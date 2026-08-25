#!/usr/bin/env python3
"""Process the black-on-white ink-drawing marks (one-color already).

Pipeline per mark: drop the full-canvas white background path, keep every
ink path verbatim (micro-dots included — in engraved/stippled drawings the
dots ARE texture, and a same-color dot can't misrender the way the purple
render's off-color smoke specks could), crop the viewBox to the ink, and
emit three editions: transparent master, on-white, and dark (white on black).
"""
import re, pathlib

OUT = pathlib.Path(__file__).parent
INK, WHITE, BLACK = "#111111", "#FFFFFF", "#000000"

SPECS = {
    "nouveau-book": "g4.svg",
    "medallion":    "g5.svg",
    "bookplate":    "g6.svg",
    "echo-v":       "g7.svg",
    "deco-v":       "g8.svg",
    "engraving":    "g9.svg",
    "fountain-book": "g10.svg",
}

for name, src in SPECS.items():
    body = (OUT / src).read_text()
    tags = re.findall(r'<path\b[^>]*>', body)
    ds = []
    for i, tag in enumerate(tags):
        if i == 0:                       # full-canvas white background
            continue
        ds.append(re.search(r'd="([^"]*)"', tag).group(1))

    nums = [float(n) for n in re.findall(r'-?\d+\.?\d*', " ".join(ds))]
    xs, ys = nums[0::2], nums[1::2]
    x0, y0, x1, y1 = min(xs), min(ys), max(xs), max(ys)
    m = 0.06 * max(x1 - x0, y1 - y0)
    vb = f"{x0 - m:.1f} {y0 - m:.1f} {(x1 - x0) + 2*m:.1f} {(y1 - y0) + 2*m:.1f}"
    rect = (f'<rect x="{x0 - m:.1f}" y="{y0 - m:.1f}" width="{(x1 - x0) + 2*m:.1f}" '
            f'height="{(y1 - y0) + 2*m:.1f}" fill="%s"/>')

    def doc(bg_rect, fg):
        paths = "".join(f'<path fill="{fg}" d="{d}"/>' for d in ds)
        return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="{vb}">{bg_rect}{paths}</svg>'

    (OUT / f"variorum-{name}-master.svg").write_text(doc("", INK))
    (OUT / f"variorum-{name}-white.svg").write_text(doc(rect % WHITE, INK))
    (OUT / f"variorum-{name}-dark.svg").write_text(doc(rect % BLACK, WHITE))
    print(f"{name}: {len(ds)} ink paths, viewBox {vb}")
