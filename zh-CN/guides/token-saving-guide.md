---
lang: zh-CN
page_id: guides/token-saving-guide
permalink: /guides/token-saving-guide.html
title: 用 Token 节省降低成本
parent: 指南
nav_order: 7
description: "为高流量端点配置提示词压缩和语义响应缓存。"
---

# 用 Token 节省降低成本

本指南为一个高流量聊天端点配置 Token 节省方案，该端点的提示词带有较长的对话历史，并且许多请求在语义上相似（例如支持机器人、代码助手、FAQ 界面）。

---

## 我们将配置的方案

1. **压缩** — 使用 TextRank 摘要将对话历史裁剪到 4096 个输入 token。
2. **精确缓存** — 对完全相同的提示词返回已缓存的响应（TTL：1 小时）。
3. **语义缓存** — 对近乎相同的提示词返回已缓存的响应（相似度 ≥ 0.85，TTL：1 小时）。

---

## 前提条件

- 运行中的 Redis（精确缓存）
- Redis-Stack（用于语义搜索）或 Qdrant

对于 Docker Compose，请使用 `--profile semantic` 运行。

---

## 第 1 步 — 创建方案

```bash
curl -X POST https://api.routero.ai/token-saving/plans \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "plan_name": "support-bot-cache",
    "compression": {
      "engine": "text_rank",
      "max_input_tokens": 4096
    },
    "cache": {
      "backend": "redis_semantic",
      "similarity_threshold": 0.85,
      "ttl": 3600
    }
  }'
```

---

## 第 2 步 — 使用方案

```python
response = client.chat.completions.create(
    model="smart/balanced",
    messages=conversation_history,   # may be hundreds of messages
    extra_body={"token_saving_plan_id": "support-bot-cache"},
)
```

网关将：
1. 使用 TextRank 将 `conversation_history` 压缩到 ≤4096 个 token。
2. 检查精确缓存 —— 若命中，返回已缓存的响应。
3. 为压缩后的查询生成嵌入，检查 ≥ 0.85 的语义匹配 —— 若命中，返回已缓存的响应。
4. 若无缓存命中，则调用 LLM 并将响应存入两个缓存层级。

---

## 第 3 步 — 衡量效果

24 小时后，在仪表盘中查看支出。对比：
- `litellm_tokens_total` 前后变化（压缩效果）
- Token 节省方案统计中的 `cache_hits`（缓存效果）

```bash
GET /token-saving/plans/support-bot-cache/stats
# Returns: total_requests, cache_hits, cache_hit_rate, tokens_saved, cost_saved_usd
```

---

## 何时使用语义缓存与精确缓存

| 缓存类型 | 适用于 | 不适用于 |
|---|---|---|
| 精确 | 完全相同的提示词（幂等工具、固定模板） | 带有独特用户输入的对话 |
| 语义 | FAQ 式问题、改写后的查询 | 时效性强或个性化的响应 |

从语义阈值 0.85 开始。调低到 0.80 可提高缓存命中率（精度略有下降）。调高到 0.90 可提高精确度（误命中更少）。

---

## 按请求退出缓存

```python
# Skip cache for this request (e.g., a real-time, time-sensitive query)
extra_body={
    "token_saving_plan_id": "support-bot-cache",
    "cache": {"no-store": True}
}
```
