---
lang: en
page_id: advanced-features/token-saving
title: Token Saving
parent: Advanced Features
nav_order: 1
description: "Prompt compression and exact/semantic response caching — reduce cost without changing application code."
---

# Token Saving

Token Saving is a named plan that bundles two independent optimizations: **prompt compression** (reduce input tokens before the LLM call) and **response caching** (eliminate the LLM call entirely on repeated or near-duplicate prompts).

Both optimizations are managed centrally by admins and activated per-request by a single ID. No application logic changes.

{: .note }
Token Saving is about reducing compute — not buying cheaper tokens. The goal is eliminating redundant LLM calls and shrinking prompts, with the savings attributable as platform cost reduction in your spend reports.

---

## Activation

```python
response = client.chat.completions.create(
    model="smart/balanced",
    messages=[...],
    extra_body={"token_saving_plan_id": "my-plan"},
)
```

The plan is resolved from your workspace, applied as a pre-call hook, and stripped before the request reaches the upstream provider.

To opt out on a specific request: pass `cache: {"no-store": true}`.

---

## Prompt compression

Compression runs before the cache-key calculation, so compressed prompts can share cache hits across callers with different history lengths.

| Engine | Method | Use when |
|---|---|---|
| `trim` | Deterministic truncation (removes oldest messages to fit `max_input_tokens`) | Fast, zero dependencies, predictable |
| `text_rank` | TextRank extractive summarisation | Medium context, semantic fidelity matters |
| `lex_rank` | LexRank extractive summarisation | Similar to TextRank, often better on structured text |
| `lsa` | LSA (Latent Semantic Analysis) summarisation | Longer documents, topic-based extraction |

Summarisation engines require `sumy` and `nltk` Python packages. Set `max_input_tokens` on the compression plan.

---

## Response caching

A two-tier waterfall:

**Tier 1 — Exact cache**
Checks Redis for an identical cache key (model + compressed messages + parameters). Cache namespace is always the plan ID — each workspace's cache is private. Default TTL: 3600 s.

**Tier 2 — Semantic cache** (on exact-cache miss)
Generates an embedding of the query and performs vector similarity search (default threshold: 0.85) against previously cached queries. If a semantically equivalent prior response is found, it is returned without calling the LLM.

Semantic cache backends: **Redis-Stack** (RediSearch vector similarity) or **Qdrant**. Embedding calls route back through the proxy via an internal service-account key — their cost is tracked as platform spend and never double-charged to the calling key.

---

## Creating a plan

```bash
curl -X POST https://api.routero.ai/token-saving/plans \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "plan_name": "my-plan",
    "cache": {
      "backend": "redis_semantic",
      "similarity_threshold": 0.85,
      "ttl": 3600
    },
    "compression": {
      "engine": "text_rank",
      "max_input_tokens": 4096
    }
  }'
```

You can also configure plans in the Routero dashboard under **Token Saving → Plans**.

---

## Management API

| Endpoint | Description |
|---|---|
| `POST /token-saving/plans` | Create a plan |
| `GET /token-saving/plans` | List all plans in workspace |
| `GET /token-saving/plans/{id}` | Get plan details |
| `PATCH /token-saving/plans/{id}` | Update a plan |
| `DELETE /token-saving/plans/{id}` | Delete a plan |
| `GET /token-saving/cache-engines` | List available cache backends |
| `GET /token-saving/compression-engines` | List available compression engines |

---

## Dependencies

| Feature | Required packages | Required infrastructure |
|---|---|---|
| Exact cache only | — | Redis |
| Semantic cache (Redis-Stack) | `redis-stack` client | Redis-Stack (RediSearch + vector module) |
| Semantic cache (Qdrant) | `qdrant-client` | Qdrant instance |
| Summarisation compression | `sumy`, `nltk` | — |
| Trim compression | — | — |
