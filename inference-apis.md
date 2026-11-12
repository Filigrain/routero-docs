---
lang: en
page_id: inference-apis
title: Inference APIs
nav_order: 11
has_children: true
description: "The inference endpoints Routero exposes — chat, embeddings, images, videos, and models — one OpenAI-compatible surface across every provider."
---

# Inference APIs

Routero normalizes the request and response schema across every provider behind a single OpenAI-compatible API. Point any OpenAI SDK — or a plain HTTP client — at one base URL, and use the model string to choose what runs.

- **Base URL:** `{{ site.api_base_url }}/v1`
- **Authentication:** `Authorization: Bearer YOUR_ROUTERO_KEY`

Every endpoint accepts the standard OpenAI request shape and returns the standard OpenAI response shape; Routero translates to and from each upstream provider.

---

## Endpoints

| Endpoint | Method | Purpose |
|---|---|---|
| [`/chat/completions`]({% link inference-apis/chat.md %}) | POST | Generate text and conversations |
| [`/embeddings`]({% link inference-apis/embeddings.md %}) | POST | Create vector embeddings |
| [`/images/generations`]({% link inference-apis/images.md %}) | POST | Generate images |
| [`/images/edits`]({% link inference-apis/images.md %}) | POST | Edit uploaded images |
| [`/videos`]({% link inference-apis/videos.md %}) | POST | Create a video task |
| [`/videos/{video_id}`]({% link inference-apis/videos.md %}) | GET | Check video task status |
| [`/videos/{video_id}/content`]({% link inference-apis/videos.md %}) | GET | Download a generated video |
| [`/models`]({% link inference-apis/models.md %}) | GET | List available models |

{: .note }
For chat, Routero also speaks the Anthropic-native Messages API at `{{ site.api_base_url }}/anthropic/v1/messages`. See [Chat]({% link inference-apis/chat.md %}).

Video generation uses an asynchronous task workflow. Follow [Videos]({% link inference-apis/videos.md %}) to create a task, check its status, and download the result. For model-specific request options, see [Provider-specific parameters]({% link integration/api-calling.md %}#provider-specific-parameters).

---

## Response headers

Inference responses can include `x-routero-*` headers you can log or display. Available headers depend on the endpoint and provider:

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
