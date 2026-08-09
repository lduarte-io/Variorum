//
//  MobileLensesTests.swift
//  VariorumMobileTests
//
//  Parity C5 — the ruled lens shape's state-transition pins (birth pins:
//  the surface did not exist on the old tree). The organizing idea under
//  test: a lens is a saved multi-block peek — activating applies
//  `effectiveLensSelection` as sticky peeks (ZERO store writes; the
//  dangle fallback honest), saves are SPARSE divergences, adopt rides
//  `adoptPicksPreservingChosen` (swaps, never destroys), and every
//  refusal speaks in phone words with no platform named.
//

import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

// MARK: - Seeds & probes

/// A two-block post; the FIRST block carries a second take. Returns the
/// ids the pins steer by.
@MainActor
private func seedLensWorld(
    _ session: AppSession
) async throws -> (
    postID: String, blockA: String, a1: String, a2: String, blockB: String, b1: String
) {
    try await session.runner.run { ops in
        let post = try ops.createPost(title: "lens world", profile: .blog)
        let a = try ops.newBlock(in: post.id, text: "Chosen words here.", at: .end)
        let second = try ops.branchVariant(a.block.id, from: a.variant.id)
        try ops.autosave(second.id, text: "The other reading of it.", charDelta: 5)
        let b = try ops.newBlock(in: post.id, text: "A second block.", at: .end)
        return (post.id, a.block.id, a.variant.id, second.id, b.block.id, b.variant.id)
    }
}

@MainActor
private func storedChosenVariantID(
    _ db: AppDatabase, blockID: String
) async throws -> String? {
    try await db.read { db in
        try String.fetchOne(
            db,
            sql: """
                SELECT chosen_variant_id FROM container_block
                WHERE block_id = ? AND deleted_at IS NULL
                """,
            arguments: [blockID])
    }
}

@MainActor
private func storedLensChoices(
    _ db: AppDatabase, lensID: String
) async throws -> [String: String] {
    try await db.read { db in
        try Queries.lensChoices(db, lens: lensID)
    }
}

@MainActor
@Suite("Mobile lenses (parity C5 — the ruled saved-peek shape)")
struct MobileLensesTests {
    /// SWITCH is viewing: activating applies the lens's effective picks
    /// as sticky peeks — the display moves, the store does not (no
    /// chosen move, no text move) — and "the note" restores truth.
    @Test func activatingALensPeeksItsEffectivePicksAndWritesNothing() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedLensWorld(session)
            let lensID = try await session.runner.run {
                [postID = seed.postID, blockA = seed.blockA, a2 = seed.a2] ops in
                let lens = try ops.createLens(post: postID, name: "draft two")
                _ = try ops.setLensChoice(lens: lens.id, block: blockA, variant: a2)
                return lens.id
            }
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            let lenses = MobileLensesModel(
                session: session, postID: seed.postID, editor: model)
            await lenses.refresh()

            await lenses.activate(lensID)

            // The display follows the lens; the peek machinery carries it.
            #expect(model.slot(for: seed.blockA)?.variantID == seed.a2)
            #expect(storage.string.hasPrefix("The other reading of it."))
            #expect(model.takes.isPeeking(seed.blockA))
            #expect(lenses.activeLensName == "draft two")
            #expect(lenses.chipLabel == "lens: draft two")
            // ZERO store writes: chosen pointer and texts untouched.
            #expect(try await storedChosenVariantID(db, blockID: seed.blockA) == seed.a1)
            #expect(try await storedBlockTexts(db, postID: seed.postID)
                == ["Chosen words here.", "A second block."])

            // "the note": the display is truth again; the session ends.
            lenses.returnToNote()
            #expect(model.slot(for: seed.blockA)?.variantID == seed.a1)
            #expect(!model.takes.isPeeking(seed.blockA))
            #expect(lenses.activeLensID == nil)
            #expect(lenses.chipLabel == "lens")
        }
    }

    /// The dangle fallback, displayed HONESTLY (the ruling's letter; the
    /// LOUD restore door stays 13j's): a pick whose take was archived is
    /// dropped by `effectiveLensSelection` — the row's meta says so, and
    /// activating shows the note's own choice on that block.
    @Test func aDanglingPickFallsThroughAndTheRowSaysSo() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedLensWorld(session)
            let lensID = try await session.runner.run {
                [postID = seed.postID, blockA = seed.blockA, a2 = seed.a2,
                 blockB = seed.blockB, b1 = seed.b1] ops in
                let lens = try ops.createLens(post: postID, name: "half gone")
                _ = try ops.setLensChoice(lens: lens.id, block: blockA, variant: a2)
                // A second fanned block whose pick will dangle.
                let b2 = try ops.branchVariant(blockB, from: b1)
                try ops.autosave(b2.id, text: "Doomed words.", charDelta: 3)
                _ = try ops.setLensChoice(lens: lens.id, block: blockB, variant: b2.id)
                try ops.archiveVariant(b2.id)
                return lens.id
            }
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            let lenses = MobileLensesModel(
                session: session, postID: seed.postID, editor: model)
            await lenses.refresh()

            let row = try #require(lenses.rows.first { $0.name == "half gone" })
            #expect(row.pickCount == 2)
            #expect(row.unavailable == 1)
            #expect(row.meta == "2 picks · 1 points at a removed take — "
                + "those blocks show the note's own choice")

            await lenses.activate(lensID)
            // The live pick peeks; the dangling block falls through to
            // the note's own choice, un-peeked (nothing pretends).
            #expect(model.slot(for: seed.blockA)?.variantID == seed.a2)
            #expect(model.slot(for: seed.blockB)?.variantID == seed.b1)
            #expect(!model.takes.isPeeking(seed.blockB))
        }
    }

    /// C5 ladder MINOR-3 (red-on-old): "save into" clears ONLY picks the
    /// view actually returned to chosen — a DANGLING pick (its take
    /// archived) shows nothing to return from, and save-into must never
    /// tombstone the row the honest meta reports and 13j's restore road
    /// revives.
    @Test func saveIntoNeverClearsADanglingPick() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedLensWorld(session)
            let (lensID, doomed) = try await session.runner.run {
                [postID = seed.postID, blockA = seed.blockA, a2 = seed.a2,
                 blockB = seed.blockB, b1 = seed.b1] ops -> (String, String) in
                let lens = try ops.createLens(post: postID, name: "keeps its ghost")
                _ = try ops.setLensChoice(lens: lens.id, block: blockA, variant: a2)
                let b2 = try ops.branchVariant(blockB, from: b1)
                try ops.autosave(b2.id, text: "Doomed words.", charDelta: 3)
                _ = try ops.setLensChoice(lens: lens.id, block: blockB, variant: b2.id)
                try ops.archiveVariant(b2.id)
                return (lens.id, b2.id)
            }
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            let lenses = MobileLensesModel(
                session: session, postID: seed.postID, editor: model)
            await lenses.refresh()
            await lenses.activate(lensID)
            #expect(model.takes.isPeeking(seed.blockA))

            await lenses.saveIntoActiveLens()
            let stored = try await storedLensChoices(db, lensID: lensID)
            #expect(stored[seed.blockB] == doomed,
                    "the dangling pick SURVIVES a save-into")
            #expect(stored[seed.blockA] == seed.a2)
        }
    }

    /// SAVES are sparse (the lens doctrine's storage philosophy): the
    /// displayed divergences and nothing else; saving puts you IN the
    /// saved lens; "save into the one you're in" upserts what diverges
    /// and clears what returned to chosen.
    @Test func savesWriteTheSparseDivergencesAndSaveIntoUpsertsAndClears() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedLensWorld(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            let lenses = MobileLensesModel(
                session: session, postID: seed.postID, editor: model)
            await lenses.refresh()

            // Arrange by hand: block A displays its other take.
            model.takes.flip(blockID: seed.blockA, forward: true)
            #expect(model.slot(for: seed.blockA)?.variantID == seed.a2)

            #expect(await lenses.saveCurrentView(name: "my reading"))
            let savedID = try #require(lenses.activeLensID)
            #expect(lenses.activeLensName == "my reading")
            // Sparse: exactly the one divergence; the undiverged block
            // has NO row.
            #expect(try await storedLensChoices(db, lensID: savedID)
                == [seed.blockA: seed.a2])

            // Return block A to chosen (the divergence ends), diverge
            // block B instead — then "save into" the active lens.
            let b2 = try await session.runner.run {
                [blockB = seed.blockB, b1 = seed.b1] ops in
                let take = try ops.branchVariant(blockB, from: b1)
                try ops.autosave(take.id, text: "B's other way.", charDelta: 3)
                return take.id
            }
            await model.refreshTakesFromStore()
            model.takes.flip(blockID: seed.blockA, forward: true)  // back to chosen
            #expect(!model.takes.isPeeking(seed.blockA))
            model.takes.peek(blockID: seed.blockB, to: b2)
            #expect(model.takes.isPeeking(seed.blockB))

            await lenses.saveIntoActiveLens()
            #expect(try await storedLensChoices(db, lensID: savedID)
                == [seed.blockB: b2],
                "upserted the new divergence, cleared the returned one")
        }
    }

    /// ADOPT swaps, never destroys (R89/R92's op through the phone
    /// door): the displayed view becomes chosen, the outgoing
    /// arrangement is auto-preserved as a lens, the status names it,
    /// and the peeks + lens session end.
    @Test func adoptMakesTheViewTheNoteAndPreservesTheOutgoing() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedLensWorld(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            let lenses = MobileLensesModel(
                session: session, postID: seed.postID, editor: model)
            await lenses.refresh()

            model.takes.flip(blockID: seed.blockA, forward: true)
            await lenses.refresh()
            #expect(lenses.viewDiverges, "the adopt door has ground to render")

            await lenses.adoptView()

            #expect(try await storedChosenVariantID(db, blockID: seed.blockA) == seed.a2,
                    "the view became the note")
            #expect(!model.takes.isPeeking(seed.blockA),
                    "the store caught up — the peek fulfilled and ended")
            let preservation = try #require(
                lenses.rows.first { $0.name.hasPrefix("chosen until") },
                "the outgoing arrangement is kept as a lens")
            #expect(lenses.status
                == MobileLensesModel.adoptedStatus(preservationName: preservation.name))
            #expect(lenses.activeLensID == nil, "adopting ends the lens session")
        }
    }

    /// Rename/delete are confirm-free doors on the standing ops; the
    /// refusal arms speak in phone words with no platform named: a
    /// blank rename refuses, adopt under the seal refuses in the
    /// standing sealed wording — while SWITCHING stays free under the
    /// seal (a lens is viewing, and viewing is never authoring).
    @Test func renameDeleteAndTheRefusalArms() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedLensWorld(session)
            let lensID = try await session.runner.run {
                [postID = seed.postID, blockA = seed.blockA, a2 = seed.a2] ops in
                let lens = try ops.createLens(post: postID, name: "first name")
                _ = try ops.setLensChoice(lens: lens.id, block: blockA, variant: a2)
                return lens.id
            }
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            let lenses = MobileLensesModel(
                session: session, postID: seed.postID, editor: model)
            await lenses.refresh()

            // Rename: blank refuses in phone words; a real name lands.
            await lenses.rename(lensID, to: "   ")
            #expect(lenses.status == MobileLensesModel.renameRefusal)
            await lenses.rename(lensID, to: "second name")
            #expect(lenses.rows.first { $0.id == lensID }?.name == "second name")

            // Adopt under the seal refuses in the standing wording; the
            // chosen pointer never moves.
            model.takes.flip(blockID: seed.blockA, forward: true)
            try await session.runner.run { [postID = seed.postID] ops in
                try ops.lockPost(postID)
            }
            await lenses.adoptView()
            #expect(lenses.status == MobileLensesModel.sealedAdoptRefusal)
            #expect(try await storedChosenVariantID(db, blockID: seed.blockA) == seed.a1)

            // Switching stays FREE under the seal (viewing, not
            // authoring — the core's own lens posture).
            await lenses.activate(lensID)
            #expect(model.slot(for: seed.blockA)?.variantID == seed.a2)
            #expect(lenses.activeLensID == lensID)

            // Delete: the row goes; deleting the ACTIVE lens ends the
            // session and restores the display to truth.
            await lenses.delete(lensID)
            #expect(!lenses.rows.contains { $0.id == lensID })
            #expect(lenses.activeLensID == nil)
            #expect(model.slot(for: seed.blockA)?.variantID == seed.a1)
        }
    }
}
