---
lang: en
page_id: integration
title: Integration
nav_order: 10
has_children: true
description: "Get connected to Routero — call the API directly, or connect Cursor, Claude Code, and Codex."
---

# Integration

Get connected to Routero. The gateway is fully **OpenAI-compatible** (and also speaks the Anthropic Messages API), so connecting is mostly a matter of pointing your tools at the right base URL with a virtual key.

- **OpenAI base URL:** `https://api.routero.ai/v1`
- **Anthropic base URL:** `https://api.routero.ai`

---

## In this section

- [Calling the API]({% link integration/api-calling.md %}) — base URL, authentication, and request examples in any language.
- [Cursor]({% link integration/cursor.md %}) — route the Cursor editor through Routero.
- [Claude Code]({% link integration/claude-code.md %}) — route the Claude Code CLI through Routero (base URL + model-slot mapping).
- [Codex]({% link integration/codex.md %}) — route the Codex CLI through Routero via a custom model provider.

{: .note }
Other OpenAI-compatible agents — Cline, Continue, Aider, GitHub Copilot, Windsurf, and the rest — work the same way: point the tool's base URL at Routero and use a virtual key. See [Calling the API]({% link integration/api-calling.md %}).

---

## Related

→ [Unified API]({% link core-gateway/unified-api.md %}) for the full endpoint surface and how model routing works.
