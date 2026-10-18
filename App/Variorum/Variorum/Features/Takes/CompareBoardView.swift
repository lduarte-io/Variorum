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
        /// The stored title, raw (nil where the note is nameless).
        var title: String?
        /// What the note is CALLED on screen — `Queries.noteDisplayTitle`,
        /// the ONE single-note display brain (the masthead's: the title,
        /// else the note's day). The Act 10 correction round, row 17: the
        /// anchor card used to fall back to the literal "This note" for a
        /// nameless journal entry; a note's name is its day, everywhere.
        var displayTitle = ""
        var sealed = false
    }

    var anchor = PostFace()
    var peers: [String: PostFace] = [:]
    /// peerID → (peer block → its anchor kin block) — `Queries.blockKinship`
    /// verbatim, never re-derived view-side.
    var kinship: [String: [String: String]] = [:]
    /// Posts version-linked to the anchor — IN ITS OWN WING only (13i-d U5:
    /// a version that lives in another library is never offered as a note,
    /// never auto-filled, never pulled in as content — #166(e)).
    var versionPeers: [String] = []
    /// 13i-d U5 — THE LINEAGE LINE (#166(e), RULED: "it can say it was in a
    /// different wing … maybe move back to that wing for more"): the OTHER
    /// wings holding a version of this note, by id and name — named, with a
    /// plain go-to road, nothing deeper.
    var otherWingVersions: [OtherWing] = []

    struct OtherWing: Equatable {
        let id: String
        let name: String
    }
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

// MARK: - The wire's landing (VX-298)

/// **A Compare landing parked on the router** (VX-336 U6a — VX-298, the run
/// record's D-298-5): `show_in_app`'s compare target and `link_versions`'
/// receipt Open ›, delivered on the lens target's model (`MCPNavigator`): the
/// anchor opened, this parked on `CommandRouter.pendingCompareLanding`, then her
/// Compare mode requested. The board for `postID` consumes it (post-stamped — a
/// landing for another note is left alone) and shows exactly `peerIDs` beside
/// the anchor, replacing the columns open (her answer (4)). A SIGNAL with no
/// posture (P-4): the board decides "related blocks only" (F-8 (a)).
nonisolated struct CompareLanding: Equatable, Sendable {
    let postID: String
    let peerIDs: [String]
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
        self.forwarder = StatusForwarder(session.status)
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
            // 18o U4 (R-18k-6's Compare clause, PROVISIONAL #163): a peer
            // that left the board's columns — swapped out, removed — is LEFT.
            // The anchor never is (it is the pane's own note; its leaving is
            // the workspace's).
            let departed = oldValue.compactMap(\.postID)
                .filter { !picked.contains($0) && $0 != anchorPostID }
            if !departed.isEmpty { onNotesLeft(departed) }
            // VX-298 (R2-1): a NAMED peer's column leaving ends the landing's
            // round (`landingPostureFor`). `land` arms before it replaces the
            // columns, and the peers that replacement drops are never named.
            if let landed = landingPostureFor, departed.contains(where: { landed.contains($0) }) {
                landingPostureFor = nil
            }
        }
    }

    /// **The board's LEAVING signal** (18o U4, PROVISIONAL #163) — raised
    /// with the PEERS it has just stopped showing: a column swapped to another
    /// note or removed, and every peer when the board itself goes
    /// (`teardown`). Wired by `CompareBoardView` to
    /// `AppSession.savepointOnLeaving` (`SavepointOnLeave.wire(compare:)`); a
    /// no-op by default, so a board built in a test writes nothing.
    @ObservationIgnored var onNotesLeft: ([String]) -> Void = { _ in }
    /// S4-3/S4-12 — "follow this post's order": display-only lineage-tied
    /// ordering of the peer columns. SESSION-LOCAL view state (a toggle,
    /// never persisted, never a mode). Default ON — the 11a aligned
    /// promise ("the two posts sit aligned block by block") holds where
    /// lineage exists; zero-lineage pairs render plain regardless.
    var followAnchorOrder = true
    /// S4-12 — the lineage-color relationship, toggleable on/off.
    /// Session-local like the follow toggle.
    var lineageColorsOn = true
    /// 13c Batch 2E (C4) — "show related blocks only": a display FILTER
    /// collapsing every column to the blocks lineage actually connects,
    /// hiding the unrelated stretches (her words: *"that would make the pane
    /// feel more usable"*). SESSION-LOCAL view state exactly like the two
    /// toggles above — a reading posture, never persisted, no schema.
    ///
    /// **Default ON — the author's ruling at the 13c ratify walk,
    /// 2026-07-27 (QUESTIONS #47(c)).** 2E shipped it OFF on the reasoning
    /// that a filter which HIDES material should be reached for rather than
    /// arrived in; she ruled the other way, which reads her original
    /// sentence straight (*"that would make the pane feel more usable"* —
    /// the usable state is the filtered one). Compare therefore opens
    /// showing only what lineage connects, and the chip reveals the full
    /// posts.
    ///
    /// The recorded consequence, which was in front of her when she ruled:
    /// against an UNRELATED post the board now greets her with the honesty
    /// line ("there is no relationship here…") before the prose — the way
    /// out named in the same breath. Nothing else about the filter changed:
    /// its SEMANTICS, the per-column note, the filter-OFF placement and the
    /// live-ring release are 2E's, byte for byte.
    var relatedOnly = true {
        didSet {
            // VX-298 (R2-1): any set of the toggle ends a landing's round
            // (`landingPostureFor`), so a later projection never overwrites her
            // pick. The model's own two writes are ordered so this never ends a
            // round they mean to keep: `land` sets the toggle BEFORE it arms,
            // `adopt` disarms BEFORE it sets.
            landingPostureFor = nil
            guard relatedOnly != oldValue else { return }
            releaseLivePaneIfFilteredAway()
        }
    }
    /// VX-298 (D-298-5): the peers a wire LANDING named, until the first
    /// projection holding every one of them applies the landing posture
    /// (`CompareComposition.landingShowsRelatedOnly`) — once; nil afterwards,
    /// so a later projection never flips her own toggle. **The round also ends,
    /// unapplied (R2-1, the ladder's round 2), at the first of: the board's
    /// `teardown()`, a named peer's column leaving (`peerSlots`), or any set of
    /// `relatedOnly` — so a named peer that never projects leaves nothing
    /// armed to flip her toggle long after the landing.**
    @ObservationIgnored private var landingPostureFor: [String]?
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
            // 18i (her R-Q5): the forward carries a KIND, named by the door
            // that is writing and RESET after each delivery — so every bare
            // `statusMessage = …` assignment here (refusals and errors, all
            // of them) is byte-unchanged. The rule lives ONCE, in
            // `StatusForwarder` beside the centre (J30).
            forwarder.deliver(statusMessage)
        }
    }

    /// The one home for the forward's rule (18i — J30).
    @ObservationIgnored private var forwarder: StatusForwarder

    /// A RECEIPT: an act landed, and this says what. Where it shows is her
    /// setting's answer; the words are untouched.
    func showReceipt(_ message: String) {
        forwarder.outgoing = .receipt
        statusMessage = message
    }

    // MARK: Coordinators (per post — the N3 boundary)

    @ObservationIgnored private var coordinatorTokens: [String: UUID] = [:]
    /// The coordinators this board HOLDS — one acquisition per post, kept
    /// until `teardown()` lets go of them (or the model dies holding them).
    /// 18k C1: `coordinator(for:)` used to call `session.autosave(forPost:)`
    /// on EVERY call — each projection's dirty check, each settle, each
    /// keystroke — and once more per post inside `teardown()`, so a board
    /// held hundreds of acquisitions nothing could ever give back.
    @ObservationIgnored private var coordinators: [String: AutosaveCoordinator] = [:]

    /// The per-post coordinator, acquired and observation-registered exactly
    /// once per post. Two or more coordinators live at once is compare's
    /// DESIGNED shape (one per post context; the 1a consolidation's boundary
    /// is per post).
    private func coordinator(for postID: String) -> AutosaveCoordinator {
        if let held = coordinators[postID] { return held }
        let coordinator = session.autosave(forPost: postID)
        coordinators[postID] = coordinator
        coordinatorTokens[postID] = coordinator.observe(
            onError: { [weak self] error in
                self?.statusMessage = OpsRefusalCopy.message(for: error)
            },
            onSettled: { [weak self] in self?.settleIfClean() })
        return coordinator
    }

    /// **18k C1 — whatever the board still holds when it dies goes back.**
    /// `teardown()` is the ordinary letting-go (flush, then release); this is
    /// for the model that never saw it — the discarded twin SwiftUI builds on
    /// a re-init of `CompareBoardView` (its `init` acquires the anchor), or a
    /// board that was never mounted. Nothing records through it after it dies.
    isolated deinit {
        for postID in coordinators.keys { session.releaseAutosave(forPost: postID) }
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
            // 13i-d U5: Compare offers the ANCHOR's own wing (§9 — never a
            // note of another library).
            let wing = (try? await session.database.read { db in
                try Queries.effectiveWing(db, ofPost: anchorID)
            }) ?? nil
            for try await items in session.database.observeLibrary(
                sort: .lastTouched, direction: .desc, limit: 100,
                wingID: wing ?? session.wing.currentID
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
                displayTitle: try Queries.noteDisplayTitle(db, id: id) ?? DisplayTitle.placeholder,
                sealed: try Queries.containerHeader(db, containerID: id)?.locked == true)
        }
        var peers: [String: CompareProjection.PostFace] = [:]
        var kinship: [String: [String: String]] = [:]
        for peerID in peerIDs {
            peers[peerID] = try face(peerID)
            kinship[peerID] = try Queries.blockKinship(db, anchor: anchorID, other: peerID)
        }
        let split = try Queries.versionPeerSplit(db, of: anchorID)
        return CompareProjection(
            anchor: try face(anchorID),
            peers: peers,
            kinship: kinship,
            versionPeers: split.sameWing,
            otherWingVersions: try split.otherWings.map { id in
                CompareProjection.OtherWing(
                    id: id, name: try Queries.wingName(db, id: id, home: WingWords.home)
                        ?? WingWords.home)
            })
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
        // VX-298 (D-298-4/5, F-9 (a) — PROVISIONAL P-VX298-1): a wire landing's
        // posture, from the board's OWN projection (F-8 (a) — the kinship it
        // computes to draw the rows anyway), once the projection holds every
        // landed peer: ON only when EVERY named peer shares lineage with the
        // anchor, else OFF — no column the AI named opens filtered empty.
        if let landed = landingPostureFor, landed.allSatisfy({ new.peers[$0] != nil }) {
            landingPostureFor = nil
            relatedOnly = CompareComposition.landingShowsRelatedOnly(
                peerKinships: landed.map { new.kinship[$0] ?? [:] })
        }
    }

    // MARK: The wire's landing (VX-298 — D-298-5)

    /// The router's parked Compare landing, consumed if it is THIS note's
    /// (post-stamped — a landing for another note is left alone; the Lenses
    /// board's `consumePendingLensLanding` pattern).
    func consumePendingCompareLanding() {
        guard let landing = session.commandRouter.pendingCompareLanding, landing.postID == anchorPostID else { return }
        session.commandRouter.pendingCompareLanding = nil
        land(peers: landing.peerIDs)
    }

    /// **The board shows exactly what was named** (her answer (4)): the peer
    /// columns REPLACED by `peers`, in order — the auto-default never refills
    /// them; a departing column's live pane released first (4C's NIT-1 — the
    /// ring never stays on a pane nothing renders, and that post's typing
    /// flushes through its own coordinator); the departed peers leave through
    /// the board's own leaving road (`peerSlots.didSet` → `onNotesLeft`, 18o
    /// U4). "Related blocks only" goes OFF while the lineage is read (nothing
    /// named is hidden); `adopt` applies the landing posture once. The board's
    /// own slot API only: at most three peers, never the anchor, each once.
    func land(peers: [String]) {
        var named: [String] = []
        for peer in peers where peer != anchorPostID && !named.contains(peer) && named.count < 3 {
            named.append(peer)
        }
        guard !named.isEmpty else { return }
        autoFilled = true
        for departing in peerSlots.compactMap(\.postID) where !named.contains(departing) {
            releaseLivePane(leavingPost: departing)
        }
        relatedOnly = false
        landingPostureFor = named
        peerSlots = named.map { PeerSlot(postID: $0) }
    }

    func teardown() {
        observation?.cancel()
        // VX-298 (R2-1): the board going ends a landing's round, unapplied.
        landingPostureFor = nil
        for (postID, token) in coordinatorTokens {
            coordinators[postID]?.stopObserving(token)
        }
        coordinatorTokens = [:]
        // 18o U4 (PROVISIONAL #163): the board going is a leaving for every
        // peer it was showing — never for the anchor, whose leaving is the
        // workspace's (a mode switch away from Compare is not one). Reported
        // before the holds go back; either order ends the same (18k C1: the
        // last release of a LEFT note re-takes its savepoint).
        let peers = peerSlots.compactMap(\.postID).filter { $0 != anchorPostID }
        if !peers.isEmpty { onNotesLeft(peers) }
        // 18k C1: let go of every post this board held — flush first, then
        // exactly one release per acquisition. A board reused after this
        // (a host keeping it across `onDisappear`) re-acquires on its next
        // touch through `coordinator(for:)`, which a later teardown pairs.
        let held = coordinators
        coordinators = [:]
        let session = session
        Task {
            for coordinator in held.values { await coordinator.flushNow() }
            for postID in held.keys { session.releaseAutosave(forPost: postID) }
        }
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

    /// What the board renders this pass. ONE computation the view reads
    /// ONCE (13c 2E): the rows and the per-column honesty notes come from
    /// the same filtered inputs, so the board can never disagree with itself
    /// about what is on screen.
    struct Display: Equatable {
        var rows: [CompareRow] = []
        /// True while "related blocks only" is filtering (2E).
        var isFiltered = false
        var anchorHasBlocks = false
        /// Per peer SLOT, in column order.
        var peerHasBlocks: [Bool] = []
    }

    /// The composition's inputs, after 2E's filter. Column order is stable:
    /// the anchor, then the peer slots (a nil slot contributes an empty
    /// column so headers and cells stay aligned).
    private var compositionInputs:
        (anchor: [String], peers: [[String]], kinships: [[String: String]])
    {
        let peerIDs = peerSlots.map(\.postID)
        let anchor = projection.anchor.slots.filter { !$0.isGap }.map(\.blockID)
        let peers = peerIDs.map { id -> [String] in
            guard let id, let face = projection.peers[id] else { return [] }
            return face.slots.filter { !$0.isGap }.map(\.blockID)
        }
        let kinships = peerIDs.map { id -> [String: String] in
            guard let id else { return [:] }
            return projection.kinship[id] ?? [:]
        }
        guard relatedOnly else { return (anchor, peers, kinships) }
        // **The Act 10 correction round, row 17 — the ANCHOR is EXEMPT from
        // the filter** (R-cor-6's in-round scope: "the anchor column always
        // rendering the note"). 13c 2E collapsed EVERY column — the anchor
        // included — to lineage-connected blocks BY DESIGN, and her #47(c)
        // ruling made the filter default-on; together they greeted her with
        // an EMPTY first column whenever no peer had kin ("'This note' is
        // showing nothing"). This is a RULED narrowing of 2E's anchor half,
        // not a regression: the PEERS stay filtered by kinship against the
        // anchor exactly as before (the pure brain and its pins are
        // byte-unmodified), and the anchor's blocks are handed through WHOLE
        // — the composition arranges the kin rows and lets the anchor's
        // unrelated stretches flow with empty peer cells. The brain's "the
        // anchor is empty exactly when every peer is" invariant is no longer
        // what this model relies on.
        let kept = CompareComposition.relatedOnly(
            anchorBlocks: anchor, peerBlocks: peers, kinships: kinships)
        // The kinship map rides UNFILTERED: `segments` only ever consults it
        // for blocks it is handed, and every surviving peer block's kin is an
        // anchor block the whole anchor column shows.
        return (anchor, kept.peerBlocks, kinships)
    }

    var display: Display {
        let inputs = compositionInputs
        return Display(
            rows: composedRows(inputs),
            isFiltered: relatedOnly,
            anchorHasBlocks: !inputs.anchor.isEmpty,
            peerHasBlocks: inputs.peers.map { !$0.isEmpty })
    }

    /// The board's rows (the view reads `display`; this stays the direct
    /// accessor the pins and any single-purpose caller use).
    var rows: [CompareRow] { composedRows(compositionInputs) }

    private func composedRows(
        _ inputs: (anchor: [String], peers: [[String]], kinships: [[String: String]])
    ) -> [CompareRow] {
        let segments = CompareComposition.segments(
            anchorBlocks: inputs.anchor,
            peerBlocks: inputs.peers,
            kinships: inputs.kinships,
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

    /// 13c Batch 2E: turning "related blocks only" ON can hide the very
    /// block the live ring sits in. **The precedent is 4C's NIT-1** (a
    /// closed column hosting the live pane): the ring never stays on a pane
    /// nothing renders — blur, and flush THAT post's own coordinator so what
    /// she typed LANDS in the store instead of sitting in a buffer no
    /// surface shows.
    ///
    /// It **speaks**, because a caret disappearing without a word is exactly
    /// the silent-door class 13b retired. The alternative considered —
    /// REFUSING the toggle while a pane is live ("close the block you're
    /// writing in first") — is lecture-and-redirect by another name (P-2):
    /// a view toggle that stops working because you happen to be typing is
    /// the friction this phase exists to remove, and it would refuse most
    /// often exactly when she is deep in a comparison.
    ///
    /// Scoped to the TOGGLE deliberately. A projection change can also hide
    /// the live pane's block (a block deleted in another window), but that
    /// is the pre-existing 4C class — unguarded today, and calling this per
    /// observation delivery would both cost a filter pass per delivery and
    /// invent a new way for the ring to drop mid-typing. Recorded, not
    /// widened.
    private func releaseLivePaneIfFilteredAway() {
        guard let pane = authority.livePane else { return }
        let postID = pane.context.isEmpty ? anchorPostID : pane.context
        let inputs = compositionInputs
        let stillVisible: Bool
        if postID == anchorPostID {
            stillVisible = inputs.anchor.contains(pane.blockID)
        } else if let index = peerSlots.firstIndex(where: { $0.postID == postID }),
                  index < inputs.peers.count {
            stillVisible = inputs.peers[index].contains(pane.blockID)
        } else {
            stillVisible = false
        }
        guard !stillVisible else { return }
        authority.blur()
        let coordinator = coordinator(for: postID)
        Task { await coordinator.flushNow() }
        statusMessage =
            "\u{201C}Related blocks only\u{201D} hid the block you were writing in — your "
            + "text is saved. Turn it off to go back to it."
    }

    func setPeer(slotID: String, postID: String?) {
        autoFilled = true
        guard let index = peerSlots.firstIndex(where: { $0.id == slotID }) else { return }
        if let postID,
           postID == anchorPostID
               || peerSlots.contains(where: { $0.postID == postID && $0.id != slotID }) {
            statusMessage = "That note is already open in this compare."
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

    /// The Act 10 correction round, row 46 (ONE placement per act): the
    /// add-a-column door shows only while EVERY slot is filled and a slot
    /// remains. An EMPTY slot's dashed "＋ choose a note" IS the add door
    /// until then, so the two never stand together.
    var addNoteDoorShows: Bool {
        peerSlots.count < 3 && !peerSlots.contains { $0.postID == nil }
    }

    /// The offer band's state: no peer is open anywhere — the two offer
    /// cards (and the note's version peers as direct rows) show; the header's
    /// own outline door yields to the card (row 46 — one placement at a time).
    var noPeerIsOpen: Bool {
        peerSlots.allSatisfy { $0.postID == nil }
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
                "Order drags stay within one note here — each column reorders its own note."
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
                    "Reordered. This column is following the first note's order right now — "
                    + "the new order shows with \u{201C}follow this note's order\u{201D} off."
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
                        "Marked as versions — a connection, nothing copied. These notes share "
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
                    "Unmarked — the notes are no longer versions of each other (both untouched; re-mark any time)."
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
    func refuse(_ message: String) {
        statusMessage = message
    }

    /// 13b 4D (the 4C handoff — judgment call 4's recorded one-gate
    /// upgrade, built): ⌘S in Compare commits the FOCUSED pane's take
    /// through the authority (the N5 letter extended to the new editable
    /// surface). The flush routes through the pane's OWN post's
    /// coordinator (the cross-context handback's rule); no focus speaks.
    /// **THE COMMIT DOOR'S PENDING NAME** (13u3 UNIT D — item 14): the
    /// board's header presents it, since this board renders no commit door
    /// of its own (⌘S is its whole commit road). **VX-347:** the presenter
    /// decides what leaving the field means (every leave but ⎋ files).
    var savepointAsk: SavepointNameAsk?

    /// ⌘S — the DOOR. It summons the optional name; leaving the field any
    /// way but ⎋ files it (VX-347); no live pane refuses HERE (P-2).
    func askSavepointName() {
        // VX-347: ⌘S again while its field is up LEAVES the field — and
        // every leave but ⎋ files it (PROVISIONAL P-VX347-2). No second field.
        if savepointAsk != nil {
            savepointAsk = nil
            return
        }
        guard let pane = authority.livePane else {
            statusMessage = "Click into a pane first — ⌘S commits the take you're in."
            return
        }
        // 13u3 ladder round 1, R1-3 (the widen): `livePane` is the raw
        // pointer, and Compare crosses posts — the seal that matters is the
        // PANE's own post's (`pane.context`), read off the face this board
        // already renders "sealed — read-only" from. Same sentence as the
        // post-⏎ road's.
        //
        // A nil face FAILS OPEN, deliberately (the sanity pass's S-4): a
        // pane whose post has left the board (or is mid-projection-swap) is
        // an UNKNOWN, and a door never refuses on ignorance — the filer
        // still refuses if the post really is sealed, which is the shipped
        // post-⏎ road unchanged. The three sibling doors have no unknown
        // state, so this clause is this door's alone.
        guard face(for: pane.context)?.sealed != true else {
            statusMessage = OpsRefusalCopy.message(
                for: OperationError.lockedPost(id: pane.context))
            return
        }
        // The pane's own post rides the ask, so the filer flushes THAT
        // post's coordinator even after the live pane has moved (VX-347).
        savepointAsk = .naming(variantID: pane.variantID, context: pane.context)
    }

    /// ⏎ on the PENDING field (the pins' road to the field's ⏎).
    func fileSavepoint(named name: String?) async {
        guard let ask = savepointAsk else { return }
        await fileSavepoint(ask, named: name)
    }

    /// **A LEFT FIELD FILES ITS ASK** (VX-347): the pane take ⌘S ASKED
    /// about (`ask.targetID`, flushed through `ask.context`'s coordinator),
    /// never the live pane at filing time — a click away into another
    /// column is a way of leaving, and it moves the pane.
    func fileSavepoint(_ ask: SavepointNameAsk, named name: String?) async {
        if savepointAsk == ask { savepointAsk = nil }
        await commitTake(ask.targetID, inPost: ask.context, named: name)
    }

    func commitFocusedTake(named name: String? = nil) async {
        guard let pane = authority.livePane else {
            statusMessage = "Click into a pane first — ⌘S commits the take you're in."
            return
        }
        await commitTake(pane.variantID, inPost: pane.context, named: name)
    }

    /// The filing itself, for the take (and its post) it is told.
    private func commitTake(_ variantID: String, inPost context: String, named name: String?) async {
        let postID = context.isEmpty ? anchorPostID : context
        await coordinator(for: postID).flushNow()
        statusMessage = nil
        do {
            try await session.runner.run { ops in
                _ = try ops.commit(variantID, message: name)
            }
            showReceipt(name.map(SavepointNameCopy.filed) ?? SavepointNameCopy.unnamedReceipt)
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
    /// 13f batch 3 (W16): the peer column's OPEN door — a `.surface` act
    /// (its target is the column you point at), declared here and walked
    /// like every other surface door (declared ⇔ rendered).
    static let surfaceCapabilities: [CapabilityID] = [.openPeerPost]

    /// The Act 10 correction round, row 16: the board's ONE horizontal inset
    /// — the toolbar, the header strip, the offer band and the rows all lead
    /// at this edge (the toolbar sat at 16, the cards at 12, the offers
    /// centered — her "horribly misaligned").
    static let boardInset: CGFloat = 12
    /// The board's own coordinate space (the DEBUG geometry oracle's).
    static let boardSpace = "compare-board"

    let session: AppSession
    let postID: String
    @State private var model: CompareViewModel
    @State private var diffPresentation: TakesDiffPresentation?
    /// Wave 2c (item 15): which peer SLOT is choosing a note — the item-14
    /// searchable picker replaces the flat dropdown enumeration.
    @State private var pickingSlot: SlotPick?

    struct SlotPick: Identifiable {
        let id: String  // the peer slot's id
    }
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
    /// 17o batch c (her U-7): the editing indicator this surface pushes
    /// into every pane it composes — ONE resolution, in `ThemeStore`.
    private var indicator: EditingIndicatorStyle {
        ThemeStore.editingIndicator(of: themeStore)
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
        // ONE display computation per pass (13c 2E): the rows and the
        // per-column honesty notes read the same filtered inputs.
        let display = model.display
        return VStack(alignment: .leading, spacing: 0) {
            header
            columnHeaders(display)
            // Row 17: the anchor's rows render in EVERY state. The offer
            // cards used to render INSTEAD of the rows whenever no peer was
            // open — the second mechanism behind "'This note' is showing
            // nothing" (the filter was the first). They are a BAND under the
            // header strip now, and the note reads whole beneath them.
            if model.noPeerIsOpen {
                offerBand
            }
            if display.isFiltered, display.rows.isEmpty {
                // With the anchor exempt from the filter this fires only for
                // a BLOCKLESS anchor — the honesty line is still true there
                // (nothing can relate to a note with no blocks).
                nothingRelatedState
            } else {
                boardRows(display)
            }
        }
        .background(tokens.surface)
        .coordinateSpace(name: Self.boardSpace)
        .compareGeometryProbe(.board)
        // Row 50: ABOVE `.board`'s own probe, so the board's frame reports
        // into this session's scope too — an environment set below a
        // modifier does not reach it.
        .debugProbeScope(session)
        .task { await model.start() }
        .onAppear {
            // 18o U4 (PROVISIONAL #163): the board's peers leave through the
            // one leaving road.
            SavepointOnLeave.wire(compare: model, session: session)
            // VX-298 (D-298-5): a parked wire landing (show_in_app's compare
            // target / link_versions' Open ›) — the Lenses board's pattern.
            model.consumePendingCompareLanding()
            // 13b 4D (the 4C handoff): ⌘S acts where it's advertised — the
            // one routed command this board consumes; the rest return
            // false and keep falling through (compare's editing is direct
            // manipulation — the recorded 4C reading stands).
            commandToken = session.commandRouter.registerHandler { command in
                switch command {
                case .commit:
                    // 13u3 UNIT D: ⌘S summons the optional name (the header
                    // hosts the field — this board renders no commit door).
                    model.askSavepointName()
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
        // VX-298: a landing parked while this board is already mounted.
        .onChange(of: session.commandRouter.pendingCompareLanding) { _, _ in
            model.consumePendingCompareLanding()
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
                leftText: diff.left, rightText: diff.right, tokens: tokens)
        }
        // Wave 2c (item 15): the ONE searchable picker (item 14's
        // component, its recorded 2c seam) — version peers ranked first,
        // each wearing the honest mark; a snippet + day per row so five
        // same-day notes are tellable apart.
        .sheet(item: $pickingSlot) { pick in
            NotePickerSheet(
                tokens: tokens,
                title: "Compare with",
                prompt: "search notes",
                source: .corpusNotes(
                    session: session, excluding: postID,
                    versionPeersOf: postID,
                    peerAnnotation: "version of this note"),
                onPick: { row in
                    model.setPeer(slotID: pick.id, postID: row.id)
                })
        }
    }

    // MARK: Header (board-level)

    private var header: some View {
        // Row 16: ONE baseline across the toolbar's controls; the board's
        // one inset (the chips sat at 16 while the cards sat at 12).
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            VoicedChip(
                tokens: tokens,
                text: model.followAnchorOrder ? "follow this note's order: on" : "follow this note's order: off",
                on: model.followAnchorOrder
            ) { model.followAnchorOrder.toggle() }
                .help("On: the other columns arrange themselves to sit beside their related "
                    + "blocks, in this note's order (display only — nothing is moved). "
                    + "Off: every column flows in its own note's order.")
                .compareGeometryProbe(.toolbarLead)
            VoicedChip(
                tokens: tokens,
                text: model.lineageColorsOn ? "lineage colors: on" : "lineage colors: off",
                on: model.lineageColorsOn
            ) { model.lineageColorsOn.toggle() }
                .help("Color rails mark related blocks across the columns — the same color "
                    + "means the same origin. Rails only appear where a real relationship exists.")
            // 13c 2E (C4) — the third toggle of the same class: a way of
            // LOOKING, session-local, nothing moved or deleted.
            VoicedChip(
                tokens: tokens,
                text: model.relatedOnly ? "related blocks only: on" : "related blocks only: off",
                on: model.relatedOnly
            ) { model.relatedOnly.toggle() }
                .help("On: every column shows only the blocks lineage connects across these "
                    + "notes — the unrelated stretches are hidden. Nothing is moved or "
                    + "deleted; this is a way of looking. Off: every block shows.")
            Spacer()
            // The Act 10 correction round, row 46 — ONE placement per act.
            // The outline door renders HERE only while a peer is open; while
            // the offer band shows (no peer), its card is the one door. It
            // is not retired outright because `adopt()` auto-fills a version
            // peer, so a version-linked note (the field guide's own lesson,
            // whose text says "press make outline note in Compare's header")
            // never opens on the band — a full retire would leave that note
            // with no outline door at all. The memo's build settles its home.
            // "+ note" left this row for the END of the header strip.
            if !model.noPeerIsOpen {
                Button(tokens.chromeLabel("make outline note")) {
                    Task { await model.makeOutlinePost() }
                }
                .buttonStyle(CalmButtonStyle(tokens: tokens, compact: true))
                .help("A linked copy named \u{201C}outline of \u{2026}\u{201D} — each block starts as this "
                    + "note's first sentence per block; it opens beside the note here, "
                    + "registered block-by-block (R99 — the retired Outline tab's power, re-homed)")
            }
        }
        .controlSize(.small)
        .padding(.horizontal, Self.boardInset)
        .padding(.vertical, 8)
        // 13u3 UNIT D (item 14): the commit door's optional name hangs at
        // the header's leading edge — ⌘S is this board's only commit door,
        // so the field needs a home with a place on screen.
        //
        // **AN OVERLAY, NOT A CHILD — and the suite is why.** The first
        // version put a zero-SIZE `Color.clear` at the head of this HStack,
        // and a zero-width child still takes the stack's SPACING: the
        // toolbar's left edge moved 8 pt and `CompareLensesCorrectionTests`
        // caught it (the row-16 one-left-edge pin, measured). An overlay
        // takes no space at all, and anchors in exactly the same corner.
        .overlay(alignment: .topLeading) {
            Color.clear
                .frame(width: 0, height: 0)
                .savepointNameAsk(
                    Binding(get: { model.savepointAsk }, set: { model.savepointAsk = $0 }),
                    tokens: tokens, arrowEdge: .bottom
                ) { pending, name in
                    // VX-347: the take ⌘S ASKED about, whichever way the field was left.
                    Task { await model.fileSavepoint(pending, named: name) }
                }
        }
    }

    // MARK: Column headers

    /// Wave 2c (item 15): the column headers are CARDS — a note's identity
    /// reads as a masthead (title, relationship, acts), which is exactly
    /// how Compare tells itself apart from Lenses by structure: these
    /// columns are NOTES; a lens column never wears a relationship line.
    private func columnHeaders(_ display: CompareViewModel.Display) -> some View {
        // Row 72 (the correction round, batch G — the orchestrator's walk of
        // D): the strip's cards were UNEVEN — the anchor card two lines, a
        // peer card three plus its doors — so the strip's bottom edge
        // stepped. Every card now stretches to the strip's height with its
        // content top-aligned (`maxHeight: .infinity` inside each card,
        // resolved against the tallest sibling by the stack's vertical
        // `fixedSize`); the memo's build still settles what the cards SAY.
        HStack(alignment: .top, spacing: 8) {
            // Row 17: the derived display name — a nameless journal entry
            // shows its day, never the literal "This note".
            CompareAnchorCard(
                tokens: tokens,
                title: model.projection.anchor.displayTitle,
                sealed: model.projection.anchor.sealed)
                .frame(maxWidth: .infinity, alignment: .leading)
                .compareGeometryProbe(.anchorCard)
            ForEach(Array(model.peerSlots.enumerated()), id: \.element.id) { index, slot in
                peerHeader(
                    slot,
                    // The per-column note fires in the MIXED case — a filtered
                    // peer with no kin beside an anchor that shows (which, with
                    // the anchor exempt from the filter, is every filtered
                    // kin-less peer on a note with blocks); the board-level
                    // line covers the blockless anchor (13c 2E, narrowed by
                    // the correction round's row 17).
                    filteredEmpty: display.isFiltered && !display.rows.isEmpty
                        && slot.postID != nil
                        && !(index < display.peerHasBlocks.count && display.peerHasBlocks[index]))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .compareGeometryProbe(.peerCard(index))
            }
            // Row 46 / row 16: the add-a-column door sits at the END of the
            // column strip, at the header's height — never a floating button
            // in the toolbar — and only while no empty slot stands (an empty
            // slot's dashed door is the add door until then).
            if model.addNoteDoorShows {
                Button(tokens.chromeLabel("+ note")) { model.addPeerSlot() }
                    .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary, compact: true))
                    // P-8 (R-13u4-5's sweep, 13u4 UNIT S3): a `fixedSize` chrome label
                    // states its own line policy, so its IDEAL width can never be a
                    // wrapped one (the b6dae25 class's window-sizing hazard).
                    .lineLimit(1)
                    .fixedSize()
                    .help("Open another note beside these (compare holds up to four)")
                    .compareGeometryProbe(.addNote)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .controlSize(.small)
        .padding(.horizontal, Self.boardInset)
        .padding(.bottom, 6)
    }

    @ViewBuilder
    private func peerHeader(
        _ slot: CompareViewModel.PeerSlot, filteredEmpty: Bool = false
    ) -> some View {
        if let peerID = slot.postID {
            CalmCard(tokens: tokens) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(peerTitle(peerID))
                            .font(tokens.small.weight(.semibold))
                            .foregroundStyle(tokens.ink)
                            .lineLimit(1)
                        Spacer(minLength: 4)
                        Button(tokens.chromeLabel("swap")) { pickingSlot = SlotPick(id: slot.id) }
                            .buttonStyle(.plain)
                            .font(tokens.small)
                            .foregroundStyle(tokens.accent)
                            .help("Choose a different note for this column")
                        Button("✕") { model.removePeerSlot(slot.id) }
                            .buttonStyle(.plain)
                            .foregroundStyle(tokens.muted)
                            .help("Close this column (the note itself is untouched)")
                    }
                    relationshipLine(peerID)
                    HStack(spacing: 5) {
                        if model.isVersionPeer(peerID) {
                            Button(tokens.chromeLabel("unmark")) { model.unmarkVersions(peerID) }
                                .buttonStyle(CalmButtonStyle(tokens: tokens, compact: true))
                                .help("These two stop being versions of each other — the link "
                                    + "deletes, both notes stay exactly as they are (Sitting 9, R60)")
                        } else {
                            Button(tokens.chromeLabel("mark as versions")) {
                                model.markAsVersions(peerID)
                            }
                            .buttonStyle(CalmButtonStyle(tokens: tokens, compact: true))
                            .help("Says 'these two notes are versions of the same piece' — a "
                                + "connection, not a copy. Blocks align side-by-side where LINEAGE "
                                + "connects them; two unrelated notes you hand-link only pair "
                                + "loosely. Unmarkable any time.")
                        }
                        Button(tokens.chromeLabel("diff")) { presentDiff(peerID) }
                            .buttonStyle(CalmButtonStyle(tokens: tokens, compact: true))
                            .help("Line diff of the two notes' rendered text — savable to a file")
                        // 13f batch 3 (W16): fire-and-DO — OPEN the note in
                        // the ordinary editor; ⌥⌘[ comes straight back (P-4,
                        // the `.variorumOpenPost` channel).
                        Button(tokens.chromeLabel(CapabilityRegistry.capability(.openPeerPost).verb)) {
                            NotificationCenter.default.post(
                                name: .variorumOpenPost, object: nil,
                                userInfo: ["postID": peerID])
                        }
                        .buttonStyle(CalmButtonStyle(tokens: tokens, compact: true))
                        .help("Open this note on its own — \u{2318}[ comes straight back to "
                            + "this comparison")
                    }
                    if model.face(for: peerID)?.sealed == true {
                        Text(tokens.chromeLabel("sealed — read-only"))
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                    }
                    // 13c 2E: N29's honesty line under the filter — an empty
                    // column must never read as content (the MIXED case; it
                    // also covers the version-linked-but-lineage-less peer).
                    if filteredEmpty {
                        Text(tokens.chromeLabel("related blocks only — nothing from this note"))
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .help("Lineage connects none of this note's blocks to the first "
                                + "note's, so the filter leaves this column empty. Turn "
                                + "\u{201C}related blocks only\u{201D} off to see it whole.")
                    }
                }
                // Row 72: the card fills the strip's height, content at the top.
                .frame(maxHeight: .infinity, alignment: .top)
            }
        } else {
            // An open slot is a DOOR where the column would be (the Lenses
            // stub's dashed grammar — one vocabulary for "a column could
            // stand here"): one generous click opens the searchable picker.
            Button {
                pickingSlot = SlotPick(id: slot.id)
            } label: {
                VStack(spacing: 6) {
                    Text(tokens.chromeLabel("＋ choose a note"))
                        .font(tokens.mono)
                        .foregroundStyle(tokens.accent)
                    Text(tokens.chromeLabel("versions of this note come first"))
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .lineLimit(2)
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(
                        tokens.faint, style: StrokeStyle(lineWidth: 1, dash: [5, 4])))
            .help("Open a note beside this one — search the library; version peers "
                + "rank first")
        }
    }

    /// N29's honesty line, per peer: say what the relationship IS.
    @ViewBuilder
    private func relationshipLine(_ peerID: String) -> some View {
        if !model.isRelated(peerID) {
            Text(tokens.chromeLabel("there is no relationship here"))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .help("No lineage and no version link connects these notes — they render "
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

    /// Wave 2c (item 15): the first open TEACHES BY WHAT IT OFFERS — two
    /// real, generous doors where the centered gray prose stood (her copy
    /// doctrine: structure over sentences), and the note's version peers
    /// as direct one-click rows when they exist.
    ///
    /// The Act 10 correction round (rows 16/17/46): a BAND under the header
    /// strip, not a page-centered block standing in the rows' place — it
    /// leads at the board's one inset, under the anchor card, and the note
    /// reads whole beneath it. The memo's build (its §4) moves these two
    /// offers into the empty second slot; this is the mechanical fix only.
    private var offerBand: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 8) {
                Button {
                    if let slot = model.peerSlots.first {
                        pickingSlot = SlotPick(id: slot.id)
                    }
                } label: {
                    CompareOfferCard(
                        tokens: tokens,
                        title: "⌕ compare with a note",
                        detail: "search the library — it opens beside this note, "
                            + "related blocks tied by lineage",
                        primary: true)
                }
                .buttonStyle(.plain)
                .compareGeometryProbe(.offerCard)
                Button {
                    Task { await model.makeOutlinePost() }
                } label: {
                    CompareOfferCard(
                        tokens: tokens,
                        title: "make outline note",
                        detail: "a linked condensation — first sentence per block — "
                            + "minted and opened right here")
                }
                .buttonStyle(.plain)
            }
            if !model.projection.versionPeers.isEmpty {
                Text(tokens.chromeLabel("versions of this note"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .padding(.top, 8)
                ForEach(model.projection.versionPeers, id: \.self) { peerID in
                    Button {
                        if let slot = model.peerSlots.first {
                            model.setPeer(slotID: slot.id, postID: peerID)
                        }
                    } label: {
                        CalmCard(tokens: tokens) {
                            HStack(spacing: 8) {
                                Text(peerTitle(peerID))
                                    .font(tokens.small)
                                    .foregroundStyle(tokens.ink)
                                    .lineLimit(1)
                                Spacer(minLength: 4)
                                Text(tokens.chromeLabel("open beside ›"))
                                    .font(tokens.small)
                                    .foregroundStyle(tokens.accent)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            // 13i-d U5 — THE LINEAGE LINE (#166(e)): another wing's version is
            // NAMED, with at most a plain go-to road — no preview, no content
            // across, no deep link.
            ForEach(model.projection.otherWingVersions, id: \.id) { wing in
                HStack(spacing: 8) {
                    Text(tokens.chromeLabel(WingCopy.versionElsewhere(wing.name)))
                        .font(tokens.small)
                        .foregroundStyle(tokens.faint)
                        .lineLimit(1)
                    Button(tokens.chromeLabel(WingCopy.goTo(wing.name))) {
                        session.wing.switchTo(wing.id)
                    }
                    .buttonStyle(.borderless)
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                    .lineLimit(1)
                }
                .padding(.top, 6)
            }
        }
        .frame(maxWidth: 560, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Self.boardInset)
        .padding(.top, 2)
        .padding(.bottom, 6)
    }

    /// 13c 2E — the whole-board honesty state: "related blocks only" with
    /// NOTHING related must SAY there is no relationship, over the empty
    /// columns. An empty board is never content (N29, composed — that
    /// honesty is the whole reason 4C's gap parade was killed).
    private var nothingRelatedState: some View {
        VStack(spacing: 8) {
            Spacer()
            Text(tokens.chromeLabel("there is no relationship here"))
                .foregroundStyle(tokens.muted)
            Text("\u{201C}Related blocks only\u{201D} is on, and lineage connects nothing "
                + "across these notes — so there is nothing to show. Turn it off to read "
                + "them side by side.")
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 420)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Rows

    private func boardRows(_ display: CompareViewModel.Display) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                ForEach(display.rows) { row in
                    rowView(row)
                }
                endDropZones
            }
            .padding(Self.boardInset)
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
                                .font(tokens.small)
                                // 18j: the voice's own "this one is
                                // different" slot (its doc's words), never a
                                // literal hue — this line's whole job is to
                                // say that one column reads out of order, and
                                // a colour that cannot follow the appearance
                                // says it at the wrong weight on black paper.
                                .foregroundStyle(tokens.alarm)
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
                model: model, tokens: tokens, indicator: indicator,
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
                model.refuse(
                    "Order drags stay within one note here — each column reorders its own note.")
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
            leftTitle: anchor.displayTitle,
            rightTitle: peer.displayTitle,
            left: Queries.joinRenderedTexts(
                anchor.slots.compactMap(\.text).filter { !$0.isEmpty }),
            right: Queries.joinRenderedTexts(
                peer.slots.compactMap(\.text).filter { !$0.isEmpty }))
    }

    private func peerTitle(_ id: String) -> String {
        // The projection is the truth once a face has loaded (a picked
        // note may sit outside the recent-100 candidates window). Both
        // roads read the ONE display rule (row 17): a nameless note is
        // called by its day here too, never "Version".
        if let face = model.projection.peers[id], !face.displayTitle.isEmpty {
            return face.displayTitle
        }
        return model.peerCandidates.first { $0.postID == id }?.displayTitle ?? "Version"
    }
}

// MARK: - The geometry oracle (DEBUG — the correction round's row 16 pins)

/// Where the board's chrome sits, as rectangles in the board's own space —
/// the `MastheadGeometry` idiom. A pin asserts the alignment she SEES (one
/// left edge for the toolbar, the header cards and the offer cards; the add
/// door at the strip's end at the header's height), not a layout the code
/// merely intends.
enum CompareProbeSlot: Hashable {
    case board
    case toolbarLead
    case anchorCard
    case peerCard(Int)
    case offerCard
    case addNote
}

#if DEBUG
/// **SCOPED BY THE MOUNTING SESSION** (13u2 UNIT E — KnownIssues row 50).
/// Swift Testing runs SUITES IN PARALLEL, so a process-global static here
/// lets another suite's mounted board answer this pin's question — a green
/// pin that proved nothing. The scope travels by environment
/// (`DebugProbeScope.swift`); a pin reads its own session's.
@MainActor
enum CompareGeometry {
    private static var worlds: [String: [CompareProbeSlot: CGRect]] = [:]

    static func record(_ slot: CompareProbeSlot, _ frame: CGRect, in scope: String) {
        worlds[scope, default: [:]][slot] = frame
    }

    /// A pin's OWN board — every read below is this session's mount.
    @MainActor
    struct Reader {
        let scope: String

        var frames: [CompareProbeSlot: CGRect] { CompareGeometry.worlds[scope] ?? [:] }

        /// A pin resets before its mount, so a stale report from an earlier
        /// mount (or a door that is no longer rendered) can never satisfy
        /// it — and it clears ITS OWN scope and no other, which is what the
        /// 18d ladder's MINOR-2 learned about whole-oracle wipes.
        func reset() { CompareGeometry.worlds[scope] = nil }
    }

    static func reader(_ scope: String) -> Reader { Reader(scope: scope) }
}

/// The probe, as a modifier rather than a bare `onGeometryChange`, because it
/// must READ the environment for its scope.
private struct CompareGeometryProbe: ViewModifier {
    let slot: CompareProbeSlot
    @Environment(\.debugProbeScope) private var scope

    func body(content: Content) -> some View {
        content.onGeometryChange(for: CGRect.self) {
            $0.frame(in: .named(CompareBoardView.boardSpace))
        } action: { CompareGeometry.record(slot, $0, in: scope) }
    }
}
#endif

extension View {
    /// The DEBUG oracle write: this view's frame in the compare board's own
    /// coordinate space, under `slot`. A no-op outside DEBUG.
    @ViewBuilder
    func compareGeometryProbe(_ slot: CompareProbeSlot) -> some View {
        #if DEBUG
        self.modifier(CompareGeometryProbe(slot: slot))
        #else
        self
        #endif
    }
}

// MARK: - The header's cards (value views — their titles are stored properties)

/// The anchor column's NOTE card: the note's display name (the ONE rule —
/// `Queries.noteDisplayTitle`) over "this note". A VALUE view rather than a
/// `CalmCard { … }` written inline, so the name it shows is a stored property
/// the composition reflection can read (a card's content closure is opaque
/// to `dump`; the correction round's row-17 pin reads `title`).
private struct CompareAnchorCard: View {
    let tokens: VoiceTokens
    let title: String
    let sealed: Bool

    var body: some View {
        CalmCard(tokens: tokens) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(tokens.small.weight(.semibold))
                    .foregroundStyle(tokens.ink)
                    .lineLimit(1)
                Text(tokens.chromeLabel(sealed ? "this note · sealed — read-only" : "this note"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
            }
            // Row 72: the card fills the strip's height, content at the top.
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }
}

/// ONE of the offer band's generous doors (wave 2c's cards, item 15): a
/// title and one line of what it does. A value view for the same reason as
/// the anchor card — the row-46 pin counts each act's placements by title.
private struct CompareOfferCard: View {
    let tokens: VoiceTokens
    let title: String
    let detail: String
    var primary = false

    var body: some View {
        CalmCard(tokens: tokens) {
            VStack(alignment: .leading, spacing: 6) {
                Text(tokens.chromeLabel(title))
                    .font(tokens.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(primary ? tokens.accent : tokens.ink)
                    .lineLimit(1)
                Text(tokens.chromeLabel(detail))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
        }
    }
}

// MARK: - One cell

/// One compare cell: a fully editable pane over the one authority, with
/// its rail (only where lineage speaks), its drag handle (reorders ITS
/// post only), and the in-cell fan bloom (✓ stays the one choosing door).
private struct CompareCellView: View {
    let model: CompareViewModel
    let tokens: VoiceTokens
    /// 17o batch c (her U-7): pushed down to the panes, decided nowhere here.
    let indicator: EditingIndicatorStyle
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
                        .help("Drag to reorder this block within its own note")
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
                            indicator: indicator,
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
                    model.refuse(
                        "Order drags stay within one note here — each column reorders its own note.")
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
                        ? "The note shows this take"
                        : "Choose this take — the note shows it everywhere")
                    PaneSurfaceView(
                        text: model.liveText(take),
                        isLive: model.authority.isLive(key, sealed: sealed),
                        tokens: tokens,
                        indicator: indicator,
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
