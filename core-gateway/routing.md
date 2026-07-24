---
lang: en
page_id: core-gateway/routing
title: Routing & Load Balancing
parent: Core Gateway
nav_order: 2
description: "Routing strategies, model groups, the Router, and how Routero selects providers per request."
---

# Routing & Load Balancing

The Routero Router distributes each request across one or more configured provider deployments using a pluggable strategy. You configure model groups (a named alias → list of provider deployments); the Router picks one based on real-time health and your chosen strategy.

---

## Routing strategies

| Strategy | How it picks | Best for |
|---|---|---|
| `simple_shuffle` (default) | Random weighted selection | Even distribution, simple setups |
| `least_busy` | Deployment with lowest in-flight request count | Throughput-limited providers |
| `lowest_latency` | Deployment with lowest recent p50 latency | Latency-sensitive applications |
| `lowest_cost` | Deployment with lowest per-token cost | Cost optimisation |
| `lowest_tpm_rpm` | Deployment furthest from its TPM/RPM limit | Rate-limit avoidance |
| `usage_based_routing_v2` | Tracks real-time usage against provider limits | High-volume, mixed rate limits |
| `tag_based_routing` | Matches request tags to deployment tags | Residency, capability routing |

Set the strategy per model group in your router configuration.

---

## Model groups

A model group maps a named alias to an ordered list of provider deployments. Example:

```yaml
model_list:
  - model_name: default
    litellm_params:
      model: openai/gpt-4o
      api_key: os.environ/OPENAI_API_KEY
    model_info:
      mode: chat

  - model_name: default
    litellm_params:
      model: anthropic/claude-sonnet-4-6-20250514
      api_key: os.environ/ANTHROPIC_API_KEY

  - model_name: default
    litellm_params:
      model: bedrock/anthropic.claude-sonnet-4-6-20250514-v1:0

router_settings:
  routing_strategy: least_busy
  num_retries: 3
  timeout: 30
```

Requests to `model: "default"` are distributed across all three deployments. On failure, the Router automatically retries on the next available deployment.

---

## Health monitoring

The Router tracks each deployment's health in Redis:
- **Error rate** — tracks 5xx, 429, and content-filter trip rates.
- **Cooldown** — a deployment that crosses an error threshold is cooled down (removed from rotation) for a configurable period.
- **Latency percentiles** — p50/p95 rolling window, used by `lowest_latency` strategy.
- **TPM/RPM proximity** — tracks usage against declared provider limits for `usage_based_routing_v2`.

---

## Routing state

All routing state (cooldowns, usage counters, latency windows) is stored in Redis. In a multi-instance deployment, all proxy replicas share the same routing state — no cross-instance coordination required beyond the shared Redis.

→ [Failover & Fallbacks]({% link core-gateway/failover.md %}) for how the Router handles provider errors mid-request.
→ [Auto Router]({% link core-gateway/auto-router.md %}) for intent-based model selection that runs before the strategy above.
