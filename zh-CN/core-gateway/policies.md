---
lang: zh-CN
page_id: core-gateway/policies
permalink: /core-gateway/policies.html
title: 策略
parent: 核心网关
nav_order: 5
description: "将护栏、提示词、记忆与 Token 节省打包为命名策略，并绑定到密钥或模型以自动激活。"
---

# 策略

**策略**是一个命名的、按组织作用域限定的 AI 能力束。你无需在每个请求上传入 `guardrail_id`、`prompt_id`、`memory_id` 和 `token_saving_plan_id`，而是把它们一次性组合成一个策略，再将该策略绑定到某个**密钥**或**模型**。随后网关会在每个匹配的请求上自动激活这些能力。

{: .note }
策略是一个**治理**原语，而非路由规则。它不决定由哪个模型服务请求——那是[路由]({% link zh-CN/core-gateway/routing.md %})与[自动路由]({% link zh-CN/core-gateway/auto-router.md %})的职责。策略负责打包的是*在模型确定之后*作用于请求的那些能力。

---

## 四种能力类型

一个策略对每种类型绑定一个资源。每种类型都映射到一个 [AI 能力]({% link zh-CN/advanced-features.md %})钩子已经识别的请求字段：

| 能力类型 | 请求字段 | 激活的内容 |
|---|---|---|
| `prompt` | `prompt_id` | 一个有版本的提示词模板（[提示词管理]({% link zh-CN/advanced-features/prompt-management.md %})） |
| `memory` | `memory_id` | 一个长期记忆会话（[记忆即服务]({% link zh-CN/advanced-features/memory-service.md %})） |
| `token_saving` | `token_saving_plan_id` | 一个压缩 + 缓存方案（[Token 节省]({% link zh-CN/advanced-features/token-saving.md %})） |
| `guardrail` | `guardrail_id` | 一个内容安全配置（[护栏]({% link zh-CN/advanced-features/guardrails.md %})） |

一个策略对**每种类型最多绑定一个资源**（因此最多四个绑定），且至少要绑定一个。大多数策略会捆绑多项——例如一个面向客户的智能体策略可能同时包含系统提示词、PII 护栏、记忆会话与 Token 节省方案。

---

## 策略如何绑定

策略通过一个 `policy_id` 引用绑定到且仅绑定到两处：

- **在虚拟密钥上** —— 每个用该密钥认证的请求都会应用该策略。
- **在模型上** —— 每个发往该模型组的请求都会应用该策略。

没有团队级或组织级绑定，且一个密钥或模型各自最多携带一个策略。因此单个请求可能同时看到**两个**策略——一个来自其密钥，一个来自其模型——由网关合并（见下文）。

---

## 创建策略

### 从仪表板

在管理导航中打开 **Policies**，选择 **Create Policy**。表单要求填写名称、可选的描述，以及每种类型各一个能力选择器（每个都按你组织现有的提示词、记忆会话、Token 节省方案和护栏过滤）。至少选择一项能力后保存。

![Policies 列表页面，带 Create Policy 按钮](/assets/images/policies/policies-list.png)

![Create Policy 抽屉——名称、描述，以及四个能力选择器](/assets/images/policies/create-policy-drawer.png)

### 从 API

```bash
POST /policies
X-Organization-Id: org-abc
Content-Type: application/json

{
  "policy_name": "standard-agent",
  "description": "面向客户的智能体默认配置",
  "capabilities": [
    { "capability_type": "prompt",       "capability_id": "<prompt-uuid>" },
    { "capability_type": "memory",       "capability_id": "<memory-session-uuid>" },
    { "capability_type": "guardrail",    "capability_id": "<guardrail-uuid>" },
    { "capability_type": "token_saving", "capability_id": "<token-saving-plan-uuid>" }
  ]
}
```

响应会返回该策略的 `policy_id`。策略名称在组织内唯一。

其他端点：

| 方法 | 路径 | 用途 |
|---|---|---|
| `GET` | `/policies/list` | 列出策略（分页，可按名称搜索） |
| `GET` | `/policies/{policy_id}` | 获取单个策略 |
| `PUT` | `/policies/{policy_id}` | 更新名称、描述或能力 |
| `DELETE` | `/policies/{policy_id}` | 删除策略并清除所有引用它的绑定 |
| `GET` | `/policies/{policy_id}/resolved-capabilities` | 显示有效绑定与 `dangling`（目标已删除/组织不符）绑定 |

---

## 绑定策略

### 绑定到密钥

在密钥详情页打开 **Policy** 标签页并选择一个策略。或直接更新密钥——在密钥的创建和更新中都接受顶层的 `policy_id`：

![密钥详情页上的 Policy 标签页](/assets/images/policies/key-policy-tab.png)

```bash
PUT /key/update
{ "key": "sk-xxxx", "policy_id": "<policy_id>" }
```

### 绑定到模型

在模型详情页展开 **Policy** 区块并选择一个策略。或直接 patch 模型：

![模型详情页上的 Policy 区块](/assets/images/policies/model-policy-section.png)

```bash
PATCH /model/update
{ "model_id": "<model_id>", "policy_id": "<policy_id>" }
```

策略只能在其所属组织内绑定——网关会拒绝跨组织绑定。

---

## 请求时发生什么

当一个请求到达时，网关解析密钥策略与模型策略（若有），将其合并，并注入能力 ID，就如同调用方手动传入一样。随后既有的逐能力钩子按其正常顺序运行：

```
GuardrailHook → PromptHook → TokenSavingPlanHook → MemoryHook
```

### 优先级（按能力类型）

```
调用方显式字段  >  密钥策略  >  模型策略
```

- 如果调用方已在请求上设置了 `prompt_id`（或任何其他能力字段），该值胜出，**对于该类型**忽略策略。
- 否则该类型的密钥策略绑定胜出。
- 否则应用该类型的模型策略绑定。

因此，模型可以提供合理的默认值（一个提示词、一个护栏），而单个密钥只覆盖它关心的部分——开发者则始终可以按请求覆盖一切。

{: .note }
策略**失败开放（fail open）**。如果解析器遇到错误，请求仍会继续，只是不应用策略的能力，而不是被拦截。

---

## 失效引用与清理

如果策略所指向的某项能力随后被**删除**（或迁移到其他组织），该绑定即变为 **dangling（失效）**：

![策略详情视图——有效的能力卡片，以及带警告标记的失效引用](/assets/images/policies/policy-detail.png)

- `GET /policies/{id}/resolved-capabilities` 会把它列在 `dangling` 下，策略详情页会显示警告。
- 请求时，失效绑定会被**静默跳过**——策略中的其他绑定照常生效。

删除策略本身是安全的：网关会自动从每一个引用它的密钥和模型上清除 `policy_id`，因此不会有失效绑定残留。

---

## 组织隔离与权限

- **按组织作用域限定。** 策略属于一个组织。列表、读取、创建、编辑与删除均按组织经 Cerbos（`org:policy:common`）授权；用户只能看到自己组织的策略。
- **能力引用保持在组织内。** 策略只能引用同一组织拥有的能力。
- **谁能管理。** 平台管理员与组织管理员可以创建、编辑和删除策略。策略页上的组织选择器面向平台管理员。

---

## 策略不是什么

为避免误解，特此说明：

- **不是路由规则。** 策略不会基于内容、地域、预算或计划选择模型。请使用[路由与负载均衡]({% link zh-CN/core-gateway/routing.md %})或[自动路由]({% link zh-CN/core-gateway/auto-router.md %})。
- **不是预算或访问控制的替代品。** 支出上限在[预算与支出护栏]({% link zh-CN/core-gateway/budgets.md %})中；谁能调用什么在[访问控制与审计]({% link zh-CN/core-gateway/sso-rbac-audit.md %})中。
- **没有继承或通配。** 策略是一个最多四项能力绑定的扁平列表——没有基础策略、没有作用域模式、没有增删清单。
- **没有 YAML 配置文件。** 策略通过仪表板或管理 API 管理，并存储在数据库中；变更会实时传播到所有代理实例。

→ 策略可绑定的四类资源，参见 [AI 能力]({% link zh-CN/advanced-features.md %})。
→ 组织/管理员权限模型，参见 [访问控制与审计]({% link zh-CN/core-gateway/sso-rbac-audit.md %})。
