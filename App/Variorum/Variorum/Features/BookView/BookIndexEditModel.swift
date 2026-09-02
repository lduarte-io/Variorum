//
//  BookIndexEditModel.swift
//  Variorum
//
//  The Act 10 correction round, batch B (row 22, R-cor-7: "index being
//  editable is true for index… book will also have the same thing for
//  index") — **the book Index's liveness authority.** ONE `PaneTextAuthority`
//  for the whole book pane, each pane keyed with its POST as the context
//  (13b 4C's compare-board shape — one authority spanning several posts, the
//  one-ring invariant over the union), so exactly one block is live across
//  every note the pane realizes (P-3). Autosave rides each post's own
//  coordinator (`AppSession.autosave(forPost:)` — the N3 boundary), and a
//  ring migrating between posts flushes the LEAVING post's coordinator, as
//  the compare board does.
//
//  What this deliberately is not: a second full-document editor. The pane
//  stays a projection tier (SwiftUI `Text` per block, virtualized per note)
//  and upgrades ONLY the clicked block to a `PaneSurfaceView` — the TOC's
//  read-cheap→live split, the block-TOC design's own promise, at book scale.
//

import Foundation
import Observation
import VariorumCore

@MainActor
@Observable
final class BookIndexEditModel {
    @ObservationIgnored let session: AppSession
    /// The pane column's id inside the authority's keys.
    static let columnID = "book-index"

    private(set) var authority = PaneTextAuthority()
    @ObservationIgnored private var coordinators: [String: AutosaveCoordinator] = [:]
    @ObservationIgnored private var tokens: [String: UUID] = [:]
    /// A block a landing asked to make live before its note's rows had
    /// loaded (row 38 — the Read click's block arrives ahead of the pane
    /// note's projection). The note's pane consumes it on its first adopt.
    private(set) var pendingLiveBlock: LandingTarget?

    init(session: AppSession) {
        self.session = session
    }

    var liveBlockID: String? { authority.livePane?.blockID }
    var livePostID: String? { authority.livePane?.context }

    func isLive(postID: String, blockID: String, variantID: String) -> Bool {
        authority.isLive(PaneTextAuthority.PaneKey(
            columnID: Self.columnID, blockID: blockID, variantID: variantID, context: postID))
    }

    /// The post's coordinator — the ONE per-post coordinator, observed for
    /// its refusals the first time this pane touches it.
    private func coordinator(for postID: String) -> AutosaveCoordinator {
        if let existing = coordinators[postID] { return existing }
        let coordinator = session.autosave(forPost: postID)
        coordinators[postID] = coordinator
        tokens[postID] = coordinator.observe(onError: { [weak self] error in
            self?.session.status.speak(OpsRefusalCopy.message(for: error))
        })
        return coordinator
    }

    /// The click (or a landing): THIS block goes live; whatever was live
    /// returns to read-cheap, its pending text flushed through its own
    /// post's coordinator.
    func makeLive(postID: String, blockID: String, variantID: String) {
        let key = PaneTextAuthority.PaneKey(
            columnID: Self.columnID, blockID: blockID, variantID: variantID, context: postID)
        switch authority.focus(key) {
        case .unchanged:
            return
        case .migrated(let from):
            if let from, !from.context.isEmpty {
                let leaving = coordinator(for: from.context)
                Task { await leaving.flushNow() }
            }
        }
    }

    func blur() {
        if let leaving = authority.livePane {
            authority.blur()
            let coordinator = coordinator(for: leaving.context)
            Task { await coordinator.flushNow() }
        }
    }

    /// A row's displayed text: the authority's overlay over the store's
    /// text (a read pane mirroring a dirty variant never renders staler
    /// text than the buffer).
    func displayText(variantID: String?, storeText: String?) -> String {
        guard let variantID else { return storeText ?? "" }
        return authority.text(variantID: variantID, storeText: storeText ?? "")
    }

    func paneEdited(postID: String, variantID: String, oldText: String, newText: String) {
        let old = authority.text(variantID: variantID, storeText: oldText)
        let cost = TakeEditCost.utf16Cost(from: old, to: newText)
        guard cost > 0 else { return }
        authority.bufferEdited(variantID: variantID, text: newText)
        coordinator(for: postID).record(variantID: variantID, text: newText, charDelta: cost)
    }

    /// Settle-time convergence on a projection delivery: buffers with no
    /// pending autosave drop, so external edits reach the pane.
    func settle() {
        let pending = coordinators.values
        authority.settle(isPending: { variantID in
            pending.contains { $0.pending[variantID] != nil }
        })
    }

    // MARK: - The landing (row 38)

    /// Ask for a block to go live once its note's rows are in hand.
    func requestLiveBlock(_ target: LandingTarget) {
        pendingLiveBlock = target
    }

    /// The note's pane adopted rows: if a landing waits on this note and
    /// names a block the rows carry, it goes live now. Returns the block
    /// made live, so the pane can scroll to it.
    @discardableResult
    func takePendingLiveBlock(postID: String, rows: [Queries.TOCRow]) -> String? {
        guard let target = pendingLiveBlock, target.postID == postID else { return nil }
        let row: Queries.TOCRow? = target.blockID
            .flatMap { id in rows.first { $0.blockID == id } }
            ?? rows.first
        guard let row, let variantID = row.variantID, !row.variantLocked else {
            pendingLiveBlock = nil
            return nil
        }
        pendingLiveBlock = nil
        makeLive(postID: postID, blockID: row.blockID, variantID: variantID)
        return row.blockID
    }

    /// Ladder R1-8: the coordinator ENTRIES leave with their tokens — a
    /// model reused after a teardown (a host that keeps it across an
    /// `onDisappear`: a tab, a hidden pane) re-subscribes on its next
    /// touch through `coordinator(for:)`, instead of returning a cached
    /// coordinator nobody observes and dropping its refusals silently.
    func teardown() {
        blur()
        for (postID, token) in tokens {
            coordinators[postID]?.stopObserving(token)
        }
        tokens.removeAll()
        let all = Array(coordinators.values)
        coordinators.removeAll()
        Task { for coordinator in all { await coordinator.flushNow() } }
    }
}
