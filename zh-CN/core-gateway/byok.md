---
lang: zh-CN
page_id: core-gateway/byok
permalink: /core-gateway/byok.html
title: 自带密钥（BYOK）
parent: LLM 网关
nav_order: 3
description: "使用你自己的供应商 API 密钥——你直接向供应商付费，Routero 仅收取加价。"
---

# 自带密钥（BYOK）

默认情况下，Routero 持有供应商密钥，并按每个请求的完整成本向你计费。使用 **BYOK** 时，你为自己的组织添加自己的供应商 API 密钥——你直接向供应商付费，Routero 只在其之上收取加价。

BYOK 是**按供应商**设置的：添加你的 OpenAI 密钥后，你的组织发起的每一个 OpenAI 请求都按“仅加价”计费。其他供应商在你为其添加密钥之前，仍使用 Routero 的密钥。

{: .note }
BYOK 仅对**组织管理员**开放。团队管理员和普通成员看不到。

---

## 添加你的密钥

在侧边栏打开 **BYOK**，选择 **Add BYOK Key**。

![BYOK 页面——本组织直接付费的每个供应商都带有 BYOK · markup only 标记](/assets/images/byok/byok-list.png)

在抽屉中选择一个 **Provider**，并粘贴 **Your API Key**。该密钥会加密存储并归属到你的组织——只需 provider 和密钥两项即可。

![Add BYOK Key 抽屉——选择供应商并粘贴你的 API 密钥](/assets/images/byok/byok-add-key.png)

该供应商随后出现在列表中，带有 **BYOK · markup only** 标记。每个供应商只能添加一个密钥；如需更换，请使用轮换。

---

## 轮换或移除

- **Rotate（轮换）** —— 用新密钥替换旧密钥。该供应商仍保持 BYOK。
- **Remove（移除）** —— 删除你的密钥。该供应商会立即回退到 Routero 的平台密钥（无空档），请求恢复正常计费。

---

## BYOK 的计费方式

当请求使用你已切换为 BYOK 的供应商时：

- **你用自己的密钥直接向供应商付费**——Routero 不替你支付。
- **Routero 仅收取加价**（按组织的折扣不适用于 BYOK 流量）。
- 你的**预算与支出**仍反映全额——你付给供应商的金额加上加价——因此支出追踪保持准确。

BYOK 请求仍会出现在[日志]({% link zh-CN/observability/logs.md %})与[用量]({% link zh-CN/observability/usage.md %})中，并带有 **BYOK** 标记。在日志行中，成本会拆分为 **Billed to us (markup)** 与 **Paid to vendor directly**。

---

## BYOK 不是什么

- 它是**按组织、按供应商**的——不是按团队或按模型。
- 它不允许你设置**自定义端点**（例如自托管网关或 Azure 资源）。如需如此，请联系你的平台管理员。
- 添加模型，或模型上的“Re-use Credentials”操作，与 BYOK 计费无关。

---

## 相关内容

→ [路由与负载均衡]({% link zh-CN/core-gateway/routing.md %})与[故障转移与回退]({% link zh-CN/core-gateway/failover.md %})——你的 BYOK 密钥与普通密钥一样参与路由与故障转移。
→ BYOK 支出参见[用量]({% link zh-CN/observability/usage.md %})。
