---
lang: en
page_id: index
title: Quickstart
nav_order: 1
description: "Get running in three steps: add a model, create a key, and make your first request."
---

# Quickstart

Get your first request through Routero in three steps: **add a model**, **create a key**, then **use that key** from your application. If you already use the OpenAI SDK, the last step is a one-line `base_url` change.

{: .note }
**Prerequisites:** an organisation administrator account, and a provider already assigned to your organisation. Routero is invitation-only, and a model references a provider key your platform admin has assigned — ask them if the provider you need isn't listed.

---

## Step 1 — Add a model

Open **Models** in the sidebar and choose **+ Add Model**.

![The Models page, with the + Add Model button](/assets/images/quickstart/quickstart-models-list.png)

In the **Add Model** drawer:

1. **Provider** — pick a provider assigned to your organisation.
2. **Model Name** — choose a model, or "All {Provider} Models" to expose them all.
3. **Public Model Name** — the alias your application sends to Routero. This is the `model` value you'll use in Step 3. Keep the default or rename it.

Leave the rest as defaults and click **Add Model** (use **Test Connect** first to verify the provider is reachable).

![Add Model drawer — provider, model name, and the public model name you will call](/assets/images/quickstart/quickstart-add-model.png)

{: .note }
No providers listed? Your platform admin hasn't assigned a provider key to your organisation yet — ask them to add one.

---

## Step 2 — Create a key

Open **API Keys** and choose **+ Create New Key**.

![The API Keys page, with the + Create New Key button](/assets/images/quickstart/quickstart-api-keys-list.png)

In the **Create New Key** drawer:

1. **Key Name** — a label for the key.
2. **Models** — which models the key can call. "All Proxy Models" by default, or pick specific ones.
3. *(Optional)* **Budget & Rate Limits** — cap spend or set TPM/RPM limits.

Click **Create Key**. A **Save your Key** dialog shows your new virtual key (`sk-…`) — **copy it now; it is shown only once.**

![The Create New Key drawer, and the Save-your-Key dialog with the sk-… virtual key](/assets/images/quickstart/quickstart-create-key.png)

![The Save your Key dialog — copy the virtual key, shown only once](/assets/images/quickstart/quickstart-key-created.png)

---

## Step 3 — Use the key

Point any OpenAI SDK — or a plain HTTP client — at Routero with your key, and request the **Public Model Name** you set in Step 1.

```python
from openai import OpenAI

client = OpenAI(
    api_key="sk-...YOUR_KEY...",          # the virtual key from Step 2
    base_url="https://api.routero.ai/v1",
)

response = client.chat.completions.create(
    model="openai/gpt-5.5",               # the Public Model Name from Step 1
    messages=[{"role": "user", "content": "Hello!"}],
)
print(response.choices[0].message.content)
```

```bash
curl https://api.routero.ai/v1/chat/completions \
  -H "Authorization: Bearer sk-...YOUR_KEY..." \
  -H "Content-Type: application/json" \
  -d '{
    "model": "openai/gpt-5.5",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

The request shows up in your [platform dashboard](https://platform.routero.ai) usage and spend views. See [Inference APIs]({% link inference-apis.md %}) for the other endpoints (embeddings, images, models).

---

## Next

- **Route your coding assistants** through Routero — [Cursor]({% link integration/cursor.md %}), [Claude Code]({% link integration/claude-code.md %}), [Codex]({% link integration/codex.md %}).
- **Add AI capabilities** (guardrails, prompts, memory, caching) — [AI Capabilities]({% link advanced-features.md %}).
- **Set a spend budget** — [Budget Limits]({% link observability/budget-limits.md %}).
