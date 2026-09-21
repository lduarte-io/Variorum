//
//  PaneSplitTests.swift
//  VariorumTests
//
//  Phase 13f, batch 4 — the SPLIT's pins (her W1/A25 ruling: two panes in
//  v1, with the free-tiling rider on the architecture; round 7.3: the split
//  NEVER shows one note twice).
//
//  Everything that DECIDES anything is pure arithmetic over pane keys and
//  is pinned as arithmetic: the MOUNT RULE, the divider's clamping, the
//  same-note rule, close-split, and the per-pane history the keys act on.
//
//  **The gate's two conditions live here** (the architect's ruling on the
//  batch-4 proposal, (c) — the flight latch stays model-local only if both
//  are PINNED, not assumed):
//
//  1. `aSplitWindowMountsExactlyOneDetailAndOneCommandHandler` — the
//     UNREPRESENTABILITY itself, asserted where it bites: with two panes on
//     screen the app-scoped singletons that assume one detail still see
//     exactly one. Loosen the mount rule and this goes red.
//  2. `aDetailUnmountingUnderAFocusMigrationStillLandsItsText` — the
//     pre-existing unmount path that the split gives a NEW trigger.
//
//  What is deliberately NOT claimed: how the divider FEELS to drag, how the
//  split LOOKS, and whether a click lands where a hand expects — those are
//  on the batch record's visual-verification-only list.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The mount rule (gate (b); condition (c)'s pure half)

@Suite("The pane mount rule (13f batch 4, W1/A25)")
struct PaneMountTests {
    /// **THE UNREPRESENTABILITY, as arithmetic.** P-3 across panes is this
    /// one property and nothing else: whatever the pane collection, exactly
    /// ONE pane mounts a live surface. `PaneTextAuthority` enforces
    /// one-live-ring INSIDE one authority, and every authority owner and
    /// every routed-command handler is mounted by a detail host — so this
    /// is what makes two panes safe without a second mechanism.
    @Test func exactlyOnePaneMountsALiveSurfaceWhateverTheCollection() {
        for count in 1...5 {
            let panes = (0..<count).map { PaneID("p\($0)") }
            for focused in panes {
                #expect(PaneMount.liveCount(panes: panes, focused: focused) == 1,
                        "\(count) panes, focus \(focused.raw)")
                #expect(PaneMount.kind(of: focused, focused: focused) == .live)
                for other in panes where other != focused {
                    #expect(PaneMount.kind(of: other, focused: focused) == .readCheap,
                            "every other pane is read-cheap — no authority, no handler")
                }
            }
        }
    }

    /// The corner the model has to close for the pin above to mean anything
    /// about the running app: a focus that is not a member would leave ZERO
    /// panes live. `WorkspaceModel.focus` refuses such a pane, so the
    /// invariant holds over the model, not merely over the function.
    @MainActor
    @Test func theModelNeverFocusesAPaneItDoesNotHave() {
        let workspace = WorkspaceModel()
        workspace.focus(PaneID("nobody"))
        #expect(workspace.focusedPane == .primary)
        #expect(PaneMount.liveCount(
            panes: workspace.panes, focused: workspace.focusedPane) == 1)

        _ = workspace.openBeside(.post("p2"))
        #expect(workspace.panes.count == 2)
        #expect(PaneMount.liveCount(
            panes: workspace.panes, focused: workspace.focusedPane) == 1,
                "still exactly one, with a split open")
    }
}

// MARK: - The divider's arithmetic

@Suite("Pane layout (13f batch 4)")
struct PaneLayoutTests {
    @Test func evenFractionsSplitTheRowAndTheWidthsAgree() {
        #expect(PaneLayout.evenFractions(paneCount: 1).isEmpty)
        #expect(PaneLayout.evenFractions(paneCount: 2) == [0.5])
        let widths = PaneLayout.widths(total: 1000, fractions: [0.5])
        #expect(widths == [500, 500])
        // Three panes generalize with no shape change (the free-tiling
        // rider: fractions are a divider LIST, never a left/right pair).
        let thirds = PaneLayout.evenFractions(paneCount: 3)
        let three = PaneLayout.widths(total: 900, fractions: thirds)
        #expect(three.count == 3)
        #expect(three.allSatisfy { abs($0 - 300) < 0.001 })
        // A zero-width row is arithmetic, not a crash.
        #expect(PaneLayout.widths(total: 0, fractions: [0.5]) == [0, 0])
    }

    @Test func aDividerDragCanNeverSwallowAPane() {
        let min = PaneLayout.minimumFraction
        // Dragged to the far left and the far right: both clamp.
        #expect(PaneLayout.moving([0.5], divider: 0, to: -3) == [min])
        #expect(PaneLayout.moving([0.5], divider: 0, to: 9) == [1 - min])
        // In range, it goes where it was put.
        #expect(PaneLayout.moving([0.5], divider: 0, to: 0.62) == [0.62])
        // With three panes a divider is clamped by its NEIGHBOURS, not by
        // the row's edges.
        let three = PaneLayout.moving([0.33, 0.66], divider: 1, to: 0.0)
        #expect(three[1] == 0.33 + min)
        #expect(three[0] == 0.33, "the untouched divider does not move")
        // An index that does not exist is inert.
        #expect(PaneLayout.moving([0.5], divider: 4, to: 0.1) == [0.5])
    }
}

// MARK: - The split's acts

@MainActor
@Suite("The split (13f batch 4, W1/A25)")
struct PaneSplitModelTests {
    @Test func openBesideMintsASecondPaneShowingTheOtherNote() {
        let workspace = WorkspaceModel()
        workspace.select(.post("a"))
        #expect(workspace.panes.count == 1)

        let outcome = workspace.openBeside(.post("b"))
        guard case .opened(let pane) = outcome else {
            Issue.record("expected a new pane, got \(outcome)")
            return
        }
        #expect(workspace.panes.count == 2)
        #expect(workspace.selections[pane] == .post("b"))
        #expect(workspace.selections[.primary] == .post("a"), "the first pane is untouched")
        #expect(workspace.focusedPane == pane, "the note you just opened is where you are")
        #expect(workspace.splitFractions == [0.5])
    }

    /// **HER ROUND-7.3 RULING**, both doors: *"definitely not two live side
    /// by sides - we already offer that for one note."*
    @Test func theSplitNeverShowsOneNoteTwice() {
        let workspace = WorkspaceModel()
        workspace.select(.post("a"))
        guard case .opened(let second) = workspace.openBeside(.post("b")) else {
            Issue.record("setup")
            return
        }

        // Door 1 — Open Beside on a note the other pane already shows.
        #expect(workspace.openBeside(.post("a")) == .focusedExistingPane(.primary))
        #expect(workspace.panes.count == 2, "no third pane, no duplicate")
        #expect(workspace.focusedPane == .primary, "you are moved to where it is")

        // Door 2 — ORDINARY navigation (a sidebar click, ⌘K, ⌘⇧n): the
        // rule lives at the one adoption door, so it cannot be bypassed by
        // adding a door.
        #expect(workspace.select(.post("b"), in: .primary) == .focusedExistingPane(second))
        #expect(workspace.selections[.primary] == .post("a"),
                "the focused pane's own note is NOT replaced")
        #expect(workspace.focusedPane == second)

        // Door 3 — "beside itself": the same refusal, because it is the
        // same ask.
        #expect(workspace.openBeside(.post("b")) == .focusedExistingPane(second))

        // A scraps container counts as a note (it opens a detail host too).
        #expect(workspace.select(.pool("scraps"), in: .primary) == .adopted)
        #expect(workspace.openBeside(.pool("scraps")) == .focusedExistingPane(.primary))

        // A non-note destination is NOT covered — two panes on the shelf is
        // nobody's confusion, and the rule is about notes.
        #expect(workspace.select(.shelf, in: second) == .adopted)
        #expect(workspace.select(.shelf, in: .primary) == .adopted)
    }

    @Test func theRefusalNamesTheSurfacesThatDoShowOneNoteSideBySide() {
        let sentence = WorkspaceNaming.sameNoteNote("Chapter One")
        #expect(sentence.contains("Chapter One"))
        #expect(sentence.contains("Lenses"))
        #expect(sentence.contains("Compare"))
    }

    @Test func closingTheSplitFoldsTheWindowBackAndDeletesNothing() {
        let workspace = WorkspaceModel()
        workspace.select(.post("a"))
        guard case .opened(let second) = workspace.openBeside(.post("b")) else {
            Issue.record("setup")
            return
        }
        workspace.select(.post("c"), in: second)   // the second pane has a trail
        #expect(workspace.history(second).canGoBack)

        #expect(workspace.closeSplit())
        #expect(workspace.panes == [.primary])
        #expect(workspace.focusedPane == .primary)
        #expect(workspace.splitFractions.isEmpty)
        #expect(workspace.selections[second] == nil)
        #expect(workspace.history(second).canGoBack == false, "the pane's trail goes with it")
        // Closing a PANE is not closing a NOTE: both are still open.
        #expect(Set(workspace.openNotes.ids) == ["a", "b", "c"])

        #expect(workspace.closeSplit() == false, "nothing to close, and it says so")
    }

    /// Item 3: each pane keys its own history, and ⌥⌘[ / ⌥⌘] act on the
    /// FOCUSED one — which is what `history()`'s focus-aware default buys,
    /// at the model, for the registry closures and the keys alike.
    @Test func eachPaneWalksItsOwnTrailAndTheKeysFollowTheFocus() {
        let workspace = WorkspaceModel()
        workspace.visit(.shelf)
        workspace.select(.post("a"))
        guard case .opened(let second) = workspace.openBeside(.post("b")) else {
            Issue.record("setup")
            return
        }
        workspace.select(.post("c"), in: second)

        // Focus is on the second pane, so the default IS the second pane.
        #expect(workspace.focusedPane == second)
        #expect(workspace.history().origin == .post("b"))
        #expect(workspace.goBack() == .post("b"), "⌥⌘[ walked the focused pane")
        #expect(workspace.history(.primary).current == .post("a"),
                "the other pane never moved")

        workspace.focus(.primary)
        #expect(workspace.history().origin == .shelf, "…and now the default is the other one")
        #expect(workspace.goBack() == .shelf)
        #expect(workspace.history(second).current == .post("b"))
    }

    /// **THE COLD REVIEW'S R1-2 PIN (red on the pre-fix code).** The menu's
    /// ⌥⌘[ / ⌥⌘] go through the ROUTER, whose old `.primary` default pinned
    /// the model's focus-aware default shut. Two arms, both real states:
    /// with a split's second pane focused, `router.goBack()` popped the
    /// PRIMARY pane's trail (and the popped destination was then adopted
    /// into the FOCUSED pane — wrong pane mutated, wrong destination
    /// navigated); and after closing the split from the primary pane, the
    /// keys were permanently inert in the surviving pane while the menu
    /// stayed enabled — a durable dead key.
    @Test func theMenuKeysWalkTheFocusedPanesTrailThroughTheRouter() {
        let router = ShellRouter()
        let workspace = router.workspace
        workspace.visit(.shelf)
        workspace.select(.post("a"))
        guard case .opened(let second) = workspace.openBeside(.post("b")) else {
            Issue.record("setup")
            return
        }
        workspace.select(.post("c"), in: second)

        // Arm 1: the split, second pane focused — ⌥⌘[ walks the FOCUSED trail.
        #expect(workspace.focusedPane == second)
        router.goBack()
        #expect(router.pendingSelection == .post("b"),
                "⌥⌘[ walked the focused pane's trail, not the primary's")
        #expect(workspace.history(.primary).current == .post("a"),
                "the primary pane's trail never moved")
        router.pendingSelection = nil

        // Arm 2: close the split FROM the primary pane — the survivor's
        // keys keep working (the `.primary` key left with its pane).
        workspace.focus(.primary)
        #expect(workspace.closeSplit())
        #expect(workspace.focusedPane == second, "focus landed on the survivor")
        router.goForward()  // arm 1's walk-back left a forward future
        #expect(router.pendingSelection == .post("c"),
                "⌥⌘] still works in the surviving pane")
    }

    @Test func theOpenBesideCandidateIsTheMostRecentNoteNoPaneIsShowing() {
        let workspace = WorkspaceModel()
        #expect(workspace.openBesideCandidate == nil, "nothing open — the door is grey")

        workspace.select(.post("a"))
        #expect(workspace.openBesideCandidate == nil,
                "the only open note is the one you are in")

        workspace.select(.post("b"))
        #expect(workspace.openBesideCandidate == "a",
                "the most recently opened note no pane shows")

        guard case .opened = workspace.openBeside(.post("a")) else {
            Issue.record("expected a pane")
            return
        }
        #expect(workspace.openBesideCandidate == nil,
                "both open notes are on screen — nothing left to put beside")
    }

    /// Beyond the v1 cap the note lands in the OTHER pane rather than
    /// minting a third — her two-panes-in-v1 ruling, expressed as a CAP on
    /// a collection (raising it is all free tiling needs here).
    @Test func atTheCapTheNoteReplacesTheOtherPaneRatherThanMintingAThird() {
        let workspace = WorkspaceModel()
        workspace.select(.post("a"))
        guard case .opened(let second) = workspace.openBeside(.post("b")) else {
            Issue.record("setup")
            return
        }
        workspace.focus(second)

        guard case .opened(let target) = workspace.openBeside(.post("c")) else {
            Issue.record("expected a pane")
            return
        }
        #expect(workspace.panes.count == WorkspaceModel.maximumPanes)
        #expect(target == .primary, "it went to the pane you were not in")
        #expect(workspace.selections[.primary] == .post("c"))
        #expect(workspace.selections[second] == .post("b"))
    }
}

// MARK: - The book's half of the mount rule

@MainActor
@Suite("A book in an unfocused pane (13f batch 4)")
struct PaneBookBlurTests {
    /// The mount rule reaches a BOOK through the book's OWN single focus
    /// authority (`BookViewModel.focusedPostID`, 13b 3E's fold) — a second
    /// REASON for one mechanism to answer nil, never a second mechanism.
    /// The reading position itself survives, so regaining the pane restores
    /// exactly what she was editing.
    @Test func aBookBesideHerMountsNothingLiveAndClaimsThePaneWhenClicked() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let model = BookViewModel(session: session, readingID: "r")

            model.focus("p1")
            #expect(model.liveFocusedPostID == "p1", "a focused pane mounts its editor")

            model.paneFocused = false
            #expect(model.liveFocusedPostID == nil,
                    "a book beside the pane she is typing in mounts NOTHING live")
            #expect(model.focusedPostID == "p1",
                    "…while the reading position is remembered, not discarded")

            var asked = 0
            model.onPaneFocusRequest = { asked += 1 }
            model.focus("p2")
            #expect(asked == 1,
                    "clicking a post in an unfocused pane claims the PANE first — one click")

            model.paneFocused = true
            #expect(model.liveFocusedPostID == "p2")
            model.focus("p3")
            #expect(asked == 1, "a focused pane asks for nothing")
        }
    }
}

// MARK: - The doors, and THE GATE'S CONDITION (c)(1)

@MainActor
@Suite("The split's doors (13f batch 4)")
struct PaneSplitDoorTests {
    @Test func theSplitDoorsAreDeclaredAndGreyWhereTheyCannotAct() {
        for id in [CapabilityID.openBeside, .closeSplit] {
            let capability = CapabilityRegistry.capability(id)
            #expect(capability.doors.contains(.menuBar))
            #expect(!capability.unavailableNote.isEmpty)
        }
        #expect(CapabilityRegistry.capability(.openBeside).doors.contains(.contextMenu),
                "the row doors are declared, not improvised")

        // Grey where they can only refuse — the `undoAvailable` stack-gate
        // shape, never a mode gate.
        #expect(!CapabilityRegistry.isEnabled(.openBeside, in: CapabilityContext(mode: nil)))
        #expect(CapabilityRegistry.isEnabled(
            .openBeside, in: CapabilityContext(mode: nil, canOpenBeside: true)))
        #expect(!CapabilityRegistry.isEnabled(.closeSplit, in: CapabilityContext(mode: nil)))
        #expect(CapabilityRegistry.isEnabled(
            .closeSplit, in: CapabilityContext(mode: nil, paneCount: 2)))
    }

    @Test func theShellSpeaksTheSameNoteRefusalAndOpensTheSplitOtherwise() {
        let router = ShellRouter()
        var spoken: [String] = []
        router.refuse = { spoken.append($0) }
        router.workspace.select(.post("a"))

        router.openBeside(.post("b"))
        #expect(router.workspace.panes.count == 2)
        #expect(spoken.isEmpty, "a split that opened has nothing to explain")

        router.openBeside(.post("a"))
        #expect(router.workspace.panes.count == 2, "still two — never a duplicate")
        #expect(spoken.count == 1)
        #expect(spoken.first?.contains("Lenses") == true)

        // The menu door picks the most recent note no pane shows; with both
        // notes on screen there is none, so it is inert (and grey).
        spoken.removeAll()
        router.openBesideMostRecent()
        #expect(spoken.isEmpty, "grey doors do not speak when raced")

        router.closeSplit()
        #expect(router.workspace.panes.count == 1)
    }

    /// **THE GATE'S CONDITION (c)(1) — the unrepresentability where it
    /// BITES.** The flight latch may stay model-local only because two
    /// door-bearing surfaces cannot co-mount. That claim is about the
    /// running app, not about a pure function, so it is asserted against
    /// the three app-scoped singletons that assume ONE detail: the routed
    /// command handler stack (LIFO — two handlers means every ⌘S and every
    /// structural act reaches the wrong surface), and the single detail
    /// registration behind ⌘1–⌘6 and the sidebar rail.
    ///
    /// Loosen `PaneMount.kind` and this goes red.
    @Test func aSplitWindowMountsExactlyOneDetailAndOneCommandHandler() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let left = try session.operations.createPost(title: "Left", profile: nil)
            let right = try session.operations.createPost(title: "Right", profile: nil)
            _ = try session.operations.newBlock(in: left.id, text: "left text")
            _ = try session.operations.newBlock(in: right.id, text: "right text")

            let router = ShellRouter()
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1200, height: 700),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            window.contentView = NSHostingView(
                rootView: RootView(session: session, services: nil, router: router))
            window.makeKeyAndOrderFront(nil)
            // Wait for the mount before routing: `onChange` never fires for
            // an initial value, so a request made before the shell exists
            // is a request nobody hears (batch 3's shell-mount discipline).
            await settle(until: { router.workspace.history().current == .shelf })

            router.pendingSelection = .post(left.id)
            await settle(until: { session.commandRouter.activePostID == left.id })
            #expect(session.commandRouter.handlerCount == 1,
                    "one pane, one mounted surface — the baseline")

            router.openBeside(.post(right.id))
            await settle(until: {
                router.workspace.panes.count == 2
                    && session.commandRouter.activePostID == right.id
            })

            #expect(router.workspace.panes.count == 2, "the split is really on screen")
            #expect(session.commandRouter.handlerCount == 1,
                    "TWO PANES, ONE HANDLER — the mount rule, where it bites")
            #expect(session.commandRouter.activePostID == right.id,
                    "and the one detail is the FOCUSED pane's, never last-mounted-wins")

            // Migrate the ring back: the count never grows, and the single
            // registration follows the focus rather than accumulating.
            router.workspace.focus(.primary)
            await settle(until: { session.commandRouter.activePostID == left.id })
            #expect(session.commandRouter.handlerCount == 1)
            #expect(session.commandRouter.activePostID == left.id)
        }
    }

    /// Bounded polling — a hosted SwiftUI mount is asynchronous, and a
    /// spin without a bound is a hang, not a test (the standing trap).
    private func settle(until condition: @MainActor () -> Bool) async {
        for _ in 0..<300 where !condition() {
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(5))
        }
    }
}

// MARK: - THE GATE'S CONDITION (c)(2)

@MainActor
@Suite("A detail unmounting under the split's new trigger (13f batch 4)")
struct PaneUnmountTests {
    /// **THE GATE'S CONDITION (c)(2).** Clicking the other pane makes this
    /// one read-cheap, which unmounts its detail — a path that already
    /// existed (a sidebar click during a ceremony does it) but that the
    /// split gives a NEW trigger. The backstop is `teardown()`'s
    /// `finalizeWork`, which flushes through the post's own autosave
    /// coordinator while holding the model alive. Pinned, not assumed.
    @Test func aDetailUnmountingUnderAFocusMigrationStillLandsItsText() async throws {
        try await withEditor(seedBlocks: ["kept"]) { h in
            h.type("X", at: 4)
            let beforeUnmount = try h.storeSlots().map(\.text)
            #expect(beforeUnmount == ["kept"],
                    "the buffer is dirty and NOT yet in the store — the pin's whole premise")

            // The trigger, stated in the terms this batch introduces.
            #expect(PaneMount.kind(of: .primary, focused: PaneID("other")) == .readCheap)

            await h.model.teardown()?.value

            #expect(try h.storeSlots().map(\.text) == ["keptX"],
                    "the unmount landed the text — nothing typed is lost to a pane click")
        }
    }
}

// MARK: - 13g L6 (WT-6): the pane's own click-to-focus door

/// **THE TRACE this suite pins closed** (her walkthrough, round 2): a pane's
/// body-click focus door existed only where a CONTENT surface happened to
/// carry one — the read tier (notes and scraps) and, partially, a book. The
/// list surfaces (Shelf, Library, Pool, Snippets, a tag folder, the recovery
/// surface) had none, so the only way to focus such a pane without ALSO
/// navigating it was the name line. The door now belongs to the PANE, which
/// is the level at which "either pane" can be true at all.
///
/// The decision is arithmetic over a rectangle — no "left", no "right" —
/// because per-side reasoning is exactly what made the bug hard to see.
@MainActor
@Suite("Pane click-to-focus (13g L6, WT-6)")
struct PaneFocusCatcherTests {
    @Test func aClickInsideAnActivePaneClaimsItAndOneOutsideDoesNot() {
        let pane = CGRect(x: 400, y: 0, width: 400, height: 600)
        #expect(PaneFocusClick.shouldFocus(
            clickInWindow: CGPoint(x: 500, y: 300), paneFrameInWindow: pane,
            active: true, sameWindow: true))
        #expect(!PaneFocusClick.shouldFocus(
            clickInWindow: CGPoint(x: 100, y: 300), paneFrameInWindow: pane,
            active: true, sameWindow: true), "the other pane's click is not ours")
        // The FOCUSED pane installs nothing: a click there is already home.
        #expect(!PaneFocusClick.shouldFocus(
            clickInWindow: CGPoint(x: 500, y: 300), paneFrameInWindow: pane,
            active: false, sameWindow: true))
        // A click in ANOTHER window never moves this window's focus (the
        // monitor is app-wide; the decision is not).
        #expect(!PaneFocusClick.shouldFocus(
            clickInWindow: CGPoint(x: 500, y: 300), paneFrameInWindow: pane,
            active: true, sameWindow: false))
    }

    /// The WIRE: a real view in a real window, a real left mouse-down event,
    /// the catcher's own monitor installed and removed with liveness, and
    /// the monitor's real body — geometry conversion, window identity and
    /// the active gate included. Red on the pre-13g code by construction:
    /// no pane had a door of its own to install.
    ///
    /// The one step the host cannot deliver is `NSApp`'s dispatch: a
    /// synthesized event pushed through `NSApp.sendEvent` never reaches a
    /// local monitor (measured while writing this pin — the monitor sees
    /// events coming off the event queue). So installation is asserted
    /// through `isWatching` and the body is driven directly, which is the
    /// honest pair; the untested step is AppKit calling a monitor it holds.
    @Test func aClickInThePaneFiresTheDoorWithoutConsumingTheEvent() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled], backing: .buffered, defer: true)
        let catcher = PaneFocusCatcherView(
            frame: NSRect(x: 400, y: 0, width: 400, height: 600))
        window.contentView?.addSubview(catcher)

        var focused = 0
        catcher.onFocus = { focused += 1 }
        #expect(!catcher.isWatching, "nothing is watching until the pane goes read-cheap")
        catcher.active = true
        defer { catcher.remove() }
        #expect(catcher.isWatching, "the unfocused pane installed its own door")

        func click(at point: NSPoint) -> NSEvent? {
            NSEvent.mouseEvent(
                with: .leftMouseDown, location: point, modifierFlags: [],
                timestamp: ProcessInfo.processInfo.systemUptime,
                windowNumber: window.windowNumber, context: nil,
                eventNumber: 0, clickCount: 1, pressure: 1)
        }

        guard let inside = click(at: NSPoint(x: 600, y: 300)),
              let outside = click(at: NSPoint(x: 100, y: 300))
        else {
            Issue.record("could not synthesize a mouse event")
            return
        }

        catcher.handleLocalMouseDown(inside)
        #expect(catcher.focusRequests == 1, "the door claimed the click")
        #expect(focused == 1, "…and the pane was asked for")

        catcher.handleLocalMouseDown(outside)
        #expect(catcher.focusRequests == 1, "a click in the sibling pane is not ours")

        // Live again ⇒ the monitor comes down and the body goes inert; a
        // click in the pane you are already in must change nothing.
        catcher.active = false
        #expect(!catcher.isWatching, "no monitor while the pane is live")
        catcher.handleLocalMouseDown(inside)
        #expect(catcher.focusRequests == 1)

        // Leaving the window takes the monitor with it — no monitor outlives
        // the pane that installed it.
        catcher.active = true
        #expect(catcher.isWatching)
        catcher.removeFromSuperview()
        #expect(!catcher.isWatching, "a pane that left the window stops watching")
    }

    /// It never becomes a hit-test target: the click it reports still
    /// belongs to whatever is above it. This is the difference between this
    /// and an overlay — an overlay would eat the read tier's caret offset
    /// and every list row's first click.
    @Test func theCatcherNeverIntercepts() {
        let catcher = PaneFocusCatcherView(frame: NSRect(x: 0, y: 0, width: 10, height: 10))
        #expect(catcher.hitTest(NSPoint(x: 5, y: 5)) == nil)
    }
}

// MARK: - 13g L5 (WT-5/F-4): the unfocused pane says what it is holding

@Suite("The unfocused pane's line (13g L5, WT-5)")
struct PaneHeldModeTests {
    /// Her report: *"it's a bit confusing to see it return to read ? or
    /// write ? mode when you click away from it, if you were just in
    /// takes."* The pane had not changed mode — it renders read-cheap, which
    /// LOOKS like Write — so the fix at this layer is to say so.
    @Test func aPaneNamesTheModeItIsHolding() {
        #expect(WorkspaceNaming.paneLine("orbit", mode: .takes) == "orbit \u{00B7} takes")
        #expect(WorkspaceNaming.paneLine("orbit", mode: .compare) == "orbit \u{00B7} compare")
        // Where a mode is not a thing the pane has (the shelf, a book, a
        // folder, a scraps container) the pane wears its name alone.
        #expect(WorkspaceNaming.paneLine("Shelf", mode: nil) == "Shelf")
    }

    /// STICKY, and read from ONE source: the line names exactly what the
    /// detail will restore, because both read the per-note memory. A second
    /// piece of pane state could disagree — and a mode row that lies is
    /// worse than none.
    @MainActor
    @Test func theLineAgreesWithWhatTheDetailWillRestore() {
        let defaults = UserDefaults.standard
        let postID = "pane-mode-\(UUID().uuidString)"
        let key = "postMode.\(postID)"
        defer { defaults.removeObject(forKey: key) }

        #expect(PostDetailView.rememberedMode(postID: postID) == .write,
                "an unvisited note opens in Write (S4-20)")
        defaults.set(PostMode.takes.rawValue, forKey: key)
        #expect(PostDetailView.rememberedMode(postID: postID) == .takes)
        #expect(WorkspaceNaming.paneLine(
            "orbit", mode: PostDetailView.rememberedMode(postID: postID))
            == "orbit \u{00B7} takes")
    }
}
