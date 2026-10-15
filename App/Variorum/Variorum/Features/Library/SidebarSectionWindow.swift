//
//  SidebarSectionWindow.swift
//  Variorum (Mac)
//
//  VX-283 run, U1b — the fix leg of U1 (the orchestrator's eye on U1's walk).
//  ONE scrolling sidebar section's WINDOW over its rows, for the two sections
//  that scroll in place — Starred and the Open list — so the two cannot drift:
//
//  · F-2 (PROVISIONAL P-U1-6, the orchestrator's ruling): a scrolled section
//    sliced its partial row through the letters right under its header — a
//    hard clip that read unfinished. Each edge now FADES over about half a
//    row, only where content lies beyond it (`SidebarLayout.edgeFades`). The
//    fade is an OVERLAY painted from the voice's ROOM token — the column's own
//    background — so the faded edge reads as the Bookcase strip's trailing
//    fade does (`BookcaseStrip.names`: content dissolving into the room),
//    following the voice, the palette and the appearance by construction. It
//    is never a per-row attribute and never a literal colour (P-8), it takes
//    no hits (the rows, the ✕ and the drops underneath stay live), and the
//    rows never move.
//  · F-1 (the walker's O-1): the note she had just opened could sit with its
//    highlighted row cut at the list's bottom edge, and stay so. The traced
//    mechanism (the U1b record): the old reveal was ONE minimal `scrollTo` per
//    NEWEST note, issued against whatever viewport stood when it ran — while
//    the Open list's viewport is a function of measurements that land a pass
//    later (`SidebarLayout.openListMaxHeight`'s two; the rail arriving; the
//    column's pitch flipping 30 ↔ 24 under the rail's transition) — and
//    returning to the note she was already in never revealed at all (its
//    recency did not change). Now the CURRENT row is revealed (clear of the
//    fades) on every current-row change, on the section's first reading, and
//    on EVERY viewport-height change, from the window as it then stands
//    (`SidebarLayout.revealAnchor`). A scroll of hers changes no viewport, so
//    a list she has scrolled is never pulled back by a scroll. Each reveal
//    is asked twice — at once, and again once the transition it rode in on
//    has settled (`transitionSettle`) — and scrolls unanimated: U1b's stage
//    window found a scroll issued inside the rail's animated transition
//    resting 1 pt short, with nothing asking again.
//

import SwiftUI

/// The DEBUG oracle's tap (`SidebarGeometry.recordSection(_:fades:for:)`): the
/// fades the section drew. nil in a shipping build. (The window itself is read
/// by its own DEBUG oracle in `SidebarView`, independent of this modifier, so
/// a pin can measure a row's place with or without it.)
typealias SidebarSectionWindowReport = (SidebarLayout.EdgeFades) -> Void

extension SidebarLayout.ScrollWindow {
    /// A scroll view's reading: its visible rectangle in the content's space
    /// and the content's height.
    nonisolated init(_ geometry: ScrollGeometry) {
        self.init(
            offset: geometry.visibleRect.minY,
            viewport: geometry.visibleRect.height,
            content: geometry.contentSize.height)
    }
}

/// Applied to a scrolling section's `ScrollView`, inside its `ScrollViewReader`.
struct SidebarSectionWindow<RowID: Hashable>: ViewModifier {
    let proxy: ScrollViewProxy
    /// The section's rows, in drawn order, each `rowHeight` tall.
    let rows: [RowID]
    /// The row of what the pane shows, if it is one of these.
    let current: RowID?
    let rowHeight: CGFloat
    /// The voice's room — the column's own background, which the fade paints.
    let room: Color
    var report: SidebarSectionWindowReport? = nil

    @State private var fades = SidebarLayout.EdgeFades.none
    @State private var memory = Memory()
    /// Bumped to ask for the after-the-transition check — through `onChange`,
    /// so the check runs with the section's FRESH rows, current row and pitch.
    @State private var settledCheck = 0

    /// The window as last read, and the reveal's bookkeeping — held by
    /// REFERENCE, so the scroll's every frame re-renders nothing (only a
    /// change of the fades does).
    @MainActor
    final class Memory {
        var window = SidebarLayout.ScrollWindow.unmeasured
        /// The mount's reveal waits for the first MEASURED reading.
        var mountRevealOwed = true
        /// Each reveal request is an episode; a later one supersedes the
        /// after-the-transition check an earlier one scheduled.
        var episode = 0
    }

    /// How long after a reveal request the section checks again — DERIVED from
    /// the column's one transition beat (`SidebarLayout.transitionSettle` =
    /// `railTransition` + its margin; the orchestrator's ruling on P-U1b-5:
    /// never a free-standing number). U1b's stage window found why: a scroll
    /// issued while the column's layout is still animating is resolved against
    /// the scroll view's PRESENTATION frame, not the one it settles into, and
    /// no reading arrives once the animation ends — so the row could rest short
    /// (1 pt in the window's Starred pin; once in ~40, much more, the walker's
    /// O-1).
    static var transitionSettle: Duration { .seconds(SidebarLayout.transitionSettle) }

    private var depth: CGFloat { SidebarLayout.edgeFadeDepth(rowHeight: rowHeight) }

    func body(content: Content) -> some View {
        content
            .onScrollGeometryChange(for: SidebarLayout.ScrollWindow.self) {
                SidebarLayout.ScrollWindow($0)
            } action: { old, new in
                memory.window = new
                refreshFades(new)
                if memory.mountRevealOwed, new.isMeasured {
                    memory.mountRevealOwed = false
                    requestReveal()
                } else if abs(new.viewport - old.viewport) > 0.5 {
                    // F-1's mechanism: a viewport that changed height under a
                    // revealed row (the rail arriving, the pitch flipping, the
                    // window resizing) reveals it from the window as it now is.
                    requestReveal()
                }
            }
            .onChange(of: current) { requestReveal() }
            .onChange(of: settledCheck) { reveal() }
            .onChange(of: rowHeight) { refreshFades(memory.window) }
            .overlay { SidebarEdgeFade(fades: fades, room: room) }
    }

    private func refreshFades(_ window: SidebarLayout.ScrollWindow) {
        let now = SidebarLayout.edgeFades(window, depth: depth)
        if now != fades { fades = now }
        report?(now)
    }

    /// A reveal now, from the window as last read — and the same question
    /// again once any transition the request rode in on has settled.
    private func requestReveal() {
        memory.episode &+= 1
        let episode = memory.episode
        reveal()
        Task { @MainActor in
            try? await Task.sleep(for: Self.transitionSettle)
            if memory.episode == episode { settledCheck &+= 1 }
        }
    }

    /// The current row, scrolled clear of the fades when the window as last
    /// read says it is not — unanimated, so the scroll lands on the layout it
    /// was computed against rather than riding the request's transition.
    private func reveal() {
        let window = memory.window
        guard window.isMeasured, let current, let row = rows.firstIndex(of: current),
              let anchor = SidebarLayout.revealAnchor(
                row: row, rows: rows.count, rowHeight: rowHeight, window: window, depth: depth)
        else { return }
        var unanimated = Transaction()
        unanimated.disablesAnimations = true
        withTransaction(unanimated) {
            proxy.scrollTo(current, anchor: UnitPoint(x: 0.5, y: anchor))
        }
    }
}

/// F-2's fade: the room, solid at the very edge, gone `depth` points in — on
/// each edge that has content beyond it, as deep as that content (capped).
private struct SidebarEdgeFade: View {
    let fades: SidebarLayout.EdgeFades
    let room: Color

    var body: some View {
        VStack(spacing: 0) {
            LinearGradient(colors: [room, room.opacity(0)], startPoint: .top, endPoint: .bottom)
                .frame(height: fades.top)
            Spacer(minLength: 0)
            LinearGradient(colors: [room.opacity(0), room], startPoint: .top, endPoint: .bottom)
                .frame(height: fades.bottom)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
