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

- **Base URL：** `{{ site.api_base_url }}/v1`
- **鉴权：** `Authorization: Bearer YOUR_ROUTERO_KEY`（一个 Routero 虚拟密钥）

{: .note }
在仪表板的 **API Keys** 下创建虚拟密钥。你可以把密钥限定到某个团队、限制可用模型，并附加预算。请像保管密钥一样保管它——它为你应用的每一个请求提供身份验证。

---

## 你的第一个请求（curl）

```bash
curl {{ site.api_base_url }}/v1/chat/completions \
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
    base_url="{{ site.api_base_url }}/v1",
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
  baseURL: "{{ site.api_base_url }}/v1",
});

const response = await client.chat.completions.create({
  model: "openai/gpt-5.5",
  messages: [{ role: "user", content: "Hello!" }],
});
```

---

## 模型

`model` 字段接受 Routero 已配置可提供的任意模型字符串。关于模型列表参见[模型]({% link zh-CN/inference-apis/models.md %})，路由机制参见[路由与负载均衡]({% link zh-CN/core-gateway/routing.md %})。

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

## 供应商扩展参数

Routero 使用兼容 OpenAI 的请求字段完成通用操作。对于供应商或模型专有的选项，可以使用 OpenAI Python SDK 的 `extra_body` 请求选项。

例如，所选图像模型和 Routero 适配器支持 `seed` 时：

```python
response = client.images.generate(
    model="YOUR_IMAGE_MODEL",
    prompt="日落时分的城市天际线，水彩画风格",
    extra_body={"seed": 123},
)
```

对于这个 JSON 图像生成请求，SDK 会将额外字段合并到 HTTP 请求体中：

```json
{
  "model": "YOUR_IMAGE_MODEL",
  "prompt": "日落时分的城市天际线，水彩画风格",
  "seed": 123
}
```

`extra_body` 是 SDK 的请求选项，使用它不代表 HTTP JSON 请求体必须包含名为 `extra_body` 的字段。使用普通 HTTP 客户端时，请遵循对应端点的请求格式；文件上传端点使用 multipart 表单，不能直接套用这里的 JSON 格式。

可用的扩展字段和取值取决于所选模型与 Routero 适配器，请按模型需要添加。`guardrail_id` 等 Routero 能力 ID 用于配置网关功能，供应商扩展参数则用于配置模型行为。

基础图视频流程参见[图像]({% link zh-CN/inference-apis/images.md %})和[视频]({% link zh-CN/inference-apis/videos.md %})；SDK 的额外请求选项参见 [OpenAI Python SDK 文档](https://developers.openai.com/api/reference/python)。

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
→ 关于完整的端点能力，参见[推理 API]({% link zh-CN/inference-apis.md %})。
