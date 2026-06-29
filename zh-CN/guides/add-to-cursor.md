---
lang: zh-CN
page_id: guides/add-to-cursor
permalink: /guides/add-to-cursor.html
title: 接入 Cursor / Claude Code
parent: 指南
nav_order: 2
description: "通过 Routero 路由 Cursor 和 Claude Code，以实现治理、成本追踪与策略执行。"
---

# 接入 Cursor / Claude Code

通过 Routero 路由 AI 编码助手，使开发者工具的使用纳入与你的生产应用相同的治理、成本追踪与策略执行体系。

---

## 为什么要通过 Routero 路由你的编码助手？

- **成本可见性** — 谁在使用哪些模型、成本几何、跨越哪些团队
- **策略执行** — 阻止未获批用于源代码的模型或供应商
- **审计轨迹** — 所有编码助手调用的不可篡改日志（对知识产权和数据处理策略很有用）
- **预算限额** — 为单个开发者或团队在 AI 工具上的支出设置上限
- **供应商回退** — 即使某个供应商被限流，编码助手仍保持可用

---

## Cursor

1. 打开 **Cursor Settings** → **Models** → **OpenAI API Key** 部分。
2. 将你的 Routero 虚拟密钥粘贴为 API 密钥。
3. 将 **Base URL** 设置为 `https://api.routero.ai/v1`。
4. 选择你的模型——任何 Routero 支持的模型字符串均可使用，包括 `smart/balanced`。

从此刻起，Cursor 将通过 Routero 路由其所有的 LLM 调用。

---

## Claude Code（Anthropic CLI）

在调用 `claude` 之前设置环境变量：

```bash
export ANTHROPIC_API_KEY="YOUR_ROUTERO_KEY"
export ANTHROPIC_BASE_URL="https://api.routero.ai/v1"
claude
```

或者添加到你的 shell 配置文件（`~/.zshrc`、`~/.bashrc`）：

```bash
export ANTHROPIC_API_KEY="YOUR_ROUTERO_KEY"
export ANTHROPIC_BASE_URL="https://api.routero.ai/v1"
```

{: .note }
Claude Code 仍然使用 `ANTHROPIC_API_KEY` 这一变量名，但只要 `ANTHROPIC_BASE_URL` 指向 Routero，所有调用都会经由网关路由。你提供的密钥应当是你的 Routero 虚拟密钥，而不是直接的 Anthropic 密钥。

---

## 生成按开发者划分的密钥

为每位开发者分配各自限定范围的虚拟密钥，以便单独归属支出：

```bash
curl -X POST https://api.routero.ai/key/generate \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{
    "team_id": "engineering",
    "models": ["smart/balanced", "anthropic/claude-sonnet-4-6-20250514"],
    "max_budget": 50,
    "budget_duration": "1mo",
    "key_alias": "dev-alice-cursor",
    "metadata": {"developer": "alice@company.com"}
  }'
```

按开发者划分的支出会与生产环境 API 支出一同显示在团队控制台中。
