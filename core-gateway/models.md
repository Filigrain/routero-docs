---
lang: en
page_id: core-gateway/models
title: Models
parent: LLM Gateway
nav_order: 1
description: "Add and manage the models your organisation can call — model groups, settings, and health."
---

# Models

The **Models** page is where you add and manage every model your organisation can call through Routero. Models are grouped by the **Public Model Name** callers use; each group can sit over one or more deployments.

Open **Models** in the sidebar (organisation admins only).

---

## The Models page

The grid view shows each model group as a card — its Public Model Name, the number of **Deployments** behind it, the **providers**, and the cost. The toolbar totals your groups and deployments. Switch to the table view to see individual deployments (the underlying model, provider, and cost per row).

![The Models page — model groups as cards, with deployment counts and providers](/assets/images/routing/routing-models-grid.png)

Click a card to open the group and see every deployment behind the name.

![A model group opened — the deployments, providers, and costs behind one Public Model Name](/assets/images/routing/routing-model-detail.png)

---

## Add a model

Choose **+ Add Model**. In the drawer:

1. **Provider** — pick a provider assigned to your organisation.
2. **Model Name** — choose a model, or "All {Provider} Models" to expose them all.
3. **Public Model Name** — the alias your application sends to Routero (the `model` value in requests). Keep the default or rename it.

Click **Add Model** (or **Test Connect** first to check the provider is reachable).

![Add Model drawer — provider, model name, and the public model name callers will use](/assets/images/quickstart/quickstart-add-model.png)

{: .note }
No providers listed? Your platform admin hasn't assigned a provider key to your organisation yet — ask them to add one. To bring your own provider key instead, see [BYOK]({% link core-gateway/byok.md %}).

Giving several models the same Public Model Name creates a **model group** that Routero load-balances across — see [Routing & Load Balancing]({% link core-gateway/routing.md %}).

---

## Model settings and detail

Open a model to manage it:

- **Model Settings** — per-deployment TPM/RPM limits, retries, timeout, and tags.
- **Policy** — bind a [policy]({% link core-gateway/policies.md %}) (guardrails, prompts, memory, token saving) to the model.
- **Test Connection** — verify the deployment is reachable.
- **Delete Model** — remove a model you own.

---

## Health check

From the table view, run an on-demand **Health Check** to see each deployment's current status (healthy or unhealthy).

![The on-demand Health Check on the Models table](/assets/images/routing/routing-health-check.png)

---

## Related

→ [Routing & Load Balancing]({% link core-gateway/routing.md %}) — how requests spread across a model group's deployments.
→ [Auto Router]({% link core-gateway/auto-router.md %}) — a virtual model that picks the best model by intent (created from **Add → Auto Router**).
→ [BYOK]({% link core-gateway/byok.md %}) — use your own provider key for a provider.
