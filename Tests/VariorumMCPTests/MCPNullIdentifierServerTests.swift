import Darwin
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-396 (the VX-912 run, batch B4; born at VX-348 U1 — VX-357's identity
// finding): GRDB binds TEXT with length -1, so SQLite reads a bound string only
// up to its first NUL while Swift compares the whole string. VX-357 strips
// U+0000 from PROSE (ruled); an IDENTIFIER holding one used to bind as its
// prefix: a `clientInfo.name` read and wrote the row of the name before the NUL
// (logged under it, minted a waiting setup on it, even minted a client named
// ''), and an id argument or a cursor's id resolved to its prefix's row — each
// road watched on the pre-fix tree (the record's B4 trace): a block id + NUL
// landed a take on the prefix's block; a book id + NUL listed that book; a note
// id + NUL (resolved through `json_each`, which keeps the NUL) was refused but
// LOGGED with the prefix's id as its target; a recency or note-page cursor
// resumed as its prefix. The door now refuses each at its identifier parse — at
// naming, at the call door, at the cursor's own parse — in one sentence, with
// nothing read, written, asked, spent or logged. Every pin here drives the real socket and uses pre-fix
// API only (the new sentences are literals), so it compiles on the pre-fix tree,
// where each red pin was watched failing.

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String,
    _ duration: MCPGrantRule.Duration = .always
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
}

/// The naming seam's sentence (PROVISIONAL — the record's P-912-B4 bundle).
private let nameWords = "Variorum refused this connection: its client name holds a null character (U+0000), which "
    + "a client name can't carry. Reconnect under a name without one."

/// The call door's sentence for ONE argument (PROVISIONAL).
private func idWords(_ path: String) -> String {
    "\(path) holds a null character (U+0000), which no Variorum id carries, so nothing was done \u{2014} send "
        + "each id exactly as an answer gave it."
}

/// A name or id as the WIRE carries it: the JSON escape `rawOpen` interpolates.
private let jsonNull = "\\u0000"

private struct Counts: Equatable {
    var activity = 0, clients = 0, waits = 0, unclaimedKeys = 0, grants = 0
}

private func counts(_ h: ServerHarness) throws -> Counts {
    try h.database.read { db in
        func count(_ table: String) throws -> Int { try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM \(table)") ?? 0 }
        return Counts(
            activity: try count("mcp_activity"), clients: try count("mcp_client"),
            waits: try count("mcp_rebind_request"), unclaimedKeys: try count("mcp_setup_key"),
            grants: try count("mcp_grant"))
    }
}

private func message(_ answer: [String: Any]) -> String? {
    (answer["error"] as? [String: Any])?["message"] as? String
}

/// Read until the server closes (or the harness's receive timeout passes).
private func drain(_ fd: Int32) async {
    await HarnessWait.offPool {   // VX-850: off the pool — the server that closes it runs on the pool
        var buffer = [UInt8](repeating: 0, count: 4096)
        while read(fd, &buffer, buffer.count) > 0 {}
    }
}

/// `claude-code` approved and bound to its own key, its connection closed.
private func approvedClaudeCode(_ h: ServerHarness, _ grant: Operations.MCPGrantSpec? = nil) async throws {
    let connection = try await h.connect(as: "claude-code")
    _ = try h.approve("claude-code", grant)
    await h.hangUp(connection)
    #expect(try await h.eventually { h.host.connectedClientNames.isEmpty })
}

@Suite("VX-396 — a NUL in a client name or an id refuses at the door's identifier parse", .serialized)
struct MCPNullIdentifierServerTests {
    // MARK: - At naming (the connection's clientInfo.name)

    /// RED ON OLD: a bare shim naming `claude-code` + NUL + `x` — the admission
    /// read `claude-code`'s row and logged the refusal under HER client's name.
    /// Now: one sentence on the frame's own id, nothing logged.
    @Test func aBareNameHoldingANullUnderAnApprovedNameLogsNothingUnderIt() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            try await approvedClaudeCode(h)
            let before = try counts(h)
            let (fd, answer) = try await h.rawOpen(as: "claude-code\(jsonNull)x", presenting: nil, id: 3)
            await drain(fd)
            close(fd)
            #expect(answer["id"] as? Int == 3 && message(answer) == nameWords, "\(answer)")
            #expect(try counts(h) == before, "nothing read into, written or logged under the prefix")
            // The real client is untouched: its own key still connects.
            let (realFD, real) = try await h.rawOpen(as: "claude-code", presenting: try h.setupKey(for: "claude-code"), id: 4)
            close(realFD)
            #expect(real["id"] as? Int == 4 && real["result"] != nil, "\(real)")
        }
    }

    /// RED ON OLD: an unclaimed "Any MCP client" key under `claude-code` + NUL —
    /// the admission found HER client's row by the prefix and minted a waiting
    /// setup on it ("New setup for claude-code", her Allow binding the
    /// stranger's key). Now nothing waits and the key stays unclaimed.
    @Test func aFreshKeyUnderANullBearingNameMintsNoWaitingSetup() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            try await approvedClaudeCode(h)
            let fresh = try h.operations.mintMCPSetupKey()
            let before = try counts(h)
            let (fd, answer) = try await h.rawOpen(as: "claude-code\(jsonNull)x", presenting: fresh, id: 5)
            await drain(fd)
            close(fd)
            #expect(message(answer) == nameWords, "\(answer)")
            #expect(try counts(h) == before, "no waiting setup, the key unclaimed, nothing logged")
        }
    }

    /// RED ON OLD: a name of nothing but U+0000 passed Swift's empty-name
    /// check and minted a client row whose stored name is ''.
    @Test func aNameOfOnlyANullMintsNoClient() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let fresh = try h.operations.mintMCPSetupKey()
            let before = try counts(h)
            let (fd, answer) = try await h.rawOpen(as: jsonNull, presenting: fresh, id: 6)
            await drain(fd)
            close(fd)
            #expect(message(answer) == nameWords, "\(answer)")
            #expect(try counts(h) == before, "no client row named '' (or anything)")
        }
    }

    /// RED ON OLD: while the library is LOCKED the old door HELD such a
    /// connection (its `initialize` answered) and ran its admission at the
    /// unlock — writing under the prefix then. Now it is refused at once (a
    /// parse of its own bytes; no store is touched) and the unlock finds nothing.
    @Test func aNullBearingNameWhileLockedIsRefusedAtOnceAndNothingLandsAtTheUnlock() async throws {
        let h = try ServerHarness(lockable: true)
        defer { h.tearDown() }
        try await approvedClaudeCode(h)
        let before = try counts(h)
        #expect(h.host.suspend())
        try h.lockStore()
        let (fd, answer) = try await h.rawOpen(as: "claude-code\(jsonNull)x", presenting: nil, id: 7)
        #expect(message(answer) == nameWords, "refused at once, never held: \(answer)")
        try h.unlockStore()
        #expect(await h.host.resume(executor: SeededExecutor(operations: h.writeOperations)) == .resumed)
        await drain(fd)
        close(fd)
        #expect(try counts(h) == before, "nothing landed at the unlock")
    }

    // MARK: - At the call door (every identifier argument)

    /// RED ON OLD: `list_notes` with a book id + NUL + junk LISTED the book
    /// the prefix names (logged as allowed on it); `read_note` with a note id +
    /// NUL was refused not-shared but LOGGED a refusal targeting the prefix's
    /// note. Now: one sentence naming the argument; nothing read or logged.
    @Test func anIdArgumentHoldingANullRefusesTheCallAndNothingIsReadOrLogged() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "Harbour book", kind: .book)
            let note = try h.operations.createPost(title: "the harbour")
            _ = try h.operations.newBlock(in: note.id, text: "Gulls over the harbour.", registeringUndo: false)
            _ = try h.operations.addPostToReading(note.id, to: book.id)
            try await approvedClaudeCode(h, spec(.edit, .wing, ""))
            let connection = try await h.connect(as: "claude-code")
            let before = try counts(h)
            let listed = try await connection.client.callTool(
                name: "list_notes", arguments: ["book_id": .string(book.id + "\u{0}junk")])
            #expect(listed.isError == true && text(listed) == idWords("book_id"), "\(text(listed))")
            let read = try await connection.client.callTool(
                name: "read_note", arguments: ["note_id": .string(note.id + "\u{0}junk")])
            #expect(read.isError == true && text(read) == idWords("note_id"), "\(text(read))")
            #expect(try counts(h) == before, "nothing logged — on the old road, two rows targeting the prefixes")
            await h.hangUp(connection)
        }
    }

    /// RED ON OLD — the wrong WRITE: `add_take` with a block id + NUL + junk
    /// LANDED a take on the block the prefix names (its answer echoing the
    /// NUL-bearing id); `rename_note` with a note id + NUL was refused but
    /// logged against the prefix's note. Now nothing is written — no take, no
    /// rename, no undo entry, no receipt, no log line.
    @Test func aWriteNamingANullBearingIdWritesNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "the harbour")
            let block = try h.operations.newBlock(in: note.id, text: "Gulls.", registeringUndo: false)
            try await approvedClaudeCode(h, spec(.edit, .wing, ""))
            let connection = try await h.connect(as: "claude-code")
            let before = try counts(h)
            let added = try await connection.client.callTool(
                name: "add_take",
                arguments: ["block_id": .string(block.block.id + "\u{0}junk"), "text": .string("A stranger's take.")])
            #expect(added.isError == true && text(added) == idWords("block_id"), "\(text(added))")
            let renamed = try await connection.client.callTool(
                name: "rename_note", arguments: ["note_id": .string(note.id + "\u{0}junk"), "title": .string("renamed")])
            #expect(renamed.isError == true && text(renamed) == idWords("note_id"), "\(text(renamed))")
            let (takes, title) = try await h.database.read { db in
                (try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM variant WHERE block_id = ?", arguments: [block.block.id]) ?? 0,
                 try String.fetchOne(db, sql: "SELECT title FROM container WHERE id = ?", arguments: [note.id]))
            }
            #expect(takes == 1 && title == "the harbour", "the rows the prefixes name are untouched: \(takes) takes")
            #expect(h.undoStack.depth == 0 && h.receipts.value.isEmpty && h.asks.value.isEmpty)
            #expect(try counts(h) == before)
            await h.hangUp(connection)
        }
    }

    /// RED ON OLD: an id NESTED in an argument (`takes[0].block_id`) and one in
    /// a LIST (`note_ids[1]`) — the old door refused the first in other words
    /// and, for the list, tagged the clean item and LOGGED the NUL item's
    /// refusal against its prefix. Each call is now refused WHOLE at the parse
    /// (the VX-606 class — a malformed call does nothing), naming the argument
    /// by its path.
    @Test func aNestedOrListedIdHoldingANullIsNamedByItsPath() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "first")
            let block = try h.operations.newBlock(in: note.id, text: "One.", registeringUndo: false)
            let other = try h.operations.createPost(title: "second")
            _ = try h.operations.createTag(name: "t")
            try await approvedClaudeCode(h, spec(.edit, .wing, ""))
            let connection = try await h.connect(as: "claude-code")
            let before = try counts(h)
            let takes = try await connection.client.callTool(
                name: "add_takes",
                arguments: ["note_id": .string(note.id),
                            "takes": .array([.object(["block_id": .string(block.block.id + "\u{0}junk"),
                                                      "text": .string("Another.")])])])
            #expect(takes.isError == true && text(takes) == idWords("takes[0].block_id"), "\(text(takes))")
            let tagged = try await connection.client.callTool(
                name: "apply_tag",
                arguments: ["note_ids": .array([.string(note.id), .string(other.id + "\u{0}junk")]), "tag": .string("t")])
            #expect(tagged.isError == true && text(tagged) == idWords("note_ids[1]"), "\(text(tagged))")
            let (variants, applications) = try await h.database.read { db in
                (try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM variant WHERE block_id = ?", arguments: [block.block.id]) ?? 0,
                 try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM post_tag WHERE deleted_at IS NULL") ?? 0)
            }
            #expect(variants == 1 && applications == 0, "nothing written: \(variants) takes, \(applications) tags")
            #expect(h.undoStack.depth == 0 && h.receipts.value.isEmpty)
            #expect(try counts(h) == before)
            await h.hangUp(connection)
        }
    }

    /// GUARD (green on both sides — VX-357's lane is untouched): PROSE
    /// holding U+0000 is not an identifier; it lands stripped and counted.
    @Test func proseHoldingANullStillLandsStrippedAndCounted() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "n")
            let block = try h.operations.newBlock(in: note.id, text: "One.", registeringUndo: false)
            try await approvedClaudeCode(h, spec(.suggest, .wing, ""))
            let connection = try await h.connect(as: "claude-code")
            let added = try await connection.client.callTool(
                name: "add_take", arguments: ["block_id": .string(block.block.id), "text": .string("Two\u{0} words.")])
            #expect(added.isError != true, "\(text(added))")
            #expect(try json(added)["null_characters_removed"] as? Int == 1)
            await h.hangUp(connection)
        }
    }

    /// GUARD (green on both sides): an undeclared argument still refuses
    /// FIRST, in VX-606's words, whatever else the call carries.
    @Test func anUndeclaredArgumentStillRefusesFirst() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "n")
            try await approvedClaudeCode(h, spec(.read, .wing, ""))
            let connection = try await h.connect(as: "claude-code")
            let refused = try await connection.client.callTool(
                name: "read_note", arguments: ["note_id": .string(note.id + "\u{0}"), "ids": .bool(true)])
            #expect(text(refused)
                    == "ids isn't an argument of read_note, so nothing was done — send only the arguments its input schema lists.")
            await h.hangUp(connection)
        }
    }

    // MARK: - At the cursor's own parse (the two id-carrying cursors)

    /// GUARD — green on both sides, a HOLLOW sub-road recorded as such: a book
    /// cursor whose note id holds a NUL already answered stale on the pre-fix
    /// tree, because its resume point's facts read binds ids through
    /// `json_each` (the NUL rides intact, so no note matches). The parse guard
    /// covers it by construction now; this pins that it stays stale.
    @Test func aBookCursorWhoseIdHoldsANullIsNotOneThisServerReturned() async throws {
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
            try await approvedClaudeCode(h, spec(.read, .book, book.id))
            let connection = try await h.connect(as: "claude-code")
            let crafted = Data("b\n0\n\(members[0])\u{0}junk".utf8).base64EncodedString()
            let resumed = try await connection.client.callTool(
                name: "list_notes", arguments: ["book_id": .string(book.id), "cursor": .string(crafted)])
            #expect(resumed.isError == true && text(resumed) == MCPReadTools.staleCursorMessage, "\(text(resumed))")
            await h.hangUp(connection)
        }
    }

    /// RED ON OLD: a RECENCY cursor (a wing's listing) whose id holds a NUL
    /// resumed as its prefix — the keyset binds the id directly. Stale now.
    @Test func aRecencyCursorWhoseIdHoldsANullIsNotOneThisServerReturned() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            for index in 0..<3 { _ = try h.operations.createPost(title: "n\(index)") }
            try await approvedClaudeCode(h, spec(.read, .wing, ""))
            let connection = try await h.connect(as: "claude-code")
            let first = try await connection.client.callTool(
                name: "list_notes", arguments: ["wing_id": .string(""), "limit": .int(1)])
            let next = try #require(try json(first)["next_cursor"] as? String, "\(text(first))")
            let parts = String(decoding: try #require(Data(base64Encoded: next)), as: UTF8.self)
            let crafted = Data((parts + "\u{0}junk").utf8).base64EncodedString()
            let resumed = try await connection.client.callTool(
                name: "list_notes", arguments: ["wing_id": .string(""), "limit": .int(1), "cursor": .string(crafted)])
            #expect(resumed.isError == true && text(resumed) == MCPReadTools.staleCursorMessage, "\(text(resumed))")
            let clean = try await connection.client.callTool(
                name: "list_notes", arguments: ["wing_id": .string(""), "limit": .int(1), "cursor": .string(next)])
            #expect(clean.isError != true, "the cursor as returned still resumes: \(text(clean))")
            await h.hangUp(connection)
        }
    }

    /// RED ON OLD: a `read_note` page cursor whose placement id holds a NUL
    /// resumed as the prefix's placement. Stale now.
    @Test func aNoteCursorWhoseIdHoldsANullIsNotOneThisServerReturned() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "pages")
            for index in 0..<3 {
                _ = try h.operations.newBlock(in: note.id, text: "Block \(index).", registeringUndo: false)
            }
            try await approvedClaudeCode(h, spec(.read, .note, note.id))
            let connection = try await h.connect(as: "claude-code")
            let first = try await connection.client.callTool(
                name: "read_note", arguments: ["note_id": .string(note.id), "limit": .int(1)])
            let next = try #require(try json(first)["next_cursor"] as? String, "\(text(first))")
            let parts = String(decoding: try #require(Data(base64Encoded: next)), as: UTF8.self)
            let crafted = Data((parts + "\u{0}junk").utf8).base64EncodedString()
            let resumed = try await connection.client.callTool(
                name: "read_note", arguments: ["note_id": .string(note.id), "cursor": .string(crafted)])
            #expect(resumed.isError == true && text(resumed) == MCPReadTools.staleCursorMessage, "\(text(resumed))")
            let clean = try await connection.client.callTool(
                name: "read_note", arguments: ["note_id": .string(note.id), "cursor": .string(next)])
            #expect(clean.isError != true, "the cursor as returned still resumes: \(text(clean))")
            await h.hangUp(connection)
        }
    }
}
