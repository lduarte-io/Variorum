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
//  13b Stage 3 (N10 — the recorded one-seam move): the gesture-execution
//  band and the projection executors live in `EditorSurfaceController`;
//  this class remains the STORAGE OWNER (composition, crystallization,
//  decoration/badge geometry, the surface plumbing) and forwards the
//  band's surface so every call site and pin reads unchanged.
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
        // 13b 1a (N3): the ONE per-post coordinator — shared with every
        // other surface editing this post (takes panel, TOC), so two
        // debounced pipelines can never race a stale flush over a newer
        // one. Callbacks are multicast observers (a shared coordinator has
        // several listeners); removed at teardown.
        self.autosave = session.autosave(forPost: postID)
        autosaveToken = autosave.observe(
            onError: { [weak self] error in self?.showOperationError(error) },
            onSettled: { [weak self] in self?.applyPendingIfClean() })
    }

    @ObservationIgnored private var autosaveToken: UUID?

    // MARK: - Observable UI state

    private(set) var header: Queries.ContainerHeader?
    private(set) var canaryMessage: String?
    /// The editor's transient outcome line. PRESENTATION is the shell's
    /// StatusCenter (13b 1b, AD-14 — one placement, one auto-dismiss
    /// policy); the property remains the tested truth and forwards on set.
    private(set) var statusMessage: String? {
        didSet {
            if let statusMessage { session.status.speak(statusMessage) }
        }
    }
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
    /// Phase 13 C1 (R11 — word-count prominence): the post's total,
    /// maintained INCREMENTALLY (per-variant cache in the LEDGER; only
    /// changed texts re-enumerate — cost ∝ the edit, the P1 unit; the
    /// caret block's live count adjusts the total between projections).
    private(set) var postWordCount: Int?
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
    /// sheet (contract item 3) — state OWNED by the surface controller
    /// (13b Stage 3, N10); forwarded so every view binding and pin reads
    /// unchanged.
    var divideWCeremony: DivideWCeremonyState? {
        get { structural.divideWCeremony }
        set { structural.divideWCeremony = newValue }
    }
    /// The merge ceremony's ONE sheet (13b Stage 4, Batch 4B — the W's
    /// mirror, S4-23): a merge landing on a fanned pair routes here.
    /// State OWNED by the surface controller; forwarded like the W's.
    var mergeCeremony: MergeCeremonyState? {
        get { structural.mergeCeremony }
        set { structural.mergeCeremony = newValue }
    }

    struct GestureAvailability: Equatable {
        var divide = false
        var extract = false
        var makeBlock = false
        var merge = false
        /// The fan door (9d): available wherever the caret is in a block —
        /// ANY arity (the badge stays fan-only; the door must not be).
        var takes = false
    }

    // The gesture band's state types moved to the surface controller
    // (13b Stage 3, N10); typealiases keep every `EditorViewModel.X`
    // reference — views (DivideWSheet, EditorView) and pins — unchanged.
    typealias DivideWCeremonyState = EditorSurfaceController.DivideWCeremonyState
    typealias WTake = EditorSurfaceController.WTake
    typealias MergeCeremonyState = EditorSurfaceController.MergeCeremonyState
    typealias MergeTake = EditorSurfaceController.MergeTake
    typealias MergePairingDraft = EditorSurfaceController.MergePairingDraft
    typealias StructuralOutcome = EditorSurfaceController.StructuralOutcome
    typealias CrossBlockMakeState = EditorSurfaceController.CrossBlockMakeState
    typealias CrossBlockEdit = EditorSurfaceController.CrossBlockEdit
    typealias VisibleTakeEdit = EditorSurfaceController.VisibleTakeEdit

    struct BlockBadge: Equatable, Identifiable {
        let blockID: String
        let variantCount: Int
        let frame: CGRect
        var id: String { blockID }
    }

    /// The AppKit badge overlay renders through this (overlay views, never
    /// rendering attributes — memo obligation).
    @ObservationIgnored var badgeSink: (([BlockBadge]) -> Void)?

    /// Phase 13 C1 — the decoration overlay feed (seams R6/R42, the
    /// editing indicator R14/R22, callouts R16/R17, comment faces R7, drag
    /// handles R19). The model computes visible-block geometry + context;
    /// `BlockDecorOverlayController` renders. Same overlay doctrine as the
    /// badges: views over the text, NEVER rendering attributes (TEXTKIT2
    /// §3 — the flaky path). Supersedes the 9d tint spans — that look is
    /// RETIRED (R6: "we shouldn't have all the blocks as different
    /// colors"); its toggle's face became seam visibility.
    @ObservationIgnored var decorSink: ((BlockDecor.State) -> Void)?
    @ObservationIgnored private var lastDecorState = BlockDecor.State()
    /// Theme context, pushed by the View (models never read environments).
    var appearance = EditorAppearance() {
        didSet { if oldValue != appearance { refreshDecorations() } }
    }
    /// Callout frames + comment briefs for this container, observed live
    /// (cost ∝ the post — the P1 unit).
    @ObservationIgnored private(set) var presentationsByBlock: [String: BlockPresentation] = [:]
    @ObservationIgnored private(set) var commentsByBlock: [String: [BlockDecor.CommentBrief]] = [:]
    /// The block whose comments panel is open (nil = closed).
    var commentsPanel: CommentsPanelState?

    struct CommentsPanelState: Equatable, Identifiable {
        let blockID: String
        var id: String { blockID }
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
    /// The store→surface rewrite door (13b Stage 3, N10): the structural
    /// gesture-execution band + the projection executors live in
    /// `EditorSurfaceController` — a sibling under the Editor feature,
    /// never the shared Registry layer (storage-coupled code stays
    /// feature-side). This class remains the storage owner; the controller
    /// reaches the storage only through the seam primitives below. Lazy so
    /// the composition can reference `self`.
    @ObservationIgnored private(set) lazy var structural = EditorSurfaceController(model: self)

    /// One structural gesture lands at a time (Phase 9) — the flight flag
    /// is the controller's; forwarded so pins stage mid-flight
    /// interleavings unchanged.
    var structuralInFlight: Bool { structural.structuralInFlight }
    /// Times `desyncRecovery` has fired this session — the Step 8 soak
    /// asserts ZERO (store == index == surface through every interleaving).
    @ObservationIgnored private(set) var desyncRecoveryCount = 0
    /// The surface-text truth per variant + word-count cache — the
    /// LEDGER (13b 1a, T3 slice: the echo-detection map moved into
    /// `EditorSurfaceLedger`, pure and unit-tested; the semantics are the
    /// Phase 10 Step 1 fix's, unchanged — echo detection never reads the
    /// surface).
    @ObservationIgnored private var ledger = EditorSurfaceLedger()
    /// Surface text extractions (`viewText` calls), test-visible: the echo
    /// pin asserts a projection echo performs ZERO of these (red on the old
    /// per-slot-extraction path).
    @ObservationIgnored private(set) var surfaceTextReads = 0
    /// Times the differential-apply DEBUG oracle found the surface diverged
    /// from the store projection — the soak asserts ZERO. The counter is
    /// the controller's; forwarded for the pins.
    var differentialOracleMisses: Int { structural.differentialOracleMisses }
    /// Clears a transient hint (the fanned-extract hint) after a beat.
    @ObservationIgnored private var hintClearTask: Task<Void, Never>?
    /// 13c 1E (memo Q3, option E — PROVISIONAL, QUESTIONS #39): the
    /// phantom fix's per-surface state. The whole concern — the cap, the
    /// once-per-block bound, the kill switch, the scan — lives in
    /// `LongBlockLayout.swift`; this is its one stored home.
    @ObservationIgnored var longBlockLayout = LongBlockLayoutState()
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
        // N14: a fresh surface is a fresh geometry world — whatever the
        // overlays computed against the old one is stale until this view's
        // first layout pass delivers real frames.
        overlayGeometryGeneration &+= 1
        textView.onLayoutSettle = { [weak self] in self?.overlayLayoutDidSettle() }
        // MINOR-2 (Stage 3 ladder round 1): a width reflow is a geometry
        // event with NO storage edit — and TK2's lazy invalidation means
        // no display pass is guaranteed to report it either, so the width
        // handler both bumps the generation AND schedules the same
        // coalesced delivery directly (the delivered/scheduled guards
        // make a riding draw-pass report a no-op; delivery stays on the
        // next runloop turn, after this cycle's remeasure has laid the
        // new width out).
        textView.onWidthReflow = { [weak self] in
            guard let self else { return }
            overlayGeometryGeneration &+= 1
            overlayLayoutDidSettle()
        }
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

    /// Runs for the editor's lifetime: header + slots + decorations, live.
    func start() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.observeHeader() }
            group.addTask { await self.observeSlots() }
            group.addTask { await self.observePresentations() }
            group.addTask { await self.observeComments() }
        }
    }

    private func observePresentations() async {
        do {
            for try await value in session.database.observe({ [postID] db in
                try Queries.blockPresentations(db, containerID: postID)
            }) {
                adoptPresentations(value)
            }
        } catch is CancellationError {
        } catch {
            statusMessage = "Presentation observation failed: \(error)"
        }
    }

    private func observeComments() async {
        do {
            for try await value in session.database.observe({ [postID] db in
                try Queries.containerComments(db, containerID: postID).mapValues { comments in
                    comments.map { BlockDecor.CommentBrief(id: $0.id, text: $0.text) }
                }
            }) {
                adoptComments(value)
            }
        } catch is CancellationError {
        } catch {
            statusMessage = "Comment observation failed: \(error)"
        }
    }

    /// Internal so tests can drive decoration context without observations.
    func adoptPresentations(_ value: [String: BlockPresentation]) {
        presentationsByBlock = value
        refreshDecorations()
    }

    func adoptComments(_ value: [String: [BlockDecor.CommentBrief]]) {
        commentsByBlock = value
        refreshDecorations()
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
        // 13c 1E: the phantom fix's debounce dies with the surface it was
        // measuring (its geometry world goes with the text view).
        longBlockLayout.task?.cancel()
        // The shared coordinator outlives this surface — detach the
        // observers (finalizeWork below still flushes it directly).
        if let autosaveToken {
            autosave.stopObserving(autosaveToken)
            self.autosaveToken = nil
        }
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
        // Round 2, MINOR 4: a scheduled cross-block compound is pending
        // WORK the dirty flags cannot see (its triggering keystroke was
        // REFUSED, so nothing is dirty) — quit/teardown must let it land
        // or the gesture is silently un-applied.
        guard autosave.isDirty || mintInFlight || hasTailText
            || pendingCrossBlockTask != nil
        else { return nil }
        return Task { // strong self, deliberately
            if let pending = self.pendingCrossBlockTask {
                await pending.value
            }
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
    /// The DECISION lives in `EditorProjectionPolicy` (13b 1a — the
    /// precedence order is pinned as pure code); this executes it.
    func applyProjection(_ new: [Queries.RenderedBlock]) {
        guard textView != nil else {
            pendingProjection = new
            return
        }
        let decision = EditorProjectionPolicy.decide(
            loaded: loaded,
            // The buffer is authoritative while dirty; defer until clean.
            // A structural flight defers too (round 3 NIT): a delivery
            // rewriting the surface mid-flight is geometry-safe
            // post-round-2 but would clear text-undo and double-rewrite
            // under the gesture — the flight's exit applies the deferred
            // value through the settle machinery.
            busy: autosave.isDirty || mintInFlight || structuralInFlight,
            forceFull: forceFullRender,
            matchesSurface: ledger.matches(new, entries: index.entries),
            sameSequence: new.map(\.blockID) == index.entries.map(\.blockID))
        switch decision {
        case .initialRender:
            // First render: there is no local tail yet — the pre-load
            // index is a placeholder, never a tail to preserve.
            structural.renderFull(new, preserveTail: false)
            loaded = true
            applyFocusSeeds()
        case .deferUntilClean:
            pendingProjection = new
        case .forcedFullRender:
            forceFullRender = false
            structural.renderFull(new, preserveTail: true)
        case .adoptEcho:
            // Our own autosave echo (or metadata-only movement): adopt the
            // projection for badge/fan data, touch nothing in the view.
            slots = new
            adoptSurfaceTextMap(new)
            refreshBadges()
        case .differential:
            structural.applyDifferential(new)
        case .fullRender:
            structural.renderFull(new, preserveTail: true)
        }
    }

    /// Adopts `new` as the known surface text per variant — called wherever
    /// the surface is (re)written from a projection, so the ledger always
    /// describes what the view actually shows.
    private func adoptSurfaceTextMap(_ new: [Queries.RenderedBlock]) {
        ledger.adopt(new)
        publishPostWordCount()
    }

    /// The total = the CURRENT slots' cached counts (stale variants fall
    /// out naturally; gaps count nothing). O(blocks) per call.
    private func publishPostWordCount() {
        let total = ledger.totalWords(over: slots)
        if postWordCount != total { postWordCount = total }
    }

    // The projection EXECUTORS (`renderFull` / `applyDifferential`) live in
    // `EditorSurfaceController` (13b Stage 3, N10 — moved TOGETHER with the
    // gesture band, the recorded one-seam move). The controller writes the
    // storage and the tiling truth ONLY through the seam primitives below.

    // MARK: - The controller's storage seam (13b Stage 3, N10)

    /// Whole-surface replacement with edit processing suppressed — the
    /// full-render primitive (the storage owner keeps its plumbing).
    func setSurfaceContent(_ attributed: NSAttributedString) {
        guard let storage = textView?.textStorage else { return }
        suppressEditProcessing = true
        storage.setAttributedString(attributed)
        suppressEditProcessing = false
    }

    /// One derived seam edit + its attribute re-bracketing, suppressed —
    /// the differential-structural primitive (the derivation stays the
    /// controller's; the bytes move here).
    func applySeamEdit(_ edit: StructuralSeamEdit.Edit) {
        guard let textView, let storage = textView.textStorage else { return }
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
    }

    /// The controller's ONE write door for the tiling truth: index + slots
    /// (+ the tail where a full render sets it), with the surface-text
    /// ledger adopted in the same breath — the original executors' exact
    /// write order. `tailText: nil` leaves the tail untouched (the
    /// differential paths).
    func adoptRewrite(
        index: BlockRangeIndex, slots: [Queries.RenderedBlock], tailText: String?
    ) {
        self.index = index
        self.slots = slots
        adoptSurfaceTextMap(slots)
        if let tailText { self.tailText = tailText }
    }

    /// Holds the idle-mint clock for a structural flight (re-arm via
    /// `armTailIdleMint` at flight end).
    func holdTailIdleClock() {
        tailIdleTask?.cancel()
    }

    /// Awaits an in-flight crystallization mint's reconciliation (the
    /// pre-rewrite fence — its tail bookkeeping must not land on a
    /// rewritten surface).
    func awaitMintSettle() async {
        while mintInFlight {
            if let mint = mintTask { await mint.value } else { await Task.yield() }
        }
    }

    /// Internal (was private) since N10: the controller's flight exit and
    /// rewrite paths settle deferred projections through it.
    func applyPendingIfClean() {
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
        // 13d batch 4 (A15, ruled option B): a SOFT newline — ⇧⏎ — never
        // opens the tail. `replacementIsSingleNewline` has exactly ONE
        // consumer (the open-tail gesture), so withholding it here is the
        // whole of B1: at the exact document end the verdict falls through
        // containment to `.block(last)` and the newline becomes the last
        // block's content, caret inside it. Every other context is
        // unchanged by construction — mid-block, tail-interior and
        // `one_block` never consult the parameter at all.
        let softNewline = replacement == "\n" && textView?.isSoftNewline == true
        let verdict = index.verdict(
            replacing: range,
            replacementIsSingleNewline: replacement == "\n" && !softNewline,
            segmentation: header?.effectiveSegmentation ?? .paragraph)
        // B2: inside an OPEN tail there is no block to stay in yet, so the
        // tail becomes one first — the ratified idle-mint, fired ~2 s early
        // (her ruling accepts the keystroke-visible boundary) — and the
        // newline then lands in the block that just became, AT THE
        // KEYSTROKE'S OWN OFFSET (13d cold review F-1: the mint changes no
        // surface byte, so the caret's position survives it — a mid-tail
        // ⇧⏎ lands its newline at the caret, never at the document end).
        // A tail with nothing mintable (the never-mints whitespace class)
        // takes the ordinary path below, where the leading-run attachment
        // already makes a tail newline the preceding block's content.
        if softNewline, case .tail = verdict, mintableTail {
            let location = range.location
            scheduleCrossBlockCompound { [weak self] in
                await self?.runSoftNewlineInTail(at: location)
            }
            return false
        }
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
            // 13c 1B (A7): the empty-block carve runs FIRST — its range is
            // exactly one separator, which touches no entry at all, so the
            // two plans below can never see it (pinned). Deleting an EMPTY
            // block is the one case where the cross-block refusal buys
            // nothing: there is no text to lose.
            if let empty = planEmptyBlockDeletion(range: range, replacement: replacement) {
                scheduleCrossBlockCompound { [weak self] in
                    await self?.runEmptyBlockDeletion(empty)
                }
            } else if let seam = planSeamMerge(range: range, replacement: replacement) {
                // 13d batch 2 (#34, her ruling (ii)): the same range shape,
                // with TEXT on both sides — backspace joins the paragraphs
                // when neither block has takes, and says why when either
                // does. Mutually exclusive with the carve above (one needs an
                // empty neighbour, this needs neither) and invisible to the
                // two plans below (both collect by intersection, and a lone
                // separator intersects nothing) — pinned.
                scheduleCrossBlockCompound { [weak self] in
                    await self?.runSeamMerge(seam)
                }
            } else if let compound = planCrossBlockEdit(range: range, replacement: replacement) {
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
        // N14: EVERY storage character edit dirties overlay geometry — the
        // suppressed programmatic writes included (renderFull's
        // setSurfaceContent is exactly the cold-mount path). The refresh
        // itself waits for the layout pass that consumes the edit
        // (`overlayLayoutDidSettle`), never runs against pre-layout frames.
        overlayGeometryGeneration &+= 1
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
        ledger.recordEdit(variantID: variantID, text: text)
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
    /// Internal (was private) since N10: the controller's flight exit
    /// re-arms it.
    func armTailIdleMint() {
        tailIdleTask?.cancel()
        guard hasOpenTail, !tailText.allSatisfy(\.isWhitespace) else { return }
        tailIdleTask = Task { [weak self, tailIdleSleep, tailIdleDebounce] in
            guard (try? await tailIdleSleep(tailIdleDebounce)) != nil else { return }
            guard !Task.isCancelled else { return }
            self?.idleMintTail()
        }
    }

    /// Whether the open tail holds anything the ratified rules would mint —
    /// the SAME guard `idleMintTail` and `finalizeWork` apply (a
    /// whitespace-only tail never mints). Read by A15's B2 fork so the two
    /// can never disagree about what "mintable" means.
    var mintableTail: Bool {
        hasOpenTail && !tailText.allSatisfy(\.isWhitespace)
    }

    /// 13d batch 4 (A15, ruled option B, rider 1): ⇧⏎ inside an open tail.
    ///
    /// The mint is `idleMintTail()` ITSELF — the very call the 2 s clock
    /// makes — never a re-implementation, so the whole ratified mint story
    /// rides free and stays pinned where it always was: the trailing
    /// partial paragraph is included, a whitespace-only tail never mints,
    /// the in-flight/marked-text skips still apply, and resumed typing
    /// extends the result. Then the newline is re-played AT THE
    /// KEYSTROKE'S OWN OFFSET through the ORDINARY editing path with the
    /// soft flag raised, so it reaches exactly the verdict the keystroke
    /// would have reached had the tail not been in the way — the mint
    /// converts the tail to a block without moving a surface byte, so the
    /// caret's offset survives it (13d cold review F-1: re-playing at the
    /// document END instead displaced a mid-tail ⇧⏎'s newline — and her
    /// caret — past everything she had typed after it).
    ///
    /// Where the mint closed the tail that verdict is `.block(…)` and the
    /// newline is block content immediately, at the caret. Where the mint
    /// kept a newline run open (a tail that already ended in blank lines —
    /// the k−1 rule) and the offset sits in that run, the re-play is an
    /// ordinary `.tail` edit and the standing leading-run attachment folds
    /// it into the preceding block instead; both roads end with the
    /// newline as block content, which is the contract.
    ///
    /// The one degradation, recorded rather than papered over (wording
    /// corrected at the 13d cold review, F-7): if `idleMintTail` SKIPS
    /// this tick (a structural gesture in flight, or an IME composition
    /// open — it re-arms the clock instead), the re-play finds the tail
    /// still open and mintable and RE-ENTERS the B2 fork, so the newline
    /// is re-scheduled — a bounded retry chained through the cross-block
    /// compound queue that lands the moment the mint stops skipping,
    /// never a plain-⏎ tail insertion. Rare, self-terminating, and the
    /// honest alternative would be inventing a blocking wait on someone
    /// else's flight.
    private func runSoftNewlineInTail(at location: Int) async {
        guard mintableTail else { return }
        idleMintTail()
        await awaitMintSettle()
        guard let textView else { return }
        // Clamped as a belt only — the mint moves no surface byte, so the
        // captured offset is still the same text position it named.
        let target = min(location, index.documentLength)
        textView.setSelectedRange(NSRange(location: target, length: 0))
        textView.withSoftNewline {
            textView.insertText("\n", replacementRange: NSRange(location: target, length: 0))
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
              let knownText = ledger.textByVariant[variantID]
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
        ledger.recordEdit(variantID: variantID, text: newText)
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
            ledger.recordEdit(variantID: correction.variantID, text: correction.text)
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
            ledger.recordEdit(variantID: block.variantID, text: block.text)
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

    // ——— The gesture-execution band lives in `EditorSurfaceController`
    // (13b Stage 3, N10 — moved TOGETHER with the projection executors,
    // the recorded one-seam move); these forwards keep every door, view,
    // and pin call site reading unchanged. ———

    /// Plans against the CURRENT selection and applies (the controller's).
    func invokeGesture(_ command: StructuralGesturePlanner.Command) async {
        await structural.invokeGesture(command)
    }

    /// THE one door for structural changes to the surface (the
    /// controller's).
    func applyStructural(_ plan: StructuralGesturePlanner.Plan) async {
        await structural.applyStructural(plan)
    }

    // MARK: - Phase 11, A9: the boundary-fluidity package — forwards
    // (execution in `EditorSurfaceController`, 13b Stage 3, N10)

    var crossBlockMakeConfirm: CrossBlockMakeState? {
        get { structural.crossBlockMakeConfirm }
        set { structural.crossBlockMakeConfirm = newValue }
    }

    /// The deferred keystroke-compound's handle (#11a/merge-then-edit) —
    /// the controller's; forwarded so `finalizeWork`'s guard, the quit
    /// fast-path, and the harness quiescence loops read unchanged.
    var pendingCrossBlockTask: Task<Void, Never>? { structural.pendingCrossBlockTask }

    private func scheduleCrossBlockCompound(_ body: @escaping @MainActor () async -> Void) {
        structural.scheduleCrossBlockCompound(body)
    }

    /// The guided cross-block Make Block's confirm executor (the
    /// controller's — the #10 auto-proceed mapping and the CAS'd compound
    /// live there).
    func confirmCrossBlockMakeBlock(_ state: CrossBlockMakeState) async {
        await structural.confirmCrossBlockMakeBlock(state)
    }

    /// The merge-then-edit plan (the controller's).
    func planCrossBlockEdit(range: NSRange, replacement: String) -> CrossBlockEdit? {
        structural.planCrossBlockEdit(range: range, replacement: replacement)
    }

    // MARK: - 13c 1B (A7/A8) — the empty-block carve + the delete door

    typealias EmptyBlockDeletion = EditorSurfaceController.EmptyBlockDeletion

    func planEmptyBlockDeletion(range: NSRange, replacement: String) -> EmptyBlockDeletion? {
        structural.planEmptyBlockDeletion(range: range, replacement: replacement)
    }

    func runEmptyBlockDeletion(_ plan: EmptyBlockDeletion) async {
        await structural.runEmptyBlockDeletion(plan)
    }

    /// A8's Write door (the Block menu / the bar / ⌘K).
    func deleteCaretBlock() async {
        await structural.deleteCaretBlock()
    }

    // MARK: - 13d batch 2 (#34) — backspace at a texted seam

    typealias SeamMerge = EditorSurfaceController.SeamMerge

    func planSeamMerge(range: NSRange, replacement: String) -> SeamMerge? {
        structural.planSeamMerge(range: range, replacement: replacement)
    }

    func runSeamMerge(_ plan: SeamMerge) async {
        await structural.runSeamMerge(plan)
    }

    /// The merge-then-edit compound (the controller's).
    func runCrossBlockEdit(_ edit: CrossBlockEdit) async {
        await structural.runCrossBlockEdit(edit)
    }

    // MARK: - Phase 11, A9 — the #11 sitting rulings — forwards
    // (execution in `EditorSurfaceController`, 13b Stage 3, N10)

    /// The visible-take edit plan (the controller's).
    func planVisibleTakeEdit(range: NSRange, replacement: String) -> VisibleTakeEdit? {
        structural.planVisibleTakeEdit(range: range, replacement: replacement)
    }

    /// The visible-take compound (the controller's).
    func runVisibleTakeEdit(_ edit: VisibleTakeEdit) async {
        await structural.runVisibleTakeEdit(edit)
    }

    /// #11b — "Delete in Every Take" (the controller's; the deliberate,
    /// NAMED command — apply-and-report, her ruling).
    func deleteInEveryTake() async {
        await structural.deleteInEveryTake()
    }

    // `StructuralSeam` lives beside its pure consumer in
    // StructuralSeamEdit.swift (review round 1, MINOR 5). `runStructural`,
    // the structural rewrite paths, and the DEBUG oracle live in
    // `EditorSurfaceController` (13b Stage 3, N10).

    /// Applies the one-shot focus-handoff seeds after the first render
    /// (Step 3): caret placement from the read-tier click, then the
    /// focus-then-fan panel where a badge tap drove the focus.
    private func applyFocusSeeds() {
        var caretClaimed = false
        if let seed = pendingCaretSeed, let textView {
            pendingCaretSeed = nil
            let clamped = min(max(0, seed), max(0, index.documentLength))
            textView.setSelectedRange(NSRange(location: clamped, length: 0))
            textView.window?.makeFirstResponder(textView)
            updateCaretContext()
            caretClaimed = true
        }
        if let fanBlock = pendingFanSeed {
            pendingFanSeed = nil
            openFan(blockID: fanBlock)
        }
        // 13b 1b — the fire-and-DO landing (move-and-execute): a Takes/
        // Lenses door parked a Write intent on the router; the arriving
        // editor consumes it once the index is real — ONLY for its OWN
        // post (round-1 MAJOR, half b: every full-document editor runs
        // this — detail Write, book-inline, pool — and a mismatched
        // consume would run a structural gesture on the wrong post at a
        // meaningless offset). A mismatched intent is left parked: a
        // book-inline/pool editor rendering mid-choreography must not
        // destroy the intent the detail's arriving editor is about to
        // take; staleness is the router's (cleared on detail change).
        if let intent = session.commandRouter.pendingWriteIntent,
           intent.postID == postID {
            session.commandRouter.pendingWriteIntent = nil
            applyWriteIntent(intent)
            caretClaimed = true
        }
        // 13b Stage 3, 3E (N12): a BARE arrival — no seed, no parked
        // intent — claims the caret too, so "⌘1 then type" is literal
        // (the N9 landing doctrine on Write's arrival: an arriving
        // editing surface is for typing, with zero clicks owed). Scoped
        // to the DETAIL editor (`scrollView != nil`): the inline
        // book-view editor mounts on the book's own focus model and must
        // never steal the window's focus as a side effect of rendering.
        // Nothing rides the router (no new parcel — the noteMode
        // staleness discipline is untouched by construction); the caret
        // lands at the document start, matching the Takes landing's
        // first-block choice. The window can lag the first projection by
        // a beat (attach precedes insertion), so a missing window gets
        // ONE next-turn retry, then gives up quietly.
        if !caretClaimed, scrollView != nil, let textView {
            let claim = { [weak textView, weak self] in
                guard let textView, let window = textView.window else { return false }
                if textView.selectedRange().location > (self?.index.documentLength ?? 0) {
                    textView.setSelectedRange(NSRange(location: 0, length: 0))
                }
                window.makeFirstResponder(textView)
                self?.updateCaretContext()
                return true
            }
            if !claim() {
                Task { @MainActor in _ = claim() }
            }
        }
    }

    /// The choreography's Write half: land the caret/selection (clamped to
    /// the target block), then run the follow-up gesture — which plans
    /// against the REAL landed selection, so its refusal (if any) is the
    /// operation's own, spoken. Task handle test-visible (the pin awaits
    /// the landed gesture deterministically).
    @ObservationIgnored private(set) var pendingIntentTask: Task<Void, Never>?

    private func applyWriteIntent(_ intent: WriteIntent) {
        guard let textView else { return }
        var location = 0
        var length = 0
        if intent.caretAtDocumentEnd {
            location = index.documentLength
        } else if let blockID = intent.blockID,
                  let i = index.entries.firstIndex(where: { $0.blockID == blockID }) {
            let range = index.range(ofEntryAt: i)
            let offset = min(max(0, intent.offsetInBlock), range.length)
            location = range.location + offset
            length = min(max(0, intent.selectionLength), range.length - offset)
        } else {
            // The block vanished between surfaces (a sync race): land at
            // the start rather than guessing; any follow-up speaks there.
            location = 0
        }
        textView.setSelectedRange(NSRange(location: location, length: length))
        textView.window?.makeFirstResponder(textView)
        updateCaretContext()
        guard let followUp = intent.followUp else { return }
        pendingIntentTask = Task { [weak self] in
            guard let self else { return }
            switch followUp {
            case .structural(let act):
                await invokeGesture(Self.plannerCommand(for: act))
            case .deleteInEveryTake:
                await deleteInEveryTake()
            }
            pendingIntentTask = nil
        }
    }

    /// Registry act → planner command (the registry never imports the
    /// planner; the Editor feature owns the mapping).
    nonisolated static func plannerCommand(
        for act: StructuralAct
    ) -> StructuralGesturePlanner.Command {
        switch act {
        case .divide: .divideAtCursor
        case .extract: .extractSelection
        case .makeBlock: .makeBlockFromSelection
        case .merge: .mergeBlocks
        }
    }

    /// 13b 4D (N28/S4-13) — insert-below's Write half, forwarded (the
    /// machinery lives in `EditorSurfaceController`, the one structural
    /// door): an empty block mints under the caret block and the caret
    /// lands in it.
    func insertBlockBelowCaret() async {
        await structural.insertBlockBelowCaret()
    }

    /// The add-block door's Write half: the caret jumps to the document's
    /// end — typing there births blocks (crystallization; blocks are born
    /// by typing in Write).
    func jumpToDocumentEnd() {
        guard let textView else { return }
        let end = index.documentLength
        textView.setSelectedRange(NSRange(location: end, length: 0))
        textView.scrollRangeToVisible(NSRange(location: end, length: 0))
        textView.window?.makeFirstResponder(textView)
        updateCaretContext()
        showStatus("Caret at the end — typing here starts a new block.")
    }

    // MARK: - The W ceremony — forwards (the state machine lives in
    // `EditorSurfaceController`, 13b Stage 3, N10)

    func toggleWTake(_ takeID: String) {
        structural.toggleWTake(takeID)
    }

    func placeWCut(takeID: String, cut: Int) {
        structural.placeWCut(takeID: takeID, cut: cut)
    }

    /// Cancel does nothing — no rows were touched by the ceremony.
    func cancelDivideW() {
        structural.cancelDivideW()
    }

    /// The ceremony object the sheet is parameterized on (13d Batch 3):
    /// Write's mount hands this over instead of the whole view model.
    var divideWCeremonyController: DivideWCeremony {
        structural.ceremony
    }

    func confirmDivideWCeremony() async {
        await structural.confirmDivideWCeremony()
    }

    // MARK: - The merge ceremony — forwards (13b Stage 4, Batch 4B; the
    // state machine lives in `EditorSurfaceController`, the W's pattern)

    func pairMergeTakes(firstID: String, secondID: String) {
        structural.pairMergeTakes(firstID: firstID, secondID: secondID)
    }

    func removeMergePairing(_ pairingID: String) {
        structural.removeMergePairing(pairingID)
    }

    func setMergeJoin(pairingID: String, join: MergeJoin) {
        structural.setMergeJoin(pairingID: pairingID, join: join)
    }

    func toggleMergeCarry(_ takeID: String) {
        structural.toggleMergeCarry(takeID)
    }

    /// Cancel does nothing — no rows were touched by the ceremony.
    func cancelMergeCeremony() {
        structural.cancelMergeCeremony()
    }

    func confirmMerge() {
        Task { await confirmMergeCeremony() }
    }

    func confirmMergeCeremony() async {
        await structural.confirmMergeCeremony()
    }

    /// Context-menu items for the text view — the second door, same brain:
    /// each item's enablement is a fresh planner verdict at menu-build time.
    /// The registry ids Write's context menu renders (13b 1b — walk-
    /// asserted against the contextMenu door set's Write half).
    nonisolated static let contextMenuCapabilities: [CapabilityID] = [
        .divide, .extract, .makeBlock, .merge, .deleteInEveryTake, .showTakes,
    ]

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

    /// Internal (was private) since N10: the controller's passive hints
    /// (fanned extract, merged fans) ride the same self-clearing line.
    func showTransientStatus(_ message: String) {
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

    /// 13b 4D (N34 — S4-14/S4-21): the one_block face's Write half — a
    /// door over the Phase-1 machinery (`setSegmentationDefault`, Phase 2;
    /// NO semantics change: `one_block` is entry-wide — typing and paste —
    /// by the model's standing meaning). ON ⇒ per-post nil (inherit the
    /// global default, paragraph); OFF ⇒ `.oneBlock`. The header
    /// observation refreshes `effectiveSegmentation`, so the chip and the
    /// crystallization mode follow. Allowed under seal (the container-row
    /// metadata class — title/date/profile; entry itself refuses under
    /// seal anyway).
    func setNewlinesMintBlocks(_ mint: Bool) async {
        do {
            try await session.runner.run { [postID] ops in
                try ops.setSegmentationDefault(postID, segmentation: mint ? nil : .oneBlock)
            }
            // 13d batch 4 (A16): read the EFFECTIVE mode back before
            // speaking — turning ON writes per-post nil, and under a global
            // one_block that still doesn't mint, so `mintOnNote` would lie.
            // A direct read (not `header`, whose observation may not have
            // delivered yet), bounded by one container.
            let effective = try? await session.database.read { [postID] db in
                try Queries.containerHeader(db, containerID: postID)?.effectiveSegmentation
            }
            showStatus(SegmentationFaceCopy.note(
                asked: mint,
                effectivelyMints: (effective ?? nil) != .oneBlock))
        } catch {
            showOperationError(error)
        }
    }

    /// 13b 4F (N36 — S4-28.1): the per-post word target's Write half. The
    /// observed header carries the stored value back into the bar's face
    /// (the setter's write stamps `updated_at`, so the header observation
    /// delivers). Refusals — the sealed post's PROVISIONAL refuse among
    /// them — speak through the standing door.
    func setPostWordTarget(_ target: Int?) async {
        do {
            try await session.runner.run { [postID] ops in
                try ops.setPostWordTarget(postID, wordTarget: target)
            }
            showStatus(target.map(WordTargetFaceCopy.setNote)
                ?? WordTargetFaceCopy.clearNote)
        } catch {
            showOperationError(error)
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

    // MARK: - Caret take shortcuts (Sitting 9, R73/R90 — the keyboard
    // family in Write: mint on the block you're in; minting never chooses
    // except the explicit power variant)

    func mintCaretTake(blank: Bool, asChosen: Bool = false) {
        guard let blockID = caretBlockID else {
            showStatus("Put the caret in a block first — takes grow on the block you're in.")
            return
        }
        let sourceID = caretVariantID
        Task {
            await autosave.flushNow()
            do {
                try await session.runner.run { ops in
                    let take: Variant
                    if blank {
                        take = try ops.newBlankVariant(blockID)
                    } else {
                        guard let sourceID else {
                            throw OperationError.variantNotFound(id: blockID)
                        }
                        take = try ops.branchVariant(blockID, from: sourceID)
                    }
                    if asChosen {
                        try ops.chooseVariant(blockID, variantID: take.id)
                    }
                }
                showStatus(asChosen
                    ? "New blank take opened as chosen — type away (the old take is still in the fan)."
                    : "New take added on this block — ⌘⇧T shows the takes.")
            } catch {
                showOperationError(error)
            }
        }
    }

    /// ⌘⇧L from Write (Sitting 9): the post's current choices become a
    /// named lens — an explicit pick per renderable slot (the elevate door
    /// without leaving the page).
    func saveCurrentChoicesAsLens(named name: String) {
        let choices: [(String, String)] = index.entries.compactMap { entry in
            entry.variantID.map { (entry.blockID, $0) }
        }
        Task {
            do {
                try await session.runner.run { [postID] ops in
                    let lens = try ops.createLens(post: postID, name: name)
                    for (blockID, variantID) in choices {
                        _ = try ops.setLensChoice(lens: lens.id, block: blockID, variant: variantID)
                    }
                }
                showStatus("Saved — “\(name)” remembers these choices (open it in Lenses, ⌘3).")
            } catch {
                showOperationError(error)
            }
        }
    }

    func archiveCaretTake() {
        guard let variantID = caretVariantID else {
            showStatus("Put the caret in a block first — ⌘⇧A archives the take you're on.")
            return
        }
        Task {
            await autosave.flushNow()
            do {
                try await session.runner.run { ops in
                    try ops.archiveVariant(variantID)
                }
                // NIT-4 (Stage 3 ladder round 1): the road copy names the
                // NEAREST road — Write's own takes panel keeps the archived
                // list (the tutorial's "keeping takes safe" lesson teaches
                // both roads; the Takes-board siblings name theirs).
                showStatus("Take archived — never gone: the takes panel (⌘⇧T) keeps it under “archived takes”.")
            } catch {
                showOperationError(error)
            }
        }
    }

    /// ⌃⌘↑/↓ — the caret jumps to the previous/next block's start (R73's
    /// navigation pair). Uses the tiling index (never diffing) and the
    /// ordinary caret-reveal scroll.
    func jumpToAdjacentBlock(_ delta: Int) {
        guard let textView, let currentID = caretBlockID,
              let currentIndex = index.entries.firstIndex(where: { $0.blockID == currentID })
        else { return }
        let target = currentIndex + delta
        guard index.entries.indices.contains(target) else { return }
        let range = index.range(ofEntryAt: target)
        textView.setSelectedRange(NSRange(location: range.location, length: 0))
        textView.scrollRangeToVisible(NSRange(location: range.location, length: 0))
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
        let previousCaretBlock = caretBlockID
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
        // The live buffer's caret-block count keeps the post TOTAL current
        // between projections (R11).
        if let caretVariantID, let fresh = caretBlockWordCount,
           ledger.setLiveWordCount(variantID: caretVariantID, count: fresh) {
            publishPostWordCount()
        }
        // Gesture enablement rides every caret/selection change — the menu
        // bar, context menu, and shortcuts read these planner verdicts
        // (one brain, three doors). Cost: the caret block's boundary scan.
        refreshGestureAvailability()
        // The editing indicator follows the caret (R14): refresh only when
        // it is on and the caret changed blocks (the decor pass is
        // viewport-bounded; off costs nothing).
        if appearance.indicator != .off, caretBlockID != previousCaretBlock {
            refreshDecorations()
        }
    }

    // MARK: - The overlay layout-settle trigger (N14, 13b Stage 3F)

    /// THE COLD-MOUNT CLASS, traced: every mount/edit-time overlay refresh
    /// (attach → renderFull → `refreshBadges`, applyChrome, the clip's
    /// mount-time bounds change) runs BEFORE TK2's first viewport layout —
    /// fragment enumeration over un-laid storage returns collapsed/estimate
    /// frames, so every ⑂ badge lands on one top anchor and the decor walk
    /// computes garbage. The only post-layout refreshes were user scrolls
    /// and the saved-anchor `JumpPrimitive` jump (which forces layout) —
    /// which is exactly why a WARM model (saved anchor) healed and a COLD
    /// model (post's first open since launch) stayed collapsed, and why a
    /// mid-document choose (differential replace + pre-layout refresh)
    /// neither caused nor healed it. The fix: the surface reports each
    /// display pass (`EditorTextView.viewWillDraw`), and the model re-runs
    /// the overlay family ONCE per storage generation, on the next runloop
    /// turn — after the pass that laid the edited storage out. The
    /// equality gates then deliver real frames; an already-correct refresh
    /// is a cheap no-op. The generation's INPUTS (the class axis, completed
    /// at the Stage 3 ladder's MINOR-2): storage content (every character
    /// edit), surface attach, and — since the round-1 fix — surface WIDTH
    /// (a reflow re-lays every fragment with no storage edit; the inline
    /// book-view editor has no scroll-view resize coverage of its own).
    @ObservationIgnored private(set) var overlayGeometryGeneration = 0
    @ObservationIgnored private var overlayGenerationDelivered = -1
    @ObservationIgnored private var overlaySettleScheduled = false

    private func overlayLayoutDidSettle() {
        guard overlayGenerationDelivered != overlayGeometryGeneration,
              !overlaySettleScheduled else { return }
        overlaySettleScheduled = true
        let generation = overlayGeometryGeneration
        // The async hop lands after the WHOLE display pass (wherever in it
        // TK2 ran layout) and keeps subview mutation out of viewWillDraw.
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            overlaySettleScheduled = false
            overlayGenerationDelivered = generation
            // A generation bumped between schedule and run re-arms on its
            // own draw pass — delivered records what this refresh SAW.
            refreshBadges()
            // 13c 1E: the post-layout settle is also the "the viewport is
            // looking somewhere new" event for a post that just OPENED (or
            // whose storage changed) — without it the phantom fix would
            // need a scroll to notice anything. Debounced and bounded; see
            // `LongBlockLayout.swift`.
            considerLongBlockLayout()
        }
    }

    /// Badges for fanned blocks currently laid out near the viewport.
    /// Cost ∝ fanned blocks (fans are opt-in and rare) — no ensureLayout,
    /// unlaid-out blocks simply have no badge until scrolled to (P1).
    func refreshBadges() {
        defer { refreshDecorations() }  // the decor layer rides every badge
                                        // refresh trigger (scroll, layout,
                                        // projection).
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

    /// A freshly-wired BADGE host gets the CURRENT badges (Stage 2 ladder
    /// round 2, R2-B — the starved-host class's LAST field): both editor
    /// representables build fresh `BadgeOverlayController`s over
    /// possibly-loaded models, `refreshBadges` gates on `result !=
    /// badges`, and nothing resets `badges` at attach — a fully-visible
    /// short post would never produce the change that un-starves the
    /// overlay. Wiring is a delivery, symmetric with the decor twin above
    /// and the read tier's `pushOverlaysToSinks`.
    func pushBadgesToSink() {
        badgeSink?(badges)
    }

    /// A freshly-wired overlay host gets the CURRENT decorations (Stage 2
    /// walk fix — the starved-host class): the mount order can compute a
    /// decoration state BEFORE the sink exists (`attach` precedes the
    /// coordinator's `install`, and the model may already be loaded), and
    /// the `lastDecorState` equality gate then starves the new host until
    /// the next REAL change — callouts/seams/handles blank on an ordinary
    /// mount, timing-dependent. Re-arming the gate before refreshing makes
    /// wiring itself a delivery.
    func pushDecorationsToSink() {
        lastDecorState = BlockDecor.State()
        refreshDecorations()
    }

    /// Phase 13 C1 — the decoration pass: per-block geometry for the
    /// visible region + the decoration context, emitted to the overlay
    /// controller. Viewport-proportional exactly like the 9d tint walk it
    /// supersedes: the visible character window (the `topVisibleOffset`
    /// fragment idiom, both edges) prunes the entry walk to on-screen
    /// entries; each visible entry costs two single-fragment lookups
    /// (first and last fragment frames). When nothing is decorated (seams
    /// off, indicator off, no callouts, no comments) the walk is skipped
    /// entirely — the calm default costs nothing.
    func refreshDecorations() {
        func send(_ state: BlockDecor.State) {
            if state != lastDecorState {
                lastDecorState = state
                decorSink?(state)
            }
        }
        let needsFrames = appearance.seamsVisible
            || appearance.indicator != .off
            || !presentationsByBlock.isEmpty
            || !commentsByBlock.isEmpty
        guard needsFrames, let textView, loaded,
              let layoutManager = textView.textLayoutManager,
              let contentManager = layoutManager.textContentManager,
              !index.entries.isEmpty
        else {
            send(BlockDecor.State())
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

        // 13c 1A (A40): the fragment's TEXT rect, not its frame — TK2 folds
        // the uniform per-paragraph gap into `layoutFragmentFrame`, and a
        // decoration drawn from that claims space belonging to neither
        // block (`BlockDecor.textBottom` carries the traced mechanism).
        func fragmentFrame(atOffset offset: Int) -> CGRect? {
            guard let location = contentManager.location(docStart, offsetBy: offset)
            else { return nil }
            var frame: CGRect?
            layoutManager.enumerateTextLayoutFragments(from: location, options: []) {
                frame = BlockDecor.textRect(of: $0)
                return false
            }
            return frame
        }

        var frames: [BlockDecor.Frame] = []
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
            frames.append(BlockDecor.Frame(
                entryIndex: i, blockID: entry.blockID, frame: frame))
        }
        send(BlockDecor.State(
            frames: frames,
            fannedBlockIDs: Set(slots.filter(\.hasFan).map(\.blockID)),
            appearance: appearance,
            caretBlockID: caretBlockID,
            presentations: presentationsByBlock,
            comments: commentsByBlock,
            textLeft: origin.x,
            textRight: textView.bounds.width - textView.textContainerInset.width,
            viewWidth: textView.bounds.width,
            entryCount: index.entries.count))
    }

    // MARK: - Comments + callouts + block reorder (Phase 13, C1)

    /// The comments panel door (R7's faces all route here).
    func openComments(blockID: String) {
        commentsPanel = CommentsPanelState(blockID: blockID)
    }

    /// Opens the caret block's comments (the Block-menu/keyboard door).
    func openCaretComments() {
        guard let caretBlockID else {
            showStatus("Place the caret in a block to see its comments.")
            return
        }
        openComments(blockID: caretBlockID)
    }

    /// The routed callout door's Write half (13c R2-2 — A13(a)): the
    /// caret block's frame, through the ONE transform every surface shares
    /// (`CalloutEditRule`), applied inside `updateBlockPresentation`'s own
    /// transaction so the stored frame is the truth — never the projection
    /// cache. Sealed posts refuse through the op, spoken (P-2).
    func applyCallout(_ edit: CalloutEdit) async {
        guard let caretBlockID else {
            showStatus("Place the caret in a block first — the frame goes on that block.")
            return
        }
        do {
            try await session.runner.run { ops in
                try ops.updateBlockPresentation(caretBlockID) {
                    CalloutEditRule.apply(edit, to: $0)
                }
            }
        } catch {
            showOperationError(error)
        }
    }

    /// Sets/clears the caret block's callout frame (R16/R27). Kept as the
    /// named colour door the Phase 13 pins drive; the routed door above is
    /// the one the menu and the boards use.
    func setCaretCallout(color: String?) async {
        await applyCallout(.color(color))
    }

    /// Sets the caret block's callout emoji (keeps the color; a callout is
    /// minted with the default color when none exists yet).
    func setCaretCalloutEmoji(_ emoji: String?) async {
        await applyCallout(.emoji(emoji))
    }

    /// The handle drop (R19): entry `fromEntry` lands BEFORE boundary
    /// `toBoundary` (0…entryCount). One ordinary `reorder` operation —
    /// undo inverse included; the observation's full render redraws.
    func moveBlock(fromEntry: Int, toBoundary: Int) async {
        guard slots.indices.contains(fromEntry),
              toBoundary >= 0, toBoundary <= slots.count,
              toBoundary != fromEntry, toBoundary != fromEntry + 1
        else { return }
        let blockID = slots[fromEntry].blockID
        let insert: Operations.InsertPosition =
            toBoundary == slots.count ? .end
            : toBoundary == 0 ? .start
            : .before(slots[toBoundary].blockID)
        do {
            try await session.runner.run { ops in
                try ops.reorder(blockID, to: insert)
            }
        } catch {
            showOperationError(error)
        }
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

    /// Internal (was private) since N10: the surface controller reads
    /// entry texts through the one counted extraction door.
    func viewText(_ range: NSRange) -> String {
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

    /// Internal (was private) since N10: the controller's differential
    /// executor replaces slot texts through this one mutating door.
    func programmaticReplace(
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
        // 13c 1A: `textLayoutFragment(for:)` takes a TEXT-CONTAINER point —
        // measured, not assumed (an inset-height Y error picked the block
        // BELOW the one at the viewport top at every scroll position). The
        // decoration pass already converted here; this site did not. Same
        // container↔view class as the Phase 10 mis-registration, one site
        // over.
        let origin = textView.textContainerOrigin
        let point = CGPoint(x: 4, y: top + 1 - origin.y)
        guard let fragment = layoutManager.textLayoutFragment(for: point) else { return nil }
        let fragmentStart = contentManager.offset(
            from: contentManager.documentRange.location,
            to: fragment.rangeInElement.location)
        // A block taller than the viewport is ONE fragment, so the
        // fragment's start IS the block's start — anchoring there threw the
        // reader back to the top of the block on every width reflow (A4).
        // Resolve to the LINE at the viewport top instead (`FragmentLines`).
        let lines = fragment.textLineFragments
        guard let i = FragmentLines.lineIndex(
            atLocalY: point.y - fragment.layoutFragmentFrame.minY,
            lineBounds: lines.map(\.typographicBounds))
        else { return fragmentStart }
        return fragmentStart + lines[i].characterRange.location
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

    /// Internal (was private) since N10: the controller's refusals speak
    /// through the model's one voice.
    func refuseFeedback(_ message: String) {
        statusMessage = message
        NSSound.beep()
    }

    /// Internal (was private) since N10: the controller's compounds reuse
    /// the refusal copy.
    func message(for refusal: BlockRangeIndex.Refusal) -> String {
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

    /// Internal (was private) since N10: the controller's op errors land
    /// in the model's status line.
    func showOperationError(_ error: Error) {
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
        // 13c R3-1: the A7 carve's authorization, re-checked inside the
        // tombstone's transaction. Reachable when a take or a note lands on
        // the block between the keystroke and the write — the editor's
        // projection is deliberately frozen while typing, so the guards that
        // enabled the gesture could not have seen it.
        case .blockCarriesUnshownText:
            return "That block isn't empty after all — it carries a take or a note that isn't shown here. Nothing was deleted."
        case .fannedBlock:
            // 13d Batch 3: the same refusal Write can reach when a take
            // lands between the plan and the operation (R1-3's
            // every-refusal-readable class).
            return "This block has more than one take now — divide it again and the take ceremony will open, so each take gets its own cut."
        case .divideSideWouldBeEmpty:
            return "Every checked take is parked at the same end — one of the two new blocks would have no takes. Split at least one take, or park one at the other end."
        case .mergedBlockWouldHaveNoTake:
            return "The merged block needs at least one take — pair takes with ＋, or check “carry” on one."
        case .takePairedTwice:
            return "A take can sit in only one pairing (and a paired take can't also carry) — remove the duplicate first."
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
