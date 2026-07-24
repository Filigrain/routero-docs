---
lang: en
page_id: quickstart
title: Quickstart
nav_order: 2
description: "Make your first request through Routero AI in under 5 minutes."
---

# Quickstart

Get your first request routed through Routero AI in under 5 minutes. If you already use the OpenAI SDK, this is a one-line change.

{: .enterprise }
> **Prerequisites:** A Routero virtual key. Workspaces are invitation-only — ask your workspace admin to invite you and issue a key from [platform.routero.ai](https://platform.routero.ai).

---

## Two ways to integrate

| Approach | Best for | What changes |
|---|---|---|
| **OpenAI SDK (drop-in)** | Existing OpenAI codebases | `base_url` only |
| **Direct REST API** | Any language, no SDK dependency | — |

---

## Option 1 — OpenAI SDK drop-in (recommended)

Change `base_url` to `https://api.routero.ai/v1`. Everything else — messages, tools, streaming, vision, structured outputs — stays identical.

### Python

```python
import openai

client = openai.OpenAI(
    api_key="YOUR_ROUTERO_KEY",          # your Routero virtual key
    base_url="https://api.routero.ai/v1",
)

response = client.chat.completions.create(
    model="openai/gpt-5.5",              # or "anthropic/claude-sonnet-4-6", "openai/gpt-4o", etc.
    messages=[{"role": "user", "content": "Hello!"}],
)
print(response.choices[0].message.content)
```

### TypeScript / Node

```typescript
import OpenAI from "openai";

const client = new OpenAI({
  apiKey: "YOUR_ROUTERO_KEY",
  baseURL: "https://api.routero.ai/v1",
});

const response = await client.chat.completions.create({
  model: "openai/gpt-5.5",
  messages: [{ role: "user", content: "Hello!" }],
});
console.log(response.choices[0].message.content);
```

### curl

```bash
curl https://api.routero.ai/v1/chat/completions \
  -H "Authorization: Bearer YOUR_ROUTERO_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "openai/gpt-5.5",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

---

## Option 2 — Direct REST API

The gateway exposes a standard OpenAI-compatible REST interface. Use any HTTP client.

**Base URL:** `https://api.routero.ai/v1`

**Authentication:** `Authorization: Bearer YOUR_ROUTERO_KEY`

**Supported endpoints:** `/chat/completions` · `/completions` · `/embeddings` · `/images/generations` · `/audio/speech` · `/audio/transcriptions` · `/rerank` · `/batches` · `/models` and more. See [Unified API]({% link core-gateway/unified-api.md %}) for the full list.

---

## Model strings

Routero passes any model string to the appropriate provider. You can use:

| Format | Example | What it does |
|---|---|---|
| Provider-scoped | `openai/gpt-5.5` | A specific provider model |
| Bare model name | `gpt-4o` | Routero infers the provider |
| Provider variant | `bedrock/anthropic.claude-sonnet-4-6` | Fully-qualified AWS Bedrock model |

{: .note }
Your workspace admin can also define **model groups** — a single name that load-balances and fails over across several deployments. See [Routing & Load Balancing]({% link core-gateway/routing.md %}).

---

## What just happened

Every request you sent ran through Routero's four-decision pipeline:

1. **Auth & access** — Routero verified your virtual key, checked that the key may call the requested model, and confirmed your workspace budget had room.
2. **Provider selection** — The Router scored eligible deployments by current health, latency, and cost, then picked your configured primary deployment for that model.
3. **Accounting** — The token count and cost were calculated and debited from your workspace budget atomically, and the usage was logged.
4. **Response** — The provider's response was streamed back through the gateway with zero buffering.

The request now appears in your [platform dashboard](https://platform.routero.ai) usage and spend views.

---

## Activate AI Capabilities

Pass any combination of feature IDs on the same request to unlock Routero's production-AI layer. The proxy resolves each config from your workspace, applies it as a hook, and strips the ID before the upstream call — your application code never changes.

```python
response = client.chat.completions.create(
    model="openai/gpt-5.5",
    messages=[{"role": "user", "content": "Summarise last quarter's results."}],
    extra_body={
        "guardrail_id":        "my-pii-guardrail",      # redact PII before the model sees it
        "token_saving_plan_id": "my-cache-plan",         # compress + cache the response
        "prompt_id":           "my-analyst-system-prompt", # inject versioned system prompt
        "memory_id":           "user-alice-session",    # retrieve Alice's long-term context
    },
)
```

→ [AI Capabilities]({% link advanced-features.md %})

---

## What to do next

- **Bundle capabilities into a policy** → [Policies]({% link core-gateway/policies.md %})
- **Add a spend budget for your team** → [Budgets & Spend Guards]({% link core-gateway/budgets.md %})
- **Enable guardrails for PII** → [Guardrails]({% link advanced-features/guardrails.md %})
