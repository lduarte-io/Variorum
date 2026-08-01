//
//  MarkdownLink.swift
//  Variorum
//
//  Phase 13g, batch 4 (L10) — WHAT A LINK IN THE TEXT MAY DO, in one place.
//
//  Three surfaces open links and they must agree: the editing surfaces on
//  ⌘-click (a plain click there places the caret — F-5's letter), Read's
//  paged leaf on a plain click, and Read's flow through SwiftUI's own link
//  handling. One rule, one guard, one door.
//
//  **The rule, v1: `http` and `https` only** (a build-time call —
//  QUESTIONS #50). A markdown link's target is ordinary text she typed, and
//  the app must not hand an arbitrary scheme to `NSWorkspace` on a click:
//  `file:` reaches the disk, and the custom-scheme space is every other app
//  on the machine. Anything else is INERT — it still renders as a link (the
//  syntax is what it is), and clicking it simply does nothing rather than
//  doing something surprising. Widening this is one line.
//

import AppKit
import Foundation

enum MarkdownLink {
    /// The schemes a click may follow. Deliberately a set rather than a
    /// predicate: what it permits should be readable at a glance.
    static let openableSchemes: Set<String> = ["http", "https"]

    /// The URL a click may follow, or nil when the text is not an address
    /// this app will open. Whitespace is trimmed (a link's target commonly
    /// arrives with a stray space from a paste); the scheme decides the rest.
    static func openable(_ raw: String) -> URL? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let url = URL(string: trimmed),
              let scheme = url.scheme?.lowercased(),
              openableSchemes.contains(scheme),
              url.host?.isEmpty == false
        else { return nil }
        return url
    }

    /// Open it, and say whether anything happened — the caller consumes the
    /// click only when it did, so a click on an inert link still behaves like
    /// the ordinary click it visually is.
    @discardableResult
    @MainActor
    static func open(_ raw: String) -> Bool {
        guard let url = openable(raw) else { return false }
        return NSWorkspace.shared.open(url)
    }
}
