#!/usr/bin/env bash
# publish-oss.sh — upload the China build (_site/) to the Alibaba Cloud OSS
# bucket behind the CDN for docs.routero.dcsmartvision.com:
#
#   HTML and JSON (pages, search data)   always revalidate
#   everything else (css/js/images/fonts) browser-cached 1 day
#   <dir>/index.html                      also as "<dir>" (/zh-CN): the CDN
#                                         serves exact keys only
#
# "/" and "<dir>/" are rewritten to index.html by the CDN and an unknown path
# gets 404.html (llmrouter-terraform tf-production-cn-ali/docs-cdn.tf). Keys the
# build no longer has are deleted last, so a page is never missing while the
# new one goes up. CNAME is a GitHub Pages hint and is not published.
#
#   scripts/publish-oss.sh <site dir> <bucket>
#
# Env: ALIYUN_PROFILE (default ci), OSS_REGION (default cn-beijing).
set -euo pipefail

site="${1:?site dir}"; bucket="${2:?bucket}"
profile="${ALIYUN_PROFILE:-ci}"; region="${OSS_REGION:-cn-beijing}"
test -f "$site/index.html" || { echo "$site/index.html missing: build first" >&2; exit 1; }

oss() { aliyun --profile "$profile" oss "$@" --region "$region"; }
# No directory objects: a zero-byte "zh-CN/" would answer /zh-CN/ blank.
put() { oss cp "$@" -f --disable-dir-object; }
page='Cache-Control:no-cache, must-revalidate'

work="$(mktemp -d)"; trap 'rm -rf "$work"' EXIT
out="$work/site"; mkdir "$out"
cp -R "$site/." "$out/"
rm -f "$out/CNAME"

# Every key this release consists of, aliases included (for the cleanup).
keys="$work/keys"
(cd "$out" && find . -type f | sed 's|^\./||') > "$keys"

# 1) static files
put "$out/" "oss://$bucket/" -r --jobs 10 --exclude '*.html' --exclude '*.json' \
  --meta 'Cache-Control:public, max-age=86400'

# 2) pages and search data; the directory homes again without the slash;
#    index.html last
put "$out/" "oss://$bucket/" -r --jobs 10 --include '*.json' --meta "$page"
(cd "$out" && find . -name '*.html' ! -path './index.html' | sed 's|^\./||') | while read -r f; do
  put "$out/$f" "oss://$bucket/$f" --meta "Content-Type:text/html; charset=utf-8#$page"
  case "$f" in */index.html)
    put "$out/$f" "oss://$bucket/${f%/index.html}" --meta "Content-Type:text/html; charset=utf-8#$page"
    echo "${f%/index.html}" >> "$keys" ;;
  esac
done
put "$out/index.html" "oss://$bucket/index.html" --meta "Content-Type:text/html; charset=utf-8#$page"

# 3) delete what the build no longer has
oss ls "oss://$bucket/" -s | grep '^oss://' | sed "s|^oss://$bucket/||" | sort > "$work/live"
sort -u "$keys" > "$work/want"
comm -23 "$work/live" "$work/want" | while read -r k; do
  [ -n "$k" ] || continue
  echo "delete $k"
  oss rm "oss://$bucket/$k" -f
done
echo "published $(sort -u "$keys" | wc -l | tr -d ' ') keys to oss://$bucket/"
