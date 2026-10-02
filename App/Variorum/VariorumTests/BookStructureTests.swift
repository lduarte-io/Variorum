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

    // MARK: - 13f W11: the drop resolvers (pure)
    //
    // THE PIN-HONESTY NOTE, and it governs everything below: batch 1 measured
    // that the SwiftUI drag route cannot be driven in this test host (the
    // hosting drop path sends the private `_lastDragDestinationOperation`, and
    // the process terminates on the unrecognized selector). So the DECISIONS a
    // drop makes live here, as pure functions over the same grouped
    // presentation the view renders, and they are pinned exhaustively. What is
    // NOT pinned — and is named as visual-verification-only in the batch
    // record — is the geometry: whether a target's hit area really covers its
    // row, and whether the pointer really reaches the end zone.

    private func twoChapterBook() -> (
        groups: [(section: ReadingSection?, entries: [Queries.ReadingEntry])],
        one: String, two: String
    ) {
        let sections = [
            section("s1", "I", position: "a"),
            section("s2", "II", position: "b"),
        ]
        let groups = BookStructureModel.grouped(
            entries: [entry("p1"), entry("p2"), entry("p3"), entry("p4")],
            sections: sections,
            assignments: ["p1": "s1", "p2": "s1", "p3": "s2", "p4": "s2"])
        return (groups, "s1", "s2")
    }

    @Test func theDragPayloadDiscriminatesChaptersFromPostsAndRefusesForeigners() {
        typealias Drag = BookStructureModel.BookDrag
        #expect(Drag.decode(Drag.chapter("s1").payload) == .chapter("s1"))
        #expect(Drag.decode(Drag.post("p1").payload) == .post("p1"))
        #expect(Drag.chapter("x").payload != Drag.post("x").payload,
                "the same id means two different things — the prefix is why")
        // Every other drag in the app is a bare id or a differently-prefixed
        // one; none of them may act on a book's structure.
        for foreign in ["s1", "p1", "lens-move:b1", "", "book-chapterish:s1"] {
            #expect(Drag.decode(foreign) == nil, "\(foreign)")
        }
    }

    /// HER SCENARIO, as a resolution table: *"i haven't been able to move the
    /// chapters in between the posts."* With two chapters, "before" was the
    /// only meaning a drop could carry, so moving one DOWN had no target
    /// except a 14 pt strip at the very end of the book. A post row is a
    /// target now, and it snaps to the nearest chapter boundary.
    @Test func aChapterDroppedBetweenPostsSnapsToTheNearestBoundary() {
        let book = twoChapterBook()
        func target(_ site: BookStructureModel.ChapterDropSite) -> String? {
            BookStructureModel.chapterDropTarget(site, groups: book.groups)
        }
        // The shipped meanings, unchanged.
        #expect(target(.chapter(book.two)) == book.two)
        #expect(target(.gapBefore(book.two)) == book.two, "the gap means the same thing")
        #expect(target(.end) == nil)
        // Top half of a chapter → that chapter's own boundary.
        #expect(target(.post("p1")) == book.one)
        #expect(target(.post("p3")) == book.two)
        // Bottom half → the boundary BELOW: the next chapter's…
        #expect(target(.post("p2")) == book.two)
        // …and, in the LAST chapter, the end — which is exactly how a
        // two-chapter book moves its first chapter down.
        #expect(target(.post("p4")) == nil)
        // A post nobody knows, and an unfiled post (unfiled trails every
        // chapter, so its boundary IS the end).
        #expect(target(.post("nowhere")) == nil)
        let withUnfiled = BookStructureModel.grouped(
            entries: [entry("p1"), entry("p9")],
            sections: [section("s1", "I", position: "a")],
            assignments: ["p1": "s1"])
        #expect(BookStructureModel.chapterDropTarget(
            .post("p9"), groups: withUnfiled) == nil)
    }

    /// A one-post chapter has no "halves" — the row is both, and the rule
    /// must still answer something reachable (its own boundary).
    @Test func aSingleRowChapterResolvesToItsOwnBoundary() {
        let groups = BookStructureModel.grouped(
            entries: [entry("p1"), entry("p2")],
            sections: [
                section("s1", "I", position: "a"),
                section("s2", "II", position: "b"),
            ],
            assignments: ["p1": "s1", "p2": "s2"])
        #expect(BookStructureModel.chapterDropTarget(.post("p1"), groups: groups) == "s1")
        #expect(BookStructureModel.chapterDropTarget(.post("p2"), groups: groups) == "s2")
    }

    /// W11b's decision half: what a POST drop writes.
    @Test func aPostDropPlansItsChapterAndItsAnchor() {
        let book = twoChapterBook()
        func plan(
            _ site: BookStructureModel.PostDropSite, _ dragged: String,
            reposition: Bool = true
        ) -> BookStructureModel.PostDropPlan? {
            BookStructureModel.postDropPlan(
                site, dragged: dragged, groups: book.groups, reposition: reposition)
        }
        // Onto a chapter header: join it, at its top.
        #expect(plan(.chapter(book.two), "p1")
                == BookStructureModel.PostDropPlan(sectionID: "s2", before: "p3"))
        // Onto another post: join ITS chapter, above it.
        #expect(plan(.post("p4"), "p1")
                == BookStructureModel.PostDropPlan(sectionID: "s2", before: "p4"))
        // Onto itself: nothing at all.
        #expect(plan(.post("p1"), "p1") == nil)
        // Onto the chapter it already heads: no self-anchor (the reorder
        // would be a no-op against its own row).
        #expect(plan(.chapter(book.two), "p3")
                == BookStructureModel.PostDropPlan(sectionID: "s2", before: nil))
        // Out of every chapter.
        #expect(plan(.unfiled, "p1")
                == BookStructureModel.PostDropPlan(sectionID: nil, before: nil))
        // Under a stamp sort the stored order is NOT what she is looking at,
        // so the drop files the post and leaves the order alone.
        #expect(plan(.post("p4"), "p1", reposition: false)
                == BookStructureModel.PostDropPlan(sectionID: "s2", before: nil))
    }

    @Test func aFinishedBookOpensIntoTheReadingFlow() {
        // R2's letter: a finished book opens here by default and shows
        // nothing but the text.
        let open = Reading(
            id: "r", name: "orbit", kind: .book, createdAt: Date(), updatedAt: Date())
        var finished = open
        finished.locked = true
        // 13c 2A: a WORKING book opens into OUTLINE — the surface it is
        // written on (A39); the case rename is `.book` → `.outline`.
        #expect(BookStructureModel.defaultMode(for: open) == .outline)
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
            // 13i-a: the daily mint stamps the MARKER (the memo §3).
            #expect(books.first?.profile == "daily")

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

    /// **⌘J obeys the same "already decided" rule the phone does** (and the
    /// retired bridge did, until 2026-09-04) (13c Stage 1 ladder, R1-4). The shared helper treats ANY
    /// membership row — live OR tombstoned — as the pair being decided, which
    /// is what stops a headless round from re-shelving something she took off
    /// the shelf. `openToday` used to call `addPostToReading` itself and
    /// catch `alreadyInReading`, which fires on LIVE rows only: a tombstoned
    /// membership was invisible to it, so it inserted a fresh one and the
    /// entry silently reappeared in the book. Three doors, one rule.
    @Test func openTodayNeverReShelvesAnEntryTheAuthorRemoved() async throws {
        try await withShellSession2 { session, db in
            let first = try await JournalBooks.openToday(session: session, day: "2026-07-26")
            let bookID = try #require(try await db.read { db in
                try Queries.dailyJournalBookID(db)
            })
            // She takes the day off the shelf.
            try await session.runner.run { [id = first.postID] ops in
                try ops.removePostFromReading(id, from: bookID)
            }
            let afterRemoval = try await db.read { [id = first.postID] db in
                try Queries.readingsContaining(db, postID: id)
            }
            #expect(afterRemoval.isEmpty)

            // …and opens the same day again.
            let again = try await JournalBooks.openToday(session: session, day: "2026-07-26")
            #expect(again.postID == first.postID, "the same entry, the untouchable rule")
            #expect(again.note == nil, "nothing to say — the pair is decided")
            let books = try await db.read { [id = again.postID] db in
                try Queries.readingsContaining(db, postID: id)
            }
            #expect(books.isEmpty, "her removal STANDS — ⌘J does not put it back")
            let rows = try await db.read { db in
                try Int.fetchOne(db, sql: """
                    SELECT COUNT(*) FROM reading_post WHERE reading_id = ?
                    """, arguments: [bookID])
            }
            #expect(rows == 1, "…and no second membership row was minted beside the tombstone")
        }
    }

    @Test func otherJournalBooksMintFreelyTheDailyRuleStaysScoped() async throws {
        try await withShellSession2 { session, db in
            // A dream journal — journal-profile BOOK, NOT the designated
            // daily; its entries mint as .generic (the round-2 BLOCKER's
            // fix — the daily shape is profile+date, and these must not
            // wear it).
            let dreamID = try await session.runner.run { ops in
                try ops.createReading(name: "Dream Journal", kind: .book, profile: "journal").id
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

    /// 13i-c ladder round 1 (the sealed-named-reopen class): the daily door
    /// on a SEALED daily Journal says UNSEAL, never Reopen — `unlockReading`
    /// refuses a sealed book (`readingSealed`, R-13ic-3), so "reopen it"
    /// named a door that cannot act. Both daily roads pinned: ⌘J's
    /// `openToday` note and the book's own "+ new entry". Red-on-old: both
    /// said "is finished — … reopen".
    @Test func theDailyDoorOnASealedJournalNamesUnsealNeverReopen() async throws {
        try await withShellSession2 { session, db in
            _ = try await JournalBooks.openToday(session: session, day: "2026-07-22")
            let dailyID = try #require(try await db.read { try Queries.dailyJournalBookID($0) })
            try await session.runner.run { ops in try ops.sealReading(dailyID) }

            let outcome = try await JournalBooks.openToday(session: session, day: "2026-07-23")
            let note = try #require(outcome.note)
            #expect(note.localizedCaseInsensitiveContains("sealed")
                    && note.localizedCaseInsensitiveContains("unseal"),
                    "⌘J's note names the sealed book's real road out")
            #expect(!note.contains("is finished"),
                    "never 'finished — reopen' on a sealed book (Reopen refuses there)")

            let daily = BookStructureModel(session: session, readingID: dailyID)
            _ = await daily.newEntry(day: "2026-07-24")
            let entryNote = try #require(daily.lastError)
            #expect(entryNote.localizedCaseInsensitiveContains("sealed")
                    && entryNote.localizedCaseInsensitiveContains("unseal"),
                    "'+ new entry' speaks the same road")
            #expect(!entryNote.contains("is finished"))
        }
    }

    /// 13i-c ladder round 1 (the F-5 wing class, the NON-DAILY arm): a
    /// journal-trait book's "+ new entry" mints the note in the BOOK's wing
    /// (§9 — a book never spans wings), through `newPostInReading` — the op
    /// that already gates, mints and members in ONE transaction and applies
    /// the outflow. Red-on-old: the composite minted via `createPost` (wing
    /// ''), so a non-Home book's entry was born in the wrong wing. The DAILY
    /// arm is deliberately NOT covered here: `canonicalJournalEntry` is
    /// wing-blind, and the daily Journal's wing story is 13i-d's (the ladder
    /// record's QUESTIONS paragraph).
    @Test func aNonDailyEntryIsBornInItsBooksWing() async throws {
        try await withShellSession2 { session, db in
            // 13i-d U5: a book is born only in a LIVE wing — the fixture
            // mints one (the assertion reads its id where it read "W1").
            let (bookID, far) = try await session.runner.run { ops in
                let far = try ops.createWing(name: "W1").id
                return (try ops.createReading(
                    name: "Far Dream Journal", kind: .book, profile: "journal",
                    wingId: far
                ).id, far)
            }
            let structure = BookStructureModel(session: session, readingID: bookID)
            let entryID = try #require(await structure.newEntry(day: "2026-07-21"))
            let shape = try await db.read { db in
                try Row.fetchOne(db, sql: """
                    SELECT wing_id, profile, segmentation_default FROM container WHERE id = ?
                    """, arguments: [entryID])
            }
            #expect((shape?["wing_id"] as String?) == far,
                    "the entry is born in its book's wing (the F-5 class)")
            #expect((shape?["profile"] as String?) == "generic",
                    "the non-daily shape holds — never profile='journal'")
            #expect((shape?["segmentation_default"] as String?) == "one_block",
                    "the notebook feel still rides explicit segmentation")
            let membered = try await db.read { db in
                try Int.fetchOne(db, sql: """
                    SELECT COUNT(*) FROM reading_post
                    WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL
                      AND status = 'member'
                    """, arguments: [bookID, entryID])
            }
            #expect(membered == 1, "…and it is the book's member, as before")
        }
    }

    @Test func aDreamEntryNeverCollidesWithTheDailyJournal() async throws {
        // Round 2, BLOCKER (red-on-old, verified by behavioral revert):
        // with a dream entry created FIRST on day D, the daily door must
        // still mint ITS OWN entry (the old .journal-profile dream WAS
        // canonicalJournalEntry's answer), and the daily-journal day shape
        // (profile='journal' + entry_date — once the Fragments bridge's
        // enumeration too) must see exactly ONE row on D — no duplicate-day
        // ambiguity, no dream text as the day's journal.
        try await withShellSession2 { session, db in
            let dreamBookID = try await session.runner.run { ops in
                try ops.createReading(name: "Dream Journal", kind: .book, profile: "journal").id
            }
            let structure = BookStructureModel(session: session, readingID: dreamBookID)
            let dreamID = try #require(await structure.newEntry(day: "2026-07-20"))

            let outcome = try await JournalBooks.openToday(session: session, day: "2026-07-20")
            #expect(outcome.postID != dreamID,
                    "the daily door mints its own entry — the dream is not the day's journal")

            // The daily-journal day shape: ONE journal-profile row on D.
            let journalShaped = try await db.read { db in
                try Int.fetchOne(db, sql: """
                    SELECT COUNT(*) FROM container
                    WHERE kind = 'post' AND profile = 'journal'
                      AND entry_date = '2026-07-20' AND deleted_at IS NULL
                    """)
            }
            #expect(journalShaped == 1,
                    "exactly one daily-shaped entry on the day — D is never ambiguous")
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
                    name: "Journal II", kind: .book, profile: "journal")
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

    @Test func aLockedBooksEntryDoorFollowsTheOutcomeDoctrine() async throws {
        // Round 3, MINOR (red-on-old by behavioral revert — the pre-fix
        // door caught only alreadyInReading): on a LOCKED book, the DAILY
        // branch still opens the entry with a SPEAKING note (never nil +
        // raw error), and the NON-DAILY branch refuses BEFORE MINTING —
        // no stray `.generic` post lands in the Pool per click.
        try await withShellSession2 { session, db in
            // DAILY half: designate, lock, knock.
            _ = try await JournalBooks.openToday(session: session, day: "2026-07-24")
            let dailyID = try #require(try await db.read { db in
                try Queries.dailyJournalBookID(db)
            })
            try await session.runner.run { ops in try ops.lockReading(dailyID) }
            let daily = BookStructureModel(session: session, readingID: dailyID)
            let openedID = await daily.newEntry(day: "2026-07-25")
            #expect(openedID != nil,
                    "the entry ALWAYS opens — the locked add never voids the door")
            #expect(daily.lastError?.contains("finished") == true,
                    "the note SPEAKS instead of a raw thrown description")

            // NON-DAILY half: a locked dream journal refuses BEFORE the mint.
            let dreamID = try await session.runner.run { ops -> String in
                let book = try ops.createReading(
                    name: "Dream Journal", kind: .book, profile: "journal")
                try ops.lockReading(book.id)
                return book.id
            }
            let before = try await db.read { db in
                try Int.fetchOne(db, sql: """
                    SELECT COUNT(*) FROM container WHERE kind = 'post' AND deleted_at IS NULL
                    """) ?? 0
            }
            let dream = BookStructureModel(session: session, readingID: dreamID)
            let refused = await dream.newEntry(day: "2026-07-25")
            #expect(refused == nil, "a locked non-daily book's door refuses")
            // 13i-d U6 (KnownIssues row 106 — a JUSTIFIED EDIT): the message
            // table's generic arm now names the true roads, not "locked —
            // unlock"; the subject (the refusal speaks through the table) holds.
            #expect(dream.lastError?.contains("finished") == true
                        && dream.lastError?.contains("reopen") == true,
                    "the refusal speaks through the message table")
            let after = try await db.read { db in
                try Int.fetchOne(db, sql: """
                    SELECT COUNT(*) FROM container WHERE kind = 'post' AND deleted_at IS NULL
                    """) ?? 0
            }
            #expect(after == before,
                    "REFUSE BEFORE MINT — no stray post per click on a locked book")

            // The capacity gate refuses pre-mint the same way.
            let cappedID = try await session.runner.run { ops -> String in
                let book = try ops.createReading(
                    name: "Tiny", kind: .book, profile: "journal", maxPosts: 1)
                let filler = try ops.createPost(title: "filler", profile: .generic)
                _ = try ops.addPostToReading(filler.id, to: book.id)
                return book.id
            }
            let capped = BookStructureModel(session: session, readingID: cappedID)
            let overCap = await capped.newEntry(day: "2026-07-25")
            #expect(overCap == nil)
            #expect(capped.lastError?.contains("limit") == true)
        }
    }

    /// Sitting 9 batch 6 (her screenshot: a fresh curated book's navigator
    /// missing ALL its doors): the LIVE start() path must deliver the
    /// reading — the doors' `reading?.kind == .book` condition hangs
    /// off it. Drives the real observation, not adopt().
    @Test func startDeliversTheReadingSoTheNavigatorDoorsCanRender() async throws {
        try await withShellSession2 { session, _ in
            let readingID = try await session.runner.run { ops in
                try ops.createReading(name: "my book :)", kind: .book).id
            }
            let structure = BookStructureModel(session: session, readingID: readingID)
            let task = Task { await structure.start() }
            defer { task.cancel() }
            var spins = 0
            while structure.reading == nil, spins < 200 {
                try await Task.sleep(for: .milliseconds(10))
                spins += 1
            }
            #expect(structure.reading?.kind == .book,
                    "the live observation delivers — the + doors' condition is satisfiable")
            #expect(structure.lastError == nil)
        }
    }

    @Test func chapterDragDropsBeforeTargetOrAtTheEnd() async throws {
        // Stage C (R19's polished bar): the navigator drag lands as ONE
        // reorderSection; no-op drops and foreign payloads touch nothing.
        try await withShellSession2 { session, db in
            let readingID = try await session.runner.run { ops in
                let reading = try ops.createReading(name: "orbit", kind: .book)
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

// MARK: - 13f W11: the drops, end to end through the store

/// Her W11 ruling, verbatim: *"i think we should fix the reach, but it should
/// also be possible to pick up a post and move it to another chapter."* The
/// resolvers above decide; these pins prove the decisions reach the ratified
/// operations and nothing else — `reorderSection`, `assignPostToSection`,
/// `reorderReadingPost`, each already pinned in core.
@MainActor
@Suite("Book drag & drop, end to end (13f W11)")
struct BookDropTests {
    /// A curated book: chapters I and II, posts p1..p4 filed two apiece.
    @MainActor
    private struct Book {
        let session: AppSession
        let database: AppDatabase
        let structure: BookStructureModel
        let readingID: String
        var sections: [String]
        var posts: [String]

        func refresh() async throws -> [Queries.ReadingEntry] {
            let (snapshot, entries) = try await database.read { [readingID] db in
                (BookStructureModel.Snapshot(
                    reading: try Queries.reading(db, id: readingID),
                    sections: try Queries.readingSections(db, readingID: readingID),
                    deletedSections: try Queries.deletedReadingSections(db, readingID: readingID),
                    assignments: try Queries.sectionAssignments(db, readingID: readingID)),
                 try Queries.assembleReading(db, readingID: readingID))
            }
            structure.adopt(snapshot)
            return entries
        }
    }

    private func withBook<T>(
        _ body: @MainActor (Book) async throws -> T
    ) async throws -> T {
        try await withShellSession2 { session, db in
            let (readingID, sections, posts) = try await session.runner.run { ops in
                let reading = try ops.createReading(name: "orbit", kind: .book)
                let one = try ops.createSection(in: reading.id, name: "I")
                let two = try ops.createSection(in: reading.id, name: "II")
                var posts: [String] = []
                for i in 1...4 {
                    let post = try ops.createPost(title: "p\(i)")
                    _ = try ops.addPostToReading(post.id, to: reading.id)
                    try ops.assignPostToSection(
                        post.id, in: reading.id, section: i <= 2 ? one.id : two.id)
                    posts.append(post.id)
                }
                return (reading.id, [one.id, two.id], posts)
            }
            let book = Book(
                session: session, database: db,
                structure: BookStructureModel(session: session, readingID: readingID),
                readingID: readingID, sections: sections, posts: posts)
            _ = try await book.refresh()
            return try await body(book)
        }
    }

    /// THE SCENARIO SHE REPORTED, end to end: two chapters, and the first one
    /// moves DOWN — by a drop on a post in the second chapter's lower half,
    /// which before this batch was not a target at all.
    @Test func aTwoChapterBookMovesItsFirstChapterDownByDroppingOnAPost() async throws {
        try await withBook { book in
            let entries = try await book.refresh()
            #expect(book.structure.sections.map(\.name) == ["I", "II"])
            await book.structure.moveChapter(
                book.sections[0], onto: .post(book.posts[3]), entries: entries)
            _ = try await book.refresh()
            #expect(book.structure.sections.map(\.name) == ["II", "I"],
                    "the drop resolved to the end and the chapter moved")
            #expect(book.structure.lastError == nil)
        }
    }

    @Test func aPostDropFilesItIntoTheOtherChapterAndLandsWhereItWasDropped() async throws {
        try await withBook { book in
            var entries = try await book.refresh()
            let before = entries.map(\.postID)
            // p1 (chapter I) dropped on p4 (chapter II): it joins II, above p4.
            await book.structure.filePost(
                book.posts[0], onto: .post(book.posts[3]),
                entries: entries, reposition: true)
            entries = try await book.refresh()

            #expect(book.structure.assignments[book.posts[0]] == book.sections[1],
                    "assignPostToSection did the filing")
            let after = entries.map(\.postID)
            let landed = try #require(after.firstIndex(of: book.posts[0]))
            #expect(after[landed + 1] == book.posts[3],
                    "…and reorderReadingPost put it directly above the post she dropped on")
            #expect(after != before, "the order really moved")
            #expect(Set(after) == Set(before))
            #expect(book.structure.lastError == nil)
        }
    }

    /// The post moves UPWARD, and that direction is the whole point of the
    /// pin. `assembleReading` already orders a chaptered book by chapter, so
    /// a post moving DOWN into a later chapter lands at that chapter's top
    /// for free — assignment alone does it, and an assertion written that way
    /// asserts nothing (revert W11b-A ran GREEN on exactly that shape before
    /// this was rewritten). Moving UP is where the membership position has to
    /// be written: without it the post lands at the chapter's END.
    @Test func aPostDroppedOnAChapterHeaderLandsAtThatChaptersTop() async throws {
        try await withBook { book in
            var entries = try await book.refresh()
            let before = entries.map(\.postID)
            // p4 — the LAST post of chapter II — dropped on chapter I's header.
            let moved = book.posts[3]
            let chapterOneFirst = try #require(
                book.structure.grouped(entries: entries)
                    .first { $0.section?.id == book.sections[0] }?.entries.first?.postID)
            #expect(before.firstIndex(of: moved)! > before.firstIndex(of: chapterOneFirst)!,
                    "it starts BELOW the chapter it is about to join")

            await book.structure.filePost(
                moved, onto: .chapter(book.sections[0]),
                entries: entries, reposition: true)
            entries = try await book.refresh()

            #expect(book.structure.assignments[moved] == book.sections[0])
            let after = entries.map(\.postID)
            #expect(after.first == moved, "it landed at the chapter's TOP, not its end")
            let landed = try #require(after.firstIndex(of: moved))
            #expect(after[landed + 1] == chapterOneFirst)
            #expect(Set(after) == Set(before), "nothing joined or left the book")
        }
    }

    /// P-2 at the drop: a FINISHED book fires the operation and delivers its
    /// real refusal (#25(b) — a locked reading freezes chapter structure and
    /// assignment), never a silent no-op and never a lecture.
    @Test func aDropOnAFinishedBookSpeaksTheOperationsOwnRefusal() async throws {
        try await withBook { book in
            let entries = try await book.refresh()
            try await book.session.runner.run { [readingID = book.readingID] ops in
                try ops.lockReading(readingID)
            }
            _ = try await book.refresh()

            await book.structure.filePost(
                book.posts[0], onto: .chapter(book.sections[1]),
                entries: entries, reposition: true)
            let postRefusal = try #require(book.structure.lastError)
            // 13i-d U6 (KnownIssues row 106 — a JUSTIFIED EDIT): the generic
            // arm's dead "locked — unlock" became the true roads ("finished —
            // reopen it first; if it's sealed, unseal it"); the subject — the
            // operation's real refusal, spoken — is unchanged.
            #expect(postRefusal.contains("finished") && postRefusal.contains("reopen"),
                    "\(postRefusal)")
            #expect(book.structure.assignments[book.posts[0]] == book.sections[0],
                    "nothing moved")

            await book.structure.moveChapter(
                book.sections[0], onto: .end, entries: entries)
            let chapterRefusal = try #require(book.structure.lastError)
            #expect(chapterRefusal.contains("finished") && chapterRefusal.contains("reopen"),
                    "\(chapterRefusal)")
            _ = try await book.refresh()
            #expect(book.structure.sections.map(\.name) == ["I", "II"])
        }
    }

    /// The dispatcher: one entry point, two payload kinds, and a foreign
    /// payload refused rather than guessed at.
    @Test func theDropDispatcherRoutesByPayloadKindAndRefusesForeignOnes() async throws {
        try await withBook { book in
            let entries = try await book.refresh()
            typealias Drag = BookStructureModel.BookDrag

            #expect(book.structure.acceptDrop(
                ["a bare id from somewhere else"],
                chapter: .end, post: .unfiled,
                entries: entries, viewOrder: nil) == false)
            #expect(book.structure.acceptDrop(
                [], chapter: .end, post: .unfiled,
                entries: entries, viewOrder: nil) == false)
            _ = try await book.refresh()
            #expect(book.structure.sections.map(\.name) == ["I", "II"])
            #expect(book.structure.assignments[book.posts[0]] == book.sections[0])

            #expect(book.structure.acceptDrop(
                [Drag.chapter(book.sections[0]).payload],
                chapter: .end, post: .unfiled,
                entries: entries, viewOrder: nil) == true)
            // The act runs in a Task the dispatcher spawns; settle it.
            for _ in 0..<200 where book.structure.sections.first?.name != "II" {
                try await Task.sleep(for: .milliseconds(5))
                _ = try await book.refresh()
            }
            #expect(book.structure.sections.map(\.name) == ["II", "I"])
        }
    }

    /// Position is only written when position is what she is LOOKING at: a
    /// stamp-sorted book files the post and leaves the stored manual order
    /// alone (writing an order she cannot see would be an invisible edit).
    @Test func repositioningFollowsWhateverOrderTheBookIsRenderedIn() async throws {
        try await withBook { book in
            _ = try await book.refresh()
            #expect(book.structure.repositionsOnDrop(viewOrder: nil) == true,
                    "a fresh curated book is manual")
            #expect(book.structure.repositionsOnDrop(
                viewOrder: Queries.ReadingOrder(field: .entryDate, direction: .asc)) == false,
                    "an A31 view override decides what she is looking at")

            try await book.session.runner.run { [readingID = book.readingID] ops in
                try ops.setReadingSort(readingID, field: .createdAt, direction: .asc)
            }
            _ = try await book.refresh()
            #expect(book.structure.repositionsOnDrop(viewOrder: nil) == false)
            #expect(book.structure.repositionsOnDrop(
                viewOrder: Queries.ReadingOrder(field: .manual, direction: .asc)) == true,
                    "…and an override back to manual makes position visible again")
        }
    }
}
