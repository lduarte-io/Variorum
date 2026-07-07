//
//  EntryEditorViewModel.swift
//  VariorumMobile
//
//  Phase 8, Step 3 — the capture editor's model. The narrow surface IS the
//  product design (pillar 8): create an entry, edit EXISTING blocks' active
//  text, nothing structural. Rules live in Operations; this model holds
//  projections and sends operations.
//
//  Shape:
//  - one focused block is a live editor at a time (P3 at phone scale);
//    other blocks render read-cheap and focus on tap;
//  - the first keystroke on an empty entry mints THE block (`newBlock`) —
//    the same one-block journal semantics the Mac ships;
//  - edits flow through the SHARED AutosaveCoordinator (debounced,
//    churn-fed, keep-pending on refusal — the Phase 7 posture comes along
//    by sharing the code); the buffer is authoritative while dirty and
//    projections defer to a clean re-fetch (the Phase 7 review posture);
//  - blocks with fans render the chosen/default take's text and edit
//    exactly that variant — the fan itself is invisible here;
//  - a sealed post renders read-only with the refusal surfaced.
//

import Foundation
import GRDB // AsyncValueObservation iteration (member import visibility)
import Observation
import VariorumCore

@Observable
@MainActor
final class EntryEditorViewModel {
    private let session: AppSession
    let postID: String
    let autosave: AutosaveCoordinator

    private(set) var slots: [Queries.RenderedBlock] = []
    private(set) var header: Queries.ContainerHeader?
    private(set) var lastError: String?

    /// The one live editor: which variant the draft belongs to.
    private(set) var focusedVariantID: String?
    private(set) var draftText: String = ""
    /// The draft as last handed to the autosave pipeline (edit-cost base).
    private var flushedDraft: String = ""
    private(set) var mintInFlight = false
    /// A projection that arrived while the buffer was authoritative — its
    /// arrival is remembered; the value is re-fetched fresh at settle
    /// (never applied stale).
    private var projectionDeferred = false

    var isSealed: Bool { header?.locked ?? false }
    var isJournal: Bool { header?.entryDate != nil }
    var entryDate: String? { header?.entryDate }

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
            self?.lastError = String(describing: error)
        }
        autosave.onSettled = { [weak self] in
            self?.applyDeferredProjectionIfClean()
        }
    }

    // MARK: - Projections

    /// Runs for the view's lifetime: the rendered post + header, live.
    func start() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.observeSlots() }
            group.addTask { await self.observeHeader() }
        }
    }

    /// One direct load (tests, and re-fetch-at-settle).
    func loadOnce() async {
        do {
            let postID = postID
            let (slots, header) = try await session.database.read { db in
                (try Queries.renderPost(db, containerID: postID),
                 try Queries.containerHeader(db, containerID: postID))
            }
            adopt(header: header)
            adopt(slots: slots)
        } catch {
            lastError = String(describing: error)
        }
    }

    private func observeSlots() async {
        do {
            for try await slots in session.database.observePost(postID) {
                adopt(slots: slots)
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    private func observeHeader() async {
        do {
            for try await header in session.database.observeContainerHeader(postID) {
                adopt(header: header)
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    private func adopt(header: Queries.ContainerHeader?) {
        self.header = header
    }

    private func adopt(slots: [Queries.RenderedBlock]) {
        // Buffer-authoritative while anything is unpersisted (the Phase 7
        // posture): remember that a projection arrived; re-fetch fresh at
        // settle instead of applying a stale value (review MAJOR 2's rule).
        guard !autosave.isDirty, !mintInFlight else {
            projectionDeferred = true
            return
        }
        self.slots = slots
        // Auto-focus the single block of a one-block entry (the journal's
        // everyday shape); multi-block posts focus by tap.
        if focusedVariantID == nil, slots.count == 1, let only = slots.first,
           !only.isGap, !only.variantLocked, !isSealed {
            focus(only)
        }
        // The focused slot's store text — adopt it when the buffer is clean
        // (our own flush echoing back, or a genuinely external change; both
        // are safe to show when nothing local is pending).
        if let focusedVariantID,
           let focused = slots.first(where: { $0.variantID == focusedVariantID }) {
            draftText = focused.text ?? ""
            flushedDraft = draftText
        } else if focusedVariantID != nil {
            // The focused variant left the projection (re-pointed slot,
            // remote structural change): drop focus rather than edit a
            // variant no slot shows.
            focusedVariantID = nil
            draftText = ""
            flushedDraft = ""
        }
    }

    private func applyDeferredProjectionIfClean() {
        guard projectionDeferred, !autosave.isDirty, !mintInFlight else { return }
        projectionDeferred = false
        Task { await loadOnce() }
    }

    // MARK: - Focus & editing

    func focus(_ slot: Queries.RenderedBlock) {
        guard !isSealed else {
            lastError = "This post is locked — unlock it on the Mac to edit."
            return
        }
        guard let variantID = slot.variantID, let text = slot.text else { return }
        guard !slot.variantLocked else {
            lastError = "This block's take is locked."
            return
        }
        focusedVariantID = variantID
        draftText = text
        flushedDraft = text
    }

    /// The TextEditor's setter: routes one edit into the pipeline.
    func setDraft(_ newText: String) {
        guard newText != draftText else { return }
        guard !isSealed else {
            lastError = "This post is locked — unlock it on the Mac to edit."
            return
        }
        draftText = newText
        if let focusedVariantID {
            autosave.record(
                variantID: focusedVariantID,
                text: newText,
                charDelta: EditCost.utf16Cost(from: flushedDraft, to: newText))
            flushedDraft = newText
        } else if slots.isEmpty {
            mintFirstBlock()
        }
        // A keystroke with no focus on a non-empty post cannot happen (the
        // view only shows an editor when focused or empty).
    }

    /// The first keystroke on an empty entry mints THE block — one-block
    /// journal semantics; Enter afterwards is content forever (I4).
    private func mintFirstBlock() {
        guard !mintInFlight else { return }
        mintInFlight = true
        let postID = postID
        Task {
            do {
                let text = draftText
                let minted = try await session.runner.run { ops in
                    try ops.newBlock(in: postID, text: text, at: .end)
                }
                focusedVariantID = minted.variant.id
                flushedDraft = text
                // Typing that landed while the mint was in flight becomes an
                // ordinary autosave on the fresh variant.
                if draftText != text {
                    autosave.record(
                        variantID: minted.variant.id,
                        text: draftText,
                        charDelta: EditCost.utf16Cost(from: text, to: draftText))
                    flushedDraft = draftText
                }
                mintInFlight = false
                applyDeferredProjectionIfClean()
            } catch {
                lastError = String(describing: error)
                mintInFlight = false
            }
        }
    }

    /// Teardown: everything pending lands (the mint path is synchronous
    /// enough that `flushNow` after it suffices at capture scale).
    func finish() async {
        await waitForMint()
        await autosave.flushNow()
    }

    /// Bounded wait for an in-flight first-block mint (teardown + tests).
    func waitForMint() async {
        for _ in 0..<2000 where mintInFlight {
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(1))
        }
    }

    // MARK: - The user-set entry date (author 2026-07-07: default today,
    // settable to any day, past or future; created_at never moves)

    func setEntryDate(_ day: String) {
        guard JournalDay.isValid(day) else {
            lastError = "Not a valid date."
            return
        }
        let postID = postID
        Task {
            do {
                try await session.runner.run { ops in
                    try ops.setEntryDate(postID, entryDate: day)
                }
            } catch {
                lastError = String(describing: error)
            }
        }
    }
}

/// The churn feed's edit cost (AppSpec §10): inserted + deleted, equal
/// weight, UTF-16 units (the Phase 3 offset decision). A whole-buffer diff
/// by common prefix/suffix — exact for any single contiguous edit, which is
/// what a text view hands us per change.
enum EditCost {
    nonisolated static func utf16Cost(from old: String, to new: String) -> Int {
        let oldUnits = Array(old.utf16)
        let newUnits = Array(new.utf16)
        var prefix = 0
        while prefix < oldUnits.count, prefix < newUnits.count,
              oldUnits[prefix] == newUnits[prefix] {
            prefix += 1
        }
        var suffix = 0
        while suffix < oldUnits.count - prefix, suffix < newUnits.count - prefix,
              oldUnits[oldUnits.count - 1 - suffix] == newUnits[newUnits.count - 1 - suffix] {
            suffix += 1
        }
        let deleted = oldUnits.count - prefix - suffix
        let inserted = newUnits.count - prefix - suffix
        return deleted + inserted
    }
}
