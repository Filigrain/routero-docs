---
lang: en
page_id: advanced-features/prompt-management
title: Prompt Management
parent: AI Capabilities
nav_order: 3
description: "Central prompt registry with immutable versioning, Jinja2 templates, and instant rollback."
---

# Prompt Management

Prompt Management decouples prompt engineering from application deploys. Prompt teams maintain templates in a central registry with full version history; applications reference a stable `prompt_id` that never changes, even as the underlying template evolves.

{: .note }
Routero's Prompt Management is a **DB-backed registry owned by your workspace** — distinct from provider-side "prompt caching" features and from third-party integrations like Langfuse or dotprompt.

---

## Activation

```python
response = client.chat.completions.create(
    model="smart/balanced",
    messages=[{"role": "user", "content": "Summarise Q3 results"}],
    extra_body={
        "prompt_id": "analyst-system-v2",
        "prompt_variables": {
            "company": "Acme Corp",
            "language": "English",
            "tone": "executive"
        },
        # Optional: pin to a specific version
        # "prompt_version": 3
    },
)
```

The gateway fetches the latest version of `analyst-system-v2`, renders the Jinja2 variables, and **prepends the rendered messages** to the request before forwarding to the provider. The `prompt_id` is stripped — the upstream never sees it.

---

## Concepts

**`prompt_id`** — A stable UUID assigned when the prompt is first created. This is what callers store and pass. It does not change across versions.

**Version** — Every `PUT /prompts/{name}` creates an immutable new version. Old versions are retained and pinnable via `prompt_version`. The `is_latest` flag tracks the current head.

**Template** — A `messages` array (`[{"role": "system", "content": "..."}, ...]`) with optional Jinja2 variables. Missing variables render as empty strings (no error).

---

## Creating and versioning prompts

```bash
# Create a prompt (version 1)
curl -X POST https://api.routero.ai/prompts \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt_name": "analyst-system-v2",
    "messages": [
      {
        "role": "system",
        "content": "You are a financial analyst at {{ company }}. Respond in {{ language }} with a {{ tone }} tone. Be concise and data-driven."
      }
    ],
    "variables": ["company", "language", "tone"]
  }'

# Update (creates version 2, retains version 1)
curl -X PUT https://api.routero.ai/prompts/analyst-system-v2 \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{
    "messages": [
      {
        "role": "system",
        "content": "You are a senior financial analyst at {{ company }}. ..."
      }
    ]
  }'
```

---

## Rollback

Pin any request to a prior version:
```python
extra_body={"prompt_id": "analyst-system-v2", "prompt_version": 1}
```

Or point all traffic back to version 1 by re-issuing a PUT that sets version 1's content as the new latest.

---

## Caching

Prompt templates are cached in two layers:
- **In-process cache** — 5-minute TTL per proxy instance
- **Redis cache** — 1-day TTL, shared across all proxy replicas

Changes apply to traffic within seconds of the TTL expiry. Cache is invalidated immediately on `DELETE`.

---

## Org scoping

Prompts belong to the organization of the creating key. A key from org A cannot resolve a prompt from org B. Prompts with a null org are **global** — accessible to all org keys in the workspace (useful for shared company standards). Proxy admins can access all prompts.

---

## Management API

| Endpoint | Description |
|---|---|
| `POST /prompts` | Create a prompt (409 on duplicate name in org) |
| `GET /prompts` | List all prompts in workspace |
| `GET /prompts/{prompt_id}` | Get latest version (add `?version=N` to pin) |
| `GET /prompts/{prompt_id}/versions` | List all versions |
| `PUT /prompts/{name}` | Create next version (immutable) |
| `DELETE /prompts/{name}` | Delete all versions of a prompt |
