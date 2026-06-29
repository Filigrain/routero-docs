---
lang: en
page_id: advanced-features/guardrails
title: Guardrails
parent: Advanced Features
nav_order: 2
description: "Content filtering, PII redaction, secret detection, and tool permission enforcement — centrally managed, per-org enforced."
---

# Guardrails

Guardrails are org-scoped named configurations that apply one or more safety engines to requests and responses. They run inside the gateway — before the LLM sees the prompt and after it responds — without changing a line of application code.

{: .enterprise }
> Guardrails answer legal's question: *"What did the model see?"* Content-filter violations, PII redactions, and secret detections are written to your audit log with their category and message — not the raw blocked content.

---

## Activation

```python
response = client.chat.completions.create(
    model="smart/balanced",
    messages=[{"role": "user", "content": user_input}],
    extra_body={"guardrail_id": "my-pii-guardrail"},
)
```

On a violation that is configured to `block`, the gateway returns HTTP 400 with a structured error:

```json
{
  "error": {
    "message": "Request blocked by guardrail: PII detected (EMAIL_ADDRESS)",
    "type": "guardrail_violation",
    "code": "guardrail_blocked"
  }
}
```

---

## Built-in engines

Four engines compose within a single guardrail. They run sequentially; each receives the (possibly-modified) output of the previous.

### Content Filter
Blocks or flags requests and responses matching keyword or regex patterns.

| Config | Description |
|---|---|
| `banned_keywords` | Case-insensitive substring match list |
| `banned_patterns` | Regex list with `IGNORECASE` |
| `event_hooks` | `pre_call`, `post_call`, or both |

No extra dependencies. Zero-latency.

---

### Tool Permission
Enforces an allow-list or deny-list on function/tool names before the LLM call.

| Config | Description |
|---|---|
| `allowed_tools` | Whitelist — only these tool names are permitted |
| `blocked_tools` | Blacklist — these tool names are removed from the request |
| `on_violation` | `block` (reject the request) or `remove` (strip the tool silently) |

Runs pre-call only (tools are in the request, not the response).

---

### PII Detection (Presidio)
Detects and anonymises personally identifiable information in prompts and responses using [Microsoft Presidio](https://microsoft.github.io/presidio/).

| Config | Description |
|---|---|
| `entities` | List of entity types: `PERSON`, `EMAIL_ADDRESS`, `PHONE_NUMBER`, `CREDIT_CARD`, `US_SSN`, `IBAN_CODE`, `IP_ADDRESS`, `LOCATION`, … |
| `action` | `anonymize` (replace with `<ENTITY_TYPE>`) or `block` (reject if PII found) |
| `score_threshold` | Minimum Presidio confidence score (default 0.5) |
| `event_hooks` | `pre_call`, `post_call`, or both |

**Dependencies:** `presidio-analyzer`, `presidio-anonymizer`

Presidio runs locally in the gateway — PII never leaves your infrastructure to reach an external moderation vendor.

---

### Secret Detection (detect-secrets)
Detects leaked credentials and secrets in prompts using [Yelp detect-secrets](https://github.com/Yelp/detect-secrets).

| Config | Description |
|---|---|
| `action` | `redact` (replace with `[REDACTED]`) or `block` (reject) |
| `detectors` | Subset of ~21 built-in detectors: `aws`, `github`, `slack`, `stripe`, `jwt`, `private_key`, `azure`, `twilio`, `base64_high_entropy`, … |

Runs pre-call only (secrets are in the prompt, not the response).

**Dependencies:** `detect-secrets`

---

## Creating a guardrail

```bash
curl -X POST https://api.routero.ai/guardrail \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "guardrail_name": "pii-redact-prod",
    "engines": [
      {
        "engine_name": "presidio",
        "config": {
          "entities": ["PERSON", "EMAIL_ADDRESS", "PHONE_NUMBER", "CREDIT_CARD", "US_SSN"],
          "action": "anonymize",
          "score_threshold": 0.5
        },
        "event_hooks": ["pre_call", "post_call"]
      },
      {
        "engine_name": "detect_secret",
        "config": {
          "action": "redact",
          "detectors": ["aws", "github", "stripe", "jwt"]
        },
        "event_hooks": ["pre_call"]
      }
    ]
  }'
```

---

## Management API

| Endpoint | Description |
|---|---|
| `GET /guardrail/engines` | List available engine types |
| `POST /guardrail` | Create a guardrail |
| `GET /guardrail/list` | List guardrails in workspace (paginated) |
| `GET /guardrail/{id}` | Get guardrail details |
| `PATCH /guardrail/{id}` | Update a guardrail |
| `DELETE /guardrail/{id}` | Delete a guardrail |
