# Phase 13b — Stage 0(a): Mac Frontend Architecture & Tech-Debt Survey

**Status:** EVIDENCE DOSSIER — verdicts (keep / consolidate / rebuild) are the
architect's, not this document's. Every claim carries file:line evidence.
**Scope:** `App/Variorum/Variorum/` (feature modules, app-level composition,
`Theme/`) + the `Shared/` pieces the frontend's liveness machinery rides on
(`AutosaveCoordinator`, `AppSession.quitFinalize`). `Sources/VariorumCore` is
out of scope; frontend misuse of it is noted where seen (§8.5).
**Paths** below are relative to `App/Variorum/` unless absolute.
**Method:** full reads of the live editor core, Takes, ReadTier, and the
composition layer; structured grep sweeps (notifications, fixedSize,
liveness refs, timers, @Observable/@State, ruling tags, test counts) over
everything else. Surveyed 2026-07-20.

---

## 1. Headline numbers

- **80 Swift files, 21,375 lines** in the Mac app target (`wc -l` sweep).
- **Biggest files:** `EditorViewModel.swift` 2,994 · `TakesViewModel.swift`
  890 · `BookView.swift` 764 · `TakesBoardView.swift` 679 · `BlockDecor.swift`
  654 · `EditorView.swift` 581 · `CanvasView.swift` 553 ·
  `StructuralGesturePlanner.swift` 478 · `LibraryCatalogView.swift` 475 ·
  `LensesBoardView.swift` 432 · `EditorCommands.swift` 415.
- **31 `@Observable` classes** (one per feature VM, plus routers/theme; two
  files hold two each: `TagsViewModel.swift:18,97`,
  `BookViewModel.swift:18,106`).
- **4 custom NotificationCenter names**, 12 distinct post sites, 8 observer
  sites (full inventory §6). Additionally 7 system-notification observer
  installations (§6.3).
- **Tests:** 46 test files, ~431 `@Test` cases (matches the recorded Mac
  baseline 431/81). Distribution is extremely uneven — the Editor core owns
  roughly **240** of them; the Takes/Lenses surface (≈2,900 lines of board +
  VM code) owns roughly **25–40** (§7).
- **Three TK2 text-surface wrappers** (`EditorTextView`, `TakeTextView`,
  `ReadPostTextView`) + a fourth rendering path (plain SwiftUI `Text`) in
  Compare/Outline/Canvas/ReadingFlow (§5.4). `FallbackCanary` is ONE shared
  class (`Features/Editor/FallbackCanary.swift`), instantiated per surface.
- **Liveness spread measured precisely:** the four Takes-side moving parts
  (`liveBuffers` / `resolvedTake` / `deferredProjection` /
  `projectionCaughtUp`) have **23 references across 5 files** (18 in
  `TakesViewModel.swift`, 2 in `TakesShared.swift`, 1 each in
  `TakesBottomBar.swift:215`, `TakesBoardView.swift:607`,
  `WriteTakesPanel.swift:163`). The Editor side runs a parallel,
  differently-named system (§5.2) — batch 15's "~30 refs across 4 files, no
  single tested authority" diagnosis stands; the precise figures are these.

---

## 2. App-level composition

| File | Lines | Role |
|---|---|---|
| `Variorum/VariorumApp.swift` | 75 | WindowGroup, bootstrap, services start, helper window |
| `Variorum/RootView.swift` | 247 | Sidebar selection + detail switch; the shell's notification receiver |
| `Variorum/EditorCommands.swift` | 415 | The whole menu bar (structural, takes family, modes ⌘1–⌘7, seams, callouts) |
| `Variorum/VariorumAppDelegate.swift` | 70 | Window-frame sanitizer (b6dae25 follow-on); quit-time finalize |
| `Variorum/ShellRouter.swift` | 22 | `pendingSelection` + `paletteRequested` (parent-composition channel) |
| `Variorum/EditorRouter.swift` | 20 | `weak var active: EditorViewModel?` + scroll anchors |
| `Variorum/StoreFailureView.swift` | 42 | Store-open failure face |

Facts:

- **RootView holds 14 `@State`s** (grep) including `postMode`, which is
  derived from the `.variorumModeDidChange` broadcast
  (`RootView.swift:114-116`) — the sidebar mode rail's `›` marker is
  broadcast-derived UI state (P-4's exact subject).
- **`EditorCommands` reaches the focused editor via
  `session.editorRouter.active`** (e.g. `EditorCommands.swift:198-202`) —
  the sanctioned parent-composition route — and posts two notification
  channels: ⌘1–⌘7 posts `.variorumSwitchMode` with NO postID
  (`EditorCommands.swift:213-221`, "the visible detail responds") and ten
  menu items post `.variorumTakesCommand` via `TakesCommand.post`
  (`EditorCommands.swift:128-161`).
- **`toggleSeams` is a read-then-write across two separate transactions**
  (`EditorCommands.swift:239-250`: `database.read` the current value, then
  `runner.run` the negation) — a small last-writer race, not one
  transaction.
- **Quit door** (`VariorumAppDelegate.swift:53-69`): awaits
  `editorRouter.active?.finalizeWork()` PLUS the `quitFinalize` registry
  (`Shared/AppSession.swift:56`) — registrants today: every
  `TakesViewModel` (`TakesViewModel.swift:54`) and the block-TOC's own
  autosave (`BlockTOCView.swift:39`). The Editor VM is NOT a registrant; it
  is reached through the router. Two mechanisms for one concern.
- **Window sanitizer** (`VariorumAppDelegate.swift:35-51`) clamps oversized
  frames at launch/activation — the b6dae25 class's belt.

## 3. Theme/

| File | Lines | Notes |
|---|---|---|
| `Theme/VoiceTokens.swift` | 269 | Token resolution, both voices |
| `Theme/VoiceControls.swift` | 163 | THE chrome vocabulary (R101); `ChromeNotice` with load-bearing lineLimit (`VoiceControls.swift:143-160`) |
| `Theme/EditorTypography.swift` | 146 | `EditorTypography.current` — a **mutable global** (see below) |
| `Theme/ThemeStore.swift` | 100 | `@Observable`, observes `Queries.themeSettings`, setters via runner (`ThemeStore.swift:19-50`) |

- **`EditorTypography.current` is written from RootView** on settings change
  (`RootView.swift:125-129`: "both writers set the same resolved value") and
  read by every surface write (`EditorDocument.swift:37,50`). It is the one
  global mutable in the frontend — deliberate (one typography), but it means
  surface font correctness depends on RootView's `.onChange` having run.
- Views consistently take `ThemeStore` from the environment with a fallback
  for test hosts (e.g. `TakesBoardView.swift:44-46`) — a repeated
  `themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)` idiom in ~12
  files (grep), boilerplate but consistent.

## 4. Feature modules (evidence per module)

Test counts are `@Test` occurrences in the named files (`VariorumTests/`).
"Sediment" = grep count of `R\d\d`/`batch`/`Sitting 9`/`2026-07` tags (a
tag-occurrence proxy, not comment-line count).

### 4.1 Features/Editor/ — 21 files, ~7,000 lines (special dossier §5)

Files: `EditorViewModel.swift` 2994 · `BlockDecor.swift` 654 ·
`EditorView.swift` 581 · `StructuralGesturePlanner.swift` 478 ·
`StructuralSeamEdit.swift` 265 · `EditorTextView.swift` 254 ·
`WriteTakesPanel.swift` 247 · `CommentsPanel.swift` 247 · `CommitBar.swift`
237 · `BlockRangeIndex.swift` 235 · `CrystallizationPlanner.swift` 216 ·
`DivideWSheet.swift` 132 · `JumpPrimitive.swift` 109 · `EditorDocument.swift`
99 · `CutPropagation.swift` 79 · `FallbackCanary.swift` 69 · `BlockTint.swift`
53 · `RefusalCopy.swift` 40 · `TextMetrics.swift` 21.

- **Tests: ~243** across 16 files (StructuralGesturePlannerTests 53,
  StructuralGestureTests 43, EditorSessionTests 36, BlockRangeIndexTests 19,
  CrystallizationTests 17, StructuralSeamEditTests 17, BoundaryFluidityTests
  14, EditorDocumentTests 10, JumpAndUndoTests 8, CutPropagationTests 8,
  FocusHandoffTests 6, EditorWindowSmokeTests 3, TintRegistration 3,
  BlockTintAndMetrics 3, InlineEditorWindow 2, GestureSoak 1). By far the
  best-covered frontend module.
- Sediment: `EditorViewModel` 31 tags; `EditorCommands` 13;
  `WriteTakesPanel`/`CommitBar` 5-7 each.
- **`EditorViewModel` is 2,994 lines and is the frontend's god object by
  size**: projection adoption + echo detection (`:439-541`), differential
  render (`:554-574`), edit routing (`:633-768`), crystallization + idle
  mint (`:770-971`), the whole Phase 9 gesture surface + W ceremony
  (`:973-2162`), cross-block compounds (`:1178-1656`), commit/fan/history
  (`:2326-2434`), caret take shortcuts (`:2436-2568`), badges + decoration
  geometry (`:2570-2757`), comments/callouts/reorder (`:2759-2837`), surface
  plumbing (`:2839-end`). Ten-plus concerns in one class (P-9's larger
  sibling to the named `TakesViewModel` counterexample).
- `WriteTakesPanel` (an Editor-feature file) **instantiates the Takes
  feature's view model** (`WriteTakesPanel.swift:39`) — see §5.5 and §8.1.

### 4.2 Features/Takes/ — 11 files, ~3,600 lines

Files: `TakesViewModel.swift` 890 · `TakesBoardView.swift` 679 ·
`LensesBoardView.swift` 432 · `AlignedPostsView.swift` 409 ·
`TakesBottomBar.swift` 268 · `PostDetailView.swift` 258 · `TakesShared.swift`
228 · `TakePaneView.swift` 213 · `TakesModels.swift` 193 · `DiffView.swift`
151 · `TakesCommands.swift` 40.

- **Tests: ~25–40** (TakesBoardTests 16, TakesArticleRenderTests 3,
  TakePaneMeasureTests 1, DiffViewTests 5, plus Takes-relevant parts of
  Phase13SurfaceTests 14). Against ~3,600 lines, this is the thinnest
  coverage-to-complexity ratio of any interaction-heavy module.
- Sediment: `TakesBoardView` **35 tags (the highest in the app)**,
  `TakesViewModel` 27, `PostDetailView` 13, `LensesBoardView` 9,
  `TakesBottomBar` 6.
- **`TakesViewModel` (890 lines) mixes at least five concerns**: column/
  view-memory management (`:296-386`), the liveness authority
  (`liveBuffers`/`resolvedTake`/`adopt`, `:145-294`), ~30 operation-calling
  gesture methods (`:408-760`), the R73 keyboard dispatch incl. per-host
  branching (`:762-860`), and status/error copy (`:862-889`). It also OWNS
  an `AutosaveCoordinator` (`:30,36`) and a quit-registry token (`:54`). The
  P-9 named counterexample, confirmed in structure.
- **D3's lecture site**: `speakStructuralGesturesLiveInWrite`
  (`TakesViewModel.swift:740-743`) — the redirect copy for Divide in Takes.
  Make Block has NO Takes-side door at all (no reference to
  `makeBlockFromSelection` outside `Features/Editor/` — grep), matching the
  batch-15 finding that it is silent there.
- **PostDetailView is the de-facto mode-shell** (`PostDetailView.swift:107-136`
  switches all seven modes, each behind `.id(...)` so every mode switch
  destroys and rebuilds the surface + its VM). Mode availability logic lives
  in the view: the blockless→Write rule is an async raw-SQL count in
  `.task(id:)` (`PostDetailView.swift:160-175`) that can race a user's
  manual mode choice (the task fires on every postID change and
  unconditionally sets `mode = .write` if blocks == 0).
- **Raw SQL in views** (bypassing `Queries`): block count
  (`PostDetailView.swift:166-172`), title fetch
  (`PostDetailView.swift:228-229` — also non-observed: a rename elsewhere
  never updates the masthead title until postID changes), and an ad-hoc GRDB
  `Variant.filter` for archived takes (`WriteTakesPanel.swift:232-239`).
- **Duplicated margin-grid geometry constants**: `mastheadMeasure`
  (`PostDetailView.swift:70-75`) recomputes `680 + 16 + cols*220 +
  (cols-1)*6` reading `UserDefaults` key `takesGridCols` directly, while
  `TakesBoardView` computes the same numbers from `@AppStorage` of the same
  key (`TakesBoardView.swift:35-36,64-66,315-319`). Two files must agree by
  hand.
- **D2 mechanism candidates (traced, not fixed — evidence only):**
  1. The takes article centers `article + reserved rail` as ONE unit
     (`TakesBoardView.swift:306-307`: `.frame(maxWidth: articleMeasure)`
     inside `.frame(maxWidth: .infinity)`); with the rail added
     (`articleMeasure = 680 + 16 + railWidth`, `:315-319`) the centered unit
     widens, so the 680pt prose column lands `railWidth/2` LEFT of where it
     sits in every other style — "margin grid shifts the whole post left."
  2. `fanToggleRow` renders ABOVE EVERY block, fanned or not
     (`TakesBoardView.swift:326-327,341-342,364-379` — the unfanned "⑂ +"
     branch), adding a control row + spacing per block — a candidate for the
     "suspiciously large vertical gaps between blocks."
- **liveBuffers bypass in the stack style**: `CollapsibleTakeCard` renders
  `take.workingText` directly (`TakesBoardView.swift:672-674`), while every
  other card path goes through the live-buffer overlay (`takeMiniPane` →
  `liveText`, `:575,606-608`; `WriteTakesPanel.swift:163`;
  `TakesShared.swift:36`). Mechanism: while an edit is dirty (autosave
  debounce), a stack-style read card mirroring the edited variant shows
  stale store text — the exact frozen-article class batch 14 fixed
  elsewhere.
- `TakesCommands` (40 lines) is the R73 keyboard channel — clean, but its
  handling is re-implemented per surface with divergent semantics
  (`EditorView.swift:160-183`, `TakesBoardView.swift:142-187`,
  `LensesBoardView.swift:95-120+`, `CanvasView.swift:348-356`) — four
  hand-maintained switch statements over the same command enum.

### 4.3 Features/ReadTier/ — 2 files, 651 lines

`ReadPostViewModel.swift` 365 · `ReadPostView.swift` 286. Tests:
ReadTierTests 8.

- The cleanest of the three surface stacks: non-editable, differential
  apply with in-memory comparison and cost counters
  (`ReadPostViewModel.swift:193-218`), full-render heal on out-of-bounds
  (`:200-202`), dismantle-reset for SwiftUI recycling (`:108-121`),
  width-gated remeasure via `NSView.frameDidChangeNotification`
  (`ReadPostView.swift:163-169`).
- Carries its OWN copy of the height-measurement brain
  (`ReadPostViewModel.swift:235-245`) and its own badge/decor geometry walk
  (`:257-361`) — the third parallel implementation (§5.3, §5.4).
- Consumed by `BookView.swift:638` (read rows) — nothing else; the takes
  boards use `TakePaneView` instead.

### 4.4 Features/BookView/ — 5 files, 1,656 lines

`BookView.swift` 764 · `BookStructureModel.swift` 369 · `MembershipChip.swift`
256 · `ReadingFlowView.swift` 150 · `BookViewModel.swift` 117. Tests:
BookViewTests 7, BookStructureTests 10, part of ScrubAndOutlineTests 3.

- **19 `@State`s in BookView** (highest in the app), including one declared
  mid-file at `BookView.swift:541` (`expandedPosts`) — sediment shape.
- **D1 confirmed at the traced site**: `postRow` computes
  `expanded = expandedPosts.contains(entry.postID) || focus.focusedPostID ==
  entry.postID` (`BookView.swift:545-546`); the collapse button only does
  `expandedPosts.remove(...)` (`BookView.swift:603`), so a focused post's ▾
  silently no-ops (the disjunct keeps it expanded). Fix shape per the
  ledger: collapsing must also release focus.
- **`BookFocusState` is a third focus authority**
  (`BookViewModel.swift:106-117`: `focusedPostID`, `caretSeed`, `fanSeed`)
  beside `EditorRouter.active` and `TakesViewModel.focusedPane` (§5.5).
- The focused post embeds the real inline editor
  (`BookView.swift:631-636` → `EditorView(inline: true)`); unfocused posts
  are `ReadPostView` (`:638`).
- `MembershipChip` defines and posts `.variorumOpenPost`
  (`MembershipChip.swift:118-119,253-255`); BookView posts it from two more
  doors (`BookView.swift:578-579,617-618`).
- `ReadingFlowView` renders paragraphs as SwiftUI `Text`
  (`ReadingFlowView.swift:122`) inside a LazyVStack (the round-3
  virtualization fix) — a fourth text-rendering path (§5.4).
- `PostCardExcerpt` (`BookView.swift:656-661`) loads per-card excerpt/meta
  from the DB per realized row — bounded by laziness, but another
  view-local fetch pattern.

### 4.5 Features/Shelf/ — 3 files, 725 lines

`ShelfView.swift` 400 · `ShelfViewModel.swift` 212 · `QuickEntryBar.swift`
113. Tests: ShelfAndPaletteTests 10 (shared with the palette).

- `QuickEntryBar` is the R102/R109 shared quick-entry (dashed box, blinking
  cursor via an infinite 550 ms `Task.sleep` loop —
  `QuickEntryBar.swift:52-57`, cancellation-scoped by `.task`); its hint
  text carries the load-bearing lineLimit with the b6dae25 comment
  (`QuickEntryBar.swift:78-86`).
- `ShelfViewModel` reads through `Queries` (`ShelfViewModel.swift:64-65`).

### 4.6 Features/Library/ — 4 files, 1,057 lines

`LibraryCatalogView.swift` 475 · `RecoveryView.swift` 229 ·
`SidebarView.swift` 189 · `LibraryViewModel.swift` 164. Tests: parts of
LifecycleFacesTests 6, ShelfAndPalette, Phase13Surface.

- **SidebarView renders the post-mode rail from broadcast state** and posts
  targeted `.variorumSwitchMode` (`SidebarView.swift:120-127`); the current
  mode marker comes down from RootView's broadcast-derived `postMode`
  (`RootView.swift:114-116`) — mode truth lives in `PostDetailView`'s
  `@State`, its projection travels by notification (P-4 subject).
- `RecoveryView.swift:175` has a `.fixedSize()` (both-axis, short label —
  not the hazard class).

### 4.7 Features/Pool/ — 4 files, 619 lines

`PoolPostsView.swift` 196 · `BlocksAreaView.swift` 192 · `BlockTagViews.swift`
116 · `PoolSection.swift` 115. Tests: PoolDragTests 5, parts of
CanvasAndPoolTests 7.

- `PoolSection` uses the full `EditorTextView` editor for pool detail
  (`PoolSection.swift` — grep hit in the EditorTextView usage sweep).
- `BlocksAreaView` repeats the blinking-cursor loop
  (`BlocksAreaView.swift:137-143`) and carries the protected
  lineLimit+fixedSize hint (`:150-156`).
- Drag payload discipline is good: block-ID-only pasteboard type, the copy
  happens inside `poolDragCopy` (`EditorTextView.swift:49-64`).

### 4.8 Features/Canvas/ — 1 file, 553 lines

`CanvasView.swift`. Tests: parts of CanvasAndPoolTests 7. Sediment 16.

- Own `@Observable` VM in-file (`CanvasView.swift:37`); free-movement board
  with negative-coordinate normalization (`:358-360`).
- Cards render text as SwiftUI `Text` with `.textSelection`
  (`CanvasView.swift:391-403`) — not a TK2 surface (read-only by design).
- **b6dae25-class instance**: the status line is
  `.fixedSize(horizontal: false, vertical: true)` with NO lineLimit in the
  non-scrolling chrome above the board scroll
  (`CanvasView.swift:318-325`); its text comes from
  `TakesViewModel.message(for:)` (`:133-252` call sites) which can be
  arbitrarily long (`"Refused: \(error)"`). Same slot-shape as the batch-12
  Lenses wedge that `ChromeNotice` was built to close — Canvas didn't adopt
  `ChromeNotice`.
- Observes `.variorumTakesCommand` for its ‹ › switcher
  (`CanvasView.swift:348-356`).
- Uses `TakesViewModel.message(for:)` for error copy in 4 places
  (`CanvasView.swift:133,144,231,252`) — cross-feature reach (§8.1).

### 4.9 Features/Tags/ + Features/Folder/ — 3 files, 415 lines

`TagsViewModel.swift` 149 (two `@Observable`s) · `TagViews.swift` 142 ·
`FolderView.swift` 124. Tests: TagAndFolderTests 6. All reads through
`Queries` (`TagsViewModel.swift:115-116`, `FolderView.swift:41-42`).

### 4.10 Features/Readings/ + Features/Timeline/ — 3 files, 623 lines

`ReadingViews.swift` 325 · `ReadingsViewModel.swift` 151 ·
`TimelineView.swift` 147. Tests: TimelineAndReadingsTests 5. Reads through
`Queries` (`ReadingsViewModel.swift:102-103`, `TimelineView.swift:63-76`).
12 `@State`s in `ReadingViews.swift`.

### 4.11 Features/TOC/ — 1 file, 331 lines

`BlockTOCView.swift`. Tests: BlockTOCTests 5.

- Has its OWN `AutosaveCoordinator` + quit-registry token
  (`BlockTOCView.swift:39,48`) for its one expanded live row — a fourth
  autosave-owning surface (§5.5).
- Uses `TakePaneView` (`BlockTOCView.swift:292`) in the pre-13 look (nil
  tokens — `TakePaneView.swift:21-24` documents the compatibility branch).
- Borrows `TakesViewModel.message(for:)` (`BlockTOCView.swift:35,173`).

### 4.12 Features/Tutorial/ — 1 file, 363 lines

`ModesTutorialView.swift`. Tests: ModesTutorialTests 3. Uses `TakePaneView`
(`:260`), raw `Queries` reads (`:59-60,109-110,174-175`), and
`TakesViewModel.message(for:)` in 4 places (`:104,165,184,198`). This is the
seed R113's tutorial spine would grow from; today it is a static seeded demo.

### 4.13 Features/CommandPalette/ · Settings/ · Help/ · References/ · Export/ · Import/

- `CommandPalette.swift` 205 (tests: ShelfAndPaletteTests part) — searches
  via `Queries.searchCatalog` (`:74-75`), executes via `ShellRouter`.
- `AppSettingsView.swift` 256 — 11 `@State`s; tag manager's home; settings
  writes via runner.
- `HelperView.swift` 209 — all `fixedSize` texts are INSIDE ScrollViews
  (`HelperView.swift:88-100,175-195`) — not the hazard class.
- `ReferencePanel.swift` 252 + `ReferencesViewModel.swift` 297 (tests:
  ReferencePanelTests 9) — PDFKit page observer with deinit-based removal
  (`ReferencePanel.swift:201-221`, `nonisolated(unsafe)` token); claims
  lifecycle-managed per the 11b review fixes.
- `ExportModel.swift` 181 + `PDFExporter.swift` 71 + `ImportModel.swift` 271
  (tests: ExportFacesTests 6, ImportFacesTests 6) — `Task.detached` for file
  I/O (`ExportModel.swift:105`, `ImportModel.swift:59`); projections via
  `Queries.bulkExportManifest`.
- `OutlineDraftView.swift` 300 (tests in ScrubAndOutlineTests) — renders
  slot text as SwiftUI `Text` (`:266,292`), own `@Observable` (`:30`).

---

## 5. SPECIAL DOSSIER — the live editor core and its seams

### 5.1 The pipeline (Write mode, detail editor)

One directed loop, all in `Features/Editor/`:

```
keystroke → EditorSurfaceDelegate (EditorView.swift:390-433)
  → EditorViewModel.shouldChangeText (EditorViewModel.swift:633-688)
      · BlockRangeIndex.verdict — block / tail / refuse / cross-block
      · cross-block → planCrossBlockEdit / planVisibleTakeEdit compounds (:662-668)
  → storage applies → storageDidEdit (:693-723)
      · index shift + blockID attribute + recordAutosave (:737-752)
      · tail edits → crystallizeIfNeeded + armTailIdleMint (:706-707)
  → AutosaveCoordinator.record (Shared/AutosaveCoordinator.swift:63-69)
      · 500 ms debounce → flushNow → ops.autosave per variant (:95-127)
      · KEEP-PENDING: a refused entry goes back into `pending` (:112-121);
        isDirty stays true → projections stay deferred
  → observation → applyProjection (EditorViewModel.swift:439-480)
      · not loaded → renderFull · dirty/mint/structural → pendingProjection
      · surfaceMatches (echo, zero surface reads, :494-513) → adopt only
      · same block sequence → applyDifferential (:554-574; undo stack dropped on edit, :567-571)
      · else renderFull (:576-607)
  → onSettled → applyPendingIfClean (:609-629)
      · RE-FETCHES fresh before applying (the round-1 MAJOR-2 fix)
```

Crystallization: planner is pure (`CrystallizationPlanner.swift:25-30`),
mints run off-main through the runner, `finishMint` reconciles against the
current tail (`EditorViewModel.swift:891-971`); idle mint = 2 s
(`EditorViewModel.swift:236-240`); teardown/quit backstop =
`finalizeWork` (`:341-397`) — flush → await mint → mint residual tail →
**flush again inside the awaited task** (the quit belt, `:389-393`).

### 5.2 The liveness moving parts — who reads/writes what

**Takes side (the four named parts):**

| Part | Home | Writers | Readers |
|---|---|---|---|
| `liveBuffers` | `TakesViewModel.swift:158` (OBSERVED — the batch-14 frozen-article fix, `:150-157`) | `paneEdited` (`:275`), `projectionCaughtUp` (`:293`) | `resolvedTake` (`:237,240`), `TakesShared.swift:55` (empty-take note), `TakesBoardView.swift:606-608` (`liveText`), `WriteTakesPanel.swift:163` |
| `resolvedTake` | `TakesViewModel.swift:225-241` | — (pure fall-through: pick → live-active take → chosen → gap) | `TakesShared.swift:36` (every cell), `TakesBottomBar.swift:215`, `TakesViewModel.swift:844,856` (stepPick/pickPosition), `rowTexts` (`:244-246`) |
| `deferredProjection` | `TakesViewModel.swift:147` (`@ObservationIgnored`) | observation loop while dirty (`:166`), cleared at settle (`:48-50`) | `onSettled` closure only |
| `projectionCaughtUp` | `TakesViewModel.swift:292-294` | called from `adopt` for every variant with no pending autosave (`:192-194`) | — (the convergence half; the round-2 MAJOR fix) |

**Editor side (the same problem, different names — the duplication P-3 names):**

| Editor part | Location | Role (Takes analog) |
|---|---|---|
| `pendingProjection` | `EditorViewModel.swift:191,458-461` | `deferredProjection` |
| `applyPendingIfClean` + re-fetch | `:609-629` | `onSettled` adopt (but with a fresh re-fetch the Takes side doesn't do) |
| `surfaceTextByVariant` | `:211,518-541,747` | `liveBuffers`' echo-detection half |
| `autosave.isDirty` gating | `:458` | same coordinator class, second instance |
| `forceFullRender` / `loaded` / `suppressEditProcessing` | `:187-193` | no analog (view-owned surface) |
| `mintInFlight` / `structuralInFlight` | `:188,200` | no analog |

**View-level third half:** `TakePaneView.updateNSView`'s
`if !isLive, view.string != text` guard (`TakePaneView.swift:102-108`) — a
pane-local restatement of buffer-vs-projection authority that must agree
with `TakesViewModel`'s dictionary for correctness.

**Fourth autosave owner:** `BlockTOCView.swift:39` (its own coordinator for
the expanded row).

No single tested authority answers "what text does this pane show, and is
it live" — the answer is distributed across `TakesViewModel.resolvedTake`,
`liveBuffers`, `TakePaneView`'s guard, and (in Write) the wholly separate
`EditorViewModel` system. This is the measured baseline P-3 targets.

### 5.3 Height measurement — three private copies of one brain

Identical formula (`ensureLayout(documentRange)` +
`usageBoundsForTextContainer.height` + `inset*2`), three implementations,
three different re-measure triggers:

| Surface | Implementation | Width/re-measure trigger |
|---|---|---|
| Take panes | `TakePaneView.swift:161-167` | `TakeTextView.layout()` width hook (`:176-185`, the batch-12 clipped-take fix) + per-keystroke (`:155-159`) |
| Read tier | `ReadPostViewModel.swift:235-245` | `NSView.frameDidChangeNotification` (`ReadPostView.swift:163-169`) + differential-apply edits (`:217`) |
| Inline editor | `EditorView.swift:354-360` | `NSTextStorage.didProcessEditingNotification` + `DispatchQueue.main.async` hop (`:339-350`) + every `updateNSView` (`:300`) |

Notes: the take-pane and inline variants run `ensureLayout` over the WHOLE
document per keystroke of their surface (bounded by pane/post size — fine at
take scale, `∝ post` for the inline editor; the review measured and accepted
it, comment `EditorView.swift:270-272`). Three copies means the batch-12
class of bug (measure-before-width) had to be fixed in one place and could
still exist in another; the fix landed only in `TakePaneView`
(width-gating); `ReadPostViewModel` uses a different mechanism
(frame-notification), and the inline editor a third (storage-edit +
update-pass).

### 5.4 The wrapper inventory (duplication P-3 must reconcile)

| | `EditorTextView` | `TakeTextView` | `ReadPostTextView` | SwiftUI `Text` path |
|---|---|---|---|---|
| File | `EditorTextView.swift:15-231` | `TakePaneView.swift:171-213` | `ReadPostView.swift:191-226` | Compare `AlignedPostsView.swift:365`, Outline `OutlineDraftView.swift:266,292`, Canvas `CanvasView.swift:391-403`, ReadingFlow `ReadingFlowView.swift:122` |
| TK2 opt-in + precondition | yes (`:147-148,202-203`) | yes (`:197-198`) | yes (`:208-209`) | n/a |
| Editable | yes (live) | toggled per `isLive` | never | never |
| Buffer authority | model-side (EVM) | view guard (`TakePaneView.swift:105-108`) | n/a | n/a |
| Height | own scroll (detail) / inline remeasure | coordinator remeasure | VM remeasure | SwiftUI |
| Canary | armed, surfaced via `EditorViewModel.canaryMessage` → banner (`EditorView.swift:63-70`) | armed, **message swallowed** — `Coordinator.canaryMessage` is a private var never rendered (`TakePaneView.swift:131-132,145`) | armed, surfaced (`ReadPostView.swift:57-64`) | none |
| Plain-click→focus | n/a (is the live editor) | `mouseDown` selection-length-0 (`TakePaneView.swift:187-191`) | same idiom (`ReadPostView.swift:197-202`) | n/a |
| Typography source | `EditorDocument.baseAttributes` | same (incl. live re-font pass `TakePaneView.swift:89-101`) | same | SwiftUI fonts — does NOT share the paragraph-gap/typography brain |

The shared pieces that already exist (the consolidation would build on
them): `EditorDocument.materialize` + `baseAttributes` (one rendering brain
for Editor + ReadTier — `EditorDocument.swift:57-89`), ONE `FallbackCanary`
class, ONE `BlockDecorOverlayController` used by both live and read tiers
(`EditorView.swift:237`, `ReadPostView.swift:157-162`), `BlockTint.viewRect`
as the container→view geometry mapping (`ReadPostViewModel.swift:340`).
`TakePaneView` does NOT use `EditorDocument.materialize` (plain
`view.string = text`, `TakePaneView.swift:75,106`) — takes render without
the block-ID attribute machinery (single-block panes; consistent but a
divergence to know about).

### 5.5 Seams with Takes / Lenses / ReadTier / Book

- **Write ↔ WriteTakesPanel (the sharpest seam):** the panel (a sheet over
  Write, `EditorView.swift:96-101`) creates a FULL `TakesViewModel`
  (`WriteTakesPanel.swift:39`) with its own `AutosaveCoordinator` while the
  underlying `EditorViewModel`'s coordinator is also alive on the same post.
  Two debounced buffer authorities can hold pending text for the SAME
  variant simultaneously (panel edits the chosen take that the Write
  surface also displays). Convergence rides the observation loop + each
  side's echo/defer logic; nothing coordinates them directly. Flush
  ordering between the two coordinators is unmanaged (each flushes on its
  own debounce/teardown).
- **Mode switches destroy everything:** `PostDetailView.swift:107-136` gives
  every mode an `.id(...)`, so Write→Takes tears down `EditorViewModel`
  (`EditorView.swift:95` `onDisappear` → `teardown()` → `finalizeWork`) and
  builds a fresh `TakesViewModel`, and vice versa. Pending text safety
  across the switch rides `finalizeWork`'s strong-self task
  (`EditorViewModel.swift:341-397`) and `TakesViewModel.teardown`'s
  fire-and-forget flush (`TakesViewModel.swift:211-217`). The Takes-side
  teardown flush is NOT awaited by anything at mode-switch time (only at
  quit, via the registry).
- **Focus authorities, three of them:** `EditorRouter.active`
  (`EditorRouter.swift:16`, written in `attach`/`teardown` —
  `EditorViewModel.swift:258,325-327`), `TakesViewModel.focusedPane`
  (`TakesViewModel.swift:70,250-264`), `BookFocusState.focusedPostID`
  (`BookViewModel.swift:106-117`). The batch-14 two-live-rings defect was a
  pane-key namespace collision inside just ONE of these
  (`TakesBoardView.swift:55-61` — the `takes-fan` namespace fix); nothing
  structurally prevents the next collision because "exactly one live pane"
  is enforced by key-equality convention per surface, not by an authority.
- **`TakesViewModel.focus()` ordering caveat:** the doc comment says "the
  leaving pane's text lands before the arriving pane goes live"
  (`TakesViewModel.swift:252-253`) but the code sets `focusedPane = pane`
  FIRST and then fires an unawaited `Task { flushNow() }` (`:254-258`) —
  safety actually rides on `liveBuffers` + the `!isLive` adopt guard, not on
  the stated ordering.
- **ReadTier → Editor handoff:** read-tier plain click / badge tap seed the
  editor's caret/fan (`ReadPostView.swift:24-27` →
  `EditorViewModel.pendingCaretSeed/pendingFanSeed` `:228-229`, applied at
  first render `:449`); BookView routes them through `BookFocusState`
  (`BookView.swift:633-641`). The offset transfers because both tiers render
  the same materialization (`ReadPostViewModel.swift:8-10`).
- **Cross-feature type reach:** `PostDetailView.jump(to:)` builds a
  `BlockRangeIndex` inside a DB read closure
  (`PostDetailView.swift:245-256`) — an Editor-feature type used by the
  Takes feature to compute a caret offset (duplicating the editor's own
  offset logic path).

### 5.6 The keep-pending flush path's blast radius

`AutosaveCoordinator.flushNow`'s refusal posture (re-queue + `isDirty`
stays true, `Shared/AutosaveCoordinator.swift:83-121`) is load-bearing in
FOUR places: `EditorViewModel.applyProjection`'s defer (`:458`),
`TakesViewModel.start`'s defer (`:165-167`) + `adopt`'s catch-up rule
(`:192-194`), the quit door (`VariorumAppDelegate.swift:58-66` +
`quitFinalize` registrants), and the mode-switch teardowns (§5.5). A future
P-3 consolidation inherits all four call patterns; the pins that exist
today: EditorSessionTests (36), AutosaveCoordinatorTests (6),
TakesArticleRenderTests (3 — the frozen-article board pins),
TakePaneMeasureTests (1), FocusHandoffTests (6).

---

## 6. The app-wide notification inventory

### 6.1 Custom names (name → definition · posters · observers)

**`.variorumSwitchMode`** — defined `Features/Editor/WriteTakesPanel.swift:243-247`
(an Editor-feature file owns the app-wide mode-switch channel).
- Posters (6 sites): `EditorCommands.swift:217-221` (⌘1–⌘7, NO postID —
  "visible detail responds"); `WriteTakesPanel.swift:57-59` (Open Takes
  mode); `TakesBoardView.swift:290-292` (empty-post → Write);
  `TakesBottomBar.swift:79-81` (Open in Write);
  `LensesBoardView.swift:203-205` (an in-board redirect);
  `SidebarView.swift:124-126` (the mode rail, targeted with postID).
- Observer (1): `PostDetailView.swift:179-187` (postID-targeted filter).
- Consequence in evidence: when no `PostDetailView` is mounted (book view,
  library, shelf), every posted switch is silently dropped (no observer for
  the current surface).

**`.variorumTakesCommand`** — defined `Features/Takes/TakesCommands.swift:15-17`.
- Poster (1 funnel): `TakesCommand.post` (`TakesCommands.swift:31-35`),
  called from 10 menu items in `EditorCommands.swift:128-161`.
- Observers (4): `EditorView.swift:107-110`, `TakesBoardView.swift:124-127`,
  `LensesBoardView.swift:76-79`, `CanvasView.swift:348-356` — four
  hand-written switch statements re-mapping the same enum per surface
  (divergent semantics by design, hand-kept in sync). Multiple observers CAN
  be live at once (e.g. Write mode + WriteTakesPanel sheet: `EditorView`'s
  observer stays active under the sheet).

**`.variorumOpenPost`** — defined `Features/BookView/MembershipChip.swift:253-256`.
- Posters (3): `MembershipChip.swift:118-120` (Open the Copy),
  `BookView.swift:578-580` and `:617-619` (open ↗ doors).
- Observer (1): `RootView.swift:109-112` → `router.pendingSelection`.

**`.variorumModeDidChange`** — defined `Features/Takes/PostDetailView.swift:21-26`.
- Posters (2): `PostDetailView.swift:142-146` (`onChange`) and `:147-151`
  (`onAppear`).
- Observer (1): `RootView.swift:114-116` → `postMode` (drives the sidebar
  rail's `›` marker — business-adjacent UI state derived from a broadcast).

### 6.2 P-4-relevant facts (no verdicts)

Mode truth lives in `PostDetailView`'s `@State mode` (`:52`); its
persistence (`:176-178`), its broadcast (`:142-151`), the sidebar's marker
(`RootView:114-116` → `SidebarView:120-140`), and its mutation channel
(`.variorumSwitchMode`) are four separately-wired pieces around that one
`@State`. Notification name definitions live in whichever feature file
happened to need them first (mode-switch in Editor, mode-did-change in
Takes, open-post in BookView) — ownership by accident of history.

### 6.3 System-notification observers

- `NSApplication.didBecomeActiveNotification` → `triggerSync`
  (`VariorumApp.swift:46-48`).
- `NSTextStorage.didProcessEditingNotification` → inline height remeasure
  via `DispatchQueue.main.async` (`EditorView.swift:339-350`).
- `NSView.boundsDidChangeNotification` + `NSWindow.willStart/didEndLiveResize`
  → `ScrollAnchorController` content-anchored restore
  (`EditorView.swift:520-541`).
- `NSView.frameDidChangeNotification` → read-tier width remeasure
  (`ReadPostView.swift:163-169`).
- `NSTextView.will/didSwitchToNSLayoutManagerNotification` → the canary
  (`FallbackCanary.swift:33-45`; block-token leak note `:62-68`).
- `.PDFViewPageChanged` → reference view-state persistence
  (`ReferencePanel.swift:206-215`, deinit removal `:217-221`).

---

## 7. Test coverage map (module → files → ~count)

| Module | Test files | ~Tests |
|---|---|---|
| Editor core + gestures | 16 files (§4.1) | ~243 |
| Takes/Lenses/Compare/Diff | TakesBoardTests, TakesArticleRenderTests, TakePaneMeasureTests, DiffViewTests, parts of Phase13SurfaceTests | ~25–40 |
| ReadTier | ReadTierTests | 8 |
| BookView/structure | BookViewTests, BookStructureTests, part of ScrubAndOutlineTests | ~18 |
| Shelf/Palette | ShelfAndPaletteTests | 10 |
| Canvas/Pool | CanvasAndPoolTests, PoolDragTests | 12 |
| Tags/Folder/Lifecycle | TagAndFolderTests, LifecycleFacesTests | 12 |
| Timeline/Readings | TimelineAndReadingsTests | 5 |
| TOC | BlockTOCTests | 5 |
| Tutorial | ModesTutorialTests | 3 |
| References | ReferencePanelTests | 9 |
| Export/Import | ExportFacesTests, ImportFacesTests | 12 |
| Theme/chrome | ThemeTests, ChromeMinHeightTests | 7 |
| Shared services (autosave/auth/sync/bridge wiring) | Phase8ServicesTests, AutosaveCoordinatorTests, AuthSessionTests, Phase9b/9c wiring, EntitlementsTests | ~42 |

The asymmetry worth seeing plainly: the two surfaces the author lives in —
the Takes board and the mode shell — carry the app's HIGHEST sediment
density (TakesBoardView 35 tags, TakesViewModel 27, PostDetailView 13) and
its THINNEST test-per-line coverage; the Editor core is the inverse
(31 tags but ~243 tests including a randomized soak). Untested-by-test-file
entirely: `PostDetailView` mode logic, `LensesBoardView`'s command handling,
`SidebarView`'s rail, `RootView`'s broadcast wiring, `WriteTakesPanel`.

## 8. Hazard patterns (mechanism per instance)

### 8.1 Cross-feature coupling
- `TakesViewModel.message(for:)` is the de-facto app error-copy authority,
  reached from TOC (`BlockTOCView.swift:35,173`), Tutorial
  (`ModesTutorialView.swift:104,165,184,198`), Canvas
  (`CanvasView.swift:133,144,231,252`) — three features depend on a Takes
  static for refusal wording.
- `WriteTakesPanel` (Editor) owns a `TakesViewModel` (Takes)
  (`WriteTakesPanel.swift:23,39`).
- `PostDetailView` (Takes) uses `BlockRangeIndex` (Editor)
  (`PostDetailView.swift:252`).
- Notification names defined in one feature, posted/observed from four
  others (§6.1).

### 8.2 fixedSize in non-scrolling chrome (the b6dae25 class)
- **UNPROTECTED:** `CanvasView.swift:318-325` (status, unbounded text, above
  the board scroll — the class's live instance); `WriteTakesPanel.swift:75-81`
  (status, sheet chrome) and `:68-73` (the R84 note, long fixed string,
  sheet chrome) — sheet-scale, same mechanism.
- **Mitigated by width caps:** `MembershipChip.swift:96-111`
  (`.frame(maxWidth: 280)` popover).
- **Protected (load-bearing lineLimit, with comments):**
  `Theme/VoiceControls.swift:143-160` (`ChromeNotice`),
  `QuickEntryBar.swift:78-86`, `BlocksAreaView.swift:150-156`,
  `CommitBar.swift:118-127` (lineLimit 2), TakesBoard/Lenses statuses via
  `ChromeNotice` (`TakesBoardView.swift:85-89`, `LensesBoardView.swift:52-58`).
- **Safe context:** `HelperView.swift:97,182,190` (inside ScrollViews).
- P-8's rule ("chrome fixedSize always carries lineLimit") is enforced only
  by convention + `ChromeMinHeightTests` (3 probes); Canvas and
  WriteTakesPanel predate/escaped it.

### 8.3 Geometry
- Container→view mapping is centralized where the tint bug was fixed
  (`BlockTint.viewRect` — `ReadPostViewModel.swift:340`; badge overlays
  offset by `textContainerOrigin` — `ReadPostView.swift:269,286`,
  `EditorView.swift:458-475`).
- `CommentMarginNote` hangs at a hard-coded `.offset(x: -166)` outside its
  row's bounds (`TakesBoardView.swift:392-396`) — clipped/overlapped at
  narrow widths; magic constant.
- Margin-grid measure constants duplicated across files (§4.2) — the D2
  evidence.

### 8.4 Timers / async races
- `PostDetailView.swift:160-175`: async block-count can override a user's
  mode choice after mount (raw-SQL `.task` racing `@State mode`).
- `TakesViewModel.focus()` ordering vs. its own comment (§5.5).
- `TakesViewModel.teardown` flush is fire-and-forget
  (`TakesViewModel.swift:216`) — at mode switch nothing awaits it (quit
  path is covered by the registry; the mode-switch path rides the runner's
  serialization).
- `EditorViewModel.showTransientStatus` 6 s clear task
  (`EditorViewModel.swift:2220-2228`) — guarded by message equality; benign.
- Blinking-cursor infinite loops, cancellation-scoped
  (`QuickEntryBar.swift:52-57`, `BlocksAreaView.swift:137-143`) — benign.
- Inline remeasure hops `DispatchQueue.main.async` out of
  `didProcessEditing` (`EditorView.swift:343-349`) — necessary (edit
  transaction), but it makes inline height correctness event-order-dependent.
- Documented accepted residual: one-cycle flicker on a stale pre-flush
  emission racing settle (`TakesViewModel.swift:188-191`).

### 8.5 Frontend misuse of the substrate (reads outside `Queries`)
- Raw SQL in views: `PostDetailView.swift:166-172` (COUNT), `:228-229`
  (title — also non-observed).
- Ad-hoc GRDB record query: `WriteTakesPanel.swift:232-239` (archived
  variants by raw columns — the Editor VM's equivalent goes through
  `Queries.blockFan`, `EditorViewModel.swift:1387` etc.).
- Read-then-write across transactions: `EditorCommands.swift:239-250`
  (seams toggle).
- Everything else sweeps clean: ~40 `database.read` closures all call
  `Queries.*` (grep, §4 per-module notes).

### 8.6 Availability logic as per-view if-statements (P-1's baseline)
- Gesture availability: the ONE planner brain exists for Write
  (`EditorViewModel.swift:2195-2218` + `StructuralGesturePlanner`), but
  Takes/Lenses/Canvas surfaces hand-roll their own availability and
  redirect copy per command handler (§6.1 observers;
  `TakesViewModel.swift:740-743`), and mode availability (blockless→Write)
  is a view-local rule (`PostDetailView.swift:160-175`). There is no
  registry; D3/D4's mechanism is exactly this distribution.

---

## 9. Top structural risks (concretely evidenced; mechanism in one sentence)

1. **No single pane-text/liveness authority** — the buffer-vs-projection
   decision is implemented three-and-a-half times (`EditorViewModel`
   `:439-541,609-629`; `TakesViewModel` `:145-294`; `TakePaneView:102-108`;
   `BlockTOCView:39`), so every new surface re-derives it and each fix
   (frozen article, two rings, clipped takes) lands in one copy while the
   others stay exposed.
2. **The stack-style liveBuffers bypass** — `TakesBoardView.swift:672-674`
   feeds `CollapsibleTakeCard` raw `take.workingText` instead of the
   live-buffer overlay every sibling path uses, so a dirty edit shows stale
   text in stack-bloom read cards: the batch-14 frozen-article class,
   still live in one style.
3. **Two concurrent autosave authorities on one post** — WriteTakesPanel's
   own `TakesViewModel`+coordinator (`WriteTakesPanel.swift:39`) runs beside
   the live `EditorViewModel`'s coordinator (`EditorViewModel.swift:37`)
   with no coordination of flush order for the same variants; convergence
   rides two independent defer/echo systems agreeing by luck of timing.
4. **Interaction gating is distributed if-statements, not data** — four
   hand-kept `TakesCommand` switch handlers (`EditorView:160-183`,
   `TakesBoardView:142-187`, `LensesBoardView:95+`, `CanvasView:348-356`),
   view-local mode rules (`PostDetailView:160-175`), and Write-only
   structural doors (`TakesViewModel:740-743`; no Make Block door outside
   `Features/Editor/`) are exactly the D3/D4 mechanism: a door's existence
   depends on which file someone remembered to edit.
5. **Mode state travels by broadcast with silent-drop semantics** — mode
   truth is one view's `@State` (`PostDetailView.swift:52`), mutations
   arrive via `.variorumSwitchMode` with a single conditional observer
   (`:179-187`), so any switch posted while no detail is mounted (book,
   shelf, library) vanishes without feedback, and the sidebar's marker is a
   broadcast-derived shadow (`RootView.swift:114-116`).
6. **`EditorViewModel` at 2,994 lines is the god object P-9 bans** — ten
   concerns share one class and one mutable neighborhood (index, slots,
   flags at `:177-240`), so every structural-gesture change risks the
   autosave/crystallization state machine and vice versa; its ~243 tests
   are also the main thing making it safe to touch.
7. **Coverage is inverted relative to churn** — the highest-sediment,
   most-patched surfaces (TakesBoardView 35 tags/679 lines,
   TakesViewModel 27/890, PostDetailView, SidebarView, WriteTakesPanel)
   have ~25–40 tests total and PostDetailView/WriteTakesPanel none, so the
   layer where the author finds "a million first class obvious bugs" is the
   layer with the least regression netting.
8. **Three private height-measurement brains with three different
   re-measure triggers** (`TakePaneView:161-185`,
   `ReadPostViewModel:235-252`, `EditorView:339-360`) — the batch-12
   clipped-take bug was fixed by width-gating only one of them; the other
   two rely on different events firing, and a missed event in either
   reproduces the same visible class.
9. **D1's focus/expand entanglement** — `BookView.swift:545-546`'s
   force-expand disjunct plus a collapse button that only edits
   `expandedPosts` (`:603`) makes collapse a silent no-op on the focused
   post; the deeper mechanism is a third independent focus authority
   (`BookFocusState`, `BookViewModel.swift:106-117`) that nothing
   reconciles with pane focus or the editor router.
10. **The b6dae25 class is convention-guarded, not structurally closed** —
    unprotected `fixedSize` status texts remain in non-scrolling chrome
    (`CanvasView.swift:318-325`; `WriteTakesPanel.swift:68-81`), and the
    canary that would surface a TK1 fallback in take panes is captured into
    a never-read private var (`TakePaneView.swift:131-132,145`) — two known
    failure classes with their alarms wired to nothing in specific spots.

---

*End of dossier. Verdicts, keep/consolidate/rebuild calls, and the ranked
backlog belong to the architect's synthesis in
`phase-13b-make-it-work.md` (Stage 0 findings).*
