//
//  WCutPlacement.swift
//  Variorum
//
//  13b Stage 4, Batch 4A — the ceremony sheet's PURE keyboard-placement
//  brain (N16(b)/(c) + the brief's keyboard family): ←/→ step the active
//  take's scissors one word edge at a time, ⌥←/→ jump by sentence (the
//  strong boundaries — sentence ends, newlines, and both parking ends),
//  ⇥ moves between checked takes. Pure functions over a take's legal
//  boundary list so every rule is unit-tested without a window; the sheet
//  wires keys to these and places through the one `placeWCut` door.
//

import Foundation
import VariorumCore

nonisolated enum WCutPlacement {
    /// The next boundary a word-step lands on. From an unplaced cut (nil),
    /// forward starts at the FIRST boundary and backward at the LAST — the
    /// scissors enter from the side you stepped toward. Stepping past
    /// either end stays parked there (no wraparound; the end slots are the
    /// parking positions, S4-22).
    static func wordStep(from cut: Int?, boundaries: [Int], forward: Bool) -> Int? {
        guard !boundaries.isEmpty else { return nil }
        guard let cut else { return forward ? boundaries.first : boundaries.last }
        if forward {
            return boundaries.first { $0 > cut } ?? boundaries.last
        }
        return boundaries.last { $0 < cut } ?? boundaries.first
    }

    /// The next STRONG boundary a sentence-step lands on: sentence ends,
    /// newlines, and both text ends (the parking slots), intersected with
    /// the take's legal boundaries. Falls back to a word step when no
    /// strong boundary lies in that direction beyond the current cut.
    static func sentenceStep(
        from cut: Int?, in text: String, boundaries: [Int], forward: Bool
    ) -> Int? {
        let strong = Set(BoundarySnapping.boundaries(in: text, granularity: .sentence))
        let strongBoundaries = boundaries.filter { strong.contains($0) }
        return wordStep(from: cut, boundaries: strongBoundaries, forward: forward)
            ?? wordStep(from: cut, boundaries: boundaries, forward: forward)
    }

    /// The next checked take's id after `current` (wrapping), for ⇥ / ⇧⇥.
    /// Unchecked takes are skipped — they have no cut to place.
    static func nextTake(
        after current: String?, in markedIDs: [String], forward: Bool
    ) -> String? {
        guard !markedIDs.isEmpty else { return nil }
        guard let current, let i = markedIDs.firstIndex(of: current) else {
            return forward ? markedIDs.first : markedIDs.last
        }
        let offset = forward ? 1 : markedIDs.count - 1
        return markedIDs[(i + offset) % markedIDs.count]
    }

    // MARK: - The token flow (the sheet's ✂-in-the-text rendering, pure half)

    /// One element of a marked take's cut flow: a placeable slot at a legal
    /// boundary, or a word token between two slots.
    enum FlowItem: Equatable {
        case slot(Int)
        /// `text` is the segment trimmed for display (separators are
        /// re-created by the flow's spacing); `breaksLineAfter` mirrors a
        /// newline in the raw segment so outline-style takes keep their
        /// line structure in the sheet.
        case token(text: String, breaksLineAfter: Bool)
    }

    /// The alternating slot/token sequence for a take: slot(b0), token,
    /// slot(b1), …, slot(end). `boundaries` is the take's legal cut list
    /// (`legalCutPositions`); empty boundaries answer an empty flow (the
    /// empty-take case — nothing to place).
    static func flowItems(text: String, boundaries: [Int]) -> [FlowItem] {
        guard boundaries.count >= 2 else { return [] }
        var items: [FlowItem] = []
        let ns = text as NSString
        for (i, boundary) in boundaries.enumerated() {
            items.append(.slot(boundary))
            guard i + 1 < boundaries.count else { break }
            let raw = ns.substring(
                with: NSRange(location: boundary, length: boundaries[i + 1] - boundary))
            let display = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            items.append(.token(
                text: display.isEmpty ? "⋯" : display,
                breaksLineAfter: raw.contains(where: \.isNewline)))
        }
        return items
    }
}
