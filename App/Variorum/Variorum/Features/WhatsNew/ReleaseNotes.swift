//
//  ReleaseNotes.swift
//  Variorum (MAC ONLY — the phone's What's New is the App Store road's, a
//  candidate parity row for the closeout, never this file's)
//
//  Phase 13r U3-A — THE ONE RELEASE-NOTES SOURCE (the U3 section: "ONE
//  source feeding the in-app What's New … AND the appcast's release notes").
//
//  THE SOURCE: one Markdown file per marketing version, in this folder —
//  `ReleaseNotes-<version>.md` — bundled as a resource (the synchronized
//  group copies it). Two readers, one text:
//    · IN THE APP, this file reads the CURRENT version's notes for What's
//      New (`WhatsNewSheet`), parsing the small grammar below;
//    · IN THE APPCAST, `Tools/Release/release.sh` copies the SAME file to
//      `Variorum-<version>.md` beside the DMG, and `generate_appcast
//      --embed-release-notes` embeds it as the item's `<description
//      sparkle:format="markdown">` — which Sparkle 2.10.0's update alert
//      renders natively (read from its source: `SUUpdateAlert` →
//      `SUTextViewReleaseNotesView prefersMarkdown:YES`). A release REFUSES
//      without the file; a walk build may lack one, and then the app says so
//      plainly (`WhatsNewCopy.noNotes`).
//
//  THE GRAMMAR (deliberately small — both renderers must agree on it):
//  `#`/`##`/`###` headings, `- ` or `* ` bullets, blank-line-separated
//  paragraphs (consecutive lines join with a space), inline **bold**,
//  *italic*, `code` and [links](url). Nothing else is promised.
//

import Foundation

nonisolated enum ReleaseNotes {
    /// The bundled file's name for a version (no extension).
    static func resourceName(for version: String) -> String { "ReleaseNotes-\(version)" }
    static let resourceExtension = "md"

    /// The Markdown source for `version`, or nil when this build carries none
    /// (a walk build — a release refuses without one).
    static func source(for version: String, in bundle: Bundle = .main) -> String? {
        guard let url = bundle.url(
            forResource: resourceName(for: version), withExtension: resourceExtension)
        else { return nil }
        let text = try? String(contentsOf: url, encoding: .utf8)
        return text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? text : nil
    }

    /// One rendered unit of the grammar.
    enum Block: Equatable, Sendable {
        case heading(String)
        case bullet(String)
        case paragraph(String)
    }

    /// The grammar's parse — pure, so the sheet's structure is pinnable.
    static func blocks(from markdown: String) -> [Block] {
        var blocks: [Block] = []
        var paragraph: [String] = []
        func flush() {
            if !paragraph.isEmpty {
                blocks.append(.paragraph(paragraph.joined(separator: " ")))
                paragraph = []
            }
        }
        for raw in markdown.components(separatedBy: .newlines) {
            let line = raw.trimmingCharacters(in: .whitespaces)
            if line.isEmpty {
                flush()
            } else if let heading = Self.heading(in: line) {
                flush()
                blocks.append(.heading(heading))
            } else if line.hasPrefix("- ") || line.hasPrefix("* ") {
                flush()
                blocks.append(.bullet(String(line.dropFirst(2)).trimmingCharacters(in: .whitespaces)))
            } else {
                paragraph.append(line)
            }
        }
        flush()
        return blocks
    }

    private static func heading(in line: String) -> String? {
        for marker in ["### ", "## ", "# "] where line.hasPrefix(marker) {
            return String(line.dropFirst(marker.count)).trimmingCharacters(in: .whitespaces)
        }
        return nil
    }
}

/// What's New's own words (functional and honest; 13s re-voices).
nonisolated enum WhatsNewCopy {
    /// The Help menu door (Help ▸ What's New — the brief's own words).
    static let menuTitle = "What\u{2019}s New"
    static func title(version: String) -> String { "What\u{2019}s new in Variorum \(version)" }
    static let closeDoor = "Continue"
    /// A build without notes for its version (a walk build; a release refuses).
    static func noNotes(version: String) -> String {
        "Variorum is now version \(version). This build doesn\u{2019}t carry notes for it."
    }
}
