---
lang: zh-CN
page_id: guides/framework-integrations
permalink: /guides/framework-integrations.html
title: 框架集成
parent: 指南
nav_order: 3
description: "将 Routero 与 LangChain、Vercel AI SDK、LlamaIndex、PydanticAI 及其他 LLM 框架配合使用。"
---

# 框架集成

任何接受 OpenAI 兼容端点的框架都可以与 Routero 配合使用。替换 base URL；其余一切——流式、工具调用、结构化输出、嵌入——保持完全一致。

---

## LangChain（Python）

```python
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(
    openai_api_key="YOUR_ROUTERO_KEY",
    openai_api_base="https://api.routero.ai/v1",
    model_name="smart/balanced",
)

response = llm.invoke("Summarise Q3 results in 3 bullet points.")
```

---

## Vercel AI SDK

```typescript
import { createOpenAI } from "@ai-sdk/openai";
import { generateText } from "ai";

const routero = createOpenAI({
  apiKey: "YOUR_ROUTERO_KEY",
  baseURL: "https://api.routero.ai/v1",
});

const { text } = await generateText({
  model: routero("smart/balanced"),
  prompt: "Summarise Q3 results in 3 bullet points.",
});
```

---

## LlamaIndex（Python）

```python
from llama_index.llms.openai import OpenAI

llm = OpenAI(
    api_key="YOUR_ROUTERO_KEY",
    api_base="https://api.routero.ai/v1",
    model="smart/balanced",
)
```

---

## PydanticAI

```python
from pydantic_ai import Agent
from pydantic_ai.models.openai import OpenAIModel

model = OpenAIModel(
    "smart/balanced",
    base_url="https://api.routero.ai/v1",
    api_key="YOUR_ROUTERO_KEY",
)
agent = Agent(model)
result = agent.run_sync("Summarise Q3 results.")
```

---

## Instructor

```python
import instructor
import openai

client = instructor.from_openai(
    openai.OpenAI(
        api_key="YOUR_ROUTERO_KEY",
        base_url="https://api.routero.ai/v1",
    )
)
```

---

## 从框架添加高级功能

支持 `extra_body` / 额外 kwargs 的框架可以将高级功能 ID 透传给 Routero：

```python
# LangChain
llm = ChatOpenAI(
    openai_api_key="YOUR_ROUTERO_KEY",
    openai_api_base="https://api.routero.ai/v1",
    model_name="smart/balanced",
    model_kwargs={"guardrail_id": "pii-redact-prod"},
)
```

对于不支持 `extra_body` 的框架，请改为在工作区层级配置该功能（例如，通过策略将某个护栏应用于来自特定团队密钥的所有请求）。
