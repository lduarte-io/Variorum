import Foundation

/// **CHANGE… REPLACES ONLY ITS OWN PLACE** (VX-516 — the VX-548 run, batch 1;
/// PROVISIONAL MB-1, the run record `notes/plans/fixes/vx-548-run-mcp-grant-pane-fixes.md`).
/// Pure, so the decision is pinned headless; the grant sheet reads it at its
/// one confirm (`MCPGrantSheet.submit`) and everywhere it says what that
/// confirm will do (its title, its replaces line, the receipt's verb).
///
/// THE TRACE (her Air report, 2026-10-23: "it keeps just changing what is
/// shown though - it doesn't show both & I can see that the other one is
/// revoked when I grant that one"): every Change… road — a Shared-with-AI
/// row's, an act's, a receipt's, a shared icon's popover — opens THE grant
/// sheet pre-filled on exactly the grant(s) it names, and names them to
/// replace (T-U3-8 — `MCPGrantOpening.replacing`). The sheet's WHERE stays
/// open to a new pick, and its confirm passed `replacing` through whatever
/// place was confirmed. So Change… on the PlanetLillian wing grant, with
/// another wing picked, revoked PlanetLillian and minted the other — two
/// wings could never stand together through it. (The one mint,
/// `insertMCPGrant`, was always per place — VX-393's index is per client ×
/// place; the revoke came from the replace the sheet named.)
///
/// THE RULE: Change…'s replace (T-U3-8's ruled purpose, "change its details
/// fast" — the rung, the duration) stands only while the place confirmed IS
/// the place the sheet was opened on. Confirming a DIFFERENT place is a new
/// grant: nothing is replaced, so the grant it was opened on stands beside
/// the new one.
public enum MCPGrantChange {
    /// One grant place: a note, a book or a wing (`""` = the virtual Home
    /// wing) — exactly a grant row's `scope_kind` × `scope_id`.
    public struct Place: Hashable, Sendable {
        public let kind: MCPGrantRule.ScopeKind
        public let id: String

        public init(_ kind: MCPGrantRule.ScopeKind, _ id: String) {
            self.kind = kind
            self.id = id
        }
    }

    /// Whether a confirm keeps the replace its opening named.
    ///
    /// - Parameters:
    ///   - opened: the place(s) the sheet was opened on — every Change… road
    ///     pre-fills exactly the place(s) of the grant(s) it names (one
    ///     grant's own place; an act's notes, in its order). Empty for a
    ///     sheet opened fresh.
    ///   - confirmed: the place(s) the confirm grants.
    /// - Returns: true only when both are non-empty and every confirmed place
    ///   is an opened one. An act's notes are SAID, never re-chosen, and a
    ///   note gone since leaves the confirm (never adds one), so an act's
    ///   Change… keeps its replace; a single place must be the very place.
    public static func keepsReplacing(opened: Set<Place>, confirmed: Set<Place>) -> Bool {
        !opened.isEmpty && !confirmed.isEmpty && confirmed.isSubset(of: opened)
    }

    /// The grants a confirm REPLACES: the ones its opening named, while the
    /// confirm keeps the replace (`keepsReplacing`); none otherwise — a new
    /// grant, revoking nothing.
    public static func replacing(_ named: [String], opened: Set<Place>, confirmed: Set<Place>) -> [String] {
        keepsReplacing(opened: opened, confirmed: confirmed) ? named : []
    }
}
