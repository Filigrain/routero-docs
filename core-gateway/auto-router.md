---
lang: en
page_id: core-gateway/auto-router
title: Auto Router
parent: Core Gateway
nav_order: 3
description: "Intent-based model selection — inspect the user's message and route to the best model group automatically."
---

# Auto Router

Auto Router is an **intent-based model-selection layer**. Instead of hard-coding a model in your application, you point requests at an Auto Router and it picks the best **model group** for each message based on what the user actually asked for — then the normal routing, load-balancing, and failover machinery takes over.

{: .note }
Auto Router is **not** a routing strategy. It runs *before* the strategy you configured in [Routing & Load Balancing]({% link core-gateway/routing.md %}) — it rewrites the requested model to the chosen group, and the Router then selects a healthy deployment for that group the usual way. The two are independent and compose cleanly.

---

## How it works

Each Auto Router holds a set of **routes**. A route is a target model group plus a description of the kinds of requests it should serve, expressed as a handful of example **utterances**. On every request:

1. Auto Router extracts the text from the request messages.
2. It matches the text against the routes and selects the best fit.
3. The selected route's model group replaces the requested model.
4. The Router proceeds with its normal strategy (least-busy, lowest-cost, …) and [failover]({% link core-gateway/failover.md %}) behaviour.
5. If no route matches — or anything goes wrong — the request falls back to the router's configured **default model**. Auto Router never blocks a request.

Two matching engines are available, selected per router:

| Mode | How it matches | Best for |
|---|---|---|
| **Embedding** (default) | Embeds the message and each route's utterances; picks the route with the highest cosine similarity above its threshold | High volume, low overhead, deterministic |
| **Classifier** | Asks a small LLM to classify the message into one of the routes | Subtle intent where keyword/embedding similarity is ambiguous |

Both engines run entirely inside your Routero deployment using an **internal service account** — the embedding and classification calls loop back through the gateway's own `/embeddings` and `/chat/completions` endpoints. They do **not** consume your virtual-key budget and do **not** call external providers at your expense.

{: .note }
Auto Router is static and configuration-driven — it does **not** learn or adapt over time. The routing decision is fully determined by your route definitions, the message, and the embedding/classifier model. To change behaviour, edit the routes.

---

## Defining routes

A route has four parts:

| Field | Description |
|---|---|
| `name` | The target model **group** to route to (must match a configured model group). Must be unique within the router. |
| `description` | A short human-readable summary of what the route handles. Used by the classifier mode. |
| `utterances` | Example phrases that characterise the route. The embedding engine compares the incoming message against these. Up to 50 per route, 500 per router. |
| `score_threshold` | Optional. Similarity score (0–1) a route must exceed to win in embedding mode. Default `0.2`. |

Example route table for a triage router:

| Route (model group) | Description | Example utterances |
|---|---|---|
| `reasoning` | Complex reasoning, maths, analysis | *"prove this theorem", "debug this algorithm", "analyse the trade-offs"* |
| `coding` | Code generation and explanation | *"write a python function", "refactor this class", "explain this stack trace"* |
| `general` (default) | Everyday questions and chat | *everything else* |

![The route builder — model, description, utterances, score threshold, and a live JSON preview](/assets/images/auto-router/auto-router-route-builder.png)

---

## Creating an Auto Router

Auto Routers are created as **virtual deployments** from the dashboard or the model-management API. The simplest path is the dashboard: **Models & Endpoints → Add → Auto Router**.

![The Add menu on the Models & Endpoints page, with the Auto Router option](/assets/images/auto-router/add-auto-router-entry.png)

The fields the gateway stores:

```yaml
# Conceptual — created via the dashboard "Add Auto Router" flow or the model API,
# not written directly into your main config file.
- model_name: triage
  litellm_params:
    model: auto_router/triage
    auto_router_config: |
      {
        "routes": [
          { "name": "reasoning", "description": "Complex reasoning, maths, analysis",
            "utterances": ["prove this theorem", "analyse the trade-offs"],
            "score_threshold": 0.3 },
          { "name": "coding", "description": "Code generation and explanation",
            "utterances": ["write a python function", "refactor this class"] }
        ]
      }
    auto_router_default_model: general
    auto_router_routing_mode: embedding      # or "classifier"
    # auto_router_classifier_model: internal-gpt-4o-mini   # required only in classifier mode
```

Required fields:

- `model` — must start with `auto_router/`. The suffix becomes the router's name.
- `auto_router_config` — a JSON string with the `routes` array.
- `auto_router_default_model` — the model group used when no route matches or the engine errors.

Optional fields:

- `auto_router_routing_mode` — `embedding` (default) or `classifier`.
- `auto_router_classifier_model` — the model used for classification (required in classifier mode; ignored otherwise).
- `auto_router_embedding_model` — override the embedding model used in embedding mode.

The dashboard form validates uniqueness, thresholds, and utterance limits for you, and shows a live JSON preview of the config.

![The Add Auto Router drawer — name, default model, routing mode, and the route builder](/assets/images/auto-router/add-auto-router-drawer.png)

---

## Calling an Auto Router

From the caller's perspective, an Auto Router is just another model name. Point your existing request at it:

```python
response = client.chat.completions.create(
    model="auto_router/triage",          # the Auto Router picks the real model group
    messages=[{"role": "user", "content": "Prove that the sum of two evens is even."}],
)
```

The gateway selects `reasoning` for that message, hands off to the Router for deployment selection, and returns the response. The response carries headers showing which deployment ultimately served the call:

- `x-routero-model-id` — the chosen deployment's model id
- `x-routero-model-api-base` — the chosen deployment's API base

![An Auto Router as it appears in the model detail view](/assets/images/auto-router/auto-router-overview.png)

{: .note }
Auto Router inspects message **content**, so it is skipped for requests without messages (for example pass-through and non-chat endpoints) — those go straight to the requested model.

---

## Multi-tenancy and regions

Each Auto Router is **org-scoped**: a router belongs to one organisation, and its routes are resolved only for keys in that organisation. When you have per-organisation model groups, give each org its own Auto Router referencing its own groups.

The internal embedding and classifier models default to region-appropriate values so a China-region workspace uses domestic models out of the box:

| Region | Default embedding model | Default classifier model |
|---|---|---|
| China (`cn-north-1`) | `internal-text-embedding-v4` | `internal-qwen-plus` |
| All other regions | `internal-text-embedding-3-small` | `internal-gpt-4o-mini` |

Override either by setting `auto_router_embedding_model` / `auto_router_classifier_model` on the router.

---

## Dependencies and enablement

| Mode | Requirement |
|---|---|
| **Embedding** | The `semantic-router` Python package. The gateway raises a clear install instruction if a router in embedding mode is created without it. |
| **Classifier** | No extra dependencies — uses the standard chat-completions path. |

Both modes need the internal embedding and classifier models present in your model list (they are tagged `usage: auto_router` in the default configuration) and a seeded internal service account. These are part of a standard Routero deployment; no Redis, vector database, or GPU is required for Auto Router itself.

---

## Combining with the rest of the gateway

Auto Router composes with every other gateway capability:

- **Routing & failover** — the chosen model group is load-balanced and failed over exactly like any directly-requested model.
- **Policies** — a model group that an Auto Router routes to can itself carry a [capability policy]({% link core-gateway/policies.md %}) (guardrails, prompts, memory, token saving).
- **Guardrails / prompts / memory / token saving** — apply to the resolved request as usual. See [AI Capabilities]({% link advanced-features.md %}).

→ [Routing & Load Balancing]({% link core-gateway/routing.md %}) for the deployment-selection strategies Auto Router hands off to.
→ [Failover & Fallbacks]({% link core-gateway/failover.md %}) for retry behaviour on the selected group.
