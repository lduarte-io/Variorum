//
//  BookcaseMastheadPopoverTests.swift
//  VariorumTests
//
//  **librarywalkpolish VR-115 (R-LWP-1, AMENDED at her screenshots) + VR-118
//  (R-LWP-4) — the Bookcase's two droppers become ONE masthead-popover
//  idiom, and "my order" steps back for 0.9.2.**
//
//  Her words: the NATIVE order menu "looks out of place in the app"; the №
//  float's "font and sizing and such is better, but solo is fairly
//  meaningless - highlighting the selected row would be better... like
//  making the order menu look a bit more in tune with the rest of the app?"
//  And: "let's just hide 'my order' from the user, hide the send to top and
//  bottom options, and add it next week or something as a post release
//  update".
//
//  THE RULED SHAPE: № and order ▾ open the SAME popover (the float's own
//  type, a hairline + a menu-grade shadow, width to its content, seated
//  under its control); the selected row wears a quiet wash — no checkmark,
//  no "solo"/"clear" column, the row is the act; the order popover offers
//  a–z · last edited; opening either closes the other. "My order" is
//  hidden WHOLE (its rows, its grips, its row drops, Send to Top/Bottom) —
//  the machinery (`shelf_position`, `placeReading`) untouched for its
//  return (VR-120), and a stored my-order preference READS as a–z while
//  hidden, never rewritten (PROVISIONAL, #188).
//
//  Red-on-old, stated: the first two pins were committed AHEAD of the fix
//  and ran red on that tree — a stored "my order" placed by hand (the grips,
//  the row drops and Send to Top/Bottom all read `placesByHand`), and the
//  utility run drew the native `Menu` and the census's "solo"/"clear"
//  column. The idiom's own pins land with the fix.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("librarywalkpolish VR-115/VR-118 — one masthead popover for № and order ▾; my order steps back", .serialized)
struct BookcaseMastheadPopoverTests {
    private static var appRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
    }

    private static func source(_ relative: String) throws -> String {
        try String(contentsOf: appRoot.appending(path: relative), encoding: .utf8)
    }

    private func defaults() throws -> UserDefaults {
        let suite = "bookcase-masthead-popover-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    private func withSession<T>(_ body: @MainActor (AppSession) async throws -> T) async throws -> T {
        let db = try AppDatabase.inMemory()
        return try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            try await body(AppSession(database: db))
        }
    }

    /// VR-118: a stored "my order" no longer places by hand — no grip, no row
    /// drop, no Send to Top/Bottom (all three read this one value) — and the
    /// stored preference is LEFT where she put it.
    @Test func aStoredMyOrderNoLongerPlacesByHand() async throws {
        try await withSession { session in
            let defaults = try defaults()
            BookcasePrefs(defaults: defaults, wingID: "").orderMode = .mine
            let model = ShelfViewModel(session: session, defaults: defaults)
            #expect(!model.placesByHand, "my order steps back whole for 0.9.2 — nothing places by hand")
            #expect(BookcasePrefs(defaults: defaults, wingID: "").orderMode == .mine,
                    "the stored preference is never rewritten — the return finds it where she left it")
        }
    }

    /// VR-115: the utility run draws no native order menu, and the census
    /// draws no "solo"/"clear" column — the selected row is washed instead.
    @Test func theDroppersAreTheAppsOwnPopovers() throws {
        let strip = try Self.source("Variorum/Features/Shelf/BookcaseStrip.swift")
        #expect(!strip.contains("VoicedMenu("), "order ▾ is no longer the native menu")
        #expect(!strip.contains("active ? \"clear\" : \"solo\""), "no solo/clear column")
    }
}
