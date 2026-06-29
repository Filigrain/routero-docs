---
lang: zh-CN
page_id: agents/tool-calling
permalink: /agents/tool-calling.html
title: 工具与函数调用
parent: 智能体与工具
nav_order: 3
description: "通过 Routero 进行标准的 OpenAI 兼容工具与函数调用。"
---

# 工具与函数调用

Routero 会将工具/函数定义原封不动地传递给上游供应商。所有 OpenAI 兼容的工具调用模式都开箱即用——并行工具调用、带工具增量（tool deltas）的流式传输，以及结构化输出。

---

## 标准用法

```python
tools = [
    {
        "type": "function",
        "function": {
            "name": "get_stock_price",
            "description": "Get the current stock price for a ticker symbol.",
            "parameters": {
                "type": "object",
                "properties": {
                    "ticker": {"type": "string", "description": "Stock ticker, e.g. AAPL"}
                },
                "required": ["ticker"]
            }
        }
    }
]

response = client.chat.completions.create(
    model="smart/balanced",
    messages=[{"role": "user", "content": "What is Apple's stock price?"}],
    tools=tools,
    tool_choice="auto",
)
```

---

## 工具权限护栏

使用 [护栏]({% link zh-CN/advanced-features/guardrails.md %}) 的 **工具权限（Tool Permission）** 引擎，在工具名称到达 LLM 之前对其强制执行允许列表或拒绝列表：

```json
{
  "engine_name": "tool_permission",
  "config": {
    "allowed_tools": ["get_stock_price", "get_news"],
    "on_violation": "block"
  },
  "event_hooks": ["pre_call"]
}
```

这可以防止调用方将未经批准的工具定义注入到请求中。

---

## 供应商支持

所有实现了 OpenAI 函数调用接口的供应商都支持工具调用。对于工具调用方式非标准的供应商（例如 Anthropic 的 tool_use），Routero 会自动将 OpenAI 模式转换为该供应商的原生格式。

有关各供应商的能力详情，请参阅 [统一 API → /models]({% link zh-CN/core-gateway/unified-api.md %})。
