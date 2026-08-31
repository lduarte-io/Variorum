//
//  CheckboxScrollTests.swift
//  VariorumTests
//
//  pre-13u Act 10 wave 1, item 11 — **checking a markdown checkbox jumped to
//  the absolute bottom of the note.** Her report (the Act 7 arrivals); the
//  mechanism was UNKNOWN by her own words, so it was traced before anything
//  was changed:
//
//  ── THE TRACED MECHANISM ─────────────────────────────────────────────────
//  A click on a checkbox's box runs `MarkdownActs.toggleCheckbox` BEFORE
//  `super.mouseDown` — so at toggle time the CARET is still wherever it was
//  before the click, and after a writing session that is the document's END.
//  The toggle's 3-for-3 storage edit calls `didChangeText()`, and that hook
//  runs `TypewriterScrollView.keepCaretClearance` — β1's typing-follow, which
//  computes the CARET's line bottom and scrolls down to keep ~2 lines of air
//  under it. With the caret at the end of the note and the view scrolled up
//  to the checkbox, "the caret's line" is the bottom of the note — so the
//  view jumps to the absolute bottom, exactly as she reported. β1's own doc
//  states the premise this violated: *"didChangeText … fires for typing,
//  paste and delete but NOT for clicks, so a click near the bottom of the
//  page never makes the view jump"* — a click that EDITS was the case the
//  premise did not cover.
//
//  The fix: the toggle's edit is a click's, not typing — it suppresses the
//  caret-follow for exactly its own mutation (`withoutCaretFollow`, the
//  `withSoftNewline`/`withPasteFlag` idiom on this class). Typing, paste and
//  delete keep the clearance byte-identically.
//

import AppKit
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("Checkbox toggle keeps the scroll (Act 10 item 11)", .serialized)
struct CheckboxScrollTests {
    private func pump(_ seconds: TimeInterval = 0.05) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    /// A long note: a checkbox in the SECOND block, prose after it — enough
    /// that the document end is far below a 600-pt viewport.
    private var corpus: [String] {
        var blocks = ["The opening paragraph of the note."]
        blocks.append("- [ ] buy milk")
        blocks += (0..<30).map { p in
            (0..<120).map { "word\(($0 &+ p) % 977)" }.joined(separator: " ") + " ¶\(p)"
        }
        return blocks
    }

    /// **The pin (red on old):** caret at the document end (where she was
    /// typing), view scrolled to the top (where the checkbox is), click the
    /// box → the box toggles, the caret stays put, and the SCROLL DOES NOT
    /// MOVE.
    @Test func togglingACheckboxPreservesScrollAndCaret() async throws {
        try await withEditor(seedBlocks: corpus) { h in
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 900, height: 600),
                styleMask: [.titled, .resizable], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let scrollView = try #require(h.textView.enclosingScrollView)
            window.contentView = scrollView
            window.orderFrontRegardless()
            pump()

            // Her session's shape: the caret sits at the very end of the note.
            let docLength = (h.documentText as NSString).length
            h.textView.setSelectedRange(NSRange(location: docLength, length: 0))
            // She scrolls up to the top, where the checkbox is.
            scrollView.contentView.scroll(to: .zero)
            scrollView.reflectScrolledClipView(scrollView.contentView)
            pump()
            let beforeOrigin = scrollView.contentView.bounds.origin.y
            #expect(beforeOrigin < 1, "the test's premise: the view starts at the top")

            // The box's interior: "- [ ] buy milk" — "[ ]" spans line offsets
            // 2..<5; strictly inside is 3/4. Resolve its on-screen point the
            // way a click produces one.
            let document = h.documentText as NSString
            let line = document.range(of: "- [ ] buy milk")
            #expect(line.location != NSNotFound)
            let boxInterior = NSRange(location: line.location + 3, length: 1)
            let screenRect = h.textView.firstRect(forCharacterRange: boxInterior, actualRange: nil)
            let windowRect = window.convertFromScreen(screenRect)
            let point = h.textView.convert(windowRect, from: nil).origin
            // Guard the premise: this point resolves inside the box.
            let insertion = h.textView.characterIndexForInsertion(
                at: NSPoint(x: point.x + 1, y: point.y + 1))
            #expect(abs(insertion - (line.location + 3)) <= 1)

            let consumed = MarkdownActs.toggleCheckbox(
                at: NSPoint(x: point.x + 1, y: point.y + 1), in: h.textView)
            #expect(consumed, "the click landed on the box and was consumed")
            pump()

            // The box toggled…
            #expect(h.documentText.contains("- [x] buy milk"))
            // …the caret went back where it was (3-for-3 keeps offsets)…
            #expect(h.textView.selectedRange().location == docLength)
            // …and the view did not move. RED on the old code: β1's caret
            // clearance scrolled to the caret's line at the bottom of the note.
            let afterOrigin = scrollView.contentView.bounds.origin.y
            #expect(
                abs(afterOrigin - beforeOrigin) < 1,
                "the scroll jumped from \(beforeOrigin) to \(afterOrigin)")

            await h.flush()
        }
    }
}
