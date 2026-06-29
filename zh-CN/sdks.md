---
lang: zh-CN
page_id: sdks
permalink: /sdks.html
title: SDK
nav_order: 9
has_children: true
description: "用于调用 Routero AI 的客户端库与即插即用替代方案。"
---

# SDK

Routero AI 旨在与你的团队已经在使用的 SDK 协同工作。网关提供完全兼容 OpenAI 的接口，因此任何语言的任何 OpenAI SDK 只需更改一处 `base_url` 即可开箱即用。

---

## 本章节页面

- [Python SDK]({% link zh-CN/sdks/python.md %}) — 使用 `litellm` 库进行进程内路由（无需代理）
- [OpenAI 兼容客户端]({% link zh-CN/sdks/openai-compatible.md %}) — 以 Routero 作为后端，使用任意 OpenAI SDK（Python、TypeScript、Go……）
