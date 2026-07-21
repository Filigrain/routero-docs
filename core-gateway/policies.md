---
lang: en
page_id: core-gateway/policies
title: Policies
parent: Core Gateway
nav_order: 5
description: "Bundle guardrails, prompts, memory, and token-saving into a named policy and bind it to a key or model for automatic activation."
---

# Policies

A **policy** is a named, org-scoped bundle of AI capabilities. Instead of passing `guardrail_id`, `prompt_id`, `memory_id`, and `token_saving_plan_id` on every request, you group them into a policy once and bind that policy to a **key** or a **model**. The gateway then activates the capabilities automatically on every matching request.

{: .note }
A policy is a **governance** primitive, not a routing rule. It does not choose which model serves a request — that is [routing]({% link core-gateway/routing.md %}) and [Auto Router]({% link core-gateway/auto-router.md %}). A policy bundles the capabilities that get applied to a request *once the model is chosen*.

---

## The four capability types

A policy binds one resource of each type. Each type maps to a request field that the [AI Capabilities]({% link advanced-features.md %}) hooks already understand:

| Capability type | Request field | What it activates |
|---|---|---|
| `prompt` | `prompt_id` | A versioned prompt template ([Prompt Management]({% link advanced-features/prompt-management.md %})) |
| `memory` | `memory_id` | A long-term memory session ([Memory-as-a-Service]({% link advanced-features/memory-service.md %})) |
| `token_saving` | `token_saving_plan_id` | A compression + caching plan ([Token Saving]({% link advanced-features/token-saving.md %})) |
| `guardrail` | `guardrail_id` | A content-safety configuration ([Guardrails]({% link advanced-features/guardrails.md %})) |

A policy can bind **at most one resource per type** (so up to four bindings total), and must bind at least one. Most policies bundle several — for example a customer-facing agent policy might combine a system prompt, a PII guardrail, a memory session, and a token-saving plan.

---

## How policies attach

A policy is bound by a single `policy_id` reference in exactly two places:

- **On a virtual key** — every request that authenticates with that key picks up the policy.
- **On a model** — every request to that model group picks up the policy.

There is no team-level or org-level binding, and a key or model carries at most one policy each. A single request can therefore see **two** policies at once — one from its key, one from its model — which the gateway merges (see below).

---

## Creating a policy

### From the dashboard

Open **Policies** in the admin navigation and choose **Create Policy**. The form asks for a name, an optional description, and one capability selector per type (each filtered to your organisation's existing prompts, memory sessions, token-saving plans, and guardrails). Pick at least one capability and save.

![The Policies list page, with the Create Policy button](/assets/images/policies/policies-list.png)

![The Create Policy drawer — name, description, and the four capability selectors](/assets/images/policies/create-policy-drawer.png)

### From the API

```bash
POST /policies
X-Organization-Id: org-abc
Content-Type: application/json

{
  "policy_name": "standard-agent",
  "description": "Customer-facing agent defaults",
  "capabilities": [
    { "capability_type": "prompt",       "capability_id": "<prompt-uuid>" },
    { "capability_type": "memory",       "capability_id": "<memory-session-uuid>" },
    { "capability_type": "guardrail",    "capability_id": "<guardrail-uuid>" },
    { "capability_type": "token_saving", "capability_id": "<token-saving-plan-uuid>" }
  ]
}
```

The response returns the policy's `policy_id`. Policy names are unique within an organisation.

Other endpoints:

| Method | Path | Purpose |
|---|---|---|
| `GET` | `/policies/list` | List policies (paginated, searchable by name) |
| `GET` | `/policies/{policy_id}` | Get one policy |
| `PUT` | `/policies/{policy_id}` | Update name, description, or capabilities |
| `DELETE` | `/policies/{policy_id}` | Delete the policy and clear every binding that referenced it |
| `GET` | `/policies/{policy_id}/resolved-capabilities` | Show active bindings vs `dangling` ones (target deleted / wrong org) |

---

## Binding a policy

### To a key

On the key's detail page, open the **Policy** tab and pick a policy. Or update the key directly — a top-level `policy_id` is accepted on key create and update:

![The Policy tab on a key's detail page](/assets/images/policies/key-policy-tab.png)

```bash
PUT /key/update
{ "key": "sk-xxxx", "policy_id": "<policy_id>" }
```

### To a model

On the model's detail page, expand the **Policy** section and pick a policy. Or patch the model:

![The Policy section on a model's detail page](/assets/images/policies/model-policy-section.png)

```bash
PATCH /model/update
{ "model_id": "<model_id>", "policy_id": "<policy_id>" }
```

A policy can only be bound within its own organisation — the gateway rejects cross-org bindings.

---

## What happens at request time

When a request arrives, the gateway resolves any key policy and model policy, merges them, and injects the capability IDs exactly as if the caller had passed them by hand. The existing per-capability hooks then run in their normal order:

```
PromptHook → TokenSavingPlanHook → GuardrailHook → MemoryHook
```

### Precedence (per capability type)

```
explicit caller field  >  key policy  >  model policy
```

- If the caller already set `prompt_id` (or any other capability field) on the request, that value wins and the policy is ignored **for that type**.
- Otherwise the key policy's binding for that type wins.
- Otherwise the model policy's binding for that type applies.

So a model can provide sensible defaults (a prompt, a guardrail) while an individual key overrides just the parts it cares about — and a developer can always override everything per-request.

{: .note }
Policies **fail open**. If the resolver hits an error, the request still proceeds without the policy's capabilities rather than being blocked.

---

## Dangling references and cleanup

If a capability a policy points to is later **deleted** (or moves to another organisation), that binding becomes **dangling**:

![A policy detail view — active capability cards and a dangling reference flagged with a warning](/assets/images/policies/policy-detail.png)

- `GET /policies/{id}/resolved-capabilities` lists it under `dangling`, and the policy detail page shows a warning.
- At request time, a dangling binding is **silently skipped** — the other bindings in the policy still apply.

Deleting a policy itself is safe: the gateway automatically clears the `policy_id` from every key and model that referenced it, so no stale binding can survive.

---

## Organisation isolation and permissions

- **Org-scoped.** Policies belong to one organisation. List, read, create, edit, and delete are authorised per org via Cerbos (`org:policy:common`); a user only ever sees their own organisation's policies.
- **Capability references stay in-org.** A policy may only reference capabilities owned by the same organisation.
- **Who can manage.** Proxy admins and organisation admins can create, edit, and delete policies. The organisation selector on the Policies page is available to proxy admins.

---

## What policies are not

To set expectations clearly:

- **Not routing rules.** A policy does not select models based on content, region, budget, or schedule. Use [Routing & Load Balancing]({% link core-gateway/routing.md %}) or [Auto Router]({% link core-gateway/auto-router.md %}) for that.
- **Not a substitute for budgets or access control.** Spend caps live in [Budgets & Spend Guards]({% link core-gateway/budgets.md %}); who can call what lives in [Access Control & Audit]({% link core-gateway/sso-rbac-audit.md %}).
- **No inheritance or wildcards.** A policy is a flat list of up to four capability bindings — there are no base policies, no scoping patterns, no add/remove lists.
- **No YAML config file.** Policies are managed through the dashboard or the Management API and stored in the database; changes propagate to all proxy instances in real time.

→ [AI Capabilities]({% link advanced-features.md %}) for the four resources a policy can bind.
→ [Access Control & Audit]({% link core-gateway/sso-rbac-audit.md %}) for the org/admin permission model.
