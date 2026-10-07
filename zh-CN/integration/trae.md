---
lang: zh-CN
page_id: integration/trae
permalink: /integration/trae.html
title: Trae
parent: 接入
nav_order: 7
description: "通过自定义 OpenAI 兼容模型将 Trae IDE 接入 Routero——base URL、API 密钥与模型 ID。"
---

# Trae

将 **Trae** IDE 接入 Routero，让它的模型调用经由你的网关——可归属、可预算、可记录——同时 Trae 在本地继续负责仓库访问与文件修改。

Trae 通过一个使用 OpenAI Chat Completions 协议（`/chat/completions`）的**自定义模型**条目接入。

---

## 必须设置的内容

| 设置项 | 值 |
|---|---|
| 模型 ID | Routero 提供的模型，例如 `deepseek/deepseek-v4-flash` |
| API Key | 一个 Routero 虚拟密钥 |
| Base URL | `{{ site.api_base_url }}/v1` |

---

## 1. 创建虚拟密钥

在仪表板中打开 **API Keys**，创建一个虚拟密钥作为 Trae 的 API 密钥。将其限定到开发者所属团队、限制为已获批的模型，并可选地附加预算，以便单独归属支出。

---

## 2. 在 Trae 中添加自定义模型

1. 在 Trae 的 AI 聊天面板中打开模型选择器，点击 **Add Model**（也可在 **Settings** 的模型管理中找到）。
2. 选择 **Custom Model**（OpenAI 兼容）。
3. 按上表填写各字段——**Base URL** 必须以 `/v1` 结尾。
4. 保存，然后在聊天面板中选择新模型并发送一个测试提示词。

{: .note }
Trae 的 **SOLO** 模式使用单独的自定义端点入口（**Settings** → AI 服务 → 自定义 API endpoint）——指向同样的 base URL 与密钥即可。

{: .note }
Trae 的 agent 与 builder 模式通过函数调用驱动工具，因此请选择部署侧接受工具调用载荷的模型。

---

## 相关内容

→ 关于 base URL 与鉴权模型，参见 [API 调用]({% link zh-CN/integration/api-calling.md %})。
→ 其他编码工具，参见 [Cursor]({% link zh-CN/integration/cursor.md %})、[ZCode]({% link zh-CN/integration/zcode.md %})与 [Kimi Code]({% link zh-CN/integration/kimi-code.md %})。
