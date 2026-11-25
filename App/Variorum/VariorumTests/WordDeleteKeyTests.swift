//
//  WordDeleteKeyTests.swift
//  VariorumTests
//
//  VX-1076 (her report, 2026-11-24): *"sometimes, option backspace at the end
//  of a line will actually remove a word on the line previous."* Her first
//  recording, read frame by frame: a checklist in ONE block, the caret at the
//  end of its last item; three ⌥⌫ take "list", "your", "make"; the fourth,
//  with only "- [ ] " left before the caret, takes the marker, the line break
//  AND the last word of the line above.
//
//  **THE MECHANISM (the run record's BATCH E IMPLEMENTER RECORD,
//  `notes/plans/fixes/vx-1082-nov-24-fixes.md`).** ⌥⌫ is `deleteWordBackward:`
//  and neither of the app's text views had a word of its own about it, so the
//  range was AppKit's — `nextWord(from:forward:)` from the caret, which walks
//  over every non-word character, line breaks included, before it takes a
//  word. Whenever no word lies between the caret and its line's start (an
//  empty list item, a dash, an empty line, a line of punctuation) the press
//  crosses the break. ⌥⌦ (`deleteWordForward:`) is the mirror and has the
//  twin fault (measured: `foo|⏎bar` loses `⏎bar`). In Write, a press at a
//  BLOCK's start crosses the inter-block separator and the cross-block route's
//  clamp arm takes the previous block's last word.
//
//  **THE RULE (PROVISIONAL — her ticket comment):** a press never takes a word
//  from another line; with only a marker, spaces or punctuation before the
//  caret on its line it removes those; at a line's start it removes the line
//  break alone; and (P-1076-1) at a BLOCK's start it removes nothing, since
//  every road that removes a block separator is structural. ⌥⌦ mirrors it.
//
//  **How these pins press:** a real ⌥⌫ / ⌥⌦ key event handed to the view's
//  `keyDown` — AppKit's own key bindings → `doCommand(by:)` → the selector —
//  in an offscreen window that is never ordered in. Nothing here calls the
//  rule or the selector directly; the pure rule has its own suite.
//
//  RED ON OLD: every pin marked so below (on the pre-fix tree the press took
//  the other line's word); the GUARDs are green on both sides and say so.
//

import AppKit
import Foundation
import Observation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

/// The fixture: a checklist like hers (her own words stay in the recording).
enum WordDeleteFixture {
    /// The line ABOVE — the one a press must never reach.
    static let above = "- [ ] keep the notes nice to organize."
    /// Her last item, before the presses.
    static let item = "- [ ] make your list"
    static var checklist: String { above + "\n" + item }
    /// What the OLD tree left after a press crossed into `above`.
    static let crossed = "- [ ] keep the notes nice to "
}

/// The rig every editor pin here shares: the editor in an offscreen window
/// never ordered in (`EditorCaretPressTests`' shape), and the chord as a real
/// key event.
@MainActor
enum WordDeleteRig {
    static func mount(_ h: EditorHarness) throws -> NSWindow {
        let scrollView = try #require(h.textView.enclosingScrollView)
        scrollView.frame = NSRect(x: 0, y: 0, width: 720, height: 400)
        let window = NSWindow(
            contentRect: NSRect(x: -20_000, y: -20_000, width: 720, height: 400),
            styleMask: [.borderless], backing: .buffered, defer: true)
        window.isReleasedWhenClosed = false
        let content = NSView(frame: NSRect(x: 0, y: 0, width: 720, height: 400))
        content.addSubview(scrollView)
        window.contentView = content
        window.layoutIfNeeded()
        window.makeFirstResponder(h.textView)
        return window
    }

    static func close(_ window: NSWindow) {
        window.contentView = nil
        window.close()
    }

    /// ⌥⌫ (`forward: false`) or ⌥⌦ (`forward: true`) through `keyDown`.
    static func press(_ view: NSTextView, forward: Bool = false) {
        view.keyDown(
            with: CommandDeleteLineTraceTests.deleteEvent(
                forward: forward, modifiers: .option,
                windowNumber: view.window?.windowNumber ?? 0))
    }

    static func caret(_ h: EditorHarness, at offset: Int) {
        h.textView.setSelectedRange(NSRange(location: offset, length: 0))
        h.model.updateCaretContext()
    }

    static func caretAtEnd(_ h: EditorHarness) {
        caret(h, at: (h.textView.string as NSString).length)
    }

    /// A run-loop turn — synchronous, because `run(until:)` is unavailable
    /// from an async context (`PressPaneRig.pump`'s shape).
    static func pump() {
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
    }

    /// What AppKit ALONE does with the same chord at the same caret — a bare
    /// TK2 `NSTextView`, nothing of Variorum's wired, the same key event.
    static func systemAnswer(_ text: String, caret: Int, forward: Bool = false) -> String {
        let view = NSTextView(usingTextLayoutManager: true)
        view.isEditable = true
        view.isRichText = false
        view.string = text
        view.setSelectedRange(NSRange(location: caret, length: 0))
        view.keyDown(
            with: CommandDeleteLineTraceTests.deleteEvent(
                forward: forward, modifiers: .option, windowNumber: 0))
        return view.string
    }

    /// One press on a one-block note, from `caret` (nil = the end), flushed;
    /// answers what the surface and the store hold afterwards.
    static func onePress(
        on text: String, caret offset: Int? = nil, forward: Bool = false
    ) async throws -> (surface: String, store: [String]) {
        try await withEditor(seedBlocks: [text]) { h in
            let window = try mount(h)
            defer { close(window) }
            if let offset { caret(h, at: offset) } else { caretAtEnd(h) }
            press(h.textView, forward: forward)
            await h.flush()
            return (h.textView.string, try h.storeSlots().map { $0.text ?? "<gap>" })
        }
    }
}

// MARK: - Write — the probe's cases, through the real key path

@MainActor
@Suite("VX-1076 — ⌥⌫ in Write never takes a word from another line", .serialized)
struct WordDeleteInEditorTests {
    private typealias F = WordDeleteFixture
    private typealias Rig = WordDeleteRig

    /// **RED ON OLD — the empty list item** (`…organize.⏎- [ ] |`). The old
    /// tree left `- [ ] keep the notes nice to `.
    @Test func anEmptyListItemLosesOnlyItsMarker() async throws {
        let after = try await Rig.onePress(on: F.above + "\n- [ ] ")
        #expect(after.surface == F.above + "\n", "only the marker went (\(after.surface.debugDescription))")
        #expect(after.store == [F.above + "\n"])
    }

    /// **RED ON OLD — a dash alone** (`…organize.⏎- |`).
    @Test func aDashAloneLosesOnlyItsDash() async throws {
        let after = try await Rig.onePress(on: F.above + "\n- ")
        #expect(after.surface == F.above + "\n", "only the dash went (\(after.surface.debugDescription))")
        #expect(after.store == [F.above + "\n"])
    }

    /// **RED ON OLD — an empty line at the end** (`…organize.⏎|`): the line
    /// break alone goes and the caret rejoins the line above, its word intact.
    @Test func anEmptyLineLosesOnlyItsLineBreak() async throws {
        let after = try await Rig.onePress(on: F.above + "\n")
        #expect(after.surface == F.above, "only the break went (\(after.surface.debugDescription))")
        #expect(after.store == [F.above])
    }

    /// **RED ON OLD — an empty line in the middle** (`first line.⏎|⏎third line`):
    /// the old tree took `line.⏎` and left `first ⏎third line`.
    @Test func anEmptyLineInTheMiddleLosesOnlyItsLineBreak() async throws {
        let text = "first line.\n\nthird line"
        let after = try await Rig.onePress(on: text, caret: 12)
        #expect(after.surface == "first line.\nthird line", "\(after.surface.debugDescription)")
        #expect(after.store == ["first line.\nthird line"])
    }

    /// **RED ON OLD — a line of punctuation alone** (`…organize.⏎...|`).
    @Test func aPunctuationOnlyLineLosesOnlyItsPunctuation() async throws {
        let after = try await Rig.onePress(on: F.above + "\n...")
        #expect(after.surface == F.above + "\n", "\(after.surface.debugDescription)")
        #expect(after.store == [F.above + "\n"])
    }

    /// **GUARD (green on both sides) — the ordinary case stays the SYSTEM's,
    /// byte for byte.** Wherever a word lies on the caret's line, the press
    /// in Write leaves exactly what a bare `NSTextView` leaves for the same
    /// chord at the same caret: end of a word, mid-word, after a trailing
    /// space, a ticked box's `x`, the first line, and the forward chord.
    @Test func whereAWordIsOnTheLineThePressIsTheSystems() async throws {
        let marker = (F.above as NSString).length + 1  // the second line's start
        let cases: [(String, Int?, Bool)] = [
            (F.above + "\n- [ ] make", nil, false),
            (F.above + "\n- [ ] make", marker + 8, false),   // mid-word: `- [ ] ma|ke`
            (F.above + "\n- [ ] make ", nil, false),
            (F.above + "\n- [x] ", nil, false),
            (F.above, 17, false),                            // inside `notes`
            ("foo bar\nbaz", 3, true),
            (F.above + "\n- [ ] make", marker + 6, true),    // `- [ ] |make`
        ]
        for (text, offset, forward) in cases {
            let caret = offset ?? (text as NSString).length
            let system = Rig.systemAnswer(text, caret: caret, forward: forward)
            let after = try await Rig.onePress(on: text, caret: caret, forward: forward)
            let chord = forward ? "⌥⌦" : "⌥⌫"
            #expect(after.surface == system,
                    "\(text.debugDescription) @\(caret) \(chord): \(after.surface.debugDescription) vs the system's \(system.debugDescription)")
            #expect(after.store == [system])
        }
    }

    /// **RED ON OLD — her recording 1, four presses.** One block holding a
    /// checklist, the caret at the end of `- [ ] make your list`. The first
    /// three presses are the system's word deletes (9 → 8 → 7 → 6 words); the
    /// FOURTH, with only the marker before the caret, takes the marker and
    /// nothing else — the word count stays 6 and the line above is
    /// byte-identical at every step (the old tree took `organize.` with it:
    /// 6 → 5). Then the undo story: the press is an ordinary TEXT edit (the
    /// structural stack never moves), ⌘Z gives the marker back without ever
    /// having touched the line above, and undoing to the end restores her
    /// note exactly.
    @Test func herRecordingOneTheFourthPressTakesOnlyTheMarker() async throws {
        try await withEditor(seedBlocks: [F.checklist]) { h in
            let window = try Rig.mount(h)
            defer { Rig.close(window) }
            Rig.caretAtEnd(h)
            let expected = [
                F.above + "\n- [ ] make your ",
                F.above + "\n- [ ] make ",
                F.above + "\n- [ ] ",
                F.above + "\n",
            ]
            let words = [8, 7, 6, 6]
            #expect(TextMetrics.wordCount(h.textView.string) == 9)
            for (press, text) in expected.enumerated() {
                Rig.press(h.textView)
                await h.flush()
                Rig.pump()
                #expect(h.textView.string == text,
                        "press \(press + 1): \(h.textView.string.debugDescription)")
                #expect(TextMetrics.wordCount(h.textView.string) == words[press],
                        "press \(press + 1)'s word count")
                #expect(h.textView.string.hasPrefix(F.above),
                        "press \(press + 1) never touched the line above")
            }
            #expect(try h.storeSlots().map { $0.text ?? "<gap>" } == [F.above + "\n"])
            #expect(h.session.undoStack.depth == 0, "nothing structural happened")

            let undo = try #require(h.textView.undoManager)
            #expect(undo.canUndo, "the press is on the text-undo stack")
            undo.undo()
            Rig.pump()
            #expect(h.textView.string.hasPrefix(F.above + "\n- [ ] "),
                    "⌘Z brings the marker back (\(h.textView.string.debugDescription))")
            var steps = 0
            while undo.canUndo, steps < 10 {
                undo.undo()
                Rig.pump()
                steps += 1
            }
            #expect(h.textView.string == F.checklist, "undoing to the end restores her note")
            await h.flush()
            #expect(try h.storeSlots().map { $0.text ?? "<gap>" } == [F.checklist])
        }
    }

    /// **RED ON OLD — a ⇧⏎ line is a line like any other** (I4: both are
    /// in-block content). ⇧⏎ at the end of a block, then ⌥⌫ on the empty line
    /// it made: the break alone goes (the old tree took `line⏎`).
    @Test func aShiftReturnLineBehavesAsAnyInBlockLine() async throws {
        try await withEditor(seedBlocks: ["first line", "second block"]) { h in
            let window = try Rig.mount(h)
            defer { Rig.close(window) }
            Rig.caret(h, at: 10)
            h.textView.keyDown(
                with: ReturnKeyTraceTests.returnEvent(
                    shift: true, windowNumber: window.windowNumber))
            await h.flush()
            #expect(h.textView.string == "first line\n\nsecond block", "⇧⏎ made an in-block line")
            #expect(h.model.index.entries.count == 2, "inside the block, not a new one")
            Rig.press(h.textView)
            await h.flush()
            #expect(h.textView.string == "first line\nsecond block",
                    "\(h.textView.string.debugDescription)")
            #expect(try h.storeSlots().map { $0.text ?? "<gap>" } == ["first line", "second block"])
        }
    }
}

// MARK: - Write — the block seam (P-1076-1) and the forward twin

@MainActor
@Suite("VX-1076 — the word delete at a block seam, and ⌥⌦", .serialized)
struct WordDeleteSeamAndForwardTests {
    private typealias F = WordDeleteFixture
    private typealias Rig = WordDeleteRig

    /// **RED ON OLD — ⌥⌫ at a texted block's start does nothing.** The old
    /// tree crossed the separator and the cross-block route's clamp took the
    /// previous BLOCK's last word (`organize.`). A press here must not join
    /// the blocks either (every separator-removing road is structural), so
    /// it does what it does at the document's start: nothing.
    @Test func atATextedBlocksStartThePressDoesNothing() async throws {
        try await withEditor(seedBlocks: [F.above, "make your list"]) { h in
            let window = try Rig.mount(h)
            defer { Rig.close(window) }
            Rig.caret(h, at: h.model.index.range(ofEntryAt: 1).location)
            Rig.press(h.textView)
            await h.flush()
            #expect(h.model.index.entries.count == 2, "both blocks stand")
            #expect(try h.storeSlots().map { $0.text ?? "<gap>" } == [F.above, "make your list"])
            #expect(h.session.undoStack.depth == 0, "nothing structural happened")
        }
    }

    /// **RED ON OLD — the same at an EMPTY block's start.**
    @Test func atAnEmptyBlocksStartThePressDoesNothing() async throws {
        try await withEditor(seedBlocks: [F.above, ""]) { h in
            let window = try Rig.mount(h)
            defer { Rig.close(window) }
            Rig.caret(h, at: h.model.index.range(ofEntryAt: 1).location)
            Rig.press(h.textView)
            await h.flush()
            #expect(h.model.index.entries.count == 2, "both blocks stand")
            #expect(try h.storeSlots().map { $0.text ?? "<gap>" } == [F.above, ""])
            #expect(h.session.undoStack.depth == 0, "nothing structural happened")
        }
    }

    /// **RED ON OLD — the TWO-block checklist** (a pasted or imported list —
    /// one block per item): the first press takes the second block's marker
    /// and nothing else (the old tree sent that block to the Trash and cut
    /// `organize.`); the second press, now at that block's start, does
    /// nothing.
    @Test func aTwoBlockChecklistLosesTheMarkerAndThenStops() async throws {
        try await withEditor(seedBlocks: [F.above, "- [ ] "]) { h in
            let window = try Rig.mount(h)
            defer { Rig.close(window) }
            Rig.caretAtEnd(h)
            Rig.press(h.textView)
            await h.flush()
            #expect(try h.storeSlots().map { $0.text ?? "<gap>" } == [F.above, ""],
                    "the marker went, in its own block")
            Rig.pump()
            Rig.press(h.textView)
            await h.flush()
            #expect(h.model.index.entries.count == 2, "both blocks stand")
            #expect(try h.storeSlots().map { $0.text ?? "<gap>" } == [F.above, ""])
            #expect(h.session.undoStack.depth == 0, "nothing structural happened")
        }
    }

    /// **RED ON OLD — ⌥⌦ at a line's end takes the break alone** (the old
    /// tree took `⏎second`, the next line's word).
    @Test func forwardAtALinesEndTakesOnlyTheBreak() async throws {
        let after = try await Rig.onePress(on: "first line\nsecond", caret: 10, forward: true)
        #expect(after.surface == "first linesecond", "\(after.surface.debugDescription)")
        #expect(after.store == ["first linesecond"])
    }

    /// **RED ON OLD — ⌥⌦ before trailing spaces takes the spaces alone** (the
    /// old tree took `  ⏎bar`).
    @Test func forwardOverTrailingSpacesStopsAtTheLinesEnd() async throws {
        let after = try await Rig.onePress(on: "foo  \nbar", caret: 3, forward: true)
        #expect(after.surface == "foo\nbar", "\(after.surface.debugDescription)")
        #expect(after.store == ["foo\nbar"])
    }

    /// **RED ON OLD — ⌥⌦ at a block's END does nothing** (the old tree took
    /// the next block's word through the cross-block road).
    @Test func forwardAtABlocksEndDoesNothing() async throws {
        try await withEditor(seedBlocks: ["first", "second"]) { h in
            let window = try Rig.mount(h)
            defer { Rig.close(window) }
            Rig.caret(h, at: h.model.index.range(ofEntryAt: 0).upperBound)
            Rig.press(h.textView, forward: true)
            await h.flush()
            #expect(h.model.index.entries.count == 2, "both blocks stand")
            #expect(try h.storeSlots().map { $0.text ?? "<gap>" } == ["first", "second"])
            #expect(h.session.undoStack.depth == 0, "nothing structural happened")
        }
    }
}

// MARK: - The panes (Takes, Compare, Lenses, Read ▸ edit, … — one view, `PaneTextView`)

@MainActor @Observable
fileprivate final class WordDeletePane {
    var text: String
    var isLive = true

    init(text: String) { self.text = text }
}

fileprivate struct WordDeletePaneHost: View {
    let pane: WordDeletePane

    var body: some View {
        PaneSurfaceView(
            text: pane.text, isLive: pane.isLive,
            role: "word-delete", variantID: "v-word-delete",
            onEdit: { pane.text = $0 },
            caretOnGoingLive: .leave)
            .frame(width: 720)
    }
}

/// An offscreen window never ordered in (`PressPaneRig`'s shape).
@MainActor
fileprivate struct WordDeletePaneRig {
    let window: NSWindow
    let hosting: NSHostingView<WordDeletePaneHost>

    init(_ pane: WordDeletePane) {
        hosting = NSHostingView(rootView: WordDeletePaneHost(pane: pane))
        hosting.frame = NSRect(x: 0, y: 0, width: 720, height: 300)
        window = NSWindow(
            contentRect: NSRect(x: -20_000, y: -20_000, width: 720, height: 300),
            styleMask: [.borderless], backing: .buffered, defer: true)
        window.isReleasedWhenClosed = false
        let content = NSView(frame: NSRect(x: 0, y: 0, width: 720, height: 300))
        content.addSubview(hosting)
        window.contentView = content
    }

    func close() {
        window.contentView = nil
        window.close()
    }

    func settle() async {
        await HostLaunchSettle.wait()  // never pump into the host's launch
        for _ in 0..<8 {
            hosting.layoutSubtreeIfNeeded()
            window.displayIfNeeded()
            WordDeleteRig.pump()
            await Task.yield()
        }
    }

    var view: PaneTextView? { Self.find(in: hosting) }

    private static func find(in view: NSView) -> PaneTextView? {
        if let pane = view as? PaneTextView { return pane }
        for sub in view.subviews {
            if let found = find(in: sub) { return found }
        }
        return nil
    }

    /// One press on a LIVE pane holding `text`, from `caret` (nil = the end);
    /// answers what the pane's edit handed up.
    static func onePress(
        on text: String, caret: Int? = nil, forward: Bool = false
    ) async throws -> String {
        let pane = WordDeletePane(text: text)
        let rig = WordDeletePaneRig(pane)
        defer { rig.close() }
        await rig.settle()
        let view = try #require(rig.view, "the pane mounted")
        #expect(view.isEditable, "the pane is live")
        rig.window.makeFirstResponder(view)
        view.setSelectedRange(
            NSRange(location: caret ?? (text as NSString).length, length: 0))
        WordDeleteRig.press(view, forward: forward)
        await rig.settle()
        #expect(view.string == pane.text, "the pane handed its text up")
        return pane.text
    }
}

@MainActor
@Suite("VX-1076 — the pane twin", .serialized)
struct WordDeleteInPaneTests {
    private typealias F = WordDeleteFixture

    /// **RED ON OLD — the empty list item, in a take's pane.**
    @Test func anEmptyListItemInAPaneLosesOnlyItsMarker() async throws {
        let after = try await WordDeletePaneRig.onePress(on: F.above + "\n- [ ] ")
        #expect(after == F.above + "\n", "\(after.debugDescription)")
    }

    /// **RED ON OLD — an empty line, in a take's pane.**
    @Test func anEmptyLineInAPaneLosesOnlyItsLineBreak() async throws {
        let after = try await WordDeletePaneRig.onePress(on: F.above + "\n")
        #expect(after == F.above, "\(after.debugDescription)")
    }

    /// **RED ON OLD — ⌥⌦ at a line's end, in a take's pane.**
    @Test func forwardAtALinesEndInAPaneTakesOnlyTheBreak() async throws {
        let after = try await WordDeletePaneRig.onePress(
            on: "first line\nsecond", caret: 10, forward: true)
        #expect(after == "first linesecond", "\(after.debugDescription)")
    }

    /// **GUARD (green on both sides) — a word on the line is the system's.**
    @Test func whereAWordIsOnTheLineThePanesPressIsTheSystems() async throws {
        let text = F.above + "\n- [ ] make"
        let system = WordDeleteRig.systemAnswer(text, caret: (text as NSString).length)
        let after = try await WordDeletePaneRig.onePress(on: text)
        #expect(after == system, "\(after.debugDescription) vs \(system.debugDescription)")
    }
}
