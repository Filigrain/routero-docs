---
lang: zh-CN
page_id: inference-apis/chat
permalink: /inference-apis/chat.html
title: 聊天
parent: 推理 API
nav_order: 1
description: "通过 POST /v1/chat/completions 生成文本与对话——OpenAI 兼容，支持流式、工具调用与结构化输出。"
---

# 聊天

通过 chat-completions 端点生成文本与多轮对话。完全 OpenAI 兼容——messages、tools、流式、视觉与结构化输出都原样可用。

**端点：** `POST https://api.routero.ai/v1/chat/completions`

---

## 请求

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

### 主要参数

| 参数 | 类型 | 说明 |
|---|---|---|
| `model` | string | 必填。Routero 提供的任意模型。 |
| `messages` | array | 必填。对话轮次（`role` + `content`）。 |
| `stream` | boolean | 生成时以 SSE 流式返回 token。 |
| `temperature` | number | 采样温度。 |
| `max_tokens` | integer | 生成 token 上限。 |
| `tools` / `tool_choice` | object | 函数 / 工具调用。 |
| `response_format` | object | JSON / 结构化输出。 |
| `user` | string | 用于归属的终端用户标识。 |

接受完整的 OpenAI chat-completions 参数集。

---

## 响应

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

实际提供服务的部署与费用也会通过 `x-routero-model-id` 与 `x-routero-response-cost` 响应头返回。

---

## 流式

设置 `stream: true`，即可在 token 生成时接收 `chat.completion.chunk` SSE 事件。

---

## Anthropic 原生 Messages

如果你的客户端使用 Anthropic 的 Messages API，可直接调用 Anthropic 原生端点，无需转换：

```
POST https://api.routero.ai/anthropic/v1/messages
```

模型字符串相同，虚拟密钥相同（以 `x-api-key` 或 `Authorization: Bearer` 发送）。

{: .note }
裸路径 `/v1/messages` 仍可解析，但已废弃——请优先使用 `/anthropic/v1/messages`。

---

## 相关内容

→ [向量]({% link zh-CN/inference-apis/embeddings.md %}) · [图像]({% link zh-CN/inference-apis/images.md %}) · [模型]({% link zh-CN/inference-apis/models.md %})
→ 在聊天请求上应用护栏、提示词、记忆与 Token 节省，参见 [AI 能力]({% link zh-CN/advanced-features.md %})。
