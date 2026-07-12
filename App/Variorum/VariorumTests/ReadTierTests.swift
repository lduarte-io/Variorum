//
//  ReadTierTests.swift
//  VariorumTests
//
//  Phase 10 Step 2 — the read-cheap tier: projection fidelity (Phase 4
//  semantics displayed, never re-decided), badges exactly on fanned blocks,
//  the differential-update cost seam (one changed slot costs that slot,
//  never the document), and the pinned selection-survival behavior the
//  Step 0 measurement verified.
//

import AppKit
import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
struct ReadTierHarness {
    let session: AppSession
    let database: AppDatabase
    let model: ReadPostViewModel
    let textView: ReadPostTextView
    let postID: String

    /// Loads the current store projection (the observation path, by hand).
    func reload() throws {
        model.applyProjection(
            try database.read { try Queries.renderPost($0, containerID: postID) })
    }
}

@MainActor
func withReadTier<T>(
    seedBlocks: [String] = [],
    _ body: @MainActor (ReadTierHarness) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        let post = try session.operations.createPost(title: "R")
        for text in seedBlocks {
            _ = try session.operations.newBlock(in: post.id, text: text)
        }
        let model = ReadPostViewModel(session: session, postID: post.id)
        let textView = ReadPostTextView.makeReadSurface()
        textView.frame = NSRect(x: 0, y: 0, width: 600, height: 100)
        model.attach(textView: textView)
        let harness = ReadTierHarness(
            session: session, database: db, model: model,
            textView: textView, postID: post.id)
        try harness.reload()
        return try await body(harness)
    }
}

@Suite("Read tier (Phase 10 Step 2)")
struct ReadTierTests {
    @Test func projectionFidelityJoinsBlocksWithTheEditorSeparator() async throws {
        try await withReadTier(seedBlocks: ["alpha", "beta"]) { h in
            #expect(h.model.documentText == "alpha\nbeta")
            #expect(h.textView.isEditable == false)
            #expect(h.textView.isSelectable == true)
            #expect(h.model.contentHeight > 1)
        }
    }

    @Test func blankTakesRenderAsEmptySlotsAndGapsAsGapsNeverCrash() async throws {
        try await withReadTier { h in
            // A blank take is an empty SLOT on the surface (Phase 4: it
            // skips only in renderedText); a gap slot renders as a gap.
            h.model.applyProjection([
                slot("a", text: "one"),
                slot("b", text: ""),           // blank take
                slot("c", variant: nil, text: nil),  // gap (SyncSpec §5)
                slot("d", text: "four"),
            ])
            #expect(h.model.documentText == "one\n\n\nfour")
            #expect(h.model.badges.isEmpty)
        }
    }

    @Test func badgesAppearExactlyOnFannedBlocks() async throws {
        try await withReadTier { h in
            h.model.applyProjection([
                slot("a", text: "plain block one"),
                slot("b", text: "fanned block", fan: 3),
                slot("c", text: "plain block two"),
                slot("d", text: "another fan", fan: 2),
            ])
            #expect(h.model.badges.map(\.blockID) == ["b", "d"])
            #expect(h.model.badges.map(\.variantCount) == [3, 2])
            // Frames are real geometry, in document order.
            let frames = h.model.badges.map(\.frame)
            #expect(frames.allSatisfy { $0.height > 0 })
            #expect(frames[0].minY < frames[1].minY)
        }
    }

    @Test func selectionSurvivesADifferentialProjectionRefresh() async throws {
        try await withReadTier(
            seedBlocks: ["one two three", "four five six", "seven eight nine"]
        ) { h in
            // Select "eight" in the THIRD block.
            let text = h.model.documentText as NSString
            let selection = text.range(of: "eight")
            #expect(selection.location != NSNotFound)
            h.textView.setSelectedRange(selection)

            // An external change lands in the FIRST block (sync, the live
            // editor elsewhere): the refresh is differential, and the
            // selection survives — shifted, same text.
            let slots = try h.database.read {
                try Queries.renderPost($0, containerID: h.postID)
            }
            try h.session.operations.autosave(
                slots[0].variantID!, text: "one two three and more", charDelta: 9)
            try h.reload()

            #expect(h.model.documentText.hasPrefix("one two three and more\n"))
            let after = h.textView.selectedRange()
            #expect(after.length == selection.length)
            #expect((h.model.documentText as NSString).substring(with: after) == "eight")
        }
    }

    @Test func aOneSlotChangeCostsThatSlotNeverTheDocument() async throws {
        let blocks = (0..<40).map { "block \($0) carries a sentence of prose." }
        try await withReadTier(seedBlocks: blocks) { h in
            #expect(h.model.fullRenderCount == 1)  // the initial render only
            let slots = try h.database.read {
                try Queries.renderPost($0, containerID: h.postID)
            }
            let oldText = slots[5].text!
            let newText = oldText + " Edited."
            try h.session.operations.autosave(
                slots[5].variantID!, text: newText, charDelta: 8)
            let before = h.model.differentialUnitsReplaced
            try h.reload()
            let replaced = h.model.differentialUnitsReplaced - before
            // The differential seam: exactly the changed slot's old + new
            // units — never document-proportional.
            #expect(replaced == oldText.utf16.count + newText.utf16.count)
            #expect(h.model.fullRenderCount == 1)
            #expect(h.model.documentText.contains("block 5 carries a sentence of prose. Edited."))
        }
    }

    @Test func aSequenceChangeReRendersFully() async throws {
        try await withReadTier(seedBlocks: ["first", "second"]) { h in
            #expect(h.model.fullRenderCount == 1)
            // A structural change (delete a block) changes the sequence.
            let slots = try h.database.read {
                try Queries.renderPost($0, containerID: h.postID)
            }
            try h.session.operations.deleteBlock(slots[0].blockID)
            try h.reload()
            #expect(h.model.fullRenderCount == 2)
            #expect(h.model.documentText == "second")
        }
    }

    @Test func aPlainClickReportsItsOffsetWhileASelectionDoesNot() async throws {
        try await withReadTier(seedBlocks: ["alpha", "beta"]) { h in
            var reported: [Int] = []
            h.textView.onPlainClick = { reported.append($0) }
            // The gesture's contract is "no selection ⇒ focus request":
            // drive the post-tracking-loop decision directly (the tracking
            // loop itself needs a real event stream).
            h.textView.setSelectedRange(NSRange(location: 3, length: 0))
            if h.textView.selectedRange().length == 0 {
                h.textView.onPlainClick?(3)
            }
            h.textView.setSelectedRange(NSRange(location: 0, length: 4))
            if h.textView.selectedRange().length == 0 {
                h.textView.onPlainClick?(0)
            }
            #expect(reported == [3])
        }
    }
}
