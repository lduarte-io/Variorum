//
//  BookNavigatorFloorTests.swift
//  VariorumTests
//
//  **VX-1091 (the VX-1036 run, batch 3 — a rider) — the book navigator's floor
//  holds its mode row.** Filed from VX-1082's measured read: in Terminal the
//  four mode tabs measure 168 pt (stable width — the widest active state, each
//  word rounded up as a `Text` sizes itself) in a 166-pt room (the 190-pt floor
//  less the navigator's 12-pt padding each side), so the navigator laid out at
//  191 pt in its 190-pt column and `SideColumn` centred it half a point over
//  the sidebar's edge. The tabs never compress (VX-887/896), so the floor is
//  where the fix lives: the column's least width holds the tabs in the voice.
//
//  RED ON OLD (the pins-only tree, where the floor was the shipped 190 in
//  every voice): Terminal's 168 > 166. The fifth mode (List — R-1036-29) makes
//  both voices' rows wider still (205 Terminal, 179 Study), so after it both
//  arms stay red until the floor follows the tabs.
//

import AppKit
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

/// `@MainActor`: the stable widths' memo is the main actor's (the app's
/// default isolation), so the voice cases measure one at a time.
@MainActor
@Suite("VX-1091 — the book navigator's floor holds its mode row")
struct BookNavigatorFloorTests {
    /// The tab row's stable width in a voice, measured in the voice's own font.
    private static func tabs(_ voice: ThemeVoice) -> CGFloat {
        BookMastheadStableWidths.tabs(
            tokens: VoiceTokens.resolve(voice: voice, dark: false),
            in: EnvironmentValues().fontResolutionContext)
    }

    /// **The claim:** at the navigator's floor in a voice, the room inside its
    /// padding holds the mode row's tabs whole — so the navigator is never laid
    /// out wider than its column.
    @Test(arguments: [ThemeVoice.terminal, .study])
    func theModeRowFitsTheNavigatorAtItsFloor(voice: ThemeVoice) {
        let tabs = Self.tabs(voice)
        let floor = BookNavigatorLayout.minimumWidth(tabs: tabs)
        let room = floor - 2 * BookNavigatorLayout.contentInset
        #expect(tabs <= room, "\(voice): tabs \(tabs) pt in a \(room)-pt room (floor \(floor))")
        #expect(tabs > 0, "\(voice): non-vacuity — the tabs were measured")
    }

    /// **The floor never grows for nothing:** where the tabs fit the shipped
    /// floor, the floor IS the shipped width (nothing moves until it must).
    @Test func theFloorIsTheShippedWidthWhereTheTabsFit() {
        let shipped = BookNavigatorLayout.minimumWidth
        let inset = BookNavigatorLayout.contentInset
        #expect(BookNavigatorFloor.width(tabs: 100, shipped: shipped, inset: inset) == shipped)
        #expect(BookNavigatorFloor.width(tabs: shipped - 2 * inset, shipped: shipped, inset: inset) == shipped)
    }

    /// **…and where they do not, it rises exactly to their need**, at a whole
    /// point (the row decides at whole points — VX-348 U3's leg), never past it.
    @Test func theFloorRisesExactlyToTheTabsNeed() {
        let shipped = BookNavigatorLayout.minimumWidth
        let inset = BookNavigatorLayout.contentInset
        #expect(BookNavigatorFloor.width(tabs: 205, shipped: shipped, inset: inset) == 229)
        #expect(BookNavigatorFloor.width(tabs: 204.5, shipped: shipped, inset: inset) == 229)
        #expect(BookNavigatorFloor.width(tabs: 167, shipped: shipped, inset: inset) == 191)
    }
}
