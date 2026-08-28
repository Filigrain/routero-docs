---
lang: zh-CN
page_id: core-gateway/mcp
permalink: /core-gateway/mcp.html
title: MCP 网关
parent: LLM 网关
nav_order: 8
description: "MCP 服务器只需注册一次——智能体、脚本与标准 MCP 客户端通过 Routero 用一把虚拟密钥调用工具，附带组织隔离、用量追踪与护栏。"
---

# MCP 网关

模型上下文协议（MCP）是 AI 应用连接外部工具的方式——搜索、数据库、邮件，任何以 MCP 服务器形式暴露的能力。Routero 网关原生支持 MCP：把你的 MCP 服务器注册一次，所有调用 Routero 的对象——你的智能体、脚本，以及 Cursor 这类标准 MCP 客户端——都通过单一端点访问其工具，用虚拟密钥认证。

网关对待 MCP 流量与对待 LLM 流量一视同仁：用虚拟密钥**认证**、按组织**隔离**（服务器绝不跨租户泄露）、在用量视图中按工具调用**记录用量**，并由**护栏**检查工具结果。

---

## 三种使用方式

| 使用者 | 方式 |
|---|---|
| **你的智能体代码** | 在 OpenAI SDK 请求中加入一个 `mcp` 工具项。网关获取工具、运行模型、执行工具调用，并持续发起后续调用，直到模型得到答案。 |
| **任意脚本** | 向网关的 `/mcp` 端点 `POST` 无状态 JSON-RPC——`tools/list`、`tools/call`、prompts 与 resources——无需握手，也无需维护会话。 |
| **标准 MCP 客户端**（Cursor、Claude Desktop……） | 把网关注册为一个 streamable-HTTP MCP 服务器。客户端看到的就像是自己本地的工具。 |

---

## 注册 MCP 服务器

打开导航中的 **MCP Servers**，选择 **Add MCP Server**。表单包含：

- **Server name（服务器名称）** —— 在组织内唯一。请用 `_` 而不是 `-`（空格会转为下划线，别名遵循同一规则）。
- **Alias（别名）** —— 可选的短标识符，留空时从名称自动生成。连接多台服务器时，工具名会以别名为前缀。
- **Server URL（服务器 URL）** —— 上游 MCP 服务器的 streamable-HTTP 端点。
- **Authentication（认证方式）** —— `none`，或一个静态凭据（`API key` / `bearer token` / `basic`），与服务器一同保存并在每次调用时发送。凭据只写不读——不会再显示。
- **Description（描述）** —— 可选。

![MCP Servers 页面——已注册的服务器列表，含健康状态与组织标签](/assets/images/mcp/mcp-list.png)

![Add MCP Server 抽屉——名称、别名、URL 与认证](/assets/images/mcp/add-mcp-server.png)

{: .warning }
> **仅支持 HTTP。** 上游服务器必须提供 streamable-HTTP MCP 传输。本地 `stdio` 服务器无法在托管网关上运行，旧的 SSE 传输也不被接受——请为 Routero 提供一个 HTTP 端点。

创建后，网关会连接该服务器，周期性执行**健康检查**，并列出发现的工具。两个设置可以收敛调用方看到的范围：

- **工具选择（工具允许列表）** —— 只有勾选的工具会被暴露和调用；之后新发现的工具保持隐藏，直到你启用。
- **Header Settings（请求头设置）** —— 要从每个入站请求转发的额外请求头名称（用于按用户传递凭据），以及每次调用都附带的静态请求头。已存凭据的值永远不会显示——只显示名称。

![服务器详情视图——MCP Tools 标签页：左侧为工具允许列表，右侧为测试面板](/assets/images/mcp/mcp-detail-tools.png)

![Header Settings——转发的请求头名称与静态键值对](/assets/images/mcp/mcp-header-settings.png)

**MCP Tools** 标签页把允许列表与测试面板合为一体：在左侧选择工具、在右侧填入 JSON 参数并调用，即可看到原始结果——与应用实际使用的调用路径相同。

---

## 接入你的应用

MCP Servers 页面的 **Connect** 标签页提供即复即用的代码片段，已填入你的网关地址。

**智能体（OpenAI SDK，Responses API）：** 按名称引用网关自带的 MCP 服务器，模型即可调用你有权访问的所有工具。设置 `require_approval: "never"` 后，网关会自动执行工具调用并返回最终答案：

```python
from openai import OpenAI

client = OpenAI(
    base_url="{{ site.api_base_url }}/v1",
    api_key="YOUR_ROUTERO_KEY",
)

response = client.responses.create(
    model="gpt-4o",
    input="Send an email via MCP",
    tools=[{
        "type": "mcp",
        "server_url": "routero_proxy",
        "require_approval": "never",
    }],
    extra_headers={"x-mcp-servers": "github,search"}  # 可选：限定具体服务器
)
```

**任意脚本（无状态 JSON-RPC）：**

```bash
curl -X POST {{ site.api_base_url }}/mcp \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "x-routero-api-key: Bearer YOUR_ROUTERO_KEY" \
  -d '{"jsonrpc": "2.0", "id": 1, "method": "tools/list"}'
```

**标准 MCP 客户端（Cursor）：** 把网关注册为 streamable-HTTP 服务器：

```json
{
  "mcpServers": {
    "routero-gateway": {
      "url": "{{ site.api_base_url }}/mcp",
      "headers": { "x-routero-api-key": "YOUR_ROUTERO_KEY" }
    }
  }
}
```

![Connect 标签页——服务器限定选择器与即复即用的代码片段](/assets/images/mcp/mcp-connect-tab.png)

---

## 访问控制

**可见性。** 一把密钥能看到你组织自己的服务器，以及平台面向所有人发布的服务器（标记为 *Public*）。私有服务器对组织外不可见——在执行路径上，对平台管理员同样如此。

**谁能调用什么。** 默认情况下，无限制的密钥可以调用其组织可见的所有服务器。在密钥详情页的 **MCP / Agents** 标签页收敛权限：

- **服务器集合** —— 该密钥可访问的具体服务器（不选表示不受限）。
- **按工具的白名单** —— 在同一台服务器内，该密钥可调用的工具。

限制只会收窄——授权永远无法引入其他组织的服务器。

**按用户传递凭据。** 如果服务器配置了转发某个入站请求头（例如 `authorization`），每个请求可以用 `x-mcp-<别名>-<请求头>` 携带最终用户自己的凭据——网关只会把它传给那台服务器。直接发给网关的凭据请求头绝不会被盲目转发。

![密钥详情页的 MCP / Agents 标签页——服务器集合与按工具白名单](/assets/images/mcp/mcp-key-binding.png)

---

## 工具命名与结果

当调用方可以访问**不止一台**服务器时，工具名会加上服务器别名前缀（`github-search_code`），同名工具不会冲突；只有一台服务器时，工具保持原名。工具结果按上游服务器的原样返回——文本、结构化内容，或以工具级错误结果呈现的错误。

**护栏依然生效。** 后置护栏引擎会在工具结果到达模型之前检查它——PII 引擎可以脱敏结果，阻断型引擎会让调用失败。

**每次工具调用都有日志。** MCP 调用会以工具名（`MCP: <tool>`）出现在请求日志中；若你的平台套餐对 MCP 调用定价，用量视图中还会显示单次调用费用。

---

## 说明与限制

- **无状态协议。** 网关使用无状态 streamable-HTTP MCP 协议——没有 `initialize` 握手，没有会话。客户端须支持 streamable-HTTP。工具之外，prompts 与 resources 也一并代理。
- **失败开放的发现。** 某台上游服务器宕机时，`tools/list` 仍会返回健康服务器的工具；该服务器的健康状态会显示故障。
- **网关自带的模型服务器。** `routero_proxy` 把你部署在网关上的模型暴露为 MCP 工具——想让脚本不走 SDK 快速完成一次补全时很方便。
- **超时。** 工具发现对每台服务器最多等待 30 秒；单个工具调用的耗时取决于上游服务器本身。

---

## 与网关其余部分的组合

- **API Keys** —— 所有使用者都用[虚拟密钥]({% link zh-CN/core-gateway/api-keys.md %})认证；可按上述方式按服务器、按工具收窄。
- **护栏** —— 后置引擎检查工具结果（[护栏]({% link zh-CN/advanced-features/guardrails.md %})）。
- **日志与用量** —— 工具调用与其他请求一样进入[日志]({% link zh-CN/observability/logs.md %})与[用量]({% link zh-CN/observability/usage.md %})视图。

→ 你的 MCP 使用者所需的凭据，参见 [API Keys]({% link zh-CN/core-gateway/api-keys.md %})。
