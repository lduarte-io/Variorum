import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP

// VX-280 — `save_lens`'s PICKS CHECK IS ∝ THE TAKES GIVEN (P1 on the plan — the
// house's P1 pin form: `MCPPreCheckPlanTests`, `OwnershipHideAndBadgesTests`,
// `MCPGrantPlacesTests`; the run record
// `notes/plans/fixes/vx-246-mcp-door-fixes-ai-docs.md`, U1 — "VX-280").
// `picks` resolves each given take id to its block, among the blocks live-placed
// in the note. VX-184's round-2 fix pass measured its plain JOINs planned with the
// note's placements OUTSIDE (`idx_cblock_order`) and `json_each` inside — cost ∝
// the document, P1's letter broken (OverallModel §5). The shipped statement must
// let the GIVEN ids drive: each id finds its take by key, then its block's one
// live placement through `uq_cblock_ownership`, never the note's placements.

@Suite("VX-280 — save_lens's picks check is ∝ the takes given (P1 on the plan)")
struct MCPPicksPlanTests {
    @Test func theGivenTakeIdsDriveEachSeekingItsBlocksOnePlacementNeverTheNotesPlacements() throws {
        let database = try AppDatabase.inMemory()
        let plan = try database.read { db -> [String] in
            try Row.fetchAll(
                db, sql: "EXPLAIN QUERY PLAN \(MCPWriteTools.picksSQL)",
                arguments: [#"["a","b"]"#, "a-note"]
            ).map { ($0["detail"] as String?) ?? "" }
        }
        let said = plan.joined(separator: "\n")
        #expect(plan.first?.hasPrefix("SCAN j") == true, "the given ids are the outer loop; plan:\n\(said)")
        #expect(said.contains("uq_cblock_ownership"), "each take's block seeks its one live placement; plan:\n\(said)")
        #expect(!said.contains("idx_cblock_order"), "never the note's placements; plan:\n\(said)")
        #expect(!said.contains("SCAN cb") && !said.contains("SCAN v"), "never a scan of a table; plan:\n\(said)")
    }
}

/// The PARITY half (VX-280): the statement changed its plan, never its answer —
/// every road `picks` speaks, pinned on the wire. No suite pinned these refusals
/// before, so this one was run on BOTH statements (the record says how).
@Suite("VX-280 — save_lens's picks answer exactly as before", .serialized)
struct MCPPicksParityServerTests {
    private func lens(
        _ connection: HarnessConnection, _ noteID: String, _ takeIDs: [String]
    ) async throws -> (content: [Tool.Content], isError: Bool?) {
        try await connection.client.callTool(name: "save_lens", arguments: [
            "note_id": .string(noteID), "name": .string("a reading"), "take_ids": .array(takeIDs.map { .string($0) }),
        ])
    }

    @Test func everyPicksRoadAnswersAsBefore() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let note = try h.operations.createPost(title: "hers")
            let other = try h.operations.createPost(title: "another")
            _ = try h.operations.addPostToReading(note.id, to: book.id)
            _ = try h.operations.addPostToReading(other.id, to: book.id)
            let first = try h.operations.newBlock(in: note.id, text: "the harbour at dawn", registeringUndo: false)
            let second = try h.operations.newBlock(in: note.id, text: "the gulls", registeringUndo: false)
            let elsewhere = try h.operations.newBlock(in: other.id, text: "far away", registeringUndo: false)
            let firstTake = first.variant.id
            let secondTake = second.variant.id
            let alternative = try h.operations.branchVariant(first.block.id, from: firstTake).id
            let gone = try h.operations.branchVariant(second.block.id, from: secondTake).id
            try h.operations.deleteVariant(gone)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", .init(rung: .suggest, scopeKind: .book, scopeID: book.id, duration: .always))

            let foreign = elsewhere.variant.id
            for (stray, why) in [(foreign, "a take of another note"), (gone, "a deleted take"),
                                 ("no-such-take", "an id naming nothing")] {
                let answer = try await lens(connection, note.id, [firstTake, stray])
                #expect(answer.isError == true && text(answer) == "take_id \(stray) isn't a take of this note.",
                        "\(why): \(text(answer))")
            }
            let twice = try await lens(connection, note.id, [firstTake, alternative])
            #expect(twice.isError == true
                    && text(twice) == "A lens shows one take per block; take_ids names two takes of one block.",
                    "two takes of one block: \(text(twice))")
            let saved = try await lens(connection, note.id, [alternative, secondTake])
            #expect(saved.isError != true, "\(text(saved))")
            let lensID = try #require(try json(saved)["lens_id"] as? String)
            #expect(try await h.database.read { try Queries.effectiveLensSelection($0, lens: lensID) }
                    == [first.block.id: alternative, second.block.id: secondTake], "the picks, block by block")
            await h.hangUp(connection)
        }
    }
}
