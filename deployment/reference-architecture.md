---
title: Reference Architecture
parent: Deployment Options
nav_order: 5
nav_exclude: true
description: "The canonical Routero AI AWS topology: VPC, ALB, ECS Fargate, RDS, Redis, Cerbos, and the coworker service."
---

# Reference Architecture

The canonical production topology used by both Routero Cloud and Private Deployments. Understanding this architecture answers most security-review questions about where data lives and how traffic flows.

---

## Topology overview

**Traffic path:** Internet → Cloudflare → AWS ALB → ECS Fargate (private subnets, 3 AZs)

| Layer | Component | Role |
|---|---|---|
| **Edge** | Cloudflare | WAF, DDoS, global CDN, TLS termination, origin-pull mTLS |
| **Ingress** | AWS ALB (HTTPS/443) | Ingress locked to Cloudflare IP ranges only — no direct internet access |
| **Compute** | `routero-proxy` (port 4000) | Stateless gateway — routing, policy, audit; autoscales 1 → 10 tasks |
| **Compute** | `routero-coworker` (no ingress) | Background worker — spend sync, cache warm-up; Redis lease-based leader election |
| **Cache** | ElastiCache Redis | Rate-limit counters, key cache, spend event queue, response cache |
| **Database** | RDS Postgres — Multi-AZ | Three instances: `litellm` (keys/orgs/spend) · `mem0` · `cognee` |
| **AuthZ** | Cerbos (ECS, internal) | PBAC/RBAC policy engine — called by proxy for every authorization decision |
| **Memory (opt.)** | Neo4j · Qdrant · Redis-Stack | EFS-backed ECS tasks — enabled via `enable_memory_tier` |
| **CI/CD** | GitHub Actions (OIDC) | Keyless deploys — no stored AWS credentials |
| **Observability** | CloudWatch · Prometheus | Metrics, logs, alerts |

---

## Components

### Edge: Cloudflare + ALB
- Cloudflare proxies all public traffic (WAF, DDoS protection, global CDN, TLS termination at edge).
- The ALB security group **only accepts ingress from Cloudflare's published IP ranges** — direct internet access to the origin is blocked.
- Cloudflare authenticates to the ALB using origin-pull mTLS (`cloudflare-origin-pull-ca.pem`).
- Only the ALB has a public IP. All ECS tasks, RDS, and Redis sit in **private subnets** with egress via NAT Gateway.

### Compute: ECS Fargate
Two services run in private subnets across 3 AZs:

**`routero-proxy`** — the FastAPI gateway.
- Autoscales on `ALBRequestCountPerTarget` (1 task at rest → up to 10 under load).
- Health check `startPeriod: 180s` (images are 2–3 GB; first pull is slow).
- Deployment circuit breaker: automatic rollback if health checks fail after a new deploy.
- ECS Exec enabled for shell access (logged to CloudTrail) — no SSH bastion.

**`routero-coworker`** — spend-sync worker.
- `desired_count: 1` with Redis lease-based leader election (so safely runnable at N>1 without double-processing).
- Drains spend increments from Redis to RDS asynchronously — keeps the proxy's hot path fast.
- No inbound traffic; communicates only with Redis and RDS.

### Data: RDS + ElastiCache
- **Three Multi-AZ RDS instances** (`db.t3.small` by default, upgradeable): `litellm` (keys, teams, orgs, spend, models), `mem0` (Mem0 vector memory), `cognee` (Cognee knowledge graph).
- `pgvector` extension required in `mem0` and `cognee` — installed via one-time migration.
- **ElastiCache Redis** (`t4g.small`): rate-limit counters, key cache, spend event queue, routing cooldown state, optional response cache.
- Provider API keys are **stored encrypted in RDS**, not in Secrets Manager or environment variables.

### Authorization: Cerbos
- Runs as a separate ECS task in a private subnet.
- The proxy calls Cerbos for authorization decisions on management and data-plane actions.
- Policy bundle (`backend/cerbos/config/policies/`) defines roles and resources for UI menus, system settings, provider configs, and tenant resources (API keys, model access, team membership, wallet operations).
- The proxy degrades gracefully if Cerbos is temporarily unreachable.

### CI/CD: GitHub Actions (OIDC)
- All deployments are keyless — GitHub Actions authenticates to AWS via OIDC (no stored IAM credentials).
- Two pipelines: **Terraform** (infra) and **App** (image build + ECS rollout).
- Promotion path: `feature/*` → PR → `develop` (apply to UAT) → PR → `main` (apply to production, gated by reviewer approval).

---

## Security properties

| Property | Implementation |
|---|---|
| No public task IPs | Private subnets + NAT egress only |
| Origin-only access | ALB ingress locked to Cloudflare IP allowlist |
| No SSH | ECS Exec (SSM, CloudTrail-logged) instead |
| No long-lived AWS keys | OIDC for CI; task roles for runtime |
| Encrypted at rest | RDS encryption enabled; EFS encrypted |
| Provider keys protected | Stored in encrypted RDS, never in logs |
| Audit trail | CloudTrail for AWS actions; Routero audit log for all LLM requests |
