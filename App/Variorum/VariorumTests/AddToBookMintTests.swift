//
//  AddToBookMintTests.swift
//  VariorumTests
//
//  17y B3 item (o) — THE ADD-NOTE-TO-BOOK PICKER: THE SAME CONTROL IDIOM +
//  THE INLINE MINT (her ruling at the question tool, in the 17y row: "the
//  search field doubles as the mint — a 'New book "X"' row mints a plain
//  book in the current wing, adds the note as an ORDINARY membership (the
//  ownership consult and the capacity gate run exactly as on every other add
//  road, never bypassed) and speaks a quiet receipt; deeper setup (rule,
//  shelf, trait) stays in Book Settings").
//
//  The faces (enumerated in the B3 RECORD): the membership chip's Add list
//  (the primary — `SearchPicker`) and the Pool row's Add to Book sheet
//  (`NotePickerSheet`, the same brain's create row). One road behind both:
//  `MembershipDoors.mintAndAdd`.
//
//  The capacity gate, said plainly: a freshly minted PLAIN book has no note
//  cap, so the gate passes by construction — what these pins prove is that
//  the mint's add IS the one membership road (`add` → `addPostToReading`,
//  where the gate and the consult live), shown by the consult's refusal
//  opening the choice exactly as on an existing book.
//
//  A ruled BUILD (no red-on-old owed); the walk captures the face.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withMintWorld<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 23))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@MainActor
@Suite("17y (o) — the add-to-book picker's inline mint", .serialized)
struct AddToBookMintTests {
    private func members(_ db: AppDatabase, _ readingID: String) async throws -> [String] {
        try await db.read { db in
            try String.fetchAll(
                db,
                sql: """
                    SELECT post_id FROM reading_post
                    WHERE reading_id = ? AND deleted_at IS NULL AND status = 'member'
                    """,
                arguments: [readingID])
        }
    }

    private func book(_ db: AppDatabase, named name: String) async throws -> Reading? {
        try await db.read { db in
            try Reading.filter(Column("name") == name && Column("deleted_at") == nil).fetchOne(db)
        }
    }

    /// A free note: a PLAIN book is made and the note joins it as an
    /// ordinary member; the quiet receipt says both.
    @Test func aNewBookIsMadeAndTheNoteJoinsItAsAMember() async throws {
        try await withMintWorld { session, db in
            let note = try session.operations.createPost(title: "an essay")
            let doors = MembershipDoors(session: session)
            let outcome = try await doors.mintAndAdd("  Essays  ", postID: note.id)
            #expect(outcome == .added(book: "Essays"))
            let made = try #require(try await book(db, named: "Essays"))
            #expect(made.kind == .book && !made.owned && made.querySpec == nil,
                    "a PLAIN book — no rule, not owned (deeper setup is Book Settings')")
            #expect(try await members(db, made.id) == [note.id], "an ordinary membership")
            #expect(session.status.spoken?.kind == .receipt)
            #expect(session.status.spoken?.text == AddToBookCopy.made("Essays"))
        }
    }

    /// The consult runs exactly as on every add road: a note another book
    /// OWNS meets the copy-only choice at the new book's door — nothing joins.
    @Test func theOwnershipConsultRunsOnTheMintRoad() async throws {
        try await withMintWorld { session, db in
            let ops = session.operations
            let owner = try ops.createReading(name: "Owner", kind: .book)
            let note = try ops.createPost(title: "claimed")
            _ = try ops.addPostToReading(note.id, to: owner.id)
            _ = try ops.setReadingOwned(owner.id, owned: true)
            let doors = MembershipDoors(session: session)

            let outcome = try await doors.mintAndAdd("Elsewhere", postID: note.id)
            #expect(outcome == .offered(book: "Elsewhere"))
            let made = try #require(try await book(db, named: "Elsewhere"))
            #expect(try await members(db, made.id).isEmpty, "nothing joined — the choice is up")
            #expect(doors.pending?.kind == .copyOnly)
            #expect(doors.pending?.book.id == made.id, "the choice is the NEW book's")
        }
    }

    /// The store-wide name guard every book mint runs (E13): a taken name
    /// refuses and nothing is made.
    @Test func aTakenNameRefusesAndMakesNothing() async throws {
        try await withMintWorld { session, db in
            let ops = session.operations
            _ = try ops.createReading(name: "Essays", kind: .book)
            let note = try ops.createPost(title: "an essay")
            let doors = MembershipDoors(session: session)
            await #expect(throws: OperationError.duplicateBookName(name: "Essays")) {
                _ = try await doors.mintAndAdd("essays", postID: note.id)
            }
            let count = try await db.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM reading WHERE deleted_at IS NULL")
            }
            #expect(count == 1)
        }
    }

    /// The book is born in the NOTE's wing (a book never spans wings).
    @Test func theBookIsBornInTheNotesWing() async throws {
        try await withMintWorld { session, db in
            let ops = session.operations
            let studio = try ops.createWing(name: "Studio")
            let note = try ops.createPost(title: "studio note", wingId: studio.id)
            let doors = MembershipDoors(session: session)
            _ = try await doors.mintAndAdd("Studio Book", postID: note.id)
            let made = try #require(try await book(db, named: "Studio Book"))
            #expect(made.wingId == studio.id)
            #expect(try await members(db, made.id) == [note.id])
        }
    }

    /// The picker's create row: offered for a name no book wears (as the E13
    /// guard reads names), never for one that is already listed.
    @Test func theCreateRowNamesOnlyANewBook() {
        let listed = [SearchPickerOption(id: "1", label: "Essays")]
        #expect(SearchPickerBrain.createOffer(
            query: "essays ", options: listed, key: AddToBookCopy.key(_:)) == nil)
        #expect(SearchPickerBrain.createOffer(
            query: "Letters", options: listed, key: AddToBookCopy.key(_:)) == "Letters")
        #expect(AddToBookCopy.newBook("Letters") == "New book \u{201C}Letters\u{201D}")
    }

    /// Both enumerated faces carry the mint (grep-form: a menu/popover's
    /// content is not evaluated under the test host).
    @Test func bothAddFacesCarryTheMint() throws {
        let appRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
        let chip = try String(
            contentsOf: appRoot.appending(path: "Variorum/Features/BookView/MembershipChip.swift"),
            encoding: .utf8)
        #expect(chip.contains("SearchPicker(") && chip.contains("membershipDoors.mintAndAdd"))
        #expect(!chip.contains("Menu(\"Add to Book\")"), "the flat menu retired")
        let pool = try String(
            contentsOf: appRoot.appending(path: "Variorum/Features/Pool/PoolPostsView.swift"),
            encoding: .utf8)
        #expect(pool.contains("createLabel: AddToBookCopy.newBook") && pool.contains("mintAndAdd"))
    }
}
