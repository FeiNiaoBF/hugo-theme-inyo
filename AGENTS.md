# AGENTS.md — Inyo 陰陽 协作规范

本文件面向 AI 编码代理与仓库协作者，记录不能仅靠浏览文件安全推断的项目约束。实现事实仍以源码和自动门禁为准。

## 事实源与优先级

1. `AGENTS.md`：工程边界、同步规则和验证流程。
2. `DESIGN.md`：视觉 token、排版和交互决策。
3. `config/_default/`、`layouts/`、`assets/`：公开配置与运行时实现。
4. `scripts/verify-*.ps1`、`.github/workflows/`：可执行合同。
5. `.pi/skills/`：任务工作流，不是第二份产品规范。

若内容冲突，先以源码和门禁确认现状，再修正上层文档。`docs/superpowers/plans/` 与 `docs/superpowers/specs/` 是历史决策记录，不应被当成当前 API，也不要为消除旧术语而重写历史。

## 技术基线

- Hugo Extended `0.164.0`，最低版本同时声明在根目录 `hugo.toml` 与 `theme.toml`。
- Go `1.26.1`，以根目录 `go.mod` 和 CI 为准。
- Go Templates、原生 CSS、原生 JavaScript；不引入前端框架、预处理器或运行时包。
- 允许的内联脚本只有首帧主题选择、主题切换和首页诗词交互。
- KaTeX 由 `params.math` 或页面 `math: true` 启用；主题不替消费者决定完整 Goldmark 策略。

## 设计铁律

1. 运行时颜色来自 `assets/css/main.css` 的 CSS token。新增颜色先更新 `DESIGN.md`，并验证正文对比度至少 `4.5:1`、大文本至少 `3:1`。
2. 暗色抬升面 `--paper-2` 上如需链接，必须先定义专用角色 token 并映射到 `DESIGN.md` 记录的舌红，不能直接使用对比度不足的 `--cinnabar`；浅档表面色只用于弱化文字、边框或装饰。
3. 正文、导航和页脚永远横排，禁止恢复 `writing-mode: vertical-rl`。
4. 新样式同时覆盖亮色纸面和暗色墨面；暗色差异通过 `[data-theme="dark"]` 或既有角色 token 表达。
5. hover 反馈必须由 `@media (hover: hover)` 门控；非必要动画必须提供 `prefers-reduced-motion` 降级。
6. `static/img/seal-yang.svg` 是无 CSS 变量上下文的固定品牌色 favicon 例外；网页内联 Logo 必须使用 token，默认社交图使用 `static/img/seal-yang-og.png`。

## 当前产品合同

- 信息架构固定为：首页、博客、标签、归档、关于；路径并不固定。
- 博客入口读取 `params.mainSections[0]`；标签、归档和 About 导航分别读取 `params.navigation.tags`、`archives`、`about`。
- `params.taxonomy.tag` 是文章 Front Matter 与 `.GetTerms` 使用的 taxonomy plural 键；`params.navigation.tags` 只负责索引页导航路径。文章标签链接必须使用 term page 的 `.RelPermalink`，禁止 `urlize` 或手工拼接 `/tags/`。
- 404 的文章入口从 `mainSections[0]` 推导；Markdown 根相对站内内容链接和普通内部社交链接经 `relLangURL` 保留项目子路径与当前语言段。
- 首页支持多篇 `pinned: true` 文章；置顶文章与普通文章分别按日期倒序。
- 归档页使用 Hugo `GroupByDate` 按年份展示日期与标题。
- 目录摘要使用 Hugo `.Summary`，为空时才回退 `.Description`；保留 140 全宽单位和最多 3 行。
- SEO description 使用页面 `.Description` → `summary-source.html` → `params.description` → `params.subtitle` →站点标题，不能与目录摘要链混写。
- 首页诗词初始使用 `data/inyo/hero_poems.toml`；远程 API 默认关闭，只在主动交互时请求，失败静默回退本地数据。
- 点击反馈为朱红双翼墨线沿 Hero 圆角边框从底部中央上行，在顶部中央合墨；非首页不得输出诗词数据、API 地址或交互脚本。

## 配置与内容边界

- 根目录 `hugo.toml`：主题模块兼容性声明，不是用户站点配置。
- `theme.toml`：Hugo 主题分发元数据。
- `config/_default/params.toml` 与 `markup.toml`：可合并的主题默认值。
- `exampleSite/hugo.yaml`：唯一规范 Demo 站点配置，只包含 Hugo 基础配置、Inyo 实际读取的参数、Demo Markdown 配置和 taxonomy。
- `scripts/fixtures/consumer-site/hugo.yaml`：自定义 `notes` section、`labels` taxonomy、class-based Chroma 和 `/blog/` 子路径的可移植性 fixture。
- `exampleSite/go.mod` 与 consumer `go.mod` 中的相对 `replace` 仅用于仓库内联调，不能写进用户配置示例。
- 文章与 `archetypes/default.md` 使用 YAML `---` Front Matter；站点示例使用 `hugo.yaml`；主题默认配置继续使用 TOML。
- 站点覆盖 `markup` 时保留 `_merge: "deep"`，避免覆盖主题的 class-based Chroma 默认值。

## 文档同步矩阵

| 改动 | 必须同步 | 主要门禁 |
| --- | --- | --- |
| 公开参数或默认值 | `config/_default/`、模板读取点、`exampleSite/hugo.yaml`、README 配置示例、相关 skill | `verify-theme.ps1`、`verify-consumer.ps1` |
| 模板、导航或 URL 行为 | `DESIGN.md`（仅设计变化）、README 特性说明、consumer fixture | 三个 `verify-*.ps1` |
| Demo 内容结构 | 六篇 Demo 文章、`about.md`、README 文档索引、`inyo-content-authoring` | `verify-theme.ps1` |
| 兼容性、CI 或发布流程 | `theme.toml`、workflow、README 双语、`CONTRIBUTING.md`、`CHANGELOG.md`、`inyo-theme-release` | CI 与全部本地门禁 |
| 设计 token 或动效 | `DESIGN.md`、`assets/css/main.css`、必要的 AGENTS/skill 约束 | 颜色、a11y、Hero smoke + 浏览器复核 |

README 面向主题用户，CONTRIBUTING 面向贡献者，AGENTS 面向代理，skills 只描述操作流程。避免在四处复制同一段细节。中文与英文 README 的功能、安装、验证和路线图语义必须一致。CHANGELOG 只记录已经实现的变更。

维护文档和项目 skills 使用三个反引号代码围栏；通用命令块标记为 `shell`，不使用 `~~~`、`powershell` 或 `pwsh` 围栏。

## 项目 skills 路由

- 模板、CSS、配置或交互：`inyo-theme-development`。
- Demo 文章、About、Front Matter 或 Markdown 展示：`inyo-content-authoring`。
- README、CHANGELOG、CI、Pages、consumer 或发布：`inyo-theme-release`。
- 选色与对比度：按需组合 `xxd-palette-builder`、`xxd-accessible-color`、`xxd-existing-design-audit` 与 `color-harmony-oklch`。

skill 与本文件、`DESIGN.md` 或源码冲突时，必须修 skill，不得用 skill 覆盖事实源。

## 验证流程

从仓库根目录运行：

```shell
hugo --source exampleSite --minify --printPathWarnings
pwsh -File scripts/verify-theme.ps1
pwsh -File scripts/verify-consumer.ps1
pwsh -File scripts/verify-hugo-basic-example.ps1
git diff --check
```

涉及视觉或交互时再运行 `hugo server --source exampleSite`，检查亮暗模式、桌面与 `390×844`、键盘焦点、reduced motion、Hero 首页边界和横向溢出。

验证产生的 `public/`、`resources/`、`.hugo_build.lock` 和临时输出不得提交。自托管字体 URL 必须保持相对于生成 CSS 的 `../fonts/` 路径。

## 提交与发布

- 保留用户已有工作区修改，只暂存本次任务的显式路径。
- 提交前缀使用 `feat:`、`fix:`、`docs:`、`design:`、`style:`、`chore:`、`perf:`、`refactor:` 或 `test:`。
- 补丁、次版本和主版本遵循 SemVer；实际版本号从 CHANGELOG、Git tag 和用户发布目标确定，不在规范中硬编码“下一个版本”。
- 只有用户明确要求时才 commit、tag、push、创建 PR 或 GitHub Release。
