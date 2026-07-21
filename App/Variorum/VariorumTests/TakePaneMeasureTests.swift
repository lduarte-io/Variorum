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
}
