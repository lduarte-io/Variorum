# 18l-b — NAVIGATION FEEL, SECOND HALF (opened 2026-09-26 at her paste of the kickoff)

**STATUS: OPEN — U2 in flight.** Orchestrator: Fable (`/architect-phase 18l-b`, a FRESH seat per
R-18l-3's declared split). **The CLOSED first-half record is `notes/plans/phase-18l-navigation-feel.md`**
(U0 · U0b · U0c · U-VIS · U1 — its SITTING RECORD R-18l-1…R-18l-5, ENVIRONMENT TRAPS, unit records and
acceptances BIND here unchanged); **the ratified charter is `notes/plans/post-13u-health-rounds.md`
KICKOFF 2** (U2/U3/U4's unit text lives there and is not duplicated here). This file is the running
record for the second half and must stay readable in full (the reading rule).

**The half in one sentence:** finish the landing subsystem's perimeter — Takes' landing half onto the
ONE authority (U2), PanePublisher's ratified frame-synchronous/state-deferred shape under her
walk-and-revert gate (U3), the one-liners (U4), and the B5 trace (KnownIssues row 88) — so she can
*"click around everywhere with no issues."*

---

## HER KICKOFF MESSAGE (2026-09-26, verbatim — the binding mandate for this half)

> You are the FRESH Fable orchestrator for 18l-b — the navigation-feel round's second half, split from
> 18l at my ruling R-18l-3 (run all, split if heavy after U1; the split fired at my 2026-09-26
> check-in). Open your own record file at notes/plans/phase-18l-b-navigation-feel.md — the 18l file is
> the CLOSED first-half record; keep both readable in full.
>
> [Preflight list — executed in full, LIVE STATUS row 1.]
>
> Your scope: U2 — Takes' landing half adopts LandingAuthority (the aim kind grows: top ·
> minimal-reveal · viewport-fraction); the restore half is BYTE-PRESERVED (my rulings R-Q20/R-Q21) and
> the ~15 gesture-end pins + the projection arm ride UNMODIFIED (the 3C proof — a pin needing edits
> means the move changed behavior: stop and re-trace); may-take: the born-live pane's persisted-END
> residue (ledger row 8). U3 — PanePublisher frame-synchronous/state-deferred, my ratified shape; the
> gate is my sentence: walk the boards under load and REVERT on any felt regression — a revert is a
> valid close; plus the TK2 §3 rider (the macOS-27 layoutViewport() clip-displacement exam of
> PaneSurface's render restore) and the warning-count measurement (18k C3: all ~1,989 are
> PaneSurface's). U4 — the one-liners (Outline .onDisappear { landing.end() };
> LandingTarget.utf16Offset wire-or-delete; FlowStoryRow reads the manifest unless 13i took it — check
> first). Plus the B5 trace (KnownIssues row 88; the deterministic Study recipe lives in
> Tools/VisualWalk — decide at U3 whether it rides the exam or its own slot; re-own the row honestly if
> 18l-b closes without it).
>
> Cast (my standing ruling): opus-implementer per unit, one at a time, strictly sequential; Fable cold
> review on U2 and U3 (editor seam), Opus on U4; same-model ladders are yours to arbitrate against the
> spec. The visual harness (VARIORUM_VISUAL_WALK=1 Tools/VisualWalk/visual-walk.sh) is a standing
> instrument — run the seeded suite as regression cover after each unit. Standing rules bind:
> pin-before-fix with behavioral reverts; one unit per implementer session; commit+push per piece, NO
> trailers; PROVISIONAL-and-continue with author-only calls as hard stops; each unit closes on your own
> hands-on walk; the closeout ritual per CLAUDE.md, including the install refresh at a zero-instance
> window behind the A1 rail. My open items live in the 18l handoff's bundle — surface them, never
> re-decide them.

---

## BINDING PRINCIPLES (the 13b constitution, P-1…P-9 — copied verbatim per the architect-phase skill; the application notes in `.claude/skills/architect-phase/SKILL.md` bind with them)

- **P-1 — One capability registry.** Every user-facing act is declared
  exactly once: verb, scope (block/take/post/book), per-mode availability
  rule, its doors (menu / context / bar / shortcut / palette), and its
  refusal copy. Surfaces render their doors FROM the registry; gating is
  data, never per-view if-statements. A registry-walk test asserts every
  declared door exists and every rendered door is declared. This kills the
  D3/D4 class structurally — the capability matrix stays green by
  construction instead of by audit.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act —
  including any mode-switch choreography, done visibly for the user — or
  delivers the operations layer's real refusal. A door that can never act in
  its context isn't rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface
  component (live + read modes; one measurement brain — the width-gated
  remeasure; the shared canary) that every pane composes; the live editor
  core's identity machinery (`BlockRangeIndex`, crystallization) becomes its
  live mode, not a sibling implementation. "What text does this pane show,
  and is it live" is answered by ONE pure, unit-tested authority
  (`PaneTextAuthority`); views never re-derive it. Its invariants stated as
  code: exactly one live pane; the live pane is buffer-authoritative; read
  panes are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** NotificationCenter
  may announce that something happened (mode changed, post opened); no
  listener derives business state or availability from a broadcast, and no
  flow's correctness depends on broadcast ordering. Cross-feature flows
  route through composition. (Stage 0's survey enumerates today's
  notification bus; Stage 1 disciplines it.)
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule
  marks an under-architected feature. The response is never another patch:
  write the feature's DESIGN MEMO — intended behavior whole, edge cases
  enumerated on paper, refusal wordings, undo story — get the author's
  rulings on the product-flavored edges, then build to the memo. Happy path
  ships first, but the edges are *decided at design time*, not discovered by
  the author. First two memos owed: **merge** and **the W ceremony**.
- **P-6 — The tutorial is the executable spec (R113).** The guided tutorial
  flow is the contract for every happy path. It stays green — automated
  where the harness allows, screenshot-walked otherwise — and any change
  that breaks a tutorial step is a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive
  harness: the ops-layer soaks (exist), the board/view-model invariant soak
  (Stage 1), the registry walk (P-1), the per-batch scripted screenshot
  walkthrough. Red-on-old stays absolute: no bug-class fix without a pin
  that fails on the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind
  the rebuilt layer exactly as they bind the substrate (invalidation ∝
  realized rows; one live editor; virtualized long views). Overlays, never
  rendering attributes. Chrome `fixedSize` texts always carry a `lineLimit`
  (the b6dae25 class). `Theme/VoiceControls.swift` is THE chrome vocabulary.
  Complexity lives in the store; restraint lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing
  board layout, text authority, and gesture routing splits by concern
  (`TakesViewModel` at 890 lines is the standing counterexample). Same
  hygiene rule as the substrate, applied where it was being waived.

---

## CAST & DISCIPLINE

- **Fable orchestrates** (this session; writes no feature code beyond adjudication/record acts) ·
  **`opus-implementer` per unit**, one at a time, strictly sequential, briefed ONLY by this file's
  named sections + the charter's and the 18l file's · **cold review per her kickoff:** Fable
  (`fable-reviewer`) on U2 and U3 (the editor seam / landing family — cross-model flow: findings to
  the implementer verbatim, its agree/dispute back, the reviewer makes the final call and implements
  its confirmed fixes); `opus-reviewer` on U4 unless its diff drifts onto the seam (same-model:
  the orchestrator arbitrates against the spec). Zero `Sync/` by design — a fix that wants it is a
  STOP-and-report.
- **Standing rules, restated because they bind every unit:** pin before fix — the red-on-old pin binds
  and is verified by BEHAVIORAL REVERT; a pin green on both sides dismisses the finding as hollow
  (recorded, not fixed). No fix without a self-traced concrete mechanism. Commit per piece, LIVE
  STATUS in this file from each unit's first commit, push after every commit, NO trailers.
  Synchronous foreground waits only (poll the log; never end a turn awaiting a background run).
  Tests at the END against the baselines below. PROVISIONAL-and-continue for non-gating ambiguity
  (log to `notes/QUESTIONS.md`); stop-and-report for gating ambiguity and every author-only call.
  One unit per implementer session. Each unit closes on the orchestrator's own hands-on walk; the
  install refresh follows the round's close at a zero-instance window (A1 safety copy into
  `Backups/safety-copies/` first). **The visual harness is a standing instrument:** the seeded suite
  runs as regression cover after each unit (`VARIORUM_VISUAL_WALK=1 Tools/VisualWalk/visual-walk.sh`).
- **`notes/SessionResiliencyProtocol.md` binds every session** — checkpoint per piece, records before
  final verification with PENDING marks, no subagents from implementers.

## BASELINES (18l's finals, 2026-09-26/27 — read, never re-run at start)

Core **1729/181** (18l U0's closing run — the last core-touching unit; U0b/U0c/U1 owed none) · full
Mac **3168/522** at 18k's finals (the only reds: the three pointer-injection suites under real machine
input — KnownIssues row 92; green 3/3 idle) · 18l per-unit closing sets 341/59 · 694/87 · 989/146 ·
214/37 all green · the harness's final run `notes/plans/vis-walks/2026-09-26/142035/`: **0 FAIL ·
0 ERROR · 0 XPASS**, XFAIL 5 = the two honestly-labelled knowns (S3 ×4, B5 in Study). Install:
`/Applications/Variorum.app` = **`c05400e8`** (Release from `1c720578`, the 18l closeout refresh).
Tree at this kickoff: `main` == `origin/main` at `51d46087`, clean; zero app instances by pgrep.

## THE UNIT ROSTER (order of execution — strictly sequential, R-18l-3's roster order)

The charter (`post-13u-health-rounds.md` KICKOFF 2) carries the full unit text for U2 · U3 · U4.
This file adds what the first half handed forward:

- **U2 — Takes' landing half adopts the authority; the restore half untouched** (the charter's
  text; the round's hardest unit). The authority grows an **AIM KIND** (top · minimal-reveal ·
  viewport-fraction — `ViewportCarry.anchor` supplies the vocabulary); `articleLandingStep` /
  `revealDecision` / `revealAnchor` move onto it under a `takesArticle` policy; **U1's JC 2
  hand-forward rides with it:** `ReadLandingResidual`'s fraction arithmetic
  (`Features/ReadMode/ReadNoteLanding.swift`) is the viewport-fraction arm's pure, pinned
  arithmetic, written there FOR U2 to hoist. The `.holding` restore machinery, `ArticlePlace`, the
  24-aim budget and every R-Q20/R-Q21 behavior ride byte-unchanged; the ~15 gesture-end pins and
  the projection arm pass UNMODIFIED (the 3C proof). **MAY-take:** C6 — a Takes pane BORN live
  reports AppKit's END of its take (`string =` in `makeNSView`) before its `.start` landing
  applies, so the persisted `currentBlock.<id>` holds the take's END until the note leaves (no
  viewport effect; U0c's find, ledger row 8's cell) — else 12 at the closeout. Editor
  seam / landing family → **Fable review**.
- **U3 — PanePublisher, the ratified shape** (the charter's text; her ratified sentence verbatim:
  *"attempt the frame-synchronous / state-deferred shape, walk the boards under load, and revert on
  any felt regression."*). The AppKit frame lever answers the visible height in the same pass; only
  the SwiftUI state write defers; the convergence loop and `deliverMeasuredHeight`'s existing
  deferral stay. **The gate is her sentence — a REVERT is a valid close**, recorded with the
  observation that forced it. Measure the warning count BOTH ways (18k C3's attribution: all
  ~1,989 `Modifying state during view update` lines are `PaneSurface`'s; the A1 apportionment
  hypothesis expects the majority to fall). **Rider (TEXTKIT2_NOTES §3's hand-forward):** the
  macOS-27 `layoutViewport()` clip-displacement examination of `PaneSurface`'s render restore —
  the other `layoutViewport()` caller, never examined; record fixed / provably-safe with the
  mechanism stated. **The B5 decision is made AT this unit** (below). → **Fable review**.
- **U4 — the one-liners** (the charter's text): the book Outline gains
  `.onDisappear { landing.end() }` (R2-12 parity); `LandingTarget.utf16Offset` wired-or-deleted
  (the charter's lean: delete + a comment naming the `FocusedBlock` road; PROVISIONAL either way,
  QUESTIONS row) — **with 18l U0's S4 finding as new evidence for the fork:** a book-Index LANDING
  (the Read ▸ Scroll click-through, `requestLanding`) still parks the caret at the block END (the
  blank line; measured, caret 329 of 329), and wiring the offset through the landing is exactly
  that road's fix, so U4 decides with S4 in hand rather than on the lean alone; `FlowStoryRow`
  reads `BookHeightManifest.resolve` instead of `FlowHeightEstimate.honestHeight` (D1) — **checked
  at this kickoff: 13i has NOT taken it** (`ReadingFlowView.swift:1146` still reads
  `honestHeight`), so the item is live. → **Opus review** unless the diff drifts onto the seam.
- **The B5 TRACE (KnownIssues row 88, re-owned to 18l-b at the split):** ⏎ right after a ⌘↓
  landing on invalidated geometry moves the text above the caret (~30 pt slide under an unmoved
  clip; frame +94 pt for one line; deterministic recipe: the harness's full STUDY pass —
  `VARIORUM_VISUAL_WALK=1 Tools/VisualWalk/visual-walk.sh --voices study`, `probes.log` holding
  every frame/clip/line around the act; the probe proven NOT in the recipe). **Decided at U3:**
  it rides the `layoutViewport()` exam (the named suspects are TK2's estimate settle and 27's
  clip displacement — the same subsystem) or gets its own slot after U3; if 18l-b closes without
  the trace, row 88 re-owns honestly at the closeout — never silently dropped.
- **Adjacent, MAY-take (not owed):** KnownIssues row 85 — the ⌘↓ editing-ring drawn too high
  (O-2), owner 12, *"18l may take it if its landing work touches the ring's refresh."* Decide at
  the unit that touches the landing-settle/overlay refresh; record either way.

**Sizing (the guidance's raise-it rule):** one phase-sized unit (U2), one medium walk-gated unit
(U3 + rider), one one-liner unit (U4), plus a bounded trace — inside the two-phase-sized-units
line; nothing to raise.

## HER OPEN ITEMS (the 18l morning bundle — SURFACED, never re-decided; 18l-b builds under the PROVISIONALs as they stand)

1. **#149** — the 13g surface-rule carve-out (R-18l-5). 2. **#150** — the two note-open refinements
of R-18l-1. 3. **#151** — U1's watch-without-placeholder-rows call (its "Rides this ruling" clause
covers the manifest's offset semantics). 4. **S3** (KnownIssues row 89) — the tier-metrics taste
call. 5. **The U-VIS design ratification** (ratified-by-build unless she objects). 6. **Her sitting
rulings to confirm as standing:** R-18l-1 · R-18l-2 · R-18l-3 (fired) · R-18l-5. An overturn of any
re-opens its named rows; none gates U2/U3/U4 as scoped.

## ENVIRONMENT TRAPS (carried from the 18l record VERBATIM — they bind every unit brief; one dated note at the end)

- Instance checks: `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH (the test
  host matches mid-run). Real-store instances are identified by STORE, not path — NEVER quit or
  kill one; no Release builds or `/Applications` refreshes while one lives. Xcode Run = Debug =
  the fenced dev store (`io.lduarte.Variorum.debug`).
- **An old build must NEVER open the dev store** — bisect by harness in a scratch worktree
  (in-memory store), never by running an old build against a live store (the 18k C2 precedent).
  The VisualWalk build stamp enforces it for harness launches (a `VW_DD` scratch build may differ
  only under `App/`, its core must be the tree's).
- Mac tests from `App/Variorum/`: `xcodebuild -scheme Variorum -destination 'platform=macOS' test`
  with SUITE-LEVEL `-only-testing` only; confirm the "Test run with N tests" line (Swift Testing
  counts SKIPPED tests in N — read the `skipped:` lines). `build-for-testing` compiles without the
  runner. zsh: `pipestatus`. NEVER add a custom build configuration (any configuration not named
  exactly "Debug" builds the SPM packages Release and silently strips VariorumCore's DEBUG
  oracles).
- Suites running beside a live session flash the test host's windows; the three pointer-injection
  suites (row 92) red if anyone uses the machine — a full run that must be trusted runs with
  nobody at it. Prefer zero-instance windows for timing-sensitive measurements. The C2 inline pins
  red when the DEV STORE's voice is Study (row 90) — restore Terminal after any walk.
- Walks: `cliclick` + `Tools/WalkKit/` on the DEV-STORE Debug build only. Accessibility + Screen
  Recording are granted to Ghostty (since 18k — live, no restart needed). Walker facts from the
  13u4 F1/F2/F3 records bind: a single `cliclick` click is sometimes swallowed by activation —
  click twice on an idempotent row; the landing signpost reads back via
  `/usr/bin/log show --predicate 'eventMessage CONTAINS "landing surface"'` filtered on `end=`;
  `walk-scroll` positive line count = DOWN. Screenshots into gitignored dirs
  (`notes/plans/18l-screens/…`). The ← → history bar appears after the first navigation and pushes
  the shelf rows ~17 pt down — measure click targets from a capture taken in the CURRENT
  navigation state. Corner drags near the screen's bottom edge land on the overlay scroller — a
  live resize needs the RIGHT edge or a smaller window first. Never `osascript` an app that is not
  ours. Wait ≥ 2.5 s between steps or `guard.sh` fires on the walker's own clicks.
- **SYSTEM DIALOGS (U-VIS's incident):** before any GUI burst, check for foreign dialogs over the
  work area (the VisualWalk helper does; `guard.sh` CANNOT see them); never click a point a system
  dialog covers; never type unless OUR window is key (a consent prompt with keyboard focus turns a
  ⏎ into Allow). **A consent dialog is ANSWERED BY THE AUTHOR ONLY — never by a session**, whatever
  it blocks; if one appears, record it, work around it or hold, and put it at the top of her
  bundle. And never osascript an app that is not ours.
- **NO GUI DRIVING WHILE THE AUTHOR IS AT THE MACHINE — hardened 2026-09-26 after a live incident
  (18l U0, ~01:37 local):** THE RULE, binding every walk step: (1) check HID idle BEFORE EVERY GUI
  step, not once per walk — recent input (< a few seconds) means STOP and wait or go harness-only;
  (2) verify the TARGET window immediately before each click — the dev pid is frontmost AND its
  window is on the current Space at the expected frame (a screen point alone is never a target);
  (3) any doubt → harness-only until the machine is genuinely author-free (the drives rule:
  unlocked + author-free + own `caffeinate -d`). `Tools/WalkKit/guard.sh --author` first, then
  activate, then the target guard — the U-VIS MAJOR-1 order, durable in WalkKit and the harness.
- Backups: WAL-safe, UTC names, ALWAYS before touching the real store; into the SUBFOLDER
  `Backups/safety-copies/` (R-18k-8), never loose in `Backups/`. Drives need unlocked +
  author-free + own `caffeinate -d`.
- Never `git checkout` over uncommitted work (commit before any revert — resiliency addendum 11);
  push after every commit; never rewrite pushed history. Staging is pathspec-limited
  (`git add <files>`, never `-A`).
- *(Dated note, this kickoff: the 18l traps carried her 2026-09-26 "go ahead freely" go-ahead for
  THAT overnight's GUI driving — it expired with 18l's close. 18l-b sessions verify
  author-absence per step via the guard, never on that quote.)*

## THE LEDGER (every row owned; dispositions land here)

| # | Item | Unit | Status |
|---|---|---|---|
| 1 | The authority grows the AIM KIND (top · minimal-reveal · viewport-fraction); `ReadLandingResidual`'s fraction arithmetic hoisted (U1 JC 2's hand-forward) | U2 | open |
| 2 | Takes' landing half (`articleLandingStep` / `revealDecision` / `revealAnchor`) onto the authority under a `takesArticle` policy; restore half BYTE-PRESERVED (R-Q20/R-Q21); ~15 gesture-end pins + projection arm ride UNMODIFIED (3C) | U2 | open |
| 3 | MAY-take: C6 — the born-live pane's transient END report poisons the persisted memory until the note leaves (18l ledger row 8's cell) | U2 | open — else 12 at the closeout |
| 4 | PanePublisher frame-synchronous / state-deferred (her ratified shape; gate = walk the boards under load, REVERT on any felt regression); the warning count measured both ways (~1,989, all `PaneSurface`'s per 18k C3) | U3 | open |
| 5 | The macOS-27 `layoutViewport()` clip-displacement exam of `PaneSurface`'s render restore (TK2 §3's hand-forward) | U3 rider | open |
| 6 | B5 (row 88): ⏎ after a ⌘↓ landing on invalidated geometry — TRACE (deterministic Study recipe in the harness) | decided at U3 (rides the exam or its own slot) | open |
| 7 | The one-liners: Outline `.onDisappear { landing.end() }` · `LandingTarget.utf16Offset` wire-or-delete (S4's click-through END evidence in hand; PROVISIONAL, QUESTIONS row) · `FlowStoryRow` → `BookHeightManifest.resolve` (13i did NOT take it — verified at this kickoff) | U4 | open |
| 8 | MAY-take: KnownIssues row 85 (the ⌘↓ ring drawn too high, O-2) — decide at the unit that touches the landing-settle/overlay refresh; record either way | rider | open |

## LIVE STATUS (orchestrator; flipped per piece)

| Piece | Status |
|---|---|
| Preflight (canon + the 18l record WHOLE + the charter's KICKOFF 2 + all seven 18l ladder files + the 18l handoff + KnownIssues whole + QUESTIONS #146–#151 + the resiliency protocol + TK2 notes whole + the master plan + health review §1/§5 + R-Q20/R-Q21 + the R-8 brief's code map + the seam headers: `PaneSurface`/`PanePublisher`, `LandingAuthority`, `TakesArticleScroll`, `LandingTarget`, `ReadNoteLanding`) | DONE (this session, 2026-09-26) |
| This record file + the U2 brief | DONE (this commit) |
| U2 (session 1) | NOT-STARTED — brief below |
| U3 (session 2) | NOT-STARTED — brief written after U2's ladder settles |
| U4 (session 3) | NOT-STARTED |
| B5 decision | at U3 |
| Closeout | NOT-STARTED |

## U2 BRIEF (session 1 — Takes' landing half adopts the authority; written by the orchestrator 2026-09-26)

You are the `opus-implementer` for **18l-b UNIT U2**. One acceptance unit, PHASE-SIZED and the
round's hardest: the Takes article column's LANDING half moves onto `LandingAuthority` — the one
watching brain the book Outline, the reading flow, the book Index and note Read's two faces already
share — while its RESTORE half (author-ruled machinery) rides byte-unchanged. **The charter's U2
bullet is your unit charter, read it IN FULL** (`notes/plans/post-13u-health-rounds.md` KICKOFF 2).

**Read first, in this order (reading is never delegated):**
(1) THIS file whole — HER KICKOFF MESSAGE, BINDING PRINCIPLES, CAST & DISCIPLINE, BASELINES,
ENVIRONMENT TRAPS (they bind you verbatim, including the per-step GUI guard and the system-dialog
rules), THE LEDGER rows 1–3, HER OPEN ITEMS.
(2) The charter's KICKOFF 2, its **U2 bullet in full**, plus its read-first list's Takes lines.
(3) The 18l record (`notes/plans/phase-18l-navigation-feel.md`): THE SITTING RECORD (R-18l-1/2 —
U0c's opening arm composes with your surface), the **U0c RECORD** (its TRACE's Takes row — the N9
arm, `landAuthorityFocus`, R-Q1's restored place; its C6 finding, your may-take; its
`openingLanding` arm: an opening landing asks no `landArticle` — your adoption must not change
that), the **U1 RECORD** (the worked example one surface over: the adoption map, JUDGMENT CALLS 1–4
— JC 2 is YOUR hand-forward: the aim kind and the fraction arithmetic; the ladder's MAJOR-1 —
her acts END a landing — and MINOR-1 — `seedsFromLastReport` false on lazy columns; whether Takes'
non-lazy article column seeds from `tops` is YOUR reasoned call, stated), and both U1 ladder files
(`18l-u1-ladder-round1/2.md`).
(4) **The rulings your build must not break:** R-Q20/R-Q21 —
`notes/plans/use-report-round-2026-09-12.md` §7 (the two ruling paragraphs) and the **R-8 brief**
(`### R-8 · 17q` in the same file, ~line 5280) whose "restore/landing step" paragraph maps every
symbol with line pointers; R-Q1 (the article reveal at the nearest page edge). **Byte-preserved
machinery: the adoption is an ADDRESS change for the landing's step/reveal arithmetic, never an
edit inside the restore — flag any pin collision to the orchestrator rather than editing a pin
silently.**
(5) `notes/TEXTKIT2_NOTES.md` in full (editor seam — mandatory; §3's 27.0 findings are your era).
(6) The 13u2 UNIT E record (`notes/plans/phase-13u2-feel.md`, `# UNIT E RECORD` ~line 2309 + its
adjudication) — the split that made `TakesArticleScroll` its own file on the 3C pattern, and the
structural arm (`noteProjectionArrived`) your move must keep working.
(7) KnownIssues rows: 42 (the `TakesArticleScroll` residue list — your known-issues context: the
non-scroll-hand `ScrollPosition` re-resolution window, the 24-aim budget's decay-across-trips, the
never-walked PAGE-TALL straddler), 85 (the O-2 ring may-take), 90 (the dev-store voice trap), 92
(the pointer-injection idle rule), 36 (the shared-defaults harness class — Takes suites own
scrubbed suites).
(8) The code, end to end before touching it: `Features/Takes/TakesArticleScroll.swift` WHOLE (the
landing half you move: `articleLanding`/`ArticleLandingKind`/`landArticle`,
`articleLandingStep(order:)` :460, `revealDecision` :389, `revealAnchor` :498; the restore half
you must NOT edit: `ArticlePlace`, `ArticleRestore`, `consumeArticleGeometry`, `restoreStep`, the
`.holding` machinery, the 24-aim budget, `articleLastCurrentRow`),
`Features/Takes/TakesBoardLayout.swift` (the forwards — every pre-move name must stay reachable),
`Features/Takes/TakesChoreographer.swift` (`consumeLandings` — the N9 entry arm and the bloom arm;
the U0c opening-landing guard), `Features/Takes/TakesBoardView.swift` (the geometry hook →
`consumeArticleGeometry` → `spendArticleLanding`; the `.onChange` hook),
`Surface/LandingAuthority.swift` WHOLE (the policy vocabulary, `LandingSurface`'s closed enum, the
signpost's content-free guard, `seedsFromLastReport`, `userTookOver`),
`Surface/ViewportCarry.swift` (`anchor(_:)` — the aim-kind vocabulary's source),
`Features/ReadMode/ReadNoteLanding.swift` (`ReadLandingResidual` — the fraction arithmetic you
hoist; its pins in `ReadNoteHeightsTests.swift`), `EditorRouter.swift` (`takesArticlePlaces`,
`takesArticleCurrentRows` — session state, untouched), and the pin files:
`VariorumTests/TakesArticleScrollTests.swift` (40 tests — the ~15 gesture-end pins live here),
`TakesLandingTests`, `ReadNoteLandingTests`/`ReadNoteHeightsTests` (the arithmetic pins that ride
your hoist), `LandingAuthorityTests`, `LandingSignpostTests`.

**The unit, in order:**
1. **Grow the authority an AIM KIND** — top · minimal-reveal · viewport-fraction — as POLICY data
   (`LandingPolicy`), with `ViewportCarry.anchor` the one fraction→`UnitPoint` door and
   `ReadLandingResidual`'s arithmetic hoisted to the authority's side as the fraction arm's pure
   brain (U1 JC 2's stated hand-forward). The three book adopters and note Read's two faces keep
   their exact shipped behavior — their resting anchors are PRODUCT and byte-identical; the hoist
   is an address change proven by their pins riding unmodified (forwards/typealiases where needed,
   the 3C pattern).
2. **Move the landing half onto the authority** under a `takesArticle` policy + a new
   `LandingSurface` case (the closed enum's own "the next adds its case here" line;
   `LandingSignpostTests`' surface count moves by its own design). The landing's aim = the reveal
   arithmetic it has today (R-Q1: the nearest page edge — the minimal-reveal kind); the authority
   watches it (quiet/hold/correct/watchdog per policy), her scroll ends it (`userTookOver` — the
   her-hand rule the board already has must not double-fire), and the content-free signpost speaks
   on Takes (`landing surface=TakesArticle …` in Console — the §1.2-class diagnostic this surface
   never had). **The ordering contract that must survive:** R-Q20's landing-wins runs at
   `landArticle` BEFORE anything moves; the restore's `.settled` gate before a landing is
   considered (`articleReadyForLanding`) keeps its meaning; the structural arm
   (`noteProjectionArrived`) still ends a landing on any content change; the U0c opening arm still
   asks no landing on an opening. If the authority's loop and the board's step machine want
   DIFFERENT owners for one of these, STOP and report the fork — that ruling is the orchestrator's.
3. **The restore half is BYTE-PRESERVED:** `ArticlePlace`, `ArticleRestore`,
   `consumeArticleGeometry`, `restoreStep`, the `.holding` machinery, the 24-aim budget,
   `articleLastCurrentRow`, `EditorRouter.takesArticlePlaces`/`takesArticleCurrentRows` — no body
   edits. R-Q20/R-Q21's behaviors are the unit's contract, not its material.
4. **The 3C proof:** the ~15 gesture-end pins and the projection arm in
   `TakesArticleScrollTests` (and every other pre-existing pin) pass UNMODIFIED. **A pin needing
   edits means the move changed behavior: STOP and re-trace** — the one sanctioned exception is a
   pin whose own text says "the next surface adds its case here" (`LandingSignpostTests`'
   surface count), called out explicitly. New authority-level pins for the aim kinds land red-first
   where they pin new behavior (the fraction arm's hoist is a move — its proof is the unmodified
   `ReadNoteLandingArithmeticTests`; the `takesArticle` watch is NEW — pin it with a red-on-old
   shape, e.g. the U1 synthetic-miss form on the article column, plus a behavioral revert named
   before it runs).
5. **MAY-take (ledger row 3): C6** — the born-live pane's `string =` selection report reaching
   `CommandRouter.noteFocusedBlock` before the `.start` landing applies, leaving the persisted
   memory at the take's END until the leaving `persist` heals it. Take it if your diff already
   stands on the report road it lives on; PREFER the consumer side (the fact writer / the
   liveness choreography) over `PaneSurface` bodies — if the honest fix wants a `PaneSurface`
   body, say so plainly (your review is Fable either way; `PaneMeasurement` stays fenced). Not
   taken ⇒ record it stays 12's at the closeout, with a line saying why.
6. **Row 85 (O-2 ring) decision:** if your diff touches the landing-settle/overlay refresh, decide
   the may-take and record either way; else one line ("not touched — stays 12").
7. **WALK (USE), both voices, per-step guarded:** Takes entry landings — a note whose current
   block is deep (the N9 arm lands it, ring + article reveal at the page edge); the fan-panel
   bloom door (17o row 8's gesture); R-Q20's landing-wins (leave Takes, move the current block in
   Write, return — the landing outranks the memory); R-Q21's plain round trip (leave and return
   with nothing clicked — the page byte-where-it-was); her scroll during a landing's hold ends it
   (`end=handedover`); a first open of a note in Takes (U0c: the top, no landing). Capture the
   Takes signpost line from Console in the record. **Then the harness as regression cover:**
   `VARIORUM_VISUAL_WALK=1 Tools/VisualWalk/visual-walk.sh` (the seeded suite, both voices —
   expected: 0 FAIL/0 ERROR/0 XPASS with the two labelled knowns XFAIL; a NEW Takes-landing
   scenario is optional-if-cheap, one `vw_def` row + one `scn_` function — say which you did).

**Cost shape (P1/P3), stated in your record:** nothing new at autosave or scroll-frame rate beyond
what the authority's other adopters pay (a box write and, while a landing is pending, one residual);
the article column realizes what it realized before.

**Discipline (the resiliency protocol, restated — it binds you):** commit per coherent piece, push
after EVERY commit, NO trailers; append a `## U2 RECORD` section to THIS file with LIVE STATUS from
your FIRST commit (per-piece lines: DONE (hash) / IN-PROGRESS / NOT-STARTED; every unverified claim
marked PENDING); records before final verification; synchronous foreground waits only (poll the
log — never end your turn awaiting a background run); NEVER spawn subagents; commit before any
behavioral revert (a committed pre-revert state makes `git checkout HEAD -- <file>` safe — the U0c
slip's lesson); tests at the END (the touched Mac suites + the landing family + the eleven Tutorial
suites, suite-level `-only-testing`), never the full suite at start. Pathspec-limited staging.
PROVISIONAL-and-continue for non-gating ambiguity (log to `notes/QUESTIONS.md`); STOP and report
for gating ambiguity, any product-behavior invention (where a landing PUTS a block is product),
anything wanting `Sources/VariorumCore/Sync/`, and every author-only call. Your diff is the
landing family on the editor seam's neighborhood → a **FABLE cold review** follows; your
self-assessment closes your record.

## U2 RECORD (implementer: `opus-implementer`, 2026-09-26)

**NOT DONE (first line — against what shipped):** (1) **C6 NOT TAKEN** (the born-live pane's END report into the persisted memory) — this diff does not stand on its road (the pane-selection → fact-writer road is untouched); it stays **12's at the closeout** (ledger row 3); (2) **row 85 (O-2) not touched — stays 12**; (3) **the B5 scenario's fixture-ordering ERROR is RECORDED FOR U3, not fixed** (pre-existing since U1 seeded `read-landing` before it — measured identical on the pre-U2 build; U3 owns B5's recipe, the ledger's row 6); (4) **the `articleLandingStep` BODY stays on `TakesArticleScroll`** — its reveal arithmetic moved to the authority's side (`LandingAim.MinimalReveal`) and its LIFECYCLE moved onto the authority's loop (the watch), but the step itself is welded to the restore's ordering contracts (the settled gate, the hold's end at a spend, the gone row) and to 40 pins that call it directly, so it stays the one aim decision, handed to the watch at its first decided step — stated as JC 2, the orchestrator's to overrule; (5) no KnownIssues / AppSpec / canon / QUESTIONS edits — no product decision was made (the lifetime change is the watch's own semantics, JC 3), and the two findings are drafted under OWED AT CLOSE; (6) zero `Sources/`, `Shared/`, `Sync/`, schema, `PaneSurface`, `EditorTextView`, `BlockRangeIndex`, `PaneTextAuthority`, `TakesChoreographer`, `EditorRouter` — no core / iOS / mobile runs owed; (7) the one pre-existing pin edit is the sanctioned surface count.

### LIVE STATUS

| # | Piece | Status |
|---|---|---|
| 1 | Reading (the brief's "Read first" list, in order, own context) | DONE — this file whole (HER KICKOFF MESSAGE, BINDING PRINCIPLES, CAST & DISCIPLINE, BASELINES, THE UNIT ROSTER, ENVIRONMENT TRAPS, THE LEDGER, HER OPEN ITEMS, the U2 BRIEF); the charter's KICKOFF 2 whole (`post-13u-health-rounds.md`, the U2 bullet + its read-first Takes lines); the 18l record's SITTING RECORD (R-18l-1…5), U0c RECORD whole (THE TRACE's Takes row, C6, the `openingLanding` arm) + its acceptance, U1 RECORD whole (the adoption map, JC 1–8, the round-1 fix pass) + both U1 ladder files; R-Q1/R-Q20/R-Q21 (`use-report-round-2026-09-12.md` §7) + the R-8 brief and record (the mount-ordering trace, piece 1, piece 6) + the 17q ladder's three rounds' findings and dispositions (R1-1/R1-2/W-1/W-2, R2-1/R2-2/R2-3, R3-1 — the `.holding` machinery's origin); `TEXTKIT2_NOTES.md` whole; the 13u2 UNIT E record (the split, the structural arm, #113) + its walk and adjudication; KnownIssues lines 36 · 42 · 85 · 90 · 92; `SessionResiliencyProtocol.md` whole; QUESTIONS #113 · #151 (next free #152); the code end to end: `TakesArticleScroll.swift` whole, `TakesBoardLayout.swift` whole, `TakesChoreographer.swift` whole, `TakesBoardView` (init, the article column, the geometry hook, the spend, `.onDisappear`), `TakesViewModel` (init's snapshot, `adopt`, `teardown`, `focus`, `landAuthorityFocus`, the article forwarders, `paneEdited`), `EditorRouter.swift` whole, `Surface/LandingAuthority.swift` whole, `Surface/ViewportCarry.swift` whole, `ReadNoteLanding.swift` whole, `ReadEditPane`/`ReadPageColumn` landings; the pins: `TakesArticleScrollTests` whole (40), `TakesLandingTests` (in `CommandRoutingTests.swift`), `ArticleLandingProjectionArmTests`, `LandingAuthorityTests`/`LandingSignpostTests`, `ReadNoteHeightsTests` (`ReadNoteLandingArithmeticTests`) |
| 2 | Step 1 — the AIM KIND (policy data) + the fraction arithmetic hoisted (address change, forwards) | DONE (`658e2815`) — `Surface/LandingAim.swift` NEW: `LandingAimKind` (top · minimalReveal · viewportFraction) as `LandingPolicy.aim` (default `.top` — the three book policies' construction reads unchanged; note Read's two `.viewportFraction`); `LandingAim.residual(kind, sighting)` the ONE dispatcher; `LandingAim.anchor(fraction:)` = `ViewportCarry.anchor` (the one vocabulary door); `LandingAim.ViewportFraction.residual` = U1's `ReadLandingResidual` body MOVED (the old name a typealias); `LandingAim.MinimalReveal` = the Takes article's `revealDecision`/`revealAnchor`/`ArticleReveal`/`ArticleRevealAim` bodies MOVED (the old names typealiases + one-line forwards) + NEW `residual` (the decision restated as the converged number: 0 ⇔ `.none`) + `anchor(edge)` (the view's `.top`/`.bottom` now through the door — identical `UnitPoint`s). New pure pins `LandingAimTests` (5; new-API, compile-red class). `build-for-testing` green (`App/Variorum/DerivedData/18lb-u2-bft1.log`, zero new warnings in the touched files); `LandingAimTests` + `ReadNoteLandingArithmeticTests` + `LandingAuthorityTests` + `LandingSignpostTests` **22/4 green, the three old suites UNMODIFIED** (`18lb-u2-step1-pure.log`) |
| 3 | Step 2 — the red-on-old pin(s) for the NEW watch behaviour, committed and run RED on the pre-fix tree | DONE — `TakesArticleWatchTests` (new file; the old harness COPIED so `TakesArticleScrollTests` stays byte-unmodified) committed at `becee950` on the pre-watch tree and run there (`App/Variorum/DerivedData/18lb-u2-watch-prefix1.log`): **RED 2/2**. (a) `aRevealedLandingIsOverOnceItHasSettledWithoutWaitingForHerHand` — **`articleLanding → …0024` still pending ~4 s after the reveal** with nothing of hers (the kept-until-her-hand lifetime). (b) `aColdEntryIntoALongNoteOfUnevenBlocksArrivesOnScreen` (U1's synthetic form on the article column: 40 one-line blocks, then 220 long paragraphs of 1–9 sentences, entered on block 201 of 260) — **block 201 NEVER drawn: `aims 64` (the whole bound), the page at 10446 showing blocks 183…239 without it**. THE MECHANISM, traced with a temporary print in `articleLandingStep` (working tree only, removed by `git checkout HEAD --`; `18lb-u2-diag1.log`): **all 64 aims were spent in ~70 ms inside the FIRST layout storm** — aims #1–#58 fired while the column still held its first screen (realized rows 0…17), one aim per row frame report, BEFORE the proxy's first scroll had taken effect; the scroll only began to move at #59 (rows 192…199 realizing) and the budget ran out at #64 with the target one screen short. It is row 100's lesson on this surface (*"a correction issued from inside a content storm is UNDONE … all of them are spent on 2-pt drifts"*) and exactly the discipline the authority exists to supply: a report re-arms a QUIET interval, and the correction is issued from quiet, never per report |
| 4 | Step 2 — the landing half onto the authority (`takesArticle` policy + `LandingSurface.takesArticle`; the watch; the signpost) | DONE (`b25f74ad`) — **the authority** grows `watch(_:facts:mayFinish:aim:)` (land's first half without the aim — the surface's step made it; `land` refactored into the shared `begin` + aim + arm, byte-identical order), `giveUp(_:)` (a surface's own `gaveup`), `onFinish` (told at a finish WITH a story, never at `end()`; nil on the five older adopters), `LandingSurface.takesArticle` ("TakesArticle"), `LandingPolicy.takesArticle` (aim `.minimalReveal`, tolerance 0.5 — the reveal's own slack, the rest note Read's numbers). **`TakesArticleScroll`** holds ONE watch per board (+ a per-board DEBUG `TakesLandingStory`, never a process-global): the step hands the landing over at its FIRST DECIDED STEP (past every gate — R-Q20's landing-wins at `landArticle`, the restore's settled gate, the gone row, the empty column); the view's REPORT roads (row frames, the geometry hook) now call `articleLandingReport` — the step until the watch has the landing, a report to it after (residual through `LandingAim.residual(policy.aim, …)`, content changes) — so a report re-arms the quiet interval instead of spending an aim; the watch's corrections are an observed count the view spends the step on (`articleLandingCorrections` → `.onChange` → `spendArticleLanding`, the one scroll mechanism); her scroll reaches the watch first through `articleGeometryArrived` (the board's `consumeArticleGeometry` forward — the restore's decision then runs byte-unchanged); every arm + the structural arm through `clearArticleLanding(endedBy:)` (`handedover`, once); the gone row / spent bound → `giveUp`; a new landing supersedes silently; `teardown` ends it silently. **`LandingSignpostTests`' surface count 5 → 6 — the ONE sanctioned pin edit** (its own "the next adds its case here" line). New pins (`TakesArticleWatchTests` +7, post-fix — corrected at the fix pass: the suite held 9 tests, not 10): the story (settled once, the facts line), her scroll hands over ONCE, the arms + the structural arm through the one funnel, the R-Q21 stand-down is never watched, a quiet miss earns ONE correction / a home target none, the watchdog (`gaveup` after 3 hops at 4 s), the policy + its content-free line. **The two red-first pins GREEN** (`18lb-u2-watch-fixed1.log`: the lifetime pin 1.15 s; the synthetic miss `aims 2`, block 201 on screen at the foot) and the suite **12/2 green with `LandingSignpostTests`** (`18lb-u2-watch-fixed2.log`). The 3C proof over the pre-existing pins: PENDING (piece 6) |
| 5 | The behavioural revert (named before it runs; on a COMMITTED tree) | DONE — **R-watch, NAMED BEFORE IT RUNS** (the pre-revert state is the committed `b25f74ad` + this record commit): `articleLandingStep`'s one new line `if watch.anchor != landing { beginWatch(landing, order: order) }` removed in the working tree — so no landing is ever handed to the watch, and every report road falls through to the step (the old per-report re-aim, byte for byte). **Expected RED:** the lifetime pin (the landing still pending), the synthetic miss (the 64-aim burn, block 201 never drawn), the story pin (no `LAND`), the her-scroll and the arms pins (their fresh landing never watched), the quiet-miss pin (no correction; the home landing still pending), the watchdog pin (still pending, no corrections). **Expected GREEN:** the stand-down guard (never watched either way), the policy pin, `LandingSignpostTests`, and the 51 pre-existing Takes landing pins. Restored by `git checkout HEAD --` of the one committed file; `git status` clean after. **RUN (`App/Variorum/DerivedData/18lb-u2-R-watch.log`): RED 7 tests / 14 issues — EXACTLY the predicted seven**: the lifetime pin (`articleLanding → …0024` still pending), the synthetic miss (`aims 64`, the page at 10446 showing 183…239, block 201 never drawn — the pre-watch numbers byte for byte), the story pin (story `[]`: no `LAND`, no `DONE`, no facts line — 4 issues), the her-scroll and arms pins (the fresh landing never handed to the watch), the quiet-miss pin (corrections 0 where 1 is owed; the home landing `"b"` still pending, no `DONE: settled` — 3 issues), the watchdog pin (`"far"` still pending, 0 corrections where 3 are owed, no `gave up` — 3 issues); **GREEN as predicted**: the stand-down guard, the policy pin, `LandingSignpostTests` 3/3, and all 51 pre-existing Takes landing pins (`TakesArticleScrollTests` 40 · `ArticleLandingProjectionArmTests` 5 · `TakesLandingTests` 6) — 63 tests / 5 suites run. Restored by `git checkout HEAD -- TakesArticleScroll.swift`; `git status` clean; the line back (grep 1) |
| 6 | The 3C proof (every pre-existing pin rides UNMODIFIED; the one sanctioned surface-count edit called out) | DONE for the landing pins, the closing set PENDING (piece 10) — **the pre-existing test files are byte-unmodified but ONE line:** `git diff 334bf74c..HEAD -- App/Variorum/VariorumTests/` touches exactly `LandingAuthorityTests.swift` (the `LandingSignpostTests` surface count 5 → 6 — **the sanctioned edit**, its own "the next adds its case here" line) plus the two NEW files (`LandingAimTests.swift`, `TakesArticleWatchTests.swift`); `TakesArticleScrollTests.swift` (40 — the ~15 gesture-end pins and the R-Q20/R-Q21/hold/restore pins), `ArticleLandingProjectionArmTests.swift` (5 — the projection arm), `CommandRoutingTests.swift` (`TakesLandingTests` 6), `ReadNoteHeightsTests.swift` (`ReadNoteLandingArithmeticTests` — the fraction arm's hoist), `ReadNoteLandingTests.swift`, `NoteOpenLandingTests.swift` — NOT in the diff. Run: **51/3 green** (`18lb-u2-3c-1.log`: `TakesArticleScrollTests` + `ArticleLandingProjectionArmTests` + `TakesLandingTests`) and green again under R-watch (they do not depend on the watch); the arithmetic + authority suites 22/4 at step 1. **The restore half is byte-preserved** — `git diff 334bf74c..HEAD -- TakesArticleScroll.swift` has NO hunk in `ArticlePlace`, `ArticleRestore`, `consumeArticleGeometry`, `restoreStep`, the `.holding` machinery, the 24-aim budget or `articleLastCurrentRow` (hunks only at the header, the init/watch, `landArticle`'s first line, the structural arm + the her-hand funnel, the hoisted reveal forwards, the step's watch lines, the new watch section, the story type); `EditorRouter.swift`, `TakesChoreographer.swift` (the N9 arm, the bloom arm, U0c's opening arm) untouched |
| 7 | May-takes: C6 (ledger row 3) · row 85 (O-2) — decided and recorded | DONE — **C6 NOT TAKEN — stays 12's at the closeout.** The brief's criterion is "take it if your diff already stands on the report road it lives on": C6 lives on the born-live pane's selection report (`makeNSView`'s `string =` → the pane's selection → `CommandRouter.noteFocusedBlock` → `CurrentBlockMemory`'s persisted `currentBlock.<id>`), and this diff stands on none of it — it changes the article column's SCROLL landing (`TakesArticleScroll`, the board's forwards, the view's article column), the authority's policy/surface data and one `teardown` line; `landAuthorityFocus`, `armPaneCaretLanding`, the pane selection report and the router are untouched. Taking it would be a second unit on the liveness/fact-writer road. **Row 85 (O-2, Write's ⌘↓ editing ring drawn too high) — not touched — stays 12:** the diff touches no Write landing-settle and no overlay/ring refresh (the Takes ring is `landAuthorityFocus`'s, unchanged) |
| 8 | The WALK (USE, both voices, per-step guarded) + the Takes signpost captured from Console | DONE — driven through VisualWalk's guarded doors (the per-step `guard.sh --author` → activate → target guard order, the foreign-dialog and key-window rules; HID idle ≥ 1 h at the start, own `caffeinate -d`, zero instances before and after) as the NEW seeded scenario **`takes-landing`** (`5e5c2d8d`; one `vw_def` row + one `scn_` function — the brief's optional-if-cheap, taken because it doubles as the walk): the stamped build of `95b9a77b` (App/ + core = this tree), *A Scandal in Bohemia* (262 blocks), **both voices PASS 6/6** — `notes/plans/vis-walks/2026-09-26/222714/` (report.md, run.log, captures `{terminal,study}/takes-landing/01…06`). The rows and her Console's lines, verbatim (Terminal · Study): **A — U0c's first open in Takes** (the note's remembered mode; the Terminal pass staged it by leaving it in Takes and relaunching): the top, block 1 ringed, **no TakesArticle line** (no landing asked — the opening arm composed) · **B — the N9 entry landing on the deep current block** (⌘1 · ⌘↓ · ⌘2): block 262 revealed at the FOOT with the rows above it (capture `02`), `landing surface=TakesArticle rows=262 target=261 offset=-1 total=9745 derived=261 exact=0 hops=0 content=2 ms=1017 end=settled top=0` · `… total=9734 … ms=1032 end=settled top=0` · **C — R-Q21's plain round trip** (⌘1 · ⌘2, nothing clicked): **no line** (the landing stood down) and the page she left — capture `03` equals `02` but for the caret's blink · **D — R-Q20's landing wins** (⌘1 · ⌘↑ · ⌘2 — her current block moved to the first while away): the page at the TOP, `… target=0 … exact=1 hops=0 content=3 ms=1009 end=settled top=0` (both voices) · **E — HER WHEEL inside the hold** (one guarded act: ⌘2, then her wheel 0.7 s later): `… target=261 … hops=0 content=2 ms=844 end=handedover top=30` · `… ms=838 end=handedover top=0` · **F — the fan panel's bloom door** (Write ▸ ⌘⇧T on the caret's block ▸ *Open Takes mode*): block 262 bloomed and revealed, `… target=261 … total=11806 derived=226 exact=0 hops=1 content=0 ms=1019 end=settled top=0` · `… total=12172 … hops=1 … ms=1012 end=settled top=0` (the one hop is the watch's correction from quiet). **THE HARNESS SCENARIO'S TEETH, and where the landing PUTS a block, both measured on a pre-U2 scratch build** (a worktree at `334bf74c` — App/ only differs; the core `4b9d3b2f7991` is this tree's, so the stamp rule admits it; built by `build.sh --src`, run by `VW_DD`, the worktree removed after): **`takes-landing` FAILS 4/6 there** (`vis-walks/2026-09-26/223440/`: B, D, E, F — no TakesArticle line on the pre-U2 tree; A and C green on both sides, guards not claims); and the captures of rows **A, B, D and F are BYTE-IDENTICAL (`cmp`) between the pre-U2 and the U2 builds** — the landing puts every block exactly where it always did (R-Q1's reveal edge, R-Q20's top, the bloom's reveal); only her Console changed. Found on the way (pre-existing, byte-identical on the pre-U2 build): row D's head reveal puts block 1's top at the viewport's top, past the column's 18-pt top padding (NOTICED, NOT TOUCHED below) |
| 9 | The harness as regression cover (`VARIORUM_VISUAL_WALK=1 Tools/VisualWalk/visual-walk.sh`, both voices) | DONE — the full seeded suite (13 scenarios with the new `takes-landing`), both voices, on the stamped build of this tree: `notes/plans/vis-walks/2026-09-26/223757/` — **0 FAIL · 0 XPASS · XFAIL 5 = the two labelled knowns exactly as the baseline (S3 ×4 on the two read-tier click scenarios, B5 in Study) · `takes-landing` PASS both voices · 2 ERROR, both harness PRECONDITIONS, both attributed:** (1) **`b5-return-after-cmd-down` (Terminal) — DETERMINISTIC and PRE-EXISTING, a fixture-ordering interaction:** `read-landing` (seeded BEFORE B5 at 18l U1, after the last full seeded run `142035` — U1's harness runs were partial) ends on its deep click at block 245, so the note's current block is 245 when B5's `vw_write_open` arrives in Write; its 30-line scroll then leaves the viewport's lower half in the typewriter ROOM (`clip=16167`, `blk=245/262`) where no blank LINE exists, and the precondition refuses. Re-run in pass order (`read-landing,b5-return-after-cmd-down`, both voices — `230331/`): B5 ERROR both voices, same numbers; and **on the pre-U2 scratch build (`334bf74c` App/, this core) the IDENTICAL refusal, byte-for-byte numbers (`231214/`: `clip=16167.0 sel=42304 blk=245/262`)** — not this unit's. The seeded run's Study B5 ran and reproduced (XFAIL) only because Study's `read-landing` had refused before its deep clicks (below), which is the mechanism confirmed from the other side. **Handed to U3 (it owns B5's recipe — the ledger's row 6): the fixture wants a start reset in `scn_b5-return-after-cmd-down` (e.g. ⌘↑ before the scroll) or `read-landing` moved after B5** — recorded, not built (the one-unit rule). (2) **`read-landing` (Study) — a FLAKE:** the contents column's filtered row 209 was not found by its AX label once; the re-run PASSES in both voices (`230331/`, 12/12 each). The dev store's voice restored to Terminal after every run (read back from each run.log) |
| 10 | Closing runs (the touched Mac suites + the landing family + the eleven Tutorial suites) | **DONE** on the final product tree (`6da17695`; App/ unchanged since `95b9a77b` — every later commit is record or harness), zero app instances, the machine author-free: `App/Variorum/DerivedData/18lb-u2-closing.sh` (101 suite TYPE names, every one `grep`-verified to exist) — the new + touched landing suites, the WHOLE Takes board family (every suite in a file that mounts a `TakesBoardView`/`TakesViewModel` — `teardown` and the board's forwards changed), the Read + book landing family, the eleven Tutorial suites: **✔ Test run with 677 tests in 101 suites passed after 397.967 seconds** (`18lb-u2-closing1.log`; `exit 0`; 102 `Suite … started` lines against 101 asked; **7 tests SKIPPED by design** — `DebugOracleSingletonWindowTests`, env-gated opt-in, so 670 ran). 1,817 `Modifying state during view update` lines (the pane-mounting family — U3's measurement, not attributed here; this diff adds no observed write at a new site: `articleLanding` is written at the sites it always was, and `articleLandingCorrections` only from the authority's work item). Core / iOS / mobile: **not owed** — zero `Sources/`, `Shared/`, `Sync/`, schema. **The Release configuration COMPILES** (`xcodebuild -configuration Release build` into a scratch derived-data folder, removed after — `App/Variorum/DerivedData/18lb-u2-release-compile.log`, `** BUILD SUCCEEDED **`): every DEBUG-only symbol the diff uses (`LandingStoryboard`, the storyboard `init`, `DebugOracleLog`, `TakesLandingStory.storyboard`) sits behind `#if DEBUG`; nothing installed, `/Applications` untouched |
| 11 | Self-assessment | DONE (below) |

- Deaths / resumes: none.
- Reverts in flight: **R-relook, then R-file** (the fix pass's B3) — announced here BEFORE they start; the tree is committed at the announcement.

### THE ADOPTION MAP — what the Takes article's landing does now

| | Before (`334bf74c`) | After (U2) |
|---|---|---|
| **Where a landing PUTS a block** (R-Q1's reveal edge, R-Q20's top, the bloom's reveal) | the step's reveal decision + edge | **unchanged, byte for byte** — the same arithmetic at its new address (`LandingAim.MinimalReveal`), the same `UnitPoint`s through `ViewportCarry.anchor`; the walk's captures of rows A/B/D/F are `cmp`-identical to the pre-U2 build's |
| **The ordering contracts** — R-Q20's landing-wins at `landArticle`, R-Q21's stand-down, the restore's settled gate (`articleReadyForLanding`), the structural arm, U0c's opening arm, the bloom never weighed | the board's step machine + the choreographer | **unchanged, same owners** — the watch takes a landing only at its FIRST DECIDED step, i.e. past every one of them (a stood-down landing is never watched — pinned; U0c's first open asks none — walked) |
| **Between aims** | one aim spent per row frame report and per geometry report, 64 at most, immediately — measured spending all 64 in ~70 ms inside ONE layout storm on an uneven note, the block never drawn | reports go to the WATCH (the minimal-reveal residual, content changes), re-arming its quiet interval; a re-aim is a CORRECTION issued from quiet (≤ 3), spent through the same step — the synthetic note's block 201 arrives with `aims 2` |
| **How a landing ENDS** | at her hand (scroll, click, keystroke, a gesture door, the structural arm), the gone row, or 64 aims — otherwise kept forever | the same hands **plus** the watch: `settled` once its row has sat home through the one-second hold and a quiet interval, `gaveup` at the four-second watchdog, the gone row or the spent bound; a new landing supersedes silently; the board's teardown ends it silently |
| **Her Console** | nothing from Takes | `landing surface=TakesArticle rows=… target=… offset=-1 total=… derived=… exact=… hops=… content=… ms=… end=settled · gaveup · handedover top=…` — content-free (the closed vocabulary + integers; pinned) |

### JUDGMENT CALLS (each reversible, the reversal named)

1. **A report is a REPORT once the watch has the landing** (`articleLandingReport`) — the per-report re-aim of 17p J1 retires for watched landings; the watch's quiet interval is the "measurement is complete" signal J1 said did not exist locally. The measurement that decided it: the synthetic note's 64 aims spent in ~70 ms, 58 of them before the proxy's first scroll had moved the page (`18lb-u2-diag1.log`). *Reverse by* returning `articleLandingStep(order:)` from the report road unconditionally (the pre-U2 road; the corrections still come on top).
2. **The step machine's BODY stays on `TakesArticleScroll`** (the brief's "move `articleLandingStep` onto it" read as: its arithmetic onto the authority's aim kind, its lifecycle onto the authority's loop). Moving the body into `Surface/` would make the authority know the restore's `.holding`, the settled gate and the row-frame bookkeeping — the P-9 line the authority's own header draws ("ONE concern — aim and settle") — and the 40 pins call it where it is. No ordering contract changed owner, so this is not the brief's STOP fork. *Reverse by* hoisting the body behind a protocol the board implements (a design the orchestrator would rule).
3. **The landing's LIFETIME is the watch's** (settled / gaveup / handedover) instead of "until her hand". It is the authority's own semantics on every adopter and the brief's "the authority watches it (quiet/hold/correct/watchdog per policy)"; its dividend is that a gesture no arm enumerated can no longer be fought by a landing that settled long before (the class the 17p/17q ladders met three times). The cost, stated: a relayout that pushes a SETTLED landing's row off screen with no hand of hers is no longer re-revealed (the enumerated arms and the structural arm already covered every content road the table knows). Nothing she sees on the walked roads changed (the `cmp` evidence). *Reverse by* a Takes veto `mayFinish: { false }` (the watch would then end only at her hand or the watchdog — and file `gaveup` for every landing, which is why it is not the call).
4. **The structural arm files `handedover`** (DEBUG act "a content change") — the closed vocabulary has no word for "the content moved under it", and a new outcome word is vocabulary growth nobody asked for. *Reverse by* `watch.end()` there (silent) instead of `userTookOver`.
5. **`tolerance 0.5`** — the reveal decision's own slack, so the authority's "home" and the article's `.none` are one rule (pinned over a 48k-frame sweep in `LandingAimTests`). *Reverse by* 2 (the family's), accepting a 0.5–2 pt band where the authority says home and the step says clipped.
6. **`seedsFromLastReport` FALSE — and the brief's premise corrected: the article column IS lazy** (`LazyVStack`; rows forget their frames on `onDisappear` — R2-2's departure half), not "non-lazy". So U1's MINOR-1 class applies, and the surface seeds each watch from the row's CURRENT frame (`beginWatch` → `reportWatchedLanding`). *Reverse by* `true` (the authority's `tops` seed) — with the stale-seed hazard it names.
7. **The signpost's facts are honest unknowns where the article has no manifest**: `offset=-1` (the Index-F1 form), `total` = the column's MEASURED content height, `derived` = rows with no frame right now (they stand on SwiftUI's estimate), `exact` = every row above the target realized. *Reverse by* a Takes height manifest (a design of its own — #151's family).
8. **The walk IS the new seeded harness scenario `takes-landing`** (the brief's optional-if-cheap, taken): six rows through VisualWalk's guarded doors, a standing tripwire that reds 4/6 on the pre-U2 build. Its row A stages "the note's remembered mode is Takes" by leaving the note in Takes and relaunching when needed, so it is self-contained in any pass.
9. **The watch lives on the MODEL (`TakesArticleScroll`), not the view** (U1 put its authorities in the faces' `@State`): the Takes landing's rules already live in the model (P-9, "the RULE lives in the model"), so the watch's corrections reach the view as an observed count the view answers with the one scroll mechanism. *Reverse by* a view-held authority with an aim closure over the proxy (the U1 shape) — it would need the step machine's state from the view.

### COST SHAPE (P1 / P3), stated

- **Nothing pending:** the report road is `articleLanding == nil` → the step's first guard; the slot order is never built (the autoclosure passes through). Zero cost change.
- **A watched landing (≤ ~1.3 s on a settle, ≤ 4 s at the watchdog):** per row report or geometry report — one dictionary read, the aim kind's O(1) residual, and the authority's quiet re-arm (a work item cancelled and re-queued), exactly what every other adopter pays per report; note the article reports EVERY realized row (not only the target), so ~a screenful of re-arms per scroll frame while a landing is watched — bounded by the viewport, and by the watch's lifetime. Once per landing: the facts (O(rows) over the order the step already built).
- **Corrections:** ≤ 3 per landing, each one observed write → one step spend. **P3 unchanged:** the column realizes exactly what it realized before.

### SEAM FILES THIS DIFF TOUCHES (the Fable reviewer reads this first)

| File | What changed | What did NOT |
|---|---|---|
| `Surface/LandingAim.swift` | NEW — `LandingAimKind` · `LandingAim.residual(kind, sighting)` · `anchor(fraction:)` · `ViewportFraction` (U1's body, moved) · `MinimalReveal` (17p's bodies, moved; + `residual`, `anchor(edge)`) | — |
| `Surface/LandingAuthority.swift` | `LandingPolicy.aim` (default `.top`); `.readNote`/`.readNoteEdit` name `.viewportFraction`; NEW `.takesArticle` + `LandingSurface.takesArticle`; `land` split into `begin` + aim + arm (same order); NEW `watch(…)`, `giveUp(_:)`, `onFinish`; header note | `LandingSettle.decide`, `eventDelay`, the loop (`look`, `arm`), the signpost's format and guard, `end()` |
| `Features/Takes/TakesArticleScroll.swift` | the watch + the per-board DEBUG story; `landArticle`'s first line; the step's watch begin + two `giveUp`s; the report road; the her-scroll door `articleGeometryArrived`; the correction count; `clearArticleLanding(endedBy:)`; the structural arm's act; the hoisted reveal types/functions as typealiases/forwards; docs | **the RESTORE half** — `ArticlePlace`, `ArticleRestore`, `consumeArticleGeometry`, `restoreStep`, `.holding`, the 24-aim budget, `articleLastCurrentRow`, `articlePlaceNow`, the row-frame bookkeeping; `resolveEntryLandingAgainstTheMemory`, `landingOutranks` |
| `Features/Takes/TakesBoardLayout.swift` | the `consumeArticleGeometry` forward → `articleGeometryArrived`; two new forwards | every other forward |
| `Features/Takes/TakesViewModel.swift` | `articleLandingReport()`, `articleLandingCorrections`; `teardown` ends the watch silently | `focus`, `landAuthorityFocus`, the article forwarders, the memory writes |
| `Features/Takes/TakesBoardView.swift` | the two report sites → `asReport: true`; the corrections `.onChange`; the edge's anchor through `LandingAim.MinimalReveal.anchor` (identical values) | the column, the rows, the restore's `scrollTo`, the geometry mapping |
| `Features/ReadMode/ReadNoteLanding.swift` | `ReadLandingResidual` = a typealias of the hoisted `LandingAim.ViewportFraction`; header line | every caller, the box, the manifest |
| Tests | NEW `LandingAimTests` (5), `TakesArticleWatchTests` (10); `LandingSignpostTests`' count 5 → 6 (sanctioned) | every other pin byte-unmodified |
| `Tools/VisualWalk/` | NEW scenario `takes-landing` (seeded, last) + README row | the guard order, every other scenario |

`PaneSurface`, `EditorTextView`, `BlockRangeIndex`, `PaneTextAuthority`, `runStructural`, `JumpPrimitive`, `TakesChoreographer`, `EditorRouter`: untouched. Zero `Sources/`, `Shared/`, `Sync/`, schema.

### NOTICED, NOT TOUCHED

1. **The head reveal eats the column's 18-pt top padding** — row D's landing on block 1 (her R-Q20 win, the current block moved to the first) puts block 1's top AT the viewport's top, the page 18 pt below rest (capture `04`: the ring at y≈184 where the first open's rests at ≈201). **Pre-existing:** the pre-U2 build's capture is byte-identical. The 17p R1-1 class (the TOP is a place of its own) met by the landing's head edge rather than the restore; cosmetic. Proposed owner 12 (drafted below).
2. **B5's harness fixture ERRORs in the full seeded order** (piece 9) — handed to U3.
3. **`TakesArticleScrollTests.theLandingWaitsForRowsAimsByDirectionAndStaysUntilHerHand`'s NAME** still says "until her hand" — true of the step function it drives (it never runs the watch's clock), no longer the whole truth of the app-level lifetime (JC 3). Left byte-unmodified by the 3C rule; the code's docs say what is true now.
4. **`isPositionedByUser` may stay true after her scroll**, so a NEW landing arriving on the same mount after she scrolled is ended by the restore decision's her-hand line at the next geometry report — pre-existing (not examined further); with the watch it files `handedover` rather than nothing.

### OWED AT CLOSE (drafted for the orchestrator)

- **THE LEDGER:** row 1 BUILT (the aim kind as policy data; the fraction arithmetic hoisted, its pins unmodified); row 2 BUILT+WALKED (the landing half on the authority; restore byte-preserved; the ~15 gesture-end pins + the projection arm unmodified; the one sanctioned surface-count edit); row 3 (C6) NOT TAKEN → 12 at the closeout.
- **KnownIssues:** (a) a row for NOTICED 1 (the head reveal eats the top air; pre-existing; owner 12 — the landing/settle family beside row 42); (b) row 42's residue may gain one line — the landing half's per-report re-aim and its kept-until-her-hand lifetime retired at 18l-b U2 (the watch); (c) the B5 fixture interaction rides ledger row 6 (U3).
- **AppSpec:** none required (no contract line names landing internals); optional §12 pointer beside U1's: *"the Takes article's landings are watched by the one landing authority (18l-b U2)."*
- **MOBILE PARITY:** nothing mobile-visible (the phone's Takes surface is its own); the aim kind is Mac `Surface/` vocabulary.
- **QUESTIONS:** none opened (no product decision made — JC 3 is the watch's own semantics under the charter).

### SELF-ASSESSMENT

**Strongest evidence.** The unit measured the old road before it replaced it: the U1 synthetic form on the article column went RED on the pre-watch tree, and a temporary trace found the mechanism — all 64 aims spent in ~70 ms inside one layout storm, one per row report, before the page had moved — which is exactly the discipline the authority exists to supply. Red-on-old is double: the two pins committed and run red first (2/2), and a named behavioural revert (R-watch) red in exactly its predicted seven tests / 14 issues while every pre-existing Takes landing pin stayed green. The 3C proof holds by `git diff`: the only pre-existing test line touched is the sanctioned surface count, and the restore half has no hunk. The walk is USE through the guarded harness in both voices (6/6 + 6/6), her Console's lines captured verbatim, and the harness scenario's teeth proven on a pre-U2 scratch build (4/6 red) — which also produced the strongest product evidence: the captures of where every landing puts its block are byte-identical before and after. The closing set is 677 / 101 green; the full seeded harness is 0 FAIL / 0 XPASS with its two ERRORs attributed by measurement (one pre-existing and identical on the pre-U2 build, one a flake that passed on re-run).

**Weakest points, for the reviewer.** (a) **JC 3 is a behaviour change the 3C proof cannot see**: the landing now ENDS at the watch's settle, so a no-hand relayout after the settle is no longer re-revealed; `theLandingWaitsForRows…StaysUntilHerHand` passes unmodified because it drives the step synchronously and never runs the clock — its name now overstates the app. I believe this is the brief's intent (the watch), but it is the one place where "pins ride unmodified" and "behaviour unchanged" diverge. (b) **JC 1 changes the re-aim CADENCE** for every watched landing (from per-report to per-quiet): every mounted landing pin still passes, and the synthetic note improves from a miss to `aims 2`, but a landing whose first aim lands on placeholder frames now waits a quiet interval (≥ 0.25 s) before its correction where it used to re-aim at once — no walked road showed it, and no pin measures that latency. (c) **JC 2 reads "move `articleLandingStep` onto it" narrowly** — the body stays; if the orchestrator reads the charter literally, the hoist is a design act of its own. (d) The article reports EVERY realized row to the watch while a landing is watched (not only the target) — bounded and short-lived, but more re-arms per frame than the other adopters pay. (e) `onFinish` is a new authority API (a callback) where the five older adopters poll `isPending` — the one shape difference among the adopters. (f) The walk's row E depends on a 0.7-s timing between ⌘2 and her wheel (it passed 2/2 at 844/838 ms, inside the hold); a slower machine could file `settled` there — a harness timing, not a product claim. **U2 — DONE (implementer); the Fable cold review follows.**

### U2 — ORCHESTRATOR ACCEPTANCE, FIRST PASS (2026-09-26; verify-never-trust) — **ONE FINDING BLOCKS THE CLOSE**

**Claims verified against git and disk before the walk:** all 16 commits present and pushed, tree
clean, no trailers; the 3C proof re-run by diff (the ONE pre-existing test line changed is the
sanctioned surface count — it lives in `LandingAuthorityTests.swift`, which is why the diff stat
names that file); the restore half hunk-free (the one new symbol NEAR it, `articleGeometryArrived`,
is a door IN FRONT of the byte-unchanged `consumeArticleGeometry`); **the "24-aim budget" question
resolved at the code — there are TWO budgets** (`articleRestoreAttempts = 24`, byte-preserved;
`articleLandingAttempts = 64`, the landing half's own), so the charter, the header and the report
all agree; the red logs read (prefix RED 2/2; R-watch 63 tests / 5 suites / exactly 14 issues;
closing `677 tests in 101 suites passed` + `** TEST SUCCEEDED **`); the walk and harness run
folders exist with the claimed shapes.

**THE WALK, in the orchestrator's own hands** (the seeded `takes-landing` scenario driven by this
seat; machine author-free, HID idle 19 min at start, zero instances, own `caffeinate`):
- **Run 1 (`notes/plans/vis-walks/2026-09-26/233747/`): 5/6 PASS, row F FAIL.** A–E passed with
  the record's exact signpost shapes (B `end=settled top=0`; C no line; D `target=0 exact=1
  settled`; E `end=handedover`). **F — the bloom door — FAILED FUNCTIONALLY:** no TakesArticle
  line at all (not even `gaveup`), and the probes + capture show the miss is real — the ring on
  block 262 (`fr=pane len=373`, footer `block 262/262`) with the pane at y≈1270, BELOW the
  viewport (empty visible rect; `clip=9867` — the page where E's wheel left it), the bloomed
  block NEVER revealed. Her original row-8 complaint (*"open takes mode … is also not
  automatically navigating you to where the take is"*), returned as a race.
- **Run 2 (`notes/plans/vis-walks/2026-09-26/234323/`): 6/6 PASS** — F `hops=1 end=settled`, the implementer's shape.
  So the miss is INTERMITTENT (1 of 2 in this seat's hands; 0 of ~3 in the implementer's).

**The finding (routed to the implementer to trace — speculation is not a trace):** the shape
matches the record's own NOTICED 4 — E ends with HER WHEEL, so the remembered place is
her-positioned (`isPositionedByUser`), and the restore decision's her-hand line can end the
arriving bloom landing at the next geometry report BEFORE the watch has it; a landing that dies
pre-watch files NOTHING (NOTICED 4's "with the watch it files `handedover`" does not hold there)
and the reveal never runs. Whether the FUNCTIONAL miss pre-exists on the old road (the same
her-hand line is byte-unchanged restore machinery — but the old per-report re-aim may win the
race more often) is exactly what the trace must attribute. **The acceptance gate holds until
this is traced, attributed, and either fixed red-on-old (if U2's, or cheap and in-scope) or
honestly recorded with an owner — her bar for this round is "click around everywhere with no
issues", and an intermittently-silent bloom door misses it.**

**Orchestrator arbitrations on the flagged judgment calls (recorded now so the fix pass builds on
settled ground; the Fable reviewer weighs them independently):**
- **JC 3 (the lifetime is the watch's) — CONFIRMED.** Adopting the authority IS adopting its
  lifecycle: the authority's header defines a landing as done when the quiet interval passes with
  the target home, every adopter ends at settle, and the old kept-until-her-hand lifetime was
  machinery shape, not a ruling (R-Q20/R-Q21 rule the landing-vs-memory decision; the gesture-end
  pins rule that her hand ends a landing, and they ride green). KnownIssues row 42's residue (1)
  documents the old lifetime's own hazard. Architecture, not product; no QUESTIONS row.
- **JC 2 (the step's body stays; arithmetic + lifecycle moved) — CONFIRMED** as the
  spec-defensible reading: P-9's one-concern line is the constitution's own, no ordering contract
  changed owner, and the 40 pins calling the step in place IS the 3C proof working. The charter's
  letter is discharged by the reveal bodies' move + the watch; a protocol hoist of the step body
  would be a design act nobody needs.
- **JC 1 (per-quiet corrections) — CONFIRMED** on the measurement (64 aims in ~70 ms, 58 before
  the first scroll took effect — row 100's lesson on this surface).
- **JC 6 — the brief's premise stands CORRECTED** (the orchestrator's error, recorded): the
  article column IS lazy (`LazyVStack`), so `seedsFromLastReport` false is right per U1 MINOR-1.
- **C6 NOT TAKEN (stays 12 at the closeout) and row 85 NOT TOUCHED (stays 12) — both ACCEPTED**;
  the diff demonstrably stands on neither road.

Ledger rows 1–2 stay open pending the F trace; the Fable cold review follows the fix pass over
the COMBINED diff.

### U2 — THE BLOOM-RACE FIX PASS (implementer, opened 2026-09-27 at `7ab1c1f6`)

**LIVE STATUS (this pass):**

| # | Piece | Status |
|---|---|---|
| B1 | Reproduce (GUI loop + a headless shape) | DONE — **the GUI race did NOT reproduce in 42 instrumented tries** (a throwaway `zz-bloom-loop` scenario, E then F: 8 + 12 Terminal + 12 Study + 10 under ten busy CPU loops — every F settled, 40 of them with `hops=1`; the first 8 logged through a redacted `NSLog`, the other 34 through a public logger — the trace below), plus the 5 un-instrumented scenario passes of the U2 walk, so the deterministic reproduction is the MODEL-LEVEL shape of the mechanism the instrumented walk exposed (B2): **`aBloomWaitingOnARestoreThatArrivedBetweenGeometryReportsStillReveals`** — committed red-first (`0181fc2b`) and run on the U2 tree: **RED, 3 issues** (`18lb-u2-bloom-red.log`: the report road's step `.wait` where the reveal is owed; the restore still `.wanted(r@33)`; the story `[]` — nothing watched, nothing filed), its guard `aRestoreWithNoLandingWaitingIsLeftToItsOwnCadence` green on both sides by design. The temporary diagnostics were removed (`git checkout HEAD --` of the four files, tree clean); their full trace is kept at `App/Variorum/DerivedData/18lb-u2-bloomdiag-trace.txt` |
| B2 | Trace + attribute | DONE — THE TRACE below. **Mechanism: the bloom waits on a restore that ARRIVED between geometry reports and never recorded it.** **ATTRIBUTION: PRE-EXISTING** — the same shape on the pre-U2 road (a worktree at `334bf74c`, the old per-report `articleLandingStep`, five row reports): `[wait, wait, wait, wait, wait]`, restore `.wanted`, landing pending forever (`18lb-u2-bloom-preu2-attribution.log`). Reachable in the app since the 17q ladder's round 1 (2026-09-13: W-1 `cd4f227d` made the restore run in the app at all; R1-2 `c4119e71` made the bloom ride THROUGH the restore); SwiftUI report-order dependent (W-2's stale frames), not a macOS point-release delta. **U2 changed neither the odds nor the outcome of the stall**: before a landing's first decided step U2's road is the old one (the report road falls through to the same step, whose first guard is the same `articleReadyForLanding`); what U2 changed is that a landing's ending now FILES — which is why her Console's silence here is the tell that the landing never reached its first step |
| B3 | Fix (red-on-old pin + behavioural revert) or record | DONE (`20d80980`) — **FIXED on the diff's own surface, no restore body edited:** `articleLandingReport` (the view's report road) first runs `restoreLooksAgainForAWaitingLanding` — while a landing WAITS on a `.wanted` restore whose row now reports at its place (the restore's own `into` ± 2), the restore is handed the geometry it last saw through its OWN door (`consumeArticleGeometry`, byte-unchanged), so it records its arrival exactly as a geometry report would (a hold) and the landing's step readies — then the step runs as before. Guarded to that one case, so the door's step is by construction the hold's `.wait` (nothing to scroll or remember); with no landing waiting the restore keeps its own cadence (R-Q21's plain round trip untouched — the guard pin). Every ordering contract stays where it was: R-Q20's landing-wins and R-Q21's stand-down (`landArticle`/the resolver, untouched), the her-hand rule (her scroll still ends everything on the geometry road — this door passes `positionedByUser: false` and is never her hand), the bloom weighed against nothing (it still waits for the restore — now for its REAL arrival). **GREEN:** the three new pins + the Takes landing family, **66 tests / 5 suites** (`18lb-u2-bloom-green.log`: `TakesArticleWatchTests` 12 · `TakesArticleScrollTests` 40 · `ArticleLandingProjectionArmTests` 5 · `TakesLandingTests` 6 · `LandingSignpostTests` 3). The behavioural reverts: IN-PROGRESS — **NAMED BEFORE THEY RUN** (the tree committed at `20d80980`): **R-relook** — the one call `restoreLooksAgainForAWaitingLanding(order: order())` removed from `articleLandingReport`; expected RED: `aBloomWaitingOnARestore…` exactly as on the U2 tree (step `.wait`, restore `.wanted`, story `[]`), GREEN everything else (the guard and the filing pin included). **R-file** — `fileEnding` reduced to the watched branch (`guard watch.anchor == landing else { return }`, the U2-tree behaviour); expected RED: `aLandingThatEndsBeforeItsFirstStepIsFiledNotSilent` (3 issues), GREEN everything else (the bloom pin included — its landing is watched). Each a working-tree edit, restored by `git checkout HEAD --` of the one committed file |
| B4 | The pre-watch death's visibility | DONE (`20d80980`) — **every ending files, watched or not** (`fileEnding`): her gesture and the structural arm (`clearArticleLanding`), her scroll (`articleGeometryArrived`), a lost row and a spent bound (the step) — a landing the watch never took is taken and ended at once, so the line reads `hops=0 … top=-9999` (never aimed, never reported) with the act in the DEBUG story. **Deliberately still SILENT:** R-Q21's stand-down (never asked of the page — `aStoodDownEntryLandingIsNeverWatched` rides green), a superseded landing (the authority's own `land` precedent), a teardown (R2-12). Pin `aLandingThatEndsBeforeItsFirstStepIsFiledNotSilent` RED on the U2 tree (3 issues), GREEN now. **Does the pre-watch window still exist?** Yes — by design it is the time a landing waits for the restore to arrive and the column to hold rows (every ordering gate); what no longer exists is a SILENT exit from it: a stall of the kind traced here is closed by the re-look, and every other way out now files |

**THE TRACE (inputs → the stranded bloom; read at the code, then measured in 34 traced app runs).**
The bloom door's mount, in the app's order, exactly as the `bloomdiag` trace shows it (the matching passing
iteration, `00:08:52`): (1) the article's FIRST geometry report reads her-positioned memory `DE01@33` (row E's
wheel) with no rows yet → the restore is `.wanted`, its first aim a no-op; (2) the projection arrives → the bloom
arm blooms and rings 262 (`focus migrated` — before the landing exists, so it ends nothing) → `landArticle(262,
.bloom)` — never weighed (17q R1-2) → pending over the `.wanted` restore; (3) the restore aims at geometry reports
while the lazy column's estimate puts the page at ~8491 (the rows there are placeholders); (4) the restore enters
`.holding` at a geometry report that happened to carry the row "at 33" — ON STALE FRAMES (the page was at the
estimate, 1,380 pt short) — which readies the bloom; its first decided step sees 262 at a stale "on screen" frame
(`frame=407`) → the watch begins at residual 0; (5) the HOLD re-aims → SwiftUI settles the page at the true place
(`9867.0`); 262's real frame (964, below the viewport) reports → the watch's quiet correction (`HOP 1`) reveals it
→ `settled hops=1`. **The losing order** is step (4) failing: the restore only ever looks at a GEOMETRY report
(`consumeArticleGeometry` — its one road), and every geometry report carries the rows' PREVIOUS frames (the 17q
ladder's W-2). When SwiftUI's own re-resolution of the restore's last aim lands the page exactly where the memory
says, the geometry report of that move reads the row at its old place (re-aim: a no-op, the page is already
there), the rows then report the row AT its place — and nothing changes the geometry again. The restore stays
`.wanted` forever with the page correct; `articleReadyForLanding` never turns true; the bloom's step returns
`.wait` on every row report; the watch never takes it; nothing is filed. **The orchestrator's run 1 is this state
to the point:** the page at `clip 9867` — the restore's TRUE target, the passing trace's final place — block 262
bloomed and ringed (`close all` live, `fr=pane`) below it, and the log store holds NO TakesArticle line in the
window (queried directly — so not a harness read miss). **The kill roads were ruled out on the evidence:** in all
34 instrumented bloom mounts NO `pbu -> true` fired during F (her-hand flips appear only at row E's real wheel), NO
`clear by …` and NO `structural clear` fired on a pending bloom, and the only `focus migrated` precedes the
landing's arming — and a kill of a WATCHED landing would have filed `handedover`, which the store does not hold.
(The orchestrator's candidate — row E's her-positioned flag carried into F — is excluded by construction as well:
F's board is a new mount with a fresh `ScrollPosition`; E's wheel reaches F only as the MEMORY, which is what
makes F's restore a real restore, and so what puts the bloom in the stall's reach.)
