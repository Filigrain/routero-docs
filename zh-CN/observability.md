---
lang: zh-CN
page_id: observability
permalink: /observability.html
title: 可观测性
nav_order: 7
has_children: true
description: "对经由 Routero 的所有 LLM 流量进行日志、追踪、指标与 Webhook。"
---

# 可观测性

经由 Routero 的每个请求都会被记录、计费并可归因。网关可与你的团队已经在使用的日志、追踪和指标后端集成——OpenTelemetry、Datadog、Langfuse、Prometheus 等——并可通过 Webhook 将每个 LLM 事件转发到任意 HTTP 端点或聊天频道。

---

## 本章节页面

- [日志与追踪]({% link zh-CN/observability/logging-tracing.md %}) — OpenTelemetry、Datadog、Langfuse、Langsmith、Prometheus 等
- [指标与分析]({% link zh-CN/observability/metrics-analytics.md %}) — 按密钥、按团队、按组织的用量与支出仪表板
- [Webhooks]({% link zh-CN/observability/webhooks.md %}) — 将 LLM 请求日志转发到任意 HTTP 端点，并提供 Slack 和邮件告警
