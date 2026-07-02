---
lang: en
page_id: security-trust/data-privacy
title: Data Handling & Privacy
parent: Security & Trust
nav_order: 3
description: "What Routero AI persists, for how long, and what it never stores."
---

# Data Handling & Privacy

This page documents exactly what data Routero processes, what it retains, and what it discards. Designed for security reviews, DPA negotiations, and GDPR/CCPA compliance.

---

## What Routero NEVER stores

| Data type | Policy |
|---|---|
| Prompt content | Never stored, never logged (discarded after routing) |
| Response content | Never stored, never logged |
| File contents (batch, file upload) | Temporarily buffered in memory during transfer; not persisted |
| Images, audio, video | Streamed through in memory; not persisted |

The gateway is a **transit system for AI requests**, not a content store. Prompt and response content passes through memory and is discarded.

---

## What Routero DOES store

| Data type | Purpose | Location | Retention |
|---|---|---|---|
| Audit log (admin actions) | Compliance, accountability | RDS Postgres | Governed by your DB retention policy |
| Token counts and cost | Billing and chargeback | RDS Postgres | Indefinite (financial records) |
| Virtual API key hashes | Authentication | RDS Postgres | Until key is deleted |
| Provider API keys | Routing | RDS Postgres (encrypted) | Until removed by admin |
| User account data | Identity and access | RDS Postgres | Until user is deleted |
| Memory session data | Memory-as-a-Service (opt-in only) | Postgres + pgvector | Until session is deleted |
| Cache hit metadata | Performance analytics | Redis (TTL-limited) | Per cache TTL (default: 1 hour) |

Memory session content (Mem0/Cognee) is **opt-in only** — it is never created unless a caller passes a `memory_id` on a request.

---

## Audit log

The audit log records **administrative actions** — not individual LLM requests. Each record captures the action (`created`, `updated`, `deleted`, `blocked`, `rotated`), the affected resource (key, user, model, team, org, budget), the acting user and key, and before/after values. Sensitive values (such as key material) are masked. Per-request usage and cost are tracked separately — see [Cost Tracking & Billing]({% link core-gateway/cost-tracking.md %}).

→ [Audit Log Reference]({% link security-trust/audit-log.md %})

---

## Data residency

| Deployment | Where audit data lives |
|---|---|
| Routero Cloud | AWS RDS, ap-southeast-1 (Singapore) |
| Single-Tenant Cloud | AWS RDS in your chosen region |
| Private Deployments | Your own database, your infrastructure, your region |

For EU data residency, use Single-Tenant Cloud in `eu-west-1` or `eu-central-1`. → [Data Residency & Regions]({% link deployment/data-residency.md %})

---

## Data subject requests (GDPR)

**Right of access** — Routero holds audit metadata and account data, not prompt content. Access requests can be fulfilled from the audit log.

**Right to erasure** — For Routero Cloud, contact privacy@routero.ai. For Private Deployments, execute deletions directly in your database. Memory session data is deleted via `DELETE /memory/session/{id}` — this is atomic across Postgres and the vector index.

**Right to portability** — Audit log data is available via the dashboard or the `GET /audit` API.

---

## Sub-processors (Routero Cloud)

| Sub-processor | Purpose | Location |
|---|---|---|
| AWS (Singapore) | Compute, RDS, Redis, S3 | ap-southeast-1 |
| Cloudflare | Edge, DDoS, TLS | Global CDN |
| Resend | Transactional email (alerts, billing notifications) | US |

Full sub-processor list available on request: privacy@routero.ai.
