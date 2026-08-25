# The mark-processing pipeline

How a raw Recraft generation becomes the production files in this folder.
Written so a future session can repeat it exactly when the author drops in
more options ("process this like the others" + a file path is enough — this
note is the spec).

## Step 0 — what arrives

Recraft outputs **true SVG** (real paths, no embedded raster). Each file
carries a large C2PA provenance `<metadata>` blob — strip it first. The
stripped originals are archived in `sources/`, one per mark, renamed to the
mark's name.

## Step 1 — inventory, then classify

List every `<path>` (fill, data length, bbox) and render the file
(`qlmanage -t -s 700 -o . file.svg`). Every mark so far falls into one of
four classes, and the class decides the treatment:

| class | signature | treatment |
|---|---|---|
| **A — flat, one-color-able** | one ink body + "carve" shapes painted in the background color, fully inside the body | merge body + carves into ONE compound path with `fill-rule="evenodd"` → carves become real holes → a true one-color transparent `-master` works on any ground (striped V, both flourishes, filigree V) |
| **B — layered two-tone** | stacked black shapes with white (and sometimes accent-color) paint BETWEEN layers — not nested, so evenodd would misrender | keep layers, assign each path a ROLE (ink / paper / face / dot), generate editions by role→color maps; no transparent master by design (cards, book). Watch for detail that vanishes when a paint layer maps to the ground color — the cards' dot flips to ink in the on-white edition for exactly this reason |
| **C — vectorized render** | hundreds/thousands of small shaded paths + gradient fills (the chrome look) | isolate the subject GEOMETRICALLY: keep paths whose points fall mostly inside the region the mark occupies (a padded triangle for a V); then a second pass drops in-region smoke/specks identified by the background's own fill family. Polychrome by nature — editions only, plus optional sub-variants by color classification (the purple `-lines` variant keeps only pink/purple-family fills, gradients classified by average stop color) |
| **D — ink drawing** | black paths on a white canvas rect, no gradients | drop the background rect, keep EVERYTHING else verbatim, recolor whole-cloth per edition. Do NOT delete micro-dot paths here: in stippled/engraved drawings the dots are texture, and a same-color dot can't misrender (unlike class C's off-color smoke specks, which must go) |

## Step 2 — universal cleanup rules

- Drop the full-canvas background path (always path 0 so far).
- Delete AI artifact specks **only when off-color** (gray slivers on a colored
  render); never in class D.
- Crop the viewBox to the content bbox + 6–10% margin.
- Normalize colors to the constants below; `#FEFEFE` whites become `#FFFFFF`.
- Verify **visually** after every structural change (render, compare against
  the original) — bbox reasoning misleads; the purple V's wisps were found by
  looking, not by math.

## Step 3 — editions and naming

Per mark (see README for the full scheme): `-master` (transparent, one-color
classes only) · `-faithful` (as generated, cleaned, own ground) · `-white` /
`-on-white` · `-dark` (white-on-black; class B inverts all roles). Class C
gets grounds instead (`-on-gradient`, `-on-black`) and named sub-variants.

Then add the mark to `tools/sheet.py`'s MANIFEST (label, light file, dark
file, light cell ground) and re-run it → `variorum-family-sheet.svg`, the
choosing surface. Re-render the `.png` twin
(`qlmanage -t -s 1400 -o . variorum-family-sheet.svg`).

## Constants

- **Red `#FC120C`** — the actual Recraft red, standardized across all red
  editions (rubrication precedent: red is the scholar's annotation ink).
- **Ink `#111111`** · creams as generated (`#F3EBD6`, `#F8F6E5`).

## Tools

`tools/` holds the scripts exactly as they ran (a session scratch directory,
staged working names): `family.py` (classes A+B editions), `purple.py`
(class C isolation + the `-lines` variant), `inkmarks.py` (class D),
`sheet.py` (the sheet). Staged-name → mark mapping: `f1-image`=cards ·
`f2-minimalist`=book · `f3-abstract`=flourish · `f4-abstract1`=flourish-thin ·
`f5-abstract2`=filigree-v · `f6-abstract3`=purple-v · `g4`=nouveau-book ·
`g5`=medallion · `g6`=bookplate · `g7`=echo-v · `g8`=deco-v · `g9`=engraving ·
(the striped V's source predates the staging scheme). A future session can
re-stage from `sources/` and adapt paths, or simply follow this note by hand.

## Status

All marks are OPTIONS — nothing is "the logo" until the author says so.
Her recorded notes-to-self: she leans to the red family ("distinct and sharp");
and since every candidate is a V, she has floated **user-selectable app icons**
as a possible future delight feature (13q's natural neighborhood — a slotting
decision that is hers, recorded here so it isn't lost).
