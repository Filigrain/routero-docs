---
title: Cost Tracking & Billing
parent: Core Gateway
nav_order: 8
description: "Per-request cost pipeline, the prepaid wallet, invoices, and spend analytics."
---

# Cost Tracking & Billing

Every request through Routero is costed in real time. Spend is attributed to the right key, team, org, and customer — with a resolution of $0.0001 per token across all providers.

---

## The spend pipeline

```
Provider response received
  → Token counts extracted from response
  → Cost calculated (model price × token counts)
  → Cost attached to response metadata / headers
  → Spend increment queued in Redis
  → Coworker service drains Redis → Postgres atomically
  → Available in dashboard and API within ~5 minutes
```

The coworker service uses Redis-based leader election, so spend is persisted exactly once even in multi-replica deployments.

---

## Billing modes

Routero supports two billing approaches, mixable per workspace:

**Routero-managed keys** — Routero holds your provider API keys. Provider costs are billed to Routero and passed through to your invoice at provider list price, with zero markup. You receive one consolidated monthly invoice.

**BYOK (Bring Your Own Keys)** — you hold provider contracts directly. Provider invoices go to you unchanged. You pay Routero only for the control-plane subscription.

→ Pricing details at [routero.ai/pricing](https://routero.ai/pricing.html).

---

## Prepaid wallet

The wallet feature (Routero-managed keys) lets your workspace maintain a prepaid balance:

```bash
# Top up the wallet
POST /billing/wallet/topup
{ "amount": 1000.00, "currency": "USD" }

# View balance and transactions
GET /billing/wallet
GET /billing/transactions
GET /billing/invoices
GET /billing/invoices/{month}
```

---

## Spend analytics

| Endpoint | Description |
|---|---|
| `GET /billing/daily-spend` | Day-by-day spend breakdown |
| `GET /billing/spend-trend` | Trend over a date range |
| `GET /billing/overview` | Summary: balance, MTD spend, projected |
| `GET /team/daily/activity` | Per-team token and cost breakdown |
| `GET /user/daily/activity` | Per-user breakdown |
| `GET /customer/daily/activity` | Per-customer breakdown |

---

## Chargeback exports

| Format | How |
|---|---|
| Dashboard table | Real-time, filterable by date, team, model |
| CSV | Monthly download from dashboard |
| REST API | Pull programmatically via `/billing/daily-spend` |
| Snowflake / BigQuery | Hourly sync (Enterprise) |
| NetSuite / Coupa | Push integration (Enterprise) |
