//
//  CaptureSurfaceTests.swift
//  VariorumTests
//
//  13u3 UNIT C — the Mac's ONE capture surface, and its ONE key rule
//  (her R-13u-4: *"the capture surface holds MANY paragraphs; ⏎ FILES the
//  note, ⇧⏎ adds a paragraph"*).
//
//  The window-hosted arms drive REAL `NSEvent`s through the REAL production
//  `keyDown`, on the `ReturnKeyTraceTests` road — because the thing worth
//  holding here is not what a value says, it is what the key DOES.
//

import AppKit
import Testing
@testable import Variorum

// MARK: - The rule, as a value

@MainActor
@Suite("The capture keys (13u3 UNIT C — R-13u-4)")
struct CaptureKeysTests {
    static func returnEvent(
        _ modifiers: NSEvent.ModifierFlags = [], keypad: Bool = false, windowNumber: Int = 0
    ) -> NSEvent {
        let characters = keypad ? "\u{3}" : "\r"
        return NSEvent.keyEvent(
            with: .keyDown, location: .zero, modifierFlags: modifiers,
            timestamp: 0, windowNumber: windowNumber, context: nil,
            characters: characters, charactersIgnoringModifiers: characters,
            isARepeat: false, keyCode: keypad ? 76 : 36)!
    }

    static func characterEvent(_ character: String, windowNumber: Int = 0) -> NSEvent {
        NSEvent.keyEvent(
            with: .keyDown, location: .zero, modifierFlags: [],
            timestamp: 0, windowNumber: windowNumber, context: nil,
            characters: character, charactersIgnoringModifiers: character,
            isARepeat: false, keyCode: 0)!
    }

    /// HER RULING, as the two lines it is.
    @Test func plainReturnFilesAndShiftReturnMakesAParagraph() {
        #expect(CaptureKeys.act(for: Self.returnEvent()) == .file)
        #expect(CaptureKeys.act(for: Self.returnEvent(.shift)) == .paragraph)
        // The full-size keyboard's Enter is the same key to her hand.
        #expect(CaptureKeys.act(for: Self.returnEvent(keypad: true)) == .file)
        #expect(CaptureKeys.act(for: Self.returnEvent(.shift, keypad: true)) == .paragraph)
    }

    /// The 13d F-2 lesson, inherited rather than re-learned: caps lock is
    /// STATE and the keypad is HARDWARE. Neither is meaning, and testing
    /// against the whole modifier word made the editor's own ⇧⏎ a dead key
    /// with caps lock on.
    @Test func capsLockAndTheKeypadAreNotMeaning() {
        #expect(CaptureKeys.act(for: Self.returnEvent(.capsLock)) == .file)
        #expect(CaptureKeys.act(for: Self.returnEvent([.capsLock, .shift])) == .paragraph)
        #expect(CaptureKeys.act(for: Self.returnEvent(
            [.numericPad, .function], keypad: true)) == .file)
        #expect(CaptureKeys.act(for: Self.returnEvent(
            [.numericPad, .function, .shift], keypad: true)) == .paragraph)
    }

    /// Everything the rule does NOT claim reaches the text untouched — said
    /// loudly, because a near-miss swallowed is a key that stops working.
    @Test func everyOtherKeyIsNobodysHere() {
        #expect(CaptureKeys.act(for: Self.returnEvent(.option)) == nil)
        #expect(CaptureKeys.act(for: Self.returnEvent(.control)) == nil)
        #expect(CaptureKeys.act(for: Self.returnEvent(.command)) == nil)
        #expect(CaptureKeys.act(for: Self.returnEvent([.command, .shift])) == nil)
        #expect(CaptureKeys.act(for: Self.returnEvent([.option, .shift])) == nil)
        #expect(CaptureKeys.act(for: Self.characterEvent("a")) == nil)
        #expect(CaptureKeys.act(for: Self.characterEvent(" ")) == nil)
    }

    /// The two masks in this app agree, and are pinned to — rather than one
    /// reaching across the layer into the other. `EditorTextView`'s rule
    /// answers "is this the editor's soft newline"; this one answers "file
    /// or paragraph"; both must call the same events shift-Return.
    @Test func theCaptureRuleAndTheEditorsSoftNewlineAgree() {
        let events: [NSEvent] = [
            Self.returnEvent(), Self.returnEvent(.shift),
            Self.returnEvent([.capsLock, .shift]), Self.returnEvent(.option),
            Self.returnEvent([.command, .shift]), Self.returnEvent(.shift, keypad: true),
            Self.characterEvent("a"),
        ]
        for event in events {
            #expect(
                (CaptureKeys.act(for: event) == .paragraph)
                    == EditorTextView.isSoftNewlineKey(event),
                "the two masks disagreed about \(event.modifierFlags)")
        }
    }

    /// The growth rule: with the paragraphs, never under the floor, never
    /// past the bound (and a nonsensical bound loses to the floor rather
    /// than collapsing the box).
    @Test func theBoxGrowsWithItsParagraphsAndStopsAtItsBound() {
        #expect(CaptureTextView.height(measured: 0, min: 22, max: 140) == 22)
        #expect(CaptureTextView.height(measured: 60, min: 22, max: 140) == 60)
        #expect(CaptureTextView.height(measured: 900, min: 22, max: 140) == 140)
        #expect(CaptureTextView.height(measured: 10, min: 22, max: 8) == 22)
    }
}

// MARK: - The surface, driven by real keys in a real window

@MainActor
@Suite("The capture surface's keys (13u3 UNIT C)")
struct CaptureTextViewKeyTests {
    /// Three paragraphs, as she would have typed them.
    static let threeParagraphs = "First paragraph.\nSecond paragraph.\nThird paragraph."

    static func host(_ view: NSView) -> (window: NSWindow, teardown: () -> Void) {
        let window = NSWindow(
            contentRect: NSRect(x: 80, y: 80, width: 480, height: 300),
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

    static func box(_ text: String) -> CaptureNSTextView {
        let view = CaptureNSTextView(usingTextLayoutManager: true)
        view.frame = NSRect(x: 0, y: 0, width: 420, height: 200)
        view.isRichText = false
        view.string = text
        return view
    }

    /// **THE LOST-PROSE TWIN — the Mac's version of the phone's 2026-08-23
    /// disaster** (master plan `### 13u` item (9); her words: *"fixing a
    /// typo in the first paragraph gets me into a mode where i couldn't open
    /// it by hitting enter… my second line was NOT in the new note and
    /// neither were the edits to the first line. complete disaster, lost
    /// prose class of bug"*).
    ///
    /// The mechanism there was a caret-dependent MODE: the caret in an
    /// earlier paragraph changed what ⏎ meant and what the hand-off carried.
    /// Here the key rule never reads the caret and the hand-off is the whole
    /// string, so the state cannot be constructed — which is what this pin
    /// asserts, at four caret positions including inside an EDIT she just
    /// made to paragraph one.
    @Test func returnFilesTheWholeCaptureWhereverTheCaretIs() {
        let view = Self.box(Self.threeParagraphs)
        var filed: [String] = []
        view.onFile = { filed.append(view.string) }
        let hosted = Self.host(view)
        defer { hosted.teardown() }

        let carets = [
            0,  // the very start
            5,  // inside paragraph ONE — the phone's exact case
            (Self.threeParagraphs as NSString).range(of: "Second").location + 3,
            (Self.threeParagraphs as NSString).length,  // the end
        ]
        for caret in carets {
            view.setSelectedRange(NSRange(location: caret, length: 0))
            view.keyDown(with: CaptureKeysTests.returnEvent(
                windowNumber: hosted.window.windowNumber))
        }

        #expect(filed.count == carets.count, "every ⏎ filed, at every caret")
        #expect(filed.allSatisfy { $0 == Self.threeParagraphs },
                "…and each one handed over ALL THREE paragraphs, unchanged")
        #expect(view.string == Self.threeParagraphs,
                "filing typed nothing into the box")
    }

    /// …and the same is true after she EDITS an earlier paragraph — the
    /// second half of her report (*"neither were the edits to the first
    /// line"*). Typed through the real text view, so the edit is hers.
    @Test func anEditToAnEarlierParagraphRidesTheFiling() {
        let view = Self.box(Self.threeParagraphs)
        var filed: String?
        view.onFile = { filed = view.string }
        let hosted = Self.host(view)
        defer { hosted.teardown() }

        view.setSelectedRange(NSRange(location: 5, length: 0))
        view.insertText("!", replacementRange: view.selectedRange())
        view.keyDown(with: CaptureKeysTests.returnEvent(
            windowNumber: hosted.window.windowNumber))

        #expect(filed == "First! paragraph.\nSecond paragraph.\nThird paragraph.")
    }

    /// ⇧⏎ types the paragraph AT THE CARET — not at the end, which is what
    /// any "insert it ourselves" road would have had to do — and files
    /// nothing. The character is a plain LF, so `bulkSegments` sees a
    /// paragraph break (U+2028, which `insertLineBreak:` would have typed,
    /// would not segment).
    @Test func shiftReturnTypesAParagraphAtTheCaretAndFilesNothing() {
        let view = Self.box("First paragraph.")
        var fileCount = 0
        view.onFile = { fileCount += 1 }
        let hosted = Self.host(view)
        defer { hosted.teardown() }

        view.setSelectedRange(NSRange(location: 6, length: 0))
        view.keyDown(with: CaptureKeysTests.returnEvent(
            .shift, windowNumber: hosted.window.windowNumber))

        #expect(view.string == "First \nparagraph.", "the break landed at the caret")
        #expect(fileCount == 0, "⇧⏎ never files")
        #expect(!view.string.unicodeScalars.contains { $0.value == 0x2028 },
                "a plain LF — the one `bulkSegments` segments on")
        // And the caret moved with it, so the next keystroke continues the
        // new paragraph rather than the old one.
        #expect(view.selectedRange().location == 7)
    }

    /// A capture typed the way she would type it: three paragraphs made with
    /// ⇧⏎, then ⏎ files all three. The end-to-end shape of her ruling, in
    /// one cell.
    @Test func aThreeParagraphCaptureCanBeTypedAndThenFiled() {
        let view = Self.box("")
        var filed: String?
        view.onFile = { filed = view.string }
        let hosted = Self.host(view)
        defer { hosted.teardown() }

        let paragraph = CaptureKeysTests.returnEvent(
            .shift, windowNumber: hosted.window.windowNumber)
        view.insertText("First paragraph.", replacementRange: view.selectedRange())
        view.keyDown(with: paragraph)
        view.insertText("Second paragraph.", replacementRange: view.selectedRange())
        view.keyDown(with: paragraph)
        view.insertText("Third paragraph.", replacementRange: view.selectedRange())
        view.keyDown(with: CaptureKeysTests.returnEvent(
            windowNumber: hosted.window.windowNumber))

        #expect(filed == Self.threeParagraphs)
    }

    /// The box grows as the paragraphs arrive — measured through the app's
    /// ONE measurement brain, at a fixed width, so the growth is the text's
    /// and not the frame's.
    @Test func theMeasuredBoxGrowsAsParagraphsArrive() {
        let view = Self.box("One line.")
        view.textContainer?.widthTracksTextView = true
        view.textContainer?.size = NSSize(
            width: 420, height: CGFloat.greatestFiniteMagnitude)
        let hosted = Self.host(view)
        defer { hosted.teardown() }

        let oneLine = PaneMeasurement.height(of: view)
        view.string = Self.threeParagraphs
        let threeLines = PaneMeasurement.height(of: view)

        #expect(oneLine > 0)
        #expect(threeLines > oneLine, "three paragraphs measure taller than one")
    }
}
