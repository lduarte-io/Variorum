import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-184 U5 — VX-196, A BOOK's MEMBERSHIP AND ORDER at EDIT (R-VX184-1, her
// picks): `remove_note_from_book` (her `removePostFromReading` — "Release" on an
// owned book, the bookless return) and `move_note_in_book` (her
// `reorderReadingPost`, gated as her doors gate it: a book that sorts itself
// takes no hand placing). Both TWO-SIDED at edit — the book AND the note (a note
// the client cannot reach is never reorganized, and a Private member's id
// answers the one shape). ONE client-named undo entry each. Written BEFORE the
// fix: on the pre-fix tree both tools answer "Unknown tool".

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String,
    _ duration: MCPGrantRule.Duration = .always
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
}

private func call(
    _ connection: HarnessConnection, _ name: String, _ arguments: [String: Value]
) async throws -> (content: [Tool.Content], isError: Bool?) {
    try await connection.client.callTool(name: name, arguments: arguments)
}

@Suite("VX-196 — a book's membership and order at edit", .serialized)
struct MCPBookMembershipServerTests {
    private func members(_ h: ServerHarness, _ bookID: String) throws -> [String] {
        try h.database.read { db in
            try String.fetchAll(
                db,
                sql: """
                    SELECT post_id FROM reading_post
                    WHERE reading_id = ? AND deleted_at IS NULL AND status = 'member'
                    ORDER BY position, post_id
                    """,
                arguments: [bookID])
        }
    }

    // MARK: - remove_note_from_book

    @Test func removeNoteFromBookIsHerRemoveAndAnOwnedBookReleases() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let other = try h.operations.createReading(name: "letters", kind: .book)
            let note = try h.operations.createPost(title: "ch 1")
            for reading in [book, other] { _ = try h.operations.addPostToReading(note.id, to: reading.id) }
            let row = try #require(try await h.database.read { db in
                try String.fetchOne(
                    db, sql: "SELECT id FROM reading_post WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL",
                    arguments: [book.id, note.id])
            })
            let owned = try h.operations.createReading(name: "the novel", kind: .book)
            let ownedNote = try h.operations.createPost(title: "its own")
            _ = try h.operations.addPostToReading(ownedNote.id, to: owned.id)
            _ = try h.operations.setReadingOwned(owned.id, owned: true)
            let stray = try h.operations.createPost(title: "in no book")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))

            let removed = try await call(connection, "remove_note_from_book", [
                "book_id": .string(book.id), "note_id": .string(note.id),
            ])
            #expect(removed.isError != true, "\(text(removed))")
            let answer = try json(removed)
            #expect(answer["removed"] as? Bool == true && answer["released"] as? Bool == false
                    && answer["bookless"] as? Bool == false, "it lives on in its other book")
            #expect(try members(h, book.id).isEmpty && members(h, other.id) == [note.id])
            #expect(h.undoStack.topLabel == "claude-code's removal from a book")
            #expect(h.receipts.value.last?.act.rawValue == "removal from a book")

            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's removal from a book")
            #expect(try members(h, book.id) == [note.id])
            #expect(try await h.database.read { db in
                try String.fetchOne(
                    db, sql: "SELECT id FROM reading_post WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL",
                    arguments: [book.id, note.id])
            } == row, "the very membership row, back")
            #expect(try h.undoStack.redo(with: h.writeOperations) == "claude-code's removal from a book")
            #expect(try members(h, book.id).isEmpty)

            // An OWNED book: her "Release" — the note goes back to the Pool.
            let released = try await call(connection, "remove_note_from_book", [
                "book_id": .string(owned.id), "note_id": .string(ownedNote.id),
            ])
            #expect(released.isError != true, "\(text(released))")
            #expect(try json(released)["released"] as? Bool == true && json(released)["bookless"] as? Bool == true)
            #expect(h.undoStack.topLabel == "claude-code's release from a book")
            #expect(try await h.database.read { try Container.fetchOne($0, key: ownedNote.id)?.deletedAt } == nil,
                    "the note itself untouched")

            // A note this client reads that is not in the book: said so.
            let notIn = try await call(connection, "remove_note_from_book", [
                "book_id": .string(other.id), "note_id": .string(stray.id),
            ])
            #expect(notIn.isError == true && text(notIn).contains("isn't in"), "\(text(notIn))")

            // A finished book refuses in her words.
            try h.operations.lockReading(other.id)
            let frozen = try await call(connection, "remove_note_from_book", [
                "book_id": .string(other.id), "note_id": .string(note.id),
            ])
            #expect(frozen.isError == true && text(frozen).contains("lockedReading"), "\(text(frozen))")
            #expect(try members(h, other.id) == [note.id])
            await h.hangUp(connection)
        }
    }

    /// The membership oracle closed: a Private MEMBER of a granted book is
    /// unreachable, so naming it answers exactly as an id naming nothing —
    /// never "removed", never "isn't in".
    @Test func aPrivateMemberAnswersTheOneShapeAndStays() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let open = try h.operations.createPost(title: "open")
            let privateNote = try h.operations.createPost(title: "not for anyone")
            for post in [open, privateNote] { _ = try h.operations.addPostToReading(post.id, to: book.id) }
            _ = try h.operations.setNotePrivate(privateNote.id, true)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, book.id))
            let unshared = MCPRefusalCopy.words(.notShared, .note)
            for (tool, arguments): (String, [String: Value]) in [
                ("remove_note_from_book", ["book_id": .string(book.id), "note_id": .string(privateNote.id)]),
                ("remove_note_from_book", ["book_id": .string(book.id), "note_id": .string("no-such-note")]),
                ("move_note_in_book", ["book_id": .string(book.id), "note_id": .string(privateNote.id),
                                       "at": .string("start")]),
                // An anchor the client cannot read is the one shape too.
                ("move_note_in_book", ["book_id": .string(book.id), "note_id": .string(open.id),
                                       "after_note_id": .string(privateNote.id)]),
            ] {
                let refused = try await call(connection, tool, arguments)
                #expect(refused.isError == true && text(refused) == unshared, "\(tool) \(arguments): \(text(refused))")
            }
            #expect(try members(h, book.id).sorted() == [open.id, privateNote.id].sorted())
            #expect(h.undoStack.depth == 0)
            await h.hangUp(connection)
        }
    }

    // MARK: - move_note_in_book

    @Test func moveNoteInBookPlacesByHandOnlyInAHandOrderedBook() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let notes = try (1...3).map { try h.operations.createPost(title: "ch \($0)") }
            for post in notes { _ = try h.operations.addPostToReading(post.id, to: book.id) }
            let (one, two, three) = (notes[0].id, notes[1].id, notes[2].id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, book.id))
            #expect(try members(h, book.id) == [one, two, three])

            let moved = try await call(connection, "move_note_in_book", [
                "book_id": .string(book.id), "note_id": .string(three), "before_note_id": .string(one),
            ])
            #expect(moved.isError != true, "\(text(moved))")
            #expect(try members(h, book.id) == [three, one, two])
            #expect(h.undoStack.topLabel == "claude-code's move in a book")
            #expect(h.receipts.value.last?.act.rawValue == "move in a book")
            _ = try await call(connection, "move_note_in_book", [
                "book_id": .string(book.id), "note_id": .string(one), "at": .string("end"),
            ])
            #expect(try members(h, book.id) == [three, two, one])
            _ = try await call(connection, "move_note_in_book", [
                "book_id": .string(book.id), "note_id": .string(three), "after_note_id": .string(two),
            ])
            #expect(try members(h, book.id) == [two, three, one])

            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's move in a book")
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's move in a book")
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's move in a book")
            #expect(try members(h, book.id) == [one, two, three], "her order, exactly")
            #expect(try h.undoStack.redo(with: h.writeOperations) == "claude-code's move in a book")
            #expect(try members(h, book.id) == [three, one, two])

            // One road at a time, and never next to itself.
            let both = try await call(connection, "move_note_in_book", [
                "book_id": .string(book.id), "note_id": .string(one), "at": .string("end"),
                "before_note_id": .string(two),
            ])
            #expect(both.isError == true)
            let itself = try await call(connection, "move_note_in_book", [
                "book_id": .string(book.id), "note_id": .string(one), "after_note_id": .string(one),
            ])
            #expect(itself.isError == true)

            // A book that sorts itself takes no hand placing (her doors' gate).
            try h.operations.setReadingSort(book.id, field: .entryDate, direction: .asc)
            let sorted = try await call(connection, "move_note_in_book", [
                "book_id": .string(book.id), "note_id": .string(one), "at": .string("start"),
            ])
            #expect(sorted.isError == true && text(sorted).contains("by hand"), "\(text(sorted))")

            // A finished book refuses in her words.
            try h.operations.setReadingSort(book.id, field: .manual, direction: .asc)
            try h.operations.lockReading(book.id)
            let frozen = try await call(connection, "move_note_in_book", [
                "book_id": .string(book.id), "note_id": .string(one), "at": .string("start"),
            ])
            #expect(frozen.isError == true && text(frozen).contains("lockedReading"), "\(text(frozen))")
            #expect(try members(h, book.id) == [three, one, two])
            await h.hangUp(connection)
        }
    }

    // MARK: - The rung; a gathering

    @Test func belowEditTheRungRefusesAndAGatheringHoldsNoMembership() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let note = try h.operations.createPost(title: "ch 1")
            _ = try h.operations.addPostToReading(note.id, to: book.id)
            let percy = try h.operations.createTag(name: "percy")
            _ = try h.operations.applyTag(percy.id, toPost: note.id)
            let gathering = try h.operations.createReading(
                name: "gathered", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(percy.id)))

            let maker = try await h.connect(as: "maker")
            _ = try h.approve("maker", spec(.writeNew, .book, book.id))
            for (tool, arguments): (String, [String: Value]) in [
                ("remove_note_from_book", ["book_id": .string(book.id), "note_id": .string(note.id)]),
                ("move_note_in_book", ["book_id": .string(book.id), "note_id": .string(note.id), "at": .string("end")]),
            ] {
                let refused = try await call(maker, tool, arguments)
                #expect(refused.isError == true
                        && text(refused).hasPrefix("This client may only read, suggest and write new here."),
                        "\(tool): \(text(refused))")
            }
            #expect(h.asks.value.last?.rung == .edit)
            await h.hangUp(maker)

            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            let fromGathering = try await call(connection, "remove_note_from_book", [
                "book_id": .string(gathering.id), "note_id": .string(note.id),
            ])
            #expect(fromGathering.isError == true && text(fromGathering).contains("is a gathering"), "\(text(fromGathering))")
            #expect(text(fromGathering).contains("remove_tag"), "the honest way out is the tag")
            #expect(try members(h, book.id) == [note.id])
            #expect(h.undoStack.depth == 0)
            await h.hangUp(connection)
        }
    }
}
