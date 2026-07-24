---
lang: zh-CN
page_id: organization-management/teams
permalink: /organization-management/teams.html
title: 团队
parent: 组织管理
nav_order: 2
description: "将你的组织细分为团队，用于预算、速率限制、模型访问与成员管理。"
---

# 团队

**团队**是你组织的细分——预算、速率限制、模型访问与成员管理的基本单位。团队支出会汇总到组织，一名成员可以属于多个团队。

在侧边栏打开 **Teams**（位于 **Account** 下）。你看到的是当前组织中的团队。

{: .note }
团队属于你当前的组织。列表会自动限定在该组织范围内——使用 **Switch Organization** 可切换到其他组织。组织管理员可以创建和删除团队；团队管理员可以管理他们所管理的团队。

---

## 团队列表

表格显示每个团队的 ID、名称、支出、预算、模型列表、密钥与成员数量，以及创建日期。点击某一行可打开团队详情。使用 **+ Create New Team** 添加团队（仅限组织管理员）。

![团队列表——每个团队的 ID、名称、支出、预算、模型、密钥/成员数量与创建日期](/assets/images/teams/teams-list.png)

---

## 创建团队

**Create Team** 抽屉包含：

- **Team Name** —— 团队的标签。
- **Models** —— 团队可使用的模型。留空则允许组织可用的全部模型。
- **Budget & Rate Limits**（可选） —— 最高预算与软提醒预算、重置周期（每日、每周或每月），以及 TPM / RPM / 并发请求限制。

团队会自动创建在你当前的组织中。

![Create Team 抽屉——名称、模型访问与可选的预算和速率限制](/assets/images/teams/create-team-drawer.png)

---

## 团队详情

点击一个团队会打开其详情，包含三个标签：

### Overview
团队一览：**预算状态**卡片（支出对限额，带进度条与重置周期）、速率限制、模型列表，以及虚拟密钥数量。

![团队详情——Overview 标签：预算状态、速率限制、模型与密钥数量](/assets/images/teams/team-overview.png)

### Members
团队中的人员。通过搜索邮箱或用户 ID 添加成员并分配角色；编辑成员角色或设置单个成员的预算与速率限制；移除成员。参见下方的[团队角色](#团队角色)。

![团队详情——Members 标签：添加、编辑角色与限制，或移除成员](/assets/images/teams/team-members.png)

### Settings
重命名团队、更改模型访问、调整预算与速率限制，以及配置护栏、MCP/代理权限等高级选项。

![团队详情——Settings 标签：名称、模型、预算、速率限制与权限](/assets/images/teams/team-settings.png)

---

## 团队角色

一个团队有两种角色：

| 角色 | 能做什么 |
|---|---|
| **Admin** | 创建团队密钥、添加与移除成员、管理团队设置。 |
| **Member** | 使用团队的密钥与模型、查看团队信息——但不能管理它。 |

新成员默认为 **Member**；当某人需要协助管理团队时，将其提升为 **Admin**。

{: .note }
创建或删除团队是**组织管理员**操作。团队管理员可以管理其团队的设置与成员，但只有组织管理员才能创建或删除团队。

---

## 预算与支出

团队的预算与速率限制在创建或编辑时设定。支出会按预算跟踪，并按你选择的周期（每日、每周、每月）重置。团队支出也会汇入你的组织总额——关于预算与告警在整个平台上的运作方式，参见[预算与支出护栏]({% link zh-CN/core-gateway/budgets.md %})。

---

## 相关内容

→ 在把成员加入团队之前先把人员加入组织，参见[成员]({% link zh-CN/organization-management/members.md %})。
→ 切换组织上下文，参见[组织]({% link zh-CN/organization-management/organizations.md %})。
→ 预算、告警与成本分摊，参见[预算与支出护栏]({% link zh-CN/core-gateway/budgets.md %})。
