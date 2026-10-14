import Foundation
import GRDB
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
