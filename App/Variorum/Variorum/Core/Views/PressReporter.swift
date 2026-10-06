//
//  PressReporter.swift
//  Variorum (Mac)
//
//  **17y B-WALK W-3 — "this control was pressed", for a control whose own API
//  says nothing when it opens.** A SwiftUI `Menu` has no open callback: it
//  starts AppKit's menu tracking on the mouse-down and nothing in SwiftUI
//  hears it. Her finding was exactly that seam — the Bookcase's № census
//  float stood open over the board while order ▾ opened over the same corner
//  ("unexcusable UI. not good at all"), because nothing could tell the board
//  a masthead menu had opened.
//
//  The reporter is an inert AppKit view laid BEHIND the control (it never
//  takes a click — `hitTest` answers nil): a local event monitor sees the
//  mouse-down on its way to the control and reports when it lands inside the
//  reporter's own bounds, in its own window. The event passes on untouched,
//  so the control behaves exactly as before. `secondaryOnly` narrows it to
//  the context-menu presses (a right-click, a control-click) for controls
//  whose primary click is something else (the strip's shelf names solo a
//  shelf on a click; only their right-click opens a menu).
//
//  The decision is one pure rule (`PressReporterView.reports`), pinned.
//

import AppKit
import SwiftUI

extension View {
    /// Report a press on this view (a mouse-down inside its bounds) — the
    /// event itself passes on to the view unchanged.
    func reportsPress(secondaryOnly: Bool = false, _ onPress: @escaping () -> Void) -> some View {
        background(PressReporter(secondaryOnly: secondaryOnly, onPress: onPress))
    }
}

struct PressReporter: NSViewRepresentable {
    let secondaryOnly: Bool
    let onPress: () -> Void

    func makeNSView(context: Context) -> PressReporterView {
        let view = PressReporterView()
        view.secondaryOnly = secondaryOnly
        view.onPress = onPress
        return view
    }

    func updateNSView(_ view: PressReporterView, context: Context) {
        view.secondaryOnly = secondaryOnly
        view.onPress = onPress
    }

    static func dismantleNSView(_ view: PressReporterView, coordinator: ()) {
        view.stopMonitoring()
    }
}

final class PressReporterView: NSView {
    var secondaryOnly = false
    var onPress: (() -> Void)?
    private var monitor: Any?

    /// Never a click target — the control above it keeps every click.
    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        stopMonitoring()
        guard window != nil else { return }
        monitor = NSEvent.addLocalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown]
        ) { [weak self] event in
            self?.handle(event)
            return event
        }
    }

    func stopMonitoring() {
        if let monitor { NSEvent.removeMonitor(monitor) }
        monitor = nil
    }

    /// The monitor's body (internal: the pins hand it an event directly —
    /// never through the window, where a `Menu` would start its tracking).
    func handle(_ event: NSEvent) {
        guard let window, event.window === window else { return }
        let point = convert(event.locationInWindow, from: nil)
        if Self.reports(
            kind: event.type, modifiers: event.modifierFlags, at: point, in: bounds,
            secondaryOnly: secondaryOnly)
        {
            onPress?()
        }
    }

    /// **The rule** (pure, pinned): a mouse-down inside the bounds — a
    /// primary press or a secondary one (right-click, control-click); with
    /// `secondaryOnly`, the secondary ones alone.
    static func reports(
        kind: NSEvent.EventType, modifiers: NSEvent.ModifierFlags, at point: NSPoint,
        in bounds: NSRect, secondaryOnly: Bool
    ) -> Bool {
        guard bounds.contains(point) else { return false }
        let secondary = kind == .rightMouseDown
            || (kind == .leftMouseDown && modifiers.contains(.control))
        switch kind {
        case .leftMouseDown, .rightMouseDown: return secondaryOnly ? secondary : true
        default: return false
        }
    }
}
