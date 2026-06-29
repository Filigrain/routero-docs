---
lang: en
page_id: guides/failover-chain
title: 3-Provider Failover Chain
parent: Guides
nav_order: 5
description: "Configure a resilient OpenAI → Anthropic → Bedrock fallback for 99.99%+ effective availability."
---

# 3-Provider Failover Chain

Configure a three-provider fallback so that a single provider outage or rate limit is transparent to your application. This is the most common production Routero configuration.

---

## What you're building

```
Request → smart/balanced
  → try: openai/gpt-4o           (primary — lowest latency)
  → if 5xx or 429 or timeout:
  → try: anthropic/claude-sonnet-4-6  (fallback 1 — different provider)
  → if 5xx or 429 or timeout:
  → try: bedrock/anthropic.claude-sonnet-4-6  (fallback 2 — different API + region)
  → if all fail: return 503 to caller with retry guidance
```

---

## Step 1 — Register the three deployments

```bash
# Primary
curl -X POST https://api.routero.ai/model/new \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{"model_name": "smart/balanced", "litellm_params": {"model": "openai/gpt-4o", "api_key": "sk-openai-..."}}'

# Fallback 1
curl -X POST https://api.routero.ai/model/new \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{"model_name": "smart/balanced", "litellm_params": {"model": "anthropic/claude-sonnet-4-6-20250514", "api_key": "sk-ant-..."}}'

# Fallback 2 — Bedrock uses IAM, not an API key
curl -X POST https://api.routero.ai/model/new \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{
    "model_name": "smart/balanced",
    "litellm_params": {
      "model": "bedrock/anthropic.claude-sonnet-4-6-20250514-v1:0",
      "aws_access_key_id": "...",
      "aws_secret_access_key": "...",
      "aws_region_name": "us-east-1"
    }
  }'
```

---

## Step 2 — Configure fallback order and retry behaviour

In the proxy config YAML or via the dashboard:

```yaml
router_settings:
  routing_strategy: least_busy
  num_retries: 2
  retry_after: 0.08         # 80ms base backoff
  timeout: 30               # per-attempt timeout (s)
  retry_on:
    - 5xx
    - timeout
    - content_filter
  fallbacks:
    - "openai/gpt-4o":
        - "anthropic/claude-sonnet-4-6-20250514"
        - "bedrock/anthropic.claude-sonnet-4-6-20250514-v1:0"
  cooldown_time: 60         # failed provider is cooled down for 60s
```

---

## Step 3 — Test the failover

Temporarily set an invalid key for OpenAI and verify that requests fall through to Anthropic:

```python
import openai

client = openai.OpenAI(
    api_key="YOUR_ROUTERO_KEY",
    base_url="https://api.routero.ai/v1",
)

response = client.chat.completions.create(
    model="smart/balanced",
    messages=[{"role": "user", "content": "Which provider am I on?"}],
)
# Check x-litellm-model-id header — should show the fallback provider
print(response.model)
```

---

## What to check in the audit log

The audit log entry for each request includes:
- `fallback_count` — number of retries before success
- `model` — the provider that ultimately served the response
- `latency_ms` — total latency including retry overhead

High `fallback_count` on a provider indicates it should be cooled down or deprioritised.
