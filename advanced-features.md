---
title: Advanced Features
nav_order: 5
has_children: true
description: "Token Saving, Guardrails, Prompt Management, and Memory-as-a-Service — Routero's production AI layer."
---

# Advanced Features

Routero ships four opt-in capabilities that production AI systems typically build in-house — response caching, content safety, prompt versioning, and long-term memory. They live inside the gateway, so your application code stays clean.

{: .note }
These features are **off by default** and activated per-request. Admins create named configurations in the Routero dashboard or via the Management API; callers reference them by ID. No code changes beyond adding an ID field to your existing requests.

---

## Activate with a single ID

Every advanced feature follows the same pattern — the **Feature-as-a-Session** design:

1. An admin creates a named configuration (guardrail, token-saving plan, prompt, or memory session) in the dashboard or Management API.
2. The caller passes the configuration's ID in the request body.
3. The gateway resolves the config from your workspace (org-scoped, IDOR-checked), applies it as a pre/post hook, and strips the ID before forwarding to the upstream provider.

```python
# All four features in a single request — zero change to the rest of your code
response = client.chat.completions.create(
    model="smart/balanced",
    messages=[{"role": "user", "content": "..."}],
    extra_body={
        "guardrail_id":         "pii-redact-prod",
        "token_saving_plan_id": "semantic-cache-v2",
        "prompt_id":            "analyst-system-v4",
        "memory_id":            "user-alice",
    },
)
```

{: .note }
You can combine any subset of the four IDs on a single request. Each is independent. Hooks run in this order: `PromptHook` → `TokenSavingPlanHook` → `GuardrailHook` → `MemoryHook`.

---

## The four features

### Token Saving
Reduces the cost of every request without touching application code. Bundles two independent optimizations:

- **Prompt compression** — trims or summarises conversation history before it reaches the LLM (TextRank, LexRank, LSA extractive summarisation, or deterministic truncation).
- **Response caching** — exact-match cache for identical prompts, falling back to semantic similarity search (Redis-Stack or Qdrant, default threshold 0.85) for near-duplicate prompts. Cache namespace is always the plan ID, so each tenant's cache is private.

The two optimizations compose: compression runs first, shrinking the cache key surface; then the cache checks for a hit. On a hit, the LLM call never happens.

→ [Token Saving]({% link advanced-features/token-saving.md %})

---

### Guardrails
Centrally managed, policy-driven safety and compliance — enforced in the gateway without touching your application.

Four built-in engines, running sequentially:

| Engine | Runs on | What it does |
|---|---|---|
| **Content Filter** | pre & post | Keyword / regex blocklist on prompts and model responses |
| **Tool Permission** | pre | Allowlist or blocklist for function/tool names |
| **Presidio PII** | pre & post | Detects and anonymises personal data (PERSON, EMAIL, SSN, CREDIT_CARD, …) via Microsoft Presidio |
| **Secret Detection** | pre | Detects and redacts leaked credentials (AWS keys, GitHub tokens, Stripe keys, JWTs, private keys, …) via Yelp detect-secrets |

Each engine is configurable per guardrail. On a violation, the request is blocked with an HTTP 400 and a structured violation message — or the offending content is redacted and the request proceeds.

→ [Guardrails]({% link advanced-features/guardrails.md %})

---

### Prompt Management
A central prompt template registry. Prompt teams iterate in one place; applications reference a stable `prompt_id` that never changes even as the underlying template evolves.

- **Versioning** — every PUT to a prompt name creates an immutable new version. The `prompt_id` UUID is stable across versions; callers can pin to a specific version with `?version=N`.
- **Jinja2 templating** — `{{ customer_name }}`, `{{ language }}`, `{{ context }}` filled at request time via `prompt_variables`.
- **Two-layer cache** — in-process 5-minute cache + Redis 1-day cache. Changes apply to the next request within seconds.
- **Instant rollback** — re-activate any prior version by pinning `prompt_version`.

→ [Prompt Management]({% link advanced-features/prompt-management.md %})

---

### Memory-as-a-Service
Turns the gateway into a memory provider. Applications get personalization and long-term context without operating their own vector store or graph database.

Two backend engines, selectable per memory session:

| Engine | Best for | Backend |
|---|---|---|
| **Mem0** | User preferences, recent facts, short-to-medium recall | pgvector (Postgres) |
| **Cognee** | Entity/relationship knowledge, long-horizon reasoning | Neo4j + pgvector |

**How it works per request:**
1. **Pre-call (retrieval)** — searches the memory session for the top-3 relevant facts, injects them into the system message as `[Past Context for ID: ...]`.
2. **Post-call (storage)** — asynchronously stores the new (user, assistant) turn in the memory backend.

Pass `store_memory: false` on any request to skip storage. Use the Management API to manually ingest facts or query the session.

→ [Memory-as-a-Service]({% link advanced-features/memory-service.md %})

---

## Enterprise framing

{: .enterprise }
> **These are governance features, not discount features.**
>
> Token Saving eliminates redundant compute and keeps platform costs accountable — not a discount on tokens, but a reduction in tokens consumed. Guardrails answer legal's question: "what did the model see?" Prompt Management gives security the version history they need for a GDPR data-handling review. Memory turns ephemeral stateless LLM calls into a system of record — a first-class enterprise capability, not a UX nicety.

Each feature is:
- **Org-scoped** — configurations belong to your workspace and are invisible to other tenants.
- **IDOR-protected** — the gateway checks that the calling key's organisation owns the referenced ID before applying it.
- **Audited** — feature activations, cache hits, and guardrail violations appear in your immutable audit log.
- **Dashboard-managed** — non-engineers can create and manage configurations from the Routero admin dashboard without API calls.

---

## Dependencies and enablement

Advanced Features require optional Python dependencies and infrastructure components not present in a minimal Routero deployment. Each feature page documents its prerequisites.

| Feature | Optional deps | Infrastructure |
|---|---|---|
| Token Saving (semantic cache) | `redis-stack` or `qdrant-client` | Redis-Stack or Qdrant |
| Token Saving (summarisation) | `sumy`, `nltk` | — |
| Guardrails (PII) | `presidio-analyzer`, `presidio-anonymizer` | — |
| Guardrails (secret detection) | `detect-secrets` | — |
| Memory (Mem0) | `mem0ai` | Postgres + pgvector |
| Memory (Cognee) | `cognee` | Neo4j + Postgres + pgvector |

The exact-cache, content-filter, tool-permission, and keyword-guardrail engines have **no extra dependencies** — they work out of the box.
