---
lang: zh-CN
page_id: deployment/cloud
permalink: /deployment/cloud.html
title: Routero Cloud
parent: 部署选项
nav_order: 1
description: "由 Routero 托管的多租户云——从 API 密钥到生产环境的最快路径。"
---

# Routero Cloud

托管型多租户方案。由 Routero 运营基础设施；你从第一天起就能通过虚拟密钥、组织和团队来使用网关。

**线上地址：** `https://api.routero.ai/v1`（API）· `https://platform.routero.ai`（控制台）

---

## 包含内容

- **弹性扩展** —— ECS Fargate 任务根据请求量自动扩缩容（最多 10 个副本）；无需进行容量规划。
- **多可用区可用性** —— 部署在 AWS ap-southeast-1（新加坡）的 3 个可用区中，前置 Cloudflare 全球边缘网络并采用源站回源 mTLS。
- **SOC 2 Type II** —— 年度认证。可向你的解决方案工程师索取报告。
- **多租户隔离** —— 通过 RBAC（Cerbos）、组织范围的虚拟密钥以及专用的 Postgres 行级所有权实现逻辑隔离。你工作区的数据和配置对其他租户不可见。
- **自动升级** —— Routero 通过经过评审的 CI/CD 流水线（feature → develop → uat → production）持续部署改进。
- **状态页** —— 在 [status.routero.ai](https://status.routero.ai) 提供实时状态；正常运行时间监控会从多个地域每 30 秒检查一次 `/health/liveliness` 和 `/health/readiness`。

---

## 接入

1. 在 [platform.routero.ai](https://platform.routero.ai) 注册。
2. 创建工作区并生成一个虚拟 API 密钥。
3. 在你的应用中设置 `base_url = "https://api.routero.ai/v1"`。完成。

首次路由请求可在 60 秒内完成。

---

## Routero Cloud 中的数据处理

| 内容 | 去向 |
|---|---|
| 提示词和响应内容 | **不存储**（仅元数据——token 计数、模型、成本、延迟） |
| 审计日志元数据 | AWS RDS Postgres，ap-southeast-1，默认保留 365 天 |
| 支出和用量数据 | 同一 RDS，组织范围，导出至你的控制台 |
| 你添加的供应商 API 密钥 | 在 RDS 中加密，从不记录日志 |

Routero 绝不会使用、转售或共享你的提示词进行训练。→ [数据处理与隐私]({% link zh-CN/security-trust/data-privacy.md %})

---

## 与私有部署相比的限制

- 数据物理上存放在 Routero 的 AWS 账户（新加坡）中。如果你的合规制度要求数据主权位于其他司法管辖区，请使用[单租户云]({% link zh-CN/deployment/single-tenant.md %})或[私有部署]({% link zh-CN/deployment/private.md %})。
- 你无法自定义基础设施层级的配置（VPC CIDR、实例类型等）。
