import Foundation

/// The merge join, as a value: HOW two takes' texts meet when blocks merge
/// (13b Stage 4, Batch 4B — the ruled merge-ceremony addendum,
/// `notes/plans/phase-13b-memo-merge.md`).
///
/// The canon rule (AppSpec §9, author decision 2026-07-06) is a RESOLVER,
/// not a case: `canon(head:tail:)` answers "a single space at the join
/// unless either side's edge already carries whitespace" by returning the
/// explicit join it resolves to. The instant merge uses exactly that; the
/// ceremony's three-way control (space · newline · nothing) exposes the
/// same three explicit joins with the canon resolution as its default —
/// ONE join brain, so the sheet's preview, the ceremony operation, and the
/// everyday merge can never disagree about a byte.
public enum MergeJoin: String, CaseIterable, Equatable, Sendable {
    /// Exactly one space between the halves.
    case space
    /// Exactly one newline between the halves (outline-ish text with no
    /// terminal punctuation — the preview shows it before anything commits).
    case newline
    /// Plain concatenation — the halves meet bare.
    case nothing

    /// The canon rule, resolved for a concrete pair of texts: a single
    /// space unless either side's edge already carries whitespace (or a
    /// side is empty — nothing to separate).
    public static func canon(head: String, tail: String) -> MergeJoin {
        let needsSpace = !head.isEmpty && !tail.isEmpty
            && head.last?.isWhitespace != true && tail.first?.isWhitespace != true
        return needsSpace ? .space : .nothing
    }

    /// The join's separator string.
    public var separator: String {
        switch self {
        case .space: " "
        case .newline: "\n"
        case .nothing: ""
        }
    }

    /// The joined text.
    public func joined(_ head: String, _ tail: String) -> String {
        head + separator + tail
    }
}
