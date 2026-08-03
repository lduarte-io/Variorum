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
        self.autosave = AutosaveCoordinator(runner: session.runner, debounce: debounce, sleep: sleep)
        autosave.onError = { [weak self] error in
            self?.statusMessage = String(describing: error)
        }
        autosave.onSettled = { [weak self] in
            self?.applyPendingIfClean()
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

    /// Runs for the editor's lifetime: header + slots, live.
    func start() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.observeHeader() }
            group.addTask { await self.observeSlots() }
        }
    }

    /// One authoritative load (first paint + deterministic tests).
    func loadOnce() async {
        do {
            let value = try await session.database.read { [postID] db in
                (slots: try Queries.renderPost(db, containerID: postID),
                 header: try Queries.containerHeader(db, containerID: postID))
            }
            adoptHeader(value.header)
            applyProjection(value.slots)
        } catch {
            statusMessage = String(describing: error)
        }
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

    private func observeSlots() async {
        do {
            for try await value in session.database.observePost(postID) {
                applyProjection(value)
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
    func applyProjection(_ new: [Queries.RenderedBlock]) {
        guard storage != nil else {
            pendingProjection = new
            return
        }
        let decision = EditorProjectionPolicy.decide(
            loaded: loaded,
            busy: autosave.isDirty || mintInFlight,
            forceFull: forceFullRender,
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
    }

    /// A deferred delivery settles by a FRESH read — the deferred value was
    /// fetched before the flush that just landed; adopting it as-is would
    /// transiently revert the edited block (the Mac's exact posture).
    func applyPendingIfClean() {
        guard !autosave.isDirty, !mintInFlight, pendingProjection != nil else { return }
        pendingProjection = nil
        Task { [weak self] in
            guard let self else { return }
            guard let fresh = try? await session.database.read({ [postID] in
                try Queries.renderPost($0, containerID: postID)
            }) else { return }
            guard !autosave.isDirty, !mintInFlight else {
                pendingProjection = fresh
                return
            }
            applyProjection(fresh)
        }
    }

    // MARK: - Edit routing (the delegate entry points)

    /// The gate (UITextViewDelegate shouldChangeTextIn). `isPaste` rides in
    /// from the view's flag so the tail's bulk-entry semantics arm exactly
    /// when a paste lands there.
    func shouldChangeText(in range: NSRange, replacement: String?, isPaste: Bool = false) -> Bool {
        guard !suppressEditProcessing else { return true }
        if header?.locked == true {
            refuse("This note is locked — unlock it on the Mac to edit.")
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
                try Queries.renderPost($0, containerID: postID)
            }) {
                applyProjection(fresh)
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
            for i in index.entries.indices {
                let entry = index.entries[i]
                let range = index.range(ofEntryAt: i)
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
    private weak var model: MobileEditorViewModel?

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
