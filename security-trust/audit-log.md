---
lang: en
page_id: security-trust/audit-log
title: Audit Log Reference
parent: Security & Trust
nav_order: 4
description: "What the Routero admin audit log records, its schema, and how to query it."
---

# Audit Log Reference

Routero keeps an audit log of **administrative actions** so your security and compliance teams can answer "who changed what, and when?". When audit logging is enabled, every create, update, delete, block, and rotation of a key, user, model, team, organization, or budget is persisted as an audit record.

{: .note }
The audit log captures **administrative (control-plane) changes**, not individual LLM inference requests. Per-request usage and spend are tracked separately — see [Metrics & Analytics]({% link observability/metrics-analytics.md %}) and [Cost Tracking & Billing]({% link core-gateway/cost-tracking.md %}).

---

## What gets audited

An audit record is written whenever an admin mutates a managed resource:

| Resource | Audited actions |
|---|---|
| API keys | created · updated · deleted · blocked · rotated |
| Users | created · updated · deleted |
| Models | added · updated · removed |
| Teams | created · updated · member changes |
| Organizations | created · updated · member changes |
| Budgets | created · updated · deleted |

---

## Record schema

Each record stores the action, the target resource, who performed it, and the before/after state:

| Field | Description |
|---|---|
| `action` | `created` · `updated` · `deleted` · `blocked` · `rotated` |
| `table_name` | The resource type affected (e.g. `LiteLLM_VerificationToken`, `LiteLLM_UserTable`) |
| `object_id` | ID of the affected resource |
| `changed_by` | The user who performed the action |
| `changed_by_api_key` | The API key used to perform the action |
| `before_value` | JSON snapshot of the resource before the change |
| `updated_values` | JSON snapshot of the changed fields |
| `organization_id` | The organization the record belongs to |
| `updated_at` | Timestamp of the change |

Sensitive values — API key material in particular — are masked before they are written to `before_value` / `updated_values`.

---

## Querying the audit log

```bash
# List recent audit records (org-scoped)
curl https://api.routero.ai/audit?limit=100 \
  -H "Authorization: Bearer $ADMIN_KEY"

# Get a single record by id
curl https://api.routero.ai/audit/{id} \
  -H "Authorization: Bearer $ADMIN_KEY"
```

Both endpoints are **admin-only** and return only records from the caller's organization. The dashboard exposes the same data under **Audit Log**.

---

## Retention

Audit records live in the proxy's primary database (PostgreSQL). Retention is governed by your database backup and lifecycle policy — in Routero Cloud this is managed for you; in Private Deployments it is controlled by your own database.
