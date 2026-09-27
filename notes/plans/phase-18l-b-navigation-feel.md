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

**NOT DONE (first line — kept honest at every commit):** PENDING — the unit is in flight; this
line is rewritten at the close against what shipped.

### LIVE STATUS

| # | Piece | Status |
|---|---|---|
| 1 | Reading (the brief's "Read first" list, in order, own context) | DONE — this file whole (HER KICKOFF MESSAGE, BINDING PRINCIPLES, CAST & DISCIPLINE, BASELINES, THE UNIT ROSTER, ENVIRONMENT TRAPS, THE LEDGER, HER OPEN ITEMS, the U2 BRIEF); the charter's KICKOFF 2 whole (`post-13u-health-rounds.md`, the U2 bullet + its read-first Takes lines); the 18l record's SITTING RECORD (R-18l-1…5), U0c RECORD whole (THE TRACE's Takes row, C6, the `openingLanding` arm) + its acceptance, U1 RECORD whole (the adoption map, JC 1–8, the round-1 fix pass) + both U1 ladder files; R-Q1/R-Q20/R-Q21 (`use-report-round-2026-09-12.md` §7) + the R-8 brief and record (the mount-ordering trace, piece 1, piece 6) + the 17q ladder's three rounds' findings and dispositions (R1-1/R1-2/W-1/W-2, R2-1/R2-2/R2-3, R3-1 — the `.holding` machinery's origin); `TEXTKIT2_NOTES.md` whole; the 13u2 UNIT E record (the split, the structural arm, #113) + its walk and adjudication; KnownIssues lines 36 · 42 · 85 · 90 · 92; `SessionResiliencyProtocol.md` whole; QUESTIONS #113 · #151 (next free #152); the code end to end: `TakesArticleScroll.swift` whole, `TakesBoardLayout.swift` whole, `TakesChoreographer.swift` whole, `TakesBoardView` (init, the article column, the geometry hook, the spend, `.onDisappear`), `TakesViewModel` (init's snapshot, `adopt`, `teardown`, `focus`, `landAuthorityFocus`, the article forwarders, `paneEdited`), `EditorRouter.swift` whole, `Surface/LandingAuthority.swift` whole, `Surface/ViewportCarry.swift` whole, `ReadNoteLanding.swift` whole, `ReadEditPane`/`ReadPageColumn` landings; the pins: `TakesArticleScrollTests` whole (40), `TakesLandingTests` (in `CommandRoutingTests.swift`), `ArticleLandingProjectionArmTests`, `LandingAuthorityTests`/`LandingSignpostTests`, `ReadNoteHeightsTests` (`ReadNoteLandingArithmeticTests`) |
| 2 | Step 1 — the AIM KIND (policy data) + the fraction arithmetic hoisted (address change, forwards) | DONE (`658e2815`) — `Surface/LandingAim.swift` NEW: `LandingAimKind` (top · minimalReveal · viewportFraction) as `LandingPolicy.aim` (default `.top` — the three book policies' construction reads unchanged; note Read's two `.viewportFraction`); `LandingAim.residual(kind, sighting)` the ONE dispatcher; `LandingAim.anchor(fraction:)` = `ViewportCarry.anchor` (the one vocabulary door); `LandingAim.ViewportFraction.residual` = U1's `ReadLandingResidual` body MOVED (the old name a typealias); `LandingAim.MinimalReveal` = the Takes article's `revealDecision`/`revealAnchor`/`ArticleReveal`/`ArticleRevealAim` bodies MOVED (the old names typealiases + one-line forwards) + NEW `residual` (the decision restated as the converged number: 0 ⇔ `.none`) + `anchor(edge)` (the view's `.top`/`.bottom` now through the door — identical `UnitPoint`s). New pure pins `LandingAimTests` (5; new-API, compile-red class). `build-for-testing` green (`App/Variorum/DerivedData/18lb-u2-bft1.log`, zero new warnings in the touched files); `LandingAimTests` + `ReadNoteLandingArithmeticTests` + `LandingAuthorityTests` + `LandingSignpostTests` **22/4 green, the three old suites UNMODIFIED** (`18lb-u2-step1-pure.log`) |
| 3 | Step 2 — the red-on-old pin(s) for the NEW watch behaviour, committed and run RED on the pre-fix tree | DONE — `TakesArticleWatchTests` (new file; the old harness COPIED so `TakesArticleScrollTests` stays byte-unmodified) committed at `becee950` on the pre-watch tree and run there (`App/Variorum/DerivedData/18lb-u2-watch-prefix1.log`): **RED 2/2**. (a) `aRevealedLandingIsOverOnceItHasSettledWithoutWaitingForHerHand` — **`articleLanding → …0024` still pending ~4 s after the reveal** with nothing of hers (the kept-until-her-hand lifetime). (b) `aColdEntryIntoALongNoteOfUnevenBlocksArrivesOnScreen` (U1's synthetic form on the article column: 40 one-line blocks, then 220 long paragraphs of 1–9 sentences, entered on block 201 of 260) — **block 201 NEVER drawn: `aims 64` (the whole bound), the page at 10446 showing blocks 183…239 without it**. THE MECHANISM, traced with a temporary print in `articleLandingStep` (working tree only, removed by `git checkout HEAD --`; `18lb-u2-diag1.log`): **all 64 aims were spent in ~70 ms inside the FIRST layout storm** — aims #1–#58 fired while the column still held its first screen (realized rows 0…17), one aim per row frame report, BEFORE the proxy's first scroll had taken effect; the scroll only began to move at #59 (rows 192…199 realizing) and the budget ran out at #64 with the target one screen short. It is row 100's lesson on this surface (*"a correction issued from inside a content storm is UNDONE … all of them are spent on 2-pt drifts"*) and exactly the discipline the authority exists to supply: a report re-arms a QUIET interval, and the correction is issued from quiet, never per report |
| 4 | Step 2 — the landing half onto the authority (`takesArticle` policy + `LandingSurface.takesArticle`; the watch; the signpost) | DONE (`b25f74ad`) — **the authority** grows `watch(_:facts:mayFinish:aim:)` (land's first half without the aim — the surface's step made it; `land` refactored into the shared `begin` + aim + arm, byte-identical order), `giveUp(_:)` (a surface's own `gaveup`), `onFinish` (told at a finish WITH a story, never at `end()`; nil on the five older adopters), `LandingSurface.takesArticle` ("TakesArticle"), `LandingPolicy.takesArticle` (aim `.minimalReveal`, tolerance 0.5 — the reveal's own slack, the rest note Read's numbers). **`TakesArticleScroll`** holds ONE watch per board (+ a per-board DEBUG `TakesLandingStory`, never a process-global): the step hands the landing over at its FIRST DECIDED STEP (past every gate — R-Q20's landing-wins at `landArticle`, the restore's settled gate, the gone row, the empty column); the view's REPORT roads (row frames, the geometry hook) now call `articleLandingReport` — the step until the watch has the landing, a report to it after (residual through `LandingAim.residual(policy.aim, …)`, content changes) — so a report re-arms the quiet interval instead of spending an aim; the watch's corrections are an observed count the view spends the step on (`articleLandingCorrections` → `.onChange` → `spendArticleLanding`, the one scroll mechanism); her scroll reaches the watch first through `articleGeometryArrived` (the board's `consumeArticleGeometry` forward — the restore's decision then runs byte-unchanged); every arm + the structural arm through `clearArticleLanding(endedBy:)` (`handedover`, once); the gone row / spent bound → `giveUp`; a new landing supersedes silently; `teardown` ends it silently. **`LandingSignpostTests`' surface count 5 → 6 — the ONE sanctioned pin edit** (its own "the next adds its case here" line). New pins (`TakesArticleWatchTests` +8, post-fix): the story (settled once, the facts line), her scroll hands over ONCE, the arms + the structural arm through the one funnel, the R-Q21 stand-down is never watched, a quiet miss earns ONE correction / a home target none, the watchdog (`gaveup` after 3 hops at 4 s), the policy + its content-free line. **The two red-first pins GREEN** (`18lb-u2-watch-fixed1.log`: the lifetime pin 1.15 s; the synthetic miss `aims 2`, block 201 on screen at the foot) and the suite **12/2 green with `LandingSignpostTests`** (`18lb-u2-watch-fixed2.log`). The 3C proof over the pre-existing pins: PENDING (piece 6) |
| 5 | The behavioural revert (named before it runs; on a COMMITTED tree) | DONE — **R-watch, NAMED BEFORE IT RUNS** (the pre-revert state is the committed `b25f74ad` + this record commit): `articleLandingStep`'s one new line `if watch.anchor != landing { beginWatch(landing, order: order) }` removed in the working tree — so no landing is ever handed to the watch, and every report road falls through to the step (the old per-report re-aim, byte for byte). **Expected RED:** the lifetime pin (the landing still pending), the synthetic miss (the 64-aim burn, block 201 never drawn), the story pin (no `LAND`), the her-scroll and the arms pins (their fresh landing never watched), the quiet-miss pin (no correction; the home landing still pending), the watchdog pin (still pending, no corrections). **Expected GREEN:** the stand-down guard (never watched either way), the policy pin, `LandingSignpostTests`, and the 51 pre-existing Takes landing pins. Restored by `git checkout HEAD --` of the one committed file; `git status` clean after. **RUN (`App/Variorum/DerivedData/18lb-u2-R-watch.log`): RED 7 tests / 14 issues — EXACTLY the predicted seven**: the lifetime pin (`articleLanding → …0024` still pending), the synthetic miss (`aims 64`, the page at 10446 showing 183…239, block 201 never drawn — the pre-watch numbers byte for byte), the story pin (story `[]`: no `LAND`, no `DONE`, no facts line — 4 issues), the her-scroll and arms pins (the fresh landing never handed to the watch), the quiet-miss pin (corrections 0 where 1 is owed; the home landing `"b"` still pending, no `DONE: settled` — 3 issues), the watchdog pin (`"far"` still pending, 0 corrections where 3 are owed, no `gave up` — 3 issues); **GREEN as predicted**: the stand-down guard, the policy pin, `LandingSignpostTests` 3/3, and all 51 pre-existing Takes landing pins (`TakesArticleScrollTests` 40 · `ArticleLandingProjectionArmTests` 5 · `TakesLandingTests` 6) — 63 tests / 5 suites run. Restored by `git checkout HEAD -- TakesArticleScroll.swift`; `git status` clean; the line back (grep 1) |
| 6 | The 3C proof (every pre-existing pin rides UNMODIFIED; the one sanctioned surface-count edit called out) | NOT-STARTED |
| 7 | May-takes: C6 (ledger row 3) · row 85 (O-2) — decided and recorded | NOT-STARTED |
| 8 | The WALK (USE, both voices, per-step guarded) + the Takes signpost captured from Console | DONE — driven through VisualWalk's guarded doors (the per-step `guard.sh --author` → activate → target guard order, the foreign-dialog and key-window rules; HID idle ≥ 1 h at the start, own `caffeinate -d`, zero instances before and after) as the NEW seeded scenario **`takes-landing`** (`5e5c2d8d`; one `vw_def` row + one `scn_` function — the brief's optional-if-cheap, taken because it doubles as the walk): the stamped build of `95b9a77b` (App/ + core = this tree), *A Scandal in Bohemia* (262 blocks), **both voices PASS 6/6** — `notes/plans/vis-walks/2026-09-26/222714/` (report.md, run.log, captures `{terminal,study}/takes-landing/01…06`). The rows and her Console's lines, verbatim (Terminal · Study): **A — U0c's first open in Takes** (the note's remembered mode; the Terminal pass staged it by leaving it in Takes and relaunching): the top, block 1 ringed, **no TakesArticle line** (no landing asked — the opening arm composed) · **B — the N9 entry landing on the deep current block** (⌘1 · ⌘↓ · ⌘2): block 262 revealed at the FOOT with the rows above it (capture `02`), `landing surface=TakesArticle rows=262 target=261 offset=-1 total=9745 derived=261 exact=0 hops=0 content=2 ms=1017 end=settled top=0` · `… total=9734 … ms=1032 end=settled top=0` · **C — R-Q21's plain round trip** (⌘1 · ⌘2, nothing clicked): **no line** (the landing stood down) and the page she left — capture `03` equals `02` but for the caret's blink · **D — R-Q20's landing wins** (⌘1 · ⌘↑ · ⌘2 — her current block moved to the first while away): the page at the TOP, `… target=0 … exact=1 hops=0 content=3 ms=1009 end=settled top=0` (both voices) · **E — HER WHEEL inside the hold** (one guarded act: ⌘2, then her wheel 0.7 s later): `… target=261 … hops=0 content=2 ms=844 end=handedover top=30` · `… ms=838 end=handedover top=0` · **F — the fan panel's bloom door** (Write ▸ ⌘⇧T on the caret's block ▸ *Open Takes mode*): block 262 bloomed and revealed, `… target=261 … total=11806 derived=226 exact=0 hops=1 content=0 ms=1019 end=settled top=0` · `… total=12172 … hops=1 … ms=1012 end=settled top=0` (the one hop is the watch's correction from quiet). **THE HARNESS SCENARIO'S TEETH, and where the landing PUTS a block, both measured on a pre-U2 scratch build** (a worktree at `334bf74c` — App/ only differs; the core `4b9d3b2f7991` is this tree's, so the stamp rule admits it; built by `build.sh --src`, run by `VW_DD`, the worktree removed after): **`takes-landing` FAILS 4/6 there** (`vis-walks/2026-09-26/223440/`: B, D, E, F — no TakesArticle line on the pre-U2 tree; A and C green on both sides, guards not claims); and the captures of rows **A, B, D and F are BYTE-IDENTICAL (`cmp`) between the pre-U2 and the U2 builds** — the landing puts every block exactly where it always did (R-Q1's reveal edge, R-Q20's top, the bloom's reveal); only her Console changed. Found on the way (pre-existing, byte-identical on the pre-U2 build): row D's head reveal puts block 1's top at the viewport's top, past the column's 18-pt top padding (NOTICED, NOT TOUCHED below) |
| 9 | The harness as regression cover (`VARIORUM_VISUAL_WALK=1 Tools/VisualWalk/visual-walk.sh`, both voices) | DONE — the full seeded suite (13 scenarios with the new `takes-landing`), both voices, on the stamped build of this tree: `notes/plans/vis-walks/2026-09-26/223757/` — **0 FAIL · 0 XPASS · XFAIL 5 = the two labelled knowns exactly as the baseline (S3 ×4 on the two read-tier click scenarios, B5 in Study) · `takes-landing` PASS both voices · 2 ERROR, both harness PRECONDITIONS, both attributed:** (1) **`b5-return-after-cmd-down` (Terminal) — DETERMINISTIC and PRE-EXISTING, a fixture-ordering interaction:** `read-landing` (seeded BEFORE B5 at 18l U1, after the last full seeded run `142035` — U1's harness runs were partial) ends on its deep click at block 245, so the note's current block is 245 when B5's `vw_write_open` arrives in Write; its 30-line scroll then leaves the viewport's lower half in the typewriter ROOM (`clip=16167`, `blk=245/262`) where no blank LINE exists, and the precondition refuses. Re-run in pass order (`read-landing,b5-return-after-cmd-down`, both voices — `230331/`): B5 ERROR both voices, same numbers; and **on the pre-U2 scratch build (`334bf74c` App/, this core) the IDENTICAL refusal, byte-for-byte numbers (`231214/`: `clip=16167.0 sel=42304 blk=245/262`)** — not this unit's. The seeded run's Study B5 ran and reproduced (XFAIL) only because Study's `read-landing` had refused before its deep clicks (below), which is the mechanism confirmed from the other side. **Handed to U3 (it owns B5's recipe — the ledger's row 6): the fixture wants a start reset in `scn_b5-return-after-cmd-down` (e.g. ⌘↑ before the scroll) or `read-landing` moved after B5** — recorded, not built (the one-unit rule). (2) **`read-landing` (Study) — a FLAKE:** the contents column's filtered row 209 was not found by its AX label once; the re-run PASSES in both voices (`230331/`, 12/12 each). The dev store's voice restored to Terminal after every run (read back from each run.log) |
| 10 | Closing runs (the touched Mac suites + the landing family + the eleven Tutorial suites) | NOT-STARTED |
| 11 | Self-assessment | NOT-STARTED |

- Deaths / resumes: none so far.
- Reverts in flight: none (R-watch ran and was restored from the committed file; `git status` clean).
