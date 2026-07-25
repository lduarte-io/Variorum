//
//  CompareBoardView.swift
//  Variorum
//
//  Phase 13b, Stage 4 (4C — S4-2/S4-3/S4-12, N29/N33): COMPARE rebuilt as
//  "lenses across posts" on the ONE architecture. Cells are `PaneSurface`
//  panes over the ONE `PaneTextAuthority` — fully EDITABLE, with ONE live
//  ring across every column and every post (the authority's contract
//  extends across post contexts; pane identity carries its post). Each
//  post's edits flow through ITS OWN per-post AutosaveCoordinator
//  (`session.autosave(forPost:)` — the N3 boundary is per post, so two or
//  more coordinators being live here is the DESIGNED shape, not a
//  violation). Up to FOUR columns: the anchor + three picked peers
//  (S4-2c + the 2026-07-17 N-post intake). Per-post block REORDER by drag
//  — each column reorders ITS OWN post only (S4-2d's compare half:
//  "a huge point of a post instead of a lens is the posts allowing
//  different block orders").
//
//  The honesty rules (N29, agreed S4-12): zero-lineage pairs render PLAIN
//  side by side — "there is no relationship here" — no blank parade, no
//  rails; rails color only where lineage actually speaks, both sides by
//  the anchor kin's ID (associated blocks share a color); zero-lineage
//  version-marking says alignment will be loose. "Follow this post's
//  order" is a display-only TOGGLE (S4-3's shape; order-drag SYNC is
//  deliberately NOT built until display-only proves insufficient).
//
//  Outline retired as a tab into this board (S4-3): its one unique power —
//  make-outline-post (R99) — lives in this header; a minted outline opens
//  beside its draft and registers block-by-block through the same lineage
//  kinship (`Queries.blockKinship`, the CTE's — never re-derived).
//
//  Replaces AlignedPostsView (SwiftUI Text cells — that surface's slice of
//  the fourth prose path retires with it). This is still `version_of`'s
//  DOOR 2: unlinked posts get "Mark as Versions" right here.
//

import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import SwiftUI
import VariorumCore

// MARK: - The observed value

/// The compare board's one observed value (nonisolated — the observation
/// hops executors).
nonisolated struct CompareProjection: Equatable, Sendable {
    struct PostFace: Equatable, Sendable {
        var slots: [Queries.RenderedBlock] = []
        var fans: [String: [Variant]] = [:]
        var title: String?
        var sealed = false
    }

    var anchor = PostFace()
    var peers: [String: PostFace] = [:]
    /// peerID → (peer block → its anchor kin block) — `Queries.blockKinship`
    /// verbatim, never re-derived view-side.
    var kinship: [String: [String: String]] = [:]
    /// Posts version-linked to the anchor.
    var versionPeers: [String] = []
}

/// A display row (the model derives these from `CompareComposition`'s
/// segments; free segments flatten to index-paired rows so the LazyVStack
/// virtualizes — P3: realized rows bound the cost, never post size).
nonisolated enum CompareRow: Equatable, Identifiable {
    /// An unrelated stretch's row: each column's next block, side by side,
    /// own orders — absent cells render as clear space, never a "—" blank.
    case free(anchor: String?, peers: [String?], index: Int)
    /// A kin row — lineage speaks; cells align.
    case aligned(CompareComposition.AlignedRow)

    var id: String {
        switch self {
        case .free(let anchor, let peers, let index):
            return "free-\(index)-\(anchor ?? "·")-\(peers.map { $0 ?? "·" }.joined(separator: "|"))"
        case .aligned(let row):
            return "aligned-\(row.anchorBlockID)"
        }
    }
}

// MARK: - The model

@MainActor
@Observable
final class CompareViewModel {
    @ObservationIgnored let session: AppSession
    let anchorPostID: String

    /// A peer COLUMN slot (up to three): nil = the picker waits.
    struct PeerSlot: Identifiable, Equatable {
        let id: String
        var postID: String?

        init(id: String = UUID().uuidString, postID: String? = nil) {
            self.id = id
            self.postID = postID
        }
    }

    init(session: AppSession, anchorPostID: String) {
        self.session = session
        self.anchorPostID = anchorPostID
        // The anchor's coordinator is tracked from birth (edits may land
        // the moment a pane goes live).
        _ = coordinator(for: anchorPostID)
    }

    // MARK: Observable state

    private(set) var projection = CompareProjection()
    private(set) var peerCandidates: [Queries.TimelineItem] = []
    var peerSlots: [PeerSlot] = [PeerSlot()] {
        didSet {
            let picked = peerSlots.compactMap(\.postID)
            for postID in picked { _ = coordinator(for: postID) }
            if picked != oldValue.compactMap(\.postID) { restartObservation() }
        }
    }
    /// S4-3/S4-12 — "follow this post's order": display-only lineage-tied
    /// ordering of the peer columns. SESSION-LOCAL view state (a toggle,
    /// never persisted, never a mode). Default ON — the 11a aligned
    /// promise ("the two posts sit aligned block by block") holds where
    /// lineage exists; zero-lineage pairs render plain regardless.
    var followAnchorOrder = true
    /// S4-12 — the lineage-color relationship, toggleable on/off.
    /// Session-local like the follow toggle.
    var lineageColorsOn = true
    /// In-cell fan blooms — session-only, like the takes board's.
    private(set) var expandedBlocks: Set<String> = []
    /// THE pane-text/liveness authority — ONE across every post context
    /// this board mounts (13b 4C: the extended contract; never a second
    /// liveness mechanism beside it).
    private(set) var authority = PaneTextAuthority()
    /// The board's transient outcome line; PRESENTATION is the shell's
    /// StatusCenter (AD-14 — one placement, one auto-dismiss).
    private(set) var statusMessage: String? {
        didSet {
            if let statusMessage { session.status.speak(statusMessage) }
        }
    }

    // MARK: Coordinators (per post — the N3 boundary)

    @ObservationIgnored private var coordinatorTokens: [String: UUID] = [:]

    /// The per-post coordinator, observation-registered exactly once. Two
    /// or more coordinators live at once is compare's DESIGNED shape (one
    /// per post context; the 1a consolidation's boundary is per post).
    private func coordinator(for postID: String) -> AutosaveCoordinator {
        let coordinator = session.autosave(forPost: postID)
        if coordinatorTokens[postID] == nil {
            coordinatorTokens[postID] = coordinator.observe(
                onError: { [weak self] error in
                    self?.statusMessage = OpsRefusalCopy.message(for: error)
                },
                onSettled: { [weak self] in self?.settleIfClean() })
        }
        return coordinator
    }

    private var mountedPostIDs: [String] {
        [anchorPostID] + peerSlots.compactMap(\.postID)
    }

    private var anyDirty: Bool {
        mountedPostIDs.contains { coordinator(for: $0).isDirty }
    }

    private func settleIfClean() {
        guard !anyDirty, let deferred = deferredProjection else { return }
        deferredProjection = nil
        adopt(deferred)
    }

    // MARK: Lifecycle

    @ObservationIgnored private var observation: Task<Void, Never>?
    @ObservationIgnored private var deferredProjection: CompareProjection?
    @ObservationIgnored private var started = false
    /// The auto-default fires at most once (a linked peer is the natural
    /// first column; clearing it afterwards STAYS cleared — the old
    /// view's refill wart is deliberately gone).
    @ObservationIgnored private var autoFilled = false

    func start() async {
        started = true
        restartObservation()
        do {
            let anchorID = anchorPostID
            for try await items in session.database.observeLibrary(
                sort: .lastTouched, direction: .desc, limit: 100
            ) {
                peerCandidates = items.filter { $0.postID != anchorID }
            }
        } catch is CancellationError {
        } catch {
            statusMessage = "Compare observation failed: \(error)"
        }
    }

    /// ONE read brain for the projection — the observation closure and the
    /// tests read through the same function (never re-typed SQL).
    nonisolated static func read(
        _ db: Database, anchor anchorID: String, peers peerIDs: [String]
    ) throws -> CompareProjection {
        func face(_ id: String) throws -> CompareProjection.PostFace {
            let slots = try Queries.renderPost(db, containerID: id)
            return CompareProjection.PostFace(
                slots: slots,
                fans: try Queries.activeFans(
                    db, blockIDs: slots.filter { !$0.isGap }.map(\.blockID)),
                title: try Queries.containerTitle(db, id: id),
                sealed: try Queries.containerHeader(db, containerID: id)?.locked == true)
        }
        var peers: [String: CompareProjection.PostFace] = [:]
        var kinship: [String: [String: String]] = [:]
        for peerID in peerIDs {
            peers[peerID] = try face(peerID)
            kinship[peerID] = try Queries.blockKinship(db, anchor: anchorID, other: peerID)
        }
        return CompareProjection(
            anchor: try face(anchorID),
            peers: peers,
            kinship: kinship,
            versionPeers: try Queries.versionPeerPosts(db, of: anchorID))
    }

    private func restartObservation() {
        guard started else { return }
        observation?.cancel()
        let anchorID = anchorPostID
        let peerIDs = peerSlots.compactMap(\.postID)
        observation = Task { [session] in
            do {
                for try await value in session.database.observe({ db in
                    try Self.read(db, anchor: anchorID, peers: peerIDs)
                }) {
                    if self.anyDirty {
                        self.deferredProjection = value  // adopt at settle
                    } else {
                        self.adopt(value)
                    }
                }
            } catch is CancellationError {
            } catch {
                self.statusMessage = "Compare observation failed: \(error)"
            }
        }
    }

    /// Internal so tests drive projections deterministically (the test
    /// host never fires `.task`).
    func adopt(_ new: CompareProjection) {
        projection = new
        // The convergence half of the buffer-authoritative discipline —
        // across the UNION of this board's coordinators (a buffer stays
        // authoritative while pending in ITS post's pipeline).
        authority.settle(isPending: { variantID in
            mountedPostIDs.contains {
                coordinator(for: $0).pending[variantID] != nil
            }
        })
        if !autoFilled, peerSlots.first?.postID == nil,
           let first = new.versionPeers.first {
            autoFilled = true
            peerSlots[0].postID = first  // a linked peer is the natural default
        }
    }

    func teardown() {
        observation?.cancel()
        for (postID, token) in coordinatorTokens {
            let coordinator = session.autosave(forPost: postID)
            coordinator.stopObserving(token)
            Task { await coordinator.flushNow() }
        }
        coordinatorTokens = [:]
    }

    // MARK: Faces + resolution

    func face(for postID: String) -> CompareProjection.PostFace? {
        postID == anchorPostID ? projection.anchor : projection.peers[postID]
    }

    func slot(postID: String, blockID: String) -> Queries.RenderedBlock? {
        face(for: postID)?.slots.first { $0.blockID == blockID }
    }

    /// What a cell shows: the slot's chosen resolution with the buffer
    /// overlay — the authority's one fall-through, same as every pane.
    func resolvedText(postID: String, slot: Queries.RenderedBlock)
        -> (variantID: String, text: String)?
    {
        authority.resolvedText(
            pick: nil, slot: slot, fan: face(for: postID)?.fans[slot.blockID])
    }

    /// A take's displayed text where it renders raw (bloomed fan cards) —
    /// never staler than the live buffer.
    func liveText(_ take: Variant) -> String {
        authority.text(variantID: take.id, storeText: take.workingText)
    }

    private func storeText(postID: String, variantID: String) -> String? {
        guard let face = face(for: postID) else { return nil }
        for (_, fan) in face.fans {
            if let take = fan.first(where: { $0.id == variantID }) {
                return take.workingText
            }
        }
        return face.slots.first { $0.variantID == variantID }?.text
    }

    // MARK: Focus + edits (the ONE ring migrates — across posts)

    func focus(_ pane: PaneTextAuthority.PaneKey) {
        switch authority.focus(pane) {
        case .unchanged:
            return
        case .migrated(let leaving):
            // The leaving pane's text lands through ITS OWN post's
            // coordinator (the cross-context contract's handback).
            if let leaving, !leaving.context.isEmpty {
                let coordinator = coordinator(for: leaving.context)
                Task { await coordinator.flushNow() }
            }
        }
    }

    func blur() {
        authority.blur()
        for postID in mountedPostIDs {
            let coordinator = coordinator(for: postID)
            Task { await coordinator.flushNow() }
        }
    }

    /// A live pane's keystroke: buffer-authoritative while dirty; the edit
    /// lands in exactly that take's working_text, through exactly that
    /// POST's autosave pipeline.
    func paneEdited(postID: String, variantID: String, newText: String) {
        let old = authority.text(
            variantID: variantID,
            storeText: storeText(postID: postID, variantID: variantID) ?? "")
        let cost = TakeEditCost.utf16Cost(from: old, to: newText)
        guard cost > 0 else { return }
        authority.bufferEdited(variantID: variantID, text: newText)
        coordinator(for: postID).record(variantID: variantID, text: newText, charDelta: cost)
    }

    // MARK: Composition (the pure brain, fed)

    /// Column order is stable: the anchor, then the peer slots (a nil slot
    /// contributes an empty column so headers and cells stay aligned).
    var rows: [CompareRow] {
        let peerIDs = peerSlots.map(\.postID)
        let segments = CompareComposition.segments(
            anchorBlocks: projection.anchor.slots.filter { !$0.isGap }.map(\.blockID),
            peerBlocks: peerIDs.map { id in
                guard let id, let face = projection.peers[id] else { return [] }
                return face.slots.filter { !$0.isGap }.map(\.blockID)
            },
            kinships: peerIDs.map { id in
                guard let id else { return [:] }
                return projection.kinship[id] ?? [:]
            },
            followAnchorOrder: followAnchorOrder)
        var rows: [CompareRow] = []
        var freeIndex = 0
        for segment in segments {
            switch segment {
            case .aligned(let row):
                rows.append(.aligned(row))
            case .free(let anchor, let peers):
                let depth = max(anchor.count, peers.map(\.count).max() ?? 0)
                for i in 0..<depth {
                    rows.append(.free(
                        anchor: i < anchor.count ? anchor[i] : nil,
                        peers: peers.map { i < $0.count ? $0[i] : nil },
                        index: freeIndex))
                    freeIndex += 1
                }
            }
        }
        return rows
    }

    /// The rail rule (S4-12): a block rails only where lineage speaks —
    /// nil means no rail. Both sides color by the ANCHOR kin's ID.
    func railKin(postID: String, blockID: String) -> String? {
        guard lineageColorsOn else { return nil }
        if postID == anchorPostID {
            let railed = CompareComposition.railedAnchors(
                kinships: peerSlots.compactMap(\.postID).map { projection.kinship[$0] ?? [:] })
            return railed.contains(blockID) ? blockID : nil
        }
        return projection.kinship[postID]?[blockID]
    }

    /// N29's relationship answer: lineage OR a version link.
    func isRelated(_ peerID: String) -> Bool {
        projection.versionPeers.contains(peerID)
            || !(projection.kinship[peerID] ?? [:]).isEmpty
    }

    func isVersionPeer(_ peerID: String) -> Bool {
        projection.versionPeers.contains(peerID)
    }

    func hasLineage(_ peerID: String) -> Bool {
        !(projection.kinship[peerID] ?? [:]).isEmpty
    }

    // MARK: Peer slot management

    /// 13b Stage 4 ladder round 1, NIT-1: a removed/replaced column may
    /// host THE live pane — the ring must never stay on an unmounted
    /// context (no rendered pane would show it), and the moment the post
    /// leaves `mountedPostIDs` the union-settle stops covering its pending
    /// buffers (the 4C record's traced, accepted transient). Blur + a
    /// targeted flush of the LEAVING post's coordinator — while we still
    /// know which post it is — shrinks that window at zero cost.
    private func releaseLivePane(leavingPost postID: String?) {
        guard let postID, authority.livePane?.context == postID else { return }
        authority.blur()
        let coordinator = coordinator(for: postID)
        Task { await coordinator.flushNow() }
    }

    func setPeer(slotID: String, postID: String?) {
        autoFilled = true
        guard let index = peerSlots.firstIndex(where: { $0.id == slotID }) else { return }
        if let postID,
           postID == anchorPostID
               || peerSlots.contains(where: { $0.postID == postID && $0.id != slotID }) {
            statusMessage = "That post is already open in this compare."
            return
        }
        if peerSlots[index].postID != postID {
            releaseLivePane(leavingPost: peerSlots[index].postID)
        }
        peerSlots[index].postID = postID
    }

    func addPeerSlot() {
        guard peerSlots.count < 3 else { return }
        peerSlots.append(PeerSlot())
    }

    func removePeerSlot(_ slotID: String) {
        autoFilled = true
        guard let index = peerSlots.firstIndex(where: { $0.id == slotID }) else { return }
        releaseLivePane(leavingPost: peerSlots[index].postID)
        if peerSlots.count == 1 {
            peerSlots[index].postID = nil  // the last column keeps its picker
        } else {
            peerSlots.remove(at: index)
        }
    }

    // MARK: Gestures (every one an Operations call)

    /// The drag-reorder's landing: ordinary `reorder` through ops (one op
    /// per drop; ⌥⌘Z undoes). Each column reorders ITS OWN post only —
    /// a cross-post drop refuses honestly (moving blocks between posts is
    /// moveBlock's, deliberately not this gesture).
    func moveBlock(_ blockID: String, inPost postID: String, before targetBlockID: String?) async {
        guard let face = face(for: postID),
              face.slots.contains(where: { $0.blockID == blockID })
        else {
            statusMessage =
                "Order drags stay within one post here — each column reorders its own post."
            return
        }
        if let targetBlockID {
            guard face.slots.contains(where: { $0.blockID == targetBlockID }),
                  targetBlockID != blockID
            else { return }
            // Dropping right before its own successor is a no-op.
            if let from = face.slots.firstIndex(where: { $0.blockID == blockID }),
               let to = face.slots.firstIndex(where: { $0.blockID == targetBlockID }),
               to == from + 1 { return }
        } else if face.slots.last?.blockID == blockID {
            return  // already last
        }
        let insert: Operations.InsertPosition =
            targetBlockID.map { .before($0) } ?? .end
        statusMessage = nil
        do {
            try await session.runner.run { ops in
                try ops.reorder(blockID, to: insert)
            }
            // Honesty note (recorded judgment call): while a peer column
            // follows the anchor's order, a KIN block's displayed position
            // is lineage-tied — the stored reorder is real but may not
            // show until the toggle is off.
            if followAnchorOrder, postID != anchorPostID,
               projection.kinship[postID]?[blockID] != nil {
                statusMessage =
                    "Reordered. This column is following the first post's order right now — "
                    + "the new order shows with \u{201C}follow this post's order\u{201D} off."
            }
        } catch {
            statusMessage = OpsRefusalCopy.message(for: error)
        }
    }

    /// ✓ — the explicit chooseVariant (I3's setter), unchanged.
    func choose(blockID: String, variantID: String) async {
        statusMessage = nil
        do {
            try await session.runner.run { ops in
                try ops.chooseVariant(blockID, variantID: variantID)
            }
        } catch {
            statusMessage = OpsRefusalCopy.message(for: error)
        }
    }

    func toggleExpanded(_ blockID: String) {
        if expandedBlocks.contains(blockID) {
            expandedBlocks.remove(blockID)
        } else {
            expandedBlocks.insert(blockID)
        }
    }

    /// DOOR 2 — the same op the library door emits. Zero-lineage marking
    /// says alignment will be loose (N29's rider).
    func markAsVersions(_ peerID: String) {
        statusMessage = nil
        Task { [runner = session.runner, anchorPostID] in
            do {
                try await runner.run { ops in
                    _ = try ops.markPostsAsVersions(anchorPostID, peerID)
                }
                if !self.hasLineage(peerID) {
                    self.statusMessage =
                        "Marked as versions — a connection, nothing copied. These posts share "
                        + "no lineage, so they align only loosely: side by side, each in its own order."
                }
            } catch {
                self.statusMessage = OpsRefusalCopy.message(for: error)
            }
        }
    }

    /// Sitting 9 (R60/R68): unmarkable right where it shows.
    func unmarkVersions(_ peerID: String) {
        statusMessage = nil
        Task { [runner = session.runner, anchorPostID] in
            do {
                try await runner.run { ops in
                    try ops.unmarkPostsAsVersions(anchorPostID, peerID)
                }
                self.statusMessage =
                    "Unmarked — the posts are no longer versions of each other (both untouched; re-mark any time)."
            } catch {
                self.statusMessage = OpsRefusalCopy.message(for: error)
            }
        }
    }

    /// R99's door, re-homed from the retired Outline tab (S4-3): mint
    /// "outline of <title>" — first sentence per block, linked
    /// block-by-block — and open it as a compare column.
    func makeOutlinePost() async {
        statusMessage = nil
        do {
            let result = try await session.runner.run { [anchorPostID] ops in
                try ops.mintOutlinePost(of: anchorPostID)
            }
            autoFilled = true
            if let index = peerSlots.firstIndex(where: { $0.postID == nil }) {
                peerSlots[index].postID = result.post.id
            } else if peerSlots.count < 3 {
                peerSlots.append(PeerSlot(postID: result.post.id))
            } else {
                statusMessage =
                    "Made \u{201C}\(result.post.title ?? "the outline")\u{201D} — close a column to open it here (compare holds four)."
            }
        } catch {
            statusMessage = OpsRefusalCopy.message(for: error)
        }
    }

    /// The bar's speaking surface.
    func speak(_ message: String) {
        statusMessage = message
    }

    /// 13b 4D (the 4C handoff — judgment call 4's recorded one-gate
    /// upgrade, built): ⌘S in Compare commits the FOCUSED pane's take
    /// through the authority (the N5 letter extended to the new editable
    /// surface). The flush routes through the pane's OWN post's
    /// coordinator (the cross-context handback's rule); no focus speaks.
    func commitFocusedTake() async {
        guard let pane = authority.livePane else {
            statusMessage = "Click into a pane first — ⌘S commits the take you're in."
            return
        }
        let postID = pane.context.isEmpty ? anchorPostID : pane.context
        await coordinator(for: postID).flushNow()
        statusMessage = nil
        do {
            try await session.runner.run { ops in
                _ = try ops.commit(pane.variantID)
            }
            statusMessage = "Committed — an immutable savepoint of this take."
        } catch {
            statusMessage = OpsRefusalCopy.message(for: error)
        }
    }

    /// 13c Stage 1 ladder, R2-2 (her A13(a) named Compare explicitly): the
    /// callout door on the FOCUSED pane's block, through the one shared
    /// transform. Compare's panes have carried a live block since 4C, and
    /// a pane knows its own post — so the frame lands on the block she is
    /// looking at, whichever column it lives in.
    func applyCallout(_ edit: CalloutEdit) async {
        guard let pane = authority.livePane else {
            statusMessage = "Click into a pane first — the frame goes on that block."
            return
        }
        statusMessage = nil
        do {
            try await session.runner.run { ops in
                try ops.updateBlockPresentation(pane.blockID) {
                    CalloutEditRule.apply(edit, to: $0)
                }
            }
        } catch {
            statusMessage = OpsRefusalCopy.message(for: error)
        }
    }
}

// MARK: - The board

struct CompareBoardView: View {
    let session: AppSession
    let postID: String
    @State private var model: CompareViewModel
    @State private var diffPresentation: TakesDiffPresentation?
    /// The drop indicator's target (the BookView idiom).
    @State private var dropTargetBlockID: String?
    @State private var dropAtEndPostID: String?
    /// 13b 4D (the 4C handoff): the routed-command registration's token —
    /// Compare now handles `.commit` (and ONLY that; everything else falls
    /// through to the router's honest note — its editing stays direct
    /// manipulation, the canvas-switcher class).
    @State private var commandToken: UUID?
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    /// The drag payload ("compare-move:<postID>:<blockID>") — post-scoped
    /// so a drop can refuse crossing columns before any op runs.
    static func dragPayload(postID: String, blockID: String) -> String {
        "compare-move:\(postID):\(blockID)"
    }

    static func parseDragPayload(_ raw: String) -> (postID: String, blockID: String)? {
        let parts = raw.split(separator: ":", maxSplits: 2).map(String.init)
        guard parts.count == 3, parts[0] == "compare-move" else { return nil }
        return (parts[1], parts[2])
    }

    init(session: AppSession, postID: String, model: CompareViewModel? = nil) {
        self.session = session
        self.postID = postID
        _model = State(initialValue: model
            ?? CompareViewModel(session: session, anchorPostID: postID))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            columnHeaders
            if model.peerSlots.allSatisfy({ $0.postID == nil }) {
                emptyState
            } else {
                boardRows
            }
        }
        .background(tokens.surface)
        .task { await model.start() }
        .onAppear {
            // 13b 4D (the 4C handoff): ⌘S acts where it's advertised — the
            // one routed command this board consumes; the rest return
            // false and keep falling through (compare's editing is direct
            // manipulation — the recorded 4C reading stands).
            commandToken = session.commandRouter.registerHandler { command in
                switch command {
                case .commit:
                    Task { await model.commitFocusedTake() }
                    return true
                case .callout(let edit):
                    // 13c R2-2 (A13(a) named Compare): the focused pane's
                    // block takes the frame. Everything else keeps falling
                    // through — compare's editing is direct manipulation
                    // (the recorded 4C reading stands).
                    Task { await model.applyCallout(edit) }
                    return true
                default:
                    return false
                }
            }
        }
        .onDisappear {
            if let commandToken {
                session.commandRouter.unregisterHandler(commandToken)
            }
            model.teardown()
        }
        .sheet(item: $diffPresentation) { diff in
            DiffView(
                leftTitle: diff.leftTitle, rightTitle: diff.rightTitle,
                leftText: diff.left, rightText: diff.right)
        }
    }

    // MARK: Header (board-level)

    private var header: some View {
        HStack(spacing: 8) {
            VoicedChip(
                tokens: tokens,
                text: model.followAnchorOrder ? "follow this post's order: on" : "follow this post's order: off",
                on: model.followAnchorOrder
            ) { model.followAnchorOrder.toggle() }
                .help("On: the other columns arrange themselves to sit beside their related "
                    + "blocks, in this post's order (display only — nothing is moved). "
                    + "Off: every column flows in its own post's order.")
            VoicedChip(
                tokens: tokens,
                text: model.lineageColorsOn ? "lineage colors: on" : "lineage colors: off",
                on: model.lineageColorsOn
            ) { model.lineageColorsOn.toggle() }
                .help("Color rails mark related blocks across the columns — the same color "
                    + "means the same origin. Rails only appear where a real relationship exists.")
            Spacer()
            Button(tokens.chromeLabel("make outline post")) {
                Task { await model.makeOutlinePost() }
            }
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary, font: tokens.mono))
            .help("A linked copy named \u{201C}outline of \u{2026}\u{201D} — each block starts as this "
                + "post's first sentence per block; it opens beside the post here, "
                + "registered block-by-block (R99 — the retired Outline tab's power, re-homed)")
            if model.peerSlots.count < 3 {
                Button(tokens.chromeLabel("+ post")) { model.addPeerSlot() }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet, font: tokens.mono))
                    .help("Open another post beside these (compare holds up to four)")
            }
        }
        .controlSize(.small)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }

    // MARK: Column headers

    private var columnHeaders: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(model.projection.anchor.title ?? "This post")
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                if model.projection.anchor.sealed {
                    Text(tokens.chromeLabel("sealed — read-only"))
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            ForEach(model.peerSlots) { slot in
                peerHeader(slot)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .controlSize(.small)
        .padding(.horizontal, 12)
        .padding(.bottom, 4)
    }

    @ViewBuilder
    private func peerHeader(_ slot: CompareViewModel.PeerSlot) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Picker("Compare with", selection: Binding(
                    get: { slot.postID },
                    set: { model.setPeer(slotID: slot.id, postID: $0) })
                ) {
                    Text("Choose a post…").tag(String?.none)
                    if !model.projection.versionPeers.isEmpty {
                        Section("Versions of this post") {
                            ForEach(model.projection.versionPeers, id: \.self) { id in
                                Text(peerTitle(id)).tag(String?.some(id))
                            }
                        }
                    }
                    Section("Recent posts") {
                        ForEach(model.peerCandidates, id: \.postID) { item in
                            Text(item.title?.isEmpty == false ? item.title! : "Untitled")
                                .tag(String?.some(item.postID))
                        }
                    }
                }
                .labelsHidden()
                .fixedSize()
                Button("✕") { model.removePeerSlot(slot.id) }
                    .buttonStyle(.plain)
                    .foregroundStyle(tokens.muted)
                    .help("Close this column (the post itself is untouched)")
            }
            if let peerID = slot.postID {
                relationshipLine(peerID)
                HStack(spacing: 6) {
                    if model.isVersionPeer(peerID) {
                        Button("Unmark") { model.unmarkVersions(peerID) }
                            .help("These two stop being versions of each other — the link deletes, "
                                + "both posts stay exactly as they are (Sitting 9, R60)")
                    } else {
                        Button("Mark as Versions") { model.markAsVersions(peerID) }
                            .help("Says 'these two posts are versions of the same piece' — a "
                                + "connection, not a copy. Blocks align side-by-side where LINEAGE "
                                + "connects them; two unrelated posts you hand-link only pair "
                                + "loosely. Unmarkable any time.")
                    }
                    Button("Diff") { presentDiff(peerID) }
                        .help("Line diff of the two posts' rendered text — savable to a file")
                }
                if model.face(for: peerID)?.sealed == true {
                    Text(tokens.chromeLabel("sealed — read-only"))
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                }
            }
        }
    }

    /// N29's honesty line, per peer: say what the relationship IS.
    @ViewBuilder
    private func relationshipLine(_ peerID: String) -> some View {
        if !model.isRelated(peerID) {
            Text(tokens.chromeLabel("there is no relationship here"))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .help("No lineage and no version link connects these posts — they render "
                    + "plainly side by side, each in its own order, no rails, no blanks.")
        } else if model.isVersionPeer(peerID), !model.hasLineage(peerID) {
            Text(tokens.chromeLabel("versions · no shared lineage — loose alignment"))
                .font(tokens.small)
                .foregroundStyle(tokens.accent)
        } else if model.isVersionPeer(peerID) {
            Text(tokens.chromeLabel("versions"))
                .font(tokens.small)
                .foregroundStyle(tokens.accent)
        } else {
            Text(tokens.chromeLabel("linked by lineage"))
                .font(tokens.small)
                .foregroundStyle(tokens.accent)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Spacer()
            Text("Pick a post to compare against — version peers appear first.")
                .foregroundStyle(tokens.muted)
            Text("Or mint an outline of this post — it opens right here, beside it.")
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Rows

    private var boardRows: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                ForEach(model.rows) { row in
                    rowView(row)
                }
                endDropZones
            }
            .padding(12)
        }
    }

    @ViewBuilder
    private func rowView(_ row: CompareRow) -> some View {
        HStack(alignment: .top, spacing: 8) {
            switch row {
            case .free(let anchor, let peers, _):
                cellOrSpace(postID: postID, blockID: anchor)
                ForEach(Array(model.peerSlots.enumerated()), id: \.element.id) { i, slot in
                    cellOrSpace(
                        postID: slot.postID,
                        blockID: i < peers.count ? peers[i] : nil)
                }
            case .aligned(let aligned):
                cellOrSpace(postID: postID, blockID: aligned.anchorBlockID)
                ForEach(Array(model.peerSlots.enumerated()), id: \.element.id) { i, slot in
                    VStack(alignment: .leading, spacing: 4) {
                        if i < aligned.peerMoved.count, aligned.peerMoved[i],
                           !aligned.peerKin[i].isEmpty {
                            Text("moved (order differs in this version)")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                        }
                        if i < aligned.peerKin.count {
                            ForEach(aligned.peerKin[i], id: \.self) { kinBlock in
                                cellOrSpace(postID: slot.postID, blockID: kinBlock)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }
            }
        }
    }

    /// A column's cell — or clear SPACE where this column has nothing in
    /// this row (never a "—" blank marker; N29).
    @ViewBuilder
    private func cellOrSpace(postID: String?, blockID: String?) -> some View {
        if let postID, let blockID, let slot = model.slot(postID: postID, blockID: blockID) {
            CompareCellView(
                model: model, tokens: tokens,
                postID: postID, slot: slot,
                dropTargetBlockID: $dropTargetBlockID)
                .frame(maxWidth: .infinity, alignment: .topLeading)
        } else {
            Color.clear
                .frame(maxWidth: .infinity, minHeight: 1)
        }
    }

    /// The per-column end drop zones ("move to the end of this post").
    private var endDropZones: some View {
        HStack(alignment: .top, spacing: 8) {
            endDropZone(postID: postID)
            ForEach(model.peerSlots) { slot in
                if let peerID = slot.postID {
                    endDropZone(postID: peerID)
                } else {
                    Color.clear.frame(maxWidth: .infinity).frame(height: 1)
                }
            }
        }
    }

    private func endDropZone(postID zonePostID: String) -> some View {
        VStack(spacing: 2) {
            if dropAtEndPostID == zonePostID {
                Rectangle().fill(tokens.ring).frame(height: 2)
            }
            Color.clear.frame(height: 12)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .dropDestination(for: String.self) { items, _ in
            guard let raw = items.first,
                  let payload = Self.parseDragPayload(raw) else { return false }
            guard payload.postID == zonePostID else {
                model.speak(
                    "Order drags stay within one post here — each column reorders its own post.")
                return false
            }
            Task {
                await model.moveBlock(payload.blockID, inPost: zonePostID, before: nil)
            }
            return true
        } isTargeted: { targeted in
            if targeted {
                dropAtEndPostID = zonePostID
            } else if dropAtEndPostID == zonePostID {
                dropAtEndPostID = nil
            }
        }
    }

    // MARK: Diff (N33's sheet rides DiffView's own save door)

    private func presentDiff(_ peerID: String) {
        guard let peer = model.face(for: peerID) else { return }
        let anchor = model.projection.anchor
        diffPresentation = TakesDiffPresentation(
            leftTitle: anchor.title ?? "this post",
            rightTitle: peer.title ?? "other post",
            left: Queries.joinRenderedTexts(
                anchor.slots.compactMap(\.text).filter { !$0.isEmpty }),
            right: Queries.joinRenderedTexts(
                peer.slots.compactMap(\.text).filter { !$0.isEmpty }))
    }

    private func peerTitle(_ id: String) -> String {
        model.peerCandidates.first { $0.postID == id }?.title ?? "Version"
    }
}

// MARK: - One cell

/// One compare cell: a fully editable pane over the one authority, with
/// its rail (only where lineage speaks), its drag handle (reorders ITS
/// post only), and the in-cell fan bloom (✓ stays the one choosing door).
private struct CompareCellView: View {
    let model: CompareViewModel
    let tokens: VoiceTokens
    let postID: String
    let slot: Queries.RenderedBlock
    @Binding var dropTargetBlockID: String?

    var body: some View {
        if let resolved = model.resolvedText(postID: postID, slot: slot) {
            let sealed = model.face(for: postID)?.sealed == true
            let key = PaneTextAuthority.PaneKey(
                columnID: "compare-\(postID)", blockID: slot.blockID,
                variantID: resolved.variantID, context: postID)
            VStack(alignment: .leading, spacing: 2) {
                if dropTargetBlockID == slot.blockID {
                    Rectangle().fill(tokens.ring).frame(height: 2)
                }
                HStack(alignment: .top, spacing: 4) {
                    rail
                    Text("⠿")
                        .font(tokens.small)
                        .foregroundStyle(tokens.faint)
                        .help("Drag to reorder this block within its own post")
                        .draggable(CompareBoardView.dragPayload(
                            postID: postID, blockID: slot.blockID))
                    VStack(alignment: .leading, spacing: 2) {
                        if slot.hasFan {
                            Button("⑂\(slot.activeVariantCount)") {
                                model.toggleExpanded(slot.blockID)
                            }
                            .buttonStyle(.plain)
                            .font(tokens.small)
                            .foregroundStyle(tokens.accent)
                            .help("This block's takes — open them right here; ✓ chooses")
                        }
                        PaneSurfaceView(
                            text: resolved.text,
                            isLive: model.authority.isLive(key, sealed: sealed),
                            tokens: tokens,
                            role: "compare", variantID: resolved.variantID,
                            onFocusRequest: { model.focus(key) },
                            onEdit: {
                                model.paneEdited(
                                    postID: postID, variantID: resolved.variantID,
                                    newText: $0)
                            })
                        if model.expandedBlocks.contains(slot.blockID) {
                            bloomedFan(chosenVariantID: slot.variantID)
                        }
                    }
                }
            }
            .contentShape(Rectangle())
            .dropDestination(for: String.self) { items, _ in
                guard let raw = items.first,
                      let payload = CompareBoardView.parseDragPayload(raw) else { return false }
                guard payload.postID == postID else {
                    model.speak(
                        "Order drags stay within one post here — each column reorders its own post.")
                    return false
                }
                Task {
                    await model.moveBlock(
                        payload.blockID, inPost: postID, before: slot.blockID)
                }
                return true
            } isTargeted: { targeted in
                if targeted {
                    dropTargetBlockID = slot.blockID
                } else if dropTargetBlockID == slot.blockID {
                    dropTargetBlockID = nil
                }
            }
        }
    }

    @ViewBuilder
    private var rail: some View {
        if let kin = model.railKin(postID: postID, blockID: slot.blockID) {
            LineageStripe(blockID: kin)
        } else {
            Color.clear.frame(width: 4)
        }
    }

    /// The in-cell bloom: every take an editable pane (the one grammar),
    /// ✓ the explicit door.
    private func bloomedFan(chosenVariantID: String?) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            ForEach(model.face(for: postID)?.fans[slot.blockID] ?? [], id: \.id) { take in
                let sealed = model.face(for: postID)?.sealed == true
                let key = PaneTextAuthority.PaneKey(
                    columnID: "compare-fan-\(postID)", blockID: slot.blockID,
                    variantID: take.id, context: postID)
                HStack(alignment: .top, spacing: 4) {
                    Button("✓") {
                        Task { await model.choose(blockID: slot.blockID, variantID: take.id) }
                    }
                    .controlSize(.mini)
                    .disabled(take.id == chosenVariantID)
                    .help(take.id == chosenVariantID
                        ? "The post shows this take"
                        : "Choose this take — the post shows it everywhere")
                    PaneSurfaceView(
                        text: model.liveText(take),
                        isLive: model.authority.isLive(key, sealed: sealed),
                        tokens: tokens,
                        role: "compare-fan", variantID: take.id,
                        onFocusRequest: { model.focus(key) },
                        onEdit: {
                            model.paneEdited(
                                postID: postID, variantID: take.id, newText: $0)
                        })
                }
                .padding(.leading, 12)
            }
        }
    }
}
