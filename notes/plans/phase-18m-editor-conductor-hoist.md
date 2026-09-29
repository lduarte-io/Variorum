# 18m — THE EDITOR-CONDUCTOR HOIST (the post-13u health rounds' KICKOFF 3, opened 2026-09-29 at her paste)

**STATUS: OPEN — U1 in flight.** Orchestrator: Fable (`/architect-phase 18m`, a fresh seat at her
paste). **The ratified charter is `notes/plans/post-13u-health-rounds.md` KICKOFF 3**
(author-ratified 2026-09-22) — its unit text is the BINDING SCOPE and is not duplicated here;
**the binding kickoff prompt is the last section of `notes/handoffs/phase-18l-b-handoff.md`**
(pre-authorized by her at the 18l-b close; her actual paste, verbatim: *"/architect-phase 18m,
the mobile session hoist phase."*). This file is the running record and must stay readable in
full (the reading rule).

**The phase in one sentence:** retire the ~700-line Mac↔mobile conductor duplication and turn
the drifted cross-block routing cascade into ONE pure, tested decision — the opening spine for
the mobile catch-up that follows, so the phone's owed seam work (KnownIssues row 51) lands as
DECLARED ARMS of a shared brain instead of a third copy.

**Standing fences (the kickoff's, restated because they bind every unit):** ZERO `Sync/` lines
(a fix that wants it is STOP-and-report); the 3C proof is the bar on BOTH platforms — every
existing routing/gesture pin rides UNMODIFIED, Mac and mobile, and the FULL mobile suite is part
of EVERY unit's finals, not just the Mac's; the phone's seam carves and its tutorial CONTENT
(rows 51 and 49) stay the mobile catch-up's — 18m makes the carves BUILDABLE and NEVER builds
them; ledger row 28's enumeration is updated as each fork is discharged, in the same commit as
the hoist (the touch rule, honored).

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
  **`opus-implementer` per unit**, one at a time, strictly sequential, briefed ONLY by this
  file's named sections + the charter's · **FABLE cold reviewer (`fable-reviewer`) on EVERY
  unit** — this is editor-seam surgery by definition (R-cor-14; her kickoff's own cast line).
  Cross-model flow as always: findings to the implementer verbatim, its agree/dispute back, the
  reviewer makes the final call and implements its confirmed fixes itself, then suite green and
  one implementer sanity pass. Zero `Sync/` by design.
- **Standing rules, restated because they bind every unit:** pin before fix — the red-on-old pin
  binds and is verified by BEHAVIORAL REVERT; a pin green on both sides dismisses the finding as
  hollow (recorded, not fixed). No fix without a self-traced concrete mechanism. Commit per
  piece, LIVE STATUS in this file from each unit's first commit, push after every commit, NO
  trailers. Synchronous foreground waits only (poll the log; never end a turn awaiting a
  background run). Tests at the END against the baselines below. PROVISIONAL-and-continue for
  non-gating ambiguity (log to `notes/QUESTIONS.md`; next free number **#159**);
  stop-and-report for gating ambiguity and every author-only call. One unit per implementer
  session. Each unit closes on the orchestrator's own hands-on walk PLUS the full mobile suite
  green; the install refresh follows the phase's close at a zero-instance window (A1 safety
  copy into `Backups/safety-copies/` first) — **her real-store instance was LIVE at this
  kickoff (pid 85601)**, so the refresh waits on a window she grants.
- **A hoist is an ADDRESS change, never a behavior change** (the 3C parity pattern, row 28's
  proof standard): pre-move names kept as forwards/typealiases where consumers need them; a
  zero-test-edit suite on BOTH platforms is the proof the hoist moved an address and not
  behavior. Where a unit's brief sanctions a specific pin edit it is named out loud, one by one.
- **In-batch design forks are the architect's** ("the implementer proposes, the architect
  rules"): the implementer returns with its proposal BEFORE building that half; the ruling lands
  in this file, then the build proceeds (the 4E pattern). U1's function shape is pre-declared as
  exactly such a fork (the U1 brief).
- **`notes/SessionResiliencyProtocol.md` binds every session** — checkpoint per piece, records
  before final verification with PENDING marks, no subagents from implementers, commit before
  any behavioral revert.

## BASELINES (18l-c's finals, 2026-09-28 — read, never re-run at start)

Install: `/Applications/Variorum.app` = **`4e461177…`** (Release from `f9427a2d`, the 18l-c
closeout refresh; A1 copy `18lc-refresh-20260928T225205Z`). Tree at this kickoff: `main` ==
`origin/main` at `34210692`, clean. Core **1729/181** (18l U0's closing run — the last full
core-touching run; 18l-c U8 added the `arrival_flash` pair, its filter 9/9). Full Mac
**3168/522** at 18k's finals; 18l-c per-unit closing sets 1608/266 (U7, one attributed
pre-existing row-58 red) · 602/99 (U8, 5 known, none its own). **Mobile: the last FULL suite
run is 18k's finals — 643/109 with exactly the 4 known** (row 49's tutorial lesson pins among
them); since then the phone gained U6's Jekyll first-write + restore pins
(`MobileFirstWriteFurnitureTests` 12/12, `MobileSeededBookRestoreTests` + FWF 14/2). **U1's
finals re-establish the full-mobile baseline** (the fence makes the full mobile suite part of
every unit's finals). VisualWalk: **17 seeded scenarios × 2 voices**; `takes-find` is
order-dependent in full runs (17w's row); the harness's 17w hazards bind — prefer targeted
scenario subsets for regression cover, and NEVER let a scenario type after a failed keyboard
probe (the takemania corruption's mechanism, healed at 18l-c). Known load-flake context:
KnownIssues rows 58 (BookOutlineLandingTests order-dependent large-run red at 3424) · 90 (the
C2 inline pins red when the dev store's voice is Study — restore Terminal after walks) · 93
(pointer-injection suites red under real machine input).

## THE CONDUCTOR MAP (verified at this kickoff against TODAY's tree — the review's §3 bands, re-based; the implementer re-reads the code itself)

- **The routing cascade** (U1's subject): Mac `EditorViewModel.shouldChangeText` (:1043, the
  `.refuse(.crossesBlockBoundary)` ladder at ~:1097–1201) — find-replace gate →
  `planEmptyBlockDeletion` (A7 carve) → `planSeamMerge` (#34) → `planWholeBlockDeletion` (J9)
  → `planClampedInBlockEdit` (#109 (i)) → `planCrossBlockEdit` (the compound) → the
  `CrossBlockRefusal.message` diagnose arm; plus the Mac-only pre-arms (the seal refusal, the
  ⇧⏎ soft-newline tail arm). Phone `MobileEditorViewModel.shouldChangeText` (:1204, the ladder
  at ~:1245–1373) — `planWholeBlockDeletion` → `planClampedInBlockEdit` → **the gap fence**
  (`index.wholeBlockRunAwaitsSync(covering:)` → `.readOnlySlot`) → `planCrossBlockEdit`
  (merge-then-edit) → the diagnose arm with `fanRoads:`; plus the phone-only pre-arms (the
  liveness belt, `MobileEditTrace`). **Different arms in a different order, as the review
  said**: the Mac's seam carves (empty-block, texted-seam) are ABSENT on the phone (row 51,
  deliberate); the phone's gap fence is ABSENT on the Mac (its storage road is synchronous);
  both ladders' comments argue the order in prose. The Mac's arms forward to
  `EditorSurfaceController` (`structural.plan…`); the phone's to `MobileStructural`. The
  planners themselves are already shared (`Shared/EditorBrain/`: `StructuralGesturePlanner`,
  `CrossBlockCompound`, `BlockRangeIndex`).
- **Crystallization** (U2): Mac :1491–1779 (`armTailIdleMint` · `mintableTail` ·
  `runSoftNewlineInTail` (Mac-only) · `idleMintTail` · `attachLeadingTailRunIfNeeded` ·
  `crystallizeIfNeeded` · `finishMint`); phone :1684–1899 (same names, no soft-newline arm).
  Verified near-byte-identical at this kickoff, comments included; the deltas: the Mac's
  `structuralInFlight` guards (the phone has no structural-flight concept on those two
  guards), the marked-text accessor (`hasMarkedText()` vs `markedTextRange`), and the error
  arm (`showOperationError` vs `statusMessage =`).
- **Storage primitives** (U2): Mac :900–1040 (`setSurfaceContent` · `applySeamEdit` ·
  `adoptRewrite` · `holdTailIdleClock` · `awaitMintSettle` · `applyPendingIfClean`); phone
  :1899–2013 (`viewText` · `syncTailText` · `programmaticReplace` · `setBlockAttribute` ·
  `restampProjection`) plus its own `applyDifferential`/projection settle (:671, :753). The
  accessor difference is the review's (`textView?.textStorage` vs `storage`); the phone's
  `restampProjection` is DELIBERATELY phone-only (iOS widens reports; the Mac never re-stamps)
  — a declared platform difference, not drift.
- **The identity audit** (U2): Mac :1445–1472 ≡ phone :2015–2037, byte-identical modulo the
  one accessor — both already consume the shared `IdentityProjectionAudit`; the duplicated
  part is the five-line consumer + `desyncRecovery`'s surrounding shape.
- **Refusal copy** (U3): the Mac's private `operationMessage` (:4506, ~13 cases) beside
  `Registry/OpsRefusalCopy.swift` (725 lines, Mac-app layer); the phone's `message(for:)`
  (:2063) + SIX `OperationError` switch sites (`MobileMembership` :175 · `MobileBlockMenu`
  :364 · `MobileComments` :286 · `MobileStructural` :889 · `MobileTrashModel` :278 ·
  `MobileUndoDoor` :276). **The sealed-note sentence exists in FOUR spellings today** — Mac
  gate *"This note is sealed — unlock it to edit."* · Mac `operationMessage` *"This note is
  sealed — unlock it first."* · `OpsRefusalCopy` *"This note is sealed — unseal it to change
  takes or choices."* · phone gate *"This note is locked — unlock it to edit."*
- **The tutorial-seeder scaffolding** (optional U4): Mac `TutorialSeeder.Existing`/`discover`/
  `restore`/`cleanup` (:148–:239) duplicated at `MobileTutorialSeeder` (:100–:179) — and a
  THIRD instance of the `Existing`/discover shape at `MobilePerfFixtureSeeder` (:203),
  enumerated at the unit if taken.
- **The conductor is TODAY'S TREE, never the review's snapshot** — the seam moved at 18l/18l-b/
  18l-c and the U2 hoist must not fight: `ReadingAnchor` + `EditorRouter.scrollPlaces` +
  `renderFull`'s exact restore (18l U0b/U0c), the note-open arm (`CommandRouter.openingLanding`
  read by `applyFocusSeeds`), `keepUntouchedReadingLine` + `applyStructuralResult`'s anchor
  capture on the differential road (18l-b U-B5), and U8's mode-switch band/flash steps
  (`pendingModeSwitchArrival`, `consumeModeSwitchArrival`) — all Mac-conductor-adjacent, all
  pinned; their pins ride UNMODIFIED.

## THE UNIT ROSTER (the charter's units, in its order — each lands alone, each on the 3C proof)

- **U1 — the routing cascade becomes a pure function.** `Shared/EditorBrain/`: a pure
  `Route`-deciding function over the verdict/index facts and a **declared platform capability
  set** (the Mac's seam-carve arms; the phone's gap fence) so each platform's arm set and ORDER
  is DATA the function is tested over, not prose in an if/else. Both view models' cascades
  become one call. **Proof:** every existing routing/gesture pin on BOTH platforms rides
  UNMODIFIED, plus a NEW pure table suite pinning the ORDER itself per platform (the thing that
  is untestable today). **Zero behavior change per platform is the acceptance bar — a differing
  route for any input is a FINDING, not a fix** (recorded, routed to its owner; the phone's
  missing arms stay missing as declared absences). Editor seam → Fable review.
- **U2 — crystallization, the storage primitives, the identity audit** hoisted on the 3C
  pattern (pre-move names forwarded where consumers need them; the platform accessor
  differences become the thin injected surface; deliberate platform deltas — the Mac's
  `structuralInFlight` guards, the ⇧⏎ arm, the phone's `restampProjection` — stay DECLARED,
  never averaged away). Zero test edits on both platforms is the proof; the Mac suite AND the
  full mobile suite run at the unit's end. **MAY-take, decided and recorded either way:**
  KnownIssues row 74 — the phone's autosave-registry leak (`MobileEditorViewModel.swift:187`
  acquires, nothing releases; the Mac's 18k C1 fix — release at the owner's exactly-once end
  of life, drop only through a landed leaving savepoint — is the model). The touch rule may
  take it here; a take needs its own red-on-old pin (the registry count across an open→close
  cycle, C1's form). The round's hardest unit → Fable review.
- **U3 — one refusal table.** `OpsRefusalCopy` hoists to `Shared/` (the synced-vocabulary
  home); `EditorViewModel`'s private `operationMessage` switch is DELETED in favour of the
  table; the six mobile `OperationError` switches collapse onto it, **keeping platform
  door-names local** (MobileSoul §4.4 — a shared home must not hold words naming a platform's
  own doors; the phone's `fanFoldRoads` parameter is the standing precedent). The sealed-note
  wording converges on ONE sentence — the canonical table's string is the spec-defensible
  default, **PROVISIONAL** (copy is hers; a QUESTIONS row quoting all four current spellings).
  → Fable review.
- **U4 (OPTIONAL — the orchestrator's sizing call, made at U3's close and recorded):** the
  tutorial-seeder scaffolding dedup (~120 lines of `Existing`/discover/restore machinery;
  lesson CONTENT stays per-platform by design — row 49's lesson rewrite stays the mobile
  catch-up's). If left, it stays row 28(b)'s next-touch item — never silently dropped.

**Sizing (the guidance's raise-it rule, said out loud):** U2 is the phase-sized unit; U1 is at
the session/phase boundary (an op-family-wide extraction across two platforms); U3 and U4 are
session-sized. Within the two-phase-sized-units line under one theme; nothing to raise.
**Scope statement on KnownIssues row 70** (owned 18m): this phase's charter discharges TWO of
its five decomposition rows — the routing cascade (U1) and `operationMessage`'s deletion (U3).
The other three (`EditorDecorationCoordinator` · `EditorLandingController` · `contextMenuItems`
as a builder) are NOT in the ratified charter and would push the phase past sizing; at the
closeout the row re-words to its remainder with a named-owner PROPOSAL in her bundle (a fresh
letter, or 18n's zero-behavior-change roster) — never silently kept or dropped. The VALUE-SEAM
rule binds any split this phase does make: a state struct passed in and returned, never another
`model:` back-reference.

## ENVIRONMENT TRAPS (carried into every unit brief VERBATIM — the 18l-c file's set, plus this kickoff's dated notes)

- Instance checks: `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH (the test
  host matches mid-run). Real-store instances are identified by STORE, not path — NEVER quit or
  kill one; no Release builds or `/Applications` refreshes while one lives. Xcode Run = Debug =
  the fenced dev store (`io.lduarte.Variorum.debug`). **Dated note (this kickoff): her
  real-store instance is LIVE (pid 85601) — assume she may be at the machine at any moment;
  GUI driving only behind the per-step guard, harness-only when in doubt.**
- **An old build must NEVER open the dev store** — bisect by harness in a scratch worktree
  (in-memory store), never by running an old build against a live store (the 18k C2 precedent).
- Mac tests from `App/Variorum/`: `xcodebuild -scheme Variorum -destination 'platform=macOS' test`
  with SUITE-LEVEL `-only-testing` only; confirm the "Test run with N tests" line (Swift Testing
  counts SKIPPED tests in N — read the `skipped:` lines). `build-for-testing` compiles without the
  runner. zsh: `pipestatus`. NEVER add a custom build configuration (any configuration not named
  exactly "Debug" builds the SPM packages Release and silently strips VariorumCore's DEBUG
  oracles). **Mobile tests: `xcodebuild -scheme VariorumMobile` against the iPhone simulator
  destination the last records used (iPhone 17 Pro); the FULL mobile suite at every unit's end;
  the generic-iOS build (`-destination generic/platform=iOS`) proves compilation where a unit
  touches `Shared/` without a simulator run in between.**
- Suites running beside a live session flash the test host's windows; the pointer-injection
  suites (KnownIssues row 93) red if anyone uses the machine — a full run that must be trusted
  runs with nobody at it. Prefer zero-instance windows for timing-sensitive measurements. The C2
  inline pins red when the DEV STORE's voice is Study (row 91) — restore Terminal after any walk.
- Walks: `cliclick` + `Tools/WalkKit/` on the DEV-STORE Debug build only. Accessibility + Screen
  Recording are granted to Ghostty. Walker facts from the 13u4 F1/F2/F3 records bind: a single
  `cliclick` click is sometimes swallowed by activation — click twice on an idempotent row; the
  landing signpost reads back via
  `/usr/bin/log show --predicate 'eventMessage CONTAINS "landing surface"'` filtered on `end=`;
  `walk-scroll` positive line count = DOWN; the ← → history bar appears after the first
  navigation and pushes rows ~17 pt down — measure click targets from a capture taken in the
  CURRENT navigation state. Screenshots into gitignored dirs (`notes/plans/18m-screens/…`).
- **SYSTEM DIALOGS:** before any GUI burst, check for foreign dialogs over the work area (the
  VisualWalk helper does; `guard.sh` CANNOT see them); never click a point a system dialog
  covers; never type unless OUR window is key. **A consent dialog is ANSWERED BY THE AUTHOR ONLY
  — never by a session**; if one appears, record it, work around it or hold, and put it at the
  top of her bundle. Never osascript an app that is not ours.
- **NO GUI DRIVING WHILE THE AUTHOR IS AT THE MACHINE** (the 18l U0 incident's hardened rule,
  binding every walk step): (1) check HID idle BEFORE EVERY GUI step — recent input (< a few
  seconds) means STOP and wait or go harness-only; (2) verify the TARGET window immediately
  before each click — the dev pid frontmost AND its window on the current Space at the expected
  frame; (3) any doubt → harness-only until the machine is genuinely author-free (drives need
  unlocked + author-free + own `caffeinate -d`).
- **VisualWalk (17w's hazards, until 17w runs):** a scenario must never TYPE after a failed
  keyboard probe (the takemania corruption's mechanism — healed once by hand at 18l-c); the
  full-suite `takes-find` is order-dependent; prefer `--only` scenario subsets for per-unit
  regression cover; verify fixture preconditions before trusting a red.
- Backups: WAL-safe, UTC names, ALWAYS before touching the real store; into the SUBFOLDER
  `Backups/safety-copies/` (R-18k-8), never loose in `Backups/`.
- Never `git checkout` over uncommitted work (commit before any revert — resiliency addendum
  11); push after every commit; never rewrite pushed history. Staging is pathspec-limited
  (`git add <files>`, never `-A`). The harness's instance check can self-match a caller's own
  compound command line containing the pattern text — run the driver in a command that does not
  spell `Variorum.app/Contents/MacOS`.

## THE LEDGER (every row owned; dispositions land here)

| # | Item | Unit | Status |
|---|---|---|---|
| 1 | The routing cascade as ONE pure function in `Shared/EditorBrain/` — declared platform capability sets, order as data, a pure table suite pinning the ORDER per platform; both cascades one call; zero behavior change per platform (a differing route is a FINDING) | U1 | open |
| 2 | Crystallization + the storage primitives + the identity audit hoisted on 3C (thin injected accessor surface; deliberate platform deltas declared; zero test edits both platforms) | U2 | open |
| 3 | MAY-take: KnownIssues row 74 — the phone's autosave-registry release (the Mac's 18k C1 fix is the model); decide at U2, record either way with its own red-on-old pin if taken | U2 | open |
| 4 | One refusal table: `OpsRefusalCopy` → `Shared/`; `operationMessage` deleted; the six mobile switches collapse; door-names local (§4.4); the sealed-note sentence converges — PROVISIONAL, QUESTIONS row quoting all four current spellings | U3 | open |
| 5 | OPTIONAL U4: the tutorial-seeder scaffolding dedup (content stays per-platform; the `MobilePerfFixtureSeeder` third instance enumerated); sizing call at U3's close, recorded either way | U4 | open |
| 6 | Row 28's fork-list enumeration updated in the SAME commit as each hoist (the touch rule): (a) the conductor band discharged by U1+U2; (b) the seeder scaffolding by U4 or re-recorded as next-touch | U1/U2/U4 | open |
| 7 | Row 70's disposition at close: the cascade + `operationMessage` rows DISCHARGED; the remaining three decomposition rows re-worded with a named-owner proposal in her bundle | closeout | open |
| 8 | MOBILE PARITY at close — LOAD-BEARING this phase: state exactly what the catch-up can now build on (the shared route function's declared-arm seam; the shared conductor pieces) and what it still owes (row 51's carves as declared absent arms, the refusal-copy faces, row 49's lesson rewrite) | closeout | open |

## THE SITTING RECORD (kickoff, 2026-09-29)

- **Her paste, verbatim:** *"/architect-phase 18m, the mobile session hoist phase."* The full
  kickoff prompt she pre-authorized at the 18l-b close (the handoff's last section) is the
  binding mandate; nothing in her paste redirects it. Cast confirmed as ruled there:
  `opus-implementer` per unit, **Fable cold review on EVERY unit**, cross-model flow.
- **Autonomy:** the ratified kickoff's own words — *"PROVISIONAL-and-continue with author-only
  calls as hard stops"* — govern this run; anything genuinely hers is HELD and BUNDLED for her
  next sitting. Her standing bundle from 18l-c (#155–#158, the two §12 proposals, the
  disclaimer polish, the tray observation) is SURFACED, never re-decided; none of it gates
  18m's units as scoped.
- **Sizing and the row-70 scope statement:** recorded above (THE UNIT ROSTER); within the
  guidance; the row-70 remainder goes to her bundle at close.
- **Her real-store instance is live at kickoff** — the install refresh is deferred to a window
  she grants; recorded so the closeout ritual plans for it rather than assuming the 18l-c
  pattern (her app was quit then; it is not now).

## U1 BRIEF (session 1 — the routing cascade becomes a pure function; written by the orchestrator 2026-09-29)

You are the `opus-implementer` for **18m UNIT U1**. One acceptance unit: the cross-block
routing cascade — the code that decides whether a keystroke deletes blocks — becomes ONE pure,
tested decision in `Shared/EditorBrain/`, consumed by BOTH view models, with each platform's
arm set and ORDER declared as data. **The charter's U1 bullet is your unit charter, read it in
full** (`notes/plans/post-13u-health-rounds.md` KICKOFF 3).

**Read first, in this order (reading is never delegated):**
(1) THIS file whole — the fences, BINDING PRINCIPLES, CAST & DISCIPLINE, BASELINES, THE
CONDUCTOR MAP (the two cascades' verified band map — then re-read the code yourself), THE
LEDGER rows 1 and 6, ENVIRONMENT TRAPS (they bind you verbatim).
(2) The charter's KICKOFF 3 whole (`notes/plans/post-13u-health-rounds.md`).
(3) `notes/codebase-health-review-2026-09-21.md` §3 (the finding) and §2.1 leak 1 (the
cascade's order "a business rule … untestable without a live NSTextView"); its §8 caveat — the
review is a record, not canon; the TREE outranks it.
(4) `notes/KnownIssuesAndTechDebt.md` rows 28 (the fork rule + the 3C proof standard — your
commit updates its enumeration), 51 (the phone's missing seam carves — you make them BUILDABLE
as declared absent arms and NEVER build them), 70 (the decomposition row your unit part-
discharges), 74 (context only — U2's may-take).
(5) `notes/MobileSoul.md` §3 and §4.4 (brains shared, faces per platform; refusal copy naming
a platform's own doors stays platform-local).
(6) `notes/TEXTKIT2_NOTES.md` IN FULL (editor seam — mandatory; §3's macOS-27 findings are the
era's facts; your unit should touch NO layout code, which is itself worth knowing).
(7) `notes/SessionResiliencyProtocol.md` whole (the checkpoint protocol binds from your first
commit).
(8) The code, END TO END before touching it: `EditorViewModel.swift` :1043–:1350 (the gate,
the ladder, `storageDidEdit`'s consume road, `fallbackVerdict`) and the planner forwards
(:2039–:2140); `EditorSurfaceController`'s plan functions the forwards name;
`MobileEditorViewModel.swift` :1199–:1680 (the gate, the ladder, the consume road, its
`fallbackVerdict`), `MobileStructural.swift` (the phone's executors); everything in
`App/Variorum/Shared/EditorBrain/` (all 13 files — `BlockRangeIndex` and `CrossBlockCompound`
are the planners your route decision fronts; `EditorEditRouting.swift` holds `ArmedEdit` and
is the natural HOME candidate for the new function, your call); the pin files that ride this
surface — Mac: `BoundaryFluidityTests`, the seam/carve/compound suites (grep
`planEmptyBlockDeletion|planSeamMerge|planWholeBlockDeletion|planClampedInBlockEdit|planCrossBlockEdit|CrossBlockRefusal`
over `VariorumTests/` and read every suite you find), `ReturnKeyTraceTests`/`TypedReturnTests`
(the ⏎ road above the ladder); phone: `MobileCrossBlockEditBrainTests` and the gesture/routing
suites (same grep over the mobile test tree). Know the known-flake facts before you read a
red: `BoundaryFluidityTests`' macOS-27 intermittency was traced to a TEST race and fixed at
18k C6 (row 65's (2)); row 58's BookOutlineLandingTests red is order-dependent under large
runs and NOT yours.

**The unit, in order:**
1. **TRACE both cascades yourself** and write the ARM TABLE into your record: per platform,
   the ordered arms with each arm's guard, its executor hand-off, and the RULING its order
   encodes (the Mac's comments cite them: A7 before #34 by geometry, J9 above the compound by
   her stated order, the clamp below J9, the phone's gap fence above merge-then-edit by MINOR
   3(a)). This table is the unit's design input AND its documentation deliverable — the order
   stops being prose.
2. **PROPOSE THE FUNCTION SHAPE BEFORE BUILDING IT (the architect rules this fork).** The
   design space, honestly: (a) a pure `route(facts) -> Route` that takes PRE-COMPUTED plan
   options (eagerly running every planner changes evaluation order/cost); (b) an ordered
   declared-arm LIST per platform (`[Arm]` as data) that the caller walks, trying each arm's
   planner lazily in the declared order — the order is data, the planners stay lazy, and the
   phone's absent arms are absent LIST ENTRIES (row 51's carves become one-line list additions
   later, which is exactly "buildable, never built"); (c) a hybrid (the function takes the
   capability set + lazy plan closures). Write your proposal with the trade-offs INTO YOUR
   RECORD, commit, and STOP for the orchestrator's ruling before building that half. Whatever
   shape wins: the pre-arms that are platform FACES (the Mac's seal sentence, the phone's
   liveness belt, `MobileEditTrace`) may stay at the call sites — say where you drew the
   boundary and why; the CROSS-BLOCK ladder itself is the non-negotiable scope.
3. **BUILD it in `Shared/EditorBrain/`** with both view models' ladders becoming one call
   each. The 3C bar: every existing routing/gesture pin on BOTH platforms rides UNMODIFIED —
   a pin needing edits means the move changed behavior: STOP and re-trace. The prose rulings
   in the deleted ladders' comments MOVE with the arms (the order's why lives at the data
   now, never lost).
4. **THE NEW PURE TABLE SUITE** — the thing that is untestable today: for each platform's
   declared set, pin the ORDER itself (input shapes × the arm that must claim them: a lone
   empty separator, a texted seam, a whole-block run, a one-block-plus-separator span, a
   mid-to-mid span, a gap-slot run on the phone) and pin the CAPABILITY DIFFERENCES as
   declared facts (the phone's set lacks the seam arms; the Mac's lacks the gap fence). These
   pins are NEW-BEHAVIOR pins for the table (compile-red/new-API class is acceptable for the
   table itself); the ROUTE-EQUIVALENCE claim rides the unmodified existing pins.
5. **Zero behavior change per platform is the bar.** If your trace finds any input the two
   ladders route DIFFERENTLY than their declared arms would (or an input whose routing looks
   WRONG against a ruling), that is a FINDING: record it (mechanism + the ruling it crosses),
   route it to the orchestrator, and build the declared table to TODAY's behavior — never fix
   product behavior inside a hoist.
6. **Row 28's enumeration** (the conductor band's cascade half) is updated IN THE SAME COMMIT
   as the hoist; row 51 gains one line naming the declared-absent arms as its build seam.
7. **WALK (USE) + finals:** a hands-on dev-store walk of the arms' felt behavior (both
   voices): ⌫ on an empty block at a seam (the carve + its receipt), ⌫ at a texted seam
   (fanless join; fanned → the deliberate-merge refusal), a whole-paragraph selection + Delete
   (the tray road), a one-block-plus-separator span typed over (the clamp), a mid-to-mid span
   (the compound), and an ordinary in-block keystroke (nothing regressed). VisualWalk subset
   as regression cover (`--only write-newline-roundtrip,write-divide-merge,b5-more-roads`,
   both voices). **Finals: the touched Mac suites + the routing/seam/compound families + the
   eleven Tutorial suites (suite-level `-only-testing`), AND THE FULL MOBILE SUITE** (the
   fence — its counts re-establish the mobile baseline; expect the 4 known; anything else is
   attributed before it is accepted), and the generic-iOS build if `Shared/` changed (it
   will).

**Discipline (the resiliency protocol, restated — it binds you):** commit per coherent piece,
push after EVERY commit, NO trailers; append a `## U1 RECORD` section to THIS file with LIVE
STATUS from your FIRST commit (per-piece lines: DONE (hash) / IN-PROGRESS / NOT-STARTED; every
unverified claim marked PENDING); records before final verification; synchronous foreground
waits only (poll the log — never end your turn awaiting a background run); NEVER spawn
subagents; commit before any behavioral revert; pathspec-limited staging; tests at the END,
never the full suite at start. PROVISIONAL-and-continue for non-gating ambiguity (QUESTIONS;
next free #159); STOP and report for gating ambiguity, any product-behavior change, anything
wanting `Sources/VariorumCore/Sync/`, and every author-only call. Your diff is the editor
seam by definition → a **FABLE cold review** follows; your self-assessment closes your record.

## LIVE STATUS (orchestrator; flipped per piece)

| Piece | Status |
|---|---|
| Preflight (canon + charter + health review + KnownIssues whole + QUESTIONS + resiliency + TK2 notes + MobileSoul + the 18l/18l-b/18l-c records + both conductors read side by side + EditorBrain) | DONE (this session, 2026-09-29) |
| This record file (constitution, baselines, conductor map, roster, ledger, traps, U1 brief) | DONE (this commit) |
| U1 (session 1) | NOT-STARTED — spawn follows this commit |
| U2 → U3 → (U4?) | NOT-STARTED — briefs written one-ahead at each close |
| Closeout | NOT-STARTED |
