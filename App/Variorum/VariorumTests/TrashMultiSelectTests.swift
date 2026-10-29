//
//  TrashMultiSelectTests.swift
//  VariorumTests
//
//  VX-671 (the VX-678 run, Unit 3) — Trash multi-select, through the shipping
//  model and the shared acts. Her report, verbatim: *"i also should be able
//  to select multiple items to delete."*
//
//  · The pick: `RecoveryViewModel.clickRow` (the Library's `NoteRowSelection`
//    brain — plain click picks one, ⌘ toggles, ⇧ ranges over the rows AS
//    SHOWN), `pruneSelection(toVisible:)`, and the view's pure
//    `RecoveryView.visibleRowIDs` (a folded original is not shown).
//  · Bulk Put back: `TrashBulk.putBack` drives each row's own
//    `TrashPutBack.run` in `TrashBulk.putBackOrder` (PROVISIONAL P-671-1/2);
//    exact rows after, and the one receipt (P-671-3/6).
//  · Bulk Delete Now: `TrashPurge.Confirm.deleteSelection` — asked once with
//    the full count by kind, one `requestPurge` over the taken rows, re-read
//    at act time (P-671-4); exact rows and intents after.
//
//  The store-side facts these stand on are pinned headlessly in
//  `Tests/VariorumCoreTests/TrashBulkTransitionTests` (green there). These
//  are WRITTEN at Unit 3 and run at the orchestrator's stage window (every
//  `xcodebuild test` holds the stage) — PENDING-RUN in the run record.
//

import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func listing(_ editor: EditorHarness) async throws -> [Queries.TrashItem] {
    try await editor.database.read { db in
        try Queries.trash(db, now: harnessNow, kinds: TrashScope.listedKinds)
    }
}

@MainActor
private func live(_ editor: EditorHarness, _ table: String, _ id: String) async throws -> Bool {
    try await editor.database.read { db in
        try Int.fetchOne(
            db, sql: "SELECT COUNT(*) FROM \(table) WHERE id = ? AND deleted_at IS NULL",
            arguments: [id]) == 1
    }
}

@MainActor
private func exists(_ editor: EditorHarness, _ table: String, _ id: String) async throws -> Bool {
    try await editor.database.read { db in
        try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM \(table) WHERE id = ?", arguments: [id]) == 1
    }
}

private func item(_ id: String, _ kind: Queries.TrashItem.Kind, anchor: String? = nil) -> Queries.TrashItem {
    Queries.TrashItem(kind: kind, id: id, deletedAt: "2026-07-01T00:10:00.000Z", anchorBlockID: anchor)
}

@Suite("VX-671 — the Trash picks several rows and acts on them", .serialized)
struct TrashMultiSelectTests {

    // MARK: - The pick

    /// The standard macOS idiom over the rows AS SHOWN: a plain click picks
    /// one row (and is the anchor), ⇧ takes the span from the anchor, ⌘
    /// toggles one; the pick is kept to what the listing shows.
    @Test func aClickPicksCommandTogglesShiftRangesAndThePickFollowsTheListing() async throws {
        try await withEditor { editor in
            let model = RecoveryViewModel(session: editor.session)
            let order = ["a", "b", "c", "d", "e"]
            model.clickRow("b", modifiers: .none, order: order)
            #expect(model.selectedRows == ["b"])
            model.clickRow("d", modifiers: .shift_, order: order)
            #expect(model.selectedRows == ["b", "c", "d"], "the span from the anchor, as shown")
            model.clickRow("c", modifiers: .command_, order: order)
            #expect(model.selectedRows == ["b", "d"], "⌘ takes one out")
            model.clickRow("e", modifiers: .command_, order: order)
            #expect(model.selectedRows == ["b", "d", "e"], "⌘ adds one")
            model.clickRow("a", modifiers: .none, order: order)
            #expect(model.selectedRows == ["a"], "a plain click replaces the pick")

            model.clickRow("c", modifiers: .command_, order: order)
            model.pruneSelection(toVisible: ["a", "b"])
            #expect(model.selectedRows == ["a"], "a row the listing no longer shows leaves the pick")
            model.clickRow("b", modifiers: .shift_, order: ["a", "b"])
            #expect(model.selectedRows == ["a", "b"], "the anchor (c, gone) was dropped — ⇧ picks b alone onto the pick")
            model.clearSelection()
            #expect(model.selectedRows.isEmpty && model.selectionAnchor == nil)
        }
    }

    /// The rows as shown: a note heading its group, its rows, and the
    /// originals nested under their anchor block — unless that run is folded.
    @Test func theRowsAsShownSkipAFoldedRunOfOriginals() {
        let note = Queries.TrashItem(kind: .note, id: "n", deletedAt: "2026-07-01T00:30:00.000Z")
        let block = Queries.TrashItem(
            kind: .block, id: "b", deletedAt: "2026-07-01T00:20:00.000Z", noteID: "n",
            noteIsDeleted: true)
        let original = Queries.TrashItem(
            kind: .preservedOriginal, id: "o", deletedAt: "2026-07-01T00:20:00.000Z",
            noteID: "live-note", anchorBlockID: "b")
        let book = item("k", .book)
        let entries = TrashGrouping.entries([note, block, original, book])
        #expect(RecoveryView.visibleRowIDs(entries, collapsed: []) == ["n", "b", "o", "k"])
        #expect(RecoveryView.visibleRowIDs(entries, collapsed: ["b"]) == ["n", "b", "k"])
    }

    /// P-671-1: books, then notes and snippet groups, then blocks, then
    /// originals — the listing's order within each.
    @Test func theBulkPutBackOrderRanksBooksNotesBlocksOriginals() {
        let picked = [
            item("o1", .preservedOriginal), item("b1", .block), item("n1", .note),
            item("k1", .book), item("g1", .snippetGroup), item("b2", .block), item("n2", .note),
        ]
        #expect(TrashBulk.putBackOrder(picked).map(\.id) == ["k1", "n1", "g1", "n2", "b1", "b2", "o1"])
        #expect(TrashBulk.taken(picked).map(\.id) == ["b1", "n1", "k1", "g1", "b2", "n2"],
                "Delete Now takes every kind but the original, which rides its family")
    }

    // MARK: - Bulk Put back

    /// A book that went in with its notes, those notes' rows, and a note
    /// deleted alone: all picked, one press. The book comes back WHOLE, its
    /// notes' rows were already back, the lone note comes back — and one
    /// receipt says so ("is back with its 2 notes": the contract's "came back
    /// whole").
    @Test func aBulkPutBackBringsABookWholeAndSaysSoOnce() async throws {
        try await withEditor { editor in
            let ids: (book: String, n1: String, n2: String, alone: String) =
                try await editor.session.runner.run { (ops: Operations) in
                    let book = try ops.createReading(name: "the book", kind: .book)
                    let n1 = try ops.createPost(title: "one")
                    let n2 = try ops.createPost(title: "two")
                    _ = try ops.addPostToReading(n1.id, to: book.id)
                    _ = try ops.addPostToReading(n2.id, to: book.id)
                    let alone = try ops.createPost(title: "alone")
                    try ops.deleteContainer(alone.id)
                    _ = try ops.deleteReadingWithNotes(book.id)
                    return (book.id, n1.id, n2.id, alone.id)
                }
            let rows = try await listing(editor)
            let model = RecoveryViewModel(session: editor.session)
            model.adopt(archived: [], trash: rows)
            let order = RecoveryView.visibleRowIDs(TrashGrouping.entries(rows), collapsed: [])
            #expect(Set(order) == [ids.book, ids.n1, ids.n2, ids.alone])
            model.clickRow(order[0], modifiers: .none, order: order)
            model.clickRow(order[order.count - 1], modifiers: .shift_, order: order)
            #expect(model.selectedRows.count == 4)

            await model.putBackSelection(order: order)
            #expect(model.lastError == nil)
            for (table, id) in [("reading", ids.book), ("container", ids.n1),
                                ("container", ids.n2), ("container", ids.alone)] {
                #expect(try await live(editor, table, id), "\(table) \(id) is back")
            }
            let members: Int = try await editor.database.read { db in
                try Int.fetchOne(
                    db,
                    sql: "SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND deleted_at IS NULL AND status = 'member'",
                    arguments: [ids.book]) ?? 0
            }
            #expect(members == 2)
            #expect(try await listing(editor).isEmpty)
            #expect(model.receipt == "3 notes and 1 book put back. \u{201C}the book\u{201D} is back with its 2 notes.")
        }
    }

    /// P-671-2: the block whose deletion stranded an original, and the
    /// original — picked together. The block comes back first; the original
    /// is then off its family's clock and is NOT placed (it would sit beside
    /// its own successor).
    @Test func aBulkPutBackNeverPlacesAnOriginalWhoseFamilyCameBackFirst() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Beta one."]) { editor in
            let blockID = try #require(editor.model.slots.first?.blockID)
            let variant = try #require(try await editor.database.read { db in
                try String.fetchOne(
                    db, sql: "SELECT default_variant_id FROM block WHERE id = ?", arguments: [blockID])
            })
            let ids: (first: String, second: String) = try await editor.session.runner.run { (ops: Operations) in
                let take2 = try ops.branchVariant(blockID, from: variant)
                let w = try ops.divideW(blockID, cuts: [variant: 10, take2.id: 10])
                try ops.deleteBlock(w.first.block.id)
                try ops.deleteBlock(w.second.block.id)
                return (w.first.block.id, w.second.block.id)
            }
            let rows = try await listing(editor)
            #expect(rows.first { $0.id == blockID }?.anchorBlockID == ids.second)
            let model = RecoveryViewModel(session: editor.session)
            model.adopt(archived: [], trash: rows)
            let order = RecoveryView.visibleRowIDs(TrashGrouping.entries(rows), collapsed: [])
            model.clickRow(blockID, modifiers: .command_, order: order)
            model.clickRow(ids.second, modifiers: .command_, order: order)

            await model.putBackSelection(order: order)
            #expect(model.lastError == nil)
            #expect(try await live(editor, "block", ids.second))
            let originalPlaced: Int = try await editor.database.read { db in
                try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM container_block WHERE block_id = ? AND deleted_at IS NULL",
                    arguments: [blockID]) ?? 0
            }
            #expect(originalPlaced == 0, "kept in the tray, never placed beside its successor")
            #expect(try await live(editor, "block", blockID))
            #expect(try await listing(editor).map(\.id) == [ids.first], "the unpicked successor stays")
            #expect(model.receipt == "1 block and 1 preserved original put back.")
        }
    }

    // MARK: - Ladder R1 MINOR-2: gone for good is never "put back"

    /// The one rule over a picked original's fate and its own block row.
    /// Absent from the fates alone is NOT "kept": a purged family's original
    /// is physically gone too, and a missing row reads absent.
    @Test func anOriginalsStandingReadsItsFateAndItsOwnRow() {
        #expect(TrashBulk.standing(fate: .counting("2026-07-01T00:10:00.000Z"), rowExists: true, rowLive: true)
                == .onTheClock)
        #expect(TrashBulk.standing(fate: .gone, rowExists: true, rowLive: true) == .goneForGood,
                "a standing intent or an expired window: gone for good")
        #expect(TrashBulk.standing(fate: nil, rowExists: true, rowLive: true) == .kept,
                "its family lives again (P-671-2)")
        #expect(TrashBulk.standing(fate: nil, rowExists: false, rowLive: false) == .goneForGood,
                "purged with its family — the row itself is gone")
        #expect(TrashBulk.standing(fate: nil, rowExists: true, rowLive: false) == .unknown,
                "tombstoned on its own: its own road answers")
    }

    /// A Put back's stale pick: a deleted note and a stranded original whose
    /// family got a purge intent in the pause (Delete Now from another door).
    /// **RED ON THE PRE-FIX CODE** (traced): the original read "not on the
    /// clock" → `.alreadyBack` → counted, and the receipt said "1 note and 1
    /// preserved original put back." for a row gone forever.
    @Test func aBulkPutBackNeverCountsAnOriginalWhoseFamilyWasPurgedInThePause() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Beta one."]) { editor in
            let original = try #require(editor.model.slots.first?.blockID)
            let variant = try #require(try await editor.database.read { db in
                try String.fetchOne(
                    db, sql: "SELECT default_variant_id FROM block WHERE id = ?", arguments: [original])
            })
            let ids: (s1: String, s2: String, note: String) = try await editor.session.runner.run { (ops: Operations) in
                let take2 = try ops.branchVariant(original, from: variant)
                let w = try ops.divideW(original, cuts: [variant: 10, take2.id: 10])
                try ops.deleteBlock(w.first.block.id)
                try ops.deleteBlock(w.second.block.id)
                let note = try ops.createPost(title: "a note")
                try ops.deleteContainer(note.id)
                return (w.first.block.id, w.second.block.id, note.id)
            }
            let rows = try await listing(editor)
            let model = RecoveryViewModel(session: editor.session)
            model.adopt(archived: [], trash: rows)
            let order = RecoveryView.visibleRowIDs(TrashGrouping.entries(rows), collapsed: [])
            model.clickRow(original, modifiers: .command_, order: order)
            model.clickRow(ids.note, modifiers: .command_, order: order)
            #expect(model.selectedRows == [original, ids.note])

            // The pause: the family's last successor gets a purge intent.
            try await editor.session.runner.run { (ops: Operations) in
                _ = try ops.requestPurge([SyncPurgeTarget(table: "block", rowID: ids.s2)])
            }
            await model.putBackSelection(order: order)
            #expect(model.receipt == nil)
            #expect(model.lastError == "1 note put back. 1 couldn't be: \(RecoveryCopy.bulkOriginalGoneForGood)")
            #expect(try await live(editor, "container", ids.note))
            let placed: Int = try await editor.database.read { db in
                try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM container_block WHERE block_id = ? AND deleted_at IS NULL",
                    arguments: [original]) ?? 0
            }
            #expect(placed == 0, "nothing placed a purged family's original")
        }
    }

    /// The same stale pick, but the local sweep FINISHED in the pause: the
    /// family's bytes are gone and the original with them, so its fate reads
    /// ABSENT — the case "absent means kept" got wrong. **RED ON THE PRE-FIX
    /// CODE** (traced): counted "put back".
    @Test func aBulkPutBackNeverCountsAnOriginalPurgedWithItsFamilyAsPutBack() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Beta one."]) { editor in
            let original = try #require(editor.model.slots.first?.blockID)
            let variant = try #require(try await editor.database.read { db in
                try String.fetchOne(
                    db, sql: "SELECT default_variant_id FROM block WHERE id = ?", arguments: [original])
            })
            let ids: (s1: String, s2: String, note: String) = try await editor.session.runner.run { (ops: Operations) in
                let take2 = try ops.branchVariant(original, from: variant)
                let w = try ops.divideW(original, cuts: [variant: 10, take2.id: 10])
                try ops.deleteBlock(w.first.block.id)
                try ops.deleteBlock(w.second.block.id)
                let note = try ops.createPost(title: "a note")
                try ops.deleteContainer(note.id)
                return (w.first.block.id, w.second.block.id, note.id)
            }
            let rows = try await listing(editor)
            let model = RecoveryViewModel(session: editor.session)
            model.adopt(archived: [], trash: rows)
            let order = RecoveryView.visibleRowIDs(TrashGrouping.entries(rows), collapsed: [])
            model.clickRow(original, modifiers: .command_, order: order)
            model.clickRow(ids.note, modifiers: .command_, order: order)

            try await editor.session.runner.run { (ops: Operations) in
                _ = try ops.requestPurge([
                    SyncPurgeTarget(table: "block", rowID: ids.s1),
                    SyncPurgeTarget(table: "block", rowID: ids.s2),
                ])
            }
            await editor.session.sweepLocalPurge()
            #expect(try await exists(editor, "block", original) == false,
                    "the original went with its family's bytes")

            await model.putBackSelection(order: order)
            #expect(model.receipt == nil)
            #expect(model.lastError == "1 note put back. 1 couldn't be: \(RecoveryCopy.bulkOriginalGoneForGood)")
        }
    }

    // MARK: - Bulk Delete Now

    /// Picked: a note, a block, and a stranded original (whose family is NOT
    /// picked). The door asks once with the full count by kind, naming the
    /// original as riding its family; Cancel mints nothing; the confirmed act
    /// takes exactly the note and the block (this harness has no sync chain,
    /// so the local sweep takes their bytes at once) and leaves the rest.
    @Test func aBulkDeleteNowAsksOnceWithTheFullCountAndTakesExactlyThePick() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Beta one.", "A block to purge."]) { editor in
            let fanned = try #require(editor.model.slots.first?.blockID)
            let purgeBlock = try #require(editor.model.slots.last?.blockID)
            let variant = try #require(try await editor.database.read { db in
                try String.fetchOne(
                    db, sql: "SELECT default_variant_id FROM block WHERE id = ?", arguments: [fanned])
            })
            let ids: (n1: String, n2: String) = try await editor.session.runner.run { (ops: Operations) in
                let n1 = try ops.createPost(title: "picked")
                let n2 = try ops.createPost(title: "unpicked")
                try ops.deleteContainer(n1.id)
                try ops.deleteContainer(n2.id)
                try ops.deleteBlock(purgeBlock)
                let take2 = try ops.branchVariant(fanned, from: variant)
                let w = try ops.divideW(fanned, cuts: [variant: 10, take2.id: 10])
                try ops.deleteBlock(w.first.block.id)
                try ops.deleteBlock(w.second.block.id)
                return (n1.id, n2.id)
            }
            let rows = try await listing(editor)
            let model = RecoveryViewModel(session: editor.session)
            model.adopt(archived: [], trash: rows)
            let order = RecoveryView.visibleRowIDs(TrashGrouping.entries(rows), collapsed: [])
            for id in [ids.n1, purgeBlock, fanned] {
                model.clickRow(id, modifiers: .command_, order: order)
            }

            model.requestDeleteSelection(order: order)
            let picked = model.selectedItems(in: order)
            let taken = picked.filter { $0.kind != .preservedOriginal }
            #expect(model.pendingConfirm == .deleteSelection(taken, versionsLeft: 0, ridingOriginals: 1))
            #expect(model.pendingConfirm?.message == "Delete these 2 for good? 1 note and 1 block skip "
                + "the rest of their 30 days — there's no putting them back. The preserved original you "
                + "picked isn't deleted on its own — it rides its family.")
            model.cancelPendingPurge()
            let afterCancel: Int = try await editor.database.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM purge_intent") ?? 0
            }
            #expect(afterCancel == 0, "Cancel mints nothing")

            model.requestDeleteSelection(order: order)
            await model.confirmPendingPurge(try #require(model.pendingConfirm))
            #expect(model.lastError == nil)
            #expect(try await exists(editor, "container", ids.n1) == false, "the picked note's bytes are gone")
            #expect(try await exists(editor, "block", purgeBlock) == false)
            #expect(try await exists(editor, "container", ids.n2), "the unpicked note stays")
            let left = Set(try await listing(editor).map(\.id))
            #expect(left.contains(ids.n2) && left.contains(fanned),
                    "the unpicked note and the original (its family unpicked) stay in the Trash")
            #expect(!left.contains(ids.n1) && !left.contains(purgeBlock))
            #expect(model.receipt == "1 note and 1 block are gone from the app now — "
                + "the app's own cleanup removes the bytes.")
        }
    }

    /// A door that did nothing speaks a refusal: every picked row came back
    /// in the pause (another hand), so the act takes nothing and writes
    /// nothing.
    @Test func aBulkDeleteNowWhoseRowsAllCameBackInThePauseRefusesAndWritesNothing() async throws {
        try await withEditor { editor in
            let ids: [String] = try await editor.session.runner.run { (ops: Operations) in
                let n1 = try ops.createPost(title: "one")
                let n2 = try ops.createPost(title: "two")
                try ops.deleteContainer(n1.id)
                try ops.deleteContainer(n2.id)
                return [n1.id, n2.id]
            }
            let rows = try await listing(editor)
            let model = RecoveryViewModel(session: editor.session)
            model.adopt(archived: [], trash: rows)
            let order = RecoveryView.visibleRowIDs(TrashGrouping.entries(rows), collapsed: [])
            for id in ids { model.clickRow(id, modifiers: .command_, order: order) }
            model.requestDeleteSelection(order: order)
            let confirm = try #require(model.pendingConfirm)
            try await editor.session.runner.run { (ops: Operations) in
                for id in ids { try ops.restoreContainer(id) }
            }
            await model.confirmPendingPurge(confirm)
            #expect(model.lastError == RecoveryCopy.bulkDeleteNowNothingLeft)
            #expect(model.receipt == nil)
            let intents: Int = try await editor.database.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM purge_intent") ?? 0
            }
            #expect(intents == 0)
        }
    }

    /// The doors' other refusals: nothing picked; only originals picked.
    @Test func aBulkDoorThatCannotActSaysSo() async throws {
        try await withEditor { editor in
            let model = RecoveryViewModel(session: editor.session)
            await model.putBackSelection(order: [])
            #expect(model.lastError == RecoveryCopy.bulkNothingSelected)
            let original = item("o", .preservedOriginal)
            model.adopt(archived: [], trash: [original])
            model.clickRow("o", modifiers: .none, order: ["o"])
            model.requestDeleteSelection(order: ["o"])
            #expect(model.pendingConfirm == nil)
            #expect(model.lastError == RecoveryCopy.bulkDeleteNowNothingTakes)
            #expect(TrashPurge.deleteSelectionConfirm(for: [original], in: [original]) == nil,
                    "the door is not even drawn for a pick it cannot take (P-2)")
        }
    }

    // MARK: - The words

    @Test func theBulkWordsCountHonestlyKindByKind() {
        let notes = [item("n1", .note), item("n2", .note)]
        #expect(RecoveryCopy.bulkPutBackLabel(notes) == "Put back 2 notes")
        #expect(RecoveryCopy.bulkDeleteNowLabel(notes) == "Delete 2 notes now\u{2026}")
        let gathering = Queries.TrashItem(
            kind: .book, id: "g", deletedAt: "2026-07-01T00:10:00.000Z", isGathering: true)
        let mixed = notes + [gathering, item("b1", .block)]
        #expect(RecoveryCopy.bulkPutBackLabel(mixed) == "Put back 4 things")
        #expect(RecoveryCopy.trashSelected(mixed) == "2 notes, 1 gathering and 1 block selected",
                "a gathering is called a gathering (VX-611)")
        #expect(RecoveryCopy.bulkDeleteNowConfirm(mixed, versionsLeft: 1).hasPrefix(
            "Delete these 4 for good? 2 notes, 1 gathering and 1 block skip the rest of their 30 days"))
        #expect(RecoveryCopy.bulkDeleteNowConfirm(mixed, versionsLeft: 1).contains(
            "1 saved version of these notes isn't taken with them"))
        #expect(RecoveryCopy.bulkDeleteNowConfirm([gathering])
                == RecoveryCopy.deleteNowConfirm(.book, isGathering: true),
                "one taken row reads exactly as its own Delete Now confirm")
        #expect(RecoveryCopy.bulkDeleteNowReceipt(mixed, synced: true)
                == "2 notes, 1 gathering and 1 block are gone from the app now — "
                + "the bytes follow once every synced device has caught up.")
        #expect(RecoveryCopy.bulkDeleteNowReceipt([gathering], synced: false)
                == RecoveryCopy.deleteNowReceipt(.book, synced: false, isGathering: true))
    }

    /// P-671-3: everything back → a receipt; some refused → one sentence in
    /// the refusal slot with both facts; nothing back → the refusal.
    @Test func aBulkPutBackSpeaksAReceiptOrARefusalByWhatHappened() {
        struct Refused: Error {}
        let voice: (any Error) -> String = { _ in "This note is marked complete — unseal it to put this back." }
        let note = item("n", .note), block = item("b", .block)
        let all = TrashBulk.putBackWords(
            [(note, .landed(RecoveryCopy.putBackReceipt(.note))), (block, .landed(RecoveryCopy.putBackWhereItWas))],
            voice: voice)
        #expect(all.receipt == "1 note and 1 block put back." && all.refusal == nil)
        let some = TrashBulk.putBackWords(
            [(note, .landed(RecoveryCopy.putBackReceipt(.note))), (block, .refused(Refused()))], voice: voice)
        #expect(some.receipt == nil)
        #expect(some.refusal == "1 note put back. 1 couldn't be: This note is marked complete — unseal it to put this back.")
        let none = TrashBulk.putBackWords([(note, .refused(Refused()))], voice: voice)
        #expect(none.refusal == "This note is marked complete — unseal it to put this back.")
        let gone = TrashBulk.putBackWords([(note, .alreadyBack)], voice: voice)
        #expect(gone.refusal == RecoveryCopy.bulkPutBackAllAlreadyBack, "a press that did nothing says so")
        let landedNews = TrashBulk.putBackWords(
            [(block, .landed(RecoveryCopy.putBackUnplaced(.post)))], voice: voice)
        #expect(landedNews.receipt == "1 block put back. \(RecoveryCopy.putBackUnplaced(.post))",
                "a row's own news rides along")
    }
}
