//
//  TrashPurgeDoorsTests.swift
//  VariorumTests
//
//  Phase 13j, batch 6b — the purge DOORS (J1's second half, built): Delete
//  Now per row and Empty Trash, IN-TRASH ONLY, backed by the ONE op
//  (`requestPurge` — the intent write; the janitor takes the bytes at the
//  horizon, tested in core's PurgeConvergenceTests).
//
//  Her rulings under test: Delete Now confirms EVERY TIME (round 10 — no
//  session-scoped don't-ask); Empty Trash is everything-always and its
//  confirm NAMES THE FULL COUNT BY KIND (round 8, the memo's wording
//  shape); rows leave every surface the moment the intent lands (the
//  read-side fence); the receipts tell the NOW-vs-janitor truth (J8); a
//  preserved original has no purge door of its own (round 8b — it rides
//  its family).
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("The purge doors: Delete Now & Empty Trash (13j 6b)")
struct TrashPurgeDoorsTests {
    // MARK: - Delete Now

    @Test func deleteNowConfirmsEveryTimeAndTheConfirmedActEmptiesTheRow() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { editor in
            let blockID = try #require(editor.model.slots.first?.blockID)
            try await editor.session.runner.run { (ops: Operations) in
                try ops.deleteBlock(blockID)
            }
            let rows: [Queries.TrashItem] = try await editor.database.read { db in
                try Queries.trash(db, now: harnessNow)
            }
            let row = try #require(rows.first { $0.kind == .block })
            let model = RecoveryViewModel(session: editor.session)

            // The door NEVER acts directly — it raises the confirm.
            model.requestDeleteNow(row)
            guard case .deleteNow(let confirmed)? = model.pendingConfirm else {
                Issue.record("Delete Now must raise its confirm, never act")
                return
            }
            #expect(confirmed.id == row.id)
            #expect(model.pendingConfirm?.message.contains("for good") == true)
            #expect(model.pendingConfirm?.message.contains("30") == true,
                    "the confirm says what is being skipped")

            // Cancel mints NOTHING.
            model.cancelPendingPurge()
            let afterCancel: Int = try await editor.database.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM purge_intent") ?? 0
            }
            #expect(afterCancel == 0)

            // EVERY time (round 10): the second request asks again — there
            // is no don't-ask state anywhere to set.
            model.requestDeleteNow(row)
            #expect(model.pendingConfirm != nil, "asked every time, by her ruling")

            // Confirm: ONE intent lands, the row leaves the Trash at once
            // (the read-side fence), and the receipt tells the split truth.
            //
            // LADDER B (B3), ANNOTATED PIN EDIT — a RULED change, never a
            // quietly relaxed pin (her round-11 ruling: never-synced things
            // purge immediately). This test's world has no sync chain, so
            // the confirm's local sweep now COMPLETES the intent and takes
            // the bytes on the spot — the assertions graduate to the
            // STRONGER truth: intent completed, family physically gone,
            // and the receipt speaks the LOCAL wording (no "synced
            // devices" that don't exist).
            await model.confirmPendingPurge()
            #expect(model.lastError == nil)
            let intentStates: (live: Int, completed: Int) = try await editor.database.read { db in
                (try Int.fetchOne(
                    db,
                    sql: "SELECT COUNT(*) FROM purge_intent WHERE table_name = 'block' AND row_id = ? AND deleted_at IS NULL",
                    arguments: [blockID]) ?? 0,
                 try Int.fetchOne(
                    db,
                    sql: "SELECT COUNT(*) FROM purge_intent WHERE table_name = 'block' AND row_id = ? AND deleted_at IS NOT NULL",
                    arguments: [blockID]) ?? 0)
            }
            #expect(intentStates.live == 0, "the local road completed the intent")
            #expect(intentStates.completed == 1)
            let bytesGone: Int = try await editor.database.read { db in
                try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM block WHERE id = ?",
                    arguments: [blockID]) ?? 0
            }
            #expect(bytesGone == 0,
                    "never-synced things really delete, right here (round 11)")
            let listed: [Queries.TrashItem] = try await editor.database.read { db in
                try Queries.trash(db, now: harnessNow)
            }
            #expect(listed.isEmpty, "the row leaves every surface immediately")
            let receipt = try #require(model.receipt)
            #expect(receipt.contains("gone from the app now"))
            #expect(receipt.contains("the app's own cleanup"),
                    "no sync chain ⇒ the receipt never promises devices that don't exist")
            // The synced wording survives as the other arm (unit — the
            // conditional itself).
            #expect(RecoveryPath.deleteNowReceipt(.block, synced: true)
                .contains("every synced device"))
            // Asking again is one purge (idempotent through the op).
            model.requestDeleteNow(row)
            await model.confirmPendingPurge()
            let stillOne: Int = try await editor.database.read { db in
                try Int.fetchOne(
                    db,
                    sql: "SELECT COUNT(*) FROM purge_intent WHERE row_id = ?",
                    arguments: [blockID]) ?? 0
            }
            #expect(stillOne == 1)
        }
    }

    // MARK: - R2-M1 (13j ladder B round 2): the THIRD population's receipt

    @Test func aOnceSyncedFamilysLocalReceiptPromisesTheSignInRoadNotLocalCleanup() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { editor in
            let blockID = try #require(editor.model.slots.first?.blockID)
            // SIGNED OUT, WITH SYNCED HISTORY: no chain is configured
            // (`syncConfigured` reads false in this harness — the exact
            // signed-out read), but the store remembers the server once
            // accepted this block (`sync_row_seq`). `LocalPurge` defers a
            // family with any synced member FOREVER on this road, so the
            // "app's own cleanup removes the bytes" sentence would be
            // indefinitely false for exactly the row the receipt names —
            // the B3 falsehood reborn one population over (the round-2
            // finding). Red on the pre-R2-M1 code: the local wording was
            // unconditional.
            try await editor.session.runner.run { (ops: Operations) in
                try ops.deleteBlock(blockID)
            }
            try await editor.database.write { db in
                try db.execute(
                    sql: """
                        INSERT OR REPLACE INTO sync_row_seq (table_name, row_id, server_seq)
                        VALUES ('block', ?, 7)
                        """,
                    arguments: [blockID])
            }
            let rows: [Queries.TrashItem] = try await editor.database.read { db in
                try Queries.trash(db, now: harnessNow)
            }
            let row = try #require(rows.first { $0.kind == .block && $0.id == blockID })
            let model = RecoveryViewModel(session: editor.session)
            model.requestDeleteNow(row)
            await model.confirmPendingPurge()
            #expect(model.lastError == nil)

            let receipt = try #require(model.receipt)
            #expect(!receipt.contains("the app's own cleanup"),
                    "a once-synced family is never promised a cleanup LocalPurge defers")
            #expect(receipt.contains("sign in"),
                    "the true road: the bytes wait for the janitor, after a sign-in")

            // The wording matches the STORE's truth: the post-confirm
            // local sweep deferred the once-synced family — bytes still
            // here, intent still live for the future janitor to honor.
            let bytes: Int = try await editor.database.read { db in
                try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM block WHERE id = ?",
                    arguments: [blockID]) ?? 0
            }
            #expect(bytes == 1, "LocalPurge waits on a synced member — nothing removed")
            let liveIntent: Int = try await editor.database.read { db in
                try Int.fetchOne(
                    db,
                    sql: "SELECT COUNT(*) FROM purge_intent WHERE row_id = ? AND deleted_at IS NULL",
                    arguments: [blockID]) ?? 0
            }
            #expect(liveIntent == 1, "the intent stands for the sign-in road")

            // Empty Trash's arm of the same truth (unit — the conditional
            // itself), and the never-synced local arm survives unchanged.
            let mixed = RecoveryPath.emptyTrashReceipt(
                2, synced: false, anyFamilyEverSynced: true)
            #expect(mixed.contains("sign in") && !mixed.contains("the app's own cleanup"))
            #expect(RecoveryPath.deleteNowReceipt(.block, synced: false)
                .contains("the app's own cleanup"),
                    "the never-synced population keeps its true local sentence")
        }
    }

    @Test func aPreservedOriginalRowHasNoPurgeDoorOfItsOwn() async throws {
        try await withEditor(seedBlocks: ["Alpha one."]) { editor in
            let model = RecoveryViewModel(session: editor.session)
            let original = Queries.TrashItem(
                kind: .preservedOriginal, id: "origin-1",
                deletedAt: "2026-07-01T00:00:00.000Z", text: "the original")
            model.requestDeleteNow(original)
            #expect(model.pendingConfirm == nil,
                    "an original rides its family (round 8b) — no door, and the belt holds")
        }
    }

    // MARK: - Empty Trash

    @Test func emptyTrashsConfirmNamesTheFullCountByKindAndTheActTakesEverything() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { editor in
            let blockID = try #require(editor.model.slots.first?.blockID)
            let secondBlock = try #require(editor.model.slots.dropFirst().first?.blockID)
            try await editor.session.runner.run { (ops: Operations) in
                try ops.deleteBlock(blockID)
                try ops.deleteBlock(secondBlock)
                let book = try ops.createReading(name: "orbit", kind: .curated)
                try ops.deleteReading(book.id)
                let doomed = try ops.createPost(title: "doomed")
                try ops.deleteContainer(doomed.id)
            }
            let model = RecoveryViewModel(session: editor.session)

            await model.requestEmptyTrash()
            guard case .emptyTrash(let counts)? = model.pendingConfirm else {
                Issue.record("Empty Trash must raise its counting confirm")
                return
            }
            #expect(counts[.block] == 2)
            #expect(counts[.note] == 1)
            #expect(counts[.book] == 1)
            let message = try #require(model.pendingConfirm?.message)
            // The memo's wording shape: the FULL count, by kind.
            #expect(message.contains("4 things go for good"))
            #expect(message.contains("1 note"))
            #expect(message.contains("2 blocks"))
            #expect(message.contains("1 book"))

            await model.confirmPendingPurge()
            #expect(model.lastError == nil)
            // LADDER B (B3), ANNOTATED PIN EDIT (the Delete Now test's
            // reason): this never-synced world purges immediately — one
            // intent per Trash row still minted, now COMPLETED by the
            // local sweep, families physically gone.
            let intents: (live: Int, completed: Int) = try await editor.database.read { db in
                (try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM purge_intent WHERE deleted_at IS NULL") ?? 0,
                 try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM purge_intent WHERE deleted_at IS NOT NULL") ?? 0)
            }
            #expect(intents.live == 0)
            #expect(intents.completed == 4, "everything, always — one intent per Trash row")
            let survivors: Int = try await editor.database.read { db in
                (try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM block WHERE id IN (?, ?)",
                                  arguments: [blockID, secondBlock]) ?? 0)
                + (try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM reading WHERE deleted_at IS NOT NULL") ?? 0)
                + (try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM container WHERE title = 'doomed'") ?? 0)
            }
            #expect(survivors == 0, "the bytes went with the confirm (round 11)")
            let listed: [Queries.TrashItem] = try await editor.database.read { db in
                try Queries.trash(db, now: harnessNow)
            }
            #expect(listed.isEmpty)
            #expect(model.receipt?.contains("4 things gone from the app now") == true)
        }
    }

    @Test func anEmptyTrashSaysSoQuietlyInsteadOfConfirmingNothing() async throws {
        try await withEditor(seedBlocks: ["Alpha one."]) { editor in
            let model = RecoveryViewModel(session: editor.session)
            await model.requestEmptyTrash()
            #expect(model.pendingConfirm == nil,
                    "nothing to delete — no confirm over an empty set")
            #expect(model.receipt == RecoveryPath.emptyTrashConfirm([:]))
        }
    }

    // MARK: - The confirm copy (pure)

    @Test func theEmptyTrashWordsCountByKindAndNameRidingOriginals() {
        let message = RecoveryPath.emptyTrashConfirm([
            .note: 12, .block: 24, .take: 3, .book: 2,
        ])
        #expect(message.contains("41 things go for good"))
        #expect(message.contains("12 notes"))
        #expect(message.contains("24 blocks"))
        #expect(message.contains("3 takes"))
        #expect(message.contains("2 books"))

        let withOriginal = RecoveryPath.emptyTrashConfirm([.note: 1, .preservedOriginal: 1])
        #expect(withOriginal.contains("1 thing goes for good"))
        #expect(withOriginal.contains("1 preserved original rides along"))
        // Originals never count as purge targets of their own.
        #expect(withOriginal.contains("1 thing "), "the total counts the four kinds only")
    }

    // MARK: - The pruning setting's face words (round 9)

    @Test func thePruningWordsCarryHerNumbersAndTheManualImmunity() {
        #expect(HistoryPruningCopy.label(.standard).contains("90 days"))
        #expect(HistoryPruningCopy.label(.never).contains("forever"))
        #expect(HistoryPruningCopy.help.contains("newest 10"))
        #expect(HistoryPruningCopy.help.contains("⌘S are never touched"),
                "the ⌘S immunity is the sentence the setting must never leave out")
        // And the op's refusal words for the belt behind it.
        #expect(OpsRefusalCopy.message(
            for: OperationError.deliberateSavepointNeverPruned(id: "x"))
            .contains("never pruned"))
        #expect(OpsRefusalCopy.message(
            for: OperationError.purgeTargetNotDeleted(table: "block", id: "x"))
            .contains("Trash"))
    }
}
