---
name: inyo-theme-development
description: Use when 在 hugo-theme-inyo 仓库开发主题（改模板/CSS/token/发布）。
metadata:
  category: software-development
---

# Inyo Theme Development

## Overview

Inyo 陰陽 是纸墨二元 Hugo 主题（开源 `hugo-theme-inyo`），v3 为顶部导航 + 右侧身份栏的 pianpker 式布局，默认霞鹜文楷。本技能保证所有改动符合根目录 `DESIGN.md`。

## 铁律（从 DESIGN.md 抄录，逐条执行）

1. **颜色禁止硬编码**——必须使用 `assets/css/main.css` 的 CSS 变量 token（`--paper` / `--ink` / `--cinnabar` / `--camel` / `--indigo` 等）。新增颜色先查 `DESIGN.md` §2，正文实测 WCAG 对比度 ≥4.5:1，大文本 ≥3:1。
2. **三条使用纪律**（DESIGN.md §2.3，实测约束）：
   - 墨色 `#1D1B1C` 上正文/链接全角色过 AA（月白 13.80 / 朱红 4.74 / 晓灰 10.10）
   - 暗色抬升面（`--paper-2` `#322F31`）上的链接必须用舌红 `#F19790`（朱红 on 抬升面 3.66 不达标）
   - 浅档（t≥0.55 `#888185` 及以上）只做弱化文字/边框/装饰，禁止放正文链接
3. **正文永远横排**；竖排（`writing-mode: vertical-rl`）禁止用于正文、导航、页脚，装饰性竖排已整体移除（v2）。
4. **双模式对称**：新样式必须同时提供亮（纸）和暗（墨）取值，暗色覆盖放在 `[data-theme="dark"]`。
5. **零 JS 依赖**：主题切换是唯一允许的内联脚本。

## 文件结构

```text
layouts/{_default,partials,shortcodes}/
assets/css/main.css
static/img/{seal-yang.svg,seal-yin.svg}
i18n/{en.toml,zh-cn.toml,ja.toml}
.pi/skills/xxd-*/
exampleSite/
```

## 布局蒸馏

- 保留 Inyo 当前 `40em` 阅读栏与全部既有颜色 token；外部主题只参考布局机制，不复制配色、框架或交互。
- v3 布局为顶部导航（首页/文章/标签/关于 + 诗句占位）+ 右侧固定身份栏（18em sticky，pianpker 式）+ 左中内容区；≤768px 顶部导航保持、身份栏折叠为紧凑头部。
- 目录/列表条目：标题 + 日期/阅读时间（更纱黑体），有 `description` 才显示一行摘要；移动端不隐藏摘要。
- TOC 默认留在正文流内；侧栏只承载导航，不承担 TOC。
- 集合页必须分别处理零篇、一篇和多篇内容，不能只验证理想数据量。
- 目录禁止用卡片、重复边框或额外强调色堆砌；分隔用细线 `--border` 与留白。
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
- [ ] 浏览器实测亮/暗切换，`body` 背景分别为 `#F8F4F0` / `#1D1B1C`。
- [ ] 印章颜色为品牌固定色 `#D92121`（白文印朱砂底白字），双模式不变。
- [ ] 所有新色均有 `DESIGN.md` 记录和对比度实测值。
