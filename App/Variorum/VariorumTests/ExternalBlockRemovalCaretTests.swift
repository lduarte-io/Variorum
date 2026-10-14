//
//  ExternalBlockRemovalCaretTests.swift
//  VariorumTests (Mac)
//
//  VX-275 (Run VX-246, U3 — the record's U3 UNIT RECORD, trace 4): the
//  EDITOR SEAM half of "delete_block under her caret". Once her words are
//  flushed first, a block removed ELSEWHERE — a client's `delete_block`, a
//  sync apply, another window — reaches her live editor as a delivery, and
//  the projection road re-renders from the store (`renderFull`), the same
//  rewrite her own Delete Block uses. What differed was the CARET: her door
//  lands it by identity on the start of the block below, else the end of the
//  block above (`caretLandingAfterRemoving`); `renderFull` kept the caret by
//  identity only while its block SURVIVED, so a removed caret block left the
//  insertion point wherever the wholesale storage replacement parked it —
//  the end of the document (renderFull's own row-49 record).
//
//  RED on old where marked (the red-on-old product is the pins' commit,
//  built before the fix: `DerivedData/vx246-u3-red`, run at the stage's W1).
//

import AppKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@Suite("VX-275 — a block removed under her caret lands the caret as her Delete Block does")
@MainActor
struct ExternalBlockRemovalCaretTests {
    /// The block below survives: the caret goes to its START. **RED on old:**
    /// the caret is parked at the document's end (the last block's end).
    @Test func theCaretLandsOnTheStartOfTheBlockBelow() async throws {
        try await withEditor(seedBlocks: ["One.", "Two.", "Three."]) { editor in
            let slots = try editor.storeSlots()
            let two = editor.model.index.range(ofEntryAt: 1)
            editor.textView.setSelectedRange(NSRange(location: two.location + 2, length: 0))
            #expect(editor.model.caretIdentity()?.blockID == slots[1].blockID, "the premise: her caret is in Two")

            // Elsewhere: the store loses the block (a client's delete, a sync
            // apply, another window) — her buffer is clean.
            try await editor.session.runner.run { (ops: Operations) in try ops.deleteBlock(slots[1].blockID) }
            try editor.reload()  // the delivery

            #expect(editor.documentText == "One.\nThree.")
            let caret = try #require(editor.model.caretIdentity())
            #expect(caret.blockID == slots[2].blockID, "the block below")
            #expect(caret.offset == 0, "at its start")
        }
    }

    /// No block follows (an open tail does — so the document's end is NOT the
    /// block above's end): the caret goes to the END of the block above.
    /// **RED on old:** the caret is parked in the tail, outside every block.
    @Test func theCaretLandsOnTheEndOfTheBlockAboveWhenNoBlockFollows() async throws {
        try await withEditor(seedBlocks: ["One.", "Two."]) { editor in
            editor.type("\n", at: editor.model.index.documentLength)
            editor.type("tail")
            #expect(editor.model.index.tailLength == 4, "the premise: an open tail after the last block")
            let slots = try editor.storeSlots()
            let two = editor.model.index.range(ofEntryAt: 1)
            editor.textView.setSelectedRange(NSRange(location: two.location + 1, length: 0))
            #expect(editor.model.caretIdentity()?.blockID == slots[1].blockID)

            try await editor.session.runner.run { (ops: Operations) in try ops.deleteBlock(slots[1].blockID) }
            try editor.reload()

            #expect(editor.documentText == "One.\ntail", "the tail kept, the block gone")
            let caret = try #require(editor.model.caretIdentity(), "the caret is in a block, not the tail")
            #expect(caret.blockID == slots[0].blockID, "the block above")
            #expect(caret.offset == 4, "at its end")
        }
    }

    /// Several blocks leave at once (a merge elsewhere releases two and mints a
    /// fresh one where they stood): the landing is the first SURVIVING block
    /// below hers, never one that left with it. **RED on old:** the
    /// document's end.
    @Test func theLandingSkipsBlocksThatLeftWithHers() async throws {
        try await withEditor(seedBlocks: ["One.", "Two.", "Three.", "Four."]) { editor in
            let slots = try editor.storeSlots()
            let two = editor.model.index.range(ofEntryAt: 1)
            editor.textView.setSelectedRange(NSRange(location: two.location, length: 0))

            try await editor.session.runner.run { (ops: Operations) in
                try ops.deleteBlock(slots[1].blockID)
                try ops.deleteBlock(slots[2].blockID)
            }
            try editor.reload()

            #expect(editor.documentText == "One.\nFour.")
            let caret = try #require(editor.model.caretIdentity())
            #expect(caret.blockID == slots[3].blockID && caret.offset == 0, "Four's start — Three left with Two")
        }
    }

    /// A caret whose block SURVIVES keeps its place by identity — exactly as
    /// before (green on both sides by design: it pins what the fix must not
    /// change).
    @Test func aCaretWhoseBlockSurvivesKeepsItsPlace() async throws {
        try await withEditor(seedBlocks: ["One.", "Two.", "Three."]) { editor in
            let slots = try editor.storeSlots()
            let three = editor.model.index.range(ofEntryAt: 2)
            editor.textView.setSelectedRange(NSRange(location: three.location + 3, length: 0))

            try await editor.session.runner.run { (ops: Operations) in try ops.deleteBlock(slots[1].blockID) }
            try editor.reload()

            let caret = try #require(editor.model.caretIdentity())
            #expect(caret.blockID == slots[2].blockID && caret.offset == 3)
        }
    }
}
