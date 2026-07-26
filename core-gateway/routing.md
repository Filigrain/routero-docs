---
lang: en
page_id: core-gateway/routing
title: Routing & Load Balancing
parent: LLM Gateway
nav_order: 2
description: "How the Router picks a healthy deployment for each request — strategies, model groups, and health-aware load balancing."
---

# Routing & Load Balancing

When a request names a model, the **Router** picks one healthy deployment to serve it. You group one or more provider deployments under a **model name**, choose a **strategy** for picking among them, and the Router applies that strategy using real-time health and usage data.

```
request: model = "default"
   → resolve the model group
   → pick one deployment by strategy + live health
   → call it (failover on failure)
```

{: .note }
Routing picks a deployment *within a model group*. [Auto Router]({% link core-gateway/auto-router.md %}) runs *before* it and can rewrite the requested model to a different group based on message intent. The two compose.

---

## Model groups

A model group maps a name to one or more provider deployments. Requests for that name are load-balanced across the deployments:

```yaml
model_list:
  - model_name: default              # the name callers use
    litellm_params:
      model: openai/gpt-5.5
      api_key: os.environ/OPENAI_API_KEY

  - model_name: default
    litellm_params:
      model: anthropic/claude-sonnet-4-6-20250514
      api_key: os.environ/ANTHROPIC_API_KEY

  - model_name: default
    litellm_params:
      model: bedrock/anthropic.claude-sonnet-4-6-20250514-v1:0
```

`default` is the **public name** callers send — the alias you set when you [add a model](/) — and the three entries are the deployments the Router chooses between. A single-deployment group just routes every request to that one deployment.

You can also alias one public name to another with `model_group_alias`, so callers use a stable name while you re-point it underneath.

---

## Routing strategies

Set `routing_strategy` to choose how the Router picks among the healthy deployments in a group:

| Strategy | How it picks | Best for |
|---|---|---|
| `simple-shuffle` (default) | Random weighted selection | Even distribution, simple setups |
| `least-busy` | Deployment with the fewest in-flight requests | Throughput-limited providers |
| `latency-based-routing` | Deployment with the lowest average recent latency | Latency-sensitive traffic |
| `cost-based-routing` | Deployment with the lowest per-token cost | Cost optimisation |
| `usage-based-routing` | Deployment furthest from its TPM/RPM usage | High volume, mixed rate limits |

```yaml
router_settings:
  routing_strategy: least-busy
  num_retries: 3
  timeout: 30
```

Tag-based routing — pinning requests to deployments by tag, for example by region — is a separate filter you enable with `enable_tag_filtering` on top of any strategy.

---

## Health and cooldown

The Router tracks each deployment's health in Redis and steers traffic away from unhealthy ones:

- **Error rate** — tracks 5xx, 429, and content-filter trips.
- **Cooldown** — a deployment that crosses the error threshold is cooled down (removed from rotation) for a period, then brought back.
- **Latency** — a rolling average of recent response latency, used by `latency-based-routing`.
- **Usage** — TPM/RPM usage against the provider's declared limits, used by `usage-based-routing`.

---

## Routing state

All routing state — cooldowns, usage counters, latency windows — lives in Redis. In a multi-replica deployment, every proxy replica shares that state through Redis, so load-balancing decisions stay consistent across instances.

---

## Combining with the rest of the gateway

- **Auto Router** — runs *before* the strategy; rewrites the requested model to a group by message intent. → [Auto Router]({% link core-gateway/auto-router.md %})
- **Failover** — if the chosen deployment errors mid-request, the Router retries on another. → [Failover & Fallbacks]({% link core-gateway/failover.md %})
- **Policies** — a model group can carry a capability policy (guardrails, prompts, memory, token saving). → [Policies]({% link core-gateway/policies.md %})
