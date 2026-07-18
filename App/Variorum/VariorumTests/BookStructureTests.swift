//
//  BookStructureTests.swift
//  VariorumTests
//
//  Phase 13, B3 — the book structure's behavioral seams: chapter grouping
//  (pure), the finished-opens-into-Read rule (R2), and the journal-book
//  doors (R50 — the daily book's ensure-membership; the one-entry-per-day
//  rule UNTOUCHED and scoped to the daily door; other journal books mint
//  freely).
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withShellSession2<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 9))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@MainActor
@Suite("Book chapters & modes (Phase 13, B3)")
struct BookStructureModelTests {
    private func entry(_ id: String) -> Queries.ReadingEntry {
        Queries.ReadingEntry(postID: id, title: id, entryDate: nil, sectionPath: nil)
    }

    private func section(_ id: String, _ name: String, position: String) -> ReadingSection {
        ReadingSection(
            id: id, readingId: "r", name: name, position: position,
            createdAt: Date(), updatedAt: Date())
    }

    @Test func groupingFollowsChapterOrderWithUnfiledLast() {
        let sections = [
            section("s1", "I", position: "a"),
            section("s2", "II", position: "b"),
        ]
        let entries = [entry("p1"), entry("p2"), entry("p3"), entry("p4")]
        let grouped = BookStructureModel.grouped(
            entries: entries,
            sections: sections,
            assignments: ["p1": "s2", "p3": "s1", "p4": "s1"])
        #expect(grouped.count == 3)
        #expect(grouped[0].section?.id == "s1")
        #expect(grouped[0].entries.map(\.postID) == ["p3", "p4"],
                "within a chapter, the reading's own entry order holds")
        #expect(grouped[1].section?.id == "s2")
        #expect(grouped[1].entries.map(\.postID) == ["p1"])
        #expect(grouped[2].section == nil)
        #expect(grouped[2].entries.map(\.postID) == ["p2"], "unfiled trails")
    }

    @Test func emptyChaptersStillRenderAndNoUnfiledGroupWhenAllFiled() {
        let sections = [section("s1", "I", position: "a")]
        let grouped = BookStructureModel.grouped(
            entries: [entry("p1")], sections: sections, assignments: ["p1": "s1"])
        #expect(grouped.count == 1)
        let withEmpty = BookStructureModel.grouped(
            entries: [], sections: sections, assignments: [:])
        #expect(withEmpty.count == 1)
        #expect(withEmpty[0].entries.isEmpty, "an empty chapter is a visible place to file into")
    }

    @Test func aFinishedBookOpensIntoTheReadingFlow() {
        // R2's letter: a finished book opens here by default and shows
        // nothing but the text.
        let open = Reading(
            id: "r", name: "orbit", kind: .curated, createdAt: Date(), updatedAt: Date())
        var finished = open
        finished.locked = true
        #expect(BookStructureModel.defaultMode(for: open) == .book)
        #expect(BookStructureModel.defaultMode(for: finished) == .read)
    }
}

@MainActor
@Suite("Journal books (Phase 13, B3 — R50)")
struct JournalBooksTests {
    @Test func openTodayEnsuresTheDailyBookPinnedDesignatedAndMembered() async throws {
        try await withShellSession2 { session, db in
            let entryID = try await JournalBooks.openToday(session: session, day: "2026-07-18").postID

            let bookID = try await db.read { db in try Queries.dailyJournalBookID(db) }
            let designated = try #require(bookID, "first use designates a daily book")
            let pins = try await db.read { db in try Queries.shelfPins(db) }
            #expect(pins == [designated], "the journal is PINNED into the shelf (R38)")
            let books = try await db.read { db in
                try Queries.readingsContaining(db, postID: entryID)
            }
            #expect(books.map(\.id) == [designated],
                    "the entry knows its book the way any post does — ordinary membership (R50)")
            #expect(books.first?.profile == "journal")

            // The SAME day re-opens the SAME entry (the untouchable
            // one-entry-per-day rule) and mints nothing new.
            let again = try await JournalBooks.openToday(session: session, day: "2026-07-18")
            #expect(again.postID == entryID)
            #expect(again.note == nil)
            let count = try await db.read { db in
                try Int.fetchOne(db, sql: """
                    SELECT COUNT(*) FROM reading_post WHERE deleted_at IS NULL
                    """)
            }
            #expect(count == 1)
        }
    }

    @Test func otherJournalBooksMintFreelyTheDailyRuleStaysScoped() async throws {
        try await withShellSession2 { session, db in
            // A dream journal — journal-profile BOOK, NOT the designated
            // daily; its entries mint as .generic (the round-2 BLOCKER's
            // fix — the daily shape is profile+date, and these must not
            // wear it).
            let dreamID = try await session.runner.run { ops in
                try ops.createReading(name: "Dream Journal", kind: .curated, profile: "journal").id
            }
            let structure = BookStructureModel(session: session, readingID: dreamID)
            let first = await structure.newEntry(day: "2026-07-18")
            let second = await structure.newEntry(day: "2026-07-18")
            #expect(first != nil && second != nil && first != second,
                    "two dream entries on one day are LEGAL — the one-per-day rule is the DAILY door's")
            let members = try await db.read { db in
                try Int.fetchOne(db, sql: """
                    SELECT COUNT(*) FROM reading_post
                    WHERE reading_id = ? AND deleted_at IS NULL
                    """, arguments: [dreamID])
            }
            #expect(members == 2)
            let shape = try await db.read { [first] db in
                try Row.fetchOne(db, sql: """
                    SELECT profile, segmentation_default FROM container WHERE id = ?
                    """, arguments: [first])
            }
            #expect((shape?["profile"] as String?) == "generic",
                    "a non-daily entry NEVER wears profile='journal' (the BLOCKER's shape)")
            #expect((shape?["segmentation_default"] as String?) == "one_block",
                    "the notebook feel rides explicit segmentation, not the profile")

            // The DAILY book's own new-entry door routes through
            // create-or-open — the rule holds there.
            _ = try await JournalBooks.openToday(session: session, day: "2026-07-19")
            let dailyID = try await db.read { db in try Queries.dailyJournalBookID(db) }
            let daily = BookStructureModel(session: session, readingID: try #require(dailyID))
            let one = await daily.newEntry(day: "2026-07-19")
            let two = await daily.newEntry(day: "2026-07-19")
            #expect(one == two, "the daily book's door is create-or-open — one entry per day")
        }
    }

    @Test func aDreamEntryNeverCollidesWithTheDailyJournal() async throws {
        // Round 2, BLOCKER (red-on-old, verified by behavioral revert):
        // with a dream entry created FIRST on day D, the daily door must
        // still mint ITS OWN entry (the old .journal-profile dream WAS
        // canonicalJournalEntry's answer), and the Fragments bridge's
        // day-enumeration shape (profile='journal' + entry_date) must see
        // exactly ONE row on D — no duplicate-day pause, no dream text
        // pushed as the day's journal.
        try await withShellSession2 { session, db in
            let dreamBookID = try await session.runner.run { ops in
                try ops.createReading(name: "Dream Journal", kind: .curated, profile: "journal").id
            }
            let structure = BookStructureModel(session: session, readingID: dreamBookID)
            let dreamID = try #require(await structure.newEntry(day: "2026-07-20"))

            let outcome = try await JournalBooks.openToday(session: session, day: "2026-07-20")
            #expect(outcome.postID != dreamID,
                    "the daily door mints its own entry — the dream is not the day's journal")

            // The bridge sweep's exact shape: ONE journal-profile row on D.
            let journalShaped = try await db.read { db in
                try Int.fetchOne(db, sql: """
                    SELECT COUNT(*) FROM container
                    WHERE kind = 'post' AND profile = 'journal'
                      AND entry_date = '2026-07-20' AND deleted_at IS NULL
                    """)
            }
            #expect(journalShaped == 1,
                    "exactly one daily-shaped entry on the day — the bridge never pauses D")
        }
    }

    @Test func aFinishedDailyBookNeverWedgesTodaysEntry() async throws {
        // Round 2, MAJOR 2 (red-on-old: the pre-fix door THREW
        // lockedReading): finishing the daily journal is the bounded-
        // notebook flow's expected end — the entry still opens, the note
        // SPEAKS, membership is skipped.
        try await withShellSession2 { session, db in
            _ = try await JournalBooks.openToday(session: session, day: "2026-07-21")
            let dailyID = try #require(try await db.read { db in
                try Queries.dailyJournalBookID(db)
            })
            try await session.runner.run { ops in try ops.lockReading(dailyID) }

            let outcome = try await JournalBooks.openToday(session: session, day: "2026-07-22")
            #expect(outcome.note?.contains("finished") == true,
                    "the door SPEAKS — never a throw, never silence")
            let membered = try await db.read { [id = outcome.postID] db in
                try Queries.readingsContaining(db, postID: id)
            }
            #expect(membered.isEmpty, "membership skipped; the entry still opened")

            // Re-designation heals the flow: a new journal book takes over.
            let nextID = try await session.runner.run { ops in
                let next = try ops.createReading(
                    name: "Journal II", kind: .curated, profile: "journal")
                try ops.setDailyJournalBook(next.id)
                return next.id
            }
            let healed = try await JournalBooks.openToday(session: session, day: "2026-07-23")
            #expect(healed.note == nil)
            let books = try await db.read { [id = healed.postID] db in
                try Queries.readingsContaining(db, postID: id)
            }
            #expect(books.map(\.id) == [nextID])
        }
    }

    @Test func chapterDragDropsBeforeTargetOrAtTheEnd() async throws {
        // Stage C (R19's polished bar): the navigator drag lands as ONE
        // reorderSection; no-op drops and foreign payloads touch nothing.
        try await withShellSession2 { session, db in
            let readingID = try await session.runner.run { ops in
                let reading = try ops.createReading(name: "orbit", kind: .curated)
                _ = try ops.createSection(in: reading.id, name: "I")
                _ = try ops.createSection(in: reading.id, name: "II")
                _ = try ops.createSection(in: reading.id, name: "III")
                return reading.id
            }
            let structure = BookStructureModel(session: session, readingID: readingID)
            @MainActor func refresh() async throws {
                let snapshot = try await db.read { [readingID] db in
                    BookStructureModel.Snapshot(
                        reading: try Queries.reading(db, id: readingID),
                        sections: try Queries.readingSections(db, readingID: readingID),
                        deletedSections: try Queries.deletedReadingSections(db, readingID: readingID),
                        assignments: try Queries.sectionAssignments(db, readingID: readingID))
                }
                structure.adopt(snapshot)
            }
            try await refresh()
            let ids = structure.sections.map(\.id)
            #expect(structure.sections.map(\.name) == ["I", "II", "III"])

            // Drop III before I.
            await structure.moveChapter(ids[2], before: ids[0])
            try await refresh()
            #expect(structure.sections.map(\.name) == ["III", "I", "II"])

            // Drop III at the END.
            await structure.moveChapter(ids[2], before: nil)
            try await refresh()
            #expect(structure.sections.map(\.name) == ["I", "II", "III"])

            // No-op drops: own position, own next boundary, foreign string.
            await structure.moveChapter(ids[0], before: ids[0])
            await structure.moveChapter(ids[0], before: ids[1])
            await structure.moveChapter("not-a-section", before: ids[0])
            try await refresh()
            #expect(structure.sections.map(\.name) == ["I", "II", "III"])
            #expect(structure.lastError == nil)
        }
    }
}
