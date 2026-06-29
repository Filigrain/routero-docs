---
title: SIEM & Audit Export
parent: Observability
nav_order: 3
description: "Stream the immutable Routero audit log to Kafka, S3, or your SIEM."
---

# SIEM & Audit Export

The Routero audit log is immutable, append-only, and cryptographically chained. Stream it to your SIEM in real time or export it on a schedule for compliance archival.

---

## Export formats

| Method | Latency | Use case |
|---|---|---|
| **Webhook** | Near-real-time | SIEM ingestion (Splunk, Elastic, etc.) |
| **Kafka** | Near-real-time | High-volume streaming pipelines |
| **S3 drop** | Hourly | Compliance archival, Snowflake/BigQuery ingestion |
| **Dashboard download** | On-demand | Ad-hoc review, eDiscovery |

---

## Webhook configuration

```bash
curl -X POST https://api.routero.ai/config/update \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{
    "general_settings": {
      "alerting": ["webhook"],
      "alerting_webhook_url": "https://siem.yourcompany.com/ingest/routero"
    }
  }'
```

Events are POSTed as JSON with an `X-Routero-Signature` header (HMAC-SHA256) for authenticity verification.

---

## Audit event schema

```json
{
  "event_id": "evt_01jz...",
  "event_type": "request.routed",
  "timestamp": "2026-06-29T10:00:00.123Z",
  "workspace_id": "ws_...",
  "org_id": "org_...",
  "team_id": "team_...",
  "user_key_hash": "sk_hash_...",
  "model": "openai/gpt-4o",
  "provider": "openai",
  "tokens_input": 512,
  "tokens_output": 128,
  "cost_usd": 0.0043,
  "latency_ms": 1240,
  "guardrail_id": "pii-redact-prod",
  "guardrail_violations": [],
  "fallback_count": 0,
  "policy_version": 18,
  "previous_event_hash": "sha256:abc123..."
}
```

The `previous_event_hash` field chains events — any tampering with a prior record breaks the chain.

---

## Retention

- **Default:** 365 days
- **Enterprise:** Configurable up to 7 years
- **Self-hosted:** Retention is controlled by your own RDS/S3 lifecycle policies

→ [Audit Log Reference]({% link security-trust/audit-log.md %}) for the full event type catalogue.
