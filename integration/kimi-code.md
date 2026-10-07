---
lang: en
page_id: integration/kimi-code
title: Kimi Code
parent: Integration
nav_order: 6
description: "Connect Kimi Code to Routero as a custom OpenAI-protocol provider — base URL, API key, model ID, and context size."
---

# Kimi Code

Connect **Kimi Code** to Routero so its model calls run through your gateway — attributed, budgeted, and logged — while Kimi Code keeps handling repository access and file edits locally.

Kimi Code connects through a **custom provider** speaking the OpenAI protocol.

---

## What you must set

In Kimi Code, open **Settings** → **Providers** → **Add provider** → **Custom**:

| Setting | Value |
|---|---|
| Name | `Routero` |
| API protocol | `OpenAI` |
| API Key | a Routero virtual key |
| Base URL | `{{ site.api_base_url }}/v1` |
| Model ID | a model Routero serves, e.g. `deepseek/deepseek-v4-flash` |
| Max context size | the model's context window, e.g. `128000` |
| Display name | anything recognizable, e.g. `Routero DeepSeek V4 Flash` |

Save the provider, then select its model in Kimi Code and send a test prompt.

{: .note }
Add one provider entry per model you plan to use — each custom provider carries a single Model ID. Any model string Routero serves works.

---

## Create a key for each developer

In the dashboard, open **API Keys** and create a virtual key per developer — scoped to their team, limited to the approved models, with an optional budget. Each developer's Kimi Code traffic is then attributed individually, and requests appear in **Logs** routed through Routero rather than straight to the underlying provider.

---

## Gateway policies on Kimi Code traffic

Policy-bound AI capabilities attached to the key apply to Kimi Code traffic:

- **Guardrails** — enforced per request, including changes made mid-conversation: switching a guardrail from **Monitor** to **Block** takes effect on the next request, and Kimi Code surfaces the block clearly as `400 Request blocked by content filter.`
- **Token saving** — repeated prompts hit the exact cache; semantically equivalent rewrites hit the semantic cache.
- **Memory** — a memory session bound through the key's policy is read and written: stored facts are retrieved in new conversations, and new facts stated in a conversation are stored to Routero automatically.

---

## Related

→ [Calling the API]({% link integration/api-calling.md %}) for the base URL and auth model.
→ [Claude Code]({% link integration/claude-code.md %}), [ZCode]({% link integration/zcode.md %}), and [Codex]({% link integration/codex.md %}) for the other agents.
