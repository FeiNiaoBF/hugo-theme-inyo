# Theme Configuration Repair Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Inyo's documented font, footer, and seal parameters match generated Hugo output.

**Architecture:** Keep the existing flat `params` API. Expose the selected font as an HTML data attribute, let CSS select the typography stack, and conditionally load only the webfont resources required by that selection. Render `seal_text` through the existing inline SVG partial.

**Tech Stack:** Hugo 0.140+, Go templates, native CSS, Google Fonts, pinned jsDelivr webfont CSS.

## Global Constraints

- Preserve the flat parameters `font`, `webfonts`, `vertical_footer`, `seal_text`, and `seal_style`.
- Keep `serif` as the default font and support `wenkai` as the only alternate value.
- Do not add JavaScript, frameworks, package dependencies, or compatibility aliases.
- Do not modify the unrelated `.gitignore` working-tree change.
- Do not address print, syntax highlighting, layout, or broader accessibility issues in this milestone.

---

### Task 1: Make font and seal parameters affect generated HTML

**Files:**
- Modify: `layouts/_default/baseof.html`
- Modify: `layouts/partials/head.html`
- Modify: `layouts/partials/seal.html`
- Modify: `assets/css/main.css`

**Interfaces:**
- Consumes: `site.Params.font`, `site.Params.webfonts`, `site.Params.seal_text`, `site.Params.seal_style`
- Produces: `<html data-font="serif|wenkai">`, conditional webfont links, configured SVG seal text

- [x] **Step 1: Reproduce the broken contract**

Build with a temporary merged config containing `font = "wenkai"`, `seal_text = "纸墨"`, and each seal style. A merged config is required because underscores in Hugo environment variable names represent nested keys rather than literal flat parameter names.

```bash
cat > "$TEMP/pi-agent/inyo-repro.toml" <<'EOF'
[params]
font = "wenkai"
seal_text = "纸墨"
seal_style = "yang"
EOF
hugo --source exampleSite \
  --config "hugo.toml,$(cygpath -w "$TEMP/pi-agent/inyo-repro.toml")" \
  --destination "$TEMP/pi-agent/inyo-before" \
  --cacheDir "$TEMP/pi-agent/inyo-cache" --minify
```

Expected before repair: generated `index.html` does not contain `data-font=wenkai` and SVG text remains hardcoded instead of using `纸墨`.

- [x] **Step 2: Expose the selected font**

Derive the value before the root element and render it as a data attribute:

```go-html-template
{{ $font := cond (eq site.Params.font "wenkai") "wenkai" "serif" }}
<!DOCTYPE html>
<html lang="{{ site.Language.Locale | default "zh-cn" }}" data-theme="light" data-font="{{ $font }}">
```

- [x] **Step 3: Load only the selected webfont**

In `head.html`, keep `webfonts = false` as the opt-out. Load pinned LXGW WenKai regular and bold CSS from jsDelivr for `wenkai`; otherwise load Noto Serif SC weights 400, 700, and 900 from Google Fonts.

- [x] **Step 4: Select the WenKai CSS stack**

Add a dedicated stack and override the existing semantic `--font-serif` token:

```css
--font-wenkai: 'LXGW WenKai', 'KaiTi', 'STKaiti', serif;

[data-font="wenkai"] {
  --font-serif: var(--font-wenkai);
}
```

- [x] **Step 5: Render configured seal text**

Replace both hardcoded `陰陽` SVG text nodes with the existing escaped `$text` template value and inherit the selected typography.

- [x] **Step 6: Verify both variants**

Build serif/yang and wenkai/yin variants outside the repository. Assert their generated HTML contains the expected data attribute, font stylesheet, and seal text. Run `git diff --check`.

### Task 2: Align user documentation with the working contract

**Files:**
- Modify: `README.md`

**Interfaces:**
- Consumes: the parameter behavior delivered by Task 1
- Produces: one copyable TOML configuration example matching Hugo templates

- [x] **Step 1: Replace stale nested keys**

Document this exact configuration:

```toml
[params]
font = "wenkai"
math = true
webfonts = true
vertical_footer = "行到水穷处"
seal_text = "陰陽"
seal_style = "yang"
```

- [x] **Step 2: Verify contract consistency**

Search `README.md`, `hugo.toml`, `exampleSite/hugo.toml`, and `layouts/` for all five parameter names. Confirm no nested `vertical.footer` or `seal.text/style` example remains.

- [x] **Step 3: Run final verification**

Run the production example build outside the repository, inspect the focused diff, and confirm `.gitignore` remains unstaged and unchanged by this work.
