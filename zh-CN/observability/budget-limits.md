---
lang: zh-CN
page_id: observability/budget-limits
permalink: /observability/budget-limits.html
title: 预算限额
parent: 可观测性
nav_order: 3
description: "为密钥、团队与组织设置支出与速率上限，并查看支出对限额的进度。"
---

# 预算限额

预算用于限制某个实体能花费多少。你在**虚拟密钥**、**团队**与**组织**上设置预算——没有单独的“预算”页面；每个实体都带有自己的 **Budget & Rate Limits** 区块，支出会据此被跟踪。

---

## 执行方式

当某个请求会使实体超出其限额时：

- **Max Budget（硬上限）** —— 支出达到最高预算后，后续请求被**拦截**。
- **Soft Budget** —— 非阻断阈值；超出会发出告警，但不会停止请求。
- **80% 阈值** —— 接近最高预算（约 80%）时也会发出非阻断告警。

告警通过邮件发送。预算要么告警、要么拦截——中间没有“限流”档位。

{: .note }
告警**发送到哪里**（例如某个 Slack 频道）属于平台级设置，由你的管理员管理，并非按预算配置。

---

## 设置预算

在密钥、团队或组织上打开其设置，开启 **Budget & Rate Limits**。字段如下：

| 字段 | 作用 |
|---|---|
| **Max Budget** | 硬支出上限。超出即拦截。 |
| **Soft Budget** | 非阻断告警阈值。 |
| **Budget Reset** | 支出窗口的重置周期——每日、每周或每月。 |
| **TPM Limit** | 每分钟最大 token 数。 |
| **RPM Limit** | 每分钟最大请求数。 |
| **Max Parallel Requests** | 并发在途请求上限。 |
| **Allocation Strategy** | 子限额与父级的关系（Best Effort / Guaranteed）——密钥与团队。 |
| **Enforcement Strategy** | 始终执行（Static），或仅在上游失败时执行（Dynamic）。 |

![密钥或团队上的 Budget & Rate Limits 区块——最高/软预算、重置与速率限制](/assets/images/budget-limits/budget-form.png)

---

## 查看支出对限额的进度

无需单独的预算视图——支出对限额的进度就显示在实体所在的位置：

- **Virtual Keys** 与 **Teams** 列表显示 **Spend**、**Budget** 与 **Budget Reset** 列。
- 密钥或团队的 **Overview** 显示支出对最高预算的进度条与已用百分比（未设最高预算时显示“Unlimited”）。

![Virtual Keys 列表上的支出对预算，以及密钥 Overview 上的进度条](/assets/images/budget-limits/budget-status.png)

如需全组织的支出全貌，参见[用量]({% link zh-CN/observability/usage.md %})。

---

## 相关内容

→ 全组织的支出分析，参见[用量]({% link zh-CN/observability/usage.md %})。
→ 单个请求的明细，参见[日志]({% link zh-CN/observability/logs.md %})。
