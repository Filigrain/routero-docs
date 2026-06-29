---
lang: zh-CN
page_id: core-gateway/budgets
permalink: /core-gateway/budgets.html
title: 预算与支出护栏
parent: 核心网关
nav_order: 5
description: "为每一美元 AI 支出提供硬性支出上限、软性告警和按团队的费用分摊。"
---

# 预算与支出护栏

Routero 让 AI 支出可治理，同时不拖慢速度。预算可附加到任意实体——工作区、团队、用户、API 密钥或路由——并在接近上限时强制执行三档响应。

> *“尽早预警。智能限流。该拦截时才拦截。”*

---

## 三档强制档位

| 档位 | 触发条件 | 效果 |
|---|---|---|
| **预警（Warn）** | 上限的 80% | 向工作区所有者发送 Slack/邮件告警；流量不受影响 |
| **限流（Throttle）** | 上限的 100% | 自动切换到成本优化路由（`smart/cheap`）；请求仍然成功 |
| **拦截（Block）** | 达到硬性上限 | 返回 HTTP 429，附带结构化错误和 `X-Routero-Budget-Reset-At` 标头 |

三档均可配置——你可以选择启用哪些档位，以及在什么阈值触发。

---

## 预算范围

预算可附加到：

| 实体 | 示例用例 |
|---|---|
| **工作区** | 跨所有团队的每月总上限 |
| **团队** | 按团队的费用分摊，各自独立限额 |
| **用户 / API 密钥** | 按开发者或按应用的限额 |
| **路由** | 限制特定模型组的支出 |
| **客户** | 多租户 SaaS 中按最终用户的支出上限 |

一个工作区可以有多个相互重叠的预算。最具限制性的适用预算优先生效。

---

## 创建预算

通过 API：

```bash
curl -X POST https://api.routero.ai/budget/new \
  -H "Authorization: Bearer $ROUTERO_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "max_budget": 500.00,
    "budget_duration": "1mo",
    "soft_budget": 400.00,
    "model_max_budget": {
      "openai/gpt-4o": 200.00
    }
  }'
```

或在仪表板中通过 **Budgets** → **New Budget** 创建。

---

## 费用分摊与成本归因

每个请求都会写入一条带有完整归因的支出事件：工作区、团队、用户密钥、路由、模型、供应商、token 计数以及以美元计的成本。归因延迟：从请求完成到记入账本不超过 5 分钟。

导出选项：
- **仪表板** —— 实时支出仪表板，含团队级明细
- **CSV** —— 按工作区的每月导出
- **REST API** —— `/billing/daily-spend`、`/billing/spend-trend`、`/billing/transactions`
- **数据仓库** —— Snowflake 或 BigQuery 每小时同步
- **ERP 推送** —— NetSuite 或 Coupa 集成

→ 完整支出管线请见 [成本追踪与计费]({% link zh-CN/core-gateway/cost-tracking.md %})。
