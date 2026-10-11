import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// 13n-b U2 Q9 — THE GRANT IN CONTEXT: the reads behind the faces outside
// Settings ▸ MCP (the Bookcase row's "shared with AI" chip; the note menu's
// line), each answered by the SAME pure rule the server consults per call.

@Suite("13n-b U2 — the grant in context (the chip and the note's line)")
struct MCPGrantInContextTests {
    private func approved(_ ops: Operations, _ name: String) throws -> MCPClient {
        let client = try ops.recordMCPContact(name: name, version: nil)
        try ops.approveMCPClient(client.id, granting: nil)
        return client
    }

    @Test func aBookChipsExactlyWhenAnApprovedClientCanReachIt() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Work")
            let granted = try ops.createReading(name: "granted", kind: .book)
            let inWing = try ops.createReading(name: "in the wing", kind: .book, wingId: wing.id)
            // 13n-c U1 (justified edit, the ritual — R-AIR-1): "never a
            // journal" means THE daily Journal now (the trait book chips like
            // any book — MCPFenceRekeyTests' pin).
            let journal = try ops.createReading(name: "journal", kind: .book, profile: "daily")
            let privateBook = try ops.createReading(name: "mine", kind: .book)
            let plain = try ops.createReading(name: "plain", kind: .book)
            try ops.setBookPrivate(privateBook.id, true)
            #expect(try db.read { try Queries.mcpReachableBookIDs($0) }.isEmpty)

            let pending = try ops.recordMCPContact(name: "stranger", version: nil)
            _ = pending
            let client = try approved(ops, "claude-code")
            _ = try ops.grantMCPAccess(client.id, .init(rung: .read, scopeKind: .book, scopeID: granted.id, duration: .always))
            _ = try ops.grantMCPAccess(client.id, .init(rung: .suggest, scopeKind: .wing, scopeID: wing.id, duration: .always))
            #expect(try db.read { try Queries.mcpReachableBookIDs($0) } == [granted.id, inWing.id],
                    "a book grant and a wing grant chip their books; nothing else")

            try ops.setMCPSwitch(.openBook, on: true)
            #expect(try db.read { try Queries.mcpReachableBookIDs($0) } == [granted.id, inWing.id, plain.id],
                    "the open book reaches every book — never the daily Journal or a Private one")
            _ = journal
            try ops.denyMCPClient(client.id)
            #expect(try db.read { try Queries.mcpReachableBookIDs($0) }.isEmpty,
                    "no approved client, nothing shared — even under the open book")
        }
    }

    @Test func aNotesLineNamesEachApprovedClientAtItsHighestRung() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "shared", kind: .book)
            let note = try ops.createPost(title: "ch 7")
            let entry = try ops.createPost(title: "pages", profile: .journal)
            _ = try ops.addPostToReading(note.id, to: book.id)
            _ = try ops.addPostToReading(entry.id, to: book.id)
            let claude = try approved(ops, "claude-code")
            let local = try approved(ops, "local-llama")
            _ = try ops.grantMCPAccess(claude.id, .init(rung: .suggest, scopeKind: .book, scopeID: book.id, duration: .always))
            _ = try ops.grantMCPAccess(local.id, .init(rung: .read, scopeKind: .note, scopeID: note.id, duration: .always))
            #expect(try db.read { try Queries.mcpNoteSharing($0, noteID: note.id) } == [
                MCPNoteSharing(clientName: "claude-code", rung: .suggest),
                MCPNoteSharing(clientName: "local-llama", rung: .read),
            ])
            #expect(try db.read { try Queries.mcpNoteSharing($0, noteID: entry.id) }.isEmpty,
                    "a journal entry is reached by no standing grant")
            try ops.setNotePrivate(note.id, true)
            #expect(try db.read { try Queries.mcpNoteSharing($0, noteID: note.id) }.isEmpty,
                    "a Private note's line goes quiet at once")
        }
    }
}
