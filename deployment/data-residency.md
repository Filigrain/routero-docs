---
title: Data Residency & Regions
parent: Deployment Options
nav_order: 6
description: "Region options, data residency for regulated markets, and the AWS China (Beijing) deployment."
---

# Data Residency & Regions

Routero AI can run in multiple AWS regions. For most customers, Routero Cloud (Singapore) is sufficient. Regulated markets — particularly those with data-localisation requirements — should use Single-Tenant Cloud or Private Deployments with an appropriate region selection.

---

## Available regions

| Region | AWS Region | Available via |
|---|---|---|
| Singapore (default) | `ap-southeast-1` | Routero Cloud, Private Deployments |
| US East | `us-east-1` | Single-Tenant Cloud, Private Deployments |
| US West | `us-west-2` | Single-Tenant Cloud, Private Deployments |
| EU West | `eu-west-1` | Single-Tenant Cloud, Private Deployments |
| EU Central | `eu-central-1` | Single-Tenant Cloud, Private Deployments |
| APAC Southeast | `ap-southeast-1` / `ap-southeast-2` | Single-Tenant Cloud, Private Deployments |
| China Beijing | `cn-north-1` (Sinnet) | Single-Tenant Cloud only |

{: .note }
**Enterprise plan only:** Region selection for Single-Tenant Cloud is scoped during provisioning with your solutions engineer.

---

## AWS China (Beijing) deployment

Routero operates a dedicated production stack in AWS China Beijing (`cn-north-1`, Sinnet account) for customers subject to China's Personal Information Protection Law (PIPL) or those needing in-country data residency.

**Key differences from the global stack:**

- **Separate AWS account and state** — the China stack is fully isolated from the global infrastructure.
- **In-region UI** — the console is served from an ECS task in Beijing (not Cloudflare, which has limited presence in mainland China).
- **ECR image mirror** — container images are mirrored into a China ECR repository; no image pull traffic leaves the country.
- **Separate DNS root** — `cn.routero.ai` (UI) and `cn-platform.routero.ai` (API/platform).
- **ICP compliance** — the deployment requires ICP recordal (备案). An ICP-registered hostname migration is in progress; availability is subject to Sinnet port opening and ICP approval.
- **PIPL alignment** — data processed within the China stack does not traverse international network paths.

Contact your solutions engineer for China deployment availability and onboarding.

---

## What "data residency" means in Routero

| Data type | What Routero stores | Where |
|---|---|---|
| Prompt / response content | **Not stored** (processed in memory, discarded) | — |
| Audit log (metadata) | Token counts, model, cost, latency, user key, org, timestamp | Your region's RDS |
| Guardrail violations | Violation type and message (not the blocked content) | Your region's RDS |
| Provider API keys | Encrypted at rest in RDS | Your region's RDS |
| Memory session content | Vector embeddings + retrieved facts (if Memory-as-a-Service enabled) | Your region's Postgres + optional Neo4j |
| Spend and usage | Per-request cost, per-key/team/org aggregates | Your region's RDS |

{: .note }
In Private Deployments, all of the above lives in your own database. In Routero Cloud, it lives in Routero's RDS in Singapore. In Single-Tenant Cloud, it lives in your dedicated RDS in your chosen region.
