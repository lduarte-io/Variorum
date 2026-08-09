//
//  MobileArchivedTakesTests.swift
//  VariorumMobileTests
//
//  Parity round Stage C, batch C4a — the archived-takes listing + the
//  unarchive road: see-your-data made real in the takes sheet (archived
//  takes are her information; `Queries.blockFan` carried them all
//  along), and the "unarchive it on the Mac" redirect dissolves WITH the
//  door (inventory #14).
//

import Dependencies
import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

// MARK: - Harness (the browser suite's fixture shape, re-declared file-locally)

@MainActor
private func seedFannedPost(
    _ session: AppSession
) async throws -> (postID: String, blockA: String, a1: String, a2: String) {
    try await session.runner.run { ops in
        let post = try ops.createPost(title: "archived", profile: .blog)
        let a = try ops.newBlock(in: post.id, text: "First block, as chosen.", at: .end)
        _ = try ops.newBlock(in: post.id, text: "Second block, fanless.", at: .end)
        let take = try ops.branchVariant(a.block.id, from: a.variant.id)
        try ops.autosave(take.id, text: "First block, the other way.", charDelta: 9)
        try ops.setTakeLabel(take.id, label: "the other way")
        return (post.id, a.block.id, a.variant.id, take.id)
    }
}

@MainActor
private func variantStatusRow(_ db: AppDatabase, variantID: String) async throws -> String? {
    try await db.read { db in
        try String.fetchOne(
            db,
            sql: "SELECT status FROM variant WHERE id = ? AND deleted_at IS NULL",
            arguments: [variantID])
    }
}

// MARK: - The suite

@MainActor
@Suite("Mobile archived takes — the listing + the road back (parity C4a)")
struct MobileArchivedTakesTests {
    /// Archive drops the take out of the fan INTO the listing (label
    /// riding — the archived list is exactly where a label identifies);
    /// unarchive returns it to the fan in fan order, listing emptied —
    /// the round trip the refusal copy names.
    @Test func archiveListsTheTakeAndUnarchiveReturnsItToTheFan() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.takesBrowser.open(blockID: seed.blockA)
            await model.takesBrowser.reloadArchived()
            #expect(model.takesBrowser.archivedCards().isEmpty)

            await model.takesBrowser.archive(variantID: seed.a2)
            #expect(model.statusMessage == nil)
            #expect(try await variantStatusRow(db, variantID: seed.a2) == "archived")
            #expect(model.takesBrowser.cards().map(\.variantID) == [seed.a1],
                    "the archived take left the fan")
            let listed = model.takesBrowser.archivedCards()
            #expect(listed.map(\.variantID) == [seed.a2])
            #expect(listed.first?.label == "the other way",
                    "the label rides — it identifies the archived take")
            #expect(listed.first?.text == "First block, the other way.")

            await model.takesBrowser.unarchive(variantID: seed.a2)
            #expect(model.statusMessage == nil)
            #expect(try await variantStatusRow(db, variantID: seed.a2) == "active")
            #expect(model.takesBrowser.cards().map(\.variantID) == [seed.a1, seed.a2],
                    "back into the fan, fan-ordered")
            #expect(model.takesBrowser.archivedCards().isEmpty)
        }
    }

    /// The seal outranks the road back, in phone words; the take stays
    /// archived (nothing half-happens).
    @Test func unarchiveUnderASealedNoteRefusesInPhoneWords() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            try await session.runner.run { ops in try ops.archiveVariant(seed.a2) }
            try await session.runner.run { [postID = seed.postID] ops in
                try ops.lockPost(postID)
            }
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.takesBrowser.open(blockID: seed.blockA)
            await model.takesBrowser.reloadArchived()

            await model.takesBrowser.unarchive(variantID: seed.a2)
            #expect(model.statusMessage == "This note is locked — unlock it to unarchive a take.")
            #expect(try await variantStatusRow(db, variantID: seed.a2) == "archived")
            #expect(model.takesBrowser.archivedCards().map(\.variantID) == [seed.a2],
                    "still listed — viewing under the seal stays free")
        }
    }

    /// Delete works from the archived listing too (the Mac archived
    /// card's second door): the tombstone lands, the listing empties.
    @Test func deleteWorksFromTheArchivedListing() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.takesBrowser.open(blockID: seed.blockA)
            await model.takesBrowser.archive(variantID: seed.a2)
            #expect(model.takesBrowser.archivedCards().count == 1)

            await model.takesBrowser.delete(variantID: seed.a2)
            #expect(model.statusMessage == nil)
            #expect(try await variantStatusRow(db, variantID: seed.a2) == nil,
                    "tombstoned (the live read sees nothing)")
            #expect(model.takesBrowser.archivedCards().isEmpty)
        }
    }

    /// Inventory #14's dissolve, pinned: the archived refusal names the
    /// in-sheet road, never a platform.
    @Test func theArchivedRefusalNamesThePhoneRoadNotTheMac() async throws {
        #expect(MobileTakesBrowserController.archivedTakeRefusal
                == "That take is archived — unarchive it from the archived list below.")
        #expect(MobileTakesBrowserController.refusalMessage(
                    OperationError.archivedVariant(id: "x"), verb: .branch)
                == MobileTakesBrowserController.archivedTakeRefusal)
        #expect(!MobileTakesBrowserController.archivedTakeRefusal.contains("Mac"))
    }
}
