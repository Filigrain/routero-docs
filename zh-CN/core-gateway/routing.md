---
lang: zh-CN
page_id: core-gateway/routing
permalink: /core-gateway/routing.html
title: 路由与负载均衡
parent: LLM 网关
nav_order: 2
description: "Routero 如何在一个模型背后的多个部署之间分发请求，以及按密钥配置的负载均衡与重试设置。"
---

# 路由与负载均衡

当一个模型背后有多个部署时——例如同一个模型在两家供应商，或一个主部署加一个备用——Routero 会把每个请求发给其中之一并分摊负载。它还会绕开正在出错的部署，并在调用失败时改到别处重试。

你不需要为每个请求挑选部署。你把多个部署归到同一个**公开模型名（Public Model Name，即你调用的名字）**下，并**在每个虚拟密钥上**配置 Routero 如何在其中挑选。

{: .note }
这是*负载均衡*——在一个模型名背后的多个部署中挑选。[自动路由]({% link zh-CN/core-gateway/auto-router.md %})不同：它根据用户的问题来决定用哪个模型。两者配合使用。

---

## 模型组

一个**模型组**是一个公开模型名背后挂载的一个或多个部署。要创建模型组，[添加模型](/)并给它们相同的公开模型名——例如两条都叫 `openai/gpt-5.5` 的记录，一条指向 OpenAI、一条指向 Azure OpenAI。发往 `openai/gpt-5.5` 的请求随后会在两者之间分摊；若其中一家供应商出问题，流量会转到另一家。

在 **Models** 页面上，同名部署会合并为一张卡片。你能看到它背后的**部署数**和**供应商**，工具栏还会汇总所有组的总数。

![Models 页面——按公开模型名分组的部署，显示部署数与供应商](/assets/images/routing/routing-models-grid.png)

点击卡片打开该组：它会列出该名字背后的每一个部署——供应商、底层模型与成本。

![打开的模型组——一个公开模型名背后的部署、供应商与成本](/assets/images/routing/routing-model-detail.png)

只有一个部署的名字则把每个请求都路由到那一个部署。

---

## 负载均衡

负载均衡是**按虚拟密钥**配置的。打开某个密钥的详情页，进入 **Router Settings** 标签，再打开 **Loadbalancing** 子标签。你在那里设置的策略与重试设置会作用于该密钥发出的每一个请求。

![密钥详情 → Router Settings → Loadbalancing：路由策略与可靠性及重试](/assets/images/routing/routing-key-router-settings.png)

### 路由策略

选择 Routero 如何从模型组中挑选部署：

| 策略 | 作用 |
|---|---|
| **Simple Shuffle（随机）** | 从列表中随机挑选一个部署。简单且快速。 |
| **Least Busy（最空闲）** | 路由到正在进行请求数最少的部署。 |
| **Latency Based Routing（按延迟）** | 路由到在滑动窗口内延迟最低的部署。 |
| **Cost Based Routing（按成本）** | 路由到每 token 成本最低的部署。 |
| **Usage Based Routing（按用量）** | 路由到跨实例 TPM/RPM 用量最低的部署。 |

想要均匀分发用 **Simple Shuffle**；想避免某一家供应商过载用 **Least Busy** 或 **Usage Based**；追求最快响应用 **Latency Based**；想优先最便宜的部署用 **Cost Based**。

### 可靠性与重试

同一标签下还可以为该密钥调整失败处理方式：

- **Allowed Fails** —— 一个部署失败多少次后会被冷却（移出轮询）。
- **Cooldown Time** —— 失败的部署移出轮询多久。
- **Number of Retries** / **Timeout** / **Retry After** —— 重试次数、单请求超时、以及重试之间的最小等待时间。

如需有序的回退链（模型 A → B → C），使用同一界面的 **Fallbacks** 子标签——参见[故障转移与回退]({% link zh-CN/core-gateway/failover.md %})。

---

## 健康与故障转移

Routero 会跟踪每个部署的健康状况。当某个部署跨过你设置的 **Allowed Fails** 阈值，它会被冷却你设置的 **Cooldown Time** 时长，流量自动流向健康的部署。

如果正在服务某请求的部署在中途失败，Routero 会在同一组的另一个部署上重试，或转到你回退链中的下一个模型——参见[故障转移与回退]({% link zh-CN/core-gateway/failover.md %})。

你也可以在 Models 表格中运行一次按需的 **Health Check**，查看每个部署当前的状态（健康/不健康）。

![Models 表格上的按需 Health Check](/assets/images/routing/routing-health-check.png)

---

## 与网关其余部分的组合

- **自动路由** —— 在负载均衡之前，按用户意图选择模型。→ [自动路由]({% link zh-CN/core-gateway/auto-router.md %})
- **故障转移** —— 某个部署失败时改在另一个部署上重试。→ [故障转移与回退]({% link zh-CN/core-gateway/failover.md %})
- **策略** —— 为模型组附加护栏、提示词、记忆或 Token 节省。→ [策略]({% link zh-CN/core-gateway/policies.md %})
