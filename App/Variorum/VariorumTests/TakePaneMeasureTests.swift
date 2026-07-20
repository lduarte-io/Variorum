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
    private func pumpedPaneHeight(text: String) -> CGFloat {
        let host = NSHostingController(
            rootView: TakePaneView(text: text, isLive: false)
                .frame(width: 400))
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
        func findTakeView(_ view: NSView) -> TakeTextView? {
            if let take = view as? TakeTextView { return take }
            for sub in view.subviews {
                if let found = findTakeView(sub) { return found }
            }
            return nil
        }
        let height = findTakeView(host.view).map(\.bounds.height) ?? 0
        window.contentViewController = nil
        return height
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
}
