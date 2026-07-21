---
lang: zh-CN
page_id: quickstart
permalink: /quickstart.html
title: 快速开始
nav_order: 2
description: "在 5 分钟内通过 Routero AI 发出你的第一个请求。"
---

# 快速开始

在 5 分钟内让你的第一个请求通过 Routero AI 路由。如果你已经在使用 OpenAI SDK，这只是一行改动。

{: .enterprise }
> **前提条件：** 一个 Routero 虚拟密钥。工作区采用邀请制——请联系你的工作区管理员，从 [platform.routero.ai](https://platform.routero.ai) 邀请你并发放密钥。

---

## 两种集成方式

| 方式 | 最适合 | 改动内容 |
|---|---|---|
| **OpenAI SDK（直接替换）** | 现有的 OpenAI 代码库 | 仅 `base_url` |
| **直接调用 REST API** | 任意语言，无 SDK 依赖 | — |

---

## 方式 1 —— OpenAI SDK 直接替换（推荐）

将 `base_url` 改为 `https://api.routero.ai/v1`。其余一切——消息、工具、流式、视觉、结构化输出——保持完全相同。

### Python

```python
import openai

client = openai.OpenAI(
    api_key="YOUR_ROUTERO_KEY",          # 你的 Routero 虚拟密钥
    base_url="https://api.routero.ai/v1",
)

response = client.chat.completions.create(
    model="smart/balanced",              # smart 别名，或 "openai/gpt-4o"、"anthropic/claude-sonnet-4-6" 等
    messages=[{"role": "user", "content": "Hello!"}],
)
print(response.choices[0].message.content)
```

### TypeScript / Node

```typescript
import OpenAI from "openai";

const client = new OpenAI({
  apiKey: "YOUR_ROUTERO_KEY",
  baseURL: "https://api.routero.ai/v1",
});

const response = await client.chat.completions.create({
  model: "smart/balanced",
  messages: [{ role: "user", content: "Hello!" }],
});
console.log(response.choices[0].message.content);
```

### curl

```bash
curl https://api.routero.ai/v1/chat/completions \
  -H "Authorization: Bearer YOUR_ROUTERO_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "smart/balanced",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

---

## 方式 2 —— 直接调用 REST API

网关提供标准的 OpenAI 兼容 REST 接口。可使用任意 HTTP 客户端。

**基础 URL：** `https://api.routero.ai/v1`

**认证：** `Authorization: Bearer YOUR_ROUTERO_KEY`

**支持的端点：** `/chat/completions` · `/completions` · `/embeddings` · `/images/generations` · `/audio/speech` · `/audio/transcriptions` · `/rerank` · `/batches` · `/models` 等。完整列表见 [统一 API]({% link zh-CN/core-gateway/unified-api.md %})。

---

## 模型字符串

Routero 会将任意模型字符串传递给相应的供应商。你可以使用：

| 格式 | 示例 | 作用 |
|---|---|---|
| Smart 别名 | `smart/balanced` | 路由到最适合该任务的可用模型 |
| 供应商限定 | `openai/gpt-4o` | 锁定到特定供应商 |
| 裸模型名 | `gpt-4o` | Routero 自动推断供应商 |
| 供应商变体 | `bedrock/anthropic.claude-sonnet-4-6` | 完全限定的 AWS Bedrock 模型 |

{: .note }
Smart 别名（`smart/balanced`、`smart/fast`、`smart/cheap`）是由你的工作区管理员配置的模型组；每个都会自动应用其回退链。参见[路由与负载均衡]({% link zh-CN/core-gateway/routing.md %})。

---

## 刚刚发生了什么

你发送的每个请求都经过了 Routero 的四步决策流水线：

1. **认证与访问** —— Routero 校验你的虚拟密钥，检查该密钥是否有权调用所请求的模型，并确认你的工作区预算尚有余量。
2. **供应商选择** —— Router 根据当前健康状况、延迟和成本为符合条件的部署打分，然后选出一个。`smart/balanced` 解析为你配置的主供应商。
3. **计费** —— 计算 token 数量和成本，并原子性地从你工作区的预算中扣除，用量被记录。
4. **响应** —— 供应商的响应通过网关零缓冲地流式返回。

该请求现在已出现在你的[平台仪表板](https://platform.routero.ai)的用量与支出视图中。

---

## 启用 AI 能力

在同一个请求上传入任意功能 ID 的组合，即可解锁 Routero 的生产级 AI 层。代理会从你的工作区解析每项配置，将其作为钩子应用，并在向上游发起调用之前剥离 ID——你的应用代码无需改动。

```python
response = client.chat.completions.create(
    model="smart/balanced",
    messages=[{"role": "user", "content": "Summarise last quarter's results."}],
    extra_body={
        "guardrail_id":        "my-pii-guardrail",      # 在模型看到之前对 PII 脱敏
        "token_saving_plan_id": "my-cache-plan",         # 压缩并缓存响应
        "prompt_id":           "my-analyst-system-prompt", # 注入有版本的系统提示词
        "memory_id":           "user-alice-session",    # 检索 Alice 的长期上下文
    },
)
```

→ [AI 能力]({% link zh-CN/advanced-features.md %})

---

## 接下来做什么

- **把能力打包为一个策略** → [策略]({% link zh-CN/core-gateway/policies.md %})
- **为你的团队添加支出预算** → [预算与支出护栏]({% link zh-CN/core-gateway/budgets.md %})
- **选择你的部署模型** → [部署选项]({% link zh-CN/deployment.md %})
- **为 PII 启用护栏** → [护栏]({% link zh-CN/advanced-features/guardrails.md %})
