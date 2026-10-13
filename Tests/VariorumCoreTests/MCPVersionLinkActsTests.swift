import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-184 U3 — VX-187's act (`linkVersionsForClient`): canonical edges through
// her road, ONE entry; the redo answers only for the edges that died on the
// undo's stamp and never collides with a live twin she minted since.

@Suite("VX-187 — the version link act and its undo")
struct MCPVersionLinkActsTests {
    @Test func theRedoKeepsHerLiveTwinAndRefusesNothing() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let a = try ops.createPost(title: "one")
            let b = try ops.createPost(title: "two")
            let a1 = try ops.seedBlock(in: a.id, text: "A.").block.id
            let b1 = try ops.seedBlock(in: b.id, text: "B.").block.id
            stack.removeAll()
            let label = Operations.MCPWriteAct.versionLink.undoLabel(client: "claude-code")
            let edges = try ops.linkVersionsForClient(
                noteA: a.id, noteB: b.id, pairs: [.init(blockA: a1, blockB: b1)], undoLabel: label)
            #expect(edges.count == 1 && edges[0].sourceBlockId == min(a1, b1) && edges[0].targetBlockId == max(a1, b1))
            #expect(try db.read { try Queries.versionPeerPosts($0, of: a.id) } == [b.id])
            #expect(try stack.undo(with: ops) == label)
            #expect(try db.read { try Queries.versionPeerPosts($0, of: a.id) }.isEmpty)
            _ = try ops.markVersionOf(b1, a1)  // her own link of the same pair, since
            #expect(try stack.redo(with: ops) == label, "the redo runs without a uniqueness collision…")
            let live = try db.read {
                try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM edge WHERE type = 'version_of' AND deleted_at IS NULL")
            }
            #expect(live == 1, "…and her twin is the pair's one live edge")
            #expect(throws: Operations.MCPVersionLinkRefusal.sameNote) {
                _ = try ops.linkVersionsForClient(noteA: a.id, noteB: a.id, pairs: [.init(blockA: a1, blockB: a1)],
                                                 undoLabel: label)
            }
        }
    }
}
