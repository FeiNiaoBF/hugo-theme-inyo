# Changelog

本项目遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/) 与 [语义化版本](https://semver.org/lang/zh-CN/)。

## Unreleased

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
