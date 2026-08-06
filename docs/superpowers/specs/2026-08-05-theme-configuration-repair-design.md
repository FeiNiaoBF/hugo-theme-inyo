# Theme Configuration Repair Design

## Context

Inyo advertises configurable typography, footer text, and seal appearance. The current public contract is inconsistent:

- Templates and `exampleSite/hugo.toml` use flat snake-case parameters.
- `README.md` documents nested footer and seal parameters.
- `font` is declared but has no effect.
- `seal_text` is read by the template but not rendered.

A copied README configuration therefore does not produce the documented theme.

## Decision

Keep the existing flat parameter contract because it is already used by the templates and example site:

```toml
[params]
font = "serif"
webfonts = true
vertical_footer = ""
seal_text = "陰陽"
seal_style = "yang"
```

Implement the two currently broken parameters:

- `font = "serif"` uses the existing serif stack.
- `font = "wenkai"` selects the LXGW WenKai stack.
- `seal_text` supplies the inline SVG text for both yin and yang seal styles.

Update `README.md` to document these exact names. Preserve current defaults and avoid compatibility aliases because the repository has no released legacy contract.

## Alternatives Considered

### Adopt nested parameters

Nested `vertical.footer` and `seal.text/style` are visually organized, but adopting them would require changing all working templates and the example configuration. This adds migration complexity without user evidence.

### Remove the broken options

Removing `font` and `seal_text` would reduce code, but both are part of the accepted design and theme identity. Their implementations are small and earn their place.

## Scope

Modify only the files needed for this contract:

- `layouts/_default/baseof.html`
- `layouts/partials/head.html`
- `layouts/partials/seal.html`
- `assets/css/main.css`
- `README.md`
- `exampleSite/hugo.toml` only if an explicit demonstration value is needed

Do not address printing, syntax highlighting, broader accessibility, layout, or release automation in this milestone.

## Verification

Build the example site outside the repository and inspect generated output. Verify:

1. The default configuration builds without Hugo warnings.
2. `font = "wenkai"` produces the WenKai selector and font resource.
3. A non-default `seal_text` value appears in generated SVG text.
4. Yin and yang seal styles both use the configured text.
5. `README.md`, theme defaults, example configuration, and template parameter names agree.
6. The Git diff contains no unrelated `skills/` files or other user work.
