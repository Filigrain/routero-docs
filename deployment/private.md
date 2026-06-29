---
lang: en
page_id: deployment/private
title: Private Deployments
parent: Deployment Options
nav_order: 3
description: "Run the full Routero AI stack inside your own infrastructure — VPC isolation, full key control, air-gap ready."
---

# Private Deployments

Run the complete Routero AI control plane inside your own infrastructure. Your VPC, your compute, your data — with zero dependency on Routero-managed systems after the initial deployment.

---

## When to choose this

- **Data never leaves your boundary** — provider API keys, audit logs, and all operational data stay in infrastructure you own and control.
- **Compliance requires it** — FedRAMP, internal InfoSec mandates, customer contractual requirements, or air-gap environments that prohibit third-party-managed compute.
- **Full upgrade control** — you decide when to pull new images and roll forward; Routero Cloud's continuous deployment is not forced on you.
- **Custom network topology** — lock the stack inside a private VPC, restrict egress to specific provider endpoints, integrate with your internal PKI.

{: .enterprise }
> Private Deployments are available on the Enterprise plan. Contact your solutions engineer to receive the deployment package, image registry access, and onboarding support.

---

## What you get

The private deployment package ships the same stack that powers Routero Cloud:

| Component | What it does |
|---|---|
| **Gateway proxy** | OpenAI-compatible HTTP proxy — routing, policy, budgets, audit |
| **Coworker service** | Background worker for async tasks, cache warm-up, budget resets |
| **Cerbos** | PBAC/RBAC policy engine for fine-grained authorization |
| **Admin console** | Full dashboard — key management, teams, guardrails, prompt registry, memory sessions |

Your infrastructure provides the stateful layer: Postgres (primary datastore), Redis (caching and rate-limit counters), and optionally a vector store for Memory-as-a-Service.

---

## Supported environments

| Platform | Notes |
|---|---|
| **AWS** | Reference architecture using ECS Fargate, RDS, ElastiCache. Full HA topology with multi-AZ. |
| **Azure / GCP** | Equivalent managed container + managed Postgres + Redis services. Topology guide available on request. |
| **On-premises / air-gap** | Kubernetes (or equivalent container runtime) + self-managed Postgres + Redis. Images mirrored to your internal registry. |

→ [Reference Architecture]({% link deployment/reference-architecture.md %}) for the canonical AWS topology (VPC · ALB · ECS Fargate · RDS · Redis · Cerbos).

---

## Baseline infrastructure requirements

| Resource | Minimum | Recommended |
|---|---|---|
| Compute (proxy) | 2 vCPU / 4 GB RAM | Autoscaling group, 2+ replicas |
| Compute (coworker) | 1 vCPU / 2 GB RAM | 1–2 replicas |
| Postgres | db.t3.small · 20 GB | db.t3.medium · Multi-AZ |
| Redis | cache.t4g.small | cache.t4g.medium · Multi-AZ |
| Memory tier (optional) | Postgres + pgvector | + Neo4j for knowledge graph |

**Estimated baseline cost (AWS):** ~USD 300/month for a minimal production topology. Memory-tier services add ~USD 50–150/month.

---

## Upgrades

Routero publishes updated container images on a regular release cadence. You control when to pull and deploy — there is no forced upgrade. Release notes are available in your customer portal.

---

## Getting started

Contact [solutions@routero.ai](mailto:solutions@routero.ai) or your assigned solutions engineer. Onboarding includes:

1. Image registry access and deployment package
2. Architecture review call (infra sizing, network topology, compliance requirements)
3. Deployment walkthrough and initial configuration
4. Handoff to customer success for ongoing support

→ [Reference Architecture]({% link deployment/reference-architecture.md %}) · [Data Residency & Regions]({% link deployment/data-residency.md %})
