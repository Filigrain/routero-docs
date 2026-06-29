---
lang: zh-CN
page_id: guides
permalink: /guides.html
title: 指南
nav_order: 10
has_children: true
description: "面向企业落地的任务导向操作手册：故障转移链、护栏、多团队治理等。"
---

# 指南

针对常见企业场景的任务导向演练。每篇指南均自成一体——按照其步骤即可实现特定的生产环境成果。

---

## 本章节页面

- [企业快速开始]({% link zh-CN/guides/enterprise-quickstart.md %}) — 配置工作区、设置策略、添加预算，并路由你的第一个生产环境请求
- [接入 Cursor / Claude Code]({% link zh-CN/guides/add-to-cursor.md %}) — 将你的 AI 编码助手经由 Routero 进行治理与成本追踪
- [框架集成]({% link zh-CN/guides/framework-integrations.md %}) — LangChain、Vercel AI SDK、LlamaIndex、PydanticAI 等
- [治理多团队工作区]({% link zh-CN/guides/multi-team-workspace.md %}) — 设置组织、团队、RBAC 角色和按团队预算
- [三供应商故障转移链]({% link zh-CN/guides/failover-chain.md %}) — 配置具有弹性的 OpenAI → Anthropic → Bedrock 回退
- [面向受监管团队的 PII 护栏]({% link zh-CN/guides/pii-guardrails.md %}) — 在提示词到达模型之前，基于 Presidio 进行 PII 脱敏
- [用 Token 节省降低成本]({% link zh-CN/guides/token-saving-guide.md %}) — 为高并发端点配置压缩 + 语义缓存
- [为你的应用赋予长期记忆]({% link zh-CN/guides/long-term-memory.md %}) — 使用 Mem0 记忆会话，自动检索与存储
