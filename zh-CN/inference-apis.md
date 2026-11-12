---
lang: zh-CN
page_id: inference-apis
permalink: /inference-apis.html
title: 推理 API
nav_order: 11
has_children: true
description: "Routero 暴露的推理端点——聊天、向量、图像、视频与模型——跨供应商的单一 OpenAI 兼容接口。"
---

# 推理 API

Routero 在单一 OpenAI 兼容 API 之后，对所有供应商的请求与响应 schema 进行归一化。把任意 OpenAI SDK——或普通 HTTP 客户端——指向同一个 base URL，用模型字符串选择运行什么即可。

- **Base URL：** `{{ site.api_base_url }}/v1`
- **鉴权：** `Authorization: Bearer YOUR_ROUTERO_KEY`

每个端点都接受标准 OpenAI 请求结构并返回标准 OpenAI 响应结构；Routero 负责与各上游供应商之间的双向转换。

---

## 端点

| 端点 | 方法 | 用途 |
|---|---|---|
| [`/chat/completions`]({% link zh-CN/inference-apis/chat.md %}) | POST | 生成文本与对话 |
| [`/embeddings`]({% link zh-CN/inference-apis/embeddings.md %}) | POST | 生成向量嵌入 |
| [`/images/generations`]({% link zh-CN/inference-apis/images.md %}) | POST | 生成图像 |
| [`/images/edits`]({% link zh-CN/inference-apis/images.md %}) | POST | 编辑上传的图像 |
| [`/videos`]({% link zh-CN/inference-apis/videos.md %}) | POST | 创建视频任务 |
| [`/videos/{video_id}`]({% link zh-CN/inference-apis/videos.md %}) | GET | 查询视频任务状态 |
| [`/videos/{video_id}/content`]({% link zh-CN/inference-apis/videos.md %}) | GET | 下载生成的视频 |
| [`/models`]({% link zh-CN/inference-apis/models.md %}) | GET | 列出可用模型 |

{: .note }
对于聊天，Routero 还支持 Anthropic 原生 Messages API，地址为 `{{ site.api_base_url }}/anthropic/v1/messages`。参见[聊天]({% link zh-CN/inference-apis/chat.md %})。

视频生成采用异步任务流程。参见[视频]({% link zh-CN/inference-apis/videos.md %})，了解如何创建任务、查询状态并下载结果。模型专有的请求选项参见[供应商扩展参数]({% link zh-CN/integration/api-calling.md %}#供应商扩展参数)。

---

## 响应头

推理响应中可以包含 `x-routero-*` 响应头，供记录或展示；具体返回哪些响应头取决于端点和供应商：

| 响应头 | 含义 |
|---|---|
| `x-routero-call-id` | 请求的唯一 ID |
| `x-routero-model-id` | 实际提供服务的部署 |
| `x-routero-model-region` | 服务部署所在地域 |
| `x-routero-response-cost` | 本次响应对应的费用 |
| `x-routero-response-duration-ms` | 端到端延迟 |
| `x-routero-attempted-fallbacks` | 故障转移时尝试过的部署（若有） |

---

## 流式

流式端点使用标准 Server-Sent Events（SSE）。流式过程中发生故障转移时，Routero 只回放尾部，让客户端收到一条完整的流。

---

## 相关内容

→ 快速发起第一个请求，参见 [API 调用]({% link zh-CN/integration/api-calling.md %})。
→ 模型字符串如何解析到具体部署，参见[路由与负载均衡]({% link zh-CN/core-gateway/routing.md %})。
