//
//  BookNameProbe.swift
//  Variorum (Mac)
//
//  VX-804 — WHICH NAME EACH FACE OF THE OPEN BOOK DRAWS, as a test oracle
//  (the `OwnershipBadgeProbe` / `BookPanelMarkProbe` pattern: recorded on
//  appear and on every change of the drawn words, DEBUG only — a no-op
//  modifier outside DEBUG). The beta tester's report, via her (2026-11-04):
//  "When I renamed it via Book Settings, I couldn't get the new name to appear
//  until I left that part of the app" — the navigator's masthead and the
//  Outline's page heading kept the old name. A pin that asserts what a FACE
//  draws reads this; the mechanism and the fix are the VX-878 record's
//  BATCH 2 RECORD (`notes/plans/fixes/vx-878-book-doors-faces.md`).
//

import SwiftUI

/// The two faces of the open book that say its name and that the tester's
/// screenshot shows: the navigator's masthead and the Outline's page heading.
nonisolated enum BookNameFace: String, Sendable {
    case masthead
    case outlineTitle
}

#if DEBUG
@MainActor
enum BookNameProbe {
    /// The name each face last drew, keyed `"‹readingID›|‹face›"`.
    static var drawn: [String: String] = [:]

    static func key(_ readingID: String, _ face: BookNameFace) -> String {
        "\(readingID)|\(face.rawValue)"
    }

    static func name(_ readingID: String, _ face: BookNameFace) -> String? {
        drawn[key(readingID, face)]
    }

    static func reset() { drawn = [:] }
}
#endif

extension View {
    /// Records the name `face` draws for `readingID` (a no-op outside DEBUG).
    @ViewBuilder
    func bookNameProbe(_ face: BookNameFace, readingID: String, name: String) -> some View {
        #if DEBUG
        onAppear { BookNameProbe.drawn[BookNameProbe.key(readingID, face)] = name }
            .onChange(of: name) { _, now in BookNameProbe.drawn[BookNameProbe.key(readingID, face)] = now }
        #else
        self
        #endif
    }
}
