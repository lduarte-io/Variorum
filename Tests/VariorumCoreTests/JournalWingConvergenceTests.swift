import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

// VX-435 + VX-436 (the VX-805 run) — THE DAILY JOURNAL UNDER SYNC, MOVABLE
// AND DELETABLE: the convergence matrix the ruled proposal names (the run
// record's Unit B "THE SYNC-HALF DESIGN PROPOSAL" §5 and "THE ORCHESTRATOR'S
// RULING"). Every scenario runs two (or three) in-memory clients against the
// fake server on the production path (real triggers, the real engine, E2EE
// payloads); every repair scenario asserts its EXPLICIT outbox rows and a
// positive activity count, and ends byte-identical at quiescence. Red-on-old
// is stated per test; the record carries the revert evidence.
//
//  K — the keeper goes wing-aware (its members land in its wing, by the mend)
//  M — the cross-wing mend (a moved Journal's offline entries follow it)
//  D — delete-then-remint (the deleted-Journal mark; no backfill by any door)
//  R — R-805-2 under sync (the Put back's demotion arrives demoted)

// MARK: - Plumbing

private enum JournalWingTestError: Error { case didNotShelve(String) }

/// The daily door's shared shape (⌘J / Today's Entry / the phone's capture):
/// the day's entry, then the shelving — the Journal minted where she stands
/// when none lives.
@discardableResult
private func file(
    _ client: SyncClient, day: String, standing: String = ""
) throws -> (bookID: String, entryID: String) {
    try client.with { ops, _ in
        let entry = try ops.createOrOpenJournalEntry(entryDate: day, standingWing: standing)
        let shelved = ops.shelveInDailyJournalBook(entry.container.id)
        guard case .shelved(let bookID) = shelved else {
            throw JournalWingTestError.didNotShelve(String(describing: shelved))
        }
        return (bookID, entry.container.id)
    }
}

private func liveDailyBooks(_ client: SyncClient) throws -> [String] {
    try client.db.read { db in
        try String.fetchAll(
            db, sql: """
                SELECT id FROM reading
                WHERE kind = 'book' AND profile = 'daily' AND deleted_at IS NULL ORDER BY id
                """)
    }
}

private func wingOf(_ client: SyncClient, post postID: String) throws -> String? {
    try client.db.fetchString("SELECT wing_id FROM container WHERE id = ?", [postID])
}

private func isLiveMember(_ client: SyncClient, _ postID: String, of bookID: String) throws -> Bool {
    try client.db.fetchInt(
        """
        SELECT COUNT(*) FROM reading_post
        WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL AND status = 'member'
        """, [bookID, postID]) == 1
}

/// The note's live tag applications as (path, wing) — what adoption by path
/// is judged on.
private func tagsWorn(_ client: SyncClient, post postID: String) throws -> [String] {
    try client.db.read { db in
        try Row.fetchAll(
            db, sql: """
                SELECT t.path AS path, t.wing_id AS wing FROM post_tag pt
                JOIN tag t ON t.id = pt.tag_id AND t.deleted_at IS NULL
                WHERE pt.post_id = ? AND pt.deleted_at IS NULL
                ORDER BY t.path
                """, arguments: [postID]
        ).map { "\($0["path"] as String)@\($0["wing"] as String)" }
    }
}

private func profileOf(_ client: SyncClient, _ readingID: String) throws -> String? {
    try client.db.fetchString("SELECT profile FROM reading WHERE id = ?", [readingID])
}

/// Three devices, one server, every one the same account.
private func syncAll(
    _ clients: [SyncClient], server: FakeSyncServer, maxRounds: Int = 12
) async throws {
    for _ in 1...maxRounds {
        for client in clients { try await client.push() }
        for client in clients { try await client.pull() }
        let head = await server.headSeq
        let quiet = try clients.allSatisfy { client in
            try client.outboxCount() == 0
                && client.db.fetchString(
                    "SELECT value FROM sync_state WHERE key = 'last_server_seq'") == String(head)
        }
        if quiet { return }
    }
    throw SyncHarnessError.neverQuiesced(maxRounds: maxRounds)
}

private func assertAllConverged(_ clients: [SyncClient], server: FakeSyncServer) async throws {
    try await syncAll(clients, server: server)
    let dumps = try clients.map { try $0.syncedDump() }
    for dump in dumps.dropFirst() {
        #expect(dump == dumps[0], "converged devices must be byte-identical")
    }
}

// MARK: - K: the keeper goes wing-aware

@Suite("VX-435 — K: the Journal keeper lands its members in its own wing (the mend composes after it)")
struct JournalKeeperWingTests {
    /// K1 — two offline mints in DIFFERENT wings (A in Home, B in a wing it
    /// made). The keeper is the smaller id (A's); B's entry, handed to it,
    /// MOVES into the keeper's wing; its tags adopt by path — "life" adopts
    /// A's Home twin, "studio-only" is minted in Home. RED ON OLD: the entry
    /// stayed in B's wing, a member of a Home book (a book spanning wings).
    @Test func k1_twoMintsInDifferentWingsConvergeIntoTheKeepersWing() async throws {
        let (a, b, server) = try furniturePair()
        let homeLife = try a.with { ops, _ in try ops.createTag(name: "life") }
        let journalA = try file(a, day: "2026-11-01")
        let studio = try b.with { ops, _ in try ops.createWing(name: "Studio") }
        let journalB = try file(b, day: "2026-11-02", standing: studio.id)
        #expect(try wingOf(b, post: journalB.entryID) == studio.id)
        try b.with { ops, _ in
            let life = try ops.createTag(name: "life", wingID: studio.id)
            let only = try ops.createTag(name: "studio-only", wingID: studio.id)
            _ = try ops.applyTag(life.id, toPost: journalB.entryID)
            _ = try ops.applyTag(only.id, toPost: journalB.entryID)
        }
        #expect(journalA.bookID < journalB.bookID, "A's Journal is the keeper by id")

        try await a.push()
        try await b.push()
        let pulled = try await b.pull()  // B meets A's Journal: keeper + mend

        #expect(pulled.repairs > 0, "positive activity: the keeper and the mend wrote")
        #expect(try liveDailyBooks(b) == [journalA.bookID])
        #expect(try isLiveMember(b, journalB.entryID, of: journalA.bookID))
        #expect(try wingOf(b, post: journalB.entryID) == "", "the entry moved into the keeper's wing")
        #expect(try tagsWorn(b, post: journalB.entryID) == ["life@", "studio-only@"],
                "its tags adopted by path in Home — one adopted, one minted")
        let adoptedLife = try b.db.fetchString(
            """
            SELECT pt.tag_id FROM post_tag pt JOIN tag t ON t.id = pt.tag_id
            WHERE pt.post_id = ? AND pt.deleted_at IS NULL AND t.path = 'life'
            """, [journalB.entryID])
        #expect(adoptedLife == homeLife.id, "the live same-path Home tag adopted the application")
        // The mend's every write is enqueued explicitly (apply mode).
        #expect(try b.outboxContains("container", journalB.entryID))
        let minted = try #require(try b.db.fetchString(
            "SELECT id FROM tag WHERE path = 'studio-only' AND wing_id = '' AND deleted_at IS NULL"))
        #expect(try b.outboxContains("tag", minted))
        for application in try await b.db.read({ db in
            try String.fetchAll(db, sql: "SELECT id FROM post_tag WHERE post_id = ?",
                                arguments: [journalB.entryID])
        }) {
            #expect(try b.outboxContains("post_tag", application), "every application row pushes")
        }

        try await assertAllConverged([a, b], server: server)
        for client in [a, b] {
            #expect(try liveDailyBooks(client) == [journalA.bookID])
            #expect(try wingOf(client, post: journalB.entryID) == "")
            #expect(try wingOf(client, post: journalA.entryID) == "")
            #expect(try tagsWorn(client, post: journalB.entryID) == ["life@", "studio-only@"])
        }
    }

    /// K2 — K1's mirror: the keeper lives in the wing (A minted there), so
    /// Home's entries move INTO the wing.
    @Test func k2_theKeeperInAWingDrawsHomesEntriesIn() async throws {
        let (a, b, server) = try furniturePair()
        let studio = try a.with { ops, _ in try ops.createWing(name: "Studio") }
        let journalA = try file(a, day: "2026-11-01", standing: studio.id)
        let journalB = try file(b, day: "2026-11-02")
        #expect(journalA.bookID < journalB.bookID)

        try await a.push()
        try await b.push()
        let pulled = try await b.pull()
        #expect(pulled.repairs > 0)
        #expect(try wingOf(b, post: journalB.entryID) == studio.id)
        #expect(try b.outboxContains("container", journalB.entryID))

        try await assertAllConverged([a, b], server: server)
        for client in [a, b] {
            #expect(try liveDailyBooks(client) == [journalA.bookID])
            #expect(try wingOf(client, post: journalB.entryID) == studio.id)
            #expect(try isLiveMember(client, journalB.entryID, of: journalA.bookID))
        }
    }

    /// K3 — K1 with the repairer's push SPLIT before `reading_post`, met by a
    /// THIRD device holding the loser's world live (direction 1, inline,
    /// cross-wing): the loser's tombstone hands its memberships to the keeper
    /// while the repairer's moved containers have already landed — so the
    /// third device holds the loser's entries IN THE KEEPER'S WING, members of
    /// the keeper, between the chunks; then all three converge. RED ON OLD:
    /// no device moved the entries — the keeper held members of another wing.
    @Test func k3_aSplitRepairerPushStillLandsTheMembersInTheKeepersWing() async throws {
        let server = FakeSyncServer()
        let transport = FaultInjectingTransport(server: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: transport)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 1000, seed: 2)
        let c = try SyncClient(name: "C", prefix: "CC", transport: server, clockOffset: 2000, seed: 3)

        let studio = try b.with { ops, _ in try ops.createWing(name: "Studio") }
        var loserEntries: [String] = []
        var loserBook = ""
        for day in ["2026-11-01", "2026-11-02"] {
            let minted = try file(b, day: day, standing: studio.id)
            loserBook = minted.bookID
            loserEntries.append(minted.entryID)
        }
        try await b.push()
        try await c.pull()  // C holds B's Journal and its entries live, in Studio
        #expect(try liveDailyBooks(c) == [loserBook])

        let journalA = try file(a, day: "2026-11-03")
        try await a.pull()  // A: keeper A, B's Journal retired, B's entries mended into Home
        for entry in loserEntries {
            #expect(try wingOf(a, post: entry) == "")
            #expect(try isLiveMember(a, entry, of: journalA.bookID))
        }

        let split = try outboxRowsAhead(of: "reading_post", in: a)
        #expect(split > 0)
        await transport.armFailNextPush(afterRows: split)
        await #expect(throws: InjectedNetworkFault.self) { try await a.push() }

        let pulled = try await c.pull()
        #expect(pulled.repairs > 0, "C's direction 1 handed the loser's children over")
        #expect(try liveDailyBooks(c) == [journalA.bookID])
        for entry in loserEntries {
            #expect(try wingOf(c, post: entry) == "", "the repairer's moved containers landed first")
            #expect(try isLiveMember(c, entry, of: journalA.bookID),
                    "the hand-over moved the membership — never the cascade")
        }

        try await assertAllConverged([a, b, c], server: server)
        for client in [a, b, c] {
            #expect(try liveDailyBooks(client) == [journalA.bookID])
            for entry in loserEntries {
                #expect(try wingOf(client, post: entry) == "")
                #expect(try isLiveMember(client, entry, of: journalA.bookID))
            }
        }
    }
}

// MARK: - M: the cross-wing mend

@Suite("VX-435 — M: a moved Journal's offline entries follow it (the cross-wing mend)")
struct JournalWingMendTests {
    /// The shared world: one Journal in Home with one entry, synced to both.
    private func syncedJournal(
        _ a: SyncClient, _ b: SyncClient
    ) async throws -> (bookID: String, entryID: String) {
        let journal = try file(a, day: "2026-11-01")
        try await a.push()
        try await b.pull()
        return journal
    }

    /// M1 + M2(a): A moves the Journal to a wing; B, offline, files the next
    /// day's entry in Home (beside the Journal as B sees it), tagged and with
    /// a saved version. A meets B's MEMBERSHIP landing (occasion (a)): the
    /// entry moves into the Journal's wing, its tag adopted by path, its
    /// saved version riding (ruling item 2 — one wing-move semantic). RED ON
    /// OLD: the entry stayed in Home, a member of a book in another wing.
    @Test func m1_anOfflineEntryFollowsTheMovedJournal_metAtTheMembership() async throws {
        let (a, b, server) = try furniturePair()
        let journal = try await syncedJournal(a, b)
        let studio = try a.with { ops, _ in try ops.createWing(name: "Studio") }
        _ = try a.with { ops, _ in try ops.moveReadingToWing(journal.bookID, to: studio.id) }

        let entry = try file(b, day: "2026-11-02")  // offline: the Journal is in Home here
        #expect(entry.bookID == journal.bookID)
        #expect(try wingOf(b, post: entry.entryID) == "")
        let version: String = try b.with { ops, _ in
            let tag = try ops.createTag(name: "dreams")
            _ = try ops.applyTag(tag.id, toPost: entry.entryID)
            _ = try ops.newBlock(in: entry.entryID, text: "last night", at: .end)
            return try ops.saveNoteVersion(entry.entryID).post.id
        }

        try await a.push()   // the move reaches the server first
        try await b.push()   // then B's entry and its membership
        let pulled = try await a.pull()  // A meets the membership: occasion (a)

        #expect(pulled.repairs > 0, "positive activity: the mend wrote")
        #expect(try wingOf(a, post: entry.entryID) == studio.id)
        #expect(try wingOf(a, post: version) == studio.id, "its saved version rides")
        #expect(try tagsWorn(a, post: entry.entryID) == ["dreams@\(studio.id)"],
                "its tag adopted by path — minted in the Journal's wing")
        #expect(try a.outboxContains("container", entry.entryID))
        #expect(try a.outboxContains("container", version))

        try await assertAllConverged([a, b], server: server)
        for client in [a, b] {
            #expect(try wingOf(client, post: entry.entryID) == studio.id)
            #expect(try wingOf(client, post: version) == studio.id)
            #expect(try isLiveMember(client, entry.entryID, of: journal.bookID))
            #expect(try tagsWorn(client, post: entry.entryID) == ["dreams@\(studio.id)"])
        }
    }

    /// M2(b): the OTHER arrival order — B pushes its entry first, then pulls
    /// A's moved Journal (occasion (b): the Journal landed with a changed
    /// wing; its members still in the wing it moved FROM follow it). The same
    /// converged outcome.
    @Test func m2_theOtherOrder_metAtTheJournalsLanding() async throws {
        let (a, b, server) = try furniturePair()
        let journal = try await syncedJournal(a, b)
        let studio = try a.with { ops, _ in try ops.createWing(name: "Studio") }
        let entry = try file(b, day: "2026-11-02")
        try await b.push()   // B's entry reaches the server first
        _ = try a.with { ops, _ in try ops.moveReadingToWing(journal.bookID, to: studio.id) }
        try await a.push()   // A has NOT pulled B's entry: it moved one member
        let pulled = try await b.pull()  // B meets the moved Journal: occasion (b)

        #expect(pulled.repairs > 0)
        #expect(try wingOf(b, post: entry.entryID) == studio.id, "B's own entry followed")
        #expect(try wingOf(b, post: journal.entryID) == studio.id, "A's member came with the move")
        #expect(try b.outboxContains("container", entry.entryID))

        try await assertAllConverged([a, b], server: server)
        for client in [a, b] {
            #expect(try wingOf(client, post: entry.entryID) == studio.id)
            #expect(try isLiveMember(client, entry.entryID, of: journal.bookID))
        }
    }

    /// M3 (a guard — green both sides): a membership arriving for a
    /// TOMBSTONED Journal never moves its note (her ruling: "the repair never
    /// moves a note for a dead book"). B files offline into the Journal A
    /// moved to a wing and then deleted; the entry stays where B made it.
    @Test func m3_aMembershipForADeadJournalNeverMovesItsNote() async throws {
        let (a, b, server) = try furniturePair()
        let journal = try await syncedJournal(a, b)
        let studio = try a.with { ops, _ in try ops.createWing(name: "Studio") }
        try a.with { ops, _ in
            _ = try ops.moveReadingToWing(journal.bookID, to: studio.id)
            try ops.deleteReading(journal.bookID)
        }
        let entry = try file(b, day: "2026-11-02")
        try await a.push()
        try await b.push()
        try await a.pull()
        #expect(try wingOf(a, post: entry.entryID) == "", "never moved for a dead book")
        try await assertAllConverged([a, b], server: server)
        for client in [a, b] {
            #expect(try wingOf(client, post: entry.entryID) == "")
            #expect(try liveDailyBooks(client).isEmpty)
        }
    }

    /// M4 (a guard on the occasion choice — green both sides): her
    /// deliberate note move OUT of the Journal, pushed split between its
    /// container row and its membership tombstone, is met by the other
    /// device between the chunks — a container landing is no occasion, so
    /// the mend never undoes her move.
    @Test func m4_aDeliberateMoveOutIsNeverUndoneBetweenTheChunks() async throws {
        let server = FakeSyncServer()
        let transport = FaultInjectingTransport(server: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: transport)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 1000, seed: 2)
        let journal = try await syncedJournal(a, b)
        let elsewhere = try a.with { ops, _ in try ops.createWing(name: "Elsewhere") }
        try await a.push()
        try await b.pull()
        _ = try a.with { ops, _ in try ops.moveNoteToWing(journal.entryID, to: elsewhere.id) }

        let split = try outboxRowsAhead(of: "reading_post", in: a)
        await transport.armFailNextPush(afterRows: split)
        await #expect(throws: InjectedNetworkFault.self) { try await a.push() }
        try await b.pull()  // between the chunks: the container moved, the membership not yet dead
        #expect(try wingOf(b, post: journal.entryID) == elsewhere.id)
        #expect(try !b.outboxContains("container", journal.entryID), "no mend fired")

        try await assertAllConverged([a, b], server: server)
        for client in [a, b] {
            #expect(try wingOf(client, post: journal.entryID) == elsewhere.id, "her move stands")
            #expect(try !isLiveMember(client, journal.entryID, of: journal.bookID))
        }
    }

    /// M5 (idempotence): after M1 converges, further rounds re-fire nothing.
    @Test func m5_quiescentRoundsAfterTheMendWriteNothing() async throws {
        let (a, b, server) = try furniturePair()
        let journal = try await syncedJournal(a, b)
        let studio = try a.with { ops, _ in try ops.createWing(name: "Studio") }
        _ = try a.with { ops, _ in try ops.moveReadingToWing(journal.bookID, to: studio.id) }
        _ = try file(b, day: "2026-11-02")
        try await assertAllConverged([a, b], server: server)
        let head = await server.headSeq
        for client in [a, b] {
            #expect(try await client.push().accepted == 0)
            #expect(try await client.pull().repairs == 0)
            #expect(try client.outboxCount() == 0)
        }
        #expect(await server.headSeq == head, "nothing re-fired")
    }
}

// MARK: - D: delete-then-remint (the deleted-Journal mark)

@Suite("VX-436 — D: her delete is never the keeper's retirement (no backfill by any door)")
struct JournalDeleteConvergenceTests {
    /// D1 — tombstone-before-mint ACROSS devices: A deletes; B pulls and
    /// re-mints; C held the old Journal live with an OFFLINE filing. The old
    /// Journal's entries never enter the new one; C's offline filing dies
    /// with the old book; C's next ⌘J files into the new Journal. RED ON OLD
    /// (the mark's belts reverted): C's filing re-pointed into the re-mint
    /// (direction 2).
    @Test func d1_tombstoneBeforeMintAcrossDevices() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 1000, seed: 2)
        let c = try SyncClient(name: "C", prefix: "CC", transport: server, clockOffset: 2000, seed: 3)
        let old = try file(a, day: "2026-11-01")
        try await a.push()
        try await b.pull()
        try await c.pull()
        let offline = try file(c, day: "2026-11-02")  // C, offline, files into the old Journal
        #expect(offline.bookID == old.bookID)

        try a.with { ops, _ in try ops.deleteReading(old.bookID) }
        try await a.push()
        try await b.pull()
        let fresh = try file(b, day: "2026-11-03")
        #expect(fresh.bookID != old.bookID)
        try await b.push()
        try await c.push()   // C's offline filing reaches the server
        let pulled = try await c.pull()
        #expect(pulled.applied > 0)

        try await assertAllConverged([a, b, c], server: server)
        for client in [a, b, c] {
            #expect(try liveDailyBooks(client) == [fresh.bookID])
            #expect(try !isLiveMember(client, old.entryID, of: fresh.bookID), "no backfill")
            #expect(try !isLiveMember(client, offline.entryID, of: fresh.bookID),
                    "C's offline filing died with the old book")
            #expect(try profileOf(client, old.bookID) == Queries.dailyJournalDeletedProfile)
        }
        let next = try file(c, day: "2026-11-04")
        #expect(next.bookID == fresh.bookID, "C's next ⌘J files into the new Journal")
    }

    /// D2 — mint-before-tombstone: ONE device deletes and re-mints in ONE
    /// push, the re-mint the SMALLER id (the old Journal was B's). B, holding
    /// the old Journal live with its own unpushed filing, backfills nothing.
    /// RED ON OLD: the drain sent the re-mint first and direction 1 handed
    /// the old Journal's children over.
    @Test func d2_deleteAndReMintInOnePushTheReMintSmaller() async throws {
        let (a, b, server) = try furniturePair()
        let old = try file(b, day: "2026-11-01")   // BB… — the larger prefix
        try await b.push()
        try await a.pull()
        let offline = try file(b, day: "2026-11-02") // unpushed on B
        try a.with { ops, _ in try ops.deleteReading(old.bookID) }
        let fresh = try file(a, day: "2026-11-03")   // AA… < BB…
        #expect(fresh.bookID < old.bookID, "the re-mint is the smaller id")
        try await a.push()  // the delete and the re-mint ride ONE push
        let oldSeq = try #require(await server.currentSeq(table: "reading", rowID: old.bookID))
        let freshSeq = try #require(await server.currentSeq(table: "reading", rowID: fresh.bookID))
        #expect(oldSeq < freshSeq, "belt (a): the delete drains ahead of the re-mint")

        try await b.pull()
        #expect(try liveDailyBooks(b) == [fresh.bookID])
        #expect(try !isLiveMember(b, old.entryID, of: fresh.bookID), "no hand-over")
        #expect(try !isLiveMember(b, offline.entryID, of: fresh.bookID))

        try await assertAllConverged([a, b], server: server)
        for client in [a, b] {
            #expect(try liveDailyBooks(client) == [fresh.bookID])
            #expect(try client.db.fetchInt(
                "SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND deleted_at IS NULL",
                [fresh.bookID]) == 1, "only the re-mint's own day")
        }
    }

    /// D2s — D2 with the push SPLIT right after the delete (the drain's own
    /// cut): a device pulling in the gap sees the old Journal dead and no
    /// re-mint — never two live 'daily' books (the door-(iii) merge never
    /// arises). RED ON OLD: the re-mint drained first; in the gap the keeper
    /// MERGED the two, retiring nothing she asked for and handing the old
    /// Journal's entries to the re-mint.
    @Test func d2s_aSplitPushNeverShowsTwoLiveJournals() async throws {
        let server = FakeSyncServer()
        let transport = FaultInjectingTransport(server: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: transport)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 1000, seed: 2)
        let old = try file(b, day: "2026-11-01")
        try await b.push()
        try await a.pull()
        try a.with { ops, _ in try ops.deleteReading(old.bookID) }
        let fresh = try file(a, day: "2026-11-03")
        // The first call carries every row up to and including the delete
        // (the drain's cut), then the connection dies.
        let first = try await a.db.read { db -> Int in
            let rows = try Row.fetchAll(db, sql: "SELECT table_name, row_id FROM sync_outbox")
                .compactMap { entry -> SyncRow? in
                    guard let table = SyncSchema.table(named: entry["table_name"]) else { return nil }
                    return try SyncRow.fetch(db, table: table, rowID: entry["row_id"])
                }
                .sorted(by: SyncEngine.precedesInDrain)
            return SyncEngine.drainChunks(rows, size: 200).first?.count ?? 0
        }
        await transport.armFailNextPush(afterRows: first)
        await #expect(throws: InjectedNetworkFault.self) { try await a.push() }
        #expect(await server.currentRow(table: "reading", rowID: old.bookID)?.isTombstoned == true)
        #expect(await server.currentRow(table: "reading", rowID: fresh.bookID) == nil,
                "the re-mint never shared the delete's call")

        try await b.pull()
        #expect(try liveDailyBooks(b).isEmpty, "the gap: no Journal, never two")
        #expect(try !isLiveMember(b, old.entryID, of: fresh.bookID))

        try await assertAllConverged([a, b], server: server)
        for client in [a, b] {
            #expect(try liveDailyBooks(client) == [fresh.bookID])
            #expect(try !isLiveMember(client, old.entryID, of: fresh.bookID))
        }
    }

    /// D3 — a LATE live child of the deleted Journal (push-without-pull)
    /// arriving where the re-mint stands joins the old book's cascade and is
    /// never re-pointed (direction 2 stands down on the mark). RED ON OLD
    /// (the mark reverted): re-pointed into the re-mint.
    @Test func d3_aLateChildOfTheDeletedJournalJoinsItsCascade() async throws {
        let (a, b, server) = try furniturePair()
        let old = try file(a, day: "2026-11-01")
        try await a.push()
        try await b.pull()
        let late = try file(b, day: "2026-11-02")      // B files offline into the old Journal
        try a.with { ops, _ in try ops.deleteReading(old.bookID) }
        let fresh = try file(a, day: "2026-11-03")
        try await a.push()
        try await b.push()   // push-without-pull: B's membership is accepted as a new row
        let pulled = try await a.pull()
        #expect(pulled.repairs > 0, "the orphan joined the cascade, enqueued")
        let lateMembership = try #require(try a.db.fetchString(
            "SELECT id FROM reading_post WHERE post_id = ?", [late.entryID]))
        #expect(try a.db.fetchString("SELECT reading_id FROM reading_post WHERE id = ?", [lateMembership])
                == old.bookID, "never re-pointed")
        #expect(try a.db.deletedAt("reading_post", lateMembership)
                == a.db.deletedAt("reading", old.bookID), "the old book's exact stamp")
        #expect(try a.outboxContains("reading_post", lateMembership))

        try await assertAllConverged([a, b], server: server)
        for client in [a, b] {
            #expect(try !isLiveMember(client, late.entryID, of: fresh.bookID))
            #expect(try liveDailyBooks(client) == [fresh.bookID])
        }
    }

    /// D4 — her delete REJECTED by a concurrent rename of the Journal on
    /// another device: the merged tombstone keeps the mark (belt (b)), and
    /// the same push's re-mint is HELD behind the rejected delete (the drain
    /// guard) — it reaches the server only after the merged delete does.
    /// RED BY CONSTRUCTION (belt (b) and the guard).
    @Test func d4_aRejectedDeleteKeepsItsMarkAndHoldsTheReMint() async throws {
        let (a, b, server) = try furniturePair()
        let old = try file(b, day: "2026-11-01")
        try await b.push()
        try await a.pull()
        try a.with { ops, _ in try ops.deleteReading(old.bookID) }
        let fresh = try file(a, day: "2026-11-03")
        try b.with { ops, _ in try ops.renameReading(old.bookID, name: "days") }
        try await b.push()   // the rename lands first

        let pushed = try await a.push()
        #expect(pushed.rejected > 0, "the delete met the rename")
        let landed = try #require(await server.currentRow(table: "reading", rowID: old.bookID))
        #expect(landed.isTombstoned)
        #expect(landed.columns["profile"] == .text(Queries.dailyJournalDeletedProfile),
                "belt (b): the mark rode the merged tombstone")
        let oldSeq = try #require(await server.currentSeq(table: "reading", rowID: old.bookID))
        let freshSeq = try #require(await server.currentSeq(table: "reading", rowID: fresh.bookID))
        #expect(oldSeq < freshSeq, "the guard held the re-mint behind the merged delete")

        try await assertAllConverged([a, b], server: server)
        for client in [a, b] {
            #expect(try liveDailyBooks(client) == [fresh.bookID])
            #expect(try profileOf(client, old.bookID) == Queries.dailyJournalDeletedProfile)
            #expect(try !isLiveMember(client, old.entryID, of: fresh.bookID))
        }
    }

    /// D5 — (true, true): a third device's RETIREMENT of the same book
    /// (`'daily'` — made on an incomplete picture) already stands on the
    /// server when her delete arrives: her mark outranks it. RED BY
    /// CONSTRUCTION (belt (b)'s both-dead arm).
    @Test func d5_herMarkOutranksARetirementOfTheSameBook() async throws {
        let (a, b, server) = try furniturePair()
        let old = try file(a, day: "2026-11-01")
        try await a.push()
        try await b.pull()
        // B retires it as the keeper would (a raw 'daily' tombstone — the
        // repair's own write shape) and pushes first.
        try b.with { _, db in
            let stamp = DateFormatter.variorumISO8601.string(from: Date(timeIntervalSince1970: 1_782_864_500))
            try db.write {
                try $0.execute(
                    sql: "UPDATE reading SET deleted_at = ?, updated_at = ? WHERE id = ?",
                    arguments: [stamp, stamp, old.bookID])
            }
        }
        try await b.push()
        try a.with { ops, _ in try ops.deleteReading(old.bookID) }
        let pushed = try await a.push()
        #expect(pushed.rejected > 0)
        let landed = try #require(await server.currentRow(table: "reading", rowID: old.bookID))
        #expect(landed.columns["profile"] == .text(Queries.dailyJournalDeletedProfile))
        try await assertAllConverged([a, b], server: server)
        for client in [a, b] {
            #expect(try profileOf(client, old.bookID) == Queries.dailyJournalDeletedProfile)
        }
    }

    /// D6 (the "exactly as today" guard — green both sides): after a delete,
    /// two devices re-mint concurrently — the TRUE race — and converge to one
    /// Journal by the keeper exactly as ever; the deleted one stays dead and
    /// inert.
    @Test func d6_theTrueRaceAfterADeleteConvergesAsToday() async throws {
        let (a, b, server) = try furniturePair()
        let old = try file(a, day: "2026-11-01")
        try await a.push()
        try await b.pull()
        try a.with { ops, _ in try ops.deleteReading(old.bookID) }
        try await a.push()
        try await b.pull()
        let mintA = try file(a, day: "2026-11-02")
        let mintB = try file(b, day: "2026-11-03")
        let keeper = min(mintA.bookID, mintB.bookID)
        try await assertAllConverged([a, b], server: server)
        for client in [a, b] {
            #expect(try liveDailyBooks(client) == [keeper])
            #expect(try isLiveMember(client, mintA.entryID, of: keeper))
            #expect(try isLiveMember(client, mintB.entryID, of: keeper))
            #expect(try client.db.deletedAt("reading", old.bookID) != nil)
            #expect(try !isLiveMember(client, old.entryID, of: keeper), "the deleted one stays inert")
        }
    }
}

// MARK: - R: R-805-2 under sync

@Suite("VX-436 — R: the Journal's Put back under sync")
struct JournalPutBackConvergenceTests {
    /// R1 — a Put back BESIDE a standing Journal arrives everywhere already
    /// demoted: the other device never meets two live 'daily' books. RED ON
    /// OLD: the restoree returned wearing its marker and the keeper merged.
    @Test func r1_aPutBackBesideAStandingJournalArrivesDemoted() async throws {
        let (a, b, server) = try furniturePair()
        let old = try file(a, day: "2026-11-01")
        try a.with { ops, _ in try ops.deleteReading(old.bookID) }
        let fresh = try file(a, day: "2026-11-02")
        try await assertAllConverged([a, b], server: server)
        try a.with { ops, _ in try ops.restoreReading(old.bookID) }
        try await a.push()
        let pulled = try await b.pull()
        #expect(pulled.applied > 0)
        #expect(try liveDailyBooks(b) == [fresh.bookID], "one live Journal on B")
        #expect(try profileOf(b, old.bookID) == Queries.journalTraitProfile)
        #expect(try isLiveMember(b, old.entryID, of: old.bookID), "returned whole")
        try await assertAllConverged([a, b], server: server)
    }

    /// R2 — with NONE standing, THE Journal returns everywhere (the mark
    /// normalized), the designation cache with it.
    @Test func r2_aPutBackWithNoneStandingReturnsTheJournalEverywhere() async throws {
        let (a, b, server) = try furniturePair()
        let old = try file(a, day: "2026-11-01")
        try a.with { ops, _ in try ops.deleteReading(old.bookID) }
        try await assertAllConverged([a, b], server: server)
        #expect(try liveDailyBooks(b).isEmpty)
        try a.with { ops, _ in try ops.restoreReading(old.bookID) }
        try await assertAllConverged([a, b], server: server)
        for client in [a, b] {
            #expect(try liveDailyBooks(client) == [old.bookID])
            #expect(try client.db.fetchString(
                "SELECT value FROM setting WHERE key = 'daily_journal_book'") == old.bookID)
        }
    }

    /// R3 (DOCUMENTED — P-805-B1): a Put back on one device concurrent with a
    /// re-mint on another (neither saw the other) is byte-for-byte the
    /// duplicate-mint race and converges as it does: the smaller id keeps,
    /// the other's children move in, one Journal.
    @Test func r3_aConcurrentPutBackAndReMintConvergeAsTheRace() async throws {
        let (a, b, server) = try furniturePair()
        let old = try file(a, day: "2026-11-01")
        try a.with { ops, _ in try ops.deleteReading(old.bookID) }
        try await assertAllConverged([a, b], server: server)
        try a.with { ops, _ in try ops.restoreReading(old.bookID) }  // none standing on A
        let fresh = try file(b, day: "2026-11-02")                   // none standing on B
        try await assertAllConverged([a, b], server: server)
        let keeper = min(old.bookID, fresh.bookID)
        for client in [a, b] {
            #expect(try liveDailyBooks(client) == [keeper])
            #expect(try isLiveMember(client, old.entryID, of: keeper))
            #expect(try isLiveMember(client, fresh.entryID, of: keeper))
        }
    }
}

// MARK: - DO: the drain order and its guard, pure

@Suite("VX-436 — DO: the deleted-Journal tombstone drains first, in its own call")
struct JournalDrainOrderTests {
    private func row(_ table: String, _ id: String, dead: Bool = false, profile: String? = nil) -> SyncRow {
        var columns: [String: SyncValue] = [:]
        if dead { columns["deleted_at"] = .text("2026-11-05T00:00:00.000Z") }
        if let profile { columns["profile"] = .text(profile) }
        return SyncRow(table: table, rowID: id, columns: columns, syncVersion: 0)
    }

    /// The comparator: inside `reading`, a deleted-Journal tombstone sorts
    /// first; a 'daily' RETIREMENT tombstone still sorts by id (R2-7 — the
    /// keeper's insert ahead of the loser's tombstone); every other table
    /// and the cross-table order are untouched. RED ON OLD (the first half).
    @Test func theMarkSortsFirstAndARetirementStillSortsByID() {
        let shuffled = [
            row("reading_post", "AA"), row("reading", "CC", dead: true, profile: "daily_deleted"),
            row("reading", "AA"), row("reading", "BB", dead: true, profile: "daily"),
            row("container", "ZZ"),
        ]
        let drained = shuffled.sorted(by: SyncEngine.precedesInDrain).map { "\($0.table)/\($0.rowID)" }
        #expect(drained == ["container/ZZ", "reading/CC", "reading/AA", "reading/BB", "reading_post/AA"])
        for x in shuffled {
            for y in shuffled where x != y {
                #expect(!(SyncEngine.precedesInDrain(x, y) && SyncEngine.precedesInDrain(y, x)))
            }
        }
        // A LIVE row wearing the mark (never written — a restore normalizes)
        // is not a tombstone and sorts by id.
        #expect(!SyncEngine.isDeletedJournalTombstone(row("reading", "X", profile: "daily_deleted")))
        #expect(!SyncEngine.isDeletedJournalTombstone(row("container", "X", dead: true, profile: "daily_deleted")))
    }

    /// The chunks: ONE extra cut right after the last deleted-Journal
    /// tombstone; without one, byte-identical to the plain stride.
    @Test func theChunksCutRightAfterTheMark() {
        let plain = (0..<5).map { row("container", "C\($0)") }
        #expect(SyncEngine.drainChunks(plain, size: 2).map(\.count) == [2, 2, 1])
        let marked = [row("container", "C0"), row("reading", "J", dead: true, profile: "daily_deleted"),
                      row("reading", "R1"), row("reading_post", "P1")]
        let chunks = SyncEngine.drainChunks(marked, size: 200)
        #expect(chunks.map { $0.map(\.rowID) } == [["C0", "J"], ["R1", "P1"]])
        #expect(SyncEngine.drainChunks(marked, size: 1).map(\.count) == [1, 1, 1, 1])
    }
}
