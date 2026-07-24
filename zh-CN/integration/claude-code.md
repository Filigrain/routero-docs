---
lang: zh-CN
page_id: integration/claude-code
permalink: /integration/claude-code.html
title: Claude Code
parent: 接入
nav_order: 3
description: "将 Claude Code 命令行接入 Routero——base URL、鉴权令牌与模型槽位映射，支持环境变量或 settings.json。"
---

# Claude Code

将 **Claude Code** 命令行（Anthropic 的 `claude`）接入 Routero，让它的调用经由你的网关——可归属、可预算、可记录，与生产流量统一管理。

Claude Code 使用 **Anthropic Messages API**，并内置三个模型槽位（haiku、sonnet、opus）。接入需要三样东西：**base URL**、**鉴权令牌**，以及把这些槽位**映射**到 Routero 提供的模型。

{: .note }
为什么要映射槽位？Claude Code 默认使用 Anthropic 模型名（`claude-sonnet-*`、`claude-opus-*`……）。把这些槽位指向 Routero 提供的模型名，每次请求才能正确经由你的网关路由。

---

## 必须设置的内容

| 设置项 | 值 |
|---|---|
| `ANTHROPIC_BASE_URL` | `https://api.routero.ai` |
| `ANTHROPIC_AUTH_TOKEN` | 一个 Routero 虚拟密钥（以 `Authorization: Bearer` 发送） |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | 用于轻量 / 后台任务的 Routero 模型 |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | 用于主会话的 Routero 模型 |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | 用于重度推理的 Routero 模型 |

请使用 `ANTHROPIC_AUTH_TOKEN`（Bearer），而不是 `ANTHROPIC_API_KEY`——Routero 虚拟密钥是 Bearer 令牌，网关读取的正是这个请求头。

---

## 方式 A——settings.json（推荐）

编辑 `~/.claude/settings.json`，把这些值放进 `env` 块。配置随工具绑定，对每个会话生效：

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.routero.ai",
    "ANTHROPIC_AUTH_TOKEN": "YOUR_ROUTERO_KEY",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "openai/gpt-5.5",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "openai/gpt-5.5",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "openai/gpt-5.5"
  }
}
```

## 方式 B——环境变量

在 shell（`~/.zshrc`、`~/.bashrc`）中 export 同样的值，然后运行 `claude`：

```bash
export ANTHROPIC_BASE_URL="https://api.routero.ai"
export ANTHROPIC_AUTH_TOKEN="YOUR_ROUTERO_KEY"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="openai/gpt-5.5"
export ANTHROPIC_DEFAULT_SONNET_MODEL="openai/gpt-5.5"
export ANTHROPIC_DEFAULT_OPUS_MODEL="openai/gpt-5.5"
```

{: .note }
你可以混搭模型——例如把重度的 `opus` 槽位映射到强推理模型，把 `haiku` 映射到便宜快速的模型。Routero 提供的任意模型字符串均可使用，包括 `openai/gpt-5.5` 或具体的供应商模型。

---

## 为每位开发者创建密钥

在仪表板的 **API Keys** 中为每位开发者创建一个虚拟密钥——限定到其团队、限制为已获批的模型，并可选附加预算。这样每位开发者的 Claude Code 流量都可单独归属。

---

## 相关内容

→ 关于 base URL 与鉴权模型，参见 [API 调用]({% link zh-CN/integration/api-calling.md %})。
→ 其他 agent，参见 [Codex]({% link zh-CN/integration/codex.md %})与 [Cursor]({% link zh-CN/integration/cursor.md %})。
