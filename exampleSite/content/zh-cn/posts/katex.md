---
title: "把公式写进文章：KaTeX"
date: 2026-08-11T09:00:00+08:00
description: "展示 Inyo 页面级 KaTeX 开关和常见数学公式写法。"
summary: "公式不一定只出现在论文里，读书笔记、数据记录和技术文章都会用到它。这里从行内公式开始，展示分式、求和、矩阵、分段函数和对齐公式。"
categories:
  - 写作
tags:
  - KaTeX
  - 数学
  - Markdown
math: true
---

我喜欢在笔记里保留公式原来的样子。与其把一个推导拆成几行难以复制的文字，不如直接让它成为文章的一部分。Inyo 的数学资源是页面级开关，只有这篇文章需要公式时，才在 Front Matter 写上 `math: true`。

## 行内公式

行内公式适合放在一句话里，例如质能关系写作 $E = mc^2$。它不会把段落撑开，读者可以顺着文字继续往下读。

## 独立公式

需要单独停下来看的公式，可以使用双美元符号：

$$
\sum_{k=1}^{n} k = \frac{n(n+1)}{2}
$$

分式、根号和积分都可以保持原来的结构：

$$
\int_{0}^{1} x^2\,dx = \frac{1}{3}
$$

## 对齐公式

多行推导使用 `aligned`，等号可以保持在同一列：

$$
\begin{aligned}
f(x) &= x^2 + 2x + 1 \\
     &= (x + 1)^2
\end{aligned}
$$

## 矩阵和分段函数

矩阵适合放在线性代数、变换或数据记录里：

$$
A =
\begin{bmatrix}
1 & 2 \\
3 & 4
\end{bmatrix}
$$

分段函数则可以把条件写在公式里：

$$
g(x) =
\begin{cases}
x^2, & x \geq 0 \\
-x, & x < 0
\end{cases}
$$

页面里不需要公式时，不要为了统一而开启 `math`。这样浏览器少加载一组资源，文章也能保持轻量。需要更紧凑的 Markdown 组织方式，可以回到 [Markdown 高效写作](/posts/markdown-efficient/)。

## 下一步

- 看看 [Markdown 基础：先把字排好](/posts/markdown-basics/)，复习图片、代码块和表格。
- 如果对主题为什么这样设计感兴趣，可以读[纸、墨与朱红：Inyo 想留下什么](/posts/brand-design/)。

