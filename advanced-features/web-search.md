---
lang: en
page_id: advanced-features/web-search
title: Web Search
parent: AI Capabilities
nav_order: 6
description: "Ground every answer in fresh web results — searched and injected by the gateway, on any model, with zero client changes."
---

# Web Search

Web Search lets a plain chat request search the web before the model answers. The gateway runs the search, injects the results into the conversation as reference material, and the model answers with current information — no function calling, no tool-use loop, no SDK upgrade. It works with **every model**, including the many models that have no built-in search of their own.

A web search tool is the right tool when answers must reflect **what is true now** — news, prices, release notes, documentation that changes. For stable, internal reference material, use a [Knowledge Base]({% link advanced-features/knowledge-base.md %}); the two compose on the same request.

---

## How it works

A web search tool runs in one of three **search modes**:

| Mode | Behaviour |
|---|---|
| **Provider's search when available, otherwise Routero's** *(default)* | Models with built-in provider search use it; every other model falls back to the Routero search engine. The only mode that behaves correctly across a mixed model fleet without you tracking which model supports what. |
| **Provider's search only** | Uses the model vendor's own search; models without it are simply not searched — the request still succeeds normally. |
| **Always Routero's search** | Every request uses the Routero search engine, even on models that have their own. For uniform behaviour, or when you would rather your queries not reach the model vendor. |

**The provider-side path** (first two modes) turns on the vendor's built-in search — the same native capability you would otherwise configure per-provider — driven by the tool's [search depth and domain filters](#search-depth-and-domain-filters). Citations come back in the provider's own format.

**The Routero engine path** works on any model. On each request:

1. The gateway derives a query from the most recent user turns of the conversation.
2. It runs the query against the platform's search engine and takes the top results (up to five).
3. The results are injected into the last user message as a clearly-labelled block of **reference material, not instructions** — each result as a markdown link with its snippet — the same anti-prompt-injection framing the Knowledge Base uses.
4. If the search returns nothing, the request proceeds unchanged.

Web search is **fail-open**: a failing or unavailable search backend never breaks the chat request — it goes through without search context. The web search hook runs last among the AI-capability hooks, after knowledge context is injected:

```
GuardrailHook → PromptHook → TokenSavingPlanHook → MemoryHook → KnowledgeHook → WebSearchHook
```

---

## Search depth and domain filters

Two settings shape provider-side search:

- **Search depth** (`low` / `medium` / `high`) — how much search context the provider gathers per query. More depth means better-grounded answers at a higher per-query cost.
- **Domain filters** — restrict search to **only** the listed domains, or **exclude** the listed domains. Providers differ in how well they honour filters (some accept a single domain only); a filter a provider does not support is dropped silently, never an error.

Which fields you see depends on the search engine you pick: fields are rendered from the engine's own declared capabilities, so an engine that cannot honour a setting does not show it.

---

## Activation

```python
response = client.chat.completions.create(
    model="openai/gpt-5.5",
    messages=[{"role": "user", "content": "What changed in the EU AI Act this month?"}],
    extra_body={"web_search_id": "web-current-events"},
)
```

Pass `web_search_id` top-level or inside `metadata`. The ID is stripped before the request is forwarded. A web search tool can also be [bound through a policy]({% link core-gateway/policies.md %}) so it activates automatically on a key or model — the recommended pattern, since callers then need no changes at all — and an explicit `web_search_id` on the request still wins.

{: .note }
**Whether and how widely to search is an organisation decision, not a caller's.** A `web_search_options` parameter passed in the request body is ignored on every request, bound or not — search costs money per query, so it is governed by the tool configuration here, the same way token-saving plans govern caching.

In the **Playground**, pick a web search tool in the request settings to try live, searched answers.

---

## Creating a web search tool

Open **AI Capabilities → Web Search** and choose **Add Web Search**. The form takes:

- **Name** — unique within your organisation (letters, digits, `-`, `_`).
- **Search mode** — one of the three modes above. The form also shows how many of your deployed models have provider-side search, so you know what the fallback mode would actually do.
- **Engine** — the platform's search backend, selected from the region's engine catalogue (for example general web search, or a Wikipedia-only engine for definitional queries). Engines that need settings show them as additional fields.
- **Search depth** and **domain filters** — when the engine supports them.
- **Description** — optional.
- **Test Engine** — runs a live query against the selected engine and shows how many results came back, before you save.

![The Web Search page — tools with engine, mode, and organisation columns](/assets/images/web-search/web-search-list.png)

![The Add Web Search form — name, search mode, engine picker, depth and domain filters](/assets/images/web-search/create-web-search.png)

Click a tool's name to inspect its effective configuration — mode, engine, and the settings that would apply to provider-side search.

![The web search detail drawer — mode, engine, and effective settings](/assets/images/web-search/web-search-detail.png)

{: .note }
**Deleting a tool stops the searching, nothing else.** Policies that referenced it keep working — a dangling binding is a silent no-op, not an error. The delete dialog says the same thing.

---

## Region availability

On the **China deployment**, the Routero search engine is not offered; web search there runs on provider-side search only (for example the DashScope and Zhipu model families with built-in search). The dashboard shows a warning when no gateway engine is available in your region, and the engine picker reflects what your region actually offers.

---

## Cost and observability

- **Provider-side search** is billed by the provider per query, at the depth you configured; the charge appears in your normal spend views.
- **The Routero engine** carries no per-query fee — its cost shows up as the additional prompt tokens of the injected results block (bounded at five results) and a little added latency.
- Every request that skips searching records why (no query, no results, model without native search, backend error) in the request's metadata, so you can tell "searched and found nothing" apart from "never searched" in the logs.

---

## Organisation isolation and permissions

- **Org-scoped.** Web search tools belong to one organisation and are only visible to it.
- **Who can manage.** Organisation admins create, edit, and delete web search tools. Regular members can view them.

---

## Combining with the rest of the gateway

- **Policies** — bind a web search tool into a [policy]({% link core-gateway/policies.md %}) to activate it automatically on a key or model; callers need zero changes.
- **Knowledge Base / memory / prompts / guardrails / token saving** — the other [AI Capabilities]({% link advanced-features.md %}) apply to the same request in their normal order; guardrails inspect the caller's raw input before any search context is added, and knowledge context is injected before the search query is derived.
- **Playground** — pick a web search tool in the request settings to test searched answers live.

→ [Policies]({% link core-gateway/policies.md %}) for binding web search to keys and models.
