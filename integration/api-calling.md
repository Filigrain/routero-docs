---
lang: en
page_id: integration/api-calling
title: Calling the API
parent: Integration
nav_order: 1
description: "Routero is OpenAI-compatible — change base_url, use your virtual key, and call /chat/completions from any language."
---

# Calling the API

Routero exposes a fully **OpenAI-compatible** API. Point any OpenAI SDK — or a plain HTTP client — at Routero with two values, and everything else (messages, tools, streaming, vision, structured outputs) works unchanged.

- **Base URL:** `https://api.routero.ai/v1`
- **Authentication:** `Authorization: Bearer YOUR_ROUTERO_KEY` (a Routero virtual key)

{: .note }
Create a virtual key in the dashboard under **API Keys**. You can scope a key to a team, limit its models, and attach a budget. Treat it like a secret — it authenticates every request your application makes.

---

## Your first request (curl)

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

## Python (openai)

```python
from openai import OpenAI

client = OpenAI(
    api_key="YOUR_ROUTERO_KEY",
    base_url="https://api.routero.ai/v1",
)

response = client.chat.completions.create(
    model="openai/gpt-5.5",
    messages=[{"role": "user", "content": "Hello!"}],
)
print(response.choices[0].message.content)
```

---

## TypeScript / Node (openai)

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
```

---

## Models

The `model` field accepts any model string Routero is configured to serve. `openai/gpt-5.5` is a router model that picks a healthy deployment for you; you can also name a specific provider model. See [Routing & Load Balancing]({% link core-gateway/routing.md %}) and [Unified API]({% link core-gateway/unified-api.md %}) for the model list and how routing works.

---

## Streaming

Set `stream: true` to receive tokens as they are generated — identical to the OpenAI streaming format:

```python
stream = client.chat.completions.create(
    model="openai/gpt-5.5",
    messages=[{"role": "user", "content": "Hello!"}],
    stream=True,
)
for chunk in stream:
    print(chunk.choices[0].delta.content or "", end="")
```

---

## AI capabilities on a request

Pass the [AI capability]({% link advanced-features.md %}) IDs (guardrails, prompts, memory, token saving) through the SDK's `extra_body`, or as extra JSON fields in the request body. Routero applies them inside the gateway and strips them before the upstream provider sees the request.

```python
response = client.chat.completions.create(
    model="openai/gpt-5.5",
    messages=[...],
    extra_body={"guardrail_id": "pii-redact-prod"},
)
```

---

## Next

→ [Cursor]({% link integration/cursor.md %}) and [Claude Code]({% link integration/claude-code.md %}) to route your coding assistants through Routero.
→ [Unified API]({% link core-gateway/unified-api.md %}) for the full endpoint surface.
