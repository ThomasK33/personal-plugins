#!/usr/bin/env bash
# Tests the snippet in references/theme-toggle.md in a real browser: it builds pages from the
# file's html, css and js blocks (product and brand look; plain, with a fake window.xum, and with
# storage that throws),
# then checks each choice under each host and OS (background, text color, assets, selection),
# themechange events, arrow keys, buttons, and saved state in localStorage and a fake window.xum.
# Needs agent-browser and the coder-brand skill (CODER_BRAND_DIR). Prints one line per check
# and a final COUNT line; exits 1 on any failure.
set -uo pipefail
HERE=$(cd "$(dirname "$0")/.." && pwd)
KB=${CODER_BRAND_DIR:-$HOME/.xum/plugins/fux-plugins/skills/coder-brand}
[ -f "$KB/kit/coder-kit.css" ] || { echo "ERR coder-brand not found at $KB (set CODER_BRAND_DIR)"; exit 2; }
command -v agent-browser >/dev/null || { echo "ERR agent-browser not found"; exit 2; }
D=$(mktemp -d)
export AGENT_BROWSER_SESSION=theme-toggle-$$
# Keep the session's files (agent-browser leaves <session>.config after close) in $D, which the trap deletes.
export AGENT_BROWSER_SOCKET_DIR="$D/ab"
trap 'agent-browser close >/dev/null 2>&1; rm -rf "$D"' EXIT
python3 - "$HERE/references/theme-toggle.md" "$KB" "$D" <<'PY'
import re, sys
md, kb, out = sys.argv[1:]
found = re.findall(r"```(html|css|js)\n(.*?)```", open(md).read(), re.S)
assert sorted(l for l, _ in found) == ["css", "html", "js"], "need exactly one html, css and js block"
b = dict(found)
fake = """<script>
let __s = JSON.parse(new URLSearchParams(location.search).get('state') || 'null');
window.xum = { get state() { return __s ? JSON.parse(JSON.stringify(__s)) : null; },
  setState(n) { __s = JSON.parse(JSON.stringify(n)); window.__setCalls = (window.__setCalls || 0) + 1; } };
</script>"""
nostore = """<script>
Object.defineProperty(window, 'localStorage', { get() { throw new DOMException('denied', 'SecurityError'); } });
</script>"""
for look in ("product", "brand"):
    for xum in ("", "-xum", "-nostore"):
        head = (f'<link rel="stylesheet" href="{kb}/kit/coder-kit.css"><script src="{kb}/kit/coder-kit.js"></script>'
                if look == "product" else f'<link rel="stylesheet" href="{kb}/tokens/coder-brand.css">')
        mark = b["html"] if look == "product" else b["html"].replace(' class="ck-segmented theme-toggle"', ' class="theme-toggle"').replace(' class="ck-segment"', '')
        page = f"""<!doctype html><html><head><meta charset=utf-8>{head}<style>{b['css']}</style><script>window.__errors = []; addEventListener('error', e => window.__errors.push(String(e.message)));</script>{fake if xum == '-xum' else nostore if xum == '-nostore' else ''}</head>
<body{' class="ck-page"' if look == 'product' else ''}><form onsubmit="window.__submitted = 1; return false"><header style="display:flex;justify-content:space-between"><b>Test</b>{mark}</header></form>
<p class="only-light" id="L">light</p><p class="only-dark" id="D">dark</p>
<script>window.__events = []; document.addEventListener('themechange', e => window.__events.push(e.detail.theme));</script>
<script>{b['js']}</script></body></html>"""
        open(f"{out}/{look}{xum}.html", "w").write(page)
PY
pass=0; fail=0
ab(){ local out; if ! out=$(agent-browser "$@" 2>&1); then echo "ERR agent-browser $1: $out" >&2; echo "$1" >> "$D/errors"; fi; printf '%s\n' "$out"; }
ev(){ ab eval "$1" | tail -1 | sed 's/^"//;s/"$//'; }
chk(){ # name expected actual
  if [ "$2" = "$3" ]; then pass=$((pass+1)); echo "PASS $1"; else fail=$((fail+1)); echo "FAIL $1 expected=$2 got=$3"; fi; }
# STATE: background theme, theme implied by the text color (dark text = light), artifactTheme(), visible asset, selected choice.
STATE='(()=>{const c=getComputedStyle(document.body).backgroundColor.match(/[\d.]+/g).map(Number);const lum=(0.2126*c[0]+0.7152*c[1]+0.0722*c[2])/255;const vis=id=>getComputedStyle(document.getElementById(id)).display!=="none";const sel=[...document.querySelectorAll("[data-theme-set]")].filter(s=>s.getAttribute("aria-selected")==="true").map(s=>s.dataset.themeSet).join("+");const f=getComputedStyle(document.body).color.match(/[\d.]+/g).map(Number);const flum=(0.2126*f[0]+0.7152*f[1]+0.0722*f[2])/255;return [lum<0.5?"dark":"light",flum<0.5?"light":"dark",artifactTheme(),vis("L")&&!vis("D")?"light":(vis("D")&&!vis("L")?"dark":"both"),sel].join(",")})()'
opp(){ [ "$1" = light ] && echo dark || echo light; }
for look in product brand; do
  ab set media light >/dev/null; ab open "file://$D/$look.html" >/dev/null
  ev 'localStorage.clear()' >/dev/null; ab reload >/dev/null
  chk "$look one themechange at load" "light" "$(ev 'window.__events.join("|")')"
  chk "$look buttons are type=button" "button,button,button" "$(ev '[...document.querySelectorAll("[data-theme-set]")].map(b=>b.type).join(",")')"
  for host in light dark; do
    ab set media "$(opp $host)" >/dev/null
    ev "document.documentElement.dataset.xumTheme='$host'" >/dev/null
    for choice in auto light dark; do
      ev "document.querySelector('[data-theme-set=$choice]').click()" >/dev/null
      exp=$([ $choice = auto ] && echo $host || echo $choice)
      chk "$look host=$host os=$(opp $host) choice=$choice" "$exp,$exp,$exp,$exp,$choice" "$(ev "$STATE")"
    done
  done
  chk "$look roving tabindex" "-1,-1,0" "$(ev '[...document.querySelectorAll("[data-theme-set]")].map(b=>b.tabIndex).join(",")')"
  chk "$look clicks submit no form" "none" "$(ev 'String(window.__submitted||"none")')"
  ev "document.querySelector('[data-theme-set=auto]').click(); window.__events.length=0" >/dev/null
  ab set media dark >/dev/null; sleep 0.3
  chk "$look auto ignores OS change under a host" "" "$(ev 'window.__events.join("|")')"
  ab set media light >/dev/null; sleep 0.3
  ev "document.querySelector('[data-theme-set=auto]').click(); delete document.documentElement.dataset.xumTheme" >/dev/null
  for os in light dark; do
    ab set media $os >/dev/null; sleep 0.3
    chk "$look no-host os=$os choice=auto" "$os,$os,$os,$os,auto" "$(ev "$STATE")"
  done
  ev "window.__events.length=0" >/dev/null; ab set media light >/dev/null; sleep 0.3
  ab set media dark >/dev/null; sleep 0.3
  chk "$look auto OS change fires themechange" "light|dark" "$(ev 'window.__events.join("|")')"
  ab set media light >/dev/null; ev "document.documentElement.dataset.xumTheme='light'" >/dev/null; sleep 0.3
  ev "window.__events.length=0; for (const v of ['dark','light','auto']) document.querySelector('[data-theme-set='+v+']').click()" >/dev/null; sleep 0.2
  chk "$look choices fire themechange only when the shown theme changes" "dark|light" "$(ev 'window.__events.join("|")')"
  ev "window.__events.length=0" >/dev/null
  ev "document.documentElement.dataset.xumTheme='dark'" >/dev/null; sleep 0.2
  chk "$look auto host change fires themechange" "dark" "$(ev 'window.__events.join("|")')"
  ev "document.querySelector('[data-theme-set=dark]').click(); window.__events.length=0; document.documentElement.dataset.xumTheme='light'" >/dev/null; sleep 0.2
  chk "$look dark choice ignores host change" "" "$(ev 'window.__events.join("|")')"
  ev "document.querySelector('[data-theme-set=light]').click(); document.documentElement.dataset.xumTheme='light'" >/dev/null; sleep 0.2
  ev "window.__events.length=0; document.documentElement.dataset.xumTheme='dark'" >/dev/null; sleep 0.2
  chk "$look light choice ignores host change" ",light" "$(ev '[window.__events.join("|"), artifactTheme()].join(",")')"
  ev "delete document.documentElement.dataset.xumTheme" >/dev/null; ab set media dark >/dev/null; sleep 0.3
  chk "$look light choice ignores OS change" ",light" "$(ev '[window.__events.join("|"), artifactTheme()].join(",")')"
  ev "document.querySelector('[data-theme-set=dark]').click(); window.__events.length=0" >/dev/null
  ab set media light >/dev/null; sleep 0.3
  chk "$look dark choice ignores OS change" ",dark,dark" "$(ev '[window.__events.join("|"), artifactTheme(), document.body.dataset.theme].join(",")')"
  ab reload >/dev/null
  chk "$look localStorage keeps choice after reload" "dark,dark" "$(ev '[document.body.dataset.theme, [...document.querySelectorAll("[data-theme-set]")].find(s=>s.getAttribute("aria-selected")==="true").dataset.themeSet].join(",")')"
done
# arrow keys, both looks (the product page also loads coder-kit.js)
SEL='[...document.querySelectorAll("[data-theme-set]")].find(s=>s.getAttribute("aria-selected")==="true").dataset.themeSet'
for look in product brand; do
ab open "file://$D/$look.html" >/dev/null; ev 'localStorage.clear()' >/dev/null; ab reload >/dev/null
chk "$look nothing saved starts in auto" "auto,auto" "$(ev "[document.body.dataset.theme||'auto', $SEL].join(',')")"
ev 'localStorage.setItem("artifact-theme","bogus")' >/dev/null; ab reload >/dev/null
chk "$look bad saved value starts in auto" "auto,auto" "$(ev "[document.body.dataset.theme||'auto', $SEL].join(',')")"
ab focus '[data-theme-set=auto]' >/dev/null; ab press ArrowRight >/dev/null; sleep 0.2
chk "$look arrow key selects light" "light" "$(ev 'document.body.dataset.theme||"auto"')"
ab reload >/dev/null
chk "$look arrow choice light kept after reload" "light,light" "$(ev "[document.body.dataset.theme||'auto', $SEL].join(',')")"
ab focus '[data-theme-set=light]' >/dev/null; ab press ArrowRight >/dev/null; sleep 0.2
chk "$look arrow key selects dark" "dark" "$(ev 'document.body.dataset.theme||"auto"')"
ab focus '[data-theme-set=dark]' >/dev/null; ab press ArrowLeft >/dev/null; ab press ArrowLeft >/dev/null; sleep 0.2; ab reload >/dev/null
chk "$look arrow choice auto kept after reload" "auto,auto" "$(ev "[document.body.dataset.theme||'auto', $SEL].join(',')")"
ab focus '[data-theme-set=auto]' >/dev/null; ab press ArrowLeft >/dev/null; sleep 0.2
chk "$look ArrowLeft from auto wraps to dark" "dark,dark" "$(ev "[document.body.dataset.theme||'auto', document.activeElement.dataset.themeSet].join(',')")"
ab press ArrowRight >/dev/null; sleep 0.2
chk "$look ArrowRight from dark wraps to auto" "auto,auto" "$(ev "[document.body.dataset.theme||'auto', document.activeElement.dataset.themeSet].join(',')")"
chk "$look arrow key default is prevented" "true" "$(ev 'String(!document.activeElement.dispatchEvent(new KeyboardEvent("keydown",{key:"ArrowRight",bubbles:true,cancelable:true})))')"
done
# Xum state (fake window.xum)
for look in product brand; do
  ab open "file://$D/$look-xum.html?state=%7B%22answers%22%3A1%7D" >/dev/null
  ev "document.querySelector('[data-theme-set=dark]').click()" >/dev/null; sleep 0.2
  chk "$look xum state merged" '{\"answers\":1,\"theme\":\"dark\"}' "$(ev 'JSON.stringify(window.xum.state)')"
  chk "$look one setState per click" "1" "$(ev 'String(window.__setCalls)')"
  ev "document.querySelector('[data-theme-set=light]').click()" >/dev/null; sleep 0.2
  chk "$look xum saves light" "light" "$(ev 'window.xum.state.theme')"
  ev "document.querySelector('[data-theme-set=auto]').click()" >/dev/null; sleep 0.2
  chk "$look xum saves auto" "auto" "$(ev 'window.xum.state.theme')"
  ev "window.xum.setState({ ...window.xum.state, answers: 2, later: 'x' }); document.querySelector('[data-theme-set=dark]').click()" >/dev/null; sleep 0.2
  chk "$look xum keeps keys set after load" "2,x,dark" "$(ev '[window.xum.state.answers, window.xum.state.later, window.xum.state.theme].join(",")')"
  for v in light dark auto; do
    ab open "file://$D/$look-xum.html?state=%7B%22answers%22%3A1%2C%22theme%22%3A%22$v%22%7D" >/dev/null; sleep 0.2
    chk "$look xum state restores $v without saving" "$v,$v,undefined" "$(ev '[document.body.dataset.theme||"auto",[...document.querySelectorAll("[data-theme-set]")].find(s=>s.getAttribute("aria-selected")==="true").dataset.themeSet,String(window.__setCalls)].join(",")')"
  done
  ab open "file://$D/$look-nostore.html" >/dev/null; sleep 0.2
  ev "document.querySelector('[data-theme-set=dark]').click()" >/dev/null; sleep 0.2
  chk "$look works when storage throws" "dark,0" "$(ev '[document.body.dataset.theme, window.__errors.length].join(",")')"
done
errs=0; [ -f "$D/errors" ] && errs=$(wc -l < "$D/errors")
fail=$((fail+errs))
echo "COUNT pass=$pass fail=$fail browser_errors=$errs"; [ "$fail" -eq 0 ]
