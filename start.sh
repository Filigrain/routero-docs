#!/usr/bin/env bash
#
# Start the Routero docs (Jekyll) dev server with hot reload.
#
#   Run from the project root:   ./start.sh
#   Run from anywhere:           bash /path/to/start.sh
#
# Ctrl-C to stop.
#
set -euo pipefail

# --- Use Homebrew Ruby (system Ruby 2.6 is too old for Jekyll 4) ---
if ! command -v brew >/dev/null 2>&1; then
  echo "✗ Homebrew not found — install it first: https://brew.sh" >&2
  exit 1
fi
RB_PREFIX="$(brew --prefix ruby)"
if [ ! -x "$RB_PREFIX/bin/ruby" ]; then
  echo "✗ Homebrew Ruby not installed — run: brew install ruby" >&2
  exit 1
fi
# Include the gem bin dir (where bundler 4.x / jekyll binstubs live), resolved
# dynamically so it survives a Ruby point-version bump (e.g. 3.4.7 -> 3.5.x).
GEM_BIN="$("$RB_PREFIX/bin/ruby" -e 'puts Gem.bindir')"
export PATH="$RB_PREFIX/bin:$GEM_BIN:$PATH"

echo "• ruby: $("$RB_PREFIX/bin/ruby" --version)"

# --- Always run from the project root, regardless of where the script is called from ---
cd "$(dirname "$0")"

# --- Install gems on first run or when the Gemfile changes ---
if [ ! -d vendor/bundle ] || ! bundle check >/dev/null 2>&1; then
  echo "• installing gems (first run or Gemfile changed)…"
  bundle config set --local path 'vendor/bundle'
  bundle install
fi

# --- Free port 4000 if a stale Jekyll from a previous run is still bound ---
if command -v lsof >/dev/null 2>&1; then
  STALE=$(lsof -ti tcp:4000 2>/dev/null || true)
  if [ -n "$STALE" ]; then
    echo "• port 4000 busy (stale pid $STALE) — freeing it…"
    kill -9 $STALE 2>/dev/null || true
    sleep 1
  fi
fi

# --- Launch the dev server (auto-regeneration on) ---
echo "• starting Jekyll dev server…  http://127.0.0.1:4000/  (zh-CN: /zh-CN/)"
exec bundle exec jekyll serve
