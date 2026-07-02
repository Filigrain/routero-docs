---
lang: en
page_id: guides/long-term-memory
title: Give Your App Long-Term Memory
parent: Guides
nav_order: 8
description: "Use Memory-as-a-Service to give your application per-user long-term memory with automatic retrieval and storage."
---

# Give Your App Long-Term Memory

This guide adds persistent, per-user memory to an existing chat application. After setup, the gateway automatically retrieves relevant facts from past conversations and injects them into each new request — no changes to application logic beyond passing a `memory_id`.

---

## What we're building

- One Mem0 memory session per user
- Automatic fact retrieval on every request (top-3 relevant facts injected as system context)
- Automatic fact storage after every response (async, no response latency impact)

---

## Prerequisites

Mem0 requires Postgres with pgvector. For Private Deployments, enable the memory tier via the deployment package (covered in your onboarding guide).

---

## Step 1 — Create a memory session per user

Create sessions at first login (or when the user is provisioned). Store the returned `memory_id` alongside the user record.

```python
import requests

def create_memory_session(user_id: str) -> str:
    resp = requests.post(
        "https://api.routero.ai/memory/session/create",
        headers={"Authorization": f"Bearer {ADMIN_KEY}"},
        json={"session_name": f"user-{user_id}", "engine_name": "mem0"},
    )
    return resp.json()["memory_id"]
```

---

## Step 2 — Pass `memory_id` on every chat request

```python
def chat(user_id: str, message: str, memory_id: str) -> str:
    response = client.chat.completions.create(
        model="smart/balanced",
        messages=[{"role": "user", "content": message}],
        extra_body={
            "memory_id": memory_id,
            "store_memory": True,     # default — can be omitted
        },
    )
    return response.choices[0].message.content
```

On the first request, no context is injected (the session is empty). After the first turn, future requests get:

```
System context (injected by gateway):
[Past Context for ID: user-alice]
- Works on the APAC sales team
- Prefers concise bullet-point summaries
- Last session: asked about Q3 pricing strategy
```

---

## Step 3 — Seed initial facts (optional)

Ingest known facts before the first conversation:

```python
requests.post(
    "https://api.routero.ai/memory/session/add",
    headers={"Authorization": f"Bearer {ADMIN_KEY}"},
    json={
        "memory_id": memory_id,
        "messages": [
            {"role": "user", "content": "My name is Alice and I lead APAC sales."}
        ],
    },
)
```

---

## Step 4 — Skip storage for sensitive turns

If a turn contains personal data the user doesn't want remembered:

```python
response = client.chat.completions.create(
    model="smart/balanced",
    messages=[...],
    extra_body={
        "memory_id": memory_id,
        "store_memory": False,   # retrieve context but don't store this turn
    },
)
```

---

## Viewing and managing stored facts

```bash
# List all stored facts for a user
GET /memory/session/{memory_id}/facts

# Delete a specific fact (e.g., user data deletion request)
DELETE /memory/session/{memory_id}/facts/{fact_id}

# Delete the entire session (GDPR right to erasure)
DELETE /memory/session/{memory_id}
```

Deletion is atomic across Postgres and the pgvector index.
