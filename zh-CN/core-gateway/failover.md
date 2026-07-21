---
lang: zh-CN
page_id: core-gateway/failover
permalink: /core-gateway/failover.html
title: 故障转移与回退
parent: 核心网关
nav_order: 4
description: "多供应商故障转移链、自动重试行为，以及感知流式的回退。"
---

# 故障转移与回退

Routero AI 将供应商宕机视为路由问题，而非应用错误。配置一条回退链；Router 会透明地处理故障 —— 包括在活跃的流式响应过程中。

**P99 故障转移决策 + 重试：<280 毫秒。**

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
  retry_after: 0.08          # 80 ms base backoff
  timeout: 30                # per-attempt timeout (seconds)
  retry_on:
    - 5xx
    - timeout
    - content_filter
```

当 `openai/gpt-4o` 返回 5xx 或超时时，Routero 会先在 `claude-sonnet-4-6` 上重试，再在 `llama-4-maverick` 上重试，然后才向调用方返回错误。

---

## 错误分类与重试行为

Routero 对供应商错误进行分类，并据此选择重试策略：

| 错误类型 | 默认行为 |
|---|---|
| `5xx`（服务器错误） | 在回退链中的下一个部署上重试 |
| `429`（限流） | 退避后在**同一个**部署上重试（遵循 `Retry-After` 头） |
| `content_filter` | 跳转到下一个部署（不同模型可能不会触发过滤器） |
| `context_window` | 仅当下一个部署具有更大的上下文窗口时才跳转 |
| `auth_error` | 不重试；立即返回错误 |
| `timeout` | 在下一个部署上重试 |

---

## 感知流式的故障转移

如果某个供应商在流中途失败，Routero 仅在回退供应商上重放尚未发送的尾部内容。客户端会收到一个不间断的 SSE 流 —— 没有断开的连接，没有重复的 token，也无需客户端侧的重试逻辑。

---

## 感知预算的回退

回退会遵循你工作区的支出限额。如果主部署会超出预算上限，Router 会在发起调用前先选择链中的下一个部署 —— 预算检查在供应商调用之前完成。

→ [预算与支出护栏]({% link zh-CN/core-gateway/budgets.md %})

---

## 地域与回退链

回退链只会考虑你在其中列出的部署。要让一条链保持在单个数据驻留地域内，只需只列出部署在该地域的部署——Router 绝不会离开你所定义的链。如需按请求标签把流量锁定到特定部署（例如 EU 地域内的部署），请使用基于标签的路由。

→ [数据驻留与地域]({% link zh-CN/deployment/data-residency.md %}) · [路由与负载均衡]({% link zh-CN/core-gateway/routing.md %})

---

## 逐请求审计

每一次重试和回退决策都会记录在审计轨迹中：
- 尝试了哪个供应商
- 错误类型和重试原因
- 选择的回退供应商
- 包含重试开销的总延迟

响应会包含相应的头，标明所选供应商和重试次数，便于调试。
