---
title: Python SDK
parent: SDKs
nav_order: 1
description: "The litellm Python library for in-process routing and LLM calls without a proxy server."
---

# Python SDK

The Routero Python SDK is the underlying `litellm` library — a Python package for calling any LLM provider with a unified interface, built-in routing, fallback, and retry logic, all running in-process without a separate proxy server.

{: .note }
The package name is `litellm`. This is an intentional fork of the upstream LiteLLM project; for Routero-specific features and behaviour, refer to this documentation (not the upstream litellm docs).

---

## Installation

```bash
pip install litellm
# With proxy server support:
pip install 'litellm[proxy]'
```

---

## Basic usage

```python
from litellm import completion

# Set provider keys as environment variables
import os
os.environ["OPENAI_API_KEY"] = "..."
os.environ["ANTHROPIC_API_KEY"] = "..."

response = completion(
    model="openai/gpt-4o",
    messages=[{"role": "user", "content": "Hello!"}],
)
print(response.choices[0].message.content)
```

---

## Routing and fallback (in-process)

```python
from litellm import Router

router = Router(
    model_list=[
        {
            "model_name": "smart/balanced",
            "litellm_params": {"model": "openai/gpt-4o", "api_key": os.environ["OPENAI_API_KEY"]},
        },
        {
            "model_name": "smart/balanced",
            "litellm_params": {"model": "anthropic/claude-sonnet-4-6-20250514", "api_key": os.environ["ANTHROPIC_API_KEY"]},
        },
    ],
    routing_strategy="least_busy",
    fallbacks=[{"openai/gpt-4o": ["anthropic/claude-sonnet-4-6-20250514"]}],
    num_retries=3,
)

response = router.completion(model="smart/balanced", messages=[{"role": "user", "content": "Hello!"}])
```

---

## When to use the SDK vs. the proxy

| | Python SDK (in-process) | Routero Proxy (gateway) |
|---|---|---|
| **Setup** | pip install, no server | Run proxy container or use Routero Cloud |
| **Supports** | Python applications only | Any language, any HTTP client |
| **Multi-tenant** | Manual | Built-in (orgs, teams, keys) |
| **Audit log** | Not included | Immutable, built-in |
| **Advanced Features** | Not included | Token Saving, Guardrails, Prompts, Memory |
| **Best for** | Internal tooling, scripts, data pipelines | Production applications, multi-team platforms |

For most enterprise deployments, the proxy (Routero Cloud or self-hosted) is the recommended path. The SDK is useful for scripts and internal tooling where standing up a gateway is unnecessary.
