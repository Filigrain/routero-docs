---
lang: zh-CN
page_id: advanced-features
permalink: /advanced-features.html
title: AI 能力
nav_order: 5
has_children: true
description: "Token 节省、护栏、提示词管理和记忆即服务——Routero 的生产级 AI 层。"
---

# AI 能力

Routero 提供四项可选启用的能力，这些通常是生产级 AI 系统会自行构建的——响应缓存、内容安全、提示词版本管理和长期记忆。它们位于网关内部，因此你的应用代码保持整洁。

{: .note }
这些功能**默认关闭**，并按请求激活。管理员在 Routero 仪表板或通过管理 API 创建命名配置；调用方通过 ID 引用它们。除了在现有请求中添加一个 ID 字段外，无需任何代码改动。

---

## 用单个 ID 激活

每项AI 能力都遵循相同的模式——**功能即会话（Feature-as-a-Session）**设计：

1. 管理员在仪表板或管理 API 中创建一个命名配置（护栏、Token 节省方案、提示词或记忆会话）。
2. 调用方在请求体中传入该配置的 ID。
3. 网关从你的工作区解析该配置（按组织作用域限定、经过 IDOR 校验），将其作为前置/后置钩子应用，并在转发给上游供应商之前剥离 ID。

```python
# 在单个请求中使用全部四项功能——代码其余部分零改动
response = client.chat.completions.create(
    model="smart/balanced",
    messages=[{"role": "user", "content": "..."}],
    extra_body={
        "guardrail_id":         "pii-redact-prod",
        "token_saving_plan_id": "semantic-cache-v2",
        "prompt_id":            "analyst-system-v4",
        "memory_id":            "user-alice",
    },
)
```

{: .note }
你可以在单个请求上组合这四个 ID 的任意子集。每一项都是独立的。钩子按以下顺序运行：`PromptHook` → `TokenSavingPlanHook` → `GuardrailHook` → `MemoryHook`。

---

## 四项功能

### Token 节省
在不触碰应用代码的情况下降低每个请求的成本。它捆绑了两项独立的优化：

- **提示词压缩** —— 在内容到达 LLM 之前对会话历史进行裁剪或摘要（TextRank、LexRank、LSA 抽取式摘要，或确定性截断）。
- **响应缓存** —— 对相同提示词进行精确匹配缓存，对近似重复的提示词则回退到语义相似度搜索（Redis-Stack 或 Qdrant，默认阈值 0.85）。缓存命名空间始终是方案 ID，因此每个租户的缓存都是私有的。

这两项优化可以组合：压缩先运行，缩小缓存键的覆盖面；然后缓存检查是否命中。命中时，LLM 调用根本不会发生。

→ [Token 节省]({% link zh-CN/advanced-features/token-saving.md %})

---

### 护栏
集中管理、策略驱动的安全与合规——在网关中强制执行，无需触碰你的应用。

四个内置引擎，依次运行：

| 引擎 | 运行于 | 作用 |
|---|---|---|
| **内容过滤** | 前置与后置 | 对提示词和模型响应进行关键词/正则黑名单过滤 |
| **工具权限** | 前置 | 对函数/工具名称进行允许列表或黑名单控制 |
| **Presidio PII** | 前置与后置 | 通过 Microsoft Presidio 检测并匿名化个人数据（PERSON、EMAIL、SSN、CREDIT_CARD……） |
| **密钥检测** | 前置 | 通过 Yelp detect-secrets 检测并脱敏泄露的凭据（AWS 密钥、GitHub 令牌、Stripe 密钥、JWT、私钥……） |

每个引擎都可按护栏分别配置。发生违规时，请求会被以 HTTP 400 和结构化的违规消息拦截——或者将违规内容脱敏后让请求继续。

→ [护栏]({% link zh-CN/advanced-features/guardrails.md %})

---

### 提示词管理
一个集中的提示词模板注册中心。提示词团队在一处迭代；应用引用一个稳定的 `prompt_id`，即便底层模板演进，该 ID 也永不改变。

- **版本管理** —— 对某个提示词名称的每次 PUT 都会创建一个不可篡改的新版本。`prompt_id` UUID 在各版本间保持稳定；调用方可通过 `?version=N` 锁定到特定版本。
- **Jinja2 模板** —— `{{ customer_name }}`、`{{ language }}`、`{{ context }}` 在请求时通过 `prompt_variables` 填充。
- **两层缓存** —— 进程内 5 分钟缓存 + Redis 1 天缓存。改动在数秒内对下一个请求生效。
- **即时回滚** —— 通过锁定 `prompt_version` 重新激活任意先前版本。

→ [提示词管理]({% link zh-CN/advanced-features/prompt-management.md %})

---

### 记忆即服务
将网关变成一个记忆供应商。应用无需运营自己的向量存储或图数据库即可获得个性化和长期上下文。

两个后端引擎，可按记忆会话选择：

| 引擎 | 最适合 | 后端 |
|---|---|---|
| **Mem0** | 用户偏好、近期事实、短到中期的回溯 | pgvector（Postgres） |
| **Cognee** | 实体/关系知识、长跨度推理 | Neo4j + pgvector |

**每个请求的工作方式：**
1. **调用前（检索）** —— 在记忆会话中搜索最相关的前 3 条事实，并将它们以 `[Past Context for ID: ...]` 注入到系统消息中。
2. **调用后（存储）** —— 异步地将新的（用户、助手）轮次存入记忆后端。

在任意请求上传入 `store_memory: false` 即可跳过存储。使用管理 API 可手动录入事实或查询会话。

→ [记忆即服务]({% link zh-CN/advanced-features/memory-service.md %})

---

## 企业级视角

{: .enterprise }
> **这些是治理功能，而非折扣功能。**
>
> Token 节省消除冗余算力，让平台成本可被问责——它不是对 token 的打折，而是减少所消耗的 token。护栏回答了法务的问题："模型看到了什么？"提示词管理为安全团队提供了 GDPR 数据处理审查所需的版本历史。记忆将短暂的无状态 LLM 调用变成一套记录系统——这是一流的企业级能力，而非锦上添花的 UX 点缀。

每项功能都是：
- **按组织作用域限定** —— 配置属于你的工作区，对其他租户不可见。
- **受 IDOR 保护** —— 网关在应用之前会校验调用密钥所属的组织是否拥有所引用的 ID。
- **可审计** —— 功能激活、缓存命中和护栏违规都会出现在你的审计日志与用量视图中。
- **仪表板管理** —— 非工程人员可在 Routero 管理仪表板中创建和管理配置，无需调用 API。

---

## 依赖与启用

AI 能力需要可选的 Python 依赖和基础设施组件，这些在最小化的 Routero 部署中并不存在。每个功能页面都记录了其前提条件。

| 功能 | 可选依赖 | 基础设施 |
|---|---|---|
| Token 节省（语义缓存） | `redis-stack` 或 `qdrant-client` | Redis-Stack 或 Qdrant |
| Token 节省（摘要） | `sumy`、`nltk` | — |
| 护栏（PII） | `presidio-analyzer`、`presidio-anonymizer` | — |
| 护栏（密钥检测） | `detect-secrets` | — |
| 记忆（Mem0） | `mem0ai` | Postgres + pgvector |
| 记忆（Cognee） | `cognee` | Neo4j + Postgres + pgvector |

精确缓存、内容过滤、工具权限和关键词护栏引擎**无需额外依赖**——它们开箱即用。
