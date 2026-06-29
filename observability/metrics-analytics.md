---
lang: en
page_id: observability/metrics-analytics
title: Metrics & Analytics
parent: Observability
nav_order: 2
description: "Usage and spend analytics: per-key, per-team, per-org dashboards and API."
---

# Metrics & Analytics

Routero's built-in analytics give every stakeholder the view they need — developers see their key's usage, teams see their spend, admins see the full workspace.

---

## Dashboard

The Routero admin dashboard ([platform.routero.ai](https://platform.routero.ai)) provides:

- **Usage overview** — total requests, tokens, cost, and latency trends (1h / 24h / 7d / 30d)
- **Model breakdown** — requests and cost by model and provider
- **Team breakdown** — per-team spend with budget remaining indicators
- **Key activity** — per-key request counts and cost
- **Routing decisions** — provider distribution, fallback frequency, error rates
- **Budget alerts** — active spend warnings and blocks

---

## Analytics API

Pull usage data programmatically:

```bash
# Org-level daily spend
GET /billing/daily-spend?start_date=2026-06-01&end_date=2026-06-30

# Team activity
GET /team/daily/activity?team_id=data-science&start_date=2026-06-01

# User activity
GET /user/daily/activity?user_id=alice@company.com

# Per-key spend
GET /key/info?key_hash=sk-...
```

---

## Prometheus metrics

When Prometheus is enabled (in Docker Compose or as an ECS task), Routero exposes a `/metrics` endpoint with:

- `litellm_request_total` — request count by model, provider, status
- `litellm_request_duration_seconds` — latency histograms
- `litellm_tokens_total` — input/output token counts
- `litellm_cost_total` — spend in USD

Scrape config:
```yaml
scrape_configs:
  - job_name: routero
    static_configs:
      - targets: ["routero-proxy:4000"]
    metrics_path: /metrics
```
