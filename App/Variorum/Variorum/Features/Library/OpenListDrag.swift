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
//  · EACH ROW IS ITS OWN DROP (`OpenListRowDrop`), a Transferable
//    `dropDestination` in the macOS 26 SESSION form, plus an END ZONE under
//    the rows when the column has room for one (`OpenListEndZoneDrop`, the
//    same kind of drop). A row's session reports the pointer in the ROW's own
//    space; its index × the pitch places it in the rows' space, where the half
//    of the row under the pointer decides (`SidebarLayout.OpenListDrop`, pure).
//    **U2c (the orchestrator's P-U2b-1):** U2 first built ONE legacy
//    `onDrop(of:delegate:)` on the scroll content's root, and under a real
//    system drag AppKit never offered it the drag (U2b's trace: zero
//    `validateDrop`, the source working); every live drop inside scroll content
//    in this app is a per-row Transferable `dropDestination`, so the rows are
//    the targets again — with the location, not the row alone, deciding.
//  · THE OPERATION: the drop's configuration answers MOVE where the line is
//    drawn and FORBIDDEN elsewhere (the image slides back), and the row's
//    SOURCE allows a move (`DragConfiguration(allowMove: true)` — macOS's
//    Transferable source is copy-only by default, and AppKit intersects the
//    destination's operation with the source's).
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
//  · The drag SESSION's end — wherever the release fell — clears the list's
//    drag (U2's known edge, closed at U2c).
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
/// line reads it. Held by the column (`SidebarView`); the line and the drops
/// read and write it. Observed, so the LINE re-renders on a change — and only
/// the line: the window is copied in only while a drag hovers, so an ordinary
/// scroll re-renders nothing.
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
    /// The row whose drop session wrote the hover (U2c — each row is its own
    /// drop, so one row's late EXIT must never clear the next row's hover).
    @ObservationIgnored private var rowSource: Int?

    /// A drag began on `noteID`'s row (`draggable`'s payload runs then — U2b's
    /// trace proved it: on the main thread, at the drag's start).
    ///
    /// Cleared by the drag SESSION's end wherever the release fell
    /// (`dragSessionUpdated`), and by a drop on this list (`ended()`, in
    /// `OpenListDropDoor.perform`) — the two may arrive in either order, and
    /// neither decides the drop (U2c; before it, a release elsewhere left this
    /// stale — the VX-283 ladder's R1-4).
    func began(_ noteID: String) {
        #if DEBUG
        OpenListDragTrace.note("STATE began row=\(noteID.prefix(8)) (dragging was \(OpenListDragTrace.short(dragging)))")
        #endif
        dragging = noteID
        rowSource = nil
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

    /// **U2c (P-U2b-1):** the drag points over row `index`, `yInRow` down it
    /// (its drop session's location, in the row's own space) — mapped into the
    /// rows' space by the pure rule.
    func hoverRow(_ index: Int, yInRow: CGFloat, rowHeight: CGFloat) {
        hoverRows(contentY: SidebarLayout.OpenListDrop.contentY(row: index, yInRow: yInRow, rowHeight: rowHeight))
        rowSource = index
    }

    /// The drag left row `index` — the hover clears only if that row wrote it
    /// (the next row's entry may arrive before this exit).
    func leftRow(_ index: Int) {
        guard rowSource == index else { return }
        leftRows()
    }

    /// The drag points over the end zone.
    func hoverEnd() {
        if window != latest { window = latest }
        rowSource = nil
        if hover != .end { hover = .end }
    }

    /// The drag left the rows (a move into the end zone keeps the zone's).
    func leftRows() {
        rowSource = nil
        if case .rows = hover { hover = nil }
    }

    /// The drag left the end zone (a move onto the rows keeps theirs).
    func leftEnd() {
        if hover == .end { hover = nil }
    }

    /// **U2c (P-U2b-1):** the row's drag SESSION moved on (the source's
    /// `onDragSessionUpdated`) — its END, wherever the release fell, ends the
    /// drag; a session still in flight changes nothing.
    func dragSessionUpdated(_ phase: DragSession.Phase) {
        guard case .ended = phase else { return }
        #if DEBUG
        OpenListDragTrace.note("STATE the drag session ended (\(phase))")
        #endif
        ended()
    }

    /// The drag is over — dropped here, or its session ended.
    func ended() {
        #if DEBUG
        OpenListDragTrace.note("STATE ended (dragging was \(OpenListDragTrace.short(dragging)))")
        #endif
        rowSource = nil
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

/// **The drop's door** — what the drops share, and the acts a pin drives (a
/// `DropSession` cannot be made outside SwiftUI).
@MainActor
enum OpenListDropDoor {
    /// **The settle** — the move lands on the column's one beat
    /// (`SidebarLayout.railTransition`), with a snap: her *"a nice fit / snap
    /// into place"*. PROVISIONAL P-U2-4.
    static var settle: Animation { .snappy(duration: SidebarLayout.railTransition) }

    /// What the drop offers where the drag now points: a move where the line
    /// is drawn; nothing (the image slides back) where a drop would change
    /// nothing.
    static func proposal(_ state: OpenListDragState, rows: [String], rowHeight: CGFloat) -> DropProposal {
        let lit = state.lineTop(rows: rows, rowHeight: rowHeight) != nil
        #if DEBUG
        // The instrument's diagnostic (`OpenListDragTrace`, marker flag `copy`
        // — never set outside a trace window): offer COPY where a line is
        // drawn, to tell a refused move (the source's mask) from a drop that
        // never arrives.
        if lit, OpenListDragTrace.has("copy") { return DropProposal(operation: .copy) }
        #endif
        return DropProposal(operation: lit ? .move : .forbidden)
    }

    /// **U2c (P-U2b-1): the drop's configuration** — the session form's answer,
    /// the same one decision as `proposal`.
    static func configuration(_ state: OpenListDragState, rows: [String], rowHeight: CGFloat) -> DropConfiguration {
        DropConfiguration(operation: proposal(state, rows: rows, rowHeight: rowHeight).operation)
    }

    /// The release: the gap the drag names at the moment of the drop (the line
    /// she saw — the action refreshes the hover from its own location first),
    /// and `land` — on the payload's word, not the hover state's (a drop never
    /// depends on the drag having been seen to begin, nor on the order of the
    /// source session's end against the drop).
    ///
    /// **U2c (P-U2b-1):** the tokens arrive DECODED (the Transferable drop
    /// decodes them before its action runs) — no item provider, no
    /// asynchronous load. The configuration has already refused where no line
    /// was drawn, so an accepted drop that lands nothing needs the rows to
    /// change under it between the last update and the release (`land`
    /// re-validates against the rows as they stand). Returns whether anything
    /// moved.
    @discardableResult
    static func perform(
        _ tokens: [SidebarView.OpenNoteDragToken], state: OpenListDragState, rows: [String], rowHeight: CGFloat,
        workspace: WorkspaceModel, animation: Animation? = settle
    ) -> Bool {
        let gap = state.gap(rows: rows.count, rowHeight: rowHeight)
        let knownNothing = state.dragging != nil && state.lineTop(rows: rows, rowHeight: rowHeight) == nil
        #if DEBUG
        OpenListDragTrace.note("DOOR perform gap=\(gap.map(String.init) ?? "nil") knownNothing=\(knownNothing)"
            + " tokens=\(tokens.map { "\($0.noteID.prefix(8))@\($0.listID.prefix(8))" })")
        #endif
        state.ended()
        guard let gap, !knownNothing, let token = tokens.first else { return false }
        return land(token, atGap: gap, listID: state.listID, in: workspace, animation: animation)
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
        else {
            #if DEBUG
            OpenListDragTrace.note("DOOR land REFUSED row=\(token.noteID.prefix(8)) gap=\(gap)"
                + " listMatch=\(token.listID == listID) inRows=\(shown.contains(token.noteID))")
            #endif
            return false
        }
        #if DEBUG
        OpenListDragTrace.note("DOOR land row=\(token.noteID.prefix(8)) from=\(from) to=\(to) of \(shown.count)")
        #endif
        withAnimation(animation) {
            workspace.moveOpenNotes(fromOffsets: IndexSet(integer: from), toOffset: to)
        }
        return true
    }
}

/// **An Open row's drop** (U2c, P-U2b-1) — the Transferable road, in the
/// macOS 26 SESSION form: the session's location (the ROW's own space) feeds
/// the hover through the row's index, the configuration answers the door's
/// operation, and the action lands the decoded token at the gap the line named.
struct OpenListRowDrop: ViewModifier {
    let state: OpenListDragState
    /// The row's index in the list (`rows`).
    let index: Int
    let rows: [String]
    let rowHeight: CGFloat
    let workspace: WorkspaceModel

    func body(content: Content) -> some View {
        content
            .dropDestination(for: SidebarView.OpenNoteDragToken.self, isEnabled: true) { tokens, session in
                state.hoverRow(index, yInRow: session.location.y, rowHeight: rowHeight)
                #if DEBUG
                OpenListDragTrace.action(site, session, tokens: tokens,
                                         gate: OpenListDragTrace.gate(state, rows: rows, rowHeight: rowHeight))
                #endif
                OpenListDropDoor.perform(tokens, state: state, rows: rows, rowHeight: rowHeight, workspace: workspace)
            }
            .onDropSessionUpdated { session in
                switch session.phase {
                case .entering, .active: state.hoverRow(index, yInRow: session.location.y, rowHeight: rowHeight)
                default: state.leftRow(index)  // exiting, ended, the transfer done
                }
                #if DEBUG
                OpenListDragTrace.dropSession(site, session, state: state, rows: rows, rowHeight: rowHeight)
                #endif
            }
            .dropConfiguration { session in
                // The order of a tick's update and configuration is the
                // framework's: the hover is refreshed here too (idempotent).
                if session.phase == .entering || session.phase == .active {
                    state.hoverRow(index, yInRow: session.location.y, rowHeight: rowHeight)
                }
                let configuration = OpenListDropDoor.configuration(state, rows: rows, rowHeight: rowHeight)
                #if DEBUG
                OpenListDragTrace.configured(site, configuration.operation, session,
                                             state: state, rows: rows, rowHeight: rowHeight)
                #endif
                return configuration
            }
    }

    #if DEBUG
    private var site: String { "ROW n=\(index + 1)" }
    #endif
}

/// **The END ZONE's drop** (U2c, P-U2b-1) — the same Transferable session
/// form; anywhere in it names the slot after the last row.
struct OpenListEndZoneDrop: ViewModifier {
    let state: OpenListDragState
    let rows: [String]
    let rowHeight: CGFloat
    let workspace: WorkspaceModel

    func body(content: Content) -> some View {
        content
            .dropDestination(for: SidebarView.OpenNoteDragToken.self, isEnabled: true) { tokens, session in
                state.hoverEnd()
                #if DEBUG
                OpenListDragTrace.action("END", session, tokens: tokens,
                                         gate: OpenListDragTrace.gate(state, rows: rows, rowHeight: rowHeight))
                #endif
                OpenListDropDoor.perform(tokens, state: state, rows: rows, rowHeight: rowHeight, workspace: workspace)
            }
            .onDropSessionUpdated { session in
                switch session.phase {
                case .entering, .active: state.hoverEnd()
                default: state.leftEnd()  // exiting, ended, the transfer done
                }
                #if DEBUG
                OpenListDragTrace.dropSession("END", session, state: state, rows: rows, rowHeight: rowHeight)
                #endif
            }
            .dropConfiguration { session in
                if session.phase == .entering || session.phase == .active { state.hoverEnd() }
                let configuration = OpenListDropDoor.configuration(state, rows: rows, rowHeight: rowHeight)
                #if DEBUG
                OpenListDragTrace.configured("END", configuration.operation, session,
                                             state: state, rows: rows, rowHeight: rowHeight)
                #endif
                return configuration
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
                    .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: {
                        report?($0)
                        OpenListDragTrace.note("LINE drawn at global \(OpenListDragTrace.rect($0))")
                    }
                    .onDisappear {
                        report?(nil)
                        OpenListDragTrace.note("LINE gone")
                    }
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

#if DEBUG
import AppKit
import os

/// **The Open list drag's instrument** (DEBUG only; the VX-283 run, VX-288 —
/// built at U2b's trace leg, KEPT and re-hooked into the session road at U2c by
/// the orchestrator's P-U2b-1, as the window's oracle). OFF unless the marker
/// file `<container>/Library/Caches/vx283-u2b-drag.on` exists; a trace
/// window's `pre` clears it, its launch writes it and its `restore` removes it,
/// so no test run and no other launch ever writes a line. Every line goes to
/// BOTH `<container>/Library/Caches/vx283-u2b-drag.log` and the unified log
/// (subsystem `io.lduarte.variorum.vx283-u2b`, category `openListDrag`, level
/// notice), so it interleaves with AppKit's own `DragAndDrop` lines.
///
/// What it logs at U2c: each row's and the end zone's drop SESSION updates
/// (phase, location, the rows'-space y, the gap, the line — one line per
/// change of what they decide, the repeats folded), the CONFIGURATION each
/// answered (folded the same way), the ACTION (its location and tokens), the
/// door's perform and land / land REFUSED, the line drawn / gone, the source's
/// payload, preview and drag-SESSION phases (with location), the state's
/// began / ended, the end zone laid out, the column's import drop, every Open
/// row's frame in SCREEN points (the window's aim) and the hover per row.
///
/// The marker's words are FLAGS, read on every call: `trace` observes only;
/// `copy` (a diagnostic, never product) makes the configuration offer COPY
/// where it would offer MOVE. U2b's other probes (`load`, `session`,
/// `allowmove`) retired with the delegates: the session hooks and `allowMove`
/// are the product now.
@MainActor
enum OpenListDragTrace {
    static let logName = "vx283-u2b-drag.log"
    static let markerName = "vx283-u2b-drag.on"
    static let subsystem = "io.lduarte.variorum.vx283-u2b"

    private static var caches: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }
    private static let logger = Logger(subsystem: subsystem, category: "openListDrag")
    private static let clock: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()

    /// The marker's flags now (`trace` always among them); nil = off.
    static var flags: Set<String>? {
        guard let text = try? String(contentsOf: caches.appending(path: markerName), encoding: .utf8)
        else { return nil }
        return Set(text.split(whereSeparator: \.isWhitespace).map(String.init)).union(["trace"])
    }

    static func has(_ flag: String) -> Bool { flags?.contains(flag) == true }

    static func note(_ line: @autoclosure () -> String) {
        guard let flags else { return }
        let text = clock.string(from: Date())
            + String(format: " %.4f", ProcessInfo.processInfo.systemUptime)
            + " [u2b \(flags.sorted().joined(separator: "+"))] " + line()
        logger.notice("\(text, privacy: .public)")
        let url = caches.appending(path: logName)
        let data = Data((text + "\n").utf8)
        if let handle = try? FileHandle(forWritingTo: url) {
            defer { try? handle.close() }
            _ = try? handle.seekToEnd()
            try? handle.write(contentsOf: data)
        } else {
            try? data.write(to: url)
        }
    }

    // MARK: The texts

    static func short(_ id: String?) -> String { id.map { String($0.prefix(8)) } ?? "nil" }

    static func number(_ value: CGFloat) -> String { String(format: "%.1f", Double(value)) }

    static func rect(_ rect: CGRect) -> String {
        "(\(number(rect.minX)),\(number(rect.minY)) \(number(rect.width))x\(number(rect.height)))"
    }

    static func point(_ point: CGPoint) -> String { "(\(number(point.x)),\(number(point.y)))" }

    private static func hoverText(_ hover: SidebarLayout.OpenListDrop.Hover?) -> String {
        switch hover {
        case nil: "nil"
        case .rows(let viewportY)?: "rows(vy \(number(viewportY)))"
        case .end?: "end"
        }
    }

    /// The gate's inputs — everything `lineTop` and the configuration read.
    static func gate(_ state: OpenListDragState, rows: [String], rowHeight: CGFloat) -> String {
        let dragged = state.dragging.flatMap { rows.firstIndex(of: $0) }
        let gap = state.gap(rows: rows.count, rowHeight: rowHeight)
        let top = state.lineTop(rows: rows, rowHeight: rowHeight)
        let window = state.window
        return "dragging=\(short(state.dragging)) draggedIndex=\(dragged.map(String.init) ?? "nil")"
            + " listID=\(state.listID.prefix(8)) hover=\(hoverText(state.hover))"
            + " window=(off \(number(window.offset)) vp \(number(window.viewport)) ct \(number(window.content))"
            + " measured \(window.isMeasured)) gap=\(gap.map(String.init) ?? "nil")"
            + " lineTop=\(top.map(number) ?? "nil") rows=\(rows.count) pitch=\(number(rowHeight))"
    }

    /// What a site's decision turns on — a fold key (the pointer's own place
    /// moves every tick; what it DECIDES changes rarely).
    private static func decision(_ state: OpenListDragState, rows: [String], rowHeight: CGFloat) -> String {
        let gap = state.gap(rows: rows.count, rowHeight: rowHeight)
        let top = state.lineTop(rows: rows, rowHeight: rowHeight)
        return "dragging=\(short(state.dragging)) gap=\(gap.map(String.init) ?? "nil") line=\(top.map(number) ?? "nil")"
    }

    private static var lastKey: [String: String] = [:]
    private static var repeats: [String: Int] = [:]

    /// One line per CHANGE of what a site decides, with the number of identical
    /// ticks between folded into it.
    private static func folded(_ site: String, key: String, _ line: () -> String) {
        guard flags != nil else { return }
        if lastKey[site] == key {
            repeats[site, default: 0] += 1
            return
        }
        let folded = repeats[site] ?? 0
        lastKey[site] = key
        repeats[site] = 0
        note(line() + (folded > 0 ? " · (previous answer repeated \(folded)×)" : ""))
    }

    /// A drop SESSION update at a row or the end zone (after the state took it).
    static func dropSession(
        _ site: String, _ session: DropSession, state: OpenListDragState, rows: [String], rowHeight: CGFloat
    ) {
        let key = "\(session.phase) " + decision(state, rows: rows, rowHeight: rowHeight)
        folded("\(site) session", key: key) {
            "\(site) DROP-SESSION phase=\(session.phase) loc=\(point(session.location))"
                + " suggested=\(session.suggestedOperations.rawValue) items=\(session.itemsCount)"
                + " · \(gate(state, rows: rows, rowHeight: rowHeight))"
        }
    }

    /// The configuration a site answered.
    static func configured(
        _ site: String, _ operation: DropOperation, _ session: DropSession, state: OpenListDragState,
        rows: [String], rowHeight: CGFloat
    ) {
        let key = "\(operation) " + decision(state, rows: rows, rowHeight: rowHeight)
        folded("\(site) config", key: key) {
            "\(site) CONFIG → \(operation) phase=\(session.phase) loc=\(point(session.location))"
                + " · \(gate(state, rows: rows, rowHeight: rowHeight))"
        }
    }

    /// A drop's ACTION ran (the tokens decoded), before the door.
    static func action(_ site: String, _ session: DropSession, tokens: [SidebarView.OpenNoteDragToken], gate: String) {
        note("\(site) ACTION phase=\(session.phase) loc=\(point(session.location))"
            + " tokens=\(tokens.map { "\($0.noteID.prefix(8))@\($0.listID.prefix(8))" }) · \(gate)")
    }

    /// The SOURCE's drag session, on the row it began on.
    static func session(_ session: DragSession, noteID: String) {
        note("SESSION row=\(noteID.prefix(8)) phase=\(session.phase)"
            + " loc=(\(number(session.location.x)),\(number(session.location.y)))")
    }

    // MARK: Where things are (so the window can aim, and see what AppKit sees)

    /// The view chain AppKit hit-tests under the pointer, each view's
    /// registered drag types counted and marked where ours is among them.
    /// (U2b's reading of it was corrected by the ruling on T3: on macOS 27
    /// SwiftUI's drop registration does not show through
    /// `registeredDraggedTypes` — it reads 0 under working targets too.)
    static func dumpHitChain(_ why: String) {
        guard flags != nil else { return }
        let mouse = NSEvent.mouseLocation
        guard let window = NSApp.orderedWindows.first(where: { $0.isVisible && $0.frame.contains(mouse) }) else {
            note("\(why) · hit-chain: no window under \(mouse)")
            return
        }
        let inWindow = window.convertPoint(fromScreen: mouse)
        guard let root = window.contentView?.superview ?? window.contentView,
              let hit = root.hitTest(inWindow) else {
            note("\(why) · hit-chain: nothing under \(mouse) in window \(window.windowNumber)")
            return
        }
        let ours = NSPasteboard.PasteboardType(SidebarView.OpenNoteDragToken.contentType.identifier)
        var chain: [String] = []
        var view: NSView? = hit
        while let current = view {
            let types = current.registeredDraggedTypes
            chain.append(String(String(describing: type(of: current)).prefix(60))
                + "[reg \(types.count)\(types.contains(ours) ? " +OURS" : "")]")
            view = current.superview
        }
        note("\(why) · hit-chain at screen \(mouse): " + chain.joined(separator: " ← "))
    }

    private static var rowFrames: [Int: (id: String, global: CGRect)] = [:]
    private static var observing = false

    /// An Open row's frame — logged in SCREEN points (cliclick's space: the
    /// main display's top-left origin), so the window's drags aim from it.
    static func row(ordinal: Int, noteID: String, global: CGRect) {
        guard flags != nil else { return }
        rowFrames[ordinal] = (noteID, global)
        if !observing {
            observing = true
            for name in [NSApplication.didBecomeActiveNotification, NSWindow.didBecomeKeyNotification] {
                NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { _ in
                    MainActor.assumeIsolated { relogRows() }
                }
            }
        }
        logRow(ordinal)
    }

    private static func relogRows() {
        for ordinal in rowFrames.keys.sorted() { logRow(ordinal) }
    }

    private static func logRow(_ ordinal: Int) {
        guard let entry = rowFrames[ordinal] else { return }
        guard let screen = screenRect(global: entry.global) else {
            note("ROW n=\(ordinal) id=\(entry.id.prefix(8)) screen=? global=\(rect(entry.global))")
            return
        }
        note("ROW n=\(ordinal) id=\(entry.id.prefix(8)) screen=\(Int(screen.minX.rounded())),"
            + "\(Int(screen.minY.rounded())),\(Int(screen.width.rounded())),\(Int(screen.height.rounded()))")
    }

    private static func screenRect(global: CGRect) -> CGRect? {
        let window = NSApp.mainWindow ?? NSApp.keyWindow
            ?? NSApp.orderedWindows.first(where: { $0.isVisible && $0.frame.width > 400 })
        guard let window, let content = window.contentView else { return nil }
        let topLeft = NSPoint(
            x: global.minX, y: content.isFlipped ? global.minY : content.bounds.height - global.minY)
        let onScreen = window.convertPoint(toScreen: content.convert(topLeft, to: nil))
        let primaryHeight = NSScreen.screens.first?.frame.height ?? 0
        return CGRect(x: onScreen.x, y: primaryHeight - onScreen.y, width: global.width, height: global.height)
    }

    /// A pointer arrived on an Open row (the window's aim check) — and what
    /// AppKit would hit-test there.
    static func hover(ordinal: Int, noteID: String) {
        guard flags != nil else { return }
        note("HOVER n=\(ordinal) id=\(noteID.prefix(8))")
        dumpHitChain("HOVER n=\(ordinal)")
    }
}
#endif
