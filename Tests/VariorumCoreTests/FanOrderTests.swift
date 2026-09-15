import Foundation
import GRDB
import Testing
@testable import VariorumCore

// Phase 13e, batch 2 (E4 — her A19: "Reorder takes"). The fan becomes an
// ordered list you can rearrange, and it is ordering like EVERY other
// ordering in the system: jittered fractional-index keys through the one
// resolver, sort key `(fan_position, id)`, no rebalance (SyncSpec §8).
//
// The suite's two jobs:
//
//  1. pin `reorderTake` against `reorder`'s shape — no touch, no churn, the
//     seal refusal, exact-key undo AND redo (13c 1B), a self-anchored move
//     writing nothing;
//  2. pin the FAN-COPY RIDER (the KnownIssues row "Single-pass fan-copy
//     remaps assume parent-precedes-child"): reorder-takes falsifies the
//     parent-precedes-child premise, so `poolDragCopy` and `copyPost` copy
//     through the one `copyFan` machine whose second pass lands a FORWARD
//     parent pointer. Before the fix both threw inside their write.

@Suite("Fan order — reorderTake (13e E4, A19)")
struct FanOrderTests {
    /// A post with one three-take block: V1 (default + chosen), V2 branched
    /// from V1, V3 blank at the fan's end.
    struct FanWorld {
        let post: Container
        let a: Operations.NewBlockResult
        let v2: Variant
        let v3: Variant

        init(_ ops: Operations) throws {
            post = try ops.createPost()
            a = try ops.seedBlock(in: post.id, text: "Take one.")
            v2 = try ops.branchVariant(a.block.id, from: a.variant.id)
            try ops.autosave(v2.id, text: "Take two.", charDelta: 0)
            v3 = try ops.newBlankVariant(a.block.id)
            try ops.autosave(v3.id, text: "Take three.", charDelta: 0)
        }

        var takes: [String] { [a.variant.id, v2.id, v3.id] }
    }

    private func fanOrder(_ db: AppDatabase, _ blockID: String) throws -> [String] {
        try db.read { try Queries.blockFan($0, blockID: blockID).map(\.id) }
    }

    private func fanPosition(_ db: AppDatabase, _ variantID: String) throws -> String {
        try db.fetchString("SELECT fan_position FROM variant WHERE id = ?", [variantID]) ?? ""
    }

    // MARK: - The act

    @Test func movingATakeLaterReordersTheFanAndTouchesOnlyItsOwnRow() throws {
        try withOperations { ops, db in
            let world = try FanWorld(ops)
            #expect(try fanOrder(db, world.a.block.id) == world.takes)
            let untouched = try world.takes.map { try fanPosition(db, $0) }
            try db.clearOutbox()

            try ops.reorderTake(world.a.variant.id, to: .after(world.v2.id))

            #expect(try fanOrder(db, world.a.block.id)
                == [world.v2.id, world.a.variant.id, world.v3.id])
            // Only the moved take's key was rewritten — no renumbering pass
            // exists (SyncSpec §8: there is no rebalance operation).
            #expect(try fanPosition(db, world.v2.id) == untouched[1])
            #expect(try fanPosition(db, world.v3.id) == untouched[2])
            #expect(try fanPosition(db, world.a.variant.id) != untouched[0])
            #expect(try db.outboxContains("variant", world.a.variant.id))
            #expect(try db.outboxContains("variant", world.v2.id) == false)
            #expect(try db.outboxContains("variant", world.v3.id) == false)
        }
    }

    @Test func movingATakeEarlierAndToTheFanEndsBothLand() throws {
        try withOperations { ops, db in
            let world = try FanWorld(ops)

            try ops.reorderTake(world.v3.id, to: .before(world.a.variant.id))
            #expect(try fanOrder(db, world.a.block.id)
                == [world.v3.id, world.a.variant.id, world.v2.id])

            try ops.reorderTake(world.v3.id, to: .end)
            #expect(try fanOrder(db, world.a.block.id)
                == [world.a.variant.id, world.v2.id, world.v3.id])

            try ops.reorderTake(world.v2.id, to: .start)
            #expect(try fanOrder(db, world.a.block.id)
                == [world.v2.id, world.a.variant.id, world.v3.id])
        }
    }

    @Test func theNewKeyIsAJitteredFractionalIndexStrictlyBetweenItsNeighbors() throws {
        // The §8 pin every ordering op carries: the key comes from
        // `FractionalIndex.between` (so it sorts strictly between the two
        // neighbors it landed between) and carries per-call jitter (so two
        // devices minting into the same gap do not collide — the same
        // insertion run twice gives two different keys).
        try withOperations { ops, db in
            let world = try FanWorld(ops)
            try ops.reorderTake(world.v3.id, to: .after(world.a.variant.id))
            let landed = try fanPosition(db, world.v3.id)
            #expect(try fanPosition(db, world.a.variant.id) < landed)
            #expect(landed < (try fanPosition(db, world.v2.id)))

            // Same gap, a second time: a different key (the jitter).
            try ops.reorderTake(world.v3.id, to: .end)
            try ops.reorderTake(world.v3.id, to: .after(world.a.variant.id))
            #expect(try fanPosition(db, world.v3.id) != landed)
            #expect(try fanOrder(db, world.a.block.id)
                == [world.a.variant.id, world.v3.id, world.v2.id])
        }
    }

    @Test func reorderingNeitherTouchesNorChurnsThePost() throws {
        // `reorder`'s shape exactly (AppSpec §9's touch-list names divide-W,
        // merge and poolDragCopy — not reordering): rearranging the fan is
        // not working on the prose and must never reshuffle the library.
        try withOperations { ops, db in
            let world = try FanWorld(ops)
            let before = try db.snapshotRow("container", world.post.id, excluding: [])

            try ops.reorderTake(world.v3.id, to: .start)

            #expect(try db.snapshotRow("container", world.post.id, excluding: []) == before)
        }
    }

    @Test func aSealedPostRefusesAFanReorder() throws {
        try withOperations { ops, db in
            let world = try FanWorld(ops)
            try ops.lockPost(world.post.id)
            #expect(throws: OperationError.lockedPost(id: world.post.id)) {
                try ops.reorderTake(world.v3.id, to: .start)
            }
            #expect(try fanOrder(db, world.a.block.id) == world.takes)
        }
    }

    @Test func aLockedTakeAndAnArchivedTakeStillReorder() throws {
        // PROVISIONAL (#57): the lock freezes the BUFFER, not identity
        // metadata (`setTakeLabel`'s ratified precedent), and an archived
        // take's place in the ordering is where it returns to.
        try withOperations { ops, db in
            let world = try FanWorld(ops)
            try ops.lockVariant(world.v2.id)
            try ops.archiveVariant(world.v3.id)

            try ops.reorderTake(world.v2.id, to: .start)
            try ops.reorderTake(world.v3.id, to: .start)

            #expect(try fanOrder(db, world.a.block.id)
                == [world.v3.id, world.v2.id, world.a.variant.id])
        }
    }

    @Test func anAnchorThatIsNotATakeOfThisBlockRefuses() throws {
        try withOperations { ops, db in
            let world = try FanWorld(ops)
            let other = try ops.seedBlock(in: world.post.id, text: "Elsewhere.")
            #expect(throws: OperationError.variantNotFound(id: other.variant.id)) {
                try ops.reorderTake(world.v2.id, to: .after(other.variant.id))
            }
            #expect(try fanOrder(db, world.a.block.id) == world.takes)
        }
    }

    @Test func movingATakeRelativeToItselfWritesNothing() throws {
        try withOperations { ops, db in
            let world = try FanWorld(ops)
            let before = try db.snapshotRow("variant", world.v2.id, excluding: [])
            try db.clearOutbox()

            try ops.reorderTake(world.v2.id, to: .after(world.v2.id))
            try ops.reorderTake(world.v2.id, to: .before(world.v2.id))

            #expect(try db.snapshotRow("variant", world.v2.id, excluding: []) == before)
            #expect(try db.outboxContains("variant", world.v2.id) == false)
        }
    }

    // MARK: - Undo / redo (13c 1B: both halves, exact keys)

    @Test func undoAndRedoPingPongTheExactKeys() throws {
        try withOperations { ops, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let world = try FanWorld(ops)
            let before = try fanPosition(db, world.a.variant.id)

            try ops.reorderTake(world.a.variant.id, to: .end)
            let landed = try fanPosition(db, world.a.variant.id)
            #expect(try fanOrder(db, world.a.block.id)
                == [world.v2.id, world.v3.id, world.a.variant.id])
            #expect(stack.depth == 1)
            #expect(stack.topLabel == "Reorder Take")

            #expect(try stack.undo(with: ops) == "Reorder Take")
            #expect(try fanPosition(db, world.a.variant.id) == before)
            #expect(try fanOrder(db, world.a.block.id) == world.takes)

            #expect(try stack.redo(with: ops) == "Reorder Take")
            #expect(try fanPosition(db, world.a.variant.id) == landed)
            #expect(try fanOrder(db, world.a.block.id)
                == [world.v2.id, world.v3.id, world.a.variant.id])

            // …and again, on the SAME captured pre-images (no re-derivation).
            #expect(try stack.undo(with: ops) == "Reorder Take")
            #expect(try fanPosition(db, world.a.variant.id) == before)
            _ = ops
        }
    }

    @Test func aSelfAnchoredMoveRegistersNoUndoEntry() throws {
        try withOperations { _, _ in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let world = try FanWorld(ops)
            try ops.reorderTake(world.v2.id, to: .after(world.v2.id))
            #expect(stack.depth == 0)
        }
    }
}

// MARK: - The fan-copy rider (the KnownIssues FIX-2 row)

@Suite("Fan copies survive a reordered fan (13e E4's rider — FIX-2)")
struct ReorderedFanCopyTests {
    @Test func aParentThatFollowsItsChildInFanOrderStillRemaps() throws {
        // poolDragCopy(includeFan:). RED-ON-OLD: the pre-fix single pass
        // inserted the copy of V2 carrying a `parent_variant_id` pointing at
        // the copy of V1, whose row did not exist yet — `parent_variant_id`
        // is an IMMEDIATE foreign key, so the insert (and the whole copy)
        // threw. Unreachable until `reorderTake` made `fan_position`
        // mutable, which is exactly why the row said the fix lands WITH the
        // feature; the pin now builds the state through the real op instead
        // of hand-writing SQL.
        try withOperations { ops, db in
            let pool = try ops.createPool()
            let post = try ops.createPost()
            let p = try ops.seedBlock(in: pool.id, text: "Parent take.")
            let child = try ops.branchVariant(p.block.id, from: p.variant.id)
            try ops.autosave(child.id, text: "Child take.", charDelta: 0)
            // The parent now sits AFTER its child in fan order.
            try ops.reorderTake(p.variant.id, to: .after(child.id))
            #expect(try db.read { try Queries.blockFan($0, blockID: p.block.id).map(\.id) }
                == [child.id, p.variant.id])

            let result = try ops.poolDragCopy(p.block.id, to: post.id, includeFan: true)

            // The copies ride in the SWAPPED order, and the child's parent
            // points at the copy that sits BEHIND it.
            #expect(result.variants.map(\.workingText) == ["Child take.", "Parent take."])
            #expect(result.variants[0].parentVariantId == result.variants[1].id)
            #expect(result.variants[1].parentVariantId == nil)
            // …and the STORE rows agree (the second pass really wrote).
            #expect(try db.fetchString(
                "SELECT parent_variant_id FROM variant WHERE id = ?",
                [result.variants[0].id]) == result.variants[1].id)
        }
    }

    @Test func aDuplicatedPostRemapsAForwardParentToo() throws {
        // `copyPost` — the second call site of the same single-pass shape
        // (duplicateAsVersion / promoteLens / divergePostForReading all
        // compose it). Same red-on-old mechanism.
        try withOperations { ops, db in
            let post = try ops.createPost(title: "Source")
            let a = try ops.seedBlock(in: post.id, text: "Parent take.")
            let child = try ops.branchVariant(a.block.id, from: a.variant.id)
            try ops.autosave(child.id, text: "Child take.", charDelta: 0)
            try ops.reorderTake(a.variant.id, to: .after(child.id))

            let copy = try ops.duplicateAsVersion(post.id)

            let copiedBlockID = try #require(copy.blockCopies.first?.copy)
            let copiedFan = try db.read {
                try Queries.blockFan($0, blockID: copiedBlockID)
            }
            #expect(copiedFan.map(\.workingText) == ["Child take.", "Parent take."])
            #expect(copiedFan[0].parentVariantId == copiedFan[1].id)
            #expect(copiedFan[1].parentVariantId == nil)
        }
    }
}
