//
//  CaptureTagPicks.swift
//  Variorum — SHARED (both platforms)
//
//  **VX-1078 (the VX-1036 run, batch 4) — tags on a quick note.** Her words at
//  sitting 2: *"ability to add tags from the quick note creation"* (R-1036-15);
//  at sitting 3: *"there should be a tag adding button where it suggests the
//  title so you can add things from there and file it if you'd like, and on the
//  quick note capture that lives on the macos menu bar too"* (R-1036-37).
//
//  The tags picked on a capture door BEFORE the note exists. They are PATHS
//  until the filing — nothing is written while she picks (the title chip's
//  class: a decision about the capture, acted on at the hand-off) — and at the
//  filing they ride the very road the typed `{#tag/path}` tokens take
//  (`CaptureMicrosyntax.applyTags` → `TypedTagPath.apply`): adopt-or-mint BY
//  PATH in the NOTE's wing — the landing wing, so a pad redirected to another
//  wing adopts or mints there (R-13ia-1's class) — through the one application
//  road, so a living book hears the birth (seat or bell). The microsyntax
//  itself is untouched: its tokens are parsed exactly as before and apply
//  FIRST, in their own order; a pick applies after them, and only when no
//  token already named the same path.
//
//  Pure, and here rather than in a Mac file, so the phone's capture door (a
//  later parity row) consumes the same rule — the forked-brains rule applied
//  before the fork can happen (`CaptureMicrosyntax`'s own reason).
//

import Foundation
import VariorumCore

nonisolated struct CaptureTagPicks: Equatable, Sendable {
    /// The picked paths, in the order she picked them, each read by the
    /// typed-path rule (`TagPath.segments` — "/a//b/" is "a/b").
    private(set) var paths: [String] = []

    init() {}

    /// A park's restore (the pad's refused capture) — the paths re-read by
    /// the same rule, so a restored set is exactly a picked one.
    init(paths: [String]) {
        for path in paths { add(path) }
    }

    var isEmpty: Bool { paths.isEmpty }

    /// The typed-path rule's reading of a path ("" when it names nothing).
    static func normalized(_ raw: String) -> String {
        TagPath.segments(raw).joined(separator: "/")
    }

    /// Pick a path (typed, or a suggestion's). Nothing — a blank, or all
    /// slashes — and a path already picked change nothing. Returns whether
    /// the set changed.
    @discardableResult
    mutating func add(_ raw: String) -> Bool {
        let path = Self.normalized(raw)
        guard !path.isEmpty, !paths.contains(path) else { return false }
        paths.append(path)
        return true
    }

    /// Take a pick off (its pill's ×).
    mutating func remove(_ path: String) {
        let normalized = Self.normalized(path)
        paths.removeAll { $0 == normalized }
    }

    mutating func clear() { paths = [] }

    /// **The paths the filing applies, in order**: the capture's own
    /// `{#…}` tokens first, exactly as parsed and in their order (the
    /// microsyntax outranks nothing it didn't before, and nothing outranks
    /// it), then each pick no token already named (compared by the
    /// typed-path rule, so `{#garden/}` and a picked `garden` are one tag).
    static func filing(tokens: [String], picks: [String]) -> [String] {
        let named = Set(tokens.map(normalized))
        var seen = Set<String>()
        let extra = picks.filter { pick in
            let path = normalized(pick)
            guard !path.isEmpty, !named.contains(path), !seen.contains(path) else { return false }
            seen.insert(path)
            return true
        }
        return tokens + extra
    }
}

extension CaptureMicrosyntax.Capture {
    /// This capture, also wearing the picked tags — the tokens untouched and
    /// first (`CaptureTagPicks.filing`); the text and the title unchanged.
    nonisolated func wearing(_ picks: CaptureTagPicks) -> Self {
        var capture = self
        capture.tagPaths = CaptureTagPicks.filing(tokens: tagPaths, picks: picks.paths)
        return capture
    }
}
