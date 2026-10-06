// BRANCH-ONLY tool code (`tools/strings-workbook`; never merges). The record:
// notes/plans/strings-workbook-record.md.

import Foundation

/// **THE ⏎ AMBIGUITY, resolved from source (the batch record's finding F-1).**
///
/// The inventory's legend says "` ⏎ ` marks a line break inside a multi-line
/// literal" — but the sweep wrote EVERY raw ⏎ glyph the same way. The app uses
/// ⏎ as the Return-key symbol in 23 of the 25 literals that contain it ("type
/// one and ⏎ makes it"), and the sweep's rewrite is lossy: each glyph was
/// space-padded (source `(⌘⇧⏎)` reads `(⌘⇧ ⏎ )`), runs of spaces collapsed, and
/// a LEADING glyph was dropped (`"⏎ files it · ⇧⏎ …"` reads `"files it · ⇧ ⏎
/// …"`). Only TWO literals are genuine `"""` multi-line literals
/// (`AcknowledgmentsCopy.swift:149`, `HelperView.swift:494` — and the second
/// carries two Return glyphs among its three line breaks), so no doc-only rule
/// can tell a line break from a glyph.
///
/// The fix: every ⏎-bearing bullet's TRUE body, read from the source at its
/// first site (2026-10-05, branch base `dbb678c6`) and kept here in SOURCE
/// notation (escapes kept, rendered by `SwiftLiteralText` like every other
/// literal); a `"""` literal's real line breaks are its `lines`. Each entry is
/// SELF-VERIFYING at parse time: `inventoryForm(of:)` — the sweep's lossy
/// rewrite, stated as code — must reproduce the inventory's body EXACTLY, or
/// the parse refuses. A ⏎-bearing bullet with no entry refuses too: the tool
/// never guesses which ⏎ is a line break.
public enum ReturnGlyphCorrections {
    public struct Entry: Equatable, Sendable {
        /// The bullet's FIRST site, exactly as the inventory writes it.
        public let site: String
        /// The literal's lines in source notation; >1 only for a `"""` literal.
        public let lines: [String]
    }

    /// The correction for a bullet whose first site is `site`, if any.
    public static func entry(forSite site: String) -> Entry? {
        bySite[site]
    }

    /// The sweep's lossy rewrite, as code: line breaks and every ⏎ glyph
    /// become a space-padded ⏎, runs of spaces collapse, and leading/trailing
    /// ⏎ markers are trimmed. Verified against all 25 entries.
    public static func inventoryForm(of entry: Entry) -> String {
        var text = entry.lines.joined(separator: " ⏎ ").replacingOccurrences(of: "⏎", with: " ⏎ ")
        while text.contains("  ") { text = text.replacingOccurrences(of: "  ", with: " ") }
        text = text.trimmingCharacters(in: .whitespaces)
        while text.hasPrefix("⏎") { text = String(text.dropFirst()).trimmingCharacters(in: .whitespaces) }
        while text.hasSuffix("⏎") { text = String(text.dropLast()).trimmingCharacters(in: .whitespaces) }
        return text
    }

    /// The screen text: each line rendered, joined by real newlines (I4 —
    /// internal newlines are content).
    public static func render(_ entry: Entry) throws -> String {
        try entry.lines.map(SwiftLiteralText.render).joined(separator: "\n")
    }

    static let bySite: [String: Entry] = Dictionary(
        uniqueKeysWithValues: all.map { ($0.site, $0) })

    /// Generated from source by the batch's survey script (not hand-copied).
    public static let all: [Entry] = [
        .init(site: "App/Variorum/Variorum/Features/Pool/SnippetsSurface.swift:50", lines: [#"new snippet — start typing · ⏎ keeps it as a standalone snippet"#]),
        .init(site: "App/Variorum/Variorum/Features/QuickNote/QuickNoteView.swift:547", lines: [#"⏎ files it · ⇧⏎ new paragraph · closing files it too"#]),
        .init(site: "App/Variorum/Variorum/Features/QuickNote/QuickNoteView.swift:611", lines: [#"the capture that couldn't be filed — ⏎ tries again"#]),
        .init(site: "App/Variorum/Variorum/Features/Tags/NoteTagChips.swift:357", lines: [#"No tags yet — type one and ⏎ makes it."#]),
        .init(site: "App/Variorum/Variorum/Features/Tags/TagViews.swift:46", lines: [#"type a tag — ⏎ applies it (new tags are created; “/” nests: life/goals)"#]),
        .init(site: "App/Variorum/Variorum/Features/Editor/CommentsPanel.swift:350", lines: [#"⏎ new line · ⌘⏎ saves · ⎋ undoes"#]),
        .init(site: "App/Variorum/Variorum/Features/Editor/CommitBar.swift:602", lines: [#"An immutable savepoint of the take under the caret — name it, or press ⏎ to save it unnamed"#]),
        .init(site: "App/Variorum/Variorum/Features/Editor/CommitBar.swift:691", lines: [#"＋ New block below this one (⌘⇧⏎)"#]),
        .init(site: "App/Variorum/Variorum/Features/Formatting/FormatBar.swift:139", lines: [#"Bold, italics, sizes, lists, links — and whether ⏎ makes new blocks. They slide out here; the rest of the bar stays put."#]),
        .init(site: "App/Variorum/Variorum/Registry/OpsRefusalCopy.swift:37", lines: [#"Newlines now stay inside the block in this note — typing and pasting won't make new blocks; Divide (⌘⇧D) or New Block Below (⌘⇧⏎) split deliberately. Existing blocks are untouched."#]),
        .init(site: "App/Variorum/Variorum/Registry/OpsRefusalCopy.swift:71", lines: [#"ON (the standard): in Write, Return makes a block wherever the cursor is — a new block below at a paragraph's end, a divide inside its text — and pasted paragraphs arrive as blocks; ⇧⏎ stays a newline inside the block, and a take pane's ⏎ is always content. OFF (opt-in): newlines stay INSIDE the block — typing and pasting never make blocks in this note; Divide (⌘⇧D) or New Block Below (⌘⇧⏎) split deliberately. Governs future entry only — existing blocks never re-segment. Per note — ON means \"follow the global setting\" (Settings ▸ Appearance ▸ Writing)."#]),
        .init(site: "App/Variorum/Variorum/Features/Takes/TakesBoardView.swift:1667", lines: [#"Choose this take — the note shows it (everywhere); ⌘⏎ from the keyboard"#]),
        .init(site: "App/Variorum/Variorum/Features/Takes/TakesBottomBar.swift:173", lines: [#"＋ New block below this one (⌘⇧⏎)"#]),
        .init(site: "App/Variorum/Variorum/Features/Takes/TakesBottomBar.swift:376", lines: [#"An immutable savepoint of the take you're in — name it, or press ⏎ to save it unnamed"#]),
        .init(site: "App/Variorum/Variorum/Features/Takes/TakesFindBar.swift:102", lines: [#" — or ⏎ in the field"#]),
        .init(site: "App/Variorum/Variorum/Features/Takes/TakesFindBar.swift:106", lines: [#" — or ⇧⏎ in the field"#]),
        .init(site: "App/Variorum/Variorum/Features/Takes/TakesViewModel.swift:2538", lines: [#"Click into a take first — ⌘⏎ chooses the take you're in."#]),
        .init(site: "App/Variorum/Variorum/Registry/OpsRefusalCopy.swift:93", lines: [#"The default for every note that has no setting of its own. ON (the standard): in Write, Return makes a block wherever the cursor is, and pasted paragraphs arrive as blocks. OFF: newlines stay inside the block everywhere — Divide (⌘⇧D) or New Block Below (⌘⇧⏎) split deliberately. Governs future entry only; existing blocks never re-segment, and a note with its own setting keeps it. Synced to all your devices."#]),
        .init(site: "App/Variorum/Shared/AcknowledgmentsCopy.swift:149", lines: [
            #"From the Bitcoin Improvement Proposals repository (BIP-0039) —"#,
            #"PD/BSD-2-Clause per the BIP's preamble; the wordlist is treated as"#,
            #"public-domain reference data across BIP-39 implementations."#,
            #"Upstream: https://github.com/bitcoin/bips/tree/master/bip-0039"#,
        ]),
        .init(site: "App/Variorum/Variorum/Features/Shelf/QuickEntryBar.swift:152", lines: [#"new note — just start typing · ⏎ opens it · ⇧⏎ new paragraph"#]),
        .init(site: "App/Variorum/Variorum/Features/Tags/MastheadTagCluster.swift:344", lines: [#"tag — ⏎ applies · / nests"#]),
        .init(site: "App/Variorum/Variorum/Features/Tags/NoteTagChips.swift:350", lines: [#"tag — ⏎ applies it (“/” nests: life/goals)"#]),
        .init(site: "App/Variorum/Variorum/Features/Help/HelperView.swift:85", lines: [#"commit — an immutable savepoint of the take you're in; name it or press ⏎ to save it unnamed"#]),
        .init(site: "App/Variorum/Variorum/Features/Help/HelperView.swift:351", lines: [#"An immutable savepoint of one take (⌘S). It can carry a NAME — ⌘S offers a field, ⏎ saves it named or not — and the name is editable afterwards from Block History. Commits are append-only: restoring one never erases another, and a name never touches the text."#]),
        .init(site: "App/Variorum/Variorum/Features/Help/HelperView.swift:494", lines: [
            #"⌘⇧T open/close takes · ⎋ close all"#,
            #"⌘T new take · ⌥⌘T blank · ⇧⌥⌘T blank & choose"#,
            #"⌘⏎ choose · ⌃⌘←/→ step takes · ⌘⇧A archive"#,
            #"⌘⇧L save as lens · ⌘S commit (⏎ saves it unnamed) · ⌘/ full list"#,
        ]),
    ]
}
