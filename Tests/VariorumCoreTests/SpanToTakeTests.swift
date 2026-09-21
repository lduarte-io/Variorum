import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// **SELECTION → A TAKE ON THE SAME BLOCK** (13u4 UNIT C2 — her item 9,
/// ruled at the kickoff sitting as **R-13u4-4**): *"move alone should be fine
/// - the fact that there'll be a savepoint/commit of the current take right
/// before moving is enough to cover the case that someone wants it to stay -
/// they can just revert it to that point if they want."*
///
/// The state-transition suite: rows read and written, the LOAD-BEARING
/// savepoint, every refusal, and the undo↔redo round trip to the same rows.
@Suite("Selection → a take on the same block (R-13u4-4)")
struct SpanToTakeTests {

    // MARK: - The shape, row by row

    /// The whole ruled shape in one pin: the span leaves the take it was in,
    /// a new take holds it at the fan's END, branched from that take, and
    /// NOTHING chooses it.
    @Test func theSpanLeavesTheTakeAndAFreshTakeAtTheFansEndHoldsIt() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "note", profile: .blog)
            let minted = try ops.seedBlock(in: post.id, text: "one two three four")

            // " two three" — offsets 3..<13 of "one two three four"
            let result = try ops.moveSpanToNewTake(
                from: minted.variant.id, span: 3..<13)

            let source = try db.read { db in try Variant.fetchOne(db, key: minted.variant.id) }
            #expect(source?.workingText == "one four", "the span left, exactly as selected")
            #expect(result.take.workingText == " two three",
                    "the take holds the span VERBATIM — no trimming, no snapping")
            #expect(result.take.blockId == minted.block.id, "the SAME block")
            #expect(result.take.parentVariantId == minted.variant.id, "branched from it")
            #expect(result.take.label == nil)
            #expect(result.take.locked == false)
            #expect(result.take.status == .active)

            let fan = try db.read { db in try Queries.blockFan(db, blockID: minted.block.id) }
            #expect(fan.map(\.id) == [minted.variant.id, result.take.id],
                    "at the fan's END, behind the take it came out of")

            // NOT chosen — neither pointer moved.
            let chosen = try db.fetchString(
                "SELECT chosen_variant_id FROM container_block WHERE block_id = ? AND deleted_at IS NULL",
                [minted.block.id])
            #expect(chosen == minted.variant.id)
            let defaultID = try db.fetchString(
                "SELECT default_variant_id FROM block WHERE id = ?", [minted.block.id])
            #expect(defaultID == minted.variant.id)
        }
    }

    /// The fan's END means the end, not "after the take it came from" —
    /// `branchVariant` places a branch BESIDE its source and this deliberately
    /// does not (R-13u4-4's own word).
    @Test func aBlockThatAlreadyCarriesTakesGetsTheMintAtTheVeryEnd() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "note", profile: .blog)
            let minted = try ops.seedBlock(in: post.id, text: "alpha beta")
            let second = try ops.branchVariant(minted.block.id, from: minted.variant.id)
            let third = try ops.newBlankVariant(minted.block.id)

            let result = try ops.moveSpanToNewTake(from: minted.variant.id, span: 0..<6)

            let fan = try db.read { db in try Queries.blockFan(db, blockID: minted.block.id) }
            #expect(fan.map(\.id)
                    == [minted.variant.id, second.id, third.id, result.take.id])
        }
    }

    /// Her whole-buffer case: the take is left EMPTY and that is legal (I10
    /// counts live ACTIVE takes, and the source take is still one of them).
    @Test func movingTheWholeBufferLeavesAnEmptyTakeAndBreaksNothing() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "note", profile: .blog)
            let minted = try ops.seedBlock(in: post.id, text: "everything")

            let result = try ops.moveSpanToNewTake(from: minted.variant.id, span: 0..<10)

            let source = try db.read { db in try Variant.fetchOne(db, key: minted.variant.id) }
            #expect(source?.workingText == "")
            #expect(source?.deletedAt == nil)
            #expect(source?.status == .active)
            #expect(result.take.workingText == "everything")
            // The block reads empty, because the empty take is still chosen.
            let rendered = try db.read { db in
                try Queries.renderPost(db, containerID: post.id).compactMap(\.text)
            }
            #expect(rendered == [""])
        }
    }

    /// No trimming, no snapping: a span selected mid-word with its
    /// whitespace comes out byte-for-byte, and the doubled space the removal
    /// leaves behind is HERS (U-19 (2) — QUESTIONS #128(a)).
    @Test func nothingIsTrimmedAndNothingIsSnapped() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "note", profile: .blog)
            let minted = try ops.seedBlock(in: post.id, text: "one two three")

            // "two" alone, leaving "one  three" with the doubled space.
            let result = try ops.moveSpanToNewTake(from: minted.variant.id, span: 4..<7)

            #expect(result.take.workingText == "two")
            let source = try db.read { db in try Variant.fetchOne(db, key: minted.variant.id) }
            #expect(source?.workingText == "one  three", "the seam is hers to tidy")
        }
    }

    // MARK: - The savepoint (LOAD-BEARING — her cover for the stay case)

    /// Her ruling's own mechanism: the take's state one keystroke before the
    /// move is a savepoint she can restore.
    @Test func theMoveLeavesAQuietSavepointOfTheTakeBeforeIt() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "note", profile: .blog)
            let minted = try ops.seedBlock(in: post.id, text: "keep this whole line")

            let result = try ops.moveSpanToNewTake(from: minted.variant.id, span: 5..<10)
            #expect(result.insuranceSavepoint?.kind == .auto)
            #expect(result.insuranceSavepoint?.text == "keep this whole line")

            // And it is a real restore road: her "I wanted it to stay".
            try ops.restoreCommit(
                minted.variant.id, commitID: #require(result.insuranceSavepoint).id)
            let source = try db.read { db in try Variant.fetchOne(db, key: minted.variant.id) }
            #expect(source?.workingText == "keep this whole line")
            // …and the moved take is still there beside it.
            let fan = try db.read { db in try Queries.blockFan(db, blockID: minted.block.id) }
            #expect(fan.count == 2)
        }
    }

    /// The standing dedupe (`isDirty`) — the five quiet occasions before this
    /// one share it. Nil does NOT mean "nothing to restore": the take's own
    /// last savepoint already holds the pre-move text byte-for-byte.
    @Test func aTakeAlreadySavedAtItsCurrentTextWritesNoSecondSavepoint() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "note", profile: .blog)
            let minted = try ops.seedBlock(in: post.id, text: "already saved here")
            let manual = try ops.commit(minted.variant.id)

            let result = try ops.moveSpanToNewTake(from: minted.variant.id, span: 0..<8)
            #expect(result.insuranceSavepoint == nil)

            let saved = try db.read { db in
                try Queries.commitHistory(db, variantID: minted.variant.id)
            }
            #expect(saved.map(\.id) == [manual.id])
            #expect(saved[0].text == "already saved here", "the cover still holds")
        }
    }

    // MARK: - Touch, churn, and the wire

    /// A buffer edit is a buffer edit: the note is touched and the removed
    /// characters churn (AppSpec §10). The mint itself adds no churn — fan
    /// growth never has.
    @Test func theNoteIsTouchedAndTheRemovedCharactersChurn() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "note", profile: .blog)
            let minted = try ops.seedBlock(in: post.id, text: "one two three four")
            let before = try db.fetchString(
                "SELECT last_touched_at FROM container WHERE id = ?", [post.id])

            _ = try ops.moveSpanToNewTake(from: minted.variant.id, span: 3..<13)

            let after = try db.fetchString(
                "SELECT last_touched_at FROM container WHERE id = ?", [post.id])
            #expect(after != nil)
            #expect(after != before)
            let churn = try db.read { db in
                try Double.fetchOne(
                    db, sql: "SELECT churn_accumulator FROM container WHERE id = ?",
                    arguments: [post.id])
            }
            #expect(churn == 10, "the span's ten UTF-16 units, deleted")
        }
    }

    /// S1's shape: three ordinary rows, all captured by the shipped outbox
    /// triggers. No engine line was written for this act and none is needed.
    @Test func everyRowItWritesIsQueuedForSync() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "note", profile: .blog)
            let minted = try ops.seedBlock(in: post.id, text: "one two three")
            try db.clearOutbox()

            let result = try ops.moveSpanToNewTake(from: minted.variant.id, span: 4..<7)

            #expect(try db.outboxContains("variant", result.take.id))
            #expect(try db.outboxContains("variant", minted.variant.id))
            #expect(try db.outboxContains(
                "commit_point", #require(result.insuranceSavepoint).id))
        }
    }

    // MARK: - The refusals (each the standing convention's, none invented)

    @Test func aSealedNoteRefuses() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "note", profile: .blog)
            let minted = try ops.seedBlock(in: post.id, text: "one two three")
            try ops.lockPost(post.id)

            #expect(throws: OperationError.lockedPost(id: post.id)) {
                try ops.moveSpanToNewTake(from: minted.variant.id, span: 4..<7)
            }
            let source = try db.read { db in try Variant.fetchOne(db, key: minted.variant.id) }
            #expect(source?.workingText == "one two three", "nothing moved")
        }
    }

    /// The lock guards the BUFFER, and the span leaving it is a buffer edit —
    /// so a locked take refuses, NAMING the lock.
    @Test func aLockedTakeRefusesNamingTheLock() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "note", profile: .blog)
            let minted = try ops.seedBlock(in: post.id, text: "one two three")
            try ops.lockVariant(minted.variant.id)

            #expect(throws: OperationError.lockedVariant(id: minted.variant.id)) {
                try ops.moveSpanToNewTake(from: minted.variant.id, span: 4..<7)
            }
            let fan = try db.read { db in try Queries.blockFan(db, blockID: minted.block.id) }
            #expect(fan.count == 1, "no take was minted either")
        }
    }

    @Test func anArchivedTakeRefuses() throws {
        try withOperations { ops, _ in
            let post = try ops.createPost(title: "note", profile: .blog)
            let minted = try ops.seedBlock(in: post.id, text: "one two three")
            _ = try ops.branchVariant(minted.block.id, from: minted.variant.id)
            try ops.archiveVariant(minted.variant.id)

            #expect(throws: OperationError.archivedVariant(id: minted.variant.id)) {
                try ops.moveSpanToNewTake(from: minted.variant.id, span: 4..<7)
            }
        }
    }

    /// The Phase 5 reject-path doctrine, applied to a door's plan: a buffer
    /// that moved between the plan and the write refuses the WHOLE gesture.
    @Test func aBufferThatMovedSinceTheGestureRefuses() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "note", profile: .blog)
            let minted = try ops.seedBlock(in: post.id, text: "one two three")

            #expect(throws: OperationError.bufferChangedSinceGesture(
                variantID: minted.variant.id)) {
                try ops.moveSpanToNewTake(
                    from: minted.variant.id, span: 4..<7,
                    expectedText: "one two three four")
            }
            let fan = try db.read { db in try Queries.blockFan(db, blockID: minted.block.id) }
            #expect(fan.count == 1)
        }
    }

    /// The caller-bug answer, not a road she can walk (the door plans the
    /// span from the surface's own tiling and never offers an empty one).
    @Test func anEmptyOrOutOfBoundsSpanRefuses() throws {
        try withOperations { ops, _ in
            let post = try ops.createPost(title: "note", profile: .blog)
            let minted = try ops.seedBlock(in: post.id, text: "one two")

            #expect(throws: OperationError.invalidCut(variantID: minted.variant.id, cut: 3)) {
                try ops.moveSpanToNewTake(from: minted.variant.id, span: 3..<3)
            }
            #expect(throws: OperationError.invalidCut(variantID: minted.variant.id, cut: 4)) {
                try ops.moveSpanToNewTake(from: minted.variant.id, span: 4..<99)
            }
        }
    }

    /// Grapheme alignment through the ONE brain: a span that would split a
    /// composed character refuses rather than minting half an emoji.
    @Test func aSpanThatWouldSplitAGraphemeRefuses() throws {
        try withOperations { ops, _ in
            let post = try ops.createPost(title: "note", profile: .blog)
            // A family emoji: several UTF-16 units, one grapheme.
            let minted = try ops.seedBlock(in: post.id, text: "a👨‍👩‍👧b")

            #expect(throws: OperationError.invalidCut(variantID: minted.variant.id, cut: 1)) {
                try ops.moveSpanToNewTake(from: minted.variant.id, span: 1..<3)
            }
        }
    }

    @Test func aDeadTakeRefuses() throws {
        try withOperations { ops, _ in
            let post = try ops.createPost(title: "note", profile: .blog)
            let minted = try ops.seedBlock(in: post.id, text: "one two three")
            let branched = try ops.branchVariant(minted.block.id, from: minted.variant.id)
            try ops.deleteVariant(branched.id)

            #expect(throws: OperationError.variantNotFound(id: branched.id)) {
                try ops.moveSpanToNewTake(from: branched.id, span: 4..<7)
            }
        }
    }

    // MARK: - ONE undo entry, and its exact-row redo

    @Test func theWholeGestureIsOneUndoEntry() throws {
        try withOperations { ops, _ in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost(title: "note", profile: .blog)
            let minted = try ops.seedBlock(in: post.id, text: "one two three")

            _ = try ops.moveSpanToNewTake(from: minted.variant.id, span: 4..<7)
            #expect(stack.depth == 1)
            #expect(stack.topLabel == "Move into a New Take")
        }
    }

    /// The inverse: the span comes home AND the minted take is tombstoned —
    /// one entry, both halves.
    @Test func undoBringsTheSpanHomeAndTakesTheMintAway() throws {
        try withOperations { ops, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost(title: "note", profile: .blog)
            let minted = try ops.seedBlock(in: post.id, text: "one two three")

            let result = try ops.moveSpanToNewTake(from: minted.variant.id, span: 3..<8)
            _ = try stack.undo(with: ops)

            let source = try db.read { db in try Variant.fetchOne(db, key: minted.variant.id) }
            #expect(source?.workingText == "one two three")
            #expect(try db.deletedAt("variant", result.take.id) != nil)
            let fan = try db.read { db in try Queries.blockFan(db, blockID: minted.block.id) }
            #expect(fan.map(\.id) == [minted.variant.id])
        }
    }

    /// The 13c 1B law: do → undo → redo returns the store to the post-do rows
    /// with every ID intact — never a fresh mint.
    @Test func undoThenRedoRoundTripsToTheSameRows() throws {
        try withOperations { ops, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost(title: "note", profile: .blog)
            let minted = try ops.seedBlock(in: post.id, text: "one two three")

            let result = try ops.moveSpanToNewTake(from: minted.variant.id, span: 3..<8)
            let afterDoMint = try db.snapshotRow("variant", result.take.id)
            let afterDoSource = try db.snapshotRow("variant", minted.variant.id)

            _ = try stack.undo(with: ops)
            _ = try stack.redo(with: ops)

            #expect(try db.snapshotRow("variant", result.take.id) == afterDoMint,
                    "the SAME row, not a fresh mint")
            #expect(try db.snapshotRow("variant", minted.variant.id) == afterDoSource)
            #expect(stack.depth == 1, "and the entry is back on the undo stack")
        }
    }

    /// Ping-pong: the entry moves between the two stacks without re-deriving
    /// anything.
    @Test func undoAndRedoPingPongIndefinitely() throws {
        try withOperations { ops, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost(title: "note", profile: .blog)
            let minted = try ops.seedBlock(in: post.id, text: "one two three")

            let result = try ops.moveSpanToNewTake(from: minted.variant.id, span: 3..<8)
            for _ in 0..<3 {
                _ = try stack.undo(with: ops)
                _ = try stack.redo(with: ops)
            }
            let fan = try db.read { db in try Queries.blockFan(db, blockID: minted.block.id) }
            #expect(fan.map(\.id) == [minted.variant.id, result.take.id])
            #expect(fan[1].workingText == " two ")
            #expect(fan[0].workingText == "onethree")
        }
    }

    /// The A12 class, and the FOURTH quiet occasion behind it: an undo whose
    /// restore would overwrite text she typed since the move insures it
    /// first, and the warning can be ASKED before the act.
    @Test func anUndoThatWouldOverwriteNewerTextInsuresItFirst() throws {
        try withOperations { ops, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost(title: "note", profile: .blog)
            let minted = try ops.seedBlock(in: post.id, text: "one two three")

            _ = try ops.moveSpanToNewTake(from: minted.variant.id, span: 3..<8)
            try ops.autosave(minted.variant.id, text: "one three and more", charDelta: 9)

            let warning = stack.pendingUndoWarning(with: ops)
            #expect(warning?.label == "Move into a New Take")
            #expect(warning?.bufferCount == 1)

            _ = try stack.undo(with: ops)
            let saved = try db.read { db in
                try Queries.commitHistory(db, variantID: minted.variant.id).map(\.text)
            }
            #expect(saved.contains("one three and more"),
                    "the diverged buffer was insured before the restore")
            let source = try db.read { db in try Variant.fetchOne(db, key: minted.variant.id) }
            #expect(source?.workingText == "one two three")
        }
    }

    /// A resolvable refusal keeps the entry: a mint she has since CHOSEN
    /// cannot be tombstoned out from under the slot showing it.
    @Test func undoRefusesWhileTheMintIsTheTakeTheNoteShows() throws {
        try withOperations { ops, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost(title: "note", profile: .blog)
            let minted = try ops.seedBlock(in: post.id, text: "one two three")

            let result = try ops.moveSpanToNewTake(from: minted.variant.id, span: 3..<8)
            try ops.chooseVariant(minted.block.id, variantID: result.take.id)

            #expect(throws: OperationError.variantIsChosen(id: result.take.id)) {
                try stack.undo(with: ops)
            }
            #expect(stack.depth == 1, "the entry stays for retry")
            #expect(try db.deletedAt("variant", result.take.id) == nil)
        }
    }

    /// Divergence is quiet: a mint she deleted herself stays deleted, and the
    /// undo still brings the span home.
    @Test func undoIsQuietAboutAMintThatIsAlreadyGone() throws {
        try withOperations { ops, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost(title: "note", profile: .blog)
            let minted = try ops.seedBlock(in: post.id, text: "one two three")

            let result = try ops.moveSpanToNewTake(from: minted.variant.id, span: 3..<8)
            try ops.deleteVariant(result.take.id)

            _ = try stack.undo(with: ops)  // the delete's own entry
            _ = try stack.undo(with: ops)  // …then this one
            let source = try db.read { db in try Variant.fetchOne(db, key: minted.variant.id) }
            #expect(source?.workingText == "one two three")
        }
    }
}
