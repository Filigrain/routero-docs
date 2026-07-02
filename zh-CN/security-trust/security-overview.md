---
lang: zh-CN
page_id: security-trust/security-overview
permalink: /security-trust/security-overview.html
title: 安全概览
parent: 安全与信任
nav_order: 1
description: "Routero AI 的架构、密钥管理、访问控制与威胁模型。"
---

# 安全概览

Routero AI 的设计目标是成为你安全问卷的事实依据来源，而非事后补充。本页介绍平台、安全与采购团队所关心的核心安全特性。

---

## 信任边界

Routero 充当 LLM API 调用的**数据平面中间层**。它从不存储提示词或响应内容——只存储元数据（token 计数、模型、成本、延迟、时间戳、密钥/组织归属）。

你需要评估的安全边界为：
1. 网关本身（网关代码、基础设施、密钥处理）
2. 你的应用与 Routero 之间的通道
3. Routero 与上游 LLM 供应商之间的通道
4. 审计数据的存储位置以及谁可以访问它

---

## 密钥管理

| 密钥类型 | 存储位置 | 谁能看到 |
|---|---|---|
| 供应商 API 密钥（OpenAI、Anthropic 等） | 加密存储于 RDS，AES-256 | 仅管理员密钥（绝不会在 API 响应或日志中返回） |
| Routero 虚拟 API 密钥 | 以 bcrypt 哈希形式存储 | 原始值仅在创建时显示一次 |
| Routero 主密钥 | 环境变量 / AWS SSM | 运维团队 |
| 数据库凭据 | Terraform state（加密）/ SSM | 运维团队 |
| TLS 证书 | ACM（托管）/ Let's Encrypt | 自动轮换 |

供应商 API 密钥**绝不会被记录、回显或导出**。创建后无法通过任何 API 端点检索。

---

## 网络安全

- 所有外部流量经由 Cloudflare WAF（DDoS、在边缘进行 TLS 终止）
- ALB 仅接受来自 Cloudflare 公布 IP 段的入站流量（origin-pull mTLS）
- 所有 ECS 任务、RDS 与 Redis 均位于私有子网——无公网 IP
- 出站流量仅通过 NAT Gateway
- 无 SSH 堡垒机——运维人员通过 ECS Exec 访问（记录到 CloudTrail）

---

## 访问控制

| 控制项 | 实现方式 |
|---|---|
| 身份验证 | 虚拟 API 密钥（带作用域、TTL、可撤销）；仪表板访问通过管理员发放的邀请 |
| 授权 | Cerbos PBAC/RBAC——每一项管理与数据平面操作都会被检查 |
| 预配 | 仅限管理员邀请——没有公开自助注册；由管理员创建用户和团队 |
| 内部服务 | 内部环回密钥（签名的服务账户，而非用户密钥） |

---

## 安全 SDLC

- 所有代码变更在合并前都需经过 PR 审查
- CI 流水线：依赖扫描（Trivy）、密钥扫描、静态分析
- 容器镜像：非 root 用户、最小化基础镜像、无 SSH
- ECS 部署熔断器：健康检查失败时自动回滚
- 基于 OIDC 的 GitHub Actions——无长期有效的 AWS 凭据

---

## 事件响应

- SOC 2 Type II 审计涵盖事件响应流程
- 生产环境告警接入 PagerDuty（p1 SLA：30 分钟响应）
- 状态页面：[status.routero.ai](https://status.routero.ai)
- 安全漏洞披露：security@routero.ai

如需完整的安全问卷，请联系你的解决方案工程师。
