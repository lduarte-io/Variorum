//
//  BookcaseCensusMenuTests.swift
//  VariorumTests
//
//  **17y B-WALK W-3 — THE № CENSUS FLOAT NEVER COVERS AN OPEN MASTHEAD MENU
//  (her ruling, the walk of 2026-10-05).** Her finding, verbatim: the census
//  float covers the order ▾ menu when clicked second — "unexcusable UI. not
//  good at all". The float (17y (r), an in-window overlay hung over the
//  board's top-right) stood open while the masthead's own menus and popover
//  opened over the same corner, and nothing in the Bookcase connected the
//  two: opening order ▾ (a SwiftUI `Menu` — no open callback), the wing
//  switcher ▾, the ⋯ shelf panel, or a shelf name's right-click menu left
//  `censusOpen` exactly as it was.
//
//  THE RULE (ruled): opening any masthead menu or popover DISMISSES the
//  float; № toggles cleanly beside them. One state door on the model
//  (`ShelfViewModel.mastheadDoorOpened`), reached from every masthead
//  menu/popover through ONE press report (`Core/Views/PressReporter`) — the
//  SwiftUI `Menu` says nothing when it opens, so the press that opens it is
//  what reports.
//
//  Red-on-old, stated: the source pin was committed AHEAD of the fix and ran
//  red on that tree (no masthead door reached the census). The model's rule
//  and the mounted wiring pins land with the fix.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("17y B-WALK W-3 — opening a masthead menu or popover dismisses the № float", .serialized)
struct BookcaseCensusMenuTests {
    private static var appRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
    }

    private static func source(_ relative: String) throws -> String {
        try String(contentsOf: appRoot.appending(path: relative), encoding: .utf8)
    }

    /// Every masthead menu/popover door reports its press to the one
    /// dismissal door: the order ▾ menu, the ⋯ shelf panel and the shelf
    /// names' right-click menus in the strip; the wing switcher ▾ in the
    /// masthead.
    @Test func everyMastheadMenuDoorReachesTheDismissal() throws {
        let strip = try Self.source("Variorum/Features/Shelf/BookcaseStrip.swift")
        let shelf = try Self.source("Variorum/Features/Shelf/ShelfView.swift")
        #expect(strip.contains(".reportsPress { model.mastheadDoorOpened() }"),
                "the order ▾ menu reports its press")
        #expect(strip.contains("panelShown.toggle()\n                    model.mastheadDoorOpened()")
                    || strip.contains("model.mastheadDoorOpened()\n                    panelShown"),
                "the ⋯ shelf panel's door dismisses the float")
        #expect(strip.contains(".reportsPress(secondaryOnly: true) { model.mastheadDoorOpened() }"),
                "the shelf names' right-click menus report their press")
        #expect(shelf.contains("WingSwitcherMenu(tokens: tokens, wings: wings)\n                    .reportsPress { model.mastheadDoorOpened() }"),
                "the wing switcher ▾ reports its press")
    }
}
