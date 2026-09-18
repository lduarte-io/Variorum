//
//  ProseHeightModel.swift
//  Variorum (Mac) — Surface (the pure surface authorities' home, beside
//  `BookHeightManifest` and `PaneTextAuthority`)
//
//  **Phase 13u2b UNIT 2 — the hoist UNIT 1 marked and left standing: ONE
//  model of how tall stored prose stands, for the two surfaces that ask.**
//
//  UNIT 1 wrote the reason at its own code, verbatim: *"the flow's own shape
//  (`FlowHeightEstimate`), restated here at the OUTLINE's measure and type
//  rather than shared, because the flow is UNIT 2's to adopt and a shared
//  brain minted while one consumer is out of scope is a refactor nobody
//  measured. **The hoist belongs to UNIT 2**, where the flow becomes the
//  second consumer of this file (the hoist-at-next-touch rule's own moment)."*
//  This is that moment, and this is the one model.
//
//  **What the model is** (measured against the real Sherlock library at batch
//  H, and re-measured at UNIT 1 against the same book at Write's measure):
//  a block is its own paragraph and its internal newlines are content (I4);
//  a stored block normally ends in ONE separator newline that renders
//  nothing, so its paragraphs are `max(1, newlines)`; each paragraph ends
//  mid-line, which wastes half a line on average; `lineSpacing` sits only
//  BETWEEN a paragraph's lines, never after its last; a paragraph gap sits
//  between paragraphs and between blocks. Nothing here reads PROSE — the
//  inputs are `Queries.BlockExtent` lengths computed in SQL (AppSpec §4's own
//  designed fallback, *"stored per-block length estimates, not live
//  geometry"*), so the cost is ∝ blocks and never ∝ text (P1).
//
//  **What it deliberately does NOT own: the empty answer, the rounding and
//  the floor.** Those differ between its two consumers and each difference is
//  a real fact about a real surface — the page's blank line is 20 pt and the
//  editor's is 24; the flow carries a calibration factor and the Outline
//  clamps at its own empty height. A hoist that swallowed them would have
//  changed both surfaces' arithmetic in the name of sharing, which is the
//  opposite of what a hoist is for. So this returns the raw total and `nil`
//  for "nothing renders", and each caller finishes the sentence in its own
//  voice.
//

import CoreGraphics
import Foundation
import VariorumCore

nonisolated enum ProseHeightModel {
    /// The type facts the model wraps text at. The defaults are the OUTLINE's
    /// (they were `BookOutlineHeightModel.ProseMetrics`' defaults, which is
    /// now a typealias for this) — the flow builds its own explicitly from
    /// the page's constants, because the page's type is voice-independent and
    /// the editor's is not.
    struct Metrics: Equatable {
        /// Characters of this face that fit the column's measure.
        var charsPerLine: Double = 80
        /// One line's pitch: the font's line height plus any line spacing the
        /// surface lays out with.
        var linePitch: CGFloat = 19
        /// The spacing BETWEEN a paragraph's lines (so one pitch's worth is
        /// owed back for every paragraph's last line).
        var lineSpacing: CGFloat = 0
        /// The gap between paragraphs, and between blocks.
        var paragraphGap: CGFloat = 7

        init(
            charsPerLine: Double = 80, linePitch: CGFloat = 19,
            lineSpacing: CGFloat = 0, paragraphGap: CGFloat = 7
        ) {
            self.charsPerLine = charsPerLine
            self.linePitch = linePitch
            self.lineSpacing = lineSpacing
            self.paragraphGap = paragraphGap
        }
    }

    /// The paragraphs a block RENDERS from its newline count: the stored
    /// separator renders nothing, so a normal block is one paragraph and each
    /// newline beyond the separator is a real break.
    static func paragraphs(newlines: Int) -> Int { max(1, newlines) }

    /// The lines one block occupies: its paragraphs at minimum, else its
    /// wrapped length plus each paragraph's half-line tail.
    static func lines(characters: Int, newlines: Int, metrics: Metrics) -> Double {
        guard characters > 0, metrics.charsPerLine > 0 else { return 0 }
        let paragraphs = Double(Self.paragraphs(newlines: newlines))
        let full = Double(characters) / metrics.charsPerLine
        return max(paragraphs, full + paragraphs * 0.5)
    }

    /// The prose's height from its blocks' lengths — **unrounded**, and `nil`
    /// when nothing renders (a note of blank takes, or of none). The caller
    /// names the empty answer, applies any calibration, rounds and floors.
    static func height(extents: [Queries.BlockExtent], metrics: Metrics) -> CGFloat? {
        let rendered = extents.filter { $0.characters > 0 }
        guard !rendered.isEmpty, metrics.charsPerLine > 0 else { return nil }
        var total: CGFloat = 0
        for extent in rendered {
            let lines = Self.lines(
                characters: extent.characters, newlines: extent.newlines, metrics: metrics)
            let paragraphs = CGFloat(Self.paragraphs(newlines: extent.newlines))
            total += CGFloat(lines) * metrics.linePitch - paragraphs * metrics.lineSpacing
                + (paragraphs - 1) * metrics.paragraphGap
        }
        total += CGFloat(rendered.count - 1) * metrics.paragraphGap
        return total
    }
}
