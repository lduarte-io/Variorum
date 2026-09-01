import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

// Pre-13u Act 0, the Fable `Sync/` half (R-pre13u-1 + R-pre13u-8): the two
// FURNITURE convergence repairs. Both heal the same birth defect — two
// devices each correctly decided "this furniture does not exist yet", both
// minted it, and the pair met under sync. Each test asserts the SyncSpec §7
// trio: (a) the deterministic outcome, (b) both devices converge on the same
// choice, (c) every repair write reaches the outbox explicitly.

// MARK: - Shared plumbing

func furniturePair() throws -> (a: SyncClient, b: SyncClient, server: FakeSyncServer) {
    let server = FakeSyncServer()
    let a = try SyncClient(name: "A", prefix: "AA", transport: server)
    let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 1000, seed: 2)
    return (a, b, server)
}

func assertFurnitureConverged(
    _ a: SyncClient, _ b: SyncClient, _ server: FakeSyncServer
) async throws {
    try await syncToQuiescence(a, b, server: server)
    #expect(try a.syncedDump() == b.syncedDump(), "converged devices must be byte-identical")
}

private enum FurnitureTestError: Error {
    case journalDidNotShelve(String)
}

/// The number of outbox rows the push drain sends BEFORE the first row of
/// `table` — the drain sorts by registry order, so a mid-drain fault armed
/// after exactly this many rows lands every earlier table and nothing from
/// `table` onward (the chunk split the ladder's F1/F2 findings describe).
func outboxRowsAhead(of table: String, in client: SyncClient) throws -> Int {
    let boundary = SyncSchema.applyOrderIndex(of: table)
    return try client.db.read { db in
        try Row.fetchAll(db, sql: "SELECT table_name FROM sync_outbox")
            .filter { SyncSchema.applyOrderIndex(of: $0["table_name"]) < boundary }
            .count
    }
}

// MARK: - The Journal keeper (R-pre13u-1's second half)

/// Two designated daily-Journal books, minted independently offline (each
/// device correctly saw "no Journal exists"), converge at apply time: the
/// `tag.path` pattern — the smaller id keeps, the loser's memberships
/// re-point (deduping against the keeper's), the loser is tombstoned, and
/// the daily-book DESIGNATION converges to the keeper.
@Suite("Journal keeper repair (pre-13u Act 0, R-pre13u-1)")
struct JournalKeeperRepairTests {
    /// Mints the day's entry and shelves it — the four doors' shared shape,
    /// which is exactly what a fresh device's first write does. Creates and
    /// designates the Journal book when none exists (the #37(iii) ensure).
    private func mintJournal(
        _ client: SyncClient, day: String
    ) throws -> (bookID: String, entryID: String) {
        try client.with { ops, _ in
            let entry = try ops.createOrOpenJournalEntry(entryDate: day)
            let shelved = ops.shelveInDailyJournalBook(entry.container.id)
            guard case .shelved(let readingID) = shelved else {
                throw FurnitureTestError.journalDidNotShelve(String(describing: shelved))
            }
            return (readingID, entry.container.id)
        }
    }

    private func liveJournalBookIDs(_ client: SyncClient) throws -> [String] {
        try client.db.read { db in
            try String.fetchAll(
                db,
                sql: """
                    SELECT id FROM reading
                    WHERE kind = 'curated' AND profile = 'journal' AND deleted_at IS NULL
                    ORDER BY id
                    """)
        }
    }

    private func designation(_ client: SyncClient) throws -> String? {
        try client.db.fetchString(
            "SELECT value FROM setting WHERE key = 'daily_journal_book'")
    }

    @Test func twoOfflineMintedJournalBooksConvergeToTheSmallerIDKeeper() async throws {
        let (a, b, server) = try furniturePair()
        let journalA = try mintJournal(a, day: "2026-08-30")
        let journalB = try mintJournal(b, day: "2026-08-31")

        try await a.push()  // A's designation wins the setting CAS
        try await b.push()
        try await b.pull()

        // Deterministic outcome on B: A's book (AA… < BB…) is the keeper;
        // B's own Journal was tombstoned by the repair, its membership
        // re-pointed to the keeper — and every repair write is enqueued.
        #expect(try liveJournalBookIDs(b) == [journalA.bookID])
        #expect(try b.db.deletedAt("reading", journalB.bookID) != nil)
        #expect(try b.outboxContains("reading", journalB.bookID),
                "the loser's tombstone must push or the devices silently diverge")
        let movedMembership = try b.db.fetchString(
            "SELECT id FROM reading_post WHERE post_id = ? AND deleted_at IS NULL",
            [journalB.entryID])
        #expect(movedMembership != nil)
        #expect(try b.db.fetchString(
            "SELECT reading_id FROM reading_post WHERE post_id = ? AND deleted_at IS NULL",
            [journalB.entryID]) == journalA.bookID,
            "the loser's membership re-points to the keeper")
        if let movedMembership {
            #expect(try b.outboxContains("reading_post", movedMembership))
        }

        try await a.pull()
        // Same choice on A: the incoming (larger-id) Journal is retired.
        #expect(try liveJournalBookIDs(a) == [journalA.bookID])
        #expect(try a.db.deletedAt("reading", journalB.bookID) != nil)
        #expect(try a.outboxContains("reading", journalB.bookID))

        try await assertFurnitureConverged(a, b, server)
        // One Journal, both days' entries live inside it, the designation
        // naming the keeper — on both devices.
        for client in [a, b] {
            #expect(try liveJournalBookIDs(client) == [journalA.bookID])
            #expect(try client.db.fetchInt(
                """
                SELECT COUNT(*) FROM reading_post
                WHERE reading_id = ? AND deleted_at IS NULL
                """, [journalA.bookID]) == 2,
                "both devices' entries live in the ONE Journal")
            #expect(try designation(client) == journalA.bookID)
        }
    }

    @Test func aPostAlreadyOnTheKeeperDedupesTheLosersMembershipInstead() async throws {
        let (a, b, server) = try furniturePair()
        // A synced starting world holding one shared post.
        let shared: String = try a.with { ops, _ in
            try ops.createPost(title: "shared", profile: nil).id
        }
        try await a.push()
        try await b.pull()
        try await b.push()
        try await a.pull()

        // Both devices mint their own Journal offline and add the SAME post.
        let journalA = try mintJournal(a, day: "2026-08-30")
        try a.with { ops, _ in _ = try ops.addPostToReading(shared, to: journalA.bookID) }
        let journalB = try mintJournal(b, day: "2026-08-31")
        try b.with { ops, _ in _ = try ops.addPostToReading(shared, to: journalB.bookID) }

        try await a.push()
        try await b.push()
        try await b.pull()
        try await a.pull()
        try await assertFurnitureConverged(a, b, server)

        // The shared post keeps exactly ONE live membership (the keeper's) —
        // the loser's re-point would violate uq_reading_post_live, so it
        // tombstones instead (the tag.path application rule).
        for client in [a, b] {
            #expect(try client.db.fetchInt(
                "SELECT COUNT(*) FROM reading_post WHERE post_id = ? AND deleted_at IS NULL",
                [shared]) == 1)
            #expect(try client.db.fetchString(
                "SELECT reading_id FROM reading_post WHERE post_id = ? AND deleted_at IS NULL",
                [shared]) == journalA.bookID)
        }
    }

    @Test func theDesignationConvergesToTheKeeperEvenWhenTheLoserWonTheSettingRace() async throws {
        let (a, b, server) = try furniturePair()
        let journalA = try mintJournal(a, day: "2026-08-30")
        let journalB = try mintJournal(b, day: "2026-08-31")

        try await b.push()  // B's designation wins the setting CAS this time
        try await a.push()
        try await a.pull()

        // On A: the setting CAS carried B's book, but the keeper is A's
        // (smaller id) — the repair rewrites the designation to the keeper
        // and pushes it.
        #expect(try liveJournalBookIDs(a) == [journalA.bookID])
        #expect(try designation(a) == journalA.bookID)
        #expect(try a.outboxContains("setting", "daily_journal_book"),
                "the designation rewrite must push")

        try await b.pull()
        try await assertFurnitureConverged(a, b, server)
        for client in [a, b] {
            #expect(try designation(client) == journalA.bookID)
            #expect(try liveJournalBookIDs(client) == [journalA.bookID])
        }
        _ = journalB
    }

    @Test func aDeliberateBookNamedJournalIsNeverConverged() async throws {
        let (a, b, server) = try furniturePair()
        _ = try mintJournal(a, day: "2026-08-30")
        // B deliberately creates an ordinary book wearing the same name —
        // BookNaming's E13 doctrine: the offline name race is LEGAL, and a
        // name-keyed repair would delete a book she made on purpose. The
        // predicate is the system's own mint-mark (curated + profile
        // 'journal'), never the name.
        try b.with { ops, _ in
            let book = try ops.createReading(
                name: Operations.defaultDailyJournalBookName, kind: .curated, profile: "book")
            let post = try ops.createPost(title: "mine", profile: nil)
            _ = try ops.addPostToReading(post.id, to: book.id)
        }
        try await a.push()
        try await b.push()
        try await b.pull()
        try await a.pull()
        try await assertFurnitureConverged(a, b, server)

        for client in [a, b] {
            #expect(try client.db.fetchInt(
                """
                SELECT COUNT(*) FROM reading
                WHERE name = ? AND deleted_at IS NULL
                """, [Operations.defaultDailyJournalBookName]) == 2,
                "her deliberate same-name book survives beside the Journal")
        }
    }

    // MARK: The ladder's F6 — the predicate is the MINT's signature

    /// **RED ON OLD (F6, BLOCKER):** the product deliberately mints
    /// additional journal-profile notebooks — the Mac Shelf's "Create
    /// Journal Book" (§14 item 10's separate notebook) and the phone's
    /// `.journal` kind — and the old profile-only predicate merged them into
    /// the Journal on the next batch touching a reading. Single-device users
    /// too: the changefeed echoes the device's own accepted `reading` rows,
    /// the pull applies them verbatim, and the repair fires against the
    /// device's own two notebooks. Old code tombstones the larger id and
    /// moves its memberships; the narrowed predicate leaves both alone.
    @Test func twoDeliberateJournalNotebooksSurviveTheirOwnEcho() async throws {
        let (a, b, server) = try furniturePair()
        let daily = try mintJournal(a, day: "2026-08-30")
        // The Mac door's exact shape, twice: curated, the journal profile,
        // dated order — and names of her own (the door refuses the daily
        // book's name against the live Journal).
        let notebooks: [(bookID: String, postID: String)] = try a.with { ops, _ in
            try ["Work journal", "2027"].map { name in
                try ops.assertBookNameIsFree(name)
                let book = try ops.createReading(
                    name: name, kind: .curated, profile: Queries.dailyJournalBookProfile,
                    sortField: .entryDate, sortDir: .asc)
                let post = try ops.createPost(title: "an entry in \(name)", profile: .journal)
                _ = try ops.addPostToReading(post.id, to: book.id)
                return (book.id, post.id)
            }
        }

        try await a.push()
        let echo = try await a.pull()  // the device's own rows, echoed
        #expect(echo.applied > 0, "positive activity: the echo must land rows")
        #expect(echo.repairs == 0, "the repair must not fire on deliberate notebooks")

        for notebook in notebooks {
            #expect(try a.db.deletedAt("reading", notebook.bookID) == nil,
                    "a deliberate journal notebook must survive its own echo")
            #expect(try a.db.fetchString(
                "SELECT reading_id FROM reading_post WHERE post_id = ? AND deleted_at IS NULL",
                [notebook.postID]) == notebook.bookID,
                "and keep its own memberships — never merged into the Journal")
        }
        #expect(try liveJournalBookIDs(a).count == 3, "the Journal + two notebooks, all live")

        // A second device sees the same three, untouched, after convergence.
        try await assertFurnitureConverged(a, b, server)
        for client in [a, b] {
            #expect(try liveJournalBookIDs(client).count == 3)
            #expect(try designation(client) == daily.bookID)
        }
    }

    /// The drift guard between the mint and the predicate: what
    /// `shelveInDailyJournalBook` mints IS a candidate, and what the Shelf's
    /// door mints (the profile without the name) is NOT — so a change to
    /// either side announces itself here before it reaches a sync round.
    @Test func theDailyMintWearsTheKeeperSignatureAndADoorNotebookDoesNot() async throws {
        let (a, _, _) = try furniturePair()
        let daily = try mintJournal(a, day: "2026-08-30")
        let notebook: String = try a.with { ops, _ in
            try ops.createReading(
                name: "Untitled Journal", kind: .curated,
                profile: Queries.dailyJournalBookProfile,
                sortField: .entryDate, sortDir: .asc).id
        }
        let candidates = try await a.db.read { db in try Queries.dailyJournalBookCandidates(db) }
        #expect(candidates == [daily.bookID])
        #expect(!candidates.contains(notebook))
        // The name leg is BookNaming's key — case and end-whitespace fold,
        // nothing else (E13's letter): a "  journal " notebook IS the
        // Journal's shape; "Journal 2" is not.
        let readings = try await a.db.read { db in try Queries.readings(db) }
        let dailyRow = try #require(readings.first { $0.id == daily.bookID })
        var folded = dailyRow
        folded.name = "  JOURNAL "
        #expect(Queries.isDailyJournalMintShape(folded))
        var other = dailyRow
        other.name = "Journal 2"
        #expect(!Queries.isDailyJournalMintShape(other))
        var plainBook = dailyRow
        plainBook.profile = "book"
        #expect(!Queries.isDailyJournalMintShape(plainBook),
                "a plain book wearing the name is E13's legal same-name book, never a candidate")
    }

    /// **DOCUMENTED CORNER (QUESTIONS #85(a), the F6 amendment):** a daily
    /// Journal she RENAMED no longer converges with a fresh phone mint — the
    /// name leg reads the renamed book as her own notebook, so the two
    /// stand as separate journal-profile books until she merges them by
    /// hand. The honest consequence of narrowing the predicate; pinned so a
    /// later change to the name leg says so out loud.
    @Test func aRenamedDailyJournalStandsBesideAFreshMint() async throws {
        let (a, b, server) = try furniturePair()
        let renamed = try mintJournal(a, day: "2026-08-30")
        try a.with { ops, _ in try ops.renameReading(renamed.bookID, name: "My Journal") }
        let fresh = try mintJournal(b, day: "2026-08-31")

        try await a.push()
        try await b.push()
        try await b.pull()
        try await a.pull()
        try await assertFurnitureConverged(a, b, server)

        for client in [a, b] {
            #expect(try liveJournalBookIDs(client) == [renamed.bookID, fresh.bookID].sorted(),
                    "two journal-profile books stand — the renamed one is hers by name")
            #expect(try client.db.fetchInt(
                "SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND deleted_at IS NULL",
                [renamed.bookID]) == 1)
            #expect(try client.db.fetchInt(
                "SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND deleted_at IS NULL",
                [fresh.bookID]) == 1)
        }
    }

    // MARK: The ladder's F1 — arrival-order independence

    private func rowsAhead(of table: String, in client: SyncClient) throws -> Int {
        try outboxRowsAhead(of: table, in: client)
    }

    private func liveMemberships(_ client: SyncClient, in bookID: String) throws -> Int {
        try client.db.fetchInt(
            "SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND deleted_at IS NULL",
            [bookID]) ?? 0
    }

    private func syncAllToQuiescence(
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

    /// **RED ON OLD (F1, MAJOR — direction 1):** the repairer's loser
    /// tombstone (`reading`, registry index 51) and its re-pointed
    /// memberships (`reading_post`, 68) travel in different push chunks,
    /// each its own server transaction. A device that pulls between them
    /// applied the tombstone, its cascade killed the loser's N memberships
    /// locally, the orphan sweep pushed N tombstones, and the repairer's
    /// re-points then CAS-rejected into the tombstone-wins merge — the
    /// Journal ended with only the repairer's own entries, the loser's N
    /// bookless in the Pool, on BOTH devices. Now the loser's tombstone
    /// arriving beside a live keeper hands the memberships to the keeper
    /// before the cascade fires.
    @Test func theLosersTombstoneArrivingBeforeItsRepointsMovesTheMembershipsToTheKeeper() async throws {
        let server = FakeSyncServer()
        let transport = FaultInjectingTransport(server: server)
        // A (the smaller ids — the keeper's device) is the repairer whose
        // push splits; B holds the loser with N = 3 entries.
        let a = try SyncClient(name: "A", prefix: "AA", transport: transport)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 1000, seed: 2)

        var loser: (bookID: String, entryID: String)?
        var loserEntries: [String] = []
        for day in ["2026-08-28", "2026-08-29", "2026-08-30"] {
            let minted = try mintJournal(b, day: day)
            loser = minted
            loserEntries.append(minted.entryID)
        }
        let journalB = try #require(loser)
        try await b.push()

        let journalA = try mintJournal(a, day: "2026-08-31")
        try await a.pull()  // A's repair: keeper A, B's three memberships re-pointed, B's book retired
        #expect(try liveJournalBookIDs(a) == [journalA.bookID])
        #expect(try liveMemberships(a, in: journalA.bookID) == 4)

        // The connection dies after every `reading` row and before any
        // `reading_post` row: the server holds A's Journal and B's tombstone,
        // not the re-points.
        let split = try rowsAhead(of: "reading_post", in: a)
        #expect(split > 0)
        await transport.armFailNextPush(afterRows: split)
        await #expect(throws: InjectedNetworkFault.self) { try await a.push() }
        #expect(await server.currentRow(table: "reading", rowID: journalB.bookID)?.isTombstoned == true,
                "the loser's tombstone reached the server")
        #expect(await server.currentRow(table: "reading", rowID: journalA.bookID) != nil,
                "and so did the keeper")

        try await b.pull()
        // On B, between the chunks: the keeper holds B's three entries — the
        // tombstone moved them rather than killing them (old: 0).
        #expect(try liveJournalBookIDs(b) == [journalA.bookID])
        #expect(try liveMemberships(b, in: journalA.bookID) == 3,
                "the loser's memberships moved to the keeper BEFORE the cascade could take them")
        for entry in loserEntries {
            let membership = try b.db.read { db in
                try Row.fetchOne(
                    db,
                    sql: "SELECT id, reading_id FROM reading_post WHERE post_id = ? AND deleted_at IS NULL",
                    arguments: [entry])
            }
            #expect(membership?["reading_id"] as String? == journalA.bookID)
            if let id = membership?["id"] as String? {
                #expect(try b.outboxContains("reading_post", id),
                        "every repair write reaches the outbox (SyncSpec §7)")
            }
        }

        // A's retry lands the rest; both devices converge on N + 1.
        try await a.push()
        try await assertFurnitureConverged(a, b, server)
        for client in [a, b] {
            #expect(try liveJournalBookIDs(client) == [journalA.bookID])
            #expect(try liveMemberships(client, in: journalA.bookID) == 4,
                    "N + 1 live memberships on the keeper — nothing bookless in the Pool")
            #expect(try designation(client) == journalA.bookID)
        }
    }

    /// **RED ON OLD (round 2, R2-4 — MINOR):** direction 1 moved the
    /// children but never the DESIGNATION. Between the loser-tombstone chunk
    /// and the repairer's `setting` chunk, the loser's own device still
    /// named the (now dead) loser — which the liveness-filtered read reports
    /// as "no designation" — so its next entry MINTED a third mint-shape
    /// Journal (designated, pinned) that the next batch retired: a Trash
    /// row and a dangling pin she never caused. Now the designation follows
    /// the children to the keeper, and the entry shelves there.
    @Test func theDesignationFollowsTheKeeperBetweenTheChunks() async throws {
        let server = FakeSyncServer()
        let transport = FaultInjectingTransport(server: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: transport)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 1000, seed: 2)

        var loser: (bookID: String, entryID: String)?
        for day in ["2026-08-28", "2026-08-29", "2026-08-30"] {
            loser = try mintJournal(b, day: day)
        }
        let journalB = try #require(loser)
        try await b.push()

        let journalA = try mintJournal(a, day: "2026-08-31")
        try await a.pull()  // A's repair, as in the F1 pins
        let split = try rowsAhead(of: "reading_post", in: a)
        await transport.armFailNextPush(afterRows: split)
        await #expect(throws: InjectedNetworkFault.self) { try await a.push() }
        #expect(await server.currentRow(table: "setting", rowID: "daily_journal_book")
                    .flatMap { row -> String? in
                        if case .text(let value) = row.columns["value"] { return value }
                        return nil
                    } == journalB.bookID,
                "the server still names the loser — the repairer's rewrite lags")

        try await b.pull()
        // Between the chunks on B: the designation followed the children.
        #expect(try liveJournalBookIDs(b) == [journalA.bookID])
        #expect(try designation(b) == journalA.bookID,
                "the designation names the keeper (old: the dead loser — read as none)")
        #expect(try b.outboxContains("setting", "daily_journal_book"),
                "the designation rewrite reaches the outbox (SyncSpec §7)")
        // Her next entry, written HERE and NOW, shelves into the keeper.
        let today = try mintJournal(b, day: "2026-09-01")
        #expect(today.bookID == journalA.bookID,
                "shelved in the keeper (old: a third Journal minted)")
        #expect(try liveJournalBookIDs(b) == [journalA.bookID],
                "exactly one live Journal (old: two — the keeper and the fresh third)")

        try await a.push()
        try await assertFurnitureConverged(a, b, server)
        for client in [a, b] {
            #expect(try liveJournalBookIDs(client) == [journalA.bookID])
            #expect(try liveMemberships(client, in: journalA.bookID) == 5,
                    "N + 1 + today's entry, all on the keeper")
            #expect(try designation(client) == journalA.bookID)
            #expect(try client.db.fetchInt(
                "SELECT COUNT(*) FROM reading WHERE profile = 'journal'") == 2,
                "no third Journal was ever minted (old: a retired third row in the Trash)")
        }
    }

    /// **RED ON OLD (round 2, R2-2 — MAJOR):** direction 1 read the LOCAL
    /// row's shape only. A loser RENAMED on its own device before the
    /// repairer's tombstone landed is not mint-shape locally, so the
    /// tombstone became an ordinary delete: the cascade killed the N
    /// memberships, the victim sweep pushed N tombstones at the
    /// merge-stamped version, the server accepted them, and the repairer's
    /// lagging re-points CAS-rejected into tombstone-wins — the Journal
    /// emptied on BOTH devices (the keeper's own entry alone survived).
    /// Now the arriving tombstone's own columns — the repairer's verdict —
    /// satisfy the predicate too.
    @Test func aLoserRenamedLocallyStillHandsItsMembershipsToTheKeeper() async throws {
        let server = FakeSyncServer()
        let transport = FaultInjectingTransport(server: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: transport)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 1000, seed: 2)

        var loser: (bookID: String, entryID: String)?
        var loserEntries: [String] = []
        for day in ["2026-08-28", "2026-08-29", "2026-08-30"] {
            let minted = try mintJournal(b, day: day)
            loser = minted
            loserEntries.append(minted.entryID)
        }
        let journalB = try #require(loser)
        try await b.push()

        let journalA = try mintJournal(a, day: "2026-08-31")
        try await a.pull()  // A's repair: keeper A, B's three memberships re-pointed, B's book retired
        let split = try rowsAhead(of: "reading_post", in: a)
        await transport.armFailNextPush(afterRows: split)
        await #expect(throws: InjectedNetworkFault.self) { try await a.push() }

        // B, not yet having pulled, renames its Journal — the row is dirty
        // here and no longer wears the daily name.
        try b.with { ops, _ in try ops.renameReading(journalB.bookID, name: "My Journal") }
        #expect(try b.outboxContains("reading", journalB.bookID),
                "positive activity: the rename is a pending local edit")

        try await b.pull()
        // Between the chunks on B: the tombstone arrived under the daily
        // name — the repairer's verdict — and the memberships moved to the
        // keeper before the cascade could take them (old: 0).
        #expect(try liveJournalBookIDs(b) == [journalA.bookID])
        #expect(try liveMemberships(b, in: journalA.bookID) == 3,
                "the renamed loser's memberships moved to the keeper (old: killed by the cascade)")
        for entry in loserEntries {
            let membership = try b.db.read { db in
                try Row.fetchOne(
                    db,
                    sql: "SELECT id, reading_id FROM reading_post WHERE post_id = ? AND deleted_at IS NULL",
                    arguments: [entry])
            }
            #expect(membership?["reading_id"] as String? == journalA.bookID)
            if let id = membership?["id"] as String? {
                #expect(try b.outboxContains("reading_post", id),
                        "every repair write reaches the outbox (SyncSpec §7)")
            }
        }

        // A's retry lands the rest; production's rounds converge on N + 1.
        try await a.push()
        try await assertFurnitureConverged(a, b, server)
        for client in [a, b] {
            #expect(try liveJournalBookIDs(client) == [journalA.bookID])
            #expect(try liveMemberships(client, in: journalA.bookID) == 4,
                    "N + 1 live memberships on the keeper on both sides (old: the keeper's own only)")
            #expect(try designation(client) == journalA.bookID)
        }
    }

    /// **RED ON OLD (F1, MAJOR — the fresh-store leg of direction 1):** a
    /// device meeting the loser's rows for the FIRST time (a third device,
    /// a re-onboarded phone) while the repairer's re-points still lag its
    /// tombstone receives the memberships live (their seqs) and then the
    /// loser as an already-dead row (its only state) — an INSERT fires no
    /// cascade, so the memberships dangled live under a dead book, healed
    /// only if the repairer's retry ever lands. Now the loser landing dead
    /// beside a live keeper hands them to the keeper on arrival.
    @Test func aFreshStoreMeetingTheLoserDeadHandsItsMembershipsToTheKeeper() async throws {
        let server = FakeSyncServer()
        let transport = FaultInjectingTransport(server: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: transport)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 1000, seed: 2)
        let c = try SyncClient(name: "C", prefix: "CC", transport: server, clockOffset: 2000, seed: 3)

        var loser: (bookID: String, entryID: String)?
        var loserEntries: [String] = []
        for day in ["2026-08-28", "2026-08-29", "2026-08-30"] {
            let minted = try mintJournal(b, day: day)
            loser = minted
            loserEntries.append(minted.entryID)
        }
        let journalB = try #require(loser)
        try await b.push()

        let journalA = try mintJournal(a, day: "2026-08-31")
        try await a.pull()  // A's repair, as above
        let split = try rowsAhead(of: "reading_post", in: a)
        await transport.armFailNextPush(afterRows: split)
        await #expect(throws: InjectedNetworkFault.self) { try await a.push() }

        // C's first pull: the keeper live, the loser dead, and the loser's
        // three memberships still live and still naming the loser.
        let first = try await c.pull()
        #expect(first.applied > 0)
        #expect(try c.db.deletedAt("reading", journalB.bookID) != nil)
        #expect(try liveJournalBookIDs(c) == [journalA.bookID])
        // Three, not four: the keeper's OWN membership rides the lagging
        // chunk too — it lands with A's retry below.
        #expect(try liveMemberships(c, in: journalA.bookID) == 3,
                "the loser's memberships re-pointed to the keeper on arrival (old: dangling under the dead book)")
        // **RED ON OLD (round 2, R2-4 — the fresh-store leg):** the feed
        // still carried `setting = loser` (the repairer's rewrite rides its
        // lagging chunk) and delivered it AFTER the tombstone; the
        // post-batch pass found one live candidate and stood down, leaving
        // the designation dangling at the dead loser — the next ⌘J here
        // would have minted a THIRD Journal. Now it lands on the keeper.
        #expect(try designation(c) == journalA.bookID,
                "the designation converges to the keeper on the fresh store (old: dangling at the dead loser)")
        #expect(try c.outboxContains("setting", "daily_journal_book"),
                "the designation rewrite reaches the outbox (SyncSpec §7)")
        for entry in loserEntries {
            let membership = try c.db.read { db in
                try Row.fetchOne(
                    db,
                    sql: "SELECT id, reading_id, deleted_at FROM reading_post WHERE post_id = ?",
                    arguments: [entry])
            }
            #expect(membership?["deleted_at"] as String? == nil)
            #expect(membership?["reading_id"] as String? == journalA.bookID)
            if let id = membership?["id"] as String? {
                #expect(try c.outboxContains("reading_post", id))
            }
        }

        try await a.push()
        try await syncAllToQuiescence([a, b, c], server: server)
        let dumpA = try a.syncedDump()
        #expect(try b.syncedDump() == dumpA)
        #expect(try c.syncedDump() == dumpA)
        for client in [a, b, c] {
            #expect(try liveJournalBookIDs(client) == [journalA.bookID])
            #expect(try liveMemberships(client, in: journalA.bookID) == 4)
        }
    }

    /// **RED ON OLD (F1, MAJOR — direction 2):** a live membership arriving
    /// AFTER its loser is already dead here (the loser's device re-versioned
    /// it — a reorder — and pushed WITHOUT first pulling the repair; the
    /// engine's `push()` is an API-legal sequence even though the scheduler
    /// always pulls first) met the orphan repair: stamped dead with the
    /// loser's stamp, and that tombstone pushed and WON the merge against
    /// the repairer's re-point. Now it re-points to the standing keeper.
    @Test func aMembershipArrivingUnderTheDeadLoserRepointsToTheKeeper() async throws {
        let server = FakeSyncServer()
        let transport = FaultInjectingTransport(server: server)
        let a = try SyncClient(name: "A", prefix: "AA", transport: transport)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 1000, seed: 2)
        let journalB = try mintJournal(b, day: "2026-08-28")
        let second = try mintJournal(b, day: "2026-08-29")
        try await b.push()

        let journalA = try mintJournal(a, day: "2026-08-31")
        try await a.pull()   // A's repair: B's two memberships re-pointed, B's book retired
        // A's push splits: the loser's tombstone lands, the re-points lag.
        let split = try rowsAhead(of: "reading_post", in: a)
        await transport.armFailNextPush(afterRows: split)
        await #expect(throws: InjectedNetworkFault.self) { try await a.push() }

        // B, not yet having pulled, re-versions one of the memberships
        // (moves it) and pushes WITHOUT pulling: its base still matches the
        // server (the re-point never landed), so the row is ACCEPTED naming
        // the dead loser, at a seq AFTER the loser's tombstone.
        try b.with { ops, _ in
            try ops.reorderReadingPost(second.entryID, in: journalB.bookID, to: .start)
        }
        let pushed = try await b.push()
        #expect(pushed.accepted > 0, "positive activity: the re-versioned row landed live")

        // A pulls it: the row arrives live, naming the loser A already holds
        // dead, with the keeper standing — it re-points on arrival.
        let report = try await a.pull()
        #expect(report.applied + report.merged > 0)
        let landed = try await a.db.read { db in
            try Row.fetchOne(
                db,
                sql: "SELECT id, reading_id, deleted_at FROM reading_post WHERE post_id = ?",
                arguments: [second.entryID])
        }
        #expect(landed?["deleted_at"] as String? == nil, "never stamped dead (old: the orphan cascade)")
        #expect(landed?["reading_id"] as String? == journalA.bookID, "re-pointed to the keeper")
        if let id = landed?["id"] as String? {
            #expect(try a.outboxContains("reading_post", id))
        }

        try await assertFurnitureConverged(a, b, server)
        for client in [a, b] {
            #expect(try liveJournalBookIDs(client) == [journalA.bookID])
            #expect(try liveMemberships(client, in: journalA.bookID) == 3)
        }
    }

    /// Re-running rounds over a converged pair changes nothing — the repair
    /// finds one live Journal and stands down.
    @Test func theRepairIsIdempotentOnceConverged() async throws {
        let (a, b, server) = try furniturePair()
        _ = try mintJournal(a, day: "2026-08-30")
        _ = try mintJournal(b, day: "2026-08-31")
        try await a.push()
        try await b.push()
        try await b.pull()
        try await a.pull()
        try await assertFurnitureConverged(a, b, server)

        let settled = try a.syncedDump()
        try await syncToQuiescence(a, b, server: server)
        #expect(try a.syncedDump() == settled, "quiescent rounds must not re-fire the repair")
        #expect(try b.syncedDump() == settled)
    }
}
