//
//  GatheringKindWordTests.swift
//  VariorumTests
//
//  VX-611 (the VX-440 run, batch 3) — A GATHERING'S KIND WORD. Confirmed in
//  code at kickoff: every renderer of the ONE delete capability's door on a
//  book ROW (the Bookcase row's menu, `BookRowMenu` — the Library's, the
//  Starred list's and the Archived group's right-click — and the Archived
//  group's own button) drew the registry's verb, "Delete Book…", for a book
//  AND a gathering, while the confirm it opens already said "Delete
//  Gathering"; and the Trash listed a deleted gathering with the kind word
//  "book" (`RecoveryCopy.rowKind` read the `.book` arm's kind), its Delete
//  Now asking "Delete this book for good?" and its receipts saying "Book put
//  back." / "The book is gone…".
//
//  The fix keeps P-1 (one capability, `.deleteBook`; the registry's declared
//  verb stays the book's) and chooses the verb by the reading's kind
//  (`BookStateCopy.deleteDoorLabel`); the Trash's book arm carries the row's
//  own kind (`TrashItem.isGathering`) and the one row rule
//  (`RecoveryCopy.rowKind(_:)`) says "gathering".
//
//  RED ON OLD, stated per pin: the words pins (`theRowsDeleteDoorSaysGathering…`,
//  `theTrashCallsADeletedGathering…`, `aDeletedGatheringsDeleteNow…`,
//  `aPutBackGathering…`) ran on the seam commit — every renderer and the
//  Trash's row already drawing through the functions they pin, the words still
//  the book's — and fail there; the renderer guard is green on both sides by
//  design (it keeps every renderer on the one function).
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore

@testable import Variorum

@MainActor
private func withKindWorld<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 611))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

/// The world's clock, not the wall's (the Trash window is 30 days back from
/// `now`, and this world's stamps start at its `start`).
private let worldNow = Date(timeIntervalSince1970: 1_782_864_000 + 3_600)

@MainActor
@Suite("VX-611 — a gathering's kind word: its row's delete door, and the Trash", .serialized)
struct GatheringKindWordTests {
    // MARK: - The row's delete door (one capability, the verb by kind)

    @Test func theRowsDeleteDoorSaysGatheringOnAGatheringAndBookOnABook() {
        #expect(BookStateCopy.deleteDoorLabel(.gathering) == "Delete Gathering\u{2026}")
        #expect(BookStateCopy.deleteDoorLabel(.book) == "Delete Book\u{2026}")
        #expect(BookStateCopy.deleteVerb(.gathering) == "Delete Gathering",
                "the rule editor's gathering gate hovers its kind's verb")
        // P-1: ONE capability — its declared verb stays the book's, and the
        // confirm the gathering's door opens already said so.
        #expect(CapabilityRegistry.capability(.deleteBook).verb == BookStateCopy.deleteVerb)
        #expect(BookStateCopy.deleteGathering(readingID: "g", name: "x").confirmLabel == "Delete Gathering")
    }

    /// The renderer guard (green on both sides by design): every drawn door of
    /// `.deleteBook` on a ROW reads its words from the one kind function —
    /// never the registry's verb with an ellipsis glued on — so a new renderer
    /// cannot bring the old words back. Read from the renderers' own source (a
    /// context menu cannot be mounted headlessly — the registry walk's
    /// `theLibraryNoteRowMenuRendersItsDeclaredDoors` precedent).
    @Test func everyRowRendererOfTheDeleteDoorChoosesItsWordsByKind() throws {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("Variorum")
        for path in ["Core/Views/BookRowMenu.swift", "Features/Shelf/ShelfView.swift",
                     "Features/Library/ArchivedView.swift"] {
            let source = try String(contentsOf: root.appendingPathComponent(path), encoding: .utf8)
            #expect(source.contains("BookStateCopy.deleteDoorLabel("), "\(path) draws the kind's words")
            #expect(!source.contains("capability(.deleteBook).verb + \"\\u{2026}\""),
                    "\(path) never glues the registry's verb into a row door")
        }
    }

    // MARK: - The Trash

    @Test func theTrashCallsADeletedGatheringAGathering() async throws {
        try await withKindWorld { session, db in
            let ops = session.operations
            let book = try ops.createReading(name: "a book", kind: .book)
            let gathering = try ops.createReading(
                name: "a gathering", kind: .gathering, querySpec: try RuleGrammar.encode(.star))
            try ops.deleteReading(book.id)
            try ops.deleteReading(gathering.id)
            let trash = try await db.read { try Queries.trash($0, now: worldNow) }
            let gatheringRow = try #require(trash.first { $0.id == gathering.id })
            let bookRow = try #require(trash.first { $0.id == book.id })
            #expect(RecoveryCopy.rowKind(gatheringRow) == "gathering")
            #expect(RecoveryCopy.rowKind(bookRow) == "book", "a book keeps its word")
            // The pure rule over a hand-built row (the phone's accessibility
            // labels read the same function).
            let built = Queries.TrashItem(
                kind: .book, id: "g", deletedAt: "", title: "x", isGathering: true)
            #expect(RecoveryCopy.rowKind(built) == "gathering")
            // The kind FILTER stays the readings' (a gathering lists under
            // Books, as before) — only the row's word changes.
            #expect(RecoveryCopy.kindLabel(.book) == "Books")
        }
    }

    @Test func aDeletedGatheringsDeleteNowAsksAndAnswersInItsOwnKind() async throws {
        try await withKindWorld { session, db in
            let ops = session.operations
            let gathering = try ops.createReading(
                name: "a gathering", kind: .gathering, querySpec: try RuleGrammar.encode(.star))
            try ops.deleteReading(gathering.id)
            let model = RecoveryViewModel(session: session)
            model.adopt(archived: [], trash: try await db.read { try Queries.trash($0, now: worldNow) })
            let row = try #require(model.trash.first { $0.id == gathering.id })

            model.requestDeleteNow(row)
            let confirm = try #require(model.pendingConfirm)
            #expect(confirm.message.hasPrefix("Delete this gathering for good?"), "\(confirm.message)")

            await model.confirmPendingPurge(confirm)
            let receipt = try #require(model.receipt)
            #expect(receipt.hasPrefix("The gathering is gone from the app now"), "\(receipt)")
        }
    }

    @Test func aPutBackGatheringSaysGatheringPutBackAndABookStillSaysBook() async throws {
        try await withKindWorld { session, db in
            let ops = session.operations
            let book = try ops.createReading(name: "a book", kind: .book)
            let gathering = try ops.createReading(
                name: "a gathering", kind: .gathering, querySpec: try RuleGrammar.encode(.star))
            try ops.deleteReading(book.id)
            try ops.deleteReading(gathering.id)
            let model = RecoveryViewModel(session: session)
            model.adopt(archived: [], trash: try await db.read { try Queries.trash($0, now: worldNow) })

            let gatheringRow = try #require(model.trash.first { $0.id == gathering.id })
            let bookRow = try #require(model.trash.first { $0.id == book.id })
            await model.putBack(gatheringRow)
            #expect(model.receipt == "Gathering put back.")
            #expect(try await db.read { try Queries.reading($0, id: gathering.id) } != nil,
                    "the act is the reading's own Put back, unchanged — it lives again")

            await model.putBack(bookRow)
            #expect(model.receipt == RecoveryCopy.putBackReceipt(.book), "a book's receipt is unchanged")
        }
    }
}
