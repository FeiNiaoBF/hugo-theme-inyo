# AGENTS.md — Inyo 陰陽 编码规范

给 AI 编码代理与本仓库协作者的规范。所有改动必须与 DESIGN.md 一致。

## 铁律

1. **颜色禁止硬编码**：任何颜色必须来自 `assets/css/main.css` 的 CSS 变量 token（`--paper` / `--ink` / `--cinnabar` / `--camel` / `--indigo` / `--srf-*` 等）。新增颜色前必须查 DESIGN.md §2 色表；新色必须实测 WCAG 对比度 ≥4.5:1（正文）/ ≥3:1（大文本），并在 DESIGN.md 记录
2. **三条使用纪律**（DESIGN.md §2.3，实测约束）：
   - 墨色 `#1D1B1C` 上正文/链接全角色过 AA（月白 13.80 / 朱红 4.74 / 晓灰 10.10）
   - 暗色抬升面（`--paper-2` `#322F31`）上的链接必须用舌红 `#F19790`（朱红 on 抬升面 3.66 不达标）
   - 浅档（t≥0.55 `#888185` 及以上）只做弱化文字/边框/装饰，禁止放正文链接
3. **正文永远横排**：竖排（`writing-mode: vertical-rl`）禁止用于正文、导航、页脚；装饰性竖排已整体移除（v2）
4. **零 JS 依赖**：主题切换是唯一允许的内联脚本；不要引入框架
5. **双模式对称**：新增样式必须同时给出亮（纸）和暗（墨）两套取值，走 `[data-theme="dark"]` 覆盖

## 技术栈约束

- Hugo（Hugo Modules 分发），模板语法 Go template
- CSS：原生 CSS + 变量，无预处理器
- 字体：霞鹜文楷（默认，OFL 开源）/ 思源宋体（可选 `font="serif"`）/ 更纱黑体（代码与元信息），全部 OFL 开源
- 数学：KaTeX 通过 `params.math` 开关，CDN 加载；博客侧 goldmark 配置不归主题管

## 文件结构

- `DESIGN.md` — 设计 token 权威来源，改设计先改这里
- `assets/css/main.css` — 唯一样式文件（token 段 + 组件段）
- `layouts/` — baseof / index / single / list / partials / shortcodes
- `static/img/` — 印章 SVG
- `exampleSite/` — 本地验证站，改动必须跑 `hugo server --source exampleSite` 验证

## 提交规范

- 中文或英文提交信息均可，前缀惯例：`feat:` `fix:` `docs:` `design:` `style:`
- 提交前跑 `hugo --source exampleSite --minify` 确认构建通过
- 涉及配色的提交必须附对比度数据

## 验证清单

```bash
cd exampleSite && hugo mod tidy && hugo server
# 检查: 亮/暗两模式切换、右侧导航栏、目录首页、文章页排版、代码块、表格、标签章
```
