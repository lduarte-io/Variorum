//
//  BookNavigatorFollow.swift
//  Variorum (Mac)
//
//  VX-646 — the book navigator scrolls ITSELF to keep the highlighted row in
//  view. Her ask (VX-562's P-562-1, QUESTIONS #246, 2026-10-28): *"ticket needs
//  to be made for this."* — superseding P-562-1's as-built "no auto-scroll".
//  The ready shape is the Open list's follow idiom (SurfaceContracts §The app;
//  A-648-8 approved this reading): the list follows its CURRENT row; a HAND
//  scroll of the list pauses the follow until the next act; a resize never
//  pulls it back.
//
//  ── WHAT IS REUSED, AND WHAT IS NEW ─────────────────────────────────────
//  The follow STATE is the Open list's own pure value,
//  `SidebarLayout.SectionFollow` (an act follows again; a hand-scroll phase
//  stops it; every reveal ask is gated while stopped) — never a second one.
//  Here the CURRENT row is the navigator's highlighted row (`followsNoteRow`
//  / `followsChapterRow`), so "the next act" is the highlighted row changing —
//  the follow's own movement as she reads on, a navigator click, a step, a
//  mode switch.
//
//  What is new is the REVEAL, because the navigator's rows are not one pitch
//  (a chapter row 30 pt, a note row 24, the group gap 20 — the Open list's
//  `revealOffset` assumes uniform rows): the minimal reveal of ONE row from
//  its OWN reported frame in the list's visible space (`reveal`) — a row above
//  the list's top comes in at the top, a row below its foot at the foot,
//  unanimated through the list's `ScrollViewReader` (the Open list's road).
//  Only the highlighted row reports its frame (`BookNavigatorFollowMemory`),
//  so the list's other rows cost nothing (P1). The visible space is the
//  scroll's own frame; no travel is computed here — `scrollTo` clamps to the
//  scroll's REACHABLE extent, so the inset-extended travel VX-562's trace walk
//  measured (the 40-pt bottom bar that is never scrollable room) cannot
//  mislead it.
//

import CoreGraphics
import SwiftUI

nonisolated enum BookNavigatorFollow {
    /// The navigator list's own named space — `0` is the list's visible top
    /// edge, so a row's `minY` there says where it sits in view.
    static let space = "book-navigator-scroll"

    /// The rows' scroll identities (`ScrollViewProxy.scrollTo`'s targets) —
    /// prefixed so a note and a chapter can never share one.
    static func noteRowID(_ postID: String) -> String { "nav-note-\(postID)" }
    static func chapterRowID(_ sectionID: String) -> String { "nav-chapter-\(sectionID)" }

    /// **Is this NOTE row the highlighted row?** Its note is the viewed
    /// note (in the spread, the LEFT page — its other page's marker is a
    /// marker, not the row the list follows).
    static func followsNoteRow(_ postID: String, viewed: BookOutlineViewed.Pair) -> Bool {
        viewed.postID == postID
    }

    /// **Is this CHAPTER row the highlighted row?** When a note is viewed, the
    /// chapter row is it only as that note's own row (a one-note chapter
    /// collapsed into its heading — row 8); when only a chapter is viewed (an
    /// empty chapter's heading at the top), its row.
    static func followsChapterRow(
        _ sectionID: String, collapsedNote: String?, viewed: BookOutlineViewed.Pair
    ) -> Bool {
        if let note = viewed.postID { return collapsedNote == note }
        return viewed.sectionID == sectionID
    }

    /// How a row comes into view.
    enum Reveal: Equatable, Sendable {
        /// Its top to the list's top (`UnitPoint.top`).
        case top
        /// Its bottom to the list's foot (`UnitPoint.bottom`).
        case bottom
    }

    /// Half a point: layout noise, never a reason to scroll.
    static let tolerance: CGFloat = 0.5

    /// **The minimal reveal** of a row `height` tall whose top sits `top`
    /// below the list's visible top, in a list `viewport` tall: nil while the
    /// row is wholly in view (or the list is not measured); `.top` for a row
    /// that starts above the top; `.bottom` for one that ends below the foot;
    /// a row taller than the list shows its TOP (and asks nothing once its
    /// top is there — a reveal from its own result moves nothing).
    static func reveal(top: CGFloat, height: CGFloat, viewport: CGFloat) -> Reveal? {
        guard viewport > 0 else { return nil }
        if height > viewport { return abs(top) > tolerance ? .top : nil }
        if top < -tolerance { return .top }
        if top + height > viewport + tolerance { return .bottom }
        return nil
    }
}

/// **The navigator's follow, as it stands** — a reference box the book view's
/// `@State` merely holds, so the highlighted row's frame reports and the
/// list's scroll readings re-render nothing (the Outline box's rule). Fed by
/// four inputs: the highlighted row's own frame (`highlightedRowMoved` — a
/// NEW row is the act), the list's height (`listResized`), a scroll phase
/// (`phase`), and the proxy.
@MainActor
final class BookNavigatorFollowMemory {
    /// The Open list's own follow value (U1d's ruling, reused whole).
    private(set) var follow = SidebarLayout.SectionFollow()
    /// The highlighted row's scroll id, and its last frame in the list's
    /// visible space.
    private(set) var rowID: String?
    private(set) var rowTop: CGFloat = 0
    private(set) var rowHeight: CGFloat = 0
    /// The list's visible height (its scroll's container).
    private(set) var viewport: CGFloat = 0
    /// The list's `ScrollViewReader` proxy — the reveal's road.
    var proxy: ScrollViewProxy?
    #if DEBUG
    /// Where a pin hears what the follow did (`BookOutlineGeometry
    /// .navigatorFollows`): set by the book view with its id and owner.
    var report: ((BookNavigatorFollowState) -> Void)?
    #endif

    /// The highlighted row reported its frame. A row that was not the
    /// highlighted one is the ACT — follow again, whatever her hand did
    /// before (the Open list's current-row change); then, while following,
    /// reveal it.
    func highlightedRowMoved(_ id: String, top: CGFloat, height: CGFloat) {
        if id != rowID {
            rowID = id
            follow.act()
        }
        rowTop = top
        rowHeight = height
        revealIfFollowing()
    }

    /// The list's height changed (a window resize, the column's own layout):
    /// re-reveal only while following — after a hand scroll it never pulls
    /// the list back.
    func listResized(_ height: CGFloat) {
        guard height != viewport else { return }
        viewport = height
        revealIfFollowing()
    }

    /// A scroll phase on the LIST: her hand (interacting, decelerating — the
    /// Open list's own test, `SidebarSectionWindow.isHandScroll`) stops the
    /// follow until the highlighted row next changes; any other phase changes
    /// nothing.
    func phase(_ phase: ScrollPhase) {
        follow.phase(hers: SidebarSectionWindow<String>.isHandScroll(phase))
        publish()
    }

    private func revealIfFollowing() {
        defer { publish() }
        guard follow.following, let rowID,
              let edge = BookNavigatorFollow.reveal(top: rowTop, height: rowHeight, viewport: viewport)
        else { return }
        var unanimated = Transaction()
        unanimated.disablesAnimations = true
        withTransaction(unanimated) {
            proxy?.scrollTo(rowID, anchor: edge == .top ? .top : .bottom)
        }
    }

    private func publish() {
        #if DEBUG
        report?(BookNavigatorFollowState(
            following: follow.following, rowID: rowID, rowTop: rowTop,
            rowHeight: rowHeight, viewport: viewport))
        #endif
    }
}

#if DEBUG
/// What a pin reads of the navigator's follow (`BookOutlineGeometry
/// .navigatorFollows`, keyed by the book).
nonisolated struct BookNavigatorFollowState: Equatable, Sendable {
    var following: Bool
    var rowID: String?
    var rowTop: CGFloat
    var rowHeight: CGFloat
    var viewport: CGFloat

    /// The highlighted row wholly inside the list (the half-point tolerance).
    var rowIsInView: Bool {
        rowID != nil && viewport > 0
            && BookNavigatorFollow.reveal(top: rowTop, height: rowHeight, viewport: viewport) == nil
    }
}
#endif

/// **Only the highlighted row reports where it sits** (P1 — the list's other
/// rows cost nothing): while `active`, the row's frame in the list's visible
/// space goes to the follow; a row that stops being the highlighted one stops
/// reporting.
struct NavigatorFollowReport: ViewModifier {
    let memory: BookNavigatorFollowMemory
    let rowID: String
    let active: Bool

    func body(content: Content) -> some View {
        if active {
            content.onGeometryChange(for: CGRect.self) {
                $0.frame(in: .named(BookNavigatorFollow.space))
            } action: { frame in
                memory.highlightedRowMoved(rowID, top: frame.minY, height: frame.height)
            }
        } else {
            content
        }
    }
}
