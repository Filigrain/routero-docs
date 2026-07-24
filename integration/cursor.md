---
lang: en
page_id: integration/cursor
title: Cursor
parent: Integration
nav_order: 2
description: "Route Cursor through Routero for governance, cost tracking, and policy enforcement on your AI coding assistant."
---

# Cursor

Route Cursor through Routero to bring your AI coding assistant under the same governance, cost tracking, and policy enforcement as your production applications — every completion is attributed, budgeted, and logged.

**Why route Cursor through Routero:**

- **Cost visibility** — see who uses which models, at what cost, across which teams.
- **Policy enforcement** — block models or providers that aren't approved for source code.
- **Audit trail** — a complete log of every coding-assistant call.
- **Budget limits** — cap per-developer or per-team spend on AI tooling.
- **Provider fallback** — Cursor stays available even if one provider is rate-limited.

---

## 1. Create a virtual key

In the dashboard, open **API Keys** and create a virtual key to use as Cursor's API key. Scope it to the developer's team, restrict it to the approved models, and optionally attach a budget so individual spend is attributable.

---

## 2. Point Cursor at Routero

1. Open **Cursor Settings** → **Models** → **OpenAI API Key**.
2. Paste your Routero virtual key as the API key.
3. Set the **Base URL** to `https://api.routero.ai/v1`.
4. Choose your models — any model string Routero supports works, including `openai/gpt-5.5`.

Cursor now routes all of its LLM calls through Routero.

---

## Related

→ [Calling the API]({% link integration/api-calling.md %}) for the base URL, auth, and SDK examples.
→ [Claude Code]({% link integration/claude-code.md %}) for the Anthropic CLI.
