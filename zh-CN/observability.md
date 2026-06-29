---
lang: zh-CN
page_id: observability
permalink: /observability.html
title: 可观测性
nav_order: 7
has_children: true
description: "对经由 Routero 的所有 LLM 流量进行日志、追踪、指标、SIEM 导出与 Webhook。"
---

# 可观测性

经由 Routero 的每个请求都会被记录、计费并可归因。网关内置约 80 种用于日志、追踪和指标的集成，并提供可推送至任意 SIEM 的流式审计日志。

---

## 本章节页面

- [日志与追踪]({% link zh-CN/observability/logging-tracing.md %}) — OpenTelemetry、Datadog、Langfuse、Langsmith、Prometheus 等
- [指标与分析]({% link zh-CN/observability/metrics-analytics.md %}) — 按密钥、按团队、按组织的用量与支出仪表板
- [SIEM 与审计导出]({% link zh-CN/observability/siem-audit.md %}) — 将不可篡改的审计日志流式推送至 Kafka、S3 或 Webhook
- [Webhooks]({% link zh-CN/observability/webhooks.md %}) — 针对路由决策、预算告警和违规的实时事件通知
