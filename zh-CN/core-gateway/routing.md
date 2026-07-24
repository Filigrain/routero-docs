---
lang: zh-CN
page_id: core-gateway/routing
permalink: /core-gateway/routing.html
title: 路由与负载均衡
parent: 核心网关
nav_order: 2
description: "路由策略、模型组、Router，以及 Routero 如何为每个请求选择供应商。"
---

# 路由与负载均衡

Routero Router 使用可插拔策略，将每个请求分发到一个或多个已配置的供应商部署上。你配置模型组（一个命名别名 → 供应商部署列表）；Router 会基于实时健康状况和你选择的策略挑选其中之一。

---

## 路由策略

| 策略 | 选择方式 | 适用场景 |
|---|---|---|
| `simple_shuffle`（默认） | 按权重随机选择 | 均匀分发、简单部署 |
| `least_busy` | 在途请求数最少的部署 | 吞吐量受限的供应商 |
| `lowest_latency` | 近期 p50 延迟最低的部署 | 对延迟敏感的应用 |
| `lowest_cost` | 每 token 成本最低的部署 | 成本优化 |
| `lowest_tpm_rpm` | 距离其 TPM/RPM 限制最远的部署 | 规避限流 |
| `usage_based_routing_v2` | 实时跟踪用量与供应商限制的对比 | 高流量、混合限流 |
| `tag_based_routing` | 将请求标签与部署标签匹配 | 驻留、能力路由 |

在你的 Router 配置中，为每个模型组设置策略。

---

## 模型组

模型组将一个命名别名映射到一个有序的供应商部署列表。示例：

```yaml
model_list:
  - model_name: default
    litellm_params:
      model: openai/gpt-4o
      api_key: os.environ/OPENAI_API_KEY
    model_info:
      mode: chat

  - model_name: default
    litellm_params:
      model: anthropic/claude-sonnet-4-6-20250514
      api_key: os.environ/ANTHROPIC_API_KEY

  - model_name: default
    litellm_params:
      model: bedrock/anthropic.claude-sonnet-4-6-20250514-v1:0

router_settings:
  routing_strategy: least_busy
  num_retries: 3
  timeout: 30
```

发往 `model: "default"` 的请求会分发到全部三个部署。发生故障时，Router 会自动在下一个可用部署上重试。

---

## 健康监控

Router 在 Redis 中跟踪每个部署的健康状况：
- **错误率** —— 跟踪 5xx、429 和内容过滤触发率。
- **冷却** —— 越过错误阈值的部署会被冷却（移出轮换）一段可配置的时间。
- **延迟百分位** —— p50/p95 滚动窗口，供 `lowest_latency` 策略使用。
- **TPM/RPM 接近度** —— 跟踪用量与声明的供应商限制的对比，供 `usage_based_routing_v2` 使用。

---

## 路由状态

所有路由状态（冷却、用量计数器、延迟窗口）都存储在 Redis 中。在多实例部署中，所有代理副本共享同一份路由状态 —— 除了共享的 Redis，无需任何跨实例协调。

→ 关于 Router 如何在请求中途处理供应商错误，参见 [故障转移与回退]({% link zh-CN/core-gateway/failover.md %})。
→ 关于在上述策略之前运行的、基于意图的模型选择，参见 [自动路由]({% link zh-CN/core-gateway/auto-router.md %})。
