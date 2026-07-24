---
lang: zh-CN
page_id: observability/usage
permalink: /observability/usage.html
title: 用量
parent: 可观测性
nav_order: 2
description: "支出与请求分析——按组织、团队、客户、模型与供应商。"
---

# 用量

**用量**页是你的支出与请求分析仪表板。查看总支出与请求量，再按模型、供应商、密钥、团队或客户在任意时间窗口内细分。

在侧边栏打开 **Usage**。默认显示你的**组织**在最近 7 天的用量。

---

## 视图

切换 **View** 以不同方式切分支出。组织管理员可使用：

- **Organization**（默认）—— 整个组织的支出。
- **Team** —— 按团队的支出。
- **Customer** —— 归属到终端客户的支出。
- **Personal** —— 你自己密钥的用量。

![用量视图选择器——Organization、Team、Customer、Personal，带日期范围选择器](/assets/images/usage/usage-view-selector.png)

{: .note }
Global、Tag 与 Agent 视图为平台管理员专用，不对租户管理员显示。

---

## 你能看到什么

每个视图以汇总卡片开头——**总支出**、**总请求数**、**成功**、**失败**与**总 token**——随后是图表与表格：按日的支出趋势、按实体（团队、密钥或客户）的支出、热门 API 密钥、热门模型，以及按供应商的支出（含成功率与吞吐）。标签可聚焦于 **Cost**、**Model Activity**、**Key Activity**、**Endpoint Activity** 与 **Performance**。

![组织用量——总支出/请求/token 卡片、每日支出图表、热门模型与供应商环形图](/assets/images/usage/usage-overview.png)

使用 **Export Data** 可将所选视图的支出下载为文件，用于成本分摊或报表。

---

## 相关内容

→ 单个请求的明细，参见[日志]({% link zh-CN/observability/logs.md %})。
→ 为支出设置上限，参见[预算限额]({% link zh-CN/observability/budget-limits.md %})。
