//
//  PaneTextCompareTests.swift
//  VariorumTests
//
//  13u2 UNIT D — **TRACE 1a**, routed here by RULING A-1.
//
//  UNIT A read the 13l hang capture and found exactly one Variorum leaf in
//  it: `PaneSurface.swift`'s `if !isLive, view.string != text`, sitting on
//  `_stringCompareSlow` for 51 of the capture's 2,551 samples. `view.string`
//  is the text storage's `NSString`, LAZILY BRIDGED — a foreign
//  `__NSCFString` — so Swift's `==` cannot take its memcmp fast path and
//  falls to a full NFC normalization with one `characterAtIndex:` ObjC
//  message per UTF-16 unit. **The EQUAL case is the worst case** (proving
//  equality means scanning to the end), and equal is the common case: it is
//  paid per read pane per SwiftUI update pass, over unchanged text, which on
//  the Takes margin grid is the whole board.
//
//  The repair is the trace's own second suggestion: the coordinator
//  remembers what it last wrote, and the question is asked of that NATIVE
//  string. The decision is byte-for-byte the one the old line made — only
//  the road to it is cheap.
//
//  **The claim is pinned as a SHAPE, never as a stopwatch**
//  (`ReadLayerP1Tests`' discipline): after a pane has adopted its text once,
//  no number of further update passes over unchanged text may reach the
//  foreign road again. `PaneSurfaceAudit.foreignTextComparisons` counts the
//  reaches. The measured COST of the two roads is in the unit record.
//

import AppKit
import Combine
import Foundation
import SwiftUI
import Testing
@testable import Variorum

@MainActor
private func pumpMain(_ seconds: TimeInterval = 0.03) {
    RunLoop.main.run(until: Date().addingTimeInterval(seconds))
}

@MainActor
private final class PaneTextModel: ObservableObject {
    @Published var text: String
    @Published var live = false
    @Published var nudge = 0
    init(text: String) { self.text = text }
}

@MainActor
private struct PaneTextHost: View {
    @ObservedObject var model: PaneTextModel
    var body: some View {
        // `nudge` is read so an update pass really re-evaluates the body,
        // which is what a SwiftUI invalidate storm does to this surface.
        ScrollView {
            PaneSurfaceView(text: model.text, isLive: model.live)
                .id("pane")
                .opacity(model.nudge >= 0 ? 1 : 1)
        }
    }
}

@MainActor
@Suite("TRACE 1a — the read pane's projection compare", .serialized)
struct PaneTextCompareTests {
    private func mount(_ model: PaneTextModel) -> NSWindow {
        let host = NSHostingController(rootView: PaneTextHost(model: model))
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 500),
            styleMask: [.borderless], backing: .buffered, defer: false)
        window.contentViewController = host
        host.view.frame = NSRect(x: 0, y: 0, width: 400, height: 500)
        pumpMain()
        return window
    }

    private func pane(in view: NSView) -> PaneTextView? {
        if let pane = view as? PaneTextView { return pane }
        for sub in view.subviews { if let found = pane(in: sub) { return found } }
        return nil
    }

    /// RED ON OLD: every update pass took the foreign road, so the counter
    /// climbed with the passes (measured on the pre-fix tree — see the
    /// record). Here it stays where the mount left it.
    @Test func updatePassesOverUnchangedTextNeverAskTheViewAgain() {
        let text = (1...40).map { "paragraph number \($0) of honest prose" }
            .joined(separator: "\n")
        let model = PaneTextModel(text: text)
        let window = mount(model)
        defer { window.contentViewController = nil }

        PaneSurfaceAudit.reset()
        for _ in 0..<12 {
            model.nudge += 1
            pumpMain(0.01)
        }
        #expect(PaneSurfaceAudit.foreignTextComparisons == 0,
                "a settled read pane asks the view nothing")
    }

    /// The decision itself is unchanged: a projection change is adopted.
    @Test func aChangedProjectionIsStillAdopted() throws {
        let model = PaneTextModel(text: "before")
        let window = mount(model)
        defer { window.contentViewController = nil }
        let view = try #require(pane(in: window.contentView!))
        #expect(view.string == "before")

        model.text = "after, and longer than before"
        pumpMain(0.05)
        #expect(view.string == "after, and longer than before")

        // …and the same text again changes nothing and asks nothing.
        PaneSurfaceAudit.reset()
        model.nudge += 1
        pumpMain(0.02)
        #expect(view.string == "after, and longer than before")
        #expect(PaneSurfaceAudit.foreignTextComparisons == 0)
    }

    /// The one road that still asks the view: the first READ pass after the
    /// pane was LIVE. Her buffer is the truth there, so the record is
    /// dropped and the old comparison answers — correct, and rare.
    @Test func theFirstReadPassAfterLivenessAsksTheViewOnce() {
        let model = PaneTextModel(text: "a line of prose")
        let window = mount(model)
        defer { window.contentViewController = nil }

        model.live = true
        pumpMain(0.05)
        PaneSurfaceAudit.reset()
        model.live = false
        pumpMain(0.05)
        #expect(PaneSurfaceAudit.foreignTextComparisons >= 1,
                "the record was dropped while live, so the view is asked")

        // And then it settles back to silence.
        let after = PaneSurfaceAudit.foreignTextComparisons
        for _ in 0..<6 {
            model.nudge += 1
            pumpMain(0.01)
        }
        #expect(PaneSurfaceAudit.foreignTextComparisons == after)
    }
}
