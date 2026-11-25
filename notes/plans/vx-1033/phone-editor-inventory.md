# Phone Write editor — inventory of what exists (for the new-core plan)

Read-only survey of `main` at `99db9ee33` (2026-11-22). Paths are repo-relative. `VM` = `App/Variorum/VariorumMobile/Features/Write/MobileEditorViewModel.swift`; `TV` = `…/Write/MobileEditorTextView.swift`; `MS` = `…/Write/MobileStructural.swift`; `EB/` = `App/Variorum/Shared/EditorBrain/`; `Ops/` = `Sources/VariorumCore/Operations/`. Signatures are quoted from source. Where something was not verified it says so.

---

## 0. Orientation facts that matter for the new design (all verified)

| Fact | Where |
|---|---|
| The phone's Return key does **not** consult `TypedReturn`. `TypedReturn.act` has Mac callers only (`Variorum/Features/Editor/EditorViewModel.swift:1736–1783`, `EditorSurfaceController.swift:1050`). On the phone, ⏎ goes `TV.insertText` override (`TV:1014`) → `MobileMarkdownActs.handleReturnKey` (list doors) → `super.insertText("\n")` → the gate. Inside any block (including at a middle block's end) the verdict is `.block(i)`, so ⏎ inserts an in-block newline (I4 content). At the exact document end with no tail it is `.openTail` (unless `oneBlock`); in the tail it is `.tail` (type-time crystallization). | `TV:1014`, `MobileMarkdownActs.swift:160`, `EB/BlockRangeIndex.swift:168` |
| The phone declares **no seam carves**: backspace at a block's start (deleting the separator) is refused and spoken (`CrossBlockRefusal.Cause.seamKeystrokeDeclined` / `.seamBesideFan` / …), including when the block is empty. Ticketed as VM-143 ("Backspace joins two blocks and removes an empty one, as on the Mac"); Return-as-block is VM-140; the per-note chip is VM-141. | `EB/EditorEditRoute.swift:170`, `EB/CrossBlockRefusal.swift:200–224` |
| No phone soft-newline (⇧⏎). Doc: "the phone has no soft-newline ⇧⏎ story yet, so a hardware ⇧⏎ reaches this door like any ⏎". | `TV:1010–1013` |
| No segmentation chip on the phone; the editor reads `header?.effectiveSegmentation ?? .paragraph` (`Queries.ContainerHeader.effectiveSegmentation` = `container.segmentationDefault ?? setting ?? .paragraph`). | `VM:1966, 2433, 2781`; `Sources/VariorumCore/Queries/EditorSupport.swift:28,55` |
| The page IS re-rendered from the store while the keyboard is up: `EditorProjectionPolicy.decide`'s only "busy" input is `autosave.isDirty || mintInFlight`; nothing reads keyboard visibility. Every structural door, sheet close and undo ends in `refreshTakesFromStore()` → `ingest` → differential or full render. | `VM:1019–1072`, `EB/EditorProjectionEngine.swift:147` |
| No text-input traits are set on the editor (`autocorrectionType`, `spellCheckingType`, `smartQuotesType`, `inlinePredictionType`, `writingToolsBehavior`, `allowsEditingTextAttributes`, paste configuration, drag/drop: none set → system defaults). | grep over `Features/Write`, `Features/Takes` |
| A doc comment at `VM:170–174` says the flight fence is "read by the text view's two typed-input doors, the gate, and the storage report". The text view does **not** read it; only `shouldChangeText` (`VM:1957`) and `storageDidEdit` (`VM:2324`) do. | grep `flightFence` |
| `MobileQuickNote` (the capture box) is a SwiftUI `TextField`, not this editor; it uses its own `AutosaveCoordinator`. The only constructor of `MobileEditorViewModel` is `MobileWriteView.swift:154`. | `Features/Shell/MobileQuickNote.swift:40,303` |

---

## 1. Operations and queries

### 1.1 How the phone runs an operation

- `actor OperationsRunner` (`App/Variorum/Shared/OperationsRunner.swift`):
  `@discardableResult func run<T: Sendable>(_ body: @Sendable (Operations) throws -> T) throws -> T` — body is synchronous, so two bodies never interleave.
- One runner per session: `AppSession.init` builds `let undo = UndoStack(); let ops = Operations(undoStack: undo); self.runner = OperationsRunner(operations: ops)` (`Shared/AppSession.swift:936–941`). `session.undoStack` is that same stack.
- **Ordering guarantee:** only what Swift actors give. Calls awaited in sequence from ONE task run in that order. Calls from different tasks (the autosave's debounce `Task`, the crystallizer's mint `Task`, a door's `Task {}`) have no FIFO guarantee in the language. The code never relies on cross-task order; every structural door does `await model.flushPendingText()` (which awaits `autosave.flushNow()`), then `await session.runner.run { … }` in the same task. To get "autosave after structural op", a caller must await the op first and then record/flush (the compound in `CrossBlockCompound.apply` instead writes its own `ops.autosave` inside the same runner body).
- `AutosaveCoordinator.flushNow()` serializes its own batches (`writing` flag + continuation waiters), not against other runner users.
- **Door latch:** `MobileWriteLatch` (`Features/Shell/MobileWriteLatch.swift:50`) — `func run<T>(_ body: () async -> T) async -> T?` / `runIfFree`. The structural controller uses its own `structuralInFlight` Bool (`MS:75`) and the undo door its `inFlight` (`MobileUndoDoor`); both call `model.structuralFlightChanged()` on every edge.
- **IDs:** `Operations.newID() -> String { uuid().uuidString }` with `@Dependency(\.uuid)` (`Ops/Operations.swift:18,80`). **No listed operation accepts a caller-supplied ID for a new row.** Callers learn new IDs synchronously from the return value (table below).

### 1.2 Signatures (verbatim) and refusals

Common guards: `liveContainer` → `containerNotFound`; `ensureUnlocked`/`ensurePlacementUnlocked` → `lockedPost`; `liveVariant` → `variantNotFound`; `editableVariant` = live + `archivedVariant` + `lockedVariant` + placement seal (`Ops/Operations+Variant.swift:681`); `placedContext` = `blockNotFound`, `blockNotPlaced`, `containerNotFound`, `lockedPost`, `noRenderableVariant` (`Ops/Operations+Structural.swift:1200`); `ensureEditable` = `archivedVariant`, `lockedVariant` (`:1214`).

| Op | Signature | Returns (new IDs learned?) | Refusals | Undo |
|---|---|---|---|---|
| autosave | `public func autosave(_ variantID: String, text: String, charDelta: Int, expectedText: String? = nil) throws` (`Ops/Operations+Variant.swift:54`) | Void | editableVariant set | none. If `expectedText` given and row ≠ expected and ≠ text and block live → mints a `'conflict'` take (`insertConflictVariant`, new ID) in the same txn; her text keeps the row |
| newBlock | `public func newBlock(in containerID: String, text: String, at insert: InsertPosition = .end, registeringUndo: Bool = true) throws -> NewBlockResult` (`Ops/Operations+Block.swift:62`) | `NewBlockResult { block, variant, placement }` — yes | `containerNotFound`, `lockedPost` | "New Block" unless `registeringUndo: false` (crystallizer passes false). `InsertPosition` = `.start/.end/.after(blockID)/.before(blockID)` |
| divide | `public func divide(_ blockID: String, cut: Int, guardedBy guardian: WriteGuard? = nil) throws -> DivideResult` (`Structural:185`) | `DivideResult { block, variant, placement, edge }` = the NEW second half; source keeps identity as first half — yes | placedContext set, `fannedBlock` (>1 active), `archivedVariant`/`lockedVariant`, `invalidCut` (edge cut, non-grapheme, or a half empty after seam trim) | "Divide" |
| divideW | `public func divideW(_ blockID: String, cuts: [String: Int], displayedVariantID: String? = nil, guardedBy guardian: WriteGuard? = nil) throws -> DivideWResult` (`:333`) | `DivideWResult { first: FanHalf, second: FanHalf, markedSourceIDs, releasedPlacementID }`; `FanHalf { block, variants, sourceVariantIDs, placement, edge }` — yes | placedContext set, `noMarkedVariants`, `variantNotFound`, `archivedVariant`, `invalidCut`, `divideSideWouldBeEmpty` | "Divide choosing takes" |
| divideDuplicating | `public func divideDuplicating(_ blockID: String, displayedVariantID: String, cut: Int) throws -> DivideDuplicatingResult` (`:543`) | `{ first: FanHalf, second: FanHalf, releasedPlacementID }` | placedContext set, `variantNotFound`, `archivedVariant`, `invalidCut` | "Divide" |
| keep-on-top divide | NOT an op. `KeepOnTopDivide.compose(displayedID: String?, cut: Int, fan: [Variant]) -> Composition?` and `compose(keepBelow:cut:fan:)` (`Sources/VariorumCore/Domain/KeepOnTopDivide.swift`) → `Composition { cuts: [String: Int], displayedID, parking, unparkable: [String]; parked }`, handed to `divideW`. nil when displayed take not in the live active fan. Empty takes go to `unparkable`. | — | — | phone wraps it: `stack.withCompound(label: "Divide", …) { ops.divideW(…) }` (`MS:200–207`) |
| merge | `public func merge(_ firstBlockID: String, _ secondBlockID: String, joining: MergeJoinRule = .door, guardedBy guardian: WriteGuard? = nil) throws -> MergeResult` (`:850`) | `MergeResult { block, variant, placement, firstEdge, secondEdge, releasedFirstPlacementID, releasedSecondPlacementID }` — yes (fresh A′) | placedContext ×2, `blocksNotAdjacent` (seal via placedContext). Locked takes do NOT refuse (copies) | "Merge" |
| mergeCeremony | `public func mergeCeremony(_ firstBlockID: String, _ secondBlockID: String, pairings: [MergePairing], carries: [String], guardedBy guardian: WriteGuard? = nil) throws -> MergeCeremonyResult` (`:1019`); `MergePairing(firstVariantID:secondVariantID:join: MergeJoin)` | `{ block, variants, sources: [TakeSource], placement, firstEdge, secondEdge, released…IDs }` | placedContext ×2, `blocksNotAdjacent`, `mergedBlockWouldHaveNoTake`, `takePairedTwice`, `archivedVariant`, `variantNotFound` | "Merge Takes" |
| extract | `public func extract(_ blockID: String, span: Range<Int>) throws -> ExtractResult` (`:69`) — `span` is UTF-16 in the rendered take | `ExtractResult { block, variant, placement, edge }` — yes | placedContext set, ensureEditable, `spanNotExtractable` (middle span, blank, whole text, non-grapheme) | "Extract" |
| deleteBlock | `public func deleteBlock(_ id: String, requiring precondition: BlockDeletionPrecondition = .none, guardedBy guardian: WriteGuard? = nil) throws` (`Ops/Operations+Deletion.swift:241`). `enum BlockDeletionPrecondition { case none; case emptyWithNothingUnshown(variantID: String) }` | Void | `blockNotFound`, `lockedPost`; with `.emptyWithNothingUnshown`: editableVariant set, `variantNotFound` (wrong block), `bufferChangedSinceGesture` (buffer not empty), `blockCarriesUnshownText` (live variants ≠ 1 or live comments > 0) — all re-read inside the tombstone's txn | "Delete Block" with redo carrying the same precondition |
| restoreBlock | `public func restoreBlock(_ blockID: String, guardedBy guardian: WriteGuard? = nil) throws -> BlockRestoreLanding` (`Ops/Operations+Placement.swift:125`) | `BlockRestoreLanding` = `.itsOldPlace(home:)`, `.endOfNote(home:)`, `.unplaced(home:)` | `blockNotFound`, `blockNotDeleted`, … (not fully traced) | not checked |
| placeBlock | `public func placeBlock(_ blockID: String, in containerID: String, at insert: InsertPosition = .end) throws -> ContainerBlock` (`:46`) | the placement row | `blockAlreadyPlaced`, … | primitive undo (per AppSpec) |
| moveBlock | `public func moveBlock(_ blockID: String, to containerID: String, at insert: InsertPosition = .end, guardedBy guardian: WriteGuard? = nil) throws` (`:187`) | Void | `blockNotPlaced`, … | "Move Block" |
| reorder | `public func reorder(_ blockID: String, to insert: InsertPosition, guardedBy guardian: WriteGuard? = nil) throws` (`:231`) | Void | `blockNotPlaced`, … | "Reorder" |
| commit | `@discardableResult public func commit(_ variantID: String, kind: CommitKind = .manual, message: String? = nil, guardedBy guardian: WriteGuard? = nil) throws -> CommitPoint` (`Variant:95`) | CommitPoint | `variantNotFound`, `lockedPost`, `lockedVariant` | none |
| closeAutoCommit (whole note) | `@discardableResult public func closeAutoCommit(_ containerID: String) throws -> [CommitPoint]` (`:311`) | commits | none thrown for gone/sealed (answers `[]`); cadence gate `savesOnLeaving` | none |
| closeAutoCommit (listed takes) | `@discardableResult public func closeAutoCommit(_ containerID: String, takes variantIDs: [String]) throws -> [CommitPoint]` (`:346`) — the phone's form (VM-71); each take re-checked live/unlocked/placed/dirty in the txn | commits | as above | none |
| insureTakes | `@discardableResult public func insureTakes(_ variantIDs: [String]) throws -> [CommitPoint]` (`:422`) — skips missing/archived/locked/clean; NOT cadence-gated | commits | `lockedPost` | none |
| resolveSyncConflict | `public func resolveSyncConflict(_ variantID: String, losingText: String, label: String = "conflict") throws -> Variant` (`Ops/Operations+Sync.swift:25`) | the new take — yes | `variantNotFound`; dead block refuses (doc) | none |
| editTakesAtomically (used by the compound) | `public func editTakesAtomically(_ edits: [TakeEdit], undoLabel: String) throws -> Int` (`Ops/Operations+TakeEdits.swift:49`); `TakeEdit(variantID:newText:charDelta:expectedText:)` — CAS refuses whole batch with `bufferChangedSinceGesture` | count | not traced further | registers |
| chooseVariant | `public func chooseVariant(_ blockID: String, variantID: String) throws` (`Placement:11`) | Void | not traced | — |
| archiveBlock / unarchiveBlock | `public func archiveBlock(_ id: String) throws` / `public func unarchiveBlock(_ id: String) throws -> BlockUnarchiveLanding` (`Ops/Operations+BlockArchive.swift:49,100`) | — | not traced | "Archive Block" / registers |

**Structural undo registry** (`Ops/UndoStack.swift`, `public final class UndoStack`): public entry points `withCompound<T>(label: String, operations: Operations, _ body: () throws -> T) throws -> T` (`:311`, compounds do not nest — `precondition`), `undo(with:) throws -> String?` (`:421`), `undoReporting(with:) throws -> Outcome?` (`:431`), `redo(with:)`/`redoReporting(with:)` (`:458,467`), `pendingUndoWarning(with:) -> PendingUndoWarning?` (`:405`), `clearRedoFuture()`, `removeAll()`, `depth`, `topLabel`, `redoDepth`, `topRedoLabel`, `addWalkObserver`, `setChangeObserver`. Registration is internal: `func register(label:inverse:redo:insuring:)` (`:261`) via `Operations.registerStructuralEntry`. A new structural act clears the redo future.

**Join rules** (`Sources/VariorumCore/Domain/MergeJoin.swift`): `MergeJoin { space, newline, nothing }`; `MergeJoinRule.door.join(head:tail:)` → always `.newline` (the rendering join, R-13u4-3); `.deleteKeystroke` → `.space` unless either side is empty or the facing edge is whitespace, then `.nothing`.

**Divide's text arithmetic** (`BoundarySnapping.seamTrimmedHalves(_:cutAtUTF16:)`, Domain): whitespace at the seam is trimmed off both halves; k newlines at the seam store k−1 trailing newlines on the FIRST half (ruling A11). So a divide at "foo |bar" stores "foo" + "bar" (the space is dropped).

### 1.3 `Queries.takesProjection` and `Queries.RenderedBlock`

`public static func takesProjection(_ db: Database, post containerID: String) throws -> TakesProjection` (`Sources/VariorumCore/Queries/TakesQueries.swift:83`) — one read: `renderPost` slots + `activeFans` + lenses + selections + dangles + seal/profile/date + `unplacedOrigins` + `presentations`.

`TakesProjection` fields: `slots: [RenderedBlock]`, `fans: [String: [Variant]]` (live ACTIVE fan, fan order), `lenses: [Lens]`, `lensSelections: [String: [String: String]]`, `lensDangles: [String: [String: DanglingPick]]`, `fanStyle: FanStyle`, `sealed: Bool`, `profile: Profile?`, `entryDate: String?`, `unplacedOrigins: [String: [UnplacedOrigin]]`, `presentations: [String: BlockPresentation]`.

`RenderedBlock` (`Queries/PostRender.swift:19`): `blockID`, `placementID`, `position`, `variantID: String?` (nil ⇒ gap), `text: String?`, `activeVariantCount`, `liveVariantCount` (active+archived), `commentCount`, `variantLocked`; computed `isGap`, `hasFan` (>1 active), `hasArchivedTakes`, `hasComments`, `carriesUnshownText` (archived takes or comments). Public memberwise `init(blockID:placementID:position:variantID:text:activeVariantCount:liveVariantCount:commentCount:variantLocked:)` (counts required, not defaulted).

Other reads the editor uses: `Queries.containerHeader(db, containerID:) -> ContainerHeader?` (nil = missing/tombstoned), `Queries.blockFan(db, blockID:) -> [Variant]` (`Queries/EditorSupport.swift:68`), `Queries.leavingSavepointCandidates(db, containerID:) -> [String]` (`Queries/IdleCommit.swift:63`), `Queries.originalsStrandedBy(db, blockIDs:)`, `session.database.observeContainerHeader(postID)`, `session.database.observe { takesProjection }`.

### 1.4 What the phone's Write surface calls today

| Caller | Ops |
|---|---|
| Autosave (keystrokes, card edits, crystallizer corrections/attach) | `autosave(_:text:charDelta:expectedText:)` |
| Crystallizer mint | `newBlock(in:text:at: .end, registeringUndo: false)`; reconcile extras: `Operations().deleteBlock` (a no-undo value) |
| Divide (⋯ "Divide Block") | `divide` (single take) or `withCompound("Divide") { divideW(KeepOnTopDivide) }` |
| Merge with Previous | `merge(_:_:)` (no fan) or `mergeCeremony(pairings:[displayed×displayed, join .door], carries: all others)` |
| Extract Selection / Make Block from Selection (edit menu) | `extract`; `withCompound("Make Block") { divide; divide }` |
| New Block Below | `newBlock(in:text:"",at:.after(blockID))` |
| Delete Block / Archive Block | `deleteBlock(_:)` / `archiveBlock(_:)` |
| Whole-block selection + delete | `withCompound("Delete Blocks") { deleteBlock × N }` |
| Cross-block edit | `CrossBlockCompound.apply` → `insureTakes`, `editTakesAtomically` (CAS), `deleteBlock`, `editTakesAtomically` or `merge(joining: .deleteKeystroke)` + `autosave` |
| Undo door | `undoStack.pendingUndoWarning(with:)`, `undoReporting(with:)`, `redoReporting(with:)` |
| Commit Take | `commit(variantID, kind: .manual)` (`Takes/MobileBlockHistory.swift:210`) |
| Takes sheet | `chooseVariant`, `branchVariant`, `newBlankVariant`, `setTakeLabel`, `reorderTake`, `takeToBlockBelow`, `takesToBlocks`, `archiveVariant`, `deleteVariant` (presumed; `delete(variantID:)` at `MobileTakesBrowser.swift:721`), `unarchiveVariant`, `lockVariant`/`unlockVariant` (not traced) |
| History sheet | `restoreCommit(_:commitID:insuringBuffer: true)`, `unarchiveVariant`, `restoreVariant` |
| Lenses | `createLens`, `setLensChoice`, `clearLensChoice`, `adoptPicksPreservingChosen`, `renameLens`, `deleteLens`, `unarchiveVariant`, `restoreVariant` |
| Tray | `unarchiveBlock`, `restoreBlock`, `restoreVariant`, `PreservedOriginPutBack`, purge |
| ⋯ menu metadata | `updateBlockPresentation`, `setBlockName` |
| Comments | `addBlockComment`, `editBlockComment`, `deleteBlockComment`, `restoreBlockComment` |
| Note | `renameContainer`, `lockPost`/`unlockPost`, `setEntryDate`, `deleteContainer`, `VersionActs.save` |
| Leaving | `closeAutoCommit(_:takes:)` (fallback `closeAutoCommit(_:)`) |

Not called by the phone: `divideDuplicating` (Mac preset), `placeBlock`, `moveBlock`, `reorder` (block order), `resolveSyncConflict` (engine's), `deleteBlock(requiring: .emptyWithNothingUnshown…)` (Mac A7 only).

---

## 2. The phone's save machinery

### 2.1 `AutosaveCoordinator` (`App/Variorum/Shared/AutosaveCoordinator.swift`, `@MainActor final class`)

| Member | Verbatim / behaviour |
|---|---|
| `struct Pending: Equatable { var text: String; var charDelta: Int; var expectedText: String? = nil }` | `expectedText` = the snapshot of the run's FIRST edit only |
| `init(runner: OperationsRunner, debounce: Duration = .milliseconds(500), sleep: …)` | |
| `func record(variantID: String, text: String, charDelta: Int, basedOn: String? = nil)` | coalesces: newest text, summed charDelta; first edit of a run sets `expectedText = basedOn`; re-arms the debounce `Task` |
| `func flushNow() async` | cancels the debounce; waits while another batch is `writing`; takes ALL pending; writes one `runner.run { ops.autosave(…, expectedText:) }` per variant in id order; a refused entry goes back into `pending` (newer typing wins text, charDelta merged, OLDER expectedText kept); then `notifyError(first)`, wakes waiters, `notifySettled()` |
| `var isDirty: Bool { !pending.isEmpty || writing }`; `func isUnlanded(_:) -> Bool`; `private(set) var pending`, `inFlight`, `flushCount` | |
| `func observe(onError:onSettled:) -> UUID`, `func stopObserving(_:)`; single-owner `onError`, `onSettled`, `onFirstEdit` | the editor uses `observe` |

Debounces: autosave 500 ms (`AppSession.autosave(forPost:debounce: .milliseconds(500))`, VM init default `.milliseconds(500)`); crystallizer idle mint 2 s (`TailCrystallizer.idleDebounce = .seconds(2)`).

### 2.2 The ledger (`EB/EditorProjectionEngine.swift:28`, `nonisolated struct EditorSurfaceLedger`)

`private(set) var textByVariant: [String: String]`, `wordCountByVariant`; `mutating func adopt(_ slots: [Queries.RenderedBlock])` (replaces the map wholesale), `mutating func recordEdit(variantID: String, text: String)`, `func matches(_ new: [Queries.RenderedBlock], entries: [BlockRangeIndex.Entry]) -> Bool` (echo check: same count, IDs, variants, editability, UTF-16 lengths, texts vs ledger — never reads the surface). Writers: `recordAutosave` (every routed block keystroke), `displaySlot` (displayed variant only), `recordTakeEdit` (card edits), crystallizer `recordSurfaceText`; `adopt` in `renderFull`, `applyDifferential`, `.adoptEcho`. Readers: `surfaceKnownText(variantID:)` (takes overlay, crystallizer attach, copy), `basedOn` in `recordAutosave`.

### 2.3 Registry (VM-70) — `AppSession.postAutosaves` (`Shared/AppSession.swift:300–520`)

- `func autosave(forPost postID: String, debounce: Duration = .milliseconds(500), sleep: …) -> AutosaveCoordinator` — returns the post's ONE coordinator, `holders += 1`.
- `@discardableResult func releaseAutosave(forPost postID: String) -> Bool` — phone (`#else` arm): `holders -= 1`; drops the entry only when `holders <= 0 && !coordinator.isDirty`.
- Editor side (`VM:226–374`): `init` acquires; `takeAutosaveHold()` (screen `.task`: count arrival, re-acquire if released, adopt a different coordinator after flushing the old one, re-observe); `releaseAutosaveHold(ifNotShownSince:)` (leaving's last act); `isolated deinit` releases a hold no leaving gave back.
- Other walkers: `flushEveryOpenPost()`, `flushPendingTypingBeforeRound()` (sync's `beforeRound`: flush only dirty coordinators before the pull), `hasPendingAutosave`.

### 2.4 Leaving, background, lock (order)

| Road | Order |
|---|---|
| Leaving a note (`MobileWriteView.swift:220–250`, `.onDisappear`) | withdraw note line; `router.editors.deregister`; `Task { await model.teardown(); await session.savepointOnLeaving(postID); model.releaseAutosaveHold(ifNotShownSince:) }`. `teardown()` (`VM:392`): disarm canary → `await pendingGestureTask?.value` → `finish()` [cancel idle clock; `idleMintTail()` if mintable else `crystallizeIfNeeded()`; `awaitMintSettle()`; `autosave.flushNow()`] → stop observing. `savepointOnLeaving` phone arm (`AppSession.swift:668+`): `flushExistingAutosave` → reader `Queries.leavingSavepointCandidates` (StoreLockedError ⇒ return) → if non-empty `runner.run { closeAutoCommit(postID, takes: owed) }` (whole-note form if the read failed) |
| Background (`VariorumMobileApp.swift:229`, `MobileShellRouter.swift:286–441`) | `MobileTiming.appLeaving()`; `BackgroundAssertion`; `performBackgroundFlush`: `quickNote.fileOnLeaving()` → `editors.flushAll()` (each registered editor's `finish()`) → `savepointOnLeaving` per registered post → `sync.flush()`; then `relock.didLeaveTheScreen()` (locks if `MobileRelockPolicy.locksOnLeaving`) |
| Return to foreground | `relock.didReturnToTheScreen()` (may lock if away long enough), then `sync.triggerSync()` |
| Lock | the lock's teardown closes the pool and removes the screens; `savepointOnLeaving` catches `StoreLockedError`. Full lock sequence not traced in this pass. |
| Sync round | `flushPendingTypingBeforeRound()` before the pull (R-683-3) |

### 2.5 The `expectedText` / `basedOn` rescue, end to end

1. `storageDidEdit` `.block(i)` → `recordAutosave` (`VM:2442`): `basedOn = ledger.textByVariant[variantID]` (before this edit), `ledger.recordEdit(…, text: whole block text read off the page)`, `autosave.record(variantID:text:charDelta:basedOn:)`.
2. Coordinator keeps the run's first `basedOn` as `Pending.expectedText`.
3. `flushNow` → `ops.autosave(variantID, text:, charDelta:, expectedText:)`.
4. In the txn (`Ops/Operations+Variant.swift:54`): guards first; row takes her text; if `displaced != expectedText && displaced != text` and the block is live → `insertConflictVariant` (label `'conflict'`, parent = the edited take's parent, fan's end, never chosen/locked). Both rows push.
5. Refused write → entry back in `pending`, older snapshot kept, `isDirty` stays true (projections keep deferring).
Other `basedOn` sources: takes card (`MobileTakesBrowser.cardTextDidChange`: `lastRecordedCardText`), crystallizer attach (`knownText`) and corrections (the minted text). Pins: core `TypedOverRescueTests`; phone `MobileTypedOverRescueTests` (4).

---

## 3. Storage writers and block-map readers

### 3(a) Every writer of the text view's storage / attributes / text / selection

| # | Function (file:line) | Changes | Door | While first responder? | `markedTextRange` check |
|---|---|---|---|---|---|
| 1 | `renderFull` (`VM:1077`) | chars + attrs (whole doc); also `selectedRange` (caret by location, clamped), `undoManager.removeAllActions()` | `storage.setAttributedString` under `suppressEditProcessing` | yes | no |
| 2 | `applyDifferential` → `programmaticReplace` (`VM:1132, 2577`) | chars + attrs per changed slot, last-to-first; `removeAllActions` if edited | `EditorSurfaceStorage.replace` (beginEditing, `replaceCharacters`, `setAttributes(base + blockID)`, markdown restyle, endEditing) under suppress | yes | no |
| 3 | `displaySlot` (`VM:1838`) — from `takes.flip`, `takes.peek`, `endAllPeeksRestoringDisplay` (lens activate/return) | chars of one block; index entry rebuilt; `removeAllActions` | `programmaticReplace` | yes | callers `flip`/`peek` and `MobileLenses.activate/returnToNote` check; `displaySlot` itself does not |
| 4 | `replaceTailRegion` (`VM:2796`) ← `TailCrystallizer.finishMint` | chars of the tail region (normalized minted texts + separators + remaining tail); `selectedRange` to end if it was at end; `clearTextUndo` | `programmaticReplace(…, caretToEndIfWasAtEnd: true)` | yes | `idleMintTail` checks before starting a mint; the `.tail`-arm `crystallizeIfNeeded` and `finishMint` do not |
| 5 | `MobileMarkdownActs.inputReplace` (`MobileMarkdownActs.swift:60`) | chars; sets `selectedRange = range` first | gate pre-consult → `textView.insertText` / `deleteBackward()` (UITextInput) | yes | via callers: `apply` and `toggleCheckbox` check; `handleReturnKey` is only reached with no marked text; `runClampedInBlockEdit` does not |
| 5a | `apply(_:to:)` (bar acts, Tab/⇧Tab, heading pick) | chars; then `selectedRange = plan.selection` | #5 per edit, reversed | yes | yes |
| 5b | `handleReturnKey` `.continueList` | ⏎ then list lead | `ordinary()` = `super.insertText("\n")`, then #5 | yes | entry guarded |
| 5c | `consumeDelete` (exit list / outdent item) | deletes lead/unit; re-places `selectedRange` | #5 | yes | entry guarded |
| 5d | `toggleCheckbox` | 3 chars for 3; restores `selectedRange` | #5 | yes | yes |
| 5e | `runClampedInBlockEdit` (`VM:2162`) | the clamped span | #5, after a CAS on `documentLength` + `expectedText` | yes | no |
| 6 | `TV.insertText` override (`TV:1014`) | system typing | `super.insertText` | yes | ⏎ branch only when no marked text |
| 7 | `performTabKey` (`TV:1029`) | `"\t"` | gate pre-consult → `super.insertText("\t")` | yes | no (via `apply` for list lines) |
| 8 | `paste` (`TV:1097`) | system paste; sets `isPasting` | `super.paste` | yes | — |
| 9 | System roads (keyboard, autocorrect `replace(_:withText:)`, dictation, marked text, `deleteBackward`, cut, predictions, Writing Tools, drop) | chars | UIKit | yes | — |
| 10 | `restampProjection(over:)` (`VM:2632`) inside `storageDidEdit` | attrs: block-ID add/remove over the reported range, extent from the index | direct `addAttribute`/`removeAttribute` | yes | no |
| 11 | `MobileTypedFace.reset` (`MobileTypedFace.swift:52`) inside `storageDidEdit` | attrs: font, ink, remove strikethrough/background on changed chars only (equality-gated) | beginEditing/addAttribute/endEditing | yes | no |
| 12 | `MarkdownFace.restyle` (in `storageDidEdit`, `programmaticReplace`), `MarkdownFace.style` (`renderFull` on the detached string; `applyVoiceChange`), `MarkdownFace.settleCaret` (`settleMarkdownCaret` from `textViewDidChangeSelection`/`textViewDidChange`) | attrs only (marked runs via `MarkdownFace.faceAttribute`) | beginEditing/endEditing inside `Shared/MarkdownFace/MarkdownFaceCore.swift` | yes | no |
| 13 | `applyVoiceChange` (`VM:983`) | attrs over full doc (remove face/background/strike; add font/ink/paragraph style) | direct, beginEditing/endEditing | yes (deliberate Settings flip) | no |
| 14 | `TailCrystallizer.attachLeadingTailRunIfNeeded` / `finishMint` (`EB/TailCrystallizer.swift`) | attrs: block-ID via `EditorSurfaceStorage.setBlockID` | direct | yes | no |
| 15 | `MobileEditorTextView.setReservation` / `healReservationResidue` (`TV:731–896`) ← `MobileBlockDecor.refresh` (emoji gap, `firstLineHeadIndent`) and `MobileTakesChromeController.refresh` (badge room, `tailIndent`) | attrs: `.paragraphStyle` per paragraph (equality-gated) | direct `storage.addAttribute` | yes — on every `refreshChrome`: `layoutSubviews` (`.nearViewport`), `storageDidEdit` (`.edit(range)`), projection apply (`.document`) | no |
| 16 | `applyVoiceChrome` (`TV:987`) | `typingAttributes = MobileEditorStyle.baseAttributes`; `inputAccessoryView`; `reloadInputViews()` | property set | yes | — |
| 17 | Other `selectedRange` writers | `MS` `runDivide`, merge, extract, make block, insert below, `landCaret` (by block identity over the re-rendered page); `jumpToBlock` (`VM:1496`, + unanimated `setContentOffset`); `restore(_ place:)` (`TV:535`) | property set | yes | no |
| 18 | Editability / responder | `standDown()` (`endEditing(true)`, `isEditable = false`), `noteLivenessGranted()`, `adoptHeader` (gone ⇒ endEditing + uneditable), takes/comments/history sheets set `page.isEditable = false` while open; `arrive(focus:)` → `becomeFirstResponder()` | property set | — | — |

`EditorSurfaceStorage` (`EB/EditorSurfaceStorage.swift`): `static func text(of: NSMutableAttributedString?, in: NSRange) -> String`, `static func setBlockID(_: String?, over: NSRange, in: NSMutableAttributedString?)`, `static func replace(_ range: NSRange, with newText: String, blockID: String?, in storage: NSMutableAttributedString, base: [NSAttributedString.Key: Any], restyle: ((NSMutableAttributedString, NSRange) -> Void)?)`.

`MobileEditorStyle.baseAttributes` = `[.font: baseFont, .foregroundColor: face.ink, .paragraphStyle: baseParagraphStyle]` (`MobileEditorStyle.swift:338`).

### 3(b) Every reader of the block map

| Reader (file:line) | What it needs |
|---|---|
| `shouldChangeText` (`VM:1904`) | `index.verdict(replacing:replacementIsSingleNewline:segmentation:)`, `documentLength`; on cross-block, `EditorEditRoute.route(range:replacement:index:slots:findReplacing:false:arms:surfaceText:)` |
| `storageDidEdit` (`VM:2219`) | `ArmedEdit.binds(… documentLength:)`; `fallbackVerdict` → `index.verdict`; mutators `applyBlockEdit(at:lengthDelta:)`, `applyTailEdit`, `openTail`, `closeTail`; `restampProjection` (entries walk); `recordAutosave` (`entries[i].variantID`, `range(ofEntryAt:)`); `syncTailText` (`tailRange`) |
| `applyProjection` | `ledger.matches(new, entries:)`; `sameSequence` = block-ID arrays equal |
| `applyDifferential` | `index.entryRanges()`; rebuilds `BlockRangeIndex(slots:tail:)` |
| `displaySlot` | entry by block ID, `range(ofEntryAt:)`, rebuilds one `Entry` |
| `blockID(atSurfaceOffset:)` (`VM:1732`) | block at offset (zero-length entry at its location; separators/tail → nil) — used by the chrome pan router hit-test |
| `blockIDNearOffset(_:)`, `blockIDAtCaret()`, `openTakesBrowserAtCaret()` | block at caret, boundary-tolerant (offset−1) |
| `rangeOfBlock(_:)` (`VM:1743`) | range of one block (O(entries)) — jump, structural caret landing, `landCaret` |
| `blockRangesByID()` (`VM:1756`) | every block's range in one walk — `refreshChrome` builds it once per event for both chrome controllers |
| `openTailText`, `hasOpenTail`, `mintableTail` | `tailRange`, `tailLength` |
| `planWholeBlockDeletion` / `planCrossBlockEdit` / `planClampedInBlockEdit` / `runClampedInBlockEdit` | `wholeBlockDeletion(covering:replacement:)`, `CrossBlockCompound.plan/clampedInBlockEdit(index:surfaceText:)`, `documentLength` |
| `TailCrystallizer` via `TailCrystallizerHost` | `index.tailLength`, last entry (`editable`, `variantID`), `range(ofEntryAt:)`, `tailRange`, `entryRanges()`, `transferTailPrefixToLastEntry`, `crystallize(minted:remainingTailLength:)` |
| `IdentityProjectionAudit.audit(index:storage:onFailure:)` (DEBUG) | the tiling vs block-ID attribute runs |
| `MobileStructuralController.entryTouching(caret:)` (`MS:958`) | entry whose CLOSED range contains the caret + intra offset |
| `divide(atSurfaceCaret:)` | `entries[i]` (`variantID`, `editable`, `blockID`), `range(ofEntryAt:)`, page text of that block |
| `mergeWithPrevious(atSurfaceCaret:)` | entries i−1, i (`variantID`, `length`) |
| `runSpanGesture` | `StructuralGesturePlanner.World(index:, fanArities: slots.map(\.activeVariantCount), sealed:, textAt:)` |
| `deleteBlock`/`archiveBlock`/`deleteWholeBlockRun` | `index.caretLandingAfterRemoving(_:) -> (blockID: String, offset: Int)` |
| `MobileTakesChromeController` (`Takes/MobileTakesChrome.swift:138,534`) | ranges map; `model.slot(for:)` (`hasFan`); `blockID(at point)` → TK2 fragment → offset → `blockID(atSurfaceOffset:)` |
| `MobileBlockDecorController` (`Write/MobileBlockDecor.swift:70`) | ranges map; `model.presentations`, comment counts (slots) |
| `MobileEditMenu.takesTarget` (`Takes/MobileEditMenuSeam.swift:33`) | `blockIDNearOffset(range.location)` |
| Keyboard bar ⋯ / ⑂ | `blockIDAtCaret()`, `openTakesBrowserAtCaret()` |
| `MobileTakesController` | `model.slot(for:)` (`slots`), `surfaceKnownText` |
| `copyNote` | `displayedTextByBlock` (slots + ledger, only when peeks exist), `openTailText` |
| `jumpToBlock` | `rangeOfBlock` |

---

## 4. Features sitting on the editor

| Feature | Where | Touches storage / index | Tests |
|---|---|---|---|
| Markdown face | `Shared/MarkdownFace/MarkdownFaceCore.swift` (`MarkdownFace.style/restyle/settleCaret`, `faceAttribute`); caret rescue core `Domain/MarkdownCaretRescue.swift` (`Ledger.noteEdit(replacing:newLength:)`, `settle(selection:in:)`) | attrs only (#12) | `MobileMarkdownTests` (33), `MobileMarkdownCaretTests` (4); core `MarkdownCaretRescueTests` (17) |
| Typed-face reset (VM-243) | `Write/MobileTypedFace.swift` — `static func reset(_ storage: NSTextStorage, range: NSRange, font: UIFont, ink: UIColor, baseInks: [UIColor]) -> Bool`; applied in `storageDidEdit` to `changedCharacters ?? bound landing` before `MarkdownFace.restyle`; counter `typedFaceResets` | attrs (#11) | `MobileTypedFaceResetTests` (8), `MobileTypedTextFaceTests` (6) |
| List continuation / exit / outdent on ⏎ | `MobileMarkdownActs.handleReturnKey` ← `TV.insertText` | chars via #5b/#5c | `MobileMarkdownTests` |
| Other keystroke inserts | Tab/⇧Tab (`performTabKey`, `performShiftTabKey`, key commands with `wantsPriorityOverSystemBehavior`); checkbox tap (`MobileCheckboxTapRouter`) | #5/#7 | `MobileMarkdownTests` |
| Formatting acts + keyboard bar | `Write/MobileKeyboardBar.swift` (`MobileKeyboardBarController`, `makeBar()` → `inputAccessoryView`). Collapsed row: "Aa" (expands strip), "⑂" (`openTakesBrowserAtCaret`), "⋯" (deferred `UIMenu` of `blockMenu.menuElements(blockID:)`). Strip: bold, italic, strike, code, link, bullet, checklist, heading (# cycles H1→H2→H3→clear; long-press picker), indent (`performTabKey`), outdent. All via `MobileMarkdownActs.apply` | #5a | `MobileKeyboardBarGeometryTests` (6), `MobileMarkdownTests` |
| Structural doors | `MS` (`MobileStructuralController`). Each: latch → seal check → flush-first (`model.flushPendingText()`) → post-flush re-verify → store read of the fan → `runner.run` → `model.report` (receipt w/ Undo) → `await model.refreshTakesFromStore()` → caret by block identity. **Divide**: cut = `StructuralGesturePlanner.snapToInteriorBoundary(intra, in: pageText)` (settle; NOT the exact word start); single take `divide`, fanned keep-on-top. **Merge with Previous**: caret's entry must be i>0; fan read; `merge` or `mergeCeremony`; caret at `min(leadingLength, range.length)`. **Extract / Make Block**: `StructuralGesturePlanner.plan(.extractSelection/.makeBlockFromSelection, selection:, world:)`; cross-block make-block refuses. **New Block Below**: fence-exempt latch. **Delete / Archive**: landing from `caretLandingAfterRemoving` read before the write. | result reaches the page ONLY through the fresh read + projection policy (differential/full render) | `MobileStructuralTests` (25), `MobileStructuralFlightFenceTests` (10), `MobileWholeBlockDeleteTests` (29), `MobileCrossBlockEditTests` (24), `MobileBlockMenuTests` (21), `MobileTakeStructureTests` (15) |
| Cross-block route on the gate | `performCrossBlockRoute` (`VM:2049`): `.deleteWholeBlocks` → `structural.deleteWholeBlockRun`; `.editInBlock` → `runClampedInBlockEdit`; `.refuseAwaitingSync` → `.unsyncedBlock` sentence; `.editAcrossBlocks` → `structural.runCrossBlockEdit`; `.refuse(cause)` → `CrossBlockRefusal.message`. Every claim is scheduled via `scheduleGestureCompound` (chained `pendingGestureTask`) and the keystroke itself is refused | — | `MobileCrossBlockEditTests`, `MobileEditRouteArmsTests` (3) |
| Structural undo door | `Write/MobileUndoDoor.swift` (`beginUndo(from:)`, `confirmPendingUndo`, `cancelPendingUndo`, `redo`): latch (`inFlight` fences) → flush → `pendingUndoWarning` (asks before overwriting unsaved buffers) → `undoReporting` → `refreshTakesFromStore()` → receipt with Redo. Does not place the caret | page via fresh read | `MobileUndoDoorTests` (14), `MobileUndoWarningWordsTests` (2) |
| Takes on a block — peek/swap | `Takes/MobileTakesController.swift`. `flip(blockID:forward:)` (swipe via `MobileTakesPanRouter`, pill arrows), `peek(blockID:to:)`, `endAllPeeksRestoringDisplay()`, `endPeek`, `chooseDisplayed(blockID:)` (→ `chooseVariant`, the only choosing act). A peek **does write the storage**: `model.displaySlot(peekedSlot…)` swaps the block's characters in place (#3), zero store writes. `overlay(_:)` maps every projection so a peeked slot carries the peeked take's `variantID/text/variantLocked`; the index entry's `variantID` becomes the peeked take, so **typing during a peek autosaves into the peeked take** (and its lock refuses through the gate). Text resolves ledger-first (`surfaceKnownText`). | #3 | `MobileTakesTests` (19), `MobileTakesChromeTests` (13), `MobileArchivedTakesTests`, `MobileTakeLockTests`, `MobileTakeLabelTests` |
| Takes sheet | `Takes/MobileTakesBrowser.swift` + `MobileTakesBrowserView.swift`: page stands down (`isEditable = false`) while open; card editor is its own text view → `cardGateAllows` / `cardTextDidChange` → `model.recordTakeEdit(variantID:text:charDelta:basedOn:)` (same ledger + coordinator); `close()` → `refreshTakesFromStore()` | page via fresh read | `MobileTakesBrowserTests` (30) |
| Takes chrome (badge ⑂, peek marker, pill, gutter) | `Takes/MobileTakesChrome.swift` (`RefreshScope { document, nearViewport, edit(NSRange) }`); rect from `TV.firstLineGeometry(atOffset:)` / `blockRectsUnion(range:)`; reserves trailing room by `setTailReservation` | attrs #15 | `MobileTakesChromeTests` |
| Lenses | `Takes/MobileLenses.swift` — a lens = a saved multi-block peek: `activate` = `endAllPeeksRestoringDisplay` + `takes.peek` per pick; saves via lens ops; `adoptView` → `refreshTakesFromStore` | #3 | `MobileLensesTests` (10) |
| Callout frames, emoji, comment marks | `Write/MobileBlockDecor.swift` (`MobileBlockDecorController.refresh(scope:ranges:)`): frame = `blockRectsUnion(range:)`; emoji = `firstLineGeometry` + `setLeadingFirstLineReservation`; comment mark = `lastLineEnd(range:)`. Inputs: `model.presentations`, slot comment counts. Callout vocabulary `Write/MobileCallout.swift` | attrs #15; overlay views | `MobileBlockMenuTests`, `MobileCommentParkTests`, `MobileCommentDraftTests` |
| Find | `presentFind()` (`VM:1398`) → `findInteraction.presentFindNavigator(showingReplace: false)`; `isFindInteractionEnabled = true` (`TV:946`); `supportsTextReplacement` → `false` (`TV:1074`) | none | — |
| Tail crystallizer host + idle mint | `EB/TailCrystallizer.swift`; phone conformance `VM:2739–2815` (`holdsTailForStructuralFlight` = false, `didApplyMint` = no-op, `replaceTailRegion` → #4, `recoverFromRefusedIndexMutation` → `desyncRecovery`) | #4, #14 | `MobileEditorTests` (23), `MobileTrailingNewlinesTests` (5), `MobileCRLFCaptureTests` |
| Keystroke fence | `Domain/StructuralFlightFence.swift` (`flightBegan`, `flightLanded(surfaceSettled:) -> Landing`, `refusesPolicedEdit()`, `withholdsSystemEdit()`, `surfaceSettled()`, `drain() -> Bool`, `static surfaceHoldsTheStore(forcedRenderOwed:projectionDeferred:)`); face `VM:1331–1388` | gate refuses; storage belt sets `forceFullRender` instead of autosaving | `MobileStructuralFlightFenceTests` (10); core `StructuralFlightFenceTests` (8) |
| Edit trace (E1) | `Write/MobileEditTrace.swift`; hooks `gate(range:replacementLength:)` (`VM:1909`), `armedVerdict()` (`VM:2030`), `report(editedRange:delta:hadArming:bound:changedCharacters:rescued:)` (`VM:2289`), `suppressedReport(editedRange:delta:)` (`VM:2233`), `desyncRecovery()` (`VM:2487`); bounded 300 events; summary counts overrun / starts-before / net≠ / gate-less / most gate calls before one edit; `MobileEditTraceView` (`:613`) | none | `MobileEditTraceTests` (13) |
| Timing marks in the editor | `AppTiming.editorBuilt` (`VM:232`), `noteProjectionDelivered/Loaded/Fetched/Refreshed`, `MobileTiming.noteRendered` (`VM:1035`, initial render), `noteRequested/Arrived/Leaving/Left` (`MobileWriteView.swift`), `autosaveWillWrite/Wrote/Refused` (coordinator); `MobileTiming` listens to `keyboardDidShow/Hide` (`keyboardIsUp`, `AppTiming.keyboardUp()`) | none | `MobileTimingTests` (4), `MobileHerPathsPerfTests` (13) |
| Note tray | `Write/MobileNoteTray.swift` — put-back roads call ops directly (no flush, no explicit refresh; the page updates by delivery) | page via delivery | `MobileNoteTrayTests` (19) |
| Jump to block | `MobileBlockList` row → `onJump` → `model.jumpToBlock` (`VM:1496`): caret at block start, unanimated offset via `firstLineGeometry`, fallback `scrollRangeToVisible` | selection + offset | `MobileBlockListTests` (16) |
| Caret / keyboard scroll | `MobileWriteSurfaceView` pins the text view's bottom to `keyboardLayoutGuide` (`TV:1111`); typewriter room = bottom inset (`MobileTypewriterRoom`); `MobileScrollAuthority` (`revealRect(_:textBottom:)`, `herGestureHolds(…)`, quiet 0.6 s) in `scrollRectToVisible`/animated `setContentOffset` overrides; `revealCaretIfLostToEstimates()` after `scrollViewDidEndScrollingAnimation`; place memory `MobileWritePlace` + `MobileWritePlaces` | offsets only | `MobileWriteScrollAuthorityTests` (10), `MobileHiddenPageKeyboardTests` (1), UI `MobileKeyboardRevealUITests` |
| Read-only states | **sealed**: gate refuses (`SealedNoteCopy`), page stays editable (caret drawn); **locked take**: `Entry.editable = false` → `.refuse(.lockedVariant)` → `lockedTakeRefusal`; **gap slot**: `variantID == nil` → `.readOnlySlot`; **stood down** (another tab holds the pen): `isEditable = false`, `endEditing`, gate belt "This note is live in your other tab."; **deleted note**: `adoptHeader(nil)` → `noteIsGone`, endEditing, uneditable, gate `deletedNoteRefusal`; **sheet open**: page `isEditable = false`. Gate order: suppress → gone → !isLive → sealed → attribute-only pass → flight fence → verdict | — | `MobileLivenessTests` (18), `MobileDeletionTests` (13) |

---

## 5. `MobileEditorTextView` and delegates

- `@MainActor final class MobileEditorTextView: UITextView` (`TV:221`).
- **Overrides:** `layoutSubviews` (stamp fling clock, `updateTypewriterRoom`, `refreshChrome(scope: .nearViewport)`, place memo); `scrollRectToVisible(_:animated:)`; `setContentOffset(_:animated:)`; `willMove(toWindow:)` (place on leaving); `insertText(_:)` (⏎ door); `keyCommands` (adds Tab, ⇧Tab); `supportsTextReplacement` (false); `paste(_:)` (isPasting). **Not overridden:** `deleteBackward`, `canPerformAction`, `buildMenu`, `caretRect` (only called), `replace(_:withText:)`, `cut`, `textInputMode`.
- **Construction / TK2 opt-in** (`static func make()`, `TV:923`): explicit `NSTextContentStorage` + `NSTextLayoutManager` + `NSTextContainer(size: (0, 1e9))`, `widthTracksTextView`, `MobileEditorTextView(frame: .zero, textContainer:)`; strong `tk2Stack` holds both (weak back-pointers). Documented trap: `UITextView(usingTextLayoutManager:)` on a Swift subclass returned an instance with uninitialized stored properties (crash). Also sets `adjustsFontForContentSizeCategory`, `alwaysBounceVertical`, `keyboardDismissMode = .interactive`, `isFindInteractionEnabled = true`, `textContainerInset (8,15,8,15)`, the bar controller, the checkbox tap recognizer.
- **Canary** `MobileFallbackCanary` (`TV:33`): `arm(for:idleInterval: 30)` (immediate checkpoint + 30 s repeating timer), `disarm()`, `checkpoint(_:context:)` (fires when `textLayoutManager == nil`: os_log fault, `assertionHandler` (debug assert), `onFire` → `VM.canaryMessage`), `isolated deinit` invalidates. Called after every storage-writing road (`canaryCheckpointAfterMutation()`).
- **Gate delegate** `MobileEditorGateDelegate: UITextViewDelegate` (`VM:2822`, installed by `attach(textView:)`): `textView(_:shouldChangeTextIn:replacementText:)` → `model.shouldChangeText(in:replacement:isPaste:)`; `textViewDidChangeSelection` and `textViewDidChange` → `settleMarkdownCaret()`; `scrollViewDidEndScrollingAnimation` → `revealCaretIfLostToEstimates()`; extension in `Takes/MobileEditMenuSeam.swift:96` — `textView(_:editMenuForTextIn:suggestedActions:) -> UIMenu?` (annotated deprecated iOS 27; adds "Takes…", Extract Selection / Make Block from Selection when length > 0, and a "Block" submenu from `blockMenu.menuElements`).
- **Storage observer** `MobileStorageObserver: NSTextStorageDelegate` (`VM:2878`): `textStorage(_:willProcessEditing:range:changeInLength:)` → `capture.willProcess(mask, range:, delta:)`; `textStorage(_:didProcessEditing:range:changeInLength:)` → `capture.take(reportedRange:delta:)` (always, every mask) then, if `.editedCharacters`, `model.storageDidEdit(editedRange, changeInLength: delta, changedCharacters:)`. `nonisolated struct MobileChangedCharactersCapture` (`VM:2951`): keeps the pre-fixing range only for character passes; accepted only if `kept.delta == delta` and kept range ⊂ reported range.
- **Text input traits:** none set (defaults). `typingAttributes` set to base in `applyVoiceChrome`. No drag/drop interaction configuration. No `pasteConfiguration`. `isFindInteractionEnabled = true`.
- **`ArmedEdit`** (`EB/EditorEditRouting.swift:47`): `verdict`, `range`, `documentLength`, `replacementLength`, `exactCost`; `describes(editedRange:delta:documentLength:) -> Bool` (same doc length, `delta == replacementLength - range.length`, start inside the approval — strict for non-empty, inclusive for empty); `binds(editedRange:delta:documentLength:landedText:) -> Bool` (adds: `.openTail` binds only if the landed char is `"\n"`). `EditorAssertionSeam.fire(_:file:line:)` with a `@TaskLocal` handler.

---

## 6. Shared brains — API, inputs, rules

All `EB/` files import only `Foundation` (+ `VariorumCore` except `EditorEditRouting`, `EditorSurfaceStorage`, `IdentityProjectionAudit`, `TextMetrics`); none import UIKit/AppKit. They compile into both app targets (synced group `Shared` is in `Variorum` and `VariorumMobile`), NOT into the Swift package. "Tied to BlockRangeIndex" below means the function takes a `BlockRangeIndex`; note that `BlockRangeIndex` is a plain value constructible from `[Entry]` (`init(entries:tailLength:)`), so a new core can build one from marks it reads off the page.

| File | Public API (abridged) | Inputs | Rules it encodes |
|---|---|---|---|
| `BlockRangeIndex` | `struct Entry { blockID, variantID?, length, editable }`; `init(entries:tailLength:)`, `init(slots:tail:)`; `documentLength`, `range(ofEntryAt:)`, `entryRanges()`, `tailRange`, `tailSeparatorOffset`; `verdict(replacing:replacementIsSingleNewline:segmentation:) -> Verdict {block(index:), tail, openTail, closeTail, refuse(Refusal{crossesBlockBoundary, readOnlySlot, lockedVariant, indexDesync})}`; `emptyBlockDeletion`, `emptyBlockCarve(replacing:isDeletion:) -> (carved, survivor)?`, `interEntrySeparatorPair(deleting:isDeletion:)`, `wholeBlockRun(covering:)`, `wholeBlockDeletion(covering:replacement:)`, `wholeBlockRunAwaitsSync`, `caretLandingAfterRemoving(_:)`, `textedSeamPair(deleting:isDeletion:)`; mutators returning Bool | value + NSRange | Tiling: entries joined by exactly one 1-char separator, then (iff open) separator + tail; no entries ⇒ tail is the document. ⏎ at exact doc end with no tail opens the tail (not in `oneBlock`). Deleting an empty tail's separator closes it. A7 geometry: "When BOTH neighbours are empty the one BEFORE the separator wins". J9: whole-block run excludes one-char ranges ("A one-character deletion is a SEAM KEYSTROKE"). |
| `EditorDocumentCore` | `EditorDocument.blockIDAttribute` (`"io.lduarte.variorum.blockID"`), `separator = "\n"`, `materializeCore(_ slots:tail:base:) -> (text: NSMutableAttributedString, index: BlockRangeIndex)`, `blockID(at:in:)` | slots | "the separator character is owned by NEITHER neighboring block — it carries no block-ID attribute"; "On iOS the attributes are strictly a DERIVED PROJECTION re-stamped from the index after every edit". |
| `EditorEditRouting` | `ArmedEdit`, `EditorAssertionSeam` | values | see §5 |
| `EditorEditRoute` | `enum Arm { findReplaceFence, emptyBlockCarve, textedSeamMerge, wholeBlockDelete, clampedInBlockEdit, gapFence, crossBlockCompound }`; `macArms`, `phoneArms`, `precedence`, `violations(of:)`; `enum Route {refuseFindReplace, carveEmptyBlock(SeamCarvePlan.EmptyBlockDeletion), mergeTextedSeam(SeamCarvePlan.SeamMerge), deleteWholeBlocks([String]), editInBlock(InBlockEdit), refuseAwaitingSync, editAcrossBlocks(Plan), refuse(CrossBlockRefusal.Cause)}`; `static func route(range:replacement:index:slots:findReplacing:arms:surfaceText:) -> Route`; `SeamCarvePlan.emptyBlockDeletion(replacing:with:index:slots:)` → `EmptyBlockDeletion { blockID, variantID, entryIndex, landing: .endOf(blockID:)/.startOf(blockID:) }`; `SeamCarvePlan.textedSeamMerge(replacing:with:index:) -> SeamMerge { leadingIndex, trailingIndex, leadingBlockID, trailingBlockID }` | BlockRangeIndex + slots + `(NSRange)->String` | `macArms = [.findReplaceFence, .emptyBlockCarve, .textedSeamMerge, .wholeBlockDelete, .clampedInBlockEdit, .crossBlockCompound]`; `phoneArms = [.wholeBlockDelete, .clampedInBlockEdit, .gapFence, .crossBlockCompound]`. Why shorter: "No find fence (no find-and-replace in its editor); NO SEAM CARVES (KnownIssues row 51 — deliberately unbuilt; the day the mobile catch-up builds them they become two entries here, placed by `precedence`, plus two phone executors); the gap fence's copy arm above the compound." A7 enablement guards: replacement empty, empty entry, editable with a variant, `slots[i].activeVariantCount == 1`, `!slots[i].carriesUnshownText`; authorization is `deleteBlock(requiring: .emptyWithNothingUnshown)`. #34: "backspace at a seam between two TEXTED blocks MERGES when NEITHER block has takes, and refuses-and-speaks when either does"; fan read from the store at run time; locked takes do not refuse. VX-290 landing: "The caret lands where the deleted line break was." |
| `CrossBlockCompound` | `cutIsAtAParagraphBreak(_:offset:)`, `clampedToBlockText(_:ranges:)`, `struct InBlockEdit { range, entryIndex, blockID, replacement, expectedText, documentLength }`, `clampedInBlockEdit(replacing:with:index:surfaceText:)`, `struct Edge { blockID, variantID, oldText, newText, charDelta }`, `struct Plan { deletedBlockIDs, leading?, trailing?, joinsEnds, caretBlockID, caretOffset; editedVariantIDs }`, `struct Outcome`, `plan(replacing:with:index:surfaceText:) -> Plan?`, `apply(_:ops:undoStack:liveActiveTakeCount:) throws -> Outcome`, `undoLabel = "Edit Across Blocks"` | BlockRangeIndex + `(NSRange)->String`; `apply` takes `Operations` + `UndoStack` | Rules 1–7 in the header: whole-covered blocks ride `deleteBlock`; partial ends keep identity and edit the chosen take; ends merge only when both cuts mid-paragraph ("They do NOT merge at a paragraph break of EITHER kind — a block seam or an internal newline", R-13u-2); a fan on either end suppresses the join (store read); `insureTakes` first; refuse whole on a locked take (R-13u-1) and on a gap; one undo entry. #109 law: "a selection edge sitting on a boundary clamps to block text — separators are structure, never deletable content — and NO boundary-anchored selection refuses." A typing gesture keeps the first block even if wholly covered. Join: `merge(joining: .deleteKeystroke)` then `autosave` of `leading.newText + trailing.newText` (no join char survives). |
| `CrossBlockRefusal` | `enum Cause { seamBesideFan, seamBesideArchivedTake, seamBesideComment, lockedTake, unsyncedBlock, openTail, emptyTailAtSpanEnd, seamKeystrokeDeclined, surfaceNotSettled }`; `diagnose(range:index:slots:)`, `causeClause`, `roadClause(for:fanRoads:)`, `message(for:fanRoads:)`, `message(range:index:slots:fanRoads:)` | BlockRangeIndex + slots | `seamKeystrokeDeclined` on iPhone: "there are no seam carves at all … so an ordinary backspace at a seam between two texted blocks lands here permanently." Clause: "This keystroke can't join these two blocks." Phone `fanRoads` = "Merge the blocks deliberately instead (⋯ → Merge with Previous), which brings every take along." |
| `CrystallizationPlanner` / `CrystallizationReconciler` | `Kind { typing, bulk(Segmentation), idle(Segmentation), oneBlock }`; `kindForTailEdit(mode:bulkPending:)`, `kindForDurabilityMint(mode:)`, `plan(_:tail:) -> Plan? { kind, mints, remaindersAfter, remainingTail }`; `reconcile(minted:currentTail:kind:) -> Outcome { corrections, deletions, applied, newTail, needsFullRerender }` | strings | Typing crystallizes completed paragraphs (paragraph-based regardless of sentence mode); bulk (paste) segments whole tail and closes it; idle keeps a trailing typed newline run (k−1); one-block mints verbatim. |
| `TailCrystallizer` | `@MainActor final class`; `text`, `mintInFlight`, `mintTask`, `idleDebounce = .seconds(2)`, `idleSleep`; `setText`, `cancelIdleClock`, `isMintable(host:)`, `armIdleMint(host:)`, `idleMintTail(host:)`, `crystallizeIfNeeded(forcedKind:host:)`, `static mintBlocks(_:in:ops:)`, `finishMint(_:kind:host:)`, `awaitMintSettle()`; `protocol TailCrystallizerHost` (index, mutators, ledger doors, autosave, runner, postID, segmentation, storage accessor, marked-text accessor, error voice, `replaceTailRegion`, `clearTextUndo`, audit, `holdsTailForStructuralFlight`, `didApplyMint`, `applyPendingIfClean`) | host | Leading `\n` run of the tail attaches to the last block as trailing content; mint off-main, reconcile against the current tail, corrections autosave, extra mints deleted quietly, then the tail region is rewritten and the index crystallized. |
| `CutPropagation` | `propose(activeCut:activeText:targetText:window: 16) -> Int?`; `TakeSpanMatch.uniqueRange(of:in:)` | strings | unique-context cut proposal for the W ceremony (Mac) |
| `EditorProjectionEngine` | `EditorSurfaceLedger` (§2.2); `EditorProjectionPolicy.decide(loaded:busy:forceFull:delivery:matchesSurface:sameSequence:) -> Decision {deferUntilClean, initialRender, forcedFullRender, adoptEcho, differential, fullRender, refetchFresh}` | values | precedence "not-loaded ▸ busy ▸ forced ▸ echo ▸ delivery-refetch ▸ same-sequence ▸ full" |
| `EditorSurfaceStorage` | §3(a) | NSMutableAttributedString | — |
| `IdentityProjectionAudit` | `isClean(index:storage:) -> Bool`, `audit(index:storage:onFailure:)` | BlockRangeIndex + storage | block-ID runs must agree with the tiling (DEBUG) |
| `MarkdownSurfaceDoors` | `Edit { range, replacement }`, `DocumentPlan { edits, selection }`, `plan(_ act:document:selection:)`, `returnVerdict(document:caret:) -> MarkdownEditing.ReturnKey`, `checkboxToggleEdit(document:insertionIndex:)`, `linkAddress(document:at:)` | NSString + NSRange (line-local) | every edit sits inside one line, so inside one block |
| `StructuralGesturePlanner` | `Command { divideAtCursor, extractSelection, makeBlockFromSelection, mergeBlocks }`; `struct World { index, fanArities, sealed, textAt }`; `Refusal` (11 cases); `Plan { divide(entryIndex:blockID:snappedCut:), divideW(entryIndex:blockID:activeCut:), extract(…), makeBlock(…), merge(…), mergeChain(…), makeBlockAcrossBlocks(…), refusal }`; `plan(_:selection:world:)`, `plan(divideAtExactCut:world:)`, `snapToInteriorBoundary(_:in:)` | BlockRangeIndex + fan arities + `textAt` | front refusals: invalid selection, sealed, touches tail; divide: fanned ⇒ `.divideW`, else needs a cut and an editable entry. |
| `TypedReturn` | `Edge { below, above }`; `Act { content, emptyBlock(edge:entryIndex:blockID:closingEmptyTail:), divideAtCaret(entryIndex:blockID:), divideAtWordStart(entryIndex:blockID:cut:) }`; `act(selection:index:segmentation:textAt:) -> Act`; `lineRange(of:at:)` | BlockRangeIndex + `(Int)->String` | see 6.1 |
| `TextMetrics` | `wordCount(_:)` | string | — |
| Domain `BoundarySnapping` | `boundaries(in:granularity:)`, `settle(_:in:among:)` (`settlePull = 2`), `wordStart(enclosing:in:)`, `extractableSpan(_:in:)`, `seamTrimmedHalves(_:cutAtUTF16:)`, `graphemeIndex(atUTF16:in:)`, `graphemeRange(_:in:)` | String + UTF-16 `Int` / `Range<Int>` | "cuts may land between ANY two words and at newlines … word edges are free, sentence ends and newlines pull a little" (S4-22); `wordStart` is "the FLOOR of the legal set, not its nearest member" (VX-806) |
| Domain `MergeJoin` | §1.2 | strings | doors vs deletes (R-13u4-3) |
| Domain `KeepOnTopDivide` | §1.2 | `[Variant]` | U-2 default; mirror `keepBelow` |

### 6.1 The Mac's ruled keystroke-structure rules (what the phone does not run today)

**Return** (`TypedReturn.act`, quoted rules; dispatch `EditorSurfaceController.runTypedReturnAct` / `insertEmptyBlock`):
- Chip off (`segmentation == .oneBlock`) → `.content`. A selection → `.content`. No blocks yet (all tail) → `.content` (crystallization).
- Caret in the tail: tail with text → `.content`; EMPTY tail → `.emptyBlock(.below, last, closingEmptyTail: true)` (close the empty tail's separator, mint below the last block).
- Caret's entry = first entry whose closed range contains the caret ("a caret at a block's END belongs to that block").
- Empty block → `.emptyBlock(.below)` — "THE CHAIN (her ruling R-13u4-2 … it SUPERSEDES U-1's 'nothing in an empty block' arm)".
- Whitespace-only block, caret past offset 0 → `.emptyBlock(.below)`.
- Only whitespace before the caret → `.emptyBlock(.above)` (block pushed down, caret stays).
- Caret on a list line, not at its end → `.content` (PROVISIONAL #94).
- Only whitespace after the caret → `.emptyBlock(.below)`.
- Caret strictly inside a word → `wordStart`; if only whitespace before it → `.emptyBlock(.above)`; else `.divideAtWordStart(cut: wordStart)` — VX-806: "a caret INSIDE a word carries the whole word down".
- Otherwise → `.divideAtCaret`.
- Mac executors: `.below` → `newBlock(in:text:"",at:.after(blockID))`, caret to new block offset 0; `.above` → `newBlock(…, at: .before(blockID))`, caret stays at the text block offset 0; `.divideAtCaret` → `.divideAtCursor` planner (settled cut; single take `divide`, fanned keep-on-top); `.divideAtWordStart` → `StructuralGesturePlanner.plan(divideAtExactCut:)`. ⇧⏎ is the in-block newline (`EditorTextView` soft-newline). The act is decided at the key and re-derived on its own turn ("so two fast Returns compose").
- Refusals are not decided here ("A sealed note, a locked take and a gap slot all answer through the doors this routes to").

**Backspace at a block's start / forward-delete at its end** (one separator):
1. A7 empty-block carve — empty neighbour, no fan, nothing unshown, editable ⇒ `deleteBlock(requiring: .emptyWithNothingUnshown(variantID:))`; caret lands at the survivor's END if the carved block sat after the separator, else the survivor's START (VX-290). Receipt "Empty block deleted — ⌥⌘Z undoes it."
2. #34 texted-seam merge — both texted ⇒ store fan read; both single-take ⇒ `merge(…, joining: .deleteKeystroke)` (space unless an edge is whitespace); either fanned ⇒ refuse ("backspace won't fold a fan away"). Receipt "Blocks joined — ⌥⌘Z undoes it."
3. Else the diagnosis (fan / archived take / comment / locked / unsynced).

**Edits across blocks** (both platforms, ladder order): J9 whole-block delete (≥2 chars, delete only, gap-fenced; #33(a) unrestricted, takes locked takes) ▸ #109 clamp (one block + boundary separator ⇒ ordinary in-block edit) ▸ [phone only: gap fence copy] ▸ cross-block compound ▸ diagnosis.

---

## 7. Tests

### 7.1 `App/Variorum/VariorumMobileTests/` (Swift Testing; app-hosted, so every run is an `xcodebuild test` needing a stage claim)

Drivers: `typeEdit(_:_:range:replacement:isPaste:)` (`MobileEditorTestSupport.swift:93`) = `model.shouldChangeText` then a bare `NSTextStorage.replaceCharacters` with base font only (no custom attrs) — the "gate + storage replace" driver; `makeEditor` attaches a bare storage with both clocks disabled; `withEditorWorld` = in-memory DB, `.incrementing` UUIDs, ticking clock. Hosted drivers: `MobileEditorTextView.make()` / `MobileWriteSurfaceView` + window, with `insertText`/`deleteBackward`; `HostedSurface` (`MobileSurfaceDriver.swift:209`) mounts SwiftUI in a key window and activates via accessibility.

| Suite | @Test | Drives |
|---|---|---|
| MobileEditorTests | 23 | typeEdit (20 uses) + 2 real views |
| MobileEditRoutingTests | 18 | typeEdit |
| MobileEditRoutingCrashTests | 3 | pure/model calls (no typeEdit) |
| MobileEditRouteArmsTests | 3 | route table |
| MobileUnarmedEditRoutingTests | 4 | unarmed storage edits (VM-24) |
| MobileChangedCharactersCaptureTests | 9 | the pure capture rule |
| MobileCrossBlockEditTests | 24 | plans + compound |
| MobileWholeBlockDeleteTests | 29 | plans + door |
| MobileStructuralTests | 25 | typeEdit + doors; includes a source walk (`:1323`) |
| MobileStructuralFlightFenceTests | 10 | doors + UIKit input on hosted views |
| MobileTakesTests | 19 | typeEdit + takes controller |
| MobileTakesChromeTests | 13 | hosted view |
| MobileTakesBrowserTests | 30 | controller + hosted |
| MobileLensesTests | 10 | controller |
| MobileMarkdownTests | 33 | hosted view, `insertText`/`deleteBackward` (17 uses) |
| MobileMarkdownCaretTests | 4 | hosted view |
| MobileTypedFaceResetTests / MobileTypedTextFaceTests | 8 / 6 | bare storage rule + hosted |
| MobileTypedOverRescueTests | 4 | typeEdit + store |
| MobileTrailingNewlinesTests | 5 | typeEdit |
| MobileUndoDoorTests / MobileUndoWarningWordsTests | 14 / 2 | door |
| MobileNoteTrayTests | 19 | model |
| MobileEditTraceTests | 13 | recorder (TaskLocal) |
| MobileEditorSeamCostTests | 1 | cost |
| MobileWriteScrollAuthorityTests | 10 | hosted view |
| MobileHiddenPageKeyboardTests | 1 | hosted |
| MobileLeavingSavesOnceTests / MobileSavepointOnLeavingTests | 7 / 6 | leaving roads |
| MobileDeferredProjectionRetryTests | 2 | projection |
| MobileLivenessTests | 18 | typeEdit (19 uses) + hosted |
| MobileWalkTests | 8 | real views, UIKit input (14 uses) |
| MobilePerfWalkTests / MobileHerPathsPerfTests | 13 / 13 | perf |
| MobileNoteOpenOnceTests | 11 | open road |
| MobileCRLFCaptureTests, MobileConflictDiscoveryTests | 1, 2 | — |
| MobileTakeStructureTests, MobileBlockMenuTests, MobileBlockHistoryTests | 15, 21, 21 | doors |
| MobileNoteClipboardTests, MobileKeyboardBarGeometryTests, MobileBlockListTests | 10, 6, 16 | — |
| Source scans touching Write/Takes | `MobilePhoneTypeSourceTests` (walks Shared + Write), `MobileStructuralTests` (a faces walk) | file reads |

### 7.2 Mac target (`App/Variorum/VariorumTests/`) — the shared brains' suites

`BlockRangeIndexTests` 27, `TypedReturnTests` 23 (pure decision; `ReturnKeyTraceTests` drives NSEvents), `EditorEditRouteTableTests` 21 (pins `phoneArms` as data, `:111–120`), `CrossBlockCompoundTests` 19, `BoundaryClampTests` 20, `SeamMergeTests` 20, `StructuralGesturePlannerTests` 61, `IdentityProjectionAuditTests` 15, `EditorProjectionEngineTests` 7, `CrystallizationTests` 21, `CutPropagationTests` 8; `FannedDefaultsTests`, `DivideArrangementTests` (KeepOnTopDivide). Mac tests that read phone source: `OpsRefusalTableIntegrityTests.swift:87` (literals of `MobileEditorViewModel.swift`), `DeadVocabularyTests.swift:195` (`MobileBlockHistorySheetView.swift`). No shared-brain suite lives in the core package.

### 7.3 Core package (`Tests/VariorumCoreTests/`, 389 files)

Relevant: `BoundarySnappingTests` 43, `MergeJoinTests` 7, `StructuralFlightFenceTests` 8, `MarkdownCaretRescueTests` 17, `MarkdownEditingTests`, `MarkdownSyntaxTests`, `StructuralDivideTests`, `StructuralDivideDuplicatingTests`, `StructuralExtractTests`, `StructuralMergeTests`, `StructuralMergeCeremonyTests`, `StructuralSplitAtNewlinesTests`, `TypedOverRescueTests`, `SegmentationRulesTests`.

### 7.4 UI tests and the Spike

- `VariorumMobileUITests/TK2SpikeUITests.swift` — scheme `TK2SpikeUITests` (marked THROWAWAY): `testHorizontalSwipeOnFannedBlockPeeks`, `testHorizontalSwipeOutsideFannedBlockDoesNotPeek`, `testVerticalSwipeScrollsWithoutPeeking`, `testEditMenuCarriesCustomBlockItems`, `testRealTypingPipelineAndKeyboard` (types "I like teh " into the spike bench, asserts storage edits). Launch env `TK2SPIKE_UI=1`; evidence also in the app's `Documents/tk2spike-results.log`.
- `MobileKeyboardRevealUITests.testAMidNoteTapRisesAboveTheKeyboard` — run via the `TK2SpikeUITests` scheme, `-only-testing:VariorumMobileUITests/MobileKeyboardRevealUITests`, on a dedicated simulator with the software keyboard (detaches the hardware keyboard itself), opens the pocket guide through Settings' Debug door, types one letter into the editor and deletes it. Commands quoted in its header (build-for-testing / test-without-building with a per-session `-derivedDataPath`).
- `VariorumMobileUITests.swift` (`testExample`, `testLaunchPerformance`), `VariorumMobileUITestsLaunchTests.testLaunch` — templates.
- `VariorumMobile/Spike/` (DEBUG: Settings ▸ "TK2 Spike" row, or `TK2SPIKE_UI`): `SpikeScreen`, `SpikeBench`, `SpikeSupport`, `SpikeScenarios` with `runFallbackInventory`, `runScale(words:)`, `runJumps(words:fractions:reps:)`, `runTyping(words: 50_000)`, `runEnsureLayoutReference(words:)`, `runAttributeSurvival`, `runGestureGeometry`, `runKeyboard`, `runAll`. Plain `UITextView`s, not the app's editor.

---

## 8. Where a headless pure rule could live

- `VariorumCore` target (`Package.swift`): deps `CArgon2`, GRDB, swift-dependencies; platforms macOS 26 / iOS 26; no UIKit/AppKit anywhere in `Sources/VariorumCore` (grep). `Domain/` files `import Foundation`. **`NSRange` is used in Domain public API today**: `MarkdownCaretRescue.point(in text: NSString, selection: NSRange) -> Int?`, `Ledger.noteEdit(replacing old: NSRange, newLength: Int)`, `Ledger.settle(selection: NSRange?, in text: NSString) -> Restyle?`; `MarkdownEditing` uses `NSString`/`NSRange` internally. **UTF-16 `Int` offsets** are the Domain convention (`BoundarySnapping` takes `Int` and `Range<Int>`, doc: "TextKit 2 reports ranges as `NSRange` (UTF-16), so the editor … hands offsets straight to these functions"). **No `NSAttributedString` anywhere in VariorumCore** (grep).
- `Shared/EditorBrain/` is app-target code (both apps), not package code; it depends on `Queries.RenderedBlock` and `Operations` from core. Its tests run only in the Mac app target.
- Core tests: Swift Testing in `Tests/VariorumCoreTests/`, run headless with `swift test --filter <SuiteName>` from the repo root (no stage claim — CLAUDE.md). App-target tests need `xcodebuild … test` and a held stage claim.

---

## 9. Build, install, Diagnostics

- **Phone device build (her installs):** scheme `VariorumMobile`, configuration Release, destination `generic/platform=iOS`, a dedicated derived-data folder named per effort: `~/Library/Developer/Xcode/DerivedData/vm45-device/…` (VM-45), `…/vm47-wave1-device/Build/Products/Release-iphoneos/VariorumMobile.app` (VM-47). The documented command form: `xcodebuild -project App/Variorum/Variorum.xcodeproj -scheme VariorumMobile -configuration Release -destination 'generic/platform=iOS' build` (`notes/plans/mobile-round-2.md:503`); the handoffs record "built from a clean checkout at exactly <sha>" but do not quote their `-derivedDataPath` flag. Gate: `codesign --verify --deep --strict`. Install in place: `xcrun devicectl device install app --device "$DEV" "$APP"` (runbook `notes/plans/vm-44/plans/vm-45-install-runbook.md` §d; never uninstall; safety copy §c; phone unlocked). Signing: Apple Development, automatic, team wildcard profile. Bundle id `io.lduarte.VariorumMobile` for both configurations; version 1.0 (1), no build stamping. VM-47 handoff: "The stage first" (a stage claim is now required for the install).
- `VariorumMobile.xcscheme`: Test = Debug, Launch = Release, Profile = Release, Archive = Release. Other shared schemes: `Variorum`, `TK2SpikeUITests`.
- **Settings ▸ Diagnostics:** `Features/Shell/MobileSettingsView.swift` — `static let diagnosticsGroupTitle = "Diagnostics"` (`:114`), `private var diagnosticsGroup` (`:378`): Toggle "Record edit trace" (`traceArmed` ↔ `MobileEditTrace.setArmed`), row "Edit trace…" (sheet `MobileEditTraceView`), row `MobileTimingCopy.door` (sheet `MobileTimingView`). Release-live. `#if DEBUG` `debugGroups` (`:410+`): "Tutorial (dev store)", "Performance (dev store)" (seed 100k fixture), "TK2 Spike" (full-screen `SpikeScreen`). A new switch/probe would be a row inside `diagnosticsGroup` (or `debugGroups` for Debug-only) plus a `.sheet` like the two existing ones.
- **How a Diagnostics value is stored:** device-local `UserDefaults.standard` — edit trace key `"VariorumMobileEditTraceArmed"` (`MobileEditTrace.swift:150`), read once into a static recorder (never on the keystroke road), written only on change; not synced (synced settings live in the `setting` table, which this does not touch). Timing readout: a JSON file at Application Support `Timing/timing.json` (`MobileTiming.swift:219`), app process only.

---

## Not covered / not verified in this pass

- Full refusal lists of `restoreBlock`, `placeBlock`, `moveBlock`, `reorder`, `chooseVariant`, `archiveBlock`, `editTakesAtomically`, and the takes-sheet ops beyond those named.
- The full lock sequence (`MobileRelockCoordinator.lock()` and the pool close).
- `MobileBlockMenu` rows beyond names/targets (callout toggle/emoji/remove, name, commit, insert, divide, merge, archive, delete; comments row).
- Per-test-case content of each suite (only counts and drivers were classified; counts are `@Test` occurrences, parameterized tests count once).
- The exact `-derivedDataPath` flags used for the recorded device builds.
