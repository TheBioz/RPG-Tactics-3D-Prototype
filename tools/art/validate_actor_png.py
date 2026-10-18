#!/usr/bin/env python3
"""Mechanical PNG checks for the PC-001 production test (not an art-style classifier).
Usage: python tools/art/validate_actor_png.py path/to/actor.png --stage runtime
"""
from __future__ import annotations
import argparse
import json
from pathlib import Path
from PIL import Image


def inspect(path: Path, stage: str) -> dict:
    im = Image.open(path)
    im.load()
    width, height = im.size
    rgba = im.convert('RGBA')
    alpha = rgba.getchannel('A')
    extrema = alpha.getextrema()
    transparent_fraction = 1.0 - sum(alpha.histogram()[1:]) / (width * height)
    has_actual_transparency = extrema[0] < 255
    bounds = alpha.point(lambda v: 255 if v >= 16 else 0).getbbox()
    # These are mechanical checks only. Crops, visible side-view, hand assignments,
    # style, and animation consistency require a visual/artistic review.
    checks = {
        'png_format': im.format == 'PNG',
        'nonempty_canvas': width > 0 and height > 0,
    }
    if stage == 'runtime':
        checks.update({
            'alpha_channel': 'A' in im.getbands(),
            'transparent_background': has_actual_transparency and transparent_fraction >= 0.01,
            'actor_pixels_present': bounds is not None,
        })
        if bounds is not None:
            l, t, r, b = bounds
            checks['safe_margins'] = (l > 1 and t > 1 and r < width - 1 and b < height - 1)
    return {
        'path': str(path), 'stage': stage, 'size': [width, height], 'mode': im.mode,
        'alpha_extrema': list(extrema), 'transparent_pixel_fraction': round(transparent_fraction, 5),
        'visible_bounds': list(bounds) if bounds else None,
        'checks': checks,
        'mechanical_pass': all(checks.values()),
        'manual_review_required': ['exactly one isolated full-body character',
                                   'non-pixel anime 2D style', 'strict side profile',
                                   'anatomical right-hand spear and left-hand shield',
                                   'same identity and clothing', 'flat practical boots',
                                   'no labels, panels or composition sheets'],
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('png', type=Path)
    parser.add_argument('--stage', choices=['concept', 'runtime'], default='runtime')
    args = parser.parse_args()
    try:
        report = inspect(args.png, args.stage)
    except (OSError, ValueError) as exc:
        print(json.dumps({'error': str(exc)}, ensure_ascii=False))
        return 2
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return 0 if report['mechanical_pass'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
