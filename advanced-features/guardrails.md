---
lang: en
page_id: advanced-features/guardrails
title: Guardrails
parent: AI Capabilities
nav_order: 2
description: "Content filtering, PII redaction, secret detection, and tool-permission enforcement — centrally managed, per-org enforced."
---

# Guardrails

A **guardrail** is an org-scoped named configuration that applies one or more safety engines to requests and responses. Guardrails run inside the gateway — before the model sees the prompt and after it responds — without changing a line of application code.

{: .note }
Guardrails answer legal's question: *"What did the model see?"* When an engine blocks or redacts content, the gateway returns a clear violation message and never forwards the offending content to the provider. Guardrail configurations are org-scoped and access-controlled through [Access Control & Audit]({% link core-gateway/sso-rbac-audit.md %}).

---

## How it works

A guardrail holds an ordered list of **engines**. On a chat request, the gateway runs the guardrail's pre-call engines against the prompt; after the model responds, it runs the post-call engines against the response. Each engine receives the (possibly-modified) output of the previous one. An engine either:

- **Blocks** — rejects the request with HTTP `400` and a violation message, or
- **Transforms** — redacts or anonymises the offending content and lets the request continue.

Guardrails run **first** in the pre-call hook chain, so safety engines inspect the caller's raw input before any prompt template is injected or compression is applied:

```
GuardrailHook → PromptHook → TokenSavingPlanHook → MemoryHook
```

{: .note }
This is the database-backed guardrail service — distinct from the upstream LiteLLM config-based guardrails (`metadata.guardrails`, `disable_global_guardrails`). The two systems are separate; this page covers only the dashboard-managed guardrails activated by `guardrail_id`.

---

## Built-in engines

Four engines compose within a single guardrail. Each engine has a set of config fields (shown below) and a choice of **event hooks** — `pre_call` (inspect the prompt), `post_call` (inspect the response), or both.

### Content Filter
Blocks requests and responses matching keyword or regex patterns. Runs on both `pre_call` and `post_call`.

| Config | Description |
|---|---|
| `banned_keywords` | Case-insensitive substring match list |
| `banned_patterns` | Regex list, compiled with `IGNORECASE` |
| `violation_message` | Custom block message (default: `Request blocked by content filter.`) |

No extra dependencies. Block-only (no redaction).

---

### Tool Permission
Enforces an allow-list or deny-list on function/tool names before the model call. Runs on `pre_call` only.

| Config | Description |
|---|---|
| `allowed_tools` | Whitelist — only these tool names are permitted. Omit to allow all. |
| `blocked_tools` | Blacklist — always blocked, takes precedence over the allow-list. |
| `on_violation` | `block` (default — reject the request) or `remove` (silently strip the disallowed tool) |
| `violation_message` | Custom block message (default: `Tool call not permitted.`) |

No extra dependencies.

---

### PII Detection (Presidio)
Detects and anonymises personally identifiable information using [Microsoft Presidio](https://microsoft.github.io/presidio/). Runs on both `pre_call` and `post_call`.

| Config | Description |
|---|---|
| `entities` | Presidio entity types to detect — e.g. `PERSON`, `EMAIL_ADDRESS`, `PHONE_NUMBER`, `CREDIT_CARD`, `US_SSN`, `IBAN_CODE`, `IP_ADDRESS`. Omit (or `null`) to detect **all** recognizers installed in your `presidio-analyzer`. |
| `language` | Text language (default: `en`) |
| `action` | `anonymize` (default — replace each PII span with a typed placeholder such as `<PERSON>`) or `block` (reject if any PII is found) |
| `score_threshold` | Minimum Presidio confidence (default: `0.5`) |
| `violation_message` | Custom block message (default: `Request contains PII and was blocked.`) |

**Dependencies:** `presidio-analyzer`, `presidio-anonymizer`. Presidio runs locally inside the gateway — PII never leaves your infrastructure to reach an external moderation vendor.

{: .note }
`entities` is open-ended: any string you pass is forwarded to Presidio, so the valid set depends on your installed recognizers. Don't treat the examples above as a fixed list.

---

### Secret Detection (detect-secrets)
Detects leaked credentials in prompts using [Yelp detect-secrets](https://github.com/Yelp/detect-secrets). Runs on `pre_call` only.

| Config | Description |
|---|---|
| `action` | `redact` (default — replace each secret with `[REDACTED]`) or `block` (reject) |
| `plugins` | Detector short-names to enable. Omit (or `null`) to enable **all** detectors. Unknown names are rejected. |
| `violation_message` | Custom block message (default: `Request contains secrets and was blocked.`) |

The 21 built-in detector short-names: `aws`, `artifactory`, `azure`, `basic_auth`, `base64_entropy`, `cloudant`, `discord`, `github`, `hex_entropy`, `ibm_cos`, `ibm_iam`, `jwt`, `mailchimp`, `npm`, `private_key`, `sendgrid`, `slack`, `softlayer`, `square`, `stripe`, `twilio`.

**Dependencies:** `detect-secrets`.

---

## Activation

A caller activates a guardrail by passing its ID on the request (top-level or inside `metadata`):

```python
response = client.chat.completions.create(
    model="smart/balanced",
    messages=[{"role": "user", "content": user_input}],
    extra_body={"guardrail_id": "pii-redact-prod"},
)
```

The gateway resolves the guardrail from the caller's organisation, runs it as a hook, and strips `guardrail_id` before forwarding to the provider. A guardrail can also be [bound through a policy]({% link core-gateway/policies.md %}) so it activates automatically on every matching request — no per-call field needed.

When an engine configured to block fires, the gateway returns HTTP `400` with the violation message in the standard error body:

```json
{
  "detail": "Request blocked by guardrail."
}
```

---

## Creating a guardrail

Open **Guardrails** in the admin navigation and choose **Create Guardrail**. Give the guardrail a name, add one or more engines, and for each engine pick its **event hooks** (`pre_call`, `post_call`) and fill in its **config**. The config form is generated dynamically from the engine's schema, so the fields match the tables above. A guardrail needs at least one engine, and names are unique within an organisation.

![The Guardrails list page, with the Create Guardrail button](/assets/images/guardrails/guardrails-list.png)

![The Create Guardrail drawer — name, engine type, event hooks, and a per-engine config form](/assets/images/guardrails/create-guardrail-drawer.png)

{: .note }
The dashboard engine picker lists **Content Filter**, **Tool Permission**, and **Secret Detection**. **Presidio** is fully supported but is not yet shown in the picker.

![A guardrail detail view — engine cards with event-hook tags and config values](/assets/images/guardrails/guardrail-detail.png)

---

## Organisation isolation and permissions

- **Org-scoped.** Guardrails belong to one organisation. The table `LiteLLM_GuardrailsTable` stores an `organization_id` and enforces a unique `(organization_id, guardrail_name)`.
- **IDOR-protected.** Every operation is authorised per-org via Cerbos (`org:guardrail:common`); the gateway also checks the guardrail's org at resolve time and rejects mismatches.
- **Who can manage.** Proxy admins and organisation admins can create, edit, and delete guardrails. The organisation selector on the Guardrails page is available to proxy admins.

---

## Dependencies and enablement

| Engine | Optional deps | Runs |
|---|---|---|
| Content Filter | — | pre & post |
| Tool Permission | — | pre |
| Secret Detection | `detect-secrets` | pre |
| Presidio PII | `presidio-analyzer`, `presidio-anonymizer` | pre & post |

Content Filter and Tool Permission work out of the box. The Presidio and Secret Detection engines require their Python packages; the gateway raises a clear install instruction if a request hits an engine whose dependency is missing.

---

## Combining with the rest of the gateway

- **Policies** — bind a guardrail into a [policy]({% link core-gateway/policies.md %}) to activate it automatically on a key or model.
- **Prompts / memory / token saving** — the other [AI Capabilities]({% link advanced-features.md %}) apply to the same request in their normal order after the guardrail runs.
- **Playground** — pick a guardrail under Advanced Settings to test it against a live model.

→ [Policies]({% link core-gateway/policies.md %}) for binding guardrails to keys and models.
→ [Access Control & Audit]({% link core-gateway/sso-rbac-audit.md %}) for the org/admin permission model.
