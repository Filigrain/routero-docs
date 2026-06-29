---
lang: zh-CN
page_id: deployment/self-hosted-aws
permalink: /deployment/self-hosted-aws.html
title: 在 AWS 上自托管
parent: 部署选项
nav_order: 3
nav_exclude: true
description: "使用 Terraform 参考架构在你自己的 AWS 账户中部署 Routero AI。"
---

# 在 AWS 上自托管

在你自己的 AWS 账户中运行完整的、生产级的 Routero AI 堆栈。`llmrouter-terraform` 中的 Terraform 参考架构会预置与 Routero 在生产环境中运行相同的拓扑：ECS Fargate、自定义 VPC、ALB、多可用区 RDS、ElastiCache、Cerbos，以及一个自动扩缩的 coworker 服务。

---

## 何时选择这种方式

- 你需要将所有数据和供应商密钥保留在自己的 AWS 账户边界内。
- 你的合规计划（FedRAMP、内部 InfoSec、客户合同要求）禁止使用由第三方托管的计算资源。
- 你希望完全掌控升级时机。
- 你拥有内部的 AWS/Terraform 专业能力。

**预估基线成本：** 一套最小化生产拓扑约为每月 300 美元（Fargate 任务 + db.t3.small RDS + t4g.small ElastiCache）。记忆层服务（Neo4j、Qdrant、Redis-Stack）会再增加约每月 50–150 美元，具体取决于 EFS 用量。

---

## 前置条件

- Terraform ≥ 1.5
- 一个具备 ECS、EC2、RDS、ElastiCache、ECR、IAM、Route53/CloudWatch/VPC 相关 IAM 权限的 AWS 账户
- 用于 Terraform 远程状态的 S3 存储桶 + DynamoDB 表（由 `tf-bootstrap/` 预置）
- 一个为 GitHub Actions CD 流水线配置了 OIDC 角色的 GitHub 仓库（或 CI 系统）
- 用于 DNS 和边缘的 Cloudflare 账户（可选，但推荐——参考架构会将 ALB 入口锁定到 Cloudflare 回源 IP）
- 用于事务性邮件的 Resend API 密钥

---

## 部署步骤

### 1. 引导远程状态

```bash
cd tf-bootstrap/
terraform init
terraform apply
```

这将为 Terraform 状态预置 S3 存储桶和 DynamoDB 锁表。

### 2. 配置环境变量

将 `envs/production.tfvars.example` 复制为 `envs/production.tfvars` 并填写：
- VPC CIDR、地域和可用区配置
- RDS 实例类型和数据库名称
- 代理与 coworker 服务的 ECR 镜像 URI
- 密钥（主密钥、数据库密码）——在 Terraform 状态中加密存储

### 3. 应用生产堆栈

```bash
cd tf-production/
terraform init -backend-config=../envs/backend-production.conf
terraform plan -var-file=../envs/production.tfvars
terraform apply -var-file=../envs/production.tfvars
```

### 4. 添加供应商 API 密钥

打开 Routero 管理后台（由代理在 `/_experimental/out/` 提供）并添加你的 LLM 供应商凭据。密钥在 RDS 中加密存储——而非存储在 Secrets Manager 或环境变量中。

### 5. 接入 DNS

在 Cloudflare 中添加一条 CNAME，将你选定的主机名指向 ALB 的 DNS 名称。Terraform 不管理 Cloudflare DNS——这是有意设计的手动步骤。

---

## 基础设施模块

Terraform 堆栈由可复用的模块组成：

| 模块 | 预置内容 |
|---|---|
| `vpc` | 自定义 VPC，跨 3 个可用区的 3 个公有 + 3 个私有子网，NAT Gateway |
| `edge` | ACM 证书、面向互联网的 ALB、HTTPS 监听器、Cloudflare IP 白名单、mTLS 回源 |
| `cluster` | ECS 集群、代理服务（端口 4000、ALB 目标、自动扩缩 1–10）、coworker 服务 |
| `stateful` | 三个多可用区 RDS 实例（litellm、mem0、cognee）+ ElastiCache Redis |
| `memory` | 在 EFS 上运行 Neo4j、Qdrant、Redis-Stack 的可选 ECS 任务（通过 `enable_memory_tier = true` 启用） |
| `cerbos` | 作为 ECS 任务运行的 Cerbos PBAC/RBAC 策略引擎 |
| `service-discovery` | 用于服务间通信的 AWS Cloud Map 内部 DNS |

→ 查看[参考架构]({% link zh-CN/deployment/reference-architecture.md %})以获取完整的拓扑图和组件说明。

---

## 升级

Routero 会将更新后的容器镜像发布到一个公共 ECR。要部署新版本：

```bash
# 在你的 tfvars 中更新镜像标签，然后：
aws ecs update-service --cluster routero-production --service routero-production --force-new-deployment
```

ECS 部署熔断器会在健康检查失败时自动回滚。需要时，shell 访问通过 ECS Exec 进行——无需 SSH 堡垒机。
