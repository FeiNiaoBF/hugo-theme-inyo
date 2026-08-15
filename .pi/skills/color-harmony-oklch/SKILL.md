---
name: color-harmony-oklch
description: Use when 需要 OKLCH 感知色相和谐分析或对比度目标驱动选色（UI/主题配色）。
metadata:
  category: design
---

# Color Harmony with OKLCH

## Overview

在 `xxd-*` 技能的“742 库点名 + WCAG 检查”之上补充两层项目独有算法：**OKLCH 感知和谐**与**对比度目标驱动明度搜索**。

方法依据：

- Björn Ottosson, *A perceptual color space for image processing* (2020)：https://bottosson.github.io/posts/oklab/
- Cohen-Or et al., *Color Harmonization*, SIGGRAPH 2006（ETH Zurich 项目页与论文）：https://igl.ethz.ch/projects/color-harmonization/
- W3C WCAG 2.2 Contrast Minimum：https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html
- OKHST 实践文章（“lightness is not contrast”）：https://tenphi.me/blog/okhst-predictable-color-generation/

核心认识：**OKLCH 明度不是 WCAG 对比度**。和谐关系在感知空间判断，最终可读性必须回到实际 sRGB 相对亮度计算。

## 算法步骤

1. **sRGB → OKLCH**
   - sRGB gamma 解码为 linear sRGB。
   - 使用 Ottosson 的 `0.4122214708…` 矩阵直接完成 linear sRGB → LMS。
   - 对 LMS 分量开立方，再变换到 OKLab `L/a/b`。
   - `C = hypot(a, b)`；`H = atan2(b, a)` 并归一化到 `[0°, 360°)`。
2. **和谐模板判据**
   - 邻近：圆周色相差 `ΔH ≤ 30°`。
   - 三角：`110° ≤ ΔH ≤ 130°`。
   - 互补：以 180° 为中心，原始模板范围 `150°–210°`；使用最短圆周差时等价为 `150°–180°`。
3. **对比度目标驱动**
   - 固定 hue 和 chroma，只搜索 OKLCH `L`。
   - 亮底搜暗端：`L ∈ [0, 0.5]`，寻找满足目标的最高 L。
   - 暗底搜亮端：`L ∈ [0.5, 1]`，寻找满足目标的最低 L。
   - 每一步转回实际 sRGB，并按 WCAG `(L1+0.05)/(L2+0.05)` 验证；默认目标为 4.5:1。
4. **742 库点名**
   - 从 `.pi/skills/xxd-palette-builder/references/chinese-color-harmony.csv` 读取候选。
   - 过滤：`ΔH ≤ 45°`、对比度 ≥4.5:1、OKLCH `C ≥ 0.02`。
   - 按 OKLab 感知距离排序，输出色名、HEX、色相差、距离和实测对比度。
   - 无库内候选时才允许“固定 H/C、移动 L”的兜底，并明确标注为算法生成色，而非 742 库原色。

## 参考脚本

`scripts/oklch_palette.py` 是无第三方依赖的参考实现，包含：

- sRGB gamma 编解码
- sRGB ↔ OKLab ↔ OKLCH
- WCAG 相对亮度与对比度
- 色相差与和谐关系分类
- 固定 H/C 的目标对比度二分搜索
- 742 色 CSV 过滤与感知距离排序
- 已知真值自测与命令行入口

```shell
python .pi/skills/color-harmony-oklch/scripts/oklch_palette.py self-test
python .pi/skills/color-harmony-oklch/scripts/oklch_palette.py analyze '#D92121'
python .pi/skills/color-harmony-oklch/scripts/oklch_palette.py contrast '#D92121' '#F8F4F0'
python .pi/skills/color-harmony-oklch/scripts/oklch_palette.py search '#D92121' '#F8F4F0' --target 4.5
python .pi/skills/color-harmony-oklch/scripts/oklch_palette.py rank '#D92121' '#F8F4F0' --limit 10
```

## 两个必须记住的 bug 坑

1. **禁止重复应用颜色空间矩阵。** Ottosson 的 `0.4122214708…` 矩阵是 linear sRGB → LMS 的直接矩阵，不是 XYZ 矩阵。不要先做 sRGB → XYZ，再乘 `0.8189…` 的 XYZ → LMS 矩阵；双重变换会扭曲全部色相。
2. **不要把 gamma 编码和解码写反。** linear → sRGB 编码使用 `1.055*c^(1/2.4)-0.055`；`((c+0.055)/1.055)^2.4` 是 sRGB → linear 解码。方向反转会破坏往返转换、插值和对比度。

## 验证清单

- [ ] 朱砂红 `#D92121` 的 OKLCH 色相约为 `27.6°`。
- [ ] 白色 `#FFFFFF` 往返转换的最大 8-bit 通道误差 `<1`。
- [ ] 所有输出色均附带实测对比度。
- [ ] 库外兜底色明确标注“算法生成”，不冒充 742 库点名色。
