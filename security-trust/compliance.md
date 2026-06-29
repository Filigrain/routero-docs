---
title: Compliance
parent: Security & Trust
nav_order: 2
description: "SOC 2 Type II, HIPAA BAA, ISO 27001, GDPR DPA — Routero AI's compliance posture."
---

# Compliance

Routero AI is built for regulated enterprises. This page summarises current certifications and what's required to obtain compliance artifacts.

---

## Certifications

| Standard | Status | Notes |
|---|---|---|
| **SOC 2 Type II** | Current | Annual audit. Report available under NDA to Enterprise customers. |
| **HIPAA BAA** | Available | Enterprise plan. Requires dedicated deployment (Single-Tenant or Private Deployments). |
| **ISO 27001** | In progress | Target certification: H2 2026. |
| **GDPR DPA** | Available | EU Standard Contractual Clauses (SCCs) included. Available to all EU customers. |
| **PCI DSS** | Not certified | Routero does not process payment card data. |

---

## SOC 2 Type II

The annual SOC 2 Type II audit covers:
- **Security** — access control, encryption, logging
- **Availability** — uptime monitoring, incident response, DR/BCP
- **Confidentiality** — data classification and handling
- **Processing Integrity** — accurate, complete, and timely processing

To request the report: contact your solutions engineer or email compliance@routero.ai with your company details.

---

## HIPAA

HIPAA Business Associate Agreement (BAA) is available for Enterprise customers on dedicated deployments. The BAA covers Routero's handling of Protected Health Information (PHI) that may appear in metadata (audit log entries, key attribution).

{: .note }
Prompt and response content is never stored by Routero — this is a core privacy property. The BAA covers audit metadata. Your organisation's PHI handling obligations for the content layer remain with you.

---

## GDPR

For EU customers, Routero provides:
- **Data Processing Agreement (DPA)** — covers Routero's role as a data processor
- **Standard Contractual Clauses (SCCs)** — for data transfers outside the EU
- **Sub-processor list** — AWS (Singapore / EU West for EU deployments), available on request

Data residency within the EU is available via Single-Tenant Cloud in `eu-west-1` or `eu-central-1`. → [Data Residency & Regions]({% link deployment/data-residency.md %})

---

## China PIPL

For customers operating in mainland China, Routero's China Beijing deployment (`cn-north-1`, Sinnet account) provides data residency within China consistent with PIPL requirements. See [Data Residency & Regions]({% link deployment/data-residency.md %}).

---

## Requesting compliance artifacts

Contact [compliance@routero.ai](mailto:compliance@routero.ai) or your solutions engineer to request:
- SOC 2 Type II report
- Security questionnaire responses
- GDPR DPA and SCCs
- HIPAA BAA
- Penetration test executive summary
