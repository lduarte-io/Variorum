//
//  CommandDeleteLineTests.swift
//  VariorumTests
//
//  13u4 UNIT E2 — HER item 11, verbatim: on the lines
//    `- [ ] Create carousel format for blog posts (maybe just screenshots of
//     personal blog to start?)`
//    `- [ ]`
//  *"Command delete at the end of the second line deletes this content:
//   start?) ⏎ - [ ]"*.
//
//  **THE TRACE FIRST** (the brief's discipline). These pins drive REAL KEY
//  EVENTS through AppKit's interpretation path — a window, a first responder,
//  `keyDown` → `interpretKeyEvents` → the standard key bindings — exactly as
//  `ReturnKeyTraceTests` does, because the whole question is what the KEY
//  proposes, not what our pipeline does with a range.
//
//  **WHAT THEY MEASURED (the unit's verdict, so a reader gets it from the
//  code):** ⌘⌫ dispatches `deleteToBeginningOfLine:`, and on macOS 26 that
//  selector deletes to the beginning of the **PARAGRAPH** — a wrapped
//  paragraph's whole text, never a visual fragment — so it is structurally
//  incapable of reaching through a newline. The editor's block separator IS
//  a newline (`EditorDocument.separator`), so it is equally incapable of
//  reaching through a block seam. The chord that DOES take exactly her
//  content is **⌥⌫** (`deleteWordBackward:`), and it takes it in a bare
//  `NSTextView` with nothing of ours wired — AppKit's own word-delete rule.
//  The pins below hold both halves: the ⌘⌫ ones are the brief's expected
//  shape, green on the shipped tree and kept as regression guards; the ⌥⌫
//  ones are CHARACTERIZATION — they record what the app does today so a
//  ruling can rewrite them deliberately (QUESTIONS #126), never a claim
//  that today's answer is the right one.
//

import AppKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

/// Her two lines, byte-exact.
enum CheckboxSeamFixture {
    static let first =
        "- [ ] Create carousel format for blog posts (maybe just screenshots of personal blog to start?)"
    /// What 13k K5's continuation actually types (`MarkdownEditing.continuedCheckboxLead`).
    static let second = "- [ ] "
    static var both: String { first + "\n" + second }
    /// The content her report names, byte-exact: `start?) ⏎ - [ ]`.
    static let herDeletedContent = "start?)\n- [ ] "
}

@MainActor
@Suite("⌘⌫ — what the key proposes (13u4 E2 trace)", .serialized)
struct CommandDeleteLineTraceTests {
    /// Records the command selectors AND the ranges the view proposes.
    @MainActor
    final class DeleteSpy: NSObject, NSTextViewDelegate {
        var commands: [String] = []
        var proposed: [NSRange] = []

        func textView(
            _ textView: NSTextView, doCommandBy commandSelector: Selector
        ) -> Bool {
            commands.append(NSStringFromSelector(commandSelector))
            return false  // let the view perform it
        }

        func textView(
            _ textView: NSTextView,
            shouldChangeTextIn affectedCharRange: NSRange,
            replacementString: String?
        ) -> Bool {
            proposed.append(affectedCharRange)
            return true
        }
    }

    /// A real key event for one of the delete chords.
    static func deleteEvent(
        forward: Bool, modifiers: NSEvent.ModifierFlags, windowNumber: Int
    ) -> NSEvent {
        let characters = forward ? "\u{F728}" : "\u{7F}"
        return NSEvent.keyEvent(
            with: .keyDown, location: .zero, modifierFlags: modifiers, timestamp: 0,
            windowNumber: windowNumber, context: nil,
            characters: characters, charactersIgnoringModifiers: characters,
            isARepeat: false, keyCode: forward ? 117 : 51)!
    }

    /// A plain `NSTextView` — nothing of ours wired — narrow enough that her
    /// first line WRAPS, hosted in a real key window. This is AppKit alone.
    private func plainView(_ text: String, width: CGFloat = 300)
        -> (view: NSTextView, spy: DeleteSpy, teardown: () -> Void) {
        let view = NSTextView(frame: NSRect(x: 0, y: 0, width: width, height: 300))
        view.isEditable = true
        view.isRichText = false
        view.isHorizontallyResizable = false
        view.textContainer?.widthTracksTextView = true
        view.textContainer?.size = NSSize(width: width, height: .greatestFiniteMagnitude)
        let spy = DeleteSpy()
        view.delegate = spy
        view.string = text
        let hosted = ReturnKeyTraceTests.host(view)
        return (view, spy, hosted.teardown)
    }

    private func press(
        _ view: NSTextView, forward: Bool = false, modifiers: NSEvent.ModifierFlags
    ) {
        view.keyDown(
            with: Self.deleteEvent(
                forward: forward, modifiers: modifiers,
                windowNumber: view.window?.windowNumber ?? 0))
    }

    private func caretAtEnd(_ view: NSTextView) {
        view.setSelectedRange(NSRange(location: (view.string as NSString).length, length: 0))
    }

    // MARK: - The dispatch fact, and the rule behind it

    /// **⌘⌫ IS `deleteToBeginningOfLine:` AND IT MEANS THE PARAGRAPH.** The
    /// paragraph here wraps onto three fragments at 300 pt, and the chord
    /// takes all 95 characters — not the last visual line. That is the whole
    /// reason the reported gesture cannot reach through a newline: its unit
    /// is the paragraph, and a newline is exactly where a paragraph stops.
    @Test func commandDeleteResolvesToTheParagraphNotTheVisualLine() throws {
        let (view, spy, teardown) = plainView(CheckboxSeamFixture.first)
        defer { teardown() }
        caretAtEnd(view)
        press(view, modifiers: .command)

        #expect(spy.commands == ["deleteToBeginningOfLine:"])
        #expect(spy.proposed == [NSRange(location: 0, length: 95)])
        #expect(view.string.isEmpty)
    }

    /// **HER TWO LINES, THE CHORD SHE NAMED, IN BARE APPKIT:** the proposed
    /// range is exactly the second line, and the first line survives
    /// byte-intact.
    @Test func commandDeleteNeverReachesThroughTheNewline() throws {
        let (view, spy, teardown) = plainView(CheckboxSeamFixture.both)
        defer { teardown() }
        caretAtEnd(view)
        press(view, modifiers: .command)

        #expect(spy.commands == ["deleteToBeginningOfLine:"])
        #expect(spy.proposed == [NSRange(location: 96, length: 6)])
        #expect(view.string == CheckboxSeamFixture.first + "\n")
    }

    /// The same on a view that opted into TEXTKIT 2 the way the app's editor
    /// does — the one configuration difference that could have made the
    /// selector resolve a different "line" (TEXTKIT2_NOTES §3's selection
    /// family). It does not.
    @Test func textKit2ResolvesTheSameLine() throws {
        let width: CGFloat = 300
        let container = NSTextContainer(
            size: NSSize(width: width, height: .greatestFiniteMagnitude))
        let manager = NSTextLayoutManager()
        let storage = NSTextContentStorage()
        storage.addTextLayoutManager(manager)
        manager.textContainer = container
        let view = NSTextView(
            frame: NSRect(x: 0, y: 0, width: width, height: 300), textContainer: container)
        view.isEditable = true
        view.isRichText = false
        view.isHorizontallyResizable = false
        view.textContainer?.widthTracksTextView = true
        let spy = DeleteSpy()
        view.delegate = spy
        view.string = CheckboxSeamFixture.both
        let hosted = ReturnKeyTraceTests.host(view)
        defer { hosted.teardown() }
        caretAtEnd(view)
        press(view, modifiers: .command)

        #expect(view.textLayoutManager != nil, "the TK2 opt-in held")
        #expect(spy.proposed == [NSRange(location: 96, length: 6)])
        #expect(view.string == CheckboxSeamFixture.first + "\n")
    }

    /// **THE CHORD THAT DOES TAKE HER CONTENT — and it is AppKit's, not
    /// ours.** ⌥⌫ dispatches `deleteWordBackward:`, which from the end of
    /// `- [ ] ` scans back over the lead, the newline and the punctuation to
    /// the start of `start` — `start?)⏎- [ ] `, her sentence byte for byte,
    /// in a `NSTextView` with nothing of Variorum's wired to it.
    @Test func optionDeleteIsTheChordThatTakesHerContent() throws {
        let (view, spy, teardown) = plainView(CheckboxSeamFixture.both)
        defer { teardown() }
        caretAtEnd(view)
        press(view, modifiers: .option)

        #expect(spy.commands == ["deleteWordBackward:"])
        let taken = spy.proposed.first.map { (CheckboxSeamFixture.both as NSString).substring(with: $0) }
        #expect(taken == CheckboxSeamFixture.herDeletedContent)
    }

    /// The rest of the family at the same caret, recorded as a table (the
    /// class sweep's raw material; the record carries the verdicts).
    @Test func theDeleteFamilyAtTheSameCaret() throws {
        let cases: [(String, Bool, NSEvent.ModifierFlags)] = [
            ("⌫", false, []),
            ("⌥⌫", false, .option),
            ("⌘⌫", false, .command),
            ("⌦", true, []),
            ("⌥⌦", true, .option),
            ("⌘⌦", true, .command),
        ]
        var dispatched: [String: [String]] = [:]
        for (name, forward, modifiers) in cases {
            let (view, spy, teardown) = plainView(CheckboxSeamFixture.both)
            defer { teardown() }
            caretAtEnd(view)
            press(view, forward: forward, modifiers: modifiers)
            dispatched[name] = spy.commands
            print("TRACE \(name): commands=\(spy.commands) proposed=\(spy.proposed) "
                + "after=\(view.string.debugDescription)")
        }
        #expect(dispatched["⌫"] == ["deleteBackward:"])
        #expect(dispatched["⌥⌫"] == ["deleteWordBackward:"])
        #expect(dispatched["⌘⌫"] == ["deleteToBeginningOfLine:"])
        #expect(dispatched["⌦"] == ["deleteForward:"])
        #expect(dispatched["⌥⌦"] == ["deleteWordForward:"])
        // ⌘⌦ is BOUND TO NOTHING on this layout — `noop:`, so the forward
        // twin of the reported chord cannot reach a seam at all.
        #expect(dispatched["⌘⌦"] == ["noop:"])
    }
}

// MARK: - The app's own road

@MainActor
@Suite("⌘⌫ in the real editor (13u4 E2)", .serialized)
struct CommandDeleteInEditorTests {
    private func hosted(_ h: EditorHarness) throws -> (window: NSWindow, teardown: () -> Void) {
        let hosted = ReturnKeyTraceTests.host(try #require(h.textView.enclosingScrollView))
        hosted.window.makeFirstResponder(h.textView)
        return hosted
    }

    private func press(
        _ h: EditorHarness, _ window: NSWindow,
        forward: Bool = false, modifiers: NSEvent.ModifierFlags
    ) {
        h.textView.keyDown(
            with: CommandDeleteLineTraceTests.deleteEvent(
                forward: forward, modifiers: modifiers,
                windowNumber: window.windowNumber))
    }

    private func caretAtEnd(_ h: EditorHarness) {
        h.textView.setSelectedRange(
            NSRange(location: (h.textView.string as NSString).length, length: 0))
        h.model.updateCaretContext()
    }

    /// Builds her note the way she built it: the checklist line, then ⏎ —
    /// 13k K5 continues the list, so the newline is CONTENT and both items
    /// live in ONE block (asserted here, because which shape it is decides
    /// which guard would have to catch anything).
    private func herNote(_ h: EditorHarness, _ window: NSWindow) async throws {
        caretAtEnd(h)
        h.textView.keyDown(
            with: ReturnKeyTraceTests.returnEvent(
                shift: false, windowNumber: window.windowNumber))
        await h.flush()
        #expect(h.textView.string == CheckboxSeamFixture.both)
        #expect(h.model.index.entries.count == 1, "13k K5: a list stays whole")
    }

    // MARK: THE BRIEF'S PIN — ⌘⌫ at the end of the second line

    /// **THE UNIT'S STATED PIN, in her own repro shape (ONE block, the list
    /// whole): ⌘⌫ deletes to THAT line's beginning and never through its
    /// newline — the previous line's tail survives byte-intact.** It is
    /// GREEN on the shipped tree, which is what makes the finding hollow as
    /// stated; it stays as the regression guard the brief's expected shape
    /// deserves.
    @Test func commandDeleteAtTheSecondLinesEndKeepsTheFirstLine() async throws {
        try await withEditor(seedBlocks: [CheckboxSeamFixture.first]) { h in
            let window = try hosted(h)
            defer { window.teardown() }
            try await herNote(h, window.window)

            caretAtEnd(h)
            press(h, window.window, modifiers: .command)
            await h.flush()

            #expect(h.textView.string == CheckboxSeamFixture.first + "\n")
            #expect(try h.storeSlots().map { $0.text ?? "<gap>" }
                    == [CheckboxSeamFixture.first + "\n"])
        }
    }

    /// The same chord in the TWO-BLOCK shape of the same picture (a pasted
    /// or imported checklist segments on entry, one block per item): ⌘⌫
    /// empties the second block and the first is byte-untouched — no seam is
    /// crossed, no block leaves.
    @Test func commandDeleteAcrossASeamTakesOnlyTheSecondBlock() async throws {
        try await withEditor(
            seedBlocks: [CheckboxSeamFixture.first, CheckboxSeamFixture.second]
        ) { h in
            let window = try hosted(h)
            defer { window.teardown() }
            caretAtEnd(h)
            press(h, window.window, modifiers: .command)
            await h.flush()

            #expect(h.model.index.entries.count == 2, "both blocks are still here")
            #expect(try h.storeSlots().map { $0.text ?? "<gap>" }
                    == [CheckboxSeamFixture.first, ""])
        }
    }

    // MARK: CHARACTERIZATION — what her report's content actually needs

    /// **What DOES take her content, in her own one-block note: ⌥⌫.** The
    /// range is AppKit's (`deleteWordBackward:`, pinned in the trace suite
    /// against a bare text view), the newline it crosses is CONTENT (I4),
    /// and the edit is an ordinary in-block one — byte-identical to what
    /// TextEdit does with the same keystroke. **CHARACTERIZATION, not
    /// approval:** QUESTIONS #126 carries the product call.
    @Test func optionDeleteTakesHerContentFromTheOneBlockNote() async throws {
        try await withEditor(seedBlocks: [CheckboxSeamFixture.first]) { h in
            let window = try hosted(h)
            defer { window.teardown() }
            try await herNote(h, window.window)

            caretAtEnd(h)
            press(h, window.window, modifiers: .option)
            await h.flush()

            let survivor = "- [ ] Create carousel format for blog posts "
                + "(maybe just screenshots of personal blog to "
            #expect(h.textView.string == survivor)
            #expect(try h.storeSlots().map { $0.text ?? "<gap>" } == [survivor])
        }
    }

    /// And in the TWO-BLOCK shape the same chord spans a seam, so it takes
    /// the ruled cross-block road (R-13u-2 / item 5): the block the span
    /// covers WHOLE rides `deleteBlock` (the Trash/tray road, recoverable)
    /// and the surviving end keeps its cut text. **CHARACTERIZATION** — the
    /// ruling is the author's, and this pin records what it does today.
    @Test func optionDeleteAcrossASeamRidesTheCrossBlockRoad() async throws {
        try await withEditor(
            seedBlocks: [CheckboxSeamFixture.first, CheckboxSeamFixture.second]
        ) { h in
            let window = try hosted(h)
            defer { window.teardown() }
            caretAtEnd(h)
            press(h, window.window, modifiers: .option)
            await h.flush()

            let survivor = "- [ ] Create carousel format for blog posts "
                + "(maybe just screenshots of personal blog to "
            #expect(try h.storeSlots().map { $0.text ?? "<gap>" } == [survivor],
                    "the second block left for the Trash; the first kept its cut")
        }
    }

    /// The family's forward half at the seam's LEADING side (the caret at the
    /// end of the first block), recorded because that is where a forward
    /// chord is the one that reaches over. ⌦ joins the blocks (the ruled
    /// merge join — E3 changes the join, not this road), ⌥⌦ takes the second
    /// block's word and joins, ⌘⌦ is bound to nothing and does nothing.
    @Test func theForwardFamilyAtTheSeam() async throws {
        let cases: [(String, NSEvent.ModifierFlags, [String])] = [
            ("⌦", [], [CheckboxSeamFixture.first + " " + CheckboxSeamFixture.second]),
            ("⌥⌦", .option, [CheckboxSeamFixture.first]),
            ("⌘⌦", .command, [CheckboxSeamFixture.first, CheckboxSeamFixture.second]),
        ]
        for (name, modifiers, expected) in cases {
            try await withEditor(
                seedBlocks: [CheckboxSeamFixture.first, CheckboxSeamFixture.second]
            ) { h in
                let window = try hosted(h)
                defer { window.teardown() }
                h.textView.setSelectedRange(
                    NSRange(location: h.model.index.range(ofEntryAt: 0).upperBound, length: 0))
                h.model.updateCaretContext()
                press(h, window.window, forward: true, modifiers: modifiers)
                await h.flush()
                #expect(try h.storeSlots().map { $0.text ?? "<gap>" } == expected,
                        "\(name) at the seam's leading side")
            }
        }
    }
}
