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
            h.type("\n")
            await h.settle()
            // Author ruling 2026-07-12: the newline alone no longer
            // completes the paragraph — its trailing run is still growing
            // (the spacing the ruling preserves); the idle-mint/teardown
            // backstops still bound durability.
            #expect(try h.storeSlots().count == 1)
            h.type("next line")             // the NEXT paragraph begins → typed past
            await h.settle()
            let slots = try h.storeSlots()
            try #require(slots.count == 2)
            #expect(slots[1].text == "fresh paragraph")
            #expect(h.model.hasOpenTail)    // "next line" accumulates in the tail
            try expectStoreMatchesView(h)
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
            // Deferred completion (2026-07-12 ruling): the idle-mint is
            // the durability backstop for a paragraph awaiting its
            // successor — drive it as the clock would.
            #expect(try h.storeSlots().isEmpty)
            h.model.idleMintTail()
            await h.settle()
            let slots = try h.storeSlots()
            #expect(slots.map(\.text) == ["first entry line"])
            try expectStoreMatchesView(h)
        }
    }

    /// Author ruling 2026-07-12 (QUESTIONS #12, the newline-ENTRY half):
    /// blank lines TYPED between paragraphs persist as trailing content —
    /// the surface stays exactly what was typed, and the store carries the
    /// k−1 rule's newlines.
    @Test func typedBlankLinesBetweenParagraphsPersist() async throws {
        try await withEditor(seedBlocks: ["existing"]) { h in
            h.type("\n", at: 8)             // open the tail
            h.type("Alpha para.\n\nBeta going")
            await h.settle()
            let slots = try h.storeSlots()
            try #require(slots.count == 2)
            #expect(slots[1].text == "Alpha para.\n", "k=2 newlines ⇒ one trailing stored")
            #expect(h.documentText == "existing\nAlpha para.\n\nBeta going",
                    "the surface is exactly what was typed")
            try expectStoreMatchesView(h)
            // And the rendered projection completes the stored spacing
            // instead of stacking (the export half of the ruling) — the
            // still-open tail is not a block yet, so mint it first (the
            // teardown backstop).
            await h.model.finalizeWork()?.value
            await h.settle()
            let rendered = try await h.database.read { [postID = h.postID] db in
                try Queries.renderedText(db, containerID: postID)
            }
            #expect(rendered == "existing\n\nAlpha para.\n\nBeta going")
        }
    }

    /// Review round 1, MAJOR 2 (red-on-old): the durability backstop must
    /// never collapse a typed pending gap — the dominant writing rhythm is
    /// "paragraph, Enter, Enter, THINK (>2 s), next paragraph", and the
    /// old idle mint dropped the trailing run and visibly collapsed the
    /// blank lines (the exact pre-ruling behavior the author ruled
    /// against). The .idle kind keeps the run; the attachment makes it
    /// durable content immediately.
    @Test func aPauseAfterTypedBlankLinesNeverCollapsesThem() async throws {
        try await withEditor(seedBlocks: ["existing"]) { h in
            h.type("\n", at: 8)  // open the tail
            h.type("A")
            h.type("\n")
            h.type("\n")          // the gap… then the author pauses to think
            await h.settle()
            #expect(h.documentText == "existing\nA\n\n")
            h.model.idleMintTail()  // the 2 s durability backstop fires
            await h.settle()
            #expect(h.documentText == "existing\nA\n\n",
                    "the pause never collapses the typed gap")
            #expect(try h.storeSlots().map(\.text) == ["existing", "A\n"],
                    "the piece minted AND the gap is already durable content")
            // The successor arrives after the pause: structure and spacing
            // both match typing straight through.
            h.type("B", at: (h.documentText as NSString).length)
            await h.settle()
            h.model.idleMintTail()
            await h.settle()
            #expect(try h.storeSlots().map(\.text) == ["existing", "A\n", "B"])
            #expect(h.documentText == "existing\nA\n\nB")
            try expectStoreMatchesView(h)
        }
    }

    /// The reopened-tail half of the same fix: Enter after a minted block
    /// opens the tail (the separator gesture); FURTHER Enters are typed
    /// blank lines and attach eagerly as the block's trailing content —
    /// durable the moment they exist, successor or not.
    @Test func entersAfterAMintedBlockPersistAsItsTrailingContent() async throws {
        try await withEditor(seedBlocks: ["alpha"]) { h in
            h.type("\n", at: 5)   // opens the tail — this one IS the separator
            #expect(h.model.hasOpenTail)
            h.type("\n")           // a typed blank line: content, attached
            await h.settle()
            #expect(h.documentText == "alpha\n\n")
            #expect(try h.storeSlots().map(\.text) == ["alpha\n"])
            try expectStoreMatchesView(h)
        }
    }

    /// Round 2, MINOR (red-on-current): the QUIT door must land the
    /// leading-run attachment's record inside the awaited finalize task —
    /// the delegate replies terminateNow right after `await task.value`,
    /// so a record left in the 500 ms autosave debounce dies with the
    /// process and the typed gap collapses on relaunch.
    @Test func quitTimeFinalizeLandsTheAttachedGapBeforeReturning() async throws {
        try await withEditor(seedBlocks: ["alpha"]) { h in
            h.type("\n", at: 5)   // open the tail
            h.type("A")
            h.type("\n")
            h.type("\n")           // the typed gap… then ⌘Q inside the idle window
            await h.model.finalizeWork()?.value  // the delegate awaits ONLY this
            let texts = try await h.database.read { [postID = h.postID] db in
                try Queries.renderPost(db, containerID: postID).map { $0.text ?? "" }
            }
            #expect(texts == ["alpha", "A\n"],
                    "the typed gap survives ⌘Q — the attachment lands inside the awaited task")
        }
    }

    /// The paste half of the same ruling, end to end through the editor.
    @Test func pastedBlankLinesPersistOnSurfaceAndStore() async throws {
        try await withEditor(seedBlocks: ["existing"]) { h in
            h.type("\n", at: 8)             // open the tail
            h.textView.withPasteFlag {
                h.type("One.\n\nTwo.\n\n\nThree tail")
            }
            await h.settle()
            let slots = try h.storeSlots()
            #expect(slots.map(\.text) == ["existing", "One.\n", "Two.\n\n", "Three tail"])
            #expect(h.documentText == "existing\nOne.\n\nTwo.\n\n\nThree tail",
                    "the paste reproduces byte-for-byte")
            #expect(!h.model.hasOpenTail)
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

    /// Phase 10 Step 1 — the KnownIssues echo-detection pin (red on old):
    /// detecting our own autosave echo must not read the surface at all.
    /// The old path extracted `attributedSubstring` for EVERY slot on each
    /// clean projection arrival — O(post length) main-thread work at
    /// debounce rate, 40 reads for this post; the map-based check performs
    /// zero.
    @Test func anEchoProjectionPerformsZeroSurfaceReads() async throws {
        let blocks = (0..<40).map { "block \($0) text with some words in it" }
        try await withEditor(seedBlocks: blocks) { h in
            h.type("!", at: 5)
            await h.flush()
            let echo = try h.storeSlots()
            let surface = h.documentText
            let reads = h.model.surfaceTextReads
            h.model.applyProjection(echo)  // the echo of our own autosave
            #expect(h.model.surfaceTextReads - reads == 0)
            #expect(h.documentText == surface)  // and it stayed an echo: untouched
            try expectStoreMatchesView(h)
        }
    }

    /// The soundness half of the Step 1 fix: the map must never claim an
    /// EXTERNAL same-length change is our echo — the surface re-renders.
    @Test func aSameLengthExternalChangeIsNotMistakenForAnEcho() async throws {
        try await withEditor(seedBlocks: ["alpha", "beta"]) { h in
            let slots = try h.storeSlots()
            // Same length as "alpha", different text (sync, another window).
            try h.session.operations.autosave(
                slots[0].variantID!, text: "ALPHA", charDelta: 5)
            try h.reload()
            #expect(h.documentText == "ALPHA\nbeta")
            try expectStoreMatchesView(h)
        }
    }
}

@MainActor
@Suite("Review-round fixes (round 1)")
struct ReviewRoundFixTests {
    // MAJOR 1: a refused flush must never drop typed text nor let an older
    // projection overwrite the surface.
    @Test func aRemoteLockMidTypingNeverLosesTheBuffer() async throws {
        try await withEditor(seedBlocks: ["guarded text", "other"]) { h in
            h.type(" plus typing", at: 12)          // dirty (debounce pending)
            let slots = try h.storeSlots()
            // The lock lands remotely while the debounce window is open.
            try h.session.operations.lockVariant(slots[0].variantID!)
            try h.reload()                          // deferred: buffer is dirty
            await h.model.autosave.flushNow()       // the flush refuses
            // The surface keeps the typed text; the store kept the old text;
            // nothing clobbered either way.
            #expect(h.documentText == "guarded text plus typing\nother")
            #expect(h.model.autosave.isDirty)       // still pending, visibly
            #expect(h.model.statusMessage != nil)
            let storeText = try h.storeSlots()[0].text
            #expect(storeText == "guarded text")
            // The user unlocks; the retry lands the buffer exactly.
            try h.session.operations.unlockVariant(slots[0].variantID!)
            await h.flush()
            let retried = try h.storeSlots()[0].text
            #expect(retried == "guarded text plus typing")
            try expectStoreMatchesView(h)
        }
    }

    // MAJOR 2: the deferred projection is stale by construction — settle
    // must re-fetch, so the just-flushed block is never transiently
    // reverted and external changes still arrive.
    @Test func deferredProjectionsReFetchAtSettle() async throws {
        try await withEditor(seedBlocks: ["mine", "theirs"]) { h in
            h.type("!", at: 4)                      // dirty
            let slots = try h.storeSlots()
            // An external write lands while we are dirty; its projection
            // (fetched pre-flush) arrives and defers.
            try h.session.operations.autosave(
                slots[1].variantID!, text: "theirs, rewritten", charDelta: 10)
            try h.reload()                          // deferred (stale value)
            await h.model.autosave.flushNow()       // clean; settle re-fetches
            for _ in 0..<2000 {
                if h.documentText.contains("theirs, rewritten") { break }
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            // Both survive: our typed text was never reverted, theirs shows.
            #expect(h.documentText == "mine!\ntheirs, rewritten")
            try expectStoreMatchesView(h)
        }
    }

    // MAJOR 3: paste into an existing BLOCK is a content edit and must not
    // poison the next tail keystroke into bulk crystallization.
    @Test func pasteIntoABlockDoesNotArmBulkEntry() async throws {
        try await withEditor(seedBlocks: ["target block"]) { h in
            h.textView.withPasteFlag {
                h.type("A\nB", at: 6)               // paste INSIDE the block
            }
            await h.flush()
            var slots = try h.storeSlots()
            #expect(slots.count == 1)               // content edit, no mints
            #expect(slots[0].text == "targetA\nB block")
            // Now open the tail and TYPE one character: typing semantics —
            // the partial paragraph must NOT mint (with the old bug the
            // armed bulk flag minted it instantly and closed the tail).
            h.type("\n", at: (h.documentText as NSString).length)
            h.type("x")
            await h.settle()
            slots = try h.storeSlots()
            #expect(slots.count == 1)               // still just the block
            #expect(h.model.hasOpenTail)            // tail open, unminted
            try expectStoreMatchesView(h)
        }
    }

    // Author ruling (QUESTIONS 2): idle-mint — a quiet gap crystallizes the
    // open tail including the trailing partial paragraph.
    @Test func idleMintCrystallizesTheQuietTail() async throws {
        try await withEditor(seedBlocks: ["existing"]) { h in
            h.type("\n", at: 8)
            h.type("half a paragraph")
            await h.settle()
            let beforeIdle = try h.storeSlots()
            #expect(beforeIdle.count == 1)          // typing alone: no mint
            h.model.idleMintTail()                  // the quiet gap elapses
            await h.settle()
            let slots = try h.storeSlots()
            #expect(slots.map(\.text) == ["existing", "half a paragraph"])
            #expect(!h.model.hasOpenTail)           // tail closed
            #expect(h.documentText == "existing\nhalf a paragraph")
            try expectStoreMatchesView(h)
            // Resumed typing extends the idle-minted block — the final
            // structure matches what typing-past would have produced.
            h.type(" continues", at: (h.documentText as NSString).length)
            await h.flush()
            let extended = try h.storeSlots()[1].text
            #expect(extended == "half a paragraph continues")
        }
    }

    // Review round 2: idle-mint never fires under an active input-method
    // composition — marked text is not yet the author's text, and minting
    // would rewrite the region mid-composition.
    @Test func idleMintSkipsAnActiveIMEComposition() async throws {
        try await withEditor(seedBlocks: ["existing"]) { h in
            h.type("\n", at: 8)
            h.type("composing ")
            h.textView.setMarkedText(
                "げ", selectedRange: NSRange(location: 0, length: 1),
                replacementRange: h.textView.selectedRange())
            #expect(h.textView.hasMarkedText())
            h.model.idleMintTail()                  // quiet gap elapses mid-composition
            await h.settle()
            #expect(try h.storeSlots().count == 1)  // nothing minted
            #expect(h.model.hasOpenTail)            // tail still open
            h.textView.unmarkText()                 // composition commits
            h.model.idleMintTail()
            await h.settle()
            #expect(try h.storeSlots().count == 2)  // now it mints
            #expect(!h.model.hasOpenTail)
            try expectStoreMatchesView(h)
        }
    }

    // MINOR 5: teardown finalization waits out an in-flight mint and mints
    // the residual tail; a sealed-post refusal is surfaced, never silent.
    @Test func finalizeWorkMintsTheResidualTailEvenMidMint() async throws {
        try await withEditor(seedBlocks: ["existing"]) { h in
            h.type("\n", at: 8)
            h.type("typed past\nstill open")        // mint of "typed past" goes in flight
            let task = try #require(h.model.finalizeWork())
            await task.value
            let slots = try h.storeSlots()
            #expect(slots.map(\.text) == ["existing", "typed past", "still open"])
            try expectStoreMatchesView(h)
        }
    }

    @Test func finalizeWorkSurfacesASealedRefusal() async throws {
        try await withEditor(seedBlocks: ["existing"]) { h in
            h.type("\n", at: 8)
            h.type("tail text")
            await h.settle()
            // Sealed remotely while the tail is open (ops-level: the editor
            // header hasn't refreshed, so the mint is attempted and refused).
            try h.session.operations.lockPost(h.postID)
            let task = try #require(h.model.finalizeWork())
            await task.value
            #expect(h.model.statusMessage?.contains("sealed") == true)
            // The tail text is still in the buffer, not silently dropped.
            #expect(h.documentText == "existing\ntail text")
            let unminted = try h.storeSlots()
            #expect(unminted.count == 1)
        }
    }

    // MINOR 6: a reconciler compensating deletion is internal bookkeeping —
    // it must NOT land on the structural undo stack.
    @Test func compensatingDeletionsRegisterNoUndo() async throws {
        try await withEditor(seedBlocks: ["existing"]) { h in
            h.type("\n", at: 8)
            h.type("para\n")                        // plans a mint of "para"
            // Before the mint task runs, un-type the paragraph entirely:
            // the reconciler must delete the minted block quietly.
            h.replace(NSRange(location: 9, length: 5), with: "")
            await h.settle()
            for _ in 0..<2000 {
                if (try? h.storeSlots())?.count == 1 { break }
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            let slots = try h.storeSlots()
            #expect(slots.map(\.text) == ["existing"])   // block deleted again
            #expect(h.session.undoStack.depth == 0)       // and NO undo entry
            #expect(h.model.hasOpenTail)
        }
    }

    // NIT 12: restore targets the variant whose history is open, even if
    // the caret moved after loading it.
    @Test func restoreTargetsTheLoadedHistoryNotTheCaret() async throws {
        try await withEditor(seedBlocks: ["committed once", "elsewhere"]) { h in
            let slots = try h.storeSlots()
            _ = try h.session.operations.commit(slots[0].variantID!)
            try h.session.operations.autosave(
                slots[0].variantID!, text: "changed since", charDelta: 5)
            try h.reload()
            h.textView.setSelectedRange(NSRange(location: 0, length: 0))
            h.model.updateCaretContext()
            await h.model.loadCommitHistory()
            let item = try #require(h.model.commitList?.first)
            // The caret wanders to the OTHER block before confirming.
            h.textView.setSelectedRange(NSRange(location: 15, length: 0))
            h.model.updateCaretContext()
            h.model.restore(item)
            await h.settle()
            for _ in 0..<2000 {
                if (try? h.storeSlots())?[0].text == "committed once" { break }
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            let restored = try h.storeSlots()
            #expect(restored[0].text == "committed once")
            #expect(restored[1].text == "elsewhere")               // untouched
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
