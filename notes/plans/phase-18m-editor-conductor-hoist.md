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
| 1 | The routing cascade as ONE pure function in `Shared/EditorBrain/` — declared platform capability sets, order as data, a pure table suite pinning the ORDER per platform; both cascades one call; zero behavior change per platform (a differing route is a FINDING) | U1 | **CLOSED 2026-09-29** — built · ladder one round 0/0/0/1 zero disputes (NIT reviewer-fixed pin-first `276fc460`, sanity `d6a8eb7e`) · **WALKED at her window: 14/14 rows PASS both voices + the VisualWalk subset 6/6 PASS 0 FAIL** (the U1 WALK RUN section) |
| 2 | Crystallization + the storage primitives + the identity audit hoisted on 3C (thin injected accessor surface; deliberate platform deltas declared; zero test edits both platforms) | U2 | **CLOSED 2026-09-29 overnight** — (B) built (TailCrystallizer + host, EditorSurfaceStorage, one mint body, the audit consumer; 3 behavior-preserving commits, zero test edits) + riders F-2/F-3 pin-first with this seat's reverts red-in-shape; 12/12 typing walk both voices; ladder ONE round 0/0/0/3 zero disputes (`b312ebb9` reviewer fixes, `60a0f47a` sanity); records `notes/plans/18m-u2-ladder-round1.md` |
| 3 | MAY-take: KnownIssues row 74 — the phone's autosave-registry release (the Mac's 18k C1 fix is the model); decide at U2, record either way with its own red-on-old pin if taken | U2 | **NOT TAKEN 2026-09-29** (the U2 record's reasons; accepted at the ruling) — the row stays the mobile project's |
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
- **HER WINDOW GRANT (2026-09-29, mid-U2-checkpoint, verbatim):** *"i have quit my real store so
  you can do everything"* — zero instances verified by pgrep the same minute. Read as: GUI
  driving and the held walks are FREE (the per-step guard still binds every act — she may
  return at any moment), and the phase-close install refresh has its window when the ritual
  reaches it (instances re-verified at execution time as always). The held U1 walks run NOW,
  before U2's ruling lands.
- **HER SECOND WORD, minutes later (verbatim):** *"you can go ahead and control my computer
  freely i'm stepping away for the evening"* — the away-run rule governs the night
  (PROVISIONAL-and-continue; author-only calls HELD and BUNDLED); GUI driving free with the
  per-step guard still run as machinery hygiene; anything genuinely hers goes to the bundle
  for her morning.
- **HER OVERNIGHT AUTHORIZATION (later the same night, after the U1 walk and one brief return
  to the machine that the guard caught correctly, verbatim):** *"ok continue, machine is now
  not being disturbed again"* and then *"continue overnight and bundle anything for my
  morning. gone for now"* — the phase runs to its close overnight under the away-run rule;
  the closeout ritual (the install refresh included, behind the A1 rail at a re-verified
  zero-instance window) is authorized; HER MORNING BUNDLE accumulates in this file and lands
  at the top of the author handoff.

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
| U1 (session 1) | **LADDER CLOSED 2026-09-29** — one round 0/0/0/1, zero disputes (NIT agreed → reviewer fix `276fc460` pin-first → sanity `d6a8eb7e`); the WALK is HELD at the guard and folded into the next drive window (the skill's else-record-and-fold provision; the SEQUENCING NOTE below) |
| U2 (session 2) | **CLOSED 2026-09-29 overnight** — built · verified (reverts red-in-shape) · walked 12/12 · ladder one round 0/0/0/3 zero disputes · sanity `60a0f47a` |
| U3 | brief below (one-ahead); spawns at U2's ladder close |
| U4? | the sizing call at U3's close, recorded either way |
| The HELD WALKS (U1's W1–W7 + VisualWalk subset; the orchestrator's own U1 acceptance walk; U2's typing walk when it reaches that step) | HELD at the guard — run at the first author-granted / app-quit window; each unit's close is PROVISIONAL until its walk passes, and a walk finding re-opens its unit as a fix pass |
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
| SANITY PASS — the reviewer's round-1 fix `276fc460` | DONE (the implementer, 2026-09-29): the diff is exactly what the disposition says and nothing more — `EditorEditRoute.precedence`'s generated fence-first rows filter out `.gapFence` (with the why at the comment), and `bothListsHonourEveryRuledPrecedence` gains the no-fence-vs-gapFence-row expectation; no other `App/` line moved, and no other pin reads that pair. `EditorEditRouteTableTests` re-ran **19/19 green** on `276fc460`. Record note: my self-assessment's phrase "the fence-≺-all pairs" now reads as "fence ≺ every PLANNER arm" — the fix corrects my own overclaim, exactly as agreed. Nothing raised back to the reviewer. |

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

### SEQUENCING NOTE (orchestrator, 2026-09-29 — PROVISIONAL, recorded rather than silent)

U2 opens while U1's walk is HELD. The warrant: the skill's own batch loop provides for it
("screenshot-verify where the environment allows — ELSE RECORD AND FOLD INTO THE NEXT DRIVE"),
the guard's refusal is environmental (her live real-store app), U1's non-walk evidence is
unusually strong for a zero-behavior-change unit (zero pins edited on both platforms, the
order-pinning table suite, a clean one-round ladder), and idling the phase on a window only she
can grant spends the run's autonomy on a low-risk wait. The cost, stated: U2 edits the same two
view-model files, so a U1 walk finding would land its fix pass on top of U2's changes — accepted
(the routed surface is now small and pinned). Every held walk runs at the FIRST window and each
unit's close stays PROVISIONAL until its walk passes.

## U2 BRIEF (session 2 — crystallization, the storage primitives, the identity audit, hoisted on 3C; written by the orchestrator 2026-09-29)

You are the `opus-implementer` for **18m UNIT U2**, the phase-sized unit: the duplicated
CONDUCTOR bands — crystallization, the storage primitives, the identity-audit consumer — move
to `Shared/EditorBrain/` on the 3C pattern, with the platform accessor differences becoming a
THIN injected surface and every deliberate platform delta staying DECLARED, never averaged
away. **The charter's U2 bullet is your unit charter** (`notes/plans/post-13u-health-rounds.md`
KICKOFF 3). Zero test edits on both platforms is the proof; the full mobile suite is part of
your finals.

**Read first, in this order (reading is never delegated):**
(1) THIS file whole — the fences, BINDING PRINCIPLES (P-9's value-seam rule binds your surface
design), CAST & DISCIPLINE, BASELINES (the mobile baseline is 647/110 = the 4 known + F-1,
attributed — never re-attribute it), THE CONDUCTOR MAP (the bands with the deltas I verified),
THE LEDGER rows 2–3 and 6, ENVIRONMENT TRAPS (verbatim binding), the SEQUENCING NOTE (your
walk step may be HELD at the guard — if so, record the ready-to-run script and fold it, U1's
precedent), and the **U1 RECORD whole + `notes/plans/18m-u1-ladder-round1.md`** (the freshest
seam facts; your diff builds ON U1's routed gates — `performCrossBlockRoute` and
`EditorEditRoute` are settled ground, untouched by you).
(2) The charter's KICKOFF 3 + the health review §3 (the ~89%/modulo-accessor claims) and §2.1.
(3) `notes/KnownIssuesAndTechDebt.md` rows 28 (your commit updates its enumeration — the
conductor band's (a) completes with your hoist), 74 (your MAY-take, below), 30 (the phone's
gate-less M12 class — context for `restampProjection`'s reason-to-exist).
(4) `notes/MobileSoul.md` §3 · `notes/TEXTKIT2_NOTES.md` IN FULL (mandatory — §3's macOS-26/27
attribute-fixing and widening facts are WHY several of these bands are shaped as they are:
the clamp-to-the-verdict rule, the phone's re-stamp) · `notes/SessionResiliencyProtocol.md`.
(5) The code, END TO END before touching it, BOTH platforms side by side:
`EditorViewModel.swift` :900–:1040 (the storage seam: `setSurfaceContent` · `applySeamEdit` ·
`adoptRewrite` · `holdTailIdleClock` · `awaitMintSettle` · `applyPendingIfClean`), :1445–:1490
(the audit consumer + `desyncRecovery`), :1491–:1779 (crystallization incl. `finishMint` and
the Mac-only `runSoftNewlineInTail`); `MobileEditorViewModel.swift` :566–:780 (projection →
surface, `applyDifferential`, the pending-text contract), :1666–:1683 (`desyncRecovery`),
:1684–:1899 (crystallization), :1899–:2037 (the storage primitives + the audit consumer);
`EditorSurfaceController` where the Mac's differential/renderFull roads consume the seam
(`applyStructuralResult`, `applyDifferentialStructural`, `renderFull` — U-B5's keeper and the
anchor capture live here and are PINNED: `WriteFloatingViewportTests`,
`UntouchedLineKeeperTests` ride unmodified); `Shared/EditorBrain/` whole (the planners and
reconciler you conduct: `CrystallizationPlanner`, `EditorProjectionEngine`,
`IdentityProjectionAudit`, `EditorDocumentCore`, `EditorEditRouting`'s `ArmedEdit`/
`EditorAssertionSeam`); the pin families that ride these bands — Mac: the crystallization/
tail/mint suites (grep `crystallize|idleMint|attachLeadingTail|finishMint|awaitMintSettle`
over `VariorumTests/` and read every suite you find), `WriteTopAirTests`, the seam/structural
suites; phone: `MobileSpaceEaterTests`, the crystallization/first-write suites, the
`desyncRecoveryCount` oracles (row 30's pins).
(6) The 18k C1 record (`notes/plans/phase-18k-runtime-hygiene.md`, UNIT C1) if you take row 74
— the Mac's release-at-end-of-life fix is the model and its pin form (the registry count
across an open→close cycle) is the required red-on-old shape.

**The unit, in order:**
1. **MAP the bands byte-honestly:** a per-function table — Mac body vs phone body — classing
   every difference as (i) ACCESSOR (the injected surface's material: `textView?.textStorage`
   vs `storage`, `hasMarkedText()` vs `markedTextRange`, `showOperationError` vs
   `statusMessage =`, `MarkdownStyling.restyle` vs `MarkdownFace.restyle`,
   `EditorDocument.baseAttributes` vs `MobileEditorStyle.baseAttributes`), (ii) DECLARED
   platform delta with its recorded reason (the Mac's `structuralInFlight` guards; the ⇧⏎
   soft-newline arm; the phone's `restampProjection` and its widened-report reason; the
   phone's liveness concept), or (iii) UNEXPLAINED — a FINDING routed to the orchestrator
   (mechanism + what each behavior would mean), built to TODAY's behavior per platform either
   way. **The phone's missing `structuralInFlight` guards in `idleMintTail`/
   `attachLeadingTailRunIfNeeded` are the first candidate for (iii)** — trace whether the
   phone HAS an equivalent in-flight hazard on its structural road and answer it with
   evidence, not a guess.
2. **PROPOSE THE INJECTED SURFACE BEFORE BUILDING (the architect rules this fork — U1's 4E
   precedent):** the design space includes a small host protocol the two view models conform
   to; free functions over a value facts-struct + effect closures; or a generic conductor type
   the models embed. P-9's rule binds: a VALUE seam (state in, state out) is preferred, and
   NOTHING may introduce a new `model:`-style mutual back-reference. Name what the surface
   must expose (storage access, the index/ledger/autosave doors, the tail state, the session
   runner, the error voice), what stays a platform arm, the forwarding plan (pre-move names as
   forwards/typealiases so every pin rides), and the hoist's file layout. Commit the proposal
   into your record and STOP for the orchestrator's ruling.
3. **BUILD per the ruling**, function by function, commit per coherent piece; the 3C bar
   throughout (zero test edits both platforms — a pin needing edits is STOP-and-re-trace).
   Row 28's enumeration (the conductor band's (a) completed) updates in the same commit.
4. **MAY-take, decided and recorded either way: row 74** — the phone's autosave-registry
   release. Take it iff your diff already stands on the phone's editor-model teardown road;
   a take needs its own red-on-old pin (the registry count, C1's form) and the 18k C1
   semantics (release at the owner's exactly-once end of life; drop only through a landed
   leaving savepoint; the phone's background flush walks the map — verify the cost shape).
   Not taken ⇒ one line saying why, and the row stays the mobile project's.
5. **WALK (USE) + finals:** the typing walk (both voices — type paragraphs past boundaries,
   the idle mint, a bulk paste, ⇧⏎ in the tail on the Mac, the k−1 blank-line shapes) — if
   the guard refuses (her live app), record the ready-to-run script and FOLD it (the
   SEQUENCING NOTE; the harness/simulator evidence carries the interim). Finals: the touched
   Mac suites + the crystallization/seam/structural families + the eleven Tutorial suites,
   **the FULL mobile suite** (expect 647/110-class counts = the 4 known + F-1; anything else
   is attributed before it is accepted), and the generic-iOS build.

**Discipline:** the resiliency protocol binds from your first commit — `## U2 RECORD` in THIS
file, LIVE STATUS per piece, PENDING marks, commit+push per piece, NO trailers, pathspec
staging, synchronous foreground waits only, NEVER spawn subagents, commit before any
behavioral revert. PROVISIONAL-and-continue (QUESTIONS next free #159 — check it fresh);
STOP-and-report for gating ambiguity, any behavior change, anything wanting `Sync/`, every
author-only call. Your diff is the editor seam by definition → a **FABLE cold review**
follows; your self-assessment closes your record.

## U2 RECORD (the `opus-implementer`, session 2 — opened 2026-09-29)

**NOT DONE (first line, per the contract): (1) no PHONE GUI walk — there is no phone walk kit; the phone's half of the band is evidenced by the harness (the full mobile suite on the simulator and the band's phone families); (2) the full MAC suite — the brief names the touched suites, the crystallization/seam/structural families and the eleven Tutorial suites, which ran green; (3) the riders' red-on-old is verified by RUN ORDER on the exact pre-fix trees (each PIN commit ran red before its FIX commit — U1 round 1's accepted form), not by a second post-fix revert.** Everything else the brief and the ruling ask for is DONE, committed and pushed: the hoist (three behaviour-preserving commits), rider F-2 (pin → fix), rider F-3 (pin → fix, not hollow), row 74 NOT TAKEN, the walk 12/12 both voices, the finals green. No revert is in flight; the tree is clean; zero instances running.

### LIVE STATUS

| Piece | Status |
|---|---|
| Preflight reads — this file whole (fences, P-1…P-9, cast, baselines, the conductor map, ledger rows 2/3/6, traps, the SEQUENCING NOTE, the U1 RECORD whole) + `18m-u1-ladder-round1.md`; the charter's KICKOFF 3; health review §2.1/§3/§6.1/§8; KnownIssues rows 28/30/51/70/74; MobileSoul §3–§5; TEXTKIT2_NOTES whole; SessionResiliencyProtocol whole; 18k's UNIT C1 RECORD + adjudication (row 74's model); 17b P36 (the review doc + the standing-fixes entry); 13g's L7 wiring list; all 13 `Shared/EditorBrain/` files; both conductors' bands end to end (Mac `EditorViewModel` :380–:1760 + :4112–:4190, `EditorSurfaceController` :1–:200 + :2870–:3160; phone `MobileEditorViewModel` whole; `MobileStructural` :1–:210); the pin families (Mac `CrystallizationTests`, `SpaceEaterTests`, `EditorTestSupport`, `StructuralGestureTests`' review-round suites; phone `MobileSpaceEaterTests`, `MobileTrailingNewlinesTests`, `MobileEditorTestSupport`; the conductor-name grep over both test trees) | DONE (read in this session, never delegated) |
| Step 1 — the band map (every difference classed ACCESSOR / DECLARED / FINDING) | DONE (this commit) — below; three FINDINGS + one observation routed |
| The (iii) first candidate — the phone's missing `structuralInFlight` guards — answered with EVIDENCE | DONE (this commit) — scratch probes run on both platforms, never committed (sources + outputs in `notes/plans/18m-screens/u2/probes/`, gitignored) |
| Step 2 — the injected-surface proposal | DONE (`3e91e7ec`) — **RULED (B)** + three conditions (the RULING section below) |
| Step 3a — the storage doors: `Shared/EditorBrain/EditorSurfaceStorage.swift` (`text` · `setBlockID` · `replace`); both view models' `viewText` / `setBlockAttribute` / `programmaticReplace` through them (names, counter, suppress, guard, caret unchanged; the Mac passes `restyle: nil` — F-3 as data) | DONE (`65941ee9`) — Mac `build-for-testing` + generic-iOS build green; behaviour claims PENDING the finals |
| Step 3b — the audit consumer: `IdentityProjectionAudit.audit(index:storage:countingFailure:file:line:)` (DEBUG-only, count-then-fire — today's order — the call site's location threaded to the seam); both `auditIdentityProjection()`s one call inside their own `#if DEBUG`, counters unchanged | DONE (`e22c0ed0`) — Mac `build-for-testing` + generic-iOS build green; behaviour claims PENDING the finals |
| Step 3c — the `TailCrystallizer` (owns the tail text, the mint flight, the idle clock) + `TailCrystallizerHost` (23 members, each documented with the band function that needs it; ACCESSOR and DECLARED rows marked) + both conformances IN each view model's own file (no setter widened) + the pre-move forwards (`tailText`, `mintInFlight`, `tailIdleDebounce`/`tailIdleSleep`, `armTailIdleMint`, `mintableTail`, `idleMintTail`, `awaitMintSettle`, the private `crystallizeIfNeeded`/`finishMint`) + the ONE mint body (`TailCrystallizer.mintBlocks` — the Mac's `finalizeWork` consumes it too) + the phone's now-dead private `setBlockAttribute` removed; row 28's enumeration updated in the same commit | DONE (`d34e4f02`) — Mac `build-for-testing`, generic-iOS build AND the mobile test target's `build-for-testing` green, zero warnings from any touched file; behaviour claims PENDING the finals |
| Pre-rider check of the hoist (the band's own pin families, suite-level, against the 3c build) | DONE — Mac **313 tests / 41 suites green, 0 skipped**; phone **257 / 38 with exactly 1 issue = F-1** (the attributed pre-existing sweep red) — the hoist holds before any rider lands |
| Rider F-2 — the phone's P36 twin | DONE — PIN `067657d2` (RED on the pre-fix behaviour: `theMarkerSurvivesAReadThatThrows` at its final expectation, 2 tests / 1 issue) → FIX this commit: the marker held across the re-read and restored on a thrown read (the Mac's P36 lines, twinned) → **GREEN** (`MobileDeferredProjectionRetryTests` 2/2 with the phone's projection/takes neighbours: 43 tests / 4 suites). Row 28 gains the `applyPendingIfClean` convergence as a NEXT-TOUCH candidate (the ruling's instruction; not taken) — FIX commit `9ba53fa0` |
| Rider F-3 — the Mac restyle (pin-first on the real roads; record-only if hollow) | DONE — PIN `8ffaaa18` (RED on the pre-fix behaviour on all three user-reachable roads, exactly at the face assertion — 3 tests / 3 issues; premises and road-taken expectations held) → FIX this commit: the Mac's `programmaticReplace` passes `restyle: MarkdownStyling.restyle` (the span-bounded, attributes-only restyle `applySeamEdit` already runs — no new mechanism), inside the same storage transaction → **GREEN** (`ProgrammaticReplaceFaceTests` 3/3 with `SpaceEaterTests`, `EditorSessionTests`, `DifferentialApplyTests`, `StructuralRewriteDoorTests`, `MarkdownFaceTests` (incl. its P1 scan budget), `ReviewRound1FixTests`, `CrystallizationPlannerTests`: 76 tests / 8 suites). The shared door's header re-worded to the new truth |
| Step 4 — row 74's MAY-take | **NOT TAKEN** (the ruling accepted the record's reasons: the hoist touches the phone's teardown road only by ADDRESS — `finish()`'s idle-clock cancel now names the crystallizer — and a take is a lifecycle behaviour change needing C1's own T1–T5 trace for the phone; the row stays the mobile project's) |
| Step 5a — the typing WALK (dev-store Debug build from `4117689b`, both voices) | **DONE — 12/12 rows PASS** (W1–W6 × Terminal/Study; the section U2 WALK below). Captures `notes/plans/18m-screens/u2/{terminal,study}/` (gitignored). The dev store's voice ENDED Terminal (read-back + capture); the walk instance quit by identity (zero instances after) |
| Step 5b — finals | **DONE** (tree `95e22720`; code last changed at `4117689b`; her machine granted, nobody at it; the dev store's voice Terminal): **Mac run A — the band's families + the three new pin suites + the face suites: `✔ 349 tests in 44 suites passed`, 0 skipped** · **Mac run B — U1's routing/seam/compound families, 18l's keeper pins, the seam-cost pins, `BoundaryFluidityTests`, `BlockDeletionAndRedoTests` and the ELEVEN Tutorial suites: `✔ 241 tests in 25 suites passed`, 0 skipped** · **the FULL mobile suite (iPhone 17 Pro simulator): `649 tests in 111 suites`, 5 issues = EXACTLY the attributed baseline — the 4 known (`MobileTrashTests` ×2, `MobileTutorialWalkTests.theFannedDivideLessonLandsTheDuplicateShape` ×2) + F-1 (`nothingUserFacingNamesTheMac`, U1's attributed pre-existing sweep red); 0 skipped** (the baseline 647/110 + the F-2 suite's 2 tests) · **generic-iOS build `** BUILD SUCCEEDED **`**. **The 3C proof by diff:** the three hoist commits (`65941ee9`, `e22c0ed0`, `d34e4f02`) touch ZERO test files; over `25ce55df..HEAD` the test targets only GAINED the two rider pin files (`ProgrammaticReplaceFaceTests.swift`, `MobileDeferredProjectionRetryTests.swift`); zero `Sources/`, `Server/`, `Sync/`. Row 28's count flipped from PENDING |
| SANITY PASS — the reviewer's round-1 fix `b312ebb9` | DONE (the implementer, 2026-09-29): the diff is exactly the three dispositions and nothing more — NIT 1: `TailCrystallizer.swift`'s charter comment reworded to the true rule (no AppKit/UIKit; Foundation, VariorumCore and UI-free `Shared/` types); NIT 2: the one doubled blank line above the ⇧⏎ arm's doc removed in `EditorViewModel.swift`; NIT 3: closed as recorded, with the optional clause on `EditorSurfaceStorage.replace`'s doc (an out-of-range range raises; both callers guard and heal through `desyncRecovery`). Checked mechanically: ZERO non-comment, non-blank lines changed under `App/`; the only other file is the round's own record (`notes/plans/18m-u2-ladder-round1.md`). Nothing raised back to the reviewer |

### STEP 1 — THE BAND MAP (today's tree, `25ce55df`; Mac body vs phone body, function by function)

Method: each band was extracted from both files and `diff -u`'d mechanically (the diffs are in this
session's scratchpad; every line below is a CODE difference — comment-only differences are not listed).
**Classes:** **IDENTICAL** (byte-identical modulo comments) · **ACCESSOR** (the same act through a
different platform accessor — the injected surface's material) · **DECLARED** (a deliberate platform
delta with its reason) · **FINDING** (unexplained — routed below, built to TODAY's behavior either way).

**A. Crystallization** (Mac `EditorViewModel` :1468–:1754 · phone `MobileEditorViewModel` :1650–:1863)

| Function | Code differences, Mac vs phone | Class |
|---|---|---|
| `armTailIdleMint` (M :1475 · P :1653) | Mac guards `hasOpenTail, !tailText.allSatisfy(\.isWhitespace)`; phone guards `mintableTail` — the same predicate (`mintableTail` IS that expression on both) | IDENTICAL (spelling) |
| `mintableTail` (M :1489 · P :1665) | none | IDENTICAL |
| `runSoftNewlineInTail` (M :1527) | Mac-only | **DECLARED** — the ⇧⏎ tail arm (13d batch 4, A15 option B + rider 1; the phone has no soft newline) |
| `idleMintTail` (M :1544 · P :1673) | (1) guard spelling as above; (2) **Mac-only** `if structuralInFlight { armTailIdleMint(); return }` (:1552); (3) marked text: `textView?.hasMarkedText() == true` vs `textView?.markedTextRange != nil` | (1) IDENTICAL · (2) **DECLARED — see "the (iii) candidate" below** · (3) ACCESSOR |
| `attachLeadingTailRunIfNeeded` (M :1581 · P :1694) | **Mac-only** `!structuralInFlight` in the first guard; the rest byte-identical (its `setBlockAttribute` is the storage accessor) | **DECLARED — see below** (and F-4) |
| `crystallizeIfNeeded` (M :1603 · P :1716) | error voice in the mint Task's catch: `self.showOperationError(error)` vs `self.statusMessage = String(describing: error)` | ACCESSOR (error voice) |
| the mint body inside it (`plan.mints.map { ops.newBlock(…, registeringUndo: false) }`) | byte-identical — and a THIRD copy lives in the Mac's `finalizeWork` (:744), R-13u-3's exception comment and all | IDENTICAL ×3 |
| `finishMint` (M :1656 · P :1767) | (1) error voice in the quiet-deletions Task (as above); (2) **Mac-only** `updateCaretContext()` after the audit (:1747) | (1) ACCESSOR · (2) **DECLARED** — the Mac maintains an OBSERVED caret context (`caretBlockID`, ordinal, word counts, gesture availability — the status bar and the menus read it) that must republish when the caret's text leaves the tail for a block; the phone keeps no VM-held caret projection (its chrome reads on demand, and a fresh mint carries no fan/comment chrome) |
| `awaitMintSettle` (M :978 · P :479) | none | IDENTICAL |

**B. The storage primitives** (Mac :900–:1040 + :4131–:4190 · phone :1865–:1979, plus :566–:728)

| Function | Code differences | Class |
|---|---|---|
| `viewText` (M :4133 · P :1868) | (1) Mac `surfaceTextReads += 1`; (2) `textView?.textStorage` vs `storage` | (1) **DECLARED** — the Mac's echo pin counts extractions (`EditorSessionTests` :369); the phone's echo pin counts `fullRenderCount` instead · (2) ACCESSOR |
| `syncTailText` (M :4140 · P :1874) | Mac inline `guard let range = index.tailRange … viewText(range)`; phone `tailText = openTailText`, the same expression factored for the copy door (`copyNote`) | IDENTICAL (factoring) |
| `programmaticReplace` (M :4150 · P :1879) | (1) `guard let textView, let storage = textView.textStorage` vs `guard let storage` (the phone attaches headless storage under test); (2) caret read `textView.selectedRange()` vs `textView?.selectedRange`; caret write `setSelectedRange` vs `selectedRange =`; (3) base `EditorDocument.baseAttributes` vs `MobileEditorStyle.baseAttributes`; (4) **the phone re-derives the markdown face over the replaced span (`MarkdownFace.restyle`); the Mac does NOT** | (1)–(3) ACCESSOR · (4) **FINDING F-3** |
| `setBlockAttribute` (M :4182 · P :1914) | storage accessor only | ACCESSOR |
| `restampProjection` (P :1946) | phone-only | **DECLARED** — iOS strips custom attributes on every insertion path (MobileSoul §5.2), so identity is RE-STAMPED from the index over the report; its Mac twin is `stampProjection` + `tailProjectionRegion` (M :1357/:1365, the consume road), which only CLAMPS to the verdict's region because macOS inherits the attribute — two implementations of TEXTKIT2 §3's one rule (*clamp stamps to the verdict, never the report*), each shaped by its platform's measured truth |
| `setSurfaceContent` · `applySeamEdit` · `adoptRewrite` · `holdTailIdleClock` (M :904/:914/:950/:971) | Mac-only | **DECLARED** — the N10 controller's storage seam (`EditorSurfaceController` reaches the storage ONLY through them); the phone has no controller, so its executors (`renderFull` :616, `applyDifferential` :671, `displaySlot` :1160) do the same writes inline |
| `applyDifferential` (Mac: the controller's :124 · P :671) | the replace loop + the index rebuild + the ledger adopt are the same modulo receiver; the post-steps differ: Mac adopts through `adoptRewrite` (which audits BEFORE the undo clear and publishes the post word count) then `updateCaretContext` + `refreshBadges`; phone audits AFTER the undo clear, then the canary checkpoint + `refreshChrome` | ACCESSOR (receiver) + **DECLARED** post-steps (Mac word count/caret context/badges; phone canary/chrome); the audit's position relative to the undo clear is unobservable (the clear touches no storage) |
| `applyPendingIfClean` (M :992 · P :705) | (1) Mac guards `!structuralInFlight` (twice) — the phone does not; (2) the re-read: `Queries.renderPost` → `applyProjection` vs `Queries.takesProjection` → `ingest`; (3) **the Mac restores the deferred marker when the re-read throws (17b P36) and exposes `hasDeferredProjection`; the phone's failure arm returns bare (`else { return }`) and drops the marker** | (1) **DECLARED** — the Mac's structural flight rewrites the surface itself and so defers deliveries for its duration (Phase 9 round 3 NIT, pinned `externalDeliveriesDeferDuringAStructuralFlight`); the phone's flight settles THROUGH the projection policy (`refreshTakesFromStore` → `ingest`), so there is nothing to defer (the mobile plan's S3 ladder records this corner as deliberate) · (2) **DECLARED** — each platform's ONE projection door (the phone's `ingest` adopts fans, presentations and the peek overlay from one coherent read) · (3) **FINDING F-2** |

**C. The identity audit** (Mac :1442–:1466 · phone :1996–:2003 + :1632–:1648)

| Function | Code differences | Class |
|---|---|---|
| `auditIdentityProjection` (M :1442 · P :1996) | storage accessor only | ACCESSOR |
| `desyncRecovery` (M :1451 · P :1632) | (1) phone-only `MobileEditTrace.desyncRecovery()` first; (2) the assertion text `"editor surface desynced…"` vs `"mobile editor surface desynced…"`; (3) the heal: `renderPost` → `applyProjection` vs `takesProjection` → `ingest` | (1) **DECLARED** — the phone's settling-experiment instrument (E1) · (2) **DECLARED** — the crash log names the platform · (3) **DECLARED** — each platform's one projection door (as B's `applyPendingIfClean` (2)) |

**Not in these bands (named so a reader does not look for them here):** the phone's liveness concept (`isLive`, `standDown`) lives at the gate — U1's pre-arm, untouched; the teardown backstops (Mac `finalizeWork` :647, phone `finish` :464) CONSUME the band (O-4 below) and are not themselves in it.

### The (iii) first candidate — the phone's missing `structuralInFlight` guards — ANSWERED WITH EVIDENCE

**The Mac's recorded reason** (`idleMintTail` :1546, pinned `ReviewRound1FixTests.anIdleMintIsNeverBornMidStructuralFlight`):
*"a mint born now races the gesture's fetch/rewrite — the mint's row failing the seam shape guard would
materialize the minted block AND the unconsumed tail (visible duplication), and the late finishMint would
crystallize a duplicate index entry."* That hazard exists because the Mac's `runStructural`
(controller :2896) rewrites the surface ITSELF after its op — `applyStructuralResult` → a seam edit or
`renderFull(preserveTail: true)` — bypassing the projection policy; hence the flight also holds the idle
clock (:2907), awaits the mint (:2941) and fences keystrokes (:2908/:2913).

**The phone's road is different by construction:** its structural doors (`MobileStructural.divide` :82 and
siblings) never write the surface — they settle through `refreshTakesFromStore` (VM :1136) → `ingest` →
`applyProjection`, whose shared policy is `busy: autosave.isDirty || mintInFlight` (VM :578). So a render
arriving while a mint is in flight DEFERS, and `finishMint`'s trailing `applyPendingIfClean` re-reads
fresh after the mint has crystallized — the ordering the Mac's guard enforces by hand.

**Probe P-a (scratch, phone, never committed):** the Mac pin's own staging on the phone — two blocks, an
open tail with text, `structural.divide(atSurfaceCaret: 19)` started, `k` yields, then `idleMintTail()`
fired — across `k = 0…13`: the flight was provably in flight at the fire for k = 1…13, a mint WAS born
every time (the phone has no guard), and **every run converged: unique block IDs, surface == store,
`desyncRecoveryCount == 0`, `identityAuditFailures == 0`, the divide landed and the tail minted** (output:
`18m-screens/u2/probes/phone-probe-output.txt`, `PROBE-PA`).

**Verdict:** the two absent guards are **DECLARED, by architecture** — the phone's flight settles through
the policy that already sequences render-after-mint. The reason was never written down; it is now, and
the hoist will carry it as a declared host fact (Mac `structuralInFlight`, phone `false`), never an
averaged guard. **But the attach guard has a second job the probe exposed on the phone** — see F-4.

### FINDINGS (routed to the orchestrator; none is U2's to fix — the hoist builds TODAY's behavior)

- **F-2 — the phone never got 17b P36.** Phone `applyPendingIfClean` (:705) nils `pendingProjection`,
  spawns its re-read, and its failure arm is `guard let fresh = try? … else { return }` — the deferred
  marker is DROPPED when the read throws, while its two sibling guards put a value back; the Mac's twin
  was fixed at 17b P36 (`b2203e71`, pinned `DeferredProjectionRetryTests`) and the phone was outside that
  entry's scope (`ProactiveTechDebtReview-2026-08-30.md` P36 names only `EditorViewModel.swift`). Same
  trigger as P36 (a lock closing the keyed store mid-settle), same consequence (an external change — a
  sync-arrived conflict take, a chosen-take flip from another surface — waits for a FURTHER store write
  before it reaches the surface), same NIT severity; traced by reading (the asymmetry is unambiguous);
  not probed (staging needs P36's re-lock rig). Owner candidate: the mobile catch-up, or a 17-entry
  beside P36 — the pin is `DeferredProjectionRetryTests`' phone twin. **Consequence for U2:**
  `applyPendingIfClean` cannot be hoisted as one body without either fixing the phone (a behavior change)
  or encoding the drift as a flag; so it stays per-platform in U2 (the proposal below).
- **F-3 — the Mac's programmatic surface writes drop the markdown face; the phone's keep it.** Mac
  `programmaticReplace` (:4150) resets the replaced span to `baseAttributes` and never re-derives the
  face — 13g's L7 wiring list names `applySeamEdit`, `storageDidEdit`, `materialize` and the read tier,
  not this door — while the phone's twin restyles (mobile batch 2, citing "the Mac `applySeamEdit`'s exact
  posture"). Two Mac roads reach it: `finishMint`'s tail normalization (whenever the minted text is not
  byte-identical to the tail — a trimmed trailing space, an excised blank line) and the controller's
  `applyDifferential` (a take flip from another surface, `restoreCommit`, a sync landing). **Probed
  (scratch, both platforms):** type `# Title ` ⏎ `B` — the Mac's heading face is present before the mint
  and GONE after it (`PROBE-MAC-FACE facedBefore=true facedAfter=false`); a differential replace of a
  slot with `# Heading now` lands unfaced (`PROBE-MAC-DIFF facedAfter=false`); the phone's same typing
  keeps its face (`PROBE-PHONE-FACE facedAfter=true`). The face returns only when that line is next
  edited or the note re-renders. Owner candidate: a 17-entry (a Mac-side one-line fix at the door, with
  the probe as its red-on-old pin). **Consequence for U2:** the hoisted storage door takes the restyle as
  an injected parameter — the phone passes its face, the Mac passes `nil` (TODAY's behavior), so the gap
  becomes VISIBLE at the Mac's call site and the fix is that one argument.
- **F-4 — the phone's structural flight has no keystroke fence, and a keystroke into the block being
  divided DUPLICATES text in the store.** The Mac's `runStructural` makes the view non-editable and defers
  typed keys for the flight (:2908/:2913) for exactly this reason (its own comment: *"a stale whole-buffer
  autosave after a divide would resurrect the moved half — the forbidden text-duplication class"*). The
  phone's doors flush, then `await` a fan read and the op with the surface still live: a keystroke landing
  in that window autosaves the block's WHOLE pre-divide text (+ the keystroke) into the variant the op just
  cut in place, and the settle's `flushNow` writes it back over the first half. **Probe P-b (scratch,
  phone):** `divide(atSurfaceCaret: 19)` on "First sentence. Second one.", one `X` typed into that block
  after k yields — for EVERY k ≥ 1 (flight in flight) the store read `["FirstX sentence. Second one.",
  "Second one.", "Anchor."]` (`DUPLICATED=true`), surface == store, no desync, no refusal; k = 0 (before
  the flight) is clean. On a device the window is milliseconds and the plausible sources are a fast
  keystroke after the ⋯ tap or a system edit (autocorrect/dictation commit — KnownIssues row 30's
  gate-less class); not measured on device. The attach guard's second job is this class for the TAIL
  (a tail attach mid-flight records the last block's pre-divide text). Not found recorded (grep over
  `notes/`). Owner candidate: the mobile catch-up (the phone's structural doors) or a 17-entry; the probe
  is the red-on-old pin's shape. **Consequence for U2:** none to the hoist — the phone's crystallizer gets
  no flight hold (TODAY's behavior); the fence, if ruled, belongs to the phone's flight, not to the band.
- **O-4 (observation, not a finding) — the two teardown backstops consume the band differently.** Mac
  `finalizeWork` mints the residual tail INLINE with the durability kind (no marked-text skip); phone
  `finish()` calls `idleMintTail()` — whose marked-text skip applies — so a composition open at the
  moment `finish()` runs leaves the tail to the re-armed clock of a model that is going away. Whether UIKit
  commits marked text before `teardown` reaches `finish()` is unverified; noted for the mobile catch-up,
  untouched here (both roads keep their shapes).

### STEP 2 — THE INJECTED-SURFACE PROPOSAL (the architect rules this fork; NOTHING BUILT)

**What the map says the surface must carry.** The platform DIFFERENCES are few — five accessors (the
storage, marked text, the error voice, the base attributes, the restyle) and four declared arms (the
Mac's flight hold, the Mac's caret-context republish, each platform's settle road, the Mac's extraction
counter). But the band is not self-contained: it mutates the TILING the gate and the projection roads
also own (`index.transferTailPrefixToLastEntry`, `index.crystallize`, the ledger) and touches their
routing/settle state (`bulkPending`, `pendingEdit`, `forceFullRender`, `storeWriteGeneration`). Whatever
the shape, that entanglement has to cross the seam — the honest question is HOW.

**A technical constraint that rules one shape out (so the ruling can weigh it).** P-9's preferred form —
a value state struct passed `inout` — cannot carry the EFFECTFUL band: its storage writes re-enter the
view model synchronously (`NSTextStorage.processEditing` → `storageDidEdit`; on the Mac, AppKit's
selection-change delegate → `updateCaretContext`, which READS the tiling; the autosave coordinator's
observers), and an `inout` access to view-model state that spans such a re-entry is a dynamic
exclusivity violation — a runtime trap in exactly the paths the pins drive. So the value seam can hold
the PURE decisions (and does, today: `CrystallizationPlanner`, `CrystallizationReconciler`,
`BlockRangeIndex`, `EditorSurfaceLedger`), while the choreography needs short accesses on a reference
type.

**(B) — RECOMMENDED — a shared `TailCrystallizer` that OWNS the band's own state; each view model owns
one (downward reference only) and passes ITSELF, per call, as a narrow `TailCrystallizerHost`.** No
stored back-reference anywhere: the crystallizer holds no model; the host arrives as a parameter and is
captured only by the two Tasks exactly as today's Tasks capture `self` (strong for the mint — the review
round 1 MINOR 5 posture, "the reconciliation must run even if the view goes away"; weak for the idle
clock).

- **State that MOVES into the crystallizer** (the band's own): the tail text, `mintInFlight`,
  `mintTask`, the idle task, `tailIdleDebounce`, `tailIdleSleep`.
- **The host protocol** (`@MainActor protocol TailCrystallizerHost: AnyObject`), each member classed:
  - *the tiling, which the VIEW MODEL KEEPS* (its `private(set)`/`private` setters stay exactly as they
    are — the band gets narrow intention-revealing doors, never a widened setter): `index` (get) ·
    `transferTailPrefixToLastEntry(_:)` · `crystallizeIndex(minted:remainingTailLength:)` ·
    `knownSurfaceText(variantID:)` · `recordSurfaceText(variantID:text:)`;
  - *routing/settle state the band touches, which the view model keeps:* `bulkPending` (get) ·
    `clearBulkPending()` · `disarmPendingEdit()` · `requestFullRender()` · `noteOwnWritesSettled()`;
  - *the store doors:* `autosave` · `mintRunner` (`session.runner`) · `postID` · `segmentation`;
  - **ACCESSORS (the injected differences):** `surfaceStorage` (`textView?.textStorage` · `storage`) ·
    `hasMarkedText` (`hasMarkedText()` · `markedTextRange != nil`) · `reportOperationError(_:)`
    (`showOperationError` · `statusMessage = String(describing:)`) · `programmaticReplace(…)` +
    `clearTextUndo()` (each view model's write door, rebuilt on the shared storage door below with its
    base attributes and restyle) · `auditIdentityProjection()`;
  - **DECLARED ARMS:** `holdsTailForStructuralFlight` (Mac `structuralInFlight`; phone `false` — reason:
    the (iii) answer above) · `didApplyMint()` (Mac `updateCaretContext()`; phone nothing — B's
    `finishMint` row) · `applyPendingIfClean()` (each platform's settle road, kept per-platform — F-2).
  - **Honest size: 23 members.** "Thin" holds for the DIFFERENCES (the accessor and declared rows); the
    rest is the view-model state the band genuinely shares with the gate and the projection roads, made
    explicit and narrow.
- **Forwarding (3C — every pin-reached name kept):** both view models keep `tailText` and
  `mintInFlight` as read forwards, `tailIdleSleep`/`tailIdleDebounce` as read-write forwards (pins SET
  `tailIdleSleep` — 18 files), and `idleMintTail()` / `armTailIdleMint()` / `mintableTail` /
  `awaitMintSettle()` / `hasOpenTail` as forwards; `crystallizeIfNeeded` / `finishMint` /
  `attachLeadingTailRunIfNeeded` become private forwards where their in-file callers need them (the
  Mac's `finalizeWork` calls `finishMint`; its soft-newline road calls `idleMintTail`/`awaitMintSettle`).
  The view-model sites that write the tail or cancel the clock outside the band (`.openTail`/`.closeTail`,
  `syncTailText`, the Mac's `adoptRewrite`, the phone's `renderFull`, `holdTailIdleClock`, the teardown
  cancels) change to crystallizer calls — compiler-guided, the state is no longer theirs to assign.
- **What it buys beyond de-duplication:** the tail's lifecycle becomes an object with its own state that
  a FAKE host can drive — the choreography (skip-and-re-arm, the flight hold, the reconcile-apply order)
  testable without a mounted editor, which is the U1 table suite's value applied to this band (not built
  here unless the architect asks; the 3C proof rides the existing pins).

**(A) — the host-protocol MIXIN (the bodies move verbatim into a protocol extension; the view models
conform).** Smallest diff and the most literal address move (the reviewer diffs bodies 1:1, and every
name stays on the model automatically). **Not recommended:** the extension can only reach state through
settable requirements, so ~12 `private`/`private(set)` members (`index`, `tailText`, the ledger,
`bulkPending`, `pendingEdit`, `mintInFlight`, `mintTask`, `forceFullRender`, `storeWriteGeneration`, the
idle task, the phone's `session`…) widen to module-settable — which FORMALIZES the god state P-9 and the
health review §2.1 name rather than splitting any of it. Its one strength is risk; B's receiver changes
are mechanical and compiler-guided, so the gap is small.

**(C) — value facts + pure fragments only.** Hoist just the pure decisions (the leading-run plan, the
kind/plan decision, the mint body, the post-reconcile region plan) and leave each view model its
choreography. P-9's letter exactly, but the choreography — the part that actually drifts (the flight
hold, the skip-and-re-arm, the apply order) — stays twice; rejected against the charter's purpose (and
see the exclusivity constraint above for why the value seam cannot take the choreography too).

**(D) — for awareness, not recommended: B plus the TILING itself** (`index` + the ledger moved into the
shared object). It would thin the host to the accessor and declared rows (~12), at the cost of
rewriting every tiling mutation in both gates, both consume roads and both projection executors (~40
sites) — row 70's decomposition territory, beyond U2's charter.

**The rest of the hoist, whichever of A/B is ruled:**
- **The storage doors — `Shared/EditorBrain/EditorSurfaceStorage.swift`**, `nonisolated enum` over
  `NSMutableAttributedString` (the `IdentityProjectionAudit` precedent: both platforms' `NSTextStorage`
  share that Foundation superclass): `text(of:in:)` (viewText's read), `setBlockID(_:over:in:)`
  (setBlockAttribute), `replace(_:with:blockID:in:base:restyle:)` (programmaticReplace's
  begin/replace/set/restyle/end core). The view models keep their names and their STATE around it:
  the Mac's extraction counter (DECLARED), the suppress toggle, the out-of-range guard → `desyncRecovery`,
  the caret-to-end (ACCESSOR). The Mac passes `restyle: nil` with F-3's pointer at the argument.
- **The mint body — `TailCrystallizer.mintBlocks(_:in:ops:)`**, `nonisolated static`: the ONE copy of the
  R-13u-3 no-undo exception, consumed by the crystallizer AND the Mac's `finalizeWork` (three copies → one).
- **The audit consumer — `IdentityProjectionAudit.audit(index:storage:countingFailure:file:line:)`**,
  `@MainActor`, DEBUG-only body, count-then-fire (TODAY's order), the call site's `#fileID`/`#line`
  threaded to the seam (no pin reads them — every muted handler is `{ _, _, _ in }`, grep-verified);
  both `auditIdentityProjection()`s become that one call and keep their own counters.
- **Stays per-platform in U2, each for its recorded reason:** `desyncRecovery` (every line is view-model
  state or a platform road — C's table), `applyPendingIfClean` (F-2 + two DECLARED differences),
  the projection executors (`renderFull`/`applyDifferential`/`displaySlot` — the Mac's live in the pinned
  N10 controller beside 18l's reading-anchor and keeper machinery, which this unit must not fight; their
  shared core is ~8 lines), `restampProjection` and the Mac's `stampProjection` (DECLARED twins), the
  Mac's N10 seam primitives (DECLARED), `runSoftNewlineInTail` (DECLARED), both teardown backstops (O-4).
- **File layout:** `Shared/EditorBrain/TailCrystallizer.swift` (the class, the host protocol, the static
  mint body — every arm's ruling moved with it, as U1 moved the ladder's prose to the arms) ·
  `Shared/EditorBrain/EditorSurfaceStorage.swift` · `IdentityProjectionAudit.swift` gains the consumer.
  The two conformances live INSIDE each view model's own file (a same-file extension is what can reach
  their `private` state for the narrow doors). No project edit (`Shared/` is a synchronized root in both
  targets).
- **Commit plan (step 3):** (1) the storage doors + both view models' primitives through them; (2) the
  audit consumer; (3) the crystallizer + both conformances + the forwards, **with row 28's enumeration
  in the same commit**; each followed by the Mac `build-for-testing` and the generic-iOS build; then the
  finals.
- **Row 74 (step 4) — the lean: NOT TAKEN, to be confirmed at step 4.** Under B the diff touches the
  phone's teardown road only by ADDRESS (`finish()`'s idle-clock cancel becomes the crystallizer's). A
  take is a lifecycle behavior change that needs C1's own T1–T5 trace for the phone — whether its
  leaving-savepoint road leans on the never-released entry (C1's T3 found three such roads on the Mac),
  and what `flushEveryOpenPost`'s walk costs — which is a unit's worth of trace inside a phase-sized unit.
  If the architect wants it taken here anyway, it lands as its own commit with the registry-count pin
  (C1's form) run red on the pre-fix tree first.

**STOP — awaiting the ruling on (A)/(B)/(C)/(D), on the "rest of the hoist" list (in particular: keeping
`applyPendingIfClean`, `desyncRecovery` and the projection executors per-platform in U2), and on row 74.
The three findings (F-2, F-3, F-4) and O-4 are the orchestrator's to route.**

### U1 — THE WALK, RUN (orchestrator's own hands, 2026-09-29, at her granted window; the held gate discharged)

**Preconditions verified:** zero instances by pgrep (her app quit at her word); `guard.sh
--author` exit 0 (idle 250 s); AX + Screen Recording granted; the dev app built from THIS tree
(`DerivedData/18m-u1`, includes the ladder fix `276fc460`) and launched by path; every act
`cliclick`-driven with ≥2 s spacing; captures in `notes/plans/18m-screens/u1/` (gitignored);
the dev store's voice ENDED Terminal (row 91 honored, verified by capture); the walk instance
quit by ⌘Q at the end (pgrep clean).

| # | Arm | Terminal | Study |
|---|---|---|---|
| W1 — A7 carve | ⏎ at Alpha's end minted the empty block (2/3, ringed); ⌫ carved it — GONE, tray ⊗1, receipt *"Empty block deleted — ⌥⌘Z undoes it."*, caret at Beta's start | **PASS** | **PASS** (the carve-then-merge sequence's end state + ⊗1 prove the intermediate) |
| W2 — #34 fanless seam | ⌫ at Beta's start joined ONE block "Alpha Beta", receipt *"Blocks joined — ⌥⌘Z undoes it."* | **PASS** | **PASS** |
| W3 — #34 fanned seam | ⌥⌘Z restored; ⌘T gave Alpha ⑂2 (receipt *"New take added on this block — ⌘⇧T shows the takes."*); ⌫ at Beta's start: NOTHING joined, the refusal TOASTED: *"The block above has takes — backspace won't fold a fan away. Merge Blocks (⌘⇧M) joins them and brings every take along; Merge choosing takes (⌥⌘⇧M) lets you arrange them yourself."* | **PASS** | **PASS** (same sentence, Study voice) |
| W4 — J9 | triple-click the middle paragraph + ⌫: the block GONE to the tray (⊗1), receipt *"Block deleted — ⌥⌘Z puts it back, then in This Note's Tray — the tray icon at the top of th…"* (the slot truncates honestly; Study's wider slot shows more), caret on the next block | **PASS** | **PASS** |
| W5 — the clamp | ⌥⌘Z restored; the same triple-click selection TYPED OVER → the block's text replaced IN PLACE ("Replaced", 2/3 — the break stands); ⌘Z stepped back as ORDINARY TEXT UNDO (character-granular, no structural entry consumed, no "Undid:" line) | **PASS** | **PASS** (clamp verified; the ⌘Z half proven in Terminal) |
| W6 — the compound | a mid-to-mid selection across three blocks + ⌫: the middle rode the tray, the ends JOINED (1/1), receipt (Study's full width): *"1 block to This Note's Tray; the ends joined — originals under Came from. ⌥⌘Z undoes it."* | **PASS** | **PASS** |
| W7 — nothing regressed | one character typed mid-block landed ("FirstXparagraph." / "First Xparagraph."), no refusal | **PASS** | **PASS** |

**14 of 14 rows PASS.** Every receipt/refusal sentence read in use matches the route mapping's
(the hoist changed no words — the walk's own confirmation of the 3C claim from the felt side).
**The VisualWalk subset: PASS, 6/6 scenario-passes, 0 FAIL / 0 XFAIL / 0 XPASS** across
`write-newline-roundtrip` · `write-divide-merge` · `b5-more-roads` in BOTH voices (runs
`vis-walks/2026-09-29/031239/` — five passes — and `032801/` — the sixth). Two machinery notes,
honestly: (1) the FIRST subset attempt refused at the harness's own stamp rule — this seat's
record commits landed mid-build and the stamper correctly declined a moved tree (the build
itself succeeded); re-run clean on the quiet tree — the traps gain the lesson: NO commits while
a stamped harness build is in flight. (2) `b5-more-roads` (Study) aborted once at the per-step
guard ("someone is at the machine", HID input ~20 s prior — real input; she confirmed in chat
minutes later and granted the resume) — the guard's abort clicked nothing and the harness quit
its instance cleanly; the dev store's voice was left at Study by that abort and RESTORED to
Terminal by hand (verified by capture) before any suite could meet row 91; the re-run PASSED
and the harness's own voice-restore ran. **U1's USE acceptance: PASS whole. Ledger row 1 —
CLOSED.**

### U2 — THE INJECTED-SURFACE RULING (orchestrator, 2026-09-29 — the 4E pattern; the settled ground steps 3–5 proceed on)

**RULED: (B)** — the shared `TailCrystallizer` in `Shared/EditorBrain/` OWNS the band's own
state (tail text, mint flight/task, idle clock); each view model owns one and passes ITSELF per
call as a narrow `TailCrystallizerHost`; NOTHING stores a back-reference — the per-call host is
P-9's accepted alternative to a stored `model:` seam, and the record's exclusivity analysis
(the band's storage writes re-enter the view model synchronously, so an `inout` value hold
would trap) is adopted: the VALUE seam covers the pure layer, the host covers the effects.
(A) is rejected — ~12 private members made module-settable is P-9's god state formalized;
(C) is rejected — it leaves exactly the drifting half duplicated (fails the charter); (D) is
rejected — the tiling move is row 70's territory and past this phase's sizing. **Also
approved as proposed:** the `EditorSurfaceStorage` storage doors, ONE shared mint body (the
three byte-identical copies collapse), the shared audit consumer.

**Conditions riding the ruling (the reviewer checks each):**
1. **The host protocol is documented per-member** — each of the ~23 members names the band
   function(s) that need it, so the reviewer can verify no general-purpose leak; conformances
   are extensions on the view models exposing nothing beyond the band's needs; the view
   models' `private(set)` surfaces stay as they are.
2. **The deliberate platform deltas stay DECLARED at the host** (the Mac's
   `structuralInFlight` reads and ⇧⏎ arm, the phone's marked-text accessor and
   `restampProjection`, each error voice) — never averaged, each with its recorded reason.
3. **The hoist commits are BEHAVIOR-PRESERVING and SEPARATE from the rider commits below** —
   the 3C diff stays clean for the cold read; zero test edits on both platforms for the hoist
   half.

**The per-platform list STANDS for U2** (`applyPendingIfClean`, `desyncRecovery`, the
projection executors) — and after F-2's rider lands, `applyPendingIfClean`'s convergence
becomes a row-28 NEXT-TOUCH candidate (recorded in the enumeration, deliberately NOT taken
this unit). **Row 74: NOT TAKEN accepted** (the record's reasons; the row stays the mobile
project's).

**The findings, dispositioned:**
- **F-2 (the phone never got 17b P36) — FIX IN-ROUND as a RIDER, after the hoist:** its own
  commit, red-on-old pin first (the P36 pin's phone twin: a thrown re-read RESTORES the
  deferred-projection marker instead of dropping it — the Mac's fix is the model, its pin
  form named in the 17b P36 record). A dropped external change waiting on a further store
  write is a correctness defect this phase is touching; the fix is the marker-restore lines.
- **F-3 (the Mac's mint/differential replace drops the markdown face) — FIX-ATTEMPT RIDER,
  pin-first, after F-2:** the pin asserts the face SURVIVES on the real roads (the typed
  `# Title` ⏎ mint; the take-flip/`restoreCommit` differential). RED on old → fix = the
  restyle argument at the Mac's call site (the span-bounded, attributes-only
  `MarkdownStyling.restyle` its own `applySeamEdit` already runs — no new mechanism). If no
  user-reachable road pins red (something re-faces before paint), RECORD-ONLY per the
  hallucination guard — never a speculative fix. Faced text is the shipped standard
  everywhere, so this is defect-repair, not product design.
- **F-4 (the phone's structural flight has NO keystroke fence — a mid-flight keystroke
  DUPLICATED store text in probe P-b at every in-flight interleaving) — NOT FIXED IN 18m,
  OWNED NOW:** the phone's structural-door semantics are the mobile catch-up's by this
  phase's own fence. A NEW KnownIssues row lands with this ruling (owner: the mobile app
  project row; a 17 entry at her word takes it earlier — it is DATA-SHAPED: the store
  duplicates text, and platform truth 2 means autocorrect can land such a keystroke without
  her typing), carrying P-b's reproduction recipe verbatim as the future red-on-old. **It
  also goes in HER BUNDLE** (worth her priority eye before the beta's phone question).
- **O-4 (the teardown backstops' marked-text difference) — RECORDED, not unified;** flagged
  to the U2 ladder: if the reviewer traces a real Mac hazard (a `finalizeWork` mint under an
  open IME composition rewriting mid-composition), it becomes an owned finding then.

The `.gitignore` line is accepted (the traps presumed it). **Sizing, said out loud:** the two
riders are small pinned fixes beside the phase-sized hoist; U2 remains ONE acceptance unit;
if either rider grows past a pin-plus-lines shape, STOP and report rather than absorb.
**Proceed with steps 3–5 in this order: the hoist (3C-clean) → F-2 → F-3 → the walk/finals.**

### U2 WALK (the implementer's own hands, 2026-09-29 04:28–04:40, at her granted evening window)

**Preconditions verified:** zero instances by pgrep (her app quit at her word); `guard.sh --author`
exit 0 (idle 3,169 s at the start); the dev app built from THIS tree (`DerivedData/18m-u2`, commit
`4117689b` — the hoist + both riders) and launched by path; every act through `keys.sh` (the
author checks → activate → full guard → act) with ≥ 2 s between guarded acts; typing as
per-character keystrokes 120 ms apart inside one guarded act (every character landed, row by row —
the 13u3 UNIT B drop did not recur at this spacing); captures in `notes/plans/18m-screens/u2/`.
Each row runs in a FRESH note (⌘N — a new note is all open tail, the band's home ground; with
blocks present the chip-on Return is structural and the tail only opens from a newline arriving as
text, AppSpec §7). The status bar is the oracle: **open tail** while the caret is in the tail,
**block n/m** once it is a block; "Nw in note" counts blocks only.

| # | Row (what the band must do) | Terminal | Study |
|---|---|---|---|
| W1 | **The idle mint** — "First paragraph." typed into a fresh note, then a pause | **PASS** — open tail → **block 1/1**, 2w, bytes and caret unchanged | **PASS** |
| W2 | **Type-time crystallization** — "One paragraph.⏎Two" in one burst; captured inside the idle window, then after it | **PASS** — mid-typing "One paragraph." is already a block (**2w in note**) while "Two" is the **open tail**; after the pause **block 2/2, 3w** | **PASS** |
| W3a | **k−1, typed gap** — "Alpha.⏎⏎⏎Beta" | **PASS** — **block 2/2**, both blank lines between them byte-exact through both mints | **PASS** |
| W3b/c | **k−1, the idle mint's kept-open run** — "Gamma.⏎⏎", pause, then "Delta" | **PASS** — at the pause "Gamma." minted, the typed gap stayed exactly where she left it, caret in the kept-open EMPTY tail (**open tail**, 1w); "Delta" then landed after ONE stored blank line — **block 2/2** (the leading-run attachment made the gap durable content) | **PASS** |
| W4 | **⇧⏎ in the tail (Mac-only, A15)** — "Soft", a HELD-shift Return, "line" | **PASS** — "Soft⏎line" is ONE block (the editing ring encloses both lines), **block 1/1, 2w block**: the tail minted first, the soft newline stayed content at the caret | **PASS** |
| W5 | **Bulk paste** — "Pasted one.⏎⏎Pasted two.⏎Pasted three." via `pbcopy` + Edit ▸ Paste (the real menu) into a fresh note | **PASS** — segmented on entry: **block 3/3, 6w**, the pasted blank line kept as "Pasted one."'s trailing content, caret at the end | **PASS** |
| W6 | **Rider F-3 from the felt side** — "# Heading " (captured faced), then in a fresh note "# Heading ⏎B" in one burst (the typing mint trims the space and rewrites the tail region) | **PASS** — after the mint (**block 2/2**) the heading is STILL faced: dimmed `#` marker, bold, larger type, exactly as typed (on the pre-fix tree it dropped to body style — the pin's red) | **PASS** (Study's serif face, same) |

**12/12 rows PASS.** Machinery notes, honestly: (1) **one guard trip, self-caused** — a burst
spaced ~0.5 s after the previous synthetic act tripped `guard.sh`'s exit 4; the HID idle then
climbed monotonically 8 → 13 s (the README's own discriminator — a human's keeps resetting), so the
walk resumed; the interrupted W6 attempt's capture (the heading faced as typed) is kept as W6a.
(2) **The dev instance TRAPPED once, and it was NOT this unit's code:** opening the TENTH note of
the session (one fresh note per row) hit KnownIssues row 73 — `EditorCommands.swift:782`'s
`Character("10")` for the Open strip's ⌘⇧<n> key equivalents (`_assertionFailure` in
`Character.init`, crash report `Variorum-2026-09-29-043442.ips`, the frames confirmed), owned by
**18o**, untouched here. The Study W1 capture was taken before the trap; the instance was
relaunched clean (Study voice persisted, the Open strip empty) and W2–W6 run in seven notes. Walker
fact for the kit: keep fewer than ten notes open in a Debug walk until 18o lands. (3) The dev store's
voice was flipped through Settings' Accessibility road (pane 1, radio group "Design voice") and
RESTORED to Terminal the same way (read-back `1, 0`, capture). The phone's twin of this band is
covered by the harness (the full mobile suite — `MobileSpaceEaterTests`, `MobileTrailingNewlinesTests`,
`MobileEditorCrystallizationTests`, `MobileNoteClipboardTests`, the perf walk's oracles), there
being no phone GUI walk kit.

### U2 SELF-ASSESSMENT (for the FABLE cold reviewer)

**What I claim, and the evidence for each claim:**
1. *The hoist (3a/3b/3c) moved an ADDRESS, not behaviour, on both platforms.* Every moved body is the
   pre-move body with its receivers re-pointed — the crystallizer's own state bare, view-model state
   through the per-call host — in the same order, with the same guards and the same effects. The Mac
   copy was the superset; the phone's two missing `structuralInFlight` guards are carried as the
   DECLARED `holdsTailForStructuralFlight == false` (probe P-a is the evidence it is architecture,
   not drift), its missing caret republish as `didApplyMint() {}`. Evidence: zero test edits in the
   three hoist commits; the band's own families green BEFORE any rider landed (Mac 313/41, phone
   257/38 with only F-1) and again at the finals; the walk 12/12.
2. *P-9 held.* Nothing stores a model: the crystallizer holds only its own state; the view model owns
   it downward; the host arrives per call. The two Tasks capture the host exactly as the old Tasks
   captured `self` — strong for the mint and its two follow-up Tasks, weak for the idle clock.
3. *The ruling's three conditions.* (1) Every one of the 23 host members names the band function that
   needs it (`TailCrystallizer.swift`'s protocol doc); both conformances live in their model's own file
   as extensions of narrow doors — no `private`/`private(set)` setter widened (the phone's
   `surfaceKnownText` was an existing member with the identical ledger read). (2) The deltas are
   declared at the host with their reasons — the structural-flight hold (both platforms' reasons side
   by side), the caret-context republish, both marked-text accessors, both error voices, each settle
   road; the ⇧⏎ arm and `restampProjection` are named in the file header as deliberately OUTSIDE the
   band. (3) The hoist commits are behaviour-preserving and separate from the rider commits (pin and
   fix each their own commit).
4. *The riders are real fixes, not speculation.* F-2: `MobileDeferredProjectionRetryTests` RED on the
   pre-fix tree (`067657d2`) at the marker expectation, GREEN after `9ba53fa0`. F-3:
   `ProgrammaticReplaceFaceTests` RED on all three user-reachable roads (`8ffaaa18`) with every
   road-taken expectation holding, GREEN after `4117689b`, and felt in the walk (W6).

**Where I would look hardest if I were reviewing this cold:**
- **The Task captures in `TailCrystallizer`.** The idle Task now captures `[weak self, weak host]` and
  guards the host before calling back; the mint Task captures the host strongly plus `self`
  implicitly. The corrections-flush Task captures the HOST (`[host] in await host.autosave.flushNow()`)
  rather than the coordinator alone, deliberately: the old `self.autosave` capture kept the view model
  alive until that flush landed, and 18k C1's release lives in the view model's `deinit` — capturing
  only the coordinator would have let the model die (and release its registry hold) before the flush.
- **`runner` read at Task creation** (`host.mintRunner`) where the old code read `session.runner` inside
  the Task — `AppSession.runner` is a `let`, so it is the same actor either way.
- **`finishMint`'s effect order**, now through host doors: corrections (ledger, then autosave) → the
  flush Task → the quiet deletions Task → the full-render request → the two early exits → the
  tail-region rewrite + text-undo clear → the ledger → `disarmPendingEdit` → `crystallizeIndex` → the
  tail text → the stamps → the audit → (Mac) the caret republish → the re-crystallize → the idle clock →
  the settle. Same as both originals.
- **Two tiny non-1:1 lines:** the Mac keeps a private read forward `mintTask` purely so `finalizeWork`'s
  wait loop stays verbatim; the phone's private `setBlockAttribute` was deleted because its only two
  callers moved (the crystallizer stamps through `EditorSurfaceStorage.setBlockID` itself).
- **The audit consumer's assertion location:** the seam now reports the view model's `audit(...)` call
  line instead of its old `fire` line, a few lines away in the same file (no pin reads it — every muted
  handler is `{ _, _, _ in }`, grep-verified). Its Release profile is unchanged: both call sites stay
  inside `#if DEBUG`.
- **F-3 widens what one door does** (the Mac's `programmaticReplace` now re-derives the face over the
  span it replaced — the span-bounded, attributes-only restyle `applySeamEdit` already runs, inside the
  same storage transaction). Its cost is ∝ the replaced lines; `MarkdownFaceTests`' P1 scan budget ran
  green beside it. The differential latency pin (row 26) times the structural divide (`applySeamEdit`),
  a road F-3 did not change.
- **The host's width (23).** The accessor and declared rows are the platform differences; the rest is
  state the band shares with the gate and projection roads. Ruled (B) with that width stated; (D) —
  moving the tiling too — would thin it and is recorded as row 70's territory.

**Not done / owed:** the first line above. F-4 stays OWNED by its KnownIssues row (untouched here).
O-4 recorded for the ladder. `applyPendingIfClean`'s convergence recorded as a row-28 next-touch
candidate. KnownIssues row 73's Debug trap met during the walk — 18o's, untouched.

### U2 — ORCHESTRATOR VERIFY PASS + THE RIDER REVERTS (2026-09-29 overnight; verify-never-trust)

**Claims verified against git:** seven code commits `65941ee9..4117689b` + the walk/record
commits, tree clean at `c915706f`, pushed, no trailers; the 3C proof re-run by diff (the three
hoist commits touch ZERO test files; the whole window's test-target diff is exactly the two
rider pin files); `Sources/`, `Server/`, `Sync/` untouched; zero instances; the mobile finals
649/111 = the attributed baseline exactly (the 4 known + F-1, plus the two new rider pins in
the count). The walk's tenth-note crash confirmed as KnownIssues row 73's known Debug trap
(owner 18o) by the implementer's frame check — not this unit's.

**The discipline gap the implementer named, closed by this seat:** the riders' red-on-old was
shown by run order only, and the standing rule wants BEHAVIORAL REVERTS. Both run by the
orchestrator on the committed tree, each named before it ran, each restored by
`git checkout HEAD --` with `git status` clean after:
- **R-F3** (the Mac call site back to `restyle: nil`): `ProgrammaticReplaceFaceTests` **RED
  3 tests / 3 issues** — every road's face assertion, exactly the pre-fix shape.
- **R-F2** (the phone's thrown-read arm back to a bare `return`):
  `MobileDeferredProjectionRetryTests` **RED 2 tests / 1 issue** — the marker-survival pin
  red, the over-fire guard green, exactly the pre-fix shape.

Ledger rows 2–3 stand BUILT + WALKED (the implementer's 12/12 typing walk, both voices; this
seat's revert pass is the acceptance's verification half — a separate hands-on walk is folded
into the closeout's install-refresh window if wanted; the felt evidence stands on the walk
plus F-3's felt check). **The FABLE cold review over `25ce55df..c915706f` is the remaining
gate**; ladder file `notes/plans/18m-u2-ladder-round1.md`.

## U3 BRIEF (session 3 — one refusal table; written by the orchestrator 2026-09-29 one-ahead, at U2's verify pass; RE-CHECK against the U2 ladder's outcome before spawning)

You are the `opus-implementer` for **18m UNIT U3**: the operations layer's refusal copy gets
ONE home — `OpsRefusalCopy` hoists to `Shared/`, `EditorViewModel`'s private
`operationMessage` switch is DELETED onto it, and the six mobile `OperationError` switches
collapse onto the table — **keeping platform door-names local** (MobileSoul §4.4; the hoisted
`CrossBlockRefusal`'s `fanRoads:` parameter is the worked precedent). **The charter's U3
bullet is your unit charter** (`notes/plans/post-13u-health-rounds.md` KICKOFF 3).

**Read first, in this order (reading is never delegated):** (1) THIS file whole — the fences,
BINDING PRINCIPLES, CAST & DISCIPLINE, BASELINES, THE CONDUCTOR MAP's refusal-copy row (the
FOUR sealed-note spellings are quoted there; the six mobile switch sites are named with
lines), THE LEDGER row 4 (O-1 — U1's gap-refusal copy divergence — is this unit's input,
quoted in the U1 RECORD's STEP 5), ENVIRONMENT TRAPS, the U1 and U2 RECORDS + ladder files
(the settled ground: `EditorEditRoute`'s diagnose arm and `CrossBlockRefusal` are routing's,
not yours to move; `TailCrystallizer`'s error-voice host member is U2's — your table is what
those voices SPEAK). (2) The charter's KICKOFF 3 + the health review §2.1 leak 2 (the
duplication's record). (3) `notes/MobileSoul.md` §3/§4.4 — the LAW of this unit: a shared
home must not hold words naming a platform's own doors. (4) `notes/KnownIssuesAndTechDebt.md`
row 28 (the enumeration — the refusal-copy fork is (c)-class; your commit updates it).
(5) `notes/QUESTIONS.md` — read the CURRENT next-free number fresh (it was #159 at kickoff).
(6) The code, END TO END: `Registry/OpsRefusalCopy.swift` whole (725 lines — EVERY string
read for door-names/chords before anything moves); `EditorViewModel.operationMessage` (:4506)
and its two callers; the six mobile switch sites (`MobileMembership` :175 · `MobileBlockMenu`
:364 · `MobileComments` :286 · `MobileStructural` :889 · `MobileTrashModel` :278 ·
`MobileUndoDoor` :276) and the phone's pinned statics beside them
(`MobileEditorViewModel.lockedTakeRefusal`, `fanFoldRoads`); the copy-register pins on BOTH
platforms (grep `OpsRefusalCopy|operationMessage|refusal` over both test trees and read every
suite you find — `MobileCopyRegisterSweepTests` and the Mac's copy pins are the riding
surface); the GATE sentences (the two sealed/locked pre-arm lines in both gates — part of the
sealed convergence; `message(for:)`'s four `BlockRangeIndex.Refusal` cases on the phone are
GATE vocabulary, and whether any of them joins the table is yours to PROPOSE, not assume).

**The unit, in order:**
1. **THE STRING CLASSIFICATION TABLE (the checkpoint — the architect rules it):** every
   string in `OpsRefusalCopy` + `operationMessage` + the six mobile switches + the gate
   sealed/locked lines, classed: SHARED-AS-IS (no platform word) · PARAMETERIZED (a
   door-name/chord slot the platform fills — the `fanRoads:` shape) · STAYS-LOCAL (a
   platform's own sentence, with why). Beside it: **the WORDS-CHANGE TABLE** — every mobile
   sentence the collapse would change (site × old × new × why the charter sanctions it), and
   **the ONE converged sealed-note sentence you propose** (the canonical table's string is
   the spec-defensible default per the charter; all four current spellings quoted; the
   convergence is PROVISIONAL — copy is hers), plus your proposal for O-1's pair (converge
   the gap-refusal sentence or keep it platform-worded, with the tail-vs-gap cause-ranking
   half stated separately — words-about-behavior, treated with care). COMMIT the tables and
   STOP for the orchestrator's ruling before the collapse lands.
2. **BUILD per the ruling** on the 3C pattern: the hoist half (the table's address moves;
   Mac consumers ride on forwards/typealiases; zero test edits) in its own commit(s);
   the COLLAPSE half (the deletions + the mobile switches onto the table) after — where a
   COPY PIN asserts an old sentence the ruling converges, that edit is SANCTIONED and named
   out loud, one by one (the 18l-b U3 sanctioned-edit form); everything else rides
   unmodified. Row 28's enumeration updates in the hoist commit. A QUESTIONS row lands with
   the converged sentence (the four spellings quoted; one line to overturn).
3. **Pins:** a NEW table-integrity pin (the shared table holds no platform door-name — a
   source-walk over the shared file banning the Mac chord/door vocabulary and the phone's,
   the MobileSoul §4.4 law as a tripwire; the `StatusSeamVocabularyTests`/`ChromeLineLimitTests`
   source-walk form) + the convergence pins red-first where behavior (words) changes.
4. **WALK (USE), both voices + the phone simulator where a face shows:** drive at least the
   sealed-note refusal (Write gate + one op door), one locked-take refusal, and one mobile
   refusal face (simulator suite evidence acceptable for the phone), reading each sentence on
   screen against the ruled table. **Finals:** the touched Mac suites + the copy/registry
   families + the eleven Tutorial suites, THE FULL MOBILE SUITE (baseline 649/111 = the 4
   known + F-1), the generic-iOS build.

**Discipline:** the resiliency protocol binds from your first commit — `## U3 RECORD` in THIS
file, LIVE STATUS per piece, PENDING marks, commit+push per piece, NO trailers, pathspec
staging, synchronous foreground waits only, NEVER spawn subagents, commit before any
behavioral revert (run your convergence reverts AFTER the fixes land — the U2 verify pass's
form). PROVISIONAL-and-continue (QUESTIONS); STOP-and-report for gating ambiguity, anything
wanting `Sync/`, every author-only call. Zero `Sources/` expected (the table is app-layer
`Shared/`); zero schema. Your diff is refusal copy on the editor seam's vocabulary → a
**FABLE cold review** follows; your self-assessment closes your record.

## U3 RECORD (the `opus-implementer`, session 3 — opened 2026-09-29)

**NOT DONE (first line, per the contract): NOTHING IS BUILT. Step 1's checkpoint is written below
and the unit is STOPPED for the architect's ruling (the brief's hard checkpoint).** No code has
moved; no revert is in flight; the tree is clean but for this record.

### LIVE STATUS

| Piece | Status |
|---|---|
| Preflight reads — this file whole (fences, P-1…P-9, cast, baselines, the conductor map's refusal row, ledger row 4 + O-1, traps, the U1 and U2 RECORDS) + both ladder files; the charter's KICKOFF 3; the health review §2.1 (leak 2), §3, §8; MobileSoul whole (§3, §4 item 4 — the no-redirect law this file calls §4.4 — and the parity ledger); KnownIssues row 28 whole; QUESTIONS' tail (next free **#159**, confirmed); SessionResiliencyProtocol whole; TEXTKIT2_NOTES whole. The code: `Registry/OpsRefusalCopy.swift` whole (all seven enums, every string); `EditorViewModel.operationMessage` + `showOperationError` + the ⌘S door's pre-check + `message(for: BlockRangeIndex.Refusal)` + the typing gate; every Mac seal line (grep); the six mobile sites + the phone's `message(for:)`, `lockedTakeRefusal`, `fanFoldRoads`, the gate and the P3 mapping; `Shared/RecoveryActs.swift` (`DeletionRefusal`) and `RecoveryCopy.sealedPutBackRefusal`; `Shared/EditorBrain/CrossBlockRefusal.swift` + `CrossBlockRefusalRoads.swift` (the worked precedent); `SeededBookRestore.failureLine` (the recorded "OpsRefusalCopy stays Mac-local" rule); `ChipRefusals`/`ReadingsViewModel.message`/`CommentsPanelCopy`/`RefusalCopy`/`TrayRefusalCopy` (the neighbouring families); the core guard order behind `lastActiveVariant`/`variantIsChosen` (`Operations+Deletion.swift`); the pins that ride this surface on both platforms (every test naming `OpsRefusalCopy`, every literal/fragment pin over the sentences below — listed where they bite) | DONE (read in this session, never delegated) |
| Step 1 — the string classification table · the words-change table · the ONE converged seal sentence · O-1 · the build shape | DONE (`997948ea`) — **RULED** (`000044e3`, the CLASSIFICATION RULING section below): (a) at R1+ with the noun a parameter · L-c · the collapse rule · Trash stays on `DeletionRefusal` · O-1 (a), ranking recorded-not-built · G yes · V yes (inside the phone's conformance) · the layout + the §4.4 source-walk tripwire over the shared file; S-1/S-2/S-3 sanctioned |
| Commit 1 — the HOIST (3C): `Shared/OpsRefusalTable.swift` (the shared table, `words(for:roads:)` / `message(for:roads:)`, `OpsRefusalRoads`'s two chord slots, G's `gateMessage`), the Mac half in `Registry/OpsRefusalCopy.swift` (forward + Mac-only arms + `.mac` roads; `.lockedPost` still Mac-local with today's words), both view models' `message(for:)` as forwards; row 28's (c) entry | DONE (this commit) — Mac `build-for-testing` ** TEST BUILD SUCCEEDED ** + generic-iOS ** BUILD SUCCEEDED **; zero test files touched; the Mac's words byte-identical by construction (every moved literal copied, the two chord slots re-composing "(⌘⇧D)" / "(⌥⌘⇧D arranges them differently)" exactly) — **PENDING the finals** (the zero-test-edit suite is the proof). One fix during the build: the Mac half is `nonisolated extension` (the Mac target's default isolation is the main actor; the pre-hoist enum was `nonisolated`) |
| Commit 2 — PINS red-first: the §4.4 tripwire over the shared file + the convergence pins (Mac + phone) + the sanctioned edits S-1 · S-2 · S-3, each run RED on commit 1 | IN-PROGRESS — written and committed (this commit): `VariorumTests/OpsRefusalTableIntegrityTests.swift` (the ban over `Shared/OpsRefusalTable.swift`'s literals, both platforms' vocabularies by name + the bite test), `VariorumTests/RefusalTableConvergenceTests.swift` (6), `VariorumMobileTests/MobileRefusalTableTests.swift` (5); **S-1** `SavepointSealedDoorTests.writesDoorRefusesASealedNoteBeforeOpeningTheField` (literal → "…unseal it first."), **S-2** `TutorialWalkTests.theSealRefusesOutLoudAndTheToastShowsIt` (literal → "…unseal it first."), **S-3** `MobileWholeBlockDeleteTests.aRunCoveringANotYetArrivedBlockRefusesAndSaysWhy` (expectation → the shared `.unsyncedBlock` sentence) — **DONE, RED IN THE PREDICTED SHAPE on commit 1's production code** (`e596b275` + a compile fix in this commit: a closure with its only `try` inside `#expect` is inferred non-throwing — the store read hoisted to a statement). **Mac:** `RefusalTableConvergenceTests` **6/6 RED** (26 issues across the run: the table's seal line; Write's error voice ≠ the table on 12 of 15 errors — every disagreeing case, the four Write-only cases, both fallbacks — green on the 3 already-shared ones; the 7 gained words; the typing gate "unlock it to edit"; both siblings; FORK L at ⌘⇧A AND at Write's E5); **S-1 RED** (1 issue — "unlock it first"); **S-2 RED** (`TutorialLibraryActsTests`, 1 issue — "…to change takes or choices"); `OpsRefusalTableIntegrityTests` **2/2 GREEN** (an integrity guard: the hoist moved only platform-free words, and the bite test found both platforms' vocabularies in their own homes); the other `SavepointSealedDoorTests` cells green (they compute from the table). **Phone (iPhone 17 Pro sim):** `MobileRefusalTableTests` **3 RED** (the five sites dumped a worded case — 5 issues; the two empty door slots — 2; the crystallizer voice — 2, its non-operation-error line green) **+ 2 GREEN guards** (each site's own fallback; the phone's seal door words); **S-3 RED** (1 issue — the read-only sentence) |
| Commit 3 — the Mac COLLAPSE: `SealedNoteCopy` + the seal slot; `operationMessage` deleted; L-c; the table gains `.bufferChangedSinceGesture` · `.invalidCut` · `.invalidCommentText`; the ceremony trio to the Mac half; the Mac gate + its two siblings through the stem | DONE (this commit) — the Mac pins GREEN: `RefusalTableConvergenceTests` + `OpsRefusalTableIntegrityTests` + `SavepointSealedDoorTests` (S-1) + `TutorialLibraryActsTests` (S-2) **23 tests / 4 suites passed**; generic-iOS ** BUILD SUCCEEDED ** (the phone untouched yet). The four moved Write sentences checked byte-identical to `operationMessage`'s by script against the pre-collapse tree. **One pin corrected in this commit, said out loud:** `writesTypingGateSpeaksTheStemWithItsAct` first TYPED into the sealed note — but a sealed note's view is not editable (`adoptHeader` :798), so AppKit never asks the gate and `statusMessage` stayed nil on BOTH trees (its commit-2 "red" was the wrong red). It now asks the gate itself (`shouldChangeText(in:replacement:)` — the road the belt answers); its red-on-old is owed to the behavioural revert after the fixes (the U2 verify form) |
| Commit 4 — the phone COLLAPSE: `MobileRefusalRoads.swift`; the five switches per § 1-D; the phone gate through the stem; P3 → `.unsyncedBlock`; V | NOT-STARTED |
| Commit 5 — QUESTIONS #159 | NOT-STARTED |
| Step 4 — walk (both voices + the phone's simulator evidence) + finals (touched Mac suites, copy/registry families, the eleven Tutorial suites, the FULL mobile suite vs 649/111, the generic-iOS build) | NOT-STARTED |

### STEP 1 — WHAT THE TRACE FOUND BEFORE ANY TABLE (three brief facts corrected, said first)

1. **`MobileTrashModel` :278 is not a switch.** It is already a one-line forward to the SHARED
   `DeletionRefusal.words(_:act: .putBack)` (`Shared/RecoveryActs.swift`, hoisted at mobile round 2
   batch 4.5b, A1-18 — "the deletion story's refusals, in one home"). That table is ACT-keyed and
   its fallback deliberately KEEPS the enum's name (pinned: `MobileTrashTests
   .theDeletionRefusalsHaveOneHome` asserts `fallback.contains("lockedVariant")`). So of the six,
   **five are real switches; the sixth is already collapsed onto a shared table.** Proposal: leave
   it on `DeletionRefusal` (merging the two shared tables would change both the pinned fallback
   form and the act keying — a design, not a collapse).
2. **The phone has more `OperationError` switches than six.** Outside the charter's named set:
   `MobileEditorViewModel.deleteNoteRefusal` (:1014) and the entry-date arm (:1074) ·
   `MobileQuickNoteCopy.refusal` (`MobileQuickNote` :145) · `MobileTagManager.refusal` (:151) ·
   `MobileTakesBrowserController.refusalMessage` (:582) · `MobileLensesModel.refusalMessage` (:338) ·
   `MobileBlockHistoryModel.refusalMessage` (:510) · catch-arms in `MobileTrashModel` (:140/:160),
   `MobileStarterJournal` (:288), `MobileCreateBook` (:163), `MobileBookDetails` (:155/:174),
   `MobileStars` (:185), `MobileTakesController` (:248). **Proposal: U3 collapses the named five
   (the charter's scope) and ENUMERATES these in row 28's new (c) as the next-touch list** — never
   silently widened.
3. **The sealed-note sentence has far more than four spellings.** The conductor map's four are
   real; the full family, found by grep (production code only), is in § STEP 1-C's seal table.
   Two Mac sites ALREADY speak the converged form proposed below (`ChipRefusals` "This note is
   sealed — unseal it first." · `CommentsPanelCopy.sealed` "…unseal it to change comments."), and
   every phone "locked — unlock it to ⟨act⟩" line already IS that form in the phone's own door
   words — which is the evidence for the proposal.

### STEP 1-A — THE CLASSIFICATION TABLE: `OpsRefusalCopy`'s table (the `enum OpsRefusalCopy` in `Registry/OpsRefusalCopy.swift`, 30 cases + the two fallbacks)

**Scope of "OpsRefusalCopy" (stated because the file holds seven enums):** the hoist is the
`OpsRefusalCopy` ENUM — the `OperationError` → sentence table. The file's six neighbours
(`SegmentationFaceCopy`, `WordTargetFaceCopy`, `TakeStructureCopy`, `BlockSelectionCopy`,
`SplitAtNewlinesCopy`, `CrossBlockEditCopy`) are Mac face copy, not refusal tables, and are dense
with Mac chords (⌘⇧D, ⌘⇧⏎, ⌥⌘Z, ⌘-click) — **STAYS-LOCAL, whole, untouched** (§4.4; and
`SeededBookRestore.failureLine`'s recorded rule that the file "carries Mac chords and Mac-only copy
homes a shared home must not hold" is honoured by moving only what is platform-free).

**Classes:** **SHARED-AS-IS** (no platform word; moves verbatim) · **PARAMETERIZED** (one sentence,
one platform slot — the `fanRoads` shape) · **STAYS-LOCAL** (a platform's own sentence; the Mac
half keeps it beside the forward, the `CrossBlockRefusalRoads` shape).

| Case | Current words (Mac, verbatim) | Class | Why |
|---|---|---|---|
| `.lockedPost` | "This note is sealed — unseal it to change takes or choices." | **PARAMETERIZED** — the seal stem + the platform's DOOR WORDS | "sealed/unseal" names the Mac's door (Seal/Unseal); the phone's door is "Lock Note/Unlock Note". Converged wording is § STEP 1-C |
| `.archivedVariant` | "That take is archived — unarchive it first." | SHARED-AS-IS | no door |
| `.variantNotDeleted` | "That take is already back — it's in the block's fan." | SHARED-AS-IS | no door (noted: `DeletionRefusal` says "That take is already back." — two shared homes, not this unit's to merge) |
| `.purgeTargetNotDeleted` | "Only things in the Trash can be deleted for good — delete it first, and it waits there \(TrashWindow.days) days." | SHARED-AS-IS | Trash is both platforms'; `TrashWindow` is core |
| `.deliberateSavepointNeverPruned` | "That's a deliberate ⌘S savepoint — those are never pruned, in any mode." | **STAYS-LOCAL (Mac)** | names ⌘S; the phone's Trash never lists savepoints (`TrashScope.listedKinds`), so it has no road to this refusal and must not be handed a Mac chord (pinned `TrashPurgeDoorsTests` `contains("never pruned")` rides) |
| `.unsupportedPurgeTarget` | "That isn't something the Trash can delete for good." | SHARED-AS-IS | — |
| `.lockedVariant` | "That take is locked — unlock it or branch a new take." | SHARED-AS-IS | the TAKE lock's door is "unlock" on BOTH platforms (Lock/Unlock Take); the phone's own sites that name its ⑂ road keep their local arm (§ 1-D) |
| `.variantIsChosen` | "The note shows this take — choose another take first, and then this one can go. (If it's the block's only take, it's the block you want to delete.)" | SHARED-AS-IS | — |
| `.variantNotFound` | "That take isn't there any more — it may have just been deleted. The block's History lists deleted takes, with Put back." | SHARED-AS-IS | the phone has Block History with Put back (`MobileBlockHistorySheetView`, PL-14(d)) |
| `.commitNotFound` | "That saved moment isn't there any more." | SHARED-AS-IS | — |
| `.versionLinkNotFound` | "These two notes aren't marked as versions — nothing to unmark." | SHARED-AS-IS | — |
| `.postsAlreadyVersionLinked` | "These two notes are already marked as versions of each other." | SHARED-AS-IS | — |
| `.postHasNoBlocks` | "There's nothing in that note yet — write a line in it first." | SHARED-AS-IS | — |
| `.readingNotDeleted` | "That book is already restored — it's back on the shelf." | SHARED-AS-IS | the phone has a shelf |
| `.readingNotFound` | "That book can't be found — it may have been deleted, or removed on another device." | SHARED-AS-IS | — |
| `.invalidExtent` | "A word target or note cap must be a positive number — nothing was changed." | SHARED-AS-IS | — |
| `.invalidTint(v)` | "“v” isn't a colour — a colour is six hex digits, like B9A7E6 or #8A7A3A. Nothing was changed." | SHARED-AS-IS | — |
| `.fannedBlock` | "This block has more than one take now — divide it again and the take you're in splits while the others stay on the first block (⌥⌘⇧D arranges them differently)." | **PARAMETERIZED** — an optional ARRANGE ROAD | the parenthetical is a Mac ceremony chord; the phone never replicates ceremonies (her exclusion) → the phone passes `nil` and the sentence ends at "first block." (the `deletedRegionExplainer(purgeRoad:)` precedent). The stem is true on the phone (keep-on-top is both platforms' default, U-2) |
| `.starLimitReached(n)` | "You can star n things at a time — un-star one in the Starred list at the top of the sidebar, and this can take its place." | **STAYS-LOCAL (Mac)** | names the Mac sidebar's list; the phone's star door words it itself (`MobileStars` :185, outside the six) |
| `.duplicateBookName` | `BookNameCopy.refusal(existing:)` | SHARED-AS-IS | already `Shared/BookNameCopy` |
| `.blockCarriesUnshownText` | "That block isn't empty after all — it carries a take or a comment that isn't shown here. Nothing was deleted." | SHARED-AS-IS | byte-identical in `operationMessage` |
| `.lastActiveVariant` | "This block has only one take — a take moves out when there's another one left behind. Divide the block instead (⌘⇧D)." | **PARAMETERIZED** — an optional DIVIDE CHORD; **and its WORDS are a fork** (§ 1-B row L) | "(⌘⇧D)" is a Mac chord; the phone passes `nil` |
| `.emptyTakeCannotBecomeABlock` | "That take is empty — there's no text to become a block." | SHARED-AS-IS | — |
| `.noConvertibleTakes` | "This block has no other takes with text in them — nothing to turn into blocks." | SHARED-AS-IS | — |
| `.blockNotFound` | `BlockSelectionCopy.blockGone` ("One of the blocks you picked … pick again and retry.") | **STAYS-LOCAL (Mac)** | ⌘-click PICK vocabulary — the phone's own comment says so (`MobileStructural`: "⌘-click vocabulary this phone has no door for"); `BlockSelectionCopy` is Mac-local |
| `.blockNotPlaced` | "That block is no longer in this note — it may have moved while you worked. Nothing was changed here." | SHARED-AS-IS | — |
| `.blocksNotAdjacent` | "Something sits between these blocks — a block that hasn't arrived yet, or one that landed since you selected. Nothing was changed." | SHARED-AS-IS | (the phone's own arm keeps "paragraphs" + its `nothingWas` slot — § 1-D) |
| `.noRenderableVariant` | "That block has no text here yet — it may still be arriving from another device. Nothing was changed; try again in a moment." | SHARED-AS-IS | — |
| `default:` (OperationError) | "Refused: \(error)" | SHARED-AS-IS (the table's fallback) | see § 1-E's `words(for:)` split — each phone site keeps ITS fallback |
| non-`OperationError` | `String(describing: error)` | SHARED-AS-IS | — |

### STEP 1-B — `EditorViewModel.operationMessage` (:4285), case by case, onto the table

| Case | `operationMessage` (Write's voice) | vs the table | Disposition proposed |
|---|---|---|---|
| `.lockedPost` | "This note is sealed — unlock it first." | DIFFERS | converges — § STEP 1-C |
| `.lockedVariant` | "This take is locked — branch or unlock it." | DIFFERS (same roads, other words) | **the table's words win** (the charter: deleted "in favour of the table") |
| `.lastActiveVariant` | "A block keeps at least one take — delete the block instead." | DIFFERS — **and each is FALSE at the other's door** | **FORK L below** |
| `.variantIsChosen` | "This take is shown in the note — choose another take first." | DIFFERS (the table's is 13u3 UNIT H's superset) | the table's words win |
| `.archivedVariant` | "This take is archived — unarchive it first." | "That…" vs "This…" | the table's words win |
| `.bufferChangedSinceGesture` | "The text changed while that gesture was landing — nothing was altered; try it again on the current text." | table has NONE (dumps "Refused: …") | **the table GAINS it** (SHARED-AS-IS — no door) |
| `.blockCarriesUnshownText` | = table | identical | rides |
| `.fannedBlock` | = table | identical | rides (PARAMETERIZED with the Mac's road → byte-identical) |
| `.divideSideWouldBeEmpty` | "Every checked take is parked at the same end — one of the two new blocks would have no takes. Split at least one take, or park one at the other end." | table has none | **STAYS-LOCAL (Mac half)** — names the Divide ceremony sheet's controls (checked · parked); ceremonies are Mac-only by her exclusion |
| `.mergedBlockWouldHaveNoTake` | "The merged block needs at least one take — pair takes with ＋, or check “carry” on one." | table has none | **STAYS-LOCAL (Mac half)** — names ＋ and "carry" on the Merge ceremony sheet |
| `.takePairedTwice` | "A take can sit in only one pairing (and a paired take can't also carry) — remove the duplicate first." | table has none | **STAYS-LOCAL (Mac half)** — the ceremony sheet's pairing |
| `.blockNotFound` | `BlockSelectionCopy.blockGone` | identical | rides (Mac half) |
| `default:` | "The operation was refused: \(opError)" | "Refused: \(error)" | the table's wins |
| non-OperationError | "Operation failed: \(error)" | `String(describing:)` | the table's wins |

**FORK L — `.lastActiveVariant`: two Mac sentences for one error, each wrong at the other's door.**
The core raises it from ONE guard (`ensureNotLastActive`) behind three different acts: ARCHIVE
(`archiveVariant` checks no chosen pointer, so ⌘⇧A on a one-take block lands here — pinned
`EditorSessionTests.refusalsSurfaceAsMessages`, `contains("keeps at least one take")`), DELETE
(reached only past `variantIsChosen`), and E5/E6 MOVE-OUT (`takeToBlockBelow` — pinned on the board
by `TakeStructureDoorTests.aRefusalArrivesInWordsNotAsAnEnumDump`, `contains("only one take")`).
`operationMessage`'s "delete the block instead" is wrong for E5 — and TODAY Write's own E5 door
(`moveCaretTakeIntoBlockBelow` → `runStructural` → `showOperationError`) speaks it; the table's
"a take moves out … Divide the block instead (⌘⇧D)" is wrong for ⌘⇧A and the board's Archive.
- **L-a** the table's words everywhere — Write's ⌘⇧A would read a move-out sentence; the
  `EditorSessionTests` fragment pin reds (a sanctioned edit it would need).
- **L-b** `operationMessage`'s words become the table's — the board's E5 refusal regresses to
  "delete the block instead" (the 13e batch-3 sentence written FOR that door is lost).
- **L-c — RECOMMENDED, PROVISIONAL (copy hers):** one act-neutral sentence that names BOTH true
  roads — composed from the two shipped clauses, no new fact:
  *"This block has only one take — a block keeps at least one take, so delete the block instead,
  or divide it (⌘⇧D) to split it into blocks."* (phone: the same with no chord.) True at archive,
  delete and move-out alike; **both fragment pins ride unmodified** (it carries "only one take" —
  E5's fact — and "keeps at least one take" — I10's fact — which are exactly what those pins guard).

### STEP 1-C — THE SEALED-NOTE SENTENCE: the family, and the ONE sentence proposed

**The four spellings the conductor map named (verbatim):**
1. Mac gate (`EditorViewModel.shouldChangeText` :1042 — and the SAME literal at `EditorFind` :373,
   :398 and `EditorSurfaceController` :2508, :2728): *"This note is sealed — unlock it to edit."*
2. Mac `operationMessage` (:4290 — Write's op voice; also the ⌘S door's pre-check :3192, held equal
   by `writesDoorAndFilerSpeakOneSealSentence`): *"This note is sealed — unlock it first."*
3. `OpsRefusalCopy` (:372 — every table consumer): *"This note is sealed — unseal it to change takes
   or choices."*
4. Phone gate (`MobileEditorViewModel.shouldChangeText` :1255): *"This note is locked — unlock it to
   edit."*

**The rest of the family (grep, production code), each with its present standing:**
- Mac, already the proposed form: `ChipRefusals` *"This note is sealed — unseal it first."* ·
  `CommentsPanelCopy.sealed` *"This note is sealed — unseal it to change comments."*
- Mac, the same "unlock"-verb drift as spelling 1 (the two gesture-worded siblings
  `SavepointSealedDoorTests`' doc names): `poolDrop` :3031 *"…unlock it to add to it."* ·
  `RefusalCopy.message(.sealed)` *"…unlock it to restructure."*
- Mac, other shapes: `CanvasViewModel` :803 *"This note is sealed — order stays frozen until it's
  unsealed."* · `ImportModel` :245 *"the destination is sealed — unseal it first"* (a clause).
- **Shared (both platforms' recovery doors):** `DeletionRefusal.words(.lockedPost, .delete)`
  *"This note is marked complete — unseal it first."* · `RecoveryCopy.sealedPutBackRefusal`
  *"This note is marked complete — unseal it to put this back."* — a Mac door verb ("unseal") the
  phone's Trash/Library/Shelf doors speak today.
- Phone, already the proposed form in phone words ("This note is locked — unlock it to ⟨act⟩."):
  the four named-six arms (`MobileBlockMenu`, `MobileComments`, `MobileStructural`, `MobileUndoDoor`
  ("…unlock it first.")), and outside the six `MobileTakesBrowser` (verbs), `MobileBlockHistory`,
  `MobileTakesController`, `MobileLenses.sealedAdoptRefusal`, `MobileStructural` :93/:227/:457/:528.
- Phone, off-form: `MobileQuickNote` :153 *"This note is sealed, so it can't take new text. Unseal it
  in the note to keep writing."* (MAC door words on the phone) · `MobileWriteView.sealedStateLine`
  *"This note is locked — reading only."* (a state line, not a refusal).

**THE PROPOSAL — (a), RECOMMENDED, PROVISIONAL (copy is hers):** ONE stem in the shared table,
each platform's door words local (§4.4 — the phone's door is "Unlock Note", the Mac's "Unseal"):

> **"This note is ⟨sealed⟩ — ⟨unseal⟩ it first."** — the table's act-less line (Mac: *"This note is
> sealed — unseal it first."*; phone: *"This note is locked — unlock it first."*), and a gate or
> gesture that knows its act fills the act slot: *"…unseal it to edit."* / *"…unlock it to edit."*

It is **the canonical table's string with its act clause removed** — and the removal is the point:
"to change takes or choices" names a takes door (R2-1's own record says so), yet the table serves
~20 Mac doors (comments, Canvas order, TOC, savepoints, stars…), and even the Mac tutorial's own
pinned walk shows the clause false at a TAKES door: ⌘S (a savepoint) on the sealed lesson reads
"unseal it to change takes or choices". The door verb follows the Mac's door ("Unseal"), which
spelling 1's "unlock" never matched on the Mac. The form already ships at two Mac sites and at
every phone seal arm, so the phone's words change NOWHERE.
- **(b)** the canonical string verbatim as the ONE sentence — false at Write's typing gate and
  filer and at most table doors; rejected by R2-1's record.
- **(c)** one literal cross-platform sentence *"This note is sealed — unlock it to ⟨act⟩."* (spelling
  1 as the ONE) — the phone's noun changes at ~25 pinned sites, and on the Mac "unlock" names no
  note door.

**The reach, a second small fork:** **R1+ — RECOMMENDED:** the four named spellings (spelling 1's
five literal sites included) + the Mac's two "unlock"-verb siblings (`poolDrop`, `RefusalCopy.sealed`
— zero pins assert them) + the named-six phone arms through the builder (zero words). Everything
else in the family above is ENUMERATED (row 28 (c) + the QUESTIONS row, so her one ruling can
extend the reach) — notably the shared `DeletionRefusal`/`sealedPutBackRefusal` pair, which is the
deletion story's pinned act-keyed table (`NoteVersionsPaneTests` holds `contains("marked
complete")`). **R2:** take the whole family now (more sites, more sanctioned edits, the shared
pair's signature grows a roads parameter).

### STEP 1-D — THE SIX MOBILE SITES, arm by arm (post-collapse shape proposed)

**The collapse rule proposed (P-a…P-c, for the ruling):** (P-a) the table is the default voice of
every refusal a site does not word LOCALLY for a platform reason; (P-b) an arm stays local iff it
names a phone door/road (§4.4) or carries a gesture slot the table has none of (`act`, `nothingWas`,
`bookName` — `DeletionRefusal`'s own rule: *"the ACT decides the sentence, not just the error"*);
(P-c) the table answers `String?` (nil = "I have no words"), so **each site keeps ITS OWN fallback**
for unworded cases — nothing regresses to "Refused: …" where a site had a better form.

| Site | Arm | Class | Post-collapse |
|---|---|---|---|
| `MobileMembershipModel.refusal(_:bookName:)` :174 | `.lockedReading` "“B” is finished — reopen it to change what's in it." · `.readingAtCapacity` "“B” is at its note cap." · `.alreadyInReading` "This note is already in “B”." · `.postNotInReading` "This note isn't in “B”." | STAYS-LOCAL | the `bookName` slot (the table has none); its Mac twin `ChipRefusals` is Mac-local too and names Mac doors ("(its settings)") — the pair is a fork ENUMERATED for row 28 (c), not hoisted here |
| ″ | `default:` "Refused: \(error)" · non-op `String(describing:)` | → table | `words(for: error, roads: .phone) ?? "Refused: \(error)"` |
| `MobileBlockMenuController.refusalMessage(_:act:)` :363 | `.lockedPost` "This note is locked — unlock it to \(act)." | PARAMETERIZED | the ONE seal stem, phone words, `act` — **zero words change** |
| ″ | `default:` `DeletionRefusal.fallback(error)` | → table | `words(…) ?? DeletionRefusal.fallback(error)` (its fallback kept) |
| `MobileCommentsController.refusalMessage` :285 | `.lockedPost` "…unlock it to change comments." | PARAMETERIZED | the stem with act "change comments" — zero words |
| ″ | `.invalidCommentText` "A comment needs some text." | → table (SHARED-AS-IS) | **the table gains it** — byte-identical to the Mac's `CommentsPanelCopy.needsText` |
| ″ | `default:` `String(describing:)` | → table | `words(…) ?? String(describing: error)` |
| `MobileStructuralController.refusalMessage(_:act:nothingWas:)` :886 | `.lockedPost` (act) | PARAMETERIZED | the stem, phone words — zero words |
| ″ | `.lockedVariant` → `MobileEditorViewModel.lockedTakeRefusal` | STAYS-LOCAL | names the phone's takes-sheet ⑂ road (parity C4a) |
| ″ | `.invalidCut` "No legal cut spot for that here — cuts land between words, at sentence ends, and at line breaks." | → table (SHARED-AS-IS) | **the table gains it** — byte-identical to the Mac planner's `RefusalCopy(.nothingToDo)`; Mac table consumers stop dumping `invalidCut` |
| ″ | `.blockNotFound` · `.bufferChangedSinceGesture` · `.blocksNotAdjacent` | STAYS-LOCAL | each carries `nothingWas` (and "selected"/"paragraphs", the phone's own gesture words) |
| ″ | `default:` `String(describing:)` | → table | `words(…) ?? String(describing: error)` |
| `MobileTrashModel.refusal` :278 | forward to `DeletionRefusal.words(_:act: .putBack)` | ALREADY ON A SHARED TABLE | **no change** (fact 1 above) |
| `MobileUndoDoor.refusal` :275 | `.lockedPost` "This note is locked — unlock it first." | → table | the table's own `.lockedPost` with phone words IS this sentence — zero words; the arm goes |
| ″ | `.lockedVariant` → `lockedTakeRefusal` | STAYS-LOCAL | the ⑂ road |
| ″ | `default:` `String(describing:)` | → table | `words(…) ?? String(describing: error)` — the Mac's undo door already speaks the table (`ShellActions` :186), so the two undo-failure lines converge |

**The gate lines + `message(for: BlockRangeIndex.Refusal)` (yours to rule — I PROPOSE, not assume):**
the phone's seal gate line joins the stem (zero words; spelling 4 above). The GATE VOCABULARY
function exists twice, byte-identical but for one arm — Mac `EditorViewModel.message(for:)` :4253 and
phone :1874: `.crossesBlockBoundary` (→ `CrossBlockRefusal` with each platform's fan roads) ·
`.readOnlySlot` "This block hasn't fully synced; it is read-only for now." · `.indexDesync` "The
editor lost track of block boundaries — reloading from the store." (all SHARED-AS-IS) · `.lockedVariant`
Mac "This take is locked — branch it or unlock it to edit." / phone `lockedTakeRefusal` (PARAMETERIZED
— the platform's locked-take gate sentence). **Proposal G — optional, recommended because it is zero
words and the same duplication class:** it joins as ONE shared `gateMessage(for:lockedTake:fanRoads:)`
beside the table; both view models keep `message(for:)` as one-line forwards (the pins call
`model.message(for: .readOnlySlot)`). Say no and it stays as is, enumerated in row 28 (c).

**Optional V — the phone's crystallizer error voice** (U2's `reportOperationError`, today
`String(describing:)`) speaks the table (the brief's "your table is what those voices SPEAK"; the
Mac's `showOperationError` speaks it by `operationMessage`'s deletion). Dump → sentence only.

### STEP 1-E — THE WORDS-CHANGE TABLE (every sentence the collapse changes, by the recommended rulings)

| # | Site | Old | New | Why sanctioned | Pin |
|---|---|---|---|---|---|
| W1 | Write's op voice `.lockedPost` (every `showOperationError` door + the ⌘S pre-check) | "This note is sealed — unlock it first." | "This note is sealed — unseal it first." | the seal convergence (C-a) | **SANCTIONED EDIT S-1:** `SavepointSealedDoorTests.writesDoorRefusesASealedNoteBeforeOpeningTheField` — its literal (the equality cell rides: door and filer both speak the table) |
| W2 | the table's `.lockedPost` (every table door) | "…unseal it to change takes or choices." | "…unseal it first." | C-a | **SANCTIONED EDIT S-2:** `TutorialWalkTests.theSealRefusesOutLoudAndTheToastShowsIt` — its literal. (`SavepointSealedDoorTests`' `sealedSentence` and `CommandRoutingTests` :1146 compute from the table and ride) |
| W3 | Mac typing gate (one literal, five sites) | "…unlock it to edit." | "…unseal it to edit." | C-a, spelling 1 | none (the Mac pins read `contains("sealed")` and ride) |
| W4 | `poolDrop`; `RefusalCopy(.sealed)` (R1+) | "…unlock it to add to it." / "…unlock it to restructure." | "…unseal it to add to it." / "…unseal it to restructure." | the same verb drift | none |
| W5 | Write `.lockedVariant` | "This take is locked — branch or unlock it." | "That take is locked — unlock it or branch a new take." | `operationMessage` deleted in favour of the table | none |
| W6 | Write AND the table `.lastActiveVariant` | the two sentences in FORK L | L-c's one sentence (Mac with "(⌘⇧D)") | FORK L | none — both fragment pins ride |
| W7 | Write `.variantIsChosen` | "This take is shown in the note — choose another take first." | the table's | table wins | none |
| W8 | Write `.archivedVariant` | "This take is archived — …" | "That take is archived — …" | table wins | none |
| W9 | Write fallbacks | "The operation was refused: X" / "Operation failed: X" | "Refused: X" / "X" | table wins (neither is a sentence) | none |
| W10 | every Mac TABLE door: `.bufferChangedSinceGesture`, `.invalidCut`, `.invalidCommentText`, the ceremony trio | "Refused: ⟨enum⟩" | the sentences above | the table gains them (dump → words; the J8 enum-dump class) | none |
| P1 | the phone's P3 mapping (`.refuseAwaitingSync`, `MobileEditorViewModel` :1367) — **only if O-1 (a)** | "This block hasn't fully synced; it is read-only for now." | "A block in this selection hasn't arrived yet — nothing was changed. It stays read-only until it syncs." | O-1 | **SANCTIONED EDIT S-3:** `MobileWholeBlockDeleteTests.aRunCoveringANotYetArrivedBlockRefusesAndSaysWhy` — its expectation re-pointed from `message(for: .readOnlySlot)` to the shared `.unsyncedBlock` sentence |
| P2 | the five phone switches' fallback arms | raw dumps / "Refused: X" / "That couldn't be done — X." | the table's sentence for every table-worded case (§ 1-A's SHARED-AS-IS and PARAMETERIZED rows, the phone's roads); unworded cases keep each site's own fallback | the collapse | none (no phone pin asserts a dump — grep-verified) |
| (P3′) | optional V | `String(describing:)` | the table | the error voice speaks the table | none |

**Phone seal lines: ZERO words change anywhere** (they already are the stem in the phone's door words).

### STEP 1-F — O-1 (U1's routed input): the gap-refusal pair

**The words.** One condition — a whole-block run containing a not-yet-arrived block — reads two ways:
Mac (the diagnosis, M7) *"A block in this selection hasn't arrived yet — nothing was changed. It stays
read-only until it syncs."*; phone (the P3 copy arm) *"This block hasn't fully synced; it is read-only
for now."* **And the phone already speaks the Mac's sentence for the SAME gap under another shape** —
a mid-to-mid span over a gap reaches its own diagnosis (P5) and reads `.unsyncedBlock`
(`MobileCrossBlockEditTests` :609 asserts `contains("hasn't arrived yet")`). So today the phone says
two sentences for one condition depending on how the span was drawn.
- **O-1 (a) — RECOMMENDED, PROVISIONAL:** P3 speaks the shared `.unsyncedBlock` sentence (the words
  change at the MAPPING only — `.refuseAwaitingSync`'s one line; U1's route, arm set and order are
  untouched, and `Arm.gapFence`'s own doc hands the words to U3). One condition, one sentence, both
  platforms and both shapes. The gate's `.readOnlySlot` sentence stays for ITS shape (typing into a
  gap slot — "This block…" is true there). Cost: S-3.
- **O-1 (b):** keep both platform-worded (zero edits; the within-phone split stays).
- **The CAUSE-RANKING half — RECORD, do not change (words-about-behaviour):** a run ending on the open
  tail's separator with a gap inside names the TAIL on the Mac (diagnose step 2 before step 3) and the
  GAP on the phone (P3 fires above the diagnosis). Both are true. Changing it means RE-ORDERING or
  RETIRING a declared arm (U1's table — settled ground, not this unit's); under O-1 (a) P3 and the
  diagnosis differ ONLY in this ranking, so the one-line change, if she wants the Mac's ranking on the
  phone, is retiring P3 from `phoneArms`. Goes to the QUESTIONS row as a sub-item, not built.

### STEP 1-G — THE BUILD SHAPE (for the ruling; nothing built)

- **NEW `App/Variorum/Shared/OpsRefusalTable.swift`** (a different basename is REQUIRED: two
  `OpsRefusalCopy.swift` files in one target collide at compile): `enum OpsRefusalCopy` — the shared
  half: `words(for:roads:) -> String?` (nil = no words; P-c) and `message(for:roads:) -> String`
  (`words ?? "Refused: …"` / `String(describing:)` — the table's fallbacks unchanged);
  `struct OpsRefusalRoads` — THREE slots: `seal: SealedNoteCopy.Words`, `divideChord: String?`,
  `arrangeTakesRoad: String?`; `enum SealedNoteCopy` — the ONE stem,
  `sentence(act: String?, words: Words)`, `Words { state, unseal }`. No literal in this file names a
  platform door (the tripwire pins it).
- **`Variorum/Registry/OpsRefusalCopy.swift` keeps its name and its six neighbour enums**; its
  `enum OpsRefusalCopy { … }` becomes `extension OpsRefusalCopy` = the Mac half: `SealedNoteCopy.Words.mac`
  ("sealed"/"unseal"), `OpsRefusalRoads.mac` ("(⌘⇧D)", "(⌥⌘⇧D arranges them differently)"), the Mac-only
  arms (§ 1-A/1-B STAYS-LOCAL rows), and the forward `static func message(for:) -> String` — so **every
  Mac call site (~60) and every Mac pin reads exactly as before** (the `CrossBlockRefusalRoads` shape).
- **NEW `VariorumMobile/Features/Write/MobileRefusalRoads.swift`:** `SealedNoteCopy.Words.phone`
  ("locked"/"unlock"), `OpsRefusalRoads.phone` (no chords). Each target sees only its own words —
  **§4.4 becomes a compile-time fact** (the phone cannot name `.mac`).
- **Commits:** (1) the HOIST — the shared file + the Mac half, **Mac words byte-identical**
  (`.lockedPost` stays a Mac-half arm with today's sentence until (3)), zero test edits both
  platforms, row 28's (c) enumeration; Mac `build-for-testing` + the generic-iOS build. (2) PINS
  red-first — the table-integrity TRIPWIRE (a source walk over `Shared/OpsRefusalTable.swift` with
  `CopyRegisterPinTests.stringLiteralContents`: bans chord glyphs ⌘ ⌥ ⇧ ⌃ ⏎ ⌫ ⎋ and their `\u{…}`
  escapes, "Mac"/"iPhone", the note-seal door words "sealed"/"unseal"/"Lock Note"/"Unlock Note", the
  phone's "⋯"/"⑂"/"takes sheet", the Mac's "sidebar"/"bottom bar"), and the CONVERGENCE pins (Write's
  filer seal == the table's == the stem; Write's ⌘⇧A speaks the table's `.lastActiveVariant`; a phone
  default arm speaks the table for a worded case; P3 speaks `.unsyncedBlock` if O-1 (a)) — each run RED
  on (1). (3) the Mac COLLAPSE — `operationMessage` deleted; the seal stem; the table gains Write's
  shared cases; the gate/sibling lines through the stem; S-1, S-2 named in the commit. (4) the phone
  COLLAPSE — the five switches per § 1-D, the phone gate through the stem, P3 (+ S-3), optional G/V.
  (5) QUESTIONS **#159** (the four spellings + the family quoted; the converged sentence; FORK L;
  O-1 + its ranking sub-item; one line to overturn each). Then the walk, the finals, and the
  convergence reverts AFTER the fixes (the U2 verify form).

**DECISIONS REQUESTED (the architect rules; I build nothing until then):**
1. The seal sentence: **(a)** (recommended) / (b) / (c) — and the reach **R1+** (recommended) / R2.
2. FORK L: **L-c** (recommended) / L-a / L-b.
3. The collapse rule P-a…P-c (esp. P-c: the table answers `String?` so each site keeps its fallback).
4. `MobileTrashModel` stays on `DeletionRefusal` (recommended) — and the six → five-plus-one reading.
5. O-1: **(a)** (recommended) / (b); the ranking half recorded, not built.
6. Optional **G** (the gate vocabulary joins, zero words) and optional **V** (the phone's error voice)
   — yes/no each.
7. The file layout (a NEW `Shared/OpsRefusalTable.swift`; the Mac file keeps its name as the Mac half).

### U3 — THE CLASSIFICATION RULING (orchestrator, 2026-09-29 overnight — the 4E pattern; the settled ground steps 2–4 proceed on)

**The three brief-corrections are ACCEPTED, each verified by this seat against the tree:**
(1) `MobileTrashModel` stays on `DeletionRefusal` (read at :277–:280 — it is already the
shared act-keyed table with its own pins; forcing it onto the ops table would be a second
brain for one question); (2) the phone's wider switch set (grep-confirmed ~10 files beyond
the named six) collapses ONLY at the named sites this unit — the remainder becomes a new
(c) NEXT-TOUCH entry on KnownIssues row 28; (3) the sealed family is wider than the
conductor map's four — the record's full-family quote is the honest base, and the proposed
form ALREADY SHIPS at two Mac sites (`MembershipChip.swift:410`, `ImportModel.swift:245`),
so (a) converges toward an existing form, not an invention.

**The seven decisions, RULED:**
1. **The sealed sentence: (a), reach R1+** — ONE SENTENCE SHAPE, *"This note is sealed —
   unseal it first."*, a door that knows what was blocked filling the act (*"…unseal it to
   edit."*), the platform noun a PARAMETER (the phone keeps *"locked — unlock"*: its shipped
   vocabulary at ~25 pinned sites, and §4.4's spirit — the noun rides the platform's own
   doors). R1+ = the four named spellings + the two unpinned Mac siblings; the family's
   remainder is listed in row 28's (c) entry, next-touch. PROVISIONAL whole — the QUESTIONS
   row offers (b) the canonical string verbatim and (c) one noun everywhere (the ~25-site
   cost stated) as her one-line flips. The S-1/S-2 pin edits are SANCTIONED by this ruling,
   named one by one in the record.
2. **FORK L: L-c** — one sentence naming both real ways out, the divide chord a Mac-local
   parameter slot; it repairs a real wrong-door case (Write's move-take-out door speaking
   "delete the block instead"). In the words-change table; PROVISIONAL in the QUESTIONS row
   with both old sentences quoted.
3. **The collapse rule as proposed** — the table answers nothing where it has no words; a
   site keeps its own fallback; an arm stays local only for a door-name or a context the
   table lacks. §4.4 by construction; no "Refused: …" regressions.
4. **Confirmed** (correction 1).
5. **O-1: (a)** — the phone's gap-fence arm speaks the shared "hasn't arrived yet" sentence
   (P3 is a declared COPY arm — changing its words is exactly its nature; U1's arm set and
   order untouched). S-3's pin edit SANCTIONED. The tail-vs-gap CAUSE-RANKING half is
   RECORDED in the QUESTIONS row, not built (it would retire an arm — U1's settled ground).
6. **G: YES** (the gate refusals join as one shared function, wording unchanged, the
   locked-take line per-platform). **V: YES** (the phone's U2 error voice speaks the table
   instead of dumping `String(describing:)` — a raw error dump is not a face; the change
   rides the words-change table; the host's error-voice member itself is untouched — the
   change is inside the phone's conformance).
7. **The file layout as proposed** (`Shared/OpsRefusalTable.swift` + the Mac file keeping
   its name as the Mac half + `MobileRefusalRoads.swift`), with ONE condition: the
   compiler-enforced placement does NOT retire the SOURCE-WALK TRIPWIRE PIN over the shared
   file — a chord or door word can sneak into a shared STRING without a compile error; the
   §4.4 ban pin lands as briefed, over the shared file's text, banning BOTH platforms'
   door/chord vocabularies by name.

**Sizing, said out loud:** the ruling holds U3 at the named sites + R1+; the family remainder
and the extra switches are row-28 next-touch entries, never silent scope growth. The five
planned commits stand (hoist → tripwire + red-first convergence pins → Mac collapse → phone
collapse → QUESTIONS row); walk, finals, and the convergence reverts after the fixes (the U2
verify form). **Proceed.**
