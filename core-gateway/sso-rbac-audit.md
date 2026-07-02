---
lang: en
page_id: core-gateway/sso-rbac-audit
title: Access Control & Audit
parent: Core Gateway
nav_order: 6
description: "Admin-invite access, Cerbos fine-grained authorization, scoped virtual keys, and the admin audit log."
---

# Access Control & Audit

Routero answers the questions your security team is already asking: who can call which model, who changed a key or a budget, and whether revoked keys are still active.

---

## Access & login

Access to a Routero workspace is **invitation-based**. There is no public self-signup.

- An **admin** creates users and teams from the dashboard (or the management API) and issues invitation links.
- Invitees set up their access from the invitation and **log in directly** with their own credentials.
- No third-party social or SSO login (Google, Microsoft, SAML, etc.) is wired into the product — identity is managed within Routero by your administrators.

{: .note }
Creating users and sending invitations requires an **admin** role. See [Authorization](#authorization-cerbos-rbac--pbac) below.

---

## Authorization: Cerbos RBAC + PBAC

Routero uses [Cerbos](https://cerbos.dev) as an externalized policy decision point. Every management and data-plane action is checked against a set of human-readable YAML policies before execution.

**Built-in roles:**

| Role | What they can do |
|---|---|
| **Proxy Admin** | Full workspace control — models, keys, teams, billing, policies, users |
| **Org Admin** | Admin over their organization — members, keys, models, and budgets scoped to the org |
| **Internal User** | Create and use their own API keys; view their own spend |
| **Internal User (view-only)** | Read-only access to spend and key metadata |
| **Proxy Admin (view-only)** | Read-only oversight of the entire workspace |

Roles are enforced both by the route gate and by Cerbos policy checks. Policy changes are themselves recorded as audit events.

---

## Virtual API keys

Virtual keys are the primary auth primitive for LLM traffic. Each key:

- Scopes to a workspace, team, or individual user
- Carries an optional model allowlist (deny access to unapproved models)
- Has a configurable TTL (expiry)
- Can be revoked instantly via the dashboard or `DELETE /key/delete`
- Never exposes the underlying provider API key to the caller

```bash
# Generate a scoped key (admin operation)
curl -X POST https://api.routero.ai/key/generate \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{
    "models": ["smart/balanced", "openai/gpt-4o"],
    "team_id": "engineering",
    "max_budget": 100,
    "duration": "30d"
  }'
```

{: .note }
`/key/generate` is an **admin** operation. Regular consumer keys are meant for inference calls only (`/chat/completions`, `/embeddings`, …), not for creating more keys.

---

## Audit log

Routero keeps an audit log of **administrative actions** — who changed what, and when. Every create, update, delete, block, and rotation of a key, user, model, team, or budget is recorded as an audit entry, with the acting user, the acting key, the affected resource, and the before/after values.

**What's recorded:**

| Category | Examples |
|---|---|
| Keys | created · updated · deleted · blocked · rotated |
| Users | created · updated · deleted |
| Models | added · updated · removed |
| Teams & Orgs | created · updated · member changes |
| Budgets | created · updated · deleted |

Query the audit log from the dashboard or the management API (`GET /audit`, `GET /audit/{id}`), scoped to your organization. Sensitive values (such as key material) are masked before storage. → [Audit Log Reference]({% link security-trust/audit-log.md %})

---

## Compliance

| Certification | Status |
|---|---|
| SOC 2 Type II | Annual audit — report available on request |
| HIPAA BAA | Enterprise plan |
| ISO 27001 | In progress |
| GDPR DPA + SCCs | Available for EU customers |

→ [Compliance]({% link security-trust/compliance.md %})
