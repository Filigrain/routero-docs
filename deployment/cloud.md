---
title: Routero Cloud
parent: Deployment Options
nav_order: 1
description: "Routero-managed multi-tenant cloud — fastest path from API key to production."
---

# Routero Cloud

The managed multi-tenant option. Routero operates the infrastructure; you consume the gateway with virtual keys, orgs, and teams from day one.

**Live at:** `https://api.routero.ai/v1` (API) · `https://platform.routero.ai` (dashboard)

---

## What's included

- **Elastic scale** — ECS Fargate tasks autoscale on request count (up to 10 replicas); no capacity planning required.
- **Multi-AZ availability** — Deployed across 3 Availability Zones in AWS ap-southeast-1 (Singapore) behind a Cloudflare global edge with origin-pull mTLS.
- **SOC 2 Type II** — Annual certification. Ask your solutions engineer for the report.
- **Multi-tenant isolation** — Logical isolation via RBAC (Cerbos), org-scoped virtual keys, and dedicated Postgres row-level ownership. Your workspace's data and configurations are invisible to other tenants.
- **Automatic upgrades** — Routero deploys improvements continuously via a reviewed CI/CD pipeline (feature → develop → uat → production).
- **Status page** — Real-time status at [status.routero.ai](https://status.routero.ai); uptime monitors check `/health/liveliness` and `/health/readiness` every 30 seconds from multiple regions.

---

## Onboarding

1. Sign up at [platform.routero.ai](https://platform.routero.ai).
2. Create a workspace and generate a virtual API key.
3. Set `base_url = "https://api.routero.ai/v1"` in your application. Done.

First routed request in under 60 seconds.

---

## Data handling in Routero Cloud

| What | Where it goes |
|---|---|
| Prompt and response content | **Not stored** (metadata only — token counts, model, cost, latency) |
| Audit log metadata | AWS RDS Postgres, ap-southeast-1, 365-day default retention |
| Spend and usage data | Same RDS, org-scoped, exported to your dashboard |
| Provider API keys you add | Encrypted in RDS, never logged |

Routero never trains on, resells, or shares your prompts. → [Data Handling & Privacy]({% link security-trust/data-privacy.md %})

---

## Limitations vs. private deployments

- Data physically resides in Routero's AWS account (Singapore). If your compliance regime requires data sovereignty in a different jurisdiction, use [Single-Tenant Cloud]({% link deployment/single-tenant.md %}) or [Private Deployments]({% link deployment/private.md %}).
- You cannot customise infrastructure-level configuration (VPC CIDR, instance types, etc.).
