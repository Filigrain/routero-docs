---
lang: zh-CN
page_id: observability/webhooks
permalink: /observability/webhooks.html
title: Webhooks
parent: 可观测性
nav_order: 4
description: "将 LLM 请求日志转发到任意 HTTP 端点，并提供 Slack、邮件及自定义 Webhook 告警。"
---

# Webhooks

Routero 可将 LLM 请求日志转发到任意 HTTPS 端点，并将运维告警发送到 Slack、邮件或自定义 Webhook。可用于将用量数据落到你自己的数据仓库、填充自定义仪表盘，或在需要关注时收到通知。

---

## 将请求日志转发到 HTTP 端点

通用 API 回调集成会将每个已完成的 LLM 请求（成功或失败）发送到你指定的 URL——这是一种轻量方式，无需专用集成即可将每条请求记录导入你自己的数据存储。可在仪表板的 **Settings → Integrations** 中配置端点、可选请求头以及负载格式（`json_array`、`ndjson` 或 `single`）。

每条转发记录都包含请求的模型、供应商、Token 计数、成本、延迟，以及密钥/团队/组织归属——与[日志与追踪]({% link zh-CN/observability/logging-tracing.md %})中描述的字段相同。

{: .note }
除非显式启用输入/输出日志，否则**不会**转发提示词与响应内容。

---

## 告警 Webhook

针对运维告警——慢请求、部署失败、预算阈值——Routero 会向 Slack、邮件或任意自定义 Webhook URL 发送通知：

```yaml
# config.yaml
litellm_settings:
  alerting: ["slack"]
  alerting_threshold: 30        # 当请求耗时超过 30 秒时告警
  SLACK_WEBHOOK_URL: os.environ/SLACK_WEBHOOK_URL
```

使用 `alerting: ["webhook"]` 配合 `alerting_webhook_url` 可将告警发送到自定义 HTTPS 端点。在仪表板的 **Settings → Alerts** 下配置接收方与阈值。

{: .note }
Webhook 负载**未经过加密签名**。请将你的端点限制为仅接受 Routero 的出站流量，并使用你掌控的密钥或令牌对请求进行认证。
