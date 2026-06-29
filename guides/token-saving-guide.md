---
lang: en
page_id: guides/token-saving-guide
title: Cut Costs with Token Saving
parent: Guides
nav_order: 7
description: "Configure prompt compression and semantic response caching for a high-volume endpoint."
---

# Cut Costs with Token Saving

This guide configures a Token Saving plan for a high-volume chat endpoint where prompts have long conversation history and many requests are semantically similar (e.g., a support bot, a code assistant, an FAQ interface).

---

## The plan we'll configure

1. **Compression** — trim conversation history to 4096 input tokens using TextRank summarisation.
2. **Exact cache** — return cached responses for identical prompts (TTL: 1 hour).
3. **Semantic cache** — return cached responses for near-identical prompts (similarity ≥ 0.85, TTL: 1 hour).

---

## Prerequisites

- Redis running (exact cache)
- Redis-Stack (for semantic search) or Qdrant

For Docker Compose, run with `--profile semantic`.

---

## Step 1 — Create the plan

```bash
curl -X POST https://api.routero.ai/token-saving/plans \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "plan_name": "support-bot-cache",
    "compression": {
      "engine": "text_rank",
      "max_input_tokens": 4096
    },
    "cache": {
      "backend": "redis_semantic",
      "similarity_threshold": 0.85,
      "ttl": 3600
    }
  }'
```

---

## Step 2 — Use the plan

```python
response = client.chat.completions.create(
    model="smart/balanced",
    messages=conversation_history,   # may be hundreds of messages
    extra_body={"token_saving_plan_id": "support-bot-cache"},
)
```

The gateway:
1. Compresses `conversation_history` to ≤4096 tokens using TextRank.
2. Checks the exact cache — if hit, returns the cached response.
3. Generates an embedding of the compressed query, checks for semantic matches ≥ 0.85 — if hit, returns the cached response.
4. If no cache hit, calls the LLM and stores the response in both cache tiers.

---

## Step 3 — Measure the impact

After 24 hours, check spend in the dashboard. Compare:
- `litellm_tokens_total` before vs. after (compression effect)
- `cache_hits` in the Token Saving plan stats (cache effect)

```bash
GET /token-saving/plans/support-bot-cache/stats
# Returns: total_requests, cache_hits, cache_hit_rate, tokens_saved, cost_saved_usd
```

---

## When to use semantic vs. exact cache

| Cache type | Good for | Not good for |
|---|---|---|
| Exact | Identical prompts (idempotent tools, fixed templates) | Conversations with unique user input |
| Semantic | FAQ-style questions, paraphrased queries | Time-sensitive or personalised responses |

Start with semantic threshold 0.85. Lower to 0.80 for higher cache hit rate (slightly less accuracy). Raise to 0.90 for higher precision (fewer false hits).

---

## Opt out per request

```python
# Skip cache for this request (e.g., a real-time, time-sensitive query)
extra_body={
    "token_saving_plan_id": "support-bot-cache",
    "cache": {"no-store": True}
}
```
