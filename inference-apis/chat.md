---
lang: en
page_id: inference-apis/chat
title: Chat
parent: Inference APIs
nav_order: 1
description: "Generate text and conversations with POST /v1/chat/completions — OpenAI-compatible, streaming, tools, and structured outputs."
---

# Chat

Generate text and multi-turn conversations with the chat-completions endpoint. It is fully OpenAI-compatible — messages, tools, streaming, vision, and structured outputs all work unchanged.

**Endpoint:** `POST https://api.routero.ai/v1/chat/completions`

---

## Request

```bash
curl https://api.routero.ai/v1/chat/completions \
  -H "Authorization: Bearer YOUR_ROUTERO_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "openai/gpt-5.5",
    "messages": [
      {"role": "system", "content": "You are a concise assistant."},
      {"role": "user", "content": "What is the capital of France?"}
    ]
  }'
```

```python
response = client.chat.completions.create(
    model="openai/gpt-5.5",
    messages=[{"role": "user", "content": "What is the capital of France?"}],
)
print(response.choices[0].message.content)
```

### Key parameters

| Parameter | Type | Description |
|---|---|---|
| `model` | string | Required. Any model Routero serves. |
| `messages` | array | Required. The conversation turns (`role` + `content`). |
| `stream` | boolean | Stream tokens via SSE as they generate. |
| `temperature` | number | Sampling temperature. |
| `max_tokens` | integer | Cap on generated tokens. |
| `tools` / `tool_choice` | object | Function / tool calling. |
| `response_format` | object | JSON / structured outputs. |
| `user` | string | End-user identifier for attribution. |

The full OpenAI chat-completions parameter set is accepted.

---

## Response

```json
{
  "id": "chatcmpl-...",
  "object": "chat.completion",
  "model": "openai/gpt-5.5",
  "choices": [
    {"index": 0, "message": {"role": "assistant", "content": "Paris."}, "finish_reason": "stop"}
  ],
  "usage": {"prompt_tokens": 12, "completion_tokens": 3, "total_tokens": 15}
}
```

The serving deployment and cost are also returned in the `x-routero-model-id` and `x-routero-response-cost` response headers.

---

## Streaming

Set `stream: true` to receive `chat.completion.chunk` SSE events as tokens generate.

---

## Anthropic-native Messages

If your client speaks Anthropic's Messages API, call the Anthropic-native endpoint instead of translating:

```
POST https://api.routero.ai/anthropic/v1/messages
```

Same model strings, same virtual key (send it as `x-api-key` or `Authorization: Bearer`).

{: .note }
The bare `/v1/messages` path still resolves but is deprecated — prefer `/anthropic/v1/messages`.

---

## Related

→ [Embeddings]({% link inference-apis/embeddings.md %}) · [Images]({% link inference-apis/images.md %}) · [Models]({% link inference-apis/models.md %})
→ [AI Capabilities]({% link advanced-features.md %}) for guardrails, prompts, memory, and token saving applied to a chat request.
