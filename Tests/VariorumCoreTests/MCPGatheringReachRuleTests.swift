import Foundation
import Testing

@testable import VariorumCore

// VX-185 (RUN VX-184, U2) — the pure read `MCPGrantRule.reach(grants:openBook:
// gathering:)`, beside `reach(grants:openBook:target:)`: read OFF
// `decideGathering`, never a parallel rule. NEW API with the fix (this file is
// set aside at the revert; the red-on-old pins are `MCPGatheringReachTests`,
// which use only the pre-fix API).

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
        // A wing grant on its wing: read, through that grant — whatever its rung.
        #expect(MCPGrantRule.reach(grants: [wingEdit], openBook: false, gathering: home)
                == .init(rung: .read, standing: .grant(wingEdit)))
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
    /// with `decideGathering` exactly: reached ⇔ allowed, and the standing is
    /// the grant (or the open book) it allows with.
    @Test func itAgreesWithDecideGatheringEverywhere() {
        let pool: [MCPGrantRule.Grant] = [
            grant("a", .read, .wing, ""), grant("b", .suggest, .wing, "", .connection),
            grant("c", .writeNew, .wing, "", .once), grant("d", .edit, .wing, "w2"),
            grant("e", .edit, .book, "g"), grant("f", .read, .note, "g"),
            grant("h", .read, .wing, "", .once, consumed: true), grant("i", .edit, .wing, "", revoked: true),
        ]
        var checked = 0
        for mask in 0..<(1 << pool.count) {
            let grants = pool.indices.filter { mask & (1 << $0) != 0 }.map { pool[$0] }
            for openBook in [false, true] {
                for fence in [nil, MCPGrantRule.Fence.privateMark] {
                    var facts = home
                    facts.fence = fence
                    let reach = MCPGrantRule.reach(grants: grants, openBook: openBook, gathering: facts)
                    let decision = MCPGrantRule.decideGathering(
                        client: .approved, grants: grants, openBook: openBook, gathering: facts)
                    switch decision {
                    case .allow(let grantID, let spends):
                        #expect(!spends, "a gathering's read never spends")
                        let standing: MCPGrantRule.Standing = grantID.flatMap { id in
                            grants.first { $0.id == id }.map(MCPGrantRule.Standing.grant)
                        } ?? .openBook
                        #expect(reach == .init(rung: .read, standing: standing))
                    default:
                        #expect(reach == nil)
                    }
                    checked += 1
                }
            }
        }
        #expect(checked == 1_024)
    }
}
