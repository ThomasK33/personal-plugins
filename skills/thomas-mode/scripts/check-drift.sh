#!/usr/bin/env bash
# Reports upstream plugin changes to the files thomas-mode amends or depends on.
# Usage: check-drift.sh [--diff | --diff=<path> | --accept]
#   --diff         print the upstream diff for each changed file
#   --diff=<path>  print the upstream diff for one watched file only, such as skills/egm-draft/SKILL.md.
#                  One leading ./ is ignored. Give it once, without --diff. A path that more than one plugin watches is an error.
#   --accept       after you reviewed the drift, pin the installed plugin commits in PINNED.
#                  Run it in your personal-plugins clone and commit PINNED. It cannot be combined with --diff.
# Exit 0: no drift. Exit 1: drift (see output). Exit 2: usage, setup, or network error.
set -euo pipefail
trap 'echo "ERR line $LINENO" >&2; exit 2' ERR
HERE="$(cd "$(dirname "$0")/.." && pwd -P)"
PINS="$HERE/PINNED"
# github.com and raw.githubusercontent.com answer HTTP 504 now and then. Without --retry-all-errors,
# curl retries only timeouts and the transient HTTP 5xx and 408/429 answers its manual lists, so a 404
# (ADDED) still answers at once. --max-time bounds each attempt, so a server that accepts the
# connection but never answers cannot hang the check.
CURL_RETRY=(--max-time 20 --retry 4 --retry-delay 2 --retry-max-time 60)
SHOW_DIFF=0 ACCEPT=0 DIFF_ALL=0 DIFF_PATH=""
for a in "$@"; do
  case "$a" in
    --diff) SHOW_DIFF=1; DIFF_ALL=1 ;;
    --diff=?*)
      [ -z "$DIFF_PATH" ] || { echo "ERR --diff=<path> given more than once" >&2; exit 2; }
      SHOW_DIFF=1; DIFF_PATH="${a#--diff=}"; DIFF_PATH="${DIFF_PATH#./}"
      [ -n "$DIFF_PATH" ] || { echo "usage: $0 [--diff | --diff=<path> | --accept]" >&2; exit 2; } ;;
    --accept) ACCEPT=1 ;;
    *) echo "usage: $0 [--diff | --diff=<path> | --accept]" >&2; exit 2 ;;
  esac
done
if [ "$DIFF_ALL" = 1 ] && [ -n "$DIFF_PATH" ]; then echo "ERR --diff cannot be combined with --diff=<path>" >&2; exit 2; fi
if [ "$ACCEPT" = 1 ] && [ "$SHOW_DIFF" = 1 ]; then echo "ERR --accept cannot be combined with --diff" >&2; exit 2; fi
# The Xum home is XUM_ROOT or MUX_ROOT when set, else the first of ~/.xum and ~/.mux (older installs) that holds a plugins.json.
XUM_HOME="${XUM_ROOT:-${MUX_ROOT:-}}"
if [ -z "$XUM_HOME" ]; then
  for d in "$HOME/.xum" "$HOME/.mux"; do [ -f "$d/plugins.json" ] && { XUM_HOME="$d"; break; }; done
fi
[ -n "$XUM_HOME" ] || { echo "ERR no plugins.json in \$XUM_ROOT, \$MUX_ROOT, ~/.xum or ~/.mux" >&2; exit 2; }
PLUGINS="$XUM_HOME/plugins"
REGISTRY="$XUM_HOME/plugins.json"
[ -f "$REGISTRY" ] || { echo "ERR no $REGISTRY" >&2; exit 2; }
[ -f "$PINS" ] || { echo "ERR no $PINS" >&2; exit 2; }

# Anchors live in SKILL.md as: [<plugin> <path> § <step title>]
ANCHORS="$(grep -oP '\[[a-z0-9-]+ [^ \]]+ § [^\]]+\]' "$HERE/SKILL.md" | sort -u || true)"
[ -n "$ANCHORS" ] || { echo "ERR no anchors in $HERE/SKILL.md" >&2; exit 2; }
# Files thomas-mode depends on without an anchor.
WATCH="pstack docs/harness/claude-code.md
pstack skills/poteto-mode/SKILL.md
pstack skills/setup-pstack/SKILL.md
pstack skills/principle-test-behavior-not-implementation/SKILL.md
fux-plugins skills/test-audit/SKILL.md
egm docs/harnesses.md
egm docs/claude.md
egm docs/codex.md"
FILES="$( { printf '%s\n' "$ANCHORS" | sed -E 's/^\[([^ ]+) ([^ ]+) § .*/\1 \2/'; printf '%s\n' "$WATCH"; } | sort -u)"
PLUGIN_SET="$(printf '%s\n' "$FILES" | cut -d' ' -f1 | sort -u)"
if [ -n "$DIFF_PATH" ]; then
  owners="$(printf '%s\n' "$FILES" | awk -v p="$DIFF_PATH" '$2==p {print $1}' | sort -u)"
  [ -n "$owners" ] || { echo "ERR $DIFF_PATH is not a watched file" >&2; exit 2; }
  case "$owners" in *$'\n'*) echo "ERR ambiguous path $DIFF_PATH: watched in plugins $(printf '%s\n' "$owners" | paste -sd' ' -)" >&2; exit 2 ;; esac
fi

# Prints: <lockedSha> <owner/repo> <subpath or .>
installed() { python3 - "$REGISTRY" "$1" <<'PY'
import json, re, sys
for p in json.load(open(sys.argv[1]))["plugins"]:
    if p["name"] == sys.argv[2]:
        m = re.match(r"(?:https://|ssh://git@|git@)github\.com[/:]([^/]+/[^/]+?)(?:\.git)?/?$", p["source"]["url"])
        if not m: sys.exit(f"unsupported source {p['source']['url']}")
        print(p["lockedSha"], m.group(1), p["source"].get("subpath") or ".")
        break
else:
    sys.exit(f"plugin {sys.argv[2]} not installed")
PY
}
pinned() { awk -v p="$1" '$1==p {print $2}' "$PINS"; }
# gh_code <api path> <out file>: writes the raw body through gh and prints 200, or 404 when GitHub has no such object.
gh_code() {
  local err rc=0
  err="$(gh api -H 'Accept: application/vnd.github.raw' "$1" 2>&1 >"$2")" || rc=$?
  if [ "$rc" = 0 ]; then printf 200; elif grep -q 'HTTP 404' <<< "$err"; then printf 404; else echo "ERR gh api $1 failed" >&2; exit 2; fi
}

missing=0
while read -r plugin path; do
  [ -f "$PLUGINS/$plugin/$path" ] || { echo "MISSING $plugin $path"; missing=1; }
done <<< "$FILES"

if [ "$ACCEPT" = 1 ]; then
  [ "$missing" = 0 ] || { echo "ERR refusing --accept while a file is MISSING" >&2; exit 2; }
  case "$HERE" in "$(cd "$PLUGINS" && pwd -P)"/*) echo "WARN $HERE is an installed plugin copy. Plugin updates replace it. Run --accept in your clone and commit PINNED." >&2 ;; esac
  tmp="$(mktemp)"
  while read -r plugin; do read -r sha _ <<< "$(installed "$plugin")"; [ -n "${sha:-}" ] || { echo "ERR plugin $plugin not in $REGISTRY" >&2; exit 2; }; echo "$plugin $sha" >> "$tmp"; done <<< "$PLUGIN_SET"
  mv "$tmp" "$PINS"; echo "pinned:"; cat "$PINS"; exit 0
fi

drift=$missing checked=0 nopin=" " cache="$(mktemp -d)"
trap 'rm -rf "$cache"' EXIT
while read -r plugin path; do
  checked=$((checked+1))
  cur="$PLUGINS/$plugin/$path"; [ -f "$cur" ] || continue
  read -r sha repo sub <<< "$(installed "$plugin")"
  [ -n "${sha:-}" ] || { echo "ERR plugin $plugin not in $REGISTRY" >&2; exit 2; }
  pin="$(pinned "$plugin")"
  if [ -z "$pin" ]; then
    case "$nopin" in *" $plugin "*) ;; *) echo "NOPIN   $plugin (run --accept once)"; nopin="$nopin$plugin " ;; esac
    drift=1; continue
  fi
  [ "$sha" = "$pin" ] && continue
  base="$cache/$plugin/$path"; mkdir -p "$(dirname "$base")"
  url="https://raw.githubusercontent.com/$repo/$pin/${sub#./}/$path"; url="${url/\/.\//\/}"
  if ! grep -qx "$plugin" "$cache/commits-ok" 2>/dev/null; then
    # Read the HTTP code, as for the raw file below: only a 404 means the pinned commit is missing.
    ccode="$(curl -sSL "${CURL_RETRY[@]}" -o /dev/null -w '%{http_code}' "https://github.com/$repo/commit/$pin")" || { echo "ERR cannot fetch github.com commit $pin of $repo" >&2; exit 2; }
    # A private repo answers 404 to anonymous curl. Read it through the GitHub CLI's login instead.
    if [ "$ccode" = 404 ] && command -v gh >/dev/null; then ccode="$(gh_code "repos/$repo/commits/$pin" /dev/null)"; [ "$ccode" = 404 ] || echo "$plugin" >> "$cache/via-gh"; fi
    if [ "$ccode" = 404 ]; then echo "ERR pinned commit $pin not found in $repo" >&2; exit 2; fi
    [ "$ccode" = 200 ] || { echo "ERR HTTP $ccode for github.com commit $pin of $repo" >&2; exit 2; }
    echo "$plugin" >> "$cache/commits-ok"
  fi
  if grep -qx "$plugin" "$cache/via-gh" 2>/dev/null; then
    rel="${sub#./}/$path"; rel="${rel#/}"
    code="$(gh_code "repos/$repo/contents/$rel?ref=$pin" "$base")"
  else
    code="$(curl -sSL "${CURL_RETRY[@]}" -o "$base" -w '%{http_code}' "$url")" || { echo "ERR cannot fetch $url" >&2; exit 2; }
  fi
  if [ "$code" = 404 ]; then echo "ADDED   $plugin $path (not present at ${pin:0:7})"; drift=1; continue; fi
  [ "$code" = 200 ] || { echo "ERR HTTP $code for $url" >&2; exit 2; }
  if ! cmp -s "$base" "$cur"; then
    n="$(diff "$base" "$cur" | grep -c '^[<>]' || true)"
    echo "CHANGED $plugin $path ($n lines since ${pin:0:7})"; drift=1
    if [ "$SHOW_DIFF" = 1 ] && { [ -z "$DIFF_PATH" ] || [ "$path" = "$DIFF_PATH" ]; }; then diff -u "$base" "$cur" || true; fi
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
echo "summary: $checked files, $anchors anchors, registry $REGISTRY, drift=$drift"
exit "$drift"
