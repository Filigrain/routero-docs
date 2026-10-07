---
lang: zh-CN
page_id: integration/zcode
permalink: /integration/zcode.html
title: ZCode
parent: 接入
nav_order: 5
description: "将 ZCode 编码智能体作为 OpenAI 兼容 provider 接入 Routero——base URL、API 密钥与模型列表。"
---

# ZCode

将 **ZCode** 编码智能体接入 Routero，让它的模型调用经由你的网关——可归属、可预算、可记录——同时 ZCode 在本地继续负责仓库访问与文件修改。

ZCode 通过一个自定义的 **OpenAI 兼容 provider** 接入，使用 Chat Completions API（`/chat/completions`）。

---

## 必须设置的内容

在 ZCode 中打开 **Settings** → **Model settings** → **Add provider** → **OpenAI**：

| 设置项 | 值 |
|---|---|
| Base URL | `{{ site.api_base_url }}/v1` |
| API 格式 | Chat completions（`/chat/completions`） |
| API key | 一个 Routero 虚拟密钥 |
| 模型列表 | 添加 Routero 提供的每个模型，例如 `deepseek/deepseek-v4-flash` |

然后在主对话框中把模型切换到刚添加的 provider/模型组合（例如 `OpenAI/deepseek/deepseek-v4-flash`），并发送一个测试提示词。

{: .note }
只有添加到 provider 模型列表中的模型才可选。把你的团队获批使用的每个模型字符串都添加进去——Routero 提供的任意模型均可使用。

---

## 为每位开发者创建密钥

在仪表板的 **API Keys** 中为每位开发者创建一个虚拟密钥——限定到其团队、限制为已获批的模型，并可选附加预算。这样每位开发者的 ZCode 流量都可单独归属，请求也会出现在 **Logs** 中，表明经由 Routero 路由而非直连底层供应商。

---

## 网关策略对 ZCode 流量的作用

绑定到密钥的策略型 AI 能力对 ZCode 流量生效：

- **提示词管理** —— 注入的指令被遵循。
- **护栏** —— 按请求执行。在 **Block** 与 **Monitor** 之间切换护栏对后续请求立即生效，无需重启对话；被拦截的请求表现为 `Request blocked by content filter.`
- **Token Saving** —— 精确缓存与语义缓存均生效。

---

## 相关内容

→ 关于 base URL 与鉴权模型，参见 [API 调用]({% link zh-CN/integration/api-calling.md %})。
→ 其他 agent，参见 [Claude Code]({% link zh-CN/integration/claude-code.md %})、[Kimi Code]({% link zh-CN/integration/kimi-code.md %})与 [Codex]({% link zh-CN/integration/codex.md %})。
