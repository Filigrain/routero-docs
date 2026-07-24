---
lang: en
page_id: inference-apis
title: Inference APIs
nav_order: 11
has_children: true
description: "The inference endpoints Routero exposes — chat, embeddings, images, and models — one OpenAI-compatible surface across every provider."
---

# Inference APIs

Routero normalizes the request and response schema across every provider behind a single OpenAI-compatible API. Point any OpenAI SDK — or a plain HTTP client — at one base URL, and use the model string to choose what runs.

- **Base URL:** `https://api.routero.ai/v1`
- **Authentication:** `Authorization: Bearer YOUR_ROUTERO_KEY`

Every endpoint accepts the standard OpenAI request shape and returns the standard OpenAI response shape; Routero translates to and from each upstream provider.

---

## Endpoints

| Endpoint | Method | Purpose |
|---|---|---|
| [`/chat/completions`]({% link inference-apis/chat.md %}) | POST | Generate text and conversations |
| [`/embeddings`]({% link inference-apis/embeddings.md %}) | POST | Create vector embeddings |
| [`/images/generations`]({% link inference-apis/images.md %}) | POST | Generate and edit images |
| [`/models`]({% link inference-apis/models.md %}) | GET | List available models |

{: .note }
For chat, Routero also speaks the Anthropic-native Messages API at `https://api.routero.ai/anthropic/v1/messages`. See [Chat]({% link inference-apis/chat.md %}).

---

## Response headers

Every inference response carries `x-routero-*` headers you can log or display:

| Header | Meaning |
|---|---|
| `x-routero-call-id` | Unique ID for the request |
| `x-routero-model-id` | The deployment that served the request |
| `x-routero-model-region` | Region of the serving deployment |
| `x-routero-response-cost` | Cost charged for the response |
| `x-routero-response-duration-ms` | End-to-end latency |
| `x-routero-attempted-fallbacks` | Deployments tried on failover, if any |

---

## Streaming

Streaming endpoints use standard Server-Sent Events (SSE). On failover mid-stream, Routero replays only the tail, so the client receives one uninterrupted stream.

---

## Related

→ [Calling the API]({% link integration/api-calling.md %}) for a quick first request.
→ [Routing & Load Balancing]({% link core-gateway/routing.md %}) for how a model string resolves to a deployment.
