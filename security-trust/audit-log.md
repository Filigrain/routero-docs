---
lang: en
page_id: security-trust/audit-log
title: Audit Log Reference
parent: Security & Trust
nav_order: 4
description: "Complete event type catalogue, audit log schema, retention, and SIEM export reference."
---

# Audit Log Reference

The Routero audit log is an immutable, append-only, cryptographically chained record of every significant event in the system. Each record includes the hash of the previous record — tampering with any record breaks the chain.

---

## Event type catalogue

### Inference events
| Event type | Triggered when |
|---|---|
| `request.routed` | A request was successfully routed to a provider |
| `request.blocked` | A request was blocked (budget, guardrail, policy, or key invalid) |
| `request.failed` | Provider returned an error and all fallbacks exhausted |
| `request.guardrail_triggered` | A guardrail engine detected a violation (anonymise or block) |
| `request.cache_hit` | Response served from cache (Token Saving) |
| `request.compressed` | Prompt was compressed by Token Saving plan |
| `request.fallback_triggered` | Router fell back to a secondary provider |

### Policy events
| Event type | Triggered when |
|---|---|
| `policy.evaluated` | A routing policy rule was matched |
| `policy.changed` | A policy version was published (old → new) |
| `policy.blocked` | Policy rule blocked a request |

### Identity and access events
| Event type | Triggered when |
|---|---|
| `user.provisioned` | User was created (manual or SCIM) |
| `user.deprovisioned` | User was deactivated (SCIM sync or manual) |
| `key.created` | A virtual API key was generated |
| `key.rotated` | A virtual API key was regenerated |
| `key.revoked` | A virtual API key was deleted |
| `key.budget_exceeded` | A key's budget ceiling was reached |
| `login.success` | Successful login (SSO or password) |
| `login.failed` | Failed login attempt |
| `mfa.challenged` | MFA challenge issued |

### Budget events
| Event type | Triggered when |
|---|---|
| `budget.threshold_reached` | Budget soft threshold crossed (warn tier) |
| `budget.exceeded` | Budget hard ceiling reached (throttle or block tier) |
| `budget.reset` | Budget period reset |
| `spend.debited` | Request cost debited from key/team/org balance |

### Advanced Feature events
| Event type | Triggered when |
|---|---|
| `memory.retrieved` | Memory facts injected into request |
| `memory.stored` | Conversation turn stored in memory session |
| `guardrail.configured` | Guardrail created or updated |
| `prompt.version_published` | Prompt template version created |
| `token_saving.plan_updated` | Token Saving plan created or modified |

---

## Record schema

```json
{
  "event_id": "evt_01jz...",
  "event_type": "request.routed",
  "timestamp": "2026-06-29T10:00:00.123456Z",
  "workspace_id": "ws_abc123",
  "org_id": "org_xyz",
  "team_id": "data-science",
  "user_key_hash": "sha256:deadbeef...",
  "customer_id": null,
  "model": "openai/gpt-4o",
  "provider": "openai",
  "tokens_input": 512,
  "tokens_output": 128,
  "cost_usd": 0.00430,
  "latency_ms": 1240,
  "time_to_first_token_ms": 380,
  "guardrail_id": null,
  "guardrail_violations": [],
  "token_saving_plan_id": "support-bot-cache",
  "cache_hit": false,
  "prompt_id": null,
  "memory_id": null,
  "fallback_count": 0,
  "policy_version": 18,
  "request_id": "req_01jz...",
  "previous_event_hash": "sha256:abc123..."
}
```

---

## Querying the audit log

```bash
# Last 100 events
GET /audit-log?limit=100

# Events for a specific key
GET /audit-log?key_hash=sha256:...&start_date=2026-06-01

# Guardrail violations only
GET /audit-log?event_type=request.guardrail_triggered

# Export as CSV
GET /audit-log?format=csv&start_date=2026-06-01&end_date=2026-06-30
```

---

## Retention and export

| Method | Default retention | Max retention |
|---|---|---|
| RDS (primary store) | 365 days | 7 years (Enterprise) |
| S3 cold archive | Optional | Indefinite |
| SIEM stream | Real-time via webhook/Kafka | — |

→ [SIEM & Audit Export]({% link observability/siem-audit.md %}) for streaming configuration.
