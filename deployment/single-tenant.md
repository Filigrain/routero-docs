---
lang: en
page_id: deployment/single-tenant
title: Single-Tenant Cloud
parent: Deployment Options
nav_order: 2
description: "A dedicated Routero stack in your chosen region — physical isolation, managed by Routero."
---

# Single-Tenant Cloud

A fully isolated Routero stack provisioned in your chosen AWS region and account, operated by Routero. You get the same control plane as the managed cloud, with physical data isolation and no shared infrastructure.

{: .enterprise }
> Single-Tenant Cloud is available on the **Enterprise plan**. Contact your solutions engineer to scope and provision.

---

## What's different from Routero Cloud

| | Routero Cloud | Single-Tenant Cloud |
|---|---|---|
| AWS account | Routero's | Dedicated per-customer (or your own) |
| VPC | Shared | Dedicated |
| RDS | Shared (row-level isolation) | Dedicated instance |
| Redis | Shared | Dedicated |
| Data region | Singapore (ap-southeast-1) | Your choice |
| Ops | Routero | Routero |
| Custom domain | — | Possible (`api.yourco.com`) |

---

## Use cases

- **Regulated industries** — healthcare (HIPAA BAA), financial services, government — where data must reside in a specific region or account.
- **China data residency** — Routero operates a production-grade single-tenant stack in AWS China (Beijing, cn-north-1) for customers subject to PIPL. See [Data Residency & Regions]({% link deployment/data-residency.md %}).
- **Blast-radius isolation** — ensures a noisy-neighbour incident in the multi-tenant cloud cannot affect your workloads.
- **Custom integrations** — enterprise customers requiring specific VPC peering, private link, or internal DNS configurations.

---

## How provisioning works

1. Your solutions engineer scopes the region, instance sizing, retention, and compliance requirements.
2. Routero provisions the stack using the same Terraform reference architecture as the managed cloud (see [Reference Architecture]({% link deployment/reference-architecture.md %})).
3. You receive an API endpoint, dashboard URL, and initial admin credentials for your dedicated instance.
4. Routero operates, monitors, and upgrades the stack — you get the same Routero-managed experience with physical isolation.
