---
lang: zh-CN
page_id: observability/metrics-analytics
permalink: /observability/metrics-analytics.html
title: 指标与分析
parent: 可观测性
nav_order: 2
description: "使用量与支出分析：按密钥、按团队、按组织的仪表盘和 API。"
---

# 指标与分析

Routero 的内置分析为每位相关方提供所需的视图——开发者查看自己密钥的使用量，团队查看自己的支出，管理员查看整个工作区。

---

## 仪表盘

Routero 管理员仪表盘（[platform.routero.ai](https://platform.routero.ai)）提供：

- **使用量概览**——总请求数、Token、成本与延迟趋势（1 小时 / 24 小时 / 7 天 / 30 天）
- **模型明细**——按模型与供应商划分的请求数和成本
- **团队明细**——按团队划分的支出及预算剩余指示
- **密钥活动**——按密钥划分的请求数与成本
- **路由决策**——供应商分布、回退频率、错误率
- **预算告警**——活动中的支出预警与拦截

---

## 分析 API

以编程方式拉取使用量数据：

```bash
# 组织级每日支出
GET /billing/daily-spend?start_date=2026-06-01&end_date=2026-06-30

# 团队活动
GET /team/daily/activity?team_id=data-science&start_date=2026-06-01

# 用户活动
GET /user/daily/activity?user_id=alice@company.com

# 按密钥支出
GET /key/info?key_hash=sk-...
```

---

## Prometheus 指标

当启用 Prometheus 时（在 Docker Compose 中或作为 ECS 任务），Routero 会暴露一个 `/metrics` 端点，包含：

- `litellm_request_total`——按模型、供应商、状态划分的请求计数
- `litellm_request_duration_seconds`——延迟直方图
- `litellm_tokens_total`——输入/输出 Token 计数
- `litellm_cost_total`——以美元计的支出

抓取配置：
```yaml
scrape_configs:
  - job_name: routero
    static_configs:
      - targets: ["routero-proxy:4000"]
    metrics_path: /metrics
```
