import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// The shared W stage: A placed between two neighbors, carrying a
/// three-take fan — V1 (default + chosen), V2, V3 in fan order.
struct WWorld {
    let post: Container
    let before: Operations.NewBlockResult
    let a: Operations.NewBlockResult
    let after: Operations.NewBlockResult
    let v1: String
    let v2: String
    let v3: String

    init(_ ops: Operations) throws {
        post = try ops.createPost()
        before = try ops.newBlock(in: post.id, text: "before")
        a = try ops.newBlock(in: post.id, text: "One alpha. One omega.")
        after = try ops.newBlock(in: post.id, text: "after")
        v1 = a.variant.id
        let take2 = try ops.branchVariant(a.block.id, from: v1)
        try ops.autosave(take2.id, text: "Two intact.", charDelta: 0)
        let take3 = try ops.branchVariant(a.block.id, from: take2.id)
        try ops.autosave(take3.id, text: "Three start.\nThree end.", charDelta: 0)
        v2 = take2.id
        v3 = take3.id
    }
}

@Suite("Divide, single-variant (Phase 3, Step 3)")
struct StructuralDivideTests {
    @Test func divideExactRows() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let before = try ops.newBlock(in: post.id, text: "before")
            let a = try ops.newBlock(in: post.id, text: "Para one.\n\nPara two.")
            let after = try ops.newBlock(in: post.id, text: "after")

            let result = try ops.divide(a.block.id, cut: 11)

            // A keeps identity as the seam-trimmed first half — and, since
            // 13d's A11 ruling, the blank line's k−1 newline with it.
            #expect(try db.fetchString(
                "SELECT working_text FROM variant WHERE id = ?", [a.variant.id]) == "Para one.\n")
            #expect(try db.deletedAt("block", a.block.id) == nil)
            #expect(try db.deletedAt("container_block", a.placement.id) == nil)

            // C: the second half, immediately after A, default + chosen set.
            #expect(result.variant.workingText == "Para two.")
            #expect(result.block.defaultVariantId == result.variant.id)
            #expect(result.placement.chosenVariantId == result.variant.id)
            #expect(try liveBlockOrder(db, in: post.id)
                == [before.block.id, a.block.id, result.block.id, after.block.id])

            // Lineage: C derived_from A, minted by divide.
            #expect(result.edge.sourceBlockId == result.block.id)
            #expect(result.edge.targetBlockId == a.block.id)
            #expect(result.edge.type == .derivedFrom)
            #expect(result.edge.originOp == "divide")
        }
    }

    @Test func commitsStayOnTheSourceAndRestorePreSplitText() throws {
        // The documented restoreCommit-predates-split behavior (AppSpec §9):
        // A's old commits still hold the full pre-split text; restoring one
        // resurrects both halves into A's buffer while C sits next door.
        // Coherent under "coarse, not forensic" — the editor warns (Phase 7).
        try withOperations { ops, db in
            let post = try ops.createPost()
            let full = "Para one.\n\nPara two."
            let a = try ops.newBlock(in: post.id, text: full)
            let savepoint = try ops.commit(a.variant.id)

            let result = try ops.divide(a.block.id, cut: 11)

            // A's commit history is untouched by the cut.
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM commit_point WHERE variant_id = ?", [a.variant.id]) == 1)
            #expect(try db.fetchString(
                "SELECT text FROM commit_point WHERE id = ?", [savepoint.id]) == full)

            try ops.restoreCommit(a.variant.id, commitID: savepoint.id)

            // Both halves back in A's buffer; C still holds the second half.
            #expect(try db.fetchString(
                "SELECT working_text FROM variant WHERE id = ?", [a.variant.id]) == full)
            #expect(try db.fetchString(
                "SELECT working_text FROM variant WHERE id = ?", [result.variant.id]) == "Para two.")
            #expect(try liveBlockOrder(db, in: post.id) == [a.block.id, result.block.id])
        }
    }

    @Test func utf16CutsRespectGraphemes() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            // Emoji occupies UTF-16 offsets 3–13; the sentence boundary is 16.
            let a = try ops.newBlock(in: post.id, text: "Hi 👩‍👩‍👧‍👦. Done.")

            #expect(throws: OperationError.invalidCut(variantID: a.variant.id, cut: 5)) {
                try ops.divide(a.block.id, cut: 5)
            }

            let result = try ops.divide(a.block.id, cut: 16)
            #expect(try db.fetchString(
                "SELECT working_text FROM variant WHERE id = ?", [a.variant.id]) == "Hi 👩‍👩‍👧‍👦.")
            #expect(result.variant.workingText == "Done.")
        }
    }

    @Test func divideRefusals() throws {
        let stack = UndoStack()
        try withOperations { _, db in
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "Para one.\n\nPara two.")

            // Edge cuts and cuts that trim to an empty half.
            for cut in [0, 20, 99, -1] {
                #expect(throws: OperationError.invalidCut(variantID: a.variant.id, cut: cut)) {
                    try ops.divide(a.block.id, cut: cut)
                }
            }
            // Cut inside the separator run still yields two halves — but one
            // inside leading text whitespace would not; covered by Domain
            // tests, asserted at the op layer via the whitespace-only text.
            let padded = try ops.newBlock(in: post.id, text: "   Hello there")
            #expect(throws: OperationError.invalidCut(variantID: padded.variant.id, cut: 2)) {
                try ops.divide(padded.block.id, cut: 2)
            }

            // A fanned block refuses toward the W ceremony.
            let take2 = try ops.branchVariant(a.block.id, from: a.variant.id)
            #expect(throws: OperationError.fannedBlock(id: a.block.id)) {
                try ops.divide(a.block.id, cut: 11)
            }
            try ops.deleteVariant(take2.id)

            // Sealed post, locked variant, unplaced block.
            try ops.lockPost(post.id)
            #expect(throws: OperationError.lockedPost(id: post.id)) {
                try ops.divide(a.block.id, cut: 11)
            }
            try ops.unlockPost(post.id)
            try ops.lockVariant(a.variant.id)
            #expect(throws: OperationError.lockedVariant(id: a.variant.id)) {
                try ops.divide(a.block.id, cut: 11)
            }
            try ops.unlockVariant(a.variant.id)
            try ops.deleteBlock(a.block.id)
            try ops.deleteContainer(post.id)
            try ops.restoreBlock(a.block.id)
            #expect(throws: OperationError.blockNotPlaced(id: a.block.id)) {
                try ops.divide(a.block.id, cut: 11)
            }

            // No refusal grew the world or touched the undo stack (the
            // delete/restore gestures above registered their own entries).
            #expect(try db.fetchInt("SELECT COUNT(*) FROM edge") == 0)
            #expect(stack.topLabel != "Divide")
        }
    }

    /// **A11 (author ruling, 13d sitting 2026-07-28) — her report, at the
    /// op level:** dividing on an empty line used to drop the blank from
    /// BOTH halves ("it lands nowhere"). The blank belongs to the FIRST
    /// half, and the proof that this is the RIGHT owner is the round trip:
    /// `renderedText` reproduces the pre-divide text byte-for-byte, because
    /// the conditional join completes a left block already ending in a
    /// newline with exactly one more.
    @Test func aDivideAtABlankLineKeepsTheBlankAndRoundTrips() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let full = "Para one.\n\nPara two."
            let a = try ops.newBlock(in: post.id, text: full)
            #expect(try db.read { try Queries.renderedText($0, containerID: post.id) } == full)

            let result = try ops.divide(a.block.id, cut: 11)

            #expect(try db.fetchString(
                "SELECT working_text FROM variant WHERE id = ?", [a.variant.id]) == "Para one.\n")
            #expect(result.variant.workingText == "Para two.")
            // The document she reads is unchanged by the cut.
            #expect(try db.read { try Queries.renderedText($0, containerID: post.id) } == full)
        }
    }

    /// …and the ordinary one-newline cut is byte-unchanged by A11 — the
    /// separator is the whole of that seam, so nothing is owned.
    @Test func aDivideAtAPlainNewlineIsUnchangedByTheBlankLineRule() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "Para one.\nPara two.")

            let result = try ops.divide(a.block.id, cut: 10)

            #expect(try db.fetchString(
                "SELECT working_text FROM variant WHERE id = ?", [a.variant.id]) == "Para one.")
            #expect(result.variant.workingText == "Para two.")
        }
    }

    /// The ONE cut brain: the ceremony's per-take cuts inherit A11 without
    /// a second implementation (`divideW` calls the same halving function).
    @Test func theCeremonysPerTakeCutsInheritTheBlankLineRule() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "Take one A.\n\nTake one B.")
            let second = try ops.branchVariant(a.block.id, from: a.variant.id)
            try ops.autosave(second.id, text: "Take two A.\n\n\nTake two B.", charDelta: 0)

            let result = try ops.divideW(a.block.id, cuts: [
                a.variant.id: 13,   // "Take one A.\n\n | Take one B."
                second.id: 14,      // k = 3 → two newlines stay
            ])

            #expect(result.first.variants.map(\.workingText) == ["Take one A.\n", "Take two A.\n\n"])
            #expect(result.second.variants.map(\.workingText) == ["Take one B.", "Take two B."])
            _ = db
        }
    }

    @Test func divideFeedsChurn() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "Para one.\n\nPara two.")
            // The mint crossed (QUESTIONS #5 (a)): baseline 20, accumulator 0.
            let touchedAtMint = try db.fetchString(
                "SELECT last_touched_at FROM container WHERE id = ?", [post.id])
            #expect(touchedAtMint != nil)

            _ = try ops.divide(a.block.id, cut: 11)
            // The seam-trimmed first half drops 10 chars (20 → 10, the blank
            // line's k−1 newline staying with it since A11): churn
            // accumulates 10 against the 20-char baseline (10/20 < 0.8) —
            // divide visibly feeds churn without restamping.
            #expect(try db.fetchString(
                "SELECT last_touched_at FROM container WHERE id = ?", [post.id]) != touchedAtMint)
            #expect(try db.fetchInt(
                "SELECT churn_accumulator FROM container WHERE id = ?", [post.id]) == 10)
        }
    }

    @Test func divideWWorkedExampleExactRows() throws {
        try withOperations { ops, db in
            let world = try WWorld(ops)
            let result = try ops.divideW(world.a.block.id, cuts: [
                world.v1: 11,  // "One alpha. | One omega."
                world.v3: 13,  // "Three start.\n | Three end."
            ])

            // A is preserved whole: live, unplaced, fan + default untouched.
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
            // The release stamps A's last home, so a later deleteBlock on
            // the released block still trays and restores correctly.
            #expect(try db.fetchString(
                "SELECT last_container_id FROM block WHERE id = ?", [world.a.block.id]) == world.post.id)

            // B carries the first halves, C the second, marked order preserved.
            #expect(result.markedSourceIDs == [world.v1, world.v3])
            #expect(result.first.variants.map(\.workingText) == ["One alpha.", "Three start."])
            #expect(result.second.variants.map(\.workingText) == ["One omega.", "Three end."])
            #expect(result.first.variants[0].fanPosition < result.first.variants[1].fanPosition)
            #expect(result.second.variants[0].fanPosition < result.second.variants[1].fanPosition)

            // Rendered (V1) was marked: its halves are default AND chosen.
            #expect(result.first.block.defaultVariantId == result.first.variants[0].id)
            #expect(result.second.block.defaultVariantId == result.second.variants[0].id)
            #expect(result.first.placement.chosenVariantId == result.first.variants[0].id)
            #expect(result.second.placement.chosenVariantId == result.second.variants[0].id)

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

    @Test func divideWMixAndMatch() throws {
        // The W payoff: first-half-of-attempt-1 with second-half-of-attempt-3.
        try withOperations { ops, db in
            let world = try WWorld(ops)
            let result = try ops.divideW(world.a.block.id, cuts: [world.v1: 11, world.v3: 13])

            try ops.chooseVariant(result.second.block.id, variantID: result.second.variants[1].id)

            #expect(try db.read { try ops.renderedVariant($0, blockID: result.first.block.id) }
                .workingText == "One alpha.")
            #expect(try db.read { try ops.renderedVariant($0, blockID: result.second.block.id) }
                .workingText == "Three end.")
        }
    }

    @Test func divideWWithRenderedUnmarkedUsesFirstMarkedDefaults() throws {
        try withOperations { ops, db in
            let world = try WWorld(ops)  // rendered = chosen = V1
            let result = try ops.divideW(world.a.block.id, cuts: [world.v3: 13])

            #expect(result.first.variants.map(\.workingText) == ["Three start."])
            #expect(result.first.block.defaultVariantId == result.first.variants[0].id)
            // Chosen stays NULL: the slot renders the default by fallback.
            #expect(result.first.placement.chosenVariantId == nil)
            #expect(result.second.placement.chosenVariantId == nil)
            #expect(try db.read { try ops.renderedVariant($0, blockID: result.second.block.id) }
                .workingText == "Three end.")
        }
    }

    @Test func divideWTouchesThePostWithoutReshuffling() throws {
        // Structural work counts as touching (author decision 2026-07-06) —
        // but never as a major revision: restructuring must not reshuffle
        // the library's meaningful sort.
        try withOperations { ops, db in
            let world = try WWorld(ops)
            let touchedBefore = try db.fetchString(
                "SELECT last_touched_at FROM container WHERE id = ?", [world.post.id])
            let majorBefore = try db.fetchString(
                "SELECT last_major_revision_at FROM container WHERE id = ?", [world.post.id])

            _ = try ops.divideW(world.a.block.id, cuts: [world.v1: 11])

            let touchedAfter = try db.fetchString(
                "SELECT last_touched_at FROM container WHERE id = ?", [world.post.id])
            #expect(touchedAfter != nil && touchedAfter != touchedBefore)
            #expect(try db.fetchString(
                "SELECT last_major_revision_at FROM container WHERE id = ?", [world.post.id])
                == majorBefore)
        }
    }

    @Test func aReleasedBlockDeletedLaterStillRestoresHome() throws {
        // The last_container_id stamped at release feeds the tray path:
        // delete the released A, restore it, and it lands back in its post.
        try withOperations { ops, db in
            let world = try WWorld(ops)
            _ = try ops.divideW(world.a.block.id, cuts: [world.v1: 11])
            try ops.deleteBlock(world.a.block.id)
            try ops.restoreBlock(world.a.block.id)
            let home = try db.read { try ops.livePlacement($0, blockID: world.a.block.id) }
            #expect(home?.containerId == world.post.id)
        }
    }

    @Test func divideWReversibleByRePointingAtA() throws {
        // The W promise made real: release the successors, placeBlock(A),
        // and the reading is back — nobody's five editors disappeared.
        try withOperations { ops, db in
            let world = try WWorld(ops)
            let result = try ops.divideW(world.a.block.id, cuts: [world.v1: 11, world.v3: 13])

            try ops.deleteBlock(result.first.block.id)
            try ops.deleteBlock(result.second.block.id)
            try ops.placeBlock(world.a.block.id, in: world.post.id, at: .before(world.after.block.id))

            #expect(try liveBlockOrder(db, in: world.post.id)
                == [world.before.block.id, world.a.block.id, world.after.block.id])
            #expect(try db.read { try ops.renderedVariant($0, blockID: world.a.block.id) }
                .workingText == "One alpha. One omega.")
        }
    }

    @Test func divideWLockedMarkedVariantCarriesThrough() throws {
        // A locked variant's buffer is copied, never edited — the guard
        // protects the original, which W leaves untouched on A.
        try withOperations { ops, db in
            let world = try WWorld(ops)
            try ops.lockVariant(world.v3)
            let result = try ops.divideW(world.a.block.id, cuts: [world.v3: 13])
            #expect(result.first.variants[0].workingText == "Three start.")
            #expect(try db.fetchInt(
                "SELECT locked FROM variant WHERE id = ?", [world.v3]) == 1)
            // The copies are not born locked.
            #expect(result.first.variants[0].locked == false)
        }
    }

    @Test func divideWRefusals() throws {
        let stack = UndoStack()
        try withOperations { _, db in
            let ops = Operations(undoStack: stack)
            let world = try WWorld(ops)
            let a = world.a.block.id

            #expect(throws: OperationError.noMarkedVariants(blockID: a)) {
                try ops.divideW(a, cuts: [:])
            }
            // 13b 4A pin edit (justified): cut 0 on the one marked take is
            // no longer an invalid cut — it is START PARKING (S4-22 ruling
            // 2), and the refusal is now the parking guard: the whole take
            // rides into C, leaving B with no takes (I10 at birth).
            #expect(throws: OperationError.divideSideWouldBeEmpty(blockID: a)) {
                try ops.divideW(a, cuts: [world.v1: 0])
            }
            #expect(throws: OperationError.variantNotFound(id: "stranger")) {
                try ops.divideW(a, cuts: ["stranger": 5])
            }
            // A variant of some other block is a foreign mark too.
            #expect(throws: OperationError.variantNotFound(id: world.before.variant.id)) {
                try ops.divideW(a, cuts: [world.before.variant.id: 3])
            }
            try ops.archiveVariant(world.v2)
            #expect(throws: OperationError.archivedVariant(id: world.v2)) {
                try ops.divideW(a, cuts: [world.v2: 5])
            }
            try ops.lockPost(world.post.id)
            #expect(throws: OperationError.lockedPost(id: world.post.id)) {
                try ops.divideW(a, cuts: [world.v1: 11])
            }
            try ops.unlockPost(world.post.id)

            // Nothing minted, nothing released, undo stack clean of divides.
            #expect(try db.fetchInt("SELECT COUNT(*) FROM edge") == 0)
            #expect(try db.deletedAt("container_block", world.a.placement.id) == nil)
            #expect(stack.topLabel != "Divide")
            #expect(stack.topLabel != "Divide choosing takes")
        }
    }

    // MARK: Parking (13b Stage 4, S4-22 ruling 2 — end/start-of-take semantics)

    @Test func divideWEndParkingContributesAFirstHalfOnly() throws {
        // V2 ("Two intact.", 11 units) parks at its END: the whole take
        // rides into B verbatim; C's fan omits it entirely.
        try withOperations { ops, db in
            let world = try WWorld(ops)
            let result = try ops.divideW(world.a.block.id, cuts: [
                world.v1: 11,   // split: "One alpha. | One omega."
                world.v2: 11,   // parked at the end — no second half
            ])

            #expect(result.first.variants.map(\.workingText)
                == ["One alpha.", "Two intact."])
            #expect(result.second.variants.map(\.workingText) == ["One omega."])
            #expect(result.first.sourceVariantIDs == [world.v1, world.v2])
            #expect(result.second.sourceVariantIDs == [world.v1])
            #expect(result.markedSourceIDs == [world.v1, world.v2])

            // The parked copy is a COPY: V2 itself is untouched on A.
            #expect(try db.fetchString(
                "SELECT working_text FROM variant WHERE id = ?", [world.v2]) == "Two intact.")
            // Rendered (V1) contributes to both sides: default + chosen on each.
            #expect(result.first.block.defaultVariantId == result.first.variants[0].id)
            #expect(result.second.block.defaultVariantId == result.second.variants[0].id)
            #expect(result.first.placement.chosenVariantId == result.first.variants[0].id)
            #expect(result.second.placement.chosenVariantId == result.second.variants[0].id)
        }
    }

    @Test func divideWStartParkingContributesASecondHalfOnly() throws {
        // The mirror: V2 parks at its START — the whole take rides into C.
        try withOperations { ops, _ in
            let world = try WWorld(ops)
            let result = try ops.divideW(world.a.block.id, cuts: [
                world.v1: 11,
                world.v2: 0,
            ])
            #expect(result.first.variants.map(\.workingText) == ["One alpha."])
            #expect(result.second.variants.map(\.workingText)
                == ["One omega.", "Two intact."])
            #expect(result.first.sourceVariantIDs == [world.v1])
            #expect(result.second.sourceVariantIDs == [world.v1, world.v2])
        }
    }

    @Test func divideWParkedRenderedTakeStillAnchorsItsSide() throws {
        // Park the RENDERED take (V1) at its end and split V3: B's default
        // and chosen are V1's whole copy; C — where V1 doesn't contribute —
        // falls back to its first contributing take, chosen NULL (the
        // standing rendered-unmarked rule, now applied per side).
        try withOperations { ops, db in
            let world = try WWorld(ops)
            let result = try ops.divideW(world.a.block.id, cuts: [
                world.v1: 21,   // "One alpha. One omega." — parked at its end
                world.v3: 13,   // split: "Three start.\n | Three end."
            ])
            #expect(result.first.variants.map(\.workingText)
                == ["One alpha. One omega.", "Three start."])
            #expect(result.second.variants.map(\.workingText) == ["Three end."])
            #expect(result.first.block.defaultVariantId == result.first.variants[0].id)
            #expect(result.first.placement.chosenVariantId == result.first.variants[0].id)
            #expect(result.second.block.defaultVariantId == result.second.variants[0].id)
            #expect(result.second.placement.chosenVariantId == nil,
                    "chosen stays NULL where the rendered take doesn't contribute")
            #expect(try db.read { try ops.renderedVariant($0, blockID: result.second.block.id) }
                .workingText == "Three end.")
        }
    }

    // MARK: The keep-on-top default's two demands on parking (18c batch 1, U-2)

    /// **RED-ON-OLD.** A parked take is a WHOLE-TAKE RIDE, and a whole-take
    /// ride keeps its name — §9's own rule for `divideDuplicating`'s
    /// duplicates ("labels copied — a whole-take ride keeps its name, the
    /// merge-carry precedent") and for `mergeCeremony`'s carries. `divideW`
    /// minted every successor take label-less, which was invisible while
    /// parking was a rare deliberate act inside the ceremony and becomes a
    /// silent loss the moment keep-on-top parks EVERY other take at EVERY
    /// fanned divide. The CUT HALVES stay unlabeled, exactly as before —
    /// they are fresh texts, not rides.
    @Test func divideWAParkedTakeKeepsItsName() throws {
        try withOperations { ops, db in
            let world = try WWorld(ops)
            try ops.setTakeLabel(world.v2, label: "the spare")
            let result = try ops.divideW(world.a.block.id, cuts: [
                world.v1: 11,   // split
                world.v2: 11,   // parked at its end — rides whole into B
            ])

            #expect(result.first.variants.map(\.label) == [nil, "the spare"],
                    "the ride keeps its name; the cut half stays unlabeled")
            #expect(result.second.variants.map(\.label) == [nil])
            // Stored, not merely returned.
            #expect(try db.fetchString(
                "SELECT label FROM variant WHERE id = ?",
                [result.first.variants[1].id]) == "the spare")
            // A is preserved whole — the original take keeps its own name.
            #expect(try db.fetchString(
                "SELECT label FROM variant WHERE id = ?", [world.v2]) == "the spare")
        }
    }

    /// **RED-ON-OLD.** Each side's chosen/default anchors on A's RENDERED
    /// take, which is right for the ceremony (the sheet opens on what the
    /// block shows) and wrong for a caller that can name the take the author
    /// was actually in — the Takes board's caret sits in ANY take's pane,
    /// and the phone's PEEK displays a take that is not the chosen one.
    /// Composed into keep-on-top unchanged, B would render the OTHER take
    /// whole while C rendered the divided take's tail. `displayedVariantID`
    /// lets the caller say; nil keeps `context.rendered`
    /// (`divideWParkedRenderedTakeStillAnchorsItsSide` holds that half).
    @Test func divideWAnchorsTheChosenOnTheDisplayedTakeWhenNamed() throws {
        try withOperations { ops, db in
            let world = try WWorld(ops)
            // Keep-on-top with the caret in V3: V3 splits, V1 (the rendered
            // take) and V2 park at their ends and ride whole into B.
            let result = try ops.divideW(
                world.a.block.id,
                cuts: [world.v1: 21, world.v2: 11, world.v3: 13],
                displayedVariantID: world.v3)

            #expect(result.first.variants.map(\.workingText)
                == ["One alpha. One omega.", "Two intact.", "Three start."])
            #expect(result.second.variants.map(\.workingText) == ["Three end."])
            #expect(result.first.placement.chosenVariantId == result.first.variants[2].id,
                    "B shows the first half of the take she divided")
            #expect(result.first.block.defaultVariantId == result.first.variants[2].id)
            #expect(result.second.placement.chosenVariantId == result.second.variants[0].id)
            #expect(try db.read { try ops.renderedVariant($0, blockID: result.first.block.id) }
                .workingText == "Three start.")
        }
    }

    @Test func divideWParkingCopiesVerbatimIncludingTrailingNewlines() throws {
        // Parking has no seam, so nothing trims — trailing newlines are
        // meaningful stored spacing (the 2026-07-12 ruling) and ride whole.
        try withOperations { ops, _ in
            let world = try WWorld(ops)
            try ops.autosave(world.v2, text: "Line one.\n\n", charDelta: 0)
            let result = try ops.divideW(world.a.block.id, cuts: [
                world.v1: 11,
                world.v2: 11,   // "Line one.\n\n".utf16.count == 11 — the end
            ])
            #expect(result.first.variants.map(\.workingText)
                == ["One alpha.", "Line one.\n\n"])
        }
    }

    @Test func divideWAllParkedAtOneEndRefuses() throws {
        // Every checked take parked at the same end would birth a takeless
        // successor — I10 by construction; the op refuses and nothing moves.
        let stack = UndoStack()
        try withOperations { _, db in
            let ops = Operations(undoStack: stack)
            let world = try WWorld(ops)
            let a = world.a.block.id
            #expect(throws: OperationError.divideSideWouldBeEmpty(blockID: a)) {
                try ops.divideW(a, cuts: [world.v1: 21, world.v2: 11])  // both ends
            }
            #expect(throws: OperationError.divideSideWouldBeEmpty(blockID: a)) {
                try ops.divideW(a, cuts: [world.v1: 0, world.v2: 0])    // both starts
            }
            #expect(try db.fetchInt("SELECT COUNT(*) FROM edge") == 0)
            #expect(try db.deletedAt("container_block", world.a.placement.id) == nil)
            #expect(stack.topLabel != "Divide choosing takes")
        }
    }

    @Test func divideWEmptyTakeCutRefuses() throws {
        // An empty take's 0 and end coincide — which block gets the blank
        // would be a guess, so the cut refuses (the sheet says "uncheck it").
        try withOperations { ops, _ in
            let world = try WWorld(ops)
            try ops.autosave(world.v2, text: "", charDelta: 0)
            #expect(throws: OperationError.invalidCut(variantID: world.v2, cut: 0)) {
                try ops.divideW(world.a.block.id, cuts: [world.v1: 11, world.v2: 0])
            }
        }
    }

    @Test func divideWWhitespaceOnlyTakeParksAtEitherEnd() throws {
        // A whitespace-only take has no interior cut but CAN park — the
        // author decides which successor carries the blank-ish take.
        try withOperations { ops, _ in
            let world = try WWorld(ops)
            try ops.autosave(world.v2, text: "\n\n", charDelta: 0)
            let result = try ops.divideW(world.a.block.id, cuts: [
                world.v1: 11, world.v2: 2,  // parked at its end → rides into B
            ])
            #expect(result.first.variants.map(\.workingText) == ["One alpha.", "\n\n"])
            #expect(result.second.variants.map(\.workingText) == ["One omega."])
        }
    }

    @Test func divideWUndoWithParkingRestoresEverything() throws {
        // The undo inverse needs nothing new for parking: both successors
        // tombstone (asymmetric fans and all) and A's placement flips back.
        let stack = UndoStack()
        try withOperations { _, db in
            let ops = Operations(undoStack: stack)
            let world = try WWorld(ops)
            let result = try ops.divideW(world.a.block.id, cuts: [
                world.v1: 11, world.v2: 11,
            ])
            try stack.undo(with: ops)
            #expect(try liveBlockOrder(db, in: world.post.id)
                == [world.before.block.id, world.a.block.id, world.after.block.id])
            for half in [result.first, result.second] {
                #expect(try db.deletedAt("block", half.block.id) != nil)
                for variant in half.variants {
                    #expect(try db.deletedAt("variant", variant.id) != nil)
                }
            }
            #expect(try db.fetchString(
                "SELECT working_text FROM variant WHERE id = ?", [world.v2]) == "Two intact.")
        }
    }

    @Test func divideWUndoFlipsThePlacementAndTombstonesTheSuccessors() throws {
        let stack = UndoStack()
        try withOperations { _, db in
            let ops = Operations(undoStack: stack)
            let world = try WWorld(ops)
            let placementBefore = try db.snapshotRow("container_block", world.a.placement.id)

            let result = try ops.divideW(world.a.block.id, cuts: [world.v1: 11, world.v3: 13])
            // The W ceremony's own label — the summoned door's name since
            // U-4 (Phase 9's "Divide into Variants" renamed at the 18f
            // ladder, R1-9): the Edit menu reads "Undo Divide choosing takes".
            #expect(stack.topLabel == "Divide choosing takes")

            try stack.undo(with: ops)

            // A's exact placement row is back — position and chosen intact.
            #expect(try db.snapshotRow("container_block", world.a.placement.id) == placementBefore)
            #expect(try liveBlockOrder(db, in: world.post.id)
                == [world.before.block.id, world.a.block.id, world.after.block.id])
            for half in [result.first, result.second] {
                #expect(try db.deletedAt("block", half.block.id) != nil)
                #expect(try db.deletedAt("container_block", half.placement.id) != nil)
                #expect(try db.deletedAt("edge", half.edge.id) != nil)
                for variant in half.variants {
                    #expect(try db.deletedAt("variant", variant.id) != nil)
                }
            }
            #expect(stack.depth == 0)
        }
    }

    @Test func divideWUndoLeavesARePlacedBlockAlone() throws {
        // Divergence rule: if A found a new home between do and undo, I2
        // wins — the undo still clears the successors but never dual-places A.
        let stack = UndoStack()
        try withOperations { _, db in
            let ops = Operations(undoStack: stack)
            let world = try WWorld(ops)
            let result = try ops.divideW(world.a.block.id, cuts: [world.v1: 11])

            let elsewhere = try ops.createPost()
            try ops.placeBlock(world.a.block.id, in: elsewhere.id)

            try stack.undo(with: ops)

            #expect(try db.deletedAt("block", result.first.block.id) != nil)
            #expect(try db.deletedAt("container_block", world.a.placement.id) != nil)  // stays released
            let home = try db.read { try ops.livePlacement($0, blockID: world.a.block.id) }
            #expect(home?.containerId == elsewhere.id)
        }
    }

    @Test func divideUndoRoundTripsToRowEquality() throws {
        let stack = UndoStack()
        try withOperations { _, db in
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "Para one.\n\nPara two.")
            let sourceBefore = try db.snapshotRow("variant", a.variant.id)

            let result = try ops.divide(a.block.id, cut: 11)
            #expect(stack.topLabel == "Divide")

            try stack.undo(with: ops)

            #expect(try db.snapshotRow("variant", a.variant.id) == sourceBefore)
            #expect(try db.deletedAt("block", result.block.id) != nil)
            #expect(try db.deletedAt("variant", result.variant.id) != nil)
            #expect(try db.deletedAt("container_block", result.placement.id) != nil)
            #expect(try db.deletedAt("edge", result.edge.id) != nil)
            #expect(try liveBlockOrder(db, in: post.id) == [a.block.id])
            #expect(stack.depth == 0)
        }
    }
}
