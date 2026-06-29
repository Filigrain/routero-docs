---
lang: zh-CN
page_id: deployment/reference-architecture
permalink: /deployment/reference-architecture.html
title: 参考架构
parent: 部署选项
nav_order: 5
nav_exclude: true
description: "Routero AI 标准的 AWS 拓扑：VPC、ALB、ECS Fargate、RDS、Redis、Cerbos 以及 coworker 服务。"
---

# 参考架构

Routero Cloud 与私有部署共同使用的标准生产环境拓扑。理解这一架构可以解答大多数安全审查中关于数据存放位置以及流量如何流转的问题。

---

## 拓扑概览

**流量路径：** Internet → Cloudflare → AWS ALB → ECS Fargate（私有子网，3 个可用区）

| 层级 | 组件 | 角色 |
|---|---|---|
| **边缘** | Cloudflare | WAF、DDoS、全球 CDN、TLS 终结、源站回源 mTLS |
| **入口** | AWS ALB（HTTPS/443） | 入口仅限 Cloudflare IP 段访问——禁止直接的互联网访问 |
| **计算** | `routero-proxy`（端口 4000） | 无状态网关——路由、策略、审计；自动扩缩 1 → 10 个任务 |
| **计算** | `routero-coworker`（无入口） | 后台工作进程——支出同步、缓存预热；基于 Redis 租约的主节点选举 |
| **缓存** | ElastiCache Redis | 限流计数器、密钥缓存、支出事件队列、响应缓存 |
| **数据库** | RDS Postgres —— 多可用区 | 三个实例：`litellm`（密钥/组织/支出）· `mem0` · `cognee` |
| **授权** | Cerbos（ECS，内部） | PBAC/RBAC 策略引擎——代理对每个授权决策都会调用它 |
| **记忆（可选）** | Neo4j · Qdrant · Redis-Stack | 由 EFS 支持的 ECS 任务——通过 `enable_memory_tier` 启用 |
| **CI/CD** | GitHub Actions（OIDC） | 无密钥部署——不存储 AWS 凭据 |
| **可观测性** | CloudWatch · Prometheus | 指标、日志、告警 |

---

## 组件

### 边缘：Cloudflare + ALB
- Cloudflare 代理所有公网流量（WAF、DDoS 防护、全球 CDN、边缘 TLS 终结）。
- ALB 安全组**仅接受来自 Cloudflare 已发布 IP 段的入口流量**——对源站的直接互联网访问被阻断。
- Cloudflare 使用源站回源 mTLS（`cloudflare-origin-pull-ca.pem`）向 ALB 进行身份验证。
- 只有 ALB 拥有公网 IP。所有 ECS 任务、RDS 和 Redis 都位于**私有子网**中，出站流量经由 NAT Gateway。

### 计算：ECS Fargate
两个服务运行在跨 3 个可用区的私有子网中：

**`routero-proxy`** —— FastAPI 网关。
- 基于 `ALBRequestCountPerTarget` 自动扩缩（空闲时 1 个任务 → 高负载时最多 10 个）。
- 健康检查 `startPeriod: 180s`（镜像为 2–3 GB；首次拉取较慢）。
- 部署熔断器：新部署后若健康检查失败则自动回滚。
- 启用 ECS Exec 以提供 shell 访问（记录到 CloudTrail）——无需 SSH 堡垒机。

**`routero-coworker`** —— 支出同步工作进程。
- `desired_count: 1`，配合基于 Redis 租约的主节点选举（因此可安全地在 N>1 下运行而不会重复处理）。
- 将支出增量从 Redis 异步落库到 RDS——使代理的热路径保持高速。
- 无入站流量；仅与 Redis 和 RDS 通信。

### 数据：RDS + ElastiCache
- **三个多可用区 RDS 实例**（默认 `db.t3.small`，可升级）：`litellm`（密钥、团队、组织、支出、模型）、`mem0`（Mem0 向量记忆）、`cognee`（Cognee 知识图谱）。
- `mem0` 和 `cognee` 需要 `pgvector` 扩展——通过一次性迁移安装。
- **ElastiCache Redis**（`t4g.small`）：限流计数器、密钥缓存、支出事件队列、路由冷却状态、可选的响应缓存。
- 供应商 API 密钥**在 RDS 中加密存储**，而非存储在 Secrets Manager 或环境变量中。

### 授权：Cerbos
- 作为独立的 ECS 任务运行在私有子网中。
- 代理在管理操作和数据平面操作上调用 Cerbos 进行授权决策。
- 策略包（`backend/cerbos/config/policies/`）为 UI 菜单、系统设置、供应商配置以及租户资源（API 密钥、模型访问、团队成员、钱包操作）定义了角色与资源。
- 若 Cerbos 暂时不可达，代理会优雅降级。

### CI/CD：GitHub Actions（OIDC）
- 所有部署均为无密钥——GitHub Actions 通过 OIDC 向 AWS 进行身份验证（不存储 IAM 凭据）。
- 两条流水线：**Terraform**（基础设施）与 **App**（镜像构建 + ECS 发布）。
- 晋级路径：`feature/*` → PR → `develop`（应用到 UAT）→ PR → `main`（应用到生产环境，需经审阅者批准把关）。

---

## 安全特性

| 特性 | 实现方式 |
|---|---|
| 任务无公网 IP | 私有子网 + 仅 NAT 出站 |
| 仅源站访问 | ALB 入口锁定到 Cloudflare IP 白名单 |
| 无 SSH | 改用 ECS Exec（SSM，记录到 CloudTrail） |
| 无长期有效的 AWS 密钥 | CI 使用 OIDC；运行时使用任务角色 |
| 静态加密 | 启用 RDS 加密；EFS 加密 |
| 供应商密钥受保护 | 加密存储于 RDS，绝不出现在日志中 |
| 审计轨迹 | AWS 操作使用 CloudTrail；所有 LLM 请求使用 Routero 审计日志 |
