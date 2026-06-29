---
lang: en
page_id: core-gateway/unified-api
title: Unified API
parent: Core Gateway
nav_order: 1
description: "Every endpoint Routero AI exposes and the 100+ providers it supports."
---

# Unified API

Routero AI exposes a single OpenAI-compatible API surface in front of 100+ LLM providers. Change `base_url` — everything else stays the same.

**Base URL:** `https://api.routero.ai/v1`

---

## Inference endpoints (data plane)

All endpoints accept standard OpenAI request shapes and return standard OpenAI response shapes.

| Endpoint | Method | Description |
|---|---|---|
| `/chat/completions` | POST | Chat completions — primary endpoint |
| `/completions` | POST | Legacy text completions |
| `/embeddings` | POST | Text embeddings |
| `/images/generations` | POST | Image generation |
| `/images/edits` | POST | Image editing |
| `/audio/speech` | POST | Text-to-speech |
| `/audio/transcriptions` | POST | Speech-to-text |
| `/moderations` | POST | Content moderation |
| `/rerank` | POST | Document reranking (Cohere-compatible) |
| `/batches` | POST | Async batch processing |
| `/files` | POST/GET | File upload/retrieval |
| `/models` | GET | List available models |
| `/responses` | POST | OpenAI Responses API |
| `/threads`, `/assistants` | POST/GET | Assistants API |

**Provider-native aliases:**
- Anthropic: `/v1/messages`, `/v1/messages/count_tokens`
- Google: `/v1beta/models/{model}:generateContent`, `:streamGenerateContent`, `:countTokens`
- Azure OpenAI: `/openai/deployments/{model}/chat/completions`

---

## Supported providers

Routero ships per-provider transformation for 100+ providers across 139 configurations. A sample:

| Provider | Notes |
|---|---|
| OpenAI | All models, all endpoints |
| Anthropic | Claude family, including Messages API |
| AWS Bedrock | All Bedrock models incl. Claude, Llama, Mistral |
| Google Vertex AI | Gemini, PaLM, embedding models |
| Google Gemini (direct) | `gemini-*` models |
| Azure OpenAI | All deployments, Azure AI Studio |
| Groq | Ultra-fast inference |
| Ollama | Local/self-hosted models |
| Cohere | Completions, embeddings, rerank |
| Mistral | All Mistral models |
| DeepSeek | DeepSeek-R1, V3 |
| Together AI | Open models |
| Fireworks AI | Fast open-model inference |
| xAI (Grok) | Grok family |
| Perplexity | Online LLMs |
| Databricks | DBRX, Llama on Databricks |
| AWS SageMaker | Custom endpoint support |
| IBM Watsonx | Enterprise LLMs |
| Snowflake | Cortex LLMs |
| vLLM / hosted_vllm | Self-hosted vLLM instances |
| Regional providers | Volcengine, DashScope, MiniMax, Moonshot, ZhipuAI, and more |

See `/models` for the full live list of models configured in your workspace.

---

## Model string formats

```python
# Smart alias — resolves to your configured policy
"smart/balanced"

# Provider-scoped
"openai/gpt-4o"
"anthropic/claude-sonnet-4-6-20250514"
"bedrock/anthropic.claude-sonnet-4-6-20250514-v1:0"
"azure/my-deployment-name"
"ollama/llama3.2"

# Bare name — Routero infers the provider
"gpt-4o"
"claude-sonnet-4-6"
```

---

## Streaming

All streaming endpoints use standard Server-Sent Events (SSE). Routero passes chunks through with zero buffering. Failover during a streaming response replays only the tail — the client receives one uninterrupted stream even if the primary provider fails mid-response.

```python
stream = client.chat.completions.create(
    model="smart/balanced",
    messages=[{"role": "user", "content": "Hello!"}],
    stream=True,
)
for chunk in stream:
    print(chunk.choices[0].delta.content or "", end="")
```
