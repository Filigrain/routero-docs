---
title: Webhooks
parent: Observability
nav_order: 4
description: "Real-time event notifications for routing decisions, budget alerts, and guardrail violations."
---

# Webhooks

Routero can POST event notifications to any HTTPS endpoint. Use webhooks for real-time alerting, custom dashboards, or piping events into internal tooling without polling the API.

---

## Event types

| Event | When it fires |
|---|---|
| `request.routed` | Every successful routing decision |
| `request.blocked` | Request rejected by guardrail or budget |
| `budget.threshold_80` | Workspace/team budget hits 80% |
| `budget.exceeded` | Budget ceiling reached (block tier active) |
| `guardrail.violated` | Guardrail engine triggered a violation |
| `key.rotated` | Virtual key was regenerated |
| `user.deprovisioned` | User removed via SCIM or manually |
| `fallback.triggered` | Router fell back to a secondary provider |

---

## Configuration

```yaml
# config.yaml
litellm_settings:
  alerting: ["webhook"]
  alerting_webhook_url: "https://hooks.yourcompany.com/routero"

# Optional: filter to specific event types
alerting_events:
  - budget.threshold_80
  - guardrail.violated
  - fallback.triggered
```

---

## Payload format

```json
{
  "event_type": "budget.threshold_80",
  "timestamp": "2026-06-29T10:00:00Z",
  "workspace_id": "ws_...",
  "team_id": "data-science",
  "budget_used_pct": 82.4,
  "budget_used_usd": 412.00,
  "budget_max_usd": 500.00
}
```

All webhook payloads include an `X-Routero-Signature` header (HMAC-SHA256 of the raw body, signed with your webhook secret). Verify it before processing.
