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
            await model.confirmPendingPurge()
            #expect(model.lastError == nil)
            let intents: Int = try await editor.database.read { db in
                try Int.fetchOne(
                    db,
                    sql: "SELECT COUNT(*) FROM purge_intent WHERE table_name = 'block' AND row_id = ? AND deleted_at IS NULL",
                    arguments: [blockID]) ?? 0
            }
            #expect(intents == 1)
            let listed: [Queries.TrashItem] = try await editor.database.read { db in
                try Queries.trash(db, now: harnessNow)
            }
            #expect(listed.isEmpty, "the row leaves every surface immediately")
            let receipt = try #require(model.receipt)
            #expect(receipt.contains("gone from the app now"))
            #expect(receipt.contains("every synced device"),
                    "the receipt is honest about NOW vs the janitor")
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
            let intents: Int = try await editor.database.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM purge_intent WHERE deleted_at IS NULL") ?? 0
            }
            #expect(intents == 4, "everything, always — one intent per Trash row")
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
