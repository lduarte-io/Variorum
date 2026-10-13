import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-184 U3 — VX-173 (the door half): `add_takes` and `add_comments`, the
// suggest rung's BATCH doors. One note per call; ONE transaction with the grant
// guard first inside it; ONE client-named undo entry; ALL-OR-NOTHING — any
// item's refusal refuses the whole batch, naming the item; a stated cap (200),
// an over-cap call refused naming it. Blank takes stay legal at add
// (R-VX171-2). Written to compile on the pre-fix tree (acts and labels by
// their strings), where every call answers "Unknown tool".

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

@Suite("VX-173 — add_takes and add_comments, one act each", .serialized)
struct MCPBatchDoorsServerTests {
    /// A five-block note in a book, and a second note (a foreign block).
    private struct World {
        let book: Reading
        let note: Container
        let blocks: [String]
        let hers: [String]
        let otherNote: Container
        let foreignBlock: String
    }

    private func world(_ h: ServerHarness) throws -> World {
        let book = try h.operations.createReading(name: "drafts", kind: .book)
        let note = try h.operations.createPost(title: "ch 1")
        _ = try h.operations.addPostToReading(note.id, to: book.id)
        var blocks: [String] = []
        var hers: [String] = []
        for index in 1...5 {
            let minted = try h.operations.newBlock(in: note.id, text: "Her paragraph \(index).", registeringUndo: false)
            blocks.append(minted.block.id)
            hers.append(minted.variant.id)
        }
        let other = try h.operations.createPost(title: "ch 2")
        _ = try h.operations.addPostToReading(other.id, to: book.id)
        let foreign = try h.operations.newBlock(in: other.id, text: "Another note's words.", registeringUndo: false)
        return World(book: book, note: note, blocks: blocks, hers: hers, otherNote: other, foreignBlock: foreign.block.id)
    }

    private func rendered(_ h: ServerHarness, _ noteID: String) async throws -> String {
        try await h.database.read { try Queries.renderedText($0, containerID: noteID) }
    }

    private func liveTakes(_ h: ServerHarness) async throws -> Int {
        try await h.database.read { try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM variant WHERE deleted_at IS NULL") ?? -1 }
    }

    private func liveComments(_ h: ServerHarness) async throws -> Int {
        try await h.database.read {
            try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM block_comment WHERE deleted_at IS NULL") ?? -1
        }
    }

    private func take(_ block: String, _ text: String, _ label: String? = nil) -> Value {
        var item: [String: Value] = ["block_id": .string(block), "text": .string(text)]
        if let label { item["label"] = .string(label) }
        return .object(item)
    }

    // MARK: - add_takes

    @Test func addTakesLandsEveryTakeAsOneUndo() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.suggest, .book, w.book.id))
            let page = try await rendered(h, w.note.id)
            let before = try await liveTakes(h)

            let items: [Value] = [
                take(w.blocks[0], "First, in English.", "english"),
                take(w.blocks[1], "Second, in English.", "english"),
                take(w.blocks[2], "Third, in English."),
                take(w.blocks[3], ""),  // a blank take — legal at add (R-VX171-2)
                take(w.blocks[4], "Fifth, in English.", "english"),
                take(w.blocks[0], "First, again.", "alt"),  // two takes on one block
            ]
            let landed = try await call(connection, "add_takes", ["note_id": .string(w.note.id), "takes": .array(items)])
            #expect(landed.isError != true, "\(text(landed))")
            let answer = try json(landed)
            let takeIDs = try #require(answer["take_ids"] as? [String])
            #expect(takeIDs.count == 6 && Set(takeIDs).count == 6, "one id per item, in the items' order")
            #expect(answer["note_id"] as? String == w.note.id)
            #expect(try await liveTakes(h) == before + 6)
            #expect(try await rendered(h, w.note.id) == page, "never chosen: the page is unchanged")

            // Each at its block's fan END, labeled with the client, never locked.
            let rows: [(block: String, text: String, label: String?, locked: Int)] = try await h.database.read { db in
                try takeIDs.compactMap { id in
                    try Row.fetchOne(
                        db, sql: "SELECT block_id, working_text, label, locked FROM variant WHERE id = ?", arguments: [id]
                    ).map { ($0["block_id"], $0["working_text"], $0["label"], $0["locked"]) }
                }
            }
            #expect(rows.map(\.block) == [w.blocks[0], w.blocks[1], w.blocks[2], w.blocks[3], w.blocks[4], w.blocks[0]])
            #expect(rows.map(\.text)
                    == ["First, in English.", "Second, in English.", "Third, in English.", "", "Fifth, in English.",
                        "First, again."])
            #expect(rows.first?.label == "claude-code \u{00B7} suggested \u{00B7} english")
            #expect(rows.count > 2 && rows[2].label == "claude-code \u{00B7} suggested")
            #expect(rows.allSatisfy { $0.locked == 0 })
            let fanOrder = try await h.database.read { db in
                try String.fetchAll(db, sql: """
                    SELECT id FROM variant WHERE block_id = ? AND deleted_at IS NULL ORDER BY fan_position, id
                    """, arguments: [w.blocks[0]])
            }
            #expect(fanOrder == [w.hers[0], takeIDs[0], takeIDs[5]], "her take first, the batch's at the end in order")

            // ONE act: one undo entry, one receipt counting six.
            #expect(h.undoStack.depth == 1 && h.undoStack.topLabel == "claude-code's takes")
            #expect(h.receipts.value.count == 1 && h.receipts.value.last?.act.rawValue == "takes"
                    && h.receipts.value.last?.count == 6)
            let activity = try await h.database.read { try Queries.mcpActivity($0, limit: 1) }
            #expect(activity.first?.act == "add_takes" && activity.first?.allowed == true
                    && activity.first?.targetID == w.note.id)

            // One ⌥⌘Z walks the whole batch back; ⇧⌥⌘Z brings back the same rows.
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's takes")
            #expect(try await liveTakes(h) == before)
            #expect(try h.undoStack.redo(with: h.writeOperations) == "claude-code's takes")
            let back = try await h.database.read { db in
                try String.fetchAll(db, sql: "SELECT id FROM variant WHERE deleted_at IS NULL")
            }
            #expect(Set(takeIDs).isSubset(of: Set(back)), "the redo revives the very rows")
            await h.hangUp(connection)
        }
    }

    /// ALL-OR-NOTHING, naming the item: a block of another note and an id
    /// naming nothing answer the SAME words (no oracle); a malformed item is
    /// refused at the parse; a sealed note refuses the whole batch with the
    /// op's own words. Nothing lands, nothing registers, no receipt.
    @Test func aBatchIsAllOrNothingNamingTheItem() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.suggest, .book, w.book.id))
            let before = try await liveTakes(h)

            let foreign = try await call(connection, "add_takes", ["note_id": .string(w.note.id), "takes": .array([
                take(w.blocks[0], "fine"), take(w.blocks[1], "fine"), take(w.foreignBlock, "elsewhere"),
            ])])
            let missing = try await call(connection, "add_takes", ["note_id": .string(w.note.id), "takes": .array([
                take(w.blocks[0], "fine"), take(w.blocks[1], "fine"), take("no-such-block", "nowhere"),
            ])])
            #expect(foreign.isError == true && text(foreign).hasPrefix("takes[2].block_id isn't a block of this note"),
                    "\(text(foreign))")
            #expect(text(missing) == text(foreign), "a block elsewhere and a block nowhere answer alike")

            let malformed = try await call(connection, "add_takes", ["note_id": .string(w.note.id), "takes": .array([
                take(w.blocks[0], "fine"), .object(["block_id": .string(w.blocks[1])]),
            ])])
            #expect(malformed.isError == true && text(malformed) == "takes[1].text is required.", "\(text(malformed))")
            let empty = try await call(connection, "add_takes", ["note_id": .string(w.note.id), "takes": .array([])])
            #expect(empty.isError == true && text(empty) == "takes must list at least one take.", "\(text(empty))")

            let blankComment = try await call(connection, "add_comments", ["note_id": .string(w.note.id), "comments": .array([
                .object(["block_id": .string(w.blocks[0]), "text": .string("good")]),
                .object(["block_id": .string(w.blocks[1]), "text": .string("   ")]),
            ])])
            #expect(blankComment.isError == true
                    && text(blankComment) == "comments[1].text is required — a comment can't be blank.",
                    "\(text(blankComment))")

            try h.operations.lockPost(w.note.id)
            let sealed = try await call(connection, "add_takes", ["note_id": .string(w.note.id), "takes": .array([
                take(w.blocks[0], "fine"), take(w.blocks[1], "fine"),
            ])])
            #expect(sealed.isError == true, "a sealed note refuses the whole batch")

            let takesAfter = try await liveTakes(h)
            let commentsAfter = try await liveComments(h)
            #expect(takesAfter == before && commentsAfter == 0, "nothing landed")
            #expect(h.undoStack.depth == 0 && h.receipts.value.isEmpty, "nothing registered, nothing said")
            await h.hangUp(connection)
        }
    }

    /// THE CAP — stated in each tool's description; a call at the cap is
    /// served, one past it refused naming the cap, nothing landing.
    @Test func theCapIsStatedAndAnOverCapCallRefusesNamingIt() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.suggest, .book, w.book.id))
            let tools = try await connection.client.listTools().tools
            let addTakes = try #require(tools.first { $0.name == "add_takes" })
            let addComments = try #require(tools.first { $0.name == "add_comments" })
            #expect(addTakes.description?.contains("at most 200 takes") == true, "\(addTakes.description ?? "")")
            #expect(addComments.description?.contains("at most 200 comments") == true, "\(addComments.description ?? "")")

            let before = try await liveTakes(h)
            let over = (0..<201).map { take(w.blocks[$0 % 5], "take \($0)") }
            let refused = try await call(connection, "add_takes", ["note_id": .string(w.note.id), "takes": .array(over)])
            #expect(refused.isError == true
                    && text(refused) == "add_takes takes at most 200 takes in one call; this call has 201. "
                        + "Split it into calls of 200 or fewer.", "\(text(refused))")
            #expect(try await liveTakes(h) == before && h.undoStack.depth == 0)

            let overComments = (0..<201).map { index in
                Value.object(["block_id": .string(w.blocks[index % 5]), "text": .string("note \(index)")])
            }
            let refusedComments = try await call(connection, "add_comments", [
                "note_id": .string(w.note.id), "comments": .array(overComments),
            ])
            #expect(refusedComments.isError == true
                    && text(refusedComments) == "add_comments takes at most 200 comments in one call; this call has 201. "
                        + "Split it into calls of 200 or fewer.", "\(text(refusedComments))")

            let atCap = (0..<200).map { take(w.blocks[$0 % 5], "take \($0)") }
            let served = try await call(connection, "add_takes", ["note_id": .string(w.note.id), "takes": .array(atCap)])
            #expect(served.isError != true, "\(text(served))")
            #expect(try await liveTakes(h) == before + 200)
            #expect(h.undoStack.depth == 1, "two hundred takes, one act")
            await h.hangUp(connection)
        }
    }

    // MARK: - add_comments

    @Test func addCommentsLandsEveryCommentAsOneUndo() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.suggest, .book, w.book.id))
            let page = try await rendered(h, w.note.id)

            let landed = try await call(connection, "add_comments", ["note_id": .string(w.note.id), "comments": .array([
                .object(["block_id": .string(w.blocks[0]), "text": .string("Check this date.")]),
                .object(["block_id": .string(w.blocks[2]), "text": .string("A source would help here.")]),
                .object(["block_id": .string(w.blocks[2]), "text": .string("Tense shifts mid-sentence.")]),
            ])])
            #expect(landed.isError != true, "\(text(landed))")
            let commentIDs = try #require(try json(landed)["comment_ids"] as? [String])
            #expect(commentIDs.count == 3)
            let rows: [(block: String, text: String)] = try await h.database.read { db in
                try commentIDs.compactMap { id in
                    try Row.fetchOne(db, sql: "SELECT block_id, text FROM block_comment WHERE id = ?", arguments: [id])
                        .map { ($0["block_id"], $0["text"]) }
                }
            }
            #expect(rows.map(\.block) == [w.blocks[0], w.blocks[2], w.blocks[2]])
            #expect(rows.map(\.text) == ["Check this date.", "A source would help here.", "Tense shifts mid-sentence."])
            #expect(try await rendered(h, w.note.id) == page, "a comment writes no word of the text")
            #expect(h.undoStack.depth == 1 && h.undoStack.topLabel == "claude-code's comments")
            #expect(h.receipts.value.count == 1 && h.receipts.value.last?.act.rawValue == "comments"
                    && h.receipts.value.last?.count == 3)

            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's comments")
            #expect(try await liveComments(h) == 0)
            #expect(try h.undoStack.redo(with: h.writeOperations) == "claude-code's comments")
            #expect(try await liveComments(h) == 3)
            await h.hangUp(connection)
        }
    }

    // MARK: - The rung, the once grant, the listing

    /// SUGGEST on the note: a read grant hears the rung's refusal (and raises
    /// the ask); a ONCE suggest grant pays for ONE batch — the second refuses.
    @Test func aBatchNeedsSuggestAndAOnceGrantPaysForOneBatch() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .book, w.book.id))
            let tools = try await connection.client.listTools().tools.map(\.name)
            #expect(!tools.contains("add_takes") && !tools.contains("add_comments"), "not offered under read")

            let tooLow = try await call(connection, "add_takes", ["note_id": .string(w.note.id), "takes": .array([
                take(w.blocks[0], "x"),
            ])])
            #expect(tooLow.isError == true && text(tooLow).hasPrefix("This client may only read here."), "\(text(tooLow))")
            #expect(h.asks.value.last?.rung == .suggest && h.asks.value.last?.scopeID == w.note.id)

            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.suggest, .note, w.note.id, .once))
            let first = try await call(connection, "add_takes", ["note_id": .string(w.note.id), "takes": .array([
                take(w.blocks[0], "a"), take(w.blocks[1], "b"), take(w.blocks[2], "c"),
            ])])
            #expect(first.isError != true, "\(text(first))")
            let second = try await call(connection, "add_comments", ["note_id": .string(w.note.id), "comments": .array([
                .object(["block_id": .string(w.blocks[0]), "text": .string("again")]),
            ])])
            #expect(second.isError == true, "the once grant paid for one batch — a write, whatever its size")
            await h.hangUp(connection)
        }
    }
}
