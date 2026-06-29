---
lang: zh-CN
page_id: guides/enterprise-quickstart
permalink: /guides/enterprise-quickstart.html
title: 企业快速开始
parent: 指南
nav_order: 1
description: "预置工作区、配置路由策略、设置团队预算，并路由你的第一个生产环境请求。"
---

# 企业快速开始

本指南带领平台工程师完成最小可用的生产环境搭建：一个工作区、一条策略、一个团队预算，以及一个带护栏的已路由请求。端到端在 30 分钟内完成。

---

## 步骤 1 — 创建工作区

在 [platform.routero.ai](https://platform.routero.ai) 注册。如果你使用的是单租户云或私有部署，请改用你的实例 URL。

你的第一个工作区会自动创建。请在 **Settings → API Keys** 中记下你的管理员密钥（`sk-admin-...`）。

---

## 步骤 2 — 添加供应商凭据

在控制台的 **Models → Provider Keys** 下，添加你要路由到的供应商的 API 密钥。密钥在数据库中加密存储——它们绝不会出现在日志中。

先添加两个供应商以实现故障转移：

```bash
# 添加 OpenAI
curl -X POST https://api.routero.ai/model/new \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{
    "model_name": "smart/balanced",
    "litellm_params": {"model": "openai/gpt-4o", "api_key": "sk-openai-..."}
  }'

# 添加 Anthropic 作为回退
curl -X POST https://api.routero.ai/model/new \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{
    "model_name": "smart/balanced",
    "litellm_params": {"model": "anthropic/claude-sonnet-4-6-20250514", "api_key": "sk-ant-..."}
  }'
```

---

## 步骤 3 — 创建带预算的团队

```bash
curl -X POST https://api.routero.ai/team/new \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{
    "team_alias": "engineering",
    "max_budget": 500,
    "budget_duration": "1mo",
    "soft_budget": 400
  }'
```

---

## 步骤 4 — 生成限定范围的团队密钥

```bash
curl -X POST https://api.routero.ai/key/generate \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{
    "team_id": "engineering",
    "models": ["smart/balanced"],
    "duration": "30d",
    "key_alias": "engineering-prod"
  }'
# 返回：{ "key": "sk-..." }
```

---

## 步骤 5 — 路由你的第一个请求

```python
import openai

client = openai.OpenAI(
    api_key="sk-...",  # 步骤 4 中的团队密钥
    base_url="https://api.routero.ai/v1",
)

response = client.chat.completions.create(
    model="smart/balanced",
    messages=[{"role": "user", "content": "Hello, Routero!"}],
)
print(response.choices[0].message.content)
```

在控制台的 **Audit Log** 中查看该请求。你应当看到：模型、供应商、token 计数、成本以及团队归属。

---

## 步骤 6 — 添加 PII 护栏

```bash
curl -X POST https://api.routero.ai/guardrail \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{
    "guardrail_name": "pii-redact",
    "engines": [{
      "engine_name": "presidio",
      "config": {
        "entities": ["PERSON", "EMAIL_ADDRESS", "PHONE_NUMBER"],
        "action": "anonymize"
      },
      "event_hooks": ["pre_call", "post_call"]
    }]
  }'
```

在可能包含个人数据的请求上传入它：

```python
response = client.chat.completions.create(
    model="smart/balanced",
    messages=[{"role": "user", "content": "What do we know about Alice Smith at alice@example.com?"}],
    extra_body={"guardrail_id": "pii-redact"},
)
```

模型收到的是：`"What do we know about [PERSON] at [EMAIL_ADDRESS]?"`

---

## 后续步骤

- 设置 SSO → [SSO、RBAC 与审计]({% link zh-CN/core-gateway/sso-rbac-audit.md %})
- 添加更多团队和策略 → [多租户]({% link zh-CN/core-gateway/multi-tenancy.md %})
- 启用 Token 节省 → [Token 节省]({% link zh-CN/advanced-features/token-saving.md %})
- 添加更多供应商以实现故障转移 → [故障转移与回退]({% link zh-CN/core-gateway/failover.md %})
