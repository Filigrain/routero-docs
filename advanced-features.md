---
lang: en
page_id: advanced-features
title: AI Capabilities
nav_order: 5
has_children: true
description: "Token Saving, Guardrails, Prompt Management, Memory-as-a-Service, Knowledge Base, and Web Search — Routero's production AI layer."
---

# AI Capabilities

Routero ships six opt-in capabilities that production AI systems typically build in-house — response caching, content safety, prompt versioning, long-term memory, document retrieval, and web search. They live inside the gateway, so your application code stays clean.

{: .note }
These features are **off by default** and activated per-request. Admins create named configurations in the Routero dashboard; callers reference them by ID. No code changes beyond adding an ID field to your existing requests.

---

## Activate with a single ID

Every AI capability follows the same pattern — the **Feature-as-a-Session** design:

1. An admin creates a named configuration (guardrail, token-saving plan, prompt, memory session, knowledge base, or web search tool) in the dashboard.
2. The caller passes the configuration's ID in the request body.
3. The gateway resolves the config from your workspace (org-scoped, IDOR-checked), applies it as a pre/post hook, and strips the ID before forwarding to the upstream provider.

```python
# All six features in a single request — zero change to the rest of your code
response = client.chat.completions.create(
    model="openai/gpt-5.5",
    messages=[{"role": "user", "content": "..."}],
    extra_body={
        "guardrail_id":         "pii-redact-prod",
        "token_saving_plan_id": "semantic-cache-v2",
        "prompt_id":            "analyst-system-v4",
        "memory_id":            "user-alice",
        "knowledge_base_id":    "product-handbook",
        "web_search_id":        "web-current-events",
    },
)
```

{: .note }
You can combine any subset of the six IDs on a single request. Each is independent. Hooks run in this order: `GuardrailHook` → `PromptHook` → `TokenSavingPlanHook` → `MemoryHook` → `KnowledgeHook` → `WebSearchHook`.

---

## The six features

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

Pass `store_memory: false` on any request to skip storage. Use the session's dashboard page to manually ingest facts or query the session.

→ [Memory-as-a-Service]({% link advanced-features/memory-service.md %})

---

### Knowledge Base
Retrieval-augmented answers from your own documents, without operating a vector store or building a RAG pipeline.

- **Upload once** — Markdown, plain text, CSV, JSON, text-layer PDFs, and Office documents are parsed, chunked along headings, embedded, and indexed by the platform.
- **Automatic retrieval** — on every request that references the knowledge base, the most similar passages are injected into the prompt as reference material (with an anti-prompt-injection header). Below-threshold queries skip silently.
- **Testable** — a built-in retrieval test runs the exact search the gateway performs, showing each chunk with its score and source.

→ [Knowledge Base]({% link advanced-features/knowledge-base.md %})

---

### Web Search
Grounds answers in fresh web results on **any model** — no function calling, no client changes. A plain chat request searches the web first; the gateway injects the results as reference material and the model answers with current information.

- **Three search modes** — the provider's built-in search where the model has one, the Routero search engine otherwise, or the Routero engine always.
- **Works everywhere** — models without native search still get searched answers; nothing to configure per model.
- **Org-governed** — whether and how widely to search is set on the tool, not switched on per request.

→ [Web Search]({% link advanced-features/web-search.md %})

---

## Enterprise framing

{: .enterprise }
> **These are governance features, not discount features.**
>
> Token Saving eliminates redundant compute and keeps platform costs accountable — not a discount on tokens, but a reduction in tokens consumed. Guardrails answer legal's question: "what did the model see?" Prompt Management gives security the version history they need for a GDPR data-handling review. Memory turns ephemeral stateless LLM calls into a system of record — a first-class enterprise capability, not a UX nicety.

Each feature is:
- **Org-scoped** — configurations belong to your workspace and are invisible to other tenants.
- **IDOR-protected** — the gateway checks that the calling key's organisation owns the referenced ID before applying it.
- **Audited** — feature activations, cache hits, and guardrail violations appear in your audit log and usage views.
- **Dashboard-managed** — non-engineers can create and manage configurations from the Routero admin dashboard without API calls.

---

## Dependencies and enablement

AI Capabilities require optional Python dependencies and infrastructure components not present in a minimal Routero deployment. Each feature page documents its prerequisites.

| Feature | Optional deps | Infrastructure |
|---|---|---|
| Token Saving (semantic cache) | `redis-stack` or `qdrant-client` | Redis-Stack or Qdrant |
| Token Saving (summarisation) | `sumy`, `nltk` | — |
| Guardrails (PII) | `presidio-analyzer`, `presidio-anonymizer` | — |
| Guardrails (secret detection) | `detect-secrets` | — |
| Memory (Mem0) | `mem0ai` | Postgres + pgvector |
| Memory (Cognee) | `cognee` | Neo4j + Postgres + pgvector |
| Knowledge Base | — (platform-managed) | Platform-provided vector index and embeddings |
| Web Search | — (platform-managed) | Platform-provided search engine; provider-side search billed by the provider |

The exact-cache, content-filter, tool-permission, and keyword-guardrail engines have **no extra dependencies** — they work out of the box. The Knowledge Base and Web Search are fully hosted: indexing and searching run on the platform side.
