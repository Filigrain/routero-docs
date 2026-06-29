---
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
| Audit log (metadata) | Compliance, billing, debugging | RDS Postgres | 365 days default, up to 7 years |
| Token counts and cost | Billing and chargeback | RDS Postgres | Indefinite (financial records) |
| Virtual API key hashes | Authentication | RDS Postgres | Until key is deleted |
| Provider API keys | Routing | RDS Postgres (encrypted) | Until removed by admin |
| User account data | Identity and access | RDS Postgres | Until user is deleted |
| Memory session data | Memory-as-a-Service (opt-in only) | Postgres + pgvector | Until session is deleted |
| Cache hit metadata | Performance analytics | Redis (TTL-limited) | Per cache TTL (default: 1 hour) |

Memory session content (Mem0/Cognee) is **opt-in only** — it is never created unless a caller passes a `memory_id` on a request.

---

## Audit log metadata

The audit log records the following per request:

```
event_id, event_type, timestamp, workspace_id, org_id, team_id,
user_key_hash (not the raw key), model, provider, tokens_input,
tokens_output, cost_usd, latency_ms, guardrail_id (if any),
guardrail_violation_types (not the blocked content), fallback_count,
policy_version
```

Guardrail violations record the **entity type** (e.g., `EMAIL_ADDRESS`) — not the original value.

---

## Data residency

| Deployment | Where audit data lives |
|---|---|
| Routero Cloud | AWS RDS, ap-southeast-1 (Singapore) |
| Single-Tenant Cloud | AWS RDS in your chosen region |
| Self-Hosted (AWS) | Your own RDS, your region |
| Self-Hosted (Docker) | Your own Postgres, wherever you run it |

For EU data residency, use Single-Tenant Cloud in `eu-west-1` or `eu-central-1`. → [Data Residency & Regions]({% link deployment/data-residency.md %})

---

## Data subject requests (GDPR)

**Right of access** — Routero holds audit metadata and account data, not prompt content. Access requests can be fulfilled from the audit log.

**Right to erasure** — For Routero Cloud, contact privacy@routero.ai. For self-hosted, execute deletions directly in your RDS. Memory session data is deleted via `DELETE /memory/session/{id}` — this is atomic across Postgres and the vector index.

**Right to portability** — Audit log data can be exported in JSON or CSV via the dashboard or API.

---

## Sub-processors (Routero Cloud)

| Sub-processor | Purpose | Location |
|---|---|---|
| AWS (Singapore) | Compute, RDS, Redis, S3 | ap-southeast-1 |
| Cloudflare | Edge, DDoS, TLS | Global CDN |
| Resend | Transactional email (alerts, billing notifications) | US |

Full sub-processor list available on request: privacy@routero.ai.
