# Phase 19 — Standing Fixes (STANDING PLAN, the second ledger)

> **This phase does not close.** It is the successor ledger to Phase 17, opened at the author's
> word on 2026-10-04, the night 17's alphabet filled (17z took the last letter): *"we don't have
> phase 19 right now, right? make a note that future small issues like the 17 rounds should start
> filling up phase 19 a–z now."* Its **entries** (19a, 19b, … 19z) are what open, run, and close —
> the phase itself stays open for the life of the project. A closed entry is never reopened; a
> recurrence gets a fresh letter.
>
> **Every rule from Phase 17 binds here unchanged** (the philosophy and the stated rules at the top
> of `notes/plans/phase-17-standing-fixes.md` are the canon; read them before opening an entry):
> product advancement never lands here; the master plan carries one pointer row; each entry is
> scoped, cast, run and closed on its own; pin before fix with red-on-old verified by revert; an
> Opus cold review is mandatory per entry, a Fable one whenever the diff touches `Sync/`,
> custody/keychain or the editor seam (the author may waive); a standing-fixes entry is a valid
> KnownIssues owner. **Phase 17's own OPEN entries (17r, 17s, 17w, 17x, 17y, 17z and the 17e
> residue) still run and close in THEIR file** — only NEW entries land here.

## The entries

| Letter | Subject | State |
|---|---|---|
| a | Xcode 27 / Swift 6.4: the TEST-target + mobile migration (the 13r toolchain census's 28 non-app errors) | REVIEW-PENDING — acceptance met 2026-10-04 by the implementer's runs (the 19a RECORD); the Opus cold review is next |

---

## 19a — Xcode 27 / Swift 6.4: the test-target + mobile migration

**Opened 2026-10-04 by the 13r orchestrator** (not author-filed — flagged to her and RATIFIED
at her word the same day: *"that's fine on 19a being opened by you - the ledger never needed to
say that it would be author filled in the first place, the 17 series was also used by sessions
whenever they needed a place to put an issue"* — sessions may open entries here, as they did in
17; the toolchain moved to Xcode 27.0/27A266a mid-13r at her hands, and the 13r U1
implementer's clean-build census found the breakage; the census record is the 13r plan's U1
RECORD, commit `d2e091ee`, logs under the gitignored `App/Variorum/DerivedData/13r-u1/`).
**Deliberately NOT in this entry:** the Mac APP's one error (`PaneSurface.swift:1076`,
isolated-conformance) — an editor-seam line that lands inside 13r U1 and rides 13r's Fable
ladder; this entry's diff touches NO editor seam, NO `Sync/` source, NO custody.

**Scope (the census, exact):**
- **`VariorumTests` (Mac), 20 errors / 8 files:** `PaletteDerivationTests` ×10 (main-actor
  statics `all` / `resolved(_:tint:)` used from nonisolated test contexts) ·
  `PlainPasteTests` ×2 (`MemberImportVisibility`: missing `import VariorumCore`) · GRDB
  `Row`'s now-enforced unavailable Sendable: `TagAndFolderTests` ×2, `TutorialWalkTests` ×2,
  `LifecycleFacesTests` ×1, `PoolDragTests` ×1, `StructuralGestureTests` ×1 ·
  `EditorSeamCostTests` ×1 (a main-actor static from a nonisolated context).
- **Core tests, 7 errors, ALL in `Tests/VariorumCoreTests/FurnitureConvergenceRepairTests.swift`:**
  lines 433/727/803 missing `await` + `Row` Sendable; line 864 `Row` Sendable alone.
- **Mobile, 1 error:** `VariorumMobile/Features/Write/MobileChipFlow.swift:81` — type-check
  timeout on the `height` reduce in the chip-flow `sizeThatFits` (fix = split the expression;
  same computed layout).

**Rules:** MECHANICAL migration only — isolation annotations, `await`s, imports, materializing
`Row` reads inside database closures, expression splitting; **test intent and assertions
byte-preserved**. Any fix that would change what a test asserts STOPS and reports.
`FurnitureConvergenceRepairTests` is a sync-convergence suite — the sync engine's protection —
so the cold review explicitly verifies no assertion weakened there. Pin-before-fix reads on
this entry as: these are COMPILE errors, red-on-old IS the failing build (the 13r-u1 probe
logs record it); no behavioral pin is owed, and the acceptance is the suites RUNNING green.

**Acceptance:** core `swift test` green in full · the eight fixed Mac files' suites green
(suite-level `-only-testing` from `App/Variorum/`, the "Test run with N tests" line confirmed,
`skipped:` lines read) · **the TK2 point-release tripwire suites green under the new toolchain**
(`JumpViewportLayoutTests` · `RefontGapTopTests` · `InlineHeightReportTests` ·
`TakePaneMeasureTests` · `PaneRenderRestoreClipTests` · `IndexTierMetricsTests` ·
`PaneFindFaceTests` — the first suite run on a new Xcode major IS the SDK-shift census) ·
**`PaneSurfaceTests` green — its five `PaneDecoration.resolve` pins are the behavior-preservation
proof for 13r U1's one-line fix** · the mobile target builds. Mac runs at zero-instance windows.

**Cast:** `opus-implementer`; **Opus cold review** (mandatory per entry; no Fable trigger —
the editor-seam line is 13r's, reviewed there). **Sequencing:** strictly sequential with 13r's
agents — runs after 13r U1's implementer session ends, before 13r U2 spawns (U2/U3's pins and
the 13r ladder's "suite green" need the restored base; U1's static drill and her live drill do
not wait on this entry).

**State: REVIEW-PENDING** — acceptance met 2026-10-04 by the implementer's runs (the 19a RECORD
below: core 2174/244 · the fixed Mac files' 48 suites 286/48 · the TK2 tripwires 41/8 at a
zero-instance window · `PaneSurfaceTests` 15/1 with the authorized pin · the mobile app builds); the
Opus cold review (`notes/REVIEW_PROMPT.md` verbatim) is next, spawned by the orchestrator.

### 19a RECORD (the implementer's LIVE STATUS — Opus, 2026-10-04; DONE(hash) / IN-PROGRESS / PENDING)

**NOT DONE BY THIS ENTRY (stated first, per the contract):** no walk capture — the entry's acceptance
is the suites RUNNING green (no product face changed; the one `Sources` line is a value-identical
expression split in a SwiftUI `Layout` whose arithmetic is not headless-pinned — `MobileChipFlowTests`
pins the pure brains only — and the mobile TEST target was neither built nor run: the entry asks for
the mobile app build only). No `Sync/`, no custody, no schema, no app source beyond that one mobile
line; 13r U1's `PaneSurface.swift` line untouched (the mutation check below swapped it temporarily
and restored it, sha256-verified). The brief's "`PaneSurfaceTests`' five `PaneDecoration.resolve` pins
PROVE 13r U1's line behavior-preserving" did NOT hold as stated — piece 4 says why; the orchestrator
ADJUDICATED it (piece 5) and authorized ONE committed absolute pin, landed here. **The drill-window pause is LIFTED** (the orchestrator's "drill window closed",
2026-10-04 — her live drill passed; U1 closed): suites run at quiet windows from here, her real-store
instance never touched, the measurement-shaped TK2 tripwire suites preferring a zero-instance window.
(During the window the implementer ran compile-only work — `swift build --build-tests` and
`xcodebuild build-for-testing` — and held core `swift test` too, since some core suites exercise
keychain custody seams and her drill read the keychain.)

**Toolchain at session start (re-read, matches the pinned pair):** macOS 27.0 (26A428) · Xcode 27.0
(27A266a) · `xcode-select -p` = `/Applications/Xcode.app/Contents/Developer`. Zero-instance check
(`pgrep -fl 'Variorum.app/Contents/MacOS'`) at session start: no match.

**Red-on-old (the census, re-read from the 13r-u1 probe logs, exact):** `probe-xcodebuild-bft.log`
20 errors / 8 files (PaletteDerivation 24/76/107/124/125/128/176/187/191/236 · PlainPaste 88/103 ·
TagAndFolder 103/111 · TutorialWalk 480/514 · LifecycleFaces 50 · PoolDrag 59 · StructuralGesture 492
· EditorSeamCost 183); `probe-swift-build-tests.log` 7 errors (FurnitureConvergenceRepair 433 ×2,
727 ×2, 803 ×2, 864); `probe-mobile-build.log` 1 error (MobileChipFlow 81 — NOTE: line 81 is the
`contentWidth` expression (81–84), not the `height` reduce (78–80) the entry names; the probe log's
own source excerpt shows it; `height` type-checks).

**THE CENSUS WAS A LOWER BOUND (found 2026-10-04, same session).** `swift build --build-tests` stops
at the first failing COMPILE BATCH (SwiftPM has no keep-going flag), so the probe saw only the batch
holding `FurnitureConvergenceRepairTests`. Fixing it and rebuilding exposed three more core sites,
each in a later batch, fixed in the same mechanical classes (logs `App/Variorum/DerivedData/19a/
core-build-tests{,-2,-3,-4}.log`, gitignored): `Phase11LockstepSyncTests.swift:221` (ROW-COPY, ×2
errors — **a sync lockstep/convergence suite: the cold review checks it like Furniture**) ·
`TagFamilySectionsTests.swift:101/107` (EXPR-SPLIT: "failed to produce diagnostic" + "generic
parameter 'Value' could not be inferred" on a typed `for fetch: @Sendable (Database) throws -> Int in
[closure, closure]` header) · `StructuralSplitAtNewlinesTests.swift:393` (TRY-IN-REQUIRE, below).
The fourth build is GREEN.
**The Mac target's census was a lower bound for the same reason** (`xcodebuild` stops scheduling
compile batches after the first failure): after the 20 census sites, the rebuild exposed
`LifecycleFacesTests.swift:94` (ROW-COPY — the file's SECOND read, a tuple holding `[Row]`); a
continue-after-errors pass (`-IDEBuildingContinueBuildingAfterErrors=YES`, an IDE build-system
default, not a build setting) then showed exactly ONE remaining failing batch, nine errors: ROW-COPY
at `BookStructureTests` 312/385 · `CanvasAndPoolTests` 69 · `CanvasBankTests` 120/338 ·
`CanvasDragTests` 333; ISOLATION at `BoundaryClampTests` 226/242/248 (one sync test calling the
Mac-only `CrossBlockRefusal.message(for:)` forward). After those, `** TEST BUILD SUCCEEDED **`
(logs `App/Variorum/DerivedData/19a/mac-bft{,-2,-3,-4}.log`). **Totals: core 7 → 12 errors in 5 files;
Mac 20 → 30 errors in 13 files; mobile 1.**

**The mechanism classes (for the cold review):**
- **ROW-COPY** (GRDB `Row` crossing an async `read`): GRDB 7 declares `@available(*, unavailable)
  extension Row: Sendable` (`.build/checkouts/GRDB.swift/GRDB/Core/Row.swift:278-280`). Under Swift
  6.2 the solver treated the unavailable conformance as non-conforming, so every `db.read { …Row… }`
  in an async body silently resolved to the SYNC `AppDatabase.read` overload (which is why the core
  sites compiled with no `await` at all). Swift 6.4 now selects the async overload
  (`read<T: Sendable>(_: @Sendable …) async`, `AppDatabase.swift:184`) and diagnoses the unavailable
  conformance (plus, at the await-less sites, the missing `await`). Fix: `await` the read and copy
  the rows INSIDE the closure — `….map(CopiedRow.init)` — into `CopiedRow`
  (`Tests/VariorumCoreTests/Support/CopiedRow.swift`; the Mac target gets the same type): a Sendable
  `(columns, values: [DatabaseValue])` copy whose two String-keyed subscripts READ THROUGH A REBUILT
  GRDB `Row` (so decoding, NULL and missing-column behaviour are GRDB's own) and whose synthesized
  `==` equals `Row ==` for scope-free raw-SQL rows (ordered names case-sensitive, `DatabaseValue
  ==`). **Every `#expect` line at a ROW-COPY site is byte-identical.** Overload proof: a standalone
  Swift 6.4 experiment mimicking `Row`'s three subscripts vs the copy's two (scratchpad `solver/`)
  binds the SAME `Value` for every shape the sites use — `x?["c"] as String?` (Optional<String>,
  so NULL reads nil, never a trap) · `x["c"] == "lit"` / `== s` / `allSatisfy { $0["c"] == … }`
  (String) · `x["c"] == nil` / `!= nil` (the untyped subscript) · `let k: String = x["c"]`.
- **ISOLATION** (main-actor members called from nonisolated test contexts): the Mac app target
  builds with `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`; `VariorumTests` does not (nonisolated).
  `PalettePreset.all` / `resolved(_:tint:)` sit in an `extension PalettePreset` that is NOT marked
  `nonisolated` (the struct is), and the 3-arg `CrossBlockRefusal.message(range:index:slots:)` and
  `message(for:)` live in the Mac's default-isolated `CrossBlockRefusalRoads.swift` extension (the
  enum itself is `nonisolated`) — so all are main-actor members Swift 6.4 now refuses from a
  nonisolated sync test. Fix, test-side only (no app source touched): `@MainActor` on the
  `PaletteDerivationTests` SUITE (all ten sites plus its shared `presets` helper are inside it; every
  test there is a pure computation) and on the ONE function at each of
  `EditorSeamCostTests.theCrossBlockRefusalDiagnosisStaysCheapAtTwentyThousandBlocks` (a 50 ms
  ceiling over a synchronous pure call — main-actor execution cannot interleave inside it) and
  `BoundaryClampTests.theSurvivingResidualsAreNamedAndNeitherIsAGeometry`.
- **IMPORT** (`MemberImportVisibility`, on in every target): `PlainPasteTests` reads
  `Queries.RenderedBlock.text` without importing its defining module — `import VariorumCore` added.
- **EXPR-SPLIT** (type-check failures): MobileChipFlow:81 (DONE — `contentWidth`'s one expression
  became `let rowWidths: [CGFloat] = rows.map { row in let chipWidths: CGFloat = …reduce(0, +); let
  gaps: CGFloat = CGFloat(max(row.count - 1, 0)) * hSpacing; return chipWidths + gaps }` then
  `rowWidths.max() ?? 0` — the same per-row sum, the same gaps, the same `+` order, the same max and
  the same empty answer; `height` untouched, it type-checks) · TagFamilySections:101 (DONE —
  the typed closure array hoisted to `let fetches: [@Sendable (Database) throws -> Int]`, then
  `for fetch in fetches`; same two closures, same order, same loop body).
- **TRY-IN-REQUIRE** (Xcode 27's Swift Testing `#require` now expands a function-call argument into
  `__checkFunctionCall(db.self, calling: { $0.fetchString($1,$2) }, …)`, a closure the outer `try`
  does not cover): `StructuralSplitAtNewlinesTests.swift:393` gains `try` before `db.fetchString(` —
  **the ONE assertion-line byte change so far: an effect marker only, the same call and the same
  value checked** (the macro now checks it as a value rather than decomposing the call; only a
  failure message's sub-expression detail differs).

**Pieces:**
1. Core test target compiles under Xcode 27 — DONE (this commit): ROW-COPY at
   `FurnitureConvergenceRepairTests` 433/727/803/864 + `Phase11LockstepSyncTests` 221; EXPR-SPLIT at
   `TagFamilySectionsTests` 101; TRY-IN-REQUIRE at `StructuralSplitAtNewlinesTests` 393;
   `Support/CopiedRow.swift` new. `swift build --build-tests` exit 0 (log `core-build-tests-4.log`).
   Core `swift test` full run — PENDING (held for the drill window).
2. Mac `VariorumTests` compiles under Xcode 27 — DONE (this commit): ROW-COPY at `TagAndFolderTests`
   104/112 · `TutorialWalkTests` 480/514 (the call-site copy; the `userPostRows` helper keeps returning
   `[Row]` — it is called only inside the reads) · `LifecycleFacesTests` 50 (`container()` now returns
   `CopiedRow`) + 94 · `PoolDragTests` 59 · `StructuralGestureTests` 492 · `BookStructureTests`
   312/385 · `CanvasAndPoolTests` 69 · `CanvasBankTests` 120/338 · `CanvasDragTests` 333; ISOLATION at
   `PaletteDerivationTests` (suite) · `EditorSeamCostTests` (one test) · `BoundaryClampTests` (one
   test); IMPORT at `PlainPasteTests`; `VariorumTests/CopiedRow.swift` new (the core copy's twin). **No
   `#expect`/`#require` line changed in the Mac diff.** The ROW-COPY overload experiment was extended
   to the Canvas shapes (`rows[0]["x"] == Double(…)` → `Double`; `let x: Double? = rows.first?["x"]`
   → `Optional<Double>`) — the same bindings as `Row`. `xcodebuild build-for-testing` →
   `** TEST BUILD SUCCEEDED **` (log `mac-bft-4.log`). Suite runs — PENDING.
3. Mobile `MobileChipFlow.swift:81` — DONE (this commit; EXPR-SPLIT above). `xcodebuild -scheme
   VariorumMobile -destination 'generic/platform=iOS Simulator' build` → `** BUILD SUCCEEDED **`, no
   diagnostic on the file (log `App/Variorum/DerivedData/19a/mobile-build.log`). The only `Sources`
   line in this entry's diff.
4. Acceptance runs — IN-PROGRESS.
   - **Core `swift test`, full: GREEN — `✔ Test run with 2174 tests in 244 suites passed`** (13i-e's
     baseline 2173/244), exit 0, the one `skipped:` line the standing Supabase integration gate
     (`basicOfflineEditsConvergeOverTheRealServer`, env-gated), XCTest `Executed 0 tests` (no XCTest
     cases). Every touched core test passed BY NAME: `theLosersTombstoneArrivingBeforeItsRepointsMoves
     TheMembershipsToTheKeeper` (433) · `aLoserRenamedLocallyStillHandsItsMembershipsToTheKeeper` (727)
     · `aFreshStoreMeetingTheLoserDeadHandsItsMembershipsToTheKeeper` (803) ·
     `aMembershipArrivingUnderTheDeadLoserRepointsToTheKeeper` (864) ·
     `duplicateCanvasRowsRepairToTheSmallerIDAndTheRepairPushes` (Phase11 221) ·
     `bothReadsAreBlindToAutosave` (TagFamily) · `everyRowItWritesIsAnOrdinaryOutboxedRow`
     (SplitAtNewlines). Log `App/Variorum/DerivedData/19a/core-swift-test.log`.
   - **`CopiedRow` ↔ `Row` parity, on a real database (a THROWAWAY probe, run once by filter, deleted,
     never committed):** NULL / missing column / present via the untyped subscript; `as String?` on
     text, NULL and missing; `as Int?`, `as Double?` (and `Double?` from an integer column); a
     case-insensitive `let x: String = copy["T"]`; `copy["t"] == "abc"`; `==` against an equal row, a
     row differing in one value, and a row differing only in a column name's CASE — 18 checks, every
     one the same answer as `Row`. 1 test, passed.
   - **The 13 fixed Mac files' suites + `PaneSurfaceTests`/`PanePublishDoorTests`** (48 suites, every
     test type in those files; `test-without-building`, suite-level `-only-testing`): **run 2 GREEN —
     `✔ Test run with 286 tests in 48 suites passed`, no `skipped:` line** (286 = the files' `@Test`
     count exactly). Run 1 (same set) had ONE issue: `CanvasHostedRealizationTests.
     aMountedLongPostRealizesABoundedCardSet` — `paneCount > 0` (a 300-card canvas mounted in its own
     `NSWindow` found no `PaneTextView` in the hierarchy). Not this entry's: the test touches no edited
     line (this file's edit is line 69, another struct) and no `CopiedRow`; GREEN alone 2/2
     (`mac-canvas-hosted-{1,2}.log`) and in run 2; and the same expectation failed the same way in a
     crowded Act 10 full run under Xcode 26 (`notes/plans/act10-correction-screens/batch-g/
     g-full-mac.log:1091`). Recorded as the pre-existing concurrent-mount sensitivity of a mounted
     window test, with her real-store app live beside the run. Logs `mac-suites-{1,2}.log`.
   - **`PaneSurfaceTests` GREEN (run 2) — `theLivePanesDecorationFollowsTheIndicatorPreference`, the
     test holding all five `PaneDecoration.resolve` calls, passed by name. BUT those five pins do NOT
     discriminate 13r U1's line** (`PaneSurface.swift:1077`, `tokens.map { _ in Color.clear } ??
     Color.gray.opacity(0.25)`): every call passes NON-nil tokens, and they compare the rest look only
     RELATIVELY (`off == rest`, `background.stroke == rest.stroke`, `resolve(isLive: false, …) ==
     rest`) — no test anywhere pins either arm's ABSOLUTE stroke (grep: `PaneDecoration` appears in
     tests only there and in `hostRing`'s three pins). A swapped or merged arm would stay green. **What
     stands in, as evidence (a THROWAWAY probe in `VariorumTests`, run once by filter, deleted, never
     committed — the line is 13r's editor-seam fix, so a committed pin is 13r's ladder's call, not this
     entry's):** for both voices × light/dark × every indicator style, `resolve(isLive: false, …,
     tokens: voiced) == PaneDecoration(stroke: .clear, lineWidth: 0.5, fill: nil)`; for every style,
     `resolve(isLive: false, …, tokens: nil) == PaneDecoration(stroke: Color.gray.opacity(0.25),
     lineWidth: 0.5, fill: nil)` and `!=` the clear one; and the live `.off` arm returns each rest. 1
     test, passed (`mac-probe-run.log`). So U1's line reads the shipped values on BOTH arms — the
     comment's contract ("voiced compositions draw nothing … tokens nil keep their grey hairline").
     **Routed to the orchestrator: whether 13r's ladder wants that probe's two absolute assertions
     committed as a real pin.**
     **ADJUDICATED** — see piece 5.
   - **The core count's +1 vs the 13i-e closeout baseline (2174/244 vs 2173/244):** not this entry's
     — 19a adds no core test (`8fe0680e` touches no `@Test` line). The closeout paragraph's 2173 was
     counted BEFORE the 13i-e post-close addendum: `6b1eefaf` (her W-O-1(b) ruling, 2026-10-03)
     renamed `aDecidedPairBringsNothingBack` → `aDecidedPairStillBringsTheJournalBackAndRefilesNothing`
     and ADDED `aHandRemovedPairStaysRemovedButTheJournalStillReturns` (DailyJournalRulingsTests), and
     `d58bc3ee` already recorded "core 2174/244".
   - **The mobile target builds** — DONE (piece 3).
   - **The seven TK2 tripwire suites — GREEN at a ZERO-INSTANCE window** (her app quit, the
     orchestrator's word; `pgrep` empty before AND after, 11:19:23Z–11:20:53Z; products rebuilt from the
     restored tree first): `JumpViewportLayoutTests` · `RefontGapTopTests` · `InlineHeightReportTests` ·
     `TakePaneMeasureTests` · `PaneRenderRestoreClipTests` · `IndexTierMetricsTests` (+ its file's
     `PaneLineMetricsScopeTests`) · `PaneFindFaceTests` — **`Test run with 41 tests in 8 suites passed …
     with 4 known issues`**, no `skipped:` line. The 4 known issues are the STANDING non-intermittent
     `withKnownIssue` at `IndexTierMetricsTests.swift:290` (#154 (b)'s one residual, 18l-c: TK2 lays the
     extra line after an empty last paragraph short), 2 voices × the Book Index and Read-edit panes —
     **measured −10.0 pt (Terminal) / −20.0 pt (Study), exactly the values recorded on 27.0**. **The
     SDK-shift census: the first suite run on Xcode 27 / the 27.0 SDK finds NO TK2 geometry shift** (the
     OS stayed 27.0 / 26A428 — only the toolchain and SDK moved). Log `mac-tk2-tripwires.log`.
5. **THE ONE AUTHORIZED NEW ASSERTION** — the 13r orchestrator's "19a MID-RUN ADJUDICATION"
   (`notes/plans/phase-13r-distribution.md`, the LIVE STATUS bullet, `0b2c1385`): the finding accepted,
   the "five pins prove it" acceptance line corrected, and — **as a scoped exception to this entry's
   no-new-assertions rule** — ONE committed pin authorized: `PaneDecoration.resolve`'s ABSOLUTE rest
   values on both arms, named as the Xcode-27 isolated-conformance fix's tripwire. **LANDED (this
   commit):** `PaneSurfaceTests.theRestLookHoldsItsAbsoluteValueOnBothArms` — for both voices ×
   light/dark × every indicator style, voiced tokens → `PaneDecoration(stroke: .clear, lineWidth:
   0.5, fill: nil)`; for every style, nil tokens → `PaneDecoration(stroke: Color.gray.opacity(0.25),
   lineWidth: 0.5, fill: nil)`. GREEN on the current tree: `✔ Test run with 15 tests in 1 suite
   passed` (`PaneSurfaceTests`, 14 + the pin; `mac-pin-green.log`). The pin's own red-on-old cannot
   run (the pre-U1 spelling no longer compiles), so its discrimination is shown by a MUTATION CHECK:
   **MUTATION CHECK STARTING after this commit** — `PaneSurface.swift:1077`'s arms are swapped
   temporarily (`tokens.map { _ in Color.gray.opacity(0.25) } ?? Color.clear`), the pin must go RED,
   then the file is restored with `git checkout -- App/Variorum/Variorum/Surface/PaneSurface.swift`
   (it is committed and carries no other change) and its sha256 re-read against
   `f5549afc0f5e3732ca9c4c23068d0d24ebf1204aa1e6ac40120c225064c1d770`. If this record still says
   STARTING, the check died mid-flight: run that `git checkout --` first.
   **MUTATION CHECK — DONE.** With the arms swapped (`mac-bft-mutant.log`, `mac-pin-mutant.log`): the
   new pin went **RED, 15 issues** (12 voiced: 2 voices × 2 appearances × 3 styles at line 169; 3 nil
   at line 176) and it was the ONLY failing test — **the five relative pins stayed GREEN under the
   mutant** (`✘ Test run with 15 tests in 1 suite failed … with 15 issues`, every issue the new pin's),
   the finding demonstrated directly. Restored with `git checkout --`; sha256 re-read =
   `f5549afc…c1d770`, the pre-mutation value; `git status` clean; the test products rebuilt from the
   restored tree (`mac-bft-restored.log`) before the tripwire run.

**DISPOSITIONS (every census and extension site):** all **FIXED** — core 12 errors / 5 files, Mac 30
errors / 13 files, mobile 1. Evidence class (the entry's own reading of pin-before-fix): red-on-old
IS the failing build (`App/Variorum/DerivedData/13r-u1/probe-*.log` for the census;
`App/Variorum/DerivedData/19a/core-build-tests{,-2,-3}.log` and `mac-bft{,-2,-3}.log` for the
extensions), green-on-new is the compiling targets plus the suites above. Nothing DISMISSED, nothing
DEFERRED. **Assertion bytes:** every `#expect`/`#require` line in the diff is byte-identical EXCEPT
(1) `StructuralSplitAtNewlinesTests.swift:393` — `try` added inside a `#require` (an effect marker;
the same call and value), and (2) the ONE new pin, authorized (piece 5). The two sync-convergence
files (`FurnitureConvergenceRepairTests`, `Phase11LockstepSyncTests`) change ONLY their read lines
(`await` + `.map(CopiedRow.init)`); every assertion there is byte-identical and every touched test
passed by name.

**FOR THE COLD REVIEW — the diff, by class (`git diff a634ff7a..HEAD -- Tests App`):**
- ROW-COPY: `Tests/VariorumCoreTests/Support/CopiedRow.swift` + `App/Variorum/VariorumTests/CopiedRow.swift`
  (new, identical bodies) · core `FurnitureConvergenceRepairTests`, `Phase11LockstepSyncTests` · Mac
  `TagAndFolderTests`, `TutorialWalkTests`, `LifecycleFacesTests`, `PoolDragTests`,
  `StructuralGestureTests`, `BookStructureTests`, `CanvasAndPoolTests`, `CanvasBankTests`,
  `CanvasDragTests`. Check: `CopiedRow`'s reads go through a rebuilt GRDB `Row`; `==` matches
  `Row ==` for scope-free rows; the overload experiment and the real-DB parity probe (piece 4).
- ISOLATION: `PaletteDerivationTests` (suite `@MainActor`), `EditorSeamCostTests` and
  `BoundaryClampTests` (one function each).
- IMPORT: `PlainPasteTests`.
- EXPR-SPLIT: `TagFamilySectionsTests` (core), `MobileChipFlow.swift` (the one `Sources` line).
- TRY-IN-REQUIRE: `StructuralSplitAtNewlinesTests` (core).
- THE AUTHORIZED PIN: `PaneSurfaceTests.theRestLookHoldsItsAbsoluteValueOnBothArms`.

**NOTICED (routed to the orchestrator; none acted on here):**
1. **A possibly VACUOUS `#expect` under Xcode 27's Testing macros, unresolved:**
   `Tests/VariorumCoreTests/CatalogDetailWordsTests.swift:45`
   (`#expect(RuleGrammar.hearsApplyingActs(.tag("t1")))`) now WARNS "result of call to
   'hearsApplyingActs' is unused" inside its expansion
   (`__checkFunctionCall(RuleGrammar.self, calling: { $0.hearsApplyingActs($1) }, .tag("t1"), …)`).
   That is the shape the `-> R?` overload of `__checkFunctionCall` would take with `R = Void` — which
   would make the expectation always pass. An isolated reproduction (a mimic with the same
   `(RuleTerm?) -> Bool` signature, scratchpad `expectprobe/`) is NOT vacuous (its false
   expectations fail) and does not warn, and the sibling lines 46–51 do not warn either, so the real
   module's warning is unexplained. Not checked further (the orchestrator's stop order). The settling
   check, ≈2 min: a throwaway core test whose FIRST statement is the same form on a FALSE value
   (`#expect(RuleGrammar.hearsApplyingActs(.tag("")))`) must FAIL. If it passes, every
   `__checkFunctionCall`-shaped `#expect` deserves a sweep — an entry of its own.
2. **The census method:** both `swift build` and `xcodebuild` stop scheduling compile batches at the
   first failure, so a one-pass "census" of a new toolchain is a LOWER BOUND (13r U1's 28 became 43
   here). The next major's census should iterate to green before quoting a number.
3. **Swift 6.4 warnings, not errors (out of scope):** core test build 60 warnings (new classes:
   "no calls to throwing functions occur within 'try'" ×11, "#require is redundant" ×8, unused
   results), Mac test build 207; 13r U1 recorded 4 new `nonisolated(unsafe)`-unnecessary warnings in
   core `Sources`.
4. **`CanvasHostedRealizationTests.aMountedLongPostRealizesABoundedCardSet`** — the pre-existing
   concurrent-mount sensitivity (piece 4): one `paneCount > 0` miss in a 48-suite run beside her live
   app, green alone 2/2 and in the re-run; the same miss is on record from Act 10 under Xcode 26.
5. **Two `CopiedRow` copies** (the core and Mac test targets share no support module) — keep them
   identical; the Mac file's header says so.

**Commits:** `4a50d0f2` (record opened, drill pause) · `8fe0680e` (piece 1, core) · `7fbe7550` (piece
2, Mac) · `dd2bd8f8` (piece 3, mobile) · `feaf5045` (acceptance runs) · `97ce8a87` (piece 5, the pin)
· `12d28565` (tripwires + mutation check) · this commit (dispositions, State → REVIEW-PENDING).
