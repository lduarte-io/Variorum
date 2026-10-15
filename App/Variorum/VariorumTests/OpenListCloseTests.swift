//
//  OpenListCloseTests.swift
//  VariorumTests
//
//  VX-283 run, U1 — CLOSING: VX-287 (Close Note, ⌘⇧W, the pane landing on
//  the next note in the Open list) and VX-289 (Close All Notes, the Open
//  list's right-click + the View menu's twin).
//
//  Her ruling (2026-10-13, verbatim): *"for command W - can we do shift
//  command W? i like that better than control, it's more natural to type. i
//  think landing in the next note on the list is perfect-that way you can
//  close them all quickly."* — and her VX-283 triage: *"close all now is
//  good."* The fallbacks (the last row lands on the previous note; an empty
//  list on the Library) are the ticket's, PROVISIONAL (P-U1-1).
//
//  These are NEW acts (no shortcut existed — the ticket's trace), so their
//  pins are exact-behaviour pins rather than red-on-old: the landing
//  arithmetic, the workspace's two acts, the registry's declaration and
//  gates, and the whole road through a mounted shell (the landing takes the
//  EXISTING open-note road — `pendingSelection`, adopted by `RootView`).
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The landing arithmetic (pure)

@Suite("VX-287 — where a pane lands when its note's row closes")
struct OpenListLandingTests {
    private func notes(_ ids: [String]) -> OpenNotes {
        var notes = OpenNotes()
        for id in ids { notes.opened(id) }
        return notes
    }

    @Test func theNextRowInStripOrder() {
        let open = notes(["a", "b", "c"])
        #expect(open.neighbour(ofClosing: "b") == "c")
        #expect(open.neighbour(ofClosing: "a") == "b")
    }

    @Test func theLastRowFallsBackToThePreviousOne() {
        #expect(notes(["a", "b", "c"]).neighbour(ofClosing: "c") == "b")
    }

    @Test func theOnlyRowLeavesNowhereSoTheCallerLandsTheLibrary() {
        #expect(notes(["a"]).neighbour(ofClosing: "a") == nil)
        #expect(OpenNotes().neighbour(ofClosing: "a") == nil)
    }

    /// The order is the STRIP's (insertion, or her manual arrangement) —
    /// never recency: re-opening `a` last must not make it "next".
    @Test func theOrderIsTheListsNotRecency() {
        var open = notes(["a", "b", "c"])
        open.opened("a")  // most recent now, still row 1
        #expect(open.neighbour(ofClosing: "b") == "c")
        open.move(fromOffsets: IndexSet(integer: 2), toOffset: 0)  // c, a, b
        #expect(open.neighbour(ofClosing: "c") == "a")
    }

    /// P-U1-2: a note another pane shows is passed over (a split never shows
    /// one note twice), in both directions.
    @Test func aNoteShownInTheOtherPaneIsPassedOver() {
        let open = notes(["a", "b", "c"])
        #expect(open.neighbour(ofClosing: "a", skipping: ["b"]) == "c")
        #expect(open.neighbour(ofClosing: "c", skipping: ["b"]) == "a")
        #expect(notes(["a", "b"]).neighbour(ofClosing: "a", skipping: ["b"]) == nil)
    }

    /// P-U1-2: a note with no row (its ✕ pressed while it stayed on screen)
    /// sits past the end, where a re-open would put it — so it lands on the
    /// last row.
    @Test func aNoteWithNoRowLandsOnTheLastRow() {
        #expect(notes(["a", "b"]).neighbour(ofClosing: "z") == "b")
    }

    /// Her reason, as arithmetic: pressing it again and again closes them all.
    @Test func pressingItAgainAndAgainClosesThemAll() {
        var open = notes(["a", "b", "c", "d"])
        var here: String? = "b"
        var visited: [String] = []
        while let current = here {
            let next = open.neighbour(ofClosing: current)
            open.close(current)
            if let next { visited.append(next) }
            here = next
        }
        #expect(visited == ["c", "d", "a"], "next, next, then the previous one, then nowhere")
        #expect(open.ids.isEmpty)
    }

    @Test func closeAllEmptiesTheListAndItsRecency() {
        var open = notes(["a", "b", "c"])
        open.closeAll()
        #expect(open.ids.isEmpty)
        #expect(open.recency.isEmpty)
    }
}

// MARK: - The workspace's two acts

@MainActor
@Suite("VX-287 / VX-289 — the workspace's close acts")
struct WorkspaceCloseActTests {
    private func makeWorkspace(open ids: [String], showing: String) -> WorkspaceModel {
        let workspace = WorkspaceModel()
        for id in ids { workspace.visit(.post(id)) }
        workspace.select(.post(showing))
        return workspace
    }

    @Test func closeNoteRemovesTheRowAndNamesTheNextNote() {
        let workspace = makeWorkspace(open: ["a", "b", "c"], showing: "b")
        #expect(workspace.closeNoteTarget == "b")
        #expect(workspace.closeFocusedNote() == .post("c"))
        #expect(workspace.openNotes.ids == ["a", "c"], "only its row closed")
        // The model names the landing; the DOOR routes it through the shell,
        // so the pane has not moved yet (the mounted pin below drives that).
        #expect(workspace.focusedSelection == .post("b"))
        workspace.select(.post("c"))
        #expect(workspace.openNotes.ids == ["a", "c"], "arriving re-adds nothing")
    }

    @Test func closingTheLastRowLandsOnThePreviousThenTheLibrary() {
        let workspace = makeWorkspace(open: ["a", "b"], showing: "b")
        let first = workspace.closeFocusedNote()
        #expect(first == .post("a"))
        workspace.select(.post("a"))
        #expect(workspace.closeFocusedNote() == .library)
        #expect(workspace.openNotes.ids.isEmpty)
    }

    /// Closing IS leaving: once the door's landing is adopted, the closed
    /// note departs like any navigation (its savepoint-on-leave fires).
    @Test func theClosedNoteDepartsWhenThePaneLands() throws {
        let workspace = makeWorkspace(open: ["a", "b"], showing: "a")
        var departed: [String] = []
        workspace.onNotesLeft = { departed += $0 }
        let landing = workspace.closeFocusedNote()
        #expect(departed.isEmpty, "the model itself navigates nothing")
        workspace.select(try #require(landing))
        #expect(departed == ["a"])
    }

    @Test func aPaneShowingNoNoteHasNothingToClose() {
        let workspace = makeWorkspace(open: ["a", "b"], showing: "a")
        workspace.select(.library)
        #expect(workspace.closeNoteTarget == nil)
        #expect(workspace.closeFocusedNote() == nil)
        #expect(workspace.openNotes.ids == ["a", "b"], "nothing closed")
        // A scraps container is not a note the Open list holds either.
        workspace.select(.pool("scraps"))
        #expect(workspace.closeFocusedNote() == nil)
        #expect(workspace.openNotes.ids == ["a", "b"])
    }

    /// P-U1-2: in a split, the landing passes over the note the OTHER pane
    /// shows — it never asks the same-note rule to move the focus instead.
    @Test func inASplitTheLandingPassesOverTheOtherPanesNote() {
        let workspace = makeWorkspace(open: ["a", "b", "c"], showing: "a")
        workspace.openBeside(.post("b"))  // focus moves to the new pane, on b
        #expect(workspace.closeNoteTarget == "b")
        #expect(workspace.closeFocusedNote() == .post("c"))

        let two = makeWorkspace(open: ["a", "b"], showing: "a")
        two.openBeside(.post("b"))
        #expect(two.closeFocusedNote() == .library,
                "the only other row is on screen beside it, so the pane lands on the Library")
    }

    @Test func closeAllEmptiesTheListAndLandsTheLibrary() {
        let workspace = makeWorkspace(open: ["a", "b", "c"], showing: "b")
        #expect(workspace.closeAllNotes() == .library)
        #expect(workspace.openNotes.ids.isEmpty)
        #expect(workspace.openNotes.recency.isEmpty)
    }

    @Test func closeAllFromAPlaceClosesTheRowsAndMovesNothing() {
        let workspace = makeWorkspace(open: ["a", "b"], showing: "a")
        workspace.select(.shelf)
        #expect(workspace.closeAllNotes() == nil, "the pane shows no note, so it stays")
        #expect(workspace.openNotes.ids.isEmpty)
        #expect(workspace.focusedSelection == .shelf)
    }

    /// P-U1-3: the OTHER pane of a split showing a note lands on the Library
    /// in place, and the focus stays where she is.
    @Test func closeAllLandsTheOtherPaneInPlaceAndKeepsTheFocus() throws {
        let workspace = makeWorkspace(open: ["a", "b"], showing: "a")
        workspace.openBeside(.post("b"))
        let focused = workspace.focusedPane
        let other = try #require(workspace.panes.first { $0 != focused })
        #expect(workspace.closeAllNotes() == .library)
        #expect(workspace.selections[other] == .library, "the other pane left its closed note")
        #expect(workspace.focusedPane == focused, "…without taking her focus")
        #expect(workspace.focusedSelection == .post("b"),
                "the focused pane's landing is the door's to route")
    }

    /// Her ruling at U1's READY (*"Yes, same as ⇧⌘W"*): the ✕'s act on the
    /// note the focused pane shows names the same landing ⌘⇧W does.
    @Test func closingTheShownNotesRowNamesTheSameLandingAsCloseNote() {
        let workspace = makeWorkspace(open: ["a", "b", "c"], showing: "b")
        #expect(workspace.closeRow("b") == .post("c"))
        #expect(workspace.openNotes.ids == ["a", "c"])
    }

    /// …and a ✕ on any OTHER row just removes that row, as it always did.
    @Test func closingAnotherRowMovesNothing() {
        let workspace = makeWorkspace(open: ["a", "b", "c"], showing: "b")
        #expect(workspace.closeRow("a") == nil)
        #expect(workspace.openNotes.ids == ["b", "c"])
        #expect(workspace.focusedSelection == .post("b"))
    }

    /// P-U1-5 (the orchestrator's): a row whose note the OTHER pane of a
    /// split shows moves that pane to the Library in place, focus kept.
    @Test func closingTheOtherPanesNoteLandsThatPaneInPlace() throws {
        let workspace = makeWorkspace(open: ["a", "b"], showing: "a")
        workspace.openBeside(.post("b"))  // focused: the new pane, on b
        let focused = workspace.focusedPane
        let other = try #require(workspace.panes.first { $0 != focused })
        #expect(workspace.closeRow("a") == nil, "the focused pane has nothing to route")
        #expect(workspace.selections[other] == .library, "the other pane left the closed note")
        #expect(workspace.focusedPane == focused, "…without taking her focus")
        #expect(workspace.focusedSelection == .post("b"))
        #expect(workspace.openNotes.ids == ["b"])
    }

    /// VIEW-ONLY, at the layer that could break it: the notes stay live.
    @Test func closingNeverTouchesTheStore() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let a = try session.operations.createPost(title: "Keep a")
            let b = try session.operations.createPost(title: "Keep b")
            let outboxBefore = try await db.read { try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM sync_outbox") }
            let workspace = makeWorkspace(open: [a.id, b.id], showing: a.id)
            _ = workspace.closeFocusedNote()
            _ = workspace.closeAllNotes()
            let titles = try await db.read { db in
                try [a.id, b.id].map { try Queries.containerHeader(db, containerID: $0)?.title }
            }
            #expect(titles == ["Keep a", "Keep b"], "closing deletes nothing")
            let outboxAfter = try await db.read { try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM sync_outbox") }
            #expect(outboxAfter == outboxBefore, "…and writes nothing")
        }
    }
}

// MARK: - The registry: declared, keyed, rendered, gated

@MainActor
@Suite("VX-287 / VX-289 — the close doors in the registry")
struct OpenListCloseDoorTests {
    @Test func closeNoteIsDeclaredOnTheMenuWithHerChord() throws {
        let close = CapabilityRegistry.capability(.closeNote)
        #expect(close.verb == "Close Note")
        #expect(close.scope == .app)
        #expect(close.doors == [.menuBar])
        #expect(close.shortcutLabel == "\u{2318}\u{21e7}W")
        #expect(EditorCommands.menuRendered.contains(.closeNote))
        let wiring = try #require(EditorCommands.keyEquivalent(for: .closeNote))
        #expect(wiring.0 == "w")
        #expect(wiring.1 == [.command, .shift], "⌘⇧W — her pick over ⌃⌘W")
        #expect(HelperView.shortcutKeysShown.contains("\u{2318}\u{21e7}W"))
    }

    /// ⌘W is NOT taken: it stays the system's File ▸ Close (it closes the window).
    @Test func plainCommandWStaysTheSystems() {
        for capability in CapabilityRegistry.all {
            guard let (key, modifiers) = EditorCommands.keyEquivalent(for: capability.id)
            else { continue }
            #expect(!(key.character == "w" && modifiers == .command),
                    "\(capability.id) must not take ⌘W")
        }
    }

    @Test func closeAllIsDeclaredOnTheMenuAndTheOpenListsRightClick() {
        let all = CapabilityRegistry.capability(.closeAllNotes)
        #expect(all.verb == "Close All Notes")
        #expect(all.doors == [.menuBar, .contextMenu])
        #expect(all.shortcutLabel == nil)
        #expect(EditorCommands.menuRendered.contains(.closeAllNotes))
        #expect(SidebarView.openListMenuCapabilities.contains(.closeAllNotes))
        #expect(!SidebarView.contextMenuCapabilities.contains(.closeAllNotes),
                "the Library's and the Pool's note rows do not render it — it is the list's")
    }

    /// The Open list's row menu RENDERS the declared verb — read from the
    /// source (a context menu cannot be mounted headlessly), the Library
    /// row menu's pin's shape.
    @Test func theOpenRowMenuRendersCloseAllFromTheRegistry() throws {
        let source = try String(
            contentsOf: URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent().deletingLastPathComponent()
                .appendingPathComponent("Variorum/Features/Library/SidebarView.swift"),
            encoding: .utf8)
        let start = try #require(source.range(of: "private func openRow("))
        let body = source[start.upperBound...]
        #expect(body.contains("CapabilityRegistry.capability(.closeAllNotes).verb"))
        #expect(body.contains("workspace.closeAllNotes()"))
    }

    @Test func closeNoteIsGreyWhereItCannotAct() {
        let full = WindowRegistry.Kind.full
        #expect(!CapabilityRegistry.isEnabled(.closeNote, in: CapabilityContext()),
                "no window, no note")
        #expect(!CapabilityRegistry.isEnabled(
            .closeNote, in: CapabilityContext(windowKind: full)), "a place in the pane")
        #expect(!CapabilityRegistry.isEnabled(
            .closeNote, in: CapabilityContext(focusedPaneShowsNote: true, windowKind: .noteOnly)),
                "a note-only window has no Open list — ⌘W closes it, ⌘⇧W is grey")
        #expect(!CapabilityRegistry.isEnabled(
            .closeNote, in: CapabilityContext(focusedPaneShowsNote: true, windowKind: .quickNote)))
        #expect(CapabilityRegistry.isEnabled(
            .closeNote, in: CapabilityContext(focusedPaneShowsNote: true, windowKind: full)))
        #expect(!CapabilityRegistry.capability(.closeNote).unavailableNote.isEmpty)
    }

    @Test func closeAllIsGreyWithNothingOpen() {
        #expect(!CapabilityRegistry.isEnabled(
            .closeAllNotes, in: CapabilityContext(windowKind: .full)))
        #expect(!CapabilityRegistry.isEnabled(
            .closeAllNotes, in: CapabilityContext(openNoteCount: 3, windowKind: .noteOnly)))
        #expect(CapabilityRegistry.isEnabled(
            .closeAllNotes, in: CapabilityContext(openNoteCount: 1, windowKind: .full)))
        #expect(!CapabilityRegistry.capability(.closeAllNotes).unavailableNote.isEmpty)
    }
}

// MARK: - The ✕'s door (her ruling at U1's READY) — RED ON OLD

/// **THE ✕ ON THE NOTE YOU'RE LOOKING AT** — her ruling at U1's READY
/// (2026-10-14): asked whether closing the row of the note she is looking at
/// should behave like ⇧⌘W, she chose *"Yes, same as ⇧⌘W"*. The defect it
/// fixes is the one the ticket names: the ✕ removed the row and the note
/// stayed on screen with no row.
///
/// The pin drives `SidebarView.closeRow` — the exact act the ✕ and the
/// right-click ▸ Close run (a source read below holds that) — with a binding
/// built exactly as `RootView.selectionBinding` is (its setter is
/// `ShellRouter.adopt` into the focused pane). RED ON OLD (R-C, the U1
/// record): the door's old act was `workspace.closeNote(noteID)`, the row
/// alone — the pane went on showing the closed note.
@MainActor
@Suite("VX-287 — the ✕ on the note you're looking at moves the pane on")
struct OpenListRowCloseDoorTests {
    /// The shell's own selection binding, as `RootView` builds it.
    private func shellBinding(_ router: ShellRouter) -> Binding<SidebarSelection?> {
        Binding(
            get: { router.workspace.selections[router.workspace.focusedPane] },
            set: { picked in
                guard let picked else { return }
                router.adopt(picked, in: router.workspace.focusedPane)
            })
    }

    private func router(open ids: [String], showing: String) -> ShellRouter {
        let router = ShellRouter()
        for id in ids { router.adopt(.post(id)) }
        router.adopt(.post(showing))
        return router
    }

    @Test func theXOnTheNoteYouAreInMovesThePaneToTheNextNote() {
        let router = router(open: ["a", "b", "c"], showing: "b")
        var departed: [String] = []
        router.workspace.onNotesLeft = { departed += $0 }
        SidebarView.closeRow("b", in: router.workspace, selection: shellBinding(router))
        #expect(router.workspace.focusedSelection == .post("c"),
                "the pane moved on to the next note — not left on the closed one with no row")
        #expect(router.workspace.openNotes.ids == ["a", "c"])
        #expect(departed == ["b"], "closing the note you're in is a leaving (its savepoint)")
    }

    @Test func theXOnTheLastRowLandsOnThePreviousThenTheLibrary() {
        let router = router(open: ["a", "b"], showing: "b")
        SidebarView.closeRow("b", in: router.workspace, selection: shellBinding(router))
        #expect(router.workspace.focusedSelection == .post("a"))
        SidebarView.closeRow("a", in: router.workspace, selection: shellBinding(router))
        #expect(router.workspace.focusedSelection == .library)
        #expect(router.workspace.openNotes.ids.isEmpty)
    }

    @Test func theXOnAnyOtherRowJustRemovesIt() {
        let router = router(open: ["a", "b", "c"], showing: "b")
        var departed: [String] = []
        router.workspace.onNotesLeft = { departed += $0 }
        SidebarView.closeRow("c", in: router.workspace, selection: shellBinding(router))
        #expect(router.workspace.focusedSelection == .post("b"), "the pane stays where she is")
        #expect(router.workspace.openNotes.ids == ["a", "b"])
        #expect(departed.isEmpty)
    }

    /// Both doors run the one act — read from `openRow`'s own body (a row's
    /// button and context menu cannot be pressed headlessly).
    @Test func theXAndRightClickCloseBothRunTheOneAct() throws {
        let source = try String(
            contentsOf: URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent().deletingLastPathComponent()
                .appendingPathComponent("Variorum/Features/Library/SidebarView.swift"),
            encoding: .utf8)
        let start = try #require(source.range(of: "private func openRow("))
        let body = String(source[start.upperBound...].prefix(8_000))
        let end = body.range(of: "\n    }\n")?.lowerBound ?? body.endIndex
        let row = body[..<end]
        let call = "Self.closeRow(noteID, in: workspace, selection: $selection)"
        #expect(row.components(separatedBy: call).count - 1 == 2,
                "the ✕ and right-click ▸ Close both run `closeRow`")
        #expect(!row.contains("workspace.closeNote(noteID)"),
                "no door closes the row bare any more")
    }
}

// MARK: - The whole road, through a mounted shell

@MainActor
@Suite("VX-287 / VX-289 — ⌘⇧W and Close All through the shell", .serialized)
struct OpenListCloseShellTests {
    private func pump() {
        RunLoop.main.run(until: Date().addingTimeInterval(0.01))
    }

    private func settle(until predicate: () -> Bool) async {
        for _ in 0..<300 where !predicate() {
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(5))
        }
    }

    /// A navigation request ADOPTED: the pane shows `target`, the shell has
    /// cleared its request, and a frame has passed, so the test's NEXT request
    /// lands in a later update. Two requests in one frame are refused by
    /// SwiftUI's `onChange` on the shell's adoption road: that product race is
    /// VX-360 (the flake this test showed in VX-283's 93-suite batch, traced in
    /// the record's "U1c — the batch flake"). This test pins the landing ORDER,
    /// not that race.
    private func settleAdoption(_ router: ShellRouter, at target: SidebarSelection) async {
        await settle { router.workspace.focusedSelection == target && router.pendingSelection == nil }
        pump()
        try? await Task.sleep(for: .milliseconds(34))
        pump()
    }

    /// The doors' acts (`EditorCommands.closeNote(in:)` and
    /// `.closeAllNotes(in:)` — the exact closures the View menu's items run)
    /// against a mounted shell: the landing goes through the shell's own
    /// open-note road and the pane ARRIVES — next, then the previous, then
    /// the Library; and the context the menu gates on is wired.
    @Test func theMenuActsLandThePaneThroughTheShell() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let a = try session.operations.createPost(title: "alpha")
            let b = try session.operations.createPost(title: "beta")
            let c = try session.operations.createPost(title: "gamma")
            let router = ShellRouter()
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1000, height: 700),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            window.contentView = NSHostingView(
                rootView: RootView(session: session, services: nil, router: router))
            window.makeKeyAndOrderFront(nil)
            await settle { router.workspace.history().current != nil }

            for note in [a, b, c] {
                router.pendingSelection = .post(note.id)
                await settleAdoption(router, at: .post(note.id))
            }
            router.pendingSelection = .post(b.id)
            await settleAdoption(router, at: .post(b.id))
            #expect(router.workspace.openNotes.ids == [a.id, b.id, c.id])
            #expect(session.commandRouter.isEnabled(.closeNote), "a note in a full window")
            #expect(session.commandRouter.isEnabled(.closeAllNotes))

            // ⌘⇧W on b: its row leaves and the pane lands on the NEXT note, c.
            EditorCommands.closeNote(in: router)
            await settleAdoption(router, at: .post(c.id))
            #expect(router.workspace.focusedSelection == .post(c.id), "landed on the next note")
            #expect(router.workspace.openNotes.ids == [a.id, c.id])
            #expect(router.pendingSelection == nil, "the shell adopted the landing")

            // Again, on the LAST row: the previous note, a.
            EditorCommands.closeNote(in: router)
            await settleAdoption(router, at: .post(a.id))
            #expect(router.workspace.focusedSelection == .post(a.id))
            #expect(router.workspace.openNotes.ids == [a.id])

            // Close All: the list empties and the pane lands on the Library.
            EditorCommands.closeAllNotes(in: router)
            await settle { router.workspace.focusedSelection == .library }
            #expect(router.workspace.focusedSelection == .library)
            #expect(router.workspace.openNotes.ids.isEmpty)
            #expect(!session.commandRouter.isEnabled(.closeNote), "grey on the Library")
            #expect(!session.commandRouter.isEnabled(.closeAllNotes), "grey with nothing open")

            // The notes are untouched.
            let titles = try await db.read { db in
                try [a.id, b.id, c.id].map { try Queries.containerHeader(db, containerID: $0)?.title }
            }
            #expect(titles == ["alpha", "beta", "gamma"])
        }
    }
}
