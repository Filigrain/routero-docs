---
lang: en
page_id: index
title: Introduction
nav_order: 1
description: "What Routero AI is, why enterprises choose it, and how to navigate this documentation."
---

# Introduction to Routero AI

{: .tagline }
**Every AI model. One router you can trust.**

Routero AI is an **enterprise AI control plane** — a unified gateway that sits between your applications and every AI provider. It gives platform, security, and FinOps teams the governance layer they need to ship AI features with confidence, while letting developers use the OpenAI SDK they already know.

Change `base_url` in one line of code. Get 100+ models, smart routing, built-in failover, capability policies, spend controls, and a complete audit trail — with data exactly where your security team requires.

> *"We replaced four gateways and a 600-line failover hack with one Routero AI config."*

---

## The enterprise problem

Shipping AI in production means clearing three hurdles before a single prompt touches a user:

1. **Security & compliance** — Which models can touch sensitive data? Who approved this? What went through the system last Tuesday?
2. **Cost accountability** — Which team is spending what? Who gets the bill when the model runs overnight by mistake?
3. **Operational reliability** — What happens when GPT-4o rate-limits at 2 am? Can we swap providers without a deploy?

Routero AI is purpose-built for all three — with a control plane your security team can review, your FinOps team can report on, and your platform team can operate without building it from scratch.

{: .note }
Routero charges for the control plane, not for tokens. Provider costs are passed through at list price with zero markup. Every charge is accountable and tied to an operational purpose.

---

## One request, four decisions

Every request runs a deterministic, auditable pipeline:

```
Your app
  → [Auth & access]         virtual key · model access · budget guard
  → [Routing]               Auto Router (optional) → strategy picks a healthy deployment
  → [Capabilities]          policy injects guardrails · prompts · memory · token saving
  → [Account & audit]       token/$ debited atomically · decision logged
  → Provider
```

Every decision is logged and reproducible months later.

---

## Four building blocks

Routero is composed of four composable primitives. Use one or all — they are independent.

### Routing & Failover
Named model groups, pluggable routing strategies, and an optional **Auto Router** that picks the best model for each message by intent. Ordered provider fallbacks automatically retry on 5xx, rate limits, or content-filter trips — streaming-aware, no dropped chunks.

[→ Routing & Load Balancing]({% link core-gateway/routing.md %}) · [Auto Router]({% link core-gateway/auto-router.md %}) · [Failover & Fallbacks]({% link core-gateway/failover.md %})

### Policies
Bundle guardrails, prompts, memory, and token-saving plans into a named policy and bind it to a key or model. The capabilities activate automatically on every matching request — no per-request IDs in your application code.

[→ Policies]({% link core-gateway/policies.md %})

### Budgets & Spend Guards
Hard ceilings, soft alerts, and per-team chargeback for every dollar of AI spend. Warn at 80 %, auto-throttle at 100 %, block if you mean it. Finance gets one consolidated invoice; each team gets attributed line items.

[→ Budgets & Spend Guards]({% link core-gateway/budgets.md %})

### Access Control & Audit
Admin-invite access · Cerbos fine-grained authorization · short-lived scoped virtual keys · an audit log of every key, user, model, and policy change.

[→ Access Control & Audit]({% link core-gateway/sso-rbac-audit.md %})

---

## Deployment: pick your trust boundary

The same control plane runs in four configurations. Your security team picks where data lives.

| Deployment | Best for | Where data lives |
|---|---|---|
| **Routero Cloud** | Fastest onboarding, elastic scale | Routero's AWS (Singapore), SOC 2 |
| **Single-Tenant Cloud** | Dedicated region, physical isolation, data residency | Your chosen region, Routero-managed |
| **Private Deployments** | VPC isolation, full key control, air-gap-ready | Entirely your infrastructure |
| **Local** | Development, evaluation, air-gapped CI | Your machine |

[→ Deployment Options]({% link deployment.md %})

---

## AI Capabilities — the production AI layer

Beyond routing and governance, Routero ships four opt-in capabilities that production AI systems typically build themselves. Activate each by passing a single ID on any request — no payload restructuring, no new endpoints.

| Feature | What it does |
|---|---|
| [**Token Saving**]({% link advanced-features/token-saving.md %}) | Prompt compression + exact & semantic response caching — reduce compute cost without changing application code |
| [**Guardrails**]({% link advanced-features/guardrails.md %}) | Content filtering · PII redaction (Presidio) · secret detection · tool allow/deny lists — centrally managed, per-org enforced |
| [**Prompt Management**]({% link advanced-features/prompt-management.md %}) | Central prompt registry with immutable versioning, Jinja2 templates, two-layer caching, and instant rollback |
| [**Memory-as-a-Service**]({% link advanced-features/memory-service.md %}) | Long-term memory via Mem0 (vector) and Cognee (knowledge graph) — automatically retrieved and injected per request |

[→ AI Capabilities]({% link advanced-features.md %})

---

## Who this documentation is for

**Platform & infrastructure engineers** — building the AI plumbing.
Start with [Quickstart]({% link quickstart.md %}) then [Deployment Options]({% link deployment.md %}).

**Security & compliance** — reviewing and approving.
Start with [Access Control & Audit]({% link core-gateway/sso-rbac-audit.md %}), [Compliance]({% link security-trust/compliance.md %}), and [Deployment Options]({% link deployment.md %}).

**FinOps & engineering managers** — owning the bill.
Start with [Budgets & Spend Guards]({% link core-gateway/budgets.md %}) and [Cost Tracking & Billing]({% link core-gateway/cost-tracking.md %}).

**Developers** — calling the API.
Start with [Quickstart]({% link quickstart.md %}) and [Unified API]({% link core-gateway/unified-api.md %}).
