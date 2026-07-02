---
lang: en
page_id: observability/logging-tracing
title: Logging & Tracing
parent: Observability
nav_order: 1
description: "Pluggable logging and tracing integrations: OpenTelemetry, Datadog, Langfuse, Prometheus, and more."
---

# Logging & Tracing

Every request through Routero fires success and failure callbacks to your configured logging backends. The pluggable integration layer connects to the logging, tracing, and metrics backends your team already runs — enable them in your proxy config or dashboard.

---

## Integration list

| Category | Integrations |
|---|---|
| **APM / Tracing** | OpenTelemetry, Datadog (DDTrace), Prometheus |
| **LLM Observability** | Langfuse, LangSmith, Arize Phoenix, Helicone, Braintrust, MLflow, Galileo, Opik, Lunary, W&B Weave, AgentOps |
| **Log storage** | S3 (any region), GCS Bucket, GCS Pub/Sub, SQS, DynamoDB |
| **Custom** | Generic HTTP webhook (forward to any datastore or SIEM) |
| **Alerting** | Slack, PagerDuty, email |
| **Analytics** | PostHog, CloudZero |
| **Logfire** | Pydantic Logfire |

---

## Enabling an integration

Set the integration in your proxy config:

```yaml
# config.yaml
litellm_settings:
  success_callback: ["langfuse", "prometheus"]
  failure_callback: ["slack", "datadog"]

# Langfuse
langfuse_public_key: os.environ/LANGFUSE_PUBLIC_KEY
langfuse_secret_key: os.environ/LANGFUSE_SECRET_KEY
langfuse_host: https://cloud.langfuse.com

# Slack alerts
alerting: ["slack"]
alerting_threshold: 30  # alert if a request takes longer than 30s
SLACK_WEBHOOK_URL: os.environ/SLACK_WEBHOOK_URL
```

Or enable integrations in the dashboard under **Settings → Integrations**.

---

## What gets logged

Every success callback receives:
- Model, provider, deployment name
- Input/output token counts
- Cost (USD)
- Latency (time to first token, total latency)
- Routing decision (which provider was chosen, fallback count)
- User key, team, org, customer IDs
- Request ID for correlation

{: .note }
**Prompt and response content is not sent to logging integrations by default.** Input/output logging must be explicitly enabled per workspace and is gated by your data-handling policy. → [Data Handling & Privacy]({% link security-trust/data-privacy.md %})
