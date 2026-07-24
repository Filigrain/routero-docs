---
lang: en
page_id: integration/claude-code
title: Claude Code
parent: Integration
nav_order: 3
description: "Connect the Claude Code CLI to Routero — base URL, auth token, and model-slot mapping, via env vars or settings.json."
---

# Claude Code

Connect the **Claude Code** CLI (Anthropic's `claude`) to Routero so its calls run through your gateway — attributed, budgeted, and logged alongside your production traffic.

Claude Code talks the **Anthropic Messages API** and has three internal model slots (haiku, sonnet, opus). Connecting it takes three things: the **base URL**, an **auth token**, and a **mapping** of those slots to models Routero serves.

{: .note }
Why map the slots? Claude Code assumes Anthropic model names (`claude-sonnet-*`, `claude-opus-*`, …). Pointing those slots at model names Routero serves makes every request route through your gateway correctly.

---

## What you must set

| Setting | Value |
|---|---|
| `ANTHROPIC_BASE_URL` | `https://api.routero.ai` |
| `ANTHROPIC_AUTH_TOKEN` | a Routero virtual key (sent as `Authorization: Bearer`) |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | a Routero model for light / background tasks |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | a Routero model for the main session |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | a Routero model for heavy reasoning |

Use `ANTHROPIC_AUTH_TOKEN` (Bearer) rather than `ANTHROPIC_API_KEY` — Routero virtual keys are Bearer tokens, and this is the header the gateway reads.

---

## Option A — settings.json (recommended)

Edit `~/.claude/settings.json` and put the values in the `env` block. The config then travels with the tool and applies to every session:

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.routero.ai",
    "ANTHROPIC_AUTH_TOKEN": "YOUR_ROUTERO_KEY",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "openai/gpt-5.5",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "openai/gpt-5.5",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "openai/gpt-5.5"
  }
}
```

## Option B — environment variables

Export the same values in your shell (`~/.zshrc`, `~/.bashrc`), then run `claude`:

```bash
export ANTHROPIC_BASE_URL="https://api.routero.ai"
export ANTHROPIC_AUTH_TOKEN="YOUR_ROUTERO_KEY"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="openai/gpt-5.5"
export ANTHROPIC_DEFAULT_SONNET_MODEL="openai/gpt-5.5"
export ANTHROPIC_DEFAULT_OPUS_MODEL="openai/gpt-5.5"
```

{: .note }
You can mix models — for example, map the heavy `opus` slot to a strong reasoning model and `haiku` to a cheap fast one. Any model string Routero serves works, including `openai/gpt-5.5` or a specific provider model.

---

## Create a key for each developer

In the dashboard, open **API Keys** and create a virtual key per developer — scoped to their team, limited to the approved models, with an optional budget. Each developer's Claude Code traffic is then attributed individually.

---

## Related

→ [Calling the API]({% link integration/api-calling.md %}) for the base URL and auth model.
→ [Codex]({% link integration/codex.md %}) and [Cursor]({% link integration/cursor.md %}) for the other agents.
