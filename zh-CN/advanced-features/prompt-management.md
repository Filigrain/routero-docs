---
lang: zh-CN
page_id: advanced-features/prompt-management
permalink: /advanced-features/prompt-management.html
title: 提示词管理
parent: AI 能力
nav_order: 3
description: "中央提示词注册表，支持不可篡改的版本管理、Jinja2 模板与即时回滚。"
---

# 提示词管理

提示词管理将提示词工程与应用部署解耦。提示词团队在一个具备完整版本历史的中央注册表中维护模板；应用引用一个永不改变的稳定 `prompt_id`，即使底层模板不断演进也是如此。

{: .note }
Routero 的提示词管理是**一个由你的工作区拥有、基于数据库的注册表**——它有别于供应商侧的“提示词缓存”功能，也不同于 Langfuse 或 dotprompt 等第三方集成。

---

## 激活

```python
response = client.chat.completions.create(
    model="smart/balanced",
    messages=[{"role": "user", "content": "Summarise Q3 results"}],
    extra_body={
        "prompt_id": "analyst-system-v2",
        "prompt_variables": {
            "company": "Acme Corp",
            "language": "English",
            "tone": "executive"
        },
        # 可选：固定到特定版本
        # "prompt_version": 3
    },
)
```

网关会获取 `analyst-system-v2` 的最新版本，渲染 Jinja2 变量，并在转发给供应商之前**将渲染后的消息前置（prepend）到请求中**。`prompt_id` 会被剥离——上游永远看不到它。

---

## 概念

**`prompt_id`** —— 在首次创建提示词时分配的稳定 UUID。这是调用方存储并传递的内容。它不会随版本变化而改变。

**版本（Version）** —— 每次 `PUT /prompts/{name}` 都会创建一个不可篡改的新版本。旧版本会被保留，并可通过 `prompt_version` 固定（pin）。`is_latest` 标志用于追踪当前头部版本。

**模板（Template）** —— 一个 `messages` 数组（`[{"role": "system", "content": "..."}, ...]`），可选带有 Jinja2 变量。缺失的变量会渲染为空字符串（不报错）。

---

## 创建提示词与版本管理

```bash
# 创建提示词（版本 1）
curl -X POST https://api.routero.ai/prompts \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt_name": "analyst-system-v2",
    "messages": [
      {
        "role": "system",
        "content": "You are a financial analyst at {{ company }}. Respond in {{ language }} with a {{ tone }} tone. Be concise and data-driven."
      }
    ],
    "variables": ["company", "language", "tone"]
  }'

# 更新（创建版本 2，保留版本 1）
curl -X PUT https://api.routero.ai/prompts/analyst-system-v2 \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{
    "messages": [
      {
        "role": "system",
        "content": "You are a senior financial analyst at {{ company }}. ..."
      }
    ]
  }'
```

---

## 回滚

将任意请求固定到先前版本：
```python
extra_body={"prompt_id": "analyst-system-v2", "prompt_version": 1}
```

或者，通过重新发起一次 PUT、将版本 1 的内容设为新的最新版本，从而将所有流量切回版本 1。

---

## 缓存

提示词模板缓存于两个层级：
- **进程内缓存** —— 每个代理实例 5 分钟 TTL
- **Redis 缓存** —— 1 天 TTL，在所有代理副本间共享

更改会在 TTL 过期后数秒内对流量生效。在执行 `DELETE` 时缓存会立即失效。

---

## 组织范围

提示词归属于创建该密钥所在的组织。来自组织 A 的密钥无法解析组织 B 的提示词。org 为 null 的提示词是**全局的**——工作区中所有组织的密钥均可访问（适用于共享的公司标准）。代理管理员可以访问所有提示词。

---

## 管理 API

| 端点 | 说明 |
|---|---|
| `POST /prompts` | 创建提示词（组织内名称重复时返回 409） |
| `GET /prompts` | 列出工作区中的所有提示词 |
| `GET /prompts/{prompt_id}` | 获取最新版本（添加 `?version=N` 以固定版本） |
| `GET /prompts/{prompt_id}/versions` | 列出所有版本 |
| `PUT /prompts/{name}` | 创建下一个版本（不可篡改） |
| `DELETE /prompts/{name}` | 删除某个提示词的所有版本 |
