---
lang: zh-CN
page_id: guides/multi-team-workspace
permalink: /guides/multi-team-workspace.html
title: 治理多团队工作区
parent: 指南
nav_order: 4
description: "为多团队企业部署设置组织、团队、RBAC 角色、按团队的预算以及模型访问控制。"
---

# 治理多团队工作区

本指南面向为多个内部团队搭建 Routero 的平台工程师或 AI 基础设施负责人。目标：每个团队拥有自己的密钥、预算和模型允许列表；中央管理员拥有完整的可见性；解除预置即时生效。

---

## 设计模式

```
Workspace (org)
  ├── Team: data-science    $2000/mo   → can use any model
  ├── Team: customer-ops    $500/mo    → can use smart/balanced only
  ├── Team: finance         $800/mo    → EU-residency required
  └── Team: engineering     $1500/mo   → any model, plus Cursor keys
```

---

## 步骤 1 — 创建团队

```bash
# Create each team
for TEAM in "data-science:2000" "customer-ops:500" "finance:800" "engineering:1500"; do
  NAME="${TEAM%%:*}"; BUDGET="${TEAM##*:}"
  curl -X POST https://api.routero.ai/team/new \
    -H "Authorization: Bearer $ADMIN_KEY" \
    -d "{\"team_alias\": \"$NAME\", \"max_budget\": $BUDGET, \"budget_duration\": \"1mo\"}"
done
```

---

## 步骤 2 — 为每个团队分配模型允许列表

```bash
# customer-ops: lock to smart/balanced only
curl -X POST https://api.routero.ai/team/update \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{"team_id": "customer-ops", "models": ["smart/balanced"]}'

# finance: lock to EU-residency route
curl -X POST https://api.routero.ai/team/update \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{"team_id": "finance", "models": ["eu/balanced"]}'
```

---

## 步骤 3 — 设置 RBAC 角色

```bash
# Grant the data-science lead Developer role
curl -X POST https://api.routero.ai/organization/member_permission_update \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{"user_email": "data-lead@company.com", "user_role": "internal_user", "team_id": "data-science"}'

# Grant finance controller Auditor role (read-only)
curl -X POST https://api.routero.ai/organization/member_permission_update \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{"user_email": "controller@company.com", "user_role": "internal_viewer"}'
```

---

## 步骤 4 — 设置 SSO

在控制台的 **Settings → SSO** 下，配置你的 SAML IdP。在 **Settings → SCIM** 下启用 SCIM，以便从 Okta 或 Azure AD 自动预置/解除预置团队成员身份。

一旦 SCIM 激活，将某员工从 IdP 组中移除后，会自动撤销其 Routero 访问权限及关联的虚拟密钥。

---

## 步骤 5 — 生成团队密钥

为每个团队生成一个供共享使用的密钥，并可选地为开发者环境生成按人划分的密钥：

```bash
curl -X POST https://api.routero.ai/key/generate \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{"team_id": "data-science", "key_alias": "ds-prod", "duration": "90d"}'
```

---

## 日常管理

- **每月预算重置** — 预算会按 `budget_duration` 自动重置。无需任何操作。
- **预算告警** — 在 `POST /config/update` 处配置 Slack 告警，设置 `alerting: ["slack"]` 及你的 webhook URL。
- **审计支出** — 使用 `GET /billing/daily-spend` 查看组织视图；团队负责人可通过控制台查看各自的支出。
- **轮换密钥** — `POST /key/regenerate` — 旧密钥立即失效。
- **撤销密钥** — `DELETE /key/delete` — 即时生效。
