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
| a | Xcode 27 / Swift 6.4: the TEST-target + mobile migration (the 13r toolchain census's 28 non-app errors) | OPEN — queued behind 13r U1's session, runs BEFORE 13r U2 spawns |

---

## 19a — Xcode 27 / Swift 6.4: the test-target + mobile migration

**Opened 2026-10-04 by the 13r orchestrator** (not author-filed — flagged to her in the same
report; the toolchain moved to Xcode 27.0/27A266a mid-13r at her hands, and the 13r U1
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

**State: OPEN.**
