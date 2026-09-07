# The 18f letter's canon deltas — applied by the orchestrator AFTER the 18f ladder closes.
def edit(path, old, new, count=1):
    s=open(path).read()
    assert s.count(old)==count, (path, old[:60], s.count(old))
    open(path,'w').write(s.replace(old,new))

# 1. AppSpec §9 — divideW's W bullet: the UI face's names and the arrangement row (U-3 · U-4 · U-5).
edit('notes/AppSpec.md',
 "QUESTIONS #91 carries the second as PROVISIONAL.)*",
 "QUESTIONS #91 carries the second as PROVISIONAL.)* *(18f, 2026-09-07/08 — THE FACE: the ceremony's UI name is **\"Divide choosing takes…\"** (U-4, her word: \"clearer\"; the model's term \"the W ceremony\" and the code's type names stay); its sheet opens on an ARRANGEMENT ROW of four — **Keep takes on the top block** (selected on open — the instant default, byte-identical on confirm), **Keep takes on the bottom block**, **Copy takes to both** (`divideDuplicating`), **Choose per take…** (the hand-placement vocabulary: every take CHECKED, the non-seed ✂ parked at the END — U-3/U-5); real prose side by side (up to three columns), the ✂ an overlay on the inter-word gap, placement by character hit-testing through the one snapping brain; rebuilt to her approved mockup, figure A. Doors: beside Divide in the block ▾ menu and the bulk bars; ⌥⌘⇧D. The bulk bars' merge door offers the two run options at every pick size — QUESTIONS #95, PROVISIONAL.)*")

# 2. AppSpec §9 — mergeCeremony's paragraph: the UI name, the row, the N-way's two choices (U-4 · U-16).
edit('notes/AppSpec.md',
 "*Why this is canon and not UI: it changes what \"merge\" MEANS — divide-then-merge now round-trips whole when you pair 1+1 and 2+2, which the one-take rule could never do.*",
 "*Why this is canon and not UI: it changes what \"merge\" MEANS — divide-then-merge now round-trips whole when you pair 1+1 and 2+2, which the one-take rule could never do.* *(18f, 2026-09-07/08: the UI name is **\"Merge choosing takes…\"** — a BUTTON beside Merge in the block ▾ menu and the bulk bars, not only ⌥⌘⇧M (U-4); its sheet opens on the arrangement row **Bring every take** (selected — the carry-all default) · **Only the two shown** · **Pair by hand…** (the S4-23 pairing surface, restyled to figure B). **Over a run of THREE OR MORE blocks the door offers exactly TWO choices — Bring every take · Only the shown ones — and never the pairing surface** (U-16, her amendment at the mockup approval: \"i don't want a super complex ceremony for merging multiple blocks together\"); the former pairwise refusal retired.)*")

# 3. AppSpec §12 — the takes presentations line names the rebuilt sheets.
edit('notes/AppSpec.md',
 "the changing-block wash behind a default-on toggle (R13), the short-block one-card-high horizontal strip (R24),",
 "the changing-block wash behind a default-on toggle (R13), the short-block one-card-high horizontal strip (R24), *(the two ceremony sheets — **Divide choosing takes** · **Merge choosing takes** — rebuilt at 18f, 2026-09-07/08, to her approved mockups: one row of presets first, real prose side by side, the ✂ overlaid, explainers folded — the record `notes/plans/use-report-round-2026-09-06.md` §5.2 + R-4/R-5)*,")
print("18f deltas applied")
