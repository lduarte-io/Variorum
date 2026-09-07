import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// **"Make every newline a block"** — the state-transition suite for
/// `Operations.splitBlockAtNewlines` (her ruling U-6, 2026-09-06; 18c batch
/// 3). The break rule itself is pinned pure in `NewlineSplittingTests`; this
/// suite is about the ROWS: what the store holds afterwards, what the takes
/// did, what one ⌥⌘Z restores, and what the op refuses.
@Suite("Split at newlines (18c batch 3 — U-6)")
struct StructuralSplitAtNewlinesTests {
    /// The live texts of a post's blocks, in reading order.
    private func texts(_ db: AppDatabase, in postID: String) throws -> [String] {
        try db.read { db in
            try Queries.renderPost(db, containerID: postID).compactMap(\.text)
        }
    }

    private func fanTexts(_ db: AppDatabase, of blockID: String) throws -> [String] {
        try db.read { db in
            try Queries.blockFan(db, blockID: blockID)
                .filter { $0.deletedAt == nil && $0.status == .active }
                .map(\.workingText)
        }
    }

    // MARK: - The single-take road

    @Test func aThreeParagraphBlockBecomesThreeBlocksInOrderKeepingAsIdentity() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let before = try ops.newBlock(in: post.id, text: "before")
            let a = try ops.newBlock(in: post.id, text: "One.\nTwo.\nThree.")
            let after = try ops.newBlock(in: post.id, text: "after")

            let result = try ops.splitBlockAtNewlines(a.block.id)

            #expect(result.blocksMade == 3)
            #expect(result.blockIDs.first == a.block.id, "A keeps its identity as paragraph 1")
            #expect(result.takesKeptOnTop == 0)
            #expect(try liveBlockOrder(db, in: post.id)
                == [before.block.id] + result.blockIDs + [after.block.id])
            #expect(try texts(db, in: post.id) == ["before", "One.", "Two.", "Three.", "after"])
            // A's own variant row is the one that was there — nothing was
            // re-minted for the first paragraph.
            #expect(try db.fetchString(
                "SELECT working_text FROM variant WHERE id = ?", [a.variant.id]) == "One.")
        }
    }

    @Test func everyMintedBlockCarriesItsLineageEdgeAndAsPresentation() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "One.\nTwo.\nThree.")
            let frame = BlockPresentation(kind: BlockPresentation.calloutKind, color: "sand")
            try ops.setBlockPresentation(a.block.id, frame)

            let result = try ops.splitBlockAtNewlines(a.block.id)

            for minted in result.blockIDs.dropFirst() {
                let ancestor = try db.fetchString(
                    """
                    SELECT target_block_id FROM edge
                    WHERE source_block_id = ? AND type = 'derived_from' AND deleted_at IS NULL
                    """, [minted])
                #expect(ancestor != nil, "each successor points back at what it came from")
                #expect(try db.fetchString(
                    "SELECT presentation FROM block WHERE id = ?", [minted])
                    == (try frame.encodedJSON()), "the frame travels, as any divide's does")
            }
        }
    }

    /// **Her spacing survives — the declared reading of §5.1's parenthetical.**
    /// The seam trim is the ONE cut brain's, so a blank line leaves its k−1
    /// newline on the preceding block (her A11 ruling) and the page reads
    /// byte-identically after the repair.
    @Test func splittingAtABlankLineKeepsHerSpacingExactly() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "One.\n\nTwo.\n\n\nThree.")
            let rendered = try db.read { try Queries.renderedText($0, containerID: post.id) }

            let result = try ops.splitBlockAtNewlines(a.block.id)

            #expect(result.blocksMade == 3)
            #expect(try texts(db, in: post.id) == ["One.\n", "Two.\n\n", "Three."])
            #expect(try db.read { try Queries.renderedText($0, containerID: post.id) } == rendered,
                    "the note reads exactly as it did — nothing she typed disappeared")
        }
    }

    @Test func aListStaysWholeInsideItsOwnBlock() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(
                in: post.id, text: "Intro line\n- one\n  - nested\n- two\nOutro line")

            let result = try ops.splitBlockAtNewlines(a.block.id)

            #expect(result.blocksMade == 3)
            #expect(try texts(db, in: post.id)
                == ["Intro line", "- one\n  - nested\n- two", "Outro line"])
        }
    }

    // MARK: - The no-op

    @Test func aBlockWithNoBreakIsANoOpDownToTheOutboxRow() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "Already one paragraph.")
            let containerBefore = try #require(try db.snapshotRow("container", post.id, excluding: []))
            let variantBefore = try #require(try db.snapshotRow("variant", a.variant.id, excluding: []))
            try db.clearOutbox()
            let stack = UndoStack()
            let stackedOps = Operations(undoStack: stack)

            let result = try stackedOps.splitBlockAtNewlines(a.block.id)

            #expect(result.isNoOp)
            #expect(result.blockIDs == [a.block.id])
            #expect(try db.snapshotRow("container", post.id, excluding: []) == containerBefore,
                    "no touch, no churn")
            #expect(try db.snapshotRow("variant", a.variant.id, excluding: []) == variantBefore)
            #expect(try db.fetchInt("SELECT COUNT(*) FROM sync_outbox") == 0,
                    "nothing was written, so nothing is pending for sync")
            #expect(stack.depth == 0, "and there is nothing to undo")
        }
    }

    @Test func aBlockThatIsAllBlankLinesIsANoOp() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "\n\nOnly one.\n\n")
            #expect(try ops.splitBlockAtNewlines(a.block.id).isNoOp)
            #expect(try texts(db, in: post.id) == ["\n\nOnly one.\n\n"])
        }
    }

    // MARK: - The fanned road (keep-on-top)

    /// *"If you had a multi paragraph block now the top paragraph is a block
    /// with all the takes"* — her sentence, as rows.
    @Test func aFannedBlockLeavesEveryTakeOnTheTopParagraph() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "One.\nTwo.\nThree.")
            let take2 = try ops.branchVariant(a.block.id, from: a.variant.id)
            try ops.autosave(take2.id, text: "Take two, whole.", charDelta: 0)
            let take3 = try ops.branchVariant(a.block.id, from: take2.id)
            try ops.autosave(take3.id, text: "Take three, whole.", charDelta: 0)

            let result = try ops.splitBlockAtNewlines(a.block.id)

            #expect(result.blocksMade == 3)
            #expect(result.takesKeptOnTop == 2)
            #expect(result.takesLeftBehind == 0)
            #expect(try fanTexts(db, of: result.blockIDs[0])
                == ["One.", "Take two, whole.", "Take three, whole."],
                    "B = paragraph 1 (chosen, leading) + every other take WHOLE")
            #expect(try fanTexts(db, of: result.blockIDs[1]) == ["Two."])
            #expect(try fanTexts(db, of: result.blockIDs[2]) == ["Three."])
            #expect(try texts(db, in: post.id) == ["One.", "Two.", "Three."],
                    "the page still reads the take she was in, straight down")
            // A is preserved WHOLE and released to lineage (the W's own rule).
            #expect(try db.deletedAt("block", a.block.id) == nil)
            #expect(try db.deletedAt("container_block", a.placement.id) != nil)
            #expect(try db.fetchString(
                "SELECT working_text FROM variant WHERE id = ?", [a.variant.id])
                == "One.\nTwo.\nThree.")
        }
    }

    @Test func aRiddenTakeKeepsItsName() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "One.\nTwo.")
            let spare = try ops.branchVariant(a.block.id, from: a.variant.id)
            try ops.autosave(spare.id, text: "The spare.", charDelta: 0)
            try ops.setTakeLabel(spare.id, label: "the spare")

            let result = try ops.splitBlockAtNewlines(a.block.id)

            let labels = try db.read { db in
                try Queries.blockFan(db, blockID: result.blockIDs[0]).map(\.label)
            }
            #expect(labels == [nil, "the spare"], "a whole-take ride keeps its name")
        }
    }

    /// The composition's own edge: an EMPTY take cannot park (0 and its end
    /// coincide), so it stays on A in lineage — counted, never swallowed.
    @Test func anEmptyOtherTakeStaysOnTheOriginalAndIsCounted() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "One.\nTwo.")
            let blank = try ops.newBlankVariant(a.block.id)

            let result = try ops.splitBlockAtNewlines(a.block.id)

            #expect(result.takesKeptOnTop == 0)
            #expect(result.takesLeftBehind == 1)
            #expect(try fanTexts(db, of: result.blockIDs[0]) == ["One."])
            #expect(try db.fetchString(
                "SELECT block_id FROM variant WHERE id = ?", [blank.id]) == a.block.id,
                    "the empty take stayed with the original block")
        }
    }

    @Test func onlyTheDisplayedTakesNewlinesDecideTheBreaks() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "One.\nTwo.")
            let take2 = try ops.branchVariant(a.block.id, from: a.variant.id)
            // A take with FIVE paragraphs of its own — it rides whole, and
            // its newlines are nobody's business (§5.1: the breaks come from
            // the DISPLAYED take).
            try ops.autosave(take2.id, text: "a\nb\nc\nd\ne", charDelta: 0)

            let result = try ops.splitBlockAtNewlines(a.block.id)

            #expect(result.blocksMade == 2)
            #expect(try fanTexts(db, of: result.blockIDs[0]) == ["One.", "a\nb\nc\nd\ne"])
        }
    }

    @Test func theChosenTakeIsTheOneThatSplitsEvenWhenItIsNotTheFirst() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "no breaks here")
            let take2 = try ops.branchVariant(a.block.id, from: a.variant.id)
            try ops.autosave(take2.id, text: "One.\nTwo.", charDelta: 0)
            try ops.chooseVariant(a.block.id, variantID: take2.id)

            let result = try ops.splitBlockAtNewlines(a.block.id)

            #expect(result.blocksMade == 2)
            #expect(try texts(db, in: post.id) == ["One.", "Two."],
                    "the page reads the take it was showing, split")
            // Source fan ORDER is what B's fan keeps (`divideW`'s own rule),
            // so the parked first take leads and the split half sits behind
            // it — but the CHOSEN one is the half, which is what the page
            // above just proved.
            #expect(try fanTexts(db, of: result.blockIDs[0]) == ["no breaks here", "One."])
        }
    }

    // MARK: - Refusals

    @Test func aSealedPostRefusesTheWholeSplit() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "One.\nTwo.")
            try ops.lockPost(post.id)

            #expect(throws: OperationError.self) { try ops.splitBlockAtNewlines(a.block.id) }
            #expect(try texts(db, in: post.id) == ["One.\nTwo."], "nothing moved")
        }
    }

    @Test func aLockedSingleTakeRefusesAndLeavesNoHalfSplit() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "One.\nTwo.\nThree.")
            try ops.lockVariant(a.variant.id)

            #expect(throws: OperationError.self) { try ops.splitBlockAtNewlines(a.block.id) }
            #expect(try texts(db, in: post.id) == ["One.\nTwo.\nThree."],
                    "one transaction: the first divide rolled back with the refusal")
        }
    }

    @Test func anUnplacedBlockRefuses() throws {
        try withOperations { ops, _ in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "One.\nTwo.")
            let b = try ops.newBlock(in: post.id, text: "second")
            _ = try ops.merge(a.block.id, b.block.id)  // releases both to lineage
            #expect(throws: OperationError.self) { try ops.splitBlockAtNewlines(a.block.id) }
        }
    }

    // MARK: - Undo and redo

    @Test func oneUndoPutsTheWholeBlockBackAndRedoSplitsItAgainExactRow() throws {
        let stack = UndoStack()
        try withOperations { _, db in
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let before = try ops.newBlock(in: post.id, text: "before")
            let a = try ops.newBlock(in: post.id, text: "One.\n\nTwo.\nThree.")
            let after = try ops.newBlock(in: post.id, text: "after")

            let result = try ops.splitBlockAtNewlines(a.block.id)
            #expect(stack.depth == 1, "ONE entry for the block, not one per divide")
            #expect(stack.topLabel == "Split at Newlines")

            _ = try stack.undo(with: ops)
            #expect(try texts(db, in: post.id) == ["before", "One.\n\nTwo.\nThree.", "after"])
            #expect(try liveBlockOrder(db, in: post.id)
                == [before.block.id, a.block.id, after.block.id])
            for minted in result.blockIDs.dropFirst() {
                #expect(try db.deletedAt("block", minted) != nil)
            }
            // An untouched mint vanishes as if never made — it must not
            // haunt the deleted-blocks tray.
            #expect(try db.fetchString(
                "SELECT last_container_id FROM block WHERE id = ?", [result.blockIDs[1]]) == nil)

            _ = try stack.redo(with: ops)
            #expect(try liveBlockOrder(db, in: post.id)
                == [before.block.id] + result.blockIDs + [after.block.id],
                    "exact-row: the SAME successor blocks came back")
            #expect(try texts(db, in: post.id)
                == ["before", "One.\n", "Two.", "Three.", "after"])
        }
    }

    @Test func oneUndoOfAFannedSplitRestoresAWholeWithItsFan() throws {
        let stack = UndoStack()
        try withOperations { _, db in
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "One.\nTwo.\nThree.")
            let take2 = try ops.branchVariant(a.block.id, from: a.variant.id)
            try ops.autosave(take2.id, text: "Take two.", charDelta: 0)

            let result = try ops.splitBlockAtNewlines(a.block.id)
            #expect(stack.depth == 1)

            _ = try stack.undo(with: ops)
            #expect(try liveBlockOrder(db, in: post.id) == [a.block.id])
            #expect(try fanTexts(db, of: a.block.id) == ["One.\nTwo.\nThree.", "Take two."])

            _ = try stack.redo(with: ops)
            #expect(try liveBlockOrder(db, in: post.id) == result.blockIDs)
            #expect(try fanTexts(db, of: result.blockIDs[0]) == ["One.", "Take two."])
            #expect(try db.deletedAt("container_block", a.placement.id) != nil)
        }
    }

    /// The note-wide door's shape: many blocks, ONE compound entry — the
    /// `withCompound` road the Mac doors take.
    @Test func aWholeNoteSplitsUnderOneCompoundUndoEntry() throws {
        let stack = UndoStack()
        try withOperations { _, db in
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let one = try ops.newBlock(in: post.id, text: "A one.\nA two.")
            let two = try ops.newBlock(in: post.id, text: "Already whole.")
            let three = try ops.newBlock(in: post.id, text: "C one.\nC two.\nC three.")

            let results = try stack.withCompound(label: "Split at Newlines", operations: ops) {
                try [one, two, three].map { try ops.splitBlockAtNewlines($0.block.id) }
            }

            #expect(results.map(\.blocksMade) == [2, 1, 3])
            #expect(results[1].isNoOp)
            #expect(stack.depth == 1, "one ⌥⌘Z for the whole note")
            #expect(try texts(db, in: post.id)
                == ["A one.", "A two.", "Already whole.", "C one.", "C two.", "C three."])

            _ = try stack.undo(with: ops)
            #expect(try texts(db, in: post.id)
                == ["A one.\nA two.", "Already whole.", "C one.\nC two.\nC three."])
            #expect(try liveBlockOrder(db, in: post.id)
                == [one.block.id, two.block.id, three.block.id])

            _ = try stack.redo(with: ops)
            #expect(try texts(db, in: post.id)
                == ["A one.", "A two.", "Already whole.", "C one.", "C two.", "C three."])
        }
    }

    // MARK: - Sync shape

    @Test func everyRowItWritesIsAnOrdinaryOutboxedRow() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "One.\nTwo.")
            try db.clearOutbox()

            let result = try ops.splitBlockAtNewlines(a.block.id)

            // Ordinary operations, ordinary trigger-fed outbox — nothing in
            // `Sync/` knows this operation exists (S1).
            #expect(try db.outboxContains("variant", a.variant.id))
            #expect(try db.outboxContains("block", result.blockIDs[1]))
            #expect(try db.outboxContains("container_block", try #require(
                db.fetchString(
                    "SELECT id FROM container_block WHERE block_id = ? AND deleted_at IS NULL",
                    [result.blockIDs[1]]))))
        }
    }

    // MARK: - Comments travel

    @Test func theSuccessorsGetCopiesOfTheBlocksComments() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "One.\nTwo.\nThree.")
            _ = try ops.addBlockComment(to: a.block.id, text: "a working note")

            let result = try ops.splitBlockAtNewlines(a.block.id)

            for blockID in result.blockIDs {
                #expect(try db.fetchInt(
                    "SELECT COUNT(*) FROM block_comment WHERE block_id = ? AND deleted_at IS NULL",
                    [blockID]) == 1, "the divide's own travel rule, once per successor")
            }
        }
    }
}
