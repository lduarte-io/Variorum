import Foundation
import Testing

@testable import VariorumCore

// VX-185 (RUN VX-184, U2) — the pure read `MCPGrantRule.reach(grants:openBook:
// gathering:)`, beside `reach(grants:openBook:target:)`: read OFF
// `decideGathering`, never a parallel rule. NEW API with the fix (this file is
// set aside at the revert; the red-on-old pins are `MCPGatheringReachTests`,
// which use only the pre-fix API).
//
// **VX-549 — FLIPPED DELIBERATELY** (VX-548 batch 3; her sitting 2026-10-27,
// RATIFIED: "the supersession of VX-273's facts-only rule is RATIFIED. Gathering
// joins the grant scopes"). Until VX-549 a gathering's reach was always READ
// ("a gathering holds nothing to write, whatever the wing grant allows"); a
// gathering is now a place like a book — reached by its OWN grant or its WING's
// at that grant's rung (a new note may be written INTO it; its members edited),
// the open book at read. R-VX185-1 STANDS: a note or book grant never reaches
// it. The table's first row and the agreement grid's rung are the flipped
// expectations; the rest held as they were.

@Suite("VX-185 — a gathering's reach is read off decideGathering, never a parallel rule")
struct MCPGatheringReachRuleTests {
    private let home = MCPGrantRule.BookFacts(id: "g", wingID: "")
    private let away = MCPGrantRule.BookFacts(id: "g2", wingID: "w2")

    private func grant(
        _ id: String, _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ scope: String,
        _ duration: MCPGrantRule.Duration = .always, consumed: Bool = false, revoked: Bool = false
    ) -> MCPGrantRule.Grant {
        .init(id: id, rung: rung, scopeKind: kind, scopeID: scope, duration: duration,
              consumedAt: consumed ? "x" : nil, revokedAt: revoked ? "x" : nil)
    }

    @Test func theTable() {
        let wingEdit = grant("w", .edit, .wing, "")
        // A wing grant on its wing: AT ITS RUNG, through that grant (VX-549 —
        // flipped from "read, whatever its rung").
        #expect(MCPGrantRule.reach(grants: [wingEdit], openBook: false, gathering: home)
                == .init(rung: .edit, standing: .grant(wingEdit)))
        // VX-549: the gathering's OWN grant, at its rung — narrower than the
        // wing's, so among equals it is the one named.
        let ownSuggest = grant("o", .suggest, .gathering, "g")
        #expect(MCPGrantRule.reach(grants: [ownSuggest], openBook: false, gathering: home)
                == .init(rung: .suggest, standing: .grant(ownSuggest)))
        #expect(MCPGrantRule.reach(grants: [ownSuggest], openBook: false, gathering: away) == nil,
                "another gathering's grant reaches nothing here")
        let wingSuggest = grant("s", .suggest, .wing, "")
        #expect(MCPGrantRule.reach(grants: [wingSuggest, ownSuggest], openBook: false, gathering: home)
                == .init(rung: .suggest, standing: .grant(ownSuggest)), "the narrower place names the why")
        // R-VX185-1: a note grant, a book grant (any rung) — nothing.
        let noteGrant = grant("n", .edit, .note, "a-member")
        let bookGrant = grant("b", .edit, .book, "a-book")
        #expect(MCPGrantRule.reach(grants: [noteGrant, bookGrant], openBook: false, gathering: home) == nil)
        // Another wing's grant — nothing.
        #expect(MCPGrantRule.reach(grants: [wingEdit], openBook: false, gathering: away) == nil)
        // The open book: read, as the open book.
        #expect(MCPGrantRule.reach(grants: [noteGrant], openBook: true, gathering: away)
                == .init(rung: .read, standing: .openBook))
        // A dead grant reaches nothing.
        #expect(MCPGrantRule.reach(grants: [grant("r", .read, .wing, "", revoked: true)],
                                   openBook: false, gathering: home) == nil)
        #expect(MCPGrantRule.reach(grants: [grant("o", .read, .wing, "", .once, consumed: true)],
                                   openBook: false, gathering: home) == nil)
        // The fence (decideGathering's own — never relaxed): nothing reaches.
        for fence in [MCPGrantRule.Fence.privateMark, .journal] {
            var fenced = home
            fenced.fence = fence
            #expect(MCPGrantRule.reach(grants: [wingEdit], openBook: true, gathering: fenced) == nil)
        }
    }

    /// Over a grid of grant sets × the open book × the fence, the read agrees
    /// with `decideGathering` exactly: reached ⇔ allowed at read, the rung is
    /// the HIGHEST rung `decideGathering` allows (VX-549 — flipped from "always
    /// read"), and the standing is the grant (or the open book) it allows with
    /// at that rung. VX-549 adds the gathering's OWN grants to the pool (one
    /// on it, one on another gathering, a spent once).
    @Test func itAgreesWithDecideGatheringEverywhere() {
        let pool: [MCPGrantRule.Grant] = [
            grant("a", .read, .wing, ""), grant("b", .suggest, .wing, "", .connection),
            grant("c", .writeNew, .wing, "", .once), grant("d", .edit, .wing, "w2"),
            grant("e", .edit, .book, "g"), grant("f", .read, .note, "g"),
            grant("h", .read, .wing, "", .once, consumed: true), grant("i", .edit, .wing, "", revoked: true),
            grant("j", .edit, .gathering, "g"), grant("k", .edit, .gathering, "g2"),
            grant("l", .suggest, .gathering, "g", .once, consumed: true),
        ]
        var checked = 0
        for mask in 0..<(1 << pool.count) {
            let grants = pool.indices.filter { mask & (1 << $0) != 0 }.map { pool[$0] }
            for openBook in [false, true] {
                for fence in [nil, MCPGrantRule.Fence.privateMark] {
                    var facts = home
                    facts.fence = fence
                    let reach = MCPGrantRule.reach(grants: grants, openBook: openBook, gathering: facts)
                    let top = MCPGrantRule.Rung.allCases.reversed().first { rung in
                        MCPGrantRule.decideGathering(
                            client: .approved, grants: grants, openBook: openBook, gathering: facts, rung: rung
                        ).isAllowed
                    }
                    guard let top else {
                        #expect(reach == nil)
                        checked += 1
                        continue
                    }
                    guard case .allow(let grantID, let spends) = MCPGrantRule.decideGathering(
                        client: .approved, grants: grants, openBook: openBook, gathering: facts, rung: top)
                    else { Issue.record("allowed at \(top) above"); continue }
                    #expect(!spends, "a non-consuming probe never spends")
                    let standing: MCPGrantRule.Standing = grantID.flatMap { id in
                        grants.first { $0.id == id }.map(MCPGrantRule.Standing.grant)
                    } ?? .openBook
                    #expect(reach == .init(rung: top, standing: standing))
                    // R-VX185-1 stands: only a gathering or wing grant (or the
                    // open book) is ever the standing.
                    if case .grant(let g) = standing { #expect(g.scopeKind == .gathering || g.scopeKind == .wing) }
                    checked += 1
                }
            }
        }
        #expect(checked == 8_192)
    }
}
