---
title: Enterprise Quickstart
parent: Guides
nav_order: 1
description: "Provision a workspace, configure a routing policy, set a team budget, and route your first production request."
---

# Enterprise Quickstart

This guide walks a platform engineer through the minimum viable production setup: a workspace, a policy, a team budget, and a routed request with guardrails. End-to-end in under 30 minutes.

---

## Step 1 — Create a workspace

Sign up at [platform.routero.ai](https://platform.routero.ai). If you're on Single-Tenant or Self-Hosted, use your instance URL instead.

Your first workspace is created automatically. Note your admin key (`sk-admin-...`) from **Settings → API Keys**.

---

## Step 2 — Add provider credentials

In the dashboard under **Models → Provider Keys**, add the API keys for the providers you'll route to. Keys are encrypted in the database — they never appear in logs.

Start with two providers for failover:

```bash
# Add OpenAI
curl -X POST https://api.routero.ai/model/new \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{
    "model_name": "smart/balanced",
    "litellm_params": {"model": "openai/gpt-4o", "api_key": "sk-openai-..."}
  }'

# Add Anthropic as fallback
curl -X POST https://api.routero.ai/model/new \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{
    "model_name": "smart/balanced",
    "litellm_params": {"model": "anthropic/claude-sonnet-4-6-20250514", "api_key": "sk-ant-..."}
  }'
```

---

## Step 3 — Create a team with a budget

```bash
curl -X POST https://api.routero.ai/team/new \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{
    "team_alias": "engineering",
    "max_budget": 500,
    "budget_duration": "1mo",
    "soft_budget": 400
  }'
```

---

## Step 4 — Generate a scoped team key

```bash
curl -X POST https://api.routero.ai/key/generate \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{
    "team_id": "engineering",
    "models": ["smart/balanced"],
    "duration": "30d",
    "key_alias": "engineering-prod"
  }'
# Returns: { "key": "sk-..." }
```

---

## Step 5 — Route your first request

```python
import openai

client = openai.OpenAI(
    api_key="sk-...",  # the team key from step 4
    base_url="https://api.routero.ai/v1",
)

response = client.chat.completions.create(
    model="smart/balanced",
    messages=[{"role": "user", "content": "Hello, Routero!"}],
)
print(response.choices[0].message.content)
```

Check the request in **Audit Log** on the dashboard. You should see: model, provider, token counts, cost, and the team attribution.

---

## Step 6 — Add a PII guardrail

```bash
curl -X POST https://api.routero.ai/guardrail \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{
    "guardrail_name": "pii-redact",
    "engines": [{
      "engine_name": "presidio",
      "config": {
        "entities": ["PERSON", "EMAIL_ADDRESS", "PHONE_NUMBER"],
        "action": "anonymize"
      },
      "event_hooks": ["pre_call", "post_call"]
    }]
  }'
```

Pass it on requests that may contain personal data:

```python
response = client.chat.completions.create(
    model="smart/balanced",
    messages=[{"role": "user", "content": "What do we know about Alice Smith at alice@example.com?"}],
    extra_body={"guardrail_id": "pii-redact"},
)
```

The model receives: `"What do we know about [PERSON] at [EMAIL_ADDRESS]?"`

---

## Next steps

- Set up SSO → [SSO, RBAC & Audit]({% link core-gateway/sso-rbac-audit.md %})
- Add more teams and policies → [Multi-Tenancy]({% link core-gateway/multi-tenancy.md %})
- Enable Token Saving → [Token Saving]({% link advanced-features/token-saving.md %})
- Add more providers for failover → [Failover & Fallbacks]({% link core-gateway/failover.md %})
