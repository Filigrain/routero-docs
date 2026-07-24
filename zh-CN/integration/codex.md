---
lang: zh-CN
page_id: integration/codex
permalink: /integration/codex.html
title: Codex
parent: 接入
nav_order: 4
description: "通过 config.toml 中的自定义 model provider，将 OpenAI Codex 命令行接入 Routero。"
---

# Codex

通过在配置中定义一个**自定义 model provider**，将 **Codex** 命令行（OpenAI 的 `codex`）接入 Routero。此后 Codex 的每次请求都经由你的网关。

Codex 支持两种线路格式——`chat`（`/chat/completions`）与 `responses`（`/responses`）。Routero 两者都支持；Codex 推荐使用 `responses`。

---

## 必须设置的内容

在 `~/.codex/config.toml` 中：

```toml
model_provider = "routero"
model = "openai/gpt-5.5"
preferred_auth_method = "apikey"

[model_providers.routero]
name = "routero"
base_url = "https://api.routero.ai/v1"
wire_api = "responses"
```

然后把你的 Routero 密钥作为 API 密钥提供：

```bash
export OPENAI_API_KEY="YOUR_ROUTERO_KEY"
```

| 设置项 | 值 / 含义 |
|---|---|
| `model_provider` | 下方 `[model_providers.*]` 块的名称（`routero`） |
| `model` | Routero 提供的任意模型（例如 `openai/gpt-5.5`） |
| `preferred_auth_method` | `apikey`——用 API 密钥鉴权，而非 ChatGPT 登录 |
| `base_url` | `https://api.routero.ai/v1` |
| `wire_api` | `responses`（推荐）或 `chat` |
| `OPENAI_API_KEY` | 你的 Routero 虚拟密钥（以 `Authorization: Bearer` 发送） |

{: .note }
`preferred_auth_method = "apikey"` 告诉 Codex 用 `OPENAI_API_KEY` 鉴权，而不是 ChatGPT 登录。请把该环境变量设为你的 **Routero 虚拟密钥**，而不是 OpenAI 密钥。

---

## 为每位开发者创建密钥

在仪表板的 **API Keys** 中为每位开发者创建一个虚拟密钥——限定到其团队、限制为已获批的模型，并可选附加预算。

---

## 相关内容

→ 关于 base URL 与鉴权模型，参见 [API 调用]({% link zh-CN/integration/api-calling.md %})。
→ 其他 agent，参见 [Claude Code]({% link zh-CN/integration/claude-code.md %})与 [Cursor]({% link zh-CN/integration/cursor.md %})。
