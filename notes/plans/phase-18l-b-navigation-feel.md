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
| 1 | The authority grows the AIM KIND (top · minimal-reveal · viewport-fraction); `ReadLandingResidual`'s fraction arithmetic hoisted (U1 JC 2's hand-forward) | U2 | **CLOSED 2026-09-27** — `658e2815`; arithmetic pins unmodified; ladder closed (MINOR-1's guard pin makes the declared kinds fail on drift) |
| 2 | Takes' landing half (`articleLandingStep` / `revealDecision` / `revealAnchor`) onto the authority under a `takesArticle` policy; restore half BYTE-PRESERVED (R-Q20/R-Q21); ~15 gesture-end pins + projection arm ride UNMODIFIED (3C) | U2 | **CLOSED 2026-09-27** — `b25f74ad` + the bloom-race fix `20d80980` (pre-existing stall found at the orchestrator's acceptance, traced by run, fixed red-first); triple-walked; ladder closed one round (0/0/3/4, all confirmed, five reviewer fixes, sanity PASS 681/101; `notes/plans/18lb-u2-ladder-round1.md`); row-42 amendment + the head-reveal row landed |
| 3 | MAY-take: C6 — the born-live pane's transient END report poisons the persisted memory until the note leaves (18l ledger row 8's cell) | U2 | **NOT TAKEN 2026-09-27** (the diff stands on none of its road) — 12's at the closeout |
| 4 | PanePublisher frame-synchronous / state-deferred (her ratified shape; gate = walk the boards under load, REVERT on any felt regression); the warning count measured both ways (~1,989, all `PaneSurface`'s per 18k C3) | U3 | **CLOSED AS REVERTED 2026-09-27 — a valid close under her gate** (built `e113dd56`, measured set B 1,106 → 0 — the WHOLE family; reverted `b60e5d6d` at the Takes mount's collapsed article, 5/5 vs 0/5 on frame evidence); the warning family's fork filed for her as QUESTIONS #152; her morning confirm rides the bundle |
| 5 | The macOS-27 `layoutViewport()` clip-displacement exam of `PaneSurface`'s render restore (TK2 §3's hand-forward) | U3 rider | **CLOSED 2026-09-27 — PROVABLY SAFE** (two measured grounds incl. the adversarial arm; the observation seam + `PaneRenderRestoreClipTests` kept as the point-release tripwire; the TK2 §3 line landed) |
| 6 | B5 (row 88): ⏎ after a ⌘↓ landing on invalidated geometry — TRACE (deterministic Study recipe in the harness) | **CLOSED 2026-09-27 at U-B5 — TRACED + FIXED** (the mechanism stack-located: TextKit re-bases a floating island under an unmoved clip when a forcing read lays out the new paragraph; attribution by run — the road our-commit `79b334ab`, the substrate pre-existing, TextKit's half undetermined; the keeper `161b66aa`, pin red-first 80.0 pt, R-keep red exactly, the harness row PLAIN with teeth 45591→44477; ladder one round 0/0/1/2 clean; row 88 closed) | **CLOSED** |
| 7 | The one-liners: Outline `.onDisappear { landing.end() }` · `LandingTarget.utf16Offset` wire-or-delete (S4's click-through END evidence in hand; PROVISIONAL, QUESTIONS row) · `FlowStoryRow` → `BookHeightManifest.resolve` (13i did NOT take it — verified at this kickoff) | U4 | **CLOSED 2026-09-27** — all three red-first; #153 PROVISIONAL (a) with (a′) added as her option at the ladder; ladder closed two rounds (R1 0/0/2/1 all confirmed + fixed with the R-two-arm teeth check; R2 verified + 0/0/0/3 NIT dispositioned at adjudication; `notes/plans/18lb-u4-ladder-round1.md`) |
| 8 | MAY-take: KnownIssues row 85 (the ⌘↓ ring drawn too high, O-2) — decide at the unit that touches the landing-settle/overlay refresh; record either way | rider | **EXHAUSTED HONESTLY 2026-09-27** — not taken at U2/U3/U4; at U-B5's last chance, five ⌘↓ landings traced on invalidated geometry with the ring correct in every one (no reproduction to pin — a hollow fix refused); stays 12, with U-B5's trace note added to the row's suspect (a settle without a clip move leaves no bounds notification; the keeper's jump now provides one on the B5 road) |

## LIVE STATUS (orchestrator; flipped per piece)

| Piece | Status |
|---|---|
| Preflight (canon + the 18l record WHOLE + the charter's KICKOFF 2 + all seven 18l ladder files + the 18l handoff + KnownIssues whole + QUESTIONS #146–#151 + the resiliency protocol + TK2 notes whole + the master plan + health review §1/§5 + R-Q20/R-Q21 + the R-8 brief's code map + the seam headers: `PaneSurface`/`PanePublisher`, `LandingAuthority`, `TakesArticleScroll`, `LandingTarget`, `ReadNoteLanding`) | DONE (this session, 2026-09-26) |
| This record file + the U2 brief | DONE (this commit) |
| U2 (session 1) | **CLOSED 2026-09-27** — built · triple-walked · bloom-race stall traced PRE-EXISTING and fixed red-first · ladder one round 0/0/3/4 all confirmed + five reviewer fixes + sanity PASS 681/101; KnownIssues row 42 amended, the head-reveal row filed |
| U3 (session 2) | **CLOSED AS REVERTED 2026-09-27, ladder CLOSED** (one round 0/0/1/3, all confirmed, zero disputes; reviewer fixes `ec998abf`/`e99e3d88`/`04a30237`; sanity PASS 75/9; `notes/plans/18lb-u3-ladder-round1.md`) |
| U-B5 (after U4) | RULED IN at U3 — the B5 trace's own slot; brief written after U4's ladder settles |
| U4 (session 3) | **CLOSED 2026-09-27** — ladder two rounds, closed clean (R1 0/0/2/1 fixed; R2 0/0/0/3 dispositioned) |
| U-B5 (session 4) | IN FLIGHT — brief above, re-checked against the U4 ladder (nothing in it moves U-B5's surface) |
| B5 decision | at U3 |
| Closeout | IN FLIGHT 2026-09-27 — the ritual below |

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
- Reverts in flight: none (R-relook and R-file ran and were restored from the committed file).

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
| B3 | Fix (red-on-old pin + behavioural revert) or record | DONE (`20d80980`) — **FIXED on the diff's own surface, no restore body edited:** `articleLandingReport` (the view's report road) first runs `restoreLooksAgainForAWaitingLanding` — while a landing WAITS on a `.wanted` restore whose row now reports at its place (the restore's own `into` ± 2), the restore is handed the geometry it last saw through its OWN door (`consumeArticleGeometry`, byte-unchanged), so it records its arrival exactly as a geometry report would (a hold) and the landing's step readies — then the step runs as before. Guarded to that one case, so the door's step is by construction the hold's `.wait` (nothing to scroll or remember); with no landing waiting the restore keeps its own cadence (R-Q21's plain round trip untouched — the guard pin). Every ordering contract stays where it was: R-Q20's landing-wins and R-Q21's stand-down (`landArticle`/the resolver, untouched), the her-hand rule (her scroll still ends everything on the geometry road — this door passes `positionedByUser: false` and is never her hand), the bloom weighed against nothing (it still waits for the restore — now for its REAL arrival). **GREEN:** the three new pins + the Takes landing family, **66 tests / 5 suites** (`18lb-u2-bloom-green.log`: `TakesArticleWatchTests` 12 · `TakesArticleScrollTests` 40 · `ArticleLandingProjectionArmTests` 5 · `TakesLandingTests` 6 · `LandingSignpostTests` 3). The behavioural reverts: DONE — **NAMED BEFORE THEY RUN** (the tree committed at `20d80980`): **R-relook** — the one call `restoreLooksAgainForAWaitingLanding(order: order())` removed from `articleLandingReport`; expected RED: `aBloomWaitingOnARestore…` exactly as on the U2 tree (step `.wait`, restore `.wanted`, story `[]`), GREEN everything else (the guard and the filing pin included). **R-file** — `fileEnding` reduced to the watched branch (`guard watch.anchor == landing else { return }`, the U2-tree behaviour); expected RED: `aLandingThatEndsBeforeItsFirstStepIsFiledNotSilent` (3 issues), GREEN everything else (the bloom pin included — its landing is watched). Each a working-tree edit, restored by `git checkout HEAD --` of the one committed file. **RUN: R-relook RED 1 test / 3 issues — exactly the U2-tree failure** (step `.wait`, restore `.wanted(r@33)`, story `[]`; `18lb-u2-R-relook.log`), the other 62 of 63 green (the guard and the filing pin included); **R-file RED 1 test / 3 issues** (nothing filed for her gesture, her scroll, the lost row; `18lb-u2-R-file.log`), the other 62 green (the bloom pin included). Both restored; `git status` clean after each (the restored lines grep back) |
| B4 | The pre-watch death's visibility | DONE (`20d80980`) — **every ending files, watched or not** (`fileEnding`): her gesture and the structural arm (`clearArticleLanding`), her scroll (`articleGeometryArrived`), a lost row and a spent bound (the step) — a landing the watch never took is taken and ended at once, so the line reads `hops=0 … top=-9999` (never aimed, never reported) with the act in the DEBUG story. **Deliberately still SILENT:** R-Q21's stand-down (never asked of the page — `aStoodDownEntryLandingIsNeverWatched` rides green), a superseded landing (the authority's own `land` precedent), a teardown (R2-12). Pin `aLandingThatEndsBeforeItsFirstStepIsFiledNotSilent` RED on the U2 tree (3 issues), GREEN now. **Does the pre-watch window still exist?** Yes — by design it is the time a landing waits for the restore to arrive and the column to hold rows (every ordering gate); what no longer exists is a SILENT exit from it: a stall of the kind traced here is closed by the re-look, and every other way out now files |
| B5 | The walk + the closing run on the fixed tree | DONE — **`takes-landing` 6/6 PASS in both voices** on the stamped build of the fixed tree (`notes/plans/vis-walks/2026-09-27/010626/`; F `… hops=1 content=1 ms=1006 end=settled top=0` · `… ms=1007 end=settled top=0`; C still files nothing — the stand-down stays silent; the dev store's voice restored to Terminal). The race itself cannot be walked red-then-green (0 of 42 instrumented tries reproduced it; the orchestrator's 1 of 2 is the only sighting) — its evidence is the model-level pin, red on the U2 tree and on the pre-U2 road, green now, with R-relook reproducing the stall byte for byte. **The closing set (the same 101 suites): ✔ Test run with 680 tests in 101 suites passed after 397.310 seconds** (`18lb-u2-closing2.log`; 677 + the 3 new; 7 skipped by design; 102 `Suite … started`). The full seeded harness was not re-run for this pass (the fix touches only the Takes article's landing half; its one scenario is the walk above; the U2 run `223757/` stands for the rest) |

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

**THE FIX PASS'S JUDGMENT CALLS (each reversible):**
- **FP-1 — the re-look is on the landing half's report road, through the restore's own door** (no restore body
  edited; the brief's byte-preserved list holds). The alternative — the restore evaluating itself at row reports
  (e.g. `articleRowFramesMoved` advancing a `.wanted` restore) — is a restore-body edit and would change the
  plain round trip's cadence too; this reaches only the one landing that WAITS on the restore. *Reverse by*
  removing the one call (R-relook's shape). **The one duplicated number:** the guard restates the restore's
  settle criterion (`into` ± 2) so that the door's step is by construction the hold's `.wait`; if the restore's
  tolerance ever moves, the guard must move with it (said at the guard, the one site this pass could write — the
  restore's body is untouched by rule). A reviewer may prefer a shared helper; that is a restore-body edit.
- **FP-2 — every ending files, watched or not; three stay silent by design** (R-Q21's stand-down — the ruled
  "the page she left" is not a landing that ended; a supersede — the authority's own precedent; a teardown —
  R2-12). A pre-watch ending reads `hops=0 … top=-9999`, so her Console tells "ended before it ever aimed"
  apart from a watched ending. *Reverse by* R-file's one line.
- **FP-3 — attribution PRE-EXISTING, fixed anyway** (the orchestrator's criterion: cheap and on this diff's own
  surface — the report road U2 introduced — with every ordering contract where it was).
- **FP-4 — the orchestrator's candidate (E's her-positioned flag) is recorded as excluded, not as refuted by a
  run:** F's board is a fresh mount with a fresh `ScrollPosition`, and in 34 traced bloom mounts no her-hand
  flip fired during F. E's wheel matters only as the memory it leaves — which is what makes F's restore a real
  restore and so puts the bloom in the stall's reach.

**SELF-ASSESSMENT (the fix pass).** Strongest: the mechanism is traced from the app's own instrumented runs (34
readable traces), matches the orchestrator's failing state to the number (`clip 9867` = the restore's true
target; no line in the log STORE, not only in the harness's window), is reproduced deterministically at the
model level, is red on the U2 tree AND on the pre-U2 road (a worktree run — attribution by run, not by reading),
and two behavioural reverts each re-open exactly their hole; the restore half stays byte-unchanged; the walk is
6/6 in both voices and the closing set 680/101. **Weakest points, for the reviewer:** (a) **the GUI race was
never reproduced in my hands** (0 of 42 instrumented + 5 plain), so the claim that THIS is the orchestrator's
run-1 mechanism rests on the trace's fit and the exclusion of the kill roads (no kill fired in any traced
mount), not on a captured failing trace; (b) FP-1's guard duplicates the restore's `± 2`; (c) the re-look lets a
restore record an arrival read from ROW frames, which W-2 says are the fresher of the two — but a row frame can
itself be a placeholder (J1's finding (2)), so the hold that follows may begin on a placeholder frame — exactly
as the geometry road's own hold can today (the passing trace's step 4 entered its hold on stale frames), and the
hold then re-aims as designed; (d) filing pre-watch endings adds Console lines on every gesture that ends a
not-yet-aimed landing (a click in the first ~100 ms of an entry) — informative, but more lines than before.

### U2 — ORCHESTRATOR ACCEPTANCE, SECOND PASS (2026-09-27; verify-never-trust) — **THE GATE LIFTS**

**Claims verified:** all 8 fix-pass commits present and pushed, tree clean, no trailers; the five
evidence logs on disk and read (the bloom-red suite run shows the 6 issues = the two red-first
pins' 3+3; the pre-U2 attribution log holds the `[wait ×5] restore=wanted` line verbatim; the
closing `680 tests in 101 suites passed`); the diff footprint is the landing half + the new pins
only (94 lines in `TakesArticleScroll`, 111 in the watch pins — no restore-body hunk).

**THE WALK, in the orchestrator's own hands (the acceptance):** three fresh passes of
`takes-landing` on the fixed tree — Terminal (`notes/plans/vis-walks/2026-09-27/012240/`), Study
(`012505/`), Terminal again on the race road (`012756/`): **18/18 rows PASS**; row F settled with
the watch's correction every time (`hops=1 end=settled top=0` ×3); row C still files nothing (the
stand-down stays silent, as ruled). The stall's specific state (my run 1: the page at the
restore's true target, the bloom ringed below the fold, the Console silent) is closed by the
re-look, and its SILENT class is closed by the filing — a recurrence would now speak
(`hops=0 … top=-9999`), which is the standing-tripwire shape this round keeps building.
*(One machinery fact for the traps: the harness's instance check greps the process table and can
self-match a caller's own compound command line containing the pattern text — run the driver in a
command that does not spell `Variorum.app/Contents/MacOS`.)*

**Orchestrator adjudications:** ATTRIBUTION ACCEPTED — **pre-existing, by run** (reachable since
the 17q ladder's W-1 + R1-2, 2026-09-13; U2 changed neither odds nor outcome — what U2 changed is
that the silence became legible); fixed anyway under my stated criterion (cheap, on the diff's own
report road, every ordering contract in place). **FP-1…FP-4 ACCEPTED** (FP-1's duplicated `± 2`,
the `-9999` never-aimed sentinel, and FP-2's added Console lines are the reviewer's to weigh
independently); my run-1 candidate stands EXCLUDED by the implementer's trace — recorded as such.
**Ledger rows 1–2 flip to BUILT+WALKED** (the aim kind + the fraction hoist; the landing half on
the authority with the restore byte-preserved and the ~15 gesture-end pins unmodified); row 3
(C6 not taken → 12 at the closeout) stands. **The Fable cold review over the COMBINED diff
(`334bf74c..43a879b1`) is the remaining gate**; ladder file `notes/plans/18lb-u2-ladder-round1.md`.

## U3 BRIEF (session 2 — PanePublisher, the ratified shape + the layoutViewport exam + the B5 decision; written by the orchestrator 2026-09-27 at U2's close)

You are the `opus-implementer` for **18l-b UNIT U3**. One acceptance unit: `PanePublisher` adopts
her RATIFIED shape — verbatim from the charter: *"attempt the frame-synchronous / state-deferred
shape, walk the boards under load, and revert on any felt regression"* (health review §5.1 A1 —
the pane's visible AppKit frame is set synchronously so NO PANE EVER VISIBLY WAITS; only the
SwiftUI state write defers; the existing convergence loop and `deliverMeasuredHeight`'s existing
deferral stay as the net). **The GATE is her sentence: a REVERT is a VALID CLOSE for this unit**,
recorded with the observation that forced it — never argued around. The charter's U3 bullet is
your unit charter (`notes/plans/post-13u-health-rounds.md` KICKOFF 2).

**Read first, in this order (reading is never delegated):**
(1) THIS file whole — HER KICKOFF MESSAGE, BINDING PRINCIPLES, CAST & DISCIPLINE, BASELINES,
ENVIRONMENT TRAPS (verbatim binding — the per-step GUI guard, the system-dialog rules, the
zero-instance rule for timing-sensitive measurement), THE LEDGER rows 4–6 + 8, and the **U2
RECORD + bloom-race fix pass + both acceptance sections** (the freshest landing-family facts;
U2's diff must not be fought).
(2) The charter's U3 bullet + `notes/codebase-health-review-2026-09-21.md` §5.1 whole (A1 is the
ruling's origin and names the starvation risk a deferred-only publish carries — the reason the
sync write existed; A2's deferral precedent in the same coordinator).
(3) `notes/TEXTKIT2_NOTES.md` IN FULL (editor seam — mandatory). §3's macOS-27 findings are your
era: **the `layoutViewport()` clip-displacement finding is your RIDER's subject** (*"`PaneSurface`'s
render restore is the other `layoutViewport()` caller and was NOT examined (18l's)"*), and the
first-full-measure-differs fact + the U0 settle net are neighbours your diff must not fight.
(4) The 18k records (`notes/plans/phase-18k-runtime-hygiene.md`): UNIT C3 (the state-write
deferral sweep + the warning-count attribution — **all ~1,989 `Modifying state during view
update` lines are `PaneSurface`'s**, the A1 apportionment hypothesis your measurement tests),
UNIT C2 (the inline editor's height-binding deferral — the sibling shape).
(5) KnownIssues rows: 88 (B5 — the deterministic Study recipe, the fixed-clip measurement, the
probe ruled out; YOUR RIDER's neighbour), 85 (the O-2 ring may-take — decide if your diff touches
the overlay/ring refresh), 90 (the dev-store voice trap), 92 (pointer-injection idle), the
autosave-rate panes row (13), and row 42's fresh U2 amendment.
(6) The code, end to end before touching it: `Surface/PaneSurface.swift` WHOLE — `PanePublisher`
(the publish door: `publishHeight`'s synchronous write + the deferred convergence turns, the
frame lever `applyFrame`, `healTurnBudget`, `convergenceSlack`, the injectable `Scheduler`),
`PaneMeasurement` (FENCED — the one measurement brain, no body edits), `PaneTextView` +
`PaneSurfaceView`'s coordinator (`install`, the width-gated layout hook, the A47/A47b render
restore — **find its `layoutViewport()` call: that is the rider's caller**), and the composers
that mount panes by the dozen (the Takes board, Compare/Lenses, the book Index pane,
`StableSurface`'s interaction); `Features/Editor/EditorView.swift`'s `InlineEditorSurface`
coordinator (U0's width door + settle net — a neighbour, not your surface);
`VariorumTests`' pane/publisher suites (find `PanePublisher`'s own pins — the injectable
scheduler is the state-transition seam).

**The unit, in order:**
1. **MEASURE FIRST — the warning count BEFORE, on a bounded, REPRODUCIBLE run** (a named suite
   set at a zero-instance window; state the exact command). The A1 hypothesis: the majority of
   ~1,989 falls. The record needs BOTH numbers whatever they say.
2. **BUILD the ratified shape:** the pane's visible height answer stays synchronous through the
   FRAME lever (AppKit's own frame — the path SwiftUI does not flag); the SwiftUI STATE write
   (`writeHeight`) defers to the next main-queue turn; the convergence loop, the budget, the
   coalescing and `invalidate` semantics stay as the net. The canary's publish keeps its shape
   unless the same hazard binds it — say which and why. `PaneMeasurement` untouched.
3. **Pins:** `PanePublisher`'s state-transition pins through the injectable scheduler — the new
   contract stated as tests (a mid-layout publish writes NO state synchronously but the frame
   answers; the state lands on the drained turn; convergence still heals a dropped frame; the
   budget still bounds). Where the OLD behavior is pinned by an existing test, that pin's edit is
   SANCTIONED ONLY if its own text pins the synchronous write as the contract — name each such
   edit out loud (the ratified change is her ruling; the 3C rule still governs everything else).
   A red-on-old pin exists here in the honest direction: the warning-generating shape (a state
   write inside a layout pass) — pin by the mechanism your measurement instruments, if it can be
   made deterministic; else the before/after count IS the measurement evidence, stated as such.
4. **MEASURE AFTER** — the same bounded run, the same command; record both numbers side by side.
5. **THE RIDER (ledger row 5):** the macOS-27 `layoutViewport()` clip-displacement examination of
   `PaneSurface`'s render restore. Under TK2 §3's finding (the viewport layout moves the clip by
   its own pass's height change; `JumpPrimitive.scroll(to:)` re-asserts once — the C6 form),
   examine the restore's caller: can its `layoutViewport()` displace the clip under a restored
   pane, and does anything re-read it? Verdict FIXED (with a red-on-old pin, the C6 re-assert
   form) or PROVABLY-SAFE (with the mechanism stated) — never "looked fine".
6. **THE B5 QUESTION (ledger row 6) — REPORT, do not decide:** with the exam's facts in hand,
   state whether B5's mechanism (row 88: the frame grows under an unmoved clip on the
   differential road after a ⌘↓ landing on invalidated geometry) is the exam's own mechanism, its
   neighbour, or unrelated — with evidence. If the exam's fix would close B5, say so and STOP for
   the orchestrator's ruling before building beyond the rider's scope. The ruling on where the
   trace lands is the orchestrator's (the roster: decided at U3).
7. **The B5 HARNESS FIXTURE fix (U2's hand-forward, Tools/ only):** `b5-return-after-cmd-down`
   (Terminal) ERRORs in full-order runs because `read-landing` leaves the note's current block at
   245 and B5's precondition then lands in the typewriter room (identical pre-U2 — not a product
   bug). Fix the FIXTURE (a start reset in the scenario, e.g. ⌘↑ before the scroll, or the
   scenario order) so the full seeded run is ERROR-free; verify by a full seeded run.
8. **Row 85 (O-2 ring) decision:** your unit touches the overlay/refresh neighbourhood — decide
   the may-take honestly and record either way (a take needs its own red-on-old pin; not-taken
   needs one line saying why).
9. **THE FELT GATE + the walk (USE, both voices, BOTH APPEARANCES, per-step guarded):** walk the
   boards UNDER LOAD — big fans (many takes on one block), Compare pairs, the book Index with
   long notes, the Takes board, expand-all — watching for ANY felt regression: a pane visibly
   waiting at mount, a flash of placeholder height, a slower fan bloom. **On ANY felt regression:
   REVERT (a valid close), record the observation, keep the measurement numbers.** Then the
   harness as regression cover (the full seeded suite, both voices — also proving your item-7
   fixture fix: expected 0 ERROR now). The orchestrator's own walk follows; her morning confirm
   rides the bundle (the felt gate is HER sentence — your walk and the orchestrator's close it
   PROVISIONALLY).

**Cost shape stated in your record** (P1/P3): the change moves WHEN a state write lands, never
what is measured; nothing new at autosave rate; the frame lever's budget unchanged.

**Discipline (the resiliency protocol, restated — it binds you):** commit per coherent piece,
push after EVERY commit, NO trailers; append a `## U3 RECORD` section to THIS file with LIVE
STATUS from your FIRST commit (DONE (hash) / IN-PROGRESS / NOT-STARTED; unverified claims
PENDING); records before final verification; synchronous foreground waits only; NEVER spawn
subagents; commit before any behavioral revert; tests at the END (the pane/publisher family, the
composers' suites, the eleven Tutorial suites — suite-level `-only-testing`; the closing set's
baseline is U2's 101 suites — extend it with the pane family you touch); pathspec-limited
staging. PROVISIONAL-and-continue for non-gating ambiguity (QUESTIONS); STOP and report for
gating ambiguity, any product-behavior invention, anything wanting `Sync/`, and every author-only
call. Your diff is `PaneSurface` — the editor seam by definition → a **FABLE cold review**
follows; your self-assessment closes your record.

## U3 RECORD (implementer: `opus-implementer`, 2026-09-27)

**NOT DONE (first line — against what shipped):** (1) **THE RATIFIED SHAPE DOES NOT SHIP — it was BUILT (`e113dd56`), MEASURED (set B 1,106 → 0: the whole warning family, not the majority), and REVERTED at her felt gate (`b60e5d6d`)**: the Takes board's mount presents a COLLAPSED article (every row empty, the ring at its 24-pt placeholder) for 50–83 ms in 5 of 5 runs on the shape and 0 of 5 without it — her sentence makes that a valid close; the warning family therefore STANDS (set B 1,106; the closing set 2,393) and needs an owner (drafted under OWED AT CLOSE — the author's next call, never re-decided here); (2) the walk's typing-growth act (a pane's ring following a line typed at a live take's end) and the Index click's live pane were NOT exercised in effect — the walk's safety rule skipped the typing on both builds (no pane held the keyboard; nothing typed blind) and the Index click made no pane first responder on either build: recorded, not claimed; (3) no CPU-load passes — the gate fired on the plain board mount first, and load could only deepen a starvation-shaped wait; (4) **B5 NOT traced — REPORTED** (a neighbour, its own slot recommended; the ruling is the orchestrator's); (5) row 85 (O-2) NOT TAKEN — stays 12; (6) the intermittent `read-landing` Study signpost miss (1 of 3) is recorded, not traced (not this unit's surface); (7) no KnownIssues / AppSpec / TEXTKIT2_NOTES / QUESTIONS edits — every canon line is drafted under OWED AT CLOSE; (8) zero `Sources/`, `Shared/`, `Sync/`, schema, `PaneMeasurement` (fenced — untouched), `EditorTextView`, `BlockRangeIndex`, `PaneTextAuthority` — no core / iOS / mobile runs owed. **What ships from U3:** the rider's verdict (PROVABLY SAFE) with its observation seam + `PaneRenderRestoreClipTests` as a point-release tripwire, and the B5 harness fixture fix (Tools/ only).

### LIVE STATUS

| # | Piece | Status |
|---|---|---|
| 1 | Reading (the brief's "Read first" list, in order, own context) | DONE — this file whole (HER KICKOFF MESSAGE, BINDING PRINCIPLES, CAST & DISCIPLINE, BASELINES, THE UNIT ROSTER, ENVIRONMENT TRAPS, THE LEDGER, HER OPEN ITEMS, the U2 BRIEF + RECORD + bloom-race fix pass + both acceptances, the U3 BRIEF); the charter's KICKOFF 2 whole (`post-13u-health-rounds.md` — the U3 bullet); `codebase-health-review-2026-09-21.md` §5.1 whole (A1's three options and the starvation risk; A2's deferral precedent); `TEXTKIT2_NOTES.md` IN FULL (§3's 27.0 findings — the `layoutViewport()` clip displacement, the first-full-measure fact, the settle net); the 18k record's UNIT C2 (brief, record, adjudication — the sibling deferral, newest-wins, M1–M4) and UNIT C3 (brief, record, adjudication — M1's one flagged shape, M2's attribution: every warning inside `PaneSurface`'s make/update, set B's 1,126–1,135); KnownIssues rows 13 · 42 (with the U2 amendment) · 85 · 88 · 90 · 92; the code: `Surface/PaneSurface.swift` WHOLE (`PaneMeasurement` — fenced; `PanePublisher`; `PaneTextView`; `PaneSurfaceView`/`PaneSurfaceRepresentable` + its `Coordinator` — `install`, `reconvergeIfDiverged`, `scheduleRenderRestore`'s `layoutViewport()` = the rider's caller), `Core/Views/StableSurface.swift` whole, `InlineEditorSurface` + its coordinator (`EditorView.swift` — U0's width door + settle net, C2's hop), `JumpPrimitive.jump` (18k C6's re-assert) + `JumpViewportLayoutTests`' header, the ten pane mounts across the composers, `PaneSurfaceTests.swift` (the `PanePublishDoorTests` suite + the F1 walk), `TakesCardHeightTests`' publisher-adjacent pins; `Tools/VisualWalk/scenarios.zsh`'s B5 pair, `read-landing`, `takes-landing` and the seeded order |
| 2 | MEASURE FIRST — the warning count BEFORE (bounded, reproducible) | DONE — **set B, 18k C3's 39-suite run, verbatim: `cd App/Variorum && ./DerivedData/18k-c3-setB.sh`** (the script names its 39 suites literally; all 39 grep-verified to exist today), counted by `grep -c 'Modifying state during view update'` over the xcodebuild log; zero app instances, HID idle 26 min. On `545375bc` (app code = U2's final `79a73919`): **1,106 · 1,106** (two runs — deterministic on this tree; C3 saw 1,126–1,135 on its tree), `✔ Test run with 187 tests in 39 suites passed` both (`App/Variorum/DerivedData/18lb-u3-setB-before{,2}.log`). A second, larger reference on the same app code: U2's 101-suite closing set read 1,817 · 1,818 · 1,819 over its three runs (`18lb-u2-closing{1,2}.log`, `18lb-u2-sanity-r1.log`) |
| 3 | BUILD the ratified shape (frame lever synchronous, state write deferred) | **BUILT (`e113dd56`), then REVERTED at the felt gate (`b60e5d6d`)** — `PanePublisher.publishHeight` now measures, pulls the FRAME LEVER (`applyFrame` — AppKit's own frame, in the same pass) and schedules the turn; the turn (unchanged) re-measures and writes the `@State`, then chases a frame that did not take with the lever inside `healTurnBudget`. The convergence loop, the budget, the coalescing, `invalidate`, the canary (kept synchronous — reason in its doc), `deliverMeasuredHeight`'s hop (kept — now a second hop), `PaneMeasurement` (FENCED — untouched) and every caller are byte-unchanged; the docs that stated the superseded synchronous reasoning (the file header, the publisher's type doc, the lever's doc, the make closure, `deliverMeasuredHeight`, `remeasure`) now state the ratified shape |
| 4 | Pins — the new contract through the injectable scheduler + the mounted mechanism pin; red-on-old; the sanctioned edits named | **DONE for the built shape — then DELETED / RESTORED at the revert (`b60e5d6d`): `PanePublishShapeTests` deleted (recoverable at `8a93eb24`/`e113dd56`), the five sanctioned `PanePublishDoorTests` edits restored BYTE-FOR-BYTE (`git diff 545375bc` of the file: 0 lines).** The evidence as it stood while the shape was built: **RED-FIRST DONE (`8a93eb24`, run on the pre-U3 publisher): `✘ 26 tests in 3 suites … 12 issues` — EXACTLY the four new pins** (`App/Variorum/DerivedData/18lb-u3-redfirst.log`): the frame-now pin (frames `[]`, heights `[46]` before any turn, `[46, 46]` after, a turn still pending), the burst pin (heights `[46, 60]` synchronously — the stale first number written), the heal pin (4 state writes, 2 lever pulls, against 3/3), and **the mounted mechanism pin: the MOUNT wrote its state inside `makeNSView` (1) and the adopted text once more inside `updateNSView` (2)**; the 22 others green (the old publisher pins, the F1 walk). **GREEN on the shape (this commit): `✔ 26 tests in 3 suites passed`** (`18lb-u3-green2.log`). The mounted pin's harness was corrected before its green run (`pump` → `settle`, yielding): its first run on the shape read `stateWrites 0` and the SwiftUI slot 1,517 pt off — a nested runloop pump in a main-actor test body never drains the main queue, so the deferred turn never ran (the precedent `aGapOrVoiceChangeRestoresTheRenderTierWithNoUserEvent` yields for the same reason); its red arm (`stateWritesInsideUpdate`) is synchronous on the old road and does not depend on it — re-proven by R-sync below. **THE SANCTIONED EDITS (named out loud — each pin's own text pinned the synchronous state write as the contract; each edit marked in place):** `PanePublishDoorTests` (in `PaneSurfaceTests.swift`) — (1) `everyPublishCoalescesIntoOneDeferredTurn` ("the sync height write is the working path" → no state before the turn; `[46, 46]` → `[46]`); (2) `theHealReSchedulesWhileTheFrameIsShortAndStopsAtTheBound` ("one sync write + one per healed turn" → one per healed turn); (3) `theHealStopsAsSoonAsTheFrameConverges` (`[46, 46]` → `[46]`); (4) `aDroppedSynchronousWriteIsRepublishedOnTheDeferredTurn` RENAMED `aStateWriteThatDoesNotTakeIsRepublishedOnTheNextTurn` (the dropped write is now the turn's, re-made on the next turn — the net it states, kept); (5) `anInvalidatedPublisherStopsWriting` ("only the pre-invalidate sync write" → none). The canary's arms in (1) and (5) are byte-unchanged. **R-sync RUN (named in `ca7df08d` before it ran): `✘ 26 tests in 3 suites … 19 issues` — EXACTLY the predicted nine red** (the four new pins — the mounted one reading `stateWritesInsideUpdate` **1** at the mount and **2** after the adopted text, so the yielding harness keeps its red arm — and the five sanctioned edits), **the predicted seventeen green** (`18lb-u3-R-sync.log`); restored by `git checkout HEAD --` of the one file, `git status` clean, `applyFrame?(height)` back (grep 2). **THE BLAST RADIUS (the closing set run early, on `7c07fd4d` — the shape, before the rider): `App/Variorum/DerivedData/18lb-u3-closing.sh` = U2's 101 suites ∪ every suite whose file mounts a pane or a pane composer (191 suite type names, each grep-verified): `✘ Test run with 1115 tests in 191 suites failed after 555.833 seconds with 6 issues`, ZERO `Modifying state during view update` lines in the whole run** (`18lb-u3-blast1.log`). The two reds are both POINTER-INJECTION pins — `BlocksWorkbenchFaceTests.aSingleClickOnARowActsWithinTheBudgetAndADoubleStillOpens` (5 issues; row 92 names this very suite) and `ReadModeTests.aRealClickOnAPageReachesTheHostWithTheBlockUnderIt` (1; it posts a real click) — and HID idle read **0 s** at the run's end (someone was at the machine: idle 1,073 s at the start, input at ~03:53). Attribution by an idle-machine isolated re-run: PENDING. Every other pin — the Takes board family, the card-height pins, the Compare/Lenses/Canvas/workbench/Index/Read/Write-panel suites, the eleven Tutorial suites — green UNMODIFIED |
| 5 | MEASURE AFTER (the same command) | DONE — **the same command** (`cd App/Variorum && ./DerivedData/18k-c3-setB.sh`, grep-counted) on `ca7df08d` (app code = the shape, `e113dd56`), zero app instances: **0 · 0** (two runs), `✔ Test run with 187 tests in 39 suites passed` both (`18lb-u3-setB-after{,2}.log`). **BEFORE 1,106 · 1,106 → AFTER 0 · 0 — the WHOLE family falls, not the majority:** 18k C3's attribution (every flagged line inside `PaneSurface`'s make/update) confirmed from the other side, and the A1 apportionment hypothesis ("expect the majority to fall") exceeded |
| 6 | THE RIDER — `layoutViewport()` clip-displacement exam of the render restore | DONE (this commit) — **VERDICT: PROVABLY SAFE, the mechanism stated in THE RIDER below; the instrument stays as a tripwire.** `PaneRenderRestoreClipTests` **3/3 green** with numbers (`App/Variorum/DerivedData/18lb-u3-rider2.log`; the first run `18lb-u3-rider1.log` 13/3 green with the two pointer suites): ROAD 1 (the A47c kill + the occasion, tail-scrolled long pane on the real board) — the one enclosing clip **2094 → 2094**, the visible top **2074 → 2074**, restore ran (1 → 2), shift **0**; ROAD 2 (the paragraph-gap re-font — the geometry really changes, the pane **2753 → 3617 pt**) — restore ran, largest shift **0**, clip 2094; ADVERSARIAL (NOT a production road — unmeasured font growth, then the bare call) — the pass REALLY changed the laid-out geometry (the viewport's first fragment **2055 → 2080**) while the frame held (**2753 → 2753**) and the clip held (**2094 → 2094**) |
| 7 | THE B5 QUESTION — REPORT, not decide | DONE (this commit) — **REPORTED, NOT DECIDED (THE B5 REPORT below): B5 is a NEIGHBOUR of the exam's mechanism, not the mechanism itself, and the exam's (null) fix cannot close it** — different surface (the full-document editor), a road with no app-side `layoutViewport()` and no pane, and the OPPOSITE symptom (B5's clip measured unmoved while the text slides; the exam's mechanism moves the clip while the line stays). The recommendation for the orchestrator's ruling: its own slot. Nothing was built toward B5 |
| 8 | The B5 harness fixture fix (Tools/ only) + a full seeded run | IN-PROGRESS — **the fix (this commit): the SCENARIO ORDER, not a start reset** — `read-landing` now runs after the B5 pair (`b5-return-after-cmd-down`, `b5-refont`, then `read-landing`, then `takes-landing`); the reason is written at `SCN_ORDER` and in the README row. Why the order and not a ⌘↑ reset: KnownIssues row 88 says B5's recipe IS the full Study pass as MEASURED at U-VIS — the order before `read-landing` was seeded — so moving `read-landing` puts every scenario before B5 back on that exact recipe in both voices with no act changed, while a ⌘↑ would rewrite the recipe of an untraced bug (the page 30 lines from the TOP, not U-VIS's mid-note page) and could turn its Study XFAIL into an XPASS or its plain Terminal row into a FAIL for reasons that are the fixture's, not the product's. The costs, stated: `read-landing` now opens the note where B5 left it (the tail), so its read face's 245 is nearer than before (its edit face's first click, 209, is still cold — the face mounts for the first time in the pass; the read face's first click was already "partly warm" by its own comment); `takes-landing` stages its first open by a relaunch and is order-independent. The headless pins green (`swift test` in `Tools/VisualWalk`: 4/2). **THE PROOF — the full seeded suite on what ships (the reverted tree's stamped build, app `5aef032d8e1c`), both voices:** `vis-walks/2026-09-27/052516/` — **Terminal 13/13: 0 FAIL · 0 ERROR · 0 XPASS**, `b5-return-after-cmd-down` **PASS** (4/4 — the precondition ERROR gone), XFAIL 2 (S3 on the two read-tier click scenarios); Study: 0 ERROR · 0 XPASS, XFAIL 3 (S3 ×2, B5 — reproduced on its measured recipe), **and ONE FAIL: `read-landing` ▸ read ▸ block 245 (cold) — the block ARRIVED at its anchor (rl −0.1) but FILED NO SIGNPOST** (the unified log for 05:48:55–05:49:35 holds the face switch's parked landing `target=208 … end=settled` and nothing for the click — a log-store fact, not a harness read miss). **Its reproduction:** the B5 pair then `read-landing` in Study (`055414/`) — PASS 12/12; a second FULL Study pass in the new order (`060002/`) — **0 FAIL · 0 ERROR · 0 XPASS**, `read-landing` 12/12 with all six signposts, XFAIL 3 (S3 ×2, B5). **So the full seeded suite reads the baseline exactly (XFAIL 5 = the two labelled knowns, 0 XPASS, 0 ERROR) and the missing signpost is INTERMITTENT (1 of 3 Study runs of `read-landing` on the new order)** — recorded as NOTICED 2 with a proposed owner, not attributed (the product code on that road is untouched by this unit; one sighting cannot say whether the new history raised its odds). The dev store's voice restored to Terminal after every run (read back from each run.log) |
| 9 | Row 85 (O-2 ring) decision | DONE — **NOT TAKEN — stays 12.** Row 85 is WRITE's editing ring after ⌘↓ (the full-document editor's `BlockDecor` overlay, refreshed by `BlockDecorOverlayController` — its suspect is that overlay refreshing before the landing settles). This diff touches neither `EditorTextView`, `BlockDecor`, the decoration controllers nor any Write landing: it changes WHEN a pane's height state is written and observes the pane restore's clips. A take needs its own red-on-old pin on Write's road, which would be a second unit. **What the diff DOES move, stated so it is walked rather than assumed:** a PANE's ring and wash are SwiftUI overlays sized by the pane's height STATE (`.frame(height:)` then `.overlay`), so on the ratified shape they follow the pane's AppKit frame one main-queue turn later (a line typed at a live take's end is inside the text view at once and inside its ring a turn later) — the felt gate walks exactly that (row 10) |
| 10 | THE FELT GATE + the walk (USE, both voices, both appearances, under load, per-step guarded) | IN-PROGRESS — **A FELT REGRESSION FOUND — THE GATE FIRES (REVERT to follow, a valid close).** The instrument: region VIDEOS of the dev window around each mount act (`screencapture -v`, variable-rate — one frame per presented screen update, up to 120 Hz), every presented state classified from the pixels (article text present / take badges present), on BOTH builds — this tree's (`0e43242e`, app `953d6b7efcba`) and a pre-U3 scratch build (a worktree at `545375bc`, app `ce5fb22ddd37`; the core `4b9d3b2f7991` identical, so the stamp admits it on the dev store), launched and driven by VisualWalk's guarded doors (throwaway `zz-` scenarios, never seeded). The fixture, built through the app's own doors on the dev store: a bookless note **\"U3 walk big fans\"** (12 paragraphs through the Shelf's quick-entry bar; note actions ▸ *Write new takes on every block*; ⌘T ×10 → block 1 holds **12 takes**, every other block 2), Compare's related-blocks filter off. **THE OBSERVATION THAT FORCES THE REVERT — the Takes board's mount (⌘2 from Lenses/Compare), Terminal, light, 4 alternating runs per build:** the pre-U3 build presents *loading page → the article* (0 of 4 runs with anything between); **this build presents *loading page → a COLLAPSED article → the article* in 4 of 4 runs** — every row EMPTY, the live pane's ring drawn at its 24-pt placeholder with no text, the take badges stacked at placeholder spacing — held **50 · 50 · 67 · 83 ms** (2–10 frames at 120 Hz), and the article appears **117–183 ms** after the loading page instead of **100–117 ms**. The mechanism, read from the frames: the lever sizes the pane's NSView, but what she SEES is the SwiftUI slot (the row, its ring, the host's clip), and that slot follows the deferred state — so the ratified shape's premise (\"the pane's visible AppKit frame is set synchronously so no pane ever visibly waits\") does not hold on a board that mounts its panes: the whole article visibly waits one main-queue turn. Evidence: `notes/plans/vis-walks/2026-09-27/{043958,044123,044318,044408,044458,044548,044637,044727}/` (videos + finals), the per-state classification in this row's successor. **CLOSED — REVERTED (`b60e5d6d`)**, the verdict and the breadth walk in THE FELT GATE'S VERDICT below. **The revert verified:** `PaneSurfaceTests.swift` byte-identical to `545375bc` (`git diff` 0 lines); `PaneSurface.swift` differs from `545375bc` by the rider's seam only; `PanePublishDoorTests` + `PaneSurfaceTests` + `PaneRenderRestoreClipTests` **25/3 green** (`18lb-u3-reverted1.log` — the rider's numbers byte-identical to the pre-revert run); **set B, the same command, 1,106** (`18lb-u3-setB-reverted.log`, 187/39 green) = the BEFORE exactly. **THE POST-REVERT WALK (what ships), the reverted tree's stamped build (`b60e5d6d`, app `5aef032d8e1c`), the breadth walk in BOTH voices × BOTH appearances** (`vis-walks/2026-09-27/051016/` light, `051702/` dark — `appearanceChoice` set to `dark` with no instance alive and restored to `system` after; the dark Study capture confirmed dark): the Takes mount **2 states in all four** (loading → the article, 100–133 ms; no collapsed state — the classifier that caught the shape's collapse finds none), Compare mount 3 / 117–133 (its pre-existing one-line collapse, as on the pre-U3 build), Lenses 2 / 100–133, the Index 4–5 / 475–517, expand all (the 12-take fan in Stack) one presented change, the scrolls 9–11 states — per-act table in `notes/plans/18l-screens/18lb-u3/rev-{light,dark}.jsonl`. The throwaway walk (its scenarios as a patch, the frame analyser, the classifier, the AX dumper, the contact sheets) is kept in `notes/plans/18l-screens/18lb-u3/` for the orchestrator's replay; `Tools/VisualWalk/scenarios.zsh` restored to its committed state (grep `zz-` 0) |
| 11 | Closing runs | **DONE** on what ships (`bd0c360a`; app code = the revert `b60e5d6d`), zero app instances, the machine idle (HID 771 s at the end): `App/Variorum/DerivedData/18lb-u3-closing.sh` — U2's 101 suites ∪ every suite whose file mounts a pane or a pane composer (191 suite type names, each grep-verified; `PaneRenderRestoreClipTests` in, the deleted `PanePublishShapeTests` out): **`✔ Test run with 1114 tests in 191 suites passed after 547.141 seconds`**, `EXIT 0` (`18lb-u3-closing1.log`; 192 `Suite … started` lines; 7 tests SKIPPED by design — the env-gated `DebugOracleSingletonWindowTests`). Both pointer-injection pins that reddened in the blast run (`BlocksWorkbenchFaceTests`' single click, `ReadModeTests.aRealClickOnAPage…`) GREEN here with the machine idle — attributed to KnownIssues row 92's class (real input: HID idle read 0 s at the blast run's end). **2,393 `Modifying state during view update` lines** — the family, back with the revert (the same set read **0** on the built shape, `18lb-u3-blast1.log`). Set B on the reverted tree: 1,106 (row 10). The harness: row 8. Core / iOS / mobile: not owed |
| 12 | Self-assessment | DONE (below) |

- Deaths / resumes: none.
- Reverts in flight: none.

### THE BEHAVIOURAL REVERT (named before it runs; the pre-revert state is `e113dd56`, committed + pushed)

**R-sync** — in the working tree only, `PanePublisher.publishHeight`'s one changed line restored to its
pre-U3 body (`writeHeight?(height)` in place of `applyFrame?(height)`): the synchronous STATE write back,
the synchronous lever gone; everything else (the seams, the docs, the pins) as committed. **Expected
RED — 9 tests:** all four `PanePublishShapeTests` (the frame-now pin: heights `[46]` before any turn and
no lever; the burst pin: `[46, 60]` synchronously; the heal pin: 4 writes / 2 lever pulls; the mounted
pin: state written INSIDE the representable's body at the mount and again at the adopted text — the
harness now yields, so this also re-proves the corrected pin's red arm) and the five sanctioned
`PanePublishDoorTests` edits (each now pins the ratified contract). **Expected GREEN — 17:** the other
three door pins (the F1 walk, its counting rule, the coordinator-holds-no-state guard) and all fourteen
`PaneSurfaceTests`. Restored by `git checkout HEAD -- App/Variorum/Variorum/Surface/PaneSurface.swift`;
`git status` clean after.

### THE RIDER — the macOS-27 `layoutViewport()` clip displacement at the render restore (ledger row 5)

**The caller.** `PaneSurfaceRepresentable.Coordinator.scheduleRenderRestore` (A47c) — on a deferred turn after a
convergence OCCASION (`reconvergeIfDiverged(restoreRender: true)`: a click on the pane, the enclosing scroll view's
end-of-live-scroll, a liveness transition) or a whole-storage RE-FONT (`restoreRenderTier()`: the voice or
paragraph-gap branch of `updateNSView`) — calls `textViewportLayoutController.layoutViewport()` to rebuild the pane's
per-fragment rendering surfaces. The only other caller in the app is `JumpPrimitive.jump`'s scroll step (18k C6's
subject, re-asserted there). Write's ⌘↓ is AppKit's own `moveToEndOfDocument:` (not overridden; grep).

**The finding under examination (TK2 §3, 18k C6's `JumpViewportLayoutTests` header):** on 27 the call moves the
clip by about the height change its OWN pass causes — measured on the full-document editor as +29 pt with the
document frame +29 and −23.23 with the frame −23.5 — while the line stays put; a plain flipped view and a bare
`setFrameSize` move nothing; "the displacement lives only inside TK2's viewport layout, and only when that pass
changes the laid-out geometry".

**VERDICT — PROVABLY SAFE, on two independent grounds, each measured:**
1. **The driver cannot exist on a pane.** The editor whose clip moved is a scroll view's DOCUMENT and is vertically
   resizable: its frame follows its laid-out text, so a pass that changes the laid-out height changes the document
   frame inside the pass, and TextKit moves the clip with it. A pane is neither: `PaneTextView.makeSurface` sets
   `isVerticallyResizable = false`, its frame is SwiftUI's (and, since this unit, the publisher's lever — outside
   the restore), and it rides INSIDE SwiftUI scroll views, never as their document. **The adversarial arm removed
   every production safeguard and asked TextKit directly:** unmeasured font growth written straight into the
   storage, then the bare call — the pass REALLY changed the laid-out geometry (the viewport's first fragment
   2055 → 2080 in the pane's space), the frame held (2753 → 2753), and **the clip held (2094 → 2094, shift 0).** On
   a pane the call has nothing to resize and moves no clip.
2. **The production roads never hand the pass unmeasured geometry anyway.** Every road into the restore measures
   the WHOLE (pane-scale) document with `.ensuresLayout` before it schedules the restore — `reconvergeIfDiverged`
   measures, then schedules; the re-font branch re-attributes, re-measures, then asks — so the pass lays out only
   geometry already laid out. The one write that can land between the measure and the restore is the liveness
   road's ink (`applyStyle`'s `textColor` — the A47c kill), a colour, which changes no geometry. ROAD 1 is that exact
   sequence on the rig where A47c was traced: clip 2094 → 2094, the visible text byte-still (top 2074 → 2074),
   shift 0. ROAD 2 is the one production road whose geometry DOES change (2753 → 3617 pt): its restore moved no
   clip either (largest shift 0).

**Does anything re-read the clip?** Nothing needs to: the restore moves none. The clips' only readers are
SwiftUI's own scroll-geometry observers (the Takes article's geometry hook → `consumeArticleGeometry`, the
landing authority's reports), which would see any move as an ordinary scroll report — so if a future point release
ever did move one, the Takes article's restore/landing machinery would at least SEE it; the pane's restore itself
reads nothing after its call. **The tripwire (kept):** the restore now reads every enclosing clip on both sides of
the call (`enclosingClipOrigins`, `lastRenderRestoreClipShift`/`largestRenderRestoreClipShift` — an observation,
the call and its gating unchanged), and the three pins go red the day a point release teaches TextKit to move a
nested pane's clip (TK2 §5's re-verify posture). **Proposed TK2 §3 line (canon — the orchestrator's to land at the
closeout):** *"`PaneSurface`'s render restore — the other `layoutViewport()` caller — was examined at 18l-b U3:
PROVABLY SAFE on 27.0. A pane is never vertically resizable nor a scroll view's document, so its pass cannot resize
it and moves no clip even over unmeasured growth (adversarial arm: fragments 2055 → 2080, frame and clip fixed); and
every production road re-measures before the restore. Pinned: `PaneRenderRestoreClipTests`."*

### THE B5 REPORT (ledger row 6 — REPORT, not decide; the ruling is the orchestrator's)

**Is B5 the exam's mechanism, its neighbour, or unrelated? — A NEIGHBOUR.** The evidence:
- **Different surface and road.** B5 (KnownIssues row 88) is WRITE — the full-document `EditorTextView` — on the
  DIFFERENTIAL road: a ⏎ at the tail right after ⌘↓, after the carve's full re-render invalidated the layout. No
  pane is mounted in its recipe (Write's takes panel is closed; `scn_b5-return-after-cmd-down` never opens it), so
  the render restore cannot run there; and its road contains NO app-side `layoutViewport()` at all (the app's only
  callers are the pane restore and `JumpPrimitive`; ⌘↓ is AppKit's own `moveToEndOfDocument:`; the ⏎ is an ordinary
  edit whose viewport layout is TextKit's implicit one).
- **The opposite symptom.** The exam's mechanism MOVES THE CLIP while the line stays (18k: +29 clip for a +29
  frame). B5 was measured at U-VIS with the CLIP UNMOVED while the text above the caret slid ~30 pt down (the frame
  +94 pt for one ~20-pt line — about 74 pt of estimate settling in one pass).
- **What they share — the subsystem.** Both are macOS 27's TextKit settling ESTIMATED geometry inside a layout pass
  after a whole-document invalidation. The exam's adversarial arm even reproduced B5's SHAPE on a pane — laid-out
  geometry moving under a fixed clip (2055 → 2080) — but only by removing the measure-before-restore ordering that
  every production pane road has. In the full-document editor there is no such ordering on the ⏎ road: after the
  ⌘↓ landing the region above the tail stands on estimates, and the ⏎'s implicit pass corrects them with nothing
  holding the first visible line in place. **The jump road compensates (the clip moves — 18k C6, then re-asserted);
  the edit road does not (the text moves).** That asymmetry, not the pane restore, is B5's open question.
- **Would the exam's fix close B5?** No — there is no fix (PROVABLY SAFE), and a pane-restore fix could not reach
  the Write editor in any case. Nothing was built toward B5 (the STOP line was not reached).

**RECOMMENDATION (not a decision):** B5 takes **its own slot** after U3 (or re-owns honestly at the closeout),
scoped to the full-document editor's differential road: instrument the ⏎'s layout pass in the deterministic Study
harness pass (frame, clip, the first visible line's document y and its fragment's estimated-vs-laid-out state,
before and after the edit's display pass), then decide between an anchor-preserving correction around the edit (the
`ScrollAnchorController`/`topVisibleOffset` family — hold the first visible line where it was across the edit) and
laying out the region above the caret before the edit lands. Its natural home is the Write editor seam's owner (the
landing/settle family, 12, or a dedicated 18l-b slot), with a Fable review. The harness scenario stays its standing
tripwire (item 8 below makes it ERROR-free).

### THE FELT GATE'S VERDICT — REVERT (her sentence: *"revert on any felt regression"*; a revert is a valid close)

**The breadth walk (every board, both builds, Terminal, light — `vis-walks/2026-09-27/044941/` this build, `045302/`
pre-U3; presented states / onset→settle ms):** Takes mount **pre 2 / 117 · U3 3 / 100 — the collapsed article again (5
of 5 U3 runs now, 0 of 5 pre)**; Compare mount pre 3 / 133 · U3 3 / 100 — **both builds** present a collapsed column
(every block cut to one 24-pt line) for one to two frames: PRE-EXISTING, not this unit's (noted for 12, below);
Compare pair pre 14 / 267 · U3 13 / 267; Lenses mount 2 / 117 · 2 / 83; book Index mount 4 / 483 · 4 / 533; expand all
(stack, 12-take fan) 1 · 1 (one presented change on both); the two recorded scrolls 9–11 states on both. The typing
act was SKIPPED on both builds by the walk's own safety rule (no pane held the keyboard after a programmatic ring
step, so nothing was typed blind), and the Index click made no pane first responder on either build — both
recorded, neither claimed.

**THE REVERT, named before it runs (the pre-revert state is committed + pushed at `ca512af9`):** the ratified shape
comes out WHOLE — `PanePublisher.publishHeight` back to its synchronous state write, the docs that stated the
ratified shape back to their pre-U3 text, the flagged-shape observation seam (`representableUpdateDepth`,
`stateWrites`/`stateWritesInsideUpdate`, the make/update brackets, the `writeHeight` wrapper) removed, the five
sanctioned `PanePublishDoorTests` edits restored BYTE-FOR-BYTE, and `PanePublishShapeTests.swift` deleted (it pins
the reverted contract; it stays recoverable at `8a93eb24`/`e113dd56`). **Kept:** the rider's observation seam and
`PaneRenderRestoreClipTests` (independent of the shape; PROVABLY SAFE; a point-release tripwire) and the B5 fixture
fix (Tools/). Mechanically: `git checkout 545375bc -- PaneSurface.swift PaneSurfaceTests.swift`, `git rm
PanePublishShapeTests.swift`, then the rider's seam re-applied to `PaneSurface.swift` exactly as committed at
`051ee76b`. **Expected after:** `git diff 545375bc -- App/Variorum/VariorumTests/PaneSurfaceTests.swift` EMPTY;
`git diff 545375bc -- PaneSurface.swift` = the rider's seam only; the pane/publisher suites green on the old
contract; set B back to the warning family's ~1,106 (the measurement that shows the revert is real); the Takes
mount back to two presented states.

### SEAM FILES THIS DIFF TOUCHES (what SHIPS — `git diff 545375bc..HEAD`; the Fable reviewer reads this first)

| File | What changed | What did NOT |
|---|---|---|
| `Surface/PaneSurface.swift` | the rider's OBSERVATION only: `PaneTextView.enclosingClipOrigins()`, `lastRenderRestoreClipShift` / `largestRenderRestoreClipShift`, `noteRenderRestore(clipShift:)` (default 0 — the one caller passes the shift) *[amended at ladder round 1, NIT-1: the default DROPPED — every caller states its shift; `18lb-u3-ladder-round1.md`]*, and `scheduleRenderRestore` reading the clips on both sides of its `layoutViewport()` | `PanePublisher` (byte-identical to `545375bc` after the revert), `PaneMeasurement` (fenced), the restore's gating, its call and its latch, every liveness/caret/style/identity/measure path |
| `VariorumTests/PaneRenderRestoreClipTests.swift` | NEW (3): the two production roads on the A47c rig + the adversarial TextKit probe (GUARDS — green on both sides by construction: the verdict is SAFE, so there is no red-on-old to have) | — |
| `VariorumTests/PaneSurfaceTests.swift` | nothing (byte-identical to `545375bc`) | — |
| `Tools/VisualWalk/scenarios.zsh`, `README.md` | `SCN_ORDER`: `read-landing` after the B5 pair, the reason at the line; the README row | every scenario's acts, the guard order, `lib.zsh` |

**The built-then-reverted diff** (for the reviewer's completeness — NOT shipped): `e113dd56` (the shape: `publishHeight` pulled `applyFrame` instead of `writeHeight`; the docs; the five sanctioned pin edits) + `8a93eb24` (the flagged-shape seam + `PanePublishShapeTests`) — reverted whole at `b60e5d6d`.

### COST SHAPE (P1 / P3), stated

- **Shipped:** two ancestor walks (the pane's clip origins, O(view-hierarchy depth)) per RENDER RESTORE — restores run per occasion burst (a click on the pane, a scroll-end, a liveness flip, a re-font), coalesced on the existing latch, zero at rest; nothing at autosave or keystroke rate; P3 unchanged.
- **The reverted shape, while built (recorded because the next attempt will ask):** the same measurements per publish (one in the pass, one on the turn — as before); the synchronous half became an equality-guarded `setFrameSize`; the SwiftUI state writes per burst DROPPED (one per turn, the newest measure — the burst pin); `deliverMeasuredHeight` gained a second hop. What it cost was not compute: it was one main-queue turn of visible layout on every board mount.

### JUDGMENT CALLS (each reversible, the reversal named)

1. **The felt gate was judged on PRESENTED FRAMES, A/B, not on my eyes alone** — region videos (one frame per screen update, up to 120 Hz) around every mount act on this build and a pre-U3 scratch build, each presented state classified from the pixels. The collapsed article is objective (5/5 vs 0/5) and ~50–83 ms long; whether that is *felt* is ultimately her sentence's call. *Reverse by* her judging it not felt: the shape is recoverable exactly (`e113dd56` + `8a93eb24`), its pins included.
2. **The revert is WHOLE** — the flagged-shape observation seam went with it (a seam with no consumer is dead code; it is one `git show` away for any next attempt). *Reverse by* re-applying `8a93eb24`'s seam alone.
3. **The rider's seam and pins are KEPT after the revert** — the verdict is independent of the shape (its numbers are byte-identical before and after the revert) and TK2 behaviour is point-release-gated (§5). *Reverse by* deleting both and keeping the verdict in prose.
4. **The fixture fix is the ORDER, not a ⌘↑ reset** (reasoned in row 8: B5's recipe IS the measured full Study pass; a reset would rewrite an untraced bug's recipe). The cost it carries — one intermittent `read-landing` signpost miss sighted on the new history — is recorded as NOTICED 2. *Reverse by* restoring the order and adding `⌘↑` at `scn_b5-return-after-cmd-down`'s start (then re-baseline B5 in both voices).
5. **While built, the canary kept its synchronous write** (it fires only on a TK1 fallback — never in any measured run; the banner has no AppKit frame to answer for it; its echo already lands the write). Moot after the revert; stated for the next attempt.

### NOTICED, NOT TOUCHED

1. **Compare's mount presents a one-line COLLAPSED column for one to two frames on BOTH builds** (every block cut to its first 24-pt line before the full column — `compare-mount-{U3,preU3}-states.png` in `notes/plans/18l-screens/18lb-u3/`): PRE-EXISTING, the same shape as the Takes collapse the ratified shape introduced, on the board where the synchronous write already could not prevent it (pane mounts inside SwiftUI's own update). Proposed owner: 12 (the pane-stability family).
2. **An intermittent note-Read signpost miss** — `read-landing` ▸ read ▸ block 245 (cold), full Study pass `052516`: the block ARRIVED at its anchor (rl −0.1) but no `landing surface=ReadNote` line was filed (the log store holds the preceding face switch's `end=settled` and nothing for the click); 1 of 3 Study runs of the scenario on the new order (`055414` and `060002` filed all six). A landing that places its block and files nothing is the silent-ending class U2's fix pass closed for Takes (FP-2) — on note Read's surface (U1's). Untraced; the product code there is untouched by this unit. Proposed owner: 12 (the landing/settle family, beside row 42), or 18l-b's closeout to re-own.
3. **The KnownIssues row 92 class reached `ReadModeTests.aRealClickOnAPageReachesTheHostWithTheBlockUnderIt`** — not one of the row's three named suites, but the same shape (it posts a real click): red in the blast run with someone at the machine, green isolated and in the idle closing run. Row 92 may want the name.
4. **`PaneSurfaceTests.everyPaneStateWriteLeavesThroughThePublishDoor`'s doc still says a write "inherits the sync-write + bounded-heal discipline"** — true again after the revert (it was the one pre-existing doc that would have gone stale had the shape shipped).
5. **The walk fixture lives in the dev store:** a bookless note **"U3 walk big fans"** (12 blocks; block 1 holds 12 takes, every other block 2) — kept for the orchestrator's replay of the felt walk (`notes/plans/18l-screens/18lb-u3/felt-walk-scenarios.patch` re-applies the throwaway scenarios; `felt_frames.py` / `classify.py` analyse the videos). Compare's related-blocks chip the fixture turned off is session-local (never persisted). Delete the note at will.

### OWED AT CLOSE (drafted for the orchestrator — nothing below was applied)

- **THE LEDGER:** row 4 → **REVERTED at the felt gate — a valid close** (built `e113dd56`, measured 1,106 → 0, reverted `b60e5d6d`; the observation: the Takes mount's collapsed article, 5/5 vs 0/5); row 5 → **PROVABLY SAFE** (two grounds, both measured; tripwire kept); row 6 → **REPORTED: a neighbour, its own slot recommended** (the orchestrator's ruling); row 8 → **NOT TAKEN** (stays 12).
- **KnownIssues — a row for the warning family, now unowned by 18l-b** (proposed text): *"`PanePublisher`'s synchronous height write inside `PaneSurface`'s `makeNSView`/`updateNSView` IS the whole 'Modifying state during view update' family (18k C3's attribution, confirmed from the other side at 18l-b U3: set B 1,106 → 0 while removed). The author's ratified frame-synchronous / state-deferred shape was built and REVERTED at her felt gate: the lever sizes the pane's NSView, but the slot she sees (row, ring, clip) follows the deferred state, so the Takes board's mount presents a collapsed article for 50–83 ms (5/5; 0/5 without it). Hygiene only — nothing user-visible stands. Options for her next ruling: (a) accept and document; (b) defer ONLY the writes made inside make/update (the one flagged shape, 18k C3 M1) and keep the layout-pass and event-road writes synchronous — UNBUILT and UNMEASURED (the collapse's state is the first real measure, made in `layout()`, which C3 measured is never flagged, so this variant plausibly keeps the warnings off and the flash out); (c) re-attempt the ratified shape with the SLOT answered too (e.g. a representable `sizeThatFits` answering the measured height) — a design of its own. Owner: the author's call / 12."* Plus rows for NOTICED 1 (Compare's pre-existing one-line collapse — 12) and NOTICED 2 (the intermittent note-Read signpost miss — 12 or the closeout), and row 88 (B5) re-owned per the orchestrator's B5 ruling.
- **TEXTKIT2_NOTES §3 (canon):** the rider line drafted in THE RIDER above.
- **AppSpec:** none (no contract moved — the publisher ships unchanged). **MOBILE PARITY:** nothing mobile-visible. **QUESTIONS:** none opened by this unit (the A1 follow-up is her call to be surfaced, drafted above — the orchestrator may file it as #152).

### SELF-ASSESSMENT

**Strongest evidence.** The unit measured before and after with the same bounded command and the numbers are exact and deterministic: set B **1,106 · 1,106 → 0 · 0 → 1,106** (before, built, reverted), and the 191-suite set **0 (built) vs 2,393 (reverted)** — 18k C3's attribution confirmed from the other side, the A1 hypothesis exceeded (all of the family, not the majority). The ratified contract was pinned red-first (4/4, 12 issues on the old publisher, the mounted pin at the flagged mechanism itself) and a named behavioural revert reddened exactly its predicted nine. The felt gate was decided on presented frames, A/B against a pre-U3 build on the same dev store (the stamp rule admitting it), with a per-state classifier: the collapse is 5 of 5 vs 0 of 5, its frame is in the record, and the same instrument shows Compare's one-line collapse is pre-existing — so the revert is attributed to exactly the regression the shape introduced, not to noise. The rider's verdict rests on two measured grounds, including an adversarial arm that removes every production safeguard and still moves no clip, and its numbers are byte-identical across the revert. The fixture fix is proven by the full seeded suite reading the baseline exactly, and the closing set is 1114/191 green on what ships.

**Weakest points, for the reviewer.** (a) **The felt judgment is mine and the instrument's, not hers**: 50–83 ms is visible in the frames, but her gate is her felt experience — the orchestrator's walk and her morning confirm are the real close (the shape is one `git revert` of `b60e5d6d` away). (b) The A/B ran in Terminal/light for the Takes-mount repeats; the post-revert walk covered both voices × both appearances, but the SHAPE was only walked in Terminal/light before the gate fired. (c) The typing-growth act never ran on either build (the safety rule skipped it) — the ring-follows-typing question stays unmeasured. (d) The adversarial rider arm's non-vacuity threshold (the viewport's first fragment moving > 20 pt; measured 25) is fixture-specific. (e) The fixture fix is sighted beside one intermittent `read-landing` signpost miss that I cannot attribute (1 of 3); a reviewer may prefer the ⌘↑ reset (JC 4 names the reversal). (f) The B5 report's "neighbour" verdict is reasoned from the recorded B5 measurements and the code roads, not from a new trace of the ⏎ pass. **U3 — DONE (implementer), closed as REVERTED under her gate; the Fable cold review follows.**

### U3 — ORCHESTRATOR ACCEPTANCE (2026-09-27; verify-never-trust) — CLOSED AS REVERTED, a valid close

**Claims verified against git and disk:** 15 commits pushed, tree clean, no trailers; the revert's
byte claims re-run by this seat — `git diff 545375bc..HEAD -- PaneSurfaceTests.swift` EMPTY,
`PaneSurface.swift` = 35 changed lines (the rider's observation seam only); the set-B logs read
**1,106 → 0 → 1,106** exactly (before / built / reverted — the WHOLE warning family, 18k C3's
attribution confirmed from the other side and the A1 hypothesis exceeded); the closing run
`1114 tests in 191 suites passed` read; the felt evidence's classification read (the shipped
build's Takes mount = **2 states, 117–133 ms**, both voices — the collapse classifier finds none).

**The walk (the acceptance's use-shaped half): HELD AT THE GUARD, deliberately.** This seat's
harness pass refused (`guard: someone is at the machine — STOP`) — the author is at the machine
and the per-step rule held exactly as designed; no GUI was driven. The hold is honest and cheap:
the SHIPPED felt surface (the publisher) is **byte-identical to the U2-final tree** this seat
walked three times at U2's acceptance; the implementer's post-revert walk classified all four
voice × appearance combos at two clean mount states; and the felt gate's REAL close is her
sentence — **her morning confirm rides the bundle** (the shape is one `git show` away —
`e113dd56` + `8a93eb24` — if she rules the 50–83 ms collapse not felt). **DISCHARGED the same
hour:** she stepped away and said so; this seat's held pass ran on the shipped tree —
`takes-landing` **6/6 PASS** (`notes/plans/vis-walks/2026-09-27/063430/`; the bloom door
`hops=1 end=settled`); the first attempt's instant abort was her just-left input inside the
guard's idle threshold — the guard working as written.

**Orchestrator adjudications:**
- **The REVERT close is ACCEPTED** — her gate's letter, honored on frame evidence (5/5 vs 0/5,
  A/B against a pre-U3 build, per-state pixel classification), not on taste. The measurement
  survives the revert: the warning family is now a MEASURED, understood cost with a fork that is
  hers — filed as **QUESTIONS #152** (accept-and-document · defer only the flagged make/update
  writes, unbuilt-and-unmeasured · re-attempt with the SLOT answered — the implementer's drafts,
  never re-decided here).
- **The rider's verdict is ACCEPTED** (PROVABLY SAFE, two measured grounds, the adversarial arm
  the stronger); the TK2 §3 line lands with this acceptance (a measurement record, the 18l
  settle-net precedent); the tripwire pins stay.
- **THE B5 RULING (the roster's decided-at-U3, mine):** B5 takes **its OWN SLOT — U-B5, run
  after U4.** The exam's evidence rules the rider road out (Write's full-document editor, the
  differential ⏎ road, no pane, no app-side `layoutViewport()`, the OPPOSITE symptom), and the
  report's instrument-then-decide scope is adopted as U-B5's shape: instrument the ⏎'s pass in
  the deterministic Study recipe, then choose between the anchor-preserving correction (the
  `ScrollAnchorController`/`topVisibleOffset` family) and pre-edit layout of the region above the
  caret. Fable review (the Write editor seam). If U-B5 runs long, the round closes at a clean
  seam with row 88 re-owned honestly and the trace progress recorded — never silently dropped.
- **JC 1–5 ACCEPTED** (the frames-not-eyes instrument; the whole revert; the kept rider seam; the
  ORDER fixture fix over the ⌘↑ reset — with its recorded cost, the 1-of-3 note-Read signpost
  miss, filed as its own KnownIssues row, owner 12, the U2 FP-2 filing shape named as the known
  remedy); row 85 NOT TAKEN accepted; **KnownIssues landed with this acceptance:** the warning-
  family row (owner: her #152 ruling / 12), Compare's pre-existing mount collapse (12), the
  note-Read signpost miss (12), row 88 re-owned to U-B5, row 92 gains the `ReadModeTests` name.

The Fable cold review over U3's diff (`545375bc..HEAD`, what ships + the built-then-reverted
pair for completeness) is the remaining gate; ladder file `notes/plans/18lb-u3-ladder-round1.md`.

## U4 BRIEF (session 3 — the one-liners; written by the orchestrator 2026-09-27 at U3's ladder close)

You are the `opus-implementer` for **18l-b UNIT U4**. One acceptance unit, the round's smallest:
the charter's three one-liners (`notes/plans/post-13u-health-rounds.md` KICKOFF 2, the U4 bullet
— your unit charter), each landed alone, each pin-preserving.

**Read first, in this order (reading is never delegated):**
(1) THIS file whole — HER KICKOFF MESSAGE, BINDING PRINCIPLES, CAST & DISCIPLINE, BASELINES,
ENVIRONMENT TRAPS (verbatim binding), THE LEDGER (rows 7–8), the U2 and U3 RECORDs + acceptances
(the freshest landing-family facts: the aim kind, the watch, `fileEnding`, the fixture order).
(2) The charter's U4 bullet + the health review §1.3 items 2 and 4 (the D1 collapse's reasoning;
the `utf16Offset` dead-field finding).
(3) The 18l record's **U0 RECORD sweep row S4** (`notes/plans/phase-18l-navigation-feel.md`) —
the NEW evidence your `utf16Offset` decision weighs: a book-Index LANDING (the Read ▸ Scroll
click-through, `requestLanding`) parks the caret at the block END via `.leave` — her blank-line
artifact, measured by a scratch probe (caret 329 of 329) — because the landing carries no offset;
the 18l ledger row 11's own words: *"`LandingTarget.utf16Offset` wired-or-deleted is exactly the
question of where a landing's caret goes."* Also U0's fix machinery (`ReadTierClickPlace`,
`MarkdownRendering.sourceOffset`) — the pinned display→source translation a wire could ride.
(4) KnownIssues rows 42 (the U2 amendment), 58 (chip wrap vs the manifest — your D1 item's
neighbour: a changed height source must not re-enter its drift class), 95–97 (U3's new rows).
(5) The code: `Shared/LandingTarget.swift` (the field + its doc); every `requestLanding` /
`pendingLanding` / `requestLiveBlock` consumer (`BookViewModel`, `BookView`, `BookIndexView`,
`BookIndexEditModel`, `ReadModeView`, `BlockHistoryPane` — grep the tree yourself); the Read ▸
Scroll click-through road end to end (the sentence click → `LandingTarget` → the Index's landing
→ `caretLanding(forVariant:)`/`.leave`); `Features/BookView/ReadingFlowView.swift` whole
(`FlowStoryRow` :1066, its `FlowHeightEstimate.honestHeight` read :1146, the manifest read the
same file makes, `BookHeightManifest.resolve`, `FlowExtentsCache`); the book Outline's landing
adoption (`BookView`/the outline column — find the missing `.onDisappear { landing.end() }`
against the flow's and Index's R2-12 lines); the pins that ride these surfaces
(`BookOutlineLandingTests`, `ReadingFlowLandingTests`, `BookIndexLandingTests`,
`IndexClickCaretTests`, `LandingAuthorityTests`).

**The unit, in order — three items, each its own commit:**
1. **The Outline's `.onDisappear { landing.end() }`** (R2-12 parity — the flow and the Index
   both carry it, citing the ladder line; the Outline is the one adopter without it). One line +
   its citation comment. Evidence: the R2-12 pins' form if one exists to extend cheaply; else
   the parity is the evidence (say so).
2. **`LandingTarget.utf16Offset` — wired or deleted, decided on the trace, PROVISIONAL either
   way (QUESTIONS #153):** TRACE the click-through road first — does the Read ▸ Scroll sentence
   click KNOW an offset today (U0's `ReadTierClickPlace` exists on the read tiers; does this
   road's face have the machinery, or would wiring need new translation work)? Then decide:
   **wire** (the click's offset rides the landing and the Index's pane lands the caret at the
   clicked place — S4's artifact dies; the charter's lean reversed on U0's evidence) or
   **delete** (+ the comment naming the `FocusedBlock` road, the charter's lean — and then say
   what happens to S4's blank-line artifact: `.leave` stands, or the landing's caret parks at
   `.start` as a cheaper artifact fix — a smaller, separate call, stated). Build the most
   spec-defensible option, mark PROVISIONAL, log #153 with both readings and your measured
   reason (the U0c #150 form). **Product fence: where a landing's caret goes is
   product-adjacent — your warrant is her U0 report's class (the caret on the blank line is the
   artifact she reported); anything beyond that class is a STOP.**
3. **`FlowStoryRow` reads `BookHeightManifest.resolve`** instead of `FlowHeightEstimate
   .honestHeight` (D1 — verified live at this round's kickoff, :1146): the health review calls
   it small, mechanical, pin-preserving — the two agree today only by accident of a nil
   argument. The proof is `BookOutlineLandingTests` + `ReadingFlowLandingTests` riding
   UNMODIFIED and green (row 58's drift class is the hazard: a changed height source that moves
   landings reds them — a red here is a FINDING, not a nudge to edit a pin).

**WALK (USE, cheap, per-step guarded, both voices):** the Outline — open a book, land deep via
the outline, switch modes mid-landing (the `.onDisappear` road), return; Read ▸ Scroll — expand
stories, deep-click a sentence (the click-through's caret: capture where it lands, before/after
if item 2 wires), scroll the flow (heights honest, no jump); the harness as regression cover
(the full seeded suite, both voices — the baseline: 0 FAIL / 0 ERROR / 0 XPASS, XFAIL 5).

**Discipline (the resiliency protocol, restated — it binds you):** commit per item, push after
EVERY commit, NO trailers; append a `## U4 RECORD` section to THIS file with LIVE STATUS from
your FIRST commit (unverified claims PENDING); records before final verification; synchronous
foreground waits only; NEVER spawn subagents; commit before any behavioral revert;
pathspec-limited staging; tests at the END (the landing family + the book/flow suites + the
eleven Tutorial suites, suite-level `-only-testing`). PROVISIONAL-and-continue for non-gating
ambiguity; STOP and report for gating ambiguity, product-behavior invention beyond the stated
fence, anything wanting `Sync/`, and every author-only call. **Review: `opus-reviewer`** per her
kickoff — unless your diff drifts onto the editor seam (`EditorTextView` / `PaneSurface` bodies /
`PaneTextAuthority`) or a default's meaning: state plainly which it is. Your self-assessment
closes your record.

## U4 RECORD (implementer: `opus-implementer`, 2026-09-27)

**NOT DONE (first line — against what shipped):** (1) **#153's (b) is NOT built** — no clicked place rides a landing (Read ▸ Scroll would need a third `ReadTierClickPlace` tier; Read ▸ Pages' wire is cheap — CoreText's index + `PageBlockRange` + U0's `sourceOffset` — but either lets Read's own pages seed a caret at a character, #149's open question, and Pages alone would split her two Read faces): product calls beyond the brief's fence, hers; (2) the sidebar note box's "edit here" in Index now lands at the block's START (was the END, the blank line) — NOT at her remembered caret, which the `FocusedBlock` memory holds and its Outline branch already uses: named in #153, not built; (3) **THE KEYBOARD STALL** (2 Terminal sightings at `mode-roundtrip` in the harness, then 10/10 across both builds) is recorded, NOT traced — outside this unit's surface and not on its road; owner proposed 12; (4) row 85 (O-2, Write's ⌘↓ ring) NOT touched — no Write ring/overlay refresh in this diff; stays 12 (U-B5 its last chance); (5) no KnownIssues / AppSpec / TEXTKIT2_NOTES / canon edits — QUESTIONS #153 (filed, as the brief asks) and #97's dated pointer are the only ledger edits; the rest is drafted under OWED AT CLOSE; (6) zero `Sources/`, `Sync/`, schema, `EditorTextView`, `BlockRangeIndex`, `PaneTextAuthority`; `PaneSurface.swift` gets ONE DOC LINE (its `PaneCaretLanding` host list), no body — core runs not owed; the iOS build (`LandingTarget` is `Shared/`) SUCCEEDED (LIVE STATUS 7).

### LIVE STATUS

| # | Piece | Status |
|---|---|---|
| 1 | Reading (the brief's "Read first" list, in order, own context) | DONE — this file whole (HER KICKOFF MESSAGE, BINDING PRINCIPLES, CAST & DISCIPLINE, BASELINES, THE UNIT ROSTER, HER OPEN ITEMS, ENVIRONMENT TRAPS, THE LEDGER, the U2 BRIEF + RECORD + bloom-race fix pass + both acceptances, the U3 BRIEF + RECORD + acceptance, the U4 BRIEF); the charter's KICKOFF 2 (`post-13u-health-rounds.md` — the U4 bullet) + the health review §1 (§1.1–§1.5; §1.3 items 2 and 4 in full); the 18l record's SITTING RECORD (R-18l-5 — the #149 carve-out), the U0 RECORD whole (ITEM 1's mechanism + fix — `ReadTierClickPlace`, `MarkdownRendering.sourceOffset`; THE SWEEP's S4 row) + its acceptance; QUESTIONS #97 (the START/END edge — the Book Index's landing listed among the `.leave` hosts "by inheritance, never by ruling") · #149 · #150 (the form) · #151 · #152 (next free **#153**); the 17o ladder's "considered and cleared" on the `read`-face click-through asymmetry (`use-report-round-2026-09-06.md`); KnownIssues rows 42 · 58 · 95 · 96 · 97; `SessionResiliencyProtocol.md` whole; `TEXTKIT2_NOTES.md` whole; the code: `Shared/LandingTarget.swift`, every `requestLanding` / `pendingLanding` / `requestLiveBlock` consumer (`BookViewModel`, `BookView` ×3 producers — the flow's `onWake`, the paged `onWake`, the note box's `editHere`; `BookIndexView.landOrSeed` + the pane row's `takePendingLiveBlock` + `blockView`'s `caretOnGoingLive`; `BookIndexEditModel` whole; `ReadModeView.openInEdit`/`landIfPending`; `BlockHistoryPane`'s `FocusedBlock` doc), `CommandRouter`'s `focusedBlock`/`noteFocusedBlock`/`currentBlock(for:)`, `PaneCaretLanding` + `noteLiveness`, `Surface/ReadTierClickPlace.swift` whole, `PageLeafView`'s hit test, `ReadingFlowView.swift` whole (`FlowStoryRow`, `heightManifest`, `FlowHeightEstimate`), `Surface/BookHeightManifest.swift` whole, `BookViewModel`'s `outlineRowInput`/`indexPaneRowInput` (the row-side `resolve` pattern), `SurfaceSizeMemory.remember`/`StableSurface`'s remember guard, `BookView`'s Outline body + its authority, `Surface/LandingAuthority.swift` whole; the pins: `BookOutlineLandingTests` · `ReadingFlowLandingTests` · `BookIndexLandingTests` · `IndexClickCaretTests` · `BookIndexEditingTests` · `ReadingFlowEstimateTests` · `LandingAuthorityTests` (suite list) |
| 2 | Item 1 — the Outline's `.onDisappear { landing.end() }` (R2-12 parity): red-first pin → fix → green | DONE — **the mechanism (traced at the code):** the Outline's `LandingAuthority` is `BookView`'s `@State`, not the Outline body's, so a MODE SWITCH mid-landing removes the rows and the scroll view but leaves the authority armed; nothing reports any more, and its next look decides on the target's last report — `DONE: settled` after the hold (or corrections through the dead `ScrollViewProxy` until `gave up`), and in Release a signpost line for a surface already gone. (A window close is safe: the `@State` dies with `BookView` and the work item captures `[weak self]`.) **Pin** `OutlineLandingTeardownTests.aModeSwitchMidLandingLeavesTheOutlinesLandingNoDoneToWrite` (NEW file — R2-12's own form on the Outline's road; harness copied so `BookOutlineLandingTests` rides byte-unmodified), committed first (`a39bd5cb`, compile fix `3e02eeb2`) and run on the pre-fix tree: **RED, 1 issue** — `DONE: settled at top=0.0 after 0 hops, 1014 ms` written after the switch, every premise green (the landing began; nothing before the switch; still in Index) (`App/Variorum/DerivedData/18lb-u4-item1-red.log`). **Fix `9bf7f460`** — `.onDisappear { landing.end() }` beside the Outline's `.onAppear`, citing R2-12. **GREEN**: `DONE lines after the switch: []` (`18lb-u4-item1-green.log`). The pre-fix run IS the behavioural revert (the two trees differ by exactly the fix's line + its comment) |
| 3 | Item 2 — `LandingTarget.utf16Offset` wired-or-deleted, decided on the trace (#153, PROVISIONAL) | DONE — **DELETED + the landing's caret at the block's START** (THE ITEM-2 TRACE AND DECISION below). **Pins** `IndexLandingCaretTests` (NEW file; `BookIndexEditingTests` rides byte-unmodified) committed first (`aab07c13`) and run on the pre-fix tree: **RED, 5 issues** — the model armed `.leave` where `.start` is owed (its two guard arms — a click still `.offset(17)`, a focus request `.leave` — green); the mounted road (exactly the flow's `onWake`: `requestLanding` + mode → Index) parked the caret at **224 of 224** (the click-through) and **247 of 247** (a block-less landing), both ON THE EMPTY LINE — S4 reproduced in this fixture's numbers (`18lb-u4-item2-red.log`). **Fix `b4841ad1`** — `BookIndexEditModel.takePendingLiveBlock` goes live with `.start` through one private `goLive(…caret:)` both roads share (`makeLive(clickOffset:)`'s signature and U0's `.offset` arm unchanged); `LandingTarget.utf16Offset` deleted, the comment naming the `FocusedBlock` road; three docs that named the Index landing as `.leave` amended (`PaneCaretLanding`'s host list — a DOC line in `PaneSurface.swift`, no body; `BookIndexView`'s call-site comment; `BlockHistoryPane`'s `FocusedBlock` doc, which cited the deleted field); QUESTIONS **#153** filed, **#97** gains a dated pointer (its `.leave` list named this host). **GREEN**: caret **0 of 224** and **0 of 247**, the model pin green (`18lb-u4-item2-green.log`). The pre-fix run IS the behavioural revert (the trees differ by the `.start` line and the deletion of a field nothing set, plus comments) |
| 4 | Item 3 — `FlowStoryRow` reads `BookHeightManifest.resolve` (D1) | DONE — **the two rules, traced:** the row stood at `FlowHeightEstimate.honestHeight` (remembered at this width, else the estimate) while the column's manifest — every flow landing's offsets — resolved the story through `BookHeightManifest.resolve` (measured > remembered > derived; a non-positive or non-finite answer falls through). They agree on every REACHABLE input today (a story's input has no measured arm — the flow passes `height: nil` for stories on purpose; and no production road remembers a non-positive story height: `StableSurface` remembers only above its placeholder ceiling, the empty read remembers 20, a persisted record refuses ≤ 0). **Pin** `FlowStoryHeightOneBrainTests` (NEW; the contract "for every input the row's height IS the manifest's") committed first (`e26bc74a`), run on the pre-fix tree: **RED, exactly and only the 6 degenerate combinations** (a remembered height ≤ 0 at the matching width — row 0/−5, manifest the estimate), the 30 reachable ones already agreeing (`18lb-u4-item3-red.log`) — the drift made visible, NOT a user-visible defect. **Fix `2442731b`** — ONE input builder, `FlowHeightEstimate.storyInput(id:remembered:columnWidth:estimate:)`, asked per ROW (`FlowStoryRow.honestHeight` = `BookHeightManifest.resolve(storyInput(…)).0`) and per COLUMN (`heightManifest`'s `.post` case) — the Outline's `outlineRowInput` / the Index's `indexPaneRowInput` shape; `FlowHeightEstimate.honestHeight` kept as a forward through it (its `ReadingFlowEstimateTests` arms ride unmodified). **THE PROOF — green, the pre-existing pin files UNMODIFIED** (`git diff 3389fedb..HEAD` of `ReadingFlowLandingTests` · `BookOutlineLandingTests` · `ReadingFlowEstimateTests` · `BookIndexEditingTests` · `IndexClickCaretTests` · `BookIndexLandingTests`: empty): **30 tests / 5 suites** (`FlowStoryHeightOneBrainTests` · `ReadingFlowLandingTests` 8 · `BookOutlineLandingTests` · `BookOutlineRowsTests` · `ReadingFlowEstimateTests`) in 58.9 s (`18lb-u4-item3-proof.log`) — the flow landings at `top=0`, ≤ 1 re-land, the twelve-story mount realizing 1 surface: row 58's drift class did not re-enter. Cost: the row's body builds one small value + a string id per evaluation (O(1), same observation dependency on `memory.size` as before) |
| 5 | The walk (USE, both voices, per-step guarded) | DONE — **driven through VisualWalk's guarded doors as the NEW seeded scenario `book-landings`** (`cdb9f3f0`, fixture fixes `6d1164f5`; appended LAST in `SCN_ORDER` so no earlier recipe changes; README row) on the stamped build of this tree (`cdb9f3f0`: app `6a42e0ec8ad7`, core `4b9d3b2f7991`), the machine author-free (HID idle 88 min, zero instances, own `caffeinate -d`): **PASS 7/7 in BOTH voices** — `notes/plans/vis-walks/2026-09-27/081039/` (report.md, run.log, captures `{terminal,study}/book-landings/01…06`). Her Console, verbatim (Terminal · Study): **A — the Outline landing ended by a mode switch** (the navigator's Copper Beeches row, Index 0.3 s later, one guarded act): the Index landed the story (`landing surface=BookIndex rows=26 target=25 … hops=1 … end=settled top=0` — the click took) and **NO `BookOutline` line** in either voice; **A's control** (back in Outline, Beryl Coronet's row, no switch): `landing surface=BookOutline rows=26 target=23 offset=1975 total=36475 derived=1 exact=1 hops=0 content=2 ms=1026 end=settled top=0` · `… offset=2256 total=41829 … hops=0 … end=settled top=0`; **B — Read ▸ Scroll, the carry lands the story on the flow's manifest**: `landing surface=ReadingFlow rows=28 target=23 offset=28670 total=69990 derived=24 exact=0 hops=2 content=6 ms=1488 end=settled top=0` · `… offset=101317 total=142637 derived=20 … hops=2 … ms=1825 end=settled top=0`; **C — the click-through on the story's third paragraph** ("He was a man of about fifty…", a block over her blank line — `nl=1` asserted): the Index pane live with **`sel=0,0`, caret line 0, first paragraph — "on-text", never the blank line** (the Index's block landing `landing surface=BookIndex rows=26 target=-1 offset=-1 … hops=0 … end=settled top=0`); capture `04` read by this seat: the paragraph live at the pane's top in its ring, the caret before "He", the ring's empty last line empty; **D — back to the flow + a long wheel up through the stories above**: the carry's landing `… hops=2 … end=settled top=0`, and the page two seconds after the wheel BYTE-IDENTICAL to the page at +1.5 s (`cmp`) in both voices — heights honest, nothing jumped. The dev store's voice restored to Terminal (run.log). **THE SCENARIO'S TEETH, and the `hops=2` attribution, on a pre-U4 scratch build** (a worktree at the kickoff tree `3389fedb` — App/ differs, the core `4b9d3b2f7991` is this tree's, so the stamp rule admits it; built by `build.sh --src`, run by `VW_DD`, the worktree removed after): **`book-landings` FAILS 4/7 in BOTH voices, exactly the predicted rows** (`vis-walks/2026-09-27/081642/`) — **A:** the pre-U4 Outline filed `landing surface=BookOutline rows=26 target=25 offset=2149 total=22400 derived=0 exact=1 hops=0 content=0 ms=1007 end=settled top=0` (Study `… offset=2455 total=25597 … ms=1016 …`) about a second after the switch — a "settled" landing in her Console for an Outline already gone (item 1's artifact, seen from her side); **C:** the click-through's caret at **`593,0` of a 593-character block — ON THE BLANK LINE**, caret line 10 (Terminal) / 8 (Study) (S4, reproduced in her own Sherlock). The control, B and D pass on both builds; **the flow's `hops=2` is identical on the pre-U4 build** (`… derived=17/18 … hops=2 … end=settled top=0`) — pre-existing, the flow's own corrections from quiet over estimated stories (budget 6), not item 3's (which is behaviour-preserving on every reachable input) |
| 6 | The harness as regression cover (the full seeded suite, both voices) | DONE — the full seeded suite (14 scenarios with `book-landings`), both voices, on the stamped build of this tree: `notes/plans/vis-walks/2026-09-27/082126/`. **Study: 0 FAIL · 0 ERROR · 0 XPASS**, XFAIL 3 (S3 on `index-click` + `readedit-click`, B5 on its measured recipe), `takes-landing` and `book-landings` PASS. **Terminal: `mode-roundtrip` FAIL, then 7 ERRORs** — its ⌘3 never reached Read and the pass drifted from there (THE KEYBOARD STALL below: an intermittent harness sighting, NOT attributed to U4 — measured on both builds). **Terminal re-covered, the same build, clean:** the pass's prefix `note-reopen … mode-roundtrip` 5/5 PASS (`090324/`) and `index-click … read-landing` in pass order (`091039/`: `index-click` + `readedit-click` XFAIL (S3, labelled), the outline pair, the B5 pair (plain in Terminal) and `read-landing` PASS); `takes-landing` + `book-landings` PASS in `082126`. **So every seeded scenario has a clean run on this build in both voices, reading the baseline exactly: 0 FAIL · 0 ERROR · 0 XPASS, XFAIL 5 = the two labelled knowns (S3 ×4, B5 in Study).** The dev store's voice ends Terminal (read back from each run.log); zero instances after |
| 7 | Closing runs (the landing family + the book/flow suites + the eleven Tutorial suites) | DONE — `App/Variorum/DerivedData/18lb-u4-closing.sh`: U3's 191 grep-verified suites (U2's 101 — the landing family, the whole Takes board family, the Read + book landing family, the eleven Tutorial suites — ∪ the pane family) ∪ the 27 book/flow/read suites it lacked ∪ U4's three new ones = **221 suite type names, each grep-verified as a `@Suite`**, zero instances, the machine author-free (HID idle since the harness's last act): **`✔ Test run with 1287 tests in 221 suites passed after 586.425 seconds`**, `** TEST SUCCEEDED **`, `EXIT 0`, zero `✘` (`App/Variorum/DerivedData/18lb-u4-closing1.log`; 222 `Suite … started` lines against 221 asked — the U2/U3 +1; **7 tests SKIPPED by design** — the env-gated `DebugOracleSingletonWindowTests` — so 1,280 ran). 2,410 `Modifying state during view update` lines — the standing `PanePublisher` family (KnownIssues row 95, QUESTIONS #152; U3's 191-suite set read 2,393), not attributed here: this diff adds no state write. **The iOS build** (`LandingTarget` is `Shared/`): `xcodebuild build -scheme VariorumMobile -destination generic/platform=iOS` — **`** BUILD SUCCEEDED **`** (`18lb-u4-ios.log`). Core `swift test`: not owed (zero `Sources/`) |
| 8 | Self-assessment | DONE (below) |

- Deaths / resumes: none.
- Reverts in flight: none.

### THE ITEM-2 TRACE AND DECISION (#153, PROVISIONAL — the brief's "decide on the trace")

**The click-through road, inputs → the wrong caret (read at the code, then measured by the pin).** Read ▸ Scroll:
`FlowPostView` draws each block as SwiftUI `Text` paragraphs under ONE `.contentShape(Rectangle()).onTapGesture {
onWake(block.blockID) }` — a tap with NO location (its own doc: *"the click maps to a block, never to a text offset (a
SwiftUI `Text` cannot say where inside itself)"*) → `FlowStoryRow.onWake` → `BookView`'s flow `onWake` →
`model.requestLanding(LandingTarget(postID:blockID:))` + `structure.mode = .index` → `BookIndexView.landOrSeed` →
`edit.requestLiveBlock(landing)` + the note selected and scrolled → the note's pane row adopts its rows →
`edit.takePendingLiveBlock` → `makeLive(…)` with no click offset → `caretLanding(forVariant:)` = `.leave` →
`PaneSurfaceView(caretOnGoingLive: .leave)` → `noteLiveness(true)`'s `.leave` arm moves nothing → the selection stays
where `string =` left it: the take's END, which in her notes is AFTER the trailing `\n` — the empty line. **Measured:**
U0's probe 329 of 329; this unit's pin 224 of 224 (and 247 of 247 for a block-less landing). The same `requestLanding`
door is taken by **Read ▸ Pages** (`PageLeafView.mouseDown` → `hit(at:)` → a blockID only) and by the sidebar note box's
**"edit here" in Index** (`BookView.editHere` — a remembered blockID; its `remembered?.utf16Offset` is in hand and
dropped, where its Outline branch parks a `WriteIntent` AT that offset).

**Does the road KNOW an offset today? No face does, and wiring one is new translation work AND a product question:**
- Read ▸ Scroll: nothing — a SwiftUI `Text` tap has no point. Wiring = a THIRD `ReadTierClickPlace` tier for the
  reading page's own type (16-pt system serif, `lineSpacing(6)`, 13-pt gaps, the flow column's width — none of it the
  Index tier's metrics the replica is built on), `ReadTierClickTarget` on the flow's block, and a new fidelity pin.
- Read ▸ Pages: **the offset is nearly in hand — a CHEAP wire, stated plainly because the record's first draft of this
  line said otherwise (corrected at the code before any decision rested on it):** CoreText names the composed-string
  index under the click (`PageLeafView.characterIndex(at:)`), and `PagePaginator.compose` lays each block down as
  `MarkdownRendering.render(text).text` at a known display range (`PageBlockRange`) — the very display space U0's pinned
  `MarkdownRendering.sourceOffset(forDisplayOffset:in:)` reads (`FlowParagraph.paragraphsWithStarts` starts from the same
  `render`). So `index − range.location` → `sourceOffset(…, in: the block's stored text)` is the stored offset: the hit
  returns it, `onBlockClick` carries it, the field stays. A few lines and a pin.
- Both would let READ'S OWN SURFACES seed a caret at a CHARACTER — 13g F-5's law, whose carve-out (R-18l-5, #149,
  PROVISIONAL, hers) grants that only to "the read tiers" (the Index and Read ▸ edit); Read is her A43 reading surface
  whose F-5 docs say a click maps to a block, never to a text offset (and L10: *"Read has no competing gesture at all: no
  caret to place"*). Wiring Pages ALONE would also split her two Read faces (Pages at the clicked character, Scroll at
  the block's start). Both are product calls beyond the brief's fence (her U0 report's CLASS — the caret on the blank
  line), whatever the wire costs.
- The one producer that DOES hold an offset — the note box's remembered caret — gets it from the `FocusedBlock` road
  (`CommandRouter.currentBlock(for:)`), which already carries it to every door that reads it; landing there instead of
  at the start is "where she was", a product step past the artifact class — recorded as #153's (b), not built *[amended at the U4 ladder's round 1, MINOR-2: now its own option, #153's (a′) — the entry rule, #149-independent, no Read-face wiring; still not built]*.

**Decided — (a) DELETE + `.start`, the most spec-defensible option, PROVISIONAL:** the artifact class dies on every
road into the Index by landing (click-through, paged, note box) with one line; `.start` is (1) the value's OWN documented
contract since Act 10 batch B (*"a SwiftUI `Text` paragraph cannot — the landing then puts the caret at the block's
start"* — never true: the pane went live `.leave` from birth, `c768c08e`), (2) 17o batch b's stated rule (*"a surface
with no caret lands at the block's start as today"*), (3) note Read's TWIN click-through on a block she was NOT last in (`ReadModeView.openInEdit`
reports the block first, so the edit face's entry rule lands `.start` there — *[amended at the U4 ladder's round 1, MINOR-2: on the block she WAS last in the twin lands her remembered caret (the memory keeps a known offset for a nil report on the same block), so the asymmetry is closed only for the other blocks; the full twin is #153's (a′), filed, not built]*), (4) QUESTIONS #97's built (a), and (5) exactly where the landing puts her EYES — the landed block's top
at the page's top, where an END can sit below the fold for a block taller than the page. The charter's lean (delete) is
taken; its bare form (c) — `.leave` kept — would leave her artifact standing on this road. **Unchanged:** a CLICK inside
the Index brings its own place (U0's `.offset`); a pane's own focus request arms nothing (`.leave`); every other
`PaneCaretLanding` host. **Product fence:** the one behaviour moved is where a landing's caret parks (END → START), inside
her U0 report's class; nothing beyond it was built. **#97 note:** its `.leave` list named "the Book Index's
clicked-block-goes-live landing" — that one host moves to (a); a dated pointer rides #97.

### THE KEYBOARD STALL (a harness sighting — measured on both builds, NOT attributed to U4, owner proposed)

**What was seen, twice, on this build, Terminal:** `mode-roundtrip`'s ⌘3 (Write → Read, sent 4 s after a click on a
mid-page line of *A Scandal in Bohemia* in Write) never took effect — the full seeded run (`082126/`, 08:24) and an
eight-scenario Terminal re-run in pass order (`084750/`, 08:48, `mode-roundtrip` first after a fresh launch). **The
signature, read off the probe sequence of the re-run:** from the click at 08:48:29 until ~08:50:21 NO keystroke took
effect — the ⌘3, a ⌘1, four `⌘K` + type + ⏎ note opens, another ⌘3 (probes 13–62: `mode=Write`, the main window key,
`fr=editor`) — while every PROBE (answered on the app's main thread), every wheel scroll and the next click were served;
then, right after `b5-return-after-cmd-down`'s click (a fresh mouseDown/Up), the queued keys all landed at once (probe 63:
`mode=Read`, the ⌘K palette's 560×302 window key). Keyboard events HELD in the app's queue behind something a later
click released — the shape of a mouse-tracking loop that its own mouseUp did not end — on WRITE's editor road.
**Attribution, measured:** after those two sightings, `mode-roundtrip` passed **10 of 10** across both builds — the
current build 5/5 (`085508`, `085733`, `085923`, `090113`, and inside the full-order prefix `090324`) and the pre-U4
scratch build (the kickoff tree `3389fedb`) 5/5 (`085328`, `085828`, `090018`, `090208`, prefix `090654`), alternated.
So: intermittent, clustered in time (both failures before 08:50; none after), and never caught on the pre-U4 build in
its 5 tries — which cannot convict or clear a 2-in-7 intermittent (the current build: 2 FAIL, 5 PASS) by rate. **By construction U4's diff is not on the
road:** a note opened in Write outside any book; U4 touches the book Outline's `onDisappear`, the book Index's landing
caret, the reading flow's row height, and an unused field of a value only book/Read doors build — no Write view, no
`EditorTextView`, no event handling. **Not traced further** (a Write-editor event-handling investigation is a unit of its
own and outside this one's surface); the one cheap discriminator for whoever owns it: when it reproduces, `sample <pid> 2`
before the next click — a main thread parked in `NSTextView`'s mouse-tracking loop (`-[NSTextView mouseDown:]` →
`nextEventMatchingMask:`) would confirm the shape. **Proposed owner: 12 (Hardening)** beside KnownIssues row 92's
real-input class — or the orchestrator's call whether it wants a KnownIssues row now (a real user would meet it as
"my keystrokes went nowhere until I clicked again"; no report of hers names it).

### SEAM FILES THIS DIFF TOUCHES (`git diff 3389fedb..HEAD` — the reviewer reads this first)

| File | What changed | What did NOT |
|---|---|---|
| `Features/BookView/BookView.swift` | item 1: `.onDisappear { landing.end() }` beside the Outline's `.onAppear`, citing R2-12 | the Outline's landing, its policy, `landOutlineReveal`, every other modifier |
| `Features/BookView/BookIndexEditModel.swift` | item 2: one private `goLive(…caret:)` both roads share; `takePendingLiveBlock` arms `.start`; docs | `makeLive(…clickOffset:)`'s signature and its `.offset` arm (U0), `caretLanding(forVariant:)`, the authority, flush, teardown |
| `Shared/LandingTarget.swift` | item 2: `utf16Offset` DELETED (set by no production site), the comment naming the `FocusedBlock` road; header | `postID`, `blockID`, every producer's call (all used the two-field init) |
| `Features/BookView/BookIndexView.swift` · `Features/Tray/BlockHistoryPane.swift` · `Surface/PaneSurface.swift` | comments only — the three places that named the Index landing as `.leave` or cited the deleted field (PaneSurface: ONE doc line in the `PaneCaretLanding` host list) | every body |
| `Features/BookView/ReadingFlowView.swift` | item 3: `FlowHeightEstimate.storyInput` (ONE input builder); `FlowStoryRow.honestHeight` = `BookHeightManifest.resolve(storyInput(…)).0`; `heightManifest`'s `.post` case through the same builder; `honestHeight(remembered:…)` a forward | the estimate, the reservation, the near/far virtualization, `StableSurface`, the landing, the manifest's other rows |
| Tests | NEW `OutlineLandingTeardownTests` (1), `IndexLandingCaretTests` (2), `FlowStoryHeightOneBrainTests` (1) | every pre-existing pin file byte-unmodified (`git diff 3389fedb..HEAD -- App/Variorum/VariorumTests/` touches only the three new files) |
| `Tools/VisualWalk/` | NEW seeded scenario `book-landings` (appended LAST) + README row | every other scenario, the guard order, `lib.zsh` |
| `notes/QUESTIONS.md` | #153 filed; #97 gains a dated pointer | — |

**The review cast — my call, stated plainly: `opus-reviewer` (her kickoff's), the diff does NOT drift onto the editor
seam or a default's meaning.** No `EditorTextView`, `PaneSurface` body, `PaneTextAuthority`, `BlockRangeIndex` or
read-tier drawing is touched (one doc line in `PaneSurface.swift`); `PaneCaretLanding`'s DEFAULT (`.leave`) is unchanged
for every host that passes nothing — item 2 changes what ONE host (the book Index's landing) passes, inside the #97 edge
her ruling owns (#153 carries it, PROVISIONAL). If the orchestrator reads #97's START/END as "a default's meaning", item
2 is the one piece a Fable eye would weigh.

### JUDGMENT CALLS (each reversible, the reversal named)

1. **Item 1's pin takes the MODE-SWITCH road, not R2-12's window teardown** — the Outline's authority is `BookView`'s
   `@State`, so a torn-down window takes it along (safe); a mode switch is the Outline's own leak. *Reverse by* a
   teardown-form pin (it would pass on both trees — hollow for this surface).
2. **Item 2 builds #153 (a): delete + `.start`** (THE ITEM-2 TRACE AND DECISION). *Reverse by* one line —
   `takePendingLiveBlock`'s `caret: .start` → `nil` (`.leave`, option (c)); (b) is a unit of its own.
3. **Item 2's `.start` rides every Index landing road** (the flow's click-through, the paged click-through, the note
   box's "edit here") — they share `requestLanding` → `takePendingLiveBlock`, and all three parked on the blank line.
   *Reverse by* a per-road caret on `LandingTarget` (a field this unit just deleted — which is why it is not the call).
4. **Item 3 keeps `FlowHeightEstimate.honestHeight` as a FORWARD through the one brain** rather than deleting it: its
   `ReadingFlowEstimateTests` arms ride unmodified. *Reverse by* deleting it and moving those four arms onto `storyInput`
   (a pin edit). *(Ladder round-1 MINOR-1's fix INVERTED this shape, 2026-09-27: the static is now the ONE rule and the
   row is a single CALL to it — so this reversal recipe is stale; deleting the static would now force the row to copy
   the rule back inline, which is exactly MINOR-1's defect. The ladder file carries the fix.)*
5. **Item 3's agreement pin reds only on degenerate inputs no production road writes** — stated as the drift made
   visible, not a user-visible defect; the landing suites riding unmodified are the brief's proof. *Reverse by* dropping
   the pin (the collapse still holds by construction).
6. **The walk is the NEW seeded scenario `book-landings`** (the U2 precedent) — a standing tripwire proven to red 4/7 on
   the pre-U4 build, with two controls so row A's zero-line claim cannot pass vacuously. *Reverse by* removing its
   `SCN_ORDER` entry (the scenario is self-contained and last).

### COST SHAPE (P1 / P3), stated

- Item 1: one `end()` per Outline disappearance (a cancel and four assignments). Nothing at scroll or keystroke rate.
- Item 2: one enum assignment per landing; the pane's `.start` arm is an existing `setSelectedRange` on the liveness
  transition. Nothing new at any rate.
- Item 3: `FlowStoryRow`'s body builds one small `Input` + a short id string per evaluation where it compared one width
  before — O(1), the same `memory.size` observation dependency; the manifest (built per landing) is unchanged in cost.
  P3 unchanged — the flow realizes exactly what it did (the twelve-story mount pin: 1 surface). *(Ladder round-1
  MINOR-1's fix, 2026-09-27: the Input build now lives inside `FlowHeightEstimate.honestHeight` — the row is one call;
  same cost, one address. LIVE STATUS row 4's and the SEAM FILES `ReadingFlowView` row's item-3 shape read with this
  bracket.)*

### NOTICED, NOT TOUCHED

1. **THE KEYBOARD STALL** (its own section above) — a Write-editor road sighting; owner proposed 12.
2. **The flow's landings take `hops=2` on the Sherlock book** (`derived=17–24` estimated stories above the target) —
   identical on the pre-U4 build; the flow's own corrections from quiet (row 100), inside its budget of 6.
3. **A re-born live Index pane re-applies its host's landing** (`paneCaretLanding` persists for its take until the next
   `makeLive`): pre-existing shape — U0's click `.offset` and the old `.leave` re-landed the same way; with `.start` a
   re-born pane lands at the block's start where it used to land on the blank line.
4. **Terminal's navigator row label carries the selection marker** once its note is focused (`⠿, <marker>, <name>`) —
   an AX-label fact the walk met (the control moved to another story); not a product issue.

### OWED AT CLOSE (drafted for the orchestrator — nothing below was applied)

- **THE LEDGER:** row 7 → **CLOSED** (item 1 red-first + fix; item 2 decided on the trace, #153 PROVISIONAL (a) delete
  + `.start`; item 3 collapsed with every landing pin unmodified; walked both voices; the new tripwire reds 4/7 pre-U4);
  row 8 (O-2) — not touched at U4 either; U-B5 remains its last chance.
- **KnownIssues:** (a) a row for THE KEYBOARD STALL if the orchestrator wants it tracked now (owner 12, beside row 92's
  real-input class); (b) row 58's drift class — the flow's half is now one brain (an optional line on the row: "the
  reading flow's story rows read the manifest's precedence since 18l-b U4 (D1)").
- **AppSpec:** none required (no contract line names the Index landing's caret); an optional §12 pointer beside U0's:
  *"a landing into the book Index puts the caret at the landed block's start (#153, PROVISIONAL)."*
- **MOBILE PARITY:** nothing mobile-visible (`LandingTarget` is `Shared/` but no phone surface builds one; the phone's
  book surfaces are their own).
- **Her bundle:** #153 joins #149–#152 (one line to change either way).

### SELF-ASSESSMENT

**Strongest evidence.** Every item was pinned before it was fixed and each pin ran RED on the tree that preceded its
fix — item 1: `DONE: settled at top=0.0 after 0 hops, 1014 ms` written by an Outline landing whose surface was gone;
item 2: caret **224 of 224 / 247 of 247**, on the empty line; item 3: exactly the 6 degenerate combinations, the 30
reachable ones already agreeing — and each fix turned exactly its pin green. Item 2's decision stands on a trace of all
three `requestLanding` producers, not on the charter's lean, and the one factual slip in my first draft (Pages' wire
"impossible") was caught at the code and corrected in the record, #153 and three comments before anything rested on
it. The walk is USE through the guarded harness in both voices and her Console's lines are quoted verbatim; the new
`book-landings` scenario was run against a pre-U4 scratch build and reds **4/7 in both voices, exactly the two claims
it guards** (the phantom `BookOutline end=settled`; the caret at 593 of 593), so it is a standing tripwire with teeth.
Every pre-existing pin file is byte-unmodified.

**Weakest points, for the reviewer.** (a) **#153 is a product-adjacent call made PROVISIONAL**: `.start` is the most
defensible of the three readings on the record I found, but "where the caret goes" is hers — the note box's "edit here"
in particular now lands at the block's start where its Outline branch lands at her remembered caret, an asymmetry I
chose not to close (beyond the fence). (b) **The keyboard stall is unexplained**: two sightings on this build, none in 5
tries on the pre-U4 build, then 10/10 across both — I attribute it away from U4 by construction (no Write, no event
handling in the diff) and by its clustering in time, not by a captured stack. (c) Item 3's agreement pin reds only on
inputs production never writes — honest as a drift guard, weak as a defect pin. (d) Item 1's pin reads the DEBUG story
(R2-12's own form); the Release signpost's silence is walked (`book-landings` row A), not unit-pinned. (e) The walk's
row C clicks the story the carry landed at the top — a deep landing, but on the flow's first screen, not after a long
scroll. The closing set is **1287 tests / 221 suites green** and the iOS build succeeds. **U4 — DONE (implementer); the `opus-reviewer` cold review follows.**

### U4 — ORCHESTRATOR ACCEPTANCE (2026-09-27; verify-never-trust)

**Claims verified:** 21 commits pushed, tree clean, no trailers; the 3C claim re-run by diff (no
pre-existing test file in the range — only the three new ones); the footprint as recorded
(`PaneSurface.swift` = one doc line; `LandingTarget.utf16Offset` deleted with its comment).
**The walk, in the orchestrator's own hands:** `book-landings` **7/7 PASS**
(`notes/plans/vis-walks/2026-09-27/094021/` era run — the Outline files NOTHING after a mode
switch while its stay-behind control files `end=settled`; the click-through caret `0,0`,
on-text, first paragraph — S4's artifact dead in my hands; the flow settles at `hops=2`, its
pre-existing shape).

**Orchestrator adjudications:**
- **The review cast stays `opus-reviewer`, her kickoff's own assignment** ("Opus on U4" — made
  knowing U4 carried the utf16Offset question). The implementer's honest flag (item 2 sits
  inside #97's START/END edge) is answered by the same-model ladder's own structure: the
  ORCHESTRATOR (Fable) arbitrates every finding against the spec, so item 2 gets its Fable eye
  at arbitration by construction — and this seat has already read the trace: (a) is the
  spec-defensible reading (the value's own documented contract, 17o b's stated rule, the twin
  click-through's behavior, #97's built (a)), PROVISIONAL and hers at #153.
- **The keyboard stall gets its KnownIssues row NOW** (owner 12, beside row 92's real-input
  class) — two sightings is thin, but "my keystrokes went nowhere until I clicked again" is a
  feel bug she could meet; the sample-before-next-click discriminator rides the row.
- **Row 58 gains the D1 one-brain line** (the flow's half of its class collapsed).
- Ledger row 7 flips to BUILT+WALKED; row 8 (O-2) stands not-taken with U-B5 its last chance.

The `opus-reviewer` ladder over `3389fedb..2aa43836` is the remaining gate; ladder file
`notes/plans/18lb-u4-ladder-round1.md`.

## U-B5 BRIEF (session 4 — the B5 trace, its own slot per the U3 ruling; written by the orchestrator 2026-09-27; RE-CHECK against the U4 ladder's outcome before spawning)

You are the `opus-implementer` for **18l-b UNIT U-B5**. One acceptance unit: TRACE, ATTRIBUTE and
(if the trace's fix stays inside the stated fence) FIX **B5** — KnownIssues row 88: *"⏎ right
after a ⌘↓ landing moves the page when a full re-render had invalidated the layout first"* (+109
Terminal / +166 Study measured at U0b's walk on `998f7d7d`; the harness's Study recipe measures
the text above the caret sliding ~30 pt DOWN under an UNMOVED clip while the frame grows +94 pt
for one ~20-pt line). UNTRACED until you; the deterministic recipe exists.

**Read first, in this order (reading is never delegated):**
(1) THIS file whole — ENVIRONMENT TRAPS (verbatim binding), THE LEDGER row 6, the U3 RECORD's
**THE B5 REPORT** (your unit's foundation: B5 is Write's full-document editor on the DIFFERENTIAL
road; no pane, no app-side `layoutViewport()`; the OPPOSITE symptom of the pane exam's mechanism;
*"the jump road compensates (the clip moves — 18k C6, then re-asserted); the edit road does not
(the text moves). That asymmetry … is B5's open question"*), and the U2/U4 records (the freshest
landing facts).
(2) KnownIssues row 88 WHOLE (the full measurement history: U0b's find, U-VIS's fixed-clip
measurement, the probe ruled out of the recipe) + rows 85 (O-2 — your may-take, ITS LAST CHANCE
this round) and 42.
(3) The 18l record (`notes/plans/phase-18l-navigation-feel.md`): the **U0b RECORD whole** (B5's
birth — the walk rows, `ReadingAnchor`, the differential road's promise; B1–B4's mechanisms are
your neighbours), the U0 RECORD's settle-net section (the inline editor's convergence re-report —
the class's other face), and 18k C6/C6b's records (`notes/plans/phase-18k-runtime-hygiene.md` —
the jump primitive's re-assert and `topVisibleOffset()`'s reading-line rule: the compensation the
edit road LACKS).
(4) `notes/TEXTKIT2_NOTES.md` IN FULL (mandatory — §2's estimate class and §3's 27.0 findings are
the two named suspects; your ATTRIBUTION column decides between them, or honestly neither).
(5) The code: `EditorTextView` (the ⏎'s road: `insertNewline` → the typed-Return door →
crystallization / content insert — trace which arm her recipe's tail ⏎ takes with the chip's
state; the typewriter room), `EditorViewModel` (`topVisibleOffset`, `readingAnchor`, the parks,
the DIFFERENTIAL road's apply — where a structural/text change lands WITHOUT a restore step),
`EditorSurfaceController` (`renderFull` vs the differential apply), `JumpPrimitive` whole (C6's
re-assert — the compensation's worked example), `ScrollAnchorController`. The pins that ride:
`WriteTopAirTests`, `RefontViewportTests`, `JumpViewportLayoutTests`, `ScrollAnchorTests`,
`NoteOpenLandingTests` — every one rides UNMODIFIED (a collision is a STOP-and-flag).

**The unit, in order:**
1. **INSTRUMENT the recipe** (the row's own command: `VARIORUM_VISUAL_WALK=1
   Tools/VisualWalk/visual-walk.sh --voices study` — the full pass reproduces B5
   deterministically; `probes.log` holds frame/clip/line around the act; a DEBUG-oracle
   instrument on the ⏎'s pass follows 18k C4's owner-keyed shape if you need more than the probe
   gives): capture, across the tail-⏎'s edit and its display pass — the frame, the clip, the
   first visible line's document y, and its fragment's estimated-vs-laid-out state before/after.
2. **TRACE the mechanism yourself** — why does the text above the caret slide under an unmoved
   clip ONLY when a full re-render (or re-font) invalidated the layout before the ⌘↓? The U3
   report's hypothesis (the region above the tail stands on ESTIMATES after the ⌘↓ landing, and
   the ⏎'s implicit pass corrects them with nothing holding the first visible line) is a
   HYPOTHESIS, not a trace.
3. **ATTRIBUTE** (the four-value column, U0's evidence bars): macOS-27 / our-commit(hash) /
   pre-existing / undetermined(why) — B5 was seen on BOTH sides of U0b's fix and predates it;
   the 26.x question may be unanswerable (say so honestly if so).
4. **FIX, inside this fence:** untouched text above the caret must not move when the act does
   not move it (the differential road's own 2026-07-07 promise, and U0b's walk criterion). The
   candidate shapes the U3 report names — an anchor-preserving correction around the edit (the
   `ReadingAnchor`/`topVisibleOffset` family, U0b's worked example) or laying out the region
   above the caret before the edit lands (P1: bounded how? — say). **Where the CARET's own line
   rests after a tail-⏎ is SHIPPED BEHAVIOR — do not redesign it; a fix that wants to change a
   ruled resting rule is a STOP** (U0b's product fence, verbatim). Red-on-old: the harness
   scenario flips XFAIL → PASS in Study **and reds on your fix's revert**; plus an in-suite
   deterministic pin if your trace admits one (state honestly if only the harness can hold it).
5. **May-take, ITS LAST CHANCE: row 85** (the ⌘↓ ring drawn too high — the overlay refreshing
   before the landing settles is the suspect, and your instrument is pointed at exactly that
   window). Take it with its own red-on-old pin if your trace reaches the ring's refresh; else
   one line, and the row stays 12's.
6. **WALK (USE, both voices, per-step guarded):** her exact B5 gestures (the carve road and the
   re-font road, mid-note and at the tail, settled and invalidated geometry); the full seeded
   harness both voices (the baseline shifts: B5's Study XFAIL becomes PASS on your fix — update
   the scenario's expectation to PLAIN with the reason at the line, the U-VIS MINOR-2 form).
   KnownIssues row 88's close is drafted for the orchestrator, never applied.

**Discipline (the resiliency protocol, restated — it binds you):** commit per coherent piece,
push after EVERY commit, NO trailers; append a `## U-B5 RECORD` section to THIS file with LIVE
STATUS from your FIRST commit (unverified claims PENDING); records before final verification;
synchronous foreground waits only; NEVER spawn subagents; commit before any behavioral revert;
pathspec-limited staging; tests at the END (the jump/anchor/typewriter family, `WriteTopAirTests`
+ kin, the eleven Tutorial suites). PROVISIONAL-and-continue for non-gating ambiguity; STOP and
report for gating ambiguity, any ruled-resting-rule change, anything wanting `Sync/`, and every
author-only call. Your diff is the Write editor seam by definition → a **FABLE cold review**
follows; your self-assessment closes your record.

## U-B5 RECORD (implementer: `opus-implementer`, 2026-09-27)

**NOT DONE (first line — against what shipped):** (1) **the PROVOCATION is not closed** — TextKit still re-estimates and re-bases a floating island when a layout-forcing read lays out the new paragraph after the edit; the fix is the anchor-preserving KEEPER (the brief's first named shape) that puts the untouched reading line back in the same turn. Candidate 1 (R1-1's deferral extended to TextKit's selection-fix road) was built, measured INSUFFICIENT for B5 (run A: +182.0 at the next door) and withdrawn; the hazard it guards (a forcing read inside the edit's processing — R1-1's class) STANDS, drafted for owner 12 (NOTICED 1); (2) the other restore-less storage road (`applyDifferential`, projection deliveries) was NOT examined for the same re-base (NOTICED 2, owner 12); (3) **TextKit's half of the attribution is UNDETERMINED** (no 26.x OS or tree on this machine); (4) **row 85 (O-2) NOT TAKEN** — five ⌘↓ landings traced on invalidated geometry, the ring correct every time, no reproduction to pin; stays 12; (5) the walk is VisualWalk's guarded driver on her B5 gestures (both voices) — no free-hand GUI walk beyond it, and no frame-video check that no displaced frame is presented (reasoned: the re-base and the keeper's jump run in one main-thread turn with no display pass between; the probe and the captures read the settled page); (6) U4's keyboard stall struck the first teeth attempt — recorded as a sighting, not traced (not this unit's road); (7) no KnownIssues / TEXTKIT2_NOTES / AppSpec / QUESTIONS edits — every canon line is drafted under OWED AT CLOSE; (8) zero `Sources/`, `Shared/`, `Sync/`, schema, `EditorTextView`, `BlockRangeIndex`, `PaneSurface`, `PaneTextAuthority` — core / iOS / mobile runs not owed; the Release configuration compiles.

### LIVE STATUS

| # | Piece | Status |
|---|---|---|
| 1 | Reading (the brief's "Read first" list, in order, own context) | DONE — this file whole (HER KICKOFF MESSAGE, BINDING PRINCIPLES, CAST & DISCIPLINE, BASELINES, THE UNIT ROSTER, HER OPEN ITEMS, ENVIRONMENT TRAPS, THE LEDGER, the U2 BRIEF + RECORD + bloom-race fix pass + both acceptances, the U3 BRIEF + RECORD (THE B5 REPORT) + acceptance, the U4 BRIEF + RECORD + acceptance, the U-B5 BRIEF); KnownIssues rows 42 · 85 · 88 whole; the 18l record's U0b BRIEF + RECORD whole + acceptance, U0's ITEM 2 (the settle net), U-VIS's probe endpoint + TABLE + B5's HONEST VERDICT; the 18k C6 RECORD whole + adjudication and the C6b RECORD whole + adjudication; `TEXTKIT2_NOTES.md` IN FULL; `SessionResiliencyProtocol.md` whole; the code: `EditorTextView.swift` whole (the ⏎ door, `setFrameSize`/`applyFrameHeight`/the room, β1, `makeEditor`, `TypewriterScrollView`), `JumpPrimitive.swift` whole (`ReadingAnchor`, C6's re-assert, C6b's live range), `StructuralSeamEdit.swift` whole, `EditorSurfaceController` (`applyDifferential`, `renderFull`, `insertEmptyBlock`, the typed Return's act, `runStructural`, `applyStructuralResult`, `applyDifferentialStructural`, the oracle), `EditorViewModel` (`attach`'s wiring, `setSurfaceContent`, `applySeamEdit`, `adoptRewrite`, `storageDidEdit`, `typedReturnAct`/`runTypedReturn`, the arrival landing + `revealLanding`, `parkAnchorRestore`, `keepingReadingPosition`, the consumers, `jumpToDocumentEnd`, `updateCaretContext`, `overlayLayoutDidSettle`, `refreshBadges`, `refreshDecorations`, `topVisibleOffset` + helpers, `readingAnchor`, `restoreReadingAnchor`), `EditorView.swift`'s coordinator + `ScrollAnchorController`, `LongBlockLayout.swift` whole, `VisualWalkProbe.swift` (the facts the recipe reads); `Tools/VisualWalk/` (README, `visual-walk.sh`, `build.sh`, the B5 pair + the seeded order) |
| 2 | INSTRUMENT the deterministic recipe (frame · clip · the first visible line's document y · its fragment's estimated-vs-laid-out state, across the tail ⏎'s edit and display pass) | DONE — a TEMPORARY DEBUG + env-gated instrument (`B5Trace`, working tree only, never committed; a copy in `App/Variorum/DerivedData/18lb-ub5/`): a content-free `os.Logger` line (category `B5`) at the ⌘↓ and ⏎ keyDowns (with a CENSUS of the fragments above the viewport — laid-out vs estimated), around `applySeamEdit`, the structural result, `layout()`, `prepareContent`, `viewWillDraw`, `setFrameSize`, the settle hop, the long-block pass and every clip-bounds change; each line carries frame · clip · usage height · the viewport's bounds and range · a REFERENCE line (the first visible line at the ⏎) with its container y, its screen y and its fragment's state · the first visible line · the last fragment. Run on the recipe — the Study pass through `b5-refont`, the stamped instrumented build (`notes/plans/vis-walks/2026-09-27/102834/`): **B5 REPRODUCED (XFAIL 2), at its LARGE size — the first visible line 45591 → 44477, ~1,100 characters of text** (U-VIS's round-1 final run's magnitude); `b5-refont` PASS. Trace: `DerivedData/18lb-ub5/trace1.txt` (B5) · `trace1-refont.txt` (the re-font road) |
| 3 | TRACE the mechanism | DONE — THE TRACE below |
| 4 | ATTRIBUTE (macOS-27 / our-commit / pre-existing / undetermined) | DONE — ATTRIBUTION below (our-commit `79b334ab` for the road that shows it, by run D1; TextKit's half undetermined — no 26.x) |
| 5 | FIX inside the fence (red-on-old: the harness's Study XFAIL → PASS on the fix and red on its revert; an in-suite pin if the trace admits one) | DONE (pin `8b9be390` red-first · fix `161b66aa` · harness `1b893262`) — **candidate 1 WITHDRAWN on measurement:** R1-1's deferral extended to the road it cannot see (the indicator arm deferring while one of the model's storage writes is processed) — run A (`112731/`, instrumented): the in-write walk no longer ran (`last` stayed `E` through `seam>`) and B5 STILL moved, +182.0 pt, now at the NEXT pre-viewport-pass forcing read (between `seam>` and the result's caret placement: the post-edit `refreshBadges` → `refreshDecorations`). So the trigger is not "inside processing": it is ANY layout-forcing query that lays out the new paragraph before the viewport pass that consumes the edit — a road with several doors. **Candidate 2 — the keeper (the brief's first named shape), in the working tree:** `applyStructuralResult` captures `readingAnchor()` before a differential rewrite; after the result's synchronous work (caret placed, context refreshed) `keepUntouchedReadingLine` restores the line EXACTLY (`exactLandingInset`, renderFull's vocabulary) iff it is untouched (starts before the edit) and moved ≥ 0.5 pt; pure half on `ReadingAnchor` (`isUntouched`, `displacement`); a DEBUG witness `untouchedLineRestores`. **Run A2 (`114046/`, instrumented): B5 XPASS — the first visible line held EXACTLY (45591 @ 298.1 → 298.1), and the trace shows the keeper WORKING, not B5 absent:** TextKit's re-base happened INSIDE `refreshDecorations` (`ucc.decor<` → `ucc.decor>`: MOVED +438.8, inside the seam write — the direct observation of the mechanism), then the keeper's jump (`to=45510 inset=-11.9`, two iterations) moved the clip +438.8 (18447.4 → 18886.2) and the line back to screen 18.1 = before, stable through the next layout, display and settle hop. **The in-suite pin (red-first, this commit):** `WriteFloatingViewportTests.aTailReturnOnAFloatingViewportLeavesTheLinesAboveItStill` — the rig reproduces B5 once TextKit has layout history (the story laid out once first; found by the scratch rig's history variants, `DerivedData/18lb-ub5-rig5.log`: history 1 and 3 re-based and the keeper restored, history 0 and 2 did not re-base); the dev store's ring ON; her column's size; the real roads (the typed Return, the carve through `renderFull`, `moveToEndOfDocument:`, the real coordinator). **RED on the pre-fix tree, deterministic (2/2): Study 80.0 pt** (`37.06 → 117.06` pt below the edge; usage 18199.8 → 18309.8 for one new line), both premises held (the island floats — laid-out run above the viewport 0; TextKit re-estimated — usage grew > 3 lines); Terminal GREEN (a guard: B5 never reproduced there) (`DerivedData/18lb-ub5-pin-prefix{1,2}.log`). **THE FIX (this commit):** `ReadingAnchor.isUntouched(byEditAt:)` + `displacement(lineTop:viewportTop:)` (pure, `JumpPrimitive.swift`); `EditorViewModel.keepUntouchedReadingLine(_:editStartingAt:)` + the DEBUG witness `untouchedLineRestores`; `EditorSurfaceController.applyStructuralResult` captures `readingAnchor()` before a seamed rewrite and, when the DIFFERENTIAL strategy landed, keeps the line after the caret is placed (before any pending projection applies); `applyDifferentialStructural` returns where the edit began (`Int?` in place of `Bool`). **GREEN:** `WriteFloatingViewportTests` + the new `UntouchedLineKeeperTests` (the pure rule · the witness on the B5 road = 1 and on a non-floating page = 0 · the fence: an act that writes ABOVE the reading line keeps its own movement — measured 10.0 pt, one empty block's line — and the keeper stays out) — **4 tests / 2 suites, 6 cases, passed** (`DerivedData/18lb-ub5-pin-fixed2.log`). **R-keep RUN (`DerivedData/18lb-ub5-R-keep.log`): RED — exactly the predicted 3 issues** (the pin's Study case 80.0 pt; `theKeeperRunsExactlyWhereTextKitMovedTheLine(true)`: moved 80.0, restores 0 where 1 is owed); every other case green; restored by `git checkout HEAD --`, `git status` clean, the call greps back (1). The harness half: DONE (row 7 — the Study row PASS plain on the fix, FAIL on the R-keep scratch build) |
| 6 | Row 85 (O-2) — the last-chance may-take decision | DONE — **NOT TAKEN, stays 12** (ROW 85 below: five ⌘↓ landings on invalidated geometry traced, the ring correct in every one; no reproduction to pin) |
| 7 | WALK (USE, both voices, per-step guarded) + the full seeded harness both voices | DONE — **the full seeded suite on the fixed tree** (the stamped clean build of `1b893262`, app `4f9d4b733b6e`, core `4b9d3b2f7991`, `dirty=` empty; the machine author-free, HID idle 26 min at the start): `notes/plans/vis-walks/2026-09-27/121540/` — **both voices 15/15 scenarios, 0 FAIL · 0 ERROR · 0 XPASS, XFAIL 4 = S3 ×4 only** (`index-click` + `readedit-click`, labelled); **`b5-return-after-cmd-down` PASS in Study, PLAIN** (the baseline's B5 XFAIL retired: XFAIL 5 → 4); the new `b5-more-roads` PASS 6/6 both voices; the dev store's voice restored to Terminal (run.log). The harness's TEETH (R-keep as a scratch build, `VW_DD`): first attempt `125012/` DERAILED by U4's KEYBOARD STALL at `mode-roundtrip` (a click on a mid-page Write line, then ⌘3 never took — the recorded intermittent row, owner 12; not this unit's road) → every later precondition ERRORed, the Settings voice control was not found (ABORT, exit 4), the app terminated by pid, **the dev store's voice left at STUDY (RESTORE OWED — in hand)**; **re-run `125735/`: `b5-return-after-cmd-down` FAILS in Study on the revert — the plain assertion reds: 45591 → 44477 (the ~1,100-character slide), exit 1 — the teeth, proven;** everything else as the fixed tree (S3 ×2 XFAIL; `b5-refont` PASS); **`b5-more-roads` PASS on the revert too — its two rows are GUARDS** (the mid-note ⏎ after the carve and the tail ⏎ on settled geometry did not move on either build; kept as standing cover, labelled as guards). **The dev store's voice RESTORED to Terminal** (a one-act throwaway scenario, removed after; the app's probe read `voice now: terminal`, 13:08:04). **THE WALK (USE) — her B5 gestures, both voices, per-step guarded (VisualWalk's doors), on the fixed build (`121540/`):** the carve road at the tail on invalidated geometry (`b5-return-after-cmd-down`: Terminal 4/4, Study 4/4 — the page byte-for-byte the pre-⏎ page in capture `study/b5-return-after-cmd-down/02-return` vs `01-cmd-down`: "You have but to name it." at the same place, footer `block 263/263`) · the re-font road at the tail (`b5-refont`: 4/4 both) · the carve road mid-note on invalidated geometry and the tail on settled geometry (`b5-more-roads`: 6/6 both) · a mid-note divide on settled geometry (`write-divide-merge`: 11/11 both) · the short note's ⏎/⌫ at the page top (`write-newline-roundtrip`: 9/9 both). The before-fix picture, same recipe: captures `102834/study/b5-return-after-cmd-down/01` vs `02` (the page slid ~a screenful, the new caret block off-screen). (An empty block's editing ring is not visible after the ⏎ on either build — shipped: the pre-U-B5 capture `082126/study/write-newline-roundtrip/02-return` shows the same.) |
| 8 | Closing runs (the jump/anchor/typewriter family, `WriteTopAirTests` + kin, the eleven Tutorial suites) | DONE — `App/Variorum/DerivedData/18lb-ub5-closing.sh` (154 suite type names, each grep-verified: U0b's 87 — the jump/anchor/landing/re-font/typewriter family, the structural and seam suites, the typed Return's, `WriteTopAirTests`, the eleven Tutorial suites — ∪ U0c's 59 landing/pane extras incl. `NoteOpenLandingTests` ∪ this unit's two ∪ `IndicatorGutterTests`, the four `SeamEdit…` suites, `GestureSoakTests`), zero instances, the dev store's voice Terminal, the machine idle (HID 997 s at the end): **`✔ Test run with 1019 tests in 154 suites passed after 358.857 seconds`**, `** TEST SUCCEEDED **`, `EXIT 0`, zero `✘`, no skipped tests (`DerivedData/18lb-ub5-closing1.log`; 156 `Suite … started` lines against 154 asked — the parameterized/unnamed prints); every riding pin UNMODIFIED and green (`WriteTopAirTests`, `RefontViewportTests`, `JumpViewportLayoutTests`, `ScrollAnchorTests`, `NoteOpenLandingTests` — `git diff b811760a..HEAD -- App/Variorum/VariorumTests/` touches only the new `WriteFloatingViewportTests.swift`); 1,112 `Modifying state during view update` lines — the standing `PanePublisher` family (row 95 / #152), not attributed here (this diff writes no state). **The Release configuration COMPILES** (`xcodebuild -configuration Release build` into a scratch folder, removed after; `18lb-ub5-release-compile.log`: `** BUILD SUCCEEDED **` — the witness is `#if DEBUG` on both sides); nothing installed. Core `swift test` / iOS build: not owed (zero `Sources/`, zero `Shared/`) |
| 9 | Self-assessment | DONE (below) |

### THE TRACE (inputs → the page moved; every number from the instrumented run `102834`)

**The act, located to one call.** The tail ⏎ (caret at the note's end, the segmentation chip ON) is claimed by the
typed Return (`TypedReturn.act` → `.emptyBlock(.below, …)`) and lands through `insertEmptyBlock` →
`runStructural` → `applyStructuralResult` → **the DIFFERENTIAL road** (`seam: .divide`, an empty successor —
`StructuralSeamEdit` derives ONE storage edit: `"\n"` appended at the document end), whose storage write is
`EditorViewModel.applySeamEdit` (`beginEditing` · `replaceCharacters` · `setAttributes` · the markdown restyle ·
`endEditing`). The reference line is the first visible line at the ⏎ (offset 45591):

| # | Where | clip | usage | frame | ref line (container y · state · SCREEN y) | first visible line |
|---|---|---|---|---|---|---|
| 17 | ⏎ keyDown | 18462.9 | 18940.8 | 19749.5 | 18456.8 · laid · **17.9** | 45591 |
| 19 | `applySeamEdit` entry | 18462.9 | 18940.8 | 19749.5 | 18456.8 · laid · **17.9** | 45591 |
| **20** | **`applySeamEdit` exit** | **18462.9** | **19633.2** | 19749.5 | **19119.2 · laid · 680.3 — MOVED +662.4** | **44477** |
| 22–25 | the next `layout()` (the frame follows usage) | 18462.9 | 19633.2 | 20442.0 | 19119.2 · 680.3 | 44477 |
| 26–33 | display pass · settle hop · display | 18462.9 | 19633.2 | 20442.0 | 19119.2 · 680.3 | 44477 |

**Mechanism: TextKit re-estimates the geometry ABOVE the viewport while it processes the edit, and re-bases the
laid-out viewport onto the new estimate — in document space, under a clip nothing moves.** Between the entry and
the exit of `applySeamEdit` nothing lays anything out (the storage is inside `beginEditing`), so the move is
TextKit's own processing of the edit at `endEditing` *[refined by the later runs — THE ROAD INSIDE THE EDIT below: the
layout-forcing read that provokes the re-estimate inside that processing is OURS (the editing ring's decoration walk,
reached through TextKit's own selection fix), and with it deferred the same re-base happens at the next forcing read
after the edit (run A) — TextKit re-estimates; our reads make it do so before a viewport pass]*: the one-line edit grew TK2's usage height by **+692.4 pt**
(one line is ~24–30) and moved the laid-out fragment of a line FAR above the edit by **+662.4 pt** — its state
still `layoutAvailable`, only its origin re-derived. The clip stayed at 18462.9 through every later pass, so the
screen shows text ~a page EARLIER (captures `02-return` vs `01-cmd-down`: "You have but to name it." from
near the top to near the bottom; the new caret block off-screen below, footer `block 263/263`). The next
`layout()` then viewport-lays out what now sits under the unmoved clip (the viewport range 45510…46376 →
44018…45640) and the frame follows usage; nothing ever re-reads the reading line.

**Why only after a full re-render (the recipe's precondition), measured by the census.** At the ⏎, the fragments
above the viewport: **n=510 · laid 39 · estimated 471 · laid-out run directly above the viewport = 0** (the
fragment right above the viewport's first is estimated, `45509@18404.8`). The carve's `renderFull` had replaced
the whole storage (every fragment back to an estimate), its exact restore laid out an island mid-note, and ⌘↓
(`moveToEndOfDocument:` + AppKit's reveal) laid out ONLY the last page — positioned on the estimate of the ~470
paragraphs between. The viewport's island FLOATS on estimates. **The re-font road, the contrast:** at its ⏎ the
census reads **laid 164 · estimated 346 · laid-out run above the viewport = 164** (the first estimate far above,
`31120@11968`): the edit grew usage by exactly one line (+24.0) and the reference line did not move — `b5-refont`
PASS. On settled geometry there is nothing above the viewport left to re-estimate.

**The asymmetry the U3 report named, now measured on both sides.** The ⌘↓'s own landing moved the fragments
+8 pt as its viewport layout settled — and the CLIP followed (+8: `18454.9 → 18462.9`, screen y unchanged): that
is TextKit's compensation inside a viewport-layout pass (18k C6's +29 / −23.23 finding, from its benign side).
The edit's re-estimation runs in edit PROCESSING, outside any viewport pass, so no compensation exists — and the
differential road has, by its own 2026-07-07 design, **no restore step at all** ("untouched text never moves" was
true only while TextKit kept laid-out geometry where it was). The U3 report's hypothesis holds with a correction:
it is not the ⏎'s PASS that corrects estimates; the ⏎'s EDIT re-bases the island.

**THE ROAD INSIDE THE EDIT — found by the second and third instrumented runs (`105239/` +438.8 pt, `111052/`
+438.8 pt, both XFAIL on the same recipe) and the in-process rig:** the move happens inside
`super.setSelectedRanges`, which TextKit ITSELF calls during the edit's processing — the captured stack:
`-[NSTextLayoutManager _fixSelectionAfterChangeInCharacterRange:changeInLength:]` → `EditorTextView.setSelectedRanges`
(the caret at the end rides the appended `"\n"`: 46376 → 46377). The insertion-point refresh inside it moves nothing
(`ipt<`/`ipt>` identical); what follows it is `NSTextViewDidChangeSelection` → `EditorSurfaceDelegate
.textViewDidChangeSelection` → `EditorViewModel.updateCaretContext()`, and with the EDITING INDICATOR ON (the dev
store's ring — capture `01-cmd-down`) the caret has changed blocks (past the pre-edit index's end), so the arm runs
`refreshDecorations()` SYNCHRONOUSLY — whose opening queries are layout-FORCING (`textLayoutFragment(for:)` at the
viewport's top and bottom edges; the bottom edge sits in the typewriter room below all text). That is exactly 13u3
R1-1's hazard (a layout-forcing geometry query inside `processEditing` — TEXTKIT2 §2's estimation class, sampled
once as the `_estimatedTextLocationForVerticalOffset` spin), on the one road R1-1's guard cannot see: R1-1 defers
the arm while `storageDidEdit` is on the stack (`inStorageEditTransaction`, depth > 0), but TextKit's selection fix
runs AFTER that delegate returned, still inside the write — the depth reads 0 there. **The rig proves the road
deterministically** (`B5ScratchRigTests`, `DerivedData/18lb-ub5-rig4.log`, indicator ON): `ucc.decor<` sits between
`seam<` and `seam>`, inside `ssr`, and it is the call that lays out the new last paragraph (`last` `0.0 E` → `L`,
usage re-estimated in the same call) — but on the rig's history TextKit does not re-base the island (0.0 pt, both
voices, key window or not). So: **the road is ours and deterministic; whether the forced estimate re-bases the island,
and by how much, is TextKit's and history-dependent** (it never did in Terminal — the monospace estimate is close to
exact — and did in every full Study pass). A typed character at the tail after the same recipe (the throwaway
`zz-b5-type`, run 3) moved NOTHING: the caret stays in its block, so the arm never fires.

**The magnitude is TextKit's re-estimate, so it is history-dependent** (U-VIS ~30 pt · U0b +109/+166 · this run
662.4): how many paragraphs are laid out where decides how far the estimate moves on re-estimation. That is
exactly row 88's "the magnitude follows that history".

- Deaths / resumes: none.
**THE BEHAVIOURAL REVERT R-keep (named before it runs; the pre-revert state is the fix commit, pushed):** in the
working tree only, `applyStructuralResult`'s one call `model.keepUntouchedReadingLine(reading, editStartingAt:
differentialEditStart)` removed (the capture and everything else kept). **Expected RED:**
`WriteFloatingViewportTests` Study (the line moves ~80 pt, as on the pre-fix tree) and
`UntouchedLineKeeperTests.theKeeperRunsExactlyWhereTextKitMovedTheLine(true)` (the line moves; witness 0 where 1 is
owed). **Expected GREEN:** the Terminal guard, the pure rule, the non-floating control (`false`), and the fence test
(its witness is 0 either way; its movement is the act's). Restored by `git checkout HEAD --` of the one file;
`git status` clean after.

**THE ATTRIBUTION DISCRIMINATORS (named before they run; each on the committed fix tree + R-keep in the working tree,
the pin run, then `git checkout HEAD --` every touched file):**
- **D1 — the insert back on its pre-18c road:** R-keep + `insertEmptyBlock`'s `.below` arm returns `seam: nil` (the
  full re-render with its anchor restore, as before `79b334ab`). Expected: `WriteFloatingViewportTests` Study GREEN —
  the road that shows B5 is the differential one 18c batch 2 gave the tail ⏎.
- **D2 — the ring off:** R-keep + the pin's `h.model.appearance.indicator = .outline` line removed (a calm page: no
  ring, no comments, no callouts, no pointer). Prediction (not a certainty): GREEN — with nothing to decorate the
  post-edit decoration walk returns before its forcing reads, so nothing lays the new paragraph out before the
  viewport pass; a RED would mean another forcing read provokes it on a calm page too.

**D1 RUN (`DerivedData/18lb-ub5-D1.log`): GREEN — 1 test (2 cases) passed:** with the insert back on its pre-18c road
(the full re-render, whose exact anchor restore holds the page) and no keeper, the line holds — so the road that SHOWS
B5 is the differential one `79b334ab` gave the tail ⏎ (the attribution's our-commit row, by run). **D2 RUN
(`18lb-ub5-D2.log`): the ring takes part in BOTH halves of the recipe, measured — with the ring OFF the Study case
fails its PREMISES, not its line:** the island does NOT float (laid-out run above the viewport **40**, where the ring-on
recipe reads 0) and TextKit does NOT re-estimate (usage **+30.0** = the one new line, against the premise's > 66); the
line held. So on a calm page this recipe never reaches B5; her dev store's ring (on) is part of it — the decoration
walks both shape which fragments TextKit has laid out and provoke the re-estimate. The keeper does not depend on it
(it keys on the line having moved, whatever moved it). Both restored by `git checkout HEAD --`; `git status` clean.

- Reverts in flight: none. **Instrumented working tree: NO — removed before the pin (the instrument, the throwaway scenario and the scratch rig are kept in `App/Variorum/DerivedData/18lb-ub5/` — `keeper-plus-instrument-final.patch`, `B5Trace-v3.swift`, `B5ScratchRigTests-final.swift`; the clean keeper at `keeper-clean.patch`).** *(History of this line:)* Instrumented working tree: YES (uncommitted, by design) — `Features/Editor/B5Trace.swift` (untracked, new) + DEBUG-gated hooks in `EditorTextView`, `EditorViewModel`, `EditorSurfaceController`, `EditorView` (`ScrollAnchorController`), `LongBlockLayout`, `JumpPrimitive` (v2: armed from the first ⏎ too; `renderFull` + the jump bracketed) + a THROWAWAY scenario `zz-b5-type` appended to `Tools/VisualWalk/scenarios.zsh` + a scratch rig `VariorumTests/B5ScratchRigTests.swift` (untracked); copies at `App/Variorum/DerivedData/18lb-ub5/` (gitignored). Restore: `git checkout HEAD --` the tracked files + `rm` the two new ones; `git status` clean. **The scratch rig's first run (`DerivedData/18lb-ub5-rig1.log`): the recipe replayed in-process reproduces the PRECONDITION (the viewport's island on ~462 estimated fragments, laid-out run above it 0, both voices) but NOT the move (0.0 pt) — so the floating island is necessary, not sufficient; the trigger of TextKit's re-estimation needs more history (v2 run next).**

### ATTRIBUTION (U0's four-value column, with its evidence bars)

| Half of the mechanism | Value | Evidence |
|---|---|---|
| **The road that SHOWS it** — the tail ⏎ lands on the differential structural rewrite, which has no restore step | **our-commit(`79b334ab`)** — 18c batch 2 (2026-09-07): U-1 made the Return key structural AND gave `insertEmptyBlock` a stated seam (`.divide` with an empty successor — "the P1 half of 18c batch 2"). Before it the insert took `seam: nil` → `renderFull`, whose anchor restore holds the page, and ⏎ at the tail was a text newline | the diff of `79b334ab` (`seam: nil` → `.divide`); **D1 by run**: the pin with the insert back on `seam: nil` and no keeper holds the line (GREEN) |
| The road it rides — the differential rewrite without a restore step | pre-existing (Phase 9 `29816875`, 2026-07-07 — "NO scroll-restore step exists on this path", the author's directive) | git history |
| The precondition — the viewport's island floats on estimates | pre-existing (the carve lands through `renderFull` since 13c 1B `7df0795d`; `renderFull` replaces the whole storage since Phase 7; ⌘↓ is AppKit's `moveToEndOfDocument:`) | the census, every instrumented run; U0b's ATTRIBUTION rows |
| The provocation — a layout-forcing read that lays out the new paragraph before the viewport pass | pre-existing (the decoration pass's opening `textLayoutFragment(for:)` reads, Phase 13 C1; the indicator arm on the selection road, R14; the post-edit `refreshBadges` → `refreshDecorations` on the differential road) — **and her editing ring takes part in BOTH halves** | the stack (run 3), the `ucc.decor` bracket (A2), run A (the next door); **D2 by run**: the ring off → no floating island (40 laid-out fragments above), no re-estimate (+30.0 = the line) |
| **TextKit's half — re-estimating the floating stretch and re-basing the laid-out island in document space, OUTSIDE a viewport pass, under an unmoved clip** | **undetermined** — no 26.x OS or tree can run on this machine (TK2 §5); the estimate class is TextKit's own (§2, documented since 15.6), and on 27.0 its viewport pass COMPENSATES such shifts by moving the clip (18k C6's measured finding — the same machinery's other door; seen here as the ⌘↓ landing's +8 pt followed by the clip). Whether 26.x re-based on this road cannot be said | — |

**The magnitude history, read with the mechanism:** U0b +109/+166 (`998f7d7d`), U-VIS ~30 pt, this unit 662.4 · 438.8
· 438.8 · 182.0 (run A, at the second door) · 80.0 (the rig) — TextKit's re-estimate of a floating stretch, whose
size follows how much of the note is laid out where. Terminal never: the monospace estimate is close to exact.

### THE FIX, and why this shape (the brief's first named candidate)

`EditorSurfaceController.applyStructuralResult` captures `readingAnchor()` (the line the viewport's top is reading,
with its place — U0b's `ReadingAnchor`) before a seamed rewrite; when the DIFFERENTIAL strategy landed, after the
result's synchronous work (the caret placed, its context refreshed — the last layout-forcing reads of that turn) and
before any pending projection applies, `EditorViewModel.keepUntouchedReadingLine` restores it EXACTLY through
`JumpPrimitive.jump(…, landingInset: exactLandingInset)` — `renderFull`'s own restore — iff the line is UNTOUCHED (it
starts strictly before the edit, `ReadingAnchor.isUntouched`) and it MOVED on screen by ≥ 0.5 pt
(`ReadingAnchor.displacement`). Nothing else moves: the caret rests where the act put it (the fence — the page
returns to the one the act leaves on settled geometry, where the new line sits below the last one); a line the act
writes or pushes is never held (its own movement is shipped — pinned: 10.0 pt, the keeper out); the full strategy
keeps `renderFull`'s restore; on settled geometry the check is one single-fragment read and no jump runs.

**Why not the root (the provocation):** candidate 1 closed the in-processing door and B5 moved at the next one (run
A, +182.0). The doors are several (the indicator arm inside TextKit's selection fix; the post-edit badge/decoration
refresh; the caret-context refresh after the caret is placed; any future geometry read in that window); closing all of
them means deferring EVERY decoration refresh after EVERY edit to the settle hop — a change to when every decoration
on this surface appears (one display pass later), not a B5 fix, and still not a guarantee against the next read.
**Why not "lay out the region above the caret before the edit lands" (the brief's second candidate):** the floating
stretch is ~470 paragraphs (tens of thousands of characters) between the mid-note island and the end — its layout
scales with the document (P1 forbids it), and bounding it to a page above would leave the estimates further up that
TextKit re-bases on.

### COST SHAPE (P1 / P3), stated

- Per differential structural act (divide, extract, makeBlock, merge, the typed Return's insert — every ⏎ in Write):
  one `readingAnchor()` before (the `topVisibleOffset` probe + one single-fragment `lineSpan` of a line already on
  screen — the read `ScrollAnchorController` already makes on every scroll event) and one `lineSpan` after.
  Viewport-bounded; nothing at autosave or keystroke rate beyond acts that already run a structural flight.
- Only when TextKit moved the line: one `JumpPrimitive.jump` (≤ 6 viewport layouts; measured 2 in A2) — the bounded
  primitive every landing on this surface uses.
- P3 unchanged.

### SEAM FILES THIS DIFF TOUCHES (`git diff b811760a..HEAD -- App Tools`; the Fable reviewer reads this first)

| File | What changed | What did NOT |
|---|---|---|
| `Features/Editor/JumpPrimitive.swift` | `ReadingAnchor.isUntouched(byEditAt:)`, `displacement(lineTop:viewportTop:)` — pure, two lines of arithmetic | `JumpCorrectionLoop`, `FragmentLines`, `lineSpan`, `jump` (C6's re-assert, C6b's live range), `exactLandingInset`, `reflowLandingInset` |
| `Features/Editor/EditorViewModel.swift` | `keepUntouchedReadingLine(_:editStartingAt:)` + the DEBUG witness `untouchedLineRestores` (beside `restoreReadingAnchor`) | `topVisibleOffset()`, `readingAnchor()`, `restoreReadingAnchor`, `applySeamEdit`, `updateCaretContext` (the R1-1 arm byte-unchanged — candidate 1 withdrawn), `refreshDecorations`, the parks, the storage seam |
| `Features/Editor/EditorSurfaceController.swift` | `applyStructuralResult`: the capture before a seamed rewrite + the keep after the caret placement (differential strategy only); `applyDifferentialStructural` returns the edit's start (`Int?` for `Bool` — its one caller) | `renderFull` (its exact restore), `runStructural`, `insertEmptyBlock` and every seam, `StructuralSeamEdit`, the oracle, `applyDifferential` |
| `VariorumTests/WriteFloatingViewportTests.swift` | NEW — the red-first pin (2 cases) + `UntouchedLineKeeperTests` (the pure rule · the witness 1/0 · the act-moves-it fence) | — |
| `Tools/VisualWalk/scenarios.zsh`, `README.md` | B5's Study expectation PLAIN (reason at the line; `KI_B5` names the fix); NEW seeded `b5-more-roads` (appended last; its rows are guards — green on the revert too) | every other scenario, `lib.zsh`, the guard order |

`EditorTextView`, `BlockRangeIndex`, `PaneSurface`, `PaneTextAuthority`, `runStructural`, `JumpCorrectionLoop`:
untouched. Zero `Sources/`, `Shared/`, `Sync/`, schema. No TK1 API (the new reads are `JumpPrimitive.lineSpan`'s
existing single-fragment idiom).

### JUDGMENT CALLS (each reversible, the reversal named)

1. **The fix is the anchor-preserving keeper, not the provocation's doors** (THE FIX above; candidate 1 measured
   insufficient). *Reverse by* removing the keep call (R-keep's shape) — B5 returns (pin + harness red).
2. **"Untouched" = the reading line STARTS strictly before the edit.** An edit that begins inside the first visible
   line (a divide in it) leaves that line's top to the text before it, so it is held; an edit at or above its start
   moves it and is the act's. *Reverse by* `offset + lineLength <= editLocation` (hold only lines wholly before the
   edit) — narrower, and a divide in the first visible line would then be unkept on a floating page.
3. **Exact landing (`exactLandingInset`), not the re-layout keepers' "line at the top".** A structural act on the
   differential road promises the page does not move; `renderFull` already lands exactly (U0b JC 1). *Reverse by*
   `reflowLandingInset`.
4. **The keep runs AFTER the caret placement and its context refresh, BEFORE `applyPendingIfClean`** — after the last
   forcing reads of the turn (so a re-base provoked by the caret-context refresh is caught), before a deferred
   projection could re-map offsets. *Reverse by* moving it into `applyDifferentialStructural` right after the edit
   (then run A's second door would escape it).
5. **The pin gives TextKit layout history (the whole story laid out once) and turns the ring on** — the two things the
   rig needed to reproduce what the app's full pass does every time (found by the history variants; D2 shows the ring
   is part of it). *Reverse by* dropping either — the pin then fails its own PREMISES (not its line), by design, so it
   cannot pass vacuously.
6. **`b5-more-roads` joins the seeded suite although its rows are guards** (green on the revert): the brief's walk
   rows made standing, labelled honestly. *Reverse by* removing its `SCN_ORDER` entry.
7. **No QUESTIONS row:** no product rule was decided — the keeper enforces the 2026-07-07 promise and the U0b walk
   criterion, the caret's resting is untouched, and the act's own movement is preserved and pinned.

### ROW 85 (O-2, the ⌘↓ ring drawn too high) — the last-chance decision: NOT TAKEN, stays 12

My instrument watched the ⌘↓ landing's window on invalidated geometry five times (runs 1–3, A, A2): each landing's
settle moved the laid-out fragments (+8 pt in run 1) and TextKit moved the CLIP with them in the same pass, and the
clip's bounds notification (`ScrollAnchorController.boundsChanged` → `refreshBadges` → `refreshDecorations`) re-ran
the decoration pass AFTER the shift; every `01-cmd-down` capture shows the ring exactly around the last block. O-2 did
not reproduce, the trace does not reach a stale ring refresh, and a take needs its own red-on-old pin on a
reproduction this unit does not have. (What the trace does add to row 85's suspect: a settle that shifts the text
WITHOUT a clip move — B5's own shape — would leave no bounds notification to re-run the pass; after the fix the
keeper's jump provides one on this road.)

### NOTICED, NOT TOUCHED

1. **The R1-1 hazard's other road:** the editing ring's layout-forcing decoration walk runs INSIDE the storage's edit
   processing through TextKit's own selection fix (`-[NSTextLayoutManager _fixSelectionAfterChangeInCharacterRange:…]`
   → `setSelectedRanges` → `textViewDidChangeSelection` → `updateCaretContext`) during every one of the model's
   programmatic writes (`setSurfaceContent`, `applySeamEdit`, `programmaticReplace`) that moves the caret's block —
   AFTER `storageDidEdit` returned, so R1-1's depth guard reads 0 there. The sampled R1-1 spin's precondition class
   (`_estimatedTextLocationForVerticalOffset`), on a road it cannot see. The one-line guard was built and measured
   (candidate 1: `inStorageEditTransaction || suppressEditProcessing`) — free (the in-write walk is always redundant
   with the post-write one) but NOT a B5 fix, so it did not ship. Proposed owner: 12 (R1-1's family); the
   candidate is recorded in LIVE STATUS row 5 and in `DerivedData/18lb-ub5/` — its pin would be R1-1's own oracle
   (`decorLayoutQueriesInEditTransaction`) widened to the same predicate, driven through the typed Return with the
   ring on (the rig's `ucc.decor` bracket showed the walk inside the seam write, deterministically).
2. **The same TextKit re-base on the OTHER restore-less road:** `applyDifferential` (projection deliveries — a take
   switch, `restoreCommit`, a sync landing) writes storage with no restore step; on a floating viewport a delivery
   that is followed by a forcing read could slide the page the same way. Unexamined (not B5's road). The TYPING road
   was measured once: a character typed at the tail after the recipe moved nothing (`zz-b5-type`, run 3 — the caret
   stays in its block, the ring arm never fires). Proposed owner: 12.
3. **U4's KEYBOARD STALL, one more sighting** (`125012/`, Study, `mode-roundtrip`: a click on a mid-page Write line,
   then ⌘3 never took; the pass derailed and aborted; the app did not answer its menu quit and was terminated by pid)
   — on the R-keep scratch build (the pre-fix road). No `sample` was taken (the harness drove on). Its row (owner 12)
   may take the sighting.
4. **An empty block's editing ring is not visible** after ⏎ makes it (both builds; the pre-U-B5 capture
   `082126/study/write-newline-roundtrip/02-return` shows the same) — shipped, noted only.
5. **The harness's full seeded run is now ~33 min** for both voices (15 scenarios each).

### OWED AT CLOSE (drafted for the orchestrator — nothing below was applied)

- **THE LEDGER:** row 6 → **CLOSED — TRACED + FIXED** (the keeper, `161b66aa`; pin `8b9be390` red-first; R-keep red
  exactly; the harness's Study row PLAIN, PASS on the fix and FAIL on the revert); row 8 → **NOT TAKEN at U-B5 either —
  stays 12** (ROW 85 above).
- **KnownIssues row 88 → CLOSED** (proposed text): *"RESOLVED 18l-b U-B5 (2026-09-27): traced — a full re-render
  leaves the end island floating on ~470 estimated paragraphs after ⌘↓; the tail ⏎'s differential rewrite is followed by
  a layout-forcing read (the editing ring's decoration walk, inside TextKit's own selection fix, or the post-edit
  refresh) that makes TextKit re-estimate that stretch and re-base the laid-out island in document space under an
  unmoved clip (+438.8/+662.4 pt measured). FIXED by the differential road's keeper (`keepUntouchedReadingLine` — the
  untouched reading line restored exactly iff TextKit moved it). Pins `WriteFloatingViewportTests` (red-first 80.0 pt)
  + `UntouchedLineKeeperTests`; the harness's `b5-return-after-cmd-down` is PLAIN in both voices (FAIL on the fix's
  revert). Attribution: our-commit `79b334ab` for the road that shows it (D1 by run); TextKit's re-base undetermined
  (no 26.x)."* Plus two NEW rows, owner 12: NOTICED 1 (the R1-1 hazard on the selection-fix road, candidate drafted)
  and NOTICED 2 (the projection road's restore-less rewrite); NOTICED 3 as a sighting line on the keyboard-stall row.
- **TEXTKIT2_NOTES §3 (canon — a measurement record, the orchestrator's pen):** *"On 27.0 a layout-forcing read that
  lays out a NEW paragraph right after an edit — outside any viewport pass — can make TextKit re-estimate the estimated
  stretch ABOVE a viewport island that floats on estimates (a full storage replacement, then one island laid out, then
  ⌘↓) and re-base the laid-out island in document space (+80…+662 pt measured) without moving the clip; the viewport
  pass compensates the same kind of shift by moving the clip (18k C6), an edit has no such pass. The rule: a road that
  writes storage with no restore step keeps the reading line itself (Write's differential structural rewrite:
  `keepUntouchedReadingLine`, 18l-b U-B5)."*
- **The harness baseline moves:** the full seeded run reads **XFAIL 4 = S3 ×4 only** (B5's Study XFAIL retired);
  `b5-more-roads` (guards) joins it.
- **AppSpec:** none (no contract line moves — the promise is the 2026-07-07 one). **MOBILE PARITY:** nothing
  mobile-visible (the phone's editor is its own; its structural road is not this controller). **QUESTIONS:** none.

### SELF-ASSESSMENT

**Strongest evidence.** The mechanism was traced by instrument, not inferred: a content-free trace around every
geometry event on the recipe located the move to ONE call (inside `applySeamEdit` → TextKit's own selection fix →
the ring's decoration walk: MOVED +438.8 between `ucc.decor<` and `ucc.decor>`), with a census showing the
precondition (a viewport island on ~470 estimated paragraphs, laid-out run above it 0) and its absence on the road
that never reproduced (the re-font road: 164 laid-out fragments above, +24 only). A first fix candidate was built and
MEASURED insufficient before the shipped one was chosen, so the fix addresses the observed class and not a guess
about one door. The red-first pin reproduces B5 in-process on the real roads (Study 80.0 pt, deterministic 2/2, both
premises asserted so it cannot pass on a quiet road), and the named behavioural revert R-keep reddened exactly its
three predicted issues. The harness half is proven both ways: the plain Study B5 row PASSES on the fixed tree and
FAILS on the R-keep scratch build (45591 → 44477); the full seeded suite reads 0 FAIL / 0 ERROR / 0 XPASS in both
voices with only the labelled S3 knowns. Attribution rests on two discriminating runs (D1: the pre-18c full-re-render
road holds the line; D2: the ring off never reaches the precondition), and the closing set is 1019 / 154 green with
every riding pin unmodified.

**Weakest points, for the reviewer.** (a) **The keeper COMPENSATES; it does not prevent** — TextKit still re-bases
the island (the document's estimated height jumps, so the scroller knob moves), and the page is put back in the same
main-thread turn. No presented frame should show the slid page (no display pass runs between the edit and the jump),
but that is reasoned from the call order, not measured by frame video. (b) The keeper holds the FIRST VISIBLE line; the
observed re-base is rigid (the whole laid-out island moves together), so the lines between it and the caret follow —
a non-rigid re-base would not be caught below the anchor. (c) The in-suite rig needs TextKit layout history AND the
ring to reproduce, and its magnitude (80 pt) is not the app's (438–662): it pins the class, the harness pins the felt
size. (d) Every differential structural act now pays one `readingAnchor()` before and one `lineSpan` after — the same
reads a scroll event pays, but on every ⏎ in Write. (e) `isUntouched` is "starts strictly before the edit" (JC 2): a
divide INSIDE the first visible line holds that line (its top is the text before the cut) — right on the evidence,
but the one place the rule reaches the act's own line. (f) Candidate 1's hazard (R1-1's class on the selection-fix
road) is left standing by design (not a B5 fix) — owner 12, drafted. (g) `b5-more-roads` is two guards, not teeth.
**U-B5 — DONE (implementer); the Fable cold review follows.**


### U-B5 — ORCHESTRATOR ACCEPTANCE, FIRST PASS (2026-09-27; verify-never-trust) — WALK HELD AT THE GUARD

**Claims verified against git and disk:** 14 commits pushed, tree clean, no trailers; the commit
chain honest (the withdrawn candidate 1 and the keyboard-stall derailment are IN the history, not
smoothed over); the diff footprint as recorded (the only test file in the range is the new
`WriteFloatingViewportTests.swift` — every riding pin byte-unmodified by construction); the
evidence logs on disk (`18lb-ub5-pin-prefix{1,2}`, `R-keep`, `D1`, `D2`, `closing1`,
`release-compile` + the `18lb-ub5/` instrument copies). The record read whole: the trace is
located to ONE call with a captured stack (TextKit's `_fixSelectionAfterChangeInCharacterRange:`
reaching the ring's layout-forcing decoration walk), the attribution is BY RUN (D1: the pre-18c
road holds the line; D2: the ring off never reaches the premises), and the fix respects the fence
(the caret's line never held; the act's own movement shipped; pinned 10.0 pt with the keeper out).

**The walk: HELD AT THE GUARD, then DISCHARGED the same afternoon** — the author returned to the
machine mid-attempt (HID idle 0 s; nothing activated, the guard's order held); at the next
author-free window (HID idle 25 min) the orchestrator's own pass ran clean: **the three B5
scenarios in Study, 14/14 assertions PASS** (`b5-return-after-cmd-down` 4/4 PLAIN — the retired
XFAIL; `b5-refont` 4/4; `b5-more-roads` 6/6 — the mid-note and settled-tail guards holding to
±0.5 pt). Her B5 gesture no longer moves the page in this seat's hands. The Fable cold review ran
in parallel (round 1: 0/0/1/2, the unit standing).

**Adjudications made now (repo-first, before the reviewer sees them):** row 85's last-chance
decision ACCEPTED (five ⌘↓ landings traced, the ring correct in every one — an honest
no-reproduction beats a hollow fix; the row stays 12's, its may-take chain exhausted this round);
the two NOTICED owner-12 drafts (R1-1's class on the selection-fix road; `applyDifferential`'s
missing restore step) and the row-88 close ride the closeout pen after the ladder.

## 18l-b CLOSEOUT (2026-09-27)

**Shipped:** **U2** — the aim kind as authority policy data (`Surface/LandingAim.swift`: top ·
minimal-reveal · viewport-fraction; U1's fraction arithmetic and the Takes reveal rule hoisted as
pure moves) and the Takes article's landings WATCHED by the one authority (`.takesArticle`; her
Console speaks on Takes; every landing ending FILES, pre-watch deaths included), the restore half
byte-preserved per R-Q20/R-Q21, plus the bloom-race stall found at this seat's acceptance walk,
traced PRE-EXISTING by run and fixed red-first (`restoreLooksAgainForAWaitingLanding`) ·
**U3 — CLOSED AS REVERTED under her gate, a valid close:** the ratified frame-synchronous /
state-deferred PanePublisher shape was BUILT and MEASURED (the WHOLE `Modifying state during view
update` family: 1,106 → 0 on set B, 2,393 → 0 on the 191-suite set) and REVERTED on frame
evidence (the Takes mount's collapsed article, 50–83 ms, 5/5 vs 0/5); the fork is hers at
QUESTIONS #152, the shape recoverable at `e113dd56` + `8a93eb24`; what ships is the rider —
the render restore's `layoutViewport()` PROVABLY SAFE on 27.0 with a tripwire — and the harness
fixture fix · **U4** — the three one-liners red-first (the Outline's `.onDisappear` parity; the
book-Index landing's caret END → START with `LandingTarget.utf16Offset` deleted, #153 PROVISIONAL
(a) with the ladder's (a′) hers to pick; `FlowStoryRow` onto the manifest, the one-brain collapse
made structural at the ladder) · **U-B5** — **B5 TRACED AND FIXED** (KnownIssues row 88 CLOSED):
the mechanism located by instrument to one call, attributed by run (the road our-commit
`79b334ab`; the substrate pre-existing; TextKit's half undetermined), the untouched-line keeper
inside the fence, the harness's B5 row PLAIN with teeth. **Ladders:** four, every finding
dispositioned in writing (U2 one round 0/0/3/4 · U3 one round 0/0/1/3 · U4 two rounds 0/0/2/1 +
0/0/0/3 · U-B5 one round 0/0/1/2); zero disputes anywhere; no ladder reached the cap.
**KnownIssues:** rows 88 CLOSED · 42 amended (U2) + the head-reveal row (95-era numbering) ·
95/96/97/98 filed en route (the warning family with her #152 fork · Compare's pre-existing mount
collapse · the note-Read signpost miss · the keyboard stall, three sightings) · two new owner-12
rows at this close (the R1-1 selection-fix road; the projection road's restore-less rewrite) ·
row 85 exhausted honestly with a sharpened suspect. **Canon:** ZERO AppSpec deltas (no author
ruling minted canon — every product-adjacent call is PROVISIONAL in her bundle); TEXTKIT2_NOTES
§3 gained two measurement records (the rider's provably-safe line; the U-B5 re-base rule); the
harness baseline is now **XFAIL 4 = S3 ×4 only** (B5's XFAIL retired), 16 seeded scenarios
(`takes-landing`, `book-landings`, `b5-more-roads` joined; `read-landing` reordered).
**Machinery:** the harness instance-check self-match trap and the walker facts recorded in the
acceptances. **Open for her — THE BUNDLE (the handoff's first section):** #149 · #150 · #151
(the 18l first-half trio, unchanged) · **#152** (the warning-family fork) · **#153** (the landing
caret: (a) as built · (a′) the ladder's option) · the U3 felt-gate confirm (her sentence; my walk
closed it provisionally) · the standing-rulings confirms carried from 18l. **MOBILE PARITY:
nothing mobile-visible** (U2's aim kind is Mac `Surface/` vocabulary; U3 reverted; U4's
`LandingTarget` is `Shared/` but no phone surface builds one; U-B5's keeper is the Mac editor's —
the phone's structural road is not this controller; each unit's record states it). **18m is NEXT
at her paste** (her 2026-09-27 resequence — the kickoff prompt is in the handoff verbatim; 18o
slides later with its ruled builds owned). Install refresh: recorded below at the refresh commit.

**INSTALL REFRESH (the closeout's last act, 2026-09-27 ~22:19–22:25 UTC):** zero-instance window
held throughout (pgrep clean before the A1 copy, before the install, verified by the
self-match-proof pattern); A1 safety copy
`Backups/safety-copies/18lb-refresh-20260927T221852Z` (6 files, byte-verified by `cmp`); Release
from `5a1564a5`; `/Applications/Variorum.app` binary **`c05400e8` → `07806a68`**; codesign OK
(deep, strict); both keychain access groups present. **18l-b — CLOSED. HARD STOP; 18m at her
paste** (the kickoff in the handoff and in chat).
