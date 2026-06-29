---
lang: en
page_id: agents/a2a-gateway
title: A2A Agent Gateway
parent: Agents & Tools
nav_order: 1
description: "Proxy and govern Agent-to-Agent (A2A) protocol agents through Routero's auth and cost layer."
---

# A2A Agent Gateway

{: .beta }
> The A2A Agent Gateway is in **beta**. APIs and behaviour may change. Contact your solutions engineer before building production workflows on A2A endpoints.

The A2A Agent Gateway lets you register, invoke, and govern AI agents that implement the [Agent-to-Agent (A2A) protocol](https://google.github.io/A2A/). Every agent invocation passes through Routero's auth, cost tracking, and policy layer — the same pipeline as LLM requests.

---

## How it works

1. Register an external A2A agent (by its card URL) in Routero. Routero rewrites the agent's card to point back to the gateway.
2. Callers invoke the agent via Routero: `POST /a2a/{agent_id}` or `POST /v1/a2a/{agent_id}/message/send`.
3. Routero validates the caller's key, checks permissions, proxies the request to the upstream agent, logs cost and usage, and streams the response back.

Because all traffic routes through the gateway, agent invocations appear in your audit log, spend dashboard, and rate-limit counters alongside standard LLM requests.

---

## Agent management

```bash
# Register an A2A agent
POST /v1/agents
{ "agent_name": "my-agent", "agent_card_url": "https://agent.example.com/.well-known/agent.json" }

# List registered agents
GET /v1/agents

# Make public (accessible without a Routero key)
POST /v1/agents/{agent_id}/make_public
```

---

## Inference endpoints

| Endpoint | Description |
|---|---|
| `GET /a2a/{agent_id}/.well-known/agent-card.json` | Agent discovery card (rewritten to point at proxy) |
| `POST /a2a/{agent_id}` | JSON-RPC 2.0 invoke |
| `POST /a2a/{agent_id}/message/send` | A2A message/send |
| `POST /v1/a2a/{agent_id}/message/send` | A2A message/send (v1 alias) |

Streaming via `message/stream` is supported (ndjson).

---

## Coming soon

Full documentation including authentication patterns, per-agent budgets, and A2A tool integration is being written. [Contact us](https://routero.ai/demo.html) for early-access guidance.
