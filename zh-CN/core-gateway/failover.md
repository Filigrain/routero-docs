---
lang: zh-CN
page_id: core-gateway/failover
permalink: /core-gateway/failover.html
title: 故障转移与回退
parent: LLM 网关
nav_order: 4
description: "多供应商故障转移链、自动重试行为，以及感知流式的回退。"
---

# 故障转移与回退

Routero AI 将供应商宕机视为路由问题，而非应用错误。配置一条回退链；Router 会透明地处理故障 —— 包括在活跃的流式响应过程中。

---

## 配置回退链

```yaml
# 在你的路由器配置中
router_settings:
  fallbacks:
    - openai/gpt-4o:
        - anthropic/claude-sonnet-4-6-20250514
        - bedrock/meta.llama4-maverick-17b-instruct-v1:0
  num_retries: 3
  timeout: 30                # per-attempt timeout (seconds)
```

当 `openai/gpt-4o` 返回 5xx 或超时时，Routero 会先在 `claude-sonnet-4-6` 上重试，再在 `llama-4-maverick` 上重试，然后才向调用方返回错误。

---

## 错误分类与重试行为

Routero 对供应商错误进行分类，并据此选择重试策略：

| 错误类型 | 默认行为 |
|---|---|
| `5xx`（服务器错误） | 在下一个健康部署上重试 |
| `429`（限流） | 在另一个部署上重试（遵循 `Retry-After`） |
| `timeout` | 在下一个部署上重试 |
| `content_filter` | 回退到 `content_policy_fallbacks` 链中的下一个模型 |

重试与回退会指向组或链中的其他健康部署；哪些错误会重试由 `RetryPolicy` 控制。

---

## 感知流式的故障转移

如果某个供应商在流中途失败，Routero 可回退到另一个供应商并继续响应，把已输出的部分一并传递，让回退模型从上次中断处接续。客户端会收到一条完整的 SSE 流，无需任何客户端侧的重试逻辑。

---

## 地域与回退链

回退链只会考虑你在其中列出的部署。要让一条链保持在单个数据驻留地域内，只需只列出部署在该地域的部署——Router 绝不会离开你所定义的链。如需按请求标签把流量锁定到特定部署（例如 EU 地域内的部署），请使用基于标签的路由。

→ [路由与负载均衡]({% link zh-CN/core-gateway/routing.md %})

---

## 逐请求可见性

重试与回退的细节可在每个请求上查看：
- 尝试过哪些供应商
- 最终由哪个回退供应商提供了服务
- 包含重试开销的总延迟

逐请求明细参见[日志]({% link zh-CN/observability/logs.md %})，并查看 `x-routero-attempted-retries` 与 `x-routero-attempted-fallbacks` 响应头。
