//
//  MobileEditorViewModel.swift
//  VariorumMobile
//
//  Mobile Stage 1, batch 1 (M1): the continuous Write-true editor's model —
//  the Mac `EditorViewModel`'s wiring in miniature, composing the SHARED
//  identity brain (`BlockRangeIndex`, `EditorDocument` core,
//  `CrystallizationPlanner`/`Reconciler`, `EditorSurfaceLedger`,
//  `EditorProjectionPolicy` — Shared/EditorBrain) over one `NSTextStorage`.
//  Structural gestures, takes UI, markdown, and find are LATER batches; the
//  refusals those absences produce speak (P-2), never sit silent.
//
//  THE iOS IDENTITY RULE (Stage 0 memo item 3 + obligation 1): iOS strips
//  custom attributes from EVERY insertion path (typing, autocorrect via
//  replace(_:withText:), marked-text commits, dictation) — attribute
//  inheritance is NOT an identity mechanism on this platform. Block-ID
//  attributes are therefore a DERIVED PROJECTION: `BlockRangeIndex` is the
//  one authority, and after every processed edit the owning entry's ID is
//  RE-STAMPED over the edited range (~0.04 ms/paragraph, measured — noise).
//  A DEBUG audit (`auditIdentityProjection`) walks the tiling after every
//  edit and asserts no MISSING runs survive reconciliation; the store stays
//  safe regardless (operations validate against the DB, never the text
//  view — AppSpec §15 risk 1).
//
//  EDIT ROUTING (the Mac's two-phase shape, which is also the iOS system-
//  path answer): policed edits set a verdict in `shouldChangeText` (the
//  UITextViewDelegate gate); the storage delegate then reports EVERY
//  character edit — including system paths that never consult the gate
//  (autocorrect, dictation, marked text) — and an edit arriving WITHOUT a
//  pending verdict is routed by `fallbackVerdict` against the pre-edit
//  index. Nothing that lands in storage goes unrouted.
//
//  PROJECTION DISCIPLINE: the Mac's ledger/policy pattern — the buffer is
//  authoritative while dirty (deliveries defer); `applyPendingIfClean`
//  re-fetches FRESH instead of adopting a deferred (possibly stale)
//  photograph; echoes adopt bookkeeping and touch nothing in the view.
//

import Foundation
import GRDB // AsyncValueObservation iteration (member import visibility)
import Observation
import UIKit
import VariorumCore

@Observable
@MainActor
final class MobileEditorViewModel {
    // MARK: - Composition

    private let session: AppSession
    let postID: String
    @ObservationIgnored let autosave: AutosaveCoordinator
    /// The takes/peek brain (S2 batch 1) — a SIBLING object per the S1
    /// ladder's binding NIT-3: the VM only routes (overlay at ingest, the
    /// targeted display apply below); every takes decision lives there.
    @ObservationIgnored let takes: MobileTakesController
    /// The takes BROWSER's brain (S2 batch 2) — the second sibling: the
    /// sheet's state + the four M4 verbs live there; the VM only routes.
    @ObservationIgnored let takesBrowser: MobileTakesBrowserController
    /// The S4 siblings (the NIT-3 law, carried): the comments sheet's
    /// brain, the divide/merge doors, and the ⋯ block menu — the VM only
    /// routes to each.
    @ObservationIgnored let comments: MobileCommentsController
    @ObservationIgnored let structural: MobileStructuralController
    @ObservationIgnored let blockMenu: MobileBlockMenuController
    /// The C4a sibling, widened at round 2 batch 6a: the commit door and
    /// the BLOCK HISTORY face's brain (savepoint runs · archived takes ·
    /// deleted takes · came-from — the polish round's ledger row 17, in the
    /// phone's own shape).
    @ObservationIgnored let blockHistory: MobileBlockHistoryController
    /// **M20's sibling (round 2, batch 4 — her R10):** the structural
    /// undo/redo door. The STACK is `AppSession`'s, shared and already
    /// live on this phone; this is the routing that reaches it.
    @ObservationIgnored let undoDoor: MobileUndoDoor

    // MARK: - Observable UI state

    /// Refusals + operation errors, one voice (functional; styling is the
    /// look track's).
    ///
    /// **`didSet` clears the receipt's action (round 2, batch 4 — M20).**
    /// A dozen sites assign this property directly, and a stale Undo
    /// button left standing beside a NEW sentence would offer to reverse
    /// something the sentence does not name. Clearing on every set makes
    /// that structurally impossible; `report(_:action:)` sets the action
    /// AFTER the message, which is why the pair survives.
    private(set) var statusMessage: String? {
        didSet { statusAction = nil }
    }

    /// **The receipt's action (M20 — her R10's ruled home):** *"the phone
    /// ALREADY shows a receipt after a structural act … and an Undo action
    /// on that receipt is the standard iOS shape."* It is an ENUM, not a
    /// closure, deliberately: the button's WORDS are read live from the
    /// stack (`MobileUndoDoor.undoLabel`) at render time, so a receipt that
    /// outlives its entry can never name an act that has since moved.
    enum StatusAction: Equatable, Sendable {
        case undo
        case redo
    }

    private(set) var statusAction: StatusAction?
    /// The canary's visible diagnostic (release posture — obligation 2).
    private(set) var canaryMessage: String?
    private(set) var isSealed = false
    /// The masthead's name for the note (batch 3): the shared
    /// `DisplayTitle` chain — the stored title, else the entry date (the
    /// 13k K1 rule rides for free because the brain is core's).
    private(set) var displayTitle: String?

    // MARK: - Editor internals (never observed)

    @ObservationIgnored private(set) var index = BlockRangeIndex(entries: [], tailLength: nil)
    @ObservationIgnored private(set) var slots: [Queries.RenderedBlock] = []
    /// blockID → the block's callout frame (S4, M12 — the projection's
    /// 13k K9 read). Adopted unconditionally at ingest like fans:
    /// bookkeeping for the decor overlay, never surface bytes.
    @ObservationIgnored private(set) var presentations: [String: BlockPresentation] = [:]
    /// **18m U2 — type-time crystallization's conductor, SHARED** with the
    /// Mac (`Shared/EditorBrain/TailCrystallizer.swift`): it owns the open
    /// tail's text, the mint flight and the idle clock; this model owns it (a
    /// downward reference only) and passes ITSELF per call as the
    /// crystallizer's host (the conformance at the end of this file). The
    /// pre-move names are forwards, so every caller and pin reads unchanged.
    @ObservationIgnored private let crystallizer = TailCrystallizer()
    /// The open tail's text (the crystallizer's; read-only here, as before).
    var tailText: String { crystallizer.text }
    @ObservationIgnored private(set) var header: Queries.ContainerHeader?
    @ObservationIgnored private(set) weak var textView: MobileEditorTextView?
    @ObservationIgnored private(set) var storage: NSTextStorage?
    @ObservationIgnored private var storageObserver: MobileStorageObserver?
    /// The VM-OWNED UITextViewDelegate (batch 2): the gate lives with the
    /// brain it polices, so every host of this surface — the SwiftUI face,
    /// the walk tests' bare views — gets the SAME police with no wiring to
    /// forget. `UITextView.delegate` is weak; this is the strong home.
    @ObservationIgnored private var gateDelegate: MobileEditorGateDelegate?
    @ObservationIgnored private var ledger = EditorSurfaceLedger()
    /// The gate's approved edit, BOUND to what it approved (round 2, batch
    /// 1 — the crash fix; `ArmedEdit`'s doc comment carries the whole
    /// mechanism). This used to be a bare `Verdict?`: an identity with no
    /// range, no document length and no expiry, consumed by whatever edit
    /// reached storage next. It carries the approved replacement's length
    /// too, which fixes the edit's exact net change (the binding) AND
    /// yields the EXACT churn cost, immune to the widening iOS applies to
    /// `didProcessEditing`'s range (measured: a 5→6 replacement reported
    /// length 7). The cost is discarded on the same condition as the
    /// verdict, since a cost belonging to a different edit is no better
    /// than a verdict that does (gate-less paths use the report-derived
    /// cost; churn is approximate by design — SyncSpec §6).
    @ObservationIgnored private var pendingEdit: ArmedEdit?
    @ObservationIgnored private var suppressEditProcessing = false
    /// One mint batch in flight (the crystallizer's; read-only here, as before).
    var mintInFlight: Bool { crystallizer.mintInFlight }
    @ObservationIgnored private var bulkPending = false
    @ObservationIgnored private var pendingProjection: [Queries.RenderedBlock]?
    @ObservationIgnored private var forceFullRender = false
    @ObservationIgnored private var loaded = false
    /// Times `desyncRecovery` fired — soaks and the walk assert ZERO.
    @ObservationIgnored private(set) var desyncRecoveryCount = 0
    /// Full surface renders performed — the echo pin's oracle (an autosave
    /// echo must not rewrite the surface).
    @ObservationIgnored private(set) var fullRenderCount = 0
    /// DEBUG identity-audit failures — the obligation-1 oracle; asserts
    /// fire in debug, this counter lets tests observe without dying.
    @ObservationIgnored private(set) var identityAuditFailures = 0

    // Idle-mint (the Mac's ratified clock — one clock since 18m U2, the
    // shared crystallizer's): a short quiet gap crystallizes the open tail —
    // crash loss bounded to seconds; teardown stays the backstop. Forwards
    // (3C): pins set the sleep exactly as before.
    var tailIdleDebounce: Duration {
        get { crystallizer.idleDebounce }
        set { crystallizer.idleDebounce = newValue }
    }
    var tailIdleSleep: @Sendable (Duration) async throws -> Void {
        get { crystallizer.idleSleep }
        set { crystallizer.idleSleep = newValue }
    }

    var hasOpenTail: Bool { index.tailLength != nil }

    // MARK: - Lifecycle

    init(
        session: AppSession,
        postID: String,
        debounce: Duration = .milliseconds(500),
        sleep: @escaping @Sendable (Duration) async throws -> Void = { try await Task.sleep(for: $0) }
    ) {
        self.session = session
        self.postID = postID
        // S3 ladder, round-1 BLOCKER: the ONE per-post coordinator (the N3
        // boundary, the constitution's application note verbatim — "both
        // surface kinds consult ... the ONE per-post autosave coordinator").
        // A second editor on the same post — the shell's two alive tab
        // stacks make one reachable — shares this instance, so two debounced
        // pipelines can never race a stale flush over a newer one. The
        // clock parameters apply only when this call MINTS the coordinator
        // (the harness's deterministic sleep; production passes defaults).
        self.autosave = session.autosave(forPost: postID, debounce: debounce, sleep: sleep)
        self.takes = MobileTakesController(runner: session.runner)
        self.takesBrowser = MobileTakesBrowserController(session: session)
        self.comments = MobileCommentsController(session: session)
        self.structural = MobileStructuralController(session: session)
        self.blockMenu = MobileBlockMenuController(session: session)
        self.blockHistory = MobileBlockHistoryController(session: session)
        self.undoDoor = MobileUndoDoor(session: session)
        takes.model = self
        takesBrowser.model = self
        comments.model = self
        structural.model = self
        blockMenu.model = self
        blockHistory.model = self
        undoDoor.model = self
        // Multicast observers, never the single-owner closures: a shared
        // coordinator has several listeners (the Mac's own move for the
        // same reason) — a second same-post editor must not deafen the
        // first. Removed at `teardown()`.
        autosaveToken = autosave.observe(
            onError: { [weak self] error in
                self?.statusMessage = String(describing: error)
            },
            onSettled: { [weak self] in
                self?.storeWriteGeneration &+= 1
                self?.applyPendingIfClean()
            })
    }

    @ObservationIgnored private var autosaveToken: UUID?

    /// The store-write freshness generation (S3 ladder, MAJOR 3 — the
    /// retired Phase 8 VM's `readGeneration` fence restored): bumped
    /// whenever OUR writes settle (flush settle, mint finish), so a fresh
    /// read that STRADDLED a settle is re-signaled instead of adopted.
    @ObservationIgnored private var storeWriteGeneration = 0

    /// The screen's teardown (onDisappear): the surface's timer stops
    /// FIRST, then the S1 backstop lands pending work, then this surface
    /// stops listening to the SHARED coordinator (which outlives any one
    /// surface — the Mac's exact posture).
    ///
    /// `afterDisarm` is a test seam and nothing else: production never
    /// passes it. The ordering below is the whole of the finding-3 fix and
    /// is otherwise unobservable from outside — a pin that holds the
    /// surface across the await cannot see the pre-fix ordering at all,
    /// which is exactly how that ordering survived its own pin.
    func teardown(afterDisarm: () -> Void = {}) async {
        // M2e (round 2): the TK2 canary's 30-second repeating main-run-loop
        // `Timer` is armed at `attach` and had NO production disarm — only
        // test callers — so one orphaned tick accumulated per note ever
        // OPENED, for the process's life. The block captures weakly, so
        // nothing leaked and nothing crashed; what accumulated was
        // main-thread wakeups doing nothing, which is quiescence's enemy on
        // a phone. The surface is going away here (the representable's view
        // goes with the screen), so this is the arm's mirror.
        //
        // IT RUNS BEFORE THE AWAIT (round-2 ladder round 1, MINOR 3):
        // `textView` is weak, `finish()` is a real DB round trip, and the
        // only production caller is a NavigationStack pop — where SwiftUI
        // releases the representable CONCURRENTLY. Disarming after the
        // await meant that whenever the view lost that race the disarm
        // silently did nothing, which is the accumulation this row exists
        // to close. Nothing in `finish()` touches the canary, so first is
        // free. (`MobileFallbackCanary.deinit` closes the same class from
        // the other end, for every path that never reaches a teardown.)
        textView?.disarmCanary()
        afterDisarm()
        // A gesture the gate refused so a compound could reproduce it
        // (R18's whole-block delete) is scheduled, not immediate — and its
        // only strong reference is this handle. The closure captures the
        // model WEAKLY, and `MobileStructuralController.model` is weak too,
        // so a compound that first runs after this object dies quietly does
        // NOTHING: her paragraphs would stay. Today the pop path keeps the
        // model alive across this method (`MobileWriteView.onDisappear`
        // captures it strongly), so the act lands by ORDERING ACCIDENT —
        // whichever suspension point below yields to it first. Awaiting it
        // here makes it land by construction instead.
        //
        // NO PIN IS CLAIMED FOR THIS LINE, deliberately: the state it
        // closes needs the model to die mid-teardown, which the one
        // production caller cannot produce, and a pin whose red depends on
        // a state the product cannot reach pins a fiction (batch 1's
        // correction (a)). It is belt-and-braces over a traced mechanism.
        await pendingGestureTask?.value
        await finish()
        if let autosaveToken {
            autosave.stopObserving(autosaveToken)
            self.autosaveToken = nil
        }
    }

    // MARK: - Liveness (S3 ladder BLOCKER — the authority's face on the VM)

    /// Whether this surface holds the pen. Standalone surfaces (tests,
    /// previews, a world with no shell) are live by construction; under
    /// the shell, `MobileLivenessAuthority` is the ONE grantor.
    @ObservationIgnored private(set) var isLive = true

    /// Read-tier (P-3's "read panes"): focus resigned — a hidden stack's
    /// editor must never keep the keyboard — editability off, and the
    /// gate's liveness belt refusing whatever slips past both.
    func standDown() {
        isLive = false
        textView?.endEditing(true)
        textView?.isEditable = false
    }

    /// The pen back (only the authority calls this, after the flush —
    /// and the refresh where one is owed — have landed). The open takes
    /// browser keeps its own page stand-down: the sheet's dim is still
    /// the surface in charge there.
    func noteLivenessGranted() {
        isLive = true
        if !takesBrowser.isOpen, !noteIsGone {
            textView?.isEditable = true
        }
    }

    /// **THE NOTE THIS SURFACE STANDS ON IS GONE** (4.5c-phone item 2 —
    /// §63's routed-out "the live editor over a tombstone").
    ///
    /// Both tab stacks stay alive by design, so deleting a note from the
    /// LIBRARY tab leaves the other stack's `MobileWriteScreen` standing on
    /// a tombstone: nothing pops it (the §49-filed `onDeleted` fix reaches
    /// only the deleting stack), and the next tab tap handed that surface
    /// the pen.
    ///
    /// **WHAT THAT COST, MEASURED — not the loss it was first recorded as**
    /// (round-1 MINOR 3, and the correction matters because a belt believed
    /// to stop corruption is weighed differently from one that stops a
    /// confusing surface). **No byte was ever written into a tombstone, pre-
    /// fix or post-fix:** `Operations.autosave` resolves through
    /// `liveVariant`, which throws `variantNotFound` for a tombstoned
    /// variant, and `deleteContainer`'s cascade tombstones the note's blocks
    /// and variants. So the pre-fix defect is that **the surface took
    /// keystrokes it could never save** — every flush refusing, and the raw
    /// `variantNotFound(id: "…")` landing in her status line.
    ///
    /// The fact comes from the ONE header door (`adoptHeader`), which is the
    /// only thing that ever answers with the store's own reading:
    /// `Queries.containerHeader` returns nil exactly when the container row
    /// is missing or tombstoned, and it is never called speculatively — so a
    /// nil answer means the store said so, never "not loaded yet".
    ///
    /// It is deliberately NOT `isLive`. `isLive` means *the authority granted
    /// this surface the pen*, and only the authority may write it; this means
    /// *there is nothing here to write into*. Keeping them apart is what
    /// makes the resurrection road heal itself: a Put back from the Trash
    /// flips this false and the surface takes keystrokes again, where
    /// latching `isLive` would have left her looking at a restored note she
    /// could not type in until some later grant.
    @ObservationIgnored private(set) var noteIsGone = false

    /// The refusal's sentence — spoken by the gate, and by the liveness
    /// authority at the moment it declines the pen (the authority's road
    /// drops the keyboard, so the gate is never consulted there).
    ///
    /// Phone-local because it is about a PHONE surface's own state — a Write
    /// screen left standing on a tombstone by the alive-stacks shape, which
    /// the Mac has no twin of. If the Mac ever grows the same refusal it
    /// hoists this then (MobileSoul §3), rather than writing a second
    /// sentence about one 30-day clock.
    ///
    /// **CONDITIONAL ABOUT THE TRASH, ON PURPOSE** (round-1 MINOR 5). The
    /// fact underneath is `Queries.containerHeader == nil`, which is true for
    /// a MISSING row as well as a tombstoned one — and the phone has a real
    /// Delete Now door, so a stale surface can outlive its note's departure
    /// from the Trash entirely. Promising a door with nothing behind it is
    /// the failure this round words refusals to avoid; one sentence true in
    /// both shapes beats a second store read to tell them apart.
    static var deletedNoteRefusal: String {
        "This note was deleted \u{2014} if it's still in the Trash "
            + "(\(TrashWindow.days) days), put it back there to keep writing."
    }

    /// Asks the STORE whether this surface's note is still live and adopts
    /// the answer through the one header door, so `noteIsGone`, `header` and
    /// the display title can never disagree about it.
    ///
    /// The authority calls this at the moment it is about to hand over the
    /// pen. It is not the observation's job: `observeContainerHeader` is a
    /// delivery whose latency is real, and a tab tap landing inside that
    /// latency would take the pen on a stale answer. One indexed row read
    /// per liveness grant — a tab tap or a push, never a keystroke.
    @discardableResult
    func confirmNoteStillLive() async -> Bool {
        do {
            adoptHeader(try await session.database.read { [postID] db in
                try Queries.containerHeader(db, containerID: postID)
            })
        } catch {
            // A read that FAILED is not an answer about existence
            // (cancellation at teardown, a store that could not be opened):
            // the last store answer stands rather than a guess.
            //
            // **DELIBERATELY SILENT, unlike this door's two siblings**
            // (round-1 NIT 8, ENDORSED). `loadOnce` and `observeHeader` both
            // surface a non-cancellation error, because each is the road that
            // was going to PAINT something and has nothing to paint. This one
            // is a belt consulted inside a liveness handoff: refusing the pen
            // because a read failed would strand her on a note that is
            // probably fine, and (MINOR 3's measurement) keeping it cannot
            // cost a byte, since a tombstoned variant refuses every write.
            // The cost of speaking here is a sentence about plumbing on a
            // surface that is working; the cost of staying silent is nothing
            // she can lose. Recorded so the silence reads as a decision.
        }
        return !noteIsGone
    }

    /// Production attach: the text view's storage + the canary + the gate
    /// (batch 2: the delegate is the VM's own, so bare test views and the
    /// SwiftUI face police identically).
    func attach(textView: MobileEditorTextView) {
        self.textView = textView
        let gate = MobileEditorGateDelegate(model: self)
        textView.delegate = gate
        gateDelegate = gate
        textView.onCanaryFired = { [weak self] message in self?.canaryMessage = message }
        textView.armCanary()
        attach(storage: textView.textStorage)
        // S2: the takes chrome (badge/gutter/marker/pill) + the swipe-peek
        // pan ride the view; headless storage-only attaches run chromeless.
        textView.installTakes(model: self)
        // S4: the ⋯ menu's prompt seams get their production plumbing
        // (UIAlertController via the view's window; tests inject their
        // own answers — the seam is the testable brain's edge).
        if blockMenu.promptForText == nil {
            blockMenu.promptForText = { [weak textView] title, message, current, completion in
                guard let root = textView?.window?.rootViewController else {
                    completion(nil)
                    return
                }
                let alert = UIAlertController(
                    title: title, message: message, preferredStyle: .alert)
                alert.addTextField { $0.text = current }
                alert.addAction(UIAlertAction(title: "Set", style: .default) { _ in
                    completion(alert.textFields?.first?.text ?? "")
                })
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                    completion(nil)
                })
                root.present(alert, animated: true)
            }
        }
        // PR19: the emoji row's own plumbing — a small OWNED sheet rather
        // than the alert its siblings use, and the divergence is the whole
        // point of the row (PROVISIONAL, recorded).
        //
        // **Why not the alert:** `UIAlertController` hands out its own
        // `UITextField` and there is no public way to replace it or to name
        // its input mode — and the emoji KEYBOARD is precisely what needs a
        // field we own (`MobileEmojiTextField`). The two roads that keep the
        // alert are both worse: overlaying our field on the alert's private
        // view hierarchy is brittle across OS versions, and a hand-rolled
        // emoji grid as an `inputView` would invent a curated glyph list the
        // system already has. `MobileEmojiPromptController` is public API
        // only, matches the phone's sheet grammar, and — a real gain — its
        // buttons ARE drivable in process, which a `UIAlertController`'s
        // measurably are not (the surface driver's own recorded finding).
        if blockMenu.promptForEmoji == nil {
            blockMenu.promptForEmoji = { [weak textView] title, message, completion in
                guard let root = textView?.window?.rootViewController else {
                    completion(nil)
                    return
                }
                root.present(
                    MobileEmojiPromptController(
                        title: title, message: message, completion: completion),
                    animated: true)
            }
        }
        if blockMenu.confirmDestructive == nil {
            blockMenu.confirmDestructive = { [weak textView] title, message, actionTitle, completion in
                guard let root = textView?.window?.rootViewController else {
                    completion(false)
                    return
                }
                let alert = UIAlertController(
                    title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: actionTitle, style: .destructive) { _ in
                    completion(true)
                })
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                    completion(false)
                })
                root.present(alert, animated: true)
            }
        }
        // Parity C4a: the takes browser's label prompt rides the same
        // plumbing (the seam is the testable brain's edge; tests inject
        // their own answers).
        if takesBrowser.promptForText == nil {
            takesBrowser.promptForText = { [weak textView] title, message, current, completion in
                guard let root = textView?.window?.rootViewController else {
                    completion(nil)
                    return
                }
                let alert = UIAlertController(
                    title: title, message: message, preferredStyle: .alert)
                alert.addTextField { $0.text = current }
                alert.addAction(UIAlertAction(title: "Set", style: .default) { _ in
                    completion(alert.textFields?.first?.text ?? "")
                })
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                    completion(nil)
                })
                root.present(alert, animated: true)
            }
        }
    }

    /// The storage seam (tests attach a bare `NSTextStorage` — the VM's
    /// whole brain runs against it; production routes here from
    /// `attach(textView:)`).
    func attach(storage: NSTextStorage) {
        self.storage = storage
        let observer = MobileStorageObserver(model: self)
        storage.delegate = observer
        storageObserver = observer
        if let pending = pendingProjection {
            pendingProjection = nil
            applyProjection(pending)
        }
    }

    /// The screen's ARRIVAL routine (S3 ladder, MAJOR 2): everything that
    /// must complete BEFORE the infinite observation loops — the
    /// authoritative first load, then the Today door's focus raise
    /// ("cold launch → typing in two taps", now true instead of dead code
    /// sequenced after a `start()` that never returns).
    func arrive(focus: Bool) async {
        await loadOnce()
        if focus {
            textView?.becomeFirstResponder()
        }
    }

    /// Runs for the editor's lifetime: header + the takes projection, live.
    /// NEVER RETURNS while the editor lives (the loops end at task
    /// cancellation) — sequence nothing after it; that is `arrive`'s job.
    func start() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.observeHeader() }
            group.addTask { await self.observeTakesProjection() }
        }
    }

    /// One authoritative load (first paint + deterministic tests).
    func loadOnce() async {
        do {
            let value = try await session.database.read { [postID] db in
                (projection: try Queries.takesProjection(db, post: postID),
                 header: try Queries.containerHeader(db, containerID: postID))
            }
            adoptHeader(value.header)
            ingest(value.projection)
        } catch is CancellationError {
            // A push-then-immediate-pop cancels the screen's task mid-read
            // (S3 ladder round 2, NIT — the MINOR-1 class): the surface is
            // being torn down; stringifying the cancellation into the
            // status line told her nothing true.
        } catch {
            statusMessage = String(describing: error)
        }
    }

    /// THE ONE PROJECTION DOOR (S2): every store delivery — observation,
    /// first load, settle-refetch, desync heal — lands here, so fan state
    /// and slots are adopted from ONE coherent read (`Queries.
    /// takesProjection` reads both in a single transaction) and every
    /// applied projection passes the peek overlay. Slots-only callers
    /// (tests driving `applyProjection` directly) bypass peeks by
    /// construction — they hold none.
    func ingest(_ projection: Queries.TakesProjection, fromDelivery: Bool = false) {
        // Fan state adopts UNCONDITIONALLY (the S2 posture — the card
        // belt must see a remote lock the moment the delivery lands;
        // fans are bookkeeping, self-healing, never surface bytes). Only
        // the SLOT application carries MAJOR 3's delivery guard below.
        takes.adoptFans(projection.fans)
        // S4: callout frames adopt the same way (decor bookkeeping).
        presentations = projection.presentations
        applyProjection(takes.overlay(projection.slots), fromDelivery: fromDelivery)
        textView?.refreshChrome()
        // S2 batch 2: an open browser re-renders its cards from the fresh
        // fan state (and closes if its block left the surface). S4: the
        // comments sheet follows the same discipline. C4a: the history
        // sheet too.
        takesBrowser.projectionDidChange()
        comments.projectionDidChange()
        blockHistory.projectionDidChange()
    }

    /// Teardown backstop: pending tail text mints (the idle plan — typed
    /// gaps survive per the k−1 rule), then everything pending lands.
    func finish() async {
        crystallizer.cancelIdleClock()
        if mintableTail {
            idleMintTail()
        } else {
            // The attach-only pass: a pure-newline tail folds into the
            // preceding block as its trailing content (the 2026-07-12
            // meaningful-spacing rule) even though nothing mints.
            crystallizeIfNeeded()
        }
        await awaitMintSettle()
        await autosave.flushNow()
    }

    /// Bounded wait for an in-flight crystallization mint (18m U2: the shared
    /// crystallizer's).
    func awaitMintSettle() async {
        await crystallizer.awaitMintSettle()
    }

    private func observeHeader() async {
        do {
            for try await value in session.database.observeContainerHeader(postID) {
                adoptHeader(value)
            }
        } catch is CancellationError {
        } catch {
            // **THE STREAM EXITS HERE AND IS NEVER RESTARTED** — context
            // named at the round-1 review, deliberately NOT rebuilt in its
            // fix wave (a retry/backoff shape is a design act, not a
            // drive-by). After one transient observation error this surface's
            // header can only be re-answered by `loadOnce` or by
            // `confirmNoteStillLive` — which is exactly why the liveness
            // authority's tombstone arm re-confirms instead of refusing on
            // its last delivery (MAJOR 1): were it still short-circuiting,
            // one dropped stream would make a stale `noteIsGone` terminal.
            statusMessage = String(describing: error)
        }
    }

    private func observeTakesProjection() async {
        do {
            for try await value in session.database.observeTakes(postID) {
                // A delivery is a SIGNAL, never surface-rewrite authority
                // (S3 ladder, MAJOR 3 — the shared policy's delivery arm).
                ingest(value, fromDelivery: true)
            }
        } catch is CancellationError {
        } catch {
            statusMessage = String(describing: error)
        }
    }

    /// The rename alert's blank-clear explanation — hoisted and pinned
    /// (C2 ladder R1-1): the copy names what DisplayTitle's chain actually
    /// does (title → date → the created day; never "the note's own words").
    static let blankTitleClearsMessage =
        "A blank title clears the stored name — the note shows its date instead."

    func adoptHeader(_ value: Queries.ContainerHeader?) {
        header = value
        isSealed = value?.locked ?? false
        displayTitle = value.map {
            DisplayTitle.note(
                title: $0.title, entryDate: $0.entryDate, createdAt: $0.createdAt)
        }
        // **THE RELINQUISH HALF** (item 2). The store's answer about whether
        // this note exists arrives here and nowhere else, so this is where a
        // surface learns its subject went — including while it is holding the
        // keyboard, which is the sync road (deleted on the Mac) and the
        // note's own ⋯ door a beat before the pop.
        //
        // The keyboard drops the moment the note does; the pen itself is the
        // authority's to move, so `isLive` is not touched here (see
        // `noteIsGone`). Both directions are written, so a Put back from the
        // Trash restores the surface rather than stranding it.
        //
        // **AND IT DELIBERATELY SAYS NOTHING HERE** — a widening considered
        // at the round-1 MAJOR 2 fix and DECLINED, traced rather than
        // assumed. Speaking the refusal at this transition would clobber the
        // receipt on her commonest deletion road: `deleteNote` reports
        // *"Moved to the Trash…"* and the observation then delivers nil a
        // beat later, so the note's OWN ⋯ door would answer its own act with
        // a refusal about a door she just used. The refusal is spoken where
        // it is DECIDED instead (`MobileLivenessAuthority.refuseOverTombstone`),
        // which covers every road that hands this surface the pen.
        //
        // What that leaves: the SYNC road — deleted on the Mac while she is
        // looking at it here — drops the keyboard with nothing on screen
        // until the next grant or keystroke speaks. Recorded as a known
        // residue, not an oversight; closing it wants a way to tell "this
        // surface deleted it" from "someone else did", which is a design act.
        //
        // **AND IT IS OWNED, not left to whoever next edits this function**
        // (round-2 MINOR R2-3): the leftover-review-backlog row in
        // `notes/plans/mobile-round-2-handoff-2026-08-30.md` §7.2 carries the
        // mechanism and that design question; the VOICE half — what the phone
        // should SAY here — is flagged for the author.
        let wasGone = noteIsGone
        noteIsGone = (value == nil)
        if noteIsGone, !wasGone {
            textView?.endEditing(true)
            textView?.isEditable = false
        } else if !noteIsGone, wasGone, isLive, !takesBrowser.isOpen {
            textView?.isEditable = true
        }
    }

    // MARK: - The voice switch (batch 3 — LK2's application to an OPEN surface)

    /// Restyles the open surface to the (already switched) live voice —
    /// **attributes only, never a character** (display == stored holds by
    /// construction; the walk pins byte-identity across the switch). The
    /// whole document re-bases: every face bookkeeping run is dropped, the
    /// new voice's base font/ink/gap is laid over the full range (ADDS,
    /// never `setAttributes` — the block-ID projection is untouched), and
    /// the markdown face re-derives fresh with the new palette. O(open
    /// note) — the same cost class as opening the note, spent only at a
    /// deliberate settings flip, never a keystroke (recorded).
    func applyVoiceChange() {
        defer {
            textView?.applyVoiceChrome()
            textView?.canaryCheckpointAfterMutation()
            // S2: the takes chrome restyles from the new voice's face —
            // and an open browser sheet re-renders in the new voice too.
            textView?.refreshChrome()
            textView?.takesBrowserView?.render()
        }
        guard let storage, storage.length > 0 else { return }
        let full = NSRange(location: 0, length: storage.length)
        storage.beginEditing()
        // The face's bookkeeping remembers the OLD voice's restore colors —
        // drop it wholesale; the base reset below is the true restore.
        storage.removeAttribute(MarkdownFace.faceAttribute, range: full)
        storage.removeAttribute(.backgroundColor, range: full)
        storage.removeAttribute(.strikethroughStyle, range: full)
        storage.addAttribute(.font, value: MobileEditorStyle.baseFont, range: full)
        storage.addAttribute(
            .foregroundColor, value: MobileEditorStyle.face.ink, range: full)
        storage.addAttribute(
            .paragraphStyle, value: MobileEditorStyle.baseParagraphStyle, range: full)
        storage.endEditing()
        // The fresh face (its own begin/endEditing; attribute-only, so the
        // storage observer's `.editedCharacters` guard keeps it inert).
        MarkdownFace.style(
            storage, base: MobileEditorStyle.baseFont,
            palette: MobileEditorStyle.markdownPalette)
        auditIdentityProjection()
    }

    // MARK: - Projection → surface

    /// Internal so tests drive projections without the observation. The
    /// DECISION is `EditorProjectionPolicy`'s (shared, pinned); this
    /// executes it.
    func applyProjection(_ new: [Queries.RenderedBlock], fromDelivery: Bool = false) {
        guard storage != nil else {
            pendingProjection = new
            return
        }
        let decision = EditorProjectionPolicy.decide(
            loaded: loaded,
            busy: autosave.isDirty || mintInFlight,
            forceFull: forceFullRender,
            delivery: fromDelivery,
            matchesSurface: ledger.matches(new, entries: index.entries),
            sameSequence: new.map(\.blockID) == index.entries.map(\.blockID))
        switch decision {
        case .initialRender:
            renderFull(new, preserveTail: false)
            loaded = true
        case .deferUntilClean:
            pendingProjection = new
        case .forcedFullRender:
            forceFullRender = false
            renderFull(new, preserveTail: true)
        case .adoptEcho:
            // Our own autosave echo (or metadata-only movement): adopt the
            // bookkeeping, touch nothing in the view.
            slots = new
            ledger.adopt(new)
        case .differential:
            applyDifferential(new)
        case .fullRender:
            renderFull(new, preserveTail: true)
        case .refetchFresh:
            // Deliveries are SIGNALS (S3 ladder, MAJOR 3 — the retired
            // Phase 8 clean-instant guarantee restored): a value fetched
            // before the flush that just settled would regress surface +
            // ledger to pre-flush bytes. Hold the marker and settle by
            // the ONE fresh-read path — the fresh value comes back as
            // non-delivery and takes the render arms above.
            pendingProjection = new
            applyPendingIfClean()
        }
    }

    /// Full materialization through the shared core with the phone's base
    /// attributes. Caret restores by TEXT location (never px — obligation
    /// 3); batch 1 has no scroll anchoring at all.
    private func renderFull(_ new: [Queries.RenderedBlock], preserveTail: Bool) {
        guard let storage else { return }
        let tail: String?
        if preserveTail, hasOpenTail {
            tail = tailText
        } else {
            // An empty post is all tail by construction; one with blocks
            // has none.
            tail = new.isEmpty ? "" : nil
        }
        let caret = textView?.selectedRange
        let (attributed, newIndex) = EditorDocument.materializeCore(
            new, tail: tail, base: MobileEditorStyle.baseAttributes)
        // Batch 2 (M11): the markdown face at the one full-materialization
        // door — the Mac `EditorDocument.materialize` forward's exact shape.
        // ATTRIBUTES ONLY; the index still tiles the bytes exactly.
        MarkdownFace.style(
            attributed, base: MobileEditorStyle.baseFont,
            palette: MobileEditorStyle.markdownPalette)
        suppressEditProcessing = true
        storage.setAttributedString(attributed)
        suppressEditProcessing = false
        // The tiling the gate last answered against is gone (round 2, the
        // crash fix): disarm STRUCTURALLY here rather than leaning on the
        // consume-time predicate alone.
        pendingEdit = nil
        bulkPending = false  // armed BESIDE it; it goes with it (NIT 4)
        index = newIndex
        slots = new
        ledger.adopt(new)
        crystallizer.setText(tail ?? "")
        fullRenderCount += 1
        textView?.undoManager?.removeAllActions()
        if let caret, let textView {
            let location = min(caret.location, storage.length)
            textView.selectedRange = NSRange(location: location, length: 0)
        }
        auditIdentityProjection()
        textView?.canaryCheckpointAfterMutation()
        textView?.refreshChrome()
    }

    /// Same block sequence, changed texts: replace only changed slots,
    /// last-to-first so earlier ranges stay valid (the Mac executor's
    /// shape).
    ///
    /// **Cost, stated honestly (13u1 UNIT 1 — P17's phone half, the Mac
    /// twin's wording mirrored).** The STORAGE WRITES are ∝ the changed
    /// blocks; the COMPARISON is ∝ the note's text. What was wrong beyond
    /// the wording was the tiling walk: this asked `index.range(ofEntryAt:)`
    /// once per slot and that accessor walks from zero, so the loop cost
    /// Σi ≈ N²/2 in the BLOCK COUNT — P1's one prohibition, on the main
    /// actor. The tiling is now read ONCE. The ranges stay correct across
    /// the descending loop for the same reason it descends at all:
    /// replacing slot `j` cannot move the prefix sum of any entry below it.
    private func applyDifferential(_ new: [Queries.RenderedBlock]) {
        var edited = false
        let ranges = index.entryRanges()
        for i in stride(from: new.count - 1, through: 0, by: -1) {
            let newText = new[i].text ?? ""
            let range = ranges[i]
            if viewText(range) != newText {
                programmaticReplace(range, with: newText, blockID: new[i].blockID)
                edited = true
            }
        }
        pendingEdit = nil // the tiling moved — see `renderFull`
        bulkPending = false  // armed BESIDE it; it goes with it (NIT 4)
        index = BlockRangeIndex(slots: new, tail: hasOpenTail ? tailText : nil)
        slots = new
        ledger.adopt(new)
        if edited {
            // Undo entries recorded against the old surface would replay at
            // stale offsets; drop them.
            textView?.undoManager?.removeAllActions()
        }
        auditIdentityProjection()
        // TEXTKIT2_NOTES §4 practice 3: every road that writes storage checks
        // the fallback canary at the mutation, not at the next keystroke or
        // the ≤30 s tick. This was the one storage-writing road on the phone
        // still missing it (round-2 ladder round 2, NIT 3) — `renderFull`,
        // `programmaticReplace`'s callers and the take-swap door all check.
        textView?.canaryCheckpointAfterMutation()
        textView?.refreshChrome()
    }

    /// **Is a projection still waiting?** A fact on the model rather than a
    /// private field a pin cannot see — the Mac's 17b P36 fact, its phone
    /// twin (18m U2, F-2): a branch that decides whether an external change
    /// ever reaches the surface should be checkable.
    var hasDeferredProjection: Bool { pendingProjection != nil }

    /// A deferred delivery settles by a FRESH read — the deferred value was
    /// fetched before the flush that just landed; adopting it as-is would
    /// transiently revert the edited block (the Mac's exact posture).
    func applyPendingIfClean() {
        guard !autosave.isDirty, !mintInFlight, pendingProjection != nil else { return }
        // **18m U2, F-2 — the phone twin of 17b P36: hold the marker while
        // the re-read runs.** The two guards below both put a value BACK on
        // their failure paths; the read-failure arm returned bare, so a
        // thrown read — a lock closing the keyed store while a settle is in
        // flight (`StoreLockedError`) — dropped the deferred marker and
        // nothing re-armed it: an externally-changed projection (a
        // sync-arrived conflict take, a chosen-take flip from another
        // surface) then waited on a FURTHER store write.
        let deferred = pendingProjection
        pendingProjection = nil
        let generation = storeWriteGeneration
        Task { [weak self] in
            guard let self else { return }
            guard let fresh = try? await session.database.read({ [postID] in
                try Queries.takesProjection($0, post: postID)
            }) else {
                // The re-read failed: restore the marker, exactly as the two
                // guards below do with theirs. The value is a stale
                // photograph, so what this buys is the RETRY — the next
                // clean moment re-reads (the Mac's P36 line, twinned).
                pendingProjection = deferred
                return
            }
            guard !autosave.isDirty, !mintInFlight else {
                pendingProjection = fresh.slots
                return
            }
            guard generation == storeWriteGeneration else {
                // A settle landed DURING the read (the value may predate
                // its writes — MAJOR 3's fence): re-signal; the loop
                // converges the moment the store goes quiet.
                pendingProjection = fresh.slots
                applyPendingIfClean()
                return
            }
            ingest(fresh)
        }
    }

    // MARK: - Takes routing (S2 batch 1 — the thin half; the brain is `takes`)

    /// The slot bookkeeping for one block, as displayed (post-overlay).
    func slot(for blockID: String) -> Queries.RenderedBlock? {
        slots.first { $0.blockID == blockID }
    }

    /// The surface's own record of a variant's text (the ledger — what
    /// THIS surface knows it holds, edits included, flushed or not). The
    /// peek overlay resolves ledger-first so a just-edited take never
    /// re-displays stale bytes.
    func surfaceKnownText(variantID: String) -> String? {
        ledger.textByVariant[variantID]
    }

    /// The status voice for sibling objects' refusals (the takes ✓ door;
    /// S2 batch 2 widened it to optional so a verb's SUCCESS clears the
    /// previous refusal — the Mac `run()`'s clearing posture).
    func report(_ message: String?, action: StatusAction? = nil) {
        statusMessage = message
        statusAction = action
    }

    // MARK: - The pending-text contract

    /// **ONE declared act, ONE contract, however many doors** — the Takes
    /// board's rule, HOISTED here at round 2 batch 2. It was already
    /// living in two places (`lockNote` and
    /// `MobileStructuralController.flushPendingText`) with the sentence
    /// written out twice; the copy door would have made three, which is
    /// the copy-drift class MobileSoul §3 names. Both former homes now
    /// call this.
    ///
    /// Why every door needs it: pending SURFACE bytes must reach the store
    /// BEFORE a door that writes through an op (the op validates against
    /// text she cannot see) or READS the store (the read hands back a note
    /// missing her last seconds — the standing Mac defect, KnownIssues
    /// "Copy doors read the store past a dirty buffer"). It speaks its own
    /// refusal, so callers may simply `guard`.
    ///
    /// *(A forward since the VM-5 whole-round pass, MINOR 4: the sentence's
    /// one home is `OpsRefusalCopy.unsavedChanges`, because the shared
    /// `VersionActs` speaks it too and a second phone-visible literal would
    /// be this file's own drift class. The name stays so every pin rides.)*
    static let unsavedChangesRefusal = OpsRefusalCopy.unsavedChanges

    @discardableResult
    func flushPendingText() async -> Bool {
        await autosave.flushNow()
        guard !autosave.isDirty else {
            report(Self.unsavedChangesRefusal)
            return false
        }
        return true
    }

    // MARK: - Find in note (parity C4b item 3 — the ⌘F family's phone
    // face: the system find navigator on the Write surface)

    /// Presents the system find navigator over this note (find only —
    /// the surface declines text replacement structurally; the
    /// `supportsTextReplacement` override carries the reasoning). The
    /// masthead's magnifier is the door; hardware ⌘F reaches the same
    /// interaction through the system's own key commands.
    func presentFind() {
        textView?.findInteraction?.presentFindNavigator(showingReplace: false)
    }

    // MARK: - Copy the whole note (round 2 batch 2 — M3 ≡ R6)

    /// **Her ask, verbatim: *"I also need a button added at the top that
    /// allows me to copy everything i've written in a particular note."***
    /// The masthead's ⧉ is the door; `MobileNoteClipboard` owns the shape,
    /// the words, and the pasteboard (its header carries the reasoning —
    /// the projection IS the `.md` export, title excluded).
    ///
    /// Three things this routing is responsible for, and all three are
    /// exactly why the door lives here and not in the view:
    /// 1. **It flushes first.** A copy READS the store, and the surface is
    ///    deliberately buffer-authoritative while dirty — copying without
    ///    the flush hands her a note missing the last seconds of typing
    ///    (the standing Mac defect this app must not re-open; KnownIssues,
    ///    "Copy doors read the store past a dirty buffer"). The shared
    ///    contract speaks its own refusal, so a failed flush copies
    ///    NOTHING and says why, rather than quietly copying stale prose.
    /// 2. **It carries the open tail**, which no store read can supply
    ///    (see the file header) — and it decides the tail is content by
    ///    the app's own `mintableTail` rule, never a second one.
    /// 3. **It works under the seal.** Nothing below writes a row, and
    ///    reading stays free under a seal (AppSpec §9's letter) — so a
    ///    locked note copies exactly like an open one.
    func copyNote(to destination: MobileClipboard.Destination = .general) async {
        guard await flushPendingText() else { return }
        let openTail = mintableTail ? openTailText : ""
        let displayed = displayedTextByBlock
        do {
            let projection = try await session.database.read { [postID] db in
                try MobileNoteClipboard.markdown(
                    db, postID: postID, openTail: openTail, displayed: displayed)
            }
            // The receipt carries the projection's OWN answer about which
            // road it took — so the one copy that cannot follow the screen
            // (the callout corner) says so instead of reading as ordinary.
            report(MobileNoteClipboard.copy(projection, to: destination).message)
        } catch {
            report(MobileNoteClipboard.Outcome
                .failed(String(describing: error)).message)
        }
    }

    /// **M23 ≡ R15 — what this surface is DISPLAYING, block by block.**
    ///
    /// Her ruling: *"copy should follow what's on the screen."* This is the
    /// ruled SHAPE of it — **ask the surface what it is displaying**, never
    /// a second selection-derivation rule (§31). There is no derivation
    /// here to get wrong: `slots` IS the display. A peek (and a lens
    /// activation, which drives the same primitive) swaps the slot's variant
    /// and text inside `MobileTakesController.overlay(_:)` BEFORE the VM
    /// ever sees the projection, so a displayed slot already holds the
    /// displayed take.
    ///
    /// **EMPTY when nothing is peeked, and that is load-bearing:** the copy
    /// door then takes the road that shipped, byte for byte — the surface's
    /// own `peeks` dictionary is the cheap, exact answer to "is anything on
    /// screen other than the store's chosen", so the no-lens case needs no
    /// proof beyond it.
    ///
    /// Text resolves LEDGER-FIRST, the peek overlay's own rule, so a take
    /// edited a keystroke ago copies the bytes on screen. (The door flushes
    /// first, which makes that a no-op on the ordinary road and the honest
    /// answer on a refused one.)
    var displayedTextByBlock: [String: String] {
        guard !takes.peeks.isEmpty else { return [:] }
        var displayed: [String: String] = [:]
        for slot in slots {
            guard let variantID = slot.variantID else { continue }
            displayed[slot.blockID] = surfaceKnownText(variantID: variantID)
                ?? slot.text ?? ""
        }
        return displayed
    }

    /// The open tail exactly as the surface holds it right now — read from
    /// the storage, never from a cached copy, so a door asking mid-typing
    /// gets the characters on screen. (`syncTailText` keeps `tailText` in
    /// step for the crystallization brain; this is the same read, on
    /// demand, and the two share one expression.)
    var openTailText: String {
        guard let range = index.tailRange else { return "" }
        return viewText(range)
    }

    // MARK: - The block list's jump (parity C4b item 5 — the in-note
    // block list's tap: "tap jumps the editor there")

    /// Places the caret at the block's start and scrolls its first line
    /// near the viewport's top. The geometry rides
    /// `firstLineGeometry(atOffset:)` — `.ensuresLayout` on exactly the
    /// target fragment (the hybrid-jump cost class: one fragment, never
    /// the document); `scrollRangeToVisible` is the honest fallback
    /// where TK2 offers no fragment yet.
    func jumpToBlock(_ blockID: String) {
        guard let range = rangeOfBlock(blockID), let textView else {
            report("That block is no longer in this note.")
            return
        }
        textView.selectedRange = NSRange(location: range.location, length: 0)
        if let geometry = textView.firstLineGeometry(atOffset: range.location) {
            // Container coords → content offset: the container starts
            // below the top inset; land the block a breath under the
            // viewport's top edge. Deliberately NOT clamped against
            // `contentSize` — TK2's height ESTIMATE can run under the
            // real layout at the target (TEXTKIT2 §2's class), and the
            // fragment provably exists at this y (its layout was just
            // ensured); the typewriter room's bottom inset already
            // makes any block's top a legitimate scroll target.
            let target = geometry.fragmentMinY + textView.textContainerInset.top - 24
            textView.setContentOffset(CGPoint(x: 0, y: max(0, target)), animated: false)
        } else {
            textView.scrollRangeToVisible(range)
        }
    }

    // MARK: - The note seal (parity round Stage A batch A1, item 4 — her
    // ruling verbatim: "i do think that you should be able to unlock a
    // note and lock it on mobile"; the sealed refusals lose their Mac
    // redirect in the same batch, the no-redirect principle)

    /// Seals the note through the core's `lockPost` (which auto-commits
    /// dirty STORE buffers first — I6's consequence-not-equivalence).
    /// FLUSH-GUARDED like every structural door (the Takes board
    /// contract): pending SURFACE bytes must reach the store BEFORE the
    /// seal — an autosave flush landing after it would refuse
    /// `.lockedPost` and the typed text could never land (the text-loss
    /// class the flush-first contract exists to kill), and the seal's own
    /// auto-commit insurance can only insure what the store holds.
    func lockNote() async {
        guard await flushPendingText() else { return }
        await setSeal(locked: true)
    }

    /// Reverses the seal (`unlockPost` — zero commits; the pre-lock
    /// editing surface returns exactly).
    func unlockNote() async {
        await setSeal(locked: false)
    }

    // MARK: - Rename note (parity C2 — note metadata, "full app
    // functionality"; the masthead title is the door)

    /// Renames the note through the core's `renameContainer`. A blank
    /// (or whitespace) title stores NIL — the ⌘N semantics (13g R6-3, no
    /// stored placeholder; the display title falls back to the derived
    /// brain). Legal under the seal BY DESIGN (AppSpec §9's letter: the
    /// seal is content-level — the post "may still be … retitled").
    func renameNote(_ title: String?) async {
        let trimmed = title?.trimmingCharacters(in: .whitespacesAndNewlines)
        let stored = (trimmed?.isEmpty ?? true) ? nil : trimmed
        do {
            try await session.runner.run { [postID] ops in
                try ops.renameContainer(postID, title: stored)
            }
            report(nil)
            // Deterministic flip for headless harnesses (the setSeal
            // precedent); the observation echoes it in production.
            let header = try await session.database.read { [postID] db in
                try Queries.containerHeader(db, containerID: postID)
            }
            adoptHeader(header)
        } catch {
            report(String(describing: error))
        }
    }

    // MARK: - Delete the note (round 2, batch 4 — PR1)

    /// **The phone could not delete a note. At all, from anywhere.** The
    /// parity inventory's headline finding: `deleteContainer` appeared in
    /// `VariorumMobile/` exactly once, inside the tutorial seeder's own
    /// cleanup. This is the door, and the masthead's ⋯ sheet + the Library
    /// row's long-press are its two faces.
    ///
    /// **Move to Trash, and it says so.** The tombstone is recoverable for
    /// `TrashWindow.days` through the phone's own Trash (batch 4's other
    /// half) — so the confirm names the destination and the clock rather
    /// than promising or threatening anything it cannot keep (J8's bar).
    ///
    /// **Flush FIRST, like every structural door.** `deleteContainer`
    /// cascades to the note's blocks and their takes; a refused flush that
    /// left typed bytes pending while the tombstone landed would strand
    /// them outside both the surface and the rows they belong to — the
    /// exact text-loss class `deleteBlock`'s contract exists to kill. A
    /// refused flush refuses the delete, and speaks.
    ///
    /// Legal under the seal BY DESIGN (AppSpec §9: the seal is
    /// content-level — the post "may still be … deleted (recoverable via
    /// restoreContainer)"), so no seal guard is written here.
    ///
    /// Returns whether the note went, so the screen can navigate away — a
    /// surface standing on a tombstoned note is the one thing this door
    /// must never leave behind.
    @discardableResult
    func deleteNote() async -> Bool {
        guard await flushPendingText() else { return false }
        do {
            try await session.runner.run { [postID] ops in
                try ops.deleteContainer(postID)
            }
            report(RecoveryCopy.movedToTrashReceipt(.note))
            return true
        } catch {
            report(Self.deleteNoteRefusal(error))
            return false
        }
    }

    /// **SAVE A VERSION — the whole note's moment** (batch 6c; the note ⋯
    /// sheet's row, ⌘⇧S's phone twin).
    ///
    /// The DECISION layer is shared (`Shared/VersionActs.swift`) and it is
    /// what makes the flush non-optional: a moment saved while a keystroke
    /// is still pending would be a moment missing the words that summoned
    /// it. This door adds only the phone's voice — its receipt and its
    /// refusal both land in the ONE status slot, which is rendered wherever
    /// the acting door is standing (the ⋯ sheet, or the masthead).
    func saveVersion() async {
        do {
            report(try await VersionActs.save(session: session, postID: postID))
        } catch {
            report(VersionActs.words(error, seal: .phone))
        }
    }

    /// The delete door's confirm words — the shared deletion vocabulary, so
    /// the phone and the Mac cannot describe one clock two ways.
    ///
    /// **13l Act 2 (ledger item 3): HOISTED, and these are forwarders.** They
    /// were born here with a comment saying they were *"born shared because
    /// the phone built the doors first and the Mac's 13l work will want the
    /// same words"* — and the Mac cannot import a `VariorumMobile` file, so
    /// the Mac's note-delete doors would have had to re-write every one of
    /// them. The words live in `Shared/RecoveryCopy.swift` now; the names stay
    /// here so this file's own pins ride unmodified (the 3C parity pattern).
    static let deleteNoteTitle = RecoveryCopy.deleteNoteTitle
    static var deleteNoteConfirmTitle: String { RecoveryCopy.deleteNoteConfirmTitle }
    static var deleteNoteConfirmDetail: String { RecoveryCopy.deleteNoteConfirmDetail }

    /// **THE REFUSAL FORWARDS TOO** (4.5c-phone item 4 — A1-18's 4.5c share,
    /// and the LAST `String(describing:)` fallback in this door's family).
    ///
    /// `DeletionRefusal` was built at 4.5b to be the one home for the deletion
    /// story's refusals, precisely because three private tables each covered a
    /// different subset of `OperationError` and each fell through to a bare
    /// enum dump — so one refused act read three ways depending on the door.
    /// This was the third table. Its ONE mapped case (`containerNotFound` →
    /// *"That note is already gone."*) is byte-identical there, so nothing she
    /// has already seen changes; what changes is everything the `default` used
    /// to dump — `lockedPost` and the whole "already back" family now speak,
    /// and a case none of them anticipated arrives as a sentence that still
    /// carries the technical name rather than as `lockedVariant` alone.
    ///
    /// `act: .delete` is passed explicitly: the same `OperationError` wants
    /// different words at a delete door and a put-back door, which is why
    /// `Act` is a parameter there rather than two functions.
    static func deleteNoteRefusal(_ error: Error) -> String {
        DeletionRefusal.words(error, act: .delete)
    }

    private func setSeal(locked: Bool) async {
        do {
            try await session.runner.run { [postID] ops in
                if locked {
                    try ops.lockPost(postID)
                } else {
                    try ops.unlockPost(postID)
                }
            }
            report(nil)
            // The observation echoes this in production; the explicit
            // re-read makes the flip deterministic (headless harnesses
            // drive no observation) — the adoptHeader path is the ONE
            // seal authority either way.
            let header = try await session.database.read { [postID] db in
                try Queries.containerHeader(db, containerID: postID)
            }
            adoptHeader(header)
        } catch {
            report(String(describing: error))
        }
    }

    // MARK: - Entry date (parity C2 — her mid-chain sitting, item 4:
    // "entry date crosses"; the note-metadata family's last member)

    /// The malformed-day refusal (refuse-and-KEEP — the ExtentInput
    /// parallel: a typo must never silently clear a stored date). Pinned
    /// static; no platform name.
    static let entryDateRefusal =
        "Dates are plain days like 2026-08-09 — nothing was changed."

    /// Sets (or clears) the note's entry date through the core's own
    /// `setEntryDate`. Blank/whitespace → CLEAR (nil — un-dating a note
    /// is legitimate, the op's own letter); a malformed day is refused by
    /// the op (`invalidEntryDate` — the belt) and spoken in phone words.
    /// Like rename, this is container METADATA (the retitle class): the
    /// op accepts it under the seal on both platforms — recorded, pinned.
    func setEntryDate(_ raw: String?) async {
        let trimmed = raw?.trimmingCharacters(in: .whitespacesAndNewlines)
        let stored = (trimmed?.isEmpty ?? true) ? nil : trimmed
        do {
            try await session.runner.run { [postID] ops in
                try ops.setEntryDate(postID, entryDate: stored)
            }
            report(nil)
            let header = try await session.database.read { [postID] db in
                try Queries.containerHeader(db, containerID: postID)
            }
            adoptHeader(header)
        } catch let error as OperationError {
            if case .invalidEntryDate = error {
                report(Self.entryDateRefusal)
            } else {
                report(String(describing: error))
            }
        } catch {
            report(String(describing: error))
        }
    }

    /// True while an input-method composition is in flight (the flip and
    /// the idle mint share the bail — mutating mid-composition rewrites
    /// the marked region).
    var markedTextActive: Bool { textView?.markedTextRange != nil }

    /// The block whose entry contains this surface offset (zero-length
    /// entries match at their exact location; separators and the tail
    /// belong to no block) — the pan router's hit-test half.
    func blockID(atSurfaceOffset offset: Int) -> String? {
        var location = 0
        for entry in index.entries {
            if entry.length == 0, offset == location { return entry.blockID }
            if offset >= location, offset < location + entry.length { return entry.blockID }
            location += entry.length + 1
        }
        return nil
    }

    /// One block's current surface range (nil when not on this surface).
    func rangeOfBlock(_ blockID: String) -> NSRange? {
        guard let i = index.entries.firstIndex(where: { $0.blockID == blockID })
        else { return nil }
        return index.range(ofEntryAt: i)
    }

    /// EVERY block's current surface range, from ONE index walk —
    /// O(entries) total (parity B3, FB2-1's cost half): the chrome
    /// controllers read a range per decorated block per pass, and
    /// per-block `rangeOfBlock` is an O(entries) scan, so the old
    /// decorated×entries per-tick cost was real milliseconds at 100k.
    /// Block IDs are unique on the surface by I2 (one live placement),
    /// so the dictionary is exact.
    func blockRangesByID() -> [String: NSRange] {
        var ranges = [String: NSRange](minimumCapacity: index.entries.count)
        var location = 0
        for entry in index.entries {
            ranges[entry.blockID] = NSRange(location: location, length: entry.length)
            location += entry.length + 1
        }
        return ranges
    }

    // MARK: - Takes browser routing (S2 batch 2 — thin; the brain is `takesBrowser`)

    /// The block "at" a caret or menu location, boundary-tolerant: a caret
    /// sitting at a block's very END rests ON the separator position, so
    /// the exact-offset read comes back empty there — the position one to
    /// the left answers for it. The open tail and true gaps stay nil
    /// (takes live on blocks).
    func blockIDNearOffset(_ offset: Int) -> String? {
        if let hit = blockID(atSurfaceOffset: offset) { return hit }
        guard offset > 0 else { return nil }
        return blockID(atSurfaceOffset: offset - 1)
    }

    /// The browser's doors (badge tap, the bar's ⑂, the edit-menu item).
    func openTakesBrowser(blockID: String) {
        takesBrowser.open(blockID: blockID)
    }

    /// The comments sheet's doors (the ⋯ menu, the ●n marker) — S4.
    func openComments(blockID: String) {
        comments.open(blockID: blockID)
    }

    /// The ⋯ menu's target: the caret's block, boundary-tolerant. nil in
    /// the open tail / gaps (the menu's doors speak or aren't offered).
    func blockIDAtCaret() -> String? {
        blockIDNearOffset(textView?.selectedRange.location ?? 0)
    }

    /// The bar's ⑂: the caret's block, or an honest refusal — the open
    /// tail is not yet a block (PROVISIONAL wording, recorded).
    func openTakesBrowserAtCaret() {
        let caret = textView?.selectedRange.location ?? 0
        guard let blockID = blockIDNearOffset(caret) else {
            report("Tap into a block first — takes live on blocks.")
            return
        }
        takesBrowser.open(blockID: blockID)
    }

    /// One fresh coherent read through the one projection door — the
    /// browser's verbs settle through this (flush first so the delivery
    /// adopts cleanly instead of deferring against a dirty buffer).
    func refreshTakesFromStore() async {
        await autosave.flushNow()
        guard let fresh = try? await session.database.read({ [postID] in
            try Queries.takesProjection($0, post: postID)
        }) else { return }
        ingest(fresh)
    }

    /// A browser-card edit lands in the ONE ledger + autosave the page
    /// uses (batch 1's variant-routed pattern) — the sheet and the page
    /// can never disagree about a take's bytes.
    func recordTakeEdit(variantID: String, text: String, charDelta: Int) {
        ledger.recordEdit(variantID: variantID, text: text)
        autosave.record(variantID: variantID, text: text, charDelta: charDelta)
    }

    /// THE TARGETED DISPLAY APPLY (the flip's surface half): swap ONE
    /// block's displayed slot in place — text via the ordinary
    /// programmatic-replace door (block-ID attribute + markdown face ride
    /// it), the index entry rebuilt surgically. Deliberately NOT a whole-
    /// index rebuild from `slots`: other blocks may be DIRTY (typed,
    /// unflushed), and their slot texts are stale photographs — only this
    /// entry may move. Zero store writes by construction: nothing here
    /// touches the ledger's dirty set, the autosave, or the database.
    func displaySlot(_ slot: Queries.RenderedBlock, for blockID: String) {
        guard let i = index.entries.firstIndex(where: { $0.blockID == blockID })
        else { return }
        let range = index.range(ofEntryAt: i)
        let newText = slot.text ?? ""
        if viewText(range) != newText {
            programmaticReplace(range, with: newText, blockID: blockID)
            // Undo entries recorded against the pre-flip surface would
            // replay at stale offsets (the differential's own posture).
            textView?.undoManager?.removeAllActions()
        }
        // **B45-2 — the slot write is BY IDENTITY, never by the index's own
        // index.** `i` indexes `index.entries`, and the two arrays really do
        // diverge: `finishMint` APPENDS to the index (`index.crystallize`)
        // and never assigns `slots`, so throughout a crystallization window
        // `entries` outruns `slots` and `slots[i]` is an out-of-range TRAP
        // for any freshly minted block. Nothing reaches here for such a
        // block today only because both takes-controller callers guard on
        // `slot(for:)`, which searches `slots` — a CALLER-SIDE ACCIDENT, not
        // an invariant, and batch 7's reorder-takes door walks into exactly
        // this room (the stability survey's own words: *"a takes door on a
        // fresh mint makes `slots[i]` an out-of-range trap"*).
        //
        // A block the projection has not echoed back yet simply has no slot
        // bookkeeping to update — the next projection brings it, which is
        // already the state `slot(for:)` reports for it. Deliberately NOT
        // appended: `slots` is index-parallel with `entries` for every other
        // reader (`planCrossBlockEdit`'s arities, the browser's position
        // count), and inventing a row here would end the lag that
        // `StructuralGesturePlanner.World.fanArity` and
        // `CrossBlockCompound` both guard for on purpose.
        if let s = slots.firstIndex(where: { $0.blockID == blockID }) {
            slots[s] = slot
        }
        var entries = index.entries
        entries[i] = BlockRangeIndex.Entry(
            blockID: slot.blockID,
            variantID: slot.variantID,
            length: (newText as NSString).length,
            editable: !slot.isGap && !slot.variantLocked)
        index = BlockRangeIndex(entries: entries, tailLength: index.tailLength)
        // The FOURTH index-replacement door gets the structural disarm the
        // other three have (round-2 ladder round 1, NIT 8). A take flip to
        // an EQUAL-LENGTH take leaves `documentLength` unchanged, so the
        // consume-time guard cannot see that the tiling moved — and the
        // fix's own doctrine is "clear the arming wherever the index is
        // replaced", which is cheaper to keep than an explanation of why
        // one door is different.
        pendingEdit = nil
        bulkPending = false  // armed BESIDE it; it goes with it (NIT 4)
        // The ledger learns what the surface now shows for the DISPLAYED
        // variant only — never a wholesale adopt, which would regress a
        // dirty neighbor's recorded text to its stale slot photograph.
        if let variantID = slot.variantID {
            ledger.recordEdit(variantID: variantID, text: newText)
        }
        auditIdentityProjection()
        textView?.canaryCheckpointAfterMutation()
        textView?.refreshChrome()
    }

    // MARK: - Edit routing (the delegate entry points)

    /// The gate (UITextViewDelegate shouldChangeTextIn). `isPaste` rides in
    /// from the view's flag so the tail's bulk-entry semantics arm exactly
    /// when a paste lands there.
    func shouldChangeText(in range: NSRange, replacement: String?, isPaste: Bool = false) -> Bool {
        // E1 — the settling experiment's GATE half (`MobileEditTrace`, and
        // its header carries the whole why). Inert unless armed from
        // Settings ▸ Diagnostics; a pure append either way, so no routing,
        // verdict, refusal or ordering below is touched.
        MobileEditTrace.gate(
            range: range,
            replacementLength: (replacement as NSString?)?.length ?? -1)
        guard !suppressEditProcessing else { return true }
        // The liveness belt (S3 ladder BLOCKER): a stood-down surface is
        // read-tier — resigned and uneditable already; this refusal is the
        // third guard for whatever slips past both (PROVISIONAL wording).
        // **THE TOMBSTONE BELT** (item 2), and it is FIRST of the three on
        // purpose — the ORDER here decides which true sentence she reads.
        //
        // The authority stands a surface down when it refuses the pen over a
        // tombstone, so by the time a keystroke arrives `!isLive` is also
        // true; below the liveness belt this door would answer *"This note is
        // live in your other tab"* about a note that is in the Trash. Above
        // it, the more specific truth wins, and it is the one with a road in
        // it.
        //
        // Its position above the SEAL is not a constraint at all, and the
        // comment that claimed one is corrected here (round-1 NIT 9): a gone
        // note has a nil `header`, so `header?.locked == true` is false
        // whatever the order — the seal belt could never speak for it.
        //
        // Both the pen and the keyboard are already withdrawn by the time a
        // keystroke could arrive here on the ordinary roads; this is the
        // guard for whatever slips past both — a marked-text commit already
        // in flight, a hardware keyboard on a surface iOS has not resigned.
        if noteIsGone {
            refuse(Self.deletedNoteRefusal)
            return false
        }
        if !isLive {
            refuse("This note is live in your other tab.")
            return false
        }
        if header?.locked == true {
            refuse(SealedNoteCopy.sentence(act: "edit", words: .phone))
            return false
        }
        guard let replacement else { return true } // attribute-only
        let verdict = index.verdict(
            replacing: range,
            replacementIsSingleNewline: replacement == "\n",
            segmentation: header?.effectiveSegmentation ?? .paragraph)
        switch verdict {
        // NIT 4 (round-2 ladder round 2): `bulkPending` is armed BESIDE the
        // verdict off this same call, so every road that drops the arming
        // drops the intent with it — the doctrine NIT 8 was ruled on,
        // applied consistently rather than only where a bug was traced. The
        // two `pendingEdit = nil` sites that deliberately do NOT clear it
        // are named at their own lines: the consume road (which clears it
        // only when the arming is DECLINED — a bound arming's paste must
        // keep its semantics) and `finishCrystallization` (where a
        // paste-during-mint's intent is being carried across the flight ON
        // PURPOSE).
        case .refuse(.indexDesync):
            pendingEdit = nil
            bulkPending = false
            desyncRecovery()
            return false
        case .refuse(.crossesBlockBoundary):
            pendingEdit = nil
            bulkPending = false
            // The keystroke is refused HERE (the storage must not half-apply
            // a cross-block edit) and whichever road claims it reproduces its
            // exact intent — the Mac's own shape. **R18 ≡ M11** (round 2,
            // batch 1b) made her whole-block delete WORK instead of speaking;
            // **M22** (batch 3) brought merge-then-edit here from the Mac (her
            // §30 correction — it was a parity gap); **13u1 UNIT 2** rebuilt
            // that compound to her item 5 rulings, and the phone inherits the
            // semantics ruled ONCE for both platforms (her own coordination
            // flag); **13u2 UNIT C** brought #109's clamp.
            //
            // **18m U1: WHICH road answers is ONE pure decision** —
            // `EditorEditRoute.route` walks the phone's DECLARED arm list
            // (`Self.routeArms`) in its ruled order and stops at the first
            // claim. Every arm's ruling — J9 above the clamp for the Mac's
            // reason, the gap fence's COPY arm above the compound (MINOR
            // 3(a)) — lives at `EditorEditRoute.Arm` now, pinned as data. The
            // phone's list deliberately carries NO seam carves (A7, #34 —
            // KnownIssues row 51): a seam backspace declines every arm and
            // the diagnosis speaks, in the phone's own roads. The phone's
            // editor has no find-and-replace, so its `findReplacing` fact is
            // `false`, said out loud rather than defaulted.
            performCrossBlockRoute(
                EditorEditRoute.route(
                    range: range, replacement: replacement,
                    index: index, slots: slots,
                    findReplacing: false,
                    arms: Self.routeArms,
                    surfaceText: { viewText($0) }),
                range: range)
            return false
        case .refuse(let refusal):
            pendingEdit = nil
            bulkPending = false
            refuse(message(for: refusal))
            return false
        default:
            if case .tail = verdict, isPaste {
                bulkPending = true
            }
            pendingEdit = ArmedEdit(
                verdict: verdict,
                range: range,
                documentLength: index.documentLength,
                replacementLength: (replacement as NSString).length)
            MobileEditTrace.armedVerdict() // E1 — this consult parked a verdict
            return true
        }
    }

    // MARK: - 18m U1: the phone's face on the ONE cross-block route

    /// The phone's DECLARED cross-block ladder (`EditorEditRoute.phoneArms` —
    /// pinned as this platform's list, so the gate can never quietly walk
    /// another one, and so the day the catch-up builds row 51's carves the
    /// change is visible here and in the pin, never inside a ladder).
    static let routeArms = EditorEditRoute.phoneArms

    /// Maps the route's answer onto the road and the words the phone has
    /// always had — and RE-DERIVES NOTHING (the 18m U1 ruling's condition
    /// 3): no second guard lives here; each executor keeps its own flush
    /// contract and store-time re-checks, byte-untouched. Every claiming road
    /// runs on the next main-actor turn through the one chained schedule,
    /// exactly as before.
    private func performCrossBlockRoute(_ route: EditorEditRoute.Route, range: NSRange) {
        switch route {
        case .deleteWholeBlocks(let blockIDs):
            // **NO CONFIRM HERE, and that is a RULING, not an oversight**
            // (author, 2026-08-21 — round 2 ladder R13, superseding §24's
            // MAJOR 1 disposition; her words: *"it's fine to have no
            // confirm"*). The answer to a one-keystroke bulk delete with no
            // way back is the way back — the structural undo/redo door (M20)
            // and the per-note tray (M21/R3). Do not re-add a confirm to this
            // road without her word (`MobileStructural.deleteWholeBlockRun`
            // carries the same note at the door).
            scheduleGestureCompound { [weak self] in
                await self?.structural.deleteWholeBlockRun(blockIDs)
            }
        case .editInBlock(let inBlock):
            scheduleGestureCompound { [weak self] in
                self?.runClampedInBlockEdit(inBlock)
            }
        case .refuseAwaitingSync:
            // The gap fence's COPY arm: the span IS a whole-block run; the
            // block simply hasn't arrived. **18m U3 (O-1 (a), PROVISIONAL —
            // QUESTIONS #159):** it speaks the SHARED `.unsyncedBlock`
            // sentence — the one this editor already says for the same gap
            // under a mid-to-mid span (its diagnosis), and the Mac's for this
            // very run — instead of the gate's single-block "This block
            // hasn't fully synced" line, so one condition reads one way on
            // both platforms and in both shapes. (Which cause a run ending
            // on the open tail's separator names FIRST — the Mac's tail, this
            // arm's gap — is recorded, not changed: it is this arm's POSITION,
            // U1's settled table.)
            refuse(CrossBlockRefusal.message(for: .unsyncedBlock, fanRoads: Self.fanFoldRoads))
        case .editAcrossBlocks(let compound):
            // Compare-and-set against the plan-time surface texts is inside
            // the compound, so a keystroke landing in the scheduling window
            // makes it refuse visibly rather than clobber newer text.
            scheduleGestureCompound { [weak self] in
                await self?.structural.runCrossBlockEdit(compound)
            }
        case .refuse(let cause):
            // **U-5, the wording half** (13u1 UNIT 2): the diagnosis names
            // WHICH real cause declined — the same brain the Mac speaks, in
            // the phone's own roads.
            refuse(CrossBlockRefusal.message(for: cause, fanRoads: Self.fanFoldRoads))
        case .refuseFindReplace, .carveEmptyBlock, .mergeTextedSeam:
            // Arms the phone does NOT declare (no find-and-replace; the seam
            // carves are KnownIssues row 51's), so the route can never return
            // them here (pinned). Swift's exhaustiveness still asks: DEBUG
            // stops the world on the impossible state; Release — where the
            // seam's default handler is a no-op — says exactly what the phone
            // says today when every declared arm declines.
            EditorAssertionSeam.fire("the cross-block route answered an arm the phone does not declare")
            refuse(CrossBlockRefusal.message(
                range: range, index: index, slots: slots, fanRoads: Self.fanFoldRoads))
        }
    }

    /// R18 ≡ M11 — the phone's face on the shared whole-block-delete plan
    /// (the Mac's `EditorSurfaceController.planWholeBlockDeletion` twin).
    /// Which blocks does this span cover WHOLE, if the edit is a delete?
    /// Exposed (not private) so pins can assert what declines without
    /// driving a store write.
    func planWholeBlockDeletion(range: NSRange, replacement: String) -> [String]? {
        index.wholeBlockDeletion(covering: range, replacement: replacement)
    }

    /// M22 — the phone's face on the shared cross-block plan (the Mac's
    /// `EditorSurfaceController.planCrossBlockEdit` twin, over the same
    /// `CrossBlockCompound`).
    ///
    /// **It takes no fan arity since 13u1 UNIT 2** (item 8's U-1): the fan
    /// decides whether the ends JOIN, and `slots` is the projection — held
    /// stale while the buffer is dirty, and short of `entries` during a mint
    /// window. A decision read from it would be an authorization read from a
    /// snapshot, which is exactly the class the 13c R3-1 finding closed. The
    /// run-time read lives in `MobileStructural.runCrossBlockEdit`.
    /// Exposed (not private) so pins can assert what declines without
    /// driving a store write.
    func planCrossBlockEdit(
        range: NSRange, replacement: String
    ) -> CrossBlockCompound.Plan? {
        CrossBlockCompound.plan(
            replacing: range, with: replacement,
            index: index,
            surfaceText: { [weak self] range in self?.viewText(range) ?? "" })
    }

    /// **#109's shape (i) — the phone's face on the shared clamp brain**
    /// (13u2 UNIT C; the Mac's `EditorViewModel.planClampedInBlockEdit`
    /// twin). Exposed (not private) so pins can assert what it plans without
    /// driving a store write.
    func planClampedInBlockEdit(
        range: NSRange, replacement: String
    ) -> CrossBlockCompound.InBlockEdit? {
        CrossBlockCompound.clampedInBlockEdit(
            replacing: range, with: replacement, index: index,
            surfaceText: { [weak self] range in self?.viewText(range) ?? "" })
    }

    /// **The ordinary input path, deliberately — this road is NOT
    /// structural.** After the clamp the edit sits inside one block, so it
    /// takes the phone's own one input door (`MobileMarkdownActs.
    /// inputReplace`: pre-gate → select → UIKit's `insertText`/
    /// `deleteBackward`), which means the index bookkeeping, the autosave
    /// arming, every existing refusal and the SYSTEM's own text undo all
    /// work unchanged. Routing it through a structural compound would have
    /// registered an undo-stack entry for a plain deletion inside one
    /// paragraph — the Mac's reasoning, and the same on the phone.
    ///
    /// It runs on the next main-actor turn (the keystroke itself must be
    /// refused, because the storage must never half-apply a span this road
    /// did not take), behind the plan's COMPARE-AND-SET — a chained compound
    /// can land in that window, and the CAS also makes the re-entrant gate
    /// consult provably terminal.
    func runClampedInBlockEdit(_ edit: CrossBlockCompound.InBlockEdit) {
        guard let textView else { return }
        guard index.documentLength == edit.documentLength,
              viewText(edit.range) == edit.expectedText
        else {
            refuse(
                "The text changed while that gesture was landing — nothing was altered; "
                    + "try it again on the current text.")
            return
        }
        MobileMarkdownActs.inputReplace(
            textView, range: edit.range, with: edit.replacement)
    }

    /// A gesture the GATE refused so a structural compound could reproduce
    /// its intent (R18's whole-block delete today; the Mac's
    /// `scheduleCrossBlockCompound` is the shape). The handle is held for
    /// two reasons, both the Mac's: back-to-back gestures CHAIN instead of
    /// racing — or being refused by the one-flight latch, which is meant for
    /// a genuinely concurrent act, not for a queue of the user's own presses
    /// — and a test can await the act it just drove rather than spinning on
    /// a guess about when it landed.
    @ObservationIgnored private(set) var pendingGestureTask: Task<Void, Never>?

    private func scheduleGestureCompound(_ body: @escaping @MainActor () async -> Void) {
        let previous = pendingGestureTask
        let token = UUID()
        pendingGestureToken = token
        pendingGestureTask = Task { @MainActor [weak self] in
            if let previous { await previous.value }
            await body()
            // "Pending" means pending: the completed handle clears unless a
            // chained schedule already replaced it (the Mac's round-3 NIT).
            if let self, self.pendingGestureToken == token { self.pendingGestureTask = nil }
        }
    }

    @ObservationIgnored private var pendingGestureToken: UUID?

    /// The exact-changed-range report (NSTextStorage didProcessEditing,
    /// characters only). `editedRange` is the NEW characters' range; the
    /// old length is `editedRange.length - delta`. System paths that
    /// bypassed the gate (autocorrect, dictation, marked text) arrive here
    /// with no pending verdict and route by `fallbackVerdict`.
    func storageDidEdit(_ editedRange: NSRange, changeInLength delta: Int) {
        guard !suppressEditProcessing else {
            // E1 — recorded so nothing that reaches storage is invisible to
            // the experiment (a pure append; the `return` is unchanged).
            MobileEditTrace.suppressedReport(editedRange: editedRange, delta: delta)
            return
        }
        // THE BINDING (round 2, batch 1 — the crash fix's real half): the
        // gate's answer is consumed ONLY while it still describes the edit
        // that arrived. Anything else — a coalesced transaction wider than
        // the sub-edit the gate last saw, an arming whose edit never
        // landed, an index that moved underneath it — falls through to
        // `fallbackVerdict`, which recomputes against the pre-edit index
        // and cannot produce a negative length for a deletion (the trace's
        // §3a lemma). Rejecting an arming never refuses the EDIT; it only
        // declines the shortcut. `binds` = the geometry (`describes`) plus
        // the CONTENT check `.openTail` needs (VM-5 stability pass, MAJOR 2:
        // a stale tail-opening arming must never bind a gate-less character
        // that is not the newline it means).
        let armed = pendingEdit
        pendingEdit = nil
        let bound = armed.flatMap {
            $0.binds(
                editedRange: editedRange, delta: delta,
                documentLength: index.documentLength,
                landedText: { viewText($0) }) ? $0 : nil
        }
        // E1 — the settling experiment's REPORT half: the numbers that
        // decide whether the gate and the storage report are 1:1 inside one
        // coordinated edit (`MobileEditTrace`'s header carries the whole
        // why). `hadArming && !bound` is the binding's own refusal, which is
        // the closest thing this code already had to an alarm.
        MobileEditTrace.report(
            editedRange: editedRange, delta: delta,
            hadArming: armed != nil, bound: bound != nil)
        if armed != nil, bound == nil {
            // M13 (round-2 ladder round 1, MINOR 5): the paste's bulk-entry
            // intent was armed BESIDE this verdict, off the same gate call.
            // A discarded arming takes it along — otherwise the flag
            // survives an edit that never became the paste it described,
            // and the next crystallization mints `.bulk` instead of
            // `.typing`. A one-shot wrong segmentation kind, no data loss —
            // and a state that could not exist before the binding, so it
            // closes where it was opened.
            bulkPending = false
        }
        let verdict = bound?.verdict ?? fallbackVerdict(editedRange: editedRange, delta: delta)
        let exactCost = bound?.exactCost
        switch verdict {
        case .block(let i):
            // The mutators REFUSE rather than trap (BlockRangeIndex's
            // mutation band). A refusal means the bookkeeping and the
            // storage have already diverged, so nothing below may run
            // against it — not the re-stamp, not the autosave, and not the
            // audit/chrome tail after the switch: `desyncRecovery`'s
            // re-render from the store redoes every one of them over the
            // truth.
            guard index.applyBlockEdit(at: i, lengthDelta: delta) else {
                recoverFromUnroutableEdit()
                return
            }
            // THE iOS RE-STAMP (obligation 1): the inserted characters
            // arrived attribute-stripped; identity is re-derived from the
            // index, never inherited.
            restampProjection(over: editedRange)
            recordAutosave(
                entryIndex: i, editedRange: editedRange, delta: delta,
                exactCost: exactCost)
        case .tail:
            guard index.applyTailEdit(lengthDelta: delta) else {
                recoverFromUnroutableEdit()
                return
            }
            restampProjection(over: editedRange)
            syncTailText()
            crystallizeIfNeeded()
            armTailIdleMint()
        case .openTail:
            guard index.openTail() else {
                recoverFromUnroutableEdit()
                return
            }
            restampProjection(over: editedRange)
            crystallizer.setText("")
        case .closeTail:
            guard index.closeTail() else {
                recoverFromUnroutableEdit()
                return
            }
            crystallizer.setText("")
            crystallizer.cancelIdleClock()
        case .refuse:
            // An edit reached the storage without a routable verdict (a
            // UIKit path outside the policed ones). The store is truth:
            // drop local bookkeeping and re-render from the projection.
            recoverFromUnroutableEdit()
            return
        }
        // Batch 2 (M11): the markdown face follows the keystroke, scoped to
        // the LINES the edit touched — the Mac's exact hook (P1's letter,
        // `MarkdownScanCount`-pinned). Attribute-only, so it moves no byte;
        // the observer's `.editedCharacters` guard means these attribute
        // writes cannot re-enter here.
        if let storage {
            MarkdownFace.restyle(
                storage, range: editedRange, base: MobileEditorStyle.baseFont,
                palette: MobileEditorStyle.markdownPalette)
        }
        auditIdentityProjection()
        textView?.canaryCheckpointAfterMutation()
        // S2: badge/gutter/marker geometry follows every character edit
        // (the overlay-geometry law — every input axis; equality-gated
        // inside, so unchanged geometry writes nothing). EDIT-SCOPED
        // since parity B3 (FB2-1's fix): the pass touches the
        // near-viewport band ∪ the edited range, never the document —
        // the pre-B3 `.document` default here forced far-decorated-block
        // layout on EVERY keystroke and re-wrote `exclusionPaths` into a
        // geometry↔exclusion invalidation loop (551 ms keystrokes at
        // 100k, measured; P-8's law: invalidation ∝ viewport + edit).
        // Off-band chrome keeps its last resolved geometry and heals the
        // moment its block scrolls near (the `.nearViewport` doctrine,
        // extended to the edit road); `.document` passes remain the
        // delivery/flip/voice axes' — user-act cadence, never keystroke.
        textView?.refreshChrome(scope: .edit(editedRange))
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

    private func recordAutosave(
        entryIndex: Int, editedRange: NSRange, delta: Int, exactCost: Int?
    ) {
        let entry = index.entries[entryIndex]
        guard let variantID = entry.variantID else {
            EditorAssertionSeam.fire("editable entry without a variant")
            return
        }
        let text = viewText(index.range(ofEntryAt: entryIndex))
        ledger.recordEdit(variantID: variantID, text: text)
        // Block-scoped edit cost (AppSpec §10): old + new lengths of the
        // exact changed edit, UTF-16 — the Mac's shape, retiring the
        // Phase 8 whole-buffer diff for this surface. Policed edits carry
        // the gate's exact figure; system paths derive from the report
        // (which iOS may widen — approximate is acceptable there).
        let oldLength = editedRange.length - delta
        autosave.record(
            variantID: variantID, text: text,
            charDelta: exactCost ?? (oldLength + editedRange.length))
    }

    /// The recovery road taken from INSIDE `storageDidEdit`, where a
    /// mutation has already reached storage and only its ROUTING failed.
    ///
    /// The checkpoint is owed here (round-2 ladder round 1, NIT 6):
    /// TEXTKIT2_NOTES §4 practice 3 makes the canary an obligation after
    /// every processed storage edit, and these roads `return` before the
    /// method's own checkpoint. `desyncRecovery`'s re-render does check the
    /// canary in the end — but the obligation reads "after the edit", not
    /// "after the async heal lands", and a downgrade caused BY this edit is
    /// exactly what the canary exists to attribute. It reads only
    /// `textLayoutManager`, so it touches none of the bookkeeping the
    /// refusal just declared untrustworthy.
    private func recoverFromUnroutableEdit() {
        textView?.canaryCheckpointAfterMutation()
        desyncRecovery()
    }

    private func desyncRecovery() {
        MobileEditTrace.desyncRecovery() // E1 — the honest road, counted
        desyncRecoveryCount += 1
        EditorAssertionSeam.fire("mobile editor surface desynced from the block index")
        forceFullRender = true
        pendingEdit = nil
        bulkPending = false  // armed BESIDE it; it goes with it (NIT 4)
        Task { [weak self] in
            guard let self else { return }
            await autosave.flushNow()
            if let fresh = try? await session.database.read({ [postID] in
                try Queries.takesProjection($0, post: postID)
            }) {
                ingest(fresh)
            }
        }
    }

    // MARK: - Crystallization (AppSpec §7; the Mac's ported clock + rules)
    //
    // **18m U2: the band's BODIES live in the shared `TailCrystallizer`**
    // (`Shared/EditorBrain/TailCrystallizer.swift` — ONE copy for both
    // platforms of the idle clock, the mint flight, the leading-run
    // attachment and the reconcile-and-apply). What stays here: the forwards
    // every caller and pin reads (3C), and the host conformance at the end of
    // this file (its DECLARED arms: no structural-flight hold — this
    // platform's flight settles through the projection policy — and no
    // caret-context republish).

    /// Re-arms the idle-mint clock after tail activity.
    func armTailIdleMint() {
        crystallizer.armIdleMint(host: self)
    }

    /// Whether the open tail holds anything the ratified rules would mint
    /// (a whitespace-only tail never mints).
    var mintableTail: Bool {
        crystallizer.isMintable(host: self)
    }

    /// The idle-mint — internal so tests fire it deterministically. Typing
    /// granularity is paragraph in every mode (author ruling); the whole
    /// tail mints, trailing partial paragraph included, tail closes — with
    /// the `.idle` kind preserving a trailing typed newline run (k−1).
    func idleMintTail() {
        crystallizer.idleMintTail(host: self)
    }

    /// The tail edit's crystallization (the consume road's `.tail` arm) —
    /// and `finish()`'s attach-only pass.
    private func crystallizeIfNeeded() {
        crystallizer.crystallizeIfNeeded(host: self)
    }

    // MARK: - Storage primitives

    /// The one counted extraction door (O(the asked range)) — since 18m U2
    /// the shared storage door, through the phone's own storage accessor.
    func viewText(_ range: NSRange) -> String {
        EditorSurfaceStorage.text(of: storage, in: range)
    }

    private func syncTailText() {
        crystallizer.setText(openTailText)
    }

    /// The one mutating door for programmatic slot/tail replacement.
    private func programmaticReplace(
        _ range: NSRange, with newText: String, blockID: String?,
        caretToEndIfWasAtEnd: Bool = false
    ) {
        guard let storage else { return }
        // Recover-not-crash: an out-of-tiling range would raise an
        // NSRangeException Swift cannot catch — heal from the store.
        guard range.location >= 0, range.upperBound <= storage.length else {
            desyncRecovery()
            return
        }
        let caretWasAtEnd = (textView?.selectedRange.location ?? -1) >= storage.length
        suppressEditProcessing = true
        // 18m U2: the storage transaction is the shared door, with the
        // phone's base attributes and its restyle. Batch 2: the base reset
        // clears the replaced span's face, so the markdown face over those
        // lines is re-derived inside the same transaction (the Mac
        // `applySeamEdit`'s exact posture). Attributes only.
        EditorSurfaceStorage.replace(
            range, with: newText, blockID: blockID, in: storage,
            base: MobileEditorStyle.baseAttributes,
            restyle: { storage, replaced in
                MarkdownFace.restyle(
                    storage, range: replaced,
                    base: MobileEditorStyle.baseFont,
                    palette: MobileEditorStyle.markdownPalette)
            })
        suppressEditProcessing = false
        if caretToEndIfWasAtEnd, caretWasAtEnd, let textView {
            textView.selectedRange = NSRange(location: storage.length, length: 0)
        }
    }

    /// **The boundary-safe re-stamp (batch 2 fix — the walk3 crash's
    /// mechanism, traced):** re-derives the block-ID projection over every
    /// character `range` touches FROM THE INDEX — entry intersections gain
    /// their entry's ID; everything between and beyond (separators, the
    /// tail) sheds any.
    ///
    /// Exists because iOS's `didProcessEditing` report may WIDEN the edited
    /// range under attribute fixing (the batch-1 measured wrinkle) — and
    /// walk3 caught the widening CROSSING A BOUNDARY: inserting 2 chars at
    /// a block's line start reported `+9`, the whole edited paragraph
    /// INCLUDING its terminating newline, which on this surface is the
    /// SEPARATOR — so stamping the raw report gave the separator an owner
    /// (diagnostic evidence: entries len 6/len 8, runs `[7,+9]`). Deriving
    /// the stamp's EXTENT from the report was the bug; the index is the one
    /// authority (memo obligation 1), and with the extent taken from it a
    /// widened report can only ever RE-stamp what is already true.
    ///
    /// Cost: an integer walk over entries with an early break — O(entries)
    /// worst case, entry-count not byte-count, and only on iOS's re-stamp
    /// path (the Mac inherits attributes and never re-stamps). A prefix-sum
    /// bisect is the recorded upgrade if a corpus-scale note ever measures
    /// it; the audit's own DEBUG walk is already O(entries) per edit.
    private func restampProjection(over range: NSRange) {
        guard let storage else { return }
        let start = max(0, range.location)
        let end = min(range.upperBound, storage.length)
        guard start < end else { return }

        var location = 0
        var covered = start
        for entry in index.entries {
            let entryRange = NSRange(location: location, length: entry.length)
            location += entry.length + 1
            if entryRange.location >= end { break }
            let overlapStart = max(entryRange.location, start)
            let overlapEnd = min(entryRange.upperBound, end)
            guard overlapStart < overlapEnd else { continue }
            // The gap before this entry (a separator) sheds any ID.
            if overlapStart > covered {
                storage.removeAttribute(
                    EditorDocument.blockIDAttribute,
                    range: NSRange(location: covered, length: overlapStart - covered))
            }
            storage.addAttribute(
                EditorDocument.blockIDAttribute, value: entry.blockID,
                range: NSRange(location: overlapStart, length: overlapEnd - overlapStart))
            covered = overlapEnd
        }
        // Whatever remains (the tail region, trailing separators) is
        // owned by no block.
        if covered < end {
            storage.removeAttribute(
                EditorDocument.blockIDAttribute,
                range: NSRange(location: covered, length: end - covered))
        }
    }

    // MARK: - The DEBUG identity audit (obligation 1's oracle)

    /// Runs the shared walk and, on a disagreement, counts it and fires the
    /// honest road's debug voice.
    ///
    /// **The walk itself is `IdentityProjectionAudit`, in
    /// `Shared/EditorBrain/`** (13l L-a): it was written here, and the Mac —
    /// same `BlockRangeIndex`, same crash fix, the same corruption
    /// reproduced against it Mac-side — had no oracle for the one class its
    /// other two are blind to. What stays here is the counter and the seam,
    /// which is exactly the per-platform half (MobileSoul §3: brains
    /// shared, faces per platform). The verdict, the message and the
    /// counter's meaning are byte-unchanged by the move; the ONE difference
    /// is that the empty-entry separator hole M15 Q2 closed here is now
    /// closed for both platforms by construction.
    ///
    /// **18m U2: the consumer moved too** — `IdentityProjectionAudit.audit`
    /// runs the guard, the walk, the count-then-fire; what stays here is
    /// the storage accessor and the counter.
    func auditIdentityProjection() {
        #if DEBUG
        IdentityProjectionAudit.audit(index: index, storage: storage) {
            identityAuditFailures += 1
        }
        #endif
    }

    // MARK: - Messages

    /// The page-level locked-take refusal (parity C4a — the "unlock it on
    /// the Mac" redirect dissolved WITH the phone's own unlock door: the
    /// take's card in the takes sheet carries Lock/Unlock in its ⋯, so
    /// the copy names that road; the no-redirect principle's letter).
    /// Pinned static — shared by the page gate and the structural doors,
    /// so the sentence can never fork between them.
    static let lockedTakeRefusal =
        "This take is locked — branch it, or unlock it from its card in the takes sheet (⑂)."

    /// **The phone's fan roads** — the one platform-shaped sentence the
    /// hoisted `CrossBlockRefusal` takes as a parameter (13u1 UNIT 2, U-5),
    /// because a shared home must not name a door one platform does not have
    /// (MobileSoul §4.4, read from the other side). The Mac's sentence names
    /// two chords; the phone names the menu row it actually has.
    static let fanFoldRoads =
        "Merge the blocks deliberately instead (\u{22EF} \u{2192} "
        + "\(MobileBlockMenuController.mergeTitle)), which brings every take along."

    private func refuse(_ message: String) {
        statusMessage = message
    }

    /// **18m U3 (ruling G):** the gate's four refusals are ONE shared brain
    /// now (`OpsRefusalCopy.gateMessage`, beside the refusal table); this
    /// forward supplies the phone's two platform pieces — its locked-take
    /// line (the takes sheet's ⑂ road) and its fan roads (the ⋯ menu row).
    /// (The cross-block arm's history — re-narrowed at 13u1 UNIT 2, its
    /// boundary residual retired at 13u2 UNIT C — moved with it.)
    func message(for refusal: BlockRangeIndex.Refusal) -> String {
        OpsRefusalCopy.gateMessage(
            for: refusal, lockedTake: Self.lockedTakeRefusal, fanRoads: Self.fanFoldRoads)
    }
}

// MARK: - 18m U2: the crystallizer's host (the band's doors — nothing more)

/// **The phone's side of `TailCrystallizerHost`** — each member is the one
/// line the band needs (the protocol names which band function asks for it),
/// written in THIS file so the doors reach this model's `private` state
/// without widening a single setter. `index`, `autosave`, `postID`,
/// `surfaceKnownText(variantID:)` (the takes overlay's ledger read, the same
/// read), `auditIdentityProjection()` and `applyPendingIfClean()` are the
/// model's existing members.
extension MobileEditorViewModel: TailCrystallizerHost {
    func transferTailPrefixToLastEntry(_ units: Int) -> Bool {
        index.transferTailPrefixToLastEntry(units)
    }

    func crystallizeIndex(
        minted: [(blockID: String, variantID: String, length: Int)],
        remainingTailLength: Int?
    ) -> Bool {
        index.crystallize(minted: minted, remainingTailLength: remainingTailLength)
    }

    /// The same road the storage-edit consumers take when the index's other
    /// four mutators refuse (VM-5, MINOR 4).
    func recoverFromRefusedIndexMutation() {
        desyncRecovery()
    }

    func recordSurfaceText(variantID: String, text: String) {
        ledger.recordEdit(variantID: variantID, text: text)
    }

    var pendingBulkEntry: Bool { bulkPending }

    func clearBulkPending() {
        bulkPending = false
    }

    func disarmPendingEdit() {
        pendingEdit = nil
    }

    func requestFullRender() {
        forceFullRender = true
    }

    func noteOwnWritesSettled() {
        storeWriteGeneration &+= 1
    }

    var mintRunner: OperationsRunner { session.runner }

    var segmentationMode: Segmentation { header?.effectiveSegmentation ?? .paragraph }

    /// ACCESSOR: the attached storage (tests attach a bare one headless).
    var surfaceStorage: NSMutableAttributedString? { storage }

    /// ACCESSOR: UIKit's marked-text range (multi-stage input is COMMON here).
    var surfaceHasMarkedText: Bool { textView?.markedTextRange != nil }

    /// ACCESSOR: the phone's error voice. **18m U3 (ruling V):** it speaks
    /// the shared refusal table — a raw error dump is not a face — and keeps
    /// the error's description only where the table has no words.
    func reportOperationError(_ error: Error) {
        statusMessage = OpsRefusalCopy.words(for: error, roads: .phone) ?? String(describing: error)
    }

    func replaceTailRegion(_ region: NSRange, with normalized: String) {
        programmaticReplace(region, with: normalized, blockID: nil, caretToEndIfWasAtEnd: true)
    }

    func clearTextUndo() {
        textView?.undoManager?.removeAllActions()
    }

    /// DECLARED — `false`: this platform's structural doors never rewrite the
    /// surface themselves; they settle through `ingest` → the projection
    /// policy, whose busy arm defers while a mint is in flight, so the Mac's
    /// mid-flight duplicate-entry hazard cannot arise here (18m U2 probe P-a:
    /// 14 interleavings, every one convergent). `TailCrystallizerHost`'s doc
    /// holds both platforms' reasons side by side.
    var holdsTailForStructuralFlight: Bool { false }

    /// DECLARED — nothing: this model keeps no caret projection to republish
    /// (its chrome reads on demand, and a fresh mint carries none).
    func didApplyMint() {}
}

// MARK: - The gate delegate (batch 2)

/// The UITextViewDelegate the VM installs at attach — the ONE gate every
/// host shares (the SwiftUI face carries no gate of its own since batch 2).
@MainActor
final class MobileEditorGateDelegate: NSObject, UITextViewDelegate {
    /// Internal (not private) since S2 batch 2: the edit-menu seam file
    /// (`MobileEditMenuSeam.swift`) extends this delegate with the ONE
    /// deprecated-annotated menu method and needs the model to route.
    private(set) weak var model: MobileEditorViewModel?

    init(model: MobileEditorViewModel) {
        self.model = model
    }

    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        guard let model else { return true }
        return model.shouldChangeText(
            in: range,
            replacement: text,
            isPaste: (textView as? MobileEditorTextView)?.isPasting == true)
    }
}

// MARK: - The storage delegate bridge

/// NSTextStorageDelegate is a nonisolated protocol; the report hops onto
/// the main actor exactly as the Mac's `EditorSurfaceDelegate` does.
@MainActor
final class MobileStorageObserver: NSObject, NSTextStorageDelegate {
    private weak var model: MobileEditorViewModel?

    init(model: MobileEditorViewModel) {
        self.model = model
    }

    nonisolated func textStorage(
        _ textStorage: NSTextStorage,
        didProcessEditing editedMask: NSTextStorage.EditActions,
        range editedRange: NSRange,
        changeInLength delta: Int
    ) {
        guard editedMask.contains(.editedCharacters) else { return }
        MainActor.assumeIsolated {
            model?.storageDidEdit(editedRange, changeInLength: delta)
        }
    }
}
