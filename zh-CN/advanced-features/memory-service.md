---
lang: zh-CN
page_id: advanced-features/memory-service
permalink: /advanced-features/memory-service.html
title: 记忆即服务
parent: AI 能力
nav_order: 4
description: "通过 Mem0（向量）和 Cognee（知识图谱）实现长期记忆——按请求自动检索并注入。"
---

# 记忆即服务

记忆即服务（MaaS）将网关变为一个记忆供应商。应用无需自行运维向量存储或图数据库即可获得个性化和长期上下文——只需在请求中传入一个 `memory_id`。

---

## 工作原理

一个记忆**会话**是一个具名的、由引擎支撑、绑定到某个组织的事实存储。对于引用了会话的每个请求，网关执行两个步骤：

**调用前（检索）。** 网关取最新的用户消息，在会话中搜索最相关的前 3 条事实，并将它们追加到系统消息：

```
[Past Context for ID: user-alice]
- Prefers summaries under 200 words
- Working on Q3 APAC analysis
- Last session: discussed Bedrock pricing
```

**调用后（存储）。** 模型响应之后，网关异步地将 `(user, assistant)` 这一轮对话存入会话。传入 `store_memory: false` 可在单个请求上跳过存储。

记忆钩子在调用前链中最后运行，因此注入的上下文位于提示词注入、护栏与压缩之后：

```
GuardrailHook → PromptHook → TokenSavingPlanHook → MemoryHook
```

`memory_id` 对上游供应商是不透明的——它会在请求转发之前被剥离。

---

## 激活

```python
response = client.chat.completions.create(
    model="openai/gpt-5.5",
    messages=[{"role": "user", "content": "Remind me where we left off."}],
    extra_body={
        "memory_id": "user-alice",
        # "store_memory": False,   # 省略（默认 true）以存储本轮对话
    },
)
```

可在顶层或 `metadata` 中传入 `memory_id`。会话也可[通过策略绑定]({% link zh-CN/core-gateway/policies.md %})，从而自动激活。

---

## 记忆引擎

在创建会话时选择引擎；创建后不可更改。

| 引擎 | 后端 | 最适合 |
|---|---|---|
| **Mem0** | Postgres + pgvector | 用户偏好、近期事实、中短期语义召回 |
| **Cognee** | Postgres + pgvector + Neo4j | 实体与关系知识、长周期推理 |

**Mem0** 会区分关键字检索与自然语言提问，并对事实去重以避免冗余存储。向量搜索默认相似度阈值为 `0.5`。

**Cognee** 从已存储的对话轮次构建知识图谱（`remember`），并用 Cognee 限定在该会话范围内的块（向量）检索来响应取数，辅以词法匹配与事实去重。它刻意不使用图补全检索（那会合成新答案而非返回已存储的事实）。

---

## 创建记忆会话

打开 **Memory**，选择 **Create Session**。表单包含 **Name**、**Engine**（Mem0 或 Cognee）、可选的 **External ID** 与可选的 **Metadata**。返回的 `memory_id`（一个 UUID）即为调用方在请求中传递的内容。

![记忆会话列表，带 Create Session 按钮](/assets/images/memory-service/memory-sessions-list.png)

![Create Session 抽屉——名称、引擎、外部 ID 与元数据](/assets/images/memory-service/create-memory-session-drawer.png)

---

## 管理已存储的事实

每个会话的详情页是处理记忆中所存事实的地方：

- **Search Memory** —— 对会话发起自然语言查询，查看带分数的匹配结果。
- **Add Memory** —— 直接摄入一条事实，无需经过一轮聊天。
- **All Memory Facts** —— 浏览并删除会话中每一条已存储的事实。

![记忆会话详情视图——搜索、添加事实与已存储事实表格](/assets/images/memory-service/memory-session-detail.png)

---

## 组织隔离与权限

- **按组织作用域。** 会话属于一个组织。表 `LiteLLM_MemorySession` 存储了 `organization_id`，并强制 `(organization_id, name)` 唯一。
- **IDOR 保护。** 操作通过 Cerbos（`org:memory:common`）按组织授权；网关在解析时也会检查会话所属组织，不匹配则拒绝。
- **谁能管理。** 代理管理员与组织管理员可创建、编辑和删除会话。

---

## 内部成本核算

记忆子系统为存储和检索而发起的嵌入与提取调用，会通过内部服务账户密钥经由网关回流（模型 `internal-gpt-4o-mini`、嵌入模型 `internal-text-embedding-3-small`；中国区使用 `internal-qwen-plus` 与 `internal-text-embedding-v4`）。这些成本被记为**平台支出**——绝不会向调用方密钥计费。

---

## 依赖项

| 引擎 | 所需包 | 所需基础设施 |
|---|---|---|
| Mem0 | `mem0ai` | Postgres + pgvector |
| Cognee | `cognee` | Postgres + pgvector + Neo4j |

两者在私有部署中均可用。

---

## 与网关其余部分的组合

- **策略** —— 将会话绑定到[策略]({% link zh-CN/core-gateway/policies.md %})中，使其在密钥或模型上自动激活。
- **提示词 / 护栏 / Token 节省** —— 其余 [AI 能力]({% link zh-CN/advanced-features.md %})按各自正常顺序作用于同一请求。
- **Playground** —— 选择一个记忆会话，以在聊天过程中启用自动上下文注入与存储。

→ 关于将会话绑定到密钥与模型，参见 [策略]({% link zh-CN/core-gateway/policies.md %})。
