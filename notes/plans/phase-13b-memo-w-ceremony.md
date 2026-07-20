# The take ceremony (dividing a block that has several takes)

*Phase 13b design memo (T4/M2). Written 2026-07-20, in plain language, per
R120 — self-executing; the author reviews it at the end checkpoint. The
parts marked "built in Stage 1b" ship with this stage; anything marked
"Stage 3" is decided here and built there.*

## What it is

Dividing a block means cutting it into two blocks at a spot you pick —
the everyday gesture for "this part should stand on its own so I can work
on it separately."

When the block has just one take, dividing is instant: put the cursor
where the cut goes, invoke Divide, done. No ceremony.

When the block has SEVERAL takes, there's a real question the app can't
answer for you: each take is a different text, so each take needs its own
cut. Say a block has three takes — where does take 2 split? Maybe its
version of the idea turns at a different sentence. That decision is
yours, and the app asks for it exactly once, in one sheet. That sheet is
the ceremony. (Internally it's called the "W": the original block fans
into first-halves and second-halves — drawn on paper it looks like a W.)

## What the sheet does

The sheet is titled **"Divide into takes."** It lists every take of the
block as a checklist:

- The take you were looking at is already checked, and its cut is already
  placed where your cursor was (snapped to the nearest sentence break).
- For every other checked take, the app proposes a cut where it can find
  the matching spot in that take's text; where it can't match
  confidently, the take shows "place the cut" and you click the sentence
  boundary you want.
- A take you UNCHECK doesn't get divided. It stays with the original
  block — nothing is lost, it just doesn't ride into the two new blocks.
- **Confirm** performs the divide: two new blocks, the first holding
  every checked take's first half, the second holding the second halves.
  Your three openings and three endings stay mix-and-matchable.
- **Cancel** (or closing the sheet any other way) touches nothing.

The original block is preserved whole, off-stage, with any unchecked
takes still on it. Undo (⌥⌘Z) puts it right back where it was.

## The doors (where you can invoke it)

There is deliberately NO separate "open the ceremony" command. **Divide
is the one gesture**; the ceremony appears exactly when the block you're
dividing has more than one take. One gesture to learn, and the sheet
explains itself when it's needed.
*(Memo decision, contestable: an explicit "Divide into takes…" menu item
was considered and declined — a second name for the same act is exactly
the kind of surface clutter R112 complained about.)*

Where Divide lives after Stage 1b:

- **In Takes (where fans live — R118):** the bottom bar's Divide button,
  ⌘⇧D, the Block menu, and the ⌘K palette all work. The app switches to
  Write visibly (that's where the whole post is one editable page),
  carries your cursor position over, and runs the divide there — on a
  fanned block, that opens the ceremony. Before Stage 1b the Takes
  button answered with a lecture about switching to Write yourself (and
  described the gesture wrongly); that lecture is gone.
- **In Write:** as before — cursor in the block, any Divide door.
- If the cursor carried over from a take that isn't the chosen one, the
  landing spot is approximate — the ceremony's per-take cut placement is
  where you fine-tune, so nothing is silently mis-cut.

## Edge cases, in plain terms

- **Sealed post:** Divide refuses and says so ("This post is sealed…").
  The sheet never opens.
- **Locked takes:** fine. The ceremony COPIES takes into the new blocks;
  it never edits the locked text, so locks don't block it.
- **A take that's a single sentence:** there's no legal spot to cut it.
  The sheet can't confirm while that take is checked and un-placed —
  uncheck it (it stays on the original block) or cancel.
- **The block you're dividing has one-sentence CHOSEN text:** divide has
  nowhere legal to cut at all and refuses with "No legal boundary for
  that here."
- **Takes changed underneath the open sheet** (a sync from another
  device): Confirm re-checks and asks you to look again rather than
  cutting stale text.
- **Empty takes:** an empty take can be unchecked like any other; if
  checked, it needs a cut and has nowhere to put one — uncheck it.
- **Undo:** one ⌥⌘Z after Confirm restores the original block and its
  placement; the minted blocks go to lineage. Nothing is destroyed
  either way — that's the app's standing rule.

## How you discover it

- The Takes surface's Divide door now WORKS where fans live — you meet
  the ceremony by doing the natural thing, not by knowing a secret
  (built in Stage 1b).
- The Helper's dictionary (⌘/) gains a "divide / the take ceremony"
  entry (built in Stage 1b).
- The guided tutorial walks one divide-with-takes end to end (Stage 2).

## Decided here, built later (Stage 3)

- The ceremony sheet itself is untouched this stage (it works). Stage 3
  may polish its cut-placement affordance (clicking between sentences is
  functional but plain).
- A hint on the Takes board when a fanned block's divide is invoked —
  "each take gets its own cut" — belongs to the tutorial pass if the
  sheet's own title proves insufficient.
