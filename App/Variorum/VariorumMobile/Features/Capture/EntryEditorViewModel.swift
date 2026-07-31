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
//    by sharing the code);
//  - blocks with fans render the chosen/default take's text and edit
//    exactly that variant — the fan itself is invisible here;
//  - a sealed post renders read-only with the refusal surfaced.
//
//  PROJECTION DISCIPLINE (review round 1, MAJOR): a delivered observation
//  value is a photograph of some PAST commit — it can arrive on the
//  MainActor after a newer flush has landed and the buffer looks clean, and
//  adopting it would reset the draft and edit-cost base to stale text; the
//  next keystroke would then overwrite the flushed text in the store (the
//  forbidden text-loss class; sub-case: a stale empty delivery would drop
//  focus and double-mint the "first" block). So delivered values are NEVER
//  adopted. Every delivery is only a signal; the authoritative application
//  is a FRESH read stamped with `readGeneration` — any local write landing
//  after the read began bumps the generation and the fetched value is
//  discarded and re-fetched. Adoption happens only when the buffer is clean
//  AND the value is provably current.
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
    /// A projection signal that arrived while the buffer was authoritative —
    /// remembered; a fresh read runs at settle (never a stale value).
    private var projectionDeferred = false
    /// Bumped whenever a local write lands (flush settle, mint completion):
    /// any in-flight read that began before the bump is stale by definition
    /// and is discarded on arrival.
    private var readGeneration = 0
    /// Authoritative reads in flight (test settling).
    private(set) var refreshesInFlight = 0

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
            guard let self else { return }
            // A flush just landed (or failed back into pending): every read
            // begun before this instant is stale.
            self.readGeneration += 1
            if self.projectionDeferred {
                self.projectionDeferred = false
                self.scheduleAuthoritativeRefresh()
            }
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

    /// One authoritative load, settled (first paint + tests).
    func loadOnce() async {
        scheduleAuthoritativeRefresh()
        await settleProjection()
    }

    /// Bounded wait until no authoritative read is in flight (tests +
    /// first paint).
    func settleProjection() async {
        for _ in 0..<2000 where refreshesInFlight > 0 {
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(1))
        }
    }

    private func observeSlots() async {
        do {
            for try await slots in session.database.observePost(postID) {
                projectionDelivered(slots)
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    private func observeHeader() async {
        do {
            for try await _ in session.database.observeContainerHeader(postID) {
                // Header changes (a remote seal, a re-date) ride the same
                // authoritative-read path as slots.
                scheduleAuthoritativeRefresh()
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    /// The observation hand-off. The DELIVERED VALUE IS DELIBERATELY
    /// UNUSED: it may predate local writes that landed while it was in
    /// transit (see the projection-discipline note above). Internal, not
    /// private, so the review pin can drive the exact race.
    func projectionDelivered(_ slots: [Queries.RenderedBlock]) {
        _ = slots
        scheduleAuthoritativeRefresh()
    }

    /// A fresh, generation-stamped read of post + header.
    private func scheduleAuthoritativeRefresh() {
        let generation = readGeneration
        refreshesInFlight += 1
        let postID = postID
        Task { [weak self] in
            guard let self else { return }
            defer { self.refreshesInFlight -= 1 }
            do {
                let value = try await self.session.database.read { db in
                    (slots: try Queries.renderPost(db, containerID: postID),
                     header: try Queries.containerHeader(db, containerID: postID))
                }
                self.applyFetched(slots: value.slots, header: value.header, generation: generation)
            } catch {
                self.lastError = String(describing: error)
            }
        }
    }

    private func applyFetched(
        slots: [Queries.RenderedBlock],
        header: Queries.ContainerHeader?,
        generation: Int
    ) {
        // Buffer-authoritative while anything is unpersisted (the Phase 7
        // posture): the settle handler re-fetches.
        guard !autosave.isDirty, !mintInFlight else {
            projectionDeferred = true
            return
        }
        // A local write landed after this read began: the value is a stale
        // photograph — discard it and read again.
        guard generation == readGeneration else {
            scheduleAuthoritativeRefresh()
            return
        }
        adopt(slots: slots, header: header)
    }

    /// Reached ONLY with a clean buffer and a provably current value.
    private func adopt(slots: [Queries.RenderedBlock], header: Queries.ContainerHeader?) {
        self.header = header
        self.slots = slots
        // Auto-focus the single block of a one-block entry (the journal's
        // everyday shape); multi-block posts focus by tap.
        if focusedVariantID == nil, slots.count == 1, let only = slots.first,
           !only.isGap, !only.variantLocked, !isSealed {
            focus(only)
        }
        // The focused slot's store text: our own flush echoing back, or a
        // genuinely external change — both safe to show when nothing local
        // is pending and the value is current.
        if let focusedVariantID,
           let focused = slots.first(where: { $0.variantID == focusedVariantID }) {
            draftText = focused.text ?? ""
            flushedDraft = draftText
        } else if focusedVariantID != nil {
            // The focused variant genuinely left the store's projection
            // (re-pointed slot, remote structural change): drop focus rather
            // than edit a variant no slot shows.
            focusedVariantID = nil
            draftText = ""
            flushedDraft = ""
        }
    }

    // MARK: - Focus & editing

    func focus(_ slot: Queries.RenderedBlock) {
        guard !isSealed else {
            lastError = "This note is locked — unlock it on the Mac to edit."
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
            lastError = "This note is locked — unlock it on the Mac to edit."
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
                // The mint is a local write: stale in-flight reads die here.
                readGeneration += 1
                if projectionDeferred {
                    projectionDeferred = false
                }
                scheduleAuthoritativeRefresh()
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
/// what a text view hands us per change. O(buffer) per keystroke — fine at
/// capture scale; folded into QUESTIONS #2's Phase 15 revisit (review NIT).
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
