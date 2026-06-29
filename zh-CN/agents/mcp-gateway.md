---
lang: zh-CN
page_id: agents/mcp-gateway
permalink: /agents/mcp-gateway.html
title: MCP 网关
parent: 智能体与工具
nav_order: 2
description: "集中注册 Model Context Protocol（MCP）服务器，并通过 Routero 暴露其工具。"
---

# MCP 网关

{: .beta }
> MCP 网关处于 **beta** 阶段，可能并未在所有部署中启用。请联系你的解决方案工程师确认可用性。

MCP 网关让你能够集中注册 [Model Context Protocol（MCP）](https://modelcontextprotocol.io) 服务器，并通过单一受治理的入口点将其工具暴露给任意 LLM 请求——具备鉴权、访问组以及可选的公共注册表。

---

## 工作原理

在 Routero 中注册一个 MCP 服务器（通过 URL 或配置）。网关会将其挂载在 `/mcp/{server_name}`，作为 Streamable-HTTP + SSE 服务器。客户端连接到网关端点——Routero 负责鉴权、校验调用方的密钥、强制执行访问组，并将工具调用代理到上游 MCP 服务器。

---

## 服务器管理

```bash
# 注册 MCP 服务器
POST /mcp-rest/server
{ "server_name": "github-tools", "server_url": "https://mcp.github.example.com" }

# 列出服务器
GET /mcp-rest/server

# 检查健康状态
GET /mcp-rest/server/health

# 管理访问组
POST /mcp-rest/access_groups
```

---

## MCP 端点

| 端点 | 描述 |
|---|---|
| `GET/POST /mcp` | 默认 MCP 服务器（Streamable-HTTP） |
| `GET/POST /mcp/{server_name}` | 命名服务器 |
| `POST /mcp-rest/tools/list` | 列出已注册服务器上的工具 |
| `POST /mcp-rest/tools/call` | 调用特定工具 |
| `GET /mcp-rest/registry.json` | 可用服务器的公共注册表 |

OAuth 发现端点（`/authorize`、`/token`、`/callback`、`.well-known`）可用于客户端凭据流程。

---

## 即将推出

包括工具访问控制、服务器健康监控以及公共注册表格式在内的完整文档正在编写中。[联系我们](https://routero.ai/demo.html) 获取抢先体验指南。
