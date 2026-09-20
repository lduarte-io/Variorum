import Foundation

/// The merge join, as a value: HOW two takes' texts meet when blocks merge
/// (13b Stage 4, Batch 4B — the ruled merge-ceremony addendum,
/// `notes/plans/phase-13b-memo-merge.md`).
///
/// The three cases are what the ceremony's per-pairing control offers, and
/// what `MergeJoinRule` below resolves to — ONE join brain, so the sheet's
/// preview, the ceremony operation, and the everyday merge can never
/// disagree about a byte.
public enum MergeJoin: String, CaseIterable, Equatable, Sendable {
    /// Exactly one space between the halves.
    case space
    /// Exactly one newline between the halves — since R-13u4-3 this is the
    /// join every merge DOOR makes (see `MergeJoinRule.door`).
    case newline
    /// Plain concatenation — the halves meet bare.
    case nothing

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

/// **WHICH join a merge makes — the DOORS-vs-DELETES classification**
/// (author ruling **R-13u4-3**, 2026-09-20, 13u4 UNIT E3; her words:
/// *"Merging should not remove a newlines in the middle of the merge
/// selected area, it should just make all newlines within the selected
/// portion part of a single block."*).
///
/// One rule brain with two members, because the app reaches `merge` from two
/// genuinely different gestures and the ruling separates them:
///
/// - **`.door`** — every deliberate merge (the block ▾ menu and ⌘⇧M, the
///   context menu, the palette, the N-way chain, the bulk bars' two run
///   options, the ceremony's per-pairing DEFAULT, the phone's "Merge with
///   Previous", and Make Block across blocks): the **RENDERING join** —
///   `top + "\n" + bottom`, byte-exact, no trimming, no conditionals — so
///   the page reads byte-identical before and after the merge (the editor
///   surface joins blocks with exactly one `"\n"`: `EditorDocument`'s
///   separator doctrine, author-confirmed interpretation 2a).
///   **SUPERSEDES the 2026-07-06 single-space join** (AppSpec §9).
/// - **`.deleteKeystroke`** — the two DELETE roads (the seam ⌦/backspace
///   carve, QUESTIONS #34's texted-seam merge; and the cross-block
///   compound's edge-join): the **shipped** join, byte-unchanged, because a
///   delete that produced the newline it just removed would visibly do
///   NOTHING. This is the pre-ruling rule verbatim: a single space unless
///   either side's edge already carries whitespace (or a side is empty —
///   nothing to separate).
///
/// The rule is resolved at act time, inside the operation's own transaction,
/// on the STORE's rendered texts — never on a projection a caller captured.
public enum MergeJoinRule: String, CaseIterable, Equatable, Sendable {
    /// Every deliberate merge door — the rendering join.
    case door
    /// The seam carve and the cross-block compound's edge-join.
    case deleteKeystroke

    /// The join this rule makes for a concrete pair of texts.
    ///
    /// `.door` ignores them BY RULING — "byte-exact, no trimming, no
    /// conditionals" are R-13u4-3's own words, and the signature stays
    /// uniform so a call site that changes class changes one argument.
    public func join(head: String, tail: String) -> MergeJoin {
        switch self {
        case .door:
            return .newline
        case .deleteKeystroke:
            let needsSpace = !head.isEmpty && !tail.isEmpty
                && head.last?.isWhitespace != true && tail.first?.isWhitespace != true
            return needsSpace ? .space : .nothing
        }
    }
}
