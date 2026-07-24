---
lang: zh-CN
page_id: organization-management/members
permalink: /organization-management/members.html
title: 成员
parent: 组织管理
nav_order: 3
description: "你组织中的人员——仅限邀请的成员资格、角色与单个成员的详情。"
---

# 成员

**成员**是你组织中的人员。成员资格是**仅限邀请**的——没有自助注册。作为组织管理员，你邀请成员、分配角色并管理他们的访问权限。

在侧边栏打开 **Users**（位于 **Account** 下）。列表限定在你当前的组织范围内。

{: .note }
列表只显示你当前组织的成员。使用 **Switch Organization** 可管理其他组织的成员。

---

## 成员列表

表格显示每个成员的邮箱与别名、支出、密钥数量，以及加入时间。点击某一行可打开成员详情。使用 **+ Invite User** 添加成员。

![成员列表——组织中每个人的邮箱、支出、密钥与加入时间](/assets/images/members/members-list.png)

---

## 邀请成员

选择 **+ Invite User** 打开邀请抽屉。输入对方的**邮箱**、选择**角色**，并可选择性地分配一个起始**团队**。提交后，Routero 会生成一个**7 天**有效的单次**邀请链接**——把它分享给被邀请人。对方打开链接并设置密码后，就会以你选择的角色加入你的组织。

![Invite User 抽屉——邮箱、角色与可选的团队](/assets/images/members/invite-member-drawer.png)

![生成的邀请链接——7 天有效，可直接分享](/assets/images/members/invitation-link.png)

你组织的待处理邀请也会列在 **Manage Organization → Invitations** 下（参见[组织]({% link zh-CN/organization-management/organizations.md %})），你可以在那里再次复制链接或撤销它。已接受的邀请会相应地标记。

{: .note }
由于注册仅限邀请，进入你组织的唯一途径是你发出的邀请（如果平台配置了单点登录，则是通过 SSO）。没有公开的注册页面。

---

## 角色

成员的角色决定其能在整个组织中做什么：

| 角色 | 能做什么 |
|---|---|
| **Admin**（组织管理员） | 一切：管理成员与邀请、创建与管理团队、管理模型与密钥、设置预算、配置 AI 能力。 |
| **Member**（内部用户） | 使用该组织——调用模型、管理自己的密钥、使用 Playground——但不能管理组织。 |

新成员默认为 **Member**。当某人需要协助管理组织时，将其提升为 **Admin**。你可以随时从成员所在行或其详情视图中更改角色。

---

## 管理成员

从成员的详情中，你可以看到其支出、所属团队、密钥与个人模型。作为组织管理员，你可以：

- **更改角色** —— 提升为 Admin 或降级为 Member。
- **移出组织** —— 撤销其在你组织中的成员资格。这不会全局删除该用户；只是将其从你的组织中移除。
- **重置密码** —— 当成员失去访问权限时，为其提供重新登录的方式。

![成员详情——支出、团队、密钥，以及组织管理员可执行的操作](/assets/images/members/member-detail.png)

{: .note }
将成员移出你的组织并不会删除其账号——对方可能仍属于其他组织。全局删除用户是平台管理员操作。

---

## 相关内容

→ 管理组织窗口中的快捷成员工具，参见[组织]({% link zh-CN/organization-management/organizations.md %})。
→ 团队级别的成员资格与团队角色，参见[团队]({% link zh-CN/organization-management/teams.md %})。
→ 这些角色背后的授权模型，参见[访问控制与审计]({% link zh-CN/core-gateway/sso-rbac-audit.md %})。
