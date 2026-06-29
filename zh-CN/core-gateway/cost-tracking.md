---
lang: zh-CN
page_id: core-gateway/cost-tracking
permalink: /core-gateway/cost-tracking.html
title: 成本追踪与计费
parent: 核心网关
nav_order: 8
description: "按请求的成本管线、预付钱包、发票和支出分析。"
---

# 成本追踪与计费

通过 Routero 的每个请求都会被实时计费。支出会被归因到正确的密钥、团队、组织和客户——在所有供应商上达到每 token $0.0001 的精度。

---

## 支出管线

```
Provider response received
  → Token counts extracted from response
  → Cost calculated (model price × token counts)
  → Cost attached to response metadata / headers
  → Spend increment queued in Redis
  → Coworker service drains Redis → Postgres atomically
  → Available in dashboard and API within ~5 minutes
```

coworker 服务使用基于 Redis 的领导者选举，因此即便在多副本部署中，支出也只会被精确持久化一次。

---

## 计费模式

Routero 支持两种计费方式，可按工作区混合使用：

**Routero 托管密钥** —— Routero 持有你的供应商 API 密钥。供应商成本由 Routero 结算，并按供应商标价、零加价转嫁到你的发票上。你将收到一份合并的月度发票。

**BYOK（自带密钥）** —— 你直接持有供应商合同。供应商发票原样开给你。你只需为控制平面订阅向 Routero 付费。

→ 定价详情见 [routero.ai/pricing](https://routero.ai/pricing.html)。

---

## 预付钱包

钱包功能（Routero 托管密钥）让你的工作区可以维持一个预付余额：

```bash
# 充值钱包
POST /billing/wallet/topup
{ "amount": 1000.00, "currency": "USD" }

# 查看余额和交易
GET /billing/wallet
GET /billing/transactions
GET /billing/invoices
GET /billing/invoices/{month}
```

---

## 支出分析

| 端点 | 说明 |
|---|---|
| `GET /billing/daily-spend` | 逐日支出明细 |
| `GET /billing/spend-trend` | 某日期范围内的趋势 |
| `GET /billing/overview` | 汇总：余额、月初至今支出、预测 |
| `GET /team/daily/activity` | 按团队的 token 和成本明细 |
| `GET /user/daily/activity` | 按用户的明细 |
| `GET /customer/daily/activity` | 按客户的明细 |

---

## 费用分摊导出

| 格式 | 方式 |
|---|---|
| 仪表板表格 | 实时，可按日期、团队、模型筛选 |
| CSV | 从仪表板按月下载 |
| REST API | 通过 `/billing/daily-spend` 以编程方式拉取 |
| Snowflake / BigQuery | 每小时同步（企业版） |
| NetSuite / Coupa | 推送集成（企业版） |
