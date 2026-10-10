import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// 13n-b U3 — THE EDIT RUNG END TO END, over a real socket driven by the SDK's
// own `Client` (U1's harness). The verification bar's EDIT half: an edit
// grant's `edit_take` lands bracketed by the named commits and a stale read
// refuses; every structural act is one client-named undo entry; a suggest or
// write-new grant PROVABLY cannot reach the edit tools; the in-transaction
// guard re-decides every act (and spends a once grant atomically with it).

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String,
    _ duration: MCPGrantRule.Duration = .always
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
}

private func call(
    _ connection: (client: Client, fd: Int32), _ name: String, _ arguments: [String: Value]
) async throws -> (content: [Tool.Content], isError: Bool?) {
    try await connection.client.callTool(name: name, arguments: arguments)
}

private let editTools: Set<String> = [
    "edit_take", "divide_block", "merge_blocks", "move_block", "delete_block", "set_block_name",
]

@Suite("13n-b U3 — the MCP server's edit rung end to end", .serialized)
struct MCPEditServerTests {
    // MARK: - The listing (P-2 on the wire)

    @Test func theEditToolsAreListedOnlyToAnEditGrant() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let connection = try await h.connect(as: "claude-code")
            let grantID = try #require(try h.approve("claude-code", spec(.writeNew, .book, book.id)))
            let writeNew = Set(try await connection.client.listTools().tools.map(\.name))
            #expect(writeNew.isDisjoint(with: editTools), "write new lists no edit door")
            #expect(writeNew.contains("create_section"), "create_section is write new's (R-13nb-11 G-1)")
            try h.operations.revokeMCPGrant(grantID)
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.edit, .book, book.id))
            let edit = Set(try await connection.client.listTools().tools.map(\.name))
            #expect(edit.isSuperset(of: editTools))
            #expect(edit.isSuperset(of: ["add_take", "create_note", "read_note"]), "the rungs are cumulative")
            await h.hangUp(connection)
        }
    }

    // MARK: - edit_take: bracketed, stale refuses, one undo

    @Test func editTakeLandsBracketedByTheNamedCommitsAndAStaleReadRefuses() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let note = try h.operations.createPost(title: "ch 1")
            _ = try h.operations.addPostToReading(note.id, to: book.id)
            let seeded = try h.operations.newBlock(in: note.id, text: "Her opening line.", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, book.id))

            let read = try json(try await call(connection, "read_note", ["note_id": .string(note.id), "with_ids": .bool(true)]))
            let block = try #require((read["blocks"] as? [[String: Any]])?.first)
            let take = try #require((block["takes"] as? [[String: Any]])?.first)
            let takeID = try #require(take["take_id"] as? String)
            let asRead = try #require(take["text"] as? String)

            let edited = try await call(connection, "edit_take", [
                "take_id": .string(takeID), "text": .string("A tighter opening."), "expected_text": .string(asRead),
            ])
            #expect(edited.isError != true, "\(text(edited))")
            let answer = try json(edited)
            #expect(answer["before_commit_id"] is String && answer["after_commit_id"] is String)
            let history = try await h.database.read { db in
                try String.fetchAll(
                    db, sql: "SELECT message FROM commit_point WHERE variant_id = ? ORDER BY created_at DESC, id DESC",
                    arguments: [seeded.variant.id])
            }
            #expect(history == ["after claude-code's edit", "before claude-code's edit"],
                    "Block History reads the cast of writers (R-13n-7)")
            #expect(try await h.database.read { try Queries.renderedText($0, containerID: note.id) } == "A tighter opening.")
            #expect(h.undoStack.topLabel == "claude-code's edit")
            #expect(h.receipts.value.last?.act == .edit)

            let stale = try await call(connection, "edit_take", [
                "take_id": .string(takeID), "text": .string("Overwrite."), "expected_text": .string(asRead),
            ])
            #expect(stale.isError == true, "the client's read is stale now — refused, nothing written")
            #expect(text(stale).contains("bufferChangedSinceGesture"), "the operations layer's own refusal: \(text(stale))")
            #expect(try await h.database.read { try Queries.renderedText($0, containerID: note.id) } == "A tighter opening.")

            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's edit")
            #expect(try await h.database.read { try Queries.renderedText($0, containerID: note.id) } == "Her opening line.")
            await h.hangUp(connection)
        }
    }

    // MARK: - The structural tools: her doors' acts, one undo each

    @Test func theStructuralToolsAreHerDoorsActsEachOneClientNamedUndo() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let note = try h.operations.createPost(title: "ch 1")
            let other = try h.operations.createPost(title: "ch 2")
            let outside = try h.operations.createPost(title: "not shared")
            for post in [note, other] { _ = try h.operations.addPostToReading(post.id, to: book.id) }
            let first = try h.operations.newBlock(in: note.id, text: "One sentence. Another sentence.", registeringUndo: false)
            let second = try h.operations.newBlock(in: note.id, text: "Closing.", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, book.id))

            // divide_block — the cut named by its words.
            let ambiguous = try await call(connection, "divide_block", [
                "block_id": .string(first.block.id), "second_half_starts_with": .string("sentence"),
            ])
            #expect(ambiguous.isError == true && text(ambiguous).contains("more than once"))
            let divided = try json(try await call(connection, "divide_block", [
                "block_id": .string(first.block.id), "second_half_starts_with": .string("Another"),
            ]))
            let secondHalf = try #require(divided["second_block_id"] as? String)
            #expect(try await h.database.read { try Queries.renderedText($0, containerID: note.id) }
                    == "One sentence.\n\nAnother sentence.\n\nClosing.")
            #expect(h.undoStack.topLabel == "claude-code's divide")

            // merge_blocks — the halves back together, by the rendering join.
            let merged = try json(try await call(connection, "merge_blocks", [
                "first_block_id": .string(first.block.id), "second_block_id": .string(secondHalf),
            ]))
            let mergedID = try #require(merged["block_id"] as? String)
            #expect(try await h.database.read { try Queries.renderedText($0, containerID: note.id) }
                    == "One sentence.\nAnother sentence.\n\nClosing.")
            #expect(h.undoStack.topLabel == "claude-code's merge")

            // move_block — within the note, then into another shared note…
            let moved = try await call(connection, "move_block", [
                "block_id": .string(second.block.id), "before_block_id": .string(mergedID),
            ])
            #expect(moved.isError != true, "\(text(moved))")
            #expect(try await h.database.read { try Queries.renderedText($0, containerID: note.id) }
                    == "Closing.\n\nOne sentence.\nAnother sentence.")
            let across = try await call(connection, "move_block", [
                "block_id": .string(second.block.id), "note_id": .string(other.id), "at": .string("start"),
            ])
            #expect(across.isError != true, "\(text(across))")
            #expect(try await h.database.read { try Queries.renderedText($0, containerID: other.id) } == "Closing.")
            #expect(h.undoStack.topLabel == "claude-code's move")
            // …but never into a note the grant does not reach.
            let escaped = try await call(connection, "move_block", [
                "block_id": .string(second.block.id), "note_id": .string(outside.id),
            ])
            #expect(escaped.isError == true && text(escaped).hasPrefix("That note isn't shared with this client"))
            #expect(try await h.database.read { try Queries.renderedText($0, containerID: outside.id) } == "")

            // set_block_name, delete_block.
            let named = try json(try await call(connection, "set_block_name", [
                "block_id": .string(mergedID), "name": .string("the opening"),
            ]))
            #expect(named["name"] as? String == "the opening" && named["changed"] as? Bool == true)
            let deleted = try await call(connection, "delete_block", ["block_id": .string(second.block.id)])
            #expect(deleted.isError != true, "\(text(deleted))")
            #expect(try await h.database.read { try Block.fetchOne($0, key: second.block.id) }?.deletedAt != nil,
                    "a tombstone — the tray catches it")
            #expect(h.undoStack.topLabel == "claude-code's delete")

            // ⌥⌘Z walks the session back one act at a time, newest first.
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's delete")
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's block name")
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's move")
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's move")
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's merge")
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's divide")
            #expect(try await h.database.read { try Queries.renderedText($0, containerID: note.id) }
                    == "One sentence. Another sentence.\n\nClosing.", "her note, exactly as it was")
            await h.hangUp(connection)
        }
    }

    // MARK: - THE PROOF, edit half: suggest and write new cannot reach the edit rung

    /// **A SUGGEST OR WRITE-NEW GRANT PROVABLY CANNOT REACH `edit_take` OR THE
    /// STRUCTURAL TOOLS** (the verification bar, U1/U2's pin discipline): a
    /// client holding each rung below edit on the whole wing calls every edit
    /// tool aimed at her takes and blocks — each refuses at the rung, and
    /// every take, placement, block (its name and default) and commit is
    /// byte-identical after.
    @Test func aSuggestOrWriteNewGrantProvablyCannotReachTheEditRung() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "hers")
            let other = try h.operations.createPost(title: "her other note")
            let one = try h.operations.newBlock(in: note.id, text: "Her first paragraph. Its end.", registeringUndo: false)
            let two = try h.operations.newBlock(in: note.id, text: "Her second.", registeringUndo: false)
            let branch = try h.operations.branchVariant(one.block.id, from: one.variant.id)
            try h.operations.autosave(branch.id, text: "her other take", charDelta: 3)
            func snapshot() throws -> [String] {
                try h.database.read { db in
                    try ["variant", "container_block", "block", "commit_point"].flatMap { table in
                        try Row.fetchAll(db, sql: "SELECT * FROM \(table) ORDER BY id").map(\.description)
                    }
                }
            }
            let before = try snapshot()
            let connection = try await h.connect(as: "claude-code")
            let calls: [(String, [String: Value])] = [
                ("edit_take", ["take_id": .string(one.variant.id), "text": .string("x"),
                               "expected_text": .string("Her first paragraph. Its end.")]),
                ("edit_take", ["take_id": .string(branch.id), "text": .string("x"), "expected_text": .string("her other take")]),
                ("divide_block", ["block_id": .string(one.block.id), "second_half_starts_with": .string("Its end.")]),
                ("merge_blocks", ["first_block_id": .string(one.block.id), "second_block_id": .string(two.block.id)]),
                ("move_block", ["block_id": .string(two.block.id), "before_block_id": .string(one.block.id)]),
                ("move_block", ["block_id": .string(two.block.id), "note_id": .string(other.id)]),
                ("delete_block", ["block_id": .string(two.block.id)]),
                ("set_block_name", ["block_id": .string(one.block.id), "name": .string("renamed")]),
            ]
            #expect(Set(calls.map(\.0)) == editTools, "every edit door was tried")
            _ = try h.approve("claude-code", spec(.suggest, .wing, ""))
            for rung in [MCPGrantRule.Rung.suggest, .writeNew] {
                if rung == .writeNew {
                    _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.writeNew, .wing, ""))
                }
                let listed = Set(try await connection.client.listTools().tools.map(\.name))
                #expect(listed.isDisjoint(with: editTools), "\(rung): no edit door is even offered")
                for (name, arguments) in calls {
                    let result = try await call(connection, name, arguments)
                    #expect(result.isError == true, "\(name) refuses under \(rung)")
                    #expect(text(result).hasPrefix("This client may only "), "the rung's own refusal: \(text(result))")
                }
            }
            #expect(try snapshot() == before, "every take, placement, block and commit is byte-identical")
            #expect(h.undoStack.depth == 0)
            await h.hangUp(connection)
        }
    }

    // MARK: - create_note's either payload (R-13nb-11 G-2 + R-13nb-26 (b))

    @Test func createNoteTakesTheStructuredPayloadAndItsDateAndReadsBackAsWritten() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "old journals", kind: .book)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, book.id))
            let both = try await call(connection, "create_note", [
                "text": .string("x"), "blocks": .array([]), "book_id": .string(book.id),
            ])
            #expect(both.isError == true && text(both).contains("not both"))
            let badDate = try await call(connection, "create_note", [
                "text": .string("x"), "entry_date": .string("2019-02-30"), "book_id": .string(book.id),
            ])
            #expect(badDate.isError == true && text(badDate).contains("yyyy-MM-dd"))

            let created = try await call(connection, "create_note", [
                "title": .string("march 4, 2019"), "entry_date": .string("2019-03-04"), "book_id": .string(book.id),
                "blocks": .array([
                    .object(["text": .string("Woke early.\n\nThe kettle, the window."), "name": .string("morning")]),
                    .object(["text": .string("Went out."),
                             "takes": .array([.object(["text": .string("Fui embora."), "label": .string("pt")])])]),
                ]),
            ])
            #expect(created.isError != true, "\(text(created))")
            let noteID = try #require(try json(created)["note_id"] as? String)
            let read = try json(try await call(connection, "read_note", ["note_id": .string(noteID), "with_ids": .bool(true)]))
            let blocks = try #require(read["blocks"] as? [[String: Any]])
            #expect(blocks.map { $0["text"] as? String } == ["Woke early.\n\nThe kettle, the window.", "Went out."])
            #expect(blocks.first?["name"] as? String == "morning")
            #expect((blocks.last?["takes"] as? [[String: Any]])?.last?["label"] as? String == "pt")
            #expect(read["entry_date"] as? String == "2019-03-04")
            #expect(h.undoStack.topLabel == "claude-code's note")
            await h.hangUp(connection)
        }
    }

    // MARK: - Format v2 on the wire, both ways (R-13nb-26 (a))

    @Test func theWireSpeaksFormatV2BothWaysThroughTheOneParser() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "letters", kind: .book)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, book.id))
            let document = "{v:2} {t:\"to K\"}\n\nDear K,\n\nIt has been a year.\n\n"
                + VariorumDocument.blockMarker + "\n\nYours."
            let imported = try await call(connection, "import_document", [
                "document": .string(document), "book_id": .string(book.id),
            ])
            #expect(imported.isError != true, "\(text(imported))")
            let answer = try json(imported)
            let noteID = try #require(answer["note_id"] as? String)
            #expect((answer["block_ids"] as? [String])?.count == 2, "the multi-paragraph block lands as ONE block")
            let read = try await call(connection, "read_note", ["note_id": .string(noteID)])
            #expect(text(read) == document, "read_note speaks it back byte for byte")
            await h.hangUp(connection)
        }
    }

    // MARK: - ONCE on the edit rung: spent inside the act's own transaction

    @Test func aOnceEditGrantAuthorizesExactlyOneEditCallAndARefusedActNeverSpendsIt() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "graded")
            let seeded = try h.operations.newBlock(in: note.id, text: "my answer", registeringUndo: false)
            let spare = try h.operations.newBlock(in: note.id, text: "spare", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .note, note.id, .once))
            // A REFUSED act (a stale read) rolls its spend back with it.
            let stale = try await call(connection, "edit_take", [
                "take_id": .string(seeded.variant.id), "text": .string("B+"), "expected_text": .string("not what it says"),
            ])
            #expect(stale.isError == true)
            let first = try await call(connection, "edit_take", [
                "take_id": .string(seeded.variant.id), "text": .string("B+"), "expected_text": .string("my answer"),
            ])
            #expect(first.isError != true, "the refused call did not spend the grant: \(text(first))")
            let second = try await call(connection, "delete_block", ["block_id": .string(spare.block.id)])
            #expect(second.isError == true, "one write means one write — the once grant is spent")
            #expect(try await h.database.read { try Block.fetchOne($0, key: spare.block.id) }?.deletedAt == nil)
            await h.hangUp(connection)
        }
    }

    // MARK: - THE GUARD closes the decide/act gap (the U2 ladder's F2)

    /// The server's snapshot decision ALLOWED this edit; then — as a sync
    /// apply would — the note was marked Private before the act's
    /// transaction opened. The act re-decides inside its own transaction and
    /// refuses whole: nothing written, no undo entry, the Private words.
    @Test func aFenceLandingAfterTheDecisionIsCaughtInsideTheActsTransaction() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let note = try h.operations.createPost(title: "ch 1")
            _ = try h.operations.addPostToReading(note.id, to: book.id)
            let seeded = try h.operations.newBlock(in: note.id, text: "hers", registeringUndo: false)
            _ = try h.operations.recordMCPContact(name: "claude-code", version: "1")
            _ = try h.approve("claude-code", spec(.edit, .book, book.id))
            let tools = MCPWriteTools(
                database: h.database, grants: h.operations, executor: SeededExecutor(operations: h.writeOperations))
            let snapshot = try await h.database.read { db in
                MCPGrantAuthority.decide(
                    try MCPGrantAuthority.standing(db, clientName: "claude-code"),
                    note: try Queries.mcpNoteFacts(db, noteID: note.id), rung: .edit, consumes: true)
            }
            #expect(snapshot.isAllowed, "the decision a snapshot made")

            try h.operations.setNotePrivate(note.id, true)  // lands between the two
            let guarded = tools.guardEdit("claude-code") { db in
                [try Queries.mcpContainerOf(take: seeded.variant.id, db)]
            }
            do {
                try h.writeOperations.editTakeUnderInsurance(
                    seeded.variant.id, text: "past the fence", expectedText: "hers", client: "claude-code",
                    undoLabel: "claude-code's edit", guardedBy: guarded)
                Issue.record("the act landed past a fence closed after the decision")
            } catch let refused as MCPWriteTools.Refused {
                #expect(refused.outcome.text.contains("marked Private"))
            }
            #expect(try await h.database.read { try Queries.renderedText($0, containerID: note.id) } == "hers")
            #expect(try await h.database.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM commit_point WHERE variant_id = ?", arguments: [seeded.variant.id])
            } == 0)
            #expect(h.undoStack.depth == 0)
        }
    }
}
