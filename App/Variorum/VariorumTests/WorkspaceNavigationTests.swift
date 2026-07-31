//
//  WorkspaceNavigationTests.swift
//  VariorumTests
//
//  Phase 13f, batch 3 — the NAVIGATION core's pins (her W3/A27 + W16
//  rulings). Everything that DECIDES anything here is pure arithmetic over
//  ids, and it is pinned as arithmetic: the per-pane history's trail, the
//  Open strip's recency and bounds, the ordinal keys' reach, and the names
//  the chip and the strip wear. The routing half pins at the registry /
//  shell-door layer (the 13d A14 precedent), including the COLLISION SWEEP
//  MADE PERMANENT.
//
//  What is deliberately NOT claimed here: how the strip LOOKS in the
//  sidebar and how the chip's fold FEELS — those are on the batch record's
//  visual-verification-only list.
//

import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The pure history (W16)

@Suite("Navigation history (13f batch 3, W16)")
struct NavigationHistoryTests {
    @Test func visitingBuildsTheTrailAndReVisitingTheCurrentIsANoOp() {
        var history = NavigationHistory()
        #expect(!history.canGoBack)
        #expect(history.origin == nil, "arriving from nowhere shows no chip")

        history.visit(.shelf)
        #expect(!history.canGoBack, "the first arrival has nothing behind it")
        history.visit(.reading("book"))
        history.visit(.post("p1"))
        #expect(history.back == [.shelf, .reading("book")])
        #expect(history.current == .post("p1"))

        // THE RE-ENTRANCY CLAIM: the shell reports every selection change,
        // including the one back/forward caused. Re-visiting the current
        // destination must change nothing at all — that is what lets
        // `goBack` set `current` itself and skip a flag.
        let before = history
        history.visit(.post("p1"))
        #expect(history == before)
    }

    @Test func backAndForwardWalkTheSameTrail() {
        var history = NavigationHistory()
        history.visit(.shelf)
        history.visit(.reading("book"))
        history.visit(.post("p1"))

        #expect(history.origin == .reading("book"), "the chip names the book")
        #expect(history.goBack() == .reading("book"))
        #expect(history.current == .reading("book"))
        #expect(history.canGoForward)
        #expect(history.goBack() == .shelf)
        #expect(history.goBack() == nil, "the trail ends")

        #expect(history.goForward() == .reading("book"))
        #expect(history.goForward() == .post("p1"))
        #expect(history.goForward() == nil)
        #expect(history.current == .post("p1"), "the round trip lands where it started")
    }

    @Test func aNewNavigationEndsTheForwardFuture() {
        var history = NavigationHistory()
        history.visit(.shelf)
        history.visit(.post("p1"))
        _ = history.goBack()
        #expect(history.canGoForward)

        history.visit(.post("p2"))  // a fresh branch
        #expect(!history.canGoForward, "the browser rule — and structural redo's")
        #expect(history.origin == .shelf)
    }

    @Test func theTrailIsBounded() {
        var history = NavigationHistory()
        for i in 0...(NavigationHistory.cap + 20) {
            history.visit(.post("p\(i)"))
        }
        #expect(history.back.count == NavigationHistory.cap, "held state gets a bound")
        // The bound drops the OLDEST, so the recent trail is intact.
        #expect(history.back.last == .post("p\(NavigationHistory.cap + 19)"))
    }
}

// MARK: - The pure Open list (W3/A27)

@Suite("Open notes (13f batch 3, W3/A27)")
struct OpenNotesTests {
    @Test func openingMovesANoteToTheFrontWithoutDuplicating() {
        var open = OpenNotes()
        open.opened("a")
        open.opened("b")
        open.opened("c")
        #expect(open.ids == ["c", "b", "a"], "most recent first")

        open.opened("a")
        #expect(open.ids == ["a", "c", "b"], "re-opening MOVES, never duplicates")
    }

    @Test func closingARowRemovesOnlyThatRowAndNothingElse() {
        var open = OpenNotes()
        open.opened("a")
        open.opened("b")
        open.close("a")
        #expect(open.ids == ["b"])
        open.close("nobody")
        #expect(open.ids == ["b"], "closing something absent is inert")
        // …and it is not a delete: the same note opens straight back.
        open.opened("a")
        #expect(open.ids == ["a", "b"])
    }

    @Test func theOrdinalsCoverExactlyTheShownRows() {
        var open = OpenNotes()
        for i in 1...OpenNotes.visibleCap { open.opened("p\(i)") }
        // Most recent first, so the LAST opened is ⌘⇧1.
        #expect(open.id(atOrdinal: 1) == "p\(OpenNotes.visibleCap)")
        #expect(open.id(atOrdinal: OpenNotes.visibleCap) == "p1")
        #expect(open.id(atOrdinal: 0) == nil)
        #expect(open.id(atOrdinal: OpenNotes.visibleCap + 1) == nil,
                "no key reaches past the strip")
        #expect(open.shown.count == OpenNotes.visibleCap)
        #expect(open.hiddenCount == 0)
        // The two numbers that must never drift apart: the keys are
        // ⌘⇧1…⌘⇧9, so the strip shows nine.
        #expect(OpenNotes.visibleCap == 9)
    }

    @Test func theListIsBoundedAndTheStripSaysSoInsteadOfCuttingSilently() {
        var open = OpenNotes()
        for i in 1...(OpenNotes.trackedCap + 5) { open.opened("p\(i)") }
        #expect(open.ids.count == OpenNotes.trackedCap, "the session memory's bound")
        #expect(open.shown.count == OpenNotes.visibleCap)
        #expect(open.hiddenCount == OpenNotes.trackedCap - OpenNotes.visibleCap,
                "the truncation row's number — never a silent cut")
        // The arm that DISCRIMINATES the ordinal's reach (added when the
        // first revert ran green: with exactly nine open, "the shown rows"
        // and "the tracked list" are the same list, so neither reading can
        // be told from the other). Here they differ, and a key must not
        // reach a row the strip does not show.
        #expect(open.id(atOrdinal: OpenNotes.visibleCap) == open.shown.last)
        #expect(open.id(atOrdinal: OpenNotes.visibleCap + 1) == nil,
                "⌘⇧n stops at the strip, never at the session memory")

        // Closing a shown row PROMOTES the next most recent into view,
        // which is the whole reason the tracked list is deeper than the
        // shown one.
        let promoted = open.ids[OpenNotes.visibleCap]
        open.close(open.shown[0])
        #expect(open.shown.contains(promoted))
        #expect(open.hiddenCount == OpenNotes.trackedCap - OpenNotes.visibleCap - 1)
    }
}

// MARK: - The names (the chip's and the strip's words)

@Suite("Workspace naming (13f batch 3)")
struct WorkspaceNamingTests {
    @Test func everyDestinationKindNamesItself() {
        let titles = [
            "p1": "The Long Way Home", "b1": "Field Notes",
            "t1": "life/goals", "pool1": "Scraps", "blank": "",
        ]
        #expect(WorkspaceNaming.label(for: .shelf, titles: titles) == "Shelf")
        #expect(WorkspaceNaming.label(for: .library, titles: titles) == "Library")
        #expect(WorkspaceNaming.label(for: .poolPosts, titles: titles) == "Pool")
        #expect(WorkspaceNaming.label(for: .blocks, titles: titles) == "Blocks")
        // The recovery surface reads its ONE name (13f W10a's RecoveryPath)
        // — copy that invented a second word would send her to a door that
        // does not exist.
        #expect(WorkspaceNaming.label(for: .recovery, titles: titles)
                == RecoveryPath.menuLabel)
        #expect(WorkspaceNaming.label(for: .post("p1"), titles: titles) == "The Long Way Home")
        #expect(WorkspaceNaming.label(for: .reading("b1"), titles: titles) == "Field Notes")
        #expect(WorkspaceNaming.label(for: .tag("t1"), titles: titles) == "life/goals")
        #expect(WorkspaceNaming.label(for: .pool("pool1"), titles: titles) == "Scraps")
    }

    @Test func anUnresolvedOrEmptyNameStillReadsAsWhatItIs() {
        #expect(WorkspaceNaming.label(for: .post("missing"), titles: [:]) == "Untitled")
        #expect(WorkspaceNaming.label(for: .reading("missing"), titles: [:]) == "Book")
        #expect(WorkspaceNaming.label(for: .tag("missing"), titles: [:]) == "Tag")
        // An empty stored title is not a name — the app's shipped reading.
        #expect(WorkspaceNaming.label(for: .post("p"), titles: ["p": ""]) == "Untitled")
    }

    @Test func theChipSpeaksOnceAndTheHelpAgrees() {
        #expect(WorkspaceNaming.backLabel(origin: "Field Notes") == "\u{2190} Field Notes")
        #expect(WorkspaceNaming.backHelp(origin: "Field Notes")
                == "Back to Field Notes (\u{2318}[)")
    }
}

// MARK: - The model (recording + the free-tiling rider)

@MainActor
@Suite("Workspace model (13f batch 3)")
struct WorkspaceModelTests {
    @Test func arrivingRecordsBothTheTrailAndTheStrip() {
        let workspace = WorkspaceModel()
        workspace.visit(.shelf)
        workspace.visit(.reading("book"))
        workspace.visit(.post("p1"))

        #expect(workspace.history().origin == .reading("book"))
        #expect(workspace.openNotes.ids == ["p1"], "only NOTES join the Open strip")
        workspace.visit(.post("p2"))
        #expect(workspace.openNotes.ids == ["p2", "p1"])
        // A book, a folder and the shelf are destinations, never rows.
        #expect(!workspace.openNotes.ids.contains("book"))
    }

    @Test func walkingBackDoesNotPushAgainWhenTheShellReportsTheArrival() {
        let workspace = WorkspaceModel()
        workspace.visit(.shelf)
        workspace.visit(.post("p1"))

        let destination = workspace.goBack()
        #expect(destination == .shelf)
        // The shell now sets its selection, which reports the arrival back
        // here — the end-to-end idempotence claim.
        workspace.visit(.shelf)
        #expect(workspace.history().canGoForward, "the forward future survived the report")
        #expect(workspace.goForward() == .post("p1"))
    }

    @Test func returningToANoteMovesItToTheFrontOfTheStrip() {
        let workspace = WorkspaceModel()
        workspace.visit(.post("p1"))
        workspace.visit(.post("p2"))
        #expect(workspace.openNotes.ids == ["p2", "p1"])
        _ = workspace.goBack()
        workspace.visit(.post("p1"))  // the shell's report of the walk back
        #expect(workspace.openNotes.ids == ["p1", "p2"],
                "arriving IS opening, however you got there")
    }

    /// THE FREE-TILING RIDER (her ruling, round 2: *"make sure the
    /// architecture isn't going down a road closed to [free tiling]"*).
    /// Today one pane exists; the key exists anyway, and two panes'
    /// histories are already independent.
    @Test func historiesAreKeyedByPaneAndDoNotBleed() {
        let workspace = WorkspaceModel()
        let second = PaneID("second")
        workspace.visit(.shelf)
        workspace.visit(.post("p1"))
        workspace.visit(.reading("book"), in: second)
        workspace.visit(.post("p2"), in: second)

        #expect(workspace.history().origin == .shelf)
        #expect(workspace.history(second).origin == .reading("book"))
        #expect(workspace.goBack(in: second) == .reading("book"))
        #expect(workspace.history().current == .post("p1"),
                "the primary pane never moved")
        // The strip is the WINDOW's, not a pane's — both panes' notes are
        // open notes.
        #expect(Set(workspace.openNotes.ids) == ["p1", "p2"])
    }

    @Test func theChipStateIsSessionStateAndStartsShowing() {
        let workspace = WorkspaceModel()
        #expect(!workspace.backChipCollapsed, "expanded by default — it is a name, unfolded")
        workspace.backChipCollapsed = true
        #expect(workspace.backChipCollapsed)
    }

    /// Her guarantee, at the layer that could break it: closing a row is
    /// PURE VIEW STATE. The note stays live in the store and opens straight
    /// back.
    @Test func closingARowNeverTouchesTheStore() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "Keep me")
            }
            let workspace = WorkspaceModel()
            workspace.visit(.post(post.id))
            #expect(workspace.openNotes.ids == [post.id])

            workspace.closeNote(post.id)
            #expect(workspace.openNotes.ids.isEmpty)

            let live = try await db.read { db in
                try Queries.containerHeader(db, containerID: post.id)
            }
            #expect(live?.title == "Keep me", "closing a ROW deletes nothing")
        }
    }

    @Test func titlesResolveForEveryKindOnScreen() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 3))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let (post, book) = try await session.runner.run { ops in
                (try ops.createPost(title: "The Long Way Home"),
                 try ops.createReading(name: "Field Notes", kind: .curated))
            }
            let workspace = WorkspaceModel()
            workspace.visit(.reading(book.id))
            workspace.visit(.post(post.id))
            await workspace.resolveTitles(session: session)

            #expect(workspace.label(for: .post(post.id)) == "The Long Way Home")
            #expect(workspace.label(for: .reading(book.id)) == "Field Notes",
                    "the chip names the book she came from")
        }
    }
}

// MARK: - The doors (registry + shell routing)

@MainActor
@Suite("The navigation doors (13f batch 3)")
struct NavigationDoorsTests {
    /// THE COLLISION SWEEP, MADE PERMANENT (the 13d A14 precedent). The
    /// sweep found ⌘[ and ⌘] free across `keyEquivalent`, every
    /// `.keyboardShortcut(` call site in `Variorum/`+`Shared/`, every
    /// `NSMenuItem` key equivalent, and the one `performKeyEquivalent`
    /// override (⌘S). This keeps the ONE table where keys are declared free
    /// of duplicates for good — including the next chord anyone adds.
    @Test func theKeyTableHasNoCollisionsAndTheNavigationKeysAreOurs() {
        var owners: [String: CapabilityID] = [:]
        for capability in CapabilityRegistry.all {
            guard let (key, modifiers) = EditorCommands.keyEquivalent(for: capability.id)
            else { continue }
            let chord = "\(key.character)|\(modifiers.rawValue)"
            #expect(owners[chord] == nil,
                    "\(capability.id) collides with \(owners[chord]?.rawValue ?? "") on \(chord)")
            owners[chord] = capability.id
        }
        #expect(owners["[|\(EventModifiers.command.rawValue)"] == .navigateBack)
        #expect(owners["]|\(EventModifiers.command.rawValue)"] == .navigateForward)
        // The ordinal families wire per index in the menu, never here — so
        // no ⌘⇧<digit> may appear in this table at all.
        let shiftCommand = EventModifiers([.command, .shift]).rawValue
        for digit in 1...9 {
            #expect(owners["\(digit)|\(shiftCommand)"] == nil,
                    "⌘⇧\(digit) belongs to the Open strip's per-ordinal wiring")
        }
        #expect(EditorCommands.keyEquivalent(for: .openNote) == nil,
                "the family declares one label and wires a key per row")
    }

    @Test func theNavigationDoorsAreDeclaredAndRendered() {
        let openNote = CapabilityRegistry.capability(.openNote)
        #expect(openNote.scope == .app, "a workspace act — no surface is behind another")
        #expect(openNote.shortcutLabel == "\u{2318}\u{21e7}1\u{2013}9")
        for id in [CapabilityID.openNote, .navigateBack, .navigateForward] {
            #expect(CapabilityRegistry.capability(id).doors == [.menuBar])
            #expect(EditorCommands.menuRendered.contains(id), "every shortcut is a menu item")
        }
        // W16's Compare half: a surface door on the peer column.
        #expect(CapabilityRegistry.capability(.openPeerPost).doors == [.surface])
        #expect(CompareBoardView.surfaceCapabilities.contains(.openPeerPost))
    }

    @Test func theNavigationDoorsAreGreyWhereTheyCannotAct() {
        let empty = CapabilityContext(mode: nil)
        for id in [CapabilityID.openNote, .navigateBack, .navigateForward] {
            #expect(!CapabilityRegistry.isEnabled(id, in: empty),
                    "\(id): a key that could only be dead is grey instead")
            #expect(!CapabilityRegistry.capability(id).unavailableNote.isEmpty,
                    "\(id) says why")
        }
        #expect(CapabilityRegistry.isEnabled(
            .openNote, in: CapabilityContext(mode: nil, openNoteCount: 1)))
        #expect(CapabilityRegistry.isEnabled(
            .navigateBack, in: CapabilityContext(mode: nil, canNavigateBack: true)))
        #expect(CapabilityRegistry.isEnabled(
            .navigateForward, in: CapabilityContext(mode: nil, canNavigateForward: true)))
        // Compare's peer door exists exactly where a peer column does.
        #expect(CapabilityRegistry.isEnabled(
            .openPeerPost, in: CapabilityContext(mode: .compare)))
        #expect(!CapabilityRegistry.isEnabled(
            .openPeerPost, in: CapabilityContext(mode: .write, writeEditorAttached: true)))
    }

    /// The shell's doors: every one of them names a DESTINATION and hands
    /// it to the router, which is what RootView adopts (P-4). Nothing here
    /// navigates itself.
    @Test func theShellDoorsRouteTheRightDestination() {
        let router = ShellRouter()
        router.workspace.visit(.shelf)
        router.workspace.visit(.reading("book"))
        router.workspace.visit(.post("p1"))

        router.goBack()
        #expect(router.pendingSelection == .reading("book"))
        router.pendingSelection = nil  // RootView consumes it
        router.workspace.visit(.reading("book"))

        router.goForward()
        #expect(router.pendingSelection == .post("p1"))
        router.pendingSelection = nil
        router.workspace.visit(.post("p1"))

        router.workspace.visit(.post("p2"))
        router.openNote(ordinal: 2)
        #expect(router.pendingSelection == .post("p1"), "⌘⇧2 = the second SHOWN row")
        router.pendingSelection = nil
        router.openNote(ordinal: 7)
        #expect(router.pendingSelection == nil, "a key past the strip does nothing")
    }

    /// The two halves that live in the VIEW and could not be caught by any
    /// pure pin: the registry context is wired to THIS window's workspace,
    /// and the pane's history is SEEDED with what the window already shows.
    ///
    /// Both are load-bearing and both fail silently. Unseeded, the very
    /// first navigation out of the shelf pushes nothing — the first back
    /// chip she could ever want is the one that never appears. Unwired, the
    /// menu's Back/Forward/Open Notes stay grey forever, because the
    /// router's defaults answer "no" to everything.
    @Test func mountingTheShellWiresTheContextAndSeedsThePane() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let router = ShellRouter()
            // Pre-fix defaults, stated so the assertions below discriminate.
            #expect(session.commandRouter.openNoteCount() == 0)

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
            for _ in 0..<200 where router.workspace.history().current == nil {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(5))
            }

            #expect(router.workspace.history().current == .shelf,
                    "the pane's history knows what it is already showing")
            router.workspace.visit(.post("p1"))
            #expect(session.commandRouter.openNoteCount() == 1,
                    "the registry context reads THIS window's workspace")
            #expect(session.commandRouter.canNavigateBack(),
                    "…and its pane's trail — the shelf is behind us")
            #expect(!session.commandRouter.canNavigateForward())
        }
    }

    @Test func aPaneWithNowhereToGoAsksForNothing() {
        let router = ShellRouter()
        router.workspace.visit(.shelf)
        router.goBack()
        router.goForward()
        #expect(router.pendingSelection == nil,
                "the doors are grey here; a race must not navigate anyway")
    }
}
