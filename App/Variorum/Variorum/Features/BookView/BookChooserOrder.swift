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
//  context bar's in-line ("in <top pick> & N more") — because the sentence
//  under the title and the list it opens must not disagree about which book
//  comes first.
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
            let aCurated = a.kind == .curated
            let bCurated = b.kind == .curated
            if aCurated != bCurated { return aCurated }
            let aRank = rank[a.id] ?? Int.max
            let bRank = rank[b.id] ?? Int.max
            if aRank != bRank { return aRank < bRank }
            if a.name != b.name { return a.name < b.name }
            return a.id < b.id
        }
    }

    /// The context bar's one line: the top pick, plus how many others there
    /// are. nil when the post is in no book — the bar says nothing rather
    /// than saying "in no book", which is the masthead chip's job and not a
    /// reason to grow chrome.
    static func inLine(_ books: [Reading]) -> String? {
        guard let first = books.first else { return nil }
        if books.count == 1 { return "in \(first.name)" }
        return "in \(first.name) & \(books.count - 1) more"
    }
}
