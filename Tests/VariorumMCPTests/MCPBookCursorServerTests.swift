import Foundation
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-859 (the VX-808 run, Unit B5 — id-resume, PRE-RULED at QUESTIONS #262; the
// VX-809 ladder's MINOR-1): `list_notes(book_id)`'s cursor resumes after the NOTE
// it names, never a raw fractional position — the gathering cursor's own road.
// The red-on-old pin is the two-store catalog's interleaved-mint arms
// (`MCPTwoStoreCatalogArms.cursorArms`); these pin the road's edges, the ruled
// trade among them (a cursor whose note left the book starts the listing again).

private func spec(_ id: String) -> Operations.MCPGrantSpec {
    .init(rung: .read, scopeKind: .book, scopeID: id, duration: .always)
}

private func cursor(_ key: String, _ id: String) -> String {
    Data("b\n\(key)\n\(id)".utf8).base64EncodedString()
}

private func decoded(_ cursor: String?) -> [String] {
    guard let cursor, let data = Data(base64Encoded: cursor) else { return [] }
    return String(decoding: data, as: UTF8.self).components(separatedBy: "\n")
}

private func page(
    _ connection: HarnessConnection, _ bookID: String, limit: Int, after: String? = nil
) async throws -> (ids: [String], next: String?, text: String, isError: Bool) {
    var arguments: [String: Value] = ["book_id": .string(bookID), "limit": .int(limit)]
    if let after { arguments["cursor"] = .string(after) }
    let result = try await connection.client.callTool(name: "list_notes", arguments: arguments)
    let said = text(result)
    guard result.isError != true else { return ([], nil, said, true) }
    let object = try json(result)
    let ids = (object["notes"] as? [[String: Any]] ?? []).compactMap { $0["id"] as? String }
    return (ids, object["next_cursor"] as? String, said, false)
}

@Suite("VX-859 — the book cursor resumes by the note it names", .serialized)
struct MCPBookCursorServerTests {
    /// Pages tile the book in its order, and no cursor carries a stored
    /// position: its key is the readable ordinal of the note it names.
    @Test func pagesTileTheBookAndNoCursorCarriesAPosition() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "Book", kind: .book)
            var members: [String] = []
            for index in 0..<5 {
                let note = try h.operations.createPost(title: "n\(index)")
                _ = try h.operations.addPostToReading(note.id, to: book.id)
                members.append(note.id)
            }
            let positions = Set(try await h.database.read { db in
                try String.fetchAll(db, sql: "SELECT position FROM reading_post WHERE reading_id = ?", arguments: [book.id])
            })
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(book.id))

            var seen: [String] = []
            var keys: [String] = []
            var next: String?
            for _ in 0..<10 {
                let answer = try await page(connection, book.id, limit: 2, after: next)
                #expect(!answer.isError, "\(answer.text)")
                seen += answer.ids
                guard let resume = answer.next else { break }
                let parts = decoded(resume)
                let last = answer.ids.last
                #expect(parts.count == 3 && parts[0] == "b" && parts[2] == last, "\(parts)")
                keys.append(parts.count == 3 ? parts[1] : "")
                next = resume
            }
            #expect(seen == members, "the book's order, every member once")
            #expect(keys == ["1", "3"], "the readable ordinal of the last note listed: \(keys)")
            #expect(positions.isDisjoint(with: keys), "no stored position crosses the wire")
            await h.hangUp(connection)
        }
    }

    /// THE RULED TRADE (her #262 pick — id-resume over position-resume): a
    /// cursor whose note has since left the book answers the stale sentence,
    /// and the listing starts again.
    @Test func aCursorWhoseNoteLeftTheBookStartsTheListingAgain() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "Book", kind: .book)
            var members: [String] = []
            for index in 0..<3 {
                let note = try h.operations.createPost(title: "n\(index)")
                _ = try h.operations.addPostToReading(note.id, to: book.id)
                members.append(note.id)
            }
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(book.id))
            let first = try await page(connection, book.id, limit: 1)
            #expect(first.ids == [members[0]])
            _ = try h.operations.removePostFromReading(members[0], from: book.id)
            let resumed = try await page(connection, book.id, limit: 1, after: first.next)
            #expect(resumed.isError && resumed.text == MCPReadTools.staleCursorMessage, "\(resumed.text)")
            let again = try await page(connection, book.id, limit: 5)
            #expect(again.ids == [members[1], members[2]], "the listing starts again")
            await h.hangUp(connection)
        }
    }

    /// A cursor naming a member the client can't read (a Private note) answers
    /// byte-identically to one naming no note at all — the stale sentence; a
    /// cursor can never tell a hidden member from a missing id (R-825).
    @Test func aCursorNamingAHiddenMemberAnswersAsOneNamingNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "Book", kind: .book)
            let open = try h.operations.createPost(title: "open")
            _ = try h.operations.addPostToReading(open.id, to: book.id)
            let hidden = try h.operations.createPost(title: "hidden")
            _ = try h.operations.setNotePrivate(hidden.id, true)
            _ = try h.operations.addPostToReading(hidden.id, to: book.id)
            let later = try h.operations.createPost(title: "later")
            _ = try h.operations.addPostToReading(later.id, to: book.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(book.id))
            let onHidden = try await page(connection, book.id, limit: 1, after: cursor("0", hidden.id))
            let onNothing = try await page(
                connection, book.id, limit: 1, after: cursor("0", "00000000-0000-0000-0000-00000000FFFF"))
            #expect(onHidden.isError && onNothing.isError)
            #expect(onHidden.text == onNothing.text && onHidden.text == MCPReadTools.staleCursorMessage)
            await h.hangUp(connection)
        }
    }

    /// A cursor minted before this build (its key a stored position) still
    /// resumes — after the note it names — exactly as today's cursor does.
    @Test func aCursorMintedBeforeThisBuildStillResumesByItsNote() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "Book", kind: .book)
            var members: [String] = []
            for index in 0..<3 {
                let note = try h.operations.createPost(title: "n\(index)")
                _ = try h.operations.addPostToReading(note.id, to: book.id)
                members.append(note.id)
            }
            let firstID = members[0]
            let position = try #require(try await h.database.read { db in
                try String.fetchOne(
                    db, sql: "SELECT position FROM reading_post WHERE reading_id = ? AND post_id = ?",
                    arguments: [book.id, firstID])
            })
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(book.id))
            let old = try await page(connection, book.id, limit: 5, after: cursor(position, members[0]))
            let new = try await page(connection, book.id, limit: 5, after: try await page(connection, book.id, limit: 1).next)
            #expect(!old.isError && old.ids == [members[1], members[2]], "\(old.text)")
            #expect(old.ids == new.ids, "the same resume, whichever key it carried")
            await h.hangUp(connection)
        }
    }
}
