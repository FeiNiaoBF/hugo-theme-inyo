# Inyo Hugo 主题完整性审计

> 审计日期：2026-08-14  
> 审计范围：主题根目录、`exampleSite`、consumer fixture、CI、文档和生成物  
> 审计目标：按照 Hugo 官方主题制作与分发流程，确认 Inyo 已完成的能力、仍未完成的部分，以及下一轮应优先补齐的工作。

## 结论摘要

Inyo 已经是一套可以用于个人 Blog 的可运行主题：

- Hugo Module 安装和本地 `themes/` 安装文档已经存在；
- `theme.toml`、`README.md`、英文文档、许可证和主题预览图已经存在；
- 首页、section、single、taxonomy、term、404、Markdown render hooks 和 archetype 已覆盖；
- 自定义 section、taxonomy、子路径部署、SEO、摘要、a11y、颜色 token 和 Hero 已有自动检查；
- `exampleSite` 和独立 consumer fixture 均能通过当前 Hugo Extended 构建。

如果目标是“一个完整、可长期复用的 Hugo Blog 主题”，仍有以下优先缺口：

| 优先级 | 缺口 | 当前判断 |
|---|---|---|
| P1 | 没有使用 Hugo 官方 `HugoBasicExample` 或 `hugoThemesSiteBuilder` 做兼容性复核 | 已有 consumer fixture，但还不是官方基准验证 |
| P1 | 根目录 Hugo 版本声明没有明确 `extended = true`，README/CI 却要求 Extended | 版本合同不完全一致 |
| P1 | `theme.toml` 没有填写已经存在的 GitHub Pages `demosite` | 分发元数据不完整 |
| P1 | RSS 文件存在，但 HTML `<head>` 没有 RSS discovery link | 用户和阅读器无法通过页面标准发现 feed |
| P1 | 首页和文章列表没有分页 | 文章数量增长后会一次渲染全部内容 |
| P1 | 经典 `themes/` 安装只写了文档，没有独立 smoke fixture | 只验证了 Hugo Module consumer |
| P2 | 没有真实多语言内容 fixture，也没有 `hreflang` link | UI i18n 有，内容级多语言验证不足 |
| P2 | `ogImage` 空值 fallback 仍然是 SVG | 默认参数是 PNG，但 fallback 规则未统一 |
| P2 | `README.en.md` 的截图仍使用相对路径 | README.md 已符合主题站要求，英文版未同步 |
| P2 | `layouts/partials/header.html` 是未使用的遗留 partial | 不影响运行，但增加维护噪声 |
| P2 | 导航是固定结构 + 参数路径，不支持 `site.Menus` 扩展 | 符合当前极简 Blog 定位，但可移植性有限 |
| P3 | 可选字体和 KaTeX 依赖外部 CDN | 当前可用，后续可做离线与隐私加固 |

当前状态可以定义为：

> **个人 Blog 使用：合格。Hugo 主题复用：基本合格。官方主题生态级完整性：还差一轮 P1 加固。**

本报告只做审计和后续计划，不在本轮直接实现这些缺口。

## 一、官方基准

### 1. 主题骨架与目录

Hugo 官方的 `hugo new theme` 会生成包含 `archetypes`、`assets`、`content`、`data`、`i18n`、`layouts` 和 `static` 等目录的主题骨架。主题不需要机械保留每个目录，但每个实际使用的能力应有明确的目录归属和模板覆盖。

参考：

- [Hugo `new theme` 命令](https://gohugo.io/commands/hugo_new_theme/)
- [Hugo Directory Structure](https://gohugo.io/getting-started/directory-structure/)
- [Hugo Template Lookup Order](https://gohugo.io/templates/lookup-order/)

### 2. 主题生态分发门槛

Hugo 官方主题构建器要求主题根目录具备 `hugo.toml`、`theme.toml`、`README.md`、许可证、screenshot 和 thumbnail，并能在主题站点的子目录中正确生成资源和链接。

官方当前图片要求：

- screenshot：至少 `1500×1000`，比例 `3:2`；
- thumbnail：至少 `900×600`，比例 `3:2`。

参考：[hugoThemesSiteBuilder：Adding a theme / Theme configuration / Media](https://github.com/gohugoio/hugoThemesSiteBuilder#adding-a-theme)

### 3. 内容与模板

Hugo 将顶层 content 目录或包含 `_index.md` 的目录视为 section；`index.md` 用于 leaf bundle，`_index.md` 用于 branch bundle。taxonomy、term、section、home 等 page kind 由模板 lookup order 决定输出。

参考：

- [Sections](https://gohugo.io/content-management/sections/)
- [Page Bundles](https://gohugo.io/content-management/page-bundles/)
- [Taxonomies](https://gohugo.io/content-management/taxonomies/)
- [URL Management](https://gohugo.io/content-management/urls/)

### 4. 配置、输出与摘要

Hugo Module 可以提供主题的 layouts、assets、content、data、i18n、archetypes 和 static。消费者站点可以覆盖主题文件，因此主题必须避免硬编码消费者的 section、taxonomy、baseURL 和本地路径。

Hugo 默认支持 HTML、RSS 等 output formats。官方 RSS 文档建议在 HTML `<head>` 中输出 `link rel="alternate"`。Hugo 的 `.Summary` 优先级为手动 `<!--more-->`、Front Matter `summary`、自动摘要。

参考：

- [Use Hugo Modules](https://gohugo.io/hugo-modules/use-modules/)
- [Configure Modules](https://gohugo.io/configuration/module/)
- [Menus](https://gohugo.io/content-management/menus/)
- [Configure Outputs](https://gohugo.io/configuration/outputs/)
- [RSS Templates](https://gohugo.io/templates/rss/)
- [Content Summaries](https://gohugo.io/content-management/summaries/)

## 二、官方分发门槛对照

| 官方门槛 | 当前证据 | 状态 | 说明 |
|---|---|---|---|
| 主题目录骨架 | `archetypes/`、`assets/`、`data/`、`i18n/`、`layouts/`、`static/` 均存在 | ✅ | Demo 内容放在 `exampleSite/`，不需要主题根目录提供内容 |
| 根目录 `hugo.toml` | 存在 `[module.hugoVersion]` | 🟡 | 有 `min`，但没有明确 `extended = true` |
| 根目录 `theme.toml` | 字段齐全 | ✅ | name、许可证、描述、homepage、tags、features、min_version、author 均存在 |
| `demosite` 元数据 | Pages workflow 和 README 已存在 Demo URL | 🟡 | `theme.toml` 尚未填写 `demosite` |
| 开源许可证 | `LICENSE` 为 MIT，字体目录含 `OFL.txt` | ✅ | 主题代码和字体许可边界清楚 |
| README 与英文入口 | `README.md`、`README.en.md` 均存在 | ✅ | README.md 为中文优先，英文版为补充入口 |
| README 图片 | README.md 使用 `raw.githubusercontent.com` 绝对 URL | ✅ | 符合主题站显示要求 |
| 预览图 | screenshot 为 `1500×1000`，thumbnail 为 `900×600` | ✅ | 尺寸和比例符合官方要求 |
| HugoBasicExample | 当前只有 `scripts/fixtures/consumer-site/` | 🟡 | consumer fixture 强于普通 Demo，但尚未跑官方基准 |
| Theme Site Builder 复核 | 未发现官方 review 流程记录 | 🔴 | 这是进入 Hugo 主题生态前的实际缺口 |
| `exampleSite` | 独立 Demo 可以构建 | ✅ | 提供完整中文示例 |
| Demo baseURL | 当前为 `https://example.org/` | 🟡 | 官方旧主题说明建议使用 `https://example.com` 这类安全占位域名 |
| 子路径 URL | consumer 覆盖 `/blog/`，Pages build 覆盖项目子路径 | ✅ | CSS、字体、图片和页面链接已验证 |
| Hugo Pipes resources | 未使用 `toCSS` 或 PostCSS | ✅ | 当前不需要提交生成的 `resources/` |
| 资源版权 | PNG、SVG、字体和许可证文件均在仓库 | ✅ | 未发现 Demo 使用的照片版权问题 |

## 三、当前主题功能完整性

### 3.1 已完成

| 能力 | 当前实现 | 证据 |
|---|---|---|
| 首页 | `layouts/index.html` | Hero、置顶文章、最新文章、摘要 |
| Blog section | `layouts/_default/list.html` | `params.mainSections[0]` 决定文章 section |
| Single article | `layouts/_default/single.html` | 标题、日期、阅读时间、标签、正文、上下篇 |
| Taxonomy / term | `taxonomy.html`、`term.html` | categories/tags 列表和文章集合 |
| Archives | `layouts/archives/list.html` | 按年份 `GroupByDate` |
| 404 | `layouts/404.html` | 返回首页和配置的主文章 section |
| Markdown hooks | `layouts/_default/_markup/` | heading、image、link |
| Archetype | `archetypes/default.md` | TOML、`pinned`、`math`、分类、标签 |
| 多篇置顶 | `pinned = true` | 首页置顶区按日期倒序 |
| 摘要 | `summary-source.html`、`summary.html` | Hugo `.Summary` 优先，Description 兜底 |
| 数学公式 | `params.math` / `.Params.math` | KaTeX 按需加载 |
| SEO | `head.html` | description、canonical、OG、Twitter、JSON-LD、breadcrumb |
| RSS / Sitemap / robots | Hugo embedded outputs | `index.xml`、section RSS、`sitemap.xml`、`robots.txt` |
| i18n UI | 三个 `i18n/*.toml` | key 集合一致 |
| Theme toggle | base layout 内联脚本 | 亮暗主题和 `aria-pressed` |
| Hero poetry | 首页 partial + `data/inyo/` | API、超时 fallback、按钮、reduced-motion |
| 颜色纪律 | `assets/css/main.css` | 运行时颜色使用 token |
| 子路径安全 | `RelPermalink`、`relURL`、相对字体 | consumer 和 Pages smoke |
| 基础 a11y | 生成物 smoke | lang、skip link、main、focus、alt、外链 rel、ARIA |

### 3.2 不应误判为缺失

| 项目 | 判断 |
|---|---|
| 没有 `layouts/_default/home.html` | 不缺失，`layouts/index.html` 负责 home |
| 没有 `section.html` 或 `page.html` | 不缺失，`_default/list.html` 和 `_default/single.html` 是合法 fallback |
| 没有自定义 RSS 模板 | 不缺失，Hugo embedded RSS 可用；当前缺的是 discovery link |
| 没有主题根目录 `content/` | 不缺失，内容由 `exampleSite` 或消费者站点提供 |
| 没有 `resources/` | 当前不缺失，没有使用 `toCSS` 或 PostCSS |
| 没有评论、搜索、TOC、短代码 | 不属于极简 Blog 的 Hugo 基础门槛 |

## 四、仍未完成的问题

### P1：优先补齐

#### P1-1：官方 HugoBasicExample / Theme Site Builder 验证

当前 consumer fixture 已验证自定义 `mainSections`、自定义 taxonomy、子路径、module replace 和 archetype，但不能替代 Hugo 官方基准。

建议新增一个固定版本的官方基准构建，或接入 `hugoThemesSiteBuilder` 的 review 流程，检查缺失模板、URL、资源和 page kind 错误。

验收：官方基准内容可以构建，且没有缺失模板、资源、路径或 page kind 错误。

#### P1-2：统一 Hugo Extended 版本合同

当前 `go.mod` 是 Go `1.26.1`，根 `hugo.toml` 只有：

```toml
[module.hugoVersion]
min = "0.164.0"
```

而 README 和 CI 要求 Hugo Extended。需要明确选择：

- 正式支持 Extended：在 `hugo.toml` 声明 `extended = true`；
- 普通 Hugo 也能完整构建：同步降低 README 和 CI 的要求。

验收：`hugo.toml`、README、CI、`theme.toml` 和 release checklist 对版本要求一致。

#### P1-3：补齐 `theme.toml.demosite`

仓库已经有稳定 Demo：

`https://FeiNiaoBF.github.io/hugo-theme-inyo/`

建议在 `theme.toml` 增加：

```toml
demosite = "https://FeiNiaoBF.github.io/hugo-theme-inyo/"
```

验收：`theme.toml`、README、Pages workflow 和 Demo URL 只有一个真实地址。

#### P1-4：增加 RSS discovery link

当前各类 RSS 文件已生成，但 `head.html` 没有标准发现链接：

```html
<link rel="alternate" type="application/rss+xml" href="..." title="...">
```

应根据 `.OutputFormats.Get "rss"` 输出，并使用 `.RelPermalink` 或 `.Permalink` 保证子路径正确。

验收：首页、section、taxonomy、term 在存在 RSS output 时生成正确 discovery link。

#### P1-5：增加博客分页

当前首页、Blog section、term 页面直接遍历完整集合：

- `layouts/index.html`：全量遍历 `$all` 和 `$latest`；
- `layouts/_default/list.html`：直接 `range .Pages`；
- `layouts/_default/term.html`：直接 `range .Pages.ByDate.Reverse`。

建议分页边界：

- 首页只分页最新文章，置顶区域保持完整；
- Blog section 使用 `Paginate`；
- taxonomy term 使用 `Paginate`；
- archives 保持年度索引，或按年份分页。

验收：新增大量 fixture 后不会一次输出全部文章，分页链接在根路径和 `/blog/` 下均正确。

#### P1-6：验证经典 `themes/` 安装路径

README 同时承诺 Hugo Module 和经典 `themes/` 安装，但现有 fixture 只验证 module import + local replace。

建议增加一个最小 classic fixture，把主题放入 `themes/inyo/`，使用 `theme = "inyo"` 构建首页、文章、标签、归档和 404。

验收：文档中列出的两种安装方式各有一次自动构建验证。

#### P1-7：统一 `exampleSite` 占位 baseURL

当前是：

```toml
baseURL = "https://example.org/"
```

官方主题仓库说明建议使用 `https://example.com` 这类安全占位域名。Pages workflow 已覆盖真实项目 URL，因此可以安全调整示例配置。

验收：Demo 配置、文档示例和主题站测试使用同一安全占位域名，Pages 仍覆盖为真实 URL。

### P2：随后处理

| 项目 | 建议 |
|---|---|
| 真实多语言 fixture | 增加中英文配对 content，验证 `.Translations`、语言 URL、`hreflang`、OG locale |
| `hreflang` link | 在 head 输出标准 `link rel="alternate" hreflang` |
| OG fallback | 将 `head.html` 空值 fallback 从 SVG 统一为 PNG |
| 未使用 partial | 确认无外部覆盖约定后处理 `layouts/partials/header.html` |
| Menu API | 保留固定默认导航，同时提供可选 `site.Menus.main` 覆盖路径 |
| 生成物链接检查 | 检查内部链接、RSS、sitemap、robots 与 baseURL 的一致性 |
| 浏览器回归 | 固定桌面、390×844、亮暗、reduced-motion、Hero fallback 检查 |

### P3：不阻塞当前使用

| 项目 | 建议 |
|---|---|
| 字体 | 当前已使用自托管 Unicode 分片和 `font-display: swap`，后续再做按站点字符集裁剪 |
| CDN | `serif` 使用 Google Fonts，math 使用 jsDelivr；未来可做本地 KaTeX、SRI、CSP 和离线资源 |

## 五、验证证据

本次审计使用当前仓库和 Hugo Extended `0.164.0` 检查：

```shell
hugo --source exampleSite --minify --printPathWarnings
pwsh -File scripts/verify-theme.ps1
pwsh -File scripts/verify-consumer.ps1
git diff --check
```

已确认：

- Demo 页面、section、taxonomy、term、404 可以生成；
- `sitemap.xml`、`robots.txt`、首页和 section RSS 已生成；
- screenshot 为 `1500×1000`；
- thumbnail 为 `900×600`；
- OG PNG 为 `1200×630`；
- consumer 的自定义 section、taxonomy、404、archetype 和 `/blog/` 子路径检查通过；
- 主题 smoke 的 P1/P2、a11y、颜色 token、Hero、SEO 和文档合同检查通过。

当前验证没有覆盖：

- HugoBasicExample 内容构建；
- hugoThemesSiteBuilder review 流程；
- 经典 `themes/` 安装；
- 大量文章下的分页和性能；
- 两个真实语言页面之间的翻译关联；
- RSS discovery link；
- 浏览器自动化的 Hero/API/fallback 全链路。

## 六、建议执行顺序

1. 统一 `hugo.toml` 的 Extended 声明，并补 `theme.toml.demosite`。
2. 将 RSS discovery link 加入共享 `head.html`，补生成物断言。
3. 增加官方 HugoBasicExample / Theme Site Builder 兼容性构建。
4. 增加经典 `themes/` 安装 fixture。
5. 设计并实现 Blog、term、首页的分页边界。
6. 将 `exampleSite` 占位 baseURL 统一到官方安全约定。
7. 增加真实多语言 fixture、`hreflang` 和 OG fallback 修复。
8. 最后处理未使用 partial、Menu API、字体和 CDN 的减法优化。

## 七、官方参考资料

- [Create a theme](https://gohugo.io/commands/hugo_new_theme/)
- [Directory structure](https://gohugo.io/getting-started/directory-structure/)
- [Use Hugo Modules](https://gohugo.io/hugo-modules/use-modules/)
- [Configure modules](https://gohugo.io/configuration/module/)
- [Template lookup order](https://gohugo.io/templates/lookup-order/)
- [Sections](https://gohugo.io/content-management/sections/)
- [Page bundles](https://gohugo.io/content-management/page-bundles/)
- [Taxonomies](https://gohugo.io/content-management/taxonomies/)
- [Menus](https://gohugo.io/content-management/menus/)
- [Content summaries](https://gohugo.io/content-management/summaries/)
- [URL management](https://gohugo.io/content-management/urls/)
- [Multilingual mode](https://gohugo.io/content-management/multilingual/)
- [Archetypes](https://gohugo.io/content-management/archetypes/)
- [Configure outputs](https://gohugo.io/configuration/outputs/)
- [RSS templates](https://gohugo.io/templates/rss/)
- [Hugo Themes Site Builder](https://github.com/gohugoio/hugoThemesSiteBuilder)

