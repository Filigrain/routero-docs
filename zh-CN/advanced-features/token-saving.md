---
lang: zh-CN
page_id: advanced-features/token-saving
permalink: /advanced-features/token-saving.html
title: Token 节省
parent: AI 能力
nav_order: 1
description: "提示词压缩与精确/语义响应缓存——在不修改应用代码的前提下降低成本。"
---

# Token 节省

**Token 节省套餐**是一个具名配置，捆绑了两项相互独立的优化：**提示词压缩**（在调用模型之前缩减输入）和**响应缓存**（对重复或近似重复的提示词完全跳过模型调用）。

这两项优化均由管理员集中管理，并通过单个 ID 在每次请求中激活。无需更改任何应用逻辑。

{: .note }
Token 节省减少的是计算量——而非购买更便宜的 token。其核心是消除冗余的模型调用并缩减提示词，所节省的部分会在你的支出报告中体现为平台成本的下降。

---

## 工作原理

当请求携带 `token_saving_plan_id` 时，网关解析该套餐并将其作为调用前钩子运行，时机在提示词注入之后、调用模型之前：

```
GuardrailHook → PromptHook → TokenSavingPlanHook → MemoryHook
```

在该钩子内部，两项优化按固定顺序运行：

1. **压缩** —— 先压缩消息列表（这样缓存键是在更小的、压缩后的输入上计算的）。
2. **缓存** —— 网关先检查精确缓存，再检查语义缓存。命中时返回已存储的响应，模型不会被调用。

套餐 ID 会在请求到达上游供应商之前被剥离。

---

## 激活

```python
response = client.chat.completions.create(
    model="openai/gpt-5.5",
    messages=[...],
    extra_body={"token_saving_plan_id": "my-plan"},
)
```

可在顶层或 `metadata` 中传入 ID。如需在单个请求上退出，传入 `cache: {"no-store": true}`。套餐也可[通过策略绑定]({% link zh-CN/core-gateway/policies.md %})，从而自动激活。

---

## 提示词压缩

| 引擎 | 方法 | 适用场景 |
|---|---|---|
| `trim` | 通过 `litellm.utils.trim_messages` 进行中部截断——保留系统消息与工具消息，从中间裁剪以适配 `max_input_tokens` | 快速、零依赖、可预测 |
| `text_rank` | TextRank 抽取式摘要（sumy） | 中等上下文、注重语义保真度 |
| `lex_rank` | LexRank 抽取式摘要（sumy） | 与 TextRank 类似，在结构化文本上通常表现更佳 |
| `lsa` | LSA（潜在语义分析）摘要（sumy） | 较长文档、基于主题的抽取 |

三个摘要引擎会完整保留最后一条用户消息，并对更早的历史进行抽取式摘要。其可选配置键为 `language`（默认 `english`）与 `min_sentences`（默认 `1`）。请设置 `max_input_tokens` 以限制压缩后的大小。

**依赖项：** `trim` 无需额外依赖；摘要引擎需要 `sumy`、`nltk` 与 `tiktoken`。

---

## 响应缓存

一个两级瀑布流。仅在你启用时才会创建缓存子套餐；你可以单独使用压缩、单独使用缓存、两者皆用，或（空操作套餐）都不用。

**第一级 —— 精确缓存**
网关在全局缓存（在常规部署中为 Redis）中检查完全相同的键——模型、消息与参数。缓存命名空间始终为**套餐 ID**，因此每个套餐的缓存都是私有的。由 **Exact Cache** 开关控制；TTL 未设置时默认为 `3600` 秒。

**第二级 —— 语义缓存**（精确缓存未命中时）
网关对查询生成嵌入，并针对此前缓存的查询执行向量相似度搜索（默认阈值 `0.85`）。若找到语义等价的先前响应，则直接返回而不调用模型。

语义缓存后端：

| 后端 | 说明 |
|---|---|
| `redis_semantic` | 带 RediSearch 向量模块的 Redis-Stack |
| `qdrant_semantic` | 一个 Qdrant 实例 |

{: .note }
语义缓存的嵌入通过网关自身的 `/embeddings` 端点、在内部服务账户密钥下生成（模型 `internal-text-embedding-3-small`，1536 维）。其成本被记为**平台支出**，绝不会向调用方密钥计费。

---

## 创建套餐

在管理导航中打开 **Token Saving**，选择 **Create Plan**。表单分为两个区——**Cache Plan** 与 **Compression Plan**——你可以只填其中一个、两者都填，或（空操作套餐）都不填。

![Token 节省套餐列表，带 Create Plan 按钮](/assets/images/token-saving/token-saving-plans-list.png)

![Create Token Saving Plan 抽屉——缓存套餐与压缩套餐两个区](/assets/images/token-saving/create-token-saving-plan-drawer.png)

### Cache Plan 选项

| 选项 | 说明 |
|---|---|
| Exact Cache | 开启或关闭精确缓存。开启时，完全相同的请求由全局缓存直接返回。 |
| Exact TTL | 精确缓存条目的存活时间，单位秒（默认 `3600`）。 |
| Semantic Cache Engine | 用于近似匹配的向量后端——`redis_semantic` 或 `qdrant_semantic` 引擎。不设置则禁用语义缓存。 |
| Similarity Threshold | 匹配阈值，0–1（默认 `0.85`）。越高越严格。 |
| Semantic TTL | 语义缓存条目的存活时间，单位秒。 |

### Compression Plan 选项

| 选项 | 说明 |
|---|---|
| Compression Engine | `trim`、`text_rank`、`lex_rank`、`lsa` 之一。不设置则禁用压缩。 |
| Max Input Tokens | 压缩后消息列表的上限。 |

![Token 节省套餐详情视图——缓存套餐与压缩套餐卡片](/assets/images/token-saving/token-saving-plan-detail.png)

---

## 组织隔离与权限

- **按组织作用域。** 套餐属于一个组织（`LiteLLM_TokenSavingPlan` 携带 `organization_id`；其缓存与压缩子套餐通过外键关联）。
- **IDOR 保护。** 操作通过 Cerbos（`org:token_saving:common`）按组织授权；网关在解析时检查套餐所属组织，不匹配则拒绝。
- **谁能管理。** 代理管理员与组织管理员可创建、编辑和删除套餐。

---

## 依赖项

| 能力 | 所需包 | 所需基础设施 |
|---|---|---|
| 精确缓存 | — | Redis（网关全局缓存） |
| 语义缓存（Redis-Stack） | `redis-stack` | Redis-Stack（RediSearch + 向量模块） |
| 语义缓存（Qdrant） | `qdrant-client` | Qdrant 实例 |
| 摘要压缩 | `sumy`、`nltk`、`tiktoken` | — |
| `trim` 压缩 | — | — |

---

## 与网关其余部分的组合

- **策略** —— 将套餐绑定到[策略]({% link zh-CN/core-gateway/policies.md %})中，使其在密钥或模型上自动激活。
- **提示词 / 护栏 / 记忆** —— 其余 [AI 能力]({% link zh-CN/advanced-features.md %})按各自正常顺序作用于同一请求。
- **Playground** —— 在 Advanced Settings 下选择套餐，观察缓存与压缩的实际效果。

→ 关于将套餐绑定到密钥与模型，参见 [策略]({% link zh-CN/core-gateway/policies.md %})。
