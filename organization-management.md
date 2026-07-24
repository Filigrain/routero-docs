---
lang: en
page_id: organization-management
title: Organization Management
nav_order: 6
has_children: true
description: "Managing your organization, teams, and members from the Routero dashboard — the tenant administrator's guide."
---

# Organization Management

Routero organises everything — access, spend, models, and audit — under your **organization** (your workspace). As an organization administrator you manage three things from the dashboard: the organization itself, the **teams** that subdivide it, and the **members** who belong to it.

```
Organization (your workspace)
  └── Teams        — budget, rate limits, and model access per group
        └── Members — the people in your organization
```

{: .note }
These pages describe the **tenant administrator** experience — what an organization admin sees and does for their own organization. Creating or deleting organizations, and platform-wide administration, are handled by your platform admin and are not covered here.

---

## Where you manage organizations

A tenant does not get a system-wide "Organizations" page. Instead, organization actions live behind the **user menu at the bottom of the sidebar**:

- **Switch Organization** — for users who belong to more than one organization, switch the workspace you are working in.
- **Manage Organization** — view your organization's details and manage its members and invitations.

→ [Organizations]({% link organization-management/organizations.md %})

---

## Teams and members

- **Teams** subdivide an organization for chargeback and access control. Each team carries its own budget, rate limits, and model list. → [Teams]({% link organization-management/teams.md %})
- **Members** are the people in your organization. Membership is invite-only — there is no self-signup. → [Members]({% link organization-management/members.md %})

---

## The active organization

The dashboard always tracks which organization you are working in — shown in the user menu at the bottom of the sidebar. Every page you open (Teams, Members, API Keys, Usage) is automatically scoped to that organization, so you only ever see your own data. Use **Switch Organization** to change context.

---

## Related

- For the conceptual tenancy model (organizations → teams → users → customers), see [Multi-Tenancy]({% link core-gateway/multi-tenancy.md %}).
- For team budgets and spend guards, see [Budgets & Spend Guards]({% link core-gateway/budgets.md %}).
- For roles and authorization, see [Access Control & Audit]({% link core-gateway/sso-rbac-audit.md %}).
