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

    // MARK: - The landing's ONE ROUND (THE ORCHESTRATOR'S RULING ON U6a's ONE OPEN DECISION, (a))

    /// A door for the wire's show, standing as the frontmost main window (the delivery pin's).
    private func showDoor(_ session: AppSession) -> MCPDoor {
        let door = MCPDoor(serverAllowed: false)
        door.attach(session: session)
        let router = ShellRouter()
        door.standingProvider = { (.frontmostMainWindow, router) }
        return door
    }

    /// HER OWN ⌘5 on `anchor`, with no wire act behind it: the detail switches to Compare and
    /// reports it, then the board mounts — its `onAppear` consumes whatever landing is parked
    /// for this note, and its observation adopts the projection (twice: the first auto-fills the
    /// linked version, the second reads that column). The test host never fires `.task`, so this
    /// drives the board's own calls in the board's own order.
    private func herOwnCompare(
        _ session: AppSession, _ db: AppDatabase, on anchor: String
    ) async throws -> CompareViewModel {
        #expect(session.commandRouter.requestMode(.compare))
        session.commandRouter.noteMode(.compare)
        let board = CompareViewModel(session: session, anchorPostID: anchor)
        board.consumePendingCompareLanding()
        try await adoptFresh(board, db, anchor: anchor, peers: board.peerSlots.compactMap(\.postID))
        try await adoptFresh(board, db, anchor: anchor, peers: board.peerSlots.compactMap(\.postID))
        return board
    }

    /// HER columns — what her own Compare opens on with nothing parked: the linked version (the
    /// duplicate) beside the anchor, "related blocks only" at her default ON (#47(c)). An orphaned
    /// landing would have REPLACED them with the stranger and turned the filter off.
    private func expectHerColumns(_ board: CompareViewModel, twin: String) {
        #expect(board.peerSlots.map(\.postID) == [twin],
                "her own Compare keeps HER columns — never the AI's set, long after the call (R-13nb-23)")
        #expect(board.relatedOnly, "her default stands — no landing posture applied")
    }

    /// **A landing she outruns with another mode is dropped** (Round-2 MINOR-R2's aborted-round
    /// window — the lens landing's twin): the wire parks a landing and requests Compare, the
    /// detail reports Compare (the landing KEPT — the ordering-safety half), and she presses ⌘2
    /// before the board takes it. The round is over: the landing goes, and her own ⌘5 later
    /// opens her board, not the AI's columns.
    /// RED on the one-property tree (`a846a5f1`) BY ASSERTION: the landing survives the ⌘2
    /// report and her ⌘5's board replaces its columns with the stranger, the filter off.
    @Test func aLandingSheOutrunsWithAnotherModeIsDroppedAndHerOwnCompareKeepsHerColumns() async throws {
        try await withCompareWorld { session, db in
            let world = try await makeWorld(session)
            let door = showDoor(session)
            defer { door.detach() }
            var applied: [PostMode] = []
            let token = session.commandRouter.registerDetail(postID: world.anchor, mode: .write) {
                applied.append($0)
            }
            defer { session.commandRouter.unregisterDetail(token) }
            let parked = CompareLanding(postID: world.anchor, peerIDs: [world.stranger])

            #expect(await door.agentShow(.compare(noteID: world.anchor, peerIDs: [world.stranger])) == .navigate)
            #expect(applied == [.compare])
            session.commandRouter.noteMode(.compare)
            #expect(session.commandRouter.pendingCompareLanding == parked,
                    "reporting the landing's own mode keeps the landing")

            // Her ⌘2 in the tens of ms before the board mounts.
            #expect(session.commandRouter.requestMode(.takes))
            session.commandRouter.noteMode(.takes)
            #expect(session.commandRouter.pendingCompareLanding == nil,
                    "any other mode report ends the landing's round")

            let board = try await herOwnCompare(session, db, on: world.anchor)
            expectHerColumns(board, twin: world.twin)
            #expect(applied == [.compare, .takes, .compare])
            board.teardown()
        }
    }

    /// **A landing whose note leaves before the board takes it is dropped** — the detail
    /// re-registering for ANOTHER note (a P→Q switch; Q's `onAppear` may run before P's
    /// `onDisappear`, so the drop rides registration) or tearing down with no successor ends its
    /// round, as each ends the lens landing's. Her own ⌘5 on the anchor afterwards opens her
    /// board each time, not the AI's columns.
    /// RED on the one-property tree BY ASSERTION: both landings survive (a same-note
    /// re-registration keeps a parcel) and both of her boards land the stranger, the filter off.
    @Test func aLandingWhoseNoteLeavesBeforeTheBoardTakesItIsDroppedAndHerOwnCompareKeepsHerColumns() async throws {
        try await withCompareWorld { session, db in
            let world = try await makeWorld(session)
            let door = showDoor(session)
            defer { door.detach() }

            // (i) Another note's detail registers before the board mounts.
            let first = session.commandRouter.registerDetail(postID: world.anchor, mode: .write) { _ in }
            #expect(await door.agentShow(.compare(noteID: world.anchor, peerIDs: [world.stranger])) == .navigate)
            #expect(session.commandRouter.pendingCompareLanding != nil, "parked")
            let elsewhere = session.commandRouter.registerDetail(postID: world.other, mode: .write) { _ in }
            #expect(session.commandRouter.pendingCompareLanding == nil,
                    "another note's registration ends the landing's round")
            session.commandRouter.unregisterDetail(first)  // P's late teardown — stale, a no-op
            // She goes back to the anchor (its onAppear before the other's onDisappear) and ⌘5s.
            let back = session.commandRouter.registerDetail(postID: world.anchor, mode: .write) { _ in }
            session.commandRouter.unregisterDetail(elsewhere)  // stale, a no-op
            let afterSwitch = try await herOwnCompare(session, db, on: world.anchor)
            expectHerColumns(afterSwitch, twin: world.twin)
            // Her ⌘1 — back to Write; the board goes.
            #expect(session.commandRouter.requestMode(.write))
            session.commandRouter.noteMode(.write)
            afterSwitch.teardown()

            // (ii) The detail tears down with no successor before the board mounts.
            #expect(await door.agentShow(.compare(noteID: world.anchor, peerIDs: [world.stranger])) == .navigate)
            #expect(session.commandRouter.pendingCompareLanding != nil, "parked again")
            session.commandRouter.unregisterDetail(back)
            #expect(session.commandRouter.pendingCompareLanding == nil,
                    "a genuine teardown ends the landing's round")
            // She opens the anchor again and ⌘5s.
            let again = session.commandRouter.registerDetail(postID: world.anchor, mode: .write) { _ in }
            defer { session.commandRouter.unregisterDetail(again) }
            let afterTeardown = try await herOwnCompare(session, db, on: world.anchor)
            expectHerColumns(afterTeardown, twin: world.twin)
            afterTeardown.teardown()
        }
    }

    // MARK: - The landing POSTURE's round (THE LADDER — ROUND 2, R2-1; fixed in the closeout's PHASE B)

    // `land(peers:)` arms the posture for the peers it named, and `adopt` applies it once, on the
    // first projection holding EVERY named peer. A named peer that never projects (deleted before
    // the board's first projection, its slot leaving) used to leave the posture armed with no
    // expiry, so a projection long after the landing could flip her own "related blocks only".
    // The round now ends at the first of: the board's teardown, a named peer's slot leaving, or
    // any set of the toggle by hand. Each test below isolates one ending, and the first is the
    // review's story whole.
    // RED on the pre-fix tree BY ASSERTION (the window runs it on the pin-only product): each of
    // the four fails at its LAST `#expect` with exactly ONE issue (4 tests failed, 4 issues; the
    // suite's other 7 green). The posture lands there on the old tree and overwrites the toggle.

    /// **The review's story.** The AI names the duplicate and a stranger. The stranger is deleted
    /// before the board's first projection and its column leaves. She turns "related blocks only"
    /// on herself. Later she restores the stranger and adds it back as a column. Her pick stands:
    /// the first projection to hold both named notes again is no landing any more.
    @Test func aNamedPeerThatNeverProjectsLeavesNoArmedPostureToOverwriteHerToggle() async throws {
        try await withCompareWorld { session, db in
            let world = try await makeWorld(session)
            let model = CompareViewModel(session: session, anchorPostID: world.anchor)
            model.land(peers: [world.twin, world.stranger])
            #expect(!model.relatedOnly, "nothing named is hidden while the lineage is read")

            // The stranger is deleted before the first projection; its column leaves.
            try await session.runner.run { ops in try ops.deleteContainer(world.stranger) }
            let strangerSlot = try #require(model.peerSlots.first { $0.postID == world.stranger })
            model.removePeerSlot(strangerSlot.id)
            try await adoptFresh(model, db, anchor: world.anchor, peers: model.peerSlots.compactMap(\.postID))
            #expect(!model.relatedOnly, "a projection missing a named peer decides nothing")

            model.relatedOnly.toggle()  // her own toggle, the chip's action
            #expect(model.relatedOnly)

            // Later: she restores the stranger and adds it back as a column herself.
            try await session.runner.run { ops in try ops.restoreContainer(world.stranger) }
            model.addPeerSlot()
            let empty = try #require(model.peerSlots.first { $0.postID == nil })
            model.setPeer(slotID: empty.id, postID: world.stranger)
            #expect(model.peerSlots.map(\.postID) == [world.twin, world.stranger])
            try await adoptFresh(model, db, anchor: world.anchor, peers: [world.twin, world.stranger])
            #expect(model.relatedOnly,
                    "her manual pick stands — the landing's mixed-set posture (off) never lands this late")
            model.teardown()
        }
    }

    /// **The board's teardown ends the round.** The AI names the duplicate, and the board goes
    /// (her ⌘1 within milliseconds) before any projection arrives. When the same model is shown
    /// again and a projection holding the duplicate arrives, it applies nothing: the filter
    /// stays as the board left it.
    @Test func aTornDownBoardNeverAppliesItsLandingsPostureAfterwards() async throws {
        try await withCompareWorld { session, db in
            let world = try await makeWorld(session)
            let model = CompareViewModel(session: session, anchorPostID: world.anchor)
            model.land(peers: [world.twin])
            #expect(!model.relatedOnly)
            model.teardown()

            // The board is shown again (a host keeping the model across onDisappear) and its
            // first projection holds the named duplicate.
            try await adoptFresh(model, db, anchor: world.anchor, peers: [world.twin])
            #expect(!model.relatedOnly,
                    "the landing's round ended with its board — the duplicate's posture (on) never lands afterwards")
            model.teardown()  // pairs the re-acquisition `adopt` made
        }
    }

    /// **Her own toggle ends the round.** The AI names a stranger, and she turns "related blocks
    /// only" on before the first projection is adopted (a projection deferred while a buffer
    /// settles is adopted at the settle). That projection applies nothing.
    @Test func herOwnToggleBeforeTheFirstProjectionEndsTheLandingsRound() async throws {
        try await withCompareWorld { session, db in
            let world = try await makeWorld(session)
            let model = CompareViewModel(session: session, anchorPostID: world.anchor)
            model.land(peers: [world.stranger])
            model.relatedOnly.toggle()  // her own toggle
            #expect(model.relatedOnly)
            try await adoptFresh(model, db, anchor: world.anchor, peers: [world.stranger])
            #expect(model.relatedOnly,
                    "her manual pick stands — the stranger's posture (off) never overwrites it")
            model.teardown()
        }
    }

    /// **A named peer's column leaving ends the round.** The AI names the duplicate, and she
    /// swaps that column to the stranger before the first projection. Later she adds the
    /// duplicate back as a column. The projection holding it applies nothing: the filter
    /// stays as she left it.
    @Test func aNamedPeersColumnLeavingEndsTheLandingsRound() async throws {
        try await withCompareWorld { session, db in
            let world = try await makeWorld(session)
            let model = CompareViewModel(session: session, anchorPostID: world.anchor)
            model.land(peers: [world.twin])
            let twinSlot = try #require(model.peerSlots.first)
            model.setPeer(slotID: twinSlot.id, postID: world.stranger)
            try await adoptFresh(model, db, anchor: world.anchor, peers: [world.stranger])
            #expect(!model.relatedOnly, "a projection missing the named peer decides nothing")

            model.addPeerSlot()
            let empty = try #require(model.peerSlots.first { $0.postID == nil })
            model.setPeer(slotID: empty.id, postID: world.twin)
            try await adoptFresh(model, db, anchor: world.anchor, peers: [world.stranger, world.twin])
            #expect(!model.relatedOnly,
                    "her columns are her own now — the duplicate's posture (on) never lands this late")
            model.teardown()
        }
    }
}
