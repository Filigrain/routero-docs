---
lang: en
page_id: inference-apis/images
title: Images
parent: Inference APIs
nav_order: 3
description: "Generate and edit images with POST /v1/images/generations and /v1/images/edits."
---

# Images

Generate images from a text prompt, or edit an existing image. OpenAI-compatible — works with DALL·E, Stable Diffusion, and other image models your workspace is configured to serve.

**Endpoints:**

- `POST https://api.routero.ai/v1/images/generations` — generate from a prompt
- `POST https://api.routero.ai/v1/images/edits` — edit an uploaded image

---

## Generate

```bash
curl https://api.routero.ai/v1/images/generations \
  -H "Authorization: Bearer YOUR_ROUTERO_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "openai/dall-e-3",
    "prompt": "A watercolour of the Singapore skyline at sunset",
    "n": 1,
    "size": "1024x1024"
  }'
```

### Parameters

| Parameter | Type | Description |
|---|---|---|
| `model` | string | Required. An image model Routero serves. |
| `prompt` | string | Required. Description of the image. |
| `n` | integer | Number of images to generate. |
| `size` | string | E.g. `1024x1024`. |
| `response_format` | string | `url` (default) or `b64_json`. |

---

## Response

```json
{
  "created": 1718000000,
  "data": [
    {"url": "https://..."}
  ]
}
```

---

## Edit

`POST /v1/images/edits` takes multipart form data — the original image, an optional mask, and a prompt describing the change. It uses the same model and response shape as generation.

---

## Related

→ [Chat]({% link inference-apis/chat.md %}) · [Embeddings]({% link inference-apis/embeddings.md %}) · [Models]({% link inference-apis/models.md %})
