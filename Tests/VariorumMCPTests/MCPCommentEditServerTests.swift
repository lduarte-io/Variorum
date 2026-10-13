import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-184 U4 — VX-195, THE COMMENTS FAMILY at EDIT (R-VX184-1 — "as capable as
// her at the keyboard"; R-VX188-1's edit clause): `edit_comment` and
// `restore_comment` on ANY comment, and `delete_comment` reaching any comment
// once the client may EDIT the note. Each is her own comment door's row work
// (`editBlockComment`, `restoreBlockComment`, `deleteBlockComment`) behind the
// grant guard, ONE client-named undo entry each; a suggest caller's refusal
// stays her ruled sentence, byte-unchanged (U3's pins stand unmodified).
// Written BEFORE the fix: on the pre-fix tree every new tool answers
// "Unknown tool" and an edit client deleting a comment not on file as its own
// hears her suggest sentence.

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

/// Her ruled words (R-VX188-2), verbatim.
private let herSentence =
    "You don't have permission to delete that comment. Suggest raising your permission level to edit."

@Suite("VX-195 — the comments family at edit: edit, restore and delete any comment", .serialized)
struct MCPCommentEditServerTests {
    private struct World {
        let book: Reading
        let note: Container
        let block: String
        let unshared: Container
        let unsharedBlock: String
    }

    private func world(_ h: ServerHarness) throws -> World {
        let book = try h.operations.createReading(name: "drafts", kind: .book)
        let note = try h.operations.createPost(title: "ch 1")
        _ = try h.operations.addPostToReading(note.id, to: book.id)
        let one = try h.operations.newBlock(in: note.id, text: "Her opening.", registeringUndo: false)
        let unshared = try h.operations.createPost(title: "not shared")
        let hidden = try h.operations.newBlock(in: unshared.id, text: "Elsewhere.", registeringUndo: false)
        return World(book: book, note: note, block: one.block.id, unshared: unshared, unsharedBlock: hidden.block.id)
    }

    private func comment(_ h: ServerHarness, _ id: String) async throws -> (text: String, live: Bool) {
        try await h.database.read { db in
            let row = try #require(try Row.fetchOne(
                db, sql: "SELECT text, deleted_at FROM block_comment WHERE id = ?", arguments: [id]))
            return (row["text"], (row["deleted_at"] as String?) == nil)
        }
    }

    // MARK: - edit_comment

    /// EDIT rewrites ANY comment — hers here — as ONE client-named entry:
    /// her ⌥⌘Z puts her words back, ⇧⌥⌘Z the client's again. The same text
    /// writes nothing; a stale `expected_text` refuses and writes nothing.
    @Test func editCommentRewritesAnyCommentAsOneClientNamedUndo() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let hers = try h.operations.addBlockComment(to: w.block, text: "Her working note.")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, w.book.id))

            let edited = try await call(connection, "edit_comment", [
                "comment_id": .string(hers.id), "text": .string("Her working note, tightened."),
                "expected_text": .string("Her working note."),
            ])
            #expect(edited.isError != true, "\(text(edited))")
            let answer = try json(edited)
            #expect(answer["changed"] as? Bool == true && answer["comment_id"] as? String == hers.id)
            #expect(answer["note_id"] as? String == w.note.id && answer["block_id"] as? String == w.block)
            #expect(try await comment(h, hers.id).text == "Her working note, tightened.")
            #expect(h.undoStack.depth == 1 && h.undoStack.topLabel == "claude-code's comment edit")
            #expect(h.receipts.value.last?.act.rawValue == "comment edit")
            let activity = try await h.database.read { try Queries.mcpActivity($0, limit: 1) }
            #expect(activity.first?.act == "edit_comment" && activity.first?.allowed == true)

            // The same text: nothing to do — no entry, no receipt.
            let same = try json(try await call(connection, "edit_comment", [
                "comment_id": .string(hers.id), "text": .string("Her working note, tightened."),
                "expected_text": .string("Her working note, tightened."),
            ]))
            #expect(same["changed"] as? Bool == false)
            #expect(h.undoStack.depth == 1 && h.receipts.value.count == 1)

            // A stale read refuses and writes nothing.
            let stale = try await call(connection, "edit_comment", [
                "comment_id": .string(hers.id), "text": .string("Something else."),
                "expected_text": .string("Her working note."),
            ])
            #expect(stale.isError == true && text(stale).contains("changed since you read it"), "\(text(stale))")
            #expect(try await comment(h, hers.id).text == "Her working note, tightened.")
            let blank = try await call(connection, "edit_comment", [
                "comment_id": .string(hers.id), "text": .string("  "),
                "expected_text": .string("Her working note, tightened."),
            ])
            #expect(blank.isError == true, "a blank comment is no comment")
            #expect(h.undoStack.depth == 1)

            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's comment edit")
            #expect(try await comment(h, hers.id).text == "Her working note.", "her words, back")
            #expect(try h.undoStack.redo(with: h.writeOperations) == "claude-code's comment edit")
            #expect(try await comment(h, hers.id).text == "Her working note, tightened.")
            await h.hangUp(connection)
        }
    }

    // MARK: - restore_comment

    /// A deleted comment comes back — her restore door's row work — as ONE
    /// client-named entry. A live comment refuses (her op's own refusal); a
    /// comment she chose to delete for good is no longer on her block's
    /// deleted-comments surface, so the client can't bring it back either.
    @Test func restoreCommentBringsADeletedCommentBackAsOneUndo() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let hers = try h.operations.addBlockComment(to: w.block, text: "Her deleted note.")
            try h.operations.deleteBlockComment(hers.id)
            let forGood = try h.operations.addBlockComment(to: w.block, text: "Gone for good.")
            try h.operations.deleteBlockComment(forGood.id)
            _ = try h.operations.requestPurge([SyncPurgeTarget(table: "block_comment", rowID: forGood.id)])
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, w.book.id))

            let restored = try await call(connection, "restore_comment", ["comment_id": .string(hers.id)])
            #expect(restored.isError != true, "\(text(restored))")
            #expect(try json(restored)["note_id"] as? String == w.note.id)
            #expect(try await comment(h, hers.id).live)
            #expect(h.undoStack.depth == 1 && h.undoStack.topLabel == "claude-code's comment restore")
            #expect(h.receipts.value.last?.act.rawValue == "comment restore")

            let live = try await call(connection, "restore_comment", ["comment_id": .string(hers.id)])
            #expect(live.isError == true && text(live).contains("commentNotDeleted"), "\(text(live))")

            let purged = try await call(connection, "restore_comment", ["comment_id": .string(forGood.id)])
            #expect(purged.isError == true && text(purged).contains("isn't among the block's deleted comments"),
                    "\(text(purged))")
            #expect(try await comment(h, forGood.id).live == false)
            #expect(h.undoStack.depth == 1)

            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's comment restore")
            #expect(try await comment(h, hers.id).live == false, "her ⌥⌘Z deletes it again")
            #expect(try h.undoStack.redo(with: h.writeOperations) == "claude-code's comment restore")
            #expect(try await comment(h, hers.id).live)
            await h.hangUp(connection)
        }
    }

    // MARK: - delete_comment, at EDIT (R-VX188-1's edit clause)

    /// EDIT deletes ANY comment — hers and another client's — one client-named
    /// entry each. A SUGGEST or WRITE-NEW caller still hears her ruled sentence,
    /// byte for byte, for a comment not on file as its own.
    @Test func editDeletesAnyCommentWhileLowerRungsHearHerSentence() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let codex = try await h.connect(as: "codex")
            _ = try h.approve("codex", spec(.suggest, .book, w.book.id))
            let theirs = try #require(try json(try await call(codex, "add_comment", [
                "block_id": .string(w.block), "text": .string("codex was here."),
            ]))["comment_id"] as? String)
            let hers = try h.operations.addBlockComment(to: w.block, text: "Her own note.")
            let hersToo = try h.operations.addBlockComment(to: w.block, text: "Her second note.")

            for (name, rung) in [("suggester", MCPGrantRule.Rung.suggest), ("maker", .writeNew)] {
                let lower = try await h.connect(as: name)
                _ = try h.approve(name, spec(rung, .book, w.book.id))
                let refused = try await call(lower, "delete_comment", ["comment_id": .string(hersToo.id)])
                #expect(refused.isError == true && text(refused) == herSentence, "\(name): \(text(refused))")
                await h.hangUp(lower)
            }
            #expect(try await comment(h, hersToo.id).live, "nothing deleted below edit")
            let depth = h.undoStack.depth

            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, w.book.id))
            for commentID in [hers.id, theirs] {
                let deleted = try await call(connection, "delete_comment", ["comment_id": .string(commentID)])
                #expect(deleted.isError != true, "\(text(deleted))")
                #expect(try await comment(h, commentID).live == false)
            }
            #expect(h.undoStack.depth == depth + 2 && h.undoStack.topLabel == "claude-code's comment deletion")
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's comment deletion")
            #expect(try await comment(h, theirs).live, "her ⌥⌘Z brings the last one back")
            await h.hangUp(codex)
            await h.hangUp(connection)
        }
    }

    // MARK: - The rung and the one answer

    /// Below EDIT the two new tools refuse at the rung and raise the ask for
    /// edit; outside the grant — a comment of an unshared note, live or
    /// deleted, and an id naming nothing — every answer is the ONE not-shared
    /// answer, byte-identical. Nothing is written.
    @Test func belowEditTheRungRefusesAndOutsideTheGrantIsTheOneAnswer() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let hers = try h.operations.addBlockComment(to: w.block, text: "Her note.")
            let deleted = try h.operations.addBlockComment(to: w.block, text: "Her deleted note.")
            try h.operations.deleteBlockComment(deleted.id)
            let elsewhere = try h.operations.addBlockComment(to: w.unsharedBlock, text: "Not yours.")
            let elsewhereGone = try h.operations.addBlockComment(to: w.unsharedBlock, text: "Not yours, gone.")
            try h.operations.deleteBlockComment(elsewhereGone.id)

            let maker = try await h.connect(as: "maker")
            _ = try h.approve("maker", spec(.writeNew, .book, w.book.id))
            for (name, arguments): (String, [String: Value]) in [
                ("edit_comment", ["comment_id": .string(hers.id), "text": .string("x"), "expected_text": .string("Her note.")]),
                ("restore_comment", ["comment_id": .string(deleted.id)]),
            ] {
                let refused = try await call(maker, name, arguments)
                #expect(refused.isError == true
                        && text(refused).hasPrefix("This client may only read, suggest and write new here."),
                        "\(name): \(text(refused))")
                #expect(h.asks.value.last?.clientName == "maker" && h.asks.value.last?.rung == .edit, "\(name) asks for edit")
            }
            await h.hangUp(maker)

            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, w.book.id))
            let unshared = MCPRefusalCopy.words(.notShared, .note)
            for (name, arguments): (String, [String: Value]) in [
                ("edit_comment", ["comment_id": .string(elsewhere.id), "text": .string("x"), "expected_text": .string("Not yours.")]),
                ("edit_comment", ["comment_id": .string("no-such-comment"), "text": .string("x"), "expected_text": .string("x")]),
                ("restore_comment", ["comment_id": .string(elsewhereGone.id)]),
                ("restore_comment", ["comment_id": .string("no-such-comment")]),
                ("delete_comment", ["comment_id": .string(elsewhere.id)]),
            ] {
                let refused = try await call(connection, name, arguments)
                #expect(refused.isError == true && text(refused) == unshared, "\(name) \(arguments): \(text(refused))")
            }
            #expect(try await comment(h, hers.id).text == "Her note.")
            #expect(try await comment(h, elsewhere.id).text == "Not yours.")
            #expect(try await comment(h, elsewhereGone.id).live == false)
            #expect(h.undoStack.depth == 0 && h.receipts.value.isEmpty)
            await h.hangUp(connection)
        }
    }

    // MARK: - Her refusals, and ONCE

    /// Under a seal her comment doors refuse (#23) — so do these; a once edit
    /// grant pays for ONE act, and a refused act spends nothing.
    @Test func aSealRefusesAsHerDoorsDoAndAOnceGrantIsOneAct() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let hers = try h.operations.addBlockComment(to: w.block, text: "Her note.")
            let deleted = try h.operations.addBlockComment(to: w.block, text: "Her deleted note.")
            try h.operations.deleteBlockComment(deleted.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .note, w.note.id, .once))

            let stale = try await call(connection, "edit_comment", [
                "comment_id": .string(hers.id), "text": .string("x"), "expected_text": .string("not what it says"),
            ])
            #expect(stale.isError == true, "a refused act…")
            let first = try await call(connection, "edit_comment", [
                "comment_id": .string(hers.id), "text": .string("Her note, kept short."),
                "expected_text": .string("Her note."),
            ])
            #expect(first.isError != true, "…spent nothing: \(text(first))")
            let second = try await call(connection, "restore_comment", ["comment_id": .string(deleted.id)])
            #expect(second.isError == true, "one write means one write")
            #expect(try await comment(h, deleted.id).live == false)

            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.edit, .book, w.book.id))
            try h.operations.lockPost(w.note.id)
            for (name, arguments): (String, [String: Value]) in [
                ("edit_comment", ["comment_id": .string(hers.id), "text": .string("y"),
                                  "expected_text": .string("Her note, kept short.")]),
                ("restore_comment", ["comment_id": .string(deleted.id)]),
            ] {
                let sealed = try await call(connection, name, arguments)
                #expect(sealed.isError == true && text(sealed).contains("lockedPost"), "\(name): \(text(sealed))")
            }
            #expect(try await comment(h, hers.id).text == "Her note, kept short.")
            await h.hangUp(connection)
        }
    }
}
