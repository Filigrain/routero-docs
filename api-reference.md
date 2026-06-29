---
title: API Reference
nav_order: 8
description: "Interactive API reference for the Routero AI gateway, generated from the FastAPI OpenAPI spec."
---

# API Reference

The full Routero AI API is documented below via the auto-generated OpenAPI spec from the gateway. The spec covers both the **data plane** (inference endpoints) and the **management/control plane** (key, team, org, budget, guardrail, prompt, memory, and token-saving plan management).

{: .note }
**Base URL:** `https://api.routero.ai/v1`
**Authentication:** `Authorization: Bearer YOUR_ROUTERO_KEY` on all requests.

---

## Interactive reference

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
          primary: { main: '#33bc95' },
          text: { primary: '#e6e1e8', secondary: '#959396' },
          border: { dark: '#44434d', light: '#44434d' },
          http: {
            get: '#33bc95', post: '#6cc8ff', put: '#f7d12e', delete: '#f96e65',
          },
        },
        typography: {
          fontFamily: 'Inter, system-ui, sans-serif',
          headings: { fontFamily: 'Inter, system-ui, sans-serif' },
          code: {
            fontFamily: '"JetBrains Mono", "Fira Mono", monospace',
            color: '#33bc95',
            backgroundColor: '#0d1117',
          },
        },
        sidebar: { backgroundColor: '#201f23', textColor: '#e6e1e8' },
        rightPanel: { backgroundColor: '#1b1a1e', textColor: '#e6e1e8' },
        schema: { nestedBackground: '#201f23' },
      },
      hideDownloadButton: false,
      expandResponses: '200',
      pathInMiddlePanel: false,
    },
    document.getElementById('redoc-container')
  )
</script>

---

## Key endpoint groups

### Inference (data plane) — `/v1/...`
| Endpoint | Description |
|---|---|
| `POST /chat/completions` | OpenAI-compatible chat completions (primary endpoint) |
| `POST /completions` | Legacy text completions |
| `POST /embeddings` | Text embeddings |
| `POST /images/generations` | Image generation |
| `POST /audio/speech` | Text-to-speech |
| `POST /audio/transcriptions` | Speech-to-text |
| `POST /rerank` | Reranking (Cohere-compatible) |
| `POST /batches` | Async batch processing |
| `GET /models` | List available models |
| `POST /v1/messages` | Anthropic Messages API compatibility |

### Management (control plane) — `/...`
| Resource | Prefix |
|---|---|
| API Keys | `/key/` |
| Organizations | `/organization/` |
| Teams | `/team/` |
| Users | `/user/` |
| Budgets | `/budget/` |
| Billing & Wallet | `/billing/` |
| Guardrails | `/guardrail/` |
| Prompts | `/prompts/` |
| Memory Sessions | `/memory/session/` |
| Token-Saving Plans | `/token-saving/plans/` |
| Models | `/model/` |
| Routing / Fallbacks | `/fallbacks/` |
| A2A Agents | `/v1/agents/` |
| MCP Servers | `/mcp/` |

For the complete spec including request/response schemas, see the interactive reference above or download the OpenAPI JSON directly from your instance at `/openapi.json`.
