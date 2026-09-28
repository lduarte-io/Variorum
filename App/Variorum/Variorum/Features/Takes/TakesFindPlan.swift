//
//  TakesFindPlan.swift
//  Variorum
//
//  18l-c UNIT U7 — SEARCH IN TAKES, find-only v1 (her R-18l-6: *"I think that
//  we should add a search in takes mode, yes that will be this phase"*; the
//  design record is `notes/plans/phase-18l-c-navigation-feel.md`'s U7 DESIGN
//  BRIEF — decision 2 is this file).
//
//  **THE MATCH MODEL, as a pure brain.** Given the open note's slots (each
//  slot's SHOWN take and its other live takes, texts already overlaid with any
//  unsettled buffer), a query and a scope, it answers the ordered matches —
//  (block, take, range, on-the-shown-take) in the order her eye reads the
//  board: slot by slot, and inside a slot the take the article shows first,
//  then the block's other takes in fan order (the fan blooms BELOW the cell).
//  Nothing here reads a store, a view or a clock; `TakesFindController` hands
//  it what the board already holds.
//
//  **ONE RULE OF SAMENESS ACROSS THE TWO BARS** (decision 2). Write's find bar
//  is AppKit's `NSTextFinder`, configured with NO compare options of its own
//  (`EditorTextView.makeEditor`: `usesFindBar`, incremental off — nothing
//  else), so the rule it matches by is the finder's built-in default. That
//  default is MEASURED, not assumed, and this brain's `compareOptions` is
//  pinned against the real finder over the same text
//  (`TakesFindTests.theTwoBarsAgreeOnWhatAMatchIs`) — so a point release that
//  moves the finder's rule reds the pin instead of splitting the two bars.
//
//  P1: bounded by the open note (the brief's own letter) — a whole-note scan
//  is a deliberate find act's cost, never a keystroke's. The controller keeps
//  a per-take cache so a settle rescans only the takes whose text moved.
//

import Foundation

nonisolated enum TakesFindPlan {
    // MARK: - Inputs

    /// One take's text, as the board would show it (the buffer overlay applied).
    struct Take: Equatable, Sendable {
        let variantID: String
        let text: String
    }

    /// One slot of the note, in the article's order.
    struct Slot: Equatable, Sendable {
        let blockID: String
        /// The article `ForEach`'s identity — what a landing names.
        let placementID: String
        /// The take the article SHOWS (nil for a gap slot, which has no text).
        let shown: Take?
        /// The block's OTHER live ACTIVE takes, in fan order (archived takes
        /// are out of view by definition and never searched — decision 3,
        /// PROVISIONAL).
        let others: [Take]
    }

    /// Decision 3 (her ruling R-18l-6 — *"search only in chosen takes should
    /// be a default selected to on decision"*): ON is each block's SHOWN take
    /// only; OFF is every live take.
    enum Scope: Equatable, Sendable {
        case shownTakesOnly
        case everyLiveTake
    }

    // MARK: - Output

    struct Match: Equatable, Hashable, Sendable {
        let blockID: String
        let placementID: String
        let variantID: String
        /// UTF-16 — the unit every pane surface speaks.
        let range: NSRange
        /// True when the match is on the take the article shows (R-18l-10's
        /// off-scope matches are the others).
        let onShownTake: Bool
        /// Where the match sits in reading order: its slot's index, then its
        /// take's place in the slot (0 = the shown take, 1… = the fan's
        /// others), then its offset. Stepping and re-anchoring compare these.
        let order: Order
    }

    /// A match's reading position — comparable, so "the first match after the
    /// caret" is one comparison, not a walk.
    struct Order: Comparable, Hashable, Sendable {
        let slot: Int
        let take: Int
        let location: Int

        static func < (lhs: Order, rhs: Order) -> Bool {
            (lhs.slot, lhs.take, lhs.location) < (rhs.slot, rhs.take, rhs.location)
        }
    }

    // MARK: - The compare rule (measured — see the header)

    /// **How two strings are "the same" — the Write bar's rule, measured.**
    /// `NSTextFinder`'s built-in default is "Contains" with "Ignore Case"
    /// (the find bar's own option menu, untouched by this app), which it runs
    /// as a case-insensitive, NON-literal `NSString` search: canonically
    /// equivalent spellings match (a precomposed é and e + a combining acute
    /// are one character), letter case does not matter, and DIACRITICS DO —
    /// "cafe" does not find "café". Pinned against the real finder.
    static let compareOptions: NSString.CompareOptions = [.caseInsensitive]

    /// Every match of `query` in `text`, left to right, NON-OVERLAPPING — the
    /// finder's own stepping (a find-next resumes after the match it
    /// selected, so "aa" in "aaaa" is two matches, not three). Empty query ⇒
    /// none, and no residue anywhere.
    static func ranges(of query: String, in text: String) -> [NSRange] {
        guard !query.isEmpty, !text.isEmpty else { return [] }
        let haystack = text as NSString
        var found: [NSRange] = []
        var from = 0
        while from < haystack.length {
            let hit = haystack.range(
                of: query, options: compareOptions,
                range: NSRange(location: from, length: haystack.length - from))
            guard hit.location != NSNotFound, hit.length > 0 else { break }
            found.append(hit)
            from = hit.upperBound
        }
        return found
    }

    // MARK: - The plan

    /// The ordered matches over the note. `ranges` answers one take's matches
    /// — the controller passes its per-take cache; the default scans afresh.
    static func matches(
        in slots: [Slot], scope: Scope,
        ranges: (Take) -> [NSRange]
    ) -> [Match] {
        var out: [Match] = []
        for (slotIndex, slot) in slots.enumerated() {
            if let shown = slot.shown {
                for range in ranges(shown) {
                    out.append(Match(
                        blockID: slot.blockID, placementID: slot.placementID,
                        variantID: shown.variantID, range: range, onShownTake: true,
                        order: Order(slot: slotIndex, take: 0, location: range.location)))
                }
            }
            guard scope == .everyLiveTake else { continue }
            for (takeIndex, take) in slot.others.enumerated() {
                for range in ranges(take) {
                    out.append(Match(
                        blockID: slot.blockID, placementID: slot.placementID,
                        variantID: take.variantID, range: range, onShownTake: false,
                        order: Order(slot: slotIndex, take: takeIndex + 1, location: range.location)))
                }
            }
        }
        return out
    }

    /// The whole-note scan, without a cache (the pins' door).
    static func matches(query: String, in slots: [Slot], scope: Scope) -> [Match] {
        matches(in: slots, scope: scope) { ranges(of: query, in: $0.text) }
    }

    /// **R-18l-10's indicator, counted:** per block, how many matches sit on
    /// takes the article is NOT showing. Only non-zero blocks appear.
    static func offScopeCounts(_ matches: [Match]) -> [String: Int] {
        var counts: [String: Int] = [:]
        for match in matches where !match.onShownTake {
            counts[match.blockID, default: 0] += 1
        }
        return counts
    }

    // MARK: - Stepping (decision 8 — wrap-around at the ends)

    /// Where a step lands. `wrapped` is true when it went past an end and came
    /// round — said in the count face, the platform standard.
    struct Step: Equatable, Sendable {
        let index: Int
        let wrapped: Bool
    }

    /// The next (or previous) match from `origin` — a reading position (the
    /// current match's, or the live caret's) — wrapping at the ends. With no
    /// origin, forward starts at the first match and backward at the last.
    /// `strictly` excludes a match AT the origin (stepping off the current
    /// match); a caret origin includes a match starting exactly there.
    static func step(
        from origin: Order?, in matches: [Match], forward: Bool, strictly: Bool = true
    ) -> Step? {
        guard !matches.isEmpty else { return nil }
        guard let origin else {
            return Step(index: forward ? 0 : matches.count - 1, wrapped: false)
        }
        if forward {
            if let index = matches.firstIndex(where: {
                strictly ? $0.order > origin : $0.order >= origin
            }) {
                return Step(index: index, wrapped: false)
            }
            return Step(index: 0, wrapped: true)
        }
        if let index = matches.lastIndex(where: {
            strictly ? $0.order < origin : $0.order <= origin
        }) {
            return Step(index: index, wrapped: false)
        }
        return Step(index: matches.count - 1, wrapped: true)
    }

    /// A match that no longer exists after a recount (the text moved, the
    /// scope changed): the current match becomes the first one at or after
    /// where it was, or none — the count then reads "M matches" until the next
    /// step, never a stale "n of M".
    static func reanchor(_ old: Match?, in matches: [Match]) -> Int? {
        guard let old else { return nil }
        if let same = matches.firstIndex(of: old) { return same }
        return matches.firstIndex { $0.order >= old.order }
    }

    // MARK: - The count face (decision 1's "N of M"; decision 8's wrap)

    /// The bar's own quiet words — never a toast (decision 8: "No matches" is
    /// the bar's own face, the door speaks in place).
    static func countFace(total: Int, current: Int?, wrapped: Bool, query: String) -> String {
        guard !query.isEmpty else { return "" }
        guard total > 0 else { return TakesFindCopy.noMatches }
        guard let current else { return TakesFindCopy.matchCount(total) }
        return TakesFindCopy.position(current + 1, of: total, wrapped: wrapped)
    }
}

/// The bar's words, in one place (P-1's copy discipline).
nonisolated enum TakesFindCopy {
    static let noMatches = "No matches"
    static func matchCount(_ total: Int) -> String {
        total == 1 ? "1 match" : "\(total) matches"
    }
    static func position(_ n: Int, of total: Int, wrapped: Bool) -> String {
        "\(n) of \(total)" + (wrapped ? " · wrapped" : "")
    }
    /// R-18l-10's marker on a card: matches the article is not showing.
    static func offScopeMarker(_ count: Int) -> String {
        count == 1 ? "1 in another take" : "\(count) in other takes"
    }
    static let scopeChip = "only chosen takes"
    static let fieldPrompt = "Find in this note's takes"
}
