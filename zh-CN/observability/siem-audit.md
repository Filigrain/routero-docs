---
lang: zh-CN
page_id: observability/siem-audit
permalink: /observability/siem-audit.html
title: SIEM 与审计导出
parent: 可观测性
nav_order: 3
description: "将不可篡改的 Routero 审计日志流式传输到 Kafka、S3 或你的 SIEM。"
---

# SIEM 与审计导出

Routero 审计日志不可篡改、仅追加，并经过加密链式连接。可将其实时流式传输到你的 SIEM，或按计划导出以用于合规归档。

---

## 导出格式

| 方式 | 延迟 | 用例 |
|---|---|---|
| **Webhook** | 近实时 | SIEM 摄取（Splunk、Elastic 等） |
| **Kafka** | 近实时 | 大流量流式管道 |
| **S3 投递** | 每小时 | 合规归档、Snowflake/BigQuery 摄取 |
| **仪表盘下载** | 按需 | 临时审阅、电子取证 |

---

## Webhook 配置

```bash
curl -X POST https://api.routero.ai/config/update \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{
    "general_settings": {
      "alerting": ["webhook"],
      "alerting_webhook_url": "https://siem.yourcompany.com/ingest/routero"
    }
  }'
```

事件以 JSON 形式 POST，并带有 `X-Routero-Signature` 标头（HMAC-SHA256），用于验证真实性。

---

## 审计事件 Schema

```json
{
  "event_id": "evt_01jz...",
  "event_type": "request.routed",
  "timestamp": "2026-06-29T10:00:00.123Z",
  "workspace_id": "ws_...",
  "org_id": "org_...",
  "team_id": "team_...",
  "user_key_hash": "sk_hash_...",
  "model": "openai/gpt-4o",
  "provider": "openai",
  "tokens_input": 512,
  "tokens_output": 128,
  "cost_usd": 0.0043,
  "latency_ms": 1240,
  "guardrail_id": "pii-redact-prod",
  "guardrail_violations": [],
  "fallback_count": 0,
  "policy_version": 18,
  "previous_event_hash": "sha256:abc123..."
}
```

`previous_event_hash` 字段将事件链接起来——对任何先前记录的篡改都会破坏该链条。

---

## 保留

- **默认：** 365 天
- **企业版：** 可配置，最长 7 年
- **自托管：** 保留由你自己的 RDS/S3 生命周期策略控制

→ 完整的事件类型目录请参阅 [审计日志参考]({% link zh-CN/security-trust/audit-log.md %})。
