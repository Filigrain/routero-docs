---
lang: zh-CN
page_id: integration/kimi-code
permalink: /integration/kimi-code.html
title: Kimi Code
parent: 接入
nav_order: 6
description: "将 Kimi Code 作为自定义 OpenAI 协议 provider 接入 Routero——base URL、API 密钥、模型 ID 与上下文大小。"
---

# Kimi Code

将 **Kimi Code** 接入 Routero，让它的模型调用经由你的网关——可归属、可预算、可记录——同时 Kimi Code 在本地继续负责仓库访问与文件修改。

Kimi Code 通过一个使用 OpenAI 协议的**自定义 provider** 接入。

---

## 必须设置的内容

在 Kimi Code 中打开 **Settings** → **Providers** → **Add provider** → **Custom**：

| 设置项 | 值 |
|---|---|
| 名称 | `Routero` |
| API 协议 | `OpenAI` |
| API Key | 一个 Routero 虚拟密钥 |
| Base URL | `{{ site.api_base_url }}/v1` |
| 模型 ID | Routero 提供的模型，例如 `deepseek/deepseek-v4-flash` |
| 最大上下文大小 | 该模型的上下文窗口，例如 `128000` |
| 显示名称 | 便于识别的任意名称，例如 `Routero DeepSeek V4 Flash` |

保存 provider 配置，然后在 Kimi Code 中选择该模型并发送一个测试提示词。

{: .note }
每个计划使用的模型都要单独添加一个 provider 条目——每个自定义 provider 只携带一个模型 ID。Routero 提供的任意模型字符串均可使用。

---

## 为每位开发者创建密钥

在仪表板的 **API Keys** 中为每位开发者创建一个虚拟密钥——限定到其团队、限制为已获批的模型，并可选附加预算。这样每位开发者的 Kimi Code 流量都可单独归属，请求也会出现在 **Logs** 中，表明经由 Routero 路由而非直连底层供应商。

---

## 网关策略对 Kimi Code 流量的作用

绑定到密钥的策略型 AI 能力对 Kimi Code 流量生效：

- **护栏** —— 按请求执行，包括对话中途的变更：把护栏从 **Monitor** 切换为 **Block** 后，下一个请求即被拦截，且 Kimi Code 会清晰地呈现 `400 Request blocked by content filter.`
- **Token Saving** —— 重复的提示词命中精确缓存；语义等价的改写命中语义缓存。
- **记忆** —— 通过密钥所属策略绑定的记忆会话可读可写：已存储的事实能在新对话中被检索；对话中陈述的新事实会被自动存储到 Routero。

---

## 相关内容

→ 关于 base URL 与鉴权模型，参见 [API 调用]({% link zh-CN/integration/api-calling.md %})。
→ 其他 agent，参见 [Claude Code]({% link zh-CN/integration/claude-code.md %})、[ZCode]({% link zh-CN/integration/zcode.md %})与 [Codex]({% link zh-CN/integration/codex.md %})。
