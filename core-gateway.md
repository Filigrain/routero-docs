---
lang: en
page_id: core-gateway
title: Core Gateway
nav_order: 4
has_children: true
description: "The four building blocks of the Routero AI control plane: Routes, Policies, Budgets, and Audit."
---

# Core Gateway

The core gateway is Routero AI's unified LLM proxy — an OpenAI-compatible interface in front of 100+ providers, with four composable governance primitives built in.

---

## Pages in this section

- [Unified API]({% link core-gateway/unified-api.md %}) — every supported endpoint and provider
- [Routing & Load Balancing]({% link core-gateway/routing.md %}) — strategies, model groups, and the Router
- [Auto Router]({% link core-gateway/auto-router.md %}) — intent-based model selection by message content
- [Failover & Fallbacks]({% link core-gateway/failover.md %}) — multi-provider failover chains
- [Policies]({% link core-gateway/policies.md %}) — bundle guardrails, prompts, memory, and token saving into a named policy
- [Budgets & Spend Guards]({% link core-gateway/budgets.md %}) — hard caps, soft alerts, FinOps chargeback
- [Access Control & Audit]({% link core-gateway/sso-rbac-audit.md %}) — admin-invite · Cerbos · audit log
- [Multi-Tenancy]({% link core-gateway/multi-tenancy.md %}) — orgs · teams · users · customers
- [Cost Tracking & Billing]({% link core-gateway/cost-tracking.md %}) — per-request cost pipeline, wallet, invoices
