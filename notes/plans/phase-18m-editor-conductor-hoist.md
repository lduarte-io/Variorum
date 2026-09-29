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
| 4 | One refusal table: `OpsRefusalCopy` → `Shared/`; `operationMessage` deleted; the six mobile switches collapse; door-names local (§4.4); the sealed-note sentence converges — PROVISIONAL, QUESTIONS row quoting all four current spellings. **+ U1's O-1 (2026-09-29):** the gap-refusal copy divergence (Mac `.unsyncedBlock` sentence vs the phone's P3 read-only sentence; the tail-vs-gap cause ranking) is this unit's input too | U3 | open |
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

## U1 RECORD (the `opus-implementer`, session 1 — opened 2026-09-29)

**NOT DONE (first line, per the contract): THE WALK — step 7b is HELD, not run: `guard.sh --author`
exits 3 because her real-store app (pid 85601) is live, and quitting it is hers alone. The unit's USE
acceptance is therefore OPEN; everything else (steps 1–6 and the harness finals) is DONE and pushed.**
No revert is in flight. *(History: the unit paused at the step-2 checkpoint; the architect's ruling —
(c) with (c1), six conditions — is the section below the proposal.)*

### LIVE STATUS

| Piece | Status |
|---|---|
| Preflight reads (this file whole; charter KICKOFF 3; health review §2.1/§3/§8; KnownIssues rows 28/51/70/74; MobileSoul §3 + §4 item 4; TEXTKIT2_NOTES whole; SessionResiliencyProtocol whole; both cascades + both consume roads + `fallbackVerdict`s; the Mac planner forwards and `EditorSurfaceController`'s plan/run functions; `MobileStructural` whole-block + compound executors; all 13 `Shared/EditorBrain/` files; the pin suites — Mac `SeamMergeTests`, `WholeBlockDeleteTests`, `BoundaryClampTests`, `CrossBlockCompoundTests`, the find fence pins in `FindAndReplaceTests`, `EditorSeamCostTests`' plan pins; phone `MobileCrossBlockEditTests`, `MobileWholeBlockDeleteTests`' gate pins, the `MobileEditRoutingTests` roster) | DONE (read in this session, never delegated) |
| Step 1 — trace both cascades; the ARM TABLE | DONE (this commit) — below |
| Step 2 — the function-shape proposal, options (a)/(b)/(c) | DONE (this commit) — **AWAITING THE ARCHITECT'S RULING; nothing is built until it lands** |
| Step 3 — build in `Shared/EditorBrain/`, both ladders one call | DONE (the hoist commit — see BUILD NOTES below) — Mac `build-for-testing` and the generic-iOS build both green; **every behavior claim PENDING the finals** |
| Step 4 — the new pure table suite (order per platform + declared capability differences) | DONE (the table commit) — `VariorumTests/EditorEditRouteTableTests.swift` **19/19 green** (literal lists; the Mac gate walks `macArms`; capability differences as facts; precedence on both lists + the vacuous-pass-then-bites pin; shape × claimant per platform incl. A7's real guards and O-3's seeded slots; ORDER-BITES by permutation for J9≺clamp (with the laziness proof: 0 surface reads), J9≺compound, fence≺carve; the gap fence as a COPY arm; the every-small-edit property: undeclared arms never answer, ≤ 2 surface reads). Phone twin `VariorumMobileTests/MobileEditRouteArmsTests.swift` (3 pins) — **PENDING the full mobile suite** |
| Step 5 — findings routed; build to TODAY's behavior | DONE for the trace (no within-platform mis-route found; three observations below, routed) — re-checked at build |
| Step 6 — row 28's enumeration + row 51's build-seam line, same commit as the hoist | DONE (the hoist commit) — row 28 (a)'s cascade half recorded DISCHARGED with its count PENDING the finals; row 51 gains its build-seam sentence |
| Step 7a — finals (harness) | DONE on tree `66e6f674` (App/ unchanged since), her real-store instance live (pid 85601, untouched), no dev-store instance: **Mac routing/seam/compound families — 40 suites named literally in two runs: `✔ 223 tests in 20 suites` + `✔ 171 tests in 20 suites`, 0 skipped** (`u1-mac-routing-a.log` / `-b.log` in the session scratchpad; the new table suite included); **the eleven Tutorial suites — `✔ 79 tests in 11 suites`**; **the FULL mobile suite (iPhone 17 Pro simulator) — `647 tests in 110 suites`, 5 issues = the 4 KNOWN (`MobileTrashTests` ×2, `MobileTutorialWalkTests.theFannedDivideLessonLandsTheDuplicateShape` ×2 — row 49's) + 1 ATTRIBUTED PRE-EXISTING red, F-1 below; 0 skipped** — the full-mobile baseline RE-ESTABLISHED at 647/110 (18k's 643/109 + 18l-c U6's pin + this unit's 3); the phone twin `MobileEditRouteArmsTests` 3/3 and every phone routing suite green; **generic-iOS build `** BUILD SUCCEEDED **`** (the hoist commit). **The 3C proof: `git diff 3975b682..HEAD` over both test targets adds exactly the two NEW files — zero existing pins edited.** |
| Step 7b — the walk (both voices, the six felt arms + the VisualWalk subset) | **HELD — NOT RUN.** `Tools/WalkKit/guard.sh --author` answers `GUARD: her app is running — STOP` (exit 3): her real-store `/Applications/Variorum.app` (pid 85601, up since 2026-09-28 23:09) is live, and the guard's first check refuses every GUI step while it is — quitting it is HERS alone, never a session's. The VisualWalk subset consumes the same guard. The ready-to-run script is `U1 WALK SCRIPT` below. **The unit's USE acceptance is therefore OPEN** (the harness evidence below is the floor, never the gate). |

### STEP 1 — THE ARM TABLE (today's tree, `3975b682`)

The ladder is the body of each gate's `.refuse(.crossesBlockBoundary)` arm — Mac
`EditorViewModel.shouldChangeText` (:1043; the arm :1097–1201), phone
`MobileEditorViewModel.shouldChangeText` (:1204; the arm :1245–1373). Both arms first clear
`pendingEdit` and `bulkPending` (NIT 4's armed-beside doctrine — state, not decision), then walk
the ladder, then `return false` whatever it answered (the keystroke never half-applies).
Every claiming arm SCHEDULES its act on the next main-actor turn (Mac
`scheduleCrossBlockCompound`, `EditorSurfaceController.swift:2019`; phone
`scheduleGestureCompound`, `MobileEditorViewModel.swift:1474` — both chained, both clearing on
completion); every refusing arm speaks synchronously (Mac `refuseFeedback` :4468; phone
`refuse` :2059).

**MAC — seven arms, in this order:**

| # | Arm | Guard (the planner, and what it reads) | Executor hand-off | The RULING its position encodes |
|---|---|---|---|---|
| M1 | **find-replace fence** | `textView?.isFindReplacing == true` (a Mac-only fact: `EditorTextView.swift:292`) | refuses: `FindReplaceGate.refusal(single: .crossesBlockBoundary)` (Mac copy; names ⌘⇧M) | QoL batch 3 L6 — *"THE SAFETY CORE, and it runs before every planner: a FIND-DRIVEN replacement never restructures the post"* (:1114). FIRST because every arm below can delete or merge blocks. Pinned: `FindAndReplaceTests.aPlannedMatchThatDriftsAcrossASeamRefusesInsteadOfMerging` (the belt the valve cannot see) + `aTypedCrossBlockEditStillMergesThenEdits` (the flag does not leak). |
| M2 | **A7 empty-block carve** | `planEmptyBlockDeletion` (`EditorSurfaceController.swift:2331`): replacement empty ∧ `index.emptyBlockDeletion` (one inter-entry separator, a zero-length neighbour; the one BEFORE wins) ∧ entry editable with a variant ∧ `slots[i].activeVariantCount == 1` ∧ `!slots[i].carriesUnshownText` (the frozen projection — ENABLEMENT only; the op re-checks) | `runEmptyBlockDeletion` (:2364 — `deleteBlock(requiring: .emptyWithNothingUnshown)`, receipt *"Empty block deleted — ⌥⌘Z undoes it."*) | 13c 1B, her A7. Before #34 by GEOMETRY: the two are MUTUALLY EXCLUSIVE at every separator (A7 needs an empty neighbour, #34 two texted ones — pinned `SeamMergeTests.theCarveAndTheSeamMergeAreMUTUALLYEXCLUSIVEAtEverySeparator`, and "A7 first, unchanged": `anEmptyBlockAtTheSeamStillTakesTheCarveNotTheMerge`). Exclusive with everything below by construction (J9 excludes length 1; the clamp's nothing-to-do guard declines a lone-separator delete; a lone separator never reaches the compound — `CrossBlockCompoundTests.aLoneSeparatorCanNeverReachTheCompound`). |
| M3 | **#34 texted-seam merge** | `planSeamMerge` (:2423): replacement empty ∧ `index.textedSeamPair` ∧ both entries have a variant (geometry + liveness ONLY — the fan is read from the STORE at run time) | `runSeamMerge` (:2444 — store fan read; fanless → `runInstantMerge(joining: .deleteKeystroke)` + receipt *"Blocks joined — ⌥⌘Z undoes it."*; fanned → `seamFanRefusal`) | 13d batch 2, her #34 option (ii). Locked takes deliberately do not refuse (merge copies). Same exclusivity as M2. |
| M4 | **J9 whole-block delete** | `planWholeBlockDeletion` (:1237) → `index.wholeBlockDeletion` (delete-never-type-over; `wholeBlockRun` with length > 1; the GAP fence inside it) | `runWholeBlockDeletion` (:1244 → `runBlockDeleteCompound`: "Delete Blocks", `BlockSelectionCopy.deletedNote`) | 13j J9, her ruling. BELOW the seam carves (exclusive — the carves keep every ruled case). **ABOVE the clamp and ABOVE the compound, and here the order is LOAD-BEARING (not exclusive):** a whole paragraph + its newline + Delete is ALSO a clamp plan (it would empty the block in place) and a whole-block run delete is ALSO a compound plan (all blocks deleted, "Edit Across Blocks", refusing a locked take). J9 keeps #33(a)'s unrestricted delete — *"two gestures, two rulings, in her stated order"* (:1158). Pinned: `WholeBlockDeleteTests.aWholeParagraphSelectionDeletesTheBlock` / `theRouteIsOneUndoEntryAndItRoundTrips` ("Delete Blocks"). |
| M5 | **#109 shape (i) clamp** | `planClampedInBlockEdit` (`EditorViewModel.swift:1953`) → `CrossBlockCompound.clampedInBlockEdit` (an edge on an inter-block separator; the clamped span inside ONE entry; declines the degenerate lone-separator DELETE) | `runClampedInBlockEdit` (:1984 — CAS, then the ONE ordinary input door `OrdinaryInputEdit`; NOT structural, so ⌘Z is text undo) | Her #109 ruling (2026-09-15). BELOW J9 (J9 declines a type-over — which is exactly why the same span typed over lands here: `WholeBlockDeleteTests.tracePreFix…`, `BoundaryClampTests.typingOverAParagraphWithBothItsNewlinesReplacesItInPlace`). BELOW the carves (they own the lone-separator keystroke; the degenerate guard means this road can never route around them — `BoundaryClampTests.theLoneSeparatorCollapses…`). |
| M6 | **the cross-block compound** | `planCrossBlockEdit` (`EditorSurfaceController.swift:2543`) → `CrossBlockCompound.plan` (run ≥ 2 by the raw span incl. zero-length entries; clamped contiguity = the tail fence; every entry arrived (gap fence) and editable (R-13u-1)) | `runCrossBlockEdit` (:2568 — `runStructural` + `CrossBlockCompound.apply` with the store fan read; receipt via `StructuralOutcome.note`) | 13u1 UNIT 2, her item 5 (+ #109 shape (ii)'s trim, which lives INSIDE the plan). Last claimant. |
| M7 | **the diagnosis** (terminal) | `CrossBlockRefusal.message(range:index:slots:)` = `diagnose` (seam → tail → not-editable-in-run → `.surfaceNotSettled`) | refuses (Mac forward supplies `macFanRoads` = `FannedDefaultsCopy.fanFoldRoads`) | 13j J8(b) + the 13u1 U-5 hoist: every decline speaks its ONE real cause (P-2). |

**PHONE — five arms, in this order:**

| # | Arm | Guard | Executor hand-off | The RULING its position encodes |
|---|---|---|---|---|
| P1 | **J9 ≡ R18/M11 whole-block delete** | `planWholeBlockDeletion` (:1398) → `index.wholeBlockDeletion` (the SAME shared brain) | `structural.deleteWholeBlockRun` (`MobileStructural.swift:639` — flush, "Delete Blocks" compound, `blocksDeletedStatus` + Undo action; NO confirm by her R13 ruling) | Mobile round 2 batch 1b — the Mac's J9 inherited. First on the phone because there are no seam carves above it (row 51). |
| P2 | **#109 shape (i) clamp** | `planClampedInBlockEdit` (:1427) → `CrossBlockCompound.clampedInBlockEdit` | `runClampedInBlockEdit` (:1450 — CAS, then `MobileMarkdownActs.inputReplace`, the phone's one input door) | 13u2 UNIT C — *"It sits BELOW the whole-block delete for the Mac's reason"* (:1321). |
| P3 | **the gap fence's FACE** | `index.wholeBlockRunAwaitsSync(covering:)` (a whole-block run containing a not-yet-arrived block) | refuses: `message(for: .readOnlySlot)` — *"This block hasn't fully synced; it is read-only for now."* | Mobile round 2 batch 1b ladder, MINOR 3(a): *"It sits ABOVE merge-then-edit deliberately"* (:1335) — the compound would decline too (its own gap fence), so the order decides the WORDS: the phone's read-only sentence instead of a residual cause. Pinned: `MobileWholeBlockDeleteTests.aRunCoveringANotYetArrivedBlockRefusesAndSaysWhy`. |
| P4 | **the cross-block compound** (merge-then-edit, rebuilt at 13u1) | `planCrossBlockEdit` (:1414) → `CrossBlockCompound.plan` | `structural.runCrossBlockEdit` (`MobileStructural.swift:730` — flush, `CrossBlockCompound.apply` with the store fan read, wordless receipt + Undo action) | M22 + 13u1 UNIT 2. |
| P5 | **the diagnosis** (terminal) | `CrossBlockRefusal.message(range:index:slots:fanRoads: Self.fanFoldRoads)` | refuses (phone roads: *"Merge the blocks deliberately instead (⋯ → Merge…)"*) | 13u1 UNIT 2 U-5. |

**The declared capability differences (facts, not drift):** Mac-only — M1 (the phone's editor
has no find-and-replace; `isFindReplacing` exists nowhere under `VariorumMobile`), M2 and M3
(KnownIssues row 51 — deliberately unbuilt on the phone). Phone-only — P3 (on the Mac the same
condition is answered by the compound's own gap fence and then M7's `.unsyncedBlock`). Shared —
J9, the clamp, the compound, the diagnosis (the planners were already one brain; only the
ORDER and the arm SET were prose).

**Pre-arms (above the ladder, per platform — faces, not routing):** Mac —
`suppressEditProcessing`; the seal (*"This note is sealed — unlock it to edit."*); attribute-only
(`replacement == nil`); the ⇧⏎ soft-newline verdict input and its `.tail`-verdict mint arm
(it answers a `.tail` verdict, so it is outside the cross-block ladder by its own verdict).
Phone — `MobileEditTrace.gate` (instrument); `suppressEditProcessing`; the liveness belt;
the seal (*"This note is locked — unlock it to edit."*); attribute-only. The other verdict arms
(`.indexDesync`, the other refusals, the arming default + `MobileEditTrace.armedVerdict`) are
the verdict switch, not the ladder.

### STEP 5 (trace half) — FINDINGS

**No within-platform mis-route found.** For every shape I traced (lone separator beside an
empty/texted/fanned/archived/commented/gap/locked block; whole-block runs with and without a
gap, with and without the tail separator; the J9-vs-clamp and J9-vs-compound overlaps; shape (i)
and (ii) clamps; mid-to-mid spans; runs reaching the tail), each ladder's answer is what its
declared arms in their declared order produce, and no answer crosses a ruling. Three
OBSERVATIONS, routed to the orchestrator (none is a U1 fix — the hoist builds today's behavior):

- **O-1 (copy — U3's territory).** The SAME refusal condition speaks different sentences per
  platform: a whole-block run containing a not-yet-arrived block — Mac (M7 `.unsyncedBlock`):
  *"A block in this selection hasn't arrived yet — nothing was changed. It stays read-only until
  it syncs."*; phone (P3): *"This block hasn't fully synced; it is read-only for now."* And for a
  run ending ON the open tail's separator with a gap inside it, the Mac's diagnosis names the
  TAIL (step 2 outranks step 3) while the phone's P3 names the gap. Both refuse with nothing
  changed; the difference is words, so it belongs beside U3's four sealed-note spellings.
- **O-2 (shape).** P3 is a COPY arm: it never changes whether a gesture lands (P4 declines the
  same span on its own gap fence) — only which sentence she reads. The table will declare it
  as such, so the catch-up does not mistake it for a safety fence.
- **O-3 (standing, documented).** M2 reads the FROZEN projection for its enablement guards, so
  a seam keystroke beside a block the projection has not echoed yet declines and reaches M7's
  `.seamKeystrokeDeclined` — already recorded at `CrossBlockRefusal.Cause.seamKeystrokeDeclined`;
  noted only so the table suite's Mac pins seed the slots deliberately.

### STEP 2 — THE FUNCTION-SHAPE PROPOSAL (the architect rules this fork; NOTHING BUILT YET)

**The boundary (whatever shape wins):** the route decision begins where the verdict is
`.refuse(.crossesBlockBoundary)` and ends in a VALUE. It takes the ladder M1–M7 / P1–P5 whole,
**including M1** (the find fence is IN the route as a Mac arm, because its position — "before
every planner" — is a ruling about ORDER; its fact `isFindReplacing` is passed in and its words
stay Mac-local). Everything else stays at the call sites: every pre-arm above (faces and
instruments), the verdict switch's other arms, the `pendingEdit`/`bulkPending` clears (state),
every EXECUTOR (the roads, flights, flush contracts, store authorizations) and every SENTENCE
(the find copy naming ⌘⇧M, the phone's read-only copy, both `fanRoads`, the seal lines).

**(a) A pure `route(facts) -> Route` over PRE-COMPUTED plan options.** The caller runs every
planner, hands in the optionals, the function picks the first non-nil in declared order.
*For:* the simplest pure function; trivially table-testable. *Against:* it changes evaluation
COST and ORDER — every cross-block keystroke would run all planners even when the first claims.
Today a seam backspace costs `interEntrySeparatorPair`'s O(position) walk and stops; under (a) it
also pays `wholeBlockRun`'s two O(N) arrays, the clamp's O(N) `entryRanges`, the compound's O(N)
walk plus up to three surface reads, and the diagnosis's O(N) walk — P1's letter, on the
keystroke road, multiplied. Behaviour identical (the planners are pure), cost profile not.
**Not recommended.**

**(b) An ordered declared-arm LIST per platform, walked by each view model.** `[Arm]` is data;
each VM loops the list and switches arm → its own planner → its own executor, lazily. *For:*
least code moves; laziness natural; the phone's absent arms are absent list entries. *Against:*
the walk and the arm→planner mapping live TWICE (the drift class this unit exists to end, one
level down), and the "input shape × claiming arm" table cannot be pinned purely — only through a
mounted editor on each platform, which is the "untestable without a live NSTextView" the review
named and the charter's `EditorEditRoute.route(...) -> Route` is the answer to. **Not
recommended.**

**(c) — RECOMMENDED — a pure, LAZY `EditorEditRoute.route(...)` that walks the platform's
declared arm list itself, each arm's planner the SHARED pure brain.** Shape:

```swift
nonisolated enum EditorEditRoute {
    enum Arm { case findReplaceFence, emptyBlockCarve, textedSeamMerge,
               wholeBlockDelete, clampedInBlockEdit, gapFence, crossBlockCompound }
    static let macArms:   [Arm] = [.findReplaceFence, .emptyBlockCarve, .textedSeamMerge,
                                   .wholeBlockDelete, .clampedInBlockEdit, .crossBlockCompound]
    static let phoneArms: [Arm] = [.wholeBlockDelete, .clampedInBlockEdit, .gapFence,
                                   .crossBlockCompound]
    enum Route: Equatable {
        case refuseFindReplace
        case carveEmptyBlock(EmptyBlockCarve)          // M2's plan (hoisted type, see c1)
        case mergeTextedSeam(TextedSeamPair)           // M3's plan (hoisted type, see c1)
        case deleteWholeBlocks([String])
        case editInBlock(CrossBlockCompound.InBlockEdit)
        case refuseAwaitingSync                        // P3 — a copy arm
        case editAcrossBlocks(CrossBlockCompound.Plan)
        case refuse(CrossBlockRefusal.Cause)           // the terminal diagnosis — never declarable
    }
    static func route(range: NSRange, replacement: String, index: BlockRangeIndex,
                      slots: [Queries.RenderedBlock], findReplacing: Bool, arms: [Arm],
                      surfaceText: (NSRange) -> String) -> Route
}
```

Each arm is tried in list order and only until one claims — today's laziness and today's
evaluation order exactly; the diagnosis is the fixed terminal (every ladder must end speaking —
P-2 as structure). Each VM's ladder becomes: clear the two flags, `switch` on
`route(… arms: Self-platform-list …)`, map each case to its EXISTING executor/sentence, `return
false`. Arms a platform does not declare can never be returned to it (pinned); its switch
still names them (Swift exhaustiveness) and answers them with `EditorAssertionSeam.fire` + the
diagnosis — exactly what that platform says today for the same shape, so even the impossible
path changes no words. The ORDER RULES move to the data: each `Arm` case carries its ruling in
its doc comment (the prose above leaves the ladders), and a declared PRECEDENCE table —
`(before, after, ruling)` pairs: find fence ≺ everything; J9 ≺ clamp; J9 ≺ compound; clamp ≺
compound; the carves ≺ J9; gap fence ≺ compound — is pinned against BOTH lists, so when the
catch-up adds `.emptyBlockCarve`/`.textedSeamMerge` to the phone's list (row 51's "one-line list
addition"), a wrong position fails a named ruling rather than a walk.

**The one sub-fork inside (c), also yours to rule:**
- **(c1) — recommended:** hoist the two Mac-only plan WRAPPERS into `Shared/EditorBrain/` as
  pure functions over `(index, slots)` — A7's four enablement guards (~12 lines + their doc
  comment) and #34's liveness pair (~10 lines). Their GEOMETRY is already shared
  (`emptyBlockDeletion`, `textedSeamPair`); `EditorSurfaceController.planEmptyBlockDeletion`/
  `planSeamMerge` become one-line forwards and `EmptyBlockDeletion`/`SeamMerge` typealiases, so
  every pin that calls them rides unmodified (the 3C proof). The EXECUTORS (`runEmptyBlockDeletion`,
  `runSeamMerge`, their store authorizations and receipts) stay Mac-side. Result: the route is
  fully pure over the facts, the table suite pins EVERY arm with its REAL planner and no fakes,
  and row 51 reduces to exactly what it says — *"the phone needs the two roads and their
  authorizations, not new brains"*: two list entries plus two phone executors. The phone's list
  does NOT gain them (never built here).
- **(c2):** leave the two wrappers Mac-local and inject platform-local planners as closures
  (`Route` generic over the carve payloads, the phone instantiating `Never`). Smaller move,
  type-level absence on the phone — but the Mac's carve rows in the table suite would be pinned
  through test-built closures rather than the Mac's real guards, and the generic `Route` makes
  every call site noisier.

**Home:** a NEW file `Shared/EditorBrain/EditorEditRoute.swift` (the `Shared` group is a
filesystem-synchronized root in both app targets — no project edit), not
`EditorEditRouting.swift`: that file's two residents are the ARMING binding and the assertion
seam, and a ~250-line route with its ruling docs would bury them. (If (c1) is ruled, the two
hoisted plans live beside the route in the same file, under their own MARK.)

**The planned table suite (step 4, both lists, one pure file in `VariorumTests` over the shared
source; plus a one-line phone-target pin that `MobileEditorViewModel` passes `phoneArms`):** the
two lists pinned literally; the capability differences pinned as declared facts; the precedence
table satisfied by both lists; input shape × claiming arm per platform — a lone EMPTY separator
(Mac → carve · phone → `.refuse(.seamKeystrokeDeclined)`), a texted seam (Mac → seam merge ·
phone → `.refuse(.seamKeystrokeDeclined)`), a FANNED EMPTY seam (Mac → `.refuse(.seamBesideFan)`:
M2 declines on the fan, M3 on the empty neighbour) beside a FANNED TEXTED seam (Mac → still M3 —
its fan is the executor's store read, never the plan's), a whole-block run (both → delete), one block + its separator typed over (both
→ clamp), mid-to-mid (both → compound), a whole run with a gap (phone → `.refuseAwaitingSync` ·
Mac → `.refuse(.unsyncedBlock)`), a find sweep over a carve-shaped seam (Mac → fence); and the
ORDER-BITES pins — shapes two arms both plan (J9 + clamp; J9 + compound; fence + carve), with
the claimant asserted AND a permuted list asserted to answer differently, so the order is
provably the thing pinned.

**STOP — awaiting the ruling on (a)/(b)/(c) and, if (c), on (c1)/(c2).**

### U1 — THE FUNCTION-SHAPE RULING (orchestrator, 2026-09-29 — the 4E pattern: the proposal
came back before the build; this ruling is the settled ground it proceeds on)

**RULED: (c) with (c1).** The reasoning, so the ladder reviews a decision and not a preference:
(a) is rejected on P1's letter — the keystroke road's cost today is "first claim stops" (a seam
backspace pays one O(position) walk); eagerly running every planner multiplies that by the
ladder on every cross-block keystroke, a cost-profile change no hoist may make. (b) is rejected
on the charter's own purpose — the walk and the arm→planner mapping duplicated per platform is
the drift class one level down, and an order testable only through a mounted editor is the
exact untestable state the charter's `route(...) -> Route` exists to end. (c) is the charter's
letter: pure, lazy, declared lists, the diagnosis as the fixed terminal (P-2 as structure), one
call per view model. (c1) over (c2) because pins must bite REAL code: a table suite that pins
the Mac's carve rows through test-built closures is half-hollow by the hallucination guard's
own standard, and (c1) is row 51's "makes them buildable" half made real — the phone's future
carves become two list entries + two phone executors, with the enablement brains already
shared. The `EmptyBlockDeletion`/`SeamMerge` pre-move names stay as typealiases so every
existing pin rides unmodified (3C). The new-file home (`EditorEditRoute.swift`, not
`EditorEditRouting.swift`) is approved for the stated reason.

**Conditions riding the ruling (each cheap, each named so the reviewer checks them):**
1. **`surfaceText` stays a bounded read-only fact source:** the route never stores it, and the
   record states the read bound (the compound's ≤ 3 reads — today's cost, unchanged). The table
   suite supplies it as a pure string-backed closure.
2. **The precedence pins treat an ABSENT arm as a vacuous pass** — "carves ≺ J9" must pass on
   today's phone list (no carves) and BITE the day row 51 adds them. Say so at the pin.
3. **The view models' `switch` maps arm → existing executor/sentence and RE-DERIVES NOTHING**
   — no second guards at the call sites; the executors' own store-time re-checks (A7's
   op-level `.emptyWithNothingUnshown`, the compound's CAS and store fan reads) are the
   executors' and ride byte-untouched.
4. **The undeclared-arm exhaustiveness arms** answer with `EditorAssertionSeam.fire` + the
   platform's own diagnosis, exactly as proposed — and the record notes Release behavior is
   the diagnosis alone (the seam's default handler is a no-op outside DEBUG).
5. **P3 is declared a COPY arm in the table's doc** (O-2 adopted), and the capability-difference
   fact records WHY the Mac lacks it (M7's `.unsyncedBlock` speaks there).
6. **`findReplacing` is passed explicitly at both call sites** (no default) — the phone passes
   `false` and its list cannot fire the fence anyway; both facts pinned.

**The observations, dispositioned:** O-1 (the gap-refusal copy divergence + the tail-vs-gap
cause ranking) is ROUTED TO U3 — added to ledger row 4's scope as an input beside the four
sealed-note spellings (U3 decides convergence there, PROVISIONAL, copy hers; neither sentence
names a platform door, so §4.4 does not force locality — but the CAUSE-RANKING half is
words-about-behavior and U3 treats it with the same care). O-2 is ADOPTED into the table's own
documentation (condition 5). O-3 stays documented behavior — the table suite seeds slots
deliberately, as planned. **Proceed with steps 3–7.**

### U1 BUILD NOTES (steps 3 + 6 — the hoist commit)

**What moved, and where (an ADDRESS change — zero behavior intended per platform, PENDING the finals):**
- **NEW `App/Variorum/Shared/EditorBrain/EditorEditRoute.swift`** — `EditorEditRoute` (`Arm` with each
  arm's ruling at its declaration; `macArms`; `phoneArms`; `Precedence` + `precedence` + `violations(of:)`;
  `Route`; `route(range:replacement:index:slots:findReplacing:arms:surfaceText:)`) and, under its own MARK,
  `SeamCarvePlan` — the Mac's two seam-carve PLANS hoisted verbatim with their full doc (A7's four
  enablement guards + #40's PROVISIONAL; #34's ruling, precedence list, the fan-is-not-the-plan's
  doctrine, locked-takes-do-not-refuse). Only `model.slots`/`model.index` became the `slots`/`index`
  parameters.
- **`EditorSurfaceController`** — `EmptyBlockDeletion` / `SeamMerge` are now typealiases to the shared
  structs and `planEmptyBlockDeletion` / `planSeamMerge` one-line forwards (the 3C names every pin
  calls); `runEmptyBlockDeletion` / `runSeamMerge` (the ROADS and their store-time authorizations)
  untouched but for one comment word ("below" → the shared plan's).
- **`EditorViewModel.shouldChangeText`** — the `.crossesBlockBoundary` arm is the two flag clears + ONE
  `EditorEditRoute.route(… arms: Self.routeArms …)` call + `return false`; `static let routeArms =
  EditorEditRoute.macArms`; `performCrossBlockRoute(_:range:)` maps each `Route` to the SAME executor
  and the SAME sentence the ladder had (`FindReplaceGate.refusal(single:)`, `runEmptyBlockDeletion`,
  `runSeamMerge`, `runWholeBlockDeletion(WholeBlockDeletion(blockIDs:))`, `runClampedInBlockEdit`,
  `runCrossBlockEdit`, `CrossBlockRefusal.message(for:)` — the Mac forward with `macFanRoads`, byte-equal
  to the old `message(range:index:slots:)` composition), all through the same `scheduleCrossBlockCompound`.
- **`MobileEditorViewModel.shouldChangeText`** — the same shape with `static let routeArms =
  EditorEditRoute.phoneArms`, `findReplacing: false` said out loud, and the phone's executors/sentences
  (`structural.deleteWholeBlockRun`, `runClampedInBlockEdit`, `message(for: .readOnlySlot)`,
  `structural.runCrossBlockEdit`, `CrossBlockRefusal.message(for:fanRoads: Self.fanFoldRoads)`) through
  the same `scheduleGestureCompound`. Her R13 NO-CONFIRM ruling moved from the ladder to the
  `.deleteWholeBlocks` mapping (the door keeps its own copy of the note).
- The prose rulings that argued each ladder's order MOVED to `EditorEditRoute.Arm` (condition: "the
  order's why lives at the data now"); the per-case executor notes stayed at the mappings.

**The ruling's six conditions, as built (for the reviewer):**
1. **`surfaceText` is bounded and read-only:** a non-escaping parameter, never stored; consulted only by
   the clamp (ONE read, and only when it claims — the walk then stops) and the compound (AT MOST TWO
   reads — its surviving ends — and only when reached). **So one route reads the surface at most
   TWICE**, which is exactly the old ladder's bound. *(Correction to the ruling's "≤ 3": three was the
   eager option (a)'s figure — clamp read + compound's two — which lazy (c) never pays.)*
2. **Precedence pins pass vacuously on an absent arm** — stated at `EditorEditRoute.Precedence` and at
   the pin (step 4).
3. **The switches re-derive nothing** — each case is one executor call or one sentence; no guard at the
   call sites.
4. **The undeclared-arm cases** (Mac: `.refuseAwaitingSync`; phone: `.refuseFindReplace`,
   `.carveEmptyBlock`, `.mergeTextedSeam`) fire `EditorAssertionSeam` then speak the platform's own
   diagnosis. **Release behavior is the diagnosis alone** — the seam's default handler is
   `assertionFailure`, a no-op outside DEBUG — which is exactly what that platform says today when every
   declared arm declines.
5. **P3 is declared a COPY arm** in `Arm.gapFence`'s doc, with why the Mac lacks it (M7's
   `.unsyncedBlock` speaks there; the WORDS differ — O-1, U3's).
6. **`findReplacing` has no default** — Mac `textView?.isFindReplacing == true`, phone `false`.

### U1 FINDINGS FROM THE FINALS (routed to the orchestrator — none is U1's to fix)

- **F-1 — PRE-EXISTING, attributed: the phone's no-redirect sweep is RED on the kickoff tree.**
  `MobileStructuralTests` ▸ "Mobile no-redirect sweep (parity C5)" ▸ `nothingUserFacingNamesTheMac`
  (`:1137`) finds exactly ONE offender: `Shared/SampleLibrary/SampleLibraryJekyllBook.swift:91`, the
  Jekyll book's disclaimer literal *"… and, on the Mac, choose Help ▸ Restore “…”: a fresh …"*. The
  file was written at 18l-c U6 (`2772a6f4`, last touched `603e5fdb`, 2026-09-28) and is untouched by
  U1; the sweep reads SOURCE TEXT from disk, so its answer is a function of that literal alone and is
  identical on `3975b682`. It went unseen because 18l-c's closing runs ran the phone's first-write
  pins, never the full mobile suite (18k's finals predate the file). What it crosses: the parity C5
  no-redirect ruling (*"redirecting you to the mac to accomplish something is a bit of a red flag"*)
  — the Jekyll book is seeded on the PHONE's first-write road too, so the phone shows her a sentence
  naming a Mac door. The disclaimer's wording is already PROVISIONAL and in her 18l-c bundle
  ("the disclaimer polish"), so the natural owner is that item (or an explicit sweep exemption with a
  ruling) — NOT a hoist unit. Recorded, not fixed.

### U1 WALK SCRIPT (HELD — runnable the moment her app is quit in a window she grants)

**Preconditions (each re-checked, never assumed):** `pgrep -fl 'Variorum.app/Contents/MacOS'` shows no
`/Applications` instance; `Tools/WalkKit/guard.sh --author` exits 0; Ghostty's AX + Screen Recording
grants hold; the dev store's voice noted at start and RESTORED to Terminal at the end (row 91).
Build the dev app from THIS tree: `xcodebuild build -scheme Variorum -destination platform=macOS
-derivedDataPath App/Variorum/DerivedData/18m-u1` and launch ONLY that path (`open -n`), then every
act through `click.sh` / `keys.sh` (guard order: author checks → activate → full guard → act; acts
≥ 2 s apart — synthetic keys reset HID idle). Captures into `notes/plans/18m-screens/u1/<voice>/`.
Stage prose through the store/quick-entry, never by typing into the TK2 editor (the 13u3 UNIT B fact).

| # | Arm walked | Staging | Act | Must see |
|---|---|---|---|---|
| W1 | M2 — A7 carve | a note "Alpha" · (empty) · "Beta" | caret at the empty block's start, ⌫ | the empty block GONE; receipt *"Empty block deleted — ⌥⌘Z undoes it."*; Edit ▸ Undo Delete Block |
| W2 | M3 — #34 fanless | "Alpha" · "Beta" | caret at "Beta"'s start, ⌫ | ONE block "Alpha Beta"; receipt *"Blocks joined — ⌥⌘Z undoes it."* |
| W3 | M3 — #34 fanned | "Alpha"(2 takes) · "Beta" | the same ⌫ | nothing joined; the refusal names the fan and ⌘⇧M / ⌥⌘⇧M |
| W4 | M4 — J9 | three paragraphs | triple-click the middle one, ⌫ | the paragraph GONE to the tray; receipt `BlockSelectionCopy.deletedNote(1)`; ⌥⌘Z restores it |
| W5 | M5 — the clamp | three paragraphs | select the middle paragraph + its newline, type a word | the block's text replaced IN PLACE, the break stands; ⌘Z is TEXT undo (no ⌥⌘Z entry) |
| W6 | M6 — the compound | two paragraphs | select mid-first to mid-second, ⌫ | the remainders JOIN into one block; the receipt names the tray / Came from and ⌥⌘Z |
| W7 | nothing regressed | any block | ordinary typing mid-block | characters land; no refusal line |

Both voices (W1–W7 in Terminal, then Study — re-read every click point from a fresh capture after the
flip). Then the VisualWalk subset as regression cover:
`VARIORUM_VISUAL_WALK=1 Tools/VisualWalk/visual-walk.sh --build --voices terminal,study --only write-newline-roundtrip,write-divide-merge,b5-more-roads`
(its 17w hazards bind: never let a scenario type after a failed keyboard probe).

**The harness floor that stands in the meantime (NOT the gate):** every one of W1–W7's arms is driven
through the REAL keystroke path (`harness.replace` → `shouldChangeText` → the route → the executor →
the STORE) by an unmodified pin that ran green in the finals — W1 `SeamMergeTests
.anEmptyBlockAtTheSeamStillTakesTheCarveNotTheMerge` + `BlockDeletionAndRedoTests`' carve pins; W2
`SeamMergeTests.backspaceAtATextedSeamMERGESTheTwoBlocks` (the receipt asserted); W3
`.aFANNEDSeamREFUSESAndNamesTheDoorThatCanFoldIt` + `.aFanArrivingWhileSheIsTypingStillStopsTheMerge`;
W4 `WholeBlockDeleteTests.aWholeParagraphSelectionDeletesTheBlock` (the receipt asserted) +
`.theRouteIsOneUndoEntryAndItRoundTrips`; W5 `BoundaryClampTests
.typingOverAParagraphWithBothItsNewlinesReplacesItInPlace` + `.shapeOneIsOrdinaryTextUndo…`; W6
`CrossBlockCompoundTests.aSpanFromMidParagraphToMidParagraphJoinsTheRemainders` +
`.theReceiptNamesBothDestinationsAndStaysShortEnoughToRead`; the find fence
`FindAndReplaceTests.aPlannedMatchThatDriftsAcrossASeamRefusesInsteadOfMerging`; the phone's arms
`MobileCrossBlockEditTests` + `MobileWholeBlockDeleteTests` (full mobile suite).

### U1 SELF-ASSESSMENT (for the cold reviewer — Fable, per the cast)

**What I claim, and the evidence for each claim:**
1. *The ladder's decision moved address, not behavior, on both platforms.* Evidence: the route
   calls exactly the planners the ladders called, with the same inputs (`index`, `slots`, the same
   `viewText` surface read — the old `[weak self] … ?? ""` / `[model]` captures collapse to one
   non-escaping `viewText($0)`, equivalent inside a synchronous gate), in the same order, stopping at
   the same first claim; each mapping calls the same executor through the same chained schedule and
   speaks the same sentence (`CrossBlockRefusal.message(for:)` is the Mac forward over `macFanRoads`,
   byte-equal to the old `message(range:index:slots:)` composition; the phone passes
   `Self.fanFoldRoads` as before). The 3C proof: the finals added two NEW test files and edited none —
   Mac 223/20 + 171/20 + Tutorial 79/11 green, the full mobile suite 647/110 with only the 4 known +
   F-1 (pre-existing, attributed).
2. *The order is now testable purely, and the table bites.* `EditorEditRouteTableTests` (19) drives
   the REAL carve guards (c1), the permutation pins show a reordered list answers differently for
   the three overlapping pairs, and the J9-vs-clamp pin shows LAZINESS (0 surface reads when J9
   claims — an eager route would read once).
3. *Row 51's carves are buildable, not built.* The phone's list lacks them (pinned in both
   targets); their plans are shared; the precedence rules that would place them pass vacuously today
   and bite when they land (pinned).

**Where I would look hardest if I were reviewing this cold:**
- **The undeclared-arm cases** (Mac `.refuseAwaitingSync`; phone `.refuseFindReplace`,
  `.carveEmptyBlock`, `.mergeTextedSeam`): the ONLY new runtime lines that are not a 1:1 move. They
  are unreachable by construction (the route walks only declared arms — pinned by the property
  sweep) and answer as each platform answers today (assertion seam, then the platform's own
  diagnosis). If the reviewer prefers these to be a `preconditionFailure`, that would trap in
  Release — against the repo's refuse-don't-trap doctrine (M-A); I chose the seam deliberately.
- **`surfaceText` bound:** I state ≤ 2 reads per route, correcting the ruling's "≤ 3" (that figure was
  option (a)'s eager sum); the property pin asserts ≤ 2 over every small edit of four notes.
- **The moved doc comments:** A7's and #34's plan docs moved VERBATIM into `SeamCarvePlan` (only
  `model.slots` → `slots` and one "see `runEmptyBlockDeletion`" → "the Mac's `runEmptyBlockDeletion`");
  the ladders' order-arguing prose moved to `Arm`'s case docs, lightly re-worded where a sentence
  referred to "the two plans below"; the phone's R13 NO-CONFIRM ruling stayed at the phone's
  `.deleteWholeBlocks` mapping (the door keeps its own copy).
- **The precedence table's "clamp ≺ compound" and the fence-≺-all pairs** are TODAY'S order with the
  ruling that placed them named; only J9≺clamp, J9≺compound and fence≺carve are proven load-bearing
  by permutation — the others are exclusive by geometry today and are recorded as rulings, not as
  proven overlaps. The gap fence ≺ compound pair is a COPY ordering (O-2): permuting it changes no
  outcome (pinned: `theGapFenceChangesOnlyTheWords`).

**Not done / owed:** the walk (HELD — see the WALK SCRIPT); F-1 routed to the orchestrator (not
U1's); O-1 is U3's (ledger row 4). Zero `Sync/`, zero schema, zero layout code touched (TEXTKIT2
seams untouched: no attribute stamps, no `BlockRangeIndex` region change, no `runStructural` change).

### U1 — ORCHESTRATOR VERIFY PASS + ADJUDICATIONS (2026-09-29; verify-never-trust — the WALK stays HELD)

**Claims verified against git and disk:** all seven commits `7a92b742..1734857a` present and
pushed, tree clean, no trailers; the 3C proof re-run by diff (the two test targets gained
exactly the two NEW files, zero existing pin lines); zero `Sources/`, `Server/`, schema; the
production footprint is the four named files + the new shared route file; both gates' call
sites read as the one-route-call shape (`EditorEditRoute.route` + `performCrossBlockRoute`, no
second guards at either site); **F-1 verified end to end** — the offender string ("on the Mac,
choose Help ▸ Restore") is real at `SampleLibraryJekyllBook.swift:91`, born at 18l-c U6
(`2772a6f4`, last touched `603e5fdb`), untouched by U1, and the sweep pin
(`nothingUserFacingNamesTheMac`) is a disk-reading source walk, so its red is tree-independent
and PRE-EXISTING as claimed.

**Adjudications (repo-first, before the reviewer sees them):**
- **Condition 1's figure stands CORRECTED to the implementer's ≤ 2 reads** (my ruling's ≤ 3 was
  the eager option's arithmetic; the pin asserts the true bound — the measured number with a
  pin beats the ruling's figure, the standing hierarchy).
- **F-1 — ROUTED TO HER BUNDLE via QUESTIONS #155, not fixed in 18m.** The deep cause is a
  genuine COLLISION between #155's built (i) (the Jekyll restore door Mac-only; the disclaimer
  says "on the Mac") and MobileSoul §4.4's no-redirect sweep on a phone-seeded string: the
  shipped (i) choice cannot pass that pin. Fixing it is her #155 second-half call — (ii) the
  phone Settings restore row (one row of face code over the shared road, and the sentence
  stops naming a platform) or keep (i) and the sweep records a dated exception. A dated
  evidence line lands on #155 with this commit; the disclaimer's WORDING is already her
  R-18l-12 polish item. **Until she rules, the FULL-mobile baseline reads 647/110 = the 4
  known + F-1** (stated here so no later unit re-attributes it).
- **The WALK stays HELD, and the ladder proceeds in parallel** (the 18l-b U3 precedent): her
  real-store app is live, `guard.sh --author` refuses correctly, and quitting it is hers
  alone. U1's USE acceptance (the implementer's W1–W7 script + this seat's own hands-on walk +
  the VisualWalk subset) runs at the next window and GATES the unit's close either way — the
  ladder is a parallel gate, never a substitute.

Ledger row 1 stays open pending the ladder + the walk; row 6's U1 half (row 28's cascade
discharge, row 51's build seam) is landed and verified in the hoist's own commit. The FABLE
cold review over `3975b682..1734857a` follows; ladder file `notes/plans/18m-u1-ladder-round1.md`.
