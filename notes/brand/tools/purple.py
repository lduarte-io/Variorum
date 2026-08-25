#!/usr/bin/env python3
"""Isolate the purple chrome V from its smoky background.

The file is a vectorized render: hundreds of shaded paths. V-pieces and
smoke share a gray palette, so classification is geometric — a path is
kept when most of its coordinate points fall inside the (padded) triangle
the V occupies; the gradient background and anything living outside the
triangle is dropped.
"""
import re, pathlib

OUT = pathlib.Path(__file__).parent
body = (OUT / "f6-abstract3.svg").read_text()

defs = "".join(re.findall(r'<defs>.*?</defs>', body, re.S))
tags = re.findall(r'<path\b[^>]*>', body)

# V triangle in canvas space (top-left, top-right, tip), padded outward
A, B, C = (69.0, 130.0), (964.0, 130.0), (510.0, 940.0)
SLACK = 30.0


def signed(p, q, r):
    return (q[0] - p[0]) * (r[1] - p[1]) - (q[1] - p[1]) * (r[0] - p[0])


import math
def edge_dist(p, q, r):
    """signed distance of r from line p->q, positive on the triangle's inner side"""
    s = signed(p, q, r)
    return s / math.hypot(q[0] - p[0], q[1] - p[1])

# orient: centroid must be positive on every edge
cent = ((A[0] + B[0] + C[0]) / 3, (A[1] + B[1] + C[1]) / 3)
edges = []
for p, q in [(A, B), (B, C), (C, A)]:
    sgn = 1.0 if edge_dist(p, q, cent) > 0 else -1.0
    edges.append((p, q, sgn))


def inside(pt):
    return all(sgn * edge_dist(p, q, pt) >= -SLACK for p, q, sgn in edges)


EXTRA_DROP = {7, 8, 1100, 1109, 1110, 1115, 1135, 1138}   # smoke wisps + floating specks inside the triangle,
                                        # identified by the smoke fills (#6B6D78/#575C74 family)
kept, dropped = [], []
for i, tag in enumerate(tags):
    if i == 0 or i in EXTRA_DROP:        # full-canvas gradient background + wisps
        dropped.append(i); continue
    d = re.search(r'd="([^"]*)"', tag).group(1)
    nums = [float(n) for n in re.findall(r'-?\d+\.?\d*', d)]
    pts = list(zip(nums[0::2], nums[1::2]))
    frac = sum(inside(p) for p in pts) / len(pts)
    (kept if frac >= 0.5 else dropped).append(i)

print(f"kept {len(kept)} paths, dropped {len(dropped)}: {dropped[:40]}{'...' if len(dropped) > 40 else ''}")

xs, ys = [], []
for i in kept:
    d = re.search(r'd="([^"]*)"', tags[i]).group(1)
    nums = [float(n) for n in re.findall(r'-?\d+\.?\d*', d)]
    xs += nums[0::2]; ys += nums[1::2]
x0, y0, x1, y1 = min(xs), min(ys), max(xs), max(ys)
m = 0.08 * max(x1 - x0, y1 - y0)
vb = f"{x0 - m:.1f} {y0 - m:.1f} {(x1 - x0) + 2*m:.1f} {(y1 - y0) + 2*m:.1f}"
print("cropped viewBox:", vb)

content = defs + "".join(tags[i] for i in kept)
rect = lambda fill: (f'<rect x="{x0 - m:.1f}" y="{y0 - m:.1f}" width="{(x1 - x0) + 2*m:.1f}" '
                     f'height="{(y1 - y0) + 2*m:.1f}" fill="{fill}"/>')

def doc(bg):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="{vb}">'
            f'{bg}{content}</svg>')

(OUT / "variorum-purple-v-master.svg").write_text(doc(""))
(OUT / "variorum-purple-v-on-gradient.svg").write_text(doc(rect("url(#gradient_0)")))
(OUT / "variorum-purple-v-on-black.svg").write_text(doc(rect("#0B0B0E")))
print("wrote 3 editions")

# ---- the purple-only variant: chrome linework sans the grey marble ----
# Keep only paths whose fill is in the pink/purple family (green is the
# smallest channel by a margin); solid greys, marble veins, near-blacks and
# blue-grey shading drop. Gradients classify by the average of their stops.

def hexrgb(c):
    c = c.lstrip('#')
    return tuple(int(c[i:i+2], 16) for i in (0, 2, 4)) if len(c) == 6 else None

def is_purple_rgb(rgb):
    r, g, b = rgb
    return (r - g) >= 12 and (b - g) >= 6

grad_purple = {}
for gm in re.finditer(r'<(?:linear|radial)Gradient[^>]*id="([^"]*)"(.*?)</(?:linear|radial)Gradient>', defs, re.S):
    gid, inner = gm.group(1), gm.group(2)
    stops = [hexrgb(c) for c in re.findall(r'stop-color="([^"]*)"', inner)]
    stops = [s for s in stops if s]
    if stops:
        avg = tuple(sum(ch) / len(stops) for ch in zip(*stops))
        grad_purple[gid] = is_purple_rgb(avg)

def path_is_purple(tag):
    fill = re.search(r'fill="([^"]*)"', tag)
    if not fill:
        return False
    f = fill.group(1)
    gm = re.match(r'url\(#([^)]*)\)', f)
    if gm:
        return grad_purple.get(gm.group(1), False)
    rgb = hexrgb(f)
    return bool(rgb) and is_purple_rgb(rgb)

purple_only = [i for i in kept if path_is_purple(tags[i])]
print(f"purple-only: {len(purple_only)} of {len(kept)} kept paths")
content_p = defs + "".join(tags[i] for i in purple_only)

def doc_p(bg):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="{vb}">'
            f'{bg}{content_p}</svg>')

(OUT / "variorum-purple-v-lines-master.svg").write_text(doc_p(""))
(OUT / "variorum-purple-v-lines-on-black.svg").write_text(doc_p(rect("#000000")))
print("wrote purple-only editions")
