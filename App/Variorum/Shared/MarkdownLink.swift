//
//  MarkdownLink.swift
//  Variorum — App/Variorum/Shared (BOTH platforms)
//
//  **WHAT A LINK IN THE TEXT MAY DO, in one place** (Phase 13g, batch 4 —
//  L10). HOISTED here at 13u1 UNIT 1 (the 2026-08-30 tech-debt sweep's
//  **P41**) from the Mac's `Features/Formatting/MarkdownLink.swift`.
//
//  **Why the hoist, and why THIS file's own header demanded it.** It read
//  *"Three surfaces open links and they must agree… One rule, one guard, one
//  door"* — and there were FOUR surfaces and TWO rules, because
//  `MobileReadPage` carried a statement-for-statement copy of the scheme set
//  and the guard. Widening the rule (QUESTIONS #50 calls it *"one line"*)
//  would have moved the Mac's three surfaces and left the phone rendering
//  the SAME stored note's link as inert text, with nothing failing.
//
//  The guard half is pure Foundation; only OPENING needs a platform, so the
//  Mac's `open(_:)` stays beside `NSWorkspace` as a one-function extension
//  and the phone (whose SwiftUI `.link` attribute is opened by the
//  environment's own `OpenURLAction`) needs no opener at all.
//
//  **The rule, v1: `http` and `https` only** (a build-time call —
//  QUESTIONS #50). A markdown link's target is ordinary text she typed, and
//  the app must not hand an arbitrary scheme to the system on a click:
//  `file:` reaches the disk, and the custom-scheme space is every other app
//  on the machine. Anything else is INERT — it still renders as a link (the
//  syntax is what it is), and clicking it simply does nothing rather than
//  doing something surprising. Widening this is one line, and now it is one
//  line for BOTH platforms.
//

import Foundation

nonisolated enum MarkdownLink {
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
}
