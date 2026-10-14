//
//  MarkdownCaretFaceTests.swift
//  VariorumTests
//
//  VX-296 — the italics flicker (her report, 2026-10-13: "the italics flip
//  happens when im typing inside *these*. every time theres a space next to
//  this symbol * it stops being in italics, once it's a character it's in
//  italics again"). Her ruling on the ticket: fix (a), "your fix is good" —
//  caret-aware in the LIVE EDITOR only.
//
//  These pins drive the Mac's two live roads through the REAL edit path:
//    - the Write editor (and the book's inline editor, which wires the same
//      `EditorSurfaceDelegate` to the same `EditorViewModel`) — `insertText`
//      → `didProcessEditing` → `storageDidEdit`'s restyle → the selection
//      change;
//    - a live PANE (Takes, Lenses, Index, Read's edit face, the take panel…)
//      — `insertText` → `textDidChange`'s restyle, and the pane's selection
//      change.
//  RED ON OLD where marked: on the pre-fix tree every live restyle was
//  caret-blind, so `*hello |*` read plain. The guards (arithmetic, the
//  zero-write caret move, identity) are green on both sides by design.
//
//  The pure halves — the parser's rescue, the O(1) gate, the ledger — are
//  pinned headless in `Tests/VariorumCoreTests/MarkdownCaretRescueTests`.
//

import AppKit
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

private func font(_ text: NSAttributedString, at offset: Int) -> NSFont? {
    text.attribute(.font, at: offset, effectiveRange: nil) as? NSFont
}

private func isItalic(_ text: NSAttributedString, at offset: Int) -> Bool {
    font(text, at: offset)?.fontDescriptor.symbolicTraits.contains(.italic) ?? false
}

private func isBold(_ text: NSAttributedString, at offset: Int) -> Bool {
    font(text, at: offset)?.fontDescriptor.symbolicTraits.contains(.bold) ?? false
}

/// The offsets in `range` whose character does NOT read italic.
private func unstyled(_ text: NSAttributedString, _ range: Range<Int>) -> [Int] {
    range.filter { !isItalic(text, at: $0) }
}

/// Is any character in `range` wearing the markdown face at all?
private func anyFace(_ text: NSAttributedString, _ range: Range<Int>) -> Bool {
    range.contains { text.attribute(MarkdownStyling.faceAttribute, at: $0, effectiveRange: nil) != nil }
}

@MainActor
@Suite("VX-296 — the caret-aware face in the Write editor")
struct MarkdownCaretFaceTests {

    /// **HER PIN — RED ON OLD.** ⌘I's pair (`**`, the caret between), then
    /// her words typed one keystroke at a time: after EVERY keystroke —
    /// the spaces included — everything typed so far reads italic.
    ///
    /// On the pre-fix tree the first space reads `*hello *`, whose closer the
    /// flanking rule refused, and the whole span went plain — then came back
    /// at `w`. The flip she reported, at every word boundary.
    @Test func herFlowTypingInsideAnItalicPairNeverDropsTheItalicAtASpace() async throws {
        try await withEditor(seedBlocks: ["**", "after"]) { h in
            let storage = try #require(h.textView.textStorage)
            h.textView.setSelectedRange(NSRange(location: 1, length: 0))
            var typed = ""
            var flips: [String] = []
            for character in "hello world again" {
                h.type(String(character))
                typed.append(character)
                let count = typed.utf16.count
                if !unstyled(storage, 1..<(1 + count)).isEmpty { flips.append(typed) }
            }
            #expect(h.documentText == "*hello world again*\nafter")
            #expect(flips.isEmpty, "the italic dropped after typing: \(flips)")

            // ATTRIBUTES ONLY: display == stored, the caret's restyle wrote no
            // identity — every character of the block still carries its ID,
            // the separator none — and the per-keystroke oracle never fired.
            await h.flush()
            try expectStoreMatchesView(h)
            let blockID = h.model.index.entries[0].blockID
            let blockRange = h.model.index.range(ofEntryAt: 0)
            for offset in blockRange.location..<blockRange.upperBound {
                #expect(EditorDocument.blockID(at: offset, in: storage) == blockID)
            }
            #expect(EditorDocument.blockID(at: blockRange.upperBound, in: storage) == nil,
                    "the separator carries no identity")
            #expect(h.model.identityAuditFailures == 0)
        }
    }

    /// **RED ON OLD — ⌘B's pair, the same rule (P-U2-2, PROVISIONAL).** On
    /// the pre-fix tree `**hello |**` did not even read plain: the bold
    /// failed, the scan stepped one star in, and the last star closed an
    /// ITALIC over `hello *` — bold, then italic with a stray dimmed star,
    /// then bold again at the next letter.
    @Test func aBoldPairStaysBoldAtASpaceToo() async throws {
        try await withEditor(seedBlocks: ["****"]) { h in
            let storage = try #require(h.textView.textStorage)
            h.textView.setSelectedRange(NSRange(location: 2, length: 0))
            var flips: [String] = []
            var typed = ""
            for character in "two words" {
                h.type(String(character))
                typed.append(character)
                let content = 2..<(2 + typed.utf16.count)
                if content.contains(where: { !isBold(storage, at: $0) })
                    || content.contains(where: { isItalic(storage, at: $0) }) {
                    flips.append(typed)
                }
            }
            #expect(h.documentText == "**two words**")
            #expect(flips.isEmpty, "the bold flickered after typing: \(flips)")
        }
    }

    /// **RED ON OLD (its first and third expectations).** Her ruling's
    /// other half: *when she leaves a trailing space behind, the span
    /// honestly un-styles* — an arrow past the star, a click elsewhere — and
    /// coming back to the rescue point brings the italic back.
    @Test func leavingATrailingSpaceBehindUnstylesTheSpanHonestly() async throws {
        try await withEditor(seedBlocks: ["**", "next block"]) { h in
            let storage = try #require(h.textView.textStorage)
            h.textView.setSelectedRange(NSRange(location: 1, length: 0))
            h.type("hello ")
            #expect(h.documentText == "*hello *\nnext block")
            #expect(h.textView.selectedRange() == NSRange(location: 7, length: 0))
            #expect(unstyled(storage, 1..<7).isEmpty, "her caret sits after the space: italic")

            h.textView.moveRight(nil)  // past the closing star
            #expect(h.textView.selectedRange() == NSRange(location: 8, length: 0))
            #expect(!anyFace(storage, 0..<8), "the trailing space is left behind: no span, no marker face")

            h.textView.moveLeft(nil)   // back to the rescue point
            #expect(unstyled(storage, 1..<7).isEmpty, "back between the space and the star: italic again")

            // A selection is not typing.
            h.textView.setSelectedRange(NSRange(location: 6, length: 1))
            #expect(!anyFace(storage, 0..<8))
            h.textView.setSelectedRange(NSRange(location: 7, length: 0))
            #expect(unstyled(storage, 1..<7).isEmpty)

            // A click into the next block.
            h.textView.setSelectedRange(NSRange(location: 12, length: 0))
            #expect(!anyFace(storage, 0..<8))
            #expect(h.model.identityAuditFailures == 0)
        }
    }

    /// **GUARD (green both sides).** `2 * 3 * 4` — typed keystroke by
    /// keystroke, then with the caret parked at every position — never
    /// wears the face anywhere: no opener ever forms, so no caret can rescue
    /// a closer.
    @Test func arithmeticStaysPlainAtEveryCaretPositionAndAsItIsTyped() async throws {
        try await withEditor(seedBlocks: ["2", "after"]) { h in
            let storage = try #require(h.textView.textStorage)
            h.textView.setSelectedRange(NSRange(location: 1, length: 0))
            var typed = "2"
            for character in " * 3 * 4" {
                h.type(String(character))
                typed.append(character)
                #expect(!anyFace(storage, 0..<typed.utf16.count), "after typing \(typed.debugDescription)")
            }
            #expect(h.documentText == "2 * 3 * 4\nafter")
            for caret in 0...9 {
                h.textView.setSelectedRange(NSRange(location: caret, length: 0))
                #expect(!anyFace(storage, 0..<9), "caret at \(caret)")
            }
        }
    }

    /// **P1 (the settle's cost) — its non-vacuity half RED ON OLD.** A caret
    /// move that cannot change the reading scans NOTHING (the O(1) gate); a
    /// move onto or off a rescue point scans the one or two lines involved
    /// — never the note.
    @Test func aCaretMoveCostsAtMostTwoLinesAndNothingWhereItCannotMatter() async throws {
        let line = "lorem ipsum *dolor sit * amet consectetur"
        let long = Array(repeating: line, count: 400).joined(separator: "\n")
        try await withEditor(seedBlocks: [long]) { h in
            let documentLength = (h.documentText as NSString).length
            #expect(documentLength > 10_000)
            let lineLength = line.utf16.count + 1
            let rescueInLine = (line as NSString).range(of: "* amet").location  // between the space and the star
            let deep = lineLength * 200 + rescueInLine
            let far = lineLength * 350 + rescueInLine

            // Moves that cannot matter: nothing scanned at all.
            MarkdownScanCount.reset()
            for caret in [5, lineLength * 100 + 3, lineLength * 300 + 9] {
                h.textView.setSelectedRange(NSRange(location: caret, length: 0))
            }
            #expect(MarkdownScanCount.current == 0, "a caret move nowhere near a rescue point scans nothing")

            // Onto a rescue point: its line, once.
            MarkdownScanCount.reset()
            h.textView.setSelectedRange(NSRange(location: deep, length: 0))
            let arriving = MarkdownScanCount.current
            #expect(arriving > 0, "the settle really ran (red on old: nothing honoured the caret)")
            #expect(arriving <= 2 * lineLength, "P1: the caret's line, never the note")

            // From one rescue point to another 150 lines away: two lines.
            MarkdownScanCount.reset()
            h.textView.setSelectedRange(NSRange(location: far, length: 0))
            #expect(MarkdownScanCount.current <= 4 * lineLength, "P1: the line left and the line arrived at")
            #expect(MarkdownScanCount.current < documentLength / 50)
        }
    }
}

// MARK: - A live pane

/// A pane whose liveness a pin can flip — file-scope, because the
/// `@Observable` macro cannot expand on a private nested type.
@MainActor @Observable
fileprivate final class CaretPaneBox {
    var live = true
    var text = "**"
}

fileprivate struct CaretPaneHost: View {
    let box: CaretPaneBox
    var body: some View {
        PaneSurfaceView(text: box.text, isLive: box.live)
            .frame(width: 400)
    }
}

@MainActor
@Suite("VX-296 — the caret-aware face in a live pane", .serialized)
struct PaneMarkdownCaretFaceTests {
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

    private func mount(_ box: CaretPaneBox)
        -> (host: NSHostingController<CaretPaneHost>, window: NSWindow, pane: PaneTextView)? {
        let host = NSHostingController(rootView: CaretPaneHost(box: box))
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 400),
            styleMask: [.borderless], backing: .buffered, defer: false)
        window.contentViewController = host
        host.view.layoutSubtreeIfNeeded()
        pump()
        guard let pane = findPane(host.view) else { return nil }
        return (host, window, pane)
    }

    /// **HER PIN ON A PANE — RED ON OLD.** The same flow in a live take
    /// pane: the pane's own keystroke road (`textDidChange`) restyled the
    /// line caret-blind, so the space dropped the italic there too.
    @Test func aLivePaneKeepsTheItalicWhileHerCaretSitsAfterTheSpace() async throws {
        let box = CaretPaneBox()
        let (_, window, pane) = try #require(mount(box))
        defer { window.contentViewController = nil }
        let storage = try #require(pane.textStorage)
        #expect(pane.isEditable, "the pane is live")
        pane.setSelectedRange(NSRange(location: 1, length: 0))
        var typed = ""
        var flips: [String] = []
        for character in "hello world" {
            pane.insertText(String(character), replacementRange: pane.selectedRange())
            typed.append(character)
            if !unstyled(storage, 1..<(1 + typed.utf16.count)).isEmpty { flips.append(typed) }
        }
        #expect(pane.string == "*hello world*")
        #expect(flips.isEmpty, "the italic dropped after typing: \(flips)")
    }

    /// **RED ON OLD (its first expectation).** Leaving the rescue point —
    /// an arrow, or the pane going READ when the ring moves to another pane
    /// — un-styles the span; a read pane never honours a caret.
    @Test func aPaneThatLosesTheCaretOrGoesReadUnstylesTheSpan() async throws {
        let box = CaretPaneBox()
        box.text = "*hello *"
        let (host, window, pane) = try #require(mount(box))
        defer { window.contentViewController = nil }
        let storage = try #require(pane.textStorage)
        pane.setSelectedRange(NSRange(location: 7, length: 0))
        #expect(unstyled(storage, 1..<7).isEmpty, "her caret sits after the space: italic")

        pane.moveRight(nil)
        #expect(!anyFace(storage, 0..<8), "past the star: the trailing space is left behind")
        pane.moveLeft(nil)
        #expect(unstyled(storage, 1..<7).isEmpty, "back: italic again")

        // The ring moves elsewhere: this pane goes read with its caret still
        // parked at the rescue point.
        box.live = false
        pump()
        host.view.layoutSubtreeIfNeeded()
        pump()
        #expect(!pane.isEditable, "the pane went read")
        #expect(pane.string == "*hello *", "the same text — no re-adoption restyled it")
        #expect(!anyFace(storage, 0..<8), "a read pane honours no caret")
        // And a caret placed in a read pane (a find step's selection, a click
        // on its way to a focus request) honours nothing either.
        pane.setSelectedRange(NSRange(location: 7, length: 0))
        #expect(!anyFace(storage, 0..<8))
    }
}
