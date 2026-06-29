---
title: Security Overview
parent: Security & Trust
nav_order: 1
description: "Architecture, key management, access control, and the Routero AI threat model."
---

# Security Overview

Routero AI is built to be the artifact source for your security questionnaires, not an afterthought. This page covers the core security properties that platform, security, and procurement teams care about.

---

## Trust boundary

Routero acts as a **data-plane intermediary** for LLM API calls. It never stores prompt or response content — only metadata (token counts, model, cost, latency, timestamps, key/org attribution).

The security boundary you need to evaluate is:
1. The gateway itself (gateway code, infrastructure, key handling)
2. The channel between your application and Routero
3. The channel between Routero and the upstream LLM provider
4. Where audit data is stored and who can access it

---

## Key management

| Key type | Where stored | Who can see it |
|---|---|---|
| Provider API keys (OpenAI, Anthropic, etc.) | Encrypted in RDS, AES-256 | Admin key only (never returned in API responses or logs) |
| Routero virtual API keys | Stored as bcrypt hash | Original value shown once on creation only |
| Routero master key | Environment variable / AWS SSM | Ops team |
| DB credentials | Terraform state (encrypted) / SSM | Ops team |
| TLS certificates | ACM (managed) / Let's Encrypt | Rotated automatically |

Provider API keys are **never logged, echoed, or exported**. They cannot be retrieved via any API endpoint after creation.

---

## Network security

- All external traffic via Cloudflare WAF (DDoS, TLS termination at edge)
- ALB only accepts ingress from Cloudflare's published IP ranges (origin-pull mTLS)
- All ECS tasks, RDS, and Redis in private subnets — no public IPs
- Egress only via NAT Gateway
- No SSH bastion — operator access via ECS Exec (logged to CloudTrail)

---

## Access control

| Control | Implementation |
|---|---|
| Authentication | Virtual API key (scoped, TTL, revocable) or SAML SSO |
| Authorization | Cerbos PBAC/RBAC — every management and data-plane action checked |
| SCIM deprovisioning | User + keys revoked within seconds of IdP removal |
| IP restriction | Per-key CIDR allowlists |
| MFA | Enforced at the IdP layer for SSO users |
| Internal service | Internal loopback key (signed service-account, not a user key) |

---

## Secure SDLC

- All code changes require PR review before merge
- CI pipeline: dependency scanning (Trivy), secret scanning, static analysis
- Container images: non-root user, minimal base image, no SSH
- ECS deployment circuit breaker: auto-rollback on health check failure
- OIDC-based GitHub Actions — no long-lived AWS credentials

---

## Incident response

- SOC 2 Type II audit includes incident response procedures
- Production alerts in PagerDuty (p1 SLA: 30-minute response)
- Status page at [status.routero.ai](https://status.routero.ai)
- Security vulnerability disclosure: security@routero.ai

For the complete security questionnaire, contact your solutions engineer.
