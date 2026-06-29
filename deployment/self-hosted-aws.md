---
title: Self-Hosted on AWS
parent: Deployment Options
nav_order: 3
description: "Deploy Routero AI in your own AWS account using the Terraform reference architecture."
---

# Self-Hosted on AWS

Run the full production-grade Routero AI stack in your own AWS account. The Terraform reference architecture in `llmrouter-terraform` provisions the same topology Routero runs in production: ECS Fargate, custom VPC, ALB, Multi-AZ RDS, ElastiCache, Cerbos, and an autoscaling coworker service.

---

## When to choose this

- You need all data and provider keys inside your own AWS account boundary.
- Your compliance programme (FedRAMP, internal InfoSec, customer contractual requirements) prohibits third-party-managed compute.
- You want full control over upgrade timing.
- You have in-house AWS/Terraform expertise.

**Estimated baseline cost:** ~USD 300/month for a minimal production topology (Fargate tasks + db.t3.small RDS + t4g.small ElastiCache). Memory-tier services (Neo4j, Qdrant, Redis-Stack) add ~USD 50–150/month depending on EFS usage.

---

## Prerequisites

- Terraform ≥ 1.5
- An AWS account with IAM permissions for ECS, EC2, RDS, ElastiCache, ECR, IAM, Route53/CloudWatch/VPC
- An S3 bucket + DynamoDB table for Terraform remote state (provisioned by `tf-bootstrap/`)
- A GitHub repository (or CI system) with OIDC roles for the GitHub Actions CD pipeline
- Cloudflare account for DNS and edge (optional but recommended — the reference architecture locks the ALB ingress to Cloudflare origin-pull IPs)
- A Resend API key for transactional email

---

## Deployment steps

### 1. Bootstrap remote state

```bash
cd tf-bootstrap/
terraform init
terraform apply
```

This provisions the S3 bucket and DynamoDB lock table for Terraform state.

### 2. Configure environment variables

Copy `envs/production.tfvars.example` to `envs/production.tfvars` and fill in:
- VPC CIDR, region, and AZ configuration
- RDS instance class and database names
- ECR image URIs for the proxy and coworker services
- Secrets (master key, database password) — stored encrypted in Terraform state

### 3. Apply the production stack

```bash
cd tf-production/
terraform init -backend-config=../envs/backend-production.conf
terraform plan -var-file=../envs/production.tfvars
terraform apply -var-file=../envs/production.tfvars
```

### 4. Add provider API keys

Open the Routero admin dashboard (served from the proxy at `/_experimental/out/`) and add your LLM provider credentials. Keys are stored encrypted in RDS — not in Secrets Manager or environment variables.

### 5. Wire DNS

Add a CNAME in Cloudflare pointing your chosen hostname to the ALB DNS name. Terraform does not manage Cloudflare DNS — this is a manual step by design.

---

## Infra modules

The Terraform stack is composed of reusable modules:

| Module | What it provisions |
|---|---|
| `vpc` | Custom VPC, 3 public + 3 private subnets across 3 AZs, NAT Gateways |
| `edge` | ACM certificate, internet-facing ALB, HTTPS listener, Cloudflare IP allowlist, mTLS origin-pull |
| `cluster` | ECS cluster, proxy service (port 4000, ALB target, autoscaling 1–10), coworker service |
| `stateful` | Three Multi-AZ RDS instances (litellm, mem0, cognee) + ElastiCache Redis |
| `memory` | Optional ECS tasks for Neo4j, Qdrant, Redis-Stack on EFS (enable with `enable_memory_tier = true`) |
| `cerbos` | Cerbos PBAC/RBAC policy engine as an ECS task |
| `service-discovery` | AWS Cloud Map internal DNS for inter-service communication |

→ [Reference Architecture]({% link deployment/reference-architecture.md %}) for the full topology diagram and component descriptions.

---

## Upgrades

Routero publishes updated container images to a public ECR. To deploy a new version:

```bash
# Update the image tag in your tfvars, then:
aws ecs update-service --cluster routero-production --service routero-production --force-new-deployment
```

The ECS deployment circuit breaker auto-rolls back if health checks fail. Shell access (when needed) is via ECS Exec — no SSH bastion required.
