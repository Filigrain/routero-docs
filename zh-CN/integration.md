---
lang: zh-CN
page_id: integration
permalink: /integration.html
title: 接入
nav_order: 10
has_children: true
description: "接入 Routero——直接调用 API，或连接 Cursor、Claude Code 与 Codex。"
---

# 接入

接入 Routero。网关完全**兼容 OpenAI**（同时支持 Anthropic Messages API），因此接入主要是把工具指向正确的 base URL，并附带一个虚拟密钥。

- **OpenAI base URL：** `https://api.routero.ai/v1`
- **Anthropic base URL：** `https://api.routero.ai`

---

## 本节内容

- [API 调用]({% link zh-CN/integration/api-calling.md %}) —— base URL、鉴权与任意语言的请求示例。
- [Cursor]({% link zh-CN/integration/cursor.md %}) —— 将 Cursor 编辑器经由 Routero 路由。
- [Claude Code]({% link zh-CN/integration/claude-code.md %}) —— 将 Claude Code 命令行经由 Routero 路由（base URL + 模型槽位映射）。
- [Codex]({% link zh-CN/integration/codex.md %}) —— 通过自定义 model provider 将 Codex 命令行经由 Routero 路由。

{: .note }
其他兼容 OpenAI 的 agent——Cline、Continue、Aider、GitHub Copilot、Windsurf 等——方式相同：把工具的 base URL 指向 Routero，并使用一个虚拟密钥。参见 [API 调用]({% link zh-CN/integration/api-calling.md %})。

---

## 相关内容

→ 关于完整的端点能力与模型路由机制，参见[统一 API]({% link zh-CN/core-gateway/unified-api.md %})。
