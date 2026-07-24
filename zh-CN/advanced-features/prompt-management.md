---
lang: zh-CN
page_id: advanced-features/prompt-management
permalink: /advanced-features/prompt-management.html
title: 提示词管理
parent: AI 能力
nav_order: 3
description: "基于数据库的提示词注册表，支持不可篡改的版本管理、Jinja2 模板与按版本固定。"
---

# 提示词管理

提示词管理将提示词工程与应用部署解耦。提示词团队在一个具备完整版本历史的中央注册表中维护模板；应用引用一个永不改变的稳定 `prompt_id`，即使底层模板不断演进也是如此。

{: .note }
Routero 提示词管理是**一个由你的工作区拥有、基于数据库的注册表**——有别于供应商侧的“提示词缓存”功能，也不同于 Langfuse 或 Humanloop 等外部集成。模板存储于 `LiteLLM_PromptTable`，并在请求时用 Jinja2 渲染。

---

## 工作原理

当请求携带 `prompt_id` 时，网关获取模板、渲染其 Jinja2 变量，并在调用模型之前将渲染后的消息**前置**到请求中。该钩子在护栏之后、Token 节省与记忆之前运行：

```
GuardrailHook → PromptHook → TokenSavingPlanHook → MemoryHook
```

`prompt_id`、`prompt_variables` 与 `prompt_version` 是代理内部参数——它们不会被转发给上游供应商。

---

## 激活

```python
response = client.chat.completions.create(
    model="openai/gpt-5.5",
    messages=[{"role": "user", "content": "Summarise Q3 results"}],
    extra_body={
        "prompt_id": "analyst-system",
        "prompt_variables": {
            "company": "Acme Corp",
            "language": "English",
            "tone": "executive"
        },
        # 可选：固定到特定版本
        # "prompt_version": 2
    },
)
```

可在顶层或 `metadata` 中传入 `prompt_id`（顶层优先）。提示词也可[通过策略绑定]({% link zh-CN/core-gateway/policies.md %})，从而自动激活。

---

## 概念

**`prompt_id`** —— 在首次创建提示词时分配的稳定 UUID。这是调用方存储并传递的内容。它不会随版本变化而改变。

**版本（Version）** —— 每次更新都会创建一个不可篡改的新版本：`version` 递增，旧版本保留，`is_latest` 翻转到新行。旧版本从不被原地修改。没有版本数量上限——版本会不断累积。（若更新未改变任何内容则为空操作：不会创建新版本。）

**模板（Template）** —— 一个由 `{role, content}` 对象组成的 `messages` 数组（`role` 为 `system`、`user` 或 `assistant`），可选带 Jinja2 变量。缺失的变量会渲染为空字符串——渲染过程绝不会抛出异常。

---

## 版本管理与固定

用 `prompt_version` 将单个请求固定到先前版本：

```python
extra_body={"prompt_id": "analyst-system", "prompt_version": 1}
```

不传 `prompt_version` 时，网关始终使用最新版本。若要将所有流量切回某个较旧的模板，用该模板的内容更新提示词——它就会成为新的最新版本。

---

## 创建与更新提示词

打开 **Prompts**，选择 **Create Prompt**。表单包含 **Prompt Name**、可重复的 **Messages** 列表（角色 + 内容，支持 `{{variable}}` 占位符），以及可选的 **Variables**（键 + 描述对）。编辑现有提示词会打开 **Edit Prompt (New Version)**，并在保存时创建一个新的不可篡改版本。名称在组织内唯一。

![提示词列表页面，带 Create Prompt 按钮](/assets/images/prompt-management/prompts-list.png)

![Create Prompt 抽屉——名称、带角色的消息列表与变量](/assets/images/prompt-management/create-prompt-drawer.png)

提示词详情页显示当前版本、**latest** 徽章，以及一个 **Version History** 选择器，可查看任意先前版本。

![提示词详情视图——版本标签、最新徽章与版本历史选择器](/assets/images/prompt-management/prompt-detail.png)

---

## 缓存

提示词模板缓存于两个层级，使高负载下解析仍然很快：

- **进程内缓存** —— 每个代理实例 5 分钟 TTL
- **Redis 缓存** —— 1 天 TTL，在所有代理副本间共享

只有最新版本会被缓存；指定版本的读取总是绕过缓存。创建或更新后，最新条目会立即写入。删除时，两层中的条目会在约 5 秒内被失效。

---

## 组织隔离与权限

- **按组织作用域。** 提示词属于一个组织。列表、读取、创建、编辑与删除均通过 Cerbos（`org:prompt:common`）按组织授权。
- **IDOR 保护。** 名称查找以 `name + organization_id` 为作用域；非管理员针对其他组织提示词的操作会被拒绝。
- **谁能管理。** 代理管理员与组织管理员可创建、编辑和删除提示词。未选择组织的代理管理员可看到所有组织的提示词。

{: .note }
`organization_id` 为 null 的提示词会被视为**全局的**（任何调用方均可解析），数据库也允许该值——但你无法通过仪表板创建它，因为创建提示词需要提供组织。全局提示词只能通过直接写入数据库来创建。

---

## 与网关其余部分的组合

- **策略** —— 将提示词绑定到[策略]({% link zh-CN/core-gateway/policies.md %})中，使其在密钥或模型上自动注入。
- **护栏 / 记忆 / Token 节省** —— 其余 [AI 能力]({% link zh-CN/advanced-features.md %})按各自正常顺序作用于同一请求。
- **Playground** —— 选择一个提示词并填入其变量，针对在线模型测试渲染后的模板。

→ 关于将提示词绑定到密钥与模型，参见 [策略]({% link zh-CN/core-gateway/policies.md %})。
