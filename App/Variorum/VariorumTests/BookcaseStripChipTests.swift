//
//  BookcaseStripChipTests.swift
//  VariorumTests
//
//  **librarywalkpolish VR-119 — THE STRIP'S DELINEATION, her OPTION 2**
//  (R-LWP-2, her words): "it is very subtle and square - not ugly standard
//  web ui pills, some restrained, tasteful, light wash squares... I like the
//  subtle tone indicator too." The committed reference is
//  `notes/plans/librarywalkpolish-ui-reference.html`, Part 2 / OPTION 2:
//  every shelf name on a quiet near-square light-wash chip, the solo'd one
//  FILLED with the subtle accent tone.
//
//  The face is her eye's (captures, both voices); this pin holds the one
//  rule the strip's words read (`BookcaseStrip.chipFill` — the masthead's
//  `QuietFill` language, shared with the popovers' selected row) and that
//  every word wears it. Red-on-old, stated: the source pin was committed
//  AHEAD of the fix and ran red on that tree (the names were bare words —
//  no chip, the active one marked by ink and weight alone).
//

import Foundation
import Testing
@testable import Variorum

@MainActor
@Suite("librarywalkpolish VR-119 — the strip's names on light-wash squares, the solo'd one filled")
struct BookcaseStripChipTests {
    private static var appRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
    }

    /// Every strip word (All · starred · each shelf · + shelf) is drawn on
    /// the chip, from the one fill rule — never a literal.
    @Test func everyStripWordSitsOnTheChip() throws {
        let strip = try String(
            contentsOf: Self.appRoot.appending(path: "Variorum/Features/Shelf/BookcaseStrip.swift"),
            encoding: .utf8)
        #expect(strip.contains("Self.chipFill(active: active, tokens: tokens)"),
                "the words read the one chip rule")
        #expect(strip.contains("Self.chipFill(active: false, tokens: tokens)"),
                "+ shelf sits on a resting chip too")
    }
}
