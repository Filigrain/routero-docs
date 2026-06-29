---
lang: zh-CN
page_id: core-gateway/sso-rbac-audit
permalink: /core-gateway/sso-rbac-audit.html
title: SSO、RBAC 与审计
parent: 核心网关
nav_order: 6
description: "SAML 2.0、SCIM、Cerbos 细粒度授权，以及不可篡改的审计日志。"
---

# SSO、RBAC 与审计

Routero 回答你的安全团队早已在问的问题：谁可以调用哪个模型、谁实际调用了、哪些提示词接触了 PII，以及已离职员工的密钥是否仍然有效。

> *“带上你的 IdP，带走审计日志。”*

---

## 身份：SAML 2.0 + SCIM

**SAML 2.0 SSO** —— 支持的 IdP：Okta、Microsoft Entra（Azure AD）、Google Workspace、Auth0、Ping Identity，以及任何标准 SAML 2.0 IdP。首次登录时进行 JIT 预配。

**SCIM 2.0 自动预配** —— 从你的 IdP 同步用户和用户组。注销是自动的：当某员工从 IdP 用户组中被移除时，其 Routero 访问权限及关联的虚拟密钥会在数秒内被撤销。

---

## 授权：Cerbos RBAC + PBAC

Routero 使用 [Cerbos](https://cerbos.dev) 作为外部化的策略决策点。每一项管理操作和数据平面操作在执行前都会针对一组人类可读的 YAML 策略进行检查。

**内置 RBAC 角色：**

| 角色 | 可执行的操作 |
|---|---|
| **Admin（管理员）** | 完整的工作区控制——模型、密钥、团队、计费、策略 |
| **Developer（开发者）** | 创建和使用 API 密钥；查看自己密钥的支出 |
| **Auditor（审计员）** | 对审计日志、支出报告和密钥元数据的只读访问 |
| **Finance（财务）** | 对计费、支出、发票和费用分摊报告的只读访问 |
| **Custom（自定义）** | 企业版套餐：定义你自己的角色，精确指定资源权限 |

Cerbos 策略与应用一同进行版本控制。策略变更本身即为审计事件。

---

## 虚拟 API 密钥

虚拟密钥是 LLM 流量的主要鉴权原语。每个密钥：
- 作用范围限定到工作区、团队或单个用户
- 携带可选的模型允许列表（拒绝访问未经批准的模型）
- 拥有可配置的 TTL（过期时间）
- 可以进行 IP 限制（CIDR 允许列表）
- 可通过仪表板或 `DELETE /key/delete` 即时撤销
- 永远不会向调用方暴露底层供应商的 API 密钥

```bash
# 生成一个限定作用范围的密钥
curl -X POST https://api.routero.ai/key/generate \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{
    "models": ["smart/balanced", "openai/gpt-4o"],
    "team_id": "engineering",
    "max_budget": 100,
    "duration": "30d"
  }'
```

---

## 不可篡改的审计日志

Routero 中的每个重要事件都会被写入一份不可篡改、仅追加、经过加密签名的审计日志。事件以链式方式串联（每条记录都包含前一条的哈希），因此任何篡改都可被检测到。

**记录的事件类型：**

| 类别 | 事件 |
|---|---|
| 推理 | `request.routed`、`request.blocked`、`request.failed`、`request.guardrail_triggered` |
| 策略 | `policy.evaluated`、`policy.changed`（v17 → v18）、`policy.blocked` |
| 身份 | `user.provisioned`、`user.deprovisioned`、`key.created`、`key.rotated`、`key.revoked` |
| 访问 | `login.success`、`login.failed`、`mfa.challenged` |
| 计费 | `budget.threshold_reached`、`budget.exceeded`、`spend.debited` |

**保留期：** 默认 365 天；企业版套餐可配置至 7 年。

**导出：** 通过 webhook、Kafka 或每小时 S3 投递将日志流式传输到你的 SIEM。→ [SIEM 与审计导出]({% link zh-CN/observability/siem-audit.md %})

---

## 合规

| 认证 | 状态 |
|---|---|
| SOC 2 Type II | 年度审计——报告可应要求提供 |
| HIPAA BAA | 企业版套餐 |
| ISO 27001 | 进行中 |
| GDPR DPA + SCCs | 面向欧盟客户提供 |

→ [合规]({% link zh-CN/security-trust/compliance.md %})
