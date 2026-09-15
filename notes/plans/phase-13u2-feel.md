# Phase 13u2 — FEEL (EXECUTION PLAN)

**Status: READY — THE CURRENT PHASE since 2026-09-15 (13u1 CLOSED that day; the baselines and the
"what changed under you" section below were refreshed at its closeout).** Authored 2026-09-14 at
the 13u1 kickoff (the R-cor-12 four-way split executed; the shared sitting's rulings live in
`phase-13u1-editor-seam.md`'s SITTING RECORD and **bind here** — 13u2 needs no sitting of its own
to start: R-13u-7 placed her feedback as items 18/19 and R-13u-10 ruled the book-Index set).
Opens at her word.
**The binding item record is the master plan's `### 13u` section** (items 1 · 2 · 10 · 11 · 13,
plus the 2026-09-14 items 18 · 19). Where this file and that section disagree, that section wins.

## Roster (R-cor-12's 13u2 list + what accrued since)

1. **Item 1 — non-editing pane stability ("the big one").** Trace-first discipline; TK2 geometry
   (TEXTKIT2 §2) is the SUSPECT, never the verdict; acceptance judged by her hands. The family,
   accrued:
   - the 13l hang lead (`PaneSurfaceRepresentable.updateNSView` re-entering — the capture named
     in the parent plan's item-1 text);
   - Act 10 correction rows **54** (read tier's provisional-width first measure) · **92** (canvas
     silhouette click lands mid-board) · **94** (Blocks' residual ~0.2–0.3 s arrival) · **98**
     (paged reader's paragraph over-count) · **100** (the flow's landing off after content creep);
   - **M12** (the gate-less insertion's honest re-render — the KnownIssues row this phase owns;
     `desyncRecoveryCount` is wired);
   - KnownIssues rows owned here: **the Outline's SHADOW second `InlineEditorSurface`** (the
     open-tail crystallization loss window is the sharpest reason to fix it) · **the
     `TakesArticleScroll` split** (owed three times, with the landing/hold residue on that row) ·
     **the re-font road's whole-storage jump** (the INK half was carved at 18j; the re-font half
     is this phase's) · **⌘A in a live take pane** · the harness rows kept here (the singleton
     geometry-oracle sweep; the masthead pin's fixed-turn-budget flake; the status seam's audit
     surface — J44's structural answer, the ~150-site rename + `private(set)` + the registry-walk
     shape).
   - **ITEM 18 — THE LONG-BOOK LANDING & SETTLE (author, 2026-09-14 — the master plan's item 18
     has her words verbatim):** the stutter-after-arrival on a far chapter/note click in the
     Sherlock book, and the two-stage jump (navigated to the chapter, THEN moved down to the
     note's start — "a bit jarring and sometimes I was moved too far"). **#88(c)'s trigger has
     now FIRED** — persist-per-story-measured-heights (option 2) is on the table with her own
     report as the evidence. One LIKE to preserve: a chapter sharing the book's name shows once
     in the navigator ("which I do like").
2. **ITEM 19 — THE BOOK-INDEX PRESENTATION SET (author, 2026-09-14; rulings R-13u-10):** the
   edited note must NOT take the whole palette wash in Index; the backdrop behind the cream read
   page stays white/neutral under every palette (refines #107/R-Q26 — the page stays cream AND
   its room on the Read surface stays quiet); the click-into-a-block INDENT defect (the live
   pane's geometry must match the read tier's from the first frame); the highlight grammar —
   the LEFT index highlight follows the editing cursor ALWAYS; the right-pane highlight on first
   click from the index column STAYS; whether the block being edited stays highlighted in the
   editor is a SETTING (compose with the R14/R22 editing-indicator family, do not mint a rival).
3. **Item 2 — the eager space-eater, BOTH platforms.** Trace the mechanism first
   (autosave/render trim? crystallization? text-checking?); the fix likely lands in
   core/`Shared` and reaches both.
4. **Item 10 — starred items scroll past ~7** (placement stays; bounded-list fix only).
5. **Item 11 — paste without newlines** (a paste-time transform, never a segmentation change;
   the chord from what is free; decide the PHONE's rule here too — one rule for a
   multi-paragraph clipboard).
6. **Item 13 — the note-title cutoff** (+ Act 10 row 93, the nameless title's prompt). MEASURED:
   no literal 30-char cap exists — find the real constraint; settle WITH item 4's card identity
   space (13u3) where they touch.
7. **P39a / P39b** — the two cross-feature defects (the carried section at this file's end).
8. **Verification duty from the re-homed protection items:** R-cor-12 re-homed the four
   launch-morning protection items to pre-13x (the typed near-empty confirmation #86(c) · the
   nudge-bar inset · the legs brain's SYNC leg + "extend" wording · COPY ALL on the recovery
   phrase). Pre-13x ran and REDESIGNED those surfaces (the loss-legs model deleted). At this
   phase's kickoff, VERIFY each is either built, moot by construction, or returns to this
   roster — record the verdict per item; #86(c)'s home was ruled "with the rebuilt Replace
   Keys" (#87's pointer).
9. **Row 57 stays OUT** (her R-cor-16 word — the Act 10 ledger row, not built here).

## What left this roster (so nobody re-derives it)

Item 17 (read-view edit jump) BUILT · row 60 (Blocks arrival blank) BUILT · item 4's Pool card
preview BUILT EARLY (all the Act 10 correction round) · item 6 (dark mode) SHIPPED at 18j ·
items 3/4/14/15/16 + item 9's face → 13u3 · the restyle continuation + its KnownIssues rows →
13u4 · item 12 → its own row (R-13u-5).

## Cast, evidence, discipline

Cast decided at its kickoff (CLAUDE.md; expected: Fable orchestrator/coordinator ·
`opus-implementer` per acceptance unit · `fable-reviewer` where the diff touches the editor
seam/pane authority, `opus-reviewer` otherwise). Every defect pinned red-on-old at its traced
mechanism; item 1 judged by HER HANDS on the dev-store build (captures); the space fix verified
on BOTH platforms; the checkpoint protocol restated in every implementer brief. Zero `Sync/`,
zero schema expected.

**BASELINES AT OPEN (13u1's finals, 2026-09-15 — the previous close's recorded result is the
baseline, and the full suite is never run at a session's START):**

| suite | number |
|---|---|
| core `swift test` | **1562 / 170**, all green |
| the FULL Mac suite | **2668 / 445**, ALL GREEN (726 s) |
| iOS build | **green** |
| the FULL mobile suite | **622 / 105 PASSED with 4 known issues** — the 2 standing (`MobileTrashTests`' accessibility-tree wrapper) + the converted tutorial pin's 2 (KnownIssues row 64, `withKnownIssue`; it trips loud if the app regresses) |
| lockstep marker | **8** |
| installed `/Applications/Variorum.app` | the 13u1 Release, refreshed 2026-09-15 (the exact hashes are in `notes/handoffs/phase-13u1-handoff.md`'s item 1) |

**Carry-forward flake rules, unchanged:** the differential-latency pin and `CanvasDragTrackingTests`
are LOAD-FLAKY (KnownIssues, owner 12) and get isolated re-runs before any conclusion; add
`MastheadLayoutTests`' open-field arm and `BlocksWorkbenchFaceTests`' single-click budget to that
list — the latter fired once under 13u1's full-suite load and was 4/4 green isolated. **Neither
load-flaky suite fired in 13u1's final runs**, so a red in either is news, not weather.

## WHAT 13u1 CHANGED UNDER YOU — read this before touching the editor

13u1 rewrote the seam this phase's item 1 and item 19 work beside. Six things to know:

1. **`finalizeWork`'s two waits are ONE loop** (`EditorViewModel`): the chain wait and the
   structural-latch wait re-ask each other until both are quiet, with an `awaited` marker so a
   completed-but-uncleared handle can never spin it. All four doors — quit, lock, seal, **teardown**
   — inherit it through that one call. If you add a road that can arm a compound or start a flight,
   it is already awaited; if you add a THIRD kind of pending work, add it to that loop, not beside
   it.
2. **The cross-block compound is the one road** (`Shared/EditorBrain/CrossBlockCompound.swift`).
   `#11a`'s visible-take edit and the 2026-07-09 merge-then-edit are RETIRED into it. Its grammar is
   the Blocks workbench's: ONE undo entry (`CrossBlockCompound.undoLabel`), exact-row redo, receipts
   that name where every block went. **One undo grammar, one refusal grammar — never two.**
3. **The refusal brain moved to `Shared/`** (`CrossBlockRefusal`) and gained causes
   (`.emptyTailAtSpanEnd` beside `.openTail`; the boundary-edge residual reworded). The Mac keeps
   three forwards in `CrossBlockRefusalRoads.swift` supplying the chord-bearing sentence. **Every
   cause must name a road that actually opens** — that rule cost the ladder two findings.
4. **`newBlock` registers structural undo** (R-13u-3). Type-time crystallization is its ONE named
   exception (`registeringUndo: false`) — and **test fixtures seed through `seedBlock` /
   `registeringUndo: false`**, because a fixture mint is not a gesture. If a new suite counts
   `stack.depth`, seed quietly or your numbers will include the fixture.
5. **The O(N²) class is CLOSED and the churn road is exact.** `BlockRangeIndex.entryRanges()` is the
   ONE accumulating walk — use it rather than `range(ofEntryAt:)` inside a loop (the class was swept
   to completion on both platforms and is pinned). Churn takes the EDIT's own cost, never a storage
   report's; `OrdinaryInputEdit.apply` is the ONE input-path door and `OneInputPathTests` fails the
   suite if a second gate call site appears.
6. **The mobile suite exits GREEN** — the tutorial red is wrapped in `withKnownIssue` citing
   KnownIssues row 64. Do not "fix" that pin: it comes right when the phone's LESSON does.

**What 13u1 handed this phase explicitly:** the `TakesArticleScroll` split (owed three times now),
the status seam's audit surface (~150 sites, the 18i ladder's MAJOR), the re-font road's viewport
jump (the INK half was carved at 18j), the Outline's SHADOW editor, the DEBUG-oracle keying sweep,
⌘A in a live pane, M12, and the two harness-calibration siblings above.

## Kickoff sketch (refresh at open)

Unit A — item 1's trace + the landing/settle family (incl. item 18) with measured evidence.
Unit B — item 19's presentation set + the shadow-editor fix. Unit C — the singles (2 · 10 · 11 ·
13 · P39a/b · the audit-surface rename). Ladder at phase end. The #88(b) book-opens-in-Outline
question, **#103 and 13u1's #109 (parts (a)–(d), incl. (d) which is hers to rule)** ride the
nearest sitting.

---

# CARRIED VERBATIM AT THE SPLIT (2026-09-14) — from `phase-13u-feel-and-polish.md` (P39's section, per its banner: "The file split must carry that section to 13u2")

## ADDENDUM 2026-08-30 (the pre-13u round, Act 2) — P39's two real defects join 13u2's roster

The cross-feature rule was REFINED in CLAUDE.md this day (pre-13u Act 2; the sweep's P39): the
prohibition now binds STATE AND OWNERSHIP — constructing or holding a sibling feature's view model,
calling its business logic, owning its lifecycle — while a view RENDERING a sibling's view is legal
composition, and shared components gained a binding placement clause (move to `Core/Views`/`Shared/`
at next touch). **The falsifiable check passed: both items below are still violations under the
refined rule** — which is what makes them 13u2's to fix rather than casualties of the clarification.

**13u2 gains two roster items** (both touch `RootView` composition and `@State` lifecycle — why they
land here, where that surface is already open, rather than in the pre-13u round):

- **P39a — break the `Library` ↔ `Pool` view-model cycle.** Pool stops holding `LibraryViewModel`;
  `duplicateAsVersion` and `archive` become closures passed by `RootView`. (Violates "never holds a
  reference to a sibling's view model.")
- **P39b — `Editor/WriteTakesPanel.swift:51` stops constructing `TakesViewModel`.** Construction is
  lifecycle ownership; `RootView` constructs, features receive. (Violates "never constructs.")

