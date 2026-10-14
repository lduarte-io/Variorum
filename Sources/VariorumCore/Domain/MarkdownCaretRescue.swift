import Foundation

/// **VX-296 — the live editor's half of the caret-aware markdown face** (her
/// ruling on the ticket: fix (a), "your fix is good" — caret-aware in the
/// LIVE EDITOR only; every other reader of the grammar is untouched).
///
/// `MarkdownSyntax.spans(in:caret:)` holds the rule itself: a closing marker
/// right at the caret still closes although whitespace precedes it. This file
/// holds the two pure pieces every live surface needs around that rule, so
/// the Mac's two live roads and the phone's run ONE brain:
///
///   1. `point(in:selection:)` — the O(1) GATE. A caret can change the
///      reading only where it sits between whitespace and a closing marker
///      of the flanking family; everywhere else (almost every caret move a
///      writer makes) a caret-aware restyle would write exactly what the
///      caret-blind one already wrote, so the surface does nothing.
///   2. `Ledger` — which line the surface last styled HONOURING a caret, kept
///      current across character edits, so a caret that LEAVES restyles
///      that one line caret-blind (the span honestly un-styles when she
///      leaves a trailing space behind) and a caret that ARRIVES restyles its
///      own. Cost: at most two lines per settle — never the document (P1).
///
/// **The posture the ledger keeps: it may OVER-claim, never UNDER-claim.** A
/// claimed line that is in fact already caret-blind costs one redundant
/// line restyle when the caret leaves. An honoured line the ledger had lost
/// track of would stay italic behind her — so every arithmetic below rounds
/// toward claiming.
///
/// Offsets are UTF-16 (the structural API's unit — `MarkdownSyntax`'s), so a
/// surface hands `NSRange`s straight in.
public enum MarkdownCaretRescue {
    /// **Could a caret at `selection` change the face's reading?** The caret
    /// offset when it could, else nil. O(1): it reads the one grapheme at the
    /// caret and the one before it.
    ///
    /// The exact NECESSARY condition of the parser's rescue
    /// (`MarkdownSyntax.closerFlanks`), so a surface that restyles honouring
    /// the caret only where this answers never misses a rescue:
    ///   - the selection is an insertion point (a selection is not typing);
    ///   - the grapheme AT the caret is a closing marker of the flanking
    ///     family — `*`, `~` or `_` (the parser compares whole characters, so
    ///     `*` with a combining mark is not one);
    ///   - the grapheme BEFORE it is whitespace on the same line (a newline
    ///     before it puts it at a line's start, where no closer can be).
    /// What only a scan can answer — whether an opener earlier on the line
    /// pairs with it — is the restyle's to find; where none does, the
    /// restyle writes what the caret-blind one wrote.
    public static func point(in text: NSString, selection: NSRange) -> Int? {
        guard selection.location != NSNotFound, selection.length == 0 else { return nil }
        let caret = selection.location
        guard caret > 0, caret < text.length else { return nil }
        let at = text.rangeOfComposedCharacterSequence(at: caret)
        guard at.location == caret,
              ["*", "~", "_"].contains(text.substring(with: at))
        else { return nil }
        let before = text.substring(with: text.rangeOfComposedCharacterSequence(at: caret - 1))
        guard let char = before.first, char.isWhitespace, !char.isNewline else { return nil }
        return caret
    }

    /// What a settle asks a surface to restyle (offsets in the CURRENT text;
    /// each names a LINE — the face's own line-scoped restyle at that offset).
    public struct Restyle: Equatable, Sendable {
        /// A line styled honouring a caret that has since left: restyle it
        /// caret-blind. Nil when there is none, or when `honour` names the
        /// same line (one pass covers both).
        public let clear: Int?
        /// The caret, where it may rescue a closer: restyle its line
        /// honouring it.
        public let honour: Int?

        public init(clear: Int?, honour: Int?) {
            self.clear = clear
            self.honour = honour
        }
    }

    /// The live surface's bookkeeping — one per live editing surface.
    public struct Ledger: Equatable, Sendable {
        /// The caret offset (current text) whose LINE the surface last styled
        /// honouring it; nil = no line carries a caret's honour.
        public private(set) var honoured: Int?
        /// A character edit has landed since the last settle. The edit's own
        /// restyle is caret-blind (every surface's keystroke road stays
        /// byte-unchanged), so it may have re-derived the honoured line
        /// without the caret: the next settle restyles even when the caret is
        /// still on the same offset.
        public private(set) var edited = false

        public init() {}

        /// The surface's characters changed: `old` — in offsets from BEFORE
        /// the edit — now holds `newLength` units. A report widened by
        /// attribute fixing (TEXTKIT2 §3 — the widening adds the same run to
        /// the old and the new length) shifts a later claim identically, and a
        /// claim inside the edited run moves to its start, a line the edit's
        /// own restyle covers (an over-claim, by the posture above).
        public mutating func noteEdit(replacing old: NSRange, newLength: Int) {
            edited = true
            guard let claim = honoured, claim >= old.location else { return }
            if claim >= old.location + old.length {
                honoured = claim + newLength - old.length
            } else {
                honoured = old.location
            }
        }

        /// The caret has settled (`selection`; nil = the surface holds no
        /// caret of hers — it is not live). Records the new honour and
        /// returns what the surface must restyle, or nil for nothing at all —
        /// the answer for a caret that neither sits at a rescue point nor
        /// leaves one, which is almost every caret move.
        public mutating func settle(selection: NSRange?, in text: NSString) -> Restyle? {
            let wanted = selection.flatMap { MarkdownCaretRescue.point(in: text, selection: $0) }
            let previous = honoured.map { min($0, text.length) }
            let changed = edited || wanted != previous
            honoured = wanted
            edited = false
            guard changed else { return nil }
            var clear = previous
            if let left = clear, let arrived = wanted,
               text.lineRange(for: NSRange(location: left, length: 0))
                == text.lineRange(for: NSRange(location: arrived, length: 0)) {
                clear = nil
            }
            guard clear != nil || wanted != nil else { return nil }
            return Restyle(clear: clear, honour: wanted)
        }
    }
}
