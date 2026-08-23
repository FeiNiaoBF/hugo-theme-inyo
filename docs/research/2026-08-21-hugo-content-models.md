# Hugo 内容模型与成熟主题调研

日期：2026-08-21

目的：为 Inyo 的普通文章、系列文章、标签、Markdown 增强和自定义 shortcode 设计寻找 Hugo 原生依据，区分 Hugo 能力与主题约定。

## 结论摘要

1. Hugo 原生已经把内容组织拆成不同层次：section/`_index.md` 负责层级与列表页，taxonomy 负责扁平的内容关系，page bundle 负责文章与资源的绑定。
2. “系列”不是 Hugo 的内置特殊模型。成熟主题通常把 `series` 当作一个自定义 taxonomy；系列内的顺序、前后篇和系列总览属于主题模板逻辑，不能把自定义字段误称为 Hugo 标准。
3. Inyo 应保留普通文章的自由度：标签继续做主题分类；有独立目录和子内容的课程使用 section；跨 section 或轻量系列可在确认需求后增加 `series` taxonomy。
4. Markdown 优先的实现路径是 Hugo Goldmark + render hooks。提示框、媒体、图表等 Markdown 无法自然表达的内容，再通过少量自定义 shortcode 扩展。
5. 相关内容可以直接使用 Hugo 的 Related API，并按 tags、keywords、date 等索引配置；它适合“相关文章”，不应被当作有严格顺序的系列导航。

## Hugo 官方模型

### Section、`_index.md` 与 page bundle

Hugo 的内容目录结构会影响渲染后的 URL、section 和模板类型。顶层内容目录决定默认 content type；`_index.md` 可为 home、section、taxonomy 和 term 页面提供 front matter 与正文。`index.md` 则用于 leaf bundle，适合把文章和图片等 page resources 放在同一个目录中。

来源：

- [Content organization](https://gohugo.io/content-management/organization/)
- [Page collections](https://gohugo.io/quick-reference/page-collections/)
- [BundleType](https://gohugo.io/methods/page/bundletype/)

对 Inyo 的含义：

- 普通文章可以继续使用 `content/posts/<slug>/index.md`。
- 有自己的简介、子文章或资源集合的课程可以使用 `content/posts/<course>/_index.md` 与子页面。
- 不能把所有文章都塞入系列 section；section 表达的是内容层级，不只是标签关系。

### Taxonomy 与 tags

Hugo 的 taxonomy 是用于内容分类的扁平关系。配置 taxonomy 后，Hugo 会自动生成 taxonomy 总览页和 term 页面；文章通过 taxonomy 的复数名称在 front matter 中赋值。taxonomy term 也可以用 branch bundle 提供自己的标题、正文和其他元数据。

来源：[Taxonomies](https://gohugo.io/content-management/taxonomies/)

对 Inyo 的含义：

- `tags` 很适合作为主题分类，继续保留。
- `series` 可以作为一个自定义 taxonomy，但它本身只表达“属于哪个系列”，不自动表达文章顺序。
- `series_order` 若未来采用，将是 Inyo 的主题约定，不是 Hugo 原生字段；应在文档中明确这一点。

### Related content

Hugo 原生提供 related content 配置与 `.Related` 方法。默认相关性可以基于 keywords、date 和 tags，也可以通过配置调整索引权重；模板可以直接取得当前页面的相关页面集合。

来源：

- [Configure related content](https://gohugo.io/configuration/related-content/)
- [Pages.Related](https://gohugo.io/methods/pages/related/)

对 Inyo 的含义：相关内容适合放在文章底部作为“旁支阅读”，但不能代替系列的严格前后顺序。系列导航应基于 section 或明确的系列顺序规则。

## Markdown、render hooks 与 shortcodes

### Goldmark

Hugo 默认使用 Goldmark 渲染 Markdown，并建议除非确有特殊需求，否则使用默认 Markdown handler。Goldmark 已覆盖表格、任务列表、脚注、自动链接、删除线等常用能力；passthrough 可用于数学公式等场景。

来源：[Configure markup](https://gohugo.io/configuration/markup/)

对 Inyo 的含义：主题不应重新定义一套 Markdown 语法，而应围绕用户站点的 Goldmark 配置提供稳定样式和兼容性。

### Render hooks

Hugo 的 render hooks 可覆盖 Markdown 中的 blockquote、code block、heading、image、link、passthrough 和 table 的 HTML 转换。模板可以按页面类型、kind、语言和输出格式进一步细分。

来源：[Render hooks introduction](https://gohugo.io/render-hooks/introduction/)

对 Inyo 的含义：代码块、标题锚点、图片懒加载、链接 URL 处理、表格和引用的第一优先级改进，都应优先放在 render hooks 与 CSS，而不是 shortcode。

### Shortcodes

Hugo 支持内置、项目自定义和 inline shortcodes。自定义 shortcode 适合视频、图片画廊、音频、图表、地图等 Markdown 无法自然表达的组件。Markdown notation 的 shortcode 会在 Markdown 渲染前处理，内部标题可以进入 `.TableOfContents`；standard notation 在 Markdown 渲染后合并，内部标题不会进入目录。

来源：

- [Shortcodes](https://gohugo.io/content-management/shortcodes/)
- [Shortcode templates](https://gohugo.io/templates/shortcode/)

对 Inyo 的含义：

- 可以逐步增加 `alert`、`figure`、`gallery`、`audio` 等语义明确的 shortcode。
- shortcode 设计必须考虑目录、可访问性、无 JS 降级和 RSS/纯文本输出。
- 不应为了视觉变化把普通段落、标题或列表都改成 shortcode。

## 成熟主题的做法

### PaperMod

PaperMod 的公开特性包括目录、代码复制、搜索、文章归档、taxonomies 和相关文章，并保持无构建期 JavaScript 依赖。[PaperMod README](https://github.com/adityatelange/hugo-PaperMod/) 展示了它把这些能力作为主题层功能组合起来。

其 Open Graph 模板会读取 `series` taxonomy 的 terms，并把同一 series 下的其他页面输出为 `og:see_also`。这证明 PaperMod 使用的是 Hugo 自定义 taxonomy，而不是一套 Hugo 内置的 series 类型。

来源：[PaperMod Open Graph template](https://github.com/adityatelange/hugo-PaperMod/blob/master/layouts/_partials/templates/opengraph.html)

对 Inyo 的含义：可以借鉴“`series` 作为 taxonomy”的建模方式，但不能直接照搬 PaperMod 的字段、UI 或 SEO 行为；Inyo 还需要自己决定系列总览和顺序。

### Congo

Congo 的文档明确区分 Hugo 的 branch pages、leaf pages 和 taxonomy pages。它使用 `_index.md` 自定义 section/taxonomy 页面，用 `index.md` 表示带资源的 leaf page，并允许通过 section layout 为某一类内容提供特殊列表样式。

来源：[Congo content examples](https://jpanther.github.io/congo/docs/content-examples/)

Congo 的 front matter 文档说明：主题参数继承自主题配置，文章只在需要覆盖默认值时声明。这种方式可以减少重复 front matter。

来源：[Congo front matter](https://jpanther.github.io/congo/docs/front-matter/)

Congo 也提供大量 shortcodes，包括 alert、figure、chart、KaTeX、Mermaid 等，并同时支持 Markdown 图片自动处理。

来源：[Congo shortcodes](https://jpanther.github.io/congo/docs/shortcodes/)

对 Inyo 的含义：可以借鉴“基础 Hugo 内容模型 + 少量展示参数 + 可选语义组件”的分层方式，但不应把 Congo 的组件数量作为 Inyo 的目标。

## 给 Inyo 的建议

### 现在应该确定的模型

```text
普通文章        = posts section 下的 leaf page
主题分类        = tags taxonomy
大型课程/独立目录 = section + _index.md + 子页面
轻量系列        = 未来可选的 series taxonomy
相关文章        = Hugo Related API
Markdown 表现   = Goldmark + render hooks
特殊内容        = 少量自定义 shortcode
```

### 现在不要确定的模型

- 不要把所有文章改成系列。
- 不要把 series、tags、section 三者混成一个“知识图谱”字段。
- 不要现在就引入 `series_order`，除非真实内容已经证明仅靠 section 顺序无法满足需求。
- 不要为了追求功能完整而一次性加入图表、Mermaid、画廊、音频、评论和搜索等组件。

### 推荐的验证顺序

1. 先用现有 `note_class` 课程结构验证 section + `_index.md` 的系列总览和前后篇。
2. 选一个普通文章集合，验证 tags 页面与 Hugo Related 的相关内容质量。
3. 只有当跨 section 的系列出现时，再增加 `series` taxonomy，并单独设计系列顺序字段。
4. Markdown 侧先完成基础 HTML 的稳定渲染，再逐个增加语义 shortcode。
