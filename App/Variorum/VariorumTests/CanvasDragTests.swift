//
//  CanvasDragTests.swift
//  VariorumTests
//
//  Phase 13e, batch 5 — E12: the canvas drag jitter/resist regression
//  (her kickoff-sitting finding, verbatim: *"right now moving cards around
//  on canvas is very weird and buggy compared to how it used to be. they
//  jitter while moving and seemingly resist moving"*).
//
//  THE MECHANISM (traced, then measured — the hallucination guard): a
//  `DragGesture()` with no coordinate space measures in the gesture view's
//  own space, and that space is displaced by the very `.offset` (card move)
//  or size change (resize grip) the drag's own translation applies. Each
//  event therefore reports `pointerDelta − alreadyAppliedOffset`, which
//  converges to HALF the pointer's travel and alternates step/stall:
//
//      pointer +20 → T=20 (offset 20) → pointer +40 → T=20 (STALL)
//      → pointer +60 → T=40 → pointer +80 → T=40 (STALL) → …
//
//  measured on the real view below as (60,30) mid-drag and (40,20) at
//  `.onEnded` for a pointer that travelled (100,50) — so the card stutters
//  (jitter), lags the pointer (resist), and LANDS 60pt short of the drop.
//  Measuring in a space the drag cannot move (`CanvasView.surfaceSpace`)
//  removes the feedback term; these pins are red on the pre-fix code with
//  exactly the halved numbers above.
//
//  HOW THEY DRIVE: synthesized `NSEvent`s through `NSApp.sendEvent` into a
//  NON-ACTIVATING panel — a real mouseDown/dragged/up sequence through
//  SwiftUI's own gesture machinery (nothing else reaches a SwiftUI
//  gesture), with no CGEvent, no cursor movement, and no focus steal: the
//  panel takes key without the test host activating.
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
private func withCanvasWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 17))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

/// The hosted drag rig: a non-activating panel, a synthesized mouse, and a
/// board-point → window-point converter through the real `NSScrollView`
/// SwiftUI builds the board's ScrollView on.
@MainActor
struct CanvasDragRig {
    let window: NSPanel
    let hosting: NSView
    let model: CanvasViewModel

    static func mount(
        session: AppSession, containerID: String, cards: Int
    ) async -> CanvasDragRig {
        // Defaults hygiene (the 4G rule): deterministic ids recur across
        // runs — clear the view-memory keys the view would read.
        UserDefaults.standard.removeObject(forKey: "canvasViewMemory.\(containerID)")
        UserDefaults.standard.removeObject(forKey: "canvasSizeMemory.\(containerID)")
        let model = CanvasViewModel(session: session, containerID: containerID)
        let window = NSPanel(
            contentRect: NSRect(x: 120, y: 120, width: 900, height: 700),
            styleMask: [.titled, .nonactivatingPanel], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.isFloatingPanel = true
        window.becomesKeyOnlyIfNeeded = false
        window.hidesOnDeactivate = false
        let hosting = NSHostingView(rootView: CanvasView(
            session: session, containerID: containerID, offersLensSave: false, model: model))
        hosting.frame = NSRect(x: 0, y: 0, width: 900, height: 700)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        let rig = CanvasDragRig(window: window, hosting: hosting, model: model)
        rig.pump(0.2)
        for _ in 0..<60 where model.projection.cards.count < cards {
            await rig.settle(turns: 1)
        }
        await rig.settle()
        return rig
    }

    func close() {
        window.orderOut(nil)
        window.close()
    }

    /// The app's own event pump: a bare RunLoop never DISPATCHES queued
    /// NSEvents, and `NSApp.sendEvent` is what sets `NSApp.currentEvent`,
    /// which SwiftUI's gesture machinery reads.
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
            await turn()
        }
    }

    /// ONE settle turn — layout, a pump, a yield. The unit both `settle`
    /// and `poll` are built from, so "wait a moment" means one thing in this
    /// rig. The DEFAULT keeps the pre-hardening cost exactly (0.03 s + 15 ms):
    /// the settle waits were never the flake, and shortening them would trade
    /// one timing bug for another. `poll` passes a cheaper turn because it
    /// re-checks its condition every time round.
    func turn(_ pumpFor: TimeInterval = 0.03, sleepMs: Int = 15) async {
        hosting.layoutSubtreeIfNeeded()
        window.layoutIfNeeded()
        window.displayIfNeeded()
        pump(pumpFor)
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(sleepMs))
    }

    /// **POLL FOR THE CONDITION — never sleep a fixed slice** (13j batch 6,
    /// the architect's rig-hardening ruling after batch 5).
    ///
    /// The trace it closes: batch 5 measured intermittent canvas reds whose
    /// every failing assertion was the `midDrag == nil` shape — the SwiftUI
    /// drag gesture had not been RECOGNIZED yet when the rig's mid-drag
    /// closure ran. The rigs pumped a fixed 0.03 s per synthesized event and
    /// then read; under full-suite concurrency that window is sometimes too
    /// small, which is why the same tests pass standalone and the failing
    /// SUBSET varies run to run (it reproduced on a pre-batch worktree, so it
    /// was never any batch's product code). A fixed sleep is exactly the
    /// anti-pattern the phase's Environment traps outlaw in spirit
    /// ("async-poll, never sync RunLoop pumping"); this waits for the thing
    /// itself.
    ///
    /// `redrive` runs each turn while the condition is false: for a drag,
    /// re-sending the FINAL drag point is harmless and idempotent, because
    /// SwiftUI measures a `DragGesture`'s translation from the mouse-DOWN
    /// location — a repeat carries the identical value, so no assertion can
    /// move because the rig waited.
    @discardableResult
    func poll(
        until condition: () -> Bool, timeout: TimeInterval = 3,
        redrive: () -> Void = {}
    ) async -> Bool {
        if condition() { return true }
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            redrive()
            await turn(0.01, sleepMs: 5)
            if condition() { return true }
        }
        return condition()
    }

    private var documentView: NSView? {
        func scrolls(_ view: NSView) -> [NSScrollView] {
            var found: [NSScrollView] = []
            if let scroll = view as? NSScrollView { found.append(scroll) }
            for sub in view.subviews { found.append(contentsOf: scrolls(sub)) }
            return found
        }
        return scrolls(hosting).first?.documentView
    }

    /// A point in BOARD coordinates (SwiftUI, y-down, origin-shifted like
    /// the view draws) → window coordinates (AppKit, y-up).
    func windowPoint(boardX: CGFloat, boardY: CGFloat) -> CGPoint? {
        documentView?.convert(NSPoint(x: boardX, y: boardY), to: nil)
    }

    /// A point in the canvas SURFACE space (what the bank strip and the
    /// board viewport report their frames in) → window coordinates.
    func windowPointFromSurface(_ point: CGPoint) -> CGPoint {
        let local = hosting.isFlipped
            ? NSPoint(x: point.x, y: point.y)
            : NSPoint(x: point.x, y: hosting.bounds.height - point.y)
        return hosting.convert(local, to: nil)
    }

    /// …and back.
    func surfacePointFromWindow(_ point: CGPoint) -> CGPoint {
        let local = hosting.convert(point, from: nil)
        return hosting.isFlipped
            ? CGPoint(x: local.x, y: local.y)
            : CGPoint(x: local.x, y: hosting.bounds.height - local.y)
    }

    /// The rendered top-left of a card, in the board's drawn coordinates.
    func cardOrigin(blockID: String) -> CGPoint {
        let resting = model.restingPosition(blockID: blockID)
        var minX: CGFloat = 0
        var minY: CGFloat = 0
        for frame in model.cardFrames.values {
            minX = min(minX, frame.minX)
            minY = min(minY, frame.minY)
        }
        return CGPoint(x: resting.x - (minX - 20), y: resting.y - (minY - 20))
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

    /// A real drag: down, `steps` moves along (dx, dy) in SWIFTUI terms
    /// (y-down — the window's y is inverted for you), then up at the end.
    /// `midDrag` runs after the last move, before the mouse-up.
    ///
    /// `started` is the GESTURE-START condition (13j batch 6): the rig waits
    /// for it — re-sending the final drag point each turn — before running
    /// `midDrag`, instead of assuming a fixed pump was long enough. Callers
    /// whose in-flight state is view-local (the bank chip's `@State`) leave
    /// it at its default and poll their OUTCOME instead.
    func drag(
        from start: CGPoint, dx: CGFloat, dy: CGFloat, steps: Int = 5,
        started: () -> Bool = { true },
        midDrag: () -> Void
    ) async {
        let end = CGPoint(x: start.x + dx, y: start.y - dy)
        sendDragSequence(from: start, dx: dx, dy: dy, steps: steps)
        // The gesture-start poll — and its redrive is the WHOLE sequence
        // again, not another dragged event: an attempt that produced no
        // `onChanged` produced no gesture at all, and a lone drag event with
        // no accepted mouse-down starts nothing. A retry is safe by the same
        // fact — SwiftUI only ends a gesture it began, so the closing up
        // lands on nothing — and it carries the identical translation,
        // because the retry's own down is at `start`.
        await poll(until: started, redrive: {
            send(.leftMouseUp, end)
            sendDragSequence(from: start, dx: dx, dy: dy, steps: steps)
        })
        midDrag()
        send(.leftMouseUp, end)
        pump(0.1)
        await settle(turns: 2)
    }

    /// Down, `steps` moves, no up — the event cadence itself, kept TIGHT
    /// (bare pumps, no layout pass and no async suspension between events).
    ///
    /// **Measured, 13j batch 6:** a first cut of the hardening put a full
    /// settle turn between the synthesized events, and the canvas drag pins
    /// then failed ~1 run in 3 STANDALONE — worse than the load-only flake
    /// it was meant to close. The mechanism: the card's own realization is
    /// recomputed while the drag is in flight (`realizedCards` keeps a card
    /// only while `dragOffsets[id] != .zero`, which is not yet true before
    /// the first `onChanged`), so a layout pass + suspension mid-sequence can
    /// tear the gesture's view down before it is recognized. The waiting
    /// belongs AFTER the sequence, where a retry can fix what a wait cannot.
    func sendDragSequence(from start: CGPoint, dx: CGFloat, dy: CGFloat, steps: Int) {
        // KEY FIRST, every attempt (13j batch 6 — the mechanism behind the
        // load-dependence). `NSHostingView.acceptsFirstMouse` is false, so a
        // mouse-down into an INACTIVE window is swallowed as the activating
        // click and never reaches the SwiftUI gesture. Suites run in
        // parallel in this target, and any other hosted test making ITS
        // window key takes key away from this panel mid-test — which is
        // exactly why these pins pass solo (6/6 measured) and fail
        // intermittently beside other suites. Re-asserting key costs
        // nothing: the panel is non-activating, so it never steals focus
        // from the machine's real front app.
        window.makeKeyAndOrderFront(nil)
        pump(0.02)
        send(.leftMouseDown, start)
        pump(0.05)
        for step in 1...steps {
            let fraction = CGFloat(step) / CGFloat(steps)
            send(.leftMouseDragged,
                 CGPoint(x: start.x + dx * fraction, y: start.y - dy * fraction))
            pump(0.03)
        }
    }
}

@Suite("Canvas drag tracking (13e E12)", .serialized)
@MainActor
struct CanvasDragTrackingTests {
    /// RED ON THE PRE-FIX CODE with the traced numbers: mid-drag (60,30)
    /// instead of (100,50) — the alternating stall she saw as jitter — and
    /// a landing at resting+(40,20) instead of resting+(100,50): the card
    /// stops 60pt short of the drop, which is the "resist".
    @Test func aCardFollowsThePointerOneToOneInsteadOfHalfOfIt() async throws {
        try await withCanvasWorld { session, db in
            let (poolID, blockID) = try await session.runner.run { ops -> (String, String) in
                let pool = try ops.createPool(title: "board")
                let block = try ops.newBlock(in: pool.id, text: "the one card", at: .end).block
                return (pool.id, block.id)
            }
            let rig = await CanvasDragRig.mount(session: session, containerID: poolID, cards: 1)
            defer { rig.close() }
            let resting = rig.model.restingPosition(blockID: blockID)
            let card = rig.cardOrigin(blockID: blockID)
            // The ⠿ grab header: the card's top strip, inside its padding.
            let header = try #require(rig.windowPoint(boardX: card.x + 120, boardY: card.y + 17))

            var midDrag: CGSize?
            await rig.drag(
                from: header, dx: 100, dy: 50,
                started: { rig.model.dragOffsets[blockID] != nil }
            ) {
                midDrag = rig.model.dragOffsets[blockID]
            }

            #expect(midDrag == CGSize(width: 100, height: 50),
                    "the card tracks the pointer 1:1 while dragging (pre-fix: 60,30)")
            let rows = try await db.read { db in
                try Row.fetchAll(db, sql: "SELECT x, y FROM canvas_layout WHERE deleted_at IS NULL")
            }
            #expect(rows.count == 1, "one drag, one layout row (the A7 pin)")
            let storedX: Double? = rows.first?["x"]
            let storedY: Double? = rows.first?["y"]
            #expect(storedX == Double(resting.x + 100))
            #expect(storedY == Double(resting.y + 50),
                    "the card LANDS where it was dropped — pre-fix it landed at +40,+20")
        }
    }

    /// The same class one gesture over: the grip sits at the card's
    /// bottom-right, so the size this drag applies MOVES the grip. Pre-fix
    /// a 60×40 pull grew the card by 36×24.
    @Test func theResizeGripFollowsThePointerToo() async throws {
        try await withCanvasWorld { session, db in
            let (poolID, blockID) = try await session.runner.run { ops -> (String, String) in
                let pool = try ops.createPool(title: "board")
                let block = try ops.newBlock(in: pool.id, text: "resize me", at: .end).block
                return (pool.id, block.id)
            }
            let rig = await CanvasDragRig.mount(session: session, containerID: poolID, cards: 1)
            defer { rig.close() }
            let card = rig.cardOrigin(blockID: blockID)
            let size = CanvasBoardGeometry.defaultCardSize
            let grip = try #require(rig.windowPoint(
                boardX: card.x + size.width - 7, boardY: card.y + size.height - 7))

            var midDrag: CGSize?
            await rig.drag(
                from: grip, dx: 60, dy: 40,
                started: { rig.model.resizeOffsets[blockID] != nil }
            ) {
                midDrag = rig.model.resizeOffsets[blockID]
            }

            #expect(midDrag == CGSize(width: 60, height: 40),
                    "the grip tracks the pointer 1:1 — pre-fix it reported (36,24)")
            #expect(rig.model.cardSize(blockID: blockID)
                    == CGSize(width: size.width + 60, height: size.height + 40),
                    "the card ends the size she pulled it to")
        }
    }
}
