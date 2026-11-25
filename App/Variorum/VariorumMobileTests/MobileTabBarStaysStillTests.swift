//
//  MobileTabBarStaysStillTests.swift
//  VariorumMobileTests
//
//  VM-253 (the VM-260 run, batch 1a) — **THE BOTTOM BAR STAYS STILL WHILE THE
//  PAGES MOVE; ONLY THE CHIP CHANGES.** Her words (2026-11-22, her first look
//  at the wave-1 build): "the bottom bar is moving when i swipe between
//  screens, which should never happen (the bar should stay still and just the
//  highlighted pill should change)."
//
//  THE MECHANISM (traced, `MobileShellView.body` on the pre-fix tree): the bar
//  was not the shell's. Each of the three roots drew its OWN copy at the foot
//  of its VStack (`tabBar()` in `MobileStarredView`, `MobileShelfView`,
//  `MobileLibraryView`), and each root sits inside `page(_:width:)`, whose
//  `.offset(x:)` moves the WHOLE page by the band's live drag (and by the
//  settle's animation of `tab`). So a swipe slid the Bookcase's bar out with
//  the Bookcase and the Library's copy in with the Library — two half-bars
//  meeting at the seam. (A pushed list wore a fourth copy inside its stack.)
//
//  THE PINS (red on the pre-fix tree, `MobileShellView.swift` and the three
//  roots before the fix commit; the held-drag seam they need was committed
//  with them):
//  · the bar is drawn ONCE in the whole walk — on a root, and on a pushed list
//    (old: three copies at rest — one per root, the walker descends every
//    page — and four with the Trash pushed);
//  · MID-SWIPE (the band held 160 pt toward the Library) each door is on the
//    window exactly once and exactly where it was at rest, the chip still on
//    the Bookcase — while the Library's own content has come into view, so
//    the band really moved (old: the Bookcase's bar 160 pt left, its
//    "Bookcase" door and the Library page's both on the window);
//  · a page change by the bar moves only the chip — the doors' frames before
//    and after are the same (a guard: at rest both trees agree; the motion
//    lived mid-flight, which the second pin holds).
//

import Foundation
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("VM-253 — the bar stays still; only the chip changes", .serialized)
struct MobileTabBarStaysStillTests {
    /// The harness's window (`HostedSurface`'s default).
    static let width: CGFloat = 393
    /// A swipe in flight: the Library pulled 160 pt in from the right (past
    /// neither landing distance — the band would snap back on release).
    static let midSwipe: CGFloat = -160

    /// Every copy of one bar door anywhere in the walk (the walker descends all
    /// three pages, a screen away or not).
    private func doors<V: View>(_ surface: HostedSurface<V>, _ word: String) -> [NSObject] {
        surface.visibleElements.filter {
            $0.accessibilityLabel == word && $0.accessibilityTraits.contains(.button)
        }
    }

    /// The copies of one door that are ON the window.
    private func onWindow<V: View>(_ surface: HostedSurface<V>, _ word: String) -> [NSObject] {
        let window = surface.window.bounds.insetBy(dx: 1, dy: 1)
        return doors(surface, word).filter { window.intersects($0.accessibilityFrame) }
    }

    /// Each bar door's on-window frame, by word (the pin fails if a word is on
    /// the window other than exactly once).
    private func barFrames<V: View>(
        _ surface: HostedSurface<V>, sourceLocation: SourceLocation = #_sourceLocation
    ) -> [String: CGRect] {
        var frames: [String: CGRect] = [:]
        for page in MobileShellBand.pages {
            let word = MobileTabBar.word(page)
            let shown = onWindow(surface, word)
            #expect(shown.count == 1,
                    "\(word) is on the window \(shown.count) times: \(shown.map(\.accessibilityFrame))",
                    sourceLocation: sourceLocation)
            if let frame = shown.first?.accessibilityFrame { frames[word] = frame }
        }
        return frames
    }

    private func same(_ a: [String: CGRect], _ b: [String: CGRect]) -> Bool {
        guard a.keys.sorted() == b.keys.sorted() else { return false }
        return a.allSatisfy { word, frame in
            guard let other = b[word] else { return false }
            return abs(frame.minX - other.minX) <= 0.5 && abs(frame.minY - other.minY) <= 0.5
                && abs(frame.width - other.width) <= 0.5 && abs(frame.height - other.height) <= 0.5
        }
    }

    /// **RED ON OLD — the bar is drawn once, by the shell.** At rest the walk
    /// holds ONE copy of each door (old: three, one per root); with a list
    /// pushed (the Library's Trash) still one, at the same place (old: four).
    @Test func theBarIsDrawnOnceByTheShell() async throws {
        try await withEditorWorld { session, _ in
            let router = MobileShellRouter()
            try await withHostedSurface(
                MobileShellView(session: session, services: nil, router: router)
            ) { surface in
                await surface.settle(30)
                for page in MobileShellBand.pages {
                    let word = MobileTabBar.word(page)
                    #expect(doors(surface, word).count == 1,
                            "\(word): \(doors(surface, word).count) copies in the walk — the bar is drawn once")
                }
                let atRoot = barFrames(surface)
                for frame in atRoot.values {
                    #expect(frame.minY >= surface.window.bounds.height * 0.75, "the bar sits at the foot: \(frame)")
                }

                // A pushed list: the Library's Trash.
                #expect(onWindow(surface, "Library").first?.accessibilityActivate() == true,
                        "labels: \(surface.visibleLabels)")
                await surface.settle(40)
                let trash = try #require(
                    surface.visibleElements.first {
                        $0.accessibilityLabel == MobileRecoveryDoors.trashLabel
                            && $0.accessibilityTraits.contains(.button)
                            && surface.window.bounds.intersects($0.accessibilityFrame)
                    }, "the Library's trash door: \(surface.visibleLabels)")
                #expect(trash.accessibilityActivate())
                await surface.settle(40)
                #expect(surface.visibleLabels.contains(MobileTrashView.emptyTrashLine),
                        "the Trash arrived: \(surface.visibleLabels)")
                for page in MobileShellBand.pages {
                    let word = MobileTabBar.word(page)
                    #expect(doors(surface, word).count == 1,
                            "\(word) on a pushed list: \(doors(surface, word).count) copies — still the one bar")
                }
                #expect(same(barFrames(surface), atRoot), "the bar on the list stands where it stood on the root")
                #expect(onWindow(surface, "Library").first?.accessibilityTraits.contains(.selected) == true)
            }
        }
    }

    /// **RED ON OLD — mid-swipe the bar has not moved.** The band held 160 pt
    /// toward the Library: the Library's own filter row has come onto the
    /// window (the band moved), and each bar door is on the window exactly once,
    /// exactly where it was at rest, the chip still on the Bookcase (a swipe
    /// changes the chip only when it lands).
    @Test func midSwipeTheBarHasNotMoved() async throws {
        try await withEditorWorld { session, _ in
            let atRest: [String: CGRect] = await withHostedSurface(
                MobileShellView(session: session, services: nil, router: MobileShellRouter())
            ) { surface in
                await surface.settle(30)
                return barFrames(surface)
            }
            #expect(atRest.count == MobileShellBand.pages.count)

            await withHostedSurface(
                MobileShellView(
                    session: session, services: nil, router: MobileShellRouter(),
                    heldDrag: Self.midSwipe)
            ) { surface in
                await surface.settle(30)
                // The band moved: the Library root's "All" door is on the window,
                // about 160 pt in from the right edge.
                let all = surface.visibleElements.filter {
                    $0.accessibilityLabel == MobileListingFilter.all.word
                        && surface.window.bounds.intersects($0.accessibilityFrame)
                }
                #expect(!all.isEmpty, "the Library came into view mid-swipe — labels \(surface.visibleLabels)")
                #expect(all.allSatisfy { $0.accessibilityFrame.minX >= Self.width + Self.midSwipe - 1 },
                        "…from the right: \(all.map(\.accessibilityFrame))")

                let midFlight = barFrames(surface)
                #expect(same(midFlight, atRest),
                        "mid-swipe the bar is where it was at rest — \(midFlight) vs \(atRest)")
                #expect(onWindow(surface, "Bookcase").first?.accessibilityTraits.contains(.selected) == true,
                        "the chip stays on the Bookcase until the swipe lands")
            }
        }
    }

    /// **A page change moves only the chip** (a guard — at rest both trees
    /// agree; the motion lived mid-flight). Bookcase → Library → Starred by the
    /// bar: the doors' frames never change; the chip follows the page.
    @Test func aPageChangeMovesOnlyTheChip() async throws {
        try await withEditorWorld { session, _ in
            await withHostedSurface(
                MobileShellView(session: session, services: nil, router: MobileShellRouter())
            ) { surface in
                await surface.settle(30)
                let home = barFrames(surface)
                for page in [MobileTab.library, .starred, .shelf] {
                    let word = MobileTabBar.word(page)
                    #expect(onWindow(surface, word).first?.accessibilityActivate() == true,
                            "\(word): labels \(surface.visibleLabels)")
                    await surface.settle(40)
                    #expect(same(barFrames(surface), home), "after \(word) the bar has not moved")
                    for other in MobileShellBand.pages {
                        let otherWord = MobileTabBar.word(other)
                        #expect(onWindow(surface, otherWord).first?.accessibilityTraits.contains(.selected)
                                    == (other == page),
                                "after \(word), \(otherWord)'s chip")
                    }
                }
            }
        }
    }
}
