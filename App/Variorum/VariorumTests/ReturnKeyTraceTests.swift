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

    /// Both keys OPEN THE TAIL at the exact document end (the ratified
    /// Phase 7 gesture — "Enter at the exact document end is the gesture
    /// that opens the tail"). This is the ONE context where a Return leads
    /// toward a block boundary, and it is where A15's real half lives.
    @Test func writeAtTheDocumentEndOpensTheTailUnderBothReturns() async throws {
        for shift in [false, true] {
            try await withEditor(seedBlocks: ["alpha"]) { h in
                let hosted = Self.host(try #require(h.textView.enclosingScrollView))
                defer { hosted.teardown() }
                hosted.window.makeFirstResponder(h.textView)

                let end = (h.documentText as NSString).length
                h.textView.setSelectedRange(NSRange(location: end, length: 0))
                h.textView.keyDown(
                    with: Self.returnEvent(shift: shift, windowNumber: hosted.window.windowNumber))

                #expect(h.model.hasOpenTail)
                #expect(h.model.index.entries.count == 1)
                // Nothing minted yet — the tail is surface-only.
                #expect(try h.storeSlots().map(\.text) == ["alpha"])
            }
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
