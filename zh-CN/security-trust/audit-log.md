---
lang: zh-CN
page_id: security-trust/audit-log
permalink: /security-trust/audit-log.html
title: 审计日志参考
parent: 安全与信任
nav_order: 4
description: "Routero 管理员审计日志记录了什么、其 schema，以及如何查询。"
---

# 审计日志参考

Routero 会记录**管理操作**的审计日志，以便你的安全与合规团队能够回答“谁在何时更改了什么”。启用审计日志后，每一次密钥、用户、模型、团队、组织或预算的创建、更新、删除、封禁和轮换都会被持久化为一条审计记录。

{: .note }
审计日志记录的是**管理（控制平面）变更**，而非单条 LLM 推理请求。单次请求的用量与支出另行追踪——参见[指标与分析]({% link zh-CN/observability/metrics-analytics.md %})和[成本追踪与计费]({% link zh-CN/core-gateway/cost-tracking.md %})。

---

## 审计范围

每当管理员变更某个受管资源时，都会写入一条审计记录：

| 资源 | 被审计的操作 |
|---|---|
| API 密钥 | 创建 · 更新 · 删除 · 封禁 · 轮换 |
| 用户 | 创建 · 更新 · 删除 |
| 模型 | 新增 · 更新 · 移除 |
| 团队 | 创建 · 更新 · 成员变更 |
| 组织 | 创建 · 更新 · 成员变更 |
| 预算 | 创建 · 更新 · 删除 |

---

## 记录 schema

每条记录都会存储操作、目标资源、执行者以及前/后状态：

| 字段 | 说明 |
|---|---|
| `action` | `created` · `updated` · `deleted` · `blocked` · `rotated` |
| `table_name` | 受影响的资源类型（如 `LiteLLM_VerificationToken`、`LiteLLM_UserTable`） |
| `object_id` | 受影响资源的 ID |
| `changed_by` | 执行该操作的用户 |
| `changed_by_api_key` | 执行该操作所使用的 API 密钥 |
| `before_value` | 变更前资源的 JSON 快照 |
| `updated_values` | 已变更字段的 JSON 快照 |
| `organization_id` | 该记录所属的组织 |
| `updated_at` | 变更时间戳 |

敏感值——尤其是 API 密钥内容——在被写入 `before_value` / `updated_values` 之前会被掩码处理。

---

## 查询审计日志

```bash
# 列出最近的审计记录（按组织限定）
curl https://api.routero.ai/audit?limit=100 \
  -H "Authorization: Bearer $ADMIN_KEY"

# 按 id 获取单条记录
curl https://api.routero.ai/audit/{id} \
  -H "Authorization: Bearer $ADMIN_KEY"
```

两个端点均为**仅管理员**可用，且仅返回调用者所属组织的记录。仪表板在**审计日志**下提供相同数据。

---

## 保留期

审计记录存储在代理的主数据库（PostgreSQL）中。保留期由你的数据库备份与生命周期策略决定——在 Routero Cloud 中由我们代为管理；在私有部署中由你自己的数据库控制。
