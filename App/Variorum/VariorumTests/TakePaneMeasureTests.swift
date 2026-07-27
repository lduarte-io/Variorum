//
//  TakePaneMeasureTests.swift
//  VariorumTests
//
//  Batch 12 pin (her clipped-take report, Sitting 9): a READ take pane
//  holding multi-paragraph text ("hello\n\n\n\nhi there") rendered ONE
//  LINE tall — the pane measured once at install, before SwiftUI handed
//  it real width (a zero-width container lays out ~nothing and reports
//  ~one line), and no later event re-measured a read pane. The fix is
//  the width-gated layout hook. RED on the pre-fix code: the hosted pane
//  stays at the 24-pt floor; GREEN shipped: the first real layout
//  re-measures and the text view grows to hold every paragraph.
//

import AppKit
import Combine
import SwiftUI
import Testing
@testable import Variorum

/// Sync pump callable from async pins (`RunLoop.run(until:)` is barred in
/// async contexts; a sync hop is the suite-wide pattern).
@MainActor
private func pumpMain(_ seconds: TimeInterval = 0.03) {
    RunLoop.main.run(until: Date().addingTimeInterval(seconds))
}

@MainActor
struct TakePaneMeasureTests {
    private func pumpedPaneHeight(hosting rootView: some View) -> CGFloat {
        let host = NSHostingController(rootView: rootView)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 600),
            styleMask: [.borderless], backing: .buffered, defer: false)
        window.contentViewController = host
        host.view.layoutSubtreeIfNeeded()
        // Let the height publish (a @State write) round-trip through
        // SwiftUI's update cycle.
        for _ in 0..<4 {
            RunLoop.main.run(until: Date().addingTimeInterval(0.05))
            host.view.layoutSubtreeIfNeeded()
        }
        func findTakeView(_ view: NSView) -> PaneTextView? {
            if let take = view as? PaneTextView { return take }
            for sub in view.subviews {
                if let found = findTakeView(sub) { return found }
            }
            return nil
        }
        let height = findTakeView(host.view).map(\.bounds.height) ?? 0
        window.contentViewController = nil
        return height
    }

    private func pumpedPaneHeight(text: String) -> CGFloat {
        pumpedPaneHeight(
            hosting: PaneSurfaceView(text: text, isLive: false).frame(width: 400))
    }

    @Test func readPaneHoldsEveryParagraphOfItsTake() {
        let multi = pumpedPaneHeight(text: "hello\n\n\n\nhi there")
        let single = pumpedPaneHeight(text: "hello")
        // Five source lines must measure decisively taller than one — the
        // pre-fix code pinned BOTH near the 24-pt floor ("the text that's
        // underneath several newlines never even shows").
        #expect(multi > single + 40,
                "multi-paragraph read pane measured \(multi) vs single-line \(single)")
    }

    /// 13b Stage 3F pin (AD-7; red-on-old, behavioral-revert verified): the
    /// margin-grid wash SLAB. An NSViewRepresentable ACCEPTS a tall height
    /// proposal, and the pane's old `.frame(minHeight:)` never pushed back
    /// down — so in the grid row (whose rail reserves 2-high card room) the
    /// article pane STRETCHED to the row's height and the wash rendered as
    /// a ~2/3-empty grey slab under ~150px of text. The pane now frames at
    /// its EXACT measured height: the wash hugs the text, whatever the
    /// composition proposes.
    @Test func aTallRowNeverStretchesThePaneIntoASlab() {
        let height = pumpedPaneHeight(
            hosting: HStack(alignment: .top, spacing: 16) {
                PaneSurfaceView(text: "one honest line of prose", isLive: false)
                    .frame(width: 400)
                Color.clear.frame(width: 100, height: 430)
            })
        #expect(height < 120,
                "a one-line pane under a 430-tall row proposal hugs its text (measured \(height)) — never the slab")
    }

    /// 13c Batch 1F (A47, the take-card gap) — RED-ON-OLD by behavioral
    /// revert (remove the same-width divergence branch from
    /// `PaneTextView.layout()` / `reconvergeIfDiverged`).
    ///
    /// The class: a pane's frame is written only from exact measurements,
    /// but a measurement taken in a transient state outlives the state it
    /// measured — and on the pre-fix code an over-tall frame was TERMINAL:
    /// every remeasure trigger was gated on a width/string/font CHANGE, and
    /// `PanePublisher`'s heal re-schedules only while the frame renders
    /// SHORT of its measurement. Her A47 card: ~450pt of dead, un-clickable
    /// space at the end of a take, stable across ring moves and clicks, on
    /// text unchanged for three days.
    ///
    /// The paragraph-spacing swap below is a STAND-IN for the (unidentified,
    /// launch-adjacent) birth event — stated plainly: it reproduces the
    /// stale STATE (frame measured tall, text rendering short, no trigger
    /// left to fire), not the specific birth. The pin holds the LAW: a
    /// pane's frame must re-converge to its current measurement on the
    /// next layout pass, whichever way it diverged.
    @Test func aStaleTallPaneFrameReconvergesOnTheNextLayoutPass() async {
        // Twelve paragraphs: the spacing swap moves the extent by ~264pt —
        // decisively past the 3pt convergence slack.
        let text = (1...12).map { "paragraph number \($0) of honest prose" }
            .joined(separator: "\n")
        let host = NSHostingController(
            rootView: PaneSurfaceView(text: text, isLive: false))
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 900),
            styleMask: [.borderless], backing: .buffered, defer: false)
        window.contentViewController = host
        host.view.frame = NSRect(x: 0, y: 0, width: 400, height: 900)
        defer { window.contentViewController = nil }

        func settle() {
            for _ in 0..<4 {
                host.view.layoutSubtreeIfNeeded()
                RunLoop.main.run(until: Date().addingTimeInterval(0.05))
            }
        }
        func findPane(_ view: NSView) -> PaneTextView? {
            if let pane = view as? PaneTextView { return pane }
            for sub in view.subviews {
                if let found = findPane(sub) { return found }
            }
            return nil
        }
        settle()
        guard let pane = findPane(host.view) else {
            Issue.record("no pane mounted")
            return
        }
        let converged = pane.bounds.height
        #expect(abs(converged - PaneMeasurement.height(of: pane)) <= 3,
                "the mounted pane converges before the experiment")

        // Inflate the text's extent BEHIND the coordinator (paragraph gap
        // 8 → 30), then hand the pane a legitimate remeasure via a width
        // change: the frame grows to the inflated measurement — on old and
        // new code alike (the width hook predates the fix).
        let full = NSRange(location: 0, length: (pane.string as NSString).length)
        let wide = NSMutableParagraphStyle()
        wide.setParagraphStyle(EditorDocument.baseParagraphStyle)
        wide.paragraphSpacing = 30
        pane.textStorage?.beginEditing()
        pane.textStorage?.addAttributes([.paragraphStyle: wide], range: full)
        pane.textStorage?.endEditing()
        host.view.frame = NSRect(x: 0, y: 0, width: 420, height: 900)
        settle()
        let tall = pane.bounds.height
        #expect(tall > converged + 100, "the inflated measurement framed the pane tall (\(tall))")

        // The stale birth, reproduced: the extent shrinks back with NO
        // width/string/font event — the frame is now measured-tall over
        // short-rendering text, exactly her card.
        let narrow = NSMutableParagraphStyle()
        narrow.setParagraphStyle(EditorDocument.baseParagraphStyle)
        narrow.paragraphSpacing = EditorDocument.baseParagraphStyle.paragraphSpacing
        pane.textStorage?.beginEditing()
        pane.textStorage?.addAttributes([.paragraphStyle: narrow], range: full)
        pane.textStorage?.endEditing()

        // A same-width layout pass, DRIVEN BY HAND. (Corrected at 1G: the
        // original comment here claimed clicks/ring moves/scrolls deliver
        // this kind of pass — the 1G census proved they deliver NONE, which
        // is why her void survived the 1F build. This pin holds the LAW for
        // whenever a pass does arrive; the 1G pins below hold the
        // production TRIGGERS and the remedy's frame lever.)
        pane.needsLayout = true
        settle()

        let measured = PaneMeasurement.height(of: pane)
        #expect(abs(pane.bounds.height - measured) <= 3,
                "the frame re-converges to the current measurement on the next layout pass (frame \(pane.bounds.height) vs measured \(measured)) — on the pre-fix code it stays at \(tall) forever")
    }

    // MARK: - 13c Batch 1G (A47b): the void survived the 1F build

    /// Shared host for the 1G pins: a pane mounted inside a real SwiftUI
    /// ScrollView (so `enclosingScrollView` resolves, as it does under the
    /// real TakesBoardView — verified by the 1G census), converged, then
    /// corrupted into the state her card was in.
    @MainActor
    private struct StarvedPaneHost {
        let window: NSWindow
        let host: NSHostingController<AnyView>
        let pane: PaneTextView
        let converged: CGFloat

        static func mount() async -> StarvedPaneHost? {
            let text = (1...12).map { "paragraph number \($0) of honest prose" }
                .joined(separator: "\n")
            let host = NSHostingController(
                rootView: AnyView(ScrollView { PaneSurfaceView(text: text, isLive: false) }))
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 500),
                styleMask: [.borderless], backing: .buffered, defer: false)
            window.contentViewController = host
            host.view.frame = NSRect(x: 0, y: 0, width: 400, height: 500)
            func findPane(_ view: NSView) -> PaneTextView? {
                if let pane = view as? PaneTextView { return pane }
                for sub in view.subviews {
                    if let found = findPane(sub) { return found }
                }
                return nil
            }
            for _ in 0..<8 {
                host.view.layoutSubtreeIfNeeded()
                pumpMain()
                await Task.yield()
            }
            guard let pane = findPane(host.view) else { return nil }
            let converged = pane.bounds.height
            guard abs(converged - PaneMeasurement.height(of: pane)) <= 3 else { return nil }
            return StarvedPaneHost(
                window: window, host: host, pane: pane, converged: converged)
        }

        /// STAND-IN 1 (pin A — the frame side): the frame diverges while
        /// the height @State does NOT — the dropped-frame-application shape
        /// (SwiftUI dropped the re-frame; the state and the measurement
        /// agree; every re-publish of the same value is a no-op).
        /// Constructed by resizing the NSView directly. A labelled STAND-IN,
        /// as 1F's was: it reproduces the terminal STATE, not the (still
        /// unidentified) birth.
        func corruptFrameSide() {
            pane.setFrameSize(NSSize(width: pane.frame.width, height: converged + 250))
            swallowLayoutDirt()
        }

        /// Production's starved card owes no pass to anyone (the 1G
        /// census); dirt left by the corruption's own mechanics would
        /// deliver an incidental pass that heals via the 1F branch — a pin
        /// satisfied by the wrong wire (the R3-4 first-version trap, hit
        /// and fixed here twice).
        private func swallowLayoutDirt() {
            var view: NSView? = pane
            while let current = view {
                current.needsLayout = false
                view = current.superview
            }
        }

        func settle() async {
            for _ in 0..<6 {
                window.layoutIfNeeded()
                window.displayIfNeeded()
                pumpMain()
                await Task.yield()
            }
        }

        var healed: Bool {
            abs(pane.bounds.height - PaneMeasurement.height(of: pane)) <= 3
        }

        func dismantle() {
            window.contentViewController = nil
        }
    }

    /// 1G pin A — the REMEDY (red-on-old by behavioral revert: remove the
    /// publisher's `applyFrame` lever / the both-sided chase): when the
    /// frame diverges while the @State already holds the measured value,
    /// the pre-1G heal's only remedy was an equal-value @State write — a
    /// SwiftUI no-op — so the check FIRED (a hand-driven pass, as in the
    /// 1F pin) and healed NOTHING, forever. The lever pulls the AppKit
    /// frame itself on a divergent chase turn.
    @Test func aFrameTheStateCannotMoveIsHealedByTheFrameLever() async {
        guard let harness = await StarvedPaneHost.mount() else {
            Issue.record("the scroll-hosted pane did not mount converged")
            return
        }
        defer { harness.dismantle() }
        harness.corruptFrameSide()
        #expect(!harness.healed, "the corruption took (frame \(harness.pane.bounds.height))")
        // Drive ONE layout pass by hand (the 1F trigger, known to fire the
        // check): on pre-1G code the check runs, publishes the equal value,
        // SwiftUI ignores it, and the frame never moves.
        harness.pane.needsLayout = true
        await harness.settle()
        #expect(harness.healed,
                "the frame lever heals a divergence the state cannot move (frame \(harness.pane.bounds.height) vs measured \(PaneMeasurement.height(of: harness.pane)))")
    }

    /// 1G pin B — the TRIGGER WIRES (red-on-old by behavioral revert:
    /// remove the occasion wires): production delivers NO layout passes to
    /// an idle card (the 1G census: counters frozen through idle, clicks,
    /// scrolls), so the 1F branch alone never ran in the shipped app —
    /// R3-4's class one layer up. This pin takes R3-4's final MECHANICAL
    /// form deliberately: it asserts the wire fires and the check runs
    /// (both counters, synchronously — no settle between drive and
    /// assert), because every heal-shaped construction we tried was
    /// eventually satisfied by incidental harness machinery (SwiftUI
    /// geometry observation; TK2's deferred invalidation) — the R3-4
    /// first-version trap, hit twice and recorded in the 1G record. The
    /// heal CAPABILITY is pin A's (red-verified against the lever revert);
    /// this pin owns the wires: scroll-end on the ENCLOSING scroll view
    /// (the production registration) and a click on the pane.
    @Test func productionOccasionsRunTheDivergenceCheck() async {
        guard let harness = await StarvedPaneHost.mount() else {
            Issue.record("the scroll-hosted pane did not mount converged")
            return
        }
        defer { harness.dismantle() }
        guard let scrollView = harness.pane.enclosingScrollView else {
            Issue.record("no enclosing scroll view — the occasion wire has no host")
            return
        }

        // Occasion 1 — scroll end (the notification IS the production
        // wire; posting it drives the registered observer synchronously).
        let checksBeforeScroll = harness.pane.convergenceChecksRun
        NotificationCenter.default.post(
            name: NSScrollView.didEndLiveScrollNotification, object: scrollView)
        #expect(harness.pane.convergenceChecksRun > checksBeforeScroll,
                "scroll-end ran the divergence check (checks \(harness.pane.convergenceChecksRun))")

        // Occasion 2 — a click on the pane (post the up first so the
        // tracking loop returns; the occasion fires as mouseDown unwinds).
        let checksBeforeClick = harness.pane.convergenceChecksRun
        let mid = harness.pane.convert(NSPoint(x: 20, y: 20), to: nil)
        func mouse(_ type: NSEvent.EventType) -> NSEvent? {
            NSEvent.mouseEvent(
                with: type, location: mid, modifierFlags: [],
                timestamp: ProcessInfo.processInfo.systemUptime,
                windowNumber: harness.window.windowNumber, context: nil,
                eventNumber: 1, clickCount: 1, pressure: 1)
        }
        if let down = mouse(.leftMouseDown), let up = mouse(.leftMouseUp) {
            // Drive the production override directly: the wire under test
            // is PaneTextView.mouseDown's occasion, not AppKit hit-testing
            // (window.sendEvent hit-tests unreliably in an unordered hosted
            // window). The up is queued first so the tracking loop returns.
            harness.window.postEvent(up, atStart: false)
            harness.pane.mouseDown(with: down)
        }
        #expect(harness.pane.convergenceChecksRun > checksBeforeClick,
                "a click ran the divergence check (checks \(harness.pane.convergenceChecksRun))")

        // A converged pane's checks publish nothing (the termination
        // argument's silent side, observed): the frame still equals the
        // measurement after both occasions.
        #expect(harness.healed, "occasions on a converged pane stay silent")
    }

    /// 1G pin C — the LIVENESS occasion: the ring migrating onto (or off)
    /// a pane runs the check — her card's one reliable event was exactly
    /// "clicking into other blocks". Same mechanical form as pin B; the
    /// occasion counter carries the red (a SwiftUI settle can deliver
    /// incidental layout passes that bump the CHECK counter on any code).
    @Test func aLivenessTransitionRunsTheDivergenceCheck() async {
        let text = (1...12).map { "paragraph number \($0) of honest prose" }
            .joined(separator: "\n")
        final class FlipModel: ObservableObject { @Published var live = false }
        struct FlipHost: View {
            let text: String
            @ObservedObject var model: FlipModel
            var body: some View {
                ScrollView { PaneSurfaceView(text: text, isLive: model.live) }
            }
        }
        let flip = FlipModel()
        let host = NSHostingController(
            rootView: FlipHost(text: text, model: flip))
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 500),
            styleMask: [.borderless], backing: .buffered, defer: false)
        window.contentViewController = host
        host.view.frame = NSRect(x: 0, y: 0, width: 400, height: 500)
        defer { window.contentViewController = nil }
        func findPane(_ view: NSView) -> PaneTextView? {
            if let pane = view as? PaneTextView { return pane }
            for sub in view.subviews {
                if let found = findPane(sub) { return found }
            }
            return nil
        }
        func settle() async {
            for _ in 0..<6 {
                window.layoutIfNeeded()
                window.displayIfNeeded()
                pumpMain()
                await Task.yield()
            }
        }
        await settle()
        guard let pane = findPane(host.view) else {
            Issue.record("no pane mounted")
            return
        }
        let occasionsBefore = pane.occasionsFired
        // The ring arrives (a real SwiftUI liveness flip → updateNSView →
        // noteLiveness transition → the occasion) — an IN-PLACE update on
        // the same mounted pane.
        flip.live = true
        await settle()
        #expect(pane.occasionsFired > occasionsBefore,
                "the liveness WIRE fired (occasions \(pane.occasionsFired))")
        #expect(abs(pane.bounds.height - PaneMeasurement.height(of: pane)) <= 3,
                "the pane stays converged through the transition")
    }
}
