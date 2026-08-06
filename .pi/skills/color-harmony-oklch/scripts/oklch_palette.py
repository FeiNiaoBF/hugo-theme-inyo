#!/usr/bin/env python3
"""Reference OKLCH harmony and WCAG contrast utilities for Inyo.

Sources:
- Björn Ottosson's OKLab conversion matrices:
  https://bottosson.github.io/posts/oklab/
- WCAG 2.2 relative luminance and contrast:
  https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html

The implementation uses only the Python standard library.
"""

from __future__ import annotations

import argparse
import csv
import json
import math
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Iterable, Sequence

RGB = tuple[float, float, float]


@dataclass(frozen=True)
class OKLab:
    L: float
    a: float
    b: float


@dataclass(frozen=True)
class OKLCH:
    L: float
    C: float
    H: float


@dataclass(frozen=True)
class ContrastSearchResult:
    hex: str
    oklch: OKLCH
    contrast: float
    direction: str
    clipped: bool
    generated: bool = True


@dataclass(frozen=True)
class PaletteCandidate:
    number: str
    name: str
    hex: str
    contrast: float
    hue_delta: float
    distance: float
    oklch: OKLCH


DEFAULT_PALETTE_CSV = (
    Path(__file__).resolve().parents[2]
    / "xxd-palette-builder"
    / "references"
    / "chinese-color-harmony.csv"
)


def clamp(value: float, low: float = 0.0, high: float = 1.0) -> float:
    return max(low, min(high, value))


def normalize_hex(value: str) -> str:
    text = value.strip().lstrip("#")
    if len(text) == 3:
        text = "".join(channel * 2 for channel in text)
    if len(text) != 6 or any(character not in "0123456789abcdefABCDEF" for character in text):
        raise ValueError(f"Expected #RGB or #RRGGBB, got {value!r}")
    return f"#{text.upper()}"


def hex_to_srgb(value: str) -> RGB:
    text = normalize_hex(value)[1:]
    return tuple(int(text[index : index + 2], 16) / 255.0 for index in (0, 2, 4))  # type: ignore[return-value]


def srgb_to_hex(rgb: Sequence[float]) -> str:
    channels = [round(clamp(channel) * 255) for channel in rgb]
    return "#" + "".join(f"{channel:02X}" for channel in channels)


def srgb_channel_to_linear(channel: float) -> float:
    return channel / 12.92 if channel <= 0.04045 else ((channel + 0.055) / 1.055) ** 2.4


def linear_channel_to_srgb(channel: float) -> float:
    return 12.92 * channel if channel <= 0.0031308 else 1.055 * channel ** (1 / 2.4) - 0.055


def srgb_to_linear(rgb: Sequence[float]) -> RGB:
    return tuple(srgb_channel_to_linear(channel) for channel in rgb)  # type: ignore[return-value]


def linear_to_srgb(rgb: Sequence[float]) -> RGB:
    return tuple(linear_channel_to_srgb(channel) for channel in rgb)  # type: ignore[return-value]


def _cbrt(value: float) -> float:
    return math.copysign(abs(value) ** (1 / 3), value)


def linear_srgb_to_oklab(rgb: Sequence[float]) -> OKLab:
    """Convert linear sRGB directly to OKLab using Ottosson's matrices."""
    red, green, blue = rgb
    light = 0.4122214708 * red + 0.5363325363 * green + 0.0514459929 * blue
    medium = 0.2119034982 * red + 0.6806995451 * green + 0.1073969566 * blue
    short = 0.0883024619 * red + 0.2817188376 * green + 0.6299787005 * blue

    light_root = _cbrt(light)
    medium_root = _cbrt(medium)
    short_root = _cbrt(short)

    return OKLab(
        0.2104542553 * light_root + 0.7936177850 * medium_root - 0.0040720468 * short_root,
        1.9779984951 * light_root - 2.4285922050 * medium_root + 0.4505937099 * short_root,
        0.0259040371 * light_root + 0.7827717662 * medium_root - 0.8086757660 * short_root,
    )


def oklab_to_linear_srgb(color: OKLab) -> RGB:
    light_root = color.L + 0.3963377774 * color.a + 0.2158037573 * color.b
    medium_root = color.L - 0.1055613458 * color.a - 0.0638541728 * color.b
    short_root = color.L - 0.0894841775 * color.a - 1.2914855480 * color.b

    light = light_root**3
    medium = medium_root**3
    short = short_root**3

    return (
        4.0767416621 * light - 3.3077115913 * medium + 0.2309699292 * short,
        -1.2684380046 * light + 2.6097574011 * medium - 0.3413193965 * short,
        -0.0041960863 * light - 0.7034186147 * medium + 1.7076147010 * short,
    )


def srgb_to_oklab(rgb: Sequence[float]) -> OKLab:
    return linear_srgb_to_oklab(srgb_to_linear(rgb))


def oklab_to_srgb(color: OKLab, *, clip: bool = True) -> RGB:
    rgb = linear_to_srgb(oklab_to_linear_srgb(color))
    if clip:
        return tuple(clamp(channel) for channel in rgb)  # type: ignore[return-value]
    return rgb


def oklab_to_oklch(color: OKLab) -> OKLCH:
    chroma = math.hypot(color.a, color.b)
    hue = math.degrees(math.atan2(color.b, color.a)) % 360 if chroma > 1e-12 else 0.0
    return OKLCH(color.L, chroma, hue)


def oklch_to_oklab(color: OKLCH) -> OKLab:
    radians = math.radians(color.H)
    return OKLab(color.L, color.C * math.cos(radians), color.C * math.sin(radians))


def hex_to_oklch(value: str) -> OKLCH:
    return oklab_to_oklch(srgb_to_oklab(hex_to_srgb(value)))


def oklch_to_srgb(color: OKLCH, *, clip: bool = True) -> RGB:
    return oklab_to_srgb(oklch_to_oklab(color), clip=clip)


def oklch_to_hex(color: OKLCH) -> str:
    return srgb_to_hex(oklch_to_srgb(color))


def is_in_srgb_gamut(rgb: Sequence[float], tolerance: float = 1e-9) -> bool:
    return all(-tolerance <= channel <= 1 + tolerance for channel in rgb)


def relative_luminance(color: str | Sequence[float]) -> float:
    rgb = hex_to_srgb(color) if isinstance(color, str) else tuple(color)
    red, green, blue = srgb_to_linear(rgb)
    return 0.2126 * red + 0.7152 * green + 0.0722 * blue


def contrast_ratio(foreground: str | Sequence[float], background: str | Sequence[float]) -> float:
    lighter, darker = sorted(
        (relative_luminance(foreground), relative_luminance(background)), reverse=True
    )
    return (lighter + 0.05) / (darker + 0.05)


def hue_distance(first: float, second: float) -> float:
    difference = abs((first - second) % 360)
    return min(difference, 360 - difference)


def harmony_relation(first_hue: float, second_hue: float) -> str | None:
    delta = hue_distance(first_hue, second_hue)
    if delta <= 30:
        return "adjacent"
    if 110 <= delta <= 130:
        return "triadic"
    if 150 <= delta <= 180:
        return "complementary"
    return None


def oklab_distance(first: OKLab, second: OKLab) -> float:
    return math.sqrt(
        (first.L - second.L) ** 2
        + (first.a - second.a) ** 2
        + (first.b - second.b) ** 2
    )


def search_lightness_for_contrast(
    anchor_hex: str,
    background_hex: str,
    *,
    target: float = 4.5,
    direction: str = "auto",
    iterations: int = 48,
) -> ContrastSearchResult:
    """Move only OKLCH L until the rendered sRGB color reaches target contrast."""
    if target < 1:
        raise ValueError("Contrast target must be at least 1")
    if direction not in {"auto", "dark", "light"}:
        raise ValueError("direction must be auto, dark, or light")

    anchor_value = normalize_hex(anchor_hex)
    anchor = hex_to_oklch(anchor_value)
    background = normalize_hex(background_hex)
    anchor_ratio = contrast_ratio(anchor_value, background)
    if anchor_ratio >= target:
        return ContrastSearchResult(
            anchor_value,
            anchor,
            anchor_ratio,
            "unchanged",
            False,
            generated=False,
        )

    if direction == "auto":
        dark_capacity = contrast_ratio("#000000", background)
        light_capacity = contrast_ratio("#FFFFFF", background)
        direction = "dark" if dark_capacity >= light_capacity else "light"

    def rendered(lightness: float) -> tuple[str, float, bool]:
        candidate = OKLCH(lightness, anchor.C, anchor.H)
        raw_rgb = oklch_to_srgb(candidate, clip=False)
        value = srgb_to_hex(raw_rgb)
        return value, contrast_ratio(value, background), not is_in_srgb_gamut(raw_rgb)

    if direction == "dark":
        low, high = 0.0, 0.5
        endpoint_hex, endpoint_ratio, _ = rendered(low)
        if endpoint_ratio < target:
            raise ValueError(
                f"No dark solution reaches {target:.2f}:1; endpoint {endpoint_hex} is {endpoint_ratio:.2f}:1"
            )
        for _ in range(iterations):
            middle = (low + high) / 2
            _, ratio, _ = rendered(middle)
            if ratio >= target:
                low = middle
            else:
                high = middle
        lightness = low
        adjustment = -1e-4
    else:
        low, high = 0.5, 1.0
        endpoint_hex, endpoint_ratio, _ = rendered(high)
        if endpoint_ratio < target:
            raise ValueError(
                f"No light solution reaches {target:.2f}:1; endpoint {endpoint_hex} is {endpoint_ratio:.2f}:1"
            )
        for _ in range(iterations):
            middle = (low + high) / 2
            _, ratio, _ = rendered(middle)
            if ratio >= target:
                high = middle
            else:
                low = middle
        lightness = high
        adjustment = 1e-4

    # Quantizing to 8-bit HEX can move a boundary result just below target.
    for _ in range(5001):
        value, ratio, clipped = rendered(lightness)
        if ratio >= target:
            return ContrastSearchResult(
                value,
                OKLCH(lightness, anchor.C, anchor.H),
                ratio,
                direction,
                clipped,
            )
        lightness = clamp(lightness + adjustment)

    raise RuntimeError("Could not retain target contrast after 8-bit quantization")


def load_traditional_colors(csv_path: Path = DEFAULT_PALETTE_CSV) -> list[dict[str, str]]:
    with csv_path.open("r", encoding="utf-8-sig", newline="") as handle:
        rows = list(csv.DictReader(handle))
    required = {"编号", "色名", "HEX"}
    if not rows or not required.issubset(rows[0]):
        raise ValueError(f"Palette CSV must contain {sorted(required)}: {csv_path}")
    return rows


def rank_traditional_candidates(
    anchor_hex: str,
    background_hex: str,
    *,
    csv_path: Path = DEFAULT_PALETTE_CSV,
    max_hue_delta: float = 45.0,
    min_contrast: float = 4.5,
    min_chroma: float = 0.02,
) -> list[PaletteCandidate]:
    anchor_lch = hex_to_oklch(anchor_hex)
    if anchor_lch.C < 0.02:
        raise ValueError("Anchor chroma is too low for a meaningful hue filter")
    anchor_lab = oklch_to_oklab(anchor_lch)

    candidates: list[PaletteCandidate] = []
    for row in load_traditional_colors(csv_path):
        value = normalize_hex(row["HEX"])
        candidate_lch = hex_to_oklch(value)
        delta = hue_distance(anchor_lch.H, candidate_lch.H)
        ratio = contrast_ratio(value, background_hex)
        if delta > max_hue_delta or ratio < min_contrast or candidate_lch.C < min_chroma:
            continue
        candidates.append(
            PaletteCandidate(
                number=row["编号"],
                name=row["色名"],
                hex=value,
                contrast=ratio,
                hue_delta=delta,
                distance=oklab_distance(anchor_lab, oklch_to_oklab(candidate_lch)),
                oklch=candidate_lch,
            )
        )
    return sorted(candidates, key=lambda candidate: candidate.distance)


def _rounded_oklch(color: OKLCH) -> dict[str, float]:
    return {"L": round(color.L, 6), "C": round(color.C, 6), "H": round(color.H, 3)}


def _candidate_payload(candidates: Iterable[PaletteCandidate]) -> list[dict[str, object]]:
    payload: list[dict[str, object]] = []
    for candidate in candidates:
        item = asdict(candidate)
        item["contrast"] = round(candidate.contrast, 3)
        item["hue_delta"] = round(candidate.hue_delta, 3)
        item["distance"] = round(candidate.distance, 6)
        item["oklch"] = _rounded_oklch(candidate.oklch)
        payload.append(item)
    return payload


def run_self_test() -> dict[str, object]:
    cinnabar = hex_to_oklch("#D92121")
    if abs(cinnabar.H - 27.6) > 0.2:
        raise AssertionError(f"Cinnabar hue expected about 27.6°, got {cinnabar.H:.3f}°")

    white_rgb = hex_to_srgb("#FFFFFF")
    white_round_trip = oklab_to_srgb(srgb_to_oklab(white_rgb))
    max_error = max(abs(actual * 255 - 255) for actual in white_round_trip)
    if max_error >= 1:
        raise AssertionError(f"White round-trip channel error must be <1, got {max_error}")

    if abs(contrast_ratio("#000000", "#FFFFFF") - 21) > 1e-9:
        raise AssertionError("Black/white contrast must be 21:1")

    unchanged = search_lightness_for_contrast("#D92121", "#F8F4F0", target=4.5)
    darkened = search_lightness_for_contrast("#F19790", "#F8F4F0", target=4.5)
    lightened = search_lightness_for_contrast("#D92121", "#3E3841", target=4.5)
    if unchanged.contrast < 4.5 or unchanged.generated:
        raise AssertionError("A passing anchor must be preserved")
    if darkened.contrast < 4.5 or darkened.direction != "dark":
        raise AssertionError("Dark contrast search did not meet target")
    if lightened.contrast < 4.5 or lightened.direction != "light":
        raise AssertionError("Light contrast search did not meet target")

    return {
        "cinnabar_hue": round(cinnabar.H, 3),
        "white_round_trip_max_8bit_error": max_error,
        "black_white_contrast": contrast_ratio("#000000", "#FFFFFF"),
        "contrast_search": {
            "unchanged": {
                "hex": unchanged.hex,
                "contrast": round(unchanged.contrast, 3),
                "generated": unchanged.generated,
            },
            "dark": {
                "hex": darkened.hex,
                "contrast": round(darkened.contrast, 3),
                "generated": darkened.generated,
            },
            "light": {
                "hex": lightened.hex,
                "contrast": round(lightened.contrast, 3),
                "generated": lightened.generated,
            },
        },
    }


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    subparsers = parser.add_subparsers(dest="command", required=True)

    analyze = subparsers.add_parser("analyze", help="Convert HEX to OKLCH")
    analyze.add_argument("hex")

    contrast = subparsers.add_parser("contrast", help="Measure WCAG contrast")
    contrast.add_argument("foreground")
    contrast.add_argument("background")

    search = subparsers.add_parser("search", help="Search OKLCH L for target contrast")
    search.add_argument("anchor")
    search.add_argument("background")
    search.add_argument("--target", type=float, default=4.5)
    search.add_argument("--direction", choices=("auto", "dark", "light"), default="auto")

    rank = subparsers.add_parser("rank", help="Rank matching colors from the 742-color dataset")
    rank.add_argument("anchor")
    rank.add_argument("background")
    rank.add_argument("--csv", type=Path, default=DEFAULT_PALETTE_CSV)
    rank.add_argument("--limit", type=int, default=10)
    rank.add_argument("--max-hue-delta", type=float, default=45.0)
    rank.add_argument("--min-contrast", type=float, default=4.5)
    rank.add_argument("--min-chroma", type=float, default=0.02)

    subparsers.add_parser("self-test", help="Run known-value assertions")
    return parser


def main() -> None:
    args = build_parser().parse_args()

    if args.command == "analyze":
        color = hex_to_oklch(args.hex)
        payload = {
            "hex": normalize_hex(args.hex),
            "oklch": _rounded_oklch(color),
            "relative_luminance": round(relative_luminance(args.hex), 6),
        }
    elif args.command == "contrast":
        payload = {
            "foreground": normalize_hex(args.foreground),
            "background": normalize_hex(args.background),
            "contrast": round(contrast_ratio(args.foreground, args.background), 3),
        }
    elif args.command == "search":
        result = search_lightness_for_contrast(
            args.anchor,
            args.background,
            target=args.target,
            direction=args.direction,
        )
        payload = asdict(result)
        payload["oklch"] = _rounded_oklch(result.oklch)
        payload["contrast"] = round(result.contrast, 3)
    elif args.command == "rank":
        candidates = rank_traditional_candidates(
            args.anchor,
            args.background,
            csv_path=args.csv,
            max_hue_delta=args.max_hue_delta,
            min_contrast=args.min_contrast,
            min_chroma=args.min_chroma,
        )
        payload = {
            "anchor": normalize_hex(args.anchor),
            "background": normalize_hex(args.background),
            "filters": {
                "max_hue_delta": args.max_hue_delta,
                "min_contrast": args.min_contrast,
                "min_chroma": args.min_chroma,
            },
            "candidates": _candidate_payload(candidates[: max(args.limit, 0)]),
        }
    else:
        payload = run_self_test()

    print(json.dumps(payload, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
