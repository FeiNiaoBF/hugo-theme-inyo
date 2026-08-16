Exit code: 0
Wall time: 0.7 seconds
Output:
# Inyo 陰陽

[![Verify theme](https://github.com/FeiNiaoBF/hugo-theme-inyo/actions/workflows/verify-theme.yml/badge.svg)](https://github.com/FeiNiaoBF/hugo-theme-inyo/actions/workflows/verify-theme.yml)
[![License](https://img.shields.io/github/license/FeiNiaoBF/hugo-theme-inyo)](LICENSE)
[![在线 Demo](https://img.shields.io/badge/demo-GitHub%20Pages-8f2f2f)](https://FeiNiaoBF.github.io/hugo-theme-inyo/)

> 一个中文优先、面向长文阅读的 Hugo 主题：纸墨双模式、诗词 Hero、多语言、页级数学公式与可移植的文章导航。

<h3 align="center">
  <a href="README.en.md">English</a>
</h3>

[![Inyo 亮色模式截图](https://raw.githubusercontent.com/FeiNiaoBF/hugo-theme-inyo/main/images/screenshot.png)](https://FeiNiaoBF.github.io/hugo-theme-inyo/)

## 项目状态

Inyo 当前处于早期可用阶段，适合个人 Blog、作品记录和中文长文站点。安装命令默认跟随最新 release；如果你需要复现某个历史版本，请改用对应的 Git tag。

兼容性要求：

| 项目   | 要求                                    |
| ------ | --------------------------------------- |
| Hugo   | Extended `>= 0.164.0`                   |
| Go     | `>= 1.26.1`（仅 Hugo Modules 流程需要） |
| 运行时 | 原生 CSS + 原生 JavaScript，无前端框架  |

在线 Demo：[FeiNiaoBF.github.io/hugo-theme-inyo](https://FeiNiaoBF.github.io/hugo-theme-inyo/)

## 特性

- 纸墨双主题：亮色纸面、暗色墨面，颜色集中在 CSS token 中管理
- 首页诗词 Hero：诗句与作者出处，点击后沿圆角边框完成朱红双翼墨线反馈
- 长文阅读布局：稳定的正文宽度、摘要、代码块和 Markdown 渲染
- 单一博客结构：首页、博客、标签、归档、关于；单篇文章作为博客详情页，About 与其他主导航项保持一致
- 支持多篇置顶：在文章 Front Matter 设置 `pinned: true`，首页置顶区按日期倒序展示
- 可移植导航：文章 section、标签 taxonomy、归档和 About 路径均可配置
- SEO：canonical、Open Graph、Twitter Card、JSON-LD 和 description 回退
- 多语言：内置中文、英文、日文翻译接口
- 页级数学公式：通过 `math` 参数按站点或单篇文章启用 KaTeX
- 可访问性：skip link、焦点环、ARIA 状态和 reduced-motion 降级
- 自托管字体：默认使用霞鹜文楷，支持子路径部署

## 快速开始

### 环境要求

安装 Hugo Extended `0.164.0` 或更高版本。只有使用 Hugo Modules 时才需要 Go。

```shell
hugo version
go version
```

### 创建站点并安装主题

```shell
hugo new site my-inyo-site --format yaml
cd my-inyo-site

hugo mod init example.com/my-inyo-site
hugo mod get github.com/FeiNiaoBF/hugo-theme-inyo@latest
hugo mod tidy
```

在站点根目录创建或编辑 `hugo.yaml`：

```yaml
baseURL: "https://example.com/"
title: "我的 Inyo Blog"
defaultContentLanguage: "zh-cn"

module:
  imports:
    - path: "github.com/FeiNiaoBF/hugo-theme-inyo"

params:
  description: "我的个人博客。"
  author: "你的名字"
  subtitle: "纸墨二元 · 落字有间"
```

启动本地预览：

```shell
hugo server --buildDrafts
```

### 更新 Inyo

在站点根目录运行以下命令，获取最新 release、整理 Hugo Modules 并验证构建：

```shell
hugo mod get github.com/FeiNiaoBF/hugo-theme-inyo@latest
hugo mod tidy
hugo --minify
```

`@latest` 会解析为具体版本并写入站点的 `go.mod`；不要把 `@latest` 直接写进 `go.mod`。如果 Go 代理尚未同步最新 release，可临时使用 `GOPROXY=direct` 后重试；PowerShell 可先执行 `$env:GOPROXY = "direct"`。Hugo 站点应使用 `hugo mod tidy`，不要单独使用 `go mod tidy`，因为主题可能只通过 `hugo.yaml` 的 Module 配置被引用。

### 直接预览 Demo

克隆仓库后，可以直接启动内置 Demo：

```shell
git clone https://github.com/FeiNiaoBF/hugo-theme-inyo.git
cd hugo-theme-inyo
hugo server --source exampleSite
```

### 经典 `themes/` 安装

不使用 Hugo Modules 时，可以将主题源码放入站点的 `themes/` 目录：

```shell
git clone https://github.com/FeiNiaoBF/hugo-theme-inyo.git themes/inyo
```

然后在 `hugo.yaml` 中配置：

```yaml
theme:
  - "inyo"
```

两种安装方式选择一种即可，不需要同时配置 `module.imports` 和 `theme`。

## 基础配置

主题默认配置位于 [`config/_default/params.toml`](config/_default/params.toml) 和 [`config/_default/markup.toml`](config/_default/markup.toml)。站点只需要覆盖自己的身份信息和需要改变的选项：

```yaml
params:
  description: "一个使用 Inyo 构建的长文博客。"
  font: "wenkai"
  math: false
  mainSections:
    - "posts"
  subtitle: "纸墨二元 · 落字有间"
  author: "你的名字"

  taxonomy:
    tag: "tags"

  navigation:
    tags: "tags"
    archives: "archives"
    about: "about"

  heroPoetry:
    api:
      enabled: false

markup:
  _merge: "deep"
```

`params.taxonomy.tag` 是文章 Front Matter 使用的 taxonomy plural 键，`params.navigation.tags` 只是标签索引页路径。若将标签 taxonomy 改为 `labels`，请同时设置 Hugo 的 `taxonomies.tag: "labels"`、`params.taxonomy.tag: "labels"` 和相应导航路径。站点覆盖 `markup` 时必须保留 `_merge: "deep"`，否则会覆盖主题的 class-based Chroma 配色默认值。

```yaml
taxonomies:
  tag: "labels"

params:
  taxonomy:
    tag: "labels"
  navigation:
    tags: "labels"
```

[`exampleSite/hugo.yaml`](exampleSite/hugo.yaml) 是用于展示完整能力的 Demo 配置，不要求用户原样复制。主题默认值位于 `config/_default/`，用户站点只需覆盖自己的身份信息和需要修改的参数。Demo 文章使用 YAML Front Matter；主题参数的最终事实以默认配置和模板读取点为准，设计约束见 `DESIGN.md`。

## 文档

- [用 Inyo 写一篇文章](exampleSite/content/posts/theme-usage.md)：安装主题、创建文章和使用置顶
- [Markdown 基础](exampleSite/content/posts/markdown-basics.md)：标题、图片、代码、表格和链接
- [Markdown 高效写作](exampleSite/content/posts/markdown-efficient.md)：摘要、长文组织和链接边界
- [KaTeX 数学格式](exampleSite/content/posts/katex.md)：页面级数学公式示例
- [常见问题](exampleSite/content/posts/faq.md)：FAQ 记录入口
- [品牌设计核心](exampleSite/content/posts/brand-design.md)：Inyo 的纸墨、朱红和阅读取舍
- [设计文档](DESIGN.md)：视觉方向、token 和交互约束
- [变更记录](CHANGELOG.md)：版本与发布说明

## GitHub Pages Demo

Demo 使用 `exampleSite` 构建，并由 GitHub Actions 发布到项目 Pages：

```text
https://FeiNiaoBF.github.io/hugo-theme-inyo/
```

如果你 Fork 了本项目并希望启用自己的 Demo：

1. 打开仓库的 `Settings → Pages`；
2. 将 `Source` 设置为 `GitHub Actions`；
3. 推送到 `main`，或在 Actions 页面手动运行 Demo 发布 workflow。

项目站点使用子路径构建，主题资源会通过 `baseURL` 正确生成，不要把字体、CSS 或文章链接改回假定根路径的绝对地址。

## 开发与验证

修改主题后，在仓库根目录运行：

```shell
hugo --source exampleSite --minify --printPathWarnings
pwsh -File scripts/verify-theme.ps1
pwsh -File scripts/verify-consumer.ps1
pwsh -File scripts/verify-hugo-basic-example.ps1
git diff --check
```

不要提交 `exampleSite/public/`、`resources/`、`.hugo_build.lock` 等构建产物。完整贡献流程见 [CONTRIBUTING.md](CONTRIBUTING.md)。

`verify-hugo-basic-example.ps1` 会使用官方空白 HugoBasicExample 和当前工作区主题运行一次兼容性构建，模拟 Hugo 主题生态的基础检查。

## 常见问题

### 远程诗词 API 是必须的吗？

不是。主题默认关闭远程 API，诗句来自 `data/inyo/hero_poems.toml`。Demo 为了展示完整能力而开启远程 API，接口失败时仍会回退本地数据。

### 可以部署在 `/blog/` 子路径吗？

可以。主题的导航、字体和静态资源已经按相对路径和 `RelPermalink` 处理，并在 consumer fixture 中验证了 `/blog/` 场景。

### 如何关闭自托管字体？

在站点配置中设置：

```yaml
params:
  webfonts: false
```

关闭后主题会使用系统字体栈。字体加载策略仍是后续计划，详见下方“未来计划”。

## 贡献

欢迎提交 Issue、改进文档或创建 Pull Request。开始前请阅读 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 致谢与参考

Inyo 的设计和实现借鉴了以下开源项目与工具：

- [zhongguo-traditional-colors](https://github.com/nevertoday/zhongguo-traditional-colors)：中国传统色资料与配色研究参考
- [pianpker](https://pianpker.pages.dev/) 与 [astro-theme-pianpker](https://github.com/DRAG0NM/astro-theme-pianpker)：编辑感、长文阅读与视觉表达参考
- [LXGW WenKai](https://github.com/lxgw/LxgwWenKai)：默认自托管字体
- [Hugo](https://github.com/gohugoio/hugo)：静态站点生成器与主题生态基础

Inyo 的模板、样式、交互和集成代码由本项目维护；上述项目的许可证和版权归其原作者所有。

## 路线图

- **字体加载性能优化**：当前霞鹜文楷采用自托管分片，浏览器按页面实际字符请求所需分片。现阶段优先观察真实设备与网络表现，之后再评估减少分片、调整加载策略或提供更轻量的默认字体。

## 许可证

MIT，详见 [LICENSE](LICENSE)。
