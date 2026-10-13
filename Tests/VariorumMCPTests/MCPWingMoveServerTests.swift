import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// 13n-c U6 — `move_note_to_wing` end to end over the socket (VX-160; VX-160's
// ratified per-item move; VX-160's R1: EDIT on the note, WRITE NEW on the
// destination wing). The rung proofs grown as the ritual: read, suggest and
// write new cannot move a note across wings; a book grant can never name a
// destination; a fenced note moves only under a per-ask note grant; the once
// grants of both sides spend together or not at all; both decisions are made
// again inside the act's transaction. Plus the answer, the receipt, her frozen
// refusal in her words, and the ONE client-named undo entry.

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

@Suite("13n-c U6 — move_note_to_wing on the wire", .serialized)
struct MCPWingMoveServerTests {
    /// Home's "parser notes" (in book Alpha, tagged #writing) and the wing
    /// "variorum" it moves to.
    private struct World {
        let wing: Wing
        let note: Container
        let alpha: Reading
    }

    private func world(_ h: ServerHarness) throws -> World {
        let wing = try h.operations.createWing(name: "variorum")
        let note = try h.operations.createPost(title: "parser notes")
        _ = try h.operations.newBlock(in: note.id, text: "the lexer comes first", registeringUndo: false)
        let alpha = try h.operations.createReading(name: "Alpha", kind: .book)
        _ = try h.operations.addPostToReading(note.id, to: alpha.id)
        let writing = try h.operations.createTag(name: "writing")
        try h.operations.applyTag(writing.id, toPost: note.id)
        return World(wing: wing, note: note, alpha: alpha)
    }

    private func wingOf(_ h: ServerHarness, _ id: String) throws -> String? {
        try h.database.read { try String.fetchOne($0, sql: "SELECT wing_id FROM container WHERE id = ?", arguments: [id]) }
    }

    /// A sync read (the async overload would win inside the test bodies).
    private func strings(_ h: ServerHarness, _ sql: String, _ arguments: [String]) throws -> [String] {
        try h.database.read { try String.fetchAll($0, sql: sql, arguments: StatementArguments(arguments)) }
    }

    /// The newest activity row (a sync read).
    private func lastActivity(_ h: ServerHarness) throws -> MCPActivityRow? {
        try h.database.read { try Queries.mcpActivity($0, limit: 1) }.first
    }

    private func grantIDs(_ h: ServerHarness) throws -> [String] {
        try h.database.read { try String.fetchAll($0, sql: "SELECT id FROM mcp_grant ORDER BY created_at, id") }
    }

    private func consumed(_ h: ServerHarness, _ id: String) throws -> Bool {
        try h.database.read {
            try String.fetchOne($0, sql: "SELECT consumed_at FROM mcp_grant WHERE id = ?", arguments: [id])
        } != nil
    }

    // MARK: - R1: edit on the note, write new on the wing — the rung proofs

    @Test func aMoveNeedsEditWhereTheNoteIsAndWriteNewWhereItGoes() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let elsewhere = try h.operations.createReading(name: "over there", kind: .book, wingId: w.wing.id)
            let connection = try await h.connect(as: "claude-code")
            let move: [String: Value] = ["note_id": .string(w.note.id), "wing_id": .string(w.wing.id)]
            let client = { try h.client("claude-code").id }
            let destination = try #require(try h.approve("claude-code", spec(.writeNew, .wing, w.wing.id)))

            // Read, suggest and write new on the note's own wing never move it.
            for rung in [MCPGrantRule.Rung.read, .suggest, .writeNew] {
                let grant = try h.operations.grantMCPAccess(try client(), spec(rung, .wing, ""))
                h.asks.setValue([])
                let refused = try await call(connection, "move_note_to_wing", move)
                #expect(refused.isError == true, "\(rung) on the note's wing cannot move it")
                #expect(text(refused).hasPrefix("This client may only \(MCPRefusalCopy.rungWords(rung)) here."))
                #expect(h.asks.value.map(\.scopeKind) == [.note] && h.asks.value.first?.rung == .edit,
                        "the source's ask, at edit — raised first")
                try h.operations.revokeMCPGrant(grant)
            }
            #expect(try wingOf(h, w.note.id) == "", "nothing moved")

            // Edit on the note, but the destination is short.
            _ = try h.operations.grantMCPAccess(try client(), spec(.edit, .wing, ""))
            try h.operations.revokeMCPGrant(destination)
            h.asks.setValue([])
            let noWing = try await call(connection, "move_note_to_wing", move)
            #expect(noWing.isError == true && text(noWing) == MCPRefusalCopy.words(.notShared, .wing))
            #expect(h.asks.value.map(\.scopeKind) == [.wing] && h.asks.value.first?.rung == .writeNew,
                    "the destination's ask, at write new")
            let bookThere = try h.operations.grantMCPAccess(try client(), spec(.edit, .book, elsewhere.id))
            let byBook = try await call(connection, "move_note_to_wing", move)
            #expect(byBook.isError == true && text(byBook) == MCPRefusalCopy.words(.notShared, .wing),
                    "a book grant in the destination can never name where a bookless note lands")
            try h.operations.revokeMCPGrant(bookThere)
            let readThere = try h.operations.grantMCPAccess(try client(), spec(.read, .wing, w.wing.id))
            let tooLow = try await call(connection, "move_note_to_wing", move)
            #expect(tooLow.isError == true && text(tooLow).hasPrefix("This client may only read here."))
            try h.operations.revokeMCPGrant(readThere)
            #expect(try wingOf(h, w.note.id) == "", "still nothing moved")

            _ = try h.operations.grantMCPAccess(try client(), spec(.writeNew, .wing, w.wing.id))
            let landed = try await call(connection, "move_note_to_wing", move)
            #expect(landed.isError != true, "\(text(landed))")
            #expect(try wingOf(h, w.note.id) == w.wing.id)
            await h.hangUp(connection)
        }
    }

    @Test func aFencedNoteMovesOnlyUnderAPerAskGrantOnThatNote() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            try h.operations.setNotePrivate(w.note.id, true)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            let client = try h.client("claude-code").id
            let destination = try h.operations.grantMCPAccess(client, spec(.writeNew, .wing, w.wing.id))
            let fenced = try await call(connection, "move_note_to_wing",
                                        ["note_id": .string(w.note.id), "wing_id": .string(w.wing.id)])
            let nowhere = try await call(connection, "move_note_to_wing",
                                         ["note_id": .string("no-such-note"), "wing_id": .string(w.wing.id)])
            #expect(fenced.isError == true && text(fenced) == text(nowhere),
                    "a Private note answers exactly as an id naming nothing — no oracle")
            #expect(try wingOf(h, w.note.id) == "")

            let perAsk = try h.operations.grantMCPAccess(client, spec(.edit, .note, w.note.id, .once))
            let landed = try await call(connection, "move_note_to_wing",
                                        ["note_id": .string(w.note.id), "wing_id": .string(w.wing.id)])
            #expect(landed.isError != true, "\(text(landed))")
            #expect(try wingOf(h, w.note.id) == w.wing.id)
            #expect(try consumed(h, perAsk), "the per-ask once grant is spent by the move")
            #expect(try !consumed(h, destination), "an always grant is never spent")
            await h.hangUp(connection)
        }
    }

    @Test func theOnceGrantsOfBothSidesSpendTogetherOrNotAtAll() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", nil)
            let client = try h.client("claude-code").id

            // A refused act (a finished book holds the note) spends neither.
            try h.operations.lockReading(w.alpha.id)
            let source = try h.operations.grantMCPAccess(client, spec(.edit, .note, w.note.id, .once))
            let destination = try h.operations.grantMCPAccess(client, spec(.writeNew, .wing, w.wing.id, .once))
            let frozen = try await call(connection, "move_note_to_wing",
                                        ["note_id": .string(w.note.id), "wing_id": .string(w.wing.id)])
            #expect(frozen.isError == true)
            #expect(try !consumed(h, source) && !consumed(h, destination), "a refused act spends nothing")

            try h.operations.unlockReading(w.alpha.id)
            let landed = try await call(connection, "move_note_to_wing",
                                        ["note_id": .string(w.note.id), "wing_id": .string(w.wing.id)])
            #expect(landed.isError != true, "\(text(landed))")
            #expect(try consumed(h, source) && consumed(h, destination), "one write, both sides' once grants")
            await h.hangUp(connection)
        }
    }

    // MARK: - The answer, the receipt, her words, the one undo entry

    @Test func theAnswerNamesOnlyBooksTheClientCanReadAndTheReceiptCoalescesBySweep() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let hidden = try h.operations.createReading(name: "Beta", kind: .book)
            _ = try h.operations.addPostToReading(w.note.id, to: hidden.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, w.alpha.id))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.writeNew, .wing, w.wing.id))

            let answer = try json(try await call(connection, "move_note_to_wing",
                                                 ["note_id": .string(w.note.id), "wing_id": .string(w.wing.id)]))
            #expect(answer["moved"] as? Bool == true)
            #expect(answer["landed"] as? String == "the Pool of \u{201C}variorum\u{201D}")
            let left = try #require(answer["left_books"] as? [[String: Any]])
            #expect(left.map { $0["book_id"] as? String } == [w.alpha.id, hidden.id])
            #expect(left.map { $0["name"] as? String } == ["Alpha", nil],
                    "a book the client can't read is named by id only — names stay with grants")
            let tags = try #require(answer["tags"] as? [String: Int])
            #expect(tags == ["adopted": 0, "made": 1], "#writing is made in the new wing by its path")

            let receipt = try #require(h.receipts.value.last)
            #expect(receipt.act == .wingMove && receipt.targetID == w.wing.id && receipt.targetTitle == "variorum")
            #expect(receipt.detail == "parser notes" && receipt.leftBooks == 2)
            #expect(receipt.show == .note(noteID: w.note.id, blockID: nil, select: nil))
            #expect(h.undoStack.topLabel == "claude-code's wing move", "ONE client-named entry")
            // D-U6-2 (found walking, the live round): the activity row names
            // the NOTE it moved — the receipt's title is the destination
            // wing's (the sweep's coalescing key), never the log's.
            let logged = try lastActivity(h)
            #expect(logged?.act == "move_note_to_wing" && logged?.targetID == w.note.id)
            #expect(logged?.targetTitle == "parser notes", "the row says which note moved")
            await h.hangUp(connection)
        }
    }

    @Test func aFrozenBooksMemberRefusesInHerWordsWhereTheClientCanReadTheBook() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        h.host.hooks.wingMoveFrozenWords = { title, book in "HER DOOR: \(title) / \(book)" }
        try await h.within {
            let w = try world(h)
            try h.operations.lockReading(w.alpha.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, w.alpha.id))
            let client = try h.client("claude-code").id
            _ = try h.operations.grantMCPAccess(client, spec(.writeNew, .wing, w.wing.id))
            let readable = try await call(connection, "move_note_to_wing",
                                          ["note_id": .string(w.note.id), "wing_id": .string(w.wing.id)])
            #expect(readable.isError == true && text(readable) == "HER DOOR: parser notes / Alpha")

            // Reached through a NOTE grant only: the book's name stays with
            // its grants — the op's own refusal speaks instead.
            try h.operations.revokeMCPGrant(try grantIDs(h).first!)
            _ = try h.operations.grantMCPAccess(client, spec(.edit, .note, w.note.id))
            let unreadable = try await call(connection, "move_note_to_wing",
                                            ["note_id": .string(w.note.id), "wing_id": .string(w.wing.id)])
            #expect(unreadable.isError == true
                    && text(unreadable) == "Refused: \(OperationError.lockedReading(id: w.alpha.id))")
            #expect(try wingOf(h, w.note.id) == "")
            await h.hangUp(connection)
        }
    }

    @Test func oneUndoWalksTheMoveBackWithItsBooksAndTags() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.writeNew, .wing, w.wing.id))
            let tagsSQL = "SELECT id FROM post_tag WHERE post_id = ? AND deleted_at IS NULL"
            let tagsBefore = try strings(h, tagsSQL, [w.note.id])
            let landed = try await call(connection, "move_note_to_wing",
                                        ["note_id": .string(w.note.id), "wing_id": .string(w.wing.id)])
            #expect(landed.isError != true)
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's wing move")
            #expect(try wingOf(h, w.note.id) == "")
            #expect(try strings(h, "SELECT reading_id FROM reading_post WHERE post_id = ? AND deleted_at IS NULL",
                                [w.note.id]) == [w.alpha.id], "back in its book")
            #expect(try strings(h, tagsSQL, [w.note.id]) == tagsBefore, "its own tag application back")
            await h.hangUp(connection)
        }
    }

    // MARK: - Both decisions re-made inside the act's transaction

    @Test func aRevocationLandingAfterTheSnapshotIsCaughtInsideTheAct() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            _ = try h.operations.recordMCPContact(name: "claude-code", version: "1")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            let destination = try h.operations.grantMCPAccess(
                try h.client("claude-code").id, spec(.writeNew, .wing, w.wing.id))
            let tools = MCPWriteTools(
                database: h.database, grants: h.operations, executor: SeededExecutor(operations: h.writeOperations))
            let snapshot = try await h.database.read { db in
                MCPGrantAuthority.decideWing(
                    try MCPGrantAuthority.standing(db, clientName: "claude-code"), wingID: w.wing.id, rung: .writeNew)
            }
            #expect(snapshot.isAllowed, "the decision a snapshot made")

            try h.operations.revokeMCPGrant(destination)  // lands between the two
            do {
                try h.writeOperations.mcpMoveNoteToWing(
                    w.note.id, to: w.wing.id, undoLabel: "claude-code's wing move",
                    guardedBy: tools.guardWingMove("claude-code", noteID: w.note.id, wingID: w.wing.id))
                Issue.record("the move landed past a grant revoked after the decision")
            } catch let refused as MCPWriteTools.Refused {
                #expect(refused.outcome.text == MCPRefusalCopy.words(.notShared, .wing))
            }
            #expect(try wingOf(h, w.note.id) == "")
            #expect(h.undoStack.depth == 0)
        }
    }
}
