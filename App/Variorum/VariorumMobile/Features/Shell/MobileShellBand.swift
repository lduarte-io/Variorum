//
//  MobileShellBand.swift
//  VariorumMobile
//
//  Round 2, batch 10 — **THE SWIPE**, as a pure brain.
//
//  Her words (2026-08-23, `notes/author-reports/2026-08-23-device-walk-
//  and-product-asks.md`): *"we need a swipe gesture for between shelf and
//  library it's killing me"*, and — for the page this band adds on the
//  other side — *"maybe you should be able to swipe from your shelf to a
//  list of starred notes on the home page?"*
//
//  ── THE BAND ──────────────────────────────────────────────────────────
//  Three root surfaces in one horizontal band, SHELF at home:
//
//      ‹ Starred    ·    SHELF    ·    Library ›
//
//  The tab bar is unchanged in kind and gains the third door, so it stays
//  AUTHORITATIVE (a tap selects) and IN SYNC (a swipe moves the same
//  state) — one `tab` value, two roads to it, never two truths.
//
//  ── WHY THIS IS ARITHMETIC AND NOT A PAGING CONTAINER ─────────────────
//  The brief's in-batch fork: *"Both stacks must STAY ALIVE exactly as
//  today … if the paging container would tear a stack down, STOP AND
//  PROPOSE."* No container is used, so the fork does not arise: the shell
//  keeps its `ZStack` of always-constructed `NavigationStack`s and this
//  brain supplies an X OFFSET for each. Every stack is built by the same
//  code as before, in the same order, with the same modifiers — the A2
//  liveness world and the quick-note box's lifecycle ride on that, and
//  nothing here can tear one down because nothing here decides whether a
//  stack EXISTS. (A `TabView(.page)` would have decided exactly that, and
//  its offscreen-page lifetime is not a documented guarantee.)
//
//  ── THE 13e JITTER RIDER ──────────────────────────────────────────────
//  Any new drag math uses NAMED coordinate spaces, never mixed ones:
//  `MobileShellBand.coordinateSpace` is declared here and BOTH the
//  `.coordinateSpace(name:)` modifier and the `DragGesture(coordinateSpace:)`
//  read this one symbol.
//
//  ── THE DIRECTION LATCH (why a vertical scroll never pages) ───────────
//  The band's gesture rides `.simultaneousGesture` over roots that contain
//  vertical `ScrollView`s, so it must decide EARLY and ONCE whether a
//  given drag is horizontal — and then stop asking. `engages` is that
//  decision; the shell latches it for the gesture's lifetime, so a drag
//  that began as a page cannot become a scroll halfway through and a drag
//  that began as a scroll can never page.
//

import CoreGraphics
import Foundation

nonisolated enum MobileShellBand {

    /// The ONE named coordinate space for this batch's drag math (13e's
    /// jitter rider: named spaces, never `.local` mixed with `.global`).
    static let coordinateSpace = "mobileShellBand"

    /// The band, left to right. The order IS the arrangement — the shelf
    /// sits in the middle because it is home (her *"swipe FROM your
    /// shelf"*), and both neighbours are one gesture away from it.
    static let pages: [MobileTab] = [.starred, .shelf, .library]

    /// Home — where the app opens, unchanged since S3.
    static let home: MobileTab = .shelf

    static func index(of page: MobileTab) -> Int {
        pages.firstIndex(of: page) ?? pages.firstIndex(of: home) ?? 0
    }

    // MARK: - The gesture's two decisions

    /// The minimum horizontal travel before the band takes a drag at all.
    static let engageDistance: CGFloat = 12

    /// How much more horizontal than vertical a drag must be to page. A
    /// ratio rather than an angle because that is what the value gives us,
    /// and 1.5 leaves an ordinary diagonal scroll to the scroll view.
    static let engageRatio: CGFloat = 1.5

    /// **The latch.** True when this drag is a PAGE, not a scroll.
    static func engages(_ translation: CGSize) -> Bool {
        abs(translation.width) > engageDistance
            && abs(translation.width) > abs(translation.height) * engageRatio
    }

    /// The drag, clamped so the ends of the band are WALLS rather than
    /// rubber: at `Starred` a rightward pull and at `Library` a leftward
    /// one have nowhere to go, and a band that visibly moves toward
    /// nothing is a promise it cannot keep.
    static func clampedDrag(_ raw: CGFloat, current: MobileTab, width: CGFloat) -> CGFloat {
        let i = index(of: current)
        var drag = raw
        if i == 0 { drag = min(drag, 0) }
        if i == pages.count - 1 { drag = max(drag, 0) }
        guard width > 0 else { return 0 }
        return max(-width, min(width, drag))
    }

    /// One page's X offset: its distance from the current page, plus the
    /// live (clamped) drag. At rest every neighbour sits exactly one screen
    /// away, which is why nothing but the current page is ever visible.
    static func offset(
        for page: MobileTab, current: MobileTab, drag: CGFloat, width: CGFloat
    ) -> CGFloat {
        // The same guard its sibling carries (the cold review's NIT 2): a
        // layout pass that proposes a ZERO width would put every page's
        // offset at the drag alone — all three roots stacked for a frame.
        // Nothing is mis-tappable while it holds (`allowsHitTesting` still
        // follows `tab`), which is why this is a guard and not a fix, but
        // one input guarded in one function and not the other reads as an
        // oversight rather than as a decision.
        guard width > 0 else { return 0 }
        return CGFloat(index(of: page) - index(of: current)) * width + drag
    }

    /// The share of the screen a drag must cross to land on the next page.
    static let landingShare: CGFloat = 0.28
    /// …with a floor, so a narrow screen (Display Zoom, the smallest
    /// supported phone) does not make paging hair-trigger.
    static let minimumLandingDistance: CGFloat = 40

    static func landingDistance(width: CGFloat) -> CGFloat {
        max(minimumLandingDistance, width * landingShare)
    }

    /// Where the band lands when the finger lifts. Two roads, because a
    /// FLICK and a DRAG are different gestures with one outcome: a slow
    /// drag lands when it has crossed the distance; a fast one lands on
    /// where it was GOING (`predictedEnd`, UIKit's own projection), so a
    /// quick flick pages without having to travel.
    ///
    /// A prediction only ever helps in the direction the finger actually
    /// moved — `drag` and `predictedEnd` must agree in sign — so a flick
    /// back toward the current page can never land forward.
    static func landing(
        current: MobileTab, drag: CGFloat, predictedEnd: CGFloat, width: CGFloat
    ) -> MobileTab {
        let distance = landingDistance(width: width)
        let flicked = abs(predictedEnd) >= width * 0.5
            && (predictedEnd < 0) == (drag < 0) && drag != 0
        guard abs(drag) >= distance || flicked else { return current }
        let step = drag < 0 ? 1 : -1
        let landed = index(of: current) + step
        guard pages.indices.contains(landed) else { return current }
        return pages[landed]
    }
}
