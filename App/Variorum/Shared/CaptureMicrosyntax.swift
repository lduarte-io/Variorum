//
//  CaptureMicrosyntax.swift
//  Variorum — SHARED (both platforms)
//
//  **13u4 item 2 — THE CAPTURE MICROSYNTAX.** Her ask, verbatim (the 13u3
//  morning sitting): *"if you put a hashtag within curly brackets like
//  {#dream} it would be a journal - I wouldn't want it applied to just any
//  hashtag… And maybe a {t:"my title"}? this is more for quicknotes on the
//  phone. I could see them disappearing from text or not disappearing once
//  the note is made, either one."*
//
//  **HER RULING R-13u4-1** (the 13u4 sizing-and-rulings sitting), which is
//  the whole of what this file implements and the whole of what it may do:
//  *"what i meant by that is the tag would be applied when within the curly
//  brackets and if there's a smart book based on that tag, it would go in
//  that smart book based on standard tag rules. so {#dream} may land in a
//  dream journal and {#workout} might go in a smart workout book if I have
//  one of those, for example."* So:
//
//  · `{#tag/path}` APPLIES THE TAG, and membership follows by the STANDING
//    smart-book tag rules — **there is no routing machinery here, of any
//    kind, and no journal special case.** A smart book picks the note up
//    because a tag applied, full stop.
//  · `{t:"my title"}` sets the title, through the standing title road
//    (`importPost(title:)`).
//  · **Only the braced forms parse.** A bare #hashtag is never touched —
//    her own line, *"I wouldn't want it applied to just any hashtag"*.
//  · **Malformed braces pass through as typed text**, byte-intact.
//  · **Tokens DISAPPEAR once parsed** (her pick of the offered pair).
//
//  ── WHERE THE RULE LIVES, AND WHEN IT RUNS ──────────────────────────────
//  ONE pure function in `Shared/`, on the `PlainPaste` pattern, so the Mac's
//  two capture doors and the phone's (whose face is a later parity row) all
//  consume one rule — the forked-brains rule applied before the fork can
//  happen.
//
//  **It runs at the HAND-OFF — the act of filing — and NEVER while she
//  types.** Her words were about the note once it is made; the box holds
//  exactly what she typed until ⏎ files it, so a token is ordinary text
//  right up to the moment it becomes a tag. (The one visible consequence is
//  recorded as a PROVISIONAL, QUESTIONS #127(e): the first-words title chip
//  still offers the RAW opening while she types, and the name it stores is
//  derived from the cleaned text at the hand-off.)
//
//  **FILING NEVER BLOCKS ON A TOKEN** (`applyTags` below, and the doors that
//  call it): the note is minted first and the tags are applied to it after,
//  so nothing a token can do — an invalid name, a store refusal mid-round —
//  can cost her the capture. A tag that does not land speaks a refusal (18i:
//  a door that did nothing says so), and the note is already safe.
//

import Foundation
import VariorumCore

nonisolated enum CaptureMicrosyntax {
    /// What a capture turns out to be: the text that becomes the note, and
    /// the tokens that were taken out of it.
    struct Capture: Equatable, Sendable {
        /// The capture with every parsed token removed — what `importPost`
        /// is handed. Byte-identical to the input when nothing parsed, apart
        /// from its line endings (rule 0).
        var text: String
        /// Every `{#…}` in the capture, in the order they appeared. Several
        /// are legal; each one applies.
        var tagPaths: [String]
        /// The FIRST `{t:"…"}`. Later ones are parsed and disappear too, but
        /// do not change the title (PROVISIONAL, QUESTIONS #127(a)).
        var title: String?

        var carriesTokens: Bool { !tagPaths.isEmpty || title != nil }
    }

    /// THE RULE, stated so a reader never has to infer it from the code:
    ///
    /// 0. **Line endings are read first** (18o U3 — ledger row 12b): `"\r\n"`
    ///    and a bare `"\r"` are `"\n"` before any rule below runs —
    ///    `SegmentationRules.normalizedLineEndings`, the segmenter's own
    ///    reading (18o U2, 17e P23) and `PlainPaste` rule 1's. `"\r\n"` is
    ///    ONE Swift `Character` that is not `"\n"`, so without this a capture
    ///    pasted from a Windows (or classic-Mac) source was a single "line"
    ///    to rules 2 and 5: an unclosed `{#` scanned across its line breaks —
    ///    and, opening the capture, could swallow it whole into a tag path —
    ///    and a token-only line kept its break, a blank paragraph downstream.
    ///    U+2028, U+2029 and U+0085 stay CONTENT, as everywhere in the
    ///    block-boundary family (`NewlineSplitting`'s doc).
    /// 1. **Only two shapes parse**, and only with their opener spelled
    ///    exactly: `{#` … `}` and `{t:"` … `"}` (the `t` is read
    ///    case-insensitively — PROVISIONAL #127(b) — because iOS
    ///    capitalizes the first letter of a capture and her own use for
    ///    this is phone-first; and the title's quotes may be straight or
    ///    CURLY, because the capture boxes substitute them as she types —
    ///    the walk's measured finding, `isQuote` below). Anything else that
    ///    happens to contain a brace is TEXT.
    /// 2. **A token lives on ONE line.** The scan for a closing brace never
    ///    crosses a newline, so an unclosed `{#` cannot swallow the rest of
    ///    the capture.
    /// 3. **A token's value must be non-empty after trimming, and a tag's
    ///    may not contain a brace.** `{#}`, `{t:""}` and `{#a{#b` are
    ///    malformed and pass through BYTE-INTACT — a token that cannot do
    ///    its job stays visible rather than vanishing silently.
    /// 4. **A token takes its own seam whitespace with it** (PROVISIONAL
    ///    #127(c)): the horizontal whitespace immediately before it goes,
    ///    unless the token opens its line, in which case the whitespace
    ///    immediately after it goes instead — so `Had a dream {#dream}`
    ///    files as `Had a dream` and `{#dream} Had a dream` as
    ///    `Had a dream`, with her own indentation untouched either way.
    /// 5. **A line that held nothing but tokens goes with them**, its
    ///    newline included — otherwise a title token on its own line would
    ///    leave a blank paragraph at the top of every note captured that
    ///    way (`bulkSegments` stores the blank line as content, by the
    ///    2026-07-12 spacing ruling).
    /// 6. **Text with no `{` passes through BYTE-IDENTICAL** apart from rule
    ///    0's line endings, and so does text whose braces all turn out to be
    ///    malformed — the capture is hers, and the app does not tidy it
    ///    (`PlainPaste`'s own doctrine, one door over, whose rule 1 reads line
    ///    endings exactly as rule 0 does; and the segmenter the text goes to
    ///    next reads them so anyway).
    static func parse(_ raw: String) -> Capture {
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

    // MARK: - Internals

    private struct LineRead {
        var text: String
        var tagPaths: [String]
        var title: String?
        var foundToken: Bool
    }

    private enum TokenValue {
        case tag(String)
        case title(String)
    }

    private struct Token {
        let value: TokenValue
        /// The index just past the token's closing brace.
        let end: String.Index
    }

    private static func readLine(_ line: String) -> LineRead {
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

    /// **THE WALK'S OWN FINDING, 13u4 UNIT C1 (2026-09-20).** The Mac capture
    /// boxes apply AppKit's automatic quote substitution, so a title token
    /// typed by hand arrives as `{t:”Ocean dream”}` — U+201D, measured by
    /// hexdump of the box's own accessibility value, not inferred. Under a
    /// straight-quote-only rule her title token filed as visible text and
    /// silently did nothing, while the `{#tag}` beside it worked; the pins
    /// could never have caught it, because a pin types the characters it
    /// means. The phone will do the same (iOS substitutes too).
    ///
    /// So the rule accepts all three: `"` · `“` · `”`, opener and closer
    /// independently. The alternative — turning substitution OFF in the
    /// capture boxes — would change what HER PROSE looks like everywhere in
    /// them to make one token work, which is the tail wagging the dog.
    private static func isQuote(_ character: Character) -> Bool {
        character == "\"" || character == "\u{201C}" || character == "\u{201D}"
    }

    private static func isHorizontal(_ character: Character) -> Bool {
        character != "\n"
            && character.unicodeScalars.allSatisfy(CharacterSet.whitespaces.contains)
    }
}

// MARK: - The tokens' acts (after the mint, never before it)

@MainActor
extension CaptureMicrosyntax {
    /// The sentence a token that did not land speaks. It is a REFUSAL by
    /// 18i's grammar — the tag door did nothing — and it names what DID
    /// happen first, because the note is already safe and that is the half
    /// she needs to read.
    ///
    /// `reason` arrives already worded by the platform's own refusal copy
    /// (the Mac's `TagsViewModel.message`), so this shared sentence names no
    /// platform and no door.
    static func tagRefusal(path: String, reason: String) -> String {
        "The note was filed — the tag “\(path)” didn't apply. \(reason)"
    }

    /// Apply the capture's tags to the note it became, through the HOISTED
    /// typed-path brain (its creation, validation and refusal rules
    /// unchanged — a token is a typed path like any other).
    ///
    /// **It never throws and never undoes anything.** The note exists before
    /// this runs; each token is tried in turn, and every one that fails
    /// comes back as a sentence for the caller to speak. Filing can never be
    /// blocked by a token — the `shelveInDailyJournalBook` posture: report
    /// what happened, never take the capture down with the bookkeeping.
    static func applyTags(
        _ capture: Capture, toPost postID: String, session: AppSession,
        wording reason: (Error) -> String
    ) async -> [String] {
        guard !capture.tagPaths.isEmpty else { return [] }
        var refusals: [String] = []
        for path in capture.tagPaths {
            switch await TypedTagPath.apply(path, toPost: postID, session: session) {
            case .applied:
                continue
            case .nothingTyped:
                // Reachable: `{#///}` is a well-formed token whose value is
                // all separators, so it parses and then names no tag.
                refusals.append(tagRefusal(path: path, reason: TypedTagPath.emptyMessage))
            case .refused(let error):
                refusals.append(tagRefusal(path: path, reason: reason(error)))
            }
        }
        return refusals
    }
}
