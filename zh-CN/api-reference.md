---
lang: zh-CN
page_id: api-reference
permalink: /api-reference.html
title: API 参考
nav_order: 8
description: "Routero AI 网关的交互式 API 参考，由 FastAPI OpenAPI 规范自动生成。"
---

# API 参考

下方通过网关自动生成的 OpenAPI 规范完整记录了 Routero AI API。该规范涵盖**数据平面**（推理端点）和**管理/控制平面**（密钥、团队、组织、预算、护栏、提示词、记忆和 Token 节省方案管理）。

{: .note }
**Base URL：** `https://api.routero.ai/v1`
**身份验证：** 所有请求均需携带 `Authorization: Bearer YOUR_ROUTERO_KEY`。

---

## 交互式参考

<div id="redoc-container"></div>

<script src="https://cdn.jsdelivr.net/npm/redoc@latest/bundles/redoc.standalone.js"></script>
<script>
  Redoc.init(
    // Spec is bundled at assets/openapi.json (static file, updated by CI).
    // To refresh: curl https://api.routero.ai/openapi.json > assets/openapi.json
    '{{ "/assets/openapi.json" | relative_url }}',
    {
      theme: {
        colors: {
          primary: { main: '#2fb68f' },
          http: {
            get: '#2fb68f', post: '#3b82f6', put: '#f59e0b', delete: '#ef4444',
          },
        },
        typography: {
          fontFamily: 'Inter, system-ui, sans-serif',
          headings: { fontFamily: 'Inter, system-ui, sans-serif' },
          code: { fontFamily: '"JetBrains Mono", "Fira Mono", monospace' },
        },
        sidebar: { backgroundColor: '#f6f8fa' },
      },
      hideDownloadButton: false,
      expandResponses: '200',
      pathInMiddlePanel: false,
    },
    document.getElementById('redoc-container')
  )
</script>

---

## 主要端点分组

### 推理（数据平面）— `/v1/...`
| 端点 | 说明 |
|---|---|
| `POST /chat/completions` | OpenAI 兼容的对话补全（主要端点） |
| `POST /completions` | 旧版文本补全 |
| `POST /embeddings` | 文本嵌入 |
| `POST /images/generations` | 图像生成 |
| `POST /audio/speech` | 文本转语音 |
| `POST /audio/transcriptions` | 语音转文本 |
| `POST /rerank` | 重排序（Cohere 兼容） |
| `POST /batches` | 异步批处理 |
| `GET /models` | 列出可用模型 |
| `POST /v1/messages` | Anthropic Messages API 兼容 |

### 管理（控制平面）— `/...`
| 资源 | 前缀 |
|---|---|
| API 密钥 | `/key/` |
| 组织 | `/organization/` |
| 团队 | `/team/` |
| 用户 | `/user/` |
| 预算 | `/budget/` |
| 计费与钱包 | `/billing/` |
| 护栏 | `/guardrail/` |
| 提示词 | `/prompts/` |
| 记忆会话 | `/memory/session/` |
| Token 节省方案 | `/token-saving/plans/` |
| 模型 | `/model/` |
| 路由 / 回退 | `/fallbacks/` |
| A2A 智能体 | `/v1/agents/` |
| MCP 服务器 | `/mcp/` |

如需包含请求/响应 schema 的完整规范，请参阅上方的交互式参考，或直接从你的实例 `/openapi.json` 下载 OpenAPI JSON。
