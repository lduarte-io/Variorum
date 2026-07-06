//
//  EditorDocumentTests.swift
//  VariorumTests
//
//  Phase 7 Step 2: the pure attribute mapping, both directions — blocks →
//  attributed string with ranges, ranges → block IDs — including empty
//  takes, multi-paragraph blocks, and the separator-ownership doctrine
//  (the separator belongs to NEITHER block).
//

import AppKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("EditorDocument mapping (Step 2)")
struct EditorDocumentTests {
    @Test func blocksJoinWithSingleNewlineAndCarryTheirIDs() {
        let (text, index) = EditorDocument.materialize([
            slot("a", text: "First block."),
            slot("b", text: "Second block."),
        ])
        #expect(text.string == "First block.\nSecond block.")
        #expect(index.entries.map(\.blockID) == ["a", "b"])
        #expect(index.range(ofEntryAt: 0) == NSRange(location: 0, length: 12))
        #expect(index.range(ofEntryAt: 1) == NSRange(location: 13, length: 13))
        // Forward mapping: every char of a block carries its ID.
        #expect(EditorDocument.blockID(at: 0, in: text) == "a")
        #expect(EditorDocument.blockID(at: 11, in: text) == "a")
        #expect(EditorDocument.blockID(at: 13, in: text) == "b")
        #expect(EditorDocument.blockID(at: 25, in: text) == "b")
    }

    @Test func theSeparatorIsOwnedByNeitherBlock() {
        let (text, _) = EditorDocument.materialize([
            slot("a", text: "one"),
            slot("b", text: "two"),
        ])
        // Offset 3 is the separator "\n": no block-ID attribute there.
        #expect(EditorDocument.blockID(at: 3, in: text) == nil)
    }

    @Test func multiParagraphBlocksKeepInternalNewlinesAsContent() {
        // I4: internal newlines are content — one block, one range, one ID.
        let (text, index) = EditorDocument.materialize([
            slot("a", text: "Para one.\nPara two."),
            slot("b", text: "Next block."),
        ])
        #expect(text.string == "Para one.\nPara two.\nNext block.")
        #expect(index.range(ofEntryAt: 0) == NSRange(location: 0, length: 19))
        // The INTERNAL newline (offset 9) belongs to block a...
        #expect(EditorDocument.blockID(at: 9, in: text) == "a")
        // ...while the separator (offset 19) belongs to nobody.
        #expect(EditorDocument.blockID(at: 19, in: text) == nil)
    }

    @Test func emptyTakesRenderAsEmptySlots() {
        // Phase 4 ratification: a chosen-but-empty variant is an empty slot
        // in the editor (unlike renderedText, where it skips).
        let (text, index) = EditorDocument.materialize([
            slot("a", text: "one"),
            slot("b", text: ""),
            slot("c", text: "three"),
        ])
        #expect(text.string == "one\n\nthree")
        #expect(index.range(ofEntryAt: 1) == NSRange(location: 4, length: 0))
        #expect(index.range(ofEntryAt: 2) == NSRange(location: 5, length: 5))
    }

    @Test func gapSlotsRenderEmptyAndReadOnly() {
        // SyncSpec §5: a missing block/variant renders as a gap, never a crash.
        let (text, index) = EditorDocument.materialize([
            slot("a", text: "one"),
            slot("gap", variant: nil, text: nil),
            slot("c", text: "three"),
        ])
        #expect(text.string == "one\n\nthree")
        #expect(index.entries[1].editable == false)
        #expect(index.entries[1].variantID == nil)
    }

    @Test func lockedVariantsAreNotEditable() {
        let (_, index) = EditorDocument.materialize([
            slot("a", text: "one", locked: true)
        ])
        #expect(index.entries[0].editable == false)
        #expect(index.entries[0].variantID != nil)
    }

    @Test func openTailSitsAfterATrailingSeparator() {
        let (text, index) = EditorDocument.materialize(
            [slot("a", text: "block")], tail: "typing…")
        #expect(text.string == "block\ntyping…")
        #expect(index.tailRange == NSRange(location: 6, length: "typing…".utf16.count))
        // Tail text carries no block ID.
        #expect(EditorDocument.blockID(at: 6, in: text) == nil)
    }

    @Test func anEmptyPostIsAllTail() {
        let (text, index) = EditorDocument.materialize([], tail: "")
        #expect(text.string == "")
        #expect(index.entries.isEmpty)
        #expect(index.tailRange == NSRange(location: 0, length: 0))
    }

    @Test func roundTripAgreement() {
        // The index (authority) and the attribute run (cross-check) must
        // agree on every non-empty block's characters.
        let slots = [
            slot("a", text: "Alpha beta."),
            slot("b", text: ""),
            slot("c", text: "Gamma\ndelta."),
            slot("d", text: "Épsilon 🦉 zeta."),
        ]
        let (text, index) = EditorDocument.materialize(slots, tail: "open tail")
        for (i, entry) in index.entries.enumerated() {
            let range = index.range(ofEntryAt: i)
            for offset in range.location..<range.upperBound {
                #expect(EditorDocument.blockID(at: offset, in: text) == entry.blockID)
            }
        }
        // Separators + tail: no ownership anywhere else.
        let owned = Set((0..<index.entries.count).flatMap { i -> [Int] in
            let r = index.range(ofEntryAt: i)
            return Array(r.location..<r.upperBound)
        })
        for offset in 0..<text.length where !owned.contains(offset) {
            #expect(EditorDocument.blockID(at: offset, in: text) == nil)
        }
    }
}
