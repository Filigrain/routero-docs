---
title: Memory-as-a-Service
parent: Advanced Features
nav_order: 4
description: "Long-term memory via Mem0 (vector) and Cognee (knowledge graph) — automatically retrieved and injected per request."
---

# Memory-as-a-Service

Memory-as-a-Service (MaaS) turns the gateway into a memory provider. Applications get personalization and long-term context without operating their own vector store or graph database — just pass a `memory_id` on the request.

---

## How it works

**Pre-call (retrieval):** The gateway takes the latest user message, searches the memory session for the top-3 relevant facts, and injects them into the system message as:
```
[Past Context for ID: user-alice]
- Prefers summaries under 200 words
- Working on Q3 APAC analysis
- Last session: discussed Bedrock pricing
```

**Post-call (storage):** After the LLM responds, the gateway asynchronously stores the `(user message, assistant response)` turn in the memory backend. Pass `store_memory: false` to skip storage on a specific request.

---

## Activation

```python
response = client.chat.completions.create(
    model="smart/balanced",
    messages=[{"role": "user", "content": "Remind me where we left off."}],
    extra_body={
        "memory_id": "user-alice",
        "store_memory": True,          # default — omit to use default
    },
)
```

---

## Memory engines

| Engine | Backend | Best for |
|---|---|---|
| **Mem0** | Postgres + pgvector | User preferences, recent facts, short-to-medium semantic recall |
| **Cognee** | Neo4j + pgvector + Postgres | Entity/relationship knowledge, long-horizon reasoning, knowledge graph queries |

Choose the engine when creating the memory session. Sessions cannot change engine after creation.

**Mem0** queries use keyword vs. question heuristics and fact deduplication to reduce redundant storage.

**Cognee** supports `SearchType.GRAPH_COMPLETION`, `CHUNKS`, and `SUMMARIES` — with graph→vector search fallback for robustness. Deletion cleans up Neo4j, PGVector, and Postgres atomically.

---

## Creating a memory session

```bash
curl -X POST https://api.routero.ai/memory/session/create \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "session_name": "user-alice",
    "engine_name": "mem0"
  }'
```

The returned `memory_id` is what callers pass on requests.

---

## Manual fact management

You can ingest facts directly (without going through a chat turn) and query the session programmatically:

```bash
# Ingest a fact manually
curl -X POST https://api.routero.ai/memory/session/add \
  -d '{"memory_id": "user-alice", "messages": [{"role": "user", "content": "My team is in Singapore."}]}'

# Search the session
curl -X POST https://api.routero.ai/memory/session/search \
  -d '{"memory_id": "user-alice", "query": "location preferences"}'

# List all stored facts
curl "https://api.routero.ai/memory/session/user-alice/facts"
```

---

## Org scoping and isolation

Memory sessions belong to the organization of the creating key. Sessions are IDOR-protected: a key from org A cannot access or inject a session from org B. The `memory_id` is opaque to the upstream provider — it is stripped before the request is forwarded.

---

## Management API

| Endpoint | Description |
|---|---|
| `GET /memory/engines` | List available memory engine types |
| `POST /memory/session/create` | Create a memory session |
| `GET /memory/sessions` | List all sessions in workspace |
| `GET /memory/session/{id}` | Get session details |
| `PATCH /memory/session/{id}` | Update session config |
| `DELETE /memory/session/{id}` | Delete session and all stored facts |
| `POST /memory/session/add` | Manually ingest facts |
| `POST /memory/session/search` | Query the session |
| `GET /memory/session/{id}/facts` | List all stored facts |

---

## Dependencies

| Engine | Required packages | Required infrastructure |
|---|---|---|
| Mem0 | `mem0ai` | Postgres + pgvector |
| Cognee | `cognee` | Neo4j + Postgres + pgvector |

Both are pre-configured in the [Docker Compose full stack]({% link deployment/self-hosted-docker.md %}) and [AWS Terraform memory module]({% link deployment/reference-architecture.md %}).

---

## Internal cost accounting

Embedding and extraction calls made by the memory subsystem (for storage and retrieval) route back through the proxy under an internal service-account key. These costs are tracked as **platform spend** — not charged to the calling user's key — and are visible in the billing dashboard under Internal / Platform.
