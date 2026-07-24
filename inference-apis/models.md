---
lang: en
page_id: inference-apis/models
title: Models
parent: Inference APIs
nav_order: 4
description: "List the models your workspace can serve with GET /v1/models."
---

# Models

List the models your workspace is configured to serve. The response follows the OpenAI shape, so OpenAI-compatible tools and coding agents work out of the box.

**Endpoint:** `GET https://api.routero.ai/v1/models`

---

## Request

```bash
curl https://api.routero.ai/v1/models \
  -H "Authorization: Bearer YOUR_ROUTERO_KEY"
```

---

## Response

```json
{
  "object": "list",
  "data": [
    {"id": "openai/gpt-5.5", "object": "model", "created": 1718000000, "owned_by": "openai"},
    {"id": "anthropic/claude-sonnet-4-6-20250514", "object": "model", "created": 1718000000, "owned_by": "anthropic"}
  ]
}
```

Each entry carries the minimal OpenAI-compatible fields: `id`, `object`, `created`, `owned_by`.

{: .note }
`/v1/models` returns the model list for client compatibility. For pricing, capabilities, and per-model configuration, use the dashboard's model management — not this endpoint.

---

## Related

→ [Chat]({% link inference-apis/chat.md %}) · [Embeddings]({% link inference-apis/embeddings.md %}) · [Images]({% link inference-apis/images.md %})
