//
//  SidebarSectionWindowTests.swift
//  VariorumTests
//
//  VX-283 run, U1b — the fix leg of U1, from the orchestrator's eye on U1's
//  walk:
//  · F-1 (the walker's O-1) — the note she had just opened could sit with its
//    highlighted Open-list row cut at the list's bottom edge. The reveal was
//    one minimal `scrollTo` per newest note, issued against whatever viewport
//    stood when it ran; the list's viewport is a function of measurements that
//    land a pass later, and returning to the note she was already in never
//    revealed at all (its recency did not change).
//  · F-2 (PROVISIONAL P-U1-6, the orchestrator's ruling) — a scrolled section
//    sliced its partial row through the letters under its header. Both
//    scrolling sections now fade each edge over about half a row, only where
//    content lies beyond it.
//
//  This file holds the PURE rules (`SidebarLayout`'s window brain). The
//  mounted pins — what the sections actually do in a window, red on old by
//  behavioural revert — are below them (the U1b record names the reverts).
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The pure rules

@Suite("U1b — a scrolling section's window: the edge fades (F-2) and the reveal (F-1)")
struct SidebarSectionWindowRuleTests {
    private typealias Window = SidebarLayout.ScrollWindow
    private typealias Fades = SidebarLayout.EdgeFades

    private let rowHeight: CGFloat = 30
    private var depth: CGFloat { SidebarLayout.edgeFadeDepth(rowHeight: rowHeight) }

    /// Twenty rows (600 pt) under a 250-pt window — eight and a third rows.
    private func window(at offset: CGFloat, viewport: CGFloat = 250, content: CGFloat = 600) -> Window {
        Window(offset: offset, viewport: viewport, content: content)
    }

    @Test func theFadeIsAboutHalfARow() {
        #expect(SidebarLayout.edgeFadeDepth(rowHeight: 30) == 15)
        #expect(SidebarLayout.edgeFadeDepth(rowHeight: 24) == 12)
    }

    /// The orchestrator's ruling, in its own words: the top fades only when
    /// scrolled down, the bottom only when more lies below.
    @Test func anEdgeFadesOnlyWhereContentLiesBeyondIt() {
        #expect(SidebarLayout.edgeFades(window(at: 0), depth: depth) == Fades(top: 0, bottom: 15),
                "at rest: nothing above, more below")
        #expect(SidebarLayout.edgeFades(window(at: 200), depth: depth) == Fades(top: 15, bottom: 15),
                "mid-list: more both ways")
        #expect(SidebarLayout.edgeFades(window(at: 350), depth: depth) == Fades(top: 15, bottom: 0),
                "at the end: more above, nothing below")
    }

    /// The depth is the content beyond the edge, capped at the half row — so
    /// the fade eases in as the list starts to move instead of popping in.
    @Test func theFadeEasesInWithTheContentBeyondTheEdge() {
        #expect(SidebarLayout.edgeFades(window(at: 4), depth: depth) == Fades(top: 4, bottom: 15))
        #expect(SidebarLayout.edgeFades(window(at: 342), depth: depth) == Fades(top: 15, bottom: 8))
        #expect(SidebarLayout.edgeFades(window(at: 0.3), depth: depth) == Fades(top: 0, bottom: 15),
                "a rounding hair beyond an edge is not more")
    }

    @Test func aWindowThatHoldsEverythingFadesNowhere() {
        #expect(SidebarLayout.edgeFades(window(at: 0, viewport: 250, content: 250), depth: depth) == .none)
        #expect(SidebarLayout.edgeFades(window(at: 0, viewport: 300, content: 250), depth: depth) == .none)
        #expect(SidebarLayout.edgeFades(.unmeasured, depth: depth) == .none)
    }

    @Test func aRowClearOfTheFadesIsLeftWhereItIs() {
        // Window 100…350 fades 100…115 and 335…350; row 5 is 150…180.
        #expect(SidebarLayout.revealOffset(
            row: 5, rows: 20, rowHeight: rowHeight, window: window(at: 100), depth: depth) == nil)
        // The first row at rest, the last at the end — nothing beyond either to fade.
        #expect(SidebarLayout.revealOffset(
            row: 0, rows: 20, rowHeight: rowHeight, window: window(at: 0), depth: depth) == nil)
        #expect(SidebarLayout.revealOffset(
            row: 19, rows: 20, rowHeight: rowHeight, window: window(at: 350), depth: depth) == nil)
    }

    /// **F-2 meets F-1:** a row wholly inside the viewport but under the
    /// bottom fade is NOT in view — it lands one fade's depth above the bottom
    /// edge, at an EXACT offset (P-U1b-6).
    @Test func aRowUnderTheBottomFadeLandsAtTheExactOffsetClearOfIt() {
        // Row 7 is 210…240; the bottom fade covers 235…250. 240 + 15 − 250 = 5.
        #expect(SidebarLayout.revealOffset(
            row: 7, rows: 20, rowHeight: rowHeight, window: window(at: 0), depth: depth) == 5)
    }

    @Test func aRowAboveLandsOneFadeBelowTheTop() {
        // Window 200…450; row 5 (150…180) lies above: 150 − 15 = 135.
        #expect(SidebarLayout.revealOffset(
            row: 5, rows: 20, rowHeight: rowHeight, window: window(at: 200), depth: depth) == 135)
    }

    @Test func theEndsLandOnTheEdgesAndTheOffsetStaysInsideTheContent() {
        #expect(SidebarLayout.revealOffset(
            row: 19, rows: 20, rowHeight: rowHeight, window: window(at: 0), depth: depth) == 350,
                "the last row: the content's end, 600 − 250")
        #expect(SidebarLayout.revealOffset(
            row: 0, rows: 20, rowHeight: rowHeight, window: window(at: 300), depth: depth) == 0,
                "the first row: the content's top")
        #expect(SidebarLayout.revealOffset(
            row: 18, rows: 20, rowHeight: rowHeight, window: window(at: 0), depth: depth) == 335,
                "the row before last keeps its half row of air: 570 + 15 − 250")
    }

    @Test func aWindowShorterThanARowShowsTheRowsTop() {
        let narrow = Window(offset: 0, viewport: 20, content: 600)
        #expect(SidebarLayout.revealOffset(
            row: 10, rows: 20, rowHeight: rowHeight, window: narrow, depth: depth) == 300)
    }

    /// **The pitch flip's two windows** (the re-run's red: Starred's ninth row
    /// after the column went 30 → 24). Each window answers its OWN exact
    /// offset — the 30-pt window 45, the 24-pt window 36 (its content's end) —
    /// so a reveal asked again on the new window's reading lands exactly,
    /// where an answer carried over from the old one would not.
    @Test func thePitchFlipsBeforeAndAfterWindowsEachAnswerExactly() {
        let before = Window(offset: 0, viewport: 225, content: 270)  // 9 rows at 30, 7.5 shown
        let after = Window(offset: 0, viewport: 180, content: 216)   // the same 9 at 24
        #expect(SidebarLayout.revealOffset(
            row: 8, rows: 9, rowHeight: 30, window: before,
            depth: SidebarLayout.edgeFadeDepth(rowHeight: 30)) == 45)
        let landed = SidebarLayout.revealOffset(
            row: 8, rows: 9, rowHeight: 24, window: after,
            depth: SidebarLayout.edgeFadeDepth(rowHeight: 24))
        #expect(landed == 36)
        #expect(SidebarLayout.revealOffset(
            row: 8, rows: 9, rowHeight: 24, window: Window(offset: 34, viewport: 180, content: 216),
            depth: SidebarLayout.edgeFadeDepth(rowHeight: 24)) == 36,
                "the re-run's resting place (34) is not clear, and the exact answer is the end")
        #expect(SidebarLayout.revealOffset(
            row: 8, rows: 9, rowHeight: 24, window: Window(offset: 36, viewport: 180, content: 216),
            depth: SidebarLayout.edgeFadeDepth(rowHeight: 24)) == nil, "…and from there nothing moves")
    }

    /// **Idempotent from every window:** every row lands wholly in view and
    /// clear of both fades, and a second reveal from the result moves nothing.
    @Test func everyRowLandsClearOfTheFadesFromAnyWindow() throws {
        for (viewport, rows, pitch) in [(CGFloat(250), 20, CGFloat(30)), (CGFloat(105), 20, CGFloat(30)),
                                        (CGFloat(225), 9, CGFloat(30)), (CGFloat(180), 9, CGFloat(24))] {
            let content = CGFloat(rows) * pitch
            let depth = SidebarLayout.edgeFadeDepth(rowHeight: pitch)
            for start in stride(from: CGFloat(0), through: max(0, content - viewport), by: 7) {
                let from = Window(offset: start, viewport: viewport, content: content)
                for row in 0..<rows {
                    var landed = from
                    if let target = SidebarLayout.revealOffset(
                        row: row, rows: rows, rowHeight: pitch, window: from, depth: depth) {
                        landed.offset = target
                    }
                    let fades = SidebarLayout.edgeFades(landed, depth: depth)
                    let top = CGFloat(row) * pitch
                    #expect(top >= landed.offset + fades.top - 0.5,
                            "row \(row) from \(start) (window \(viewport)): top \(top) under the top fade")
                    #expect(top + pitch <= landed.offset + viewport - fades.bottom + 0.5,
                            "row \(row) from \(start) (window \(viewport)): bottom under the bottom fade")
                    #expect(SidebarLayout.revealOffset(
                        row: row, rows: rows, rowHeight: pitch, window: landed, depth: depth) == nil,
                            "row \(row) from \(start): a second reveal moves nothing")
                }
            }
        }
    }

    @Test func nothingIsRevealedBeforeTheWindowIsMeasuredOrForARowThatIsNotThere() {
        #expect(SidebarLayout.revealOffset(
            row: 15, rows: 20, rowHeight: rowHeight, window: .unmeasured, depth: depth) == nil)
        #expect(SidebarLayout.revealOffset(
            row: 20, rows: 20, rowHeight: rowHeight, window: window(at: 0), depth: depth) == nil)
        #expect(SidebarLayout.revealOffset(
            row: -1, rows: 20, rowHeight: rowHeight, window: window(at: 0), depth: depth) == nil)
    }
}

// MARK: - The column's one transition beat (the orchestrator's ruling on P-U1b-5)

/// The scrolling sections ask their reveal a second time once the rail's
/// animated transition has settled (U1b's stage window: a reveal resolved
/// mid-transition rested short). The ruling: that wait is DERIVED from the
/// rail's own duration, named once — never a free-standing number that drifts
/// silently the day the motion changes.
@MainActor
@Suite("U1b — the column's one transition beat (P-U1b-5, ruled)")
struct SidebarTransitionBeatTests {
    private static var appRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
    }

    /// Code lines only — a comment may name the beat's history.
    private func code(_ relative: String) throws -> [String] {
        try String(contentsOf: Self.appRoot.appendingPathComponent(relative), encoding: .utf8)
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map(String.init)
            .filter {
                let line = $0.trimmingCharacters(in: .whitespaces)
                return !line.hasPrefix("//") && !line.hasPrefix("*")
            }
    }

    @Test func theSecondRevealWaitsStrictlyPastTheRailsTransition() {
        #expect(SidebarLayout.transitionSettleMargin > 0)
        #expect(SidebarLayout.transitionSettle > SidebarLayout.railTransition)
        #expect(SidebarLayout.transitionSettle
                == SidebarLayout.railTransition + SidebarLayout.transitionSettleMargin)
        #expect(SidebarSectionWindow<String>.transitionSettle == .seconds(SidebarLayout.transitionSettle),
                "the section's wait is the derived settle, not a number of its own")
    }

    /// **A source read:** every animation in the sidebar column runs on the one
    /// beat — the rail's and the note box's arrival and departure — and no
    /// literal duration remains; the sections' wait reads the derived settle.
    @Test func theSidebarsRailAnimationsReadTheOneBeat() throws {
        let sidebar = try code("Variorum/Features/Library/SidebarView.swift")
        let animations = sidebar.filter { $0.contains(".animation(") }
        #expect(animations.contains { $0.contains("value: railPostID") }, "the rail's motion")
        #expect(animations.contains { $0.contains("value: noteBox == nil") }, "the note box's motion")
        for line in animations {
            #expect(line.contains("SidebarLayout.railTransition"),
                    "a sidebar animation off the shared beat: \(line)")
        }
        #expect(!sidebar.contains { $0.contains("duration: 0") || $0.contains("duration: 1") },
                "no literal duration in the column")
        let window = try code("Variorum/Features/Library/SidebarSectionWindow.swift")
        #expect(window.contains { $0.contains(".seconds(SidebarLayout.transitionSettle)") })
        #expect(!window.contains { $0.contains(".milliseconds(") || $0.contains("duration: 0") },
                "no free-standing wait in the section window")
    }
}

// MARK: - The mounted pins: what the sections actually DO in a window

/// The column, bound to the workspace exactly as `RootView.selectionBinding`
/// binds it: the sidebar reads the FOCUSED pane's selection, and a pick goes
/// through `WorkspaceModel.select` (the road `ShellRouter.adopt` ends on).
@MainActor
private struct SectionWindowHost: View {
    let session: AppSession
    let workspace: WorkspaceModel
    let stars: StarsModel
    let theme: ThemeStore
    /// The stand-in for the sync footer — `RootView.statusRows`' slot.
    let footerHeight: CGFloat

    var body: some View {
        SidebarView(
            session: session, model: LibraryViewModel(session: session),
            pool: PoolViewModel(session: session),
            workspace: workspace, stars: stars,
            selection: Binding(
                get: { workspace.selections[workspace.focusedPane] },
                set: { picked in if let picked { workspace.select(picked) } }),
            noteBox: nil,
            bottom: AnyView(Color.clear.frame(height: footerHeight)))
            .frame(width: 230)
            .environment(theme)
    }
}

/// One mounted column and the doors a pin drives it through.
@MainActor
private final class SectionRig {
    let session: AppSession
    let workspace: WorkspaceModel
    let window: NSWindow
    let hosting: NSView
    let key: String
    private(set) var notes: [String]

    init(session: AppSession, workspace: WorkspaceModel, window: NSWindow, hosting: NSView, notes: [String]) {
        self.session = session
        self.workspace = workspace
        self.window = window
        self.hosting = hosting
        self.key = SidebarGeometry.bodyKey(for: workspace)
        self.notes = notes
    }

    /// A synchronous turn of the run loop (`run(until:)` is barred from async
    /// contexts — `OpenListLayoutMountTests`' own helper shape).
    private func pump(_ seconds: TimeInterval = 0.02) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    var open: SidebarGeometry.SectionDraw? { SidebarGeometry.sectionDraws[key]?[.open] }
    var starred: SidebarGeometry.SectionDraw? { SidebarGeometry.sectionDraws[key]?[.starred] }

    /// A navigation, through the one door every navigation funnels through.
    func go(_ destination: SidebarSelection) async {
        workspace.select(destination)
        await settle()
    }

    func newNote(_ title: String) throws -> String {
        let id = try session.operations.createPost(title: title).id
        notes.append(id)
        return id
    }

    /// Turns the run loop until the Open list's window has STOPPED MOVING —
    /// and never before the rail's 0.22 s fade has run its course.
    func settle(minimum: TimeInterval = 0.5, until ready: () -> Bool = { true }) async {
        let start = Date()
        var last: SidebarLayout.ScrollWindow?
        var lastFrame: CGRect?
        var lastStar: SidebarLayout.ScrollWindow?
        var still = 0
        for _ in 0..<300 {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(10))
            let now = open?.window
            let frame = open?.scroll
            let star = starred?.window
            if now != nil, now == last, frame == lastFrame, star == lastStar { still += 1 } else { still = 0 }
            last = now
            lastFrame = frame
            lastStar = star
            if still >= 5, Date().timeIntervalSince(start) >= minimum, ready() { return }
        }
    }

    /// F-2's full depth at the pitch a section is drawing NOW (its window's
    /// content over its rows — the column's pitch flips 30 ↔ 24 as rows come
    /// and go, so a pin reads it after every step).
    func depth(_ draw: SidebarGeometry.SectionDraw?, rows: Int) -> CGFloat {
        SidebarLayout.edgeFadeDepth(rowHeight: (draw?.window?.content ?? 0) / CGFloat(max(rows, 1)))
    }

    /// nil when `noteID`'s Open row stands wholly in the list's window and
    /// clear of its fades (none recorded reads as none drawn); otherwise what
    /// is wrong, for the expectation's message.
    func openRowTrouble(_ noteID: String) -> String? {
        guard let draw = open, let window = draw.window else { return "the list never reported its window" }
        let shown = workspace.openNotes.shown
        guard let row = shown.firstIndex(of: noteID) else { return "\(noteID) has no row" }
        let rowHeight = window.content / CGFloat(max(shown.count, 1))
        let fades = draw.fades ?? .none
        let top = CGFloat(row) * rowHeight
        let bottom = top + rowHeight
        let clearTop = window.offset + fades.top
        let clearBottom = window.offset + window.viewport - fades.bottom
        if top >= clearTop - 0.5, bottom <= clearBottom + 0.5 { return nil }
        return "row \(row + 1) of \(shown.count) spans \(top)…\(bottom); the window shows \(window.offset)…"
            + "\(window.offset + window.viewport) with fades \(fades.top)/\(fades.bottom)"
    }
}

@MainActor
@Suite("U1b — the scrolling sections' windows, as drawn", .serialized)
struct SidebarSectionWindowMountTests {
    private static let footerHeight: CGFloat = 64

    /// Mounts the column at `height` with `openNotes` open (visited in order)
    /// and `starred` stars, the focused pane on `startOn` (an index into the
    /// notes, or nil for the Library), settled.
    private func withRig(
        height: CGFloat, openNotes: Int, starred: Int = 0, startOn: Int?,
        _ body: @MainActor (SectionRig) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            // The LIVE generator: the oracle keys must not collide with a
            // parallel suite's (the DEBUG-oracle keying rule).
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 1281))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let notes = try (1...max(openNotes, starred)).map {
                try session.operations.createPost(title: "note \($0)").id
            }
            if starred > 0 {
                // `StarredScrollTests`' reason: the geometry, not the cap.
                let keys = notes.prefix(starred).map { StarTarget.post($0).key }
                let json = String(decoding: try JSONEncoder().encode(Array(keys)), as: UTF8.self)
                try await db.write { db in
                    try db.execute(
                        sql: """
                            INSERT INTO setting (key, value) VALUES ('starred', ?)
                            ON CONFLICT(key) DO UPDATE SET value = excluded.value
                            """,
                        arguments: [json])
                }
            }
            let workspace = WorkspaceModel()
            for note in notes.prefix(openNotes) { workspace.visit(.post(note)) }
            workspace.select(startOn.map { .post(notes[$0]) } ?? .library)
            let stars = StarsModel(session: session)
            let observing = Task { await stars.start() }
            defer { observing.cancel() }
            let theme = ThemeStore(session: session)
            SidebarGeometry.forgetSections(for: workspace)
            defer { SidebarGeometry.forgetSections(for: workspace) }

            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 230, height: height),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(rootView: SectionWindowHost(
                session: session, workspace: workspace, stars: stars, theme: theme,
                footerHeight: Self.footerHeight))
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            let rig = SectionRig(
                session: session, workspace: workspace, window: window, hosting: hosting, notes: notes)
            await rig.settle {
                starred == 0 || (stars.items.count == starred && rig.starred?.window != nil)
            }
            try await body(rig)
        }
    }

    /// **F-1, the deterministic road (RED ON OLD).** On the last row's note,
    /// go to the Library and come back. The Library's taller list (no rail)
    /// takes the rows in; coming back, the rail returns and the list's
    /// viewport shrinks under the row — and the old reveal never ran, because
    /// the note was already the newest (`recency.first` unchanged). RED ON
    /// OLD: the row sits far below the window.
    @Test func returningToTheNoteYouWereInRevealsItsRow() async throws {
        try await withRig(height: 900, openNotes: 20, startOn: 18) { rig in
            let last = rig.notes[19]
            await rig.go(.post(last))
            #expect(rig.openRowTrouble(last) == nil, "on the note: \(rig.openRowTrouble(last) ?? "")")
            await rig.go(.library)
            await rig.go(.post(last))
            print("[U1b return] \(String(describing: rig.open?.window)) · \(String(describing: rig.open?.fades))")
            #expect(rig.openRowTrouble(last) == nil,
                    "back on the note, its row is wholly in view: \(rig.openRowTrouble(last) ?? "")")
        }
    }

    /// **F-1's mechanism — a viewport that changes height under the current
    /// row re-reveals it (RED ON OLD, and RED with only that trigger
    /// reverted).** The current row revealed near the bottom, then the window
    /// shortens by 60 pt: the list's viewport shrinks from below, top-anchored,
    /// and only a re-reveal brings the row back.
    @Test func aShorterListKeepsTheCurrentRowInView() async throws {
        try await withRig(height: 900, openNotes: 20, startOn: 9) { rig in
            let current = rig.notes[15]
            await rig.go(.post(current))
            #expect(rig.openRowTrouble(current) == nil, "revealed: \(rig.openRowTrouble(current) ?? "")")
            let before = rig.open?.window
            rig.window.setContentSize(NSSize(width: 230, height: 840))
            await rig.settle()
            let after = rig.open?.window
            print("[U1b shorter] \(String(describing: before)) → \(String(describing: after))")
            #expect((after?.viewport ?? 0) < (before?.viewport ?? 0) - 30,
                    "the list's viewport really shrank: \(String(describing: before)) → \(String(describing: after))")
            #expect(rig.openRowTrouble(current) == nil,
                    "after the window shortened: \(rig.openRowTrouble(current) ?? "")")
        }
    }

    /// **F-1, the walker's road** (O-1: a NEW note opened from a place, the
    /// rail arriving and the column's height settling after the reveal). The
    /// old code raced here — usually whole, once in ~40 cut — so this pin is
    /// exact-behaviour for the new code, not a red-on-old proof.
    @Test func aNewNoteOpenedFromThePlacesLandsWhollyInView() async throws {
        try await withRig(height: 900, openNotes: 19, startOn: 18) { rig in
            await rig.go(.library)
            let newcomer = try rig.newNote("note 20")
            await rig.go(.post(newcomer))
            #expect(rig.workspace.openNotes.shown.last == newcomer)
            #expect(rig.openRowTrouble(newcomer) == nil,
                    "the note she just opened: \(rig.openRowTrouble(newcomer) ?? "")")
        }
    }

    /// **F-1 — a ⌘⇧W landing** (the door's road: the workspace closes the
    /// row and names the landing; the shell selects it). The next row sat
    /// under the bottom fade beneath the closed one; it lands clear of it.
    @Test func aCloseNoteLandingRevealsTheNextRowClearOfTheFades() async throws {
        try await withRig(height: 900, openNotes: 20, startOn: 9) { rig in
            await rig.go(.post(rig.notes[14]))
            let landing = try #require(rig.workspace.closeFocusedNote())
            #expect(landing == .post(rig.notes[15]))
            await rig.go(landing)
            #expect(rig.openRowTrouble(rig.notes[15]) == nil,
                    "the landing's row: \(rig.openRowTrouble(rig.notes[15]) ?? "")")
        }
    }

    /// **F-2 — the Open list fades only the edges with more beyond them**
    /// (P-U1-6; the oracle reads the fades the overlay draws). At the top
    /// only the bottom fades, mid-list both, at the end only the top — each
    /// half a row deep. RED ON OLD: no fade at all (none recorded).
    @Test func theOpenListFadesOnlyTheEdgesWithMoreBeyond() async throws {
        try await withRig(height: 900, openNotes: 20, startOn: 0) { rig in
            _ = try #require(rig.open?.window)
            var depth = rig.depth(rig.open, rows: 20)
            #expect(depth >= 12, "half a row at either pitch: \(depth)")
            #expect(rig.open?.fades == SidebarLayout.EdgeFades(top: 0, bottom: depth),
                    "at the top: \(String(describing: rig.open?.fades))")
            // Row 15 (420…450) lies below the fold of the 351-pt list, so the
            // reveal scrolls it in and leaves rows above AND below. (U1b's
            // window: row 10, the first draft's pick, stood clear at offset 0 —
            // nothing scrolled — a pin fault, recorded.)
            await rig.go(.post(rig.notes[14]))
            depth = rig.depth(rig.open, rows: 20)
            #expect(rig.open?.fades == SidebarLayout.EdgeFades(top: depth, bottom: depth),
                    "mid-list: \(String(describing: rig.open?.fades))")
            await rig.go(.post(rig.notes[19]))
            depth = rig.depth(rig.open, rows: 20)
            #expect(rig.open?.fades == SidebarLayout.EdgeFades(top: depth, bottom: 0),
                    "at the end: \(String(describing: rig.open?.fades))")
        }
    }

    /// **F-2 — Starred too:** past its ~7 it fades its bottom edge at rest
    /// (its half row reads as "more", softly), and a starred note revealed at
    /// the end fades the top instead; a Starred that holds every row fades
    /// nowhere. RED ON OLD: no fade at all.
    @Test func starredFadesWhereMoreLiesBeyondAndNowhereWhenItHoldsEverything() async throws {
        try await withRig(height: 900, openNotes: 3, starred: 9, startOn: nil) { rig in
            let window = try #require(rig.starred?.window)
            var depth = rig.depth(rig.starred, rows: 9)
            #expect(depth >= 12, "half a row at either pitch: \(depth)")
            #expect(rig.starred?.fades == SidebarLayout.EdgeFades(top: 0, bottom: depth),
                    "at rest: \(String(describing: rig.starred?.fades)) over \(window)")
            // Opening the ninth star's note brings the rail (and may flip the
            // column's pitch): the section reveals it and fades the top instead.
            await rig.go(.post(rig.notes[8]))
            depth = rig.depth(rig.starred, rows: 9)
            #expect(rig.starred?.fades == SidebarLayout.EdgeFades(top: depth, bottom: 0),
                    "the ninth star revealed: \(String(describing: rig.starred?.fades)) over \(String(describing: rig.starred?.window))")
        }
        try await withRig(height: 900, openNotes: 3, starred: 5, startOn: nil) { rig in
            #expect(rig.starred?.fades == SidebarLayout.EdgeFades.none,
                    "five stars, all shown: \(String(describing: rig.starred?.fades))")
        }
    }
}
