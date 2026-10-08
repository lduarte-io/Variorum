//
//  SearchAnswerFaces.swift
//  Variorum (Mac)
//
//  **13o — THE ANSWER SHEET'S SHARED PIECES** (moved here at 13o U3 from
//  `Features/Library/`, CLAUDE.md's shared-home rule: the book's in-place
//  answer sheet — the architect's ruling F1, "the answer sheet's small
//  sibling" — is their second consumer). Names preserved (the 3C parity
//  pattern: every pre-move pin compiles unchanged): the quiet CHIP, the
//  passage LINE, the sheet's pure rules (`LibrarySearchFace`), and the words
//  both sheets say (`SearchAnswerCopy`; `LibrarySearchCopy` forwards its
//  pre-move names).
//

import SwiftUI
import VariorumCore

/// **What every answer sheet says** — the passage line's kind words and
/// badges, the group's road, the archived facet's words. One home, so the
/// Library's sheet and the book's never speak a passage two ways.
nonisolated enum SearchAnswerCopy {
    /// The query's echo — the words, as typed, in quotes (the mockup's
    /// `“dream”`).
    static func echo(_ words: String) -> String {
        "\u{201C}\(words)\u{201D}"
    }

    /// "all N ›" — the group's whole road (R-13o-9).
    static func allLines(_ n: Int) -> String { "all \(n) \u{203A}" }
    /// The open group's road closed again.
    static let fewerLines = "fewer \u{2039}"
    /// The next page of an open group's passages.
    static let moreLines = "more \u{203A}"
    static let loadingMore = "loading more\u{2026}"

    /// The badge a hit in an UNRENDERED take wears (the mockup's own).
    static let inAnotherTake = "in another take"

    /// What a non-prose passage IS — said before its words, so a block's
    /// name never reads as its prose (PROVISIONAL P-13o-U2-8). Takes and
    /// titles say nothing (the line is prose; the head is the title).
    static func kindWord(_ kind: SearchPassage.Kind) -> String? {
        switch kind {
        case .take, .title, .wornDay: nil
        case .takeLabel: "take label"
        case .blockName: "block name"
        case .comment: "comment"
        case .noteMeta: "floating notes"
        case .book: "book"
        case .chapter: "chapter"
        }
    }

    /// An archived group's mark (only ever drawn under the facet) — and,
    /// since 13o U3, the badge an archived passage wears.
    static let archivedMark = "archived"

    /// **An archived NOTE's line under its head** (13o U3 — under the facet
    /// the rows say which they are; PROVISIONAL P-13o-U3-5's words).
    static let archivedNote = "archived note \u{2014} kept out of the Library"

    /// The archived facet's chip (D4): an invitation at rest, the armed word
    /// with its ✕ when on.
    static let archivedOff = "+ archived"
    static let archivedOn = "archived"
    static let archivedOffHelp = "Include archived notes, books and takes"
    static let archivedOnHelp = "Back to the living library \u{2014} leave the archive out"

    /// **The archived foot** (D4 — PROVISIONAL P-13o-U2-3's wording): with
    /// the facet off and archived matches present, the sheet's last line
    /// says how many places they would add, with the door.
    static func archivedFoot(_ places: Int) -> String {
        "\(places) more in the archive \u{2014}"
    }

    static let showArchived = "show archived"
}

/// **The pure rule every sheet's groups share**: a group's LINES are its
/// passages that are not its name (the head already says the name).
nonisolated enum SearchAnswerFace {
    static func lines(of passages: [SearchPassage]) -> [SearchPassage] {
        passages.filter { $0.kind != .title && $0.kind != .wornDay }
    }
}

/// **The field's tokens, read ONE way for every band's echo** (ladder round
/// 1, NIT-1 — the Library's and the book's bands each carried their own
/// words rule; one home now, beside the sheets' other shared pieces).
/// Whitespace-separated with quoted phrases kept whole (the v1 grammar's
/// own token shape), each token classified EXACTLY as `SearchQueryParser`
/// reads it — the adopted caveat: the PARSER's letter, neither old copy —
/// a `#path` is a TAG (trailing slashes trimmed), a lone `#` is a WORD,
/// and `#/` (an empty path) is NEITHER (the parser's tag branch drops it).
nonisolated enum SearchFieldWords {
    /// The band's echo: the words as typed, tags (and the dropped `#/`)
    /// aside.
    static func words(of text: String) -> String {
        tokens(of: text).filter { !isTagShaped($0) }.joined(separator: " ")
    }

    /// The typed `#tag` paths, in the order typed.
    static func tagPaths(of text: String) -> [String] {
        tokens(of: text).filter(isTag).map(tagPath)
    }

    /// The v1 grammar's own token shape: whitespace-separated, a quoted
    /// phrase kept whole (`SearchQueryParser`'s reading).
    static func tokens(of text: String) -> [String] {
        var tokens: [String] = []
        var current = ""
        var quoted = false
        for ch in text {
            if isQuote(ch) { quoted.toggle(); current.append(ch); continue }
            if ch.isWhitespace, !quoted {
                if !current.isEmpty { tokens.append(current); current = "" }
            } else {
                current.append(ch)
            }
        }
        if !current.isEmpty { tokens.append(current) }
        return tokens
    }

    /// The parser's tag: `#` + a non-empty path once trailing slashes trim.
    static func isTag(_ token: String) -> Bool {
        isTagShaped(token) && !tagPath(token).isEmpty
    }

    /// What the parser's TAG BRANCH takes (`#/` included — it then drops
    /// it, so the token is no word either).
    static func isTagShaped(_ token: String) -> Bool {
        token.hasPrefix("#") && token.count > 1
    }

    static func tagPath(_ token: String) -> String {
        var path = String(token.dropFirst())
        while path.hasSuffix("/") { path.removeLast() }
        return path
    }

    private static func isQuote(_ ch: Character) -> Bool {
        ch == "\"" || ch == "\u{201C}" || ch == "\u{201D}"
    }
}

/// **One quiet chip** — the mockup's: a hairline-bordered label on the
/// paper, its ✕ when it can be taken off; an INVITATION (a filter not yet
/// applied) wears a dashed border and the muted ink.
struct LibrarySearchChip: View {
    let tokens: VoiceTokens
    let label: String
    var help: String? = nil
    var invitation = false
    var onTap: (() -> Void)? = nil
    var onClear: (() -> Void)? = nil

    var body: some View {
        let face = HStack(spacing: 4) {
            Text(label)
                .font(tokens.small)
                .foregroundStyle(invitation ? tokens.muted : tokens.ink)
                .lineLimit(1)
            if let onClear {
                Button(action: onClear) {
                    Text("\u{2715}")
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(help ?? "Clear")
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 1.5)
        .background(RoundedRectangle(cornerRadius: 6).fill(tokens.surface))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(
                    tokens.line,
                    style: StrokeStyle(lineWidth: 1, dash: invitation ? [3, 2] : [])))
        .fixedSize()
        .help(help ?? "")
        Group {
            if let onTap {
                Button(action: onTap) { face }
                    .buttonStyle(.plain)
            } else {
                face
            }
        }
    }
}

/// **One passage line** — its kind word where it is not prose, its snippet
/// with the matched words marked in the index's own folding (what matched
/// IS what is marked — F1), and the "in another take" badge where the hit's
/// take is not the one the note shows. A click lands it (D6).
struct LibrarySearchLine: View {
    let tokens: VoiceTokens
    let passage: SearchPassage
    /// 13o U3: the passage is archived on its own (its take or its block) —
    /// only ever under the archived facet.
    var archivedBadge = false
    let onOpen: () -> Void

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            if let word = SearchAnswerCopy.kindWord(passage.kind) {
                Text(tokens.chromeLabel(word))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .fixedSize()
            }
            Text(LibrarySearchFace.snippet(passage.snippet, tokens: tokens))
                .font(tokens.small)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            if LibrarySearchFace.isInAnotherTake(kind: passage.kind, rendered: passage.isRenderedTake) {
                badge(SearchAnswerCopy.inAnotherTake)
            }
            if archivedBadge {
                badge(SearchAnswerCopy.archivedMark)
            }
            Spacer(minLength: 0)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onOpen)
    }

    /// The mockup's quiet badge (hairline-bordered, muted).
    private func badge(_ word: String) -> some View {
        Text(tokens.chromeLabel(word))
            .font(tokens.small)
            .foregroundStyle(tokens.muted)
            .padding(.horizontal, 5)
            .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(tokens.line))
            .lineLimit(1)
            .fixedSize()
    }
}

/// The sheet's pure rules (pinned).
enum LibrarySearchFace {
    /// The snippet's runs as one attributed line — the matched runs on the
    /// wash in the ink, the rest muted (the mockup's `<mark>`).
    static func snippet(_ segments: [SearchSnippetSegment], tokens: VoiceTokens) -> AttributedString {
        var line = AttributedString()
        for segment in segments {
            var run = AttributedString(segment.text)
            if segment.isMatch {
                run.foregroundColor = tokens.ink
                run.backgroundColor = tokens.wash
            } else {
                run.foregroundColor = tokens.muted
            }
            line += run
        }
        return line
    }

    /// A take hit the note does not render (the mockup's badge).
    static func isInAnotherTake(kind: SearchPassage.Kind, rendered: Bool) -> Bool {
        kind == .take && !rendered
    }

    /// **A passage wears the archived badge** (13o U3 — the archived facet's
    /// face, R-13o-6: *"rows say which they are"*) when something archived
    /// touches it and its GROUP is not already marked archived (an archived
    /// note says so once, under its head).
    static func wearsArchivedBadge(archived: Bool, inArchivedGroup: Bool) -> Bool {
        archived && !inArchivedGroup
    }

}
