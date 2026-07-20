# Merge (joining blocks back together)

*Phase 13b design memo (T4/M1). Written 2026-07-20, in plain language, per
R120 — self-executing; the author reviews it at the end checkpoint. The
parts marked "built in Stage 1b" ship with this stage.*

## What it is

Merge joins neighboring blocks into one block. It's divide's opposite and
just as everyday: "these two paragraphs are really one thought."

The joined text gets a single space at the join when neither side brought
its own whitespace — so dividing a sentence and merging it back restores
it exactly, while two merged paragraphs come back as one paragraph with a
space (adjust in the editor if you wanted a line break; nothing else is
invented).

## The gesture

- **Cursor at the seam** (in Write, the boundary between two blocks —
  turn on seams with ⌘⇧B to see them): Merge joins the block above with
  the block below. This is the precise, everyday form.
- **Selection across blocks:** select any stretch touching two or more
  blocks and Merge joins the whole run, left to right, as ONE undoable
  act. Empty blocks inside the selection join too — you selected across
  them, so they're part of the run.
- Merge never partially applies: either the whole chain joins, or
  nothing does and the app says why.

## What happens to takes when blocks merge

The merged block's text is what you were LOOKING at — the visible take of
each source, joined. Other takes don't get glued together in every
combination (that way lies madness); they stay with the released source
blocks in lineage, and the app says so out loud:

> "Merged the visible takes — 2 other takes stay with the released
> blocks in lineage (undo brings them back here)."

Undo (⌥⌘Z) restores the source blocks — takes, choices, and all.

## The doors (after Stage 1b)

- **In Write:** cursor at a seam or selection across blocks, then the
  bottom-bar Merge button, ⌘⇧M, Block ▸ Merge Blocks, right-click, or
  the ⌘K palette.
- **In Takes / Lenses (R118):** the same doors now ACT. Click into a
  block first; Merge switches to Write visibly, puts the cursor at that
  block's start — the seam with the block ABOVE — and merges the focused
  block into the one before it. *(Memo decision, contestable: "merge
  joins upward" — the reading-order instinct, "this paragraph belongs to
  the one above." Merging downward is one cursor-move away in Write.)*
  Before Stage 1b these doors lectured ("works on selected text in
  Write…"); the lecture is gone.
- With no block focused in Takes, Merge says "Click into a block first."

## Edge cases, in plain terms

- **First block of the post, from Takes:** there's nothing above to join.
  You land in Write and the app answers with merge's real refusal
  ("Merge needs a caret at a block seam or a selection across blocks")
  — not a silent nothing.
- **Sealed post:** refuses and says so; nothing joins.
- **Locked takes:** fine — merge COPIES the visible texts into the new
  block; the locked take itself is never edited and stays with its
  source in lineage.
- **A gap slot** (a block whose text hasn't arrived over sync yet):
  merge refuses rather than joining text it can't see.
- **Empty blocks:** an empty block selected in a chain joins the chain
  (its nothing contributes nothing). Cursor-at-seam with an empty
  neighbor joins normally.
- **Merge, then edit:** the merged block is an ordinary block — divide
  it again anytime; the seam isn't remembered, and dividing at the same
  spot re-creates it.
- **Undo after further edits:** undo insures your newer text first (a
  quiet auto-savepoint) before restoring the pre-merge blocks — nothing
  typed since is lost.

## How you discover it

- The Takes/Lenses Merge doors now act (built in Stage 1b).
- The Helper's dictionary (⌘/) gains a "merge" entry beside divide
  (built in Stage 1b).
- The tutorial merges two blocks end to end (Stage 2).

## Decided here, built later (Stage 3)

- A visible seam-hover affordance in Write ("click to put the cursor at
  this seam") — candidate for the T7 spacing/crowdedness pass.
- Whether Takes should offer an explicit "merge with block above/below"
  pair instead of the upward default — revisit only if the upward
  reading trips her in practice (R116's friction rule).
