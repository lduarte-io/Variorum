//
//  QuickEntryLaunchFocusTests.swift
//  VariorumTests
//
//  VX-282 U6 — VX-326: THE BOOKCASE'S QUICK ENTRY ISN'T FOCUSED AT LAUNCH.
//  The binding record is `notes/plans/fixes/vx-282-editor-notes-fixes.md`
//  § U6 (the trace, the pins, the walk).
//
//  THE MECHANISM (traced headlessly against the real module — the record):
//  the shell asks for the caret once, from the Bookcase bar's `.task`
//  (`QuickEntryBar`'s `focusRequest += 1`, R102: "the shelf opens with the
//  cursor already IN the bar"). At launch the shell is not the window's first
//  content — `VariorumApp.mainWindowContent` shows the opening face while the
//  store opens and SWAPS in `RootView` when it is ready — and in a swap the
//  `.task`'s ask reaches `CaptureTextView.updateNSView` BEFORE SwiftUI puts the
//  box in its window. `takeFocus` returns at its `view.window` guard, the ask
//  is spent (`lastFocusRequest` already bumped), and nothing retries: the
//  window keeps the keyboard. F-FR-1 (17y B2) measured the same drop in a
//  hosted test window and recorded it untraced in the real app; O-U4-3 saw it
//  live at launch.
//
//  THE ROAD THESE PINS DRIVE: the production shell in the launch's own shape —
//  an opening face swapped for `RootView` once the store is "ready" — in a
//  window that becomes key afterwards. They settle by SUSPENDING ONLY (no
//  forced layout, no nested run loop): SwiftUI's own run-loop pass decides
//  when the box reaches its window, exactly as in the app. (A forced layout —
//  the other suites' settle — inserts the box before the ask runs, which is
//  the order a window gets when the shell is its FIRST content: the
//  `TourEntryTests` / `CaptureTourFocusTests` mounts, where the caret lands on
//  the old tree too.) This host never makes a window key (`WindowsTests`'
//  header); the window here reports key once the pin says so and posts
//  AppKit's own notification — the one thing not under test is AppKit's
//  posting of it under a real hand, which the walk carries.
//
//  RED ON OLD, stated exactly: `theShellOpeningOnTheBookcasePutsTheCaretInItsQuickEntry`'s
//  last cell (the window keeps the keyboard). The two never-steal cells are
//  GUARDS — green on both sides (on the old tree the ask is dropped before
//  anything could be stolen; on the fixed one it is dropped because something
//  else holds the keyboard).
//
//  THE FIX'S OWN PINS (added with the fix — they name what the old tree does
//  not have, so they are GUARDS of the fixed product): the rule as a table
//  (`CaptureOpeningFocusRuleTests`); the box's opening road — waits for its
//  window, takes only a free keyboard, never late, served once
//  (`CaptureOpeningFocusBoxTests`); and the scope — the opening ask is the
//  shell's, once; a navigation back to the Bookcase keeps the bar's mount
//  raise exactly as it was (`QuickEntryOpeningScopeTests`).
//

import AppKit
import Dependencies
import Foundation
import Observation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The launch's shape

/// `VariorumApp.mainWindowContent`'s switch, in miniature: the opening face
/// while the store opens, the shell once it is ready.
@MainActor
@Observable
private final class LaunchBoot {
    var ready = false
}

private struct LaunchShell: View {
    let boot: LaunchBoot
    let session: AppSession
    let router: ShellRouter

    var body: some View {
        if boot.ready {
            RootView(session: session, router: router)
        } else {
            Text("opening")
        }
    }
}

/// A window that is KEY when the pin says so — `isKeyWindow` answers it and
/// AppKit's own notification is posted, as on a click (`WindowsTests`' road).
private final class LaunchWindow: NSWindow {
    private var simulatedKey = false

    override var isKeyWindow: Bool { simulatedKey || super.isKeyWindow }

    func simulateBecomingKey() {
        simulatedKey = true
        NotificationCenter.default.post(name: NSWindow.didBecomeKeyNotification, object: self)
    }
}

@MainActor
private enum LaunchRig {
    /// Suspends only — the app's own run loop runs SwiftUI's passes and the
    /// main queue between turns (no forced layout, no nested run loop).
    static func settle(turns: Int = 40, until predicate: () -> Bool = { false }) async {
        for _ in 0..<turns {
            try? await Task.sleep(for: .milliseconds(10))
            if predicate() { return }
        }
    }

    static func boxes(in view: NSView) -> [CaptureNSTextView] {
        ((view as? CaptureNSTextView).map { [$0] } ?? []) + view.subviews.flatMap(boxes)
    }

    /// The Bookcase's capture box, once it is IN the window.
    static func windowedBox(_ window: NSWindow) -> CaptureNSTextView? {
        guard let content = window.contentView else { return nil }
        return boxes(in: content).first { $0.window === window }
    }

    /// The shell's window: the launch face over a hosting view, beside a
    /// stand-in for ANOTHER responder (a field), ordered in (never key here).
    static func window(boot: LaunchBoot, session: AppSession, router: ShellRouter)
        -> (LaunchWindow, NSTextField)
    {
        let size = NSSize(width: 1100, height: 720)
        let window = LaunchWindow(
            contentRect: NSRect(x: 40, y: 40, width: size.width, height: size.height + 40),
            styleMask: [.titled, .resizable], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let content = NSView(frame: NSRect(x: 0, y: 0, width: size.width, height: size.height + 40))
        let hosting = NSHostingView(rootView: LaunchShell(boot: boot, session: session, router: router))
        hosting.frame = NSRect(x: 0, y: 40, width: size.width, height: size.height)
        hosting.autoresizingMask = [.width, .height]
        let field = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        content.addSubview(hosting)
        content.addSubview(field)
        window.contentView = content
        window.makeKeyAndOrderFront(nil)
        return (window, field)
    }

    static func close(_ window: NSWindow) {
        window.orderOut(nil)
        window.contentView = nil
        window.close()
    }

    /// One in-memory world per pin (the store never leaves memory).
    static func world<T>(
        seed: UInt64, _ body: @MainActor (AppSession) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        return try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: seed))
        } operation: { @MainActor in
            try await body(AppSession(database: db))
        }
    }
}

// MARK: - The pins

@MainActor
@Suite("VX-326 — the shell opening on the Bookcase puts the caret in its quick entry, never stealing",
       .serialized)
struct QuickEntryLaunchFocusTests {
    /// **RED ON OLD** (the last cell): the launch — the opening face swapped
    /// for the shell, the window key afterwards — ends with the caret in the
    /// Bookcase's quick entry. On the old tree the window keeps the keyboard.
    @Test func theShellOpeningOnTheBookcasePutsTheCaretInItsQuickEntry() async throws {
        try await LaunchRig.world(seed: 326) { session in
            let boot = LaunchBoot()
            let (window, _) = LaunchRig.window(boot: boot, session: session, router: ShellRouter())
            defer { LaunchRig.close(window) }
            await LaunchRig.settle(turns: 10)
            #expect(LaunchRig.windowedBox(window) == nil, "the opening face: no shell yet")

            boot.ready = true  // `AppBootstrap.finish` — the store is ready
            await LaunchRig.settle(turns: 300) { LaunchRig.windowedBox(window) != nil }
            let box = try #require(LaunchRig.windowedBox(window), "the shell mounted the Bookcase's bar")
            await LaunchRig.settle(turns: 20)

            window.simulateBecomingKey()
            await LaunchRig.settle(turns: 20) { window.firstResponder === box }
            #expect(window.firstResponder === box, """
                the shell opened on the Bookcase and its quick entry holds the caret \
                (the keyboard is on \(String(describing: window.firstResponder)))
                """)
        }
    }

    /// GUARD: another responder holding the window's keyboard when the shell
    /// opens keeps it — the ask is dropped, never served later.
    @Test func aFieldHoldingTheKeyboardKeepsItAcrossTheOpening() async throws {
        try await LaunchRig.world(seed: 327) { session in
            let boot = LaunchBoot()
            let (window, field) = LaunchRig.window(boot: boot, session: session, router: ShellRouter())
            defer { LaunchRig.close(window) }
            await LaunchRig.settle(turns: 10)
            window.makeFirstResponder(field)
            await LaunchRig.settle(turns: 3)
            let holder = window.firstResponder
            #expect(holder !== window && !(holder is CaptureNSTextView),
                    "non-vacuity: the field holds the keyboard before the shell opens")

            boot.ready = true
            await LaunchRig.settle(turns: 300) { LaunchRig.windowedBox(window) != nil }
            let box = try #require(LaunchRig.windowedBox(window), "the shell mounted the Bookcase's bar")
            await LaunchRig.settle(turns: 20)
            window.simulateBecomingKey()
            await LaunchRig.settle(turns: 20)
            #expect(window.firstResponder !== box, "the quick entry never takes the keyboard from the field")
            #expect(window.firstResponder === holder, "the field keeps it")

            // …and the dropped ask stays dropped: a re-attach of the box (the
            // SwiftUI reveal class, TEXTKIT2 §3) never serves it later.
            let scroll = try #require(box.enclosingScrollView)
            let superview = try #require(scroll.superview)
            scroll.removeFromSuperview()
            superview.addSubview(scroll)
            await LaunchRig.settle(turns: 20)
            #expect(window.firstResponder === holder, "still the field's after a re-attach")
        }
    }

    /// GUARD: a sheet on the window when the shell opens holds the keyboard;
    /// the quick entry does not take it, during the sheet or after it closes.
    @Test func aSheetOnTheWindowAtTheOpeningKeepsTheKeyboardFromTheQuickEntry() async throws {
        try await LaunchRig.world(seed: 328) { session in
            let boot = LaunchBoot()
            let (window, _) = LaunchRig.window(boot: boot, session: session, router: ShellRouter())
            defer { LaunchRig.close(window) }
            let sheet = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 300, height: 120),
                styleMask: [.titled], backing: .buffered, defer: false)
            sheet.isReleasedWhenClosed = false
            window.beginSheet(sheet, completionHandler: nil)
            await LaunchRig.settle(turns: 60) { window.attachedSheet === sheet }
            try #require(window.attachedSheet === sheet, "non-vacuity: the sheet is on the window")

            boot.ready = true
            await LaunchRig.settle(turns: 300) { LaunchRig.windowedBox(window) != nil }
            let box = try #require(LaunchRig.windowedBox(window), "the shell mounted the Bookcase's bar")
            await LaunchRig.settle(turns: 20)
            #expect(window.firstResponder !== box, "the sheet holds the keyboard; the quick entry leaves it")

            window.endSheet(sheet)
            await LaunchRig.settle(turns: 30) { window.attachedSheet == nil }
            window.simulateBecomingKey()
            await LaunchRig.settle(turns: 20)
            #expect(window.firstResponder !== box, "a dropped ask is not served when the sheet closes")
        }
    }
}

// MARK: - The rule, as a table (VX-326 — the fix's own pins; GUARDS)

@Suite("VX-326 — the capture box's opening ask: the rule")
struct CaptureOpeningFocusRuleTests {
    private typealias Rule = CaptureOpeningFocus

    @Test func outOfItsWindowTheAskWaits() {
        for keyboard: Rule.Holder in [.nobody, .theBox, .someoneElse] {
            for sheet in [false, true] {
                #expect(Rule.verdict(.init(inWindow: false, keyboard: keyboard, sheetOnWindow: sheet)) == .wait)
            }
        }
    }

    @Test func inItsWindowTheAskTakesOnlyAFreeKeyboard() {
        #expect(Rule.verdict(.init(inWindow: true, keyboard: .nobody, sheetOnWindow: false)) == .take)
        #expect(Rule.verdict(.init(inWindow: true, keyboard: .someoneElse, sheetOnWindow: false)) == .drop,
                "never steals from another responder")
        #expect(Rule.verdict(.init(inWindow: true, keyboard: .nobody, sheetOnWindow: true)) == .drop,
                "a sheet on the window holds its keyboard")
        #expect(Rule.verdict(.init(inWindow: true, keyboard: .someoneElse, sheetOnWindow: true)) == .drop)
        #expect(Rule.verdict(.init(inWindow: true, keyboard: .theBox, sheetOnWindow: false)) == .alreadyHeld)
    }
}

// MARK: - The box's opening road (the fix's own pins; GUARDS)

/// A host for the bare box with both of its asks.
@MainActor
@Observable
private final class OpeningBoxRig {
    var text = ""
    var focusRequest = 0
    var openingFocusRequest = 0
}

private struct OpeningBoxRigView: View {
    @Bindable var rig: OpeningBoxRig

    var body: some View {
        CaptureTextView(
            text: $rig.text, style: CaptureTextStyle(tokens: .terminalLight), maxHeight: 160,
            focusRequest: rig.focusRequest, openingFocusRequest: rig.openingFocusRequest,
            onFile: {})
            .frame(width: 400, height: 60)
    }
}

@MainActor
private struct MountedBox {
    let window: NSWindow
    let content: NSView
    let hosting: NSView
    let field: NSTextField
    let box: CaptureNSTextView
    let rig: OpeningBoxRig

    static func mount() async throws -> MountedBox {
        let rig = OpeningBoxRig()
        let hosting = NSHostingView(rootView: OpeningBoxRigView(rig: rig))
        let window = NSWindow(
            contentRect: NSRect(x: 80, y: 80, width: 420, height: 120),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let content = NSView(frame: NSRect(x: 0, y: 0, width: 420, height: 120))
        hosting.frame = NSRect(x: 0, y: 40, width: 420, height: 80)
        let field = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        content.addSubview(hosting)
        content.addSubview(field)
        window.contentView = content
        window.makeKeyAndOrderFront(nil)
        await LaunchRig.settle(turns: 100) { LaunchRig.windowedBox(window) != nil }
        let box = try #require(LaunchRig.windowedBox(window), "the box mounted")
        return MountedBox(window: window, content: content, hosting: hosting, field: field, box: box, rig: rig)
    }

    /// The host out of the window and back — SwiftUI's re-parent shape
    /// (`PaneFindFaceTests.reparent`), with the pin's act in between.
    func detach() { hosting.removeFromSuperview() }
    func reattach() { content.addSubview(hosting) }

    func close() { LaunchRig.close(window) }
}

@MainActor
@Suite("VX-326 — the capture box's opening ask waits for its window, takes only a free keyboard, once",
       .serialized)
struct CaptureOpeningFocusBoxTests {
    /// The launch's order, driven at the box: the ask arrives while the box
    /// is OUT of its window; it waits, and the arrival decides (a free
    /// keyboard: the caret).
    @Test func anAskArmedOutOfTheWindowIsDecidedOnArrival() async throws {
        let mounted = try await MountedBox.mount()
        defer { mounted.close() }
        let (window, box) = (mounted.window, mounted.box)
        mounted.detach()
        #expect(box.window == nil, "non-vacuity: the box is out of its window")
        box.armOpeningFocus()
        await LaunchRig.settle(turns: 5)
        #expect(box.openingFocusPending, "the ask waits for the window")
        #expect(window.firstResponder !== box)

        mounted.reattach()
        await LaunchRig.settle(turns: 20) { window.firstResponder === box }
        #expect(window.firstResponder === box, "arrived on a free keyboard — the caret is the box's")
        #expect(!box.openingFocusPending, "decided, once")
    }

    /// Never steals, never late: a field takes the keyboard while the ask
    /// waits; the arrival drops it, and no later re-attach or release serves it.
    @Test func anAskNeverStealsAndIsNeverServedLate() async throws {
        let mounted = try await MountedBox.mount()
        defer { mounted.close() }
        let (window, box) = (mounted.window, mounted.box)
        mounted.detach()
        box.armOpeningFocus()
        window.makeFirstResponder(mounted.field)
        let holder = window.firstResponder
        #expect(holder !== window && holder !== box, "non-vacuity: the field holds the keyboard")

        mounted.reattach()
        await LaunchRig.settle(turns: 20)
        #expect(window.firstResponder === holder, "the field keeps it")
        #expect(!box.openingFocusPending, "the ask is spent — dropped")

        window.makeFirstResponder(nil)  // the keyboard freed later
        mounted.detach()
        mounted.reattach()
        await LaunchRig.settle(turns: 20)
        #expect(window.firstResponder !== box, "a dropped ask is never served later")
    }

    /// Through the representable: an ask raised with the box in a window whose
    /// keyboard is free takes the caret; served ONCE — a release and a
    /// re-attach afterwards leave it away (VX-112's contract, unchanged).
    @Test func anAskOnAFreeWindowTakesTheCaretAndIsServedOnce() async throws {
        let mounted = try await MountedBox.mount()
        defer { mounted.close() }
        let (window, box) = (mounted.window, mounted.box)
        #expect(window.firstResponder !== box, "nothing has asked yet")
        mounted.rig.openingFocusRequest += 1
        await LaunchRig.settle(turns: 20) { window.firstResponder === box }
        #expect(window.firstResponder === box)

        window.makeFirstResponder(nil)  // the release (the tour's own act)
        mounted.detach()
        mounted.reattach()
        await LaunchRig.settle(turns: 20)
        #expect(window.firstResponder !== box, "released, the box stays away — the ask was served once")
    }

    /// Through the representable: a sheet on the window holds its keyboard —
    /// the ask is dropped, and closing the sheet does not serve it.
    @Test func anAskWithASheetOnTheWindowIsDropped() async throws {
        let mounted = try await MountedBox.mount()
        defer { mounted.close() }
        let (window, box) = (mounted.window, mounted.box)
        let sheet = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 80),
            styleMask: [.titled], backing: .buffered, defer: false)
        sheet.isReleasedWhenClosed = false
        window.beginSheet(sheet, completionHandler: nil)
        await LaunchRig.settle(turns: 60) { window.attachedSheet === sheet }
        try #require(window.attachedSheet === sheet, "non-vacuity: the sheet is on the window")

        mounted.rig.openingFocusRequest += 1
        await LaunchRig.settle(turns: 20)
        #expect(window.firstResponder !== box)
        #expect(!box.openingFocusPending, "dropped")
        window.endSheet(sheet)
        await LaunchRig.settle(turns: 30) { window.attachedSheet == nil }
        #expect(window.firstResponder !== box, "the sheet's close serves nothing")
    }
}

// MARK: - The shell's ONE opening ask (the fix's own pins; GUARDS)

@MainActor
@Suite("VX-326 — the opening ask is the shell's, once; a navigation back keeps the bar's raise as it was",
       .serialized)
struct QuickEntryOpeningScopeTests {
    @Test func theClaimIsTrueExactlyOnce() {
        let claim = QuickEntryOpeningFocus()
        #expect(!claim.spent)
        #expect(claim.claim())
        #expect(claim.spent)
        #expect(!claim.claim())
        #expect(!claim.claim())
    }

    /// The shell opens on the Bookcase (the opening ask served); a navigation
    /// to the Library and back mounts a new Bookcase bar, which finds the
    /// claim spent and raises the counted request exactly as before — the
    /// opening road is not taken again.
    @Test func aNavigationBackToTheBookcaseKeepsTheBarsRaiseAsItWas() async throws {
        try await LaunchRig.world(seed: 329) { session in
            let boot = LaunchBoot()
            let router = ShellRouter()
            let (window, _) = LaunchRig.window(boot: boot, session: session, router: router)
            defer { LaunchRig.close(window) }
            await LaunchRig.settle(turns: 10)
            boot.ready = true
            await LaunchRig.settle(turns: 300) { LaunchRig.windowedBox(window) != nil }
            let first = try #require(LaunchRig.windowedBox(window))
            await LaunchRig.settle(turns: 20) { window.firstResponder === first }
            #expect(window.firstResponder === first, "the shell's opening: the caret in the quick entry")
            let firstAsks = try #require(first.delegate as? CaptureTextView.Coordinator)
            #expect(firstAsks.lastOpeningFocusRequest == 1 && firstAsks.lastFocusRequest == 0,
                    "the opening took the opening road")

            // The Library carries a quick-entry bar of its own (no autofocus):
            // its box is told apart by identity.
            router.pendingSelection = .library
            await LaunchRig.settle(turns: 300) {
                router.workspace.focusedSelection == .library
                    && LaunchRig.windowedBox(window).map { $0 !== first } == true
            }
            #expect(router.workspace.focusedSelection == .library)
            let libraryBox = LaunchRig.windowedBox(window)
            await LaunchRig.settle(turns: 20)
            router.pendingSelection = .shelf
            await LaunchRig.settle(turns: 300) {
                router.workspace.focusedSelection == .shelf
                    && LaunchRig.windowedBox(window).map { $0 !== first && $0 !== libraryBox } == true
            }
            let second = try #require(LaunchRig.windowedBox(window), "back on the Bookcase")
            #expect(second !== first && second !== libraryBox, "a new Bookcase bar mounted")
            await LaunchRig.settle(turns: 20)
            let secondAsks = try #require(second.delegate as? CaptureTextView.Coordinator)
            #expect(secondAsks.lastOpeningFocusRequest == 0, "the claim was spent — no second opening ask")
            #expect(secondAsks.lastFocusRequest == 1, "the bar's mount raise, as it was")
            #expect(!second.openingFocusPending)
        }
    }
}
