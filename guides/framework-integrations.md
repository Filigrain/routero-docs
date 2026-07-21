---
lang: en
page_id: guides/framework-integrations
title: Framework Integrations
parent: Guides
nav_order: 3
description: "Use Routero with LangChain, Vercel AI SDK, LlamaIndex, PydanticAI, and other LLM frameworks."
---

# Framework Integrations

Any framework that accepts an OpenAI-compatible endpoint works with Routero. Replace the base URL; everything else — streaming, tool calls, structured outputs, embeddings — stays identical.

---

## LangChain (Python)

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

## LlamaIndex (Python)

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

## Adding AI Capabilities from frameworks

Frameworks that support `extra_body` / extra kwargs can pass AI Capability IDs through to Routero:

```python
# LangChain
llm = ChatOpenAI(
    openai_api_key="YOUR_ROUTERO_KEY",
    openai_api_base="https://api.routero.ai/v1",
    model_name="smart/balanced",
    model_kwargs={"guardrail_id": "pii-redact-prod"},
)
```

For frameworks that don't support `extra_body`, configure the feature at the workspace level (e.g., apply a guardrail to all requests from a specific team key via policy) instead.
