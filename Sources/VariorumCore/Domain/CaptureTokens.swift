import Foundation

/// **THE CAPTURE MICROSYNTAX'S GRAMMAR, IN CORE** (13n-a — the Variorum
/// document format's header line; R-13n-8: "the shipped Alternates sections
/// plus the capture microsyntax (`{t:"…"}`, `{#tag}`)").
///
/// This is the brace grammar of her ruling R-13u4-1 (13u4 item 2), MOVED here
/// byte-for-byte from the app's `Shared/CaptureMicrosyntax.swift` so the core
/// package — which cannot see the app target — can read a document's header
/// line by the SAME rule her capture boxes file by. The app's
/// `CaptureMicrosyntax.parse` now delegates here (the forked-brains rule:
/// one rule, one home; the app's capture suites pin the move — a zero-edit
/// run of them is the proof the move changed an address, not a behaviour).
/// The tokens' ACTS (applying a tag after the mint) stay app-side, where the
/// session and the refusal copy live.
///
/// THE RULE (stated in full on the app's `CaptureMicrosyntax.parse`, which
/// keeps the long-form narrative): rule 0 reads foreign line endings first;
/// only `{#…}` and `{t:"…"}` parse (the `t` case-insensitive, the title's
/// quotes straight or curly); a token lives on ONE line; an empty value or a
/// tag holding a brace is malformed and passes through byte-intact; a token
/// takes its own seam whitespace with it; a line that held nothing but tokens
/// goes with them; text with no `{` passes through byte-identical.
public enum CaptureTokens {
    /// What a capture turns out to be: the text that becomes the note, and
    /// the tokens that were taken out of it.
    public struct Capture: Equatable, Sendable {
        /// The capture with every parsed token removed.
        public var text: String
        /// Every `{#…}` in the capture, in the order they appeared.
        public var tagPaths: [String]
        /// The FIRST `{t:"…"}` (later ones parse and disappear, but do not
        /// change the title — PROVISIONAL, QUESTIONS #127(a)).
        public var title: String?

        public init(text: String, tagPaths: [String], title: String?) {
            self.text = text
            self.tagPaths = tagPaths
            self.title = title
        }

        public var carriesTokens: Bool { !tagPaths.isEmpty || title != nil }
    }

    /// One LINE read by the grammar — the document format's header-line
    /// reader (`VariorumDocument.parse` reads exactly one line this way).
    public struct LineRead: Equatable, Sendable {
        /// The line with every parsed token (and its seam whitespace) removed.
        public var text: String
        public var tagPaths: [String]
        /// The line's first title token, if any.
        public var title: String?
        /// Whether ANY token parsed on the line (rule 5 keys on it).
        public var foundToken: Bool
    }

    /// The whole-capture parse (the app's capture doors' rule).
    public static func parse(_ raw: String) -> Capture {
        // Rule 0 — every rule below is about LINES, so the lines are read
        // first, by the segmenter's own rule.
        let raw = SegmentationRules.normalizedLineEndings(raw)
        // The fast path AND the promise: no brace, nothing to do.
        guard raw.contains("{") else {
            return Capture(text: raw, tagPaths: [], title: nil)
        }
        var tagPaths: [String] = []
        var title: String?
        var kept: [String] = []
        for line in raw.split(separator: "\n", omittingEmptySubsequences: false) {
            let read = readLine(String(line))
            tagPaths.append(contentsOf: read.tagPaths)
            // The FIRST title in the whole capture wins.
            if title == nil { title = read.title }
            // Rule 5: a line that held only tokens leaves nothing behind.
            if read.foundToken, read.text.allSatisfy(isHorizontal) { continue }
            kept.append(read.text)
        }
        return Capture(text: kept.joined(separator: "\n"), tagPaths: tagPaths, title: title)
    }

    /// Reads ONE line (no newline inside it) by the grammar.
    public static func readLine(_ line: String) -> LineRead {
        guard line.contains("{") else {
            return LineRead(text: line, tagPaths: [], title: nil, foundToken: false)
        }
        var out = ""
        var tagPaths: [String] = []
        var title: String?
        var foundToken = false
        var i = line.startIndex
        while i < line.endIndex {
            guard line[i] == "{", let token = token(in: line, at: i) else {
                // Not a token: the character is hers, byte for byte. A
                // MALFORMED opener resumes the scan one character on, so a
                // well-formed token inside it is still found (`{#a{#b}` is
                // the text "{#a" and the tag "b").
                out.append(line[i])
                i = line.index(after: i)
                continue
            }
            foundToken = true
            switch token.value {
            case .tag(let path):
                tagPaths.append(path)
            case .title(let name):
                if title == nil { title = name }
            }
            var next = token.end
            if out.allSatisfy(isHorizontal) {
                // The token opens the line (only her indentation before it),
                // so the whitespace AFTER it is the seam.
                while next < line.endIndex, isHorizontal(line[next]) {
                    next = line.index(after: next)
                }
            } else {
                while let last = out.last, isHorizontal(last) { out.removeLast() }
            }
            i = next
        }
        return LineRead(text: out, tagPaths: tagPaths, title: title, foundToken: foundToken)
    }

    // MARK: - Internals

    private enum TokenValue {
        case tag(String)
        case title(String)
    }

    private struct Token {
        let value: TokenValue
        /// The index just past the token's closing brace.
        let end: String.Index
    }

    /// Reads a token at `start` (which is a `{`), or nil when what stands
    /// there is ordinary text.
    private static func token(in line: String, at start: String.Index) -> Token? {
        let afterBrace = line.index(after: start)
        guard afterBrace < line.endIndex else { return nil }

        if line[afterBrace] == "#" {
            let contentStart = line.index(after: afterBrace)
            guard let close = line[contentStart...].firstIndex(of: "}") else { return nil }
            let content = String(line[contentStart..<close])
            // A brace inside means an unclosed token ran into the next one.
            guard !content.contains("{") else { return nil }
            let path = content.trimmingCharacters(in: .whitespaces)
            guard !path.isEmpty else { return nil }
            return Token(value: .tag(path), end: line.index(after: close))
        }

        guard line[afterBrace] == "t" || line[afterBrace] == "T" else { return nil }
        let afterT = line.index(after: afterBrace)
        guard afterT < line.endIndex, line[afterT] == ":" else { return nil }
        let afterColon = line.index(after: afterT)
        guard afterColon < line.endIndex, isQuote(line[afterColon]) else { return nil }
        let contentStart = line.index(after: afterColon)
        // Scanning to the first QUOTE FOLLOWED BY `}` rather than to the
        // first quote is what lets a title carry quotes of its own:
        // {t:"say "hi""} is `say "hi"`.
        var cursor = contentStart
        var close: String.Index?
        while cursor < line.endIndex {
            let next = line.index(after: cursor)
            if isQuote(line[cursor]), next < line.endIndex, line[next] == "}" {
                close = cursor
                break
            }
            cursor = next
        }
        guard let close else { return nil }
        let name = String(line[contentStart..<close])
            .trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return nil }
        return Token(value: .title(name), end: line.index(after: line.index(after: close)))
    }

    /// Straight or curly — the capture boxes substitute quotes as she types
    /// (13u4 UNIT C1's measured finding; the app file keeps the narrative).
    static func isQuote(_ character: Character) -> Bool {
        character == "\"" || character == "\u{201C}" || character == "\u{201D}"
    }

    static func isHorizontal(_ character: Character) -> Bool {
        character != "\n"
            && character.unicodeScalars.allSatisfy(CharacterSet.whitespaces.contains)
    }
}
