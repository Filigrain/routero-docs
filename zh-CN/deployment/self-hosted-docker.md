---
lang: zh-CN
page_id: deployment/self-hosted-docker
permalink: /deployment/self-hosted-docker.html
title: 使用 Docker 自托管
parent: 部署选项
nav_order: 4
nav_exclude: true
description: "使用 Docker Compose 在本地或本地环境（on-prem）运行 Routero AI——占用最小，完全可控。"
---

# 使用 Docker 自托管

最轻量的部署方式。使用 Docker Compose 启动完整的 Routero AI 网关——适用于本地环境（on-prem）、单节点生产、离网（air-gap）评估，或作为自定义容器编排器的基础。

---

## 最小可用堆栈

运行网关所需的最低配置：代理容器 + 一个 Postgres 数据库。

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

控制台可在 `http://localhost:4000/_experimental/out/` 访问。在那里添加你的第一个模型和 API 密钥。

---

## 完整堆栈（推荐用于生产）

捆绑的 `docker-compose.yml` 包含代理、coworker 支出同步服务、Postgres（pgvector）、Redis 和 Prometheus：

```bash
git clone https://github.com/Filigrain/llmrouter.git
cd llmrouter/cicd/compose
MASTER_KEY=your-secret-key docker compose up -d
```

**启动的服务：**

| 服务 | 端口 | 用途 |
|---|---|---|
| `litellm`（代理） | 4000 | 网关——推理 + 管理 API |
| `coworker` | 8001 | 支出同步工作进程（Redis → Postgres） |
| `db` | 5432 | Postgres + pgvector（密钥、支出、配置） |
| `redis` | 6379 | 限流、密钥缓存、支出队列 |
| `prometheus` | 9090 | 指标抓取 |

---

## 启用高级功能（记忆层）

记忆层（[记忆即服务]({% link zh-CN/advanced-features/memory-service.md %})以及 [Token 节省]({% link zh-CN/advanced-features/token-saving.md %})中的语义缓存所必需）作为一个可选的 Compose profile 运行：

```bash
docker compose --profile semantic up -d
```

这会新增：
- `neo4j` —— 用于 Cognee 长期记忆的图数据库
- `qdrant` —— 用于语义缓存的向量存储
- `redis-stack` —— 带向量搜索的 Redis，用于语义缓存
- `mem0_db` / `cognee_db` —— 分别用于 Mem0 和 Cognee 的专用 Postgres 实例

---

## 必需的环境变量

| 变量 | 是否必需 | 描述 |
|---|---|---|
| `MASTER_KEY` | 是 | 代理的管理密钥——请保密 |
| `DATABASE_URL` | 是 | Postgres 连接字符串 |
| `REDIS_URL` | 否 | 用于缓存和限流的 Redis |
| `LITELLM_PROXY_BASE_URL` | 否 | 本实例的公网基础 URL（用于记忆/缓存回环） |
| `USE_DDTRACE` | 否 | 设为 `true` 以启用 Datadog APM 追踪 |
| `SEPARATE_HEALTH_APP` | 否 | 在独立端口上运行健康检查端点 |

---

## 注意事项

- 代理和 coworker 镜像以**非 root** 用户运行。
- 此部署**没有内置的高可用（HA）或自动扩缩**——客户需自行负责进程监管、数据库持久性和水平扩展。
- 在生产环境中使用多副本时，请使用共享的外部 Postgres 和 Redis，并在负载均衡器后运行多个代理容器。
- 如需完整的 AWS 原生高可用拓扑，请参阅[在 AWS 上自托管]({% link zh-CN/deployment/self-hosted-aws.md %})。
