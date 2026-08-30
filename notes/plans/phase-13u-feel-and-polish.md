# Phase 13u — Feel & Polish (EXECUTION PLAN)

> **⚠️ SPLIT BANNER (2026-08-26, the launch-strategy sitting — read
> this before the plan body).** The author SPLIT this row into TWO
> phases: **13u1 — the editor seam** (items 5, 7, 8, 9, 12) and
> **13u2 — feel & faces** (items 1, 2, 3, 4, 6, 10, 11, 13, 14, 15,
> 16 — items 14–16 joined 2026-08-25/26, after this plan was
> authored), with **ONE shared kickoff sitting** ruling both halves
> and 13u1 proposed first. Her words: *"it seems like 13u has gotten
> really really big for one phase... I feel like it's too big for one
> phase without at least one midphase cutover."* The binding split
> record is the master plan's `### 13u` section (its SPLIT block at
> the top). **The 13u1 kickoff's first act is executing this file's
> split** — this plan's execution shape (reading order, sitting
> agenda, batches, obligations) remains the raw material for both
> halves. Sequencing note: the intro below predates two
> re-sequencings — the running order now reads 13p → 13u1 → 13u2 →
> 13i → … with mobile catch-up post-launch.

>**ADDENDUM 2026-08-30 — the sweep fold.** Seven tech-debt items from
> the proactive sweep of 2026-08-30 were folded into **13u1** at the
> author's instruction; they live in the section **"Folded in from the
> proactive tech-debt sweep of 2026-08-30"** at the END of this file.
> They are deliberately NOT in the master plan's `### 13u` section
> (that document is product advancement only, per her same-day
> ruling), so the precedence rule above is intact and their absence
> there is by design. **The file split must carry that section to
> 13u1.** None of the seven has a red-on-old pin.

**STATUS: READY — authored 2026-08-24 during 13l's night watch and
FINALIZED at 13l's closeout the same day** (finals filled; the hang
lead in item 1 arrived from 13l's ladder). She runs this phase
immediately after 13l per her ruling (*"my highest priority should be
13l -> 13u"*; the order: 13l → 13u → mobile catch-up → 13p). Cast
decided at kickoff as always; expected `/architect-phase 13u`.

**THE BINDING ITEM RECORD IS THE MASTER PLAN'S `### 13u` SECTION**
(`notes/DetailedPlanForPhases.md`, immediately below the phase table —
THIRTEEN items, most in her verbatim words, several RULED in place).
This plan deliberately does NOT duplicate that section: it adds the
execution shape — reading order, the sitting agenda, batch structure,
obligations, verification. Where this plan and that section disagree,
THAT SECTION WINS (it is canon; this is choreography).

## Kickoff message (paste-ready)

> You are running **Variorum Phase 13u — Feel & Polish**, a
> CROSS-PLATFORM phase by construction (MobileSoul §6's "design
> together" class — mobile is IN the design sitting, ledger row PL-12;
> **after this phase, mobile must have NO known Mac or `Shared/` work
> left** — that is the stated point of the 13l→13u order).
>
> READ IN FULL FIRST: `CLAUDE.md` + the canon it loads · the master
> plan's `### 13u` section TOP TO BOTTOM (the binding item record —
> thirteen items, her words) · this plan · `notes/MobileSoul.md`
> (§6 especially) · `notes/plans/mobile-round-2-orchestrator-handoff.md`
> §2b (the handback rows U-1…U-5 and U-7 — this phase flips them) and
> §5 (the coordination flag: which mobile items are downstream of item
> 5's semantics) · the 13l closeout + `notes/handoffs/phase-13l-handoff.md`
> (what actually shipped under you — the trash surface, the L-items,
> the identity oracle and its macOS-26 widening finding in
> TEXTKIT2_NOTES §3, which touches this phase's editor-seam work
> directly) · `notes/KnownIssuesAndTechDebt.md`'s two rows pointing at
> 13u (M12; the O(N²) `planVisibleTakeEdit` row) — **closing this
> phase without resolving or re-owning them orphans them, which
> CLAUDE.md forbids** · for editor work: `notes/TEXTKIT2_NOTES.md` in
> full. Copy the P-1…P-9 constitution into this file verbatim if
> running under `/architect-phase`.
>
> OPEN WITH THE DESIGN SITTING (agenda below) — four-plus of the
> thirteen items are sitting-first, and mobile's deliverable is named
> INSIDE this phase at design time, never left as a parity row.
> Baselines: the section below, filled at 13l's closeout — verify with
> your own runs.

## How the thirteen items split (execution shape)

**SITTING-FIRST (her decisions gate the build):**
- **Item 1 — pane stability** ("the big one"): trace-first discipline —
  the TK2 geometry family (TEXTKIT2 §2) is the SUSPECT, not the
  verdict; the sitting sets the acceptance bar ("judged by her hands").
  **A CAPTURED LEAD ARRIVES FROM 13l's recovery walk (2026-08-24,
  ladder finding LR-MINOR-4's routing):** the app HUNG at 100% CPU in
  Takes mode (margin-grid, takes panel open) — clicks, menus and the
  AX tree all dead; the `sample` shows the main thread in SwiftUI
  lazy layout with `PaneSurfaceRepresentable.updateNSView`
  RE-ENTERING (`PaneSurface.swift:832`). One occurrence, unreproduced,
  candidate mechanism honestly unproven — the capture is
  `notes/plans/phase-13l-act7-screens/hang-sample-takes-margin-grid.txt`
  (gitignored dir on the machine) and the 13l plan's Act 7 record has
  the context. Start item 1's trace here rather than blind.
- **Item 5 — cross-block edits**: the semantics are ALREADY RULED
  (refusals open; edge-join merges mid-paragraph, not at a paragraph
  break; the fanned case ruled — fanned MIDDLE deletes whole to the
  tray, fanned EDGE touches the chosen take only; her auto-commit
  adopted as the SEVENTH quiet occasion; her condition: the previous
  blocks must be EASY TO SEE in lineage). The sitting settles the
  RESIDUE only: the paragraph-break detail (block seam vs internal
  newline — her rule reads as covering both), refuse-whole vs
  skip-and-report on a locked take, and whether item 5 promotes to its
  own batch row. **The 13l Act-3 finding binds here:** macOS 26
  attribute fixing WIDENS the post-fixing report (TEXTKIT2 §3) — any
  new stamping in this seam clamps to the verdict's range.
  **HER LEGIBILITY MANDATE (2026-08-24, the post-13l design sittings
  — binding on this item's sitting AND build):** the destination map
  — middles → Trash always; edges → lineage when merged, in-place
  when not — must be LEGIBLE: (1) every cross-block gesture's
  RECEIPT names where each block went ("2 blocks to the Trash; A and
  C merged — originals in the new block's History"); (2) the
  sitting weighs the destination map's TEACHABILITY as a first-class
  design constraint (her words: "at some point, the issue just is
  complex, but the tutorial needs to handle it well… i want to make
  sure someone owns it" — THIS ITEM owns it); (3) the tutorial's
  TWO-EXITS lesson (built by the post-13l polish round, its row 27:
  "deletion goes to the Trash; transformation goes to lineage")
  gets UPDATED by this phase to cover the fanned matrix it builds —
  her A/B/C×4-takes scenario is the sitting's worked example,
  recorded in the polish round's eleventh-sitting record. The
  recovery surfaces this leans on (the Trash, Block History's
  came-from with one-button restore) exist by then — the polish
  round builds them, which is what makes the liberalization honest
  (her 8d reasoning, completed).
  **HER INCLINATION, jotted 2026-08-24 — an inclination, NOT a
  ruling; her emphasis verbatim: "I still want the sitting though -
  I don't want to get into it too much here but might as well jot
  down where my thoughts are while it's present":** fanned EDGES
  remain their own blocks; and if the user is DETERMINED to merge
  them (*"mobile can't have the whole merge ceremony"*), the merge
  is ONE block carrying everything — *"the two chosen are now
  together in one block, each of their takes is now a take on the
  new block."* **The architect's mapping note: this IS the standing
  CARRY-ALL merge** (the phone's shipped C5 shape, adopted as the
  Mac's own quick fanned-merge default at 13j J4b) — the determined
  road would invoke it rather than refusing, zero new machinery.
  Her take-count example is illustrative, not binding (4+4 → 1
  merged + 6 carried). The sitting rules.
- **Item 9 — the quick-capture ownership model, BOTH platforms**: does
  a capture surface own ONE block or MANY; what ⏎ / shift-⏎ do; what
  the hand-off carries. The phone's lost-prose evidence (A5-2
  reopened, her "complete disaster" verdict) is in front of the
  sitting; **mobile batch 4.6 builds the phone's face to this ruling
  and does NOT re-decide it.**
- **Item 12 — multi-block paragraph drag** (missing on BOTH platforms,
  her walk's finding): the sitting decides in/out or own-row; if IN,
  the phone's half becomes a mobile row at that moment (the handback
  checklist is where it lands).
- **Item 13 — the title cut-off**: MEASURED pre-phase — there is NO
  literal 30-char cap; find the REAL constraint (likely a width
  constraint or `lineLimit(1)` in a frame) before changing anything;
  settle WITH item 4 (they share the card's identity space). Platform
  read: MAC (her landmark is the Scraps button) — flagged, hers to
  redirect; the phone's own title constraint gets one look while open.

**BUILD-DIRECT (ruled or defect-shaped; batch them):**
- **Item 2 — the eager space-eater (BOTH apps)**: trace the mechanism
  first (autosave/render trim? crystallization? text-checking?) — the
  fix likely lands in core/`Shared` and reaches both.
- **Item 3 — the comments-area rework** (the add box grows into the
  area it owns; the whole surface behaves like a text editor).
- **Item 4 — note-list skimmability, RULED**: the derived display-name
  snippet — ONE pure Domain brain (cap + word-boundary trim) serving
  the Mac library, MOBILE'S LISTS, and capture alike; journal cards
  stay date-led; the title-suggestion chip at capture; stored
  auto-title definitively rejected. Sitting residue: snippet length /
  ellipsis / typography only.
- **Item 6 — dark mode**: R51's direction (fully black in both
  voices); the PHONE's shipped dark mode is the look reference; token
  work shared.
- **Item 7 — the Mac's `MarkdownActs` arm-then-hand-off residual**:
  the MAC half of M1's root (E1 answered the iOS half on her device —
  PROVEN; do not reopen it). Rewrite the arm-then-hand-off sites so a
  verdict cannot be armed and abandoned — the same seam item 5
  rewrites; sequence them together.
- **Item 8 — the editor-seam backlog (mobile round 2's five)**: the
  frozen-projection fan fence (correctness half: never authorize from
  stale state; policy half follows item 5's ruling) · **the surviving
  O(N²) twin in `planVisibleTakeEdit`** (a live P1 breach — fix with
  the proven accumulation pass, pin equivalence, MEASURE, sweep the
  class to completion: every `range(ofEntryAt:)` caller in a loop,
  both platforms, each FIXED-with-pin or provably SAFE) · the gap
  fence's missing Mac face · the empty-block dead plan ·
  `CrossBlockRefusal`'s hoist to `Shared/` (the wording follows item
  5). **Plus M12** (the gate-less insertion's honest re-render — the
  KnownIssues row this phase owns; the counter is wired,
  `desyncRecoveryCount`).
- **Item 10 — starred items scroll past ~7** (placement stays; the
  bounded-list fix only — R27's shape).
- **Item 11 — paste without newlines**: a paste-time transform, never
  a segmentation change; the chord from what's free (⌘⇧V may be
  taken; ⌘⌥V her named alternative); **decide the PHONE's answer here
  too** (long-press/edit-menu; ONE rule for what it does to a
  multi-paragraph clipboard).

## The design sitting agenda (her decisions, bundled)

1. Item 9's ownership ruling (the phone's A5-2 evidence in view).
2. Item 5's residue (paragraph-break detail; locked-take shape;
   own-batch promotion).
3. Item 12 in/out (and the phone-half row if in).
4. Item 13's real constraint + the item-4 detail calls (snippet
   length, ellipsis, card typography) — settled together.
5. Item 1's acceptance bar and any reproduction recipes she has.
6. Dark-mode acceptance shape (her look reference; "no unreadable
   surface" is the bar).
7. ~~The suite-simulator switch~~ — **RULED 2026-08-24, the morning
   after 13l's close (author, via the question tool): SWITCH.** The
   test fleet standardizes on **iPhone 17 Pro** as a ONE-COMMIT
   re-baselining act at this kickoff — perf and geometry pins
   re-measured in the same commit, every moved number recorded. This
   is now the kickoff's first mechanical act, not a sitting question.
8. MOBILE'S DELIVERABLES named per item (2/4/5/6/9/11/12 are the
   both-platform set) — written INTO the batches, not parity rows.

## Batch sketch (the kickoff's to reshape)

Batch A: item 8's defect set + item 7 (the editor seam's correctness
half — pre-sitting-safe, none of it waits on rulings) — the O(N²)
sweep FIRST (a live P1 breach outranks polish). Batch B (post-sitting):
item 5 + the seam rewrites to its ruling. Batch C: items 2/4/10/11/13
(the small physical things + the one shared brain). Batch D: item 3 +
item 6 (the two visual reworks). Batch E: items 9/12 as ruled. Every
batch: both platforms' suites; the spine; red-on-old; the standing
loop.

## Obligations at close

- The KnownIssues rows M12 + the O(N²) row: RESOLVED or re-owned —
  never orphaned.
- The handback greps U-1…U-5, U-7 flipped and quoted (the mobile
  handoff §2b).
- **After this phase mobile has NO known Mac or `Shared/` work left**
  — state it as a checked claim, not a hope.
- The MobileSoul parity ledger: PL-12 answered INSIDE the phase.
- R16 → canon wording PROPOSED to her (reassigned here from mobile —
  obligation 12 of the mobile handoff; the phase that builds the
  behavior proposes; canon changes remain author-only).
- The closeout ritual in full (master plan, archives, QUESTIONS,
  handoff, /Applications refresh, the next plan authored at her pick).

## Baselines at open (13l's finals, written at its 2026-08-24 closeout — verify with your own runs)

core **1373/143** · Mac **1691/292 fully green** · Mac spine **63/8** ·
mobile **486/78** (2 recorded `withKnownIssue`s) · mobile spine
**33/7** · mirror at lockstep marker **7** · zero schema and zero
`Sources/VariorumCore/Sync/` lines all phase. Carry-forward flake
rules: the Phase-12 latency pin (`EditorWindowSmokeTests/
rewriteStrategyLatencies`) is intermittently red at its own budget —
re-run isolated before concluding anything; `CanvasDragTrackingTests`
holds at ONE recorded non-reproducing red (13l's disposition: a
second red promotes it to a KnownIssues row, owner 12). The installed
`/Applications/Variorum.app` is fresh as of 13l's close (2026-08-24
09:04).

## Environment

The 13j Environment traps bind verbatim (by reference —
`notes/plans/phase-13j-deletion-and-trash.md`); 13l's records add: the
identity oracle now runs per-keystroke in DEBUG on BOTH platforms
(expect it in any editor-seam work — it kills the process on identity
corruption, which is the point); the macOS-26 widening rule
(TEXTKIT2 §3) binds all attribute stamping.

## Folded in from the proactive tech-debt sweep of 2026-08-30 (13u1's inheritance)

**Origin, stated once so no future session has to reconstruct it.** These seven items come from a
proactive whole-codebase sweep run on 2026-08-30, immediately after 13p closed, at the author's
instruction — 18 independent cold review lenses over the tree, each finding then put to an
adversarial verifier instructed to REFUTE it by opening the real code (65 raw findings, 50 survived,
15 killed). The full artifact, with verbatim code evidence and each verifier's trace, is
**`notes/ProactiveTechDebtReview-2026-08-30.md`**; the P-numbers below are that document's.

**Why they are HERE and not in the master plan's `### 13u` section.** That section is canon and this
plan is choreography — where they disagree, that section wins. These items are deliberately absent
from it: the author's 2026-08-30 ruling keeps `DetailedPlanForPhases.md` for **product advancement**,
with tech debt and bug fixes living in plan files and in the standing-fix phase
(`notes/plans/phase-17-standing-fixes.md`). So the precedence rule is unchanged and these have no
counterpart there **by design** — they are not a silent divergence.

**They were routed here, and not to Phase 17, for one reason:** 13u1's item 5 rewrites this exact
seam, and the master plan's item 8 already carries the editor-seam backlog. `KnownIssuesAndTechDebt.md`
already uses this reasoning for the known `planVisibleTakeEdit` twin — *fixing it elsewhere would mean
fixing it twice.* Items P16, P17 and P22 are further members of exactly that O(N²) family; the
KnownIssues row's own instruction to **sweep the class to completion** (every caller of
`range(ofEntryAt:)` inside a loop, both platforms, each verdicted FIXED-with-a-pin or provably SAFE)
is what these three make concrete.

> **⚠️ NONE OF THESE HAS A RED-ON-OLD PIN.** Every one carries a traced mechanism and a file:line, and
> nothing more. Under the hallucination guard, step zero for each is the pin that fails on the
> pre-fix tree — not the fix. A pin that passes on both sides exposes the finding as hollow, and it
> is then dismissed and recorded as such rather than fixed. The sweep ran no code and measured
> nothing: the P1 claims below are traced-by-reading, calibrated against the two already-MEASURED
> twins in KnownIssues (23.8 s → 0.003 s at 20,000 entries), never benchmarked themselves. **Measure
> before believing a number, and pin before changing a line.**

### The O(N²) family — the keystroke road (P16, P17, P22)

These three complete the class the KnownIssues row opened. P16 and P17 are on roads that run on
every caret move and every keystroke respectively; P22 is on the Replace-All-in-Every-Take road.
**P1 is the one performance prohibition in the canon** — cost proportional to viewport and edit,
never to document size — so these are invariant violations, not slowness.

#### P16. StructuralGesturePlanner.seamPair is O(N^2) in block count and runs on every caret move and every keystroke (Mac)

`App/Variorum/Shared/EditorBrain/StructuralGesturePlanner.swift:419` · **MAJOR** · CONFIRMED · perf-p1 · sweep lens: shared editor brain · finder confidence 0.90

BlockRangeIndex.range(ofEntryAt:) (BlockRangeIndex.swift:74-81) walks the entries from zero on every call. seamPair calls it inside `for i in 0..<max(0, index.entries.count - 1)`, so the loop costs sum(i) = N^2/2 additions — and for a caret anywhere OTHER than a block seam (i.e. essentially always) no `i` matches, so the loop runs to completion every time. Cadence, traced end to end: EditorView.textViewDidChangeSelection (EditorView.swift:583-585) -> model.updateCaretContext() (EditorViewModel.swift:2493) -> refreshGestureAvailability() called unconditionally at EditorViewModel.swift:2532 -> enabled(.mergeBlocks) -> StructuralGesturePlanner.plan(.mergeBlocks, …) -> merge(selection:world:) with selection.length == 0 -> seamPair. storageDidEdit also ends in updateCaretContext() (EditorViewModel.swift:1079), so it fires per keystroke as well as per arrow key. At the author's stated 100k-word bar (~1,400 paragraphs) that is ~980,000 main-actor inner iterations per caret move; at the 20,000 entries this repo's own perf pin adopts as its ceiling, ~2e8 — the same class as the twin CrossBlockEditPlanner.swift:141-153 records as measuring 23.8 s for one plan before it was fixed. The sibling separatorPair (line 407) has the identical shape on the same enablement road. Mac-only: the phone reaches the planner solely from an explicit gesture (MobileStructural.runSpanGesture:337-357), never from a caret change.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Every link verified. BlockRangeIndex.range(ofEntryAt:) (BlockRangeIndex.swift:74-81) walks entries from zero on each call; seamPair (StructuralGesturePlanner.swift:417-425) calls it inside `for i in 0..<max(0, index.entries.count - 1)` with NO break, so a caret anywhere but a seam runs the full N^2/2. The cadence is unconditional: refreshGestureAvailability (EditorViewModel.swift:2015-2038) evaluates enabled(.mergeBlocks) as part of the GestureAvailability initializer -> plan(.mergeBlocks) -> merge(selection:world:) -> with selection.length == 0 -> seamPair (planner lines 345-352); updateCaretContext calls refreshGestureAvailability unconditionally at line 2532 and is reached from textViewDidChangeSelection (EditorView.swift:583-585) AND from the end of storageDidEdit (EditorViewModel.swift:1079). Only the tail-region and sealed guards can return earlier, and neither covers ordinary in-block typing. The constant is the repo's own: CrossBlockEditPlanner.swift:141-153 documents the IDENTICAL loop shape measuring 23.8 s at 20,000 entries and ~100 ms per keystroke at the author's ~1,400-paragraph bar — and this road fires on every arrow key, not only on cross-block edits. Note the codebase's other helpers (entryTouching:448, entriesIntersecting:461, the twin's fixed pass) all use a single accumulating walk, which is exactly the proven remedy. The call-site comment at EditorViewModel.swift:2529-2531 does assert the opposite cost, and the corroborating site is real: EditorSurfaceController.applyDifferential (lines 104-107) calls range(ofEntryAt: i) inside its stride loop under a comment claiming 'Cost ∝ changed blocks, never the post'. Two corrections to the finding's framing, neither refuting it: separatorPair (line 407) guards `selection.length == 1` FIRST, so it exits in O(1) for essentially every selection and is not a live hot path; and the CLASS is not unowned — KnownIssues' planVisibleTakeEdit row (owner 13u1) explicitly prescribes sweeping 'every caller of that accessor inside a loop, on both platforms, each verdicted FIXED-with-a-named-pin or provably SAFE', which this instance falls squarely inside. The marginal news is therefore the instance's identity and its hotter cadence, not the class. Severity held at MAJOR: P1 is violable here by the letter (cost ∝ block count, quadratically, on the caret/keystroke road) with a measured ~100 ms at the project's own stated document bar, but the felt cost at ordinary note sizes (a few hundred blocks) is microseconds, so it is not BLOCKER-class.

*No red-on-old pin exists.* Full evidence quotes and the verifier's own trace are in `notes/ProactiveTechDebtReview-2026-08-30.md` under P16.

#### P17. applyDifferential walks the block index from zero for every slot — O(N²) in blocks on BOTH platforms' live editors, unguarded

`App/Variorum/Variorum/Features/Editor/EditorSurfaceController.swift:107` · **MINOR** · CONFIRMED · perf-p1 · sweep lens: architecture conformance · finder confidence 0.90

BlockRangeIndex.range(ofEntryAt:) walks `entries` from index 0 on every call (BlockRangeIndex.swift:74-81; `entries` is a stored array at :36, no memoization), so the call is O(i). Both live editors call it unconditionally once per slot inside a loop over every slot, with no guard and no accumulation: EditorSurfaceController.swift:103-111 and MobileEditorViewModel.swift:658-666. Concrete path: open a post with N blocks; any store projection whose block/variant sequence is unchanged routes to `.differential` via EditorProjectionPolicy, and the loop then performs Σi ≈ N²/2 entry-walk steps on the main actor before comparing a single character. N=500 blocks ⇒ ~125,000 iterations per projection apply; N=5,000 (AppSpec §4's contemplated 100k-word single post) ⇒ ~12.5M iterations, tens of ms of main-actor stall, at autosave-settle cadence. Cost is proportional to document size, which is P1's one prohibition. A third, lower-severity site is ReadPostViewModel.swift:218 — same loop shape but a text-inequality `continue` above it reduces it to O(N × changedSlots), quadratic only when a sync pull lands many slot texts of one post at once.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Code claims verified verbatim. BlockRangeIndex.range(ofEntryAt:) (App/Variorum/Shared/EditorBrain/BlockRangeIndex.swift:74-81) walks `entries` from 0 with no memoization; EditorSurfaceController.swift:104-111 and MobileEditorViewModel.swift:658-666 (actual path App/Variorum/VariorumMobile/Features/Write/) both call it once per slot in a loop with no continue-guard, so the walk is Σi ≈ N²/2. ReadPostViewModel.swift:218 does carry the text-inequality `continue` above it, exactly as the finding says. The in-repo remedy precedent is real (IdentityProjectionAudit.swift:69 does the running-location walk and names the same O(entries²) reason; CrossBlockEditPlanner.swift:141-153 the same). BUT TWO OF THE FINDING'S CLAIMS ARE REFUTED. (1) The road: 'any store projection whose block/variant sequence is unchanged routes to .differential' is wrong. EditorProjectionPolicy.decide (EditorProjectionEngine.swift:146-157) pins the precedence not-loaded ▸ busy ▸ forced ▸ ECHO ▸ DELIVERY-REFETCH ▸ same-sequence ▸ full — so every ValueObservation delivery goes .refetchFresh, and every autosave echo goes .adoptEcho (the ledger's zero-surface-read match). .differential fires only on a fresh non-delivery read whose text genuinely differs: a take switch (sameSequence compares blockIDs only), restoreCommit, a sync landing. That is not 'autosave-settle cadence'. (2) 'named nowhere': KnownIssuesAndTechDebt.md's planVisibleTakeEdit row owns this exact accessor-in-a-loop CLASS at 13u1 and its remedy text mandates sweeping 'every caller of that accessor inside a loop, on both platforms' — these sites fall inside that named owner's mandate, so already_known is understated. Severity down to MINOR: no user-visible wrong behaviour, and the quadratic term only bites at thousands of blocks in ONE note, on a non-keystroke road. Worth noting as a bonus the reviewer missed: the same loop calls model.viewText(range) for every slot, so the function is O(document chars) regardless of the accessor — its own doc comment 'Cost ∝ changed blocks, never the post' is inaccurate on both counts.

*No red-on-old pin exists.* Full evidence quotes and the verifier's own trace are in `notes/ProactiveTechDebtReview-2026-08-30.md` under P17.

#### P22. `replaceInEveryTake` is O(matches × blocks²) — `range(ofEntryAt:)` called inside a nested loop on the Replace-All-in-Every-Take road

`App/Variorum/Variorum/Features/Editor/EditorSurfaceController.swift:2056` · **MINOR** · CONFIRMED · perf-p1 · sweep lens: Mac editor feature · finder confidence 0.85

`BlockRangeIndex.range(ofEntryAt: i)` walks from entry 0 on every call (BlockRangeIndex.swift:74-81), so it is O(i). `replaceInEveryTake` calls it inside `for i in entries.indices` which is itself inside `for item in plan`, making the placement pass O(M·N²) for M approved matches over N blocks. A 500-match Replace All over a 5,000-block book is ~6×10⁹ iterations on the main actor. KnownIssues already owns this accessor's class at 13u1, but names only `planVisibleTakeEdit` (same file, line 1819-1820), which is O(N²) on a deliberate gesture; this third-factor instance on the ⌘F takes-scope road was never enumerated, and the row's remedy explicitly demands the class be swept to completion.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Code confirmed: BlockRangeIndex.swift:74-81 walks from entry 0 on every call (O(i)), and EditorSurfaceController.swift:2053-2057 calls it as `model.index.range(ofEntryAt: i)` inside `for i in entries.indices` inside `for item in plan`. The inner loop breaks on placement, so the true cost is O(Σ_items k_item²) — worst case O(M·N²) — and it runs on the main actor. Real, and it is a genuine member of the accessor class KnownIssues already tracks. Two corrections to the finding as written: (a) the stated scale is overstated — the find bar and this index describe ONE note's rendered blocks, not a whole book, so N is blocks in a post (a 5,000-block post is a 100k+-word single note, the escape-hatch case AppSpec §4 explicitly parks); (b) it is not un-owned — the KnownIssues `planVisibleTakeEdit` row's remedy already binds the fix to be "swept to completion — every caller of that accessor inside a loop, on both platforms", which covers this site by construction, so the finding's value is enumeration of an unnamed instance rather than a new problem. MINOR is right; it is not a common-road P1 breach at realistic post sizes, and the reviewer's own already_known flag is honest.

*No red-on-old pin exists.* Full evidence quotes and the verifier's own trace are in `notes/ProactiveTechDebtReview-2026-08-30.md` under P22.

### The churn pair — the 80%-sort is defeated by the widening rule (P24, P25)

Two findings, one mechanism, reported independently by the shared-editor-brain lens and the
Mac-editor lens — which is corroboration, not duplication. **This is the most consequential
correctness bug in the sweep's editor half:** `last_major_revision_at` exists so that fixing one typo
never reshuffles the library (AppSpec §10, and CoreDescription pillar 7 — *"sane sorting"*), and it is
computed from a report that macOS 26 widens to the whole paragraph. The widening is not a surprise:
it is measured and recorded in `notes/TEXTKIT2_NOTES.md` §3, whose stated rule — **clamp to the
VERDICT's range, never the report's** — this code does not follow.

#### P24. The Mac computes churn from the WIDENED NSTextStorage report, so a typo fix inside existing prose stamps last_major_revision_at

`App/Variorum/Variorum/Features/Editor/EditorViewModel.swift:1148` · **MAJOR** · CONFIRMED · correctness · sweep lens: shared editor brain · finder confidence 0.90

storageDidEdit receives the SAME didProcessEditing report the repo's own pin measures as widened: EditorView.swift:588-598 forwards the .editedCharacters callback, and IdentityProjectionAuditTests.appKitWidensAnInsertionsReportedRangeToTheParagraph pins that typing one character at offset 2 of "Alpha\n…" reports {2,5} with delta +1. recordAutosave then computes oldLength = editedRange.length - delta = 4 and charDelta = oldLength + editedRange.length = 9 for a 1-character edit — a 9x overcount; in general ~2 x (characters from the caret to the paragraph end). AutosaveCoordinator.record sums those (Shared/AutosaveCoordinator.swift:113) and passes the sum to ops.autosave (line 157), which reaches Operations.registerTextChange -> Churn.accumulate (Operations+Variant.swift:446-457) and stamps last_major_revision_at + rebaselines baseline_length on crossing. Concrete: a 5-block x 400-char note (baseline_length 2000, threshold 0.8 => 1600). Fixing a typo at offset 10 of block 1 reports ~{10,392} per keystroke => charDelta ~783. THREE keystrokes = 2349 >= 1600 => last_major_revision_at stamps and the post rebaselines. True churn for those three keystrokes is 3 (ratio 0.0015). The shared brain already carries the fix and the Mac never adopted it: ArmedEdit.exactCost (Shared/EditorBrain/EditorEditRouting.swift:62) is read only by MobileEditorViewModel (lines 1438, 1458, 1547 — `charDelta: exactCost ?? (oldLength + editedRange.length)`); `grep -rn exactCost App` shows zero Mac consumers.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Traced end to end in the real source. EditorView.swift:588-598 forwards the .editedCharacters didProcessEditing report to EditorViewModel.storageDidEdit; on a .block(i) verdict (line 1034) it hands the SAME editedRange/delta to recordAutosave, which computes `oldLength = editedRange.length - delta` and `charDelta: oldLength + editedRange.length` (EditorViewModel.swift:1145-1148) — i.e. 2*reportedLength - delta. The widening is pinned in-repo ON THE PRODUCTION CONFIGURATION: IdentityProjectionAuditTests.appKitWidensAnInsertionsReportedRangeToTheParagraph installs a spy on the same didProcessEditing callback inside `withEditor`, which builds the real EditorTextView.makeEditor() + real EditorSurfaceDelegate (EditorTestSupport.swift:183-186), and asserts a 1-char insert at offset 2 reports {2,5} — so charDelta = 9 for a true cost of 1, and the overcount scales with the distance from the caret to the paragraph terminator. The cost then flows AutosaveCoordinator.record (sums, Shared/AutosaveCoordinator.swift:106-113) -> flushNow -> ops.autosave -> Operations.registerTextChange -> Churn.accumulate -> stamps lastMajorRevisionAt and rebaselines baselineLength (Operations+Variant.swift:436-461); nothing on that road normalizes the cost. The shared fix exists and the Mac genuinely never reads it: `grep -rn exactCost App Sources` returns only EditorEditRouting.swift:62 (the definition) and four MobileEditorViewModel lines. Every other Mac charDelta call site computes an exact cost (BlockTOCView:172, TakesViewModel:576, CanvasViewModel:682, EditorFind, EditorSurfaceController:1872/1961/1975), so the keystroke road is the sole report-derived one. Not a documented acceptance: exactCost's own comment frames the widening as what "iOS applies", which pre-dates 13l's macOS-26 measurement (TEXTKIT2_NOTES records that measurement as FALSIFYING the earlier 'AppKit does not widen'), and KnownIssues carries no churn row. The stamp is user-visible through BookOrderAndConversion.swift:51 ('Major revision ↓'), TimelineView.swift:26, and ReadingAssembly.swift:380, which is exactly the sort CoreDescription pillar 7 / AppSpec §10 exist to keep meaningful. Severity held at MAJOR: wrong behaviour a user reaches on a real sort, defeating a named product pillar, but no data loss or corruption (churn is a counter, and SyncSpec's merge matrix already treats it as approximate under sync).

*No red-on-old pin exists.* Full evidence quotes and the verifier's own trace are in `notes/ProactiveTechDebtReview-2026-08-30.md` under P24.

#### P25. Mac churn cost is derived from AppKit's WIDENED edited-range report, so one keystroke inside a block over-reports churn by ~2× the paragraph tail

`App/Variorum/Variorum/Features/Editor/EditorViewModel.swift:1145` · **MAJOR** · CONFIRMED · correctness · sweep lens: Mac editor feature · finder confidence 0.90

`recordAutosave` computes `charDelta = (editedRange.length - delta) + editedRange.length` from the RAW NSTextStorage report. This repo's own pinned measurement (`IdentityProjectionAuditTests.appKitWidensAnInsertionsReportedRangeToTheParagraph`) proves macOS 26 attribute fixing widens an insertion's report to the paragraph end INCLUDING the terminator: typing "X" at offset 2 of block "Alpha" reports {2, 5} with delta 1. So charDelta = (5-1) + 5 = 9 for an edit whose true cost is 0 deleted + 1 inserted = 1. Generalised: a 1-char insertion at intra-block offset p in a paragraph of length M reports ≈ 2·(M − p + 1) − 1, so one character near the start of a 500-char paragraph reports ~1000 instead of 1. AutosaveCoordinator.record sums these across the debounce window; Operations.autosave → registerTextChange → Churn.accumulate then stamps container.last_major_revision_at and rebaselines once churn/max(baseline,1) ≥ 0.8 (Operations+Variant.swift:23-25, 446-459). Result: a few typo fixes inside long paragraphs stamp the note as majorly revised, collapsing reading.sort_field='last_major_revision' into 'last_touched'. The exact value already exists — ArmedEdit.exactCost (range.length + replacementLength) — and `storageDidEdit` computes the bound ArmedEdit at line 1000 but never passes it down; grep -rn exactCost App/ returns zero Mac hits while MobileEditorViewModel.swift:1547 consumes it (`charDelta: exactCost ?? (oldLength + editedRange.length)`). 13l applied the clamp rule to the attribute stamp two lines above (`stampProjection(... within: entryRange)`) and not to the arithmetic. No test drives the real typed path and asserts the recorded cost.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Traced end to end. EditorViewModel.swift:1144-1148 (`recordAutosave`) computes `charDelta: oldLength + editedRange.length` from the RAW report, where `oldLength = editedRange.length - delta`. The report reaching it is the NSTextStorageDelegate `didProcessEditing` range (EditorView.swift:588-599 → `model.storageDidEdit`), which is exactly what IdentityProjectionAuditTests.swift:258-281 measures with a temporarily-swapped spy on the SAME single storage delegate, driven through the real AppKit road (`EditorTestSupport.swift:98` — `textView.insertText`): a 1-char insert at offset 2 of "Alpha" reports {2,5}, delta 1 ⇒ charDelta 9 for a true cost of 1. TEXTKIT2_NOTES.md records this as the pinned macOS 26 finding that FALSIFIES the earlier "AppKit does not widen" belief, and 13l's stated rule ("clamp attribute stamps to the VERDICT's range, never the report's") was applied only to `stampProjection` two lines above, not to the arithmetic. The over-reported value is real currency: AutosaveCoordinator.swift:113 sums it across the debounce window, Operations+Variant.swift:16-27 passes it to `registerTextChange` (:438-461), which folds it into `Churn.accumulate` and, on crossing the 0.8 threshold, stamps `container.last_major_revision_at` and rebaselines. Generalised: a 1-char insert at offset p in a paragraph of pre-edit length M records 2(M−p)+3, so a typo fix near the start of a long single-paragraph note can cross the threshold on a SINGLE keystroke — directly defeating CoreDescription §7 ("Fixing one typo must never reshuffle the library"). The corrected value already exists and is hoisted: `ArmedEdit.exactCost` (Shared/EditorBrain/EditorEditRouting.swift:58-62), whose own doc says "Platforms that derive cost from the report simply never read it (the Mac)" — but that comment predates the macOS-26 widening measurement, so it documents the Mac's non-use, not an accepted over-report. grep confirms the only consumers are MobileEditorViewModel.swift:1438/1458/1547; zero Mac hits. Other Mac autosave call sites (TakesViewModel:576, CanvasViewModel:682, BlockTOCView:172) pass their own computed cost — the Write editor is the outlier. No test in VariorumTests asserts a charDelta recorded from the real typed path. Severity MAJOR stands: common road (any mid-block edit), silent corruption of a canonical persisted sort value, no crash or text loss.

*No red-on-old pin exists.* Full evidence quotes and the verifier's own trace are in `notes/ProactiveTechDebtReview-2026-08-30.md` under P25.

### Two forked brains — and a canon correction (P40, P41)

Folded in at the author's word (*"since P40/41 are cheap, might as well fold them in"*) rather than
routed to Phase 17. Both are MobileSoul §3's drift class, and the fix is always a **hoist to
`App/Variorum/Shared/`, never a patch** — with both platforms' pins riding unmodified, since a
zero-test-edit suite is the proof the hoist moved an address and not a behaviour.

**These also correct canon.** `KnownIssuesAndTechDebt.md`'s forked-brain row carries an *"eight-brain
table"* it presents as a grep-verified complete enumeration as of 2026-08-21. It is not complete:
P40 and P41 name brains absent from it. **Whichever phase lands these must amend that row's
enumeration** — a stale completeness claim is worse than no claim, because the next session trusts it.

#### P40. Shelf ORDER and smart-book tag brains are a byte-identical Mac/mobile fork, and are absent from KnownIssues' "eight brains" enumeration that claims to be complete

`App/Variorum/VariorumMobile/Features/Shell/MobileShelfFaces.swift:101` · **MINOR** · CONFIRMED · drift · sweep lens: mobile app · finder confidence 0.90

`MobileShelfFaces.ordered(books:pins:)` (MobileShelfFaces.swift:101-114) and `ShelfViewModel.ordered(books:pins:)` (App/Variorum/Variorum/Features/Shelf/ShelfViewModel.swift:81-96) are the same statements in the same order — pins collected in pin order, then `rest` split on `profile == "journal"` and each half sorted by `reading.name`. Neither delegates to the other; neither lives in App/Variorum/Shared/ or VariorumCore/Domain. The same holds for `MobileShelfFaces.tagPaths(for:curatedTags:)` (:44-54) vs `ShelfViewModel.tagsColumn(for:)` (:103-112) — identical `querySpec` JSONDecoder walk and `(spec.tagsAll ?? []) + (spec.tags ?? [])`. KnownIssuesAndTechDebt.md's forked-brain row asserts "THE CURRENT ENUMERATION is the parity inventory's EIGHT-brain table … every symbol grep-verified 2026-08-21" and lists ThemeStore, applyTypedPath, CalloutPalette, CalloutMenu.rows, the five deletion-copy homes, TakeClipboard, BlockSelection, TakesReplacePlan — neither shelf symbol appears, so these two sit under no owner and falsify the row's completeness claim. Concrete divergence path: the master plan's 13i row carries her ruling "CUSTOM SHELF ORDER MUST BE ADDED"; a phase editing `ShelfViewModel.ordered` to honour a stored custom order leaves `MobileShelfFaces.ordered` on R38's pin-then-journal-then-name rule, and the phone's shelf silently disagrees with the Mac's about the order of the same books, with a green suite on both sides.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> The code claim checks out exactly. `MobileShelfFaces.ordered(books:pins:)` (MobileShelfFaces.swift:99-112) and `ShelfViewModel.ordered(books:pins:)` (ShelfViewModel.swift:81-95) are the same statements in the same order, both ending `return pinned + journals + others`; neither delegates, neither lives in App/Variorum/Shared/ or VariorumCore. `MobileShelfFaces.tagPaths` (:41-54) and `ShelfViewModel.tagsColumn` (:103-113) share the identical `SmartQuerySpec` decode + `(spec.tagsAll ?? []) + (spec.tags ?? [])`, differing only in where the curated aggregate comes from. Both sides carry their own pins (MobileShellTests.swift:99; the Mac's own) and there is no cross-platform drift pin. Two corrections that pull the severity down hard. (1) The completeness claim is over-read: the parity inventory's table is scoped "Building the faces above adds these" (mobile-round-2-parity-inventory.md, §4(c) preamble) — it enumerates the brains that ROUND's faces would need, not every fork in the tree. (2) The KnownIssues row owns the CLASS with a named owner, and its standing rule — "any Mac phase touching one of these brains hoists it THEN" — is what would fire at 13i, so "sits under no owner" overstates it; what is true is that these two symbols are untracked. Nothing behaves wrongly today and the divergence is contingent on a future phase, so this is debt, not a MAJOR.

*No red-on-old pin exists.* Full evidence quotes and the verifier's own trace are in `notes/ProactiveTechDebtReview-2026-08-30.md` under P40.

#### P41. Read's markdown-paragraph brain and the link-scheme guard are duplicated on the phone, against MarkdownLink's own "one rule, one guard, one door" declaration

`App/Variorum/VariorumMobile/Features/Read/MobileReadPage.swift:131` · **MINOR** · CONFIRMED · drift · sweep lens: mobile app · finder confidence 0.85

`MobileReadPage.openableLink(_:)` (MobileReadPage.swift:131-141) re-implements `MarkdownLink.openable(_:)` (App/Variorum/Variorum/Features/Formatting/MarkdownLink.swift:31-39) statement for statement, including its own `openableSchemes: Set<String> = ["http", "https"]` at :129. `MobileReadPage.paragraphs(of:codeTint:)` (:76-106) and `container(for:codeTint:)` (:108-124) are likewise byte-identical to `FlowParagraph.paragraphs`/`container` (App/Variorum/Variorum/Features/BookView/ReadingFlowView.swift:209-269), as is `MobileReadPage.Paragraph.indent` vs `FlowParagraph.indent`. MarkdownLink's header states the invariant this breaks: "Three surfaces open links and they must agree … One rule, one guard, one door" and "Widening this is one line" (QUESTIONS #50 is a build-time call). There are now four surfaces and two rules. Concrete divergence: a phase that widens the Mac set (say to `mailto`) changes MarkdownLink.openableSchemes and the Mac's three surfaces follow; MobileReadPage keeps `["http","https"]`, so the SAME stored note renders its link as tappable on the Mac and as inert text on the phone, with nothing failing. The same shape applies to any change in the run-walk or emphasis mapping in `container`.

**The verifier's check — and its tempering.** *(The paragraph above is the FINDER's
claim. This is the adversarial verifier's own trace, and where the two differ THIS ONE
WINS — it was written with the real code open and with instructions to refute.)*

> Verified in both files. `MobileReadPage.openableSchemes` + `openableLink` (MobileReadPage.swift:129-141) reproduce `MarkdownLink.openableSchemes` + `openable` (MarkdownLink.swift:27-39) statement for statement — same trim, same scheme set, same `url.host?.isEmpty == false`. `MobileReadPage.paragraphs(of:codeTint:)` (:75-105) and `container(for:codeTint:)` (:107-123) likewise reproduce `FlowParagraph.paragraphs`/`container` (ReadingFlowView.swift:209-268) including the concatenation walk and the emphasis→`InlinePresentationIntent` mapping; only the final line differs (`openableLink(raw)` vs `MarkdownLink.openable(raw)`). Both consume the shared `MarkdownRendering`, so only this presentation layer is forked. The guard half is pure Foundation (only `open(_:)` needs AppKit), so it is hoistable, and the phone's own comment concedes the shape ("`MarkdownLink.openable`'s rule, mirrored"). Same class as finding 3, and MINOR is the right size: the drift is latent, no user-visible wrong behavior today. Note the finding slightly over-reads MarkdownLink's header — "three surfaces" enumerates the MAC surfaces of one app target, not a cross-platform invariant.

*No red-on-old pin exists.* Full evidence quotes and the verifier's own trace are in `notes/ProactiveTechDebtReview-2026-08-30.md` under P41.

### What this section obliges at 13u1's close

1. Each of the seven is **verdicted explicitly** — FIXED (with its named red-on-old pin), DISMISSED
   AS HOLLOW (the pin passed on both sides — recorded, not fixed), or DEFERRED with a named owner.
   Silence on any one of them is an incomplete closeout.
2. The O(N²) family's sweep-to-completion runs to its end: every `range(ofEntryAt:)` caller inside a
   loop on **both** platforms verdicted FIXED-with-a-pin or provably SAFE, and the KnownIssues row
   closed or narrowed to what actually survives.
3. The forked-brain row's eight-brain enumeration is **amended**, not left claiming completeness.
4. Any item this phase declines is recorded in `KnownIssuesAndTechDebt.md` with an owner, per that
   file's rule — never dropped back into the sweep artifact, which is a dated snapshot and not a
   tracking surface.
