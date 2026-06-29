---
lang: zh-CN
page_id: security-trust/data-privacy
permalink: /security-trust/data-privacy.html
title: 数据处理与隐私
parent: 安全与信任
nav_order: 3
description: "Routero AI 持久化哪些数据、保留多久，以及它从不存储哪些数据。"
---

# 数据处理与隐私

本页准确记录 Routero 处理哪些数据、保留哪些数据以及丢弃哪些数据。专为安全审查、DPA 协商以及 GDPR/CCPA 合规而设计。

---

## Routero 绝不存储的内容

| 数据类型 | 策略 |
|---|---|
| 提示词内容 | 从不存储、从不记录（路由后即丢弃） |
| 响应内容 | 从不存储、从不记录 |
| 文件内容（批处理、文件上传） | 传输期间临时缓存在内存中；不持久化 |
| 图像、音频、视频 | 以流式方式在内存中传递；不持久化 |

网关是一套**面向 AI 请求的中转系统**，而非内容存储。提示词与响应内容经过内存后即被丢弃。

---

## Routero 会存储的内容

| 数据类型 | 用途 | 位置 | 保留期 |
|---|---|---|---|
| 审计日志（元数据） | 合规、计费、调试 | RDS Postgres | 默认 365 天，最长可达 7 年 |
| Token 计数与成本 | 计费与费用分摊 | RDS Postgres | 无限期（财务记录） |
| 虚拟 API 密钥哈希 | 身份验证 | RDS Postgres | 直至密钥被删除 |
| 供应商 API 密钥 | 路由 | RDS Postgres（加密） | 直至被管理员移除 |
| 用户账户数据 | 身份与访问 | RDS Postgres | 直至用户被删除 |
| 记忆会话数据 | 记忆即服务（仅按需启用） | Postgres + pgvector | 直至会话被删除 |
| 缓存命中元数据 | 性能分析 | Redis（受 TTL 限制） | 按缓存 TTL（默认：1 小时） |

记忆会话内容（Mem0/Cognee）**仅按需启用**——除非调用方在请求中传入 `memory_id`，否则绝不会被创建。

---

## 审计日志元数据

审计日志针对每个请求记录以下内容：

```
event_id, event_type, timestamp, workspace_id, org_id, team_id,
user_key_hash (not the raw key), model, provider, tokens_input,
tokens_output, cost_usd, latency_ms, guardrail_id (if any),
guardrail_violation_types (not the blocked content), fallback_count,
policy_version
```

护栏违规记录的是**实体类型**（例如 `EMAIL_ADDRESS`）——而非原始值。

---

## 数据驻留

| 部署 | 审计数据存放位置 |
|---|---|
| Routero Cloud | AWS RDS，ap-southeast-1（新加坡） |
| 单租户云 | 你所选地域的 AWS RDS |
| 私有部署 | 你自己的数据库、你的基础设施、你的地域 |

如需欧盟数据驻留，请使用位于 `eu-west-1` 或 `eu-central-1` 的单租户云。→ [数据驻留与地域]({% link zh-CN/deployment/data-residency.md %})

---

## 数据主体请求（GDPR）

**访问权**——Routero 持有的是审计元数据与账户数据，而非提示词内容。访问请求可通过审计日志予以满足。

**删除权**——对于 Routero Cloud，请联系 privacy@routero.ai。对于私有部署，请直接在你的数据库中执行删除。记忆会话数据通过 `DELETE /memory/session/{id}` 删除——该操作在 Postgres 与向量索引之间是原子性的。

**可携带权**——审计日志数据可通过仪表盘或 API 以 JSON 或 CSV 格式导出。

---

## 子处理者（Routero Cloud）

| 子处理者 | 用途 | 位置 |
|---|---|---|
| AWS（新加坡） | 计算、RDS、Redis、S3 | ap-southeast-1 |
| Cloudflare | 边缘、DDoS、TLS | 全球 CDN |
| Resend | 事务性邮件（告警、计费通知） | 美国 |

完整的子处理者清单可应请求提供：privacy@routero.ai。
