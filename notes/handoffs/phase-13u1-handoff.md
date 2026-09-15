# Phase 13u1 — THE EDITOR SEAM · AUTHOR HANDOFF

**Closed 2026-09-15.** Self-contained: a fresh session can answer questions about this phase from
this file plus the record it points at (`notes/plans/phase-13u1-editor-seam.md`). If a question
about 13u1 can only be answered from a session's memory, that is a documentation bug — fix the
docs, not the session.

**In one sentence:** your item 5 shipped — *selecting across paragraphs and pressing ⌫ just works
now* — as ONE structural compound with one undo entry, and the seam under it was made solid.

---

## ⬛ YOUR CHECKLIST

### 1. The app is already refreshed — nothing to do, just launch it

You said *"when my app is done you can refresh it - i have it closed now"*, so the refresh ran on
the standing rails. **Your store was never opened and the app was never launched.**

| | |
|---|---|
| **A1 backup (taken FIRST)** | `~/dev/variorum-store-backups/13u1-refresh-20260915T073559Z/` — the WHOLE store folder: `variorum.sqlite`, `-wal`, `-shm`, all three `variorum-keys*.json`, and the 88-entry `Backups/` folder |
| **Backup verified** | `cmp` byte-identical on the sqlite, the wal and all three key files; the sqlite header is **ciphertext** (`1799 8efb 28ec 84e2 …`, not `SQLite format 3`) |
| **Built from** | commit `f4264bff`, in a clean throwaway worktree (`~/dev/variorum-13u1-release`, since removed), `-configuration Release` |
| **Old binary SHA-256** | `490285e03af15e4df98b663050737ae2941d7004ff66a7ccafb7a740e4719a2d` |
| **New binary SHA-256** | `ffe42c8817e324ce9484fd2fa3b5248363ae8ca37508fb595aeb032f26c9f65c` |
*[removed for publication]*
*[removed for publication]*
| **Zero instances** | verified before the backup, before the copy, and after |

### 2. The walk — the cross-block gesture matrix, in the order you would hit it

Take any note with four paragraphs. Every row below was walked on the dev build and captured
(`notes/plans/13u1-screens/`), so this is a confirmation pass, not a hunt.

1. **The everyday one.** Select from the middle of paragraph 1 into the middle of paragraph 3 and
   press ⌫. → The selection vanishes, the two remainders become ONE paragraph with **no space at
   the join**, and paragraph 2 is gone. The bottom bar says quietly: *"1 block to This Note's Tray;
   the ends joined — originals under Came from. ⌥⌘Z undoes it."*
2. **One ⌥⌘Z.** Press it. → All three paragraphs come back exactly as they were. The Edit menu says
   **"Undo Edit Across Blocks"** — one entry for the whole gesture. Press ⇧⌥⌘Z and it goes forward
   again, to the same rows.
3. **The cut at a paragraph break.** Select from the very START of paragraph 1 into the middle of
   paragraph 3, ⌫. → The whole paragraphs go to the tray and the remainder **keeps its own block**
   — no join. That is your ruling: *"if the place cut at was a paragraph, I don't think it should
   be merged."* It also holds for a line break INSIDE a block (⇧⏎'s newline counts).
4. **A fanned middle → the tray → Put back.** Put a take on paragraph 2 (Block ▸ New Take), then do
   the everyday gesture again. → The ends join and paragraph 2 leaves **whole, with both takes**.
   Open the tray (the icon at the top of the note): it is there with **Put back** and 30 days left.
   This is the one place your ruling changed the old behaviour, which used to empty the shown take
   and leave a blank block with a fan hanging on it.
5. **A fan on an END.** Put a take on paragraph 1 instead and do the gesture. → **Two blocks stay
   two**, the fan untouched, and the line says why: *"the ends kept their own blocks — one has
   takes."* A keystroke never folds a fan away.
6. **The two refusals, and there are only two.** Lock a take (Takes panel ▸ ⋯ ▸ Lock this take) and
   try the gesture → *"A take in this selection is locked — nothing was changed. Branch it or
   unlock it, then try again."* **Nothing is deleted.** Then seal the note (note ▾ ▸ Seal) → the
   surface reads *"sealed note — read-only"* and the keystroke does nothing.
7. **⌥⌘Z on a ⏎-made empty block.** Type a paragraph, press ⏎ at its end (which makes an empty block
   below), then press ⌘Z. → It now **tells you** *"Nothing to undo in the text — your last change
   was structural: ⌥⌘Z undoes it"*, and ⌥⌘Z really removes the block. Before this phase it did
   nothing and said nothing.
8. **The quit-during-flight safety** (worth one try, because it is where the ladder found real text
   loss): start a structural act from a MENU (Block ▸ New Block Below), and while it is landing type
   a letter, ⏎, another letter. → Both letters are kept and the ⏎'s block is made. Quitting in that
   window is safe too.
9. **The thing you praised** — *"the selection and location that you're at are following between
   different modes excellently"* — was treated as a constraint: no landing pin was touched, and the
   walk round-tripped Write → Takes → Blocks → Write staying at block 2/2.

### 3. To ratify

- **QUESTIONS #109 — a selection with an end sitting on a block boundary.** The phase's ONE
  PROVISIONAL. Shipped as (a): it keeps its old refusal, now worded truthfully. **Part (d) is the
  one I'd read closely** — it names a shape where taking the gesture is clean under your own
  R-13u-2 ruling (a whole paragraph really does get deleted), and says why the *other* shape in the
  family is a different question. Nothing is built past (a).
- **QUESTIONS #103** — still outstanding from the 2026-09-12 round (three PROVISIONAL calls on the
  Library card's two facts). Unchanged by this phase; listed so it does not get lost.

### 4. One call that is yours, and I think it is worth making soon

**The phone's tutorial teaches a rule the app no longer follows.** Its "divide with takes" lesson
still says the other takes are *"copied onto both halves"* and *"the extra copies are quick to
delete"* — which your U-2 ruling (2026-09-06) superseded on BOTH platforms. The Mac's lesson was
rewritten then; the phone's was not. It is `KnownIssuesAndTechDebt.md`'s row 64, owned by the mobile
project — **but a friends-beta reader would be taught a rule the app does not follow**, so it may
deserve a 17 entry ahead of the mobile session at your word.

### 5. Judgment calls worth your eye (nothing blocking)

- **⌘Z still stops at a paragraph break, and I decided to keep it that way.** Every structural
  rewrite clears the text-undo stack because a replayed edit would land at moved offsets — the
  corruption class. I checked whether it could be narrowed: AppKit gives no way to drop part of
  `NSTextView`'s own undo stack, and nothing can rebase a registration across a rewritten storage,
  so the alternative is writing our own undo stack over the text — a redesign of the riskiest
  subsystem in the app. What makes it *cost less now*: the ⏎-made block is undoable (item 7 of the
  walk), and the savepoint taken right before a cross-block edit survives the session.
- **A cross-block edit now says something.** It used to be silent, deliberately. It speaks because
  it moves blocks to the Trash, and a delete whose receipt names no road reads as permanent. It is
  a **quiet** line in the bottom bar (your 18i default), never a toast.
- **A fanned block you select WHOLE now goes whole.** That supersedes the 2026-07-13 #11a behaviour
  for that one cell, in your words: *"recoverable, family intact."*

---

## WHAT SHIPPED, AND WHY IT IS SHAPED THIS WAY

### The compound (item 5)

One gesture = ONE structural compound. Each block the selection touches gets exactly one of two
fates, decided by **how much of it you selected**:

- **covered WHOLE** → `deleteBlock`, the Trash/tray road: takes preserved, Put back real, a fanned
  block included (your ruling). *Why not merge it away, which is what the old road did: merging
  releases a block to lineage with no tombstone, so there is nothing in the tray and Put back has
  nothing to put back.*
- **covered in PART** → the block keeps its identity and its **chosen take** takes an ordinary
  buffer edit. A fanned edge touches only what you can see.

The two surviving ends **join** when both cuts sit mid-paragraph (**R-13u-2** — "paragraph break"
covers a block seam AND a line break inside a block; one function answers for both ends so the two
halves of your ruling cannot drift) **and** no fan hangs on either (#11a's standing rule, carried
forward). The merge runs LAST with both texts whole, which is what makes the join character fall
inside what you deleted — so it reads as "the selection vanished", never "…and left a space".

Refusals shrink to **a sealed note** and **a locked take** (**R-13u-1**: refuse the whole gesture,
name the lock), plus the two standing fences that are not about the gesture — a block that has not
synced, and the open tail.

Before the compound, a quiet savepoint of every take it is about to edit — **the seventh quiet
auto-commit occasion**, your own idea. The reason it is right here: this gesture mixes the
text-undo and structural-undo worlds, which never interleave by design, so the state it overwrites
has no ⌘Z road afterwards. The savepoint is the road that outlives the session.

### The floor under it (unit 1)

The seam had a performance invariant violation on the **keystroke road**: a helper walked every
block from zero on every call, inside loops. Swept to completion on both platforms — 14 callers
fixed, 24 verdicted safe — and the hottest (which ran on *every caret move*) measured **29.2 s →
3.3 ms** at 20,000 blocks. Separately, the Mac computed churn from macOS 26's *widened* edit report,
so **three typo keystrokes in a long paragraph could stamp a note as majorly revised** — exactly
what "fixing one typo must never reshuffle the library" forbids. Now it takes the edit's own cost.

### Canon, extended twice — both yours

- **AppSpec §9's structural-undo list gains `newBlock`** (R-13u-3), with type-time crystallization
  as its one named exception (a paragraph becoming a block because you typed past it is not a
  gesture you made).
- **OverallModel §3 gains the seventh quiet auto-commit occasion.**

---

## VERIFICATION

| suite | result |
|---|---|
| core `swift test` | **1562 / 170, all green** |
| the FULL Mac suite | **2668 / 445, ALL GREEN** (726 s; neither load-flaky suite fired) |
| iOS build | **green** |
| the FULL mobile suite | **622 / 105 PASSED with 4 known issues** — green for the first time since the tutorial mismatch was found; the mismatch still reports on every run |

**Zero `Sync/` lines · zero schema · zero migrations · lockstep marker 8 · no commit trailers.**

Every bug-class fix landed with a **red-on-old pin** — a test that fails on the real pre-fix code.
Six were measured on a scratch worktree at the unit's first commit (one of them reproducing the raw
`blocksNotAdjacent(first:…, second:…)` enum dump, with two UUIDs in it, that you would have met);
three more in place during the ladder. **Nothing was dismissed as hollow.** A 16-capture hands-on
walk covered the matrix; **the walk changed the build once** — the receipt was too long and
truncated exactly where the join clause began, so it was rewritten to name both destinations first.

---

## FINDINGS & DISPOSITIONS, IN BRIEF

**Ladder round 1** (cold `fable-reviewer`): 0 BLOCKER · **2 MAJOR** · 1 MINOR · 4 NIT, plus 3 raised
by the implementer's sanity pass. All confirmed; none hollow.
- **MAJOR 1** — two waits in the quit/lock/seal/teardown door did not compose, so a menu-born act's
  own key-replay could forge work the door then walked past. Measured, it **swallowed a typed ⏎**.
  Fixed as one loop; pinned.
- **MAJOR 2** — a refusal sentence was false for one shape, and three records claimed too narrow a
  scope for what still refuses — the scope you would have ruled #109 on. Corrected; #109 gained
  part (d).
- The rest: a doc citing numbers its own source does not hold; a pin name overstating what the copy
  says; two recorded-only shape notes; and the mobile tutorial pin converted to a visible
  known-issue so the suite's green means something again.
- **Sanity pass** — one was bug-class: a span ending at the tail's own separator spoke the wrong
  cause.

**Ladder round 2** (a fresh cold reviewer): 0 BLOCKER · 0 MAJOR · 0 MINOR · **2 NIT**, both in the
one condition round 1 touched. One was bug-class on its trace — an *empty* trailing line's refusal
promised a road that can never open. Both fixed. **No round 3 owed.**

---

## WHAT IS DEFERRED, AND WHO OWNS IT

| item | owner |
|---|---|
| **QUESTIONS #109** (a)–(d) | **you** |
| The phone's FACE for the compound — a receipt naming where every block went, its own device walk, the R-13u-4 capture face (⏎ files · ⇧⏎ paragraph), a call on "Undo New Block" in its undo sheet | the mobile app project (`notes/MobileSoul.md`, **PL-23**) |
| The phone's tutorial lesson (row 64) | the mobile project — **or a 17 entry at your word** |
| **Multi-block paragraph drag** (item 12) | its own unslotted row in `notes/FuturePhases.md` (**R-13u-5**); it reuses this phase's machinery and wants a short design sitting |
| Item 9's quick-capture FACES (the model is ruled) | 13u3 (Mac) · the mobile catch-up (phone) — **R-13u-4** |
| The rows 13u1 inherited and re-owned (the `TakesArticleScroll` split, the status seam's audit surface, the re-font road, the Outline's shadow editor, the DEBUG-oracle sweep, ⌘A in a pane, M12) | **13u2** |

---

## WHERE EVERYTHING IS

| | |
|---|---|
| The phase record | `notes/plans/phase-13u1-editor-seam.md` — the SITTING RECORD (R-13u-1…R-13u-11), both UNIT RECORDs with their traced mechanisms and measurements, the two-round ladder, the PHASE CLOSEOUT |
| The walk's captures | `notes/plans/13u1-screens/` (16) |
| The closeout paragraph | `notes/DetailedPlanForPhases.md`'s closeout log |
| The canon deltas | `notes/AppSpec.md` §9 and §14 · `notes/OverallModel.md` §3 |
| The mobile parity row | `notes/MobileSoul.md`, PL-23 |
| Your open questions | `notes/QUESTIONS.md` #109 (new) and #103 (carried) |

---

## NEXT

**13u2 — FEEL & FACES**, at your word. It is already the current phase in the master plan, its
kickoff and baselines are refreshed (`notes/plans/phase-13u2-feel.md`), and it carries a **"what
13u1 changed under you"** section so a fresh session does not have to rediscover the seam. **It
needs no sitting of its own to start** — the one shared 13u kickoff sitting already ruled both
halves (R-13u-7 placed your 2026-09-14 feedback as its items 18 and 19; R-13u-10 ruled the
book-Index set).

Standing beside it at your word, in the order you set: the two grouped standing-fix runs
(`notes/plans/pre-beta-standing-fix-runs.md` — RUN A custody & text-loss doors, RUN B sync
correctness) and the stress-test pass, then 13y, then packaging, then the friends beta.
