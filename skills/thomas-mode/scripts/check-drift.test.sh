#!/usr/bin/env bash
# Runs check-drift.sh against fake Xum homes and a fake curl, with no network.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
CHECK="$SCRIPT_DIR/check-drift.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

ANCHORS="$(grep -oP '\[[a-z0-9-]+ [^ \]]+ § [^\]]+\]' "$SKILL_DIR/SKILL.md" | sort -u)"
WATCH="$(sed -n '/^WATCH="/,/"$/p' "$CHECK" | tr -d '"' | sed 's/^WATCH=//')"
FILES="$( { sed -E 's/^\[([^ ]+) ([^ ]+) § .*/\1 \2/' <<< "$ANCHORS"; printf '%s\n' "$WATCH"; } | sort -u)"

# installed_tree <xum home> [url template]: writes plugins.json and one file per watched path, each holding its anchor titles.
# Real installs record the clone URL with .git, and pstack lives under a subpath.
installed_tree() {
  local home="$1" url="${2:-https://github.com/test/@NAME@.git}" plugin path
  mkdir -p "$home"
  while read -r plugin path; do
    mkdir -p "$(dirname "$home/plugins/$plugin/$path")"
    grep -F "[$plugin $path § " <<< "$ANCHORS" | sed -E 's/^\[[^ ]+ [^ ]+ § (.*)\]$/## \1/' > "$home/plugins/$plugin/$path" || true
  done <<< "$FILES"
  local names; mapfile -t names < <(cut -d' ' -f1 <<< "$FILES" | sort -u)
  python3 - "$home/plugins.json" "$url" "${names[@]}" <<'PY'
import json, sys
plugins = []
for name in sys.argv[3:]:
    source = {"type": "git", "url": sys.argv[2].replace("@NAME@", name), "ref": "main"}
    if name == "pstack":
        source["subpath"] = "pstack"
    plugins.append({"name": name, "source": source, "lockedSha": "installed-" + name})
json.dump({"plugins": plugins}, open(sys.argv[1], "w"))
PY
}

# The fake upstream holds each installed file at the pinned commit, laid out as raw.githubusercontent.com serves it.
REMOTE="$TMP/remote"
upstream_from() {
  local home="$1" plugin path pin sub
  rm -rf "$REMOTE"
  while read -r plugin path; do
    pin="$(awk -v p="$plugin" '$1==p {print $2}' "$SKILL_DIR/PINNED")"
    sub=""; [ "$plugin" = pstack ] && sub="pstack/"
    mkdir -p "$(dirname "$REMOTE/test/$plugin/$pin/$sub$path")"
    cp "$home/plugins/$plugin/$path" "$REMOTE/test/$plugin/$pin/$sub$path"
  done <<< "$FILES"
}

mkdir -p "$TMP/bin"
cat > "$TMP/bin/curl" <<EOF
#!/usr/bin/env bash
out=/dev/null url=""
while [ \$# -gt 0 ]; do
  case "\$1" in -o) out="\$2"; shift ;; http*) url="\$1" ;; esac
  shift
done
case "\$url" in
  https://github.com/*/commit/*)
    rest="\${url#https://github.com/}"; repo="\${rest%%/commit/*}"; sha="\${rest##*/commit/}"
    if [ -d "$REMOTE/\$repo/\$sha" ]; then printf 200; else printf 404; fi ;;
  https://raw.githubusercontent.com/*)
    f="$REMOTE/\${url#https://raw.githubusercontent.com/}"
    if [ -f "\$f" ]; then cp "\$f" "\$out"; printf 200; else printf 404; fi ;;
  *) printf 404 ;;
esac
EOF
chmod +x "$TMP/bin/curl"

# A watched file that the "changed" cases edit.
read -r EDIT_PLUGIN EDIT_PATH <<< "$(head -n 1 <<< "$FILES")"
pass=0 fail=0
# run_case <name> <expected exit> <expected output line regex> [VAR=value...] [script args...]
run_case() {
  local name="$1" want="$2" pattern="$3" rc=0 out envs=()
  shift 3
  while [ $# -gt 0 ] && [[ "$1" == *=* ]]; do envs+=("$1"); shift; done
  out="$(env -u XUM_ROOT -u MUX_ROOT PATH="$TMP/bin:$PATH" "${envs[@]}" "$CHECK" "$@" 2>&1)" || rc=$?
  if [ "$rc" = "$want" ] && grep -qE "$pattern" <<< "$out"; then
    echo "PASS $name"; pass=$((pass+1))
  else
    echo "FAIL $name: exit $rc, want $want and /$pattern/"; printf '%s\n' "$out" | head -5 | cut -c1-200; fail=$((fail+1))
  fi
}

H="$TMP/xum-only"; installed_tree "$H/.xum"; upstream_from "$H/.xum"
run_case "reads ~/.xum and strips .git from the source URL" 0 "^summary: .*, registry $H/.xum/plugins.json, drift=0\$" HOME="$H"

H="$TMP/mux-only"; installed_tree "$H/.mux"; upstream_from "$H/.mux"
run_case "falls back to ~/.mux on older installs" 0 "^summary: .*, registry $H/.mux/plugins.json, drift=0\$" HOME="$H"

H="$TMP/both"; installed_tree "$H/.xum"; upstream_from "$H/.xum"; installed_tree "$H/.mux"
echo extra >> "$H/.mux/plugins/$EDIT_PLUGIN/$EDIT_PATH"
run_case "prefers ~/.xum over ~/.mux" 0 '^summary: .* drift=0$' HOME="$H"

H="$TMP/root"; installed_tree "$H/custom"; upstream_from "$H/custom"
installed_tree "$H/other"; echo extra >> "$H/other/plugins/$EDIT_PLUGIN/$EDIT_PATH"; cp -r "$H/other" "$H/.xum"
run_case "XUM_ROOT wins over ~/.xum" 0 "registry $H/custom/plugins.json, drift=0\$" HOME="$H" XUM_ROOT="$H/custom"
run_case "MUX_ROOT wins over ~/.xum" 0 "registry $H/custom/plugins.json, drift=0\$" HOME="$H" MUX_ROOT="$H/custom"
run_case "XUM_ROOT wins over MUX_ROOT" 0 "registry $H/custom/plugins.json, drift=0\$" HOME="$H" XUM_ROOT="$H/custom" MUX_ROOT="$H/other"

for url in "https://github.com/test/@NAME@" "https://github.com/test/@NAME@/" "git@github.com:test/@NAME@.git" "ssh://git@github.com/test/@NAME@.git"; do
  H="$TMP/url-$((pass+fail))"; installed_tree "$H/.xum" "$url"; upstream_from "$H/.xum"
  run_case "accepts source URL $url" 0 '^summary: .* drift=0$' HOME="$H"
done

H="$TMP/changed"; installed_tree "$H/.xum"; upstream_from "$H/.xum"
echo extra >> "$H/.xum/plugins/$EDIT_PLUGIN/$EDIT_PATH"
run_case "reports an upstream change" 1 "^CHANGED $EDIT_PLUGIN $EDIT_PATH " HOME="$H"

run_case "fails without any Xum home" 2 'ERR no plugins.json' HOME="$TMP/empty"
run_case "reports a bad argument before a missing home" 2 '^usage: ' HOME="$TMP/empty" --bogus

H="$TMP/accept"; installed_tree "$H/.xum"; ln -s "$H/.xum" "$H/.mux"
mkdir -p "$H/.xum/plugins/personal-plugins/skills"; cp -r "$SKILL_DIR" "$H/.xum/plugins/personal-plugins/skills/thomas-mode"
CHECK="$H/.mux/plugins/personal-plugins/skills/thomas-mode/scripts/check-drift.sh"
run_case "--accept warns when the script path goes through a link" 0 '^WARN .* is an installed plugin copy' HOME="$H" --accept
CHECK="$H/.xum/plugins/personal-plugins/skills/thomas-mode/scripts/check-drift.sh"
run_case "--accept warns when the Xum home goes through a link" 0 '^WARN .* is an installed plugin copy' HOME="$TMP/empty" MUX_ROOT="$H/.mux" --accept
CHECK="$SCRIPT_DIR/check-drift.sh"

echo "summary: $pass passed, $fail failed"
[ "$fail" = 0 ]
