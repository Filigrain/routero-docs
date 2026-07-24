---
lang: zh-CN
page_id: inference-apis/models
permalink: /inference-apis/models.html
title: 模型
parent: 推理 API
nav_order: 4
description: "通过 GET /v1/models 列出你的工作区可提供的模型。"
---

# 模型

列出你的工作区已配置可提供的模型。响应遵循 OpenAI 结构，因此兼容 OpenAI 的工具与编码 agent 可开箱即用。

**端点：** `GET https://api.routero.ai/v1/models`

---

## 请求

```bash
curl https://api.routero.ai/v1/models \
  -H "Authorization: Bearer YOUR_ROUTERO_KEY"
```

---

## 响应

```json
{
  "object": "list",
  "data": [
    {"id": "openai/gpt-5.5", "object": "model", "created": 1718000000, "owned_by": "openai"},
    {"id": "anthropic/claude-sonnet-4-6-20250514", "object": "model", "created": 1718000000, "owned_by": "anthropic"}
  ]
}
```

每个条目带有最小化的 OpenAI 兼容字段：`id`、`object`、`created`、`owned_by`。

{: .note }
`/v1/models` 返回的是用于客户端兼容的模型列表。如需价格、能力与逐模型配置，请使用仪表板的模型管理——而非此端点。

---

## 相关内容

→ [聊天]({% link zh-CN/inference-apis/chat.md %}) · [向量]({% link zh-CN/inference-apis/embeddings.md %}) · [图像]({% link zh-CN/inference-apis/images.md %})
