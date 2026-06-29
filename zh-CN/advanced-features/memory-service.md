---
lang: zh-CN
page_id: advanced-features/memory-service
permalink: /advanced-features/memory-service.html
title: 记忆即服务
parent: 高级功能
nav_order: 4
description: "通过 Mem0（向量）和 Cognee（知识图谱）实现长期记忆——按请求自动检索并注入。"
---

# 记忆即服务

记忆即服务（MaaS）将网关变为一个记忆供应商。应用无需自行运维向量存储或图数据库即可获得个性化和长期上下文——只需在请求中传入一个 `memory_id`。

---

## 工作原理

**调用前（检索）：** 网关取最新的用户消息，在记忆会话中搜索最相关的前 3 条事实，并将它们注入系统消息，形如：
```
[Past Context for ID: user-alice]
- Prefers summaries under 200 words
- Working on Q3 APAC analysis
- Last session: discussed Bedrock pricing
```

**调用后（存储）：** 在 LLM 响应之后，网关会异步地将 `(user message, assistant response)` 这一轮对话存入记忆后端。传入 `store_memory: false` 可在特定请求上跳过存储。

---

## 激活

```python
response = client.chat.completions.create(
    model="smart/balanced",
    messages=[{"role": "user", "content": "Remind me where we left off."}],
    extra_body={
        "memory_id": "user-alice",
        "store_memory": True,          # default — omit to use default
    },
)
```

---

## 记忆引擎

| 引擎 | 后端 | 最适合 |
|---|---|---|
| **Mem0** | Postgres + pgvector | 用户偏好、近期事实、中短期语义召回 |
| **Cognee** | Neo4j + pgvector + Postgres | 实体/关系知识、长周期推理、知识图谱查询 |

在创建记忆会话时选择引擎。会话创建后无法更改引擎。

**Mem0** 查询使用关键字与问题的启发式判断以及事实去重，以减少冗余存储。

**Cognee** 支持 `SearchType.GRAPH_COMPLETION`、`CHUNKS` 和 `SUMMARIES`——并通过图→向量搜索回退以增强健壮性。删除操作会原子性地清理 Neo4j、PGVector 和 Postgres。

---

## 创建记忆会话

```bash
curl -X POST https://api.routero.ai/memory/session/create \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "session_name": "user-alice",
    "engine_name": "mem0"
  }'
```

返回的 `memory_id` 即为调用方在请求中传递的内容。

---

## 手动事实管理

你可以直接摄入事实（无需经过一轮聊天），并以编程方式查询会话：

```bash
# 手动摄入事实
curl -X POST https://api.routero.ai/memory/session/add \
  -d '{"memory_id": "user-alice", "messages": [{"role": "user", "content": "My team is in Singapore."}]}'

# 查询会话
curl -X POST https://api.routero.ai/memory/session/search \
  -d '{"memory_id": "user-alice", "query": "location preferences"}'

# 列出所有已存储的事实
curl "https://api.routero.ai/memory/session/user-alice/facts"
```

---

## 组织范围与隔离

记忆会话归属于创建该密钥所在的组织。会话受 IDOR 保护：来自组织 A 的密钥无法访问或注入组织 B 的会话。`memory_id` 对上游供应商是不透明的——它会在请求转发之前被剥离。

---

## 管理 API

| 端点 | 说明 |
|---|---|
| `GET /memory/engines` | 列出可用的记忆引擎类型 |
| `POST /memory/session/create` | 创建记忆会话 |
| `GET /memory/sessions` | 列出工作区中的所有会话 |
| `GET /memory/session/{id}` | 获取会话详情 |
| `PATCH /memory/session/{id}` | 更新会话配置 |
| `DELETE /memory/session/{id}` | 删除会话及所有已存储的事实 |
| `POST /memory/session/add` | 手动摄入事实 |
| `POST /memory/session/search` | 查询会话 |
| `GET /memory/session/{id}/facts` | 列出所有已存储的事实 |

---

## 依赖项

| 引擎 | 所需包 | 所需基础设施 |
|---|---|---|
| Mem0 | `mem0ai` | Postgres + pgvector |
| Cognee | `cognee` | Neo4j + Postgres + pgvector |

两者在私有部署中均可用——基础设施要求参见[参考架构]({% link zh-CN/deployment/reference-architecture.md %})。

---

## 内部成本核算

记忆子系统为存储和检索而发起的嵌入和提取调用，会通过内部服务账户密钥经由代理回流。这些成本被记为**平台支出**——不会向调用用户的密钥计费——并在计费仪表盘的 Internal / Platform 下可见。
