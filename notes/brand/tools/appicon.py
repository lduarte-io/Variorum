#!/usr/bin/env python3
"""The app's icon and in-app mark, composed from THE LOGO family's cards fan.

VX-177 (her word, 2026-10-12): the app's face is the CARDS mark —
`variorum-cards-faithful.svg`, the fan of cards on the red ground #FC120C —
superseding R-13s-24/25's striped V as the art while keeping every ruled
placement (the app icon, About, the offer line's small mark — Q19's set).
Nothing is redrawn: the fan's geometry is copied verbatim from the brand
files and only placed (translate + one uniform scale, identical for every
edition). Re-run from the repo root after any change to the source editions:

    python3 notes/brand/tools/appicon.py

It writes two things:

1. `App/Variorum/Variorum/AppIcon.icon/` — the macOS 26 app icon as an Icon
   Composer document (Apple's route since Xcode 26: the SYSTEM applies the
   squircle mask, so the layer is full-canvas art with no mask, shadow or
   margin baked in, and the ground is the document's fill). The faithful
   edition is a flat print, so the document asks for no Liquid Glass depth
   (no group shadow, no specular, no translucency, the layer's glass off).
   macOS 26 draws icons in four appearances; the system's own dark and
   tinted derivations keep a layer's colours, and the faithful fan's BLACK
   cards would vanish into a dark ground. So the dark and tinted appearances
   wear the brand's own dark-ground pairing — the cards mark's dark edition
   (`variorum-cards-dark.svg`, the family sheet's own dark cell for this
   mark) on black — and the default appearance wears the faithful edition
   on red.
2. `App/Variorum/Variorum/Assets.xcassets/VariorumMark.imageset/` — the small
   flat mark the offer line and the About window draw (a vector SVG asset):
   the faithful fan on the red ground, on a continuous-corner rounded square
   in the icon's own proportions, so the in-app mark and the Dock icon read
   as one.
"""
import json
import math
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parents[3]
FAITHFUL = ROOT / "notes/brand/variorum-cards-faithful.svg"
DARK = ROOT / "notes/brand/variorum-cards-dark.svg"
ICON_DIR = ROOT / "App/Variorum/Variorum/AppIcon.icon"
MARK_DIR = ROOT / "App/Variorum/Variorum/Assets.xcassets/VariorumMark.imageset"

RED = "#FC120C"      # the brand red (README "Constants")
BLACK = "#000000"    # the dark edition's ground (and R51's dark room)
CANVAS = 1024
# The fan's width as a share of the canvas: bold, with the mask's corners
# well clear of the cards (TASTE.md through-line 3, "bold structure").
MARK_WIDTH_SHARE = 0.62
# The fan's mass reads centred (the front card's weight balances the spread),
# so no optical nudge is needed; kept as a dial for the eye.
OPTICAL_DROP_SHARE = 0.0


def edition_paths(source):
    """One edition's paths, in document order, fills verbatim (the ground
    rect is the document fill's job, so only <path> elements ride)."""
    body = source.read_text()
    paths = re.findall(r'<path fill="(#[0-9A-Fa-f]{6})" d="([^"]+)"/>', body)
    assert paths, f"no paths in {source.name}"
    return [(fill.upper(), d, None) for fill, d in paths]


def faithful_paths():
    paths = edition_paths(FAITHFUL)
    assert paths[0][0] == "#111111", "the ink card leads"
    return paths


def dark_paths():
    return edition_paths(DARK)


def bbox(d_list):
    xs, ys = [], []
    for d in d_list:
        nums = [float(n) for n in re.findall(r"-?\d+(?:\.\d+)?", d)]
        xs += nums[0::2]
        ys += nums[1::2]
    return min(xs), min(ys), max(xs), max(ys)


def placement(size):
    """ONE placement for every edition, measured on the faithful fan (both
    editions share the same viewBox and geometry), so the default and dark
    icons put the fan in exactly the same place."""
    x0, y0, x1, y1 = bbox([d for _, d, _ in faithful_paths()])
    w, h = x1 - x0, y1 - y0
    scale = size * MARK_WIDTH_SHARE / w
    tx = (size - w * scale) / 2 - x0 * scale
    ty = (size - h * scale) / 2 + h * scale * OPTICAL_DROP_SHARE - y0 * scale
    return f"translate({tx:.3f},{ty:.3f}) scale({scale:.6f})"


def placed_group(paths, size):
    inner = "".join(
        f'<path fill="{fill}"{f" fill-rule=\"{rule}\"" if rule else ""} d="{d}"/>'
        for fill, d, rule in paths)
    return f'<g transform="{placement(size)}">{inner}</g>'


def layer_svg(paths):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{CANVAS}" height="{CANVAS}" '
            f'viewBox="0 0 {CANVAS} {CANVAS}">{placed_group(paths, CANVAS)}</svg>\n')


def srgb(hex_color):
    r, g, b = (int(hex_color[i:i + 2], 16) / 255 for i in (1, 3, 5))
    return f"srgb:{r:.5f},{g:.5f},{b:.5f},1.00000"


def continuous_square(size, radius_share=0.225, n=96):
    """A rounded square with continuous (superelliptic) corners — Apple's
    icon silhouette, close enough for a 16-point mark. A plain arc corner
    reads as a different, older shape."""
    r = size * radius_share
    pts = []
    corners = [(size - r, r, 0), (size - r, size - r, 90), (r, size - r, 180), (r, r, 270)]
    for cx, cy, start in corners:
        for i in range(n + 1):
            t = math.radians(start - 90 + 90 * i / n)
            c, s = math.cos(t), math.sin(t)
            # superellipse exponent 5: the continuous-corner family
            x = cx + r * math.copysign(abs(c) ** (2 / 5), c)
            y = cy + r * math.copysign(abs(s) ** (2 / 5), s)
            pts.append(f"{x:.2f},{y:.2f}")
    return "M" + " L".join(pts) + " Z"


def write_icon():
    assets = ICON_DIR / "Assets"
    assets.mkdir(parents=True, exist_ok=True)
    for stale in assets.iterdir():
        stale.unlink()
    (assets / "cards.svg").write_text(layer_svg(faithful_paths()))
    (assets / "cards-dark.svg").write_text(layer_svg(dark_paths()))
    manifest = {
        "fill-specializations": [
            {"value": {"solid": srgb(RED)}},
            {"appearance": "dark", "value": {"solid": srgb(BLACK)}},
        ],
        "groups": [{
            "layers": [{
                "name": "cards",
                "glass": False,
                "image-name-specializations": [
                    {"value": "cards.svg"},
                    {"appearance": "dark", "value": "cards-dark.svg"},
                    {"appearance": "tinted", "value": "cards-dark.svg"},
                ],
            }],
            "shadow": {"kind": "none", "opacity": 0.5},
            "specular": False,
            "translucency": {"enabled": False, "value": 0.5},
        }],
        "supported-platforms": {"squares": "shared"},
    }
    (ICON_DIR / "icon.json").write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n")


def write_mark():
    MARK_DIR.mkdir(parents=True, exist_ok=True)
    clip = continuous_square(CANVAS)
    mark = (f'<svg xmlns="http://www.w3.org/2000/svg" width="{CANVAS}" height="{CANVAS}" '
            f'viewBox="0 0 {CANVAS} {CANVAS}">'
            f'<defs><clipPath id="tile"><path d="{clip}"/></clipPath></defs>'
            f'<g clip-path="url(#tile)"><rect width="{CANVAS}" height="{CANVAS}" fill="{RED}"/>'
            f'{placed_group(faithful_paths(), CANVAS)}</g></svg>\n')
    (MARK_DIR / "VariorumMark.svg").write_text(mark)
    contents = {
        "images": [{"filename": "VariorumMark.svg", "idiom": "universal"}],
        "info": {"author": "xcode", "version": 1},
        "properties": {"preserves-vector-representation": True},
    }
    (MARK_DIR / "Contents.json").write_text(json.dumps(contents, indent=2) + "\n")


if __name__ == "__main__":
    write_icon()
    write_mark()
    print("wrote", ICON_DIR.relative_to(ROOT), "and", MARK_DIR.relative_to(ROOT))
