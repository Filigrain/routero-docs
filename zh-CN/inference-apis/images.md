---
lang: zh-CN
page_id: inference-apis/images
permalink: /inference-apis/images.html
title: 图像
parent: 推理 API
nav_order: 3
description: "通过 POST /v1/images/generations 与 /v1/images/edits 生成和编辑图像。"
---

# 图像

从文本提示词生成图像，或对已有图像进行编辑。OpenAI 兼容——支持 DALL·E、Stable Diffusion 等你的工作区已配置的图像模型。

**端点：**

- `POST https://api.routero.ai/v1/images/generations` —— 根据提示词生成
- `POST https://api.routero.ai/v1/images/edits` —— 编辑已上传的图像

---

## 生成

```bash
curl https://api.routero.ai/v1/images/generations \
  -H "Authorization: Bearer YOUR_ROUTERO_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "openai/dall-e-3",
    "prompt": "A watercolour of the Singapore skyline at sunset",
    "n": 1,
    "size": "1024x1024"
  }'
```

### 参数

| 参数 | 类型 | 说明 |
|---|---|---|
| `model` | string | 必填。Routero 提供的图像模型。 |
| `prompt` | string | 必填。对图像的描述。 |
| `n` | integer | 要生成的图像数量。 |
| `size` | string | 例如 `1024x1024`。 |
| `response_format` | string | `url`（默认）或 `b64_json`。 |

---

## 响应

```json
{
  "created": 1718000000,
  "data": [
    {"url": "https://..."}
  ]
}
```

---

## 编辑

`POST /v1/images/edits` 接收 multipart 表单数据——原图、可选的蒙版，以及描述改动的提示词。模型与响应结构与生成相同。

---

## 相关内容

→ [聊天]({% link zh-CN/inference-apis/chat.md %}) · [向量]({% link zh-CN/inference-apis/embeddings.md %}) · [模型]({% link zh-CN/inference-apis/models.md %})
