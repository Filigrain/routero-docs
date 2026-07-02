---
lang: en
page_id: observability
title: Observability
nav_order: 7
has_children: true
description: "Logging, tracing, metrics, and webhooks for all LLM traffic through Routero."
---

# Observability

Every request through Routero is logged, costed, and attributable. The gateway integrates with the logging, tracing, and metrics backends your team already runs — OpenTelemetry, Datadog, Langfuse, Prometheus, and more — and can forward every LLM event to any HTTP endpoint or chat channel via webhooks.

---

## Pages in this section

- [Logging & Tracing]({% link observability/logging-tracing.md %}) — OpenTelemetry, Datadog, Langfuse, Langsmith, Prometheus, and more
- [Metrics & Analytics]({% link observability/metrics-analytics.md %}) — per-key, per-team, per-org usage and spend dashboards
- [Webhooks]({% link observability/webhooks.md %}) — forward LLM request logs to any HTTP endpoint, plus Slack and email alerts
