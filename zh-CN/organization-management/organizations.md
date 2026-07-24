---
lang: zh-CN
page_id: organization-management/organizations
permalink: /organization-management/organizations.html
title: 组织
parent: 组织管理
nav_order: 1
description: "切换组织以及管理你自己的组织——从侧边栏底部的用户菜单进入。"
---

# 组织

你的**组织**就是你的 Routero 工作区——你的成员、团队、密钥、模型、支出与审计日志的隔离边界。作为租户，你没有系统级的组织控制台；你通过**侧边栏底部的用户菜单**来切换和管理组织。

{: .note }
你属于一个或多个组织。每个用户还有一个**个人组织**，用于私人密钥和实验，与任何共享的团队工作区相互独立。

---

## 用户菜单

打开侧边栏底部的用户菜单（你的头像或首字母）。它会显示你当前的组织，并提供租户使用的两个组织操作：

- **切换组织（Switch Organization）** —— 更换你正在工作的组织。
- **管理组织（Manage Organization）** —— 查看你的组织并管理其成员与邀请（仅限组织管理员）。

![侧边栏底部的用户菜单——切换与管理组织的入口](/assets/images/organizations/user-menu.png)

---

## 切换组织

选择 **Switch Organization** 打开切换器。它列出你所属的每一个组织——个人组织在前，共享组织按字母顺序排列。你当前所在的组织会被标记为 **Active**。

![切换组织弹窗——你所属的组织列表，当前组织带标记](/assets/images/organizations/switch-organization.png)

点击一个组织即可切换进去。仪表板会在该组织的上下文中重新加载，此后你看到的一切——团队、成员、密钥、用量、支出——都限定在它的范围内。

{: .note }
如果你只属于一个组织，切换器仍会打开，但只会显示那一个。切换只对有权访问多个组织的用户有意义。

---

## 管理你的组织

组织管理员会在用户菜单中看到 **Manage Organization**。它会打开一个窗口，包含两个标签：**General** 与 **Members**。

### General

组织的只读摘要：名称、**组织 ID**（复制它以便在别处引用该组织）、创建时间与创建者、当前成员数，以及总支出。

![管理组织窗口——General 标签：组织信息、ID、成员数与支出](/assets/images/organizations/manage-organization-general.png)

### Members

谁在组织里的一个聚焦视图。你可以搜索成员、内联修改成员的组织角色、移除成员，或通过邮箱邀请新成员。待处理的邀请列在 **Invitations** 子标签下，你可以在那里复制或撤销邀请链接。

![管理组织窗口——Members 标签：搜索、内联角色、移除与邀请](/assets/images/organizations/manage-organization-members.png)

![管理组织窗口——Invitations 子标签，列出待处理的邀请链接](/assets/images/organizations/manage-organization-invitations.png)

这是成员管理的快捷入口。完整的成员管理工作流——成员列表、邀请流程、角色与单个成员的详情——请参见[成员]({% link zh-CN/organization-management/members.md %})。

---

## 组织管理员能做与不能做的事

**能** —— 管理成员与邀请、创建与管理团队、管理模型与密钥、设置预算、配置 AI 能力，以上均在组织范围内。

**不能** —— 创建或删除组织、更改组织所有者，或查看属于其他组织的数据。这些都是平台管理员操作。如果你需要一个新组织（例如单独的业务单元或客户工作区），请让你的平台管理员创建它并将你设为其管理员。

---

## 相关内容

→ 完整的成员与邀请工作流，参见[成员]({% link zh-CN/organization-management/members.md %})。
→ 细分你的组织，参见[团队]({% link zh-CN/organization-management/teams.md %})。
→ 这些角色背后的授权模型，参见[访问控制与审计]({% link zh-CN/core-gateway/sso-rbac-audit.md %})。
