//
//  LibrarySearchOrderDoor.swift
//  Variorum (Mac)
//
//  **VX-820 — the answer sheet's order door** (her R-819-2, *"Full
//  vocabulary"*: while a search is live the sort door offers relevance —
//  leading, the default per search — · edited · created · date · title,
//  with direction, exactly like the Library's own `sort ▾`). It stands in
//  the controls row's sort slot while the field asks with words, where the
//  plain label "relevance · best first" stood (P-13o-U2-7's label, retired:
//  the order can change now, so the slot is a door — P-2).
//
//  The words are the Library door's own (`LibrarySortFace`, one vocabulary)
//  plus relevance's; the value and its lifecycle are the search state's
//  (`LibrarySearchModel.order`); the core order is `SearchOrder`.
//

import SwiftUI
import VariorumCore

/// What the order door says (pure — no view spells a label).
nonisolated enum LibrarySearchOrderFace {
    /// Her five, in her order — relevance first (nil), then the Library
    /// door's four (`LibrarySortFace.offered`).
    static let offered: [Queries.LibrarySort?] = [nil] + LibrarySortFace.offered.map { Optional($0) }

    /// One lower-case word per row.
    static let relevanceWord = "relevance"

    static func label(_ sort: Queries.LibrarySort?) -> String {
        sort.map(LibrarySortFace.label) ?? relevanceWord
    }

    /// The door's own label — what the sheet is DOING: relevance's words
    /// ("relevance · best first"), or the Library door's own for a home
    /// order ("created · oldest first").
    static func doorLabel(_ order: SearchOrder) -> String {
        switch order {
        case .relevance: LibrarySearchCopy.relevance
        case .home(let sort, let direction): LibrarySortFace.doorLabel(sort, direction)
        }
    }

    /// The pick the order IS (nil = relevance) — the row wearing the ✓.
    static func picked(_ order: SearchOrder) -> Queries.LibrarySort? {
        if case .home(let sort, _) = order { return sort }
        return nil
    }

    /// The door's tooltip, composed from the one word table (the 18h
    /// ladder's R3-8 rule — never re-spelled). PROVISIONAL wording.
    static var doorHelp: String {
        "Order the results \u{2014} " + offered.map(label).joined(separator: " \u{B7} ")
            + "; relevance puts the best match first"
    }
}

/// The search state's `order ▾` — the five orders, then (for a home order)
/// the two directions in that sort's language. A pick is handed up; the
/// search state owns the value and the view spawns the re-read (the
/// `LibrarySortMenu` convention, one file over).
struct LibrarySearchOrderMenu: View {
    let tokens: VoiceTokens
    let order: SearchOrder
    let onPick: (Queries.LibrarySort?) -> Void
    let onDirection: (SortDirection) -> Void

    var body: some View {
        VoicedMenu(tokens: tokens, label: LibrarySearchOrderFace.doorLabel(order), role: .secondary) {
            let picked = LibrarySearchOrderFace.picked(order)
            ForEach(LibrarySearchOrderFace.offered, id: \.self) { option in
                Button {
                    onPick(option)
                } label: {
                    Text(option == picked
                         ? "\u{2713} \(LibrarySearchOrderFace.label(option))"
                         : LibrarySearchOrderFace.label(option))
                }
            }
            // Relevance has no direction arm — best first IS its meaning.
            if case .home(let sort, let direction) = order {
                Divider()
                ForEach([SortDirection.desc, .asc], id: \.self) { option in
                    Button {
                        onDirection(option)
                    } label: {
                        Text(option == direction
                             ? "\u{2713} \(LibrarySortFace.directionLabel(sort, option))"
                             : LibrarySortFace.directionLabel(sort, option))
                    }
                }
            }
        }
        .help(LibrarySearchOrderFace.doorHelp)
    }
}
