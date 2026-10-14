import Foundation
import Testing

@testable import VariorumCore

// VX-281 ladder R1-7 — A WING's REACH as a pure Domain rule
// (`MCPGrantRule.reach(grants:openBook:wing:)`, read off `decideWing` beside its
// two twins). Moved from `Queries` (VX-268's `MCPReachPlace.wingReach`): a
// cleanliness move, so these pins are green on both sides of it — they hold the
// rule where it now lives, tested independently (CLAUDE.md's Domain rule).

private typealias Rule = MCPGrantRule

private func grant(
    _ id: String, _ rung: Rule.Rung, _ kind: Rule.ScopeKind, _ scope: String,
    _ duration: Rule.Duration = .always, consumed: String? = nil, revoked: String? = nil
) -> Rule.Grant {
    Rule.Grant(id: id, rung: rung, scopeKind: kind, scopeID: scope, duration: duration,
               consumedAt: consumed, revokedAt: revoked)
}

@Suite("VX-281 R1-7 — a wing's reach, read off decideWing (Domain)")
struct MCPWingReachRuleTests {
    @Test func aWingsReachIsItsOwnWingGrantOrTheOpenBookNothingElse() {
        // Nothing shared.
        #expect(Rule.reach(grants: [], openBook: false, wing: "") == nil)
        // The open book: read, every wing.
        for wing in ["", "w2"] {
            #expect(Rule.reach(grants: [], openBook: true, wing: wing) == Rule.Reach(rung: .read, standing: .openBook))
        }
        // A wing grant reaches ITS wing at its rung — never another wing.
        let home = grant("g-home", .edit, .wing, "")
        #expect(Rule.reach(grants: [home], openBook: false, wing: "") == Rule.Reach(rung: .edit, standing: .grant(home)))
        #expect(Rule.reach(grants: [home], openBook: false, wing: "w2") == nil)
        // A grant outranks the open book's read.
        let suggest = grant("g-s", .suggest, .wing, "")
        #expect(Rule.reach(grants: [suggest], openBook: true, wing: "")
                == Rule.Reach(rung: .suggest, standing: .grant(suggest)))
        // The top rung wins among several.
        let read = grant("g-r", .read, .wing, "")
        let writeNew = grant("g-w", .writeNew, .wing, "", .once)
        #expect(Rule.reach(grants: [read, writeNew], openBook: false, wing: "")?.rung == .writeNew)
        // A dead grant reaches nothing (revoked; a once grant spent).
        let revoked = grant("g-x", .edit, .wing, "", revoked: "2026-10-14T00:00:00.000Z")
        let spent = grant("g-o", .read, .wing, "", .once, consumed: "2026-10-14T00:00:00.000Z")
        #expect(Rule.reach(grants: [revoked, spent], openBook: false, wing: "") == nil)
        #expect(Rule.reach(grants: [revoked], openBook: true, wing: "") == Rule.Reach(rung: .read, standing: .openBook))
        // A note or book grant inside a wing never reaches the wing (P-VX281-U2-4).
        let inside = [grant("g-n", .edit, .note, "note-1"), grant("g-b", .edit, .book, "book-A")]
        #expect(Rule.reach(grants: inside, openBook: false, wing: "") == nil)
    }

    /// The read-off property, over a grid: the reach's rung is one `decideWing`
    /// allows (naming the same grant, or the open book), and no higher rung is
    /// allowed — at every rung, for every wing grant shape.
    @Test func theReachIsDecideWingsHighestAllowedRungEverywhere() {
        let rungs = Rule.Rung.allCases
        var cases = 0
        for openBook in [false, true] {
            for held in [nil] + rungs.map(Optional.some) {
                for duration in [Rule.Duration.always, .once, .connection] {
                    for wing in ["", "w2"] {
                        let grants = held.map { [grant("g", $0, .wing, "", duration)] } ?? []
                        let reach = Rule.reach(grants: grants, openBook: openBook, wing: wing)
                        let allowed = rungs.filter {
                            Rule.decideWing(client: .approved, grants: grants, openBook: openBook,
                                            wingID: wing, rung: $0, consumes: false).isAllowed
                        }
                        #expect(reach?.rung == allowed.max(),
                                "open=\(openBook) held=\(String(describing: held)) \(duration) wing=\(wing)")
                        if let reach {
                            let decision = Rule.decideWing(
                                client: .approved, grants: grants, openBook: openBook, wingID: wing,
                                rung: reach.rung, consumes: false)
                            switch (decision, reach.standing) {
                            case (.allow(let grantID?, _), .grant(let named)): #expect(grantID == named.id)
                            case (.allow(nil, _), .openBook): break
                            default: Issue.record("the standing is decideWing's own: \(decision) vs \(reach.standing)")
                            }
                        }
                        cases += 1
                    }
                }
            }
        }
        #expect(cases == 2 * 5 * 3 * 2)
    }
}
