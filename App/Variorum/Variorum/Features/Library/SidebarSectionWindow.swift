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
//    revealOffset`) landed through the reveal's `ScrollViewReader` proxy,
//    unanimated. (U1b's windows: an absolute `ScrollPosition` road was tried
//    and withdrawn, the orchestrator's ruling on Q9.) Her own scroll moves
//    neither the viewport nor the content, so a list she has scrolled is
//    never pulled back by a scroll; a row closing elsewhere is no reason
//    either (P-U1b-7). (The re-walk's R6 showed that was not enough — any
//    LATER viewport or content change still pulled her list back — so
//    U1d's FOLLOW below gates every one of these re-asks.)
//  · U1c (P-U1c-1 — the trace leg): the rail's implicit animation reaches a
//    section's viewport frame by frame, its top held, and the re-ask used to
//    fire only on a reading that stepped more than half a point — so the
//    ease's slow tail cut the row by its sum (1–2 pt in the mounted rig)
//    until the settled backstop landed it 0.30 s later. The viewport now
//    re-asks on EVERY reading that changes it (`SidebarLayout.readingAsk`)
//    and reveals directly — the beat's last reading lands the row exactly.
//    The settled check (`transitionSettle`) stays as the backstop of the
//    DISCRETE requests only: the current row, the content height, the
//    pitch, the mount.
//  · U1d (her two rulings on the design memo, 2026-10-15):
//    - FOLLOW, not every change (R6 — the re-walk saw the list pulled back
//      to the current row seconds after her own scroll, with no input). A
//      section FOLLOWS its current row from its first appearance and after
//      every current-row change (an open, a ⇧⌘W/✕/Close All landing,
//      back/forward); while it follows, every input above still re-asks.
//      A HAND scroll — the scroll view's own phase, interacting or
//      decelerating (`onScrollPhaseChange`; the reveal's unanimated
//      `scrollTo` reports no phase, an animated scroll `.animating`) — ends
//      following, and then NO reading, pitch change or settled check may
//      reveal until her next act (`SidebarLayout.SectionFollow`, pure).
//      Her words: *"once you scroll by hand it stays where you put it until
//      your next one of those; resizing the window never pulls it back."*
//    - THE FADE, RESHAPED (O-2/O-3): always the full half row deep where
//      more lies beyond, its STRENGTH eased with the content beyond, and
//      never fully solid at the very edge (`SidebarLayout.edgeFades`,
//      `edgeFadeCap`).
//

import SwiftUI

/// The DEBUG oracle's tap (`SidebarGeometry.recordSection(_:fades:for:)`): the
/// fades the section drew. nil in a shipping build. (The window itself is read
/// by its own DEBUG oracle in `SidebarView`, independent of this modifier, so
/// a pin can measure a row's place with or without it.)
typealias SidebarSectionWindowReport = (SidebarLayout.EdgeFades) -> Void

/// U1d's DEBUG seam (nil in a shipping build): the section hands its owner a
/// way to feed its follow state a scroll PHASE — exactly the road
/// `onScrollPhaseChange` takes — so a mounted pin can play a hand scroll
/// without posting a real scroll-wheel event (the test host never injects
/// pointer events for this). `SidebarView` files it with the DEBUG oracle,
/// keyed by the column's workspace.
typealias SidebarSectionPhaseSeam = (@escaping (ScrollPhase) -> Void) -> Void

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
    var phaseSeam: SidebarSectionPhaseSeam? = nil

    @State private var fades = SidebarLayout.EdgeFades.none
    @State private var memory = SidebarSectionMemory()
    /// Bumped to ask for the settled check — through `onChange`, so the check
    /// runs with the section's FRESH rows, current row and pitch.
    @State private var settledCheck = 0


    /// How long after a reveal request the section checks again — DERIVED from
    /// the column's one transition beat (`SidebarLayout.transitionSettle` =
    /// `railTransition` + its margin; the orchestrator's ruling on P-U1b-5:
    /// never a free-standing number). Since P-U1b-6 it is the BACKSTOP, and
    /// since P-U1c-1 only the DISCRETE requests schedule it (the current row,
    /// the content height, the pitch, the mount) — a viewport reading reveals
    /// directly, frame by frame, and schedules nothing.
    static var transitionSettle: Duration { .seconds(SidebarLayout.transitionSettle) }

    /// **U1d — which scroll phases are HER hand** (her ruling on the memo,
    /// R6): interacting (a trackpad gesture, a wheel burst, the scroller) and
    /// decelerating (its momentum). Measured offscreen at U1d: a wheel burst
    /// and a trackpad gesture each report `.interacting` before their first
    /// offset change; the reveal's unanimated `scrollTo` reports no phase; an
    /// animated programmatic scroll reports `.animating` — the app's, never
    /// hers.
    static func isHandScroll(_ phase: ScrollPhase) -> Bool {
        phase == .interacting || phase == .decelerating
    }

    private var depth: CGFloat { SidebarLayout.edgeFadeDepth(rowHeight: rowHeight) }

    #if DEBUG
    /// U1c's trace label: which section this is (Starred's rows are star
    /// targets, the Open list's note ids).
    private var traceLabel: String { String(describing: RowID.self) }
    #endif

    func body(content: Content) -> some View {
        ScrollViewReader { proxy in
            content
                .onAppear {
                    memory.proxy = proxy
                    // U1d's DEBUG seam: the same road as the phase callback below.
                    let memory = memory
                    let label = traceLabelOrEmpty
                    phaseSeam? { phase in Self.observe(phase, memory: memory, label: label) }
                }
                .onScrollGeometryChange(for: SidebarLayout.ScrollWindow.self) {
                    SidebarLayout.ScrollWindow($0)
                } action: { old, new in
                    memory.window = new
                    refreshFades(new)
                    let rowsChanged = rows.count != memory.rowCountAtReading
                    memory.rowCountAtReading = rows.count
                    #if DEBUG
                    SidebarSectionTrace.note(traceLabel,
                        "reading \(SidebarSectionTrace.text(old)) -> \(SidebarSectionTrace.text(new))"
                        + " rows=\(rows.count) rowsChanged=\(rowsChanged) pitch=\(rowHeight)"
                        + " following=\(memory.follow.following)")
                    #endif
                    if memory.mountRevealOwed, new.isMeasured {
                        memory.mountRevealOwed = false
                        // The section's first appearance is an act (U1d).
                        memory.follow.act()
                        requestReveal("mount")
                        return
                    }
                    // Every input that moves the row's place re-asks (P-U1b-6): the
                    // content height under an unchanged count (the pitch flip's own
                    // signal) as a discrete request; the viewport (the rail arriving,
                    // a resize) on EVERY reading that changes it, revealed at once
                    // (P-U1c-1). An offset-only change — her scroll — never does.
                    // And only while the section FOLLOWS (U1d): after her hand
                    // scroll, nothing moves the list until her next act.
                    switch memory.follow.gate(
                        SidebarLayout.readingAsk(old: old, new: new, rowsChanged: rowsChanged)) {
                    case .request: requestReveal("content")
                    case .revealNow: reveal("viewport")
                    case .none: break
                    }
                }
                // U1d: her hand on the scroll ends following (R6).
                .onScrollPhaseChange { _, phase in
                    Self.observe(phase, memory: memory, label: traceLabelOrEmpty)
                }
                // A current-row change is her ACT: follow again (U1d), then reveal.
                .onChange(of: current) {
                    memory.follow.act()
                    requestReveal("current")
                }
                .onChange(of: rowHeight) {
                    refreshFades(memory.window)
                    // The pitch moved the row — a discrete request, while following.
                    if memory.follow.gate(.request) == .request { requestReveal("rowHeight") }
                }
                .onChange(of: settledCheck) {
                    // The backstop moves the list only while it still follows: a
                    // hand scroll inside the settle window wins (U1d).
                    if memory.follow.gate(.revealNow) == .revealNow { reveal("settled") }
                }
                .overlay { SidebarEdgeFade(fades: fades, room: room) }
        }
    }

    /// The trace's label in a DEBUG build; nothing in a shipping one.
    private var traceLabelOrEmpty: String {
        #if DEBUG
        traceLabel
        #else
        ""
        #endif
    }

    /// A scroll phase reaches the section's follow state — from
    /// `onScrollPhaseChange`, or (DEBUG) from a pin through `phaseSeam`.
    private static func observe(_ phase: ScrollPhase, memory: SidebarSectionMemory, label: String) {
        memory.follow.phase(hers: isHandScroll(phase))
        #if DEBUG
        SidebarSectionTrace.note(label, "phase \(phase) following=\(memory.follow.following)")
        #endif
    }

    private func refreshFades(_ window: SidebarLayout.ScrollWindow) {
        let now = SidebarLayout.edgeFades(window, depth: depth)
        if now != fades { fades = now }
        report?(now)
    }

    /// A DISCRETE request: a reveal now, from the window as last read — and
    /// the same question again once any transition the request rode in on has
    /// settled. (A viewport reading never comes here — P-U1c-1.)
    private func requestReveal(_ trigger: StaticString) {
        memory.episode &+= 1
        let episode = memory.episode
        #if DEBUG
        SidebarSectionTrace.note(traceLabel, "request \(trigger) episode=\(episode)")
        #endif
        reveal(trigger)
        Task { @MainActor in
            try? await Task.sleep(for: Self.transitionSettle)
            #if DEBUG
            SidebarSectionTrace.note(traceLabel, "settle-timer episode=\(episode) latest=\(memory.episode)"
                + (memory.episode == episode ? " FIRES" : " superseded"))
            #endif
            if memory.episode == episode { settledCheck &+= 1 }
        }
    }

    /// The current row, scrolled clear of the fades when the window as last
    /// read says it is not: the exact offset (`revealOffset`), turned into the
    /// proxy's anchor and landed unanimated.
    private func reveal(_ caller: StaticString) {
        let window = memory.window
        guard window.isMeasured, let current, let row = rows.firstIndex(of: current),
              let target = SidebarLayout.revealOffset(
                row: row, rows: rows.count, rowHeight: rowHeight, window: window, depth: depth)
        else {
            #if DEBUG
            SidebarSectionTrace.note(traceLabel,
                "reveal(\(caller)) NONE window=\(SidebarSectionTrace.text(window))"
                + " row=\(current.flatMap { rows.firstIndex(of: $0) }.map(String.init) ?? "nil")"
                + "/\(rows.count) pitch=\(rowHeight)")
            #endif
            return
        }
        var unanimated = Transaction()
        unanimated.disablesAnimations = true
        // The proxy lands the row's top `y × (viewport − rowHeight)` below the
        // window's top, so the exact offset is the anchor `y` below.
        let room = window.viewport - rowHeight
        let anchor = room > 0 ? min(max((CGFloat(row) * rowHeight - target) / room, 0), 1) : 0
        #if DEBUG
        SidebarSectionTrace.note(traceLabel,
            "reveal(\(caller)) window=\(SidebarSectionTrace.text(window)) row=\(row)/\(rows.count)"
            + " pitch=\(rowHeight) target=\(target) anchor=\(anchor) proxy=\(memory.proxy != nil)")
        #endif
        withTransaction(unanimated) {
            memory.proxy?.scrollTo(current, anchor: UnitPoint(x: 0.5, y: anchor))
        }
    }
}

/// A scrolling section's window as last read, and its reveal's bookkeeping —
/// top-level (not nested in the generic modifier) so its isolation never
/// leans on the row type's conformances. Held by
/// REFERENCE, so the scroll's every frame re-renders nothing (only a
/// change of the fades does).
@MainActor
final class SidebarSectionMemory {
    var window = SidebarLayout.ScrollWindow.unmeasured
    /// The mount's reveal waits for the first MEASURED reading.
    var mountRevealOwed = true
    /// How many rows stood at the last reading (a content change from a
    /// row closing elsewhere is not a reason to scroll — P-U1b-7).
    var rowCountAtReading = 0
    /// Each reveal request is an episode; a later one supersedes the
    /// settled check an earlier one scheduled.
    var episode = 0
    /// The section's `ScrollViewReader` proxy — the reveal's road (the
    /// orchestrator's ruling on Q9).
    var proxy: ScrollViewProxy?
    /// U1d: whether the section follows its current row (her ruling, R6).
    var follow = SidebarLayout.SectionFollow()
}

/// F-2's fade, reshaped at U1d: on each edge that has content beyond it, the
/// room at the edge's OPACITY (its eased strength under the cap — never fully
/// solid) at the very edge, gone a half row in.
private struct SidebarEdgeFade: View {
    let fades: SidebarLayout.EdgeFades
    let room: Color

    var body: some View {
        VStack(spacing: 0) {
            LinearGradient(colors: [room.opacity(fades.top.opacity), room.opacity(0)],
                           startPoint: .top, endPoint: .bottom)
                .frame(height: fades.top.depth)
            Spacer(minLength: 0)
            LinearGradient(colors: [room.opacity(0), room.opacity(fades.bottom.opacity)],
                           startPoint: .top, endPoint: .bottom)
                .frame(height: fades.bottom.depth)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

#if DEBUG
/// **U1c — the trace leg's instrument** (DEBUG-only; the VX-283 run). Off
/// unless a pin or the offscreen probe installs a `sink`: every geometry
/// reading a scrolling section receives, every reveal request and its
/// trigger, every reveal's inputs and what it hands the proxy, and every
/// settled check — each stamped on the system uptime clock (the same clock
/// as `CACurrentMediaTime`), so a trace lines up with AppKit's own
/// notifications. The architect's ruling decides whether it stays as an
/// oracle or goes.
@MainActor
enum SidebarSectionTrace {
    static var sink: ((String) -> Void)?

    static func note(_ label: String, _ line: @autoclosure () -> String) {
        guard let sink else { return }
        sink(String(format: "%.4f", ProcessInfo.processInfo.systemUptime) + " [\(label)] " + line())
    }

    nonisolated static func text(_ window: SidebarLayout.ScrollWindow) -> String {
        String(format: "(off %.3f vp %.3f ct %.3f)", window.offset, window.viewport, window.content)
    }
}
#endif
