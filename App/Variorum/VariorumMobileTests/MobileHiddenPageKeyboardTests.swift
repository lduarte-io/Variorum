//
//  MobileHiddenPageKeyboardTests.swift
//  VariorumMobileTests
//
//  VM-47 (the run's one walk, part B set 2 — finding W-C2; the walk's fixes,
//  batch 2) — **A PAGE SHE IS NOT ON NEVER HOLDS THE KEYBOARD.** The walk's
//  road: the Library searched (its field focused), a hit opened, Versions
//  pushed, then "Bookcase" in the bar — and a keyboard rose over the Bookcase
//  root with nothing there focused, the bar lifted to mid-screen; back on the
//  Library its search held the caret.
//
//  THE MECHANISM (traced in the shell and the Library): the search field is a
//  plain `TextField` with no focus binding of its own. A push over the Library
//  root covers the field and the keyboard goes; the tab road (P-47-19,
//  `MobileShellView.tabSelected`) pops the leaving stack back to its root
//  unanimated while the page slides away, and the framework restores the
//  first responder of the screen it uncovers — the search field — so the
//  hidden page takes the keyboard back. (A plain Back to the Library restores
//  it the same way, on screen, which is a road she sees and is kept.)
//
//  THE FIX: the shell tells each page whether it is the band's current one
//  (`mobilePageShowing`), and the Library's search gives the keyboard back
//  whenever it holds it while its page is hidden (and on leaving the screen).
//
//  THE PIN drives the road on the mounted shell in a real scene window: the
//  Library's search focused, the Trash pushed over it (a list with the bar —
//  the same covering push as the walk's hit), "Bookcase" in that list's bar;
//  then nothing in the window is first responder and the Bookcase's bar sits
//  at its foot. Red on old: the search field is first responder again.
//

import Foundation
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("VM-47 W-C2 — a hidden page never holds the keyboard (mounted shell)", .serialized)
struct MobileHiddenPageKeyboardTests {
    /// Every view in a window's tree.
    private func views(in view: UIView) -> [UIView] {
        [view] + view.subviews.flatMap { views(in: $0) }
    }

    /// The Library's search field (its placeholder names it).
    private func searchField(in window: UIWindow) -> UITextField? {
        views(in: window).compactMap { $0 as? UITextField }.first { field in
            let words = field.attributedPlaceholder?.string ?? field.placeholder ?? ""
            return words.range(of: "search notes", options: .caseInsensitive) != nil
        }
    }

    @Test func theTabRoadLeavesNoKeyboardOnAHiddenPage() async throws {
        try await withEditorWorld { session, _ in
            let router = MobileShellRouter()
            try await withSceneSurface(
                MobileShellView(session: session, services: nil, router: router), dark: false
            ) { surface in
                await surface.settle(50)
                let library = try #require(surface.onScreen("Library"), "the bar's Library door: \(surface.labels)")
                #expect(library.accessibilityActivate())
                await surface.settle(40)

                let field = try #require(searchField(in: surface.window), "the Library's search field")
                #expect(field.becomeFirstResponder(), "the search takes the keyboard")
                await surface.settle(10)
                try #require(field.isFirstResponder, "the search holds the keyboard before the road")

                let trash = try #require(surface.onScreen(MobileRecoveryDoors.trashLabel),
                                         "the Library's Trash door: \(surface.labels)")
                #expect(trash.accessibilityActivate())
                await surface.settle(50)
                print("PERF[sim] VM-47 W-C2 — after the push, the search holds the keyboard: \(field.isFirstResponder)")

                let bookcase = try #require(surface.onScreen("Bookcase"),
                                            "the pushed list's bar: \(surface.labels)")
                #expect(bookcase.accessibilityActivate())
                await surface.settle(80)

                let holders = views(in: surface.window).filter(\.isFirstResponder)
                #expect(holders.isEmpty,
                        "a page she is not on holds the keyboard: \(holders.map { String(describing: type(of: $0)) }) (the search field: \(field.isFirstResponder))")
                let bar = try #require(surface.onScreen("Bookcase"), "the Bookcase root's bar: \(surface.labels)")
                let foot = surface.window.bounds.height - surface.window.safeAreaInsets.bottom
                #expect(bar.accessibilityFrame.maxY >= foot - 2,
                        "the bar sits at its foot (\(bar.accessibilityFrame.maxY) against \(foot)), not over a keyboard")
            }
        }
    }
}
