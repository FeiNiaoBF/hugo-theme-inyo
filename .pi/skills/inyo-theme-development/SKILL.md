---
name: inyo-theme-development
description: Use when 在 hugo-theme-inyo 仓库开发主题（改模板/CSS/token/发布）。
metadata:
  category: software-development
---

# Inyo Theme Development

## Overview

Inyo 陰陽 是纸墨二元 Hugo 主题（开源 `hugo-theme-inyo`）。本技能保证所有改动符合根目录 `DESIGN.md`。

## 铁律（从 DESIGN.md 抄录，逐条执行）

1. **颜色禁止硬编码**——必须使用 `assets/css/main.css` 的 CSS 变量 token（`--paper` / `--ink` / `--cinnabar` / `--camel` / `--indigo` 等）。新增颜色先查 `DESIGN.md` §2，正文实测 WCAG 对比度 ≥4.5:1，大文本 ≥3:1。
2. **三条使用纪律**：
   - 松烟墨 `#3B3A3E` 禁作剑锋紫辅助面（ΔL=0.0006，不可辨）。
   - 卡片面（t=0.08，`#4C454D`）上的链接必须使用粉红 `#F2B9B2`，或压深卡片。
   - t≥0.20 的浅档（`#62595F` 及以上）只做背景、边框或分隔，禁止放文字。
3. **正文永远横排**；竖排（`writing-mode: vertical-rl`）只允许用于 `.tategaki` 装饰类。
4. **双模式对称**：新样式必须同时提供亮（纸）和暗（墨）取值，暗色覆盖放在 `[data-theme="dark"]`。
5. **零 JS 依赖**：主题切换是唯一允许的内联脚本。

## 文件结构

```text
layouts/{_default,partials,shortcodes}/
assets/css/main.css
static/img/{seal-yang.svg,seal-yin.svg,brush.svg}
i18n/{en.toml,zh-cn.toml,ja.toml}
.pi/skills/xxd-*/
exampleSite/
```

## 布局蒸馏

- 保留 Inyo 当前 `40em` 阅读栏与全部既有颜色 token；外部主题只参考布局机制，不复制配色、框架或交互。
- 文章列表可在桌面端内联日期等元信息，并按真实内容需要显示摘要；移动端堆叠元信息并隐藏摘要，降低信息密度。
- TOC 默认留在正文流内；只有超宽屏确有空间时，才允许使用纯 CSS 侧栏布局。
- 不引入固定全站侧栏、UnoCSS、视图过渡或额外 JavaScript，除非实际使用证明当前布局存在对应问题。
- 集合页必须分别处理零篇、一篇和多篇内容，不能只验证理想数据量。
- 首页可突出第一篇文章建立层级，但禁止用卡片、重复边框或额外强调色堆砌“特色文章”。
- 新的列表条目 partial 只在标记被复用或形成稳定职责边界后提取，避免为单次调用制造碎片。
- 需要用户定制时，优先提供小型 Hugo 覆盖 partial；不要为每个视觉细节增加配置开关。

## 精确命令（低自由度，照抄执行）

```bash
# 构建验证
hugo --source exampleSite --minify

# 本地预览；验证后必须停止进程
hugo server --source exampleSite

# 模块整理
cd exampleSite && hugo mod tidy
```

## 常见坑（本项目实测）

- `--minify` 输出可能省略属性引号（如 `class=site-title`）；检查生成 HTML 时使用兼容有无引号的 `grep -E` 模式。
- `hugo.toml` 的模块导入使用 `[[module.imports]]` TOML 数组表；`hugo.yaml` 必须使用 YAML 列表，禁止混用两种语法。
- 本机 Git 代理 `127.0.0.1:7897` 可能未运行。获得用户明确 push 批准后，可用 `git -c http.proxy= push` 直连。
- Windows 的 CRLF 转换警告正常；先运行 `git diff --check`，没有空白错误即可。
- 主题切换有 0.25s 过渡；浏览器实测切换后等待至少 400ms，再读取 computed style。

## 发布流程

1. 运行完整验证清单。
2. 使用显式路径执行 `git add`，避免纳入无关工作。
3. 使用 `feat:`、`fix:`、`design:` 等前缀创建聚焦提交。
4. 仅在用户明确批准后执行 `git -c http.proxy= push`。
5. 稳定后按 Hugo 官方流程提交到主题市场。

## Hugo 官方文档

以下入口于 2026-08-05 验证可访问；`/themes/` 当前会重定向到 Hugo Modules 总览：

- 主题总览：https://gohugo.io/themes/
- 模板系统：https://gohugo.io/templates/
- 模板查找顺序：https://gohugo.io/templates/lookup-order/
- 主题组件：https://gohugo.io/hugo-modules/theme-components/
- Hugo Modules：https://gohugo.io/hugo-modules/use-modules/
- 新建主题命令：https://gohugo.io/commands/hugo_new_theme/
- 主题市场：https://themes.gohugo.io/
- 提交主题：https://gohugo.io/contribute/themes/

旧入口 `https://gohugo.io/tutorials/create-a-theme/` 已返回 404，不要引用。

## 验证清单

- [ ] `hugo --source exampleSite --minify` 构建通过。
- [ ] 浏览器实测亮/暗切换，`body` 背景分别为 `#F8F4F0` / `#3E3841`。
- [ ] 印章颜色在双模式下保持 `#D92121`。
- [ ] 所有新色均有 `DESIGN.md` 记录和对比度实测值。
