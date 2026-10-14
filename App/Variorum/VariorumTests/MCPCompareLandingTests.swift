//
//  MCPCompareLandingTests.swift
//  VariorumTests (Mac)
//
//  VX-298 (VX-336 U6a — the run record `notes/plans/fixes/vx-336-mcp-wire-tools-ai-docs.md`,
//  U6a D-298-3/4/5/8 and THE ORCHESTRATOR'S RULINGS ON U6a's FORKS): the APP half of
//  `show_in_app`'s Compare target. The delivery rides the lens target's model — the anchor
//  opened, the landing parked on the router (`CommandRouter.pendingCompareLanding`), then her
//  Compare mode requested; a refused request clears the landing. The board consumes a landing
//  stamped with ITS note (one for another note is left alone) and REPLACES its columns with
//  exactly what was named (her answer (4)), a live pane on a departing column released (4C's
//  NIT-1); "related blocks only" is the board's to decide from its own projection (F-8 (a)):
//  OFF while the lineage is read, then — once, on the first projection holding every landed
//  peer — ON only when EVERY named peer shares lineage with the anchor (F-9 (a), PROVISIONAL
//  P-VX298-1: no named column opens filtered empty); a later projection never flips it.
//
//  RED on the old tree BY COMPILATION (stated, not measured — every symbol below is absent
//  there: `CompareLanding`, `CommandRouter.pendingCompareLanding`, `CompareViewModel.land`,
//  `consumePendingCompareLanding`, `CompareComposition.landingShowsRelatedOnly`,
//  `MCPShowTarget.compare`). Compiled by U6a's `build-for-testing`; RUN in U6b's Mac batch.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
import VariorumMCP
@testable import Variorum

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
@Suite("VX-298 — Compare from the wire: the delivery, the board's landing, its posture", .serialized)
struct MCPCompareLandingTests {
    /// The anchor, its DUPLICATE (her Duplicate as Version — lineage block by block), and two
    /// notes unrelated to it.
    private func makeWorld(_ session: AppSession) async throws
        -> (anchor: String, twin: String, stranger: String, other: String)
    {
        try await session.runner.run { ops in
            let anchor = try ops.createPost(title: "the piece")
            _ = try ops.newBlock(in: anchor.id, text: "First block of the piece.", at: .end)
            _ = try ops.newBlock(in: anchor.id, text: "Second block of the piece.", at: .end)
            let twin = try ops.duplicateAsVersion(anchor.id)
            let stranger = try ops.createPost(title: "unrelated")
            _ = try ops.newBlock(in: stranger.id, text: "Nothing to do with it.", at: .end)
            let other = try ops.createPost(title: "another")
            _ = try ops.newBlock(in: other.id, text: "Nor this.", at: .end)
            return (anchor.id, twin.post.id, stranger.id, other.id)
        }
    }

    private func adoptFresh(
        _ model: CompareViewModel, _ db: AppDatabase, anchor: String, peers: [String]
    ) async throws {
        model.adopt(try await db.read { db in
            try CompareViewModel.read(db, anchor: anchor, peers: peers)
        })
    }

    // MARK: - The posture rule (F-9 (a), the board's pure brain)

    @Test func thePostureOpensRelatedOnlyOnlyWhenEveryNamedPeerSharesLineage() {
        #expect(CompareComposition.landingShowsRelatedOnly(peerKinships: [["b1": "a1"]]),
                "a duplicate's pair: its rows line up, so the filter is the usable state")
        #expect(!CompareComposition.landingShowsRelatedOnly(peerKinships: [[:]]),
                "her answer (2): related blocks only OFF when they have no history")
        #expect(!CompareComposition.landingShowsRelatedOnly(peerKinships: [["b1": "a1"], [:]]),
                "a mixed set opens OFF — no column the AI named opens filtered empty")
        #expect(CompareComposition.landingShowsRelatedOnly(peerKinships: [["b1": "a1"], ["c2": "a2"]]))
    }

    // MARK: - The board's landing (D-298-5)

    /// Her answer (4): the board shows exactly what was named, REPLACING the columns open —
    /// a live pane on a departing column released, the departed peer LEFT through the board's
    /// own road, and nothing hidden while the lineage is read.
    @Test func aLandingReplacesTheColumnsExactlyAndReleasesADepartingPeersLivePane() async throws {
        try await withCompareWorld { session, db in
            let world = try await makeWorld(session)
            let model = CompareViewModel(session: session, anchorPostID: world.anchor)
            var left: [[String]] = []
            model.onNotesLeft = { left.append($0) }
            model.peerSlots = [.init(postID: world.twin), .init()]
            try await adoptFresh(model, db, anchor: world.anchor, peers: [world.twin])
            let twinSlot = try #require(model.projection.peers[world.twin]?.slots.first)
            let twinKey = PaneTextAuthority.PaneKey(
                columnID: "compare-\(world.twin)", blockID: twinSlot.blockID,
                variantID: try #require(twinSlot.variantID), context: world.twin)
            model.focus(twinKey)
            #expect(model.authority.isLive(twinKey))

            model.land(peers: [world.stranger, world.other])
            #expect(model.peerSlots.map(\.postID) == [world.stranger, world.other], "exactly what was named")
            #expect(model.authority.livePane == nil, "the departing column's live pane released")
            #expect(left == [[world.twin]], "the departed peer left through the board's own road")
            #expect(!model.relatedOnly, "nothing named is hidden while the lineage is read")
            model.teardown()
        }
    }

    /// The posture lands ONCE, on the first projection holding every landed peer: ON for a
    /// duplicate's pair, OFF for an unrelated one and for a mixed set — and her own toggle
    /// afterwards is never flipped back by a later projection.
    @Test func theFirstProjectionHoldingEveryLandedPeerSetsThePostureOnce() async throws {
        try await withCompareWorld { session, db in
            let world = try await makeWorld(session)
            let duplicatePair = CompareViewModel(session: session, anchorPostID: world.anchor)
            duplicatePair.land(peers: [world.twin])
            #expect(!duplicatePair.relatedOnly)
            try await adoptFresh(duplicatePair, db, anchor: world.anchor, peers: [])
            #expect(!duplicatePair.relatedOnly, "a projection without the landed peer decides nothing")
            try await adoptFresh(duplicatePair, db, anchor: world.anchor, peers: [world.twin])
            #expect(duplicatePair.relatedOnly, "a duplicate's pair opens related blocks only — rows line up")
            duplicatePair.relatedOnly = false  // her toggle
            try await adoptFresh(duplicatePair, db, anchor: world.anchor, peers: [world.twin])
            #expect(!duplicatePair.relatedOnly, "a later projection never flips her toggle")

            let unrelated = CompareViewModel(session: session, anchorPostID: world.anchor)
            unrelated.land(peers: [world.stranger])
            try await adoptFresh(unrelated, db, anchor: world.anchor, peers: [world.stranger])
            #expect(!unrelated.relatedOnly, "her answer (2): no history, the filter off")
            #expect(unrelated.display.peerHasBlocks == [true], "the unrelated column shows whole")

            let mixed = CompareViewModel(session: session, anchorPostID: world.anchor)
            mixed.land(peers: [world.twin, world.stranger])
            try await adoptFresh(mixed, db, anchor: world.anchor, peers: [world.twin, world.stranger])
            #expect(!mixed.relatedOnly, "F-9 (a): a mixed set opens off")
            for model in [duplicatePair, unrelated, mixed] { model.teardown() }
        }
    }

    /// The router's parked landing is consumed only by ITS note's board (post-stamped — a
    /// landing for another note is left alone), and consuming it lands the columns.
    @Test func aParkedLandingIsConsumedOnlyByItsOwnNotesBoard() async throws {
        try await withCompareWorld { session, _ in
            let world = try await makeWorld(session)
            let model = CompareViewModel(session: session, anchorPostID: world.anchor)
            let elsewhere = CompareLanding(postID: world.stranger, peerIDs: [world.twin])
            session.commandRouter.pendingCompareLanding = elsewhere
            model.consumePendingCompareLanding()
            #expect(session.commandRouter.pendingCompareLanding == elsewhere, "another note's landing left alone")
            #expect(model.peerSlots.map(\.postID) == [nil])

            session.commandRouter.pendingCompareLanding = CompareLanding(
                postID: world.anchor, peerIDs: [world.twin, world.stranger])
            model.consumePendingCompareLanding()
            #expect(session.commandRouter.pendingCompareLanding == nil, "consumed, once")
            #expect(model.peerSlots.map(\.postID) == [world.twin, world.stranger])
            session.commandRouter.pendingCompareLanding = nil
            model.teardown()
        }
    }

    // MARK: - The delivery (D-298-5: the lens target's model)

    /// The anchor opened, the landing parked, then her Compare mode requested — and a show
    /// that cannot finish (the note never registered) refuses with no landing left parked.
    @Test func theNavigatorDeliversCompareOnHerOwnRoad() async throws {
        try await withCompareWorld { session, _ in
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            let router = ShellRouter()
            door.standingProvider = { (.frontmostMainWindow, router) }
            var applied: [PostMode] = []
            let token = session.commandRouter.registerDetail(postID: "n1", mode: .write) { applied.append($0) }
            defer { session.commandRouter.unregisterDetail(token) }

            #expect(await door.agentShow(.compare(noteID: "n1", peerIDs: ["n2", "n3"])) == .navigate)
            #expect(session.commandRouter.pendingCompareLanding == CompareLanding(postID: "n1", peerIDs: ["n2", "n3"]))
            #expect(applied == [.compare], "the landing, then her Compare mode")
            session.commandRouter.pendingCompareLanding = nil

            let restoreWait = MCPNavigator.mountWait
            MCPNavigator.mountWait = .milliseconds(40)
            defer { MCPNavigator.mountWait = restoreWait }
            #expect(await door.agentShow(.compare(noteID: "n9", peerIDs: ["n2"]))
                    == .refuse(MCPShowRule.partialShowWords))
            #expect(session.commandRouter.pendingCompareLanding == nil, "no landing parked for a failed show")
            #expect(applied == [.compare], "the mode never switched behind her back")
        }
    }
}
