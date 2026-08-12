# Inyo 陰陽

> 纸墨二元 · 日式现代简约 × 古中国水墨 — Hugo 博客主题

**Inyo（陰陽）** 是一个为长文阅读设计的 Hugo 博客主题。亮色模式是墨在纸上（荼蘼白宣纸底 + 墨色正文），暗色模式是白墨在墨（墨色夜墨底 + 月白正文）。朱砂红是唯一的情绪色——像一枚印章盖在整个站点上。

当前发布基线：Inyo `v0.1.0`、Hugo Extended `>= 0.164.0`、Go `>= 1.26.1`。

## 特性

- 🌗 **纸墨双模式**：亮 = 荼蘼白宣纸，暗 = 墨色夜墨，10 行内联 JS 切换，零依赖
- 🖋️ **全站只有一个情绪色**：朱砂红（链接/印章/按钮），60/25/10/5 用色纪律
- 📖 **长文优先**：40em 容器、中文行高 2.0、标题字距拉开——东方式排版
- 🎨 **全部颜色出自《中华传统色》742 色库**：每个 token 有真实色名（荼蘼白、墨色、朱砂红、朱红、晓灰、云峰灰…），全部通过 WCAG AA 实测
- 🔖 **太极 Logo**：双鱼太极 + 朱砂环，几何验证面积对称，双模式可见
- 🧭 **右侧身份栏**（pianpker 式）：大字站名、气质签名、横排文字的纵向堆叠导航、社交链接（`/` 分隔）、语言切换、主题切换
- 🖌️ **诗句 Hero**（品牌交互）：首页横条显示“诗句 + 作者出处”，点击、触摸或键盘换句；两阶段反馈先让朱红双翼墨线沿圆角边框从底部中央向上行进并在顶部中央合墨，再在 API 或 fallback 就绪后完成落字
- 🧮 **数学公式开关**：`params.math = true` 启用 KaTeX（保留自带字体）
- 📐 **可定制**：全 CSS 变量 token 体系，改配色不用碰模板
- 🔤 **多语言**：i18n（zh-cn / en / ja）+ 语言切换器（Hugo 多语言站点自动显示）
- 📦 **自托管字体**：霞鹜文楷 unicode-range 分片（OFL 1.1）随主题分发，零 CDN 依赖、无字体闪烁
- 🔍 **SEO 元数据全家桶**：canonical / OpenGraph / Twitter Card / Person + BreadcrumbList JSON-LD / description 自动摘要兜底
- ♿ **可访问性 WCAG AA**：skip link、全局焦点环、`prefers-reduced-motion`、ARIA 状态
- 🧩 **内容系统**：标题锚点（hover 显示 #）、返回键、Hugo `.Summary` 优先的三行摘要（CJK=2/ASCII=1，140 全宽单位）、外链自动新窗口 + `rel="noopener noreferrer"`
- 📄 **404 页**：纸墨叙事的「四〇四」引导页
- ⚡ **性能**：图片懒加载（`loading=lazy` + LCP 首图保护）、首页脚本按页输出、字体防 FOUC、合成器属性动效

## 安装

### Hugo Modules（推荐）

要求：Hugo Extended `>= 0.164.0`；使用 Hugo Modules 时 Go `>= 1.26.1`。

新建站点先初始化模块：

```bash
hugo mod init example.org/my-site
hugo mod get github.com/FeiNiaoBF/hugo-theme-inyo
```

```toml
# hugo.toml
[module]
[[module.imports]]
path = "github.com/FeiNiaoBF/hugo-theme-inyo"
```

```bash
hugo mod tidy
```

主题通过 `config/_default/markup.toml` 默认使用 Hugo 的 class-based Chroma 输出。若站点同时自定义 `[markup]`（例如开启 Goldmark 原始 HTML），请保留 deep merge：

```toml
[markup]
_merge = "deep"

[markup.highlight]
noClasses = false
```

本地开发可用 `replace` 指向本地路径：

```toml
[module]
replacements = "github.com/FeiNiaoBF/hugo-theme-inyo -> ../hugo-theme-inyo"

[[module.imports]]
path = "github.com/FeiNiaoBF/hugo-theme-inyo"
```

### 经典 themes/ 目录

```bash
git clone https://github.com/FeiNiaoBF/hugo-theme-inyo.git themes/inyo
```

```toml
theme = "inyo"
```

## 配置

Hugo 官方建议把项目配置放在站点根目录的 `hugo.toml`，并且只写偏离默认值的部分。Inyo 主题自己的默认值放在 `config/_default/params.toml` 与 `config/_default/markup.toml`，模块会将它们合并到站点；站点配置优先。站点名称、域名、语言、作者和社交链接仍然必须由使用者决定。

```toml
[params]
# 首页和无页面级 description 时使用的站点 SEO 描述
description = "一个使用 Inyo 构建的长文博客。"
# 正文字体：wenkai（霞鹜文楷，默认，自托管分片）/ serif（思源宋体，CDN）
font = "wenkai"
# 是否加载 web 字体（false 则用系统字体栈）
webfonts = true
# 数学公式（全站默认关闭）
math = false
# 全站关闭时，单篇文章也可在 front matter 使用 math: true 按页加载 KaTeX
# 首页展示的 section
mainSections = ["posts"]
# 社交卡片图（不配置时默认使用兼容分享平台的 PNG）
# ogImage = "img/og-image.png"
# 站名下的气质签名（副标题）
subtitle = "纸墨二元 · 落字有间"
# 站点作者（SEO Person schema + 文章页 article:author）
author = "Inyo"

# 导航路径；文章入口使用 mainSections 的第一项
[params.navigation]
tags = "tags"
about = "about"

# 可选远程诗词；关闭或请求失败时使用 data/inyo/hero_poems.toml
[params.heroPoetry.api]
enabled = false
endpoint = "https://poetry.palemoky.com/api/poems/random"
lang = "zh-Hans"

# 社交链接（右侧栏渲染，/ 分隔）
[[params.social]]
name = "GitHub"
url = "https://github.com/FeiNiaoBF/hugo-theme-inyo"

[[params.social]]
name = "RSS"
url = "/index.xml"
```

`math` 站点参数控制全局默认值：设置为 `true` 会让所有页面加载 KaTeX；保持默认 `false` 时，单篇 front matter 的 `math: true` 才会单独启用 KaTeX。默认 `ogImage` 是 `static/img/seal-yang-og.png`；favicon 仍使用 `static/img/seal-yang.svg`。文章导航读取 `mainSections[0]`，标签与 About 路径由 `params.navigation` 控制。

远程诗词接口的最小响应合同是：对象本身或其 `data` 字段包含 `content`、`author` 和 `title`；`content` 可以是诗句数组，主题只取第一条非空诗句，作者与作品名组合为出处。响应不符合合同时会静默回退到 `data/inyo/hero_poems.toml`。

## 多语言

主题内置 zh-cn / en / ja 翻译与语言切换器；Hugo 站点配置多个 `[languages.*]` 后，右侧栏自动显示语言切换。

## 目录结构

```
hugo-theme-inyo/
├── DESIGN.md        # 设计文档（配色 token 权威来源 + ADR + 动效规范）
├── AGENTS.md        # AI 编码代理规范
├── theme.toml       # Hugo Themes 分发元数据
├── archetypes/      # hugo new content 使用的默认 Front Matter
├── images/          # 主题市场截图与缩略图
├── config/_default/ # 主题可合并的默认参数与 Markdown 配置
├── layouts/         # 模板（baseof/index/single/list + partials + _markup 渲染 hooks）
├── assets/css/      # main.css —— CSS 变量 token 体系
├── data/inyo/       # 首页 Hero 的本地诗句 fallback
├── scripts/         # 主题与独立消费者生成物 smoke 检查
├── .github/workflows/# Hugo 构建与 smoke CI 门禁
├── static/img/      # favicon SVG 与社交分享 PNG
└── exampleSite/     # 演示站点（hugo server --source exampleSite）
```

## 演示

```bash
cd exampleSite
hugo mod tidy
hugo server
```

发布前运行：

```bash
hugo --source exampleSite --minify
pwsh -File scripts/verify-theme.ps1
pwsh -File scripts/verify-consumer.ps1
git diff --check
```

验证脚本会检查 P1/P2 生成物合同，包括 SEO、render hooks、颜色 token、首页 Hero 诗句、双翼 SVG、摘要语义、a11y 和三语 key。独立消费者 fixture 还会使用 `notes` section 和 `labels` taxonomy 验证主题没有依赖 Demo 的固定路径。Hero 交互只存在于首页，文章页不会输出本地诗句数据、API 地址或交互脚本。

仓库的 GitHub Actions 会在每次 push 和 pull request 上运行两组门禁：Demo 构建与 `scripts/verify-theme.ps1`，以及独立 consumer 的 `scripts/verify-consumer.ps1`；两组均使用 Windows runner、Go `1.26.1` 和 Hugo Extended `0.164.0`。通过 CI 是发布前的必要条件。

## 主题质量门禁

- 网页内联 Logo 使用 `assets/css/main.css` 的主题 token，亮暗模式自动适配。
- `static/img/seal-yang.svg` 是 favicon 的固定品牌色版本；它没有 CSS 变量上下文，是明确记录的唯一例外。
- 诗句 Hero 只在首页加载，远程 API 默认关闭且始终有本地 fallback；点击后先即时播放沿圆角边框的双翼墨线，再等待新诗句。
- 文章列表优先使用 Hugo `.Summary`，支持 Front Matter `summary`、`<!--more-->` 和自动摘要；只有 `.Summary` 为空时才使用 `.Description`。
- 发布前必须通过 Hugo 构建、P1/P2 smoke checks 和 GitHub Actions。

新建内容时，主题自带的 `archetypes/default.md` 会填入动态标题、日期、description、summary、draft、math、categories 和 tags：

```powershell
hugo new content posts/my-first-post.md
```

## English

Inyo is a Chinese-first editorial Hugo theme built for long-form reading. It provides paper-and-ink light and dark themes, a homepage poetry interaction, multilingual UI strings, taxonomy pages, page-level KaTeX, accessible navigation, and Hugo-native summaries.

Compatibility: Inyo `v0.1.0`, Hugo Extended `>= 0.164.0`, and Go `>= 1.26.1`.

### Install with Hugo Modules

```powershell
hugo mod init example.com/my-site
hugo mod get github.com/FeiNiaoBF/hugo-theme-inyo
```

```toml
[module]
[[module.imports]]
path = "github.com/FeiNiaoBF/hugo-theme-inyo"
```

Theme defaults live in `config/_default/params.toml` and `config/_default/markup.toml`. Configure site identity, `params.description`, `params.mainSections`, navigation paths, author data, and social links in your site's `hugo.toml`.

The remote poetry API is disabled by default. Enable `params.heroPoetry.api.enabled` only when wanted; local poems in `data/inyo/hero_poems.toml` remain the fallback.

Run the example and release checks with:

```powershell
hugo server --source exampleSite
hugo --source exampleSite --minify
pwsh -File scripts/verify-theme.ps1
pwsh -File scripts/verify-consumer.ps1
git diff --check
```

New posts created with `hugo new content posts/my-post.md` use the theme's TOML archetype. Inyo is released under the MIT License.

## 许可

MIT © FeiNiaoBF

---

配色与设计决策的完整记录见 [DESIGN.md](DESIGN.md)。
