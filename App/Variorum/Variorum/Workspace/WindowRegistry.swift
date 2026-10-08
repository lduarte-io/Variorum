//
//  WindowRegistry.swift
//  Variorum (Mac)
//
//  Phase 13f, batch 5b (W2/A26 — SEVERAL WINDOWS): the app's small register
//  of open windows, and the ONE authority on which of them is KEY.
//
//  ── WHY IT EXISTS ────────────────────────────────────────────────────────
//  Batch 3 put the window's workspace on `ShellRouter`, and batch 4 recorded
//  the finding this file fixes: the router was App-level `@State` on
//  `VariorumApp`, so every `WindowGroup` window shared ONE workspace — one
//  Open strip, one set of histories, one context-bar fold. The router now
//  lives INSIDE the window's root view; what the app keeps is this register,
//  so that the two things which are genuinely app-wide can still find the
//  right window:
//
//  1. **The menu bar.** `EditorCommands` is attached to the SCENE, not to a
//     window, and its navigation doors (⌥⌘[, ⌥⌘], ⌘⇧1…9, Open Beside, the
//     context-bar fold) act on *the key window's* workspace. It reads
//     `activeRouter`.
//  2. **The key-window mount gate.** `PaneMount` gained the window's
//     key-ness as a second input (the architect's ruling (b)): exactly one
//     pane, in exactly one window, mounts a live surface — which is what
//     keeps `CommandRouter`'s single detail registration, its LIFO handler
//     stack and `EditorRouter.active` correct at app scale, exactly as the
//     pane-level mount rule keeps them correct inside one window.
//
//  ── THE KEY IS STICKY, AND THAT IS A RULING ──────────────────────────────
//  The architect's condition (3): the key-ness input is **LAST-KNOWN-KEY,
//  never literal `keyWindow`-now**. ⌘-tabbing to another APP resigns key
//  with no successor window, and a literal reading would unmount the live
//  surface on every app switch — a teardown/flush storm the split never had.
//  So this type has **no resign path at all**: `keyWindowID` moves only when
//  another window becomes key, or when the key window unregisters. Adding a
//  resign door is the regression `theStickyKeySurvivesAppDeactivation` pins.
//
//  ── AND A FALLBACK, WHICH THE TESTS MADE LOAD-BEARING ────────────────────
//  Measured on macOS 26.5.2 while building this batch: in the XCTest host
//  `NSApp.isActive` is false and `makeKeyAndOrderFront(_:)` does **not**
//  make a window key — no `didBecomeKey` ever fires. So `activeWindowID`
//  falls back to the first REGISTERED window when nothing has been key yet,
//  which is also right in the app (a window that has just opened and has not
//  yet been clicked still has to show its note).
//

import AppKit
import Observation
import SwiftUI

@MainActor
@Observable
final class WindowRegistry {
    /// What a window IS. A note-only window shows exactly one note and never
    /// navigates (the architect's ruling (d)), which is why it can be key —
    /// and therefore own the live surface — while never being the target of
    /// a navigation broadcast.
    /// `nonisolated` (18o U1 — 17e (12)): pure data, so the nonisolated
    /// `CapabilityContext` can carry the key window's kind as a registry fact.
    nonisolated enum Kind: Equatable, Sendable {
        case full
        case noteOnly
        /// 13f batch 6 (W5): the floating QUICK NOTE pad. It mounts no text
        /// surface at all, so while it is key the app has ZERO live
        /// surfaces — which is the point: ⌘S and the whole editing family
        /// go honestly grey through the gates that already exist, and no
        /// menu act can reach a window she is not looking at. It navigates
        /// nowhere, so `navigationTargetID` skips it exactly as it skips a
        /// note-only window.
        case quickNote
    }

    struct Entry {
        let router: ShellRouter
        let kind: Kind
        weak var window: NSWindow?
    }

    /// Registration order — the fallback's tie-break, and stable.
    private(set) var order: [UUID] = []
    private var entries: [UUID: Entry] = [:]
    /// Most-recently-key first. Bounded by the window count, so it needs no
    /// cap of its own; ids leave it when they unregister.
    private(set) var keyOrder: [UUID] = []

    var count: Int { order.count }

    func register(_ id: UUID, router: ShellRouter, kind: Kind) {
        entries[id] = Entry(router: router, kind: kind, window: entries[id]?.window)
        if !order.contains(id) { order.append(id) }
    }

    func unregister(_ id: UUID) {
        entries.removeValue(forKey: id)
        order.removeAll { $0 == id }
        keyOrder.removeAll { $0 == id }
    }

    /// The window's own AppKit window, handed over by `WindowKeyReporter`
    /// so `bringForward` has something to raise.
    func attach(_ window: NSWindow, to id: UUID) {
        guard var entry = entries[id] else { return }
        entry.window = window
        entries[id] = entry
    }

    /// The window's own AppKit window, if it has attached one. 13s-b U2: the
    /// tour's start releases that window's first responder (the walk's
    /// W-U1a-1 — "yes" must not leave the caret in the Bookcase's quick entry).
    func window(for id: UUID) -> NSWindow? { entries[id]?.window }

    /// A window became key. **The only writer of key-ness** — there is no
    /// resign door, deliberately (see the header).
    func noteKey(_ id: UUID) {
        guard entries[id] != nil else { return }
        keyOrder.removeAll { $0 == id }
        keyOrder.insert(id, at: 0)
    }

    /// The window whose pane mounts live: the last-known-key window while it
    /// is still open, else the first one registered.
    var activeWindowID: UUID? {
        keyOrder.first { entries[$0] != nil } ?? order.first
    }

    func isKey(_ id: UUID) -> Bool { activeWindowID == id }

    var activeRouter: ShellRouter? {
        activeWindowID.flatMap { entries[$0]?.router }
    }

    func kind(of id: UUID) -> Kind? { entries[id]?.kind }

    /// The active window's kind — the sidebar toggle's gate (the Act 10
    /// correction round, batch A): only a FULL window has a sidebar, so the
    /// View-menu item is honestly grey while a note-only window is key.
    /// **Read through the registry since 18o U1 (17e (12)):** the shell wires
    /// it into `CommandRouter.windowKind`, `.toggleSidebar` declares the rule,
    /// and the menu asks the registry — never this property directly.
    var activeWindowKind: Kind? { activeWindowID.flatMap { entries[$0]?.kind } }

    /// Where an app-wide NAVIGATION broadcast lands (`.variorumOpenPost`,
    /// `.variorumOpenBookAtPost`).
    ///
    /// **This is the second window's own correctness problem, and it is why
    /// the rule is not simply `isKey`.** Those notifications are posted to
    /// the whole app, and every full window listens; without a target every
    /// one of them would navigate on one click. And a note-only window
    /// cannot navigate at all, so if the rule were `isKey` a book link
    /// clicked in a note-only window would be a dead door — exactly the
    /// class W20 was built to kill. So: the key window when it can navigate,
    /// otherwise the most recently key FULL window.
    var navigationTargetID: UUID? {
        if let active = activeWindowID, entries[active]?.kind == .full { return active }
        return keyOrder.first { entries[$0]?.kind == .full }
            ?? order.first { entries[$0]?.kind == .full }
    }

    func isNavigationTarget(_ id: UUID) -> Bool { navigationTargetID == id }

    /// **Where a CREATION or palette act lands** (13f cold review, R1-3 —
    /// the fix). ⌘N / ⌘J / the tutorial doors mint-or-open and then
    /// navigate via `pendingSelection`; ⌘K opens the palette. A note-only
    /// or quick-note window consumes NEITHER (no shell, no palette), so
    /// routing them to `activeRouter` while one of those was key minted
    /// real store rows into a router nobody watches — a silent store write
    /// behind an enabled key, and ⌘K a fully dead one. The rule is the
    /// `navigationTargetID` precedent: the act lands in a window that CAN
    /// show its result, and that window raises itself when it is not the
    /// one she is looking at (the `claimBroadcast` shape).
    ///
    /// A METHOD, not a property, deliberately: the raise is a side effect,
    /// and menu RENDERING must never trigger it — only a chosen act does.
    /// nil ⇔ no full window exists; `hasNavigationTarget` is the
    /// side-effect-free gate the menu's grey reads.
    func creationRouter() -> ShellRouter? {
        guard let id = navigationTargetID else { return nil }
        if id != activeWindowID { bringForward(id) }
        return entries[id]?.router
    }

    /// The side-effect-free half of `creationRouter()`: may a creation or
    /// palette act land anywhere at all? False only when no full window
    /// exists — the one state where greying is the honest answer, because
    /// nothing could ever show the act's result.
    var hasNavigationTarget: Bool { navigationTargetID != nil }

    /// Raise a window that just acted on a broadcast it did not have focus
    /// for — so "open this book" from a note-only window puts the book in
    /// front of her rather than behind.
    func bringForward(_ id: UUID) {
        guard let window = entries[id]?.window else { return }
        window.makeKeyAndOrderFront(nil)
    }
}

// MARK: - The AppKit half (one call, no decisions)

/// Reports its own window and its become-key events. Deliberately tiny: the
/// DECISION (which window is key, and what that means) is the registry's and
/// `PaneMount`'s; this only says "AppKit said so".
///
/// It observes `NSWindow.didBecomeKeyNotification` for **its own window**,
/// which is the notification AppKit posts on a click — so a pin can post
/// that same notification and drive the whole chain. What no pin here can
/// cover is AppKit's own posting of it under a real click; that is on the
/// batch record's visual-verification list.
struct WindowKeyReporter: NSViewRepresentable {
    let onWindow: (NSWindow) -> Void
    let onKey: () -> Void

    func makeNSView(context: Context) -> NSView {
        let view = WindowKeyReportingView()
        view.onWindow = onWindow
        view.onKey = onKey
        return view
    }

    func updateNSView(_ view: NSView, context: Context) {
        guard let view = view as? WindowKeyReportingView else { return }
        view.onWindow = onWindow
        view.onKey = onKey
    }
}

final class WindowKeyReportingView: NSView {
    var onWindow: ((NSWindow) -> Void)?
    var onKey: (() -> Void)?

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        NotificationCenter.default.removeObserver(
            self, name: NSWindow.didBecomeKeyNotification, object: nil)
        guard let window else { return }
        onWindow?(window)
        NotificationCenter.default.addObserver(
            self, selector: #selector(windowBecameKey),
            name: NSWindow.didBecomeKeyNotification, object: window)
        // A window that is ALREADY key when this mounts (the ordinary case
        // for "Open in New Window": AppKit made it key before SwiftUI ran
        // this view's body) has already posted its notification.
        if window.isKeyWindow { onKey?() }
    }

    @objc private func windowBecameKey() { onKey?() }
}
