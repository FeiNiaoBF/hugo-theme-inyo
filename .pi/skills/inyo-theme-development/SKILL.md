---
name: inyo-theme-development
description: Use when 在 hugo-theme-inyo 仓库开发主题（改模板/CSS/token/发布）。
metadata:
  category: software-development
---

# Inyo Theme Development

## Overview

Inyo 陰陽 是纸墨二元 Hugo 主题（开源 `hugo-theme-inyo`），当前基线是右侧身份栏（含导航）+ 左中内容区的 pianpker 式布局，首页诗句 Hero 横条交互，默认霞鹜文楷。本技能保证所有改动符合根目录 `AGENTS.md` 与 `DESIGN.md`；如果本技能与它们冲突，以根目录规范为准。

## 铁律（从 DESIGN.md 抄录，逐条执行）

1. **颜色禁止硬编码**——必须使用 `assets/css/main.css` 的 CSS 变量 token（`--paper` / `--ink` / `--cinnabar` / `--camel` / `--indigo` 等）。新增颜色先查 `DESIGN.md` §2，正文实测 WCAG 对比度 ≥4.5:1，大文本 ≥3:1。
2. **三条使用纪律**（DESIGN.md §2.3，实测约束）：
   - 墨色 `#1D1B1C` 上正文/链接全角色过 AA（月白 13.80 / 朱红 4.74 / 晓灰 10.10）
   - 暗色抬升面（`--paper-2` `#322F31`）上的链接必须用舌红 `#F19790`（朱红 on 抬升面 3.66 不达标）
   - 浅档（t≥0.55 `#888185` 及以上）只做弱化文字/边框/装饰，禁止放正文链接
3. **正文永远横排**；竖排（`writing-mode: vertical-rl`）禁止用于正文、导航、页脚，装饰性竖排已整体移除（v2）。
4. **双模式对称**：新样式必须同时提供亮（纸）和暗（墨）取值，暗色覆盖放在 `[data-theme="dark"]`。
5. **零 JS 依赖**：内联脚本仅限两类——主题切换 + 首页诗词交互；hover 反馈必须 `hover:hover` 门控，换句动效必须提供 `prefers-reduced-motion` 降级。

## 文件结构

```text
config/_default/{params.toml,markup.toml}
layouts/{_default,partials}/
assets/css/main.css
data/inyo/hero_poems.toml
static/{fonts/wenkai,img/seal-yang.svg,img/seal-yang-og.png}
archetypes/default.md
i18n/{en.toml,zh-cn.toml,ja.toml}
scripts/verify-theme.ps1
scripts/verify-consumer.ps1
.github/workflows/{verify-theme.yml,verify-consumer.yml,deploy-demo.yml}
theme.toml
images/{screenshot.png,tn.png}
README.md / README.en.md / CONTRIBUTING.md / CHANGELOG.md
.pi/skills/xxd-*/
exampleSite/
```

## 配置事实来源

- `config/_default/params.toml`：主题默认字体、数学公式、主 section、OG 图片和可选诗词 API 参数。
- `config/_default/markup.toml`：保留 class-based Chroma；站点自己定义 `[markup]` 时必须使用 `_merge = "deep"`。
- `exampleSite/hugo.toml`：可复制的消费者配置，站点标题、域名、语言、作者和社交链接由站点决定。
- `hugo.toml`：主题元数据与 `module.hugoVersion.min = "0.164.0"`，不是站点身份配置。
- `data/inyo/hero_poems.toml`：离线可用的 Hero 诗句 fallback；每条记录必须同时包含 `text` 与 `source`。

## 布局蒸馏

- 保留 Inyo 当前 `40em` 阅读栏与全部既有颜色 token；外部主题只参考布局机制，不复制配色、框架或交互。
- 当前布局为右侧固定身份栏（18em sticky，pianpker 式，含站名/签名/导航/社交/语言/主题）+ 左中内容区；≤768px 身份栏折叠为紧凑头部。顶部导航与独立导航栏已移除（v4 并入身份栏）；首页诗句交互是横条按钮，不是悬浮 Hero。
- 目录/列表条目：标题 + 日期/阅读时间（更纱黑体），优先显示 Hugo `.Summary`，由 `.Description` 兜底；摘要按 140 全宽单位截断并限制为最多 3 行。
- TOC 默认留在正文流内；侧栏只承载导航，不承担 TOC。
- 集合页必须分别处理零篇、一篇和多篇内容，不能只验证理想数据量。
- 目录禁止用卡片、重复边框或额外强调色堆砌；分隔用细线 `--border` 与留白。
- 新的列表条目 partial 只在标记被复用或形成稳定职责边界后提取，避免为单次调用制造碎片。
- 需要用户定制时，优先提供小型 Hugo 覆盖 partial；不要为每个视觉细节增加配置开关。
- **导航交互（pianpker 蒸馏）**：激活项 = 常驻下划线 + 加粗；hover = 下划线自左下扫入（`::after` + `transform-origin: bottom-right→bottom-left` + `scale-x 0→1`，≈300ms ease-out）；**暗色模式删除下划线**，改颜色 + 字重过渡。纯 CSS，零 JS。
- **字体交付（pianpker 蒸馏，已实现）**：中文字体自托管——官方 `lxgw-wenkai-webfont` 包 vendor 进 `static/fonts/wenkai/`（`unicode-range` 分片 + `assets/css/wenkai.css`），零 CDN 依赖、无 FOUT。字体 CSS 必须使用相对于生成 CSS 的 `../fonts/` 路径，确保根路径和 `/blog/` 子路径部署都能加载。注意：Windows 上 `cn-font-split` 因 koffi/libffi 不可用，优先 vendor 官方分片包。

## 精确命令（低自由度，照抄执行）

```bash
# 构建验证
hugo --source exampleSite --minify

# P1/P2、配置、a11y、Hero 诗词和生成物合同
pwsh -File scripts/verify-theme.ps1

# 独立消费者、可配置导航和 archetype 合同
pwsh -File scripts/verify-consumer.ps1

# 空白字符检查
git diff --check

# 本地预览；验证后必须停止进程
hugo server --source exampleSite

# 模块整理
cd exampleSite && hugo mod tidy
```

## 常见坑（本项目实测）

- `--minify` 输出可能省略属性引号（如 `class=site-title`）；检查生成 HTML 时使用兼容有无引号的 `grep -E` 模式。
- `hugo.toml` 的模块导入使用 `[[module.imports]]` TOML 数组表；`hugo.yaml` 必须使用 YAML 列表，禁止混用两种语法。
- Windows 的 CRLF 转换警告正常；先运行 `git diff --check`，没有空白错误即可。
- 主题切换有 0.25s 过渡；浏览器实测切换后等待至少 400ms，再读取 computed style。
- **防导航闪烁（FOUC）**：应用主题的脚本必须放 `head.html` 样式表之前（首帧前定主题）；`body` 末尾只保留切换绑定。若在 body 应用主题，暗色用户每次导航都会先闪浅色。
- 非首页不渲染 Hero，不应出现本地诗句 JSON、诗词 API 地址或交互脚本。
- 诗词 API 适配器只接受对象本身或 `data` 包装对象中的 `content`、`author` 与 `title`；只取第一条非空 `content`，缺字段必须回退本地数据。
- `static/img/seal-yang.svg` 是 favicon 固定品牌色例外；网页内联 Logo 必须使用 CSS token。
- 默认社交图使用 `static/img/seal-yang-og.png`；导航从 `mainSections[0]` 与 `params.navigation` 解析，禁止重新硬编码 `/posts`、`/tags`、`/about`。
- 文章标签链接必须从 `params.navigation.tags` 推导，404 返回文章入口必须从 `mainSections[0]` 推导；所有自托管资源路径必须对子路径部署安全。

## 文档与分发规则

- 中文开源入口是 `README.md`，英文入口是 `README.en.md`；README 顶部保留居中、显眼的 English 切换入口。
- README 不复制完整配置表；真实参数说明放在 `exampleSite/content/posts/configuration-reference.md`，写作规则放在对应 Demo 文档。
- 用户文档和项目 skill 使用三反引号代码围栏；通用命令代码块使用 `shell`，不要新增 `~~~` 围栏。只有展示真实 PowerShell 脚本语法时才保留 `powershell` 标记。
- 默认安装示例使用 `github.com/FeiNiaoBF/hugo-theme-inyo@latest`；兼容性要求以 `theme.toml`、`go.mod` 和 CI 为准。
- 主题分发资源包括 `theme.toml`、900×600 以上预览图、1200×630 PNG 社交图和根目录 `archetypes/default.md`；不能把 `public/`、`resources/` 或 lock 文件提交进仓库。
- 修改 README、CHANGELOG、Pages workflow 或 consumer fixture 时，优先使用 `$inyo-theme-release` skill；不要在开发 skill 中复制发布流程。

## 发布流程

1. 运行完整验证清单。
2. 使用显式路径执行 `git add`，避免纳入无关工作。
3. 使用 `feat:`、`fix:`、`design:` 等前缀创建聚焦提交。
4. 仅在用户明确批准后执行 `git -c http.proxy= push`。
5. 稳定后按 Hugo 官方流程提交到主题市场。

## Hugo 官方文档

以下入口于 2026-08-07 验证可访问；`/themes/` 当前会重定向到 Hugo Modules 总览：

- 主题总览：https://gohugo.io/themes/
- 模板系统：https://gohugo.io/templates/
- 模板查找顺序：https://gohugo.io/templates/lookup-order/
- 主题组件：https://gohugo.io/hugo-modules/theme-components/
- Hugo Modules：https://gohugo.io/hugo-modules/use-modules/
- 配置总览：https://gohugo.io/configuration/introduction/
- 模块配置：https://gohugo.io/configuration/module/
- 多语言配置：https://gohugo.io/configuration/languages/
- 新建主题命令：https://gohugo.io/commands/hugo_new_theme/
- 主题市场：https://themes.gohugo.io/
- 提交主题：https://gohugo.io/contribute/themes/

旧入口 `https://gohugo.io/tutorials/create-a-theme/` 已返回 404，不要引用。

## 验证清单

- [ ] `hugo --source exampleSite --minify` 构建通过。
- [ ] `pwsh -File scripts/verify-theme.ps1` 通过，且主题默认配置与项目 skill 合同存在。
- [ ] `pwsh -File scripts/verify-consumer.ps1` 通过，独立 fixture 与动态 archetype 可用。
- [ ] Consumer fixture 的 `notes` / `labels` 路径、文章标签、404 入口和 `/blog/` 字体加载均通过。
- [ ] `theme.toml`、预览图、PNG 社交图、README 双语入口与 Pages workflow 合同通过。
- [ ] `git diff --check` 通过。
- [ ] Hugo Extended `0.164.0` 与 Go `1.26.1` 和 CI 一致。
- [ ] 首页包含 Hero，文章页、标签页、About、404 不包含 Hero。
- [ ] `html lang`、skip link、`main-content`、主题按钮 ARIA 与图片 alt 通过生成物检查。
- [ ] 浏览器实测亮/暗切换，`body` 背景分别为 `#F8F4F0` / `#1D1B1C`。
- [ ] favicon 保留 `#F2EDE6`、`#1D1B1C`、`#D92121` 固定品牌色；网页内联 Logo 随亮暗模式可见。
- [ ] 所有新色均有 `DESIGN.md` 记录和对比度实测值。

## 东方美学设计原则（2026-08 补充）

- **竖排**：`writing-mode: vertical-rl` 只用于装饰（题签/印章），正文/导航/页脚永远横排；竖排中数字用汉字数字（一、二、三、四〇四）
- **纸墨二元**：亮=纸色 `--paper` / 暗=墨色 `--ink`，双模式同温轴；全站单情绪色朱砂 `--cinnabar`；墨色派生一律 `color-mix(in srgb, var(--ink) N%, transparent)`（暗色自动白墨）
- **图形可见性铁律**：纯黑白图形在单一模式会隐形（白=纸色=背景）——需要固定浅色圆盘（如 `#F2EDE6`）承托，或加朱砂环
- **动效**：优先 transform/opacity/filter 合成器属性；clip-path 动画有全屏重绘风险、mask-position 有圆心漂移坑（圆心=图像左上角+尺寸/2，动画尺寸时圆心会跑）；hover 触发动效必须 `hover:hover` 门控 + `prefers-reduced-motion` 降级
- **诗句 Hero**：本地数据走 `data/inyo/hero_poems.toml`；远程 API 默认关闭，只在用户主动交互时请求，失败必须静默回退；点击后朱红双翼墨线沿 Hero 圆角边框从底部中央上行并在顶部中央合墨，内容就绪后再落字，并提供 reduced-motion 降级
- **摘要链路**：目录/列表使用 `.Summary → .Description`；SEO description 使用页面 `.Description → summary-source.html → params.description → subtitle → site.Title`，二者不可在文档中混写。
