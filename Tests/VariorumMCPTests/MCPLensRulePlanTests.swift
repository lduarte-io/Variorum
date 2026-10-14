import Foundation
import GRDB
import Testing

@testable import VariorumCore
@testable import VariorumMCP

// VX-253 (VX-336 U5a — the run record `notes/plans/fixes/vx-336-mcp-wire-tools-ai-docs.md`):
// the lens rule's NEW API, pinned as state (green by construction — the wire pins in
// `MCPLensByLabelServerTests` carry the red-on-old evidence). Two things a reviewer
// should be able to read off without a socket: the matcher's one rule (and that it
// agrees with the form `aiLabel` writes — VX-267), and the rule's read is ∝ the note,
// never the corpus (P1 on the plan — the house's form: `MCPPicksPlanTests`,
// `MCPPreCheckPlanTests`).

@Suite("VX-253 — the lens rule's matcher and its read")
struct MCPLensRulePlanTests {
    @Test func theMatcherIsExactAsStoredPlusTheClientsOwnSuggestionInEitherForm() {
        let answers = { (stored: String?) in MCPWriteTools.labelAnswers(stored, label: "english", client: "claude-code") }
        #expect(answers("english"), "exactly as stored")
        #expect(answers("claude-code \u{00B7} english"), "its own suggestion, VX-267's form")
        #expect(answers("claude-code \u{00B7} suggested \u{00B7} english"), "its own suggestion, the legacy form")
        #expect(!answers("another-client \u{00B7} english"), "never another client's by its own part")
        #expect(!answers("another-client \u{00B7} suggested \u{00B7} english"))
        #expect(!answers("English"), "case-sensitive")
        #expect(!answers("english "), "byte-exact — no trimming")
        #expect(!answers("claude-code"), "the client alone names no label")
        #expect(!answers(nil), "an unlabelled take")
        #expect(MCPWriteTools.labelAnswers("another-client \u{00B7} english",
                                           label: "another-client \u{00B7} english", client: "claude-code"),
                "another client's take answers to its FULL stored label — exactly as stored")
    }

    /// What `aiLabel` writes, the matcher finds — for the client that wrote it,
    /// and for no other client.
    @Test func whatAiLabelWritesTheMatcherFindsForItsOwnClientOnly() {
        for own in ["english", "português", "a \u{00B7} b", "draft 2"] {
            let stored = MCPWriteTools.aiLabel(client: "claude-code", own: own)
            #expect(MCPWriteTools.labelAnswers(stored, label: own, client: "claude-code"), "\(stored)")
            #expect(!MCPWriteTools.labelAnswers(stored, label: own, client: "another-client"), "\(stored)")
        }
    }

    @Test func theRulesReadIsTheNotesPlacementsThenTheirTakesNeverAScan() throws {
        let database = try AppDatabase.inMemory()
        let (placements, takes) = try database.read { db -> (String, String) in
            let placements = try Row.fetchAll(
                db, sql: "EXPLAIN QUERY PLAN \(MCPWriteTools.lensRulePlacementsSQL)", arguments: ["a-note"]
            ).map { ($0["detail"] as String?) ?? "" }
            let takes = try Row.fetchAll(
                db, sql: "EXPLAIN QUERY PLAN \(MCPWriteTools.lensRuleTakesSQL)", arguments: [#"["a","b"]"#]
            ).map { ($0["detail"] as String?) ?? "" }
            return (placements.joined(separator: "\n"), takes.joined(separator: "\n"))
        }
        #expect(placements.contains("idx_cblock_order"), "the note's placements, by its own index; plan:\n\(placements)")
        #expect(!placements.contains("SCAN cb") && !placements.contains("SCAN b"), "no scan; plan:\n\(placements)")
        #expect(takes.hasPrefix("SCAN j"), "the block ids drive; plan:\n\(takes)")
        #expect(takes.contains("idx_variant_block"), "each block's takes, by its index; plan:\n\(takes)")
        #expect(!takes.contains("SCAN v"), "never a scan of the takes; plan:\n\(takes)")
    }
}
