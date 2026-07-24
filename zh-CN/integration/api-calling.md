---
lang: zh-CN
page_id: integration/api-calling
permalink: /integration/api-calling.html
title: API 调用
parent: 接入
nav_order: 1
description: "Routero 兼容 OpenAI——改 base_url、用你的虚拟密钥，即可用任意语言调用 /chat/completions。"
---

# API 调用

Routero 暴露一个完全**兼容 OpenAI** 的 API。把任意 OpenAI SDK——或普通 HTTP 客户端——指向 Routero，只需两个值，其余一切（消息、工具、流式、视觉、结构化输出）都原样可用。

- **Base URL：** `https://api.routero.ai/v1`
- **鉴权：** `Authorization: Bearer YOUR_ROUTERO_KEY`（一个 Routero 虚拟密钥）

{: .note }
在仪表板的 **API Keys** 下创建虚拟密钥。你可以把密钥限定到某个团队、限制可用模型，并附加预算。请像保管密钥一样保管它——它为你应用的每一个请求提供身份验证。

---

## 你的第一个请求（curl）

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

## Python（openai）

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

## TypeScript / Node（openai）

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

## 模型

`model` 字段接受 Routero 已配置可提供的任意模型字符串。`openai/gpt-5.5` 是一个路由模型，会为你挑选一个健康的部署；你也可以直接指定某个供应商模型。关于模型列表与路由机制，参见[路由与负载均衡]({% link zh-CN/core-gateway/routing.md %})与[统一 API]({% link zh-CN/core-gateway/unified-api.md %})。

---

## 流式

设置 `stream: true` 即可在生成时逐 token 接收——与 OpenAI 的流式格式完全一致：

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

## 在请求上使用 AI 能力

通过 SDK 的 `extra_body`，或作为请求体中的额外 JSON 字段，传入 [AI 能力]({% link zh-CN/advanced-features.md %}) ID（护栏、提示词、记忆、Token 节省）。Routero 在网关内部应用它们，并在上游供应商看到请求之前将其剥离。

```python
response = client.chat.completions.create(
    model="openai/gpt-5.5",
    messages=[...],
    extra_body={"guardrail_id": "pii-redact-prod"},
)
```

---

## 下一步

→ 将你的编码助手经由 Routero 路由，参见 [Cursor]({% link zh-CN/integration/cursor.md %})与 [Claude Code]({% link zh-CN/integration/claude-code.md %})。
→ 关于完整的端点能力，参见[统一 API]({% link zh-CN/core-gateway/unified-api.md %})。
