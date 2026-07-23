---
lang: en
page_id: advanced-features/memory-service
title: Memory-as-a-Service
parent: AI Capabilities
nav_order: 4
description: "Long-term memory via Mem0 (vector) and Cognee (knowledge graph) — automatically retrieved and injected per request."
---

# Memory-as-a-Service

Memory-as-a-Service (MaaS) turns the gateway into a memory provider. Applications get personalization and long-term context without operating their own vector store or graph database — just pass a `memory_id` on the request.

---

## How it works

A memory **session** is a named, engine-backed store of facts tied to one organisation. On each request that references a session, the gateway runs two steps:

**Pre-call (retrieval).** The gateway takes the latest user message, searches the session for the top 3 relevant facts, and appends them to the system message:

```
[Past Context for ID: user-alice]
- Prefers summaries under 200 words
- Working on Q3 APAC analysis
- Last session: discussed Bedrock pricing
```

**Post-call (storage).** After the model responds, the gateway asynchronously stores the `(user, assistant)` turn in the session. Pass `store_memory: false` to skip storage on a single request.

The memory hook runs last in the pre-call chain, so injected context follows prompt injection, guardrails, and compression:

```
GuardrailHook → PromptHook → TokenSavingPlanHook → MemoryHook
```

The `memory_id` is opaque to the upstream provider — it is stripped before the request is forwarded.

---

## Activation

```python
response = client.chat.completions.create(
    model="smart/balanced",
    messages=[{"role": "user", "content": "Remind me where we left off."}],
    extra_body={
        "memory_id": "user-alice",
        # "store_memory": False,   # omit (default true) to store this turn
    },
)
```

Pass `memory_id` top-level or inside `metadata`. A session can also be [bound through a policy]({% link core-gateway/policies.md %}) so it activates automatically.

---

## Memory engines

Choose the engine when creating the session; it cannot be changed afterwards.

| Engine | Backend | Best for |
|---|---|---|
| **Mem0** | Postgres + pgvector | User preferences, recent facts, short-to-medium semantic recall |
| **Cognee** | Postgres + pgvector + Neo4j | Entity and relationship knowledge, long-horizon reasoning |

**Mem0** distinguishes keyword lookups from natural-language questions and deduplicates facts to avoid redundant storage. Vector search defaults to a `0.5` similarity threshold.

**Cognee** builds a knowledge graph from stored turns (`remember`) and answers retrieval with Cognee's chunk (vector) search scoped to the session, supplemented by lexical matching and fact dedup. It deliberately does not use graph-completion search (which synthesises new answers rather than returning stored facts).

---

## Creating a memory session

Open **Memory** and choose **Create Session**. The form takes a **Name**, an **Engine** (Mem0 or Cognee), an optional **External ID**, and optional **Metadata**. The returned `memory_id` (a UUID) is what callers pass on requests.

![The Memory sessions list, with the Create Session button](/assets/images/memory-service/memory-sessions-list.png)

![The Create Session drawer — name, engine, external ID, and metadata](/assets/images/memory-service/create-memory-session-drawer.png)

---

## Managing stored facts

Each session's detail page is where you work with the facts the memory holds:

- **Search Memory** — run a natural-language query against the session and see scored matches.
- **Add Memory** — ingest a fact directly, without going through a chat turn.
- **All Memory Facts** — browse and delete every stored fact in the session.

![A memory session detail view — search, add-fact, and the stored-facts table](/assets/images/memory-service/memory-session-detail.png)

---

## Organisation isolation and permissions

- **Org-scoped.** Sessions belong to one organisation. The table `LiteLLM_MemorySession` stores an `organization_id` and enforces a unique `(organization_id, name)`.
- **IDOR-protected.** Operations are authorised per-org via Cerbos (`org:memory:common`); the gateway also checks the session's org at resolve time and rejects mismatches.
- **Who can manage.** Proxy admins and organisation admins can create, edit, and delete sessions.

---

## Internal cost accounting

The embedding and extraction calls the memory subsystem makes for storage and retrieval route back through the gateway under an internal service-account key (model `internal-gpt-4o-mini` with embedder `internal-text-embedding-3-small`; China region uses `internal-qwen-plus` with `internal-text-embedding-v4`). These costs are tracked as **platform spend** — never charged to the calling key.

---

## Dependencies

| Engine | Required packages | Required infrastructure |
|---|---|---|
| Mem0 | `mem0ai` | Postgres + pgvector |
| Cognee | `cognee` | Postgres + pgvector + Neo4j |

Both are available in private deployments — see [Reference Architecture]({% link deployment/reference-architecture.md %}) for infrastructure requirements.

---

## Combining with the rest of the gateway

- **Policies** — bind a session into a [policy]({% link core-gateway/policies.md %}) to activate it automatically on a key or model.
- **Prompts / guardrails / token saving** — the other [AI Capabilities]({% link advanced-features.md %}) apply to the same request in their normal order.
- **Playground** — pick a memory session to enable automatic context injection and storage during a chat.

→ [Policies]({% link core-gateway/policies.md %}) for binding sessions to keys and models.
