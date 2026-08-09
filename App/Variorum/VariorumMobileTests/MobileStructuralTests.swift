//
//  MobileStructuralTests.swift
//  VariorumMobileTests
//
//  Mobile Stage 4, batch 1 (M10) — the divide/merge doors; the fanned
//  divide re-ruled at the gate (Q-M2, parity batch A2): a fanned block
//  divides through the shared duplicate-shape op — displayed take cut,
//  every other active take duplicated whole onto both successors — and
//  the old auto-proceed/refuse pair is retired (a sanctioned pin flip
//  riding her ruling). Store-byte checks throughout (the ops are the
//  tested substrate; these pins hold the DOOR's routing, gating, and
//  refusal shapes). Plus the S3 round-2 NIT's pin (the loadOnce
//  cancellation filter).
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

    // MARK: Divide on a fanned block (Q-M2 — the duplicate shape, parity A2)

    @Test func divideOnAFannedBlockLandsTheDuplicateShape() async throws {
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

            // Her ruling's letter: the DISPLAYED take is cut at "Different"
            // (offset 34); the other take is DUPLICATED WHOLE onto both
            // successors — no CutPropagation, no unique-match gate.
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
            // it; C: the second half leading, the same duplicate behind.
            #expect(try await activeFanTexts(db, blockID: placements[0]) == [
                "Same beginning of the block here.",
                "Same beginning of the block here. Different ending number two!",
            ])
            #expect(try await activeFanTexts(db, blockID: placements[1]) == [
                "Different ending number one.",
                "Same beginning of the block here. Different ending number two!",
            ])
            #expect(model.index.entries.count == 2)
        }
    }

    /// The ruled FLIP pin (Q-M2 supersedes M10's refusal): the exact
    /// fixture that used to refuse toward the Mac's ceremony — no shared
    /// context anywhere near the cut, so no take mapped — now divides
    /// with the duplicate shape. No refusal on this road names any
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
            #expect(try await activeFanTexts(db, blockID: placements[1]) == [
                "Unique tail one.",
                "Entirely different words in this take.",
            ])
        }
    }

    /// The peek-aware half of the door's contract: a PEEKED take is the
    /// displayed take, so the cut lands in ITS text and the previously
    /// chosen take rides whole onto both successors as a duplicate — and
    /// each successor's chosen is its cut half.
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
            // The PEEKED take was cut; the chosen take duplicated whole.
            #expect(try await activeFanTexts(db, blockID: placements[0])
                == ["Peeked take", "Chosen words entirely here."])
            #expect(try await activeFanTexts(db, blockID: placements[1])
                == ["other words.", "Chosen words entirely here."])
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
                == ["Gamma delta. Typed tail.", "The other way entirely."])
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

    @Test func mergeJoinsFanlessNeighborsWithTheCanonSpace() async throws {
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
            // The canon join: a single space at the seam.
            #expect(try await liveBlockTexts(db, postID: seed.postID)
                == ["First half. Second half."])
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

    @Test func mergeRefusesToTheMacCeremonyWhenEitherSideCarriesAFan() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedProsePost(session)
            try await session.runner.run { [blockID = seed.blockA, a1 = seed.a1] ops in
                let take = try ops.branchVariant(blockID, from: a1)
                try ops.autosave(take.id, text: "The other way entirely.", charDelta: 6)
            }
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            let before = try await liveBlockTexts(db, postID: seed.postID)

            let bRange = try #require(model.rangeOfBlock(seed.blockB!))
            await model.structural.mergeWithPrevious(atSurfaceCaret: bRange.location + 3)

            #expect(model.statusMessage
                == "One of these blocks has other takes — pairing takes into a "
                    + "merge is the Mac's merge ceremony.")
            #expect(try await liveBlockTexts(db, postID: seed.postID) == before)
            #expect(try await livePlacementBlockIDs(db, postID: seed.postID).count == 2)
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
