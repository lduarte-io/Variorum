//
//  MobileEditorTests.swift
//  VariorumMobileTests
//
//  Mobile Stage 1, batch 1 — the continuous Write-true editor core's
//  state-transition suite (the Phase 8 house pattern over the new VM):
//  materialization + tiling, edit routing incl. the iOS system paths, the
//  identity re-stamp (the Stage 0 memo's obligation 1), block-scoped
//  autosave/churn, crystallization (typing · bulk · one-block · idle), and
//  the projection discipline (echo / defer / differential).
//

import Dependencies
import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

// MARK: - Materialization + identity

@MainActor
@Suite("Mobile Write editor — materialization & identity (S1 batch 1)")
struct MobileEditorMaterializationTests {
    @Test func materializationTilesBlocksSeparatorsAndAttributes() async throws {
        try await withEditorWorld { session, _ in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "two blocks", profile: .blog)
            }
            let first = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "First block.", at: .end)
            }
            let second = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Second block.", at: .end)
            }

            let (model, storage) = makeEditor(session, postID: post.id)
            await model.loadOnce()

            #expect(storage.string == "First block.\nSecond block.")
            #expect(model.index.entries.map(\.length) == [12, 13])
            #expect(model.index.tailLength == nil)
            // Attributes: each block's range carries its ID; the separator
            // carries none (owned by neither neighbor).
            #expect(EditorDocument.blockID(at: 0, in: storage) == first.block.id)
            #expect(EditorDocument.blockID(at: 12, in: storage) == nil)
            #expect(EditorDocument.blockID(at: 13, in: storage) == second.block.id)
            #expect(model.identityAuditFailures == 0)
        }
    }

    @Test func aTypedInsertionIsReStampedFromTheIndex() async throws {
        // THE OBLIGATION-1 PIN: iOS strips custom attributes on every
        // insertion path (memo item 3) — the simulated keystroke below
        // inserts attribute-bare characters exactly as the real keyboard
        // does, and the model must repair identity from `BlockRangeIndex`.
        // Remove the re-stamp and this fails: the inserted run reads
        // MISSING where its block ID belongs.
        try await withEditorWorld { session, _ in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "restamp", profile: .blog)
            }
            let minted = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Alpha beta gamma.", at: .end)
            }
            let (model, storage) = makeEditor(session, postID: post.id)
            await model.loadOnce()

            // Insert mid-block (the predictive-acceptance shape, case P).
            typeEdit(model, storage, range: NSRange(location: 6, length: 0), replacement: "inserted ")
            #expect(storage.string == "Alpha inserted beta gamma.")
            // Every inserted character carries the block ID (repaired).
            for offset in 6..<15 {
                #expect(EditorDocument.blockID(at: offset, in: storage) == minted.block.id)
            }
            #expect(model.identityAuditFailures == 0)
        }
    }

    @Test func aSystemPathEditWithNoGateCallStillRoutesAndReStamps() async throws {
        // Autocorrect (`replace(_:withText:)`), dictation, and marked-text
        // commits can land in storage WITHOUT consulting the delegate gate
        // — the fallback verdict must route them and the re-stamp must
        // repair them (the memo's cases R/M/D).
        try await withEditorWorld { session, db in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "system path", profile: .blog)
            }
            let minted = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "I like teh word.", at: .end)
            }
            let (model, storage) = makeEditor(session, postID: post.id)
            await model.loadOnce()

            // The autocorrect mechanism: a direct storage replacement of
            // "teh" with "the" — no shouldChangeText call precedes it.
            storage.replaceCharacters(
                in: NSRange(location: 7, length: 3),
                with: NSAttributedString(
                    string: "the",
                    attributes: [.font: MobileEditorStyle.baseFont]))

            #expect(storage.string == "I like the word.")
            #expect(EditorDocument.blockID(at: 7, in: storage) == minted.block.id)
            #expect(model.identityAuditFailures == 0)
            // …and the edit reached the autosave pipeline.
            await model.autosave.flushNow()
            #expect(try await storedText(db, variantID: minted.variant.id) == "I like the word.")
        }
    }
}

// MARK: - The TK2 canary

@MainActor
@Suite("Mobile Write editor — the TK2 checkpoint canary (S1 batch 1)")
struct MobileCanaryTests {
    /// The healthy half: the Write view is TK2-alive at construction and a
    /// checkpoint on it stays silent.
    @Test func aHealthyViewCheckpointsSilently() async throws {
        let view = MobileEditorTextView.make()
        #expect(view.textLayoutManager != nil, "TK2-explicit construction")
        view.armCanary()
        view.canaryCheckpointAfterMutation()
        #expect(!view.canaryFired)
        view.disarmCanary()
    }

    /// The positive control (the spike's, in-suite): a REAL downgrade —
    /// touching the TK1 `.layoutManager` API — is detected synchronously
    /// at the next checkpoint. Runs on a factory-constructed base
    /// UITextView (the system TK2 stack, where the downgrade trigger is
    /// measured real); the assertion seam is swapped for exactly this
    /// test's scope (debug builds stop the world by design).
    @Test func theCheckpointDetectsARealDowngrade() async throws {
        let view = UITextView(usingTextLayoutManager: true)
        #expect(view.textLayoutManager != nil)

        let canary = MobileFallbackCanary()
        var delivered: String?
        canary.onFire = { delivered = $0 }
        let original = MobileFallbackCanary.assertionHandler
        MobileFallbackCanary.assertionHandler = { _ in } // the N2 test seam
        defer { MobileFallbackCanary.assertionHandler = original }

        canary.checkpoint(view, context: "pre-control")
        #expect(!canary.fired, "healthy checkpoint is silent")

        _ = view.layoutManager // the deliberate TK1 touch (spike item 1)
        #expect(view.textLayoutManager == nil, "the downgrade is real on iOS 26")
        canary.checkpoint(view, context: "post-control")
        #expect(canary.fired, "the poll detects the downgrade at the next checkpoint")
        #expect(delivered?.contains("fallback") == true, "the visible diagnostic is delivered")
    }
}

// MARK: - Edit routing + autosave

@MainActor
@Suite("Mobile Write editor — routing & autosave (S1 batch 1)")
struct MobileEditorRoutingTests {
    @Test func aBlockEditAutosavesExactlyItsVariantWithBlockScopedCost() async throws {
        try await withEditorWorld { session, db in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "routing", profile: .blog)
            }
            let first = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "First block.", at: .end)
            }
            let second = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Second block.", at: .end)
            }
            let (model, storage) = makeEditor(session, postID: post.id)
            await model.loadOnce()

            // Append inside block 2 (its range starts at 13).
            typeEdit(model, storage, range: NSRange(location: 26, length: 0), replacement: " More")
            #expect(model.autosave.pending[second.variant.id]?.text == "Second block. More")
            // Block-scoped cost: old 0 + new 5 (never a whole-buffer diff).
            #expect(model.autosave.pending[second.variant.id]?.charDelta == 5)
            #expect(model.autosave.pending[first.variant.id] == nil)

            await model.autosave.flushNow()
            #expect(try await storedText(db, variantID: second.variant.id) == "Second block. More")
            #expect(try await storedText(db, variantID: first.variant.id) == "First block.",
                    "the sibling variant is untouched")
        }
    }

    @Test func aReplacementCostCountsBothSides() async throws {
        try await withEditorWorld { session, _ in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "cost", profile: .blog)
            }
            let minted = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Hello world.", at: .end)
            }
            let (model, storage) = makeEditor(session, postID: post.id)
            await model.loadOnce()

            // Replace "world" (5) with "there!" (6): cost 11 (AppSpec §10 —
            // inserts + deletes, equal weight).
            typeEdit(model, storage, range: NSRange(location: 6, length: 5), replacement: "there!")
            #expect(model.autosave.pending[minted.variant.id]?.charDelta == 11)
        }
    }

    @Test func aCrossBlockEditRefusesAndSpeaks() async throws {
        try await withEditorWorld { session, _ in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "seam", profile: .blog)
            }
            _ = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "One.", at: .end)
            }
            _ = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Two.", at: .end)
            }
            let (model, storage) = makeEditor(session, postID: post.id)
            await model.loadOnce()

            // A deletion spanning the separator (2, 4): crosses the seam.
            let allowed = model.shouldChangeText(
                in: NSRange(location: 2, length: 4), replacement: "")
            #expect(!allowed)
            #expect(model.statusMessage != nil, "the refusal speaks, never silent")
            #expect(storage.string == "One.\nTwo.", "a refused edit never half-applies")
        }
    }

    @Test func aSealedNoteRefusesEveryEdit() async throws {
        try await withEditorWorld { session, _ in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "sealed", profile: .journal, entryDate: "2026-08-01")
            }
            _ = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Sealed text.", at: .end)
            }
            try await session.runner.run { ops in try ops.lockPost(post.id) }

            let (model, _) = makeEditor(session, postID: post.id)
            await model.loadOnce()
            #expect(model.isSealed)
            #expect(!model.shouldChangeText(in: NSRange(location: 0, length: 0), replacement: "x"))
            #expect(model.statusMessage != nil)
        }
    }

    @Test func aLockedTakeRefusesWithItsOwnMessage() async throws {
        try await withEditorWorld { session, _ in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "locked take", profile: .blog)
            }
            let minted = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Guarded.", at: .end)
            }
            try await session.runner.run { ops in
                try ops.lockVariant(minted.variant.id)
            }
            let (model, _) = makeEditor(session, postID: post.id)
            await model.loadOnce()
            #expect(!model.shouldChangeText(in: NSRange(location: 0, length: 0), replacement: "x"))
            #expect(model.statusMessage?.contains("locked") == true)
        }
    }
}

// MARK: - Crystallization

@MainActor
@Suite("Mobile Write editor — crystallization (S1 batch 1)")
struct MobileEditorCrystallizationTests {
    @Test func typingPastAParagraphCrystallizesItThroughTheSharedBrain() async throws {
        try await withEditorWorld { session, db in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "crystallize", profile: .blog)
            }
            _ = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Alpha.", at: .end)
            }
            let (model, storage) = makeEditor(session, postID: post.id)
            await model.loadOnce()

            // Enter at the exact document end opens the tail.
            typeAtEnd(model, storage, "\n")
            #expect(model.hasOpenTail)
            // Type a paragraph; it completes when the NEXT one begins (the
            // 2026-07-12 timing rule).
            typeAtEnd(model, storage, "Beta line")
            typeAtEnd(model, storage, "\n")
            #expect(model.mintInFlight == false, "a paragraph is not complete at its own newline")
            typeAtEnd(model, storage, "Gam")
            await model.awaitMintSettle()

            // The store minted "Beta line"; the surface bytes never moved.
            #expect(try await storedBlockTexts(db, postID: post.id) == ["Alpha.", "Beta line"])
            #expect(storage.string == "Alpha.\nBeta line\nGam")
            #expect(model.index.entries.count == 2)
            #expect(model.tailText == "Gam")
            #expect(model.identityAuditFailures == 0)

            // The still-open remainder mints at teardown (the backstop).
            await model.finish()
            #expect(try await storedBlockTexts(db, postID: post.id) == ["Alpha.", "Beta line", "Gam"])
        }
    }

    @Test func bulkPasteSegmentsOnEntryAndPreservesGaps() async throws {
        try await withEditorWorld { session, db in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "paste", profile: .blog)
            }
            let (model, storage) = makeEditor(session, postID: post.id)
            await model.loadOnce()

            // An empty post is all tail; a paste there is bulk entry.
            typeAtEnd(model, storage, "One\n\nTwo\nThree", isPaste: true)
            await model.awaitMintSettle()

            // The k−1 rule: the double newline stores one trailing newline
            // on "One"; the surface separator re-creates the other.
            #expect(try await storedBlockTexts(db, postID: post.id) == ["One\n", "Two", "Three"])
            #expect(storage.string == "One\n\nTwo\nThree", "surface bytes are untouched by the mint")
            #expect(model.index.entries.count == 3)
            #expect(!model.hasOpenTail, "bulk entry consumes the tail")
            #expect(model.identityAuditFailures == 0)
        }
    }

    @Test func aJournalEntryMintsExactlyOneBlockAndEnterStaysContent() async throws {
        try await withEditorWorld { session, db in
            let entry = try await session.runner.run { ops in
                try ops.createOrOpenJournalEntry(entryDate: "2026-08-03")
            }
            let (model, storage) = makeEditor(session, postID: entry.container.id)
            await model.loadOnce()
            #expect(model.header?.effectiveSegmentation == .oneBlock)

            typeAtEnd(model, storage, "D")
            await model.awaitMintSettle()
            typeAtEnd(model, storage, "ear diary.")
            await model.awaitMintSettle()
            // Enter afterwards is CONTENT of the one block, forever (I4) —
            // one-block posts never open a tail.
            typeAtEnd(model, storage, "\n")
            typeAtEnd(model, storage, "Second line.")
            await model.awaitMintSettle()
            await model.autosave.flushNow()

            let counts = try await db.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM block") ?? -1
            }
            #expect(counts == 1, "one-block journal semantics: exactly ONE block, ever")
            #expect(try await storedBlockTexts(db, postID: entry.container.id)
                    == ["Dear diary.\nSecond line."])
            #expect(model.identityAuditFailures == 0)
        }
    }

    @Test func theIdleMintLandsTheTrailingPartialParagraph() async throws {
        try await withEditorWorld { session, db in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "idle", profile: .blog)
            }
            _ = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Alpha.", at: .end)
            }
            let (model, storage) = makeEditor(session, postID: post.id)
            await model.loadOnce()

            typeAtEnd(model, storage, "\n")
            typeAtEnd(model, storage, "A half-typed thought")
            // The 2 s clock is disabled in tests; fire the mint it would.
            model.idleMintTail()
            await model.awaitMintSettle()

            #expect(try await storedBlockTexts(db, postID: post.id)
                    == ["Alpha.", "A half-typed thought"])
            #expect(!model.hasOpenTail, "the idle mint closes a run-less tail")
            #expect(storage.string == "Alpha.\nA half-typed thought")
        }
    }
}

// MARK: - Projection discipline

@MainActor
@Suite("Mobile Write editor — projection discipline (S1 batch 1)")
struct MobileEditorProjectionTests {
    @Test func anAutosaveEchoNeverRewritesTheSurface() async throws {
        try await withEditorWorld { session, _ in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "echo", profile: .blog)
            }
            _ = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Echo me.", at: .end)
            }
            let (model, storage) = makeEditor(session, postID: post.id)
            await model.loadOnce()
            let rendersAfterLoad = model.fullRenderCount

            typeEdit(model, storage, range: NSRange(location: 8, length: 0), replacement: " Again")
            await model.autosave.flushNow()

            // The flush's own echo arrives as a delivery.
            let fresh = try await session.database.read { [postID = post.id] in
                try Queries.renderPost($0, containerID: postID)
            }
            model.applyProjection(fresh)

            #expect(model.fullRenderCount == rendersAfterLoad,
                    "an echo adopts bookkeeping and touches nothing in the view")
            #expect(storage.string == "Echo me. Again")
        }
    }

    @Test func aDeliveryWhileDirtyDefersUntilSettleThenAppliesFresh() async throws {
        try await withEditorWorld { session, _ in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "defer", profile: .blog)
            }
            _ = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Base.", at: .end)
            }
            let (model, storage) = makeEditor(session, postID: post.id)
            await model.loadOnce()

            // A stale photograph fetched BEFORE the edit below.
            let stale = try await session.database.read { [postID = post.id] in
                try Queries.renderPost($0, containerID: postID)
            }

            typeEdit(model, storage, range: NSRange(location: 5, length: 0), replacement: " Typed")
            // The buffer is dirty: the stale delivery must NOT rewrite the
            // surface to pre-edit text.
            model.applyProjection(stale)
            #expect(storage.string == "Base. Typed", "the buffer is authoritative while dirty")

            await model.autosave.flushNow()
            // The settle path re-fetches FRESH (never adopts the stale
            // value); give the scheduled task a beat.
            for _ in 0..<200 {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            #expect(storage.string == "Base. Typed", "the fresh re-fetch is the flush's own echo")
        }
    }

    @Test func anExternalTakeChoiceAppliesDifferentially() async throws {
        try await withEditorWorld { session, _ in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "differential", profile: .blog)
            }
            let stays = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Stays put.", at: .end)
            }
            let changes = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Original take.", at: .end)
            }
            let (model, storage) = makeEditor(session, postID: post.id)
            await model.loadOnce()
            let rendersAfterLoad = model.fullRenderCount

            // An external change (the Mac choosing another take, arriving
            // via sync): branch + choose, then the delivery.
            let branch = try await session.runner.run { ops in
                try ops.branchVariant(changes.block.id, from: changes.variant.id)
            }
            try await session.runner.run { ops in
                try ops.autosave(branch.id, text: "Chosen take.", charDelta: 12)
            }
            try await session.runner.run { ops in
                try ops.chooseVariant(changes.block.id, variantID: branch.id)
            }
            let fresh = try await session.database.read { [postID = post.id] in
                try Queries.renderPost($0, containerID: postID)
            }
            model.applyProjection(fresh)

            #expect(storage.string == "Stays put.\nChosen take.")
            #expect(model.fullRenderCount == rendersAfterLoad,
                    "same block sequence applies differentially, never a full rebuild")
            #expect(EditorDocument.blockID(at: 11, in: storage) == changes.block.id)
            #expect(model.identityAuditFailures == 0)
            _ = stays
        }
    }

    /// S3 ladder, MAJOR 3 (the adjudicated deterministic drive): a stale
    /// photograph CONSUMED at a clean instant — fetched before a flush,
    /// delivered after it settles — must never rewrite surface or ledger;
    /// the retired Phase 8 capture VM's clean-instant guarantee, restored
    /// ("every delivery is only a signal; the authoritative application is
    /// a fresh read").
    @Test func aStaleDeliveryAtACleanInstantNeverRewritesTheSurface() async throws {
        try await withEditorWorld { session, _ in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "clean instant", profile: .blog)
            }
            let minted = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Base.", at: .end)
            }
            let (model, storage) = makeEditor(session, postID: post.id)
            await model.loadOnce()

            // The photograph a delivery might carry: fetched BEFORE the edit.
            let stale = try await session.database.read { [postID = post.id] in
                try Queries.renderPost($0, containerID: postID)
            }

            typeEdit(model, storage, range: NSRange(location: 5, length: 0), replacement: " Typed")
            await model.autosave.flushNow() // the clean instant; the store holds the typed bytes

            // The stale photograph lands as a DELIVERY after the flush —
            // the round-1 window. Surface and ledger keep the flushed bytes.
            model.applyProjection(stale, fromDelivery: true)
            #expect(storage.string == "Base. Typed",
                    "a delivery never rewrites the surface to pre-flush bytes")
            #expect(model.surfaceKnownText(variantID: minted.variant.id) == "Base. Typed",
                    "the ledger keeps the surface's truth record")

            // The signal settles by a fresh read (the flush's own echo) —
            // give the scheduled task a beat, then re-assert.
            for _ in 0..<100 {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            #expect(storage.string == "Base. Typed")
            #expect(model.surfaceKnownText(variantID: minted.variant.id) == "Base. Typed")

            // The stale-EMPTY analog (the retired double-mint pin's class):
            // an empty photograph at a clean instant must not blank the
            // just-written surface either.
            model.applyProjection([], fromDelivery: true)
            #expect(storage.string == "Base. Typed",
                    "an empty delivery never blanks the surface")
            for _ in 0..<100 {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            #expect(storage.string == "Base. Typed")
        }
    }
}
