import Foundation
import GRDB
import Testing

@testable import VariorumCore
@testable import VariorumMCP

// VX-184 ladder round 2 — P1 IN THE BATCH AND LINK PRE-CHECKS, pinned ON THE
// PLAN (the house's P1 pin form: `OwnershipHideAndBadgesTests.theBadgeFacts…`,
// `MCPGrantPlacesTests.theOfferedBooksRead…`). `add_takes`, `add_comments` and
// `link_versions` check up to 200 given block ids against their note(s) before
// the act; until this pass that check read every live placement of the note —
// cost ∝ the document, P1's letter broken (OverallModel §5). The shipped
// statement must let the GIVEN ids drive: each id seeks its one live placement
// through `uq_cblock_ownership`, never the note's placements through
// `idx_cblock_order`. The trap this guards: the same statement written with a
// plain JOIN (the `picks` precedent's shape) is planned with the note's
// placements OUTSIDE and `json_each` inside — the O(note) read again, worse.

@Suite("VX-184 ladder round 2 — the batch and link pre-checks are ∝ the items (P1 on the plan)")
struct MCPPreCheckPlanTests {
    @Test func theGivenIdsDriveEachSeekingItsOnePlacementNeverTheNotesPlacements() throws {
        let database = try AppDatabase.inMemory()
        let plan = try database.read { db -> [String] in
            try Row.fetchAll(
                db, sql: "EXPLAIN QUERY PLAN \(MCPWriteTools.placedBlocksSQL)",
                arguments: [#"["a","b"]"#, "a-note"]
            ).map { ($0["detail"] as String?) ?? "" }
        }
        let said = plan.joined(separator: "\n")
        #expect(plan.first?.hasPrefix("SCAN j") == true, "the given ids are the outer loop; plan:\n\(said)")
        #expect(said.contains("uq_cblock_ownership"), "each id seeks its one live placement; plan:\n\(said)")
        #expect(!said.contains("idx_cblock_order"), "never the note's placements; plan:\n\(said)")
        #expect(!said.contains("SCAN cb") && !said.contains("SCAN b"), "never a scan of a table; plan:\n\(said)")
    }
}
