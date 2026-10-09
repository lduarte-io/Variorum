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
    ///
    /// **13n-a — THE GRAMMAR LIVES IN CORE NOW** (`VariorumCore.CaptureTokens`,
    /// moved there byte-for-byte): the Variorum document format reads its
    /// header line by this exact rule, and core cannot see this target. This
    /// face delegates — one rule, one home — and every capture suite pinning
    /// the rules above rides unmodified (the zero-test-edit proof that the
    /// move changed an address, not a behaviour). The quote rule's history
    /// (13u4 UNIT C1's measured finding: the capture boxes substitute curly
    /// quotes as she types, so `"` · `“` · `”` are all accepted, opener and
    /// closer independently) stays recorded here and on `CaptureTokens`.
    static func parse(_ raw: String) -> Capture {
        let parsed = CaptureTokens.parse(raw)
        return Capture(text: parsed.text, tagPaths: parsed.tagPaths, title: parsed.title)
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
