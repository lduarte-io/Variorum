import Foundation

/// The markdown FORMATTING ACTS, as pure edit computations (Phase 13g,
/// batch 3 — L8/L9 over the author's rulings F-1…F-3: storage is
/// markdown-as-content, the v1 vocabulary is bold · italic ·
/// strikethrough · inline code · `#`/`##`/`###` · `- ` bullets ·
/// `- [ ]` checkboxes).
///
/// **What this file is, and what it deliberately is not.** It answers ONE
/// question — *given this text and this selection, which characters change
/// and where does the selection land?* — and nothing else. It never touches
/// a text view, a store, or an operation: the app applies the returned edits
/// through the editor's ORDINARY input path (the same path typing takes), so
/// autosave, churn, block routing and text undo all happen exactly as they
/// always do. That is the whole reason formatting needs no new operation and
/// no schema: under F-1 the markers ARE the text.
///
/// **Offsets are UTF-16 code units**, the structural API's unit
/// (`BoundarySnapping`'s discipline, and `MarkdownSyntax`'s), so the caller
/// hands `NSRange`s in and takes ranges out with no translation.
///
/// **The caller passes WHOLE LINES, not the document** (`inLines:`): every
/// act here is line-scoped, because `MarkdownSyntax` is line-scoped by law —
/// a span never crosses a newline, and on the editor surface (blocks joined
/// by a single `"\n"`) that also means a span can never cross a BLOCK SEAM.
/// Two things follow, both load-bearing:
///   1. **P1** — the cost of ⌘B is the cost of the lines it touches, never
///      the note's length. The caller does the `lineRange(for:)` lookup, the
///      same shape `MarkdownStyling.restyle` already uses.
///   2. **No formatting act can ever restructure a note.** Every edit it
///      emits sits inside one line, and a line sits inside one block, so the
///      cross-block arm of the editor's own pipeline (which MERGES blocks —
///      the ratified 2026-07-09 merge-then-edit, made for a deliberate
///      hand-made selection) is unreachable from here. This is the same
///      safety core `EditorFind` states for find-and-replace, obtained by
///      construction instead of by a pre-check.
///
/// **Toggle semantics, one rule for both families:** if EVERY affected piece
/// (or line) already carries the act, the act CLEARS it; otherwise it is
/// applied to every piece that lacks it. Wrapped-ness is read from
/// `MarkdownSyntax.spans` — never guessed by regex — so ⌘B on `**sel**`
/// unwraps, and ⌘B with the caret inside a bold span unwraps it too.
public enum MarkdownEditing {
    // MARK: - The vocabulary

    /// The v1 acts (F-3), exactly. Two families: INLINE WRAPS around a
    /// selection, and LINE LEADS at a line's first character.
    public enum Act: Equatable, Sendable {
        case bold, italic, strikethrough, code
        /// `[text](url)` — 13g batch 4 (L10). It joins the WRAP family rather
        /// than being its own thing: its markers are simply asymmetric, and
        /// everything the family already decided (read wrapped-ness from the
        /// tokenizer, toggle-clears-when-every-piece-carries-it, trim the
        /// selection's whitespace) is what a link wants too.
        case link
        /// `#`, `##`, `###` — clamped to 1…3, because F-3 names three sizes
        /// and `####` is plain text to the tokenizer.
        case heading(level: Int)
        case bullet
        case checkbox
        /// **13k K8 — nesting.** Not a wrap and not a lead: they change a
        /// list line's INDENT and touch nothing else. Her ruling gave Tab
        /// the indent and sitting Q3 gave ⇧Tab + Format ▸ Indent/Outdent
        /// the way back; the acts are here so both doors and the menu run
        /// one computation.
        case indent, outdent

        /// The syntax characters an inline act wraps with; nil for the line
        /// family. Asymmetric for links, symmetric for the emphasis four.
        var wrapMarkers: (open: String, close: String)? {
            switch self {
            case .bold: ("**", "**")
            case .italic: ("*", "*")
            case .strikethrough: ("~~", "~~")
            case .code: ("`", "`")
            case .link: ("[", "]()")
            case .heading, .bullet, .checkbox, .indent, .outdent: nil
            }
        }

        var wrapKind: MarkdownSyntax.Kind? {
            switch self {
            case .bold: .bold
            case .italic: .italic
            case .strikethrough: .strikethrough
            case .code: .code
            case .link: .link
            case .heading, .bullet, .checkbox, .indent, .outdent: nil
            }
        }

        /// **Links act on ONE line** (13g batch 4, a build-time call —
        /// QUESTIONS #50): a multi-line selection is trimmed to the line it
        /// STARTS on. The emphasis four wrap each line, because `**one**` and
        /// `**two**` are both wanted and both real; three EMPTY links from
        /// one gesture are junk, and only one of them could hold the caret
        /// the act exists to place.
        var wrapsFirstLineOnly: Bool {
            if case .link = self { return true }
            return false
        }

        /// The characters a line act puts at the line's start; nil for the
        /// inline family. A checkbox is always born UNCHECKED — checking it
        /// is the click (L9), not the insertion.
        var lead: String? {
            switch self {
            case .heading(let level):
                String(repeating: "#", count: min(max(level, 1), 3)) + " "
            case .bullet: "- "
            case .checkbox: "- [ ] "
            case .bold, .italic, .strikethrough, .code, .link, .indent, .outdent: nil
            }
        }

        /// Does `kind` already carry exactly this act? (A checkbox matches in
        /// EITHER state — the act is "this line is a checkbox", not "this
        /// line is unchecked".)
        func matches(_ kind: MarkdownSyntax.Kind) -> Bool {
            switch (self, kind) {
            case (.heading(let want), .heading(let have)): min(max(want, 1), 3) == have
            case (.bullet, .bullet): true
            case (.checkbox, .checkbox): true
            default: false
            }
        }
    }

    /// One replacement, UTF-16 offsets relative to the text handed in.
    public struct Edit: Equatable, Sendable {
        public let range: Range<Int>
        public let replacement: String

        public init(range: Range<Int>, replacement: String) {
            self.range = range
            self.replacement = replacement
        }
    }

    /// What an act does. `edits` are ASCENDING and DISJOINT — the caller
    /// applies them LAST FIRST so every earlier offset stays valid (the
    /// reason `EditorFind` gives for its own reverse ordering, and the SDK's
    /// for the finder's). `selection` is where the selection lands once every
    /// edit is applied.
    public struct Plan: Equatable, Sendable {
        public let edits: [Edit]
        public let selection: Range<Int>

        public init(edits: [Edit], selection: Range<Int>) {
            self.edits = edits
            self.selection = selection
        }

        /// Nothing to do — the door should not pretend it acted.
        public var isEmpty: Bool { edits.isEmpty }
    }

    // MARK: - The one entry point

    /// Plans `act` over `selection` (UTF-16, relative to `text`), where
    /// `text` is the WHOLE LINES the selection touches.
    public static func plan(_ act: Act, inLines text: String, selection: Range<Int>) -> Plan {
        let chars = Array(text)
        var offsets: [Int] = [0]
        offsets.reserveCapacity(chars.count + 1)
        for char in chars { offsets.append(offsets[offsets.count - 1] + char.utf16Width) }
        let total = offsets[offsets.count - 1]

        let lower = min(max(selection.lowerBound, 0), total)
        let upper = min(max(selection.upperBound, lower), total)
        let sel = lower..<upper

        let lines = lineRanges(chars, offsets)
        let affected = lines.filter { line in
            sel.isEmpty
                ? (line.start <= sel.lowerBound && sel.lowerBound <= line.end)
                // A selection ENDING exactly at a line's first character does
                // not reach that line (`line.start < sel.upperBound` is
                // false) — selecting "abc\n" bullets one line, not two.
                : (line.start < sel.upperBound && line.end >= sel.lowerBound)
        }
        guard !affected.isEmpty else { return Plan(edits: [], selection: sel) }

        // ONE scan, of the handed-in lines only — this is the P1 claim, and
        // `MarkdownScanCount` (DEBUG) is what makes it checkable.
        let spans = MarkdownSyntax.spans(in: text)

        if act == .indent || act == .outdent {
            return indentPlan(
                act, spans: spans, chars: chars, offsets: offsets,
                lines: affected, selection: sel)
        }
        if let markers = act.wrapMarkers, let kind = act.wrapKind {
            return wrapPlan(
                markers: markers, kind: kind, chars: chars, offsets: offsets,
                spans: spans,
                lines: act.wrapsFirstLineOnly ? Array(affected.prefix(1)) : affected,
                selection: sel)
        }
        return leadPlan(act, spans: spans, chars: chars, offsets: offsets,
                        lines: affected, selection: sel)
    }

    /// **L9's click (her ruled half):** the edit a click ON a checkbox's BOX
    /// makes — `- [ ]` ↔ `- [x]`, three characters for three, so every offset
    /// in the note is unchanged and the caret can simply stay where it was.
    ///
    /// `insertionIndex` must land STRICTLY INSIDE the box (the caret position
    /// a click yields is a boundary, so `boxStart` and `boxEnd` are also
    /// produced by clicks on the half-character OUTSIDE the box — accepting
    /// them would let a click meant for the text toggle a box instead). Nil ⇒
    /// this was an ordinary caret click and the caller must not consume it.
    public static func checkboxToggle(inLines text: String, insertionIndex: Int) -> Edit? {
        for span in MarkdownSyntax.spans(in: text) {
            guard case .checkbox(let checked) = span.kind, span.markers.count == 2 else { continue }
            let box = span.markers[1]
            guard box.lowerBound < insertionIndex, insertionIndex < box.upperBound else { continue }
            return Edit(range: box, replacement: checked ? "[ ]" : "[x]")
        }
        return nil
    }

    // MARK: - K5: what ⏎ does on a list line

    /// **The ⏎ rule on a LIST line** (13k K5 — her ruling: *⏎ at the end of
    /// a texted list line mints the next lead; ⏎ on an EMPTY list item
    /// removes the lead and exits the list*).
    ///
    /// ── WHAT THIS DELIBERATELY IS NOT ───────────────────────────────────
    /// It is **not** a change to what ⏎ MEANS. The ratified structural
    /// semantics — the open-tail gesture at the document end, `one_block`'s
    /// newlines-don't-mint, A15's ⇧⏎, the idle-mint — all key on a single
    /// typed `"\n"`, and the continuation half leaves that keystroke
    /// completely alone: the newline goes in exactly as it always did, and
    /// the lead is a SECOND ordinary insertion of ordinary text at the
    /// caret the newline left behind. (Planning the two as one `"\n- "`
    /// replacement would have made the open-tail gesture stop recognising
    /// its own keystroke — the reason this returns a lead rather than an
    /// edit.)
    ///
    /// The exit half is the one place the keystroke is CONSUMED, and it
    /// inserts no newline at all: it deletes the lead of an item with
    /// nothing in it, which is an ordinary in-line edit that can never
    /// touch a seam.
    public enum ReturnKey: Equatable, Sendable {
        /// Nothing list-shaped here — ⏎ is exactly the keystroke it was.
        case ordinary
        /// A texted list line: once the newline has landed, insert this.
        /// **13k K8: the lead CARRIES THE INDENT**, so a nested item's ⏎
        /// continues at its own level instead of collapsing to column 0.
        case continueList(lead: String)
        /// An EMPTY list item at level 0: delete this range (its lead) and
        /// insert NO newline. UTF-16, relative to the text handed in.
        case exitList(lead: Range<Int>)
        /// **13k K8 — an EMPTY list item that is NESTED: OUTDENT FIRST.**
        /// Delete this range (one indent unit) and insert no newline; the
        /// item stays a list item, one level shallower, and a second ⏎ at
        /// level 0 exits exactly as her K5 ruling says.
        ///
        /// Ruled (architect, 2026-08-02) as the platform standard extending
        /// K5 — Notes, Bear, Obsidian and Notion all do this, "finish this
        /// sub-list and continue the parent" is the everyday gesture, and
        /// **at level 0 nothing she ruled changes at all**. The literal
        /// alternative (exit straight to column 0 from any depth) is a
        /// lettered call on QUESTIONS #54.
        case outdentItem(unit: Range<Int>)
    }

    /// The unchecked checkbox lead a continued checklist gets — never a
    /// checked one, the same call `Act.checkbox` makes (QUESTIONS #49(h):
    /// *Format ▸ Checklist always makes an UNCHECKED box; checking is the
    /// click*).
    static let continuedCheckboxLead = "- [ ] "
    static let continuedBulletLead = "- "

    /// `text` is the caret's LINE (the `checkboxToggle` shape — whole lines
    /// in, offsets relative to them); `offset` is the caret within it.
    ///
    /// **The caret must be at the line's END** — her ruling's letter ("⏎ at
    /// the END of a texted list line"). Mid-item ⏎ therefore splits the item
    /// without leading the remainder, which is the conservative reading;
    /// widening it is one comparison (recorded as a build-time call).
    ///
    /// **Headings do not continue.** Her ruling names the two list leads
    /// (`- ` and `- [ ]`); a heading is not a list, and a second `# ` after
    /// every heading is nobody's intent.
    public static func returnKey(inLines text: String, at offset: Int) -> ReturnKey {
        let ns = text as NSString
        for span in MarkdownSyntax.spans(in: text) {
            let lead: String
            switch span.kind {
            case .bullet: lead = continuedBulletLead
            case .checkbox: lead = continuedCheckboxLead
            case .heading, .bold, .italic, .strikethrough, .code, .link: continue
            }
            // A line-leading span covers its whole line, so its upper bound
            // IS the line's end.
            guard offset == span.range.upperBound else { continue }
            let content = ns.substring(with: NSRange(
                location: span.content.lowerBound, length: span.content.count))
            // The line's own indent — the run inside `markers[0]`, before the
            // `"- "`. Read from the text rather than rebuilt from the level,
            // so a tab-indented item keeps its tab (this never rewrites her
            // whitespace).
            let indent = MarkdownSyntax.leadingWhitespace(of: ns.substring(with: NSRange(
                location: span.range.lowerBound, length: span.range.count)))

            if content.trimmingCharacters(in: .whitespaces).isEmpty {
                guard span.indentLevel > 0 else {
                    // Level 0 ⇒ exit, exactly as her K5 ruling says. The LEAD
                    // goes; anything she typed past it (stray spaces) is hers
                    // and stays.
                    return .exitList(lead: span.range.lowerBound..<span.content.lowerBound)
                }
                // Nested ⇒ outdent one level and stay a list item. One tab is
                // one level; otherwise up to the two-space unit.
                let unitLength = indent.hasPrefix("\t")
                    ? 1
                    : min(MarkdownSyntax.indentUnit.utf16.count, indent.utf16.count)
                return .outdentItem(
                    unit: span.range.lowerBound..<(span.range.lowerBound + unitLength))
            }
            return .continueList(lead: indent + lead)
        }
        return .ordinary
    }

    /// **L10's ⌘-click (13g batch 4):** the ADDRESS of the link an offset
    /// falls in, or nil where there is none — the pure decision an editing
    /// surface asks before it consumes a modified click.
    ///
    /// The whole SPAN counts, `(url)` included, deliberately: the dimmed
    /// address is visibly part of the link, and unlike the checkbox click
    /// (which competes with an ordinary caret click and so must be strict)
    /// this gesture carries a modifier and competes with nothing.
    public static func link(inLines text: String, at offset: Int) -> String? {
        let ns = text as NSString
        for span in MarkdownSyntax.spans(in: text) {
            guard case .link = span.kind, let url = span.url,
                  span.range.lowerBound <= offset, offset <= span.range.upperBound
            else { continue }
            return ns.substring(with: NSRange(
                location: url.lowerBound, length: url.count))
        }
        return nil
    }

    // MARK: - Lines

    /// Every line of `text` as UTF-16 bounds, terminators EXCLUDED (and an
    /// empty text is one empty line — the caret in a blank note still has a
    /// line to bullet).
    private struct Line {
        let start: Int
        let end: Int
        let charStart: Int
        let charEnd: Int
    }

    private static func lineRanges(_ chars: [Character], _ offsets: [Int]) -> [Line] {
        var result: [Line] = []
        var lineStart = 0
        var index = 0
        while index <= chars.count {
            if index == chars.count || chars[index].isNewline {
                result.append(Line(
                    start: offsets[lineStart], end: offsets[index],
                    charStart: lineStart, charEnd: index))
                lineStart = index + 1
            }
            index += 1
        }
        return result
    }

    private static func isBlank(_ line: Line, _ chars: [Character]) -> Bool {
        !(line.charStart..<line.charEnd).contains { !chars[$0].isWhitespace }
    }

    // MARK: - The inline family (wrap / unwrap)

    private struct Piece {
        let range: Range<Int>
        let enclosing: MarkdownSyntax.Span?
    }

    private static func wrapPlan(
        markers: (open: String, close: String), kind: MarkdownSyntax.Kind,
        chars: [Character], offsets: [Int], spans: [MarkdownSyntax.Span],
        lines: [Line], selection sel: Range<Int>
    ) -> Plan {
        let openLength = markers.open.utf16.count
        var pieces: [Piece] = []

        for line in lines {
            var piece: Range<Int>
            if sel.isEmpty {
                piece = sel.lowerBound..<sel.lowerBound
            } else {
                let low = max(line.start, sel.lowerBound)
                let high = min(line.end, sel.upperBound)
                guard low <= high else { continue }
                piece = trimmingWhitespace(low..<high, chars, offsets)
                // A blank line inside a multi-line selection is skipped:
                // wrapping it would produce `****`, which the tokenizer reads
                // as literal text (empty content is always literal — batch
                // 2's pinned decision), i.e. visible junk for no gain.
                if piece.isEmpty { continue }
            }
            pieces.append(Piece(range: piece, enclosing: enclosing(piece, kind: kind, in: spans)))
        }

        // A selection made entirely of whitespace has no piece to wrap; the
        // honest answer is the caret gesture at its start, never a silent
        // no-op.
        if pieces.isEmpty {
            pieces = [Piece(
                range: sel.lowerBound..<sel.lowerBound,
                enclosing: enclosing(sel.lowerBound..<sel.lowerBound, kind: kind, in: spans))]
        }

        let allWrapped = pieces.allSatisfy { $0.enclosing != nil }
        var edits: [Edit] = []

        if allWrapped {
            for piece in pieces {
                guard let span = piece.enclosing, span.markers.count >= 2 else { continue }
                // The trailing run is everything from the closing marker to
                // the span's end — `**` for the emphasis four, and the whole
                // `](url)` for a link, whose URL goes with the link it named.
                let last = span.markers[span.markers.count - 1]
                edits.append(Edit(range: span.markers[0], replacement: ""))
                edits.append(Edit(
                    range: span.markers[1].lowerBound..<last.upperBound, replacement: ""))
            }
        } else {
            for piece in pieces where piece.enclosing == nil {
                if piece.range.isEmpty {
                    // The caret gesture: both markers at once, caret between
                    // them — she has asked for bold (or for a link) and is
                    // about to type it.
                    edits.append(Edit(
                        range: piece.range, replacement: markers.open + markers.close))
                } else {
                    edits.append(Edit(
                        range: piece.range.lowerBound..<piece.range.lowerBound,
                        replacement: markers.open))
                    edits.append(Edit(
                        range: piece.range.upperBound..<piece.range.upperBound,
                        replacement: markers.close))
                }
            }
        }
        edits.sort { ($0.range.lowerBound, $0.range.upperBound) < ($1.range.lowerBound, $1.range.upperBound) }

        // Where the selection lands. Three shapes, in the order they are
        // decided:
        //   * the CARET gesture — between the two markers just inserted;
        //   * a LINK just made — inside its empty parens, which is the whole
        //     point of the act (she has the text, she needs to paste the
        //     address);
        //   * everything else — the text stays selected (the opening marker
        //     pushes the start, the closing one does not pull the end).
        let selectionAfter: Range<Int>
        if edits.count == 1, edits[0].range.isEmpty,
           edits[0].replacement == markers.open + markers.close {
            // `**|**`, and `[|]()` — past the OPENING marker either way,
            // which is where the next keystroke belongs in both.
            let caret = edits[0].range.lowerBound + openLength
            selectionAfter = caret..<caret
        } else if !allWrapped, kind == .link, let close = edits.last, close.range.isEmpty,
                  close.replacement == markers.close {
            // `[text](|)` — the close marker landed at the piece's end; the
            // caret sits inside its parens, because the text is already
            // written and the ADDRESS is what she is about to supply.
            let caret = close.range.lowerBound + openLength + markers.close.utf16.count - 1
            selectionAfter = caret..<caret
        } else {
            selectionAfter = map(sel.lowerBound, through: edits, bias: .right)
                ..< map(sel.upperBound, through: edits, bias: .left)
        }
        return Plan(edits: edits, selection: normalized(selectionAfter))
    }

    /// The span of `kind` this piece already lives in, if any. Two shapes
    /// count, and only two: the piece sits inside the span's CONTENT (the
    /// ordinary "my caret is in the bold word"), or the piece IS the whole
    /// span, markers included (selecting `**sel**` and pressing ⌘B — the
    /// case the brief names). A caret merely ADJACENT to a span — just after
    /// `**bold**` — is deliberately NOT inside it: typing on and pressing ⌘B
    /// must start new emphasis, not undo the last word's.
    private static func enclosing(
        _ piece: Range<Int>, kind: MarkdownSyntax.Kind, in spans: [MarkdownSyntax.Span]
    ) -> MarkdownSyntax.Span? {
        spans.first { span in
            guard span.kind == kind else { return false }
            if piece == span.range { return true }
            return span.content.lowerBound <= piece.lowerBound
                && piece.upperBound <= span.content.upperBound
        }
    }

    private static func trimmingWhitespace(
        _ range: Range<Int>, _ chars: [Character], _ offsets: [Int]
    ) -> Range<Int> {
        var low = charIndex(range.lowerBound, offsets)
        var high = charIndex(range.upperBound, offsets)
        while low < high, chars[low].isWhitespace { low += 1 }
        while high > low, chars[high - 1].isWhitespace { high -= 1 }
        return offsets[low]..<offsets[high]
    }

    /// The character index a UTF-16 offset names (binary search — `offsets`
    /// is ascending). An offset inside a surrogate pair cannot occur: every
    /// offset here comes from this table or from a `MarkdownSyntax` range,
    /// and both accumulate per GRAPHEME.
    private static func charIndex(_ offset: Int, _ offsets: [Int]) -> Int {
        var low = 0
        var high = offsets.count - 1
        while low < high {
            let mid = (low + high) / 2
            if offsets[mid] < offset { low = mid + 1 } else { high = mid }
        }
        return low
    }

    // MARK: - The line family (set / clear the lead)

    private static func leadPlan(
        _ act: Act, spans: [MarkdownSyntax.Span],
        chars: [Character], offsets: [Int], lines: [Line], selection sel: Range<Int>
    ) -> Plan {
        guard let lead = act.lead else { return Plan(edits: [], selection: sel) }

        // A blank line inside a MULTI-line selection is skipped (bulleting
        // the gaps between paragraphs is nobody's intent); a single blank
        // line is kept, because "caret on an empty line, start a list" is
        // exactly the everyday gesture.
        var targets = lines
        if targets.count > 1 {
            let written = targets.filter { !isBlank($0, chars) }
            if !written.isEmpty { targets = written }
        }

        let leads: [(range: Range<Int>, matches: Bool, indent: String)] = targets.map { line in
            let span = spans.first { span in
                span.range.lowerBound == line.start && isLineLeading(span.kind)
            }
            // 13k K8: an indented list line's lead INCLUDES its indent, so
            // re-leading it (bullet → checklist) must put the indent back or
            // the nesting would silently collapse. Clearing removes the whole
            // lead, indent and all — the line stops being a list, and a
            // paragraph indented by two orphan spaces is not what "clear"
            // means.
            let indent = String(chars[line.charStart..<line.charEnd].prefix { $0 == " " || $0 == "\t" })
            return (line.start..<(span?.content.lowerBound ?? line.start),
                    span.map { act.matches($0.kind) } ?? false,
                    (span.map { isListLead($0.kind) } ?? false) ? indent : "")
        }

        // ONE rule for both families: every affected line already carries the
        // act ⇒ CLEAR it; otherwise SET it on the lines that lack it. Setting
        // REPLACES whatever lead a line had — the three line kinds are
        // mutually exclusive to the tokenizer, so a heading that becomes a
        // bullet must stop being a heading (prefixing instead would produce
        // `- # Title`, a bullet whose text reads as literal `#`).
        let clearing = leads.allSatisfy(\.matches)
        var edits: [Edit] = []
        for entry in leads {
            if clearing {
                guard !entry.range.isEmpty else { continue }
                edits.append(Edit(range: entry.range, replacement: ""))
            } else {
                guard !entry.matches else { continue }  // already exactly this lead
                edits.append(Edit(range: entry.range, replacement: entry.indent + lead))
            }
        }

        let selectionAfter = map(sel.lowerBound, through: edits, bias: .right)
            ..< map(sel.upperBound, through: edits, bias: .right)
        return Plan(edits: edits, selection: normalized(selectionAfter))
    }

    // MARK: - K8: the indent family

    /// **Tab and ⇧Tab, as a plan** (13k K8, her ruling + sitting Q3).
    ///
    /// The rule is narrow on purpose: **only LIST lines move.** Every
    /// affected line that carries a bullet or checkbox lead gains (or loses)
    /// exactly one indent unit at its start; a heading, a paragraph, or a
    /// blank line inside the selection is left alone. An outdent on a line
    /// with no indent left is simply no edit for that line.
    ///
    /// **An EMPTY plan is the signal that the keystroke was not ours** — the
    /// surface falls straight through to `super.insertTab`/`insertBacktab`,
    /// so Tab outside a list is byte-for-byte the key it has always been
    /// (the `insertNewlineContinuingLists` shape, same reasoning).
    private static func indentPlan(
        _ act: Act, spans: [MarkdownSyntax.Span],
        chars: [Character], offsets: [Int], lines: [Line], selection sel: Range<Int>
    ) -> Plan {
        var edits: [Edit] = []
        for line in lines {
            guard spans.contains(where: { span in
                span.range.lowerBound == line.start && isListLead(span.kind)
            }) else { continue }

            if act == .indent {
                edits.append(Edit(
                    range: line.start..<line.start, replacement: MarkdownSyntax.indentUnit))
                continue
            }
            // Outdent: ONE unit off the front — a tab is one level, so it
            // goes whole; otherwise up to two spaces (the ruled unit).
            var index = line.charStart
            var removed = 0
            if index < line.charEnd, chars[index] == "\t" {
                index += 1
                removed = 1
            } else {
                while index < line.charEnd, chars[index] == " ",
                      removed < MarkdownSyntax.indentUnit.count {
                    index += 1
                    removed += 1
                }
            }
            guard removed > 0 else { continue }
            edits.append(Edit(range: line.start..<offsets[index], replacement: ""))
        }
        let selectionAfter = map(sel.lowerBound, through: edits, bias: .right)
            ..< map(sel.upperBound, through: edits, bias: .right)
        return Plan(edits: edits, selection: normalized(selectionAfter))
    }

    private static func isListLead(_ kind: MarkdownSyntax.Kind) -> Bool {
        switch kind {
        case .bullet, .checkbox: true
        case .heading, .bold, .italic, .strikethrough, .code, .link: false
        }
    }

    private static func isLineLeading(_ kind: MarkdownSyntax.Kind) -> Bool {
        switch kind {
        case .heading, .bullet, .checkbox: true
        case .bold, .italic, .strikethrough, .code, .link: false
        }
    }

    // MARK: - Where an offset lands

    /// At an INSERTION point an offset can land on either side of the
    /// inserted text, and which side is right depends on what the offset is:
    /// a selection's START wants to end up after an opening marker
    /// (`.right`), its END before the closing one (`.left`).
    private enum Bias { case left, right }

    private static func map(_ offset: Int, through edits: [Edit], bias: Bias) -> Int {
        var result = offset
        for edit in edits {
            let replacement = edit.replacement.utf16.count
            if edit.range.isEmpty {
                if offset > edit.range.lowerBound
                    || (offset == edit.range.lowerBound && bias == .right) {
                    result += replacement
                }
            } else if offset >= edit.range.upperBound {
                result += replacement - edit.range.count
            } else if offset > edit.range.lowerBound {
                // Inside text that is going away: land at the replacement's end.
                result += edit.range.lowerBound + replacement - offset
            }
        }
        return result
    }

    private static func normalized(_ range: Range<Int>) -> Range<Int> {
        let low = max(range.lowerBound, 0)
        return low..<max(range.upperBound, low)
    }
}
