#!/usr/bin/env python3
"""Clean all Variorum logo finalists into masters + editions + one family sheet."""
import re, pathlib

OUT = pathlib.Path(__file__).parent
INK, WHITE, RED, CREAM, BLACK = "#111111", "#FFFFFF", "#FC120C", "#F3EBD6", "#000000"


def parse(name):
    body = (OUT / name).read_text()
    paths = []
    for m in re.finditer(r'<path\b[^>]*>', body):
        tag = m.group(0)
        fill = re.search(r'fill="([^"]*)"', tag)
        tr = re.search(r'transform="([^"]*)"', tag)
        paths.append({"fill": fill.group(1) if fill else "#000000",
                      "d": re.search(r'd="([^"]*)"', tag).group(1),
                      "tr": tr.group(1) if tr else None})
    return paths


def bbox(paths, idxs):
    xs, ys = [], []
    for i in idxs:
        p = paths[i]
        scale = 0.5 if p["tr"] and "0.5" in p["tr"] else 1.0
        nums = [float(n) for n in re.findall(r'-?\d+\.?\d*', p["d"])]
        xs += [n * scale for n in nums[0::2]]
        ys += [n * scale for n in nums[1::2]]
    return min(xs), min(ys), max(xs), max(ys)


def viewbox(paths, idxs, margin=0.10):
    x0, y0, x1, y1 = bbox(paths, idxs)
    m = margin * max(x1 - x0, y1 - y0)
    return (x0 - m, y0 - m, (x1 - x0) + 2 * m, (y1 - y0) + 2 * m)


def emit(vb, bg, layers):
    """layers: list of (fill, d, tr, fill_rule)"""
    x, y, w, h = vb
    parts = [f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="{x:.1f} {y:.1f} {w:.1f} {h:.1f}">']
    if bg:
        parts.append(f'<rect x="{x:.1f}" y="{y:.1f}" width="{w:.1f}" height="{h:.1f}" fill="{bg}"/>')
    for fill, d, tr, fr in layers:
        t = f' transform="{tr}"' if tr else ""
        r = f' fill-rule="{fr}"' if fr else ""
        parts.append(f'<path fill="{fill}"{r}{t} d="{d}"/>')
    parts.append("</svg>")
    return "".join(parts)


# ---- per-file role maps (indices from inspection) ---------------------
SPECS = {
    "cards":         dict(src="f1-image.svg",     roles={1: "ink", 2: "paper", 3: "ink", 4: "ink",
                                                         5: "face", 6: "paper", 7: "dot"},
                          bg=RED, layered=True),
    "book":          dict(src="f2-minimalist.svg", roles={1: "ink", 2: "paper", 3: "paper", 4: "paper",
                                                          5: "paper", 7: "ink"},     # 6 = artifact speck, dropped
                          bg=RED, layered=True),
    "flourish":      dict(src="f3-abstract.svg",  roles={1: "ink", 2: "carve"}, bg=WHITE, layered=False),
    "flourish-thin": dict(src="f4-abstract1.svg", roles={1: "ink", 2: "carve", 3: "carve", 4: "carve", 5: "carve"},
                          bg=CREAM, layered=False),
    "filigree-v":    dict(src="f5-abstract2.svg", roles={1: "ink", **{i: "carve" for i in range(2, 24)}},
                          bg="#F8F6E5", layered=False),   # 24 = artifact speck, dropped
}

EDITIONS = {   # role -> fill, per edition; bg per edition
    "faithful": dict(bg=None,  ink=INK,   paper=WHITE, face=None,  dot=WHITE, carve=None),  # None = spec default
    "white":    dict(bg=WHITE, ink=INK,   paper=WHITE, face=WHITE, dot=INK,   carve=WHITE),
    "dark":     dict(bg=BLACK, ink=WHITE, paper=BLACK, face=BLACK, dot=WHITE, carve=BLACK),
}

made = {}
for name, spec in SPECS.items():
    paths = parse(spec["src"])
    idxs = sorted(spec["roles"])
    vb = viewbox(paths, idxs)

    for ed, colors in EDITIONS.items():
        bg = colors["bg"] or spec["bg"]
        layers = []
        for i in idxs:
            role = spec["roles"][i]
            fill = colors[role]
            if fill is None:                       # faithful defaults
                fill = {"face": RED, "carve": spec["bg"]}[role]
            layers.append((fill, paths[i]["d"], paths[i]["tr"], None))
        fn = f"variorum-{name}-{ed}.svg"
        (OUT / fn).write_text(emit(vb, bg, layers))
        made[(name, ed)] = fn

    # true one-color compound master for the non-layered marks
    if not spec["layered"]:
        ink_i = [i for i in idxs if spec["roles"][i] == "ink"]
        carve_i = [i for i in idxs if spec["roles"][i] == "carve"]
        d = " ".join(paths[i]["d"] for i in ink_i + carve_i)
        tr = paths[ink_i[0]]["tr"]
        (OUT / f"variorum-{name}-master.svg").write_text(emit(vb, None, [(INK, d, tr, "evenodd")]))
        made[(name, "master")] = f"variorum-{name}-master.svg"

# ---- re-emit the striped V colorways on the true generated red --------
vsrc = (OUT / "variorum-v-master.svg").read_text()
vvb = tuple(float(n) for n in re.search(r'viewBox="([^"]*)"', vsrc).group(1).split())
vd = re.search(r'd="([^"]*)"', vsrc).group(1)
(OUT / "variorum-v-on-red.svg").write_text(emit(vvb, RED, [(INK, vd, None, "evenodd")]))
fsrc = (OUT / "variorum-v-faithful-red.svg").read_text()
fsrc = fsrc.replace("#DE3A2B", RED)
(OUT / "variorum-v-faithful-red.svg").write_text(fsrc)

print("editions written; the sheet is sheet.py's job")
