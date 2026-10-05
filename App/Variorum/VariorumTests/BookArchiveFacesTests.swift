//
//  BookArchiveFacesTests.swift
//  VariorumTests
//
//  13i-e U2 — THE FACES of book archive (her kickoff rulings R-13ie-1…4 with
//  both riders; the sitting record §10; the architect's U2 riders). The
//  binding record is the 13i-e plan's U2 RECORD
//  (`notes/plans/phase-13i-e-daily-journal.md`).
//
//  - the registry: `.archiveBook` / `.unarchiveBook` declared and rendered;
//    WHICH of Archive · Unarchive · Delete renders is DATA
//    (`BookArchiveDoorSet` — the daily Journal never offers Delete, P-2);
//  - the doors' acts through the one brain (`BookStateDoors`): a plain book,
//    a gathering and the daily Journal archive at once; an OWNED book asks
//    (the delete confirm's twin); unarchive says what came back and what
//    waits at Arrivals; the daily Journal's delete refuses in the table's
//    words;
//  - the Book Settings sheet's Archived row and THE VISIBLE PAUSE (mounted);
//  - the Archived surface's BOOKS group's brain and words;
//  - the "(archived)" marks (her second rider's lighter road);
//  - the comes-back RECEIPT on the ⌘J road (F-U1-6's ruling);
//  - the wing refusal's "(N archived)" (F-U1-8's copy rider).
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore

@testable import Variorum

// MARK: - The world

@MainActor
private func withArchiveWorld<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 61))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

private func pump(_ seconds: TimeInterval = 0.1) {
    RunLoop.main.run(until: Date().addingTimeInterval(seconds))
}

@MainActor
private func settle(until condition: () -> Bool = { false }) async {
    for _ in 0..<20 where !condition() {
        pump(0.05)
        for _ in 0..<10 { await Task.yield() }
    }
}

/// Mounts `view` in a real window for the body of `run`.
@MainActor
private func mounted<V: View>(_ view: V, _ run: () async throws -> Void) async throws {
    let window = NSWindow(
        contentRect: NSRect(x: 60, y: 60, width: 640, height: 760),
        styleMask: [.titled, .resizable], backing: .buffered, defer: false)
    window.isReleasedWhenClosed = false
    defer {
        window.orderOut(nil)
        window.close()
    }
    window.contentView = NSHostingView(rootView: view)
    window.orderFrontRegardless()
    await settle()
    try await run()
}

@MainActor
private func reading(_ db: AppDatabase, _ id: String) async throws -> Reading {
    try #require(try await db.read { try Queries.reading($0, id: id) })
}

@MainActor
private func archivedAt(_ db: AppDatabase, post id: String) async throws -> Date? {
    try await db.read { try Container.fetchOne($0, key: id)?.archivedAt }
}

/// A note minted inside a book (an explicit add — the hand door).
@MainActor
private func noteIn(_ session: AppSession, _ bookID: String) throws -> String {
    try session.operations.newPostInReading(bookID, section: nil, title: nil, profile: .generic).id
}

private func rule(_ term: RuleTerm) throws -> String {
    try #require(try RuleGrammar.encode(term))
}

/// A bare reading for the pure tables (never stored).
private func bare(
    _ name: String = "B", kind: ReadingKind = .book, profile: String? = nil,
    archived: Bool = false, querySpec: String? = nil
) -> Reading {
    var reading = Reading(
        id: "r-\(name)", name: name, kind: kind, profile: profile, querySpec: querySpec,
        createdAt: Date(timeIntervalSince1970: 0), updatedAt: Date(timeIntervalSince1970: 0))
    if archived { reading.archivedAt = Date(timeIntervalSince1970: 60) }
    return reading
}

// MARK: - The registry and the table

@MainActor
@Suite("13i-e U2 — the archive acts are declared, and which renders is data")
struct BookArchiveDeclarationTests {
    @Test func theTwoActsAreDeclaredAndRendered() {
        let archive = CapabilityRegistry.capability(.archiveBook)
        #expect(archive.verb == "Archive" && archive.scope == .book)
        #expect(archive.doors == [.contextMenu, .surface])
        let unarchive = CapabilityRegistry.capability(.unarchiveBook)
        #expect(unarchive.verb == "Unarchive" && unarchive.scope == .book)
        // 17y B3 item (l) — A JUSTIFIED EDIT: Unarchive gains a context door
        // (the book row menu beyond the Bookcase renders it on an archived
        // book); the subject — never on the BOOKCASE's menu, where an
        // archived book never stands — holds below, unchanged.
        #expect(unarchive.doors == [.surface, .contextMenu])
        #expect(BookRowMenu.contextMenuCapabilities.contains(.unarchiveBook))
        #expect(ShelfView.contextMenuCapabilities.contains(.archiveBook))
        #expect(!ShelfView.contextMenuCapabilities.contains(.unarchiveBook),
                "an archived book is never on the Bookcase")
        #expect(BookSettingsSheet.surfaceCapabilities.contains(.archiveBook))
        #expect(BookSettingsSheet.surfaceCapabilities.contains(.unarchiveBook))
        #expect(ArchivedView.surfaceCapabilities.contains(.unarchiveBook))
        #expect(ArchivedView.surfaceCapabilities.contains(.deleteBook))
    }

    /// P-1 + P-2: archived ⇒ Unarchive, else Archive; Delete everywhere EXCEPT
    /// the daily Journal (the op refuses it — a door that could never act).
    @Test func theTableIsTheRule() {
        #expect(BookArchiveDoorSet.rendered(for: .init(archived: false, isDailyJournal: false))
                == [.archiveBook, .deleteBook])
        #expect(BookArchiveDoorSet.rendered(for: .init(archived: true, isDailyJournal: false))
                == [.unarchiveBook, .deleteBook])
        #expect(BookArchiveDoorSet.rendered(for: .init(archived: false, isDailyJournal: true))
                == [.archiveBook], "the daily Journal: Archive in Delete's place")
        #expect(BookArchiveDoorSet.rendered(for: .init(archived: true, isDailyJournal: true))
                == [.unarchiveBook])
        // The facts read the op guard's OWN predicate — the marker, never a name.
        #expect(BookArchiveFacts(bare("Journal", profile: Queries.dailyJournalBookProfile)).isDailyJournal)
        #expect(!BookArchiveFacts(bare("Journal", profile: Queries.journalTraitProfile)).isDailyJournal)
        #expect(!BookArchiveFacts(bare("g", kind: .gathering, profile: Queries.dailyJournalBookProfile))
            .isDailyJournal, "a gathering is never the daily Journal")
    }

    /// The owned door carries the ellipsis (it asks); every other acts at once.
    @Test func theArchiveDoorAsksOnlyOnAnOwnedBook() {
        var owned = bare("O")
        owned.owned = true
        #expect(BookStateCopy.archiveAsks(owned))
        #expect(BookStateCopy.archiveDoorLabel(asks: true) == "Archive\u{2026}")
        #expect(!BookStateCopy.archiveAsks(bare("P")))
        #expect(!BookStateCopy.archiveAsks(bare("g", kind: .gathering)))
        #expect(BookStateCopy.archiveDoorLabel(asks: false) == "Archive")
    }
}

// MARK: - The doors' acts

@MainActor
@Suite("13i-e U2 — the archive doors act through the one brain", .serialized)
struct BookArchiveDoorActTests {
    /// A PLAIN book archives AT ONCE, alone (R-13ie-2); its receipt names the
    /// road back and says its notes stay.
    @Test func aPlainBookArchivesAtOnceAndAlone() async throws {
        try await withArchiveWorld { session, db in
            let book = try session.operations.createReading(name: "Plain", kind: .book)
            let note = try noteIn(session, book.id)
            let doors = BookStateDoors(session: session)
            await doors.open(.archiveBook, readingID: book.id)
            #expect(doors.pending == nil, "no confirm on a plain book")
            #expect(try await reading(db, book.id).archivedAt != nil)
            #expect(try await archivedAt(db, post: note) == nil, "its note stays live")
            #expect(session.status.spoken?.text
                    == BookStateCopy.archived("Plain", kind: .book, dailyJournal: false))
            #expect(session.status.spoken?.kind == .receipt)
        }
    }

    /// An OWNED book ASKS — the delete confirm's twin — and each choice does
    /// what it says: book only (notes stay, still its own) · book and its N
    /// notes on ONE stamp; Unarchive brings exactly those back.
    @Test func anOwnedBookAsksAndBothChoicesDoWhatTheySay() async throws {
        try await withArchiveWorld { session, db in
            let ops = session.operations
            let owned = try ops.createReading(name: "Mine", kind: .book)
            _ = try ops.setReadingOwned(owned.id, owned: true)
            let a = try noteIn(session, owned.id)
            let b = try noteIn(session, owned.id)
            let doors = BookStateDoors(session: session)

            await doors.open(.archiveBook, readingID: owned.id)
            let ask = try #require(doors.pending)
            #expect(ask.act == .archiveBook)
            #expect(ask.confirmLabel == "Archive Book Only")
            #expect(ask.alternateLabel == "Archive Book and Its 2 Notes")
            #expect(ask.lines.joined().contains("stay in the Library"))
            #expect(try await reading(db, owned.id).archivedAt == nil, "asking archives nothing")

            // The second choice: the book AND its notes, one stamp.
            await doors.confirm(alternate: true)
            let stamp = try #require(try await reading(db, owned.id).archivedAt)
            #expect(try await archivedAt(db, post: a) == stamp)
            #expect(try await archivedAt(db, post: b) == stamp)
            #expect(session.status.spoken?.text == BookStateCopy.archivedWithNotes("Mine", notes: 2))

            // Unarchive returns them whole and says so.
            await doors.open(.unarchiveBook, readingID: owned.id)
            #expect(doors.pending == nil, "unarchive never asks")
            #expect(try await reading(db, owned.id).archivedAt == nil)
            #expect(try await archivedAt(db, post: a) == nil)
            #expect(session.status.spoken?.text
                    == "Unarchived \u{201C}Mine\u{201D} \u{2014} it\u{2019}s back on the Bookcase. "
                        + "Its 2 notes came back with it.")

            // The first choice: the book only — the notes stay live.
            await doors.open(.archiveBook, readingID: owned.id)
            await doors.confirm()
            #expect(try await reading(db, owned.id).archivedAt != nil)
            #expect(try await archivedAt(db, post: a) == nil, "book only: the notes stay")
        }
    }

    /// A GATHERING archives at once (R-13ie-3) and its receipt says what the
    /// pause means; the daily Journal archives at once and says it comes back.
    @Test func aGatheringAndTheDailyJournalArchiveAtOnce() async throws {
        try await withArchiveWorld { session, db in
            let ops = session.operations
            let t = try ops.createTag(name: "t")
            let gathering = try ops.createReading(
                name: "G", kind: .gathering, querySpec: try rule(.tag(t.id)))
            let doors = BookStateDoors(session: session)
            await doors.open(.archiveBook, readingID: gathering.id)
            #expect(doors.pending == nil)
            #expect(try await reading(db, gathering.id).archivedAt != nil)
            #expect(session.status.spoken?.text.contains("shows nothing until you unarchive it") == true)

            let entry = try ops.createPost(title: nil)
            guard case .shelved(let journal) = ops.shelveInDailyJournalBook(entry.id) else {
                Issue.record("the daily Journal is minted by the first filing")
                return
            }
            await doors.open(.archiveBook, readingID: journal)
            #expect(try await reading(db, journal).archivedAt != nil)
            #expect(session.status.spoken?.text.hasSuffix("it comes back when a day arrives.") == true)
        }
    }

    /// Unarchiving a LIVING book RESUMES with the catch-up — what matched
    /// meanwhile WAITS at Arrivals (never quiet seats), and the receipt counts it.
    @Test func unarchivingALivingBookSaysWhatWaits() async throws {
        try await withArchiveWorld { session, db in
            let ops = session.operations
            let t = try ops.createTag(name: "t")
            let living = try ops.createReading(name: "L", kind: .book, querySpec: try rule(.tag(t.id)))
            try ops.archiveReading(living.id)
            let later = try ops.createPost(title: "later")
            _ = try ops.applyTag(t.id, toPost: later.id)
            let doors = BookStateDoors(session: session)
            await doors.open(.unarchiveBook, readingID: living.id)
            #expect(session.status.spoken?.text.hasSuffix("1 waiting at Arrivals.") == true)
            #expect(try await db.read { try Queries.pendingArrivalCount($0, readingID: living.id) } == 1)
        }
    }

    /// The daily Journal's delete REFUSES in the shared table's words — the
    /// door is never drawn (the table), and a road that reached the act anyway
    /// hears the guard's sentence, never a raw enum.
    @Test func theDailyJournalsDeleteSpeaksTheGuardsWords() async throws {
        try await withArchiveWorld { session, db in
            let ops = session.operations
            let entry = try ops.createPost(title: nil)
            guard case .shelved(let journal) = ops.shelveInDailyJournalBook(entry.id) else {
                Issue.record("the daily Journal is minted by the first filing")
                return
            }
            let doors = BookStateDoors(session: session)
            let landed = await doors.perform(.deleteBook, readingID: journal)
            #expect(!landed)
            #expect(session.status.spoken?.text == BookArchiveCopy.cannotDeleteDailyJournal)
            #expect(session.status.spoken?.kind == .refusal)
            #expect(try await reading(db, journal).deletedAt == nil)
            #expect(OpsRefusalCopy.words(
                for: OperationError.readingAlreadyArchived(id: "x"), roads: .mac)
                    == "That book is already archived \u{2014} nothing changed.")
            #expect(OpsRefusalCopy.words(
                for: OperationError.readingNotArchived(id: "x"), roads: .mac)
                    == "That book isn't archived any more \u{2014} nothing changed.")
            #expect(DeletionRefusal.words(OperationError.dailyJournalCannotBeDeleted(id: journal))
                    == BookArchiveCopy.cannotDeleteDailyJournal, "the phone's delete road too")
        }
    }
}

// MARK: - The Book Settings sheet: the Archived row and THE VISIBLE PAUSE

@MainActor
@Suite("13i-e U2 — the sheet's Archived row and the visible pause", .serialized)
struct BookSettingsArchiveRowTests {
    /// The pure rules: the pause is said only where something auto-ingests
    /// (a book whose rule reads; a gathering), and only while archived.
    @Test func thePauseSentenceIsSaidOnlyWhereItIsTrue() throws {
        let spec = try rule(.star)
        #expect(BookArchiveCopy.pausedSentence(for: bare(archived: true, querySpec: spec))
                == "Collecting is paused while this book is archived.")
        #expect(BookArchiveCopy.pausedSentence(for: bare(archived: false, querySpec: spec)) == nil)
        #expect(BookArchiveCopy.pausedSentence(for: bare(archived: true)) == nil,
                "a rule-less book has no auto-ingestion to pause")
        #expect(BookArchiveCopy.pausedSentence(for: bare("g", kind: .gathering, archived: true, querySpec: spec))
                == BookArchiveCopy.pausedGathering)
        #expect(CollectingCopy.archiveCaption(for: bare("J", profile: Queries.dailyJournalBookProfile))
                == "The daily Journal can be archived, never deleted; it returns when a day arrives.",
                "§10's own sentence")
    }

    /// Mounted: a LIVING archived book's sheet draws Unarchive, the archived
    /// caption and the pause sentence; an open plain book's draws Archive and
    /// no pause; an archived gathering's sheet draws its State section (the
    /// archive row) and its own pause sentence; the explicit add doors are
    /// not this sheet's (nothing refuses them).
    @Test func theMountedSheetDrawsTheArchivedRowAndThePause() async throws {
        try await withArchiveWorld { session, db in
            let ops = session.operations
            let t = try ops.createTag(name: "t")
            let living = try ops.createReading(name: "L", kind: .book, querySpec: try rule(.tag(t.id)))
            let plain = try ops.createReading(name: "P", kind: .book)
            let gathering = try ops.createReading(
                name: "G", kind: .gathering, querySpec: try rule(.tag(t.id)))
            try ops.archiveReading(living.id)
            try ops.archiveReading(gathering.id)
            BookSettingsProbe.drawn = [:]

            for id in [living.id, plain.id, gathering.id] {
                let target = try #require(await BookSettingsTarget.load(session: session, readingID: id))
                try await mounted(BookSettingsHost(target: target)) {}
            }
            let l = try #require(BookSettingsProbe.drawn[living.id])
            #expect(l.archiveDoor == .unarchiveBook)
            #expect(l.archiveCaption == CollectingCopy.archivedCaption)
            #expect(l.paused == BookArchiveCopy.pausedBook)
            let p = try #require(BookSettingsProbe.drawn[plain.id])
            #expect(p.archiveDoor == .archiveBook)
            #expect(p.paused == nil)
            let g = try #require(BookSettingsProbe.drawn[gathering.id])
            #expect(g.archiveDoor == .unarchiveBook, "a gathering's sheet carries the archive row")
            #expect(g.paused == BookArchiveCopy.pausedGathering)

            // R-13ie-4's amendment, seen from here: an EXPLICIT add lands on
            // the archived living book.
            let note = try ops.createPost(title: "by hand")
            _ = try ops.addPostToReading(note.id, to: living.id)
            #expect(try await db.read {
                try Queries.liveMemberNoteCount($0, readingID: living.id) } == 1)
        }
    }
}

// MARK: - The Archived surface's BOOKS group

@MainActor
@Suite("13i-e U2 — the Archived surface's books group", .serialized)
struct ArchivedBooksGroupTests {
    @Test func theGroupListsNewestFirstWithHonestFacts() async throws {
        try await withArchiveWorld { session, db in
            let ops = session.operations
            let t = try ops.createTag(name: "t")
            let book = try ops.createReading(name: "Essays", kind: .book)
            _ = try noteIn(session, book.id)
            _ = try noteIn(session, book.id)
            let gathering = try ops.createReading(
                name: "Ideas", kind: .gathering, querySpec: try rule(.tag(t.id)))
            let open = try ops.createReading(name: "Open", kind: .book)
            try ops.archiveReading(book.id)
            try ops.archiveReading(gathering.id)

            let model = ArchivedBooksModel(session: session)
            await model.adopt(try await db.read { try Queries.archivedReadings($0, wingID: "") })
            #expect(model.books.map(\.id) == [gathering.id, book.id], "newest archive first")
            #expect(!model.books.contains { $0.id == open.id }, "a live, unarchived book is not here")
            #expect(model.noteCounts[book.id] == 2)
            #expect(ArchivedBookCopy.facts(model.books[1], notes: model.noteCounts[book.id])
                    == "book \u{00B7} 2 notes")
            #expect(ArchivedBookCopy.facts(model.books[0], notes: nil)
                    == "gathering \u{00B7} shows nothing while archived")
            #expect(ArchivedBooksModel.matches(model.books, query: "ess").map(\.id) == [book.id])
            #expect(ArchivedBookCopy.stamp(model.books[1])?.hasPrefix("archived ") == true)

            // The daily Journal says what it is, and never offers Delete.
            let entry = try ops.createPost(title: nil)
            guard case .shelved(let journal) = ops.shelveInDailyJournalBook(entry.id) else {
                Issue.record("the daily Journal is minted by the first filing")
                return
            }
            try ops.archiveReading(journal)
            let j = try await reading(db, journal)
            #expect(ArchivedBookCopy.facts(j, notes: 1).hasPrefix("daily Journal"))
            #expect(BookArchiveDoorSet.rendered(for: BookArchiveFacts(j))
                .filter { $0 != .archiveBook } == [.unarchiveBook])
            #expect(ArchivedView.subtitle == "notes and books you set aside \u{2014} kept, with no countdown")
        }
    }
}

// MARK: - The "(archived)" marks

@MainActor
@Suite("13i-e U2 — the (archived) marks name an archived book everywhere it appears")
struct ArchivedMarkTests {
    @Test func theOneMark() async throws {
        #expect(BookArchiveCopy.name(bare("Old", archived: true)) == "Old (archived)")
        #expect(BookArchiveCopy.name(bare("New")) == "New")
        #expect(BookPanelCopy.stateWords(bare("Old", archived: true)) == "archived")
        #expect(BookStateCopy.navigatorChip(finished: true, sealed: false, archived: true)
                == "archived \u{00B7} \u{2713} finished")
        #expect(BookStateCopy.navigatorChip(finished: false, sealed: false, archived: true) == "archived")
        #expect(BookStateCopy.navigatorChip(finished: false, sealed: false) == nil, "unchanged")
        #expect(MembershipChip.label(
            bookNames: [BookArchiveCopy.name(bare("Old", archived: true))], gatheringCount: 0
        ) { "in \($0)" } == "in Old (archived)")
    }

    /// Her second rider: the add picker MARKS, never refuses — the archived
    /// book is offered and named, beside "finished".
    @Test func thePoolsPickerMarksArchivedBooks() async throws {
        var finished = bare("F", archived: true)
        finished.locked = true
        let rows = await NotePickerSource.curatedBooks([bare("A", archived: true), bare("B"), finished])
            .search("")
        #expect(rows.map(\.annotation) == ["archived", nil, "finished \u{00B7} archived"])
    }
}

// MARK: - The comes-back RECEIPT (F-U1-6's ruling)

@MainActor
@Suite("13i-e U2 — the ⌘J road says when the Journal came back", .serialized)
struct ComesBackReceiptTests {
    @Test func theReceiptSpeaksOnlyWhenTheJournalCameBack() async throws {
        try await withArchiveWorld { session, db in
            let first = try await JournalBooks.openToday(session: session, day: "2026-10-01")
            #expect(first.receipt == nil, "a fresh mint is not a return")
            let journal = try #require(try await db.read { try Queries.dailyJournalBookID($0) })
            let again = try await JournalBooks.openToday(session: session, day: "2026-10-02")
            #expect(again.receipt == nil, "an unarchived Journal never came back")

            try session.operations.archiveReading(journal)
            let back = try await JournalBooks.openToday(session: session, day: "2026-10-03")
            #expect(back.receipt == "The Journal is back on the Bookcase.")
            #expect(try await reading(db, journal).archivedAt == nil)
        }
    }

    /// The pure decision: the SAME book, archived before and not after.
    @Test func theDecisionIsTheSameBookComingBack() {
        #expect(JournalBooks.comesBackReceipt(before: ("a", true), after: ("a", false))
                == BookArchiveCopy.journalCameBack)
        #expect(JournalBooks.comesBackReceipt(before: ("a", true), after: ("a", true)) == nil)
        #expect(JournalBooks.comesBackReceipt(before: ("a", true), after: ("b", false)) == nil)
        #expect(JournalBooks.comesBackReceipt(before: ("a", false), after: ("a", false)) == nil)
        #expect(JournalBooks.comesBackReceipt(before: nil, after: ("a", false)) == nil)
    }
}

// MARK: - The wing refusal's "(N archived)" (F-U1-8's copy rider)

@MainActor
@Suite("13i-e U2 — a wing's contents say where archived books are", .serialized)
struct WingContentsArchivedWordsTests {
    @Test func aWingHoldingArchivedBooksSaysSo() async throws {
        try await withArchiveWorld { session, db in
            let ops = session.operations
            let wing = try ops.createWing(name: "Away")
            let kept = try ops.createReading(name: "Kept", kind: .book, wingId: wing.id)
            _ = try ops.createReading(name: "Shown", kind: .book, wingId: wing.id)
            try ops.archiveReading(kept.id)
            let contents = try await db.read { try Queries.wingContents($0, wingID: wing.id) }
            #expect(contents.books == 2 && contents.archivedBooks == 1)
            #expect(WingWords.contents(contents) == "2 books (1 archived)")
            #expect(WingWords.contents(Queries.WingContents(notes: 1, books: 1, gatherings: 0, tags: 0))
                    == "1 book and 1 note", "no archived book, no mark")
        }
    }
}
