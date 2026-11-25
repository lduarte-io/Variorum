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
//  window's own background.
//
//  THE FIX, REDONE. The first fix (`67525b499`) bounded the band's clip
//  sideways only, so each page's own ground ran on past the band — and so did
//  its CONTENT: a mid-note tap no longer rose above the keyboard (the walk's
//  W-E4), her prose showed through the keyboard bar's glass (W-E3), a scrolled
//  page's words ran up under the status bar (W-F1). Now the band keeps main's
//  `.clipped()` — nothing inside it draws past the safe area — and the SHELL
//  paints the strips beyond it, behind it, in the showing page's declared
//  edge grounds (`MobileEdgeGrounds.swift`).
//
//  THE PINS render the real shell in a real window of the test host's scene —
//  the device's own safe-area insets — whose host carries a sentinel colour,
//  and read the pixels in the status bar's strip and the home indicator's.
//  Two families:
//  · THE GROUNDS (a root, a note, a pushed list, the Read page) — the strips
//    wear the page's grounds. RED on main (the sentinel shows there; a black
//    room cannot pass for the window here).
//  · NO CONTENT BEYOND THE BAND (a scrolled Read page's top strip, the Read
//    page's foot at rest) — the strip holds ONE ground and no ink of her words.
//    RED on the first fix's tree (her words there); green on main (the bare
//    window is one ground too) and on the redo.
//  Each pin first reads a pixel INSIDE the safe area that every tree draws the
//  same, so a render that captured nothing, or a token resolved wrongly, fails
//  as itself and never as the defect; the no-content pins also first prove
//  there ARE words right inside the band's edge, so they can never pass on an
//  empty page. A guard holds the half both fixes keep: in a host with side
//  insets, nothing is drawn past the band's own width.
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
    private func edgePoints<V: View>(_ surface: SceneHostedSurface<V>) throws
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

    // MARK: - W-A1 redone: a pushed list, the Read page, and nothing of a page beyond the band

    /// How far a pixel of a strip may stray from the strip's own commonest
    /// colour and still be that ground (a flat fill reads exactly; a glyph of
    /// her words, even faded under the system's scroll edge, strays far more —
    /// the walk measured the faintest at 1.28:1 on black, ≈ 0.12 a channel).
    static let oneGroundTolerance = 0.03

    /// **A pushed list: its paper runs up under the status bar and the bar's
    /// room down past the home indicator** — the Trash, by the Library's own
    /// door (a list wears the bar, VM-52; MOVED at VM-255 from the Bookcase's,
    /// which her ruling retired). And back on the root by the current tab
    /// (P-47-19), the strips are the room again: no stale paper is left.
    /// GROUNDS — red on main (the sentinel), green on the first fix (the page's
    /// and the bar's own grounds ran on) and on the redo (the shell paints them).
    @Test(arguments: [false, true])
    func onAPushedListThePaperRunsUpAndTheBarsRoomDown(dark: Bool) async throws {
        try await withEditorWorld { session, _ in
            let router = MobileShellRouter()
            try await withSceneSurface(
                MobileShellView(session: session, services: nil, router: router), dark: dark
            ) { surface in
                await surface.settle(40)
                let library = try #require(lowestOnScreen(surface, "Library"), "the bar's Library door: \(surface.labels)")
                #expect(library.accessibilityActivate())
                await surface.settle(40)
                let door = try #require(surface.onScreen(MobileRecoveryDoors.trashLabel),
                                        "the Library's Trash door: \(surface.labels)")
                #expect(door.accessibilityActivate())
                await surface.settle(50)
                try #require(surface.onScreen(MobileTrashView.emptyTrashLine) != nil,
                             "the Trash arrived: \(surface.labels)")
                let tokens = router.tokens(dark: dark)
                let paper = PixelColor(UIColor(tokens.surface), traits: surface.traits)
                let room = PixelColor(UIColor(tokens.room), traits: surface.traits)
                let bounds = surface.window.bounds
                let insets = surface.host.view.safeAreaInsets
                let pixels = try surface.render()
                // Inside the band every tree draws these alike: the list's paper
                // in its gutter half-way down, the bar's room just above the
                // band's foot.
                let page = pixels.color(at: CGPoint(x: 2, y: bounds.midY))
                try #require(page.distance(to: paper) <= Self.tolerance,
                             "inside the band the Trash's paper reads \(page), the paper is \(paper)")
                let bar = pixels.color(at: CGPoint(x: 2, y: bounds.maxY - insets.bottom - 2))
                try #require(bar.distance(to: room) <= Self.tolerance,
                             "inside the band the bar's room reads \(bar), the room is \(room)")
                let edges = try edgePoints(surface)
                for point in edges.top {
                    let seen = pixels.color(at: point)
                    #expect(seen.distance(to: paper) <= Self.tolerance,
                            "dark \(dark): above the Trash at \(point) the screen shows \(seen), not its paper \(paper)")
                }
                for point in edges.bottom {
                    let seen = pixels.color(at: point)
                    #expect(seen.distance(to: room) <= Self.tolerance,
                            "dark \(dark): under the Trash's bar at \(point) the screen shows \(seen), not the bar's room \(room)")
                }
                // Back on the root by the bar's current tab: the strips follow it.
                let tab = try #require(lowestOnScreen(surface, "Library"),
                                       "the bar's Library door: \(surface.labels)")
                #expect(tab.accessibilityActivate())
                await surface.settle(60)
                try #require(surface.onScreen(MobileListingFilter.all.word) != nil
                                && surface.onScreen(MobileTrashView.emptyTrashLine) == nil,
                             "back on the Library's root: \(surface.labels)")
                let after = try surface.render()
                for point in edges.top + edges.bottom {
                    let seen = after.color(at: point)
                    #expect(seen.distance(to: room) <= Self.tolerance,
                            "dark \(dark): back on the Library at \(point) the screen shows \(seen), not the room \(room)")
                }
            }
        }
    }

    /// **A scrolled page's words never run up under the status bar** (the
    /// walk's W-F1). The long book's Read page, scrolled 400 pt in: her lines
    /// fill the page right below the navigation bar (proven first, so the pin
    /// cannot pass on an empty page), and the status bar's strip holds ONE
    /// ground and nothing of them. NO CONTENT BEYOND THE BAND — red on the first
    /// fix's tree (her faded lines there), green on main (the bare window, one
    /// ground) and on the redo (the painted room).
    @Test(arguments: [false, true])
    func aScrolledPagesWordsStayOutOfTheStatusBar(dark: Bool) async throws {
        try await withEditorWorld { session, _ in
            try await mintTheLongBook(session)
            let router = MobileShellRouter()
            try await withSceneSurface(
                MobileShellView(session: session, services: nil, router: router), dark: dark
            ) { surface in
                await surface.settle(40)
                try await openTheLongBooksReadPage(
                    surface, readWord: router.tokens(dark: dark).chromeLabel(MobileBookView.readDoorTitle))
                let scroll = try #require(tallestScrollOnScreen(surface), "the Read page's scroll view")
                let rest = scroll.contentOffset.y
                scroll.setContentOffset(CGPoint(x: scroll.contentOffset.x, y: rest + 400), animated: false)
                await surface.settle(30)
                try #require(scroll.contentOffset.y >= rest + 300,
                             "the Read page scrolled: \(rest) → \(scroll.contentOffset.y)")
                let pixels = try surface.render()
                let bounds = surface.window.bounds
                let insets = surface.host.view.safeAreaInsets
                try #require(insets.top >= 8, "the device has a status bar's strip to read (insets \(insets))")
                // The premise: her words right below the navigation bar.
                let below = CGRect(x: 30, y: insets.top + 50, width: bounds.width - 60, height: 70)
                let words = try #require(pixels.inkAndGround(in: below),
                                         "no words below the navigation bar at \(below) — the premise fails")
                try #require(words.ink.contrast(with: words.ground) >= 3,
                             "the words below the navigation bar read \(words.ink) on \(words.ground) — the premise fails")
                // The fact: the status bar's strip is one ground.
                let strip = CGRect(x: 0, y: 0, width: bounds.width, height: insets.top - 1)
                let seen = try #require(oneGround(pixels, in: strip), "the strip \(strip) has pixels")
                #expect(seen.distance <= Self.oneGroundTolerance, """
                    dark \(dark): on the scrolled Read page the status bar's strip holds \(seen.farthest) on its \
                    ground \(seen.ground) — her words run past the band's top (W-F1)
                    """)
            }
        }
    }

    /// **A page's words stop at the band's foot** — the Read page at rest: her
    /// lines run on to just above the band's foot (proven first), and the home
    /// indicator's strip holds ONE ground and nothing of them (the walk's F7 on
    /// the first fix: "app, not in you." drawn below 840). NO CONTENT BEYOND THE
    /// BAND — red on the first fix's tree, green on main and on the redo.
    @Test(arguments: [false, true])
    func aPagesWordsStopAtTheBandsFoot(dark: Bool) async throws {
        try await withEditorWorld { session, _ in
            try await mintTheLongBook(session)
            let router = MobileShellRouter()
            try await withSceneSurface(
                MobileShellView(session: session, services: nil, router: router), dark: dark
            ) { surface in
                await surface.settle(40)
                try await openTheLongBooksReadPage(
                    surface, readWord: router.tokens(dark: dark).chromeLabel(MobileBookView.readDoorTitle))
                let pixels = try surface.render()
                let bounds = surface.window.bounds
                let insets = surface.host.view.safeAreaInsets
                try #require(insets.bottom >= 8, "the device has a home indicator's strip to read (insets \(insets))")
                // The premise: her words right above the band's foot.
                let above = CGRect(x: 30, y: bounds.maxY - insets.bottom - 64, width: bounds.width - 60, height: 60)
                let words = try #require(pixels.inkAndGround(in: above),
                                         "no words above the band's foot at \(above) — the premise fails")
                try #require(words.ink.contrast(with: words.ground) >= 3,
                             "the words above the band's foot read \(words.ink) on \(words.ground) — the premise fails")
                // The fact: the home indicator's strip is one ground.
                let strip = CGRect(x: 0, y: bounds.maxY - insets.bottom + 1, width: bounds.width,
                                   height: insets.bottom - 2)
                let seen = try #require(oneGround(pixels, in: strip), "the strip \(strip) has pixels")
                #expect(seen.distance <= Self.oneGroundTolerance, """
                    dark \(dark): under the Read page the home indicator's strip holds \(seen.farthest) on its \
                    ground \(seen.ground) — her words run past the band's foot
                    """)
            }
        }
    }

    /// **The Read page's own room fills both strips** — what the page declares
    /// (the voice's own room, never the palette's — R-13u-10): under the status
    /// bar and past the home indicator, where the cream page now stops at the
    /// band's foot. GROUNDS — red on main (the sentinel), red on the first fix
    /// at the foot (the cream page and her lines ran on there), green on the redo.
    @Test(arguments: [false, true])
    func onTheReadPageItsOwnRoomFillsBothStrips(dark: Bool) async throws {
        try await withEditorWorld { session, _ in
            try await mintTheLongBook(session)
            let router = MobileShellRouter()
            try await withSceneSurface(
                MobileShellView(session: session, services: nil, router: router), dark: dark
            ) { surface in
                await surface.settle(40)
                let tokens = router.tokens(dark: dark)
                try await openTheLongBooksReadPage(
                    surface, readWord: tokens.chromeLabel(MobileBookView.readDoorTitle))
                let room = PixelColor(
                    UIColor(ReadingPageTokens.room(voice: tokens.voice, dark: dark)), traits: surface.traits)
                let pixels = try surface.render()
                let bounds = surface.window.bounds
                // Inside the band every tree draws the room here: the margin
                // beside the cream page, half-way down.
                let inside = pixels.color(at: CGPoint(x: 2, y: bounds.midY))
                try #require(inside.distance(to: room) <= Self.tolerance,
                             "inside the band the Read page's margin reads \(inside), its room is \(room)")
                let edges = try edgePoints(surface)
                for point in edges.top + edges.bottom {
                    let seen = pixels.color(at: point)
                    #expect(seen.distance(to: room) <= Self.tolerance,
                            "dark \(dark): at the screen's edge \(point) the Read page shows \(seen), not its room \(room)")
                }
            }
        }
    }

    // MARK: - The fixtures and roads these pins share

    /// The long book: one note whose one paragraph runs long enough that her
    /// lines continue, with no gap, past both of the screen's strips.
    static let longBook = "A long book"
    static let longParagraph = Array(
        repeating: "The tide came in slowly over the flats, and the gulls walked ahead of it as if they owned the shore.",
        count: 30).joined(separator: " ")

    private func mintTheLongBook(_ session: AppSession) async throws {
        let name = Self.longBook
        let text = Self.longParagraph
        try await session.runner.run { ops in
            let book = try ops.createReading(name: name, kind: .book)
            let note = try ops.createPost(title: "A long walk")
            _ = try ops.newBlock(in: note.id, text: text, at: .end)
            _ = try ops.addPostToReading(note.id, to: book.id)
        }
    }

    /// From the Bookcase: the long book's row, then its contents' Read door. The
    /// door sits in the navigation bar, so it is driven by each road a bar door
    /// answers to in turn — its accessibility activation, its control's actions,
    /// its bar item's action — and the arrival is PROVEN each time (her paragraph
    /// on screen, or the Read page's tall scroll), never assumed.
    private func openTheLongBooksReadPage<V: View>(
        _ surface: SceneHostedSurface<V>, readWord: String
    ) async throws {
        let bounds = surface.window.bounds.insetBy(dx: 1, dy: 1)
        let row = try #require(surface.elements.first {
            ($0.accessibilityLabel ?? "").lowercased().hasPrefix(Self.longBook.lowercased())
                && bounds.intersects($0.accessibilityFrame)
        }, "the long book's row on the Bookcase: \(surface.labels)")
        #expect(row.accessibilityActivate())
        await surface.settle(50)
        func arrived() -> Bool {
            surface.onScreen(Self.longParagraph) != nil
                || (tallestScrollOnScreen(surface)?.contentSize.height ?? 0) > 1500
        }
        let doors = surface.elements.filter {
            $0.accessibilityLabel == readWord && bounds.intersects($0.accessibilityFrame)
        }
        var roads: [String] = []
        for door in doors where !arrived() {
            if door.accessibilityActivate() {
                roads.append("accessibilityActivate")
                await surface.settle(50)
            }
        }
        for door in doors where !arrived() {
            guard let control = door as? UIControl else { continue }
            control.sendActions(for: .primaryActionTriggered)
            roads.append("primaryActionTriggered")
            await surface.settle(50)
            if !arrived() {
                control.sendActions(for: .touchUpInside)
                roads.append("touchUpInside")
                await surface.settle(50)
            }
        }
        if !arrived(), let item = barItem(titled: readWord, in: surface.host), let action = item.action {
            UIApplication.shared.sendAction(action, to: item.target, from: item, for: nil)
            roads.append("the bar item's action")
            await surface.settle(50)
        }
        try #require(arrived(), """
            the Read page did not arrive: the contents' Read door (\(doors.count) on screen) could not be driven \
            in process (roads tried: \(roads)); labels: \(surface.labels)
            """)
        await surface.settle(30)
    }

    /// The bar button item with this title on any navigation controller's top
    /// screen under `controller`.
    private func barItem(titled title: String, in controller: UIViewController) -> UIBarButtonItem? {
        var queue: [UIViewController] = [controller]
        while let next = queue.popLast() {
            if let navigation = next as? UINavigationController, let top = navigation.topViewController {
                let items = (top.navigationItem.rightBarButtonItems ?? []) + (top.navigationItem.leftBarButtonItems ?? [])
                if let item = items.first(where: { $0.title == title || $0.accessibilityLabel == title }) {
                    return item
                }
            }
            queue.append(contentsOf: next.children)
            if let presented = next.presentedViewController { queue.append(presented) }
        }
        return nil
    }

    /// The on-screen scroll view holding the tallest content (a text view is
    /// not a page's scroll).
    private func tallestScrollOnScreen<V: View>(_ surface: SceneHostedSurface<V>) -> UIScrollView? {
        var found: [UIScrollView] = []
        var queue: [UIView] = [surface.window]
        while let view = queue.popLast() {
            if let scroll = view as? UIScrollView, !(view is UITextView) { found.append(scroll) }
            queue.append(contentsOf: view.subviews)
        }
        let screen = surface.window.bounds
        return found.filter { scroll in
            guard !scroll.isHidden, scroll.window === surface.window else { return false }
            let frame = scroll.convert(scroll.bounds, to: surface.window)
            return screen.contains(CGPoint(x: frame.midX, y: frame.midY))
        }.max { $0.contentSize.height < $1.contentSize.height }
    }

    /// Of the on-screen elements with this label, the lowest (the bar's door
    /// under any same-word line above it).
    private func lowestOnScreen<V: View>(_ surface: SceneHostedSurface<V>, _ label: String) -> NSObject? {
        let bounds = surface.window.bounds.insetBy(dx: 1, dy: 1)
        return surface.elements
            .filter { $0.accessibilityLabel == label && bounds.intersects($0.accessibilityFrame) }
            .max { $0.accessibilityFrame.midY < $1.accessibilityFrame.midY }
    }

    /// A strip's commonest colour, and its pixel farthest from it.
    private func oneGround(_ pixels: RenderedPixels, in rect: CGRect)
        -> (ground: PixelColor, farthest: PixelColor, distance: Double)?
    {
        let all = pixels.colors(in: rect)
        guard !all.isEmpty else { return nil }
        var counts: [Int: Int] = [:]
        func key(_ c: PixelColor) -> Int {
            Int((c.r * 255).rounded()) << 16 | Int((c.g * 255).rounded()) << 8 | Int((c.b * 255).rounded())
        }
        for c in all { counts[key(c), default: 0] += 1 }
        guard let groundKey = counts.max(by: { $0.value < $1.value })?.key else { return nil }
        let ground = PixelColor(
            r: Double((groundKey >> 16) & 0xFF) / 255, g: Double((groundKey >> 8) & 0xFF) / 255,
            b: Double(groundKey & 0xFF) / 255)
        guard let farthest = all.max(by: { $0.distance(to: ground) < $1.distance(to: ground) }) else { return nil }
        return (ground, farthest, farthest.distance(to: ground))
    }
}
