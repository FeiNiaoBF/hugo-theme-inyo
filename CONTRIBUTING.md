# 贡献 Inyo

感谢你关注 Inyo。欢迎通过 Issue、文档改进、示例内容和 Pull Request 帮助完善这个中文优先的 Hugo 主题。

## 开始之前

请先了解：

- [README.md](README.md)：项目定位、安装方式和文档入口
- [DESIGN.md](DESIGN.md)：视觉方向、颜色 token 和交互约束
- [AGENTS.md](AGENTS.md)：主题开发规则
- [CHANGELOG.md](CHANGELOG.md)：版本与变更记录

Inyo 目前处于早期可用阶段。提交功能改动前，请先说明使用场景、影响范围和验证方式。

## 本地开发

环境要求：

- Hugo Extended `>= 0.164.0`
- Go `>= 1.26.1`（Hugo Modules 和 consumer fixture 需要）
- PowerShell 7（smoke 脚本需要）

启动 Demo：

```shell
hugo server --source exampleSite
```

如果需要同时修改主题源码和 Demo，请保留 `exampleSite/go.mod` 中的相对 `replace`。用户配置示例只写正式 Module 路径，不要把本地 `replace` 或绝对路径写进 `exampleSite/hugo.yaml`。

## 修改约束

- 颜色必须来自 `assets/css/main.css` 的 token；
- 运行时不引入前端框架、动画库或额外依赖；
- Hero 只在首页输出，远程诗词 API 必须有本地 fallback；
- 新增动画必须支持 `prefers-reduced-motion: reduce`；
- 正文、导航和页脚保持横排；
- 自托管资源不能假定站点部署在根路径；
- 主题必须继续支持自定义 section、taxonomy 和 `/blog/` 子路径；
- 不提交 `public/`、`resources/` 或锁文件等构建产物。

## 文档与配置同步

配置、模板和文档不是彼此独立的副本。改动公开行为时，请按下面的最小范围同步：

| 改动 | 同步位置 |
| --- | --- |
| Inyo 参数 | `config/_default/`、模板读取点、`exampleSite/hugo.yaml`、README 示例、smoke 断言 |
| 导航或 URL | 默认 Demo、consumer fixture、README 特性说明、可移植性测试 |
| Demo 文章 | 六篇文章、`exampleSite/content/about.md`、README 文档索引、内容 authoring skill |
| 发布或兼容性 | README 双语、CHANGELOG、workflow、release skill |
| 设计 token 或动效 | `DESIGN.md`、CSS、必要的 AGENTS/skill 规则和浏览器复核 |

维护文档使用三个反引号代码围栏；通用命令块使用 `shell`。

## 提交前验证

从仓库根目录运行：

```shell
hugo --source exampleSite --minify --printPathWarnings
pwsh -File scripts/verify-theme.ps1
pwsh -File scripts/verify-consumer.ps1
pwsh -File scripts/verify-hugo-basic-example.ps1
git diff --check
```

请确认 Git 状态中没有以下构建产物：

```text
exampleSite/public/
exampleSite/resources/
exampleSite/.hugo_build.lock
scripts/fixtures/consumer-site/.hugo_build.lock
```

## Pull Request 建议

一个 Pull Request 尽量只解决一个主题问题，并在描述中包含：

1. 改动目的和用户场景；
2. 影响的模板、配置或文档；
3. 自动化验证结果；
4. 需要手动浏览器复核的内容；
5. 是否涉及视觉、颜色、a11y 或兼容性变化。

提交信息可以使用以下前缀：

```text
feat: 新增功能
fix: 修复问题
docs: 更新文档
design: 调整设计
test: 更新验证
chore: 工程维护
```

## Issue

提交 Issue 时请尽量提供：

- Hugo 和 Go 版本；
- 主题安装方式；
- 站点配置片段；
- 最小复现步骤；
- 预期结果与实际结果；
- 浏览器和视口信息（如果是视觉或交互问题）。

## 致谢与参考

Inyo 的设计和实现借鉴了以下开源项目与工具：

- [zhongguo-traditional-colors](https://github.com/nevertoday/zhongguo-traditional-colors)：中国传统色资料与配色研究参考；
- [pianpker](https://pianpker.pages.dev/) 与 [astro-theme-pianpker](https://github.com/DRAG0NM/astro-theme-pianpker)：编辑感、长文阅读与视觉表达参考；
- [LXGW WenKai](https://github.com/lxgw/LxgwWenKai)：默认自托管字体；
- [Hugo](https://github.com/gohugoio/hugo)：静态站点生成器与主题生态基础。

Inyo 的模板、样式、交互和集成代码由本项目维护；上述项目的许可证和版权归其原作者所有。
