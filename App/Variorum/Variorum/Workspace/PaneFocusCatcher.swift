//
//  PaneFocusCatcher.swift
//  Variorum (Mac)
//
//  Phase 13g, batch 1 (L6 — her WT-6): CLICKING A PANE FOCUSES IT.
//
//  ── THE TRACE (what was actually wrong) ──────────────────────────────────
//  Her report, verbatim: *"clicking into the read body of the pane on the
//  right makes that the editable pane (which I like) but on the left pane you
//  have to click the narrow bar that says 'click on this pane to edit'."*
//
//  Traced through `RootView.paneDetail`, which is where an unfocused pane's
//  content is chosen. A pane's body-click focus door existed in exactly TWO
//  of its branches:
//
//  - **notes and scraps** (`readCheapNote` → `ReadPostView.onFocusRequest`,
//    Phase 10's click-to-focus contract) — this is the pane she said works;
//  - **books** (`BookView.onPaneFocusRequest`), and only via
//    `BookViewModel.focus(_:)`, i.e. only when a POST inside the book takes
//    focus — a click on the chapter list, the header or the empty page does
//    nothing.
//
//  Every OTHER branch — Shelf, Library, Pool, Snippets, a tag folder, the
//  recovery surface — has no body-click door at all. Their ROWS focus the
//  pane, but only as a side effect of navigating it (`opener(pane)` →
//  `adopt` → `WorkspaceModel.select`), so the only way to focus such a pane
//  WITHOUT also changing what it shows was the name line. That asymmetry is
//  what she hit, and it is per-CONTENT, not per-side: whichever pane holds a
//  list is the pane whose body does nothing.
//
//  ── THE FIX, AND WHY IT IS SHAPED THIS WAY ───────────────────────────────
//  Parity belongs to the PANE, not to each of seven content surfaces —
//  fixing it content-by-content would leave the eighth surface to rediscover
//  it. So the pane itself watches for a click inside its own rectangle.
//
//  It watches through a LOCAL event monitor rather than an overlay, because
//  an overlay that catches clicks also EATS them: the read tier's click
//  carries a caret offset and every list row acts on first click, and
//  "click once to focus, click again to act" is a worse app than the one she
//  has. A monitor observes and returns the event untouched — the click still
//  does exactly what it did before, and the pane simply also becomes live.
//
//  It is installed ONLY while a pane is unfocused inside a split, so the
//  ordinary one-pane window carries no monitor at all. The decision itself
//  is pure (`PaneFocusClick`) and pinned as arithmetic; the view is the wire.
//

import AppKit
import SwiftUI

// MARK: - The decision (pure)

/// Whether a left mouse-down belongs to this pane. Deliberately total and
/// side-free — "left" and "right" appear nowhere; a pane is a rectangle in a
/// window, which is what keeps this honest under the free-tiling rider.
nonisolated enum PaneFocusClick {
    static func shouldFocus(
        clickInWindow: CGPoint,
        paneFrameInWindow: CGRect,
        active: Bool,
        sameWindow: Bool
    ) -> Bool {
        guard active, sameWindow else { return false }
        return paneFrameInWindow.contains(clickInWindow)
    }
}

// MARK: - The wire

/// A zero-drawing background view that reports clicks landing inside its own
/// frame. It never draws, never hit-tests and never consumes.
@MainActor
final class PaneFocusCatcherView: NSView {
    var onFocus: (() -> Void)?

    /// Installed only while the pane is unfocused in a split.
    var active = false {
        didSet {
            guard active != oldValue else { return }
            active ? install() : remove()
        }
    }

    /// Observation seam (the `fireConvergenceOccasion` idiom): how many
    /// clicks this catcher has claimed, so a pin can assert the WIRE fired
    /// rather than inferring it from a focus change something else could
    /// also have caused.
    private(set) var focusRequests = 0

    private var monitor: Any?

    /// The second observation seam: is the monitor actually installed? A pin
    /// asserts installation here and drives `handleLocalMouseDown` for the
    /// decision, because a synthesized event pushed through
    /// `NSApp.sendEvent` does NOT reach a local monitor — MEASURED in this
    /// test host while writing the pin (the monitor sees events coming off
    /// the event QUEUE, and an injected one never entered it). Asserting
    /// installation plus the body is the honest pair; claiming an end-to-end
    /// dispatch that the host cannot deliver would be the hollow one.
    var isWatching: Bool { monitor != nil }

    /// Never a hit-test target: the click belongs to whatever is above.
    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if window == nil { remove() } else if active { install() }
    }

    /// The monitor's body, exposed so a pin can drive the real decision with
    /// a real event in a real window.
    func handleLocalMouseDown(_ event: NSEvent) {
        guard let window else { return }
        guard PaneFocusClick.shouldFocus(
            clickInWindow: event.locationInWindow,
            paneFrameInWindow: convert(bounds, to: nil),
            active: active,
            // By NUMBER, not by `event.window`: that property is a lookup of
            // this same number through the window server, and it answers nil
            // for a window with no device — which is every window a test
            // builds and never orders in. The number is what the event
            // actually carries.
            sameWindow: event.windowNumber == window.windowNumber)
        else { return }
        focusRequests += 1
        onFocus?()
    }

    private func install() {
        guard monitor == nil, window != nil else { return }
        monitor = NSEvent.addLocalMonitorForEvents(matching: .leftMouseDown) {
            [weak self] event in
            MainActor.assumeIsolated { self?.handleLocalMouseDown(event) }
            // Untouched: the click goes on to do whatever it was going to do.
            return event
        }
    }

    func remove() {
        if let monitor { NSEvent.removeMonitor(monitor) }
        monitor = nil
    }
}

/// The SwiftUI face — mounted as a pane's `.background`, so its frame IS the
/// pane's rectangle.
struct PaneFocusCatcher: NSViewRepresentable {
    let active: Bool
    let onFocus: () -> Void

    func makeNSView(context: Context) -> PaneFocusCatcherView {
        let view = PaneFocusCatcherView()
        view.onFocus = onFocus
        view.active = active
        return view
    }

    func updateNSView(_ nsView: PaneFocusCatcherView, context: Context) {
        nsView.onFocus = onFocus
        nsView.active = active
    }

    static func dismantleNSView(_ nsView: PaneFocusCatcherView, coordinator: ()) {
        nsView.remove()
    }
}
