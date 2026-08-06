# Inyo 陰陽

> 纸墨二元 · 日式极简 × 昭和レトロ × 古中国水墨 — Hugo 博客主题

**Inyo（陰陽）** 是一个为长文阅读设计的 Hugo 博客主题。亮色模式是墨在纸上（荼蘼白宣纸底 + 墨色正文），暗色模式是白墨在墨底（剑锋紫夜墨底 + 月白正文）。朱砂红是唯一的情绪色——像一枚印章盖在整个站点上。

## 特性

- 🌗 **纸墨双模式**：亮 = 荼蘼白宣纸，暗 = 剑锋紫夜墨，10 行内联 JS 切换，零依赖
- 🖋️ **全站只有一个情绪色**：朱砂红（链接/印章/按钮），60/25/10/5 用色纪律
- 📖 **长文优先**：40em 容器、中文行高 2.0、标题字距拉开——东方式排版
- 🎨 **全部颜色出自《中华传统色》742 色库**：每个 token 有真实色名（荼蘼白、松烟墨、剑锋紫、舌红、晓灰、云峰灰…），全部通过 WCAG AA 实测
- 🔖 **印章 Logo + 竖排题款**：朱砂红印章 SVG（阴/阳文），页脚竖排签名（装饰性，正文横排）
- 🧮 **数学公式开关**：`params.math = true` 启用 KaTeX
- 📐 **可定制**：全 CSS 变量 token 体系，改配色不用碰模板
- 🔤 **多语言**：i18n（zh-cn / en / ja），按 Hugo 标准处理

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
# 文人变体正文（楷体，OFL 开源）；默认 "serif"（思源宋体）
font = "wenkai"
# 是否从 CDN 加载当前字体
webfonts = true
# 数学公式
math = true
# 页脚竖排签名（装饰性）
vertical_footer = "行到水穷处"
# 印章内容（1–4 字最佳）与样式
seal_text = "陰陽"
seal_style = "yang" # yang=阳文（朱文）/ yin=阴文（白文）
```

## 目录结构

```
hugo-theme-inyo/
├── DESIGN.md        # 设计文档（配色 token 权威来源 + ADR）
├── AGENTS.md        # AI 编码代理规范
├── layouts/         # 模板
├── assets/css/      # main.css —— CSS 变量 token 体系
├── static/img/      # 印章、毛笔分隔线 SVG
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
