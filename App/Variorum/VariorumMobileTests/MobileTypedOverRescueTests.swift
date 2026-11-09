//
//  MobileTypedOverRescueTests.swift
//  VariorumMobileTests
//
//  VX-683 B on the PHONE's surfaces (the VX-849 run, batch 1 — the record
//  `notes/plans/fixes/vx-849-typed-over-rescue.md`, BATCH 1 RECORD): the page
//  editor and the home-screen quick note hand the shared coordinator the text
//  each edit was built on, so a row changed under her typing since (a sync
//  pull inside the debounce window) is RESCUED — her buffer keeps the row, the
//  displaced words land as the `'conflict'` take — never blind-written.
//
//  RED ON OLD (behavioral — pre-fix API only: the real typing roads, a pull's
//  row write, the flush): the two `…RescuesThePullsWords` pins. GUARDS (green
//  on both sides): her own successive runs never mint a card — including a
//  capture whose box text and stored text may differ by the import's
//  normalization (the quick note's `recordBase`).
//

import Dependencies
import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("VX-683 B — the phone's surfaces carry the snapshot")
struct MobileTypedOverRescueTests {
    /// A pull's own row write on the LOCALLY-CLEAN path (apply mode — the
    /// outbox triggers suppressed). No `Sync/` source is called.
    private static func applyAsSyncPull(_ db: AppDatabase, _ variantID: String, _ text: String) async throws {
        try await db.write { db in
            try db.execute(sql: "INSERT INTO _sync_applying (applying) VALUES (1)")
            try db.execute(
                sql: "UPDATE variant SET working_text = ?, sync_version = sync_version + 1 WHERE id = ?",
                arguments: [text, variantID])
            try db.execute(sql: "DELETE FROM _sync_applying")
        }
    }

    /// The live take texts of `postID`'s blocks other than each block's
    /// rendered take — the cards.
    private static func cards(_ db: AppDatabase, postID: String) async throws -> [String] {
        try await db.read { db in
            try String.fetchAll(db, sql: """
                SELECT v.working_text FROM container_block cb
                JOIN block b ON b.id = cb.block_id
                JOIN variant v ON v.block_id = b.id
                WHERE cb.container_id = ? AND cb.deleted_at IS NULL AND v.deleted_at IS NULL
                  AND v.id != COALESCE(cb.chosen_variant_id, b.default_variant_id)
                ORDER BY v.fan_position
                """, arguments: [postID])
        }
    }

    private static func renderedTake(_ db: AppDatabase, postID: String) async throws -> String? {
        try await db.read { db in
            try String.fetchOne(db, sql: """
                SELECT COALESCE(cb.chosen_variant_id, b.default_variant_id) FROM container_block cb
                JOIN block b ON b.id = cb.block_id
                WHERE cb.container_id = ? AND cb.deleted_at IS NULL
                ORDER BY cb.position DESC, cb.id DESC LIMIT 1
                """, arguments: [postID])
        }
    }

    private static func quietBox(_ session: AppSession) -> MobileQuickNoteModel {
        let model = MobileQuickNoteModel(session: session)
        model.sleep = { _ in throw CancellationError() }
        model.autosaveSleep = { _ in throw CancellationError() }
        return model
    }

    // MARK: - The page editor

    /// **RED ON OLD — THE PAGE: she types; a pull lands the Mac's words on the
    /// clean row inside the debounce window; her autosave then fires.**
    @Test func thePageTypingOverASyncPullRescuesThePullsWords() async throws {
        try await withEditorWorld { session, db in
            let post = try session.operations.createPost(title: "p")
            let made = try session.operations.newBlock(in: post.id, text: "The base.", registeringUndo: false)
            let (model, storage) = makeEditor(session, postID: post.id)
            await model.loadOnce()
            typeAtEnd(model, storage, " Her next.")
            #expect(model.autosave.isDirty, "fixture: her typing sits in the debounce window")
            try await Self.applyAsSyncPull(db, made.variant.id, "The Mac's rewrite.")

            await model.autosave.flushNow()

            #expect(try await storedText(db, variantID: made.variant.id) == "The base. Her next.", "R-683-1")
            #expect(try await Self.cards(db, postID: post.id) == ["The Mac's rewrite."],
                    "RED ON OLD: the pull's words survived nowhere")
        }
    }

    /// GUARD — THE PAGE: her own successive runs never mint a card.
    @Test func thePageHerOwnSuccessiveRunsNeverMintACard() async throws {
        try await withEditorWorld { session, db in
            let post = try session.operations.createPost(title: "p")
            let made = try session.operations.newBlock(in: post.id, text: "One.", registeringUndo: false)
            let (model, storage) = makeEditor(session, postID: post.id)
            await model.loadOnce()
            typeAtEnd(model, storage, " Two.")
            await model.autosave.flushNow()
            typeAtEnd(model, storage, " Three.")
            await model.autosave.flushNow()
            #expect(try await storedText(db, variantID: made.variant.id) == "One. Two. Three.")
            #expect(try await Self.cards(db, postID: post.id).isEmpty)
        }
    }

    // MARK: - The quick note

    /// **RED ON OLD — A CAPTURE: the box minted its note; a pull rewrites the
    /// owned take; she types on and the box autosaves.**
    @Test func aQuickCaptureTypedOverAPullRescuesThePullsWords() async throws {
        try await withEditorWorld { session, db in
            let box = Self.quietBox(session)
            box.text = "A quick thought"
            let postID = try #require(await box.mintNow())
            let take = try #require(try await Self.renderedTake(db, postID: postID))
            try await Self.applyAsSyncPull(db, take, "The Mac's rewrite.")

            box.text = "A quick thought, continued"
            await session.flushEveryOpenPost()

            #expect(try await storedText(db, variantID: take) == "A quick thought, continued", "R-683-1")
            #expect(try await Self.cards(db, postID: postID) == ["The Mac's rewrite."],
                    "RED ON OLD: the pull's words survived nowhere")
        }
    }

    /// GUARD — A CAPTURE: her own typing after the mint, flush after flush,
    /// never mints a card — a one-block capture and a pasted two-paragraph one
    /// alike (the box's tail is compared through the STORED text it adopted).
    @Test func aQuickCapturesOwnTypingAfterItsMintNeverMintsACard() async throws {
        for (first, more, again) in [
            ("one paragraph", "one paragraph and more", "one paragraph and more again"),
            ("First paragraph.\n\nSecond.", "First paragraph.\n\nSecond. More.", "First paragraph.\n\nSecond. More. Again."),
        ] {
            try await withEditorWorld { session, db in
                let box = Self.quietBox(session)
                box.text = first
                let postID = try #require(await box.mintNow())
                box.text = more
                await session.flushEveryOpenPost()
                box.text = again
                await session.flushEveryOpenPost()
                #expect(try await Self.cards(db, postID: postID).isEmpty, "\(first.debugDescription)")
            }
        }
    }
}
