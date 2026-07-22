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

---

# Addendum: the merge ceremony (authored 2026-07-21 by the 13b architect; BUILT AT STAGE 4 — the author discusses goals and tradeoffs at that stage's kickoff; merge's stored meaning is canonical, so the semantic changes here are HER ruling to make, not the architect's)

*Why this exists: the author divided a two-take block and merged it
back, and take 2 seemed to vanish (it was safe in lineage, but nothing
pointed there). Her direction, quoted in the plan file: "there should be
something like the W ceremony but for keeping the takes of your two
blocks. Maybe instead of having scissors, there is a + that you move
around?" Plus: the join should handle text with no sentence
punctuation.*

## When it appears

- Both blocks have one take: **merge stays instant.** No ceremony, no
  sheet — the everyday case is untouched.
- Either block has several takes: **the merge ceremony opens** — the
  W's mirror. Today's behavior (join the two visible takes, everything
  else to lineage, spoken in a toast) becomes the sheet's DEFAULT
  proposal instead of a silent rule.

## What the sheet shows

The two blocks' takes, side by side — left block's takes on the left,
right block's on the right — with **＋ marks you place between them**:

- **A ＋ between two takes PAIRS them:** the merged block gets a take
  that is left-half + right-half joined. Pair take 1 with take 1 and
  take 2 with take 2, and your divided block comes back whole — the
  round trip she expected just works.
- **An unpaired take can ride whole:** check "carry" and it lands on
  the merged block as its own take, unjoined (for "this alternate
  stands on its own" cases).
- **Or stay behind:** an unchecked take stays with its released source
  block in lineage — today's rule, now visible and chosen instead of
  silent.
- The default proposal pre-pairs the two CHOSEN takes (exactly what
  merge does today), so confirming immediately = current behavior.
- Takes are never multiplied combinatorially — you place pairings by
  hand; nothing is cartesian-producted. (That standing rule survives;
  pairing is choosing, not multiplying.)

## The join, previewed

The sheet PREVIEWS each paired take's joined text, with a three-way
join control: **space · new line · nothing.** The default follows
today's rule (a single space, unless either side already brings its own
whitespace). Outline-ish text with no periods is exactly why the
preview + newline option exist — you see the join before you commit it,
so no cleverness has to guess your intent. Instant merges (the
no-ceremony case) keep the canon rule unchanged.

## The road behind you, named

Whatever stays in lineage, the confirmation speech names the actual
road: takes stay findable under **Library → Archived & Deleted →
Unplaced blocks** (and ⌥⌘Z undoes the whole merge). The toast-copy
half of this is cheap and canon-preserving, so it lands in Stage 3's
geometry batch rather than waiting for the ceremony.

## Tradeoffs to settle at the Stage 4 kickoff

1. **The semantics extension is the real decision:** today a merge
   mints ONE take; with pairing it can mint several (and carry some).
   Lineage edges and undo cover it identically either way — but this
   changes what "merge" means in the canon, which is yours to ratify.
2. Should "carry" exist at all, or is pair-or-leave cleaner?
3. Join memory: should the sheet remember your last join choice
   (per-session), or always reset to the default?
4. Does the ceremony threshold feel right (any fan on either side), or
   should a fanned-but-chosen-only merge stay instant with the toast?
5. The N-ary chain (selection across 3+ blocks with fans): recommended
   to stay OUT of the ceremony (chain-merge the visible takes as
   today) — a 3-way pairing surface is complexity nobody asked for.
   Agree?

## RULINGS (2026-07-22, the Stage 4 kickoff sitting — the author settled all five tradeoffs; this addendum is now BUILD-READY as ruled)

1. **THE SEMANTICS EXTENSION IS ADOPTED — her canon ruling.** A merge
   ceremony can mint SEVERAL takes on the merged block: each ＋ pairing
   mints a joined take, carries ride whole. Divide-then-merge
   round-trips whole when you pair 1+1 and 2+2. Nothing is
   cartesian-producted — pairing is choosing by hand. The instant
   no-fan merge keeps minting exactly one take, unchanged. **Canon
   recording duty:** AppSpec §9's merge entry and OverallModel §7 gain
   this delta when the build lands (the Stage 4 closeout).
2. **Carry EXISTS.** An unpaired take may ride whole onto the merged
   block as its own take, unjoined.
3. **Join memory: PER-SESSION.** The sheet remembers the last join
   choice within a session; a fresh launch resets to the canon default
   (single space unless a side brings its own whitespace).
4. **Threshold: ANY FAN on either side opens the sheet**, pre-paired
   with the two chosen takes — ⏎ immediately reproduces today's exact
   outcome; one keystroke buys visibility. The silent-vanish experience
   cannot recur.
5. **N-ary chains stay OUT.** A 3+-block selection chain-merges the
   visible takes instantly as today (toast, lineage, undo); pairwise
   ceremony merges reach every outcome when the takes matter.
