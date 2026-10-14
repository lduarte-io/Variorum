import Foundation

#if DEBUG
/// **DEBUG-only: how many UTF-16 code units the markdown scanner has walked ON
/// THIS THREAD** since its last `reset()` (Phase 13g, batch 2 — L7).
///
/// The counter lives HERE, on the scanner, for the reason `BoundaryScanCount`
/// records: the shipped code calls `MarkdownSyntax.spans(in:)` directly, so a
/// counter on an app-side wrapper would read zero against the pre-fix code and
/// every P1 pin built on it would be hollow. Thread-local for the same reason
/// too — suites run in parallel and other tests scan on other threads.
///
/// What it buys: the editing face's P1 claim ("re-scan scope ∝ the edited
/// paragraphs, never the document") becomes literally checkable — a keystroke
/// in a 50k-word note must walk the edited line, not the note.
///
/// Standing environment law: DEBUG oracles exist only under the configuration
/// named exactly "Debug" — never add a custom one.
public enum MarkdownScanCount {
    private static let key = "io.lduarte.variorum.markdownScanCount"

    /// UTF-16 units scanned on the CALLING thread since its last `reset()`.
    public static var current: Int {
        (Thread.current.threadDictionary[key] as? Int) ?? 0
    }

    public static func reset() {
        Thread.current.threadDictionary[key] = 0
    }

    static func add(_ units: Int) {
        let dictionary = Thread.current.threadDictionary
        dictionary[key] = ((dictionary[key] as? Int) ?? 0) + units
    }
}
#endif

/// Markdown syntax recognition over one text — a pure Domain function, no
/// GRDB, no AppKit (Phase 13g, the author's ruling **F-1**: storage is
/// MARKDOWN-AS-CONTENT; the stored text IS the markdown, so recognizing it is
/// a *reading* of ordinary content and never a schema, an operation, or a
/// second source of truth).
///
/// **Offset convention: UTF-16 code units** — the structural API's unit
/// (`BoundarySnapping`'s discipline), so the editor hands `NSRange`s straight
/// in and takes ranges straight out with no translation. Offsets accumulate
/// per grapheme CLUSTER, so every range this returns is grapheme-aligned by
/// construction: a marker range can never split an emoji or a combining
/// sequence.
///
/// **Line-scoped by law.** A span never crosses a newline. Two consequences,
/// both load-bearing:
///   1. the editing face can rescan just the edited paragraph(s) — P1's
///      "cost ∝ the edit", not the document;
///   2. on the editor surface, where blocks are joined by a single `"\n"`
///      (`EditorDocument.separator`), **a span can never cross a block seam**
///      — markdown styling and block identity can never disagree.
///
/// **What it does NOT do.** It does not rewrite text, decide product
/// behavior, or resolve nesting. The content of a matched span is not
/// rescanned (v1's documented first-match rule): `` `*a*` `` is one code span,
/// and `**a *b* c**` is one bold span whose inner `*` stay literal. The one
/// exception is deliberate and stated below: a LINE-LEADING span's content IS
/// inline-scanned, so `# **Big**` and `- [ ] **task**` behave as written.
///
/// **The v1 vocabulary is exactly her ruling F-3** and nothing else:
/// `**bold**` · `*italic*` · `~~strikethrough~~` · `` `inline code` `` ·
/// `[text](url)` · `#`/`##`/`###` headings · `- ` bullets · `- [ ]` / `- [x]`
/// checkboxes. Arbitrary per-span sizes are NOT markdown-expressible and are
/// deliberately absent (sizes = headings — F-3's letter).
///
/// **One addition, ruled at the Act 10 correction round (R-cor-10(4), row
/// 84 — the sample library's Gutenberg `_emphasis_` read raw on every
/// face): `_italic_` JOINS the vocabulary as italics.** Display-only by
/// construction — this scanner writes no text; `renderedText` and the `.md`
/// export never consult it — with a stricter
/// boundary than the star's: an underscore opens only at a WORD START (the
/// text's start, or after whitespace/punctuation) and closes only at a WORD
/// END (the text's end, or before whitespace/punctuation), so `snake_case`
/// and `a_b_c` stay literal while `_the_ word` and `(_so_)` italicize. The
/// minimal flanking rule and the non-empty-content rule apply as they do to
/// `*`; ⌘I keeps writing `*` (`MarkdownEditing`'s vocabulary is untouched).
public enum MarkdownSyntax {
    /// What a span is. Line-leading kinds (`heading`/`bullet`/`checkbox`) may
    /// only begin at a line's first character; the rest are inline.
    public enum Kind: Equatable, Sendable {
        /// `#`, `##`, `###` — levels 1…3 only (F-3 names three sizes; `####`
        /// is plain text, so a fourth size can never appear by accident).
        case heading(level: Int)
        case bullet
        case checkbox(checked: Bool)
        case bold
        case italic
        case strikethrough
        case code
        case link
    }

    /// One recognized span, all offsets UTF-16 and absolute to the scanned
    /// text.
    ///
    /// `markers` are the syntax characters (the dimmed run of the F-2 face);
    /// `content` is the styled text between them; `url` is the link's target
    /// (dimmed like a marker, and the range L10's ⌘-click will open).
    ///
    /// For a checkbox, `markers[0]` is the `"- "` lead and `markers[1]` is the
    /// BOX (`"[ ]"` or `"[x]"`) — the range a toggle rewrites. The single
    /// space between the box and the content belongs to neither: it is
    /// ordinary text the face leaves alone.
    public struct Span: Equatable, Sendable {
        public let kind: Kind
        /// The whole span, markers included.
        public let range: Range<Int>
        /// Syntax runs, ascending, disjoint.
        public let markers: [Range<Int>]
        /// The content between the markers (may be EMPTY for the
        /// line-leading kinds — `"# "` alone is a heading with no words yet).
        public let content: Range<Int>
        /// Links only: the target's range.
        public let url: Range<Int>?
        /// **13k K8 — the NESTING LEVEL of a list line** (0 everywhere else).
        ///
        /// Her ruling: *"we should allow indented lists and it should happen
        /// when you click tab."* A leading whitespace run before `- ` makes
        /// the line a NESTED list item; the run itself belongs to
        /// `markers[0]` (it is part of the lead), so a reading surface that
        /// substitutes the lead strips the indent for free and renders the
        /// level as a hanging indent instead of as spaces.
        ///
        /// **The arithmetic (ruled):** a TAB counts as one level, spaces
        /// count `floor(count / 2)` — two spaces per level, because that is
        /// exactly the width of the `- ` lead, so a nested item's marker
        /// lines up under its parent's first word and the text round-trips
        /// as REAL nesting in any markdown renderer that sees an export.
        /// Uncapped: the stored text is the truth, and
        /// refusing to read what she typed would be a lie (a reading
        /// surface may clamp what it DRAWS — that is a look decision, not
        /// this one).
        public let indentLevel: Int

        public init(
            kind: Kind,
            range: Range<Int>,
            markers: [Range<Int>],
            content: Range<Int>,
            url: Range<Int>? = nil,
            indentLevel: Int = 0
        ) {
            self.kind = kind
            self.range = range
            self.markers = markers
            self.content = content
            self.url = url
            self.indentLevel = indentLevel
        }

        /// The same span read against a larger text — the rebasing door for
        /// line-scoped rescans (the caller scans one line's substring and
        /// shifts by that line's start).
        public func shifted(by delta: Int) -> Span {
            Span(
                kind: kind,
                range: (range.lowerBound + delta)..<(range.upperBound + delta),
                markers: markers.map { ($0.lowerBound + delta)..<($0.upperBound + delta) },
                content: (content.lowerBound + delta)..<(content.upperBound + delta),
                url: url.map { ($0.lowerBound + delta)..<($0.upperBound + delta) },
                indentLevel: indentLevel)
        }
    }

    // MARK: - The one entry point

    /// Every span in `text`, in APPLICATION ORDER: for each line, its
    /// line-leading span (if any) first, then its inline spans left to right.
    ///
    /// Inline spans never overlap each other. A line-leading span's `content`
    /// CONTAINS that line's inline spans — deliberately, so a styler applying
    /// them in order composes (`# **Big**` = heading, then bold within it).
    /// Nothing else overlaps.
    ///
    /// **`caret` — the LIVE EDITOR'S insertion point, and only its (VX-296,
    /// her ruling on the ticket: fix (a), "your fix is good").** A UTF-16
    /// offset into `text`, or nil. Nil — the default, and what every reader
    /// that is not a live editor passes by omission (the read pages, export,
    /// search, the formatting acts) — reads `text` EXACTLY as before: the
    /// argument changes nothing else anywhere.
    ///
    /// With a caret, ONE thing differs: a closing marker that sits RIGHT AT
    /// the caret still closes although whitespace precedes it — the closer
    /// half of the minimal flanking rule yields to the caret. That is her
    /// typing flow inside a pair she already has (⌘I's `*|*`, or both stars
    /// typed first): `*hello |*` — the caret between the space she just
    /// typed and the closing star — stays italic, where the caret-blind
    /// reading flipped it plain at every word boundary and back at the next
    /// letter. It applies to every closer the flanking rule governs (`*`,
    /// `**`, `~~`) and to `_`, which shares the rule (PROVISIONAL — the run
    /// record's P-U2-2). The OPENER half is untouched (P-U2-1), which is what
    /// keeps arithmetic safe at every caret position: in `2 * 3 * 4` every
    /// star is followed by a space, so no opener ever forms and no closer is
    /// ever consulted.
    ///
    /// A non-nil caret that names no grapheme boundary in `text` rescues
    /// nothing (it matches no character's start).
    public static func spans(in text: String, caret: Int? = nil) -> [Span] {
        #if DEBUG
        MarkdownScanCount.add(text.utf16.count)
        #endif
        guard !text.isEmpty else { return [] }

        let chars = Array(text)
        var offsets: [Int] = [0]
        offsets.reserveCapacity(chars.count + 1)
        for char in chars { offsets.append(offsets[offsets.count - 1] + char.utf16Width) }

        // The CHARACTER index the caret names (nil with no caret, or when it
        // falls inside a grapheme) — the closers compare indices, not offsets.
        let rescue = caret.flatMap { characterIndex(atOffset: $0, offsets) }

        var result: [Span] = []
        var lineStart = 0
        var index = 0
        while index <= chars.count {
            if index == chars.count || chars[index].isNewline {
                if lineStart < index {
                    scanLine(
                        chars, offsets, from: lineStart, to: index, rescue: rescue,
                        into: &result)
                }
                lineStart = index + 1
            }
            index += 1
        }
        return result
    }

    /// The character index whose START is the UTF-16 `offset`, or nil
    /// (binary search — `offsets` ascends strictly; its last entry is the
    /// text's end, which no closer can sit at, so it is never returned).
    private static func characterIndex(atOffset offset: Int, _ offsets: [Int]) -> Int? {
        var low = 0
        var high = offsets.count - 2
        while low <= high {
            let mid = (low + high) / 2
            if offsets[mid] == offset { return mid }
            if offsets[mid] < offset { low = mid + 1 } else { high = mid - 1 }
        }
        return nil
    }

    // MARK: - One line

    private static func scanLine(
        _ chars: [Character], _ offsets: [Int],
        from start: Int, to end: Int, rescue: Int?, into result: inout [Span]
    ) {
        var contentStart = start
        if let leading = leadingSpan(chars, offsets, from: start, to: end) {
            result.append(leading.span)
            contentStart = leading.contentIndex
        }
        scanInline(chars, offsets, from: contentStart, to: end, rescue: rescue, into: &result)
    }

    /// The line-leading kinds.
    ///
    /// **A HEADING must begin at the line's FIRST character** — no
    /// leading-whitespace tolerance (CommonMark allows up to three spaces;
    /// allowing it here would make an indented line silently become a
    /// heading, and "it starts the line or it is text" is the rule a writer
    /// can hold in her head).
    ///
    /// **A LIST LEAD may be INDENTED** (13k K8, her ruling — *"we should
    /// allow indented lists and it should happen when you click tab"*): a
    /// leading run of spaces and tabs before `- ` nests the item, and the run
    /// joins `markers[0]` because it is part of the lead. The widening is
    /// deliberately LIST-ONLY, which is what keeps the heading rule above
    /// exactly as it shipped.
    ///
    /// **The consequence, stated where it happens:** no stored byte changes
    /// anywhere, but a line in an EXISTING note that already begins with
    /// spaces + `- ` now renders as a list item where it used to render as
    /// prose. That is the ruling's intent (author-approved with the
    /// consequence named).
    private static func leadingSpan(
        _ chars: [Character], _ offsets: [Int], from start: Int, to end: Int
    ) -> (span: Span, contentIndex: Int)? {
        guard start < end else { return nil }

        // Heading: 1–3 `#` followed by a SPACE. `#tag` is plain (no space);
        // `####` is plain (F-3 names three sizes); `"# "` at the line's end is
        // a heading with empty content — she has typed the marker and is
        // about to type the words.
        if chars[start] == "#" {
            var level = 0
            var index = start
            while index < end, chars[index] == "#" {
                level += 1
                index += 1
            }
            guard level <= 3, index < end, chars[index] == " " else { return nil }
            let markerEnd = index + 1
            return (
                Span(
                    kind: .heading(level: level),
                    range: offsets[start]..<offsets[end],
                    markers: [offsets[start]..<offsets[markerEnd]],
                    content: offsets[markerEnd]..<offsets[end]),
                markerEnd)
        }

        // The indent run (13k K8): spaces and tabs only — a line holds no
        // newline here, so this can never run past its own line.
        var lead = start
        while lead < end, chars[lead] == " " || chars[lead] == "\t" { lead += 1 }
        let level = indentLevel(chars, from: start, to: lead)

        // Bullets and checkboxes both open with `"- "` (the HYPHEN is the
        // list marker — her words, "hyphens, [], bullets"). `*` is
        // deliberately NOT a bullet in v1: it would collide with italic at a
        // line's start, and one unambiguous list marker is worth more than
        // CommonMark parity here.
        guard lead < end, chars[lead] == "-", lead + 1 < end, chars[lead + 1] == " "
        else { return nil }

        // Checkbox first — `- [ ] a` also matches the bullet shape.
        if lead + 4 < end, chars[lead + 2] == "[", chars[lead + 4] == "]",
           let checked = boxState(chars[lead + 3]),
           lead + 5 == end || chars[lead + 5] == " " {
            let boxEnd = lead + 5
            // The single space after the box is ordinary text, not a marker.
            let contentIndex = min(boxEnd + 1, end)
            return (
                Span(
                    kind: .checkbox(checked: checked),
                    range: offsets[start]..<offsets[end],
                    // `markers[0]` is the INDENT + `"- "` — the whole lead, so
                    // a surface that substitutes the lead strips the indent
                    // for free and `markers[1]` is still exactly the box.
                    markers: [
                        offsets[start]..<offsets[lead + 2],
                        offsets[lead + 2]..<offsets[boxEnd],
                    ],
                    content: offsets[contentIndex]..<offsets[end],
                    indentLevel: level),
                contentIndex)
        }

        let markerEnd = lead + 2
        return (
            Span(
                kind: .bullet,
                range: offsets[start]..<offsets[end],
                markers: [offsets[start]..<offsets[markerEnd]],
                content: offsets[markerEnd]..<offsets[end],
                indentLevel: level),
            markerEnd)
    }

    /// The ruled arithmetic: a TAB is one level, spaces are `floor(n / 2)`,
    /// and the two sum. An odd space count simply lands between levels —
    /// which is what the stored text says, and this never rewrites it.
    private static func indentLevel(_ chars: [Character], from: Int, to: Int) -> Int {
        var tabs = 0
        var spaces = 0
        for index in from..<to where index < chars.count {
            if chars[index] == "\t" { tabs += 1 } else { spaces += 1 }
        }
        return tabs + spaces / 2
    }

    /// **The indent UNIT the app inserts** (13k K8, ruled): two spaces per
    /// level. Public because the editing acts and the ⏎ continuation both
    /// build leads from it, and one constant is what keeps them agreeing.
    public static let indentUnit = "  "

    /// Whether `line`'s first line READS AS A LIST LEAD (bullet or
    /// checkbox) per this law — the exact mirror of `leadingSpan`'s list
    /// rule: an optional space/tab indent run, then `"- "` (a checkbox is
    /// the bullet shape and matches for free).
    ///
    /// Public because the SEGMENTATION TRIM rule consults it (the mobile
    /// S1 batch-2 trim-law adjudication, 2026-08-03: a segmented piece
    /// that reads as a list lead KEEPS its leading indent — K8 made that
    /// indent meaningful nesting content, and the Phase 2 trim predated
    /// the vocabulary). Housing the predicate HERE, beside the tokenizer
    /// it mirrors, is what keeps the two laws from ever drifting: the
    /// widening is list-only in both places by construction.
    public static func isListLead(_ line: String) -> Bool {
        line.dropFirst(leadingWhitespace(of: line).count).hasPrefix("- ")
    }

    /// The leading whitespace of `text`'s first line — the run a continued
    /// or re-led list item must carry so nesting survives the keystroke.
    /// Pure, and it never looks past the first newline.
    public static func leadingWhitespace(of text: String) -> String {
        var result = ""
        for char in text {
            guard char == " " || char == "\t" else { break }
            result.append(char)
        }
        return result
    }

    /// `" "` ⇒ unchecked, `x`/`X` ⇒ checked, anything else ⇒ not a box (so
    /// `- [] a` and `- [?] a` fall through to an ordinary bullet).
    private static func boxState(_ char: Character) -> Bool? {
        switch char {
        case " ": return false
        case "x", "X": return true
        default: return nil
        }
    }

    // MARK: - Inline

    private static func scanInline(
        _ chars: [Character], _ offsets: [Int],
        from: Int, to: Int, rescue: Int?, into result: inout [Span]
    ) {
        var index = from
        while index < to {
            if let match = matchInline(chars, offsets, at: index, limit: to, rescue: rescue) {
                result.append(match.span)
                index = match.next
            } else {
                // An opener with no closer is plain text; advance ONE
                // grapheme so a later opener on the same line still matches
                // (`**a*b*` ⇒ the italic is found).
                index += 1
            }
        }
    }

    private static func matchInline(
        _ chars: [Character], _ offsets: [Int], at index: Int, limit: Int, rescue: Int?
    ) -> (span: Span, next: Int)? {
        switch chars[index] {
        case "`":
            // Code has NO flanking rule (CommonMark doesn't either) —
            // backticks legitimately wrap spaces and operators. Its content
            // is not rescanned, which is the whole point of code.
            guard let close = firstIndex(of: "`", chars, from: index + 1, to: limit),
                  close > index + 1
            else { return nil }
            return (
                Span(
                    kind: .code,
                    range: offsets[index]..<offsets[close + 1],
                    markers: [
                        offsets[index]..<offsets[index + 1],
                        offsets[close]..<offsets[close + 1],
                    ],
                    content: offsets[index + 1]..<offsets[close]),
                close + 1)

        case "*" where index + 1 < limit && chars[index + 1] == "*":
            guard let close = closingPair(
                "*", chars, openerEnd: index + 2, to: limit, rescue: rescue)
            else {
                return nil
            }
            return (
                pairSpan(.bold, offsets, open: index, close: close, width: 2),
                close + 2)

        case "~" where index + 1 < limit && chars[index + 1] == "~":
            guard let close = closingPair(
                "~", chars, openerEnd: index + 2, to: limit, rescue: rescue)
            else {
                return nil
            }
            return (
                pairSpan(.strikethrough, offsets, open: index, close: close, width: 2),
                close + 2)

        case "*":
            // A `**` that failed to close is NOT an empty italic over its two
            // stars — `**unfinished` must read as plain text.
            guard index + 1 < limit, chars[index + 1] != "*",
                  let close = closingSingle(
                      "*", chars, openerEnd: index + 1, to: limit, rescue: rescue)
            else { return nil }
            return (
                pairSpan(.italic, offsets, open: index, close: close, width: 1),
                close + 1)

        case "_":
            // Row 84: `_italic_` — the star's rule with WORD BOUNDARIES on
            // both sides, so an underscore inside an identifier never opens
            // or closes a span.
            guard isWordStart(chars, at: index),
                  index + 1 < limit, chars[index + 1] != "_",
                  let close = closingUnderscore(
                      chars, openerEnd: index + 1, to: limit, rescue: rescue)
            else { return nil }
            return (
                pairSpan(.italic, offsets, open: index, close: close, width: 1),
                close + 1)

        case "[":
            return linkSpan(chars, offsets, at: index, limit: limit)

        default:
            return nil
        }
    }

    /// Row 84's word boundary: the character before `index` is nothing, or
    /// not a letter/digit/underscore (whitespace, punctuation, a symbol) —
    /// so an underscore RUN (`__bold__`, `snake__case`) never opens.
    private static func isWordStart(_ chars: [Character], at index: Int) -> Bool {
        index == 0 || !isWordCharacter(chars[index - 1])
    }

    private static func isWordCharacter(_ char: Character) -> Bool {
        char.isLetter || char.isNumber || char == "_"
    }

    /// The closing underscore: the minimal flanking rule (no whitespace
    /// after the opener, none before the closer) AND the closer must end a
    /// word — the character after it is nothing, or not a letter, digit or
    /// underscore (the stricter rule: `_lead_ing` and `a_b_` never close
    /// there) — AND the content never ENDS in an underscore (ladder R1-11,
    /// the orchestrator's rule for the corner: `_a__` is LITERAL; an italic
    /// `a_` is nonsense, and the opener already refuses content that
    /// STARTS with one — `__bold__`). VX-296: the whitespace test — and only
    /// it — yields to the live caret (`spans(in:caret:)`); the word-end and
    /// the no-trailing-underscore tests hold at the caret too.
    private static func closingUnderscore(
        _ chars: [Character], openerEnd: Int, to: Int, rescue: Int?
    ) -> Int? {
        guard openerEnd < to, !chars[openerEnd].isWhitespace else { return nil }
        var index = openerEnd + 1
        while index < to {
            if chars[index] == "_",
               closerFlanks(chars, at: index, rescue: rescue), chars[index - 1] != "_",
               index + 1 >= to || !isWordCharacter(chars[index + 1]) {
                return index
            }
            index += 1
        }
        return nil
    }

    private static func pairSpan(
        _ kind: Kind, _ offsets: [Int], open: Int, close: Int, width: Int
    ) -> Span {
        Span(
            kind: kind,
            range: offsets[open]..<offsets[close + width],
            markers: [
                offsets[open]..<offsets[open + width],
                offsets[close]..<offsets[close + width],
            ],
            content: offsets[open + width]..<offsets[close])
    }

    /// `[text](url)`.
    ///
    /// Two decisions worth stating: the link TEXT does not nest (the first
    /// `]` closes it, so `[a[b]](u)` is plain text — a nesting parser buys
    /// nothing a writer of prose would use), and the URL's parentheses are
    /// BALANCED, so `[a](http://x/a(b))` links the whole address. Empty text
    /// or an empty URL is plain text (a link to nowhere is not a link).
    private static func linkSpan(
        _ chars: [Character], _ offsets: [Int], at index: Int, limit: Int
    ) -> (span: Span, next: Int)? {
        guard let close = firstIndex(of: "]", chars, from: index + 1, to: limit),
              close > index + 1,
              close + 1 < limit, chars[close + 1] == "("
        else { return nil }

        var depth = 1
        var scan = close + 2
        while scan < limit {
            if chars[scan] == "(" {
                depth += 1
            } else if chars[scan] == ")" {
                depth -= 1
                if depth == 0 { break }
            }
            scan += 1
        }
        guard scan < limit, depth == 0, scan > close + 2 else { return nil }

        return (
            Span(
                kind: .link,
                range: offsets[index]..<offsets[scan + 1],
                markers: [
                    offsets[index]..<offsets[index + 1],
                    offsets[close]..<offsets[close + 2],
                    offsets[scan]..<offsets[scan + 1],
                ],
                content: offsets[index + 1]..<offsets[close],
                url: offsets[close + 2]..<offsets[scan]),
            scan + 1)
    }

    // MARK: - Closers

    /// The MINIMAL flanking rule (`*`, `**`, `~~` only): an opener may not be
    /// followed by whitespace and a closer may not be preceded by it.
    ///
    /// This is what keeps `2 * 3 * 4` arithmetic instead of italics — the one
    /// false positive a prose writer would actually hit — for two comparisons
    /// per candidate. Content is required NON-EMPTY for the same family, so
    /// `****` and `* *` stay literal.
    ///
    /// **VX-296 — the closer half yields to the live caret, the opener half
    /// never does.** `closerFlanks` is the closer test; `rescue` is the
    /// character index of the live editor's caret (nil for every other
    /// reader, which therefore reads exactly what it read before).
    private static func closingPair(
        _ char: Character, _ chars: [Character], openerEnd: Int, to: Int, rescue: Int?
    ) -> Int? {
        guard openerEnd < to, !chars[openerEnd].isWhitespace else { return nil }
        var index = openerEnd + 1
        while index <= to - 2 {
            if chars[index] == char, chars[index + 1] == char,
               closerFlanks(chars, at: index, rescue: rescue) {
                return index
            }
            index += 1
        }
        return nil
    }

    private static func closingSingle(
        _ char: Character, _ chars: [Character], openerEnd: Int, to: Int, rescue: Int?
    ) -> Int? {
        guard openerEnd < to, !chars[openerEnd].isWhitespace else { return nil }
        var index = openerEnd + 1
        while index < to {
            if chars[index] == char, closerFlanks(chars, at: index, rescue: rescue) {
                return index
            }
            index += 1
        }
        return nil
    }

    /// The closer half of the minimal flanking rule: a closing marker at
    /// `index` may not be preceded by whitespace — UNLESS the live caret sits
    /// exactly there (VX-296), between the space she just typed and the
    /// marker she has not reached. Every caller has `index > openerEnd >= 1`,
    /// so `index - 1` is always a character of the same line.
    private static func closerFlanks(_ chars: [Character], at index: Int, rescue: Int?) -> Bool {
        !chars[index - 1].isWhitespace || index == rescue
    }

    private static func firstIndex(
        of char: Character, _ chars: [Character], from: Int, to: Int
    ) -> Int? {
        var index = from
        while index < to {
            if chars[index] == char { return index }
            index += 1
        }
        return nil
    }
}
