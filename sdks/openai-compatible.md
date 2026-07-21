---
lang: en
page_id: sdks/openai-compatible
title: OpenAI-Compatible Clients
parent: SDKs
nav_order: 2
description: "Use any OpenAI SDK — Python, TypeScript, Go, or any HTTP client — with Routero as the backend."
---

# OpenAI-Compatible Clients

Routero exposes a fully OpenAI-compatible API. Any language with an OpenAI SDK works out of the box — change `base_url`, keep everything else.

---

## Python (openai package)

```python
import openai

client = openai.OpenAI(
    api_key="YOUR_ROUTERO_KEY",
    base_url="https://api.routero.ai/v1",
)

response = client.chat.completions.create(
    model="smart/balanced",
    messages=[{"role": "user", "content": "Hello!"}],
)
```

---

## TypeScript / Node (openai npm package)

```typescript
import OpenAI from "openai";

const client = new OpenAI({
  apiKey: "YOUR_ROUTERO_KEY",
  baseURL: "https://api.routero.ai/v1",
});

const response = await client.chat.completions.create({
  model: "smart/balanced",
  messages: [{ role: "user", content: "Hello!" }],
});
```

---

## Go (sashabaranov/go-openai)

```go
import "github.com/sashabaranov/go-openai"

config := openai.DefaultConfig("YOUR_ROUTERO_KEY")
config.BaseURL = "https://api.routero.ai/v1"
client := openai.NewClientWithConfig(config)

resp, err := client.CreateChatCompletion(
    context.Background(),
    openai.ChatCompletionRequest{
        Model: "smart/balanced",
        Messages: []openai.ChatCompletionMessage{
            {Role: openai.ChatMessageRoleUser, Content: "Hello!"},
        },
    },
)
```

---

## curl / any HTTP client

```bash
curl https://api.routero.ai/v1/chat/completions \
  -H "Authorization: Bearer YOUR_ROUTERO_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model": "smart/balanced", "messages": [{"role": "user", "content": "Hello!"}]}'
```

---

## AI Capabilities with OpenAI clients

Pass AI Capability IDs via the SDK's `extra_body` parameter (Python/TS) or as additional JSON fields in the request body:

```python
# Python — extra_body
response = client.chat.completions.create(
    model="smart/balanced",
    messages=[...],
    extra_body={"guardrail_id": "pii-redact-prod"},
)
```

```typescript
// TypeScript — extra_body option
const response = await client.chat.completions.create({
  model: "smart/balanced",
  messages: [...],
  // @ts-ignore — Routero extension
  guardrail_id: "pii-redact-prod",
});
```

The `extra_body` / extended fields are stripped by Routero before the request reaches the upstream provider — the provider never sees them.
