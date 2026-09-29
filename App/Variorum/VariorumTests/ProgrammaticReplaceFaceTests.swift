//
//  ProgrammaticReplaceFaceTests.swift
//  VariorumTests
//
//  **18m U2, rider F-3 — the Mac's programmatic surface writes must keep the
//  markdown face.**
//
//  THE MECHANISM (the U2 band map's F-3, probed before this pin existed):
//  `EditorViewModel.programmaticReplace` resets the span it replaces to
//  `EditorDocument.baseAttributes` and never re-derived the markdown face
//  there — 13g's L7 wiring list names `materialize`, the keystroke road and
//  `applySeamEdit`, not this door — while the phone's twin always restyled
//  (mobile batch 2). Two user-reachable Mac roads reach the door:
//
//  · the MINT's tail normalization — whenever the minted text is not
//    byte-identical to the tail (a completed paragraph's trimmed trailing
//    space, an excised blank line), `finishMint` rewrites the tail region;
//  · the DIFFERENTIAL projection apply — a take chosen on another surface,
//    a restored savepoint, a sync landing: same block sequence, new text.
//
//  On both, a heading that was faced before the write landed unfaced after
//  it, and stayed so until that line was edited again or the note
//  re-rendered. Faced text is the shipped standard on every other road.
//
//  Each pin also asserts the REPLACE ROAD WAS TAKEN (the trimmed space, the
//  new text), so a green cannot come from a road that never wrote.
//

import AppKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("18m U2 F-3 — the Mac's programmatic writes keep the markdown face")
struct ProgrammaticReplaceFaceTests {
    /// Whether any part of `range` carries the markdown face's bookkeeping
    /// attribute (a faced span always does; base attributes never do).
    private func faced(_ h: EditorHarness, _ range: NSRange) -> Bool {
        guard let storage = h.textView.textStorage, range.upperBound <= storage.length
        else { return false }
        var any = false
        storage.enumerateAttribute(MarkdownFace.faceAttribute, in: range) { value, _, stop in
            if value != nil {
                any = true
                stop.pointee = true
            }
        }
        return any
    }

    /// A few main-actor turns, so a late re-face (if one existed) would have
    /// run before the assertion — the pin asserts what she sees, not the
    /// instant after the write.
    private func turns() async {
        for _ in 0..<10 { await Task.yield() }
        try? await Task.sleep(for: .milliseconds(20))
        for _ in 0..<10 { await Task.yield() }
    }

    @Test func aHeadingTypedWithATrailingSpaceKeepsItsFaceThroughTheMint() async throws {
        try await withEditor { h in
            h.type("# Title ")
            #expect(faced(h, NSRange(location: 0, length: 7)),
                    "the premise: the keystroke road faces the heading")
            h.type("\n")
            h.type("B")
            await h.flush()
            await h.settle()
            await turns()
            // The replace road WAS taken: the completed paragraph's trailing
            // space is the shipped trim (`.typing`), so the minted text is not
            // byte-identical to the tail and `finishMint` rewrote the region.
            #expect(h.documentText == "# Title\nB")
            #expect(faced(h, NSRange(location: 0, length: 7)),
                    "the minted heading keeps its face")
        }
    }

    @Test func aTakeChosenElsewhereLandsFaced() async throws {
        try await withEditor(seedBlocks: ["Plain first.", "Second."]) { h in
            let slots = try h.storeSlots()
            let blockID = slots[0].blockID
            let take = try h.session.operations.branchVariant(blockID, from: slots[0].variantID!)
            try h.session.operations.autosave(take.id, text: "# Heading take", charDelta: 0)
            try h.session.operations.chooseVariant(blockID, variantID: take.id)
            try h.reload()  // the observation road, driven by hand
            await turns()
            #expect(h.documentText == "# Heading take\nSecond.",
                    "the differential road wrote the chosen take")
            #expect(faced(h, NSRange(location: 0, length: 14)),
                    "the chosen take's heading lands faced")
        }
    }

    @Test func aRestoredSavepointLandsFaced() async throws {
        try await withEditor(seedBlocks: ["# Saved heading", "Second."]) { h in
            let slots = try h.storeSlots()
            let variantID = slots[0].variantID!
            let savepoint = try h.session.operations.commit(variantID)
            try h.session.operations.autosave(variantID, text: "Plain now.", charDelta: 0)
            try h.reload()
            #expect(h.documentText == "Plain now.\nSecond.")
            try h.session.operations.restoreCommit(variantID, commitID: savepoint.id)
            try h.reload()
            await turns()
            #expect(h.documentText == "# Saved heading\nSecond.",
                    "the differential road wrote the restored text")
            #expect(faced(h, NSRange(location: 0, length: 15)),
                    "the restored heading lands faced")
        }
    }
}
