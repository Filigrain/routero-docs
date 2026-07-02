---
lang: zh-CN
page_id: guides/pii-guardrails
permalink: /guides/pii-guardrails.html
title: 面向受监管团队的 PII 护栏
parent: 指南
nav_order: 6
description: "在 Routero 中设置基于 Presidio 的 PII 脱敏，以满足受监管行业的数据处理要求。"
---

# 面向受监管团队的 PII 护栏

本指南面向需要防止个人数据到达模型的团队 —— 医疗健康应用、财务顾问、HR 工具，或任何用户可能将个人信息粘贴到提示词中的应用。

**你将构建什么：** 一道护栏，在提示词到达 LLM 之前自动对其中的 PII（个人身份信息）进行匿名化处理，并在响应到达用户之前对响应执行同样的处理。Microsoft Presidio 在网关本地运行 —— 没有任何数据离开你的基础设施去往外部审核 API。

---

## 前提条件

Presidio 是一个可选依赖。请确保它已安装在你的 Routero 部署中：

```bash
pip install presidio-analyzer presidio-anonymizer
python -m spacy download en_core_web_sm  # 英语 NLP 模型
```

对于私有部署，请在构建代理镜像时包含 `presidio` extras（部署包中已涵盖此内容）。

---

## 第 1 步 — 创建护栏

```bash
curl -X POST https://api.routero.ai/guardrail \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "guardrail_name": "pii-healthcare",
    "engines": [
      {
        "engine_name": "presidio",
        "config": {
          "entities": [
            "PERSON",
            "EMAIL_ADDRESS",
            "PHONE_NUMBER",
            "CREDIT_CARD",
            "US_SSN",
            "US_DRIVER_LICENSE",
            "US_PASSPORT",
            "US_BANK_NUMBER",
            "MEDICAL_LICENSE",
            "IP_ADDRESS",
            "LOCATION",
            "DATE_TIME"
          ],
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

注意记录返回的 `guardrail_id`。

---

## 第 2 步 — 测试护栏

```python
response = client.chat.completions.create(
    model="smart/balanced",
    messages=[{
        "role": "user",
        "content": "Patient John Smith (DOB 01/15/1985, SSN 123-45-6789) needs a follow-up."
    }],
    extra_body={"guardrail_id": "pii-healthcare"},
)
# 模型收到："Patient [PERSON] (DOB [DATE_TIME], SSN [US_SSN]) needs a follow-up."
```

---

## 第 3 步 — 应用到团队中的所有密钥（策略级强制执行）

与其要求每个调用方都传入 `guardrail_id`，不如通过策略将护栏应用到来自特定团队的所有请求：

```yaml
# healthcare-team-policy.yaml
workspace: healthcare
rules:
  - when:
      identity.team_id: healthcare
    guardrail_id: pii-healthcare
    route: smart/balanced
```

通过仪表盘或 `POST /config/update` 上传该策略。此后来自 `healthcare` 团队密钥的每个请求都会自动经过 PII 护栏 —— 调用方无需知道它的存在。

---

## 会记录哪些内容

当护栏触发时，违规信息会出现在你的请求日志和控制台中——包括护栏、引擎、所采取的操作（`anonymize` 或 `block`），以及检测到的实体类型或类别（例如 `PERSON`、`US_SSN`）。

**原始内容永不存储** —— 只记录检测到的实体类型。这是有意为之的设计。
