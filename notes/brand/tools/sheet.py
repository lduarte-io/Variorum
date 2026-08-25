#!/usr/bin/env python3
"""The family choosing sheet: every mark as a (light ground / dark ground)
pair, wrapped 5 pairs per row. Add new marks to MANIFEST and re-run."""
import re, pathlib

OUT = pathlib.Path(__file__).parent
MANIFEST = [  # (label, light-ground file, dark-ground file, light cell bg)
    ("the striped V",     "variorum-v-faithful-red.svg",         "variorum-v-white-on-black.svg",     "#FC120C"),
    ("the cards",         "variorum-cards-faithful.svg",         "variorum-cards-dark.svg",           "#FC120C"),
    ("the book",          "variorum-book-faithful.svg",          "variorum-book-dark.svg",            "#FC120C"),
    ("the flourish",      "variorum-flourish-faithful.svg",      "variorum-flourish-dark.svg",        "#FFFFFF"),
    ("the thin flourish", "variorum-flourish-thin-faithful.svg", "variorum-flourish-thin-dark.svg",   "#F3EBD6"),
    ("the filigree V",    "variorum-filigree-v-faithful.svg",    "variorum-filigree-v-dark.svg",      "#F8F6E5"),
    ("the purple V",      "variorum-purple-v-on-gradient.svg",   "variorum-purple-v-on-black.svg",    "#33363E"),
    ("purple V, lines",   "variorum-purple-v-on-black.svg",      "variorum-purple-v-lines-on-black.svg", "#000000"),
    ("the nouveau book",  "variorum-nouveau-book-white.svg",     "variorum-nouveau-book-dark.svg",    "#FFFFFF"),
    ("the medallion",     "variorum-medallion-white.svg",        "variorum-medallion-dark.svg",       "#FFFFFF"),
    ("the bookplate",     "variorum-bookplate-white.svg",        "variorum-bookplate-dark.svg",       "#FFFFFF"),
    ("the echo V",        "variorum-echo-v-white.svg",           "variorum-echo-v-dark.svg",          "#FFFFFF"),
    ("the deco V",        "variorum-deco-v-white.svg",           "variorum-deco-v-dark.svg",          "#FFFFFF"),
    ("the engraving",     "variorum-engraving-white.svg",        "variorum-engraving-dark.svg",       "#FFFFFF"),
]

S, P, LH, COLS = 170, 14, 18, 5


def cell(fn, x, y, bg):
    body = (OUT / fn).read_text()
    vb = tuple(float(n) for n in re.search(r'viewBox="([^"]*)"', body).group(1).split())
    inner = re.sub(r'^<svg[^>]*>|</svg>$', "", body)
    sc = S / max(vb[2], vb[3])
    ox = x + (S - vb[2] * sc) / 2 - vb[0] * sc
    oy = y + (S - vb[3] * sc) / 2 - vb[1] * sc
    return (f'<rect x="{x}" y="{y}" width="{S}" height="{S}" fill="{bg}"/>'
            f'<g transform="translate({ox:.1f},{oy:.1f}) scale({sc:.4f})">{inner}</g>')


rows = (len(MANIFEST) + COLS - 1) // COLS
W = COLS * S + (COLS + 1) * P
H = rows * (2 * S + LH + P) + P
parts = [f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}">',
         f'<rect width="{W}" height="{H}" fill="#F4F2ED"/>']
for i, (label, light, dark, bg) in enumerate(MANIFEST):
    x = P + (i % COLS) * (S + P)
    y = P + (i // COLS) * (2 * S + LH + P)
    parts.append(cell(light, x, y, bg))
    parts.append(cell(dark, x, y + S, "#000000"))
    parts.append(f'<text x="{x + S/2}" y="{y + 2*S + 13}" text-anchor="middle" '
                 f'font-family="Menlo, monospace" font-size="9" fill="#666">{label}</text>')
(OUT / "variorum-family-sheet.svg").write_text("".join(parts) + "</svg>")
print(f"sheet: {len(MANIFEST)} marks, {rows} rows")
