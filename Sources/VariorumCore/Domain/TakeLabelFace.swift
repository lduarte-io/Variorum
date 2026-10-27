import Foundation

/// **A take's label on a narrow card: the part that tells takes apart is the
/// part kept** (VX-352 — RUN VX-548 batch 2a, the run record
/// `notes/plans/fixes/vx-548-run-mcp-grant-pane-fixes.md`; PROVISIONAL MB-4).
///
/// The traced face: the Takes card header (`TakeChooseHeader`) drew a take's
/// label as ONE `Text` with `lineLimit(1)`, so a narrow card cut it at its TAIL.
/// An AI take's label is `‹client› · ‹label›` (VX-267's convention — the client's
/// name first, so the fan always says who), so in Terminal's monospace at a
/// margin-grid card's width "claude-code · english" read "claude-code · e…" —
/// the client's name whole and the words that tell two takes apart gone (the
/// VX-336 U5 STAGE RUN, step 12; Study's proportional face fit it whole).
///
/// The rule, in two pure pieces the face composes (its `TakeLabelLine` layout):
/// - **`parts`** splits a label at its FIRST separator (`separator`, the spaced
///   middle dot `MCPWriteTools.labelSeparator` writes — pinned equal) into a
///   YIELDING head — the client's name, and the legacy `suggested` word with it
///   when the label is the pre-VX-267 `‹client› · suggested · ‹label›` — and a
///   KEPT tail: the separator and the label's own words. A label with no
///   separator (her own "english", a client's bare name) is ONE kept part —
///   today's face exactly.
/// - **`allocate`** gives the kept part its whole width FIRST and the head what
///   is left; each part then tail-truncates inside its own width, so a narrow
///   card reads "claud… · english", then "… · english", and only past that does
///   the label's own part give way. The old face was the READING-ORDER
///   allocation (the head first — one run cut at its tail).
///
/// The whole label is always the hover (`.help`). Labels are text: nothing here
/// decides who wrote a take — a label of hers that holds the separator splits
/// the same way, and only which side yields first is at stake.
///
/// Pure and dependency-free (no SwiftUI): widths are plain numbers, so the rule
/// is pinned headlessly (`TakeLabelFaceTests`).
public enum TakeLabelFace {
    /// The separator inside an AI take's label — a spaced middle dot
    /// (VX-267's `MCPWriteTools.labelSeparator`; pinned equal on the MCP side).
    public static let separator = " \u{00B7} "
    /// The word takes labelled before VX-267 carry between the client's name
    /// and the label (`MCPWriteTools.legacySuggestionWord`; pinned equal).
    public static let legacySuggestionWord = "suggested"

    /// A label's two parts as the card draws them.
    public struct Parts: Equatable, Sendable {
        /// What yields first on a narrow card — the client's name (with the
        /// legacy word); nil when the label has no separator to split at.
        public let yielding: String?
        /// What is kept whole — the separator and the label's own words, or
        /// the whole label when it has no separator.
        public let kept: String

        public init(yielding: String?, kept: String) {
            self.yielding = yielding
            self.kept = kept
        }
    }

    /// The label split for the card (see the type's doc).
    public static func parts(_ label: String) -> Parts {
        guard let first = label.range(of: separator, options: .literal),
              first.lowerBound > label.startIndex
        else { return Parts(yielding: nil, kept: label) }
        var cut = first.lowerBound
        // The legacy form: the `suggested` word yields with the client's name,
        // so the label's own words are what is kept.
        let legacy = legacySuggestionWord + separator
        if label[first.upperBound...].hasPrefix(legacy) {
            cut = label.index(first.upperBound, offsetBy: legacySuggestionWord.count)
        }
        let kept = String(label[cut...])
        let own = kept.dropFirst(separator.count).trimmingCharacters(in: .whitespacesAndNewlines)
        // A separator with nothing after it is no own part to keep.
        guard !own.isEmpty else { return Parts(yielding: nil, kept: label) }
        return Parts(yielding: String(label[..<cut]), kept: kept)
    }

    /// Each part's width on a card that offers `available` (nil — or room for
    /// both — gives each its ideal): the KEPT part first, whole while it fits
    /// (else all the room), then the yielding part what is left. Widths never
    /// go below zero and never above a part's ideal.
    public static func allocate(
        available: Double?, yielding: Double, kept: Double
    ) -> (yielding: Double, kept: Double) {
        let yielding = max(0, yielding), kept = max(0, kept)
        guard let available, available < yielding + kept else { return (yielding, kept) }
        let room = max(0, available)
        let keptWidth = min(kept, room)
        return (min(yielding, room - keptWidth), keptWidth)
    }
}
