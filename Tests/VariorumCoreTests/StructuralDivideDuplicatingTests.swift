import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// The duplicate-shape divide (mobile parity Stage A, batch A2 — Q-M2, the
/// author's 2026-08-03 gate-sitting ruling): dividing a FANNED block cuts
/// the DISPLAYED take into B and C and duplicates every OTHER active take
/// WHOLE onto both successors. These are the operation's birth pins — the
/// state-transition tests that define the behavior (the brief's red-on-old
/// reading for a new op). The shared `WWorld` stage: A between two
/// neighbors, takes V1 (default + chosen), V2, V3 in fan order, with
/// V2 branched from V1 and V3 branched from V2 (the parent chain the
/// remap tests read).
@Suite("Divide, duplicate shape (mobile parity A2 — Q-M2)")
struct StructuralDivideDuplicatingTests {
    @Test func duplicateShapeWorkedExampleExactRows() throws {
        try withOperations { ops, db in
            let world = try WWorld(ops)
            try ops.setTakeLabel(world.v2, label: "alt")

            let result = try ops.divideDuplicating(
                world.a.block.id, displayedVariantID: world.v1, cut: 11)

            // A is preserved whole: live, unplaced, fan + default + texts
            // untouched, the released placement stamped with A's last home.
            #expect(try db.deletedAt("block", world.a.block.id) == nil)
            #expect(try db.read { try ops.livePlacement($0, blockID: world.a.block.id) } == nil)
            #expect(try db.deletedAt("container_block", result.releasedPlacementID) != nil)
            for (variant, text) in [
                (world.v1, "One alpha. One omega."),
                (world.v2, "Two intact."),
                (world.v3, "Three start.\nThree end."),
            ] {
                #expect(try db.fetchString(
                    "SELECT working_text FROM variant WHERE id = ?", [variant]) == text)
                #expect(try db.deletedAt("variant", variant) == nil)
            }
            #expect(try db.fetchString(
                "SELECT default_variant_id FROM block WHERE id = ?", [world.a.block.id]) == world.v1)
            #expect(try db.fetchString(
                "SELECT last_container_id FROM block WHERE id = ?", [world.a.block.id]) == world.post.id)

            // B: the cut first half leading, then EVERY other active take
            // duplicated whole, in source fan order. C: the second half
            // leading, the same duplicates behind.
            #expect(result.first.variants.map(\.workingText)
                == ["One alpha.", "Two intact.", "Three start.\nThree end."])
            #expect(result.second.variants.map(\.workingText)
                == ["One omega.", "Two intact.", "Three start.\nThree end."])
            #expect(result.first.sourceVariantIDs == [world.v1, world.v2, world.v3])
            #expect(result.second.sourceVariantIDs == [world.v1, world.v2, world.v3])
            for half in [result.first, result.second] {
                #expect(half.variants[0].fanPosition < half.variants[1].fanPosition)
                #expect(half.variants[1].fanPosition < half.variants[2].fanPosition)
                // Chosen AND default are the cut half on each successor.
                #expect(half.block.defaultVariantId == half.variants[0].id)
                #expect(half.placement.chosenVariantId == half.variants[0].id)
                // The cut half mints unlabeled (the W's halves rule); a
                // duplicate keeps its label (the merge-carry rule — the
                // name is part of the take it rides in on).
                #expect(half.variants[0].label == nil)
                #expect(half.variants[1].label == "alt")
                #expect(half.variants[2].label == nil)
            }

            // Duplicates are FRESH rows: fresh UUIDs everywhere, and B's
            // duplicates are distinct rows from C's.
            let mintedIDs = (result.first.variants + result.second.variants).map(\.id)
            #expect(Set(mintedIDs).count == mintedIDs.count)
            #expect(Set(mintedIDs).isDisjoint(with: [world.v1, world.v2, world.v3]))

            // B then C stand exactly where A stood.
            #expect(try liveBlockOrder(db, in: world.post.id) == [
                world.before.block.id, result.first.block.id,
                result.second.block.id, world.after.block.id,
            ])

            // Lineage: both successors derive from A via divide.
            for half in [result.first, result.second] {
                #expect(half.edge.sourceBlockId == half.block.id)
                #expect(half.edge.targetBlockId == world.a.block.id)
                #expect(half.edge.type == .derivedFrom)
                #expect(half.edge.originOp == "divide")
            }
        }
    }

    @Test func theDisplayedTakeMayBeAnyActiveTake() throws {
        // The peek case: the door names whatever take she is LOOKING at —
        // the chosen pointer never gates which take gets cut.
        try withOperations { ops, db in
            let world = try WWorld(ops)  // chosen = V1; she displays V3

            let result = try ops.divideDuplicating(
                world.a.block.id, displayedVariantID: world.v3, cut: 13)

            #expect(result.first.variants.map(\.workingText)
                == ["Three start.", "One alpha. One omega.", "Two intact."])
            #expect(result.second.variants.map(\.workingText)
                == ["Three end.", "One alpha. One omega.", "Two intact."])
            #expect(result.first.sourceVariantIDs == [world.v3, world.v1, world.v2])
            for half in [result.first, result.second] {
                #expect(half.block.defaultVariantId == half.variants[0].id)
                #expect(half.placement.chosenVariantId == half.variants[0].id)
            }
            _ = db
        }
    }

    @Test func theParentTreeRemapsInsideTheCopySet() throws {
        // WWorld's chain: V2 branched from V1, V3 branched from V2. With V1
        // displayed (cut, not duplicated), V2's parent leaves the copy set
        // (→ nil, the poolDragCopy rule) while V3's parent is V2, whose
        // duplicate is in the set (→ that successor's own dup-of-V2).
        try withOperations { ops, db in
            let world = try WWorld(ops)
            #expect(try db.fetchString(
                "SELECT parent_variant_id FROM variant WHERE id = ?", [world.v3]) == world.v2)

            let result = try ops.divideDuplicating(
                world.a.block.id, displayedVariantID: world.v1, cut: 11)

            for half in [result.first, result.second] {
                // The cut half is parentless (the W's halves rule).
                #expect(half.variants[0].parentVariantId == nil)
                // dup-of-V2: parent (V1) is outside the copy set → nil.
                #expect(half.variants[1].parentVariantId == nil)
                // dup-of-V3: parent (V2) remaps to THIS successor's dup.
                #expect(half.variants[2].parentVariantId == half.variants[1].id)
                // …and the store rows agree.
                #expect(try db.fetchString(
                    "SELECT parent_variant_id FROM variant WHERE id = ?",
                    [half.variants[2].id]) == half.variants[1].id)
            }
        }
    }

    @Test func aParentThatFollowsItsChildInFanOrderStillRemaps() throws {
        // Stage A ladder round 1, FIX-2: today's ops cannot produce a
        // parent AFTER its child in fan order (`branchVariant` appends),
        // but 13e's ruled reorder-takes makes `fan_position` mutable — so
        // the pin CONSTRUCTS the store state directly (fan-position swap,
        // legal in tests) and divides. RED-ON-OLD: the pre-fix remap
        // indexed a partially built array (`variants[parentIndex]` with
        // the parent not yet minted) and died by index trap inside the
        // write transaction; the poolDragCopy pre-assigned-ID shape
        // resolves the parent by ID, order-free.
        try withOperations { ops, db in
            let world = try WWorld(ops)  // V3 branched from V2
            try db.write { db in
                let p2 = try String.fetchOne(
                    db, sql: "SELECT fan_position FROM variant WHERE id = ?",
                    arguments: [world.v2])
                let p3 = try String.fetchOne(
                    db, sql: "SELECT fan_position FROM variant WHERE id = ?",
                    arguments: [world.v3])
                try db.execute(
                    sql: "UPDATE variant SET fan_position = ? WHERE id = ?",
                    arguments: [p3, world.v2])
                try db.execute(
                    sql: "UPDATE variant SET fan_position = ? WHERE id = ?",
                    arguments: [p2, world.v3])
            }

            let result = try ops.divideDuplicating(
                world.a.block.id, displayedVariantID: world.v1, cut: 11)

            // Duplicates ride in the SWAPPED fan order — dup-of-V3 first.
            #expect(result.first.variants.map(\.workingText)
                == ["One alpha.", "Three start.\nThree end.", "Two intact."])
            #expect(result.second.variants.map(\.workingText)
                == ["One omega.", "Three start.\nThree end.", "Two intact."])
            for half in [result.first, result.second] {
                // dup-of-V3 still parents to THIS successor's dup-of-V2,
                // which now sits BEHIND it in the fan.
                #expect(half.sourceVariantIDs == [world.v1, world.v3, world.v2])
                #expect(half.variants[1].parentVariantId == half.variants[2].id)
                // dup-of-V2's parent (V1) is outside the copy set → nil.
                #expect(half.variants[2].parentVariantId == nil)
                // …and the store rows agree.
                #expect(try db.fetchString(
                    "SELECT parent_variant_id FROM variant WHERE id = ?",
                    [half.variants[1].id]) == half.variants[2].id)
            }
        }
    }

    @Test func archivedTakesStayOnAAndLockedTakesDuplicateUnlocked() throws {
        try withOperations { ops, db in
            let world = try WWorld(ops)
            try ops.archiveVariant(world.v2)
            try ops.lockVariant(world.v3)

            let result = try ops.divideDuplicating(
                world.a.block.id, displayedVariantID: world.v1, cut: 11)

            // The archived take never travels — it stays on A, archived,
            // byte-untouched (the W's unmarked-variant precedent: A is
            // preserved whole, nothing is lost).
            #expect(result.first.variants.map(\.workingText)
                == ["One alpha.", "Three start.\nThree end."])
            #expect(result.second.variants.map(\.workingText)
                == ["One omega.", "Three start.\nThree end."])
            #expect(try db.fetchString(
                "SELECT status FROM variant WHERE id = ?", [world.v2]) == "archived")
            #expect(try db.deletedAt("variant", world.v2) == nil)

            // The locked take's buffer was COPIED, never edited: still
            // locked on A; the duplicates are NOT born locked.
            #expect(try db.fetchInt(
                "SELECT locked FROM variant WHERE id = ?", [world.v3]) == 1)
            #expect(result.first.variants[1].locked == false)
            #expect(result.second.variants[1].locked == false)
        }
    }

    @Test func aLockedDisplayedTakeDividesLegally() throws {
        // Stage A ladder round 1, FIX-4: the op doc's "a LOCKED displayed
        // take is deliberately legal" claim, pinned — buffers are COPIED,
        // never edited (divideW's locked-marked rule). The lock stays on
        // A's take, byte-untouched; nothing minted is born locked.
        try withOperations { ops, db in
            let world = try WWorld(ops)
            try ops.lockVariant(world.v1)

            let result = try ops.divideDuplicating(
                world.a.block.id, displayedVariantID: world.v1, cut: 11)

            #expect(result.first.variants.map(\.workingText)
                == ["One alpha.", "Two intact.", "Three start.\nThree end."])
            #expect(result.second.variants.map(\.workingText)
                == ["One omega.", "Two intact.", "Three start.\nThree end."])
            #expect(try db.fetchInt(
                "SELECT locked FROM variant WHERE id = ?", [world.v1]) == 1)
            #expect(try db.fetchString(
                "SELECT working_text FROM variant WHERE id = ?", [world.v1])
                == "One alpha. One omega.")
            for variant in result.first.variants + result.second.variants {
                #expect(variant.locked == false)
            }
        }
    }

    @Test func commitsAreNeverCopied() throws {
        try withOperations { ops, db in
            let world = try WWorld(ops)
            _ = try ops.commit(world.v1)
            _ = try ops.commit(world.v2)

            let result = try ops.divideDuplicating(
                world.a.block.id, displayedVariantID: world.v1, cut: 11)

            for variant in result.first.variants + result.second.variants {
                #expect(try db.fetchInt(
                    "SELECT COUNT(*) FROM commit_point WHERE variant_id = ?", [variant.id]) == 0)
            }
            // A's history is untouched by the divide.
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM commit_point WHERE variant_id = ?", [world.v1]) == 1)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM commit_point WHERE variant_id = ?", [world.v2]) == 1)
        }
    }

    @Test func commentsCopyToBothSuccessorsAndPresentationInherits() throws {
        try withOperations { ops, db in
            let world = try WWorld(ops)
            let note = try ops.addBlockComment(to: world.a.block.id, text: "keep me")
            let dead = try ops.addBlockComment(to: world.a.block.id, text: "gone")
            try ops.deleteBlockComment(dead.id)
            try ops.setBlockPresentation(
                world.a.block.id, BlockPresentation(color: "sand", emoji: nil))

            let result = try ops.divideDuplicating(
                world.a.block.id, displayedVariantID: world.v1, cut: 11)

            for half in [result.first, result.second] {
                // The divide-W travel rule: COPIES to both successors —
                // live comments only, the source's created_at preserved.
                let copies = try db.read { db in
                    try Row.fetchAll(
                        db,
                        sql: """
                            SELECT text, created_at FROM block_comment
                            WHERE block_id = ? AND deleted_at IS NULL
                            """,
                        arguments: [half.block.id])
                }
                #expect(copies.map { $0["text"] as String } == ["keep me"])
                #expect(copies.first.map { $0["created_at"] as String }
                    == (try db.fetchString(
                        "SELECT created_at FROM block_comment WHERE id = ?", [note.id])))
                // Presentation inherits (the span was the callout's content).
                #expect(try db.fetchString(
                    "SELECT presentation FROM block WHERE id = ?", [half.block.id])
                    == #"{"color":"sand","kind":"callout"}"#)
            }
            // A keeps its originals — the live one and the dead one.
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM block_comment WHERE block_id = ?",
                [world.a.block.id]) == 2)
        }
    }

    @Test func touchesThePostWithoutReshuffling() throws {
        // Touch-without-churn (author decision 2026-07-06, the divide-W
        // rule): last_touched_at stamps; churn and the meaningful sort
        // never move — restructuring is not revision.
        try withOperations { ops, db in
            let world = try WWorld(ops)
            let touchedBefore = try db.fetchString(
                "SELECT last_touched_at FROM container WHERE id = ?", [world.post.id])
            let majorBefore = try db.fetchString(
                "SELECT last_major_revision_at FROM container WHERE id = ?", [world.post.id])
            let churnBefore = try db.fetchInt(
                "SELECT churn_accumulator FROM container WHERE id = ?", [world.post.id])

            _ = try ops.divideDuplicating(
                world.a.block.id, displayedVariantID: world.v1, cut: 11)

            let touchedAfter = try db.fetchString(
                "SELECT last_touched_at FROM container WHERE id = ?", [world.post.id])
            #expect(touchedAfter != nil && touchedAfter != touchedBefore)
            #expect(try db.fetchString(
                "SELECT last_major_revision_at FROM container WHERE id = ?", [world.post.id])
                == majorBefore)
            #expect(try db.fetchInt(
                "SELECT churn_accumulator FROM container WHERE id = ?", [world.post.id])
                == churnBefore)
        }
    }

    @Test func aSingleTakeBlockIsAcceptedWithReleaseASemantics() throws {
        // PROVISIONAL (A2 batch record): an unfanned block is accepted —
        // the divideW precedent's letter ("the editor picks the gesture,
        // the op doesn't second-guess") — and degenerates to a divide with
        // release-A semantics and no duplicates. The phone door routes
        // single-take blocks to plain `divide`; this door stays coherent
        // for a caller that doesn't.
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "One here. Two here.")

            let result = try ops.divideDuplicating(
                a.block.id, displayedVariantID: a.variant.id, cut: 9)

            #expect(result.first.variants.map(\.workingText) == ["One here."])
            #expect(result.second.variants.map(\.workingText) == ["Two here."])
            #expect(try db.deletedAt("block", a.block.id) == nil)
            #expect(try db.read { try ops.livePlacement($0, blockID: a.block.id) } == nil)
            #expect(try db.fetchString(
                "SELECT working_text FROM variant WHERE id = ?", [a.variant.id])
                == "One here. Two here.")
        }
    }

    @Test func reversibleByRePointingAtA() throws {
        // The W promise, carried byte-intact: release the successors,
        // placeBlock(A), and the reading is back — fan and all.
        try withOperations { ops, db in
            let world = try WWorld(ops)
            let result = try ops.divideDuplicating(
                world.a.block.id, displayedVariantID: world.v1, cut: 11)

            try ops.deleteBlock(result.first.block.id)
            try ops.deleteBlock(result.second.block.id)
            try ops.placeBlock(
                world.a.block.id, in: world.post.id, at: .before(world.after.block.id))

            #expect(try liveBlockOrder(db, in: world.post.id)
                == [world.before.block.id, world.a.block.id, world.after.block.id])
            #expect(try db.read { try ops.renderedVariant($0, blockID: world.a.block.id) }
                .workingText == "One alpha. One omega.")
        }
    }

    @Test func refusalsLeaveTheWorldUntouched() throws {
        let stack = UndoStack()
        try withOperations { _, db in
            let ops = Operations(undoStack: stack)
            let world = try WWorld(ops)
            let a = world.a.block.id
            let length = "One alpha. One omega.".utf16.count

            // Start/end cuts refuse — her "valid divider" condition;
            // there is NO parking in the default divide (the ceremony's
            // vocabulary stays the ceremony's).
            for cut in [0, length, -1, 99] {
                #expect(throws: OperationError.invalidCut(variantID: world.v1, cut: cut)) {
                    try ops.divideDuplicating(a, displayedVariantID: world.v1, cut: cut)
                }
            }

            // The displayed take must be a live ACTIVE take of THIS block.
            #expect(throws: OperationError.variantNotFound(id: "stranger")) {
                try ops.divideDuplicating(a, displayedVariantID: "stranger", cut: 5)
            }
            let foreign = world.before.variant.id
            #expect(throws: OperationError.variantNotFound(id: foreign)) {
                try ops.divideDuplicating(a, displayedVariantID: foreign, cut: 5)
            }
            try ops.archiveVariant(world.v2)
            #expect(throws: OperationError.archivedVariant(id: world.v2)) {
                try ops.divideDuplicating(a, displayedVariantID: world.v2, cut: 5)
            }

            // The seal refuses everything under the post.
            try ops.lockPost(world.post.id)
            #expect(throws: OperationError.lockedPost(id: world.post.id)) {
                try ops.divideDuplicating(a, displayedVariantID: world.v1, cut: 11)
            }
            try ops.unlockPost(world.post.id)

            // No refusal grew the world or registered an undo entry.
            #expect(try db.fetchInt("SELECT COUNT(*) FROM edge") == 0)
            #expect(try liveBlockOrder(db, in: world.post.id)
                == [world.before.block.id, a, world.after.block.id])
            #expect(stack.topLabel != "Divide")
        }
    }

    @Test func undoRestoresAWholeAndRedoPingPongs() throws {
        // ONE undo entry: A's placement back live at its exact row (chosen
        // intact), the mints cascading away whole — and the required redo
        // half re-applies the SAME rows (exact-row, never a forward
        // re-run), so undo↔redo ping-pongs with every ID stable.
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let world = try WWorld(ops)
            let placementBefore = try db.snapshotRow(
                "container_block", world.a.placement.id)

            let result = try ops.divideDuplicating(
                world.a.block.id, displayedVariantID: world.v1, cut: 11)
            #expect(stack.topLabel == "Divide")
            let postDivideOrder = try liveBlockOrder(db, in: world.post.id)

            try stack.undo(with: ops)

            // A stands exactly where it stood — same placement row, same
            // position, same chosen pointer.
            #expect(try liveBlockOrder(db, in: world.post.id)
                == [world.before.block.id, world.a.block.id, world.after.block.id])
            #expect(try db.snapshotRow("container_block", world.a.placement.id)
                == placementBefore)
            // Both mints are gone with their WHOLE fans (cascade-stamped).
            for half in [result.first, result.second] {
                #expect(try db.deletedAt("block", half.block.id) != nil)
                for variant in half.variants {
                    #expect(try db.deletedAt("variant", variant.id) != nil)
                }
            }

            #expect(try stack.redo(with: ops) == "Divide")

            // The same rows return: order, fans, chosen — IDs intact.
            #expect(try liveBlockOrder(db, in: world.post.id) == postDivideOrder)
            for half in [result.first, result.second] {
                #expect(try db.deletedAt("block", half.block.id) == nil)
                for variant in half.variants {
                    #expect(try db.deletedAt("variant", variant.id) == nil)
                }
                #expect(try db.fetchString(
                    "SELECT chosen_variant_id FROM container_block WHERE id = ?",
                    [half.placement.id]) == half.variants[0].id)
            }
            #expect(try db.deletedAt("container_block", result.releasedPlacementID) != nil)

            // …and back again: the entry ping-pongs on the same pre-images.
            try stack.undo(with: ops)
            #expect(try liveBlockOrder(db, in: world.post.id)
                == [world.before.block.id, world.a.block.id, world.after.block.id])
        }
    }
}
