//
//  MCPGrantRule+Wing.swift
//  VariorumCore — Domain
//
//  VX-281 ladder R1-7 — A WING's REACH, beside its twins. VX-268 (U2) read a
//  wing row's reach off `decideWing` exactly as `MCPGrantRule.reach(…target:)`
//  is read off `decide`, but kept that pure read-off in `Queries`
//  (`MCPReachPlace.wingReach`). CLAUDE.md puts pure rules in Domain, tested
//  independently; this file moves it here — a NEW file, so `MCPGrantRule.swift`
//  itself stays untouched (another run's lane while this one runs).
//

import Foundation

extension MCPGrantRule {
    /// **A WING's reach, read OFF `decideWing`** — the twin of
    /// `reach(grants:openBook:target:)` (read off `decide`) and
    /// `reach(grants:openBook:gathering:)` (off `decideGathering`): from the
    /// top rung down, the first rung `decideWing` allows (a non-consuming
    /// probe — it spends nothing), its `.allow(grantID)` naming the grant (nil
    /// = the open book). Never a parallel rule: what a wing row says is what
    /// `list_notes` / `create_note` / `create_book` would be allowed on that
    /// wing — a live wing grant on THAT wing at its rung, or the open book at
    /// read. A note or book grant inside a wing never reaches the wing itself
    /// (R-VX185-1's reading, one level up — P-VX281-U2-4).
    public static func reach(grants: [Grant], openBook: Bool, wing wingID: String) -> Reach? {
        for rung in Rung.allCases.reversed() {
            guard case .allow(let grantID, _) = decideWing(
                client: .approved, grants: grants, openBook: openBook, wingID: wingID,
                rung: rung, consumes: false)
            else { continue }
            guard let grantID else { return Reach(rung: rung, standing: .openBook) }
            guard let grant = grants.first(where: { $0.id == grantID }) else { continue }
            return Reach(rung: rung, standing: .grant(grant))
        }
        return nil
    }
}
