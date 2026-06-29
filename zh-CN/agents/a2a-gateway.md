---
lang: zh-CN
page_id: agents/a2a-gateway
permalink: /agents/a2a-gateway.html
title: A2A 智能体网关
parent: 智能体与工具
nav_order: 1
description: "通过 Routero 的鉴权与成本层代理并治理 Agent-to-Agent（A2A）协议智能体。"
---

# A2A 智能体网关

{: .beta }
> A2A 智能体网关处于 **beta** 阶段。API 与行为可能发生变化。在基于 A2A 端点构建生产工作流之前，请先联系你的解决方案工程师。

A2A 智能体网关让你能够注册、调用并治理实现了 [Agent-to-Agent（A2A）协议](https://google.github.io/A2A/) 的 AI 智能体。每一次智能体调用都会经过 Routero 的鉴权、成本追踪和策略层——与 LLM 请求使用相同的处理管道。

---

## 工作原理

1. 在 Routero 中注册一个外部 A2A 智能体（通过其 card URL）。Routero 会重写该智能体的 card，使其指向网关。
2. 调用方通过 Routero 调用该智能体：`POST /a2a/{agent_id}` 或 `POST /v1/a2a/{agent_id}/message/send`。
3. Routero 校验调用方的密钥、检查权限、将请求代理到上游智能体、记录成本与用量，并将响应流式返回。

由于所有流量都经过网关路由，智能体调用会与标准 LLM 请求一起出现在你的审计日志、支出仪表盘和限流计数器中。

---

## 智能体管理

```bash
# 注册 A2A 智能体
POST /v1/agents
{ "agent_name": "my-agent", "agent_card_url": "https://agent.example.com/.well-known/agent.json" }

# 列出已注册的智能体
GET /v1/agents

# 设为公开（无需 Routero 密钥即可访问）
POST /v1/agents/{agent_id}/make_public
```

---

## 推理端点

| 端点 | 描述 |
|---|---|
| `GET /a2a/{agent_id}/.well-known/agent-card.json` | 智能体发现 card（已重写为指向代理） |
| `POST /a2a/{agent_id}` | JSON-RPC 2.0 调用 |
| `POST /a2a/{agent_id}/message/send` | A2A message/send |
| `POST /v1/a2a/{agent_id}/message/send` | A2A message/send（v1 别名） |

支持通过 `message/stream` 进行流式传输（ndjson）。

---

## 即将推出

包括鉴权模式、按智能体预算以及 A2A 工具集成在内的完整文档正在编写中。[联系我们](https://routero.ai/demo.html) 获取抢先体验指南。
