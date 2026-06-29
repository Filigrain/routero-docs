---
title: Deployment Options
nav_order: 3
has_children: true
description: "Routero Cloud, Single-Tenant Cloud, Private Deployments, and Local — pick the trust boundary that satisfies your security team."
---

# Deployment Options

The same Routero AI control plane ships in four configurations. Your security team picks where data lives; your engineering team picks how much infrastructure they want to run.

{: .enterprise }
> **"Ship the AI your security team will approve."** Deployment flexibility — including in-VPC and China-region options — is a primary reason enterprises choose Routero over cloud-only alternatives.

---

## Choosing your trust boundary

| | Routero Cloud | Single-Tenant Cloud | Private Deployments | Local |
|---|---|---|---|---|
| **Data location** | Routero's AWS (Singapore) | Your chosen region, Routero-managed | Entirely your infrastructure | Your machine |
| **Isolation** | Logical (RBAC, virtual keys) | Physical (dedicated account & VPC) | Physical + network boundary | Fully local |
| **Ops burden** | None | None | Your team | Your team |
| **Setup time** | 60 seconds | Days (solutions engineer) | Hours–days | Minutes |
| **Compliance** | SOC 2 Type II | SOC 2 · HIPAA BAA · custom | Customer-controlled | N/A |
| **Custom domain** | `api.routero.ai` | `api.yourcompany.com` possible | Your own | `localhost` |
| **Best for** | POC → production teams | Regulated industries, data residency | Air-gap, VPC isolation, full control | Development, evaluation, CI |

---

## Pages in this section

- [Routero Cloud]({% link deployment/cloud.md %}) — managed multi-tenant, fastest path to production
- [Single-Tenant Cloud]({% link deployment/single-tenant.md %}) — dedicated region, physical isolation
- [Private Deployments]({% link deployment/private.md %}) — your VPC, your compute, your data; AWS, other cloud, or on-prem
- [Local Deployment]({% link deployment/local.md %}) — single machine for development, evaluation, or air-gapped environments
- [Reference Architecture]({% link deployment/reference-architecture.md %}) — the canonical AWS topology (VPC · ALB · ECS Fargate · RDS · Redis · Cerbos)
- [Data Residency & Regions]({% link deployment/data-residency.md %}) — region options including AWS China (Beijing)
