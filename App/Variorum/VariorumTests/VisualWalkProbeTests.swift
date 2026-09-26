//
//  VisualWalkProbeTests.swift
//  VariorumTests
//
//  18l U-VIS round 1, N7 — the visual harness's ORACLE ENDPOINT, pinned in-suite
//  (`Core/Views/VisualWalkProbe.swift`). Two facts the harness trusts every run:
//
//  1. THE GATE. The endpoint exists only in DEBUG, and inside DEBUG only when the
//     process was launched with `VARIORUM_VISUAL_WALK=1` — Xcode Run, the test host
//     and every walk that is not the harness never register it.
//  2. THE ARITHMETIC, on a bare TextKit 2 view: the first visible line, the caret's
//     line, and — the fact U0's click regression rests on and TEXTKIT2_NOTES §3 calls
//     version-variable — a caret after a trailing newline sits on the EXTRA empty line
//     fragment, below the text. The harness runs after every macOS update; a point
//     release that moves any of this goes red HERE, not as a baffling walk result.
//     And the probe reads nothing off screen unless asked (round 1, MINOR-8).
//

#if DEBUG
import AppKit
import Testing
@testable import Variorum

@MainActor
@Suite("The visual walk's oracle endpoint — the env gate and its TK2 arithmetic (18l U-VIS)")
struct VisualWalkProbeTests {
    @Test func theObserverRegistersOnlyWhenTheHarnessLaunchedTheProcess() {
        VisualWalkProbe.uninstall()
        defer { VisualWalkProbe.uninstall() }
        #expect(!VisualWalkProbe.isInstalled, "the test host was not launched by the harness")
        VisualWalkProbe.installIfRequested(environment: [:]) { nil }
        #expect(!VisualWalkProbe.isInstalled, "no flag, no observer")
        VisualWalkProbe.installIfRequested(environment: ["VARIORUM_VISUAL_WALK": "0"]) { nil }
        #expect(!VisualWalkProbe.isInstalled, "only the value 1 opens the gate")
        VisualWalkProbe.installIfRequested(environment: ["VARIORUM_VISUAL_WALK": "1"]) { nil }
        #expect(VisualWalkProbe.isInstalled, "the harness's launch registers the endpoint")
    }

    /// A bare TK2 view in a window: "alpha one" / "beta two" / the empty line after the
    /// trailing newline — her notes' shape (every sample-library block ends in "\n").
    private func rig() -> (NSWindow, NSTextView) {
        let scrollView = NSScrollView(frame: NSRect(x: 0, y: 0, width: 500, height: 300))
        let textView = NSTextView(usingTextLayoutManager: true)
        textView.frame = NSRect(x: 0, y: 0, width: 500, height: 300)
        textView.textContainerInset = NSSize(width: 0, height: 10)
        textView.string = "alpha one\nbeta two\n"
        scrollView.documentView = textView
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 300),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = scrollView
        if let layout = textView.textLayoutManager {
            layout.ensureLayout(for: layout.documentRange)
            layout.textViewportLayoutController.layoutViewport()
        }
        return (window, textView)
    }

    private func facts(_ textView: NSTextView, last: Bool = false) -> VisualWalkProbe.Line {
        var line = VisualWalkProbe.Line(id: "pin")
        VisualWalkProbe.textFacts(textView, measure: false, last: last, into: &line)
        return line
    }

    @Test func theFirstLineAndACaretAtTheStart() throws {
        let (window, textView) = rig()
        defer { window.close() }
        textView.setSelectedRange(NSRange(location: 0, length: 0))
        let line = facts(textView)
        #expect(line["len"] == "19")
        #expect(line["nl"] == "1", "the text ends in a newline")
        #expect(line["top"] == "0", "the first visible line is the text's first")
        #expect(line["topBlank"] == "0")
        #expect(line["caretEnd"] == "0")
        #expect(line["caretState"] == "laid")
        #expect(line["caretLine"] == "0")
        let y0 = try #require(line["caretY0"].flatMap(Double.init))
        let top = try #require(line["topY"].flatMap(Double.init))
        #expect(abs(y0 - top) < 0.5, "the caret at 0 is on the first visible line")
    }

    @Test func aCaretAfterTheTrailingNewlineSitsOnTheEmptyLineBelowTheText() throws {
        let (window, textView) = rig()
        defer { window.close() }
        textView.setSelectedRange(NSRange(location: 9, length: 0))   // "alpha one|"
        let onText = facts(textView)
        textView.setSelectedRange(NSRange(location: 19, length: 0))  // after "beta two\n"
        let atEnd = facts(textView)
        #expect(atEnd["caretEnd"] == "1")
        #expect(atEnd["caretState"] == "laid")
        let lines = try #require(atEnd["caretLines"].flatMap(Int.init))
        let textLines = try #require(atEnd["caretTextLines"].flatMap(Int.init))
        #expect(atEnd["caretLine"] == "\(lines - 1)", "the caret is on the fragment's LAST line")
        #expect(lines == textLines + 1,
                "TK2 lays an EXTRA empty line fragment after a trailing newline (TEXTKIT2_NOTES §3) — the line U0's regression parked the caret on")
        let textLineY = try #require(onText["caretY1"].flatMap(Double.init))
        let endY = try #require(atEnd["caretY0"].flatMap(Double.init))
        #expect(endY > textLineY, "that empty line is BELOW the text's lines")
    }

    @Test func theLastFragmentIsReadOnlyWhenAsked() {
        let (window, textView) = rig()
        defer { window.close() }
        #expect(facts(textView)["lastFrag"] == nil, "no off-screen read unless asked (MINOR-8)")
        #expect(facts(textView, last: true)["lastFrag"] != nil)
    }
}
#endif
