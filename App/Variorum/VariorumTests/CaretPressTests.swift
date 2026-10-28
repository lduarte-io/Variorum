//
//  CaretPressTests.swift
//  VariorumTests
//
//  VX-601 batch A2 — VX-429 (in Takes, a drag that starts exactly at the
*[removed for publication]*
//  drag a highlight from where my cursor is currently typing, it doesn't
//  work"*). ONE traced mechanism (the run record's BATCH A2 RECORD, `notes/
//  plans/fixes/vx-601-run-takes-editor-quick-fixes.md`, and `Surface/
//  CaretPress.swift`): on AppKit's classic mouse road — every text view that
//  overrides `mouseDown`, which both of this app's writing surfaces do — a
//  SETTLED caret counts as covering the character after it, so a press on
//  that character, HELD a moment before moving, begins a drag of the EMPTY
//  selection and nothing happens at all.
//
//  How the pins press (measured first in standalone offscreen probes): the
//  mouse-down is handed to the view directly (the hosted window is never
//  ordered in — no screen, no real pointer), and the drag and the mouse-up
//  are QUEUED INTO AppKit's own tracking loop by a timer in the
//  event-tracking run-loop mode, after a real hold — the press-hold-move
//  shape her hand makes. Every gesture here either selects or drags an EMPTY
//  selection, whose AppKit drag answers false before any image, pasteboard or
//  session (measured), so no pin can start a real drag on either tree; a
//  drag-out of a NON-empty selection is deliberately never pressed here (it
//  would start a real one) — the pure rule pins that it is never touched.
//
//  RED ON OLD: every pin marked so below; the guards are green on both sides
//  and say so.
//

import AppKit
import Foundation
import Observation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The press: hold, then move, inside AppKit's own tracking loop

@MainActor
enum CaretPressGesture {
    /// The point on `index`'s glyph, `dx` points right of its leading edge,
    /// in the VIEW's space (the caret before `index` stands at `dx == 0`). The
    /// default, one point in, is ON the caret where she sees it and inside the
    /// glyph's leading half in either voice — so a press there anchors at
    /// `index` (the pins assert it: `anchors(_:at:in:)`).
    static func point(_ index: Int, dx: CGFloat = 1, in view: NSTextView) -> NSPoint {
        guard let window = view.window else { return .zero }
        var actual = NSRange()
        let screen = view.firstRect(
            forCharacterRange: NSRange(location: index, length: 0), actualRange: &actual)
        let rect = view.convert(window.convertFromScreen(screen), from: nil)
        return NSPoint(x: rect.minX + dx, y: rect.midY)
    }

    static func event(
        _ type: NSEvent.EventType, at point: NSPoint, in view: NSTextView,
        flags: NSEvent.ModifierFlags
    ) -> NSEvent? {
        guard let window = view.window else { return nil }
        return NSEvent.mouseEvent(
            with: type, location: view.convert(point, to: nil), modifierFlags: flags,
            timestamp: ProcessInfo.processInfo.systemUptime,
            windowNumber: window.windowNumber, context: nil,
            eventNumber: 0, clickCount: 1,
            pressure: type == .leftMouseUp ? 0 : 1)
    }

    /// A press at `from`, held `hold` seconds, then (when `to` is given) a
    /// drag there in six steps, then the mouse-up — every event after the
    /// down delivered INTO the view's tracking loop as it runs.
    static func press(
        _ view: NSTextView, from: NSPoint, to: NSPoint?, hold: TimeInterval,
        flags: NSEvent.ModifierFlags = []
    ) {
        guard let down = event(.leftMouseDown, at: from, in: view, flags: flags) else { return }
        let feed = CaretPressFeed(view: view, from: from, to: to, hold: hold, flags: flags)
        let timer = Timer(
            timeInterval: 0.008, target: feed, selector: #selector(CaretPressFeed.tick(_:)),
            userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .eventTracking)
        RunLoop.main.add(timer, forMode: .default)
        view.mouseDown(with: down)
        timer.invalidate()
        // Nothing of this gesture may outlive it.
        while let left = NSApp.nextEvent(
            matching: [.leftMouseDragged, .leftMouseUp], until: Date(),
            inMode: .default, dequeue: true) { _ = left }
    }

    /// The press's own precondition, said: the point is on character `index`
    /// (the one the caret precedes — the measured zone) and a press there
    /// anchors a selection at `index`.
    static func anchors(_ point: NSPoint, at index: Int, in view: NSTextView) -> Bool {
        guard let window = view.window else { return false }
        let under = view.characterIndex(for: window.convertPoint(toScreen: view.convert(point, to: nil)))
        return under == index && view.characterIndexForInsertion(at: point) == index
    }

    /// A plain click (no hold) — how she puts the caret somewhere.
    static func click(_ view: NSTextView, at point: NSPoint) {
        press(view, from: point, to: nil, hold: 0)
    }

    /// Let the caret SETTLE — the measured precondition (a run-loop turn
    /// after it was placed; a display pass alone does not do it). Plain
    /// run-loop turns: no main-queue hop is needed (measured inside a
    /// main-queue callback, the test host's own shape).
    static func settleCaret(_ view: NSView) {
        for _ in 0..<10 {
            view.displayIfNeeded()
            RunLoop.main.run(until: Date().addingTimeInterval(0.03))
        }
    }
}

/// The gesture's feed: posts the drag steps and the mouse-up once the hold
/// has passed — a timer TARGET (not a block), so nothing non-Sendable rides a
/// `@Sendable` closure; it fires on the main run loop, in the tracking mode.
@MainActor
final class CaretPressFeed: NSObject {
    private let view: NSTextView
    private let from: NSPoint
    private let to: NSPoint?
    private let hold: TimeInterval
    private let flags: NSEvent.ModifierFlags
    private let start = Date()
    private var fired = 0

    init(view: NSTextView, from: NSPoint, to: NSPoint?, hold: TimeInterval, flags: NSEvent.ModifierFlags) {
        self.view = view
        self.from = from
        self.to = to
        self.hold = hold
        self.flags = flags
    }

    @objc func tick(_ timer: Timer) {
        guard Date().timeIntervalSince(start) >= hold else { return }
        fired += 1
        let steps = to == nil ? 0 : 6
        if fired <= steps, let to {
            let f = CGFloat(fired) / CGFloat(steps)
            let at = NSPoint(x: from.x + (to.x - from.x) * f, y: from.y + (to.y - from.y) * f)
            if let drag = CaretPressGesture.event(.leftMouseDragged, at: at, in: view, flags: flags) {
                NSApp.postEvent(drag, atStart: false)
            }
        } else {
            if let up = CaretPressGesture.event(.leftMouseUp, at: to ?? from, in: view, flags: flags) {
                NSApp.postEvent(up, atStart: false)
            }
            timer.invalidate()
        }
    }
}

// MARK: - The pane rig (the ONE pane component, hosted as the boards host it)

/// One pane's host state. File-scope: `@Observable` cannot expand on a
/// `private` nested type.
@MainActor @Observable
fileprivate final class PressPane {
    var text: String
    var isLive: Bool
    var landing: PaneCaretLanding
    @ObservationIgnored var selections: [NSRange] = []
    @ObservationIgnored var clickPlaces: [Int] = []
    @ObservationIgnored var focusRequests = 0

    init(text: String, isLive: Bool, landing: PaneCaretLanding = .leave) {
        self.text = text
        self.isLive = isLive
        self.landing = landing
    }
}

fileprivate struct PressPaneHost: View {
    let pane: PressPane

    var body: some View {
        PaneSurfaceView(
            text: pane.text, isLive: pane.isLive,
            role: "press", variantID: "v-press",
            onFocusRequest: { pane.focusRequests += 1 },
            onClickPlace: { pane.clickPlaces.append($0) },
            onEdit: { pane.text = $0 },
            onSelectionChange: { pane.selections.append($0) },
            caretOnGoingLive: pane.landing)
            .frame(width: 720)
    }
}

/// An OFFSCREEN window that is never ordered in (`LifecycleRig`'s shape).
@MainActor
fileprivate struct PressPaneRig {
    let window: NSWindow
    let hosting: NSHostingView<PressPaneHost>

    init(_ pane: PressPane) {
        hosting = NSHostingView(rootView: PressPaneHost(pane: pane))
        hosting.frame = NSRect(x: 0, y: 0, width: 720, height: 300)
        window = NSWindow(
            contentRect: NSRect(x: -20_000, y: -20_000, width: 720, height: 300),
            styleMask: [.borderless], backing: .buffered, defer: true)
        window.isReleasedWhenClosed = false
        let content = NSView(frame: NSRect(x: 0, y: 0, width: 720, height: 300))
        content.addSubview(hosting)
        window.contentView = content
    }

    func close() {
        window.contentView = nil
        window.close()
    }

    func settle() async {
        await HostLaunchSettle.wait()  // never pump into the host's launch
        for _ in 0..<8 {
            hosting.layoutSubtreeIfNeeded()
            window.displayIfNeeded()
            Self.pump()
            await Task.yield()
        }
    }

    /// A run-loop turn — synchronous, because `run(until:)` is unavailable
    /// from an async context (`LifecycleRig.pump`'s shape).
    private static func pump() {
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
    }

    var pane: PaneTextView? { Self.find(in: hosting) }

    private static func find(in view: NSView) -> PaneTextView? {
        if let pane = view as? PaneTextView { return pane }
        for sub in view.subviews {
            if let found = find(in: sub) { return found }
        }
        return nil
    }
}

private let pressText = "alpha bravo charlie delta echo foxtrot golf hotel"

// MARK: - VX-429 — the pane (every Takes/Lenses/Compare/… pane is this one view)

@MainActor
@Suite("VX-429 — a press on the caret starts a selection in a pane", .serialized)
struct PaneCaretPressTests {
    /// Mount a LIVE pane, put the caret at `caret` with a real click, let it
    /// settle. Returns nil (with an issue) if the rig did not stand up.
    private func liveRig(
        caret: Int
    ) async -> (PressPane, PressPaneRig, PaneTextView)? {
        let pane = PressPane(text: pressText, isLive: true)
        let rig = PressPaneRig(pane)
        await rig.settle()
        guard let view = rig.pane else {
            Issue.record("the pane did not mount")
            rig.close()
            return nil
        }
        rig.window.makeFirstResponder(view)
        CaretPressGesture.click(view, at: CaretPressGesture.point(caret, dx: 0.5, in: view))
        await rig.settle()
        CaretPressGesture.settleCaret(view)
        return (pane, rig, view)
    }

    /// **RED ON OLD — her gesture.** The caret sits where she clicked; she
    /// presses ON it (its right side, where she sees it), holds a moment, and
    /// drags. On the old tree AppKit treated the press as inside the empty
    /// selection and dragged nothing: the selection stayed `{12, 0}`.
    @Test func aHeldDragFromTheCaretsOwnPlaceSelects() async throws {
        guard case let (_, rig, view)? = await liveRig(caret: 12) else { return }
        defer { rig.close() }
        #expect(view.selectedRange() == NSRange(location: 12, length: 0),
                "the click put the caret at 12 (\(view.selectedRange()))")
        let end = view.characterIndexForInsertion(at: CaretPressGesture.point(30, dx: 0, in: view))
        #expect(CaretPressGesture.anchors(CaretPressGesture.point(12, in: view), at: 12, in: view),
                "the press is on the caret's own character")
        CaretPressGesture.press(
            view, from: CaretPressGesture.point(12, in: view),
            to: CaretPressGesture.point(30, dx: 0, in: view), hold: 0.4)
        #expect(view.selectedRange() == NSRange(location: 12, length: end - 12),
                "the drag from the caret selected (\(view.selectedRange()), end \(end))")
    }

    /// **RED ON OLD — the landing's caret** (the note's ENTRY rule lands a
    /// pane at its START, QUESTIONS #97): a pane that went live with its caret
    /// at 0, pressed on its first character, held, dragged.
    @Test func aHeldDragFromALandedCaretAtTheStartSelects() async throws {
        let pane = PressPane(text: pressText, isLive: true, landing: .start)
        let rig = PressPaneRig(pane)
        defer { rig.close() }
        await rig.settle()
        let view = try #require(rig.pane)
        rig.window.makeFirstResponder(view)
        CaretPressGesture.settleCaret(view)
        #expect(view.selectedRange() == NSRange(location: 0, length: 0),
                "the landing put the caret at the start (\(view.selectedRange()))")
        let end = view.characterIndexForInsertion(at: CaretPressGesture.point(20, dx: 0, in: view))
        #expect(CaretPressGesture.anchors(CaretPressGesture.point(0, in: view), at: 0, in: view),
                "the press is on the caret's own character")
        CaretPressGesture.press(
            view, from: CaretPressGesture.point(0, in: view),
            to: CaretPressGesture.point(20, dx: 0, in: view), hold: 0.4)
        #expect(view.selectedRange() == NSRange(location: 0, length: end),
                "the drag from the landed caret selected (\(view.selectedRange()))")
    }

    /// **RED ON OLD — a READ pane's kept selection** (VX-296: a pane going read
    /// keeps its selection, unseen). The same press there dragged nothing on
    /// the old tree — and then read as a plain click (a focus request).
    @Test func aReadPanesKeptCaretNeverEatsADrag() async throws {
        guard case let (pane, rig, view)? = await liveRig(caret: 12) else { return }
        defer { rig.close() }
        pane.isLive = false
        await rig.settle()
        CaretPressGesture.settleCaret(view)
        #expect(!view.isEditable, "the pane reads")
        #expect(view.selectedRange() == NSRange(location: 12, length: 0),
                "the read pane kept its selection (\(view.selectedRange()))")
        let focusBefore = pane.focusRequests
        let end = view.characterIndexForInsertion(at: CaretPressGesture.point(30, dx: 0, in: view))
        #expect(CaretPressGesture.anchors(CaretPressGesture.point(12, in: view), at: 12, in: view),
                "the press is on the caret's own character")
        CaretPressGesture.press(
            view, from: CaretPressGesture.point(12, in: view),
            to: CaretPressGesture.point(30, dx: 0, in: view), hold: 0.4)
        #expect(view.selectedRange() == NSRange(location: 12, length: end - 12),
                "the drag on the read pane selected (\(view.selectedRange()))")
        #expect(pane.focusRequests == focusBefore,
                "a drag-selection is not a click — no focus request")
    }

    /// GUARD (green on both sides) — the same held drag from ANY OTHER place
    /// always selected: the asymmetry her report names.
    @Test func aHeldDragFromElsewhereSelects() async throws {
        guard case let (_, rig, view)? = await liveRig(caret: 12) else { return }
        defer { rig.close() }
        let end = view.characterIndexForInsertion(at: CaretPressGesture.point(30, dx: 0, in: view))
        CaretPressGesture.press(
            view, from: CaretPressGesture.point(6, dx: 0.5, in: view),
            to: CaretPressGesture.point(30, dx: 0, in: view), hold: 0.4)
        #expect(view.selectedRange() == NSRange(location: 6, length: end - 6),
                "elsewhere selects (\(view.selectedRange()))")
    }

    /// GUARD (green on both sides) — a QUICK press-and-move from the caret
    /// selected on the old tree too: why it read as "sometimes".
    @Test func aQuickDragFromTheCaretSelects() async throws {
        guard case let (_, rig, view)? = await liveRig(caret: 12) else { return }
        defer { rig.close() }
        let end = view.characterIndexForInsertion(at: CaretPressGesture.point(30, dx: 0, in: view))
        #expect(CaretPressGesture.anchors(CaretPressGesture.point(12, in: view), at: 12, in: view),
                "the press is on the caret's own character")
        CaretPressGesture.press(
            view, from: CaretPressGesture.point(12, in: view),
            to: CaretPressGesture.point(30, dx: 0, in: view), hold: 0.02)
        #expect(view.selectedRange() == NSRange(location: 12, length: end - 12),
                "a quick drag selects (\(view.selectedRange()))")
    }

    /// GUARD (green on both sides) — a held CLICK on the caret, no move, is
    /// still exactly a click: the caret where it was, one selection report,
    /// the click's place handed up. The fix must not change what a click is.
    @Test func aHeldClickOnTheCaretIsStillAPlainClick() async throws {
        guard case let (pane, rig, view)? = await liveRig(caret: 12) else { return }
        defer { rig.close() }
        let reportsBefore = pane.selections.count
        let placesBefore = pane.clickPlaces.count
        #expect(CaretPressGesture.anchors(CaretPressGesture.point(12, in: view), at: 12, in: view),
                "the press is on the caret's own character")
        CaretPressGesture.press(
            view, from: CaretPressGesture.point(12, in: view), to: nil, hold: 0.4)
        #expect(view.selectedRange() == NSRange(location: 12, length: 0),
                "the click left the caret at 12 (\(view.selectedRange()))")
        #expect(pane.selections.count - reportsBefore == 1,
                "one selection report, as ever (\(pane.selections.suffix(3)))")
        #expect(pane.selections.last == NSRange(location: 12, length: 0))
        #expect(Array(pane.clickPlaces.dropFirst(placesBefore)) == [12],
                "the click's place was handed up (\(pane.clickPlaces))")
    }

    /// GUARD (green on both sides) — ⇧-click still extends from the caret
    /// (the rule never touches a modified click).
    @Test func aShiftClickStillExtendsFromTheCaret() async throws {
        guard case let (_, rig, view)? = await liveRig(caret: 12) else { return }
        defer { rig.close() }
        let end = view.characterIndexForInsertion(at: CaretPressGesture.point(30, dx: 0, in: view))
        CaretPressGesture.press(
            view, from: CaretPressGesture.point(30, dx: 0, in: view), to: nil, hold: 0.02,
            flags: .shift)
        #expect(view.selectedRange() == NSRange(location: 12, length: end - 12),
                "⇧-click extended from the caret (\(view.selectedRange()))")
    }
}

// MARK: - VX-592 — the Write editor (the other surface on the classic road)

@MainActor
@Suite("VX-592 — a press on the caret starts a selection in Write", .serialized)
struct EditorCaretPressTests {
    /// The editor in an offscreen window never ordered in, the caret put at
    /// `caret` by a real click and settled.
    private func mounted(
        _ h: EditorHarness, caret: Int
    ) throws -> NSWindow {
        let scrollView = try #require(h.textView.enclosingScrollView)
        scrollView.frame = NSRect(x: 0, y: 0, width: 720, height: 400)
        let window = NSWindow(
            contentRect: NSRect(x: -20_000, y: -20_000, width: 720, height: 400),
            styleMask: [.borderless], backing: .buffered, defer: true)
        window.isReleasedWhenClosed = false
        let content = NSView(frame: NSRect(x: 0, y: 0, width: 720, height: 400))
        content.addSubview(scrollView)
        window.contentView = content
        window.layoutIfNeeded()
        window.displayIfNeeded()
        CaretPressGesture.settleCaret(content)
        window.makeFirstResponder(h.textView)
        CaretPressGesture.click(
            h.textView, at: CaretPressGesture.point(caret, dx: 0.5, in: h.textView))
        CaretPressGesture.settleCaret(h.textView)
        return window
    }

    *[removed for publication]*
    /// typing; a press on it, held, dragged — nothing on the old tree.
    @Test func aHeldDragFromTheCaretSelectsInWrite() async throws {
        await HostLaunchSettle.wait()  // never pump into the host's launch
        try await withEditor(seedBlocks: [pressText, "india juliet kilo"]) { h in
            let window = try mounted(h, caret: 12)
            defer {
                window.contentView = nil
                window.close()
            }
            let view = h.textView
            #expect(view.selectedRange() == NSRange(location: 12, length: 0),
                    "the click put the caret at 12 (\(view.selectedRange()))")
            let end = view.characterIndexForInsertion(at: CaretPressGesture.point(30, dx: 0, in: view))
            #expect(CaretPressGesture.anchors(CaretPressGesture.point(12, in: view), at: 12, in: view),
                    "the press is on the caret's own character")
            CaretPressGesture.press(
                view, from: CaretPressGesture.point(12, in: view),
                to: CaretPressGesture.point(30, dx: 0, in: view), hold: 0.4)
            #expect(view.selectedRange() == NSRange(location: 12, length: end - 12),
                    "the drag from the caret selected (\(view.selectedRange()), end \(end))")
        }
    }

    /// **RED ON OLD — the caret where she TYPED.** She types a word, then
    /// drags from the caret the typing left — her exact words, *"from where
    /// my cursor is currently typing."*
    @Test func aHeldDragFromWhereSheJustTypedSelectsInWrite() async throws {
        await HostLaunchSettle.wait()
        try await withEditor(seedBlocks: [pressText, "india juliet kilo"]) { h in
            let window = try mounted(h, caret: 11)
            defer {
                window.contentView = nil
                window.close()
            }
            let view = h.textView
            h.type("x")  // "alpha bravo" + "x" — the caret now at 12, typed
            await h.flush()
            CaretPressGesture.settleCaret(view)
            #expect(view.selectedRange() == NSRange(location: 12, length: 0),
                    "typing left the caret at 12 (\(view.selectedRange()))")
            let end = view.characterIndexForInsertion(at: CaretPressGesture.point(30, dx: 0, in: view))
            #expect(CaretPressGesture.anchors(CaretPressGesture.point(12, in: view), at: 12, in: view),
                    "the press is on the caret's own character")
            CaretPressGesture.press(
                view, from: CaretPressGesture.point(12, in: view),
                to: CaretPressGesture.point(30, dx: 0, in: view), hold: 0.4)
            #expect(view.selectedRange() == NSRange(location: 12, length: end - 12),
                    "the drag from the typed caret selected (\(view.selectedRange()))")
        }
    }

    /// GUARD (green on both sides) — the same held drag from elsewhere.
    @Test func aHeldDragFromElsewhereSelectsInWrite() async throws {
        await HostLaunchSettle.wait()
        try await withEditor(seedBlocks: [pressText, "india juliet kilo"]) { h in
            let window = try mounted(h, caret: 12)
            defer {
                window.contentView = nil
                window.close()
            }
            let view = h.textView
            let end = view.characterIndexForInsertion(at: CaretPressGesture.point(30, dx: 0, in: view))
            CaretPressGesture.press(
                view, from: CaretPressGesture.point(6, dx: 0.5, in: view),
                to: CaretPressGesture.point(30, dx: 0, in: view), hold: 0.4)
            #expect(view.selectedRange() == NSRange(location: 6, length: end - 6),
                    "elsewhere selects (\(view.selectedRange()))")
        }
    }

    /// GUARD (green on both sides) — a held click on the caret stays a click.
    @Test func aHeldClickOnTheCaretStaysAClickInWrite() async throws {
        await HostLaunchSettle.wait()
        try await withEditor(seedBlocks: [pressText, "india juliet kilo"]) { h in
            let window = try mounted(h, caret: 12)
            defer {
                window.contentView = nil
                window.close()
            }
            let view = h.textView
            #expect(CaretPressGesture.anchors(CaretPressGesture.point(12, in: view), at: 12, in: view),
                    "the press is on the caret's own character")
            CaretPressGesture.press(
                view, from: CaretPressGesture.point(12, in: view), to: nil, hold: 0.4)
            #expect(view.selectedRange() == NSRange(location: 12, length: 0),
                    "the click left the caret at 12 (\(view.selectedRange()))")
        }
    }
}

// MARK: - The rule, pure

@Suite("VX-429/VX-592 — CaretPress's rule")
struct CaretPressRuleTests {
    private let text = pressText as NSString

    @Test func aPressOnTheCharacterAfterTheCaretMovesItPastThatCharacter() {
        #expect(CaretPress.caretBeforePress(
            selection: [NSRange(location: 12, length: 0)], pressedCharacter: 12, text: text) == 13)
    }

    @Test func aPressOnTheCharacterBeforeTheCaretMovesItToo() {
        // The boundary pixel: harmless, and it keeps the measured zone whole.
        #expect(CaretPress.caretBeforePress(
            selection: [NSRange(location: 12, length: 0)], pressedCharacter: 11, text: text) == 13)
    }

    @Test func aPressAnywhereElseLeavesTheCaret() {
        for pressed in [0, 6, 10, 13, 30, 48] {
            #expect(CaretPress.caretBeforePress(
                selection: [NSRange(location: 12, length: 0)], pressedCharacter: pressed,
                text: text) == nil, "pressed \(pressed)")
        }
    }

    @Test func aRealSelectionIsNeverTouched() {
        // A drag-out of a selection is AppKit's, unchanged.
        for pressed in [5, 6, 10, 18, 19] {
            #expect(CaretPress.caretBeforePress(
                selection: [NSRange(location: 6, length: 13)], pressedCharacter: pressed,
                text: text) == nil, "pressed \(pressed)")
        }
    }

    @Test func severalSelectionsAreNeverTouched() {
        #expect(CaretPress.caretBeforePress(
            selection: [NSRange(location: 3, length: 0), NSRange(location: 12, length: 0)],
            pressedCharacter: 12, text: text) == nil)
    }

    @Test func aCaretAtTheEndCoversNothing() {
        #expect(CaretPress.caretBeforePress(
            selection: [NSRange(location: text.length, length: 0)],
            pressedCharacter: text.length - 1, text: text) == nil)
    }

    @Test func aCaretAtTheStartMovesPastTheFirstCharacter() {
        #expect(CaretPress.caretBeforePress(
            selection: [NSRange(location: 0, length: 0)], pressedCharacter: 0, text: text) == 1)
    }

    @Test func theMoveNeverLandsInsideAComposedCharacter() {
        let composed = "ab👍🏽cd" as NSString  // the thumbs-up + skin tone is 4 UTF-16 units
        #expect(CaretPress.caretBeforePress(
            selection: [NSRange(location: 2, length: 0)], pressedCharacter: 2,
            text: composed) == 6)
    }

    @Test func noSelectionAtAllIsLeftAlone() {
        #expect(CaretPress.caretBeforePress(
            selection: [], pressedCharacter: 0, text: text) == nil)
        #expect(CaretPress.caretBeforePress(
            selection: [NSRange(location: NSNotFound, length: 0)], pressedCharacter: 0,
            text: text) == nil)
    }

    @Test func onlyAPlainSingleLeftClickIsTheRulesPress() {
        #expect(CaretPress.isPlainSingleClick(type: .leftMouseDown, clickCount: 1, modifiers: []))
        #expect(CaretPress.isPlainSingleClick(
            type: .leftMouseDown, clickCount: 1, modifiers: .capsLock),
            "caps lock is not a modifier of the gesture")
        #expect(!CaretPress.isPlainSingleClick(type: .leftMouseDown, clickCount: 2, modifiers: []))
        #expect(!CaretPress.isPlainSingleClick(type: .leftMouseDown, clickCount: 3, modifiers: []))
        for flag: NSEvent.ModifierFlags in [.shift, .command, .option, .control] {
            #expect(!CaretPress.isPlainSingleClick(
                type: .leftMouseDown, clickCount: 1, modifiers: flag), "\(flag)")
        }
        #expect(!CaretPress.isPlainSingleClick(type: .rightMouseDown, clickCount: 1, modifiers: []))
    }
}
