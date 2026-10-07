---
lang: en
page_id: integration/codex
title: Codex
parent: Integration
nav_order: 4
description: "Connect the OpenAI Codex CLI to Routero via a custom model provider in config.toml."
---

# Codex

Connect the **Codex** CLI (OpenAI's `codex`) to Routero by defining a **custom model provider** in its config. Codex then sends every request through your gateway.

Codex supports two wire formats — `chat` (`/chat/completions`) and `responses` (`/responses`). Routero supports both; `responses` is recommended for Codex.

---

## What you must set

In `~/.codex/config.toml`:

```toml
model_provider = "routero"
model = "openai/gpt-5.5"

[model_providers.routero]
name = "routero"
base_url = "{{ site.api_base_url }}/v1"
env_key = "OPENAI_API_KEY"
wire_api = "responses"
```

Then provide your Routero key as the API key:

```bash
export OPENAI_API_KEY="YOUR_ROUTERO_KEY"
```

| Setting | Value / meaning |
|---|---|
| `model_provider` | the name of the `[model_providers.*]` block below (`routero`) |
| `model` | any model Routero serves (e.g. `openai/gpt-5.5`) |
| `env_key` | `OPENAI_API_KEY` — the env var Codex reads your Routero virtual key from and sends as `Authorization: Bearer` |
| `base_url` | `{{ site.api_base_url }}/v1` |
| `wire_api` | `responses` (recommended) or `chat` |
| `OPENAI_API_KEY` | your Routero virtual key, not an OpenAI key |

{: .note }
For a custom provider, Codex sends the key named by `env_key`. Without `env_key`, the key is never attached and Routero returns `401 Unauthorized: No api key passed in`.

{: .note }
`preferred_auth_method = "apikey"`, sometimes cited for API-key auth, is **not recognized** by recent Codex versions (verified against Codex CLI v0.157.1, which warns it is an unknown config key and ignores it). On older releases it may still be accepted; it is harmless to remove.

---

## Create a key for each developer

In the dashboard, open **API Keys** and create a virtual key per developer — scoped to their team, limited to the approved models, with an optional budget.

---

## Related

→ [Calling the API]({% link integration/api-calling.md %}) for the base URL and auth model.
→ [Claude Code]({% link integration/claude-code.md %}) and [Cursor]({% link integration/cursor.md %}) for the other agents.
