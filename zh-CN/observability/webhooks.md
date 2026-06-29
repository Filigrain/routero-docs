---
lang: zh-CN
page_id: observability/webhooks
permalink: /observability/webhooks.html
title: Webhooks
parent: 可观测性
nav_order: 4
description: "针对路由决策、预算告警与护栏违规的实时事件通知。"
---

# Webhooks

Routero 可将事件通知 POST 到任意 HTTPS 端点。使用 webhook 可实现实时告警、自定义仪表盘，或将事件导入内部工具，而无需轮询 API。

---

## 事件类型

| 事件 | 触发时机 |
|---|---|
| `request.routed` | 每次成功的路由决策 |
| `request.blocked` | 请求被护栏或预算拒绝 |
| `budget.threshold_80` | 工作区/团队预算达到 80% |
| `budget.exceeded` | 达到预算上限（拦截层级生效） |
| `guardrail.violated` | 护栏引擎触发违规 |
| `key.rotated` | 虚拟密钥被重新生成 |
| `user.deprovisioned` | 通过 SCIM 或手动移除用户 |
| `fallback.triggered` | 路由器回退到备用供应商 |

---

## 配置

```yaml
# config.yaml
litellm_settings:
  alerting: ["webhook"]
  alerting_webhook_url: "https://hooks.yourcompany.com/routero"

# 可选：过滤到特定事件类型
alerting_events:
  - budget.threshold_80
  - guardrail.violated
  - fallback.triggered
```

---

## 负载格式

```json
{
  "event_type": "budget.threshold_80",
  "timestamp": "2026-06-29T10:00:00Z",
  "workspace_id": "ws_...",
  "team_id": "data-science",
  "budget_used_pct": 82.4,
  "budget_used_usd": 412.00,
  "budget_max_usd": 500.00
}
```

所有 webhook 负载都包含 `X-Routero-Signature` 标头（对原始请求体进行 HMAC-SHA256 签名，使用你的 webhook 密钥签名）。请在处理前验证它。
