---
title: Policy Routing
parent: Core Gateway
nav_order: 4
description: "Declarative YAML routing rules — evaluated on identity, content, region, budget, schedule, and custom signals."
---

# Policy Routing

Policy routing lets you decide which model serves which request using declarative YAML rules — without changing application code. Policies live in version control, pass through your normal code review, and hot-reload in under 5 seconds.

> *"Policy lives in your repo, not your runtime."*

---

## How it works

Every request runs the policy evaluator before provider selection. The evaluator scores 42 routing signals across six classes and picks the first matching rule:

| Signal class | Examples |
|---|---|
| **Identity & org** | Workspace, team, cost-centre header, RBAC role, plan tier |
| **Content classification** | PII detected, code content, language, token count, data-class header |
| **Region & residency** | Caller's declared region, EU-only, FedRAMP-pinned |
| **Budget state** | Remaining budget as % of ceiling |
| **Schedule** | Business hours, overnight, weekends |
| **Custom app signals** | Any HTTP header (`X-Routero-*` or your own) |

Evaluation overhead: **P50 ~8 ms, P99 <50 ms**.

---

## Policy YAML structure

```yaml
# finance-team.yaml
workspace: finance
version: 18

rules:
  # PII detected → route to internal redacted model
  - when:
      content.pii_detected: true
    route: internal/llama-4-maverick-redacted
    on_redaction_fail: block

  # EU users → EU-only providers (data residency)
  - when:
      identity.region: eu
    route: eu/anthropic-frankfurt
    residency: eu-only

  # Budget below 20% → downgrade + alert
  - when:
      budget.remaining_pct: { lt: 20 }
    route: smart/cheap
    alert:
      channel: slack
      message: "Finance workspace budget below 20%"

  # Default
  - route: smart/balanced
    audit:
      log_inputs: true
      retention_days: 365
```

---

## GitOps workflow

1. **Edit** — update the YAML file in your repository.
2. **Review** — open a PR. Your security team reviews the diff the same way they'd review any config change.
3. **Simulate** — Routero's policy simulator replays the last 24 hours of traffic against the new policy before you merge. Confirm no traffic shifts unexpectedly.
4. **Ship** — merge to main. The policy hot-reloads in <5 seconds. No application redeploy. No downtime.

---

## Policy versioning and audit

Every policy change is an immutable audit event: `policy.changed` (v17 → v18), including who made the change and when. The audit log provides a reproducible record of which policy version was active at any point in time.

→ [SSO, RBAC & Audit]({% link core-gateway/sso-rbac-audit.md %}) for the full audit log schema.

---

## Routing signals reference

For the complete list of 42 routing signals and their syntax, see the [API Reference]({% link api-reference.md %}) under **Policy**.
