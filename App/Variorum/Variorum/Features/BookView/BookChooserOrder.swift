//
//  BookChooserOrder.swift
//  Variorum
//
//  Phase 13f, batch 5 — W20(c): the order a post's books are OFFERED in.
//
//  Her round-10 words, both floated and neither firm: *"prioritizing
//  manually adjusted books over smartbooks where it was auto added in the
//  chip selector maybe, or what book you were most recently in or
//  something"*. The architect's shaping (overturnable on her walk, and
//  stated here so it can be): **curated before smart, and inside each group
//  the session's most-recently-visited floats to the top.**
//
//  It is ONE pure rule with TWO readers — the chip's popover list and the
//  context bar's book door (whose click opens the top pick and whose
//  dropdown lists them all) — because the door and the list it opens must
//  not disagree about which book comes first.
//
//  **13k K11 retired `inLine`**, the bar's spelled-out "in <top pick> & N
//  more" sentence: her ruling replaced it with the book ICON, so there is
//  no in-line left to write. The ORDER below is untouched and is what both
//  readers still share.
//
//  Smart matches are LISTED, not filtered: derived membership IS membership
//  (her round-10 ruling 2; QUESTIONS #26(h)), and "the books it is in" is
//  ratified as "the places you can navigate to".
//

import Foundation
import VariorumCore

nonisolated enum BookChooserOrder {
    /// `recentlyVisited`: book ids, MOST RECENT FIRST (the workspace's
    /// session trail). Ids it does not know sort after the ones it does,
    /// then by name and id so the order is total and device-independent.
    static func ordered(_ books: [Reading], recentlyVisited: [String]) -> [Reading] {
        var rank: [String: Int] = [:]
        for (index, id) in recentlyVisited.enumerated() where rank[id] == nil {
            rank[id] = index
        }
        return books.sorted { a, b in
            let aCurated = a.kind == .book
            let bCurated = b.kind == .book
            if aCurated != bCurated { return aCurated }
            let aRank = rank[a.id] ?? Int.max
            let bRank = rank[b.id] ?? Int.max
            if aRank != bRank { return aRank < bRank }
            if a.name != b.name { return a.name < b.name }
            return a.id < b.id
        }
    }
}
