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
