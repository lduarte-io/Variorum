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
| **C3** | The mechanical state-write deferrals (~14 geometry actions, the `BookIndexView` twin first, Canvas's observed geometry writes, window registration WITH the sticky-key ruling) | review §5.1 A3/A4/A5 | hygiene → per-site verdict table (the 13u4 S3 form) + a before/after `Modifying state during view update` count on a bounded run; behaviour byte-identical; walk of Canvas drag + the book Index | Opus | NOT-STARTED |
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
- C2 — IN-PROGRESS (brief appended; implementer spawned).
- C3–C6 — NOT-STARTED.
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
  Held so far: C1 (open/close many notes; ⌘Q feels instant).
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

**NOT DONE (first line, per the brief):** PENDING — written at close.

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
  off the measured height after 20 turns on the old road) — its numbers are now printed; interpreted
  after the fix runs (PENDING). The pins as committed:
  the seam `InlineEditorSurface.Coordinator.viewUpdated(chrome:gutter:on:)` — `updateNSView`'s body
  moved verbatim onto the coordinator (still a synchronous `remeasure()`: behaviour-identical) so a pin
  can drive the update road without a SwiftUI `Context`; `VariorumTests/InlineHeightReportTests.swift`
  (4 tests): the mount reports nothing inside itself and the first height still arrives with NO storage
  edit to prompt it · an update pass reports nothing inside itself and the reflowed height arrives next
  turn · a burst (3 keystrokes + 2 update passes in one turn) reports once · the whole road — the real
  `EditorView(inline: true)` mounted fresh reaches its measured height (a GUARD; its teeth are a
  mutation). No double-realization pin: the double is DISPROVED as this binding's effect and does not
  reproduce today (THE MEASUREMENT).
- The `Modifying state during view update` count, before/after, one fixed suite set — NOT-STARTED.
- In-app use evidence (dev-store Debug, scripted; the GUI walk HELD for TCC) — NOT-STARTED.
- The ledger row amendment (claimed only if confirmed) — NOT-STARTED.
- Closing runs — NOT-STARTED.
- Deaths / resumes: none.
