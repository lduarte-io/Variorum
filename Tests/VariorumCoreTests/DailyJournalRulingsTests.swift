import Foundation
import GRDB
import Testing

@testable import VariorumCore

// 13i-e U1 — THE DAILY JOURNAL AS RULED (the sitting record §10; the identity
// memo §3/§4/§5 edge 5; the binding record is the 13i-e plan's U1 RECORD):
//
// - THE GUARD — "the daily Journal can be archived, never deleted": both
//   delete doors refuse a book wearing the 'daily' marker, inside their own
//   write transaction. (Red on old, by revert: the old tree tombstoned it.)
// - THE DERIVATION — the designation IS the marker: `dailyJournalBookID` reads
//   the keeper's own smallest-id pick over the live marker-bearers; the
//   `daily_journal_book` setting is a written CACHE, never read for it. (Red
//   on old, by revert: a marker/setting disagreement answered the setting,
//   and a dangling setting beside a live marker-bearer let ⌘J mint a second
//   Journal.)
// - THE COMES-BACK — "it returns when a day arrives": the shelving door
//   un-archives an archived Journal in its own transaction before filing.
//   (Red on old, by revert: the old tree filed into it and left it archived.)

// MARK: - Fixtures

/// The day's entry minted and shelved — the doors' shared shape (⌘J, Today's
/// Entry, the phone's capture). Creates the Journal on the first call.
private func file(_ ops: Operations, day: String) throws -> (bookID: String, entryID: String) {
    let entry = try ops.createOrOpenJournalEntry(entryDate: day)
    let outcome = ops.shelveInDailyJournalBook(entry.container.id)
    guard case .shelved(let bookID) = outcome else {
        throw DailyFixtureError.didNotShelve(String(describing: outcome))
    }
    return (bookID, entry.container.id)
}

private enum DailyFixtureError: Error {
    case didNotShelve(String)
}

/// A daily Journal that died the only ways one still can: an older build's
/// delete, or another device's tombstone arriving under sync. A raw row write
/// — the delete door itself refuses now (that is the point of this file).
/// The tombstone-propagation triggers fire exactly as they did for the op.
private func tombstoneAsAnOlderBuildWould(_ db: AppDatabase, readingID: String) throws {
    let stamp = DateFormatter.variorumISO8601.string(from: harnessNow)
    try db.write { db in
        try db.execute(
            sql: "UPDATE reading SET deleted_at = ?, updated_at = ? WHERE id = ?",
            arguments: [stamp, stamp, readingID])
    }
}

/// The cached designation, written raw — the shape a synced setting row
/// lands in (its CAS carries another device's write independently of the
/// marker's row). UPDATE-then-INSERT, the repo's one upsert shape
/// (`Operations.upsertSetting` — an ON CONFLICT would fire the outbox
/// trigger twice).
private func setCachedDesignation(_ db: AppDatabase, to value: String?) throws {
    try db.write { db in
        if let value {
            try db.execute(
                sql: "UPDATE setting SET value = ? WHERE key = 'daily_journal_book'",
                arguments: [value])
            if db.changesCount == 0 {
                try db.execute(
                    sql: "INSERT INTO setting (key, value) VALUES ('daily_journal_book', ?)",
                    arguments: [value])
            }
        } else {
            try db.execute(sql: "DELETE FROM setting WHERE key = 'daily_journal_book'")
        }
    }
}

private func liveDailyBooks(_ db: AppDatabase) throws -> [String] {
    try db.read {
        try String.fetchAll(
            $0, sql: """
                SELECT id FROM reading
                WHERE kind = 'book' AND profile = 'daily' AND deleted_at IS NULL ORDER BY id
                """)
    }
}

private func liveMember(_ db: AppDatabase, _ postID: String, of readingID: String) throws -> Bool {
    try db.fetchInt(
        """
        SELECT COUNT(*) FROM reading_post
        WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL AND status = 'member'
        """, [readingID, postID]) == 1
}

private func archivedAt(_ db: AppDatabase, _ table: String, _ id: String) throws -> String? {
    try db.fetchString("SELECT archived_at FROM \(table) WHERE id = ?", [id])
}

// MARK: - The guard

@Suite("13i-e U1 — the daily Journal can be archived, never deleted (the guard)")
struct DailyJournalDeleteGuardTests {
    /// RED ON OLD (R1, by revert): the old `deleteReading` tombstoned it.
    @Test func deleteReadingRefusesTheDailyJournal() throws {
        try withOperations { ops, db in
            let daily = try file(ops, day: "2026-10-01")
            try db.clearOutbox()

            #expect(throws: OperationError.dailyJournalCannotBeDeleted(id: daily.bookID)) {
                try ops.deleteReading(daily.bookID)
            }

            #expect(try db.deletedAt("reading", daily.bookID) == nil)
            #expect(try liveMember(db, daily.entryID, of: daily.bookID))
            #expect(try db.fetchInt("SELECT COUNT(*) FROM sync_outbox") == 0, "nothing was written")
        }
    }

    /// RED ON OLD (R1, by revert): the old `deleteReadingWithNotes` sent the
    /// Journal AND its entries to the Trash.
    @Test func deleteReadingWithNotesRefusesTheDailyJournalAndTouchesNoEntry() throws {
        try withOperations { ops, db in
            let daily = try file(ops, day: "2026-10-01")

            #expect(throws: OperationError.dailyJournalCannotBeDeleted(id: daily.bookID)) {
                try ops.deleteReadingWithNotes(daily.bookID)
            }

            #expect(try db.deletedAt("reading", daily.bookID) == nil)
            #expect(try db.deletedAt("container", daily.entryID) == nil)
            #expect(try liveMember(db, daily.entryID, of: daily.bookID))
        }
    }

    /// The guard keys on the MARKER — never the name, never the setting: a
    /// RENAMED Journal still refuses; a journal-TRAIT notebook named
    /// "Journal" deletes; moving the designation moves the protection.
    @Test func theGuardKeysOnTheMarker() throws {
        try withOperations { ops, db in
            let daily = try file(ops, day: "2026-10-01")
            try ops.renameReading(daily.bookID, name: "Days")
            #expect(throws: OperationError.dailyJournalCannotBeDeleted(id: daily.bookID)) {
                try ops.deleteReading(daily.bookID)
            }
            let notebook = try ops.createReading(
                name: "Journal", kind: .book, profile: Queries.journalTraitProfile)
            try ops.setDailyJournalBook(notebook.id)            // the marker moves
            try ops.deleteReading(daily.bookID)                 // now a trait book: deletable
            #expect(try db.deletedAt("reading", daily.bookID) != nil)
            #expect(throws: OperationError.dailyJournalCannotBeDeleted(id: notebook.id)) {
                try ops.deleteReadingWithNotes(notebook.id)
            }
        }
    }

    /// The road the refusal names: archive is legal on the daily Journal.
    @Test func archiveIsTheDailyJournalsRoad() throws {
        try withOperations { ops, db in
            let daily = try file(ops, day: "2026-10-01")
            try ops.archiveReading(daily.bookID)
            #expect(try archivedAt(db, "reading", daily.bookID) != nil)
            #expect(try db.read { try Queries.dailyJournalBookID($0) } == daily.bookID,
                    "an archived Journal is still THE daily Journal (it is live)")
        }
    }
}

// MARK: - The derivation

@Suite("13i-e U1 — the designation is DERIVED from the marker (the setting is a cache)")
struct DailyJournalDerivationTests {
    /// RED ON OLD (R2, by revert): a marker/setting disagreement (the setting
    /// CAS can carry another device's write) answered the SETTING.
    @Test func theMarkerAnswersWhenTheCachedSettingDisagrees() throws {
        try withOperations { ops, db in
            let daily = try file(ops, day: "2026-10-01")
            let notebook = try ops.createReading(
                name: "Dreams", kind: .book, profile: Queries.journalTraitProfile)
            try setCachedDesignation(db, to: notebook.id)

            #expect(try db.read { try Queries.dailyJournalBookID($0) } == daily.bookID)
            let next = try file(ops, day: "2026-10-02")
            #expect(next.bookID == daily.bookID, "⌘J files into the marker-bearer")
            #expect(try !liveMember(db, next.entryID, of: notebook.id))
        }
    }

    /// RED ON OLD (R2, by revert): a DANGLING setting beside a live
    /// marker-bearer read as "no Journal", so ⌘J minted a SECOND one (and
    /// demoted the first to the trait — the double-mint).
    @Test func aDanglingSettingBesideALiveMarkerBearerNoLongerDoubleMints() throws {
        try withOperations { ops, db in
            let daily = try file(ops, day: "2026-10-01")
            try setCachedDesignation(db, to: "a-reading-that-is-gone")

            let next = try file(ops, day: "2026-10-02")

            #expect(next.bookID == daily.bookID)
            #expect(try liveDailyBooks(db) == [daily.bookID], "one Journal, still wearing the marker")
            #expect(try db.fetchInt("SELECT COUNT(*) FROM reading WHERE deleted_at IS NULL") == 1)
        }
    }

    /// The marker can arrive under sync before the setting does: no setting
    /// row at all beside a live marker-bearer files there too.
    @Test func aMissingSettingBesideALiveMarkerBearerFilesThere() throws {
        try withOperations { ops, db in
            let daily = try file(ops, day: "2026-10-01")
            try setCachedDesignation(db, to: nil)

            #expect(try db.read { try Queries.dailyJournalBookID($0) } == daily.bookID)
            #expect(try file(ops, day: "2026-10-02").bookID == daily.bookID)
            #expect(try liveDailyBooks(db) == [daily.bookID])
        }
    }

    /// The setting ALONE no longer designates (the documented consequence the
    /// U1 RECORD's F-U1-1 names): a live book the cache points at, wearing NO
    /// marker, is not the daily Journal — the next day mints one fresh, and
    /// the cache follows the mint.
    @Test func theCachedSettingAloneNoLongerDesignates() throws {
        try withOperations { ops, db in
            let notebook = try ops.createReading(
                name: "Journal", kind: .book, profile: Queries.journalTraitProfile)
            try setCachedDesignation(db, to: notebook.id)

            #expect(try db.read { try Queries.dailyJournalBookID($0) } == nil)
            let minted = try file(ops, day: "2026-10-01")
            #expect(minted.bookID != notebook.id)
            #expect(try liveDailyBooks(db) == [minted.bookID])
            #expect(try db.fetchString(
                "SELECT value FROM setting WHERE key = 'daily_journal_book'") == minted.bookID)
        }
    }

    /// The writers keep the cache fresh, byte-unchanged (the memo §3's
    /// blessed letter): the mint and `setDailyJournalBook` write it beside
    /// the marker; two marker-bearers mid-convergence read the keeper's pick.
    @Test func theCacheIsStillWrittenAndTheReadIsTheKeepersPick() throws {
        try withOperations { ops, db in
            let daily = try file(ops, day: "2026-10-01")
            #expect(try db.fetchString(
                "SELECT value FROM setting WHERE key = 'daily_journal_book'") == daily.bookID)
            let other = try ops.createReading(name: "Other", kind: .book)
            try ops.setDailyJournalBook(other.id)
            #expect(try db.fetchString(
                "SELECT value FROM setting WHERE key = 'daily_journal_book'") == other.id)
            #expect(try db.read { try Queries.dailyJournalBookID($0) } == other.id)
            // Two marker-bearers (an offline race not yet repaired): the read
            // is the keeper's own smallest-id pick, whatever the cache says.
            try db.write { db in
                try db.execute(sql: "UPDATE reading SET profile = 'daily' WHERE id = ?",
                               arguments: [daily.bookID])
            }
            let keeper = try #require(try liveDailyBooks(db).first)
            #expect(try db.read { try Queries.dailyJournalBookID($0) } == keeper)
            #expect(try db.read { try Queries.dailyJournalBookCandidates($0) }.first == keeper)
        }
    }
}

// MARK: - The comes-back

@Suite("13i-e U1 — it returns when a day arrives (the comes-back)")
struct DailyJournalComesBackTests {
    /// RED ON OLD (R3, by revert): the day was filed into the archived
    /// Journal and the Journal STAYED archived — out of the Bookcase, with
    /// today's entry inside it.
    @Test func aDayArrivingBringsAnArchivedJournalBackAndFilesIntoIt() throws {
        try withOperations { ops, db in
            let daily = try file(ops, day: "2026-10-01")
            try ops.archiveReading(daily.bookID)
            try db.clearOutbox()

            let today = try file(ops, day: "2026-10-02")

            #expect(today.bookID == daily.bookID, "the SAME book back, never a second mint")
            #expect(try archivedAt(db, "reading", daily.bookID) == nil, "it came back")
            #expect(try liveMember(db, today.entryID, of: daily.bookID))
            #expect(try liveDailyBooks(db) == [daily.bookID])
            #expect(try db.read { try Queries.bookshelf($0, wingID: "") }.map(\.reading.id)
                    == [daily.bookID], "back on the Bookcase")
            #expect(try db.outboxContains("reading", daily.bookID))
        }
    }

    /// The comes-back IS the unarchive: a Journal archived WITH its entries
    /// brings them back too (the exact-stamp return), then files the day.
    @Test func theComesBackReturnsTheEntriesArchivedWithTheJournal() throws {
        try withOperations { ops, db in
            let first = try file(ops, day: "2026-10-01")
            try ops.archiveReadingWithNotes(first.bookID)
            #expect(try archivedAt(db, "container", first.entryID) != nil)

            let today = try file(ops, day: "2026-10-02")

            #expect(today.bookID == first.bookID)
            #expect(try archivedAt(db, "container", first.entryID) == nil)
            #expect(try db.read { try Queries.assembleReading($0, readingID: first.bookID) }
                .map(\.postID).sorted() == [first.entryID, today.entryID].sorted())
        }
    }

    /// P-13ie-U1-12: a REFUSED filing still brings the Journal back — the day
    /// arrived; and only the filing rolls back (the savepoint), never the
    /// return.
    @Test func aRefusedFilingStillBringsTheJournalBack() throws {
        try withOperations { ops, db in
            let daily = try file(ops, day: "2026-10-01")
            try ops.lockReading(daily.bookID)
            try ops.archiveReading(daily.bookID)
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-10-02")

            #expect(ops.shelveInDailyJournalBook(entry.container.id) == .bookFinished)

            #expect(try archivedAt(db, "reading", daily.bookID) == nil)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM reading_post WHERE post_id = ?", [entry.container.id]) == 0)
            #expect(try liveDailyBooks(db) == [daily.bookID])
        }
    }

    /// …and the ownership BELL rings at a Journal she can see.
    @Test func anOwnershipBellRingsAtAJournalThatCameBack() throws {
        try withOperations { ops, db in
            let daily = try file(ops, day: "2026-10-01")
            let owned = try ops.createReading(name: "owned", kind: .book)
            try ops.setReadingOwned(owned.id, owned: true)
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-10-02")
            try ops.addPostToReading(entry.container.id, to: owned.id)
            try ops.archiveReading(daily.bookID)

            #expect(ops.shelveInDailyJournalBook(entry.container.id)
                    == .waitingAtDoor(readingID: daily.bookID))

            #expect(try archivedAt(db, "reading", daily.bookID) == nil)
            #expect(try db.fetchString(
                """
                SELECT status FROM reading_post
                WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL
                """, [daily.bookID, entry.container.id]) == "arrival")
        }
    }

    /// No day arrived: re-reaching an entry already decided brings nothing
    /// back (P-13ie-U1-12's other half).
    @Test func aDecidedPairBringsNothingBack() throws {
        try withOperations { ops, db in
            let daily = try file(ops, day: "2026-10-01")
            try ops.archiveReading(daily.bookID)
            let stamp = try archivedAt(db, "reading", daily.bookID)

            #expect(ops.shelveInDailyJournalBook(daily.entryID) == .alreadyDecided)

            #expect(try archivedAt(db, "reading", daily.bookID) == stamp)
        }
    }

    /// A DEAD daily book (an older build's delete) still mints fresh —
    /// today's behaviour, untouched.
    @Test func aDeadDailyJournalStillMintsFresh() throws {
        try withOperations { ops, db in
            let daily = try file(ops, day: "2026-10-01")
            try tombstoneAsAnOlderBuildWould(db, readingID: daily.bookID)
            #expect(try db.read { try Queries.dailyJournalBookID($0) } == nil)

            let today = try file(ops, day: "2026-10-02")

            #expect(today.bookID != daily.bookID)
            #expect(try liveDailyBooks(db) == [today.bookID])
        }
    }
}

// MARK: - The keeper repair meets an archived Journal (headless, the fake server)

/// The plan's edge: "the candidates filter is live-rows-only — an archived
/// daily Journal keeps its identity and converges exactly as a visible one
/// (zero `Sync/` change; pinned headless)." Test-side only.
@Suite("13i-e U1 — the keeper repair meets an archived daily Journal")
struct ArchivedJournalKeeperTests {
    private func mint(_ client: SyncClient, day: String) throws -> (bookID: String, entryID: String) {
        try client.with { ops, _ in try file(ops, day: day) }
    }

    private func liveDaily(_ client: SyncClient) throws -> [String] {
        try client.db.read {
            try String.fetchAll(
                $0, sql: """
                    SELECT id FROM reading
                    WHERE kind = 'book' AND profile = 'daily' AND deleted_at IS NULL ORDER BY id
                    """)
        }
    }

    private func members(_ client: SyncClient, _ bookID: String) throws -> Int {
        try client.db.fetchInt(
            """
            SELECT COUNT(*) FROM reading_post
            WHERE reading_id = ? AND deleted_at IS NULL AND status = 'member'
            """, [bookID]) ?? 0
    }

    /// The ARCHIVED Journal holds the smaller id (A's): it stays the keeper,
    /// stays ARCHIVED, and takes the fresh device's entry.
    @Test func anArchivedKeeperKeepsItsIdentityAndStaysArchived() async throws {
        let (a, b, server) = try furniturePair()
        let kept = try mint(a, day: "2026-10-01")
        try a.with { ops, _ in try ops.archiveReading(kept.bookID) }
        let fresh = try mint(b, day: "2026-10-02")

        try await a.push()
        try await b.push()
        try await b.pull()
        try await a.pull()
        try await assertFurnitureConverged(a, b, server)

        for client in [a, b] {
            #expect(try liveDaily(client) == [kept.bookID])
            #expect(try client.db.deletedAt("reading", fresh.bookID) != nil)
            #expect(try client.db.fetchString(
                "SELECT archived_at FROM reading WHERE id = ?", [kept.bookID]) != nil,
                "the archive survives the convergence")
            #expect(try members(client, kept.bookID) == 2, "both devices' entries in the ONE Journal")
            #expect(try await client.db.read { try Queries.dailyJournalBookID($0) } == kept.bookID)
        }
    }

    /// The ARCHIVED Journal holds the larger id (B's): it converges exactly as
    /// a visible loser would — retired, its entry re-pointed to the keeper.
    @Test func anArchivedLoserConvergesExactlyAsAVisibleOne() async throws {
        let (a, b, server) = try furniturePair()
        let keeper = try mint(a, day: "2026-10-01")
        let loser = try mint(b, day: "2026-10-02")
        try b.with { ops, _ in try ops.archiveReading(loser.bookID) }

        try await a.push()
        try await b.push()
        try await b.pull()
        try await a.pull()
        try await assertFurnitureConverged(a, b, server)

        for client in [a, b] {
            #expect(try liveDaily(client) == [keeper.bookID])
            #expect(try client.db.deletedAt("reading", loser.bookID) != nil)
            #expect(try members(client, keeper.bookID) == 2)
            #expect(try await client.db.read { try Queries.dailyJournalBookID($0) } == keeper.bookID)
        }
    }
}
