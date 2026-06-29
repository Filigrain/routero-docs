---
title: Self-Hosted with Docker
parent: Deployment Options
nav_order: 4
nav_exclude: true
description: "Run Routero AI locally or on-prem using Docker Compose — minimal footprint, full control."
---

# Self-Hosted with Docker

The lightest deployment path. Bring up the full Routero AI gateway with Docker Compose — suitable for on-prem, single-node production, air-gap evaluation, or as the base for a custom container orchestrator.

---

## Minimum viable stack

The bare minimum to run the gateway: the proxy container + a Postgres database.

```yaml
# docker-compose.minimal.yml
services:
  litellm:
    image: ghcr.io/filigrain/routero-proxy:latest
    ports:
      - "4000:4000"
    environment:
      MASTER_KEY: "your-master-key"
      DATABASE_URL: "postgresql://user:pass@db:5432/litellm"
    depends_on: [db]

  db:
    image: pgvector/pgvector:pg16
    environment:
      POSTGRES_DB: litellm
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  pgdata:
```

```bash
docker compose -f docker-compose.minimal.yml up -d
```

The dashboard is available at `http://localhost:4000/_experimental/out/`. Add your first model and API key there.

---

## Full stack (recommended for production)

The bundled `docker-compose.yml` includes the proxy, coworker spend-sync service, Postgres (pgvector), Redis, and Prometheus:

```bash
git clone https://github.com/Filigrain/llmrouter.git
cd llmrouter/cicd/compose
MASTER_KEY=your-secret-key docker compose up -d
```

**Services started:**

| Service | Port | Purpose |
|---|---|---|
| `litellm` (proxy) | 4000 | Gateway — inference + management API |
| `coworker` | 8001 | Spend-sync worker (Redis → Postgres) |
| `db` | 5432 | Postgres + pgvector (keys, spend, config) |
| `redis` | 6379 | Rate limiting, key cache, spend queue |
| `prometheus` | 9090 | Metrics scraping |

---

## Enable Advanced Features (memory tier)

The memory tier (required for [Memory-as-a-Service]({% link advanced-features/memory-service.md %}) and semantic caching in [Token Saving]({% link advanced-features/token-saving.md %})) runs as an optional Compose profile:

```bash
docker compose --profile semantic up -d
```

This adds:
- `neo4j` — graph database for Cognee long-term memory
- `qdrant` — vector store for semantic caching
- `redis-stack` — Redis with vector search for semantic caching
- `mem0_db` / `cognee_db` — dedicated Postgres instances for Mem0 and Cognee

---

## Required environment variables

| Variable | Required | Description |
|---|---|---|
| `MASTER_KEY` | Yes | Admin key for the proxy — keep secret |
| `DATABASE_URL` | Yes | Postgres connection string |
| `REDIS_URL` | No | Redis for caching and rate limiting |
| `LITELLM_PROXY_BASE_URL` | No | Public base URL of this instance (for memory/cache loopback) |
| `USE_DDTRACE` | No | Set to `true` to enable Datadog APM tracing |
| `SEPARATE_HEALTH_APP` | No | Run health endpoints on a separate port |

---

## Notes

- The proxy and coworker images run as **non-root** users.
- This deployment has **no built-in HA or autoscaling** — the customer is responsible for process supervision, DB durability, and horizontal scaling.
- For production use with multiple replicas, use a shared external Postgres and Redis, and run multiple proxy containers behind a load balancer.
- For the full AWS-native HA topology, see [Self-Hosted on AWS]({% link deployment/self-hosted-aws.md %}).
