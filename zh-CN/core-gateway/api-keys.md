---
lang: zh-CN
page_id: core-gateway/api-keys
permalink: /core-gateway/api-keys.html
title: API 密钥
parent: LLM 网关
nav_order: 2
description: "创建并管理虚拟密钥——你的应用调用 Routero 时使用的凭据。"
---

# API 密钥

**虚拟密钥**是你的应用调用 Routero 时使用的凭据。可为每个应用或环境创建一个，限定到具体模型、附加预算，并随时撤销。密钥永远不会暴露底层的供应商密钥。

在侧边栏打开 **API Keys**。

---

## API Keys 页

列表显示每个密钥的名称、可调用的模型、所属团队与所有者、支出对预算的进度、速率限制以及创建时间。点击某个密钥可打开其详情。

![API Keys 页——你的虚拟密钥，含模型、支出与速率限制](/assets/images/api-keys/api-keys-list.png)

---

## 创建密钥

选择 **+ Create New Key**：

1. **Owned By** —— 你自己，或某个服务账号。
2. **Key Name** —— 密钥的名称。
3. **Models** —— 该密钥可调用哪些模型（默认 “All Proxy Models”，也可选择具体模型）。
4.（可选）**Budget & Rate Limits** —— 最高预算、软告警、重置周期与 TPM/RPM 限制。

点击 **Create Key**，并从弹窗中**复制密钥**（`sk-…`）——它只显示一次。

![Create New Key 抽屉，以及显示 sk-… 密钥的 Save-your-key 对话框](/assets/images/api-keys/api-keys-create.png)

完整的分步流程参见[快速开始](/)。

---

## 密钥详情

密钥详情页有六个标签：

- **Overview** —— 支出对预算、速率限制、用量。
- **Settings** —— 编辑密钥名称、模型、预算与速率限制。
- **Router Settings** —— 该密钥的负载均衡策略与回退链。→ [路由]({% link zh-CN/core-gateway/routing.md %}) · [故障转移]({% link zh-CN/core-gateway/failover.md %})
- **Policy** —— 绑定一个[策略]({% link zh-CN/core-gateway/policies.md %})，让能力在该密钥的每个请求上自动激活。
- **Model Aliases** —— 为该密钥重映射模型名。
- **Key Lifecycle** —— 轮换与过期。

![密钥详情——六个标签：Overview / Settings / Router Settings / Policy / Model Aliases / Key Lifecycle](/assets/images/api-keys/api-keys-detail.png)

{: .note }
密钥默认不过期（“Expires”列显示 “Never”）。删除密钥即可立即撤销。

---

## 相关内容

→ [策略]({% link zh-CN/core-gateway/policies.md %})——为密钥绑定能力。
→ [预算限额]({% link zh-CN/observability/budget-limits.md %})——密钥预算如何执行。
→ [快速开始](/)——创建你的第一个密钥。
