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
    /// Fan badges for on-screen fanned blocks (document coordinates).
    private(set) var badges: [BlockBadge] = []
    /// The block whose fan panel is open (nil = closed).
    var fanPanel: FanPanelState?
    /// Commit history for the caret variant (nil = panel closed).
    var commitList: [CommitListItem]?
    /// A restore that needs the pre-split warning confirmed first.
    var pendingRestore: CommitListItem?

    struct BlockBadge: Equatable, Identifiable {
        let blockID: String
        let variantCount: Int
        let frame: CGRect
        var id: String { blockID }
    }

    /// The AppKit badge overlay renders through this (overlay views, never
    /// rendering attributes — memo obligation).
    @ObservationIgnored var badgeSink: (([BlockBadge]) -> Void)?

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
    @ObservationIgnored private var bulkPending = false
    @ObservationIgnored private var pendingProjection: [Queries.RenderedBlock]?
    @ObservationIgnored private var forceFullRender = false
    @ObservationIgnored private var loaded = false

    var hasOpenTail: Bool { index.tailLength != nil }

    // MARK: - Lifecycle

    func attach(textView: EditorTextView, scrollView: NSScrollView) {
        self.textView = textView
        self.scrollView = scrollView
        canary.onFire = { [weak self] message in self?.canaryMessage = message }
        canary.arm(for: textView)
        textView.onCommitShortcut = { [weak self] in self?.commitCaretVariant() }
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
    /// anchor), then let go. The open tail crystallizes on teardown so
    /// nothing typed is ever lost to a post switch or window close
    /// (PROVISIONAL timing — see phase plan closeout).
    func teardown() {
        if let anchor = topVisibleOffset() {
            session.editorRouter.scrollAnchors[postID] = anchor
        }
        if session.editorRouter.active === self {
            session.editorRouter.active = nil
        }
        canary.disarm()
        let vmTask = finalizeWork()
        if vmTask != nil { /* runs detached from the view's lifetime */ }
    }

    /// Flushes the buffer and crystallizes a non-blank open tail. Returns
    /// the task so quit-time callers can await it.
    @discardableResult
    func finalizeWork() -> Task<Void, Never>? {
        let tail = hasOpenTail ? tailText : ""
        let needsMint = !tail.allSatisfy(\.isWhitespace) && !mintInFlight
        guard autosave.isDirty || needsMint || mintInFlight else { return nil }
        let mode = header?.effectiveSegmentation ?? .paragraph
        let post = postID
        return Task { [session] in
            await autosave.flushNow()
            if needsMint, let plan = CrystallizationPlanner.plan(
                mode == .oneBlock ? .oneBlock : .bulk(mode), tail: tail) {
                _ = try? await session.runner.run { ops in
                    for text in plan.mints {
                        _ = try ops.newBlock(in: post, text: text, at: .end)
                    }
                }
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
        textView?.isEditable = value.map { !$0.locked } ?? false
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
        guard let textView else {
            pendingProjection = new
            return
        }
        if !loaded {
            // First render: there is no local tail yet — the pre-load index
            // is a placeholder, never a tail to preserve.
            renderFull(new, preserveTail: false)
            loaded = true
            return
        }
        // The buffer is authoritative while dirty; defer until clean.
        if autosave.isDirty || mintInFlight {
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
            refreshBadges()
            return
        }
        if new.map(\.blockID) == index.entries.map(\.blockID) {
            applyDifferential(new)
        } else {
            renderFull(new, preserveTail: true)
        }
        _ = textView // silence unused warning paths
    }

    /// True when the projection and the live surface agree on every slot:
    /// same blocks, same rendered variants, same texts, same editability.
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
            guard text.utf16.count == entry.length,
                  text == viewText(index.range(ofEntryAt: i))
            else { return false }
        }
        return true
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
        guard !autosave.isDirty, !mintInFlight, let pending = pendingProjection else { return }
        pendingProjection = nil
        applyProjection(pending)
    }

    // MARK: - Edit routing (the delegate entry points)

    func shouldChangeText(in range: NSRange, replacement: String?) -> Bool {
        guard !suppressEditProcessing else { return true }
        if header?.locked == true {
            refuseFeedback("This post is sealed — unlock it to edit.")
            return false
        }
        guard let replacement else { return true } // attribute-only
        if textView?.isPasting == true { bulkPending = true }
        let verdict = index.verdict(
            replacing: range,
            replacementIsSingleNewline: replacement == "\n",
            segmentation: header?.effectiveSegmentation ?? .paragraph)
        switch verdict {
        case .refuse(let refusal):
            pendingVerdict = nil
            refuseFeedback(message(for: refusal))
            return false
        default:
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
        case .openTail:
            index.openTail()
            setBlockAttribute(nil, over: editedRange)
            tailText = ""
        case .closeTail:
            index.closeTail()
            tailText = ""
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
        let oldLength = editedRange.length - delta
        autosave.record(
            variantID: variantID, text: text,
            charDelta: oldLength + editedRange.length)
    }

    private func desyncRecovery() {
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

    private func crystallizeIfNeeded() {
        guard !mintInFlight, hasOpenTail else { bulkPending = false; return }
        let mode = header?.effectiveSegmentation ?? .paragraph
        let kind: CrystallizationPlanner.Kind =
            bulkPending ? .bulk(mode) : (mode == .oneBlock ? .oneBlock : .typing)
        bulkPending = false
        guard let plan = CrystallizationPlanner.plan(kind, tail: tailText) else { return }
        mintInFlight = true
        let post = postID
        Task { [weak self, session] in
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
                self?.finishMint(minted, kind: kind)
            } catch {
                self?.mintInFlight = false
                self?.showOperationError(error)
                self?.applyPendingIfClean()
            }
        }
    }

    private func finishMint(_ minted: [CrystallizationReconciler.MintedBlock], kind: CrystallizationPlanner.Kind) {
        mintInFlight = false
        let outcome = CrystallizationReconciler.reconcile(
            minted: minted, currentTail: tailText, kind: kind)

        // Store follow-ups: corrections and deletions are ordinary
        // operations; the FIFO runner keeps them ordered after the mints.
        if !outcome.corrections.isEmpty || !outcome.deletions.isEmpty {
            let corrections = outcome.corrections
            let deletions = outcome.deletions
            Task { [session] in
                do {
                    try await session.runner.run { ops in
                        for correction in corrections {
                            try ops.autosave(
                                correction.variantID, text: correction.text,
                                charDelta: correction.text.utf16.count)
                        }
                        for blockID in deletions {
                            try ops.deleteBlock(blockID)
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
        // New paragraphs may have completed during the flight.
        crystallizeIfNeeded()
        applyPendingIfClean()
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
        } catch {
            statusMessage = "Could not load history: \(error)"
        }
    }

    /// Restore honors the documented pre-split warning (AppSpec §9,
    /// KnownIssues entry): a commit older than the newest divide/extract on
    /// this block resurrects pre-split text — confirm first.
    func restore(_ item: CommitListItem, confirmed: Bool = false) {
        if item.predatesSplit && !confirmed {
            pendingRestore = item
            return
        }
        pendingRestore = nil
        guard let variantID = caretVariantID else { return }
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

    func openFan(blockID: String) {
        Task {
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
        let caret = textView.selectedRange().location
        var location = 0
        caretBlockID = nil
        caretVariantID = nil
        for entry in index.entries {
            if caret >= location, caret <= location + entry.length {
                caretBlockID = entry.blockID
                caretVariantID = entry.variantID
                return
            }
            location += entry.length + 1
        }
    }

    /// Badges for fanned blocks currently laid out near the viewport.
    /// Cost ∝ fanned blocks (fans are opt-in and rare) — no ensureLayout,
    /// unlaid-out blocks simply have no badge until scrolled to (P1).
    func refreshBadges() {
        guard let textView, let scrollView,
              let layoutManager = textView.textLayoutManager,
              let contentManager = layoutManager.textContentManager
        else {
            badges = []
            return
        }
        let visible = scrollView.contentView.bounds
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
            if let frame, frame.intersects(visible) {
                result.append(BlockBadge(
                    blockID: slot.blockID,
                    variantCount: slot.activeVariantCount,
                    frame: frame))
            }
        }
        if result != badges {
            badges = result
            badgeSink?(result)
        }
    }

    // MARK: - Surface plumbing

    private func viewText(_ range: NSRange) -> String {
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
        let caretWasAtEnd = textView.selectedRange().location >= storage.length
        suppressEditProcessing = true
        storage.beginEditing()
        storage.replaceCharacters(in: range, with: newText)
        var attributes: [NSAttributedString.Key: Any] = [.font: EditorDocument.baseFont]
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
            "Edits can't cross block boundaries yet — structural gestures arrive later."
        case .readOnlySlot:
            "This block hasn't fully synced; it is read-only for now."
        case .lockedVariant:
            "This take is locked — branch it or unlock it to edit."
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
