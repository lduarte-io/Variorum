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

/// **THE CONFIRM→ACT EDGE, DRIVEN THROUGH THE REAL DIALOG** (13l Act 2,
/// ledger item 2 — her live report: *"clicking Delete Now in the Trash
/// produced NO confirmation and NO effect"*).
///
/// Every pin in `TrashPurgeDoorsTests` below calls the confirm method
/// DIRECTLY while `pendingConfirm` is still set, so the one edge that was
/// broken — SwiftUI's `isPresented` write-back racing the action's deferred
/// `Task` — had no coverage at all, and the whole door set stayed green while
/// true delete was unreachable in her hands.
///
/// This suite closes it with **no simulated step**. Three mechanism facts,
/// measured here rather than assumed (and the reason a Mac pin can be
/// stronger than the phone's, whose driver must supply the write-back by
/// hand):
///
/// 1. SwiftUI's `confirmationDialog` on macOS 26 presents a real
///    `_NSAlertPanel` as a sheet on the hosting window — with real
///    `NSButton`s, reachable in process.
/// 2. `performClick(nil)` on that button runs SwiftUI's action closure AND
///    SwiftUI's own dismissal write-back, in one turn — exactly what a real
///    press does. Nothing about the write-back is faked.
/// 3. The action's `Task` resumes only after that turn yields, which is where
///    the defect lived.
///
/// It mounts the SHIPPING modifier (`View.purgeConfirmDialog`) inside a
/// `List` row, which is where `RecoveryView` applies it — measured to behave
/// identically to a bare view, and the closest a test can stand to the real
/// surface, whose `@State` model is unreachable from outside.
@MainActor
@Suite("The purge confirm's real button (13l Act 2)", .serialized)
struct TrashConfirmEdgeTests {
    /// The shipping modifier, over a model the test owns, in production's own
    /// structural position (inside a `List` row).
    private struct Host: View {
        let model: RecoveryViewModel

        var body: some View {
            List {
                Section("Trash") {
                    HStack { Text("controls") }
                        .purgeConfirmDialog(model)
                }
            }
            .frame(width: 480, height: 320)
        }
    }

    private func pump(_ seconds: TimeInterval = 0.3) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    /// Every `NSButton` under a view, however deep.
    private static func buttons(in view: NSView?) -> [NSButton] {
        guard let view else { return [] }
        var found: [NSButton] = []
        if let button = view as? NSButton { found.append(button) }
        for sub in view.subviews { found.append(contentsOf: buttons(in: sub)) }
        return found
    }

    /// Presents the dialog, presses its REAL destructive button, and lets the
    /// action's continuation resume. Returns false when no dialog appeared —
    /// itself a finding, so callers assert on it rather than passing over
    /// nothing.
    @discardableResult
    private func pressTheRealConfirmButton(
        _ model: RecoveryViewModel, raise: () async -> Void
    ) async -> Bool {
        let window = NSWindow(
            contentRect: NSRect(x: 60, y: 60, width: 520, height: 380),
            styleMask: [.titled, .resizable], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        defer {
            window.orderOut(nil)
            window.close()
        }
        window.contentView = NSHostingView(rootView: Host(model: model))
        window.orderFrontRegardless()
        pump(0.4)
        for _ in 0..<20 { await Task.yield() }

        await raise()
        pump(0.4)
        for _ in 0..<20 { await Task.yield() }
        pump(0.2)

        guard let sheet = window.attachedSheet,
              let confirm = Self.buttons(in: sheet.contentView)
                  .first(where: { $0.title == "Delete for Good" })
        else { return false }
        // A REAL press: SwiftUI's action AND SwiftUI's dismissal write-back,
        // in the same turn UIKit/AppKit gives a real click.
        confirm.performClick(nil)
        // The act is a real async transaction (intent write + the local
        // sweep), so the pin waits for its ANSWER rather than for a fixed
        // number of turns — bounded, so the shipped code's silence still
        // fails rather than hangs.
        await settle(until: { model.receipt != nil || model.lastError != nil })
        return true
    }

    /// Pumps the runloop and yields until `done`, or the deadline passes.
    private func settle(until done: () -> Bool, seconds: TimeInterval = 3) async {
        let deadline = Date().addingTimeInterval(seconds)
        while !done(), Date() < deadline {
            pump(0.05)
            for _ in 0..<10 { await Task.yield() }
        }
    }

    @Test func pressingDeleteForGoodInTheRealDialogActuallyPurges() async throws {
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

            let presented = await pressTheRealConfirmButton(model) {
                model.requestDeleteNow(row)
            }
            #expect(presented, "the confirm must present — both purge doors ride this host")

            // RED ON THE SHIPPED CODE: the dismissal nilled `pendingConfirm`
            // before the action's `Task` could read it, so nothing below
            // happened — no intent, no receipt, the row still listed.
            #expect(model.lastError == nil)
            #expect(model.receipt != nil, "a pressed confirm answers her")
            let intents: Int = try await editor.database.read { db in
                try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM purge_intent WHERE row_id = ?",
                    arguments: [blockID]) ?? 0
            }
            #expect(intents == 1, "the press wrote the intent the door promises")
            let listed: [Queries.TrashItem] = try await editor.database.read { db in
                try Queries.trash(db, now: harnessNow)
            }
            #expect(listed.isEmpty, "the row leaves the Trash on the press")
        }
    }

    /// Empty Trash rides the SAME host, which is why one dead edge killed
    /// both doors — so its press is pinned too, not inferred.
    @Test func pressingDeleteForGoodEmptiesTheWholeTrash() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { editor in
            let blockID = try #require(editor.model.slots.first?.blockID)
            try await editor.session.runner.run { (ops: Operations) in
                try ops.deleteBlock(blockID)
                let doomed = try ops.createPost(title: "doomed")
                try ops.deleteContainer(doomed.id)
            }
            let model = RecoveryViewModel(session: editor.session)
            let presented = await pressTheRealConfirmButton(model) {
                await model.requestEmptyTrash()
            }
            #expect(presented, "Empty Trash raises the same host")
            #expect(model.lastError == nil)
            #expect(model.receipt?.contains("Trash is emptied") == true)
            let listed: [Queries.TrashItem] = try await editor.database.read { db in
                try Queries.trash(db, now: harnessNow)
            }
            #expect(listed.isEmpty)
        }
    }

    /// Cancel is the other half of the same edge: the dismissal must leave
    /// nothing pending AND write nothing.
    @Test func pressingCancelInTheRealDialogWritesNothing() async throws {
        try await withEditor(seedBlocks: ["Alpha one."]) { editor in
            let blockID = try #require(editor.model.slots.first?.blockID)
            try await editor.session.runner.run { (ops: Operations) in
                try ops.deleteBlock(blockID)
            }
            let rows: [Queries.TrashItem] = try await editor.database.read { db in
                try Queries.trash(db, now: harnessNow)
            }
            let row = try #require(rows.first { $0.kind == .block })
            let model = RecoveryViewModel(session: editor.session)

            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: 520, height: 380),
                styleMask: [.titled, .resizable], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            window.contentView = NSHostingView(rootView: Host(model: model))
            window.orderFrontRegardless()
            pump(0.4)
            for _ in 0..<20 { await Task.yield() }
            model.requestDeleteNow(row)
            pump(0.4)
            for _ in 0..<20 { await Task.yield() }
            let sheet = try #require(window.attachedSheet)
            let cancel = try #require(Self.buttons(in: sheet.contentView)
                .first { $0.title == "Cancel" })
            cancel.performClick(nil)
            pump(0.3)
            for _ in 0..<40 { await Task.yield() }

            #expect(model.pendingConfirm == nil)
            let intents: Int = try await editor.database.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM purge_intent") ?? 0
            }
            #expect(intents == 0, "a cancelled confirm mints nothing")
            let listed: [Queries.TrashItem] = try await editor.database.read { db in
                try Queries.trash(db, now: harnessNow)
            }
            #expect(listed.count == 1, "the row is still there to put back")
        }
    }
}

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
            await model.confirmPendingPurge(try #require(model.pendingConfirm))
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
            await model.confirmPendingPurge(try #require(model.pendingConfirm))
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
            await model.confirmPendingPurge(try #require(model.pendingConfirm))
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

    /// **STRENGTHENED IN PLACE** (the post-13l polish round, ledger row 21 —
    /// her G6 ruling, which SUPERSEDES 13j round-8's "everything, always").
    /// The claim is now *everything it ROWS*, and the mechanism is stated so
    /// the change reads as a ruling rather than a relaxation: takes no longer
    /// row in the Trash (D1), so the bulk door no longer takes them —
    /// *"I just don't think a 'delete everything' button in the trash should
    /// delete items that aren't being shown."* This world gains a deleted
    /// take on a LIVING block, which is exactly the row her ruling protects,
    /// and asserts it survives the confirm that empties everything else.
    @Test func emptyTrashsConfirmNamesTheFullCountByKindAndTheActTakesEverythingItRows() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two.", "Gamma three."]) { editor in
            let blockID = try #require(editor.model.slots.first?.blockID)
            let secondBlock = try #require(editor.model.slots.dropFirst().first?.blockID)
            // The row her G6 ruling protects: a take deleted on a block that
            // STAYS ALIVE, which the Trash never shows and the door may
            // therefore never take.
            let living = try #require(editor.model.slots.dropFirst(2).first)
            let sparedTake = try await editor.session.runner.run { (ops: Operations) -> String in
                let chosen = try #require(living.variantID)
                let extra = try ops.branchVariant(living.blockID, from: chosen)
                try ops.deleteVariant(extra.id)
                return extra.id
            }
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
            guard case .emptyTrash(let counts, _)? = model.pendingConfirm else {
                Issue.record("Empty Trash must raise its counting confirm")
                return
            }
            #expect(counts[.block] == 2)
            #expect(counts[.note] == 1)
            #expect(counts[.book] == 1)
            // Ledger row 21: the take is COUNTED — the ask-time read sees
            // everything the store holds — so the sentence can be honest
            // about what stays. It is not part of the total.
            #expect(counts[.take] == 1)
            let message = try #require(model.pendingConfirm?.message)
            // The memo's wording shape: the FULL count, by kind.
            #expect(message.contains("4 things go for good"))
            #expect(message.contains("1 note"))
            #expect(message.contains("2 blocks"))
            #expect(message.contains("1 book"))
            #expect(!message.contains("1 take,"), "a take is never among the going")
            #expect(message.contains("stays") && message.contains("not kept"),
                    "her caveat: sparing is not keeping — \(message)")

            await model.confirmPendingPurge(try #require(model.pendingConfirm))
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
            #expect(intents.completed == 4,
                    "one intent per Trash ROW — and the spared take is not one")
            let survivors: Int = try await editor.database.read { db in
                (try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM block WHERE id IN (?, ?)",
                                  arguments: [blockID, secondBlock]) ?? 0)
                + (try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM reading WHERE deleted_at IS NOT NULL") ?? 0)
                + (try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM container WHERE title = 'doomed'") ?? 0)
            }
            #expect(survivors == 0, "the bytes went with the confirm (round 11)")
            // The SURFACE's listing is what empties — asked the way the
            // surface asks it (ledger row 11: the Trash lists notes, books
            // and blocks). The raw query still answers for takes, which is
            // the next assertion's whole point.
            let listed: [Queries.TrashItem] = try await editor.database.read { db in
                try Queries.trash(db, now: harnessNow, kinds: TrashScope.listedKinds)
            }
            #expect(listed.isEmpty)
            #expect(model.receipt?.contains("4 things gone from the app now") == true)

            // …and the row the door does not show is the row it does not take.
            let takeAlive: Int = try await editor.database.read { db in
                try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM variant WHERE id = ?",
                    arguments: [sparedTake]) ?? 0
            }
            #expect(takeAlive == 1, "G6: Empty Trash purges exactly what it rows")
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

    /// **STRENGTHENED IN PLACE** (ledger row 21): the take count no longer
    /// joins the total or the going-list — it becomes the honest caveat. The
    /// mechanism, stated: takes stopped rowing in the Trash at D1, and a door
    /// may not take what it does not show; sparing is not keeping, so the
    /// sentence says the clock keeps running.
    @Test func theEmptyTrashWordsCountByKindAndNameRidingOriginals() {
        let message = RecoveryPath.emptyTrashConfirm([
            .note: 12, .block: 24, .take: 3, .book: 2,
        ])
        #expect(message.contains("38 things go for good"),
                "the total counts what the door TAKES: \(message)")
        #expect(message.contains("12 notes"))
        #expect(message.contains("24 blocks"))
        #expect(message.contains("2 books"))
        #expect(message.contains("3 deleted takes on living blocks stay"))
        #expect(message.contains("not kept"))
        #expect(message.contains("\(TrashWindow.days) days"),
                "her ruling: NOT clock-exempt")
        // One take reads in the singular, and still says the same two facts.
        let one = RecoveryPath.emptyTrashConfirm([.note: 1, .take: 1])
        #expect(one.contains("1 deleted take on living blocks stays"))
        #expect(one.contains("putting it back is what keeps it"))
        // Takes ALONE are nothing this door can act on — it says so quietly
        // rather than confirming a purge of nothing.
        #expect(RecoveryPath.emptyTrashConfirm([.take: 4])
                == "The Trash is empty — nothing to delete.")

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

/// **THE HOIST, PINNED** (13l Act 2, ledger item 4 — the decision layer
/// mobile round 2's batch 4.5b stopped at half, plus the Act-1 review's two
/// routed NITs).
///
/// The claim a hoist has to earn is that it moved an ADDRESS, not a
/// behaviour, and this repo's usual proof is the other platform's suite
/// riding unmodified. That proof is real here (no mobile test file was
/// touched) but it is the weaker half — it shows no COVERED behaviour
/// changed. These pins carry the other half: the rules themselves, asserted
/// where they now live, plus the sentences the review found missing.
@MainActor
@Suite("The shared purge decision layer (13l Act 2, item 4)")
struct TrashPurgeSharedLayerTests {
    /// Both models' `PurgeConfirm` is now literally the same type, which is
    /// the strongest statement of "one decision" available in the language.
    @Test func bothSurfacesConfirmTypeIsTheSharedOne() {
        #expect(RecoveryViewModel.PurgeConfirm.self == TrashPurge.Confirm.self)
        // And the rule the belt rides on, at its one home.
        let original = Queries.TrashItem(
            kind: .preservedOriginal, id: "origin-1",
            deletedAt: "2026-07-01T00:00:00.000Z", text: "the original")
        #expect(TrashPurge.deleteNowConfirm(for: original) == nil,
                "an original rides its family — no door, on either platform")
        let block = Queries.TrashItem(
            kind: .block, id: "b1", deletedAt: "2026-07-01T00:00:00.000Z")
        #expect(TrashPurge.deleteNowConfirm(for: block) == .deleteNow(block))
    }

    /// The +1 probe's rule, which both listings ran as their own copy — a
    /// rule whose bug (forgetting to DROP the probe row) is silent.
    @Test func theWindowDropsItsProbeRowAndSaysSo() {
        let exact = TrashListing.windowed(Array(1...5), window: 5)
        #expect(exact.rows.count == 5)
        #expect(!exact.truncated, "an exact-window read is not truncated")
        let over = TrashListing.windowed(Array(1...6), window: 5)
        #expect(over.rows == Array(1...5), "the probe row never reaches the listing")
        #expect(over.truncated)
        let empty = TrashListing.windowed([Int](), window: 5)
        #expect(empty.rows.isEmpty && !empty.truncated)
    }

    /// **A1-NIT-1** — the "already BACK" family. **RED ON OLD**: every case
    /// here fell to `fallback`, which prints the technical name, on the
    /// ordinary double-click-Put-back race.
    @Test func theAlreadyBackFamilySpeaksInsteadOfNamingItsEnumCase() {
        let cases: [(OperationError, String)] = [
            (.containerNotDeleted(id: "x"), "note is already back"),
            (.readingNotDeleted(id: "x"), "book is already back"),
            (.blockNotDeleted(id: "x"), "block is already back"),
            (.variantNotDeleted(id: "x"), "take is already back"),
        ]
        for (error, expected) in cases {
            let words = DeletionRefusal.words(error, act: .putBack)
            #expect(words.contains(expected))
            #expect(!words.contains("NotDeleted"), "never the enum case's name")
            #expect(!words.contains("couldn't be done"), "never the fallback")
        }
        // The purge side of the same race names the rule it broke.
        let purge = DeletionRefusal.words(
            OperationError.purgeTargetNotDeleted(table: "block", id: "x"), act: .delete)
        #expect(purge.contains(RecoveryCopy.trashSection))
        #expect(!purge.contains("couldn't be done"))
        // The "already gone" family it mirrors is untouched.
        #expect(DeletionRefusal.words(OperationError.containerNotFound(id: "x"))
            .contains("already gone"))
    }

    /// **A1-MINOR-2** — the four raw `String(describing:)` catches. Three
    /// are unreachable without breaking the store, so the pin asserts what
    /// is assertable: the surface's error slot never carries a bare
    /// `String(describing:)` shape, and the ONE reachable arm speaks.
    @Test func theSurfacesErrorSlotNeverCarriesARawDump() async throws {
        try await withEditor(seedBlocks: ["Alpha one."]) { editor in
            let model = RecoveryViewModel(session: editor.session)
            // The reachable arm: a purge refused by the ops layer (a target
            // that is NOT in the Trash — the `requestPurge` guard).
            let live = try #require(editor.model.slots.first?.blockID)
            model.requestDeleteNow(Queries.TrashItem(
                kind: .block, id: live, deletedAt: "2026-07-01T00:00:00.000Z"))
            await model.confirmPendingPurge(try #require(model.pendingConfirm))
            let said = try #require(model.lastError)
            #expect(!said.hasPrefix("purgeTargetNotDeleted"),
                    "a refusal is a sentence, never the enum's description")
            #expect(said.contains(RecoveryPath.trashSection) || said.contains("Trash"))
        }
    }
}
