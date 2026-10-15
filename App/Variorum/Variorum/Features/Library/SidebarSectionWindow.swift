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
//    on EVERY change of the viewport, the content height or the pitch, from
//    the window as it then stands — an EXACT offset (`SidebarLayout.
//    revealOffset`) set absolutely through a `ScrollPosition`, unanimated
//    (P-U1b-6 — U1b's two stage windows found the anchor road resting 1, then
//    2 pt short after a pitch flip). A scroll of hers changes neither the
//    viewport nor the content, so a list she has scrolled is never pulled
//    back by a scroll; a row closing elsewhere is no reason either (P-U1b-7).
//    The derived settled ask (`transitionSettle`) stays as the backstop.
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

/// Applied to a scrolling section's `ScrollView`.
struct SidebarSectionWindow<RowID: Hashable>: ViewModifier {
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
    /// **The section's scroll position — the reveal's ONE road** (P-U1b-6): an
    /// exact content offset (`SidebarLayout.revealOffset`) set absolutely,
    /// never the proxy's id lookup with an anchor fraction (which resolved the
    /// row through the lazy stack's own, stale, estimate mid-flip).
    @State private var position = ScrollPosition()
    /// Bumped to ask for the settled check — through `onChange`, so the check
    /// runs with the section's FRESH rows, current row and pitch.
    @State private var settledCheck = 0

    /// The window as last read, and the reveal's bookkeeping — held by
    /// REFERENCE, so the scroll's every frame re-renders nothing (only a
    /// change of the fades does).
    @MainActor
    final class Memory {
        var window = SidebarLayout.ScrollWindow.unmeasured
        /// The mount's reveal waits for the first MEASURED reading.
        var mountRevealOwed = true
        /// How many rows stood at the last reading (a content change from a
        /// row closing elsewhere is not a reason to scroll — P-U1b-7).
        var rowCountAtReading = 0
        /// Each reveal request is an episode; a later one supersedes the
        /// settled check an earlier one scheduled.
        var episode = 0
    }

    /// How long after a reveal request the section checks again — DERIVED from
    /// the column's one transition beat (`SidebarLayout.transitionSettle` =
    /// `railTransition` + its margin; the orchestrator's ruling on P-U1b-5:
    /// never a free-standing number). Since P-U1b-6 it is the BACKSTOP: every
    /// input that moves the row's place already re-asks.
    static var transitionSettle: Duration { .seconds(SidebarLayout.transitionSettle) }

    private var depth: CGFloat { SidebarLayout.edgeFadeDepth(rowHeight: rowHeight) }

    func body(content: Content) -> some View {
        content
            .scrollPosition($position)
            .onScrollGeometryChange(for: SidebarLayout.ScrollWindow.self) {
                SidebarLayout.ScrollWindow($0)
            } action: { old, new in
                memory.window = new
                refreshFades(new)
                let rowsChanged = rows.count != memory.rowCountAtReading
                memory.rowCountAtReading = rows.count
                if memory.mountRevealOwed, new.isMeasured {
                    memory.mountRevealOwed = false
                    requestReveal()
                } else if abs(new.viewport - old.viewport) > 0.5
                    || (abs(new.content - old.content) > 0.5 && !rowsChanged) {
                    // Every input that moves the row's place re-asks (P-U1b-6):
                    // the viewport (the rail arriving, a resize) and the
                    // content height (the pitch flip's own signal — rows re-laid
                    // at the new pitch). An offset-only change — her scroll —
                    // never does.
                    requestReveal()
                }
            }
            .onChange(of: current) { requestReveal() }
            .onChange(of: rowHeight) {
                refreshFades(memory.window)
                requestReveal()
            }
            .onChange(of: settledCheck) { reveal() }
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
    /// read says it is not: the exact offset, set absolutely and unanimated.
    private func reveal() {
        let window = memory.window
        guard window.isMeasured, let current, let row = rows.firstIndex(of: current),
              let target = SidebarLayout.revealOffset(
                row: row, rows: rows.count, rowHeight: rowHeight, window: window, depth: depth)
        else { return }
        var unanimated = Transaction()
        unanimated.disablesAnimations = true
        withTransaction(unanimated) { position.scrollTo(y: target) }
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
