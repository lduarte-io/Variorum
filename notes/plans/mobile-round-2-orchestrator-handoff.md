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
> the Variorum iPhone app, taking over mid-round from a seat that ran
> out of context. Work in `~/dev/variorum-mobile` on branch `mobile`.
> Run under `/architect-phase`.
>
> **READ FIRST, IN THIS ORDER, IN FULL, YOURSELF:**
> 1. `notes/plans/mobile-round-2-successor-first-acts.md` — **her
>    instruction for what you do before anything else.** Start here, not
>    with the batch map.
> 2. `CLAUDE.md` · `notes/MobileSoul.md` ·
>    `.claude/skills/architect-phase/SKILL.md`
> 3. `notes/plans/mobile-round-2.md` **in full** (long; the reading rule
>    is load-bearing — this round paid six times for items that lived
>    only in prose)
> 4. **This file**, then
>    `notes/plans/mobile-round-2-consistency-audit.md`
>
> **THE ROUND'S ONE-LINE STATE:** batches 1–4 are built; **five of seven
> shipped without a cold review** until the author asked three times;
> when the reviews finally ran they found **three BLOCKERs** — two that
> destroy or discard her text in the quick note, one that leaves four
> confirm buttons inoperative. **Batch 4.5 exists to fix all of it.**
>
> **VERIFY, DO NOT TRUST.** §2 lists what: the branch tip, the suite
> counts, whether batch 4 landed. **Several diagnoses in this round were
> traced by READING and never EXECUTED, and several were reported done
> when only their easy half was done.** One of them — the Mac's
> dead-door mechanism — was repeated six times before anyone ran it and
> found it wrong. Inherit nothing; re-derive what you rely on.
>
> **§3 IS THE ONLY SCHEDULE.** A row is not scheduled until it appears
> in that batch map under a numbered batch. Prose scheduling — an
> "owner" column, a sentence in a record, a promise in a message to her
> — is a NOTE, not a schedule. Write the map in the same commit that
> names a row; dispatch from the map, never from prose.
>
> **R28 — THE BATCH LOOP IS SELF-CLOSING (her ruling, and it is the fix
> for this round's worst failure).** A batch dispatch is
> **BUILD → COLD REVIEW → FIX → CONTINUE**, as ONE unit, dispatched
> together, completed without a human in the middle. You do not decide
> after a build reports whether to review it. **The review is inside the
> batch.** A batch reaches her only as build + review + dispositions.
>
> **STANDING INSTRUCTION — 13l IS THE NEXT MAC PHASE, AND YOU FEED IT AS
> YOU GO.** This is a MOBILE round that keeps changing Mac code (the
> crash lived in a shared brain; every hoist since has moved Mac-visible
> logic). `notes/plans/phase-13l-data-safety-floor.md` carries a
> **MANIFEST** of those changes for the Fable cold review she ruled as
> 13l's first act (R20). **Write every Mac-important change and every
> Mac residual into that manifest IN THE COMMIT THAT MAKES IT — never at
> closeout.** It went stale once already because a record said an item
> "belongs there" and nobody carried it across.
>
> **TWO REVIEWS ARE BOUND AS EXIT CONDITIONS, not list entries** (§3's
> last two rows): the **dedicated stability pass** is batch 4.5's exit
> condition, and the **whole-round pass** is closeout obligation ZERO.
> Neither is discharged by anything that resembles it — if you catch
> yourself thinking *"we already did a review like that,"* that is
> exactly how this round lost five of them.
>
> **CAST: ALL-OPUS** (R1), with the surplus spent on review depth.
> **Her standing rule: nothing gates on installing to her phone** (R3) —
> take install windows opportunistically. **And when she offers her
> device, run the device-only queue in that window** (B45-4: E1 and
> M16), not just the install — this round spent one such offer on two
> installs while both sat runnable.

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

> **VERIFIED BY THE INCOMING SEAT, 2026-08-22.** Tip **`d62d820`**,
> working tree **clean**, `origin/mobile` in sync (0 ahead / 0 behind).
> **`git diff 46ffa0c..HEAD -- Sources/` is EMPTY** and zero
> `Sources/VariorumCore/Sync/` lines — both hygiene claims hold. **Batch
> 4 landed** (`e7e2472`, in history). **`ZZProbe2Tests.swift` is gone**
> (the audit's finding 19 — the tree is clean, so the count it would
> have moved is trustworthy). **NO Swift moved after `e7e2472`**
> (`git diff --stat e7e2472..d62d820 -- '*.swift'` is empty), so the
> 449/75 and 1568/272 figures describe the current tree; the mobile
> figure was re-run to confirm. **The Mac footprint of this round is TEN
> files** — `Shared/EditorBrain/{BlockRangeIndex,CrossBlockEditPlanner,EditorEditRouting}.swift`,
> `Shared/{RecoveryCopy,StructuralUndoCopy}.swift`,
> `Variorum/Features/Editor/{EditorSurfaceController,EditorViewModel}.swift`,
> `Variorum/Features/Library/RecoveryView.swift`,
> `Variorum/Features/Tray/TrayPanel.swift`,
> `Variorum/Registry/ShellActions.swift` — plus three `VariorumTests/`
> files. That list is the 13l manifest's completeness check.
>
> **HER MAC APP IS LIVE** (`/Applications/Variorum.app`, pid observed at
> cutover). It is her real-store daily drive: **never quit it, never
> kill it, and no Release build or `/Applications` refresh while it
> lives.**

**Counts as last measured** (re-run them yourself; CLAUDE.md's rule is
that the previous closeout is the baseline, but this round has moved
them repeatedly):

| | count | note |
|---|---|---|
| core | 1350/141 | unchanged all round |
| Mac | 1568/272 | **exact and unmodified since batch 1's fixes — this is the hoist proof; if it moves, something changed Mac behaviour** |
| Mac spine | 63/8 | exact |
| mobile | 449/75 | grew every batch; last measured at batch 4's landing (§46) |
| mobile spine | 33/7 | = `MobileTutorialWalkTests` (25/6) + `MobileWalkTests` (8/1) |

**Hygiene held all round: ZERO schema, ZERO `Sources/VariorumCore/Sync/`
lines, no build configuration added.** The mirror is at lockstep marker
**7**. Keep all three true.

**BATCH 4 LANDED** (undo door · delete a note · the Trash · delete a book
· the on-leaving savepoint) — commit `e7e2472`, recorded in the plan's
§46, mobile **449/75**. *(This line said "IN FLIGHT AT CUTOVER" when the
handoff was written; the outgoing seat completed its orchestration as
her instruction allowed.)* **Its own cold ladder is OWED** — §43's rule
binds it like every other batch — and it joins the consolidated fix
round's queue with the five reviews already reported (§44, §45).

**Her phone** carries a Release build installed 2026-08-21 23:49 with
batches 1/1b/2/3/3b + R12 + R22/M26. It does NOT yet have batch 4.

---

## 3. THE BINDING BATCH MAP — THE ONLY SCHEDULE

*(Inventory rows are cited **PR**n to avoid colliding with her ruling
numbers — both run 1–24. This is §39's fix for a real confusion risk.)*

| Batch | Contents | Built | **Cold review** |
|---|---|---|---|
| 1 | M1 the crash · M2a–M2e | ✅ | ✅ rounds 1+2, closed |
| 1b | M11 ≡ PR18 whole-block delete | ✅ | ✅ round 1 fixed · **round 2 landed 2026-08-22 → §44, 1 MAJOR + 7 open** |
| 2 | M3 copy door · M4 bar air | ✅ | ⚠️ **reviewed 2026-08-22 → §45, 2 MAJOR open** |
| 3 | M22 merge-then-edit | ✅ | ⚠️ **reviewed 2026-08-22 → §45, 4 MAJOR open** |
| 3b | M5 the quick note | ✅ | 🔴 **reviewed 2026-08-22 → §45, TWO BLOCKERs + 2 MAJOR + more.** *(This cell read "in flight — reviewer C not yet reported" when the handoff was written; C reported the same night, and its findings are the round's worst: the batch whose whole promise is "nothing you type is lost" breaks that promise in two traced ways. Q1/Q2 lead the consolidated fix round.)* |
| — | R12 bar tuning · R22 one-row strip · M26 un-indent | ✅ | ⚠️ **reviewed 2026-08-22 → §45, 2 MAJOR open** |
| **4** | **M20 the undo/redo door (FIRST)** · PR1 delete a note · PR2 the Trash + Archived · PR4 delete a book · PR7 the on-leaving savepoint | ✅ `e7e2472` → §46 | ⏳ **DISPATCHED 2026-08-22** at her instruction (§47/R28); its findings join batch 4.5 |
| **4.5 (THE CONSOLIDATED FIX ROUND — dispatch first)** | **Every finding from every cold review of batches 1–4, plus her four named rows and both successor Acts.** Full ordered enumeration: `mobile-round-2.md` **§52**. In brief, by consequence: **Q1** the quick-note clamp DESTROYS stored text · **Q2** a refused mint at a leaving wipes the box AND the error · **the batch-4 BLOCKER** — four confirm buttons read back state SwiftUI has already cleared (Delete Now · Empty Trash · Library-row Delete Note · Shelf-row Delete Book) and the A12 warning's **Undo CANCELS it** · then §45's MAJORs (the fan fence read from a frozen projection · the 320 pt strip overflow · the surviving O(N²) twin in `planVisibleTakeEdit` · the geometry pins asserting constants against themselves) · §49's two MAJORs · §44's MAJOR (the Mac gets the gap fence's REFUSAL but not its FACE) · **B45-1** `AppBootstrap` runs migrations synchronously on the MAIN THREAD before first paint (a **P2** violation) · **B45-2** the `displaySlot`/`slots[i]` coupling that batch 7's PR8 walks into · **B45-3** the crash trace's six unowned items · **B45-4** THE ON-DEVICE SWEEP (E1 + M16, ONE window) · **+ ACT 1's findings** (a fresh cold read over the round's whole shipped diff) **+ ACT 2's findings** (the never-became-work sweep) | ⏳ | **ITS EXIT CONDITION IS THE DEDICATED STABILITY PASS** (the row below). 4.5 is NOT done until that pass has run. Its own build half is reviewed under R28 like any batch |
| ↳ **4.5a** capture & lifecycle (Q1 · Q2 · Q3 · Q4 · Q5–Q10 · A1-19 · B45-1 measured) | ✅ built → §58 · ✅ **FIXED** → §62 | ✅ round 1 → §59 (5 MAJOR, all accepted) · ❌ **ROUND 2 OWED** (dispatched, died on the API limit before reading anything) |
| ↳ **4.5b** deletion doors & the confirm BLOCKER (+ the accessibility-harness fix, + the `TrashPutBack` hoist) | ✅ **built** → §63 | ❌ **COLD REVIEW OWED** (dispatched, died on the API limit before reading anything). **This is the only in-flight work touching `Shared/` and the Mac** |
| ↳ **4.5d** the keyboard bar's geometry | ✅ built → §60 | ✅ reviewed → §61 (2 MAJOR + 6 MINOR + 6 NIT) · ❌ **FIX ROUND OWED** (dispatched, died on the API limit after establishing baseline; **it left an experimental revert in the tree, which the architect found and restored — see §64**) |
| ↳ **4.5c** the editor & the shared brain — **THE LARGEST REMAINING RISK IN THE ROUND** | ❌ **NEVER RAN.** WAVE 2, alone (every target compiles against `Shared/EditorBrain/`) | ❌ owed |
| ↳ **4.5e** the shared lifecycle files + the Mac's quick-capture twins | ❌ **NEVER RAN.** WAVE 3, alone | ❌ owed |
| **4.5e (born 2026-08-22 — three findings converge on two `Shared/` files nobody owned)** | **B45-1's fix** (`AppBootstrap` opens the store and runs migrations synchronously on the main thread before first paint — a **P2** violation; MEASURED at 54.0 ms first launch / 5.0 ms reopen / 3.6 ms at 100k, so **flat in corpus size** and O(migrations), not a hang today, but the migration set only grows and the device number is unknown) · **A1-21** the `postAutosaves` removal path (the quick note adds one coordinator per capture) · **A1-15's** two inverted comments. **Owns `Shared/AppBootstrap.swift` + `Shared/AppSession.swift`.** Born because the architect's §1 brief gave 4.5a *"the `AppSession` lines"* without listing the file — 4.5a refused to reach across and reported, which is the fence catching the architect's own error | ⏳ **WAVE 3, alone** — those two files are compiled against by every target, exactly like 4.5c's editor brain | ❌ owed (R28) |
| **5 (queued)** | **R26/R27 the shelf layout** (quick note takes Today's Entry's box; books list bounded + scrolls past ~8; writing area ≈ half the screen; Today's Entry becomes a badge on the Journal row, no blinking cursor) · **R27b the starter Journal book** · **R24 "more info" → "info"** · **NEW 2026-08-22 (§53 items 6 + 7): the shelf has NO keyboard-avoidance opt-out** (`MobileShelfView.swift:101` carries only `.background(tokens.room.ignoresSafeArea())`, unlike Write's `.ignoresSafeArea(.keyboard)`) **and R26/R27 pin a DWELLING text field into that layout** — default avoidance insets the whole `VStack`, so the tab bar rides the keyboard and the bounded books list collapses, making **her ruled "about half the phone screen" the first casualty**; plus **the quick note's mint cost at corpus scale, never measured** (`MobilePerfWalkTests` has no quick-note leg; the 100k dev store exists) — measure alongside the layout change, fix only if the number earns it | queued behind 4.5 (same shelf files) | ❌ owed |
| 6 | PR3 per-note tray · PR5 deleted takes · PR6 archive/unarchive · PR14 lens-dangles notice · PR15 lineage door · PR22 guide deletion chapter | | ❌ owed |
| 7 | PR8 reorder takes · PR9 duplicate-book-name guard · PR11 copy all takes · PR12 take→block · **M23 copy-follows-screen** · PR19 swatches+emoji · PR20 block multi-select · **PR21 replace — and it HOISTS `FindReplaceGate` WITH it, never after** (§56's A1-17): that gate is Mac-app-local today, and the phone is safe only because `MobileEditorTextView.swift:754` returns `supportsTextReplacement: false`. **The phone's editor now routes cross-block spans into merge-then-edit and whole-block deletion**, so a machine-driven find-and-replace sweep must never be able to restructure the post. Same shape as B45-2 — a known hazard with a dated collision, and this row is the date | | ❌ owed |
| 8 | PR10 tag-chip grammar · PR13 cadence/pruning settings · PR16 PL-9 judgment acts · PR17 document settings · **PR23 the forked voice brain (HOIST, never patch)** — **and it closes §53's item 5 in the same act**: `MobileEditorStyle.storedVoice` is an unenforced `nonisolated(unsafe)` main-thread convention (`MobileEditorStyle.swift:48`) read from a `nonisolated` `MarkdownFace.style`. No live race today; the stated trip is *"a future off-main markdown pass"* — **which is M14's Read fix, also in this batch.** The tripwire and its closer are already in one batch; the row simply never said so · **M14's UNMEASURED HALF** — the SwiftUI `Text`-per-paragraph sizing on the Read surface, which needs a rendered view (§19 promised it "is measured there too" and it had landed in no map; measurement only, no fix — the decision is hers, §6 item 1) | | ❌ owed |
| — | **PR24** — her held design calls (the ●n comment marker's side; the margin-comment tap shape) | **propose-only, bundled to a sitting** | ❌ owed |
| **REVIEW — the dedicated stability pass** (§8's second commitment; it lived only in prose until 2026-08-22 and §43's own accounting missed it) | ONE fresh cold reviewer whose ONLY brief is **the crash class and the editor's range/identity math** — adversarial, tasked to find the case the fix misses. *It reviews the FIX, not the feature*, so its target is batch 1 + batch 1b + M22's shared-brain work as one body: `Shared/EditorBrain/` (`BlockRangeIndex`, `EditorEditRouting`, `CrossBlockEditPlanner`) and both platforms' `storageDidEdit` consumers. **It OWNS M27** — the first typed edit after a DIVIDE is unroutable and takes `desyncRecovery` (§46, reproduced on the pre-batch tree, neither caused nor fixable in batch 4). **Read it beside B45-3** (`mobile-round-2-successor-first-acts.md`): that row owns the crash trace's six *unowned items* (E1, E2, the UIKit undo-replay path, the `supportsTextReplacement: false` fence note, the `MarkdownActs` Mac residual, M1's SUSPECTED status) as BUILD/EXPERIMENT work; this pass is the adversarial REVIEW of the fix itself. Neither discharges the other | **TRIGGER: batch 4.5's exit condition — 4.5 IS NOT DONE UNTIL THIS HAS RUN** | n/a (it IS a review) |
| **REVIEW — the whole-round pass** (§8's third commitment; in no map and no closeout obligation until 2026-08-22) | ONE fresh cold reviewer over the round's **entire diff** (`46ffa0c..HEAD`), briefed on **nothing but the diff** — the round's own cold read, **after the LAST build batch** and after the consolidated fix round lands. Findings go in the plan with dispositions like any ladder round. **It is NOT discharged by ACT 1** of `mobile-round-2-successor-first-acts.md`: her Act-1 pass is an *earlier* cold read over batches 1–4 feeding batch 4.5, and §8's pass is the round's *closing* read over everything, batches 5–8 included. Two passes, two moments, both hers | **TRIGGER: the LAST build batch's exit condition — the round CANNOT CLOSE until this has run** | n/a (it IS a review) |

**Not in a batch, deliberately — and each now lands somewhere that survives this round's close** (the 2026-08-22 audit's finding 8: "re-owned in prose" is the homeless state under another name):
- **M12** the gate-less-insertion re-render — measured 0 in policed typing; **re-owned to 13u** with the caveat that the harness cannot drive the gate-less class. **It now has a `notes/KnownIssuesAndTechDebt.md` row owned by 13u**, so the ownership outlives this plan file; the closeout still names it on 13u's master-plan row.
- **M14** the Read hitch (312 ms main-actor transform per 100k-word row; memory fine at +1 MiB) — **measured, the DECISION is held for her** (§6 item 1). Its **unmeasured half is now scheduled in batch 8** above, where §19 always said it belonged.
- **M16** same-note drag-move — **device-only**, settle on her hardware. **Closeout obligation 8** binds it: settled at a device round, or re-owned with a named owner before the round closes.
- **M17 / M25** — closeout obligations, → `notes/TEXTKIT2_NOTES.md` §3.
- **M27** the post-divide unroutable edit — **owned by the dedicated stability pass**, now a real row in the map above.
- **M9** the parity inventory's missed-capability sweep — **CLOSED 2026-08-22 against the inventory's own §4(b)**, which performed exactly that sweep and produced ten items: nine became rows (PR4 · PR10 · PR14 · PR17 · PR18 · PR20 · PR21 · PR22 · PR23), all of them in the map above, and the tenth (the `deleteConfirmDetail` promise going stale) was discharged at batch 4, which graduated the sentence when M20 made its second half false. Nothing is left for a second sweep to find.
- **M15** (the predicate residue) and **M24** (auto-commit) — **CLOSED**, refuted and declined respectively. Do not reopen without new evidence; §21 and §32 carry the reasoning.
- **M18** (copy vs. what's on screen) — **SETTLED by R15**; the build is **M23**, batch 7. **M19** (the glow) — **CLOSED by R23**, nothing built.

---

### ⚠️ THE TWO STANDALONE PASSES HAVE TRIGGERS, NOT DATES — read this

The two rows above are the ONLY scheduled items in this round that are
**not** dispatched by a batch. Every other review fires because R28
makes it part of a batch's dispatch. **These two attach to nothing that
fires on its own**, which is the exact shape that lost five reviews and
six work rows in this round.

**So they are bound as EXIT CONDITIONS rather than entries in a list:**

| Pass | Cannot be skipped because… |
|---|---|
| **The dedicated stability pass** | **Batch 4.5 is not complete until it has run.** 4.5 fixes the crash-class findings; this pass is the adversarial read of *those fixes*. Marking 4.5 done without it is marking a batch done without its review — the thing R28 forbids |
| **The whole-round pass** | **The round cannot close until it has run.** It is closeout obligation 0: before the parity ledger, before the master plan, before the handoff to her. If you are writing a closeout and this has not run, stop and run it |

**Neither is discharged by anything that resembles it.** Her ACT 1 pass
(`mobile-round-2-successor-first-acts.md`) is an *earlier* read over
batches 1–4 feeding 4.5. **B45-3** owns the crash trace's unowned items
as *build/experiment* work. Both look like the stability pass from a
distance; neither replaces it. If you find yourself reasoning *"we
already did a review like that"* — that reasoning is how this round lost
five of them.

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
   fanned case Mac-side. Verify with `git diff -- '*.swift' | grep planVisibleTakeEdit`
   after any editor batch; it must be 0. **(Do NOT grep the whole diff:
   `notes/*.md` contain the fence's own text, so an unfiltered grep
   returns 5 and false-positives. Zero SWIFT hits is the test.)**
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
4. **The strip's act width is now TWO REGIMES, not one — CORRECTED
   2026-08-22** (§61's MAJOR 2: this item read *"the built width is 28"*,
   which the 4.5d fix made false). She pre-ruled tappable at a quoted
   **31 pt**; the built width is **28 pt on every phone ≥ 375 pt**
   (byte-identical to what she has seen and not objected to) **and 23 pt
   at the 320 pt Display-Zoom width.** The architect ruled **accept 23**
   — the alternatives are dropping an act (an act-count change, and she
   ruled eleven) or scrolling (contradicts FIX-5, and hides acts on the
   one width where she can already see least). **This is INFORMATION for
   her, not a gate** — but it is a ruling about a number, and the number
   has moved 31 → 28 → 23 while this was the only register she reads.
   **And 23 × 38 pt acts have never been rendered for a human** — the
   28 pt strip was photographed on device; the 23 pt strip has only
   frames-in-bounds in a plain window host. **Device-queue row D9.**
5. **M16** — the drag-move question, on her hardware.

**Five more, folded in 2026-08-22** (the audit's finding 5: each was
marked "held for her" and pointed at a bundle that **does not exist** —
§21 sent one to "§22", §35 sent one to "§36's bundle", and neither
section ever grew a list. They are not new questions; they are questions
that were promised a home and never got one):

6. **F2 — where a phone quick note lands** (§11's HELD FOR HER). It
   ships **bookless**, the grammar of the Mac bar she praised (the Pool
   lists bookless notes — R29). But the Mac's two capture surfaces
   genuinely disagree: its floating pad files into Quicknotes via
   `fileAsQuicknote`, her own R6-4 ruling there. *Should phone quick
   notes file into a Quicknotes book instead?* Reversible in one call.
7. **The Release-side boundary check** (§21's ruling (3)). The DEBUG
   half shipped **ON THE PHONE ONLY — corrected 2026-08-22** (§53's
   finding 1: `auditIdentityProjection` and its separator check live in
   `MobileEditorViewModel`, and the Mac has **no identity-projection
   audit at all**, though both platforms share the brain and took the
   same crash fix). The phone's identity audit now catches the
   corruption class both prior oracles were blind to. What is held is a **Release-side**
   belt: the reviewer framed it honestly as *defence-in-depth against an
   untraced class, not a fix for a live bug*, which makes it a
   risk-appetite question about her own prose, not an architect's.
   **The premise moves before she rules:** 4.5c gives the Mac the
   DEBUG oracle it never had, so by the time this reaches her the
   "DEBUG half" will be true of both platforms — which is the version
   of the question she should actually be answering.
8. **The gap-fence Mac narrowing** (§34(a) — *"it goes on her list as a
   notification, not a request"*). A whole-block-delete run that
   contains a **gap** block (one whose text has not synced) is now
   declined on BOTH platforms, because the shared brain carries the
   fence. It narrows a shipped Mac gesture. **Read it beside §44's
   MAJOR 1**, which falsified the trace that made this look free: the
   Mac gets the fence's REFUSAL but not its FACE, and she would read a
   raw `blocksNotAdjacent(first:second:)` enum dump. The fix is in
   13l's manifest; the narrowing itself is still hers to notice or
   object to.
9. **The ⋯-door gap boundary** (§34(b)). The Mac's ⌘-click pick and
   BOTH platforms' ⋯ ▸ Delete Block still ACCEPT a gap block — the
   fence covers the sweep, not the deliberate per-block act she is
   pointing at. Endorsed as the right distinction; recorded for her
   because it is a boundary, not an oversight.
10. **The gap-spanning-plan decline** (§38(a)). On the Mac a
    merge-then-edit plan may still SPAN a gap: the gap renders
    zero-length, the plan names the two readable blocks, and `ops.merge`
    refuses on adjacency so nothing lands. Mac behaviour was
    **preserved** rather than quietly narrowed — declining earlier is a
    change to a ratified road, so it goes on her list rather than into a
    mobile batch.

---

## 7. CLOSEOUT OBLIGATIONS — do not lose these

1. **13l's manifest must be COMPLETED** (`phase-13l-data-safety-floor.md`).
   It carries the Mac-side changes for the Fable cold review she ruled as
   13l's first act (R20) — including the O(N²) fix — and it says PARTIAL.
   **Final Mac counts + every Mac file + which hoists the Mac delegates
   to.** A stale manifest wastes the review she asked for.
2. **M17, M25 AND THE HOSTED-SURFACE HARNESS HAZARD → `notes/TEXTKIT2_NOTES.md` §3** (an
   `inputAccessoryView` cannot resize after presentation; the
   delegate-bypassing input APIs). **A third candidate was proposed
   2026-08-22 and DOES NOT QUALIFY as written** (§61's MAJOR 1): the
   `makeKeyAndVisible()` harness interaction is a real, reproducible,
   isolated-three-ways **observation**, but its stated MECHANISM was
   falsified — three untouched key-window hosts already coexist in a
   green run. **An untraced observation is not a platform truth and must
   not be routed into TEXTKIT2_NOTES as one.** It stays in the round's
   record and in the briefs' §0 as *what was measured*; it earns a
   TEXTKIT2_NOTES entry only if someone traces the distinguishing factor
   (the missing `rootViewController` is the leading, untraced candidate).
   **Recording the distinction is the point:** M17 and M25 were each
   traced to a mechanism, which is why they belong there.
3. **The parity ledger** in `notes/MobileSoul.md` §6 — burn down PL-9,
   PL-10, PL-11; add this round's own line.
4. **KnownIssues — the forked-brains row.** It was **RESTORED
   2026-08-22** (the audit's finding 7: it had been deleted at 13e's
   closeout although that closeout records it as *"cautioned"*, leaving
   the debt with no owner outside a plan file that closes). It now
   carries the parity inventory's **EIGHT**-brain table, §4(c). The
   closeout keeps it current as hoists land — batch 4 already
   discharged the `RecoveryPath`/`TrayPath` half; `ThemeStore`,
   `applyTypedPath`, `CalloutPalette`/`CalloutMenu`, `BlockSelection`
   and `TakesReplacePlan` are still forked.
5. **The master plan** — pointer, the mobile project row, the closeout
   paragraph, and CLAUDE.md's **MOBILE PARITY LINE**. **Plus: name M12
   on 13u's row** (it is re-owned there; the row does not mention it,
   and its KnownIssues row is the belt, not the braces).
6. **The author handoff** (`notes/handoffs/…`) with her checklist at top.
7. **The merge to `main` at her word** (R9) — she has said she will ask
   for it at the round's end, and **13l is the first Mac phase to open
   against the merged tree**.
8. **M16 — settle it or own it.** *"The device round"* is not an owner.
   It is settled on her hardware before the round closes (the §24.9
   experiment: long-press-drag a two-paragraph selection within one
   note; observe whether the source blocks vanish and whether the moved
   text lands as blocks or as content), **or** it leaves this round with
   a named owner — a KnownIssues row, or 13u — exactly as M12 did.
10. **`notes/QUESTIONS.md` — THIS ROUND HAS NO ENTRIES IN IT** (§53's
    finding 9, verified: zero round-2 hits; the file ends *"(Next free
    number: #74.)"*). Every prior phase numbered its held items there —
    13j = #66–#73, 13e = #58/#63, 13g = #52 — because CLAUDE.md's
    PROVISIONAL rule sends them there *"for the checkpoint's ratify
    list"*. **Ten items are currently held for her in §6 above, in a
    file that closes at closeout.** Number them into QUESTIONS.md, or
    into a round end-bundle on the `mobile-parity-end-bundle.md`
    precedent — **either home works; NO home is the defect.**
11. **TWO STANDING RIDERS OUT OF THE PLAN FILE** (§53's finding 10):
    the **NAMED-coordinate-space rule for any future iOS drag** (parity
    inventory §4(a), the 13e jitter rider — still preventive, `grep -rn
    "DragGesture"` is zero) → **`notes/MobileSoul.md` §5 (platform
    truths)**, where the next editor session will meet it; and the
    **`CarryAllMerge` sibling-implementation note** (the Mac's
    `FannedDefaults.swift:46` and the phone's C5 composition are
    independent siblings, so a change to the carry-all rule silently
    touches one) → **the KnownIssues forked-brains row**. That row also
    gains **`MobileQuickNoteModel.charDelta`** (§53's finding 8 — a new
    mobile-local brain whose hoist trigger lives only in a code comment
    and this plan file), and its paired question — *should the Mac's
    `QuickEntryBar` adopt mint-as-you-type?* — joins §6 above.
12. **R16 → THE CANON.** Her standing principle, recorded verbatim at
   §31 and owed to the canon at closeout: *"if you have text selected, I
   lean towards the idea that you should be able to copy or delete it…
   basically obvious and intuitive operations like selecting a bunch of
   visible text and deleting should be allowed - the refusing because of
   different blocks is more annoying than it's worth."* It belongs
   **beside `notes/OverallModel.md` §7's block-size rules** (the
   cut-may-fall-between-any-two-words family — the same "the gesture
   should just work" doctrine). **The architect PROPOSES the wording;
   she ratifies.** It is never applied to canon autonomously — canon
   changes are the author-only list's first line. Three of the four
   refusal cases §31 enumerates are hers by this round's end; the fourth
   (a cross-block span touching a block with takes) is the one the
   wording must be honest about.

---
---

# SUCCESSOR HANDOFF — written 2026-08-23, FOR A MOBILE SESSION THAT RESUMES **AFTER 13l AND 13u**

> **⚠️ THE RESUME TRIGGER MOVED, same day this was written.** It first
> read *"after 13l"*. **Her ruling: `13l → 13u → mobile catch-up → 13p`**
> — *"I think I'd rather do the mac phases in order so that the shared
> brain is 100% solid and stable (up to this point, since making mobile
> is proven to uncover latent mac bugs), then return to mobile work on a
> steadier base."* **Read §5 with that in mind: the entangled half of
> 4.5c should be SETTLED by 13u before you touch it, and several items
> below may come back already built.** The full record is
*[removed for publication]*

**Her instructions that shaped this document** (2026-08-23):
*"let's do the merge, then I'll run 13l"* · *"I'll only resume variorum
mobile work after 13l is done - I think that's cleaner"* · *"remove
whatever is in there about spawning unlimited subagents because we're in
a new week and I want to go back to the one subagent at a time
approach"* · *"start a new Fable orchestrator up where you left off"*.

**Everything above the double rule still binds** — the rulings index
(§4), the machinery lessons (§5), the OPEN WITH HER list (§6) and the
closeout obligations (§7) are unchanged unless a row below supersedes
them. **The first handoff's §3 batch map remains THE ONLY SCHEDULE.**

---

## 0. PASTE-READY KICKOFF (a fresh session starts here)

> You are the architect/orchestrator for the remainder of **Mobile Round
> 2** of the Variorum iPhone app. Work in `~/dev/variorum-mobile` on
> branch `mobile`, under `/architect-phase`. **Phases 13l AND 13u have
> run since the last mobile session — verify what they changed before
> you plan anything.** 13u in particular is a cross-platform phase that
> was told to write mobile's deliverable into itself, so some of the work
> listed below may already be done, and the cross-block SEMANTICS are
> settled by it rather than by you.
>
> **READ, IN FULL, YOURSELF, IN THIS ORDER:** `CLAUDE.md` ·
> `notes/MobileSoul.md` · `.claude/skills/architect-phase/SKILL.md` ·
> **this handoff (both sections)** · `notes/plans/mobile-round-2.md`
> **in full** (long, and the reading rule is load-bearing — this round
> paid six times for items that lived only in prose) ·
> `notes/plans/mobile-round-2-batch-4.5-briefs.md` ·
> `notes/plans/mobile-round-2-consistency-audit.md`.
>
> **CAST: FABLE. ONE SUBAGENT AT A TIME** — her 2026-08-23 ruling,
> superseding R1's concurrency (§1 below). No parallel waves.
>
> **STATE IN ONE LINE:** all three of the round's BLOCKERs are fixed and
> **merged to `main`**; **three review/fix steps are OWED** (4.5b's cold
> review, 4.5d's fix round, 4.5a's ladder round 2) and **two sub-batches
> never ran at all** (4.5c and 4.5e), then batches 5–8 and two standalone
> review passes remain.
>
> **VERIFY, DO NOT TRUST** (§2). Several diagnoses in this round were
> traced by READING and never EXECUTED; twice the architect propagated a
> mechanism nobody had tested.
>
> **R28 still binds: BUILD → COLD REVIEW → FIX → CONTINUE as one unit.**
> With one agent at a time this is a SEQUENCE, not a fan-out, and the
> review is still inside the batch — you never decide afterwards whether
> to run it.

---

## 1. CAST AND CONCURRENCY — HER 2026-08-23 RULING, and what it changes

**R1 is amended.** Its original form (*"I have a lot of Opus credits…
There should be more cold reviews to account for that fact"* and *"it's
open season on opus credits"*) licensed an amplified, **parallel** ladder.
Her new instruction: **one subagent at a time**, and the cast is **Fable**.

| | before | **NOW** |
|---|---|---|
| model | all-Opus | **Fable** |
| concurrency | many agents in parallel; three-wide waves | **ONE agent at a time, strictly sequential** — CLAUDE.md's standing exposure cap, restored |
| review depth | a ladder per batch + two standalone passes | **UNCHANGED — this half of R1 survives and still binds** |

**What this simplifies, and it is a real gain:** the elaborate wave
structure (wave 1 / wave 2 / wave 3), the per-sub-batch simulator and
DerivedData assignments, and the whole parallel-fence recipe existed
**only** because several sessions shared one working tree. **With one
agent at a time they are unnecessary.** The file fences in the briefs
stay useful as **scope discipline** — they say what a session may touch —
but they are no longer collision avoidance, and the sub-batches simply
run in order.

**What this costs:** wall-clock. Plan for it; do not compensate by
skipping a review, which is the failure this round exists to correct.

**Consequences to carry:**
- **Ignore every "distinct simulator by UDID / distinct DerivedData /
  another session is live in this tree" instruction** in the 4.5 briefs.
  One simulator is fine. **Still re-arm the accessibility flag on it**
  (§2) — that hazard is per-simulator, not per-session.
- **§5.3's parallel-fence recipe is dormant**, not deleted. If she ever
  re-authorizes parallelism, it is still correct.
- **The whole-directory backup rule (§62) still binds absolutely.** It
  caused a live incident, and a directory restore is destructive whether
  or not anyone else is running.

---

## 2. STATE TO VERIFY — and 13l has run since this was written

**Branch `mobile`. `main` and `mobile` were merged at this cutover, at
her word** (*"let's do the merge"*) — the round's work through batch 4.5
is on `main`, and `main`'s two 13u-ruling commits are on `mobile`.

**Re-derive all of this yourself. 13l ran in between and its scope
overlaps this round's Mac surface directly:**

| check | how |
|---|---|
| Branch tips, and whether 13l advanced `main` | `git log --oneline -5 origin/main`; `git rev-list --count origin/main..HEAD` |
| **What 13l changed in files this round touched** | `git diff --stat <this cutover's tip>..origin/main -- App/Variorum/Shared/ App/Variorum/Variorum/` — **this is the important one; see §5** |
| Suite counts | run them; do not inherit. Last measured at this cutover: core **1350/141** · Mac **1569/272** · mobile **475/77** · both spines green |
| Hygiene | `git diff -- Sources/` **must stay empty**; zero `Sync/`; no build configuration; marker **7** |
| **The accessibility flag on your simulator** | `xcrun simctl spawn <UDID> defaults read com.apple.Accessibility ApplicationAccessibilityEnabled` — **if this is not `1`, sixteen real pins fail as phantoms reading `labels were []`** and every real door reads as absent. Arm it with `defaults write … -bool true` |

**Her phone still carries the 2026-08-21 23:49 build** — R30 (*"i'll wait
for my fresh build til these batches are all done"*). **The three
BLOCKERs are fixed in the tree but NOT on her phone**, so her working
caveats still stand until she takes a build: no multi-paragraph pastes
into the quick note, and the Trash's purge doors and the row-delete doors
silently do nothing on the installed build.

---

## 3. THE REMAINING WORK, IN THE ORDER TO RUN IT

**Sequential, one agent at a time. Each numbered item is a full R28 unit
unless it says otherwise.**

| # | Work | Why this position |
|---|---|---|
| **1** | **4.5b's COLD REVIEW** (owed; its dispatch died before reading anything) | **It is the only merged work that reached `Shared/` and the Mac without a review.** It is now on `main`. First, because everything else is phone-local |
| **2** | **4.5d's FIX ROUND** — §61's 2 MAJOR + 6 MINOR + 6 NIT | Its findings are recorded and adjudicated; the work is `MobileKeyboardBar.swift` + its pins. **Read §64 first** — the architect already restored the experimental revert that round left behind and rewrote its MAJOR 1 comment |
| **3** | **4.5a's LADDER ROUND 2** — a real re-review of §59's fixes | The fixes are substantial and one of them (§62's restore-a-turn-later) changed pin semantics. Round 2 is owed and was never run |
| **4** | **4.5c — the editor & the shared brain** (§4 below) | **The largest remaining risk in the round.** Read §5's coordination flag BEFORE briefing it |
| **5** | **4.5e — the shared lifecycle files + the Mac's quick-capture twins** (§4 below) | Includes a live data-loss defect on her Mac |
| **6** | **THE DEDICATED STABILITY PASS** — batch 4.5's **exit condition** | 4.5 is not done until it runs. It owns **M27**. Nothing that resembles it discharges it |
| **7** | **Batches 5 · 6 · 7 · 8** — the first handoff's §3 map, unchanged | Batch 5's brief must carry §53's two added deliverables (the shelf's missing keyboard avoidance under a dwelling field; the quick note's unmeasured mint cost) |
| **8** | **THE WHOLE-ROUND PASS** — **closeout obligation ZERO** | The round cannot close until it runs |
| **9** | **Closeout** — the first handoff's §7, all twelve obligations | Includes the parity ledger, R16 to canon (**she ratifies; never applied autonomously**), and 13l's manifest completed |

---

## 4. FULL SPECIFICS ON THE THREE SUB-BATCHES SHE ASKED ABOUT

### 4.5b — BUILT AND MERGED, **COLD REVIEW OWED** (the only unreviewed `Shared/`+Mac work)

**Brief:** `mobile-round-2-batch-4.5-briefs.md` §2. **Record:** §63.
**Commit:** `7fd2cd0`.

**What it shipped:** the round's third BLOCKER, closed at **five** hosts
(Delete Now · Empty Trash · the Library row's Delete Note · the Shelf
row's Delete Book · the A12 destructive-undo warning, whose Undo button
*cancelled* the undo). Three row doors moved to
`alert(_:isPresented:presenting:)`; **the A12 door got a SEAM fix**
(`askedWarning` — authorization outlives presentation) because that door
has **two** alert hosts, one of them in another fence.
**Plus:** the accessibility harness armed from inside the test bundle and
made to **fail loudly**; `MobileBlockMenuController.actInFlight`; the
`TrashPutBack` hoist into `Shared/RecoveryCopy.swift`; `DeletionRefusal`
as one home for deletion refusal copy; and **a Mac fix — `putBack` was
landing silently**, discarding the result while the view renders a
receipt (the only Mac count move this round, 1568 → 1569).

**What its review must look at hardest:**
1. **The `Shared/RecoveryCopy.swift` hoist** — does the Mac's suite ride
   unmodified apart from the one new pin, and did the hoist move an
   address rather than a behaviour? **Remember A1-16: an unmoved Mac
   count proves only "no COVERED behaviour changed".**
2. **The five confirm roads end to end, including Cancel.**
3. **The `tapAlertAction` driver simulates ONE step** (the binding
   write-back) because the real one is unreachable in process. **Is the
   simulation faithful, and is it named rather than hidden?** It measured
   four roads to find the one that reproduces — and in doing so it
   **falsified the settling experiment both a reviewer and the architect
   had specified**, which would have produced the round's sixth
   green-over-nothing pin.
4. **The candidate SIXTH affected site: `MobileLenses.swift:419`
   ("Rename Lens")** — a computed binding read back synchronously inside
   the action. Its probe suggests it is not in the affected class, **but
   it could not drive a genuine tap and reported it unproven both ways.**
   Settle it or record it unsettled.
5. **The loud diagnostic** — can it fire spuriously, or suppress a real
   failure?

**Known open from it, already routed:** the remaining decision-layer
hoist (**13l's manifest**), the live-editor-over-a-tombstone fix
(**4.5c**), two owed one-liners (**4.5c**), `commitNow`'s missing latch
(**batch 7**), and **§49's four NITs, which are unenumerated anywhere and
unrecoverable.**

### 4.5c — **NEVER RAN. The largest remaining risk in the round.**

**Brief:** `mobile-round-2-batch-4.5-briefs.md` §3. **Enumeration:** §52.
**Read §5 below BEFORE briefing it.**

**It owns:** `App/Variorum/Shared/EditorBrain/*` ·
`Features/Write/{MobileEditorViewModel, MobileStructural, MobileWriteView,
MobileMarkdownActs}.swift` ·
`Variorum/Features/Editor/{EditorSurfaceController, EditorViewModel}.swift`
· the editor test suites on both platforms.

**Its work, itemised:**

| item | what |
|---|---|
| **The fan fence is read from a FROZEN projection** | A block that gained a take during a dirty window can be **merged away by a keystroke**, against the #11a ruling. `BlockRangeIndex.wholeBlockDeletion`'s own doc states the law forty lines away; the sibling seam road obeys it. **Fix the fence's SOURCE, not its routing** — her `planVisibleTakeEdit` fence must keep refusing |
| **The O(N²) twin SURVIVES in `planVisibleTakeEdit`** | One `else if` after the one that was fixed, **on a road that runs**. The fixed twin measured **23.8 s → 0.003 s at 20,000 entries**. Fix the same way (an accumulation pass), pin the equivalence against the accessor, **MEASURE**, and **sweep the class to completion** — every caller of `range(ofEntryAt:)` inside a loop, both platforms, each verdicted FIXED-with-a-pin or provably SAFE |
| **The Mac gets the gap fence's REFUSAL but not its FACE** | §44's MAJOR. Three parts, all pinnable: the Mac's fence arm; `CrossBlockRefusal.diagnose` step 3 treating a zero-length entry as touched; the Mac's `.blocksNotAdjacent` sentence. **A defect this round CREATED Mac-side** |
| **The Mac has NO identity-projection audit at all** | §53 f1. HOIST `auditIdentityProjection` + the separator check into `Shared/EditorBrain/`, wire the Mac, **carry the empty-entry hole's fix**, and pin it **red-on-old ON THE MAC** by reproducing §20's traced corruption there |
| **An EMPTY block inside a span** | Yields a plan that can never execute, refusing an ordinary gesture with a sentence naming a cause that isn't there |
| **The phone's unwired A7/#34 seam carves** | Backspace-to-join still refuses — a fifth refusal case §31's four-case table omits |
| **B45-2 — the `displaySlot`/`slots[i]` coupling** | Out-of-range-safe only by caller accident. **Batch 7's PR8 reorder-takes walks straight into it.** Make the safety structural |
| **B45-3 — the crash trace's six unowned items** | **E1** (build the instrumentation and leave it RUNNABLE for a device session that will not have your context — **M1's root is still "high confidence, NOT PROVEN"**) · **E2** · **§8 path 8** (UIKit undo replaying a coalesced edit — zero mentions anywhere in the round) · **§8 path 11** (the `supportsTextReplacement: false` fence — verify it stands and says why) · **§9's `MarkdownActs` Mac residual** · **M1's SUSPECTED status itself**. **Each leaves the session FIXED or with a named owner** |
| **A1-5 — `CrossBlockRefusal` never hoisted** | Merge-then-edit landed and the refusal copy carrying **its own unexecuted instruction** was never re-narrowed, so the phone's cross-block refusal names **none** of its four real causes |
| routed in from 4.5b | the **live editor over a tombstone** (the filed remedy was WRONG — the stale editor is in the *other* tab stack, so the fix is at the liveness seam), the **`MobileLenses.swift:419`** candidate, and two one-liners (`deleteNoteRefusal:958` → `DeletionRefusal.words(error)`; the A1-15 comment at `MobileCrossBlockEditTests.swift:598`) |

**M-B binds every line of it:** core + Mac + both spines + mobile, and
**every Mac-side change into 13l's manifest** — 13l will have closed, so
**re-read what it did there first** and record against the current file.

### 4.5e — **NEVER RAN.** Includes a live data-loss defect on her Mac

**Brief:** `mobile-round-2-batch-4.5-briefs.md` §4c.

**It owns:** `App/Variorum/Shared/{AppBootstrap, AppSession}.swift` · the
`.opening` arm in **both** app roots · **and the Mac's quick-capture
twins** `Variorum/Features/Shelf/QuickEntryBar.swift` +
`Features/QuickNote/QuickNoteView.swift`.

| item | what |
|---|---|
| **B45-1 — a P2 violation on every launch** | `AppBootstrap.init` opens the store and runs the migration set **synchronously on the main thread before first paint**. **MEASURED:** 54.0 / 23.4 ms first launch, 5.0 ms reopen, **3.6 ms at 100k — flat in corpus size**, O(migrations) not O(corpus). **The shape is already ruled** (§58/§62): an `.opening` state, the file work detached, hopping back to MainActor for `install` + the state write (**preserving the once-per-process flag**), `retry()` re-entering, a quiet launch view in both roots. **The not-ready window cannot open by construction** — `AppSession` exists only inside `.ready`. **Re-measure after** |
| **🔴 The Mac's `QuickEntryBar` DESTROYS HER TEXT on a refusal** | `submit()` does `entryText = ""` **before** the mint, and its catch is a raw `\(error)` dump — **Q2 and Q7 in one method, in the bar she praised by name and uses daily.** The phone's just-shipped fix is the reference shape; route the copy through `OpsRefusalCopy.message(for:)`. `QuickNotePad.take()` clears before filing too (deliberate there, and its copy does speak) |
| **A1-21 — `postAutosaves` has no removal path** | The quick note adds one coordinator **per capture**, and `flushEveryOpenPost()` iterates all of them on every filing and every background flush. Shape proposed: `releaseAutosave(forPost:)` called from the box's `reset()` — **with the trap already traced**: the Mac registers a `quitFinalize` at *mint* time, so release-then-remint registers a second (deduped by `closeAutoCommit` — noise, not corruption, but it must be deliberate) |
| **A1-15 + §61's third line** | Three comments in `AppSession.swift` state reasons that are FALSE while the behaviour is fine — `:89` ("no undo UI yet" — M20 shipped it), `:240-245` (inverted — the quick note DOES cache a coordinator), `:206-208` ("open posts are a handful by construction", now false for A1-21's reason) |

---

## 5. ⚠️ THE COORDINATION FLAG THAT ARRIVED WITH THE MERGE — READ BEFORE BRIEFING 4.5c

**`main` carried in her 13u item 5 ruling (2026-08-21), and it names this
round explicitly.** The master plan's 13u row is the binding text; the
parts that change mobile work:

1. **CROSS-BLOCK EDITS STOP REFUSING.** Her words: *"obvious and
   intuitive operations like selecting a bunch of visible text and
   deleting should be allowed - the refusing because of different blocks
   is more annoying than it's worth."* This is R16 promoted from a
   principle to a scheduled design.
2. **The edge-join is RULED:** remainders **MERGE** when the cut ends sit
   **mid-paragraph**; they do **NOT** merge at a paragraph break.
3. **The fanned case is RULED** — a fanned **middle** block deletes whole
   to the tray; a fanned **edge** block's edit touches the chosen take
   only. *This round fenced the fanned case off as "hers"; she has now
   ruled it.*
4. **HER AUTO-COMMIT IS ADOPTED as the SEVENTH quiet occasion** — a quiet
   commit of the affected takes right before a multi-block edit.
   **⚠️ THIS ROUND DESIGNED THAT AS M24 AND SHE DECLINED IT AT R18**
   (*"okay I agree we don't need it"*). **The decline is superseded, and
   the reason changed rather than the fact:** R18 declined it standalone
   because Trash and lineage already covered the loss cases; 13u adopts
   it *inside the cross-block gesture*, where it is **"doubly right…
   because the gesture mixes the text-undo and structural-undo worlds."*
   **Do not treat §32/§33's decline as current.**
5. **HER OWN COORDINATION FLAG, verbatim from the row:** *"mobile round
   2's M1 crash (`BlockRangeIndex.applyBlockEdit` on multi-line delete)
   is THIS EXACT SEAM — the crash fix is stability, the semantics are
   ruled HERE, once, for both platforms; the mobile session should know
   the direction before hardening any refusal."*

**WHAT THIS MEANS FOR 4.5c, concretely.** Its items split in two:

- **UNAFFECTED — build them:** the O(N²) twin · the Mac identity-audit
  hoist · the gap fence's Mac face · B45-2 · B45-3 · the live editor over
  a tombstone. These are defects, not semantics.
- **DOWNSTREAM OF HER RULING — do NOT harden these into place:** the
  empty-block-in-a-span refusal · the unwired seam carves · `CrossBlockRefusal`'s
  hoist and its refusal wording · the fan fence's shape. **Fixing the fan
  fence's SOURCE (so it cannot be read from a stale projection) is still
  right** — that is a correctness fix. **Re-writing what the refusals SAY,
  or widening/narrowing which cases refuse, is 13u's.**

**Bring this to her at 4.5c's kickoff** and let her rule the boundary.
The safe default if she is unavailable: **fix the mechanisms, leave the
semantics, and record what you left.**

---

## 5b. M1's ROOT — the question she asked, and how the answer splits

She asked (2026-08-23): *"is M1 the mac issue? because if so, a mac
session should settle that root."* **The precise answer, recorded because
it governs who does what:**

**M1 is NEITHER platform's — it is the SHARED editor brain.**
`BlockRangeIndex` lives in `App/Variorum/Shared/EditorBrain/`. The crash
**fired on her iPhone**; the Mac was proven **latent-not-prevented**, and
that is not a guess — the Mac twin pins went **red on the pre-fix tree**
(§17). Both platforms were fixed in batch 1.

**The remaining ROOT question — where the stale verdict came from —
splits by platform, and only one half is Mac work:**

| half | who can settle it |
|---|---|
| **The iOS half — experiment E1** | **Her iPhone, iOS 26.6.** It is an input-path question about how UIKit coalesces a delete-plus-reinsert (`_deleteBackwardAndNotify:reinsertText:…`), and the newest simulator here is 26.2, so a non-reproduction is a **runtime gap, never a clean bill**. **A Mac session cannot settle it.** The instrumentation is 4.5c's to build and leave runnable |
| **The Mac half — the `MarkdownActs` arm-then-hand-off sites** | **A Mac session, and it is ROUTED TO 13u** (master plan, 13u item 7). The crash trace names it *"the Mac's real residual"*: a verdict armed and then handed off without being consumed. It lives in the same seam 13u item 5 rewrites |

**So her instinct was right about half of it**, and that half now has a
Mac home. **M1's status stays "high confidence, NOT PROVEN" until E1 runs
on her hardware** — and E1 remains the single highest-value item in the
device queue.

---

## 6. WHAT 13l AND 13u MAY HAVE CHANGED UNDER YOU

13l's scope overlaps this round's Mac surface directly. **Before
briefing 4.5b's review or 4.5c, diff what it did** to
`Variorum/Features/Library/RecoveryView.swift`, `Features/Tray/TrayPanel.swift`,
`Shared/RecoveryCopy.swift` and the editor files.

**And 13u is the bigger one.** It was told to write mobile's deliverable
into itself for four items — the space-eater (both platforms), the
derived display-name snippet (one brain, mobile's lists included), the
cross-block semantics (ruled once for both), and dark mode (the phone's
shipped look is the reference). **Check what landed before you schedule
anything: you may owe faces rather than brains, or nothing at all.** And
**§5's entangled half of 4.5c is 13u's to have settled** — if it did,
your job there is composing to its rule, not writing refusal copy.

**Specifically expect that 13l may have closed some of §65's four
known-open Mac defects**, because they were written into its manifest for
exactly that reason. **Check each before scheduling it in 4.5c** —
building a fix for something 13l already fixed is the waste this flag
exists to prevent, and building it *differently* is worse.

Also: 13l owned **the Mac's fifth dead confirm site** (the architect
declined to take it and offered it to her). §56 gave 13l the derived
mechanism and the one-line fix. **Verify it landed**; if it did not, it
is still open and belongs to whoever she says.

---

## 6b. ⚠️ THE GAP NOBODY OWNED — who cold-reviews mobile's Mac changes made AFTER 13l

**Found by the architect's own handoff sweep, 2026-08-23, and it is the
clearest dropped-ball candidate in the whole boundary.**

Her R20 ruling bought **one** Fable cold review of this round's Mac-side
work, and it runs as **13l's first act**. Its manifest is complete
**through batch 4.5**. But:

- **4.5c has not run, and it is heavily Mac-side** — it changes
  `Variorum/Features/Editor/EditorSurfaceController.swift` and
  `EditorViewModel.swift`, and it **hoists into
  `Shared/EditorBrain/`** (the identity audit, `CrossBlockRefusal`).
- **4.5e has not run**, and it changes `Shared/AppBootstrap.swift`,
  `Shared/AppSession.swift` **and two Mac files** (`QuickEntryBar.swift`,
  `QuickNoteView.swift` — one of which destroys her text on a refusal).
- **Batches 5–8** may add more.

**All of that lands AFTER 13l has closed.** So the review she asked for
covers the Mac work done up to today and **nothing anybody does
afterwards** — while the largest, most Mac-visible mobile work is still
ahead. **No document named an owner for it.**

**THE ARCHITECT'S PROPOSAL, for her to rule** (recorded rather than
assumed, because R20 was hers and its extension should be too):

> **Mobile's own closeout hands a SECOND manifest forward to the next Mac
> phase that opens after mobile resumes — which, on her current order, is
> 13p.** Same shape as 13l's: every Mac-side file, every hoist, what the
> Mac's callers now delegate to, and the final counts. **13p is a good
> home for it on merit, not just by position:** its own subject
> (on-device encryption) is both-platform, so it already has to look at
> the shared seam with both platforms in view.

**Until she rules, this is written into closeout obligation 13 below**, so
the round cannot close without either doing it or her saying it is not
needed. **The alternative she may prefer: fold the second review into
13u**, which runs sooner and touches the same editor seam — but 13u runs
*before* 4.5c, so it would review work that does not exist yet. **That is
why 13p is the proposal.**

---

## 7. THE RULES THAT BIND, CONSOLIDATED

Everything in the first handoff's §5 still holds. Added this seat:

- **A rule that names a SHAPE will be obeyed into the same bug.** Name
  the **property**. (*Never a computed `Binding(get:set:)`* — four doors
  obeyed it and were dead; two sites using that syntax are immune.)
- **A mechanism that explains the symptom is not one that was tested.**
  This round attributed one symptom to two wrong causes and repeated a
  third for six sessions. **Twice the architect was the culprit.**
  Isolate before you propagate; never put an untested mechanism into a
  binding brief.
- **A SPECULATIVE finding investigated properly beats a confirmed one.**
  Build the pin first as the confirm; **then ask why it says what it
  says.** The "green" caret pin found an unsuspected data-loss path.
- **Check the tree after an agent FAILS, not only after it succeeds.** A
  dead session left a red-on-old revert in the harness and **the suite
  stayed green over it** (§64).
- **Never back up or restore a whole DIRECTORY** (§62).
- **Land every review's findings IN FULL.** Two summaries in this round
  say *"and N NITs"* without listing them, and those findings are
  **unrecoverable** (§62, §63).
- **A pin that indexes a collection right after asserting its size takes
  the whole runner down under its own revert.** Use `#require(x.first)`.

---

## 8. OPEN WITH HER — the four added this seat (the ten in §6 still stand)

11. **The 320 pt Display-Zoom strip renders her acts at 23 pt**, below
    the ~31 she pre-ruled tappable. Architect ruled *accept 23*; **never
    seen by a human — device-queue row D9**, and Display Zoom restarts
    the phone so it must ride an install window.
12. **Q1's residual cost:** fixing a typo in the FIRST paragraph of a
    pasted multi-paragraph capture now holds at the boundary and says so.
    A consequence of her own A5-2 one-block ruling, never seen as a lived
    consequence.
13. **The caret collapses to the end after a boundary hold** (confirmed,
    safe, but unasked). Putting it back needs a `UIViewRepresentable`
    text view — **a surface decision**, and the stray-newline-on-a-refused-⏎
    item wants the same one.
14. **The device queue is nine rows now** (§4b of the briefs), and **E1
    is still the only thing that would settle M1's root cause.** When she
    offers her phone, run the queue in that window — not just the install.
15. **🔴 HER PHONE IS RUNNING THREE FIXED BUGS, and R30 has quietly gone
    stale.** R30 (*"i'll wait for my fresh build til these batches are
    all done"*) was ruled when "these batches" meant days. **It now means
    two Mac phases plus the rest of the mobile round.** Meanwhile **all
    three BLOCKERs are FIXED and merged**, so her installed build is the
    only place they still exist — and she is **hand-avoiding them**
    (no multi-paragraph pastes into the quick note; the Trash's purge
    doors and both row-delete doors silently do nothing). **This is worth
    re-offering rather than waiting on**, and nobody currently owns
    re-offering it. *(A build also unblocks eight of the nine device-queue
    rows.)*
