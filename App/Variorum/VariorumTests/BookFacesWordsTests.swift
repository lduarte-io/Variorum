//
//  BookFacesWordsTests.swift
//  VariorumTests
//
//  The VX-914 run, batch 3 — the book faces' WORDS: VX-897 (the delete and
//  archive confirms' em dashes become commas, RULED in her chat, Nov 7) and
//  VX-667 (the context bar's book icon speaks kinds — a gathering is never
//  counted as a book) and VX-45 (the copy family: the book-only delete
//  receipt never puts an archived note in the Pool; the empty state speaks a
//  gathering's kind). The record: `notes/plans/fixes/vx-914-walkthrough-
//  followups.md`, BATCH 3.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore

@testable import Variorum

@MainActor
private func withWordsWorld<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 45))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

// MARK: - VX-897

@Suite("VX-897 — the owned book's delete and archive confirms say it with a comma")
struct ConfirmCommaWordsTests {
    /// **The ruled sentence, exactly** (her chat, Nov 7): "…the book goes to
    /// the Trash for 30 days, and Put back returns whatever went in together,
    /// together." — the comma where the em dash stood; the N stays dynamic.
    @Test func theOwnedDeleteConfirmsSecondLineIsTheRuledSentence() {
        let confirm = BookStateCopy.deleteOwnedBook(readingID: "o", name: "Mine", notes: 2)
        #expect(confirm.lines.count == 2)
        #expect(confirm.lines.last
                == "Either way the book goes to the Trash for \(TrashWindow.days) days, and "
                + "Put back returns whatever went in together, together.")
        #expect(confirm.lines.last?.contains("\u{2014}") == false, "no em dash on the ruled line")
        // Outside the ruling, unchanged: the first line keeps its own words.
        #expect(confirm.lines.first
                == "\u{201C}Mine\u{201D} owns its notes. Delete the book only, and its 2 notes go "
                + "back to the Pool \u{2014} or delete the book and its 2 notes together.")
    }

    /// **Its archive twin** (`keptLine`, the owned book's two-choice archive
    /// confirm): the em dash becomes a comma too.
    @Test func theArchiveConfirmsKeptLineSaysItWithAComma() {
        #expect(BookStateCopy.keptLine
                == "Either way it's kept under Archived, with no countdown, and Unarchive brings "
                + "back whatever went in together, together.")
        #expect(!BookStateCopy.keptLine.contains("\u{2014}"))
        let confirm = BookStateCopy.archiveOwnedBook(readingID: "o", name: "Mine", notes: 2)
        #expect(confirm.lines.contains(BookStateCopy.keptLine), "the confirm speaks the kept line")
    }
}

// MARK: - VX-667

@Suite("VX-667 — the book icon's popover and hover speak kinds")
struct AscentKindWordsTests {
    /// **Her case** (a note in one book and one gathering): the popover's
    /// headline was "This note is in 2 books — open one at this note:" while
    /// the chip beside it said "in ‹book› · 1 gathering". It speaks the chip's
    /// headline grammar now — books "in", gatherings "appears in".
    @Test func aNoteInOneBookAndOneGatheringIsNeverTwoBooks() {
        let header = WorkspaceNaming.ascentListHeader(bookCount: 1, gatheringCount: 1)
        #expect(header == "This note is in 1 book and appears in 1 gathering — open one at this note:")
        #expect(!header.contains("2 books"))
        let help = WorkspaceNaming.ascentHelp(topBook: "Essays", bookCount: 1, gatheringCount: 1)
        #expect(help == "This note is in 1 book and appears in 1 gathering — click to pick one")
        #expect(!help.contains("2 books"))
    }

    /// Gatherings alone: "appears in", never "is in … books".
    @Test func gatheringsAloneAppear() {
        #expect(WorkspaceNaming.ascentListHeader(bookCount: 0, gatheringCount: 1)
                == "This note appears in 1 gathering — open it at this note:")
        #expect(WorkspaceNaming.ascentListHeader(bookCount: 0, gatheringCount: 2)
                == "This note appears in 2 gatherings — open one at this note:")
        #expect(WorkspaceNaming.ascentHelp(topBook: "#reading", bookCount: 0, gatheringCount: 2)
                == "This note appears in 2 gatherings — click to pick one")
        // One gathering alone: the one place is named and opened (the count
        // of places decides the click, never the kind).
        #expect(WorkspaceNaming.ascentHelp(topBook: "#reading", bookCount: 0, gatheringCount: 1)
                == "Open \u{201c}#reading\u{201d} at this note (\u{2318}-click to see it listed)")
    }

    /// The plural arms by kind, and the books-only sentences byte-for-byte the
    /// shipped ones.
    @Test func thePluralsFollowEachKindsOwnCount() {
        #expect(WorkspaceNaming.ascentListHeader(bookCount: 2, gatheringCount: 3)
                == "This note is in 2 books and appears in 3 gatherings — open one at this note:")
        #expect(WorkspaceNaming.ascentListHeader(bookCount: 2, gatheringCount: 0)
                == "This note is in 2 books — open one at this note:")
        #expect(WorkspaceNaming.ascentListHeader(bookCount: 1, gatheringCount: 0)
                == "This note is in 1 book — open it at this note:")
    }

    /// The context bar hands the words its places BY KIND (the chip's own
    /// split), never the mixed total — grep form (a popover is not evaluated
    /// by the test host). The click's arity still reads the total: a
    /// gathering is a place she can open.
    @Test func theContextBarCountsByKind() throws {
        let source = try String(
            contentsOf: URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent().deletingLastPathComponent()
                .appending(path: "Variorum/Workspace/ContextBar.swift"),
            encoding: .utf8)
        #expect(source.components(separatedBy: "bookCount: memberBookCount, gatheringCount: gatheringCount")
            .count - 1 == 2, "the help and the headline both read the kinds")
        #expect(source.contains("books.filter { $0.kind == .book }.count"))
        #expect(source.contains("books.filter { $0.kind == .gathering }.count"))
        #expect(!source.contains("count: books.count))"), "no ascent sentence reads the mixed total")
        #expect(source.contains("bookCount: books.count,"), "the click's arity: every place")
    }
}

// MARK: - VX-45

@MainActor
@Suite("VX-45 — the copy family: the book-only receipt and the empty state", .serialized)
struct BookCopyFamilyTests {
    /// An owned book whose notes are `live` + `archived` members, deleted
    /// through the door's FIRST choice (the book only).
    private func deleteBookOnly(
        _ session: AppSession, live: Int, archived: Int
    ) async throws -> String? {
        let ops = session.operations
        let mine = try ops.createReading(name: "Mine", kind: .book)
        try ops.setReadingOwned(mine.id, owned: true)
        for index in 0..<(live + archived) {
            let note = try ops.createPost(title: "n\(index)")
            _ = try ops.addPostToReading(note.id, to: mine.id)
            if index >= live { try ops.archiveContainer(note.id) }
        }
        let doors = BookStateDoors(session: session)
        await doors.open(.deleteBook, readingID: mine.id)
        _ = try #require(doors.pending, "an owned book's delete asks")
        await doors.confirm()   // the first choice: the book only
        return session.status.spoken?.text
    }

    /// **RED ON OLD (the bug — KnownIssues row 102):** the receipt read the
    /// book's member count (archived included) and said every one was "in the
    /// Pool now" — but the Pool lists only UN-archived notes, so of an owned
    /// book holding one archived note it said "its 1 note is in the Pool now."
    /// (false of the store). It says the note stays archived. This pin drives
    /// the door's own act and reads the receipt it spoke — it compiles and
    /// runs on the pre-fix tree, where it is red.
    @Test func anArchivedMemberIsNeverSaidToBeInThePool() async throws {
        try await withWordsWorld { session, _ in
            let spoken = try await deleteBookOnly(session, live: 0, archived: 1)
            #expect(spoken == "Deleted \u{201C}Mine\u{201D} \u{2014} it\u{2019}s in the Trash; its note stays archived.")
            #expect(spoken?.contains("Pool") == false)
        }
    }

    /// Mixed members: honest counts — the Pool's share and the archived share
    /// (RED ON OLD too: the old receipt said "its 3 notes are in the Pool now.").
    @Test func mixedMembersSayBothShares() async throws {
        try await withWordsWorld { session, _ in
            let spoken = try await deleteBookOnly(session, live: 2, archived: 1)
            #expect(spoken == "Deleted \u{201C}Mine\u{201D} \u{2014} it\u{2019}s in the Trash; 2 of its notes "
                    + "are in the Pool now, and 1 stays archived.")
        }
    }

    /// The four forms, pure (PROVISIONAL wording, her bundle) — the
    /// all-unarchived sentence byte-for-byte the shipped one.
    @Test func theReceiptsFormsFollowTheSplit() {
        func say(_ pool: Int, _ archived: Int) -> String {
            BookStateCopy.deletedBookOnly("X", released: .init(unarchived: pool, archived: archived))
        }
        let lead = "Deleted \u{201C}X\u{201D} \u{2014} it\u{2019}s in the Trash; "
        #expect(say(0, 0) == BookStateCopy.deleted("X"))
        #expect(say(1, 0) == lead + "its 1 note is in the Pool now.")
        #expect(say(3, 0) == lead + "its 3 notes are in the Pool now.")
        #expect(say(0, 1) == lead + "its note stays archived.")
        #expect(say(0, 2) == lead + "its 2 notes stay archived.")
        #expect(say(1, 1) == lead + "1 of its notes is in the Pool now, and 1 stays archived.")
        #expect(say(2, 3) == lead + "2 of its notes are in the Pool now, and 3 stay archived.")
    }

    /// The door reads the split from the ACT (`deleteReading`'s own
    /// transaction), never a count read beside it — grep form.
    @Test func theDoorReadsTheSplitFromTheAct() throws {
        let source = try String(
            contentsOf: URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent().deletingLastPathComponent()
                .appending(path: "Variorum/Features/Readings/BookStateDoors.swift"),
            encoding: .utf8)
        #expect(source.contains("let held = try ops.deleteReading(readingID)"))
        #expect(source.contains("BookStateCopy.deletedBookOnly(name, released: held)"))
    }

    /// **The empty state's one home** (VX-45's 13i-e member + the ruled
    /// FOLD-IN): an archived gathering says it is archived and shows nothing;
    /// a live gathering matching nothing says so in its own kind; a book's
    /// line is the shipped one, byte for byte.
    @Test func theEmptyStateSpeaksTheReadingsKind() async throws {
        try await withWordsWorld { session, db in
            let ops = session.operations
            let tag = try ops.createTag(name: "t")
            let gathering = try ops.createReading(
                name: "G", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(tag.id)))
            let book = try ops.createReading(name: "B", kind: .book)
            func reading(_ id: String) async throws -> Reading? {
                try await db.read { try Reading.fetchOne($0, key: id) }
            }
            let liveBook = try await reading(book.id)
            let liveGathering = try await reading(gathering.id)
            #expect(BookEmptyStateCopy.line(for: liveBook) == "This book has no notes yet.")
            #expect(BookEmptyStateCopy.line(for: liveGathering) == "No note matches this gathering yet.")
            try ops.archiveReading(gathering.id)
            try ops.archiveReading(book.id)
            let archivedGathering = try await reading(gathering.id)
            let archivedBook = try await reading(book.id)
            #expect(archivedGathering?.archivedAt != nil && archivedBook?.archivedAt != nil)
            #expect(BookEmptyStateCopy.line(for: archivedGathering)
                    == "This gathering is archived, so it shows nothing until you unarchive it.")
            #expect(BookEmptyStateCopy.line(for: archivedBook)
                    == "This book has no notes yet.", "an archived BOOK still holds its notes")
            #expect(BookEmptyStateCopy.line(for: nil) == BookEmptyStateCopy.book, "not read yet")
        }
    }

    /// The three faces speak the one home and the literal lives nowhere else
    /// (grep form — Outline, Read ▸ Pages, Book).
    @Test func theThreeFacesSpeakTheOneHome() throws {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
            .appending(path: "Variorum/Features/BookView")
        for file in ["BookView.swift", "PagedReadView.swift", "SpreadBookView.swift"] {
            let source = try String(contentsOf: root.appending(path: file), encoding: .utf8)
            #expect(source.contains("Text(BookEmptyStateCopy.line(for: structure.reading))"), "\(file)")
            #expect(!source.contains("\"This book has no notes yet.\""), "\(file): no copy of the literal")
        }
    }
}
