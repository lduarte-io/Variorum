import Foundation

/// **THE ANSWER SHEET'S ORDER** (VX-820 — her R-819-2, *"Full vocabulary"*:
/// while a search is live the sort door offers relevance — leading, the
/// default per search — · edited · created · date · title, with direction,
/// exactly like the Library's own `sort ▾`).
///
/// The order re-ranks the sheet's GROUPS — a note, or a scraps group — by
/// their HOME, through the Library's own sort semantics
/// (`Queries.LibrarySort`'s keys: edited `COALESCE(last_touched_at,
/// created_at)`, created, date `COALESCE(entry_date, created_at)` — VX-758's
/// rule — and title `COALESCE(NULLIF(title, ''), entry_date, created_at)`
/// case-folded), tie-broken on the home's id in the same direction. It never
/// reshuffles a group's own passages: those stay best-first within their
/// note under every order (the brief, PROVISIONAL).
///
/// P1: a home order is the SAME walk of the matches the relevance order is
/// (the grouping already reads every match), the key read off the home row
/// the hits already join — no per-row read; keyset-paged on `(key, home)`
/// so every group is reachable (R-13o-9).
public enum SearchOrder: Equatable, Sendable {
    /// Best first — the composer's own rank (`bm25 × the kind's weight × the
    /// rendered-take boost`). Every search starts here.
    case relevance
    /// The Library's sort over each group's home, in a direction.
    case home(Queries.LibrarySort, SortDirection)

    /// The order's key over a container alias — nil under relevance.
    func homeKey(over alias: String) -> String? {
        guard case .home(let sort, _) = self else { return nil }
        return sort.keyExpression(over: alias)
    }

    /// Whether the key compares case-folded (SQLite's `NOCASE`: ASCII A–Z
    /// folded, then byte order) — read from the sort's ONE collation truth
    /// (`Queries.LibrarySort.foldsCase`, which the statement's
    /// `keyCollation` reads too — the VX-819 ladder's F5), never restated.
    var foldsCase: Bool {
        guard case .home(let sort, _) = self else { return false }
        return sort.foldsCase
    }

    // MARK: - The order, in Swift (the worn-day merge — `Queries.searchGroups`)

    /// One group's place under a home order: its key and its home's id.
    struct Place: Equatable {
        let key: String
        let homeID: String
    }

    /// **Does `a` come before `b` under this order?** — exactly as the
    /// composer's `ORDER BY key [COLLATE NOCASE] dir, home dir` places them:
    /// the keys compared as SQLite compares TEXT (`BINARY` — UTF-8 bytes,
    /// then length — or `NOCASE`, ASCII A–Z folded first), equal keys tie-
    /// broken on the home id's bytes, both in the order's direction. Used to
    /// place what the statement cannot list (a nameless note WEARING the
    /// named day with no index hit) among what it did. Relevance has no such
    /// order: false.
    func precedes(_ a: Place, _ b: Place) -> Bool {
        guard case .home(_, let direction) = self else { return false }
        var c = Self.compareText(a.key, b.key, foldingCase: foldsCase)
        if c == 0 { c = Self.compareText(a.homeID, b.homeID, foldingCase: false) }
        return direction == .asc ? c < 0 : c > 0
    }

    /// SQLite's TEXT comparison (`BINARY`: `memcmp` of the UTF-8 bytes, the
    /// shorter first on a common prefix; `NOCASE`: the same after folding the
    /// 26 ASCII capitals). −1 · 0 · 1.
    static func compareText(_ a: String, _ b: String, foldingCase: Bool) -> Int {
        func bytes(_ s: String) -> [UInt8] {
            let raw = Array(s.utf8)
            guard foldingCase else { return raw }
            return raw.map { (65...90).contains($0) ? $0 + 32 : $0 }
        }
        let x = bytes(a), y = bytes(b)
        for (p, q) in zip(x, y) where p != q { return p < q ? -1 : 1 }
        return x.count == y.count ? 0 : (x.count < y.count ? -1 : 1)
    }
}
