//
//  EditorViewModel.swift
//  Variorum
//
//  The editor conductor (Phase 7 Steps 2–6): renders the post projection
//  into one live TK2 surface (author-confirmed: one live NSTextView per
//  focused post), routes every edit through BlockRangeIndex (live identity —
//  AppSpec §15 risk 1), autosaves through Operations, executes tail
//  crystallization, and fronts commit/fan/restore gestures. No business
//  rules live here: the operations layer enforces; this class holds
//  projections, routes edits, and sends operations.
//
//  Buffer-vs-observation rule (plan Step 4): while an autosave is pending or
//  a mint is in flight the buffer is authoritative — projections defer until
//  clean, then apply. Our own autosave echo is detected by comparing the
//  incoming projection against the live surface and skipped without a view
//  edit. Sync conflicts arrive as new variants, never buffer clobbers (S5).
//

import AppKit
import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import VariorumCore

@MainActor
@Observable
final class EditorViewModel {
    // MARK: - Composition

    @ObservationIgnored let session: AppSession
    let postID: String

    init(session: AppSession, postID: String) {
        self.session = session
        self.postID = postID
        self.autosave = AutosaveCoordinator(runner: session.runner)
        autosave.onError = { [weak self] error in self?.showOperationError(error) }
        autosave.onSettled = { [weak self] in self?.applyPendingIfClean() }
    }

    // MARK: - Observable UI state

    private(set) var header: Queries.ContainerHeader?
    private(set) var canaryMessage: String?
    private(set) var statusMessage: String?
    private(set) var caretBlockID: String?
    private(set) var caretVariantID: String?
    /// 9d — the caret block's user-facing number (1-based, current order,
    /// derived at read time, never stored) and the post's block count.
    private(set) var caretOrdinal: Int?
    private(set) var blockCount = 0
    /// 9d — word counts for the status bar: the caret block's, and the
    /// selection's when one exists.
    private(set) var caretBlockWordCount: Int?
    private(set) var selectionWordCount: Int?
    /// Fan badges for on-screen fanned blocks (document coordinates).
    private(set) var badges: [BlockBadge] = []
    /// The block whose fan panel is open (nil = closed).
    var fanPanel: FanPanelState?
    /// Commit history for the caret variant (nil = panel closed).
    var commitList: [CommitListItem]?
    /// A restore that needs the pre-split warning confirmed first.
    var pendingRestore: CommitListItem?
    /// Per-command gesture enablement (Phase 9) — recomputed on every caret/
    /// selection change from THE planner, so the menu bar, context menu, and
    /// shortcuts all read one brain's verdicts.
    private(set) var gestureAvailability = GestureAvailability()
    /// A divide invoked on a fanned block routes here: the W ceremony's ONE
    /// sheet (contract item 3). Non-nil = the sheet is up; the live editor
    /// is untouched for the ceremony's whole duration; cancel sets nil with
    /// no rows touched; confirm funnels back through the structural door.
    var divideWCeremony: DivideWCeremonyState?

    struct GestureAvailability: Equatable {
        var divide = false
        var extract = false
        var makeBlock = false
        var merge = false
        /// The fan door (9d): available wherever the caret is in a block —
        /// ANY arity (the badge stays fan-only; the door must not be).
        var takes = false
    }

    struct DivideWCeremonyState: Equatable, Identifiable {
        let blockID: String
        /// The rendered variant at invoke time — pre-marked, its cut
        /// pre-placed at the gesture's snapped position.
        let activeVariantID: String?
        var takes: [WTake]
        var id: String { blockID }

        /// Every marked take needs a legal cut before the mint (the op's
        /// own requirement, mirrored so Confirm can gate).
        var canConfirm: Bool {
            let marked = takes.filter(\.marked)
            return !marked.isEmpty && marked.allSatisfy { $0.cut != nil }
        }

        var markedCuts: [String: Int] {
            Dictionary(uniqueKeysWithValues: takes.compactMap { take in
                guard take.marked, let cut = take.cut else { return nil }
                return (take.variant.id, cut)
            })
        }
    }

    struct WTake: Equatable, Identifiable {
        let variant: Variant
        var marked: Bool
        /// The cut carried through this take (UTF-16, interior boundary of
        /// its text) — pre-seeded by string-context matching, freely
        /// adjusted; nil = unseeded (no unique match) until placed.
        var cut: Int?
        /// The legal cut positions in this take's text (interior
        /// sentence/paragraph boundaries) — the click-to-place targets.
        let boundaries: [Int]
        var id: String { variant.id }
    }

    struct BlockBadge: Equatable, Identifiable {
        let blockID: String
        let variantCount: Int
        let frame: CGRect
        var id: String { blockID }
    }

    /// The AppKit badge overlay renders through this (overlay views, never
    /// rendering attributes — memo obligation).
    @ObservationIgnored var badgeSink: (([BlockBadge]) -> Void)?

    /// 9d — the "Show Blocks" tint mode: one span per visible block, its
    /// stable palette index and document-coordinate frame. Same overlay
    /// doctrine as the badges: views over the text, NEVER rendering
    /// attributes (TEXTKIT2 §3 — the flaky path).
    struct BlockTintSpan: Equatable {
        let entryIndex: Int
        let colorIndex: Int
        let frame: CGRect
    }
    @ObservationIgnored var tintSink: (([BlockTintSpan]) -> Void)?
    private var tintSpans: [BlockTintSpan] = []
    /// Set by the view from its AppStorage toggle.
    var blockTintEnabled = false {
        didSet { if oldValue != blockTintEnabled { refreshTint() } }
    }

    struct FanPanelState: Equatable, Identifiable {
        let blockID: String
        var variants: [Variant]
        var chosenVariantID: String?
        var id: String { blockID }
    }

    struct CommitListItem: Equatable, Identifiable {
        let commit: CommitPoint
        let predatesSplit: Bool
        var id: String { commit.id }
    }

    // MARK: - Editor internals (never observed)

    @ObservationIgnored private(set) var index = BlockRangeIndex(entries: [], tailLength: nil)
    @ObservationIgnored private(set) var slots: [Queries.RenderedBlock] = []
    @ObservationIgnored private(set) var tailText = ""
    @ObservationIgnored private(set) weak var textView: EditorTextView?
    @ObservationIgnored private(set) weak var scrollView: NSScrollView?
    @ObservationIgnored let autosave: AutosaveCoordinator
    @ObservationIgnored private let canary = FallbackCanary()
    @ObservationIgnored private var pendingVerdict: BlockRangeIndex.Verdict?
    @ObservationIgnored private var suppressEditProcessing = false
    @ObservationIgnored private(set) var mintInFlight = false
    @ObservationIgnored private var mintTask: Task<Void, Never>?
    @ObservationIgnored private var bulkPending = false
    @ObservationIgnored private var pendingProjection: [Queries.RenderedBlock]?
    @ObservationIgnored private var forceFullRender = false
    @ObservationIgnored private var loaded = false
    /// The variant a loaded commit history belongs to — restore targets
    /// THIS, never the caret's current position (review round 1, NIT 12).
    @ObservationIgnored private var commitListVariantID: String?
    /// One structural gesture lands at a time (Phase 9): the door is busy
    /// from invoke to rewrite, and a second invoke refuses visibly.
    /// Readable so the review-round pins can stage mid-flight interleavings.
    @ObservationIgnored private(set) var structuralInFlight = false
    /// Times `desyncRecovery` has fired this session — the Step 8 soak
    /// asserts ZERO (store == index == surface through every interleaving).
    @ObservationIgnored private(set) var desyncRecoveryCount = 0
    /// The text the surface currently holds per variant — maintained at
    /// every adoption point (full render, differential, structural apply)
    /// and every edit record, so `surfaceMatches` detects our own autosave
    /// echo WITHOUT reading the surface (Phase 10 Step 1 — the KnownIssues
    /// O(post-length) echo-compare fix: the old path extracted
    /// `attributedSubstring` for every slot on every clean projection
    /// arrival, document-proportional main-thread work at debounce rate).
    @ObservationIgnored private var surfaceTextByVariant: [String: String] = [:]
    /// Surface text extractions (`viewText` calls), test-visible: the echo
    /// pin asserts a projection echo performs ZERO of these (red on the old
    /// per-slot-extraction path).
    @ObservationIgnored private(set) var surfaceTextReads = 0
    /// Times the differential-apply DEBUG oracle found the surface diverged
    /// from the store projection — the soak asserts ZERO (the author-
    /// directed proof that the differential path lands safely).
    @ObservationIgnored private(set) var differentialOracleMisses = 0
    /// Clears a transient hint (the fanned-extract hint) after a beat.
    @ObservationIgnored private var hintClearTask: Task<Void, Never>?
    /// One-shot seeds applied at the first render after attach (Phase 10
    /// Step 3 — focus handoff): the read-tier click's caret offset (the
    /// read surface and the editor render the SAME materialization, so the
    /// offset transfers), and the badge tap's focus-then-fan block
    /// (interpretation 1: focus FIRST, then the fan panel opens on the one
    /// live surface).
    @ObservationIgnored var pendingCaretSeed: Int?
    @ObservationIgnored var pendingFanSeed: String?

    // Idle-mint (author decision 2026-07-06, review round — QUESTIONS item
    // 2 answered): a short quiet gap crystallizes the open tail, including
    // the trailing partial paragraph, bounding crash loss to seconds like
    // every other edit; teardown stays the backstop. Granularity is
    // paragraph in EVERY mode (author ruling on QUESTIONS item 3).
    @ObservationIgnored var tailIdleDebounce: Duration = .seconds(2)
    /// Injectable for deterministic tests (default: the real clock).
    @ObservationIgnored var tailIdleSleep: @Sendable (Duration) async throws -> Void =
        { try await Task.sleep(for: $0) }
    @ObservationIgnored private var tailIdleTask: Task<Void, Never>?

    var hasOpenTail: Bool { index.tailLength != nil }

    // MARK: - Lifecycle

    /// `scrollView` is the editor's OWN scroll view (the detail editor) —
    /// nil for the inline book-view editor, which lives inside the
    /// container's scroll (Phase 10 Step 3): viewport reads then come from
    /// the view's `visibleRect`, and per-editor scroll anchoring/jumping
    /// stands down (the container owns scroll position).
    func attach(textView: EditorTextView, scrollView: NSScrollView?) {
        self.textView = textView
        self.scrollView = scrollView
        canary.onFire = { [weak self] message in self?.canaryMessage = message }
        canary.arm(for: textView)
        textView.onCommitShortcut = { [weak self] in self?.commitCaretVariant() }
        textView.structuralMenuItems = { [weak self] in self?.contextMenuItems() ?? [] }
        session.editorRouter.active = self
        if let pending = pendingProjection {
            pendingProjection = nil
            applyProjection(pending)
        }
    }

    /// Runs for the editor's lifetime: header + slots, live.
    func start() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.observeHeader() }
            group.addTask { await self.observeSlots() }
        }
    }

    /// Teardown: persist what only the editor knows (open tail, scroll
    /// anchor), then let go. The open tail crystallizes on idle (author
    /// decision 2026-07-06) and again here as the backstop, so nothing
    /// typed is ever lost to a post switch or window close. Returns the
    /// finalize task (nil when nothing was pending) so handoff callers and
    /// tests can await text safety deterministically (Phase 10 Step 3).
    @discardableResult
    func teardown() -> Task<Void, Never>? {
        if let anchor = topVisibleOffset() {
            session.editorRouter.scrollAnchors[postID] = anchor
        }
        if session.editorRouter.active === self {
            session.editorRouter.active = nil
        }
        canary.disarm()
        return finalizeWork()
    }

    /// Flushes the buffer, waits out any in-flight mint (so its
    /// reconciliation runs — review round 1, MINOR 5), then crystallizes
    /// whatever open tail remains. Holds `self` strongly: the view model
    /// stays alive until its text is safe, even across a post switch.
    /// A refusal (a post sealed remotely while a tail was open) is
    /// surfaced, never silently dropped; the text stays in the buffer for
    /// the session (see QUESTIONS — anything more inventive is a product
    /// call). Returns the task so quit-time callers can await it.
    @discardableResult
    func finalizeWork() -> Task<Void, Never>? {
        tailIdleTask?.cancel()
        let hasTailText = hasOpenTail && !tailText.allSatisfy(\.isWhitespace)
        guard autosave.isDirty || mintInFlight || hasTailText else { return nil }
        return Task { // strong self, deliberately
            await self.autosave.flushNow()
            // Let the in-flight mint (and any round it chains) reconcile.
            while self.mintInFlight {
                if let mint = self.mintTask {
                    await mint.value
                } else {
                    await Task.yield()
                }
            }
            // Mint the residual tail with TYPING granularity (paragraph in
            // every mode — author ruling; the trailing partial included).
            let tail = self.hasOpenTail ? self.tailText : ""
            guard !tail.allSatisfy(\.isWhitespace) else { return }
            let mode = self.header?.effectiveSegmentation ?? .paragraph
            let kind: CrystallizationPlanner.Kind =
                mode == .oneBlock ? .oneBlock : .idle(.paragraph)
            guard let plan = CrystallizationPlanner.plan(kind, tail: tail) else { return }
            let post = self.postID
            do {
                let minted = try await self.session.runner.run { ops in
                    try plan.mints.map { text -> CrystallizationReconciler.MintedBlock in
                        let result = try ops.newBlock(in: post, text: text, at: .end)
                        return .init(
                            blockID: result.block.id,
                            variantID: result.variant.id,
                            text: text)
                    }
                }
                // Keeps index/view/bookkeeping consistent when the editor
                // is still alive (quit path); harmless after a post switch.
                self.finishMint(minted, kind: kind)
                // The quit belt (round 2, MINOR): finishMint's leading-run
                // attachment records into the 500 ms autosave debounce, and
                // the app delegate replies terminateNow right after this
                // task — a record left pending dies with the process and
                // the typed gap collapses on relaunch. Land it HERE, inside
                // the awaited task (this also makes toggleSeal's trailing
                // flush a redundant belt rather than load-bearing).
                await self.autosave.flushNow()
            } catch {
                self.showOperationError(error)
            }
        }
    }

    private func observeHeader() async {
        do {
            for try await value in session.database.observeContainerHeader(postID) {
                adoptHeader(value)
            }
        } catch is CancellationError {
        } catch {
            statusMessage = "Header observation failed: \(error)"
        }
    }

    /// Internal so tests can drive the header without the observation.
    func adoptHeader(_ value: Queries.ContainerHeader?) {
        header = value
        // The structural flight's non-editable fence must hold for the
        // WHOLE flight (review round 1, MINOR 2): the op's own touch stamp
        // triggers a header delivery, and letting it re-enable editing
        // reopens the flush→op keystroke window the fence exists to close.
        // The flight's defer re-derives editability from the freshest
        // header at flight end.
        if !structuralInFlight {
            textView?.isEditable = value.map { !$0.locked } ?? false
        }
    }

    private func observeSlots() async {
        do {
            for try await value in session.database.observePost(postID) {
                applyProjection(value)
            }
        } catch is CancellationError {
        } catch {
            statusMessage = "Post observation failed: \(error)"
        }
    }

    // MARK: - Projection → surface

    /// Internal so tests can drive projections without the observation.
    func applyProjection(_ new: [Queries.RenderedBlock]) {
        guard textView != nil else {
            pendingProjection = new
            return
        }
        if !loaded {
            // First render: there is no local tail yet — the pre-load index
            // is a placeholder, never a tail to preserve.
            renderFull(new, preserveTail: false)
            loaded = true
            applyFocusSeeds()
            return
        }
        // The buffer is authoritative while dirty; defer until clean. A
        // structural flight defers too (round 3 NIT): a delivery rewriting
        // the surface mid-flight is geometry-safe post-round-2 (the seam
        // guards fall back to full render on any mismatch) but would clear
        // text-undo and double-rewrite under the gesture — the flight's
        // exit applies the deferred value through the settle machinery.
        if autosave.isDirty || mintInFlight || structuralInFlight {
            pendingProjection = new
            return
        }
        if forceFullRender {
            forceFullRender = false
            renderFull(new, preserveTail: true)
            return
        }
        if surfaceMatches(new) {
            // Our own autosave echo (or metadata-only movement): adopt the
            // projection for badge/fan data, touch nothing in the view.
            slots = new
            adoptSurfaceTextMap(new)
            refreshBadges()
            return
        }
        if new.map(\.blockID) == index.entries.map(\.blockID) {
            applyDifferential(new)
        } else {
            renderFull(new, preserveTail: true)
        }
    }

    /// True when the projection and the live surface agree on every slot:
    /// same blocks, same rendered variants, same texts, same editability.
    ///
    /// Cost (Phase 10 Step 1 — resolves the KnownIssues echo-detection row):
    /// the surface is NEVER read here. `surfaceTextByVariant` carries the
    /// text the surface is known to hold per variant — written at every
    /// adoption point and every edit record — so the echo check is an
    /// in-memory comparison (no `attributedSubstring` extraction, no
    /// allocation; the old path extracted every slot's text from the
    /// storage on each clean projection arrival, O(post length) of
    /// main-thread surface reads at autosave-debounce rate). The pin
    /// asserts `surfaceTextReads` stays flat through an echo.
    private func surfaceMatches(_ new: [Queries.RenderedBlock]) -> Bool {
        guard new.count == index.entries.count else { return false }
        for (i, slot) in new.enumerated() {
            let entry = index.entries[i]
            let editable = !slot.isGap && !slot.variantLocked
            guard slot.blockID == entry.blockID,
                  slot.variantID == entry.variantID,
                  editable == entry.editable
            else { return false }
            let text = slot.text ?? ""
            guard text.utf16.count == entry.length else { return false }
            guard let variantID = slot.variantID else {
                // A gap slot renders as an empty read-only range; the length
                // check above (0 == 0) is the whole comparison.
                continue
            }
            guard text == surfaceTextByVariant[variantID] else { return false }
        }
        return true
    }

    /// Adopts `new` as the known surface text per variant — called wherever
    /// the surface is (re)written from a projection, so the map always
    /// describes what the view actually shows.
    private func adoptSurfaceTextMap(_ new: [Queries.RenderedBlock]) {
        var map: [String: String] = [:]
        map.reserveCapacity(new.count)
        for slot in new {
            if let variantID = slot.variantID { map[variantID] = slot.text ?? "" }
        }
        surfaceTextByVariant = map
    }

    /// Same block sequence, different content (choose-variant, an external
    /// edit, restoreCommit): replace only the changed slots, last-to-first
    /// so earlier ranges stay valid. Cost ∝ changed blocks, never the post.
    private func applyDifferential(_ new: [Queries.RenderedBlock]) {
        var edited = false
        for i in stride(from: new.count - 1, through: 0, by: -1) {
            let newText = new[i].text ?? ""
            let range = index.range(ofEntryAt: i)
            if viewText(range) != newText {
                programmaticReplace(range, with: newText, blockID: new[i].blockID)
                edited = true
            }
        }
        index = BlockRangeIndex(slots: new, tail: hasOpenTail ? tailText : nil)
        slots = new
        adoptSurfaceTextMap(new)
        if edited {
            // Undo entries recorded against the old surface would replay at
            // stale offsets — across-block corruption risk; drop them.
            textView?.undoManager?.removeAllActions()
        }
        updateCaretContext()
        refreshBadges()
    }

    private func renderFull(_ new: [Queries.RenderedBlock], preserveTail: Bool) {
        guard let textView, let storage = textView.textStorage else { return }
        let tail: String?
        if preserveTail, hasOpenTail {
            tail = tailText
        } else {
            // No local tail (or nothing worth preserving): an empty post is
            // all tail by construction; a post with blocks has none.
            tail = new.isEmpty ? "" : nil
        }
        let anchor = topVisibleOffset()
        let (attributed, newIndex) = EditorDocument.materialize(new, tail: tail)
        suppressEditProcessing = true
        storage.setAttributedString(attributed)
        suppressEditProcessing = false
        index = newIndex
        slots = new
        adoptSurfaceTextMap(new)
        tailText = tail ?? ""
        textView.undoManager?.removeAllActions()
        if let anchor {
            JumpPrimitive.jump(
                toOffset: min(anchor, max(0, index.documentLength)),
                textView: textView, scrollView: scrollView)
        } else if let saved = session.editorRouter.scrollAnchors[postID] {
            JumpPrimitive.jump(
                toOffset: min(saved, max(0, index.documentLength)),
                textView: textView, scrollView: scrollView)
        }
        updateCaretContext()
        refreshBadges()
    }

    private func applyPendingIfClean() {
        guard !autosave.isDirty, !mintInFlight, !structuralInFlight,
              pendingProjection != nil else { return }
        pendingProjection = nil
        // The deferred value was fetched BEFORE the flush that just landed —
        // applying it as-is would transiently revert the actively edited
        // block to its pre-flush text (review round 1, MAJOR 2). Re-fetch:
        // the fresh projection includes our flush, so the echo check passes
        // and only genuinely external changes touch the view.
        Task { [weak self] in
            guard let self else { return }
            guard let fresh = try? await session.database.read({ [postID] in
                try Queries.renderPost($0, containerID: postID)
            }) else { return }
            guard !autosave.isDirty, !mintInFlight, !structuralInFlight else {
                pendingProjection = fresh
                return
            }
            applyProjection(fresh)
        }
    }

    // MARK: - Edit routing (the delegate entry points)

    func shouldChangeText(in range: NSRange, replacement: String?) -> Bool {
        guard !suppressEditProcessing else { return true }
        if header?.locked == true {
            refuseFeedback("This post is sealed — unlock it to edit.")
            return false
        }
        guard let replacement else { return true } // attribute-only
        let verdict = index.verdict(
            replacing: range,
            replacementIsSingleNewline: replacement == "\n",
            segmentation: header?.effectiveSegmentation ?? .paragraph)
        switch verdict {
        case .refuse(.indexDesync):
            // The index no longer describes the storage: recover from the
            // store instead of crashing (review round 1, MINOR 7).
            pendingVerdict = nil
            desyncRecovery()
            return false
        case .refuse(.crossesBlockBoundary):
            // Phase 11, A9: the keystroke is refused HERE (the storage must
            // not half-apply it) and a compound reproduces its exact intent
            // through the structural door. Single×single → MERGE-THEN-EDIT
            // (ratified 2026-07-09: a cross-seam delete just works — the
            // halves join). A FANNED span → the VISIBLE-TAKE edit (the #11a
            // sitting ruling, 2026-07-13: each touched block's visible take
            // loses its piece; fan, seam, and structure untouched — the
            // ruled deviation: two blocks, NOT a join). Locked/gap/tail
            // spans keep the speaking refusal.
            pendingVerdict = nil
            if let compound = planCrossBlockEdit(range: range, replacement: replacement) {
                scheduleCrossBlockCompound { [weak self] in
                    await self?.runCrossBlockEdit(compound)
                }
            } else if let visible = planVisibleTakeEdit(range: range, replacement: replacement) {
                scheduleCrossBlockCompound { [weak self] in
                    await self?.runVisibleTakeEdit(visible)
                }
            } else {
                refuseFeedback(message(for: .crossesBlockBoundary))
            }
            return false
        case .refuse(let refusal):
            pendingVerdict = nil
            refuseFeedback(message(for: refusal))
            return false
        default:
            // Bulk entry is a TAIL concept only: a paste routed into an
            // existing block is a content edit of that block, and a refused
            // paste must not arm anything (review round 1, MAJOR 3).
            if case .tail = verdict, textView?.isPasting == true {
                bulkPending = true
            }
            pendingVerdict = verdict
            return true
        }
    }

    /// The exact-changed-range report (NSTextStorage didProcessEditing,
    /// characters only). `editedRange` is the NEW characters' range; the old
    /// length is `editedRange.length - delta`.
    func storageDidEdit(_ editedRange: NSRange, changeInLength delta: Int) {
        guard !suppressEditProcessing else { return }
        let verdict = pendingVerdict ?? fallbackVerdict(editedRange: editedRange, delta: delta)
        pendingVerdict = nil
        switch verdict {
        case .block(let i):
            index.applyBlockEdit(at: i, lengthDelta: delta)
            setBlockAttribute(index.entries[i].blockID, over: editedRange)
            recordAutosave(entryIndex: i, editedRange: editedRange, delta: delta)
        case .tail:
            index.applyTailEdit(lengthDelta: delta)
            setBlockAttribute(nil, over: editedRange)
            syncTailText()
            crystallizeIfNeeded()
            armTailIdleMint()
        case .openTail:
            index.openTail()
            setBlockAttribute(nil, over: editedRange)
            tailText = ""
        case .closeTail:
            index.closeTail()
            tailText = ""
            tailIdleTask?.cancel()
        case .refuse:
            // An edit reached the storage without a routable verdict (an
            // AppKit path outside the policed ones). The store is truth:
            // drop local bookkeeping and re-render from the projection.
            desyncRecovery()
        }
        updateCaretContext()
    }

    private func fallbackVerdict(editedRange: NSRange, delta: Int) -> BlockRangeIndex.Verdict {
        // The index still describes the PRE-edit document here.
        let oldRange = NSRange(location: editedRange.location, length: editedRange.length - delta)
        guard oldRange.length >= 0, oldRange.upperBound <= index.documentLength else {
            return .refuse(.crossesBlockBoundary)
        }
        return index.verdict(
            replacing: oldRange,
            replacementIsSingleNewline: false,
            segmentation: header?.effectiveSegmentation ?? .paragraph)
    }

    private func recordAutosave(entryIndex: Int, editedRange: NSRange, delta: Int) {
        let entry = index.entries[entryIndex]
        guard let variantID = entry.variantID else {
            assertionFailure("editable entry without a variant")
            return
        }
        let text = viewText(index.range(ofEntryAt: entryIndex))
        // The edited block's surface truth, for echo detection (Step 1):
        // this extraction is O(the edited block) and already paid for the
        // autosave itself.
        surfaceTextByVariant[variantID] = text
        let oldLength = editedRange.length - delta
        autosave.record(
            variantID: variantID, text: text,
            charDelta: oldLength + editedRange.length)
    }

    private func desyncRecovery() {
        desyncRecoveryCount += 1  // the Step 8 soak asserts this stays 0
        assertionFailure("editor surface desynced from the block index")
        forceFullRender = true
        pendingVerdict = nil
        Task { [weak self] in
            guard let self else { return }
            await autosave.flushNow()
            if let fresh = try? await session.database.read({ [postID] in
                try Queries.renderPost($0, containerID: postID)
            }) {
                applyProjection(fresh)
            }
        }
    }

    // MARK: - Crystallization (AppSpec §7 segmentation trigger)

    /// Re-arms the idle-mint clock after tail activity (author decision
    /// 2026-07-06: the open tail crystallizes after a short quiet gap, so
    /// crash loss is bounded to seconds; teardown remains the backstop).
    private func armTailIdleMint() {
        tailIdleTask?.cancel()
        guard hasOpenTail, !tailText.allSatisfy(\.isWhitespace) else { return }
        tailIdleTask = Task { [weak self, tailIdleSleep, tailIdleDebounce] in
            guard (try? await tailIdleSleep(tailIdleDebounce)) != nil else { return }
            guard !Task.isCancelled else { return }
            self?.idleMintTail()
        }
    }

    /// The idle-mint itself — internal so tests can fire it deterministically.
    /// Typing granularity is paragraph in EVERY mode (author ruling): the
    /// whole tail mints, trailing partial paragraph included, tail closes.
    func idleMintTail() {
        guard hasOpenTail, !tailText.allSatisfy(\.isWhitespace) else { return }
        // A structural gesture is mid-flight (Phase 9 review round 1,
        // MAJOR): a mint born now races the gesture's fetch/rewrite — the
        // mint's row failing the seam shape guard would materialize the
        // minted block AND the unconsumed tail (visible duplication), and
        // the late finishMint would crystallize a duplicate index entry.
        // Skip this tick and re-arm; the flight's defer re-arms too.
        if structuralInFlight {
            armTailIdleMint()
            return
        }
        // Marked text is an in-progress input-method composition, not yet
        // the author's text (review round 2): minting under it would rewrite
        // the region mid-composition. Skip this tick and re-arm the clock.
        if textView?.hasMarkedText() == true {
            armTailIdleMint()
            return
        }
        let mode = header?.effectiveSegmentation ?? .paragraph
        // The .idle kind (round 1, MAJOR 2): the durability mint must never
        // collapse a pending typed gap — the trailing run survives.
        crystallizeIfNeeded(forcedKind: mode == .oneBlock ? .oneBlock : .idle(.paragraph))
    }

    /// The leading-run attachment (author ruling 2026-07-12; Phase 10
    /// review round 1, MAJOR 2's fix): a tail that STARTS with newlines
    /// sits after a preceding block — under the ruling those newlines are
    /// that block's trailing CONTENT (the k−1 rule; the tail separator is
    /// the +1). The surface BYTES never change: the block's range grows
    /// over the run, the separator conceptually slides to the run's end,
    /// and the store follows through an ordinary autosave (read from the
    /// Step-1 surface-text map, so this works even when the view is
    /// already gone at teardown). Fires when the .idle mint leaves its
    /// kept-open run behind AND when Enters land in a reopened tail — a
    /// typed gap is durable content the moment it exists, successor or
    /// not (the "like any normal editor" behavior the author named).
    private func attachLeadingTailRunIfNeeded() {
        guard !structuralInFlight, !mintInFlight, hasOpenTail else { return }
        guard let last = index.entries.indices.last,
              index.entries[last].editable,
              let variantID = index.entries[last].variantID,
              let knownText = surfaceTextByVariant[variantID]
        else { return }
        let run = tailText.prefix(while: { $0 == "\n" }).count
        guard run > 0 else { return }
        let oldRange = index.range(ofEntryAt: last)
        index.transferTailPrefixToLastEntry(run)
        // Ownership moves; bytes don't: the block-ID attribute grows over
        // the old separator position + run−1 tail newlines.
        setBlockAttribute(
            index.entries[last].blockID,
            over: NSRange(location: oldRange.upperBound, length: run))
        tailText = String(tailText.dropFirst(run))
        let newText = knownText + String(repeating: "\n", count: run)
        surfaceTextByVariant[variantID] = newText
        autosave.record(variantID: variantID, text: newText, charDelta: run)
    }

    private func crystallizeIfNeeded(forcedKind: CrystallizationPlanner.Kind? = nil) {
        // While a mint is in flight, keep `bulkPending` ARMED (review round
        // 1, MAJOR 3): finishMint re-runs this and the paste-during-mint
        // still gets bulk semantics.
        guard !mintInFlight else { return }
        attachLeadingTailRunIfNeeded()
        guard hasOpenTail else {
            bulkPending = false
            return
        }
        let mode = header?.effectiveSegmentation ?? .paragraph
        let kind: CrystallizationPlanner.Kind = forcedKind
            ?? (bulkPending ? .bulk(mode) : (mode == .oneBlock ? .oneBlock : .typing))
        guard let plan = CrystallizationPlanner.plan(kind, tail: tailText) else {
            if forcedKind == nil { bulkPending = false } // consumed: nothing to mint
            return
        }
        // Any plan covers the whole current tail — the flag is consumed.
        bulkPending = false
        mintInFlight = true
        let post = postID
        // Strong self (review round 1, MINOR 5): the reconciliation must run
        // even if the view goes away mid-flight — the task completes in
        // milliseconds and the VM is freed after.
        mintTask = Task { [session] in
            do {
                let minted = try await session.runner.run { ops in
                    try plan.mints.map { text -> CrystallizationReconciler.MintedBlock in
                        let result = try ops.newBlock(in: post, text: text, at: .end)
                        return .init(
                            blockID: result.block.id,
                            variantID: result.variant.id,
                            text: text)
                    }
                }
                self.finishMint(minted, kind: kind)
            } catch {
                self.mintInFlight = false
                self.showOperationError(error)
                self.applyPendingIfClean()
            }
        }
    }

    private func finishMint(_ minted: [CrystallizationReconciler.MintedBlock], kind: CrystallizationPlanner.Kind) {
        mintInFlight = false
        let outcome = CrystallizationReconciler.reconcile(
            minted: minted, currentTail: tailText, kind: kind)

        // Store follow-ups (review round 1, MINOR 6):
        // - Corrections go through the autosave coordinator, so `isDirty`
        //   covers the window until they land (no clobber-then-heal gap)
        //   and a refusal rides the coordinator's keep-pending posture.
        // - Compensating deletions are internal bookkeeping, not an author
        //   gesture: they run through an undo-stack-FREE Operations so
        //   ⌥⌘Z never offers an inverse for something she never did.
        for correction in outcome.corrections {
            surfaceTextByVariant[correction.variantID] = correction.text
            autosave.record(
                variantID: correction.variantID,
                text: correction.text,
                charDelta: correction.text.utf16.count)
        }
        if !outcome.corrections.isEmpty {
            Task { await self.autosave.flushNow() }
        }
        if !outcome.deletions.isEmpty {
            let deletions = outcome.deletions
            Task { [session] in
                do {
                    try await session.runner.run { _ in
                        let quiet = Operations() // no undo stack, same store
                        for blockID in deletions {
                            try quiet.deleteBlock(blockID)
                        }
                    }
                } catch {
                    self.showOperationError(error)
                }
            }
        }
        if outcome.needsFullRerender {
            forceFullRender = true
        }
        guard !outcome.applied.isEmpty else {
            applyPendingIfClean()
            return
        }

        // View + index application for the applied prefix.
        guard let region = index.tailRange else {
            forceFullRender = true
            applyPendingIfClean()
            return
        }
        var normalized = outcome.applied.map(\.text).joined(separator: EditorDocument.separator)
        if let newTail = outcome.newTail {
            normalized += EditorDocument.separator + newTail
        }
        if normalized != tailText {
            programmaticReplace(region, with: normalized, blockID: nil, caretToEndIfWasAtEnd: true)
            textView?.undoManager?.removeAllActions()
        }
        for block in outcome.applied {
            surfaceTextByVariant[block.variantID] = block.text
        }
        index.crystallize(
            minted: outcome.applied.map { ($0.blockID, $0.variantID, $0.text.utf16.count) },
            remainingTailLength: outcome.newTail?.utf16.count)
        tailText = outcome.newTail ?? ""
        let firstNew = index.entries.count - outcome.applied.count
        for (offset, block) in outcome.applied.enumerated() {
            let range = index.range(ofEntryAt: firstNew + offset)
            if range.length > 0 {
                setBlockAttribute(block.blockID, over: range)
            }
        }
        updateCaretContext()
        // New paragraphs may have completed during the flight — and a
        // paste-during-mint's still-armed bulk flag is honored here.
        crystallizeIfNeeded()
        // Whatever tail remains restarts the idle-mint clock.
        armTailIdleMint()
        applyPendingIfClean()
    }

    // MARK: - Structural gestures (Phase 9)

    /// The planner's snapshot of the live surface. `textAt` reads the view
    /// (the buffer is authoritative while dirty), lazily — enablement costs
    /// one block's text per recompute, never the document (P1). `slots` may
    /// briefly lag `index.entries` during a mint window; the planner reads
    /// missing arities as 1, which is exactly what a fresh mint is.
    func gestureWorld() -> StructuralGesturePlanner.World {
        StructuralGesturePlanner.World(
            index: index,
            fanArities: slots.map(\.activeVariantCount),
            sealed: header?.locked == true,
            textAt: { [weak self] i in
                guard let self, i >= 0, i < index.entries.count else { return "" }
                return viewText(index.range(ofEntryAt: i))
            })
    }

    // The three doors' entry points (menu bar, context menu, shortcut all
    // land here; enablement used the same planner call).
    func divideAtCursor() { performGesture(.divideAtCursor) }
    func extractSelection() { performGesture(.extractSelection) }
    func makeBlockFromSelection() { performGesture(.makeBlockFromSelection) }
    func mergeBlocks() { performGesture(.mergeBlocks) }

    private func performGesture(_ command: StructuralGesturePlanner.Command) {
        Task { await invokeGesture(command) }
    }

    /// Plans against the CURRENT selection and applies — the invoke re-plans
    /// even when a menu's enablement said yes (enablement can go stale under
    /// a remote seal/lock; the refusal then surfaces here, never silently).
    func invokeGesture(_ command: StructuralGesturePlanner.Command) async {
        guard let textView else { return }
        let plan = StructuralGesturePlanner.plan(
            command, selection: textView.selectedRange(), world: gestureWorld())
        await applyStructural(plan)
    }

    /// THE one door for structural changes to the surface (plan ground
    /// rule): every gesture funnels through here; nothing else rewrites the
    /// editor for a structural result. The store leads — the surface is
    /// never pre-written optimistically; the rewrite renders the operation's
    /// known outcome, and the observation's later arrival is our own echo
    /// (`surfaceMatches` skips it).
    func applyStructural(_ plan: StructuralGesturePlanner.Plan) async {
        guard !structuralInFlight else {
            refuseFeedback("Another structural change is still landing.")
            return
        }
        switch plan {
        case .refusal(let refusal):
            refuseFeedback(RefusalCopy.message(for: refusal))

        case .divideW(_, let blockID, let activeCut):
            // Contract item 3: the W ceremony is ONE sheet; the live editor
            // is untouched for its whole duration. Opening touches no rows —
            // confirm funnels back through this door.
            await openDivideWCeremony(blockID: blockID, activeCut: activeCut)

        case .divide(let i, let blockID, let cut):
            // Snap-and-proceed, visibly (contract item 2): the caret lands
            // on the snapped cut as part of the one invoke.
            visiblySnap(NSRange(location: index.range(ofEntryAt: i).location + cut, length: 0))
            _ = await runStructural { ops in
                let result = try ops.divide(blockID, cut: cut)
                return StructuralOutcome(
                    caretBlockID: result.block.id, caretOffset: 0,  // the successor's start
                    seam: .divide(entryIndex: i, sourceID: blockID, successorID: result.block.id))
            }

        case .extract(let i, let blockID, let span, let edge, let otherTakes):
            let base = index.range(ofEntryAt: i).location
            visiblySnap(NSRange(location: base + span.lowerBound, length: span.count))
            let landed = await runStructural { ops in
                let result = try ops.extract(blockID, span: span)
                return StructuralOutcome(
                    caretBlockID: result.block.id, caretOffset: 0,  // the extracted block's start
                    seam: .extract(entryIndex: i, edge: edge,
                                   sourceID: blockID, extractedID: result.block.id))
            }
            if landed, otherTakes > 0 {
                // Contract item 8: passive, self-dismissing, never modal.
                showTransientStatus(
                    otherTakes == 1
                        ? "This block has 1 other take — it keeps this span."
                        : "This block has \(otherTakes) other takes — they keep this span.")
            }

        case .makeBlock(let i, let blockID, let span):
            // Contract item 5: two divides as ONE undoable action —
            // UndoStack.withCompound folds their inverses into one entry
            // (atomic on partial failure), inside one serialized runner body.
            let entryRange = index.range(ofEntryAt: i)
            visiblySnap(NSRange(location: entryRange.location + span.lowerBound, length: span.count))
            let entryLength = entryRange.length
            let stack = session.undoStack
            _ = await runStructural { ops in
                try stack.withCompound(label: "Make Block", operations: ops) {
                    let first = try ops.divide(blockID, cut: span.lowerBound)
                    // The span's end, mapped into the successor: the
                    // successor lost `span.lowerBound` units plus whatever
                    // leading whitespace the seam trim dropped — derived
                    // from the op's actual output, never re-guessed.
                    let dropped = (entryLength - span.lowerBound)
                        - first.variant.workingText.utf16.count
                    let second = try ops.divide(first.block.id, cut: span.count - dropped)
                    return StructuralOutcome(
                        caretBlockID: first.block.id, caretOffset: 0,  // the middle block's start
                        seam: .makeBlock(entryIndex: i, sourceID: blockID,
                                         middleID: first.block.id, suffixID: second.block.id))
                }
            }

        case .merge(let leadingIndex, let trailingIndex, let leadingID, let trailingID):
            let trailingLength = index.entries[trailingIndex].length
            // #11c (the sitting ruling, 2026-07-13): merge on fanned blocks
            // SPEAKS about what it does to the fan.
            let otherTakes = mergedAwayTakes([leadingIndex, trailingIndex])
            let landed = await runStructural { ops in
                let result = try ops.merge(leadingID, trailingID)
                // Caret at the join: right where the trailing half begins.
                let join = max(0, result.variant.workingText.utf16.count - trailingLength)
                return StructuralOutcome(
                    caretBlockID: result.block.id, caretOffset: join,
                    seam: .merge(leadingIndex: leadingIndex, mergedID: result.block.id))
            }
            if landed { speakAboutMergedFans(otherTakes) }

        case .makeBlockAcrossBlocks(let indices, let blockIDs, let startCut, let endCut):
            // Phase 11, A9 (the guided flow — the v1 refusal becomes a
            // CONFIRM, never a silent act): opening touches no rows; the
            // confirm funnels into `confirmCrossBlockMakeBlock`.
            crossBlockMakeConfirm = CrossBlockMakeState(
                entryIndices: indices, blockIDs: blockIDs,
                startCut: startCut, endCut: endCut)

        case .mergeChain(let indices, let blockIDs):
            // N-way merge (author 2026-07-09, supersedes the binary rule):
            // a left-to-right chain of the existing binary merges under ONE
            // undo entry (withCompound, the Make Block pattern). A deliberate
            // multi-block act takes the full-render door (seam: nil) — the
            // differential seam edit stays the binary merge's.
            let leadingLength = index.entries[indices.lowerBound].length
            let chainOtherTakes = mergedAwayTakes(Array(indices))
            let stack = session.undoStack
            let chainLanded = await runStructural { ops in
                try stack.withCompound(label: "Merge Blocks", operations: ops) {
                    var mergedID = blockIDs[0]
                    var mergedLength = 0
                    for nextID in blockIDs.dropFirst() {
                        let result = try ops.merge(mergedID, nextID)
                        mergedID = result.block.id
                        mergedLength = result.variant.workingText.utf16.count
                    }
                    // Caret at the FIRST join (merge keeps the leading text
                    // verbatim, so the leading length still addresses it).
                    return StructuralOutcome(
                        caretBlockID: mergedID,
                        caretOffset: min(leadingLength, mergedLength),
                        seam: nil)
                }
            }
            if chainLanded { speakAboutMergedFans(chainOtherTakes) }
        }
    }

    /// #11c: how many OTHER takes the merged sources carry — they stay
    /// with the released blocks in lineage (merge's standing semantics),
    /// and the gesture says so instead of silently folding a fan away.
    private func mergedAwayTakes(_ entryIndices: [Int]) -> Int {
        entryIndices.reduce(0) { total, i in
            guard i < slots.count else { return total }
            return total + max(0, slots[i].activeVariantCount - 1)
        }
    }

    private func speakAboutMergedFans(_ otherTakes: Int) {
        guard otherTakes > 0 else { return }
        showTransientStatus(
            otherTakes == 1
                ? "Merged the visible takes — 1 other take stays with the released block in lineage (undo brings it back here)."
                : "Merged the visible takes — \(otherTakes) other takes stay with the released blocks in lineage (undo brings them back here).")
    }

    /// What a structural operation reports back to the rewrite path: where
    /// the caret belongs (by identity) and the op's known seam shape — the
    /// differential strategy's input. `seam == nil` means full re-render
    /// (the W ceremony's confirm; author decision 2026-07-07: ceremonial
    /// acts rebuild from the store, permanently).
    struct StructuralOutcome: Sendable {
        let caretBlockID: String
        let caretOffset: Int
        let seam: StructuralSeam?
    }

    // MARK: - Phase 11, A9: the boundary-fluidity package (committed scope)

    /// The guided cross-block Make Block's confirm state (the ratified
    /// flow: confirm → adjust the neighbor edges → compound divide/divide/
    /// merge under ONE undo entry).
    struct CrossBlockMakeState: Identifiable, Equatable {
        let entryIndices: ClosedRange<Int>
        let blockIDs: [String]
        let startCut: Int
        let endCut: Int
        var id: String { blockIDs.joined(separator: "+") }
        var blockCount: Int { blockIDs.count }
    }

    var crossBlockMakeConfirm: CrossBlockMakeState?

    /// The deferred keystroke-compound's handle (#11a/merge-then-edit):
    /// the keystroke is refused synchronously and the compound runs as the
    /// next main-actor turn — this seam CHAINS overlapping schedules and
    /// lets teardown/tests await quiescence. Execution is compare-and-set
    /// against the plan-time texts (`editTakesAtomically`'s expectedText /
    /// the merge compound's verification pass), so a keystroke landing in
    /// the scheduling window makes the compound REFUSE VISIBLY instead of
    /// clobbering newer text — the edit-during-await class, closed at the
    /// op boundary.
    @ObservationIgnored private(set) var pendingCrossBlockTask: Task<Void, Never>?

    private func scheduleCrossBlockCompound(_ body: @escaping @MainActor () async -> Void) {
        let previous = pendingCrossBlockTask
        pendingCrossBlockTask = Task { @MainActor in
            if let previous { await previous.value }
            await body()
        }
    }

    /// The confirm's executor: divide the FIRST block at the snapped start
    /// (its head stays out), divide the LAST at the snapped end (its tail
    /// stays out), merge every in-span piece left-to-right — ONE compound
    /// undo entry (the Make Block pattern), atomic on partial failure,
    /// through the one structural door (full re-render — a deliberate
    /// multi-block act, the mergeChain precedent).
    ///
    /// FANNED divided edges (the #10 sitting ruling, 2026-07-13):
    /// AUTO-PROCEED when the edge's cut maps UNIQUELY into every active
    /// take (CutPropagation — the same seeds the W ceremony uses); the
    /// edge divides through `divideW` with the mapped cuts, so the
    /// out-of-span half keeps its per-take fan while the in-span half
    /// joins the (single-variant) middle by merge's standing semantics.
    /// Where ANY take doesn't map uniquely, the W CEREMONY OPENS for that
    /// block instead — the sheet survives exactly where a genuine per-take
    /// decision exists; never a refusal, never a guess.
    func confirmCrossBlockMakeBlock(_ state: CrossBlockMakeState) async {
        crossBlockMakeConfirm = nil
        guard state.entryIndices.upperBound < index.entries.count else {
            refuseFeedback(RefusalCopy.message(for: .invalidSelection))
            return
        }
        let firstIndex = state.entryIndices.lowerBound
        let lastIndex = state.entryIndices.upperBound
        let firstLength = index.entries[firstIndex].length
        let lastLength = index.entries[lastIndex].length
        let firstArity = firstIndex < slots.count ? slots[firstIndex].activeVariantCount : 1
        let lastArity = lastIndex < slots.count ? slots[lastIndex].activeVariantCount : 1

        // The mapping reads STORE texts, so the buffer lands first (the
        // runStructural discipline, pulled ahead of the read — runStructural
        // flushes again, harmlessly).
        await autosave.flushNow()
        guard !autosave.isDirty else {
            showStatus("Unsaved changes couldn't be written — resolve that first, then retry.")
            return
        }
        var firstCuts: [String: Int]?
        if state.startCut > 0, state.startCut < firstLength, firstArity > 1 {
            guard let cuts = await propagatedCuts(
                blockID: state.blockIDs[0], activeCut: state.startCut)
            else { return }  // the ceremony opened, or the error surfaced
            firstCuts = cuts
        }
        var lastCuts: [String: Int]?
        if state.blockIDs.count > 1, state.endCut > 0, state.endCut < lastLength, lastArity > 1 {
            guard let cuts = await propagatedCuts(
                blockID: state.blockIDs[state.blockIDs.count - 1], activeCut: state.endCut)
            else { return }
            lastCuts = cuts
        }

        let stack = session.undoStack
        let frozenFirstCuts = firstCuts
        let frozenLastCuts = lastCuts
        _ = await runStructural { ops in
            try stack.withCompound(label: "Make Block", operations: ops) {
                var pieces: [String] = []
                if state.startCut > 0, state.startCut < firstLength {
                    if let firstCuts = frozenFirstCuts {
                        // Fanned edge, unique matches everywhere: W-divide —
                        // B stays out with the first-half fan; C (the
                        // second halves) is the in-span piece.
                        pieces.append(try ops.divideW(state.blockIDs[0], cuts: firstCuts).second.block.id)
                    } else {
                        // The successor carries the in-span head; the first
                        // block keeps its out-of-span text and identity.
                        pieces.append(try ops.divide(state.blockIDs[0], cut: state.startCut).block.id)
                    }
                } else if state.startCut == 0 {
                    pieces.append(state.blockIDs[0])
                }  // startCut == firstLength: the first block stays out entirely
                pieces.append(contentsOf: state.blockIDs.dropFirst().dropLast())
                if state.blockIDs.count > 1 {
                    let lastID = state.blockIDs[state.blockIDs.count - 1]
                    if state.endCut > 0, state.endCut < lastLength {
                        if let lastCuts = frozenLastCuts {
                            // Fanned edge: B (the first halves) is the
                            // in-span piece; C stays out with its fan.
                            pieces.append(try ops.divideW(lastID, cuts: lastCuts).first.block.id)
                        } else {
                            // The last block keeps its in-span head; the
                            // minted successor carries the out-of-span tail.
                            _ = try ops.divide(lastID, cut: state.endCut)
                            pieces.append(lastID)
                        }
                    } else if state.endCut >= lastLength {
                        pieces.append(lastID)
                    }  // endCut == 0: the last block stays out entirely
                }
                var mergedID = pieces[0]
                for next in pieces.dropFirst() {
                    mergedID = try ops.merge(mergedID, next).block.id
                }
                return StructuralOutcome(caretBlockID: mergedID, caretOffset: 0, seam: nil)
            }
        }
    }

    /// The #10 auto-proceed's mapping: the active take's cut carried into
    /// EVERY other active take by CutPropagation's unique-match (the same
    /// discipline that pre-seeds the W ceremony). Returns nil after either
    /// OPENING THE CEREMONY (some take didn't map — the per-take decision
    /// is genuinely a human's; guidance shown) or surfacing a read error.
    private func propagatedCuts(blockID: String, activeCut: Int) async -> [String: Int]? {
        do {
            let fan = try await session.database.read { db in
                try Queries.blockFan(db, blockID: blockID)
            }
            let active = fan.filter { $0.status == .active }
            guard let renderedID = index.entries.first(where: { $0.blockID == blockID })?.variantID,
                  let rendered = active.first(where: { $0.id == renderedID })
            else {
                refuseFeedback(RefusalCopy.message(for: .invalidSelection))
                return nil
            }
            var cuts: [String: Int] = [renderedID: activeCut]
            for take in active where take.id != renderedID {
                guard let mapped = CutPropagation.propose(
                    activeCut: activeCut,
                    activeText: rendered.workingText,
                    targetText: take.workingText)
                else {
                    await openDivideWCeremony(blockID: blockID, activeCut: activeCut)
                    showTransientStatus(
                        "One of this block's takes needs its cut placed by hand — "
                        + "finish the take ceremony, then run Make Block from Selection again.")
                    return nil
                }
                cuts[take.id] = mapped
            }
            return cuts
        } catch {
            showOperationError(error)
            return nil
        }
    }

    /// A cross-block DESTRUCTIVE EDIT on single-variant blocks (the
    /// author's ratified 2026-07-09 direction — "a cross-seam delete just
    /// works"): the refused keystroke becomes a MERGE-THEN-EDIT compound.
    /// Nil = not eligible — a FANNED span takes the VISIBLE-TAKE edit
    /// instead (the #11a sitting ruling, 2026-07-13); locked/gap/tail
    /// spans keep the speaking refusal.
    struct CrossBlockEdit: Sendable, Equatable {
        let blockIDs: [String]
        /// The touched blocks' rendered variants + their PLAN-TIME surface
        /// texts — the compound's compare-and-set inputs (a buffer that
        /// moved since planning refuses the whole compound, visibly).
        let pieces: [(variantID: String, text: String)]
        /// The edit's start, intra the FIRST block (merge preserves the
        /// leading text verbatim, so this addresses the merged text too).
        let intraStart: Int
        /// The edit's end, intra the LAST block.
        let intraEndInLast: Int

        static func == (lhs: CrossBlockEdit, rhs: CrossBlockEdit) -> Bool {
            lhs.blockIDs == rhs.blockIDs
                && lhs.pieces.elementsEqual(rhs.pieces, by: ==)
                && lhs.intraStart == rhs.intraStart
                && lhs.intraEndInLast == rhs.intraEndInLast
                && lhs.lastPieceLength == rhs.lastPieceLength
                && lhs.replacement == rhs.replacement
        }
        /// The last block's surface length at plan time (locates the tail
        /// suffix in the merged text — derived from op output, never
        /// re-guessed).
        let lastPieceLength: Int
        let replacement: String
    }

    func planCrossBlockEdit(range: NSRange, replacement: String) -> CrossBlockEdit? {
        let entries = index.entries
        var touched: [Int] = []
        for i in entries.indices {
            let entryRange = index.range(ofEntryAt: i)
            if NSIntersectionRange(range, entryRange).length > 0
                || (range.length == 0 && range.location >= entryRange.location
                    && range.location <= entryRange.upperBound) {
                touched.append(i)
            }
        }
        guard touched.count >= 2, let first = touched.first, let last = touched.last else {
            return nil
        }
        // Contiguity + no tail: the range must sit inside the touched run.
        guard range.location >= index.range(ofEntryAt: first).location,
              range.upperBound <= index.range(ofEntryAt: last).upperBound
        else { return nil }
        for i in touched {
            guard entries[i].variantID != nil, entries[i].editable else { return nil }
            // The fanned case is deliberately OPEN (#11): not eligible.
            guard i < slots.count, slots[i].activeVariantCount == 1 else { return nil }
        }
        let firstRange = index.range(ofEntryAt: first)
        let lastRange = index.range(ofEntryAt: last)
        return CrossBlockEdit(
            blockIDs: touched.map { entries[$0].blockID },
            pieces: touched.map {
                (entries[$0].variantID!, viewText(index.range(ofEntryAt: $0)))
            },
            intraStart: max(0, range.location - firstRange.location),
            intraEndInLast: min(lastRange.length, max(0, range.upperBound - lastRange.location)),
            lastPieceLength: lastRange.length,
            replacement: replacement)
    }

    /// The compound itself: merge the touched run left-to-right, then apply
    /// the intended edit to the merged buffer — ONE undo compound, one
    /// serialized runner body, through the one structural door. The mapped
    /// range's ends live in the verbatim-preserved leading/trailing pieces,
    /// so the join characters merge minted die with the deleted span — the
    /// surface reads exactly "the selection vanished" (her principle: text
    /// that looks like basic text behaves like basic text).
    func runCrossBlockEdit(_ edit: CrossBlockEdit) async {
        let stack = session.undoStack
        _ = await runStructural { ops in
            try stack.withCompound(label: "Merge & Edit", operations: ops) {
                // COMPARE-AND-SET first (the edit-during-await guard): a
                // no-op TakeEdit with expectedText is a pure verification —
                // any buffer that moved since planning refuses the whole
                // compound before a single row changes. (The remaining
                // verify→merge gap inside this ONE serialized runner body
                // is the recorded ms-window sync-apply residual, the W
                // drift check's class.)
                _ = try ops.editTakesAtomically(
                    edit.pieces.map {
                        Operations.TakeEdit(
                            variantID: $0.variantID, newText: $0.text,
                            charDelta: 0, expectedText: $0.text)
                    },
                    undoLabel: "Merge & Edit")
                var mergedID = edit.blockIDs[0]
                var mergedVariantID: String?
                var mergedText = ""
                for next in edit.blockIDs.dropFirst() {
                    let result = try ops.merge(mergedID, next)
                    mergedID = result.block.id
                    mergedVariantID = result.variant.id
                    mergedText = result.variant.workingText
                }
                guard let variantID = mergedVariantID else {
                    throw OperationError.blockNotFound(id: mergedID)
                }
                let merged = mergedText as NSString
                let start = edit.intraStart
                let end = merged.length - (edit.lastPieceLength - edit.intraEndInLast)
                guard start >= 0, end >= start, end <= merged.length else {
                    throw OperationError.invalidCut(variantID: variantID, cut: start)
                }
                let replaced = NSRange(location: start, length: end - start)
                let newText = merged.replacingCharacters(in: replaced, with: edit.replacement)
                let cost = replaced.length + (edit.replacement as NSString).length
                try ops.autosave(variantID, text: newText, charDelta: cost)
                return StructuralOutcome(
                    caretBlockID: mergedID,
                    caretOffset: start + (edit.replacement as NSString).length,
                    seam: nil)
            }
        }
    }

    // MARK: - Phase 11, A9 — the #11 sitting rulings (2026-07-13)

    /// #11a — the VISIBLE-TAKE cross-block edit: the plain gesture's
    /// everyday behavior on a FANNED span (supersedes the shipped refusal).
    /// Each touched block's VISIBLE take loses exactly its piece of the
    /// selection (the replacement, if any, lands where typing started —
    /// the first block's cut point); fan, seam, and block structure stay
    /// UNTOUCHED — the ruled deviation from basic text: the result is two
    /// blocks, NOT a join; the fan hangs on the seam. Never guesses:
    /// nothing is touched in unseen takes.
    struct VisibleTakeEdit: Sendable, Equatable {
        struct Piece: Sendable, Equatable {
            let variantID: String
            /// The piece's intra-take range in the take's CURRENT text.
            let intraRange: NSRange
            /// The take's surface text at plan time (flushed = store text).
            let text: String
        }
        let pieces: [Piece]
        let replacement: String
        /// Caret identity after the compound.
        let caretBlockID: String
        let caretOffset: Int
    }

    /// Nil = not eligible (gap/locked visible take, tail overlap, or a
    /// single-block range) — the remaining refusal speaks.
    func planVisibleTakeEdit(range: NSRange, replacement: String) -> VisibleTakeEdit? {
        let entries = index.entries
        var touched: [Int] = []
        for i in entries.indices {
            let entryRange = index.range(ofEntryAt: i)
            if NSIntersectionRange(range, entryRange).length > 0 {
                touched.append(i)
            }
        }
        guard touched.count >= 2, let first = touched.first, let last = touched.last else {
            return nil
        }
        guard range.location >= index.range(ofEntryAt: first).location,
              range.upperBound <= index.range(ofEntryAt: last).upperBound
        else { return nil }
        var pieces: [VisibleTakeEdit.Piece] = []
        for (position, i) in touched.enumerated() {
            guard let variantID = entries[i].variantID, entries[i].editable else { return nil }
            let entryRange = index.range(ofEntryAt: i)
            let intersection = NSIntersectionRange(range, entryRange)
            let intraRange = NSRange(
                location: intersection.location - entryRange.location,
                length: intersection.length)
            // The replacement (if any) rides the FIRST piece.
            _ = position
            pieces.append(VisibleTakeEdit.Piece(
                variantID: variantID,
                intraRange: intraRange,
                text: viewText(entryRange)))
        }
        return VisibleTakeEdit(
            pieces: pieces,
            replacement: replacement,
            caretBlockID: entries[first].blockID,
            caretOffset: max(0, range.location - index.range(ofEntryAt: first).location)
                + (replacement as NSString).length)
    }

    /// The compound: ONE `editTakesAtomically` (one transaction, one undo
    /// entry, dirty targets insurance-committed) through the structural
    /// door — the flush-first fence keeps a pending autosave of the
    /// pre-delete surface from resurrecting the deleted span.
    func runVisibleTakeEdit(_ edit: VisibleTakeEdit) async {
        _ = await runStructural { ops in
            var edits: [Operations.TakeEdit] = []
            for (i, piece) in edit.pieces.enumerated() {
                let text = piece.text as NSString
                guard piece.intraRange.upperBound <= text.length else {
                    throw OperationError.invalidCut(
                        variantID: piece.variantID, cut: piece.intraRange.location)
                }
                let replacement = i == 0 ? edit.replacement : ""
                let newText = text.replacingCharacters(in: piece.intraRange, with: replacement)
                edits.append(Operations.TakeEdit(
                    variantID: piece.variantID,
                    newText: newText,
                    charDelta: piece.intraRange.length + (replacement as NSString).length,
                    expectedText: piece.text))
            }
            _ = try ops.editTakesAtomically(edits, undoLabel: "Delete Across Blocks")
            return StructuralOutcome(
                caretBlockID: edit.caretBlockID, caretOffset: edit.caretOffset, seam: nil)
        }
    }

    /// #11b — "Delete in Every Take": the deliberate, NAMED command. The
    /// selection's per-block piece (the visible take's text) is located in
    /// every OTHER active take by UNIQUE match (the #10 discipline — one
    /// occurrence or nothing); matching takes are edited, non-matching
    /// takes are SKIPPED AND REPORTED (her explicit call over
    /// refuse-unless-all-match); locked takes skip with their own reason.
    /// One transaction, one undo compound, insurance-committed.
    func deleteInEveryTake() async {
        guard header?.locked != true else {
            refuseFeedback("This post is sealed — unlock it to edit.")
            return
        }
        guard let selection = textView?.selectedRange(), selection.length > 0 else {
            refuseFeedback("Select the text to delete in every take first.")
            return
        }
        // No tail: the open tail is not a block yet.
        let entries = index.entries
        var touched: [Int] = []
        for i in entries.indices {
            let entryRange = index.range(ofEntryAt: i)
            if NSIntersectionRange(selection, entryRange).length > 0 { touched.append(i) }
        }
        guard let first = touched.first, let last = touched.last,
              selection.location >= index.range(ofEntryAt: first).location,
              selection.upperBound <= index.range(ofEntryAt: last).upperBound
        else {
            refuseFeedback(RefusalCopy.message(for: .openTailTarget))
            return
        }
        struct Target {
            let blockID: String
            let renderedID: String
            let intraRange: NSRange
            let renderedText: String
        }
        var targets: [Target] = []
        for i in touched {
            guard let variantID = entries[i].variantID, entries[i].editable else {
                refuseFeedback(message(for: .crossesBlockBoundary))
                return
            }
            let entryRange = index.range(ofEntryAt: i)
            let intersection = NSIntersectionRange(selection, entryRange)
            targets.append(Target(
                blockID: entries[i].blockID,
                renderedID: variantID,
                intraRange: NSRange(
                    location: intersection.location - entryRange.location,
                    length: intersection.length),
                renderedText: viewText(entryRange)))
        }

        await autosave.flushNow()
        guard !autosave.isDirty else {
            showStatus("Unsaved changes couldn't be written — resolve that first, then retry.")
            return
        }
        // The per-take locate happens against STORE texts (== the flushed
        // surface); skips collect for the visible report.
        var edits: [Operations.TakeEdit] = []
        var applied = 0
        var skipped: [String] = []
        do {
            for target in targets {
                let fan = try await session.database.read { db in
                    try Queries.blockFan(db, blockID: target.blockID)
                }
                let needle = (target.renderedText as NSString)
                    .substring(with: target.intraRange)
                for take in fan where take.deletedAt == nil && take.status == .active {
                    if take.id == target.renderedID {
                        let text = target.renderedText as NSString
                        edits.append(Operations.TakeEdit(
                            variantID: take.id,
                            newText: text.replacingCharacters(in: target.intraRange, with: ""),
                            charDelta: target.intraRange.length,
                            expectedText: target.renderedText))
                        applied += 1
                        continue
                    }
                    if take.locked {
                        skipped.append(takeName(take) + " (locked)")
                        continue
                    }
                    if let range = TakeSpanMatch.uniqueRange(of: needle, in: take.workingText) {
                        let text = take.workingText as NSString
                        edits.append(Operations.TakeEdit(
                            variantID: take.id,
                            newText: text.replacingCharacters(in: range, with: ""),
                            charDelta: range.length,
                            expectedText: take.workingText))
                        applied += 1
                    } else {
                        skipped.append(takeName(take) + " (no unique match)")
                    }
                }
            }
        } catch {
            showOperationError(error)
            return
        }
        let allEdits = edits
        let caretBlockID = targets[0].blockID
        let caretOffset = targets[0].intraRange.location
        let landed = await runStructural { ops in
            _ = try ops.editTakesAtomically(allEdits, undoLabel: "Delete in Every Take")
            return StructuralOutcome(
                caretBlockID: caretBlockID,
                caretOffset: caretOffset,
                seam: nil)
        }
        if landed {
            // The REPORT is part of the ruling: visible, naming what was
            // skipped — applied-and-reported over refuse-unless-all-match.
            var message = "Deleted in \(applied) take\(applied == 1 ? "" : "s")."
            if !skipped.isEmpty {
                message += " Skipped \(skipped.count): \(skipped.joined(separator: ", "))."
            }
            showStatus(message)
        }
    }

    private func takeName(_ take: Variant) -> String {
        if let label = take.label, !label.isEmpty { return "“\(label)”" }
        let preview = take.workingText.prefix(20)
        return preview.isEmpty ? "an empty take" : "“\(preview)…”"
    }

    // `StructuralSeam` lives beside its pure consumer in
    // StructuralSeamEdit.swift (review round 1, MINOR 5).

    /// Runs one structural operation through the runner and applies its
    /// outcome to the surface. Returns true when the operation landed.
    ///
    /// Discipline: the buffer flushes FIRST, so the store text the operation
    /// validates against equals the surface text the planner snapped
    /// against; the view is non-editable for the few-ms flight so no
    /// keystroke can slip between the flush and the operation (a stale
    /// whole-buffer autosave after a divide would resurrect the moved half —
    /// the forbidden text-duplication class).
    ///
    /// SELF-guarding (review round 3, MINOR): one flight at a time is
    /// enforced HERE, at the door itself, so every entrance — gestures via
    /// `applyStructural` AND the W ceremony's confirm — refuses while a
    /// flight is up. Overlapping flights would share the one
    /// `structuralInFlight` flag: the first finisher's defer would clear it
    /// and re-enable editing while the other was still between its op and
    /// its rewrite — reopening the keystroke window this fence closes.
    private func runStructural(
        _ body: @escaping @Sendable (Operations) throws -> StructuralOutcome
    ) async -> Bool {
        guard !structuralInFlight else {
            refuseFeedback("Another structural change is still landing.")
            return false
        }
        structuralInFlight = true
        // The idle-mint clock is held for the flight (review round 1,
        // MAJOR): a mint must never be born between the pre-op mint wait
        // and the rewrite. idleMintTail's own guard is the second door.
        tailIdleTask?.cancel()
        textView?.isEditable = false
        defer {
            structuralInFlight = false
            textView?.isEditable = header.map { !$0.locked } ?? false
            // Any surviving tail gets its clock back (arming is a no-op
            // when no non-blank tail exists).
            armTailIdleMint()
            // A projection deferred during the flight applies now (round 3
            // NIT: deliveries defer while a flight is up).
            applyPendingIfClean()
        }
        await autosave.flushNow()
        guard !autosave.isDirty else {
            // A refused flush keeps its text pending (Phase 7 MAJOR 1); a
            // structural op against a store that disagrees with the surface
            // must not run.
            showStatus("Unsaved changes couldn't be written — resolve that first, then retry.")
            return false
        }
        // An in-flight crystallization mint reconciles before the rewrite
        // (its tail bookkeeping must not land on a rewritten surface).
        while mintInFlight {
            if let mint = mintTask { await mint.value } else { await Task.yield() }
        }
        do {
            let outcome = try await session.runner.run(body)
            let fresh = try await session.database.read { [postID] in
                try Queries.renderPost($0, containerID: postID)
            }
            applyStructuralResult(fresh, outcome: outcome)
            return true
        } catch {
            showOperationError(error)
            return false
        }
    }

    /// The single structural rewrite path — TWO strategies behind the ONE
    /// door (author decision 2026-07-07, superseding the full-re-render
    /// PROVISIONAL): the everyday gestures apply DIFFERENTIALLY (minimal
    /// text edits derived from the op result's known seams — untouched text
    /// never moves, no scroll restore step exists at all); the W ceremony's
    /// confirm (seam == nil) and any seam whose expected shape the fresh
    /// projection doesn't match re-render fully from the store. Both
    /// strategies clear text-undo (stale-offset replays don't care which
    /// strategy rewrote) and place the caret BY IDENTITY.
    private func applyStructuralResult(
        _ fresh: [Queries.RenderedBlock], outcome: StructuralOutcome
    ) {
        if let seam = outcome.seam, applyDifferentialStructural(seam, fresh: fresh) {
            // Differential landed; bookkeeping done inside.
        } else {
            renderFull(fresh, preserveTail: true)
        }
        if let textView,
           let i = index.entries.firstIndex(where: { $0.blockID == outcome.caretBlockID }) {
            let range = index.range(ofEntryAt: i)
            let offset = range.location + min(max(0, outcome.caretOffset), range.length)
            textView.setSelectedRange(NSRange(location: offset, length: 0))
            updateCaretContext()
        }
        applyPendingIfClean()
    }

    // MARK: - The differential structural apply (author decision 2026-07-07)

    /// Applies the pure derivation's minimal edit to the storage (the
    /// derivation itself lives in `StructuralSeamEdit.derive` — review
    /// round 1, MINOR 5: pure computation out of the view model, so its
    /// guard fallbacks are directly testable). Returns false when the
    /// derivation refuses — the fresh projection doesn't match what the
    /// edit would assume (seam shape, non-seam geometry, or the retained
    /// bytes; a concurrent sync apply landed between the op and the fetch)
    /// — and the caller then re-renders fully from the store, truth, in
    /// EVERY build.
    private func applyDifferentialStructural(
        _ seam: StructuralSeam, fresh: [Queries.RenderedBlock]
    ) -> Bool {
        guard let textView, let storage = textView.textStorage else { return false }
        let edit = StructuralSeamEdit.derive(
            seam, oldIndex: index,
            oldTextAt: { [weak self] i in
                guard let self, i >= 0, i < index.entries.count else { return "" }
                return viewText(index.range(ofEntryAt: i))
            },
            fresh: fresh)
        guard let edit else { return false }

        // Apply: one storage edit, then the attribute re-bracketing.
        suppressEditProcessing = true
        storage.beginEditing()
        storage.replaceCharacters(in: edit.replaceRange, with: edit.replacement)
        storage.setAttributes(
            EditorDocument.baseAttributes,
            range: NSRange(
                location: edit.replaceRange.location,
                length: (edit.replacement as NSString).length))
        for run in edit.attributeRuns where run.range.length > 0 {
            if let blockID = run.blockID {
                storage.addAttribute(
                    EditorDocument.blockIDAttribute, value: blockID, range: run.range)
            } else {
                storage.removeAttribute(EditorDocument.blockIDAttribute, range: run.range)
            }
        }
        storage.endEditing()
        suppressEditProcessing = false

        // Adopt the fresh projection as the tiling truth (a value rebuild,
        // no surface cost — the store leads; nothing here was diffed).
        index = BlockRangeIndex(slots: fresh, tail: hasOpenTail ? tailText : nil)
        slots = fresh
        adoptSurfaceTextMap(fresh)
        // The directive: text-undo clears on EVERY structural rewrite —
        // offsets after the seam shifted; a stale replay is the corruption
        // class regardless of rewrite strategy.
        textView.undoManager?.removeAllActions()
        verifyDifferentialOracle(fresh)
        refreshBadges()
        return true
    }

    /// The DEBUG-ONLY oracle (author-directed posture): after every
    /// differential apply, the surface must equal the store's fresh
    /// projection — the soak exercising this with zero firings is the proof
    /// the differential lands safely. On a miss: count (test-visible),
    /// assert, heal via `renderFull`. NOTHING here compiles into release —
    /// there, a divergence that slipped the shape guard (a remote race
    /// changing the seam entry's text without changing shape) stands until
    /// the next projection delivery heals it, and that delivery is already
    /// in flight by construction: the same sync apply that caused the
    /// divergence fired the observation (review round 1, MINOR 3 — the
    /// release tripwire was considered and declined; disposition in the
    /// closeout).
    private func verifyDifferentialOracle(_ fresh: [Queries.RenderedBlock]) {
        #if DEBUG
        var matches = index.documentLength == (textView?.textStorage?.length ?? -1)
        if matches {
            for (j, slot) in fresh.enumerated() {
                if viewText(index.range(ofEntryAt: j)) != (slot.text ?? "") {
                    matches = false
                    break
                }
            }
        }
        guard !matches else { return }
        differentialOracleMisses += 1
        assertionFailure("differential structural apply diverged from the store projection")
        renderFull(fresh, preserveTail: true)
        #endif
    }

    /// Applies the one-shot focus-handoff seeds after the first render
    /// (Step 3): caret placement from the read-tier click, then the
    /// focus-then-fan panel where a badge tap drove the focus.
    private func applyFocusSeeds() {
        if let seed = pendingCaretSeed, let textView {
            pendingCaretSeed = nil
            let clamped = min(max(0, seed), max(0, index.documentLength))
            textView.setSelectedRange(NSRange(location: clamped, length: 0))
            textView.window?.makeFirstResponder(textView)
            updateCaretContext()
        }
        if let fanBlock = pendingFanSeed {
            pendingFanSeed = nil
            openFan(blockID: fanBlock)
        }
    }

    /// The visible snap (contract item 2): the selection moves to the
    /// snapped cut/span as part of the invoke — never silently, never as a
    /// separate confirm step.
    private func visiblySnap(_ range: NSRange) {
        textView?.setSelectedRange(range)
        updateCaretContext()
    }

    // MARK: - The W ceremony (Step 6, contract item 3)

    /// Builds the one-sheet ceremony state: the block's live ACTIVE fan as
    /// a checklist (the rendered take pre-marked with the gesture's snapped
    /// cut), per-take cut proposals by string-context matching, per-take
    /// legal cut positions. The buffer flushes first so every take's stored
    /// text — what the sheet shows and the op will cut — matches the
    /// surface. No rows are touched by opening.
    private func openDivideWCeremony(blockID: String, activeCut: Int) async {
        await autosave.flushNow()
        guard !autosave.isDirty else {
            showStatus("Unsaved changes couldn't be written — resolve that first, then retry.")
            return
        }
        let activeVariantID = index.entries.first { $0.blockID == blockID }?.variantID
        do {
            let fan = try await session.database.read { db in
                try Queries.blockFan(db, blockID: blockID)
            }
            let liveActive = fan.filter { $0.deletedAt == nil && $0.status == .active }
            guard liveActive.count > 1,
                  let activeTake = liveActive.first(where: { $0.id == activeVariantID })
            else {
                // The fan changed under us (sync race): re-plan next invoke.
                showStatus("This block's takes changed — try the divide again.")
                return
            }
            let takes = liveActive.map { variant in
                WTake(
                    variant: variant,
                    marked: variant.id == activeTake.id,
                    cut: variant.id == activeTake.id
                        ? activeCut
                        : CutPropagation.propose(
                            activeCut: activeCut,
                            activeText: activeTake.workingText,
                            targetText: variant.workingText),
                    boundaries: interiorBoundaries(of: variant.workingText))
            }
            divideWCeremony = DivideWCeremonyState(
                blockID: blockID, activeVariantID: activeTake.id, takes: takes)
        } catch {
            showOperationError(error)
        }
    }

    private func interiorBoundaries(of text: String) -> [Int] {
        let end = text.utf16.count
        return BoundarySnapping.boundaries(in: text, granularity: .sentence)
            .filter { $0 != 0 && $0 != end }
    }

    func toggleWTake(_ takeID: String) {
        guard var state = divideWCeremony,
              let i = state.takes.firstIndex(where: { $0.id == takeID }) else { return }
        state.takes[i].marked.toggle()
        divideWCeremony = state
    }

    func placeWCut(takeID: String, cut: Int) {
        guard var state = divideWCeremony,
              let i = state.takes.firstIndex(where: { $0.id == takeID }),
              state.takes[i].boundaries.contains(cut) else { return }
        state.takes[i].cut = cut
        divideWCeremony = state
    }

    /// Cancel does nothing — no rows were touched by the ceremony.
    func cancelDivideW() {
        divideWCeremony = nil
    }

    func confirmDivideW() {
        Task { await confirmDivideWCeremony() }
    }

    func confirmDivideWCeremony() async {
        guard let state = divideWCeremony, state.canConfirm else { return }
        // The one-flight door, checked synchronously BEFORE the drift
        // check's await (review round 3, MINOR): a gesture can be mid-
        // flight while the sheet is up (menu key equivalents stay live
        // under a window-modal sheet) — refuse visibly and KEEP the
        // ceremony and its cuts; `runStructural`'s own self-guard is the
        // belt behind this.
        guard !structuralInFlight else {
            refuseFeedback("Another structural change is still landing.")
            return
        }
        let cuts = state.markedCuts
        let blockID = state.blockID
        // The sheet may have sat open while a sync round landed edits to
        // the takes (review round 2, MINOR): cuts were placed against the
        // SNAPSHOT texts, and cutting the current store at those offsets
        // would land a well-formed but wrong-position cut, silently. Verify
        // every marked take against the CURRENT store first; on any drift,
        // refresh the ceremony (marks kept, cuts re-seeded) instead.
        do {
            let fan = try await session.database.read { db in
                try Queries.blockFan(db, blockID: blockID)
            }
            let liveActive = fan.filter { $0.deletedAt == nil && $0.status == .active }
            let drifted = state.takes.filter(\.marked).contains { snapshot in
                guard let current = liveActive.first(where: { $0.id == snapshot.id })
                else { return true }  // a marked take vanished (deleted/archived remotely)
                return current.workingText != snapshot.variant.workingText
            }
            if drifted {
                refreshDivideWCeremony(from: state, liveActive: liveActive)
                return
            }
        } catch {
            showOperationError(error)
            return
        }
        // Accepted residual (review round 3, NIT — same class as the
        // ceremony-open flush→fetch window): the drift check above is
        // check-then-act — a sync apply committing in the ms between that
        // read and the op below still lands a stale-offset cut. A true fix
        // needs op-level expected-text preconditions (a core change this
        // phase has no cause to make); the cut stays well-formed,
        // recoverable by undo, and the window is delivery-cadence narrow.
        // Recorded in the closeout's residuals.
        let landed = await runStructural { ops in
            let result = try ops.divideW(blockID, cuts: cuts)
            // seam nil: the W confirm re-renders fully from the store —
            // the permanent shape for ceremonial acts (author, 2026-07-07).
            return StructuralOutcome(
                caretBlockID: result.first.block.id, caretOffset: 0, seam: nil)
        }
        // The sheet dismisses only when the cut LANDED — a refusal (busy
        // door, op error) keeps the ceremony and its cuts for the author.
        if landed {
            divideWCeremony = nil
        }
    }

    /// Rebuilds the ceremony over the CURRENT fan: marks survive by take
    /// identity, unchanged takes keep their placed cuts, changed takes get
    /// re-seeded cuts (the active take's cut re-snapped into its new text;
    /// others re-proposed from it via string-context matching). The author
    /// reviews and confirms again — nothing is cut on a drifted snapshot.
    private func refreshDivideWCeremony(
        from state: DivideWCeremonyState, liveActive: [Variant]
    ) {
        guard liveActive.count > 1,
              let activeCurrent = liveActive.first(where: { $0.id == state.activeVariantID })
        else {
            // The fan itself dissolved (a single take remains, or the
            // rendered take died): the ceremony no longer applies.
            divideWCeremony = nil
            showStatus("This block's takes changed — try the divide again.")
            return
        }
        let previous = Dictionary(uniqueKeysWithValues: state.takes.map { ($0.id, $0) })
        let previousActive = previous[activeCurrent.id]
        let activeCut: Int? = {
            guard let cut = previousActive?.cut else { return nil }
            if previousActive?.variant.workingText == activeCurrent.workingText { return cut }
            return StructuralGesturePlanner.snapToInteriorBoundary(
                cut, in: activeCurrent.workingText)
        }()
        let takes = liveActive.map { variant -> WTake in
            let old = previous[variant.id]
            let cut: Int?
            if variant.id == activeCurrent.id {
                cut = activeCut
            } else if old?.variant.workingText == variant.workingText, let kept = old?.cut {
                cut = kept
            } else if let activeCut {
                cut = CutPropagation.propose(
                    activeCut: activeCut,
                    activeText: activeCurrent.workingText,
                    targetText: variant.workingText)
            } else {
                cut = nil
            }
            return WTake(
                variant: variant,
                marked: old?.marked ?? false,
                cut: cut,
                boundaries: interiorBoundaries(of: variant.workingText))
        }
        divideWCeremony = DivideWCeremonyState(
            blockID: state.blockID, activeVariantID: activeCurrent.id, takes: takes)
        showStatus("This block's takes changed while the sheet was open — the cuts were re-proposed; review before dividing.")
    }

    /// Context-menu items for the text view — the second door, same brain:
    /// each item's enablement is a fresh planner verdict at menu-build time.
    func contextMenuItems() -> [EditorTextView.StructuralMenuItem] {
        guard textView != nil else { return [] }
        // Doors fire and speak (author 2026-07-09, superseding the
        // disabled-door posture): items stay enabled; a refused invocation
        // surfaces its RefusalCopy through the one planning door instead of
        // being silently swallowed. The planner verdict still drives the
        // button bar's dimming (`gestureAvailability`).
        func item(
            _ title: String, _ command: StructuralGesturePlanner.Command
        ) -> EditorTextView.StructuralMenuItem {
            .init(title: title, enabled: true) { [weak self] in
                self?.performGesture(command)
            }
        }
        return [
            item("Divide Block at Cursor", .divideAtCursor),
            item("Extract Selection", .extractSelection),
            item("Make Block from Selection", .makeBlockFromSelection),
            item("Merge Blocks", .mergeBlocks),
            // #11b (the sitting ruling, 2026-07-13): the deliberate, NAMED
            // command — not a planner gesture (it edits takes, not
            // structure); fire-and-speak like every door.
            .init(title: "Delete in Every Take", enabled: true) { [weak self] in
                Task { await self?.deleteInEveryTake() }
            },
            .init(title: "Show Takes", enabled: true) { [weak self] in
                self?.openCaretFan()
            },
        ]
    }

    private func refreshGestureAvailability() {
        guard let textView, loaded else {
            if gestureAvailability != GestureAvailability() {
                gestureAvailability = GestureAvailability()
            }
            return
        }
        let selection = textView.selectedRange()
        let world = gestureWorld()
        func enabled(_ command: StructuralGesturePlanner.Command) -> Bool {
            if case .refusal = StructuralGesturePlanner.plan(
                command, selection: selection, world: world) { return false }
            return true
        }
        let fresh = GestureAvailability(
            divide: enabled(.divideAtCursor),
            extract: enabled(.extractSelection),
            makeBlock: enabled(.makeBlockFromSelection),
            merge: enabled(.mergeBlocks),
            takes: caretBlockID != nil)
        if fresh != gestureAvailability {
            gestureAvailability = fresh
        }
    }

    private func showTransientStatus(_ message: String) {
        statusMessage = message
        hintClearTask?.cancel()
        hintClearTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(6))
            guard !Task.isCancelled else { return }
            if self?.statusMessage == message { self?.statusMessage = nil }
        }
    }

    // MARK: - Post lifecycle faces (Phase 10 Step 8)

    /// The seal toggle (`lockPost`/`unlockPost` — brief item 4): sealing
    /// runs the FULL teardown contract first — flush, await any mint in
    /// flight, mint the residual open tail (`finalizeWork`) — so the seal
    /// freezes exactly what the surface shows (review round 1, MAJOR 1:
    /// the flush-only version left an open tail permanently unmintable
    /// under the seal — every later mint path hits the locked-container
    /// refusal, and the text existed nowhere in the store; "type the last
    /// line, click Seal" is the natural gesture, so the Phase 7
    /// "seconds-wide-rare" premise did not cover a same-surface seal
    /// button. The lock doctrine everywhere else is "the guard insures
    /// exactly what it protects").
    func toggleSeal() {
        Task {
            do {
                if header?.locked == true {
                    try await session.runner.run { [postID] ops in
                        try ops.unlockPost(postID)
                    }
                    showStatus("Unsealed.")
                } else {
                    await finalizeWork()?.value
                    // finishMint's corrections/attachments ride the
                    // autosave coordinator — land them before the freeze.
                    await autosave.flushNow()
                    try await session.runner.run { [postID] ops in
                        try ops.lockPost(postID)
                    }
                    showStatus("Sealed — the post is read-only until unsealed.")
                }
            } catch {
                showOperationError(error)
            }
        }
    }

    /// Mac-side entry-date editing (brief item 5 — `setEntryDate`'s first
    /// Mac face; the ops-boundary day-key guard enforces canon).
    func updateEntryDate(_ day: String?) async {
        do {
            try await session.runner.run { [postID] ops in
                try ops.setEntryDate(postID, entryDate: day)
            }
            showStatus(day.map { "Entry date set to \($0)." } ?? "Entry date cleared.")
        } catch {
            showOperationError(error)
        }
    }

    // MARK: - Pool drops (Phase 10 Step 7)

    /// A pool block dropped onto this editor: EXACTLY `poolDragCopy` —
    /// copy + lineage, never shared ownership (the pool's one export
    /// gesture; P stays in its pool). Returns whether the drop was
    /// consumed (a sealed post refuses visibly).
    func poolDrop(blockID: String, atOffset offset: Int, includeFan: Bool) -> Bool {
        guard header?.locked != true else {
            refuseFeedback("This post is sealed — unlock it to add to it.")
            return true  // consumed: never fall through to a text insert
        }
        let insert = insertPosition(forOffset: offset)
        let post = postID
        Task { [session] in
            do {
                _ = try await session.runner.run { ops in
                    try ops.poolDragCopy(
                        blockID, to: post, at: insert, includeFan: includeFan)
                }
                self.showStatus(includeFan
                    ? "Copied from the pool with its takes."
                    : "Copied from the pool.")
            } catch {
                self.showOperationError(error)
            }
        }
        return true
    }

    /// Maps a drop offset to a block-boundary insertion (drops land BETWEEN
    /// blocks — the nearer boundary of the block under the point; past the
    /// last block or into the tail region is the end).
    func insertPosition(forOffset offset: Int) -> Operations.InsertPosition {
        guard !index.entries.isEmpty else { return .end }
        var location = 0
        for entry in index.entries {
            let end = location + entry.length
            if offset <= end {
                let midpoint = location + entry.length / 2
                return offset <= midpoint ? .before(entry.blockID) : .after(entry.blockID)
            }
            location = end + 1
        }
        return .end
    }

    // MARK: - Commit + history (Step 5)

    func commitCaretVariant() {
        Task { await commitCaret() }
    }

    func commitCaret() async {
        guard let variantID = caretVariantID else {
            statusMessage = "Place the caret in a block to commit."
            return
        }
        await autosave.flushNow()
        do {
            _ = try await session.runner.run { ops in
                try ops.commit(variantID, kind: .manual)
            }
            statusMessage = "Committed."
            if commitList != nil { await loadCommitHistory() }
        } catch {
            showOperationError(error)
        }
    }

    func toggleCommitHistory() {
        if commitList != nil {
            commitList = nil
            commitListVariantID = nil
        } else {
            Task { await loadCommitHistory() }
        }
    }

    func loadCommitHistory() async {
        guard let variantID = caretVariantID, let blockID = caretBlockID else {
            statusMessage = "Place the caret in a block to see its history."
            return
        }
        do {
            let (commits, splits) = try await session.database.read { db in
                (try Queries.commitHistory(db, variantID: variantID),
                 try Queries.splitDates(db, blockID: blockID))
            }
            commitList = commits.map {
                CommitListItem(
                    commit: $0,
                    predatesSplit: CommitRules.predatesSplit(commitDate: $0.createdAt, splitDates: splits))
            }
            commitListVariantID = variantID
        } catch {
            statusMessage = "Could not load history: \(error)"
        }
    }

    /// Restore honors the documented pre-split warning (AppSpec §9,
    /// KnownIssues entry): a commit older than the newest divide/extract on
    /// this block resurrects pre-split text — confirm first. The target is
    /// the variant whose history is OPEN, not the caret's current position
    /// (the caret may have moved since — review round 1, NIT 12).
    func restore(_ item: CommitListItem, confirmed: Bool = false) {
        if item.predatesSplit && !confirmed {
            pendingRestore = item
            return
        }
        pendingRestore = nil
        guard let variantID = commitListVariantID else { return }
        Task {
            await autosave.flushNow()
            do {
                try await session.runner.run { ops in
                    try ops.restoreCommit(variantID, commitID: item.commit.id)
                }
                statusMessage = "Restored commit."
            } catch {
                showOperationError(error)
            }
        }
    }

    // MARK: - Fan (Step 6)

    /// The fan door for ANY block (9d — closes the first-branch
    /// chicken-and-egg: the badge opens fans, but only fanned blocks have a
    /// badge, so a block's FIRST branch had no door at all).
    func openCaretFan() {
        guard let blockID = caretBlockID else {
            showStatus("Place the caret in a block to see its takes.")
            return
        }
        openFan(blockID: blockID)
    }

    func openFan(blockID: String) {
        Task { await loadFan(blockID: blockID) }
    }

    /// The awaitable core of the fan door (split out in 9d so tests can
    /// await the panel deterministically).
    func loadFan(blockID: String) async {
        do {
            let variants = try await session.database.read { db in
                try Queries.blockFan(db, blockID: blockID)
            }
            let chosen = index.entries.first { $0.blockID == blockID }?.variantID
            fanPanel = FanPanelState(
                blockID: blockID, variants: variants, chosenVariantID: chosen)
        } catch {
            statusMessage = "Could not load the fan: \(error)"
        }
    }

    func fanAction(_ action: FanAction) {
        guard let panel = fanPanel else { return }
        let blockID = panel.blockID
        Task {
            await autosave.flushNow()
            do {
                try await session.runner.run { ops in
                    switch action {
                    case .branch(let sourceVariantID):
                        _ = try ops.branchVariant(blockID, from: sourceVariantID)
                    case .newBlank:
                        _ = try ops.newBlankVariant(blockID)
                    case .choose(let variantID):
                        try ops.chooseVariant(blockID, variantID: variantID)
                    case .archive(let variantID):
                        try ops.archiveVariant(variantID)
                    case .unarchive(let variantID):
                        try ops.unarchiveVariant(variantID)
                    case .delete(let variantID):
                        try ops.deleteVariant(variantID)
                    case .lock(let variantID):
                        try ops.lockVariant(variantID)
                    case .unlock(let variantID):
                        try ops.unlockVariant(variantID)
                    }
                }
                openFan(blockID: blockID) // refresh the panel
            } catch {
                showOperationError(error)
            }
        }
    }

    enum FanAction {
        case branch(from: String)
        case newBlank
        case choose(String)
        case archive(String)
        case unarchive(String)
        case delete(String)
        case lock(String)
        case unlock(String)
    }

    // MARK: - Caret + badges

    func updateCaretContext() {
        guard let textView else { return }
        let selection = textView.selectedRange()
        let caret = selection.location
        var location = 0
        caretBlockID = nil
        caretVariantID = nil
        caretOrdinal = nil
        caretBlockWordCount = nil
        blockCount = index.entries.count
        for (i, entry) in index.entries.enumerated() {
            if caret >= location, caret <= location + entry.length {
                caretBlockID = entry.blockID
                caretVariantID = entry.variantID
                // 9d: the user-facing block number — derived from current
                // order at read time, never stored (the stable ID remains
                // the identity; this is a handle for a human).
                caretOrdinal = i + 1
                caretBlockWordCount = TextMetrics.wordCount(
                    viewText(NSRange(location: location, length: entry.length)))
                break
            }
            location += entry.length + 1
        }
        // Selection word count: cost ∝ selection (P1's unit); the block
        // count above costs ∝ the caret block.
        selectionWordCount = selection.length > 0
            ? TextMetrics.wordCount(viewText(selection))
            : nil
        // Gesture enablement rides every caret/selection change — the menu
        // bar, context menu, and shortcuts read these planner verdicts
        // (one brain, three doors). Cost: the caret block's boundary scan.
        refreshGestureAvailability()
    }

    /// Badges for fanned blocks currently laid out near the viewport.
    /// Cost ∝ fanned blocks (fans are opt-in and rare) — no ensureLayout,
    /// unlaid-out blocks simply have no badge until scrolled to (P1).
    func refreshBadges() {
        defer { refreshTint() }  // 9d: the tint rides every badge refresh
                                 // trigger (scroll, layout, projection).
        guard let textView,
              let layoutManager = textView.textLayoutManager,
              let contentManager = layoutManager.textContentManager
        else {
            badges = []
            return
        }
        let visible = viewportBounds(of: textView)
        // Same container→view conversion as the tint (the Step 8 traced
        // mechanism): fragment frames are container-relative; the badge
        // buttons live in the view.
        let origin = textView.textContainerOrigin
        var result: [BlockBadge] = []
        for (i, slot) in slots.enumerated() where slot.hasFan {
            guard i < index.entries.count else { break }
            let range = index.range(ofEntryAt: i)
            guard let location = contentManager.location(
                contentManager.documentRange.location, offsetBy: range.location)
            else { continue }
            var frame: CGRect?
            layoutManager.enumerateTextLayoutFragments(from: location, options: []) { fragment in
                frame = fragment.layoutFragmentFrame
                return false
            }
            if let frame {
                let viewFrame = frame.offsetBy(dx: origin.x, dy: origin.y)
                if viewFrame.intersects(visible) {
                    result.append(BlockBadge(
                        blockID: slot.blockID,
                        variantCount: slot.activeVariantCount,
                        frame: viewFrame))
                }
            }
        }
        if result != badges {
            badges = result
            badgeSink?(result)
        }
    }

    /// 9d — "Show Blocks": per-block tint spans for the visible region.
    /// Viewport-proportional: the visible character window (the
    /// `topVisibleOffset` fragment idiom, both edges) prunes the entry walk
    /// to on-screen entries; each visible entry costs two single-fragment
    /// lookups (first and last fragment frames). Colors are stable per
    /// block ID with the never-adjacent rule (`BlockTint`).
    func refreshTint() {
        func send(_ spans: [BlockTintSpan]) {
            if spans != tintSpans {
                tintSpans = spans
                tintSink?(spans)
            }
        }
        guard blockTintEnabled, let textView, loaded,
              let layoutManager = textView.textLayoutManager,
              let contentManager = layoutManager.textContentManager,
              !index.entries.isEmpty
        else {
            send([])
            return
        }
        let visible = viewportBounds(of: textView)
        let docStart = contentManager.documentRange.location
        // TK2 fragment geometry is CONTAINER-relative; the viewport and the
        // overlay views are VIEW-relative — the container sits at the inset
        // origin (the traced Step 8 mis-registration: this conversion was
        // missing in both directions).
        let origin = textView.textContainerOrigin

        func offsetAt(y viewY: CGFloat) -> Int? {
            guard let fragment = layoutManager.textLayoutFragment(
                for: CGPoint(x: 4, y: max(0, viewY - origin.y))) else { return nil }
            return contentManager.offset(from: docStart, to: fragment.rangeInElement.location)
        }
        // Visible character window; generous fallbacks keep this correct
        // when a fragment lookup misses (blank area past the last line).
        let windowStart = offsetAt(y: visible.minY + 1) ?? 0
        let windowEnd = offsetAt(y: visible.maxY - 1)
            .map { min($0 + 1024, index.documentLength) } ?? index.documentLength

        func fragmentFrame(atOffset offset: Int) -> CGRect? {
            guard let location = contentManager.location(docStart, offsetBy: offset)
            else { return nil }
            var frame: CGRect?
            layoutManager.enumerateTextLayoutFragments(from: location, options: []) {
                frame = $0.layoutFragmentFrame
                return false
            }
            return frame
        }

        let colors = BlockTint.indices(for: index.entries.map(\.blockID))
        var spans: [BlockTintSpan] = []
        var location = 0
        for (i, entry) in index.entries.enumerated() {
            defer { location += entry.length + 1 }
            guard location + entry.length >= windowStart else { continue }
            guard location <= windowEnd else { break }
            guard let first = fragmentFrame(atOffset: location),
                  let last = fragmentFrame(atOffset: max(location, location + entry.length - 1))
            else { continue }
            // Container→view conversion at the ONE pure mapping (the
            // Step 8 fix; red-on-old pinned).
            let frame = BlockTint.viewRect(
                containerTop: min(first.minY, last.minY),
                containerBottom: max(first.maxY, last.maxY),
                containerOrigin: origin,
                viewWidth: textView.bounds.width)
            guard frame.intersects(visible) else { continue }
            spans.append(BlockTintSpan(entryIndex: i, colorIndex: colors[i], frame: frame))
        }
        send(spans)
    }

    // MARK: - Surface plumbing

    /// The overlay pruning region, in text-view coordinates: the owned
    /// scroll view's clip bounds for the detail editor (whose
    /// ScrollAnchorController re-runs the overlays on every scroll), else
    /// the WHOLE surface for the inline book-view editor. Inline
    /// deliberately does NOT prune to `visibleRect` (review round 1,
    /// MINOR 5): nothing re-fires the overlays when the CONTAINER scrolls,
    /// so viewport-pruned spans went stale — a fanned block scrolled into
    /// view showed no badge and tint stripes stopped at the attach-time
    /// viewport. Whole-post overlay work is the accepted inline cost model
    /// (the inline surface is laid out to content already; fans are rare;
    /// tint is an explicit mode) and makes staleness impossible instead of
    /// adding observers on SwiftUI's internal clip view.
    private func viewportBounds(of textView: EditorTextView) -> CGRect {
        if let scrollView { return scrollView.contentView.bounds }
        return textView.bounds
    }

    private func viewText(_ range: NSRange) -> String {
        surfaceTextReads += 1  // the Step 1 echo pin counts these
        guard let storage = textView?.textStorage else { return "" }
        guard range.upperBound <= storage.length else { return "" }
        return storage.attributedSubstring(from: range).string
    }

    private func syncTailText() {
        guard let range = index.tailRange else {
            tailText = ""
            return
        }
        tailText = viewText(range)
    }

    private func programmaticReplace(
        _ range: NSRange, with newText: String, blockID: String?,
        caretToEndIfWasAtEnd: Bool = false
    ) {
        guard let textView, let storage = textView.textStorage else { return }
        // Recover-not-crash (round 2 NIT, defense-in-depth): the read-side
        // siblings (`viewText`, `setBlockAttribute`) clamp against
        // `storage.length`, but this is the one path that MUTATES — an
        // out-of-tiling range raises an NSRangeException Swift cannot
        // catch. The live route here was a geometry desync (closed by the
        // round-2 non-seam guard); should any future path regress, heal
        // from the store instead of crashing.
        guard range.location >= 0, range.upperBound <= storage.length else {
            desyncRecovery()
            return
        }
        let caretWasAtEnd = textView.selectedRange().location >= storage.length
        suppressEditProcessing = true
        storage.beginEditing()
        storage.replaceCharacters(in: range, with: newText)
        var attributes = EditorDocument.baseAttributes
        if let blockID { attributes[EditorDocument.blockIDAttribute] = blockID }
        storage.setAttributes(
            attributes,
            range: NSRange(location: range.location, length: (newText as NSString).length))
        storage.endEditing()
        suppressEditProcessing = false
        if caretToEndIfWasAtEnd, caretWasAtEnd {
            textView.setSelectedRange(NSRange(location: storage.length, length: 0))
        }
    }

    private func setBlockAttribute(_ blockID: String?, over range: NSRange) {
        guard range.length > 0, let storage = textView?.textStorage,
              range.upperBound <= storage.length else { return }
        if let blockID {
            storage.addAttribute(EditorDocument.blockIDAttribute, value: blockID, range: range)
        } else {
            storage.removeAttribute(EditorDocument.blockIDAttribute, range: range)
        }
    }

    // MARK: - Scroll anchoring (Step 7; the memo's obligation)

    func topVisibleOffset() -> Int? {
        guard let textView, let scrollView, loaded,
              let layoutManager = textView.textLayoutManager,
              let contentManager = layoutManager.textContentManager
        else { return nil }
        let top = scrollView.contentView.bounds.origin.y
        let point = CGPoint(x: 4, y: top + 1)
        guard let fragment = layoutManager.textLayoutFragment(for: point) else { return nil }
        return contentManager.offset(
            from: contentManager.documentRange.location,
            to: fragment.rangeInElement.location)
    }

    func restoreTopVisibleOffset(_ offset: Int) {
        guard let textView else { return }
        JumpPrimitive.jump(
            toOffset: min(offset, max(0, index.documentLength)),
            textView: textView, scrollView: scrollView)
        refreshBadges()
    }

    // MARK: - Messages

    func showStatus(_ message: String) {
        statusMessage = message
    }

    private func refuseFeedback(_ message: String) {
        statusMessage = message
        NSSound.beep()
    }

    private func message(for refusal: BlockRangeIndex.Refusal) -> String {
        switch refusal {
        case .crossesBlockBoundary:
            // Reached only when NEITHER compound is eligible (Phase 11,
            // A9 + the #11a ruling): a locked take, a gap slot, or the
            // open tail inside the span.
            "This edit reaches a block that can’t take it right now (a locked take, unsynced text, or text that isn’t a block yet) — resolve that, or edit within one block."
        case .readOnlySlot:
            "This block hasn't fully synced; it is read-only for now."
        case .lockedVariant:
            "This take is locked — branch it or unlock it to edit."
        case .indexDesync:
            "The editor lost track of block boundaries — reloading from the store."
        }
    }

    private func showOperationError(_ error: Error) {
        statusMessage = operationMessage(error)
    }

    private func operationMessage(_ error: Error) -> String {
        guard let opError = error as? OperationError else {
            return "Operation failed: \(error)"
        }
        switch opError {
        case .lockedPost: return "This post is sealed — unlock it first."
        case .lockedVariant: return "This take is locked — branch or unlock it."
        case .lastActiveVariant:
            return "A block keeps at least one take — delete the block instead."
        case .variantIsChosen:
            return "This take is shown in the post — choose another take first."
        case .archivedVariant: return "This take is archived — unarchive it first."
        case .bufferChangedSinceGesture:
            return "The text changed while that gesture was landing — nothing was altered; try it again on the current text."
        default: return "The operation was refused: \(opError)"
        }
    }
}

/// Pure predicate behind the pre-split warning (tested in the app bundle).
nonisolated enum CommitRules {
    static func predatesSplit(commitDate: Date, splitDates: [Date]) -> Bool {
        guard let newest = splitDates.max() else { return false }
        return commitDate < newest
    }
}
