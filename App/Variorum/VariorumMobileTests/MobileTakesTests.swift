//
//  MobileTakesTests.swift
//  VariorumMobileTests
//
//  Mobile Stage 2, batch 1 — the swipe-peek's brain (`MobileTakesController`
//  + the VM's thin routing), headless over the bare-storage seam. The
//  binding cores under test: a flip PEEKS with ZERO store writes (variant
//  rows, chosen pointer, AND the outbox all untouched — pinned); the peek
//  is sticky across deliveries; ✓ is the ONLY choosing act and its
//  refusals speak; typing into a peeked block edits the PEEKED take's
//  `working_text` (R8/R23 — route autosave to the displayed variant); the
//  identity audit stays clean throughout.
//

import Dependencies
import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

// MARK: - Harness

/// A post with a FANNED first block (chosen a1 + take a2) and a fanless
/// second block — the batch's standing fixture.
@MainActor
private func seedFannedPost(
    _ session: AppSession
) async throws -> (postID: String, blockA: String, a1: String, a2: String, blockB: String, b1: String) {
    try await session.runner.run { ops in
        let post = try ops.createPost(title: "takes", profile: .blog)
        let a = try ops.newBlock(in: post.id, text: "First block, as chosen.", at: .end)
        let b = try ops.newBlock(in: post.id, text: "Second block, fanless.", at: .end)
        let take = try ops.branchVariant(a.block.id, from: a.variant.id)
        try ops.autosave(take.id, text: "First block, the other way.", charDelta: 9)
        return (post.id, a.block.id, a.variant.id, take.id, b.block.id, b.variant.id)
    }
}

@MainActor
private func chosenVariantID(_ db: AppDatabase, blockID: String) async throws -> String? {
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
private func outboxCount(_ db: AppDatabase) async throws -> Int {
    try await db.read { db in
        try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_outbox") ?? -1
    }
}

/// One fresh coherent delivery, exactly as the observation would hand it in.
@MainActor
private func deliver(_ model: MobileEditorViewModel, _ db: AppDatabase) async throws {
    let fresh = try await db.read { [postID = model.postID] in
        try Queries.takesProjection($0, post: postID)
    }
    model.ingest(fresh)
}

// MARK: - The suite

@MainActor
@Suite("Mobile takes — the swipe-peek brain (S2 batch 1)")
struct MobileTakesTests {
    // MARK: The peek's zero-write core (M6)

    @Test func flipPeeksInPlaceWithZeroStoreWrites() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            #expect(storage.string == "First block, as chosen.\nSecond block, fanless.")

            let outboxBefore = try await outboxCount(db)
            model.takes.flip(blockID: seed.blockA, forward: true)

            // The DISPLAY moved to the take, in place…
            #expect(storage.string == "First block, the other way.\nSecond block, fanless.")
            #expect(model.takes.isPeeking(seed.blockA))
            // …and the STORE moved nowhere: texts, chosen pointer, outbox.
            #expect(try await storedBlockTexts(db, postID: seed.postID)
                    == ["First block, as chosen.", "Second block, fanless."])
            #expect(try await chosenVariantID(db, blockID: seed.blockA) == seed.a1)
            #expect(try await outboxCount(db) == outboxBefore)
            #expect(model.identityAuditFailures == 0)
            #expect(model.desyncRecoveryCount == 0)
            #expect(model.statusMessage == nil)
        }
    }

    @Test func flipWrapsAndLandingOnTheChosenTakeEndsThePeek() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            model.takes.flip(blockID: seed.blockA, forward: true)
            #expect(model.takes.isPeeking(seed.blockA))
            // The two-take carousel wraps back onto the CHOSEN take —
            // displaying truth is not a peek (M6's unambiguity rule).
            model.takes.flip(blockID: seed.blockA, forward: true)
            #expect(!model.takes.isPeeking(seed.blockA))
            #expect(storage.string == "First block, as chosen.\nSecond block, fanless.")
            #expect(model.takes.originals[seed.blockA] == nil)
            #expect(model.identityAuditFailures == 0)
        }
    }

    @Test func flipDoesNothingOnFanlessOrUnknownBlocks() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            let before = storage.string

            model.takes.flip(blockID: seed.blockB, forward: true)
            model.takes.flip(blockID: "no-such-block", forward: true)
            #expect(storage.string == before)
            #expect(model.takes.peeks.isEmpty)
        }
    }

    // MARK: Editing the peeked take (the brief's item 4)

    @Test func typingIntoAPeekedBlockEditsThePeekedTake() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.takes.flip(blockID: seed.blockA, forward: true)

            // Type at the peeked text's end (inside block A's range).
            let insertAt = ("First block, the other way." as NSString).length
            #expect(typeEdit(
                model, storage,
                range: NSRange(location: insertAt, length: 0),
                replacement: " More."))
            await model.autosave.flushNow()

            // The PEEKED take took the edit; the chosen take and the
            // pointer are untouched (never silently the chosen one).
            #expect(try await storedText(db, variantID: seed.a2)
                    == "First block, the other way. More.")
            #expect(try await storedText(db, variantID: seed.a1)
                    == "First block, as chosen.")
            #expect(try await chosenVariantID(db, blockID: seed.blockA) == seed.a1)
            #expect(model.identityAuditFailures == 0)
            #expect(model.statusMessage == nil)
        }
    }

    @Test func anEditedPeekSurvivesFlippingAwayAndBack() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.takes.flip(blockID: seed.blockA, forward: true)
            let insertAt = ("First block, the other way." as NSString).length
            #expect(typeEdit(
                model, storage,
                range: NSRange(location: insertAt, length: 0),
                replacement: " Edited."))

            // Away (onto chosen) and back — BEFORE any flush lands: the
            // ledger-first resolution must show the edited bytes, never
            // the fan cache's stale photograph.
            model.takes.flip(blockID: seed.blockA, forward: true)
            #expect(storage.string.hasPrefix("First block, as chosen."))
            model.takes.flip(blockID: seed.blockA, forward: true)
            #expect(storage.string.hasPrefix("First block, the other way. Edited."))

            await model.autosave.flushNow()
            #expect(try await storedText(db, variantID: seed.a2)
                    == "First block, the other way. Edited.")
            #expect(model.identityAuditFailures == 0)
        }
    }

    @Test func anEditedChosenTakeSurvivesFlippingAwayAndBack() async throws {
        // The S2 ladder round-1 BLOCKER's pin: the CHOSEN direction is
        // ledger-first exactly like the peeked one. Type into the chosen
        // take with the debounce held open (the injected sleep never
        // fires), flip away and back — the surface AND the ledger hold
        // the edited bytes (the old code restored the stale slot
        // photograph and overwrote the ledger with it), and the flush
        // lands them in the store.
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            let edited = "First block, as chosen. Typed."
            #expect(typeEdit(
                model, storage,
                range: NSRange(location: ("First block, as chosen." as NSString).length,
                               length: 0),
                replacement: " Typed."))
            #expect(model.autosave.isDirty)

            // Away (onto the take) and back (onto chosen) — inside the
            // debounce window, before any flush lands.
            model.takes.flip(blockID: seed.blockA, forward: true)
            #expect(storage.string.hasPrefix("First block, the other way."))
            model.takes.flip(blockID: seed.blockA, forward: true)

            // The surface and the surface's own truth record both hold
            // the edited bytes — never the stale photograph.
            #expect(storage.string.hasPrefix(edited))
            #expect(model.surfaceKnownText(variantID: seed.a1) == edited)

            await model.autosave.flushNow()
            #expect(try await storedText(db, variantID: seed.a1) == edited)
            #expect(model.identityAuditFailures == 0)
        }
    }

    @Test func typingAfterAFlipRoundTripNeverLosesTheEarlierEdit() async throws {
        // The BLOCKER's arm (b) — the permanent-loss shape: on the old
        // code, typing onto the reverted base replaced the pending
        // autosave entry with stale-based text and the earlier keystrokes
        // vanished from `working_text` with no commit anywhere. Both
        // edits must reach the store.
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            #expect(typeEdit(
                model, storage,
                range: NSRange(location: ("First block, as chosen." as NSString).length,
                               length: 0),
                replacement: " Typed."))
            model.takes.flip(blockID: seed.blockA, forward: true)
            model.takes.flip(blockID: seed.blockA, forward: true)

            // Type again at block A's CURRENT end (wherever the round
            // trip left it), then flush: the store holds BOTH edits.
            let rangeA = try #require(model.rangeOfBlock(seed.blockA))
            #expect(typeEdit(
                model, storage,
                range: NSRange(location: rangeA.location + rangeA.length, length: 0),
                replacement: " More."))
            await model.autosave.flushNow()

            #expect(try await storedText(db, variantID: seed.a1)
                    == "First block, as chosen. Typed. More.")
            #expect(model.identityAuditFailures == 0)
        }
    }

    // MARK: Stickiness (M9)

    @Test func thePeekIsStickyAcrossDeliveries() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.takes.flip(blockID: seed.blockA, forward: true)
            let rendersBefore = model.fullRenderCount

            // An unrelated edit lands elsewhere (the fanless block), then a
            // fresh delivery arrives — the peek holds.
            let bStart = ("First block, the other way.\n" as NSString).length
            #expect(typeEdit(
                model, storage,
                range: NSRange(location: bStart, length: 0),
                replacement: "Now edited: "))
            await model.autosave.flushNow()
            try await deliver(model, db)

            #expect(model.takes.isPeeking(seed.blockA))
            #expect(storage.string
                    == "First block, the other way.\nNow edited: Second block, fanless.")
            #expect(model.fullRenderCount == rendersBefore, "deliveries echo, never rebuild")
            #expect(model.identityAuditFailures == 0)
        }
    }

    // MARK: ✓ — the one choosing act (M6)

    @Test func chooseCommitsThePeekThroughOperations() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.takes.flip(blockID: seed.blockA, forward: true)

            await model.takes.chooseDisplayed(blockID: seed.blockA)

            // The store's pointer moved (the Mac would follow); the peek
            // ended — the display IS the truth now.
            #expect(try await chosenVariantID(db, blockID: seed.blockA) == seed.a2)
            #expect(!model.takes.isPeeking(seed.blockA))
            #expect(storage.string.hasPrefix("First block, the other way."))
            #expect(model.statusMessage == nil)

            // The delivery confirms as an echo.
            let rendersBefore = model.fullRenderCount
            try await deliver(model, db)
            #expect(model.fullRenderCount == rendersBefore)
            #expect(storage.string.hasPrefix("First block, the other way."))
            #expect(model.identityAuditFailures == 0)
        }
    }

    @Test func chooseUnderASealedNoteRefusesAndSpeaksWhileThePeekStays() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.takes.flip(blockID: seed.blockA, forward: true)
            try await session.runner.run { ops in try ops.lockPost(seed.postID) }

            await model.takes.chooseDisplayed(blockID: seed.blockA)

            #expect(model.statusMessage
                    == "This note is locked — unlock it on the Mac to choose a take.")
            #expect(try await chosenVariantID(db, blockID: seed.blockA) == seed.a1)
            // The PEEK is reading, not authoring — it survives the refusal.
            #expect(model.takes.isPeeking(seed.blockA))
            #expect(storage.string.hasPrefix("First block, the other way."))
        }
    }

    @Test func peekingASealedNoteIsAllowedButEditingItRefuses() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            try await session.runner.run { ops in try ops.lockPost(seed.postID) }
            let header = try await db.read { [postID = model.postID] in
                try Queries.containerHeader($0, containerID: postID)
            }
            model.adoptHeader(header)

            // The flip is display-only — free under the seal (the seal
            // freezes AUTHORING; a peek is reading).
            model.takes.flip(blockID: seed.blockA, forward: true)
            #expect(model.takes.isPeeking(seed.blockA))
            #expect(storage.string.hasPrefix("First block, the other way."))

            // Typing into the peeked take refuses at the standing gate.
            #expect(!typeEdit(
                model, storage,
                range: NSRange(location: 0, length: 0),
                replacement: "x"))
            #expect(model.statusMessage
                    == "This note is locked — unlock it on the Mac to edit.")
            #expect(try await storedText(db, variantID: seed.a2)
                    == "First block, the other way.")
        }
    }

    @Test func aLockedPeekedTakeRefusesEdits() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            try await session.runner.run { ops in try ops.lockVariant(seed.a2) }
            try await deliver(model, db)

            model.takes.flip(blockID: seed.blockA, forward: true)
            #expect(storage.string.hasPrefix("First block, the other way."))

            #expect(!typeEdit(
                model, storage,
                range: NSRange(location: 0, length: 0),
                replacement: "x"))
            #expect(model.statusMessage
                    == "This take is locked — branch it or unlock it on the Mac to edit.")
            #expect(try await storedText(db, variantID: seed.a2)
                    == "First block, the other way.")
        }
    }

    // MARK: Pruning & fulfillment

    @Test func archivingThePeekedTakeElsewherePrunesThePeek() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.takes.flip(blockID: seed.blockA, forward: true)

            // The Mac archives the very take being peeked; the delivery
            // prunes the peek and the surface heals to chosen.
            try await session.runner.run { ops in try ops.archiveVariant(seed.a2) }
            try await deliver(model, db)

            #expect(!model.takes.isPeeking(seed.blockA))
            #expect(storage.string == "First block, as chosen.\nSecond block, fanless.")
            #expect(model.identityAuditFailures == 0)
        }
    }

    @Test func aRemoteChooseOfThePeekedTakeFulfillsThePeek() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.takes.flip(blockID: seed.blockA, forward: true)

            // The Mac chooses the same take she is peeking: the store
            // caught up — the peek is FULFILLED, the marker ends, the
            // display doesn't move.
            try await session.runner.run { ops in
                try ops.chooseVariant(seed.blockA, variantID: seed.a2)
            }
            try await deliver(model, db)

            #expect(!model.takes.isPeeking(seed.blockA))
            #expect(storage.string.hasPrefix("First block, the other way."))
            #expect(model.identityAuditFailures == 0)
        }
    }

    // MARK: The pill's content brain (LK6)

    @Test func pillContentReportsPositionLabelAndChoosability() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            try await session.runner.run { ops in
                try ops.setTakeLabel(seed.a2, label: "the other way")
            }
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            // Displaying the chosen truth: counts show, ✓ cannot act (P-2
            // renders the "✓ chosen" state instead).
            #expect(model.takes.pillContent(blockID: seed.blockA)
                    == .init(text: "take 1/2", canChoose: false))
            // Peeking: position + the take's label + a real ✓.
            model.takes.flip(blockID: seed.blockA, forward: true)
            #expect(model.takes.pillContent(blockID: seed.blockA)
                    == .init(text: "take 2/2 · the other way", canChoose: true))
            // Fanless blocks have no pill at all.
            #expect(model.takes.pillContent(blockID: seed.blockB) == nil)
        }
    }
}
