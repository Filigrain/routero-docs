---
lang: zh-CN
page_id: advanced-features/guardrails
permalink: /advanced-features/guardrails.html
title: 护栏
parent: AI 能力
nav_order: 2
description: "内容过滤、PII 脱敏、密钥检测与工具权限强制执行——集中管理、按组织强制执行。"
---

# 护栏

**护栏**是一种以组织为范围的具名配置，可对请求和响应应用一个或多个安全引擎。护栏在网关内部运行——在模型看到提示词之前以及在它响应之后——无需更改一行应用代码。

{: .note }
护栏回答了法务部门的问题：*“模型看到了什么？”* 当某个引擎拦截或脱敏内容时，网关会返回一条明确的违规消息，且绝不会将违规内容转发给供应商。护栏配置按组织作用域限定，并通过[访问控制与审计]({% link zh-CN/core-gateway/sso-rbac-audit.md %})进行权限控制。

---

## 工作原理

一个护栏持有一个有序的**引擎**列表。在聊天请求到达时，网关用护栏的调用前（pre-call）引擎检查提示词；模型响应之后，再用调用后（post-call）引擎检查响应。每个引擎接收前一个引擎（可能已被修改）的输出。引擎要么：

- **拦截（Block）** —— 以 HTTP `400` 和一条违规消息拒绝请求，要么
- **转换（Transform）** —— 脱敏或匿名化违规内容，让请求继续。

护栏在调用前钩子链中**最先**运行，因此安全引擎会在任何提示词模板注入或压缩之前检查调用方的原始输入：

```
GuardrailHook → PromptHook → TokenSavingPlanHook → MemoryHook
```

{: .note }
这是基于数据库的护栏服务——有别于上游 LiteLLM 基于配置的护栏（`metadata.guardrails`、`disable_global_guardrails`）。两套系统相互独立；本页仅介绍由 `guardrail_id` 激活、在仪表板中管理的护栏。

---

## 内置引擎

四个引擎可在单个护栏中组合使用。每个引擎有一组配置字段（见下文），并可选择**事件钩子**——`pre_call`（检查提示词）、`post_call`（检查响应）或两者皆有。

### 内容过滤（Content Filter）
拦截匹配关键字或正则表达式模式的请求和响应。在 `pre_call` 和 `post_call` 均运行。

| 配置项 | 说明 |
|---|---|
| `banned_keywords` | 不区分大小写的子串匹配列表 |
| `banned_patterns` | 带 `IGNORECASE` 的正则表达式列表 |
| `violation_message` | 自定义拦截消息（默认：`Request blocked by content filter.`） |

无额外依赖。仅拦截（不做脱敏）。

---

### 工具权限（Tool Permission）
在调用模型之前，对函数/工具名称强制执行允许列表或拒绝列表。仅在 `pre_call` 运行。

| 配置项 | 说明 |
|---|---|
| `allowed_tools` | 白名单——仅允许这些工具名称。省略则允许全部。 |
| `blocked_tools` | 黑名单——始终拦截，优先级高于白名单。 |
| `on_violation` | `block`（默认——拒绝请求）或 `remove`（静默剥离被禁用的工具） |
| `violation_message` | 自定义拦截消息（默认：`Tool call not permitted.`） |

无额外依赖。

---

### PII 检测（Presidio）
使用 [Microsoft Presidio](https://microsoft.github.io/presidio/) 检测并匿名化个人身份信息。在 `pre_call` 和 `post_call` 均运行。

| 配置项 | 说明 |
|---|---|
| `entities` | 要检测的 Presidio 实体类型——例如 `PERSON`、`EMAIL_ADDRESS`、`PHONE_NUMBER`、`CREDIT_CARD`、`US_SSN`、`IBAN_CODE`、`IP_ADDRESS`。省略（或 `null`）则检测你安装的 `presidio-analyzer` 中**全部**识别器。 |
| `language` | 文本语言（默认：`en`） |
| `action` | `anonymize`（默认——将每段 PII 替换为带类型的占位符，如 `<PERSON>`）或 `block`（发现任何 PII 即拒绝） |
| `score_threshold` | Presidio 最低置信度（默认：`0.5`） |
| `violation_message` | 自定义拦截消息（默认：`Request contains PII and was blocked.`） |

**依赖项：** `presidio-analyzer`、`presidio-anonymizer`。Presidio 在网关内本地运行——PII 绝不会离开你的基础设施去往外部审核厂商。

{: .note }
`entities` 是开放的：你传入的任何字符串都会直接转发给 Presidio，因此可用集合取决于你安装的识别器。请勿将上面的示例视为固定列表。

---

### 密钥检测（detect-secrets）
使用 [Yelp detect-secrets](https://github.com/Yelp/detect-secrets) 检测提示词中泄露的凭据。仅在 `pre_call` 运行。

| 配置项 | 说明 |
|---|---|
| `action` | `redact`（默认——将每个密钥替换为 `[REDACTED]`）或 `block`（拒绝） |
| `plugins` | 要启用的检测器短名列表。省略（或 `null`）则启用**全部**检测器。未知名称会被拒绝。 |
| `violation_message` | 自定义拦截消息（默认：`Request contains secrets and was blocked.`） |

21 个内置检测器短名：`aws`、`artifactory`、`azure`、`basic_auth`、`base64_entropy`、`cloudant`、`discord`、`github`、`hex_entropy`、`ibm_cos`、`ibm_iam`、`jwt`、`mailchimp`、`npm`、`private_key`、`sendgrid`、`slack`、`softlayer`、`square`、`stripe`、`twilio`。

**依赖项：** `detect-secrets`。

---

## 激活

调用方通过在请求中传入护栏 ID（顶层或 `metadata` 内）来激活护栏：

```python
response = client.chat.completions.create(
    model="smart/balanced",
    messages=[{"role": "user", "content": user_input}],
    extra_body={"guardrail_id": "pii-redact-prod"},
)
```

网关从调用方所属组织解析护栏，作为钩子运行，并在转发给供应商之前剥离 `guardrail_id`。护栏也可以[通过策略绑定]({% link zh-CN/core-gateway/policies.md %})，从而在每个匹配请求上自动激活——无需逐请求传字段。

当配置为 `block` 的引擎触发时，网关返回 HTTP `400`，违规消息位于标准错误体中：

```json
{
  "detail": "Request blocked by guardrail."
}
```

---

## 创建护栏

在管理导航中打开 **Guardrails**，选择 **Create Guardrail**。为护栏命名，添加一个或多个引擎，并为每个引擎选择其**事件钩子**（`pre_call`、`post_call`）并填写其**配置**。配置表单根据引擎的 schema 动态生成，因此字段与上方各表一致。一个护栏至少需要一个引擎，名称在组织内唯一。

![护栏列表页面，带 Create Guardrail 按钮](/assets/images/guardrails/guardrails-list.png)

![Create Guardrail 抽屉——名称、引擎类型、事件钩子与按引擎的配置表单](/assets/images/guardrails/create-guardrail-drawer.png)

{: .note }
仪表板的引擎选择器列出 **Content Filter**、**Tool Permission** 和 **Secret Detection**。**Presidio** 完全受支持，但目前尚未在选择器中显示。

![护栏详情视图——引擎卡片，带事件钩子标签与配置值](/assets/images/guardrails/guardrail-detail.png)

---

## 组织隔离与权限

- **按组织作用域。** 护栏属于一个组织。表 `LiteLLM_GuardrailsTable` 存储了 `organization_id`，并强制 `(organization_id, guardrail_name)` 唯一。
- **IDOR 保护。** 每一项操作都通过 Cerbos（`org:guardrail:common`）按组织授权；网关在解析时也会检查护栏所属组织，不匹配则拒绝。
- **谁能管理。** 代理管理员与组织管理员可创建、编辑和删除护栏。护栏页面上的组织选择器对代理管理员可用。

---

## 依赖与启用

| 引擎 | 可选依赖 | 运行时机 |
|---|---|---|
| Content Filter | — | pre & post |
| Tool Permission | — | pre |
| Secret Detection | `detect-secrets` | pre |
| Presidio PII | `presidio-analyzer`、`presidio-anonymizer` | pre & post |

Content Filter 与 Tool Permission 开箱即用。Presidio 与 Secret Detection 引擎需要各自的 Python 包；若请求命中某个依赖缺失的引擎，网关会给出明确的安装提示。

---

## 与网关其余部分的组合

- **策略** —— 将护栏绑定到[策略]({% link zh-CN/core-gateway/policies.md %})中，使其在密钥或模型上自动激活。
- **提示词 / 记忆 / Token 节省** —— 其余 [AI 能力]({% link zh-CN/advanced-features.md %})在护栏运行之后按各自正常顺序作用于同一请求。
- **Playground** —— 在 Advanced Settings 下选择护栏，针对在线模型进行测试。

→ 关于将护栏绑定到密钥与模型，参见 [策略]({% link zh-CN/core-gateway/policies.md %})。
→ 关于组织/管理员权限模型，参见 [访问控制与审计]({% link zh-CN/core-gateway/sso-rbac-audit.md %})。
