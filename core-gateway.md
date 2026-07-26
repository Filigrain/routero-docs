---
lang: en
page_id: core-gateway
title: LLM Gateway
nav_order: 4
has_children: true
description: "The four building blocks of the Routero AI control plane: Routes, Policies, Budgets, and Audit."
---

# LLM Gateway

The LLM Gateway is Routero AI's unified proxy — an OpenAI-compatible interface in front of 100+ providers, with four composable governance primitives built in.

---

## Pages in this section

- [Routing & Load Balancing]({% link core-gateway/routing.md %}) — strategies, model groups, and the Router
- [Auto Router]({% link core-gateway/auto-router.md %}) — intent-based model selection by message content
- [Failover & Fallbacks]({% link core-gateway/failover.md %}) — multi-provider failover chains
- [Policies]({% link core-gateway/policies.md %}) — bundle guardrails, prompts, memory, and token saving into a named policy
- [Bring Your Own Key (BYOK)]({% link core-gateway/byok.md %}) — use your own provider keys; you pay the provider directly, Routero charges markup only
