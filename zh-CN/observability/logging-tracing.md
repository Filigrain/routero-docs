---
lang: zh-CN
page_id: observability/logging-tracing
permalink: /observability/logging-tracing.html
title: 日志与追踪
parent: 可观测性
nav_order: 1
description: "可插拔的日志与追踪集成：OpenTelemetry、Datadog、Langfuse、Prometheus 等。"
---

# 日志与追踪

通过 Routero 的每个请求都会向你配置的日志后端触发成功与失败回调。可插拔的集成层可连接你的团队已经在使用的日志、追踪与指标后端——在你的代理配置或仪表盘中启用它们即可。

---

## 集成列表

| 类别 | 集成 |
|---|---|
| **APM / 追踪** | OpenTelemetry, Datadog (DDTrace), Prometheus |
| **LLM 可观测性** | Langfuse, LangSmith, Arize Phoenix, Helicone, Braintrust, MLflow, Galileo, Opik, Lunary, W&B Weave, AgentOps |
| **日志存储** | S3（任意地域）, GCS Bucket, GCS Pub/Sub, SQS, DynamoDB |
| **自定义** | 通用 HTTP Webhook（转发到任意数据存储或 SIEM） |
| **告警** | Slack, PagerDuty, email |
| **分析** | PostHog, CloudZero |
| **Logfire** | Pydantic Logfire |

---

## 启用集成

在你的代理配置中设置集成：

```yaml
# config.yaml
litellm_settings:
  success_callback: ["langfuse", "prometheus"]
  failure_callback: ["slack", "datadog"]

# Langfuse
langfuse_public_key: os.environ/LANGFUSE_PUBLIC_KEY
langfuse_secret_key: os.environ/LANGFUSE_SECRET_KEY
langfuse_host: https://cloud.langfuse.com

# Slack 告警
alerting: ["slack"]
alerting_threshold: 30  # 当请求耗时超过 30 秒时告警
SLACK_WEBHOOK_URL: os.environ/SLACK_WEBHOOK_URL
```

或在仪表盘中通过 **Settings → Integrations** 启用集成。

---

## 记录哪些内容

每个成功回调都会接收到：
- 模型、供应商、部署名称
- 输入/输出 Token 计数
- 成本（美元）
- 延迟（首个 Token 时间、总延迟）
- 路由决策（选择了哪个供应商、回退次数）
- 用户密钥、团队、组织、客户 ID
- 用于关联的请求 ID

{: .note }
**默认情况下，提示词与响应内容不会发送给日志集成。** 输入/输出日志必须按工作区显式启用，并受你的数据处理策略约束。
