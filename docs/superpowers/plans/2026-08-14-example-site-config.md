# ExampleSite Hugo 配置完整化计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` or `superpowers:subagent-driven-development` to implement this plan task-by-task.

**Goal：** 基于 Hugo 官方配置规范和 Inyo 当前模板接口，补齐 `exampleSite/hugo.toml` 的可运行示例与注释说明。

## Scope

- 启用 Demo 实际使用的站点身份、语言、模块、主题参数、Markdown、taxonomy、输出格式和 sitemap 配置。
- 将当前主题未使用但常见的博客配置保留为注释示例，并注明启用前需要同步模板或内容。
- 不把主题运行时默认配置重复搬入根站点；站点文件只展示消费者需要覆盖或明确理解的参数。
- 不新增分页、搜索、评论或菜单运行时功能。

## Tasks

- [x] 在主题 smoke 中增加 `exampleSite/hugo.toml` 完整配置合同，使现状先失败。
- [x] 按 Hugo 官方字段重写 `exampleSite/hugo.toml`，启用配置保持干净，未启用配置保留注释说明。
- [x] 若示例站点地址发生调整，同步 README 中的示例地址。
- [x] 运行 Demo、consumer、官方 Hugo Basic Example 和 diff 检查，清理构建产物。

## Verification

```shell
hugo --source exampleSite --minify --printPathWarnings
pwsh -File scripts/verify-theme.ps1
pwsh -File scripts/verify-consumer.ps1
pwsh -File scripts/verify-hugo-basic-example.ps1
git diff --check
```
