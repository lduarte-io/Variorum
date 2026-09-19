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

    /// The flush asymmetry, pinned exactly (ladder round 3, MINOR-B): a
    /// PEER's kin-less run waits for a row its OWN kin bounds, but the
    /// ANCHOR flushes at every aligned row — it genuinely is bounded by
    /// each of them (its pending blocks precede this anchor block in the
    /// anchor's own order). The accepted consequence, from the reviewer's
    /// traced configuration: material that would once have shared one
    /// packed segment splits into two sparser ones. This pin exists so the
    /// shipped placement is explicit and cannot drift unnoticed — flipping
    /// either half (anchor waits / peer flushes) reds it.
    @Test func theAnchorFlushesAtEveryAlignedRowWhileAPeerRunWaits() {
        // Anchor A B C — peer0: P1x (kin-less), C1' (kin C);
        //                peer1: B2' (kin B).
        let segments = CompareComposition.segments(
            anchorBlocks: ["A", "B", "C"],
            peerBlocks: [["P1x", "C1'"], ["B2'"]],
            kinships: [["C1'": "C"], ["B2'": "B"]],
            followAnchorOrder: true)
        #expect(segments == [
            // A is bounded by the arriving aligned row and flushes alone…
            .free(anchor: ["A"], peers: [[], []]),
            .aligned(.init(anchorBlockID: "B", peerKin: [[], ["B2'"]],
                           peerMoved: [false, false])),
            // …while peer0's P1x waited for the row its OWN kin bounds.
            .free(anchor: [], peers: [["P1x"], []]),
            .aligned(.init(anchorBlockID: "C", peerKin: [["C1'"], []],
                           peerMoved: [false, false])),
        ])
    }

    /// PROVISIONAL, pinned as shipped (ladder round 3, MINOR-C — the
    /// author's call at the 13c kickoff): in a MIXED multi-peer board a
    /// peer with NO kinship at all has no row that bounds its run, so its
    /// whole post trails EVERY aligned row. Here that packs tighter than
    /// the alternative (2 segments), but scaled to a long fully-kin anchor
    /// the unrelated column reads blank for that many rows. The pin
    /// records the choice; it is not a claim that the choice is settled.
    @Test func aPeerWithNoKinshipAtAllTrailsEveryAlignedRow() {
        let segments = CompareComposition.segments(
            anchorBlocks: ["A", "B"],
            peerBlocks: [["U1", "U2"], ["A''"]],
            kinships: [[:], ["A''": "A"]],
            followAnchorOrder: true)
        #expect(segments == [
            .aligned(.init(anchorBlockID: "A", peerKin: [[], ["A''"]],
                           peerMoved: [false, false])),
            .free(anchor: ["B"], peers: [["U1", "U2"], []]),
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

    // MARK: 13c Batch 2E — "show related blocks only" (C4)
    //
    // CONTRACT pins over a NEW capability (the 4C record's "(c) new-contract
    // pins" class), not red-on-old: there is no pre-2E filter to run red.
    // Their non-hollowness is proven by the batch record's guard reverts —
    // each surgical arm of `relatedOnly` reds a named pin below.

    /// The filter keeps exactly the kin and drops exactly the rest — in each
    /// column's OWN order — and because every survivor is kin, the
    /// composition then holds nothing but aligned rows (the free stretches
    /// are precisely the unrelated material).
    @Test func relatedOnlyKeepsTheKinAndComposesOnlyAlignedRows() {
        // Anchor A B C D — peer: A' (kin A), X, Y (unrelated), C' (kin C).
        let kept = CompareComposition.relatedOnly(
            anchorBlocks: ["A", "B", "C", "D"],
            peerBlocks: [["A'", "X", "Y", "C'"]],
            kinships: [["A'": "A", "C'": "C"]])
        #expect(kept.anchorBlocks == ["A", "C"], "B and D relate to nothing here")
        #expect(kept.peerBlocks == [["A'", "C'"]], "X and Y drop; the peer's order survives")
        #expect(CompareComposition.segments(
            anchorBlocks: kept.anchorBlocks, peerBlocks: kept.peerBlocks,
            kinships: [["A'": "A", "C'": "C"]], followAnchorOrder: true) == [
                .aligned(.init(anchorBlockID: "A", peerKin: [["A'"]], peerMoved: [false])),
                .aligned(.init(anchorBlockID: "C", peerKin: [["C'"]], peerMoved: [false])),
            ], "every survivor is kin, so nothing composes free")
    }

    /// THE HONESTY CASE (N29, composed — never broken): zero lineage filters
    /// down to NOTHING on both sides. The board must SAY "there is no
    /// relationship here" over the empty columns; an empty board is never
    /// content. Pinned with the invariant the board relies on — the anchor
    /// column is empty exactly when every peer column is.
    @Test func relatedOnlyLeavesTheAnchorEmptyExactlyWhenEveryPeerIs() {
        let nothing = CompareComposition.relatedOnly(
            anchorBlocks: ["A1", "A2", "A3"], peerBlocks: [["B1", "B2"]], kinships: [[:]])
        #expect(nothing.anchorBlocks.isEmpty)
        #expect(nothing.peerBlocks == [[]])
        #expect(CompareComposition.segments(
            anchorBlocks: nothing.anchorBlocks, peerBlocks: nothing.peerBlocks,
            kinships: [[:]], followAnchorOrder: true).isEmpty,
                "nothing related ⇒ no rows at all — the board speaks instead")

        // …and the converse arm: one kin anywhere keeps both sides non-empty.
        let something = CompareComposition.relatedOnly(
            anchorBlocks: ["A1", "A2"], peerBlocks: [["B1"], []],
            kinships: [["B1": "A2"], [:]])
        #expect(something.anchorBlocks == ["A2"])
        #expect(something.peerBlocks == [["B1"], []])
    }

    /// **The 4C kin-less-peer PROVISIONAL, MOOTED** (13b judgment call 0 —
    /// a peer with no kinship at all trailed EVERY aligned row, so on a long
    /// fully-kin anchor its column read blank for that many rows). This is
    /// the exact configuration that pin uses. With the filter ON the
    /// unrelated peer contributes NOTHING, so the question of where its run
    /// lands does not arise — and the placement with the filter OFF is
    /// deliberately unchanged (`aPeerWithNoKinshipAtAllTrailsEveryAlignedRow`
    /// still holds, byte-for-byte).
    @Test func relatedOnlyDropsTheKinLessPeerEntirelyAndMootsThePlacement() {
        let kept = CompareComposition.relatedOnly(
            anchorBlocks: ["A", "B"],
            peerBlocks: [["U1", "U2"], ["A''"]],
            kinships: [[:], ["A''": "A"]])
        #expect(kept.anchorBlocks == ["A"], "B relates to nothing")
        #expect(kept.peerBlocks == [[], ["A''"]], "the unrelated column is empty, not trailing")
        #expect(CompareComposition.segments(
            anchorBlocks: kept.anchorBlocks, peerBlocks: kept.peerBlocks,
            kinships: [[:], ["A''": "A"]], followAnchorOrder: true) == [
                .aligned(.init(anchorBlockID: "A", peerKin: [[], ["A''"]],
                               peerMoved: [false, false])),
            ], "ONE aligned row; no trailing free segment to place anywhere")
    }

    /// A kinship entry naming an anchor block this compare does NOT show (a
    /// gap slot; a map read a beat before the projection) relates to nothing
    /// HERE — the peer block drops rather than surviving as a cell with no
    /// partner.
    @Test func relatedOnlyIgnoresKinshipPointingOutsideThisCompare() {
        let kept = CompareComposition.relatedOnly(
            anchorBlocks: ["A"],
            peerBlocks: [["A'", "ghost"]],
            kinships: [["A'": "A", "ghost": "GONE"]])
        #expect(kept.anchorBlocks == ["A"])
        #expect(kept.peerBlocks == [["A'"]], "a kin of an absent anchor is not related here")
    }

    /// The two toggles are ORTHOGONAL by construction: this one decides
    /// WHICH blocks show, follow-order decides HOW they arrange. Filter on +
    /// follow off = each column's related blocks, in its own order.
    @Test func relatedOnlyAndFollowOrderStayOrthogonal() {
        let kept = CompareComposition.relatedOnly(
            anchorBlocks: ["A", "B", "C"],
            peerBlocks: [["X", "C'", "A'"]],
            kinships: [["A'": "A", "C'": "C"]])
        #expect(kept.anchorBlocks == ["A", "C"])
        #expect(kept.peerBlocks == [["C'", "A'"]], "the peer's OWN order is preserved")
        #expect(CompareComposition.segments(
            anchorBlocks: kept.anchorBlocks, peerBlocks: kept.peerBlocks,
            kinships: [["A'": "A", "C'": "C"]], followAnchorOrder: false)
                == [.free(anchor: ["A", "C"], peers: [["C'", "A'"]])],
                "follow off still flows each column whole — of the FILTERED blocks")
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
            // 13u3 UNIT D: through the ⌘S DOOR (it summons the optional
            // name), which refuses before presenting a field.
            model.askSavepointName()
            #expect(model.statusMessage?.contains("Click into a pane") == true)
            #expect(model.savepointAsk == nil)

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
            #expect(model.statusMessage?.contains("its own note") == true,
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

    /// **Compare's versions door speaks in words, and links a note that has
    /// nothing in it yet** (ledger rows 17 + 27; her U-19 (1)).
    ///
    /// Two defects, one door. (a) Marking a pair that is ALREADY linked fell
    /// to `OpsRefusalCopy`'s `default:` and printed the raw enum with both
    /// post UUIDs in it — the J8 class, on a click she can make by
    /// double-pressing the row. (b) A peer with no blocks refused with
    /// `postHasNoBlocks`, likewise raw: on the note she had just made, the
    /// door said `Refused: postHasNoBlocks(id: "…")`. The core now mints the
    /// anchor block (row 17), so (b) does not refuse at all — it LINKS — and
    /// the wording added here covers the shape that survives it (a blockless
    /// note on the copy roads) plus (a).
    @Test func theVersionsDoorSpeaksInWordsAndLinksABlocklessNote() async throws {
        try await withCompareWorld { session, db in
            let world = try await makeWorld(session)
            let fresh = try await session.runner.run { ops in
                try ops.createPost(title: "the note I just made").id
            }
            let model = CompareViewModel(session: session, anchorPostID: world.anchor)
            model.peerSlots = [.init(postID: fresh)]
            try await adoptFresh(model, db, anchor: world.anchor, peers: [fresh])

            // (b) U-19 (1): it LINKS, and the note gains its anchor block.
            model.markAsVersions(fresh)
            await poll { model.statusMessage != nil || model.isRelated(fresh) }
            try await adoptFresh(model, db, anchor: world.anchor, peers: [fresh])
            let (peers, slots) = try await db.read { database in
                (try Queries.versionPeerPosts(database, of: fresh),
                 try Queries.renderPost(database, containerID: fresh))
            }
            #expect(peers == [world.anchor], "the link landed on a note with nothing in it")
            #expect(slots.map(\.text) == [""], "one empty block, minted as the anchor")
            #expect(model.statusMessage?.contains("Refused") != true,
                    "and no raw error: \(model.statusMessage ?? "nil")")

            // (a) The same door again on the now-linked pair: words, and no
            // enum dump carrying the ids.
            let firstLine = model.statusMessage
            model.markAsVersions(fresh)
            await poll { model.statusMessage != firstLine && model.statusMessage != nil }
            let spoken = try #require(model.statusMessage)
            #expect(!spoken.hasPrefix("Refused:"), "\(spoken)")
            #expect(!spoken.contains(fresh), "a UUID is not a sentence: \(spoken)")
            #expect(!spoken.contains(world.anchor), "\(spoken)")
            #expect(spoken == OpsRefusalCopy.message(
                for: OperationError.postsAlreadyVersionLinked(a: world.anchor, b: fresh)),
                    "the refusal's ONE home, so both doors say it the same way")
            model.teardown()
        }
    }

    /// 13c Batch 2E (C4): the filter, ON THE BOARD — and since her #47(c)
    /// ruling (13c ratify walk, built 13d batch 1) it is what Compare OPENS
    /// with. Only the kin rows compose, and the unrelated column reports
    /// itself empty rather than sitting blank (the mixed case — the version
    /// twin is related, the stranger is not); turning the chip OFF reveals
    /// the full posts, which is 2E's byte-unchanged behavior.
    @Test func relatedOnlyHidesTheUnrelatedColumnAndTheBoardSaysSo() async throws {
        try await withCompareWorld { session, db in
            let world = try await makeWorld(session)
            let model = CompareViewModel(session: session, anchorPostID: world.anchor)
            model.peerSlots = [.init(postID: world.twin), .init(postID: world.stranger)]
            try await adoptFresh(
                model, db, anchor: world.anchor, peers: [world.twin, world.stranger])

            #expect(model.relatedOnly, "Compare opens filtered — her #47(c) ruling")
            let filtered = model.display
            #expect(filtered.isFiltered)
            #expect(!filtered.rows.isEmpty, "the twin's kin rows survive")
            #expect(filtered.rows.allSatisfy { row in
                if case .aligned = row { return true }
                return false
            }, "every survivor is kin — nothing composes free")
            #expect(filtered.anchorHasBlocks)
            #expect(filtered.peerHasBlocks == [true, false],
                    "the stranger contributes nothing — the column's note says so")

            // Every anchor block of the twin pair is kin, so the filter
            // costs the related comparison nothing.
            #expect(filtered.rows.count == model.projection.anchor.slots.count)

            // …and the chip still reveals the whole posts — 2E's OFF side,
            // byte-unchanged by the default flip.
            model.relatedOnly = false
            let unfiltered = model.display
            #expect(!unfiltered.isFiltered)
            #expect(unfiltered.rows.contains { row in
                if case .free = row { return true }
                return false
            }, "unfiltered, the stranger's block flows in a free row")
            #expect(unfiltered.peerHasBlocks == [true, true])
            model.teardown()
        }
    }

    /// THE LIVE-RING CALL, pinned (13c 2E): turning the filter on can hide
    /// the block the ring sits in. The 4C NIT-1 precedent governs — the ring
    /// never stays on a pane nothing renders: it blurs, the pane's own post
    /// flushes so the typed text LANDS, and the board SPEAKS (a caret
    /// disappearing without a word is the silent-door class). Deliberately
    /// NOT a refusal of the toggle.
    @Test func turningOnRelatedOnlyReleasesARingItHidesAndLandsTheText() async throws {
        try await withCompareWorld { session, db in
            let world = try await makeWorld(session)
            let model = CompareViewModel(session: session, anchorPostID: world.anchor)
            model.peerSlots = [.init(postID: world.twin), .init(postID: world.stranger)]
            try await adoptFresh(
                model, db, anchor: world.anchor, peers: [world.twin, world.stranger])

            // The board now OPENS filtered (#47(c)), so the transition this
            // pin is about starts from the chip turned OFF — which is also
            // the real sequence: she reads the posts whole, types, then
            // reaches for the filter.
            model.relatedOnly = false
            let strangerSlot = model.projection.peers[world.stranger]!.slots[0]
            let strangerKey = PaneTextAuthority.PaneKey(
                columnID: "compare-\(world.stranger)", blockID: strangerSlot.blockID,
                variantID: strangerSlot.variantID!, context: world.stranger)
            model.focus(strangerKey)
            model.paneEdited(
                postID: world.stranger, variantID: strangerSlot.variantID!,
                newText: "typed just before the filter hid it")
            #expect(model.authority.isLive(strangerKey))

            model.relatedOnly = true
            #expect(model.authority.livePane == nil,
                    "the ring never stays on a pane the filter hid")
            #expect(model.statusMessage?.contains("hid the block you were writing in") == true,
                    "it speaks — a caret does not vanish silently")
            await poll { session.autosave(forPost: world.stranger).pending.isEmpty }
            let landed = try await db.read { db in
                try Queries.renderPost(db, containerID: world.stranger)[0].text
            }
            #expect(landed == "typed just before the filter hid it",
                    "the buffer flushed on the way out, not dropped")
            model.teardown()
        }
    }

    /// The narrowness half: a ring on a block the filter KEEPS is untouched
    /// — no blur, no speech. (Without it, the release guard could over-fire
    /// and drop the ring on every toggle.)
    @Test func relatedOnlyLeavesARingItDoesNotHideAlone() async throws {
        try await withCompareWorld { session, db in
            let world = try await makeWorld(session)
            let model = CompareViewModel(session: session, anchorPostID: world.anchor)
            model.peerSlots = [.init(postID: world.twin)]
            try await adoptFresh(model, db, anchor: world.anchor, peers: [world.twin])

            let twinSlot = model.projection.peers[world.twin]!.slots[0]
            let twinKey = PaneTextAuthority.PaneKey(
                columnID: "compare-\(world.twin)", blockID: twinSlot.blockID,
                variantID: twinSlot.variantID!, context: world.twin)
            model.focus(twinKey)
            // Off, then on: the default is ON now (#47(c)), and a set that
            // doesn't CHANGE the value never runs the release guard — so
            // driving the real transition is what keeps this pin honest.
            model.relatedOnly = false
            model.relatedOnly = true
            #expect(model.authority.isLive(twinKey),
                    "the twin's blocks are all kin — the ring is not hidden, so it stays")
            #expect(model.statusMessage == nil, "nothing to say")

            // …and the anchor side of the same guard.
            let anchorSlot = model.projection.anchor.slots[0]
            let anchorKey = PaneTextAuthority.PaneKey(
                columnID: "compare-\(world.anchor)", blockID: anchorSlot.blockID,
                variantID: anchorSlot.variantID!, context: world.anchor)
            model.focus(anchorKey)
            model.relatedOnly = false
            model.relatedOnly = true
            #expect(model.authority.isLive(anchorKey), "the anchor's kin block stays live too")
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
