---
lang: zh-CN
page_id: advanced-features/guardrails
permalink: /advanced-features/guardrails.html
title: 护栏
parent: AI 能力
nav_order: 2
description: "内容过滤、PII 脱敏、密钥检测与工具权限强制执行——集中管理、按组织强制执行。"
---

# 护栏

护栏是以组织为范围的具名配置，可对请求和响应应用一个或多个安全引擎。它们在网关内部运行——在 LLM 看到提示词之前以及在它响应之后——无需更改一行应用代码。

{: .enterprise }
> 护栏回答了法务部门的问题：*“模型看到了什么？”* 内容过滤违规、PII 脱敏和密钥检测都会连同其类别和消息一起写入你的审计日志——而非被拦截的原始内容。

---

## 激活

```python
response = client.chat.completions.create(
    model="smart/balanced",
    messages=[{"role": "user", "content": user_input}],
    extra_body={"guardrail_id": "my-pii-guardrail"},
)
```

当某个被配置为 `block` 的违规发生时，网关会返回 HTTP 400 以及一个结构化错误：

```json
{
  "error": {
    "message": "Request blocked by guardrail: PII detected (EMAIL_ADDRESS)",
    "type": "guardrail_violation",
    "code": "guardrail_blocked"
  }
}
```

---

## 内置引擎

四个引擎可在单个护栏中组合。它们顺序运行；每个引擎接收前一个引擎（可能已被修改）的输出。

### 内容过滤（Content Filter）
拦截或标记匹配关键字或正则表达式模式的请求和响应。

| 配置项 | 说明 |
|---|---|
| `banned_keywords` | 不区分大小写的子串匹配列表 |
| `banned_patterns` | 带 `IGNORECASE` 的正则表达式列表 |
| `event_hooks` | `pre_call`、`post_call` 或两者 |

无额外依赖。零延迟。

---

### 工具权限（Tool Permission）
在调用 LLM 之前，对函数/工具名称强制执行允许列表（allow-list）或拒绝列表（deny-list）。

| 配置项 | 说明 |
|---|---|
| `allowed_tools` | 白名单——仅允许这些工具名称 |
| `blocked_tools` | 黑名单——从请求中移除这些工具名称 |
| `on_violation` | `block`（拒绝请求）或 `remove`（静默剥离该工具） |

仅在调用前运行（工具位于请求中，而非响应中）。

---

### PII 检测（Presidio）
使用 [Microsoft Presidio](https://microsoft.github.io/presidio/) 检测并匿名化提示词和响应中的个人身份信息（PII）。

| 配置项 | 说明 |
|---|---|
| `entities` | 实体类型列表：`PERSON`、`EMAIL_ADDRESS`、`PHONE_NUMBER`、`CREDIT_CARD`、`US_SSN`、`IBAN_CODE`、`IP_ADDRESS`、`LOCATION`…… |
| `action` | `anonymize`（替换为 `<ENTITY_TYPE>`）或 `block`（发现 PII 时拒绝） |
| `score_threshold` | Presidio 最低置信度分数（默认 0.5） |
| `event_hooks` | `pre_call`、`post_call` 或两者 |

**依赖项：** `presidio-analyzer`、`presidio-anonymizer`

Presidio 在网关内本地运行——PII 绝不会离开你的基础设施去往外部审核厂商。

---

### 密钥检测（detect-secrets）
使用 [Yelp detect-secrets](https://github.com/Yelp/detect-secrets) 检测提示词中泄露的凭据和密钥。

| 配置项 | 说明 |
|---|---|
| `action` | `redact`（替换为 `[REDACTED]`）或 `block`（拒绝） |
| `detectors` | 约 21 个内置检测器的子集：`aws`、`github`、`slack`、`stripe`、`jwt`、`private_key`、`azure`、`twilio`、`base64_high_entropy`…… |

仅在调用前运行（密钥位于提示词中，而非响应中）。

**依赖项：** `detect-secrets`

---

## 创建护栏

```bash
curl -X POST https://api.routero.ai/guardrail \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "guardrail_name": "pii-redact-prod",
    "engines": [
      {
        "engine_name": "presidio",
        "config": {
          "entities": ["PERSON", "EMAIL_ADDRESS", "PHONE_NUMBER", "CREDIT_CARD", "US_SSN"],
          "action": "anonymize",
          "score_threshold": 0.5
        },
        "event_hooks": ["pre_call", "post_call"]
      },
      {
        "engine_name": "detect_secret",
        "config": {
          "action": "redact",
          "detectors": ["aws", "github", "stripe", "jwt"]
        },
        "event_hooks": ["pre_call"]
      }
    ]
  }'
```

---

## 管理 API

| 端点 | 说明 |
|---|---|
| `GET /guardrail/engines` | 列出可用的引擎类型 |
| `POST /guardrail` | 创建护栏 |
| `GET /guardrail/list` | 列出工作区中的护栏（分页） |
| `GET /guardrail/{id}` | 获取护栏详情 |
| `PATCH /guardrail/{id}` | 更新护栏 |
| `DELETE /guardrail/{id}` | 删除护栏 |
