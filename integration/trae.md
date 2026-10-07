---
lang: en
page_id: integration/trae
title: Trae
parent: Integration
nav_order: 7
description: "Connect the Trae IDE to Routero via a custom OpenAI-compatible model — base URL, API key, and model ID."
---

# Trae

Connect the **Trae** IDE to Routero so its model calls run through your gateway — attributed, budgeted, and logged — while Trae keeps handling repository access and file edits locally.

Trae connects through a **custom model** entry speaking the OpenAI Chat Completions protocol (`/chat/completions`).

---

## What you must set

| Setting | Value |
|---|---|
| Model ID | a model Routero serves, e.g. `deepseek/deepseek-v4-flash` |
| API Key | a Routero virtual key |
| Base URL | `{{ site.api_base_url }}/v1` |

---

## 1. Create a virtual key

In the dashboard, open **API Keys** and create a virtual key to use as Trae's API key. Scope it to the developer's team, restrict it to the approved models, and optionally attach a budget so individual spend is attributable.

---

## 2. Add a custom model in Trae

1. In Trae's AI chat panel, open the model selector and click **Add Model** (also available under **Settings** → model management).
2. Choose **Custom Model** (OpenAI-compatible).
3. Fill in the fields from the table above — the **Base URL** must end in `/v1`.
4. Save, then select the new model in the chat panel and send a test prompt.

{: .note }
Trae's **SOLO** mode uses a separate custom-endpoint entry (**Settings** → AI services → custom API endpoint) — point it at the same base URL and key.

{: .note }
Trae's agent and builder modes drive tools through function calls, so pick models whose deployments accept tool-call payloads.

---

## Related

→ [Calling the API]({% link integration/api-calling.md %}) for the base URL and auth model.
→ [Cursor]({% link integration/cursor.md %}), [ZCode]({% link integration/zcode.md %}), and [Kimi Code]({% link integration/kimi-code.md %}) for the other coding tools.
