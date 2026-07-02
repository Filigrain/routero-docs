---
lang: en
page_id: core-gateway/multi-tenancy
title: Multi-Tenancy
parent: Core Gateway
nav_order: 7
description: "Orgs, teams, users, and customers — Routero's hierarchical tenancy model."
---

# Multi-Tenancy

Routero AI organises access, spend, and model permissions in a four-level hierarchy. Each level can have its own budgets, rate limits, and role assignments.

```
Organization (Workspace)
  └── Teams
        └── Users (internal)
              └── Customers (end-users / external)
```

---

## Organizations (Workspaces)

The top-level isolation boundary. Each organization has:
- Its own set of models and provider configurations
- Independent budgets, rate limits, and spend tracking
- Separate audit logs
- Admin-managed membership (invitation-based; no self-signup)

In Routero Cloud, an organization maps to your company. In Private Deployments or Single-Tenant Cloud, you can create multiple organizations for different business units, subsidiaries, or customer-tenants.

---

## Teams

Subdivisions within an organization. Teams are the primary unit of chargeback and access control:
- Each team has an independent budget and rate limit
- Team members inherit team-level model access
- Team spend rolls up to the organization dashboard
- RBAC role assignments are team-scoped

```bash
# Create a team
curl -X POST https://api.routero.ai/team/new \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{"team_alias": "data-science", "max_budget": 2000, "budget_duration": "1mo"}'
```

---

## Users

Internal users (employees) have individual identities with:
- Personal API keys (optionally) alongside team keys
- Role assignments (Admin, Developer, Auditor, Finance, or Custom)
- Per-user spend tracking and daily activity reports
- Created and managed by admins (invitation-based)

---

## Customers (End-Users)

For teams building multi-tenant SaaS products on Routero, the `customer` entity represents your end-users:
- Attach a `customer_id` to any request to track per-customer spend
- Set per-customer budgets and rate limits
- View per-customer daily activity via `/customer/daily/activity`
- Useful for enforcing fair-use limits in consumer-facing applications

```python
response = client.chat.completions.create(
    model="smart/balanced",
    messages=[...],
    extra_body={"user": "customer_alice_123"},  # track spend to this end-user
)
```

---

## Switching organizations

Users with access to multiple organizations switch context via `/user/switch_org`. The active organization is resolved from the `X-Organization-Id` header or the `organization_id` field in the request body — Management API calls use whichever is set; if neither is set, the key's default org is used.
