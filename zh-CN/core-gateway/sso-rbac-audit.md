---
lang: zh-CN
page_id: core-gateway/sso-rbac-audit
permalink: /core-gateway/sso-rbac-audit.html
title: 访问控制与审计
parent: 核心网关
nav_order: 7
description: "管理员邀请访问、Cerbos 细粒度授权、限定范围的虚拟密钥，以及管理员审计日志。"
---

# 访问控制与审计

Routero 回答你的安全团队早已在问的问题：谁可以调用哪个模型、谁更改了某个密钥或预算、以及被撤销的密钥是否仍然有效。

---

## 访问与登录

对 Routero 工作区的访问采用**邀请制**。没有公开的自助注册。

- **管理员**从仪表板（或管理 API）创建用户和团队，并发放邀请链接。
- 受邀者通过邀请设置自己的访问权限，并使用自己的凭据**直接登录**。
- 产品未接入任何第三方社交登录或 SSO（Google、Microsoft、SAML 等）——身份由你的管理员在 Routero 内部管理。

{: .note }
创建用户和发送邀请需要**管理员**角色。参见下方的[授权](#授权cerbos-rbac--pbac)。

---

## 授权：Cerbos RBAC + PBAC

Routero 使用 [Cerbos](https://cerbos.dev) 作为外部化的策略决策点。每一项管理操作和数据平面操作在执行前都会针对一组人类可读的 YAML 策略进行检查。

**内置角色：**

| 角色 | 可执行的操作 |
|---|---|
| **Proxy Admin（平台管理员）** | 完整的工作区控制——模型、密钥、团队、计费、策略、用户 |
| **Org Admin（组织管理员）** | 管理其所在组织——成员、密钥、模型和预算，范围限定到该组织 |
| **Internal User（内部用户）** | 创建和使用自己的 API 密钥；查看自己的支出 |
| **Internal User（只读）** | 对支出和密钥元数据的只读访问 |
| **Proxy Admin（只读）** | 对整个工作区的只读监督 |

角色由路由网关和 Cerbos 策略检查共同强制执行。策略变更本身也会作为审计事件被记录。

---

## 虚拟 API 密钥

虚拟密钥是 LLM 流量的主要鉴权原语。每个密钥：

- 作用范围限定到工作区、团队或单个用户
- 携带可选的模型允许列表（拒绝访问未经批准的模型）
- 拥有可配置的 TTL（过期时间）
- 可通过仪表板或 `DELETE /key/delete` 即时撤销
- 永远不会向调用方暴露底层供应商的 API 密钥

```bash
# 生成一个限定作用范围的密钥（管理员操作）
curl -X POST https://api.routero.ai/key/generate \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{
    "models": ["smart/balanced", "openai/gpt-4o"],
    "team_id": "engineering",
    "max_budget": 100,
    "duration": "30d"
  }'
```

{: .note }
`/key/generate` 是一项**管理员**操作。普通消费密钥仅用于推理调用（`/chat/completions`、`/embeddings`……），不能用于创建更多密钥。

---

## 审计日志

Routero 会记录**管理操作**的审计日志——谁在何时更改了什么。每一次密钥、用户、模型、团队或预算的创建、更新、删除、封禁和轮换都会被记为一条审计记录，包含操作用户、操作密钥、受影响资源以及前/后值。

**记录的内容：**

| 类别 | 示例 |
|---|---|
| 密钥 | 创建 · 更新 · 删除 · 封禁 · 轮换 |
| 用户 | 创建 · 更新 · 删除 |
| 模型 | 新增 · 更新 · 移除 |
| 团队与组织 | 创建 · 更新 · 成员变更 |
| 预算 | 创建 · 更新 · 删除 |

可从仪表板或管理 API（`GET /audit`、`GET /audit/{id}`）查询审计日志，范围限定到你的组织。敏感值（如密钥内容）在存储前会被掩码处理。→ [审计日志参考]({% link zh-CN/security-trust/audit-log.md %})

---

## 合规

| 认证 | 状态 |
|---|---|
| SOC 2 Type II | 年度审计——报告可应要求提供 |
| HIPAA BAA | 企业版套餐 |
| ISO 27001 | 进行中 |
| GDPR DPA + SCCs | 面向欧盟客户提供 |

→ [合规]({% link zh-CN/security-trust/compliance.md %})
