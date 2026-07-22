//
//  CompareBoardTests.swift
//  VariorumTests
//
//  Phase 13b, Stage 4 (4C): the compare rework's pins — the pure
//  composition brain (N29's honesty rule as code), and the cross-post
//  board model (one authority spanning post contexts, per-post edit
//  routing, per-post reorder isolation, relationship detection).
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The composition brain (pure)

@Suite("Compare composition (13b 4C — N29/S4-12)")
struct CompareCompositionTests {
    /// ZERO lineage ⇒ ONE free segment: the posts sit plainly side by
    /// side, each in its own order — no blank parade, nothing aligned.
    @Test func zeroLineagePacksOneFreeSegment() {
        let segments = CompareComposition.segments(
            anchorBlocks: ["A1", "A2", "A3"],
            peerBlocks: [["B1", "B2"]],
            kinships: [[:]],
            followAnchorOrder: true)
        #expect(segments == [.free(anchor: ["A1", "A2", "A3"], peers: [["B1", "B2"]])])
        #expect(CompareComposition.railedAnchors(kinships: [[:]]).isEmpty,
                "no rails where no lineage speaks")
    }

    /// A partial relationship aligns ONLY the kin rows; the unrelated
    /// stretches between them pack side by side in their own orders —
    /// no blanks between unrelated rows (the S4-12 agreed nuance).
    @Test func partialRelationshipAlignsOnlyWhereLineageSpeaks() {
        // Anchor: A B C D — peer: A' (kin A), X, Y (unrelated), C' (kin C).
        let segments = CompareComposition.segments(
            anchorBlocks: ["A", "B", "C", "D"],
            peerBlocks: [["A'", "X", "Y", "C'"]],
            kinships: [["A'": "A", "C'": "C"]],
            followAnchorOrder: true)
        #expect(segments.count == 4)
        #expect(segments[0] == .aligned(.init(
            anchorBlockID: "A", peerKin: [["A'"]], peerMoved: [false])))
        // B (kin-less) and the peer's X,Y pack ONE free stretch, own orders.
        #expect(segments[1] == .free(anchor: ["B"], peers: [["X", "Y"]]))
        #expect(segments[2] == .aligned(.init(
            anchorBlockID: "C", peerKin: [["C'"]], peerMoved: [false])))
        // D trails kin-less — a free tail, peer side simply empty.
        #expect(segments[3] == .free(anchor: ["D"], peers: [[]]))
        #expect(CompareComposition.railedAnchors(kinships: [["A'": "A", "C'": "C"]])
                == ["A", "C"])
    }

    /// A divide's span shares its anchor's row (the 11a lineage-keyed
    /// registration, carried through), and a cross-version reorder is
    /// MARKED, never guessed at — PostAlignment's semantics survive the
    /// segment layer verbatim.
    @Test func spansShareARowAndMovesStayMarked() {
        let spans = CompareComposition.segments(
            anchorBlocks: ["A", "B"],
            peerBlocks: [["B1'", "B2'", "A'"]],
            kinships: [["B1'": "B", "B2'": "B", "A'": "A"]],
            followAnchorOrder: true)
        #expect(spans == [
            .aligned(.init(anchorBlockID: "A", peerKin: [["A'"]], peerMoved: [true])),
            .aligned(.init(anchorBlockID: "B", peerKin: [["B1'", "B2'"]], peerMoved: [false])),
        ])
    }

    /// Multi-peer (up to the anchor + three): each peer registers against
    /// the anchor independently; a kin row carries every peer's cells (an
    /// uninvolved peer's cell is EMPTY, never a "—" blank), and each
    /// peer's kin-less blocks pack into the free stretches in their own
    /// orders.
    @Test func multiPeerRowsMergeOnTheAnchorSpine() {
        let segments = CompareComposition.segments(
            anchorBlocks: ["A", "B"],
            peerBlocks: [["A'", "P1x"], ["B''", "P2x"]],
            kinships: [["A'": "A"], ["B''": "B"]],
            followAnchorOrder: true)
        #expect(segments == [
            .aligned(.init(anchorBlockID: "A", peerKin: [["A'"], []], peerMoved: [false, false])),
            .aligned(.init(anchorBlockID: "B", peerKin: [[], ["B''"]], peerMoved: [false, false])),
            .free(anchor: [], peers: [["P1x"], ["P2x"]]),
        ])
    }

    /// The follow-order toggle OFF is the display-only escape (S4-3's
    /// shape): every column flows whole, in its own order — even where
    /// kinship exists. Rails stay a separate channel (the lineage-color
    /// toggle), so the composition carries no color decisions.
    @Test func followOrderOffFlowsEveryColumnWhole() {
        let segments = CompareComposition.segments(
            anchorBlocks: ["A", "B"],
            peerBlocks: [["A'", "B'"]],
            kinships: [["A'": "A", "B'": "B"]],
            followAnchorOrder: false)
        #expect(segments == [.free(anchor: ["A", "B"], peers: [["A'", "B'"]])])
    }

    /// Peer blocks arriving BEFORE any kin (an opening the anchor lacks)
    /// pack a leading free stretch; empty inputs compose to nothing.
    @Test func leadingOrphansAndEmptyInputs() {
        let leading = CompareComposition.segments(
            anchorBlocks: ["A"],
            peerBlocks: [["X", "A'"]],
            kinships: [["A'": "A"]],
            followAnchorOrder: true)
        #expect(leading == [
            .free(anchor: [], peers: [["X"]]),
            .aligned(.init(anchorBlockID: "A", peerKin: [["A'"]], peerMoved: [false])),
        ])
        #expect(CompareComposition.segments(
            anchorBlocks: [], peerBlocks: [[]], kinships: [[:]],
            followAnchorOrder: true).isEmpty)
    }
}

// MARK: - The board model (cross-post authority + per-post pipelines)

@MainActor
private func withCompareWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 43))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@MainActor
private func poll(
    _ predicate: @MainActor () -> Bool, timeout: TimeInterval = 5
) async {
    let deadline = Date().addingTimeInterval(timeout)
    while !predicate(), Date() < deadline {
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(10))
    }
}

@MainActor
@Suite("Compare board model (13b 4C)", .serialized)
struct CompareViewModelTests {
    /// anchor (2 blocks) + its duplicate-as-version twin + an unrelated
    /// post — the compare world every pin below shares.
    private func makeWorld(_ session: AppSession) async throws
        -> (anchor: String, twin: String, stranger: String)
    {
        try await session.runner.run { ops in
            let anchor = try ops.createPost(title: "the piece")
            _ = try ops.newBlock(in: anchor.id, text: "First block of the piece.", at: .end)
            _ = try ops.newBlock(in: anchor.id, text: "Second block of the piece.", at: .end)
            let twin = try ops.duplicateAsVersion(anchor.id)
            let stranger = try ops.createPost(title: "unrelated")
            _ = try ops.newBlock(in: stranger.id, text: "Nothing to do with it.", at: .end)
            return (anchor.id, twin.post.id, stranger.id)
        }
    }

    private func adoptFresh(
        _ model: CompareViewModel, _ db: AppDatabase, anchor: String, peers: [String]
    ) async throws {
        model.adopt(try await db.read { db in
            try CompareViewModel.read(db, anchor: anchor, peers: peers)
        })
    }

    /// The batch's riskiest piece, pinned: EDITS ROUTE PER POST (each
    /// post's own AutosaveCoordinator — the N3 boundary is per post, so
    /// two coordinators live at once is the DESIGNED shape) and the ONE
    /// ring holds across both post contexts on the one authority.
    @Test func editsRoutePerPostAndOneRingHoldsAcrossPosts() async throws {
        try await withCompareWorld { session, db in
            let world = try await makeWorld(session)
            let model = CompareViewModel(session: session, anchorPostID: world.anchor)
            model.peerSlots = [.init(postID: world.twin)]
            try await adoptFresh(model, db, anchor: world.anchor, peers: [world.twin])

            // Distinct pipelines per post (session-scoped identity).
            #expect(session.autosave(forPost: world.anchor)
                    !== session.autosave(forPost: world.twin),
                    "one coordinator PER POST — compare mounts two, by design")

            let anchorSlot = model.projection.anchor.slots[0]
            let anchorKey = PaneTextAuthority.PaneKey(
                columnID: "compare-\(world.anchor)", blockID: anchorSlot.blockID,
                variantID: anchorSlot.variantID!, context: world.anchor)
            model.focus(anchorKey)
            model.paneEdited(
                postID: world.anchor, variantID: anchorSlot.variantID!,
                newText: "typed into the anchor")
            #expect(session.autosave(forPost: world.anchor)
                    .pending[anchorSlot.variantID!]?.text == "typed into the anchor")
            #expect(session.autosave(forPost: world.twin).pending.isEmpty,
                    "the twin's pipeline never sees the anchor's edit")

            // The ring migrates ACROSS posts — one authority, one optional.
            let twinSlot = model.projection.peers[world.twin]!.slots[0]
            let twinKey = PaneTextAuthority.PaneKey(
                columnID: "compare-\(world.twin)", blockID: twinSlot.blockID,
                variantID: twinSlot.variantID!, context: world.twin)
            model.focus(twinKey)
            #expect(model.authority.isLive(twinKey))
            #expect(!model.authority.isLive(anchorKey), "ONE live ring across both posts")
            model.paneEdited(
                postID: world.twin, variantID: twinSlot.variantID!,
                newText: "typed into the twin")
            #expect(session.autosave(forPost: world.twin)
                    .pending[twinSlot.variantID!]?.text == "typed into the twin")

            // Both land — in their own posts, nothing crossed.
            await session.autosave(forPost: world.anchor).flushNow()
            await session.autosave(forPost: world.twin).flushNow()
            let landed = try await db.read { db in
                (try Queries.renderPost(db, containerID: world.anchor)[0].text,
                 try Queries.renderPost(db, containerID: world.twin)[0].text)
            }
            #expect(landed.0 == "typed into the anchor")
            #expect(landed.1 == "typed into the twin")
            model.teardown()
        }
    }

    /// 13b Stage 4 ladder round 1, NIT-1 (red-on-old: the ring stayed
    /// keyed to the removed column's context — an unmounted post no pane
    /// renders, with the union-settle no longer covering its pending
    /// buffers): removing OR replacing the live pane's column blurs the
    /// authority, and the leaving post's dirty buffer flushes through its
    /// own coordinator instead of waiting out the transient window.
    @Test func removingOrReplacingTheLiveColumnsPeerReleasesTheRing() async throws {
        try await withCompareWorld { session, db in
            let world = try await makeWorld(session)
            let model = CompareViewModel(session: session, anchorPostID: world.anchor)
            model.peerSlots = [.init(postID: world.twin)]
            try await adoptFresh(model, db, anchor: world.anchor, peers: [world.twin])

            // Focus a twin pane and leave it DIRTY — the worst case the
            // 4C record traced.
            let twinSlot = model.projection.peers[world.twin]!.slots[0]
            let twinKey = PaneTextAuthority.PaneKey(
                columnID: "compare-\(world.twin)", blockID: twinSlot.blockID,
                variantID: twinSlot.variantID!, context: world.twin)
            model.focus(twinKey)
            model.paneEdited(
                postID: world.twin, variantID: twinSlot.variantID!,
                newText: "typed just before the column closed")
            #expect(model.authority.isLive(twinKey))

            // ✕ on the live pane's column (single slot ⇒ postID clears).
            model.removePeerSlot(model.peerSlots[0].id)
            #expect(model.authority.livePane == nil,
                    "the ring never points at an unmounted column")
            // The targeted flush lands the leaving post's buffer.
            await poll {
                session.autosave(forPost: world.twin).pending.isEmpty
            }
            let landed = try await db.read { db in
                try Queries.renderPost(db, containerID: world.twin)[0].text
            }
            #expect(landed == "typed just before the column closed",
                    "the dirty buffer flushed on the way out, not dropped")

            // The REPLACE path (the picker swaps the post): same release.
            model.setPeer(slotID: model.peerSlots[0].id, postID: world.twin)
            try await adoptFresh(model, db, anchor: world.anchor, peers: [world.twin])
            model.focus(twinKey)
            #expect(model.authority.isLive(twinKey))
            model.setPeer(slotID: model.peerSlots[0].id, postID: world.stranger)
            #expect(model.authority.livePane == nil,
                    "replacing the column releases the ring the same way")

            // A no-op re-pick of the SAME post never blurs (the column
            // still shows that post).
            try await adoptFresh(model, db, anchor: world.anchor, peers: [world.stranger])
            let strangerSlot = model.projection.peers[world.stranger]!.slots[0]
            let strangerKey = PaneTextAuthority.PaneKey(
                columnID: "compare-\(world.stranger)", blockID: strangerSlot.blockID,
                variantID: strangerSlot.variantID!, context: world.stranger)
            model.focus(strangerKey)
            model.setPeer(slotID: model.peerSlots[0].id, postID: world.stranger)
            #expect(model.authority.isLive(strangerKey),
                    "re-picking the same post is not a column change")
            model.teardown()
        }
    }

    /// 13b 4D (the 4C handoff — judgment call 4's recorded upgrade, built):
    /// ⌘S in Compare commits the FOCUSED pane's take — whichever POST it
    /// belongs to (the flush routes through that post's own coordinator);
    /// no focus speaks instead of guessing.
    @Test func commitFocusedTakeCommitsThePaneOwnPostsTake() async throws {
        try await withCompareWorld { session, db in
            let world = try await makeWorld(session)
            let model = CompareViewModel(session: session, anchorPostID: world.anchor)
            model.peerSlots = [.init(postID: world.twin)]
            try await adoptFresh(model, db, anchor: world.anchor, peers: [world.twin])

            @MainActor func commits(_ variantID: String) async throws -> Int {
                try await db.read { db in
                    try Int.fetchOne(
                        db, sql: "SELECT COUNT(*) FROM commit_point WHERE variant_id = ?",
                        arguments: [variantID]) ?? 0
                }
            }

            // No focus: speaks, commits nothing.
            await model.commitFocusedTake()
            #expect(model.statusMessage?.contains("Click into a pane") == true)

            // Focus a PEER pane — pending text flushes through the twin's
            // own pipeline and the commit lands on that take.
            let twinSlot = model.projection.peers[world.twin]!.slots[0]
            let twinKey = PaneTextAuthority.PaneKey(
                columnID: "compare-\(world.twin)", blockID: twinSlot.blockID,
                variantID: twinSlot.variantID!, context: world.twin)
            model.focus(twinKey)
            model.paneEdited(
                postID: world.twin, variantID: twinSlot.variantID!,
                newText: "the committed twin text")
            await model.commitFocusedTake()
            #expect(try await commits(twinSlot.variantID!) == 1,
                    "⌘S committed the focused pane's take")
            let committedText = try await db.read { db in
                try String.fetchOne(
                    db,
                    sql: "SELECT text FROM commit_point WHERE variant_id = ?",
                    arguments: [twinSlot.variantID!])
            }
            #expect(committedText == "the committed twin text",
                    "the flush preceded the commit — the savepoint holds the typed text")
            let anchorSlot = model.projection.anchor.slots[0]
            #expect(try await commits(anchorSlot.variantID!) == 0,
                    "the anchor's take is untouched — the pane's own post only")
            model.teardown()
        }
    }

    /// S4-2d's compare half: a drag reorders ITS OWN post only — the
    /// other column's stored order is byte-untouched, and one ⌥⌘Z undoes
    /// (an ordinary `reorder` through ops, never a bespoke order store).
    @Test func reorderTouchesExactlyItsOwnPost() async throws {
        try await withCompareWorld { session, db in
            let world = try await makeWorld(session)
            let model = CompareViewModel(session: session, anchorPostID: world.anchor)
            model.peerSlots = [.init(postID: world.twin)]
            try await adoptFresh(model, db, anchor: world.anchor, peers: [world.twin])

            let orderBefore = try await db.read { db in
                (try Queries.renderPost(db, containerID: world.anchor).map(\.blockID),
                 try Queries.renderPost(db, containerID: world.twin).map(\.blockID))
            }
            await model.moveBlock(
                orderBefore.0[0], inPost: world.anchor, before: nil)  // → the end
            let orderAfter = try await db.read { db in
                (try Queries.renderPost(db, containerID: world.anchor).map(\.blockID),
                 try Queries.renderPost(db, containerID: world.twin).map(\.blockID))
            }
            #expect(orderAfter.0 == [orderBefore.0[1], orderBefore.0[0]],
                    "the anchor reordered")
            #expect(orderAfter.1 == orderBefore.1,
                    "the twin's order is byte-untouched — each column reorders its own post")

            // ⌥⌘Z: the ordinary undo inverse restores the exact order.
            let undoStack = session.undoStack
            _ = try await session.runner.run { ops in try undoStack.undo(with: ops) }
            let restored = try await db.read { db in
                try Queries.renderPost(db, containerID: world.anchor).map(\.blockID)
            }
            #expect(restored == orderBefore.0, "one ⌥⌘Z restores the order")
            model.teardown()
        }
    }

    /// A cross-post drop refuses HONESTLY (speaks, changes nothing) —
    /// order drags stay within a post; moving blocks between posts is a
    /// different operation, deliberately not this gesture.
    @Test func aCrossPostDropRefusesAndSpeaks() async throws {
        try await withCompareWorld { session, db in
            let world = try await makeWorld(session)
            let model = CompareViewModel(session: session, anchorPostID: world.anchor)
            model.peerSlots = [.init(postID: world.twin)]
            try await adoptFresh(model, db, anchor: world.anchor, peers: [world.twin])

            let twinBlock = model.projection.peers[world.twin]!.slots[0].blockID
            let before = try await db.read { db in
                (try Queries.renderPost(db, containerID: world.anchor).map(\.blockID),
                 try Queries.renderPost(db, containerID: world.twin).map(\.blockID))
            }
            await model.moveBlock(twinBlock, inPost: world.anchor, before: nil)
            #expect(model.statusMessage?.contains("its own post") == true,
                    "the refusal speaks")
            let after = try await db.read { db in
                (try Queries.renderPost(db, containerID: world.anchor).map(\.blockID),
                 try Queries.renderPost(db, containerID: world.twin).map(\.blockID))
            }
            #expect(after.0 == before.0)
            #expect(after.1 == before.1, "nothing moved anywhere")
            model.teardown()
        }
    }

    /// N29's relationship answers: a twin is related (lineage + link); a
    /// stranger is NOT ("there is no relationship here"); marking
    /// versions on zero lineage says alignment will be loose.
    @Test func relationshipHonestyAnswersPerPeer() async throws {
        try await withCompareWorld { session, db in
            let world = try await makeWorld(session)
            let model = CompareViewModel(session: session, anchorPostID: world.anchor)
            model.peerSlots = [.init(postID: world.twin), .init(postID: world.stranger)]
            try await adoptFresh(
                model, db, anchor: world.anchor, peers: [world.twin, world.stranger])

            #expect(model.isRelated(world.twin))
            #expect(model.hasLineage(world.twin))
            #expect(!model.isRelated(world.stranger), "no lineage, no link — say so")
            #expect(model.railKin(postID: world.stranger,
                                  blockID: model.projection.peers[world.stranger]!.slots[0].blockID)
                    == nil, "no rail where no lineage speaks")

            // Zero-lineage marking: linked now, but LOOSE — spoken.
            model.markAsVersions(world.stranger)
            await poll { model.statusMessage?.contains("loosely") == true }
            #expect(model.statusMessage?.contains("loosely") == true,
                    "zero-lineage version-marking says alignment will be loose")
            try await adoptFresh(
                model, db, anchor: world.anchor, peers: [world.twin, world.stranger])
            #expect(model.isRelated(world.stranger), "the link relates them")
            #expect(!model.hasLineage(world.stranger), "…but lineage still has nothing to say")
            model.teardown()
        }
    }

    /// The lineage-color toggle (S4-12) gates every rail; the rail colors
    /// by the ANCHOR kin on both sides (associated blocks share a color).
    @Test func railsFollowKinshipAndTheToggle() async throws {
        try await withCompareWorld { session, db in
            let world = try await makeWorld(session)
            let model = CompareViewModel(session: session, anchorPostID: world.anchor)
            model.peerSlots = [.init(postID: world.twin)]
            try await adoptFresh(model, db, anchor: world.anchor, peers: [world.twin])

            let anchorBlock = model.projection.anchor.slots[0].blockID
            let twinBlock = model.projection.peers[world.twin]!.slots[0].blockID
            let kin = model.projection.kinship[world.twin]?[twinBlock]
            #expect(kin == anchorBlock, "the twin's first block kins the anchor's first")
            #expect(model.railKin(postID: world.anchor, blockID: anchorBlock) == anchorBlock)
            #expect(model.railKin(postID: world.twin, blockID: twinBlock) == anchorBlock,
                    "both sides color by the anchor kin — one color per family")

            model.lineageColorsOn = false
            #expect(model.railKin(postID: world.anchor, blockID: anchorBlock) == nil)
            #expect(model.railKin(postID: world.twin, blockID: twinBlock) == nil,
                    "the toggle silences every rail")
            model.teardown()
        }
    }
}
