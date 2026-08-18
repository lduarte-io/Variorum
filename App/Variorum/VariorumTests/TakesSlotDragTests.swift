//
//  TakesSlotDragTests.swift
//  VariorumTests
//
//  Phase 13e, batch 7 — **THE ROUTED RIDER** from batch 5's E12 sweep:
//  `TakesBoardView.slotHeightHandle` carries the SAME coordinate-space
//  defect the canvas cards did (her kickoff finding, verbatim: *"they
//  jitter while moving and seemingly resist moving"*), and the sweep
//  table recorded it as "the same defect, NOT FIXED — out of E12's
//  letter (canvas), recorded for routing".
//
//  THE MECHANISM (batch 5's, one surface over): a `DragGesture` with no
//  coordinate space measures in the gesture VIEW's own space. The
//  slot-height handle sits directly BELOW the row it resizes, so
//  shortening the row moves the handle, and every event reports
//  `pointerDelta − alreadyAppliedChange`:
//
//      pointer −20 → T=−20 (height −20) → pointer −40 → T=−20 (STALL)
//      → pointer −60 → T=−40 → pointer −80 → T=−40 (STALL) → …
//
//  i.e. the strip follows HALF the pointer with an alternating stall, and
//  `.onEnded` commits one more feedback step short of the drop. Measuring
//  in the board's own named space (`TakesBoardView.surfaceSpace`) removes
//  the feedback term; this pin is RED on the pre-fix code with exactly
//  the halved numbers.
//
//  HOW IT DRIVES: batch 5's `CanvasDragRig` machinery, re-aimed — a
//  NON-ACTIVATING `NSPanel` (it takes key without the test host
//  activating), synthesized `NSEvent`s through `NSApp.sendEvent`, and the
//  app's own event pump (a bare `RunLoop.run(until:)` never DISPATCHES
//  queued NSEvents). The handle's position is not guessed: the board's
//  take cards are REAL `PaneTextView`s, so the strip's own
//  `NSScrollView` frame — converted to window coordinates — says exactly
//  where the row ends and the handle begins.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private struct SlotDragRig {
    let window: NSPanel
    let hosting: NSHostingView<TakesBoardView>
    let model: TakesViewModel
    let blockID: String

    static func mount(
        session: AppSession, database: AppDatabase, postID: String, blockID: String,
        defaults: UserDefaults
    ) async throws -> SlotDragRig {
        let model = TakesViewModel(session: session, postID: postID, defaults: defaults)
        // Driven by hand for determinism (the `TakesCardHeightTests` rig's
        // rule) — the board's own `.task` would load the same projection.
        model.adopt(try await database.read { try Queries.takesProjection($0, post: postID) })
        let window = NSPanel(
            contentRect: NSRect(x: 100, y: 100, width: 1000, height: 800),
            styleMask: [.titled, .nonactivatingPanel], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.isFloatingPanel = true
        window.becomesKeyOnlyIfNeeded = false
        window.hidesOnDeactivate = false
        let hosting = NSHostingView(
            rootView: TakesBoardView(session: session, postID: postID, model: model))
        hosting.frame = NSRect(x: 0, y: 0, width: 1000, height: 800)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        let rig = SlotDragRig(window: window, hosting: hosting, model: model, blockID: blockID)
        await rig.settle(turns: 8)
        model.toggleExpanded(blockID)
        await rig.settle(turns: 10)
        return rig
    }

    func close() {
        window.orderOut(nil)
        window.close()
    }

    func pump(_ seconds: TimeInterval) {
        let deadline = Date().addingTimeInterval(seconds)
        while Date() < deadline {
            if let event = NSApp.nextEvent(
                matching: .any, until: deadline, inMode: .default, dequeue: true) {
                NSApp.sendEvent(event)
            }
        }
    }

    func settle(turns: Int = 3) async {
        for _ in 0..<turns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump(0.03)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(15))
        }
    }

    private func panes(in view: NSView) -> [PaneTextView] {
        var found: [PaneTextView] = []
        if let pane = view as? PaneTextView { found.append(pane) }
        for sub in view.subviews { found.append(contentsOf: panes(in: sub)) }
        return found
    }

    private func cardPanes() -> [PaneTextView] {
        panes(in: hosting).filter { $0.identifier?.rawValue.hasPrefix("pane:mini|") == true }
    }

    private func scrollAncestor(of view: NSView) -> NSScrollView? {
        var current: NSView? = view.superview
        while let node = current, node !== hosting {
            if let scroll = node as? NSScrollView { return scroll }
            current = node.superview
        }
        return nil
    }

    /// The take strip's own frame, in WINDOW coordinates — the geometry
    /// that DRAWS the row, so the pin's pointer and the app's layout can
    /// never disagree (the batch-4 chord pin's rule).
    func stripRectInWindow() -> CGRect? {
        guard let card = cardPanes().first, let strip = scrollAncestor(of: card) else { return nil }
        return strip.convert(strip.bounds, to: nil)
    }

    /// The handle's grab point, found by PROBING rather than by
    /// arithmetic: the handle is a SwiftUI row BELOW the strip, and how
    /// much chrome sits between them is a layout detail no pin should
    /// encode (measured today: ~34 pt). A small shorten-drag is tried at
    /// candidate points below the strip's bottom edge — window
    /// coordinates are y-UP, so "below" is a SMALLER y — until one takes;
    /// the height that probe moved is reset before the real drag runs.
    func findHandlePoint() async -> CGPoint? {
        guard let strip = stripRectInWindow() else { return nil }
        var y = strip.minY - 2
        while y > strip.minY - 80 {
            let point = CGPoint(x: strip.midX, y: y)
            await dragUp(from: point, by: 20, steps: 2, midDrag: {})
            if model.slotHeight(blockID) != nil {
                model.resetSlotHeight(blockID)
                await settle(turns: 1)
                return point
            }
            y -= 3
        }
        return nil
    }

    func send(_ type: NSEvent.EventType, _ point: CGPoint) {
        guard let event = NSEvent.mouseEvent(
            with: type, location: point, modifierFlags: [],
            timestamp: ProcessInfo.processInfo.systemUptime,
            windowNumber: window.windowNumber, context: nil,
            eventNumber: 1, clickCount: 1, pressure: type == .leftMouseUp ? 0 : 1)
        else { return }
        NSApp.sendEvent(event)
    }

    /// A real drag UPWARD by `up` points (SwiftUI's y-down sense), in
    /// `steps` moves. `midDrag` runs after the last move, before mouse-up.
    func dragUp(from start: CGPoint, by up: CGFloat, steps: Int = 5, midDrag: () -> Void) async {
        send(.leftMouseDown, start)
        pump(0.05)
        for step in 1...steps {
            let fraction = CGFloat(step) / CGFloat(steps)
            // Dragging the handle UP (shortening) is +y in window terms.
            send(.leftMouseDragged, CGPoint(x: start.x, y: start.y + up * fraction))
            pump(0.03)
        }
        midDrag()
        send(.leftMouseUp, CGPoint(x: start.x, y: start.y + up))
        pump(0.1)
        await settle(turns: 2)
    }
}

@MainActor
private func withSlotBoard<T>(
    _ body: @MainActor (AppSession, AppDatabase, String, String) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 23))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        // A genuinely long fanned block in SLOT SPLIT — the composition
        // whose bloom carries the handle (carousel shares the same store).
        let text = (1...3).map { i in
            "Paragraph \(i). " + Array(
                repeating: "honest prose words keep flowing along the measured line and wrap",
                count: 3
            ).joined(separator: " ") + "."
        }.joined(separator: "\n\n")
        let post = try session.operations.createPost(title: "slot drag fixture")
        let minted = try session.operations.newBlock(in: post.id, text: text)
        let take = try session.operations.branchVariant(minted.block.id, from: minted.variant.id)
        try session.operations.autosave(take.id, text: text + "\n\ntake 2.", charDelta: 9)
        try session.operations.setFanStyle(.slotSplit)
        return try await body(session, db, post.id, minted.block.id)
    }
}

@Suite("13e rider — the takes slot-height drag (the E12 class)", .serialized)
@MainActor
struct TakesSlotDragTests {
    /// **RED ON THE PRE-FIX CODE**: a 200 pt shorten-drag moved the strip
    /// by ~half that, with the alternating stall her canvas report named,
    /// and committed a height one feedback step short of the drop.
    @Test func theSlotHeightHandleFollowsThePointerOneToOneInsteadOfHalfOfIt() async throws {
        try await withSlotBoard { session, db, postID, blockID in
            let defaults = UserDefaults(
                suiteName: "TakesSlotDragTests.\(UUID().uuidString)")!
            let rig = try await SlotDragRig.mount(
                session: session, database: db, postID: postID, blockID: blockID,
                defaults: defaults)
            defer { rig.close() }

            let natural = try #require(rig.model.naturalSlotHeight(blockID),
                                       "the fixture measured a natural height")
            #expect(natural > 300, "the fixture take is genuinely long (\(natural))")
            #expect(rig.model.slotHeight(blockID) == nil, "full length is the default (L3)")

            let found = await rig.findHandlePoint()
            let handle = try #require(found, "a real mouse drag grabbed the handle")
            var mid: CGFloat?
            await rig.dragUp(from: handle, by: 200) {
                mid = rig.model.slotHeight(blockID)
            }

            let expected = TakesBoardLayout.clampedSlotHeight(natural - 200, naturalHeight: natural)
            #expect(mid == expected,
                    "mid-drag the strip is exactly 200 pt shorter — pre-fix it moved ~120 (mid \(String(describing: mid)))")
            #expect(rig.model.slotHeight(blockID) == expected,
                    "…and it COMMITS where she let go — pre-fix it landed a feedback step short")
        }
    }
}
