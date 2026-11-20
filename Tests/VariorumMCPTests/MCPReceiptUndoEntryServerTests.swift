import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-133 (the VX-981 run, batch 2 — the record `notes/plans/fixes/vx-981-mcp-door-followups.md`,
// BATCH 2 RECORD): the wire's half of "the receipt run's count stays true". Every landed act
// registers ONE client-named undo entry on the session's stack; its receipt now carries that
// entry's token (`MCPWriteReceipt.undoEntryID`, stamped by `MCPWriteTools.call` from the stack
// the act ran on), so the app's run knows which of its acts her ⌥⌘Z walked back. RED ON THE
// SCAFFOLD (no receipt carried a token, so no walk could ever lower the count).

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: .always)
}

private func call(
    _ connection: HarnessConnection, _ name: String, _ arguments: [String: Value]
) async throws -> (content: [Tool.Content], isError: Bool?) {
    try await connection.client.callTool(name: name, arguments: arguments)
}

/// Walks heard on the runner's thread.
private final class Heard: @unchecked Sendable {
    private let lock = NSLock()
    private var walks: [UndoStack.Walk] = []
    func append(_ walk: UndoStack.Walk) { lock.withLock { walks.append(walk) } }
    var value: [UndoStack.Walk] { lock.withLock { walks } }
}

@Suite("VX-133 — a landed act's receipt names the undo entry it registered", .serialized)
struct MCPReceiptUndoEntryServerTests {
    /// **RED ON THE SCAFFOLD.** A single act's receipt carries the token of the ONE entry its act
    /// registered; each item of a LIST call (VX-812) carries its own, in order; a commit — no
    /// entry (I5) — carries none.
    @Test func eachLandedActsReceiptCarriesItsOwnEntrysToken() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "Shelf", kind: .book)
            let one = try h.operations.createPost(title: "one")
            let two = try h.operations.createPost(title: "two")
            for note in [one, two] { _ = try h.operations.addPostToReading(note.id, to: book.id) }
            let block = try h.operations.newBlock(in: one.id, text: "Her line.", registeringUndo: false)
            _ = try h.operations.createTag(name: "listed")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, book.id))

            #expect(try await call(connection, "add_take", [
                "block_id": .string(block.block.id), "text": .string("Another line."),
            ]).isError != true)
            let single = try #require(h.receipts.value.last)
            #expect(single.undoEntryID != nil && single.undoEntryID == h.undoStack.newestEntryID,
                    "RED ON THE SCAFFOLD: the act's own entry — \(String(describing: single.undoEntryID))")

            let before = h.undoStack.newestEntryID
            let listed = try await call(connection, "apply_tag", [
                "note_ids": .array([.string(one.id), .string(two.id)]), "tag": .string("listed"),
            ])
            #expect(listed.isError != true, "\(text(listed))")
            let items = Array(h.receipts.value.suffix(2))
            #expect(items.map(\.undoEntryID) == h.undoStack.entryIDs(newerThan: before).map(Optional.some),
                    "RED ON THE SCAFFOLD: each item its own entry, in order — \(items.map(\.undoEntryID))")
            #expect(Set(items.compactMap(\.runKey)).count == 1, "one call, one run key")

            let take = try #require(try await h.database.read { db in
                try String.fetchOne(db, sql: "SELECT id FROM variant WHERE block_id = ? ORDER BY fan_position LIMIT 1",
                                    arguments: [block.block.id])
            })
            #expect(try await call(connection, "save_commit", [
                "take_id": .string(take), "message": .string("kept"),
            ]).isError != true)
            #expect(h.receipts.value.last?.act == .commit && h.receipts.value.last?.undoEntryID == nil,
                    "a commit registers no entry, so its receipt names none")
            await h.hangUp(connection)
        }
    }

    /// **RED ON THE SCAFFOLD — the ticket's case end to end, with real acts:** four of a client's
    /// acts land on one note; she walks three back with her structural undo; the run that hears
    /// the stack's walks (the app door's road, `MCPReceiptRun`) counts ONE; her redo of one raises
    /// it to two.
    @Test func fourActsThreeUndoneTheRunCountsOne() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "ch 1")
            let block = try h.operations.newBlock(in: note.id, text: "Her line.", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.suggest, .note, note.id))
            let heard = Heard()
            let token = h.undoStack.addWalkObserver { heard.append($0) }
            defer { h.undoStack.removeWalkObserver(token) }

            for index in 1...4 {
                #expect(try await call(connection, "add_take", [
                    "block_id": .string(block.block.id), "text": .string("Take \(index)."),
                ]).isError != true)
            }
            var run = MCPReceiptRun()
            for (offset, receipt) in h.receipts.value.enumerated() {
                run.land(receipt, now: ServerHarness.worldNow.addingTimeInterval(Double(offset)))
            }
            #expect(run.standing.count == 4)
            for _ in 1...3 { _ = try h.undoStack.undoReporting(with: h.writeOperations) }
            for walk in heard.value { run.walked(walk) }
            #expect(run.standing.count == 1, "RED ON THE SCAFFOLD: four acts, three undone — \(run.standing.count)")
            _ = try h.undoStack.redoReporting(with: h.writeOperations)
            if let last = heard.value.last { run.walked(last) }
            #expect(run.standing.count == 2, "RED ON THE SCAFFOLD: her redo raises it again")
            await h.hangUp(connection)
        }
    }
}
