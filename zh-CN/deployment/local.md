---
lang: zh-CN
page_id: deployment/local
permalink: /deployment/local.html
title: 本地部署
parent: 部署选项
nav_order: 5
description: "在单台机器上运行 Routero AI，用于本地开发、评估或气隙环境。"
---

# 本地部署

在你自己的机器上运行 Routero AI 的最快方式——用于评估平台、本地开发，或需要完整控制平面而又不依赖云的气隙环境。

---

## 何时选择此方案

- **评估** —— 在决定采用云部署之前，探索 Routero 的路由、策略和高级功能。
- **本地开发** —— 在开发过程中与你的应用并行运行网关，使你的开发环境与生产环境保持一致。
- **气隙 / 离线** —— 无对外互联网访问的环境。模型由本地端点提供服务（例如 Ollama）；网关执行与云相同的策略。
- **CI/CD 集成测试** —— 在流水线中启动网关，针对真实的 Routero 实例对你的应用进行集成测试。

{: .note }
本地部署不适用于生产流量。生产环境请使用 [Routero Cloud]({% link zh-CN/deployment/cloud.md %})、[单租户云]({% link zh-CN/deployment/single-tenant.md %})或[私有部署]({% link zh-CN/deployment/private.md %})。

---

## 你需要什么

| 组件 | 要求 |
|---|---|
| **Postgres** | v14+，带 pgvector（用于审计日志和密钥存储） |
| **Redis** | v7+（限流和缓存） |
| **Routero 代理** | 容器镜像——在部署包中提供 |
| **管理密钥** | 你自行选择的 `MASTER_KEY`；用于对管理 API 调用进行身份验证 |

无需云账户、无需 Terraform、无需外部服务。所有流量都留在你的机器上。

---

## 本地模式下的能力

所有 Routero 功能在本地均可使用，无需更改任何配置：

| 功能 | 本地可用 |
|---|---|
| 路由、故障转移、负载均衡 | ✓ |
| 策略路由（YAML 规则） | ✓ |
| 预算和支出追踪 | ✓ |
| 虚拟 API 密钥和组织 | ✓ |
| 护栏（包括 Presidio PII） | ✓ |
| 提示词管理 | ✓ |
| Token 节省（压缩 + 缓存） | ✓ |
| 记忆即服务（Mem0 / Cognee） | ✓（需 pgvector） |
| 管理控制台 | ✓ 在 `/_experimental/out/` 本地提供服务 |

本地模型端点（Ollama、LM Studio、vLLM，以及任何 OpenAI 兼容的服务器）作为一等供应商受到支持——在管理控制台的 **Models → Provider Keys** 中添加它们。

---

## 获取部署包

请联系 [solutions@routero.ai](mailto:solutions@routero.ai) 以获取：

- 容器镜像访问权限（私有仓库）
- `docker-compose.local.yml` 快速启动文件，可在几分钟内运行 Postgres + Redis + 代理
- 本地使用的许可证密钥

→ [参考架构]({% link zh-CN/deployment/reference-architecture.md %})，了解完整的组件拓扑 · [高级功能]({% link zh-CN/advanced-features.md %})，探索运行后可用的功能
