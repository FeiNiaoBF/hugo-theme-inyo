# Inyo 陰陽 设计文档 (DESIGN.md)

> 纸墨二元，日式现代简约与古中国水墨的 Hugo 博客主题
> 文档状态：持续维护 — 2026-08-15（纸墨体系、目录信息架构与诗句 Hero）

## 0. 主题身份

- **名称**: Inyo（陰陽）— 阴阳，纸墨二元性
- **机制**: 亮色模式 = 墨在纸上（sand 纸底 + 墨字）；暗色模式 = 白墨在墨（sand 暗底 + 月白字）
- **目标**: 长文阅读优先的小众审美博客主题；日式现代简约的秩序，古中国水墨的墨韵
- **技术**: Hugo（Hugo Modules 分发），无 JavaScript 运行时依赖；主题切换与首页诗词交互使用少量原生内联脚本，样式由 CSS 变量 token 管理

## 1. 设计原则

1. **墨韵为骨**：全站只有一个情绪色——朱砂红。底色与墨文占据绝大多数面积，朱红只作强调
2. **留白为呼吸**：间（ma）——页首尾大留白，容器 42em，正文行高 1.75
3. **数据为证**：颜色来自 Radix Colors 的既验色阶，关键组合逐一通过 WCAG 对比度实测（正文 ≥4.5:1）

## 2. 配色系统

颜色来自 Radix Colors：sand 负责暖中性纸面，tomato 负责朱红强调，indigo 负责代码。所有运行时颜色只出现在 `assets/css/main.css` 的 `:root` 与 `[data-theme="dark"]`（ADR-11）。

### 2.1 token 映射

| 角色 | token | 亮色 | 暗色 |
|---|---|---|---|
| 页面底色 | `--paper` | sand-1 `#fdfdfc` | sand-1 `#111110` |
| 抬高面 | `--paper-2` | sand-2 `#f9f9f8` | sand-2 `#191918` |
| 安静填充 | `--paper-3` | sand-3 `#f1f0ef` | sand-3 `#222221` |
| 正文 | `--ink` | sand-12 `#21201c` | sand-12 `#eeeeec` |
| 次要文字 | `--ink-muted` | sand-11 `#63635e` | sand-11 `#b5b3ad` |
| 发丝线 | `--line` / `--line-strong` | sand-6 `#dad9d6` / sand-7 `#cfceca` | sand-6 `#3b3a37` / sand-7 `#494844` |
| 强调文字/链接 | `--cinnabar` | tomato-11 `#d13415` | tomato-11 `#ff977d` |
| 实心按钮 | `--cinnabar-fill` | tomato-11 `#d13415` | tomato-9 `#e54d2e` |
| 代码强调 | `--code-ink` | indigo-11 `#3a5bc7` | indigo-11 `#9eb1ff` |
| 抬高面链接 | `--link-raised` | `#d13415` | `#ff977d` |

### 2.2 对比度实测

- 亮色正文 `#21201c` on `#fdfdfc`：**16.018:1**
- 亮色次要文字 `#63635e` on `#fdfdfc`：**5.934:1**
- 亮色强调 `#d13415` on `#fdfdfc`：**4.897:1**；on `--paper-2` `#f9f9f8`：**4.731:1**
- 暗色正文 `#eeeeec` on `#111110`：**16.263:1**
- 暗色次要文字 `#b5b3ad` on `#111110`：**9.011:1**
- 暗色抬高面链接 `#ff977d` on `#191918`：**8.357:1**

### 2.3 使用纪律

1. 颜色一律走 token，组件 CSS 不写死 hex；唯一例外是无 CSS 上下文的 favicon。
2. `--paper-2` 上的链接使用专用 `--link-raised`；正文链接使用 `--cinnabar` 并保留常驻下划线。
3. 强调色只用于链接、选中、焦点和少量状态反馈，不做大块背景。
4. 亮暗两套角色同时维护；暗色差异只通过 `[data-theme="dark"]` 覆盖。

## 3. 字体系统

| 角色 | 字体栈 | 参数 |
|---|---|---|
| 中文正文 | `'LXGW WenKai','Noto Serif SC','Source Han Serif SC','KaiTi',serif` | 默认 **霞鹜文楷**（OFL 1.1，自托管分片：`static/fonts/wenkai` + `assets/css/wenkai.css`）；16px，行高 1.75 |
| 标题 | 同族加粗（霞鹜文楷 Bold） | 统一使用 28px 展示级或 16px 正文级 |
| 思源宋体（可选） | `'Noto Serif SC','Source Han Serif SC','SimSun',Georgia,serif` | `params.font = "serif"` |
| 代码/元信息 | Sarasa Mono SC 更纱黑体 | 12px，行高 1.6，日期/阅读时间/版权 |
| 容器 | — | **42em**（中文一行 30–45 字舒适区） |

字号只有四档：`--text-xs` 12px、`--text-sm` 14px、`--text-base` 16px、`--text-display` 28px。不新增中间档位。

## 4. 组件风格

| 组件 | 规范 |
|---|---|
| Logo | **双鱼太极 + 朱砂环**：网页内联 Logo 使用 `--seal-disc` / `--seal-ink` / `--seal-light` 主题 token + `--cinnabar`，亮暗模式自适应；favicon 因无 CSS 变量上下文继续使用品牌固定色版 `img/seal-yang.svg`（唯一固定色例外） |
| 分隔线 | 不使用装饰性分隔线；目录靠留白，内容区块靠间距 |
| 竖排题款 | 已删除——正文、导航、页脚和标签索引均横排 LTR |
| 标签索引 | 横向标签云，按文章数降序；`ink-1..4` 只改变文字颜色与字重（弱化灰 → 正文墨 → 加粗墨），不改变字号。文章数使用两位等宽 `01` 形式，左侧一条朱红发丝线与标签名分隔；点击区域至少 24px，不使用卡片、胶囊或阴影 |
| 顶部导航 | 已移除，导航并入右侧身份区的纵向堆叠列表 |
| 身份区 | 太极 Logo + 站名（统一 28px）组成品牌行，副标题在下一行与站名文字左轴锁定；长站名自然换行。桌面为右侧纵向 rail，≤768px 为顶部品牌区；导航与语言/主题按钮组成同一工具栏，激活项使用朱红文字 + 发丝下划线 |
| 页脚 | 单一语义 `<footer class="shell-footer">`，DOM 位于正文之后；桌面与 769–1000px 固定在右侧 rail 底部并限制高度；≤768px 解除固定并随正文结束后出现，社交链接使用 `/` 分隔 |
| 卡片/引用 | `--paper-2` 底 + `--line` 发丝边框 + 4px 圆角，不使用左侧彩色竖线；内部链接使用 `--link-raised` |
| 表格 | 仅横线，无竖线 |
| 标签 | 发丝描边小章（`--line-strong` + 4px 圆角 + 极小字距），避免与标题争夺层级 |
| 按钮 | `--cinnabar-fill` 底 + `--on-fill` 字 |
| 文字选中 | `--selection`（tomato-5）晕染 |
| 代码块 | Hugo Chroma `noClasses = false` 输出语义 class；背景 `--code-bg`，注释用 `--ink-muted`，关键字用 `--syntax-keyword`，字符串/数字用 `--code-ink` |

## 5. 排版参数（有真实主题背书）

- 正文 16px / 行高 1.75 / 字距 0.01em
- 标题字距 0.03–0.04em；不使用负字距
- 容器 42em —— CJK 阅读舒适区（一行约 30–45 字）
- 桌面阅读轴 —— `.content` 使用 `2vw` 左内缩，让首页目录、列表页、诗句 Hero 与文章正文共享同一条安静轴线
- 数学公式保留 KaTeX 自带字体（Computer Modern 风格）

## 6. 首页：目录（v3 — pianpker 式）

- **结构**: 桌面采用右侧固定身份区（18em，大字站名 28px + 副标语 + 横排文字的纵向堆叠导航）+ 左内容区 42em；页脚语义上位于正文之后，视觉上归入右侧 rail 底部
- **首页 = 目录**: 先展示 `pinned = true` 的置顶文章，再按日期分组展示最新文章（`GroupByDate "2006-01-02" "desc"`）；每组文章标题 + 日期 + 阅读时间（更纱黑体）；摘要优先使用 Hugo `.Summary`，再做宽度感知截断（CJK=2/ASCII=1，140 单位）并限制为 3 行
- **标题字重**: 目录标题常规字重（400），对齐 pianpker 阅读气质
- **内容状态**: 零篇本地化空状态
- **响应层级**: 站名在全部视口保持 28px；≤768px 为紧凑横向工具栏，481–768px 以 `max(1.25em, calc((100% - var(--container)) / 2 + 1.25em))` 让品牌、工具栏、Hero 和正文共享同一左轴；769–1000px 保留 14em 右侧 rail 并收紧导航间距；>1000px 保留 18em rail、42em 内容块和 `2vw` 阅读轴
- **移动构图**: ≤768px 身份区高度保持 14em，工具栏落在品牌区下缘，Hero 顶部约 248px，继续作为首个三分线附近的过渡锚点；页脚在正文之后，不再占据身份区高度
- **禁止项**: 无卡片、阴影、封面图、标签堆叠和首页分页；年份分组只用于独立的 `/archives/` 归档页

### 6.1 博客信息架构

- 主导航角色固定为：首页、博客、标签、归档、关于；默认路径分别是 `/`、`/posts/`、`/tags/`、`/archives/`、`/about/`。
- 实际路径由顶层 `mainSections`（`.Site.MainSections`）与 `params.navigation` 推导，消费者可以替换 section 或 taxonomy，模板不得恢复固定路径。
- 单篇文章是主 section 下的详情页，不作为重复的主导航入口；标签负责主题分类，归档负责按年份浏览，About 与其他导航项保持相同的字号和位置。
- 归档使用 Hugo page collection 的 `GroupByDate`，按年份输出年谱：所有语言统一显示阿拉伯数字年份（如 `2026`）并作为放大的视觉锚点，后缀「年」使用弱化小字；文章标题在左、日期 folio 在右；条目整行可点击，不使用逐行横线或卡片，依靠年份间距与行距建立节奏。

## 6.5 内容系统与工程（2026-08 新增）

### 6.5.1 SEO 元数据（`head.html` 集中输出）

| 项 | 实现 |
|---|---|
| canonical | 每页 `.Permalink` |
| OpenGraph | title/type(article\|website)/url/image(双鱼logo+alt)/description/site_name/locale+alternate |
| Twitter Card | summary 卡 |
| JSON-LD | Person（含 sameAs 社交链接）+ 非首页 BreadcrumbList（站→section→文章） |
| description 兜底 | 页面 `.Description` → 共享 `summary-source.html` → `params.description` → `params.subtitle` → `site.Title`，plainify 后截 155 字符 |

### 6.5.2 可访问性（WCAG 2.x AA）

- skip link（body 首元素 → `#main-content`，聚焦滑入）
- 全局 `:focus-visible` 朱砂焦点环（outline 2px + 3px offset）
- 正文内联链接使用实色 `currentColor` 常驻下划线；抬升面链接同时切换到专用高对比角色，不只依赖颜色辨识
- `prefers-reduced-motion` 全动画降级（0.01ms）
- 主题切换按钮 `aria-pressed` + 三语 `aria-label`，透明命中区固定为 28×28px，在满足 WCAG 2.2 最小目标尺寸的同时维持移动端头部比例
- 首页诗句 Hero 使用原生 button，支持点击、触摸、Enter 与 Space

### 6.5.3 内容交互

- **标题锚点**：`_markup/render-heading.html` 构建期注入 `#`（hover 显示，朱砂），零 JS
- **返回键**：文章标题上方 `← 返回`（`CurrentSection`，三语 i18n）
- **链接策略**：`_markup/render-link.html` — 外链自动 `target="_blank" rel="noopener noreferrer"`；根相对站内内容链接经 `relLangURL` 保留项目子路径与语言段，锚点和普通相对链接不动
- **图片懒加载**：`_markup/render-image.html` — markdown 图片默认 `loading=lazy decoding=async`；页面资源与 static 位图自动输出固有尺寸；手写 `<figure>` 不注入

### 6.5.4 404 页

`404` 朱砂大字 + 直白说明（"页面不存在。" / "链接可能已失效，或内容已被移除。"）+ 首页/文章导航，三语 i18n。

### 6.5.5 摘要算法（`partials/summary.html`）

- **宽度感知截断**：CJK/全角=2 全宽单位（UTF-8 字节≥3 判定），ASCII/半角=1
- **长度**：140 全宽单位 ≈ 3 行（47 单位/行 × 3 行，42em 容器实测；基准 pianpker 121–123 单位/3 行）
- **来源优先级**：Hugo `.Summary`（`<!--more-->` → Front Matter `summary` → 自动摘要）→ `.Description` 兜底
- 超限追加 `…`；首页 tags 组/untagged 组/列表页三处统一调用

### 6.5.6 普通文章与系列

- **普通文章（post）**：`layout: post` 是文章 archetype 的默认显式值；作者省略 `layout` 时，`_default/single.html` 仍回退到同一个 post partial，普通文章的页面结构和视觉不发生分叉。
- **系列（series）**：只有 section 的 `_index.md` 使用 `layout: series`，系列内容只收录该 section 的直接子文章；子文章继续按 post 渲染，不递归吸收更深层目录。
- **阅读顺序**：先按非零 `weight` 升序，再把未设置或为零的 `weight` 按 `date` 升序接在其后。系列的最近更新时间取所有直接子文章中最大的 `lastmod`，文章未提供有效 `lastmod` 时回退 `date`。
- **置顶边界**：系列是否置顶只读取 `_index.md` 的 `pinned`；子文章的 `pinned` 不改变 Home 与 Blog 的系列入口位置。
- **目录视觉**：Home 与 Blog 的系列入口沿用普通目录的单轴构图：系列名称、普通文章标题和摘要从同一条左轴开始，metadata 保持普通目录的右侧槽位；series icon 退到标题左侧 gutter 作为系列标记，不占用标题列。只有 icon 与系列名称组成的标题行链接到系列总览；不显示最新文章标题，不引入 card、阴影或新的颜色 token。
- **系列图标**：series icon 使用固定 `16×16` viewBox、`1px` 描边的静态线装书册，以单线书脊、两个装订点和两条页线表达“书册”。图标 `aria-hidden`、继承 `currentColor`，不做 hover 或焦点动画。
- **总览视觉**：系列总览与普通文章同宽，H1 由线性 series icon 与系列标题组成；正文简介可选，文章目录只显示两位序号与标题，并把整行作为链接。目录以留白分隔，不显示返回博客、系列类型、篇数、最近更新、文章日期、阅读时间或摘要。
- **详情行为**：系列子文章在标题上方使用“返回「系列名称」”链接回到总览，同时保留阅读进度和按系列顺序计算的前后篇。
- **浏览合同**：Home 与 Blog 将每个系列折叠为单一入口；archives 与 tags 保留 individual articles。

## 7. ADR 记录

### ADR-1: 配色方法论（OKLCH + Cohen-Or + WCAG + 742 点名）
- **状态**: 已接受 → **选色路径已被 ADR-11 取代**
- **方法**: sRGB→OKLCH 感知空间（Ottosson 2020）；Cohen-Or 色相和谐模板（SIGGRAPH 2006，邻近≤30°/三角~120°/互补~180°）；WCAG 对比度目标驱动（"明度≠对比度"，二分搜索明度）；选色只从 742 中华传统色库点名，兜底（明度推移）必须标注
- **来源**: zhongguo-traditional-colors（harmony CSV 算法同源）、OKHST 实践（tenphi.me）

### ADR-2: 暗色模式选剑锋紫（已被 ADR-7 取代）
- **状态**: 已接受 → **已被 ADR-7 取代**（v2 改墨黑体系）
- **背景**: 用户原方案含剑锋紫/绿灰两组有色暗底。客观对比：潭水绿主色 1.05:1、黄昏灰强调 1.14:1、綟绶强调 2.52:1 全部结构性失败；剑锋紫 + 舌红 5.18:1 通过
- **决策**: 保留剑锋紫做暗底（有色暗底潮流 + 正文 10.39:1），角色全部按算法归位
- **取代原因（ADR-7）**: 用户实测反馈暗色“怪、两套设计” —— 剑锋紫 H=314.6° 与亮色暖纸温度轴分离；墨黑体系让亮暗同属纸墨二元

### ADR-7: 暗色改用墨黑体系（取代 ADR-2 剑锋紫）
- **状态**: 已接受 → **具体色值已被 ADR-11 取代**
- **决策**: 暗底用墨色 `#1D1B1C`（742 库真名，恰为亮色正文墨色），月白 `#ECE6DC` 正文、朱红 `#ED5126` 链接
- **理由**: 亮=墨字在纸，暗=白墨在墨，双模式同一设计；暗底取亮色正文色，纸墨闭环叙事
- **实测**: 朱红 on 墨色 4.74 ✅（on #232323 4.35 ❌，故底必须取暗端）；月白 13.80 ✅；抬升面链接须用舌红 6.03 ✅

### ADR-3: 命名演化
- Ink-Shōwa（不符合）→ Kanso 簡素（撞名 bitgnostiq/kanso）→ **Inyo 陰陽**（纸墨二元性，查重通过）

### ADR-4: 独立仓库 + Hugo Module 分发
- **决策**: 主题独立仓库 `github.com/FeiNiaoBF/hugo-theme-inyo`，博客经 `module.imports` 引入；Vercel 要求模块仓库公开
- **理由**: 开源分享、内容与主题解耦、契合现有 Hugo Modules 架构

### ADR-5: 数学公式职责边界
- **决策**: 主题带 KaTeX 开关（`params.math`），博客侧的 goldmark passthrough 配置留在博客
- **理由**: 数学支持是站点需求不是主题需求，主题只提供能力

### ADR-8: Logo 改为双鱼太极 + 朱砂环（v4）
- **状态**: 已接受（2026-08-06 用户从 4 候选选定，几何经 2 轮修正确认）
- **背景**: 旧 Logo 为传统印章（朱砂底「陰陽」白字）。v3 对齐 pianpker 布局后，站名放大 36px 成为主角，印章信息过载；且 Inyo=陰陽，太极图形直表本义
- **候选对比**: A 太极章（朱砂框+太极）／B 双鱼太极（无框）／C 印章 v2（细线白文印）／D 印章太极（满底）
- **决策**: B 方案双鱼太极。**修正 1**（v2）: 手推弧线 sweep 方向画反不成太极 → 对照标准 Yin-Yang 路径修正；**修正 2**（v4）: 改用基本形状叠加（左半圆+上下小圆），数学验证面积对称 200π=200π，杜绝几何错误
- **配色**: 网页内联版圆盘/墨鱼/浅色鱼使用 `--seal-disc` / `--seal-ink` / `--seal-light`，朱砂环使用 `--cinnabar`，亮暗模式自适应；鱼眼经典对位（黑鱼白点/白鱼黑点）
- **favicon**: 无 CSS 变量上下文，继续使用品牌固定色版 `img/seal-yang.svg`（复用原文件名，内容已换）；这是明确记录的唯一固定品牌色例外
- **社交分享图**: 默认 `ogImage` 使用 `img/seal-yang-og.png`，避免社交平台对 SVG 支持不一致；该 PNG 是固定品牌色静态输出，不进入运行时 CSS token 系统

### ADR-10: section + layout 内容模型
- **状态**: 已接受
- **背景**: 仅靠 `xxx(1)`、`xxx(2)` 标题或人工维护普通文章目录，无法让主题稳定区分系列边界、阅读顺序和总览入口；新增 taxonomy 或站点级系列参数又会把同一内容关系拆到多处管理。
- **决策**: 以 Hugo section 表达系列边界，以 named layout 表达页面角色。普通文章默认或显式使用 `layout: post`；省略 `layout` 时由 `_default/single.html` 回退到 post partial。只有系列 section 的 `_index.md` 使用 `layout: series`，且只管理其直接子文章。
- **排序与更新**: 阅读顺序先取非零 `weight` 升序，再取未设置或为零的 `weight` 并按 `date` 升序；系列最近更新优先使用子文章 `lastmod`，无有效值时回退 `date`。
- **置顶**: 系列级 `pinned` 只写在 `_index.md` 并由目录读取，子文章的 `pinned` 不参与系列入口排序。
- **视觉与导航**: Home 与 Blog 目录中，series icon 与系列名称组成指向系列总览的标题链接；标题文字和摘要保持普通文章的左轴，metadata 保持普通目录的右侧槽位，icon 只在左侧 gutter 中提供系列识别。icon 是固定尺寸的静态线装书册；总览只保留 icon 标题、可选简介以及“序号 + 标题”的整行文章链接，以留白而非分隔线组织内容；子文章通过包含系列名的返回链接、进度与前后篇完成系列导航。不使用 badge 或 card，也不新增颜色 token。
- **集合合同**: Home 与 Blog 将每个系列折叠为单一入口；archives 与 tags 保留 individual articles。
- **结果**: 内容关系由目录结构与 Front Matter 就地管理，不解析标题、不增加 series taxonomy，也不增加新的站点配置参数。

### ADR-11: 配色改用 Radix Colors（取代 ADR-1 / ADR-2 / ADR-7 的选色路径）
- **状态**: 已接受（2026-11）
- **背景**: 旧配色依赖 742 中华传统色点名与手工 OKLCH 推色，token 多、文档长，且部分角色在暗色下需要单独推导。维护成本高于收益。
- **决策**: 亮色与暗色统一采用 Radix Colors：sand 作中性纸面、tomato 作朱红强调、indigo 作代码。颜色只通过语义 token 暴露，组件不直接引用色阶。
- **结果**: 亮暗两套角色一一对应；对比度实测记录在 §2.2；装饰性差异（红圆印章、双翼描边、翻书动画）随旧色系一并移除。

## 8. 首页诗句 Hero

首页 Hero 是固定高度的横向诗签，以阅读体感为先，显示居中双行的“诗句 + 作者出处”。诗句与出处各限制为单行省略，避免远程内容改变首页布局或造成横向溢出。

- **初始数据**：主题自带 `data/inyo/hero_poems.toml`，页面加载不发起网络请求
- **主动交互**：整条 Hero 是原生 button；点击、触摸、Enter、Space 均抽取下一句
- **远程增强**：`heroPoetry.api.enabled` 默认 `false`；开启后仅在主动交互时请求，响应必须规范化为 `text` 与 `source`
- **失败策略**：超时、CORS、非 2xx、字段缺失或连续重复时静默使用本地诗句，不显示加载或错误文案
- **页面范围**：数据和脚本仅输出到首页；文章、列表、标签、About 与 404 不包含 API 地址
- **颜色纪律**：正文使用 `--ink`，出处使用 `--ink-muted`，边框使用 `--line`，仅 pending 状态用 `--cinnabar`；不新增颜色 token

## 9. 首页诗句交互

诗句 Hero 只做一次状态反馈，不做装饰性描边或文字出入场。

- 点击后立即进入 `is-fetching`（边框转为朱红），诗句内容在请求完成或本地抽取后一次替换
- 本地优先；远程请求超时、失败或字段缺失时静默回退本地诗句
- 请求期间保留当前诗句并设置 `aria-busy="true"`；结束后通过 polite live region 宣布新内容
- hover 只在 `hover:hover` 下改变边框，不请求数据
- 动效只有边框与背景色的 250ms ease-out 过渡；`prefers-reduced-motion: reduce` 下由全局规则降为近零
- Hero 高度桌面 64px、移动端 56px

### ADR-9: 诗句 Hero（2026-08-08，2026-11 调整）
- **状态**: 已接受
- **决策**: 保留本地优先、可选远程的随机诗句；移除朱红双翼描边和文字出入场动画，只保留 pending 边框状态
- **理由**: 诗句本身已提供记忆点，持续动画与阅读型主题的安静气质冲突，也增加维护面
- **接口**: 默认示例使用诗泉 `https://poetry.palemoky.com/api/poems/random`；接口地址可替换，主题离线时仍完整可用
- **可访问性**: 原生 button、动态 `aria-label`、`aria-busy`、live region、可见焦点环与 reduced-motion 降级

## 10. 致谢与来源

- Radix Colors: @radix-ui/colors（sand / tomato / indigo）
- 字体: 思源宋体/霞鹜文楷/更纱黑体（均为开源 OFL）
- 字体交付: 霞鹜文楷自托管分片来自官方 lxgw-wenkai-webfont 包（97×2 unicode-range 分片）；Windows 上 `cn-font-split` 因 koffi/libffi 不可用，改 vendor 官方分片
