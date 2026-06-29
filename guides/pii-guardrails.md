---
lang: en
page_id: guides/pii-guardrails
title: PII Guardrails for Regulated Teams
parent: Guides
nav_order: 6
description: "Set up Presidio-backed PII redaction in Routero to satisfy data handling requirements for regulated industries."
---

# PII Guardrails for Regulated Teams

This guide is for teams that need to prevent personal data from reaching the model — healthcare applications, financial advisors, HR tools, or any application where users might paste personal information into a prompt.

**What you'll build:** a guardrail that automatically anonymises PII in prompts before they reach the LLM, and in responses before they reach the user. Microsoft Presidio runs locally in the gateway — no data leaves your infrastructure to reach an external moderation API.

---

## Prerequisites

Presidio is an optional dependency. Ensure it's installed in your Routero deployment:

```bash
pip install presidio-analyzer presidio-anonymizer
python -m spacy download en_core_web_sm  # English NLP model
```

For Private Deployments, include the `presidio` extras when building the proxy image (covered in the deployment package).

---

## Step 1 — Create the guardrail

```bash
curl -X POST https://api.routero.ai/guardrail \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "guardrail_name": "pii-healthcare",
    "engines": [
      {
        "engine_name": "presidio",
        "config": {
          "entities": [
            "PERSON",
            "EMAIL_ADDRESS",
            "PHONE_NUMBER",
            "CREDIT_CARD",
            "US_SSN",
            "US_DRIVER_LICENSE",
            "US_PASSPORT",
            "US_BANK_NUMBER",
            "MEDICAL_LICENSE",
            "IP_ADDRESS",
            "LOCATION",
            "DATE_TIME"
          ],
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

Note the returned `guardrail_id`.

---

## Step 2 — Test it

```python
response = client.chat.completions.create(
    model="smart/balanced",
    messages=[{
        "role": "user",
        "content": "Patient John Smith (DOB 01/15/1985, SSN 123-45-6789) needs a follow-up."
    }],
    extra_body={"guardrail_id": "pii-healthcare"},
)
# Model receives: "Patient [PERSON] (DOB [DATE_TIME], SSN [US_SSN]) needs a follow-up."
```

---

## Step 3 — Apply to all keys in a team (policy-level enforcement)

Rather than requiring every caller to pass `guardrail_id`, apply the guardrail to all requests from a specific team via policy:

```yaml
# healthcare-team-policy.yaml
workspace: healthcare
rules:
  - when:
      identity.team_id: healthcare
    guardrail_id: pii-healthcare
    route: smart/balanced
```

Upload the policy via the dashboard or `POST /config/update`. Every request from the `healthcare` team key now runs through the PII guardrail automatically — callers don't need to know it exists.

---

## What gets logged

Guardrail activations are recorded in the audit log under `event_type: request.guardrail_triggered`:

```json
{
  "event_type": "request.guardrail_triggered",
  "guardrail_id": "pii-healthcare",
  "engine": "presidio",
  "entities_detected": ["PERSON", "US_SSN"],
  "action": "anonymize",
  "hook": "pre_call"
}
```

The **original content is never stored** — only the entity types detected. This is intentional and auditable.
