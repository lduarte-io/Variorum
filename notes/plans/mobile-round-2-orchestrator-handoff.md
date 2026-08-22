# Mobile Round 2 — ORCHESTRATOR HANDOFF

**Written 2026-08-22 at the author's instruction.** The outgoing seat is
past the ~500k context line (her call: *"I think I'm going to need you
to write me up a plan file and then I'll start a new orchestrator,
because you're already above the 500k threshold. I think it's fine for
you to complete the orchestration of batch 4 though."*).

**The two-document form:** this file is the ROLE handoff — state, the
schedule, the machinery lessons, and the open author items. The running
record is `notes/plans/mobile-round-2.md` (2858 lines, 43 sections),
which is the phase's own truth and is cited throughout.

---

## 0. PASTE-READY KICKOFF (the successor starts here)

> You are the incoming architect/orchestrator for **Mobile Round 2** of
> the Variorum iPhone app, taking over mid-round. Work in
> `~/dev/variorum-mobile` on branch `mobile`.
>
> **Read, in full, yourself, before anything:** `CLAUDE.md` ·
> `notes/MobileSoul.md` · `notes/plans/mobile-round-2.md` **in full**
> (it is long; the reading rule is load-bearing and this round has paid
> five times for schedule items that lived only in prose) · this file ·
> `.claude/skills/architect-phase/SKILL.md`.
>
> **Then VERIFY, do not trust** (§2 below lists exactly what): the
> branch tip, the suite counts, and whether batch 4 landed. The outgoing
> seat's claims are claims until you have re-run them.
>
> **§3 is the ONLY schedule.** A row is not scheduled until it appears
> in that batch map under a numbered batch — five rows went homeless
> this round because prose said otherwise.
>
> Cast is ALL-OPUS at her ruling (R1), with the surplus spent on review
> depth: a cold ladder per BATCH plus a whole-round pass. Her standing
> instruction is that **nothing gates on installing to her phone** (R3);
> take install windows opportunistically.

---

## 1. WHAT THIS ROUND IS, IN ONE PARAGRAPH

Her iPhone was crashing when she deleted multi-line selections at a
note's end. That crash is fixed (both platforms, **confirmed on her
hardware**). Around it the round is doing three things: **stability**
(the crash class and the architecture question behind it), **three
features she asked for** (copy-the-note, keyboard-bar spacing, a
home-screen quick note), and **the parity backlog** the ledger had
accumulated (PL-9/PL-10/PL-11 → 24 inventory rows). She ruled "build it
all, ordered by importance" (R4).

---

## 2. STATE AT CUTOVER — VERIFY, DO NOT TRUST

**Branch `mobile`, tip should be at or after `c574acc`** (plus whatever
batch 4 lands). Pushed. **Never push `main`.**

**Counts as last measured** (re-run them yourself; CLAUDE.md's rule is
that the previous closeout is the baseline, but this round has moved
them repeatedly):

| | count | note |
|---|---|---|
| core | 1350/141 | unchanged all round |
| Mac | 1568/272 | **exact and unmodified since batch 1's fixes — this is the hoist proof; if it moves, something changed Mac behaviour** |
| Mac spine | 63/8 | exact |
| mobile | 414/71 | grew every batch |
| mobile spine | 33/7 | = `MobileTutorialWalkTests` (25/6) + `MobileWalkTests` (8/1) |

**Hygiene held all round: ZERO schema, ZERO `Sources/VariorumCore/Sync/`
lines, no build configuration added.** The mirror is at lockstep marker
**7**. Keep all three true.

**IN FLIGHT AT CUTOVER: batch 4** (undo door · delete a note · the Trash
· delete a book · the on-leaving savepoint). The outgoing seat completes
its orchestration — build, ladder, fixes, record — at her instruction.
**Confirm it is committed and recorded before starting anything new.**

**Her phone** carries a Release build installed 2026-08-21 23:49 with
batches 1/1b/2/3/3b + R12 + R22/M26. It does NOT yet have batch 4.

---

## 3. THE BINDING BATCH MAP — THE ONLY SCHEDULE

*(Inventory rows are cited **PR**n to avoid colliding with her ruling
numbers — both run 1–24. This is §39's fix for a real confusion risk.)*

| Batch | Contents | State |
|---|---|---|
| 1 | M1 the crash · M2a–M2e | **DONE**, ladder closed round 2 |
| 1b | M11 ≡ PR18 whole-block delete | **DONE**, ladder round 1 fixed |
| 2 | M3 copy door · M4 bar air | **DONE** |
| 3 | M22 merge-then-edit | **DONE** |
| 3b | M5 the quick note | **DONE** |
| — | R12 bar tuning · R22 one-row strip · M26 un-indent | **DONE** |
| **4** | **M20 the undo/redo door (FIRST)** · PR1 delete a note · PR2 the Trash + Archived · PR4 delete a book · PR7 the on-leaving savepoint | **IN FLIGHT** |
| **5 (queued, dispatch next)** | **R26/R27 the shelf layout** (quick note takes Today's Entry's box; books list bounded + scrolls past ~8; writing area ≈ half the screen; Today's Entry becomes a badge on the Journal row, no blinking cursor) · **R27b the starter Journal book** · **R24 "more info" → "info"** | queued behind batch 4 (same shelf files) |
| 6 | PR3 per-note tray · PR5 deleted takes · PR6 archive/unarchive · PR14 lens-dangles notice · PR15 lineage door · PR22 guide deletion chapter | |
| 7 | PR8 reorder takes · PR9 duplicate-book-name guard · PR11 copy all takes · PR12 take→block · **M23 copy-follows-screen** · PR19 swatches+emoji · PR20 block multi-select · PR21 replace | |
| 8 | PR10 tag-chip grammar · PR13 cadence/pruning settings · PR16 PL-9 judgment acts · PR17 document settings · **PR23 the forked voice brain (HOIST, never patch)** | |
| — | **PR24** — her held design calls (the ●n comment marker's side; the margin-comment tap shape) | **propose-only, bundled to a sitting** |

**Not in a batch, deliberately:**
- **M12** the gate-less-insertion re-render — measured 0 in policed typing; **re-owned to 13u** with the caveat that the harness cannot drive the gate-less class.
- **M14** the Read hitch (312 ms main-actor transform per 100k-word row; memory fine at +1 MiB) — **measured, decision held for her**, batch 8's neighbourhood.
- **M16** same-note drag-move — **device-only**, settle on her hardware.
- **M17 / M25** — closeout obligations, → `notes/TEXTKIT2_NOTES.md` §3.
- **M15** (the predicate residue) and **M24** (auto-commit) — **CLOSED**, refuted and declined respectively. Do not reopen without new evidence; §21 and §32 carry the reasoning.

---

## 4. HER RULINGS — INDEX (all verbatim in `mobile-round-2.md`)

R1 all-Opus, more reviews · R2 the crash is top · **R3 never gate on the
phone install** · R4 build all parity, ordered · R5 quick note mints as
you type · R6 the copy door · R7 the bar's air · **R8 Mac-side fixes
authorized for SHARED crashes/bugs (not Mac features)** · **R9 she will
have the round merged to `main` at its end** · R10 the phone needs undo
+ block restore · R11 explain the mid-paragraph limit concretely · R12
the bar overshot · **R13 NO CONFIRM on delete** · R14 trash reachable
from a note by round's end (**a commitment**) · R15 copy follows the
screen · **R16 selecting visible text and deleting should just work** ·
R17→R18 auto-commit proposed then **declined** · R19 the Mac's merge and
delete still get used · **R20 13l's first act is a Fable cold review of
this round's Mac changes** · R21 a visible un-indent · R22 option 1 ·
R23 the glow stays, no text traded · R24 "info" · R25 the buttons are
tappable · R26/R27 the shelf layout + starter Journal.

**Two fences she set personally, and they bind:**
1. **`planVisibleTakeEdit` is HERS** — a cross-block span touching a
   block with takes must keep REFUSING on the phone. She is handling the
   fanned case Mac-side. Verify with `git diff | grep planVisibleTakeEdit`
   after any editor batch; it must be 0.
2. **No Mac FEATURES.** R8 authorizes fixing shared defects, not
   building Mac capability.

---

## 5. MACHINERY LESSONS — the ones that cost real time

**5.1 — PIN QUALITY. This round hit "green over nothing" FOUR times.**
The Mac's dead purge doors · 13j's pins over them · a dead bar-resize
mechanism · an outdent door nobody could find. The rule, in final form:

> **A pin asserting a view model's number, or a view's configured
> property, proves nothing about what renders. Drive the real surface —
> AND verify the path you drove is the path you meant.**

The second clause is not decoration: `UITextView.deleteBackward()` and
`UITextInput.replace(_:withText:)` **mutate storage without consulting
the delegate**, so a pin driving them exercises the recovery road and
misses the gesture entirely (M25). On the phone, drive
`textView.delegate?.textView?(_:shouldChangeTextIn:replacementText:)`.

**5.2 — HOLLOW PINS.** *A pin whose red depends on a state the product
cannot produce pins a fiction.* Say so and skip it, rather than
manufacturing a precondition (§22(a)).

**5.3 — THE PARALLEL-FENCE RECIPE**, learned three times over:
distinct **files** + distinct **simulators (by UDID — never `booted`)**
+ distinct **DerivedData** + (for visual work) a **private source copy**.
Anything less and sessions break each other's builds mid-run.

**5.4 — THE HOMELESS-ROW RULE** (five occurrences): §3's map is the only
schedule. Prose scheduling is a note.

**5.5 — HOISTS PAY FOR THEMSELVES.** Two hoists this round moved
Mac-local rules into `Shared/EditorBrain/`; the Mac suite riding
**unmodified** is the proof a hoist moved an address and not behaviour.
One of them **revealed a six-week-old P1 violation on the Mac** nobody
had noticed (§38). Moving a rule into shared code forces someone to read
it fresh and measure it against the phone's harder bar.

---

## 6. OPEN WITH HER — short, nothing blocking

1. **M14 — the Read hitch.** 312 ms main-actor transform per 100k-word
   Read row. Measured; the fix is hers to want.
2. **PR24** — the ●n comment marker's side; the margin-comment tap shape.
3. **R27b's copy** — the starter journal entry's TEXT is hers to write
   (the 13s row); draft it PROVISIONAL, never ship a placeholder as
   voice.
4. **The 28 pt strip** — she pre-ruled tappable at a quoted 31 pt; the
   built width is **28**. She has seen it and not objected; re-offer only
   if she raises it.
5. **M16** — the drag-move question, on her hardware.

---

## 7. CLOSEOUT OBLIGATIONS — do not lose these

1. **13l's manifest must be COMPLETED** (`phase-13l-data-safety-floor.md`).
   It carries the Mac-side changes for the Fable cold review she ruled as
   13l's first act (R20) — including the O(N²) fix — and it says PARTIAL.
   **Final Mac counts + every Mac file + which hoists the Mac delegates
   to.** A stale manifest wastes the review she asked for.
2. **M17 and M25 → `notes/TEXTKIT2_NOTES.md` §3** (an
   `inputAccessoryView` cannot resize after presentation; the
   delegate-bypassing input APIs).
3. **The parity ledger** in `notes/MobileSoul.md` §6 — burn down PL-9,
   PL-10, PL-11; add this round's own line.
4. **KnownIssues** — the six-brains row gains/loses entries as hoists
   land (`applyTypedPath`, `ThemeStore`, `CalloutPalette`, `BlockSelection`,
   `TakesReplacePlan`, the deletion-copy homes — the inventory's §4(c)).
5. **The master plan** — pointer, the mobile project row, the closeout
   paragraph, and CLAUDE.md's **MOBILE PARITY LINE**.
6. **The author handoff** (`notes/handoffs/…`) with her checklist at top.
7. **The merge to `main` at her word** (R9) — she has said she will ask
   for it at the round's end, and **13l is the first Mac phase to open
   against the merged tree**.
