# Inyo 陰陽

> 纸墨二元 · 日式现代简约 × 古中国水墨 — Hugo 博客主题

**Inyo（陰陽）** 是一个为长文阅读设计的 Hugo 博客主题。亮色模式是墨在纸上（荼蘼白宣纸底 + 墨色正文），暗色模式是白墨在墨（墨色夜墨底 + 月白正文）。朱砂红是唯一的情绪色——像一枚印章盖在整个站点上。

## 特性

- 🌗 **纸墨双模式**：亮 = 荼蘼白宣纸，暗 = 墨色夜墨，10 行内联 JS 切换，零依赖
- 🖋️ **全站只有一个情绪色**：朱砂红（链接/印章/按钮），60/25/10/5 用色纪律
- 📖 **长文优先**：40em 容器、中文行高 2.0、标题字距拉开——东方式排版
- 🎨 **全部颜色出自《中华传统色》742 色库**：每个 token 有真实色名（荼蘼白、墨色、朱砂红、朱红、晓灰、云峰灰…），全部通过 WCAG AA 实测
- 🔖 **太极 Logo**：双鱼太极 + 朱砂环，几何验证面积对称，双模式可见
- 🧭 **右侧身份栏**（pianpker 式）：大字站名、气质签名、横排文字的纵向堆叠导航、社交链接（`/` 分隔）、语言切换、主题切换
- 🖌️ **墨滴涟漪 Hero**（品牌交互）：仅首页加载并响应悬停卷轴 → 四幕生命周期——落印（朱砂环急落）→ 洇墨（古画自鼠标落点晕开，撕纸边蒙版永无矩形边界）→ 落款（太极印章盖于右下）→ 收墨（移开向落点回退）；背景图可配置（`params.heroImage`，构建期自动转 1600w WebP，零运行时成本），文章、标签、About 和 404 不加载 Hero 资源
- 🧮 **数学公式开关**：`params.math = true` 启用 KaTeX（保留自带字体）
- 📐 **可定制**：全 CSS 变量 token 体系，改配色不用碰模板
- 🔤 **多语言**：i18n（zh-cn / en / ja）+ 语言切换器（Hugo 多语言站点自动显示）
- 📦 **自托管字体**：霞鹜文楷 unicode-range 分片（OFL 1.1）随主题分发，零 CDN 依赖、无字体闪烁
- 🔍 **SEO 元数据全家桶**：canonical / OpenGraph / Twitter Card / Person + BreadcrumbList JSON-LD / description 自动摘要兜底
- ♿ **可访问性 WCAG AA**：skip link、全局焦点环、`prefers-reduced-motion`、ARIA 状态
- 🧩 **内容系统**：标题锚点（hover 显示 #）、返回键、宽度感知摘要截断（CJK=2/ASCII=1，140 全宽单位）、外链自动新窗口 + `rel=noopener`
- 📄 **404 页**：纸墨叙事的「四〇四」引导页
- ⚡ **性能**：图片懒加载（`loading=lazy` + LCP 首图保护）、构建期 WebP 优化、字体防 FOUC、GPU 合成层动画

## 安装

### Hugo Modules（推荐）

要求：Hugo Extended `>= 0.140.0`；使用 Hugo Modules 时 Go `>= 1.26.1`。

新建站点先初始化模块：

```bash
hugo mod init example.org/my-site
```

```toml
# hugo.toml
module:
  imports:
    - path: github.com/FeiNiaoBF/hugo-theme-inyo
```

```bash
hugo mod tidy
```

主题默认使用 Hugo 的 class-based Chroma 输出，站点配置应保留：

```toml
[markup.highlight]
noClasses = false
```

本地开发可用 `replace` 指向本地路径：

```toml
module:
  imports:
    - path: github.com/FeiNiaoBF/hugo-theme-inyo
  replacements:
    github.com/FeiNiaoBF/hugo-theme-inyo: ../hugo-theme-inyo
```

### 经典 themes/ 目录

```bash
git clone https://github.com/FeiNiaoBF/hugo-theme-inyo.git themes/inyo
```

```yaml
theme: inyo
```

## 配置

```toml
[params]
# 正文字体：wenkai（霞鹜文楷，默认，自托管分片）/ serif（思源宋体，CDN）
font = "wenkai"
# 是否加载 web 字体（false 则用系统字体栈）
webfonts = true
# 数学公式
math = true
# 单篇文章也可在 front matter 使用 math: true；默认关闭时按页加载 KaTeX
# 社交卡片图（不配置时默认使用 static/img/seal-yang.svg）
# ogImage = "img/og-image.png"
# 站名下的气质签名（副标题）
subtitle = "纸墨二元 · 落字有间"
# 墨滴涟漪背景图（放 assets/img/ 下，构建期自动转 1600w WebP；选图规范见 DESIGN.md §8）
heroImage = "img/hero-beauty.jpg"
heroImageQuality = 72
# 站点作者（SEO Person schema + 文章页 article:author）
author = "Inyo"

# 社交链接（右侧栏渲染，/ 分隔）
[[params.social]]
name = "GitHub"
url = "https://github.com/FeiNiaoBF/hugo-theme-inyo"

[[params.social]]
name = "RSS"
url = "/index.xml"
```

`math` 站点参数控制全局默认值，单篇 front matter 的 `math: true` 可单独启用 KaTeX。`ogImage` 未配置时使用双鱼太极 logo；`/tags/` 与 `/tags/<term>/` 由主题分别渲染标签计数和文章列表。

## 多语言

主题内置 zh-cn / en / ja 翻译与语言切换器；Hugo 站点配置多个 `[languages.*]` 后，右侧栏自动显示语言切换。

## 目录结构

```
hugo-theme-inyo/
├── DESIGN.md        # 设计文档（配色 token 权威来源 + ADR + 动效/选图规范）
├── AGENTS.md        # AI 编码代理规范
├── layouts/         # 模板（baseof/index/single/list + partials + _markup 渲染 hooks）
├── assets/css/      # main.css —— CSS 变量 token 体系
├── assets/img/      # heroImage 背景图（墨滴涟漪，构建期转 WebP）
├── static/img/      # Logo SVG（双鱼太极，favicon 品牌色版）
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
```

验证脚本会检查 P1/P2 生成物合同，包括 SEO、render hooks、颜色 token、首页 Hero 资源范围、a11y 和三语 key。Hero 交互只存在于首页，文章页不会加载 Hero 背景资源。

仓库的 GitHub Actions 也会在每次 push 和 pull request 上运行相同门禁：Windows runner、Go `1.26.1`、Hugo Extended `0.164.0`、主题构建、`scripts/verify-theme.ps1` 和 `git diff --check`。通过 CI 是发布前的必要条件。

## 主题质量门禁

- 网页内联 Logo 使用 `assets/css/main.css` 的主题 token，亮暗模式自动适配。
- `static/img/seal-yang.svg` 是 favicon 的固定品牌色版本；它没有 CSS 变量上下文，是明确记录的唯一例外。
- 墨滴涟漪 Hero 只在首页加载，文章页、标签页、About 和 404 不处理 Hero 背景资源。
- 发布前必须通过 Hugo 构建、P1/P2 smoke checks 和 GitHub Actions。

## 许可

MIT © FeiNiaoBF

---

配色与设计决策的完整记录见 [DESIGN.md](DESIGN.md)。
