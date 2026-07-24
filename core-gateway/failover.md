---
lang: en
page_id: core-gateway/failover
title: Failover & Fallbacks
parent: Core Gateway
nav_order: 4
description: "Multi-provider failover chains, automatic retry behaviour, and streaming-aware fallback."
---

# Failover & Fallbacks

Routero AI treats provider outages as routing problems, not application errors. Configure a fallback chain; the Router handles failure transparently — including during active streaming responses.

---

## Configuring a fallback chain

```yaml
# In your router config
router_settings:
  fallbacks:
    - openai/gpt-4o:
        - anthropic/claude-sonnet-4-6-20250514
        - bedrock/meta.llama4-maverick-17b-instruct-v1:0
  num_retries: 3
  timeout: 30                # per-attempt timeout (seconds)
```

When `openai/gpt-4o` returns a 5xx or times out, Routero retries on `claude-sonnet-4-6`, then on `llama-4-maverick`, before surfacing an error to the caller.

---

## Error classification and retry behaviour

Routero classifies provider errors and chooses the retry strategy accordingly:

| Error type | Default behaviour |
|---|---|
| `5xx` (server error) | Retry on the next healthy deployment |
| `429` (rate limit) | Retry on another deployment (respects `Retry-After`) |
| `timeout` | Retry on the next deployment |
| `content_filter` | Fall to the next model in a `content_policy_fallbacks` chain |

Retries and fallbacks target other healthy deployments in the group or chain; which errors retry is controlled by a `RetryPolicy`.

---

## Streaming-aware failover

If a provider fails mid-stream, Routero can fall back to another provider and continue the response, passing the partial output along so the fallback model picks up where the first left off. The client receives a single SSE stream without any client-side retry logic.

---

## Region and fallback chains

A fallback chain only ever considers the deployments you list in it. To keep a chain within a single data-residency region, list only deployments hosted in that region — the Router never leaves the chain you defined. For pinning traffic to specific deployments by request tag (for example EU-hosted deployments), use tag-based routing.

→ [Routing & Load Balancing]({% link core-gateway/routing.md %})

---

## Per-request visibility

Retry and fallback details are visible per request:
- Which providers were tried
- The fallback provider that ultimately served the request
- Total latency including retry overhead

See [Logs]({% link observability/logs.md %}) for the per-request detail, and check the `x-routero-attempted-retries` and `x-routero-attempted-fallbacks` response headers.
