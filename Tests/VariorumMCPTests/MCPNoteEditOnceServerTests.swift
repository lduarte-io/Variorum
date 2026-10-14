import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-184 U4 — VX-195: EVERY edit-parity tool spends a ONCE edit grant inside
// its own transaction (the guard — AF-10 (a)): one act lands, the next act on
// that note is refused, and a refused act spends nothing. Over the wire, per
// tool: the snapshot never spends (`spendsAfter: false`), so the ONLY road a
// once grant is spent by is the in-transaction guard each tool hands its op —
// a tool whose guard went missing would leave the grant standing (the
// mutation check in the record).

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

@Suite("VX-195 — every edit-parity tool spends a once grant inside its act", .serialized)
struct MCPNoteEditOnceServerTests {
    /// One note holding something for every tool to act on.
    private struct World {
        let note: Container
        let take: String
        let other: String
        let lastTake: String
        let archived: String
        let comment: String
        let deletedComment: String
        let commit: String
        let lens: String
    }

    private func world(_ h: ServerHarness, _ name: String) throws -> World {
        let note = try h.operations.createPost(title: name)
        let one = try h.operations.newBlock(in: note.id, text: "Her opening.", registeringUndo: false)
        let commit = try h.operations.commit(one.variant.id, message: "first")
        try h.operations.autosave(one.variant.id, text: "Her opening, revised.", charDelta: 9)
        let other = try h.operations.branchVariant(one.block.id, from: one.variant.id)
        let archived = try h.operations.branchVariant(one.block.id, from: one.variant.id)
        try h.operations.archiveVariant(archived.id)
        let two = try h.operations.newBlock(in: note.id, text: "Her close.", registeringUndo: false)
        let comment = try h.operations.addBlockComment(to: one.block.id, text: "Her note.")
        let gone = try h.operations.addBlockComment(to: one.block.id, text: "Her deleted note.")
        try h.operations.deleteBlockComment(gone.id)
        let lens = try h.operations.createLens(post: note.id, name: "a cut")
        return World(note: note, take: one.variant.id, other: other.id, lastTake: two.variant.id,
                     archived: archived.id, comment: comment.id, deletedComment: gone.id, commit: commit.id,
                     lens: lens.id)
    }

    @Test func eachToolSpendsAOnceEditGrantByItsOneActAndNoMore() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", nil)
            let clientID = try h.client("claude-code").id
            let acts: [(String, (World) -> [String: Value])] = [
                ("edit_comment", { ["comment_id": .string($0.comment), "text": .string("Her note, kept."),
                                    "expected_text": .string("Her note.")] }),
                ("restore_comment", { ["comment_id": .string($0.deletedComment)] }),
                ("delete_comment", { ["comment_id": .string($0.comment)] }),
                ("delete_take", { ["take_id": .string($0.other)] }),
                ("delete_take", { ["take_id": .string($0.lastTake)] }),
                ("archive_take", { ["take_id": .string($0.other)] }),
                ("unarchive_take", { ["take_id": .string($0.archived)] }),
                ("set_take_label", { ["take_id": .string($0.other), "label": .string("bold")] }),
                ("lock_take", { ["take_id": .string($0.other)] }),
                ("unlock_take", { _ in [:] }),  // filled below: a locked take of that note
                ("restore_commit", { ["commit_id": .string($0.commit)] }),
                ("rename_commit", { ["commit_id": .string($0.commit), "message": .string("the first")] }),
                ("rename_note", { ["note_id": .string($0.note.id), "title": .string("renamed")] }),
                ("delete_lens", { ["lens_id": .string($0.lens)] }),
            ]
            for (index, (tool, arguments)) in acts.enumerated() {
                let w = try world(h, "note \(index)")
                var args = arguments(w)
                if tool == "unlock_take" {
                    try h.operations.lockVariant(w.other)
                    args = ["take_id": .string(w.other)]
                }
                _ = try h.operations.grantMCPAccess(clientID, spec(.edit, .note, w.note.id, .once))
                let first = try await call(connection, tool, args)
                #expect(first.isError != true, "\(tool) lands on its once grant: \(text(first))")
                let second = try await call(connection, "set_take_label", [
                    "take_id": .string(w.take), "label": .string("after \(tool)"),
                ])
                #expect(second.isError == true, "\(tool) spent the once grant — one write means one write")
                let label = try await h.database.read { db in
                    try String.fetchOne(db, sql: "SELECT label FROM variant WHERE id = ?", arguments: [w.take])
                }
                #expect(label == nil, "\(tool): nothing landed past the spent grant")
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
            let refusals: [(String, (World) -> [String: Value])] = [
                ("edit_comment", { ["comment_id": .string($0.comment), "text": .string("x"),
                                    "expected_text": .string("stale")] }),
                ("delete_take", { ["take_id": .string($0.take)] }),  // the shown take: choose another first
                ("restore_commit", { _ in [:] }),  // filled below: a locked take's commit
            ]
            for (index, (tool, arguments)) in refusals.enumerated() {
                let w = try world(h, "refusal \(index)")
                var args = arguments(w)
                if tool == "restore_commit" {
                    try h.operations.lockVariant(w.take)
                    args = ["commit_id": .string(w.commit)]
                }
                _ = try h.operations.grantMCPAccess(clientID, spec(.edit, .note, w.note.id, .once))
                let refused = try await call(connection, tool, args)
                #expect(refused.isError == true, "\(tool) refuses: \(text(refused))")
                let then = try await call(connection, "set_take_label", [
                    "take_id": .string(w.other), "label": .string("after a refused \(tool)"),
                ])
                #expect(then.isError != true, "a refused \(tool) spent nothing: \(text(then))")
            }
            await h.hangUp(connection)
        }
    }
}
