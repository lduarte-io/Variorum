import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-184 U5 — VX-196: EVERY library-parity tool spends a ONCE edit grant inside
// its own transaction (the guard — AF-10 (a)): one act lands, the next act on
// that place is refused, and a refused act spends nothing. The snapshot never
// spends (`spendsAfter: false`), so the ONLY road a once grant is spent by is
// the in-transaction guard each tool hands its op — a tool whose guard went
// missing would leave the grant standing (the mutation check in the record).

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String,
    _ duration: MCPGrantRule.Duration = .always
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
}

/// VX-184 ladder round 1 (the `hersAlone` overclaim): every wire call in this
/// suite expects the hers-alone columns byte-identical across it.
private func call(
    _ h: ServerHarness, _ connection: HarnessConnection, _ name: String, _ arguments: [String: Value],
    sourceLocation: SourceLocation = #_sourceLocation
) async throws -> (content: [Tool.Content], isError: Bool?) {
    try await callKeepingHersAlone(h, connection, name, arguments, sourceLocation: sourceLocation)
}

@Suite("VX-196 — every library-parity tool spends a once grant inside its act", .serialized)
struct MCPLibraryOnceServerTests {
    /// One book holding something for every tool to act on.
    private struct World {
        let book: Reading
        let first: String
        let second: String
        let chapter: String
        let otherChapter: String
    }

    /// The once grant's own row: stamped consumed?
    private func spent(_ h: ServerHarness, _ grantID: String) throws -> Bool {
        try h.database.read { db in
            try String.fetchOne(db, sql: "SELECT consumed_at FROM mcp_grant WHERE id = ?", arguments: [grantID]) != nil
        }
    }

    private func world(_ h: ServerHarness, _ name: String) throws -> World {
        let book = try h.operations.createReading(name: name, kind: .book)
        let first = try h.operations.createPost(title: "\(name) one")
        let second = try h.operations.createPost(title: "\(name) two")
        for post in [first, second] { _ = try h.operations.addPostToReading(post.id, to: book.id) }
        let chapter = try h.operations.createSection(in: book.id, name: "a")
        let otherChapter = try h.operations.createSection(in: book.id, name: "b")
        return World(book: book, first: first.id, second: second.id, chapter: chapter.id,
                     otherChapter: otherChapter.id)
    }

    @Test func eachBookToolSpendsAOnceBookEditGrantByItsOneActAndNoMore() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", nil)
            let clientID = try h.client("claude-code").id
            let acts: [(String, (World) -> [String: Value])] = [
                ("rename_book", { ["book_id": .string($0.book.id), "name": .string("\($0.book.name), renamed")] }),
                ("finish_book", { ["book_id": .string($0.book.id)] }),
                ("reopen_book", { ["book_id": .string($0.book.id)] }),  // finished first, below
                ("archive_book", { ["book_id": .string($0.book.id)] }),
                ("unarchive_book", { ["book_id": .string($0.book.id)] }),  // archived first, below
                ("delete_book", { ["book_id": .string($0.book.id)] }),
                ("remove_note_from_book", { ["book_id": .string($0.book.id), "note_id": .string($0.first)] }),
                ("move_note_in_book", { ["book_id": .string($0.book.id), "note_id": .string($0.second),
                                         "at": .string("start")] }),
                ("rename_chapter", { ["section_id": .string($0.chapter), "name": .string("renamed")] }),
                ("delete_chapter", { ["section_id": .string($0.chapter)] }),
                ("move_chapter", { ["section_id": .string($0.otherChapter), "at": .string("start")] }),
            ]
            for (index, (tool, arguments)) in acts.enumerated() {
                let w = try world(h, "book \(index)")
                if tool == "reopen_book" { try h.operations.lockReading(w.book.id) }
                if tool == "unarchive_book" { try h.operations.archiveReading(w.book.id) }
                let grantID = try h.operations.grantMCPAccess(clientID, spec(.edit, .book, w.book.id, .once))
                let first = try await call(h, connection, tool, arguments(w))
                #expect(first.isError != true, "\(tool) lands on its once grant: \(text(first))")
                #expect(try spent(h, grantID), "\(tool) spent its once grant in its own act")
                // The probe: a second edit act on that book (a deleted book is
                // the one answer either way; its probe is the chapter's book).
                let second = try await call(h, connection, "rename_chapter", [
                    "section_id": .string(w.otherChapter), "name": .string("after \(tool)"),
                ])
                #expect(second.isError == true, "\(tool) spent the once grant — one write means one write")
                let name = try await h.database.read { db in
                    try String.fetchOne(db, sql: "SELECT name FROM reading_section WHERE id = ?", arguments: [w.otherChapter])
                }
                #expect(name == "b", "\(tool): nothing landed past the spent grant")
            }
            await h.hangUp(connection)
        }
    }

    @Test func eachNoteToolSpendsAOnceNoteEditGrantByItsOneActAndNoMore() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", nil)
            let clientID = try h.client("claude-code").id
            for tool in ["archive_note", "unarchive_note", "delete_note"] {
                let target = try h.operations.createPost(title: "a note for \(tool)")
                if tool == "unarchive_note" { try h.operations.archiveContainer(target.id) }
                let grantID = try h.operations.grantMCPAccess(clientID, spec(.edit, .note, target.id, .once))
                let first = try await call(h, connection, tool, ["note_id": .string(target.id)])
                #expect(first.isError != true, "\(tool) lands on its once grant: \(text(first))")
                #expect(try spent(h, grantID), "\(tool) spent its once grant in its own act")
                let second = try await call(h, connection, "rename_note", [
                    "note_id": .string(target.id), "title": .string("after \(tool)"),
                ])
                #expect(second.isError == true, "\(tool) spent the once grant — one write means one write")
                let title = try await h.database.read { db in
                    try String.fetchOne(db, sql: "SELECT title FROM container WHERE id = ?", arguments: [target.id])
                }
                #expect(title == "a note for \(tool)", "\(tool): nothing landed past the spent grant")
            }
            await h.hangUp(connection)
        }
    }

    /// A refused act spends nothing — the act's transaction rolls its stamp
    /// back (one representative refusal per family).
    @Test func aRefusedActSpendsNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", nil)
            let clientID = try h.client("claude-code").id
            _ = try h.operations.createReading(name: "taken", kind: .book)
            let refusals: [(String, (World) -> [String: Value])] = [
                ("rename_book", { ["book_id": .string($0.book.id), "name": .string("taken")] }),  // E13
                ("reopen_book", { ["book_id": .string($0.book.id)] }),  // sealed, below
                ("move_note_in_book", { ["book_id": .string($0.book.id), "note_id": .string($0.second),
                                         "at": .string("start")] }),  // sorted by date, below
            ]
            for (index, (tool, arguments)) in refusals.enumerated() {
                let w = try world(h, "refusal \(index)")
                if tool == "reopen_book" { _ = try h.operations.sealReading(w.book.id) }
                if tool == "move_note_in_book" {
                    try h.operations.setReadingSort(w.book.id, field: .entryDate, direction: .asc)
                }
                let grantID = try h.operations.grantMCPAccess(clientID, spec(.edit, .book, w.book.id, .once))
                let refused = try await call(h, connection, tool, arguments(w))
                #expect(refused.isError == true, "\(tool) refuses: \(text(refused))")
                #expect(try !spent(h, grantID), "\(tool) refused — its stamp rolled back")
                let then = try await call(h, connection, "rename_chapter", [
                    "section_id": .string(w.otherChapter), "name": .string("after a refused \(tool)"),
                ])
                #expect(then.isError != true, "a refused \(tool) spent nothing: \(text(then))")
            }
            await h.hangUp(connection)
        }
    }
}
