---
lang: zh-CN
page_id: core-gateway/policy-routing
permalink: /core-gateway/policy-routing.html
title: 策略路由
parent: 核心网关
nav_order: 4
description: "声明式 YAML 路由规则 —— 基于身份、内容、地域、预算、计划与自定义信号进行评估。"
---

# 策略路由

策略路由让你用声明式 YAML 规则决定由哪个模型服务哪个请求 —— 无需更改应用代码。策略保存在版本控制中，经过你常规的代码审查流程，并在 5 秒内热重载。

> *“策略存放在你的代码仓库中，而非运行时。”*

---

## 工作原理

每个请求都会在供应商选择之前运行策略评估器。评估器对六大类共 42 个路由信号进行评分，并选择第一个匹配的规则：

| 信号类别 | 示例 |
|---|---|
| **身份与组织** | 工作区、团队、成本中心头、RBAC 角色、计划层级 |
| **内容分类** | 检测到 PII、代码内容、语言、token 数量、数据类别头 |
| **地域与驻留** | 调用方声明的地域、EU-only、FedRAMP 绑定 |
| **预算状态** | 剩余预算占上限的百分比 |
| **计划** | 工作时间、夜间、周末 |
| **自定义应用信号** | 任意 HTTP 头（`X-Routero-*` 或你自己的） |

评估开销：**P50 约 8 毫秒，P99 <50 毫秒**。

---

## 策略 YAML 结构

```yaml
# finance-team.yaml
workspace: finance
version: 18

rules:
  # 检测到 PII → 路由至内部脱敏模型
  - when:
      content.pii_detected: true
    route: internal/llama-4-maverick-redacted
    on_redaction_fail: block

  # EU 用户 → 仅限 EU 供应商（数据驻留）
  - when:
      identity.region: eu
    route: eu/anthropic-frankfurt
    residency: eu-only

  # 预算低于 20% → 降级并告警
  - when:
      budget.remaining_pct: { lt: 20 }
    route: smart/cheap
    alert:
      channel: slack
      message: "Finance workspace budget below 20%"

  # 默认
  - route: smart/balanced
    audit:
      log_inputs: true
      retention_days: 365
```

---

## GitOps 工作流

1. **编辑** —— 更新仓库中的 YAML 文件。
2. **审查** —— 发起 PR。你的安全团队会像审查任何配置变更一样审查该 diff。
3. **模拟** —— 在合并之前，Routero 的策略模拟器会用最近 24 小时的流量针对新策略进行重放。确认没有流量出现意外迁移。
4. **发布** —— 合并到 main。策略会在 <5 秒内热重载。无需重新部署应用。无停机时间。

---

## 策略版本管理与审计

策略变更会被记录在审计日志中——包括是谁、在何时做出的变更——为你提供一份可复现的路由配置变更记录。

→ 审计日志参考请参见 [访问控制与审计]({% link zh-CN/core-gateway/sso-rbac-audit.md %})。
