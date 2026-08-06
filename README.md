# Inyo 陰陽

> 纸墨二元 · 日式现代简约 × 古中国水墨 — Hugo 博客主题

**Inyo（陰陽）** 是一个为长文阅读设计的 Hugo 博客主题。亮色模式是墨在纸上（荼蘼白宣纸底 + 墨色正文），暗色模式是白墨在墨（墨色夜墨底 + 月白正文）。朱砂红是唯一的情绪色——像一枚印章盖在整个站点上。

## 特性

- 🌗 **纸墨双模式**：亮 = 荼蘼白宣纸，暗 = 墨色夜墨，10 行内联 JS 切换，零依赖
- 🖋️ **全站只有一个情绪色**：朱砂红（链接/印章/按钮），60/25/10/5 用色纪律
- 📖 **长文优先**：40em 容器、中文行高 2.0、标题字距拉开——东方式排版
- 🎨 **全部颜色出自《中华传统色》742 色库**：每个 token 有真实色名（荼蘼白、墨色、朱砂红、朱红、晓灰、云峰灰…），全部通过 WCAG AA 实测
- 🔖 **传统印章 Logo**：白文印（朱砂底白字）/ 朱文印两版，双模式不变色
- 🧭 **顶部导航 + 右侧身份栏**（pianpker 式）：气质签名、社交链接（`/` 分隔）、语言切换、主题切换
- 🧮 **数学公式开关**：`params.math = true` 启用 KaTeX（保留自带字体）
- 📐 **可定制**：全 CSS 变量 token 体系，改配色不用碰模板
- 🔤 **多语言**：i18n（zh-cn / en / ja）+ 语言切换器（Hugo 多语言站点自动显示）

## 安装

### Hugo Modules（推荐）

```toml
# hugo.yaml
module:
  imports:
    - path: github.com/FeiNiaoBF/hugo-theme-inyo
```

```bash
hugo mod tidy
```

本地开发可用 `replace` 指向本地路径：

```toml
module:
  imports:
    - path: github.com/FeiNiaoBF/hugo-theme-inyo
  replacements:
    github.com/FeiNiaoBF/hugo-theme-inyo: ../hugo-theme-inyo
```

### 经典 themes/ 目录

```bash
git clone https://github.com/FeiNiaoBF/hugo-theme-inyo.git themes/inyo
```

```yaml
theme: inyo
```

## 配置

```toml
[params]
# 正文字体：wenkai（霞鹜文楷，默认，OFL 开源）| serif（思源宋体）
font = "wenkai"
# 是否从 CDN 加载当前字体
webfonts = true
# 数学公式
math = true
# 站名下的气质签名（副标题）
subtitle = "纸墨二元 · 落字有间"
# 顶部导航诗句（二期动画占位，留空不显示）
verse = ""
# 印章内容（1–4 字最佳）与样式
seal_text = "陰陽"
seal_style = "yin" # yin=阴文（白文，默认）/ yang=阳文（朱文）

# 社交链接（右侧栏渲染，/ 分隔）
[[params.social]]
name = "GitHub"
url = "https://github.com/FeiNiaoBF/hugo-theme-inyo"

[[params.social]]
name = "RSS"
url = "/index.xml"
```

## 多语言

主题内置 zh-cn / en / ja 翻译与语言切换器；Hugo 站点配置多个 `[languages.*]` 后，右侧栏自动显示语言切换。

## 目录结构

```
hugo-theme-inyo/
├── DESIGN.md        # 设计文档（配色 token 权威来源 + ADR）
├── AGENTS.md        # AI 编码代理规范
├── layouts/         # 模板
├── assets/css/      # main.css —— CSS 变量 token 体系
├── static/img/      # 印章 SVG（白文/朱文两版）
└── exampleSite/     # 演示站点（hugo server --source exampleSite）
```

## 演示

```bash
cd exampleSite
hugo mod tidy
hugo server
```

## 许可

MIT © FeiNiaoBF

---

配色与设计决策的完整记录见 [DESIGN.md](DESIGN.md)。
