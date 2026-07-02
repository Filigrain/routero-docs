---
lang: zh-CN
page_id: guides/long-term-memory
permalink: /guides/long-term-memory.html
title: 为你的应用赋予长期记忆
parent: 指南
nav_order: 8
description: "使用记忆即服务为你的应用赋予按用户划分的长期记忆，并实现自动检索与存储。"
---

# 为你的应用赋予长期记忆

本指南为一个现有的聊天应用添加按用户划分的持久化记忆。设置完成后，网关会自动从过往对话中检索相关事实，并将其注入到每个新请求中 —— 除了传入一个 `memory_id` 之外，无需更改任何应用逻辑。

---

## 我们将构建什么

- 每个用户一个 Mem0 记忆会话
- 在每个请求上自动检索事实（注入最相关的 3 条事实作为系统上下文）
- 在每个响应后自动存储事实（异步进行，不影响响应延迟）

---

## 前提条件

Mem0 需要带 pgvector 的 Postgres。对于私有部署，请通过部署包启用记忆层级（在你的入门指南中有涵盖）。

---

## 第 1 步 — 为每个用户创建记忆会话

在首次登录时（或在用户被预配时）创建会话。将返回的 `memory_id` 与用户记录一同存储。

```python
import requests

def create_memory_session(user_id: str) -> str:
    resp = requests.post(
        "https://api.routero.ai/memory/session/create",
        headers={"Authorization": f"Bearer {ADMIN_KEY}"},
        json={"session_name": f"user-{user_id}", "engine_name": "mem0"},
    )
    return resp.json()["memory_id"]
```

---

## 第 2 步 — 在每个聊天请求上传入 `memory_id`

```python
def chat(user_id: str, message: str, memory_id: str) -> str:
    response = client.chat.completions.create(
        model="smart/balanced",
        messages=[{"role": "user", "content": message}],
        extra_body={
            "memory_id": memory_id,
            "store_memory": True,     # default — can be omitted
        },
    )
    return response.choices[0].message.content
```

在第一个请求时，不会注入任何上下文（会话为空）。在第一轮对话之后，后续请求将获得：

```
System context (injected by gateway):
[Past Context for ID: user-alice]
- Works on the APAC sales team
- Prefers concise bullet-point summaries
- Last session: asked about Q3 pricing strategy
```

---

## 第 3 步 — 预置初始事实（可选）

在第一次对话之前摄入已知事实：

```python
requests.post(
    "https://api.routero.ai/memory/session/add",
    headers={"Authorization": f"Bearer {ADMIN_KEY}"},
    json={
        "memory_id": memory_id,
        "messages": [
            {"role": "user", "content": "My name is Alice and I lead APAC sales."}
        ],
    },
)
```

---

## 第 4 步 — 对敏感轮次跳过存储

如果某一轮包含用户不希望被记住的个人数据：

```python
response = client.chat.completions.create(
    model="smart/balanced",
    messages=[...],
    extra_body={
        "memory_id": memory_id,
        "store_memory": False,   # 检索上下文但不存储本轮对话
    },
)
```

---

## 查看和管理已存储的事实

```bash
# 列出某个用户的所有已存储事实
GET /memory/session/{memory_id}/facts

# 删除某条特定事实（例如，用户数据删除请求）
DELETE /memory/session/{memory_id}/facts/{fact_id}

# 删除整个会话（GDPR 被遗忘权）
DELETE /memory/session/{memory_id}
```

删除操作在 Postgres 和 pgvector 索引之间是原子性的。
