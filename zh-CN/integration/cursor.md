---
lang: zh-CN
page_id: integration/cursor
permalink: /integration/cursor.html
title: Cursor
parent: 接入
nav_order: 2
description: "将 Cursor 经由 Routero 路由，为你的 AI 编码助手实现治理、成本追踪与策略执行。"
---

# Cursor

将 Cursor 经由 Routero 路由，使你的 AI 编码助手纳入与生产应用相同的治理、成本追踪与策略执行体系——每一次补全都可归属、可预算、可记录。

**为什么要通过 Routero 路由 Cursor：**

- **成本可见性** —— 看到谁在使用哪些模型、成本几何、跨越哪些团队。
- **策略执行** —— 阻止未获批用于源代码的模型或供应商。
- **审计轨迹** —— 每一次编码助手调用的完整日志。
- **预算限额** —— 为单个开发者或团队在 AI 工具上的支出设置上限。
- **供应商回退** —— 即使某个供应商被限流，Cursor 仍保持可用。

---

## 1. 创建虚拟密钥

在仪表板中打开 **API Keys**，创建一个虚拟密钥作为 Cursor 的 API 密钥。将其限定到开发者所属团队、限制为已获批的模型，并可选地附加预算，以便单独归属支出。

---

## 2. 将 Cursor 指向 Routero

1. 打开 **Cursor Settings** → **Models** → **OpenAI API Key**。
2. 将你的 Routero 虚拟密钥粘贴为 API 密钥。
3. 将 **Base URL** 设置为 `https://api.routero.ai/v1`。
4. 选择你的模型——任何 Routero 支持的模型字符串均可使用，包括 `openai/gpt-5.5`。

从此刻起，Cursor 将经由 Routero 路由其所有的 LLM 调用。

---

## 相关内容

→ 关于 base URL、鉴权与 SDK 示例，参见 [API 调用]({% link zh-CN/integration/api-calling.md %})。
→ 关于 Anthropic 命令行，参见 [Claude Code]({% link zh-CN/integration/claude-code.md %})。
