---
title: Failover & Fallbacks
parent: Core Gateway
nav_order: 3
description: "Multi-provider failover chains, automatic retry behaviour, and streaming-aware fallback."
---

# Failover & Fallbacks

Routero AI treats provider outages as routing problems, not application errors. Configure a fallback chain; the Router handles failure transparently — including during active streaming responses.

**P99 failover decision + retry: <280 ms.**

---

## Configuring a fallback chain

```yaml
# In your router config or policy YAML
router_settings:
  fallbacks:
    - openai/gpt-4o:
        - anthropic/claude-sonnet-4-6-20250514
        - bedrock/meta.llama4-maverick-17b-instruct-v1:0
  num_retries: 3
  retry_after: 0.08          # 80 ms base backoff
  timeout: 30                # per-attempt timeout (seconds)
  retry_on:
    - 5xx
    - timeout
    - content_filter
```

When `openai/gpt-4o` returns a 5xx or times out, Routero retries on `claude-sonnet-4-6`, then on `llama-4-maverick`, before surfacing an error to the caller.

---

## Error classification and retry behaviour

Routero classifies provider errors and chooses the retry strategy accordingly:

| Error type | Default behaviour |
|---|---|
| `5xx` (server error) | Retry on next deployment in fallback chain |
| `429` (rate limit) | Retry on the **same** deployment after backoff (respects `Retry-After` header) |
| `content_filter` | Jump to next deployment (different model may not trip the filter) |
| `context_window` | Next deployment only if it has a larger context window |
| `auth_error` | Do not retry; surface error immediately |
| `timeout` | Retry on next deployment |

---

## Streaming-aware failover

If a provider fails mid-stream, Routero replays only the undelivered tail on the fallback provider. The client receives one uninterrupted SSE stream — no dropped connection, no duplicate tokens, no client-side retry logic required.

---

## Budget-aware fallback

Fallback respects your workspace's spend policies. If the primary deployment would exceed a budget ceiling, the Router selects the next deployment in the chain before making the call — the budget check runs as part of the policy gate, before the provider call.

→ [Budgets & Spend Guards]({% link core-gateway/budgets.md %})

---

## Region-pinned fallback

Fallback chains can be constrained to a data residency region. If your policy specifies `residency: eu-only`, the Router only considers deployments in EU regions for both primary and fallback selection.

→ [Policy Routing]({% link core-gateway/policy-routing.md %}) · [Data Residency & Regions]({% link deployment/data-residency.md %})

---

## Per-request audit

Every retry and fallback decision is logged in the audit trail:
- Which provider was tried
- The error type and retry reason
- The fallback provider selected
- Total latency including retry overhead

The response includes headers with the chosen provider and retry count for debugging.
