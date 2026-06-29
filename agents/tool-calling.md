---
lang: en
page_id: agents/tool-calling
title: Tool & Function Calling
parent: Agents & Tools
nav_order: 3
description: "Standard OpenAI-compatible tool and function calling through Routero."
---

# Tool & Function Calling

Routero passes tool/function definitions through to the upstream provider unchanged. All OpenAI-compatible tool calling patterns work out of the box — parallel tool calls, streaming with tool deltas, and structured outputs.

---

## Standard usage

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

## Tool Permission Guardrail

Use the [Guardrails]({% link advanced-features/guardrails.md %}) **Tool Permission** engine to enforce an allow-list or deny-list on tool names before they reach the LLM:

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

This prevents callers from injecting unapproved tool definitions into the request.

---

## Provider support

Tool calling is supported on all providers that implement the OpenAI function-calling interface. For providers with non-standard tool calling (e.g., Anthropic tool_use), Routero translates the OpenAI schema to the provider's native format automatically.

See [Unified API → /models]({% link core-gateway/unified-api.md %}) for per-provider capability details.
