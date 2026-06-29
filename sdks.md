---
lang: en
page_id: sdks
title: SDKs
nav_order: 9
has_children: true
description: "Client libraries and drop-in replacements for calling Routero AI."
---

# SDKs

Routero AI is designed to work with the SDKs your team already uses. The gateway exposes a fully OpenAI-compatible interface, so any OpenAI SDK in any language works out of the box with a single `base_url` change.

---

## Pages in this section

- [Python SDK]({% link sdks/python.md %}) — using the `litellm` library for in-process routing (no proxy required)
- [OpenAI-Compatible Clients]({% link sdks/openai-compatible.md %}) — using any OpenAI SDK (Python, TypeScript, Go, …) with Routero as the backend
