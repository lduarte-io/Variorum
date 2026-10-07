//
//  MobileStructuralTests.swift
//  VariorumMobileTests
//
//  Mobile Stage 4, batch 1 (M10) — the divide/merge doors; the fanned
//  divide re-ruled TWICE, each time riding a ruling of hers. At the
//  mobile gate (Q-M2, parity batch A2) the old auto-proceed/refuse pair
//  gave way to the duplicate shape; at the 2026-09-06 use-report round
//  (**U-2**, 18c batch 1) the duplicate shape gives way to **KEEP ON
//  TOP** — the displayed take is cut, and every other active take rides
//  WHOLE onto the top block through the shared `KeepOnTopDivide`
//  composition and `Operations.divideW`. Her follow-up is what brought
//  the phone along: *"the phone divide should update to match this
//  default divide behavior."*
//
//  The three fanned-divide pins below carry the NEW premise; their old
//  names are kept here rather than deleted silently —
//  `divideOnAFannedBlockLandsTheDuplicateShape` →
//  `divideOnAFannedBlockKeepsTheTakesOnTop`;
//  `divideOnAFannedBlockWithUnmappableTakesStillDivides` and
//  `divideOnAPeekedBlockCutsThePeekedTake` keep their names (their
//  subjects — no-mapping and peek-awareness — outlive the flip) with
//  their expectations rewritten; `fannedDivideCarriesUnflushedTypingThroughTheFlush`
//  likewise. Store-byte checks throughout (the ops are the tested
//  substrate; these pins hold the DOOR's routing, gating, and refusal
//  shapes). Plus the S3 round-2 NIT's pin (the loadOnce cancellation
//  filter).
//

import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

// MARK: - Seeds & probes

@MainActor
private func seedProsePost(
    _ session: AppSession, first: String = "Alpha beta. Gamma delta.",
    second: String? = "Second block prose."
) async throws -> (postID: String, blockA: String, a1: String, blockB: String?, b1: String?) {
    try await session.runner.run { ops in
        let post = try ops.createPost(title: "structural", profile: .blog)
        let a = try ops.newBlock(in: post.id, text: first, at: .end)
        if let second {
            let b = try ops.newBlock(in: post.id, text: second, at: .end)
            return (post.id, a.block.id, a.variant.id, b.block.id, b.variant.id)
        }
        return (post.id, a.block.id, a.variant.id, nil, nil)
    }
}

@MainActor
private func liveBlockTexts(_ db: AppDatabase, postID: String) async throws -> [String] {
    try await storedBlockTexts(db, postID: postID)
}

@MainActor
private func livePlacementBlockIDs(_ db: AppDatabase, postID: String) async throws -> [String] {
    try await db.read { db in
        try String.fetchAll(
            db,
            sql: """
                SELECT block_id FROM container_block
                WHERE container_id = ? AND deleted_at IS NULL
                ORDER BY position, id
                """,
            arguments: [postID])
    }
}

@MainActor
private func activeFanTexts(_ db: AppDatabase, blockID: String) async throws -> [String] {
    try await db.read { db in
        try String.fetchAll(
            db,
            sql: """
                SELECT working_text FROM variant
                WHERE block_id = ? AND deleted_at IS NULL AND status = 'active'
                ORDER BY fan_position, id
                """,
            arguments: [blockID])
    }
}

@MainActor
private func blockIsLive(_ db: AppDatabase, blockID: String) async throws -> Bool {
    try await db.read { db in
        try Bool.fetchOne(
            db, sql: "SELECT deleted_at IS NULL FROM block WHERE id = ?",
            arguments: [blockID]) ?? false
    }
}

@MainActor
@Suite("Mobile structural doors — divide/merge (S4 batch 1, M10)")
struct MobileStructuralTests {
    // MARK: Divide, the everyday in-place cut

    @Test func divideSplitsASingleTakeBlockInPlace() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedProsePost(session)
            // A comment + a callout ride the block — the op's travel
            // rules (copies to the successor; the frame inherits) are
            // the store-byte proof the door ran the REAL op.
            try await session.runner.run { [blockID = seed.blockA] ops in
                _ = try ops.addBlockComment(to: blockID, text: "note")
                try ops.setBlockPresentation(
                    blockID, BlockPresentation(color: "sand", emoji: nil))
            }
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            // The caret after "Alpha beta. " (offset 12 — a word start).
            await model.structural.divide(atSurfaceCaret: 12)

            #expect(model.statusMessage == nil)
            let placements = try await livePlacementBlockIDs(db, postID: seed.postID)
            #expect(placements.count == 3)
            #expect(placements.first == seed.blockA)
            #expect(try await liveBlockTexts(db, postID: seed.postID)
                == ["Alpha beta.", "Gamma delta.", "Second block prose."])
            // The successor inherited the frame and a COPY of the comment.
            let successor = placements[1]
            let successorPresentation = try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT presentation FROM block WHERE id = ?",
                    arguments: [successor])
            }
            #expect(successorPresentation == #"{"color":"sand","kind":"callout"}"#)
            let successorComments = try await db.read { db in
                try Int.fetchOne(
                    db,
                    sql: """
                        SELECT COUNT(*) FROM block_comment
                        WHERE block_id = ? AND deleted_at IS NULL
                        """,
                    arguments: [successor]) ?? 0
            }
            #expect(successorComments == 1)
            // The surface healed to the store's shape.
            #expect(model.index.entries.count == 3)
            #expect(model.viewText(model.index.range(ofEntryAt: 0)) == "Alpha beta.")
            #expect(model.viewText(model.index.range(ofEntryAt: 1)) == "Gamma delta.")
        }
    }

    @Test func divideSnapsAMidWordCaretThroughTheOneSnapBrain() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedProsePost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            // Mid-"Gamma" (offset 15): the ruled word rule settles the
            // cut onto a legal boundary — never a mid-word split.
            await model.structural.divide(atSurfaceCaret: 15)
            #expect(model.statusMessage == nil)
            let texts = try await liveBlockTexts(db, postID: seed.postID)
            #expect(texts.count == 3)
            // Every stored half ends/starts at a word edge (no half of
            // "Gamma" anywhere).
            #expect(!texts[0].hasSuffix("Ga"))
            #expect(texts[0] + " " + texts[1] == "Alpha beta. Gamma delta."
                || texts[0] + texts[1] == "Alpha beta. Gamma delta.")
        }
    }

    @Test func divideCarriesUnflushedTypingThroughTheFlush() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedProsePost(session, second: nil)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            // Type into the block; leave it UNFLUSHED (the harness clock
            // never fires). The door's flush-first contract must carry
            // these bytes into the halves.
            let range = try #require(model.rangeOfBlock(seed.blockA))
            typeEdit(model, storage,
                     range: NSRange(location: range.upperBound, length: 0),
                     replacement: " Typed tail.")
            #expect(model.autosave.isDirty)

            await model.structural.divide(atSurfaceCaret: 12)
            #expect(model.statusMessage == nil)
            #expect(try await liveBlockTexts(db, postID: seed.postID)
                == ["Alpha beta.", "Gamma delta. Typed tail."])
        }
    }

    // MARK: Divide on a fanned block (U-2 — keep on top, 18c batch 1)

    @Test func divideOnAFannedBlockKeepsTheTakesOnTop() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedProsePost(
                session,
                first: "Same beginning of the block here. Different ending number one.",
                second: nil)
            try await session.runner.run { [blockID = seed.blockA, a1 = seed.a1] ops in
                let take = try ops.branchVariant(blockID, from: a1)
                try ops.autosave(
                    take.id,
                    text: "Same beginning of the block here. Different ending number two!",
                    charDelta: 4)
            }
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            // Her ruling's letter (U-2): the DISPLAYED take is cut at
            // "Different" (offset 34); the other take rides WHOLE onto the
            // TOP block and nowhere else — no CutPropagation, no
            // unique-match gate, and no copy on the second successor.
            await model.structural.divide(atSurfaceCaret: 34)
            #expect(model.statusMessage == nil)

            // A is preserved WHOLE and released to lineage (its
            // placement tombstoned, the block + both takes live).
            let placements = try await livePlacementBlockIDs(db, postID: seed.postID)
            #expect(placements.count == 2)
            #expect(!placements.contains(seed.blockA))
            #expect(try await blockIsLive(db, blockID: seed.blockA))
            #expect(try await activeFanTexts(db, blockID: seed.blockA) == [
                "Same beginning of the block here. Different ending number one.",
                "Same beginning of the block here. Different ending number two!",
            ])
            // B: the cut first half leading, the other take whole behind
            // it; C: the second half, ALONE.
            #expect(try await activeFanTexts(db, blockID: placements[0]) == [
                "Same beginning of the block here.",
                "Same beginning of the block here. Different ending number two!",
            ])
            #expect(try await activeFanTexts(db, blockID: placements[1])
                == ["Different ending number one."])
            #expect(model.index.entries.count == 2)
        }
    }

    /// The ruled FLIP pin (Q-M2 superseded M10's refusal; U-2 now sets
    /// the shape): the exact fixture that used to refuse toward the Mac's
    /// ceremony — no shared context anywhere near the cut, so no take
    /// mapped — divides without mapping anything, the other take riding
    /// whole onto the top block. No refusal on this road names any
    /// platform anymore.
    @Test func divideOnAFannedBlockWithUnmappableTakesStillDivides() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedProsePost(
                session, first: "Shared start. Unique tail one.", second: nil)
            try await session.runner.run { [blockID = seed.blockA, a1 = seed.a1] ops in
                let take = try ops.branchVariant(blockID, from: a1)
                // NO shared context anywhere near the cut — the old door
                // refused here; the duplicate shape needs no mapping.
                try ops.autosave(
                    take.id, text: "Entirely different words in this take.",
                    charDelta: 10)
            }
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            await model.structural.divide(atSurfaceCaret: 14)

            #expect(model.statusMessage == nil)
            let placements = try await livePlacementBlockIDs(db, postID: seed.postID)
            #expect(placements.count == 2)
            #expect(!placements.contains(seed.blockA))
            #expect(try await blockIsLive(db, blockID: seed.blockA))
            #expect(try await activeFanTexts(db, blockID: placements[0]) == [
                "Shared start.",
                "Entirely different words in this take.",
            ])
            #expect(try await activeFanTexts(db, blockID: placements[1])
                == ["Unique tail one."])
        }
    }

    /// The peek-aware half of the door's contract: a PEEKED take is the
    /// displayed take, so the cut lands in ITS text and the previously
    /// chosen take rides whole onto the TOP block — and each successor's
    /// chosen is still its cut half, which under keep-on-top is exactly
    /// what `divideW`'s new `displayedVariantID` anchor buys (QUESTIONS
    /// #91): without it the top block would render the chosen take whole
    /// beside the bottom block's tail of the peeked one.
    @Test func divideOnAPeekedBlockCutsThePeekedTake() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedProsePost(
                session, first: "Chosen words entirely here.", second: nil)
            let peeked = try await session.runner.run {
                [blockID = seed.blockA, a1 = seed.a1] ops in
                let take = try ops.branchVariant(blockID, from: a1)
                try ops.autosave(take.id, text: "Peeked take other words.", charDelta: 3)
                return take.id
            }
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            // Flip to the peek: the surface now DISPLAYS the other take
            // (zero store writes — the M6 rule; the peek is the display).
            model.takes.flip(blockID: seed.blockA, forward: true)
            #expect(model.takes.isPeeking(seed.blockA))
            #expect(storage.string == "Peeked take other words.")

            // Cut at "other" (offset 12 of the PEEKED text).
            await model.structural.divide(atSurfaceCaret: 12)
            #expect(model.statusMessage == nil)

            // A released whole — chosen pointer and both takes untouched.
            let placements = try await livePlacementBlockIDs(db, postID: seed.postID)
            #expect(placements.count == 2)
            #expect(!placements.contains(seed.blockA))
            #expect(try await activeFanTexts(db, blockID: seed.blockA)
                == ["Chosen words entirely here.", "Peeked take other words."])
            // The PEEKED take was cut; the chosen take rode whole onto the
            // top block, in FAN ORDER (it leads — it comes first in A's fan).
            #expect(try await activeFanTexts(db, blockID: placements[0])
                == ["Chosen words entirely here.", "Peeked take"])
            #expect(try await activeFanTexts(db, blockID: placements[1])
                == ["other words."])
            // Each successor's chosen is its cut half (the op's rule) —
            // what she was looking at is what each new block shows.
            for (blockID, half) in [(placements[0], "Peeked take"),
                                    (placements[1], "other words.")] {
                let chosenText = try await db.read { db in
                    try String.fetchOne(
                        db,
                        sql: """
                            SELECT v.working_text FROM container_block cb
                            JOIN variant v ON v.id = cb.chosen_variant_id
                            WHERE cb.block_id = ? AND cb.deleted_at IS NULL
                            """,
                        arguments: [blockID])
                }
                #expect(chosenText == half)
            }
            _ = peeked
        }
    }

    /// The flush rides in front on the fanned road exactly as on the
    /// single-take one: unflushed typing lands in the store BEFORE the op
    /// reads it, so the cut halves carry the typed bytes.
    @Test func fannedDivideCarriesUnflushedTypingThroughTheFlush() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedProsePost(session, second: nil)
            try await session.runner.run { [blockID = seed.blockA, a1 = seed.a1] ops in
                let take = try ops.branchVariant(blockID, from: a1)
                try ops.autosave(take.id, text: "The other way entirely.", charDelta: 6)
            }
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            let range = try #require(model.rangeOfBlock(seed.blockA))
            typeEdit(model, storage,
                     range: NSRange(location: range.upperBound, length: 0),
                     replacement: " Typed tail.")
            #expect(model.autosave.isDirty)

            await model.structural.divide(atSurfaceCaret: 12)
            #expect(model.statusMessage == nil)

            let placements = try await livePlacementBlockIDs(db, postID: seed.postID)
            #expect(try await activeFanTexts(db, blockID: placements[0])
                == ["Alpha beta.", "The other way entirely."])
            #expect(try await activeFanTexts(db, blockID: placements[1])
                == ["Gamma delta. Typed tail."])
        }
    }

    @Test func divideRefusalsSpeakTheRefusalShapes() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedProsePost(session, second: nil)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            // A one-word block: no legal interior cut.
            let tiny = try await session.runner.run { [postID = seed.postID] ops in
                try ops.newBlock(in: postID, text: "Word", at: .end)
            }
            await model.refreshTakesFromStore()
            let tinyRange = try #require(model.rangeOfBlock(tiny.block.id))
            await model.structural.divide(atSurfaceCaret: tinyRange.location + 2)
            #expect(model.statusMessage
                == "No legal cut spot for that here — cuts land between words, "
                    + "at sentence ends, and at line breaks.")

            // The open tail is not a block yet — a fresh note's typed
            // tail (type-time crystallization mints the finished
            // paragraph; the trailing text stays an open tail).
            let fresh = try await session.runner.run { ops in
                try ops.createPost(title: "tail", profile: .blog)
            }
            let (tailModel, tailStorage) = makeEditor(session, postID: fresh.id)
            await tailModel.loadOnce()
            typeAtEnd(tailModel, tailStorage, "Para one.\n")
            typeAtEnd(tailModel, tailStorage, "Still typing the tail")
            await tailModel.awaitMintSettle()
            let tailStart = try #require(tailModel.index.tailRange?.location)
            await tailModel.structural.divide(atSurfaceCaret: tailStart + 3)
            #expect(tailModel.statusMessage
                == "This text isn't a block yet — it becomes one moments after you pause typing.")

            // A locked take (single) refuses — branch or unlock.
            try await session.runner.run { [a1 = seed.a1] ops in
                try ops.lockVariant(a1)
            }
            await model.refreshTakesFromStore()
            await model.structural.divide(atSurfaceCaret: 12)
            #expect(model.statusMessage
                == "This take is locked — branch it, or unlock it from its card in the takes sheet (⑂).")

            // The seal outranks everything (the pre-gate's wording once
            // the surface KNOWS the seal; the op's own lockedPost refusal
            // is the belt for the stale-header window).
            try await session.runner.run { [postID = seed.postID] ops in
                try ops.lockPost(postID)
            }
            await model.loadOnce()
            await model.structural.divide(atSurfaceCaret: 12)
            #expect(model.statusMessage
                == "This note is locked — unlock it to restructure.")
            _ = db
        }
    }

    // MARK: Merge with previous

    @Test func mergeJoinsFanlessNeighborsWithTheCanonJoin() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedProsePost(
                session, first: "First half.", second: "Second half.")
            try await session.runner.run { [a = seed.blockA, b = seed.blockB!] ops in
                _ = try ops.addBlockComment(to: a, text: "from A")
                _ = try ops.addBlockComment(to: b, text: "from B")
            }
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            // The caret in block B; merge joins it with the block above.
            let bRange = try #require(model.rangeOfBlock(seed.blockB!))
            await model.structural.mergeWithPrevious(atSurfaceCaret: bRange.location + 3)

            #expect(model.statusMessage == nil)
            let placements = try await livePlacementBlockIDs(db, postID: seed.postID)
            #expect(placements.count == 1)
            let merged = placements[0]
            #expect(merged != seed.blockA && merged != seed.blockB)
            // The canon join — the RENDERING join since her R-13u4-3
            // (2026-09-20): "Merge with Previous" is a DOOR, and the rule
            // is core-side, so the phone flipped with the Mac at 13u4 UNIT
            // E3 (this read "First half. Second half.").
            #expect(try await liveBlockTexts(db, postID: seed.postID)
                == ["First half.\nSecond half."])
            // Both sources released to lineage, live.
            #expect(try await blockIsLive(db, blockID: seed.blockA))
            #expect(try await blockIsLive(db, blockID: seed.blockB!))
            // A' carries BOTH sides' comments (copies).
            let mergedComments = try await db.read { db in
                try String.fetchAll(
                    db,
                    sql: """
                        SELECT text FROM block_comment
                        WHERE block_id = ? AND deleted_at IS NULL
                        ORDER BY created_at, id
                        """,
                    arguments: [merged])
            }
            #expect(Set(mergedComments) == ["from A", "from B"])
            #expect(model.index.entries.count == 1)
        }
    }

    /// The ruled FLIP pin (parity C5 supersedes M10's refusal — her
    /// workaround doctrine, Q-M2's logic on merge): the exact fixture
    /// that used to refuse toward the Mac's ceremony now MERGES — the
    /// two displayed takes join under the canon rule, and every other
    /// active take rides WHOLE onto the merged block (label kept, fresh
    /// row). Archived takes stay with the released source in lineage
    /// (the divideDuplicating parallel). No refusal on this road names
    /// any platform anymore.
    @Test func mergeOnAFannedPairLandsTheCarryAll() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedProsePost(session)
            let (spareID, archivedID) = try await session.runner.run {
                [blockID = seed.blockA, a1 = seed.a1] ops in
                let take = try ops.branchVariant(blockID, from: a1)
                try ops.autosave(take.id, text: "The other way entirely.", charDelta: 6)
                try ops.setTakeLabel(take.id, label: "spare")
                let parked = try ops.branchVariant(blockID, from: a1)
                try ops.autosave(parked.id, text: "Parked words.", charDelta: 3)
                try ops.archiveVariant(parked.id)
                return (take.id, parked.id)
            }
            let (model, surface) = await makeSurfaceEditor(session, postID: seed.postID)
            surface.layoutIfNeeded()

            let bRange = try #require(model.rangeOfBlock(seed.blockB!))
            await model.structural.mergeWithPrevious(atSurfaceCaret: bRange.location + 3)

            #expect(model.statusMessage == nil,
                    "the carry-all merges — no refusal, no redirect")
            let placements = try await livePlacementBlockIDs(db, postID: seed.postID)
            #expect(placements.count == 1)
            let merged = placements[0]
            #expect(merged != seed.blockA && merged != seed.blockB)
            // The fan: the joined take FIRST (chosen — the core's
            // rendered×rendered rule), the carried take whole behind it.
            #expect(try await activeFanTexts(db, blockID: merged) == [
                "Alpha beta. Gamma delta.\nSecond block prose.",
                "The other way entirely.",
            ])
            let carried = try await db.read { db -> (id: String, label: String?)? in
                try Row.fetchOne(
                    db,
                    sql: """
                        SELECT id, label FROM variant
                        WHERE block_id = ? AND deleted_at IS NULL
                          AND status = 'active' AND working_text = ?
                        """,
                    arguments: [merged, "The other way entirely."]
                ).map { (id: $0["id"], label: $0["label"]) }
            }
            #expect(carried?.label == "spare", "a carried take keeps its name")
            #expect(carried?.id != spareID,
                    "the carry is a FRESH row — the source keeps its original")
            let chosenText = try await db.read { db in
                try String.fetchOne(
                    db,
                    sql: """
                        SELECT v.working_text FROM container_block cb
                        JOIN variant v ON v.id = cb.chosen_variant_id
                        WHERE cb.block_id = ? AND cb.deleted_at IS NULL
                        """,
                    arguments: [merged])
            }
            #expect(chosenText == "Alpha beta. Gamma delta.\nSecond block prose.")
            // The archived take did NOT ride — it stays on the released
            // source, which keeps its WHOLE fan in lineage.
            let archivedHome = try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT block_id FROM variant WHERE id = ?",
                    arguments: [archivedID])
            }
            #expect(archivedHome == seed.blockA)
            #expect(try await blockIsLive(db, blockID: seed.blockA))
            #expect(try await blockIsLive(db, blockID: seed.blockB!))
            #expect(try await activeFanTexts(db, blockID: seed.blockA)
                == ["Alpha beta. Gamma delta.", "The other way entirely."])
            // Caret at the join (the instant merge's rule, both roads).
            let mergedRange = try #require(model.rangeOfBlock(merged))
            #expect(surface.textView.selectedRange
                == NSRange(
                    location: mergedRange.location
                        + ("Alpha beta. Gamma delta." as NSString).length,
                    length: 0))
            #expect(model.index.entries.count == 1)
        }
    }

    /// The peek-aware half (Q-M2's peek rule, merge's edition): a PEEKED
    /// take is the displayed take, so IT pairs into the join and the
    /// previously chosen take rides whole as the carry.
    @Test func mergeOnAPeekedPairJoinsTheDisplayedTakes() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedProsePost(
                session, first: "Chosen words here.", second: "Trailing prose.")
            try await session.runner.run { [blockID = seed.blockA, a1 = seed.a1] ops in
                let take = try ops.branchVariant(blockID, from: a1)
                try ops.autosave(take.id, text: "Peeked words instead.", charDelta: 4)
            }
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            model.takes.flip(blockID: seed.blockA, forward: true)
            #expect(model.takes.isPeeking(seed.blockA))
            #expect(storage.string.hasPrefix("Peeked words instead."))

            let bRange = try #require(model.rangeOfBlock(seed.blockB!))
            await model.structural.mergeWithPrevious(atSurfaceCaret: bRange.location + 3)

            #expect(model.statusMessage == nil)
            let placements = try await livePlacementBlockIDs(db, postID: seed.postID)
            #expect(placements.count == 1)
            // The PEEKED take joined; the chosen take rode whole.
            #expect(try await activeFanTexts(db, blockID: placements[0]) == [
                "Peeked words instead.\nTrailing prose.",
                "Chosen words here.",
            ])
            // A released whole — chosen pointer and both takes untouched.
            #expect(try await activeFanTexts(db, blockID: seed.blockA)
                == ["Chosen words here.", "Peeked words instead."])
        }
    }

    /// The flush rides in front on the fanned merge road exactly as on
    /// the fanless one: unflushed typing lands in the store BEFORE the
    /// join is computed, so the joined take carries the typed bytes.
    @Test func fannedMergeCarriesUnflushedTypingThroughTheFlush() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedProsePost(
                session, first: "First half.", second: "Second half.")
            try await session.runner.run { [blockID = seed.blockA, a1 = seed.a1] ops in
                let take = try ops.branchVariant(blockID, from: a1)
                try ops.autosave(take.id, text: "The spare way.", charDelta: 4)
            }
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            let bRange = try #require(model.rangeOfBlock(seed.blockB!))
            typeEdit(model, storage,
                     range: NSRange(location: bRange.upperBound, length: 0),
                     replacement: " Typed tail.")
            #expect(model.autosave.isDirty)

            await model.structural.mergeWithPrevious(atSurfaceCaret: bRange.location + 3)

            #expect(model.statusMessage == nil)
            let placements = try await livePlacementBlockIDs(db, postID: seed.postID)
            #expect(try await activeFanTexts(db, blockID: placements[0]) == [
                "First half.\nSecond half. Typed tail.",
                "The spare way.",
            ])
        }
    }

    @Test func mergeOnTheFirstBlockRefusesHonestly() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedProsePost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            await model.structural.mergeWithPrevious(atSurfaceCaret: 3)
            #expect(model.statusMessage
                == "This is the note's first block — there's nothing above to merge with.")
        }
    }

    // MARK: The post-flush re-verify (S4 ladder MINOR 2)

    /// S4 ladder MINOR 2's red-on-old pin, divide door: the caret's entry
    /// is resolved BEFORE the flush await, and main-actor work landing
    /// INSIDE that window can re-tile the index — the pre-fix door then
    /// trusted the stale position, so a cut snapped in one block's text
    /// was applied to another block's ID (a legal-but-wrong divide). The
    /// deterministic drive: a projection ingest fired synchronously from
    /// the autosave's own settle notification, which runs at the end of
    /// `flushNow()` BEFORE the structural door's await resumes — the
    /// mechanization of a deferred delivery applying mid-suspension.
    @Test func divideReVerifiesTheCaretsBlockAfterTheFlushWindow() async throws {
        try await withEditorWorld { session, db in
            // Three blocks; the LEAD is long, so its remote death shifts
            // every later surface position by more than a block.
            let seed = try await seedProsePost(
                session,
                first: "This lead block is quite long and it is going away soon.",
                second: "Alpha beta. Gamma delta.")
            let blockZ = try await session.runner.run { [postID = seed.postID] ops in
                try ops.newBlock(in: postID, text: "One two go. Four five six seven.", at: .end)
            }
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            // Type into the SECOND block — the flush must have real work.
            let yRange = try #require(model.rangeOfBlock(seed.blockB!))
            typeEdit(model, storage,
                     range: NSRange(location: yRange.upperBound, length: 0),
                     replacement: " Typed.")
            #expect(model.autosave.isDirty)

            // The lead dies REMOTELY (ops directly — the headless world
            // runs no live observation, so the surface still shows it)…
            try await session.runner.run { [blockID = seed.blockA] ops in
                try ops.deleteBlock(blockID)
            }
            // …and its delivery "applies" INSIDE the divide's own flush
            // window, via the settle seam described above.
            let freshProjection = try await session.database.read {
                [postID = seed.postID] db in
                try Queries.takesProjection(db, post: postID)
            }
            var ingested = false
            let token = model.autosave.observe(onSettled: {
                guard !ingested else { return }
                ingested = true
                model.ingest(freshProjection)
            })

            // The caret in the second block (intra 12 — the "Gamma" edge).
            let caret = yRange.location + 12
            await model.structural.divide(atSurfaceCaret: caret)
            model.autosave.stopObserving(token)
            #expect(ingested)

            // RED-ON-OLD: the pre-fix door snapped the cut in the
            // re-tiled entry-1's text (block Z's) and divided the
            // pre-flush block at it — store changed, no refusal. The
            // fixed door refuses on drift, store byte-untouched past
            // the flush itself.
            #expect(model.statusMessage
                == "This block's takes changed — try the divide again.")
            #expect(try await liveBlockTexts(db, postID: seed.postID)
                == ["Alpha beta. Gamma delta. Typed.",
                    "One two go. Four five six seven."])
            #expect(try await livePlacementBlockIDs(db, postID: seed.postID)
                == [seed.blockB!, blockZ.block.id])
        }
    }

    /// The merge door's twin: a block minted remotely BETWEEN the pair
    /// inside the flush window. Honest scope (the round-2 correction):
    /// the pre-fix door did NOT merge — the op's own adjacency belt
    /// refused, surfacing the RAW `blocksNotAdjacent(...)` string (the
    /// revert's recorded 1 issue; store untouched). What this pins is
    /// the DOOR-LEVEL re-verify: the fixed door refuses with its own
    /// spoken message before the op is ever asked.
    @Test func mergeReVerifiesBothNeighborsAfterTheFlushWindow() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedProsePost(
                session, first: "First half.", second: "Second half goes here.")
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            let yRange = try #require(model.rangeOfBlock(seed.blockB!))
            typeEdit(model, storage,
                     range: NSRange(location: yRange.upperBound, length: 0),
                     replacement: " Typed.")
            #expect(model.autosave.isDirty)

            // A new block lands remotely BETWEEN the pair…
            let between = try await session.runner.run {
                [postID = seed.postID, a = seed.blockA] ops in
                try ops.newBlock(
                    in: postID, text: "A whole block that arrived between them.",
                    at: .after(a))
            }
            // …and its delivery applies inside the merge's flush window.
            let freshProjection = try await session.database.read {
                [postID = seed.postID] db in
                try Queries.takesProjection(db, post: postID)
            }
            var ingested = false
            let token = model.autosave.observe(onSettled: {
                guard !ingested else { return }
                ingested = true
                model.ingest(freshProjection)
            })

            await model.structural.mergeWithPrevious(atSurfaceCaret: yRange.location + 3)
            model.autosave.stopObserving(token)
            #expect(ingested)

            // RED-ON-OLD (corrected at S4 round 2): the pre-fix door
            // reached the op, whose adjacency belt refused with the raw
            // `blocksNotAdjacent` string (1 issue; store untouched) —
            // the fixed door refuses at the door with its own message;
            // all three blocks stand, the typed bytes flushed.
            #expect(model.statusMessage
                == "This block's takes changed — try the merge again.")
            #expect(try await liveBlockTexts(db, postID: seed.postID)
                == ["First half.",
                    "A whole block that arrived between them.",
                    "Second half goes here. Typed."])
            #expect(try await livePlacementBlockIDs(db, postID: seed.postID)
                == [seed.blockA, between.block.id, seed.blockB!])
        }
    }

    // MARK: Insert block below (parity C4b item 1)

    /// The ⋯ row's act (birth pin — the door did not exist before C4b):
    /// an EMPTY block mints right under the named block through the
    /// standing `newBlock(at: .after(...))`, I10 holds at birth (the
    /// empty variant IS the one live take), the caret lands in it, and
    /// the Mac door's own status speaks. The awkward
    /// type-into-next-then-divide road retires as THE road; the door
    /// stays honest under it.
    @Test func insertBlockBelowMintsAnEmptyBlockAndLandsTheCaret() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedProsePost(session)
            let (model, surface) = await makeSurfaceEditor(session, postID: seed.postID)
            surface.layoutIfNeeded()

            await model.structural.insertBlockBelow(blockID: seed.blockA)

            #expect(model.statusMessage == MobileStructuralController.blockInsertedStatus)
            let placements = try await livePlacementBlockIDs(db, postID: seed.postID)
            #expect(placements.count == 3)
            #expect(placements.first == seed.blockA)
            #expect(placements.last == seed.blockB)
            let minted = placements[1]
            #expect(try await liveBlockTexts(db, postID: seed.postID)
                == ["Alpha beta. Gamma delta.", "", "Second block prose."])
            // I10 at birth: exactly one live active (empty) take.
            #expect(try await activeFanTexts(db, blockID: minted) == [""])
            // The surface healed and the caret sits in the new block.
            #expect(model.index.entries.map(\.blockID) == placements)
            let range = try #require(model.rangeOfBlock(minted))
            #expect(surface.textView.selectedRange
                == NSRange(location: range.location, length: 0))
        }
    }

    /// The door's guards: a sealed note refuses in phone words with
    /// nothing minted, and a REFUSED flush refuses the act (the
    /// structural-act contract's second half — re-rendering the surface
    /// over unlandable pending bytes is the text-loss class).
    @Test func insertBlockBelowRefusesUnderTheSealAndUnderARefusedFlush() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedProsePost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            // Arm a refused flush: type into A's take, lock it remotely.
            let range = try #require(model.rangeOfBlock(seed.blockA))
            typeEdit(model, storage,
                     range: NSRange(location: range.upperBound, length: 0),
                     replacement: " Typed.")
            #expect(model.autosave.isDirty)
            try await session.runner.run { [a1 = seed.a1] ops in
                try ops.lockVariant(a1)
            }
            await model.structural.insertBlockBelow(blockID: seed.blockA)
            #expect(model.statusMessage
                == "Unsaved changes couldn't be written — resolve that first, then retry.")
            #expect(try await livePlacementBlockIDs(db, postID: seed.postID).count == 2)
            #expect(model.autosave.isDirty)

            // The seal's arm (a fresh, clean world state: unlock + flush).
            try await session.runner.run { [a1 = seed.a1] ops in
                try ops.unlockVariant(a1)
            }
            await model.autosave.flushNow()
            try await session.runner.run { [postID = seed.postID] ops in
                try ops.lockPost(postID)
            }
            model.report(nil)
            await model.structural.insertBlockBelow(blockID: seed.blockA)
            #expect(model.statusMessage
                == "This note is locked — unlock it to add a block.")
            #expect(model.statusMessage?.contains("Mac") == false)
            #expect(try await livePlacementBlockIDs(db, postID: seed.postID).count == 2)
        }
    }

    // MARK: The S3 round-2 NIT's pin

    @Test func aCancelledLoadOnceNeverLandsAsAnError() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedProsePost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)

            // The push-then-immediate-pop shape: the screen's task is
            // cancelled before the read lands — GRDB throws
            // CancellationError, and the status line must NOT stringify
            // a teardown into an error she can read.
            let task = Task { await model.loadOnce() }
            task.cancel()
            await task.value
            #expect(model.statusMessage == nil)
        }
    }
}

// MARK: - The selection acts (parity C4b item 4 — her ruling 5)

@MainActor
@Suite("Mobile selection acts — extract + make block (parity C4b)")
struct MobileSelectionActsTests {
    /// Extract through the door: a boundary-adjacent prefix lifts out
    /// as its own block BEFORE the source (AppSpec §9's letter — the
    /// source survives, keeps identity, keeps its fan), the caret lands
    /// in the extracted block, and unflushed typing rides through the
    /// flush first (the standing contract).
    @Test func extractLiftsABoundarySpanAndCarriesUnflushedTyping() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedProsePost(session)
            let (model, surface) = await makeSurfaceEditor(session, postID: seed.postID)
            surface.layoutIfNeeded()

            // Unflushed typing at A's end — the flush must land it
            // BEFORE the plan reads the surface and the op the store.
            let storage = surface.textView.textStorage
            let aRange = try #require(model.rangeOfBlock(seed.blockA))
            typeEdit(model, storage,
                     range: NSRange(location: aRange.upperBound, length: 0),
                     replacement: " Typed.")
            #expect(model.autosave.isDirty)

            // Select "Alpha beta." — the prefix span.
            await model.structural.extractSelection(
                range: NSRange(location: 0, length: 11))

            #expect(model.statusMessage == nil)
            let placements = try await livePlacementBlockIDs(db, postID: seed.postID)
            #expect(placements.count == 3)
            // The extracted block lands BEFORE the surviving source.
            #expect(placements[1] == seed.blockA)
            #expect(try await liveBlockTexts(db, postID: seed.postID)
                == ["Alpha beta.", "Gamma delta. Typed.", "Second block prose."])
            // The caret sits in the extracted block.
            let landing = try #require(model.rangeOfBlock(placements[0]))
            #expect(surface.textView.selectedRange
                == NSRange(location: landing.location, length: 0))
        }
    }

    /// The fanned-extract documented behavior (AppSpec §9 review #10)
    /// gets the Mac's hint on the phone (PROVISIONAL): extract edits
    /// only the rendered take — the OTHER takes keep the span — and
    /// the status line says so.
    @Test func extractFromAFannedBlockSpeaksTheHintAndSparesOtherTakes() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedProsePost(session)
            try await session.runner.run { [blockID = seed.blockA, a1 = seed.a1] ops in
                _ = try ops.branchVariant(blockID, from: a1)
            }
            let (model, surface) = await makeSurfaceEditor(session, postID: seed.postID)
            surface.layoutIfNeeded()

            await model.structural.extractSelection(
                range: NSRange(location: 0, length: 11))

            #expect(model.statusMessage
                == MobileStructuralController.fannedExtractHint(1))
            #expect(model.statusMessage?.contains("Mac") == false)
            // The other take kept the whole pre-extract text.
            let fan = try await db.read { [blockID = seed.blockA] db in
                try Queries.blockFan(db, blockID: blockID)
                    .filter { $0.deletedAt == nil && $0.status == .active }
                    .map(\.workingText)
            }
            #expect(fan.contains("Alpha beta. Gamma delta."),
                    "the branched take keeps its own copy of the span")
            #expect(fan.contains("Gamma delta."),
                    "the rendered take lost exactly the extracted prefix")
        }
    }

    /// Make Block from Selection: a middle span becomes its own block —
    /// the Mac's exact execution (two divides, ONE compound), the
    /// source keeping identity as the first piece, the caret landing in
    /// the carved middle.
    @Test func makeBlockCarvesAMiddleSpanAsItsOwnBlock() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedProsePost(
                session, first: "Alpha beta. Gamma delta. Epsilon zeta.")
            let (model, surface) = await makeSurfaceEditor(session, postID: seed.postID)
            surface.layoutIfNeeded()

            // Select "Gamma delta." — a true middle span.
            await model.structural.makeBlockFromSelection(
                range: NSRange(location: 12, length: 12))

            #expect(model.statusMessage == nil)
            let placements = try await livePlacementBlockIDs(db, postID: seed.postID)
            #expect(placements.count == 4)
            #expect(placements.first == seed.blockA, "the source keeps identity")
            #expect(try await liveBlockTexts(db, postID: seed.postID)
                == ["Alpha beta.", "Gamma delta.", "Epsilon zeta.",
                    "Second block prose."])
            let landing = try #require(model.rangeOfBlock(placements[1]))
            #expect(surface.textView.selectedRange
                == NSRange(location: landing.location, length: 0))
        }
    }

    /// The refusal shapes, each in phone words with no platform named:
    /// the fanned middle span names the phone's own divide road; the
    /// cross-block spans name the divide/merge roads; extract's middle
    /// span names Make Block; the seal and locked-take arms speak the
    /// standing sentences.
    @Test func selectionActsRefuseInPhoneWords() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedProsePost(session)
            let (model, surface) = await makeSurfaceEditor(session, postID: seed.postID)
            surface.layoutIfNeeded()

            @MainActor
            func expectRefusal(_ message: String, file: String = #function) async throws {
                #expect(model.statusMessage == message)
                #expect(model.statusMessage?.contains("Mac") == false)
                #expect(try await livePlacementBlockIDs(db, postID: seed.postID).count == 2,
                        "a refusal leaves the world untouched")
            }

            // Extract on a MIDDLE span → the Make Block pointer.
            await model.structural.extractSelection(
                range: NSRange(location: 12, length: 5)) // "Gamma"
            try await expectRefusal(MobileStructuralController.spanRefusalMessage(
                .middleSpanNeedsMakeBlock))

            // Make Block on a FANNED block's middle span → the phone's
            // own divide road (never a ceremony, never a platform).
            try await session.runner.run { [blockID = seed.blockA, a1 = seed.a1] ops in
                _ = try ops.branchVariant(blockID, from: a1)
            }
            await model.refreshTakesFromStore()
            await model.structural.makeBlockFromSelection(
                range: NSRange(location: 12, length: 5))
            try await expectRefusal(MobileStructuralController.spanRefusalMessage(
                .fannedMiddleSpan))

            // A cross-block selection: extract refuses to the
            // divide-then-merge road; make-block names merge-first.
            let aLength = try #require(model.rangeOfBlock(seed.blockA)).length
            let crossing = NSRange(location: 12, length: aLength - 12 + 8)
            await model.structural.extractSelection(range: crossing)
            try await expectRefusal(MobileStructuralController.spanRefusalMessage(
                .crossBlockSpan))
            await model.structural.makeBlockFromSelection(range: crossing)
            try await expectRefusal(MobileStructuralController.crossBlockMakeBlockRefusal)

            // The seal outranks every other answer (loadOnce re-reads
            // the header — the headless world runs no live observation).
            try await session.runner.run { [postID = seed.postID] ops in
                try ops.lockPost(postID)
            }
            await model.loadOnce()
            await model.structural.extractSelection(
                range: NSRange(location: 0, length: 11))
            #expect(model.statusMessage
                == MobileStructuralController.spanRefusalMessage(.sealed))
            #expect(model.statusMessage?.contains("Mac") == false)
        }
    }

    /// The door itself (P-2's letter): the selection menu offers the
    /// two acts ONLY when a selection exists — a caret's menu stays
    /// exactly what it was.
    @Test func theSelectionMenuOffersTheActsOnlyWithASelection() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedProsePost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            let cased = MobileEditorStyle.chromeCase

            let caretMenu = MobileEditMenu.menu(
                model: model, range: NSRange(location: 1, length: 0), suggested: [])
            #expect(caretMenu.children.map(\.title)
                == [cased(MobileEditMenu.takesTitle), cased(MobileEditMenu.blockTitle)])

            let selectionMenu = MobileEditMenu.menu(
                model: model, range: NSRange(location: 0, length: 11), suggested: [])
            #expect(selectionMenu.children.map(\.title)
                == [cased(MobileEditMenu.takesTitle),
                    cased(MobileEditMenu.extractTitle),
                    cased(MobileEditMenu.makeBlockTitle),
                    cased(MobileEditMenu.blockTitle)])
        }
    }
}

// MARK: - The whole-target no-redirect sweep (parity C5 — the last pair)

/// The NO-REDIRECT principle made durable (her gate ruling: *"redirecting
/// you to the mac to accomplish something is a bit of a red flag"*; the
/// C1 inventory's fifteen rows all dissolved or sanctioned by C5): no
/// user-facing string in the mobile target names the Mac. The walk is the
/// 14b TerminologyPinTests' deep-walk shape, narrowed to STRING LITERALS
/// (comments narrate the Mac everywhere, legitimately — only what a user
/// can READ is policed). `Spike/` is exempt (DEBUG diagnostics behind the
/// separate TK2SpikeUITests scheme — inventory #15's recorded no-action);
/// test sources are exempt (this file is the pin, and pins quote the
/// strings they police).
@Suite("Mobile no-redirect sweep (parity C5)")
struct MobileNoRedirectSweepTests {
    /// Word-boundary "Mac" (matches "Mac" and "the Mac's"; never "macOS",
    /// "MacBook", or lowercase identifiers). Computed — `Regex` is not
    /// Sendable, so a stored static would not be concurrency-safe.
    /// `.wordBoundaryKind(.simple)` is LOAD-BEARING (traced at the pin's
    /// own red run): Swift Regex's default `\b` is the UAX #29 Unicode
    /// boundary, under which an apostrophe between letters is
    /// word-INTERNAL — the default never matches "the Mac's", and the
    /// pin's first form passed hollow on exactly the strings it exists
    /// to police.
    private static var forbidden: Regex<Substring> {
        /\bMac\b/.wordBoundaryKind(.simple)
    }

    @Test func nothingUserFacingNamesTheMac() throws {
        // BOTH roots the mobile target compiles (C5 ladder MINOR-1):
        // `VariorumMobile/` AND `App/Variorum/Shared/` — Shared views
        // render on the phone. Caveat for a future tripper: a Shared
        // literal inside an `#if os(macOS)` arm never renders on the
        // phone; if one legitimately names the Mac someday, exempt it
        // explicitly here rather than narrowing the walk.
        let appRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumMobileTests
            .deletingLastPathComponent()  // App/Variorum
        let roots = [
            appRoot.appendingPathComponent("VariorumMobile", isDirectory: true),
            appRoot.appendingPathComponent("Shared", isDirectory: true),
        ]
        // THE ONE EXPLICIT EXEMPTION (13p Batch 2 — this walk's own caveat
        // above: "exempt it explicitly here rather than narrowing the
        // walk"): `ProtectionCopy.deviceName`'s macOS arm is the bare
        // literal "Mac" inside `#if os(macOS)` — the protection copy is
        // platform-aware by interpolation (the phone renders "iPhone" /
        // "Face ID" through the same sentences), so the phone never shows
        // it; the literal exists only so the MAC's ruled knot-8 sentences
        // stay byte-identical. Only the exact bare word in that one file
        // is exempt — a sentence naming the Mac still trips.
        let exempt: [(file: String, literal: String)] = [
            (file: "StoreProtection.swift", literal: "Mac"),
            // pre-13x ladder round 2, F3 (the F2 adjudication's copy
            // follow-up 3): `ProtectionCopy.deviceNameWithArticle`'s macOS
            // arm — the bare noun with its article ("a Mac"), in the SAME
            // `#if os(macOS)` block as the exempted "Mac", for the one
            // sentence that names ANOTHER device of the kind ("run Replace
            // All Keys from a Mac that is"); the phone renders "an iPhone"
            // through the same sentence. Exactly this walk's own caveat,
            // exempted explicitly rather than by narrowing the walk.
            (file: "StoreProtection.swift", literal: "a Mac"),
        ]
        // ONE PREFIX exemption (the VM-5 merge, 2026-10-07): the Jekyll
        // sample book's restore instructions name the Mac's Help ▸ Restore
        // because that door exists ONLY there today — 17y kept Jekyll for
        // the Mac's Restore doors and removed the phone's seed, and the
        // phone's OWN sample-restore door is still OWED (MobileSoul PL-17;
        // board: VM-8). The copy is honest about the one road that exists;
        // §4.4's no-redirect bar is answered by the ticket, not by hiding
        // the road. Matched by file + prefix because the literal is a long
        // multiline body. THIS EXEMPTION RETIRES when VM-8 builds the
        // phone's restore door and the copy generalizes.
        let exemptPrefixes: [(file: String, prefix: String)] = [
            (file: "SampleLibraryJekyllBook.swift", prefix: "\n        u{201C}The Strange Case of Dr Jekyll"),
        ]
        var walked = 0
        var offenders: [String] = []
        for root in roots {
            // A missing root yields an EMPTY enumerator, not nil (C5 R2
            // NIT-1) — assert each root exists so a rename can never
            // silently shrink the walk back to one root.
            #expect(FileManager.default.fileExists(atPath: root.path),
                    "sweep root missing: \(root.lastPathComponent)")
            let walk = try #require(FileManager.default.enumerator(
                at: root, includingPropertiesForKeys: nil))
            for case let url as URL in walk where url.pathExtension == "swift" {
                guard !url.path.contains("/Spike/") else { continue }
                walked += 1
                let source = try String(contentsOf: url, encoding: .utf8)
                for literal in Self.stringLiteralContents(of: source)
                where literal.contains(Self.forbidden) {
                    guard !exempt.contains(where: {
                        $0.file == url.lastPathComponent && $0.literal == literal
                    }) else { continue }
                    guard !exemptPrefixes.contains(where: {
                        $0.file == url.lastPathComponent && literal.hasPrefix($0.prefix)
                    }) else { continue }
                    offenders.append("\(url.lastPathComponent): \"\(literal)\"")
                }
            }
        }
        #expect(walked > 40, "the walk must actually reach the shipped mobile sources")
        #expect(offenders.isEmpty,
                "no user-facing mobile string names the Mac — found \(offenders)")
    }

    /// Extracts string-literal CONTENTS from Swift source — single-line
    /// `"…"` and multi-line `"""…"""` — ignoring `//` and `/* */`
    /// comments (which narrate the Mac legitimately). KNOWN LIMIT
    /// (C5 ladder MINOR-2, verified): a literal NESTED inside an
    /// interpolation — `"…\(flag ? "Mac" : "…")…"` — reads as code to
    /// this state machine and is NOT scanned; the pin's claim is
    /// top-level literals. A full tokenizer was judged disproportionate
    /// for a copy sweep; a reviewer hitting this note should re-grep
    /// interpolation bodies by hand if the pattern spreads.
    static func stringLiteralContents(of source: String) -> [String] {
        var literals: [String] = []
        var current = ""
        let chars = Array(source)
        var i = 0
        enum State { case code, lineComment, blockComment, string, multiline }
        var state = State.code
        var blockDepth = 0
        func has(_ pattern: String) -> Bool {
            i + pattern.count <= chars.count
                && String(chars[i..<i + pattern.count]) == pattern
        }
        while i < chars.count {
            switch state {
            case .code:
                if has("\"\"\"") { state = .multiline; current = ""; i += 3 }
                else if has("//") { state = .lineComment; i += 2 }
                else if has("/*") { state = .blockComment; blockDepth = 1; i += 2 }
                else if chars[i] == "\"" { state = .string; current = ""; i += 1 }
                else { i += 1 }
            case .lineComment:
                if chars[i] == "\n" { state = .code }
                i += 1
            case .blockComment:
                if has("/*") { blockDepth += 1; i += 2 }
                else if has("*/") { blockDepth -= 1; i += 2; if blockDepth == 0 { state = .code } }
                else { i += 1 }
            case .string:
                if chars[i] == "\\", i + 1 < chars.count { current.append(chars[i + 1]); i += 2 }
                else if chars[i] == "\"" { literals.append(current); state = .code; i += 1 }
                else if chars[i] == "\n" { state = .code; i += 1 }  // unterminated — bail
                else { current.append(chars[i]); i += 1 }
            case .multiline:
                if has("\"\"\"") { literals.append(current); state = .code; i += 3 }
                else if chars[i] == "\\", i + 1 < chars.count { current.append(chars[i + 1]); i += 2 }
                else { current.append(chars[i]); i += 1 }
            }
        }
        return literals
    }
}

/// pre-13x 5a — THE TWO-REGISTER RULE on the phone (the Mac's
/// `CopyRegisterPinTests` twin; ONE forbidden list): no user-facing string
/// of the phone's protection faces or the Shared copy homes names a
/// key-family internal (*box · vault · escrow · KDF · token · session ·
/// RLS*). The same string-literal extractor, the same exemptions (14b-era
/// sentences copy §11 routes to 13s).
@Suite("The two-register rule on the phone (pre-13x 5a)")
struct MobileCopyRegisterSweepTests {
    private static var forbidden: Regex<Substring> {
        /\b(?:box|boxes|vault|vaults|escrow|escrowed|kdf|token|tokens|session|sessions|rls)\b/
            .ignoresCase().wordBoundaryKind(.simple)
    }
    private static let exemptLiterals: Set<String> = [
        "That recovery phrase doesn't unlock this account's vault.",
        "No encryption vault exists for this account yet — run setup first.",
        "This account already has an encryption vault — enroll with its passphrase instead.",
        "The vault just changed on another device — nothing was overwritten. Try again from the current state.",
        "Passphrase KDF derivation: (seconds, format: .fixed(precision: 3)) s on this device",  // a logger line, never a face
    ]

    @Test func noUserFacingProtectionStringNamesAKeyFamilyInternal() throws {
        let appRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumMobileTests
            .deletingLastPathComponent()  // App/Variorum
        var files: [URL] = [
            "Shared/StoreProtection.swift", "Shared/PostureCopy.swift", "Shared/KeyDoorCopy.swift",
            "Shared/SampleLibrary/SampleLibraryEncryptionBook.swift",
            "Shared/EncryptionViews.swift", "Shared/KeyDoorView.swift", "Shared/KeyDoorModel.swift",
            "Shared/PostureSwitchModel.swift", "Shared/PostureFollowModel.swift",
            "Shared/SyncEnrollmentView.swift", "Shared/SyncEnrollmentModel.swift",
            "Shared/EncryptionSession.swift",
        ].map { appRoot.appendingPathComponent($0) }
        let faces = appRoot.appendingPathComponent("VariorumMobile/Features/Protection", isDirectory: true)
        let walk = try #require(FileManager.default.enumerator(at: faces, includingPropertiesForKeys: nil))
        for case let url as URL in walk where url.pathExtension == "swift" { files.append(url) }
        var offenders: [String] = []
        var literals = 0
        for url in files {
            #expect(FileManager.default.fileExists(atPath: url.path), "copy home missing: \(url.lastPathComponent)")
            let source = try String(contentsOf: url, encoding: .utf8)
            for literal in MobileNoRedirectSweepTests.stringLiteralContents(of: source) {
                literals += 1
                guard literal.contains(Self.forbidden), !Self.exemptLiterals.contains(literal) else { continue }
                offenders.append("\(url.lastPathComponent): \"\(literal.prefix(90))\"")
            }
        }
        #expect(literals > 300)
        #expect(offenders.isEmpty, "the two-register rule on the phone: \(offenders)")
    }
}
