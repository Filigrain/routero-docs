---
lang: zh-CN
page_id: core-gateway/failover
permalink: /core-gateway/failover.html
title: 故障转移与回退
parent: LLM 网关
nav_order: 6
description: "在密钥上定义一条有序的回退链，让请求在主模型失败时转到下一个模型。"
---

# 故障转移与回退

回退链告诉 Routero 在某个模型失败时接下来试哪个。如果主模型在重试后仍然出错，Routero 会转到链中的下一个模型——这样即便某家供应商出了问题，请求仍然能成功。

回退是**按虚拟密钥**配置的，与负载均衡在同一个界面。

---

## 设置回退链

打开某个密钥的详情页，进入 **Router Settings** 标签，选择 **Fallbacks** 子标签。

![密钥详情 → Router Settings → Fallbacks：一个主模型与一条有序的回退链](/assets/images/failover/failover-key-fallbacks.png)

每一组是一个**主模型（Primary Model）**加上它自己有序的**回退链（Fallback Chain）**：

1. **Primary Model** —— 请求通常使用的模型。
2. **Fallback Chain** —— 主模型失败时按顺序尝试的模型。最多 **5** 个，按 1、2、3……编号，并依此顺序尝试。

{: .note }
回退顺序就是你在下拉里选择模型的顺序。要改顺序，需先移除某模型再重新添加——目前不支持拖拽排序。

你最多可以定义 **5 组**（点击标签栏的 **+** 可再添加一组“主模型 → 回退链”）。大多数密钥只需要一组。

---

## 何时触发回退

当请求失败时，Routero 会先**在模型组内重试**——使用 [Loadbalancing]({% link zh-CN/core-gateway/routing.md %}) 子标签里的 **Number of Retries**、**Timeout** 和 **Retry After**。只有当这些重试都耗尽后，才会转到回退链中的**下一个模型**，该模型再按相同策略重试。

回退在请求级别的失败时触发，例如**超时、服务器错误（5xx）、限流（429）以及内容过滤错误**。链中的每个模型都有一次机会，之后请求才会真正失败。

---

## 保存

Loadbalancing 与 Fallbacks 是一起保存的——使用 Router Settings 标签底部的同一个 **Save Router Settings** 按钮即可同时应用两者。

---

## 逐请求可见性

对于发生过故障转移的请求，你可以查看：

- 尝试过哪些供应商，最终由哪一个提供了服务。
- 包含重试开销的总延迟。

逐请求明细参见[日志]({% link zh-CN/observability/logs.md %})，并查看 `x-routero-attempted-retries` 与 `x-routero-attempted-fallbacks` 响应头。

---

## 与网关其余部分的组合

- **负载均衡** —— Routero 如何在模型组内部挑选部署。→ [路由与负载均衡]({% link zh-CN/core-gateway/routing.md %})
- **自动路由** —— 在负载均衡或回退之前，按意图选择模型。→ [自动路由]({% link zh-CN/core-gateway/auto-router.md %})
- **策略** —— 附加护栏、提示词、记忆或 Token 节省。→ [策略]({% link zh-CN/core-gateway/policies.md %})
