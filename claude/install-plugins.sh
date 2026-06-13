#!/usr/bin/env bash
# Install the Claude Code plugins declared in claude/plugins.json.
# Idempotent: safe to re-run; run it after cloning this repo on a new machine.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cfg="$repo/claude/plugins.json"

# Add or update each marketplace. type=local -> source is path relative to repo;
# type=github -> source is "owner/repo".
python3 -c "
import json
for m in json.load(open('$cfg'))['marketplaces']:
    src = '$repo' if m['type']=='local' and m['path']=='.' else m['path']
    print(m['name'], src)
" | while read -r name src; do
  if claude plugin marketplace list 2>/dev/null | grep -q "$name"; then
    claude plugin marketplace update "$name"
  else
    claude plugin marketplace add "$src"
  fi
done

python3 -c "import json;[print(p) for p in json.load(open('$cfg'))['enable']]" | while read -r p; do
  claude plugin install "$p" 2>/dev/null || claude plugin enable "$p" 2>/dev/null \
    || echo "already installed: $p"
done

echo "--- installed plugins ---"
claude plugin list 2>/dev/null | grep "❯" || true
echo "done."
