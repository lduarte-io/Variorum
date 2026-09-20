import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// The merge ceremony's operation (13b Stage 4, Batch 4B — the ruled merge
/// addendum, S4-23): pairing mints one take per hand-placed ＋, carries ride
/// whole, unpaired takes stay behind in lineage, nothing is
/// cartesian-producted, and the instant no-fan `merge` is byte-untouched
/// (its own suite is the parity net).
@Suite("Merge ceremony (13b Stage 4, Batch 4B)")
struct StructuralMergeCeremonyTests {
    /// Two fanned blocks; one pairing + one carry; one take stays behind.
    @Test func ceremonyExactRows() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let before = try ops.seedBlock(in: post.id, text: "before")
            let b = try ops.seedBlock(in: post.id, text: "First half.")
            let c = try ops.seedBlock(in: post.id, text: "Second half.")
            let after = try ops.seedBlock(in: post.id, text: "after")
            let bAlt = try ops.branchVariant(b.block.id, from: b.variant.id)
            try ops.autosave(bAlt.id, text: "Alt first.", charDelta: 0)
            try ops.setTakeLabel(bAlt.id, label: "the alternate")
            let cAlt = try ops.branchVariant(c.block.id, from: c.variant.id)
            try ops.autosave(cAlt.id, text: "Alt second.", charDelta: 0)

            let result = try ops.mergeCeremony(
                b.block.id, c.block.id,
                pairings: [.init(
                    firstVariantID: b.variant.id, secondVariantID: c.variant.id,
                    join: .space)],
                carries: [bAlt.id])

            // The fan: the pairing's joined take, then the carry — whole,
            // label riding along, unlocked, commit-free.
            #expect(result.variants.map(\.workingText)
                == ["First half. Second half.", "Alt first."])
            #expect(result.variants.map(\.label) == [nil, "the alternate"])
            #expect(result.sources == [
                .pairing(firstVariantID: b.variant.id, secondVariantID: c.variant.id),
                .carried(variantID: bAlt.id),
            ])
            #expect(result.variants.allSatisfy { !$0.locked })
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM variant WHERE block_id = ?",
                [result.block.id]) == 2)
            // Fan order is storage order.
            #expect(result.variants[0].fanPosition < result.variants[1].fanPosition)

            // Chosen/default: the rendered×rendered pairing exists → it.
            #expect(result.block.defaultVariantId == result.variants[0].id)
            #expect(result.placement.chosenVariantId == result.variants[0].id)

            // A' stands where the pair stood.
            #expect(try liveBlockOrder(db, in: post.id)
                == [before.block.id, result.block.id, after.block.id])

            // Sources: released to lineage — live, unplaced, fans whole
            // (the stay-behind take included), last home stamped.
            for source in [b.block.id, c.block.id] {
                #expect(try db.deletedAt("block", source) == nil)
                #expect(try db.read { try ops.livePlacement($0, blockID: source) } == nil)
                #expect(try db.fetchString(
                    "SELECT last_container_id FROM block WHERE id = ?", [source]) == post.id)
            }
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM variant WHERE block_id = ? AND deleted_at IS NULL",
                [b.block.id]) == 2)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM variant WHERE block_id = ? AND deleted_at IS NULL",
                [c.block.id]) == 2, "the unpaired take stays behind, alive")

            // The edge pair: A' derived_from each source, minted by merge.
            #expect(result.firstEdge.sourceBlockId == result.block.id)
            #expect(result.firstEdge.targetBlockId == b.block.id)
            #expect(result.secondEdge.targetBlockId == c.block.id)
            #expect(result.firstEdge.originOp == "merge")
            #expect(result.secondEdge.originOp == "merge")
            #expect(result.firstEdge.type == .derivedFrom)
        }
    }

    /// N17(b), resolved by S4-23 ruling 1: ceremony-divide then pair-back
    /// 1+1 / 2+2 restores both takes whole — the round trip she expected.
    @Test func divideWThenPairBackRoundTripsBothTakesWhole() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.seedBlock(in: post.id, text: "One alpha. One omega.")
            let alt = try ops.branchVariant(a.block.id, from: a.variant.id)
            try ops.autosave(alt.id, text: "Two alpha. Two omega.", charDelta: 0)

            let divided = try ops.divideW(
                a.block.id, cuts: [a.variant.id: 11, alt.id: 11])
            #expect(divided.first.variants.map(\.workingText)
                == ["One alpha.", "Two alpha."])
            #expect(divided.second.variants.map(\.workingText)
                == ["One omega.", "Two omega."])

            // Pair 1+1 and 2+2. The DOOR default is the ceremony's default
            // join, and since R-13u4-3 that is the newline (the pairings
            // read `MergeJoin.canon` and the texts joined with a space
            // until E3 rewrote this to the ruling); a SENTENCE cut that
            // wants its space back chooses `space` in the sheet, which is
            // the pin below this one.
            let firstFan = divided.first.variants
            let secondFan = divided.second.variants
            let restored = try ops.mergeCeremony(
                divided.first.block.id, divided.second.block.id,
                pairings: [
                    .init(firstVariantID: firstFan[0].id,
                          secondVariantID: secondFan[0].id,
                          join: MergeJoinRule.door.join(
                            head: firstFan[0].workingText,
                            tail: secondFan[0].workingText)),
                    .init(firstVariantID: firstFan[1].id,
                          secondVariantID: secondFan[1].id,
                          join: MergeJoinRule.door.join(
                            head: firstFan[1].workingText,
                            tail: secondFan[1].workingText)),
                ],
                carries: [])

            #expect(restored.variants.map(\.workingText)
                == ["One alpha.\nOne omega.", "Two alpha.\nTwo omega."],
                "divide-then-pair-back restores the takes whole — nothing cartesian")
            #expect(restored.variants.count == 2)
        }
    }

    /// The three-way join control: explicit newline and nothing joins land
    /// exactly their separator; canon suppresses the space at a whitespace
    /// edge — all through the ONE join brain.
    @Test func pairingsHonorTheExplicitJoin() throws {
        try withOperations { ops, _ in
            let post = try ops.createPost()
            let b = try ops.seedBlock(in: post.id, text: "line one")
            let c = try ops.seedBlock(in: post.id, text: "line two")
            _ = try ops.branchVariant(c.block.id, from: c.variant.id)

            let result = try ops.mergeCeremony(
                b.block.id, c.block.id,
                pairings: [.init(
                    firstVariantID: b.variant.id, secondVariantID: c.variant.id,
                    join: .newline)],
                carries: [])
            #expect(result.variants[0].workingText == "line one\nline two")

            let d = try ops.seedBlock(in: post.id, text: "bare")
            let e = try ops.seedBlock(in: post.id, text: "concatenation")
            _ = try ops.branchVariant(d.block.id, from: d.variant.id)
            let joined = try ops.mergeCeremony(
                d.block.id, e.block.id,
                pairings: [.init(
                    firstVariantID: d.variant.id, secondVariantID: e.variant.id,
                    join: .nothing)],
                carries: [])
            #expect(joined.variants[0].workingText == "bareconcatenation")
        }
    }

    /// Chosen/default (a): the rendered×rendered pairing wins wherever it
    /// sits in the given order.
    @Test func theRenderedPairingIsChosenWhereverItSits() throws {
        try withOperations { ops, _ in
            let post = try ops.createPost()
            let b = try ops.seedBlock(in: post.id, text: "B rendered")
            let bAlt = try ops.branchVariant(b.block.id, from: b.variant.id)
            try ops.autosave(bAlt.id, text: "B alt", charDelta: 0)
            let c = try ops.seedBlock(in: post.id, text: "C rendered")
            let cAlt = try ops.branchVariant(c.block.id, from: c.variant.id)
            try ops.autosave(cAlt.id, text: "C alt", charDelta: 0)
            let a = try ops.mergeCeremony(
                b.block.id, c.block.id,
                pairings: [
                    .init(firstVariantID: bAlt.id, secondVariantID: cAlt.id, join: .space),
                    .init(firstVariantID: b.variant.id, secondVariantID: c.variant.id, join: .space),
                ],
                carries: [])
            #expect(a.block.defaultVariantId == a.variants[1].id,
                    "the rendered×rendered pairing is chosen wherever it sits")
            #expect(a.placement.chosenVariantId == a.variants[1].id)
        }
    }

    /// (b)/(c) of the chosen rule, with legal inputs: first pairing when
    /// the rendered pairing is absent; the first carry when no pairing.
    @Test func chosenRuleWithoutTheRenderedPairing() throws {
        try withOperations { ops, _ in
            let post = try ops.createPost()
            let b = try ops.seedBlock(in: post.id, text: "B rendered")
            let bAlt = try ops.branchVariant(b.block.id, from: b.variant.id)
            try ops.autosave(bAlt.id, text: "B alt", charDelta: 0)
            let c = try ops.seedBlock(in: post.id, text: "C rendered")
            let cAlt = try ops.branchVariant(c.block.id, from: c.variant.id)
            try ops.autosave(cAlt.id, text: "C alt", charDelta: 0)

            // (b) no rendered×rendered pairing → the first pairing listed.
            let paired = try ops.mergeCeremony(
                b.block.id, c.block.id,
                pairings: [
                    .init(firstVariantID: bAlt.id, secondVariantID: c.variant.id, join: .space),
                    .init(firstVariantID: b.variant.id, secondVariantID: cAlt.id, join: .space),
                ],
                carries: [])
            #expect(paired.block.defaultVariantId == paired.variants[0].id)
            #expect(paired.placement.chosenVariantId == paired.variants[0].id)

            // (c) carries only → the first carry (mechanical order).
            let d = try ops.seedBlock(in: post.id, text: "D rendered")
            let dAlt = try ops.branchVariant(d.block.id, from: d.variant.id)
            try ops.autosave(dAlt.id, text: "D alt", charDelta: 0)
            let e = try ops.seedBlock(in: post.id, text: "E rendered")
            _ = try ops.branchVariant(e.block.id, from: e.variant.id)
            let carried = try ops.mergeCeremony(
                d.block.id, e.block.id,
                pairings: [],
                carries: [e.variant.id, d.variant.id])
            // Mechanical order: the FIRST block's carries first — D's take
            // leads regardless of the caller's array order.
            #expect(carried.variants.map(\.workingText) == ["D rendered", "E rendered"])
            #expect(carried.sources == [
                .carried(variantID: d.variant.id),
                .carried(variantID: e.variant.id),
            ])
            #expect(carried.block.defaultVariantId == carried.variants[0].id)
        }
    }

    @Test func ceremonyRefusals() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let b = try ops.seedBlock(in: post.id, text: "b")
            let bAlt = try ops.branchVariant(b.block.id, from: b.variant.id)
            let c = try ops.seedBlock(in: post.id, text: "c")
            let x = try ops.seedBlock(in: post.id, text: "x")

            // Zero pairings + zero carries: the merged block would be born
            // takeless — I10 at confirm.
            #expect(throws: OperationError.mergedBlockWouldHaveNoTake(
                first: b.block.id, second: c.block.id)) {
                try ops.mergeCeremony(b.block.id, c.block.id, pairings: [], carries: [])
            }

            // 1:1 arity: a take in two pairings…
            #expect(throws: OperationError.takePairedTwice(variantID: c.variant.id)) {
                try ops.mergeCeremony(
                    b.block.id, c.block.id,
                    pairings: [
                        .init(firstVariantID: b.variant.id, secondVariantID: c.variant.id, join: .space),
                        .init(firstVariantID: bAlt.id, secondVariantID: c.variant.id, join: .space),
                    ],
                    carries: [])
            }
            // …and a paired take also carried.
            #expect(throws: OperationError.takePairedTwice(variantID: bAlt.id)) {
                try ops.mergeCeremony(
                    b.block.id, c.block.id,
                    pairings: [.init(
                        firstVariantID: bAlt.id, secondVariantID: c.variant.id, join: .space)],
                    carries: [bAlt.id])
            }

            // Sides are sides: a pairing whose left take belongs to the
            // RIGHT block is not found among the left block's takes.
            #expect(throws: OperationError.variantNotFound(id: c.variant.id)) {
                try ops.mergeCeremony(
                    b.block.id, c.block.id,
                    pairings: [.init(
                        firstVariantID: c.variant.id, secondVariantID: b.variant.id, join: .space)],
                    carries: [])
            }

            // Adjacency holds exactly as for the instant merge.
            #expect(throws: OperationError.blocksNotAdjacent(
                first: b.block.id, second: x.block.id)) {
                try ops.mergeCeremony(
                    b.block.id, x.block.id,
                    pairings: [.init(
                        firstVariantID: b.variant.id, secondVariantID: x.variant.id, join: .space)],
                    carries: [])
            }

            // An archived take diagnoses precisely — paired or carried.
            try ops.archiveVariant(bAlt.id)
            #expect(throws: OperationError.archivedVariant(id: bAlt.id)) {
                try ops.mergeCeremony(
                    b.block.id, c.block.id,
                    pairings: [.init(
                        firstVariantID: bAlt.id, secondVariantID: c.variant.id, join: .space)],
                    carries: [])
            }
            #expect(throws: OperationError.archivedVariant(id: bAlt.id)) {
                try ops.mergeCeremony(
                    b.block.id, c.block.id,
                    pairings: [.init(
                        firstVariantID: b.variant.id, secondVariantID: c.variant.id, join: .space)],
                    carries: [bAlt.id])
            }

            // A tombstoned take is simply not found (the gap-slot class at
            // the op level: never join text you can't see).
            let cAlt = try ops.branchVariant(c.block.id, from: c.variant.id)
            try ops.deleteVariant(cAlt.id)
            #expect(throws: OperationError.variantNotFound(id: cAlt.id)) {
                try ops.mergeCeremony(
                    b.block.id, c.block.id,
                    pairings: [.init(
                        firstVariantID: b.variant.id, secondVariantID: cAlt.id, join: .space)],
                    carries: [])
            }

            // Refusals leave no residue: placements live, no edges, no
            // fresh blocks (the transaction rolls back whole).
            #expect(try db.fetchInt("SELECT COUNT(*) FROM edge") == 0)
            #expect(try db.deletedAt("container_block", b.placement.id) == nil)
            #expect(try db.deletedAt("container_block", c.placement.id) == nil)
        }
    }

    @Test func ceremonyRefusesUnderASealedPost() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let b = try ops.seedBlock(in: post.id, text: "b")
            let c = try ops.seedBlock(in: post.id, text: "c")
            _ = try ops.branchVariant(b.block.id, from: b.variant.id)
            try ops.lockPost(post.id)
            #expect(throws: OperationError.lockedPost(id: post.id)) {
                try ops.mergeCeremony(
                    b.block.id, c.block.id,
                    pairings: [.init(
                        firstVariantID: b.variant.id, secondVariantID: c.variant.id, join: .space)],
                    carries: [])
            }
            #expect(try db.fetchInt("SELECT COUNT(*) FROM edge") == 0)
            #expect(try db.deletedAt("container_block", b.placement.id) == nil)
        }
    }

    /// Locked takes COPY fine (the memo's letter): the locked take is never
    /// edited, its copy is born unlocked, and it stays locked on its
    /// released source in lineage.
    @Test func lockedTakesPairAndCarryByCopy() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let b = try ops.seedBlock(in: post.id, text: "Locked head.")
            try ops.lockVariant(b.variant.id)
            let bAlt = try ops.branchVariant(b.block.id, from: b.variant.id)
            try ops.autosave(bAlt.id, text: "Also locked.", charDelta: 0)
            try ops.lockVariant(bAlt.id)
            let c = try ops.seedBlock(in: post.id, text: "Free tail.")

            let result = try ops.mergeCeremony(
                b.block.id, c.block.id,
                pairings: [.init(
                    firstVariantID: b.variant.id, secondVariantID: c.variant.id, join: .space)],
                carries: [bAlt.id])

            #expect(result.variants.map(\.workingText)
                == ["Locked head. Free tail.", "Also locked."])
            #expect(result.variants.allSatisfy { !$0.locked },
                    "copies are not born locked — the poolDragCopy doctrine")
            // The sources' locks are untouched, in lineage.
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM variant WHERE block_id = ? AND locked = 1",
                [b.block.id]) == 2)
        }
    }

    /// Comments travel like merge's: A' carries copies from BOTH sides.
    /// Presentation: kept only when both sources agree.
    @Test func ceremonyCarriesCommentsAndAgreedPresentation() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let b = try ops.seedBlock(in: post.id, text: "b")
            _ = try ops.branchVariant(b.block.id, from: b.variant.id)
            let c = try ops.seedBlock(in: post.id, text: "c")
            _ = try ops.addBlockComment(to: b.block.id, text: "left note")
            _ = try ops.addBlockComment(to: c.block.id, text: "right note")
            let frame = BlockPresentation(color: "accent")
            try ops.setBlockPresentation(b.block.id, frame)
            try ops.setBlockPresentation(c.block.id, frame)

            let result = try ops.mergeCeremony(
                b.block.id, c.block.id,
                pairings: [.init(
                    firstVariantID: b.variant.id, secondVariantID: c.variant.id, join: .space)],
                carries: [])

            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM block_comment WHERE block_id = ? AND deleted_at IS NULL",
                [result.block.id]) == 2, "both sides' notes ride as copies")
            #expect(result.block.presentation == (try frame.encodedJSON()),
                    "both sources agree on the frame — it survives")

            // Disagreeing frames mint PLAIN.
            let d = try ops.seedBlock(in: post.id, text: "d")
            _ = try ops.branchVariant(d.block.id, from: d.variant.id)
            let e = try ops.seedBlock(in: post.id, text: "e")
            try ops.setBlockPresentation(d.block.id, frame)
            let plain = try ops.mergeCeremony(
                d.block.id, e.block.id,
                pairings: [.init(
                    firstVariantID: d.variant.id, secondVariantID: e.variant.id, join: .space)],
                carries: [])
            #expect(plain.block.presentation == nil)
        }
    }

    /// The post is touched, never reshuffled — merge's exact stamp rule.
    @Test func ceremonyTouchesThePostWithoutReshuffling() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let b = try ops.seedBlock(in: post.id, text: "b")
            _ = try ops.branchVariant(b.block.id, from: b.variant.id)
            let c = try ops.seedBlock(in: post.id, text: "c")
            let touchedBefore = try db.fetchString(
                "SELECT last_touched_at FROM container WHERE id = ?", [post.id])
            let majorBefore = try db.fetchString(
                "SELECT last_major_revision_at FROM container WHERE id = ?", [post.id])

            _ = try ops.mergeCeremony(
                b.block.id, c.block.id,
                pairings: [.init(
                    firstVariantID: b.variant.id, secondVariantID: c.variant.id, join: .space)],
                carries: [])

            #expect(try db.fetchString(
                "SELECT last_touched_at FROM container WHERE id = ?", [post.id]) != touchedBefore)
            #expect(try db.fetchString(
                "SELECT last_major_revision_at FROM container WHERE id = ?", [post.id]) == majorBefore)
        }
    }

    /// ONE ⌥⌘Z restores the sources whole — takes, choices, placements.
    @Test func ceremonyUndoRestoresSourcesWhole() throws {
        let stack = UndoStack()
        try withOperations { _, db in
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let before = try ops.seedBlock(in: post.id, text: "before")
            let b = try ops.seedBlock(in: post.id, text: "First half.")
            let bAlt = try ops.branchVariant(b.block.id, from: b.variant.id)
            try ops.autosave(bAlt.id, text: "Alt first.", charDelta: 0)
            try ops.chooseVariant(b.block.id, variantID: bAlt.id)
            let c = try ops.seedBlock(in: post.id, text: "Second half.")
            let after = try ops.seedBlock(in: post.id, text: "after")
            let bPlacementBefore = try db.snapshotRow("container_block", b.placement.id)
            let cPlacementBefore = try db.snapshotRow("container_block", c.placement.id)

            let result = try ops.mergeCeremony(
                b.block.id, c.block.id,
                pairings: [.init(
                    firstVariantID: bAlt.id, secondVariantID: c.variant.id, join: .space)],
                carries: [b.variant.id])
            #expect(stack.topLabel == "Merge Takes")

            try stack.undo(with: ops)

            // The placements flip back EXACTLY — chosen pointer included.
            #expect(try db.snapshotRow("container_block", b.placement.id) == bPlacementBefore)
            #expect(try db.snapshotRow("container_block", c.placement.id) == cPlacementBefore)
            #expect(try liveBlockOrder(db, in: post.id)
                == [before.block.id, b.block.id, c.block.id, after.block.id])
            // Every minted take is tombstoned with its block; edges too.
            #expect(try db.deletedAt("block", result.block.id) != nil)
            for minted in result.variants {
                #expect(try db.deletedAt("variant", minted.id) != nil)
            }
            #expect(try db.deletedAt("container_block", result.placement.id) != nil)
            #expect(try db.deletedAt("edge", result.firstEdge.id) != nil)
            #expect(try db.deletedAt("edge", result.secondEdge.id) != nil)
            // The sources' fans survived untouched.
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM variant WHERE block_id = ? AND deleted_at IS NULL",
                [b.block.id]) == 2)
            #expect(stack.depth == 0)
        }
    }

    /// One canon pairing of the two rendered takes, nothing else — the
    /// ceremony's ⏎ default — lands the SAME text/rows shape as the
    /// instant merge (the parity the sheet's pre-pairing promises).
    @Test func aLoneCanonPairingOfTheRenderedTakesMatchesInstantMerge() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let b = try ops.seedBlock(in: post.id, text: "First half.")
            let bAlt = try ops.branchVariant(b.block.id, from: b.variant.id)
            try ops.autosave(bAlt.id, text: "Alt first.", charDelta: 0)
            let c = try ops.seedBlock(in: post.id, text: "Second half.")

            let result = try ops.mergeCeremony(
                b.block.id, c.block.id,
                pairings: [.init(
                    firstVariantID: b.variant.id, secondVariantID: c.variant.id,
                    join: MergeJoinRule.door.join(
                        head: "First half.", tail: "Second half."))],
                carries: [])

            #expect(result.variants.map(\.workingText) == ["First half.\nSecond half."])
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM variant WHERE block_id = ?", [result.block.id]) == 1)
            #expect(result.block.defaultVariantId == result.variants[0].id)
            #expect(result.placement.chosenVariantId == result.variants[0].id)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM variant WHERE block_id = ? AND deleted_at IS NULL",
                [b.block.id]) == 2, "the other take stays behind in lineage")
        }
    }
}
