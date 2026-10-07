# Mobile Round 2 — ORCHESTRATOR HANDOFF

> # ⚠️ THIS FILE HAS TWO KICKOFFS. THE ONE BELOW IS HISTORY.
>
> **A fresh mobile session starts at the SECOND half of this file** —
> **`# SUCCESSOR HANDOFF`**, and its **§0** is the paste-ready kickoff.
> Jump there.
>
> **§0 of THIS first half is superseded** (it was written 2026-08-22 for
> a seat that took over mid-round). It is kept because §3's batch map,
> §4's rulings index, §5's machinery lessons, §6's open-with-her list and
> §7's closeout obligations are all still live and are cited throughout
> — **but its own kickoff paragraph describes a state that no longer
> exists**: it says batch 4.5 is unbuilt (it is built and merged) and it
> tells the session to feed 13l's manifest as it goes (13l will have
> closed; see obligation 1's amendment).
>
> **Where things actually stand:** all three BLOCKERs fixed and merged ·
> three review/fix steps owed · 4.5c and 4.5e never ran and have SHRUNK
> (their Mac and `Shared/` work moved to 13l and 13u at her ruling) ·
> then batches 5–8, two standing review passes, and closeout.
>
> **⚠️ RESUMPTION RE-SEQUENCED (2026-08-25/26, the launch-strategy
> sitting — her confirmed order):** mobile now resumes **AFTER the Mac
> v1 HARD LAUNCH and 13n**, not after 13u (the old 13l → 13u → mobile →
> 13p order is superseded; the master plan's RUNNING ORDER governs).
> What that changes for the resuming session: **(1)** 13u SPLIT into
> **13u1** (the editor seam — items 5/7/8/9/12) and **13u2** (feel &
> faces) — the §2b HANDBACK CHECKLIST now verifies BOTH halves' items;
> **(2)** 13p ran BEFORE mobile and its **Batch 4 shipped the phone's
> encryption faces inside that phase** (Face ID at open, the locked
> lobby, settings/presets, locked-note gates) — verify landed, don't
> rebuild; **(3)** more Mac phases (13i wings/Owned/Book-Panel, 13o
> search, 13y, 13x) closed before resumption, so the PARITY LEDGER
> (`notes/MobileSoul.md`) carries accrued rows the old batch map does
> not know about — read the ledger before planning batches; **(4)** the
> quick-capture ruling mobile batch 4.6 composes to is 13u1's item 9
> now (not "13u's").

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

## 0. ~~PASTE-READY KICKOFF~~ — **SUPERSEDED 2026-08-23; the live one is §0 of the SUCCESSOR HANDOFF, in the second half of this file.** Kept as the record of what the 2026-08-22 seat was told.

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
| Mac | 1568/272 → **1569/272 (SUPERSEDED 2026-08-23; see the successor handoff's §2)** | ~~exact and unmodified since batch 1's fixes — this is the hoist proof; if it moves, something changed Mac behaviour~~ **The count HAS moved, for a known good reason: batch 4.5b's single new pin in `TrashSurfaceTests.swift`. Do NOT raise a false alarm on it.** And the round has since established that an unmoved count proves only *"no COVERED behaviour changed"* — it is weaker evidence than this line claimed |
| Mac spine | 63/8 | exact |
| mobile | 449/75 → **475/77 (SUPERSEDED 2026-08-23)** | grew every batch; 449/75 was batch 4's landing (§46), 475/77 is post-4.5 |
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

> ### ⚠️ STALE CELLS BELOW — 2026-08-30. **`§7`'s TABLE IS AUTHORITATIVE.**
>
> This map was written 2026-08-22 and its per-row cells were NOT all
> refreshed as work landed. **Read `mobile-round-2-handoff-2026-08-30.md`
> §7 first** — it carries every scheduled item of this round in exactly
> one row, done or remaining, with a column saying whether 13u blocks it.
>
> **Landed since this map was written, whatever its cells say below:**
> **4.5b**'s cold review (discharged by 13l's Fable review) · **4.5d**'s
> fix round (its finding: 13 of 14 already fixed uncommitted) ·
> **PL-10(b)** the duplicate-book-name guard · **batch 5** built,
> refined to her two live rulings, and cold-reviewed · **batch 6a** the
> Block History twin, built and cold-reviewed · the **architecture
> review** · the **archive/trash design session** (she ruled **Two
> rooms**) · the **five-MAJOR fix round** · the **`main` iOS build
> break**, found and fixed.
>
> **Suites 513/86 → 582/93.** Anything below that contradicts this
> banner is stale, not a second opinion.


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
| ↳ **4.5d** the keyboard bar's geometry | ✅ built → §60 | ✅ reviewed → §61 · ✅ **FIX ROUND DONE 2026-08-30** (`mobile-batch-4.5d-record.md`) — 13 of 14 findings were ALREADY FIXED uncommitted, so nothing was re-fixed; the one real act was proving a never-run red pin. ~~FIX ROUND OWED~~ (dispatched, died on the API limit after establishing baseline; **it left an experimental revert in the tree, which the architect found and restored — see §64**) |
| ↳ **4.5c** the editor & the shared brain — **THE LARGEST REMAINING RISK IN THE ROUND** | ❌ **NEVER RAN.** WAVE 2, alone (every target compiles against `Shared/EditorBrain/`) | ❌ owed |
| ↳ **4.5e** the shared lifecycle files + the Mac's quick-capture twins | ❌ **NEVER RAN.** WAVE 3, alone | ❌ owed |
| **4.5e (born 2026-08-22 — three findings converge on two `Shared/` files nobody owned)** | **B45-1's fix** (`AppBootstrap` opens the store and runs migrations synchronously on the main thread before first paint — a **P2** violation; MEASURED at 54.0 ms first launch / 5.0 ms reopen / 3.6 ms at 100k, so **flat in corpus size** and O(migrations), not a hang today, but the migration set only grows and the device number is unknown) · **A1-21** the `postAutosaves` removal path (the quick note adds one coordinator per capture) · **A1-15's** two inverted comments. **Owns `Shared/AppBootstrap.swift` + `Shared/AppSession.swift`.** Born because the architect's §1 brief gave 4.5a *"the `AppSession` lines"* without listing the file — 4.5a refused to reach across and reported, which is the fence catching the architect's own error | ⏳ **WAVE 3, alone** — those two files are compiled against by every target, exactly like 4.5c's editor brain | ❌ owed (R28) |
| **5 — ✅ BUILT + REVIEWED 2026-08-30** (`mobile-batch-5-record.md`, `mobile-batch-5-cold-review.md`; her two live refinements folded in) | **R26/R27 the shelf layout** (quick note takes Today's Entry's box; books list bounded + scrolls past ~8; writing area ≈ half the screen; Today's Entry becomes a badge on the Journal row, no blinking cursor) · **R27b the starter Journal book** · **R24 "more info" → "info"** · **NEW 2026-08-22 (§53 items 6 + 7): the shelf has NO keyboard-avoidance opt-out** (`MobileShelfView.swift:101` carries only `.background(tokens.room.ignoresSafeArea())`, unlike Write's `.ignoresSafeArea(.keyboard)`) **and R26/R27 pin a DWELLING text field into that layout** — default avoidance insets the whole `VStack`, so the tab bar rides the keyboard and the bounded books list collapses, making **her ruled "about half the phone screen" the first casualty**; plus **the quick note's mint cost at corpus scale, never measured** (`MobilePerfWalkTests` has no quick-note leg; the 100k dev store exists) — measure alongside the layout change, fix only if the number earns it | queued behind 4.5 (same shelf files) | ❌ owed |
| 6 | **SPLIT 2026-08-30.** **6a ✅ DONE** — the Block History twin (absorbs PR5 deleted takes + PR15 the lineage door; `mobile-round-2.md` §70 + `mobile-batch-6a-cold-review.md`), closing the deleted-take dark window. **6b ❌ owed** — PR3 the per-note tray (§69.3's ruled three-section shape) · PR6 archive/unarchive · PR14 the lens-dangles notice · PR22 the guide's deletion chapter. **6c ❌ owed** — the **Two-rooms IA**, UNBLOCKED by her 2026-08-30 ruling (`mobile-archive-trash-design/`) | 6a ✅ | 6a ✅ · 6b/6c ❌ owed |
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
1. **`planVisibleTakeEdit` is HERS — ⚠️ SUPERSEDED IN SCOPE 2026-08-23, and the tripwire below is redefined.** As set, it read: a cross-block span touching a
   block with takes must keep REFUSING on the phone. **Her 13u item 5
   ruling has since opened the fanned case** — a fanned *middle* block
   deletes whole to the tray; a fanned *edge* block's edit touches the
   chosen take only. **So the fence no longer means "keep refusing"; it
   means the phone does not invent its own answer.** 13u rules the
   semantics for both platforms and mobile composes to them. **The
   tripwire is redefined:** a diff touching that method is fine when it
   implements 13u's rule and is a finding when it invents one — **grep
   for it and READ the change**, rather than treating any hit as a
   violation. *(It still held at 0 Swift hits through this round.)* She is handling the
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

1. **13l's manifest — COMPLETED THROUGH 13l's CLOSE ONLY** (`phase-13l-data-safety-floor.md`). **⚠️ AMENDED 2026-08-23:** as written this said "must be COMPLETED", which **becomes impossible the moment 13l closes** — and 13l runs before mobile resumes. **The rule now:** the manifest is complete as of 13l's close and is not edited afterwards; **anything Mac-side that mobile does LATER goes to the SECOND manifest (obligation 13)**, not into a closed phase's file. Every "write it into 13l's manifest" instruction elsewhere in these documents inherits this amendment.
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
9. *(There is no obligation 9 — a numbering slip from 2026-08-22, left rather than renumbered so existing cross-references keep resolving. **The list runs 1–8, then 10, 11, 13, 12** — thirteen obligations, and **13 sits before 12 deliberately** because 12 was reassigned. Count them, do not trust the last number.)*
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
13. **🔴 THE SECOND MAC MANIFEST — created 2026-08-23 by the handoff
    sweep, because nothing owned it.** R20 bought **ONE** Fable cold
    review of this round's Mac changes, and it runs as **13l's first
    act**, covering the work **through batch 4.5**. But **4.5c is heavily
    Mac-side** (`EditorSurfaceController`, `EditorViewModel`, and two
    hoists into `Shared/EditorBrain/`), **4.5e touches two Mac files**
    (one of which destroys her text on a refusal), and **batches 5–8 may
    add more** — **all of it landing AFTER 13l has closed.** So the
    review she asked for covers the Mac work done up to 2026-08-23 and
    **nothing done afterwards**, while the most Mac-visible mobile work is
    still ahead. **This closeout hands a SECOND manifest forward** — same
    shape as 13l's (every Mac-side file, every hoist, what the Mac's
    callers now delegate to, the final counts) — **to the next Mac phase
    that opens after mobile resumes: 13p on her current order, and a good
    home on merit because on-device encryption is both-platform anyway.**
    The reasoning is §6b. **Or she rules it unnecessary — but the round
    may not close on silence here.**
12. **R16 → THE CANON — ⚠️ REASSIGNED TO 13u, 2026-08-23.** **Her 13u item 5 IS R16 promoted from a principle to a scheduled design**, and 13u runs before mobile resumes — so the phase that BUILDS the behaviour should propose the canon wording, not a mobile round proposing wording for a behaviour another phase is defining. *(Its own caveat here is already stale: it said the fourth refusal case is "the one the wording must be honest about", and she has since ruled that case — the fanned one — open.)* **Mobile keeps a one-line pointer only.** Two sessions proposing canon wording for one principle, months apart, would cost her the same sitting twice. **Canon changes remain author-only either way.** The original text: Her standing principle, recorded verbatim at
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
> **AND RUN §2b BEFORE YOU PLAN ANYTHING — the HANDBACK CHECKLIST.** Nine
> items left mobile for 13l and 13u on her ruling, on the understanding
> that *"the mobile session shouldn't have mac / shared work to do when I
> return to it."* §2b gives each one a **command that answers yes/no** and
> **the value it returns while the work is undone**, so a matching value
> means nobody did it. **Anything that did not land is MOBILE'S AGAIN —
> put it in a batch in the commit that finds it, and tell her**, because
> she ruled them out on the understanding they would be done.
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
| **What 13l changed in files this round touched** | `git diff --stat <this cutover's tip>..origin/main -- App/Variorum/Shared/ App/Variorum/Variorum/ App/Variorum/VariorumMobile/` — **the third path is not a typo:** 13l's manifest assigns it the remaining decision-layer hoist whose Mac twin is `MobileTrashModel.swift`, which lives under `VariorumMobile/`, so a Mac phase can and will change mobile files — **this is the important one; see §5** |
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

## 2b. 🔴 THE HANDBACK CHECKLIST — run this BEFORE you plan anything

**Nine items left mobile for the Mac phases on her 2026-08-23 ruling. This
section is how you confirm they actually landed — and what happens if
one did not.**

**Why it exists in this form:** "verify what the Mac phases built" appears
three times in this handoff, and **an instruction to verify is not a
verification.** This project's own failure mode is a row that everyone
assumed someone else had. So each row below carries **a command that
answers yes/no**, and **the value it returns TODAY, while the work is
undone** — so a matching value means *nobody did it*, not *it is fine*.

**THE RULE, and it is the point of the whole section:**

> **If an item did NOT land, it is MOBILE'S AGAIN.** Do not assume a Mac
> phase deferred it deliberately, and do not leave it for a third phase.
> **Put it in a batch, in the binding map, in the commit that finds it**
> — then tell her, because she ruled these out of mobile on the
> understanding they would be done, and she should know if one came back.

### 13l owed these four (L-a … L-d)

| # | item | command | **TODAY (= not done)** | if it did not land |
|---|---|---|---|---|
| **L-a** | The Mac has no identity-projection audit — the DEBUG oracle for *the totals agree while the content is wrong*, which the round **reproduced Mac-side** | `grep -rl 'auditIdentityProjection' App/Variorum/Variorum \| wc -l` | **`0`** | **Highest-value of the nine.** It is a HOIST to `Shared/EditorBrain/` + Mac wiring + a Mac-side red-on-old. Take it back into 4.5c |
| **L-b** | The Mac's `QuickEntryBar` **destroys her text on a refusal** (`entryText = ""` before the mint) and dumps a raw error | `grep -c 'New note refused' App/Variorum/Variorum/Features/Shelf/QuickEntryBar.swift` | **`1`** (and `entryText = ""` appears **2×**) | **A live data-loss bug on her daily driver.** If it survives 13l, tell her at once — do not wait for a batch boundary |
| **L-c** | `AppBootstrap` runs migrations **synchronously on the main thread before first paint** (P2, both platforms) | `grep -c '\.opening' App/Variorum/Shared/AppBootstrap.swift` | **`0`** | Take it back into 4.5e. **The shape is already ruled** (§58/§62) and a real device number may exist — check the device walk's D8 row |
| **L-d** | `Shared/AppSession.postAutosaves` has **no removal path**; the quick note adds one coordinator per capture | `grep -c 'removeValue\|releaseAutosave' App/Variorum/Shared/AppSession.swift` | **`0`** | Take it back into 4.5e, with the `quitFinalize` trap §62 traced |

### 13u owed these five (its item 8), plus item 7

> **STATUS 2026-09-14 (13u1, BOTH UNITS): ALL FIVE PLUS ITEM 7 HAVE LANDED — nothing from this block comes back to mobile.** U-2 and U-7 landed at UNIT 1; **U-1, U-3, U-4 and U-5 landed at UNIT 2** with the cross-block compound they depended on. Each row below carries what shipped, in the words of the thing that shipped. **What mobile still owes is a FACE, not a fix** — the phone's receipt for the compound (the Mac's `CrossBlockEditCopy`) and its own walk of the matrix; the SEMANTICS are ruled once for both platforms (her item 5 coordination flag) and the phone inherits them through the shared brain today. That is the closeout's parity row, recorded as a decision rather than left as a discovery.

| # | item | command | **TODAY (= not done)** | if it did not land |
|---|---|---|---|---|
| **U-1** ✅ **LANDED 2026-09-14 (13u1 UNIT 2)** | The fan fence is read from a **frozen projection** — a block that gained a take mid-typing can be merged away | read the plan's fan source: does it read the STORE at run time, or `slots`? | reads the frozen projection | **DONE, both halves.** The plan takes NO fan arity at all now: the fan decides whether the ends JOIN, and `CrossBlockCompound.apply` asks that of the STORE, synchronously, INSIDE the flight (after `runStructural`'s flush, under the one-flight latch, on the serialized operations runner) through a `liveActiveTakeCount` closure both platforms hand it. That is the correctness half stated as a law — *never authorize from stale state*, the 13c R3-1 doctrine. The POLICY half is her item 5 ruling: a fan on either surviving end suppresses the JOIN (#11a carried forward), never the edit. **RED ON OLD, measured on a scratch worktree:** with a take arriving while the buffer was dirty, the old road read arity 1 off the frozen projection and MERGED the two blocks away. Pinned: `CrossBlockCompoundTests.aTakeArrivingDuringTheTypingBurstStopsTheJoin` |
| **U-2** ✅ **LANDED 2026-09-14 (13u1 UNIT 1)** | The **O(N²) twin** in `planVisibleTakeEdit` — `range(ofEntryAt:)` inside a collection loop, on the keystroke road | `grep -c 'range(ofEntryAt:' App/Variorum/Variorum/Features/Editor/EditorSurfaceController.swift` | **`19`** — and check whether any remain *inside a loop* | **DONE, and wider than this row asked.** The site is fixed and MEASURED (**4.31 s → 1.57 ms** at 8,000 blocks, red on the real pre-fix code), and the whole CLASS was swept to completion on BOTH platforms as the KnownIssues row's remedy demanded: **14 callers FIXED, 24 verdicted provably SAFE, and no production caller of that accessor now sits inside a loop over the entries.** The accumulation is ONE shared brain (`BlockRangeIndex.entryRanges()`), equivalence-pinned on an irregular tiling with empty entries. **The phone's two members went with it** (`MobileEditorViewModel.applyDifferential`, **3.73 s → 30.6 ms** at 8,000 blocks on iPhone 17 Pro; and the crystallization attribute stamp) — so mobile inherits the fix rather than the debt. Record: the 13u1 plan's UNIT 1 RECORD, section A |
| **U-3** ✅ **LANDED 2026-09-14 (13u1 UNIT 2)** | The gap fence's **missing Mac face** — she meets a raw `blocksNotAdjacent(first:second:)` dump | `grep -rl 'blocksNotAdjacent' App/Variorum/Variorum \| wc -l` | **`0`** | **DONE, and at the root rather than at the words.** The compound's run is an index RANGE, not the intersected set, so a zero-length GAP inside the span is IN the run and the plan FENCES it — no operation is attempted at all, and `CrossBlockRefusal` (hoisted) diagnoses `.unsyncedBlock` over the same run, so the sentence names the cause — a block that has not arrived (deliberately no block id: naming rows is the enum-dump class; wording precised at the 13u1 ladder, round 1). `blocksNotAdjacent` ALSO gained Mac words as the belt behind that brace (the ordinary race). **RED ON OLD, measured:** the old plan answered `Edit(blockIDs: ["b0", "b2"] …)` — a merge ACROSS the gap — and the status line read the raw `blocksNotAdjacent(first: "00000000-…-0001", second: "00000000-…-0007")` with both UUIDs in it. Pinned: `CrossBlockCompoundTests.aGapInsideTheSpanRefusesAndNamesTheCause` *(renamed at the 13u1 ladder, round 1)* |
| **U-4** ✅ **LANDED 2026-09-14 (13u1 UNIT 2)** | An **empty block inside a span** yields a plan that can never execute | read the plan's run collection for a zero-length arm | no zero-length arm | **DONE — the same one-line change as U-3, from the other side.** An EMPTY block inside the span is now an ordinary member of the run: covered whole, so it rides `deleteBlock` to the tray with everything else, and the gesture WORKS where it used to refuse with a cause that was not there. **RED ON OLD, measured:** the store was untouched and the status read the raw `blocksNotAdjacent` dump. Pinned: `EditorSeamCostTests.theCrossBlockPlanTakesAnEmptyBlockInsideTheSpan` |
| **U-5** ✅ **LANDED 2026-09-14 (13u1 UNIT 2)** | **`CrossBlockRefusal` never hoisted**, so the phone's refusal names none of its four real causes | `find App/Variorum/Shared -name 'CrossBlockRefusal*' \| wc -l` | **`0`** | **DONE, both halves.** The HOIST: the causes, `diagnose` and every road that names an ACT live in `App/Variorum/Shared/EditorBrain/CrossBlockRefusal.swift`; the one sentence that names a platform CHORD arrives as a `fanRoads` parameter (a shared home must not hold a door one platform lacks — MobileSoul §4.4 from the other side), and the Mac keeps three forwards so **every Mac call site and every Mac pin read exactly as before** — the 3C zero-test-edit proof. The WORDING follows item 5: `.partialBlockAcrossSeam` no longer claims every partially-covered span (the compound takes those) and says what is actually left; `.lockedTake`/`.unsyncedBlock` carry *"nothing was changed"*. **The phone's single line is retired** — the one that carried an unexecuted instruction in its own doc comment to re-narrow itself when merge-then-edit landed — for the shared diagnosis in the phone's own roads |
| **U-7** ✅ **LANDED 2026-09-14 (13u1 UNIT 1)** | 13u item 7 — the Mac's **`MarkdownActs` arm-then-hand-off residual**, the Mac half of M1's root | read `Variorum/…/MarkdownActs.swift` for the arm-then-hand-off sites | present, unaddressed | **DONE.** All eight Mac sites were READ first and the honest answer recorded: **every one already put the gate as the last condition of its guard with the mutation on the next line, so nothing armed and abandoned** — the residual was structural, not live. It is closed by making the separation UNEXPRESSIBLE: `OrdinaryInputEdit.apply` is the one door (gate + mutation + notification in one call) and the eight sites fold onto it, with a grep pin (`OneInputPathTests`) asserting AppKit's `shouldChangeText(in:replacementString:)` is called in exactly one file. Zero behaviour change, zero test edits. **The PHONE is NOT owed a twin:** UIKit has no `shouldChangeText` on `UITextView`, so `MobileMarkdownActs` calls the model's gate directly and the pair has a different shape — recorded so the new Mac door is never read as a parity debt |

### Two more things to confirm at the same time

- **`KnownIssuesAndTechDebt.md`'s M12 is owned by 13u.** If 13u closed without resolving or re-owning it, **the row points at a closed phase** — the orphaned-entry state CLAUDE.md forbids. Re-own it or take it.
- **13l's Fable review covered 4.5b** (commit `7fd2cd0`, the only merged work that reached `Shared/`+Mac unreviewed). **Read its findings before starting** — some may be yours, and this handoff's own second read of 4.5b is deliberate duplication at her word (*"it's for the best if we get more eyes on items"*), not an oversight.

---

## 3. THE REMAINING WORK, IN THE ORDER TO RUN IT

**Sequential, one agent at a time. Each numbered item is a full R28 unit
unless it says otherwise.**

| # | Work | Why this position |
|---|---|---|
| **1** | **4.5b's COLD REVIEW** (owed; its dispatch died before reading anything) | **It is the only merged work that reached `Shared/` and the Mac without a review.** It is now on `main`. First, because everything else is phone-local |
| **2** | **4.5d's FIX ROUND** — §61's 2 MAJOR + 6 MINOR + 6 NIT | Its findings are recorded and adjudicated; the work is `MobileKeyboardBar.swift` + its pins. **Read §64 first** — the architect already restored the experimental revert that round left behind and rewrote its MAJOR 1 comment |
| **3** | **4.5a's LADDER ROUND 2** — a real re-review of §59's fixes | The fixes are substantial and one of them (§62's restore-a-turn-later) changed pin semantics. Round 2 is owed and was never run |
| **4** | **4.5c — now PHONE-LOCAL ONLY** (§4): the unwired A7/#34 seam carves · **B45-2** the `displaySlot` coupling batch 7 walks into · B45-3's phone half · the live editor over a tombstone · the `MobileLenses.swift:419` candidate · two one-liners | **Six of its items moved to 13l and 13u** at her ruling. **Run §2b's handback checklist first** — anything the Mac phases did not do is yours again. The cross-block SEMANTICS are 13u's; compose to its rule rather than inventing one |
| **5** | **4.5e — probably VERIFICATION ONLY** (§4) | **Nearly all of it went to 13l** (L-c `AppBootstrap`, L-d `AppSession`, L-b the Mac's `QuickEntryBar`). What is left: confirm the `.opening` launch arm renders on the phone and that releasing an autosave coordinator at the quick note's `reset()` behaves. **If 13l built it all, 4.5e closes as verified rather than built** |
| **5b** | 🔴 **BATCH 4.6 — THE QUICK NOTE'S SECOND PASS. NO DESIGN SITTING IS OWED — 13u DECIDED IT.** From her 2026-08-23 device walk (verbatim source: `notes/author-reports/2026-08-23-device-walk-and-product-asks.md`; analysis: `mobile-round-2.md` §67). **(a)** moving the caret into the frozen prefix puts the box in a state where **⏎ stops opening the note and starts inserting newlines** — which A5-1 says can never happen — **and the hand-off then drops BOTH the tail AND her prefix edits.** Her verdict: *"complete disaster, lost prose class of bug. we need full multi line editing clearly or some other solution because this was not it."* **THE DESIGN IS THE DEFECT: the boundary hold exists because A5-2 ruled ONE BLOCK, and she rejected that ruling in use — so A5-2 was reopened.**
> **⚠️ AND IT IS NOT YOURS TO DECIDE.** Her 2026-08-23 ruling: *"4.6 is going to happen after 13u, so update it to say it won't need a design sitting, the mac will have decided it."* **13u item 9 settles the quick-capture ownership model for BOTH platforms** — whether a capture surface holds one paragraph or many, what ⏎ does, what shift-⏎ does, and what the hand-off carries. **READ WHAT 13u RULED FIRST, then build the phone's face to it. Do not re-open it, and do not diverge from it** — the whole point of the Mac phases running first is that this rule gets decided once. **(b)** the box **vanishes with no receipt** on a swipe-away; the note was saved and nothing said so. Her shape: *"maybe it needs to stay in that field for like three minutes when you swipe away, editable in that field… at the very least, a link to the one that was just created should pop up."* **This reverses A5-8.** **(c) SHIFT-ENTER for a new paragraph** — the phone half of the same rule 13u item 9 settles | **A lost-prose defect, so it precedes the stability pass and every feature batch.** It is a BUILD, not a sitting — **but it is blocked on 13u having ruled**, which is why it sits after both Mac phases by construction |
| **6** | **THE DEDICATED STABILITY PASS** — batch 4.5's **exit condition** | 4.5 is not done until it runs. It owns **M27**. Nothing that resembles it discharges it. **Feed it §67's E1 result: the signature FIRED on her hardware, so M1's root is PROVEN and this pass reviews a fix now known to catch the real thing** |
| **7** | **Batches 5 · 6 · 7 · 8** — the first handoff's §3 map, unchanged. **5:** the shelf layout (R26/R27 — the quick note takes Today's Entry's box, the books list bounded, the writing area ≈ half the screen), the starter Journal book (R27b), "more info" → "info" (R24). **6:** the per-note tray · deleted takes / History past · archive-unarchive · the lens-dangles notice · the lineage door · the guide's deletion chapter. **7:** reorder takes · the duplicate-book-name guard · copy-all-takes · take→block · **M23 copy-follows-screen** · swatches + emoji · block multi-select · **PR21 replace, which HOISTS `FindReplaceGate` WITH it, never after**. **8:** tag-chip grammar · cadence/pruning settings · PL-9's judgment acts · document settings · **PR23 the forked voice brain (HOIST)** · **M14's unmeasured half** | **Batch 5's brief must carry §53's two added deliverables** (the shelf has NO keyboard-avoidance opt-out while R26/R27 pin a DWELLING text field into that layout — her ruled "half the phone screen" is the first casualty; and the quick note's mint cost at corpus scale was never measured). **Batch 7 walks into B45-2**, so 4.5c must close it first |
| **7b** | **BATCH 9 — THE EDITOR'S ⋯ MENU, THE TAKES VOCABULARY, AND TEXT SELECTION** (her 2026-08-23 list). **(a) Structural UNDO *and* REDO in the ⋯ menu** — *"i want it easy to access."* The stack is `Shared/` and live; M20 gave the phone a receipt-based undo, **redo has no door at all**. **(b) Take history MOVES to the PER-TAKE ⋯ menu.** **(c) "Takes" comes OUT of the main ⋯ menu** — *"it's already the middle bar."* **(d) MERGE — her question, not an instruction:** *"i also only see merge with previous rather than a multi merge option? or do we need to add multi merge on mobile still? or a select and then merge? idk, let's think about that three dots menu a little more."* **Bring the whole ⋯ vocabulary as a proposal — propose-only.** *(Context: the Mac's N-way merge chain shipped at 9d; the phone's carry-all fanned merge at parity C5.)* **(e) 🟠 TEXT SELECTION IS BROKEN** — raised unprompted: *"holding it down makes you scroll upwards, the exact opposite."* A daily-use defect on the core surface; **trace the mechanism before designing** | Grouped by SURFACE — all five live in the editor's own files |
| **7c** | **BATCH 10 — NAVIGATION, STARRING & BOOKS** (her 2026-08-23 list). **(a) A SWIPE GESTURE BETWEEN SHELF AND LIBRARY** — *"it's killing me."* **(b) A DIFFERENT WAY TO SEE STARRED NOTES ON THE HOME SCREEN** — *"I don't like where it appears above the shelf, I think it's awkward placing."* Her floated shape, unchosen: *"maybe you should be able to swipe from your shelf to a list of starred notes"* — **it composes with (a)**. **SHE RULED THE BOUNDARY: build a phone face; do NOT build a starred smart book** (*"add smart book of starred notes to the 13i phase and don't build it yourself. however, DO build a different way to see starred notes on the homescreen"*). **(c) NEW NOTE + NEW CHAPTER BUTTONS INSIDE A BOOK** — *"which the mac up does have."* Both ops are core and shared; **the phone owes doors, not brains** | **Check batch 5 first:** her *"I still see today's entry where i don't want it and the quick note where i don't want it"* is R26/R27, already batch 5's — do not re-solve it here |
| **8** | **THE WHOLE-ROUND PASS** — **closeout obligation ZERO** | The round cannot close until it runs |
| **9** | **Closeout** — the first handoff's §7. **Thirteen obligations, numbered 1–8, 10, 11, 13, 12** (there is no 9; 13 precedes 12 deliberately — count them, do not trust the last number) | Includes the **parity ledger** (PL-9/10/11 burned down, PL-12 answered, this round's own line added) · **QUESTIONS.md**, which still has ZERO round-2 entries while fifteen items are held for her · **obligation 1 as AMENDED** (13l's manifest is complete through 13l's close and is not edited after; later Mac work goes to the second manifest, obligation 13) · **obligation 12 REASSIGNED to 13u** (R16 → canon; the phase that builds the behaviour proposes the wording) |

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

### 4.5c — **NEVER RAN — and it SHRANK on 2026-08-23 to phone-local work only**

> **Six of its items left for the Mac phases** (her ruling, §6b): the
> frozen-projection fan fence, the O(N²) twin, the gap fence's Mac face,
> the identity-audit hoist, the empty-block dead plan and
> `CrossBlockRefusal`'s hoist → **13l (L-a) and 13u (item 8)**.
> **VERIFY WHAT THEY BUILT before planning anything below** — the
> itemisation that follows is the record of the FINDINGS, not a list of
> your work.
>
> **What is still 4.5c's, and it is phone-local:** the unwired A7/#34
> **seam carves** (the phone owes a consumer for brains that already
> exist — but **13u item 5 rules what that gesture DOES**, so compose to
> its rule) · **B45-2** the `displaySlot`/`slots[i]` coupling batch 7
> walks into · **B45-3's** phone half (E2, §8 path 8, the
> `supportsTextReplacement: false` fence, and M1's status — **E1's
> instrumentation was built on 2026-08-23 for her device window; check
> the device walk's results before treating M1 as unproven**) · the
> **live editor over a tombstone** (the liveness seam is phone files) ·
> the **`MobileLenses.swift:419`** candidate confirm site · the two
> one-liners.

### The findings as originally itemised (a record, not a work list)

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
| **B45-3 — the crash trace's six unowned items** | **⚠️ E1 RAN 2026-08-23 AND FIRED — M1 IS PROVEN (§67; the crash trace's top banner). This item is DISCHARGED.** **E1** (build the instrumentation and leave it RUNNABLE for a device session that will not have your context — **M1's root is still "high confidence, NOT PROVEN"**) · **E2** · **§8 path 8** (UIKit undo replaying a coalesced edit — zero mentions anywhere in the round) · **§8 path 11** (the `supportsTextReplacement: false` fence — verify it stands and says why) · **§9's `MarkdownActs` Mac residual** · **M1's SUSPECTED status itself**. **Each leaves the session FIXED or with a named owner** |
| **A1-5 — `CrossBlockRefusal` never hoisted** | Merge-then-edit landed and the refusal copy carrying **its own unexecuted instruction** was never re-narrowed, so the phone's cross-block refusal names **none** of its four real causes |
| routed in from 4.5b | the **live editor over a tombstone** (the filed remedy was WRONG — the stale editor is in the *other* tab stack, so the fix is at the liveness seam), the **`MobileLenses.swift:419`** candidate, and two one-liners (`deleteNoteRefusal:958` → `DeletionRefusal.words(error)`; the A1-15 comment at `MobileCrossBlockEditTests.swift:598`) |

**M-B binds every line of it:** core + Mac + both spines + mobile, and
**every Mac-side change into 13l's manifest** — 13l will have closed, so
**re-read what it did there first** and record against the current file.

### 4.5e — **NEVER RAN — and it is now almost entirely 13l's**

> **Her 2026-08-23 ruling moved its Mac and `Shared/` work to 13l**
> (§6b): **B45-1** (`AppBootstrap`'s main-thread migrations) → **L-c**;
> **the Mac's `QuickEntryBar`/`QuickNoteView` twins**, including the one
> that destroys her text on a refusal → **L-b**; **`AppSession`'s**
> missing removal path and its three false comments → **L-d**.
>
> **What is left for mobile: essentially nothing but verification** —
> confirm the `.opening` launch arm renders correctly on the phone and
> that releasing an autosave coordinator at the quick note's `reset()`
> behaves. **If 13l built it all, 4.5e closes as verified rather than
> built.**

### The findings as originally itemised (a record, not a work list)

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
Mac home. **⚠️ SUPERSEDED 2026-08-23 — E1 RAN ON HER DEVICE AND FIRED; M1's ROOT IS PROVEN.** iOS consulted the delegate about an insert at offset 178, performed a different net-zero transaction at 177, then inserted at 178 without consulting — the gate's verdict and the storage report describing different edits, observed. **The binding REJECTED it, `desync recoveries 0`.** Full analysis `mobile-round-2.md` §67; the crash trace carries a result banner at its top; her verbatim trace is `notes/author-reports/2026-08-23-device-walk-and-product-asks.md`. **The device queue's highest-value item is discharged.** *(The MAC half — the `MarkdownActs` arming residual — is unaffected and remains 13u item 7: E1 answered the iOS half.)*

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

## 6b. ⚠️ ~~THE GAP NOBODY OWNED~~ — **DISSOLVED 2026-08-23 BY HER RULING. Read this, then skip to §7.**

> **Her correction, verbatim:** *"I thought I asked for 4.5c's mac work to
> be added to what 13l is supposed to accomplish? so the mobile session
> shouldn't have mac / shared work to do when I return to it (though it
> may still find other items in which case they should be fixed, as
> previously ruled)."*
>
> **MOBILE'S REMAINING MAC AND `Shared/` BACKLOG HAS MOVED TO THE MAC
> PHASES.** 13l takes the four data-safety-shaped items (**L-a** the
> Mac's missing identity-projection audit · **L-b** the Mac
> `QuickEntryBar` that destroys her text on a refusal · **L-c**
> `AppBootstrap`'s main-thread migrations · **L-d** `AppSession`'s
> unbounded autosave map + its three false comments); **13u takes the
> five editor-seam items** as its item 8 (the frozen-projection fan
> fence · the surviving O(N²) twin · the gap fence's missing Mac face ·
> the empty-block dead plan · `CrossBlockRefusal`'s hoist and wording),
> because item 5 rewrites that seam and item 7 already owns the Mac's
> `MarkdownActs` residual.
>
> **So the problem this section described no longer exists:** there is no
> post-13l mobile Mac work for a second manifest to carry.
> **Obligation 13 survives only as a TRIPWIRE** — if mobile *discovers*
> new Mac/shared work under R8 (her rider keeps that permission alive),
> it still hands it forward rather than fixing it silently.
>
> **WHAT THIS MEANS FOR 4.5c AND 4.5e:** they shrink to **phone-local
> work only**. §4's itemisations are still accurate as a *record of the
> findings*, but the Mac/`Shared/` rows in them are **no longer mobile's
> to build** — verify what the Mac phases did instead.

*(The original text is kept below because it is the reasoning that
produced the ruling, and because the tripwire's shape comes from it.)*

### The gap as originally found

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
16. **THE FRAGMENTS BRIDGE DOES NOT RUN ON HER PHONE, AND SHE NOTICED** (§68). She asked why she had to sign in there; the answer is that **she did not have to — the door has no consumer.** `bridgeEnabled: true` has exactly one caller (the Mac app); the phone's composition passes false and is pinned that way. **The token is Keychain-per-device by design and should stay that way.** But **she identified the live consequence herself**: *"my computer has to be open for that."* **A journal entry written on her phone reaches Fragments only when her Mac next opens** — on the device MobileSoul §1 calls the one she writes journal entries on. **The DOOR's fate is batch 8's** (PL-9's judgment act) **and the honest-copy floor belongs there regardless**; **whether the phone should run the bridge at all is HERS** — it is phase-sized, touches the Fragments contract and their side, and would put the journal-class E2EE key on a second device. **DISSOLVED 2026-09-04 — the Fragments bridge itself was RETIRED from `main` (pre-13x batch 0b, her ruling 16; tag `archive/fragments-bridge-2026-09-04`, `notes/archive/fragments-bridge.md`), so there is no door and no consumer on either device. MERGE NOTE for the mobile seat: the `mobile` branch (worktree `~/dev/variorum-mobile`, 66 ahead / 422 behind `main` on 2026-09-04) still carries every bridge file, so its next merge from `main` meets delete/modify conflicts on them — take `main`'s deletions (`Sources/VariorumCore/Bridge/`, the 16 core `Bridge*`/`Fragments*`/`FakeFragmentsServer*` test files, `Shared/BridgeSession`, `Shared/BridgeStatusViews`, `Shared/SignInFlow`, `Phase9bBridgeWiringTests`); drop the phone composition's `bridgeEnabled: false` argument (and any `fragmentsAuth:`/`makeBridge…` argument the branch grew); drop the `Phase9cAuthWiringTests` pins on them (`main`'s version of that file is the shape to keep); `BridgeHash` now lives at `Sources/VariorumCore/Domain/BridgeHash.swift`, name unchanged.**
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

---

# §9. THE HANDBACK CHECKLIST — **RUN 2026-08-30. RESULTS BELOW.**

*Written by the 2026-08-30 orchestrator session, at her instruction to
find mobile parity work runnable **without 13u**. §2b said an
instruction to verify is not a verification; this is the verification.*

## 9.1 THE STATE THAT CHANGED UNDER THIS ROUND — read this first

**`mobile` was 206 commits behind `main` and ZERO ahead** (fast-forwarded
at the top of this session). **THREE Mac phases closed since the
2026-08-23 cutover, not one**, and the handoff above was written knowing
only about 13l:

| phase | closed | what it means for mobile |
|---|---|---|
| **13l** | 2026-08-24 | **All four handback items LANDED** (9.2). Parity row **PL-13** born — the phone owes data-safety FACES |
| **the post-13l polish round** | 2026-08-25 | **RULED BATCH 6's ENTIRE DESIGN** before a mid-design could reach the phone — her token instruction, executed: `mobile-round-2.md` **§69**. Parity row **PL-14** |
| **13p** | 2026-08-30 | **The phone's encryption faces SHIPPED INSIDE THE PHASE** (PL-15, her mobile-only-user rider; 19 pins, mobile 486/78 → 513/86). **No parity debt owed** — only her LIVE Face ID walk and the on-device perf leg, which only her hardware can give |

**13i has NOT run — it is `pending`.** An earlier draft of this section
said it had, and that was wrong; the error is corrected here rather than
left to mislead. What happened is that **wings and the Owned book were
RATIFIED INTO CANON** at the 2026-08-25/26 launch-strategy sitting
(`CoreDescription` pillar 3, `OverallModel` §2) **ahead of the phase that
builds them** — the canon wording "designed and built at Phase 13i" reads
naturally as past tense and is not. **Measured: `Wing` appears in ZERO
files across `Sources/`, `App/Variorum/Shared/`, the Mac target and the
phone.** So there is **no 13i parity debt yet**, and the ledger is right
to be silent. When 13i runs, its mobile consequences are real and large
(a library level ABOVE books, plus a book relationship that bends the
notes-in-many-books default) — **PL-12's "design together" test will
almost certainly be met, so mobile should be IN that design sitting**
rather than handed a parity row afterwards.

**Baseline now: core 1453/154 · Mac 1843/312 · mobile 513/86 · spine
71/10; marker 7.** The Mac's known intermittent latency pin is
red-under-load and pre-existing — its KnownIssues row says re-run it
isolated before concluding anything.

## 9.2 13l's FOUR — **ALL FOUR LANDED. Nothing comes back to mobile.**

Commands are §2b's own, run against `main`'s tip (5123580). §2b gave the
value each returns **while undone**; every one of them moved.

| # | item | §2b said (= undone) | **MEASURED** | verdict |
|---|---|---|---|---|
| **L-a** | the identity-projection audit hoist | `0` | **`1`** | ✅ **landed** — and it earned its keep: its FIRST run caught the macOS-26 attribute-fixing widening now pinned in `TEXTKIT2_NOTES.md` §3 |
| **L-b** | the Mac `QuickEntryBar` destroying her text on a refusal | `1` | **`0`** | ✅ **landed** — the live data-loss bug on her daily driver is gone |
| **L-c** | `AppBootstrap` migrations on the main thread (P2) | `0` | **`4`** | ✅ **landed** |
| **L-d** | `AppSession.postAutosaves` with no removal path | `0` | **`2`** | ✅ **landed** |

**Consequence: 4.5e is verification-only, exactly as §3 row 5 predicted,
and no 13l item returns to mobile under §2b's rule.**

## 9.3 13u's — **NOT RUN. Every item still open, as expected.**

13u has not run and **was SPLIT on 2026-08-26 into 13u1 (the editor
seam) + 13u2 (feel & faces)**, sharing ONE kickoff sitting. **U-3** and
**U-5** measured at their undone values (`0` and `0`). U-1, U-2, U-4 and
U-7 are unchanged by construction.

**This is not a defect and must not be treated as one** — the author's
own framing, 2026-08-30: *"the 13u not being done should NOT be treated
as an error."*

**What 13u genuinely blocks, and ONLY this:**

1. **Batch 4.6** (the quick note's second pass) — blocked on **13u item
   9**, which settles the quick-capture ownership model for BOTH
   platforms. Her ruling: *"it won't need a design sitting, the mac will
   have decided it."* Building the phone's face before that ruling is
   the divergence the two-Mac-phases-first order exists to prevent.
2. **The cross-block SEMANTICS half of 4.5c** — 13u1's item 5.
3. **U-1's policy half** (U-1's *correctness* half — never authorize
   from stale state — was always safe to take back).

**Everything else is unblocked.** Batches 5, 6, 7, 8, 9 and 10 do not
depend on 13u at all.

## 9.4 WHAT IS BLOCKED ON **HER**, NOT ON 13u — do not improvise it

**PL-14(b) / §69.5 — the phone's ARCHIVE/TRASH IA SEPARATION**, and
**§69.6 — the VERSIONS face's door and listing shape.** Her ruling,
verbatim in PL-14: the phone mimics the Mac's decided surfaces *"in some
way that works for mobile"*, settled at **its own design session
proposing different designs to her as HTML mockups**. The phone's
combined "Archived & Deleted" is **known-interim by her word**.

**So batch 6 SPLITS, and the split is the useful finding:**

- **6a / 6b — BUILDABLE NOW, design fully ruled by §69:** the Block
  History twin (§69.4) · the per-note tray's three-section shape
  (§69.3) · the verify-don't-rebuild set (§69.7) · the pocket guide's
  deletion chapter (§69.8) · the version-blind accessibility labels
  (PL-14(g), one line, owed regardless).
- **6c — WAITS FOR HER:** the IA separation and the Versions face.

## 9.5 THE DELETED-TAKE DARK WINDOW — the reason 6a goes first

**PL-14(c) / §69.2: deleted takes are currently INVISIBLE and
UN-RESTORABLE on the phone** — recoverable only via the Mac. `TrashScope`
shipped on both platforms (takes never row in a global Trash, correctly),
but the phone's Block History and tray faces — which are a deleted take's
*only* home — have not landed. **The rule is right and the face is
missing, so the phone has a data-visibility hole on her daily driver.**
It is recorded OPEN and hers to time; this session builds 6a to close it.

## 9.6 PL-10's FOUR DOORS — verified still missing, core ops all present

Measured this session, so batch 7's brief does not have to re-derive it:

| PL-10 | core op | phone door |
|---|---|---|
| (a) reorder takes | `reorderTake` — `Operations+Variant.swift` ✅ | **0 references** |
| (b) duplicate-book-name guard | `assertBookNameIsFree` — `Operations+Reading.swift` ✅ | **0 references** |
| (c) copy-all-takes | `Queries.blockTakes` ✅; `TakeClipboard` is **Mac-only** | needs a `UIPasteboard` twin — **HOIST, never copy** (§3) |
| (d) take→block | `Operations+TakeStructure.swift` ✅ | Mac doors only |

**B45-2's coupling sits at `MobileEditorViewModel.swift:1146`
(`displaySlot`) with its callers in `MobileTakesController.swift`** — and
batch 7's reorder-takes work walks straight into it, so it closes first.

## 9.7 THIS SESSION'S CAST — a stated call, hers to overturn

Her 2026-08-23 ruling was **Fable, one subagent at a time**. Her
2026-08-30 instruction records the budget as *"33% of my weekly limit
left mostly on Opus agents"*. **Called: Opus implementers, still strictly
ONE AT A TIME** — coherent with 13p's own cast (Fable on substrate and
custody, **Opus on faces**), and this session is all faces. **The
one-at-a-time half of her ruling is untouched**; R28 (build → cold review
→ fix as one unit) binds unchanged.

---

# §10. HER RULINGS AND ONE HARD-WON MACHINERY FINDING (2026-08-30)

## 10.1 🔴 THE ARCHIVE/TRASH IA IS **RULED: OPTION 2, "TWO ROOMS"**

The design session ran (`notes/plans/mobile-archive-trash-design/` —
four options as local self-contained HTML, propose-only). **She read it
and ruled**, discharging PL-14(b)/§69.5's design-session gate:

> *"i read the proposal and I want this option: **Two rooms** — The Mac's
> own asymmetry, translated literally. Archive becomes a room you browse;
> the Trash becomes a utility you visit. Two doors, two destinations,
> nothing shared."*

**Note this OVERRULES the proposal's own recommendation** (option 3, the
Library-filter road). Her reasoning is recorded in 10.2 and is not
merely a preference — it carries a scope consequence the proposal did
not anticipate.

**So batch 6c is UNBLOCKED and its shape is fixed:** two doors, two
destinations, nothing shared; the combined "Archived & Deleted" surface
retires. The five-places map (§69.1) still governs every remaining call.

## 10.2 🔴 AND A NEW WORK ROW SHE CREATED IN THE SAME BREATH — **THE LIBRARY'S FILTER VOCABULARY**

Her words, and the second half is the bigger item:

> *"Archived is a comparatively rare option, and it needs the same
> filters that the regular library has. the mockup only had bookless and
> scraps but those are less useful than 'books' 'posts', etc. so I'd want
> to see that kind of sorting on the library, **which is more important
> because it's where you see everything**."*

**Two distinct deliverables, and she ranked them:**

1. **THE LIBRARY'S OWN FILTERS ARE THE PRIORITY** — *"more important
   because it's where you see everything."* Today the phone's filter
   vocabulary is `bookless` and `scraps` (`MobileLibraryViewModel`), both
   of which are **provenance** filters. She wants **KIND** filters —
   "books", "posts", etc. — because that is how you actually find a thing
   in a listing of everything.
2. **ARCHIVE INHERITS THE SAME FILTER SET.** Not a reduced one: *"it
   needs the same filters that the regular library has."* This is a
   direct consequence of choosing Two rooms — an Archive that is a
   **room you browse** needs browsing tools, where a filter-chip Archive
   would have inherited them for free. **She chose the option that costs
   this and is paying for it deliberately.**

**Design notes for whoever builds it, not decisions:** "books" and
"posts"/notes are different *entity kinds* on the shelf-vs-library axis,
so the filter row may be expressing two different things at once — worth
settling before building. The proposal's own flagged risk stands and now
matters more: **the filter row is at its width budget**, and this adds
doors to it. That was a measurement question then and still is.

**Ownership: mobile.** Not 13i — this is the phone's listing ergonomics,
not smart-book identity. Slot it near batch 6c so Archive and the Library
get one filter brain, not two.

## 10.3 HER TWO SHELF REFINEMENTS (routed live to the batch-5 agent)

> *"the box should be one line until you click into it"* — the quick-note
> box sits collapsed at one line at rest and grows on focus. **This
> settles batch 5's own PROVISIONAL** about the large empty box on a
> near-empty shelf, in that direction.

> *"the shelf should be bounded so it always has a decent amount of room
> to write"* — batch 5 built a floor into `MobileShelfLayout`; she raised
> it to a **guarantee**, to hold in every state (many books, starred
> present, keyboard up, smallest screen, largest Dynamic Type). **Pin the
> guarantee, not the arithmetic that currently produces it.**

## 10.4 ⚠️ MACHINERY: **TWO AGENTS ON ONE SIMULATOR CONTAMINATE EACH OTHER INVISIBLY**

**Found empirically by the 4.5d agent, 2026-08-30, and it cost real
time.** This belongs beside §2's accessibility-flag warning — **same
class, worse**, because the red names tests from someone else's branch.

**DerivedData is NOT the crossing point** — it is genuinely separate per
worktree (verified via `info.plist`'s `WorkspacePath`). **The SIMULATOR
is:** same bundle id, **last installer wins.**

**Observed symptoms, all of which vanished on an uncontended device:**
repeated `signal kill`; layout pins reading nonsense heights
(`field.height → 14.0`); and decisively, **a failing test that does not
exist in the running worktree at all** (`grep -rn` returns nothing) —
because it came from another branch's installed bundle.

**THE RULE: one simulator per concurrent agent, always, with its
accessibility flag armed.** And note the second-order danger, which is
worse than lost time: a contaminated run hands a *reviewer* **phantom
findings with convincing evidence** — precisely the hallucination class
the guard exists to prevent.

**This retro-explains at least one earlier "environmental" run death** in
this session, and probably more than one.

## 10.5 ⚠️ MACHINERY: A DYING AGENT LEAVES BOTH CORRUPTION *AND* WORK

**§64 is WRONG and should be corrected in place** (it is cited in the
batch map). It recorded that 4.5d's fixes did not exist. In fact
**thirteen of §61's fourteen findings were already fixed** — sitting
**uncommitted in the tree** when the session died, each carrying a fix
comment naming the cold review as its source, and the architect committed
them in `1fc3036`/`ad9d29a` **while writing the message saying they did
not exist**.

**The lesson, and it is §64's missing second half:** §64 correctly taught
*check the tree after an agent fails* — and it found the harness revert
by doing exactly that. **But it read the tree for CORRUPTION and never
read it for WORK.** A dying agent leaves both.

**The consequence that mattered:** one of those commits carried a
**red-on-old pin that had never actually been run red** — a claim, not a
pin. The 4.5d agent ran it (drop `currentBarWidth()`'s remembered-width
arm → 12 issues, the sibling pin still green) and it is a pin now. **An
unverified pin committed on a dead session's behalf is the exact
green-over-nothing class this round exists to correct.**

---

# §11. THE 2026-08-30 PARALLEL BOUT — WHAT LANDED, WHAT IS OWED

**Her window:** ~2 hours, budget on Opus agents. **Her ask:** mobile
parity work runnable *without* 13u, explicitly *"the 13u not being done
should NOT be treated as an error."*

## 11.1 WHAT LANDED ON `mobile` — verified merged, 513/86 → **568/92**

Full suite run on the FULLY MERGED tree (not inherited from any branch):
**568 tests / 92 suites passed**, zero real failures. Hygiene: `Sources/`
diff **empty**, zero `Sync/`, zero build-configuration files, marker 7.
Core **1453/154** and Mac **1843/312** both baseline-exact.

| batch | what | evidence |
|---|---|---|
| **6a — the Block History twin** | Her four regions in her order (savepoint runs · archived+Unarchive · deleted+clock+Put back, **no purge door** · came-from with ALL originals + Bring back). **CLOSES THE DELETED-TAKE DARK WINDOW** — LR1-3's live data hole. Door renamed `Take History…` → **`Block History…`** | `Shared/BlockHistoryFace.swift` hoist; **Mac rode 1843/312 with zero Mac test files edited** — the hoist proof. Two KnownIssues forked-brain entries discharged |
| **5 — the shelf** | Her twice-stated complaint fixed. Quick note takes Today's Entry's box; books bounded; **the box is ONE LINE at rest (70 pt) and 50% of the shelf focused (466 pt)**; Today's Entry became a badge with a fallback row so it is reachable in every state; starter Journal seeds once | The writing floor restated **in lines** (`6 × smallLineHeight + chrome = 140 pt`) and **pinned across 2,408 shelf states** — the promise, not the arithmetic. Worst case **144 vs 140** (SE-class, keyboard up, 40 books, AX5) |
| **4.5d + PL-10(b)** | §61's fix round verified **already done** (13/14) — correctly NOT re-fixed. `assertBookNameIsFree` wired; `BookNameCopy` **hoisted** to `Shared/` | Revert-showed the gate's absence: **two live books with one name got through the rename door**. Four pre-existing book pins stayed green throughout, which is why it shipped unwired. **SEVERITY CORRECTED 2026-08-30 by the author:** this is a **UI courtesy gate, not a data-integrity defect.** Her words: *"the mac app ruled that the UI would deny duplicate book namings but it wouldn't cause a deeper issue… it can be UI gated on the rename area, but it's not a serious bug or issue."* **Verified against the schema: there is NO uniqueness on `reading.name`** — the only reading-side unique index is `uq_reading_post_live` on membership pairs — so duplicate book names are LEGAL in the model and nothing downstream breaks. The wiring was still the right call (the phone should gate where the Mac gates), but earlier records here called it "a real bug" and that overstated it. |
| **the architecture review** | `notes/plans/mobile-architecture-review.md` — **0 BLOCKER · 2 MAJOR · 4 MINOR · 2 NIT** | Findings-only; **no simulator used** (static + a standalone `swiftc` harness), so none of it can carry the contamination below |
| **the archive/trash design session** | `notes/plans/mobile-archive-trash-design/` — four options, local self-contained HTML | **SHE RULED: option 2, Two rooms** (§10.1), plus the Library-filter row (§10.2) |

## 11.2 🔴 OWED — R28 REVIEWS. NOT DONE, AND NOT PRETENDED DONE.

**Batch 6a and batch 5 have NO cold review.** R28 says a batch is
BUILD → COLD REVIEW → FIX as one unit; the window closed with the builds
landed and the reviews unrun. They are merged because the merge was
verified green and the work is hers to use — but **merged is not
reviewed**, and this round exists because that distinction was blurred
before.

**4.5d is the exception and only by accident:** its whole job was
verifying someone else's fixes, so it *was* a review. Its own three new
pins are unreviewed.

**The architecture review's 2 MAJORs are unfixed by design** — she asked
for findings, not fixes. **MAJOR 1 is half-closed already**: its guard
half is exactly what 4.5d wired (the review read `HEAD`, before that
merge). **The latch half — two taps mint two books — is open**, as is
MAJOR 2, the liveness race that can leave a visible editor she cannot
type in.

## 11.3 ⚠️ MY OWN ERROR, STATED PROPERLY — `git commit` COMMITS THE WHOLE INDEX

§10.4's rule was **not sharp enough and I proved it myself.** I told both
main-tree agents "explicit-path staging, never `git add -A`" — and then
**staged one explicit path and ran a bare `git commit`**, which swept
four of the live agent's already-staged index entries into commit
`a232455`: the `OriginPeek.swift` deletion (118 lines) and three renames.

**Nothing was lost** (verified: `OriginPeekCopy` is absent Mac-side and
present in `Shared/BlockHistoryFace.swift` at the tip; the content landed
in the agent's own commit) and no history was rewritten. But
`git log --follow` on those files is now misleading, which is why it is
written here.

**CORRECTION, added after batch 6a's cold review (which caught it): "nothing
was lost" was one step short of the truth.** The sweep committed the
*deletion* of `OriginPeek.swift` without the *addition* that replaced it,
and `OriginPeekCopy` had **eight non-test reference sites** at `16ba929^`
with no declaration anywhere in `App/`. **So the MAC TARGET COULD NOT
COMPILE for the length of that window**, and the batch-6a commit repaired
it as a side effect rather than as an intended change. Nothing was lost
and the tip is correct — but the intermediate commit is broken, and a
`git bisect` across it will fail to build for a reason that has nothing to
do with what it is bisecting. **That is the real cost of a bare
`git commit` in a shared tree, and it is worse than a confusing
`git log --follow`.**

**THE CORRECTED RULE: in a shared tree, `git add <path>` is not enough —
the COMMIT must be pathspec-limited too.** Use `git commit -- <paths>`
(or `--only`). A bare `git commit` publishes whatever is in the index,
including work another agent staged seconds ago. The mockup agent got
this right unprompted; I did not.

## 11.4 ⚠️ THE SIMULATOR RULE, NOW WITH DECISIVE EVIDENCE

§10.4 recorded this from one agent; a second **proved it by measurement**.
Four runs on a shared device reported 560–564 tests including whole
suites (*Shelf layout*, *Starter Journal R27b*) **that exist nowhere in
that tree** — the other agent's. `strings` on the simulator's *installed
bundle* found them; `strings` on its own linked product did not. **A
`clean` and a `simctl uninstall` did not survive the next concurrent
install.**

**THE RULE: one simulator AND one `-derivedDataPath` per live session.**
And note what it costs a *reviewer*: convincing evidence for findings
that are not real.

**Also: every iPhone 16-series simulator on this machine is iOS 18.3,
below the iOS 26 deployment target, and is not a valid destination.** The
valid iOS 26.2 devices are the iPhone 17 family, iPhone Air, and one
*[removed for publication]*
implementers found it before my correction reached them.

## 11.5 WAITING ON HER

- **PROVISIONALs:** batch 5's seven (record §3) — the badge's short word,
  the starter-journal copy, the box's 11.5 pt type, starred inside the
  bound, and the **new one her ruling opened: blur-with-text collapses
  anyway** ("collapse only when empty" is equally defensible and is hers).
- **The architecture review's 2 MAJORs** — hers to slot.
- **R24** (`"more info"` → `"info"`) — the one undelivered batch-5 scope
  item, fenced in `Features/Write/`; exact three sites + two pins written
  out in its record. Minutes, for whoever next holds those files.
- **Her device queue grew by two:** MAJOR 2's "does it fire in her
  hands", and Read-mode memory at 100k on real hardware — **both batch
  naturally with PL-15's outstanding Face ID walk**, which is the same
  trip.

---

# §12. HER CAST RULING, 2026-08-30 (evening) — PARALLEL DEVELOPMENT ENDS; PARALLEL REVIEWS STAY

Her words, after the parallel bout landed:

> *"from now on, don't do the several subagents and parallel simulators /
> workers - my weekly limit has now reset and the overhead is no longer
> worth the increased effectiveness. fwiw, it also did not use many
> tokens at all. you can run the cold reviews in parallel if you'd like,
> but no more parallel development."*

**The ruling, precisely:**

| | |
|---|---|
| **Development batches** | **ONE AT A TIME.** Strictly sequential. Her 2026-08-23 one-subagent ruling is restored for build work |
| **Cold reviews** | **May run in parallel**, at the orchestrator's discretion |
| **Her stated reason** | The weekly limit reset, so wall-clock parallelism no longer buys anything worth its **overhead** — and she noted explicitly that the bout *"did not use many tokens at all"*, so **cost was never the objection.** The objection is coordination overhead: simulators, DerivedData, fences, merges, and the machinery corrections they demanded |

**What this retires:** worktree isolation for build batches, multi-simulator assignment for implementers, and the pre-merge-then-merge dance. **What it keeps:** the two machinery rules the bout proved (§11.3 pathspec-limited commits, §11.4 one simulator + one DerivedData per live session) — **these still bind wherever ANY two sessions are live at once, including two parallel reviewers in one tree, and including a Mac session running beside this one.**

## 12.1 SHE IS RUNNING 13u1 ON THE MAC IN PARALLEL WITH THIS ROUND

> *"I'm going to be starting 13ui shortly here on the mac side, but I
> think parallel work shouldn't be an issue while you move through these
> batches."*

**Her call, and it is a reasonable one** — different branches, different
surfaces. Two factual notes so nobody is surprised later, neither of them
an objection:

1. **13u1 IS the editor seam**, and mobile round 2's own editor-seam
   backlog was moved INTO it as its item 8 (`CrossBlockRefusal`'s hoist,
   the O(N²) twin, the gap fence's Mac face, the frozen-projection fan
   fence, the empty-block dead plan). Those live in `App/Variorum/Shared/`
   — **shared with the phone.** So the next `main` → `mobile` merge after
   13u1 closes is the one that can actually conflict, and it is the one
   to take carefully.
2. **13u1 also RULES semantics this round must not pre-empt** — the
   cross-block edit rules and, at item 9, the quick-capture ownership
   model that **batch 4.6 is explicitly waiting on** (§3 row 5b). Batch
   4.6 stays blocked until she has ruled, by her own instruction:
   *"it won't need a design sitting, the mac will have decided it."*

**Practical consequence for this round's remaining batches:** prefer work
that does NOT touch `Shared/EditorBrain/` or the cross-block planner
while 13u1 is live. The tray, the Two-rooms IA, the Library filters, and
the takes/book doors are all clear of it.

## POINTER 2026-09-02 (from the Mac side — the Act 10 correction round)

For §2b's handback checklist: **13u item 17 (the read-view edit jump) is BUILT on the Mac** by the correction round
(`Shared/LandingTarget.swift` — the one scrolled-open door, both halves, plus the paged faces' click; batch B/C/G
records in `notes/plans/act10-correction-round.md`). **13u was RE-SPLIT into FOUR** (13u1 seam · 13u2 feel · 13u3
faces · 13u4 restyle + dark) — the record is the 13u plan's 2026-09-01/02 banner; the mobile-shared items (2 · 4 ·
5 · 6 · 9) keep their homes inside those letters. Nothing else on the Mac side changed the checklist.

## 12.2 🔴 HANDED IN FROM THE MAC'S 2026-09-12 USE-REPORT ROUND — THE WRITE PAGE OPENS SHOWING NONE OF THE TEXT (her report; her ruling: the mobile session's, standalone or with 13u)

*(Written 2026-09-12 by the Mac round's Fable orchestrator, at her instruction the same day: "the mobile
bug can be noted and I can handle it in a separate variorum mobile session — that repo has its own
rules, if it's not shared. I would like you to write about it in the plans for that repo though, to be
completed as a standalone part or with 13u, if I work on mobile after 13u is done." The Mac round's
record is `notes/plans/use-report-round-2026-09-12.md` on `main` — ledger row 7, §4.9, her ruling R-Q9;
her report `notes/author-reports/2026-09-12-use-report.md`.)*

**Her words (2026-09-12, verbatim):** *"the mobile app also has this issue to an even worse degree where
it defaults to showing NONE of the written text lines, which also drives me insane."* — and at the
sitting she named the surface: **the Write page when a note opens** (not the takes browser sheet).

**What the Mac found about ITS twin (so the class is understood, not the code):** on the Mac the Takes
board scrolled her CURRENT block to the TOP of the viewport on every entry (`scrollTo(anchor: .top)`)
and the typewriter room — the clear extent below the last row — let the LAST block sit at the top with
nothing above it; a two-block note therefore opened showing only its empty third block. **Nothing of
that is shared code**: it is board code under `App/Variorum/Variorum/Features/Takes/`. The Mac's ruled
fix (R-Q1): a per-note scroll memory for the session, restored on entry, and a landing that REVEALS a
block only when it is off-screen, minimally — never a land-at-top.

**The phone's candidate mechanism (traced by reading on `main` at `3805e210`; unproven — the pin
decides):** the phone's Write page keeps a typewriter room as a BOTTOM INSET on its `UITextView`, and
its own code states the contract: *"the typewriter room's bottom inset already makes any block's top a
legitimate scroll target"* (`MobileEditorViewModel.jumpToBlock`, ~`:838–860`, the block-list jump). An
ARRIVAL that lands the caret at the note's END (`MobileWriteView`'s arrival — "the Today door's
straight-into-typing invitation", ~`:40`/`:162`) and reveals it therefore shows the room and no text —
the same CLASS as the Mac's, in the phone's own scroll (`contentOffset` on a `UITextView`; nothing in
`App/Variorum/Shared/` scrolls). Whether the keyboard's rise compounds it (the visible band shrinks to
the room above the keyboard) is the first thing to measure.

**The ruled shape (hers, from the Mac sitting — the phone builds its OWN version):** (1) opening a note
REVEALS the caret's line minimally — never lands it at the top — unless the note is being entered with
nothing remembered, in which case the page opens at the TOP; (2) the page's offset is remembered per
note for the SESSION and restored on re-entry (the Mac's `scrollAnchors` class); (3) the room stays.
Evidence of the kind: a pin on the arrival (a three-block note whose caret is in the last block opens
with block 1 visible — red on old), a pin on the memory, and a simulator walk with captures. **Fences:**
nothing in `Shared/EditorBrain/` (13u1's), nothing in the cross-block planner; the phone's own
`MobileEditorViewModel`/`MobileWriteView` arrival only.

**Where it runs:** at her word — as a standalone mobile unit, or folded into the mobile catch-up after
13u (this handoff's §12.1 says why the post-13u1 merge is the careful one). The Mac round's MOBILE
PARITY LINE is `notes/MobileSoul.md` §6 row **PL-22** on `main`.

### 12.2a · PASTE-READY KICKOFF for the standalone mobile unit (written 2026-09-12 at her ask; paste into a fresh session opened in `~/dev/variorum-mobile`)

> You are running ONE standalone mobile unit of the Variorum iPhone app: **the Write page opens showing none of the written text** — her 2026-09-12 report. Work in `~/dev/variorum-mobile` on branch `mobile` (verify: `git status -sb`, `git log --oneline -5`; `main` is NOT merged into `mobile` for this unit — do not merge, do not pull `main`). This is a fix unit, not the round's resumption: batches 5–8 and the owed reviews in this handoff's §3 stay where they are.
>
> **READ, YOURSELF, IN THIS ORDER:** `CLAUDE.md` · `notes/MobileSoul.md` (§3 the drift rule, §4.4, §6 the parity ledger) · this handoff's **§12.2** (the item: her words, the Mac twin's mechanism, the phone's traced candidate, the ruled shape, the fences) · §12.1 (why `Shared/EditorBrain/` and the cross-block planner are off limits while 13u1 is pending) · §10.4–§10.5 and §11.4 (the simulator and DerivedData rules) · §2 row "the accessibility flag on your simulator" · `notes/plans/mobile-round-2.md` §17–§20 (the M12 flicker row — the phone's arrival and reveal history) · `notes/SessionResiliencyProtocol.md`'s implementer half · the phone's Write arrival code: `App/Variorum/VariorumMobile/Features/Write/MobileWriteView.swift` (the arrival, ~`:40`/`:162`) and `MobileEditorViewModel.swift` (`jumpToBlock` ~`:838–860` — the room's stated contract; find the arrival's own caret placement and reveal), `MobileEditorTextView.swift` (the bottom inset / typewriter room).
>
> **THE RULED SHAPE (hers, from the Mac's 2026-09-12 sitting — SETTLED, build to it):** (1) opening a note REVEALS the caret's line minimally — never lands it at the top of the viewport — unless nothing is remembered for the note, in which case the page opens at the TOP; (2) the page's scroll offset is remembered per note for the SESSION and restored on re-entry; (3) the typewriter room stays exactly as it is. The Mac's twin defect was a `scrollTo(anchor: .top)` on the current block plus the room letting the last block sit at the top — the phone's is its own code (`UITextView` content offset); nothing in `App/Variorum/Shared/` scrolls, and nothing there may change.
>
> **PIN BEFORE FIX — no exceptions.** First TRACE the mechanism by running it, not by reading: a three-block note whose caret is in the last block, opened cold — capture where the page lands (the simulator's screenshot + the text view's `contentOffset` and `contentSize` at the settle, with and without the keyboard raised). Then write the red-on-old pin in `VariorumMobileTests` (the arrival lands block 1 visible when the caret is in block 3 with nothing remembered — measure the red number on the pre-fix code and record it), then fix, then green. A second pin for the memory (leave with block 2 at the top → re-enter → block 2 at the top). A pin green on both sides means the finding is hollow: record it, do not "fix" it.
>
> **RULES THAT BIND:** one simulator for this session, chosen by UDID from the valid iOS 26.2 devices (the iPhone 17 family, iPhone Air, the one iPhone 16e — the iPhone 16-series are iOS 18.3 and invalid), NEVER `booted`; arm its accessibility flag first (`xcrun simctl spawn <UDID> defaults read com.apple.Accessibility ApplicationAccessibilityEnabled` must be `1`, else `defaults write … -bool true`); one `-derivedDataPath` of your own; mobile tests via `xcodebuild test -project App/Variorum/Variorum.xcodeproj -scheme VariorumMobile -destination 'platform=iOS Simulator,id=<UDID>'` with suite-level `-only-testing:` and the `Test run with N tests` line read (Swift Testing counts skipped tests); the checkpoint protocol — commit per coherent piece, push `origin mobile` after every commit, a LIVE STATUS section in your record from the first commit (a new section `### 12.2b · RECORD` appended to this handoff), PENDING on every unverified claim, synchronous foreground waits only (poll a log; never end your turn awaiting a background run), no subagents beyond the standing one-at-a-time rule; NO `Co-Authored-By` / `Claude-Session` trailers; never rewrite history; path-scoped `git add`; nothing in `Shared/`, nothing in `Sources/`, no schema, no `Sync/`; no product invention — a decision the ruled shape does not make goes to `notes/QUESTIONS.md` at the next free number with 2–3 options, built PROVISIONAL.
>
> **THE ACCEPTANCE GATE IS USE:** a simulator walk with captures under a gitignored `notes/plans/mobile-write-arrival-screens/` — a long note opened cold shows its first lines; a note left scrolled mid-way re-opens there; the Today door's straight-into-typing arrival still lands the caret ready to type (the room intact); with the keyboard up the caret's line is visible. **THE REVIEW:** an Opus cold review is mandatory (the standing 17-entry rule: `notes/REVIEW_PROMPT.md` verbatim, a fresh agent with zero context from you, anchored on your record); a Fable review only if the diff touched the editor seam (it should not). **CLOSE:** the touched mobile suites + the phone's arrival/perf suites green, the record's dispositions (FIXED with the pin's name and the red-on-old numbers · DISMISSED AS HOLLOW · DEFERRED with an owner), `notes/MobileSoul.md` §6 row PL-22's mobile half flipped (on `main` — tell her; do not edit `main` from this session), and a one-paragraph report to her.
