//
//  MobileScreenEdgeGroundsTests.swift
//  VariorumMobileTests
//
//  VM-47 (the run's one walk, finding W-A1) — **EVERY SCREEN'S GROUND RUNS TO
//  THE SCREEN'S EDGES.** The walk read it off the captures: on every root the
//  0–62 pt strip above the path line and the 840–874 pt strip under the bar
//  were the bare window (#FFFFFF in light — neither the room nor Terminal's
//  paper), and in a note in dark black bands sat above and below the hued
//  paper with the last prose line cut at 840. The sheet's frames are the room
//  edge to edge, and §E's tab bar is "Bar 49 + the 34 pt home-indicator inset,
//  both painted in the room" (P-47-21).
//
//  THE MECHANISM (traced in `MobileShellView.body`): the band is a
//  `GeometryReader` whose frame is the safe area, and its pages sat under a
//  `.clipped()` at that frame — so every page's own `ignoresSafeArea()` ground
//  (the roots' room, the bar's room "down past the home indicator", the
//  note's paper) was cut at the safe area, and what showed beyond it was the
//  window's own background. The fix bounds the clip SIDEWAYS only
//  (`MobileBandClip`), so the neighbours one width away stay hidden.
//
//  THE PINS render the real shell in a real window of the test host's scene —
//  the device's own safe-area insets — whose host carries a sentinel colour,
//  and read the pixels in the status bar's strip and the home indicator's.
//  RED ON OLD: the clip left the sentinel there, on a root and in a note, in
//  light and in dark (a black room cannot pass for the window here). Each pin
//  first reads a pixel INSIDE the safe area that both trees draw the same, so
//  a render that captured nothing, or a token resolved wrongly, fails as
//  itself and never as the defect. A third pin holds the half the fix KEEPS:
//  in a host with side insets, nothing is drawn past the band's own width.
//

import Foundation
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("The grounds reach the screen's edges (VM-47, the walk's W-A1)", .serialized)
struct MobileScreenEdgeGroundsTests {
    /// How close a pixel must be to the token it should show (a channel's
    /// difference; the sentinel is ≥ 0.5 from every ground the app ships).
    static let tolerance = 0.05

    /// The strips the pins read: the middle of the status bar's inset and of
    /// the home indicator's, at the left edge, the middle and the right edge.
    private func edgePoints(_ surface: SceneHostedSurface<some View>) throws
        -> (top: [CGPoint], bottom: [CGPoint])
    {
        let insets = surface.host.view.safeAreaInsets
        let bounds = surface.window.bounds
        try #require(insets.top >= 8 && insets.bottom >= 8,
                     "the device has unsafe edges to read (insets \(insets)) — on one without, the pin cannot see W-A1")
        let xs = [CGFloat(2), bounds.midX, bounds.maxX - 2]
        return (xs.map { CGPoint(x: $0, y: insets.top / 2) },
                xs.map { CGPoint(x: $0, y: bounds.maxY - insets.bottom / 2) })
    }

    /// **On a root, the room runs up under the status bar and the bar's room
    /// down to the screen's bottom edge** — the Bookcase, the shell's home.
    @Test(arguments: [false, true])
    func onARootTheRoomRunsToBothEdges(dark: Bool) async throws {
        try await withEditorWorld { session, _ in
            let router = MobileShellRouter()
            try await withSceneSurface(
                MobileShellView(session: session, services: nil, router: router), dark: dark
            ) { surface in
                await surface.settle(40)
                #expect(surface.onScreen("New Book") != nil,
                        "the Bookcase is on screen: \(surface.labels)")
                let room = PixelColor(UIColor(router.tokens(dark: dark).room), traits: surface.traits)
                let pixels = try surface.render()
                let insets = surface.host.view.safeAreaInsets
                // Inside the safe area, both trees draw the room here (the
                // path line's top air, in the gutter): the render is real and
                // the token is the right one.
                let inside = pixels.color(at: CGPoint(x: 2, y: insets.top + 2))
                try #require(inside.distance(to: room) <= Self.tolerance,
                             "inside the safe area the path line's room reads \(inside), the room is \(room)")
                let edges = try edgePoints(surface)
                for point in edges.top {
                    let seen = pixels.color(at: point)
                    #expect(seen.distance(to: room) <= Self.tolerance,
                            "dark \(dark): under the status bar at \(point) the screen shows \(seen), not the room \(room)")
                }
                for point in edges.bottom {
                    let seen = pixels.color(at: point)
                    #expect(seen.distance(to: room) <= Self.tolerance,
                            "dark \(dark): under the bar at \(point) the screen shows \(seen), not the bar's room \(room)")
                }
            }
        }
    }

    /// **In a note, the paper runs to both edges** — up under the status bar
    /// (the masthead's side) and down past the home indicator (the foot), so
    /// no band of the window sits around her page. The note is the Bookcase's
    /// Today entry, opened in Write by its own door.
    @Test(arguments: [false, true])
    func inANoteThePaperRunsToBothEdges(dark: Bool) async throws {
        try await withEditorWorld { session, _ in
            let router = MobileShellRouter()
            try await withSceneSurface(
                MobileShellView(session: session, services: nil, router: router), dark: dark
            ) { surface in
                await surface.settle(50)
                let door = try #require(surface.onScreen(MobileShelfFaces.todayDoorSpoken),
                                        "the Today door: \(surface.labels)")
                #expect(door.accessibilityActivate())
                #expect(await eventually { !router.editors.registeredPostIDs.isEmpty },
                        "a note opened in Write")
                await surface.settle(60)
                let paper = PixelColor(UIColor(router.tokens(dark: dark).surface), traits: surface.traits)
                let pixels = try surface.render()
                let bounds = surface.window.bounds
                // Inside the safe area, both trees draw the paper here (the
                // editor's left margin, half-way down): the render is real.
                let inside = pixels.color(at: CGPoint(x: 2, y: bounds.midY))
                try #require(inside.distance(to: paper) <= Self.tolerance,
                             "inside the safe area the note's margin reads \(inside), the paper is \(paper)")
                let edges = try edgePoints(surface)
                for point in edges.top + edges.bottom {
                    let seen = pixels.color(at: point)
                    #expect(seen.distance(to: paper) <= Self.tolerance,
                            "dark \(dark): at the screen's edge \(point) the note shows \(seen), not its paper \(paper)")
                }
            }
        }
    }

    /// **The half the fix keeps: nothing is drawn past the band's own width.**
    /// A host with side insets narrows the band; each page's ground ignores
    /// the safe area on every side, so without the sideways clip the current
    /// page's room — and a neighbour's, one width away — would fill the side
    /// strips. They stay the host's own colour. (A guard: green before the fix
    /// as after it; red for a fix that dropped the clip instead of freeing its
    /// top and bottom.)
    @Test func theBandStillDrawsNothingPastItsOwnWidth() async throws {
        try await withEditorWorld { session, _ in
            let router = MobileShellRouter()
            try await withSceneSurface(
                MobileShellView(session: session, services: nil, router: router), dark: false,
                additionalInsets: UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
            ) { surface in
                await surface.settle(40)
                let room = PixelColor(UIColor(router.tokens(dark: false).room), traits: surface.traits)
                let sentinel = PixelColor(SceneHostedSurface<AnyView>.sentinel, traits: surface.traits)
                let pixels = try surface.render()
                let bounds = surface.window.bounds
                let insets = surface.host.view.safeAreaInsets
                try #require(insets.left >= 20 && insets.right >= 20, "the side insets took: \(insets)")
                let inside = pixels.color(at: CGPoint(x: insets.left + 2, y: insets.top + 2))
                try #require(inside.distance(to: room) <= Self.tolerance,
                             "inside the band the path line's room reads \(inside), the room is \(room)")
                for point in [CGPoint(x: insets.left / 2, y: bounds.midY),
                              CGPoint(x: bounds.maxX - insets.right / 2, y: bounds.midY)] {
                    let seen = pixels.color(at: point)
                    #expect(seen.distance(to: sentinel) <= Self.tolerance,
                            "beside the band at \(point) something was drawn (\(seen)) — the sideways clip is gone")
                }
            }
        }
    }
}
