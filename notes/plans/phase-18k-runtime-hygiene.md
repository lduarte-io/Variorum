# 18k — RUNTIME HYGIENE (was "RUN C")

**STATUS: OPEN 2026-09-25 — kickoff; the ledger below is the plan; LIVE STATUS is the truth.**

An 18 entry run under `/architect-phase` with the RUN A discipline (one roster, each item
independently scoped, cast, run and closed). **18k's items are its OWN (C0–C6) — her 2026-09-22
letters ruling: no 17 letters are minted for them.** The kickoff is KICKOFF 1 in
`notes/plans/post-13u-health-rounds.md`; the charter is `notes/codebase-health-review-2026-09-21.md`
§5–§7. **C5 is 17e riding this run — `notes/plans/phase-17-standing-fixes.md`'s 17e entry stays the
BINDING record, and C5's dispositions are copied there at close.** This file is the run's ONE
running record (ledger, briefs, records, adjudications, the ladder, the closeout).

**13r is OPEN-BUT-PAUSED beside this run** (her word, 2026-09-25): zero 13r code exists; nothing
here touches distribution, signing or `/Applications` before this run's own closeout refresh.

**Kickoff corrections to the kickoff text (recorded, not silent — each verified at the kickoff):**
1. **The baseline is 13y's finals, not RUN B's.** The kickoff was written 2026-09-22, before 13y ran
   and closed (2026-09-24). 13y's finals (`notes/plans/phase-13y-per-tenant-seq.md` ledger row 13a):
   core **1722/180 ALL PASSED** · full Mac **3089/510 with exactly FOUR issues — four of the five
   adjudicated macOS-27 deltas** (Refont · LibraryPanel-"inspector" · the two NSSlider scrubber pins;
   the fifth, BoundaryFluidity, went green = INTERMITTENT) · iOS **BUILD SUCCEEDED** · mobile
   **642/109 with exactly the 4 known issues**. **Never run the full suite at a session's start —
   these ARE the baseline.**
2. **The install is 13y's, not RUN B's:** `/Applications/Variorum.app` binary sha256
   `9e15f8bfd825aa4f3cf7f3eb076af784ac22047fb641ad159e990b451450ca0e` — measured at this kickoff,
   equal to the 13y deploy checklist's recorded fresh product (custody chain clean). Marker **9**.
3. **KnownIssues row 65 (the FIVE macOS-27 test deltas) is 18k's** — owned here at her 2026-09-22
   order at 13y's kickoff, after KICKOFF 1 was written. It joins as **C6**.
4. **C1 has an EIGHTH acquisition site** the review's §6.1 did not list:
   `Registry/ShellActions.swift:109` — `await session.autosave(forPost: postID).flushNow()` mints a
   coordinator (and its quit registration) for any post it names, only to flush it.
5. **17e's item (11) is already partly discharged:** `CommandRouter.forgetCurrentBlock` HAS a
   production caller since 18d (`RecoveryView.swift:489`, the Mac's Delete Now), and KnownIssues'
   per-note-view-state row (owner 12) carries and ACCEPTS the remainder at its arithmetic. C5's
   disposition records that; nothing is built for it.

---

## THE LEDGER (every row owned; a row closes FIXED-with-named-pin · DISMISSED-AS-HOLLOW · DEFERRED-with-owner · DONE for records)

| Row | Item | Source | Unit kind → acceptance evidence | Cold review seat | Status |
|---|---|---|---|---|---|
| **C0** | Ledger housekeeping (review §7): rows 56/57's DURABLE owner (her confirmation); row 27's stale owner → 13o; row 28's fork list gains the conductor band + the tutorial-seeder scaffolding; file the review's new rows with owners (T2 · StableSurface's asyncAfter · the warming assessment → 12; the EditorViewModel decomposition → 18m; accessibility → the Design & UI review row); the PurgeJanitor split → 18a | review §7; KICKOFF 1 C0 + D1's paragraph | records → the ledger's header rule holds (no blank owner) | — (orchestrator's records) | NOT-STARTED |
| **C1** | The autosave-coordinator registry release — 7 Mac holders + the `ShellActions` flush site mint and never release | review §6.1 | runtime/lifecycle → red-on-old count pin (`openAutosaveCount` / `QuitFinalizeRegistry.count` across open→close) + the dev-store measurement: counts after opening many notes, before/after; the lock/⌘Q finalize walk | Opus (Fable if the diff reaches the editor seam) | **DONE** — FIXED `a8b27b11` |
| **C2** | The inline editor's height binding written inside `makeNSView`/`updateNSView` — MEASURE FIRST (ledger row "The Outline's SHADOW `InlineEditorSurface`", the surviving double realization) | review §5.1 A2 | trace → the instrumented chain on the long-note fixture; the pin is the double-realization count IF confirmed; else the deferral lands as hygiene and the row is NOT claimed | Fable if the seam is touched, else Opus | NOT-STARTED |
| **C3** | The mechanical state-write deferrals (~14 geometry actions, the `BookIndexView` twin first, Canvas's observed geometry writes, window registration WITH the sticky-key ruling) | review §5.1 A3/A4/A5 | hygiene → per-site verdict table (the 13u4 S3 form) + a before/after `Modifying state during view update` count on a bounded run; behaviour byte-identical; walk of Canvas drag + the book Index | Opus | **DONE** — DISMISSED AS HOLLOW (measured; comments only) |
| **C4** | The DEBUG-oracle ownership sweep (owner-keyed registration on the three reference shapes) + the `MarkdownStyling.palette` three-writer comment-plus-pin | review §5.2 | harness → the two-window cross-clear pins per oracle (red-on-old where reachable; structural where teardown order cannot be forced — S2's precedent) | Opus | NOT-STARTED |
| **C5** | 17e's concurrency five (R-18k-1): row 59 Canvas focused-block fact · P26 phone liveness race · P27 ⌘⇧M frozen-projection merge · P33 ⌥⌘Z in-flight latch · P38 backup single-flight latch | 17e + KnownIssues row 59 | runtime/concurrency → red-on-old pins per item (P26 on the MOBILE suite); walks: Canvas select → ⌘K Block History on that block; ⌥⌘Z double-press | Fable (P27 is `EditorSurfaceController`, the seam's pair) | NOT-STARTED |
| **→18o** | The rest of 17e + 17t + row 66 (#138(f) ruled) + row 64 (#136(b) record-only) — a SEPARATE 18 entry run right after 18k (R-18k-1/2/4/5) | the sitting | its own record + ladder | Fable (17t = custody) | NOT-STARTED — opens at 18k's close |
| **C6** | KnownIssues row 65 — the FIVE macOS-27 test deltas: TRACE `RefontViewportTests.aShrinkingRefontKeepsTheLineAtTheViewportTop` (94-pt drift — possibly REAL, the editor seam) and `BoundaryFluidityTests.theKeystrokePathRoutesCrossBlockDeletesIntoTheCompound` (intermittent); RE-MECHANIZE the two `NSSlider` scrubber pins and `LibraryPanelHostTests`' "inspector" reflection pin | ledger row 65 | trace + pin re-mechanization → the full Mac suite reads GREEN (no "modulo"); a Refont fix, if owed, walks on the Copper Beeches fixture (13u4 F2's own walk) | **Fable** (Refont / BoundaryFluidity are the editor seam) | NOT-STARTED |

**Run order:** C0 (orchestrator, first — records only) → C1 → C2 → C3 → C4 → C6 → C5 → the ladder →
the closeout. One `opus-implementer` per unit, fresh, strictly sequential; C3 follows C2 because C2
measures the warning family C3 then sweeps.

---

## THE KICKOFF SITTING (2026-09-25) — her rulings, verbatim-faithful

- **R-18k-1 — C5's scope: a SPLIT into a second 18 entry.** Asked how much of 17e (~13 items) this
  run takes, her words: *"plan a single extra session, split items appropriately between them, give
  it an 18 name."* The orchestrator proposed the split and she confirmed it ("Yes, as proposed"):
  **18k's C5 = the stale-fact / in-flight concurrency class** — KnownIssues row 59 (Canvas reports no
  focused block, so ⌘K "Block History" opens on a stale target) · **P26** (the phone's
  `takeLiveness` grants the pen from a stale continuation — two editors live) · **P27** (⌘⇧M's merge
  threshold reads the frozen `slots` projection) · **P33** (the Mac's ⌥⌘Z has no in-flight latch) ·
  **P38** (`StoreBackup.run` has no single-flight latch). **The extra session is 18o — CORRECTNESS &
  HONESTY SINGLES** (record file `notes/plans/phase-18o-correctness-singles.md`, authored when 18k
  closes): **P23** (CRLF imports as one block) · **P29** · **P32** (false code docs; P32's UX gap
  named) · **P34** (the snap boundary pin + doc) · **P35** (`shelf_pins` self-heal) · **P37** (the
  tray's archived truncation marker) · **17e (12)** (`.toggleSidebar`'s window-kind gate as a
  registry fact) · **KnownIssues row 66** built to her #138(f) ruling below · **17t** (below).
  **18o runs right after 18k, under this orchestrator.** 17e (11) needs no build (kickoff
  correction 5); row 64 / #136(b) is ruled below.
- **R-18k-2 — rows 56/57's durable owner: a new letter 17t, riding an 18.** Her words: *"17t and
  add that to an 18"* — confirmed by the split above: **17t (the two unwired protection doors — the
  Replace-All-Keys typed near-empty confirmation #86(c)/#87, and the recovery phrase's COPY ALL /
  dead "Copied" branch, Mac + the shared enrollment page; the phone's three word-screen doors stay
  the mobile app row's) rides 18o.** The custody Fable rider fires on 18o's ladder.
- **R-18k-3 — the install refresh:** her real-store app was running at the kickoff; her words: she
  will quit it before bed (*"I'll quit it before bed"*). Both 18k and 18o close with the Release →
  `/Applications` refresh behind the A1 rail at that zero-instance window — re-checked by PATH before
  any Release build; if an instance lives, the refresh is HELD, never forced.
- **R-18k-4 — QUESTIONS #136(b), note-scoped structural undo: LEAVE IT FOR NOW** (her pick of the
  recommended option). KnownIssues row 64 stays documented + pinned behaviour; its owner moves from
  17e to **18o** as a RECORD-ONLY disposition (18o re-verifies the pin and records the ruling; no
  build). A future note-scoped undo is a design, at her word.
- **R-18k-5 — QUESTIONS #138(f), cross-device deletion finality at the LAUNCH seeder: HONOR THE
  TOMBSTONE AT LAUNCH** (her pick of the recommended option) — the launch road declines on a
  tombstoned seeded book exactly as the tutorial door's silent ensure already does. Built at 18o
  (KnownIssues row 66), pin-before-fix.
- **R-18k-6 — a note edited INSIDE A BOOK gets its leaving savepoint when she moves to another
  note** (asked from C1's noticed item 3, late the same night; her words: *"a note edited inside a
  book should get a savepoint when you open it"*, clarified at once to the option **"When I move to
  another note"**). Built at **18o** (KnownIssues row filed `4fd19cb6`); Compare peers follow the
  same rule, PROVISIONAL.
- **R-18k-7 — the TCC grants:** she granted Ghostty Accessibility + Screen Recording mid-run; both
  read true without a restart (`AX: true SCREEN: true`), so the held walks run INSIDE this run after
  C5, before the ladder (`notes/handoffs/18k-held-walks-handoff.md` is the walk session's brief).
- **Her standing posture for the night:** *"just bring me the issues now, your session will be
  running overnight"* — every remaining ambiguity is PROVISIONAL-and-continue; anything needing her
  hands (a Touch-ID-gated custody walk, a product call) is HELD and bundled for the morning.

---

## ENVIRONMENT TRAPS (every batch brief carries this section verbatim — the skill's rule; carried from RUN A's, updated for macOS 27)

- **Machine: macOS 27.0, Xcode 26.** Five deterministic suite deltas were adjudicated at 13y's
  kickoff (KnownIssues row 65 — this run's C6); until C6 lands, a full-Mac run reads "green modulo
  those" and any SIXTH red is a finding.
- **Instance checks:** `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH (the test
  host matches mid-run). Real-store instances are identified by STORE, not path — **NEVER quit or
  kill one** (quit-by-bundle-identity is walker law since 13u3's breach); no Release builds or
  `/Applications` refreshes while one lives; the install refresh follows the closeout's walk, at a
  sanctioned zero-instance window (her app quit by HER, never by a session).
- **Builds/tests:** Mac tests run from `App/Variorum/`, suite-level `-only-testing` only; confirm
  the "Test run with N tests" line (Swift Testing COUNTS skipped tests — read the `skipped:` lines);
  `xcodebuild build-for-testing` compiles without the runner; **NEVER add a custom build
  configuration** (any configuration not named exactly "Debug" builds SPM dependencies RELEASE and
  silently strips VariorumCore's DEBUG-gated oracles); zsh `pipestatus` for pipeline exit codes.
- **Suites beside a live session flash the test host's windows** — prefer zero-instance windows for
  timing-sensitive measurements. The flake list (adjudicate by the paired interleaved protocol,
  never a single isolated run): the differential-latency pin · `CanvasDragTrackingTests` ·
  `BlocksWorkbenchFaceTests`' single-click · `BookOutlineLandingTests`' collapsed-story cell (the
  3424 signature) · `ModeSwitchCarryTests`' top-of-Write arm.
- **The keychain drills are OPT-IN suites** (`TEST_RUNNER_VARIORUM_MIGRATION_DRILL=1` and kin) and
  run under throwaway `drill-<uuid>` scopes — never the real scope. The Mac suites write the
  DEV-STORE app's `UserDefaults.standard` (the per-note-defaults class): scrub or use own suites
  where a test reads per-note keys.
- **Walks:** dev-store Debug build only (`io.lduarte.Variorum.debug`), `Tools/WalkKit/` + `cliclick`;
  **READ `Tools/WalkKit/README.md` WHOLE before any walk.** Screenshots in gitignored dirs
  (`notes/plans/18k-screens/`). The Debug domain's `surfaceSize.*` keys may be wiped to stage cold
  runs (they regenerate) — NEVER the real store's. **Settings is NINE PANES with a leading search**
  (720×552 at (200,120)). **⌘[ / ⌘] are OUTDENT/INDENT; back/forward is ⌥⌘[ / ⌥⌘].** The dev
  store's custody posture is whatever she left it in — check at walk time, record honestly.
- **Git:** never `git checkout` over uncommitted work; commit per piece and **PUSH after every
  commit**. **No commit trailers** (her 2026-09-04 rule — no `Co-Authored-By`, no `Claude-Session`).
  **Stage PATHSPEC-LIMITED (`git add <your files>`), never `git add -A`** — the orchestrator edits
  shared records between your commits.
- **Backups:** any act near the real store takes the A1 rail first (WAL-safe, UTC-named) — this run
  never touches it before the closeout refresh.
- **The `-only-testing`-in-a-variable trap:** flags built into a zsh VARIABLE and passed unquoted
  select NOTHING, and xcodebuild prints `Executed 0 tests` **and `** TEST SUCCEEDED **`**. Write the
  selectors literally; the only proof a run happened is `Test run with N tests in M suites` with a
  non-zero N. **`-only-testing:VariorumTests/TutorialWalkTests` selects NOTHING** — the acceptance
  spine is named by its ELEVEN struct names: `TutorialBookShapeTests` · `TutorialDoorTests` ·
  `TutorialWritingActsTests` · `TutorialTakesActsTests` · `TutorialStructureActsTests` ·
  `TutorialLookingActsTests` · `TutorialLibraryActsTests` · `TutorialDeletionActsTests` ·
  `TutorialWherePlacesActsTests` · `TutorialPrivacyChapterTests` · `TutorialFannedMatrixTests`
  (79 tests, 11 suites).
- **Foreground waits:** poll a log with `grep -q '<EXIT LINE>' <log> && break; sleep 5` in a loop,
  repeated past the Bash timeout — never `tail -f | grep -m1` (it hangs once the line has landed),
  never a backgrounded run you end your turn on.

---

## CAST & DISCIPLINE

**Orchestrator: Fable — this session** (writes no feature code beyond adjudication/record acts).
**Implementer: `opus-implementer`, a FRESH session per unit, strictly sequential, one at a time,
ONE unit each.** **Cold review: ONE ladder over the run's COMBINED diff at the end** (fresh reviewer
per round; cap three rounds) — **`fable-reviewer` if the combined diff touches the editor seam
(`EditorTextView` / the `EditorViewModel` storage seam / `PaneSurface` / `BlockRangeIndex` /
`PaneTextAuthority`), custody/keychain, or `Sync/`; otherwise `opus-reviewer`** (R-cor-14: an Opus
cold review always, Fable where the rider fires — expected to fire, because C6's Refont trace lives
on the seam). Cross-model flow when the reviewer is Fable: findings to the implementer side
verbatim, the reviewer makes the final call and implements its confirmed findings itself.

**PIN BEFORE FIX on every item** — trace the mechanism yourself; every bug-class fix lands with a
red-on-old pin verified by BEHAVIOURAL REVERT; a pin green on both sides is DISMISSED AS HOLLOW and
recorded, not fixed. Architectural/hygiene items need no pin but need the traced mechanism and a
written justification. The acceptance spine (the eleven Tutorial suites) rides every unit's closing
run. PROVISIONALs log to `notes/QUESTIONS.md` (next free number **#146** at kickoff — check the end
marker). Author-only calls are hard stops. Units close only on use-shaped evidence of their kind
(the orchestrator spot-checks the record + walks/measures before the record closes); the install
refresh follows the closeout walk.

**Session resiliency (the checkpoint protocol — RESTATED IN EVERY BRIEF):** commit per coherent
piece + push after every commit · the unit record's LIVE STATUS written at the START and flipped in
the same commit as each piece, unverified claims marked PENDING · synchronous foreground waits only
(the grep-poll loop above) · never spawn subagents (ONE Sonnet lookup for external facts only, no
repo reading delegated) · no revert starts until the record names it and the pre-revert state is
COMMITTED · every death and resume noted in the record.

---

## LIVE STATUS (the orchestrator's; flipped at every state change)

- C0 — DONE (`5fea5e81`).
- The kickoff sitting — DONE (R-18k-1…5, above).
- C1 — DONE, ACCEPTED (`a8b27b11`; adjudication below). GUI walk HELD (TCC).
- C2 — DONE, ACCEPTED (hypothesis disproved; deferral as hygiene `6571c558`; shadow row CLOSED as resolved-by `f8610cb9`). GUI walk HELD.
- C3 — DONE, ACCEPTED (premise DISMISSED AS HOLLOW by measurement — all warnings are `PaneSurface`'s, 18l's; comment corrections only).
- C4 — DONE, ACCEPTED (12 oracle types owner-keyed; 13 two-window pins red-on-old; palette guard).
- C6 — DONE, ACCEPTED (row 65 CLOSED; the re-font drift a REAL 27 regression, fixed in `JumpPrimitive`).
- C5 — DONE, ACCEPTED (four FIXED, P26 pinned-already-fixed; dispositions in 17e).
- THE WALKS — IN-PROGRESS (walk session spawned; `notes/handoffs/18k-held-walks-handoff.md`).
- NEXT: the ladder (Fable, one combined diff) → finals → closeout → refresh → 18o.
- Deaths / resumes: none.

---

## BINDING PRINCIPLES — the 13b constitution (P-1…P-9, copied byte-verbatim per the skill; the application notes bind the same way)

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

**Application notes (13b's build record, binding as stated in the skill):** P-1's scope is the
ROUTED vocabulary, grown incrementally (surface-local doors declare `.surface`, never mis-filed).
P-3 keeps TWO deliberate surface kinds (the full-document editor is never absorbed into the pane
surface; both consult the ONE authority and the ONE per-post autosave coordinator —
`AppSession.autosave(forPost:)`; any liveness extension extends the authority's one-live-ring
contract ON the authority). Storage-coupled code lives feature-side; parity refactors keep every
pre-move name as computed forwards/typealiases so every existing pin compiles UNMODIFIED (the 3C
pattern). Every equality-gated sink delivers its stored state AT WIRE TIME; overlay geometry
refreshes trigger on EVERY input axis. The closing form for a recurring fixed class is the sweep
table: instance × host/path, each cell FIXED-with-named-pin or provably SAFE.

**Run-relevant note:** P-8's chrome-`fixedSize` rule is now pinned by construction
(`VariorumTests/ChromeLineLimitTests`, 13u4 UNIT S3) — new chrome this run adds must pass it.

---


## UNIT C1 BRIEF — the autosave-coordinator registry release (self-contained; read in this order)

**You are the C1 implementer (`opus-implementer`), ONE unit, this session only.** Read, in order:
1. `CLAUDE.md` (auto-loaded) — the invariants, testing expectations, no commit trailers.
2. THIS FILE: the kickoff corrections, THE LEDGER (row C1), THE KICKOFF SITTING, **ENVIRONMENT
   TRAPS (binding, verbatim for you)**, CAST & DISCIPLINE, and this brief.
3. `notes/codebase-health-review-2026-09-21.md` §6 (the finding) — a REVIEW record: re-trace every
   claim yourself before acting on it (the hallucination guard).
4. The code: `App/Variorum/Shared/AppSession.swift` (`autosave(forPost:)`, `Hold`,
   `releaseAutosave(forPost:)`, `openAutosaveCount`, `flushExistingAutosave`), the Mac quit/lock
   roads (`QuitFinalizeRegistry`, `Workspace/SavepointOnLeave.swift`, `MacWillLock.swift`,
   `VariorumAppDelegate.swift`), `AutosaveCoordinator.swift`, and every acquisition site:
   `EditorViewModel.swift:49` · `TakesViewModel.swift:59` · `BlockTOCView.swift:36` ·
   `CanvasViewModel.swift:120` · `CompareBoardView.swift:203` and `:327` ·
   `BookIndexEditModel.swift:57` · **`Registry/ShellActions.swift:109`** (the eighth site the review
   missed — kickoff correction 4) — plus the phone's one release (`MobileQuickNote.swift:1031`) as
   the precedent.

**The finding (review §6.1):** every Mac surface takes a coordinator via `autosave(forPost:)` and
none releases, so `postAutosaves` + one `quitFinalize` closure per DISTINCT note touched this session
accumulate forever; every screen lock and every ⌘Q serially walks them all (`savepointOnLeaving` →
an awaited `closeAutoCommit` write per post).

**THE DANGER THAT OUTRANKS THE LEAK — read twice.** `Hold.holders` counts acquisitions, and the
map's one guarantee is ONE coordinator per post (13b 1a's N3; the S3 ladder's BLOCKER). **An
OVER-release (more releases than acquisitions for a post, or a release while another surface still
holds that coordinator) is a TEXT-LOSS class:** the dropped coordinator lives on inside the surviving
surface, that surface's keystrokes go into a coordinator the ⌘Q / lock / `flushEveryOpenPost` walks
can no longer reach, and the next surface to open the note mints a SECOND pipeline that can flush a
stale buffer over a newer one. **Under-release merely keeps today's leak.** So: exactly ONE release
per acquisition, at the owner's genuine end of life (its teardown — `stopObserving`/`onDisappear`/
dismantle, whichever is the site's real end), ordered flush-then-release; sites that acquire more
than once per owner (CompareBoardView has two acquisitions — find out whether they are per-render or
per-lifetime) must pair each. Where a site's lifetime cannot be established cleanly, DO NOT release
there — record it as a named residual (under-release is the safe side). `ShellActions:109` should
prefer `flushExistingAutosave(forPost:)` if its caller only needs a flush (read the 13l LR-MINOR-2
doc on `Hold.holders` — `toggleSeal` was judged fine because its post is open by definition; decide
with the trace, record why).

**Also verify, and pin:** (a) the LEAVING savepoint (13j J11, `SavepointOnLeave`) still lands for a
note closed with unsaved changes — i.e., release never runs before the leaving road has flushed and
savepointed (the conservative `isDirty` refusal is the backstop, not the plan); (b) ⌘Q / lock still
finalize every note that is STILL open; (c) a note opened in two surfaces, one closed, keeps ONE
coordinator the other surface's typing reaches (the N3 pin shape — `openAutosaveCount` stays 1 and a
⌘Q walk flushes the survivor's edit).

**Pins (red-on-old, verified by behavioural revert):** `openAutosaveCount` and
`QuitFinalizeRegistry.count` across an open→close cycle per surface family (old code ratchets; fixed
returns to baseline) + the three verifications above. **Use-shaped evidence (the unit's acceptance):**
on the DEV-STORE Debug build, open and close ~20 notes through Write/Takes/Canvas/Compare/book Index,
then read the two counts (a DEBUG print or oracle you add and REMOVE, or an existing oracle) — before
(on a build of the pre-fix tree) and after — and time a ⌘Q-less finalize walk if cheaply observable
(the lock road via its test seam is acceptable; never lock her real session). Record the numbers.

**Closing runs (tests at the END, never at the start):** `swift test` is NOT needed unless you touch
`Sources/` (you should not); the Mac suites for every touched surface + the pins' suite + the
acceptance spine's eleven Tutorial suites (names in ENVIRONMENT TRAPS), each read by its "Test run
with N tests" line. `AppSession` is SHARED — build the iOS target
(`xcodebuild build -scheme VariorumMobile -destination generic/platform=iOS`) and run the phone's
quick-note suites that exercise `releaseAutosave`. No full Mac suite (the orchestrator runs finals).

**CHECKPOINT RULES (restated, binding from your first commit):** write `## UNIT C1 RECORD` with its
`### LIVE STATUS` at the END of this file in your FIRST commit, and flip it in the same commit as each
piece (`DONE (hash)` · `IN-PROGRESS — what remains` · `NOT-STARTED`); unverified claims marked
**PENDING**. Commit per coherent piece and PUSH after every commit; stage pathspec-limited, never
`git add -A`; NO commit trailers. Synchronous foreground waits only — the grep-poll loop, never
`tail -f | grep -m1`, never a backgrounded run you end your turn on (ending your turn = your death).
Never spawn subagents (one Sonnet lookup for EXTERNAL facts only). No behavioural revert starts until
the record names it and the pre-revert state is COMMITTED; restore with `git checkout -- <file>` of
that commit, verify by `git diff`. Every death/resume noted in the record. If the worktree moves under
you (files you did not change changing), write nothing, report, stop.

**Scope fence:** C1 only. Do not fix C2–C6 items you notice — record them in your record's
"noticed, not touched" list. Zero `Sources/` (if the fix seems to want it, stop and report). Zero
`Sync/`. PROVISIONAL-and-continue for non-gating ambiguity (QUESTIONS from **#146**); stop-and-report
for anything product-flavoured or author-only. **Your final message:** a short summary pointing at
your record — the record is the deliverable.

---

## UNIT C1 RECORD — the autosave-coordinator registry release (implementer: `opus-implementer`, 2026-09-25)

**NOT DONE (first line, per the brief):** (1) the HANDS-ON GUI walk and its captures — HELD: this
session's host (Ghostty) holds neither Screen Recording nor Accessibility, so nothing in this session
tree could capture or drive the app; granting either is the author's (TCC). An in-app scripted walk
on the dev store stands in as the use evidence (below). (2) The full Mac suite — the orchestrator's
finals, per the brief. Everything else the brief asks for is done.

### THE TRACE (done in-session before any pin or fix — every claim re-read at the code)

**T1 — the review's §6.1 claim holds, and is WORSE than stated at three sites.** Every Mac holder
acquires through `AppSession.autosave(forPost:)` (holders += 1) and none calls
`releaseAutosave(forPost:)` — grep-verified: the one production release is the phone's
`MobileQuickNote.swift:1031`. So `postAutosaves` + one `quitFinalize` closure per distinct note ANY
surface touched accumulate for the session; `finalizeAll` (⌘Q, `VariorumAppDelegate`) and
`macWillLock` (every screen lock) walk them all, each `savepointOnLeaving` → flush + an awaited
`closeAutoCommit` write transaction. The per-site shapes:

| Site | Acquisition shape | Real end of life |
|---|---|---|
| `EditorViewModel.swift:49` | ONCE, in `init` (`let autosave`) | the instance's death — see T2 |
| `TakesViewModel.swift:59` | ONCE, in `init` (`let autosave`) | the instance's death — see T2 |
| `BlockTOCView.swift:36` (`BlockTOCViewModel`) | ONCE, in `init` (`let autosave`) | the instance's death — see T2 |
| `CanvasViewModel.swift:120` | **PER ACCESS** — `coordinator` is a COMPUTED property calling `session.autosave(forPost:)`: init, every projection delivery, every settle, every keystroke, teardown | the instance's death (the fix stores it ONCE) |
| `CompareBoardView.swift:203` (`CompareViewModel.coordinator(for:)`) | **PER CALL** — every `anyDirty` check (each projection delivery), every `adopt` settle-closure call (per buffered variant × mounted post), every focus/blur/keystroke | per post: the model's teardown (its cache cleared) or its death |
| `CompareBoardView.swift:327` (`teardown`) | one MORE acquisition per cached token, inside teardown itself | — (the fix reads the cache, acquiring nothing) |
| `BookIndexEditModel.swift:57` | ONCE per post per cache lifetime (`coordinators[postID]`); `teardown` clears the cache and a reused model re-acquires on its next touch (the ladder's R1-8 shape) | per post: `teardown` (cache cleared) or the model's death |
| `Registry/ShellActions.swift:109` (`toggleSeal` fallback) | one acquisition per press, never released, for `router.activePostID` | none — it only FLUSHES; `flushExistingAutosave` is the right door (T5) |

*(Found while building the fix: `CompareViewModel.init` ALSO acquires — `_ = coordinator(for:
anchorPostID)` — and so does `peerSlots.didSet` for every picked peer on every mutation; so
Compare's discarded eager twins acquire too, which is why its release lives in `deinit` as well as
at `teardown()`.)* The per-access/per-call sites mean the holder count for a Canvas- or Compare-touched post climbs by
hundreds in minutes; nothing today reads it, but a release there without first making the
acquisition single would be meaningless.

**T2 — why "the teardown" is NOT the genuine end of life for the three init-acquirers.** Every host
builds its model EAGERLY in the view's `init` (`EditorView.swift:75`, `TakesBoardView.swift:140`,
`WriteTakesPanel.swift:83`, `LensesBoardView.swift:128`, `BlocksWorkbenchView.swift:178`,
`ReadModeView.swift:133`, `CanvasView.swift:100`) and hands it to `State(initialValue:)`, whose
argument is evaluated on EVERY re-init of the view struct — SwiftUI keeps the first instance and
discards the rest, which never mount and never see `onDisappear`. Each discarded instance has already
acquired. A release placed in `teardown()` therefore pairs with ONE of N acquisitions and the entry
can never reach zero (a hollow fix), while a second `teardown()` (a host re-appearing the same
`@State`) would release TWICE for one acquisition — the over-release TEXT-LOSS class the brief
names. **The instance's `deinit` is the one point that runs exactly once per acquisition and after
which nothing can record through that instance** — and it runs only after `finalizeWork()`'s /
`teardown()`'s flush Tasks (which hold `self` strongly) have finished, so flush-then-release is
ordered by construction. The repo's precedent for `isolated deinit` is
`MobileFallbackCanary` (`MobileEditorTextView.swift:60`). Controllers hold these models `unowned`
(`EditorSurfaceController:50`, `TakesStructureController:58`, `TakesChoreographer:29`) and
`EditorViewModel` holds its text view `weak` — no cycle keeps them alive (the dev-store measurement is
the empirical check).

**T3 — the registry's ⌘Q/lock registration is doing J11 work a plain release would silently
remove.** The quit closure IS `savepointOnLeaving(postID)` — J11's road 3. For a note the workspace
reports as LEFT (road 1/2, `SavepointOnLeave`), the leaving savepoint lands independently of the
registry, so dropping its entry costs nothing. But three ordinary situations have NO leaving road
before ⌘Q/lock, and today they get their savepoint ONLY because the entry leaks until then:
1. **A still-shown note whose surface is gone** — `RootView.swift:808–826`: "the shell re-creates
   this view whenever the pane stops being live (a split's other pane taking focus, a second window
   becoming key)" and renders `readCheapNote` instead. The note is still shown (not left, so no J11
   savepoint), its editor has unmounted, and a plain release would drop it: ⌘Q/lock would then skip
   a note that is STILL OPEN — brief verification (b) broken.
2. **Notes edited inside a BOOK or as a Compare PEER** — `WorkspaceModel.shownNoteIDs` counts only
   `selections[pane]?.noteID`, and a book selection has none; Compare's peers are not the pane's
   note. Their only savepoint roads are ⌘Q/lock and the 2 h idle backstop — brief verification (a)
   broken for them by a plain release.
3. **The open-tail race on the ordinary road** — navigating away from a note with an uncrystallized
   tail: the workspace spawns the leaving Task at the click, SwiftUI's `onDisappear` spawns
   `finalizeWork` after it, the leaving Task's flush finds nothing pending (tail typing records
   nothing — the tail has no variant), its `closeAutoCommit` enqueues on the serial runner BEFORE
   the finalize's tail `newBlock` → the leaving savepoint misses the tail block, whose take is then
   "never committed and non-empty" (`autoCommitDirtyVariants`' dirty rule). Today ⌘Q/lock catches it
   via the leaked entry; a plain release at the editor's death would leave it to the idle backstop.

**T4 — the fix's shape follows from T2 + T3 (no product call in it).** (i) Every acquisition is made
single and paired with exactly one release at the owner's death (or, for the two per-post caches,
when the cache lets go of that post). (ii) On the Mac the registry drops an entry only through a
**leaving savepoint that LANDED after the last holder let go** — the brief's own condition (a),
"release never runs before the leaving road has flushed and savepointed", made structural rather
than timing luck: a release of a note nobody has left keeps the entry (it still owes its ⌘Q/lock
savepoint — T3 cases 1/2); a release of a note that WAS left re-takes the leaving savepoint (it
flushes first) and drops the entry when that lands (T3 case 3's tail is in it); a leaving savepoint
that begins with nobody holding the note drops the entry when it lands. An acquisition generation
guards both drops against a surface that re-opened the note mid-flight. The phone's release keeps
its 13l L-d behaviour byte-for-byte (`#if os(macOS)` — the phone has no quit registry).

**T5 — `ShellActions:109`.** The seal fallback only FLUSHES before `lockPost`/`unlockPost` (whose
own insurance auto-commits read the rows). The 13l LR-MINOR-2 doc judged it fine because its post is
open by definition — true of the FLUSH, false of the mint: an open post has an entry held by its
surface, so `flushExistingAutosave` flushes the SAME coordinator; where no surface holds one, there is
nothing pending by construction and the mint only buys a permanent holder that would now pin the
entry forever. → `flushExistingAutosave(forPost:)`.

**Recorded consequence (not a product call — the leak's accident, named):** a note the Mac LEFT whose
text is later changed ELSEWHERE (a phone edit arriving by sync) and never re-opened here no longer
gets a Mac ⌘Q/lock savepoint; J11's letter is "every editing session that changed a note", the phone
savepoints its own sessions, and the idle backstop (`IdleCommitScheduler`, every note by
`last_touched_at`) still covers it.

### LIVE STATUS

- Reading (CLAUDE.md canon, this plan's kickoff corrections / ledger / sitting / traps / cast, the
  review §6, `AppSession`, the quit + lock + leaving roads, `AutosaveCoordinator`, all eight
  acquisition sites, the phone's release precedent) — DONE (in-session, this record's first commit).
- The trace (every site's acquisition shape and real end of life; what the ⌘Q/lock registration is
  still doing for J11) — DONE (T1–T5 above).
- Pins (red-on-old) — DONE (`af9041e7`; the lock pin tightened at `732bfa23`): the seam `AppSession.autosaveHolderCount(forPost:)`
  (read-only, no behaviour) + `VariorumTests/AutosaveRegistryLifecycleTests.swift` (two suites,
  16 tests). **Run on the PRE-FIX behaviour (seam only): `Test run with 16 tests in 2 suites failed …
  with 25 issues`** — every count pin RED (Write ×2, Takes, Blocks/Read, Canvas — 7 holds after one
  open, 9 after close; Compare — 6, then 7; the book index — 1 hold never returned; the seal fallback
  — +1 entry +1 ⌘Q closure), the lock pin's count arm RED, the two-surface pin's hold arm RED (2),
  and **the open-tail leaving pin RED — T3 case 3 confirmed empirically**: the old leaving savepoint
  wrote NOTHING for a tail the editor minted on its way out. The pure guards GREEN on old, as they
  must be (the old tree never let go of anything): quit-at-the-latest tail, book-note lock
  savepoint, still-open ⌘Q walk, mode switch, seal-still-flushes.
- The fix — DONE (`a8b27b11`; verified by R1/M1/M2, the in-app walk and the closing runs below):
  `AppSession` (Mac: the entry leaves only through a leaving savepoint that lands after the last
  holder let go — `markLeaving`/`dropAfterLeaving`, the acquisition generation; the last release of a
  LEFT note re-takes that savepoint; a DEBUG `assert` on more releases than acquisitions; the phone's
  release byte-unchanged under `#else`) · `EditorViewModel` / `TakesViewModel` / `BlockTOCViewModel`
  — one `isolated deinit` release each · `CanvasViewModel` — the coordinator stored ONCE (was a
  computed acquire-per-read) + `isolated deinit` · `CompareViewModel` — a per-post cache (was
  acquire-per-call, plus one more per post inside teardown), released after flush at `teardown()` +
  `isolated deinit` for what it still holds · `BookIndexEditModel` — release after flush at
  `teardown()` + `isolated deinit` · `ShellActions.toggleSeal` → `flushExistingAutosave`. The three
  13l L-d Mac pins (`AutosaveRegistryReleaseTests`: the flush-walk, re-mint-once and eight-captures
  pins) let a post go through a `letGo` helper (release, then the leaving savepoint) — their
  assertions' meaning unchanged; the other three untouched. **Run on the fixed tree: `Test run with
  22 tests in 3 suites passed`** (the 16 C1 pins + the 6 L-d pins).
- Behavioural revert (red-on-old evidence) — DONE. **R1** (the eight production files from
  `af9041e7` over the fix `a8b27b11`): `Test run with 22 tests in 3 suites failed … with 25 issues` —
  byte-for-byte the pre-fix picture (every count pin red, the open-tail leaving pin red, the lock
  pin's and the two-surface pin's count arms red; the L-d suite and the pure guards green); restored
  by `git checkout a8b27b11 -- <files>`, `git diff` empty. **M1** (the Mac's release drops like the
  phone's — no leaving gate) on the fixed tree: `Test run with 16 tests in 2 suites failed … with 8
  issues` — the open tail (both forms), the book-note lock savepoint, the still-shown note's ⌘Q
  savepoint (B), the mode switch (a DIFFERENT coordinator after the switch), and — incidental, and
  worth having — Compare (a release that finds its coordinator mid-flush is refused and nothing ever
  retries it; the fix's re-run savepoint flushes first) and the book index (the entry dropped
  although the note still owes its savepoint). The lock pin passed M1 BY TIMING (its surface had not
  released before the walk's snapshot) → tightened to wait for the release first (`732bfa23`) and
  re-run under M1: RED, as it must be. **M2** (the release drops the entry whatever other holders
  remain — the over-release shape): `Test run with 7 tests in 1 suite failed … with 9 issues` — all
  seven guards red, and the two-surface pin shows the brief's TEXT-LOSS class in the flesh: the
  survivor's typing was NOT reached by the ⌘Q walk (`working_text` still "One."). Both mutations
  restored the same way; `git diff` empty (`git status` clean).
- Dev-store before/after measurement — DONE, as an IN-APP scripted walk (the GUI walk is HELD — see
  "WALK" below). Two DEV-STORE Debug builds (`io.lduarte.Variorum.debug`), each carrying the same
  temporary DEBUG instrumentation (NSLog probes on every acquire / mint / release / drop, on every
  `EditorViewModel` init / deinit, and an env-gated driver) — PRE = a worktree at `af9041e7` (pins +
  seam, pre-fix behaviour), POST = the fixed tree; the instrumentation was applied only for each
  build and reverted (main tree clean after each; the worktree removed). The driver runs the
  shell's own doors: 20 notes of the dev library, each opened through `ShellRouter.adopt(.post(id))`
  and switched through `CommandRouter.requestMode` twice (all seven note modes, 5–6 times each; 40/40
  steps accepted), navigating away to the next note; then a book; then home (`.shelf`); then it
  reads the counts and times `quitFinalize.finalizeAll()` — the exact ⌘Q/lock walk. **PRE:**
  entries 1 → 2 → … → 20 across the walk; at home **20 coordinators, 20 ⌘Q closures, 137 holds**;
  the finalize walk over them **62 ms** (≈3 ms per note on the encrypted dev store — so hundreds of
  notes after days of use is a lock/quit teardown measured in seconds). **POST:** exactly **1**
  entry while a note is open, at every step; at home **0 coordinators, 0 ⌘Q closures**; the
  finalize walk **0.07 ms**; **96 acquisitions, 96 releases** (every hold given back), 20 drops.
  **T2 confirmed in the running app:** `EditorViewModel` inits 43 (PRE) / 44 (POST) against ≈8–10
  Write mounts in the walk — SwiftUI's discarded eager twins outnumber the mounted editors ~4:1, so a
  teardown-placed release would have left the holds above zero; and inits = deinits in both runs
  (no retain cycle keeps a model alive). Probe logs + the instrumentation script:
  `notes/plans/18k-screens/c1/` (gitignored).
- **WALK — HELD for the author's grant.** This session's host is Ghostty
  (`ghostty → login → zsh → claude`), which holds NEITHER Screen Recording
  (`CGPreflightScreenCaptureAccess() == false`; `screencapture` fails for every window and the whole
  display, which is awake and unlocked) NOR Accessibility (`AXIsProcessTrusted() == false`; a System
  Events call hung on a consent prompt and was stopped). So no capture and no `cliclick` walk were
  possible from any session in this tree tonight; granting either is the author's (TCC). The in-app
  driver above is the substitute evidence; the hands-on walk (open/close ~20 notes by hand, then
  read the counts with a probe) is owed at her word, and captures with it.
- **FOUND ON THE WAY — a pre-existing CRASH, not C1's, not touched (for the orchestrator):** the
  first PRE walk trapped at the TENTH note — `Character.init` "more than one extended grapheme
  cluster" in `EditorCommands.body` (`EditorCommands.swift:780`, the Open strip's `⌘⇧<n>` menu:
  `KeyEquivalent(Character("\(index + 1)"))` over `workspace.openNotes.shown`). Since pre-13u Act 10
  (`a9772471`, 2026-08-31) `shown` is EVERY open note (the tracked cap is 20; `ordinalCap = 9` caps
  only the KEYS in `id(atOrdinal:)`), so the tenth row asks for `Character("10")`. `Character.init`'s
  check is not DEBUG-only — this should trap the Release app too, whenever a window's Open strip
  reaches ten rows (crash report: `notes/plans/18k-screens/c1/open-strip-tenth-note-crash.ips`). The
  driver then closed each left note's strip row (closing a row is not a leaving) to stay under it.
  **CORRECTION (same session, verified at the SDK's `Swift.swiftinterface`):** the grapheme check in
  `Character.init(_: String)` is a `_debugPrecondition` inside an `@inlinable @inline(__always)`
  body, so it is compiled OUT of the `-O` Release app — the sentence above that it "should trap the
  Release app too" is WRONG. What is established: the DEBUG (dev-store) build traps at the tenth
  Open-strip row — every Debug walk and any Debug session that opens ten notes in one window; the
  Release app most likely builds a malformed two-grapheme key equivalent for rows 10+ instead
  (unverified what AppKit then does with it).
- Closing runs — DONE (on the committed fix, the tree clean, zero app instances): **every Mac suite
  in every test file that constructs or drives a touched type** (`EditorViewModel(session:)`,
  `TakesViewModel(`, `BlockTOCViewModel(`, `CanvasViewModel(`, `CompareViewModel(`,
  `BookIndexEditModel(`, `ShellActions(`) **or the registry roads** (`autosave(forPost`,
  `releaseAutosave`, `savepointOnLeaving`, `quitFinalize`, `macWillLock`, `openAutosaveCount`) —
  152 suites selected literally by name, **including all eleven Tutorial acceptance-spine suites**:
  **`Test run with 858 tests in 152 suites passed after 223.410 seconds`**, zero `✘`, zero skipped.
  iOS: **`xcodebuild build -scheme VariorumMobile -destination generic/platform=iOS` → `** BUILD
  SUCCEEDED **`**. The phone suites that exercise the shared registry (`MobileQuickNoteTests` — the
  one production release — `MobileQuickNoteReadFailureTests`, `MobileSavepointOnLeavingTests`,
  `MobileMembershipTests`, `MobileDeletionTests`, `MobileNoteEntryDateTests`,
  `MobileNoteRenameTests`) on the iPhone 17 Pro simulator: **`Test run with 65 tests in 7 suites
  passed`**. No `swift test` (zero `Sources/`). No full Mac suite (the orchestrator's finals).

### DISPOSITION

**C1 — FIXED**, pinned by `VariorumTests/AutosaveRegistryLifecycleTests.swift`:
- the count pins, RED on the pre-fix tree (`af9041e7`) and under R1, GREEN on the fix —
  `writeLetsGoOnceTheNoteIsLeft` · `writeLetsGoWhenItsEditorOutlivesTheLeaving` ·
  `takesLetsGoOnceTheNoteIsLeft` · `blocksAndReadLetGoOnceTheNoteIsLeft` ·
  `canvasHoldsExactlyOneAndLetsGo` · `compareHoldsOnePerPostAndLetsGo` ·
  `theBookIndexHandsBackWhatItTook` · `theSealFallbackFlushesWithoutMinting`;
- the three verifications + the mode switch, GREEN on old (it never let go) and RED under the
  mutations M1/M2 that a wrong release would be — (a) `theOpenTailOfANoteLeftMidParagraphIsIn
  ItsLeavingSavepoint` (also RED on old — T3.3, the tail now lands at the leaving instead of at ⌘Q)
  · `theOpenTailIsSavepointedByQuitAtTheLatest` · `aNoteEditedInABookKeepsItsQuitAndLockSavepoint`;
  (b) `quitStillFinalizesEveryNoteThatIsStillOpen` · `theLockStillFinalizesEveryNoteThatIsStillOpen`;
  (c) `twoSurfacesOnOneNoteKeepOneCoordinatorWhenOneCloses` (M2 shows the text loss);
  `aModeSwitchIsNotALeaving`; parity `theSealFallbackStillFlushesAnOpenSurfacesTyping`.
- `ShellActions:109` (kickoff correction 4) — FIXED with the same suite's seal pin.
- The 13l L-d Mac pins (`AutosaveRegistryReleaseTests`) — ADAPTED, not weakened: three pins let a
  post go through `letGo` (release, then the leaving savepoint), every assertion unchanged in
  meaning; the phone's release rule is byte-unchanged (`#else`).
- A DEBUG `assert` now stops the world on more releases than acquisitions for a post (the text-loss
  class the brief names) — a guard, not a behaviour; nothing in the 858 + 65 tripped it.

**Named residuals (recorded, bounded, all on the SAFE side — an entry kept, never one dropped early):**
1. **Book and Compare-peer notes stay registered until a leaving savepoint lands for them** — the
   ⌘Q/lock walk, which now DROPS every note it savepoints with nobody holding it, or a workspace
   leaving if the note is also a pane's. So the registry resets at every lock, but between locks a
   book-heavy session still walks the book notes it touched (today's behaviour for them, exactly —
   the ⌘Q/lock savepoint is their ONLY leaving road; see noticed item 3).
2. **An entry the lock walk could not savepoint** (the store closing under it) stays until the next
   leaving or walk — bounded by the notes open at the lock.
3. **A savepoint racing an in-flight multi-variant flush** (pre-existing: `closeAutoCommit` can land
   between a batch's per-variant writes) leaves the entry dirty at completion → kept, so ⌘Q/lock
   still reaches the second variant's text. Nothing new; the release makes it no worse.

**Recorded consequence** — as T5's paragraph above: a note the Mac LEFT, later changed elsewhere and
not re-opened here, no longer gets a Mac ⌘Q savepoint (J11's letter; the idle backstop covers it).

### NOTICED, NOT TOUCHED (C1's scope fence)

1. **A pre-existing DEBUG-build crash — the tenth Open-strip row** (`EditorCommands.swift:780`;
   full note under "FOUND ON THE WAY" above; crash report in `notes/plans/18k-screens/c1/`). Needs
   an owner (a one-liner — key only the first `OpenNotes.ordinalCap` rows — plus a red pin that
   mounts the menu with ten open notes). Every Debug walk that opens ten notes in one window hits it.
2. **The phone's editor has the same leak class**: `MobileEditorViewModel.swift:187` acquires and
   never releases (the phone has no quit registry, but `flushEveryOpenPost` walks every entry at
   each filing and background flush). The mobile app row's (or its catch-up's).
3. **A pre-existing J11 coverage question for the author:** a note edited INSIDE a book (or as a
   Compare peer) is never reported LEFT — `WorkspaceModel.shownNoteIDs` counts only a pane's own
   note — so its leaving savepoint arrives only at ⌘Q, the lock, or the 2 h idle backstop, never
   when she leaves the book. C1 preserves that exactly; whether leaving a BOOK should savepoint
   the notes edited in it is hers.
4. **The walk tooling's grant note is stale for this host**: `Tools/WalkKit/README.md` says
   Accessibility is granted to "the terminal host" — true of whichever host earlier walks used,
   false of Ghostty tonight (no Accessibility, no Screen Recording). Worth one line in the README
   and her one-time grant if walks are to run from Ghostty.
5. `EditorViewModel.teardown()` stops observing the coordinator; a model SwiftUI re-shows after an
   `onDisappear` (same `@State`) stays unobserved (no settle/refusal callbacks) — pre-existing, C1
   neither causes nor fixes it (the model's HOLD stays until its death, so no pipeline splits).
6. A stale worktree `/private/tmp/claude-501/u1-baseline-tree` (prunable, not this session's).

### CAPTURES

None possible (see the first line). The use evidence is the in-app walk's probe logs
(`notes/plans/18k-screens/c1/pre-walk-probe.log`, `post-walk-probe.log`, `pre-walk-crash-probe.log`),
the crash report, and the instrumentation script that produced them (`c1_instrument.py` — apply to a
tree, build Debug, launch the binary with `C1_WALK=1`).
- Deaths / resumes: none.
- **C1 — DONE (implementer), awaiting the orchestrator's spot-check; the hands-on GUI walk HELD.**

### UNIT C1 — ORCHESTRATOR ADJUDICATION (2026-09-25 night; the unit CLOSES here)

**Verified by spot-check, not trusted:** 13 commits `8ae18857`…`77635dd7`, all pushed, **zero trailers**
(grep over every message), tree clean, zero app instances at hand-back (her real-store app is QUIT —
her R-18k-3 promise kept; the closing refresh window is open). Diff scope matches the record exactly
(8 app files + 2 test files; zero `Sources/`, zero `Sync/`). The `AppSession` change was read line by
line: on the Mac an entry leaves ONLY through `dropAfterLeaving`, which requires a leaving savepoint
that LANDED, zero holders, an unchanged acquisition count (a mid-flight re-open cancels the drop), and
a clean coordinator — every arm errs toward keeping. The phone's release rule is byte-unchanged under
`#else`. The over-release text-loss class is PINNED (mutation M2 turns all seven guards red; the
two-surface pin shows the loss). **ACCEPTED — C1 FIXED** (`a8b27b11`; pins `af9041e7`/`732bfa23`,
red-on-old by behavioural revert R1, 25 issues both times). The design choice (drop-through-leaving,
not plain release) goes beyond the brief's letter and is the correct reading of its "verify the
leaving savepoint" clause — the trace found three J11 roads a plain release would have silently cost;
it is flagged FOR THE LADDER as the unit's highest-value review target.

**Use evidence:** in-app scripted walk on the dev store — 20 notes × all seven modes: coordinators
20 → 0, ⌘Q closures 20 → 0, holds 137 → 96-acquired-96-released, finalize walk 62 ms → 0.07 ms. The
**GUI walk + captures are HELD**: this session's terminal host (Ghostty) holds NEITHER Screen
Recording NOR Accessibility, so NO session tonight can drive or capture the app. **This binds every
remaining unit:** use evidence tonight is in-app scripted/harness evidence, recorded as such; the GUI
walks are BUNDLED for her morning (granting Ghostty those permissions is her call — never a session's).

**Hand-back items dispositioned:**
1. **The Open strip's tenth row traps (Debug)** — `EditorCommands.swift:780` builds
   `Character("\(index + 1)")` for every open note; since pre-13u Act 10 (`a9772471`) the strip holds
   up to 20, so "10" is two characters and the grapheme `_debugPrecondition` traps; Release most likely
   builds a malformed shortcut instead. A real defect, pre-existing, recorded with owner **18o**
   (correctness singles — a KnownIssues row filed this commit; pin before fix there).
2. **The phone's same leak** (`MobileEditorViewModel.swift:187`) → KnownIssues, owner **the mobile app
   project row** (18m's hoist touches the phone's conductor; the touch rule may take it earlier).
3. **A note edited inside a book is never "left"** — its leaving savepoint comes only at ⌘Q, lock, or
   the 2 h idle backstop. Behaviour UNCHANGED by C1; a product-shaped question → **her morning bundle**
   (below), not decided.
4. `Tools/WalkKit/README.md`'s "the terminal host has Accessibility" is false for Ghostty → morning
   bundle (the fix is her TCC grant, or a README correction if she moves the walks elsewhere).
5. A model SwiftUI re-shows after `teardown()` stays unobserved — pre-existing, noted for the ladder.
6. A stale worktree at `/private/tmp/claude-501/u1-baseline-tree` — not this run's; left untouched.

## HER MORNING BUNDLE (accumulating; the checkpoint report carries it)

- **QUESTIONS #146** — the signed-out-first phone's sample book (decided PROVISIONALLY at her
  instruction; 18o builds it).
- **TCC for walks:** Ghostty has neither Screen Recording nor Accessibility — every GUI walk of this run
  is HELD for her grant (or her walking it herself); the list of held walks grows below per unit.
  Held so far: C6 (Copper Beeches re-font steps — the line stays at the top) · C1 (open/close many notes; ⌘Q feels instant) · C2 (the eight steps in its record: Sherlock ▸ Outline ▸ *A Scandal in Bohemia*, click in, type, scroll, narrow/restore, the spread view).
- **C1 item 3:** should a note edited inside a book (or as a Compare peer) get a leaving savepoint when
  she leaves the BOOK, the way a note gets one when she leaves the note? Today: only ⌘Q/lock/idle.

## UNIT C2 BRIEF — the inline editor's height binding (MEASURE FIRST; self-contained; read in this order)

**You are the C2 implementer (`opus-implementer`), ONE unit, this session only.** Read, in order:
1. `CLAUDE.md` (auto-loaded) — invariants, testing expectations, no commit trailers.
2. THIS FILE: the kickoff corrections, THE LEDGER (row C2), **ENVIRONMENT TRAPS (binding, verbatim
   for you)**, CAST & DISCIPLINE, the UNIT C1 RECORD's closing section (what changed before you — the
   tree moved; do not re-derive it), and this brief.
3. `notes/codebase-health-review-2026-09-21.md` §5.1 (A2 is your finding; A1/A3 are context — A1 is
   18l's, A3 is C3's, NOT yours) — a REVIEW record: re-trace every claim before acting on it.
4. `notes/KnownIssuesAndTechDebt.md`'s row beginning "The Outline's SHADOW `InlineEditorSurface`
   row is RESOLVED in its ROUTER half" — the surviving double realization (262-block note, the
   representable realizes twice ~40 ms apart; three causes already ELIMINATED by measurement: the
   height publish, the `active` write, `StableSurface` bypassed). Read what 13u2 UNIT B measured —
   its record is `notes/plans/phase-13u2-*.md`'s UNIT B RECORD / TRACE B-1 (grep for "B-1").
5. The code: `App/Variorum/Variorum/Features/Editor/EditorView.swift` — `InlineEditorSurface`
   (`makeNSView` installs a closure that WRITES the `@Binding height` synchronously; `install` calls
   `remeasure()` inside `makeNSView`; `updateNSView` calls `remeasure()` → the binding write happens
   INSIDE SwiftUI's view update; the host's `@State inlineHeight = 24` at `:52`, read at `:123–124`
   in the same body). Contrast the SAME coordinator's storage-notification road, which already defers
   (`DispatchQueue.main.async { self?.remeasure() }`). And `Core/Views/StableSurface.swift` (the 60 pt
   placeholder ceiling, `loaded`), plus the book Outline host that mounts this surface.

**The hypothesis (review §5.1 A2 — UNPROVEN):** a dropped/ignored mid-update binding write leaves the
editor framed at 24 pt → under `StableSurface`'s 60 pt placeholder ceiling → `loaded` never flips →
the near-band decides on a false frame → a SECOND realization. It would explain the surviving double
realization AND why only long notes show it. Note 13u2 UNIT B eliminated the Outline row's publish —
NOT this representable's binding.

**Phase 1 — MEASURE FIRST (the hallucination guard; no product line changes in this phase).** Build
the instrument: DEBUG-only counters/signposts (added, committed as "WIP: probe", and REMOVED before
close) for makeNSView count per mount, each binding write (value, and whether SwiftUI applied it —
read `inlineHeight` on the next body pass), `StableSurface`'s `loaded` flip, and the realization
count. Run it on the row's long-note fixture (a ~262-block note in the book Outline, dev-store Debug
build or a mounted-harness rig — the row's own pins show the harness shape; the Sherlock sample
book's long stories are the dev store's fixture). Record the chain step by step with numbers.
  - **If CONFIRMED:** the red-on-old pin is the double-realization count (or the `loaded` flip) on
    that fixture; the fix follows (Phase 2); the row's surviving half is claimed RESOLVED with the
    numbers.
  - **If DISPROVED:** record exactly which link broke, with numbers. The deferral still lands as
    warning-class hygiene (Phase 2), but the row is NOT claimed — its text is amended with your
    measurement (what is now eliminated, a fourth cause) and the owner stays 12.

**Phase 2 — the fix:** defer the binding write out of `makeNSView`/`updateNSView` exactly as the
coordinator's storage road already does (the pattern is in the file) — a coalescing hop so a burst
of updates reports once, with the `abs(Δ) > 0.5` equality gate preserved. **The overlay/sink delivery
law binds (the constitution's application notes, below in this file):** the FIRST height must still
be delivered — wiring is the delivery — so the deferral must not strand the initial report (a mount
that reports nothing leaves 24 pt forever, which is exactly the bug class). Pin that: a freshly
mounted long note reaches its measured height within N turns. Then measure the
`Modifying state during view update` count on a bounded run touching the book Outline / spread /
pool inline editors, before and after (log grep over one fixed suite set — name it, run it both
sides) and record both numbers.

**Seam note:** `InlineEditorSurface` wires `EditorViewModel.attach` and the storage delegate — the
editor seam's neighbour. Change ONLY the height-report timing; if the fix wants anything in
`EditorTextView`, `EditorViewModel`'s storage seam, `BlockRangeIndex` or `PaneSurface`, STOP and
report (the ladder is Fable either way; the fence is about scope).

**Use-shaped evidence:** this session's terminal host holds NO Screen Recording and NO Accessibility
(C1's finding — do not try to drive or capture the GUI; a System Events call hangs on a consent
prompt). So the evidence is an IN-APP scripted run on the dev-store Debug build (C1's pattern — see
its record: temporary probes, never committed) or a mounted-harness rig: a long Sherlock story in the
book Outline, the inline editor made live, typing, scrolled away and back — the realization count and
the settled height read out. The GUI walk is HELD for the author's morning; write the steps she
should walk into your record. **Closing runs (tests at the END):** the
suites for the book Outline / reading flow / Index / spread / pool inline editors + your pins + the
eleven Tutorial suites (names in ENVIRONMENT TRAPS), each read by its "Test run with N tests" line;
no full Mac suite.

**CHECKPOINT RULES (restated, binding from your first commit):** write `## UNIT C2 RECORD` with its
`### LIVE STATUS` at the END of this file in your FIRST commit, and flip it in the same commit as each
piece (`DONE (hash)` · `IN-PROGRESS — what remains` · `NOT-STARTED`); unverified claims marked
**PENDING**. Commit per coherent piece and PUSH after every commit; stage pathspec-limited, never
`git add -A`; NO commit trailers (no Co-Authored-By, no Claude-Session). Synchronous foreground waits
only — the grep-poll loop, never `tail -f | grep -m1`, never a backgrounded run you end your turn on
(ending your turn = your death). Never spawn subagents (one Sonnet lookup for EXTERNAL facts only).
No behavioural revert starts until the record names it and the pre-revert state is COMMITTED; restore
from that commit, verify by `git diff`. Every death/resume noted in the record. If the worktree moves
under you, write nothing, report, stop. Never touch `/Applications`, never build Release, never quit
or kill the author's real-store app.

**Scope fence:** C2 only (C3's ~14 geometry actions are NOT yours — list them under "noticed, not
touched"). Zero `Sources/`, zero `Sync/`. PROVISIONAL-and-continue for non-gating ambiguity
(QUESTIONS — the next free number is **#147**; check the end marker); stop-and-report for anything
product-flavoured. **Your final message:** a short summary pointing at your record.

---

## UNIT C2 RECORD — the inline editor's height binding (implementer: `opus-implementer`, 2026-09-25)

**NOT DONE (first line, per the brief):** (1) **The row's double realization is NOT claimed.** The
review's hypothesis that this binding caused it is DISPROVED (M4), and the double no longer reproduces
on today's tree; it was removed by `f8610cb9` (13u2b UNIT 1, bisected), not by C2. The KnownIssues row
is AMENDED, not closed. (2) **The hands-on GUI walk and its captures are HELD**: this session's host
holds no Screen Recording and no Accessibility grant (C1's finding). An in-app scripted walk on the
dev store stands in, and her walk steps are listed below. (3) The app-side double was not bisected in
the app, because an old build must never open the dev store. (4) No full Mac suite (the
orchestrator's finals), no `swift test` (zero `Sources/`), no iOS build (zero `Shared/`; the only
production file touched is the Mac target's `EditorView.swift`). Everything else the brief asks for
is done.

### READING (done in-session before any probe)

CLAUDE.md + canon (auto-loaded); this file's kickoff corrections, ledger row C2, ENVIRONMENT TRAPS,
CAST & DISCIPLINE, the C1 record's close + adjudication, and the C2 brief; the health review §5.1
(A2, with A1/A3 as context); KnownIssues' "SHADOW `InlineEditorSurface`" row; 13u2's UNIT B record +
TRACE B-1 (`notes/plans/phase-13u2-feel.md`); `EditorView.swift` (`EditorView`, `InlineEditorSurface`
and its coordinator), `Core/Views/StableSurface.swift`, the two inline hosts (`BookView.swift`'s
`OutlinePostRow` live branch, `SpreadBookView.swift`'s active page), and the harness shapes
(`InlineEditorWindowTests`, `ProseGutterTests`, `BookOutlineLandingTests`, `EditorRouterActiveTests`).

**A fact on the record BEFORE measuring (the hallucination guard, read at the source):** the review's
premise that "the 13u2 trace eliminated the Outline row's publish, NOT the representable's binding"
does not match TRACE B-1 as written. B-1's eliminated cause 1 IS this binding: *"`Coordinator.install`
ends in `remeasure()`, which writes `EditorView`'s `@State inlineHeight` inside `makeNSView`, and
`updateNSView` does it again … Deferred both to the next runloop turn: still doubled."* And B-1's
cause 3 bypassed `StableSurface` entirely ("still doubled") — which is the chain's second link. So
the hypothesis enters this unit already contradicted by one prior measurement; Phase 1 re-measures it
independently rather than trusting either record. (Also on the record: `BookOutlineLandingTests`'
13u2 A2 comment says the REAL APP mounted once, B-1 says twice on a LONG note — the two are
reconciled by B-1's long/short finding; A2's walk may have used a short note. Not re-litigated here.)

**The hosts, counted:** `inline: true` has exactly TWO hosts today — the book Outline's focused row
and the spread's active page. The brief's "pool inline editor" no longer exists as an inline host
(Canvas/the scraps area mount the full-document `EditorView`, `CanvasView.swift:1103`).

### THE MEASUREMENT (Phase 1 — every number from a run in this session)

**The instrument** (`WIP: probe`, `d599539b` + this commit): per realization — `makeNSView` /
`updateNSView` / `dismantleNSView` counts; every binding write with its PHASE (`make` · `update` ·
`storage`), the value the closure's binding READ, the value written, and whether the gate let it
write; the host `EditorView` body's `inlineHeight` on every pass (did SwiftUI apply the write?);
`StableSurface`'s reports, `loaded` flip and settle; every near-band decision; the Outline row's
live-branch body; each text view's window-ness at +0.05/+0.5/+2 s (B-1's orphan discriminator).

**M1 — the dev store, today's tree (in-app driver, the Sherlock book, *A Scandal in Bohemia*, 262
blocks; a 3-block note as the control).** Two runs, two gestures: focus straight from a collapsed
card (walk 1, `notes/plans/18k-screens/c2/walk1-pre-fix.log`), and B-1's OWN gesture — expand
read-cheap first, then a focus WITH a caret, the read tier's click road (walk 2,
`walk2-pre-fix-expand-then-click.log`). **Every focus realized ONCE: 3 of 3 long-note focuses, 3 of 3
short** — `makes=1`, `dismantles=0`, the one text view in a window at +0.05 s and still at +2 s with
all 262 entries, `active == editing` on it. Typing 5 keystrokes and deleting them, scrolling the
23,601-pt column away and back: still one realization. The chain, link by link (walk 2, the long
note, the remembered size `696×20993` present):

| t (ms) | event | what it shows |
|---|---|---|
| +3091.9 | `make #1`, binding 24 | one realization |
| +3092.8 | write `phase=make` 24 → 24, **wrote=false** | the mount-time write writes NOTHING: no projection yet (`entries=0` at +0.05 s) — nothing to drop |
| +3093.2 / +3118.5 | write `phase=update` 24 → 24, wrote=false (×2) | same |
| +3096.7 | `StableSurface` report h=24, `loaded=false`, **reserved=20993** | the reservation holds the row at its remembered 20,993 pt — the column never sees 24 pt |
| +3231.0 | write **`phase=storage`** 24 → 20993, WROTE | the first real height arrives through the ALREADY-DEFERRED storage road |
| +3236.7 | body `inlineHeight=20993` | SwiftUI APPLIED it (link 1 of the hypothesis breaks here: no dropped write) |
| +3237.4 | write `phase=update`, closure's binding READS **24**, new 20993, **wrote=true** → `[SwiftUI] Modifying state during view update` | the ONE warning: a REDUNDANT re-write of a height the state already holds, because the binding captured at `makeNSView` reads stale inside a view update |
| +3238.9 | `StableSurface` loaded FLIP (reached) | `loaded` flips (link 2 breaks: nothing is stuck under the 60-pt ceiling) |
| +4242.5 | settled at 20993 | |

Without a remembered size (walk 1's first long focus, `known=nil`): `loaded` flips at +101 ms on the
24-pt report (`reached` is true with no memory), the real height lands via the storage road at
+236 ms — same single realization.

**M2 — the mounted harness, today's tree** (`BookOutlineLandingTests`, the row's own harness shape,
probes armed via `TEST_RUNNER_C2_PROBE=1`): **8 realizations for 8 focuses** across the suite's 8
tests (the multi-story test's makes each pair with a dismantle as focus moves) — NO double, including
`aChapterRevealLandsAtTheChapterWithAStoryExpandedAndLive`. **20 `Modifying state during view update`
warnings in the run, and every one of the 20 immediately follows this representable's
`updateNSView`-phase write that WROTE** (log interleave, `DerivedData/18k-c2-harness1.log`): the
harness's first real height often arrives through `updateNSView` before the storage hop, and the
stale captured binding re-writes it on the next update.

**M3 — THE CONTROL: the instrument on TRACE B-1's own tree** (`cfe53bb5`, a scratch worktree, a
minimal make/dismantle/window probe, an in-memory store only — an old build never opened the dev
store): `aChapterRevealLandsAtTheChapterWithAStoryExpandedAndLive` **DOUBLES** — two makes back to
back, and at +0.3 s one text view in a window and one alive but window-LESS: B-1's orphan, exactly.
So the instrument sees the double where it existed, and today's tree does not have it.

**M4 — THE HYPOTHESIS TESTED DIRECTLY, on the tree where the double exists:** the B-1 tree with EVERY
synchronous height write deferred to the next turn (install's first report, `updateNSView`'s, and the
then-extant decoration lane's second pass), run twice: **the double REMAINS in 2 of 2 runs** (two
makes, the window-less orphan at +0.3 s) **while the suite's `Modifying state` warnings go 18 → 0.**

**VERDICT — DISPROVED, link by link:** (1) no write is dropped — at mount the writes are 24→24 no-ops
because the projection has not arrived, and the first real height is applied by SwiftUI on the pass
after the storage road writes it; (2) `loaded` flips (on reach, or on the 24-pt report when nothing is
remembered) and `StableSurface`'s reservation keeps the column from ever seeing a 24-pt frame; (3) the
causal claim itself fails M4 — removing every mid-update write removes this representable's warnings
and leaves the double untouched. What the binding write DOES cause is exactly one thing, measured:
the `Modifying state during view update` warnings this representable emits (18 of 18 on the B-1
tree's suite, 20 of 20 on today's). **And the double realization itself no longer reproduces on
today's tree** (M1 app 0/3, M2 harness 0/8 including the test that doubles on the B-1 tree) — some
change between `cfe53bb5` and today removed it; C2 did not, and claims nothing for it.

### THE USE EVIDENCE (in-app, dev store, *A Scandal in Bohemia* 262 blocks + a 3-block control; the same driver on both roads)

The gesture set per run: B-1's expand-then-click on the long story and on the short note, a straight
focus of each, five keystrokes typed and deleted, the 23,601-pt Outline scrolled to its end and back,
then the WINDOW narrowed by 260 pt and restored. Frame = the live text view's SwiftUI-driven frame;
content = `PaneMeasurement.height` of it at that moment.

| | PRE-fix road (W-app-B) | POST-fix (the fix) |
|---|---|---|
| realizations per focus (makes / dismantles) | 1 / 0, every focus (4 of 4) | 1 / 0, every focus (4 of 4) |
| `Modifying state during view update` in the whole walk | **10** | **0** |
| binding writes made INSIDE `makeNSView`/`updateNSView` | **18** (6 of them WROTE) | **0** |
| frame vs content after focus, typing, scroll away/back | equal (20,993 · 231) | equal (20,993 · 231) |
| after the window NARROWED | **stranded: frame 20,993 over 20,908 of content** (the update pass measured before its own layout; nothing re-reported) | **equal: 20,993 / 20,993** (the hop measured after the layout, re-reported once as TextKit settled) |
| after the window was RESTORED | frame 20,993 over 20,908 | frame 20,993 over 20,908 — the one miss, identical on both roads |

**Reading it:** the fix removes this representable's writes-inside-an-update entirely (18 → 0) and
with them every warning the walk produced (10 → 0); it changes nothing about realization (the double
does not occur on today's tree on either road); and on the width road it is strictly better — the old
road's update-pass measure read the pre-layout width and stranded BOTH resize steps, the new one
converges on the first and misses only the second. That remaining 85-pt miss is the measurement's,
not the report's timing: the same text at the same width measured 20,993 or 20,908 depending on
layout history (TEXTKIT2 §2's class), and the inline editor has no convergence loop to re-report a
late settle — see NOTICED (it is the pane component's `PanePublisher` heal, which the inline editor
does not compose; not this unit's fence).

### LIVE STATUS

- Reading — DONE (this commit).
- Phase 1, the instrument (DEBUG probes, committed as "WIP: probe", removed before close) — DONE
  (`d599539b`/`3f9b84ea`; **REMOVED** at the commit after `3f9b84ea` — `App/` byte-identical to the
  pre-probe `709bd7bf`, verified by `git diff --quiet`; kept as a patch in the session scratchpad for
  the post-fix in-app run, never re-committed): `C2Probe` (EditorView.swift — makeNSView/updateNSView/dismantle
  counts, every binding write with its phase make|update|storage and whether it wrote, the host
  body's `inlineHeight` per pass, each text view's window-ness at +0.05/+0.5/+2 s), `StableSurface`
  (every report, the `loaded` flip, the settle), `NearViewportObserver` (every decision), the Outline
  row's live-branch body; `C2WalkProbe.swift` — an env-gated (`C2_WALK=1`) in-app driver: short-note
  focus (control) → long-note focus → five keystrokes typed and deleted → scrolled away and back.
- Phase 1, the measurement — DONE (this commit): **DISPROVED**, and the symptom no longer reproduces
  on today's tree — THE MEASUREMENT below. (Probe additions in this commit: a temporary expand door
  and caret-focus door beside the book's DEBUG focus door, for B-1's own gesture; the driver's
  terminate moved off its task — walk 1's synchronous `NSApp.terminate` from inside a main-actor task
  hung in `terminateLater`, and both walk instances were stopped by PID, path verified as the Debug
  product.)
- Phase 2, the deferral — DONE (this commit): `InlineEditorSurface.Coordinator.scheduleRemeasure()` —
  every trigger (the mount's first report in `install`, `viewUpdated` = `updateNSView`'s body, and the
  storage road, now `MainActor.assumeIsolated { scheduleRemeasure() }` — still one hop) schedules; ONLY
  THE NEWEST measures (a generation counter), so a burst reports once, at exactly the point the old
  road's LAST report measured. The binding closure and its `abs(Δ) > 0.5` gate are byte-unchanged; it
  is simply never called inside a SwiftUI update now. `remeasure()` stays synchronous and public (the
  measurement brain's caller the window tests drive). **Design note, measured:** the first version
  used a FIRST-trigger latch; it was replaced before commit because it measures BEFORE any main-queue
  work the burst's later triggers queued — earlier than the road it replaces — while newest-wins can
  never measure earlier than the old road's last report. **Pin-harness facts found on the way (NOT
  this fix's, recorded for the ladder):** TextKit's FIRST full measure after the view enters its window,
  after a width change, or after an edit can differ from the layout a later display pass converges to
  (11,182 → 10,929 with no edit/frame/inset change; 18,713 vs 19,344 after a 700→420 reflow; one 20-pt
  line after three keystrokes) — TEXTKIT2 §2's documented `enumerateTextLayoutFragments` class, in the
  fenced measurement brain (`PaneMeasurement`), identical on both roads; nothing re-reports that drift
  on either. The pins settle layout before the install and allow a line (or a midpoint, for the
  reflow) accordingly — see NOTICED.
- Pins — DONE: GREEN ON THE FIX (`d4ede53b`): **`Test run with 4 tests in 1 suite passed` — 3 of 3
  runs**. **R1 (pre-fix behaviour under the committed pins): `Test run with 4 tests in 1 suite failed …
  with 5 issues`** — the mount reported inside itself (`[10929.0]`), the update pass reported inside
  itself, **and the old road STRANDED the reflowed height: it reported the WIDE 10,929 pt (measured
  before the layout that pass was about to do) while the narrow layout converged to 18,713 pt, and
  nothing re-reported it** (the behavioural red — a mis-sized frame, not only a warning), the burst
  reported twice inside itself and **5** times in all; the whole-road guard green, by design.
  **M-strand: `failed … with 3 issues`** — no first report at all (`[]` against 10,929 pt measured).
  **M-stuck: `failed … with 5 issues`** — incl. the whole-road GUARD: the real `EditorView(inline:)`
  stuck at a **24.0-pt frame over 10,929 pt of content**. All three restored by `git checkout d4ede53b
  -- …/EditorView.swift`, `git diff` empty. The revert and mutations were named before they ran, over
  the committed fix
  `d4ede53b`: **R1** = `EditorView.swift` from the seam commit `48297899` (the pre-fix behaviour, the
  seam kept) under the committed pins; **M-strand** = the fix with `install`'s first
  `scheduleRemeasure()` removed (the mount reports nothing — the delivery law broken); **M-stuck** = the
  fix with only the FIRST generation ever allowed to measure (a latch that never re-arms — the
  stranding a coalescing hop can introduce). Each restored by `git checkout d4ede53b -- <file>`,
  verified by `git diff`. Earlier, **run on the PRE-FIX behaviour (the seam tree `48297899` + this commit's compile
  fixes to the pins): `Test run with 4 tests in 1 suite failed … with 5 issues`** — the mount pin RED
  (`reports == [10929.0]` inside the install), the update pin RED (reported inside the pass), the burst
  pin RED (2 reports inside the burst, **5** in all), the whole-road guard GREEN (as designed); plus
  one arm not designed to be red — the update pin's steady-state precondition (the last report 229 pt
  off the measured height after 20 turns on the old road). **That arm was interpreted after the fix
  ran: it is TextKit's provisional FIRST measure** (11,182 on the report turn, 10,929 one turn later,
  with no edit, frame or inset change), not either road's timing. The pins now settle layout before
  the install, as `mounted()`'s doc records (NOTICED 3). The pins as committed:
  the seam `InlineEditorSurface.Coordinator.viewUpdated(chrome:gutter:on:)` — `updateNSView`'s body
  moved verbatim onto the coordinator (still a synchronous `remeasure()`: behaviour-identical) so a pin
  can drive the update road without a SwiftUI `Context`; `VariorumTests/InlineHeightReportTests.swift`
  (4 tests): the mount reports nothing inside itself and the first height still arrives with NO storage
  edit to prompt it · an update pass reports nothing inside itself and the reflowed height arrives next
  turn · a burst (3 keystrokes + 2 update passes in one turn) reports once · the whole road — the real
  `EditorView(inline: true)` mounted fresh reaches its measured height (a GUARD; its teeth are a
  mutation). No double-realization pin: the double is DISPROVED as this binding's effect and does not
  reproduce today (THE MEASUREMENT).
- The `Modifying state during view update` count, before/after, one fixed suite set — DONE (`5b0cc41e`).
  **The set (16 pre-existing suites, named literally, the same on both sides):** `BookOutlineLandingTests`
  · `BookOutlineRowsTests` · `BookViewTests` · `BookFocusFoldTests` · `OutlineWritingSurfaceTests` ·
  `SpreadBookViewTests` · `NoteBoxGeometryTests` · `NoteBoxCompositionTests` · `BookRedesignMountTests` ·
  `BookOutlineCostTests` · `OutlineRoomTests` · `BookCardHeightStabilityTests` · `EditorRouterActiveTests`
  · `ProseGutterTests` · `InlineEditorWindowTests` · `ReadTierTests`. **BEFORE = the named revert W-B:**
  `EditorView.swift` from the seam commit `48297899` (behaviour-identical to the pre-fix `709bd7bf`)
  over the committed `86b7a5e1`; AFTER = the committed tree. Paired and interleaved (B, A, B, A), zero
  app instances, grep of the xcodebuild log. **RESULT: BEFORE 84 · 85 — AFTER 4 · 4** (`Test run with
  92 tests in 16 suites` every run; logs `App/Variorum/DerivedData/18k-c2-warn-{B,A}{1,2}.log`). The
  4 that remain are other generators (C3's family / A1's publisher — not this representable's).
  **Both sides carried the known macOS-27 delta** `theSpreadKeepsItsBarWithFormsAndTheJumpScrubber`
  (the NSSlider scrubber pin, KnownIssues row 65 — C6's). **AFTER also turned
  `InlineEditorWindowTests.inlineBadgesTrackAWidthReflow` RED (2 of 2; green before 2 of 2) — traced,
  and it is the HARNESS's coupling, not an app regression:** that test's text view is born 600 pt wide
  and its ONLY width-setter is the height-report closure (`frame = (wrapperWidth, height)`), so on the
  old road `install`'s synchronous report widened it to 700 at the mount, and the reload's storage
  edits then laid the text out at 700 (steady 915 pt). With the report deferred, the width first
  changed at the test's explicit `remeasure()` — AFTER the reload — and TextKit's first measure at the
  new width (880 pt, converging to 915 over display passes — the §2 class) became the steady state,
  the ⑂ badge delivered on it (855 vs 890) and nothing re-triggered it. In the app SwiftUI lays the
  wrapper out at its width right after `makeNSView`, before ANY report (the report sets height, never
  width) — so the mount order the old harness got by accident is the app's by construction. **The
  adaptation (this commit): ONE line in the harness setup — `textView.frame.size.width =
  wrapperWidth` at mount, with the reason at the line; every assertion byte-unchanged.** Green on both
  roads (`3 tests … passed`, fixed ×2 and pre-fix ×1). **M-teeth (named here, runs next over this
  commit):** `EditorViewModel.attach`'s `onWidthReflow` handler emptied — the MINOR-2 pin's reflow arm
  must go RED, proving the adaptation left it teeth.
- In-app use evidence — DONE (dev-store Debug, scripted; the GUI walk HELD for TCC): the Phase 1
  probes RE-APPLIED to the working tree by a scratchpad script (`c2_probe_apply.py`, NEVER committed
  this time; the driver gained a frame-vs-content read at every checkpoint and a window resize, narrow
  then back); the SAME driver run on the fix (`walk3-POST-fix.log`) and on the named revert W-app-B
  (`EditorView.swift` from the seam `48297899`, `walk4-PRE-fix-same-driver.log`); the tree restored to
  HEAD after (`git diff --quiet HEAD`, zero probe strings in `App/` outside gitignored logs). THE USE
  EVIDENCE table below.
- A BISECT for the change that REMOVED the double — DONE: measurement only (a scratch worktree, an
  in-memory store, the minimal make/dismantle/window probe; the predicate is the Outline harness's
  chapter-reveal make count). The range: `cfe53bb5` doubles, `709bd7bf` makes once. Nine steps
  (b1f903f4 1 · f3f3a345 1 · 448c4237 1 · c954145c **2+orphan** · 1399b67a 1 · 9206a078 **2+orphan** ·
  f8610cb9 1 · f049af48 **2+orphan** · e6e7abb0 **2+orphan**) → **the first single commit is
  `f8610cb9` — 13u2b UNIT 1**, which replaced the Outline's `LazyVStack` runs of small rows with
  `OutlineRunRow` (expanded notes and the one live editor kept as direct children of the column).
  Confirmed by a repeat run on each side: parent `e6e7abb0` doubles (orphan), `f8610cb9` makes once;
  2 of 2 each. B-1 had caught the second mount inside the LAYOUT pass, and that commit's structural
  change to the column is the lazy-container swap. Nothing about SwiftUI internals is claimed beyond
  that. The app-side double is not bisected in the app (an old build never opens the dev store); it
  predates the commit and is absent today.
- The ledger row amendment — DONE (this commit): `KnownIssuesAndTechDebt.md`'s "SHADOW
  `InlineEditorSurface`" row is AMENDED, NOT CLAIMED. It now records that the double no longer
  reproduces, the fourth eliminated cause (this binding, M4) and the bisect. It **suggests the owner
  close the row as RESOLVED-BY `f8610cb9`**, which is the orchestrator's or 12's call. Owner stays 12.
- Closing runs — DONE (this commit; the committed fix, the tree clean, zero app instances): 61
  suites selected literally: my pins, every suite that constructs or drives `InlineEditorSurface` or
  mounts a book Outline / spread / reading-flow / Index / read-tier / pane-window surface, and **all
  eleven Tutorial acceptance-spine suites**. **`Test run with 330 tests in 61 suites failed after
  195.367 seconds with 1 issue`** — the one issue is `theSpreadKeepsItsBarWithFormsAndTheJumpScrubber`
  (`count(NSSlider.self) → 0`), one of the two NSSlider scrubber pins in KnownIssues row 65's
  macOS-27 deltas (C6's). It failed identically on the PRE-fix side of the warning set (B1/B2), so
  it is not this change's. 60 suites green, all eleven Tutorial suites green, zero skipped. Log:
  `App/Variorum/DerivedData/18k-c2-closing1.log` (the script beside it).
- Deaths / resumes: none.
- **C2 — DONE (implementer), awaiting the orchestrator's spot-check; the GUI walk HELD.**

### DISPOSITION

**The ledger row C2 — the hypothesis DISPROVED, the row NOT claimed, and the deferral LANDED AS
HYGIENE with red-on-old pins:**
- **The review's §5.1 A2 chain — DISPROVED, link by link (THE MEASUREMENT).** No write is dropped at
  the mount (they are 24→24 no-ops before the projection arrives). `loaded` flips. And on TRACE
  B-1's own tree, removing every mid-update write takes the warnings from 18 to 0 while the double
  stands (M4). The KnownIssues row is AMENDED with that (a fourth eliminated cause) and with the
  bisect (`f8610cb9` removed the double). Its owner stays 12, with close-as-resolved-by suggested.
- **The deferral — FIXED as hygiene, and it proved to be more than hygiene.** Pinned by
  `VariorumTests/InlineHeightReportTests.swift` (4 tests):
  `theFirstHeightArrivesOnTheTurnAfterTheMountNeverInsideIt` ·
  `anUpdatePassReportsOnTheTurnAfterItNeverInsideIt` ·
  `aBurstOfEditsAndUpdatesInOneTurnReportsOnce` · `aFreshlyMountedLongNoteReachesItsMeasuredHeight`
  (the delivery guard). Evidence:
  - RED ON OLD by the behavioural revert R1: 5 issues, including a BEHAVIOURAL red — the old update
    pass measured before its own layout and stranded a reflowed frame at the wide height (10,929 pt
    reported against 18,713 laid out).
  - Mutations: M-strand turns the mount pin red (3 issues); M-stuck turns the delivery guard red (a
    24-pt frame over 10,929 pt of content).
  - Warnings over a fixed 16-suite set: **84/85 → 4/4** (the 4 left are another generator's).
  - In the app, same driver both roads: **10 → 0** warnings and **18 → 0** in-update writes; the
    window-narrow step stranded before (85 pt) and converges after.
- **`InlineEditorWindowTests.inlineBadgesTrackAWidthReflow` — its harness ADAPTED, one line, and
  every assertion unchanged.** Traced: the harness's only width-setter was the now-deferred report.
  It is green on both roads, and M-teeth proves it still bites (816 pt, its original number).
- **No PROVISIONAL, no QUESTIONS entry** (#147 unused). The one design choice made in the fix is
  newest-trigger-wins over a first-trigger latch, and it is technical, not product: it never
  measures earlier than the old road's last report did.

### NOTICED, NOT TOUCHED (C2's scope fence)

1. **C3's family, as the review names it** (§5.1 A3/A4/A5): the ~14 un-deferred geometry actions —
   `BookIndexView.swift:791` (the un-deferred twin of the known-correct deferral at
   `BookView.swift:1413`), Canvas's geometry writes into observed storage (incl. the `ForEach`-driving
   `realizedIDs`), and the window-registration/onAppear writes (the sticky-key ruling in
   `WindowRegistry`'s header). Plus what this unit measured of the remainder: the fixed set's last 4
   warnings sit inside `SpreadBookViewTests.aMountedSpreadConsumesTheCommitCommandInEitherForm`
   (its Takes form mounts panes — A1's `PanePublisher`, 18l's), and the 61-suite closing run logged
   50 from other generators. None of them can be this representable's, because its report closure is
   only called from the hop.
2. **The inline editor's frame can stay off its content after a width change settles late**:
   measured in the app at **85 pt taller than the text after the window was restored**, identically on
   both roads (the old road also missed the narrowing step, which the fix converges). Cause: the same
   text at the same width measured 20,993 or 20,908 depending on layout history (TEXTKIT2 §2's
   `enumerateTextLayoutFragments` class), and nothing re-reports a late settle. The pane component
   has a bounded convergence heal (`PanePublisher`) that the inline editor does not compose. It needs
   an owner (a candidate is 12, beside the read-click flake row). Fixing it would reach the
   measurement brain (`PaneSurface`, fenced), so it is untouched.
3. **A measured TextKit fact worth a TEXTKIT2_NOTES line (canon, so it is left for the orchestrator):**
   on macOS 27 the FIRST full `.ensuresLayout` measure after a text view enters its window, after a
   container width change, or after an edit can differ from the layout a later display pass converges
   to, with no edit, no frame change and no inset change in between. Measured: 11,182 → 10,929 on
   entering the window; 18,713 vs 19,344 after a 700→420 reflow; one 20-pt line after three
   keystrokes. The pins are built around it (layout settled before the install, one line of slack,
   and a midpoint discriminator for the reflow).
4. **Inside a SwiftUI update, a `Binding` captured at `makeNSView` reads the PRE-update value**
   (measured: 24 while the state already held 20,993). This is moot for C2, whose closure never runs
   inside an update now, but any representable that gates on a captured binding inside `updateNSView`
   inherits the stale read.
5. **The dev app did not exit on the driver's `NSApp.terminate`.** In walk 1 a synchronous terminate
   from inside a main-actor task hung in `terminateLater` for over 2 minutes. In walks 2–4, with the
   terminate deferred, the app had not exited 3 s later and was stopped by PID (the path verified as
   the Debug product each time). This is NOT established as a product ⌘Q hang: it was the driver's
   own call, and the real menu/⌘Q road was not exercised. It is recorded so nobody reads the PID stops
   as clean exits.
6. **Every test host prints two `sqlcipher_codec_ctx_set_error` lines at startup**, on old and new
   trees alike. Pre-existing noise, not investigated.
7. **`BookOutlineLandingTests`' `writingEditor(in:)` doc** says the harness realizes the Outline's
   editor twice (13u2 A2). It has not since `f8610cb9` (bisected here), so that claim is stale; the
   helper's choose-the-editor-with-text logic stays harmless. Left for whoever owns the suite.
8. The brief's "pool inline editor" is no longer an inline host (see READING). The C1 walk's
   tenth-Open-strip-row crash did not arise, because this driver opens at most two notes.

### THE GUI WALK — HELD for the author (her steps; ~5 minutes on the dev-store Debug build)

1. Run the dev-store Debug build (Xcode's Run). Open the **Sherlock** book in **Outline**.
2. Click ▸ on *A Scandal in Bohemia*, then click into its prose so it goes live. Expect no jump and
   no flash, and the story at its full length at once, with no strip of blank space growing under it.
3. Scroll to the story's last paragraph. Expect nothing clipped and no blank gap below the last line.
4. Type a few characters mid-story and delete them. Expect the row to track the text and the page
   not to hop.
5. Scroll to the book's end and back. The story should still be live at the same place.
6. Drag the window narrower, then back to its width, and look under the story's last line again. A
   blank gap of up to ~85 pt after widening is the RECORDED residual (NOTICED 2, the same before and
   after this change). A clipped last line would be new — tell the orchestrator.
7. Optional: Console.app filtered on *Modifying state during view update* while doing 2–6. Expect
   none from the Outline's editor (other surfaces may still print theirs — C3's and 18l's families).
8. Switch the book to the page (spread) view, open a note and type. The page should grow with the text.

### CAPTURES

None possible (see the first line). The use evidence is the in-app walk logs in
`notes/plans/18k-screens/c2/` (gitignored): `walk1-pre-fix.log`, `walk2-pre-fix-expand-then-click.log`,
`walk3-POST-fix.log`, `walk4-PRE-fix-same-driver.log`. The harness logs are in `App/Variorum/DerivedData/18k-c2-*.log`
(harness1 · pins-prefix · pins-fixed-r{1,2,3} · R1 · Mstrand · Mstuck · Mteeth · warn-{B,A}{1,2} ·
closing1). The probe scripts are session-scratch only (`c2_probe_apply.py`, `c2_min_probe.py`,
`bisect_step.sh`), and the Phase 1 probe is recoverable from `d599539b`/`3f9b84ea`.

### UNIT C2 — ORCHESTRATOR ADJUDICATION (2026-09-25 night; the unit CLOSES here)

**Verified by spot-check:** 17 commits `709bd7bf`…`6571c558`, pushed, **zero trailers**, tree clean,
zero app instances, the scratch bisect worktree removed (the only other worktree,
`u1-baseline-tree`, predates this run — untouched). Diff scope: `InlineEditorSurface` in
`EditorView.swift` + two test files — no `EditorTextView`, no storage seam, no `PaneSurface`, no
`Sources/`. **ACCEPTED — the hypothesis DISPROVED honestly** (TRACE B-1 had already deferred this
binding and still doubled; M4 on B-1's tree: warnings 18 → 0 with the double intact), **the deferral
landed as hygiene with red-on-old pins** (`InlineHeightReportTests`, 5 issues on old incl. a
behavioural strand at 10,929 vs 18,713 pt; the M-strand/M-stuck mutations prove the first-report
delivery law holds), and **the double realization bisected to `f8610cb9` (13u2b UNIT 1)**. The one
existing-test adaptation (`InlineEditorWindowTests.inlineBadgesTrackAWidthReflow`, one setup line,
assertions unchanged, M-teeth still red at its original 816) is traced and accepted.
**Warning counts:** the fixed 16-suite set 84/85 → 4/4 (the 4 are `PanePublisher`'s — 18l U3's family);
in-app 10 → 0. **Ledger:** the shadow-editor row CLOSED as RESOLVED-BY `f8610cb9` (the orchestrator
adopts the suggested disposition); the ~85-pt restore residual filed as its own row, owner 12.
**Noticed items:** (3) the measured TK2 fact (first full measure after window entry / width change /
edit differs from the settled layout) → a `TEXTKIT2_NOTES.md` measured-finding paragraph at THIS
RUN's CLOSEOUT (recording a measured delta, the 13l/17o precedent); (7) `BookOutlineLandingTests`'
stale "realizes twice" comment → C3 may correct it if it touches that file, else the ladder notes it;
(5) the dev app not exiting on `NSApp.terminate` under the driver — recorded, not established as a
product hang; watched for in later units. **GUI walk HELD** — the eight steps are in the C2 RECORD and
join the morning bundle.

## UNIT C3 BRIEF — the mechanical state-write deferrals (self-contained; read in this order)

**You are the C3 implementer (`opus-implementer`), ONE unit, this session only.** Read, in order:
1. `CLAUDE.md` (auto-loaded).
2. THIS FILE: the kickoff corrections, THE LEDGER (row C3), **ENVIRONMENT TRAPS (binding)**, CAST &
   DISCIPLINE, the C1 and C2 RECORDS' closing sections + their ORCHESTRATOR ADJUDICATIONS (the tree
   moved; C2 measured the warning family you now sweep — START from its numbers and its
   noticed-not-touched list), and this brief.
3. `notes/codebase-health-review-2026-09-21.md` §5.1 — A3/A4/A5 are yours; **A1 (`PanePublisher`) is
   NOT** (it is 18l's, under her ratified frame-synchronous/state-deferred ruling — do not touch
   `PanePublisher`/`PaneSurface`), and A2 was C2's. A REVIEW record: re-trace every site.
4. `App/Variorum/Variorum/Workspace/WindowRegistry.swift`'s header — **the sticky-key ruling binds**
   (`theStickyKeySurvivesAppDeactivation` pins its regression); read it before touching any window
   registration.

**The class:** a SwiftUI state write (an `@State`, an `@Observable` model's observed stored property,
a `@Binding`) performed synchronously inside a view-update pass — `.onGeometryChange` actions,
`onAppear` paths that write observed state, window-registration callbacks — logs
`Modifying state during view update` and can drop or re-order the write. The known-correct shape is in
the tree: `BookView.swift:~1413` gates on a tolerance and defers with `DispatchQueue.main.async`; its
**un-deferred twin is `BookIndexView.swift:~791`** (`model.reportIndexContentWidth(width)` straight in
the action) — do that one first, it is a copy of a pattern already reviewed. Then enumerate the rest:
the review counts ~14 un-deferred geometry actions, **Canvas** handing geometry straight into observed
storage (including the `ForEach`-driving `realizedIDs`; `CanvasDragTrackingTests` is on the flake list
and its structure matches this symptom — note it, don't claim it), plain-`@State` sites, and ~6 A4/A5
one-liners in window registration / `onAppear`.

**The acceptance form (the 13u4 UNIT S3 precedent):** a **per-site verdict table** in your record —
site (file:line) × what it writes × verdict: DEFERRED (with the shape used) · SAFE-AS-IS (the write is
not observed / is already off the update pass — state the mechanism) · LEFT (with the reason, e.g. the
sticky-key ruling, or a write whose ordering is load-bearing — name the pin that proves it). Grep the
whole Mac app for `.onGeometryChange` and `onPreferenceChange`-like actions so the table is COMPLETE,
not the review's sample — enumerate trigger inputs, not just consumers. **Behaviour must be
byte-identical**: every existing pin on a touched surface rides UNMODIFIED (a pin that needs editing
means the deferral changed behaviour — stop and re-trace). Where a deferral could reorder a
load-bearing sequence (a landing, a measure-then-aim), prefer LEFT-with-reason over a clever fix.
**No red-on-old pin is owed for pure deferral hygiene** (the warning is the evidence); a site where
the deferral fixes an OBSERVABLE defect gets its pin.

**The measurement:** the `Modifying state during view update` count over the SAME fixed 16-suite set C2 named
in its record (84/85 → 4/4 after C2; the 4 left are `PanePublisher`'s — 18l's, not yours), PLUS a
second set covering Canvas, the book Index, Compare and the shell if C2's set misses a site you
touch — name it and run it BOTH sides: your pre-change commit and your final one, recorded with the command.

**Use-shaped evidence:** the terminal host holds NO Screen Recording / Accessibility (do not drive the
GUI). In-app scripted or harness evidence: Canvas drag tracking, the book Index width report, window
open/close — the touched surfaces' suites plus `CanvasDragTrackingTests` run 3× (report the rate; it
is a known load-flake — the point is whether it moved). Write the GUI walk steps for the author into
your record (they are HELD for her morning).

**Closing runs (tests at the END):** every touched surface's suites + the eleven Tutorial suites
(names in ENVIRONMENT TRAPS), each read by its "Test run with N tests" line; no full Mac suite.

**CHECKPOINT RULES (restated, binding from your first commit):** write `## UNIT C3 RECORD` with its
`### THE MECHANISM (Phase 0 + 1 — every number from a run in this session)

**M1 — what SwiftUI flags, in a minimal harness** (a scratch Swift Testing file mounting one view
per write shape in an `NSHostingView` window, mount + a resize each, bracketed by `NSLog` markers
on the warning's own stream; never committed; `DerivedData/18k-c3-mech1.log`). Of fourteen shapes,
exactly ONE is flagged: **a `@State` written through a `@Binding` inside `updateNSView`** (arm E).
Not flagged: `onGeometryChange` → `@State` (read in the body, or not) · `onGeometryChange` →
`@Observable` (read, or not) · the same with a `DispatchQueue.main.async` hop · `onAppear` →
`@State` / `@Observable` · `onChange` → `@State` · `onScrollGeometryChange` → `@State` ·
`viewDidMoveToWindow` → `@State` / `@Observable` (the `WindowKeyReporter` shape) · a preference
round-trip → `@State` · **and an `@Observable` write inside `updateNSView`** (arm F — the warning
cannot see Observation at all, so it can never be the evidence for an `@Observable` site).

**M2 — who emits it in the app** (a trigger-scoped probe: `NSLog` enter/exit around 132 triggers —
all 76 geometry/scroll-geometry actions, every representable's make/update/dismantle, the
window reporter's `viewDidMoveToWindow`/`windowBecameKey`, the three `Layout` types' methods, and
the NSView `layout`/`setFrameSize` overrides; applied by a scratch script, never committed; a
warning is attributed to the innermost open bracket on its thread):

| run | tests / suites | warnings | inside `PaneSurface.makeNSView` | inside `PaneSurface.updateNSView` | anywhere else | unbracketed |
|---|---|---|---|---|---|---|
| set A (C2's 16) | 92 / 16 | 4 | 4 | 0 | **0** | **0** |
| set B (this unit's 39) | 187 / 39 | 1,127 | 1,117 | 10 | **0** | **0** |
| set C (9, incl. a scratch `CommentsPanel` mount) | 55 / 9 | 50 | 50 | 0 | **0** | **0** |

70,752 probed trigger entries; 125 of the 132 triggers exercised; **29,071 geometry-action entries
over 75 of the 76 sites, none flagged**. The seven never entered: `CommentsPanel:795` (the deleted
fold's height, behind a click — the same shape as `:649`/`:917`, which were) and `ReferencePanel`'s
three representables (they write no SwiftUI storage — below). **Conclusion: in these 334 tests the
warning family is 100% `PaneSurface` (18l's `PanePublisher`), and the review's A3/A4/A5 premise —
that the geometry actions and the window/onAppear one-liners GENERATE it — is DISPROVED.** The
kind-level fact the table leans on: the SAME modifier's action closure writing a `@State` (15 sites,
~515 entries) is never flagged, while a `@State` write inside an update is flagged every time — so
`onGeometryChange` / `onScrollGeometryChange` actions run OUTSIDE SwiftUI's view update, and an
`@Observable` write in one is the ordinary Observation invalidation, not a write during an update.

### THE VERDICT TABLE (the 13u4 S3 form — every trigger in the Mac app; entries = probed entries over sets A+B+C)

**Verdicts: DEFERRED 0 · SAFE-AS-IS 76 geometry actions + every non-geometry trigger below · LEFT
(as well as safe) 8 landing sites + the window-registration road (the sticky-key ruling) ·
`PaneSurface` LEFT for 18l (fenced).** No deferral was applied anywhere: at every site the
evidence a deferral would remove — the warning — reads zero on both sides (the brief's own form of
"a pin green on both sides is hollow"; demonstrated literally on its first site, Phase 2b).

**S — DEBUG oracle / pin-seam writes into plain statics (not SwiftUI storage; nothing to flag by
construction; their OWNERSHIP is C4's sweep) — 38 sites, SAFE-AS-IS:**
`BaselineProbe:61` (19) · `SeamGrip:87`/`:101` (265/262 — callbacks whose every consumer writes a
DEBUG static — `SeamGeometry`, `ShellGeometry`, `PostDetailOracle` via `SideColumn.onDividerFrame`
— or a pin seam that is nil in the app, `WorkbenchSeam.onFrame`) · `SidebarNoteBox:139`/`:158` (9/9)
· `BookIndexView:395` (29) `:625` (171) `:833` scroll-offset trace (62) `:1057` (212) `:1192` (77)
`:1294` (23) `:1325` (3,657) · `BookView:748` (169) `:1845` (4,842) · `CanvasView:640` (16) ·
`CommitBar:533` (60) `:543` (59) · `LibraryInfoPanel:614` (55) · `SidebarView:371` (50) `:486` (4)
`:596` (138) `:605` (105) `:619` (15) `:728` (233) `:737` (30) `:740` (233) · `ReadModeView:199`
(20) `:604` (81) · `CompareBoardView:1579` (26) · `LensesBoardView:936` (21) · `PostDetailView:373`
(52) `:677` (99) `:759` (4) `:775` (97) `:991` (305) · `TakesBoardView:1697` (162) `:1792` (91) ·
`BlocksWorkbenchView:1082` (44).

**A — `@State` written synchronously in the action (the kind that WOULD be flagged were the action
inside the update; measured: never) — 15 sites, SAFE-AS-IS:**

| site | writes | entries | note |
|---|---|---|---|
| `SideColumn:210` | `totalWidth` | 126 | |
| `CommitBar:537` | `barWidth` | 59 | |
| `TakesBottomBar:267` | `barWidth` | 51 | |
| `LibraryCatalogView:209` | `libraryWidth` | 13 | |
| `SidebarView:290` | `columnHeight` | 52 | |
| `ShelfView:82` | `listContentHeight` | 28 | the `of:` trailing-closure form |
| `PostDetailView:304` | `mastheadIconRowWidth` | 49 | |
| `BlocksWorkbenchView:260` | `totalWidth` | 3 | |
| `ReadingFlowView:278` | `columnWidth` | 2 | equality-guarded |
| `ProseTakeCard:266` | `width`, then `rebuild()` → `geometry` | 10 | 0.5-pt gate |
| `CalmGrammar:155` / `:159` | `textWidth` / `boxWidth` (the marquee) | 65 / 54 | |
| `CommentsPanel:649` / `:917` | `commentsHeight` / `measured` | 2 / 1 | scratch mount (no suite mounts the panel's view) |
| `CommentsPanel:795` | `deletedHeight` | 0 | not entered (behind a click); the same shape as the two above |

**O — an `@Observable` model's OBSERVED property, written synchronously in the action — 4 sites,
SAFE-AS-IS** (the action is outside the update — kind A's measurement; the write is the ordinary
Observation invalidation; the warning cannot see these either way — M1 arm F):

| site | writes | entries | note |
|---|---|---|---|
| **`BookIndexView:791`** — the brief's "un-deferred twin" | `BookViewModel.indexContentWidth` (1-pt tolerance in the model), `indexPaneHeights.stand` | 17 | **DISMISSED AS HOLLOW, demonstrated:** `BookView:1410`'s exact deferral applied in scratch → set B 1,126 → 1,134 (no decrease; the +8 is one Takes test's `PaneSurface` count), the four Index suites green both sides with zero warnings attributed. The "known-correct" twin's hop rests on the B-1 claim C2 disproved — it is harmless and kept, not a pattern owed here. |
| `CanvasView:161` | `boardViewportRect` | 14 | read only by the drop decision (a method), no body reads it |
| `CanvasView:166` (scroll) | `visibleRect` (+ `realizedIDs` via `recull()`, re-cull hysteresis-gated) | 35 | `realizedIDs` drives the `ForEach` through `realizedCards` — the write is outside the update, so the `ForEach` re-renders on the NEXT pass as designed. The review's "structure matches symptom" for `CanvasDragTrackingTests` is not this mechanism (it produces no warning); the flake rate is recorded below, unclaimed. |
| `CanvasView:431` | `bankRect` | 7 | read only by the drop decision |

**U — unobserved storage (a plain class held in `@State`, `@ObservationIgnored`, or a nil pin seam)
— 5 sites, SAFE-AS-IS by construction:** `ReadEditPane:264` → `ReadCarryGeometry.noteRow` (72; a
plain class, "not observed, deliberately") · `ReadModeView:166` → `noteViewport` + a DEBUG static
(20) · `ReadModeView:807` → `noteRow` (9) · `BookIndexView:1232` → a DEBUG static + `onMeasured` →
`learnIndexPaneRowHeight` → `indexPaneHeights` (`@ObservationIgnored`) (146) · `CalmGrammar:85` →
`onDetailHeight` (nil in the app — row 89's pin seam) (1).

**L — LANDING / measure-then-aim reports (load-bearing ORDER: a hop would move each report behind
the aim it feeds) — 8 sites, SAFE-AS-IS and LEFT:** `BookView:1440` (scroll) →
`LandingAuthority.contentChanged` (128) · `BookView:1883` → `outlineAnchorMoved` → the landing box +
`landing.noteTop` (2,348) · `BookIndexView:806` (scroll) → `paneBox.contentHeight` +
`contentChanged` (120) · `BookIndexView:1211` → `paneBlockAnchorMoved` → `noteTop` (3,622) ·
`ReadingFlowView:188` (scroll) → `landing.lastOffset` + `contentResized` (6) ·
`ReadingFlowView:1004` → the flow's anchor report (575) · `TakesBoardView:608` →
`noteArticleRowFrame` (`@ObservationIgnored` frames; the 17q R1-1 ordering note) +
`spendArticleLanding` → `scrollTo` (2,631) · `TakesBoardView:666` (scroll) →
`consumeArticleGeometry` → `scrollTo` (362). (`LandingAuthority`, the landing boxes and
`paneBox` are plain classes — not observed.) Pins that hold the order: `BookOutlineLandingTests`,
`BookIndexLandingTests`, `ReadingFlowLandingTests`, `TakesArticleScrollTests` — all in the closing
runs.

**D — ALREADY DEFERRED (a next-turn hop) — 6 sites, SAFE-AS-IS; the hop KEPT byte-identical, its
stated reason CORRECTED (comment-only, `5286ff39`):** `StableSurface:102` (`near`, 2,786) ·
`StableSurface:208` (`loaded` / `reportedWidth`, 346) · `BookView:1410` (`outlineContentWidth`, 61)
· `BookView:1432` (`outlinePaneWidth`, 163) · `BookView:1940` (the run row: `learnOutlineRowHeight`
unobserved + `outlineAnchorMoved` synchronous, `near` hopped; 1,527) · `BookIndexView:959` (the
pane row: the same shape, 1,754). Each comment said the hop existed because "a geometry action can
arrive inside a layout pass, and a state write there is the class that doubled a mounted editor";
M2 shows the first half is not the flagged class and C2's bisect showed the double was the lazy
container. One canonical note now sits on `NearViewportObserver`; the five others point to it.

**Non-geometry triggers:**

| trigger | entries | flagged | verdict |
|---|---|---|---|
| `PaneSurface` `makeNSView` / `updateNSView` | 1,125 / 4,215 | **1,171 / 10 — every warning in the app's runs** | LEFT — 18l's (`PanePublisher`, her frame-synchronous/state-deferred ruling); fenced |
| `EditorView` full-document (make/update) + `InlineEditorSurface` (make/update) | 52+119 / 20+130 | 0 | SAFE-AS-IS (C2 deferred the inline height report) |
| `CaptureTextView` make/update/`sizeThatFits`/`viewDidMoveToWindow` | 23 / 1,146 / 11,387 / 38 | 0 | SAFE-AS-IS — update adopts `text` INTO the NSView (`view.string =`, no state write); focus via the coordinator |
| `ReadPostView` make/update | 79 / 199 | 0 | SAFE-AS-IS — attach/install/chrome, no binding written |
| `PageLeafView`, `PageTurnKeys`, `CommentsPanel`'s key monitor, `DivideWSheet`'s key monitor, `PaneFocusCatcher` | 4+16, 2+8, 1+5, 5+9, 20+91 | 0 | SAFE-AS-IS — assign closures/properties onto the NSView only |
| `ReferencePanel` ×3 (PDF / Quick Look / web) | 0 (not mounted by any suite) | — | SAFE-AS-IS by construction — NSView properties + a `.main`-queue notification observer (async) |
| `Layout` types: `TrailingFlow`, `MastheadRowTwo`, `FlowLayoutLite` | 3,691+3,404 · 4,241+4,425 · 2+7 | 0 | SAFE-AS-IS — size/placement arithmetic, no state |
| NSView overrides (`EditorTextView` `setFrameSize`/`layout`/`viewDidMoveToWindow`, `BlockDecor.layout`, `PaneSurface` `layout`/`viewDidMoveToWindow`) | 1,882 / 151 / 136 · 11 · 2,828 / 1,587 | 0 | SAFE-AS-IS (and `EditorTextView`/`PaneSurface` fenced) |
| **Window registration** — `RootView:334` / `NoteWindowView:139` / `QuickNoteView:353` `.onAppear { windows.register(…) }` | (onAppear — M1 arms C/D) | 0 unbracketed in any window suite | SAFE-AS-IS and LEFT — `WindowRegistry` is `@Observable`; the sticky-key ruling binds its order and key-ness, untouched |
| **`WindowKeyReporter`** (three hosts): `onWindow` → `windows.attach` (+ `NoteWindowView`'s `@State window`), `onKey` → `windows.noteKey` | make 18 · `viewDidMoveToWindow` 19 · `windowBecameKey` 4 | 0 | SAFE-AS-IS and LEFT — the sticky-key ruling (no resign door; `theStickyKeySurvivesAppDeactivation`); `NoteWindowView`'s `@State` shape is M1 arm G |
| every other `.onAppear` (57 in all: `EditorView:169,185` · `QuickNoteView:353` · `DivideWSheet:146` · `CanvasView:235,1116` · `TrayPanel:1295` · `TakesBoardView:143,145,148,200,597` · `NoteWindowView:139` · `SidebarNoteBox:184,268` · `LibraryInfoPanel:436,546` · `ProtectionPane:193` · `ReadPostView:96` · `RootView:334,812,813,818,858` · `TakesShared:124,162,647,796,821` · `CommentsPanel:60` · `CompareBoardView:971` · `CommitBar:209` · `PostDetailView:492,723,732` · `VariorumApp:54` · `LensesBoardView:152` · `ReadModeView:216` · `ReadingFlowView:205,1086` · `ShelfView:426` · `LibraryTimeFace:485,500` · `CalmGrammar:127` · `BookView:235,241,245,1467,2056,2095,2109,2393` · `SpreadBookView:95` · `SidebarView:250` · `BookIndexView:403` · `BookOrderAndConversion:150` · `NotePicker:247`) | — | 0 unbracketed across 334 tests | SAFE-AS-IS as a kind — `onAppear` runs after the update (M1 arms C/D) |
| `onPreferenceChange` | — | — | none in the codebase (0 sites) |
| `GeometryReader` bodies (`RootView:622`, `TakesBoardView:578`, `CommentsPanel:619`, `NotePagesView:107`, `PagedReadView:148`) | — | 0 | SAFE-AS-IS — no synchronous write in any of the five bodies (read) |

### THE USE EVIDENCE (in-app, dev store, the final tree + the scratch probe; the Sherlock book, *A Scandal in Bohemia* 262 blocks, a 14-block note for Canvas)

The driver (`C3_WALK=1`, a DEBUG task on `RootView`, never committed, the C1/C2 pattern — the
scripts are in `notes/plans/18k-screens/c3/`) walked, in order: the book in **INDEX** (an ANIMATED
live resize 1,700 → 1,440 → 1,700 pt, then the 235,019-pt pane scrolled to five depths and back) ·
the book in **OUTLINE** (the same) · the note in **CANVAS** (the resize, the board scrolled, and
ONE synthesized card drag through `NSApp.sendEvent`, which MOVED the card (20,20) → (100,68) on
its first attempt) · **TAKES** as the positive control · a **note-only window** and a **second main
window**, each opened and closed.

| phase | `Modifying state during view update` | inside |
|---|---|---|
| Index · Outline · Canvas (incl. the drag) · both windows | **0** | — |
| opening the note on the way into Canvas (it opens in its remembered pane mode first) | 14 | `PaneSurface.makeNSView` |
| Takes (the positive control) | 15 | `PaneSurface.makeNSView` |

12,762 probed entries, including `BookIndexView:791` ×1 (the Index column is capped at 640 pt, so a
260-pt window resize never changes its width and the action fires only at the mount),
`BookIndexView:959` ×510 and `:1211` ×3,161, `BookView:1940` ×208, `CanvasView:161` ×47 and `:166` ×99,
and the window reporter (3 mounts, 4 `viewDidMoveToWindow`, 3 `windowBecameKey`). **One capture
trap, recorded for every future walker:** the FIRST launch (`c3-walk1.log`, no env) logged ZERO
warnings, the Takes control included. A directly launched binary does not mirror SwiftUI's
runtime-issue log to stderr. The second launch set `OS_ACTIVITY_DT_MODE=YES` and captured the
control (`c3-walk2.log`), so an in-app warning count needs that variable AND a positive control.
**The dev store was written by the walk:** one Canvas card's layout moved, as above. That is a
dev-store row, never the real store. The Debug instance was stopped by PID after its path was
verified as this session's `DerivedData/18k-c3-walk` product, following C2's precedent that a
driver's `NSApp.terminate` hangs.

### LIVE STATUS` at the END of this file in your FIRST commit, and flip it in the same commit as each
piece; unverified claims marked **PENDING**. Commit per coherent piece (a site or a small group per
commit is right here) and PUSH after every commit; stage pathspec-limited, never `git add -A`; NO
commit trailers (no Co-Authored-By, no Claude-Session). Synchronous foreground waits only — the
grep-poll loop; never end your turn with a run in progress. Never spawn subagents (one Sonnet lookup
for EXTERNAL facts only). No behavioural revert starts until the record names it and the pre-revert
state is COMMITTED. Every death/resume noted in the record. If the worktree moves under you, write
nothing, report, stop. Never touch `/Applications`, never build Release, never quit or kill a
real-store Variorum instance.

**Scope fence:** C3 only. Zero `Sources/`, zero `Sync/`, zero `PanePublisher`/`PaneSurface`/
`EditorTextView`/`BlockRangeIndex`. The DEBUG oracles are C4's (list them, don't touch). QUESTIONS:
check the end marker for the next free number. **Your final message:** a short summary pointing at
your record.

## UNIT C3 RECORD — the mechanical state-write deferrals (implementer: `opus-implementer`, 2026-09-25)

**NOT DONE (first line, per the brief):** (1) **NO DEFERRAL WAS APPLIED — the brief's premise did
not survive measurement.** Not one of the 76 geometry actions, the window-registration road, any
`onAppear`, or any trigger other than `PaneSurface` (18l's, fenced) emits `Modifying state during
view update`: 0 of 1,181 harness warnings and 0 of 29 in-app ones. So the brief's "defer each one
that can be deferred" found nothing whose evidence a deferral would move. The first site was
deferred in scratch to prove it (no decrease), and the change was not kept. What landed is a
COMMENT-ONLY correction at the six hops that gave the disproven reason. (2) **The hands-on GUI walk
and its captures are HELD**: this host holds no Screen Recording and no Accessibility grant (C1's
finding). An in-app scripted walk on the dev store stands in, and her steps are listed below.
(3) `CommentsPanel:795` (the deleted fold's height, behind a click) and `ReferencePanel`'s three
representables were never entered by any run. Their verdicts rest on the shape (the same as sites
that were entered) and on reading the code (no SwiftUI storage written). (4) No full Mac suite (the
orchestrator's finals). No `swift test` and no iOS build: zero `Sources/`, zero `Shared/`.

### READING (done in-session before any code)

CLAUDE.md + canon (auto-loaded); this file's kickoff corrections, THE LEDGER (row C3), ENVIRONMENT
TRAPS, CAST & DISCIPLINE, the C1 and C2 records' closing sections + both ORCHESTRATOR ADJUDICATIONS,
and the C3 brief; the health review §5.1 (A3/A4/A5 mine; A1 18l's; A2 C2's); `WindowRegistry.swift`
whole (the sticky-key ruling: NO resign door — `keyWindowID` moves only on another window's
become-key or the key window's unregister; `theStickyKeySurvivesAppDeactivation` pins it); C2's
warning-set script (`DerivedData/18k-c2-warnset.sh`, 16 suites) and its closing-run log (50
warnings across 61 suites, attributed by nearest started test — mostly pane-mounting tests).

### LIVE STATUS

- Reading — DONE (this commit).
- Phase 0, THE MECHANISM — DONE (this commit; scratch, never committed — THE MECHANISM below):
  of fourteen minimal write shapes, SwiftUI flags exactly ONE — a `@State`/`@Binding` write inside
  `updateNSView`. `onGeometryChange` / `onScrollGeometryChange` / `onAppear` / `onChange` /
  `viewDidMoveToWindow` → `@State`, and every `@Observable` write (even inside `updateNSView`),
  log nothing.
- Phase 1, THE ENUMERATION + ATTRIBUTION — DONE (this commit): 76 geometry actions, 49 representable
  / NSView-callback / Layout triggers, the three window registrations. A trigger-scoped probe
  (scratch, never committed; `git checkout` removes it) bracketed 132 triggers across THREE suite
  sets — C2's 16 (92 tests), a named second set of 39 suites (187 tests), and a third of 9 (55
  tests, incl. a scratch `CommentsPanel` mount): **1,181 warnings, EVERY ONE inside `PaneSurface`'s
  `makeNSView` (1,171 = A 4 + B 1,117 + C 50) or `updateNSView` (10, all B) — 18l's `PanePublisher`
  family; ZERO unbracketed; ZERO inside any of the 125 other exercised triggers
  (70,752 probed entries, 29,071 of them geometry actions — 75 of the 76 exercised).** The review's
  A3/A4/A5 premise — that these sites GENERATE the warning — is DISPROVED by measurement.
  **PENDING:** the per-site verdict table and the dispositions (next commit).
- Phase 2, the BEFORE count — DONE (this commit), unprobed, on `a43af3e9` (app code = the pre-C3
  tree `c823357b`), zero app instances: **set A (C2's 16 suites, `DerivedData/18k-c2-warnset.sh`)
  `Test run with 92 tests in 16 suites` → 4 warnings; set B (39 suites, `DerivedData/18k-c3-setB.sh`,
  named literally in the script) `Test run with 187 tests in 39 suites` → 1,126 warnings.** One
  issue each, both KnownIssues row 65's macOS-27 deltas (A: the NSSlider scrubber pin; B:
  `LibraryPanelHostTests`' "inspector" pin). Logs `DerivedData/18k-c3-before-{A,B}.log`.
- Phase 2b, THE HOLLOW DEMONSTRATION on the brief's first site — DONE (named in `4bdced1c` before
  it ran; scratch, never committed): `BookView:1410`'s exact shape applied to `BookIndexView:791`
  (tolerance gate + `DispatchQueue.main.async { model.reportIndexContentWidth(width) }`), set B
  unprobed: **`Test run with 187 tests in 39 suites` → 1,134 warnings (before: 1,126) — NO
  decrease.** Per-test diff of the two logs: identical everywhere except ONE Takes test
  (`theBloomDoorStillGoesToTheBlockTheRingWasLastIn`, 105 → 113 — `PaneSurface`'s own run-to-run
  count); the four BookIndex suites pass on both sides with zero warnings attributed to them. The
  deferral is HOLLOW at its own evidence → NOT applied. Restored by `git checkout --
  …/BookIndexView.swift`, `git diff` empty. Log `DerivedData/18k-c3-hollow-B.log`.
- Phase 3, the deferrals — DONE AS **ZERO DEFERRALS** (every site SAFE-AS-IS by the measured
  mechanism; THE VERDICT TABLE above, committed after `5286ff39`). **What DID land (this commit): a comment-only
  correction** at the six places that gave the disproven reason for a next-turn hop
  (`StableSurface.swift` ×2 + a canonical note on `NearViewportObserver`; `BookView.swift` ×3;
  `BookIndexView.swift` ×1). The hops are byte-identical and kept; only the stated WHY changed.
  `git diff -U0` over `App/`: **0 non-comment lines changed.** Built and counted AFTER (Phase 4).
- Phase 4, the AFTER count, `CanvasDragTrackingTests` ×3, closing runs — DONE (numbers under
  DISPOSITION).
- Phase 5, the IN-APP scripted walk (dev-store Debug build; the GUI cannot be driven from this host)
  — DONE (THE USE EVIDENCE above). The scratch probe + driver are REMOVED: `git checkout -- App/…`
  + the helper deleted; `git diff --quiet HEAD` true; zero `C3Probe`/`C3Walk` strings in `App/`;
  zero app instances. (While it ran, the tree carried them uncommitted, as recorded in
  `286c27a6`.) Driver (env `C3_WALK=1`, appended to
  `RootView.swift`): the Sherlock book in INDEX (a live animated resize narrow/back + the pane
  scrolled), then OUTLINE (the same), a mid-size note in CANVAS (resize, scroll, one synthesized card
  drag through `NSApp.sendEvent`), TAKES as the POSITIVE CONTROL (panes mount, so `PaneSurface`
  should warn — a zero elsewhere cannot then be a capture failure), and a note-only window + a
  second main window opened and closed. Built with `-derivedDataPath DerivedData/18k-c3-walk`.
- Deaths / resumes: none.
- **C3 — DONE (implementer), awaiting the orchestrator's spot-check; the GUI walk HELD.**

### DISPOSITION

**Ledger row C3 — the review's §5.1 A3/A4/A5 are DISMISSED AS HOLLOW, measured. No deferral was
applied. A comment-only correction landed. No observable defect was found, so no pin is owed.**
- **The mechanism (M1, M2, THE USE EVIDENCE):** SwiftUI flags a state write only inside a view
  update, meaning inside `makeNSView`/`updateNSView` here. It runs `onGeometryChange` and
  `onScrollGeometryChange` actions, `onAppear`, and the window reporter's AppKit callbacks outside
  that update. In this app the family is 100% `PaneSurface`: set A 4 of 4 · set B 1,127 of 1,127 ·
  set C 50 of 50 · the in-app walk 29 of 29.
- **The brief's first site, `BookIndexView:791`, was demonstrated hollow.** `BookView:1410`'s exact
  deferral was applied in scratch. Set B read 1,126 → 1,134 (no decrease; the +8 sits in one Takes
  test's `PaneSurface` count), and the Index suites were green with zero warnings on both sides.
  The change was not kept. The "known-correct" twin's hop is not a pattern this site owes, because
  its stated reason is the claim C2 disproved.
- **The table:** 0 DEFERRED · SAFE-AS-IS everywhere · LEFT as well for the 8 landing reports (a hop
  would reorder measure-then-aim) and the window-registration road (the sticky-key ruling,
  untouched) · `PaneSurface` LEFT for 18l.
- **Landed (`5286ff39`, comment-only; `git diff -U0` over `App/`: 0 non-comment lines):** the six
  places that justified a hop with the disproven mechanism now say the hop is harmless and kept,
  and one canonical note on `NearViewportObserver` carries the measurement. The hops are
  byte-identical. Reason: the review's A3 claim was plausibly read off these very comments, and
  leaving them would invite the next reviewer to re-derive it.
- **Warning counts, one fixed pair of suite sets, unprobed, zero app instances, commands in the
  scripts:**
  - **Set A**, C2's 16 suites (`DerivedData/18k-c2-warnset.sh`): **BEFORE 4 → AFTER 4**.
  - **Set B**, this unit's 39 suites (`DerivedData/18k-c3-setB.sh`): **BEFORE 1,126 → AFTER
    1,135**. The spread across four runs of the same app code is 1,126 · 1,127 · 1,134 · 1,135.
    The per-test diff puts every difference in two `TakesArticleScrollTests` tests (+8, +1): that is
    `PaneSurface`'s run-to-run variance, not this unit.
  - Before = `a43af3e9`, whose app code is the pre-C3 `c823357b`. After = `61fda725`, which adds
    the comment-only diff.
- **`CanvasDragTrackingTests`: 7 of 7 green.** 4 of the runs were inside set B under load
  (probed · before · scratch-deferral · after) and 3 were isolated (`✔ Test run with 2 tests in 1
  suite passed` ×3). The flake did not reproduce this session. The review's "structure matches
  symptom" is not supported, because the Canvas writes produce no warning. Unclaimed either way.
- **Existing pins:** none modified; none needed editing.
- **Closing runs (the final tree):**
  - Set A AFTER: `✘ Test run with 92 tests in 16 suites failed after 42.885 seconds with 1 issue`.
    The one issue is the NSSlider scrubber pin, a KnownIssues row 65 macOS-27 delta.
  - Set B AFTER: `✘ Test run with 187 tests in 39 suites failed after 109.914 seconds with 1
    issue`. The one issue is `LibraryPanelHostTests`' "inspector" pin, the same row.
  - Closing: `✔ Test run with 138 tests in 20 suites passed after 116.190 seconds`. That is
    `StableSurfaceTests`, `SurfaceSizeMemoryTests`, the three `ReadingFlow` suites,
    `BookOutlineHeightsTests`, `BookHeightManifestTests`, `LandingAuthorityTests`, `BookAnchorTests`
    and **all eleven Tutorial suites, green**, with zero skipped. Its 9 warnings are all in one
    Tutorial takes act (`branchOnAClosedFanRevealsTheNewTake`, panes, `PaneSurface`), the same 9
    C2's closing run saw there.
  - In all, 417 tests / 75 suites ran on the final tree. The only issues were those two known
    deltas.
- **No PROVISIONAL, no QUESTIONS entry** (#147 unused). Nothing product-shaped arose.

### NOTICED, NOT TOUCHED (C3's scope fence)

1. **For 18l (A1's ruling): `PanePublisher` is not the "estimated majority" of the warning count.
   It is ALL of it** in every run this unit made (1,181 harness, 29 in-app), mostly inside
   `PaneSurface.makeNSView`. The heaviest single generators are the Takes article tests (~80–113
   each: `theBloomDoorStillGoesToTheBlockTheRingWasLastIn`,
   `aPlainRoundTripComesBackToTheSameLineNotOnlyTheSameRow`, …). The review document itself
   (`notes/codebase-health-review-2026-09-21.md` §5.1) is untouched; annotating it is the
   orchestrator's call.
2. **The walk-tooling trap:** a directly launched Debug binary needs `OS_ACTIVITY_DT_MODE=YES` for
   SwiftUI's runtime issues to reach stderr. Without it the count reads a false ZERO (walk 1 did,
   positive control included). One line in `Tools/WalkKit/README.md` would save the next walker.
   It is left for the orchestrator, because the tooling doc is shared.
3. **The Outline and Index hops (group D) are harmless but not free of history:** every landing pin
   was measured WITH them. A future cleanup that removes them is a timing change and would need
   the landing suites re-run, so it is not recommended as hygiene.
4. `BookIndexView:791` fires once per mount at any window width above the 640-pt column cap. That
   is fine, and recorded so nobody reads "1 entry" as a dead action.
5. `CommentsPanel`'s view is mounted by no suite (its tests drive `CommentsPanelModel`), and neither
   are `ShelfView`, `TakesBottomBar` or `ProseTakeCard` directly (they were reached through their
   hosts). A mount smoke for the panel would be cheap for whoever next owns it.
6. C2's noticed item 7 (`BookOutlineLandingTests`' stale "realizes twice" comment) is still there,
   because this unit did not touch that file.
7. The DEBUG oracles in group S (38 sites) are C4's ownership sweep, listed not touched.

### THE GUI WALK — HELD for the author (her steps; ~5 minutes on the dev-store Debug build)

Nothing she sees should change, because this unit changed only comments. The walk confirms the
measurement.
1. Run the dev-store Debug build (Xcode's Run). Open **Console.app**, filter on *Modifying state
   during view update*, process **Variorum**.
2. Open **Sherlock** in **Index**. Drag the window narrower, then wider, and scroll the pane from
   top to bottom. Expect **no** Console lines, and no rows jumping under the scroll.
3. Switch the book to **Outline** and repeat step 2. Expect none.
4. Open a note in **Canvas**. Drag a card, scroll the board, and resize the window. Expect none,
   and the card lands where it was dropped.
5. Open a note in a **new window** and close it. Then File ▸ **New Window**, and close that too.
   ⌘-Tab to another app and back: the note you were editing stays live (the sticky key). Expect
   none.
6. **The control:** switch a note to **Takes**. Console WILL print lines here. They are
   `PaneSurface`'s, the family 18l owns, and they are expected.

### CAPTURES

None possible (see the first line). The evidence is the harness logs and the in-app walk logs.
- **Harness logs** (`App/Variorum/DerivedData/`): `18k-c3-mech1.log` (M1),
  `18k-c3-attr{A,B,C}.log` (M2, probed), `18k-c3-before-{A,B}.log`, `18k-c3-hollow-B.log`,
  `18k-c3-after-{A,B}.log`, `18k-c3-canvasdrag-{1,2,3}.log` and `18k-c3-closing1.log`, with the
  set scripts beside them (`18k-c2-warnset.sh`, `18k-c3-setB.sh`, `18k-c3-closing.sh`).
- **In-app walk** (`notes/plans/18k-screens/c3/`, gitignored): `c3-walk1.log` (the false-zero
  capture) and `c3-walk2.log` (the real one), with the instruments `c3_probe_apply.py`,
  `c3_walk_apply.py` + `c3_walk_patch2.py` (+ its `c3_walk_drag_block.swift.txt`), `c3_attr.py`,
  and the M1 harness `C3ScratchMechanismTests.swift`. None of these was ever committed.

### UNIT C3 — ORCHESTRATOR ADJUDICATION (2026-09-25 night; the unit CLOSES here)

**Verified by spot-check:** 7 commits `7802ea6a`…`1d833ca0`, pushed, zero trailers, tree clean, zero
app instances, no scratch worktree left. The one code commit (`5286ff39`) has **zero non-comment
lines** (diff filtered by the orchestrator). **ACCEPTED — the review's §5.1 A3/A4/A5 premise is
DISMISSED AS HOLLOW by measurement:** a 14-shape minimal harness shows SwiftUI flags exactly one shape
(a state write inside `updateNSView`), and a bracketed in-app probe over 334 tests put **all 1,181
warnings inside `PaneSurface`'s make/update** — zero from 29,071 geometry-action entries (75 of 76
sites exercised), zero from window registration, `onAppear` or any other trigger; the brief's first
site (`BookIndexView:791`) deferred in scratch moved the count 1,126 → 1,134 (not kept). The
76-site verdict table (0 DEFERRED; SAFE-AS-IS / LEFT with reasons) is the unit's record. The six
comments that justified existing hops with the disproven reason now point at the true one; the hops
are byte-identical (every landing pin was measured with them). Two sites never entered by any run
(`CommentsPanel:795`, `ReferencePanel`'s views) rest on shape + reading — recorded as such.
**Carried forward:** (a) **for 18l U3 — `PanePublisher`/`PaneSurface` is ALL of the warning count in
every measured run, not "the estimated majority"; the Takes article tests are the heaviest
generators** — 18l's kickoff should read this adjudication; (b) the walk-tooling facts (Ghostty's
missing TCC grants; `OS_ACTIVITY_DT_MODE=YES` or a false zero) written into `Tools/WalkKit/README.md`
this commit; (c) C2's stale `BookOutlineLandingTests` comment → the ladder. **GUI walk HELD** (six
steps in the C3 RECORD; nothing visible changed — it would only confirm the measurement).

## UNIT C4 BRIEF — the DEBUG-oracle ownership sweep (self-contained; read in this order)

**You are the C4 implementer (`opus-implementer`), ONE unit, this session only.** Read, in order:
1. `CLAUDE.md` (auto-loaded).
2. THIS FILE: the kickoff corrections, THE LEDGER (row C4), **ENVIRONMENT TRAPS (binding)**, CAST &
   DISCIPLINE, the closing sections + ORCHESTRATOR ADJUDICATIONS of every earlier unit record (the tree
   moved — C3's verdict table names 38 geometry actions that write ONLY DEBUG statics: those are your
   population's writers, a ready-made enumeration to check yours against), and this brief.
3. `notes/codebase-health-review-2026-09-21.md` §5.2 — a REVIEW record; re-trace every claim.
4. **The three reference fixes — the shape you apply:** `ShellRouter.blockNamingDoors`
   (`ShellRouter.swift:~247` — owner-keyed map + an owner stack, `publish(owner:)`/`release(owner:)`,
   a reset for pins; the 13u4 UNIT S3 record in `notes/plans/phase-13u4-restyle.md` explains it and
   its pins `ShellDoorOwnershipTests`), `PostDetailOracle.stamp*` and `CatalogStampOracle`
   (`LibraryTimeFace.swift:~404`; the 13u4 UNIT S2 record; pins `StampOracleOwnershipTests`). **The two
   rules:** the registrant names itself (a window/owner identity it already has), and a teardown clears
   only what it still owns.

**The instances (review §5.2):** `BookOutlineGeometry.focusDoors` (`BookView.swift:~1764` — the
clearest: two windows on one book cross-clear each other's doors, and its closure captures a
`@State`-owned model) · `PostDetailOracle`'s four UNKEYED singletons (`PostDetailView.swift:~1022`;
`beginTitleEditing` is never cleared by anyone) · the unkeyed frame singletons `ShellGeometry`
(`ShellSplit.swift:~186`) · `CommitBarGeometry` (`CommitBar.swift:~920`) · `CanvasArrivalOracle`
(`CanvasView.swift:~1163`) · `BookIndexGeometry` (`BookIndexView.swift:~48`) · the two append-only
trace buffers never cleared by `resetNavigator()` (find them) · `SidebarGeometry`'s (`SidebarView.swift
:~783`) and the seam grip's subject-keyed-not-owner-keyed maps. **Re-grep for the class** (`static var`
dictionaries/closures/frames in `#if DEBUG` oracle enums across the Mac app) so your table is COMPLETE
— the review's list is a sample.

**Acceptance:** a per-oracle verdict table (oracle × registrant identity used × clear rule × pin) —
FIXED · SAFE-AS-IS (with the mechanism — e.g. read only by one pin that mounts one window) · LEFT (with
reason). **Pins:** the two-window cross-clear test the reference fixes model — MEASURED RED FIRST where
reachable (mount two owners, tear down one, assert the survivor's registration still answers); where
SwiftUI teardown order cannot be forced, the fix stands on the structural arm (S2's recycled-card
precedent) — say which per row. Every existing pin that READS these oracles must ride UNMODIFIED
except where the API itself changes (then ONE line per call site, recorded — S3's precedent). DEBUG-only
blast radius: production behaviour byte-identical (grep proof that every touched symbol is inside
`#if DEBUG`, or state why not).

**The one non-DEBUG guard:** `MarkdownStyling.palette` (`Theme/MarkdownStyling.swift:~107`) has three
writers, one of them a pane's `updateNSView` (`applyFace`, "the third writer of that global") — fine
while appearance is app-wide, a race the day anything is per-window. Add a doc comment naming the
three writers and the invariant (appearance is app-wide), plus a pin that fails if a fourth writer
appears or a writer diverges (a source-walk pin in the 18j literal-colour pin's form is acceptable).
No behaviour change.

**Use-shaped evidence:** this is a harness unit — the evidence IS the pins + the per-oracle table. The
terminal host holds no Screen Recording / Accessibility; do not drive the GUI.

**Closing runs (tests at the END):** every suite that reads a touched oracle (grep for each symbol
across `VariorumTests`) + your pins + the eleven Tutorial suites, each read by its "Test run with N
tests" line; no full Mac suite.

**CHECKPOINT RULES (restated, binding from your first commit):** write `## UNIT C4 RECORD` with its
`### LIVE STATUS` at the END of this file in your FIRST commit, and flip it in the same commit as each
piece; unverified claims marked **PENDING**. Commit per coherent piece and PUSH after every commit;
stage pathspec-limited, never `git add -A`; NO commit trailers (no Co-Authored-By, no Claude-Session).
Synchronous foreground waits only — the grep-poll loop; never end your turn with a run in progress.
Never spawn subagents (one Sonnet lookup for EXTERNAL facts only). No behavioural revert starts until
the record names it and the pre-revert state is COMMITTED. Every death/resume noted in the record. If
the worktree moves under you, write nothing, report, stop. Never touch `/Applications`, never build
Release, never quit or kill a real-store Variorum instance.

**Scope fence:** C4 only. Zero `Sources/`, zero `Sync/`. QUESTIONS: check the end marker for the next
free number. **Your final message:** a short summary pointing at your record.

## UNIT C4 RECORD — the DEBUG-oracle ownership sweep (implementer: `opus-implementer`, 2026-09-25)

**NOT DONE (first line, per the brief):** (1) **the parallel-suites axis is NOT fixed** — two LIVE
surfaces in two different TESTS on one UNKEYED slot still answer from the last writer, which can be
the other test's (13u2 UNIT E's session-scoping axis, KnownIssues row 50's class; the three reference
fixes share it). It bit this unit's own pins at the first closing run and is why the seven two-window
pins over unkeyed singletons are an OPT-IN suite (run alone; `DebugOracleSingletonWindowTests`), with
the synchronous structural arm as their always-on guard; the unscoped oracles it exposes are listed
under NOTICED for an owner's call. (2) **No GUI walk and no captures** — a harness unit, and the host
holds no Screen Recording / Accessibility; the pins and the table are the evidence (the brief's own
terms). (3) No full Mac suite (the orchestrator's finals), no `swift test`, no iOS build — zero
`Sources/`, zero `Shared/`, zero mobile. (4) The session-scoped oracles (SAFE-AS-IS (B)) were not
given owners WITHIN a session; the table says why that is safe for every reader today.

### READING (done in-session before any code)

CLAUDE.md + canon (auto-loaded); this file's kickoff corrections, THE LEDGER (row C4), ENVIRONMENT
TRAPS, CAST & DISCIPLINE, the C1/C2/C3 records' closing sections + all three ORCHESTRATOR
ADJUDICATIONS, C3's verdict table (group S — the 38 geometry actions that write only DEBUG statics),
and the C4 brief; the health review §5.2 (re-traced below, claim by claim); the three reference fixes
at the code AND their records — `ShellRouter.blockNamingDoors` (`ShellRouter.swift:226–280`, the 13u4
UNIT S3 record's ROW 46 + `ShellDoorOwnershipTests`), `PostDetailOracle.stamp*`
(`PostDetailView.swift:1016–1153` + `MastheadStamp.swift:131–197`) and `CatalogStampOracle`
(`LibraryTimeFace.swift:398–512`) (the 13u4 UNIT S2 record's ROW 51 + `StampOracleOwnershipTests`);
and the 13u2 UNIT E scoping rule (`Core/Views/DebugProbeScope.swift` + `DebugOracleScopingTests`),
which is the OTHER axis (parallel suites) and bears on the classification.

### THE POPULATION (re-grepped; the review's list is a sample)

A scratch parser walked every `.swift` file under `App/Variorum/Variorum/`, tracking `#if DEBUG` /
`#else` / `#endif` nesting, and listed every `static var` (and `static let`) with its enclosing type:
**188 `static var`s; 101 inside `#if DEBUG` across 38 DEBUG types** (the DEBUG `static let`s are
constants — `DebugProbeScopeKey.defaultValue`, `TakeCardGeometry.reportLimit`). Outside DEBUG the only mutable process-global stores are `MarkdownStyling.storedPalette`
(the brief's non-DEBUG guard), `EditorTypography.current`/`isAdopted` (the review's "same class,
lower risk"), `FallbackCanary.assertionHandler` and `FlowHeightEstimate.metricsCache`. `Shared/`
carries two more DEBUG-shaped statics (`KeychainCustody`'s trip counters — custody code) and two
seeder latches (owner-keyed by construction). Every app-side WRITER of every DEBUG oracle was then
listed (135 lines + the multi-line ones found by hand) — the verdict table below carries them.

### THE CLASSIFICATION RULE (decided before any code — stated so the table can be checked)

The reference fixes' own definition of the defect: **a registration keyed by its subject (or not
keyed) with no record of WHO registered it, so a departing view tears down — or leaves standing over —
a registration that belongs to a view still on screen.** Two arms: **cross-clear** (a teardown clears
a slot another live owner wrote; the survivor reads nil) and **stale-standing** (nothing clears it;
a departed owner's value or closure stays the answer while a live owner stands).
- **FIXED** — a LAST-VALUE registration (a door, a surface fact, a frame, a per-row map) in a
  PROCESS-GLOBAL slot whose key does not name its registrant. Fix = the reference shape: the
  registrant names itself, the read answers from the last LIVE writer (what the static answered while
  every writer stood — see THE DESIGN for why not "the first registration"), a teardown releases only
  its own, a pin's reset stays unconditional ("a pin owns nothing").
- **SAFE-AS-IS (A) accumulators** — counters, +1/−1 mount refcounts, set unions, logs: every owner's
  contribution composes and none can erase another's, so neither arm exists.
- **SAFE-AS-IS (B) session-scoped worlds** (13u2 UNIT E) — every write lands under the WRITING
  session's scope and every read names the reader's own; no teardown writes them. Another test can
  neither clear nor overwrite a pin's rows; two owners on one scope exist only inside one test, which
  orders its own mounts.
- **SAFE-AS-IS (C) already owner-keyed** (keyed by a workspace's identity; the three references).
- **SAFE-AS-IS (D) the value is a function of its key** — any registrant writes the same value, so
  no order can change the answer.
- **LEFT** — with the reason.

**The one axis this unit does NOT fix, stated so nobody reads it as fixed:** two LIVE owners in
different tests on one unscoped slot (parallel suites) — owner-keying answers from the last live
writer, which can be the other test's. That is the 13u2 UNIT E scoping axis (row 50's), and the
references share the residual (`ShellRouter.blockNamingDoor` answers from the most recent shell,
whoever mounted it). Oracles with that exposure are listed under NOTICED.

### THE DESIGN (as built — two points differ from the plan first written here, both recorded)

One DEBUG-only generic in `Core/Views/DebugOracleOwnership.swift` (beside `DebugProbeScope.swift`;
the whole file, imports included, is `#if DEBUG`): `OwnedRegistrations<Key, Value>` — per key, the
LIVE registrants in the order they last wrote, the last one the answer; `publish(_:for:owner:)`
replaces the owner's value and makes it the newest (an in-place write when it already is — geometry
rate); `withdraw(_:owner:)` and `release(owner:)` take ONLY the owner's own (a reverse index keeps a
teardown ∝ what it wrote); `value(for:owner:)` is the read-modify-write door; `forget`/`forgetAll` are
the pin's unconditional doors — plus `OwnedSlot<Value>` for the unkeyed singletons (an optional
`Value` registers "nothing" as a fact), `DebugOracleLog.bound` (the 13u2 UNIT E `TakeCardGeometry`
rule for append-only logs, shared), and the `debugOracleOwner` environment value. The registrant is
the VIEW that writes: its own DEBUG `@State private var oracleOwner = UUID()` (the `MastheadStamp`
shape; `RootView` uses the `windowID` it already had); a surface whose ROWS write (separate structs,
probe extensions — now modifiers, the `TakeCardGeometryProbe` reason) hands its token down by
environment (the `debugProbeScope` road, one level down) so a row's registration lives exactly as
long as the surface that drew it; a probe with no owning surface above it falls back to
`DebugOracleOwner.unowned` (never released — the pre-C4 behaviour, for that case only; no mount path
in the app or the suite hits it). Reads keep their names and types (computed, get-only — an unowned
write is now a COMPILE error), so reading pins ride unmodified; a pin that ASSIGNED a reset changed
ONE line to a named reset door (S3's precedent, 21 lines, listed below).
**Differs from the plan:** (1) the order was first "the most recent FIRST registration" — replaced by
the last live writer after the first closing run (the trace is under LIVE STATUS: the first design
would have changed every existing unkeyed reader's live behaviour under parallel suites); (2) the plan
named one central release list (`DebugOracleOwners.release`) — not built: each registrant releases
its own oracle in its own `onDisappear` (explicit, local, and a Core file would otherwise have had to
name every Features oracle).

### LIVE STATUS

- Reading + population + the classification rule — DONE (this commit).
- The two-window pins (red first where reachable) — WRITTEN AND MEASURED RED ON THE PRE-FIX TREE (this
  commit). `VariorumTests/DebugOracleTwoWindowTests.swift`, 12 tests, written against the read names the
  tree ALREADY has so each compiles on both sides; every one mounts the same kind of surface in TWO real
  windows whose registrations differ, tears one down, and asks the oracle about the one still standing.
  **THE PRE-FIX RUN (`DerivedData/18k-c4-old4.log`, `DerivedData/18k-c4-pins.sh`): `✘ Test run with 12
  tests in 1 suite failed after 21.533 seconds with 31 issues` — every precondition green (each test
  first proves the two windows reported DIFFERENT values), every red a post-teardown assertion, each the
  closed window's value:**

  | pin | issues | what the pre-fix tree answered after the teardown |
  |---|---|---|
  | `thePostDetailsSingletonsAnswerForTheWindowStillOpen` | 4 | `titleShown` "beta, the window that goes"; `inspectorPanel` β's `.tray`; `sideColumnDividerFrame` β's `(479,0,1,560)`; `beginTitleEditing` drove β's torn-down title, so α's open mark never came |
  | `aBookInTwoWindowsKeepsTheOpenWindowsDoorAndNavigator` | 6 | navigator `…×600` and its seam `…×600` against the open window's `…×900`; `focusDoors[book]` **nil** after the NEWER window's teardown AND after the OLDER one's — both cross-clear arms — so neither survivor could be focused |
  | `theBarsGeometryIsTheOpenBarsAfterTheOtherCloses` | 2 | `barWidth` 480 pt off (the closed 420-pt bar's); `rowFrame` the closed bar's compact `(12,6,396,18)` vs `(12,6,876,18)`; its `mounted` refcount control GREEN (SAFE-AS-IS (A)) |
  | `theReadHostsFaceAndSelectionAreTheOpenWindows` | 2 | `face` β's `.edit` (α rests on `.read`); `selectedBlockID` β's block |
  | `oneNoteReadInTwoWindowsKeepsTheOpenWindowsFrames` | 4 | `faceFrames`, `indexColumnFrames`, `editBlockFrames` and the index column's `SeamGeometry` row all the short window's (`…×484` vs `…×714`; the row `(375,62,411,71)` vs `(400.5,62,640,50)`) |
  | `aBookIndexInTwoWindowsKeepsTheOpenWindowsColumnAndPanes` | 2 | `columnFrames` `…×560` vs `…×900`; `paneNoteHeights` 141 vs 99 |
  | `theLibraryCatalogInTwoWindowsKeepsTheOpenWindowsFrames` | 3 | `rootFrame`, `dividerFrame`, `panelFrame` the short window's (`…×520` vs `…×700`) |
  | `aCanvasInTwoWindowsKeepsTheOpenWindowsArrival` | 1 | `viewport` `(760,486)` vs `(1300,826)` |
  | `theTakesArticleDoorIsTheOpenWindows` | 1 | the door at x 48 (the narrow window's) vs 318 |
  | `aReadingFlowInTwoWindowsKeepsTheOpenWindowsRowTops` | 1 | the second story's top 497 (narrow) vs 397 |
  | `aNoteInTwoShellsKeepsTheOpenShellsSeamAndRail` | 3 | the shell seam's line and grip `…×452` vs `…×932`; `railGroupHeights` 198 (compressed) vs 240 |
  | `aBookInTwoShellsKeepsTheOpenShellsNoteBox` | 2 | `noteBoxFrames` `(12,205,206,198)` vs `(12,235,206,240)`; the where-line "2 of 2 in this book" vs "one · 1 of 2 · block 1/1" |

  Two runs before the recorded one are not findings: `18k-c4-old1.log` crashed two tests on the
  live-store fallback (the helper had not installed the `database` dependency), and `18k-c4-old3.log`
  failed ONE precondition — the two Library catalogs lay out at the same (minimum) width, so their
  note rows are the same rectangle and `noteRowFrames` cannot be separated in that fixture; it was
  dropped from the pin (it rests on the structural arm) before the recorded run.
- The generic — DONE (this commit): `Core/Views/DebugOracleOwnership.swift` (all `#if DEBUG`) —
  `OwnedRegistrations<Key, Value>`, `OwnedSlot<Value>` (an optional `Value` registers a "nothing"),
  `DebugOracleLog.bound` (the 13u2 UNIT E `TakeCardGeometry` rule for append-only logs, shared) and the
  `debugOracleOwner` environment value. Its structural pins — DONE (`c85b48c8`, below).
- The conversions — DONE (`9fe6ae5d`), **12** oracle types in 16 app files (that commit's message and
  this line first said 13 — a miscount, corrected here, the history left as it is), every change inside `#if DEBUG`
  (the proof: DONE at close, below): `BookOutlineGeometry` · `BookIndexGeometry` · `ReadingFlowGeometry`
  · `ReadModeOracle` · `LibraryPanelOracle` · `PostDetailOracle` (the four singletons) · `ShellGeometry`
  · `CommitBarGeometry` (row + width) · `CanvasArrivalOracle` · `TakesArticleDoorProbe` ·
  `SidebarGeometry` (rail + box maps) · `SeamGeometry`. Each registering view now holds a DEBUG
  `@State private var oracleOwner = UUID()` (the `MastheadStamp` shape) and releases it in its
  `onDisappear`; the Outline's navigator rows, the Index's rows/panes, the Read host's rows and the
  catalog's probes read their surface's token by environment (their probe extensions became modifiers,
  the `TakeCardGeometryProbe` reason); the Takes article door's modifier names itself; the shell's pane
  seam registers under `RootView.windowID` (the identity it already had). The three landing traces and
  the catalog's two realized-row lists are LOGS (SAFE-AS-IS (A)) and gained only the bound.
  **Build:** `** TEST BUILD SUCCEEDED **` (`DerivedData/18k-c4-bft1.log`); every warning in a touched
  file is a kind that file already carried before C4 (found in C3's logs: `probeSpace`/`frameSpace`/
  `outlineSpace`/`flowSpace`/`surfaceSpace`/`space` from Sendable closures, `Content.Type` capture) —
  none new.
  **THE FIX, MEASURED:** `DebugOracleTwoWindowTests` on the fixed tree — `✔ Test run with 12 tests in 1
  suite passed after 19.481 seconds` (`DerivedData/18k-c4-new1.log`). RED 31 → GREEN 0.
  **The 21 pin lines whose API changed** (S3's precedent — ONE line per call site, each an ASSIGNMENT
  that became the named reset door, the pin's body untouched): `PostDetailOracle.sideColumnDividerFrame
  = nil` → `.forgetSideColumnDivider()` (`BlockHistoryPaneTests:154`, `NoteVersionsPaneTests:113`,
  `SideColumnTests:118`, `TrayPanelMoveTests:108`) · `BookOutlineGeometry.anchorTops = [:]` →
  `.forgetAnchorTops()` (`BookOutlineLandingTests:341,390,485,626,747`) · `BookOutlineGeometry.rowHeights
  = [:]` → `.forgetRowHeights()` (`BookCardHeightStabilityTests:158`) · `BookOutlineGeometry.focusDoors[id]
  = nil` → `.forgetFocusDoor(id)` (`NoteBoxMountTests:656`) · `ReadingFlowGeometry.anchorTops = [:]` →
  `.forgetAnchorTops()` (`ReadingFlowLandingTests:199,239,280,396,502,574`) · `BookIndexGeometry.
  paneContentSpans = [:]` → `.forgetContentSpans()` (`BookIndexColumnHeightsTests:188`) ·
  `SidebarGeometry.railGroupHeights[id] = nil` → `.forgetRail(id)` (`NoteBoxMountTests:172,389`) ·
  `SidebarGeometry.noteBoxFrames[id] = nil` → `.forgetBoxFrame(id)` (`NoteBoxMountTests:194`). Every READ
  rides unmodified (the read names and types are unchanged, computed and get-only — so an unowned write
  is now a compile error, not a runtime surprise). The reader suites' run: DONE (the closing runs, below).
- The structural pins — DONE (this commit): `VariorumTests/DebugOracleOwnershipTests.swift`, 18 tests —
  the container's rules one pin each (newest answers + a re-publish keeps its place · a teardown takes
  only its own FROM EITHER SIDE · a release reaches every key its owner holds and no other · a stranger's
  or a double release is a no-op · withdraw takes one key · a pin's forget is unconditional · an owner's
  own value · an optional slot registers "nothing" as a fact · the log bound) and EVERY converted oracle
  driven through its own doors by two owners (newer leaves → every read is the older's; older leaves →
  nothing) — which is where the fields the mounted pins could not separate stand (the catalog's note
  rows, the Outline's anchor tops/row heights/navigator rows, the Index's two glyphs/wash/prose
  edges/anchors, the Read host's `form`/`liveBlockID`/page rows, the canvas's landing and content size,
  the box's header) and where a field forgotten in its oracle's `release(owner:)` would go red. RED ON
  OLD by non-compilation (S2's card-pin shape): none of these doors existed.
- The `MarkdownStyling.palette` guard — DONE (this commit): the doc comment at the declaration names the
  three writers (`RootView.adoptMarkdownPalette` · `NSTextView.applyVoiceChrome` · `PaneSurface.applyFace`)
  and the invariant (appearance is app-wide, so all three resolve one value; per-window anything makes
  them a race); `VariorumTests/MarkdownPaletteWritersTests.swift`, a source walk in the 18j
  `NoLiteralColourTests` form, three arms: exactly the three writers with their exact right-hand sides ·
  every `MarkdownStyling.Palette` outside its file built `Palette(tokens:)`, the pane's face built at its
  one site and handed to the one representable · appearance app-wide (an `NSAppearance(named:)` only in
  `AppearanceChoice`, no `preferredColorScheme(` / `environment(\.colorScheme` override). Green on this
  tree. **ITS TEETH — NEXT, named here before they run (scratch mutations on the committed tree, each
  restored by `git checkout -- <file>`):** M-fourth (a fourth writer in `RootView`) → arm one red;
  M-diverge (the pane's face built without the tokens) → arm two red; M-scheme (a
  `.preferredColorScheme(.dark)` on a view) → arm three red.
- **The unit's pins, fixed tree (`DerivedData/18k-c4-new2.log`): `✔ Test run with 33 tests in 3 suites
  passed after 19.903 seconds`** (12 two-window + 18 structural + 3 palette).
- The palette pin's TEETH — DONE (`DerivedData/18k-c4-palette-teeth.log`): the three named mutations
  applied together on `c85b48c8` → `✘ Test run with 3 tests in 1 suite failed … with 3 issues`, each arm
  red on its own mutation and naming it (arm one: the fourth writer `MarkdownStyling.palette =
  .systemFallback` in `RootView.swift`; arm two: the pane face `tokens.map { _ in
  MarkdownStyling.Palette.systemFallback }`; arm three: `RootView.swift:1057 … preferredColorScheme(.dark)`).
  Restored by `git checkout -- RootView.swift Surface/PaneSurface.swift`; `git diff --quiet HEAD` true.
- **THE FIRST CLOSING RUN, AND WHAT IT CHANGED** (`DerivedData/18k-c4-closing1.log`, 64 suites): `✘ Test
  run with 413 tests in 64 suites failed after 232.849 seconds with 6 issues` — two are KnownIssues row
  65's macOS-27 deltas (`LibraryPanelHostTests`' "inspector" composition pin; `RefontViewportTests.
  aShrinkingRefontKeepsTheLineAtTheViewportTop`, 42034 vs 42128 — its 94 pt), and **four were THIS
  unit's own pins, all one mechanism: an UNKEYED slot read while another suite's surface of the same
  kind was live** — the structural pins' final "nothing stands" checks (`chapterCountFrame`,
  `titleShown`, `beginTitleEditing` — other suites' live Index/detail answered) and the mounted
  post-detail pin (`sideColumnDividerFrame → (679,0,1,750)`, another suite's detail with a panel open).
  That is precisely the axis this record says C4 does not fix — biting the unit's own pins. Three
  changes followed, each traced:
  1. **The container's order — last LIVE writer answers** (was: the most recent FIRST registration).
     The first design would have changed every existing unkeyed reader's live behaviour under parallel
     suites: a surface mounted later by another suite would have shadowed a pin's own surface for its
     whole life, where before C4 the pin's own next write won. The last-writer order is exactly what the
     bare static answered while every writer stood (ShellRouter's own publish order), so no reader's
     live behaviour moves; the only change is the one C4 exists for — a teardown hands the slot back
     instead of clearing it or leaving a stale value. `publish` keeps the common case (the owner is
     already the newest) an in-place write. The structural pin became `theLastLiveWriterAnswersAsTheStaticDid`.
  2. **The structural pins' "afterwards" checks on UNKEYED slots** say THIS test's registration is gone
     (`!= rect(1)`, `!= "older"`, …), not "nothing stands"; their "the older answers after the newer
     leaves" checks are synchronous (no other suite can interleave) and stand as written.
  3. **The two-window pins split in two** (the rig shared as `protocol DebugOracleWindowRig`):
     `DebugOracleTwoWindowTests` keeps the six pins over slots KEYED by a live uuid the pin minted (exact
     under parallel suites — always on); `DebugOracleSingletonWindowTests` takes the seven over UNKEYED
     slots and is OPT-IN — the drills' pattern (`ProtectionMigrationDrillTests`), `.enabled(if:
     VARIORUM_ORACLE_SINGLETON_WINDOWS == "1")`, run alone with `TEST_RUNNER_VARIORUM_ORACLE_SINGLETON_
     WINDOWS=1`. The Read host's first-paint arm moved into the opt-in face/selection pin (it is
     unkeyed); the shell seam left the rail pin for its own opt-in pin (`aShellInTwoWindowsKeepsTheOpen
     ShellsSeam`). The always-on guard for the unkeyed slots is the structural arm.
  **Fixed tree after the three:** always-on `✔ Test run with 27 tests in 3 suites passed after 11.788
  seconds` (`18k-c4-new3.log`: 6 keyed + 18 structural + 3 palette); opt-in, alone, `✔ Test run with 7
  tests in 1 suite passed after 10.051 seconds` (`18k-c4-new-singletons.log`).
- **THE FINAL PIN FORMS, RE-MEASURED RED ON THE PRE-FIX TREE — DONE** (`DerivedData/18k-c4-final-forms-
  prefix.log`): a scratch worktree at `0a84adbc` (the pre-fix app and its own tests) with the two final
  two-window files copied in — both compile against the old read API — built with its own derived data;
  worktree and build REMOVED after (`git worktree list` shows only the two pre-existing ones). Keyed,
  always-on: `✘ Test run with 6 tests in 1 suite failed after 11.176 seconds with 16 issues`; unkeyed,
  opt-in, alone: `✘ Test run with 7 tests in 1 suite failed after 12.454 seconds with 16 issues`. **All
  13 red, every issue a post-teardown assertion, no precondition red**, the same values as the first
  measurement (the table above) plus the one new arm: the Read host's first edit-row paint answered β's
  `15:06:39` against α's none.
- **NEXT — the behavioural revert, named before it runs (M-norelease):** on the committed final tree,
  `OwnedRegistrations.release(owner:)`'s body replaced by `return` (the fix's hand-back road cut at its
  one door; every oracle's `release` and every slot's forwards to it), then the always-on pins run —
  expected RED: the structural arm's "after the newer leaves" checks and the keyed two-window pins.
  Restored by `git checkout -- App/Variorum/Variorum/Core/Views/DebugOracleOwnership.swift`.
- **M-norelease — RAN (`DerivedData/18k-c4-M-norelease.log`): `✘ Test run with 27 tests in 3 suites
  failed after 11.995 seconds with 82 issues`** — all 6 keyed two-window pins red and 16 of the 18
  structural pins (the two that stay green by design never call `release`: an owner's own value, the
  log bound); the 3 palette pins green (unrelated). Restored; `git diff --quiet HEAD` true; zero
  `M-norelease` strings in the tree. The final pins bite the fix's own mechanism.
- **Release projection — made EXACT (this commit):** the new file's two imports moved inside its
  `#if DEBUG`, so a Release build compiles `DebugOracleOwnership.swift` to nothing. The proof script
  (`release_projection.py`, session scratch): for every app file the C4 diff touches, the lines a
  non-DEBUG build compiles (DEBUG branches dropped, `#else` kept, directives/comments/blanks dropped),
  old vs new — **final run over `0a84adbc..80b3787c`: `files 18; release projections that differ: 0`**
  (before this move it read 1 of 18: exactly those two imports). A line-level companion
  (`debug_proof.py`) flags 4 of 1,281 changed lines outside a DEBUG region — all four the diff's
  re-alignment of the Read probe's unchanged `#else self #endif` tail (`-617 self` / `+682 self` and
  two braces), which the projection shows is content-identical. `MarkdownStyling.swift`'s change is
  doc-comment lines only.
- **THE SECOND CLOSING RUN (`DerivedData/18k-c4-closing2.log`, the final tree before this commit):
  `✘ Test run with 414 tests in 65 suites failed after 226.036 seconds with 3 issues`** — the two row-65
  deltas again, the opt-in suite reported SKIPPED with its reason on all 7 tests (the gate works), and
  ONE flaw in this unit's keyed note-box pin, traced: shell one's where-line after shell two closed was
  shell ONE's, but in its not-live form (`"one · 1 of 2 in this book"`) where the pin had captured the
  live form (`"… · block 1/1"`). Both shells shared ONE session, and the one live editor is a
  session's (P-3), so shell two's focus legitimately stepped shell one's note down — the pin compared
  against state that had moved for a real reason, green or red by timing. **Fixed in the PIN** (this
  commit): the two shells get two sessions on one store (the post-detail pin's arrangement), and shell
  two's precondition names its own note (`hasPrefix("2 of 2")`) rather than "anything but line one".
  Keyed suite, fixed tree, ×3: `✔ Test run with 6 tests in 1 suite passed` each
  (`18k-c4-keyed-r{1,2,3}.log`).
- **The reworked pin re-measured on the pre-fix tree — DONE** (`DerivedData/18k-c4-final-forms-
  prefix2.log`, a fresh scratch worktree at `0a84adbc` with the final files; worktree and build
  REMOVED): keyed `✘ Test run with 6 tests in 1 suite failed after 11.229 seconds with 16 issues`,
  opt-in `✘ Test run with 7 tests in 1 suite failed after 12.583 seconds with 16 issues` — the
  note-box pin red on its two post-teardown lines only (box `(12,205,206,198)` vs `(12,235,206,240)`;
  where-line "2 of 2 in this book" vs "one · 1 of 2 · block 1/1"), its "2 of 2" precondition green.
- **THE FINAL CLOSING RUN — DONE** (`DerivedData/18k-c4-closing3.log`, `DerivedData/18k-c4-closing.sh`,
  final tree `80b3787c`, zero app instances): **`✘ Test run with 414 tests in 65 suites failed after
  225.951 seconds with 2 issues`** — BOTH KnownIssues row 65's macOS-27 deltas, nothing else:
  `LibraryPanelHostTests.aNoteSelectionStandsThePanelUpWithItsBoundaryActiveAndInactive` (the
  "inspector" composition pin, `LibraryPanelTests.swift:296`) and `RefontViewportTests.
  aShrinkingRefontKeepsTheLineAtTheViewportTop` (42034 vs 42128 — its 94 pt). 62 suites passed, 2
  failed (those), 1 SKIPPED — the opt-in suite, all 7 tests `skipped: "unkeyed slots are written by
  every parallel suite's surfaces — run deliberately and alone with TEST_RUNNER_VARIORUM_ORACLE_
  SINGLETON_WINDOWS=1"`. **All eleven Tutorial suites green.** The 65: every suite that reads a
  touched oracle (a grep over `VariorumTests` for the 12 converted types + `MarkdownStyling.palette` —
  50 suites, a deliberate superset), the touched surfaces' own mount suites not already in it
  (`BookViewTests`, `ShellDoorOwnershipTests`, `ShellLandingTests`, `WindowsTests`,
  `LibraryCardStampsTests`), the unit's four suites, and the eleven Tutorial suites.
- Deaths / resumes: none.
- **C4 — DONE (implementer), awaiting the orchestrator's spot-check.**

### THE VERDICT TABLE (every DEBUG oracle type in the Mac app — 38 — plus the non-DEBUG globals; the S3 form)

**Totals (38 types): FIXED 12 types (49 slots: 6+8+1+9+7+4+2+2+3+1+4+2) · SAFE-AS-IS 24 types (A 15
· B 6 · D 3), plus the SAFE fields inside FIXED types (A: the 3 traces, `pageTurns`, the 2 realized-row
logs, `mounted`, `noteBoxFaces` · B: `headerWorlds` · C: `starredSectionHeights`, `bodyEvaluations`) ·
FIXED-AT-13u4 (the references, untouched) 2 types (`ShellRouter`, `CatalogStampOracle`) +
`PostDetailOracle.stamp*` · LEFT 0.** (The closing commit's message says "51 slots" — a miscount,
corrected here; the history left as it is.) "Registrant" is the identity that now names itself; "clear" is the teardown
that releases ONLY that registrant's rows; pins: **TW** = `DebugOracleTwoWindowTests` (always on,
keyed), **SW** = `DebugOracleSingletonWindowTests` (opt-in, unkeyed), **ST** =
`DebugOracleOwnershipTests` (structural, always on). Every TW/SW pin was MEASURED RED on the pre-fix
tree in its final form (the LIVE STATUS numbers); every ST pin is red on old by non-compilation and
red under M-norelease on the final tree. Arm: **X** cross-clear, **S** stale-standing.

| # | oracle (file) | slots | kind / arm | verdict | registrant · clear | pins |
|---|---|---|---|---|---|---|
| 1 | `BookOutlineGeometry` (`BookView`) | `focusDoors` (book) · `navigatorFrames` (book) · `navigatorChapterRows` · `navigatorNoteRows` (row) · `anchorTops` · `rowHeights` (anchor) | X (the door) · S (the rest) | **FIXED** | the `BookView`'s `oracleOwner` (its navigator rows by environment) · `BookView.onDisappear` → `release` | TW `aBookInTwoWindows…` (both arms of the door; navigator; its seam) · ST `theOutlinesRegistrations…` (all six) |
| 1a | ″ | `trace` | log | **SAFE-AS-IS (A)**, bounded (`DebugOracleLog`) — one of the review's two "never cleared" buffers | — | ST (the bound) |
| 2 | `BookIndexGeometry` (`BookIndexView`) | `chapterCountFrame` · `noteMenuFrame` (unkeyed) · `columnFrames` · `paneContentSpans` (book) · `paneSelectionWashHeights` · `paneNoteHeights` (note) · `paneProseLeading` (block) · `paneAnchorTops` (anchor) | S | **FIXED** | the `BookIndexView`'s token (its note rows/panes by environment) · its `onDisappear`; the span's fold reads only its own row | TW `aBookIndexInTwoWindows…` (column, pane heights) · ST `theIndexsRegistrations…` (all eight, incl. the fold) |
| 2a | ″ | `trace` | log | **SAFE-AS-IS (A)**, bounded (it already had `reset()`) | — | — |
| 3 | `ReadingFlowGeometry` (`ReadingFlowView`) | `anchorTops` (story) | S | **FIXED** | the flow's token · its `onDisappear` | TW `aReadingFlow…` · ST `theFlowsRowTops…` |
| 3a | ″ | `trace` | log | **SAFE-AS-IS (A)**, bounded — the review's second "never cleared" buffer (no reset door at all) | — | — |
| 4 | `ReadModeOracle` (`ReadModeView`) | `face` · `form` · `selectedBlockID` · `liveBlockID` (one host-state slot) · `firstEditRowPaintedAt` (per host) · `pageBlockFrames` · `editBlockFrames` (block) · `faceFrames` · `indexColumnFrames` (note) | S | **FIXED** | the host's token (its page/edit rows by environment) · its `onDisappear` | TW `oneNoteRead…` (face frame, column, row, + seam) · SW `theReadHostsFace…` (face, selection, first paint) · ST `theReadHostsRegistrations…` |
| 4a | ″ | `pageTurns` | counter | **SAFE-AS-IS (A)** | — | — |
| 5 | `LibraryPanelOracle` (`LibraryInfoPanel` · `LibraryCatalogView`) | `rootFrame` · `dividerFrame` · `panelFrame` · `messageFrame` · `quickEntryFrame` · `bookLineFrame` (unkeyed) · `noteRowFrames` (row) | S | **FIXED** | the catalog's token, read by `libraryGeometryProbe` (now a modifier) · the catalog's `onDisappear` | SW `theLibraryCatalog…` (root, divider, panel) · ST `theCatalogsFrames…` (all seven — the rows the mounted pair could not separate) |
| 5a | ″ | `shownBlockIDs` · `shownOutlineRowIDs` | logs | **SAFE-AS-IS (A)**, bounded | — | — |
| 6 | `PostDetailOracle` (`PostDetailView`) | `inspectorPanel` · `sideColumnDividerFrame` (the detail) · `beginTitleEditing` · `titleShown` (the title label) — all unkeyed; the door never cleared by anyone | S (+ a closure over a dead view) | **FIXED** | the detail's token / the title label's token · each view's `onDisappear` | SW `thePostDetailsSingletons…` · ST `theDetailsSingletons…` |
| 6a | ″ | `stamp*` | — | **FIXED at 13u4 UNIT S2** (the reference) — untouched | the masthead's token | `StampOracleOwnershipTests` |
| 7 | `ShellGeometry` (`ShellSplit`) | `dividerLineFrame` · `dividerGripFrame` | S | **FIXED** | the `ShellSplit`'s token · its `onDisappear` | SW `aShellInTwoWindows…` · ST `theUnkeyedFrames…` |
| 8 | `CommitBarGeometry` (`CommitBar`) | `rowFrame` · `barWidth` | S | **FIXED** | the bar's token · its `onDisappear` | SW `theBarsGeometry…` · ST `theUnkeyedFrames…` |
| 8a | ″ | `mounted` | +1/−1 refcount | **SAFE-AS-IS (A)** — composes across owners by construction | — | — |
| 9 | `CanvasArrivalOracle` (`CanvasView`) | `landing` · `boardContentSize` · `viewport` | S | **FIXED** | the canvas's token · its `onDisappear` | SW `aCanvas…` (viewport) · ST `theUnkeyedFrames…` (all three) |
| 10 | `TakesArticleDoorProbe` (`TakesBoardView`) | `frame` | S | **FIXED** | the door's own modifier token (`ArticleDoorProbe`, the `CatalogStampRecorder` shape) · the door's `onDisappear` | SW `theTakesArticleDoor…` · ST `theUnkeyedFrames…` |
| 11 | `SidebarGeometry` (`SidebarView` · `SidebarNoteBox`) | `railGroupHeights` (note) · `noteBoxFrames` · `noteBoxHeaderFrames` · `noteBoxWhereLines` (book) | S — the review's named "subject-keyed, not owner-keyed" maps | **FIXED** | the column's token (the rail) / the box's token (its three) · each view's `onDisappear` | TW `aNoteInTwoShells…Rail` · `aBookInTwoShells…NoteBox` · ST `theRailAndTheBox…` |
| 11a | ″ | `headerWorlds` | session-scoped | **SAFE-AS-IS (B)** | — | `DebugOracleScopingTests` |
| 11b | ″ | `starredSectionHeights` · `bodyEvaluations` | keyed by the workspace (an owner) | **SAFE-AS-IS (C)** | — | — |
| 11c | ″ | `noteBoxFaces` | +1/−1 refcount | **SAFE-AS-IS (A)** | — | — |
| 12 | `SeamGeometry` (`SeamGrip`) | `lineFrames` · `gripFrames` (family·subject) — the review's named "seam grip" maps | S | **FIXED** | each `SideColumn`'s token; the shell's pane seam under `RootView.windowID` (its key already named the window's router) · `SideColumn.onDisappear` / `RootView.onDisappear` | TW (the navigator seam, the Read index column's seam) · ST `aSeamAnswers…` |
| 13 | `ShellRouter` (`blockNamingDoors`) | — | — | **FIXED at 13u4 UNIT S3** (the reference) — untouched | `RootView.windowID` | `ShellDoorOwnershipTests` |
| 14 | `CatalogStampOracle` (`LibraryTimeFace`) | — | — | **FIXED at 13u4 UNIT S2** (the reference) — untouched | the card's token | `StampOracleOwnershipTests` |
| 15 | `MastheadGeometry` (`PostDetailView`) | `worlds` | session-scoped | **SAFE-AS-IS (B)** (its per-note stamp row is S2's refcounted rule) | — | `DebugOracleScopingTests` |
| 16 | `CompareGeometry` · 17 `LensesGeometry` · 18 `BlocksWorkbenchOracle` · 19 `TakeCardGeometry` (bounded log) · 20 `TakeCardDoors` (union) | `worlds` / `byScope` | session-scoped | **SAFE-AS-IS (B)** | — | `DebugOracleScopingTests` |
| 21 | `BaselineProbe` (`BaselineProbe.swift`) | `offsets` · `tops` (probe id) | — | **SAFE-AS-IS (D)** — each probe reports in its ROW's own named space (`catalog-note-line`, …), so every row of a kind writes the same row-relative baseline under the one app-wide voice; its one reader asserts two ids agree within a point | — | `LibraryRowAlignmentTests` |
| 22 | `TakesCellChrome` (`TakesShared`) | `overlayWords` (variant) | — | **SAFE-AS-IS (D)** — the one call site records the constant `[]` | — | — |
| 23 | `TrayRowDoorProbe` (`TrayPanel`) | `verbs` (row) | — | **SAFE-AS-IS (D)** — the verbs are the row's own facts from the one store (put back, + delete now where `TrayPurgeDoor` says) | — | — |
| 24 | `TakesEmptyStateDoors` (`TakesShared`) | `rendered` | union | **SAFE-AS-IS (A)** | — | — |
| 25–36 | `PagedReadMaterialization` · `BookIndexMaterialization` · `BookOutlineMaterialization` · `ReadingFlowMaterialization` · `BookSpreadMaterialization` · `CanvasCardMaterialization` · `CanvasBankChipMaterialization` · `CutFlowRealization` · `BookIndexExtentReads` · `BookOutlineExtentReads` · `ReadingFlowExtentsReads` · `BookCardPreviewReads` | counts | counters | **SAFE-AS-IS (A)** (the two `*ExtentReads` are keyed by book — row 50's rule) | — | — |
| 37 | `TypewriterCaretClearance` (`EditorTextView` — the editor seam) | `applied` | counter | **SAFE-AS-IS (A)**, and fenced | — | — |
| 38 | `PaneSurfaceAudit` (`PaneSurface` — 18l's) | `foreignTextComparisons` | counter | **SAFE-AS-IS (A)**, and fenced | — | — |
| — | `MarkdownStyling.palette` (non-DEBUG) | the markdown face's live colours | three writers | **GUARDED** (the brief's one non-DEBUG item): the three writers + the app-wide invariant at the declaration; `MarkdownPaletteWritersTests` (three arms, each with teeth — M-fourth / M-diverge / M-scheme) | — | `MarkdownPaletteWritersTests` |
| — | `EditorTypography.current` / `isAdopted` (non-DEBUG) | the adopted typography | — | **not in C4's brief** — the review's "same class, lower risk"; NOTICED | — | — |
| — | `FallbackCanary.assertionHandler` · `FlowHeightEstimate.metricsCache` · `Shared/KeychainCustody` trip counters · `Shared/SampleLibrarySeeder` latches | — | — | **out of the population** — a test seam, a pure cache, custody counters (custody — never touched here), owner-keyed seed latches (the review: "checked clean") | — | — |

### DISPOSITION

**Ledger row C4 — FIXED.** The class is closed on the owner axis for every process-global DEBUG
registration in the Mac app: 12 oracle types, 49 slots, one generic
(`Core/Views/DebugOracleOwnership.swift`) in the reference fixes' shape — the registrant names itself,
a teardown clears only what it still owns, the last LIVE writer answers exactly as the static did.
Production byte-identical: Release projection 0 of 18 files differ.
- **Pins:** 13 two-window pins, every one MEASURED RED on the pre-fix tree in its final form (keyed
  6/16 issues, unkeyed 7/16; `18k-c4-final-forms-prefix2.log`) and green on the fixed tree (keyed ×3;
  unkeyed alone); 18 structural pins (red on old by non-compilation; 16 red under M-norelease, the
  other two independent of `release` by design); the palette guard's 3 source-walk pins (each arm red
  under its own mutation).
- **The review's §5.2 claims, re-traced:** `focusDoors` "two windows on one book cross-clear each
  other's doors" — TRUE, measured (nil after either teardown); `PostDetailOracle`'s four "unkeyed
  singletons", `beginTitleEditing` "never cleared by anyone" — TRUE, measured (the door drove a dead
  title); `ShellGeometry` / `CommitBarGeometry` / `CanvasArrivalOracle` / `BookIndexGeometry` "unkeyed
  frames" — TRUE, measured; "two append-only trace buffers never cleared by `resetNavigator()`" —
  `BookOutlineGeometry.trace` and `ReadingFlowGeometry.trace` (the third, `BookIndexGeometry.trace`,
  has a reset): a LOG is not a registration (no clear/overwrite arm), so their disposition is the
  bound; `SidebarGeometry`'s and the seam grip's "subject-keyed (not owner-keyed) maps" — TRUE,
  measured. The re-grep added five the review did not name: `ReadModeOracle` (the heaviest — read by
  7 suites), `LibraryPanelOracle`, `TakesArticleDoorProbe`, `ReadingFlowGeometry.anchorTops`, and the
  per-row maps inside the named oracles.
- **Existing pins:** every read rides unmodified; **21 lines** changed, each an ASSIGNMENT that became
  its named reset door (S3's precedent), listed under LIVE STATUS.
- **No PROVISIONAL, no QUESTIONS entry** (#147 unused): nothing product-shaped arose — every call was
  harness design, each recorded with its reason (the order, the split, the two-session pin).

### NOTICED, NOT TOUCHED (C4's scope fence)

1. **The parallel-suites axis on the UNKEYED oracles is live and pre-existing** — every pin that reads
   `PostDetailOracle`'s four, `CommitBarGeometry`'s two, `ReadModeOracle`'s host state / first paint,
   `LibraryPanelOracle`'s six frames, `CanvasArrivalOracle`, `TakesArticleDoorProbe`, `ShellGeometry`
   or `BookIndexGeometry`'s two glyph frames reads a slot any concurrently mounted suite writes (C4's
   own first closing run proved it on its own pins; the readers include `MastheadLayoutTests`,
   `SideColumnTests`, `TrayPanelMoveTests`, `BlockHistoryPaneTests`, `NoteVersionsPaneTests`,
   `CommitBarLayoutTests`, `ReadModeTests`, `ReadLandingTests`, `ModeSwitchCarryTests`,
   `CurrentBlockContinuityTests`, `ReadArrivalMeasureTests`, `LibraryPanelTests`, `CanvasArrivalTests`,
   `TakesEmptyBlockFaceTests`, `ShellChromeTests`). C4's order keeps their live behaviour exactly what
   it was (last write wins), so C4 adds no exposure — but the exposure is real, and it is 13u2 UNIT
   E's class: the fix is session-scoping these oracles the way UNIT E scoped six (a scoped read beside
   the unscoped one). Needs an owner (a candidate is the harness family, 12, or 18l beside its
   `PaneSurface` work). The same axis also reaches the unscoped COUNTERS a pin resets to 0 and then
   bounds (`*Materialization.count` read by `BookViewTests`/`CanvasBankTests`/`PagedReadTests`/…):
   another suite's mount adds to them.
2. **`EditorTypography.current` / `isAdopted`** — the review's "same class, lower risk" non-DEBUG
   global. Not in C4's brief; the palette guard's invariant (appearance app-wide) is its invariant too,
   so the same three-arm pin would extend to it cheaply.
3. **Session-scoped oracles within ONE session** (SAFE-AS-IS (B)): two same-kind surfaces under one
   session share a scope, and no teardown writes them — safe for every reader today (none mounts two).
   A future pin that does would need owners below the scope; the container is ready for it.
4. **The first closing run's note-box finding is a real product fact, not a defect:** the ONE live
   editor is a session's, so in the real app (one session, many windows) focusing a note in one
   window's book steps another window's book note down from live. By design (P-3); recorded because a
   reader of the where-line oracle will meet it.
5. The stale `/private/tmp/claude-501/u1-baseline-tree` worktree (not this run's) — untouched, as C1–C3
   left it.

### CAPTURES

None — a harness unit on a host without Screen Recording / Accessibility (the brief: "the evidence IS
the pins + the per-oracle table"). The logs, all in `App/Variorum/DerivedData/` (gitignored), with the
scripts beside them (`18k-c4-pins.sh`, `18k-c4-singletons.sh`, `18k-c4-keyed.sh`,
`18k-c4-palette.sh`, `18k-c4-closing.sh`): the pre-fix measurements `18k-c4-old{1,2,3,4}.log` (old1
the dependency crash, old3 the one precondition, old4 the recorded run) and
`18k-c4-final-forms-prefix{,2}.log`; the fixed-tree runs `18k-c4-new{1,2,3}.log`,
`18k-c4-new-singletons.log`, `18k-c4-keyed-r{1,2,3}.log`; the teeth and the revert
`18k-c4-palette-teeth.log`, `18k-c4-M-norelease.log`; the builds `18k-c4-bft{0,1}.log`; the closing
runs `18k-c4-closing{1,2,3}.log`. The proof scripts (`release_projection.py`, `debug_proof.py`) and the
population parser are session scratch — each is small enough to re-derive from its description here.

### UNIT C4 — ORCHESTRATOR ADJUDICATION (2026-09-25 night; the unit CLOSES here)

**Verified by spot-check:** 10 commits `02bcc320`…`a58b903b`, pushed, zero trailers, tree clean, zero
app instances, no scratch worktree left. The DEBUG gating spot-read: `DebugOracleOwnership.swift` is
wholly inside `#if DEBUG`, and the per-view owner tokens (`@State private var oracleOwner`) and their
releases are `#if DEBUG`-fenced at the touched views read; the implementer's Release-compile
comparison (0 of 18 touched files differ) is the production-identity proof. **ACCEPTED — C4 FIXED:**
38 DEBUG oracle types re-grepped; 12 types / 49 slots owner-keyed (FIXED), 24 SAFE-AS-IS with
mechanisms, 0 LEFT; 13 two-window pins measured RED on the pre-fix tree in their final form (32
issues), green after; 18 structural pins (red by non-compilation, and by the M-norelease revert — 82
issues); the 7 unkeyed-singleton pins opt-in (`TEST_RUNNER_VARIORUM_ORACLE_SINGLETON_WINDOWS=1`, run
alone) because the parallel-suites axis is NOT this unit's; 21 existing pin lines changed as named
reset doors (the S3 precedent), every READ unmodified. The mid-unit design correction ("the last live
writer answers" — what the bare static answered while every writer was on screen) is the right call
and is flagged for the ladder. **Palette guard:** the three writers documented + `MarkdownPaletteWritersTests`
(three arms, each red under its own mutation). **Closing run:** 414/65, the only 2 issues row 65's
(C6's). **Carried:** the parallel-suites axis + `EditorTypography.current` → a KnownIssues row, owner
12 (filed this commit). The one-live-editor-per-SESSION fact across two windows is P3 working as
designed — FYI, not a finding.

## UNIT C6 BRIEF — the five macOS-27 test deltas (KnownIssues row 65; self-contained; read in this order)

**You are the C6 implementer (`opus-implementer`), ONE unit, this session only.** Read, in order:
1. `CLAUDE.md` (auto-loaded) and `notes/TEXTKIT2_NOTES.md` (auto-loaded — §5's point-release matrix is
   exactly this unit's subject: the machine moved macOS 26 → 27.0 with the tree unchanged).
2. THIS FILE: the kickoff corrections, THE LEDGER (row C6), **ENVIRONMENT TRAPS (binding)**, CAST &
   DISCIPLINE, the closing sections + ORCHESTRATOR ADJUDICATIONS of the earlier unit records, and this
   brief.
3. `notes/KnownIssuesAndTechDebt.md` — the row beginning "**FIVE deterministic macOS-27 test deltas**"
   (your charter) and the RESOLVED row about the full-document editor's RE-FONT road (13u4 UNIT F2's
   fix — `EditorViewModel.keepingReadingPosition(acrossRefont:_:)`); 13y's kickoff-baseline record in
   `notes/plans/phase-13y-per-tenant-seq.md` (grep "macOS-27" / "Refont") for how the five were first
   adjudicated; 13u4's UNIT F2 RECORD in `notes/plans/phase-13u4-restyle.md` for the re-font design.

**The five, in two classes:**
- **TRACE items (possibly REAL product behaviour on 27 — the hallucination guard binds hard):**
  1. `RefontViewportTests.aShrinkingRefontKeepsTheLineAtTheViewportTop` — a deterministic **94-pt
     drift** on 27. Question: is F2's restore inexact on 27 (a real regression her place-keeping would
     feel), or has the test's measurement of "the line at the viewport top" changed meaning? Trace the
     park → settle hop → `JumpPrimitive` spend on 27 with numbers (the TK2 geometry of the anchor
     fragment before/after; which hop lands where). If REAL: fix on the smallest surface, pin
     red-on-old — **this is the editor seam; if the fix must touch `EditorTextView`, the storage seam
     or `JumpPrimitive`'s contract, make it the narrowest possible change and name it plainly in the
     record for the Fable ladder.** If the pin's measurement is wrong on 27, re-mechanize the pin and
     state why the product is right (with the measured evidence).
  2. `BoundaryFluidityTests.theKeystrokePathRoutesCrossBlockDeletesIntoTheCompound` — `status.spoken`
     nil under the harness's synthetic keystroke; **INTERMITTENT on 27** (red at 13y's kickoff twice
     incl. isolated, green at 13y's finals). Run it N times isolated and in its suite; find the
     covariate (harness routing vs real routing — does the synthetic keystroke reach the same
     `shouldChangeText` road the real key does on 27?). Verdict: harness fix (pin re-mechanized) ·
     real defect (fix + pin) · load-flake (joins the flake list with the paired-protocol numbers —
     only if you cannot find a mechanism, and say so).
- **PIN-MECHANISM items (the PRODUCT was verified in use at 13y's kickoff — re-mechanize the pin, never
  the product):** 3–4. the two `count(NSSlider) == 1` scrubber pins (`PagedReadViewTests` + the
  BookView spread) — SwiftUI's `Slider` is no longer `NSSlider`-backed on 27; find what IS in the
  hierarchy now (or assert through an accessibility role / an identifier the view already carries) so
  the pin still proves "exactly one scrubber, and it works". 5. `LibraryPanelHostTests`' banned-word
  "inspector" reflection pin — an OS-renamed internal symbol now matches it; narrow the reflection to
  the app's own types so the pin still bans what it was written to ban (read its history first).

**Acceptance:** each of the five gets a written verdict with its mechanism. The pins you rewrite must
still be ABLE to fail — prove each one by a deliberate mutation of the thing it guards (red), restored
(green). **The unit's evidence is the full-Mac suite reading GREEN with no "modulo"** — but the full
suite is the orchestrator's finals; YOU run the five tests' suites isolated and in-suite, the touched
surfaces' suites, and the eleven Tutorial suites. **Note from C4's closing run:** `RefontViewportTests`' 94 pt and
`LibraryPanelHostTests`' "inspector" are still red on today's tree (C4's diff did not move them); the
C4 two-window pins are OPT-IN for one suite (`DebugOracleSingletonWindowTests`) — do not run it in
your sets. If the Refont trace yields a product fix, write the
GUI walk steps for the author (Copper Beeches, 212 blocks, caret at the end, Settings ▸ Editor ▸
inline comments OFF / paragraph gap → Standard — 13u4 F2's walk) into your record: the terminal host
holds NO Screen Recording / Accessibility, so the walk is HELD for her morning; your in-app evidence is
the rig's numbers.

**CHECKPOINT RULES (restated, binding from your first commit):** write `## UNIT C6 RECORD` with its
`### LIVE STATUS` at the END of this file in your FIRST commit, and flip it in the same commit as each
piece; unverified claims marked **PENDING**. Commit per coherent piece and PUSH after every commit;
stage pathspec-limited, never `git add -A`; NO commit trailers (no Co-Authored-By, no Claude-Session).
Synchronous foreground waits only — the grep-poll loop; never end your turn with a run in progress.
Never spawn subagents (one Sonnet lookup for EXTERNAL facts only — e.g. the macOS 27 SwiftUI `Slider`
backing, if documentation helps). No behavioural revert starts until the record names it and the
pre-revert state is COMMITTED. Every death/resume noted in the record. If the worktree moves under
you, write nothing, report, stop. Never touch `/Applications`, never build Release, never quit or kill
a real-store Variorum instance.

**Scope fence:** C6 only. Zero `Sources/`, zero `Sync/`. QUESTIONS: check the end marker for the next
free number. **Your final message:** a short summary pointing at your record.

## UNIT C6 RECORD — the five macOS-27 test deltas (implementer: `opus-implementer`, 2026-09-25)

**WHAT THIS UNIT DID NOT DO — the record's first line.** No GUI walk and no captures: the terminal
host holds neither Screen Recording nor Accessibility. The Refont fix's walk is HELD for her morning
(steps below), and its in-app evidence is the rig's numbers, as the brief sets. No full-Mac suite (the
orchestrator's finals). No core `swift test` (zero `Sources/`) and no iOS build (zero `Shared/`). No
edit to `KnownIssuesAndTechDebt.md` row 65 or to `TEXTKIT2_NOTES.md`: both are canon records, and the
row's close and the measured-TK2 paragraph are handed to the orchestrator (below). No phone code. No
`DebugOracleSingletonWindowTests` in any set. **One item went BEYOND the five, and it is stated, not
silent:** the Outline's `count(NSSlider) == 0` arm had gone HOLLOW on 27 in the same class. It is
re-mechanized (items 3–4).

### LIVE STATUS

| # | Piece | Status |
|---|---|---|
| 1 | The reading, in this session's own context, in the brief's order | **DONE** — CLAUDE.md + canon, TEXTKIT2 §5, this file's corrections/ledger/traps/cast + C1–C4 closings and adjudications, KnownIssues row 65 + the re-font RESOLVED row, 13y's kickoff adjudication (lines 381–413), 13u4's UNIT F2 RECORD whole |
| 2 | Refont (TRACE item 1) — reproduce on 27, trace park → settle hop → `JumpPrimitive` with numbers | **TRACED** — REAL on 27 (the mechanism below). **Pin committed RED on the pre-fix tree** (`JumpViewportLayoutTests`, 3 issues + the Refont shrink pin's 1 — `18k-c6-jumppin-prefix.log`). **FIXED** in `JumpPrimitive.scroll(to:)` (one bounded re-assert) — both pins GREEN (`18k-c6-jumppin-fixed.log`, 7/2); behavioural revert R1 RED (4 issues, identical) → restored GREEN. **Item 1 CLOSED: FIXED** (the family re-run on the final tree rides the closing runs) |
| 3 | BoundaryFluidity (TRACE item 2) — N isolated + in-suite runs, the covariate | **TRACED — HARNESS** (the pin's wait predicate precedes its asserted event by one awaited hop); pin RE-MECHANIZED (wait on the scheduled compound) — green 14/14; M1/M2/M3 RED at their targets, P (the delay) GREEN. **Item 2 CLOSED: HARNESS, re-mechanized** |
| 4 | The two `NSSlider` scrubber pins — re-mechanize + mutation proof | **RE-MECHANIZED** (`ComposedSliders` — composition nodes + the node's own binding driving the surface) — green; **plus the Outline's zero-slider arm, found HOLLOW in the same class** — first re-mechanized by composition (`d21bf0fd`), then MEASURED hollow for the A6 shape (MO) and re-mechanized on the page's bottom content inset. MO-2 + MS1–MS4 all RED at their targets. **Items 3–4 CLOSED: PIN MECHANISM, re-mechanized (+ the Outline arm)** |
| 5 | `LibraryPanelHostTests`' "inspector" pin — history, narrow, mutation proof | **NARROWED** to the body's static type — green 6/6; MI (the retired host back) RED on the final form. **Item 5 CLOSED: PIN MECHANISM, narrowed** |
| 6 | Closing runs (the five suites isolated + in-suite, the touched surfaces, the eleven Tutorial suites) | **DONE** — 48/7 alone, then 569/70 all green, 0 skipped, suites counted (below) |
| 7 | The record complete (verdicts, disposition, held walk steps, noticed-not-touched) | **DONE** — C6 complete (implementer), awaiting the orchestrator's spot-check; the GUI walk HELD |

- Deaths / resumes: none.

### ITEM 1 — `RefontViewportTests.aShrinkingRefontKeepsTheLineAtTheViewportTop` — THE TRACE

**Reproduced isolated on 27 (`18k-c6-refont-iso1.log`):** `topVisibleOffset() → 42034 == before → 42128`,
1 issue, the other five pins green. **The "94-pt drift" is 94 CHARACTERS, not points** — one line of
the fixture's 14-pt mono at 900 pt — so the pin's own facts line says it plainly: after the shrink
the viewport's top line is the line ABOVE the one she was reading (`42034` = block 119's last line,
`42128` = block 120's second line).

**Where it happens — a scratch trace on the pin's own rig, `JumpPrimitive.jump` temporarily
instrumented (never committed; `18k-c6-trace{2,3}.log`):**

```
pin's first jump (tall) to b120 = 42056:
  scroll(11102.49) → layoutViewport → clip 11102.49 (frame 20963 → 21137.5)   minY(target) = 10995.67
  scroll(10995.67) → layoutViewport → clip 11024.67 (frame 21137.5 → 21166.5) minY(target) = 10995.67
  loop: |minY − requested top| < 1 ⇒ "converged"   — but the clip sits 29 pt BELOW the target line
  ⇒ top line read = 42128 (b120's 2nd line) — the pin's `before` is itself one line off b120
the re-font's settle-hop restore to 42128 (the park, spent on the first display pass):
  scroll(11082.75) → layoutViewport → clip 11082.75 (frame 20892)             minY = 10854.63
  scroll(10854.63) → layoutViewport → clip 10831.41 (frame 20892 → 20868.5)   minY = 10854.63
  loop: "converged"  — but the clip sits 23.23 pt ABOVE the target line (one 17-pt line + the 7-pt gap)
  next turn: frame +11, clip +10.78, target +10.78 (a content-preserving compensation; offset kept)
  ⇒ top line read = 42034 (b119's last line) — THE RED
a manual re-jump to 42128 on the settled geometry: both scrolls land where requested ⇒ exact (0.00)
```

**The mechanism, isolated:** on macOS 27 **`NSTextViewportLayoutController.layoutViewport()` moves the
clip view by (≈) the height change its own layout pass causes** — +29 with the frame +29, −23.23 with
the frame −23.5 — while the target line's `minY` (just laid out by the loop's single-fragment
`.ensuresLayout`) does not move. `JumpCorrectionLoop` judges convergence as `|minY − top| < 1` where
`top` is the value it REQUESTED, never the clip's actual origin, so it reports converged with the
viewport displaced by that delta. **Isolation (`18k-c6-trace4.log`):** a plain flipped document view in
an `NSScrollView` keeps its clip origin across ±29/−59-pt frame changes, and a bare `setFrameSize` on
the editor at mid-scroll moves nothing either — the displacement lives only inside TK2's viewport
layout, when that pass changes the laid-out geometry (unsettled geometry: a whole-document re-font,
or a jump into a region only estimated so far). On macOS 26 the same road was exact (F2's pins
green, the tree unchanged — 13y's attribution-by-construction).

**Verdict — REAL (small) on 27, and the pin's measurement is RIGHT.** The pin drives the product's
own road (the real coordinator → `keepingReadingPosition` → the park → the settle hop →
`JumpPrimitive`), and what it reads is what she would see: after a shrinking re-font the line she was
reading sits one line + one paragraph gap below the viewport top. Not a blank page (row 53's
dramatic half stays fixed — `herFixtureGestureLeavesThePageDrawn` is green) — a one-line slip of her
place, which F2's promise ("the same line at the viewport top") rules out. The primitive is shared,
so any landing whose loop ends on unsettled geometry inherits the slip (the pin's own first jump
shows it: asked for b120, it landed b120's second line).

**THE FIX'S SITE — decided on measurement, before a fix line (the candidate was evaluated in scratch
and reverted; its instrumented diff is kept in session scratch).** Two sites were weighed:
(a) the primitive — `JumpPrimitive.jump`'s `scroll(to:)` re-asserts the requested origin once when
TK2's viewport layout displaced it (a pure clamp at a shrunken maximum excluded); or (b) the one
consumer — `consumePendingAnchorRestore` re-jumps when the landing reads off. **(a) is chosen**: the
defect is the primitive's (its loop assumes the scroll it requests is the scroll it gets), all seven
`JumpPrimitive.jump` call sites inherit it on 27, and (b) would leave six of them one line off on
unsettled geometry. The candidate's measured blast radius (`18k-c6-candA-family.log`, the 35-suite
jump/landing family + the eleven Tutorial suites): **299 tests / 35 suites green**; the re-assert fired
**9 times, all on unsettled geometry** — 8 inside `RefontViewportTests`, 1 in
`EditorWindowSmokeTests.tenThousandWordPostStaysSnappyAndAnchored` (a 3,441-pt displacement on a
non-final iteration, which the old loop happened to re-steer out of — why that pin never went red) —
and **one re-assert sufficed 9 of 9** (`18k-c6-candA-once.log`: the second `layoutViewport()` never
displaced). On settled geometry — every other landing in the family — the clip is where it was asked
to be, the branch never runs, and the road is byte-identical.

**THE RED-ON-OLD PIN, measured on the pre-fix tree** (`App/Variorum/VariorumTests/JumpViewportLayoutTests.swift`,
`aJumpIntoEstimatedGeometryLandsItsLineAtTheViewportTop` — the primitive's own promise, on the Refont
rig's fixture): **3 issues** — the line **29.0 pt** from the viewport top; `topVisibleOffset() → 42128`
vs `target → 42056`, twice (right after the jump, and after four display passes). Beside it
`RefontViewportTests.aShrinkingRefontKeepsTheLineAtTheViewportTop` red as on 13y's kickoff
(`42034` vs `42128`). `18k-c6-jumppin-prefix.log`: 7 tests / 2 suites, 4 issues.

**THE FIX (`App/Variorum/Variorum/Features/Editor/JumpPrimitive.swift`, `jump`'s local `scroll(to:)` —
EDITOR SEAM, named plainly for the Fable ladder).** After the loop's `scroll → reflect →
layoutViewport()`, if the clip is not where it was asked to be (≥ 0.5 pt from the requested top, the
requested top re-clamped to the frame the pass left — so a clamp at a SHRUNKEN maximum is not
mistaken for a displacement), scroll back to the requested top once and lay out the viewport again.
**What did NOT change:** the pure `JumpCorrectionLoop` (byte-identical, its pins untouched), the
closure's measurement, `lineSpan`, the estimate, `maxScroll`, the ≤ 6-iteration bound, `landingInset`,
every signature — the primitive's contract ("lands the LINE containing `offset` at the viewport top")
is unchanged; the fix makes it true again on 27. **P1:** the extra work is one viewport layout
(viewport-bounded, never document-scale — no `ensureLayout` added) and only on a displaced scroll.
**TK2 discipline:** no TK1 API reached for. `EditorTextView`, the storage seam, `BlockRangeIndex`,
`EditorViewModel` and `keepingReadingPosition` are NOT in the diff. Zero `Sources/`, zero `Sync/`.
**Pins after the fix** (`18k-c6-jumppin-fixed.log`): `JumpViewportLayoutTests` 1/1 green and
`RefontViewportTests` 6/6 green — **7 tests / 2 suites passed**.

**BEHAVIOURAL REVERT R1 (named before it runs; the pre-revert state is `f058ac7f`, committed + pushed):**
the re-assert's condition forced false (`if false, abs(...) >= 0.5`) in the working tree only, the two
pins run, then `JumpPrimitive.swift` restored to `f058ac7f` byte-exact and the pins run again.
Expected: red as on the pre-fix tree, then green. **Result: RED — 4 issues, byte-identical to the
pre-fix measurement** (29.0 pt · `42128` vs `42056` ×2 · the Refont shrink's `42034` vs `42128`;
`18k-c6-R1.log`, 7 tests / 2 suites); **restored → GREEN** (`18k-c6-R1-restored.log`, 7/2 passed;
`git status` clean after the restore).

### ITEM 2 — `BoundaryFluidityTests.theKeystrokePathRoutesCrossBlockDeletesIntoTheCompound` — HARNESS

**Runs on today's tree (27.0):** isolated **40/40 green** (`-test-iterations 40`,
`18k-c6-fluid-iso40.log`); in its suite **15/15 green** (`-test-iterations 15`, 210 tests,
`18k-c6-fluid-suite15.log`); inside the 35-suite jump/landing family once, green. The kickoff's red
did not reproduce in 56 runs — so the mechanism had to be found, not waited for.

**The mechanism (read at the code, then measured).** The pin polled the STORE until the merged block
appeared, did one more `await database.read`, then read `status.spoken`. But `runStructural`
(`EditorSurfaceController.swift`) speaks the receipt only AFTER the transaction: `await
runner.run(body)` commits → `await database.read` the fresh projection → `applyStructuralResult`
(re-render + caret) → `showReceipt(note)`. So the poll's condition (the row is visible) is an EARLIER
event than the asserted one (the receipt spoken), separated by an awaited read on each side; which
of the two main-actor continuations resumes first was never guaranteed. **Measured** (a scratch copy,
60 iterations in one process, `18k-c6-fluid-window1.log`): at the moment the pin's poll broke, the
compound was **still in flight with nothing spoken in 8 of 60**; the pin's extra read covered the
window in all 60 that run; **after awaiting the scheduled compound itself: 60/60 a receipt, 0
refusals.** **Forced** (a scratch 100-ms sleep between `runner.run` and the fresh read — no outcome
changed, reverted; `18k-c6-fluid-perturb.log`): the SHIPPED pin went red with **13y's exact
signature** (`BoundaryFluidityTests.swift:98 … status.spoken → nil`), an old-form copy red beside it,
the re-mechanized form green, and the other 13 suite tests green.

**The routing question the brief asked** ("does the synthetic keystroke reach the same
`shouldChangeText` road the real key does on 27?"): **yes** — `harness.replace` is
`insertText(_:replacementRange:)`, the real `NSTextInputClient` road; 13y's failure carried only the
`spoken` line, so the surface-unchanged assertion (the storage refused the edit) and `texts ==
["Alpha two."]` (the compound landed) both held on the red runs. The routing was never the red.

**Verdict — HARNESS; the pin RE-MECHANIZED, the product untouched.** The pin now `#require`s the
handle the refused keystroke scheduled (`model.pendingCrossBlockTask` — which also makes "the
keystroke scheduled a compound" an explicit assertion) and awaits its `value` — the act that speaks
the receipt — instead of a store row. Every assertion after the wait is byte-unchanged in meaning.
Not a load-flake: the mechanism is named and forced. **Green: `BoundaryFluidityTests` 14/14**
(`18k-c6-fluid-new.log`).

**MUTATION PROOFS for the rewritten pin (named before they run; the pre-mutation state is `d195e748`,
committed + pushed; each mutation in the working tree only, the file restored from HEAD after each,
only `BoundaryFluidityTests` run):**
- **M1 — the receipt becomes a refusal:** `runStructural`'s receipt line always `model.refuse(note)`.
  Expected RED (`kind == .receipt`, `current == nil`).
- **M2 — no receipt is spoken:** `runStructural`'s `if let note` arm emptied. Expected RED (`#require
  spoken`).
- **M3 — the keystroke schedules nothing:** the keystroke router's compound arm
  (`EditorViewModel`, `planCrossBlockEdit` → `scheduleCrossBlockCompound`) replaced by `_ = compound`.
  Expected RED (`#require pendingCrossBlockTask`).
- **P — the timing perturbation, against the REAL rewritten pin:** the 100-ms sleep between the
  commit and the receipt re-applied. Expected GREEN (the old form went red under it).

**Results (every file restored from HEAD after each; `git status` clean after each restore):**
- **M1 → RED, 2 issues** (`18k-c6-fluid-M1.log`): `spoken.kind → .refusal == .receipt`, and
  `status.current → Item(… "the ends joined — originals under Came from. ⌥⌘Z undoes it." … .refusal)
  == nil`.
- **M2 → RED, 1 issue** (`18k-c6-fluid-M2.log`): `status.spoken → nil` at the `#require` (line 108).
- **M3 → RED** at the new `#require` (`pendingCrossBlockTask → nil`, line 92) — plus the two OTHER
  suite pins that ride the same arm (`aFannedCrossBlockDeleteEditsTheVisibleTakesOnly`,
  `quitTimeFinalizeLandsAScheduledCrossBlockCompound`), 5 issues in all (`18k-c6-fluid-M3.log`).
- **P → GREEN**, 14/14, the suite 1.280 s against 0.45 s unperturbed, so the delay did run
  (`18k-c6-fluid-P.log`).

### ITEMS 3–4 — the two `count(NSSlider) == 1` scrubber pins — PIN MECHANISM (+ one hollow sibling)

**What IS in the hierarchy on 27 — measured, not assumed** (scratch probes, reverted):
- The paged Read bar hosted (`18k-c6-slider-explore.log`): `NSHostingView<PagedReadView>` · 2 ×
  `AppKitPlatformViewHost<…PageFrameView>` · 2 × `PageFrameNSView` · `KeyViewProxy` · 3 ×
  `_FocusRingView` — **no NSView for the Slider, nor for the ◀ ▶ buttons**: SwiftUI draws the bar.
- A bare `Slider` + linear/spinner `ProgressView` + segmented `Picker` + `Toggle` hosted
  (`18k-c6-bare-controls.log`): `NSSlider` **0** · `NSProgressIndicator` **2** · `NSSegmentedControl`
  **1** · `NSButton` 0. So on 27 only the `Slider` left AppKit among the controls these pins count.
- **The accessibility tree is not a road in this environment** (`18k-c6-slider-explore2.log`): the
  hosting view answers `AXGroup` with **0** children, and 750 `accessibilityHitTest`s along the bar all
  answer that same group. In-process, with no assistive client attached, SwiftUI builds no
  accessibility nodes, and the terminal host has no Accessibility grant for an out-of-process client.
- The composition: a `Mirror` walk of `PagedReadView.body` finds **exactly one** node whose own type is
  `SwiftUI.Slider<EmptyView, EmptyView>`, holding its `Binding<Double>` (found by TYPE). Naive
  text-searching of the dump hits **24** lines, one per ancestor whose generic signature names it
  (`18k-c6-slider-explore3.log`).

**The re-mechanization — `App/Variorum/VariorumTests/ComposedSliders.swift` (new, test-only).** It counts
`Slider` NODES in a view's composition, and hands back each node's `Binding<Double>` found by type,
never by SwiftUI's internal field names (item 5 is what trusting an OS-internal name costs). The walk
stays inside the composition: it descends SwiftUI's own values and storage classes, never the app's
captured models, and visits each SwiftUI class once. It reads `hosting.rootView.body`, i.e. the
composition the hosted surface renders. It is the road `SurfaceComposition` already sanctions
(`ProtectionSurfaceRenderTests.swift`'s header: it proves COMPOSED, not VISIBLE; the hosted window
beside it proves the surface builds and lays out).
- **`PagedReadViewTests.theBarKeepsItsScrubberAndSpeaksApproximately`**: exactly one composed
  scrubber, **and it works**. The drawn leaves open at `[1, 2]` (read off `PageFrameNSView.pageNumber`,
  the surface's own answer). Setting the scrubber's own binding to the track's end redraws the book's
  last leaf. This part is new: the old pin only counted. The view's page model is its `@State`, and the
  root view's body reads the instance the hosted graph installed, as the moving pages prove.
- **`SpreadBookViewTests.theSpreadKeepsItsBarWithFormsAndTheJumpScrubber`**: exactly one composed
  scrubber, and it works. The spread opens on the first note; the binding set to 1 opens it on the last
  (`BookViewModel.scrubIndex`'s rule). The segmented-picker count is unchanged, since it is still AppKit
  on 27.
- **Found in the sweep, same class: `OutlineWritingSurfaceTests.outlineCarriesNoBottomChrome`'s
  `count(NSSlider) == 0` arm was HOLLOW on 27.** A restored slider would also have read 0, so that arm
  could not fail. It now reads `ComposedSliders.find(in: hosting.rootView.body).isEmpty`. Its
  `NSProgressIndicator == 0` arm is unchanged and still has teeth (measured above). The sweep over
  every AppKit-control count in `VariorumTests` (`NSSlider · NSProgressIndicator · NSSegmentedControl ·
  NSButton · NSPopUpButton · NSSwitch · NSStepper · NSTextField · …`) found only these three `NSSlider`
  arms, the one progress arm, the spread's segmented count, and `PagesArrowKeysTests`' `NSTextField`
  lookups (still AppKit; green).
- **Green:** `PagedReadViewTests` + `SpreadBookViewTests` + `OutlineWritingSurfaceTests`, **21 tests / 3
  suites passed** (`18k-c6-scrub-new.log`).
- **The recorded noise:** evaluating a body outside SwiftUI's graph logs SwiftUI's *"Accessing
  Environment<…>'s value outside of being installed on a View"* notice (48 lines across the three pins).
  That is the composition road's standing cost, and the inspector pin pays it too. It is harmless here:
  both reads (`ThemeStore?`, `colorScheme`) fall back to defaults that do not decide whether a slider is
  composed.

**MUTATION PROOFS for the three re-mechanized arms (named before they run; pre-mutation state
`d21bf0fd`, committed + pushed; each mutation in the working tree only, the product file restored from
HEAD after each):**
- **MO — the A6 regression shape, restored:** 13c 2A's removed `.safeAreaInset(edge: .bottom) { … Slider
  … }` re-attached where it stood, INSIDE the Outline's `ScrollViewReader` closure (it called
  `proxy.scrollTo`), with a scratch copy of the OLD arm (`count(NSSlider) == 0`) beside the new one.
  **Run FIRST, because the closure placement means a body walk may not reach it** — the expectation
  written down before the run: the old arm GREEN (hollow on 27); the new arm possibly GREEN too (hollow
  for this shape), in which case the Outline arm needs a different mechanism.
- **MS1 — the paged bar loses its Slider** → the paged pin RED (count 0).
- **MS2 — the paged Slider's setter a no-op** → the paged pin RED on its "it works" arm only.
- **MS3 — the spread bar gains a second Slider** → the spread pin RED (count 2).
- **MS4 — the spread Slider's setter a no-op** → the spread pin RED on its "it works" arm only.

**MO — RESULT (`18k-c6-scrub-MO.log`), and it CORRECTED this unit's own first rewrite.** With the A6 inset
restored where it stood (a `ProgressView` + a `Slider` in a `.safeAreaInset(edge: .bottom)` on the
Outline's `ScrollViewReader` content), BOTH slider arms read **GREEN**. The old `count(NSSlider) == 0`
is hollow on 27, as expected. **`d21bf0fd`'s composition arm is also hollow for this shape**: the reader
closure runs at render time, so no body walk reaches it. Only the `NSProgressIndicator` arm went red
(1 issue), and only because this mutation carried a progress bar too. A slider-only restoration would
have passed the whole pin.

**The Outline arm, re-mechanized a second time, on what her ruling actually removed** (13c 2A: *"Outline's
ENTIRE bottom inset is gone"*). A scratch probe of the hosted Outline's scroll views (`18k-c6-outline-geo-{MO,HEAD}.log`)
reads the page's `HostingScrollView` (909 × 800, the widest) with **`contentInsets.bottom` = 54 under MO
and 0 on HEAD**, and the navigator's scroll view at 0 both times. The arm now asserts **every
`NSScrollView` in the hosted Outline has a 0 bottom content inset, and the page's scroll view reaches the
window's bottom edge (≤ 1 pt)**. It uses AppKit's scroll-view API, not how SwiftUI draws a control, and
it catches ANY bottom bar, which is the letter of her ruling. The composition arm is DROPPED there
(it was hollow for the regression shape; keeping it would give false confidence). The progress arm is
unchanged. The pin's doc is corrected. **Green: `OutlineWritingSurfaceTests` 7/7**
(`18k-c6-outline-geo-new.log`).

**MO-2 (added, named here before it runs):** the A6 inset restored with the `Slider` ALONE (no progress
bar) against the new arm. Expected RED on the inset arm; the progress arm green.

**Results (every product file restored from HEAD after each; `git status` clean after each):**
- **MO-2 → RED, 1 issue** (`18k-c6-scrub-MO2.log`): `scrollViews.allSatisfy { bottom == 0 }` failed,
  reading `[0.0, 32.0]` (the navigator 0, the page 32 — the slider-only bar). The progress arm stayed
  green, so the new arm alone catches what used to pass the whole pin.
- **MS1 → RED, 2 issues** (`18k-c6-scrub-MS1.log`): `scrubbers.count → 0 == 1`, and the binding
  `#require`.
- **MS2 → RED, 1 issue** (`18k-c6-scrub-MS2.log`): `drawnPages().first → 1 > 2`. The count arm stayed
  green, so the "it works" arm is independent.
- **MS3 → RED, 1 issue** (`18k-c6-scrub-MS3.log`): `scrubbers.count → 2 == 1`.
- **MS4 → RED, 1 issue** (`18k-c6-scrub-MS4.log`): `model.leftPage?.postID → …0001 == postIDs.last →
  …0038`. The count arm stayed green.

### ITEM 5 — `LibraryPanelHostTests.aNoteSelectionStandsThePanelUpWith…`'s "inspector" ban — PIN MECHANISM

**History (read first, as the brief asks).** `dcb620d6` (pre-13u Act 10 wave 1) hosted the Library's right
panel in a SwiftUI `.inspector(isPresented:)` applied in `LibraryCatalogView.body`. `04355fba` (the Act
10 correction round, batch E) retired it for a column of our own, because the system draws an
inspector's divider only in a KEY window, so tabbed out the boundary vanished (row 34). `4ef9c80a` pinned
it: the mounted half (our divider + panel reported in both window states) plus a reflection line that
bans "inspector" in `SurfaceComposition.text(of: catalog.body)`, the VALUE dump lowercased.

**What matched on 27, measured** (a scratch probe, reverted; `18k-c6-inspector-explore{,2}.log`): the
dump is **14,672 lines**, and its real hits are two **`- activeInspector: nil`** lines. Each is a stored
field of SwiftUI's own sheet-presentation modifier (beside `sheetContent`, `placement`,
`drawsBackground`, `anchorProvider`), one for each of this view's two `.sheet(item:)`s
(`$tagSheetTarget`, `$versionPickTarget`). SwiftUI's internals grew the field on 27; nobody added an
inspector. **A latent trap found beside it:** the dump also descends into the swift-dependencies test
context the models captured, test NAME included (the probe's own name, `c6ScratchWhichInspector`, hit
6 lines). So any pin in this suite named with the word would have tripped the ban on ANY OS.

**The narrowing — the body's STATIC TYPE, the app's own composition exactly as written.** The line now
reads `String(reflecting: type(of: catalog.body))`. That is the modifier chain `LibraryCatalogView`
composes, including both branches of every conditional. It never includes SwiftUI's stored fields, and
never a captured dependency context. **Measured (`18k-c6-inspector-type-{HEAD,MI}.log`):** today the
type string is 12,459 characters with no "inspector"; with the retired `.inspector(isPresented:)` host
put back at the body's end, it spells **`SwiftUI.InspectorModifier<SwiftUI.Text>`**. The substring ban
over the TYPE is kept deliberately, rather than the exact internal name `InspectorModifier`. Pinning
SwiftUI's internal type name would go silently hollow if it were renamed. A substring match would
instead fail LOUDLY on a composed app type whose name contains "Inspector", and that false positive
is the safe direction. **Green: `LibraryPanelHostTests` 6/6** (`18k-c6-inspector-new.log`).

**MUTATION MI (named before it runs; pre-mutation state = this commit):** the retired host put back
(`.inspector(isPresented: .constant(model.infoHit != nil)) { Text(…) }` at `LibraryCatalogView.body`'s
end) → expected RED on the narrowed line. **Result: RED, 1 issue** — first on `e56520aa`'s form
(`18k-c6-inspector-MI.log`: the failure printed the whole type, ending `…swiftui.inspectormodifier<swiftui.text>>…`),
then on the final committed form `90290e92` (the predicate bound to a name so a failure prints
`(spellsAnInspector → true) == false`, not a 12k-character type; `18k-c6-inspector-MI3.log`). Restored → green
6/6 (`18k-c6-inspector-new3.log`); `git status` clean after each restore. The rest of the pin (the
mounted half: our divider + panel in both window states) is byte-unchanged.

### DISPOSITION — the five, one verdict each

| # | Pin | Verdict | Mechanism (traced + measured) | Evidence |
|---|---|---|---|---|
| 1 | `RefontViewportTests.aShrinkingRefontKeepsTheLineAtTheViewportTop` | **REAL on 27 → FIXED** (`JumpPrimitive`, editor seam) | TK2's `layoutViewport()` moves the clip by the height delta its own pass causes, and the jump loop judged convergence against the top it REQUESTED. The shrink's restore therefore landed one line + one gap low. | Red-on-old pin `JumpViewportLayoutTests` (3 issues) + the Refont shrink pin; behavioural revert R1 red (4 issues, identical) → green |
| 2 | `BoundaryFluidityTests.theKeystrokePathRoutesCrossBlockDeletesIntoTheCompound` | **HARNESS → pin re-mechanized** (not a load-flake) | The pin waited on the store row, which commits an awaited read BEFORE `runStructural` speaks the receipt. Two main-actor continuations raced. The routing was never the red. | Window measured 8/60; a 100-ms delay forces 13y's exact red; the new form waits on the scheduled compound. M1/M2/M3 red, P green |
| 3–4 | The two `count(NSSlider) == 1` scrubber pins | **PIN MECHANISM → re-mechanized** (+ the Outline's hollow zero arm) | On 27 a SwiftUI `Slider` is no NSView at all, and in-process there is no accessibility tree. The pins now read composition NODES plus the node's own binding driving the surface. The Outline arm (whose A6 inset sits in a `ScrollViewReader` closure) reads the page's bottom content inset. | MO proved both old and composition Outline arms hollow; MO-2 / MS1–MS4 red at their targets |
| 5 | `LibraryPanelHostTests`' "inspector" ban | **PIN MECHANISM → narrowed** | SwiftUI's sheet modifier grew a stored `activeInspector: nil` on 27, and the value dump matched it; the dump also reached the test's name. The ban now reads the body's STATIC TYPE. | MI (the retired host back) red on the final form; green 6/6 |

**No PROVISIONAL, no QUESTIONS entry** (#147 unused): no product-shaped call arose. The Refont fix
restores a promise F2 already made ("the same line at the viewport top"); it rules nothing new.

### SEAM FILES THIS DIFF TOUCHES (the ladder's Fable reviewer reads this list first)

| File | What changed | What did NOT |
|---|---|---|
| `App/Variorum/Variorum/Features/Editor/JumpPrimitive.swift` | **The ONE product change, 21 lines (a comment + one bounded re-assert) in `jump`'s local `scroll(to:)`.** After `layoutViewport()`, if the clip is ≥ 0.5 pt from the requested top (the requested top re-clamped to the frame the pass left), scroll back once and lay out the viewport again | `JumpCorrectionLoop` (the pure loop; its pins untouched), the closure's measurement, `lineSpan`, `FragmentLines`, the estimate, `maxScroll`, the ≤ 6 bound, `landingInset`, every signature and every caller |
| `App/Variorum/VariorumTests/JumpViewportLayoutTests.swift` | NEW — the primitive's red-on-old pin | — |
| `App/Variorum/VariorumTests/ComposedSliders.swift` | NEW — test-only helper (composition nodes + the node's own binding) | — |
| `App/Variorum/VariorumTests/BoundaryFluidityTests.swift` | the keystroke pin's WAIT (the scheduled compound, not a store row) | every assertion after the wait |
| `App/Variorum/VariorumTests/PagedReadTests.swift` | the paged scrubber pin (count + "it works") | the pin's `pageLine` half |
| `App/Variorum/VariorumTests/BookViewTests.swift` | the spread scrubber pin (count + "it works"); the Outline pin's slider arm (bottom content inset) + its doc | the segmented-picker count; the progress arm |
| `App/Variorum/VariorumTests/LibraryPanelTests.swift` | the inspector ban (the body's static type) | the mounted half |

**Untouched, named because a reviewer will look:** `EditorTextView`, `EditorViewModel`
(`keepingReadingPosition`, `consumePendingAnchorRestore`, `topVisibleOffset`), the storage seam,
`BlockRangeIndex`, `PaneSurface`, `PaneTextAuthority`, `runStructural`, `ScrollAnchorController`,
`EditorSurfaceController`, `LibraryCatalogView`, `PagedReadView`, `SpreadBookView`, `BookView`. **Zero
`Sources/`, zero `Sync/`, zero `Shared/`, zero `Server/`; marker 9 unchanged.** TK2 discipline: no TK1
API anywhere in the diff; the fix adds no `ensureLayout`, and its one extra `layoutViewport()` is
viewport-bounded and runs only on a displaced scroll (P1).

### JUDGMENT CALLS (each one a reviewer can reverse in a line)

1. **The fix lives in the primitive, not the one consumer.** All seven `JumpPrimitive.jump` call sites
   inherit the displacement on 27, and the pin's own first jump showed it outside the re-font road.
   *Reverse by* moving the retry to `consumePendingAnchorRestore` (jump, then re-jump when
   `topVisibleOffset()` reads off), which fixes the row and leaves six landings a line off on unsettled
   geometry.
2. **One re-assert, not a loop.** Measured 9 of 9: the second `layoutViewport()` never displaced. A
   future point release that displaces twice would show up here as a red `JumpViewportLayoutTests`.
   *Reverse by* a bounded `while`.
3. **The Outline zero arm was taken into C6** although the brief named the five. It is the same
   mechanism (an AppKit-class count SwiftUI no longer backs), it was HOLLOW (it could not fail), and
   the brief's own rule is that a rewritten pin must be able to fail. *Reverse by* restoring
   `count(NSSlider) == 0` and filing the hollowness as its own row.
4. **The scrubber pins read `hosting.rootView.body`** (the hosted composition) rather than a freshly
   built view. For `PagedReadView` that is what makes "it works" real, because its page model is
   `@State` and only the installed instance is the one drawn (the moving `pageNumber`s prove it). The
   cost is SwiftUI's "Environment read outside a view" notice (122 lines in the closing run).
5. **The inspector ban keeps a substring match over the TYPE**, not SwiftUI's exact internal name
   `InspectorModifier`. A rename of the internal name would silently hollow an exact match; an app type
   named `…Inspector…` composed here would fail loudly. Loud is the safe direction. *Reverse by*
   matching `"swiftui.inspectormodifier<"` exactly.
6. **BoundaryFluidity `#require`s the handle** (`pendingCrossBlockTask`). That adds an explicit "the
   refused keystroke scheduled a compound" assertion the old poll only implied (M3 proves it bites).

### CLOSING RUNS (at the unit's END, on the final tree `54217fc9`; zero app instances; `DebugOracleSingletonWindowTests` in no set)

| Run | Command (from `App/Variorum/`) | Result |
|---|---|---|
| **1 — the five deltas' suites alone** (+ the new primitive pin and the corrected Outline pin) | `DerivedData/18k-c6-run.sh 18k-c6-closing-five RefontViewportTests BoundaryFluidityTests PagedReadViewTests SpreadBookViewTests LibraryPanelHostTests JumpViewportLayoutTests OutlineWritingSurfaceTests` | **✔ Test run with 48 tests in 7 suites passed** (7 suites counted), 0 skipped |
| **2 — the closing set, in-suite** (`DerivedData/18k-c6-closing.sh`, 70 literal selectors): every `JumpPrimitive` consumer's suite and the editor/landing family (13u4 F2's closing list + this unit's jump family), every touched test file's suites (`PageDomainTests` · `PagePaginatorTests` · `PagedReadViewTests` · `BookViewTests` · `BookFocusFoldTests` · `OutlineWritingSurfaceTests` · `SpreadBookViewTests` · `LibraryPreviewBrainTests` · `LibraryPanelHostTests` · `JumpViewportLayoutTests`) and **the eleven Tutorial suites** | `DerivedData/18k-c6-closing.sh 18k-c6-closing1` | **✔ Test run with 569 tests in 70 suites passed after 149.4 s** — 0 issues, 0 skipped, **70 suites counted** against 70 asked. 50 `Modifying state during view update` lines (all in suites that mount panes — `PaneSurface`'s family, 18l's, as C3 measured) and 122 SwiftUI "outside of being installed" notices (the composition road's standing cost) |
| Repeated (item 2) | `-test-iterations 40` isolated · `-test-iterations 15` in-suite | **40/40** · **15/15** green (`18k-c6-fluid-iso40.log`, `18k-c6-fluid-suite15.log`) |
| Core (`swift test`) · iOS build | — | **NOT OWED** — zero `Sources/`, zero `Shared/` |

**What the orchestrator's full-Mac finals should read:** the four deterministic row-65 reds (Refont,
the two scrubbers, inspector) now GREEN, and BoundaryFluidity's intermittent red closed at its
mechanism. Any red there is a finding, not "modulo".

### THE GUI WALK — HELD for the author (her steps; ~5 minutes on the dev-store Debug build)

The fix changes where every Write landing puts the page on macOS 27, by up to about one line, and only
when TK2 was still settling. 13u4 F2's walk is the one that shows it.
1. Run the dev-store Debug build (Xcode's Run). Open ***The Adventure of the Copper Beeches*** (212
   blocks) in **Write**. Scroll to the middle of the story and note the line at the very top of the page.
2. Open Settings **from the menu** (Variorum ▸ Settings…; ⌘, is swallowed while the editor has focus).
   In **Editor**, turn **inline comments ON** and then **OFF**. **Expect the same line at the very top
   both times.** Before this fix, on macOS 27, turning comments off left the line above hers
   (the previous paragraph's last line) at the top, with hers one line lower.
3. Set **paragraph gap → a blank line's worth**, then **→ Standard**. Expect the same line at the top.
4. Press **⌘↓** (the caret to the end), then repeat step 2. Expect the page drawn whole, with the same
   tail line at the top and no blank page (row 53's fix, still holding).
5. Switch the voice **Study ⇄ Terminal** from the mid-story position. Expect the same paragraph at the
   top (Study re-wraps it, so within a line).
6. Landings, since the fix lives in the shared jump: switch to Takes (⌘2) and back (⌘1). Expect the page
   where you left it. Then jump deep into the note from the block index or the outline, and expect the
   block's first line at the very top, not its second.
7. Put Settings back the way you found it (the dev store was left: Terminal voice, inline comments
   OFF, paragraph gap Standard at 13u4 F2, and whatever you have set since).

### NOTICED, NOT TOUCHED (C6's scope fence)

1. **A measured TK2 fact for `TEXTKIT2_NOTES.md` (canon, so it is the orchestrator's at the closeout, as
   C2's item 3 was):** *on macOS 27.0, `NSTextViewportLayoutController.layoutViewport()` can move the
   enclosing clip view by about the height change its own layout pass causes (+29 pt with the
   document frame +29; −23.23 with −23.5), while a fragment just laid out by `.ensuresLayout` stays
   put. A plain flipped document and a bare `setFrameSize` do not move the clip. Only the viewport
   layout does, and only when it changes laid-out geometry. Anything that scrolls, lays out the
   viewport and then trusts its requested offset inherits the displacement.* `JumpPrimitive` now
   re-asserts it. **Re-grepped (not assumed): the app has exactly TWO `layoutViewport()` call sites.**
   `JumpPrimitive.scroll(to:)` is this fix. `PaneSurface.scheduleRenderRestore` (`PaneSurface.swift:1732`)
   is the A47c render-tier restore on a content-sized pane: it scrolls nothing and trusts no requested
   offset, so it is not this shape. Whether 27's displacement can nudge the HOST's scroll view when
   that restore relays out a pane was NOT examined. That surface is 18l's (fenced).
2. **`SurfaceComposition.text(of:)`'s value dump reaches swift-dependencies' captured test context, test
   NAME included** (the probe's own name hit 6 lines). Any pin that searches that dump for a plain word
   can be tripped by a test's name. The inspector pin no longer reads it; `LibraryPanelHostTests`'
   List pin (`contains("List<Swift.Never")`) and `ProtectionSurfaceRenderTests`' `carries` (quoted
   sentences) are unlikely victims, but the class is real. Needs an owner if filed (a candidate is the
   harness family, 12).
3. **The same OS-internal-name risk sits in the List pin** (`LibraryPanelHostTests`, line ~425): it
   reads SwiftUI's type spellings (`List<Swift.Never`, `List<Swift.Set<`) out of the VALUE dump. A
   rename would turn its negative arm hollow silently. It is green on 27 and was not touched.
4. **Row 65's close:** all five are dispositioned here. The KnownIssues row flip (to RESOLVED — 18k C6,
   with the Outline arm noted) is the orchestrator's.
5. **`EditorWindowSmokeTests.tenThousandWordPostStaysSnappyAndAnchored`'s jump displaced by 3,441 pt**
   on a non-final iteration on 27, and the old loop happened to re-steer out of it. That is why that
   pin never went red. After the fix the re-assert absorbs it at that iteration. Nothing owed.
6. **The book surfaces' landings (`LandingAuthority`, the Outline / Index / Read columns) do not use
   `JumpPrimitive`** and were not examined for the 27 displacement. Their suites are green in this
   unit's closing run and in 13y's finals.
7. The stale `/private/tmp/claude-501/u1-baseline-tree` worktree (not this run's) — untouched, as C1–C4
   left it. This unit created no worktree.

### CAPTURES

None possible (see the first line). The evidence is the harness logs in `App/Variorum/DerivedData/`
(gitignored), with the scripts beside them (`18k-c6-run.sh`, `18k-c6-family.sh`, `18k-c6-closing.sh`):
- Refont: `18k-c6-refont-iso1` · the traces `18k-c6-trace{1,2,3,4}` · the candidate
  `18k-c6-candA-{refont,family,once}` · `18k-c6-jumppin-{prefix,fixed}` · `18k-c6-R1{,-restored}`.
- BoundaryFluidity: `18k-c6-fluid-{window1,iso40,suite15,perturb,new,M1,M2,M3,P}`.
- Scrubbers: `18k-c6-slider-explore{,2,3}` · `18k-c6-bare-controls` · `18k-c6-scrub-{new,MO,MO2,MS1,MS2,MS3,MS4}` ·
  `18k-c6-outline-geo-{MO,HEAD,new}`.
- Inspector: `18k-c6-inspector-{explore,explore2,type-HEAD,type-MI,new,MI,new2,MI2,new3,MI3}`.
- Closing: `18k-c6-closing-five` · `18k-c6-closing1`.

The scratch instruments were never committed: the instrumented `JumpPrimitive` candidate patch, the
BoundaryFluidity perturbation patch, and the two scratch suites (`C6ScratchRefontTrace.swift`,
`C6ScratchFluidityForms.swift`, `C6ScratchFluidityTrace.swift`). They are kept in this session's
scratchpad only. Every product file they touched is byte-identical to HEAD (`git status` clean at
hand-back).
- Deaths / resumes: none.
- **C6 — DONE (implementer), awaiting the orchestrator's spot-check; the hands-on GUI walk HELD.**


### UNIT C6 — ORCHESTRATOR ADJUDICATION (2026-09-25 night; the unit CLOSES here)

**Verified by spot-check:** 18 commits after `8ce7a892`, pushed, zero trailers, tree clean, zero app
instances. The one product change read in full: `JumpPrimitive.scroll(to:)` — after the scroll, if the
clip sits ≥ 0.5 pt from the REACHABLE target (`min(wanted, frameHeight − clipHeight)` — so a clamp at
a shrunken maximum is not a displacement), re-scroll once, reflect, and lay the viewport out again;
TK2 API only (`textViewportLayoutController` exists only on `NSTextLayoutManager` — no TK1 touch).
Bounded (one re-assert), measured firing 9× in 299 tests, always converging in one. **ACCEPTED — C6
DONE: KnownIssues row 65 CLOSED** with all five mechanisms (1 real product regression FIXED on the
editor seam's jump primitive with a red-on-old pin; 1 test race; 3 pin mechanisms re-built, each proven
able to fail by mutation — plus one hollow `== 0` arm found and rewritten beyond the five). **FOR THE
FABLE LADDER (the seam):** the `JumpPrimitive` re-assert is the run's second-highest-value review
target after C1's registry. **Carried:** the `layoutViewport()` displacement → a `TEXTKIT2_NOTES.md`
measured-finding paragraph at the CLOSEOUT (with C2's first-measure finding); `PaneSurface`'s own
`layoutViewport()` caller (the render restore) was not examined → 18l's; the `SurfaceComposition`
dump-reach → a KnownIssues row, owner 12 (filed this commit). **Walk HELD** (Copper Beeches steps in
the C6 RECORD) → the morning bundle.

## UNIT C5 BRIEF — 17e's concurrency five (her ruling R-18k-1; self-contained; read in this order)

**You are the C5 implementer (`opus-implementer`), ONE unit, this session only.** Read, in order:
1. `CLAUDE.md` (auto-loaded).
2. THIS FILE: the kickoff corrections, THE LEDGER (row C5), THE KICKOFF SITTING (R-18k-1), **ENVIRONMENT
   TRAPS (binding)**, CAST & DISCIPLINE, the closing sections + ORCHESTRATOR ADJUDICATIONS of the
   earlier unit records (the tree moved: C1 changed `AppSession`'s autosave registry and several view
   models' lifecycles — read its record before touching the undo or editor doors), and this brief.
3. `notes/plans/phase-17-standing-fixes.md`'s **17e entry** — the BINDING item record: read P26, P27,
   P33 and P38 WHOLE, including each "verifier's check" (where finder and verifier differ, the
   verifier wins), and KnownIssues' row beginning "Canvas reports no focused block".

**The five (each its own pin, its own commit; red-on-old by behavioural revert unless stated):**
1. **Row 59 — Canvas reports no focused block to the router**, so ⌘K "Block History" (any
   router-reading door) acts on the last OTHER surface's block. One wire: the canvas's selection calls
   `CommandRouter.noteFocusedBlock` (read how Write/Takes/Blocks/Read call it — U-20's offset rule where
   applicable); pin: select a card in Canvas → the router's fact names it.
2. **P26 (MAJOR, the PHONE) — `MobileLivenessAuthority.takeLiveness` grants the pen from a stale
   continuation** across its awaits (two editors `isLive`; the worse ordering leaves the VISIBLE note
   uneditable). Fix the check-then-act-across-await: re-check `live === editor` after the suspensions
   before `noteLivenessGranted()` (and/or a generation token). Pin on the MOBILE suite (interleave two
   `takeLiveness` calls with a controllable suspension). The phone's P3 invariant (exactly one live
   editor) is the property.
3. **P27 — ⌘⇧M's merge threshold reads the frozen `slots` projection**
   (`EditorSurfaceController.applyStructural`'s `.merge` arm): a fan arriving mid-typing-burst makes
   the door take the un-carrying instant merge and suppress the lineage receipt. The sibling roads read
   truth via `liveActiveFans` ("from the store — never `model.slots`"); make this door do the same (an
   authorization read, not a projection read). Pin: fan arrives while the editor is busy → ⌘⇧M carries.
   **Seam note:** `EditorSurfaceController` is the editor seam's pair — keep the change to the arity
   decision; flag it plainly for the Fable ladder.
4. **P33 — the Mac's ⌥⌘Z has no in-flight guard** (`ShellActions.structuralUndo`): two presses inside
   one runner round-trip compute both warnings against entry E while the second undoes E−1, skipping
   the A12 confirm. Adopt the phone's rule (`MobileUndoDoor.beginUndo`'s `guard !inFlight` + its
   refusal) — the Mac is the drifted copy; check whether a shared brain is the right home (MobileSoul
   §3 hoist rule) and record the call. Pin: two presses in flight → the second refuses (or queues
   after), never undoes an unwarned entry. Check the redo door (⇧⌥⌘Z) for the same shape and treat it
   the same way if it has it.
5. **P38 — `StoreBackup.run` has no single-flight latch** (`Shared/StoreBackup.swift`): two forced runs
   in one second share a filename and race `integrityCheck`'s sidecar deletion and `prune`. Add an
   in-flight latch (a second request while one runs coalesces — returns the in-flight run's outcome —
   never starts a parallel one), and guard `DataSafetyModel.setInsurance`'s un-latched door. Pin: two
   forced runs back to back → one run, one file, no false `failed`. Shared file: the iOS build must
   still succeed; run the phone's backup suites if any exist.

**Acceptance:** each item FIXED-with-pin (red-on-old by behavioural revert) or DISMISSED-AS-HOLLOW
(pin green on both sides — recorded, not fixed). The terminal host holds NO Screen Recording /
Accessibility — in-app/harness evidence only; write the author's GUI walk steps (Canvas select → ⌘K
Block History; ⌥⌘Z pressed twice fast after two structural acts; Back Up Now while the insurance toggle
flips) into your record, HELD for her morning.

**Closing runs (tests at the END):** the touched surfaces' Mac suites + your pins + the eleven Tutorial
suites; the iOS build (`xcodebuild build -scheme VariorumMobile -destination generic/platform=iOS`) and
the phone's liveness/shell suites + P26's pin on the iPhone 17 Pro simulator; each read by its "Test
run with N tests" line; no full suites (the orchestrator's finals).

**CHECKPOINT RULES (restated, binding from your first commit):** write `## UNIT C5 RECORD` with its
`### LIVE STATUS` at the END of this file in your FIRST commit, and flip it in the same commit as each
piece; unverified claims marked **PENDING**. Commit per item and PUSH after every commit; stage
pathspec-limited, never `git add -A`; NO commit trailers (no Co-Authored-By, no Claude-Session).
Synchronous foreground waits only — the grep-poll loop; never end your turn with a run in progress.
Never spawn subagents (one Sonnet lookup for EXTERNAL facts only). No behavioural revert starts until
the record names it and the pre-revert state is COMMITTED. Every death/resume noted in the record. If
the worktree moves under you, write nothing, report, stop. Never touch `/Applications`, never build
Release, never quit or kill a real-store Variorum instance.

**Scope fence:** these five only — 17e's other items are 18o's. Zero `Sources/`, zero `Sync/`. A fix
that wants product behaviour decided (e.g. what the refusal SAYS) → the phone's existing sentence is
the default, PROVISIONAL (QUESTIONS — check the end marker). **Your final message:** a short summary
pointing at your record.

## UNIT C5 RECORD — 17e's concurrency five (implementer: `opus-implementer`, 2026-09-25)

**NOT DONE (first line, per the brief):** (1) the hands-on GUI walks and their captures — HELD (the brief: this
host could not drive or capture the app when the unit began; the orchestrator's handoff `262ff146` now runs them
after C5, from the steps under THE GUI WALK below). (2) The full Mac suite — the orchestrator's finals. (3) Copying
C5's dispositions into 17e's entry and flipping KnownIssues row 59 — the orchestrator's records (a ready-to-copy
block is under DISPOSITION). (4) P26's product code — nothing was owed: `6bc4f187` had already fixed it; C5 pinned it.
Everything else the brief asks for is done.

### READING (done in-session before any code)

`CLAUDE.md` and the canon it loads; this file's kickoff corrections, THE LEDGER (row C5), THE KICKOFF
SITTING (R-18k-1), ENVIRONMENT TRAPS, CAST & DISCIPLINE, the closing sections and ORCHESTRATOR
ADJUDICATIONS of C1–C4 and C6, and the C5 BRIEF; `notes/plans/phase-17-standing-fixes.md`'s 17e
entry whole (P26, P27, P33, P38 with each verifier's check); KnownIssues row 59; `MobileSoul.md` §3.
The code, at HEAD `5d831922`: `CommandRouter` (the focused-block fact, `requestBlockHistoryForFocusedBlock`),
`ShellActions` (`showBlockHistory`, `structuralUndo`, `structuralRedo`), `CanvasViewModel` /
`CanvasView`, every other `noteFocusedBlock` reporter (Write, Takes, Blocks, Read, the TOC),
`MobileLivenessAuthority` + its callers (`MobileShellView.tabDoor`, `MobileWriteView`) + its pins
(`MobileLivenessTests`), `MobileUndoDoor`, `StructuralUndoCopy`, `AppSession` (the Mac latch
precedent `tutorialDoorInFlight`), `EditorSurfaceController` (`applyStructural`'s `.merge` arm,
`runInstantMerge`, `runCarryAllMerge`, `openMergeCeremony`, `runSeamMerge`, `liveActiveFans`,
`runStructural`), `StoreBackup` (`run`, `performRun`, `performBackupIfDue`, `prune`,
`integrityCheck`), `DataSafetyModel`, `DataSafetyPane`, and the suites each item's pin will join
(`CanvasAndPoolTests`, `SeamMergeTests`, `FannedDefaultsTests`, `DestructiveUndoWarningTests`,
`DataSafetyTests`, `Phase13pSubstrateTests`).

### THE TRACE (inputs → wrong state; every claim re-read at the code, not taken from 17e)

**Item 1 — row 59, Canvas's focused-block fact.** `CanvasViewModel.focus(blockID:variantID:)`
migrates the ONE ring (`authority.focus`) and flushes; it never calls
`CommandRouter.noteFocusedBlock` (grep: the reporters are Write, Takes ×2, Blocks, the TOC, Read ×3 —
no Canvas file). ⌘K "Block History" → `ShellActions.showBlockHistory` → `router.dispatch(.showBlockHistory)`;
the canvas's registered handler consumes only `.commit` and the switcher's three, so it returns false →
`router.requestBlockHistoryForFocusedBlock()` reads `focusedBlock`, which is whatever the LAST
reporter wrote for this note (the fact survives a mode switch within the note — that is the row-39
memory's design). Wrong output: she clicks card Y in Canvas, presses ⌘K Block History, and the pane
opens on block X, the Write caret's block from before she switched. **CONFIRMED.**

**Item 2 — P26, the phone's liveness grant.** P26 cites `MobileLivenessAuthority.swift:107/112/113/115/117`.
Those are the lines of the file BEFORE `6bc4f187` (2026-08-30, "The five MAJORs"), which added the
monotonic handoff token for the architectural review's MAJOR 2 — the same defect, reached by another
review the same day. At HEAD the grant re-checks `isCurrent(token)` at entry AND after each suspension
(after `flushNow`, after `refreshTakesFromStore`), and the shell mints the token synchronously at the
tap (`MobileShellView.tabDoor` → `beginHandoff()` in the same turn as `tab = target`). Both of P26's
orderings, re-traced against HEAD: (a) the finder's — the stale grant suspended INSIDE the flush,
the newer one completing, the stale one resuming → the post-suspension guard returns before
`noteLivenessGranted()`; (b) the verifier's worse one — the stale task suspended in `fileOnLeaving()`
before it ever enters → the entry guard returns. **So P26 is already FIXED, by `6bc4f187`, before
this unit.** What is NOT covered: the two pins `6bc4f187` added
(`theLastRequestedTabWinsEvenWhenTheStaleHandoffLandsLast` and its mirror) run the stale grant as a
LATER ENTRY, which only the entry guard sees. The post-suspension guards — P26's literal mechanism —
are pinned by nothing: deleting both leaves every liveness pin green (to be shown by mutation M-P26).
The unit's work on P26 is therefore the missing pin, not a fix.

**Item 3 — P27, ⌘⇧M's arity read.** `applyStructural`'s `.merge` arm decides from
`model.slots[i].activeVariantCount` (`EditorSurfaceController.swift:329–332` at HEAD — P27's `:277`
has moved). `slots` is frozen while the editor is busy (`EditorProjectionPolicy` → `.deferUntilClean`).
A take born on the trailing block mid-burst (sync, or her own Takes surface) leaves `trailingArity == 1`
→ the `else` arm → `runInstantMerge`, which never reads the store; `ops.merge` accepts fanned blocks
(no fan fence); the trailing block is released to lineage with its take behind it, and
`speakAboutMergedFans(mergedAwayTakes(...))` reads the same stale slots → 0 → silent. The
false-POSITIVE direction is guarded (`runCarryAllMerge` re-reads via `liveActiveFans` and falls
back); the false-NEGATIVE is not. The ceremony branch (⌥⌘⇧M) reads the same two numbers for its
"needs a fan" refusal, so a fan that arrived mid-burst makes that door refuse wrongly — the same
arity decision, one branch over (recorded under THE FIX's scope note). **CONFIRMED.**

**Item 4 — P33, the Mac's ⌥⌘Z.** `ShellActions.structuralUndo` spawns a `Task` with no latch and makes
TWO runner submissions — `pendingUndoWarning` then `undo` — each reading the stack's top
independently. Two presses: T1 and T2 start in order on the main actor, each submits its warning
read before either resumes → runner order T1.warn, T2.warn, T1.undo, T2.undo → both warnings were
computed against entry E while T2 undoes E−1. With E clean and E−1 in the insurance class, the A12
confirm never shows and E−1's edited buffer is discarded without asking. **The redo door has the
same shape across doors:** ⇧⌥⌘Z pressed inside an undo's warn→act gap lands a redo between them, so
the confirm she answered was about E−1 while the act undoes the entry the redo just re-applied. The
phone's door shares ONE latch across undo and redo (`MobileUndoDoor.inFlight`, guarding `beginUndo`,
`confirmPendingUndo` and `redo`) for exactly this reason. **CONFIRMED (both).**

**Item 5 — P38, the backup single-flight.** `StoreBackup.run(force:)` (now `:150`, P38's `:143`
moved) takes `stamp = now()` and awaits a detached `performRun` with no in-flight guard; the snapshot
name is second-granular (`stampFormatter`), so two runs in one second write the SAME path, both run
`integrityCheck` (which deletes `-wal`/`-shm` beside that path) and both `prune` the same doomed set
— the loser's `removeItem` throws out of `performBackupIfDue` and its record reads `.failed` for a
snapshot that succeeded (`lastError` set, the Data Safety face says it failed). Doors that reach it
un-latched: the hourly `start()` tick, `DataSafetyModel.setInsurance` (no `busy`, and its toggle is
not `.disabled(model.busy)`), `ICloudDriveOffer`, `PostureSwitch`. Even with no prune race, two
parallel runs append TWO log records for one intent. **CONFIRMED.**

### LIVE STATUS

- Reading + the trace — DONE (this commit).
- Item 1 (row 59) — DONE, FIXED (`bc5e8cf9`; pin `4eb91dad`). Pins `CanvasFocusedBlockFactTests` (in `CanvasAndPoolTests.swift`, 2 tests): the card click is the router's fact and ⌘K "Block History" (through `ShellActions.showBlockHistory`, the canvas's own fall-through road) opens on it; a re-click on the live card re-asserts the fact. **Pre-fix tree: `Test run with 2 tests in 1 suite failed … with 5 issues`** (every arm read the stale first block). Fixed: `2 tests … passed`. **R1-i1** (the production file from `4eb91dad` over the fix): `failed … with 5 issues`, identical; restored, `git diff` empty. The fix is one report in `CanvasViewModel.focus(blockID:variantID:)`, placed BEFORE `authority.focus` (the Takes board's placement — the re-click arm is what a report after the `.unchanged` return would fail), nil offset.
- Item 2 (P26) — DONE: **ALREADY FIXED by `6bc4f187` (2026-08-30) before this unit — now PINNED** (`ebd690e6`); zero product code. Not hollow: the defect was real on the tree P26 was filed against, and M-P26 below re-opens it exactly. Pin `MobileLivenessTests.aGrantSuspendedInsideItsFlushNeverResumesIntoThePen` (the finder's interleaving, FORCED — a write on another thread holds the in-memory `DatabaseQueue`, so tap 1's grant is suspended inside the shared coordinator's flush while tap 2's grant runs to its own fresh read; then the store is released). **HEAD: `Test run with 8 tests in 1 suite passed`** (the suite's 7 + this pin). **Mutation M-P26** (delete ONLY the two post-suspension `guard isCurrent(token)` lines in `takeLiveness`, keep the entry guard — the pre-`6bc4f187` grant's post-suspension shape): **`8 tests … failed … with 2 issues`, both in the new pin** (the hidden Shelf editor ends `isLive` and its gate ACCEPTS a keystroke beside the visible Library editor — two live editors, P3's violation), while `6bc4f187`'s two pins (`theLastRequestedTabWins…`, `theMirrorHoldsToo…`) stay GREEN — they reach only the entry guard, which is the gap this pin closes. Restored with `git checkout HEAD --`, tree clean. The verifier's worse ordering (the stale task suspended in `fileOnLeaving()` before it enters) is the ENTRY guard's, already pinned by those two.
- Item 3 (P27) — DONE, FIXED (`dee61938`; pin `98880463`). **EDITOR-SEAM PAIR — flagged for the Fable ladder:** `EditorSurfaceController.applyStructural`'s `.merge` arm, the non-ceremony UNFANNED branch only (+20 lines): before the instant merge it reads `liveActiveFans` (the seam keystroke's exact shape, `runSeamMerge`) and takes the carry-all road if the store says either block is fanned. Untouched: the fanned branch (its road re-reads truth and falls back, as before), the ceremony branch (⌥⌘⇧M — see NOTICED), `runInstantMerge`, `runCarryAllMerge`, `runStructural`, every signature. Pins in `FannedDefaultsTests`: `aFanArrivingWhileSheIsTypingIsCarriedByTheMerge` (the burst: type, branch a take on the block below, deliver the projection so the engine defers it, ⌘⇧M) and the guard `anUnfannedMergeMidBurstIsStillTheInstantMerge` (green both sides). **Pre-fix tree: `Test run with 33 tests in 1 suite failed … with 2 issues`** (the merged block carried ONE take — the new one left on the released block — and `statusMessage` was nil). Fixed: `FannedDefaultsTests` + `SeamMergeTests` **`53 tests in 2 suites passed`**. **R1-i3** (the production file from `98880463` over the fix): `33 tests … failed … with 2 issues`, identical; restored, `git diff` empty. Cost: one indexed read of the two blocks' fans per everyday ⌘⇧M (P1-bounded). The read is an await before `runStructural` raises its flight flag — the window the carry-all and seam roads already have; a second structural act inside it is refused by `runStructural`'s own guard, and `runInstantMerge` resolves its entries by id at act time (R1-2), so nothing acts on a stale index.
- Item 4 (P33) — DONE, FIXED (`65aa05fa`; pins + the sentence's home `8a172f7a`). The Mac's ⌥⌘Z AND ⇧⌥⌘Z share ONE in-flight latch, taken synchronously at press time: `AppSession.beginStructuralUndoDoor()` / `endStructuralUndoDoor()` (macOS block, beside the tutorial door's latch — the precedent; session-scoped because `ShellActions` is a value rebuilt per menu read), released by a `defer` in each door's Task. A press that finds it held refuses with `StructuralUndoCopy.anotherIsLanding` — the phone's words, hoisted into the shared copy home, with `MobileUndoDoor.anotherIsLanding` forwarding byte-identically (the call: see JUDGMENT CALLS). Pins in `DestructiveUndoWarningTests`: `twoUndoPressesInFlightNeverUndoAnUnwarnedEntry` (E−1 edited since, E clean, two presses) and `aRedoPressedInsideAnUndosFlightRefusesAndTheUndoDoesWhatItAsked` (the redo door's cross-door shape). **Pre-fix door** (the copy hoist present, no latch): **`Test run with 7 tests in 1 suite failed … with 9 issues`** — arm A: no refusal, BOTH entries undone, the writing after the first divide gone, and the next press found nothing to ask; arm B: she was asked about E−1 and approved, yet E was undone and E−1 stayed. Fixed: `DestructiveUndoWarningTests` + `BlockDeletionAndRedoTests` **`36 tests in 2 suites passed`**. **R1-i4** (both production files from `8a172f7a`): `7 tests … failed … with 9 issues`, identical; restored. **M-P33r** (undo latched, redo NOT): `failed … with 4 issues`, all in the redo arm — the shared half is load-bearing. Consequence, stated: two presses inside ONE flight (milliseconds) now refuse the second rather than queueing it — the phone's rule and every structural door's own flight guard; a held-down chord undoes at the rate flights land.
- Item 5 (P38) — DONE, FIXED (`3f480486`; pins `824dfebf`). **`StoreBackup.run` is single-flight** (Shared): an in-flight slot `(id, task, forced)`; a request is handed the in-flight run's outcome whenever that run covers it (any request behind a forced run; a due-check behind anything); a FORCED request behind a due-check waits for it and then runs its own (JUDGMENT CALLS 3) — never two runs in parallel; the old body moved verbatim into `performOneRun`. **The pane's door:** `DataSafetyModel.setInsurance` takes `busy` like its three siblings (`guard !busy`, set, defer clear), and the pane's toggle adds `model.busy` to its `.disabled` (the siblings' line). Pins `BackupSingleFlightTests` (in `DataSafetyTests.swift`, 3 tests): `twoForcedRunsInOneSecondAreOneRun` (on-disk WAL source, keep 1 with an older copy to prune, one clock reading for both), the guard `aForcedRequestBehindADueCheckStillWritesAFreshCopy`, and `theInsuranceToggleHoldsThePanesLatchWhileItsBackupRuns`. **Pre-fix: `Test run with 3 tests in 1 suite failed … with 3 issues`** — TWO runs (two log records) for one intent, and the pane never busy during the toggle's pass. **Honest about the consequence:** the false `failed` P38 names did NOT occur on the unlatched door in 80 runs (`-test-iterations 40`, in-memory AND on-disk sources: `18k-c5-p38-prefix-iter40.log`, `…-disk40.log`) — both sources serialise the two snapshot writes, so one run's `prune` lands before the other lists; the double run (the mechanism) reddened every iteration, 80/80. The `failed`/`lastError` arms stay as guards of the consequence. Fixed: `BackupSingleFlightTests` + `BackupRunTests` + `Phase13pInsuranceFaceTests` **`13 tests in 3 suites passed`**. **R1-i5** (all three production files from `824dfebf`): `3 tests … failed … with 3 issues`, identical. **M-P38c** (coalesce EVERY request): `failed … with 2 issues`, both in the guard (Back Up Now handed the tick's `upToDate`). **M-P38d** (the pane's door reverted, the latch kept): `failed … with 2 issues`, both in the door pin (never busy; the press ran a second pass). Restored each time, tree clean.
- Closing runs — DONE (below, CLOSING RUNS): Mac closing set 609/95 green ×2 of 3 on the final tree, the one red being the flake list's `ModeSwitchCarryTests` top-of-Write arm, adjudicated by the paired interleaved protocol; iOS BUILD SUCCEEDED; the phone's five suites 58/5 green.
- The record closed — DONE (this commit).
- Deaths / resumes: none.

### DISPOSITION — the five, one verdict each

| # | Item | Verdict | Pin (red-on-old evidence) | Commits |
|---|---|---|---|---|
| 1 | KnownIssues row 59 — Canvas reports no focused block | **FIXED** | `CanvasFocusedBlockFactTests` (2) — pre-fix 5 issues; R1-i1 5, identical | pin `4eb91dad` · fix `bc5e8cf9` |
| 2 | P26 — the phone's `takeLiveness` stale continuation | **ALREADY FIXED by `6bc4f187` (2026-08-30), now PINNED** — not hollow, zero product code | `MobileLivenessTests.aGrantSuspendedInsideItsFlushNeverResumesIntoThePen` — green on HEAD; M-P26 (the post-suspension guards deleted) 2 issues in this pin alone, `6bc4f187`'s two pins green | pin `ebd690e6` |
| 3 | P27 — ⌘⇧M decides from the frozen `slots` | **FIXED** (editor seam's pair — Fable ladder) | `FannedDefaultsTests.aFanArrivingWhileSheIsTypingIsCarriedByTheMerge` + guard — pre-fix 2 issues; R1-i3 2, identical | pin `98880463` · fix `dee61938` |
| 4 | P33 — ⌥⌘Z has no in-flight latch (+ ⇧⌥⌘Z, same shape across doors) | **FIXED** (both doors, one shared latch) | `DestructiveUndoWarningTests` (2 new) — pre-fix 9 issues; R1-i4 9, identical; M-P33r 4 (redo arm only) | pins `8a172f7a` · fix `65aa05fa` |
| 5 | P38 — `StoreBackup.run` has no single-flight latch (+ `setInsurance`'s door) | **FIXED** | `BackupSingleFlightTests` (3) — pre-fix 3 issues (double run 80/80; the false `failed` 0/80, recorded); R1-i5 3; M-P38c 2; M-P38d 2 | pins `824dfebf` · fix `3f480486` |

**Ready to copy into 17e's entry (the orchestrator's act):** *row 59 — FIXED 18k C5 (`bc5e8cf9`, pin
`CanvasFocusedBlockFactTests`) · P26 — ALREADY FIXED by `6bc4f187`, pinned 18k C5
(`MobileLivenessTests.aGrantSuspendedInsideItsFlushNeverResumesIntoThePen`) · P27 — FIXED 18k C5 (`dee61938`,
pin `FannedDefaultsTests.aFanArrivingWhileSheIsTypingIsCarriedByTheMerge`) · P33 — FIXED 18k C5 (`65aa05fa`, both
doors; pins `DestructiveUndoWarningTests.twoUndoPressesInFlightNeverUndoAnUnwarnedEntry` +
`aRedoPressedInsideAnUndosFlightRefusesAndTheUndoDoesWhatItAsked`) · P38 — FIXED 18k C5 (`3f480486`, pins
`BackupSingleFlightTests`).*

**No PROVISIONAL, no QUESTIONS entry** (#147 unused): the one refusal sentence is the phone's existing words (the
brief's default), and every other call below is technical, each reversible in a line.

### SEAM FILES THIS DIFF TOUCHES (the ladder reads this first)

| File | What changed | What did NOT |
|---|---|---|
| `App/Variorum/Variorum/Features/Editor/EditorSurfaceController.swift` | **The editor seam's pair (P27), +20 lines:** the `.merge` arm's non-ceremony UNFANNED branch reads `liveActiveFans` and takes the carry-all road when the store says fanned | the fanned branch, the ceremony branch, `runInstantMerge`, `runCarryAllMerge`, `runStructural`, `liveActiveFans` itself, every signature |
| `App/Variorum/Shared/AppSession.swift` (shared) | +21 lines inside the existing `#if os(macOS)` block: `structuralUndoDoorInFlight` + begin/end (the tutorial door's latch, beside it) | the autosave registry C1 rebuilt, everything the phone compiles |
| `App/Variorum/Shared/StoreBackup.swift` (shared) | the single-flight slot + `run(force:)`; the old body moved verbatim into `performOneRun(force:)` | `performRun`, `performBackupIfDue`, `prune`, `integrityCheck`, the legs, every static |
| `App/Variorum/Shared/StructuralUndoCopy.swift` (shared) | `anotherIsLanding` (the phone's sentence, byte-identical) | every other string |
| `App/Variorum/VariorumMobile/Features/Write/MobileUndoDoor.swift` | `anotherIsLanding` forwards to the shared copy (same bytes) | the door's latch, flush contract, presentation state |
| `App/Variorum/Variorum/Registry/ShellActions.swift` | `structuralUndo` / `structuralRedo` take the latch at press time, `defer` release in their Tasks | the A12 warning, the confirm seam, every report |
| `App/Variorum/Variorum/Features/Canvas/CanvasViewModel.swift` | one `noteFocusedBlock` in `focus(blockID:variantID:)` | the ring, the flush, order mode, every other method |
| `App/Variorum/Variorum/Features/Settings/DataSafetyModel.swift` · `DataSafetyPane.swift` | `setInsurance` takes `busy`; the toggle's `.disabled` gains `model.busy` | the other three doors, the receipts |

**Untouched, named because a reviewer will look:** `EditorTextView`, `EditorViewModel`, the storage seam,
`BlockRangeIndex`, `PaneSurface`, `PaneTextAuthority`, `MobileLivenessAuthority` (P26 is test-only),
`CommandRouter`. **Zero `Sources/`, zero `Sync/`, zero `Server/`; marker 9 unchanged; no schema.**

### JUDGMENT CALLS (each one a reviewer can reverse in a line)

1. **Row 59 — the report rides BEFORE `authority.focus`, with a nil offset, and nothing on blur.** Before: the
   Takes board's placement, so a re-click on the live card re-asserts a fact another pane moved (the second pin).
   Nil offset: nil is UNKNOWN under U-20, and a canvas caret reporter is the "fourth reporter … a design act" that
   Blocks' row records (NOTICED 2). No blur report: no surface clears the fact on blur; "the block you were in"
   outlives the ring. *Consequence, stated:* Canvas now FEEDS the row-39 memory, so Canvas → Write lands on the
   card she last clicked (its remembered offset, else its start) rather than Write's older caret block — the
   memory's design, now honest in Canvas too.
2. **P26's verdict wording.** The defect was real on the tree it was filed against (`6bc4f187`'s parent) and is
   closed at HEAD; "hollow" would misstate it and "fixed by C5" would claim someone else's fix. The pin is what
   was owed. *Reverse by* re-labelling; nothing in code turns on it.
3. **P38 — a forced request behind an UNFORCED run waits and then runs its own** (instead of being handed the
   due-check's answer). Back Up Now's own doc promises "a fresh snapshot at both destinations regardless of the
   interval"; handing it "already up to date" would break that promise while still never running in parallel.
   Every other pairing coalesces, as the brief says. *Reverse by* `if let current = inFlight {` (M-P38c shows the
   guard pin that would flip).
4. **P33 — the latch is session-scoped on `AppSession` (Mac), SHARED by undo and redo; the phone keeps its own
   door-local latch; only the SENTENCE is hoisted.** MobileSoul §3's hoist rule, applied: the RULE (one flight at a
   time, across both doors, refused in these words) now reads identically on both platforms, and its words have
   one home (`StructuralUndoCopy`). The latch MECHANISM is not hoisted: the phone's is interleaved with its
   presentation state (released before its alert shows, re-taken at confirm), the Mac's alert is modal inside the
   flight, so a shared latch type would be six lines each door wraps differently — no brain, just two lifecycles.
   *Reverse by* a `StructuralUndoFlight` type in `Shared/` both doors hold.
5. **P33 — refuse, not queue.** The brief allowed either; the phone refuses, and so does every structural door's
   own flight guard in the same words. A second press inside one flight (milliseconds) now shows the sentence.
6. **P27 — the store read sits only in the unfanned branch.** The fanned branch's road already re-reads truth
   and falls back; the ceremony branch's stale read can only REFUSE (never authorize) — see NOTICED 1.
7. **P38 — the pin runs on an on-disk WAL source** (the app's real store shape), after the in-memory source showed
   the same 0/40 for the `failed` consequence. The double run reddens either way.

### CLOSING RUNS (at the unit's END, on the final tree; zero app instances; `DebugOracleSingletonWindowTests` in no set)

| Run | Command (from `App/Variorum/`) | Result |
|---|---|---|
| **Mac closing set** — 95 literal suites: row 59's router/Canvas family (27), P27's merge-door family (31), P33's undo doors (8), P38's backup family (18), **the eleven Tutorial suites** | `DerivedData/18k-c5-closing.sh 18k-c5-closing1` (list in the script) | **`✘ Test run with 609 tests in 95 suites failed after 101.981 seconds with 2 issues`** — both in `ModeSwitchCarryTests.aBlockAtTheTopOfWriteArrivesAtTheTopOfRead`, the flake list's "top-of-Write arm", at its PRECONDITION (`wrote <= 0.02`: Write's own harness scroll, before any mode switch) — a road no line of C5 sits on |
| **The paired interleaved adjudication** (her protocol: this tree vs the opening commit `5d831922`, alternating; a scratch worktree, removed) | `ROOT=… DerivedData/18k-c5-closing-at.sh <log>` | base `18k-c5-pair-old1` **600/93 passed** · final `…-new2` **609/95 passed** · base `…-old2` **600/93 passed** · final `…-new3` **609/95 passed**. Isolated, `-test-iterations 10`: **30/10 passed on BOTH trees, 0 reds** (`18k-c5-msc-{new,old}-iter10.log`). Verdict: the known load flake (1 of 3 loaded runs on the final tree, 0 of 2 on the base, 0 of 20 isolated), not C5's. The 9-test / 2-suite difference is exactly this unit's pins. |
| iOS build | `xcodebuild build -scheme VariorumMobile -destination generic/platform=iOS` | **`** BUILD SUCCEEDED **`** |
| Phone suites (iPhone 17 Pro, iOS 26.2) | `DerivedData/18k-c5-phone.sh 18k-c5-phone-closing MobileLivenessTests MobileShellTests MobileUndoDoorTests MobileBlockMenuTests MobileStructuralTests` | **`✔ Test run with 58 tests in 5 suites passed`** (P26's pin included) |
| Core (`swift test`) | — | **NOT OWED** — zero `Sources/` |

Not run, named: the opt-in drills (`PostureSwitchDrillTests` reaches `backUpNow` through the posture switch;
`Phase13pKeyedDrillTests`) — keychain-scoped, the orchestrator's to opt into.

### THE GUI WALK — HELD for the author (her steps; ~5 minutes on the dev-store Debug build)

1. **Canvas → ⌘K Block History (row 59).** Open a note of several blocks in **Write** and click into its FIRST
   block. Switch to **Canvas** (⌘7) and click into a card further down (say the third). ⌘K → **Block History**.
   Expect the pane to open on THAT card's block, not the first. Click a different card and ask again: the pane
   follows. (Then ⌘1: Write now lands on the card you last clicked — the stated consequence.)
2. **⌥⌘Z pressed twice fast (P33).** In Write on a scratch note: ⌘⇧D to divide a block, then type a word into
   the first half; ⌘⇧D a different block and type nothing. Press ⌥⌘Z twice as fast as you can. Expect ONE of:
   the second press shows *"Another structural change is still landing."* (it was inside the first's flight), or
   — if the first had already landed — the "Undo Divide?" confirm for the edited one. **Never** both divides
   undone with no confirm. Answer Cancel and check the typed word is still there.
3. **⇧⌥⌘Z inside ⌥⌘Z (P33's redo arm).** From step 2's state after one undo: press ⌥⌘Z and immediately ⇧⌥⌘Z.
   Expect the redo refused in the same words, OR the confirm naming the edited divide — and whatever you approve
   is what comes back.
4. **Back Up Now vs the insurance toggle (P38).** Settings ▸ **Data Safety** (dev store, with a SCRATCH backup
   folder picked — the toggle writes plain-text copies there). Flip **"Keep a weekly plain-text copy…"** ON and
   look at the pane at once: Back Up Now and the folder buttons grey while its pass runs, and the toggle itself
   greys while a Back Up Now runs. Press Back Up Now right after flipping: nothing doubles. The log below shows
   ONE run per act, and no *"failed"*. Turn the toggle back OFF afterwards.
5. **(P26 — the phone, optional.)** On the phone, with the same note open in both tab stacks, tap Library →
   Shelf → Library as fast as you can, then type. Expect the note you're LOOKING at to take the keystroke, and
   the other tab's copy never editable. (Already fixed since 2026-08-30; this is a confirmation, not a new face.)
6. **(P27 — not hand-walkable.)** It needs a take to arrive from another device inside a typing burst; the pin
   drives exactly that. If she wants to try: type in the Mac note while adding a take to the NEXT block from the
   phone, then ⌘⇧M across the two within a second — the merged block should carry the take and the receipt
   should say *"…1 other take came along whole…"*.

### NOTICED, NOT TOUCHED (C5's scope fence)

1. **⌥⌘⇧M's arity is still read from the frozen `slots`** (the `.merge` arm's ceremony branch, same two numbers
   P27 fixed for ⌘⇧M). Mechanism: a take born mid-burst makes the door REFUSE with *"needs a fan"* while one
   exists (a factually wrong refusal, the safe direction — pressing again after the burst works); and the mirror,
   a take archived elsewhere mid-burst, makes "Merge choosing takes…" fall through `openMergeCeremony`'s truth
   read into an INSTANT merge rather than its ruled refusal. Neither authorizes from stale state, which is why it
   was left; fixing it is one store read in that branch and changes what the ceremony door does in the second
   case — a door-behaviour call. Needs an owner (18o's correctness singles, or the ladder's word).
2. **Canvas reports no caret OFFSET** — the Blocks row's "fourth reporter … a design act", now a fifth surface
   with a real caret. Canvas → Write lands at the card's remembered offset (else its start), not where the
   canvas pane's caret sat. Needs an owner if she wants it (U-20's family; a design act, not a fix).
3. **P26's neighbour, traced on the way:** a grant whose editor is DEREGISTERED (its screen popped) while the grant
   is suspended mid-flush still resumes into `noteLivenessGranted()` — a pop does not bump the handoff token. The
   popped model ends `isLive` with no surface (its screen is gone, so no keystroke road), until it deallocates;
   a later `register` cannot stand it down because it is no longer registered. Not user-visible; a
   `live === editor` belt beside the token would close it. The mobile app row's.
4. **P38's consequence is not reproducible in the harness** (0/80 false `failed`, both source shapes — the snapshot
   writes serialise, so one prune lands before the other lists). The single-flight latch removes the race
   structurally; the `failed` arms stay as guards. Recorded so no one reads the green as the race "measured gone".
5. **The Mac's merge/undo doors now await before `runStructural` raises its flight flag in one more place**
   (P27's read) — the window the carry-all and seam roads already had; a second structural act inside it is
   refused by `runStructural`'s own guard. Recorded for the Fable reviewer, not a defect found.
6. `git worktree prune` (run while removing this unit's scratch worktree) also removed the STALE administrative
   entry for `/private/tmp/claude-501/u1-baseline-tree` that C1–C6 left in place — its directory was already gone
   (it was listed `prunable`), so only metadata went; nothing on disk was touched.

### CAPTURES

None (the GUI walk is HELD — see the first line). The evidence is the harness logs in `App/Variorum/DerivedData/`
(gitignored), with the scripts beside them (`18k-c5-run.sh`, `18k-c5-phone.sh`, `18k-c5-closing.sh`,
`18k-c5-closing-at.sh`):
- Row 59: `18k-c5-i1-{prefix,fixed,R1}`.
- P26: `18k-c5-p26-{head,M}`.
- P27: `18k-c5-p27-{prefix,fixed,R1}`.
- P33: `18k-c5-p33-{prefix,fixed,R1,Mredo}`.
- P38: `18k-c5-p38-{prefix,prefix-iter40,prefix-disk40,fixed,R1,Mc,Md}`.
- Closing: `18k-c5-closing1` · `18k-c5-pair-{old1,new2,old2,new3}` · `18k-c5-msc-{new,old}-iter10` ·
  `18k-c5-ios-build` · `18k-c5-phone-closing`.
- Deaths / resumes: none.
- **C5 — DONE (implementer), awaiting the orchestrator's spot-check; the hands-on GUI walk HELD.**

### UNIT C5 — ORCHESTRATOR ADJUDICATION (2026-09-25; the unit CLOSES here)

**Verified by spot-check:** C5's commits through `36984601`, pushed, zero trailers (checked over every
message since `5d831922`), tree clean, no scratch worktree, zero app instances. Scope: 14 files — zero
`Sources/`, zero `Sync/`; `EditorSurfaceController` (P27, the seam's pair) changed only in the unfanned
branch's authorization read. **ACCEPTED — C5 DONE:** row 59, P27, P33 (+ the redo door), P38 FIXED
with red-on-old pins (revert-identical); P26 found already fixed by `6bc4f187` and given its missing
pin. The closing Mac set's 2 issues are `ModeSwitchCarryTests`' top-of-Write arm — the flake list's
member — ADJUDICATED by the paired interleaved protocol against `5d831922` (both trees green 2/2
interleaved, 10/10 isolated). Dispositions copied into 17e (this commit); KnownIssues row 59 CLOSED;
the ceremony-branch residue → 18o; the phone's popped-screen residue → the mobile app row. **FOR THE
FABLE LADDER:** P27's store read (a short await before `runStructural`'s in-flight flag — the same gap
the carry-all/seam roads already carry) and P33's shared latch. **Walks:** run next by the walk
session (R-18k-7).

---

## THE HELD WALKS — RESULTS (2026-09-25)

**Walk session** (spawned by the 18k orchestrator after C5, per R-18k-7; brief
`notes/handoffs/18k-held-walks-handoff.md`). 18k only — 18o has not opened.

**Step 0 — the grants, proved:** a compiled probe printed `AX: true SCREEN: true`
(`AXIsProcessTrusted()` / `CGPreflightScreenCaptureAccess()`), in this session's own process tree.

**Build walked:** the DEV-STORE Debug build (`io.lduarte.Variorum.debug`) from `main` at `791044eb`, into its
own DerivedData (`App/Variorum/DerivedData/18k-walks/`). Captures: `notes/plans/18k-screens/walks/`
(gitignored). Zero app instances at the start (`pgrep -fl 'Variorum.app/Contents/MacOS'` empty).

### LIVE STATUS

- Step 0 (grants) — DONE (`AX: true SCREEN: true`).
- The Debug build — DONE (`** BUILD SUCCEEDED **`, `DerivedData/18k-walks-build.log`).
- C1 — DONE, **PASS** (table below).
- C2 — IN-PROGRESS. C3 · C6 · C5 — NOT-STARTED.
- Deaths / resumes: none.

**The dev store as found:** custody posture **standard** ("Your Apple account holds a key") — the app opened
with no Touch ID prompt, so no step of this walk met a custody gate; Terminal voice; the pink palette;
appearance `system`. The Debug binary is launched DIRECTLY with `OS_ACTIVITY_DT_MODE=YES`, its output
logged to `walks/app-run<n>.log` (the SwiftUI warning count's source).

### C1 — the registry release: many notes, then ⌘Q (Terminal voice; lifecycle, voice-independent)

| # | Step | Captures | What I saw | Verdict |
|---|---|---|---|---|
| 1 | Open 16 notes (Library click + ⌘K), each switched through a mode (⌘1…⌘7 in rotation) and back to Write, leaving each for the next; the oldest Open-strip row closed once the strip held five (below C1's recorded tenth-row Debug trap, owned by 18o) | `c1-00-library` · `c1-01-first-note` · `c1-02-palette` · `c1-03-second-note` · `c1-04-after-14-notes` | Every open and mode switch landed; no stall, no crash; the 97 s script time is the script's own delays. *A Scandal in Bohemia* (262 blocks) opened through Blocks and back without a hitch | PASS |
| 2 | Type a marker into a note, then leave it | `c1-05-typed-marker` | ` c1walkmark` landed whole at the end of *three ways of working*'s last block (per-character `osascript` keystrokes with re-activation — the whole string landed) | PASS |
| 3 | Type a second marker into *Walk test* and quit AT ONCE, by identity (`tell application id … to quit` — the ⌘Q road's terminate, never a keystroke) | `c1-06-walk-test` · `c1-07-quitmark-typed` | The quit call returned after **0.26 s**; the process was gone **0.42 s** after the call | PASS |
| 4 | Relaunch; open both notes | `c1-08-relaunch-walk-test` · `c1-09-relaunch-three-ways` | Both markers present: *Walk test* reads `words c1quitmark` (the still-open note, saved by the quit's flush alone), *three ways of working* ends `…the bridge.” c1walkmark`; both stamped "edited today" | PASS |
| 5 | Clean up: both markers deleted by backspace | `c1-10-walktest-cleaned` · `c1-11-threeways-cleaned` | Both notes back to their original text | — |
