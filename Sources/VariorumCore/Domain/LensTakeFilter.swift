//
//  LensTakeFilter.swift
//  VariorumCore (Domain)
//
//  **VX-170 — LENS-AWARE TAKES: the four filter forms, as one pure rule.**
//  Her ask (the 2026-10-11 editorial session): *"on the Takes page, expand
//  just the takes that belong to certain named lens columns … lenses are kinda
//  useful, but their surface is more for creating them — Takes has the better
//  views for reading them."* Her rulings the same day
//  (`notes/plans/vx-170-lens-aware-takes.md`, RATIFIED):
//
//  - **R-VX170-1 — the grammar is FOUR forms**: `in X` · `in A, not in B` ·
//    `X disagrees with Y` · `X disagrees with the chosen takes`. Arbitrary
//    boolean trees deferred.
//  - **R-VX170-3 — a matching block expands the filter-named take(s) plus the
//    chosen take** for contrast.
//  - **P-VX170-1 — a blank take is an ordinary take in every form** (R-VX171-2's
//    blank-take blanking: a blanked block IS `in X`, and blank-vs-chosen IS a
//    disagreement, so a lens's proposed deletions surface in the review).
//
//  **The one fact a lens contributes per block** (the shape file's
//  "Semantics"): it names a take there, or it does not. The fact is read from
//  the lens's EFFECTIVE picks (`Queries.effectiveLensSelection` — a pick whose
//  take is live, active and on the picked block), the same fact the MCP door's
//  `via` and her Lenses board read. **A DANGLING pick (archived, deleted, gone
//  or foreign) therefore names NOTHING** — PROVISIONAL P-VX168-U4-2, the one
//  reading every surface already gives it (the wire answers `via: chosen`, the
//  board falls through to the chosen take).
//
//  "Disagree" compares take IDENTITY, never text: R-VX170-1's own words are
//  "both name takes, DIFFERENT ONES". Two takes with byte-identical text are
//  still two takes (sameness of text is the Lenses board's tint, a different
//  question). The "chosen takes" are the slots' RENDERED takes (`renderPost`'s
//  chosen-else-default) — what the note shows.
//
//  Pure, `nonisolated`, store-free — the `KeepOnTopDivide` pattern — so every
//  arm is a unit test and a phone face could call it unchanged. Cost is one
//  pass over the note's slots (P1: ∝ the note, never the corpus).
//

import Foundation

public nonisolated enum LensTakeFilter: Hashable, Sendable {
    /// `in X` — X names a take on the block.
    case inLens(String)
    /// `in A, not in B` — A names a take on the block, B names none.
    case inLensNotIn(String, String)
    /// `X disagrees with Y` — both name takes there, and they are different
    /// takes.
    case disagree(String, String)
    /// `X disagrees with the chosen takes` — X names a take that is not the
    /// one the note shows there.
    case disagreeWithChosen(String)

    // MARK: - The forms (the popover's rows, in her order)

    /// The four forms in R-VX170-1's order — the popover lists them so.
    public enum Form: Hashable, Sendable, CaseIterable {
        case inLens, inLensNotIn, disagree, disagreeWithChosen

        /// How many lenses the form names (the popover's pickers).
        public var lensCount: Int {
            switch self {
            case .inLens, .disagreeWithChosen: 1
            case .inLensNotIn, .disagree: 2
            }
        }
    }

    public var form: Form {
        switch self {
        case .inLens: .inLens
        case .inLensNotIn: .inLensNotIn
        case .disagree: .disagree
        case .disagreeWithChosen: .disagreeWithChosen
        }
    }

    /// The lenses the filter names, in the expression's order.
    public var lensIDs: [String] {
        switch self {
        case .inLens(let x), .disagreeWithChosen(let x): [x]
        case .inLensNotIn(let a, let b), .disagree(let a, let b): [a, b]
        }
    }

    /// A form with its operands — nil when the count is wrong, or when a
    /// two-lens form names ONE lens twice: `in A, not in A` and `A disagrees
    /// with A` can only ever match nothing, and a door that could only empty
    /// the page is a false offer (P-2).
    public init?(form: Form, lenses: [String]) {
        guard lenses.count == form.lensCount else { return nil }
        switch form {
        case .inLens: self = .inLens(lenses[0])
        case .disagreeWithChosen: self = .disagreeWithChosen(lenses[0])
        case .inLensNotIn:
            guard lenses[0] != lenses[1] else { return nil }
            self = .inLensNotIn(lenses[0], lenses[1])
        case .disagree:
            guard lenses[0] != lenses[1] else { return nil }
            self = .disagree(lenses[0], lenses[1])
        }
    }

    // MARK: - The rule, per block

    /// **The takes this filter NAMES on one block, or nil when the block does
    /// not match.** `pick(lens)` is the take that lens names ON THIS BLOCK —
    /// its effective pick, nil where it names none (a dangling pick included).
    /// `shown` is the take the note shows there (nil on a gap slot, which never
    /// matches — nothing renders there to compare with).
    ///
    /// The named takes come back in the expression's order, deduplicated.
    public func namedTakes(shown: String?, pick: (String) -> String?) -> [String]? {
        guard shown != nil else { return nil }
        switch self {
        case .inLens(let x):
            guard let px = pick(x) else { return nil }
            return [px]
        case .inLensNotIn(let a, let b):
            guard let pa = pick(a), pick(b) == nil else { return nil }
            return [pa]
        case .disagree(let x, let y):
            guard let px = pick(x), let py = pick(y), px != py else { return nil }
            return [px, py]
        case .disagreeWithChosen(let x):
            guard let px = pick(x), px != shown else { return nil }
            return [px]
        }
    }

    /// **R-VX170-3's expand set for one block** — the named takes plus the
    /// shown take, in FAN order (the order every bloom style already draws).
    /// nil when the block does not match.
    public func expandSet(
        shown: String?, fan: [String], pick: (String) -> String?
    ) -> [String]? {
        guard let named = namedTakes(shown: shown, pick: pick) else { return nil }
        var wanted = Set(named)
        if let shown { wanted.insert(shown) }
        return fan.filter { wanted.contains($0) }
    }

    // MARK: - The rule, over a note

    /// One slot of the note, as the rule needs it.
    public struct Block: Equatable, Sendable {
        public let blockID: String
        /// The rendered take (nil = a gap).
        public let shownTakeID: String?
        /// The block's live ACTIVE fan, in fan order.
        public let fanTakeIDs: [String]

        public init(blockID: String, shownTakeID: String?, fanTakeIDs: [String]) {
            self.blockID = blockID
            self.shownTakeID = shownTakeID
            self.fanTakeIDs = fanTakeIDs
        }
    }

    /// The filter's answer over a whole note.
    public struct Evaluation: Equatable, Sendable {
        /// blockID → the takes a MATCHING block expands (R-VX170-3), in fan
        /// order. A block absent here does not match.
        public let expanded: [String: [String]]
        /// Every slot the note holds — the honest denominator ("N of M").
        public let blockCount: Int

        public init(expanded: [String: [String]], blockCount: Int) {
            self.expanded = expanded
            self.blockCount = blockCount
        }

        public var matchCount: Int { expanded.count }

        public func matches(_ blockID: String) -> Bool { expanded[blockID] != nil }
    }

    /// The filter over a note: `selections` is lensID → blockID → the take
    /// (the EFFECTIVE picks — `TakesProjection.lensSelections`). One pass,
    /// cost ∝ the note.
    public func evaluate(
        _ blocks: [Block], selections: [String: [String: String]]
    ) -> Evaluation {
        var expanded: [String: [String]] = [:]
        for block in blocks {
            if let set = expandSet(
                shown: block.shownTakeID, fan: block.fanTakeIDs,
                pick: { selections[$0]?[block.blockID] })
            {
                expanded[block.blockID] = set
            }
        }
        return Evaluation(expanded: expanded, blockCount: blocks.count)
    }
}

// MARK: - Over the Takes board's projection

extension Queries.TakesProjection {
    /// The filter over THIS projection — the board's slots (their rendered
    /// takes), their active fans and the lenses' effective picks, exactly the
    /// facts the board draws from. A pure read of values already in hand.
    public nonisolated func evaluate(_ filter: LensTakeFilter) -> LensTakeFilter.Evaluation {
        filter.evaluate(
            slots.map { slot in
                LensTakeFilter.Block(
                    blockID: slot.blockID, shownTakeID: slot.variantID,
                    fanTakeIDs: (fans[slot.blockID] ?? []).map(\.id))
            },
            selections: lensSelections)
    }
}
