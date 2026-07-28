//
//  ReturnKeyTraceTests.swift
//  VariorumTests
//
//  13d batch 4 (A15) — THE TRACE, pinned rather than asserted.
//
//  Her row: *"Shift-Enter staying in the block in BOTH editors"*. Before any
//  design, the brief demanded a trace of what ⏎ and ⇧⏎ each do TODAY in the
//  five contexts the batch names. These pins ARE that trace: they drive REAL
//  key events through the real AppKit interpretation path (a window, a first
//  responder, `keyDown` → `interpretKeyEvents` → the standard key bindings)
//  rather than calling `insertText`, because the whole question is what the
//  KEY does, not what the text pipeline does with a string.
//
//  The trace's finding, recorded here so a future reader gets it from the
//  code: macOS's StandardKeyBinding.dict binds `\r` (Return) to
//  `insertNewline:` and gives Shift-Return NO binding of its own — so the
//  shift falls away and ⇧⏎ dispatches `insertNewline:` too. Both keys type
//  the same character, and every context below therefore behaves identically
//  under both.
//

import AppKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("Return / Shift-Return trace (13d A15)", .serialized)
struct ReturnKeyTraceTests {
    /// A real Return key event (keyCode 36), optionally with shift held.
    static func returnEvent(shift: Bool, windowNumber: Int) -> NSEvent {
        NSEvent.keyEvent(
            with: .keyDown,
            location: .zero,
            modifierFlags: shift ? .shift : [],
            timestamp: 0,
            windowNumber: windowNumber,
            context: nil,
            characters: "\r",
            charactersIgnoringModifiers: "\r",
            isARepeat: false,
            keyCode: 36)!
    }

    /// Hosts `view` in a real key window and returns a teardown closure.
    static func host(_ view: NSView) -> (window: NSWindow, teardown: () -> Void) {
        let window = NSWindow(
            contentRect: NSRect(x: 80, y: 80, width: 600, height: 400),
            styleMask: [.titled, .resizable], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = view
        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(view)
        return (window, {
            window.orderOut(nil)
            window.close()
        })
    }

    /// Records the command selectors a text view dispatches.
    @MainActor
    final class CommandSpy: NSObject, NSTextViewDelegate {
        var commands: [String] = []
        func textView(
            _ textView: NSTextView, doCommandBy commandSelector: Selector
        ) -> Bool {
            commands.append(NSStringFromSelector(commandSelector))
            return false  // let the view perform it
        }
    }

    // MARK: - The dispatch fact both editors inherit

    /// ⏎ and ⇧⏎ dispatch the SAME selector and type the SAME character.
    /// This is the trace's headline and the reason four of the five
    /// contexts needed no work: there is no "soft return" key on this
    /// keyboard layout to give different meaning to.
    @Test func shiftReturnDispatchesInsertNewlineExactlyAsReturnDoes() throws {
        let view = NSTextView(frame: NSRect(x: 0, y: 0, width: 500, height: 300))
        let spy = CommandSpy()
        view.delegate = spy
        view.isEditable = true
        view.isRichText = false
        let hosted = Self.host(view)
        defer { hosted.teardown() }

        view.string = "alpha"
        view.setSelectedRange(NSRange(location: 5, length: 0))
        view.keyDown(with: Self.returnEvent(shift: false, windowNumber: hosted.window.windowNumber))
        let afterPlain = view.string
        let plainCommands = spy.commands

        spy.commands = []
        view.string = "alpha"
        view.setSelectedRange(NSRange(location: 5, length: 0))
        view.keyDown(with: Self.returnEvent(shift: true, windowNumber: hosted.window.windowNumber))
        let afterShift = view.string
        let shiftCommands = spy.commands

        #expect(plainCommands == ["insertNewline:"])
        #expect(shiftCommands == ["insertNewline:"])
        #expect(afterPlain == "alpha\n")
        #expect(afterShift == "alpha\n")
        // …and the character is a plain LF, not U+2028 (which
        // `insertLineBreak:` — Control-Return — would have produced).
        #expect(!afterShift.unicodeScalars.contains { $0.value == 0x2028 })
    }

    /// Control-Return is the one Return variant macOS binds differently —
    /// recorded so the trace's negative space is on the record too (nothing
    /// in the app wires it; it is AppKit's).
    @Test func controlReturnIsTheOneBoundDifferently() throws {
        let view = NSTextView(frame: NSRect(x: 0, y: 0, width: 500, height: 300))
        let spy = CommandSpy()
        view.delegate = spy
        view.isEditable = true
        view.isRichText = false
        let hosted = Self.host(view)
        defer { hosted.teardown() }

        view.string = "alpha"
        view.setSelectedRange(NSRange(location: 5, length: 0))
        let event = NSEvent.keyEvent(
            with: .keyDown, location: .zero, modifierFlags: .control,
            timestamp: 0, windowNumber: hosted.window.windowNumber, context: nil,
            characters: "\r", charactersIgnoringModifiers: "\r",
            isARepeat: false, keyCode: 36)!
        view.keyDown(with: event)
        #expect(spy.commands == ["insertLineBreak:"])
    }

    // MARK: - (a) Write, mid-block

    /// Both keys type a newline that STAYS in the block (I4 — internal
    /// newlines are content). Nothing to build for A15 here.
    @Test func writeMidBlockKeepsBothReturnsInsideTheBlock() async throws {
        for shift in [false, true] {
            try await withEditor(seedBlocks: ["alpha beta", "gamma"]) { h in
                let hosted = Self.host(try #require(h.textView.enclosingScrollView))
                defer { hosted.teardown() }
                hosted.window.makeFirstResponder(h.textView)

                h.textView.setSelectedRange(NSRange(location: 5, length: 0))
                h.textView.keyDown(
                    with: Self.returnEvent(shift: shift, windowNumber: hosted.window.windowNumber))
                await h.flush()

                let blocks = try h.storeSlots().map(\.text)
                #expect(blocks == ["alpha\n beta", "gamma"])
                #expect(h.model.index.entries.count == 2)
                #expect(!h.model.hasOpenTail)
            }
        }
    }

    // MARK: - (b) Write, at the document end in PARAGRAPH mode

    /// THE ONE CONTEXT THE BUILD CHANGED. Before A15 both keys opened the
    /// tail here (the ratified Phase 7 gesture — "Enter at the exact
    /// document end is the gesture that opens the tail"), and this pin
    /// asserted exactly that; the ruled build split them, so it now
    /// asserts the split. **⏎ still opens the tail — untouched** — and
    /// ⇧⏎ declines it, which is B1. Recorded as a RULED FLIP, not a bug
    /// fix; the flip's own end-to-end behaviour is `SoftNewlineTests`'.
    @Test func onlyPlainReturnOpensTheTailAtTheDocumentEnd() async throws {
        // ⏎: the ratified gesture, byte-unchanged.
        try await withEditor(seedBlocks: ["alpha"]) { h in
            let hosted = Self.host(try #require(h.textView.enclosingScrollView))
            defer { hosted.teardown() }
            hosted.window.makeFirstResponder(h.textView)

            let end = (h.documentText as NSString).length
            h.textView.setSelectedRange(NSRange(location: end, length: 0))
            h.textView.keyDown(
                with: Self.returnEvent(shift: false, windowNumber: hosted.window.windowNumber))

            #expect(h.model.hasOpenTail)
            #expect(h.model.index.entries.count == 1)
            // Nothing minted yet — the tail is surface-only.
            let stored = try h.storeSlots().map(\.text)
            #expect(stored == ["alpha"])
        }
        // ⇧⏎: no tail; the newline is the last block's content (A15/B1).
        try await withEditor(seedBlocks: ["alpha"]) { h in
            let hosted = Self.host(try #require(h.textView.enclosingScrollView))
            defer { hosted.teardown() }
            hosted.window.makeFirstResponder(h.textView)

            let end = (h.documentText as NSString).length
            h.textView.setSelectedRange(NSRange(location: end, length: 0))
            h.textView.keyDown(
                with: Self.returnEvent(shift: true, windowNumber: hosted.window.windowNumber))
            await h.flush()

            #expect(!h.model.hasOpenTail)
            let stored = try h.storeSlots().map(\.text)
            #expect(stored == ["alpha\n"])
        }
    }

    // MARK: - (c) Write under one_block

    /// Under `one_block` neither key can open a tail (`verdict` excludes
    /// `.oneBlock` explicitly) — the newline is content of the last block,
    /// exactly what A15 asks for, already true.
    @Test func writeUnderOneBlockKeepsBothReturnsAsContent() async throws {
        for shift in [false, true] {
            try await withEditor(profile: .journal, seedBlocks: ["alpha"]) { h in
                #expect(h.model.header?.effectiveSegmentation == .oneBlock)
                let hosted = Self.host(try #require(h.textView.enclosingScrollView))
                defer { hosted.teardown() }
                hosted.window.makeFirstResponder(h.textView)

                let end = (h.documentText as NSString).length
                h.textView.setSelectedRange(NSRange(location: end, length: 0))
                h.textView.keyDown(
                    with: Self.returnEvent(shift: shift, windowNumber: hosted.window.windowNumber))
                await h.flush()

                #expect(!h.model.hasOpenTail)
                #expect(try h.storeSlots().map(\.text) == ["alpha\n"])
            }
        }
    }

    // MARK: - (d) A take pane (Takes / Lenses)

    /// A pane is single-block by construction: both keys type a newline into
    /// the take's buffer and the edit is reported as ordinary content. There
    /// is no tail and no crystallization on a board — nothing to build.
    @Test func aTakePaneKeepsBothReturnsInTheTake() throws {
        for shift in [false, true] {
            let view = PaneTextView.makeTakeSurface()
            view.frame = NSRect(x: 0, y: 0, width: 400, height: 200)
            view.isEditable = true
            let spy = CommandSpy()
            view.delegate = spy
            let hosted = Self.host(view)
            defer { hosted.teardown() }
            hosted.window.makeFirstResponder(view)

            view.string = "alpha"
            view.setSelectedRange(NSRange(location: 5, length: 0))
            view.keyDown(
                with: Self.returnEvent(shift: shift, windowNumber: hosted.window.windowNumber))
            #expect(spy.commands == ["insertNewline:"])
            #expect(view.string == "alpha\n")
        }
    }
}

// MARK: - A15 BUILT (the architect's ruling: option B, both halves)

/// The contract in one sentence: **⇧⏎ ends with the caret inside a real
/// block and the newline as that block's content.** No provenance memory
/// anywhere — a newline that is block content the moment it exists can
/// never become a segmentation boundary (I4 is absolute; crystallization
/// never touches existing blocks).
@MainActor
@Suite("A15 — shift-Return stays in the block (13d batch 4)", .serialized)
struct SoftNewlineTests {
    private func softReturn(_ h: EditorHarness, window: NSWindow) {
        h.textView.keyDown(
            with: ReturnKeyTraceTests.returnEvent(shift: true, windowNumber: window.windowNumber))
    }

    private func plainReturn(_ h: EditorHarness, window: NSWindow) {
        h.textView.keyDown(
            with: ReturnKeyTraceTests.returnEvent(shift: false, windowNumber: window.windowNumber))
    }

    // MARK: B1 — the exact document end, no open tail

    /// ⇧⏎ at the document end lands the newline INSIDE the last block, no
    /// tail opens, and typing afterwards extends that same block.
    @Test func shiftReturnAtTheDocumentEndStaysInTheLastBlock() async throws {
        try await withEditor(seedBlocks: ["alpha", "beta"]) { h in
            let hosted = ReturnKeyTraceTests.host(try #require(h.textView.enclosingScrollView))
            defer { hosted.teardown() }
            hosted.window.makeFirstResponder(h.textView)

            h.textView.setSelectedRange(
                NSRange(location: (h.documentText as NSString).length, length: 0))
            softReturn(h, window: hosted.window)
            #expect(!h.model.hasOpenTail, "B1: the open-tail gesture is declined")
            #expect(h.model.index.entries.count == 2)

            // …and typing after it extends the SAME block, never a new one.
            h.textView.insertText("more", replacementRange: h.textView.selectedRange())
            await h.flush()
            #expect(try h.storeSlots().map(\.text) == ["alpha", "beta\nmore"])
            #expect(!h.model.hasOpenTail)
        }
    }

    /// Rider 3's two-keys pin: the flag is per-keystroke and self-clearing,
    /// so ⇧⏎ then plain ⏎ behave as two different keys in the same breath.
    @Test func softThenPlainReturnBehaveAsTwoDifferentKeys() async throws {
        try await withEditor(seedBlocks: ["alpha"]) { h in
            let hosted = ReturnKeyTraceTests.host(try #require(h.textView.enclosingScrollView))
            defer { hosted.teardown() }
            hosted.window.makeFirstResponder(h.textView)

            h.textView.setSelectedRange(
                NSRange(location: (h.documentText as NSString).length, length: 0))
            softReturn(h, window: hosted.window)
            #expect(!h.model.hasOpenTail, "⇧⏎ stayed in the block")
            #expect(!h.textView.isSoftNewline, "the flag cleared with the keystroke")

            plainReturn(h, window: hosted.window)
            #expect(h.model.hasOpenTail, "⏎ still opens the tail — nothing stuck")
            await h.flush()
            let stored = try h.storeSlots().map(\.text)
            #expect(stored == ["alpha\n"], "the soft newline is the block's content")
        }
    }

    /// Control-Return keeps AppKit's own `insertLineBreak:` — the soft
    /// gesture claims SHIFT-Return and nothing else (rider 3).
    @Test func controlReturnIsNotTheSoftGesture() throws {
        let view = EditorTextView.makeEditor().textView
        let hosted = ReturnKeyTraceTests.host(view)
        defer { hosted.teardown() }
        for flags in [NSEvent.ModifierFlags.control, [.command, .shift], [.option, .shift], []] {
            let event = NSEvent.keyEvent(
                with: .keyDown, location: .zero, modifierFlags: flags,
                timestamp: 0, windowNumber: hosted.window.windowNumber, context: nil,
                characters: "\r", charactersIgnoringModifiers: "\r",
                isARepeat: false, keyCode: 36)!
            #expect(!EditorTextView.isSoftNewlineKey(event))
        }
        let soft = ReturnKeyTraceTests.returnEvent(
            shift: true, windowNumber: hosted.window.windowNumber)
        #expect(EditorTextView.isSoftNewlineKey(soft), "non-vacuity: shift alone IS the gesture")
    }

    // MARK: B2 — inside an open tail

    /// ⇧⏎ in an open tail mints the tail (the ratified idle-mint, ~2 s
    /// early) and the newline lands in the block that just became — and
    /// the FINAL STRUCTURE equals idle-mint-then-type, which is the
    /// ruling's own equality bar.
    @Test func shiftReturnInATailMintsAndStaysAndMatchesTheIdleMintPath() async throws {
        // (i) the ⇧⏎ road.
        var viaSoftReturn: [String?] = []
        try await withEditor(seedBlocks: ["alpha"]) { h in
            let hosted = ReturnKeyTraceTests.host(try #require(h.textView.enclosingScrollView))
            defer { hosted.teardown() }
            hosted.window.makeFirstResponder(h.textView)

            h.textView.setSelectedRange(
                NSRange(location: (h.documentText as NSString).length, length: 0))
            plainReturn(h, window: hosted.window)   // opens the tail
            h.textView.insertText("beta", replacementRange: h.textView.selectedRange())
            #expect(h.model.hasOpenTail)

            softReturn(h, window: hosted.window)
            await h.flush()
            h.textView.insertText("gamma", replacementRange: h.textView.selectedRange())
            await h.flush()
            viaSoftReturn = try h.storeSlots().map(\.text)
        }

        // (ii) the road the 2 s clock would have taken: mint, then type.
        var viaIdleMint: [String?] = []
        try await withEditor(seedBlocks: ["alpha"]) { h in
            let hosted = ReturnKeyTraceTests.host(try #require(h.textView.enclosingScrollView))
            defer { hosted.teardown() }
            hosted.window.makeFirstResponder(h.textView)

            h.textView.setSelectedRange(
                NSRange(location: (h.documentText as NSString).length, length: 0))
            plainReturn(h, window: hosted.window)
            h.textView.insertText("beta", replacementRange: h.textView.selectedRange())
            h.model.idleMintTail()
            await h.flush()
            // The newline the soft key would have typed, then the word.
            h.textView.setSelectedRange(
                NSRange(location: h.model.index.documentLength, length: 0))
            h.textView.withSoftNewline {
                h.textView.insertText("\n", replacementRange: h.textView.selectedRange())
            }
            h.textView.insertText("gamma", replacementRange: h.textView.selectedRange())
            await h.flush()
            viaIdleMint = try h.storeSlots().map(\.text)
        }

        #expect(viaSoftReturn == viaIdleMint, "the ruling's equality bar")
        #expect(viaSoftReturn == ["alpha", "beta\ngamma"],
                "the tail became a block and the soft newline is inside it")
    }

    /// A whitespace-only tail is the ratified never-mints class, so ⇧⏎
    /// takes the ORDINARY path there — where the standing leading-run
    /// attachment already makes the newline the preceding block's content.
    @Test func aWhitespaceOnlyTailTakesTheOrdinaryPath() async throws {
        try await withEditor(seedBlocks: ["alpha"]) { h in
            let hosted = ReturnKeyTraceTests.host(try #require(h.textView.enclosingScrollView))
            defer { hosted.teardown() }
            hosted.window.makeFirstResponder(h.textView)

            h.textView.setSelectedRange(
                NSRange(location: (h.documentText as NSString).length, length: 0))
            plainReturn(h, window: hosted.window)  // an EMPTY open tail
            #expect(h.model.hasOpenTail)
            #expect(!h.model.mintableTail, "nothing mintable — the never-mints class")

            softReturn(h, window: hosted.window)
            await h.flush()
            // No block was minted; the newline is the preceding block's
            // trailing content (the k−1 attachment, unchanged).
            let stored = try h.storeSlots().map(\.text)
            #expect(stored == ["alpha\n"])
            #expect(h.model.index.entries.count == 1)
        }
    }

    // MARK: Rider 2 — what undo offers, MEASURED, with idle-mint parity

    /// Rider 2: whatever ⌥⌘Z offers after the 2 s clock's mint is exactly
    /// what it offers after a ⇧⏎ mint. This pin MEASURES both rather than
    /// claiming either — the batch record quotes what it found.
    @Test func undoAfterASoftReturnMintMatchesTheIdleMintExactly() async throws {
        func undoStateAfterSoftReturn() async throws -> (depth: Int, label: String?) {
            try await withEditor(seedBlocks: ["alpha"]) { h in
                let hosted = ReturnKeyTraceTests.host(try #require(h.textView.enclosingScrollView))
                defer { hosted.teardown() }
                hosted.window.makeFirstResponder(h.textView)
                h.textView.setSelectedRange(
                    NSRange(location: (h.documentText as NSString).length, length: 0))
                plainReturn(h, window: hosted.window)
                h.textView.insertText("beta", replacementRange: h.textView.selectedRange())
                softReturn(h, window: hosted.window)
                await h.flush()
                return (h.session.undoStack.depth, h.session.undoStack.topLabel)
            }
        }
        func undoStateAfterIdleMint() async throws -> (depth: Int, label: String?) {
            try await withEditor(seedBlocks: ["alpha"]) { h in
                let hosted = ReturnKeyTraceTests.host(try #require(h.textView.enclosingScrollView))
                defer { hosted.teardown() }
                hosted.window.makeFirstResponder(h.textView)
                h.textView.setSelectedRange(
                    NSRange(location: (h.documentText as NSString).length, length: 0))
                plainReturn(h, window: hosted.window)
                h.textView.insertText("beta", replacementRange: h.textView.selectedRange())
                h.model.idleMintTail()
                await h.flush()
                return (h.session.undoStack.depth, h.session.undoStack.topLabel)
            }
        }
        let soft = try await undoStateAfterSoftReturn()
        let idle = try await undoStateAfterIdleMint()
        #expect(soft.depth == idle.depth, "PARITY: the same undo story, both roads")
        #expect(soft.label == idle.label)
        // …and what that story IS, pinned rather than narrated: a
        // crystallization mint — by the clock or by ⇧⏎ — registers NO
        // structural undo entry at all. Segmentation is the machinery
        // doing its job, not an author gesture, so ⌥⌘Z offers nothing new
        // after either road. The record states exactly this and no more.
        #expect(soft.depth == 0)
        #expect(soft.label == nil)
    }
}
