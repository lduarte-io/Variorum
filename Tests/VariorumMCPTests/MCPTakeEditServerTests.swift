import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-184 U4 — VX-195, THE TAKES FAMILY at EDIT (R-VX184-1): `delete_take` —
// and deleting a block's LAST take deletes the BLOCK, `delete_block`'s road,
// said in the answer and the receipt — `archive_take`, `unarchive_take`,
// `set_take_label`, `lock_take`, `unlock_take`. Each is her take door's row
// work (`deleteVariant`, `archiveVariant`, `unarchiveVariant`, `setTakeLabel`,
// `lockVariant`/`unlockVariant`) behind the grant guard, ONE client-named undo
// entry each. Written BEFORE the fix: on the pre-fix tree every tool here
// answers "Unknown tool".

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

@Suite("VX-195 — the takes family at edit: delete (the last take ⇒ the block), archive, label, lock", .serialized)
struct MCPTakeEditServerTests {
    /// A note in a book: block 1 fanned (her chosen take + a second take),
    /// block 2 one take, block 3 one ACTIVE take and one ARCHIVED.
    private struct World {
        let book: Reading
        let note: Container
        let block1: String
        let hers1: String
        let other1: String
        let block2: String
        let hers2: String
        let block3: String
        let hers3: String
        let archived3: String
    }

    private func world(_ h: ServerHarness) throws -> World {
        let book = try h.operations.createReading(name: "drafts", kind: .book)
        let note = try h.operations.createPost(title: "ch 1")
        _ = try h.operations.addPostToReading(note.id, to: book.id)
        let one = try h.operations.newBlock(in: note.id, text: "Her opening.", registeringUndo: false)
        let other = try h.operations.branchVariant(one.block.id, from: one.variant.id)
        try h.operations.autosave(other.id, text: "A bolder opening.", charDelta: 4)
        let two = try h.operations.newBlock(in: note.id, text: "Her close.", registeringUndo: false)
        let three = try h.operations.newBlock(in: note.id, text: "Her coda.", registeringUndo: false)
        let old = try h.operations.branchVariant(three.block.id, from: three.variant.id)
        try h.operations.autosave(old.id, text: "An older coda.", charDelta: 3)
        try h.operations.archiveVariant(old.id)
        return World(book: book, note: note, block1: one.block.id, hers1: one.variant.id, other1: other.id,
                     block2: two.block.id, hers2: two.variant.id, block3: three.block.id, hers3: three.variant.id,
                     archived3: old.id)
    }

    /// One take's row facts, read fresh.
    private struct TakeFacts: Sendable {
        let status: String
        let label: String?
        let locked: Bool
        let deletedAt: String?
    }

    private func take(_ h: ServerHarness, _ id: String) async throws -> TakeFacts {
        try await h.database.read { db in
            let row = try #require(try Row.fetchOne(
                db, sql: "SELECT status, label, locked, deleted_at FROM variant WHERE id = ?", arguments: [id]))
            return TakeFacts(status: row["status"], label: row["label"], locked: row["locked"], deletedAt: row["deleted_at"])
        }
    }

    private func isDead(_ h: ServerHarness, block id: String) async throws -> Bool {
        try await h.database.read { db in
            try String.fetchOne(db, sql: "SELECT deleted_at FROM block WHERE id = ?", arguments: [id]) != nil
        }
    }

    private func rendered(_ h: ServerHarness, _ noteID: String) async throws -> String {
        try await h.database.read { try Queries.renderedText($0, containerID: noteID) }
    }

    // MARK: - delete_take

    /// A take that is NOT the block's last goes alone — her `deleteVariant`,
    /// one client-named entry, her ⌥⌘Z puts it back.
    @Test func deleteTakeDeletesOneTakeAsOneUndo() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, w.book.id))

            let deleted = try await call(connection, "delete_take", ["take_id": .string(w.other1)])
            #expect(deleted.isError != true, "\(text(deleted))")
            let answer = try json(deleted)
            #expect(answer["deleted_block"] as? Bool == false && answer["block_id"] as? String == w.block1)
            #expect((try await take(h, w.other1).deletedAt) != nil)
            #expect(try await isDead(h, block: w.block1) == false)
            #expect(h.undoStack.depth == 1 && h.undoStack.topLabel == "claude-code's take deletion")
            #expect(h.receipts.value.last?.act.rawValue == "take deletion")

            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's take deletion")
            #expect((try await take(h, w.other1).deletedAt) == nil, "her ⌥⌘Z puts it back")
            #expect(try h.undoStack.redo(with: h.writeOperations) == "claude-code's take deletion")
            #expect((try await take(h, w.other1).deletedAt) != nil)
            await h.hangUp(connection)
        }
    }

    /// R-VX184-1: the block's LAST take deleted IS the block deleted —
    /// `delete_block`'s road exactly (the tray holds it, archived takes and
    /// all; the entry is "‹client›'s delete"), said in the answer, the receipt
    /// and Activity. I10 holds because the block goes.
    @Test func deletingTheLastTakeDeletesTheBlockByDeleteBlocksRoad() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, w.book.id))

            let deleted = try await call(connection, "delete_take", ["take_id": .string(w.hers2)])
            #expect(deleted.isError != true, "\(text(deleted))")
            #expect(try json(deleted)["deleted_block"] as? Bool == true)
            #expect(try await isDead(h, block: w.block2), "the block went, as delete_block's does")
            #expect(try await rendered(h, w.note.id) == "Her opening.\n\nHer coda.")
            #expect(h.undoStack.topLabel == "claude-code's delete", "delete_block's own entry")
            let receipt = try #require(h.receipts.value.last)
            #expect(receipt.act == .delete && receipt.detail == "its last take", "the receipt says why the block went")
            let activity = try await h.database.read { try Queries.mcpActivity($0, limit: 1) }
            #expect(activity.first?.act == "delete_take" && activity.first?.targetKind == "block"
                    && activity.first?.targetID == w.block2, "Activity logs the block")

            // One active take beside an archived one: the active is the last —
            // the block goes, the archived take with it (to the tray).
            let again = try await call(connection, "delete_take", ["take_id": .string(w.hers3)])
            #expect(try json(again)["deleted_block"] as? Bool == true)
            #expect(try await isDead(h, block: w.block3))
            #expect((try await take(h, w.archived3).deletedAt) != nil, "every take rode with the block")

            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's delete")
            #expect(try await isDead(h, block: w.block3) == false, "her ⌥⌘Z puts the block back")
            #expect((try await take(h, w.archived3).deletedAt) == nil)
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's delete")
            #expect(try await rendered(h, w.note.id) == "Her opening.\n\nHer close.\n\nHer coda.")
            await h.hangUp(connection)
        }
    }

    /// Where her own delete refuses, this one does: the CHOSEN take (choose
    /// another first) and a LOCKED take — a locked LAST take too (the lock
    /// guards the take; `delete_block` is the explicit road for a block).
    @Test func deleteTakeRefusesTheChosenAndTheLockedAsHerDoorDoes() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            try h.operations.lockVariant(w.other1)
            try h.operations.lockVariant(w.hers2)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, w.book.id))
            let chosen = try await call(connection, "delete_take", ["take_id": .string(w.hers1)])
            #expect(chosen.isError == true && text(chosen).contains("variantIsChosen"), "\(text(chosen))")
            for locked in [w.other1, w.hers2] {
                let refused = try await call(connection, "delete_take", ["take_id": .string(locked)])
                #expect(refused.isError == true && text(refused).contains("lockedVariant"), "\(text(refused))")
            }
            #expect(try await isDead(h, block: w.block2) == false)
            #expect(try await rendered(h, w.note.id) == "Her opening.\n\nHer close.\n\nHer coda.")
            #expect(h.undoStack.depth == 0 && h.receipts.value.isEmpty)
            await h.hangUp(connection)
        }
    }

    // MARK: - archive_take / unarchive_take

    @Test func archiveAndUnarchiveATakeEachOneUndo() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, w.book.id))

            let archived = try await call(connection, "archive_take", ["take_id": .string(w.other1)])
            #expect(archived.isError != true, "\(text(archived))")
            #expect(try json(archived)["changed"] as? Bool == true)
            #expect(try await take(h, w.other1).status == "archived")
            #expect(h.undoStack.topLabel == "claude-code's take archiving")
            #expect(h.receipts.value.last?.act.rawValue == "take archiving")
            let again = try json(try await call(connection, "archive_take", ["take_id": .string(w.other1)]))
            #expect(again["changed"] as? Bool == false && h.undoStack.depth == 1, "already archived: nothing to do")

            let last = try await call(connection, "archive_take", ["take_id": .string(w.hers2)])
            #expect(last.isError == true && text(last).contains("lastActiveVariant"),
                    "I10: archiving the last take is refused, never turned into a delete: \(text(last))")

            let back = try await call(connection, "unarchive_take", ["take_id": .string(w.archived3)])
            #expect(back.isError != true, "\(text(back))")
            #expect(try await take(h, w.archived3).status == "active")
            #expect(h.undoStack.topLabel == "claude-code's take unarchiving")
            #expect(h.receipts.value.last?.act.rawValue == "take unarchiving")

            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's take unarchiving")
            #expect(try await take(h, w.archived3).status == "archived")
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's take archiving")
            #expect(try await take(h, w.other1).status == "active")
            await h.hangUp(connection)
        }
    }

    // MARK: - set_take_label

    @Test func setTakeLabelNamesAnyTakeAsOneUndo() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            try h.operations.lockVariant(w.hers2)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, w.book.id))

            let labeled = try await call(connection, "set_take_label", [
                "take_id": .string(w.other1), "label": .string("  a bolder cut  "),
            ])
            #expect(labeled.isError != true, "\(text(labeled))")
            #expect(try json(labeled)["label"] as? String == "a bolder cut")
            #expect(try await take(h, w.other1).label == "a bolder cut", "as given, trimmed — her door's rule")
            #expect(h.undoStack.topLabel == "claude-code's take label")
            #expect(h.receipts.value.last?.detail == "a bolder cut")
            let same = try json(try await call(connection, "set_take_label", [
                "take_id": .string(w.other1), "label": .string("a bolder cut"),
            ]))
            #expect(same["changed"] as? Bool == false && h.undoStack.depth == 1)
            let cleared = try json(try await call(connection, "set_take_label", [
                "take_id": .string(w.other1), "label": .null,
            ]))
            #expect(cleared["changed"] as? Bool == true && cleared["label"] is NSNull)
            #expect(try await take(h, w.other1).label == nil)
            let onLocked = try await call(connection, "set_take_label", [
                "take_id": .string(w.hers2), "label": .string("kept"),
            ])
            #expect(onLocked.isError != true, "a lock guards the buffer, never the name: \(text(onLocked))")

            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's take label")
            #expect(try await take(h, w.hers2).label == nil)
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's take label")
            #expect(try await take(h, w.other1).label == "a bolder cut")
            await h.hangUp(connection)
        }
    }

    // MARK: - lock_take / unlock_take

    /// Her lock: a take with unsaved words is insured by one quiet commit
    /// before it locks (the commit stays when ⌥⌘Z unlocks it — commits stay).
    @Test func lockAndUnlockATakeEachOneUndo() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, w.book.id))
            func commits(_ id: String) async throws -> Int {
                try await h.database.read { db in
                    try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM commit_point WHERE variant_id = ?", arguments: [id]) ?? 0
                }
            }

            let locked = try await call(connection, "lock_take", ["take_id": .string(w.other1)])
            #expect(locked.isError != true, "\(text(locked))")
            #expect(try json(locked)["locked"] as? Bool == true)
            #expect(try await take(h, w.other1).locked == true)
            #expect(try await commits(w.other1) == 1, "the unsaved words insured first, as her lock does")
            #expect(h.undoStack.topLabel == "claude-code's take lock")
            let again = try json(try await call(connection, "lock_take", ["take_id": .string(w.other1)]))
            #expect(again["changed"] as? Bool == false && h.undoStack.depth == 1)

            let editRefused = try await call(connection, "edit_take", [
                "take_id": .string(w.other1), "text": .string("x"), "expected_text": .string("A bolder opening."),
            ])
            #expect(editRefused.isError == true, "the lock guards the buffer")

            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's take lock")
            #expect(try await take(h, w.other1).locked == false)
            #expect(try await commits(w.other1) == 1, "the insurance commit stays")

            try h.operations.lockVariant(w.hers2)
            let unlocked = try await call(connection, "unlock_take", ["take_id": .string(w.hers2)])
            #expect(unlocked.isError != true, "\(text(unlocked))")
            #expect(try await take(h, w.hers2).locked == false)
            #expect(h.undoStack.topLabel == "claude-code's take unlock")
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's take unlock")
            #expect(try await take(h, w.hers2).locked == true)
            await h.hangUp(connection)
        }
    }

    // MARK: - The rung and the one answer

    @Test func belowEditTheRungRefusesAndOutsideTheGrantIsTheOneAnswer() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let outside = try h.operations.createPost(title: "not shared")
            let theirs = try h.operations.newBlock(in: outside.id, text: "Elsewhere.", registeringUndo: false)
            let theirOther = try h.operations.branchVariant(theirs.block.id, from: theirs.variant.id)
            let deadTake = try h.operations.branchVariant(w.block1, from: w.hers1)
            try h.operations.deleteVariant(deadTake.id)
            let tools = ["delete_take", "archive_take", "unarchive_take", "set_take_label", "lock_take", "unlock_take"]
            func arguments(_ tool: String, _ take: String) -> [String: Value] {
                tool == "set_take_label" ? ["take_id": .string(take), "label": .string("x")] : ["take_id": .string(take)]
            }

            let maker = try await h.connect(as: "maker")
            _ = try h.approve("maker", spec(.writeNew, .book, w.book.id))
            for tool in tools {
                let refused = try await call(maker, tool, arguments(tool, w.other1))
                #expect(refused.isError == true
                        && text(refused).hasPrefix("This client may only read, suggest and write new here."),
                        "\(tool): \(text(refused))")
            }
            #expect(h.asks.value.last?.clientName == "maker" && h.asks.value.last?.rung == .edit)
            await h.hangUp(maker)

            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, w.book.id))
            let unshared = MCPRefusalCopy.words(.notShared, .note)
            for tool in tools {
                for id in [theirOther.id, deadTake.id, "no-such-take"] {
                    let refused = try await call(connection, tool, arguments(tool, id))
                    #expect(refused.isError == true && text(refused) == unshared, "\(tool) \(id): \(text(refused))")
                }
            }
            #expect(try await rendered(h, w.note.id) == "Her opening.\n\nHer close.\n\nHer coda.")
            #expect((try await take(h, theirOther.id).deletedAt) == nil)
            #expect(h.undoStack.depth == 0 && h.receipts.value.isEmpty)
            await h.hangUp(connection)
        }
    }
}
