---
lang: en
page_id: core-gateway/budgets
title: Budgets & Spend Guards
parent: Core Gateway
nav_order: 6
description: "Hard spend ceilings, soft alerts, and per-team chargeback for every dollar of AI spend."
---

# Budgets & Spend Guards

Routero makes AI spend governable without making it slow. Budgets attach to any entity — workspace, team, user, API key, or route — and enforce three tiers of response when a ceiling is approached.

> *"Warn early. Throttle smart. Block only when you mean it."*

---

## Three enforcement tiers

| Tier | Trigger | Effect |
|---|---|---|
| **Warn** | 80% of ceiling | Slack/email alert to workspace owner; traffic unaffected |
| **Throttle** | 100% of ceiling | Auto-swap to a cost-optimised route; requests still succeed |
| **Block** | Hard cap reached | Returns HTTP 429 with structured error and `X-Routero-Budget-Reset-At` header |

All three tiers are configurable — you choose which to enable and at what thresholds.

---

## Budget scope

Budgets can be attached to:

| Entity | Example use case |
|---|---|
| **Workspace** | Total monthly ceiling across all teams |
| **Team** | Per-team chargeback with independent limits |
| **User / API key** | Per-developer or per-application limit |
| **Route** | Limit spend on a specific model group |
| **Customer** | Per-end-user spend cap in multi-tenant SaaS |

One workspace can have multiple overlapping budgets. The most restrictive applicable budget wins.

---

## Creating a budget

Via the API:

```bash
curl -X POST https://api.routero.ai/budget/new \
  -H "Authorization: Bearer $ROUTERO_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "max_budget": 500.00,
    "budget_duration": "1mo",
    "soft_budget": 400.00,
    "model_max_budget": {
      "openai/gpt-4o": 200.00
    }
  }'
```

Or from the dashboard under **Budgets** → **New Budget**.

---

## Chargeback and cost attribution

Every request writes a spend event with full attribution: workspace, team, user key, route, model, provider, token counts, and cost in USD. Attribution latency: under 5 minutes from request completion to ledger entry.

Export options:
- **Dashboard** — real-time spend dashboard with team-level breakdown
- **CSV** — monthly export per workspace
- **REST API** — `/billing/daily-spend`, `/billing/spend-trend`, `/billing/transactions`
- **Data warehouse** — Snowflake or BigQuery hourly sync
- **ERP push** — NetSuite or Coupa integration

→ [Cost Tracking & Billing]({% link core-gateway/cost-tracking.md %}) for the full spend pipeline.
