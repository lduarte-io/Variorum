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

# SECOND ORCHESTRATOR HANDOFF — 2026-08-23

**Written at the author's instruction after the second seat reached
~571k context.** *"given that you're already at 571k tokens though, it's
time for a handoff to a new orchestrator… you can probably just add to
the one that I gave you, since a lot of the work in it is not yet
complete."* Everything above this line still binds unless a row below
supersedes it; this section updates state, not rules.

**Her cast instruction for the successor: a FABLE orchestrator**
(*"start a new Fable orchestrator up where you left off"*) — a change
from R1's all-Opus, made because her Opus week ran out and reset
differently. **R1's SUBSTANCE survives and is what matters: reviews get
the surplus.** The standing Sync/ rider is moot here (this round has
touched zero `Sources/` lines).

## S1. WHAT THE SECOND SEAT DID (all committed and pushed)

**Her successor-first-acts file, executed in order:**
- **ACT 1** — a fresh cold read over the round's whole shipped diff → **§56**. It settled the Mac dead-door diagnosis §46 said had to be re-derived, found the confirm defect is FIVE sites not four, corrected the "Mac suite unmoved ⇒ nothing changed" claim, and caught that **the mobile suite is not green on a clean simulator** (an unrecorded per-simulator accessibility default) — which would have opened three of four sub-batches with sixteen phantom failures.
- **ACT 2** — the never-became-work sweep → **§53**. Twelve verified orphans, all routed. Its structural finding is the one to carry: **three of them were obligations a batch discharged on ONE side and recorded honestly on the other.**
- **ACT 3** — batch 4.5 built as four file-fenced sub-batches. **All three BLOCKERs are fixed** (§62, §63).

**Also landed:** §54 (the Mac suite is intermittently red at a latency budget — pre-existing, measured on both trees, KnownIssues row owned by 12) · §55 (the three BLOCKERs verified at the code by the architect before briefing) · §57–§63 (per-sub-batch records) · **13l's manifest fed four times, in the commits that made each change** · two KnownIssues rows · the parity-ledger and closeout obligations updated.

## S2. STATE AT THIS CUTOVER — VERIFY, DO NOT TRUST

**Branch `mobile`, tip `407e978` + the architect's §64 restore commit. Pushed. Never push `main`.**

| | |
|---|---|
| **Committed** | batches 1 · 1b · 2 · 3 · 3b · 4 · R12 · R22/M26, plus every record above |
| **UNCOMMITTED, in the working tree (26 files)** | **4.5a** (build + fix round) · **4.5b** (build) · **4.5d** (build) — **all green together at `475/77`** |
| **Never started** | **4.5c** (wave 2) · **4.5e** (wave 3) · batches 5–8 · both standalone review passes |

**Suites, last measured on this tree:** core **1350/141** · Mac **1569/272** · Mac spine **8/8 suites** · mobile **475/77** · mobile spine **7/7 suites**. **Hygiene held all round: `git diff 46ffa0c..HEAD -- Sources/` is EMPTY, zero `Sync/` lines, no build configuration, zero schema. Mirror at marker 7.**

**⚠️ Re-arm the accessibility flag on any simulator you use** (§56 / §9) or sixteen real pins fail as phantoms reading `labels were []`:
`xcrun simctl spawn <UDID> defaults write com.apple.Accessibility ApplicationAccessibilityEnabled -bool true`. Five simulators were armed on 2026-08-22; a fresh or reset one is not.

## S3. THE THREE DEAD AGENTS — what was lost, and one thing they left behind

All three died on the same API weekly limit, **and none of them had produced anything recoverable**:

| agent | how far it got |
|---|---|
| 4.5b's cold review | *"I'll start by building my own picture…"* — **nothing** |
| 4.5a's ladder round 2 | *"Let me start a build/test run…"* — **nothing** |
| 4.5d's fix round | established baseline (475/77) and began MAJOR 1's trace — **nothing written but one revert** |

**⚠️ AND THE LAST ONE LEFT A REVERT IN THE TREE.** It had restored `makeKeyAndVisible()` in **two** places in `MobileKeyboardBarGeometryTests.swift` — marked `// EXPERIMENT B` — as a red-on-old trace, and died before undoing it. **The product fix was intact; only the harness was mid-experiment.** The architect found it by checking rather than assuming, restored both sites to `window.isHidden = false`, **and wrote the falsified-mechanism correction into that comment** (the fix round's own MAJOR 1, which it never reached). **Recorded as §64.**

> **THE LESSON, and it is new:** *an agent that dies mid-revert leaves the tree in a state no one is watching.* A red-on-old revert is a deliberate temporary corruption; if the session performing it dies, nothing announces it. **Whoever dispatches a fix round should check the tree after any agent failure, not only after a success.**

**Do NOT relaunch these three by resuming.** Dispatch fresh sessions from the briefs — everything they needed is in the repo (§59 / §61 / §2 of the briefs file), which is the point of repo-first.

## S4. THE MERGE QUESTION — her direct question, answered with numbers

> *"I know that this all hasn't been merged into main yet — but what parts touch shared code? … What's the lift on getting what's in flight merged into main? and are there elements that are unverified / untested that touch the shared core?"*

### (a) `Sources/` — the core package — is UNTOUCHED. Zero lines, all round, committed and in flight.
This is the strongest single fact for a merge decision: **nothing in Mobile Round 2 has changed `VariorumCore`.** No schema, no `Sync/`, no operations, no queries. The mirror stays at marker 7 by construction.

### (b) COMMITTED `Shared/` + Mac — thirteen files, all reviewed, **but with KNOWN-OPEN findings against them**

```
Shared/EditorBrain/{BlockRangeIndex, CrossBlockEditPlanner, EditorEditRouting}.swift
Shared/{RecoveryCopy, StructuralUndoCopy}.swift
Variorum/Features/Editor/{EditorSurfaceController, EditorViewModel}.swift
Variorum/Features/Library/RecoveryView.swift · Features/Tray/TrayPanel.swift
Variorum/Registry/ShellActions.swift
VariorumTests/{BlockRangeIndexTests, EditRoutingCrashTests, EditRoutingTests}.swift
```

**These are 13l's manifest, and the manifest is current.** What the manifest ALSO needs to say — and §65 now adds it — is that **four Mac-visible defects in this code are recorded, accepted, and NOT YET FIXED**, because the sub-batch that owns them (4.5c) never ran:

1. **The fan fence is read from a deliberately FROZEN projection** — a block with takes can be merged away mid-typing, against the #11a ruling (§45, batch 3).
2. **The O(N²) twin SURVIVES in `planVisibleTakeEdit`** — a P1 violation on a road that runs, on the Mac (§45; §38's "the Mac inherits the fix" is overstated in three places).
3. **The Mac gets the gap fence's REFUSAL but not its FACE** — she meets a raw `blocksNotAdjacent(first:second:)` enum dump (§44 MAJOR 1).
4. **The Mac has NO identity-projection audit at all** — the DEBUG oracle for the corruption class both other oracles are blind to exists only on the phone, though both platforms share the brain and §20 reproduced the corruption Mac-side (§53 finding 1).

### (c) IN FLIGHT `Shared/` + Mac — exactly THREE files, and they are 4.5b's

```
 M App/Variorum/Shared/RecoveryCopy.swift              (the TrashPutBack hoist)
 M App/Variorum/Variorum/Features/Library/RecoveryView.swift   (adopts it; Put back now sets a receipt)
 M App/Variorum/VariorumTests/TrashSurfaceTests.swift  (+1 pin — the only Mac count move)
```

**Everything else in flight — 14 files — is iPhone-only.**

**So the honest answer to "unverified/untested touching the shared core":** **one file, `Shared/RecoveryCopy.swift`, plus its two Mac consumers — and "unverified" means UNREVIEWED, not untested.** It carries red-on-old pins, both platforms' suites are green, and the Mac gained a pin for it (1568 → 1569). **The risk is real but small and bounded**; a cold review is owed and is a short job.

### (d) THE LIFT — small mechanically, and here it is as a checklist

1. Restore any dead agent's experiment (**done — §64**) and re-run the mobile suite green.
2. `git add` the 26 in-flight files and commit as the 4.5 landing.
3. Run all five suites on the committed tree; record the counts.
4. `mobile` → `main` and `main` → `mobile`, **resolving `notes/` conflicts as the UNION of both sides** (the c928a33 precedent).
5. Push both.

**Perhaps an hour.** The lift is not the obstacle; **the judgement is.**

## S5. WHAT WAVE 2 WAS — 4.5c, and why it is the largest remaining risk

She asked directly: *"I'm not sure what wave 2 was for the editor brain."*

**4.5c is "the editor & the shared brain" — the sub-batch that owns `Shared/EditorBrain/*`, both platforms' `storageDidEdit` consumers, and the Mac's editor files.** It was put in a wave of its own **on a mechanism, not a preference**: every mobile and Mac target compiles against `Shared/EditorBrain/`, so a session mid-edit there breaks every other session's build. **It never ran.** Its brief is `mobile-round-2-batch-4.5-briefs.md` §3, and it carries:

- the four Mac-visible defects in S4(b) above (fan fence · the O(N²) twin · the gap fence's missing face · the missing identity audit — **a HOIST, with a Mac-side red-on-old**);
- an **empty block inside a span** yielding a plan that can never execute;
- the phone's **unwired A7/#34 seam carves** (backspace-to-join still refuses);
- **B45-2** — the `displaySlot`/`slots[i]` coupling that **batch 7's PR8 reorder-takes walks straight into**;
- **B45-3** — the crash trace's six unowned items, including **building E1's instrumentation** so a device session can run it (**M1's root cause is still recorded "high confidence, NOT PROVEN"**);
- **A1-5** — `CrossBlockRefusal` never hoisted, so the phone's cross-block refusal names **none** of its four real causes;
- routed in from 4.5b: **the live editor over a tombstone** (the filed remedy was wrong — the stale editor is in the *other* tab stack, so the real fix is at the liveness seam), the **candidate sixth confirm site** at `MobileLenses.swift:419`, and two owed one-liners.

## S6. THE ARCHITECT'S RECOMMENDATION ON SEQUENCING — hers to overrule

She wants to run 13l and start a fresh mobile orchestrator. **Both can happen soon; the one hard constraint is that TWO SESSIONS MUST NOT EDIT MAC EDITOR CODE CONCURRENTLY** — that is this round's most expensive lesson, at phase scale rather than file scale.

**Recommended, and it gets her to 13l fastest without racing:**

1. **Commit the in-flight 4.5 work and merge to `main` now.** It is green, all three BLOCKERs are fixed, and `Sources/` is untouched. 13l unblocks.
2. **Run 13l.** Its Fable cold review reads the Mac changes **with S4(b)'s four known-open defects written into the manifest** (§65), so it spends its budget on what nobody has looked at rather than re-deriving what is already recorded. Its own first act — the dead Delete Now door — now has a **derived mechanism and a one-line fix** waiting for it (§56).
3. **In parallel, the fresh mobile orchestrator does PHONE-ONLY work:** 4.5a's ladder round 2 (read-only), 4.5d's fix round (`MobileKeyboardBar` + its tests — iPhone-only), and 4.5b's cold review (read-only). **None of these writes a Mac or `Shared/` line**, so they cannot race 13l.
4. **AFTER 13l closes:** 4.5c (wave 2), 4.5e (wave 3), and 4.5b's fix round — all of which touch `Shared/` or Mac code.

**The one thing to weigh honestly before step 1:** merging now puts **4.5b's unreviewed `Shared/` hoist** and **4.5d's fourteen open findings** into `main`. Against that: her Mac app is her daily driver and 4.5b's Mac change is a small improvement (Put back was landing silently and now says where it went), R30 keeps the phone build frozen anyway, and **the alternative — holding the merge until 4.5c and 4.5e finish — is the longer wait she is trying to avoid.**

**If she would rather not merge unreviewed `Shared/` code:** the cheapest variant is to have the fresh orchestrator run **4.5b's cold review FIRST, alone** (a few hours, read-only) and merge after. That buys back the only real exposure in S4(c).

## S7. MACHINERY LESSONS ADDED THIS SEAT

- **A rule that names a SHAPE will be obeyed into the same bug.** *Never a computed `Binding(get:set:)`* named a syntax; four doors obeyed it to the letter and were dead anyway, while two sites using that exact syntax were immune. Name the **property**: *a binding setter must never clear state an action's continuation will read back.*
- **A mechanism that explains the symptom is not a mechanism that was tested.** This round attributed one symptom to two different wrong causes, and repeated a third for six sessions. **Twice the guilty party was the architect** (§61, §62). Isolate before you propagate — and *never* propagate a mechanism into a binding preamble before someone has checked it.
- **A SPECULATIVE finding investigated properly is worth more than a confirmed one.** MAJOR 5 came back "green" — and asking *why* it was green found a data-loss path nobody suspected (§62).
- **Never back up or restore a WHOLE DIRECTORY in a shared tree.** It is a fence violation wearing another name, it reverts other sessions' files silently, and nothing announces it (§62).
- **Check the tree after an agent FAILS, not only after it succeeds** (§64).
- **A compressed review summary costs real work later.** Twice this round a record said *"and N NITs"* without listing them, and the findings are unrecoverable (§62, §63). **Land every review's findings in full.**
- **The fence caught the architect's own brief errors twice** — `AppSession.swift` (§58) and `VariorumMobileApp.swift` (§62), both double-owned. Per-file fences are worth their overhead.

## S8. OPEN WITH HER — added this seat (the ten above still stand)

11. **The 320 pt Display-Zoom strip renders her acts at 23 pt** — below the ~31 she pre-ruled tappable. The architect ruled *accept 23* (whole acts beat two acts off-screen; the alternatives are an act-count change, which is hers, or scrolling, which contradicts FIX-5). **Never seen by a human — device-queue row D9.**
12. **Q1's residual cost:** fixing a typo in the FIRST paragraph of a pasted multi-paragraph capture now holds at the boundary and says so — that paragraph needs the editor, one tap away. A consequence of her own A5-2 one-block ruling, but she has never seen it as a lived consequence.
13. **The caret collapses to the end after a boundary hold** (§62, confirmed) — safe, but it moves unasked, and putting it back needs a `UIViewRepresentable` text view. **A surface decision.** The stray-newline-on-a-refused-⏎ item wants the same decision.
14. **The Mac's fifth dead confirm site** — 13l owns it by her ruling; the architect declined to take it and offered it. **Still hers.**
