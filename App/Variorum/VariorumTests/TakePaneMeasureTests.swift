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

// MARK: - 13c A47c (the draw gap): the render tier

import CoreGraphics
import Dependencies
import VariorumCore

extension TakePaneMeasureTests {
    /// Compact pixel truth for the render-tier pins: composite the
    /// window's CURRENT layer contents (CALayer.render(in:) uses existing
    /// backing stores/surfaces — a destroyed rendering surface shows as
    /// blank; nothing is force-redrawn), then report, band by band, where
    /// ink exists inside the pane's visible rect.
    @MainActor
    private func inkBands(of pane: NSView, in window: NSWindow, bands: Int) -> [Bool]? {
        guard let contentView = window.contentView, let layer = contentView.layer else { return nil }
        let scale = window.backingScaleFactor
        let width = Int(contentView.frame.width * scale)
        let height = Int(contentView.frame.height * scale)
        guard width > 0, height > 0,
              let ctx = CGContext(
                data: nil, width: width, height: height,
                bitsPerComponent: 8, bytesPerRow: 0,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
        else { return nil }
        ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
        ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))
        ctx.scaleBy(x: scale, y: scale)
        ctx.translateBy(x: 0, y: contentView.frame.height)
        ctx.scaleBy(x: 1, y: -1)
        layer.render(in: ctx)
        guard let image = ctx.makeImage(),
              let data = image.dataProvider?.data as Data? else { return nil }
        let rectInWindow = pane.convert(pane.visibleRect, to: nil)
        guard rectInWindow.width > 0, rectInWindow.height > 0 else { return nil }
        let scaleX = CGFloat(image.width) / contentView.frame.width
        let scaleY = CGFloat(image.height) / contentView.frame.height
        let x0 = max(0, Int(rectInWindow.minX * scaleX))
        let x1 = min(image.width, Int(rectInWindow.maxX * scaleX))
        let yTop = contentView.frame.height - rectInWindow.maxY
        let y0 = max(0, Int(yTop * scaleY))
        let y1 = min(image.height, Int((yTop + rectInWindow.height) * scaleY))
        guard x1 > x0, y1 > y0 else { return nil }
        let bpr = image.bytesPerRow
        let bpp = image.bitsPerPixel / 8
        var result: [Bool] = []
        let bandHeight = max(1, (y1 - y0) / bands)
        for band in 0..<bands {
            let by0 = y0 + band * bandHeight
            let by1 = min(by0 + bandHeight, y1)
            var dark = false
            for y in stride(from: by0, to: by1, by: 2) where !dark {
                for x in stride(from: x0, to: x1, by: 2) {
                    let offset = y * bpr + x * bpp
                    guard offset + 3 < data.count else { continue }
                    if data[offset + 1] < 128, data[offset + 2] < 128, data[offset + 3] < 128 {
                        dark = true
                        break
                    }
                }
            }
            result.append(dark)
        }
        return result
    }

    /// 13c A47c pin A — RED-ON-OLD by behavioral revert (remove the
    /// render half from `reconvergeIfDiverged` — the
    /// `scheduleRenderRestore()` call): a convergence occasion must
    /// re-assert BOTH authorities, geometry AND drawnness.
    ///
    /// The class (traced in the A47c session, real mounted board): TK2
    /// draws a pane through per-fragment RENDERING SURFACES created by
    /// viewport layout. A full-range storage attribute write on a
    /// tail-scrolled long pane (production trigger: the pre-A47c
    /// unguarded `textColor` write on every updateNSView) DESTROYS the
    /// surfaces above the pane's tail and nothing rebuilds them —
    /// viewportBounds stays CORRECT, `needsDisplay` is powerless (the
    /// surfaces are the unit of drawing), idle delivers nothing. Text
    /// that is laid out, measured exact, and selectable renders BLANK
    /// except its last lines, permanently — her four A47c screenshots,
    /// and the state behind 1G's deletion deception.
    ///
    /// The pin drives the REAL trigger (a same-value textColor write —
    /// deliberately NOT through applyStyle, whose change-gate is pin B's
    /// subject) on the REAL mounted TakesBoardView, asserts the strand
    /// (top-of-viewport bands blank while the measurement stays exact —
    /// laid-out-but-undrawn, both halves), then fires the occasion wire
    /// and asserts the deferred viewport re-layout rebuilt the drawing
    /// (ink back + the restore counter — the R3-4 mechanical form).
    ///
    /// If a macOS update ever fixes the underlying TK2 cull, the STRAND
    /// assertion fails first — that is TEXTKIT2 §5's re-verify posture
    /// working: re-run the A47c experiments and retire the mechanism
    /// deliberately, never silently.
    @Test func aStrandedRenderTierIsRebuiltByAConvergenceOccasion() async throws {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 47))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let longText = (1...28).map { i in
                "Paragraph \(i). " + Array(
                    repeating: "honest prose words keep flowing along the measured line and wrap",
                    count: 4
                ).joined(separator: " ") + "."
            }.joined(separator: "\n\n")
            let (postID, longVariantID): (String, String) = try {
                let post = try session.operations.createPost(title: "a47c pin A")
                let long = try session.operations.newBlock(in: post.id, text: longText)
                _ = try session.operations.newBlock(
                    in: post.id, text: "a short neighbor block of one line")
                return (post.id, long.variant.id)
            }()

            let model = TakesViewModel(session: session, postID: postID)
            let observing = Task { await model.start() }
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 900, height: 760),
                styleMask: [.borderless], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                observing.cancel()
                model.teardown()
                window.orderOut(nil)
            }
            let hosting = NSHostingView(
                rootView: TakesBoardView(session: session, postID: postID, model: model))
            hosting.frame = NSRect(x: 0, y: 0, width: 900, height: 760)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            for _ in 0..<40 where model.projection.slots.isEmpty {
                pumpMain(0.05)
                await Task.yield()
            }
            for _ in 0..<8 {
                window.layoutIfNeeded(); window.displayIfNeeded(); pumpMain(); await Task.yield()
            }
            func findPane(_ view: NSView) -> PaneTextView? {
                if let pane = view as? PaneTextView,
                   pane.identifier?.rawValue.contains(longVariantID) == true { return pane }
                for sub in view.subviews {
                    if let found = findPane(sub) { return found }
                }
                return nil
            }
            guard let long = findPane(hosting) else {
                Issue.record("the long pane did not mount")
                return
            }
            @MainActor func turns(_ n: Int) async {
                for _ in 0..<n { pumpMain(0.05); await Task.yield() }
            }
            // Deterministic tail scroll (verified; the board's own scroll
            // restoration can eat an early attempt).
            let paneH = long.frame.height
            var attempts = 0
            while long.visibleRect.minY < paneH - 800, attempts < 8 {
                attempts += 1
                _ = long.scrollToVisible(NSRect(x: 0, y: paneH - 600, width: 10, height: 600))
                await turns(3)
                window.layoutIfNeeded(); window.displayIfNeeded()
                pumpMain()
            }
            guard long.visibleRect.minY > paneH - 800 else {
                Issue.record("could not scroll the long pane to its tail after \(attempts) attempts")
                return
            }
            await turns(4)

            let bands = 12
            guard let baseline = inkBands(of: long, in: window, bands: bands) else {
                Issue.record("pixel capture unavailable")
                return
            }
            let topHalf = bands / 2
            #expect(baseline.prefix(topHalf).filter { $0 }.count >= topHalf - 1,
                    "the construction is meaningful: the visible tail region is DRAWN at baseline (\(baseline))")

            // THE KILL — the traced class trigger, driven directly.
            long.textColor = long.textColor ?? .labelColor
            await turns(6)
            guard let stranded = inkBands(of: long, in: window, bands: bands) else {
                Issue.record("pixel capture unavailable after the kill")
                return
            }
            let measured = PaneMeasurement.height(of: long)
            #expect(abs(long.bounds.height - measured) <= 3,
                    "the strand is laid-out-but-UNDRAWN: geometry stays exact (frame \(long.bounds.height) vs measured \(measured))")
            // 13e KICKOFF-SWEEP DISPOSITION (2026-08-18; amended the same
            // night by full-suite evidence) — the re-run this pin's own
            // message directed is DONE, and the answer dissolves the whole
            // "environment-gated" mystery: the cull is LOAD/TIMING-
            // DEPENDENT on this OS. Standalone suite runs leave ALL bands
            // inked after the kill (8+ runs, both lock states); FULL-suite
            // runs still strand — fully in the 13g/13k era, PARTIALLY
            // tonight (1-of-6 top bands inked). The covariate was never
            // lock state; it was suite context. Three kill outcomes are
            // therefore all real on this one OS (none · partial · full),
            // so the pin asserts NO particular kill outcome. The CONTRACT
            // is the two arms below, unconditional in every world: the
            // occasion's mechanical restore RUNS (`renderRestoresRun` —
            // red on the pre-A47c revert regardless of world), and the
            // page ends DRAWN (red whenever a strand of ANY depth goes
            // unhealed). The guard machinery stays byte-unchanged: it is
            // exactly what turns each of these worlds into a drawn page.

            // THE OCCASION — the funnel wire, exactly what a click /
            // scroll-end / ring move fires in production.
            let restoresBefore = long.renderRestoresRun
            let occasionsBefore = long.occasionsFired
            long.fireConvergenceOccasion()
            await turns(6)
            #expect(long.occasionsFired > occasionsBefore, "the wire fired")
            #expect(long.renderRestoresRun > restoresBefore,
                    "the deferred render restore RAN (restores \(long.renderRestoresRun)) — the mechanical half; on pre-A47c code the occasion measures geometry and never touches the render tier")
            guard let healed = inkBands(of: long, in: window, bands: bands) else {
                Issue.record("pixel capture unavailable after the occasion")
                return
            }
            #expect(healed.prefix(topHalf).filter { $0 }.count >= topHalf - 1,
                    "the occasion rebuilt the drawing: the upper visible bands hold ink again (\(healed))")
        }
    }

    /// 13c A47c pin B — RED-ON-OLD by behavioral revert (remove the
    /// change-gate from `applyStyle`): an updateNSView pass whose ink is
    /// UNCHANGED must not write the storage at all. The unguarded
    /// `textColor` write was the draw gap's production trigger — a
    /// full-range attribute edit on EVERY SwiftUI update of every tokened
    /// pane (every click, every ring move), each one a fresh chance to
    /// strand a tail-scrolled long pane's render tier.
    ///
    /// Mechanical form, R3-4's lesson applied to this pin's own first
    /// version (which drove a sibling-state tick that SwiftUI's
    /// fine-grained invalidation never delivered to the pane — green on
    /// the unguarded code, i.e. hollow): the update is driven through a
    /// LIVENESS FLIP, and `occasionsFired` growing is the proof the
    /// update actually reached updateNSView; the storage-edit count is
    /// the subject.
    @Test func anUnchangedInkUpdateNeverRewritesTheStorage() async {
        final class Flip: ObservableObject { @Published var live = false }
        struct Host: View {
            let text: String
            let tokens: VoiceTokens
            @ObservedObject var flip: Flip
            var body: some View {
                PaneSurfaceView(
                    text: text, isLive: flip.live, tokens: tokens,
                    role: "article", variantID: "pinB")
                    .frame(width: 400)
            }
        }
        let flip = Flip()
        let tokens = VoiceTokens.resolve(voice: .terminal, dark: false)
        let host = NSHostingController(
            rootView: Host(
                text: "paragraph one of honest prose\n\nparagraph two keeps flowing",
                tokens: tokens, flip: flip))
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 500),
            styleMask: [.borderless], backing: .buffered, defer: false)
        window.contentViewController = host
        host.view.frame = NSRect(x: 0, y: 0, width: 420, height: 500)
        defer { window.contentViewController = nil }
        func findPane(_ view: NSView) -> PaneTextView? {
            if let pane = view as? PaneTextView { return pane }
            for sub in view.subviews {
                if let found = findPane(sub) { return found }
            }
            return nil
        }
        for _ in 0..<6 {
            host.view.layoutSubtreeIfNeeded()
            pumpMain()
            await Task.yield()
        }
        guard let pane = findPane(host.view), let storage = pane.textStorage else {
            Issue.record("no pane mounted")
            return
        }
        #expect(pane.textColor != nil, "the FIRST styling applied the ink")

        let edits = LockIsolated(0)
        let observer = NotificationCenter.default.addObserver(
            forName: NSTextStorage.didProcessEditingNotification,
            object: storage, queue: nil) { _ in
            edits.withValue { $0 += 1 }
        }
        defer { NotificationCenter.default.removeObserver(observer) }

        // Drive updates that PROVABLY reach updateNSView: liveness flips
        // (each transition bumps occasionsFired — the non-vacuity proof).
        let occasionsBefore = pane.occasionsFired
        for _ in 0..<3 {
            flip.live.toggle()
            for _ in 0..<2 {
                host.view.layoutSubtreeIfNeeded()
                pumpMain()
                await Task.yield()
            }
        }
        #expect(pane.occasionsFired > occasionsBefore,
                "the updates actually reached updateNSView (occasions \(pane.occasionsFired))")
        #expect(edits.value == 0,
                "same-ink updateNSView passes made ZERO storage edits (counted \(edits.value)) — on pre-A47c code every pass re-attributed the whole storage through the textColor setter")
    }

    // MARK: - 17o batch c, ledger row 16 — the stale height after a big deletion

    /// Her punchlist 13, verbatim: *"delete a lot of text from a take…
    /// empty gap… until you switch modes"*.
    ///
    /// **The traced mechanism, measured before it was believed** (the
    /// standing-17 rule; the probe's numbers are in the batch record):
    /// `NSTextLayoutManager.usageBoundsForTextContainer` is a HIGH-WATER
    /// MARK for its container's life on macOS 26. A 30-line pane measured
    /// 1223 pt; deleting 25 of those lines through the real responder path
    /// left the property at 1189 and it stayed there for six main-queue
    /// turns — so the five-line take kept a 1201-pt frame with ~1000 pt of
    /// dead gap under it until a remount minted a fresh container, which is
    /// exactly "until you switch modes". Neither the `ensureLayout(for:
    /// documentRange)` the measurement already ran nor an explicit
    /// `invalidateLayout` ahead of it moves the property (both measured).
    ///
    /// RED ON THE PRE-FIX TREE: the pane's frame stands at 1201 for five
    /// lines of prose. GREEN with `PaneMeasurement` reading the laid-out
    /// fragments' own bottom, which tracks the text both ways (198 after
    /// the deletion, 608 after ten lines were typed back).
    ///
    /// Driven through the real edit path — select, `deleteBackward` — so
    /// this is a pin on her experience, not on our arithmetic.
    @Test func aPaneThatLosesMostOfItsTextShrinksWithinOneTurn() {
        let lines = (1...30).map {
            "Line \($0) of honest prose that keeps flowing along the measured line and wraps."
        }
        let host = NSHostingController(
            rootView: PaneSurfaceView(text: lines.joined(separator: "\n"), isLive: true)
                .frame(width: 400))
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 1400),
            styleMask: [.borderless], backing: .buffered, defer: false)
        window.contentViewController = host
        host.view.frame = NSRect(x: 0, y: 0, width: 420, height: 1400)
        defer { window.contentViewController = nil }
        func findPane(_ view: NSView) -> PaneTextView? {
            if let pane = view as? PaneTextView { return pane }
            for sub in view.subviews { if let found = findPane(sub) { return found } }
            return nil
        }
        for _ in 0..<6 { host.view.layoutSubtreeIfNeeded(); pumpMain(0.04) }
        guard let pane = findPane(host.view) else {
            Issue.record("no pane mounted")
            return
        }
        let tall = pane.bounds.height
        #expect(tall > 900, "non-vacuity: thirty lines really are tall (\(tall))")

        // The real gesture: select everything after line 5 and delete it.
        let keepLength = (lines.prefix(5).joined(separator: "\n") as NSString).length
        let whole = (pane.string as NSString).length
        pane.setSelectedRange(NSRange(location: keepLength, length: whole - keepLength))
        pane.deleteBackward(nil)
        #expect(pane.string.components(separatedBy: "\n").count == 5,
                "non-vacuity: the deletion landed (\(pane.string.components(separatedBy: "\n").count) lines)")

        // ONE main-queue turn — her words are "until you switch modes",
        // so the pane owes her the shrink without one.
        pumpMain(0.05)
        host.view.layoutSubtreeIfNeeded()
        let short = pane.bounds.height
        #expect(short < tall / 3,
                "five lines of prose frame short (\(short)) instead of keeping the thirty-line height (\(tall)) — the empty gap")

        // And BACK: the height is not a one-way ratchet in the other
        // direction either (the property it replaced was).
        pane.setSelectedRange(NSRange(location: (pane.string as NSString).length, length: 0))
        pane.insertText(
            "\n" + lines.suffix(10).joined(separator: "\n"),
            replacementRange: pane.selectedRange())
        pumpMain(0.05)
        host.view.layoutSubtreeIfNeeded()
        #expect(pane.bounds.height > short + 200,
                "fifteen lines stand taller than five (\(pane.bounds.height) vs \(short))")
    }


    /// **17o c/d/e ladder, MAJOR-1 — the DECIDING pin (J30: pin-decides, run
    /// before the brain is touched).** Row 16's fix left `extent(of:)`
    /// falling back to `usageBoundsForTextContainer` whenever the fragment
    /// enumeration yields nothing — and that property is the very
    /// high-water mark the fix exists to escape. The reviewer's traced
    /// consequence: a take emptied COMPLETELY (select the rest, delete)
    /// would lay out zero fragments, take the fallback, and JUMP BACK to
    /// the container's tallest-ever height — her punchlist 13 at its
    /// endpoint, inside the row reported fixed.
    ///
    /// The one link neither the record nor the review could settle without
    /// running it: whether an EMPTIED TK2 container really enumerates zero
    /// fragments (the record measured only the BORN-empty case). This pin
    /// decided it, and the verdict is worth keeping here because it is
    /// counter-intuitive.
    ///
    /// **MEASURED (17o c/d/e round 1): the finding is HOLLOW, and its two
    /// links split.** Link one is TRUE — an emptied container enumerates
    /// **zero** fragments, so the fallback really is the road taken. Link
    /// two is FALSE — at that moment `usageBoundsForTextContainer` reads
    /// **22.0**, not the container's tallest-ever **1564.0**: the property
    /// is a high-water mark only while the document still holds text (the
    /// 1223 → 1189 measurement row 16 was built on), and it resets when the
    /// document becomes EMPTY. So the emptied pane framed at **34.0**,
    /// exactly a fresh empty pane's 34.0, with no jump at all. The pin was
    /// green when written and stays as a standing guard on the endpoint of
    /// her gesture: the fallback is reachable ONLY for an empty document
    /// (any content yields at least one fragment under `.ensuresLayout`),
    /// and this is the pin that would catch it if that ever stopped being
    /// honest.
    @Test func aPaneEmptiedCompletelyDoesNotJumpBackToItsTallestHeight() throws {
        // The reference: what a pane holding no text at all stands at.
        let freshEmpty = pumpedPaneHeight(text: "")

        let lines = (1...30).map {
            "Line \($0) of honest prose that keeps flowing along the measured line and wraps."
        }
        let host = NSHostingController(
            rootView: PaneSurfaceView(text: lines.joined(separator: "\n"), isLive: true)
                .frame(width: 400))
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 1400),
            styleMask: [.borderless], backing: .buffered, defer: false)
        window.contentViewController = host
        host.view.frame = NSRect(x: 0, y: 0, width: 420, height: 1400)
        defer { window.contentViewController = nil }
        func findPane(_ view: NSView) -> PaneTextView? {
            if let pane = view as? PaneTextView { return pane }
            for sub in view.subviews { if let found = findPane(sub) { return found } }
            return nil
        }
        for _ in 0..<6 { host.view.layoutSubtreeIfNeeded(); pumpMain(0.04) }
        let pane = try #require(findPane(host.view))
        let tall = pane.bounds.height
        #expect(tall > 900, "non-vacuity: thirty lines really are tall (\(tall))")

        // The gesture at its endpoint: the WHOLE take goes.
        pane.setSelectedRange(NSRange(location: 0, length: (pane.string as NSString).length))
        pane.deleteBackward(nil)
        #expect(pane.string.isEmpty, "non-vacuity: the take really is empty now")

        pumpMain(0.05)
        host.view.layoutSubtreeIfNeeded()
        let emptied = pane.bounds.height
        let layout = try #require(pane.textLayoutManager)
        var fragments = 0
        layout.enumerateTextLayoutFragments(from: nil, options: [.ensuresLayout]) { _ in
            fragments += 1
            return true
        }
        #expect(abs(emptied - freshEmpty) < 24,
                "an emptied take stands where a fresh empty pane stands (\(emptied) vs \(freshEmpty)); it was \(tall) — the emptied container enumerated \(fragments) fragment(s) and the property reads \(layout.usageBoundsForTextContainer.height)")
    }

    /// The measurement's own contract, stated where a future reader will
    /// look for it: at steady state the fragments' bottom and the old
    /// property agree, so nothing that was converged moved when row 16's
    /// fix landed. GREEN on both sides deliberately — it is the
    /// no-regression half of row 16, not its pin.
    @Test func aFreshPanesMeasurementIsUnchangedByRow16sFix() throws {
        for text in ["", "hello", "hello\n", "hello\n\n\n\nhi there",
                     (1...30).map { "Line \($0) of prose." }.joined(separator: "\n")] {
            let host = NSHostingController(
                rootView: PaneSurfaceView(text: text, isLive: false).frame(width: 400))
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 420, height: 1400),
                styleMask: [.borderless], backing: .buffered, defer: false)
            window.contentViewController = host
            host.view.frame = NSRect(x: 0, y: 0, width: 420, height: 1400)
            for _ in 0..<6 { host.view.layoutSubtreeIfNeeded(); pumpMain(0.04) }
            func findPane(_ view: NSView) -> PaneTextView? {
                if let pane = view as? PaneTextView { return pane }
                for sub in view.subviews { if let found = findPane(sub) { return found } }
                return nil
            }
            let pane = try #require(findPane(host.view))
            let layout = try #require(pane.textLayoutManager)
            layout.ensureLayout(for: layout.documentRange)
            let property = layout.usageBoundsForTextContainer.height
                + pane.textContainerInset.height * 2
            #expect(abs(PaneMeasurement.height(of: pane) - max(property, 0)) < 0.5
                    || text.isEmpty,
                    "a fresh pane measures the same as it always did (\(PaneMeasurement.height(of: pane)) vs \(property)) for \(text.debugDescription)")
            window.contentViewController = nil
        }
    }
}
