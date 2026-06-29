---
lang: zh-CN
page_id: advanced-features/token-saving
permalink: /advanced-features/token-saving.html
title: Token 节省
parent: 高级功能
nav_order: 1
description: "提示词压缩与精确/语义响应缓存——在不修改应用代码的前提下降低成本。"
---

# Token 节省

Token 节省是一个具名套餐，捆绑了两项相互独立的优化：**提示词压缩**（在调用 LLM 之前减少输入 token）和**响应缓存**（对重复或近似重复的提示词完全消除 LLM 调用）。

这两项优化均由管理员集中管理，并通过单个 ID 在每次请求中激活。无需更改任何应用逻辑。

{: .note }
Token 节省的目标是减少计算量——而非购买更便宜的 token。其核心是消除冗余的 LLM 调用并缩减提示词，所节省的部分会在你的支出报告中体现为平台成本的下降。

---

## 激活

```python
response = client.chat.completions.create(
    model="smart/balanced",
    messages=[...],
    extra_body={"token_saving_plan_id": "my-plan"},
)
```

该套餐会从你的工作区中解析出来，作为调用前钩子（pre-call hook）应用，并在请求到达上游供应商之前被剥离。

如需在特定请求上退出：传入 `cache: {"no-store": true}`。

---

## 提示词压缩

压缩在缓存键计算之前运行，因此压缩后的提示词可以在历史长度不同的多个调用方之间共享缓存命中。

| 引擎 | 方法 | 适用场景 |
|---|---|---|
| `trim` | 确定性截断（移除最早的消息以适配 `max_input_tokens`） | 快速、零依赖、可预测 |
| `text_rank` | TextRank 抽取式摘要 | 中等上下文、注重语义保真度 |
| `lex_rank` | LexRank 抽取式摘要 | 与 TextRank 类似，在结构化文本上通常表现更佳 |
| `lsa` | LSA（潜在语义分析）摘要 | 较长文档、基于主题的抽取 |

摘要引擎需要 `sumy` 和 `nltk` Python 包。请在压缩套餐上设置 `max_input_tokens`。

---

## 响应缓存

一个两级瀑布流：

**第一级 —— 精确缓存**
在 Redis 中检查是否存在完全相同的缓存键（模型 + 压缩后的消息 + 参数）。缓存命名空间始终为套餐 ID——每个工作区的缓存都是私有的。默认 TTL：3600 秒。

**第二级 —— 语义缓存**（在精确缓存未命中时）
生成查询的嵌入，并针对此前缓存的查询执行向量相似度搜索（默认阈值：0.85）。如果找到语义等价的先前响应，则直接返回，而不调用 LLM。

语义缓存后端：**Redis-Stack**（RediSearch 向量相似度）或 **Qdrant**。嵌入调用通过内部服务账户密钥经由代理回流——其成本被记为平台支出，绝不会向调用方密钥重复计费。

---

## 创建套餐

```bash
curl -X POST https://api.routero.ai/token-saving/plans \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "plan_name": "my-plan",
    "cache": {
      "backend": "redis_semantic",
      "similarity_threshold": 0.85,
      "ttl": 3600
    },
    "compression": {
      "engine": "text_rank",
      "max_input_tokens": 4096
    }
  }'
```

你也可以在 Routero 仪表盘的 **Token Saving → Plans** 下配置套餐。

---

## 管理 API

| 端点 | 说明 |
|---|---|
| `POST /token-saving/plans` | 创建套餐 |
| `GET /token-saving/plans` | 列出工作区中的所有套餐 |
| `GET /token-saving/plans/{id}` | 获取套餐详情 |
| `PATCH /token-saving/plans/{id}` | 更新套餐 |
| `DELETE /token-saving/plans/{id}` | 删除套餐 |
| `GET /token-saving/cache-engines` | 列出可用的缓存后端 |
| `GET /token-saving/compression-engines` | 列出可用的压缩引擎 |

---

## 依赖项

| 功能 | 所需包 | 所需基础设施 |
|---|---|---|
| 仅精确缓存 | — | Redis |
| 语义缓存（Redis-Stack） | `redis-stack` 客户端 | Redis-Stack（RediSearch + 向量模块） |
| 语义缓存（Qdrant） | `qdrant-client` | Qdrant 实例 |
| 摘要压缩 | `sumy`、`nltk` | — |
| 截断压缩 | — | — |
