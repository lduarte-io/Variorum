//
//  TrashEmptyBlockSweepTests.swift
//  VariorumTests
//
//  VX-800 (the VX-828 run, batch D) — the Trash's empty-block sweep DOOR,
//  through the shipping model and the shared acts. Her ask, verbatim:
//  *"delete all empty blocks with no history from trash."* The fork's ruling
//  (`notes/plans/fixes/vx-828-editor-shell-qol.md`, "Batch D — THE FORK'S
//  RULING") is what these stand on:
//  · the door is a registry-declared `.surface` act the Trash alone renders,
//    drawn only while it would take something (P-2), its label the count;
//  · it asks every time with the count and R-828-1's six facts; Cancel
//    writes nothing; the act takes the confirm's ids ∩ what still qualifies
//    (`Operations.sweepEmptyTrashBlocks`), the local sweep runs before the
//    receipt, and the receipt counts what really went;
//  · the swept rows leave the pick at once (the belt); a press whose blocks
//    all came back in the pause refuses and writes nothing.
//
//  The predicate's rows and the op's transitions are pinned headlessly in
//  `Tests/VariorumCoreTests/EmptyBlockSweepTests` (green there). These are
//  WRITTEN and compiled by batch D and run at the orchestrator's stage window.
//

import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func sweepable(_ editor: EditorHarness) async throws -> [String] {
    try await editor.database.read { db in
        try Queries.emptyTrashBlocks(db, now: harnessNow, wingID: "")
    }
}

@MainActor
private func count(_ editor: EditorHarness, _ sql: String, _ arguments: [String] = []) async throws -> Int {
    try await editor.database.read { db in
        try Int.fetchOne(db, sql: sql, arguments: StatementArguments(arguments)) ?? -1
    }
}

/// Pumps until `done`, or the bound passes — waiting for an EVENT (a held
/// observation's delivery), never bounding a time it should take.
@MainActor
private func settle(until done: () -> Bool, seconds: TimeInterval = 10) async {
    let deadline = Date().addingTimeInterval(seconds)
    while !done(), Date() < deadline {
        try? await Task.sleep(for: .milliseconds(20))
    }
}

@Suite("VX-800 — the Trash's empty-block sweep door", .serialized)
struct TrashEmptyBlockSweepTests {

    // MARK: - The declaration

    /// Declared once, a `.surface` act, and the Trash its renderer — so the
    /// surface walk keeps it Trash-only by construction.
    @Test func theSweepIsATrashSurfaceActDeclaredOnce() {
        let capability = CapabilityRegistry.capability(.deleteEmptyBlocks)
        #expect(capability.verb == "Delete Empty Blocks")
        #expect(capability.doors == [.surface])
        #expect(capability.scope == .app)
        #expect(RecoveryView.surfaceCapabilities.contains(.deleteEmptyBlocks))
    }

    // MARK: - The door

    /// P-2: no door while it would take nothing; with blocks to take, its
    /// label is the count it takes.
    @Test func theDoorDrawsOnlyWhileItWouldTakeSomethingAndSaysTheCount() async throws {
        try await withEditor { editor in
            let model = RecoveryViewModel(session: editor.session)
            #expect(!RecoveryView.showsDeleteEmptyBlocksDoor(model))
            model.adoptEmptyBlocks(["a", "b", "c"])
            #expect(RecoveryView.showsDeleteEmptyBlocksDoor(model))
            #expect(RecoveryCopy.deleteEmptyBlocksLabel(model.emptyBlockIDs.count)
                == "Delete 3 empty blocks\u{2026}")
            #expect(RecoveryCopy.deleteEmptyBlocksLabel(1) == "Delete 1 empty block\u{2026}")
            model.adoptEmptyBlocks([])
            #expect(!RecoveryView.showsDeleteEmptyBlocksDoor(model))
        }
    }

    /// The count is LIVE: the model's held observation follows the store —
    /// an empty block deleted, then one put back.
    @Test func theCountFollowsTheTrash() async throws {
        try await withEditor(seedBlocks: ["", "", "words"]) { editor in
            let ids = editor.model.slots.map(\.blockID)
            let model = RecoveryViewModel(session: editor.session)
            let task = Task { await model.startEmptyBlocks() }
            defer { task.cancel() }
            try await editor.session.runner.run { (ops: Operations) in
                for id in ids { try ops.deleteBlock(id) }
            }
            await settle(until: { model.emptyBlockIDs.count == 2 })
            #expect(Set(model.emptyBlockIDs) == Set(ids.prefix(2)), "the two empty blocks, not the worded one")
            _ = try await editor.session.runner.run { (ops: Operations) in
                try ops.restoreBlock(ids[0])
            }
            await settle(until: { model.emptyBlockIDs.count == 1 })
            #expect(model.emptyBlockIDs == [ids[1]], "a block put back leaves the count")
        }
    }

    // MARK: - The confirm and the act

    /// Asked with the count and the six facts; Cancel writes nothing; the
    /// confirmed act takes exactly the counted blocks (this harness has no
    /// sync chain, so the local sweep takes their bytes before the receipt),
    /// leaves a worded block and a commented one, and the receipt counts what
    /// went.
    @Test func theDoorAsksWithTheCountAndTheActTakesExactlyThose() async throws {
        try await withEditor(seedBlocks: ["", "", "words", ""]) { editor in
            let ids = editor.model.slots.map(\.blockID)
            let (junkA, junkB, worded, commented) = (ids[0], ids[1], ids[2], ids[3])
            try await editor.session.runner.run { (ops: Operations) in
                _ = try ops.addBlockComment(to: commented, text: "a thought")
                for id in ids { try ops.deleteBlock(id) }
            }
            let counted = try await sweepable(editor)
            #expect(Set(counted) == [junkA, junkB])
            let model = RecoveryViewModel(session: editor.session)
            model.adoptEmptyBlocks(counted)

            model.requestDeleteEmptyBlocks()
            #expect(model.pendingConfirm == .deleteEmptyBlocks(counted))
            #expect(model.pendingConfirm?.message == "Delete these 2 empty blocks for good? None "
                + "holds any words, savepoints, comments, a name, a callout or a link to a living "
                + "block. They skip the rest of their 30 days — there's no putting them back.")
            model.cancelPendingPurge()
            #expect(try await count(editor, "SELECT COUNT(*) FROM purge_intent") == 0, "Cancel writes nothing")

            model.requestDeleteEmptyBlocks()
            await model.confirmPendingPurge(try #require(model.pendingConfirm))
            #expect(model.lastError == nil)
            #expect(model.receipt == "2 empty blocks are gone from the app now — "
                + "the app's own cleanup removes the bytes.")
            #expect(try await count(
                editor, "SELECT COUNT(*) FROM block WHERE id IN (?, ?)", [junkA, junkB]) == 0,
                    "the bytes went before the receipt (no sync chain)")
            #expect(try await count(
                editor, "SELECT COUNT(*) FROM block WHERE id IN (?, ?)", [worded, commented]) == 2)
            let left = try await editor.database.read { db in
                Set(try Queries.trash(db, now: harnessNow, kinds: TrashScope.listedKinds).map(\.id))
            }
            #expect(left == [worded, commented], "the worded and the commented block stay in the Trash")
        }
    }

    /// The pick belt: a swept row leaves the pick the moment the act answers;
    /// a picked row the sweep did not take stays picked.
    @Test func theSweptRowsLeaveThePickAtOnce() async throws {
        try await withEditor(seedBlocks: ["", "words"]) { editor in
            let ids = editor.model.slots.map(\.blockID)
            try await editor.session.runner.run { (ops: Operations) in
                for id in ids { try ops.deleteBlock(id) }
            }
            let rows = try await editor.database.read { db in
                try Queries.trash(db, now: harnessNow, kinds: TrashScope.listedKinds)
            }
            let model = RecoveryViewModel(session: editor.session)
            model.adopt(archived: [], trash: rows)
            let order = RecoveryView.visibleRowIDs(TrashGrouping.entries(rows), collapsed: [])
            model.clickRow(ids[1], modifiers: .none, order: order)
            model.clickRow(ids[0], modifiers: .command_, order: order)  // ⌘ makes it the anchor
            #expect(model.selectedRows == Set(ids))
            model.adoptEmptyBlocks(try await sweepable(editor))

            model.requestDeleteEmptyBlocks()
            await model.confirmPendingPurge(try #require(model.pendingConfirm))
            #expect(model.receipt != nil)
            #expect(model.selectedRows == [ids[1]], "the swept block left the pick; the worded one stays")
            #expect(model.selectionAnchor == nil, "the anchor was the swept block")
        }
    }

    /// A door that did nothing speaks a refusal: every counted block came
    /// back in the pause, so the act takes nothing and writes nothing. And a
    /// press at zero (the race the hidden door answers) refuses the same way.
    @Test func aSweepWhoseBlocksAllCameBackRefusesAndWritesNothing() async throws {
        try await withEditor(seedBlocks: ["", ""]) { editor in
            let ids = editor.model.slots.map(\.blockID)
            try await editor.session.runner.run { (ops: Operations) in
                for id in ids { try ops.deleteBlock(id) }
            }
            let model = RecoveryViewModel(session: editor.session)
            model.adoptEmptyBlocks(try await sweepable(editor))
            model.requestDeleteEmptyBlocks()
            let confirm = try #require(model.pendingConfirm)
            try await editor.session.runner.run { (ops: Operations) in
                for id in ids { _ = try ops.restoreBlock(id) }
            }
            await model.confirmPendingPurge(confirm)
            #expect(model.lastError == RecoveryCopy.deleteEmptyBlocksNothingLeft)
            #expect(model.lastError == "None of those empty blocks are in the Trash any more — nothing was deleted.")
            #expect(model.receipt == nil)
            #expect(try await count(editor, "SELECT COUNT(*) FROM purge_intent") == 0)

            model.adoptEmptyBlocks([])
            model.requestDeleteEmptyBlocks()
            #expect(model.pendingConfirm == nil, "no confirm for nothing")
            #expect(model.lastError == RecoveryCopy.deleteEmptyBlocksNothingLeft)
        }
    }

    // MARK: - The words (PROVISIONAL P-828-10 — hers to tune)

    @Test func theWordsAreTheDraftsVerbatim() {
        #expect(RecoveryCopy.deleteEmptyBlocksConfirm(1) == "Delete this empty block for good? It "
            + "holds no words, savepoints, comments, name, callout or link to a living block. It "
            + "skips the rest of its 30 days — there's no putting it back.")
        #expect(RecoveryCopy.deleteEmptyBlocksReceipt(1, synced: false)
            == "The empty block is gone from the app now — the app's own cleanup removes the bytes.")
        #expect(RecoveryCopy.deleteEmptyBlocksReceipt(1, synced: true)
            == "The empty block is gone from the app now — the bytes follow once every synced device has caught up.")
        #expect(RecoveryCopy.deleteEmptyBlocksReceipt(1, synced: false, anyFamilyEverSynced: true)
            == "The empty block is gone from the app now — it once synced, so the bytes finish clearing after you next sign in.")
        #expect(RecoveryCopy.deleteEmptyBlocksReceipt(4, synced: true)
            == "4 empty blocks are gone from the app now — the bytes follow once every synced device has caught up.")
        #expect(RecoveryCopy.deleteEmptyBlocksReceipt(4, synced: false, anyFamilyEverSynced: true)
            == "4 empty blocks are gone from the app now — anything that once synced finishes "
            + "clearing after you next sign in; the rest the app cleans up now.")
        #expect(TrashPurge.Confirm.deleteEmptyBlocks(["a"]).title == "Delete Empty Blocks")
        #expect(TrashPurge.Confirm.deleteEmptyBlocks(["a"]).confirmVerb == RecoveryCopy.deleteNowVerb)
    }
}
