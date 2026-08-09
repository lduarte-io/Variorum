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

    // MARK: - Observable UI state

    /// Refusals + operation errors, one voice (functional; styling is the
    /// look track's).
    private(set) var statusMessage: String?
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
    @ObservationIgnored private(set) var tailText = ""
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
    @ObservationIgnored private var pendingVerdict: BlockRangeIndex.Verdict?
    /// The policed edit's EXACT cost (old + new UTF-16 lengths, captured at
    /// the gate). iOS's `didProcessEditing` report can WIDEN the coalesced
    /// `editedRange` under attribute fixing (measured: a 5→6 replacement
    /// reported length 7), so a policed edit's churn cost is taken from the
    /// gate's own range + replacement; gate-less system paths fall back to
    /// the report-derived cost (approximate is fine there — churn is
    /// approximate by design, SyncSpec §6).
    @ObservationIgnored private var pendingEditCost: Int?
    @ObservationIgnored private var suppressEditProcessing = false
    @ObservationIgnored private(set) var mintInFlight = false
    @ObservationIgnored private var mintTask: Task<Void, Never>?
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

    // Idle-mint (the Mac's ratified clock, ported): a short quiet gap
    // crystallizes the open tail — crash loss bounded to seconds; teardown
    // stays the backstop.
    @ObservationIgnored var tailIdleDebounce: Duration = .seconds(2)
    @ObservationIgnored var tailIdleSleep: @Sendable (Duration) async throws -> Void =
        { try await Task.sleep(for: $0) }
    @ObservationIgnored private var tailIdleTask: Task<Void, Never>?

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
        self.takesBrowser = MobileTakesBrowserController(runner: session.runner)
        self.comments = MobileCommentsController(session: session)
        self.structural = MobileStructuralController(session: session)
        self.blockMenu = MobileBlockMenuController(session: session)
        takes.model = self
        takesBrowser.model = self
        comments.model = self
        structural.model = self
        blockMenu.model = self
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

    /// The screen's teardown (onDisappear): the S1 backstop lands pending
    /// work, then this surface stops listening to the SHARED coordinator
    /// (which outlives any one surface — the Mac's exact posture).
    func teardown() async {
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
        if !takesBrowser.isOpen {
            textView?.isEditable = true
        }
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
        // comments sheet follows the same discipline.
        takesBrowser.projectionDidChange()
        comments.projectionDidChange()
    }

    /// Teardown backstop: pending tail text mints (the idle plan — typed
    /// gaps survive per the k−1 rule), then everything pending lands.
    func finish() async {
        tailIdleTask?.cancel()
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

    /// Bounded wait for an in-flight crystallization mint.
    func awaitMintSettle() async {
        while mintInFlight {
            if let mint = mintTask { await mint.value } else { await Task.yield() }
        }
    }

    private func observeHeader() async {
        do {
            for try await value in session.database.observeContainerHeader(postID) {
                adoptHeader(value)
            }
        } catch is CancellationError {
        } catch {
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

    func adoptHeader(_ value: Queries.ContainerHeader?) {
        header = value
        isSealed = value?.locked ?? false
        displayTitle = value.map {
            DisplayTitle.note(title: $0.title, entryDate: $0.entryDate)
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
        index = newIndex
        slots = new
        ledger.adopt(new)
        tailText = tail ?? ""
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
    /// shape). Cost ∝ changed blocks, never the post.
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
        ledger.adopt(new)
        if edited {
            // Undo entries recorded against the old surface would replay at
            // stale offsets; drop them.
            textView?.undoManager?.removeAllActions()
        }
        auditIdentityProjection()
        textView?.refreshChrome()
    }

    /// A deferred delivery settles by a FRESH read — the deferred value was
    /// fetched before the flush that just landed; adopting it as-is would
    /// transiently revert the edited block (the Mac's exact posture).
    func applyPendingIfClean() {
        guard !autosave.isDirty, !mintInFlight, pendingProjection != nil else { return }
        pendingProjection = nil
        let generation = storeWriteGeneration
        Task { [weak self] in
            guard let self else { return }
            guard let fresh = try? await session.database.read({ [postID] in
                try Queries.takesProjection($0, post: postID)
            }) else { return }
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
    func report(_ message: String?) {
        statusMessage = message
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
        await autosave.flushNow()
        guard !autosave.isDirty else {
            report("Unsaved changes couldn't be written — resolve that first, then retry.")
            return
        }
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
        slots[i] = slot
        var entries = index.entries
        entries[i] = BlockRangeIndex.Entry(
            blockID: slot.blockID,
            variantID: slot.variantID,
            length: (newText as NSString).length,
            editable: !slot.isGap && !slot.variantLocked)
        index = BlockRangeIndex(entries: entries, tailLength: index.tailLength)
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
        guard !suppressEditProcessing else { return true }
        // The liveness belt (S3 ladder BLOCKER): a stood-down surface is
        // read-tier — resigned and uneditable already; this refusal is the
        // third guard for whatever slips past both (PROVISIONAL wording).
        if !isLive {
            refuse("This note is live in your other tab.")
            return false
        }
        if header?.locked == true {
            refuse("This note is locked — unlock it to edit.")
            return false
        }
        guard let replacement else { return true } // attribute-only
        let verdict = index.verdict(
            replacing: range,
            replacementIsSingleNewline: replacement == "\n",
            segmentation: header?.effectiveSegmentation ?? .paragraph)
        switch verdict {
        case .refuse(.indexDesync):
            pendingVerdict = nil
            pendingEditCost = nil
            desyncRecovery()
            return false
        case .refuse(let refusal):
            pendingVerdict = nil
            pendingEditCost = nil
            refuse(message(for: refusal))
            return false
        default:
            if case .tail = verdict, isPaste {
                bulkPending = true
            }
            pendingVerdict = verdict
            pendingEditCost = range.length + (replacement as NSString).length
            return true
        }
    }

    /// The exact-changed-range report (NSTextStorage didProcessEditing,
    /// characters only). `editedRange` is the NEW characters' range; the
    /// old length is `editedRange.length - delta`. System paths that
    /// bypassed the gate (autocorrect, dictation, marked text) arrive here
    /// with no pending verdict and route by `fallbackVerdict`.
    func storageDidEdit(_ editedRange: NSRange, changeInLength delta: Int) {
        guard !suppressEditProcessing else { return }
        let verdict = pendingVerdict ?? fallbackVerdict(editedRange: editedRange, delta: delta)
        pendingVerdict = nil
        let exactCost = pendingEditCost
        pendingEditCost = nil
        switch verdict {
        case .block(let i):
            index.applyBlockEdit(at: i, lengthDelta: delta)
            // THE iOS RE-STAMP (obligation 1): the inserted characters
            // arrived attribute-stripped; identity is re-derived from the
            // index, never inherited.
            restampProjection(over: editedRange)
            recordAutosave(
                entryIndex: i, editedRange: editedRange, delta: delta,
                exactCost: exactCost)
        case .tail:
            index.applyTailEdit(lengthDelta: delta)
            restampProjection(over: editedRange)
            syncTailText()
            crystallizeIfNeeded()
            armTailIdleMint()
        case .openTail:
            index.openTail()
            restampProjection(over: editedRange)
            tailText = ""
        case .closeTail:
            index.closeTail()
            tailText = ""
            tailIdleTask?.cancel()
        case .refuse:
            // An edit reached the storage without a routable verdict (a
            // UIKit path outside the policed ones). The store is truth:
            // drop local bookkeeping and re-render from the projection.
            desyncRecovery()
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
            assertionFailure("editable entry without a variant")
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

    private func desyncRecovery() {
        desyncRecoveryCount += 1
        assertionFailure("mobile editor surface desynced from the block index")
        forceFullRender = true
        pendingVerdict = nil
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

    /// Re-arms the idle-mint clock after tail activity.
    func armTailIdleMint() {
        tailIdleTask?.cancel()
        guard mintableTail else { return }
        tailIdleTask = Task { [weak self, tailIdleSleep, tailIdleDebounce] in
            guard (try? await tailIdleSleep(tailIdleDebounce)) != nil else { return }
            guard !Task.isCancelled else { return }
            self?.idleMintTail()
        }
    }

    /// Whether the open tail holds anything the ratified rules would mint
    /// (a whitespace-only tail never mints).
    var mintableTail: Bool {
        hasOpenTail && !tailText.allSatisfy(\.isWhitespace)
    }

    /// The idle-mint — internal so tests fire it deterministically. Typing
    /// granularity is paragraph in every mode (author ruling); the whole
    /// tail mints, trailing partial paragraph included, tail closes — with
    /// the `.idle` kind preserving a trailing typed newline run (k−1).
    func idleMintTail() {
        guard mintableTail else { return }
        // Marked text is an in-progress input-method composition, not yet
        // the author's text — minting under it would rewrite the region
        // mid-composition. Skip this tick and re-arm (on iOS multi-stage
        // input is COMMON, so this guard earns its keep).
        if textView?.markedTextRange != nil {
            armTailIdleMint()
            return
        }
        let mode = header?.effectiveSegmentation ?? .paragraph
        crystallizeIfNeeded(forcedKind: mode == .oneBlock ? .oneBlock : .idle(.paragraph))
    }

    /// The leading-run attachment (the 2026-07-12 rule; the Mac's exact
    /// port): a tail that STARTS with newlines sits after a preceding
    /// block — those newlines are that block's trailing CONTENT (the k−1
    /// rule; the tail separator is the +1). Surface bytes never change:
    /// the block's range grows over the run, and the store follows through
    /// an ordinary autosave read from the ledger (works even with the view
    /// gone at teardown).
    private func attachLeadingTailRunIfNeeded() {
        guard !mintInFlight, hasOpenTail else { return }
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
        // While a mint is in flight, keep `bulkPending` ARMED — the
        // finish re-runs this and a paste-during-mint keeps bulk
        // semantics (the Mac's MAJOR-3 posture).
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
        bulkPending = false
        mintInFlight = true
        let post = postID
        // Strong self: the reconciliation must run even if the view goes
        // away mid-flight — the task completes in milliseconds.
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
                self.statusMessage = String(describing: error)
                self.applyPendingIfClean()
            }
        }
    }

    private func finishMint(
        _ minted: [CrystallizationReconciler.MintedBlock],
        kind: CrystallizationPlanner.Kind
    ) {
        mintInFlight = false
        storeWriteGeneration &+= 1 // our mint's writes settled (MAJOR 3's fence)
        let outcome = CrystallizationReconciler.reconcile(
            minted: minted, currentTail: tailText, kind: kind)

        // Corrections ride the autosave coordinator (isDirty covers the
        // window; refusals keep-pending). Compensating deletions are
        // internal bookkeeping, not an author gesture — undo-stack-free
        // Operations, so no inverse is ever offered for something she
        // never did (the Mac's exact posture).
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
                    self.statusMessage = String(describing: error)
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
        auditIdentityProjection()
        // New paragraphs may have completed during the flight — and a
        // paste-during-mint's still-armed bulk flag is honored here.
        crystallizeIfNeeded()
        armTailIdleMint()
        applyPendingIfClean()
    }

    // MARK: - Storage primitives

    /// The one counted extraction door (O(the asked range)).
    func viewText(_ range: NSRange) -> String {
        guard let storage else { return "" }
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
        storage.beginEditing()
        storage.replaceCharacters(in: range, with: newText)
        var attributes = MobileEditorStyle.baseAttributes
        if let blockID { attributes[EditorDocument.blockIDAttribute] = blockID }
        storage.setAttributes(
            attributes,
            range: NSRange(location: range.location, length: (newText as NSString).length))
        // Batch 2: the `setAttributes` above reset the replaced span to
        // base, so the markdown face over those lines is re-derived (the
        // Mac `applySeamEdit`'s exact posture). Attributes only.
        MarkdownFace.restyle(
            storage,
            range: NSRange(location: range.location, length: (newText as NSString).length),
            base: MobileEditorStyle.baseFont,
            palette: MobileEditorStyle.markdownPalette)
        storage.endEditing()
        suppressEditProcessing = false
        if caretToEndIfWasAtEnd, caretWasAtEnd, let textView {
            textView.selectedRange = NSRange(location: storage.length, length: 0)
        }
    }

    private func setBlockAttribute(_ blockID: String?, over range: NSRange) {
        guard range.length > 0, let storage,
              range.upperBound <= storage.length else { return }
        if let blockID {
            storage.addAttribute(EditorDocument.blockIDAttribute, value: blockID, range: range)
        } else {
            storage.removeAttribute(EditorDocument.blockIDAttribute, range: range)
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

    /// Walks the tiling after reconciliation and asserts the attribute
    /// PROJECTION agrees with the index AUTHORITY: every entry's range
    /// uniformly carries its block ID (no MISSING runs — the measured iOS
    /// failure mode is pure absence, never bleed), separators and the tail
    /// carry none, and the index tiles the storage exactly. O(blocks) per
    /// edit, DEBUG-only.
    func auditIdentityProjection() {
        #if DEBUG
        guard let storage else { return }
        var clean = index.documentLength == storage.length
        if clean {
            // Running-location walk (B3): `range(ofEntryAt: i)` is O(i),
            // so the per-entry call made this per-keystroke audit
            // O(entries²) — ~1.9M additions per keystroke at 1,370
            // blocks, real DEBUG milliseconds on the keystroke road.
            // Same ranges, same checks, one walk.
            var runningLocation = 0
            for i in index.entries.indices {
                let entry = index.entries[i]
                let range = NSRange(location: runningLocation, length: entry.length)
                runningLocation += entry.length + 1
                guard range.length > 0 else { continue }
                storage.enumerateAttribute(
                    EditorDocument.blockIDAttribute, in: range
                ) { value, _, stop in
                    if (value as? String) != entry.blockID {
                        clean = false
                        stop.pointee = true
                    }
                }
                if !clean { break }
                // The separator after this entry (if any) is owned by no
                // block.
                if i < index.entries.count - 1 || index.tailLength != nil {
                    let separatorAt = range.upperBound
                    if separatorAt < storage.length,
                       EditorDocument.blockID(at: separatorAt, in: storage) != nil {
                        clean = false
                    }
                }
                if !clean { break }
            }
        }
        if clean, let tail = index.tailRange, tail.length > 0 {
            storage.enumerateAttribute(
                EditorDocument.blockIDAttribute, in: tail
            ) { value, _, stop in
                if value != nil {
                    clean = false
                    stop.pointee = true
                }
            }
        }
        if !clean {
            identityAuditFailures += 1
            assertionFailure(
                "identity projection audit failed: block-ID attributes disagree with BlockRangeIndex")
        }
        #endif
    }

    // MARK: - Messages

    private func refuse(_ message: String) {
        statusMessage = message
    }

    func message(for refusal: BlockRangeIndex.Refusal) -> String {
        switch refusal {
        case .crossesBlockBoundary:
            // PROVISIONAL batch-1 copy: the Mac's cross-block compounds
            // (merge-then-edit, visible-take) and the M10 structural doors
            // are LATER batches — until they land the refusal speaks
            // plainly rather than promising machinery that isn't there.
            "This edit spans more than one block — edit inside one block for now."
        case .readOnlySlot:
            "This block hasn't fully synced; it is read-only for now."
        case .lockedVariant:
            "This take is locked — branch it or unlock it on the Mac to edit."
        case .indexDesync:
            "The editor lost track of block boundaries — reloading from the store."
        }
    }
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
