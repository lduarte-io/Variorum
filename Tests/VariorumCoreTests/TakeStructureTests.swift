import Foundation
import GRDB
import Testing
@testable import VariorumCore

// Phase 13e, batch 3 — take↔block structure (E5: her A20, *"shortcut for
// moving a take into being a new block beneath the current block"*; E6: her
// A21, *"keyboard shortcut for copying all takes together to clipboard, or
// turning all takes into their own blocks"* — the A45 repair tool).
//
// This file holds the CORE half. The clipboard suite pins `Queries.blockTakes`
// — the projection E6's clipboard door copies — against the ratified export
// shape it must never diverge from: ONE rule for "which takes count", so the
// door's confirmation and the copied text can never disagree.

@Suite("The clipboard projection (13e E6, A21's clipboard half)")
struct BlockTakesProjectionTests {
    @Test func aLoneTakeIsOneTakeAndTheTextIsJustItsProse() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let block = try ops.newBlock(in: post.id, text: "Only take.")
            let copy = try db.read { try Queries.blockTakes($0, blockID: block.block.id) }
            #expect(copy.markdown == "Only take.")
            #expect(copy.takeCount == 1)
        }
    }

    @Test func theProjectionIsExportBlocksOwnBytes() throws {
        // The one-rule claim, as an equality: `exportBlock` DELEGATES here, so
        // a future change to either cannot silently give the clipboard a
        // different shape than the export she already knows.
        try withOperations { ops, db in
            let post = try ops.createPost()
            let block = try ops.newBlock(in: post.id, text: "Shown take.")
            let second = try ops.branchVariant(block.block.id, from: block.variant.id)
            try ops.autosave(second.id, text: "Second take.", charDelta: 0)
            try ops.setTakeLabel(second.id, label: "bolder")

            let (markdown, count) = try db.read {
                try Queries.blockTakes($0, blockID: block.block.id)
            }
            let exported = try db.read { try Queries.exportBlock($0, blockID: block.block.id) }
            #expect(markdown == exported)
            #expect(count == 2)
            // The ratified fan shape: the shown take, then the labeled
            // alternates section (`take: "<label>"`).
            #expect(markdown.contains("--- Alternates for this block ---"))
            #expect(markdown.contains("take: \"bolder\""))
            #expect(markdown.contains("Second take."))
        }
    }

    @Test func blankAndArchivedTakesAreOutOfTheCountAsTheyAreOutOfTheExport() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let block = try ops.newBlock(in: post.id, text: "Shown take.")
            let blank = try ops.newBlankVariant(block.block.id)          // no text
            let archived = try ops.branchVariant(block.block.id, from: block.variant.id)
            try ops.autosave(archived.id, text: "Was a contender.", charDelta: 0)
            try ops.archiveVariant(archived.id)
            let alive = try ops.branchVariant(block.block.id, from: block.variant.id)
            try ops.autosave(alive.id, text: "Still in the fan.", charDelta: 0)

            let copy = try db.read { try Queries.blockTakes($0, blockID: block.block.id) }
            // Shown + the one live active non-blank alternate: the export's
            // ratified rule, stated as a number.
            #expect(copy.takeCount == 2)
            #expect(copy.markdown.contains("Still in the fan."))
            #expect(copy.markdown.contains("Was a contender.") == false)
            _ = blank
        }
    }

    @Test func anEmptyShownTakeCountsNothingAndADeadBlockProjectsNothing() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let empty = try ops.newBlock(in: post.id, text: "")
            let emptyCopy = try db.read { try Queries.blockTakes($0, blockID: empty.block.id) }
            #expect(emptyCopy.markdown.isEmpty)
            #expect(emptyCopy.takeCount == 0)

            let block = try ops.newBlock(in: post.id, text: "Doomed.")
            try ops.deleteBlock(block.block.id)
            let deadCopy = try db.read { try Queries.blockTakes($0, blockID: block.block.id) }
            #expect(deadCopy.markdown.isEmpty)
            #expect(deadCopy.takeCount == 0)
        }
    }

    @Test func aSealedNotesTakesStillCopy() throws {
        // Reading is never authoring: the clipboard door writes no row, so the
        // seal has nothing to refuse (the export precedent — a sealed post
        // exports fine).
        try withOperations { ops, db in
            let post = try ops.createPost()
            let block = try ops.newBlock(in: post.id, text: "Sealed prose.")
            try ops.lockPost(post.id)
            let copy = try db.read { try Queries.blockTakes($0, blockID: block.block.id) }
            #expect(copy.markdown == "Sealed prose.")
            #expect(copy.takeCount == 1)
        }
    }
}
