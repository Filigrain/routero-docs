---
lang: en
page_id: observability/billing
title: Billing
parent: Observability
nav_order: 4
description: "Your organisation's balance, monthly invoices, and transaction ledger."
---

# Billing

The **Billing** pages show what your organisation has spent and owes — your balance, monthly invoices, and the transaction ledger. For tenants these views are **read-only**: adding credit is handled by your platform administrator.

Open **Billing** in the sidebar (organisation admins).

---

## Overview

The **Overview** page is a summary: your **Current Balance** (or credit used), this month's spend and request count, your **Payment Type** (prepaid or postpaid), a monthly spend trend, and your most recent transactions.

![Billing Overview — balance, monthly spend/requests, payment type, and recent transactions](/assets/images/billing/billing-overview.png)

---

## Invoices

**Invoices** lists one monthly invoice per month with its amount, paid status, and settlement date. Open an invoice to break the month down **by model, by team, by provider, or by day**, and export it as CSV.

![Invoices — monthly invoices with a breakdown by model / team / provider / day](/assets/images/billing/billing-invoices.png)

---

## Transactions

**Transactions** is the balance ledger: every top-up, refund, and deduction, with its source, amount, and the balance before and after. Filter by type, source, or date, and export as CSV.

![Transactions — the balance ledger of top-ups, refunds, and deductions](/assets/images/billing/billing-transactions.png)

---

## Payment settings

Click the **balance** widget at the bottom of the sidebar to see your **Payment Settings** — your organisation, payment type, credit limit or balance, and a history of payment-type changes. (Changing these is a platform-admin action.)

---

## BYOK and spend

Traffic on a provider you've switched to [BYOK]({% link core-gateway/byok.md %}) is billed markup-only — you pay the provider directly. That spend still counts in your totals and is flagged in [Logs]({% link observability/logs.md %}) and [Usage]({% link observability/usage.md %}).

---

## Related

→ [Usage]({% link observability/usage.md %}) — spend analytics by model, team, and provider.
→ [Budget Limits]({% link observability/budget-limits.md %}) — cap spend on keys, teams, and organisations.
→ [BYOK]({% link core-gateway/byok.md %}) — bring your own provider key.
