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
preferred_auth_method = "apikey"

[model_providers.routero]
name = "routero"
base_url = "https://api.routero.ai/v1"
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
| `preferred_auth_method` | `apikey` — authenticate with an API key, not ChatGPT login |
| `base_url` | `https://api.routero.ai/v1` |
| `wire_api` | `responses` (recommended) or `chat` |
| `OPENAI_API_KEY` | your Routero virtual key (sent as `Authorization: Bearer`) |

{: .note }
`preferred_auth_method = "apikey"` tells Codex to authenticate with `OPENAI_API_KEY` instead of ChatGPT sign-in. Set that env var to your **Routero virtual key**, not an OpenAI key.

---

## Create a key for each developer

In the dashboard, open **API Keys** and create a virtual key per developer — scoped to their team, limited to the approved models, with an optional budget.

---

## Related

→ [Calling the API]({% link integration/api-calling.md %}) for the base URL and auth model.
→ [Claude Code]({% link integration/claude-code.md %}) and [Cursor]({% link integration/cursor.md %}) for the other agents.
