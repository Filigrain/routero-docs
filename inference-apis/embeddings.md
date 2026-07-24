---
lang: en
page_id: inference-apis/embeddings
title: Embeddings
parent: Inference APIs
nav_order: 2
description: "Create vector embeddings with POST /v1/embeddings — OpenAI-compatible, for search, clustering, and RAG."
---

# Embeddings

Generate vector embeddings from text for semantic search, similarity matching, clustering, and retrieval-augmented generation.

**Endpoint:** `POST https://api.routero.ai/v1/embeddings`

---

## Request

```bash
curl https://api.routero.ai/v1/embeddings \
  -H "Authorization: Bearer YOUR_ROUTERO_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "openai/text-embedding-3-small",
    "input": "The food was delicious and the waiter was friendly."
  }'
```

### Parameters

| Parameter | Type | Description |
|---|---|---|
| `model` | string | Required. An embedding model Routero serves. |
| `input` | string \| array | Required. The text (or list of texts) to embed. |
| `encoding_format` | string | `float` (default) or `base64`. |
| `dimensions` | integer | Output dimensionality, for models that support it. |

---

## Response

```json
{
  "object": "list",
  "model": "openai/text-embedding-3-small",
  "data": [
    {"object": "embedding", "index": 0, "embedding": [0.0023, -0.0091]}
  ],
  "usage": {"prompt_tokens": 8, "total_tokens": 8}
}
```

---

## Related

→ [Chat]({% link inference-apis/chat.md %}) · [Images]({% link inference-apis/images.md %}) · [Models]({% link inference-apis/models.md %})
