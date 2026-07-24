---
lang: zh-CN
page_id: index
permalink: /
title: 简介
nav_order: 1
description: "Routero AI 是什么、企业为何选择它，以及如何使用本文档。"
---

# Routero AI 简介

{: .tagline }
**每一个 AI 模型。一个值得信赖的路由器。**

Routero AI 是一个**企业级 AI 控制平面**——一个统一网关，位于你的应用程序与每一家 AI 供应商之间。它为平台、安全和 FinOps 团队提供所需的治理层，让他们能够放心地交付 AI 功能，同时让开发者继续使用他们已经熟悉的 OpenAI SDK。

只需一行代码修改 `base_url`，即可获得 100+ 模型、智能路由、内置故障转移、能力策略、支出管控，以及完整的审计日志——并将数据严格保存在你的安全团队所要求的位置。

> *“我们用一份 Routero AI 配置，替换掉了四个网关和一段 600 行的故障转移补丁代码。”*

---

## 企业面临的难题

在生产环境中交付 AI，意味着在任何一条提示词触达用户之前，必须先跨过三道门槛：

1. **安全与合规**——哪些模型可以接触敏感数据？是谁批准的？上周二系统里都处理了什么？
2. **成本问责**——哪个团队花了多少钱？模型在深夜误跑一整晚，账单算谁的？
3. **运行可靠性**——当 GPT-4o 在凌晨 2 点触发限流时会发生什么？我们能否不重新部署就切换供应商？

Routero AI 正是为这三点而生——它提供一个你的安全团队可以审查、FinOps 团队可以据此报告、平台团队无需从零构建即可运维的控制平面。

{: .note }
Routero 对控制平面收费，而非对 token 收费。供应商成本按目录价零加价透传。每一笔费用都可问责，并与明确的运营用途挂钩。

---

## 一次请求，四个决策

每个请求都会经过一条确定性的、可审计的流水线：

```
你的应用
  → [认证与访问]         虚拟密钥 · 模型访问 · 预算护栏
  → [路由]               自动路由（可选）→ 策略挑选一个健康的部署
  → [能力]               策略注入护栏 · 提示词 · 记忆 · Token 节省
  → [计费与审计]         token/$ 原子化扣减 · 决策被记录
  → 供应商
```

每个决策都会被记录，并可在数月后复现。

---

## 四块基石

Routero 由四个可组合的原语构成。单独使用或全部使用皆可——它们彼此独立。

### 路由与故障转移
命名模型组、可插拔的路由策略，以及可选的**自动路由**——按意图为每条消息挑选最合适的模型。有序的供应商回退会在 5xx、限流或内容过滤触发时自动重试——支持流式，不丢任何数据块。

[→ 路由与负载均衡]({% link zh-CN/core-gateway/routing.md %}) · [自动路由]({% link zh-CN/core-gateway/auto-router.md %}) · [故障转移与回退]({% link zh-CN/core-gateway/failover.md %})

### 策略
将护栏、提示词、记忆与 Token 节省方案打包为一个命名策略，并绑定到密钥或模型。这些能力会在每个匹配的请求上自动激活——应用代码中无需传入逐请求的 ID。

[→ 策略]({% link zh-CN/core-gateway/policies.md %})

### 预算与支出护栏
为每一美元 AI 支出设置硬性上限、软性告警和按团队分摊。在 80% 时告警，100% 时自动限流，必要时直接阻断。财务收到一张合并发票；每个团队拿到归属到自己的明细。

[→ 预算与支出护栏]({% link zh-CN/core-gateway/budgets.md %})

### 访问控制与审计
管理员邀请访问 · Cerbos 细粒度授权 · 短时效的限定范围虚拟密钥 · 针对每次密钥、用户、模型和策略变更的审计日志。

[→ 访问控制与审计]({% link zh-CN/core-gateway/sso-rbac-audit.md %})

---

## AI 能力——生产级 AI 层

在路由与治理之外，Routero 还提供四项可选启用的能力，这些通常是生产级 AI 系统需要自行构建的。只需在任意请求上传入一个 ID 即可启用每一项——无需重构负载，也无需新增端点。

| 功能 | 作用 |
|---|---|
| [**Token 节省**]({% link zh-CN/advanced-features/token-saving.md %}) | 提示词压缩 + 精确与语义响应缓存——在不改动应用代码的前提下降低算力成本 |
| [**护栏**]({% link zh-CN/advanced-features/guardrails.md %}) | 内容过滤 · PII 脱敏（Presidio）· 密钥检测 · 工具允许/拒绝清单——集中管理、按组织强制执行 |
| [**提示词管理**]({% link zh-CN/advanced-features/prompt-management.md %}) | 集中式提示词注册表，支持不可变版本管理、Jinja2 模板、两层缓存与即时回滚 |
| [**记忆即服务**]({% link zh-CN/advanced-features/memory-service.md %}) | 通过 Mem0（向量）与 Cognee（知识图谱）提供长期记忆——按请求自动检索并注入 |

[→ AI 能力]({% link zh-CN/advanced-features.md %})

---

## 本文档面向谁

**平台与基础设施工程师**——搭建 AI 底层管道。
从[快速开始]({% link zh-CN/quickstart.md %})开始。

**安全与合规人员**——审查与批准。
从 [访问控制与审计]({% link zh-CN/core-gateway/sso-rbac-audit.md %})开始。

**FinOps 与工程管理者**——为账单负责。
从[预算与支出护栏]({% link zh-CN/core-gateway/budgets.md %})和[成本追踪与计费]({% link zh-CN/core-gateway/cost-tracking.md %})开始。

**开发者**——调用 API。
从[快速开始]({% link zh-CN/quickstart.md %})和[统一 API]({% link zh-CN/core-gateway/unified-api.md %})开始。
