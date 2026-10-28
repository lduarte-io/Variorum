//
//  TrayBadgeP1Tests.swift
//  VariorumCoreTests
//
//  VX-647 (VX-648 batch 1) — the pins for her report: "when a note has a
//  lot of deleted blocks, making new blocks with newlines and deleting
//  blocks starts to have a several second (like 3-5 seconds at least)
//  delay."
//
//  The traced mechanism (the batch record's "VX-647 TRACE",
//  `notes/plans/fixes/vx-648-launch-week.md`): an open note HOLDS the tray
//  door's badge (`PaneHost.watchTray` → `observeTrayCounts` →
//  `Queries.trayCounts`), and GRDB re-runs a held `tracking { }` fetch
//  synchronously on the WRITER after every commit its region touches — every
//  structural write and every autosave. The badge's `deleted_count` arm runs
//  the cascade-victim fence once per deleted block of the note, and that
//  fence looked up a TOMBSTONED placement by `block_id`, which no index could
//  serve: the plan read `SCAN cb`, a full scan of the library's whole
//  placement table per deleted block — O(the note's deleted blocks × every
//  placement row in the store) on every keystroke's write.
//
//  These are SHAPE pins (query plans and SQLite's own work counter), never
//  timings — the P48 lesson the read-layer pins already follow
//  (`ReadLayerP1Tests`): a stopwatch pin can pass or fail with machine load.
//

import Dependencies
import Foundation
import GRDB
import SQLCipher
import Testing

@testable import VariorumCore

/// Every statement `body` runs, captured as SQLite expanded it.
private func capturedStatements(
    _ db: AppDatabase, _ body: (Database) throws -> Void
) throws -> [String] {
    try db.read { database in
        let captured = LockIsolated<[String]>([])
        let capturing = LockIsolated(true)
        database.trace(options: .statement) { event in
            guard capturing.value, case .statement(let statement) = event else { return }
            let sql = statement.expandedSQL
            captured.withValue { $0.append(sql) }
        }
        try body(database)
        capturing.setValue(false)
        return captured.value.filter {
            let head = $0.trimmingCharacters(in: .whitespacesAndNewlines).prefix(6).uppercased()
            return head.hasPrefix("SELECT") || head.hasPrefix("WITH")
        }
    }
}

/// The joined query plan of every SELECT `body` ran.
private func capturedPlan(
    _ db: AppDatabase, _ body: (Database) throws -> Void
) throws -> String {
    let statements = try capturedStatements(db, body)
    return try db.read { database in
        try statements.flatMap { sql in
            try Row.fetchAll(database, sql: "EXPLAIN QUERY PLAN \(sql)")
                .map { ($0["detail"] as String?) ?? "" }
        }.joined(separator: "\n")
    }
}

/// SQLite's own work counter (`SQLITE_STMTSTATUS_VM_STEP`) summed over every
/// SELECT `body` ran — each statement re-prepared from its expanded SQL and
/// stepped to the end, so the count is the work the read really does.
private func vmSteps(
    _ db: AppDatabase, _ body: (Database) throws -> Void
) throws -> Int {
    let statements = try capturedStatements(db, body)
    return try db.read { database in
        var total = 0
        for sql in statements {
            let statement = try database.makeStatement(sql: sql)
            _ = try Row.fetchAll(statement)
            total += Int(sqlite3_stmt_status(statement.sqliteStatement, SQLITE_STMTSTATUS_VM_STEP, 0))
        }
        return total
    }
}

/// ⏎ at a block's end mints an empty block; ⌫ in it carves it — the road
/// that adds one TOMBSTONED block to the note per round (the Mac's
/// `runEmptyBlockDeletion`, through the same operation and precondition).
private func carve(_ ops: Operations, in noteID: String, after anchorID: String) throws {
    let minted = try ops.seedBlock(in: noteID, text: "", at: .after(anchorID))
    try ops.deleteBlock(
        minted.block.id, requiring: .emptyWithNothingUnshown(variantID: minted.variant.id))
}

/// A note with `deleted` carved blocks inside a library of `libraryNotes` ×
/// `blocksEach` other placements; returns the note's id.
private func fixture(
    _ ops: Operations, deleted: Int, libraryNotes: Int, blocksEach: Int
) throws -> String {
    for n in 0..<libraryNotes {
        let other = try ops.createPost(title: "library \(n)")
        for b in 0..<blocksEach {
            try ops.seedBlock(in: other.id, text: "paragraph \(b) of note \(n).")
        }
    }
    let note = try ops.createPost(title: "the note")
    let anchor = try ops.seedBlock(in: note.id, text: "the one paragraph that stays.")
    for _ in 0..<deleted {
        try carve(ops, in: note.id, after: anchor.block.id)
    }
    return note.id
}

@Suite("VX-647 — the tray badge's cost is the note's, never the library's")
struct TrayBadgeP1Tests {

    /// RED ON OLD: the cascade-victim fence planned as `SCAN cb` — the whole
    /// placement table, once per deleted block of the note — in BOTH the
    /// badge's count and the tray's deleted listing (the same fence).
    @Test func theCascadeVictimFenceSeeksAndNeverScansThePlacementTable() throws {
        try withOperations { ops, db in
            let noteID = try fixture(ops, deleted: 3, libraryNotes: 2, blocksEach: 2)
            for (name, read) in [
                ("trayCounts", { (d: Database) in
                    _ = try Queries.trayCounts(d, postID: noteID, now: harnessNow) }),
                ("trayBlocks", { (d: Database) in
                    _ = try Queries.trayBlocks(d, postID: noteID, now: harnessNow, limit: 501) }),
            ] as [(String, (Database) throws -> Void)] {
                let plan = try capturedPlan(db, read)
                #expect(!plan.contains("SCAN cb") && !plan.contains("SCAN container_block"),
                        "\(name) must never scan the placement table; plan was:\n\(plan)")
            }
        }
    }

    /// RED ON OLD: the badge's work grew with every placement row in the
    /// LIBRARY — fifteen times the other notes' blocks was roughly fifteen
    /// times the work, for the same note with the same deleted history. The
    /// claim: the library is not the driver (P1). The note's own deleted
    /// history (bounded by the 30-day window) may drive it; the corpus may not.
    @Test func theBadgesWorkDoesNotGrowWithTheLibrary() throws {
        func steps(blocksEach: Int) throws -> Int {
            try withOperations { ops, db in
                let noteID = try fixture(ops, deleted: 40, libraryNotes: 20, blocksEach: blocksEach)
                let counts = try db.read { try Queries.trayCounts($0, postID: noteID, now: harnessNow) }
                #expect(counts.deleted == 40, "the fixture's carved blocks are the badge's count")
                return try vmSteps(db) { _ = try Queries.trayCounts($0, postID: noteID, now: harnessNow) }
            }
        }
        let thin = try steps(blocksEach: 2)
        let thick = try steps(blocksEach: 30)
        #expect(Double(thick) < Double(thin) * 1.5,
                "library placements ×15: \(thin) → \(thick) VM steps — the library must not drive the badge (P1)")
    }

    /// The listing's twin of the claim above — the tray's deleted section
    /// carries the same fence (and Blocks mode HOLDS it, `observeTray`).
    @Test func theDeletedListingsWorkDoesNotGrowWithTheLibrary() throws {
        func steps(blocksEach: Int) throws -> Int {
            try withOperations { ops, db in
                let noteID = try fixture(ops, deleted: 40, libraryNotes: 20, blocksEach: blocksEach)
                return try vmSteps(db) {
                    _ = try Queries.trayBlocks($0, postID: noteID, now: harnessNow, limit: 501)
                }
            }
        }
        let thin = try steps(blocksEach: 2)
        let thick = try steps(blocksEach: 30)
        #expect(Double(thick) < Double(thin) * 1.5,
                "library placements ×15: \(thin) → \(thick) VM steps — the library must not drive the listing (P1)")
    }
}
