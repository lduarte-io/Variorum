import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-184 U3 — VX-187: `link_versions` (R-VX187-1: the AI NAMES the paragraph
// pairs — at least one {block_a, block_b} across the two notes, never
// positional guessing). Each pair a `version_of` edge stored canonically
// (min(id), max(id)) through her own road (`insertVersionOfEdge`); ONE pair
// makes the notes Compare peers (`Queries.versionPeerPosts`, Compare's
// `versionPeerSplit.sameWing`). WRITE NEW on BOTH notes — both sides decided,
// their once grants spent together (`move_note_to_wing`'s two-sided shape).
// ONE client-named undo entry. Written to compile on the pre-fix tree.

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

private func pair(_ a: String, _ b: String) -> Value {
    .object(["block_a": .string(a), "block_b": .string(b)])
}

@Suite("VX-187 — link_versions: named pairs, Compare peers", .serialized)
struct MCPLinkVersionsServerTests {
    private struct World {
        let book: Reading
        let a: Container
        let b: Container
        let aBlocks: [String]
        let bBlocks: [String]
    }

    private func world(_ h: ServerHarness) throws -> World {
        let book = try h.operations.createReading(name: "drafts", kind: .book)
        let a = try h.operations.createPost(title: "draft one")
        let b = try h.operations.createPost(title: "draft two")
        var aBlocks: [String] = []
        var bBlocks: [String] = []
        for (note, texts) in [(a, ["A first.", "A second.", "A third."]), (b, ["B first.", "B second.", "B third."])] {
            _ = try h.operations.addPostToReading(note.id, to: book.id)
            for text in texts {
                let block = try h.operations.newBlock(in: note.id, text: text, registeringUndo: false).block.id
                if note.id == a.id { aBlocks.append(block) } else { bBlocks.append(block) }
            }
        }
        return World(book: book, a: a, b: b, aBlocks: aBlocks, bBlocks: bBlocks)
    }

    private func peers(_ h: ServerHarness, _ noteID: String) async throws -> [String] {
        try await h.database.read { try Queries.versionPeerPosts($0, of: noteID) }
    }

    private func liveVersionEdges(_ h: ServerHarness) async throws -> [[String]] {
        try await h.database.read { db in
            try Row.fetchAll(db, sql: """
                SELECT source_block_id, target_block_id, origin_op FROM edge
                WHERE type = 'version_of' AND deleted_at IS NULL ORDER BY source_block_id, target_block_id
                """).map { [$0["source_block_id"], $0["target_block_id"], $0["origin_op"]] }
        }
    }

    @Test func namedPairsMakeTheNotesComparePeersAsOneUndo() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, w.book.id))
            #expect(try await peers(h, w.a.id).isEmpty)

            let linked = try await call(connection, "link_versions", [
                "note_a": .string(w.a.id), "note_b": .string(w.b.id),
                "pairs": .array([pair(w.aBlocks[0], w.bBlocks[0]), pair(w.aBlocks[2], w.bBlocks[1])]),
            ])
            #expect(linked.isError != true, "\(text(linked))")
            let answer = try json(linked)
            let links = try #require(answer["links"] as? [[String: Any]])
            #expect(links.count == 2 && links.allSatisfy { ($0["edge_id"] as? String)?.isEmpty == false })
            #expect(links.map { $0["block_a"] as? String } == [w.aBlocks[0], w.aBlocks[2]])

            // Each pair stored canonically — (min(id), max(id)) — through her road.
            let named: [(String, String)] = [(w.aBlocks[0], w.bBlocks[0]), (w.aBlocks[2], w.bBlocks[1])]
            let canonical: [[String]] = named.map { pair -> [String] in
                [min(pair.0, pair.1), max(pair.0, pair.1), "manual"]
            }
            let expected: [[String]] = canonical.sorted { lhs, rhs in
                lhs[0] != rhs[0] ? lhs[0] < rhs[0] : lhs[1] < rhs[1]
            }
            #expect(try await liveVersionEdges(h) == expected)
            // ONE linked pair makes the notes Compare peers — Compare's own read.
            let peersOfA = try await peers(h, w.a.id)
            let peersOfB = try await peers(h, w.b.id)
            #expect(peersOfA == [w.b.id] && peersOfB == [w.a.id])
            let split = try await h.database.read { try Queries.versionPeerSplit($0, of: w.a.id) }
            #expect(split.sameWing == [w.b.id], "Compare's peer column offers it")
            // The client can read the relation back, block by block.
            let lineage = try json(try await call(connection, "read_note", [
                "note_id": .string(w.a.id), "with_lineage": .bool(true),
            ]))
            let first = try #require((lineage["blocks"] as? [[String: Any]])?.first?["lineage"] as? [[String: Any]])
            #expect(first.contains { $0["relation"] as? String == "version_of" && $0["note_id"] as? String == w.b.id
                && $0["block_id"] as? String == w.bBlocks[0] })

            #expect(h.undoStack.depth == 1 && h.undoStack.topLabel == "claude-code's version link")
            #expect(h.receipts.value.last?.act.rawValue == "version link")
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's version link")
            let edgesAfterUndo = try await liveVersionEdges(h)
            let peersAfterUndo = try await peers(h, w.a.id)
            #expect(edgesAfterUndo.isEmpty && peersAfterUndo.isEmpty, "one undo takes every pair")
            #expect(try h.undoStack.redo(with: h.writeOperations) == "claude-code's version link")
            #expect(try await liveVersionEdges(h) == expected, "the redo brings back the very pairs")
            await h.hangUp(connection)
        }
    }

    /// The pairs are NAMED, never guessed — and refused, naming the pair,
    /// all-or-nothing, when they don't name what the act needs.
    @Test func everyPairIsNamedAndCheckedAllOrNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let work = try h.operations.createWing(name: "work")
            let away = try h.operations.createPost(title: "away", wingId: work.id)
            let awayBlock = try h.operations.newBlock(in: away.id, text: "Away.", registeringUndo: false).block.id
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, w.book.id))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.writeNew, .wing, work.id))

            let none = try await call(connection, "link_versions", [
                "note_a": .string(w.a.id), "note_b": .string(w.b.id), "pairs": .array([]),
            ])
            #expect(none.isError == true && text(none).hasPrefix("pairs must name at least one pair"), "\(text(none))")
            let same = try await call(connection, "link_versions", [
                "note_a": .string(w.a.id), "note_b": .string(w.a.id), "pairs": .array([pair(w.aBlocks[0], w.aBlocks[1])]),
            ])
            #expect(same.isError == true && text(same) == "note_a and note_b must be two different notes.", "\(text(same))")
            let wrongSide = try await call(connection, "link_versions", [
                "note_a": .string(w.a.id), "note_b": .string(w.b.id),
                "pairs": .array([pair(w.aBlocks[0], w.bBlocks[0]), pair(w.bBlocks[1], w.bBlocks[2])]),
            ])
            let nowhere = try await call(connection, "link_versions", [
                "note_a": .string(w.a.id), "note_b": .string(w.b.id),
                "pairs": .array([pair(w.aBlocks[0], w.bBlocks[0]), pair("no-such-block", w.bBlocks[2])]),
            ])
            #expect(wrongSide.isError == true && text(wrongSide).hasPrefix("pairs[1].block_a isn't a block of note_a"),
                    "\(text(wrongSide))")
            #expect(text(nowhere) == text(wrongSide), "a block elsewhere and a block nowhere answer alike")
            let twice = try await call(connection, "link_versions", [
                "note_a": .string(w.a.id), "note_b": .string(w.b.id),
                "pairs": .array([pair(w.aBlocks[0], w.bBlocks[0]), pair(w.aBlocks[0], w.bBlocks[0])]),
            ])
            #expect(twice.isError == true && text(twice) == "pairs[1] repeats an earlier pair.", "\(text(twice))")
            let crossWing = try await call(connection, "link_versions", [
                "note_a": .string(w.a.id), "note_b": .string(away.id), "pairs": .array([pair(w.aBlocks[0], awayBlock)]),
            ])
            #expect(crossWing.isError == true && text(crossWing).contains("different wings"), "\(text(crossWing))")
            let tooMany = try await call(connection, "link_versions", [
                "note_a": .string(w.a.id), "note_b": .string(w.b.id),
                "pairs": .array((0..<201).map { _ in pair(w.aBlocks[0], w.bBlocks[0]) }),
            ])
            #expect(tooMany.isError == true && text(tooMany).hasPrefix("link_versions takes at most 200 pairs in one call"),
                    "\(text(tooMany))")
            let edgesNow = try await liveVersionEdges(h)
            #expect(edgesNow.isEmpty && h.undoStack.depth == 0, "nothing landed")

            try h.operations.markVersionOf(w.aBlocks[1], w.bBlocks[1])
            let already = try await call(connection, "link_versions", [
                "note_a": .string(w.a.id), "note_b": .string(w.b.id),
                "pairs": .array([pair(w.aBlocks[0], w.bBlocks[0]), pair(w.aBlocks[1], w.bBlocks[1])]),
            ])
            #expect(already.isError == true && text(already).hasPrefix("pairs[1] is already linked"), "\(text(already))")
            #expect(try await liveVersionEdges(h).count == 1, "her link stands; the call's first pair never landed")
            await h.hangUp(connection)
        }
    }

    /// WRITE NEW on BOTH notes: short on one side refuses naming that side
    /// (and raises its ask); once grants on both sides are spent together by
    /// the one act.
    @Test func writeNewOnBothNotesAndTheirOnceGrantsSpentTogether() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .note, w.a.id))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.read, .note, w.b.id))

            let short = try await call(connection, "link_versions", [
                "note_a": .string(w.a.id), "note_b": .string(w.b.id), "pairs": .array([pair(w.aBlocks[0], w.bBlocks[0])]),
            ])
            #expect(short.isError == true && text(short).hasPrefix("This client may only read here."), "\(text(short))")
            #expect(h.asks.value.last?.scopeID == w.b.id && h.asks.value.last?.rung == .writeNew)
            #expect(try await liveVersionEdges(h).isEmpty)

            let client = try h.client("claude-code").id
            for grant in try await h.database.read({ try Queries.mcpGrants($0, clientID: client) }) {
                try h.operations.revokeMCPGrant(grant.id)
            }
            _ = try h.operations.grantMCPAccess(client, spec(.writeNew, .note, w.a.id, .once))
            _ = try h.operations.grantMCPAccess(client, spec(.writeNew, .note, w.b.id, .once))
            let linked = try await call(connection, "link_versions", [
                "note_a": .string(w.a.id), "note_b": .string(w.b.id), "pairs": .array([pair(w.aBlocks[0], w.bBlocks[0])]),
            ])
            #expect(linked.isError != true, "\(text(linked))")
            let spent = try await h.database.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM mcp_grant WHERE consumed_at IS NOT NULL")
            }
            #expect(spent == 2, "both sides' once grants paid for the one act")
            let again = try await call(connection, "link_versions", [
                "note_a": .string(w.a.id), "note_b": .string(w.b.id), "pairs": .array([pair(w.aBlocks[1], w.bBlocks[1])]),
            ])
            #expect(again.isError == true)
            await h.hangUp(connection)
        }
    }

    // MARK: - VX-298 (VX-336 U6a — APPENDED; nothing above modified)

    /// Her answer (5): the receipt's Open › opens the two side by side in Compare — A, then B
    /// (`show_in_app`'s compare target, delivered by her press, D-298-6). **RED on old:** the
    /// receipt opened note A alone (`.note(A)`).
    @Test func theReceiptsOpenOpensTheTwoInCompare() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, w.book.id))
            let linked = try await call(connection, "link_versions", [
                "note_a": .string(w.a.id), "note_b": .string(w.b.id), "pairs": .array([pair(w.aBlocks[0], w.bBlocks[0])]),
            ])
            #expect(linked.isError != true, "\(text(linked))")
            let receipt = try #require(h.receipts.value.last)
            #expect(receipt.act.rawValue == "version link")
            #expect(showCompareParts(receipt.show) == [w.a.id, w.b.id], "Open › opens Compare: A, then B beside it")
            await h.hangUp(connection)
        }
    }
}
