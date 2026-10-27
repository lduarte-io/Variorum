//
//  OpenListDrag.swift
//  Variorum (Mac)
//
//  **VX-288 — the Open list's drag, the light version** (the VX-283 run, U2).
//  Her words (2026-10-13): *"the dragging between open notes in there needs to
//  be smoother - it should be as smooth as the editor drag with a nice little
//  line showing as you hover and a nice fit / snap into place because right now
//  it feels janky to use."* Her ruling on the shape: **the light version first**
//  — the system drag stays — and the compact chip *"Only on the Open list's
//  rows"* (VX-70's ruling).
//
//  The traced jank (the U2 record): main's road — each row its own drop, every
//  drop landing in the gap BEFORE the row it was released on — drew nothing
//  while she dragged, moved without a settle, and had no slot after the last
//  row at all.
//
//  **U2d — the orchestrator's P-U2d-1: F2, the book navigator's road on MAIN's
//  own per-row API.** No synthetic road reaches a drop in the sidebar, on main
//  either (the U2c main-build control), so the drop stays on the API her hands
//  have used, and gains what she asked for:
//
//  · EACH ROW IS ITS OWN DROP (`OpenListRowDrop`) — a classic Transferable
//    `dropDestination(for:action:isTargeted:)`, main's own call — and the
//    TARGETED row names the slot BEFORE it: the line at its top, the landing
//    there (main's landing). An END ZONE under the rows names the last slot
//    (`OpenListEndZoneDrop`, the same kind of drop; PROVISIONAL P-U2d-2: it
//    takes the column's bottom padding too, so it is never absent).
//  · THE OPERATION is main's: the drop accepts by type and the system's copy
//    applies (the source's default) — no move configuration. The dragged row's
//    own place (its own row, and the row right after it) draws no line, and a
//    release there moves nothing, so the image slides back.
//  · THE LINE — 2 pt in the ring token, the book navigator's precedent — drawn
//    as an OVERLAY over the list (above the edge fade, taking no hits), placed
//    from the targeted row, the list's scroll window, the rows and the pitch,
//    so it re-derives on every input axis (target, scroll, list change; the
//    overlay/sink delivery law) and never before a reading exists. It lights
//    only where a drop would act (§12's false-offer rule): never on the dragged
//    row's own place, never for a drag that did not begin in this list.
//  · THE SETTLE — the move lands inside an animation on the column's one beat.
//  · A drop acts only on the list its drag began in (the token carries the
//    list's id — P-U2-3).
//  · The source's half (U2b's trace proved it, U2c kept it): the payload is
//    evaluated when the drag BEGINS, on the main thread, and arms the list's
//    drag; the drag SESSION's end — wherever the release fell — clears it.
//
//  What a drop does to the scrolling section's FOLLOW state (U1d): nothing
//  (P-U2-1). A drop is neither one of her acts (it changes no current row) nor
//  a hand scroll (it reports no scroll phase), and it never scrolls the list:
//  the rows rearrange in place under the pointer, a following list keeps
//  following, a list she scrolled stays where she put it.
//

import SwiftUI

/// **One Open list's drag, as it stands** — which row a drag of THIS list's
/// began on, which of the list's drops it targets, and the list's scroll
/// window as the line reads it. Held by the column (`SidebarView`); the line
/// and the drops read and write it. Observed, so the LINE re-renders on a
/// change — and only the line: the window is copied in only while a target
/// stands, so an ordinary scroll re-renders nothing.
@MainActor
@Observable
final class OpenListDragState {
    /// Which of the list's drops a drag targets: a row's HALF — by the row's
    /// NOTE, so a change of the list re-derives where that row stands (main's
    /// landing names the row the same way) — or the end zone.
    ///
    /// **VX-424:** a row has two targets now — its upper half (`before`, the
    /// slot before it; also the row's own drop under its halves) and its lower
    /// half (`after`, the slot after it) — where it had one (`row`, "before"
    /// whichever half the pointer was in).
    nonisolated enum Target: Equatable, Sendable {
        case before(String)
        case after(String)
        case end

        /// The target as the pure rule reads it, against `rows` as they stand
        /// — nil for a row no longer in the list.
        func hover(in rows: [String]) -> SidebarLayout.OpenListDrop.Hover? {
            switch self {
            case .before(let noteID): rows.firstIndex(of: noteID).map { .before($0) }
            case .after(let noteID): rows.firstIndex(of: noteID).map { .after($0) }
            case .end: .end
            }
        }
    }

    /// This list's name on its drags' payload (P-U2-3).
    @ObservationIgnored let listID = UUID().uuidString
    /// The row a drag of this list's began on; nil when none is in flight here.
    private(set) var dragging: String?
    /// The drop the drag targets now; nil while it is over none of the list's.
    private(set) var target: Target?
    /// The list's scroll window, as the line reads it (current only while a
    /// target stands).
    private(set) var window = SidebarLayout.ScrollWindow.unmeasured
    /// The list's window as last read, whatever is in flight.
    @ObservationIgnored private var latest = SidebarLayout.ScrollWindow.unmeasured

    /// A drag began on `noteID`'s row (`draggable`'s payload runs then — U2b's
    /// trace proved it: on the main thread, at the drag's start).
    ///
    /// Cleared by the drag SESSION's end wherever the release fell
    /// (`dragSessionUpdated`), and by a drop on this list (`ended()`, in
    /// `OpenListDropDoor.perform`) — the two may arrive in either order, and
    /// neither decides the drop (the payload and the drop's own row do).
    func began(_ noteID: String) {
        dragging = noteID
        if target != nil { target = nil }
    }

    /// The list's scroll view reported a reading — the line's scroll axis.
    func read(_ reading: SidebarLayout.ScrollWindow) {
        latest = reading
        if target != nil, window != reading { window = reading }
    }

    /// A drop's `isTargeted` changed — a row's, or the end zone's. A target
    /// replaces whatever stood; an un-target clears only the target IT set
    /// (each row is its own drop, so the next row's `true` may arrive before
    /// this row's `false`).
    func targeted(_ which: Target, _ isTargeted: Bool) {
        if isTargeted {
            if window != latest { window = latest }
            if target != which { target = which }
        } else if target == which {
            target = nil
        }
    }

    /// The row's drag SESSION moved on (the source's `onDragSessionUpdated`) —
    /// its END, wherever the release fell, ends the drag; a session still in
    /// flight changes nothing.
    func dragSessionUpdated(_ phase: DragSession.Phase) {
        guard case .ended = phase else { return }
        ended()
    }

    /// The drag is over — dropped here, or its session ended.
    func ended() {
        if dragging != nil { dragging = nil }
        if target != nil { target = nil }
    }

    /// **Whether THIS list's drag is in flight among `rows`** — the row
    /// halves' liveness (VX-424): a drag began here AND its row is still
    /// drawn. The VX-439 ladder's m-7: should a drag's session end never be
    /// delivered after its source row is removed mid-drag (closed in another
    /// window, a sync apply), `dragging` would stay latched — and the halves
    /// with it, eating every row's clicks (R-G's mechanism). A gone row
    /// stands them down; the row's own drop under them still lands a drop.
    func dragInFlight(among rows: [String]) -> Bool {
        dragging.map(rows.contains) ?? false
    }

    /// The line's top in the list's viewport — nil where none is drawn.
    func lineTop(rows: [String], rowHeight: CGFloat) -> CGFloat? {
        SidebarLayout.OpenListDrop.lineTop(
            hover: target?.hover(in: rows), dragged: dragging.flatMap { rows.firstIndex(of: $0) },
            rows: rows.count, rowHeight: rowHeight, window: window)
    }
}

/// **The drop's door** — what the drops share, and the acts a pin drives.
@MainActor
enum OpenListDropDoor {
    /// **The settle** — the move lands on the column's one beat
    /// (`SidebarLayout.railTransition`), with a snap: her *"a nice fit / snap
    /// into place"*. PROVISIONAL P-U2-4.
    static var settle: Animation { .snappy(duration: SidebarLayout.railTransition) }

    /// **The release on `target`** — named by the drop that took it (a row's
    /// half, the row itself, or the end zone), never by the hover state, against
    /// the rows as they stand: the slot before or after that row, or the last
    /// slot. `land` decides
    /// on the payload's word (a drop never depends on the drag having been seen
    /// to begin, nor on the order of the source session's end against the
    /// drop). The drop ends the drag either way. Returns whether anything moved
    /// — false (the image slides back) for no payload, a row no longer listed,
    /// another list's drag, or the dragged row's own place.
    ///
    /// **VX-589:** `displayed` — the rows the list DRAWS (the strip less its
    /// starred notes while "Hide starred notes from Open" is on; nil = the
    /// strip). The target and the own place are read among the drawn rows,
    /// where the line was judged; the landing names the strip's slot
    /// (`OpenListDrop.stripGap`). With nothing hidden, exactly as before.
    @discardableResult
    static func perform(
        _ tokens: [SidebarView.OpenNoteDragToken], onto target: OpenListDragState.Target,
        displayed: [String]? = nil,
        state: OpenListDragState, workspace: WorkspaceModel, animation: Animation? = settle
    ) -> Bool {
        state.ended()
        let shown = workspace.openNotes.shown
        let drawn = displayed ?? shown
        guard let token = tokens.first, let hover = target.hover(in: drawn),
              let gap = SidebarLayout.OpenListDrop.gap(for: hover, rows: drawn.count),
              let stripGap = SidebarLayout.OpenListDrop.stripGap(
                displayedGap: gap, displayed: drawn, strip: shown, dragged: token.noteID)
        else { return false }
        return land(token, atGap: stripGap, listID: state.listID, in: workspace, animation: animation)
    }

    /// **The landing**: the dragged row moves to the gap — when the drag began
    /// in THIS list (P-U2-3) and the move changes something — inside the
    /// settle. Returns whether anything moved.
    @discardableResult
    static func land(
        _ token: SidebarView.OpenNoteDragToken, atGap gap: Int, listID: String,
        in workspace: WorkspaceModel, animation: Animation? = settle
    ) -> Bool {
        let shown = workspace.openNotes.shown
        guard token.listID == listID, let from = shown.firstIndex(of: token.noteID),
              let to = SidebarLayout.OpenListDrop.destination(gap: gap, dragged: from, rows: shown.count)
        else { return false }
        #if DEBUG
        lastLanding = Landing(from: from, to: to, animation: animation)
        #endif
        withAnimation(animation) {
            workspace.moveOpenNotes(fromOffsets: IndexSet(integer: from), toOffset: to)
        }
        return true
    }

    #if DEBUG
    /// The DEBUG oracle's landing: the move and the animation it rode (a pin
    /// reads the settle through it — an animation is not observable after the
    /// fact).
    struct Landing: Equatable {
        let from: Int
        let to: Int
        let animation: Animation?
    }

    /// The last landing, in this process.
    private(set) static var lastLanding: Landing?
    #endif
}

/// **An Open row's own drop** (U2d, P-U2d-1) — main's per-row Transferable
/// drop: `isTargeted` marks the row as the drag's target (the line at its top),
/// and the action lands the decoded token in the slot before THIS row, through
/// the door and its settle.
///
/// **VX-424:** the row's two HALVES (`OpenListRowHalves`, an overlay INSIDE
/// this modifier, so nearer the pointer) take every drop of this list's own
/// drag; this drop stays UNDER them as the row's floor — should a half ever not
/// be offered the drag, the row still takes it exactly as it did before VX-424
/// (the slot before it), never a dead row.
struct OpenListRowDrop: ViewModifier {
    let state: OpenListDragState
    /// The row's note — its name as a target and at the landing.
    let noteID: String
    /// VX-589: the rows the list draws (nil = the strip).
    var rows: [String]? = nil
    let workspace: WorkspaceModel

    func body(content: Content) -> some View {
        content
            .dropDestination(for: SidebarView.OpenNoteDragToken.self) { tokens, _ in
                OpenListDropDoor.perform(tokens, onto: .before(noteID), displayed: rows, state: state, workspace: workspace)
            } isTargeted: { targeted in
                state.targeted(.before(noteID), targeted)
            }
    }
}

/// **VX-424 — an Open row's two HALVES**, each its own drop on main's road
/// (the classic `dropDestination(…isTargeted:)` her hands have used, and the
/// end zone's own shape: a clear, shaped view): the UPPER half names the slot
/// BEFORE the row, the LOWER half the slot AFTER it. The half IS the target, so
/// no pointer location is needed while hovering (the macOS 26 session form that
/// would carry one was never offered a real drag — U2b/U2c). Together they cover
/// the row and reach the list's side margins (`reach`), which were dead room.
///
/// **Live only while THIS list's own drag is in flight** —
/// `state.dragInFlight(among:)`: a drag began here (`state.dragging`, set when
/// the drag begins, cleared at its session's end or its drop) AND its row is
/// still drawn (the VX-439 ladder's m-7 — a row gone mid-drag stands the halves
/// down even if its session's end never arrives): at rest the halves take no
/// hits, so every door of the row — the click, the ✕, the right-click, the
/// title's hover scroll, the drag itself — is exactly as it was; and a drag
/// that began elsewhere (another window's list, a file) never meets them.
struct OpenListRowHalves: View {
    let state: OpenListDragState
    let noteID: String
    /// VX-589: the rows the list draws (nil = the strip).
    var rows: [String]? = nil
    let workspace: WorkspaceModel
    /// The side margin the halves reach into on each side (the list's rows sit
    /// inside the scroll content's padding).
    let reach: CGFloat
    #if DEBUG
    /// The DEBUG oracle's tap: the two halves as laid out (global), upper first.
    var report: ((CGRect, CGRect) -> Void)? = nil
    @State private var upper: CGRect = .zero
    @State private var lower: CGRect = .zero
    #endif

    var body: some View {
        VStack(spacing: 0) {
            half(.before(noteID))
                #if DEBUG
                .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: {
                    upper = $0
                    report?(upper, lower)
                }
                #endif
            half(.after(noteID))
                #if DEBUG
                .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: {
                    lower = $0
                    report?(upper, lower)
                }
                #endif
        }
        .padding(.horizontal, -reach)
        // The ladder's m-7: in flight = began here AND its row still drawn.
        .allowsHitTesting(state.dragInFlight(among: rows ?? workspace.openNotes.shown))
        .accessibilityHidden(true)
    }

    private func half(_ target: OpenListDragState.Target) -> some View {
        Color.clear
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .dropDestination(for: SidebarView.OpenNoteDragToken.self) { tokens, _ in
                OpenListDropDoor.perform(tokens, onto: target, displayed: rows, state: state, workspace: workspace)
            } isTargeted: { targeted in
                state.targeted(target, targeted)
            }
    }
}

/// **The END ZONE's drop** (U2d, P-U2d-1) — the same kind of drop; anywhere in
/// it names the slot after the last row.
struct OpenListEndZoneDrop: ViewModifier {
    let state: OpenListDragState
    /// VX-589: the rows the list draws (nil = the strip).
    var rows: [String]? = nil
    let workspace: WorkspaceModel

    func body(content: Content) -> some View {
        content
            .dropDestination(for: SidebarView.OpenNoteDragToken.self) { tokens, _ in
                OpenListDropDoor.perform(tokens, onto: .end, displayed: rows, state: state, workspace: workspace)
            } isTargeted: { targeted in
                state.targeted(.end, targeted)
            }
    }
}

/// **The insertion line** — an overlay over the list's scroll view, drawn
/// above the edge fade (the fade must never dim the line), across the rows'
/// width, taking no hits (the drops underneath stay the rows').
struct OpenListInsertionLine: View {
    let state: OpenListDragState
    let rows: [String]
    let rowHeight: CGFloat
    /// The rows' side margin inside the scroll view — the line spans the rows.
    let inset: CGFloat
    let color: Color
    #if DEBUG
    /// The DEBUG oracle's tap: the line as drawn (global), nil when none is.
    var report: ((CGRect?) -> Void)? = nil
    #endif

    var body: some View {
        ZStack(alignment: .topLeading) {
            if let top = state.lineTop(rows: rows, rowHeight: rowHeight) {
                Rectangle()
                    .fill(color)
                    .frame(height: SidebarLayout.OpenListDrop.lineThickness)
                    #if DEBUG
                    .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { report?($0) }
                    .onDisappear { report?(nil) }
                    #endif
                    // Placed by LAYOUT (never `.offset`, which moves only the
                    // drawing): the line's frame is where it draws.
                    .padding(.horizontal, inset)
                    .padding(.top, top)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
