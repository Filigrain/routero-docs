---
lang: zh-CN
page_id: sdks/python
permalink: /sdks/python.html
title: Python SDK
parent: SDK
nav_order: 1
description: "用于进程内路由和 LLM 调用的 litellm Python 库，无需代理服务器。"
---

# Python SDK

Routero Python SDK 即底层的 `litellm` 库——这是一个用于以统一接口调用任意 LLM 供应商的 Python 包，内置路由、回退和重试逻辑，全部在进程内运行，无需单独的代理服务器。

{: .note }
包名为 `litellm`。这是上游 LiteLLM 项目的一个有意分叉；关于 Routero 特有的功能与行为，请参阅本文档（而非上游 litellm 文档）。

---

## 安装

```bash
pip install litellm
# With proxy server support:
pip install 'litellm[proxy]'
```

---

## 基本用法

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

## 路由与回退（进程内）

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

## 何时使用 SDK，何时使用代理

| | Python SDK（进程内） | Routero 代理（网关） |
|---|---|---|
| **搭建** | pip 安装，无需服务器 | 运行代理容器或使用 Routero Cloud |
| **支持范围** | 仅限 Python 应用 | 任意语言、任意 HTTP 客户端 |
| **多租户** | 手动 | 内置（组织、团队、密钥） |
| **审计日志** | 不包含 | 不可篡改，内置 |
| **高级功能** | 不包含 | Token 节省、护栏、提示词、记忆 |
| **最适合** | 内部工具、脚本、数据管道 | 生产应用、多团队平台 |

对于大多数企业部署，推荐使用代理（Routero Cloud 或私有部署）这条路径。SDK 则适用于无需搭建网关的脚本和内部工具场景。
