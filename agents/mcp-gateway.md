---
title: MCP Gateway
parent: Agents & Tools
nav_order: 2
description: "Register Model Context Protocol (MCP) servers centrally and expose their tools through Routero."
---

# MCP Gateway

{: .beta }
> The MCP Gateway is in **beta** and may not be enabled in all deployments. Contact your solutions engineer to confirm availability.

The MCP Gateway lets you register [Model Context Protocol (MCP)](https://modelcontextprotocol.io) servers centrally and expose their tools to any LLM request through a single governed entry point — with auth, access groups, and an optional public registry.

---

## How it works

Register an MCP server (by URL or config) in Routero. The gateway mounts it at `/mcp/{server_name}` as a Streamable-HTTP + SSE server. Clients connect to the gateway endpoint — Routero handles auth, validates the caller's key, enforces access groups, and proxies tool calls to the upstream MCP server.

---

## Server management

```bash
# Register an MCP server
POST /mcp-rest/server
{ "server_name": "github-tools", "server_url": "https://mcp.github.example.com" }

# List servers
GET /mcp-rest/server

# Check health
GET /mcp-rest/server/health

# Manage access groups
POST /mcp-rest/access_groups
```

---

## MCP endpoints

| Endpoint | Description |
|---|---|
| `GET/POST /mcp` | Default MCP server (Streamable-HTTP) |
| `GET/POST /mcp/{server_name}` | Named server |
| `POST /mcp-rest/tools/list` | List tools across registered servers |
| `POST /mcp-rest/tools/call` | Call a specific tool |
| `GET /mcp-rest/registry.json` | Public registry of available servers |

OAuth discovery endpoints (`/authorize`, `/token`, `/callback`, `.well-known`) are available for client credential flows.

---

## Coming soon

Full documentation including tool access control, server health monitoring, and the public registry format is being written. [Contact us](https://routero.ai/demo.html) for early-access guidance.
