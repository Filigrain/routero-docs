---
lang: zh-CN
page_id: deployment
permalink: /deployment.html
title: 部署选项
nav_order: 3
has_children: true
description: "Routero Cloud、单租户云、私有部署和本地——选择能让你的安全团队满意的信任边界。"
---

# 部署选项

同一套 Routero AI 控制平面以四种配置交付。你的安全团队决定数据存放在哪里；你的工程团队决定他们愿意运行多少基础设施。

{: .enterprise }
> **"交付你的安全团队会批准的 AI。"** 部署灵活性——包括 VPC 内部署和中国地域选项——是企业选择 Routero 而非纯云方案的首要原因。

---

## 选择你的信任边界

| | Routero Cloud | 单租户云 | 私有部署 | 本地 |
|---|---|---|---|---|
| **数据位置** | Routero 的 AWS（新加坡） | 你选择的地域，由 Routero 托管 | 完全在你的基础设施中 | 你的机器 |
| **隔离** | 逻辑隔离（RBAC、虚拟密钥） | 物理隔离（专用账户与 VPC） | 物理隔离 + 网络边界 | 完全本地 |
| **运维负担** | 无 | 无 | 你的团队 | 你的团队 |
| **搭建时间** | 60 秒 | 数天（需解决方案工程师） | 数小时至数天 | 数分钟 |
| **合规** | SOC 2 Type II | SOC 2 · HIPAA BAA · 定制 | 由客户控制 | 不适用 |
| **自定义域名** | `api.routero.ai` | 可使用 `api.yourcompany.com` | 你自己的域名 | `localhost` |
| **最适合** | POC → 生产团队 | 受监管行业、数据驻留 | 气隙网络、VPC 隔离、完全控制 | 开发、评估、CI |

---

## 本节页面

- [Routero Cloud]({% link zh-CN/deployment/cloud.md %}) —— 托管的多租户，通往生产环境的最快路径
- [单租户云]({% link zh-CN/deployment/single-tenant.md %}) —— 专用地域，物理隔离
- [私有部署]({% link zh-CN/deployment/private.md %}) —— 你的 VPC、你的算力、你的数据；可选 AWS、其他云或本地
- [本地部署]({% link zh-CN/deployment/local.md %}) —— 用于开发、评估或气隙环境的单机
- [参考架构]({% link zh-CN/deployment/reference-architecture.md %}) —— 标准的 AWS 拓扑（VPC · ALB · ECS Fargate · RDS · Redis · Cerbos）
- [数据驻留与地域]({% link zh-CN/deployment/data-residency.md %}) —— 地域选项，包括 AWS 中国（北京）
