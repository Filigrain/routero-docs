---
lang: en
page_id: guides/multi-team-workspace
title: Govern a Multi-Team Workspace
parent: Guides
nav_order: 4
description: "Set up orgs, teams, RBAC roles, per-team budgets, and model access controls for a multi-team enterprise deployment."
---

# Govern a Multi-Team Workspace

This guide is for the platform engineer or AI infrastructure lead setting up Routero for multiple internal teams. Goal: each team has its own key, budget, and model allowlist; the central admin has full visibility; revoking access is instant.

---

## Design pattern

```
Workspace (org)
  ├── Team: data-science    $2000/mo   → can use any model
  ├── Team: customer-ops    $500/mo    → can use smart/balanced only
  ├── Team: finance         $800/mo    → EU-residency required
  └── Team: engineering     $1500/mo   → any model, plus Cursor keys
```

---

## Step 1 — Create teams

```bash
# Create each team
for TEAM in "data-science:2000" "customer-ops:500" "finance:800" "engineering:1500"; do
  NAME="${TEAM%%:*}"; BUDGET="${TEAM##*:}"
  curl -X POST https://api.routero.ai/team/new \
    -H "Authorization: Bearer $ADMIN_KEY" \
    -d "{\"team_alias\": \"$NAME\", \"max_budget\": $BUDGET, \"budget_duration\": \"1mo\"}"
done
```

---

## Step 2 — Assign model allowlists per team

```bash
# customer-ops: lock to smart/balanced only
curl -X POST https://api.routero.ai/team/update \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{"team_id": "customer-ops", "models": ["smart/balanced"]}'

# finance: lock to EU-residency route
curl -X POST https://api.routero.ai/team/update \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{"team_id": "finance", "models": ["eu/balanced"]}'
```

---

## Step 3 — Set RBAC roles

```bash
# Grant the data-science lead Developer role
curl -X POST https://api.routero.ai/organization/member_permission_update \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{"user_email": "data-lead@company.com", "user_role": "internal_user", "team_id": "data-science"}'

# Grant finance controller Auditor role (read-only)
curl -X POST https://api.routero.ai/organization/member_permission_update \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{"user_email": "controller@company.com", "user_role": "internal_viewer"}'
```

---

## Step 4 — Invite team members

Access is invitation-based. From the dashboard under **Members**, invite each teammate by email and assign them to their team with the appropriate role. Members log in directly with the credentials they set up from the invitation — no SSO or IdP configuration required.

To remove someone's access, delete the user (or revoke their keys) from the dashboard; their keys are invalidated immediately.

---

## Step 5 — Generate team keys

Generate one key per team for shared use, and optionally per-person keys for developer environments:

```bash
curl -X POST https://api.routero.ai/key/generate \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{"team_id": "data-science", "key_alias": "ds-prod", "duration": "90d"}'
```

---

## Ongoing management

- **Monthly budget reset** — budgets reset automatically per `budget_duration`. No action required.
- **Budget alerts** — configure Slack alerts at `POST /config/update` with `alerting: ["slack"]` and your webhook URL.
- **Audit spend** — `GET /billing/daily-spend` for the org view; team leads can see their own via the dashboard.
- **Rotate a key** — `POST /key/regenerate` — old key is invalidated immediately.
- **Revoke a key** — `DELETE /key/delete` — instant.
