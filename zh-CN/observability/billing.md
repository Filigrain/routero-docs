---
lang: zh-CN
page_id: observability/billing
permalink: /observability/billing.html
title: 计费
parent: 可观测性
nav_order: 4
description: "你组织的余额、月度发票与交易流水。"
---

# 计费

**Billing** 页面展示你的组织花费了多少、应付多少——余额、月度发票与交易流水。对租户而言这些视图是**只读**的：充值由你的平台管理员处理。

在侧边栏打开 **Billing**（仅组织管理员）。

---

## 概览

**Overview** 页是汇总：你的**当前余额**（或已用额度）、本月支出与请求数、**付款类型**（预付/后付）、月度支出趋势，以及最近的交易。

![计费概览——余额、月度支出/请求、付款类型与最近交易](/assets/images/billing/billing-overview.png)

---

## 发票

**Invoices** 按月列出每月一张发票，含金额、支付状态与结算日期。打开一张发票可按**模型、团队、供应商或按天**拆分当月明细，并可导出为 CSV。

![发票——月度发票，可按模型/团队/供应商/天拆分](/assets/images/billing/billing-invoices.png)

---

## 交易

**Transactions** 是余额流水账：每一笔充值、退款与扣款，含来源、金额以及变动前后的余额。可按类型、来源或日期筛选，并导出为 CSV。

![交易——充值、退款与扣款的余额流水](/assets/images/billing/billing-transactions.png)

---

## 付款设置

点击侧边栏底部的**余额**组件可查看 **Payment Settings**——你的组织、付款类型、信用额度或余额，以及付款类型变更历史。（修改这些属于平台管理员操作。）

---

## BYOK 与支出

在你已切换为 [BYOK]({% link zh-CN/core-gateway/byok.md %}) 的供应商上的流量按“仅加价”计费——你直接向供应商付费。该支出仍计入你的总额，并在[日志]({% link zh-CN/observability/logs.md %})与[用量]({% link zh-CN/observability/usage.md %})中带标记。

---

## 相关内容

→ [用量]({% link zh-CN/observability/usage.md %})——按模型、团队、供应商的支出分析。
→ [预算限额]({% link zh-CN/observability/budget-limits.md %})——为密钥、团队、组织设置支出上限。
→ [BYOK]({% link zh-CN/core-gateway/byok.md %})——使用你自己的供应商密钥。
