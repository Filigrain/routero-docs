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

- **Base URL:** `{{ site.api_base_url }}/v1`
- **Authentication:** `Authorization: Bearer YOUR_ROUTERO_KEY` (a Routero virtual key)

{: .note }
Create a virtual key in the dashboard under **API Keys**. You can scope a key to a team, limit its models, and attach a budget. Treat it like a secret — it authenticates every request your application makes.

---

## Your first request (curl)

```bash
curl {{ site.api_base_url }}/v1/chat/completions \
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
    base_url="{{ site.api_base_url }}/v1",
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
  baseURL: "{{ site.api_base_url }}/v1",
});

const response = await client.chat.completions.create({
  model: "openai/gpt-5.5",
  messages: [{ role: "user", content: "Hello!" }],
});
```

---

## Models

The `model` field accepts any model string Routero is configured to serve. See [Models]({% link inference-apis/models.md %}) for the model list and [Routing & Load Balancing]({% link core-gateway/routing.md %}) for how routing works.

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

## Provider-specific parameters

Routero uses OpenAI-compatible request fields for common operations. For options specific to a provider or model, the OpenAI Python SDK offers the `extra_body` request option.

For an image model whose Routero adapter supports `seed`, for example:

```python
response = client.images.generate(
    model="YOUR_IMAGE_MODEL",
    prompt="A watercolour of a city skyline at sunset",
    extra_body={"seed": 123},
)
```

For this JSON image-generation request, the SDK merges these fields into the HTTP request body:

```json
{
  "model": "YOUR_IMAGE_MODEL",
  "prompt": "A watercolour of a city skyline at sunset",
  "seed": 123
}
```

`extra_body` is an SDK request option; using it does not mean the HTTP JSON body must contain a field named `extra_body`. Follow the endpoint's request format when using a plain HTTP client. File-upload endpoints use multipart form data instead of this JSON format.

The selected model and Routero adapter determine which extension fields and values are supported. Add only the options your model needs. Routero capability IDs such as `guardrail_id` configure gateway features, while provider-specific parameters configure model behavior.

See [Images]({% link inference-apis/images.md %}) and [Videos]({% link inference-apis/videos.md %}) for the basic media workflows, and the [OpenAI Python SDK documentation](https://developers.openai.com/api/reference/python) for additional request options.

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
→ [Inference APIs]({% link inference-apis.md %}) for the full endpoint surface.
