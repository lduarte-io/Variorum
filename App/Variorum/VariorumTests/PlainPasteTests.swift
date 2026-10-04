//
//  PlainPasteTests.swift
//  VariorumTests
//
//  13u2 UNIT D — item 11, "paste without newlines".
//
//  The RULE is pinned here and the DOOR beside it. Both platforms consume the
//  rule (`App/Variorum/Shared/PlainPaste.swift`); the Mac's chord is ⇧⌘V and
//  the phone's edit-menu item is the mobile catch-up's face work — which is
//  exactly why the rule is pinned in shared code rather than written twice.
//
//  This is NOT a bug-class fix, so there is no red-on-old pin to show: the
//  master plan records it as her QoL ask and notes that NEITHER platform has
//  such a door today (grep-verified: no `pasteWithoutFormatting`/`pastePlain`
//  anywhere). Every arm below is red on old by construction — the function
//  did not exist.
//

import AppKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("Item 11 — paste without line breaks (the rule)")
struct PlainPasteRuleTests {
    @Test func aMultiParagraphClipboardBecomesOneParagraph() {
        #expect(PlainPaste.flattened("One line.\nTwo line.") == "One line. Two line.")
        #expect(PlainPaste.flattened("One.\n\n\nTwo.") == "One. Two.",
                "a blank line is a separator, not a word")
    }

    @Test func theJoinIsExactlyOneSpaceEvenWhenTheLinesCarryTheirOwn() {
        #expect(PlainPaste.flattened("One.   \n   Two.") == "One. Two.")
        #expect(PlainPaste.flattened("One.\t\n\tTwo.") == "One. Two.")
    }

    @Test func theEdgesAreHersAndAreKept() {
        // Item 2's doctrine one door over: the app does not tidy her
        // whitespace — only the SEAMS are trimmed.
        #expect(PlainPaste.flattened("   indented\nsecond") == "   indented second")
        #expect(PlainPaste.flattened("first\nlast   ") == "first last   ")
    }

    @Test func foreignLineEndingsAreLineBreaksToo() {
        #expect(PlainPaste.flattened("One.\r\nTwo.") == "One. Two.")
        #expect(PlainPaste.flattened("One.\rTwo.") == "One. Two.")
    }

    @Test func textWithNoLineBreakPassesThroughByteIdentical() {
        #expect(PlainPaste.flattened("just a line") == "just a line")
        #expect(PlainPaste.flattened("  spaces kept  ") == "  spaces kept  ")
        #expect(PlainPaste.flattened("") == "")
    }

    @Test func aClipboardOfNothingButBlankLinesIsLeftAlone() {
        #expect(PlainPaste.flattened("\n\n") == "\n\n",
                "nothing to join — the door has no word to make")
    }
}

// MARK: - The Mac's door

@MainActor
@Suite("Item 11 — the Mac's ⇧⌘V door")
struct PlainPasteDoorTests {
    private func withClipboard(_ text: String, _ body: () -> Void) {
        let board = NSPasteboard.general
        let saved = board.string(forType: .string)
        board.clearContents()
        board.setString(text, forType: .string)
        body()
        board.clearContents()
        if let saved { board.setString(saved, forType: .string) }
    }

    /// The full-document editor: the flattened text lands through the SAME
    /// input door an ordinary paste uses, so the gate sees it and the open
    /// tail treats it as bulk entry — which now has no newline to split on.
    @Test func theChordLandsOneParagraphInTheWriteEditor() async throws {
        try await withEditor { harness in
            withClipboard("One line.\nTwo line.\n\nThree.") {
                harness.textView.pasteWithoutNewlines(nil)
            }
            #expect(harness.documentText == "One line. Two line. Three.")
            harness.model.idleMintTail()
            await harness.flush()
            let stored = try harness.storeSlots().map(\.text)
            #expect(stored == ["One line. Two line. Three."],
                    "ONE block — the transform is why, not a segmentation change")
        }
    }

    /// …and an ordinary ⌘V over the same clipboard still makes three blocks,
    /// which is the proof that segmentation itself was not touched.
    @Test func anOrdinaryPasteOverTheSameClipboardStillSegments() async throws {
        try await withEditor { harness in
            harness.textView.withPasteFlag {
                harness.type("One line.\nTwo line.\n\nThree.")
            }
            harness.model.idleMintTail()
            await harness.flush()
            let stored = try harness.storeSlots().map(\.text)
            // Three blocks, and the blank line rides as "Two line."'s trailing
        // content — the k−1 spacing rule (her 2026-07-12 ruling), untouched.
        #expect(stored == ["One line.", "Two line.\n", "Three."])
        }
    }

    @Test func aTakePaneTakesTheSameChord() {
        let pane = PaneTextView(usingTextLayoutManager: true)
        pane.isEditable = true
        pane.string = ""
        withClipboard("alpha\nbeta") {
            pane.pasteWithoutNewlines(nil)
        }
        #expect(pane.string == "alpha beta")
    }

    @Test func aREADPaneRefusesTheChord() {
        let pane = PaneTextView(usingTextLayoutManager: true)
        pane.isEditable = false
        pane.string = "untouched"
        withClipboard("alpha\nbeta") {
            pane.pasteWithoutNewlines(nil)
        }
        #expect(pane.string == "untouched", "a read pane is not a writing surface")
    }
}
