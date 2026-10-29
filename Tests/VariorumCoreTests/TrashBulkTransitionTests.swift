//
//  TrashBulkTransitionTests.swift
//  VariorumCoreTests
//
//  VX-671 (the VX-678 run, Unit 3) — the STORE SIDE of the Trash's bulk acts,
//  exact rows after every step. Her report: *"i also should be able to select
//  multiple items to delete."*
//
//  The bulk acts add no operation: they drive the EXISTING per-row roads in a
//  decided order (`TrashBulk`, app-side Shared — `RecoveryActs.swift`).
//  · Bulk Put back runs each picked row's own Put back — `restoreReading`,
//    `restoreContainer`, `restoreBlock`, the original's `placeBlock` — in
//    `TrashBulk.putBackOrder`: books, notes and snippet groups, blocks,
//    preserved originals (PROVISIONAL P-671-1); a row that left the Trash
//    before its turn is "already back" (its op refuses `…NotDeleted` and
//    changes nothing; an original no longer on its family's clock is not
//    placed — P-671-2).
//  · Bulk Delete Now is Empty Trash's road restricted to the pick: ONE
//    `requestPurge` over the taken rows (originals ride their families),
//    re-read at act time (P-671-4).
//
//  These pins drive exactly those op sequences headlessly and assert the rows
//  (live, dead, placed, intents) — the facts the app-side order and skip rules
//  stand on, each with its contrast where the ORDER is the point. The app-side
//  executor's own pins are `App/Variorum/VariorumTests/TrashMultiSelectTests`
//  (written, run at the orchestrator's stage window).
//

import Foundation
import GRDB
import Testing

@testable import VariorumCore

private func liveIDs(_ db: AppDatabase, _ table: String, _ ids: [String]) throws -> Set<String> {
    try db.read { database in
        Set(try String.fetchAll(
            database,
            sql: "SELECT id FROM \(table) WHERE deleted_at IS NULL AND id IN (\(Queries.databaseQuestionMarks(count: ids.count)))",
            arguments: StatementArguments(ids)))
    }
}

private func existing(_ db: AppDatabase, _ table: String, _ ids: [String]) throws -> Set<String> {
    try db.read { database in
        Set(try String.fetchAll(
            database,
            sql: "SELECT id FROM \(table) WHERE id IN (\(Queries.databaseQuestionMarks(count: ids.count)))",
            arguments: StatementArguments(ids)))
    }
}

private func trashIDs(_ db: AppDatabase) throws -> Set<String> {
    try db.read { Set(try Queries.trash($0, now: harnessNow).map(\.id)) }
}

private func rendered(_ db: AppDatabase, _ noteID: String) throws -> [String] {
    try db.read { try Queries.renderPost($0, containerID: noteID).map(\.blockID) }
}

private func isPlaced(_ db: AppDatabase, _ blockID: String) throws -> Bool {
    try db.fetchInt(
        "SELECT COUNT(*) FROM container_block WHERE block_id = ? AND deleted_at IS NULL", [blockID]) == 1
}

/// Every intent's (table, row, live?) — the whole table, sorted.
private func intents(_ db: AppDatabase) throws -> [String] {
    try db.read { database in
        try Row.fetchAll(database, sql: "SELECT table_name, row_id, deleted_at FROM purge_intent")
            .map { "\($0["table_name"] as String):\($0["row_id"] as String):\(($0["deleted_at"] as String?) == nil ? "live" : "done")" }
            .sorted()
    }
}

@Suite("VX-671 — the Trash's bulk acts, row by row at the store")
struct TrashBulkTransitionTests {

    // MARK: - Bulk Put back

    /// Picked: a book that went to the Trash WITH its two notes, those two
    /// notes' own rows, and a note deleted alone. Book first: it comes back
    /// WHOLE — its notes and their memberships on its stamp — so the notes'
    /// rows find themselves already back (their op refuses and changes
    /// nothing), and the lone note comes back on its own road.
    @Test func aBookPickedWithItsNotesComesBackWholeAndTheirRowsAreAlreadyBack() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "the book", kind: .book)
            let n1 = try ops.createPost(title: "one")
            let n2 = try ops.createPost(title: "two")
            _ = try ops.addPostToReading(n1.id, to: book.id)
            _ = try ops.addPostToReading(n2.id, to: book.id)
            let alone = try ops.createPost(title: "alone")
            try ops.deleteContainer(alone.id)
            let taken = try ops.deleteReadingWithNotes(book.id)
            #expect(Set(taken) == [n1.id, n2.id])
            #expect(try trashIDs(db) == [book.id, n1.id, n2.id, alone.id], "four rows to pick")

            // The bulk order: the book, then the notes (listing order).
            try ops.restoreReading(book.id)
            #expect(try liveIDs(db, "container", [n1.id, n2.id]) == [n1.id, n2.id],
                    "the book came back whole — its notes with it")
            let before = try db.snapshotRow("container", n1.id, excluding: [])
            #expect(throws: OperationError.containerNotDeleted(id: n1.id)) {
                try ops.restoreContainer(n1.id)
            }
            #expect(try db.snapshotRow("container", n1.id, excluding: []) == before,
                    "an already-back row's turn changes nothing")
            #expect(throws: OperationError.containerNotDeleted(id: n2.id)) {
                try ops.restoreContainer(n2.id)
            }
            try ops.restoreContainer(alone.id)

            #expect(try liveIDs(db, "reading", [book.id]) == [book.id])
            #expect(try liveIDs(db, "container", [n1.id, n2.id, alone.id]) == [n1.id, n2.id, alone.id])
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND deleted_at IS NULL AND status = 'member'",
                [book.id]) == 2, "both memberships back, as members")
            #expect(try trashIDs(db).isEmpty, "everything picked is back")
        }
    }

    /// Picked: a note and a block deleted from it EARLIER (its own stamp).
    /// Note first: the note's road returns its stamp's blocks, then the
    /// block's road lands it in its own place — the order the note had.
    /// CONTRAST (why the order): the block first finds its note gone and is
    /// set aside, and the note's road then does not return it.
    @Test func aNoteBeforeItsEarlierDeletedBlockLandsTheBlockWhereItWas() throws {
        func world(_ ops: Operations) throws -> (note: String, b1: String, b2: String, b3: String) {
            let note = try ops.createPost(title: "the note")
            let b1 = try ops.seedBlock(in: note.id, text: "First.").block.id
            let b2 = try ops.seedBlock(in: note.id, text: "Second.").block.id
            let b3 = try ops.seedBlock(in: note.id, text: "Third.").block.id
            try ops.deleteBlock(b2)
            try ops.deleteContainer(note.id)
            return (note.id, b1, b2, b3)
        }
        try withOperations { ops, db in
            let w = try world(ops)
            #expect(try trashIDs(db) == [w.note, w.b2])
            try ops.restoreContainer(w.note)
            #expect(try liveIDs(db, "block", [w.b1, w.b2, w.b3]) == [w.b1, w.b3],
                    "the note's road returns its own stamp's blocks only")
            #expect(try ops.restoreBlock(w.b2) == .itsOldPlace(home: .post))
            #expect(try rendered(db, w.note) == [w.b1, w.b2, w.b3], "back where it was")
            #expect(try trashIDs(db).isEmpty)
        }
        try withOperations { ops, db in
            let w = try world(ops)
            let landing = try ops.restoreBlock(w.b2)
            #expect(landing != .itsOldPlace(home: .post), "CONTRAST: its note is gone — \(landing)")
            try ops.restoreContainer(w.note)
            #expect(try rendered(db, w.note) == [w.b1, w.b3],
                    "CONTRAST: the block came back first and is not in its note")
            #expect(try isPlaced(db, w.b2) == false)
        }
    }

    /// Picked: the block whose deletion stranded an original, and that
    /// original (nested under it). Block first: the family lives again, so
    /// the original is OFF the clock — no Trash row, kept in its note's tray
    /// as a preserved original — and its turn places nothing. CONTRAST (why
    /// the skip): placing it anyway puts the original beside its own
    /// successor — the same words in the note twice.
    @Test func aBlockBeforeTheOriginalItsDeletionStrandedLeavesTheOriginalOffTheClockUnplaced() throws {
        func world(_ ops: Operations) throws -> (note: String, original: String, s1: String, s2: String) {
            let note = try ops.createPost(title: "the note")
            let fanned = try ops.seedBlock(in: note.id, text: "Alpha one. Beta one.")
            let take2 = try ops.branchVariant(fanned.block.id, from: fanned.variant.id)
            let w = try ops.divideW(fanned.block.id, cuts: [fanned.variant.id: 10, take2.id: 10])
            try ops.deleteBlock(w.first.block.id)
            try ops.deleteBlock(w.second.block.id)
            return (note.id, fanned.block.id, w.first.block.id, w.second.block.id)
        }
        try withOperations { ops, db in
            let w = try world(ops)
            let listed = try db.read { try Queries.trash($0, now: harnessNow) }
            #expect(listed.first { $0.id == w.original }?.anchorBlockID == w.s2,
                    "the original rides the second successor's clock")
            #expect(try db.read { try Queries.originFamilyClocks($0, postID: w.note, now: harnessNow) }[w.original]
                    != nil, "on the clock before the press")

            // The bulk order: the block, then the original.
            #expect(try ops.restoreBlock(w.s2) == .itsOldPlace(home: .post))
            let fates = try db.read { try Queries.originFamilyClocks($0, postID: w.note, now: harnessNow) }
            #expect(fates[w.original] == nil, "its family lives again — off the clock: the turn is skipped")
            #expect(try db.read { try Queries.strandedOriginals($0, now: harnessNow) }.isEmpty)

            #expect(try liveIDs(db, "block", [w.original, w.s1, w.s2]) == [w.original, w.s2])
            #expect(try isPlaced(db, w.original) == false, "kept in the tray, never placed")
            #expect(try rendered(db, w.note) == [w.s2])
            #expect(try trashIDs(db) == [w.s1], "the unpicked successor stays in the Trash")
        }
        try withOperations { ops, db in
            let w = try world(ops)
            _ = try ops.restoreBlock(w.s2)
            _ = try ops.placeBlock(w.original, in: w.note, at: .end)
            #expect(try Set(rendered(db, w.note)) == [w.s2, w.original],
                    "CONTRAST: placed anyway, the original sits beside its own successor")
        }
    }

    /// Ladder R1 MINOR-2 — the store facts a picked original's standing reads
    /// (`TrashBulk.standing`, app-side): a purge intent on its family turns
    /// its fate `.gone`; once the local sweep takes the family, the original
    /// is physically gone with it and its fate reads ABSENT — so "absent"
    /// alone can never mean "kept", the row's existence decides.
    @Test func anOriginalWhoseFamilyIsPurgedReadsGoneThenLeavesWithItsFamily() async throws {
        try await withOperationsAsync { ops, db in
            let note = try ops.createPost(title: "the note")
            let fanned = try ops.seedBlock(in: note.id, text: "Alpha one. Beta one.")
            let take2 = try ops.branchVariant(fanned.block.id, from: fanned.variant.id)
            let w = try ops.divideW(fanned.block.id, cuts: [fanned.variant.id: 10, take2.id: 10])
            try ops.deleteBlock(w.first.block.id)
            try ops.deleteBlock(w.second.block.id)
            let original = fanned.block.id
            func fate() throws -> Queries.OriginFamilyFate? {
                try db.read { try Queries.originFamilyClocks($0, postID: note.id, now: harnessNow) }[original]
            }
            guard case .counting? = try fate() else {
                Issue.record("on the clock before the purge")
                return
            }
            _ = try ops.requestPurge([SyncPurgeTarget(table: "block", rowID: w.second.block.id)])
            #expect(try fate() == .gone, "a standing intent on one member: gone for good")
            #expect(try existing(db, "block", [original]) == [original], "…its row still here")

            _ = try ops.requestPurge([SyncPurgeTarget(table: "block", rowID: w.first.block.id)])
            let report = try await LocalPurge(database: db).sweep()
            #expect(report.familiesPurged >= 1)
            #expect(try existing(db, "block", [original, w.first.block.id, w.second.block.id]).isEmpty,
                    "the original went with its family's bytes")
            #expect(try fate() == nil, "ABSENT — the same reading a living family gives")
        }
    }

    // MARK: - Bulk Delete Now

    /// Picked: a note, a block, a book and a stranded original; left alone:
    /// another note and the original's family. The act is ONE `requestPurge`
    /// over the taken rows — the original rides its family and is no target.
    /// Exactly three intents; the picked rows leave the Trash at once, the
    /// rest stay; the local sweep then takes exactly those families' bytes.
    @Test func aPicksDeleteNowIsOneIntentPerTakenRowAndTheRestStays() async throws {
        try await withOperationsAsync { ops, db in
            let n1 = try ops.createPost(title: "picked note")
            _ = try ops.seedBlock(in: n1.id, text: "Its words.")
            let n2 = try ops.createPost(title: "unpicked note")
            try ops.deleteContainer(n1.id)
            try ops.deleteContainer(n2.id)
            let home = try ops.createPost(title: "home")
            let block = try ops.seedBlock(in: home.id, text: "A block to purge.").block.id
            try ops.deleteBlock(block)
            let book = try ops.createReading(name: "a book", kind: .book)
            try ops.deleteReading(book.id)
            let fanned = try ops.seedBlock(in: home.id, text: "Alpha one. Beta one.")
            let take2 = try ops.branchVariant(fanned.block.id, from: fanned.variant.id)
            let w = try ops.divideW(fanned.block.id, cuts: [fanned.variant.id: 10, take2.id: 10])
            try ops.deleteBlock(w.first.block.id)
            try ops.deleteBlock(w.second.block.id)
            let everything: Set<String> = [
                n1.id, n2.id, block, book.id, fanned.block.id, w.first.block.id, w.second.block.id,
            ]
            #expect(try trashIDs(db) == everything)

            // Picked {n1, block, book, the original}: the taken rows.
            let minted = try ops.requestPurge([
                SyncPurgeTarget(table: "container", rowID: n1.id),
                SyncPurgeTarget(table: "block", rowID: block),
                SyncPurgeTarget(table: "reading", rowID: book.id),
            ])
            #expect(minted == 3)
            #expect(try intents(db) == [
                "block:\(block):live", "container:\(n1.id):live", "reading:\(book.id):live",
            ].sorted(), "one intent per taken row — none for the original, none for the unpicked")
            #expect(try trashIDs(db) == everything.subtracting([n1.id, block, book.id]),
                    "the taken rows leave the Trash at once; the original stays with its family")

            let report = try await LocalPurge(database: db).sweep()
            #expect(report.familiesPurged == 3)
            #expect(try existing(db, "container", [n1.id, n2.id]) == [n2.id], "the picked note's bytes are gone")
            #expect(try existing(db, "block", [block, fanned.block.id]) == [fanned.block.id])
            #expect(try existing(db, "reading", [book.id]).isEmpty)
            #expect(try intents(db) == [
                "block:\(block):done", "container:\(n1.id):done", "reading:\(book.id):done",
            ].sorted())
            #expect(try trashIDs(db) == everything.subtracting([n1.id, block, book.id]))
        }
    }

    /// A picked row put back in the PAUSE (between the confirm and the act):
    /// `requestPurge` refuses a whole batch on one row that is no longer
    /// deleted and mints nothing — which is why the act re-reads the Trash
    /// and takes only the picked rows still in it.
    @Test func aRowPutBackInThePauseIsNotTakenAndOneUndeletedTargetRefusesTheWholeBatch() throws {
        try withOperations { ops, db in
            let n1 = try ops.createPost(title: "one")
            let n2 = try ops.createPost(title: "two")
            try ops.deleteContainer(n1.id)
            try ops.deleteContainer(n2.id)
            let picked = [n1.id, n2.id]
            try ops.restoreContainer(n1.id)  // another hand, in the pause

            #expect(throws: OperationError.purgeTargetNotDeleted(table: "container", id: n1.id)) {
                try ops.requestPurge(picked.map { SyncPurgeTarget(table: "container", rowID: $0) })
            }
            #expect(try intents(db).isEmpty, "all or none: nothing minted")

            let stillThere = try trashIDs(db)
            let taken = picked.filter(stillThere.contains)
            #expect(taken == [n2.id])
            #expect(try ops.requestPurge(taken.map { SyncPurgeTarget(table: "container", rowID: $0) }) == 1)
            #expect(try intents(db) == ["container:\(n2.id):live"])
            #expect(try liveIDs(db, "container", [n1.id]) == [n1.id], "the put-back note is untouched")
        }
    }
}
