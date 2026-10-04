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
| a | Xcode 27 / Swift 6.4: the TEST-target + mobile migration (the 13r toolchain census's 28 non-app errors) | **CLOSED 2026-10-04** — round 2: no BLOCKER/MAJOR (2 MINOR record-scope, dispositioned into the lesson/19b/19c; 1 NIT next-touch); every target green under Xcode 27 |
| b | Xcode 27 / Swift 6.4: the MOBILE test-target migration (19a round-1 finding 2's census; CopiedRow unified to ONE source, three consumers) | **CLOSED 2026-10-04** — round 1 CLEAN BILL (no BLOCKER/MAJOR/MINOR; 2 record-scope NITs dispositioned); 6 sites fixed, mobile 62/14 green |
| c | The Xcode-27 residue census: silent vacuous-#expect candidates (19a NOTICED #6) + the test-side isolation warnings, Mac AND MOBILE (#7, widened at 19b's close) | **RUNNING 2026-10-04** — the implementer's LIVE STATUS is the 19c RECORD at this file's tail |

---

## 19c — the Xcode-27 residue census (opened 2026-10-04 by the 13r orchestrator; owns 19a's NOTICED #6 and #7)

**Arm 1 — the silent vacuous-#expect candidates (#6).** F1's mechanism has a WARNING-FREE
twin: a `@discardableResult … -> Bool` callee asserted bare takes the same Void route with no
tell. 65 such functions exist in `Sources` + the Mac/Shared app code; the named live
candidates are `MarkdownActsTests.swift:96/123/146/167/191`
(`#expect(MarkdownActs.apply(.bold, to: h.textView))`) and
`BookStructureTests.swift:782/786/793` (`#expect(book.structure.acceptDrop(…`); R2-2 adds the
MOBILE arm — `MobileMarkdownActs.swift:90–91` asserted bare at
`MobileMarkdownTests.swift:389/397/453/551/563` — so Arm 1's universe is `Sources` + the
Mac/Shared app code + `VariorumMobile/`, with the mobile call sites sequenced AFTER 19b (no
mobile test build exists until 19b). **Scope:** enumerate EVERY bare `#expect(F(…))` call
site over a `@discardableResult -> Bool` callee (grep-complete, recorded); settle each
candidate with a red mutant **IN PLACE in the real test target at the EXACT spelling, then
revert — never in a scratch or mimic module (R2-1: the import graph, not only the spelling,
decides the overload; the recorded trigger conditions rank candidates, never clear them)**;
re-spell any vacuous site (explicit type or `== true`) with the mutant red on the new
spelling; a site whose falseness cannot be staged mechanically is recorded, not guessed. **Arm 2 — the isolation residue (#7), WIDENED
to the mobile side at 19b's close:** the warning-grade main-actor reads in seven Mac test
files (`BookViewTests`, `LibraryPanelTests`, `PagedReadTests`, `ReadNoteLandingTests`,
`ReadTierTests`, `TakePaneMeasureTests`, `TutorialWalkTests`) AND in the five mobile test
files 19b's census found (`MobileMarkdownTests`, `MobileTakesBrowserTests`,
`MobileCommentDraftTests`, `MobileCommentParkTests`, `MobileProtectionTests` — 20 warnings;
the per-class table is the 19b RECORD's) get the same test-side `@MainActor`, assertion
bytes unchanged — the F3 class closed file-complete on BOTH platforms before the next
toolchain promotes it to red. **Adjacent residue recorded here, deliberately NOT owned by
this entry (19b round 1's routing):** the 10 deprecated `UIWindow.init(frame:)` sites in 7
mobile test rigs — not mechanical (the replacement needs a window scene); a fresh letter
when a toolchain turns it red. **Rules:** 19a's
(mechanical only; anything intent-changing stops and reports). **Acceptance:** the census
table in the record (site → real/vacuous-fixed, mutant evidence per fix) · zero isolation
warnings left in the Mac test build AND zero in the mobile test build beyond the recorded
not-owned classes (the deprecation class and `MobileProtectionTests:1572`'s unnecessary
`try` stay recorded, not owed) · the touched suites green at a quiet window. **Cast:**
`opus-implementer`; Opus cold review. **State: OPEN — runs at 19b's close (2026-10-04): the
mobile test build it needed exists; her walk outranks it for the machine.**

---

## 19a ROUND 1 — the Opus cold review's findings and the orchestrator's dispositions (2026-10-04, same-model flow: the orchestrator arbitrates, the implementer fixes, a FRESH reviewer runs round 2)

- **F1 [MAJOR] — `CatalogDetailWordsTests.swift:45` is VACUOUS under Xcode 27 — ACCEPTED,
  ORCHESTRATOR-CONFIRMED by the decisive check run by my own hands** (line 45's argument →
  the provably-false `.tag("")`: the suite stayed GREEN 2/2; file restored, tree clean).
  Mechanism per the review (from Xcode 27's `Testing.swiftinterface`): a bare implicit-member
  `.tag(…)` argument in function-call shape routes the `#expect` expansion through
  `__checkFunctionCall` with R = Void — the Bool is discarded (the compiler's own
  "unused result" warning IS the tell) and the check passes on `.some(())`, unable to fail.
  **The orchestrator's earlier settlement (`e57fbb4c`) is WITHDRAWN:** its probe substituted
  `.legacyProfile` for the trigger spelling `.tag`, which changed overload resolution — the
  probe proved a DIFFERENT instance real. The lesson, binding on future settlements: **a
  settling probe must reproduce the EXACT trigger spelling, or prove the substitution
  resolution-equivalent** *(AMENDED at round 2, R2-1: and it must run IN PLACE in the real
  test target — the import graph also decides the overload, so a scratch/mimic module can
  clear a vacuous site wrongly even at the exact spelling)*. FIX (the implementer, in-entry): re-spell line 45 with the explicit
  type (`RuleTerm.tag("t1")`) or `== true`; land the review's mutation pin discipline (the
  `.tag("")` mutant must go RED on the new spelling — it is GREEN on today's); correct NOTICED
  #1; record the census rule — an unused-result warning inside an `#expect` expansion means a
  vacuous expectation until proven otherwise (and a `@discardableResult` callee takes the same
  path with NO warning — the review's named blind spot).
- **F2 [MAJOR] — the mobile TEST target does not compile and nothing owned it — ACCEPTED,
  ownership gap real; ROUTED TO 19b** (below) rather than extending this entry: the
  orchestrator read the review's own continue-after-errors log (`mobile-bft-2.log`) and the
  class reaches **~61 sites across ~25 mobile test files** (the review's six were the
  first-failure floor) — a full unit of its own by the sizing rule, and this entry's session
  already carried one. 19b carries the census, the same rules, and the CopiedRow unification
  question.
- **F3 [NIT] — `LandingAuthorityTests.swift:54–59`, the ISOLATION class as warnings —
  ACCEPTED: fix in-entry now** (the same test-side `@MainActor`, assertion bytes unchanged;
  one toolchain promotion from red is exactly what this entry exists to prevent). The
  review's app-side root note (nonisolated types with default-isolated extensions) is
  recorded here, no fix owed in a test-migration entry.
- **F4 [NIT] — the CopiedRow doc comment's duplicate-column claim is half-true — ACCEPTED as
  the COMMENT NARROWING** (both twins: case-variant duplicate names unsupported; every live
  site reads single-table rows with unique names). The case-insensitive rebuild is NOT
  implemented (zero live sites — over-build); the one-source-many-targets unification rides
  19b, which adds the third consumer.
- **Out-of-entry note recorded:** `SyncEnrollmentTests.swift:262`'s `!= nil` on a non-optional
  `SymmetricKey` is dead weight (the `try` carries the real check) — remove at the next
  legitimate touch of that file; no fix owed here.
- **The clean bill acknowledged:** the convergence suites' assertions proven unweakened by the
  review's three red mutations; CopiedRow↔Row parity independently re-verified; the authorized
  pin independently confirmed discriminating; every acceptance claim checked against its log.

## 19a ROUND 2 — the fresh reviewer's verdict and the orchestrator's dispositions (2026-10-04); THE ENTRY CLOSES

**No BLOCKER, no MAJOR — no round 3 earned; F1/F3/F4 confirmed sound** (the re-spell verified
against the real module graph with a true red/green pair at the exact spelling; the F1 census
claim re-checked across every build log; F3's six warnings traced into the one now-annotated
test, suites 10/2 green; F4's narrowed comment verified against GRDB's own source and all 20
live sites). Two MINOR findings, both record/ledger scope, DISPOSITIONED BY EDIT in this
commit; one NIT held to next-touch:

- **R2-1 [MINOR] ACCEPTED — the settlement lesson was incomplete: the IMPORT GRAPH, not only
  the spelling, decides the overload.** The reviewer's probes: the same exact spelling is REAL
  with `import Testing` alone and VACUOUS once `SwiftUI`/`AppKit`/`Dependencies` is visible
  (an Optional-typed parameter + certain implicit-member names — observed: `tag`, `id`,
  `opacity`, `post`, `bold`); `Foundation`/`Combine`/`GRDB` leave it real. So NOTICED #1's
  failed reproduction was the import graph's doing, and even an exact-spelling probe in a
  scratch module can clear a vacuous site wrongly. **The lesson as AMENDED (binding, here and
  in 19c's rules): settle by mutating IN PLACE in the real test target, then revert — never
  in a scratch or mimic module.** The trigger conditions are recorded as a candidate-RANKING
  aid only, never a clearance.
- **R2-2 [MINOR] ACCEPTED — mobile's vacuous-expectation check was unowned.** Named live
  candidates: `MobileMarkdownActs.swift:90–91` (`@discardableResult … -> Bool`) asserted bare
  at `MobileMarkdownTests.swift:389/397/453/551/563`. DISPOSITIONED: 19b's acceptance gains
  the zero-unused-result-warnings line; 19c Arm 1 widens to the mobile callees and call
  sites, sequenced after 19b (both edited below/above in this commit).
- **R2-3 [NIT] — one 127-column comment line in each CopiedRow twin: re-wrap at next touch**
  (recorded; no commit owed).

**19a IS CLOSED** (opened and closed 2026-10-04; the red-on-old was the failing Xcode-27
build; every target compiles and runs green; the ladder ran round 1 → fixes → round 2 clean).

## 19b — Xcode 27 / Swift 6.4: the MOBILE test-target migration

**Opened 2026-10-04 by the 13r orchestrator out of 19a's round-1 review** (finding 2: the
mobile TEST target was outside every census — the 13r-u1 probe built the mobile APP only —
and does not compile under Xcode 27; unowned ⇒ owned here). **Scope:** the Row-Sendable
ROW-COPY class across `App/Variorum/VariorumMobileTests/` — **~61 sites in ~25 files** per
the reviewer's continue-after-errors log (a FLOOR until the build is green: censuses are
lower bounds, 19a's own lesson); the same rules as 19a (MECHANICAL migration only, assertion
bytes preserved, any intent-changing fix stops and reports); PLUS the **CopiedRow
unification question** — one source file serving core/Mac/mobile versus a third identical
twin: the implementer PROPOSES, the orchestrator rules, before building that part.
**Acceptance:** mobile TEST BUILD SUCCEEDED (generic iOS Simulator) · the touched files'
suites green on a concrete simulator (suite-level, counts confirmed) · **zero unused-result
warnings inside `#expect`/`#require` expansions in the mobile test build (F1's census rule;
any found settled by an IN-PLACE mutant at the exact spelling — R2-1's amended lesson)** ·
F4's narrowed comment carried into whatever CopiedRow shape lands. **Cast:** `opus-implementer`; Opus cold review.
**Red-on-old:** the failing build itself (`mobile-bft-2.log` preserved in the 19a round-1
evidence). **State: CLOSED 2026-10-04 — the Opus cold review returned a CLEAN BILL (no
BLOCKER, no MAJOR, no MINOR; two record-scope NITs, dispositioned in the ROUND 1 section
below); no round 2 earned.**

**THE CENSUS CORRECTED (the implementer's log re-read, 2026-10-04 — accepted by the
orchestrator):** the "~61 sites in ~25 files" above was the round-1 log's WARNING census
misread as the error class; the preserved red-on-old carries **6 ROW-COPY error sites in 4
mobile test files** (MobileLibraryTests:212 · MobileMembershipTests:239/299 ·
MobileShellTests:270 · MobileTutorialWalkTests:395/433), a FLOOR until the implementer's own
builds iterate to green. The ~60 warnings get a per-class census in the 19b RECORD (counts +
classes, no fixes beyond this entry's own acceptance lines); their ROUTING is held for the
orchestrator at the entry's close (candidates: the mobile main-actor warning class widens
19c Arm 2; cosmetic classes recorded next-touch).

**THE COPIEDROW FORK — RULED BY THE ORCHESTRATOR (2026-10-04, repo-first before the build):
OPTION A, one file, three consumers.** `Tests/VariorumCoreTests/Support/CopiedRow.swift`
stays the single source; the Xcode project gains ONE classic file reference to it (a small
TestSupport group) plus one PBXBuildFile per TEST target's Sources phase; the Mac twin
`App/Variorum/VariorumTests/CopiedRow.swift` is DELETED. Why over B: one source of truth
ends the lockstep-editing class F4 already exposed; the pbxproj risk is contained to
test-target sections (provable in the diff) and cannot touch 13r's BUILT walk artifacts; B
would institutionalize a three-way copy rule the next toolchain bump punishes. RIDERS: (1)
the record PROVES from the diff that zero app-target lines changed; (2) the twin's deletion
lands in the SAME commit as the wiring — no interval with a duplicate or missing type; (3)
verification owed: core `swift build --build-tests` green · Mac `build-for-testing` compiles
· the Mac suites that consume CopiedRow (19a's migrated Row-copy suites) re-run GREEN at a
zero-instance window (the re-pointed file proven serving the Mac target identically) ·
mobile per this entry's own acceptance; (4) comment fate as proposed — F4's narrowed text
verbatim, the three-consumers header, "keep them identical" retires, R2-3's re-wrap counts
as its next touch; (5) any harness-stopped deletion is surfaced, never worked around.

## 19b ROUND 1 — the Opus cold review's verdict and the orchestrator's dispositions (2026-10-04, same-model flow); THE ENTRY CLOSES

**CLEAN BILL: no BLOCKER, no MAJOR, no MINOR — no round 2 earned.** The reviewer verified by
its own hands: six in-place red mutants in the real mobile target (exactly 6 issues, then
reverted, tree clean) proving every migrated assertion can still fail — including the new
`== nil as String?` shape, proven non-vacuous; the 6-site census reconfirmed from both logs;
zero `#expect`/`#require` lines changed; the pbxproj object diff independently reproduced
(only the main group, the two TEST Sources phases, and the four new objects — all six
targets, every configuration, both app Sources phases unchanged); the twins' code proven
identical pre-deletion; mobile 62/14 green on a concrete simulator; Mac 213/40 and core 29/5
green at a zero-instance window; the warning census reconciled (58 path-anchored + 2
macro-expansion = 60). Reviewer evidence: `App/Variorum/DerivedData/19b-review/` (kept; its
3.3 GB of build products deleted, logs retained). Two NITs, both record-scope:

- **N1 [NIT] ACCEPTED — the 19b RECORD's post-edit line citations drifted by one; THIS BLOCK
  is the corrected citation** (the record's prose stands as written; verified by the
  orchestrator's own grep at HEAD): `.map(CopiedRow.init)` sits at MobileLibraryTests:215 ·
  MobileMembershipTests:242/303 · MobileShellTests:279 · MobileTutorialWalkTests:396/434;
  the two flagged read shapes at MobileMembershipTests:244/305 (`== nil as String?`) and
  MobileLibraryTests:218/222. The census lines (the compiler's error lines on the OLD tree)
  were correct as recorded. The record's "evidence in place" gap for the NULL-binding shape
  is also closed BY THE REVIEW: its green run proved the binding, and the reviewer's red
  mutants (logs `19b-review/mobile-bft-mutant.log` + `mobile-mutant-run.log`; issues at
  Library:217, Membership:244/305, Shell:281/282, TutorialWalk:439) supply the
  can-fail proof R2-1's discipline asks for.
- **N2 [NIT] ACCEPTED as next-touch, record-only:** CopiedRow's failure output prints two
  parallel arrays where `Row` printed name:value pairs; the improvement at the next
  legitimate touch is a `CustomStringConvertible` built from `zip(columns, values)` (never
  `row.description` — the dictionary rebuild loses column order). Joins R2-3's next-touch
  class. No commit owed.
- **Out-of-diff item 1 — FIXED in this commit:** the master plan's standing-fixes pointer
  row (17) gains the succession sentence naming THIS ledger as the active one (the ledger
  header's "the master plan carries one pointer row" promise was dangling for 19).
- **Out-of-diff item 2 — RECORDED, no entry opened:** a fresh mobile build shows 7 app/core
  SOURCE warnings, outside 19b/19c's test-file scope (warning-grade, zero behavior change;
  next legitimate touch per file). One is `Shared/EncryptionSession.swift:387` ("`joined`
  inferred as `()?`") — custody-adjacent, so any future touch of that file is FABLE-seat
  work by the standing review rule.

**THE NOTICED ROUTING (held to the close, now ruled):** (1) the 20 mobile isolation
warnings in 5 files → **19c Arm 2 WIDENS to the mobile side** (the 19c entry is amended in
this commit); (2) the 10 deprecated `UIWindow.init(frame:)` sites in
7 test rigs are RECORDED in 19c's entry as adjacent residue deliberately NOT owned there
(not mechanical — the replacement needs a window scene; promote to a fresh letter when a
toolchain turns it red); (3) the counting lesson, binding on future censuses: xcodebuild's
"(N failures)" counts BUILD COMMANDS, not errors — count unique `error:` lines, and include
`macro expansion #expect:` lines when counting warnings (they carry no file path).

**19b IS CLOSED** (opened and closed 2026-10-04; the red-on-old was the failing mobile test
build; one round, clean).

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

**State: ROUND-2-PENDING** — acceptance met 2026-10-04 by the implementer's runs (the 19a RECORD
below: core 2174/244 · the fixed Mac files' 48 suites 286/48 · the TK2 tripwires 41/8 at a
zero-instance window · `PaneSurfaceTests` 15/1 with the authorized pin · the mobile app builds);
round 1 reviewed and arbitrated (the "19a ROUND 1" section above); its three in-entry fixes F1 · F3 ·
F4 landed (the RECORD's "ROUND 1 FIXES"; `e9fbccbe`, `13610ffc`): `RuleHearsActsTests` 2/1 with
the F1 mutant RED, `LandingAuthorityTests` + `LandingSignpostTests` 10/2. A FRESH reviewer runs
round 2 over the fixes (`git diff 574ea6a8..HEAD -- Tests App`), spawned by the orchestrator.

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

**ROUND 1 FIXES (LIVE STATUS — the same implementer, resumed 2026-10-04 at the orchestrator's
arbitration `e1bfdd08`; the binding record is the "19a ROUND 1" section above):**
- F1 [MAJOR] `CatalogDetailWordsTests.swift:45` vacuous — **DONE (`e9fbccbe` + this commit).**
  Re-spelled `#expect(RuleGrammar.hearsApplyingActs(RuleTerm.tag("t1")))` — the explicit type, the
  file's own line-51 idiom — under a three-line comment naming why (the expectation now sits at line
  49). The core test build carries ZERO unused-result warnings inside any `#expect`/`#require`
  expansion (it carried 1, this line; `r1-core-bft.log`). **Mutation check DONE:** argument →
  `RuleTerm.tag("")` ⇒ `RuleHearsActsTests` RED, exactly 1 issue, at the re-spelled line
  (`Expectation failed: RuleGrammar.hearsApplyingActs(RuleTerm.tag(""))`; `r1-f1-mutant.log`) — the
  same mutant was GREEN on the old spelling (the orchestrator's decisive check). Restored with
  `git checkout --`, tree clean, suite GREEN again 2/1.
  **NOTICED #1 CORRECTED:** the isolated reproduction I cited did not reproduce the trigger (its
  stand-in enum resolved differently), so "not vacuous in isolation" proved nothing about line 45;
  the line WAS vacuous. Mechanism (the review's, from Xcode 27's `Testing.swiftinterface`): the
  bare implicit-member `.tag(…)` argument in function-call shape routes the `#expect` expansion
  through `__checkFunctionCall` with R = Void, the Bool is discarded, and the check passes on
  `.some(())`. **THE CENSUS RULE (binding on any toolchain census):** an unused-result warning inside
  an `#expect`/`#require` expansion means a VACUOUS expectation until a red mutant proves otherwise
  — and a `@discardableResult` callee takes the same path with NO warning, so the tell cannot
  clear those. Applied to this entry's targets: the core and Mac test builds carry exactly ONE such
  warning between them (line 45, now gone). The silent half is NOT cleared — see NOTICED #6.
- F3 [NIT] `LandingAuthorityTests.swift:54–59` isolation warnings — **DONE (this commit).**
  `@MainActor` on the one synchronous test, `theTwoPoliciesCarryTheSurfacesShippedNumbers` (its six
  `BookView.landing*` / `ReadingFlowView.landing*` reads are main-actor statics); assertion bytes
  unchanged. The Mac test build's lines carrying those six warnings: 12 → 0 (`r1-mac-bft.log`).
  `LandingAuthorityTests` + `LandingSignpostTests` (the file's two suites): **`✔ Test run with 10
  tests in 2 suites passed`**, no `skipped:` line, at a zero-instance window (`pgrep` empty before
  and after; `r1-landing.log`). The rest of the class in the Mac build (AppKit `subviews` / `title`
  / `frame` / `identifier` from nonisolated contexts — `BookViewTests`, `LibraryPanelTests`,
  `PagedReadTests`, `ReadNoteLandingTests`, `ReadTierTests`, `TakePaneMeasureTests`,
  `TutorialWalkTests`) is NOT F3's and is not touched — NOTICED #7.
- F4 [NIT] both `CopiedRow` twins' duplicate-column comment — **DONE (this commit).** Narrowed in
  both: an EXACT duplicate keeps the leftmost; duplicates differing only in CASE are NOT supported
  (the rebuilt row comes from an unordered dictionary, so GRDB's case-insensitive lookup picks one
  unspecified); every live site reads single-table rows with unique names. Comment-only — the
  bodies are byte-identical between the twins (`diff` clean) and both targets build. No
  case-insensitive rebuild (the arbitration's ruling).
- F2 is 19b's (the mobile TEST target) — not touched here.

**NOTICED, round 1 (routed to the orchestrator; none acted on):**
6. **The census rule's SILENT half is live in this codebase, unverified.** 65 functions in `Sources`
   and the Mac/Shared app code are `@discardableResult … -> Bool` (scratchpad list), and Mac tests
   assert some of them BARE with an implicit-member argument, the exact F1 shape minus the warning,
   e.g. `MarkdownActsTests.swift:96/123/146/167/191` (`#expect(MarkdownActs.apply(.bold, to:
   h.textView))`), `BookStructureTests.swift:782/786/793` (`#expect(book.structure.acceptDrop(…`).
   Whether any is vacuous is unknown until a red mutant at its exact spelling says so — a census
   of its own (a natural rider for 19b, or a fresh letter).
7. **The ISOLATION class still stands as WARNINGS** in seven Mac test files (F3's list above): one
   toolchain promotion from red, like F3. Not this round's.

---

## 19b RECORD (the implementer's LIVE STATUS — Opus, 2026-10-04; DONE(hash) / IN-PROGRESS / PENDING)

**NOT DONE BY THIS ENTRY (stated first, per the contract):** (1) no walk capture — no product face
changed: the diff is test-target-only (four mobile test files, the one shared test-support file's
COMMENT, the Mac twin's deletion, and test-target-only pbxproj objects), so the entry's acceptance is
builds + suites, as 19a's was; (2) NO full suite — only the touched mobile files' suites, rider 3's Mac
CopiedRow consumers, and the core CopiedRow consumers ran (below); (3) no vacuous-`#expect` settlement
— the R2-2 mobile candidates are 19c Arm 1's, untouched (re-spelling them would change assertion
bytes); (4) no warning fixed — the 60-warning census is RECORDED for the orchestrator's routing; (5) no
`Sync/`, no custody, no schema, no app source, no Release build, `/Applications` untouched (no Mac-app
change: the app targets' pbxproj objects are byte-equal — no refresh owed); `Tools/Release/` and 13r's
DerivedData folders untouched.

**Toolchain at session start (re-read, matches the pinned pair):** macOS 27.0 (26A428) · Xcode 27.0
(27A266a) · `xcode-select -p` = `/Applications/Xcode.app/Contents/Developer`. Zero-instance check
(`pgrep -fl 'Variorum.app/Contents/MacOS'`) at session start: no match. Base `102453a8`.

**THE CENSUS, re-read from the preserved red-on-old (`App/Variorum/DerivedData/19b/mobile-bft-2.log`,
the 19a round-1 reviewer's continue-after-errors `build-for-testing`):** exactly **6 ERROR sites in 4
files**, all ROW-COPY (`conformance of 'Row' to 'Sendable' is unavailable`), each printed twice (two
arch passes): `MobileLibraryTests.swift:212` · `MobileMembershipTests.swift:239/299` ·
`MobileShellTests.swift:270` · `MobileTutorialWalkTests.swift:395/433`. **The entry's "~61 sites in
~25 files" is NOT the log's error census** — the log's ~60 unique WARNING lines (20 "no calls to
throwing functions occur within 'try'", 17+2+1 main-actor reads from nonisolated contexts, 10
`UIWindow.init(frame:)` deprecations, …) match that figure; the errors are 6. Still a FLOOR (19a's
lesson): SIL-stage diagnostics only run once a batch type-checks, so the number is quoted only after
my own builds iterate to green. Ten more `Row.fetch*` reads in the mobile tests (`MobileBlockHistory`
55, `MobileShell` 249, `MobileStructural` 511, `MobileTakeLock` 42/55, `MobileTutorialWalk` 193/1061,
`MobileWalk` 495) did NOT error — each is checked below before it is called out of scope.

**THE COPIEDROW FORK — RULED: OPTION A** (the orchestrator, `52edc1f9`; the ruling text and its five
riders live in the 19b entry above). Built in piece 2: `Tests/VariorumCoreTests/Support/CopiedRow.swift`
is the ONE source; the Xcode project compiles that same file into BOTH test targets; the Mac twin
`App/Variorum/VariorumTests/CopiedRow.swift` is deleted in the SAME commit as the wiring (rider 2).
Facts behind it: both Xcode test targets are nonisolated (no `SWIFT_DEFAULT_ACTOR_ISOLATION`), Swift
6.0 mode, `MemberImportVisibility` on, fed by file-system-synchronized groups with empty Sources
phases, and already `import GRDB` — the type compiles identically in all three.

**Pieces:**
1. Red-on-old under my own hands — DONE (`1355ecad` record; the log is gitignored): a fresh
   `build-for-testing` of the unmodified tree (`App/Variorum/DerivedData/19b/mobile-bft-old.log`,
   derived data `19b/mobile.noindex`, `-IDEBuildingContinueBuildingAfterErrors=YES`) → `** TEST BUILD
   FAILED **`, exactly the same 6 error sites as the preserved log (no more, no fewer). Its "(27
   failures)" counts failed BUILD COMMANDS (four 6-file compile batches × two archs plus their per-file
   lines) — the failing batches hold 24 files, the likely source of the entry's "~25 files".
2. The six ROW-COPY call sites + the ruled CopiedRow shape — DONE (this commit). Call sites, 19a's
   shape exactly (the copy INSIDE the read closure; every `#expect`/`#require` line byte-identical):
   `MobileLibraryTests` 214 · `MobileMembershipTests` 241, 301 · `MobileShellTests` 280 (`Row.fetchOne(…)
   .map(CopiedRow.init)` — `Optional.map`) · `MobileTutorialWalkTests` 395, 433 (the call-site copy,
   `userPostRows(…).map(CopiedRow.init)`; the helper keeps returning `[Row]` — it is called only inside
   the reads, as on the Mac). The ruled shape: (a) `Tests/VariorumCoreTests/Support/CopiedRow.swift` —
   COMMENT-ONLY change (the body is byte-identical): the header now names its three consumers and how
   each sees it; F4's narrowed duplicate-column text carried verbatim (words unchanged); "keep them
   identical" retired; R2-3's 127-column line re-wrapped (this is its next touch); (b)
   `App/Variorum/Variorum.xcodeproj/project.pbxproj` — ONE `PBXFileReference` (`CopiedRow.swift`) in a
   new `TestSupport` `PBXGroup` (`path = ../../Tests/VariorumCoreTests/Support`, under the main group),
   TWO `PBXBuildFile`s, one in each TEST target's Sources phase; (c) `git rm` of the Mac twin (no harness
   stop). **RIDER 1 — zero app-target lines, PROVEN from the diff** (both files converted to JSON with
   `plutil`, every object compared — `App/Variorum/DerivedData/19b/pbxproj-object-diff.txt`): REMOVED
   none; ADDED exactly the file reference, the two build files and the `TestSupport` group; CHANGED
   exactly three objects — the project's main group (`children` gains `TestSupport`), `VariorumTests`'
   Sources phase `E1C271912FFC2F440084BEA6` and `VariorumMobileTests`' `E1D217642FFCE2C600886CFC`
   (`files: [] → [the build file]`); all six `PBXNativeTarget`s, every build configuration, and both app
   targets' Sources phases (`E1C271842FFC2F420084BEA6` Variorum, `E1D217582FFCE2C500886CFC`
   VariorumMobile) byte-equal.
   **Builds:** mobile `build-for-testing` (generic iOS Simulator) → **`** TEST BUILD SUCCEEDED **` on the
   FIRST iteration** (`mobile-bft-1.log`; the shared file compiled `in target 'VariorumMobileTests'` from
   `Tests/VariorumCoreTests/Support/CopiedRow.swift`) — **the census is FINAL: 6 sites in 4 files**,
   no SIL-stage extension site surfaced (unlike 19a's core and Mac targets). Mac `build-for-testing` →
   `** TEST BUILD SUCCEEDED **` (`mac-bft-1.log`; the shared file compiled `in target 'VariorumTests'`,
   zero references to the deleted twin). Core `swift build --build-tests` → `Build complete!`, exit 0
   (`core-build-tests.log`).
   **The ten non-erroring `Row.fetch*` reads** (named in the census paragraph) — checked, OUT OF SCOPE:
   each already maps its rows to Sendable values INSIDE the closure (`.map { ($0["kind"], $0["text"]) }`,
   `.map { $0["deleted_at"] as String? }`, `.reduce(into: [String: String]())`, …), so no `Row` crosses
   the async read — they are already in the copy-inside-closure shape.
3. The `#expect`/`#require` unused-result census over the green build log — DONE (this commit): see
   the WARNING CENSUS below. **ZERO unused-result warnings inside any `#expect`/`#require` expansion in
   the mobile test build** (acceptance line met).
4. Suites green on a concrete simulator — DONE (this commit). Every suite type in the four touched
   files (14 suites: `MobileLibraryTests` · `MobileLibrarySortTests` · `MobileMembershipTests` ·
   `MobileNoteRenameTests` · `MobileNoteEntryDateTests` · `MobileShellTests` · the eight
   `MobileTutorialWalkTests.swift` suites), `test-without-building`, suite-level `-only-testing`, on the
   project's established destination `platform=iOS Simulator,name=iPhone 17 Pro,OS=26.2`: **`Test run
   with 62 tests in 14 suites passed … with 2 known issues`** (62 = the files' `@Test` count exactly),
   ZERO `skipped:` lines (`mobile-suites-1.log`). The 2 known issues are the STANDING deliberate
   `withKnownIssue` in `theFannedDivideLessonLandsTheDuplicateShape` (`MobileTutorialWalkTests` 919–,
   13u1 ladder F-5 `0af79a38`, its KnownIssues row owned by the mobile project) — untouched here. **Every
   test holding a migrated site passed BY NAME:** `theNewNoteDoorMintsANamelessNote` (Library) ·
   `renameWritesTrimsAndBlankClears` + `setAndClearTheEntryDate` (Membership) ·
   `theShelfNewNoteDoorIsTheLibrarysTwin` (Shell) · `restoreReplacesWholesaleAndTouchesNothingElse`
   (TutorialWalk, both reads + the `[CopiedRow] ==` wholesale pin). **The read shapes (for the
   review):** `(x?["c"] as String?) == nil` and `as Int?` and `[copies] == [copies]` are 19a's covered
   shapes; two shapes are NEW here — `x?["c"] == nil as String?` (Membership 243/303) and `x?["c"]` passed
   to a `String?` parameter (`DisplayTitle.day(fromStamp:)`, `TimelineItem(createdAt:)`, Library
   217/221). Evidence in place, not in a mimic (R2-1): Membership 243/303 read a SQL NULL — had the copy's
   generic subscript bound a NON-optional `String`, GRDB's decode traps on NULL and the test dies; it
   passed, so the binding is `String?`, the only one that can read nil there, as `Row`'s did. Library
   217/221 read a NOT NULL `created_at` into `String?` parameters (no untyped-subscript candidate
   converts to `String?`), where `String` and `String?` bindings decode the same value.
5. Rider 3's Mac re-run — DONE (this commit). Every suite type in the nine Mac files that consume
   `CopiedRow` (40 suites; `BookStructureTests` · `CanvasAndPoolTests` · `CanvasBankTests` ·
   `CanvasDragTests` · `LifecycleFacesTests` · `PoolDragTests` · `StructuralGestureTests` ·
   `TagAndFolderTests` · `TutorialWalkTests`; the non-suite `CanvasDragRig` helper excluded) from the
   re-pointed build: **`✔ Test run with 213 tests in 40 suites passed`** (213 = those files' `@Test`
   count exactly), ZERO `skipped:` lines, at a ZERO-INSTANCE window — `pgrep -fl
   'Variorum.app/Contents/MacOS'` empty before (13:59:49Z) and after (14:01:14Z) (`mac-suites-1.log`,
   `mac-suites-1.window`). The re-pointed file serves the Mac target identically. **Extra, core:** the
   two core consumers' five suites (`JournalKeeperRepairTests` · `TheDrainOrderTests` ·
   `SchemaLockstepTests` · `SchemaVersionTransportTests` · `Phase11SyncConvergenceTests`) —
   **`✔ Test run with 29 tests in 5 suites passed`**, no `skipped:` line (`core-copiedrow-suites.log`;
   the core file's change is comment-only).

**DISPOSITIONS (every census site):** all six **FIXED** (ROW-COPY): `MobileLibraryTests` 212 ·
`MobileMembershipTests` 239, 299 · `MobileShellTests` 270 · `MobileTutorialWalkTests` 395, 433.
Evidence class (19a's reading of pin-before-fix for a toolchain migration): red-on-old IS the failing
build (`mobile-bft-2.log` preserved + `mobile-bft-old.log` by my hands, the same six); green-on-new is
the TEST BUILD SUCCEEDED + the suites above. Nothing DISMISSED, nothing DEFERRED inside the scope. The
ten non-erroring `Row.fetch*` reads: out of scope, already copy-inside-closure (piece 2). **Assertion
bytes:** ZERO `#expect`/`#require` lines in the diff (`git diff 52edc1f9..HEAD -- App Tests | grep -E
'^[-+].*#(expect|require)'` is empty). **Acceptance lines:** mobile TEST BUILD SUCCEEDED ✔ · the touched
files' suites green on a concrete simulator, counts confirmed, `skipped:` read ✔ · zero unused-result
warnings inside `#expect`/`#require` expansions ✔ · F4's narrowed comment carried into the ONE file ✔ ·
the ruling's riders 1–5 ✔ (1: the object diff; 2: `3c70b283` carries the wiring AND the deletion; 3:
core build-tests, Mac bft, rider-3 suites, mobile; 4: the comment fate; 5: the `git rm` met no stop).

**FOR THE COLD REVIEW — the diff, by class (`git diff 52edc1f9..HEAD -- App Tests`):**
- ROW-COPY: `App/Variorum/VariorumMobileTests/{MobileLibraryTests,MobileMembershipTests,MobileShellTests,
  MobileTutorialWalkTests}.swift` — six `.map(CopiedRow.init)` insertions inside read closures.
- THE ONE FILE: `Tests/VariorumCoreTests/Support/CopiedRow.swift` — comment-only (`git diff -w` shows no
  code line); `App/Variorum/VariorumTests/CopiedRow.swift` deleted; `App/Variorum/Variorum.xcodeproj/
  project.pbxproj` — the four added objects + three changed objects of rider 1's proof.
- Check: the shared file compiles `in target 'VariorumTests'` and `in target 'VariorumMobileTests'` from
  its core path (the build logs); no app target's objects changed; every `#expect` line byte-identical.

**NOTICED (routed to the orchestrator; none acted on):**
1. **The mobile ISOLATION warnings (20 = 17 + 2 autoclosure + 1 static, five files:
   `MobileMarkdownTests`, `MobileTakesBrowserTests`, `MobileCommentDraftTests`, `MobileCommentParkTests`,
   `MobileProtectionTests`)** are the 19a F3 / 19c Arm 2 class on the phone side — one toolchain
   promotion from red. A candidate widening of 19c Arm 2 (the orchestrator's routing call).
2. **`UIWindow.init(frame:)` deprecated in iOS 26 (10 sites in 7 files, the hosted-surface rigs)** —
   cosmetic today; `init(windowScene:)` needs a scene in a test host, so it is not a mechanical swap.
3. **The census-number lesson, refined:** an xcodebuild failure summary's "(N failures)" counts failed
   BUILD COMMANDS (batch lines + per-file lines × archs), and a continue-after-errors log's warning
   lines outnumber its errors — quote the unique `error:` lines, and include the
   `macro expansion #expect:` lines when counting warnings (they carry no file path).

**Commits:** `1355ecad` (record opened) · `3c70b283` (pieces 1–3: the six sites, the ruled CopiedRow
shape, the census) · this commit (pieces 4–5, dispositions, State → REVIEW-PENDING).

**THE WARNING CENSUS (the mobile TEST target, the green build `mobile-bft-1.log`; counts + classes only,
no fixes — routing is the orchestrator's at the close; the full line list is
`App/Variorum/DerivedData/19b/mobile-warning-census.txt`):** **60 unique warnings in 20 files** (each
printed once per arch). The test-target set is IDENTICAL between the red-on-old fresh build and the green
one — fixing the six sites surfaced no new warning. NOTE for any re-count: two of the 60 are reported at
`macro expansion #expect:1:N`, not at a file path, so a `^/…: warning:` grep finds only 58.
| Class | Count | Sites (file:line) |
|---|---|---|
| UnnecessaryEffectMarker — "no calls to throwing functions occur within 'try'" | 20 | `MobileNoteClipboardTests` 86/111/131/148/165/191 · `MobileTrashTests` 54/82/112/261/408/419 · `MobileUndoDoorTests` 116/194/220 · `MobileDeletionTests` 270 · `MobileEditTraceTests` 343 · `MobileEmptyStoreTests` 120 · `MobileTutorialWalkTests` 919 · `MobileProtectionTests` 1572 (INSIDE an `#expect` expansion: `#expect(try await PostureSwitchRunner.pendingMarker(…) == nil)`) |
| ISOLATION — main-actor property read from a nonisolated context | 17 | `MobileMarkdownTests` 646/647/648/649/651×2/653/656 · `MobileTakesBrowserTests` 741×2/956/957/963 · `MobileCommentDraftTests` 54/55 · `MobileCommentParkTests` 57/58 |
| ISOLATION — main-actor property read from a nonisolated AUTOCLOSURE | 2 | `MobileMarkdownTests` 657×2 |
| ISOLATION — main-actor STATIC property from a nonisolated context | 1 | `MobileProtectionTests` 620 (INSIDE an `#expect` expansion: `EncryptionView.keysReplacedExplanation`) |
| DeprecatedDeclaration — `UIWindow.init(frame:)` (iOS 26: "Use init(windowScene:)") | 10 | `MobileBlockHistoryTests` 579/688 · `MobileKeyboardBarGeometryTests` 254/584 · `MobileTakesBrowserTests` 768/944 · `MobileCommentDraftTests` 70 · `MobileCommentParkTests` 70 · `MobileLivenessTests` 400 · `MobileSurfaceDriver` 218 |
| "`#require(_:_:)` is redundant because … never equals 'nil'" | 4 | `MobileCrossBlockEditTests` 144/163/210/310 |
| "conditional cast … always succeeds" | 2 | `MobileQuickNoteTests` 1172/1188 |
| NoUsage — "expression of type 'Bool' is unused" | 2 | `MobileWriteLatchTests` 100/101 — `await first.value` / `await second.value` (a `Task<Bool>`'s value as a bare STATEMENT, NOT inside any `#expect`/`#require` expansion) |
| NoUsage — "immutable value … was never used" | 1 | `MobileUndoDoorTests` 250 |
| VariableNeverMutated | 1 | `VaultRPCEmulation` 104 |
**The F1 census rule applied:** zero "result of call … is unused" / unused-result warnings inside any
`#expect`/`#require` expansion (the build's only two in-expansion warnings are the isolation and
effect-marker lines above). **The rule's SILENT half is NOT cleared and is NOT this entry's:** a
`@discardableResult … -> Bool` callee asserted bare takes the vacuous route with NO warning — 19a
R2-2's named mobile candidates (`MobileMarkdownActs.swift:90–91` asserted bare at
`MobileMarkdownTests.swift:389/397/453/551/563`) carry no warning in this build, as the rule predicts;
settling them by in-place mutants is 19c Arm 1's, sequenced after this entry (the mobile test build now
exists for it).

---

## 19c RECORD (the implementer's LIVE STATUS — Opus, 2026-10-04; DONE(hash) / IN-PROGRESS / PENDING)

**NOT DONE BY THIS ENTRY (stated first, per the contract — PENDING, finalized at the close).**

**Toolchain at session start (re-read, matches the pinned pair):** macOS 27.0 (26A428) · Xcode 27.0
(27A266a) · `xcode-select -p` = `/Applications/Xcode.app/Contents/Developer`. Zero-instance check
(`pgrep -fl 'Variorum.app/Contents/MacOS'`) at session start: no match. Base `e8a0950e` (no code
change since 19b's `3c70b283`; every commit after it touches `notes/` only). Evidence logs:
`App/Variorum/DerivedData/19c/` (gitignored); census scripts in the session scratchpad, their
outputs copied into the evidence folder.

**THE METHOD (decided before any edit; the reviewer checks it):**
- **Arm 1 enumeration, two independent censuses.** (A) the GREP census the entry asks for — every
  `@discardableResult` declaration in `Sources` + `App/Variorum/{Variorum,Shared,VariorumMobile}`
  whose return type is `Bool`/`Bool?` (a balanced-paren signature parse, not a line grep), PLUS
  the same attribute on test-target helpers (an extension of the stated universe — the mechanism
  does not care where the callee lives; recorded as such); then every `#expect(`/`#require(` in
  the three test targets whose first argument, after `try`/`await`/`!`/outer parens, is a call
  whose final name is one of those callees, each RESOLVED by hand to its declaration (name
  collisions are many: `settle`, `poll`, `save`, `apply`…). (B) a COMPILER-LEVEL cross-check
  (PENDING): which `__checkFunctionCall` overload each expansion actually CALLS, read from the
  test objects' relocations (`llvm-objdump -d -r -l`; the line annotations name the macro buffer,
  whose mangled name carries the original line) — the `-> R?` overload under an `#expect` is the
  vacuous route by construction. (B) ranks and cross-checks; it never clears (R2-1).
- **Arm 1 settlement — the CALLEE-NEGATION mutant, in place.** Each in-class callee keeps its
  exact declaration (attributes, name, parameter clause, effects, return type) and its body is
  renamed aside behind a wrapper of the identical signature that calls it and returns the
  NEGATED Bool. Every call site stays byte-identical (the import graph, the spelling and the
  overload set are untouched; only the runtime value flips), every side effect still happens,
  and every assertion over the callee's Bool — bare, `!`-negated, `try`/`await`-prefixed or
  `== true/false` — must go RED if it is real. A site that stays green under its callee's
  mutant (and is proven REACHED) is VACUOUS. Re-spelled sites must then go RED under the same
  mutant on the new spelling, and green without it. Mutants are reverted with
  `git checkout --` of COMMITTED files only (the resiliency protocol's rule 11) and verified by
  `git status`/`git diff`.
- **Arm 2:** the warning census from fresh `build-for-testing` logs (Mac + mobile), the
  isolation class's sites per file, test-side `@MainActor` (19a F3's shape), assertion bytes
  unchanged, rebuild to zero.

**Pieces:**
1. The grep census (A) — IN-PROGRESS (hand resolution of the 369 name-matched sites): 95
   `@discardableResult … -> Bool/Bool?` declarations in the four code roots (19 core, 33 Mac, 21
   Shared, 22 mobile — 19a's "65" predates the mobile arm) + 17 test-target helpers.
2. Fresh builds — DONE (logs `mac-bft-0.log`, `mobile-bft-0.log`: `** TEST BUILD SUCCEEDED **`
   both; core `swift build --build-tests` up to date at HEAD, `core-build-tests-0.log`).
3. The compiler-level cross-check (B) — FIRST PASS DONE, positive control IN FLIGHT. Every
   `__check*` call in every test object, by macro expansion and overload route
   (`census/routes.py` → `mac-routes.tsv` 18,950 calls · `mobile-routes.tsv` 3,623 (arm64) ·
   `core-routes.tsv` 8,997): **ZERO `#expect` expansions on an Optional-returning route in any of
   the three targets** (the only `#expect` OPT routes are `__checkClosureCall`, i.e.
   `#expect(throws:)`, whose `E?` result is its contract). The five named MarkdownActs lines,
   e.g., call the `(T, Arg0, Arg1) throws -> Bool` overload. **Prediction: no vacuous `#expect`
   at HEAD — the mutants must confirm it (B never clears).** **POSITIVE CONTROL IN FLIGHT (a
   probe edit of a COMMITTED file):** `Tests/VariorumCoreTests/CatalogDetailWordsTests.swift:49`
   re-spelled back to 19a F1's bare `.tag("t1")`, core rebuilt, the census must flag line 49 OPT;
   restore = `git checkout -- Tests/VariorumCoreTests/CatalogDetailWordsTests.swift` (if this line
   still says IN FLIGHT, run that first).
4. Mutant runs, per target — PENDING.
5. Re-spells of VACUOUS sites + red-on-new-spelling — PENDING.
6. Arm 2, Mac then mobile — PENDING.
7. Acceptance runs + the census table + dispositions — PENDING.
