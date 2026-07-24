---
lang: zh-CN
page_id: organization-management
permalink: /organization-management.html
title: 组织管理
nav_order: 6
has_children: true
description: "在 Routero 仪表板中管理你的组织、团队与成员——租户管理员指南。"
---

# 组织管理

Routero 把一切——访问、支出、模型与审计——都组织在你的**组织**（你的工作区）之下。作为组织管理员，你在仪表板中管理三件事：组织本身、细分组织的**团队**，以及组织中的**成员**。

```
组织（你的工作区）
  └── 团队        —— 按组的预算、速率限制与模型访问
        └── 成员 —— 你组织中的人员
```

{: .note }
这些页面描述的是**租户管理员**的体验——即组织管理员对自己的组织能看到和能做的事。创建或删除组织、平台级的管理工作由你的平台管理员完成，不在本节范围内。

---

## 你在哪里管理组织

租户没有系统级的“组织”页面。相反，组织操作都位于**侧边栏底部的用户菜单**背后：

- **切换组织（Switch Organization）** —— 当你属于多个组织时，切换你正在工作的工作区。
- **管理组织（Manage Organization）** —— 查看组织详情，并管理其成员与邀请。

→ [组织]({% link zh-CN/organization-management/organizations.md %})

---

## 团队与成员

- **团队**细分组织，用于成本分摊与访问控制。每个团队有自己的预算、速率限制和模型列表。→ [团队]({% link zh-CN/organization-management/teams.md %})
- **成员**是你组织中的人员。成员资格是**仅限邀请**的——没有自助注册。→ [成员]({% link zh-CN/organization-management/members.md %})

---

## 当前组织

仪表板始终记录你正在工作的组织——显示在侧边栏底部的用户菜单中。你打开的每个页面（团队、成员、API 密钥、用量）都会自动限定在该组织范围内，因此你只会看到自己的数据。使用**切换组织**来更换上下文。

---

## 相关内容

- 关于租户模型的概念（组织 → 团队 → 用户 → 客户），参见[多租户]({% link zh-CN/core-gateway/multi-tenancy.md %})。
- 关于团队预算与支出护栏，参见[预算与支出护栏]({% link zh-CN/core-gateway/budgets.md %})。
- 关于角色与授权，参见[访问控制与审计]({% link zh-CN/core-gateway/sso-rbac-audit.md %})。
