//
//  ShelfOrder.swift
//  Variorum — App/Variorum/Shared (BOTH platforms)
//
//  **The shelf's ORDER and a smart book's TAG IDENTITY, in one place.**
//  HOISTED here at 13u1 UNIT 1 (the 2026-08-30 tech-debt sweep's **P40**).
//
//  Both rules lived twice — `ShelfViewModel.ordered`/`tagsColumn` on the Mac
//  and `MobileShelfFaces.ordered`/`tagPaths` on the phone, the same
//  statements in the same order, neither delegating to the other and neither
//  in a shared home. That is MobileSoul §3's drift class, and
//  `KnownIssuesAndTechDebt.md`'s forked-brain row says the fix is always a
//  HOIST, never a patch.
//
//  **The divergence this closes is not hypothetical.** The master plan's 13i
//  row carries her ruling *"CUSTOM SHELF ORDER MUST BE ADDED"*: a phase
//  editing the Mac's `ordered` to honour a stored custom order would have
//  left the phone on R38's pin-then-journal-then-name rule, and the two
//  shelves would have disagreed about the order of the same books with a
//  green suite on both sides.
//
//  **These two symbols were ALSO absent from the forked-brain row's
//  "eight-brain table", which presents itself as a grep-verified complete
//  enumeration** — P40's real finding. That row is amended at this batch,
//  because a stale completeness claim is worse than no claim: the next
//  session trusts it.
//
//  Each platform keeps its own FACE (leaf display, casing, the meta column's
//  count/smart split): the brain is shared, the chrome is not.
//

import Foundation
import VariorumCore

nonisolated enum ShelfOrder {
    /// Shelf order: **pinned books first, in PIN order** (R38), then
    /// journal-profile books by name (the journal lives on the shelf), then
    /// everything else by name.
    static func ordered(
        books: [Queries.ShelfBook], pins: [String]
    ) -> [Queries.ShelfBook] {
        var pinned: [Queries.ShelfBook] = []
        for pin in pins {
            if let book = books.first(where: { $0.reading.id == pin }) {
                pinned.append(book)
            }
        }
        let rest = books.filter { !pins.contains($0.reading.id) }
        let journals = rest.filter { $0.reading.profile == "journal" }
            .sorted { $0.reading.name < $1.reading.name }
        let others = rest.filter { $0.reading.profile != "journal" }
            .sorted { $0.reading.name < $1.reading.name }
        return pinned + journals + others
    }

    /// A SMART book's own query tags — `tagsAll` then `tags`, the shipped
    /// order — or **nil when the book is not smart**, which is the caller's
    /// signal to fall back to its curated aggregate
    /// (`Queries.shelfBookTags`' most-applied member paths). Nil rather than
    /// an empty array on purpose: "not a smart book" and "a smart book whose
    /// spec names no tag" are different answers and the caller acts
    /// differently on each.
    static func smartQueryTagPaths(of reading: Reading) -> [String]? {
        guard reading.kind == .smart else { return nil }
        guard let json = reading.querySpec,
              let spec = try? JSONDecoder().decode(
                  Queries.SmartQuerySpec.self, from: Data(json.utf8))
        else { return [] }
        return (spec.tagsAll ?? []) + (spec.tags ?? [])
    }
}
