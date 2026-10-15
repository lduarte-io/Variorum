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
//  The traced bug under the jank (the U2 record): each row was its own drop
//  target and every drop landed in the gap BEFORE the row under the pointer,
//  whatever half of it — the row just below was unreachable, every downward
//  drop landed one row short, the last slot could not be reached, the move did
//  not animate and nothing showed where a drop would land. Now:
//
//  · ONE drop target over the list's rows (`OpenListRowsDrop`, on the scroll
//    CONTENT, so a drop's location is the rows' own space and the half of the
//    row under the pointer decides — `SidebarLayout.OpenListDrop`, pure), plus
//    an END ZONE under the rows when the column has room for one
//    (`OpenListEndZoneDrop`).
//  · THE LINE — 2 pt in the ring token, the book navigator's precedent — drawn
//    as an OVERLAY over the list (above the edge fade, taking no hits), placed
//    from the pointer's place in the VIEWPORT, the list's scroll window, the
//    rows and the pitch, so it re-derives on every input axis (hover, scroll,
//    list change; the overlay/sink delivery law) and never before a reading
//    exists. It lights only where a drop would act (§12's false-offer rule):
//    never at the dragged row's own two gaps, never for a drag that did not
//    begin in this list.
//  · THE SETTLE — the move lands inside an animation on the column's one beat.
//  · A drop acts only on the list its drag began in (the token carries the
//    list's id — P-U2-3).
//
//  What a drop does to the scrolling section's FOLLOW state (U1d): nothing
//  (P-U2-1). A drop is neither one of her acts (it changes no current row) nor
//  a hand scroll (it reports no scroll phase), and it never scrolls the list:
//  the rows rearrange in place under the pointer, a following list keeps
//  following, a list she scrolled stays where she put it.
//

import SwiftUI
import UniformTypeIdentifiers

/// **One Open list's drag, as it stands** — which row a drag of THIS list's
/// began on, where it points over the list, and the list's scroll window as the
/// line reads it. Held by the column (`SidebarView`); the line and the two drop
/// targets read and write it. Observed, so the LINE re-renders on a change —
/// and only the line: the window is copied in only while a drag hovers, so an
/// ordinary scroll re-renders nothing.
@MainActor
@Observable
final class OpenListDragState {
    /// This list's name on its drags' payload (P-U2-3).
    @ObservationIgnored let listID = UUID().uuidString
    /// The row a drag of this list's began on; nil when none is in flight here.
    private(set) var dragging: String?
    /// Where that drag points over this list; nil while it is elsewhere.
    private(set) var hover: SidebarLayout.OpenListDrop.Hover?
    /// The list's scroll window, as the line reads it (current only while a
    /// drag hovers).
    private(set) var window = SidebarLayout.ScrollWindow.unmeasured
    /// The list's window as last read, whatever is in flight.
    @ObservationIgnored private var latest = SidebarLayout.ScrollWindow.unmeasured

    /// A drag began on `noteID`'s row (`draggable`'s payload runs then).
    ///
    /// **A known edge** (the U2 record; the VX-283 ladder's R1-4): only a drop
    /// on THIS list's own targets clears `dragging` (`ended()`, in
    /// `OpenListDropDoor.perform`). A drag released anywhere else leaves it
    /// stale until this list's next drag begins here. Harmless on its own —
    /// the hover clears on exit, and a drop is decided by the PAYLOAD's list
    /// id — except that a row dragged in from ANOTHER window's list meanwhile
    /// reads as a drag of this list's: the line draws, the drop is accepted,
    /// and `land` then refuses the foreign payload, so nothing moves and the
    /// image does not slide back. Deliberately not cleared from the drag
    /// session's end (`onDragSessionUpdated`): its order against
    /// `performDrop` is unverified, and the wrong order would break every
    /// drop. No deterministic pin short of a fake drag session.
    func began(_ noteID: String) {
        dragging = noteID
        if hover != nil { hover = nil }
    }

    /// The list's scroll view reported a reading — the line's scroll axis.
    func read(_ reading: SidebarLayout.ScrollWindow) {
        latest = reading
        if hover != nil, window != reading { window = reading }
    }

    /// The drag points over the rows at `contentY` (the rows' own space) —
    /// held as its place in the VIEWPORT, so a later scroll under a still
    /// pointer moves the gap it names.
    func hoverRows(contentY: CGFloat) {
        if window != latest { window = latest }
        let now = SidebarLayout.OpenListDrop.Hover.rows(viewportY: contentY - latest.offset)
        if hover != now { hover = now }
    }

    /// The drag points over the end zone.
    func hoverEnd() {
        if window != latest { window = latest }
        if hover != .end { hover = .end }
    }

    /// The drag left the rows (a move into the end zone keeps the zone's).
    func leftRows() {
        if case .rows = hover { hover = nil }
    }

    /// The drag left the end zone (a move onto the rows keeps theirs).
    func leftEnd() {
        if hover == .end { hover = nil }
    }

    /// The drag is over — dropped here.
    func ended() {
        if dragging != nil { dragging = nil }
        if hover != nil { hover = nil }
    }

    /// The gap the drag names now.
    func gap(rows: Int, rowHeight: CGFloat) -> Int? {
        guard let hover else { return nil }
        return SidebarLayout.OpenListDrop.gap(
            for: hover, offset: window.offset, rowHeight: rowHeight, rows: rows)
    }

    /// The line's top in the list's viewport — nil where none is drawn.
    func lineTop(rows: [String], rowHeight: CGFloat) -> CGFloat? {
        SidebarLayout.OpenListDrop.lineTop(
            hover: hover, dragged: dragging.flatMap { rows.firstIndex(of: $0) },
            rows: rows.count, rowHeight: rowHeight, window: window)
    }
}

/// **The drop's door** — what the two targets share, and the one act a pin
/// drives (a `DropInfo` cannot be made outside SwiftUI).
@MainActor
enum OpenListDropDoor {
    /// The payload type both targets accept — the row's own transfer type, so
    /// nothing else (text, files: the column's import drop) ever lights them.
    static var types: [UTType] { [SidebarView.OpenNoteDragToken.contentType] }

    /// **The settle** — the move lands on the column's one beat
    /// (`SidebarLayout.railTransition`), with a snap: her *"a nice fit / snap
    /// into place"*. PROVISIONAL P-U2-4.
    static var settle: Animation { .snappy(duration: SidebarLayout.railTransition) }

    /// What the drop offers where the drag now points: a move where the line
    /// is drawn; nothing (the image slides back) where a drop would change
    /// nothing.
    static func proposal(_ state: OpenListDragState, rows: [String], rowHeight: CGFloat) -> DropProposal {
        DropProposal(operation: state.lineTop(rows: rows, rowHeight: rowHeight) != nil ? .move : .forbidden)
    }

    /// The release: the gap the drag names at the moment of the drop (the
    /// line she saw), the payload read, and `land` — on the payload's word,
    /// not the hover state's (a drop never depends on the drag having been
    /// seen to begin).
    ///
    /// **The same known edge, from this side** (`OpenListDragState.began`;
    /// the VX-283 ladder's R1-4): the answer is given BEFORE the payload is
    /// read, so a drop accepted here can still land nothing — a foreign
    /// payload drawn a line by a stale `dragging`, a `loadTransferable` that
    /// fails, or a `land` that re-validates against the rows as they stand
    /// by then and finds no move. Each is accepted and silent: no slide-back,
    /// no message. No deterministic pin short of a failing item provider.
    static func perform(
        _ providers: [NSItemProvider], state: OpenListDragState, rows: [String], rowHeight: CGFloat,
        workspace: WorkspaceModel
    ) -> Bool {
        let gap = state.gap(rows: rows.count, rowHeight: rowHeight)
        let knownNothing = state.dragging != nil && state.lineTop(rows: rows, rowHeight: rowHeight) == nil
        let listID = state.listID
        state.ended()
        guard let gap, !knownNothing, let provider = providers.first else { return false }
        _ = provider.loadTransferable(type: SidebarView.OpenNoteDragToken.self) { result in
            guard case .success(let token) = result else { return }
            Task { @MainActor in land(token, atGap: gap, listID: listID, in: workspace) }
        }
        return true
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
        withAnimation(animation) {
            workspace.moveOpenNotes(fromOffsets: IndexSet(integer: from), toOffset: to)
        }
        return true
    }
}

/// The drop target over the list's ROWS — on the scroll content, so its
/// location is the rows' own space (row arithmetic needs no scroll offset).
struct OpenListRowsDrop: DropDelegate {
    let state: OpenListDragState
    let rows: [String]
    let rowHeight: CGFloat
    let workspace: WorkspaceModel

    func validateDrop(info: DropInfo) -> Bool {
        info.hasItemsConforming(to: OpenListDropDoor.types)
    }

    func dropEntered(info: DropInfo) {
        state.hoverRows(contentY: info.location.y)
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        state.hoverRows(contentY: info.location.y)
        return OpenListDropDoor.proposal(state, rows: rows, rowHeight: rowHeight)
    }

    func dropExited(info: DropInfo) {
        state.leftRows()
    }

    func performDrop(info: DropInfo) -> Bool {
        state.hoverRows(contentY: info.location.y)
        return OpenListDropDoor.perform(
            info.itemProviders(for: OpenListDropDoor.types), state: state, rows: rows,
            rowHeight: rowHeight, workspace: workspace)
    }
}

/// The END ZONE's drop target — anywhere in it names the slot after the last
/// row.
struct OpenListEndZoneDrop: DropDelegate {
    let state: OpenListDragState
    let rows: [String]
    let rowHeight: CGFloat
    let workspace: WorkspaceModel

    func validateDrop(info: DropInfo) -> Bool {
        info.hasItemsConforming(to: OpenListDropDoor.types)
    }

    func dropEntered(info: DropInfo) {
        state.hoverEnd()
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        state.hoverEnd()
        return OpenListDropDoor.proposal(state, rows: rows, rowHeight: rowHeight)
    }

    func dropExited(info: DropInfo) {
        state.leftEnd()
    }

    func performDrop(info: DropInfo) -> Bool {
        state.hoverEnd()
        return OpenListDropDoor.perform(
            info.itemProviders(for: OpenListDropDoor.types), state: state, rows: rows,
            rowHeight: rowHeight, workspace: workspace)
    }
}

/// **The insertion line** — an overlay over the list's scroll view, drawn
/// above the edge fade (the fade must never dim the line), across the rows'
/// width, taking no hits (the drop underneath stays the rows').
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
