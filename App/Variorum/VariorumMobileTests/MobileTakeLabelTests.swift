//
//  MobileTakeLabelTests.swift
//  VariorumMobileTests
//
//  Parity round Stage C, batch C4a — label take: the 13b `setTakeLabel`
//  op's phone face (cards DISPLAYED labels since S2; the set-door was
//  the owed half). The card's ⋯ prompts through an injectable seam and
//  the act routes the standing op — trim-and-NULL clear, legal on locked
//  and archived takes (the op's own recorded rules, pinned here through
//  the door).
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
        let post = try ops.createPost(title: "labels", profile: .blog)
        let a = try ops.newBlock(in: post.id, text: "First block, as chosen.", at: .end)
        _ = try ops.newBlock(in: post.id, text: "Second block, fanless.", at: .end)
        let take = try ops.branchVariant(a.block.id, from: a.variant.id)
        try ops.autosave(take.id, text: "First block, the other way.", charDelta: 9)
        return (post.id, a.block.id, a.variant.id, take.id)
    }
}

@MainActor
private func storedLabel(_ db: AppDatabase, variantID: String) async throws -> String? {
    try await db.read { db in
        try String.fetchOne(
            db,
            sql: "SELECT label FROM variant WHERE id = ? AND deleted_at IS NULL",
            arguments: [variantID])
    }
}

// MARK: - The suite

@MainActor
@Suite("Mobile take labels (parity C4a — the set-door)")
struct MobileTakeLabelTests {
    /// Set → change → clear (empty trims to NULL — the op's own rule),
    /// with the card displaying each state; legal on a LOCKED take (the
    /// lock freezes the buffer, not identity metadata) and on an
    /// ARCHIVED one (the listing is where a label identifies) — and the
    /// prompt seam prefills the CURRENT label under the pinned words.
    @Test func labelSetsChangesClearsAndServesLockedAndArchivedTakes() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.takesBrowser.open(blockID: seed.blockA)

            await model.takesBrowser.setLabel(variantID: seed.a2, label: "bolder opening")
            #expect(model.statusMessage == nil)
            #expect(try await storedLabel(db, variantID: seed.a2) == "bolder opening")
            #expect(model.takesBrowser.cards().last?.label == "bolder opening")

            await model.takesBrowser.setLabel(variantID: seed.a2, label: "  the calm one  ")
            #expect(try await storedLabel(db, variantID: seed.a2) == "the calm one",
                    "the op trims")

            await model.takesBrowser.setLabel(variantID: seed.a2, label: "")
            #expect(try await storedLabel(db, variantID: seed.a2) == nil,
                    "empty clears — trim-and-NULL")

            // The prompt seam: prefilled with the CURRENT label, the
            // pinned words; cancel changes nothing (completion nil).
            await model.takesBrowser.setLabel(variantID: seed.a2, label: "keeper")
            var captured: (title: String, message: String, current: String?)?
            model.takesBrowser.promptForText = { title, message, current, completion in
                captured = (title, message, current)
                completion(nil)
            }
            model.takesBrowser.requestLabel(variantID: seed.a2)
            #expect(captured?.title == MobileTakesBrowserController.labelPromptTitle)
            #expect(captured?.message == MobileTakesBrowserController.labelPromptMessage)
            #expect(captured?.current == "keeper", "prefilled with the stored label")
            #expect(try await storedLabel(db, variantID: seed.a2) == "keeper",
                    "cancel changes nothing")

            // A LOCKED take labels legally (identity metadata, not buffer).
            try await session.runner.run { ops in try ops.lockVariant(seed.a2) }
            await model.refreshTakesFromStore()
            await model.takesBrowser.setLabel(variantID: seed.a2, label: "locked but named")
            #expect(model.statusMessage == nil)
            #expect(try await storedLabel(db, variantID: seed.a2) == "locked but named")

            // An ARCHIVED take labels too, and its listing card shows it.
            try await session.runner.run { ops in
                try ops.unlockVariant(seed.a2)
                try ops.archiveVariant(seed.a2)
            }
            await model.refreshTakesFromStore()
            await model.takesBrowser.reloadArchived()
            await model.takesBrowser.setLabel(variantID: seed.a2, label: "archived, named")
            #expect(model.statusMessage == nil)
            #expect(model.takesBrowser.archivedCards().first?.label == "archived, named")
        }
    }

    /// The seal refuses labeling in phone words (the op's own guard —
    /// the seal freezes everything under the post).
    @Test func labelUnderASealedNoteRefusesInPhoneWords() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            try await session.runner.run { [postID = seed.postID] ops in
                try ops.lockPost(postID)
            }
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.takesBrowser.open(blockID: seed.blockA)

            await model.takesBrowser.setLabel(variantID: seed.a2, label: "sealed away")
            #expect(model.statusMessage == "This note is locked — unlock it to label a take.")
            #expect(try await storedLabel(db, variantID: seed.a2) == nil)
        }
    }
}
