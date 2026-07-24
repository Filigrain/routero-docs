---
lang: en
page_id: observability/logs
title: Logs
parent: Observability
nav_order: 1
description: "Every request through Routero — status, tokens, cost, latency, and optionally the prompt and response."
---

# Logs

The **Logs** page records every request that passes through the gateway. For each call you can see its status, model, token usage, cost, and latency — and, when prompt logging is enabled, the request and response themselves.

Open **Logs** in the sidebar. Organisation administrators see every request in the organisation; a regular member sees only their own.

---

## Request logs

The list shows one row per request, with **Live Tail** on by default (it refreshes every 15 seconds). Columns cover the time, success/failure status, request and session IDs, model, token count, cost, duration, and the team, internal user, and end user behind the call.

![The Logs request list — live-tail table with time, status, model, tokens, cost, and a filter toolbar](/assets/images/logs/logs-request-list.png)

Filter the list by **time range** (last 15 minutes to last 7 days, or a custom range), **team**, **status** (success or failure), **model**, **key alias**, **end user**, **error code**, or **request ID**. Toggle **Live Tail** to stream new entries as they arrive.

![Logs filters — team, status, model, key, end user, error code, and a custom date range](/assets/images/logs/logs-filters.png)

The page also has **Deleted Keys** and **Deleted Teams** tabs for auditing removals.

---

## Request detail

Click a row to open the request detail drawer. It shows the request's model, provider, call type, and API base; a metrics card with prompt, completion, and total tokens, cost, duration, and cache stats; any tools used; and the full **metadata** as JSON. When prompt logging is on, a **Request & Response** panel shows the messages and the model's reply, with a Pretty/JSON toggle.

![The request detail drawer — request details, metrics, and the request/response panel](/assets/images/logs/logs-detail-drawer.png)

---

## What gets logged

Metadata is always logged — model, provider, tokens, cost, timings, status, and the key, team, user, and end-user behind the call.

Prompt and response **content** is **off by default**. Storing it is a platform-level setting (not a per-key toggle in the dashboard); while it is off, the Request & Response panel is empty.

{: .note }
Org-admin-only columns and filters — such as the organisation selector and the router-overhead metric — are hidden for tenant administrators; they belong to the platform admin.

---

## Related

→ [Usage]({% link observability/usage.md %}) to analyse spend over time.
→ [Budget Limits]({% link observability/budget-limits.md %}) to cap the spend you see here.
