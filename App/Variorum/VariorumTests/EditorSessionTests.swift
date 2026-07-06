//
//  EditorSessionTests.swift
//  VariorumTests
//
//  Phase 7 Steps 3–6 integration: scripted edit sessions through the REAL
//  NSTextView pipeline (shouldChange → storage edit → didProcessEditing),
//  verified against the store — after every session, DB rows equal the text
//  view's content per block (the plan's Step 3 integration test).
//

import AppKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

/// DB rows == view content, per block (identity validated against the store).
@MainActor
func expectStoreMatchesView(
    _ harness: EditorHarness,
    sourceLocation: SourceLocation = #_sourceLocation
) throws {
    let slots = try harness.storeSlots()
    #expect(slots.count == harness.model.index.entries.count, sourceLocation: sourceLocation)
    guard slots.count == harness.model.index.entries.count else { return }
    let document = harness.documentText as NSString
    for (i, stored) in slots.enumerated() {
        let entry = harness.model.index.entries[i]
        #expect(stored.blockID == entry.blockID, sourceLocation: sourceLocation)
        let viewText = document.substring(with: harness.model.index.range(ofEntryAt: i))
        #expect(stored.text == viewText, sourceLocation: sourceLocation)
    }
}

@MainActor
@Suite("Editor sessions (Steps 3–4 integration)")
struct EditorSessionTests {
    @Test func typingInsideABlockAutosavesToItsVariant() async throws {
        try await withEditor(seedBlocks: ["one", "two"]) { h in
            #expect(h.documentText == "one\ntwo")
            h.type("X", at: 3)              // end of block a
            h.type("Y", at: 5)              // "two" starts at 5 now: prepend to b
            #expect(h.documentText == "oneX\nYtwo")
            await h.flush()
            try expectStoreMatchesView(h)
            let slots = try h.storeSlots()
            #expect(slots.map(\.text) == ["oneX", "Ytwo"])
        }
    }

    @Test func enterInsideABlockIsContentNeverAStructureChange() async throws {
        try await withEditor(seedBlocks: ["para one", "closer"]) { h in
            h.type("\nadded line", at: 8)   // Enter INSIDE block a (at its end, non-last)
            await h.flush()
            let slots = try h.storeSlots()
            try #require(slots.count == 2)  // I4: no new block
            #expect(slots[0].text == "para one\nadded line")
            try expectStoreMatchesView(h)
        }
    }

    @Test func crossBlockDestructiveEditsRefuse() async throws {
        try await withEditor(seedBlocks: ["one", "two"]) { h in
            let before = h.documentText
            h.replace(NSRange(location: 2, length: 3), with: "")   // spans the separator
            h.replace(NSRange(location: 3, length: 1), with: "")   // the separator itself
            h.replace(NSRange(location: 0, length: 7), with: "Z")  // select-all overtype
            #expect(h.documentText == before)
            #expect(h.model.statusMessage != nil)
            await h.flush()
            let slots = try h.storeSlots()
            #expect(slots.map(\.text) == ["one", "two"])
        }
    }

    @Test func typingPastAParagraphMintsExactlyOneBlock() async throws {
        try await withEditor(seedBlocks: ["existing"]) { h in
            h.type("\n", at: 8)             // Enter at document end: opens the tail
            #expect(h.model.hasOpenTail)
            h.type("fresh paragraph")
            await h.settle()
            // Still an open tail: nothing typed past yet.
            let midway = try h.storeSlots()
            #expect(midway.count == 1)
            h.type("\n")                    // typed past → crystallize
            await h.settle()
            let slots = try h.storeSlots()
            try #require(slots.count == 2)
            #expect(slots[1].text == "fresh paragraph")
            #expect(h.model.hasOpenTail)    // the (empty) tail stays open
            try expectStoreMatchesView(h)
            // Keep typing: the next paragraph accumulates in the tail.
            h.type("next line")
            await h.settle()
            let after = try h.storeSlots()
            #expect(after.count == 2)
            #expect(h.documentText == "existing\nfresh paragraph\nnext line")
        }
    }

    @Test func anEmptyPostCrystallizesFromScratch() async throws {
        try await withEditor { h in
            #expect(h.documentText == "")
            h.type("first entry line")
            await h.settle()
            let beforeEnter = try h.storeSlots()
            #expect(beforeEnter.isEmpty)   // open tail only
            h.type("\n")
            await h.settle()
            let slots = try h.storeSlots()
            #expect(slots.map(\.text) == ["first entry line"])
            try expectStoreMatchesView(h)
        }
    }

    @Test func bulkPasteIntoTheTailSegmentsOnEntry() async throws {
        try await withEditor(seedBlocks: ["existing"]) { h in
            h.type("\n", at: 8)             // open the tail
            h.textView.withPasteFlag {
                h.type("Alpha para.\nBeta para.\nGamma tail")
            }
            await h.settle()
            let slots = try h.storeSlots()
            #expect(slots.map(\.text) == ["existing", "Alpha para.", "Beta para.", "Gamma tail"])
            // Bulk entry consumes the tail entirely (segments on entry).
            #expect(!h.model.hasOpenTail)
            try expectStoreMatchesView(h)
        }
    }

    @Test func oneBlockJournalPostsMintOnFirstTextAndNeverCrystallize() async throws {
        try await withEditor(profile: .journal) { h in
            h.type("Dear diary")
            await h.settle()
            var slots = try h.storeSlots()
            try #require(slots.count == 1)       // minted at first text
            h.type(", hello.\nSecond line.")     // Enter is content forever
            await h.flush()
            slots = try h.storeSlots()
            try #require(slots.count == 1)
            #expect(slots[0].text == "Dear diary, hello.\nSecond line.")
            try expectStoreMatchesView(h)
        }
    }

    @Test func closingAnEmptyTailDeletesOnlyTheSeparator() async throws {
        try await withEditor(seedBlocks: ["block"]) { h in
            h.type("\n", at: 5)
            #expect(h.model.hasOpenTail)
            // Backspace over the empty tail's separator.
            h.replace(NSRange(location: 5, length: 1), with: "")
            #expect(!h.model.hasOpenTail)
            #expect(h.documentText == "block")
            await h.flush()
            let texts = try h.storeSlots().map(\.text)
            #expect(texts == ["block"])
        }
    }

    @Test func lockedVariantSlotsRefuseEdits() async throws {
        try await withEditor(seedBlocks: ["frozen", "free"]) { h in
            let slots = try h.storeSlots()
            _ = try h.session.operations.lockVariant(slots[0].variantID!)
            try h.reload()
            h.type("X", at: 0)
            #expect(h.documentText == "frozen\nfree")   // refused
            h.type("Y", at: 7)                           // block b still editable
            #expect(h.documentText == "frozen\nYfree")
            await h.flush()
            try expectStoreMatchesView(h)
        }
    }

    @Test func sealedPostsRefuseEverything() async throws {
        try await withEditor(seedBlocks: ["sealed content"]) { h in
            try h.session.operations.lockPost(h.postID)
            try h.reload()
            #expect(h.textView.isEditable == false)
            h.type("X", at: 0)
            #expect(h.documentText == "sealed content")
        }
    }

    @Test func externalStoreChangesReRenderWhenClean() async throws {
        try await withEditor(seedBlocks: ["original", "stable"]) { h in
            let slots = try h.storeSlots()
            // An out-of-editor change (another window, sync, restore…).
            try h.session.operations.autosave(
                slots[0].variantID!, text: "rewritten elsewhere", charDelta: 10)
            try h.reload()
            #expect(h.documentText == "rewritten elsewhere\nstable")
            try expectStoreMatchesView(h)
        }
    }

    @Test func projectionEchoesLeaveTheSurfaceUntouched() async throws {
        try await withEditor(seedBlocks: ["alpha", "beta"]) { h in
            h.type("!", at: 5)
            await h.flush()
            let before = h.documentText
            let selection = h.textView.selectedRange()
            try h.reload()  // the echo of our own autosave
            #expect(h.documentText == before)
            #expect(h.textView.selectedRange() == selection)
        }
    }
}

@MainActor
@Suite("Commit flow (Step 5)")
struct CommitFlowTests {
    @Test func commitFlushesTheBufferFirst() async throws {
        try await withEditor(seedBlocks: ["draft text"]) { h in
            h.type("… more", at: 10)
            h.textView.setSelectedRange(NSRange(location: 3, length: 0))
            h.model.updateCaretContext()
            await h.model.commitCaret()   // flush-then-commit ordering
            await h.settle()
            let variantID = try h.storeSlots()[0].variantID!
            let history = try await h.database.read { try Queries.commitHistory($0, variantID: variantID) }
            #expect(history.count == 1)
            #expect(history[0].text == "draft text… more")   // exactly the buffer
            #expect(history[0].kind == .manual)
        }
    }

    @Test func commitWithCaretInTheTailRefusesGently() async throws {
        try await withEditor(seedBlocks: ["block"]) { h in
            h.type("\n", at: 5)
            h.model.updateCaretContext()
            #expect(h.model.caretVariantID == nil)
            await h.model.commitCaret()
            #expect(h.model.statusMessage == "Place the caret in a block to commit.")
        }
    }

    @Test func predatesSplitPredicate() {
        let earlier = Date(timeIntervalSince1970: 100)
        let split = Date(timeIntervalSince1970: 200)
        let later = Date(timeIntervalSince1970: 300)
        #expect(CommitRules.predatesSplit(commitDate: earlier, splitDates: [split]))
        #expect(!CommitRules.predatesSplit(commitDate: later, splitDates: [split]))
        #expect(!CommitRules.predatesSplit(commitDate: earlier, splitDates: []))
        // The NEWEST split is the reference.
        #expect(CommitRules.predatesSplit(commitDate: later, splitDates: [split, Date(timeIntervalSince1970: 400)]))
    }

    @Test func restoreOfAPreSplitCommitAsksFirst() async throws {
        try await withEditor(seedBlocks: ["First half here. Second half there."]) { h in
            let variantID = try h.storeSlots()[0].variantID!
            _ = try h.session.operations.commit(variantID)          // pre-split commit
            _ = try h.session.operations.divide(
                try h.storeSlots()[0].blockID, cut: "First half here.".utf16.count)
            try h.reload()
            h.textView.setSelectedRange(NSRange(location: 0, length: 0))
            h.model.updateCaretContext()
            await h.model.loadCommitHistory()
            let item = try #require(h.model.commitList?.first)
            #expect(item.predatesSplit)
            h.model.restore(item)                                   // not confirmed
            #expect(h.model.pendingRestore == item)                 // warning pending
            await h.settle()
            // Nothing restored yet: the buffer still holds the post-divide half.
            let postDivide = try h.storeSlots()
            try #require(!postDivide.isEmpty)
            let firstText = postDivide[0].text
            #expect(firstText == "First half here.")
        }
    }
}

@MainActor
@Suite("Fan flows (Step 6)")
struct FanFlowTests {
    @Test func badgePredicateOnlyFansShow() async throws {
        try await withEditor(seedBlocks: ["plain", "fanned"]) { h in
            let slots = try h.storeSlots()
            _ = try h.session.operations.branchVariant(
                slots[1].blockID, from: slots[1].variantID!)
            try h.reload()
            let fresh = try h.storeSlots()
            #expect(fresh.map(\.hasFan) == [false, true])   // AppSpec §12: badge only with a fan
        }
    }

    @Test func chooseSwapsTheRenderedSlot() async throws {
        try await withEditor(seedBlocks: ["take one", "anchor"]) { h in
            let slots = try h.storeSlots()
            let blockID = slots[0].blockID
            let branch = try h.session.operations.branchVariant(blockID, from: slots[0].variantID!)
            try h.session.operations.autosave(branch.id, text: "take two", charDelta: 8)
            try h.session.operations.chooseVariant(blockID, variantID: branch.id)
            try h.reload()   // I3: the pointer decides what renders here
            #expect(h.documentText == "take two\nanchor")
            try expectStoreMatchesView(h)
        }
    }

    @Test func refusalsSurfaceAsMessages() async throws {
        try await withEditor(seedBlocks: ["only take"]) { h in
            let slots = try h.storeSlots()
            h.model.fanPanel = .init(
                blockID: slots[0].blockID, variants: [], chosenVariantID: slots[0].variantID)
            h.model.fanAction(.delete(slots[0].variantID!))   // chosen AND last active
            for _ in 0..<2000 {
                if h.model.statusMessage != nil { break }
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            #expect(h.model.statusMessage?.contains("shown in the post") == true)
            // The store refused: the variant is still there.
            let surviving = try h.storeSlots()
            try #require(!surviving.isEmpty)
            let survivingVariant = surviving[0].variantID
            #expect(survivingVariant == slots[0].variantID)
        }
    }
}
