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
        #if DEBUG
        OpenListDragTrace.note("STATE began row=\(noteID.prefix(8)) (dragging was \(OpenListDragTrace.short(dragging)))")
        #endif
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
        #if DEBUG
        OpenListDragTrace.note("STATE ended (dragging was \(OpenListDragTrace.short(dragging)))")
        #endif
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
        let lit = state.lineTop(rows: rows, rowHeight: rowHeight) != nil
        #if DEBUG
        // U2b's probe (`OpenListDragTrace`, marker flag `copy` — never set
        // outside the trace window): offer COPY where a line is drawn, to
        // test G2 (the source's copy-only mask) against G1's fix.
        if lit, OpenListDragTrace.has("copy") { return DropProposal(operation: .copy) }
        #endif
        return DropProposal(operation: lit ? .move : .forbidden)
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
        #if DEBUG
        OpenListDragTrace.note("DOOR perform gap=\(gap.map(String.init) ?? "nil") knownNothing=\(knownNothing)"
            + " providers=\(providers.count) types=\(providers.map(\.registeredTypeIdentifiers))")
        #endif
        state.ended()
        guard let gap, !knownNothing, let provider = providers.first else { return false }
        _ = provider.loadTransferable(type: SidebarView.OpenNoteDragToken.self) { result in
            #if DEBUG
            let outcome = OpenListDragTrace.outcome(result)
            Task { @MainActor in OpenListDragTrace.note("DOOR perform loadTransferable → \(outcome)") }
            #endif
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

/// The drop target over the list's ROWS — on the scroll content, so its
/// location is the rows' own space (row arithmetic needs no scroll offset).
struct OpenListRowsDrop: DropDelegate {
    let state: OpenListDragState
    let rows: [String]
    let rowHeight: CGFloat
    let workspace: WorkspaceModel

    func validateDrop(info: DropInfo) -> Bool {
        let valid = info.hasItemsConforming(to: OpenListDropDoor.types)
        #if DEBUG
        OpenListDragTrace.note("ROWS validateDrop → \(valid) · \(OpenListDragTrace.describe(info))"
            + " · \(OpenListDragTrace.gate(state, rows: rows, rowHeight: rowHeight))")
        #endif
        return valid
    }

    func dropEntered(info: DropInfo) {
        state.hoverRows(contentY: info.location.y)
        #if DEBUG
        OpenListDragTrace.note("ROWS dropEntered · \(OpenListDragTrace.describe(info))"
            + " · \(OpenListDragTrace.gate(state, rows: rows, rowHeight: rowHeight))")
        OpenListDragTrace.probeLoadIfAsked(info, site: "ROWS")
        #endif
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        state.hoverRows(contentY: info.location.y)
        let proposal = OpenListDropDoor.proposal(state, rows: rows, rowHeight: rowHeight)
        #if DEBUG
        OpenListDragTrace.updated("ROWS", proposal: proposal, info: info,
                                  gate: OpenListDragTrace.gate(state, rows: rows, rowHeight: rowHeight))
        #endif
        return proposal
    }

    func dropExited(info: DropInfo) {
        state.leftRows()
        #if DEBUG
        OpenListDragTrace.note("ROWS dropExited · \(OpenListDragTrace.gate(state, rows: rows, rowHeight: rowHeight))")
        #endif
    }

    func performDrop(info: DropInfo) -> Bool {
        state.hoverRows(contentY: info.location.y)
        #if DEBUG
        OpenListDragTrace.note("ROWS performDrop · \(OpenListDragTrace.describe(info))"
            + " · \(OpenListDragTrace.gate(state, rows: rows, rowHeight: rowHeight))")
        #endif
        let accepted = OpenListDropDoor.perform(
            info.itemProviders(for: OpenListDropDoor.types), state: state, rows: rows,
            rowHeight: rowHeight, workspace: workspace)
        #if DEBUG
        OpenListDragTrace.note("ROWS performDrop → \(accepted)")
        #endif
        return accepted
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
        let valid = info.hasItemsConforming(to: OpenListDropDoor.types)
        #if DEBUG
        OpenListDragTrace.note("END validateDrop → \(valid) · \(OpenListDragTrace.describe(info))"
            + " · \(OpenListDragTrace.gate(state, rows: rows, rowHeight: rowHeight))")
        #endif
        return valid
    }

    func dropEntered(info: DropInfo) {
        state.hoverEnd()
        #if DEBUG
        OpenListDragTrace.note("END dropEntered · \(OpenListDragTrace.describe(info))"
            + " · \(OpenListDragTrace.gate(state, rows: rows, rowHeight: rowHeight))")
        OpenListDragTrace.probeLoadIfAsked(info, site: "END")
        #endif
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        state.hoverEnd()
        let proposal = OpenListDropDoor.proposal(state, rows: rows, rowHeight: rowHeight)
        #if DEBUG
        OpenListDragTrace.updated("END", proposal: proposal, info: info,
                                  gate: OpenListDragTrace.gate(state, rows: rows, rowHeight: rowHeight))
        #endif
        return proposal
    }

    func dropExited(info: DropInfo) {
        state.leftEnd()
        #if DEBUG
        OpenListDragTrace.note("END dropExited · \(OpenListDragTrace.gate(state, rows: rows, rowHeight: rowHeight))")
        #endif
    }

    func performDrop(info: DropInfo) -> Bool {
        state.hoverEnd()
        #if DEBUG
        OpenListDragTrace.note("END performDrop · \(OpenListDragTrace.describe(info))"
            + " · \(OpenListDragTrace.gate(state, rows: rows, rowHeight: rowHeight))")
        #endif
        let accepted = OpenListDropDoor.perform(
            info.itemProviders(for: OpenListDropDoor.types), state: state, rows: rows,
            rowHeight: rowHeight, workspace: workspace)
        #if DEBUG
        OpenListDragTrace.note("END performDrop → \(accepted)")
        #endif
        return accepted
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

/// **U2b — the trace leg's instrument** (DEBUG only; the VX-283 run, VX-288 —
/// the drag that never lands). OFF unless the marker file
/// `<container>/Library/Caches/vx283-u2b-drag.on` exists; the trace window's
/// `pre` writes it and its `restore` removes it, so no test run and no other
/// launch ever writes a line. Every line goes to BOTH
/// `<container>/Library/Caches/vx283-u2b-drag.log` and the unified log
/// (subsystem `io.lduarte.variorum.vx283-u2b`, category `openListDrag`, level
/// notice), so it interleaves with AppKit's own `DragAndDrop` lines.
///
/// The marker's words are FLAGS, read on every call (the window changes them
/// between drags): `trace` observes only. Three PROBES test the fix's halves
/// without building one (T1's G1 and G2; none is product behaviour, none
/// ships): `load` — a delegate's `dropEntered` loads the payload at once, so
/// the source's payload closure (and `began`) runs WHILE the drag hovers;
/// `copy` — the proposal offers `.copy` where it would offer `.move`; and two
/// SOURCE flags read once at LAUNCH (a modifier is attached at body time):
/// `session` logs `onDragSessionUpdated`'s phases on each Open row, and
/// `allowmove` attaches `DragConfiguration(allowMove: true)` to them. The
/// architect's ruling decides whether any of it stays.
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

    /// The flags as the process LAUNCHED — the source-side probes attach a
    /// modifier at body time, so they read once and hold for the process.
    static let launchFlags: Set<String> = flags ?? []

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

    private static func hoverText(_ hover: SidebarLayout.OpenListDrop.Hover?) -> String {
        switch hover {
        case nil: "nil"
        case .rows(let viewportY)?: "rows(vy \(number(viewportY)))"
        case .end?: "end"
        }
    }

    /// The gate's inputs — everything `lineTop` and the proposal read.
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

    /// What the drop info carries — types only, never data (reading the data
    /// would resolve the payload's promise and change the road under trace).
    static func describe(_ info: DropInfo) -> String {
        let types = NSPasteboard(name: .drag).types?.map(\.rawValue) ?? []
        return "loc=(\(number(info.location.x)),\(number(info.location.y)))"
            + " conforms=\(info.hasItemsConforming(to: OpenListDropDoor.types)) dragPboard=\(types)"
    }

    nonisolated static func outcome(_ result: Result<SidebarView.OpenNoteDragToken, any Error>) -> String {
        switch result {
        case .success(let token): "success row=\(token.noteID.prefix(8)) list=\(token.listID.prefix(8))"
        case .failure(let error): "FAILURE \(error)"
        }
    }

    private static var lastUpdated: [String: String] = [:]
    private static var repeats: [String: Int] = [:]

    /// `dropUpdated` fires on every tracking tick — one line per CHANGE of
    /// what it answers, with the number of identical ticks folded into it.
    static func updated(_ site: String, proposal: DropProposal, info: DropInfo, gate: String) {
        let line = "\(site) dropUpdated → \(proposal.operation) · \(gate)"
        if lastUpdated[site] == line {
            repeats[site, default: 0] += 1
            return
        }
        let folded = repeats[site] ?? 0
        lastUpdated[site] = line
        repeats[site] = 0
        note(line + " · loc=(\(number(info.location.x)),\(number(info.location.y)))"
            + (folded > 0 ? " · (previous answer repeated \(folded)×)" : ""))
    }

    // MARK: The probes

    /// `load`: read the payload while the drag hovers (G1's fix, tested).
    static func probeLoadIfAsked(_ info: DropInfo, site: String) {
        guard has("load") else { return }
        let providers = info.itemProviders(for: OpenListDropDoor.types)
        note("PROBE load at \(site) dropEntered: providers=\(providers.count)"
            + " types=\(providers.map(\.registeredTypeIdentifiers))")
        guard let provider = providers.first else { return }
        _ = provider.loadTransferable(type: SidebarView.OpenNoteDragToken.self) { result in
            let outcome = outcome(result)
            Task { @MainActor in note("PROBE load → \(outcome)") }
        }
    }

    /// `session`: what the drag session says on the row it began on.
    static func session(_ session: DragSession, noteID: String) {
        note("SESSION row=\(noteID.prefix(8)) phase=\(session.phase)"
            + " loc=(\(number(session.location.x)),\(number(session.location.y)))")
    }

    // MARK: Where things are (so the window can aim, and see what AppKit sees)

    /// The view chain AppKit hit-tests under the pointer, each view's
    /// registered drag types counted and marked where ours is among them.
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

/// U2b's SOURCE probes on an Open row (`session`, `allowmove` — read at
/// launch; with neither, the row is exactly as shipped).
struct OpenListDragTraceSource: ViewModifier {
    let noteID: String

    @ViewBuilder
    func body(content: Content) -> some View {
        let flags = OpenListDragTrace.launchFlags
        let noteID = noteID
        if flags.contains("session"), flags.contains("allowmove") {
            content
                .onDragSessionUpdated { OpenListDragTrace.session($0, noteID: noteID) }
                .dragConfiguration(DragConfiguration(allowMove: true))
        } else if flags.contains("session") {
            content.onDragSessionUpdated { OpenListDragTrace.session($0, noteID: noteID) }
        } else if flags.contains("allowmove") {
            content.dragConfiguration(DragConfiguration(allowMove: true))
        } else {
            content
        }
    }
}
#endif
