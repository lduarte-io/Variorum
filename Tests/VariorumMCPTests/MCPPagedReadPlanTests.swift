import Foundation
import GRDB
import Testing

@testable import VariorumCore
@testable import VariorumMCP

// VX-256 (VX-336 U7 — D-256-5, P-256-11): A PAGE COSTS ∝ THE PAGE, pinned on the plan
// (the house's P1 pin form: `MCPPicksPlanTests`, `MCPPreCheckPlanTests`). The page's
// statement must SEEK the cursor through `idx_cblock_order(container_id, position)` —
// a range on `position`, never a walk of the note's placements up to it — and never sort
// the note whole; a lens's picks for the page are each block's one live pick through
// `uq_lens_choice_live(lens_id, block_id)`, the given ids driving.

@Suite("VX-256 — a page of read_note is ∝ the page (P1 on the plan)")
struct MCPPagedReadPlanTests {
    private func plan(_ sql: String, _ arguments: StatementArguments) throws -> [String] {
        let database = try AppDatabase.inMemory()
        return try database.read { db in
            try Row.fetchAll(db, sql: "EXPLAIN QUERY PLAN \(sql)", arguments: arguments)
                .map { ($0["detail"] as String?) ?? "" }
        }
    }

    @Test func thePageSeeksTheCursorThroughTheOrderIndex() throws {
        let plan = try plan(MCPNoteStructure.pageSQL, ["a-note", "Va", "Va", "an-id", 51])
        let said = plan.joined(separator: "\n")
        #expect(said.contains("idx_cblock_order (container_id=? AND position>?)"),
                "a range seek on the note's order index; plan:\n\(said)")
        #expect(!said.contains("USE TEMP B-TREE FOR ORDER BY"), "never a sort of the note whole; plan:\n\(said)")
        #expect(!said.contains("SCAN cb"), "never a scan of the placements; plan:\n\(said)")
    }

    @Test func aPagesLensPicksAreEachBlocksOneLivePick() throws {
        let plan = try plan(Queries.pageLensSelectionSQL, [#"["a","b"]"#, "a-lens"])
        let said = plan.joined(separator: "\n")
        #expect(plan.first?.hasPrefix("SCAN j") == true, "the page's block ids drive; plan:\n\(said)")
        #expect(said.contains("uq_lens_choice_live"), "each block seeks its one live pick; plan:\n\(said)")
        #expect(!said.contains("SCAN lc") && !said.contains("SCAN v"), "never a scan of a table; plan:\n\(said)")
    }
}
