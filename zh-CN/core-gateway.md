---
lang: zh-CN
page_id: core-gateway
permalink: /core-gateway.html
title: LLM 网关
nav_order: 4
has_children: true
description: "Routero AI 控制平面的四大构建模块：路由、策略、预算和审计。"
---

# LLM 网关

LLM 网关是 Routero AI 的统一 LLM 代理——一个位于 100+ 供应商之前的 OpenAI 兼容接口，内置四个可组合的治理原语。

---

## 本节页面

- [路由与负载均衡]({% link zh-CN/core-gateway/routing.md %}) —— 策略、模型组与 Router
- [自动路由]({% link zh-CN/core-gateway/auto-router.md %}) —— 基于消息内容的意图式模型选择
- [故障转移与回退]({% link zh-CN/core-gateway/failover.md %}) —— 多供应商故障转移链
- [策略]({% link zh-CN/core-gateway/policies.md %}) —— 将护栏、提示词、记忆与 Token 节省打包为命名策略
- [自带密钥（BYOK）]({% link zh-CN/core-gateway/byok.md %}) —— 使用你自己的供应商密钥；直接向供应商付费，Routero 仅收加价