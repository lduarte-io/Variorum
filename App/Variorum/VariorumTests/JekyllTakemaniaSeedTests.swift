//
//  JekyllTakemaniaSeedTests.swift
//  VariorumTests
//
//  18l-c U6 — the takemania book's acceptance bar, as state-transition
//  evidence (the sizing guidance's bar for an operations-family unit): what
//  a fresh seed leaves in the store, row by row — the book and its
//  disclaimer, takemania's fans and labels and archived takes, its lineage
//  (divide AND merge AND extract), its tray, its released originals, its
//  savepoints named and unnamed and renamed, and the dates they carry — plus
//  the seeder's own contracts: idempotence, the two restore roads, title-last
//  completeness with its heal, the Pool left blank, nothing on the
//  structural-undo stack, and the book kept out of the sync dedupe's facts.
//
//  The shape numbers are EXACT on purpose: the history is a script, so any
//  drift in it (a step that silently stopped doing what it did) is loud.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withJekyllWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_950_400)
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 42))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

/// A defaults-free mark, so a pin never touches this machine's real ones.
@MainActor
private final class JekyllMark {
    var value = false
    var load: () -> Bool { { [self] in value } }
    var save: (Bool) -> Void { { [self] in value = $0 } }
}

/// takemania's shape, read off the store in one pass.
private struct TakemaniaShape: Equatable, Sendable {
    var noteID = ""
    var placedBlocks = 0
    var fannedBlocks = 0
    var unfannedBlocks = 0
    var archivedTakes = 0
    var labels: Set<String> = []
    var lineage: [String: Int] = [:]   // origin_op → live derived_from edges touching the note's blocks
    var trayCount = 0
    var trayDaysLeft: [Int] = []
    var trayFannedBlocks = 0
    var preservedOriginals = 0
    var manualSavepoints = 0
    var namedSavepoints: Set<String> = []
    var unnamedManualSavepoints = 0
    var autoSavepoints = 0
    var earliestStamp = ""
    var latestStamp = ""
    var renderedText = ""
    var chosenTexts: [String] = []
}

private let jekyll = SampleLibrarySeeder.Book.jekyllAndHyde
private typealias P = TakemaniaProse

@MainActor
@Suite("The takemania book — The Strange Case of Dr Jekyll and Mr Hyde (18l-c U6)")
struct JekyllTakemaniaSeedTests {

    // MARK: - The source and the plan

    @Test("The bundled text is the two quiet chapters, unwrapped, with no stored blank lines")
    func bundledTextIsTheTwoQuietChapters() throws {
        let stories = try SampleLibrarySeeder.loadStories(for: jekyll)
        #expect(stories.map(\.title) == [
            "Story of the Door", "Henry Jekyll\u{2019}s Full Statement of the Case",
        ])
        #expect(stories[0].text.hasPrefix("Mr. Utterson the lawyer was a man of a rugged countenance"))
        for story in stories {
            #expect(!story.text.contains("Project Gutenberg"))
            #expect(!story.text.contains("PROJECT GUTENBERG"))
            let blocks = SegmentationRules.bulkSegments(story.text, mode: .paragraph)
            #expect(blocks.count > 20, Comment(rawValue: story.title))
            // Her own notes' shape — no paragraph stores a blank line
            // (design call 4).
            #expect(blocks.allSatisfy { !$0.hasSuffix("\n") }, Comment(rawValue: story.title))
        }
        let words = stories.reduce(0) { $0 + $1.text.split(separator: " ").count }
        #expect(words > 9_000 && words < 10_000)
    }

    @Test("The plan puts takemania between the two quiet chapters, and counts it toward 'complete'")
    func thePlanPutsTakemaniaBetweenTheQuietChapters() throws {
        let stories = try SampleLibrarySeeder.loadStories(for: jekyll)
        let titles = SampleLibrarySeeder.expectedTitles(for: jekyll, stories: stories)
        #expect(titles == ["Story of the Door", Takemania.title, "Henry Jekyll\u{2019}s Full Statement of the Case"])
        // Every book before U6 plans exactly its stories.
        let sherlock = try SampleLibrarySeeder.loadStories()
        #expect(SampleLibrarySeeder.expectedTitles(for: .sherlock, stories: sherlock) == sherlock.map(\.title))
    }

    // MARK: - The book

    @Test("The seed mints the book: front matter, two quiet chapters, takemania — one chapter each, tagged, the Pool blank, no undo entry")
    func seedMintsTheBook() async throws {
        try await withJekyllWorld { session, db in
            let mark = JekyllMark()
            let clock = ContinuousClock()
            let began = clock.now
            let outcome = await SampleLibrarySeeder.seedIfNeeded(
                session: session, book: jekyll, loadMark: mark.load, saveMark: mark.save)
            let took = clock.now - began
            print("[18l-c U6] the Jekyll seed (skeleton + 2 quiet chapters + takemania's history) took \(took)")
            guard case .seeded(let bookID, let minted) = outcome else {
                Issue.record("expected a seed, got \(outcome)")
                return
            }
            #expect(minted == 3)
            #expect(mark.value, "the mark lands only after the COMPLETE seed")
            #expect(session.undoStack.depth == 0, "furniture never lands on her structural-undo stack")
            #expect(session.undoStack.topLabel == nil)
            try await db.read { db in
                let book = try #require(try Queries.reading(db, id: bookID))
                #expect(book.name == SampleLibraryJekyllBook.name && book.kind == .curated)
                #expect(book.createdAt == SampleLibraryJekyllBook.publicationDate,
                        "the book itself carries the novella's publication date")
                let chapters = try Queries.readingSections(db, readingID: bookID).map(\.name)
                #expect(chapters == [
                    SampleLibraryJekyllBook.frontMatterChapter, "Story of the Door",
                    Takemania.chapter, "Henry Jekyll\u{2019}s Full Statement of the Case",
                ])
                let entries = try Queries.assembleReading(db, readingID: bookID)
                #expect(entries.compactMap(\.title) == [
                    SampleLibraryJekyllBook.frontMatterTitle, "Story of the Door",
                    Takemania.title, "Henry Jekyll\u{2019}s Full Statement of the Case",
                ])
                #expect(Set(entries.compactMap(\.sectionPath)).count == 4, "one chapter per note")
                let tag = try #require(try Queries.allTags(db).first { $0.path == SampleLibraryJekyllBook.tagName })
                #expect(try Queries.everythingTagged(db, tagID: tag.id).postIDs.count == 4)
                // HER CHECK, for this book too: every note is a member.
                #expect(try Queries.poolPosts(db, limit: 100).isEmpty)
            }
        }
    }

    /// R-18l-12's three items, and the door the first one names is the door
    /// the registry actually renders (a renamed verb would make the
    /// disclaimer lie).
    @Test("The front matter carries R-18l-12's disclaimer, naming the real Restore door")
    func theFrontMatterCarriesTheDisclaimer() {
        let text = SampleLibraryJekyllBook.aboutThisBook
        #expect(text.contains("on purpose"), "(1) the deleted blocks ship on purpose")
        #expect(text.contains("thirty-day clock"), "(1) …and leave on the ordinary clock")
        #expect(text.contains("Help \u{25B8} " + CapabilityRegistry.capability(.restoreJekyllBook).verb),
                "(1) Restore for the full experience — the door's own name")
        #expect(text.contains("can appear twice"), "(2) the two-devices note")
        #expect(text.contains("\u{201C}\(SampleLibraryJekyllBook.tagName)\u{201D}"), "the tag sentence")
        #expect(!text.contains("\n\n"), "no stored blank lines (design call 4)")
    }

    // MARK: - takemania's history

    @Test("takemania carries a real history: fans beside plain blocks, lineage, a tray, named savepoints, weeks of dates")
    func takemaniaCarriesARealHistory() async throws {
        try await withJekyllWorld { session, db in
            @Dependency(\.date) var date
            let mark = JekyllMark()
            let before = date.now
            let outcome = await SampleLibrarySeeder.seedIfNeeded(
                session: session, book: jekyll, loadMark: mark.load, saveMark: mark.save)
            guard case .seeded(let bookID, _) = outcome else {
                Issue.record("expected a seed, got \(outcome)")
                return
            }
            let now = date.now
            let shape = try await db.read { db in try Self.shape(db, bookID: bookID, now: now) }

            // The blocks: fans beside blocks with none.
            #expect(shape.placedBlocks == 47)
            #expect(shape.fannedBlocks == 10, "blocks with two or more live takes")
            #expect(shape.unfannedBlocks == 37)
            #expect(shape.archivedTakes == 2, "the eyesore's first try; Hyde's exit with the dialogue")
            #expect(shape.labels.isSuperset(of: [
                "Stevenson", "tighter", "short", "scroll", "no face", "plainer",
                "the maid tells it", "the stick first", "shorter", "five blows",
                "open ending", "Stevenson\u{2019}s close", "Lanyon next", "sat up", "one hand",
                "cut to the door",
            ]))

            // Lineage: real edges from real divides, merges and an extract.
            #expect(shape.lineage == ["divide": 4, "merge": 4, "extract": 1])

            // The tray: five blocks deleted over the last three weeks — one of
            // them fanned — and five released originals behind the lineage doors.
            #expect(shape.trayCount == 5)
            #expect(shape.trayFannedBlocks == 1, "Guest's fireside went with both its takes")
            #expect(shape.trayDaysLeft.allSatisfy { (1...30).contains($0) })
            #expect((shape.trayDaysLeft.min() ?? 0) <= 12 && (shape.trayDaysLeft.max() ?? 0) >= 29,
                    "the clocks spread: \(shape.trayDaysLeft)")
            #expect(shape.preservedOriginals == 5,
                    "the two merges' four sources and the divided Hyde paragraph, whole")

            // Savepoints: deliberate ones, named and not, one renamed after
            // the fact; and the quiet ones leaving the note left behind.
            #expect(shape.manualSavepoints == 12)
            #expect(shape.unnamedManualSavepoints == 2)
            #expect(shape.namedSavepoints == [
                "the maid, in one piece", "the whole scroll, before cutting",
                "opening, back to Stevenson\u{2019}s rhythm", "Stevenson\u{2019}s door, untouched",
                "ending as Stevenson closes it", "before the oath gets shorter",
                "first pass at the weather", "keep the blood running cold",
                "after the divide: Hyde\u{2019}s face in two", "the open ending, reading it tomorrow",
            ])
            #expect(shape.autoSavepoints > 0, "leaving the note stamped its quiet savepoints")

            // Weeks of work, all of it in the past, the last of it yesterday.
            let earliest = try #require(DateFormatter.variorumISO8601.date(from: shape.earliestStamp))
            let latest = try #require(DateFormatter.variorumISO8601.date(from: shape.latestStamp))
            #expect(before.timeIntervalSince(earliest) > 30 * 86_400, "the first savepoint is over four weeks old")
            #expect(latest < before && before.timeIntervalSince(latest) < 2 * 86_400,
                    "the last is from the day before the seed, never the future")

            // What the note reads as: the chosen takes, the cuts at their exact
            // seams, the merge's rendering join, and none of what was deleted.
            let text = shape.renderedText
            #expect(text.contains(P.eyesoreStevenson) && text.contains(P.dreamShort))
            #expect(text.contains(P.nightTighter) && text.contains(P.doorFiveBlows))
            #expect(text.contains(P.endingOpen) && text.contains(P.oathShorter))
            #expect(text.contains(P.candle + "\n" + P.ifAnyOneKnows), "the merge's rendering join")
            #expect(text.contains(P.oldestFriends + "\n" + P.friendsYounger))
            #expect(shape.chosenTexts.contains(P.maidFirst) && shape.chosenTexts.contains(P.maidSecond))
            #expect(shape.chosenTexts.contains(P.fineNightFirst) && shape.chosenTexts.contains(P.fineNightSecond))
            #expect(shape.chosenTexts.contains(P.hydeFaceTop) && shape.chosenTexts.contains(P.hydeFaceBottom))
            #expect(shape.chosenTexts.contains(P.safeRemainder) && shape.chosenTexts.contains(P.bloodRanCold))
            #expect(shape.chosenTexts.contains(P.guestComparesV2) && shape.chosenTexts.contains(P.openingV3))
            for gone in [P.mrSeek, P.maladyTheory, P.kettleAndBook, P.chevalGlass, P.guestWine] {
                #expect(!text.contains(gone))
            }
            #expect(shape.chosenTexts.allSatisfy { !$0.hasSuffix("\n") }, "her own notes' shape")
            #expect(!text.contains(Takemania.workingTitle))
        }
    }

    /// The divide-W's keep-on-top shape, row by row: the displayed take cut
    /// into B and C, the other take riding WHOLE onto B under its own name,
    /// the original preserved whole with both of its takes.
    @Test("Hyde's face: divided keep-on-top — the other take rides whole onto the top block, the original preserved")
    func theFannedDivideKeepsTheOtherTakeOnTop() async throws {
        try await withJekyllWorld { session, db in
            let mark = JekyllMark()
            _ = await SampleLibrarySeeder.seedIfNeeded(
                session: session, book: jekyll, loadMark: mark.load, saveMark: mark.save)
            try await db.read { db in
                let top = try #require(try String.fetchOne(
                    db, sql: "SELECT block_id FROM variant WHERE working_text = ? AND deleted_at IS NULL",
                    arguments: [P.hydeFaceTop]))
                let takes = try Row.fetchAll(
                    db,
                    sql: """
                        SELECT working_text, label FROM variant
                        WHERE block_id = ? AND deleted_at IS NULL AND status = 'active'
                        ORDER BY fan_position, id
                        """,
                    arguments: [top])
                #expect(takes.map { $0["working_text"] as String } == [P.hydeFaceTop, P.hydeFacePlainer])
                #expect(takes.last?["label"] as String? == "plainer", "a parked take keeps its name")
                // The original: unplaced, alive, both takes whole.
                let original = try #require(try String.fetchOne(
                    db,
                    sql: """
                        SELECT v.block_id FROM variant v JOIN block b ON b.id = v.block_id
                        WHERE v.working_text = ? AND b.deleted_at IS NULL
                          AND NOT EXISTS (SELECT 1 FROM container_block cb
                                          WHERE cb.block_id = b.id AND cb.deleted_at IS NULL)
                        """,
                    arguments: [P.hydeFaceStevenson]))
                let originalTakes = try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM variant WHERE block_id = ? AND deleted_at IS NULL",
                    arguments: [original]) ?? 0
                #expect(originalTakes == 2)
                let edges = try Int.fetchOne(
                    db,
                    sql: """
                        SELECT COUNT(*) FROM edge WHERE target_block_id = ? AND type = 'derived_from'
                          AND origin_op = 'divide' AND deleted_at IS NULL
                        """,
                    arguments: [original]) ?? 0
                #expect(edges == 2, "both successors name it as their origin")
            }
        }
    }

    // MARK: - The seeder's contracts

    @Test("Seeding twice mints no second book and no second takemania")
    func seedingTwiceIsANoOp() async throws {
        try await withJekyllWorld { session, db in
            let mark = JekyllMark()
            _ = await SampleLibrarySeeder.seedIfNeeded(
                session: session, book: jekyll, loadMark: mark.load, saveMark: mark.save)
            let second = await SampleLibrarySeeder.seedIfNeeded(
                session: session, book: jekyll, loadMark: mark.load, saveMark: mark.save)
            #expect(second == .alreadySeeded, "the device mark is the first guard")
            mark.value = false
            let third = await SampleLibrarySeeder.seedIfNeeded(
                session: session, book: jekyll, loadMark: mark.load, saveMark: mark.save)
            #expect(third == .alreadyPresent, "discovery — takemania's title included — is the guard that holds")
            try await db.read { db in
                #expect(try Queries.readings(db).filter { $0.name == SampleLibraryJekyllBook.name }.count == 1)
                let takemanias = try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM container WHERE title = ? AND deleted_at IS NULL",
                    arguments: [Takemania.title]) ?? 0
                #expect(takemanias == 1)
            }
            #expect(session.undoStack.depth == 0)
        }
    }

    /// R-18l-12's "Restore for the full experience", made true: delete the
    /// played-with takemania and the door mints a FRESH one, whole history
    /// and all — and the old one sits in the Trash.
    @Test("Delete takemania, then Help ▸ Restore: a fresh takemania with its whole history")
    func restoreAfterDeletingTakemaniaMintsAFreshOne() async throws {
        try await withJekyllWorld { session, db in
            @Dependency(\.date) var date
            let mark = JekyllMark()
            guard case .seeded(let bookID, _) = await SampleLibrarySeeder.seedIfNeeded(
                session: session, book: jekyll, loadMark: mark.load, saveMark: mark.save)
            else {
                Issue.record("expected a seed")
                return
            }
            let first = try await db.read { db in try Self.shape(db, bookID: bookID, now: date.now) }
            try await session.runner.run { ops in try ops.deleteContainer(first.noteID) }

            let outcome = try await SeededBookRestore.restore(session: session, book: jekyll)
            #expect(outcome == .restored(readingID: bookID, minted: 1))
            let fresh = try await db.read { db in try Self.shape(db, bookID: bookID, now: date.now) }
            #expect(fresh.noteID != first.noteID, "a FRESH note, not the one she deleted")
            #expect(fresh.placedBlocks == first.placedBlocks && fresh.fannedBlocks == first.fannedBlocks)
            #expect(fresh.lineage == first.lineage && fresh.trayCount == first.trayCount)
            #expect(fresh.namedSavepoints == first.namedSavepoints)
            let deletedAt = try await db.read { db in
                try String.fetchOne(db, sql: "SELECT deleted_at FROM container WHERE id = ?", arguments: [first.noteID])
            }
            #expect(deletedAt != nil, "the played-with copy is in the Trash, not gone")
            // And a second press finds the book whole.
            let again = try await SeededBookRestore.restore(session: session, book: jekyll)
            #expect(again == .alreadyWhole(readingID: bookID))
        }
    }

    /// F10 for the scripted note: deleting the BOOK keeps its notes, and the
    /// restore road RE-MEMBERS them — takemania included, with its history.
    @Test("Delete the book, then Restore: the same notes come back, takemania's history intact")
    func restoreAfterDeletingTheBookReMembersTheNotes() async throws {
        try await withJekyllWorld { session, db in
            @Dependency(\.date) var date
            let mark = JekyllMark()
            guard case .seeded(let bookID, _) = await SampleLibrarySeeder.seedIfNeeded(
                session: session, book: jekyll, loadMark: mark.load, saveMark: mark.save)
            else {
                Issue.record("expected a seed")
                return
            }
            let original = try await db.read { db in
                Set(try Queries.assembleReading(db, readingID: bookID).map(\.postID))
            }
            let before = try await db.read { db in try Self.shape(db, bookID: bookID, now: date.now) }
            try await session.runner.run { ops in try ops.deleteReading(bookID) }

            let outcome = try await SeededBookRestore.restore(session: session, book: jekyll)
            guard case .restored(let newBookID, let minted) = outcome else {
                Issue.record("expected a restore, got \(outcome)")
                return
            }
            #expect(minted == 3, "every note came back — by membership, not by mint")
            let members = try await db.read { db in
                Set(try Queries.assembleReading(db, readingID: newBookID).map(\.postID))
            }
            #expect(members == original, "the SAME notes are the book's members again")
            let after = try await db.read { db in try Self.shape(db, bookID: newBookID, now: date.now) }
            #expect(after.noteID == before.noteID)
            #expect(after.placedBlocks == before.placedBlocks && after.namedSavepoints == before.namedSavepoints)
        }
    }

    /// **Design call 3, pinned — COMPLETE, OR NOT THERE.** A history stopped
    /// halfway (a process death, a refused write) must never be marked done:
    /// the note carries the reserved working title until its LAST act, so
    /// discovery never counts it present; the next occasion trashes it and
    /// mints a whole takemania, and only then is the mark set.
    ///
    /// *Red on the title-first shape* (the history's rename moved to its
    /// first step): discovery reads the stopped note as present, the book as
    /// complete, and the launch seed marks it done over a half-built note.
    @Test("A history stopped halfway is never marked done — the next occasion trashes it and mints a whole one")
    func aStoppedHistoryIsNeverMarkedAndHealsNextTime() async throws {
        try await withJekyllWorld { session, db in
            let stories = try SampleLibrarySeeder.loadStories(for: jekyll)
            let titles = SampleLibrarySeeder.expectedTitles(for: jekyll, stories: stories)
            // The stopped history: forty steps into takemania's first weeks.
            await #expect(throws: Takemania.ScriptError.interrupted(afterStep: 40)) {
                try await SampleLibrarySeeder.seed(
                    session: session, book: jekyll, stories: stories,
                    existing: SampleLibrarySeeder.Existing(), interruptScriptAfterStep: 40)
            }
            let stopped = try await db.read { db in try SampleLibrarySeeder.discover(db, book: jekyll) }
            #expect(!stopped.isComplete(for: titles), "a half-written takemania is not present")
            #expect(stopped.presentTitles.contains(Takemania.workingTitle))
            #expect(!stopped.presentTitles.contains(Takemania.title))
            #expect(stopped.halfBuiltNoteIDs.count == 1)
            #expect(!stopped.presentTitles.contains("Henry Jekyll\u{2019}s Full Statement of the Case"),
                    "the stop also held back the chapter after takemania — the seed resumes it too")
            // Not a `#require`: on the title-first shape the id is missing, and
            // the rest of this pin must still run to show what follows — the
            // mark set over a half-built takemania.
            let halfBuilt = stopped.halfBuiltNoteIDs.first
            #expect(try await db.read { db in try Queries.poolPosts(db, limit: 100).isEmpty },
                    "even stopped, the note is a book member — never in the Pool")

            // The next occasion.
            let mark = JekyllMark()
            let outcome = await SampleLibrarySeeder.seedIfNeeded(
                session: session, book: jekyll, loadMark: mark.load, saveMark: mark.save)
            guard case .seeded(let bookID, let minted) = outcome else {
                Issue.record("expected the healing seed, got \(outcome)")
                return
            }
            #expect(minted == 2, "takemania, and the last chapter the stopped seed never reached")
            #expect(mark.value)
            try await db.read { db in
                if let halfBuilt {
                    let trashed = try String.fetchOne(
                        db, sql: "SELECT deleted_at FROM container WHERE id = ?", arguments: [halfBuilt])
                    #expect(trashed != nil, "the half-built note went to the Trash")
                }
                let entries = try Queries.assembleReading(db, readingID: bookID).compactMap(\.title)
                #expect(entries.filter { $0 == Takemania.title }.count == 1)
                #expect(!entries.contains(Takemania.workingTitle))
                // The mark is set — so what it was set over must be WHOLE.
                #expect(try Self.shape(db, bookID: bookID, now: Date()).fannedBlocks == 10,
                        "the marked takemania is whole, never the half-built one")
            }
        }
    }

    /// Design call 1 (PROVISIONAL, QUESTIONS #155): the engine's facts list
    /// stays EXACTLY Sherlock + *Encryption Explained*; the Jekyll book is
    /// seeded everywhere and judged nowhere.
    @Test("The sync dedupe's facts leave the Jekyll book out — the engine's list is unchanged")
    func theDedupeFactsLeaveTheJekyllBookOut() {
        #expect(SampleLibrarySeeder.Book.all.contains(jekyll))
        #expect(!jekyll.joinsPristineDedupe)
        let names = SampleLibrarySeeder.allDedupeFacts().map(\.bookName)
        #expect(names == [SampleLibrarySeeder.bookName, SampleLibraryEncryptionBook.name])
        #expect(!names.contains(SampleLibraryJekyllBook.name))
    }

    @Test("Its own mark: stores whose other books are marked still seed this one, and only it")
    func itsOwnMark() async throws {
        try await withJekyllWorld { session, db in
            let variant = AppDatabase.StoreVariant.real.rawValue
            #expect(SampleLibrarySeeder.seededDefaultsKey(for: .real, book: jekyll)
                    == "SampleLibrarySeeded.\(variant).jekyll-and-hyde")
            let marked = JekyllMark()
            marked.value = true
            let mine = JekyllMark()
            for book in SampleLibrarySeeder.Book.all {
                let mark = book == jekyll ? mine : marked
                _ = await SampleLibrarySeeder.seedIfNeeded(
                    session: session, book: book, loadMark: mark.load, saveMark: mark.save)
            }
            let names = try await db.read { db in try Queries.readings(db).map(\.name) }
            #expect(names == [SampleLibraryJekyllBook.name])
            #expect(mine.value)
        }
    }

    // MARK: - Reading the shape

    nonisolated private static func shape(_ db: Database, bookID: String, now: Date) throws -> TakemaniaShape {
        var shape = TakemaniaShape()
        let entry = try #require(try Queries.assembleReading(db, readingID: bookID)
            .first { $0.title == Takemania.title })
        let note = entry.postID
        shape.noteID = note
        let placed = try String.fetchAll(
            db, sql: "SELECT block_id FROM container_block WHERE container_id = ? AND deleted_at IS NULL",
            arguments: [note])
        shape.placedBlocks = placed.count
        for block in placed {
            let active = try Int.fetchOne(
                db,
                sql: "SELECT COUNT(*) FROM variant WHERE block_id = ? AND deleted_at IS NULL AND status = 'active'",
                arguments: [block]) ?? 0
            if active >= 2 { shape.fannedBlocks += 1 } else { shape.unfannedBlocks += 1 }
            shape.archivedTakes += try Int.fetchOne(
                db,
                sql: "SELECT COUNT(*) FROM variant WHERE block_id = ? AND deleted_at IS NULL AND status = 'archived'",
                arguments: [block]) ?? 0
            shape.labels.formUnion(try String.fetchAll(
                db, sql: "SELECT label FROM variant WHERE block_id = ? AND deleted_at IS NULL AND label IS NOT NULL",
                arguments: [block]))
        }
        shape.chosenTexts = try Queries.renderPost(db, containerID: note).compactMap(\.text)
        shape.renderedText = try Queries.renderedText(db, containerID: note)

        // Every block that was ever this note's: placed now, or released/deleted from it.
        let family = try String.fetchAll(
            db,
            sql: """
                SELECT id FROM block WHERE last_container_id = ?
                UNION SELECT block_id FROM container_block WHERE container_id = ?
                """,
            arguments: [note, note])
        let familyJSON = String(data: try JSONEncoder().encode(family), encoding: .utf8) ?? "[]"
        for row in try Row.fetchAll(
            db,
            sql: """
                SELECT origin_op, COUNT(*) AS n FROM edge
                WHERE type = 'derived_from' AND deleted_at IS NULL
                  AND source_block_id IN (SELECT value FROM json_each(?))
                GROUP BY origin_op
                """,
            arguments: [familyJSON]) {
            shape.lineage[row["origin_op"] as String? ?? "nil"] = row["n"] as Int? ?? 0
        }

        let tray = try Queries.trayBlocks(db, postID: note, now: now)
        shape.trayCount = tray.count
        shape.trayDaysLeft = tray.compactMap { TrashWindow.daysLeft($0.deletedAt, now: now) }
        for item in tray {
            let takes = try Int.fetchOne(
                db, sql: "SELECT COUNT(*) FROM variant WHERE block_id = ? AND deleted_at = ?",
                arguments: [item.blockID, item.deletedAt]) ?? 0
            if takes >= 2 { shape.trayFannedBlocks += 1 }
        }
        shape.preservedOriginals = try Queries.preservedOriginals(db, postID: note).count

        let commits = try Row.fetchAll(
            db,
            sql: """
                SELECT cp.kind, cp.message, cp.created_at FROM commit_point cp
                JOIN variant v ON v.id = cp.variant_id
                WHERE v.block_id IN (SELECT value FROM json_each(?))
                ORDER BY cp.created_at, cp.id
                """,
            arguments: [familyJSON])
        for commit in commits {
            let kind = commit["kind"] as String
            if kind == "manual" {
                shape.manualSavepoints += 1
                if let message = commit["message"] as String? {
                    shape.namedSavepoints.insert(message)
                } else {
                    shape.unnamedManualSavepoints += 1
                }
            } else {
                shape.autoSavepoints += 1
            }
        }
        shape.earliestStamp = commits.first?["created_at"] ?? ""
        shape.latestStamp = commits.last?["created_at"] ?? ""
        return shape
    }
}
