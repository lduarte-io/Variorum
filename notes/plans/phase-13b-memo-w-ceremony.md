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

---

# Addendum: the cut, redesigned (authored 2026-07-21 by the 13b architect; BUILT AT STAGE 4 — the author discusses goals and tradeoffs at that stage's kickoff, so nothing here is final until that conversation)

*Why this exists: the author's 2026-07-21 rulings — cuts should not be
limited to sentence ends, the scissors should be draggable, and a cut at
a take's very end should mean "this take doesn't split." Her words are
quoted in the plan file's ledger (N16, N18) and Author-additions
section.*

## Where cuts can go (the new rule)

A cut can go **between any two words** — and at newlines, which is what
outline-style writing needs ("I rarely use periods within my outline").
The scissors snap to the nearest word edge, so half a word can never end
up in each block. Sentence ends and newlines are still the easiest spots
to land on (the scissors settle onto them a little more readily), but
they're no longer the only spots.

One rule everywhere: plain divide (one take, no ceremony) follows the
same rule. Two behaviors for one gesture would be the confusion class
this phase exists to kill.

## The ends mean something now

- **Scissors at a take's very END:** that take doesn't split — all of it
  rides into the first block, and it simply has no say in the second.
  (Her example: a two-paragraph take splits; the one-paragraph take puts
  its scissors at the end and contributes only a first half.)
- **Scissors at a take's very START:** the mirror — all of it rides into
  the second block.
- A happy consequence: the old "this take is a single sentence, so it
  can't be placed" dead end disappears. Every take always has a legal
  placement now — split it somewhere, or park the scissors at either
  end.
- In plain no-ceremony divide, a cut at the block's start or end still
  refuses ("nothing to divide") — there's no second take to give the
  whole text to.

## How placing feels

- **Every checked take is visible at once**, each with its own ✂ sitting
  in its text. No clicking into takes one at a time.
- **Drag the ✂** and it glides between word edges. Click a spot to jump
  it there (the current gesture survives).
- **Keyboard:** ←/→ nudge the active take's scissors a word at a time;
  ⌥←/→ jump by sentence; ⇥ moves between takes; ⏎ confirms when every
  checked take is placed.
- The app still proposes each cut where it can match your original spot
  in that take's wording — you adjust from a good guess, not from zero.

## What this dissolves

- The N18 stumble (a selection late in the last sentence refusing to
  extract) — word-edge snapping makes those spans legal.
- The single-sentence-take dead end (above).

## Tradeoffs to settle at the Stage 4 kickoff

1. How strong should the sentence/newline "magnetism" be — a gentle
   settle, or none at all (pure word edges)?
2. Is the start-of-take mirror rule wanted, or is end-only enough?
3. Word-edge snapping is the recommended floor (mid-word cuts serve
   nobody). Agree?
4. Does the relaxed rule extend to EXTRACT's boundary checks too?
   (Recommended: yes — same one-rule-everywhere logic; extract's
   "boundary-adjacent" requirement itself is untouched.)

*Store semantics are untouched by all of this: divide and the W still
write exactly the same rows — only where the cut offsets may fall, and
how you place them, changes. The boundary rules live in one Domain
function (`BoundarySnapping`), which is where the change goes — with its
own tests, its own commit, and no schema work.*

## RULINGS (2026-07-22, the Stage 4 kickoff sitting — the author settled all four tradeoffs; this addendum is now BUILD-READY as ruled)

1. **Magnetism: GENTLE SETTLE.** Word edges are free; sentence ends and
   newlines pull a little — the common landings stay easy, nothing
   forced.
2. **Start-of-take mirror: YES, both ends.** End = the whole take rides
   into the first block; start = the whole take rides into the second.
   Every take always has a legal placement — the single-sentence dead
   end is gone in both directions.
3. **Word-edge floor: YES.** A cut never lands mid-word; a one-word
   half remains legal (her block-is-at-minimum-one-character case is
   satisfied by the floor, not defeated by it).
4. **EXTRACT joins the relaxed rule: YES.** One rule everywhere —
   extract's span edges snap to word edges/newlines exactly like
   divide's cuts (the N18 late-start refusal class dissolves); the
   prefix/suffix boundary-adjacency requirement itself is untouched.
