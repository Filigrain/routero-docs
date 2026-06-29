---
title: Add to Cursor / Claude Code
parent: Guides
nav_order: 2
description: "Route Cursor and Claude Code through Routero for governance, cost tracking, and policy enforcement."
---

# Add to Cursor / Claude Code

Route AI coding assistants through Routero to bring developer tool usage under the same governance, cost tracking, and policy enforcement as your production applications.

---

## Why route your coding assistant through Routero?

- **Cost visibility** — who's using what models, at what cost, across which teams
- **Policy enforcement** — block models or providers that aren't approved for source code
- **Audit trail** — immutable log of all code-assistant calls (useful for IP and data-handling policies)
- **Budget limits** — cap individual developer or team spend on AI tooling
- **Provider fallback** — coding assistant stays available even if one provider is rate-limited

---

## Cursor

1. Open **Cursor Settings** → **Models** → **OpenAI API Key** section.
2. Paste your Routero virtual key as the API key.
3. Set the **Base URL** to `https://api.routero.ai/v1`.
4. Choose your models — any model string Routero supports works, including `smart/balanced`.

Cursor will route all its LLM calls through Routero from this point on.

---

## Claude Code (Anthropic CLI)

Set the environment variables before invoking `claude`:

```bash
export ANTHROPIC_API_KEY="YOUR_ROUTERO_KEY"
export ANTHROPIC_BASE_URL="https://api.routero.ai/v1"
claude
```

Or add to your shell profile (`~/.zshrc`, `~/.bashrc`):

```bash
export ANTHROPIC_API_KEY="YOUR_ROUTERO_KEY"
export ANTHROPIC_BASE_URL="https://api.routero.ai/v1"
```

{: .note }
Claude Code still uses the `ANTHROPIC_API_KEY` variable name, but with `ANTHROPIC_BASE_URL` pointing at Routero, all calls route through the gateway. The key you supply should be your Routero virtual key, not an Anthropic key directly.

---

## Generate a per-developer key

Give each developer their own scoped virtual key so spend is attributed individually:

```bash
curl -X POST https://api.routero.ai/key/generate \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{
    "team_id": "engineering",
    "models": ["smart/balanced", "anthropic/claude-sonnet-4-6-20250514"],
    "max_budget": 50,
    "budget_duration": "1mo",
    "key_alias": "dev-alice-cursor",
    "metadata": {"developer": "alice@company.com"}
  }'
```

Per-developer spend appears in the team dashboard alongside production API spend.
