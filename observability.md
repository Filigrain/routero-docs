---
lang: en
page_id: observability
title: Observability
nav_order: 7
has_children: true
description: "Request logs, usage analytics, and budget limits — observe every request through Routero."
---

# Observability

Every request through Routero is logged, costed, and attributable to a key, team, and organisation. Three dashboard pages let you inspect what happened, analyse spend, and cap costs:

- [Logs]({% link observability/logs.md %}) — every request, with status, tokens, cost, latency, and (optionally) the prompt and response.
- [Usage]({% link observability/usage.md %}) — spend and request analytics by organisation, team, customer, model, and provider.
- [Budget Limits]({% link observability/budget-limits.md %}) — set spend and rate caps on keys, teams, and organisations, and watch spend against them.
- [Billing]({% link observability/billing.md %}) — your organisation's balance, invoices, and transaction ledger.

{: .note }
Exporting logs and metrics to external platforms (Langfuse, Datadog, OpenTelemetry, Prometheus) is a platform-level integration configured by your administrator — not a per-tenant dashboard setting.
