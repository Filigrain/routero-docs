#!/usr/bin/env bash
# cn-bj-docs-cert-renewal.sh — auto-renew the Let's Encrypt viewer certificate
# for the docs China CloudFront (docs.routero.dcsmartvision.com).
#
# WHY: China CloudFront cannot reference ACM — only IAM server certificates —
# and IAM certs cannot be re-imported in place. Every renewal is therefore:
#   ACME DNS-01 (Route53) → upload as a NEW IAM server certificate → repoint the
#   distribution → verify → prune superseded certs.
# The docs stack is CLI-managed (no Terraform) — this script is the SOLE owner
# of the cert lifecycle, including the initial issuance if run with --force
# once the distribution exists.
#
# Run by .github/workflows/cert-renewal-cn.yml (weekly; no-ops while >30 days
# remain). Credentials come from the standard AWS chain: OIDC env vars in CI,
# locally export AWS_PROFILE=china-profile first.
#
# Idempotent & self-healing: a run interrupted mid-way (e.g. uploaded but not
# swapped) is recovered by the next weekly run — it simply mints a fresh cert
# and re-uploads; pruning keeps the newest 2 certs (current + 1 rollback).
#
# ACME account is per-run ephemeral (no persisted account key). Let's Encrypt's
# 10-new-accounts-per-IP-per-3h limit can in theory collide on shared CI runner
# IPs; a failed run merely retries next week with the old cert still serving.
#
# Usage: scripts/cn-bj-docs-cert-renewal.sh [--dry-run] [--force]
#   --dry-run  inspect + report only (no certbot, no IAM/CloudFront writes)
#   --force    renew even if more than RENEW_WHEN_DAYS_LEFT days remain
#
# Requires: aws CLI v2, python3 (with venv), network to PyPI + LetsEncrypt.

set -euo pipefail

DOMAIN="docs.routero.dcsmartvision.com"
CERT_PATH="/cloudfront/docs-dcsmartvision/"
CERT_NAME_PREFIX="docs-dcsmartvision"
RENEW_WHEN_DAYS_LEFT=30
KEEP_CERTS=2            # newest 2 by expiry: current + 1 rollback
CERTBOT_VERSION="5.7.0" # pin; bump together when touching this file
DEPLOY_TIMEOUT_MIN=20   # China CloudFront deploys can be slow

DRY_RUN=false
FORCE=false
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --force) FORCE=true ;;
    *) echo "unknown argument: $arg (expected --dry-run / --force)" >&2; exit 2 ;;
  esac
done

# Private key + ACME state never outlive the run.
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

log() { echo "[cert-renewal] $*"; }

# ── 1. Locate the docs distribution by alias ──────────────────────────────────
DIST_ID="$(aws cloudfront list-distributions \
  --query "DistributionList.Items[?contains(Aliases.Items, '${DOMAIN}')].Id | [0]" \
  --output text)"
if [ -z "$DIST_ID" ] || [ "$DIST_ID" = "None" ]; then
  log "ERROR: no CloudFront distribution with alias ${DOMAIN} found"
  exit 1
fi
log "distribution: ${DIST_ID} (alias ${DOMAIN})"

# ── 2. How long does the live viewer cert have left? ──────────────────────────
CURRENT_ID="$(aws cloudfront get-distribution-config --id "$DIST_ID" \
  --query 'DistributionConfig.ViewerCertificate.IAMCertificateId' --output text)"
DAYS_LEFT=0
if [ -n "$CURRENT_ID" ] && [ "$CURRENT_ID" != "None" ]; then
  EXPIRY_ISO="$(aws iam list-server-certificates --path-prefix "$CERT_PATH" \
    --query "ServerCertificateMetadataList[?ServerCertificateId=='${CURRENT_ID}'].Expiration | [0]" \
    --output text)"
  if [ -n "$EXPIRY_ISO" ] && [ "$EXPIRY_ISO" != "None" ]; then
    DAYS_LEFT="$(python3 -c "
from datetime import datetime, timezone
exp = datetime.fromisoformat('${EXPIRY_ISO}'.replace('Z', '+00:00'))
print(int((exp - datetime.now(timezone.utc)).total_seconds() // 86400))")"
  fi
fi
log "live cert: ${CURRENT_ID:-<none>}, expires in ${DAYS_LEFT} day(s)"

if [ "$DAYS_LEFT" -gt "$RENEW_WHEN_DAYS_LEFT" ] && [ "$FORCE" != "true" ]; then
  log "no renewal needed (> ${RENEW_WHEN_DAYS_LEFT} days left) — exiting"
  exit 0
fi
if [ "$DRY_RUN" = "true" ]; then
  log "DRY RUN: would now issue a new cert for ${DOMAIN} (certbot DNS-01),"
  log "upload it under ${CERT_PATH}, swap ${DIST_ID} to it and prune old certs."
  exit 0
fi
log "renewing (days left: ${DAYS_LEFT}, force: ${FORCE})"

# ── 3. Issue a fresh cert via certbot DNS-01 against Route53 ──────────────────
# boto3 resolves the aws-cn partition Route53 endpoint from AWS_REGION; the
# session credentials (env vars) are inherited by the venv's certbot as-is.
python3 -m venv "$WORK/venv"
"$WORK/venv/bin/pip" install --quiet "certbot==${CERTBOT_VERSION}" "certbot-dns-route53==${CERTBOT_VERSION}"
"$WORK/venv/bin/certbot" certonly \
  --dns-route53 \
  --non-interactive --agree-tos \
  --register-unsafely-without-email \
  --cert-name "$DOMAIN" -d "$DOMAIN" \
  --config-dir "$WORK/letsencrypt" --work-dir "$WORK/work" --logs-dir "$WORK/logs"
LIVE_DIR="$WORK/letsencrypt/live/$DOMAIN"

# Integrity check on what we are about to upload (leaf + chain match IAM metadata).
NEW_NOTAFTER_EPOCH="$(openssl x509 -enddate -noout -in "$LIVE_DIR/cert.pem" \
  | cut -d= -f2 | python3 -c "
import sys
from datetime import datetime, timezone
print(int(datetime.strptime(sys.stdin.read().strip(), '%b %d %H:%M:%S %Y %Z').replace(tzinfo=timezone.utc).timestamp()))")"

# ── 4. Upload as a NEW IAM server certificate ─────────────────────────────────
NEW_NAME="${CERT_NAME_PREFIX}-$(date -u +%Y%m%d-%H%M)"
NEW_ID="$(aws iam upload-server-certificate \
  --server-certificate-name "$NEW_NAME" \
  --certificate-body "file://${LIVE_DIR}/cert.pem" \
  --private-key "file://${LIVE_DIR}/privkey.pem" \
  --certificate-chain "file://${LIVE_DIR}/chain.pem" \
  --path "$CERT_PATH" \
  --query 'ServerCertificateMetadata.ServerCertificateId' --output text)"
IAM_EXPIRY_EPOCH="$(aws iam list-server-certificates --path-prefix "$CERT_PATH" \
  --query "ServerCertificateMetadataList[?ServerCertificateId=='${NEW_ID}'].Expiration | [0]" \
  --output text | python3 -c "
import sys
from datetime import datetime
print(int(datetime.fromisoformat(sys.stdin.read().strip().replace('Z', '+00:00')).timestamp()))")"
if [ "$IAM_EXPIRY_EPOCH" != "$NEW_NOTAFTER_EPOCH" ]; then
  log "ERROR: uploaded cert expiry (${IAM_EXPIRY_EPOCH}) != local cert expiry (${NEW_NOTAFTER_EPOCH}) — aborting before swap"
  exit 1
fi
log "uploaded: ${NEW_NAME} (${NEW_ID})"

# ── 5. Swap the distribution to the new cert ──────────────────────────────────
aws cloudfront get-distribution-config --id "$DIST_ID" > "$WORK/dist-config.json"
ETAG="$(python3 -c "import json; print(json.load(open('$WORK/dist-config.json'))['ETag'])")"
python3 - "$WORK/dist-config.json" "$WORK/dist-config-new.json" "$NEW_ID" <<'PY'
import json, sys
src, dst, new_id = sys.argv[1], sys.argv[2], sys.argv[3]
cfg = json.load(open(src))["DistributionConfig"]
cfg["ViewerCertificate"]["IAMCertificateId"] = new_id
json.dump(cfg, open(dst, "w"), indent=2)
PY
aws cloudfront update-distribution \
  --id "$DIST_ID" --if-match "$ETAG" \
  --distribution-config "file://${WORK}/dist-config-new.json" > /dev/null
log "swap requested — waiting for Deployed (timeout ${DEPLOY_TIMEOUT_MIN}m)"

# ── 6. Wait for the distribution to finish deploying ─────────────────────────
DEADLINE=$(( $(date +%s) + DEPLOY_TIMEOUT_MIN * 60 ))
while :; do
  STATUS="$(aws cloudfront get-distribution --id "$DIST_ID" \
    --query 'Distribution.Status' --output text)"
  [ "$STATUS" = "Deployed" ] && break
  if [ "$(date +%s)" -ge "$DEADLINE" ]; then
    log "ERROR: distribution still '${STATUS}' after ${DEPLOY_TIMEOUT_MIN}m — new cert ${NEW_ID} is attached but not verified; investigate manually"
    exit 1
  fi
  sleep 20
done

# ── 7. Verify the swap stuck ──────────────────────────────────────────────────
LIVE_ID="$(aws cloudfront get-distribution-config --id "$DIST_ID" \
  --query 'DistributionConfig.ViewerCertificate.IAMCertificateId' --output text)"
if [ "$LIVE_ID" != "$NEW_ID" ]; then
  log "ERROR: distribution references ${LIVE_ID}, expected ${NEW_ID}"
  exit 1
fi
# Best-effort end-to-end probe from the runner (non-fatal — CN edge reachability
# from outside China varies, and the config check above is authoritative).
if ! curl -sI --max-time 20 "https://${DOMAIN}" -o /dev/null; then
  log "WARN: HTTPS probe of https://${DOMAIN} failed/timed out from this runner (config verified OK — ignoring)"
fi
log "verified: ${DOMAIN} now served by ${NEW_NAME} (${NEW_ID})"

# ── 8. Prune superseded certs (keep newest ${KEEP_CERTS} by expiry) ───────────
aws iam list-server-certificates --path-prefix "$CERT_PATH" --output json > "$WORK/certs.json"
python3 - "$WORK/certs.json" "$KEEP_CERTS" <<'PY' > "$WORK/to-delete.txt"
import json, sys
certs, keep = json.load(open(sys.argv[1]))["ServerCertificateMetadataList"], int(sys.argv[2])
for c in sorted(certs, key=lambda c: c["Expiration"], reverse=True)[keep:]:
    print(c["ServerCertificateName"])
PY
if [ -s "$WORK/to-delete.txt" ]; then
  while read -r OLD_NAME; do
    [ -z "$OLD_NAME" ] && continue
    aws iam delete-server-certificate --server-certificate-name "$OLD_NAME"
    log "pruned old cert: ${OLD_NAME}"
  done < "$WORK/to-delete.txt"
else
  log "no superseded certs to prune"
fi

log "DONE — ${DOMAIN} renewed (was ${DAYS_LEFT} day(s) left)"
