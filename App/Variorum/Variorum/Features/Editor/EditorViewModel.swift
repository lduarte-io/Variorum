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
        self.forwarder = StatusForwarder(session.status)
        // 13b 1a (N3): the ONE per-post coordinator — shared with every
        // other surface editing this post (takes panel, TOC), so two
        // debounced pipelines can never race a stale flush over a newer
        // one. Callbacks are multicast observers (a shared coordinator has
        // several listeners); removed at teardown.
        self.autosave = session.autosave(forPost: postID)
        autosaveToken = autosave.observe(
            onError: { [weak self] error in self?.showOperationError(error) },
            onSettled: { [weak self] in
                self?.storeWriteGeneration &+= 1
                self?.applyPendingIfClean()
            })
    }

    @ObservationIgnored private var autosaveToken: UUID?
    /// The store-write freshness generation (mobile S3 ladder, MAJOR 3 —
    /// the retired Phase 8 VM's `readGeneration` fence restored): bumped
    /// whenever OUR writes settle (flush settle, mint finish), so a fresh
    /// read that STRADDLED a settle is re-signaled instead of adopted.
    @ObservationIgnored private var storeWriteGeneration = 0

    // MARK: - Observable UI state

    private(set) var header: Queries.ContainerHeader?
    private(set) var canaryMessage: String?
    /// The editor's transient outcome line. PRESENTATION is the shell's
    /// StatusCenter (13b 1b, AD-14 — one placement, one auto-dismiss
    /// policy); the property remains the tested truth and forwards on set.
    ///
    /// **18i (her R-Q5): the forward carries a KIND** — the class the NEXT
    /// write delivers, named by the door that is writing (`showReceipt` /
    /// `showTransientReceipt` say receipt; everything else is a refusal),
    /// and RESET after each delivery — so the ~25 bare `statusMessage = …`
    /// assignments in this file and its controller, every one of them a
    /// refusal or an error, keep behaving exactly as they did without a
    /// single edit. The rule and the reason live ONCE, in `StatusForwarder`
    /// beside the centre (J30); four view models forward this way.
    private(set) var statusMessage: String? {
        didSet { forwarder.deliver(statusMessage) }
    }

    /// The one home for the forward's rule (18i — J30).
    @ObservationIgnored private var forwarder: StatusForwarder

    /// The ONE write that names its class; every door below goes through it.
    private func setStatusMessage(_ message: String?, kind: StatusCenter.Kind) {
        forwarder.outgoing = kind
        statusMessage = message
    }
    private(set) var caretBlockID: String?
    private(set) var caretVariantID: String?
    /// **13e E2 (her A17) — the BLOCK selection.** Observed, because the
    /// banner and the highlight both render from it. Session-only view
    /// state, exactly like the Takes board's (it is the same
    /// `BlockSelection` brain): nothing here is persisted, projected or
    /// synced.
    private(set) var blockSelection = BlockSelection()
    /// 13f W10b — blockID → its RELEASED originals (live, unplaced), from
    /// `Queries.unplacedOrigins`. Empty for an ordinary post; the lineage
    /// door reads it synchronously at menu-build time. 13j J3: the values
    /// carry the act and the date, because the ruled row says WHICH act
    /// released the original and a menu builder cannot ask the store.
    private(set) var unplacedOriginsByBlock: [String: [Queries.UnplacedOrigin]] = [:]
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
    /// **THE BLOCK HISTORY PANE'S PENDING TARGET** (the post-13l polish
    /// round, ledger row 17 — G2). Its NAMED home is the post detail's
    /// inspector, reached through the router; this is the FALLBACK sheet, and
    /// it is not vestigial for `trayRequest`'s exact reason: this editor is
    /// also composed where no post detail exists (the scraps hosts, the book
    /// spread's inline form), and a door that cannot act in its context is a
    /// door that should not have been rendered (P-2).
    ///
    /// *(What this replaces: `commitList` + `pendingRestore` + `blockPast` —
    /// the caret take's savepoint strip, its pre-split confirm, and the
    /// block's past region, three pieces of state for two faces that showed
    /// parts of one block's time. The pane owns all of it now, in ONE model
    /// with ONE observation, which is what makes "the pane is the one home"
    /// a fact about the code rather than a claim in a comment.)*
    var blockHistoryRequest: BlockHistoryRequest?
    /// **THE VERSIONS PANE'S PENDING REQUEST** (the post-13l polish round,
    /// ledger rows 16/23). Its named home is the post detail's inspector,
    /// reached through the router; this is the FALLBACK sheet, for the reason
    /// its two neighbours have one — this editor is also composed where no
    /// post detail exists.
    var versionsRequested = false
    /// **THE COMMIT DOOR'S PENDING NAME** (13u3 UNIT D — item 14: *"an
    /// optional name at the manual-commit door, enter-to-skip keeps ⌘S
    /// instant"*). Non-nil while the field is up; the bar presents it at the
    /// commit door. Nil-ing it without filing IS the cancel (the one road —
    /// ⎋, a click outside, a window going away).
    var savepointAsk: SavepointNameAsk?
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
        /// 13u4 UNIT C2 (her item 9, R-13u4-4): the selection lies inside
        /// ONE block that has a take to move a span out of. Unlike the four
        /// above this drives RENDERING, not dimming (P-2 — a cross-block
        /// selection is not this gesture, so its doors do not appear there);
        /// the verdict is `SpanToTakeGesture.plan`'s, the same one the act
        /// consults.
        var moveToTake = false
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
    /// 13e E7: whether the pointer is inside this surface, reported by the
    /// decoration controller's hover tracker. It is a DECORATION INPUT, not
    /// UI state anything renders directly: the hover faces need block
    /// geometry to resolve against, and `refreshDecorations`' gate skips the
    /// walk entirely on a calm page. Ignored for observation like every
    /// other decoration input — it drives the sink, never a view body.
    @ObservationIgnored var pointerInEditor = false {
        didSet { if oldValue != pointerInEditor { refreshDecorations() } }
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

    /// Which block the takes sheet is open on — nothing more. The sheet
    /// (`WriteTakesPanel`) drives every act through its own `TakesViewModel`
    /// and reads only `blockID`, so the `variants`/`chosenVariantID` fields
    /// this once carried were written on every open and read nowhere
    /// (17f/P43 — retired with the store read that filled them).
    struct FanPanelState: Equatable, Identifiable {
        let blockID: String
        var id: String { blockID }
    }

    // MARK: - Editor internals (never observed)

    @ObservationIgnored private(set) var index = BlockRangeIndex(entries: [], tailLength: nil)
    @ObservationIgnored private(set) var slots: [Queries.RenderedBlock] = [] {
        // 13e E2: the block selection is pruned wherever the surface adopts
        // a fresh projection — a `didSet` rather than a call at each of the
        // two adoption sites, because a THIRD site added later would
        // otherwise silently reopen the ghost-selection class (batch 2's
        // pruning lesson, made structural).
        didSet { pruneBlockSelection() }
    }
    @ObservationIgnored private(set) var tailText = ""
    @ObservationIgnored private(set) weak var textView: EditorTextView?
    @ObservationIgnored private(set) weak var scrollView: NSScrollView?
    @ObservationIgnored let autosave: AutosaveCoordinator
    @ObservationIgnored private let canary = FallbackCanary()
    /// The gate's approved edit, BOUND to what it approved (mobile round 2,
    /// batch 1 — `ArmedEdit`'s doc comment carries the mechanism). This was
    /// a bare `Verdict?`: an identity with no range, no document length and
    /// no expiry, consumed by whatever edit reached storage next. The crash
    /// that class produces has only been OBSERVED on iOS, but the shape is
    /// this file's line for line and it is shared-brain bookkeeping — the
    /// Mac survived on three accidents (AppKit's near-1:1 typing contract,
    /// cross-block spans answered by compounds rather than left to storage,
    /// and `EditorFind`'s hand-written 1:1 discipline around the ONE AppKit
    /// road that does coalesce), not on a guarantee. Latent, not prevented;
    /// fixed here in the same change (M-B).
    @ObservationIgnored private var pendingEdit: ArmedEdit?
    @ObservationIgnored private var suppressEditProcessing = false
    @ObservationIgnored private(set) var mintInFlight = false
    @ObservationIgnored private var mintTask: Task<Void, Never>?
    @ObservationIgnored private var bulkPending = false
    @ObservationIgnored private var pendingProjection: [Queries.RenderedBlock]?
    @ObservationIgnored private var forceFullRender = false
    /// `private(set)`: `EditorSurfaceController.renderFull` reads it to tell
    /// the COLD mount (the initial render — the frame is still the pre-fill
    /// height) from a warm re-render (the ladder's round 2, RAISE-M1).
    @ObservationIgnored private(set) var loaded = false
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
    /// Times the DEBUG identity audit found the attribute projection
    /// disagreeing with the index (13l L-a — the phone's counter, arriving
    /// on the Mac with the hoisted walk). Its meaning is the same as
    /// `desyncRecoveryCount`'s: zero, always, and any other value is a bug
    /// the pins are entitled to fail on.
    @ObservationIgnored private(set) var identityAuditFailures = 0
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
    /// QoL batch 3 (L6): the deferred find-replace application (we are inside
    /// AppKit's finder call when the gate runs — rewriting storage there would
    /// be re-entrant). Exposed so tests can await it deterministically, the
    /// `pendingCrossBlockTask` precedent.
    @ObservationIgnored var findReplaceTask: Task<Void, Never>?
    /// 13e E9: the takes-aware replace's ONE-SHOT arming — true only
    /// between "Replace All in Every Take" being pressed and the finder's
    /// client question arriving (a synchronous window, M5). Never a mode:
    /// a scope she cannot see the state of would make an ordinary Replace
    /// All silently edit takes, which is the surprise this act exists to
    /// make deliberate.
    @ObservationIgnored var takesScopeArmed = false

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
        // 13u2b UNIT 3: the DETAIL editor answers "where is the carried block
        // on your screen?" when a mode switch asks. The inline book/pool
        // editor does not — it scrolls inside its host's scroll view and owns
        // no viewport of its own (the `revealLanding` rule, one door over).
        if scrollView != nil, placeProbeToken == nil {
            placeProbeToken = session.commandRouter.registerBlockPlaceProbe {
                [weak self] in self?.carriedBlockPlace()
            }
        }
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
        // 13e E2 (her A17): ⌘-click picks a block, ⌘⇧-click extends the run,
        // an ordinary click puts the selection down. Wired HERE rather than
        // in each `NSViewRepresentable` because the model owns the surface
        // from this point — one wiring for the detail editor, the inline
        // book/spread/pool editor, and every harness that attaches a real
        // text view (two copies in the views would be a wiring a pin could
        // pass without the app having).
        textView.onBlockPick = { [weak self] offset, extending in
            self?.pickBlock(atOffset: offset, extending: extending) ?? false
        }
        textView.onPlainClick = { [weak self] in self?.clearBlockSelection() }
        // 18c batch 2 (her U-1): the Return key's act. Wired HERE for the
        // reason the block pick above states — the model owns the surface
        // from this point, so the detail editor, the inline book editor and
        // every harness that attaches a real text view get ONE wiring.
        textView.onTypedReturn = { [weak self] afterListExit in
            self?.runTypedReturn(afterListExit: afterListExit) ?? false
        }
        // 18c ladder R1-1: the list door's continuation asks before its
        // newline lands whether that newline would open the tail.
        textView.onNewlineWouldOpenTail = { [weak self] in
            self?.typedNewlineWouldOpenTail() ?? false
        }
        // 13j J7 (her ruling): ⌘Z / ⌘⇧Z with nothing left in the TEXT stack
        // point at the structural one — spoken, never a key stolen.
        textView.onTextUndoUnavailable = { [weak self] in self?.speakUndoHint(.undo) }
        textView.onTextRedoUnavailable = { [weak self] in self?.speakUndoHint(.redo) }
        // QoL batch 3 (L6): the find bar's replacements arrive here. Only the
        // editor that owns a scroll view has a bar at all, so the hook is
        // wired only there — the inline book/spread/pool editor never sees a
        // finder, and leaving it nil says so.
        if scrollView != nil {
            textView.onFindReplace = { [weak self] ranges, strings in
                self?.gateFindReplace(ranges: ranges, strings: strings)
            }
        }
        textView.structuralMenuItems = { [weak self] in self?.contextMenuItems() ?? [] }
        // 13k K6: the right-click callout door. It runs the SAME
        // `applyCallout` the routed menu-bar command runs — the caret block's
        // frame, through `updateBlockPresentation` — so there is one
        // transform and one refusal, and the rows come from the one
        // vocabulary (`CalloutMenu`).
        textView.calloutMenuItem = { [weak self] in
            guard let self else { return nil }
            return CalloutMenu.menuItem { edit in
                Task { await self.applyCallout(edit) }
            }
        }
        session.editorRouter.active = self
        // **AND AGAIN WHEN THIS VIEW REACHES THE SCREEN** (13u2 UNIT B —
        // KnownIssues row 49). `active` means "the last text view to attach",
        // and in the book's Outline that is the wrong object: SwiftUI
        // realizes the focused note's `InlineEditorSurface` twice (~40 ms
        // apart, two models, no `dismantleNSView`), so the SECOND — a
        // projection-less orphan whose view never enters a window — held
        // `active` for as long as the note stayed focused, and the quit and
        // lock doors asked IT to `finalizeWork()`. A shadow has no pending
        // text, so it answered nil and the door believed there was nothing to
        // await: the note's OPEN TAIL, whose crystallization only
        // `finalizeWork()` performs, could be lost to a quit inside the idle
        // interval.
        //
        // The claim on window entry corrects it without changing what
        // `attach` does for anybody: the real view reaches the window a few
        // milliseconds later and takes `active` back, and the orphan — window
        // nil at +0.05 s, +0.5 s and +2 s, measured — can never take it
        // again. A view leaving its window does NOT relinquish (teardown is
        // the one door that clears `active`, unchanged), so a re-parent or a
        // window close cannot blank the router behind a live editor's back.
        textView.onWindowChange = { [weak self, weak textView] in
            guard let self, let textView, textView.window != nil else { return }
            session.editorRouter.active = self
        }
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
            group.addTask { await self.observeUnplacedOrigins() }
        }
    }

    /// 13f W10b: blockID → the RELEASED originals it was derived from. Read
    /// as a MAP, live, exactly like presentations and comments — a menu
    /// builder runs synchronously and must never touch the store (P2), and
    /// the fact changes on structural writes the surface already observes.
    private func observeUnplacedOrigins() async {
        do {
            for try await value in session.database.observe({ [postID] db in
                try Queries.unplacedOrigins(db, inContainer: postID)
            }) {
                adoptUnplacedOrigins(value)
            }
        } catch is CancellationError {
        } catch {
            statusMessage = "Lineage observation failed: \(error)"
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

    /// Internal so tests drive the lineage door without an observation.
    func adoptUnplacedOrigins(_ value: [String: [Queries.UnplacedOrigin]]) {
        unplacedOriginsByBlock = value
    }

    /// The released original the caret block's own `derived_from` edge points
    /// at, when it has one that is live and unplaced (13f W10b). Deterministic
    /// (the query sorts) and nil for every ordinary block, which is what keeps
    /// the door off ordinary blocks.
    var caretBlockOrigin: Queries.UnplacedOrigin? {
        guard let caretBlockID else { return nil }
        return unplacedOriginsByBlock[caretBlockID]?.first
    }

    /// The same fact as an id, for callers that only need to know THAT there
    /// is one (the pre-13j shape, kept so nothing has to unwrap to ask).
    var caretBlockOriginID: String? { caretBlockOrigin?.blockID }

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
        // 13u2b UNIT 3: the probe goes with the surface whose geometry it
        // reads (a torn-down editor has no viewport to answer about).
        if let placeProbeToken {
            session.commandRouter.unregisterBlockPlaceProbe(placeProbeToken)
            self.placeProbeToken = nil
        }
        if session.editorRouter.active === self {
            session.editorRouter.active = nil
        }
        if session.editorRouter.editing === self {
            session.editorRouter.editing = nil
        }
        // 13u2 UNIT B: and the window-entry claim goes with the teardown — a
        // model that has let go must not re-take `active` if its view is
        // re-parented on the way out.
        textView?.onWindowChange = nil
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
        // **AND A MENU FLIGHT IS PENDING WORK TOO** (13u1 UNIT 2 —
        // `KnownIssuesAndTechDebt.md`'s row named at UNIT 1's close, which
        // traced it and deliberately did not fold it into the chain fix:
        // widening the guard changes what the quit door WAITS FOR, which is
        // door semantics rather than a loop, and the flight and the compound
        // are one subject here). A divide, merge or ceremony launched from a
        // MENU arms no compound handle and dirties nothing — its keystroke
        // was never refused because there was no keystroke — so all four
        // doors read three flags that are all false and reply "done" while
        // the operation is still in the writer queue. Older than U-1 and
        // older than the deferred-keystroke seam.
        guard autosave.isDirty || mintInFlight || hasTailText
            || pendingCrossBlockTask != nil || structuralInFlight
        else { return nil }
        return Task { // strong self, deliberately
            // **AWAIT THE WHOLE CHAIN, not one link of it** (13u1 UNIT 1 —
            // the 18c ladder's R3-1, recorded at that ladder's cap and owned
            // here). This captured the handle ONCE: under the deferred-
            // keystroke seam a stashed ⏎ or seam ⌫ replayed by the awaited
            // task's TAIL schedules a NEW compound and re-populates the
            // handle, so ⏎ x ⏎ y ⌘Q returned with the second act unstarted
            // and `y` still in `deferredKeyEvents` — keys ending with the
            // process, against 18c's own doctrine that nothing typed can be
            // permanently lost. The harness's `flush()` has looped for
            // exactly this reason since 18c; the production doors had not.
            //
            // All four doors — quit, lock, seal, teardown — inherit the
            // await through the one call.
            //
            // **THE MENU FLIGHT** (13u1 UNIT 2). A keystroke-born compound
            // has a Task handle to await; a menu-born one has only the
            // one-flight latch, so this waits on the latch the way the mint
            // loop below waits on `mintInFlight` — the same shape, for the
            // same reason, in the same method. What is unknown without it is
            // not the OPERATION (one transaction through the runner; the
            // store is truth and a half-written structural op is not a state
            // the operations layer can commit) but the flight's own
            // post-landing bookkeeping: the caret landing, the deferred
            // projection, the stash drain. It yields rather than spinning,
            // and it converges because `runStructural`'s `defer` clears the
            // latch on every road, throw included.
            //
            // **AND THE TWO WAITS ARE ONE LOOP** (13u1 ladder, round 1 —
            // the composition of the two fixes above). Waiting the chain
            // and THEN the latch left a back-edge unhandled: a menu-born
            // flight's `defer` clears the latch and then DRAINS the stash
            // in the same main-actor slice, and a replayed ⏎ schedules a
            // compound — re-populating a handle the chain check had already
            // found nil. The door then proceeded, and its own `flushNow`
            // RACED the forged act's flight: the act's dirty-guard refused
            // ("Unsaved changes couldn't be written…") and the typed ⏎ was
            // swallowed — measured, y ⏎ z during a menu flight read "yz" in
            // one block. At quit the same race ends the process over an
            // unstarted act; at teardown the forged body's `[weak self]`
            // makes it a no-op outright. So each wait re-asks the other
            // until BOTH are quiet. `awaited` keeps round 3's belt without
            // its loop hazard: a completed handle nothing cleared (a
            // torn-down controller) is remembered rather than re-awaited,
            // so the loop can never spin on it.
            var awaited: Task<Void, Never>?
            while true {
                if let pending = self.pendingCrossBlockTask, pending != awaited {
                    await pending.value
                    awaited = pending
                    continue
                }
                if self.structuralInFlight {
                    await Task.yield()
                    continue
                }
                break
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
            let kind = CrystallizationPlanner.kindForDurabilityMint(mode: mode)
            guard let plan = CrystallizationPlanner.plan(kind, tail: tail) else { return }
            let post = self.postID
            do {
                let minted = try await self.session.runner.run { ops in
                    try plan.mints.map { text -> CrystallizationReconciler.MintedBlock in
                        // **R-13u-3's ONE named exception** (13u1 UNIT 2):
                        // type-time crystallization is not a gesture she
                        // made — a paragraph becomes a block because she
                        // typed past it (AppSpec §7's "silently becomes a
                        // block as you type") — so it registers NO undo
                        // entry. Registering here would put one on her stack
                        // per paragraph AND clear the redo future on every
                        // one, which is the opposite of what ⌥⌘Z is for.
                        let result = try ops.newBlock(
                            in: post, text: text, at: .end, registeringUndo: false)
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
                // A delivery is a SIGNAL, never surface-rewrite authority
                // (mobile S3 ladder, MAJOR 3 — shared mechanism).
                applyProjection(value, fromDelivery: true)
            }
        } catch is CancellationError {
        } catch {
            statusMessage = "Note observation failed: \(error)"
        }
    }

    // MARK: - Projection → surface

    /// Internal so tests can drive projections without the observation.
    /// The DECISION lives in `EditorProjectionPolicy` (13b 1a — the
    /// precedence order is pinned as pure code); this executes it.
    func applyProjection(_ new: [Queries.RenderedBlock], fromDelivery: Bool = false) {
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
            delivery: fromDelivery,
            matchesSurface: ledger.matches(new, entries: index.entries),
            sameSequence: new.map(\.blockID) == index.entries.map(\.blockID))
        switch decision {
        case .initialRender:
            // First render: there is no local tail yet — the pre-load
            // index is a placeholder, never a tail to preserve. WHERE SHE
            // WAS is read BEFORE the fill (rows 39/49): the fill parks the
            // insertion point at the document's end and reports THAT as the
            // caret's block, so a landing that read the fact afterwards
            // would honor its own fill's side effect (the first cut did —
            // and landed at the last block's start).
            let arrivalFact = session.commandRouter.focusedBlock
            structural.renderFull(new, preserveTail: false)
            loaded = true
            applyFocusSeeds(arrivalFact: arrivalFact)
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
        case .refetchFresh:
            // Deliveries are SIGNALS (mobile S3 ladder, MAJOR 3 — the
            // retired Phase 8 clean-instant guarantee restored): a value
            // fetched before the flush that just settled would regress
            // surface + ledger to pre-flush bytes. Hold the marker and
            // settle by the ONE fresh-read path — the fresh value comes
            // back as non-delivery and takes the render arms above.
            pendingProjection = new
            applyPendingIfClean()
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
        // 13g batch 2 (L7): the `setAttributes` above resets the replaced span
        // to base, so the markdown face over those lines is re-derived here.
        // Attributes only — the seam edit's own bytes are already in place and
        // are not touched.
        MarkdownStyling.restyle(
            storage,
            range: NSRange(
                location: edit.replaceRange.location,
                length: (edit.replacement as NSString).length))
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
        // The tiling the gate last answered against is gone (mobile round 2,
        // the crash fix): disarm STRUCTURALLY at the ONE rewrite door rather
        // than leaning on the consume-time predicate alone.
        pendingEdit = nil
        bulkPending = false  // armed BESIDE it; it goes with it (NIT 4)
        self.index = index
        self.slots = slots
        adoptSurfaceTextMap(slots)
        if let tailText { self.tailText = tailText }
        // 13l L-a: the ONE tiling-write door, so the phone's three
        // index-replacement call sites (full render, differential, take
        // flip) are covered here by one line — every executor writes the
        // storage BEFORE it adopts, so the projection is settled by now.
        auditIdentityProjection()
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
    /// **17b P36 — is a projection still waiting?** A fact on the model
    /// rather than a private field a pin cannot see, for the reason the
    /// house style already gives elsewhere: a branch that decides whether
    /// an external change ever reaches the surface should be checkable.
    var hasDeferredProjection: Bool { pendingProjection != nil }

    func applyPendingIfClean() {
        guard !autosave.isDirty, !mintInFlight, !structuralInFlight,
              pendingProjection != nil else { return }
        // **17b P36: hold the marker while the re-read runs.** The two
        // guards below both put a value BACK on their failure paths; this
        // method's own read-failure arm returned bare, so a thrown read —
        // the plausible trigger being a re-lock closing the keyed store
        // while a settle is in flight (`StoreLockedError`) — dropped the
        // deferred marker and nothing re-armed it. The externally-changed
        // projection (a sync-applied conflict take, a chosen-variant flip
        // from another surface) then waited on the next ValueObservation
        // delivery, which only fires on a FURTHER store change.
        let deferred = pendingProjection
        pendingProjection = nil
        // The deferred value was fetched BEFORE the flush that just landed —
        // applying it as-is would transiently revert the actively edited
        // block to its pre-flush text (review round 1, MAJOR 2). Re-fetch:
        // the fresh projection includes our flush, so the echo check passes
        // and only genuinely external changes touch the view.
        let generation = storeWriteGeneration
        Task { [weak self] in
            guard let self else { return }
            guard let fresh = try? await session.database.read({ [postID] in
                try Queries.renderPost($0, containerID: postID)
            }) else {
                // The re-read failed: restore the marker, exactly as the two
                // guards below do with theirs (17b P36). The value is a
                // stale photograph, so what this buys is the RETRY — the
                // next clean moment re-reads instead of the surface sitting
                // on pre-change content until some later write happens.
                pendingProjection = deferred
                return
            }
            guard !autosave.isDirty, !mintInFlight, !structuralInFlight else {
                pendingProjection = fresh
                return
            }
            guard generation == storeWriteGeneration else {
                // A settle landed DURING the read (the value may predate
                // its writes — MAJOR 3's fence): re-signal; the loop
                // converges the moment the store goes quiet.
                pendingProjection = fresh
                applyPendingIfClean()
                return
            }
            applyProjection(fresh)
        }
    }

    // MARK: - Edit routing (the delegate entry points)

    func shouldChangeText(in range: NSRange, replacement: String?) -> Bool {
        guard !suppressEditProcessing else { return true }
        if header?.locked == true {
            refuseFeedback("This note is sealed — unlock it to edit.")
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
        // NIT 4 (round-2 ladder round 2): `bulkPending` is armed BESIDE the
        // verdict off this same call, so every road that drops the arming
        // drops the intent with it — NIT 8's doctrine applied consistently
        // rather than only where a bug was traced, and the phone's exact
        // shape (M-B). The two sites that deliberately do NOT clear it are
        // named at their own lines: the consume road (clears only when the
        // arming is DECLINED) and `finishCrystallization` (a
        // paste-during-mint's intent is carried across the flight on
        // purpose).
        case .refuse(.indexDesync):
            // The index no longer describes the storage: recover from the
            // store instead of crashing (review round 1, MINOR 7).
            pendingEdit = nil
            bulkPending = false
            desyncRecovery()
            return false
        case .refuse(.crossesBlockBoundary):
            // Phase 11, A9: the keystroke is refused HERE (the storage must
            // not half-apply it) and a compound reproduces its exact intent
            // through the structural door. **13u1 UNIT 2 — her item 5:**
            // the two roads that used to split by fan arity are ONE
            // cross-block compound now (`planCrossBlockEdit` ▸
            // `CrossBlockCompound`), which takes fanned and unfanned spans
            // alike: blocks the selection covers WHOLE ride `deleteBlock`
            // (the Trash/tray road), the surviving ends take their chosen
            // takes' edits, and the ends join only where both cuts sit
            // mid-paragraph and no fan hangs on either (R-13u-2 + #11a).
            // Only two things still refuse: a sealed note (above, before any
            // plan runs) and a LOCKED take anywhere in the run — refuse
            // whole, naming the lock (R-13u-1). The gap fence and the tail
            // keep their own refusals, which are not about the gesture.
            pendingEdit = nil
            bulkPending = false
            // QoL batch 3 (L6) — THE SAFETY CORE, and it runs before every
            // planner: a FIND-DRIVEN replacement never restructures the post.
            // Below this line a cross-block edit can DELETE and MERGE blocks
            // — ratified for a deliberate hand-made selection, never for a
            // machine-driven sweep. `EditorFind` pre-checks every range, so
            // reaching here under the flag means the text moved underneath a
            // checked range; it refuses and says so.
            if textView?.isFindReplacing == true {
                refuseFeedback(FindReplaceGate.refusal(single: .crossesBlockBoundary))
                return false
            }
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
            } else if let whole = planWholeBlockDeletion(range: range, replacement: replacement) {
                // 13j J9 (her ruling): a selection covering exactly N WHOLE
                // blocks + Delete IS the delete gesture — it routes to the
                // 13e batch-4 delete compound (ONE ⌥⌘Z entry, redo carried)
                // instead of refusing. It sits BELOW the two seam carves
                // deliberately: their geometry is a single separator, which
                // `wholeBlockRun` excludes by construction — so A7's
                // no-fan/nothing-unshown authorization and #34's fan refusal
                // keep every case they ruled, and this road can never route
                // around them. It sits ABOVE the compound because a run of
                // whole paragraphs plus Delete means "these paragraphs go",
                // and that road keeps its OWN ruling — #33(a)'s unrestricted
                // delete, which takes a locked take's block, where the
                // compound refuses whole for one (R-13u-1). Two gestures,
                // two rulings, in her stated order.
                scheduleCrossBlockCompound { [weak self] in
                    await self?.runWholeBlockDeletion(whole)
                }
            } else if let inBlock = planClampedInBlockEdit(
                range: range, replacement: replacement) {
                // **#109's SHAPE (i), her ruling of 2026-09-15:** a span
                // touching only ONE block's characters plus the separator at
                // one end CLAMPS to that block's text and edits — *"if it's
                // on the boundary, why not treat it as just part of that one
                // block?"* The break she selected stands, which is R-13u-2
                // speaking rather than a compromise of it.
                //
                // **It sits BELOW J9 deliberately.** A whole paragraph plus
                // its newline plus Delete is her J9 gesture and the paragraph
                // GOES (tray, Put back real); clamping first would have left
                // an empty block instead. J9 declines a type-over, which is
                // why the same span typed over lands here and replaces the
                // block's text in place.
                //
                // **And BELOW the seam carves**, which own the one-character
                // separator keystroke whole: a lone-separator DELETE is A7's
                // carve or #34's merge, with their own authorizations and
                // their own refusals, and this road's "nothing to do" guard
                // declines it so it can never route around them.
                scheduleCrossBlockCompound { [weak self] in
                    self?.runClampedInBlockEdit(inBlock)
                }
            } else if let compound = planCrossBlockEdit(range: range, replacement: replacement) {
                // **THE CROSS-BLOCK COMPOUND** (13u1 UNIT 2 — item 5). One
                // gesture, one structural compound, one ⌥⌘Z entry.
                scheduleCrossBlockCompound { [weak self] in
                    await self?.runCrossBlockEdit(compound)
                }
            } else {
                // 13j J8(b): the refusal DIAGNOSES. Every road above declined
                // for a reason this arm can still see — the range, the index's
                // tiling and the projection beside it — so the line names that
                // one reason instead of listing three.
                refuseFeedback(
                    CrossBlockRefusal.message(range: range, index: index, slots: slots))
            }
            return false
        case .refuse(let refusal):
            pendingEdit = nil
            bulkPending = false
            refuseFeedback(message(for: refusal))
            return false
        default:
            // Bulk entry is a TAIL concept only: a paste routed into an
            // existing block is a content edit of that block, and a refused
            // paste must not arm anything (review round 1, MAJOR 3).
            if case .tail = verdict, textView?.isPasting == true {
                bulkPending = true
            }
            pendingEdit = ArmedEdit(
                verdict: verdict, range: range, documentLength: index.documentLength,
                replacementLength: (replacement as NSString).length)
            return true
        }
    }

    /// The exact-changed-range report (NSTextStorage didProcessEditing,
    /// characters only). `editedRange` is the NEW characters' range; the old
    /// length is `editedRange.length - delta`.
    func storageDidEdit(_ editedRange: NSRange, changeInLength delta: Int) {
        // 13u3 ladder round 1, R1-1: this method IS the storage's edit
        // transaction (`didProcessEditing` calls it before the edit closes),
        // and a layout-forcing geometry query in here is TEXTKIT2 §2's own
        // estimation hazard — sampled once for real as a whole-app spin in
        // `_estimatedTextLocationForVerticalOffset` (the UNIT B record's
        // frames). The flag is what `updateCaretContext`'s indicator arm
        // consults to defer its decoration refresh onto the settle hop this
        // same method arms one line below.
        enterStorageEditTransaction()
        defer { exitStorageEditTransaction() }
        // N14: EVERY storage character edit dirties overlay geometry — the
        // suppressed programmatic writes included (renderFull's
        // setSurfaceContent is exactly the cold-mount path). The refresh
        // itself waits for the layout pass that consumes the edit
        // (`overlayLayoutDidSettle`), never runs against pre-layout frames.
        overlayGeometryGeneration &+= 1
        guard !suppressEditProcessing else { return }
        // THE BINDING (mobile round 2, batch 1 — the shared crash fix): the
        // gate's answer is consumed ONLY while it still describes the edit
        // that arrived; anything else falls through to `fallbackVerdict`,
        // which recomputes against the pre-edit index. The Mac's exposure is
        // narrower than iOS's and stayed un-triggered on accidents rather
        // than guarantees — AppKit's near-1:1 typing contract, cross-block
        // spans answered by compounds instead of left to storage,
        // `EditorSurfaceDelegate`'s multi-range gate refusing outright, and
        // `EditorFind`'s hand-written 1:1 discipline around the ONE AppKit
        // road that does coalesce. Any of the arm-then-hand-off sites
        // (`MarkdownActs.apply`, `toggleCheckbox`,
        // `insertNewlineContinuingLists`, `deleteWithoutNewline`) is one
        // refactor away from separating an arming from its
        // `replaceCharacters`; the binding makes that harmless.
        let armed = pendingEdit
        pendingEdit = nil
        let bound = armed.flatMap {
            $0.describes(
                editedRange: editedRange, delta: delta,
                documentLength: index.documentLength) ? $0 : nil
        }
        if armed != nil, bound == nil {
            // M13's Mac twin (round-2 ladder round 1, MINOR 5): the paste's
            // bulk-entry intent is armed BESIDE the verdict, off the same
            // gate call, so a discarded arming takes it along. Otherwise
            // the flag outlives the edit that never became the paste it
            // described and the next crystallization mints `.bulk` instead
            // of `.typing`. The finding traced the phone; the shape here is
            // line for line the same, and a latent twin is what the whole
            // batch-1 Mac verdict was about.
            bulkPending = false
        }
        let verdict = bound?.verdict ?? fallbackVerdict(editedRange: editedRange, delta: delta)
        switch verdict {
        case .block(let i):
            // The mutators REFUSE rather than trap. A refusal means the
            // bookkeeping and the storage have already diverged, so nothing
            // below may run against it — `desyncRecovery`'s re-render from
            // the store redoes the attribute work and the caret context
            // over the truth.
            guard index.applyBlockEdit(at: i, lengthDelta: delta) else {
                desyncRecovery()
                return
            }
            // CLAMPED, and the clamp is the fix (13l L-a — found by the
            // identity audit on its first Mac run; see `stampProjection`).
            // One walk for both consumers: the range is the entry's, and
            // `recordAutosave` needs exactly the same one.
            let entryRange = index.range(ofEntryAt: i)
            stampProjection(index.entries[i].blockID, reported: editedRange, within: entryRange)
            recordAutosave(
                entryIndex: i, entryRange: entryRange,
                editedRange: editedRange, delta: delta,
                // 13u1 UNIT 1 (the sweep's P24 + P25): the GATE's exact
                // cost where the gate answered — the other half of the
                // clamp rule applied one line above. Nil only where the
                // arming did not bind (a system path outside the policed
                // ones), which is exactly where the report is all there is.
                exactCost: bound?.exactCost)
        case .tail:
            guard index.applyTailEdit(lengthDelta: delta) else {
                desyncRecovery()
                return
            }
            stampProjection(nil, reported: editedRange, within: tailProjectionRegion)
            syncTailText()
            crystallizeIfNeeded()
            armTailIdleMint()
        case .openTail:
            guard index.openTail() else {
                desyncRecovery()
                return
            }
            stampProjection(nil, reported: editedRange, within: tailProjectionRegion)
            tailText = ""
        case .closeTail:
            guard index.closeTail() else {
                desyncRecovery()
                return
            }
            tailText = ""
            tailIdleTask?.cancel()
        case .refuse:
            // An edit reached the storage without a routable verdict (an
            // AppKit path outside the policed ones). The store is truth:
            // drop local bookkeeping and re-render from the projection.
            desyncRecovery()
            return
        }
        // 13g batch 2 (L7, F-2): the markdown face follows the keystroke,
        // scoped to the LINES the edit touched — P1's letter, pinned by
        // `MarkdownScanCount`. Attribute-only, so it moves no byte and
        // registers nothing with NSTextView's undo; and the delegate's
        // `.editedCharacters` guard means these attribute edits cannot
        // re-enter here.
        if let storage = textView?.textStorage {
            MarkdownStyling.restyle(storage, range: editedRange)
        }
        // 13l L-a: the per-keystroke oracle, at the end of the road the
        // corruption class travels (the phone's own call site, mirrored).
        auditIdentityProjection()
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

    /// **The projection is a PROJECTION, and the report is a hint about
    /// WHERE — never a licence over WHAT** (13l L-a).
    ///
    /// MEASURED on macOS 26 (the pin `aKeystrokeNeverStampsItsSeparator`):
    /// `NSTextStorage` attribute fixing WIDENS the reported edited range to
    /// the whole paragraph *including its terminator* — a one-character
    /// insertion at offset 2 of "Alpha\n…" reports `{2, 5}`. Stamping the
    /// block's ID over that report therefore wrote the block's identity onto
    /// the SEPARATOR after it, on every keystroke in every non-last block,
    /// silently breaking the doctrine `EditorDocumentCore` states as holding
    /// "by construction": *the separator is owned by NEITHER neighbour, and
    /// attribute ownership and range math therefore agree.*
    ///
    /// (The round-2 crash trace recorded "AppKit does not widen" from the
    /// insertion cases it measured; this is the same measurement taken at a
    /// paragraph END, where it does. `ArmedEdit.describes` was already right
    /// not to police the report's EXTENT — this is the other half of that
    /// same fact, at the site that consumes the extent.)
    ///
    /// Nothing legitimate is lost by clamping: a `.block(i)` verdict MEANS
    /// the edit is owned entirely by entry `i`, so any part of the report
    /// outside that entry describes characters the verdict never claimed.
    private func stampProjection(_ blockID: String?, reported: NSRange, within region: NSRange) {
        setBlockAttribute(blockID, over: NSIntersectionRange(reported, region))
    }

    /// Everything a tail edit may clear the block attribute over: the tail
    /// itself PLUS its leading separator (which must carry no ID either).
    /// Empty when there is no tail region — a widened report then stamps
    /// nothing, which is the honest answer.
    private var tailProjectionRegion: NSRange {
        guard let tail = index.tailRange else {
            return NSRange(location: index.documentLength, length: 0)
        }
        guard let separator = index.tailSeparatorOffset else { return tail }
        return NSRange(location: separator, length: tail.upperBound - separator)
    }

    /// **The churn cost is the EDIT's, never the REPORT's** (13u1 UNIT 1 —
    /// the 2026-08-30 sweep's P24 + P25, one mechanism found by two lenses).
    ///
    /// `container.last_major_revision_at` exists so that *fixing one typo
    /// never reshuffles the library* (CoreDescription pillar 7; the math is
    /// AppSpec §10). This derived its cost from the RAW `NSTextStorage`
    /// edited-range report — and macOS 26's attribute fixing WIDENS that
    /// report to the paragraph's end INCLUDING the terminator, which this
    /// repo measures and pins two files away
    /// (`IdentityProjectionAuditTests.appKitWidensAnInsertionsReportedRangeToTheParagraph`:
    /// one character at offset 2 of "Alpha" reports `{2, 5}`). So a single
    /// typed character recorded **nine** — `(5 − 1) + 5` — and in general
    /// ≈ 2 × the distance from the caret to the paragraph's end. Measured
    /// here too: a 4-for-2 replacement recorded 8.
    ///
    /// 13l applied TEXTKIT2_NOTES §3's rule — *clamp to the VERDICT's range,
    /// never the report's* — to `stampProjection` and not to this
    /// arithmetic. `exactCost` is the same rule at the same seam: the gate
    /// knew `range.length + replacementLength` before anything reached
    /// storage, and the value was hoisted for both platforms at mobile round
    /// 2 with only the phone ever reading it.
    ///
    /// **`exactCost` is nil only when the arming did not BIND** — a system
    /// path outside the policed ones, where `fallbackVerdict` recomputes and
    /// the report genuinely is all there is. The old arithmetic stays as
    /// that fallback, unchanged and now honestly scoped.
    ///
    /// Pinned by `EditorChurnCostTests` (three pins, red on old: 9 vs 1,
    /// 8 vs 6, and a stamped major revision after three typo keystrokes).
    private func recordAutosave(
        entryIndex: Int, entryRange: NSRange, editedRange: NSRange, delta: Int,
        exactCost: Int?
    ) {
        let entry = index.entries[entryIndex]
        guard let variantID = entry.variantID else {
            EditorAssertionSeam.fire("editable entry without a variant")
            return
        }
        let text = viewText(entryRange)
        // The edited block's surface truth, for echo detection (Step 1):
        // this extraction is O(the edited block) and already paid for the
        // autosave itself.
        ledger.recordEdit(variantID: variantID, text: text)
        let oldLength = editedRange.length - delta
        autosave.record(
            variantID: variantID, text: text,
            charDelta: exactCost ?? (oldLength + editedRange.length))
    }

    // MARK: - The DEBUG identity audit (13l L-a — the phone's oracle, hoisted)

    /// Runs the shared walk and, on a disagreement, counts it and fires the
    /// honest road's debug voice.
    ///
    /// **Why the Mac needs this at all.** The editor already has two
    /// oracles, and BOTH are satisfied by the corruption class this one
    /// exists for: `documentLength == storage.length` compares TOTALS,
    /// which a mis-routed ZERO-NET edit leaves agreeing, and
    /// `desyncRecoveryCount` counts edits the router REFUSED, which is
    /// precisely what a mis-routed edit is not. The mobile round reproduced
    /// that shape against this view model — the gate's approval consumed by
    /// a transaction landing one block over, block 1's ID stamped across
    /// block 2's characters, and `recordAutosave` writing the wrong text to
    /// the store through the ledger — with `desyncRecoveryCount == 0` and
    /// the totals agreeing the whole time. Nothing announced it. This is
    /// the thing that announces it.
    ///
    /// DEBUG-only and O(blocks): it runs at the per-keystroke road's end
    /// and at every door that replaces the tiling.
    func auditIdentityProjection() {
        #if DEBUG
        guard let storage = textView?.textStorage else { return }
        guard !IdentityProjectionAudit.isClean(index: index, storage: storage) else { return }
        identityAuditFailures += 1
        EditorAssertionSeam.fire(IdentityProjectionAudit.failureMessage)
        #endif
    }

    private func desyncRecovery() {
        desyncRecoveryCount += 1  // the Step 8 soak asserts this stays 0
        EditorAssertionSeam.fire("editor surface desynced from the block index")
        forceFullRender = true
        pendingEdit = nil
        bulkPending = false  // armed BESIDE it; it goes with it (NIT 4)
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
        crystallizeIfNeeded(forcedKind: CrystallizationPlanner.kindForDurabilityMint(mode: mode))
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
            ?? CrystallizationPlanner.kindForTailEdit(mode: mode, bulkPending: bulkPending)
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
                        // **R-13u-3's ONE named exception** (13u1 UNIT 2):
                        // type-time crystallization is not a gesture she
                        // made — a paragraph becomes a block because she
                        // typed past it (AppSpec §7's "silently becomes a
                        // block as you type") — so it registers NO undo
                        // entry. Registering here would put one on her stack
                        // per paragraph AND clear the redo future on every
                        // one, which is the opposite of what ⌥⌘Z is for.
                        let result = try ops.newBlock(
                            in: post, text: text, at: .end, registeringUndo: false)
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
        storeWriteGeneration &+= 1 // our mint's writes settled (MAJOR 3's fence)
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
        // A verdict armed before the mint describes a tail that may no
        // longer exist (see `adoptRewrite`) — the sharpest stale case, since
        // a `.tail` arming survives into a closed tail.
        //
        // `bulkPending` deliberately does NOT go with it here (the one
        // exception to NIT 4's rule, beside the consume road's conditional
        // clear): a paste that arrived DURING the mint parked its intent
        // here on purpose, and the crystallization re-run consumes it.
        pendingEdit = nil
        index.crystallize(
            minted: outcome.applied.map { ($0.blockID, $0.variantID, $0.text.utf16.count) },
            remainingTailLength: outcome.newTail?.utf16.count)
        tailText = outcome.newTail ?? ""
        let firstNew = index.entries.count - outcome.applied.count
        // ONE tiling walk for the whole mint (13u1 UNIT 1 — the O(N²) class,
        // this member found by its own sweep rule): the accessor walks from
        // zero, so stamping M freshly-minted paragraphs over a note of N
        // blocks cost O(M·N) — and a bulk paste makes M large.
        let ranges = index.entryRanges()
        for (offset, block) in outcome.applied.enumerated() {
            let range = ranges[firstNew + offset]
            if range.length > 0 {
                setBlockAttribute(block.blockID, over: range)
            }
        }
        // 13l L-a: crystallization mints entries and stamps their attributes
        // by hand — the phone audits here for the same reason.
        auditIdentityProjection()
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

    // MARK: - 18c batch 2 (U-1): the Return key makes a block, anywhere

    /// The typed Return's act over the LIVE surface — the pure decision
    /// (`TypedReturn.act`) with this model's caret, tiling, chip and text.
    /// `textAt` reads the view, lazily and for the caret's entry only, so a
    /// keystroke costs one block's text and never the document (P1) — the
    /// `gestureWorld` shape exactly.
    func typedReturnAct() -> TypedReturn.Act {
        guard let textView else { return .content }
        return TypedReturn.act(
            selection: textView.selectedRange(),
            index: index,
            segmentation: header?.effectiveSegmentation ?? .paragraph,
            textAt: { [weak self] i in
                guard let self, i >= 0, i < index.entries.count else { return "" }
                return viewText(index.range(ofEntryAt: i))
            })
    }

    /// The key's own answer: TRUE when the Return became a structural act
    /// (so no newline is typed). The act itself runs on the next main-actor
    /// turn through the deferred-keystroke seam — chained, so two fast
    /// Returns compose instead of racing — and it RE-DERIVES the decision
    /// there against the surface the previous one left behind.
    func runTypedReturn(afterListExit: Bool = false) -> Bool {
        // 18c ladder round 2, R2-2: DECIDE, THEN ACT. The chip's answer is
        // read once, before anything touches the surface — under `one_block`
        // the key is content again (U-19 (3)) and the exit is 13k K5's,
        // unchanged: the lead goes and she stays on the empty line. The
        // retraction below exists because U-1 moves the caret INTO a new
        // block and orphans that line; under the chip nothing moves her, so
        // retracting there deleted the line she stood on and left ⏎ unable
        // to end a list at all (`"- one\n- "` ⇄ `"- one"`, forever — every
        // journal note, which seeds `one_block`). No other road may mutate
        // ahead of this guard.
        guard header?.effectiveSegmentation != .oneBlock else { return false }
        if afterListExit { retractListContinuationNewline() }
        guard typedReturnAct() != .content else { return false }
        // 18c ladder round 1, R1-2: from this claim until the act has
        // landed, every key event is stashed and replayed at the landed
        // caret — the claim-to-turn gap would otherwise put a character
        // into the block the caret is about to leave, and the flight itself
        // would drop it against the disabled surface.
        textView?.beginDeferringKeystrokes()
        structural.scheduleTypedReturn()
        return true
    }

    /// **18c ladder round 1, R1-3 (PROVISIONAL — QUESTIONS #94):** when an
    /// EMPTY list item's ⏎ has just retracted its lead (`.exitList`) and
    /// that item was the block's LAST line, the newline the continuation
    /// typed one keystroke earlier goes with it — through the ordinary
    /// editing path — so ⏎⏎ after a list ends the block at its last item
    /// exactly as ⏎ ends a prose paragraph, and no blank last line is left
    /// behind. Only the continuation's OWN newline is retracted: the line
    /// before it must itself be a list line (a continuation always follows
    /// one), so a blank line she typed above the item (U-19 (2)) is never
    /// touched, and an item mid-block keeps the seam's k−1 spacing (A11).
    /// A RESTORATION of the gesture's pre-U-1 shape, not a new behaviour:
    /// K5 left the caret ON that line, where prose continued in the same
    /// block; U-1 moves it into a new block, which is what turned the line
    /// into a leftover. **Chip ON only** (round 2, R2-2 — the guard sits in
    /// `runTypedReturn`, ahead of this call).
    ///
    /// **A gap, named (18c ladder round 2, R2-3):** this deletion and the
    /// exit's own lead deletion (`MarkdownActs.deleteWithoutNewline`) are
    /// two text-undo registrations for one keystroke, against K5's
    /// one-group rule for the continuation. Unreachable today — the act
    /// that follows a retraction is always a structural flight (the block
    /// holds the list it just exited, and R1-4's line-end rule excludes
    /// `.content`; the empty block's old no-op arm retired with R-13u4-2 and
    /// would mint here too), and every structural rewrite clears the
    /// text-undo stack (R-2 residual 1) — and live the day 13u1 relaxes
    /// that directive: group the two then.
    private func retractListContinuationNewline() {
        guard let textView else { return }
        let selection = textView.selectedRange()
        guard selection.length == 0, selection.location != NSNotFound,
              selection.location > 0
        else { return }
        let caret = selection.location
        // The caret's entry (never the tail), and the caret must sit at its
        // END — the item was the block's last line.
        var location = 0
        var entryStart: Int?
        for entry in index.entries {
            if caret >= location, caret <= location + entry.length {
                guard caret == location + entry.length else { return }
                entryStart = location
                break
            }
            location += entry.length + 1
        }
        guard let entryStart, caret - 1 >= entryStart else { return }
        let text = textView.string as NSString
        guard text.character(at: caret - 1) == 0x0A else { return }
        let previous = text.range(
            of: "\n", options: .backwards,
            range: NSRange(location: entryStart, length: caret - 1 - entryStart))
        let previousStart = previous.location == NSNotFound ? entryStart : previous.location + 1
        let previousLine = text.substring(
            with: NSRange(location: previousStart, length: caret - 1 - previousStart))
        guard MarkdownSyntax.isListLead(previousLine) else { return }
        let range = NSRange(location: caret - 1, length: 1)
        OrdinaryInputEdit.apply("", over: range, in: textView)
    }

    /// **18c ladder R1-1 — the ONE tail-opening predicate, asked before a
    /// newline lands.** `BlockRangeIndex.verdict`'s own answer for a single
    /// plain newline at the caret: TRUE exactly when that newline would be
    /// the ratified open-tail gesture (the document end, no tail, a
    /// segmenting note). The list door consults it so its continuation can
    /// take the soft road there instead of opening the tail U-1 retired
    /// from the key; asking the verdict rather than restating its condition
    /// keeps the door and the verdict one rule.
    func typedNewlineWouldOpenTail() -> Bool {
        guard let textView else { return false }
        let selection = textView.selectedRange()
        guard selection.length == 0, selection.location != NSNotFound else { return false }
        return index.verdict(
            replacing: selection, replacementIsSingleNewline: true,
            segmentation: header?.effectiveSegmentation ?? .paragraph) == .openTail
    }

    /// Closes an EMPTY open tail by deleting its separator through the
    /// ORDINARY editing path (`BlockRangeIndex.Verdict.closeTail` — "no
    /// block text is touched, only the render artifact goes", and no store
    /// write happens because the tail was never a block).
    ///
    /// This is the trap §4.1 of the use-report round traced: the idle mint
    /// leaves an empty tail open, the tail road plans nothing over `""`, and
    /// a Return there produced her "several new lines". U-1's act closes it
    /// and mints the block instead. The shape is `MarkdownActs`'
    /// `deleteWithoutNewline`: `shouldChangeText` → `replaceCharacters` →
    /// `didChangeText`, so the index, autosave and every refusal see an
    /// ordinary edit with no new refusal code.
    func closeEmptyTailSeparator() {
        guard let textView, index.tailLength == 0,
              let separator = index.tailSeparatorOffset
        else { return }
        let range = NSRange(location: separator, length: 1)
        guard range.upperBound <= (textView.string as NSString).length else { return }
        OrdinaryInputEdit.apply("", over: range, in: textView)
    }

    // MARK: - #109's SHAPE (i): clamp and EDIT (13u2 UNIT C)

    typealias ClampedInBlockEdit = CrossBlockCompound.InBlockEdit

    /// Her #109 ruling's shape (i): a span touching only ONE block's
    /// characters plus the separator at one end. The selection clamps to that
    /// block's text and the gesture becomes an ORDINARY in-block edit; the
    /// break she selected stands (R-13u-2's own consequence).
    ///
    /// The geometry is the shared brain's — the phone consumes the same rule
    /// — and what is per-platform is only the road it lands on.
    func planClampedInBlockEdit(range: NSRange, replacement: String) -> ClampedInBlockEdit? {
        CrossBlockCompound.clampedInBlockEdit(
            replacing: range, with: replacement, index: index,
            surfaceText: { [weak self] range in self?.viewText(range) ?? "" })
    }

    /// **The ordinary input path, deliberately — this road is NOT
    /// structural.** After the clamp the edit sits inside one block, so it
    /// takes `shouldChangeText` → `replaceCharacters` → `didChangeText` (the
    /// ONE input door, `OrdinaryInputEdit`): the index bookkeeping, the
    /// autosave arming, every existing refusal AND **⌘Z's ordinary text
    /// undo** all work unchanged. Routing it through a structural compound
    /// would have registered an ⌥⌘Z entry and cleared the text-undo stack for
    /// what is, after the clamp, a plain deletion inside one paragraph — the
    /// *"headache compared to using a different editor"* her item 5 exists to
    /// end.
    ///
    /// **It runs on the NEXT main-actor turn** (the caller schedules it on
    /// the same chain the cross-block compound uses): the keystroke itself
    /// must be refused synchronously, because the storage must never
    /// half-apply a span AppKit was handed and this road did not take, and a
    /// mutation issued from inside `shouldChangeText` would re-enter the text
    /// system mid-flight.
    ///
    /// **COMPARE-AND-SET before a character moves.** A chained compound can
    /// land in that window, so the plan-time surface text and document length
    /// are verified first — the same discipline `editTakesAtomically`'s
    /// `expectedText` gives the compound, and the same words when it fails.
    /// It also makes the re-entrant gate consult below provably terminal: a
    /// verified-unchanged index answers `.block(i)` for the clamped range, so
    /// this road can never re-clamp and re-schedule itself.
    func runClampedInBlockEdit(_ edit: ClampedInBlockEdit) {
        guard let textView else { return }
        guard index.documentLength == edit.documentLength,
              edit.range.upperBound <= (textView.string as NSString).length,
              viewText(edit.range) == edit.expectedText
        else {
            refuseFeedback(
                "The text changed while that gesture was landing — nothing was altered; "
                    + "try it again on the current text.")
            return
        }
        guard OrdinaryInputEdit.apply(edit.replacement, over: edit.range, in: textView)
        else { return }  // the pipeline refused and has already spoken
        let caret = edit.range.location + (edit.replacement as NSString).length
        textView.setSelectedRange(NSRange(location: caret, length: 0))
    }

    // The three doors' entry points (menu bar, context menu, shortcut all
    // land here; enablement used the same planner call).
    func divideAtCursor() { performGesture(.divideAtCursor) }
    func extractSelection() { performGesture(.extractSelection) }
    func makeBlockFromSelection() { performGesture(.makeBlockFromSelection) }
    func mergeBlocks() { performGesture(.mergeBlocks) }
    // 18f batch 1 (U-4): the two SUMMONED doors, so the bottom bar's block ▾
    // rows land the same act ⌥⌘⇧D / ⌥⌘⇧M land — one body, however many doors.
    func divideAtCursorWithCeremony() { performGesture(.divideAtCursor, ceremony: true) }
    func mergeBlocksWithCeremony() { performGesture(.mergeBlocks, ceremony: true) }

    private func performGesture(
        _ command: StructuralGesturePlanner.Command, ceremony: Bool = false
    ) {
        Task { await invokeGesture(command, ceremony: ceremony) }
    }

    // ——— The gesture-execution band lives in `EditorSurfaceController`
    // (13b Stage 3, N10 — moved TOGETHER with the projection executors,
    // the recorded one-seam move); these forwards keep every door, view,
    // and pin call site reading unchanged. ———

    /// Plans against the CURRENT selection and applies (the controller's).
    /// `ceremony` (13j J4/J4b) names the DOOR, not a plan shape.
    func invokeGesture(
        _ command: StructuralGesturePlanner.Command, ceremony: Bool = false
    ) async {
        await structural.invokeGesture(command, ceremony: ceremony)
    }

    /// THE one door for structural changes to the surface (the
    /// controller's).
    func applyStructural(
        _ plan: StructuralGesturePlanner.Plan, ceremony: Bool = false
    ) async {
        await structural.applyStructural(plan, ceremony: ceremony)
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

    /// The cross-block compound's plan (the controller's).
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

    /// 13j's Write door (her round-7 ruling): archive the caret block.
    func archiveCaretBlock() async {
        await structural.archiveCaretBlock()
    }

    /// 13e E2's Write door (her A17): every ⌘-clicked block, one undo entry.
    func deleteSelectedBlocks() async {
        await structural.deleteSelectedBlocks()
    }

    // MARK: - 13j J9 — a whole-block selection + Delete, forwards

    typealias WholeBlockDeletion = EditorSurfaceController.WholeBlockDeletion

    func planWholeBlockDeletion(range: NSRange, replacement: String) -> WholeBlockDeletion? {
        structural.planWholeBlockDeletion(range: range, replacement: replacement)
    }

    func runWholeBlockDeletion(_ plan: WholeBlockDeletion) async {
        await structural.runWholeBlockDeletion(plan)
    }

    // MARK: - 13e batch 3 (her A20/A21) — take ↔ block, forwards

    func moveCaretTakeIntoBlockBelow() async {
        await structural.moveCaretTakeIntoBlockBelow()
    }

    func turnCaretBlockTakesIntoBlocks() async {
        await structural.turnCaretBlockTakesIntoBlocks()
    }

    // MARK: - 13d batch 2 (#34) — backspace at a texted seam

    typealias SeamMerge = EditorSurfaceController.SeamMerge

    func planSeamMerge(range: NSRange, replacement: String) -> SeamMerge? {
        structural.planSeamMerge(range: range, replacement: replacement)
    }

    func runSeamMerge(_ plan: SeamMerge) async {
        await structural.runSeamMerge(plan)
    }

    /// The cross-block compound (the controller's).
    func runCrossBlockEdit(_ edit: CrossBlockEdit) async {
        await structural.runCrossBlockEdit(edit)
    }

    // MARK: - Phase 11, A9 — the #11 sitting rulings — forwards
    // (execution in `EditorSurfaceController`, 13b Stage 3, N10)
    //
    // #11a's visible-take road retired at 13u1 UNIT 2 — the compound above
    // answers every cross-block span and carries #11a's rule at the ends
    // (see `EditorSurfaceController`'s note where the road stood).

    /// #11b — "Delete in Every Take" (the controller's; the deliberate,
    /// NAMED command — apply-and-report, her ruling).
    func deleteInEveryTake() async {
        await structural.deleteInEveryTake()
    }

    /// 13u4 UNIT C2 (her item 9, R-13u4-4) — the selected span leaves the
    /// take it is in and becomes a take of its own on the same block (the
    /// controller's; one operation, one undo entry).
    func moveSelectionToNewTake() async {
        await structural.moveSelectionToNewTake()
    }

    // `StructuralSeam` lives beside its pure consumer in
    // StructuralSeamEdit.swift (review round 1, MINOR 5). `runStructural`,
    // the structural rewrite paths, and the DEBUG oracle live in
    // `EditorSurfaceController` (13b Stage 3, N10).

    /// Applies the one-shot focus-handoff seeds after the first render
    /// (Step 3): caret placement from the read-tier click, then the
    /// focus-then-fan panel where a badge tap drove the focus.
    private func applyFocusSeeds(arrivalFact: FocusedBlock? = nil) {
        var caretClaimed = false
        if let seed = pendingCaretSeed, let textView {
            pendingCaretSeed = nil
            let clamped = min(max(0, seed), max(0, index.documentLength))
            textView.setSelectedRange(NSRange(location: clamped, length: 0))
            textView.window?.makeFirstResponder(textView)
            updateCaretContext()
            // 17o batch b (ledger row 20, her words: *"Opening in write from
            // blocks puts your cursor in the right place but doesn't move you
            // there"*). This arm — the Blocks workbench's Open in Write, the
            // Index column's "Jump to block in Write", Read's `onJump`, the
            // canvas card's — placed the caret and never revealed it: on a
            // 250-paragraph note the caret's line measured y 6930 with the
            // viewport at 0…719. The reveal is `JumpPrimitive`, the Phase 6
            // hybrid jump (TEXTKIT2 §2): TK2 has not laid the document out at
            // this moment, so the primitive's single-fragment `ensuresLayout`
            // is exactly what makes the landing exact — and it is the only
            // ensureLayout this road performs (P1).
            revealLanding(clamped, textView: textView)
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
        // staleness discipline is untouched by construction). WHERE the
        // caret lands (the Act 10 correction round, rows 39 + 49): at the
        // start of the note's CURRENT block — the one fact every mode
        // enters on and leaves to (`CommandRouter.focusedBlock`, this
        // post's) — else the document start. Before this it landed at the
        // document's END on every arrival: the projection fill carried the
        // insertion point to the end, and the old "reset when past the
        // length" check could never be true (row 49's "block 262/262" on
        // opening a story). The window can lag the first projection by a
        // beat (attach precedes insertion), so a missing window gets ONE
        // next-turn retry, then gives up quietly.
        if !caretClaimed, scrollView != nil, let textView {
            // The LANDING is placed at once — it needs no window, and a
            // window-less first render's next-turn retry must never move a
            // caret she has since put somewhere (the K5 list pin caught the
            // first cut doing exactly that). The retry claims first
            // responder only.
            let remembered = rememberedArrivalLanding(fact: arrivalFact)
            let landing = remembered ?? 0
            textView.setSelectedRange(NSRange(location: landing, length: 0))
            // 17o batch b (rows 20/42): the REVEAL is the Phase 6 hybrid
            // jump, never `scrollRangeToVisible` — on TK2 the reveal runs
            // before the document below the viewport is laid out, so it
            // steers by the height ESTIMATE and lands short (measured on
            // a 250-paragraph note: the caret's line at y 6930 with the
            // viewport at 0…719). `JumpPrimitive` scrolls to a
            // proportional estimate, forces layout of the ONE target
            // fragment, and corrects — bounded, and the only ensureLayout
            // this target performs (P1; TEXTKIT2 §2).
            //
            // 17o batch d (ledger row 47; the batch-b ladder's cap, R3-1):
            // it runs at every REMEMBERED landing, 0 included. The old
            // `landing > 0` exemption was hollow while the cold-mount anchor
            // restore clamped at ~24 pt — it hid nothing, which is why round
            // 1 dismissed it — and round 2's RAISE-M1 made that restore
            // EXACT, so a remembered 0 under a far anchor left the caret off
            // screen and "⌘1 then type" typed where she could not see.
            //
            // The test is REMEMBERED, not `> 0`, because the two ruled
            // behaviours meet here: QUESTIONS #98(a) is about *the remembered
            // caret* — when it is not inside the restored view, its line
            // lands at the viewport top — while RAISE-M1 is about the anchor
            // she left. With nothing remembered there is no caret of hers to
            // honour, only a default, and revealing a default would haul the
            // page off the anchor the cold mount just restored (measured:
            // dropping the condition outright turned
            // `aColdMountRestoresTheSessionScrollAnchorAtTheSettleHop` red by
            // 6927 pt). Everything the reveal does beyond that is its own
            // visibility guard's: a remembered 0 the viewport already shows
            // still moves nothing.
            if remembered != nil {
                revealLanding(landing, textView: textView)
            }
            // 13u2b UNIT 3: and if she arrived here by a MODE SWITCH that
            // carried this block's place, that place outranks both landings —
            // parked for the same hop, taken from the router now so no other
            // editor rendering in this beat can consume it.
            parkCarriedPlacement(fact: arrivalFact)
            updateCaretContext()
            let claim = { [weak textView, weak self] in
                guard let textView, let window = textView.window else { return false }
                window.makeFirstResponder(textView)
                self?.updateCaretContext()
                return true
            }
            if !claim() {
                Task { @MainActor in _ = claim() }
            }
        }
    }

    /// **The ONE reveal for every landing in Write** (17o batch b): the Phase
    /// 6 hybrid jump, never `scrollRangeToVisible` — on TK2 a landing runs
    /// before the document below the viewport is laid out, so the caret-reveal
    /// scroll steers by a height ESTIMATE and lands short (measured: a caret
    /// 6,211 pt below the viewport on a 250-paragraph note). The DETAIL editor
    /// only: the inline book/pool editor scrolls inside its host's scroll view
    /// and has none of its own, and `JumpPrimitive` refuses a nil one anyway.
    private func revealLanding(_ offset: Int, textView: NSTextView) {
        guard scrollView != nil else { return }
        // PARKED, never performed here — measured, which is why: at the moment
        // a landing runs, `setSurfaceContent` has just replaced the storage and
        // the text view's FRAME is still the pre-fill height, so
        // `JumpPrimitive`'s scroll range (`docHeight − viewport`) is a couple of
        // dozen points and the correction loop clamps there. (The first cut
        // jumped here and left the caret 6,213 pt below the viewport with the
        // page scrolled by 24.) Every caller of this is inside
        // `applyFocusSeeds`, which runs on the INITIAL RENDER — so a geometry
        // generation always bumps first and the N14 layout-settle hop always
        // arrives. That hop is the first moment the frame is honest, and it is
        // where the reveal is spent.
        //
        // The ladder's R1-5: STAMPED with the geometry generation it was
        // parked under. A hop is scheduled with the generation it SAW, and
        // the empty editor's first display pass can queue hop(G₁) BEFORE the
        // projection drains — renderFull then bumps G₂ and parks here, and
        // that older hop would spend the park against the very frame the
        // park exists to wait out (the jump clamps at a couple of dozen
        // points; the honest hop(G₂) then finds nothing). A hop for an older
        // generation leaves the park alone; the bump guarantees hop(G₂).
        pendingRevealOffset = offset
        pendingRevealGeneration = overlayGeometryGeneration
    }

    /// The landing waiting for the post-layout settle (above). Cleared the
    /// moment it is spent, and abandoned if the caret has since moved — a
    /// second jump must never yank her away from a place she chose.
    @ObservationIgnored private(set) var pendingRevealOffset: Int?  // read by the R1-5 pin
    /// The generation the park was made under (R1-5) — a settle hop for an
    /// OLDER generation is not the one the park is waiting for.
    @ObservationIgnored private var pendingRevealGeneration = 0

    // MARK: - The session scroll anchor's restore, parked for the same hop (round 2, RAISE-M1)

    /// **The cold mount's anchor restore waits for the settle hop too** (the
    /// ladder's round 2, RAISE-M1 — verified in use: block 168 mid-viewport
    /// → ⌘2 → ⌘1 → the page re-topped on block 168). `renderFull` restored
    /// `editorRouter.scrollAnchors[postID]` through `JumpPrimitive.jump`
    /// against the PRE-FILL frame, whose `maxScroll` is a couple of dozen
    /// points — the very clamp the batch measured for the reveal and
    /// answered with the hop — so on every cold mount (a mode switch mints
    /// one) the anchor contributed nothing and the reveal decided the page
    /// alone. Parked here by `renderFull` on the initial render only (a warm
    /// re-render's frame is honest and its immediate restore is unchanged),
    /// stamped with the geometry generation like the reveal, and consumed in
    /// the hop BEFORE the reveal — so the reveal's guard then finds a caret
    /// inside the view she left and moves nothing (her row 7's page half).
    /// QUESTIONS #98 carries the product edge (the caret OFF the restored
    /// view: the top landing, built PROVISIONAL).
    func parkAnchorRestore(_ offset: Int) {
        guard scrollView != nil else { return }  // the inline editors scroll in their host
        pendingAnchorRestore = offset
        pendingAnchorGeneration = overlayGeometryGeneration
    }

    @ObservationIgnored private(set) var pendingAnchorRestore: Int?  // read by the RAISE-M1 pins' kin
    @ObservationIgnored private var pendingAnchorGeneration = 0

    // MARK: - A RE-FONT IS A REFLOW (13u4 UNIT F2 — KnownIssues row 53)

    /// **Keeps her reading position across a whole-document re-font** — a
    /// voice switch, the inline-comments toggle, the paragraph-gap dial: the
    /// three settings that move `EditorDocument.baseAttributes` and so make
    /// `applyVoiceChrome` re-write the whole storage.
    ///
    /// **The mechanism it answers, measured (the UNIT F2 record's seven-step
    /// trace).** A re-font changes the geometry under a scroll offset that
    /// AppKit keeps in PIXELS — the Phase 6 spike's own hazard, which this
    /// app already answers on the WIDTH axis (`ScrollAnchorController`
    /// captures the top visible LOCATION and restores it through
    /// `JumpPrimitive`) and had never answered on this one. Two things follow
    /// from that, and only the second one photographs: in EVERY direction the
    /// text under her viewport moves, and in the SHRINKING direction the old
    /// offset can exceed the shortened document's maximum — at which point
    /// the clip is clamped to the bottom, and because the document carries a
    /// viewport-page of TYPEWRITER ROOM below its last line, "the bottom"
    /// means "the last line at the very top and a page of blank". Measured on
    /// a 212-block note: 305.5 pt of prose in the viewport before, **11.0 pt**
    /// after. It never self-heals, because a clamp is a legitimate position.
    ///
    /// **Why the restore is PARKED and not performed here.** It is the
    /// `revealLanding` rule, for the reason `revealLanding` states: at this
    /// moment the storage's new attributes are written but nothing is laid
    /// out for them, so the frame — and therefore `JumpPrimitive`'s scroll
    /// range — is still the OLD document's. The settle hop is the first turn
    /// on which the geometry is the new one, and it is where every other
    /// landing on this surface is already spent. Deferring also keeps this
    /// road clear of the 13u3 ladder's R1-1 rule by construction: no
    /// layout-forcing query runs inside a storage-edit transaction, because
    /// the capture happens BEFORE the write and the restore a turn AFTER it.
    ///
    /// **Why it bumps the generation.** A re-font is a geometry event with no
    /// CHARACTER edit, so `storageDidEdit` never sees it (the delegate filters
    /// on `.editedCharacters`) and no hop would ever be armed. These are the
    /// width-reflow road's own two lines (`onWidthReflow`), for its own
    /// stated reason — and the badges and decorations this surface draws get
    /// the same post-layout refresh a reflow gives them, which they did not
    /// have across a re-font either.
    ///
    /// **What it deliberately does not do.** It never moves the CARET (⌘↑ is
    /// the symptom's healer, not the fix's shape — pinned), it never runs for
    /// a colour-only chrome change (18g's R1-1 carve: a palette or an
    /// appearance moves no base attribute, so there is no reflow to survive —
    /// pinned), and it is inert on the CONTAINED editors, which own no scroll
    /// view: the book/spread/pool surface scrolls inside its host and has no
    /// viewport of its own to keep, exactly as `parkAnchorRestore` and
    /// `revealLanding` already rule. A viewport resting in the typewriter
    /// room has no top visible location at all (`topVisibleOffset` answers
    /// nil there — the A22 batch-5 measurement), and then there is nothing to
    /// keep and nothing is parked; the clamp leaves her at the end, which is
    /// where she was.
    func keepingReadingPosition(acrossRefont isRefont: Bool, _ apply: () -> Void) {
        guard isRefont, scrollView != nil else {
            apply()
            return
        }
        let anchor = topVisibleOffset()
        apply()
        overlayGeometryGeneration &+= 1
        if let anchor { parkAnchorRestore(anchor) }
        overlayLayoutDidSettle()
    }

    private func consumePendingAnchorRestore(deliveredBy generation: Int) {
        guard let offset = pendingAnchorRestore else { return }
        guard generation >= pendingAnchorGeneration else { return }  // a stale hop leaves it (R1-5's rule)
        pendingAnchorRestore = nil
        guard let textView, let scrollView else { return }
        JumpPrimitive.jump(
            toOffset: min(offset, max(0, index.documentLength)),
            textView: textView, scrollView: scrollView)
    }

    private func consumePendingReveal(deliveredBy generation: Int) {
        guard let offset = pendingRevealOffset else { return }
        // R1-5: a stale hop LEAVES the park — the honest one is guaranteed
        // (the bump that parked it is undelivered, so the next display pass
        // schedules it).
        guard generation >= pendingRevealGeneration else { return }
        pendingRevealOffset = nil
        guard let textView, let scrollView,
              textView.selectedRange().location == offset else { return }
        // Already on screen — the restored scroll anchor put her there, which
        // is the ordinary case for a mode round trip. Leave the page alone:
        // REVEAL means make visible, never "move". (Without this a bare
        // arrival would haul the caret's line to the viewport top on every
        // ⌘2-then-⌘1, a lurch nobody asked for.)
        // The ladder's R1-11: the WHOLE line — top and bottom — with the
        // 1-pt slack kept, so a line flush with an edge still counts as
        // shown and a line clipped by more than that is revealed.
        if let span = JumpPrimitive.lineSpan(ofOffset: offset, in: textView) {
            let visible = scrollView.contentView.bounds
            if span.top >= Double(visible.minY) - 1, span.bottom <= Double(visible.maxY) + 1 {
                return
            }
        }
        JumpPrimitive.jump(toOffset: offset, textView: textView, scrollView: scrollView)
    }

    // MARK: - The mode switch's viewport carry (13u2b UNIT 3)

    /// The registration behind the probe below; nil for the inline editors.
    @ObservationIgnored private var placeProbeToken: UUID?

    /// **Where the carried block sits on THIS editor's screen** — the CAPTURE
    /// half, asked by `CommandRouter.carryPlaceAcrossModeSwitch` at the moment
    /// a mode switch is made, while this surface is still mounted.
    ///
    /// The block, not the caret's line: the carry is about the block she is
    /// working in, which is the one thing every mode agrees it is showing
    /// (Read has rows, Write has paragraphs, and only the block is common to
    /// both). Its span runs the first line's top to the last line's bottom,
    /// because a block may hold internal newlines (I4) and is then several TK2
    /// fragments. Two bounded single-fragment layouts, the `JumpPrimitive`
    /// pattern — never a document-wide `ensureLayout` (P1; TEXTKIT2 §2).
    private func carriedBlockPlace() -> ViewportCarry.Place? {
        guard let textView, let scrollView, let blockID = caretBlockID,
              let i = index.entries.firstIndex(where: { $0.blockID == blockID })
        else { return nil }
        let range = index.range(ofEntryAt: i)
        guard let first = JumpPrimitive.lineSpan(ofOffset: range.location, in: textView),
              let last = JumpPrimitive.lineSpan(
                ofOffset: range.location + max(0, range.length - 1), in: textView)
        else { return nil }
        let visible = scrollView.contentView.bounds
        guard let fraction = ViewportCarry.fraction(
            blockTop: first.top - Double(visible.minY),
            blockHeight: max(1, last.bottom - first.top),
            viewportHeight: Double(visible.height))
        else { return nil }
        return ViewportCarry.Place(postID: postID, blockID: blockID, fraction: fraction)
    }

    /// The APPLY half's park. Like the reveal and the anchor restore it waits
    /// for the N14 settle hop, and for exactly their reason: at the moment an
    /// arrival runs, the text view's frame is still the pre-fill height, so
    /// any scroll computed here clamps a couple of dozen points down.
    ///
    /// The carry is TAKEN from the router here rather than at the hop, so a
    /// second editor rendering in the same beat (the book-inline one, a
    /// background pane) can never consume the place this arrival is for.
    private func parkCarriedPlacement(fact: FocusedBlock?) {
        guard scrollView != nil, let fact, fact.postID == postID else { return }
        guard let fraction = session.commandRouter.takeCarriedFraction(
            postID: postID, blockID: fact.blockID) else { return }
        pendingCarriedPlacement = (fact.blockID, fraction)
        pendingCarriedGeneration = overlayGeometryGeneration
    }

    @ObservationIgnored private var pendingCarriedPlacement: (blockID: String, fraction: Double)?
    @ObservationIgnored private var pendingCarriedGeneration = 0

    /// **The mode switch's landing**: put the carried block back at the
    /// viewport fraction it had in the mode she left.
    ///
    /// It REPLACES the two landings that would otherwise decide this arrival —
    /// the session scroll anchor (Write's own memory of where IT stood, which
    /// is older than the switch) and the caret reveal (whose contract is "the
    /// line at the viewport top") — and it keeps the reveal's promise anyway:
    /// a caret left off screen by the placement (a block taller than the
    /// viewport) is revealed afterwards, because a landing that hides the
    /// caret she is about to type at is worse than one that moves the page.
    private func consumePendingCarriedPlacement(deliveredBy generation: Int) {
        guard let placement = pendingCarriedPlacement else { return }
        guard generation >= pendingCarriedGeneration else { return }  // a stale hop leaves it (R1-5's rule)
        pendingCarriedPlacement = nil
        guard let textView, let scrollView,
              let i = index.entries.firstIndex(where: { $0.blockID == placement.blockID })
        else { return }
        let range = index.range(ofEntryAt: i)
        guard let first = JumpPrimitive.lineSpan(ofOffset: range.location, in: textView),
              let last = JumpPrimitive.lineSpan(
                ofOffset: range.location + max(0, range.length - 1), in: textView)
        else { return }
        let inset = ViewportCarry.topInset(
            fraction: placement.fraction,
            blockHeight: max(1, last.bottom - first.top),
            viewportHeight: Double(scrollView.contentView.bounds.height))
        pendingAnchorRestore = nil
        let caret = pendingRevealOffset
        pendingRevealOffset = nil
        JumpPrimitive.jump(
            toOffset: range.location, textView: textView, scrollView: scrollView,
            landingInset: inset)
        guard let caret,
              let span = JumpPrimitive.lineSpan(ofOffset: caret, in: textView)
        else { return }
        let visible = scrollView.contentView.bounds
        if span.top < Double(visible.minY) - 1 || span.bottom > Double(visible.maxY) + 1 {
            JumpPrimitive.jump(toOffset: caret, textView: textView, scrollView: scrollView)
        }
    }

    /// The bare arrival's landing offset (rows 39/49): this post's current
    /// block — the fact as it stood BEFORE the arrival's own fill — when the
    /// index knows it, else 0. Pure over the index.
    ///
    /// **17o batch b (her ruling U-20):** the landing is the block's start
    /// PLUS the remembered caret offset — *"when you are within a block and
    /// then click go to write, you also end up with your caret at the start
    /// of the block rather than where you were within it, which is annoying
    /// on long blocks"*. The offset is clamped to the block's CURRENT length,
    /// because the block may have shrunk since she left it (another take
    /// chosen, a sync arrival), and a landing past its end would put her in
    /// the next block — the one thing worse than the start. No offset (a
    /// surface that holds no caret) is the block's start, exactly as before.
    func bareArrivalLanding(fact: FocusedBlock?) -> Int {
        rememberedArrivalLanding(fact: fact) ?? 0
    }

    /// The same brain, read for WHETHER the landing is remembered at all
    /// (ledger row 47). `bareArrivalLanding` folds two different situations
    /// into the number 0 — "her caret was at the note's very start" and
    /// "this note remembers nothing, so land at the start" — and the reveal
    /// has to tell them apart: the first is a place she left and the second
    /// is a default that must never outrank the session scroll anchor the
    /// cold mount just restored. `nil` ⇒ nothing remembered for this note
    /// (no fact, another note's fact, or a block the index no longer holds).
    func rememberedArrivalLanding(fact: FocusedBlock?) -> Int? {
        guard let fact, fact.postID == postID,
              let i = index.entries.firstIndex(where: { $0.blockID == fact.blockID })
        else { return nil }
        let range = index.range(ofEntryAt: i)
        let offset = min(max(0, fact.utf16Offset ?? 0), range.length)
        return min(range.location + offset, max(0, index.documentLength))
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
        // 17o batch b (row 20's class, one door over): the fire-and-DO landing
        // placed the caret and never revealed it either — a follow-up gesture
        // that runs off-screen is a gesture she cannot see happen.
        revealLanding(location, textView: textView)
        guard let followUp = intent.followUp else { return }
        pendingIntentTask = Task { [weak self] in
            guard let self else { return }
            switch followUp {
            case .structural(let act):
                await invokeGesture(
                    Self.plannerCommand(for: act), ceremony: Self.requestsCeremony(act))
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
        case .divide, .divideWithCeremony: .divideAtCursor
        case .extract: .extractSelection
        case .makeBlock: .makeBlockFromSelection
        case .merge, .mergeWithCeremony: .mergeBlocks
        }
    }

    /// 13j J4/J4b: which DOOR the act came from. The plan is identical for
    /// an act and its ceremony twin — the planner is pure over the surface
    /// and answers only "this block/pair carries a fan"; the ruling that
    /// changed is what the fanned branch DOES, so the door travels beside
    /// the command rather than inside it.
    nonisolated static func requestsCeremony(_ act: StructuralAct) -> Bool {
        switch act {
        case .divideWithCeremony, .mergeWithCeremony: true
        case .divide, .extract, .makeBlock, .merge: false
        }
    }

    /// 13b 4D (N28/S4-13) — insert-below's Write half, forwarded (the
    /// machinery lives in `EditorSurfaceController`, the one structural
    /// door): an empty block mints under the caret block and the caret
    /// lands in it.
    func insertBlockBelowCaret() async {
        await structural.insertBlockBelowCaret()
    }

    /// 18c batch 3 (her U-6) — the two Write-bar doors onto the newline
    /// repair, forwarded (the machinery lives in `EditorSurfaceController`,
    /// the one structural door).
    func splitEveryNewlineIntoBlocks() async {
        await structural.splitEveryNewlineIntoBlocks()
    }

    func splitCaretBlockAtNewlines() async {
        await structural.splitCaretBlockAtNewlines()
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
        // A DIRECTION: the jump LANDED; this says what typing here will do.
        direct("Caret at the end — typing here starts a new block.")
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

    /// 18f batch 1 (U-5/U-16): the merge row's forward.
    func setMergeArrangement(_ arrangement: MergeArrangement) {
        structural.setMergeArrangement(arrangement)
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
        // 13j J4/J4b: the two ceremony doors — her round-4 binding names the
        // block context menu explicitly, beside the Block menu and ⌘K.
        .divideWithCeremony, .mergeWithCeremony,
        // 13j (her round-7 ruling): block archive — the Block menu's twin.
        .archiveBlock,
        // The post-13l polish round, ledger row 4(c): archive's OWN twin,
        // which this menu had been missing while carrying archive.
        .deleteBlock,
        .showOriginBlock,  // 13f W10b — rendered only where an origin exists
        .callout,  // 13k K6 — the submenu this surface inserts beside Format
        // 13e E2 (A17) — rendered only while blocks are picked
        .deleteSelectedBlocks,
        // 13u4 UNIT C2 (her item 9, R-13u4-4) — rendered ONLY where the
        // selection lies inside one block (P-2: a cross-block selection is
        // not this gesture, so the row does not appear there). The
        // `.showOriginBlock` / `.deleteSelectedBlocks` per-target shape.
        .moveSelectionToTake,
    ]

    func contextMenuItems() -> [EditorTextView.StructuralMenuItem] {
        guard textView != nil else { return [] }
        // Doors fire and speak (author 2026-07-09, superseding the
        // disabled-door posture): items stay enabled; a refused invocation
        // surfaces its RefusalCopy through the one planning door instead of
        // being silently swallowed. The planner verdict still drives the
        // button bar's dimming (`gestureAvailability`).
        func item(
            _ title: String, _ command: StructuralGesturePlanner.Command,
            ceremony: Bool = false
        ) -> EditorTextView.StructuralMenuItem {
            .init(title: title, enabled: true) { [weak self] in
                self?.performGesture(command, ceremony: ceremony)
            }
        }
        // 13j J4/J4b: the two ceremony rows sit beside their twins, rendered
        // unconditionally like every other structural row on THIS menu — the
        // 2026-07-09 fire-and-speak posture recorded above governs it (Merge
        // renders with no seam in reach, Extract with no selection), and the
        // ceremony's own honest refusal is what a wrong target gets. Their
        // titles carry the chord because this menu is where a summoned door
        // is most likely to be met for the first time.
        // 13u4 UNIT S1 (her item 7): the four PLAIN rows take their titles
        // from the registry too. They were hard-coded literals beside the two
        // chorded ceremony rows, so this menu said "Merge choosing takes…
        // (⌥⌘⇧M)" directly under a silent "Merge Blocks" — which teaches the
        // opposite of what the registry declares. Their words are unchanged
        // (the registry's verbs ARE these four strings); what is new is the
        // chord the one formatter appends.
        var items = [
            item(CapabilityRegistry.capability(.divide).menuTitle(), .divideAtCursor),
            item(CapabilityRegistry.capability(.divideWithCeremony).menuTitle(),
                 .divideAtCursor, ceremony: true),
            item(CapabilityRegistry.capability(.extract).menuTitle(), .extractSelection),
            item(CapabilityRegistry.capability(.makeBlock).menuTitle(),
                 .makeBlockFromSelection),
            item(CapabilityRegistry.capability(.merge).menuTitle(), .mergeBlocks),
            item(CapabilityRegistry.capability(.mergeWithCeremony).menuTitle(),
                 .mergeBlocks, ceremony: true),
            // #11b (the sitting ruling, 2026-07-13): the deliberate, NAMED
            // command — not a planner gesture (it edits takes, not
            // structure); fire-and-speak like every door.
            .init(title: "Delete in Every Take", enabled: true) { [weak self] in
                Task { await self?.deleteInEveryTake() }
            },
            .init(title: "Show Takes", enabled: true) { [weak self] in
                self?.openCaretFan()
            },
            // 13j (her round-7 ruling): the third verb, beside the two it
            // has to be told apart from. Rendered unconditionally like every
            // other structural row on THIS menu (the 2026-07-09
            // fire-and-speak posture); a caret outside a block gets the
            // door's own honest sentence.
            .init(title: CapabilityRegistry.capability(.archiveBlock).menuTitle(),
                  enabled: true) { [weak self] in
                Task { await self?.archiveCaretBlock() }
            },
        ]
        // 13e E2 (her A17): the delete door for a ⌘-click selection,
        // rendered only where it can act — with at least one block picked
        // (the `.showOriginBlock` per-target shape below, P-2). The count is
        // in the row's words so the menu says how much it will remove.
        //
        // **The post-13l polish round, ledger row 4(c):** the CARET block's
        // own delete row joins it, because this menu carried **Archive
        // Block** with no delete beside it — the two verbs that exist to be
        // told apart, one of them missing from the door you reach by
        // right-clicking the block itself.
        //
        // Exactly ONE of the two renders, and which one is not a style call:
        // with a single block picked, `deleteVerb(picked: 1)` is the STRING
        // "Delete Block", so rendering both would put two identically-worded
        // rows on one menu aiming at two different targets. A standing
        // selection is the more specific intent, so it wins the row.
        let picked = selectedBlocksInOrder
        if picked.isEmpty {
            items.append(.init(
                title: CapabilityRegistry.capability(.deleteBlock).menuTitle(),
                enabled: true
            ) { [weak self] in
                Task { await self?.deleteCaretBlock() }
            })
        } else {
            items.append(.init(
                title: BlockSelectionCopy.deleteVerb(picked: picked.count), enabled: true
            ) { [weak self] in
                Task { await self?.deleteSelectedBlocks() }
            })
        }
        // 13u4 UNIT C2 (her item 9, R-13u4-4): rendered ONLY where the
        // selection lies inside ONE block with a take to move a span out of
        // — the `.showOriginBlock` per-target shape below, P-2. A
        // cross-block selection is a DIFFERENT gesture's population (Make
        // Block from Selection), so the row is absent there rather than
        // present-and-refusing. The verdict is the act's own brain's, asked
        // fresh at menu-build time like every other row on this menu.
        if let textView, SpanToTakeGesture.plan(
            selection: textView.selectedRange(), index: index) != nil {
            items.append(.init(
                title: CapabilityRegistry.capability(.moveSelectionToTake).menuTitle(),
                enabled: true
            ) { [weak self] in
                Task { await self?.moveSelectionToNewTake() }
            })
        }
        // 13f W10b: the lineage door, rendered ONLY on a block whose own
        // `derived_from` edge points at a live, unplaced original (P-2 — a
        // door that could never act is not rendered at all). Ordinary blocks
        // see the menu exactly as before. 13j J3: the row says WHICH act
        // released it — her ruled wording ("See original from divide…").
        if let origin = caretBlockOrigin {
            items.append(.init(
                title: OriginPeekCopy.doorVerb(op: origin.originOp), enabled: true
            ) { [weak self] in
                self?.revealCaretBlockOrigin()
            })
        }
        return items
    }

    /// Fire-and-DO (P-2): show the released original — the ⌘K row's body and
    /// the context row's alike.
    ///
    /// **The door's history, because the record is the argument.** 13f W10b
    /// broadcast a signal the shell turned into a navigation to Library →
    /// Archived & Deleted → Unplaced blocks; her round-2 ruling removed that
    /// room ("what is that cursed table of lost hopes and dreams?"), so batch
    /// 2 repointed the door at the note's OWN tray. 13j J3 gave it a read-only
    /// PEEK of the original itself, with Put back and Open this note's tray.
    ///
    /// **The post-13l polish round is its third and last landing** (ledger row
    /// 17, and it is the honest end of the sequence): the peek is ABSORBED
    /// into the Block History pane's came-from region, which answers the same
    /// question with two things the peek could not manage —
    ///
    /// · **it shows ALL of them.** The peek took `.first` of an array whose
    ///   own doc says a merge releases both sources, so the 13l walk found a
    ///   door promising "the original" and showing one of two (P-3); and
    /// · **its "Open this note's tray" is no longer a sheet over a sheet.**
    ///   The pane is a side panel, so the tray takes the SAME column (the
    ///   architect's adjudication 3 — dissolved, not moved).
    ///
    /// The act keeps its name, its verb and its two summoned doors; what
    /// changed is where it lands.
    func revealCaretBlockOrigin() {
        guard caretBlockOrigin != nil else {
            refuse(OriginPeekCopy.noOriginHere)
            return
        }
        requestBlockHistory()
    }

    /// 13j J2: the tray sheet's pending target (`EditorView` presents it).
    var trayRequest: TrayRequest?

    /// **A door onto this note's tray.**
    ///
    /// Since her C1 ruling (the post-13l polish round, ledger row 9) the
    /// tray's home is the post detail's SIDE PANEL, so this asks the router
    /// first — one panel, wherever the door is. The sheet survives as the
    /// FALLBACK, and it is not vestigial: this editor is also composed where
    /// there is no post detail and therefore no inspector (the scraps
    /// editor's own hosts, the book-inline form), and a door that cannot act
    /// in its context is a door that should not have been rendered (P-2).
    func requestNoteTray() {
        let request = TrayRequest(postID: postID)
        if session.commandRouter.requestNoteTray(request) { return }
        trayRequest = request
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
            takes: caretBlockID != nil,
            // 13u4 UNIT C2: its own brain, for the reason stated there —
            // this act moves no block boundary, so it is not one of the
            // structural planner's verdicts.
            moveToTake: SpanToTakeGesture.plan(selection: selection, index: index) != nil)
        if fresh != gestureAvailability {
            gestureAvailability = fresh
        }
    }

    /// Internal (was private) since N10: the controller's passive hints
    /// (fanned extract, merged fans) ride the same self-clearing line.
    ///
    /// **A DIRECTION, and now named one** (13u2 UNIT E — row 56, step 1;
    /// it was `directTransiently`): its one caller's words are *"finish
    /// Divide choosing takes, then run Make Block from Selection again"* —
    /// nothing was refused, and she must see it, which is exactly what the
    /// always-shown class means.
    func directTransiently(_ message: String) {
        showTransient(message, kind: .refusal)
    }

    /// 18i: the same self-clearing line, delivered as a RECEIPT — the
    /// passive after-the-fact notes (a fanned extract's other takes, the
    /// takes that stayed with a released block). Its refusal-class twin
    /// above carries the one message that is a DIRECTION, not a report:
    /// "finish Divide choosing takes, then run Make Block again."
    func showTransientReceipt(_ message: String) {
        showTransient(message, kind: .receipt)
    }

    private func showTransient(_ message: String, kind: StatusCenter.Kind) {
        setStatusMessage(message, kind: kind)
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
                    showReceipt("Unsealed.")  // J43: the seal moved
                } else {
                    await finalizeWork()?.value
                    // finishMint's corrections/attachments ride the
                    // autosave coordinator — land them before the freeze.
                    await autosave.flushNow()
                    try await session.runner.run { [postID] ops in
                        try ops.lockPost(postID)
                    }
                    showReceipt("Sealed — the note is read-only until unsealed.")  // J43
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
            // 18i: a RECEIPT — the toggle landed, and this says what it
            // means. Her images 6/7 are this sentence.
            showReceipt(SegmentationFaceCopy.note(
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
            // J43: the target landed (the board's twin has always been a
            // receipt — one act, one class).
            showReceipt(target.map(WordTargetFaceCopy.setNote)
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
            showReceipt(day.map { "Entry date set to \($0)." } ?? "Entry date cleared.")  // J43
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
            refuseFeedback("This note is sealed — unlock it to add to it.")
            return true  // consumed: never fall through to a text insert
        }
        let insert = insertPosition(forOffset: offset)
        let post = postID
        Task { [session] in
            do {
                // 13e E10's sweep: `poolDragCopy` reads the SOURCE block's
                // `working_text` rows, so a scrap dragged in while its own
                // editor still holds a pending buffer copies stale text —
                // the copy-door class, one container over. The source's
                // container is not named here (only its block is), so the
                // family's block-shaped entry flushes every open post; a
                // clean coordinator costs nothing.
                await session.flushEveryOpenPost()
                _ = try await session.runner.run { ops in
                    try ops.poolDragCopy(
                        blockID, to: post, at: insert, includeFan: includeFan)
                }
                // J43: the copy landed.
                self.showReceipt(includeFan
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

    // MARK: - The block selection (13e E2 — her A17)

    /// The picked blocks in the POST's order — what the banner counts and
    /// what the delete door walks (through a fresh STORE read; this order is
    /// the surface's own and is a selection aid, never an authorization).
    var selectedBlocksInOrder: [String] {
        blockSelection.inOrder(index.entries.map(\.blockID))
    }

    /// The ⌘-click / ⌘⇧-click door, in document offsets — the surface knows
    /// where the pointer landed, the index knows which block that is, and
    /// this is the one place the two meet. Returns whether the click was
    /// CLAIMED: a click past the last block (the open tail, which is not a
    /// block yet) claims nothing and falls through to the ordinary caret
    /// move it looked like.
    @discardableResult
    func pickBlock(atOffset offset: Int, extending: Bool) -> Bool {
        guard let blockID = blockID(atOffset: offset) else { return false }
        if extending {
            blockSelection.extend(to: blockID, in: index.entries.map(\.blockID))
        } else {
            blockSelection.toggle(blockID)
        }
        refreshDecorations()
        return true
    }

    func clearBlockSelection() {
        guard !blockSelection.isEmpty || blockSelection.anchor != nil else { return }
        blockSelection.clear()
        refreshDecorations()
    }

    /// Drops picks the surface no longer holds. Called from `slots`' own
    /// `didSet`, so every adoption path prunes; the decoration refresh only
    /// fires when something actually left (the calm default costs nothing).
    private func pruneBlockSelection() {
        let before = blockSelection
        blockSelection.prune(to: Set(index.entries.map(\.blockID)))
        if blockSelection != before { refreshDecorations() }
    }

    /// The caret's place BY IDENTITY — the block it stands in and its
    /// UTF-16 offset inside that block — so a full re-render can put it
    /// back where it was (rows 39/49). Nil with no surface, an empty index,
    /// or a caret in the open tail (which has no block yet).
    func caretIdentity() -> (blockID: String, offset: Int)? {
        guard let textView, !index.entries.isEmpty else { return nil }
        let caret = textView.selectedRange().location
        var location = 0
        for entry in index.entries {
            let end = location + entry.length
            if caret <= end { return (entry.blockID, max(0, caret - location)) }
            location = end + 1
        }
        return nil
    }

    /// Which block a document offset falls in — the index walk
    /// `insertPosition(forOffset:)` already does, answering identity instead
    /// of a boundary. The trailing separator belongs to the block BEFORE it
    /// (a click at a block's very end is a click in that block).
    func blockID(atOffset offset: Int) -> String? {
        var location = 0
        for entry in index.entries {
            let end = location + entry.length
            if offset <= end { return entry.blockID }
            location = end + 1
        }
        return nil
    }

    // MARK: - Commit + history (Step 5)

    /// **⌘S AND THE COMMIT BUTTON — the door** (13u3 UNIT D, item 14).
    ///
    /// The door now SUMMONS the name field instead of writing the savepoint
    /// itself: ⏎ on the empty field files it unnamed, so the fast road is
    /// two keys and the savepoint she has always got is the savepoint she
    /// still gets. Where the caret can commit nothing the door refuses HERE,
    /// before a field opens over a gesture that cannot land (P-2).
    func commitCaretVariant() {
        askSavepointName()
    }

    /// The no-caret refusal, ONE literal for the door and the filer (13u3
    /// ladder round 2 — the R2-1 class one guard up: two hand-kept copies of
    /// a sentence that must match are one typo from diverging).
    private static let noCaretToCommit = "Place the caret in a block to commit."

    func askSavepointName() {
        guard let variantID = caretVariantID else {
            refuse(Self.noCaretToCommit)
            return
        }
        // 13u3 ladder round 1, R1-3 (P-2's letter): a SEALED note's ⌘S used
        // to refuse at the keypress; the door must not open a field over a
        // gesture the filer will refuse.
        //
        // **THE SURFACE'S OWN SENTENCE, deliberately — not the registry's**
        // (round 2, R2-1: the registry's "unseal it to change takes or
        // choices" answers a takes door, and it is NOT what this surface's
        // filer speaks). This door is the one seal refusal in Write whose
        // GESTURE has two refusal moments — here, or at the op after ⏎ when
        // the seal landed under a stale `header` (the fail-open this guard
        // deliberately leaves to the filer) — so the two moments must speak
        // identically, and `operationMessage` is where the filer's words
        // live. These are also the exact pre-D words of this keypress. The
        // two gesture-worded siblings ("unlock it to edit." / "unlock it to
        // add to it.") are NOT this rule's: their doors consume the gesture
        // outright, so the door is those gestures' only worded refusal.
        // The equality pin (`writesDoorAndFilerSpeakOneSealSentence`) holds
        // this door alone.
        guard header?.locked != true else {
            refuse(operationMessage(OperationError.lockedPost(id: postID)))
            return
        }
        savepointAsk = .naming(variantID: variantID)
    }

    /// ⏎ in the field. The name is already through the one rule; nil is the
    /// skip road and files exactly what ⌘S has always filed.
    func fileSavepoint(named name: String?) async {
        savepointAsk = nil
        await commitCaret(named: name)
    }

    /// The filing itself — unchanged in every respect but the optional name
    /// it now carries (the flush-then-commit ordering, the caret guard and
    /// the refusal road are byte-identical, which is why the shipped pins on
    /// this road ride unmodified).
    func commitCaret(named name: String? = nil) async {
        guard let variantID = caretVariantID else {
            statusMessage = Self.noCaretToCommit
            return
        }
        await autosave.flushNow()
        do {
            _ = try await session.runner.run { ops in
                try ops.commit(variantID, kind: .manual, message: name)
            }
            // 18i: the savepoint landed — a receipt. The named form says the
            // name back, because the name is the news.
            showReceipt(name.map(SavepointNameCopy.filed) ?? "Committed.")
        } catch {
            showOperationError(error)
        }
    }

    /// **THE BLOCK HISTORY DOOR** (the post-13l polish round, ledger row 17).
    ///
    /// It asks the router first — one pane, wherever the door is pressed —
    /// and falls back to its own sheet where no post detail is mounted, which
    /// is `requestNoteTray`'s shape and its reason.
    ///
    /// The request carries the FOCUSED take as well as the block: her ruling
    /// sections every take's savepoint run with *"the focused take's
    /// expanded"*, and the caret is the only thing that knows which that is.
    func requestBlockHistory() {
        guard let blockID = caretBlockID else {
            refuse(CapabilityRegistry.capability(.showBlockHistory).unavailableNote)
            return
        }
        let request = BlockHistoryRequest(
            postID: postID, blockID: blockID, focusedVariantID: caretVariantID)
        if session.commandRouter.requestBlockHistory(request) { return }
        blockHistoryRequest = request
    }

    /// **THE VERSIONS DOOR** (the post-13l polish round, ledger rows 16/23).
    /// Asks the router first — one pane wherever the door is pressed — and
    /// falls back to its own sheet where no post detail is mounted, which is
    /// `requestBlockHistory`'s shape and its reason.
    func requestNoteVersions() {
        if session.commandRouter.requestNoteVersions(postID: postID) { return }
        versionsRequested = true
    }

    /// **⌘⇧S — save the whole note as it is.** The flush is the composition's
    /// (`VersionActs`), because a moment missing the keystroke that summoned
    /// it is not the moment she asked for.
    func saveNoteVersion() async {
        do {
            // FOUND ON THE ROUND-2 WALK (18i): the moment LANDED, so this is
            // a RECEIPT and her setting governs it — the board's twin
            // (`TakesViewModel.saveNoteVersion`) has always classed it that
            // way, and this arm's `refuse` kept ⌘⇧S toasting over Write
            // and the book's inline editor under the default she chose to
            // stop the toasting. The J38 class, other direction.
            showReceipt(try await VersionActs.save(session: session, postID: postID))
        } catch {
            refuse(VersionActs.words(error))
        }
    }

    // MARK: - Fan (Step 6)

    /// The fan door for ANY block (9d — closes the first-branch
    /// chicken-and-egg: the badge opens fans, but only fanned blocks have a
    /// badge, so a block's FIRST branch had no door at all).
    func openCaretFan() {
        guard let blockID = caretBlockID else {
            refuse("Place the caret in a block to see its takes.")
            return
        }
        openFan(blockID: blockID)
    }

    /// Opens the takes sheet on a block. Synchronous since 17f/P43: the fan
    /// itself is read by `WriteTakesPanel`'s own `TakesViewModel`, so the
    /// async `Queries.blockFan` read this used to perform on every open fed
    /// nothing but two unread fields.
    func openFan(blockID: String) {
        fanPanel = FanPanelState(blockID: blockID)
    }

    // MARK: - Caret take shortcuts (Sitting 9, R73/R90 — the keyboard
    // family in Write: mint on the block you're in; minting never chooses
    // except the explicit power variant)

    func mintCaretTake(blank: Bool, asChosen: Bool = false) {
        guard let blockID = caretBlockID else {
            refuse("Put the caret in a block first — takes grow on the block you're in.")
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
                // J43: the take exists now.
                showReceipt(asChosen
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
                // J43: the lens exists (the boards' and canvas's twins are receipts).
                showReceipt("Saved — “\(name)” remembers these choices (open it in Lenses, ⌘5).")
            } catch {
                showOperationError(error)
            }
        }
    }

    func archiveCaretTake() {
        guard let variantID = caretVariantID else {
            refuse("Put the caret in a block first — ⌘⇧A archives the take you're on.")
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
                // J43: it was archived (the board's twin is a receipt).
                showReceipt("Take archived — never gone: the takes panel (⌘⇧T) keeps it under “archived takes”.")
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

    // (17f/P43: `fanAction` + `enum FanAction` lived here — eight operations
    // dispatched from a panel retired at Sitting 9 (R87). Their only caller
    // in the tree was a test that had to hand-construct a `FanPanelState` no
    // UI road can produce; the live takes acts are `WriteTakesPanel` →
    // `TakesViewModel`, and the editor's own refusal wording is pinned
    // through a live door — `archiveCaretTake` in `EditorSessionTests`.)

    // MARK: - Caret + badges

    func updateCaretContext() {
        guard let textView else { return }
        // 18d batch 1: THIS is the editor under the caret — the fact the
        // sidebar's note box builds its bar from (`EditorRouter.editing`,
        // whose comment has the measured reason it is not `active`).
        // Assigned only on a change, so a caret walking inside one block
        // writes nothing and wakes nobody.
        if session.editorRouter.editing !== self {
            session.editorRouter.editing = self
        }
        let previousCaretBlock = caretBlockID
        let selection = textView.selectedRange()
        let caret = selection.location
        var location = 0
        caretBlockID = nil
        caretVariantID = nil
        caretOrdinal = nil
        caretBlockWordCount = nil
        blockCount = index.entries.count
        // 17o batch b (U-20): where the caret sits INSIDE its block — what
        // every door into Write lands at when she comes back.
        var caretOffsetInBlock: Int?
        for (i, entry) in index.entries.enumerated() {
            if caret >= location, caret <= location + entry.length {
                caretBlockID = entry.blockID
                caretVariantID = entry.variantID
                caretOffsetInBlock = caret - location
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
        //
        // **NEVER SYNCHRONOUSLY INSIDE THE STORAGE'S EDIT TRANSACTION**
        // (13u3 ladder round 1, R1-1). `refreshDecorations` opens with a
        // layout-FORCING fragment query (`textLayoutFragment(for:)`), and
        // run from `storageDidEdit` — i.e. inside `processEditing`, against
        // storage whose edit is not laid out — that is TEXTKIT2 §2's
        // estimation class, sampled once as a permanent 99% spin
        // (`_estimatedTextLocationForVerticalOffset`, the UNIT B record).
        // The sibling road on the same notification already hops for
        // exactly this reason (`EditorView`'s re-measure observer: "geometry
        // reads must wait for it to close"). Deferring costs nothing here:
        // `storageDidEdit` bumped `overlayGeometryGeneration` at its top, so
        // the settle hop (`overlayLayoutDidSettle`, armed by the edit's own
        // draw pass) delivers `refreshBadges` → `refreshDecorations` against
        // laid-out frames one turn later — the latency every edit-driven
        // decoration on this surface already has (N14's design). The
        // selection-change road (arrow keys — no edit transaction) keeps the
        // synchronous refresh.
        if appearance.indicator != .off, caretBlockID != previousCaretBlock {
            if inStorageEditTransaction {
                // Deferred onto the settle hop (R1-1) — and WITNESSED (S-1):
                // the pin asserts this branch fired, not only that the
                // forcing walk did not.
                #if DEBUG
                deferredIndicatorRefreshes += 1
                #endif
            } else {
                refreshDecorations()
            }
        }
        // Ledger row 33 — the Block History pane's jump door reads this fact.
        // 17o batch b (her ruling U-20): the report now rides EVERY caret
        // move, not only a block change, because the OFFSET is what a door
        // into Write lands at and an offset stale by one paragraph of typing
        // is the defect. The row-33 cheapness is unmoved and is now the
        // router's: it keeps the offset `@ObservationIgnored` beside the
        // observed identity, so a caret walking inside one paragraph still
        // wakes nobody (`CommandRouter.focusedBlock`).
        session.commandRouter.noteFocusedBlock(
            caretBlockID, variantID: caretVariantID, postID: postID,
            utf16Offset: caretOffsetInBlock)
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

    /// **TRUE WHILE `storageDidEdit` IS ON THE STACK** — i.e. inside
    /// `NSTextStorage.processEditing`, where the edit is not laid out and a
    /// layout-forcing geometry query is TEXTKIT2 §2's estimation hazard
    /// (13u3 ladder round 1, R1-1; the sampled deleteBackward spin). The
    /// caret arm in `updateCaretContext` consults it to defer the indicator's
    /// decoration refresh onto the settle hop.
    ///
    /// A DEPTH, not a Bool (the sanity pass's S-3): today `storageDidEdit`
    /// cannot re-enter — one production caller, non-`async`, its inner
    /// attribute-only restyle filtered by the delegate's `.editedCharacters`
    /// guard, `desyncRecovery` deferring its re-render into a Task — but a
    /// Bool encodes that premise silently, and if a future road ever DID
    /// re-enter, an inner frame's `defer` would drop the flag while the
    /// outer frame was still inside `processEditing`, reopening the exact
    /// hole R1-1 closed. A counter cannot be got wrong that way.
    private var inStorageEditTransaction: Bool { storageEditDepth > 0 }
    @ObservationIgnored private var storageEditDepth = 0

    /// The one writer (`storageDidEdit`'s entry/exit) — and since the round-2
    /// ladder (R2-2) the claim is a COMPILER fact, not a doc line: the pair
    /// and the flag are `private` (file-scoped), so no second site can bump
    /// the depth ad hoc. A stray `enter` would suppress the indicator
    /// refresh forever; a stray `exit` would drive the depth negative and
    /// un-suppress mid-transaction — R1-1's hole, reopened in the one state
    /// it exists to close.
    private func enterStorageEditTransaction() { storageEditDepth += 1 }
    private func exitStorageEditTransaction() { storageEditDepth -= 1 }

    #if DEBUG
    /// **The R1-1 oracle:** how many times the decoration pass's
    /// layout-forcing walk ran while the storage-edit transaction was open.
    /// Any count above zero is the spin's precondition, reintroduced; the
    /// pin (`EditorDecorTransactionTests`) holds it at zero through the real
    /// delegate pipeline.
    @ObservationIgnored private(set) var decorLayoutQueriesInEditTransaction = 0

    /// **The WITNESS beside the absence (the sanity pass's S-1):** how many
    /// times the indicator arm fired inside the transaction and was
    /// DEFERRED. The zero above is equally true when the arm was never
    /// reached — an AppKit ordering fact TEXTKIT2 §5 says to re-verify per
    /// point release — so the pin asserts this too: the arm fired, and took
    /// the deferral branch. Green-and-hollow becomes red-and-loud.
    @ObservationIgnored private(set) var deferredIndicatorRefreshes = 0
    #endif

    /// Internal (not private) so the ladder's R1-5 pin can schedule a hop
    /// for one generation and deliver a projection under the next.
    func overlayLayoutDidSettle() {
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
            // 17o batch b (row 20): the arriving landing's second, exact jump
            // — this hop is the first moment the document's frame is honest
            // (for the generation this hop saw — R1-5). Round 2, RAISE-M1:
            // the session anchor lands FIRST, so the reveal's guard judges
            // "already on screen" against the view she left.
            // 13u2b UNIT 3: the mode switch's carry lands FIRST and, when it
            // fires, stands the other two down — it is the newer fact than
            // either (the session anchor is where Write stood last time; the
            // reveal's rule is "the line at the top", which is the very policy
            // clash the carry exists to end).
            consumePendingCarriedPlacement(deliveredBy: generation)
            consumePendingAnchorRestore(deliveredBy: generation)
            consumePendingReveal(deliveredBy: generation)
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
        // ONE tiling walk (13u1 UNIT 1 — the O(N²) class): the badge pass
        // asked the accessor once per FANNED slot, and the accessor walks
        // from zero, so a note with many fans paid O(fans × blocks) on a
        // pass that re-runs on every scroll and every projection.
        let ranges = index.entryRanges()
        for (i, slot) in slots.enumerated() where slot.hasFan {
            guard i < ranges.count else { break }
            let range = ranges[i]
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
    // (13u3 UNIT A1: `proseColumnDidChange` is RETIRED here. It existed for
    //  17p batch b's decoration lane — a decoration moving this surface's
    //  prose column under a fixed frame. No decoration can move the column
    //  now (`ProseGutter`: it is a pure function of the view's width), and
    //  the case that remains — the frame moved — is `onWidthReflow`, which
    //  bumps the same generation and runs the same hop.)

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
            // 13e E2: a block selection needs frames like any other
            // decoration — without this arm the calm default (seams off,
            // indicator off, no callouts, no comments) skips the walk and
            // the highlight never draws, which is the silent-selection
            // class: she would be picking blocks with nothing to see.
            || !blockSelection.isEmpty
            // 13e E7: so does a POINTER IN THE SURFACE. The hover faces —
            // the drag handle (13b 4D, S4-19) and the new margin comment
            // invitation — resolve the hovered block against these frames,
            // so on a calm page they had nothing to resolve against and
            // NEITHER could ever appear: hovering a plain post revealed no
            // handle at all, working exactly as built and invisible in the
            // one state it was built for (the E2 silent-selection class,
            // one affordance over). Cost stays P1-shaped: the walk is
            // viewport-proportional, it runs only while she is pointing at
            // the surface, and it stops the moment the pointer leaves.
            || pointerInEditor
        guard needsFrames, let textView, loaded,
              let layoutManager = textView.textLayoutManager,
              let contentManager = layoutManager.textContentManager,
              !index.entries.isEmpty
        else {
            send(BlockDecor.State())
            return
        }
        #if DEBUG
        // The R1-1 oracle: everything below this line forces layout
        // (`textLayoutFragment(for:)`, `enumerateTextLayoutFragments`), and
        // inside the storage-edit transaction that is the sampled spin's
        // precondition. Counted, never fatal — the pin reads it.
        if inStorageEditTransaction { decorLayoutQueriesInEditTransaction += 1 }
        #endif
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
            selectedBlockIDs: blockSelection.picked,
            presentations: presentationsByBlock,
            comments: commentsByBlock,
            // 17p batch b (rows 5–6): ONE derivation for the prose column
            // (`EditorTextView.proseLeft`/`proseRight`). On a symmetric
            // surface both are IDENTICAL to the arithmetic that stood here —
            // `textContainerOrigin.x == textContainerInset.width`, and the
            // trailing inset IS that same number — so every shipped
            // decoration geometry is unchanged by identity. The contained
            // editor's insets become ASYMMETRIC while its decoration lane is
            // reserved, and only the one derivation can be right then.
            textLeft: textView.proseLeft,
            textRight: textView.proseRight,
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
            refuse("Place the caret in a block to see its comments.")
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
            refuse("Place the caret in a block first — the frame goes on that block.")
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

    /// **13e E6 (her A21's clipboard half)** — the caret block's whole fan on
    /// the clipboard, through the ONE brain the boards' door uses
    /// (`TakeClipboard`), so no surface copies different bytes or speaks a
    /// different sentence (R118). Flushes first: the projection reads the
    /// store, and this editor's buffer is normally a debounce ahead of it.
    func copyCaretBlockTakes(
        to destination: TakeClipboard.Destination = .general
    ) async {
        guard let caretBlockID else {
            refuse("Place the caret in a block first — this copies that block's takes.")
            return
        }
        await autosave.flushNow()
        // J43, the split-by-outcome pair: `Outcome` already knows whether it
        // copied anything — a copy that landed is a RECEIPT, and
        // "no text to copy" / "Copy failed" are refusals that always show.
        let outcome = await TakeClipboard.copyBlock(
            caretBlockID, session: session, to: destination)
        outcome.isRefusal ? refuse(outcome.message) : showReceipt(outcome.message)
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

    /// **REFUSE — nothing happened, and this says why.** Always shown,
    /// under every setting (P-2: a door that could not act must deliver the
    /// real refusal).
    ///
    /// *(13u2 UNIT E — KnownIssues row 56, step 1: this door was
    /// `refuse`, a name that said nothing about its class across ~46
    /// call sites, which is how the 18i ladder's J42/J43 found eight Write
    /// doors reporting ACTS through it. Zero behaviour — the body is
    /// unchanged.)*
    func refuse(_ message: String) {
        setStatusMessage(message, kind: .refusal)
    }

    /// **DIRECT — a direction she must see, though nothing was refused.**
    /// The same always-shown class as `refuse` (that is what her setting
    /// does NOT govern), with a name that does not tell a reader something
    /// failed when nothing did. `StatusCenter.Kind.refusal`'s own doc always
    /// carried this distinction; 13u2 UNIT E gave it a door.
    func direct(_ message: String) {
        setStatusMessage(message, kind: .refusal)
    }

    /// **A RECEIPT** (18i — her R-Q5): an act LANDED and this says what.
    /// Where it shows is her setting's answer (`StatusCenter.receiptStyle`);
    /// the words are untouched. Its twins `refuse` and `direct` stay the
    /// always-show doors, which is why `speakUndoHint` below deliberately
    /// does not call this one.
    func showReceipt(_ message: String) {
        setStatusMessage(message, kind: .receipt)
    }

    /// **13j J7 — the sign at the junction.** Speaks only when the text stack
    /// is empty AND the structural one is not (`EditorUndoHint` holds the
    /// rule); a `refuse`, never a `refuseFeedback`, because nothing was
    /// refused — the keystroke was passed straight through to AppKit and the
    /// line is a direction, not a beep. (13u2 UNIT E: it says `direct` now,
    /// which is what this comment had to say in prose before.)
    func speakUndoHint(_ chord: EditorUndoHint.Chord) {
        let manager = textView?.undoManager
        let textStackHasEntries = chord == .undo
            ? (manager?.canUndo ?? false)
            : (manager?.canRedo ?? false)
        guard let line = EditorUndoHint.message(
            for: chord,
            textStackHasEntries: textStackHasEntries,
            structuralUndoLabel: session.undoMenuState.topLabel,
            structuralRedoLabel: session.undoMenuState.topRedoLabel)
        else { return }
        direct(line)
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
            // 13j J8(b), her report: *"the reason is really unclear to me why
            // right now."* This case used to name THREE causes at once for a
            // gesture that had exactly one. Both live doors onto it now
            // DIAGNOSE — they hold the range and the slots, so they call
            // `CrossBlockRefusal.message(range:index:slots:)`, which asks
            // which condition actually declined. What remains here is the
            // range-less fallback for any future caller that has neither.
            // **13u2 UNIT C:** it used to speak the boundary residual, which
            // #109's clamp law retired — and a range-less caller could not
            // claim that geometry anyway. The surviving cause says only that
            // the surface has not caught up, which is the honest answer when
            // nobody can name the condition.
            CrossBlockRefusal.message(for: .surfaceNotSettled)
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
        case .lockedPost: return "This note is sealed — unlock it first."
        case .lockedVariant: return "This take is locked — branch or unlock it."
        case .lastActiveVariant:
            return "A block keeps at least one take — delete the block instead."
        case .variantIsChosen:
            return "This take is shown in the note — choose another take first."
        case .archivedVariant: return "This take is archived — unarchive it first."
        case .bufferChangedSinceGesture:
            return "The text changed while that gesture was landing — nothing was altered; try it again on the current text."
        // 13c R3-1: the A7 carve's authorization, re-checked inside the
        // tombstone's transaction. Reachable when a take or a note lands on
        // the block between the keystroke and the write — the editor's
        // projection is deliberately frozen while typing, so the guards that
        // enabled the gesture could not have seen it.
        case .blockCarriesUnshownText:
            return "That block isn't empty after all — it carries a take or a comment that isn't shown here. Nothing was deleted."
        case .fannedBlock:
            // 13d Batch 3: the same refusal Write can reach when a take
            // lands between the plan and the operation (R1-3's
            // every-refusal-readable class).
            return "This block has more than one take now — divide it again and the take you're in splits while the others stay on the first block (⌥⌘⇧D arranges them differently)."
        case .divideSideWouldBeEmpty:
            return "Every checked take is parked at the same end — one of the two new blocks would have no takes. Split at least one take, or park one at the other end."
        case .mergedBlockWouldHaveNoTake:
            return "The merged block needs at least one take — pair takes with ＋, or check “carry” on one."
        case .takePairedTwice:
            return "A take can sit in only one pairing (and a paired take can't also carry) — remove the duplicate first."
        // 13e E2 (her A17): the multi-delete's rollback refusal. It shares
        // ONE constant with `OpsRefusalCopy`'s case so this surface and the
        // Takes board cannot drift on the sentence — the two refusal
        // switches are a standing duplication, and a shared constant is how
        // a line that MUST match stays matched.
        case .blockNotFound: return BlockSelectionCopy.blockGone
        default: return "The operation was refused: \(opError)"
        }
    }
}

/// Pure predicate behind the pre-split warning (tested in the app bundle).
/// Since parity C4a the brain lives in core (`Queries.commitPredatesSplit`
/// — the phone's history face reads it too; MobileSoul §3's one-brain
/// rule); this enum delegates, byte-identical in behavior.
nonisolated enum CommitRules {
    static func predatesSplit(commitDate: Date, splitDates: [Date]) -> Bool {
        Queries.commitPredatesSplit(commitDate: commitDate, splitDates: splitDates)
    }
}
