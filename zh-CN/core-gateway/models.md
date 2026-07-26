---
lang: zh-CN
page_id: core-gateway/models
permalink: /core-gateway/models.html
title: 模型
parent: LLM 网关
nav_order: 1
description: "添加并管理你的组织可调用的模型——模型组、设置与健康状态。"
---

# 模型

**Models** 页是你添加和管理组织可通过 Routero 调用的每一个模型的地方。模型按调用方使用的**公开模型名（Public Model Name）**分组；每个组可挂载一个或多个部署。

在侧边栏打开 **Models**（仅组织管理员）。

---

## Models 页

网格视图把每个模型组显示为一张卡片——公开模型名、背后的**部署数**、**供应商**与成本。工具栏汇总你的组与部署总数。切换到表格视图可看到每个单独的部署（底层模型、供应商与每行成本）。

![Models 页——按公开模型名分组的卡片，显示部署数与供应商](/assets/images/routing/routing-models-grid.png)

点击卡片打开该组，查看该名字背后的每一个部署。

![打开的模型组——一个公开模型名背后的部署、供应商与成本](/assets/images/routing/routing-model-detail.png)

---

## 添加模型

选择 **+ Add Model**。在抽屉中：

1. **Provider** —— 选择一个已分配给你组织的供应商。
2. **Model Name** —— 选择一个模型，或选 “All {Provider} Models” 一次暴露该供应商的全部模型。
3. **Public Model Name** —— 你的应用发给 Routero 的别名（请求里的 `model` 值）。可保留默认或重命名。

点击 **Add Model**（可先用 **Test Connect** 验证供应商可达）。

![Add Model 抽屉——供应商、模型名，以及调用方将使用的公开模型名](/assets/images/quickstart/quickstart-add-model.png)

{: .note }
供应商列表为空？说明平台管理员尚未给你的组织分配供应商密钥——请联系管理员添加。如想改用自己的供应商密钥，参见 [BYOK]({% link zh-CN/core-gateway/byok.md %})。

给多个模型相同的公开模型名即创建一个**模型组**，Routero 会在其上做负载均衡——参见[路由与负载均衡]({% link zh-CN/core-gateway/routing.md %})。

---

## 模型设置与详情

打开一个模型即可管理：

- **Model Settings** —— 按部署的 TPM/RPM 限制、重试、超时与标签。
- **Policy** —— 为该模型绑定一个[策略]({% link zh-CN/core-gateway/policies.md %})（护栏、提示词、记忆、Token 节省）。
- **Test Connection** —— 验证部署是否可达。
- **Delete Model** —— 删除你拥有的模型。

---

## 健康检查

在表格视图中运行一次按需的 **Health Check**，查看每个部署当前的状态（健康/不健康）。

![Models 表格上的按需 Health Check](/assets/images/routing/routing-health-check.png)

---

## 相关内容

→ [路由与负载均衡]({% link zh-CN/core-gateway/routing.md %})——请求如何在模型组的多个部署之间分发。
→ [自动路由]({% link zh-CN/core-gateway/auto-router.md %})——按意图挑选最佳模型的虚拟模型（通过 **Add → Auto Router** 创建）。
→ [BYOK]({% link zh-CN/core-gateway/byok.md %})——为某个供应商使用你自己的密钥。
