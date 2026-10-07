---
lang: en
page_id: integration/zcode
title: ZCode
parent: Integration
nav_order: 5
description: "Connect the ZCode coding agent to Routero as an OpenAI-compatible provider — base URL, API key, and model list."
---

# ZCode

Connect the **ZCode** coding agent to Routero so its model calls run through your gateway — attributed, budgeted, and logged — while ZCode keeps handling repository access and file edits locally.

ZCode connects through a custom **OpenAI-compatible provider** that talks the Chat Completions API (`/chat/completions`).

---

## What you must set

In ZCode, open **Settings** → **Model settings** → **Add provider** → **OpenAI**:

| Setting | Value |
|---|---|
| Base URL | `{{ site.api_base_url }}/v1` |
| API format | Chat completions (`/chat/completions`) |
| API key | a Routero virtual key |
| Model list | add each model Routero serves, e.g. `deepseek/deepseek-v4-flash` |

Then switch the model in the main dialog to the provider/model pair you just added (e.g. `OpenAI/deepseek/deepseek-v4-flash`) and send a test prompt.

{: .note }
Only models added to the provider's model list are selectable. Add every model string your team is approved to use — any model Routero serves works.

---

## Create a key for each developer

In the dashboard, open **API Keys** and create a virtual key per developer — scoped to their team, limited to the approved models, with an optional budget. Each developer's ZCode traffic is then attributed individually, and requests appear in **Logs** routed through Routero rather than straight to the underlying provider.

---

## Gateway policies on ZCode traffic

Policy-bound AI capabilities attached to the key apply to ZCode traffic:

- **Prompt management** — injected instructions are honored.
- **Guardrails** — enforced per request. Switching a guardrail between **Block** and **Monitor** takes effect on subsequent requests without restarting the conversation; blocked requests surface as `Request blocked by content filter.`
- **Token saving** — exact and semantic caching both apply.

---

## Related

→ [Calling the API]({% link integration/api-calling.md %}) for the base URL and auth model.
→ [Claude Code]({% link integration/claude-code.md %}), [Kimi Code]({% link integration/kimi-code.md %}), and [Codex]({% link integration/codex.md %}) for the other agents.
