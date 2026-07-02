---
lang: en
page_id: observability/webhooks
title: Webhooks
parent: Observability
nav_order: 4
description: "Forward LLM request logs to any HTTP endpoint, plus Slack, email, and custom webhook alerts."
---

# Webhooks

Routero can forward LLM request logs to any HTTPS endpoint, and send operational alerts to Slack, email, or a custom webhook. Use these to land usage data in your own warehouse, feed a custom dashboard, or get notified when something needs attention.

---

## Forwarding request logs to an HTTP endpoint

The generic API callback integration sends each completed LLM request (success or failure) to a URL you choose — a lightweight way to pipe every request record into your own datastore without a dedicated integration. Configure the endpoint, optional headers, and payload format (`json_array`, `ndjson`, or `single`) from **Settings → Integrations** in the dashboard.

Each forwarded record carries the request's model, provider, token counts, cost, latency, and key/team/org attribution — the same fields described in [Logging & Tracing]({% link observability/logging-tracing.md %}).

{: .note }
Prompt and response content is **not** forwarded unless input/output logging is explicitly enabled. → [Data Handling & Privacy]({% link security-trust/data-privacy.md %})

---

## Alerting webhooks

For operational alerts — slow requests, deployment failures, budget thresholds — Routero posts to Slack, email, or any custom webhook URL:

```yaml
# config.yaml
litellm_settings:
  alerting: ["slack"]
  alerting_threshold: 30        # alert if a request takes longer than 30s
  SLACK_WEBHOOK_URL: os.environ/SLACK_WEBHOOK_URL
```

Use `alerting: ["webhook"]` with `alerting_webhook_url` to send alerts to a custom HTTPS endpoint. Configure recipients and thresholds from the dashboard under **Settings → Alerts**.

{: .note }
Webhook payloads are **not cryptographically signed**. Restrict your endpoint to Routero's egress and authenticate requests with a secret or token you control.
