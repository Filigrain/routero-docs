---
lang: en
page_id: observability
title: Observability
nav_order: 7
has_children: true
description: "Logging, tracing, metrics, SIEM export, and webhooks for all LLM traffic through Routero."
---

# Observability

Every request through Routero is logged, costed, and attributable. The gateway ships ~80 built-in integrations for logging, tracing, and metrics — plus a streaming audit log you can pipe to any SIEM.

---

## Pages in this section

- [Logging & Tracing]({% link observability/logging-tracing.md %}) — OpenTelemetry, Datadog, Langfuse, Langsmith, Prometheus, and more
- [Metrics & Analytics]({% link observability/metrics-analytics.md %}) — per-key, per-team, per-org usage and spend dashboards
- [SIEM & Audit Export]({% link observability/siem-audit.md %}) — streaming the immutable audit log to Kafka, S3, or webhooks
- [Webhooks]({% link observability/webhooks.md %}) — real-time event notifications for routing decisions, budget alerts, and violations
