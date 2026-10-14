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
//  THE FIX'S OWN PINS live in `QuickEntryOpeningFocusTests.swift` (they name
//  what the old tree does not have, so they are GUARDS of the fixed product
//  and the old products are built without that file).
//
//  HARNESS FACT (measured for this file): AppKit makes a window's first text
//  field its first responder the moment the window is first ordered in, key
//  or not — so the rig frees the keyboard right after, and every pin that
//  wants another responder holding it puts it there itself.
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
final class LaunchFocusBoot {
    var ready = false
}

struct LaunchFocusShell: View {
    let boot: LaunchFocusBoot
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
final class LaunchFocusWindow: NSWindow {
    private var simulatedKey = false

    override var isKeyWindow: Bool { simulatedKey || super.isKeyWindow }

    func simulateBecomingKey() {
        simulatedKey = true
        NotificationCenter.default.post(name: NSWindow.didBecomeKeyNotification, object: self)
    }
}

@MainActor
enum LaunchFocusRig {
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
    static func window(boot: LaunchFocusBoot, session: AppSession, router: ShellRouter)
        -> (LaunchFocusWindow, NSTextField)
    {
        let size = NSSize(width: 1100, height: 720)
        let window = LaunchFocusWindow(
            contentRect: NSRect(x: 40, y: 40, width: size.width, height: size.height + 40),
            styleMask: [.titled, .resizable], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let content = NSView(frame: NSRect(x: 0, y: 0, width: size.width, height: size.height + 40))
        let hosting = NSHostingView(rootView: LaunchFocusShell(boot: boot, session: session, router: router))
        hosting.frame = NSRect(x: 0, y: 40, width: size.width, height: size.height)
        hosting.autoresizingMask = [.width, .height]
        let field = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        content.addSubview(hosting)
        content.addSubview(field)
        window.contentView = content
        window.makeKeyAndOrderFront(nil)
        // AppKit selects a window's first text field as its first responder
        // the moment the window is first ordered in (measured — a key window
        // or not). The launch's window holds nothing (its opening face has no
        // field), so the stand-in starts OFF the keyboard; a pin that wants it
        // there puts it there.
        window.makeFirstResponder(nil)
        return (window, field)
    }

    /// The keyboard is free: the window itself, or nothing, is first responder.
    static func keyboardIsFree(_ window: NSWindow) -> Bool {
        window.firstResponder == nil || window.firstResponder === window
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
        try await LaunchFocusRig.world(seed: 326) { session in
            let boot = LaunchFocusBoot()
            let (window, _) = LaunchFocusRig.window(boot: boot, session: session, router: ShellRouter())
            defer { LaunchFocusRig.close(window) }
            await LaunchFocusRig.settle(turns: 10)
            #expect(LaunchFocusRig.windowedBox(window) == nil, "the opening face: no shell yet")
            #expect(LaunchFocusRig.keyboardIsFree(window), "the opening face holds no keyboard (the launch's state)")

            boot.ready = true  // `AppBootstrap.finish` — the store is ready
            await LaunchFocusRig.settle(turns: 300) { LaunchFocusRig.windowedBox(window) != nil }
            let box = try #require(LaunchFocusRig.windowedBox(window), "the shell mounted the Bookcase's bar")
            await LaunchFocusRig.settle(turns: 20)

            window.simulateBecomingKey()
            await LaunchFocusRig.settle(turns: 20) { window.firstResponder === box }
            #expect(window.firstResponder === box, """
                the shell opened on the Bookcase and its quick entry holds the caret \
                (the keyboard is on \(String(describing: window.firstResponder)))
                """)
        }
    }

    /// GUARD: another responder holding the window's keyboard when the shell
    /// opens keeps it — the ask is dropped, never served later.
    @Test func aFieldHoldingTheKeyboardKeepsItAcrossTheOpening() async throws {
        try await LaunchFocusRig.world(seed: 327) { session in
            let boot = LaunchFocusBoot()
            let (window, field) = LaunchFocusRig.window(boot: boot, session: session, router: ShellRouter())
            defer { LaunchFocusRig.close(window) }
            await LaunchFocusRig.settle(turns: 10)
            window.makeFirstResponder(field)
            await LaunchFocusRig.settle(turns: 3)
            let holder = window.firstResponder
            #expect(holder !== window && !(holder is CaptureNSTextView),
                    "non-vacuity: the field holds the keyboard before the shell opens")

            boot.ready = true
            await LaunchFocusRig.settle(turns: 300) { LaunchFocusRig.windowedBox(window) != nil }
            let box = try #require(LaunchFocusRig.windowedBox(window), "the shell mounted the Bookcase's bar")
            await LaunchFocusRig.settle(turns: 20)
            window.simulateBecomingKey()
            await LaunchFocusRig.settle(turns: 20)
            #expect(window.firstResponder !== box, "the quick entry never takes the keyboard from the field")
            #expect(window.firstResponder === holder, "the field keeps it")

            // …and the dropped ask stays dropped: a re-attach of the box (the
            // SwiftUI reveal class, TEXTKIT2 §3) never serves it later.
            let scroll = try #require(box.enclosingScrollView)
            let superview = try #require(scroll.superview)
            scroll.removeFromSuperview()
            superview.addSubview(scroll)
            await LaunchFocusRig.settle(turns: 20)
            #expect(window.firstResponder === holder, "still the field's after a re-attach")
        }
    }

    /// GUARD: a sheet on the window when the shell opens holds the keyboard;
    /// the quick entry does not take it, during the sheet or after it closes.
    @Test func aSheetOnTheWindowAtTheOpeningKeepsTheKeyboardFromTheQuickEntry() async throws {
        try await LaunchFocusRig.world(seed: 328) { session in
            let boot = LaunchFocusBoot()
            let (window, _) = LaunchFocusRig.window(boot: boot, session: session, router: ShellRouter())
            defer { LaunchFocusRig.close(window) }
            let sheet = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 300, height: 120),
                styleMask: [.titled], backing: .buffered, defer: false)
            sheet.isReleasedWhenClosed = false
            window.beginSheet(sheet, completionHandler: nil)
            await LaunchFocusRig.settle(turns: 60) { window.attachedSheet === sheet }
            try #require(window.attachedSheet === sheet, "non-vacuity: the sheet is on the window")

            boot.ready = true
            await LaunchFocusRig.settle(turns: 300) { LaunchFocusRig.windowedBox(window) != nil }
            let box = try #require(LaunchFocusRig.windowedBox(window), "the shell mounted the Bookcase's bar")
            await LaunchFocusRig.settle(turns: 20)
            #expect(window.firstResponder !== box, "the sheet holds the keyboard; the quick entry leaves it")

            window.endSheet(sheet)
            await LaunchFocusRig.settle(turns: 30) { window.attachedSheet == nil }
            window.simulateBecomingKey()
            await LaunchFocusRig.settle(turns: 20)
            #expect(window.firstResponder !== box, "a dropped ask is not served when the sheet closes")
        }
    }
}
