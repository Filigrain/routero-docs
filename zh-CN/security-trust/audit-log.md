---
lang: zh-CN
page_id: security-trust/audit-log
permalink: /security-trust/audit-log.html
title: 审计日志参考
parent: 安全与信任
nav_order: 4
description: "完整的事件类型目录、审计日志架构、保留与 SIEM 导出参考。"
---

# 审计日志参考

Routero 审计日志是一份不可篡改、仅追加、以密码学方式链接的记录，涵盖系统中每一项重要事件。每条记录都包含前一条记录的哈希——篡改任何一条记录都会破坏整条链。

---

## 事件类型目录

### 推理事件
| 事件类型 | 触发时机 |
|---|---|
| `request.routed` | 请求已成功路由至某供应商 |
| `request.blocked` | 请求被拦截（预算、护栏、策略或密钥无效） |
| `request.failed` | 供应商返回错误且所有回退均已用尽 |
| `request.guardrail_triggered` | 护栏引擎检测到违规（匿名化或拦截） |
| `request.cache_hit` | 响应由缓存提供（Token 节省） |
| `request.compressed` | 提示词被 Token 节省方案压缩 |
| `request.fallback_triggered` | 路由器回退至备用供应商 |

### 策略事件
| 事件类型 | 触发时机 |
|---|---|
| `policy.evaluated` | 匹配到某条路由策略规则 |
| `policy.changed` | 发布了某个策略版本（旧 → 新） |
| `policy.blocked` | 策略规则拦截了某个请求 |

### 身份与访问事件
| 事件类型 | 触发时机 |
|---|---|
| `user.provisioned` | 用户被创建（手动或 SCIM） |
| `user.deprovisioned` | 用户被停用（SCIM 同步或手动） |
| `key.created` | 生成了某个虚拟 API 密钥 |
| `key.rotated` | 重新生成了某个虚拟 API 密钥 |
| `key.revoked` | 删除了某个虚拟 API 密钥 |
| `key.budget_exceeded` | 某个密钥达到其预算上限 |
| `login.success` | 登录成功（SSO 或密码） |
| `login.failed` | 登录尝试失败 |
| `mfa.challenged` | 发起 MFA 质询 |

### 预算事件
| 事件类型 | 触发时机 |
|---|---|
| `budget.threshold_reached` | 跨越预算软阈值（警告档） |
| `budget.exceeded` | 达到预算硬上限（限流或拦截档） |
| `budget.reset` | 预算周期重置 |
| `spend.debited` | 从密钥/团队/组织余额中扣除请求成本 |

### 高级功能事件
| 事件类型 | 触发时机 |
|---|---|
| `memory.retrieved` | 记忆事实被注入请求 |
| `memory.stored` | 对话轮次被存入记忆会话 |
| `guardrail.configured` | 护栏被创建或更新 |
| `prompt.version_published` | 创建了提示词模板版本 |
| `token_saving.plan_updated` | Token 节省方案被创建或修改 |

---

## 记录架构

```json
{
  "event_id": "evt_01jz...",
  "event_type": "request.routed",
  "timestamp": "2026-06-29T10:00:00.123456Z",
  "workspace_id": "ws_abc123",
  "org_id": "org_xyz",
  "team_id": "data-science",
  "user_key_hash": "sha256:deadbeef...",
  "customer_id": null,
  "model": "openai/gpt-4o",
  "provider": "openai",
  "tokens_input": 512,
  "tokens_output": 128,
  "cost_usd": 0.00430,
  "latency_ms": 1240,
  "time_to_first_token_ms": 380,
  "guardrail_id": null,
  "guardrail_violations": [],
  "token_saving_plan_id": "support-bot-cache",
  "cache_hit": false,
  "prompt_id": null,
  "memory_id": null,
  "fallback_count": 0,
  "policy_version": 18,
  "request_id": "req_01jz...",
  "previous_event_hash": "sha256:abc123..."
}
```

---

## 查询审计日志

```bash
# Last 100 events
GET /audit-log?limit=100

# Events for a specific key
GET /audit-log?key_hash=sha256:...&start_date=2026-06-01

# Guardrail violations only
GET /audit-log?event_type=request.guardrail_triggered

# Export as CSV
GET /audit-log?format=csv&start_date=2026-06-01&end_date=2026-06-30
```

---

## 保留与导出

| 方式 | 默认保留期 | 最长保留期 |
|---|---|---|
| RDS（主存储） | 365 天 | 7 年（企业版） |
| S3 冷归档 | 可选 | 无限期 |
| SIEM 流 | 通过 webhook/Kafka 实时传输 | — |

→ 流式配置请参见 [SIEM 与审计导出]({% link zh-CN/observability/siem-audit.md %})。
