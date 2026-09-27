//
//  PanePublishShapeTests.swift
//  VariorumTests
//
//  18l-b U3 — `PanePublisher` adopts the author's RATIFIED shape (the health
//  review §5.1 A1; her sentence, verbatim: *"attempt the frame-synchronous /
//  state-deferred shape, walk the boards under load, and revert on any felt
//  regression"*): a publish answers the pane's VISIBLE height at once through
//  AppKit's own frame (the lever — the path SwiftUI does not flag), and the
//  SwiftUI STATE write waits for the next main-queue turn, where a write is
//  never inside a view update. The convergence loop, its budget, the
//  coalescing and `invalidate` stay as the net.
//
//  The red-on-old arm is the MECHANISM 18k UNIT C3 measured (M1: SwiftUI
//  flags exactly one write shape in this app — a `@State` written through a
//  `@Binding` while a representable's `makeNSView`/`updateNSView` body runs;
//  M2: every flagged line in the app sat inside THIS pane's two bodies). The
//  pane counts its height state writes, and counts again the ones that land
//  inside that bracket (`PaneTextView.noteStateWrite`) — per VIEW, so a suite
//  running beside this one cannot touch the number.
//

import AppKit
import SwiftUI
import Testing
@testable import Variorum

/// A pane whose TEXT a pin can move after the mount — the projection change a
/// read pane adopts through `updateNSView` (its adopt-remeasure road).
/// File-scope: the `@Observable` macro cannot expand on a `private` nested type.
@MainActor @Observable
fileprivate final class PaneTextBox {
    var text: String
    init(_ text: String) { self.text = text }
}

fileprivate struct PaneTextBoxHost: View {
    let box: PaneTextBox
    var body: some View {
        PaneSurfaceView(text: box.text, isLive: false)
            .frame(width: 400)
    }
}

@MainActor
@Suite("Pane publish shape — the frame now, the state next turn (18l-b U3)", .serialized)
struct PanePublishShapeTests {
    /// A hand-drained main queue (`PanePublishDoorTests`' own shape).
    private final class ManualScheduler {
        private var work: [() -> Void] = []
        var pending: Int { work.count }
        func schedule(_ item: @escaping () -> Void) { work.append(item) }
        /// Runs exactly the turns queued when the drain began.
        @discardableResult func drainOneTurn() -> Int {
            let batch = work
            work = []
            batch.forEach { $0() }
            return batch.count
        }
    }

    // MARK: - The contract, through the injectable scheduler

    /// THE SHAPE, stated: the frame answers in the same pass, the state
    /// write waits one turn and lands there, and a converged pane then
    /// schedules nothing. RED on the pre-U3 publisher: it wrote the state
    /// synchronously (`[46]` before any turn) and pulled no lever.
    @Test func aPublishAnswersTheFrameNowAndWritesTheStateOnTheNextTurn() {
        let scheduler = ManualScheduler()
        var frames: [CGFloat] = []
        var heights: [CGFloat] = []
        let publisher = PanePublisher(
            measure: { 46 },
            renderedHeight: { frames.last ?? 24 },  // the pane renders what the lever set
            applyFrame: { frames.append($0) },
            writeHeight: { heights.append($0) },
            writeCanary: { _ in },
            schedule: { scheduler.schedule($0) })

        publisher.publishHeight()
        #expect(frames == [46],
                "the VISIBLE height answers in the same pass, through AppKit's own frame (frames \(frames))")
        #expect(heights.isEmpty,
                "…and NO state is written synchronously — the flagged shape whenever the publish runs inside a SwiftUI update (heights \(heights))")
        #expect(scheduler.pending == 1, "the state write waits for ONE deferred turn")

        scheduler.drainOneTurn()
        #expect(heights == [46], "the state lands on the drained turn (heights \(heights))")
        #expect(frames == [46], "the frame had already answered — no second lever pull (frames \(frames))")
        #expect(scheduler.pending == 0, "converged: nothing further is scheduled")
    }

    /// A burst in one pass (the width hook, then the adopt-remeasure, then a
    /// keystroke's remeasure) answers the frame at EACH measure and writes the
    /// state ONCE, with the NEWEST measure — the deferred turn re-measures, so
    /// a stale first number can never reach SwiftUI. RED on the pre-U3
    /// publisher: two synchronous writes, the stale one first.
    @Test func aBurstInOnePassWritesTheNewestMeasureOnce() {
        let scheduler = ManualScheduler()
        var measured: CGFloat = 46
        var frames: [CGFloat] = []
        var heights: [CGFloat] = []
        let publisher = PanePublisher(
            measure: { measured },
            renderedHeight: { frames.last ?? 24 },
            applyFrame: { frames.append($0) },
            writeHeight: { heights.append($0) },
            writeCanary: { _ in },
            schedule: { scheduler.schedule($0) })

        publisher.publishHeight()
        measured = 60
        publisher.publishHeight()
        #expect(frames == [46, 60], "each measure answers the frame in its own pass (frames \(frames))")
        #expect(heights.isEmpty, "no state written inside the burst (heights \(heights))")
        #expect(scheduler.pending == 1, "the burst coalesces into ONE deferred turn")

        scheduler.drainOneTurn()
        #expect(heights == [60], "one state write, the NEWEST measure (heights \(heights))")
        #expect(scheduler.pending == 0)
    }

    /// The net, kept: a frame that does not take (a composition re-imposing
    /// the old height, SwiftUI's own layout between the pass and the turn) is
    /// chased with the lever on every heal turn, and the BUDGET still bounds
    /// the chase — the state written once per healed turn, none synchronously.
    /// RED on the pre-U3 publisher: one synchronous write too many and one
    /// lever pull too few.
    @Test func theHealStillChasesAFrameThatDoesNotTakeAndStopsAtTheBudget() {
        let scheduler = ManualScheduler()
        var frames: [CGFloat] = []
        var heights: [CGFloat] = []
        let publisher = PanePublisher(
            measure: { 46 },
            renderedHeight: { 29 },  // the frame never takes
            applyFrame: { frames.append($0) },
            writeHeight: { heights.append($0) },
            writeCanary: { _ in },
            schedule: { scheduler.schedule($0) })

        publisher.publishHeight()
        var turns = 0
        while scheduler.pending > 0, turns < PanePublisher.healTurnBudget + 5 {
            scheduler.drainOneTurn()
            turns += 1
        }
        #expect(turns == PanePublisher.healTurnBudget, "the heal ran the whole budget and no further")
        #expect(heights.count == PanePublisher.healTurnBudget,
                "one state write per healed turn and none synchronous (\(heights.count))")
        #expect(frames.count == PanePublisher.healTurnBudget,
                "the synchronous answer + one lever pull on every turn that re-schedules (\(frames.count))")
        #expect(scheduler.pending == 0, "the bound holds — no perpetual turn")
    }

    // MARK: - The mechanism, on a real mount (the flagged shape, counted)

    private func pump(_ turns: Int = 4) {
        for _ in 0..<turns {
            RunLoop.main.run(until: Date().addingTimeInterval(0.04))
        }
    }

    private func findPane(_ view: NSView) -> PaneTextView? {
        if let pane = view as? PaneTextView { return pane }
        for sub in view.subviews {
            if let found = findPane(sub) { return found }
        }
        return nil
    }

    private func paragraphs(_ count: Int) -> String {
        (1...count).map { "Paragraph \($0) of an honest take that wraps across the measure more than once." }
            .joined(separator: "\n\n")
    }

    /// **The red-on-old pin, at the mechanism 18k C3 measured.** A pane's
    /// MOUNT (`makeNSView` measures and publishes) and a SwiftUI update that
    /// hands a read pane new text (`updateNSView`'s adopt-remeasure) both
    /// publish from INSIDE the representable's body — the one shape SwiftUI
    /// flags. On the pre-U3 publisher each of them wrote the `@State` right
    /// there (the mount alone, every time); on the ratified shape the state is
    /// written only on a later turn, outside any update, and the pane still
    /// converges to its measure — the frame, and the SwiftUI slot the state
    /// drives.
    @Test func aMountAndAnAdoptedTextWriteNoStateInsideTheRepresentablesBody() async throws {
        let box = PaneTextBox(paragraphs(6))
        let host = NSHostingController(rootView: PaneTextBoxHost(box: box))
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 900),
            styleMask: [.borderless], backing: .buffered, defer: false)
        window.contentViewController = host
        defer { window.contentViewController = nil }
        host.view.layoutSubtreeIfNeeded()
        pump(6)
        host.view.layoutSubtreeIfNeeded()

        let pane = try #require(findPane(host.view))
        #expect(pane.stateWrites > 0, "non-vacuity: the mount's height state was written (\(pane.stateWrites))")
        #expect(pane.stateWritesInsideUpdate == 0,
                "the MOUNT wrote no state inside makeNSView/updateNSView — \(pane.stateWritesInsideUpdate) of \(pane.stateWrites) did")
        let measured = max(PaneMeasurement.height(of: pane), 24)
        #expect(abs(pane.bounds.height - measured) < 2,
                "settled at mount: the pane renders its measure (\(pane.bounds.height) vs \(measured))")

        // The adopt-remeasure road: new text through a SwiftUI update.
        let writesBefore = pane.stateWrites
        box.text = paragraphs(24)
        pump(6)
        host.view.layoutSubtreeIfNeeded()
        pump(4)
        let grown = max(PaneMeasurement.height(of: pane), 24)
        #expect(grown > measured + 100, "non-vacuity: the adopted text really grew (\(measured) → \(grown))")
        #expect(pane.stateWrites > writesBefore, "non-vacuity: the adopted text re-published its height")
        #expect(pane.stateWritesInsideUpdate == 0,
                "the UPDATE pass's re-publish wrote no state inside the update — \(pane.stateWritesInsideUpdate) of \(pane.stateWrites) did")
        #expect(abs(pane.bounds.height - grown) < 2,
                "the pane converged to the new measure (\(pane.bounds.height) vs \(grown))")
        #expect(abs(host.view.fittingSize.height - grown) < 2,
                "…and so did the SwiftUI slot its state drives — the state landed (\(host.view.fittingSize.height) vs \(grown))")
    }
}
