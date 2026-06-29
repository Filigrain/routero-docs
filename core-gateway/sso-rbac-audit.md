---
title: SSO, RBAC & Audit
parent: Core Gateway
nav_order: 6
description: "SAML 2.0, SCIM, Cerbos fine-grained authorization, and the immutable audit log."
---

# SSO, RBAC & Audit

Routero answers the questions your security team is already asking: who can call which model, who did, which prompts touched PII, and are deprovisioned employees' keys still active.

> *"Bring your IdP, leave with the audit log."*

---

## Identity: SAML 2.0 + SCIM

**SAML 2.0 SSO** — Supported IdPs: Okta, Microsoft Entra (Azure AD), Google Workspace, Auth0, Ping Identity, and any standard SAML 2.0 IdP. JIT provisioning on first login.

**SCIM 2.0 auto-provisioning** — Sync users and groups from your IdP. Deprovisioning is automatic: when an employee is removed from the IdP group, their Routero access and associated virtual keys are revoked within seconds.

---

## Authorization: Cerbos RBAC + PBAC

Routero uses [Cerbos](https://cerbos.dev) as an externalized policy decision point. Every management and data-plane action is checked against a set of human-readable YAML policies before execution.

**Built-in RBAC roles:**

| Role | What they can do |
|---|---|
| **Admin** | Full workspace control — models, keys, teams, billing, policies |
| **Developer** | Create and use API keys; view spend for their own keys |
| **Auditor** | Read-only access to audit logs, spend reports, and key metadata |
| **Finance** | Read-only access to billing, spend, invoices, and chargeback reports |
| **Custom** | Enterprise-plan: define your own role with exact resource permissions |

Cerbos policies are version-controlled alongside the application. Policy changes are themselves audit events.

---

## Virtual API keys

Virtual keys are the primary auth primitive for LLM traffic. Each key:
- Scopes to a workspace, team, or individual user
- Carries an optional model allowlist (deny access to unapproved models)
- Has a configurable TTL (expiry)
- Can be IP-restricted (allowlist of CIDRs)
- Can be revoked instantly via the dashboard or `DELETE /key/delete`
- Never exposes the underlying provider API key to the caller

```bash
# Generate a scoped key
curl -X POST https://api.routero.ai/key/generate \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{
    "models": ["smart/balanced", "openai/gpt-4o"],
    "team_id": "engineering",
    "max_budget": 100,
    "duration": "30d"
  }'
```

---

## Immutable audit log

Every significant event in Routero is written to an immutable, append-only, cryptographically signed audit log. Events are chained (each record includes the hash of the previous) so tampering is detectable.

**Event types logged:**

| Category | Events |
|---|---|
| Inference | `request.routed`, `request.blocked`, `request.failed`, `request.guardrail_triggered` |
| Policy | `policy.evaluated`, `policy.changed` (v17 → v18), `policy.blocked` |
| Identity | `user.provisioned`, `user.deprovisioned`, `key.created`, `key.rotated`, `key.revoked` |
| Access | `login.success`, `login.failed`, `mfa.challenged` |
| Billing | `budget.threshold_reached`, `budget.exceeded`, `spend.debited` |

**Retention:** 365 days default; configurable to 7 years on Enterprise plans.

**Export:** Stream to your SIEM via webhook, Kafka, or hourly S3 drop. → [SIEM & Audit Export]({% link observability/siem-audit.md %})

---

## Compliance

| Certification | Status |
|---|---|
| SOC 2 Type II | Annual audit — report available on request |
| HIPAA BAA | Enterprise plan |
| ISO 27001 | In progress |
| GDPR DPA + SCCs | Available for EU customers |

→ [Compliance]({% link security-trust/compliance.md %})
