---
lang: zh-CN
page_id: core-gateway
permalink: /core-gateway.html
title: 核心网关
nav_order: 4
has_children: true
description: "Routero AI 控制平面的四大构建模块：路由、策略、预算和审计。"
---

# 核心网关

核心网关是 Routero AI 的统一 LLM 代理——一个位于 100+ 供应商之前的 OpenAI 兼容接口，内置四个可组合的治理原语。

---

## 本节页面

- [统一 API]({% link zh-CN/core-gateway/unified-api.md %}) —— 每一个受支持的端点和供应商
- [路由与负载均衡]({% link zh-CN/core-gateway/routing.md %}) —— 策略、模型组与 Router
- [自动路由]({% link zh-CN/core-gateway/auto-router.md %}) —— 基于消息内容的意图式模型选择
- [故障转移与回退]({% link zh-CN/core-gateway/failover.md %}) —— 多供应商故障转移链
- [策略]({% link zh-CN/core-gateway/policies.md %}) —— 将护栏、提示词、记忆与 Token 节省打包为命名策略
- [预算与支出护栏]({% link zh-CN/core-gateway/budgets.md %}) —— 硬上限、软告警、FinOps 费用分摊
- [访问控制与审计]({% link zh-CN/core-gateway/sso-rbac-audit.md %}) —— 管理员邀请 · Cerbos · 审计日志
- [多租户]({% link zh-CN/core-gateway/multi-tenancy.md %}) —— 组织 · 团队 · 用户 · 客户
- [成本追踪与计费]({% link zh-CN/core-gateway/cost-tracking.md %}) —— 按请求的成本流水线、钱包、发票
