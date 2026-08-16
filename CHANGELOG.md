# Changelog

本项目遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/) 与 [语义化版本](https://semver.org/lang/zh-CN/)。

## Unreleased

## v0.3.0 - 2026-08-15

### Added

- tags 索引页改为**横向编辑型标签云**：标签按文章数降序，映射 `ink-1..4` 权重分级（字号 + 墨色浓淡，高频标签更粗更深）；每枚标签显示等宽文章计数；categories 等其它 taxonomy 保留列表；标签云仅用于 `params.taxonomy.tag` 配置的 taxonomy

### Changed

- 标签索引一律横排（`writing-mode` 不使用竖排）；文档与门禁同步更新，竖排仅限题签的例外已撤销

## v0.2.2 - 2026-08-15

### Fixed

- 语言切换器列出所有已配置语言且顺序固定（当前语言原位高亮，不再跳位）；未翻译页面回退到对应语言首页
- `content/en`、`content/ja` 未映射到对应语言，导致 en/ja 页面外壳（`<html lang>`、标题、导航）停留默认语言——通过显式 `contentDir` 修复
- 弃用的 `.Language.LanguageName` 改为 `.Language.Label`

### Changed

- demo 启用 en/ja 语言并翻译 About 页；语言切换器使用 `/` 分隔（与社交链接风格统一）

## v0.2.1 - 2026-08-15

### Fixed

- 页脚回退为桌面/平板固定在右侧 rail 底部、移动端正文之后；语言切换与主题切换按钮重新钉回 rail 底部（撤销 v0.2.0 的全宽页面页脚改动）

### Changed

- 新增英文 README（`README.en.md`）并加入更新 Inyo 指南（`hugo mod get @latest` + `GOPROXY=direct` 说明）
- 同步 CONTRIBUTING 与 demo 指南（`--buildDrafts`、`pinned: true` 示例）及对应 smoke 断言

## v0.2.0 - 2026-08-15

### Added

- 首页多篇置顶与独立归档页：主导航保持“首页、博客、标签、归档、关于”，归档按年份输出文章日期与标题
- `scripts/verify-hugo-basic-example.ps1` 与对应 CI job，使用官方 HugoBasicExample 验证主题基础兼容性
- `inyo-content-authoring` 项目 skill，用于约束 Demo 文章、YAML Front Matter、Markdown 展示和内容互链
- `inyo-git-release` 项目 skill，用于分组提交、commit 质量、SemVer Tag 与经授权的 push 流程

### Changed

- Demo 与 consumer 站点配置统一为 `exampleSite/hugo.yaml` 和 `scripts/fixtures/consumer-site/hugo.yaml`；根目录 `hugo.toml` 继续只承担主题模块兼容性声明
- Demo 内容收敛为主题使用、Markdown 基础、高效写作、KaTeX、FAQ 和品牌设计六篇文章，默认 archetype 与内容 fixture 统一使用 YAML Front Matter
- 同步 README 双语、CONTRIBUTING、DESIGN、AGENTS 与项目 skills 的配置边界、验证命令和职责说明

### Fixed

- 页脚从 `position: fixed` 浮层改为全宽、文档流内的页面页脚（任何视口均在正文之后），修复平板/桌面下页脚悬浮叠内容的问题
- `scrollbar-gutter: stable` 固定滚动条槽位，避免跨页切换时内容列横向跳动
- 路由与可访问性合同加固：多语言 fixture、外链安全、地标顺序与 aria-current 语义

## v0.1.1 - 2026-08-12

### Changed

- 重写 README：加入主题截图（绝对图片路径）、快速开始、精简配置节（完整参数表指向演示站配置参考）
- 同步开发规范（AGENTS.md / .pi/skills）：右侧身份栏 + 诗句 Hero 的现行布局基线

### Fixed

- 404 / 列表 / 文章页的可移植路径：文章入口读 `mainSections[0]`、标签链接读 `params.navigation.tags`，不再硬编码 `/posts/`、`/tags/`
- 自托管字体资源路径改为相对 `../fonts/`，支持 `/blog/` 等子路径部署
- `.gitignore` 扩展：忽略所有 `**/public/`、`**/resources/`、锁文件与临时文件

## v0.1.0 - 2026-08-12

首个发布基线：纸墨二元 Hugo 主题，可分发、可上架 Hugo Themes。

### Added

- **诗句 Hero**：首页诗句 + 作者出处，点击两阶段反馈（朱红双翼墨线沿圆角边框上行、顶部中央合墨）；本地 `data/inyo/hero_poems.toml` 兜底、远程 API 可选（默认关闭）
- **太极 Logo**：双鱼太极 + 朱砂环，几何验证面积对称；网页内联版随主题 token 变色，favicon 固定品牌色例外
- **可移植导航**：文章入口 `mainSections[0]`，标签/About 路径可配置；`aria-current="page"`
- **独立消费者验证**：`scripts/fixtures/consumer-site`（自定义 `notes` section + `labels` taxonomy）+ `verify-consumer.ps1` + Windows CI
- **主题分发资产**：`theme.toml`、`images/` 截图与缩略图、`archetypes/default.md`
- **配置架构**：`config/_default/params.toml` 与 `markup.toml` 深合并默认值

### Changed

- 右侧身份栏布局（pianpker 式）：站名/签名/导航/社交/语言/主题，≤768px 折叠为紧凑头部
- 目录按日期分组；摘要用 Hugo `.Summary` 优先 + 宽度感知截断（CJK=2/ASCII=1，140 全宽单位）
- 全站 CSS token 化；Chroma 输出 class-based，代码高亮亮暗自适应
- 自托管霞鹜文楷分片（regular + bold），零 CDN

### Fixed

- SEO 元数据门控：About 等无日期页面不再输出 `article:published_time` 假日期
- 首页 `description` 回退链：页面 `.Description` → 摘要 → 站点参数
- 标签索引页本地化标题与计数，不再出现"阅读约 0 分钟"
- 外链统一 `target="_blank" rel="noopener noreferrer"`；拒绝 `javascript:`/`data:`/`vbscript:` 目标
- 移动端横向溢出：代码块内部滚动，不裁切页面
- 主题切换防闪烁（FOUC）：首帧前应用主题
