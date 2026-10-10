import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// 13n-b U3 R5 — WHAT THE READ RUNG CARRIES NOW, end to end: commits by
// explicit ask on read_note's structured view (R-13nb-7, AF-10 (d) — never
// ambient, never the Level 0 text), commits in search behind the explicit
// parameter (R-13nb-10 — the `+ commits` facet's wire form), and chapters on
// the listings and the wire document (R-13nb-11 G-1; AF-10 (f) — only books
// the client may read).

private func readGrant(_ kind: MCPGrantRule.ScopeKind, _ id: String) -> Operations.MCPGrantSpec {
    .init(rung: .read, scopeKind: kind, scopeID: id, duration: .always)
}

private func call(
    _ connection: (client: Client, fd: Int32), _ name: String, _ arguments: [String: Value]
) async throws -> (content: [Tool.Content], isError: Bool?) {
    try await connection.client.callTool(name: name, arguments: arguments)
}

@Suite("13n-b U3 — the read rung's carriage: commits, commit search, chapters", .serialized)
struct MCPReadCarriageTests {
    @Test func withCommitsCarriesEachTakesCommitsNewestFirstBoundedAndFetchableByID() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let note = try h.operations.createPost(title: "ch 1")
            _ = try h.operations.addPostToReading(note.id, to: book.id)
            let other = try h.operations.createPost(title: "elsewhere")
            let seeded = try h.operations.newBlock(in: note.id, text: "first draft", registeringUndo: false)
            let first = try h.operations.commit(seeded.variant.id, message: "the first draft")
            let huge = String(repeating: "x", count: MCPNoteStructure.commitTextBudget + 1)
            try h.operations.autosave(seeded.variant.id, text: huge, charDelta: huge.count)
            let big = try h.operations.commit(seeded.variant.id)
            try h.operations.autosave(seeded.variant.id, text: "second draft", charDelta: 5)
            let newest = try h.operations.commit(seeded.variant.id, message: "tightened")
            let foreign = try h.operations.newBlock(in: other.id, text: "theirs", registeringUndo: false)
            let foreignCommit = try h.operations.commit(foreign.variant.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", readGrant(.book, book.id))

            let plain = text(try await call(connection, "read_note", ["note_id": .string(note.id)]))
            #expect(!plain.contains("tightened") && !plain.contains("the first draft"),
                    "never in the Level 0 text (R-13n-8)")
            let ids = try json(try await call(connection, "read_note", ["note_id": .string(note.id), "with_ids": .bool(true)]))
            let idTake = try #require(((ids["blocks"] as? [[String: Any]])?.first?["takes"] as? [[String: Any]])?.first)
            #expect(idTake["commits"] == nil, "never ambient — asked by name only")

            let shaped = try json(try await call(connection, "read_note", [
                "note_id": .string(note.id), "with_commits": .bool(true),
            ]))
            let take = try #require(((shaped["blocks"] as? [[String: Any]])?.first?["takes"] as? [[String: Any]])?.first)
            let commits = try #require(take["commits"] as? [[String: Any]])
            #expect(commits.map { $0["commit_id"] as? String } == [newest.id, big.id, first.id], "newest first")
            #expect(commits[0]["text"] as? String == "second draft" && commits[0]["message"] as? String == "tightened")
            #expect(commits[0]["kind"] as? String == "manual")
            #expect(commits[1]["text_omitted"] as? Bool == true, "past the budget a text is omitted, never truncated")
            #expect(commits[1]["length"] as? Int == huge.count)
            #expect(commits[2]["text_omitted"] as? Bool == true, "texts ride newest-first: older ones wait too")

            let fetched = try json(try await call(connection, "read_note", [
                "note_id": .string(note.id), "commit_ids": .array([.string(big.id), .string(first.id)]),
            ]))
            let fetchedCommits = try #require(((fetched["blocks"] as? [[String: Any]])?.first?["takes"] as? [[String: Any]])?
                .first?["commits"] as? [[String: Any]])
            #expect(fetchedCommits.first { $0["commit_id"] as? String == big.id }?["text"] as? String == huge,
                    "fetched by id, the whole text rides")
            #expect(fetchedCommits.first { $0["commit_id"] as? String == first.id }?["text"] as? String == "first draft")

            let stranger = try await call(connection, "read_note", [
                "note_id": .string(note.id), "commit_ids": .array([.string(foreignCommit.id)]),
            ])
            #expect(stranger.isError == true && text(stranger).contains("isn't a commit of this note"))
            #expect(!text(stranger).contains("theirs"))
            let refused = try await call(connection, "read_note", [
                "note_id": .string(other.id), "with_commits": .bool(true),
            ])
            #expect(refused.isError == true && text(refused).hasPrefix("That note isn't shared"),
                    "the same decision as the text form")
            await h.hangUp(connection)
        }
    }

    @Test func searchReachesCommitsOnlyWhenAskedAndOnlyInsideTheGrant() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let note = try h.operations.createPost(title: "ch 1")
            _ = try h.operations.addPostToReading(note.id, to: book.id)
            let seeded = try h.operations.newBlock(in: note.id, text: "the lighthouse at dawn", registeringUndo: false)
            let saved = try h.operations.commit(seeded.variant.id)
            try h.operations.autosave(seeded.variant.id, text: "the harbour at dawn", charDelta: 9)
            let outside = try h.operations.createPost(title: "not shared")
            let theirs = try h.operations.newBlock(in: outside.id, text: "a lighthouse elsewhere", registeringUndo: false)
            _ = try h.operations.commit(theirs.variant.id)
            try h.operations.autosave(theirs.variant.id, text: "gone now", charDelta: 9)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", readGrant(.book, book.id))

            let without = try json(try await call(connection, "search", ["query": .string("lighthouse")]))
            #expect((without["passages"] as? [Any])?.isEmpty == true, "a savepoint never lists without the facet")
            let with = try json(try await call(connection, "search", [
                "query": .string("lighthouse"), "include_commits": .bool(true),
            ]))
            let passages = try #require(with["passages"] as? [[String: Any]])
            #expect(passages.count == 1, "only the shared note's commit: \(passages)")
            #expect(passages.first?["kind"] as? String == "savepoint")
            #expect(passages.first?["commit_id"] as? String == saved.id)
            #expect(passages.first?["note_id"] as? String == note.id)
            #expect(passages.first?["saved_at"] is String)
            await h.hangUp(connection)
        }
    }

    @Test func chaptersRideTheListingAndTheWireDocumentForReadableBooksOnly() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "lessons", kind: .book)
            let unshared = try h.operations.createReading(name: "her private shelf of drafts", kind: .book)
            let chapter = try h.operations.createSection(in: book.id, name: "week 1")
            let filed = try h.operations.createPost(title: "lesson 1", entryDate: "2019-03-04")
            let loose = try h.operations.createPost(title: "lesson 2")
            for post in [filed, loose] { _ = try h.operations.addPostToReading(post.id, to: book.id) }
            _ = try h.operations.addPostToReading(filed.id, to: unshared.id)
            try h.operations.assignPostToSection(filed.id, in: book.id, section: chapter.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", readGrant(.book, book.id))

            let listed = try json(try await call(connection, "list_notes", ["book_id": .string(book.id)]))
            let rows = try #require(listed["notes"] as? [[String: Any]])
            let filedRow = try #require(rows.first { $0["id"] as? String == filed.id })
            #expect(filedRow["section_id"] as? String == chapter.id && filedRow["section_name"] as? String == "week 1")
            #expect(rows.first { $0["id"] as? String == loose.id }?["section_id"] == nil, "unfiled says nothing")

            let shaped = try json(try await call(connection, "read_note", [
                "note_id": .string(filed.id), "with_ids": .bool(true),
            ]))
            let books = try #require(shaped["books"] as? [[String: Any]])
            #expect(books.map { $0["book_id"] as? String } == [book.id],
                    "a book the grant does not reach keeps its name (AF-10 (f))")
            #expect(books.first?["section_name"] as? String == "week 1")
            #expect(shaped["entry_date"] as? String == "2019-03-04")
            #expect(!text(try await call(connection, "read_note", ["note_id": .string(filed.id), "with_ids": .bool(true)]))
                    .contains("her private shelf"))

            try h.operations.deleteSection(chapter.id)
            let dangling = try json(try await call(connection, "list_notes", ["book_id": .string(book.id)]))
            #expect((dangling["notes"] as? [[String: Any]])?.first { $0["id"] as? String == filed.id }?["section_id"] == nil,
                    "a dangling chapter pointer reads unsectioned (the app's own rule)")
            await h.hangUp(connection)
        }
    }
}
