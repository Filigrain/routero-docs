---
lang: zh-CN
page_id: sdks/openai-compatible
permalink: /sdks/openai-compatible.html
title: OpenAI 兼容客户端
parent: SDK
nav_order: 2
description: "将任意 OpenAI SDK——Python、TypeScript、Go 或任意 HTTP 客户端——与 Routero 作为后端搭配使用。"
---

# OpenAI 兼容客户端

Routero 暴露一个完全 OpenAI 兼容的 API。任何带有 OpenAI SDK 的语言都开箱即用——只需更改 `base_url`，其余保持不变。

---

## Python（openai 包）

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

## TypeScript / Node（openai npm 包）

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

## Go（sashabaranov/go-openai）

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

## curl / 任意 HTTP 客户端

```bash
curl https://api.routero.ai/v1/chat/completions \
  -H "Authorization: Bearer YOUR_ROUTERO_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model": "smart/balanced", "messages": [{"role": "user", "content": "Hello!"}]}'
```

---

## 在 OpenAI 客户端中使用高级功能

通过 SDK 的 `extra_body` 参数（Python/TS）或作为请求体中的额外 JSON 字段，传入高级功能 ID：

```python
# Python — extra_body 参数
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

`extra_body` / 扩展字段会在请求到达上游供应商之前被 Routero 剥离——供应商永远不会看到它们。
