# Theme toggle

The "Theme toggle" rule in `SKILL.md` points here. Copy the three blocks below into the page. They are tested together: change them only when you test the page again.

## Markup

Put it at the right end of the top bar. With no top bar, put it in a header row at the top right, in the page flow, not over the content. This is the product look. In the brand look, drop the `ck-segmented` and `ck-segment` classes.

```html
<div class="ck-segmented theme-toggle" role="tablist" aria-label="Theme" data-theme-toggle>
  <button class="ck-segment" role="tab" data-theme-set="auto" aria-selected="true">Auto</button>
  <button class="ck-segment" role="tab" data-theme-set="light" aria-selected="false">Light</button>
  <button class="ck-segment" role="tab" data-theme-set="dark" aria-selected="false">Dark</button>
</div>
```

## CSS

Light and Dark set `data-theme` on `<body>`, so define page colors and the page background on `body`. A value set on `:root` or `html` keeps the host's theme. Mark each light and dark pair of assets, such as baked Mermaid SVGs, with `only-light` and `only-dark`.

```css
body { min-height: 100vh; margin: 0; background: var(--coder-bg); color: var(--coder-fg); font-family: var(--coder-font-sans); }
.theme-toggle:not(.ck-segmented) { display: inline-flex; gap: 2px; padding: 3px; border: 1px solid var(--coder-line); border-radius: 8px; background: var(--coder-surface); }
.theme-toggle:not(.ck-segmented) button { padding: 6px 12px; border: 0; border-radius: 6px; background: none; color: var(--coder-muted); font: inherit; cursor: pointer; }
.theme-toggle:not(.ck-segmented) button[aria-selected="true"] { background: var(--coder-bg); color: var(--coder-fg); }
body[data-theme="light"] .only-dark, body[data-theme="dark"] .only-light,
:root[data-xum-theme="light"] body:not([data-theme]) .only-dark,
:root[data-xum-theme="dark"] body:not([data-theme]) .only-light { display: none; }
@media (prefers-color-scheme: light) { :root:not([data-xum-theme]) body:not([data-theme]) .only-dark { display: none; } }
@media (prefers-color-scheme: dark) { :root:not([data-xum-theme]) body:not([data-theme]) .only-light { display: none; } }
```

## Script

Put it at the end of `<body>`. It follows clicks and the arrow keys of `coder-kit.js`, which move the selection without a click. In Xum, whose frame has no storage, it saves the choice in `window.xum.state`. A republished version starts empty. Elsewhere it uses `localStorage`.

```js
(() => {
  const toggle = document.querySelector("[data-theme-toggle]");
  const segs = toggle ? [...toggle.querySelectorAll("[data-theme-set]")] : [];
  const root = document.documentElement, body = document.body;
  const os = matchMedia("(prefers-color-scheme: dark)");
  const xum = window.xum && typeof window.xum.setState === "function" ? window.xum : null;
  let choice = null, shown = null;
  const load = () => { try { return xum ? (xum.state || {}).theme : localStorage.getItem("artifact-theme"); } catch { return null; } };
  const save = (v) => { try { if (xum) xum.setState({ ...(xum.state || {}), theme: v }); else localStorage.setItem("artifact-theme", v); } catch {} };
  const current = () => body.dataset.theme || root.dataset.xumTheme || (os.matches ? "dark" : "light");
  function announce() {
    const t = current();
    if (t === shown) return;
    shown = t;
    document.dispatchEvent(new CustomEvent("themechange", { detail: { theme: t } }));
  }
  function apply(v, persist) {
    if (v !== "light" && v !== "dark") v = "auto";
    if (v === choice) return;
    choice = v;
    if (v === "auto") delete body.dataset.theme; else body.dataset.theme = v;
    for (const s of segs) if (s.getAttribute("aria-selected") !== String(s.dataset.themeSet === v)) s.setAttribute("aria-selected", String(s.dataset.themeSet === v));
    if (persist) save(v);
    announce();
  }
  window.artifactTheme = current;
  for (const s of segs) s.addEventListener("click", () => apply(s.dataset.themeSet, true));
  if (toggle) new MutationObserver(() => {
    const s = segs.find((x) => x.getAttribute("aria-selected") === "true");
    if (s) apply(s.dataset.themeSet, true);
  }).observe(toggle, { subtree: true, attributeFilter: ["aria-selected"] });
  new MutationObserver(announce).observe(root, { attributeFilter: ["data-xum-theme"] });
  addEventListener("xumthemechange", announce);
  os.addEventListener("change", announce);
  apply(load(), false);
})();
```

## The rest of the page

- A script that picks colors (code highlighting, Mermaid, charts) draws with `artifactTheme()`, which returns `"light"` or `"dark"`. It draws again on each `themechange` event on `document`. The event fires on a choice, and in Auto when the host or the OS theme changes.
- Every other `window.xum.setState` call on the page keeps the `theme` key: `xum.setState({ ...xum.state, ...yours })`. `setState` replaces the whole object.

## Check

Before you publish, check the three choices under a light and a dark host: six states. To set the host, set `data-xum-theme` on `<html>`. The script follows that attribute, so no event is needed. For each Auto state, also set the OS theme to the opposite of the host (`agent-browser set media`), so that a page that follows the OS instead of the host fails. Also remove the attribute and check Auto under a light and a dark OS. Then move the choice with an arrow key, and reload to see it restored. In Xum, the other keys in `window.xum.state` must survive. `scripts/test-theme-toggle.sh` runs all of these on the snippet alone.
