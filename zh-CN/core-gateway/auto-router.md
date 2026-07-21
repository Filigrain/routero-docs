---
lang: zh-CN
page_id: core-gateway/auto-router
permalink: /core-gateway/auto-router.html
title: 自动路由
parent: 核心网关
nav_order: 3
description: "基于意图的模型选择——检查用户消息，自动路由到最合适的模型组。"
---

# 自动路由

自动路由是一个**基于意图的模型选择层**。你不必在应用中硬编码模型，而是把请求指向一个自动路由器，它会根据用户实际提问的内容，为每条消息挑选最合适的**模型组**——随后的路由、负载均衡与故障转移机制照常接管。

{: .note }
自动路由**不是**一种路由策略。它在你在[路由与负载均衡]({% link zh-CN/core-gateway/routing.md %})中配置的策略**之前**运行——它把请求的模型改写为所选的组，然后 Router 再用常规方式为该组挑选一个健康的部署。两者相互独立，可以干净地组合使用。

---

## 工作原理

每个自动路由器包含一组**路由**。一条路由由一个目标模型组加上它应当服务的请求类型描述（以若干示例**话术**表达）组成。每个请求的处理流程：

1. 自动路由从请求消息中提取文本。
2. 将文本与各条路由进行匹配，选出最合适的一条。
3. 所选路由的模型组替换掉请求中原本的模型。
4. Router 继续按其常规策略（least-busy、lowest-cost……）以及[故障转移]({% link zh-CN/core-gateway/failover.md %})行为处理。
5. 如果没有路由匹配——或出现任何问题——请求会回退到路由器配置的**默认模型**。自动路由永远不会拦截请求。

每个路由器可在两种匹配引擎中选择：

| 模式 | 匹配方式 | 适用场景 |
|---|---|---|
| **向量**（默认） | 对消息和每条路由的话术生成向量嵌入；在超过阈值的前提下选择余弦相似度最高的路由 | 高吞吐、低开销、确定性 |
| **分类器** | 让一个小模型把消息分类到某条路由中 | 关键词/向量相似度难以区分的细微意图 |

两个引擎都完全运行在你的 Routero 部署内部，使用一个**内部服务账号**——嵌入与分类调用会回环经过网关自身的 `/embeddings` 和 `/chat/completions` 端点。它们**不**消耗你的虚拟密钥预算，也**不**以你的费用调用外部供应商。

{: .note }
自动路由是静态的、由配置驱动的——它**不会**随时间学习或自适应。路由决策完全由你的路由定义、消息内容以及嵌入/分类模型决定。要改变行为，编辑路由即可。

---

## 定义路由

一条路由由四部分组成：

| 字段 | 说明 |
|---|---|
| `name` | 要路由到的目标模型**组**（必须与已配置的模型组匹配）。在路由器内必须唯一。 |
| `description` | 对该路由所处理内容的简短可读说明。分类器模式会用到。 |
| `utterances` | 表征该路由的示例短语。向量引擎将进入的消息与这些话术进行比对。每条路由最多 50 条，每个路由器最多 500 条。 |
| `score_threshold` | 可选。向量模式下一条路由要胜出所需超过的相似度分数（0–1）。默认 `0.2`。 |

一个分流路由器的示例路由表：

| 路由（模型组） | 说明 | 示例话术 |
|---|---|---|
| `reasoning` | 复杂推理、数学、分析 | *"证明这个定理"、"调试这个算法"、"分析其中的权衡"* |
| `coding` | 代码生成与解释 | *"写一个 python 函数"、"重构这个类"、"解释这段堆栈跟踪"* |
| `general`（默认） | 日常提问与闲聊 | *其他一切* |

![路由构建器——模型、描述、话术、分数阈值，以及实时 JSON 预览](/assets/images/auto-router/auto-router-route-builder.png)

---

## 创建自动路由器

自动路由器作为**虚拟部署**创建，可通过仪表板或模型管理 API 创建。最简单的方式是仪表板：**Models & Endpoints → Add → Auto Router**。

![Models & Endpoints 页面的 Add 菜单，其中的 Auto Router 选项](/assets/images/auto-router/add-auto-router-entry.png)

网关存储的字段如下：

```yaml
# 概念示例——通过仪表板的 "Add Auto Router" 流程或模型 API 创建，
# 并非直接写入你的主配置文件。
- model_name: triage
  litellm_params:
    model: auto_router/triage
    auto_router_config: |
      {
        "routes": [
          { "name": "reasoning", "description": "复杂推理、数学、分析",
            "utterances": ["证明这个定理", "分析其中的权衡"],
            "score_threshold": 0.3 },
          { "name": "coding", "description": "代码生成与解释",
            "utterances": ["写一个 python 函数", "重构这个类"] }
        ]
      }
    auto_router_default_model: general
    auto_router_routing_mode: embedding      # 或 "classifier"
    # auto_router_classifier_model: internal-qwen-plus   # 仅在分类器模式下必填
```

必填字段：

- `model` —— 必须以 `auto_router/` 开头。后缀即路由器的名称。
- `auto_router_config` —— 包含 `routes` 数组的 JSON 字符串。
- `auto_router_default_model` —— 没有路由匹配或引擎出错时使用的模型组。

可选字段：

- `auto_router_routing_mode` —— `embedding`（默认）或 `classifier`。
- `auto_router_classifier_model` —— 用于分类的模型（分类器模式下必填，否则忽略）。
- `auto_router_embedding_model` —— 覆盖向量模式下使用的嵌入模型。

仪表板表单会替你校验唯一性、阈值与话术数量限制，并实时预览配置的 JSON。

![Add Auto Router 抽屉——名称、默认模型、路由模式与路由构建器](/assets/images/auto-router/add-auto-router-drawer.png)

---

## 调用自动路由器

从调用方角度看，自动路由器只是另一个模型名。把现有请求指向它即可：

```python
response = client.chat.completions.create(
    model="auto_router/triage",          # 自动路由器挑选真正的模型组
    messages=[{"role": "user", "content": "证明两个偶数之和仍是偶数。"}],
)
```

网关为这条消息选择 `reasoning`，把请求交给 Router 进行部署选择，然后返回响应。响应中带有显示最终由哪个部署提供服务的响应头：

- `x-routero-model-id` —— 所选部署的模型 id
- `x-routero-model-api-base` —— 所选部署的 API base

![自动路由器在模型详情视图中的呈现](/assets/images/auto-router/auto-router-overview.png)

{: .note }
自动路由检查的是消息**内容**，因此对于没有消息的请求（例如透传与非聊天端点）它会跳过——这些请求会直接发往所请求的模型。

---

## 多租户与地域

每个自动路由器都是**按组织作用域限定**的：一个路由器属于一个组织，其路由仅对该组织的密钥解析。当你有按组织划分的模型组时，为每个组织提供各自的自动路由器并引用各自的组即可。

内部嵌入与分类模型默认采用与地域匹配的取值，使中国区工作区开箱即用国内模型：

| 地域 | 默认嵌入模型 | 默认分类器模型 |
|---|---|---|
| 中国（`cn-north-1`） | `internal-text-embedding-v4` | `internal-qwen-plus` |
| 所有其他地域 | `internal-text-embedding-3-small` | `internal-gpt-4o-mini` |

如需覆盖，可在路由器上设置 `auto_router_embedding_model` / `auto_router_classifier_model`。

---

## 依赖与启用

| 模式 | 要求 |
|---|---|
| **向量** | `semantic-router` Python 包。如果在未安装该包时创建了向量模式路由器，网关会给出明确的安装提示。 |
| **分类器** | 无额外依赖——使用标准的聊天补全路径。 |

两种模式都要求模型列表中存在内部嵌入与分类器模型（在默认配置中标记为 `usage: auto_router`），并已植入内部服务账号。这些属于标准 Routero 部署的一部分；自动路由本身不需要 Redis、向量数据库或 GPU。

---

## 与网关其余部分的组合

自动路由可与网关的每一项其他能力组合使用：

- **路由与故障转移** —— 所选模型组的负载均衡与故障转移方式与任何直接请求的模型完全一致。
- **策略** —— 自动路由所路由到的模型组本身可以携带[能力策略]({% link zh-CN/core-gateway/policies.md %})（护栏、提示词、记忆、Token 节省）。
- **护栏 / 提示词 / 记忆 / Token 节省** —— 照常作用于解析后的请求。参见 [AI 能力]({% link zh-CN/advanced-features.md %})。

→ 关于自动路由器交棒之后的部署选择策略，参见 [路由与负载均衡]({% link zh-CN/core-gateway/routing.md %})。
→ 关于所选组的重试行为，参见 [故障转移与回退]({% link zh-CN/core-gateway/failover.md %})。
