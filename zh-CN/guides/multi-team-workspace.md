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

本指南面向为多个内部团队搭建 Routero 的平台工程师或 AI 基础设施负责人。目标：每个团队拥有自己的密钥、预算和模型允许列表；中央管理员拥有完整的可见性；撤销访问即时生效。

---

## 设计模式

```
工作区（组织）
  ├── 团队：data-science    $2000/月   → 可使用任意模型
  ├── 团队：customer-ops    $500/月    → 仅可使用 smart/balanced
  ├── 团队：finance         $800/月    → 需要 EU 数据驻留
  └── 团队：engineering     $1500/月   → 任意模型，含 Cursor 密钥
```

---

## 步骤 1 — 创建团队

```bash
# 创建每个团队
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
# customer-ops：仅限使用 smart/balanced
curl -X POST https://api.routero.ai/team/update \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{"team_id": "customer-ops", "models": ["smart/balanced"]}'

# finance：限制为 EU 数据驻留路由
curl -X POST https://api.routero.ai/team/update \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{"team_id": "finance", "models": ["eu/balanced"]}'
```

---

## 步骤 3 — 设置 RBAC 角色

```bash
# 授予 data-science 负责人 Developer 角色
curl -X POST https://api.routero.ai/organization/member_permission_update \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{"user_email": "data-lead@company.com", "user_role": "internal_user", "team_id": "data-science"}'

# 授予 finance 主计官 Auditor 角色（只读）
curl -X POST https://api.routero.ai/organization/member_permission_update \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{"user_email": "controller@company.com", "user_role": "internal_viewer"}'
```

---

## 步骤 4 — 邀请团队成员

访问采用邀请制。在控制台的 **Members** 下，通过邮件邀请每位团队成员，并将其分配到相应团队、赋予合适的角色。成员使用从邀请中设置的凭据直接登录——无需 SSO 或 IdP 配置。

如需移除某人的访问权限，请从控制台删除该用户（或撤销其密钥）；其密钥会立即失效。

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
