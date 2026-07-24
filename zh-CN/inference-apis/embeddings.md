---
lang: zh-CN
page_id: inference-apis/embeddings
permalink: /inference-apis/embeddings.html
title: 向量
parent: 推理 API
nav_order: 2
description: "通过 POST /v1/embeddings 生成向量嵌入——OpenAI 兼容，用于搜索、聚类与 RAG。"
---

# 向量

从文本生成向量嵌入，用于语义搜索、相似度匹配、聚类与检索增强生成（RAG）。

**端点：** `POST https://api.routero.ai/v1/embeddings`

---

## 请求

```bash
curl https://api.routero.ai/v1/embeddings \
  -H "Authorization: Bearer YOUR_ROUTERO_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "openai/text-embedding-3-small",
    "input": "The food was delicious and the waiter was friendly."
  }'
```

### 参数

| 参数 | 类型 | 说明 |
|---|---|---|
| `model` | string | 必填。Routero 提供的嵌入模型。 |
| `input` | string \| array | 必填。要嵌入的文本（或文本列表）。 |
| `encoding_format` | string | `float`（默认）或 `base64`。 |
| `dimensions` | integer | 输出维度（支持的模型）。 |

---

## 响应

```json
{
  "object": "list",
  "model": "openai/text-embedding-3-small",
  "data": [
    {"object": "embedding", "index": 0, "embedding": [0.0023, -0.0091]}
  ],
  "usage": {"prompt_tokens": 8, "total_tokens": 8}
}
```

---

## 相关内容

→ [聊天]({% link zh-CN/inference-apis/chat.md %}) · [图像]({% link zh-CN/inference-apis/images.md %}) · [模型]({% link zh-CN/inference-apis/models.md %})
