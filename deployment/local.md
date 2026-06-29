---
title: Local Deployment
parent: Deployment Options
nav_order: 5
description: "Run Routero AI on a single machine for local development, evaluation, or air-gapped environments."
---

# Local Deployment

The fastest way to run Routero AI on your own machine — for evaluating the platform, local development, or air-gapped environments that need the full control plane without a cloud dependency.

---

## When to choose this

- **Evaluation** — explore Routero's routing, policy, and Advanced Features before committing to a cloud deployment.
- **Local development** — run the gateway alongside your application during development so your dev environment matches production.
- **Air-gapped / offline** — environments with no outbound internet access. Models are served from local endpoints (e.g. Ollama); the gateway enforces the same policies as cloud.
- **CI/CD integration testing** — spin up the gateway in a pipeline to integration-test your application against a real Routero instance.

{: .note }
Local Deployment is not intended for production traffic. For production, use [Routero Cloud]({% link deployment/cloud.md %}), [Single-Tenant Cloud]({% link deployment/single-tenant.md %}), or [Private Deployments]({% link deployment/private.md %}).

---

## What you need

| Component | Requirement |
|---|---|
| **Postgres** | v14+ with pgvector (for audit log and key storage) |
| **Redis** | v7+ (rate limiting and caching) |
| **Routero proxy** | Container image — provided in the deployment package |
| **Admin key** | A `MASTER_KEY` you choose; used to authenticate management API calls |

No cloud account, no Terraform, no external services required. All traffic stays on your machine.

---

## Capabilities in local mode

All Routero features work locally with no configuration changes required:

| Feature | Works locally |
|---|---|
| Routing, failover, load balancing | ✓ |
| Policy routing (YAML rules) | ✓ |
| Budgets and spend tracking | ✓ |
| Virtual API keys and orgs | ✓ |
| Guardrails (including Presidio PII) | ✓ |
| Prompt Management | ✓ |
| Token Saving (compression + caching) | ✓ |
| Memory-as-a-Service (Mem0 / Cognee) | ✓ with pgvector |
| Admin console | ✓ served locally at `/_experimental/out/` |

Local model endpoints (Ollama, LM Studio, vLLM, any OpenAI-compatible server) are supported as first-class providers — add them under **Models → Provider Keys** in the admin console.

---

## Getting the deployment package

Contact [solutions@routero.ai](mailto:solutions@routero.ai) to receive:

- Container image access (private registry)
- `docker-compose.local.yml` quick-start for getting Postgres + Redis + the proxy running in minutes
- License key for local use

→ [Reference Architecture]({% link deployment/reference-architecture.md %}) for the full component topology · [Advanced Features]({% link advanced-features.md %}) to explore what's available once running
