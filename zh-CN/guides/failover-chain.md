---
lang: zh-CN
page_id: guides/failover-chain
permalink: /guides/failover-chain.html
title: 三供应商故障转移链
parent: 指南
nav_order: 5
description: "配置一条富有弹性的 OpenAI → Anthropic → Bedrock 回退链，实现 99.99%+ 的有效可用性。"
---

# 三供应商故障转移链

配置一条三供应商回退链，使得单个供应商的中断或限流对你的应用透明无感。这是最常见的 Routero 生产环境配置。

---

## 你将构建什么

```
Request → smart/balanced
  → try: openai/gpt-4o           (primary — lowest latency)
  → if 5xx or 429 or timeout:
  → try: anthropic/claude-sonnet-4-6  (fallback 1 — different provider)
  → if 5xx or 429 or timeout:
  → try: bedrock/anthropic.claude-sonnet-4-6  (fallback 2 — different API + region)
  → if all fail: return 503 to caller with retry guidance
```

---

## 第 1 步 — 注册三个部署

```bash
# Primary
curl -X POST https://api.routero.ai/model/new \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{"model_name": "smart/balanced", "litellm_params": {"model": "openai/gpt-4o", "api_key": "sk-openai-..."}}'

# Fallback 1
curl -X POST https://api.routero.ai/model/new \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{"model_name": "smart/balanced", "litellm_params": {"model": "anthropic/claude-sonnet-4-6-20250514", "api_key": "sk-ant-..."}}'

# Fallback 2 — Bedrock uses IAM, not an API key
curl -X POST https://api.routero.ai/model/new \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{
    "model_name": "smart/balanced",
    "litellm_params": {
      "model": "bedrock/anthropic.claude-sonnet-4-6-20250514-v1:0",
      "aws_access_key_id": "...",
      "aws_secret_access_key": "...",
      "aws_region_name": "us-east-1"
    }
  }'
```

---

## 第 2 步 — 配置回退顺序与重试行为

在代理配置 YAML 中或通过仪表盘配置：

```yaml
router_settings:
  routing_strategy: least_busy
  num_retries: 2
  retry_after: 0.08         # 80ms base backoff
  timeout: 30               # per-attempt timeout (s)
  retry_on:
    - 5xx
    - timeout
    - content_filter
  fallbacks:
    - "openai/gpt-4o":
        - "anthropic/claude-sonnet-4-6-20250514"
        - "bedrock/anthropic.claude-sonnet-4-6-20250514-v1:0"
  cooldown_time: 60         # failed provider is cooled down for 60s
```

---

## 第 3 步 — 测试故障转移

临时为 OpenAI 设置一个无效密钥，验证请求会回退到 Anthropic：

```python
import openai

client = openai.OpenAI(
    api_key="YOUR_ROUTERO_KEY",
    base_url="https://api.routero.ai/v1",
)

response = client.chat.completions.create(
    model="smart/balanced",
    messages=[{"role": "user", "content": "Which provider am I on?"}],
)
# Check x-litellm-model-id header — should show the fallback provider
print(response.model)
```

---

## 审计日志中应检查的内容

每个请求的审计日志条目包含：
- `fallback_count` — 成功之前的重试次数
- `model` — 最终为响应提供服务的供应商
- `latency_ms` — 包含重试开销在内的总延迟

某个供应商上较高的 `fallback_count` 表明它应被冷却或降低优先级。
