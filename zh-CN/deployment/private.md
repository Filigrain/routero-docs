---
lang: zh-CN
page_id: deployment/private
permalink: /deployment/private.html
title: 私有部署
parent: 部署选项
nav_order: 3
description: "在你自有的基础设施中运行完整的 Routero AI 技术栈——VPC 隔离、完全的密钥控制、可用于气隙环境。"
---

# 私有部署

在你自有的基础设施中运行完整的 Routero AI 控制平面。你的 VPC、你的算力、你的数据——在初次部署之后，对 Routero 托管系统零依赖。

---

## 何时选择此方案

- **数据绝不离开你的边界** —— 供应商 API 密钥、审计日志以及所有运营数据都留在你拥有并掌控的基础设施中。
- **合规要求** —— FedRAMP、内部信息安全规定、客户合同要求，或禁止使用第三方托管算力的气隙环境。
- **完全的升级控制** —— 由你决定何时拉取新镜像并向前滚动升级；不会被强制采用 Routero Cloud 的持续部署。
- **自定义网络拓扑** —— 将技术栈锁定在私有 VPC 中，将出站流量限制到特定的供应商端点，并与你的内部 PKI 集成。

{: .enterprise }
> 私有部署在企业版套餐中提供。请联系你的解决方案工程师，以获取部署包、镜像仓库访问权限和接入支持。

---

## 你将获得什么

私有部署包提供与 Routero Cloud 相同的技术栈：

| 组件 | 功能 |
|---|---|
| **网关代理** | OpenAI 兼容的 HTTP 代理——路由、策略、预算、审计 |
| **Coworker 服务** | 用于异步任务、缓存预热、预算重置的后台工作进程 |
| **Cerbos** | 用于细粒度授权的 PBAC/RBAC 策略引擎 |
| **管理控制台** | 完整的控制台——密钥管理、团队、护栏、提示词注册表、记忆会话 |

你的基础设施提供有状态层：Postgres（主数据存储）、Redis（缓存和限流计数器），以及可选的用于记忆即服务的向量存储。

---

## 支持的环境

| 平台 | 说明 |
|---|---|
| **AWS** | 采用 ECS Fargate、RDS、ElastiCache 的参考架构。具备多可用区的完整高可用拓扑。 |
| **Azure / GCP** | 等效的托管容器 + 托管 Postgres + Redis 服务。拓扑指南可应需提供。 |
| **本地部署 / 气隙环境** | Kubernetes（或等效的容器运行时）+ 自管理 Postgres + Redis。镜像会被镜像到你的内部仓库。 |

→ [参考架构]({% link zh-CN/deployment/reference-architecture.md %})，了解标准的 AWS 拓扑（VPC · ALB · ECS Fargate · RDS · Redis · Cerbos）。

---

## 基线基础设施要求

| 资源 | 最低 | 推荐 |
|---|---|---|
| 算力（代理） | 2 vCPU / 4 GB RAM | 自动扩缩组，2+ 副本 |
| 算力（coworker） | 1 vCPU / 2 GB RAM | 1–2 副本 |
| Postgres | db.t3.small · 20 GB | db.t3.medium · 多可用区 |
| Redis | cache.t4g.small | cache.t4g.medium · 多可用区 |
| 记忆层（可选） | Postgres + pgvector | + Neo4j 用于知识图谱 |

**基线成本估算（AWS）：** 一个最小化生产拓扑约为每月 300 美元。记忆层服务额外增加约每月 50–150 美元。

---

## 升级

Routero 按固定的发布节奏发布更新的容器镜像。由你控制何时拉取并部署——不存在强制升级。发布说明可在你的客户门户中查看。

---

## 开始使用

请联系 [solutions@routero.ai](mailto:solutions@routero.ai) 或你指定的解决方案工程师。接入流程包括：

1. 镜像仓库访问权限和部署包
2. 架构评审通话（基础设施规格、网络拓扑、合规要求）
3. 部署演练和初始配置
4. 移交给客户成功团队以提供持续支持

→ [参考架构]({% link zh-CN/deployment/reference-architecture.md %}) · [数据驻留与地域]({% link zh-CN/deployment/data-residency.md %})
