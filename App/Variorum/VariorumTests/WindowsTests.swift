//
//  WindowsTests.swift
//  VariorumTests
//
//  Phase 13f, batch 5b — SEVERAL WINDOWS (her W2/A26 ruling, round 2: *both*
//  window kinds; round 13: a note MAY show in two windows — only one is ever
//  live).
//
//  **The architect's three conditions live here** (the ruling on the windows
//  proposal, (b) — the key-window mount gate ships only if all three are
//  PINNED, not assumed):
//
//  1. `twoWindowsMountExactlyOneDetailAndOneCommandHandler` — the
//     unrepresentability at WINDOW scale, the R4-A shape with two hosted
//     windows: `handlerCount` stays 1 and `activePostID` follows the KEY
//     window across a key migration in both directions.
//  2. `aDetailUnmountingWhenItsWindowStopsBeingKeyStillLandsItsText` — the
//     teardown/flush backstop at window scale, premise-asserted like batch
//     4's.
//  3. `theStickyKeySurvivesAppDeactivation` — the key-ness input is
//     LAST-KNOWN-KEY, never literal `keyWindow`-now: a resign with no
//     successor window (⌘-tab to another app) unmounts and remounts
//     NOTHING.
//
//  ── WHAT THIS HOST CAN AND CANNOT DRIVE (measured, not assumed) ──────────
//  Measured on macOS 26.5.2 while building this batch: in the XCTest host
//  `NSApp.isActive` is false and `makeKeyAndOrderFront(_:)` does **not**
//  make a window key — `isKeyWindow` stays false for every window and no
//  `didBecomeKey` ever fires by itself. So these pins POST
//  `NSWindow.didBecomeKeyNotification` / `didResignKeyNotification` for a
//  real hosted window, which is the exact notification AppKit posts on a
//  click: the whole chain — reporter → `WindowRegistry` → `PaneMount` → the
//  three app-scoped singletons — is under test, and the one thing that is
//  not is AppKit's own posting of it under a real hand. That half is on the
//  batch record's visual-verification list, stated rather than claimed.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The registry's arithmetic

@MainActor
@Suite("The window registry (13f batch 5b)")
struct WindowRegistryTests {
    /// **THE STICKY KEY, as arithmetic** (the ruling's condition 3): the key
    /// moves only when another window becomes key, or when the key window
    /// closes. There is no resign door at all — and the fallback covers the
    /// state before anything has ever been key, which is a real state in the
    /// app (a window that just opened) as well as this host's permanent one.
    @Test func theKeyIsStickyAndFallsBackToTheFirstWindowRegistered() {
        let registry = WindowRegistry()
        let a = UUID(), b = UUID(), c = UUID()
        let routerA = ShellRouter(), routerB = ShellRouter(), routerC = ShellRouter()

        #expect(registry.activeWindowID == nil, "no windows, nothing live")
        registry.register(a, router: routerA, kind: .full)
        registry.register(b, router: routerB, kind: .full)
        #expect(registry.activeWindowID == a, "nothing has been key — the first registered")
        #expect(registry.activeRouter === routerA)

        registry.noteKey(b)
        #expect(registry.isKey(b))
        #expect(!registry.isKey(a))
        #expect(registry.activeRouter === routerB)

        registry.noteKey(b)
        #expect(registry.isKey(b), "idempotent")

        // A THIRD window opening does not steal the key — only becoming key
        // does. (In the app AppKit makes a new window key and the reporter
        // says so; the registry never guesses.)
        registry.register(c, router: routerC, kind: .full)
        #expect(registry.isKey(b))

        // An unknown id is ignored rather than becoming a key nobody renders.
        registry.noteKey(UUID())
        #expect(registry.isKey(b))

        // Closing the key window: the key leaves with it and the fallback
        // catches — never a nil active window while any window is open.
        registry.unregister(b)
        #expect(registry.activeWindowID == a)
        #expect(registry.activeRouter === routerA)
        registry.unregister(a)
        registry.unregister(c)
        #expect(registry.activeWindowID == nil)
    }

    /// A NOTE-ONLY window can be key — it owns the live surface while she is
    /// typing in it — but it can never be the target of a navigation
    /// broadcast, because it navigates nowhere. Making that rule `isKey`
    /// would have turned a book link clicked there into a dead door, which
    /// is precisely the class W20 exists to kill.
    @Test func theNavigationTargetIsTheKeyFullWindowElseTheMostRecentFullOne() {
        let registry = WindowRegistry()
        let full = UUID(), note = UUID(), otherFull = UUID()
        registry.register(full, router: ShellRouter(), kind: .full)
        registry.register(note, router: ShellRouter(), kind: .noteOnly)

        registry.noteKey(note)
        #expect(registry.isKey(note), "the note-only window owns the live surface")
        #expect(registry.navigationTargetID == full,
                "…and the full window is where a navigation lands")
        #expect(registry.isNavigationTarget(full))
        #expect(!registry.isNavigationTarget(note))

        // With TWO full windows the target is the most recently key one —
        // so one broadcast navigates exactly one window, never both.
        registry.register(otherFull, router: ShellRouter(), kind: .full)
        registry.noteKey(otherFull)
        #expect(registry.navigationTargetID == otherFull)
        registry.noteKey(full)
        #expect(registry.navigationTargetID == full)

        registry.unregister(full)
        registry.unregister(otherFull)
        #expect(registry.navigationTargetID == nil,
                "only a note-only window is open — nothing can navigate, and it says so")
    }
}

// MARK: - The mount rule at window scale

@Suite("The key-window mount gate (13f batch 5b)")
struct PaneMountWindowTests {
    /// **THE APP-SCALE INVARIANT, as arithmetic.** Whatever the windows and
    /// whatever their panes: exactly ONE pane in ONE window mounts a live
    /// surface — which is what keeps `CommandRouter`'s single detail
    /// registration, its LIFO handler stack and `EditorRouter.active`
    /// correct with two windows open, exactly as the pane rule keeps them
    /// correct inside one.
    @Test func exactlyOnePaneInOneWindowMountsALiveSurface() {
        for windowCount in 1...3 {
            for keyIndex in 0..<windowCount {
                let windows = (0..<windowCount).map { w in
                    PaneMount.WindowState(
                        panes: [PaneID("w\(w)-a"), PaneID("w\(w)-b")],
                        focused: PaneID("w\(w)-a"), isKey: w == keyIndex)
                }
                #expect(PaneMount.liveCount(across: windows) == 1,
                        "\(windowCount) windows, key \(keyIndex)")
            }
        }
        // No key window at all (the state between a close and the fallback
        // catching up) mounts nothing live — never two.
        let none = [
            PaneMount.WindowState(panes: [.primary], focused: .primary, isKey: false),
            PaneMount.WindowState(panes: [.primary], focused: .primary, isKey: false),
        ]
        #expect(PaneMount.liveCount(across: none) == 0)
    }

    /// A pane in a NON-key window is read-cheap even when it is that
    /// window's focused pane — the gate is `AND`, not `OR`.
    @Test func aFocusedPaneInANonKeyWindowIsStillReadCheap() {
        #expect(PaneMount.kind(of: .primary, focused: .primary, windowIsKey: false)
            == .readCheap)
        #expect(PaneMount.kind(of: .primary, focused: .primary, windowIsKey: true) == .live)
        #expect(PaneMount.liveCount(panes: [.primary], focused: .primary, windowIsKey: false)
            == 0)
        // The batch-4 reading is untouched: one window, and the default is
        // key (the parity proof — every batch-4 pin reads unchanged).
        #expect(PaneMount.kind(of: .primary, focused: .primary) == .live)
    }
}

// MARK: - The note-only window's honest greys

@MainActor
@Suite("The note-only window (13f batch 5b, ruling (d))")
struct NoteOnlyWindowTests {
    /// `showOnly` shows the note and records NOTHING — and that silence is
    /// the whole mechanism behind the ruling's promise that every app-scope
    /// act resolves honestly grey there through the gates that already
    /// exist. Not one new availability rule was written for this window.
    @Test func aNoteOnlyWindowShowsItsNoteAndEveryAppScopeActIsHonestlyGrey() {
        let workspace = WorkspaceModel()
        workspace.showOnly(.post("p1"))

        #expect(workspace.selections[.primary] == .post("p1"), "the note is on screen")
        #expect(workspace.openNotes.ids.isEmpty, "no Open strip")
        #expect(workspace.history().canGoBack == false)
        #expect(workspace.history().canGoForward == false)
        #expect(workspace.openBesideCandidate == nil)
        #expect(workspace.panes.count == 1)
        #expect(workspace.recentBookIDs.isEmpty)

        // The four greys, read through the SAME registry gates the main
        // window uses — the context a note-only window produces.
        let context = CapabilityContext(
            mode: .write, writeEditorAttached: true,
            openNoteCount: workspace.openNotes.ids.count,
            canNavigateBack: workspace.history().canGoBack,
            canNavigateForward: workspace.history().canGoForward,
            paneCount: workspace.panes.count,
            canOpenBeside: workspace.openBesideCandidate != nil)
        for id in [CapabilityID.openNote, .navigateBack, .navigateForward,
                   .openBeside, .closeSplit] {
            #expect(!CapabilityRegistry.isEnabled(id, in: context),
                    "\(id) is honestly grey in a note-only window")
        }
        // …while everything editing-scoped works exactly as in the main
        // window, because it routes through the app's CommandRouter and this
        // window mounts the live detail when it is key.
        #expect(CapabilityRegistry.isEnabled(.commitTake, in: context))
        #expect(CapabilityRegistry.isEnabled(.divide, in: context))
    }

    /// The door that opens one (P-1): ONE declaration, rendered by the
    /// note-row family. `File ▸ New Window` deliberately has none — it is a
    /// system-standard File item, and nothing in this registry duplicates
    /// one (the ruled reason).
    @Test func theOpenInNewWindowDoorIsDeclaredOnTheNoteRowFamily() {
        let capability = CapabilityRegistry.capability(.openInNewWindow)
        #expect(!capability.verb.isEmpty)
        #expect(capability.doors == [.contextMenu])
        #expect(capability.scope == .app, "a window act, never an editing one")
        #expect(SidebarView.contextMenuCapabilities.contains(.openInNewWindow),
                "the note rows render what the registry declares")
        // Rendered ONLY on a note row, so its target always exists — the
        // `.diffAgainstChosen` split, and why `always` is the honest gate
        // rather than a missing one.
        #expect(CapabilityRegistry.isEnabled(.openInNewWindow, in: CapabilityContext(mode: nil)))
    }
}

// MARK: - Independent workspaces (what batch 3 promised, now true)

@MainActor
@Suite("Two windows, two workspaces (13f batch 5b)")
struct IndependentWorkspaceTests {
    /// Batch 3 said the workspace hangs off `ShellRouter` "so the state is
    /// per-window by construction the moment batch 4 mints a second window".
    /// Batch 4 found that was false for WINDOWS (the router was App-level
    /// `@State`, shared by the whole `WindowGroup`). This is the claim made
    /// true: two windows, two Open strips, two sets of histories, two folds.
    @Test func twoWindowsKeepTheirOwnStripHistoryAndFold() {
        let registry = WindowRegistry()
        let a = UUID(), b = UUID()
        let routerA = ShellRouter(), routerB = ShellRouter()
        registry.register(a, router: routerA, kind: .full)
        registry.register(b, router: routerB, kind: .full)

        routerA.workspace.select(.shelf)
        routerA.workspace.select(.post("p1"))
        routerA.workspace.select(.post("p2"))
        routerB.workspace.select(.post("p3"))

        #expect(routerA.workspace.openNotes.ids == ["p1", "p2"])
        #expect(routerB.workspace.openNotes.ids == ["p3"], "its own strip, not the other's")
        #expect(routerA.workspace.history().origin == .post("p1"))
        #expect(routerB.workspace.history().canGoBack == false,
                "its own trail — the other window's visits are not its history")

        routerB.workspace.contextBarCollapsed = true
        #expect(routerA.workspace.contextBarCollapsed == false, "its own fold")

        // And the app's ONE menu bar reads whichever is key.
        registry.noteKey(a)
        #expect(registry.activeRouter?.workspace.openNotes.ids == ["p1", "p2"])
        registry.noteKey(b)
        #expect(registry.activeRouter?.workspace.openNotes.ids == ["p3"])
    }
}

// MARK: - THE RULING'S CONDITIONS (1) and (3), in two real windows

@MainActor
@Suite("Two hosted windows (13f batch 5b — the gate's conditions)")
struct TwoWindowMountTests {
    /// **CONDITION (1) — the unrepresentability at WINDOW scale**, the R4-A
    /// shape one level up. Two windows, each showing a different note: the
    /// three app-scoped singletons that assume ONE detail still see exactly
    /// one, and the one they see is the KEY window's — never last-mounted-
    /// wins, which is the LIFO misrouting hazard `SpreadBookView` names.
    ///
    /// Loosen the key-window gate and this goes red.
    @Test func twoWindowsMountExactlyOneDetailAndOneCommandHandler() async throws {
        try await withTwoWindows { world in
            // Nothing has been key yet (this host never makes a window key
            // on its own — measured): the FALLBACK decides, and it is the
            // first window registered.
            #expect(world.registry.isKey(world.idA))
            world.routerA.pendingSelection = .post(world.left)
            world.routerB.pendingSelection = .post(world.right)
            await world.settle(until: {
                world.session.commandRouter.activePostID == world.left
            })
            #expect(world.session.commandRouter.handlerCount == 1,
                    "TWO WINDOWS, ONE HANDLER — the gate, where it bites")
            #expect(world.session.commandRouter.activePostID == world.left)

            // Key migrates to B — AppKit's own notification, posted for B's
            // real window.
            world.becomeKey(world.windowB)
            await world.settle(until: {
                world.session.commandRouter.activePostID == world.right
            })
            #expect(world.session.commandRouter.handlerCount == 1,
                    "still one handler with two windows showing two notes")
            #expect(world.session.commandRouter.activePostID == world.right,
                    "the one detail is the KEY window's")

            // …and back, so the claim is not one-directional.
            world.becomeKey(world.windowA)
            await world.settle(until: {
                world.session.commandRouter.activePostID == world.left
            })
            #expect(world.session.commandRouter.handlerCount == 1)
            #expect(world.session.commandRouter.activePostID == world.left)
        }
    }

    /// **CONDITION (3) — THE STICKY KEY.** ⌘-tabbing to another APP resigns
    /// key with **no successor window**. A literal `keyWindow`-now reading
    /// would unmount the live surface on every app switch — a teardown/flush
    /// storm the split never had, and the reason the ruling made this a
    /// condition rather than a detail.
    ///
    /// Add a resign door anywhere in the chain and this goes red.
    @Test func theStickyKeySurvivesAppDeactivation() async throws {
        try await withTwoWindows { world in
            world.becomeKey(world.windowB)
            world.routerB.pendingSelection = .post(world.right)
            await world.settle(until: {
                world.session.commandRouter.activePostID == world.right
            })
            #expect(world.session.commandRouter.handlerCount == 1, "the premise")

            // The app deactivates: the key window resigns, and NOTHING
            // becomes key in its place.
            NotificationCenter.default.post(
                name: NSWindow.didResignKeyNotification, object: world.windowB)
            NotificationCenter.default.post(
                name: NSApplication.didResignActiveNotification, object: NSApp)
            await world.quiesce()

            #expect(world.registry.isKey(world.idB), "last-known-key, not keyWindow-now")
            #expect(world.session.commandRouter.activePostID == world.right,
                    "the live surface did not unmount")
            #expect(world.session.commandRouter.handlerCount == 1,
                    "…and nothing remounted either")
        }
    }

    /// Two things the second window would otherwise have broken, pinned
    /// together because they are the same mistake at two ends:
    ///
    /// 1. **The menu's gates.** `CommandRouter` is the APP's, and batch 3
    ///    wired its workspace closures to *a* window's workspace — so with
    ///    two windows the last one to appear answered Back / Forward /
    ///    ⌘⇧n for a window she was not in. They read the registry now.
    /// 2. **The navigation broadcasts.** `.variorumOpenPost` and friends
    ///    reach every listening window; without a target ONE click would
    ///    navigate both.
    @Test func theMenuGatesAndTheNavigationBroadcastsFollowTheKeyWindow() async throws {
        try await withTwoWindows { world in
            world.routerA.pendingSelection = .post(world.left)
            await world.settle(until: {
                world.routerA.workspace.openNotes.ids == [world.left]
            })
            #expect(world.session.commandRouter.openNoteCount() == 1,
                    "A is key by fallback, and A has one note open")

            world.becomeKey(world.windowB)
            await world.settle(until: { world.registry.isKey(world.idB) })
            #expect(world.session.commandRouter.openNoteCount() == 0,
                    "the menu now answers for B, which has opened nothing")
            #expect(world.session.commandRouter.canNavigateBack() == false)

            // ONE broadcast, ONE window navigates — and it is the target.
            NotificationCenter.default.post(
                name: .variorumOpenPost, object: nil, userInfo: ["postID": world.right])
            await world.settle(until: {
                world.routerB.workspace.selections[.primary] == .post(world.right)
            })
            #expect(world.routerB.workspace.selections[.primary] == .post(world.right))
            #expect(world.routerA.workspace.selections[.primary] == .post(world.left),
                    "the other window did NOT navigate on the same broadcast")
        }
    }

    // MARK: - The two-window harness

    @MainActor
    struct World {
        let session: AppSession
        let registry: WindowRegistry
        let routerA: ShellRouter
        let routerB: ShellRouter
        let windowA: NSWindow
        let windowB: NSWindow
        let idA: UUID
        let idB: UUID
        let left: String
        let right: String

        /// AppKit's own become-key notification, for a real hosted window —
        /// the exact one a click posts. (Measured: this host cannot make a
        /// window key by itself, so posting is how the chain is driven.)
        func becomeKey(_ window: NSWindow) {
            NotificationCenter.default.post(
                name: NSWindow.didBecomeKeyNotification, object: window)
        }

        func settle(until condition: @MainActor () -> Bool) async {
            for _ in 0..<400 where !condition() {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(5))
            }
        }

        /// Let every pending mount/unmount run, for a claim that something
        /// did NOT happen.
        func quiesce() async {
            for _ in 0..<40 {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(5))
            }
        }
    }

    private func withTwoWindows(_ body: @MainActor (World) async throws -> Void) async throws {
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

            let registry = WindowRegistry()
            let routerA = ShellRouter()
            let routerB = ShellRouter()
            let windowA = Self.makeWindow(session: session, router: routerA, registry: registry)
            let windowB = Self.makeWindow(session: session, router: routerB, registry: registry)
            defer {
                for window in [windowA, windowB] {
                    window.orderOut(nil)
                    window.close()
                }
            }
            let world = World(
                session: session, registry: registry, routerA: routerA, routerB: routerB,
                windowA: windowA, windowB: windowB,
                idA: UUID(), idB: UUID(), left: left.id, right: right.id)
            // The ids the shell minted are its own; find them by router, so
            // the harness never has to reach into `RootView`'s state.
            await world.settle(until: { registry.count == 2 })
            #expect(registry.count == 2, "both windows registered themselves")
            let resolved = World(
                session: session, registry: registry, routerA: routerA, routerB: routerB,
                windowA: windowA, windowB: windowB,
                idA: registry.order[0], idB: registry.order[1],
                left: left.id, right: right.id)
            #expect(registry.activeRouter === routerA,
                    "registration order decides while nothing has been key")
            try await body(resolved)
        }
    }

    private static func makeWindow(
        session: AppSession, router: ShellRouter, registry: WindowRegistry
    ) -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 60, y: 60, width: 1100, height: 700),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = NSHostingView(
            rootView: RootView(
                session: session, services: nil, router: router, windows: registry))
        window.orderFront(nil)
        return window
    }
}

// MARK: - THE RULING'S CONDITION (2)

@MainActor
@Suite("A detail unmounting when its window stops being key (13f batch 5b)")
struct WindowUnmountTests {
    /// **CONDITION (2).** Clicking into the OTHER WINDOW makes this one
    /// read-cheap, which unmounts its detail — the same pre-existing path
    /// batch 4 pinned at pane scale, given a new trigger one level up. The
    /// backstop is `teardown()`'s `finalizeWork`, which flushes through the
    /// post's own autosave coordinator while holding the model alive.
    /// Premise-asserted first, so the pin cannot pass vacuously.
    @Test func aDetailUnmountingWhenItsWindowStopsBeingKeyStillLandsItsText() async throws {
        try await withEditor(seedBlocks: ["kept"]) { h in
            h.type("X", at: 4)
            let beforeUnmount = try h.storeSlots().map(\.text)
            #expect(beforeUnmount == ["kept"],
                    "the buffer is dirty and NOT yet in the store — the pin's whole premise")

            // The trigger, stated in the terms THIS batch introduces: the
            // pane is still its window's focused one; the WINDOW stopped
            // being key.
            #expect(PaneMount.kind(of: .primary, focused: .primary, windowIsKey: false)
                == .readCheap)

            await h.model.teardown()?.value

            #expect(try h.storeSlots().map(\.text) == ["keptX"],
                    "the unmount landed the text — nothing typed is lost to a window switch")
        }
    }
}
