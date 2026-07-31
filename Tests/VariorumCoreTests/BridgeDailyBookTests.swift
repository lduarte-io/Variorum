import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 13c, batch 1D (ledger A1) — **a Fragments-landed day belongs in the
/// daily journal book.**
///
/// The author's report, verbatim: *"fragments journal did sync and appear,
/// but not in the journal book, just appeared in the pool."* Traced: the
/// Mac's ⌘J door (`JournalBooks.openToday`) creates-or-opens the day's entry
/// AND adds it to the designated daily book; the bridge's landing half
/// called only the first half, so every day it minted arrived in no book —
/// and "posts in no book" is exactly what the Pool surface lists (R29).
///
/// The three rules this suite pins, in order: the day gets shelved; the
/// landing is NEVER blocked by shelving (every refusal speaks instead of
/// throwing); and a pair the author already decided — shelved, or
/// deliberately REMOVED — is left exactly as she left it.
@Suite("Bridge — the daily journal book's membership (13c A1)")
struct BridgeDailyBookTests {
    /// The designated daily journal book, the shape `JournalBooks.openToday`
    /// creates on first use.
    private func designateDailyBook(
        _ bridge: BridgeHarness, name: String = "Journal"
    ) throws -> String {
        let book = try bridge.ops.createReading(
            name: name, kind: .curated, profile: "journal",
            sortField: .entryDate, sortDir: .asc)
        try bridge.ops.setDailyJournalBook(book.id)
        return book.id
    }

    private func memberships(
        _ bridge: BridgeHarness, book: String
    ) throws -> [(postID: String, deletedAt: String?)] {
        try bridge.db.read { db in
            try Row.fetchAll(
                db,
                sql: "SELECT post_id, deleted_at FROM reading_post WHERE reading_id = ? ORDER BY position, id",
                arguments: [book])
                .map { ($0["post_id"], $0["deleted_at"]) }
        }
    }

    // MARK: The fix

    /// THE PIN (red-on-old): a day the bridge mints from Fragments lands in
    /// the daily journal book, not the Pool.
    @Test func aFragmentsLandedDayJoinsTheDailyJournalBook() async throws {
        try await withBridge { bridge in
            let book = try designateDailyBook(bridge)
            _ = try await bridge.server.fragmentsAppWrites(
                userID: bridge.config.userID, day: "2026-07-09",
                body: "Written on the phone, in Fragments.",
                updatedAt: bridge.fragmentsStamp(0))

            let report = try await bridge.engine.pullAndLand()

            #expect(report.created == 1)
            #expect(try bridge.rendered(day: "2026-07-09")
                    == "Written on the phone, in Fragments.")
            let rows = try memberships(bridge, book: book)
            #expect(rows.count == 1, "the landed day must be shelved exactly once")
            #expect(rows.first?.deletedAt == nil)
            // Shelved silently — nothing to report when it worked.
            #expect(report.notes.isEmpty)
        }
    }

    /// The REPAIR half: a day whose entry already exists but was never
    /// shelved (a pre-fix bridge landing; a phone capture; any door that
    /// mints without shelving) joins the book on the next landing that
    /// writes to it. This is what clears the author's existing Pool orphans.
    @Test func aBooklessExistingEntryIsShelvedByTheNextLanding() async throws {
        try await withBridge { bridge in
            let book = try designateDailyBook(bridge)
            // Minted the way a pre-fix landing (or the phone) mints it:
            // create-or-open, no membership.
            let (entry, _) = try bridge.makeEntry(day: "2026-07-09", text: "Typed here.")
            _ = try await bridge.engine.run()  // agree on the current body
            #expect(try memberships(bridge, book: book).isEmpty,
                    "precondition: the entry starts bookless")

            _ = try await bridge.server.fragmentsAppWrites(
                userID: bridge.config.userID, day: "2026-07-09",
                body: "Edited in Fragments.", updatedAt: bridge.fragmentsStamp(0))
            let report = try await bridge.engine.pullAndLand()

            #expect(report.updated == 1)
            let rows = try memberships(bridge, book: book)
            #expect(rows.map(\.postID) == [entry.id])
            #expect(rows.first?.deletedAt == nil)
        }
    }

    /// A rescue landing (the graduated-entry regime — the day is push-only
    /// and the body arrives as a `'fragments'` take) shelves too: it wrote to
    /// the day, so the day is one the bridge is maintaining.
    @Test func aRescueLandingShelvesTheDayToo() async throws {
        try await withBridge { bridge in
            let book = try designateDailyBook(bridge)
            let (entry, _) = try bridge.makeEntry(day: "2026-07-09", text: "First block.")
            _ = try bridge.ops.newBlock(in: entry.id, text: "Second block.", at: .end)
            _ = try await bridge.engine.run()  // pushes only — pushing never shelves
            #expect(try memberships(bridge, book: book).isEmpty)

            _ = try await bridge.server.fragmentsAppWrites(
                userID: bridge.config.userID, day: "2026-07-09",
                body: "Written in Fragments against a graduated day.",
                updatedAt: bridge.fragmentsStamp(0))
            let report = try await bridge.engine.pullAndLand()

            #expect(report.rescuedVariants == 1)
            #expect(try memberships(bridge, book: book).map(\.postID) == [entry.id])
        }
    }

    // MARK: The landing is never blocked (every refusal speaks)

    /// **13d batch 5 — QUESTIONS #37 OVERTURNED to option (iii)** (author,
    /// 2026-07-28: *"the fragments entries should arrive as part of
    /// Journal"*). A RULED FLIP: this pin asserted the superseded
    /// PROVISIONAL (land, skip, say why, mint nothing). With no designation
    /// the landing now CREATES AND PINS the Journal book — ⌘J's first-press
    /// shape, made shared — and the round says nothing, because there is
    /// nothing to explain.
    @Test func withNoDesignatedBookTheLandingCreatesAndPinsTheJournalBook() async throws {
        try await withBridge { bridge in
            _ = try await bridge.server.fragmentsAppWrites(
                userID: bridge.config.userID, day: "2026-07-09",
                body: "Nowhere to shelve this — until now.",
                updatedAt: bridge.fragmentsStamp(0))

            let report = try await bridge.engine.pullAndLand()

            #expect(report.created == 1)
            #expect(try bridge.rendered(day: "2026-07-09") == "Nowhere to shelve this — until now.")
            #expect(report.notes.isEmpty)

            // Exactly ONE book, and it is the ⌘J door's own shape.
            let books = try await bridge.db.read { db in
                try Reading.fetchAll(db, sql: "SELECT * FROM reading WHERE deleted_at IS NULL")
            }
            #expect(books.count == 1)
            #expect(books.first?.name == Operations.defaultDailyJournalBookName)
            #expect(books.first?.kind == .curated)
            #expect(books.first?.profile == "journal")
            #expect(books.first?.sortField == .entryDate)
            // Designated, pinned, and holding the day.
            #expect(try await bridge.db.read { try Queries.dailyJournalBookID($0) } == books.first?.id)
            #expect(try await bridge.db.read { try Queries.shelfPins($0) }
                == [books.first?.id].compactMap { $0 })
            #expect(try memberships(bridge, book: books.first?.id ?? "").count == 1)
        }
    }

    /// …and a SECOND landing on another day joins that book rather than
    /// minting a second one (the create is an ensure, not a per-landing act).
    @Test func aSecondLandingJoinsTheBookTheFirstOneCreated() async throws {
        try await withBridge { bridge in
            for (i, day) in ["2026-07-09", "2026-07-10"].enumerated() {
                _ = try await bridge.server.fragmentsAppWrites(
                    userID: bridge.config.userID, day: day,
                    body: "Day \(i).", updatedAt: bridge.fragmentsStamp(i))
                _ = try await bridge.engine.pullAndLand()
            }
            let books = try await bridge.db.read { db in
                try Reading.fetchAll(db, sql: "SELECT * FROM reading WHERE deleted_at IS NULL")
            }
            #expect(books.count == 1)
            #expect(try memberships(bridge, book: books.first?.id ?? "").count == 2)
        }
    }

    /// A FINISHED daily book is the bounded-notebook flow's expected end
    /// (the `openToday` precedent): the entry still lands, and the note
    /// points at the two doors out.
    @Test func aFinishedDailyBookNeverBlocksTheLanding() async throws {
        try await withBridge { bridge in
            let book = try designateDailyBook(bridge)
            try bridge.ops.lockReading(book)
            _ = try await bridge.server.fragmentsAppWrites(
                userID: bridge.config.userID, day: "2026-07-09",
                body: "Landed against a finished book.",
                updatedAt: bridge.fragmentsStamp(0))

            let report = try await bridge.engine.pullAndLand()

            #expect(report.created == 1)
            #expect(try bridge.rendered(day: "2026-07-09") == "Landed against a finished book.")
            #expect(try memberships(bridge, book: book).isEmpty)
            #expect(report.notes.count == 1)
            #expect(report.notes.first?.contains("finished") == true)
        }
    }

    /// A FULL daily book (the `max_posts` extent constraint) — same posture.
    @Test func aFullDailyBookNeverBlocksTheLanding() async throws {
        try await withBridge { bridge in
            let book = try designateDailyBook(bridge)
            let filler = try bridge.ops.createPost(title: "filler", profile: .generic)
            _ = try bridge.ops.addPostToReading(filler.id, to: book)
            try bridge.ops.setReadingMaxPosts(book, maxPosts: 1)

            _ = try await bridge.server.fragmentsAppWrites(
                userID: bridge.config.userID, day: "2026-07-09",
                body: "Landed against a full book.", updatedAt: bridge.fragmentsStamp(0))
            let report = try await bridge.engine.pullAndLand()

            #expect(report.created == 1)
            #expect(try bridge.rendered(day: "2026-07-09") == "Landed against a full book.")
            #expect(try memberships(bridge, book: book).map(\.postID) == [filler.id])
            #expect(report.notes.count == 1)
            // 13f batch 7 (the K5 sweep): the note's wording swept post→note.
            #expect(report.notes.first?.contains("note cap") == true)
        }
    }

    /// A designation dangling at a DELETED book reads as none (the fallback
    /// class, `Queries.dailyJournalBookID`) — so #37(iii) treats it exactly
    /// like no designation at all: a fresh Journal book, created and pinned.
    /// (Another RULED FLIP: this pin asserted the "say why" note.)
    @Test func aDanglingDesignationGetsAFreshJournalBook() async throws {
        try await withBridge { bridge in
            let dead = try designateDailyBook(bridge)
            try bridge.ops.deleteReading(dead)

            _ = try await bridge.server.fragmentsAppWrites(
                userID: bridge.config.userID, day: "2026-07-09",
                body: "The book is gone.", updatedAt: bridge.fragmentsStamp(0))
            let report = try await bridge.engine.pullAndLand()

            #expect(report.created == 1)
            #expect(try bridge.rendered(day: "2026-07-09") == "The book is gone.")
            #expect(report.notes.isEmpty)
            let liveBooks = try await bridge.db.read { db in
                try Reading.fetchAll(db, sql: "SELECT * FROM reading WHERE deleted_at IS NULL")
            }
            #expect(liveBooks.count == 1)
            #expect(liveBooks.first?.id != dead)
            #expect(try memberships(bridge, book: liveBooks.first?.id ?? "").count == 1)
        }
    }

    /// **The cannot-widen edge of the creation, and it is the one that
    /// matters:** a book she DESIGNATED and then finished / filled / made
    /// smart is a deliberate state, and creation must never answer it by
    /// minting a second Journal beside hers. Those three paths keep their
    /// statuses and their notes (pinned above); this asserts the count.
    @Test func creationNeverReplacesABookSheDesignated() async throws {
        try await withBridge { bridge in
            let book = try designateDailyBook(bridge)
            try bridge.ops.lockReading(book)
            _ = try await bridge.server.fragmentsAppWrites(
                userID: bridge.config.userID, day: "2026-07-09",
                body: "Landed against a finished book.",
                updatedAt: bridge.fragmentsStamp(0))
            let report = try await bridge.engine.pullAndLand()

            #expect(report.notes.first?.contains("finished") == true)
            #expect(try bridge.db.fetchInt(
                "SELECT COUNT(*) FROM reading WHERE deleted_at IS NULL") == 1)
            #expect(try memberships(bridge, book: book).isEmpty)
        }
    }

    // MARK: Narrowness — what the shelving must never do
    //
    // The three pins that pass on the PRE-FIX engine too (which shelved
    // nothing at all) are NARROWNESS pins, not red-on-old pins —
    // `theBridgeNeverReShelvesAnEntryTheAuthorRemoved`,
    // `anEchoLandingShelvesNothing` and `shelvingNeverCausesAPush`. Their job
    // is to hold the carve's edges so a later widening goes red, the 1B
    // cannot-widen precedent. `anAlreadyShelvedDayMintsNothingFurther` sits
    // in both classes (it is red pre-fix on the count, and narrow on the
    // "exactly once" half).

    /// **Never re-shelve what she took off the shelf.** A TOMBSTONED
    /// membership is a decision (`removePostFromReading`), and a headless
    /// round must not undo it.
    @Test func theBridgeNeverReShelvesAnEntryTheAuthorRemoved() async throws {
        try await withBridge { bridge in
            let book = try designateDailyBook(bridge)
            let (entry, _) = try bridge.makeEntry(day: "2026-07-09", text: "Typed here.")
            _ = try bridge.ops.addPostToReading(entry.id, to: book)
            try bridge.ops.removePostFromReading(entry.id, from: book)
            _ = try await bridge.engine.run()  // agree on the current body

            _ = try await bridge.server.fragmentsAppWrites(
                userID: bridge.config.userID, day: "2026-07-09",
                body: "Edited in Fragments.", updatedAt: bridge.fragmentsStamp(0))
            let report = try await bridge.engine.pullAndLand()

            #expect(report.updated == 1)
            let rows = try memberships(bridge, book: book)
            #expect(rows.count == 1, "no second membership row is minted")
            #expect(rows.first?.deletedAt != nil, "her removal stands")
        }
    }

    /// An already-shelved day mints no second membership, and reports
    /// nothing — landing after landing.
    @Test func anAlreadyShelvedDayMintsNothingFurther() async throws {
        try await withBridge { bridge in
            let book = try designateDailyBook(bridge)
            for offset in 0..<3 {
                _ = try await bridge.server.fragmentsAppWrites(
                    userID: bridge.config.userID, day: "2026-07-09",
                    body: "Body \(offset).", updatedAt: bridge.fragmentsStamp(offset))
                let report = try await bridge.engine.pullAndLand()
                #expect(report.notes.isEmpty)
            }
            #expect(try memberships(bridge, book: book).count == 1)
        }
    }

    /// A landing that WROTE NOTHING (an echo of our own push) shelves
    /// nothing — the shelving rides real writes, never every pulled row.
    @Test func anEchoLandingShelvesNothing() async throws {
        try await withBridge { bridge in
            let book = try designateDailyBook(bridge)
            _ = try bridge.makeEntry(day: "2026-07-09", text: "My text.")
            _ = try await bridge.engine.push()  // pushing never shelves
            #expect(try memberships(bridge, book: book).isEmpty)

            let report = try await bridge.engine.pullAndLand()

            #expect(report.skipped == 1 && report.updated == 0 && report.created == 0)
            #expect(try memberships(bridge, book: book).isEmpty,
                    "an echo wrote nothing, so it shelves nothing")
        }
    }

    /// A NON-journal book designated as the daily journal (a smart book, say)
    /// cannot take posts — the landing still lands, and the note carries the
    /// operation's own refusal rather than a guess.
    @Test func aSmartDailyBookLandsAndSaysWhy() async throws {
        try await withBridge { bridge in
            let smart = try bridge.ops.createReading(name: "Smart", kind: .smart)
            try bridge.ops.setDailyJournalBook(smart.id)

            _ = try await bridge.server.fragmentsAppWrites(
                userID: bridge.config.userID, day: "2026-07-09",
                body: "Against a smart book.", updatedAt: bridge.fragmentsStamp(0))
            let report = try await bridge.engine.pullAndLand()

            #expect(report.created == 1)
            #expect(try bridge.rendered(day: "2026-07-09") == "Against a smart book.")
            #expect(report.notes.count == 1)
            let note = try #require(report.notes.first)
            #expect(note.contains("2026-07-09"))
            // 13c Stage 1 ladder, R1-3: this note goes in front of the
            // author in the bridge status row. It used to be
            // `String(describing:)` of the raw error, so it read
            // `…: wrongReadingKind(id: "8F3C-…", expected:
            // VariorumCore.ReadingKind.curated)`. A smart designation is a
            // refusal she can cause AND fix, so it is modelled like its
            // siblings and worded.
            #expect(!note.contains("(id:"), "no row ids in front of her: \(note)")
            #expect(!note.contains("wrongReadingKind"), "no enum case names either: \(note)")
            #expect(!note.contains("VariorumCore."))
            #expect(note.lowercased().contains("smart"),
                    "…and it names the actual problem: \(note)")
        }
    }

    /// The 9b guarantees the shelving must not disturb: unchanged text still
    /// never pushes, and a shelved landing's agreed hash still stops the
    /// echo. (Membership is not rendered text — but the day now takes a
    /// second write per landing, so this pins that the push half is
    /// untouched by it.)
    @Test func shelvingNeverCausesAPush() async throws {
        try await withBridge { bridge in
            _ = try designateDailyBook(bridge)
            _ = try await bridge.server.fragmentsAppWrites(
                userID: bridge.config.userID, day: "2026-07-09",
                body: "One body.", updatedAt: bridge.fragmentsStamp(0))
            let writesBefore = await bridge.server.acceptedWriteCount

            let round = try await bridge.engine.run()

            #expect(round.landing.created == 1)
            #expect(round.push.pushed == 0, "a landed body is never echoed back")
            #expect(await bridge.server.acceptedWriteCount == writesBefore)
            // And a second, quiescent round writes nothing anywhere.
            let quiet = try await bridge.engine.run()
            #expect(quiet.push.pushed == 0 && quiet.landing.created == 0)
            #expect(await bridge.server.acceptedWriteCount == writesBefore)
        }
    }
}
