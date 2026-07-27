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
import SwiftUI
import Testing
@testable import Variorum

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

        // An ordinary same-width layout pass — the only kind of event her
        // stable void ever received (clicks, ring moves, scrolls).
        pane.needsLayout = true
        settle()

        let measured = PaneMeasurement.height(of: pane)
        #expect(abs(pane.bounds.height - measured) <= 3,
                "the frame re-converges to the current measurement on the next layout pass (frame \(pane.bounds.height) vs measured \(measured)) — on the pre-fix code it stays at \(tall) forever")
    }
}
