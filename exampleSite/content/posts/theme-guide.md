---
title: "主题上手指南"
date: 2026-08-07
categories: ["指南"]
tags: ["Inyo", "安装", "配置"]
---

Inyo 陰陽 是一个为长文阅读设计的 Hugo 博客主题：亮色是墨在纸上，暗色是白墨在墨。本文按分类介绍主题的完整用法，从安装到发布。建议先读完 [Markdown 样式指南](/posts/markdown-style-guide/) 了解排版能力，再动手配置。

## 一、安装

### Hugo Modules（推荐）

要求：Hugo Extended `>= 0.140.0`；使用 Hugo Modules 时 Go `>= 1.26.1`。

新建站点先初始化模块：

```bash
hugo mod init example.org/my-site
```

你的站点 `hugo.yaml` 加入模块导入：

```yaml
module:
  imports:
    - path: github.com/FeiNiaoBF/hugo-theme-inyo
```

然后拉取依赖：

```bash
hugo mod tidy
```

本地开发时可用 `replace` 指向本地主题目录（改主题不用每次发布）：

```yaml
module:
  imports:
    - path: github.com/FeiNiaoBF/hugo-theme-inyo
  replacements:
    github.com/FeiNiaoBF/hugo-theme-inyo: ../hugo-theme-inyo
```

> 注意：Vercel 等平台从全新仓库构建时，本地 `replace` 路径不存在；发布前需改回远程模块，且模块仓库必须公开。

### 经典 themes/ 目录

```bash
git clone https://github.com/FeiNiaoBF/hugo-theme-inyo.git themes/inyo
```

```yaml
theme: inyo
```

## 二、站点配置

Inyo 全站配置集中在**一个 `hugo.yaml`**（Hugo 官方推荐的配置格式，PaperMod 等主流主题同款）。新建站点后复制下面整份文件，按注释调整即可：

```yaml
# ============ 站点基础 ============
baseURL: "https://example.org/"        # 发布域名（必填，协议+斜杠结尾）
title: "Inyo 陰陽"                      # 站点名（身份栏大字 + 浏览器标题）
defaultContentLanguage: "zh-cn"        # 默认语言
enableRobotsTXT: true                  # 生成 robots.txt

# ============ 主题模块 ============
module:
  imports:
    - path: github.com/FeiNiaoBF/hugo-theme-inyo

# ============ 多语言（可选，去掉注释启用） ============
# languages:
#   zh-cn:
#     languageName: 中文
#     weight: 1
#   en:
#     languageName: English
#     weight: 2

# ============ Markdown 渲染 ============
markup:
  goldmark:
    renderer:
      unsafe: true                     # 允许内联 HTML（<mark>/<kbd>/<figure> 必需）
  highlight:
    noClasses: false                   # 使用主题 token 渲染 Chroma 语法高亮

# ============ 主题参数 ============
params:
  # --- 字体 ---
  font: "wenkai"                       # wenkai 霞鹜文楷（默认，自托管分片）/ serif 思源宋体（CDN）
  webfonts: true                       # false 则用系统字体栈（加载更快）

  # --- 站名与签名 ---
  subtitle: "纸墨二元 · 落字有间"        # 身份栏站名下的气质签名

  # --- 作者（SEO） ---
  author: "Inyo"                       # Person schema + 文章页作者信息

  # --- 社交卡片图（可选） ---
  # ogImage: "img/og-image.png"        # 不配置时默认使用 static/img/seal-yang.svg

  # --- 数学公式 ---
  math: true                           # 启用 KaTeX（CDN 按需加载）

  # --- 墨滴涟漪背景图（特色交互） ---
  heroImage: "img/hero-beauty.jpg"     # assets/img/ 内路径，构建期自动转 1600w WebP
  heroImageQuality: 72                 # WebP 压缩质量

  # --- 社交链接（右侧身份栏） ---
  social:
    - name: "GitHub"
      url: "https://github.com/FeiNiaoBF/hugo-theme-inyo"
    - name: "RSS"
      url: "/index.xml"
```

**参数速查**（上文的 `params` 之外还有两个可选键）：

| 参数 | 默认 | 说明 |
|---|---|---|
| `mainSections` | `posts` | 首页目录展示的 section |
| `ogImage` | 双鱼 logo | 社交分享卡片图（放 `static/img/`，绝对路径） |

## 三、写作

### Frontmatter

文章头部支持以下字段：

```yaml
---
title: "文章标题"            # 必填
date: 2026-08-07            # 发布日期（首页按日期分组）
description: "一句话摘要"     # 可选；不写则自动截取正文首段
categories: ["指南"]         # 可选；当前首页按日期分组，categories 供检索
tags: ["Inyo"]              # 可选；显示在文章页
math: true                  # 可选；本文启用 KaTeX
---
```

### 摘要规则

首页目录的摘要**自动生成**，无需手写：

1. 有 `description` → 用它
2. 否则取正文第一个段落
3. 超长自动截断——按**显示宽度**（中文 2 单位 / 英文 1 单位）截到约 140 全宽单位（≈3 行），末尾加省略号

### 数学公式

frontmatter 开 `math: true` 后：

```markdown
行内公式：$E = mc^2$

行间公式：

$$
\sum_{k=1}^{n} k = \frac{n(n+1)}{2}
$$
```

### 其他 Markdown 能力

主题通过渲染 hook 自动增强正文，写作时无需额外配置：

| 能力 | 说明 |
|---|---|
| 标题锚点 | 悬停标题出现 `#`，点击复制章节链接 |
| 外链新窗口 | 站外链接自动 `target="_blank" rel="noopener noreferrer"` |
| 图片懒加载 | markdown 图片自动 `loading="lazy"`（手写 `<figure>` 除外，保证首图 LCP） |
| 内联 HTML | 需 `markup.goldmark.renderer.unsafe: true`，`<mark>`/`<kbd>`/`<sub>`/`<figure>` 等可用 |

## 四、首页与导航

- **首页 = 目录**：按日期分组（新在前），每组显示标题 + 阅读时长 + 摘要
- **站名即首页链接**：点击身份栏站名回到首页，导航栏不再设「首页」按钮
- **导航栏**：自动取 `posts` / `tags` / `about` 三个 section，站点有对应内容才显示
- **文章与标签页**：`/posts/` 使用本地化文章标题；`/tags/` 显示标签及文章数量，`/tags/<term>/` 显示该标签下的文章列表
- **返回键**：文章页标题上方 `← 返回`，回到文章所属 section 列表

## 五、墨滴涟漪（特色交互）

该交互只在首页加载。悬停首页顶部的卷轴题签，会触发「墨滴涟漪」；文章页、标签页、About 和 404 不会处理或加载 Hero 背景资源：

1. **落印**：朱砂环自鼠标位置急落盖下
2. **洇墨**：古画自鼠标位置晕开铺满全屏（撕纸边蒙版，永无矩形边界）
3. **落款**：双鱼太极印章盖于画作右下
4. **收墨**：鼠标移开，墨向落点回退

背景图可换：图片放 `assets/img/`，改 `heroImage` 参数即可。**选图规范**：

| 维度 | 规范 |
|---|---|
| 内容 | 古画/水墨/山水/花鸟等低信息密度题材（避免人群/文字） |
| 明度 | 主体中低亮度，保证文字可读 |
| 构图 | 主体偏离中心（三分法） |
| 比例 | 竖幅或方形（≥1:1） |
| 分辨率 | 原始宽 ≥1600px |
| 大小 | ≤5MB（构建期自动转 WebP） |

> 触屏设备自动禁用该交互；系统开启「减少动效」时动画自动降级。

Hero 图片由 Hugo 在构建期处理为 WebP，不产生运行时图片依赖。

## 六、多语言

主题内置 zh-cn / en / ja 三语翻译，站点配置多个语言后身份栏自动出现语言切换器：

```yaml
defaultContentLanguage: "zh-cn"
languages:
  zh-cn:
    languageName: 中文
    weight: 1
  en:
    languageName: English
    weight: 2
    params:
      description: "Inyo theme site"
```

注意：Hugo 默认没有翻译回退——某文章缺某语言版本时，该语言列表会隐藏它。多语言站点请为每篇内容规划各语言版本。

## 七、定制主题

主题全部视觉 token 集中在 `assets/css/main.css` 的 CSS 变量，改配色/字体不用碰模板：

```css
:root {
  --paper: #F8F4F0;      /* 纸色（亮色背景） */
  --ink: #1D1B1C;        /* 墨色（正文 + 暗色背景） */
  --cinnabar: #D92121;   /* 朱砂（全站唯一情绪色） */
  --camel: #A09182;      /* 驼色（弱化文字/元信息） */
}
```

> 设计纪律：新颜色必须实测 WCAG 对比度（正文 ≥4.5:1、大文本 ≥3:1），并保持亮暗双模式对称。设计决策的完整记录见主题仓库 `DESIGN.md`。

### Logo 与 favicon

网页内联 Logo 的圆盘、墨鱼、浅色鱼和朱砂环分别使用 `--seal-disc`、`--seal-ink`、`--seal-light`、`--cinnabar`，会随亮暗主题适配。`static/img/seal-yang.svg` 作为 favicon 没有 CSS 变量上下文，因此保留固定品牌色；这是明确记录的唯一例外。

## 八、发布

```bash
hugo --gc --minify
```

- 构建产物在 `public/`
- 平台部署（Vercel / Netlify / GitHub Pages）前，确认模块引用为远程地址（非本地 `replace`）
- 提交主题前必须依次通过：

```powershell
hugo --source exampleSite --minify
pwsh -File scripts/verify-theme.ps1
git diff --check
```

- GitHub Actions 会在 push 和 pull request 上重复执行构建、P1/P2 smoke checks 和 whitespace 检查；CI 通过是发布前的必要门禁

---

至此主题的核心用法已覆盖。写作时专注内容即可——样式交给主题，气质由 Inyo 负责。
