//
//  MobileConflictDiscoveryTests.swift
//  VariorumMobileTests
//
//  Parity round Stage C, batch C4a — THE S5 CONFLICT-DISCOVERABILITY
//  VERIFY + PIN (the C-kickoff's named check; MobileSoul §5.3: offline
//  is the phone's NORMAL, so conflict-as-variant fires more here than it
//  ever did between two desks — a conflict variant landing on the phone
//  must be DISCOVERABLE there).
//
//  THE MECHANISM UNDER PROOF (traced end to end): the engine's reject
//  merge lands the losing text through `resolveSyncConflict` — a fresh
//  ACTIVE variant on the same block, label 'conflict', at the fan's end
//  (S5: nothing is ever clobbered). An active second variant makes the
//  slot's `activeVariantCount` 2 → `hasFan` → the ⑂ BADGE renders on
//  the block (the natural face), the swipe pill counts "take 1/2", and
//  the browser's fan road lists the conflict card wearing its label —
//  three roads, one delivery, zero new code owed. These pins hold that
//  road open forever.
//

import Dependencies
import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

// MARK: - Harness (the browser suite's laid-out-surface shape, re-declared)

@MainActor
private func seedPost(
    _ session: AppSession
) async throws -> (postID: String, blockID: String, variantID: String) {
    try await session.runner.run { ops in
        let post = try ops.createPost(title: "conflicts", profile: .journal)
        let a = try ops.newBlock(
            in: post.id, text: "The phone's own sentence.", at: .end)
        _ = try ops.newBlock(in: post.id, text: "A second, calm block.", at: .end)
        return (post.id, a.block.id, a.variant.id)
    }
}

@MainActor
private func makeSurface(
    _ session: AppSession, postID: String
) async -> (model: MobileEditorViewModel, surface: MobileWriteSurfaceView) {
    let model = MobileEditorViewModel(
        session: session, postID: postID,
        sleep: { _ in throw CancellationError() })
    model.tailIdleSleep = { _ in throw CancellationError() }
    let surface = MobileWriteSurfaceView()
    surface.frame = CGRect(x: 0, y: 0, width: 393, height: 700)
    model.attach(textView: surface.textView)
    await model.loadOnce()
    surface.layoutIfNeeded()
    return (model, surface)
}

/// The delivery arm: exactly what the standing observation does when the
/// sync apply's rows land — one fresh coherent read, ingested as a
/// delivery (headless tests drive the arm deterministically; in
/// production the observation fires it).
@MainActor
private func deliver(_ model: MobileEditorViewModel, _ db: AppDatabase) async throws {
    let fresh = try await db.read { [postID = model.postID] in
        try Queries.takesProjection($0, post: postID)
    }
    model.ingest(fresh, fromDelivery: true)
}

// MARK: - The suite

@MainActor
@Suite("Mobile S5 conflict discoverability (parity C4a — the verify + pin)")
struct MobileConflictDiscoveryTests {
    /// THE HEADLINE PIN: a conflict variant landing on a displayed block
    /// surfaces on ALL THREE roads — the ⑂ badge (the natural face), the
    /// swipe pill's count, and the browser's fan with the 'conflict'
    /// label — while the chosen text stands untouched (S5's letter:
    /// nothing clobbered, the losing edit becomes a card in the fan).
    @Test func aConflictVariantLandingSurfacesInTheBadgePillAndBrowser() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedPost(session)
            let (model, surface) = await makeSurface(session, postID: seed.postID)

            // Before: one take, no fan, no badge — the calm default.
            #expect(model.slot(for: seed.blockID)?.hasFan == false)
            #expect(surface.textView.takesChrome?.badgeView(for: seed.blockID) == nil)

            // The engine's landing: the losing text becomes a take
            // (label 'conflict', the fan's end) — the S5 op itself.
            let losing = "The other device's sentence."
            let conflict = try await session.runner.run { ops in
                try ops.resolveSyncConflict(seed.variantID, losingText: losing)
            }
            try await deliver(model, db)
            surface.layoutIfNeeded()

            // Road 1 — the badge: the block is fanned now and wears ⑂.
            let slot = try #require(model.slot(for: seed.blockID))
            #expect(slot.activeVariantCount == 2, "the conflict take is ACTIVE — a real fan")
            #expect(slot.hasFan)
            #expect(surface.textView.takesChrome?.badgeView(for: seed.blockID) != nil,
                    "the ⑂ badge renders — the conflict is discoverable at a glance")

            // Road 2 — the pill's count (any flip shows "take 1/2").
            #expect(model.takes.pillContent(blockID: seed.blockID)?.text == "take 1/2")

            // Road 3 — the browser's fan: the conflict card, labeled,
            // NOT chosen; the chosen card untouched.
            model.takesBrowser.open(blockID: seed.blockID)
            let cards = model.takesBrowser.cards()
            #expect(cards.map(\.variantID) == [seed.variantID, conflict.id],
                    "the conflict lands at the fan's end")
            #expect(cards[1].label == "conflict", "the card says what it is")
            #expect(!cards[1].isChosen && cards[0].isChosen,
                    "the chosen pointer never moved — S5 clobbers nothing")
            #expect(cards[1].text == losing, "the losing text is all there")
            #expect(cards[0].text == "The phone's own sentence.")

            // And the store agrees: both texts live, chosen untouched.
            let chosen = try await db.read { db in
                try String.fetchOne(
                    db,
                    sql: """
                        SELECT chosen_variant_id FROM container_block
                        WHERE block_id = ? AND deleted_at IS NULL
                        """,
                    arguments: [seed.blockID])
            }
            #expect(chosen == seed.variantID)
        }
    }

    /// The sealed arm: S5 outranks the seal (the op's documented rule —
    /// a sync conflict is not authoring, and refusing would throw the
    /// losing text away). The landed conflict is DISCOVERABLE under the
    /// seal too — viewing stays free; only editing refuses.
    @Test func aConflictLandsEvenUnderASealAndStaysDiscoverable() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedPost(session)
            try await session.runner.run { [postID = seed.postID] ops in
                try ops.lockPost(postID)
            }
            let (model, surface) = await makeSurface(session, postID: seed.postID)

            let conflict = try await session.runner.run { ops in
                try ops.resolveSyncConflict(
                    seed.variantID, losingText: "Typed offline, elsewhere.")
            }
            try await deliver(model, db)
            surface.layoutIfNeeded()

            #expect(model.slot(for: seed.blockID)?.hasFan == true,
                    "the conflict landed despite the seal — S5 outranks it")
            #expect(surface.textView.takesChrome?.badgeView(for: seed.blockID) != nil)

            model.takesBrowser.open(blockID: seed.blockID)
            let cards = model.takesBrowser.cards()
            #expect(cards.count == 2)
            #expect(cards.last?.label == "conflict")

            // Viewing is free; EDITING the conflict card refuses with
            // the sealed copy (the browser's standing gate).
            model.takesBrowser.beginEditing(variantID: conflict.id)
            #expect(model.takesBrowser.editingVariantID == nil)
            #expect(model.statusMessage == "This note is locked — unlock it to edit.")
        }
    }
}
