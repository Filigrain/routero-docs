---
lang: zh-CN
page_id: deployment/single-tenant
permalink: /deployment/single-tenant.html
title: 单租户云
parent: 部署选项
nav_order: 2
description: "在你选定的地域中部署一套专属的 Routero 技术栈——物理隔离，由 Routero 托管运营。"
---

# 单租户云

在你选定的 AWS 地域和账户中预置的、完全隔离的 Routero 技术栈，由 Routero 运营。你将获得与托管云相同的控制平面，并具备物理数据隔离，不共享任何基础设施。

{: .enterprise }
> 单租户云在**企业版套餐**中提供。请联系你的解决方案工程师进行需求评估与预置。

---

## 与 Routero Cloud 的区别

| | Routero Cloud | 单租户云 |
|---|---|---|
| AWS 账户 | Routero 的 | 每客户专属（或你自有的） |
| VPC | 共享 | 专用 |
| RDS | 共享（行级隔离） | 专用实例 |
| Redis | 共享 | 专用 |
| 数据地域 | 新加坡（ap-southeast-1） | 由你选择 |
| 运维 | Routero | Routero |
| 自定义域名 | — | 可行（`api.yourco.com`） |

---

## 使用场景

- **受监管行业** —— 医疗（HIPAA BAA）、金融服务、政府等数据必须存放在特定地域或账户中的场景。
- **中国数据驻留** —— Routero 在 AWS 中国（北京，cn-north-1）运营生产级单租户技术栈，面向受 PIPL 约束的客户。参见[数据驻留与地域]({% link zh-CN/deployment/data-residency.md %})。
- **影响范围隔离** —— 确保多租户云中的“吵闹邻居”事件不会影响你的工作负载。
- **自定义集成** —— 需要特定 VPC 对等连接、专线（private link）或内部 DNS 配置的企业客户。

---

## 预置流程

1. 你的解决方案工程师评估地域、实例规格、保留期限和合规要求。
2. Routero 使用与托管云相同的 Terraform 参考架构来预置技术栈（参见[参考架构]({% link zh-CN/deployment/reference-architecture.md %})）。
3. 你将收到专属实例的 API 端点、控制台 URL 以及初始管理员凭据。
4. Routero 负责运营、监控和升级该技术栈——你将获得与 Routero 托管相同的体验，同时具备物理隔离。
