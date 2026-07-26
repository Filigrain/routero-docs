---
lang: en
page_id: core-gateway/api-keys
title: API Keys
parent: LLM Gateway
nav_order: 2
description: "Create and manage virtual keys — the credentials your applications use to call Routero."
---

# API Keys

A **virtual key** is the credential your application uses to call Routero. Create one per application or environment, scope it to specific models, attach a budget, and revoke it any time. A key never exposes the underlying provider key.

Open **API Keys** in the sidebar.

---

## The API Keys page

The list shows each key's name, the models it can call, its team and owner, spend against budget, rate limits, and when it was created. Click a key to open its detail.

![The API Keys page — your virtual keys, with models, spend, and rate limits](/assets/images/api-keys/api-keys-list.png)

---

## Create a key

Choose **+ Create New Key**:

1. **Owned By** — yourself, or a service account.
2. **Key Name** — a label for the key.
3. **Models** — which models the key can call ("All Proxy Models" by default, or pick specific ones).
4. *(Optional)* **Budget & Rate Limits** — a max budget, soft alert, reset period, and TPM/RPM limits.

Click **Create Key** and **copy the secret** (`sk-…`) from the dialog — it is shown only once.

![Create New Key drawer, then the Save-your-key dialog with the sk-… secret](/assets/images/api-keys/api-keys-create.png)

For the step-by-step walkthrough, see the [Quickstart](/).

---

## Key detail

A key's detail page has six tabs:

- **Overview** — spend against budget, rate limits, usage.
- **Settings** — edit the key's name, models, budget, and rate limits.
- **Router Settings** — the load-balancing strategy and fallback chain for this key. → [Routing]({% link core-gateway/routing.md %}) · [Failover]({% link core-gateway/failover.md %})
- **Policy** — bind a [policy]({% link core-gateway/policies.md %}) so capabilities activate automatically on every request made with this key.
- **Model Aliases** — remap model names for this key.
- **Key Lifecycle** — rotation and expiry.

![Key detail — the six tabs: Overview, Settings, Router Settings, Policy, Model Aliases, Key Lifecycle](/assets/images/api-keys/api-keys-detail.png)

{: .note }
Keys do not expire by default (the "Expires" column shows "Never"). Delete a key to revoke it immediately.

---

## Related

→ [Policies]({% link core-gateway/policies.md %}) — bind capabilities to a key.
→ [Budget Limits]({% link observability/budget-limits.md %}) — how the key's budget is enforced.
→ [Quickstart](/) — create your first key.
