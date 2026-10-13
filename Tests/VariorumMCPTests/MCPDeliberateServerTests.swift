import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-168 U2 — THE EDIT RUNG's DELIBERATE ACTS END TO END, over a real socket
// driven by the SDK's own `Client` (U1's harness; every connection presents
// its name's own setup key — Unit 1's `connect(as:)`). VX-169's `save_commit`
// lands her commit with the client's name prefixed and NO undo entry;
// VX-174's `choose_take` and `adopt_lens` (R-MERGE-1) land her ✓ and her "✓
// Make this the note", ONE client-named undo each; every act answers the one
// not-shared answer outside its grant (no oracle), spends a once grant
// exactly once, and is re-decided inside its own transaction.

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

@Suite("VX-168 U2 — save_commit, choose_take and adopt_lens end to end", .serialized)
struct MCPDeliberateServerTests {
    /// A note in a book: block 1 fanned (her take + a second take), block 2
    /// plain, and a lens showing the second take on block 1.
    private struct World {
        let book: Reading
        let note: Container
        let block1: String
        let hers1: String
        let other1: String
        let hers2: String
        let lensID: String
    }

    private func world(_ h: ServerHarness) throws -> World {
        let book = try h.operations.createReading(name: "drafts", kind: .book)
        let note = try h.operations.createPost(title: "ch 1")
        _ = try h.operations.addPostToReading(note.id, to: book.id)
        let one = try h.operations.newBlock(in: note.id, text: "Her opening.", registeringUndo: false)
        let other = try h.operations.branchVariant(one.block.id, from: one.variant.id)
        try h.operations.autosave(other.id, text: "A bolder opening.", charDelta: 4)
        let two = try h.operations.newBlock(in: note.id, text: "Her close.", registeringUndo: false)
        let lens = try h.operations.createLens(post: note.id, name: "the bold cut")
        _ = try h.operations.setLensChoice(lens: lens.id, block: one.block.id, variant: other.id)
        return World(book: book, note: note, block1: one.block.id, hers1: one.variant.id, other1: other.id,
                     hers2: two.variant.id, lensID: lens.id)
    }

    private func rendered(_ h: ServerHarness, _ noteID: String) async throws -> String {
        try await h.database.read { try Queries.renderedText($0, containerID: noteID) }
    }

    // MARK: - VX-169: save_commit

    @Test func saveCommitLandsHerCommitWithTheClientsNameAndNoUndoEntry() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, w.book.id))

            let missing = try await call(connection, "save_commit", ["take_id": .string(w.hers1)])
            #expect(missing.isError == true && text(missing) == "message is required.")
            let blank = try await call(connection, "save_commit", ["take_id": .string(w.hers1), "message": .string("  ")])
            #expect(blank.isError == true, "a blank message is no message")

            let saved = try await call(connection, "save_commit", [
                "take_id": .string(w.hers1), "message": .string("fact-checked, no changes"),
            ])
            #expect(saved.isError != true, "\(text(saved))")
            let answer = try json(saved)
            let commitID = try #require(answer["commit_id"] as? String)
            #expect(answer["message"] as? String == "claude-code: fact-checked, no changes")
            #expect(answer["block_id"] as? String == w.block1 && answer["note_id"] as? String == w.note.id)
            let row = try await h.database.read { db -> [String]? in
                try Row.fetchOne(db, sql: "SELECT kind, text, variant_id FROM commit_point WHERE id = ?",
                                 arguments: [commitID])
                    .map { [$0["kind"], $0["text"], $0["variant_id"]] }
            }
            #expect(row == ["manual", "Her opening.", w.hers1], "the settled kind, the take's text, the take")
            #expect(h.undoStack.depth == 0, "append-only: no undo entry, as her own commit")
            #expect(h.receipts.value.last?.act == .commit && h.receipts.value.last?.act.isUndoable == false)

            // Her history reads it back, by the client's name.
            let read = try json(try await call(connection, "read_note", [
                "note_id": .string(w.note.id), "with_commits": .bool(true),
            ]))
            let take = try #require(((read["blocks"] as? [[String: Any]])?.first?["takes"] as? [[String: Any]])?
                .first { $0["take_id"] as? String == w.hers1 })
            #expect((take["commits"] as? [[String: Any]])?.first?["message"] as? String
                    == "claude-code: fact-checked, no changes")

            // Where her commit refuses, this one does — the op's own words.
            try h.operations.lockVariant(w.hers2)
            let locked = try await call(connection, "save_commit", ["take_id": .string(w.hers2), "message": .string("x")])
            #expect(locked.isError == true && text(locked).contains("lockedVariant"), "\(text(locked))")
            await h.hangUp(connection)
        }
    }

    // MARK: - VX-174: choose_take

    @Test func chooseTakeIsHerCheckmarkOneClientNamedUndo() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, w.book.id))

            let chosen = try await call(connection, "choose_take", ["take_id": .string(w.other1)])
            #expect(chosen.isError != true, "\(text(chosen))")
            #expect(try json(chosen)["changed"] as? Bool == true)
            #expect(try await rendered(h, w.note.id) == "A bolder opening.\n\nHer close.")
            #expect(h.undoStack.topLabel == "claude-code's take choice")
            #expect(h.receipts.value.last?.act == .choice)
            #expect(try await h.database.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM commit_point")
            } == 0, "a pointer move writes no text and no commit")

            let again = try json(try await call(connection, "choose_take", ["take_id": .string(w.other1)]))
            #expect(again["changed"] as? Bool == false, "the take already shown: nothing to do")
            #expect(h.undoStack.depth == 1 && h.receipts.value.count == 1, "no second entry, no second receipt")

            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's take choice")
            #expect(try await rendered(h, w.note.id) == "Her opening.\n\nHer close.", "her take, chosen again")
            await h.hangUp(connection)
        }
    }

    // MARK: - VX-174: adopt_lens

    @Test func adoptLensMakesTheLensTheNoteKeepsWhatItShowedAndUndoesWhole() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, w.book.id))

            let adopted = try await call(connection, "adopt_lens", ["lens_id": .string(w.lensID)])
            #expect(adopted.isError != true, "\(text(adopted))")
            let answer = try json(adopted)
            #expect(answer["changed"] as? Bool == true && answer["chose"] as? Int == 1)
            let keptID = try #require(answer["kept_as_lens_id"] as? String)
            #expect((answer["kept_as"] as? String)?.hasPrefix("chosen until ") == true, "her door's preservation lens")
            #expect(try await rendered(h, w.note.id) == "A bolder opening.\n\nHer close.")
            #expect(h.undoStack.topLabel == "claude-code's lens adoption")
            #expect(h.receipts.value.last?.act == .lensAdoption && h.receipts.value.last?.detail == "the bold cut")

            // The note's lenses: the adopted one and the one that kept her chosen.
            func lensIDs() async throws -> Set<String> {
                let read = try json(try await call(connection, "read_note", [
                    "note_id": .string(w.note.id), "with_lenses": .bool(true),
                ]))
                return Set(((read["lenses"] as? [[String: Any]]) ?? []).compactMap { $0["lens_id"] as? String })
            }
            #expect(try await lensIDs() == [w.lensID, keptID])

            // A lens that already agrees: nothing to do.
            let agree = try json(try await call(connection, "adopt_lens", ["lens_id": .string(w.lensID)]))
            #expect(agree["changed"] as? Bool == false && agree["kept_as_lens_id"] == nil)
            #expect(h.undoStack.depth == 1)

            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's lens adoption")
            #expect(try await rendered(h, w.note.id) == "Her opening.\n\nHer close.", "her note, exactly as it was")
            #expect(try await lensIDs() == [w.lensID], "the lens the act made walks back with it")
            #expect(try h.undoStack.redo(with: h.writeOperations) == "claude-code's lens adoption")
            #expect(try await lensIDs() == [w.lensID, keptID])
            await h.hangUp(connection)
        }
    }

    // MARK: - One answer outside the grant (no oracle)

    /// A take or a lens in a note the grant does not reach answers EXACTLY
    /// what a dead id and an id naming nothing answer — and writes nothing.
    @Test func outsideTheGrantEveryActAnswersTheOneNotSharedAnswer() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let outside = try h.operations.createPost(title: "not shared")
            let theirs = try h.operations.newBlock(in: outside.id, text: "Elsewhere.", registeringUndo: false)
            let theirLens = try h.operations.createLens(post: outside.id, name: "theirs")
            let deadLens = try h.operations.createLens(post: w.note.id, name: "gone")
            try h.operations.deleteLens(deadLens.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, w.book.id))
            let unshared = MCPRefusalCopy.words(.notShared, .note)
            let calls: [(String, [String: Value])] = [
                ("save_commit", ["take_id": .string(theirs.variant.id), "message": .string("x")]),
                ("save_commit", ["take_id": .string("no-such-take"), "message": .string("x")]),
                ("choose_take", ["take_id": .string(theirs.variant.id)]),
                ("choose_take", ["take_id": .string("no-such-take")]),
                ("adopt_lens", ["lens_id": .string(theirLens.id)]),
                ("adopt_lens", ["lens_id": .string(deadLens.id)]),
                ("adopt_lens", ["lens_id": .string("no-such-lens")]),
            ]
            for (name, arguments) in calls {
                let result = try await call(connection, name, arguments)
                #expect(result.isError == true && text(result) == unshared, "\(name) \(arguments): \(text(result))")
            }
            #expect(try await h.database.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM commit_point")
            } == 0)
            #expect(h.undoStack.depth == 0 && h.receipts.value.isEmpty)
            await h.hangUp(connection)
        }
    }

    // MARK: - Her refusals, in her words

    @Test func underASealEachActRefusesAsHerDoorDoes() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, w.book.id))
            try h.operations.lockPost(w.note.id)
            for (name, arguments): (String, [String: Value]) in [
                ("save_commit", ["take_id": .string(w.hers1), "message": .string("x")]),
                ("choose_take", ["take_id": .string(w.other1)]),
                ("adopt_lens", ["lens_id": .string(w.lensID)]),
            ] {
                let result = try await call(connection, name, arguments)
                #expect(result.isError == true && text(result).contains("lockedPost"), "\(name): \(text(result))")
            }
            #expect(try await rendered(h, w.note.id) == "Her opening.\n\nHer close.")
            #expect(h.undoStack.depth == 0)
            await h.hangUp(connection)
        }
    }

    // MARK: - ONCE: spent inside the act's own transaction

    @Test func aOnceEditGrantIsSpentByOneDeliberateActAndARefusedActSpendsNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let archived = try h.operations.branchVariant(w.block1, from: w.hers1)
            try h.operations.archiveVariant(archived.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .note, w.note.id, .once))
            let refused = try await call(connection, "choose_take", ["take_id": .string(archived.id)])
            #expect(refused.isError == true && text(refused).contains("archivedVariant"), "\(text(refused))")
            let first = try await call(connection, "save_commit", [
                "take_id": .string(w.hers1), "message": .string("before the review"),
            ])
            #expect(first.isError != true, "the refused act did not spend the grant: \(text(first))")
            let second = try await call(connection, "adopt_lens", ["lens_id": .string(w.lensID)])
            #expect(second.isError == true, "one write means one write — the once grant is spent")
            #expect(try await rendered(h, w.note.id) == "Her opening.\n\nHer close.")
            await h.hangUp(connection)
        }
    }

    // MARK: - THE GUARD closes the decide/act gap

    /// The snapshot ALLOWED each act; then — as a sync apply would — the note
    /// was marked Private before the act's transaction opened. Each act
    /// re-decides inside its own transaction and refuses whole, with the one
    /// answer: nothing written, no undo entry.
    @Test func aFenceLandingAfterTheDecisionIsCaughtInsideEachActsTransaction() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            _ = try h.operations.recordMCPContact(name: "claude-code", version: "1")
            _ = try h.approve("claude-code", spec(.edit, .book, w.book.id))
            let tools = MCPWriteTools(
                database: h.database, grants: h.operations, executor: SeededExecutor(operations: h.writeOperations))
            try h.operations.setNotePrivate(w.note.id, true)  // lands after the snapshot
            let byTake = tools.guardEdit("claude-code") { db in [try Queries.mcpContainerOf(take: w.hers1, db)] }
            let byLens = tools.guardEdit("claude-code") { db in [try Queries.mcpContainerOf(lens: w.lensID, db)] }
            let acts: [(String, () throws -> Void)] = [
                ("save_commit", { _ = try h.writeOperations.commitTakeForClient(
                    w.hers1, message: "x", client: "claude-code", guardedBy: byTake) }),
                ("choose_take", { _ = try h.writeOperations.chooseTake(
                    w.other1, undoLabel: "claude-code's take choice", guardedBy: tools.guardEdit("claude-code") { db in
                        [try Queries.mcpContainerOf(take: w.other1, db)]
                    }) }),
                ("adopt_lens", { _ = try h.writeOperations.adoptLensAsNote(
                    w.lensID, undoLabel: "claude-code's lens adoption", guardedBy: byLens) }),
            ]
            for (name, act) in acts {
                do {
                    try act()
                    Issue.record("\(name) landed past a fence closed after the decision")
                } catch let refused as MCPWriteTools.Refused {
                    #expect(refused.outcome.text == MCPRefusalCopy.words(.notShared, .note), "\(name)")
                }
            }
            #expect(try await rendered(h, w.note.id) == "Her opening.\n\nHer close.")
            #expect(try await h.database.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM commit_point")
            } == 0)
            #expect(try await h.database.read { db in try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM lens") } == 1)
            #expect(h.undoStack.depth == 0)
        }
    }
}
