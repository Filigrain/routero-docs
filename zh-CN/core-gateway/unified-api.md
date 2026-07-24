---
lang: zh-CN
page_id: core-gateway/unified-api
permalink: /core-gateway/unified-api.html
title: 统一 API
parent: 核心网关
nav_order: 1
description: "Routero AI 暴露的所有端点，以及它支持的 100+ 供应商。"
---

# 统一 API

Routero AI 在 100+ 个 LLM 供应商之前暴露单一的 OpenAI 兼容 API 接口。只需更改 `base_url` —— 其他一切保持不变。

**Base URL：** `https://api.routero.ai/v1`

---

## 推理端点（数据平面）

所有端点都接受标准的 OpenAI 请求格式，并返回标准的 OpenAI 响应格式。

| 端点 | 方法 | 说明 |
|---|---|---|
| `/chat/completions` | POST | 聊天补全 —— 主要端点 |
| `/completions` | POST | 旧版文本补全 |
| `/embeddings` | POST | 文本嵌入 |
| `/images/generations` | POST | 图像生成 |
| `/images/edits` | POST | 图像编辑 |
| `/audio/speech` | POST | 文本转语音 |
| `/audio/transcriptions` | POST | 语音转文本 |
| `/moderations` | POST | 内容审核 |
| `/rerank` | POST | 文档重排序（Cohere 兼容） |
| `/batches` | POST | 异步批处理 |
| `/files` | POST/GET | 文件上传/检索 |
| `/models` | GET | 列出可用模型 |
| `/responses` | POST | OpenAI Responses API |
| `/threads`、`/assistants` | POST/GET | Assistants API |

**供应商原生别名：**
- Anthropic：`/v1/messages`、`/v1/messages/count_tokens`
- Google：`/v1beta/models/{model}:generateContent`、`:streamGenerateContent`、`:countTokens`
- Azure OpenAI：`/openai/deployments/{model}/chat/completions`

---

## 支持的供应商

Routero 为 100+ 个供应商、139 种配置提供逐供应商的转换。以下为部分示例：

| 供应商 | 备注 |
|---|---|
| OpenAI | 所有模型，所有端点 |
| Anthropic | Claude 系列，包括 Messages API |
| AWS Bedrock | 所有 Bedrock 模型，包括 Claude、Llama、Mistral |
| Google Vertex AI | Gemini、PaLM、嵌入模型 |
| Google Gemini（直连） | `gemini-*` 模型 |
| Azure OpenAI | 所有部署，Azure AI Studio |
| Groq | 超快推理 |
| Ollama | 本地/自托管模型 |
| Cohere | 补全、嵌入、重排序 |
| Mistral | 所有 Mistral 模型 |
| DeepSeek | DeepSeek-R1、V3 |
| Together AI | 开源模型 |
| Fireworks AI | 快速的开源模型推理 |
| xAI（Grok） | Grok 系列 |
| Perplexity | 在线 LLM |
| Databricks | DBRX、Databricks 上的 Llama |
| AWS SageMaker | 支持自定义端点 |
| IBM Watsonx | 企业级 LLM |
| Snowflake | Cortex LLM |
| vLLM / hosted_vllm | 自托管的 vLLM 实例 |
| 区域性供应商 | Volcengine、DashScope、MiniMax、Moonshot、ZhipuAI 等 |

查看 `/models` 可获取你工作区中已配置模型的完整实时列表。

---

## 模型字符串格式

```python
# 你的工作区提供的模型
"openai/gpt-5.5"

# 限定供应商
"openai/gpt-4o"
"anthropic/claude-sonnet-4-6-20250514"
"bedrock/anthropic.claude-sonnet-4-6-20250514-v1:0"
"azure/my-deployment-name"
"ollama/llama3.2"

# 裸名称 —— Routero 自动推断供应商
"gpt-4o"
"claude-sonnet-4-6"
```

---

## 流式

所有流式端点都使用标准的服务器发送事件（SSE）。Routero 零缓冲地透传数据块。在流式响应过程中发生故障转移时，仅重放尾部内容 —— 即使主供应商在响应中途失败，客户端仍会收到一个不间断的流。

```python
stream = client.chat.completions.create(
    model="openai/gpt-5.5",
    messages=[{"role": "user", "content": "Hello!"}],
    stream=True,
)
for chunk in stream:
    print(chunk.choices[0].delta.content or "", end="")
```
