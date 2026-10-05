//
//  CaptureFocusReportTests.swift
//  VariorumTests
//
//  17y B2 — item (m): THE QUICK-ENTRY BOX'S DOUBLE BLINKING CURSOR. Her
//  rule verbatim: "if the terminal cursor is blinking open at the end, your
//  cursor shouldn't be blinking as well" — exactly ONE cursor at a time.
//
//  The mechanism (the B2 RECORD): the box (`QuickEntryBar` — the Bookcase's
//  and the Library's capture) draws the Terminal voice's blinking block
//  cursor while `showsBlockCursor && !entryFocused`, and `entryFocused` is
//  `CaptureTextView`'s `onFocusChange`. Since 13u3 UNIT C (a0b1957d) that
//  report came from `textDidBeginEditing` / `textDidEndEditing` — which
//  AppKit posts on the first EDIT, not when the caret arrives. The Bookcase
//  autofocuses the box (R102), so the caret blinks in the empty box while
//  the host still believes it is elsewhere, and the block cursor blinks
//  beside it: two cursors. Before 13u3 the gate read `@FocusState` (the
//  first-responder truth), and the Snippets area's entry still does.
//
//  The pin drives the PRODUCTION representable in a real key window: the
//  caret arriving by the box's own focus request (no keystroke) must be
//  reported, and so must its departure. Red-on-old, stated exactly: on the
//  pre-fix tree the ARRIVAL is not reported — 1 issue (AppKit's end-editing
//  notification still reported the departure); the behavioural revert (the
//  first-responder wire removed) reports neither — 2 issues. Both counts
//  re-measured on THIS host at the B2 fix round (the record).
//
//  THE ROAD (the B2 ladder's NIT-1): the caret arrives by a focus request
//  RAISED once the box is up — the bar's own re-raise road (a click on the
//  box's padding, the title chip handing the caret back): `updateNSView` →
//  `takeFocus` → `makeFirstResponder`, which runs INSIDE SwiftUI's view
//  update — and the host writes `@State` from the report as `QuickEntryBar`
//  does. The report is delivered on the next main-queue turn (never inside
//  that update), so the pin settles for it.
//
//  Why not the `.task` raise at birth (the Bookcase's autofocus), as the
//  ladder asked: in this hosted window that raise lands while the box is
//  NOT yet in a window, and `takeFocus` drops it (the request consumed, no
//  caret, no report) — measured by the fix round with scratch diagnostics.
//  Whether the real Bookcase's autofocus meets that order is untraced (its
//  walk shows the caret arriving); recorded for the orchestrator in the 17y
//  B2 FIX ROUND record, not changed here.
//

import AppKit
import Observation
import SwiftUI
import Testing
@testable import Variorum

@MainActor
@Suite("17y (m) — the capture box reports where the CARET is, not whether she edited",
       .serialized)
struct CaptureFocusReportTests {
    private final class Log {
        var reports: [Bool] = []
    }

    /// The bar's counted focus REQUEST, raised by the pin once the box is up
    /// (`QuickEntryBar`'s `focusRequest += 1` — its padding tap, its chip).
    @Observable fileprivate final class Asker {
        var focusRequest = 0
    }

    private struct Host: View {
        @State var text = ""
        /// The bar's own state (`QuickEntryBar.entryFocused`), written from
        /// the report exactly as the bar writes it.
        @State var entryFocused = false
        let asker: Asker
        let log: Log
        var body: some View {
            CaptureTextView(
                text: $text, style: CaptureTextStyle(tokens: .terminalLight),
                maxHeight: 160, focusRequest: asker.focusRequest,
                onFocusChange: {
                    entryFocused = $0
                    log.reports.append($0)
                }, onFile: {})
                .frame(width: 400, height: 60)
        }
    }

    private func pump() {
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
    }

    private func settle(_ window: NSWindow, _ hosting: NSView, turns: Int = 15) async {
        for _ in 0..<turns {
            hosting.layoutSubtreeIfNeeded()
            window.displayIfNeeded()
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(10))
        }
    }

    private func captureView(in view: NSView) -> CaptureNSTextView? {
        if let found = view as? CaptureNSTextView { return found }
        for sub in view.subviews {
            if let found = captureView(in: sub) { return found }
        }
        return nil
    }

    @Test func theCaretArrivingAndLeavingIsReportedWithoutAKeystroke() async throws {
        let log = Log()
        let asker = Asker()
        let hosting = NSHostingView(rootView: Host(asker: asker, log: log))
        hosting.frame = NSRect(x: 0, y: 0, width: 420, height: 80)
        let window = NSWindow(
            contentRect: NSRect(x: 80, y: 80, width: 420, height: 80),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        defer {
            window.orderOut(nil)
            window.close()
        }
        await settle(window, hosting)

        let box = try #require(captureView(in: hosting))
        #expect(box.window === window, "the box is up")
        #expect(window.firstResponder !== box && log.reports.isEmpty,
                "nothing has asked for the caret yet")

        // The raise: `updateNSView` → `takeFocus` → `makeFirstResponder`,
        // inside SwiftUI's view update — the road NIT-1 is about.
        asker.focusRequest += 1
        await settle(window, hosting)
        #expect(window.firstResponder === box, "the request put the caret in the box")
        #expect(log.reports.last == true, """
            the caret is in the box and blinking — the host must hear it before \
            any keystroke, or the Terminal voice's block cursor blinks beside it
            """)

        window.makeFirstResponder(nil)
        await settle(window, hosting, turns: 5)
        #expect(log.reports.last == false,
                "the caret left — the block cursor may come back (one cursor, always)")
    }
}
