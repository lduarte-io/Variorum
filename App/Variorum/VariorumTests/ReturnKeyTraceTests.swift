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

    /// **RETIRED HALF (18c batch 2, her U-1):** this pin used to run BOTH
    /// keys through the loop and assert that both left the newline inside
    /// the block. The plain-⏎ half is gone with the ruling — *"I want it to
    /// work on newlines even when you're in the middle of write"* — and now
    /// lives, inverted, in `TypedReturnKeyTests`
    /// (`insideABlocksTextTheKeyDividesAtTheCaret`). What A15 ruled is
    /// untouched and is what remains here: **⇧⏎ types a newline that STAYS
    /// in the block** (I4 — internal newlines are content).
    @Test func writeMidBlockKeepsTheSoftReturnInsideTheBlock() async throws {
        try await withEditor(seedBlocks: ["alpha beta", "gamma"]) { h in
            let hosted = Self.host(try #require(h.textView.enclosingScrollView))
            defer { hosted.teardown() }
            hosted.window.makeFirstResponder(h.textView)

            h.textView.setSelectedRange(NSRange(location: 5, length: 0))
            h.textView.keyDown(
                with: Self.returnEvent(shift: true, windowNumber: hosted.window.windowNumber))
            await h.flush()

            let blocks = try h.storeSlots().map(\.text)
            #expect(blocks == ["alpha\n beta", "gamma"])
            #expect(h.model.index.entries.count == 2)
            #expect(!h.model.hasOpenTail)
        }
    }

    // MARK: - (b) Write, at the document end in PARAGRAPH mode

    /// **THE CONTEXT THIS FILE HAS NOW WATCHED CHANGE TWICE.** Phase 7
    /// ratified "⏎ at the exact document end opens the tail"; A15 split the
    /// two keys and left ⏎'s half of that gesture standing (the pin was
    /// `onlyPlainReturnOpensTheTailAtTheDocumentEnd`); **U-1 retires it
    /// outright — the key makes a BLOCK here, and no tail opens at all.**
    ///
    /// Both halves are asserted together because the pair is the point:
    /// neither key opens a tail any more, for opposite reasons (⏎ is
    /// structural now; ⇧⏎ was ruled content by A15).
    @Test func neitherKeyOpensTheTailAtTheDocumentEndAnyMore() async throws {
        // ⏎: U-1 — a real block below, minted, with the caret in it.
        try await withEditor(seedBlocks: ["alpha"]) { h in
            let hosted = Self.host(try #require(h.textView.enclosingScrollView))
            defer { hosted.teardown() }
            hosted.window.makeFirstResponder(h.textView)

            let end = (h.documentText as NSString).length
            h.textView.setSelectedRange(NSRange(location: end, length: 0))
            h.textView.keyDown(
                with: Self.returnEvent(shift: false, windowNumber: hosted.window.windowNumber))
            await h.flush()

            #expect(!h.model.hasOpenTail, "U-1: the tail gesture is retired from the key")
            #expect(h.model.index.entries.count == 2)
            #expect(try h.storeSlots().map(\.text) == ["alpha", ""])
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

    /// …and the tail region itself is NOT retired: it still opens from a
    /// newline arriving as TEXT — a paste or a drop of a bare newline at the
    /// document end — which is the road `BlockRangeIndex`'s `.openTail` arm
    /// and every crystallization pin below now travel. (A fresh note with no
    /// blocks is the other tail there has ever been, and it is untouched.)
    @Test func theTailStillOpensFromANewlineArrivingAsText() async throws {
        try await withEditor(seedBlocks: ["alpha"]) { h in
            h.type("\n", at: (h.documentText as NSString).length)
            #expect(h.model.hasOpenTail)
            #expect(h.model.index.entries.count == 1)
            // Nothing minted yet — the tail is surface-only.
            let stored = try h.storeSlots().map(\.text)
            #expect(stored == ["alpha"])
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

    /// **Opens the tail the one way that survives U-1** (18c batch 2): a
    /// newline arriving as TEXT — a paste or a drop of a bare newline at the
    /// document end — never the key, which now makes a block there. Every B2
    /// pin below used `plainReturn` for this and is REBUILT on this helper;
    /// the behaviour they pin (⇧⏎ inside an open tail) is unchanged, only
    /// the way the tail comes to exist is.
    private func openTailAsPastedText(_ h: EditorHarness) {
        h.type("\n", at: (h.documentText as NSString).length)
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
    /// **RE-POINTED (18c batch 2, U-1):** the second key's proof used to be
    /// "⏎ still opens the tail"; it is now "⏎ makes a block" — the same
    /// question (did the flag stick?) asked of the key's current meaning.
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
            await h.flush()
            #expect(try h.storeSlots().map(\.text) == ["alpha\n"],
                    "the soft newline is the block's content")

            plainReturn(h, window: hosted.window)
            await h.flush()
            #expect(!h.model.hasOpenTail, "…and the plain key makes a block — nothing stuck")
            #expect(try h.storeSlots().map(\.text) == ["alpha\n", ""])
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

    /// 13d cold review F-2 (red-on-old): STATE and HARDWARE flags are not
    /// meaning. AppKit sets `.capsLock` on every key event while caps lock
    /// is LATCHED, and `.numericPad`/`.function` on every keypad key — so
    /// an exactly-shift test over the whole device-independent word made
    /// ⇧⏎ silently not-the-gesture with caps lock on (the tail opened as
    /// if plain ⏎, a dead key with nothing spoken) and made the keypad-
    /// Enter arm unreachable from real hardware (judgment call 4's claim
    /// was true only of the tests' synthesized events). The mask is now
    /// the four meaning-bearing modifiers.
    @Test func capsLockAndKeypadFlagsDoNotDefeatTheSoftGesture() throws {
        func event(
            _ flags: NSEvent.ModifierFlags, _ chars: String, keyCode: UInt16
        ) -> NSEvent {
            NSEvent.keyEvent(
                with: .keyDown, location: .zero, modifierFlags: flags,
                timestamp: 0, windowNumber: 0, context: nil,
                characters: chars, charactersIgnoringModifiers: chars,
                isARepeat: false, keyCode: keyCode)!
        }
        // ⇧⏎ while caps lock is latched.
        #expect(EditorTextView.isSoftNewlineKey(
            event([.shift, .capsLock], "\r", keyCode: 36)))
        // Shift + keypad Enter, as real hardware reports it.
        #expect(EditorTextView.isSoftNewlineKey(
            event([.shift, .numericPad, .function], "\u{3}", keyCode: 76)))
        // …while the meaning-bearing exclusions stand exactly as before.
        #expect(!EditorTextView.isSoftNewlineKey(
            event([.shift, .command], "\r", keyCode: 36)))
        #expect(!EditorTextView.isSoftNewlineKey(
            event([.shift, .option, .capsLock], "\r", keyCode: 36)))
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

            openTailAsPastedText(h)
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

            openTailAsPastedText(h)
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

    /// 13d cold review F-1 (red-on-old): ⇧⏎ with the caret MID-tail lands
    /// the newline AT THE CARET — never at the document end. The tail is
    /// the standing state while she composes the trailing paragraph, so
    /// "type a sentence, arrow back, ⇧⏎" is ordinary fresh writing; the
    /// pre-fix code discarded the keystroke's offset and re-played the
    /// newline at `documentLength`, displacing it — and her caret — past
    /// everything she had typed after it. The bar is the ruling's own
    /// equality: idle-mint-then-⇧⏎ at this caret is a mid-BLOCK content
    /// newline at this caret.
    @Test func shiftReturnMidTailLandsTheNewlineAtTheCaretNotTheEnd() async throws {
        try await withEditor(seedBlocks: ["alpha"]) { h in
            let hosted = ReturnKeyTraceTests.host(try #require(h.textView.enclosingScrollView))
            defer { hosted.teardown() }
            hosted.window.makeFirstResponder(h.textView)

            openTailAsPastedText(h)
            h.textView.insertText("beta more", replacementRange: h.textView.selectedRange())
            #expect(h.model.hasOpenTail)

            // Arrow back: the caret sits after "beta", MID-tail.
            let caret = (h.documentText as NSString).length - (" more" as NSString).length
            h.textView.setSelectedRange(NSRange(location: caret, length: 0))
            softReturn(h, window: hosted.window)
            await h.flush()

            #expect(try h.storeSlots().map(\.text) == ["alpha", "beta\n more"],
                    "the newline lands at the caret, not the document end")
            #expect(h.textView.selectedRange().location == caret + 1,
                    "…and the caret stays where she was typing")
            #expect(!h.model.hasOpenTail, "the tail minted — B2's contract holds mid-tail too")
        }
    }

    /// A whitespace-only tail is the ratified never-mints class, so ⇧⏎
    /// takes the ORDINARY path there — where the standing leading-run
    /// attachment already makes the newline the preceding block's content.
    @Test func aWhitespaceOnlyTailTakesTheOrdinaryPath() async throws {
        try await withEditor(seedBlocks: ["alpha"]) { h in
            let hosted = ReturnKeyTraceTests.host(try #require(h.textView.enclosingScrollView))
            defer { hosted.teardown() }
            hosted.window.makeFirstResponder(h.textView)

            openTailAsPastedText(h)  // an EMPTY open tail
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
                openTailAsPastedText(h)
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
                openTailAsPastedText(h)
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

// MARK: - U-1 BUILT (18c batch 2): the Return key makes a block, anywhere

/// **HER ROW (the round's ledger row 1), in one sentence:** *"newlines to
/// make new blocks is NOT working properly at all… I was writing in Write,
/// but in the middle of Write, so I had paragraphs above and below. I want
/// it to work on newlines even when you're in the middle of write."*
///
/// These are the nine pins §5.1 of `notes/plans/use-report-round-2026-09-06.md`
/// names, driven as REAL KEY EVENTS through AppKit's interpretation path —
/// the same harness the A15 trace above uses, for the same reason: the whole
/// question is what the KEY does. Every one of them fails on the pre-batch
/// tree (the red-on-old runs are recorded in the batch record, R-2).
@MainActor
@Suite("U-1 — the Return key makes a block (18c batch 2)", .serialized)
struct TypedReturnKeyTests {
    private func hosted(_ h: EditorHarness) throws -> (window: NSWindow, teardown: () -> Void) {
        let hosted = ReturnKeyTraceTests.host(try #require(h.textView.enclosingScrollView))
        hosted.window.makeFirstResponder(h.textView)
        return hosted
    }

    private func caret(_ h: EditorHarness, entry i: Int, offset: Int) {
        h.textView.setSelectedRange(
            NSRange(location: h.model.index.range(ofEntryAt: i).location + offset, length: 0))
        h.model.updateCaretContext()
    }

    private func returnKey(_ h: EditorHarness, _ window: NSWindow, shift: Bool = false) {
        h.textView.keyDown(
            with: ReturnKeyTraceTests.returnEvent(shift: shift, windowNumber: window.windowNumber))
    }

    private func fan(_ h: EditorHarness, _ blockID: String) throws -> [Variant] {
        try h.database.read { db in
            try Queries.blockFan(db, blockID: blockID)
                .filter { $0.deletedAt == nil && $0.status == .active }
        }
    }

    // MARK: (1) her scenario — the end of a MIDDLE block

    /// The row itself: paragraphs above and below, the caret at the end of
    /// the middle one, ⏎, type — and the words land in a NEW BLOCK between
    /// them, where the shipped model could only ever have added a newline to
    /// "beta" (it had no position but the note's very end).
    @Test func theEndOfAMiddleBlockMakesTheBlockBelowAndTypingLandsInIt() async throws {
        try await withEditor(seedBlocks: ["alpha", "beta", "gamma"]) { h in
            let window = try hosted(h)
            defer { window.teardown() }

            caret(h, entry: 1, offset: 4)
            returnKey(h, window.window)
            await h.flush()
            h.textView.insertText("new", replacementRange: h.textView.selectedRange())
            await h.flush()

            #expect(try h.storeSlots().map(\.text) == ["alpha", "beta", "new", "gamma"])
            #expect(!h.model.hasOpenTail)
            #expect(h.model.caretBlockID == h.model.index.entries[2].blockID,
                    "the caret went into the block the key made")
        }
    }

    // MARK: (2) inside a block's text — the divide

    /// Inside the text the key DIVIDES at the caret, through the one
    /// snapping rule the planner already applies (S4-22), and the caret
    /// lands at the second half's start — "the paragraph I just started".
    ///
    /// **The seed is two words, deliberately.** §5.1 sketched this pin as
    /// `["alpha","beta","gamma"]` cut inside "beta" into `"be"`/`"ta"`; that
    /// cut is MID-WORD, which S4-22's word-edge floor forbids and the one
    /// snap brain would never place. Cutting at a word edge is the same pin
    /// with a legal cut — see the record's note.
    @Test func insideABlocksTextTheKeyDividesAtTheCaret() async throws {
        try await withEditor(seedBlocks: ["alpha", "beta gamma", "delta"]) { h in
            let window = try hosted(h)
            defer { window.teardown() }

            caret(h, entry: 1, offset: 4)  // "beta| gamma"
            returnKey(h, window.window)
            await h.flush()

            #expect(try h.storeSlots().map(\.text) == ["alpha", "beta", "gamma", "delta"])
            #expect(h.textView.selectedRange().location
                        == h.model.index.range(ofEntryAt: 2).location,
                    "the caret is at the second half's start")
            #expect(h.session.undoStack.topLabel == "Divide",
                    "…and ⌥⌘Z offers the divide back")
        }
    }

    // MARK: (3) a fanned block — the keep-on-top default (18c batch 1)

    /// The key's divide is the SAME divide the door runs, so a fanned block
    /// takes batch 1's keep-on-top road: the take she is in splits across
    /// both blocks and every other take rides WHOLE onto the top one.
    @Test func aFannedBlocksKeyDivideKeepsTheTakesOnTop() async throws {
        try await withEditor(
            seedBlocks: ["alpha", "Beta one. Beta two.", "gamma"]
        ) { h in
            let slots = try h.storeSlots()
            let middle = slots[1]
            let other = try h.session.operations.branchVariant(
                middle.blockID, from: try #require(middle.variantID))
            let otherText = "A wholly different middle paragraph."
            try h.session.operations.autosave(
                other.id, text: otherText, charDelta: otherText.count)
            try h.reload()

            let window = try hosted(h)
            defer { window.teardown() }
            caret(h, entry: 1, offset: 9)  // "Beta one.| Beta two."
            returnKey(h, window.window)
            await h.flush()

            let after = try h.storeSlots()
            #expect(after.map(\.text) == ["alpha", "Beta one.", "Beta two.", "gamma"])
            let topFan = try fan(h, after[1].blockID).map(\.workingText)
            let bottomFan = try fan(h, after[2].blockID).map(\.workingText)
            #expect(topFan == ["Beta one.", otherText],
                    "the top block keeps the other take, whole")
            #expect(bottomFan == ["Beta two."],
                    "the bottom block carries its half alone")
        }
    }

    // MARK: (4) the last block's end

    @Test func theLastBlocksEndMakesABlockAndNoTailOpens() async throws {
        try await withEditor(seedBlocks: ["alpha", "beta"]) { h in
            let window = try hosted(h)
            defer { window.teardown() }

            caret(h, entry: 1, offset: 4)
            returnKey(h, window.window)
            await h.flush()

            #expect(try h.storeSlots().map(\.text) == ["alpha", "beta", ""])
            #expect(!h.model.hasOpenTail, "the tail road is retired from the key")
            #expect(h.model.index.entries.count == 3)
        }
    }

    // MARK: (5) the empty block — U-19 (2)

    /// Two Returns in one breath make ONE empty block: the act re-derives on
    /// its own turn, so the second one sees the block the first one made and
    /// takes the ruled no-op there (*"we won't reintroduce it with
    /// paragraphs disappearing"* cuts both ways — nothing vanishes, and
    /// nothing piles up). This is also the compose-not-race pin.
    @Test func twoQuickReturnsMakeOneEmptyBlockNotTwo() async throws {
        try await withEditor(seedBlocks: ["alpha", "gamma"]) { h in
            let window = try hosted(h)
            defer { window.teardown() }

            caret(h, entry: 0, offset: 5)
            returnKey(h, window.window)
            returnKey(h, window.window)
            await h.flush()

            #expect(try h.storeSlots().map(\.text) == ["alpha", "", "gamma"])
            #expect(h.model.caretBlockID == h.model.index.entries[1].blockID)
        }
    }

    /// …and the empty block she leaves behind STAYS (U-19 (2)) — nothing
    /// sweeps it, on the key or afterwards.
    @Test func theEmptyBlockStaysWhenSheWalksAway() async throws {
        try await withEditor(seedBlocks: ["alpha", "gamma"]) { h in
            let window = try hosted(h)
            defer { window.teardown() }

            caret(h, entry: 0, offset: 5)
            returnKey(h, window.window)
            await h.flush()
            caret(h, entry: 2, offset: 0)   // she goes elsewhere
            h.model.idleMintTail()
            await h.flush()

            #expect(try h.storeSlots().map(\.text) == ["alpha", "", "gamma"])
        }
    }

    // MARK: (6) ⇧⏎ — content, always (A15 stands)

    /// A15's ruling is untouched by U-1: mid-block, ⇧⏎ is the blank line
    /// inside the paragraph (her U-19 (3): *"shift return is good for a
    /// blank line within a paragraph"*).
    @Test func softReturnMidBlockIsStillContent() async throws {
        try await withEditor(seedBlocks: ["alpha beta", "gamma"]) { h in
            let window = try hosted(h)
            defer { window.teardown() }

            caret(h, entry: 0, offset: 5)
            returnKey(h, window.window, shift: true)
            await h.flush()

            #expect(try h.storeSlots().map(\.text) == ["alpha\n beta", "gamma"])
        }
    }

    // MARK: (7) the chip OFF

    /// Her U-19 (3), answered: *"users can also turn off newlines make
    /// blocks if they want, right?"* — under `one_block` the key is content
    /// again, in the middle of the note exactly as at its end.
    @Test func theChipOffKeepsTheKeyAsContentInTheMiddleToo() async throws {
        try await withEditor(profile: .journal, seedBlocks: ["alpha beta", "gamma"]) { h in
            #expect(h.model.header?.effectiveSegmentation == .oneBlock)
            let window = try hosted(h)
            defer { window.teardown() }

            caret(h, entry: 0, offset: 5)
            returnKey(h, window.window)
            await h.flush()

            #expect(try h.storeSlots().map(\.text) == ["alpha\n beta", "gamma"])
            #expect(h.model.index.entries.count == 2)
        }
    }

    // MARK: (8) lists — 13k K5 keeps the key, and the exit composes

    /// Inside a list ⏎ continues the list (lists stay whole — her U-19 (4));
    /// a second ⏎ on the now-empty item ends the list AND makes the block.
    /// The two intercepts compose in that order.
    @Test func aListItemsReturnContinuesTheListAndTheEmptyItemEndsItAndMakesTheBlock()
        async throws
    {
        try await withEditor(seedBlocks: ["- one", "gamma"]) { h in
            let window = try hosted(h)
            defer { window.teardown() }

            caret(h, entry: 0, offset: 5)
            returnKey(h, window.window)
            await h.flush()
            #expect(try h.storeSlots().map(\.text) == ["- one\n- ", "gamma"],
                    "13k K5: the list continued, in the same block")
            #expect(h.model.index.entries.count == 2)

            returnKey(h, window.window)
            await h.flush()
            #expect(try h.storeSlots().map(\.text) == ["- one\n", "", "gamma"],
                    "the empty item ended the list AND the key made the block")
            #expect(h.model.caretBlockID == h.model.index.entries[1].blockID)
        }
    }

    // MARK: (9) her S1 scenario

    /// *⏎, pause, click at the end of the last line, ⏎, type.* Every step
    /// ends with a real block and never a loose newline: the first key makes
    /// the block, the pause has no tail left to mint, the second key finds
    /// an empty block and does nothing, and the words land in that block —
    /// never appended to "beta", never "several new lines".
    @Test func herS1ScenarioMakesABlockAndNeverALooseNewline() async throws {
        try await withEditor(seedBlocks: ["alpha", "beta"]) { h in
            let window = try hosted(h)
            defer { window.teardown() }

            caret(h, entry: 1, offset: 4)
            returnKey(h, window.window)
            await h.flush()
            #expect(!h.model.hasOpenTail)

            h.model.idleMintTail()          // the 2 s clock: nothing to mint
            await h.flush()
            #expect(try h.storeSlots().map(\.text) == ["alpha", "beta", ""])

            // The click at the end of the last line.
            h.textView.setSelectedRange(
                NSRange(location: (h.documentText as NSString).length, length: 0))
            h.model.updateCaretContext()
            returnKey(h, window.window)
            await h.flush()
            #expect(try h.storeSlots().map(\.text) == ["alpha", "beta", ""],
                    "no second empty block")

            h.textView.insertText("new", replacementRange: h.textView.selectedRange())
            await h.flush()
            #expect(try h.storeSlots().map(\.text) == ["alpha", "beta", "new"])
            #expect(!h.model.hasOpenTail)
        }
    }

    /// **THE TRAP (§4.1) — the same scenario when an EMPTY TAIL is the state
    /// she comes back to.** The idle mint leaves one behind (it mints the
    /// paragraph and keeps the run's last newline open), the tail road plans
    /// nothing over `""`, and the shipped key answered it with the k−1
    /// attachment — a newline on the END of "beta", her image 4. The act
    /// closes that render artifact and makes the block instead.
    @Test func theEmptyTailTrapClosesAndMakesABlock() async throws {
        try await withEditor(seedBlocks: ["alpha"]) { h in
            let window = try hosted(h)
            defer { window.teardown() }

            // The state she reported: a paragraph typed at the end, ⏎, a
            // pause — reproduced with the newline arriving as text, which is
            // the only road left to the tail.
            h.type("\n", at: (h.documentText as NSString).length)
            h.textView.insertText("beta", replacementRange: h.textView.selectedRange())
            h.type("\n", at: (h.documentText as NSString).length)
            h.model.idleMintTail()
            await h.flush()
            #expect(try h.storeSlots().map(\.text) == ["alpha", "beta"])
            #expect(h.model.hasOpenTail && h.model.index.tailLength == 0,
                    "the empty tail the trap lives in")

            h.textView.setSelectedRange(
                NSRange(location: (h.documentText as NSString).length, length: 0))
            returnKey(h, window.window)
            await h.flush()

            #expect(!h.model.hasOpenTail, "the render artifact is gone")
            #expect(try h.storeSlots().map(\.text) == ["alpha", "beta", ""],
                    "and a real block stands where the newline used to go")
            h.textView.insertText("gamma", replacementRange: h.textView.selectedRange())
            await h.flush()
            #expect(try h.storeSlots().map(\.text) == ["alpha", "beta", "gamma"])
        }
    }

    // MARK: The start of a block — "push this paragraph down"

    /// §5.1's choice, taken as its first option: an empty block ABOVE, the
    /// caret staying in the text block.
    @Test func theStartOfABlockPushesItDownWithAnEmptyBlockAbove() async throws {
        try await withEditor(seedBlocks: ["alpha", "beta"]) { h in
            let window = try hosted(h)
            defer { window.teardown() }

            caret(h, entry: 1, offset: 0)
            returnKey(h, window.window)
            await h.flush()

            #expect(try h.storeSlots().map(\.text) == ["alpha", "", "beta"])
            #expect(h.model.caretBlockID == h.model.index.entries[2].blockID,
                    "the caret stays with her paragraph")
        }
    }

    // MARK: A fresh note is all tail — untouched

    /// The one place the tail still does the work: a note with no blocks
    /// yet. Typing paragraphs there crystallizes exactly as it always did —
    /// the same promise by the other road.
    @Test func aFreshNoteStillCrystallizesAsSheTypes() async throws {
        try await withEditor { h in
            let window = try hosted(h)
            defer { window.teardown() }

            h.textView.insertText("alpha", replacementRange: h.textView.selectedRange())
            returnKey(h, window.window)
            h.textView.insertText("beta", replacementRange: h.textView.selectedRange())
            await h.flush()

            #expect(try h.storeSlots().map(\.text) == ["alpha"],
                    "the finished paragraph crystallized as she typed past it")
            #expect(h.model.hasOpenTail, "…and the one she is typing is still the tail")
        }
    }
}
