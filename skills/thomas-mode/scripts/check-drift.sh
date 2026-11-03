#!/usr/bin/env bash
# Reports upstream plugin changes to the files thomas-mode amends or depends on.
# Usage: check-drift.sh [--diff] [--accept]
#   --diff    print the upstream diff for each changed file
#   --accept  after you reviewed the drift, pin the installed plugin commits in PINNED.
#             Run it in your personal-plugins clone and commit PINNED.
# Exit 0: no drift. Exit 1: drift (see output). Exit 2: usage, setup, or network error.
set -euo pipefail
trap 'echo "ERR line $LINENO" >&2; exit 2' ERR
HERE="$(cd "$(dirname "$0")/.." && pwd)"
PLUGINS="$HOME/.mux/plugins"
REGISTRY="$HOME/.mux/plugins.json"
PINS="$HERE/PINNED"
SHOW_DIFF=0 ACCEPT=0
for a in "$@"; do
  case "$a" in
    --diff) SHOW_DIFF=1 ;;
    --accept) ACCEPT=1 ;;
    *) echo "usage: $0 [--diff] [--accept]" >&2; exit 2 ;;
  esac
done
[ -f "$REGISTRY" ] || { echo "ERR no $REGISTRY" >&2; exit 2; }
[ -f "$PINS" ] || { echo "ERR no $PINS" >&2; exit 2; }

# Anchors live in SKILL.md as: [<plugin> <path> § <step title>]
ANCHORS="$(grep -oP '\[[a-z0-9-]+ [^ \]]+ § [^\]]+\]' "$HERE/SKILL.md" | sort -u || true)"
[ -n "$ANCHORS" ] || { echo "ERR no anchors in $HERE/SKILL.md" >&2; exit 2; }
# Files thomas-mode depends on without an anchor.
WATCH="pstack docs/harness/claude-code.md
pstack skills/poteto-mode/SKILL.md
pstack skills/setup-pstack/SKILL.md
egm docs/harnesses.md
egm docs/claude.md
egm docs/codex.md"
FILES="$( { printf '%s\n' "$ANCHORS" | sed -E 's/^\[([^ ]+) ([^ ]+) § .*/\1 \2/'; printf '%s\n' "$WATCH"; } | sort -u)"
PLUGIN_SET="$(printf '%s\n' "$FILES" | cut -d' ' -f1 | sort -u)"

# Prints: <lockedSha> <owner/repo> <subpath or .>
installed() { python3 - "$REGISTRY" "$1" <<'PY'
import json, re, sys
for p in json.load(open(sys.argv[1]))["plugins"]:
    if p["name"] == sys.argv[2]:
        m = re.match(r"https://github\.com/([^/]+/[^/]+?)/?$", p["source"]["url"])
        if not m: sys.exit(f"unsupported source {p['source']['url']}")
        print(p["lockedSha"], m.group(1), p["source"].get("subpath") or ".")
        break
else:
    sys.exit(f"plugin {sys.argv[2]} not installed")
PY
}
pinned() { awk -v p="$1" '$1==p {print $2}' "$PINS"; }

missing=0
while read -r plugin path; do
  [ -f "$PLUGINS/$plugin/$path" ] || { echo "MISSING $plugin $path"; missing=1; }
done <<< "$FILES"

if [ "$ACCEPT" = 1 ]; then
  [ "$missing" = 0 ] || { echo "ERR refusing --accept while a file is MISSING" >&2; exit 2; }
  case "$HERE" in "$PLUGINS"/*) echo "WARN $HERE is an installed plugin copy. Plugin updates replace it. Run --accept in your clone and commit PINNED." >&2 ;; esac
  tmp="$(mktemp)"
  while read -r plugin; do read -r sha _ <<< "$(installed "$plugin")"; [ -n "${sha:-}" ] || { echo "ERR plugin $plugin not in $REGISTRY" >&2; exit 2; }; echo "$plugin $sha" >> "$tmp"; done <<< "$PLUGIN_SET"
  mv "$tmp" "$PINS"; echo "pinned:"; cat "$PINS"; exit 0
fi

drift=$missing checked=0 cache="$(mktemp -d)"
trap 'rm -rf "$cache"' EXIT
while read -r plugin path; do
  checked=$((checked+1))
  cur="$PLUGINS/$plugin/$path"; [ -f "$cur" ] || continue
  read -r sha repo sub <<< "$(installed "$plugin")"
  [ -n "${sha:-}" ] || { echo "ERR plugin $plugin not in $REGISTRY" >&2; exit 2; }
  pin="$(pinned "$plugin")"
  [ -n "$pin" ] || { echo "NOPIN   $plugin (run --accept once)"; drift=1; continue; }
  [ "$sha" = "$pin" ] && continue
  base="$cache/$plugin/$path"; mkdir -p "$(dirname "$base")"
  url="https://raw.githubusercontent.com/$repo/$pin/${sub#./}/$path"; url="${url/\/.\//\/}"
  if ! grep -qx "$plugin" "$cache/commits-ok" 2>/dev/null; then
    curl -fsS -o /dev/null "https://github.com/$repo/commit/$pin" || { echo "ERR pinned commit $pin not found in $repo" >&2; exit 2; }
    echo "$plugin" >> "$cache/commits-ok"
  fi
  code="$(curl -sSL -o "$base" -w '%{http_code}' "$url")" || { echo "ERR cannot fetch $url" >&2; exit 2; }
  if [ "$code" = 404 ]; then echo "ADDED   $plugin $path (not present at ${pin:0:7})"; drift=1; continue; fi
  [ "$code" = 200 ] || { echo "ERR HTTP $code for $url" >&2; exit 2; }
  if ! cmp -s "$base" "$cur"; then
    n="$(diff "$base" "$cur" | grep -c '^[<>]' || true)"
    echo "CHANGED $plugin $path ($n lines since ${pin:0:7})"; drift=1
    if [ "$SHOW_DIFF" = 1 ]; then diff -u "$base" "$cur" || true; fi
  fi
done <<< "$FILES"
anchors=0
while IFS= read -r a; do
  anchors=$((anchors+1))
  plugin="$(sed -E 's/^\[([^ ]+) .*/\1/' <<< "$a")"
  path="$(sed -E 's/^\[[^ ]+ ([^ ]+) § .*/\1/' <<< "$a")"
  title="$(sed -E 's/^\[[^ ]+ [^ ]+ § (.*)\]$/\1/' <<< "$a")"
  grep -qF -- "$title" "$PLUGINS/$plugin/$path" 2>/dev/null || { echo "ANCHOR  $plugin $path: step '$title' not found"; drift=1; }
done <<< "$ANCHORS"
echo "summary: $checked files, $anchors anchors, drift=$drift"
exit "$drift"
