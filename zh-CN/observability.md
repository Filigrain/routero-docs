---
lang: zh-CN
page_id: observability
permalink: /observability.html
title: 可观测性
nav_order: 7
has_children: true
description: "请求日志、用量分析与预算限额——观测每一个经由 Routero 的请求。"
---

# 可观测性

经由 Routero 的每个请求都会被记录、计费，并归属到具体的密钥、团队与组织。三个仪表板页面让你查看发生了什么、分析支出并控制成本：

- [日志]({% link zh-CN/observability/logs.md %}) —— 每个请求的状态、token、成本、延迟，以及（可选的）提示词与响应。
- [用量]({% link zh-CN/observability/usage.md %}) —— 按组织、团队、客户、模型与供应商的支出与请求分析。
- [预算限额]({% link zh-CN/observability/budget-limits.md %}) —— 为密钥、团队与组织设置支出与速率上限，并查看支出对限额的进度。
- [计费]({% link zh-CN/observability/billing.md %}) —— 你组织的余额、月度发票与交易流水。

{: .note }
将日志与指标导出到外部平台（Langfuse、Datadog、OpenTelemetry、Prometheus）属于平台级集成，由你的管理员配置——并非租户可自行设置的仪表板开关。
