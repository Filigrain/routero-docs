---
lang: zh-CN
page_id: observability/logs
permalink: /observability/logs.html
title: 日志
parent: 可观测性
nav_order: 1
description: "每一个经由 Routero 的请求——状态、token、成本、延迟，以及可选的提示词与响应。"
---

# 日志

**日志**页记录每一个经过网关的请求。对于每次调用，你都可以查看其状态、模型、token 用量、成本与延迟——在启用提示词日志时，还能看到请求与响应本身。

在侧边栏打开 **Logs**。组织管理员能看到组织内的所有请求；普通成员只能看到自己的。

---

## 请求日志

列表为每个请求显示一行，**Live Tail** 默认开启（每 15 秒自动刷新）。列包括时间、成功/失败状态、请求 ID 与会话 ID、模型、token 数量、成本、延迟，以及调用背后的团队、内部用户与终端用户。

![日志请求列表——实时刷新的表格，含时间、状态、模型、token、成本，顶部为筛选工具栏](/assets/images/logs/logs-request-list.png)

可按**时间范围**（最近 15 分钟到最近 7 天，或自定义范围）、**团队**、**状态**（成功/失败）、**模型**、**密钥别名**、**终端用户**、**错误码**或**请求 ID** 筛选。开关 **Live Tail** 可实时接收新条目。

![日志筛选——团队、状态、模型、密钥、终端用户、错误码与自定义日期范围](/assets/images/logs/logs-filters.png)

页面还提供 **Deleted Keys** 与 **Deleted Teams** 标签，用于审计删除操作。

---

## 请求详情

点击某一行打开请求详情抽屉。它显示请求的模型、供应商、调用类型与 API base；一张指标卡片，包含 prompt/completion/总 token、成本、延迟与缓存统计；使用的工具；以及完整的 **metadata**（JSON）。启用提示词日志时，**Request & Response** 面板会显示消息与模型回复，支持 Pretty/JSON 切换。

![请求详情抽屉——请求详情、指标与请求/响应面板](/assets/images/logs/logs-detail-drawer.png)

---

## 记录了什么

元数据始终被记录——模型、供应商、token、成本、计时、状态，以及调用背后的密钥、团队、用户与终端用户。

提示词与响应**内容默认关闭**。是否存储属于平台级设置（仪表板中没有按密钥的开关）；关闭时 Request & Response 面板为空。

{: .note }
仅限组织管理员的列与筛选（如组织选择器、router 开销指标）对租户管理员隐藏——它们属于平台管理员。

---

## 相关内容

→ 随时间分析支出，参见[用量]({% link zh-CN/observability/usage.md %})。
→ 为此处看到的支出设置上限，参见[预算限额]({% link zh-CN/observability/budget-limits.md %})。
