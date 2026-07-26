---
lang: zh-CN
page_id: core-gateway/routing
permalink: /core-gateway/routing.html
title: 路由与负载均衡
parent: LLM 网关
nav_order: 2
description: "Router 如何为每个请求挑选一个健康的部署——策略、模型组与基于健康状况的负载均衡。"
---

# 路由与负载均衡

当一个请求指定了模型时，**Router** 会挑出一个健康的部署来服务它。你把一个或多个供应商部署归到一个**模型名**下，选择一种**策略**来在它们之间挑选，Router 会基于实时的健康状况与用量数据应用该策略。

```
请求：model = "default"
   → 解析模型组
   → 按策略 + 实时健康状况挑一个部署
   → 调用它（失败则故障转移）
```

{: .note }
路由是在一个模型组*内部*挑选部署。[自动路由]({% link zh-CN/core-gateway/auto-router.md %}) 运行在它*之前*，可按消息意图把所请求的模型改写为另一个组。两者可组合。

---

## 模型组

一个模型组把一个名字映射到一个或多个供应商部署。发往该名字的请求会在这些部署之间做负载均衡：

```yaml
model_list:
  - model_name: default              # 调用方使用的名字
    litellm_params:
      model: openai/gpt-5.5
      api_key: os.environ/OPENAI_API_KEY

  - model_name: default
    litellm_params:
      model: anthropic/claude-sonnet-4-6-20250514
      api_key: os.environ/ANTHROPIC_API_KEY

  - model_name: default
    litellm_params:
      model: bedrock/anthropic.claude-sonnet-4-6-20250514-v1:0
```

`default` 是调用方发送的**公开名**——即你[添加模型](/)时设置的别名——而这三条是 Router 可选择的部署。单部署的组则把每个请求都路由到那一个部署。

你还可以用 `model_group_alias` 把一个公开名别名到另一个，让调用方使用稳定名称，而你在底层随时改写指向。

---

## 路由策略

设置 `routing_strategy`，决定 Router 如何在一个组的健康部署中挑选：

| 策略 | 选择方式 | 适用场景 |
|---|---|---|
| `simple-shuffle`（默认） | 按权重随机选择 | 均匀分发、简单部署 |
| `least-busy` | 在途请求数最少的部署 | 吞吐量受限的供应商 |
| `latency-based-routing` | 近期平均延迟最低的部署 | 对延迟敏感的流量 |
| `cost-based-routing` | 每 token 成本最低的部署 | 成本优化 |
| `usage-based-routing` | 距离其 TPM/RPM 用量最远的部署 | 高流量、混合限流 |

```yaml
router_settings:
  routing_strategy: least-busy
  num_retries: 3
  timeout: 30
```

基于标签的路由——按标签把请求锁定到特定部署（例如按地域）——是一个独立过滤器，可通过 `enable_tag_filtering` 叠加在任一策略之上启用。

---

## 健康与冷却

Router 在 Redis 中跟踪每个部署的健康状况，并把流量从不健康的部署上移开：

- **错误率** —— 跟踪 5xx、429 与内容过滤触发。
- **冷却** —— 跨过错误阈值的部署会被冷却（移出轮询）一段时间，然后再带回。
- **延迟** —— 近期响应延迟的滚动平均值，供 `latency-based-routing` 使用。
- **用量** —— 对照供应商声明限制的 TPM/RPM 用量，供 `usage-based-routing` 使用。

---

## 路由状态

所有路由状态——冷却、用量计数器、延迟窗口——都存放在 Redis 中。在多副本部署中，每个代理副本都通过 Redis 共享该状态，因此跨实例的负载均衡决策保持一致。

---

## 与网关其余部分的组合

- **自动路由** —— 运行在策略*之前*；按消息意图把所请求的模型改写到某个组。→ [自动路由]({% link zh-CN/core-gateway/auto-router.md %})
- **故障转移** —— 若所选部署在请求中途出错，Router 会在另一个部署上重试。→ [故障转移与回退]({% link zh-CN/core-gateway/failover.md %})
- **策略** —— 一个模型组可携带能力策略（护栏、提示词、记忆、Token 节省）。→ [策略]({% link zh-CN/core-gateway/policies.md %})
