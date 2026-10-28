//
//  TrashLineageP1Tests.swift
//  VariorumCoreTests
//
//  VX-670 (the VX-678 run, Unit 3 — ruling A-678-1): the two lineage reads
//  that open the Trash and the tray, over a note's SEAM history (⏎
//  mid-paragraph divides, ⌫ at the seam merges; every round releases two
//  live-unplaced originals with lineage edges).
//
//  · `Queries.strandedOriginals` — the Trash listing's stranded-originals arm
//    (`Queries.trash` runs it whenever `.preservedOriginal` is listed; the
//    open Trash HOLDS two such observations, `startTrash` and
//    `startTrashTotal`). Unit 2's probe: 24.0 s at 600 seam rounds.
//  · `Queries.originFamilyClocks` — the tray panel's held fates read
//    (`TrayPanel.start()`). 14.6 s at 600 rounds.
//
//  Both carried the `fam(origin, descendant)` PAIR SET VX-654 removed from
//  `originalsStrandedBy` — O(L²) in lineage depth. The rewrite (A-678-1's
//  ruled shape): phase 1 finds the stranded originals with the linear upward
//  liveness walk; phase 2 aggregates (family clock, anchor, fence) over ONLY
//  those all-dead families.
//
//  The rows pins are EXACT (ids, order, every field) and every one asserts
//  TWO things: the hand-derived answer, and that the production body answers
//  exactly what the pre-rewrite body (`LegacyTrashLineage`, verbatim) answers
//  on the same store. They were run against the UNCHANGED source first —
//  green there — so the hand derivations are the old rule's own answers. The
//  cost pins are SHAPE pins (SQLite's VM-instruction count and the query
//  plan), never timings — the P48 lesson `LineageReadP1Tests` follows.
//

import Dependencies
import Foundation
import GRDB
import SQLCipher
import Testing

@testable import VariorumCore

// MARK: - Measurement helpers

private final class InstructionCounter: @unchecked Sendable { var value = 0 }

/// Every SQLite VM instruction the connection executes while `body` runs
/// (`sqlite3_progress_handler` at a period of one instruction).
private func instructions(_ db: AppDatabase, _ body: (Database) throws -> Void) throws -> Int {
    try db.read { database in
        let counter = InstructionCounter()
        let context = Unmanaged.passRetained(counter).toOpaque()
        defer { Unmanaged<InstructionCounter>.fromOpaque(context).release() }
        sqlite3_progress_handler(database.sqliteConnection, 1, { pointer in
            guard let pointer else { return 0 }
            Unmanaged<InstructionCounter>.fromOpaque(pointer).takeUnretainedValue().value += 1
            return 0
        }, context)
        defer { sqlite3_progress_handler(database.sqliteConnection, 0, nil, nil) }
        try body(database)
        return counter.value
    }
}

/// The joined query plan of every SELECT `body` ran.
private func capturedPlan(_ db: AppDatabase, _ body: (Database) throws -> Void) throws -> String {
    let statements: [String] = try db.read { database in
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
    return try db.read { database in
        try statements.flatMap { sql in
            try Row.fetchAll(database, sql: "EXPLAIN QUERY PLAN \(sql)")
                .map { ($0["detail"] as String?) ?? "" }
        }.joined(separator: "\n")
    }
}

/// The plan lines that SCAN a store table (by any alias either body uses for
/// one), minus the ones the caller allows by name.
private func storeTableScans(_ plan: String, allowing allowed: Set<String> = []) -> [String] {
    let storeAliases = [
        "b", "o", "d", "d2", "e", "c", "cb", "placed", "t", "dv", "pi", "w", "rel",
        "block", "edge", "container", "container_block", "variant", "purge_intent", "wing",
    ]
    return plan.split(separator: "\n").map(String.init).filter { line in
        guard !allowed.contains(line) else { return false }
        return storeAliases.contains { line == "SCAN \($0)" || line.hasPrefix("SCAN \($0) ") }
    }
}

// MARK: - The two reads, asked of BOTH bodies

/// The Trash arm — and the assertion that the rewrite answers exactly what
/// the pre-rewrite body answers on this store, for these arguments.
private func stranded(
    _ db: AppDatabase, now: Date = harnessNow, oldestFirst: Bool = false,
    limit: Int? = nil, wingID: String? = nil,
    sourceLocation: SourceLocation = #_sourceLocation
) throws -> [Queries.TrashItem] {
    let (new, old) = try db.read { d in
        (try Queries.strandedOriginals(
            d, now: now, oldestFirst: oldestFirst, limit: limit, wingID: wingID),
         try LegacyTrashLineage.strandedOriginals(
            d, now: now, oldestFirst: oldestFirst, limit: limit, wingID: wingID))
    }
    #expect(new == old, "the rewrite must answer what the old body answered", sourceLocation: sourceLocation)
    return new
}

/// The tray's fates — same double assertion.
private func fates(
    _ db: AppDatabase, _ postID: String, now: Date = harnessNow,
    sourceLocation: SourceLocation = #_sourceLocation
) throws -> [String: Queries.OriginFamilyFate] {
    let (new, old) = try db.read { d in
        (try Queries.originFamilyClocks(d, postID: postID, now: now),
         try LegacyTrashLineage.originFamilyClocks(d, postID: postID, now: now))
    }
    #expect(new == old, "the rewrite must answer what the old body answered", sourceLocation: sourceLocation)
    return new
}

/// One expected Trash row for a stranded original.
private func original(
    _ id: String, clock: String, text: String?, note: String, noteTitle: String, anchor: String
) -> Queries.TrashItem {
    Queries.TrashItem(
        kind: .preservedOriginal, id: id, deletedAt: clock, text: text,
        noteID: note, noteTitle: noteTitle, anchorBlockID: anchor)
}

private func defaultText(_ db: AppDatabase, _ blockID: String) throws -> String? {
    try db.fetchString(
        """
        SELECT v.working_text FROM block b
        JOIN variant v ON v.id = b.default_variant_id AND v.deleted_at IS NULL
        WHERE b.id = ?
        """, [blockID])
}

// MARK: - Fixtures

/// A paragraph long enough for the seam cut at 24 to land inside it.
private let seamText = "Paragraph seam has words. And a second sentence follows here."

/// A note whose paragraph has been through `rounds` seam rounds (⏎ at 24,
/// then ⌫ at the seam). `a[0]` the seeded paragraph, `a[k]` round k's merge
/// (`a[rounds]` is the one still placed), `c[k]` round k's released second
/// half (`c[0]` unused).
private func seamNote(
    _ ops: Operations, rounds: Int, title: String = "the seam note"
) throws -> (note: String, a: [String], c: [String]) {
    let note = try ops.createPost(title: title)
    try ops.seedBlock(in: note.id, text: "A paragraph above.")
    var a = [try ops.seedBlock(in: note.id, text: seamText).block.id]
    var c = [""]
    try ops.seedBlock(in: note.id, text: "A paragraph below.")
    for _ in 0..<rounds {
        let divided = try ops.divide(a[a.count - 1], cut: 24)
        let merged = try ops.merge(a[a.count - 1], divided.block.id, joining: .deleteKeystroke)
        a.append(merged.block.id)
        c.append(divided.block.id)
    }
    return (note.id, a, c)
}

/// A two-take block divided by the ceremony: A preserved whole and released,
/// B and C its live successors.
private func dividedW(
    _ ops: Operations, in noteID: String, text: String = "Alpha one. Beta one."
) throws -> (original: String, first: String, second: String) {
    let fanned = try ops.newBlock(in: noteID, text: text)
    let take2 = try ops.branchVariant(fanned.block.id, from: fanned.variant.id)
    try ops.autosave(take2.id, text: text.replacingOccurrences(of: "one", with: "two"), charDelta: 0)
    let w = try ops.divideW(fanned.block.id, cuts: [fanned.variant.id: 10, take2.id: 10])
    return (fanned.block.id, w.first.block.id, w.second.block.id)
}

@Suite("VX-670 — the Trash's stranded arm and the tray's fates cost the lineage, never its square")
struct TrashLineageP1Tests {

    // MARK: - The exact rows (both bodies, hand-derived answers)

    /// The seam chain her ⏎/⌫ makes. Deleting the placed block strands
    /// exactly the second half its last merge released, on that deletion's
    /// clock and nested under it; deleting that half too moves the stranding
    /// up one link, onto the LATER of the two clocks; past the window the
    /// family has left every surface (the tray says `.gone`).
    @Test func aSeamHistoryStrandsOnlyItsLastReleasedHalfOnTheDeletionsClock() throws {
        try withOperations { ops, db in
            let (note, a, c) = try seamNote(ops, rounds: 4)
            #expect(try stranded(db) == [], "nothing is stranded while the placed block lives")
            #expect(try fates(db, note) == [:])

            try ops.deleteBlock(a[4])
            let a4 = try #require(try db.deletedAt("block", a[4]))
            #expect(try stranded(db) == [
                original(c[4], clock: a4, text: try defaultText(db, c[4]),
                         note: note, noteTitle: "the seam note", anchor: a[4]),
            ], "c4's only descendant went; every older original still has c4 alive")
            #expect(try fates(db, note) == [c[4]: .counting(a4)])

            // The half deleted on its own (the tray's door): a3's whole family
            // (c4, a4) is gone now, and its clock is the LATER deletion.
            try ops.deleteBlock(c[4])
            let c4 = try #require(try db.deletedAt("block", c[4]))
            #expect(a4 < c4, "the fixture's clock claim")
            #expect(try stranded(db) == [
                original(a[3], clock: c4, text: try defaultText(db, a[3]),
                         note: note, noteTitle: "the seam note", anchor: c[4]),
            ])
            #expect(try fates(db, note) == [a[3]: .counting(c4)])

            // Day 31: the family left every surface — both surfaces agree.
            let day31 = harnessNow.addingTimeInterval(31 * 86_400)
            #expect(try stranded(db, now: day31) == [])
            #expect(try fates(db, note, now: day31) == [a[3]: .gone])
        }
    }

    /// The ceremony's original, its successors in two notes, a tombstoned
    /// edge from a live successor and a `version_of` edge beside it; the LAST
    /// successor goes as a cascade victim of ITS note's delete — the family
    /// clock is that note's stamp, the original lists under the note it was
    /// released FROM.
    @Test func aDivideWOriginalRidesItsLastSuccessorWhereverItLivedAndHoweverItWent() throws {
        try withOperations { ops, db in
            let here = try ops.createPost(title: "here")
            let there = try ops.createPost(title: "there")
            let w = try dividedW(ops, in: here.id)
            try ops.moveBlock(w.second, to: there.id)
            try db.write { db in
                try db.execute(
                    sql: """
                        UPDATE edge SET deleted_at = '2026-07-01T00:30:00.000Z'
                        WHERE source_block_id = ? AND target_block_id = ? AND type = 'derived_from'
                        """,
                    arguments: [w.second, w.original])
            }
            let cousin = try ops.newBlock(in: there.id, text: "a version of it")
            try db.write { db in
                try db.execute(
                    sql: """
                        INSERT INTO edge (id, source_block_id, target_block_id, type, origin_op, created_at)
                        VALUES ('version-edge', ?, ?, 'version_of', 'manual', '2026-07-01T00:31:00.000Z')
                        """,
                    arguments: [min(cousin.block.id, w.original), max(cousin.block.id, w.original)])
            }

            try ops.deleteBlock(w.first)
            #expect(try stranded(db) == [], "the second half still lives, in the other note")
            #expect(try fates(db, here.id) == [:])

            try ops.deleteContainer(there.id)
            let clock = try #require(try db.deletedAt("block", w.second))
            #expect(clock == (try db.deletedAt("container", there.id)),
                    "the last successor died as a cascade victim, on its note's stamp")
            #expect(try stranded(db) == [
                original(w.original, clock: clock, text: try defaultText(db, w.original),
                         note: here.id, noteTitle: "here", anchor: w.second),
            ])
            #expect(try fates(db, here.id) == [w.original: .counting(clock)])
            #expect(try fates(db, there.id) == [:], "an original answers under the note it left")
        }
    }

    /// Only a LIVE, UNARCHIVED, UNPLACED original lists, newest family clock
    /// first (the caller's direction, then the original's id), bounded by
    /// `limit` in that direction. A whole note in the Trash carries its
    /// stranded original under the note's ONE row — the Trash arm drops it,
    /// while the tray twin (which has no note-liveness term) still reads it.
    @Test func onlyLiveUnarchivedUnplacedOriginalsOfLiveNotesListNewestFamilyFirst() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "note")
            let x = try ops.newBlock(in: post.id, text: "Ex.")
            let y = try ops.newBlock(in: post.id, text: "Why.")
            let xy = try ops.merge(x.block.id, y.block.id)
            try ops.archiveBlock(x.block.id)
            let p = try ops.newBlock(in: post.id, text: "Pea.")
            let q = try ops.newBlock(in: post.id, text: "Queue.")
            let pq = try ops.merge(p.block.id, q.block.id)
            try ops.deleteBlock(p.block.id)
            let e = try ops.newBlock(in: post.id, text: "Kept part. Extracted part.")
            let extracted = try ops.extract(e.block.id, span: 11..<26)
            let pool = try ops.createPool()
            let scrap = try ops.newBlock(in: pool.id, text: "A scrap.")
            let copy = try ops.poolDragCopy(scrap.block.id, to: post.id)
            for id in [xy.block.id, pq.block.id, extracted.block.id, copy.block.id] {
                try ops.deleteBlock(id)
            }
            let xyClock = try #require(try db.deletedAt("block", xy.block.id))
            let pqClock = try #require(try db.deletedAt("block", pq.block.id))
            #expect(xyClock < pqClock)
            let yRow = original(y.block.id, clock: xyClock, text: "Why.",
                                note: post.id, noteTitle: "note", anchor: xy.block.id)
            let qRow = original(q.block.id, clock: pqClock, text: "Queue.",
                                note: post.id, noteTitle: "note", anchor: pq.block.id)

            #expect(try stranded(db) == [qRow, yRow],
                    "x archived (no clock), p already in the Trash, the extract and pool sources placed")
            #expect(try stranded(db, oldestFirst: true) == [yRow, qRow])
            #expect(try stranded(db, limit: 1) == [qRow])
            #expect(try stranded(db, oldestFirst: true, limit: 1) == [yRow])
            #expect(try fates(db, post.id) == [y.block.id: .counting(xyClock), q.block.id: .counting(pqClock)])

            let gone = try ops.createPost(title: "gone")
            let w = try dividedW(ops, in: gone.id)
            try ops.deleteBlock(w.first)
            try ops.deleteBlock(w.second)
            let wClock = try #require(try db.deletedAt("block", w.second))
            try ops.deleteContainer(gone.id)
            #expect(try db.deletedAt("block", w.original) == nil, "a released original is no cascade victim")
            #expect(try stranded(db) == [qRow, yRow], "it rides the dead note's one row — never double-listed")
            #expect(try fates(db, gone.id) == [w.original: .counting(wClock)])
        }
    }

    /// The purge-intent fence, stamp-aware, on BOTH surfaces (13j ladder B,
    /// B1/B5): a LIVE intent on any family member fences the family; a
    /// voided intent from before the member's tombstone (a re-delete) never
    /// does; a completed one at-or-after the tombstone covered it; an intent
    /// on another table never fences a block.
    @Test func theIntentFenceIsStampAwareOnBothSurfaces() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "fenced")
            let w = try dividedW(ops, in: post.id)
            try ops.deleteBlock(w.first)
            try ops.deleteBlock(w.second)
            let first = try #require(try db.deletedAt("block", w.first))
            let second = try #require(try db.deletedAt("block", w.second))
            let listed = [original(w.original, clock: second, text: try defaultText(db, w.original),
                                   note: post.id, noteTitle: "fenced", anchor: w.second)]
            #expect(try stranded(db) == listed)
            #expect(try fates(db, post.id) == [w.original: .counting(second)])

            func intent(_ deletedAt: String?, table: String = "block") throws {
                try db.write { db in
                    try db.execute(sql: "DELETE FROM purge_intent WHERE id = 'pi-1'")
                    try db.execute(
                        sql: """
                            INSERT INTO purge_intent
                              (id, table_name, row_id, requested_at, created_at, updated_at, deleted_at)
                            VALUES ('pi-1', ?, ?, ?, ?, ?, ?)
                            """,
                        arguments: [table, w.first, first, first, first, deletedAt])
                }
            }
            try intent(nil)
            #expect(try stranded(db) == [], "a live intent on one member fences the whole family")
            #expect(try fates(db, post.id) == [w.original: .gone])
            try intent("2026-06-30T00:00:00.000Z")
            #expect(try stranded(db) == listed, "voided before the tombstone — a re-delete's row stays")
            #expect(try fates(db, post.id) == [w.original: .counting(second)])
            try intent(first)
            #expect(try stranded(db) == [], "completed at the tombstone — it covered this row")
            #expect(try fates(db, post.id) == [w.original: .gone])
            try intent(nil, table: "container")
            #expect(try stranded(db) == listed, "an intent on another table never fences a block")
            #expect(try fates(db, post.id) == [w.original: .counting(second)])
        }
    }

    /// The per-wing Trash: the original's NOTE's wing; a deleted wing's rows
    /// list in Home's Trash (`wingScope`'s dangling rule); nil is every wing.
    @Test func theWingFenceReadsTheOriginalsNote() throws {
        try withOperations { ops, db in
            let far = try ops.createWing(name: "Far")
            let home = try ops.createPost(title: "home")
            let away = try ops.createPost(title: "away", wingId: far.id)
            let wh = try dividedW(ops, in: home.id)
            try ops.deleteBlock(wh.first)
            try ops.deleteBlock(wh.second)
            let wa = try dividedW(ops, in: away.id)
            try ops.deleteBlock(wa.first)
            try ops.deleteBlock(wa.second)
            let h = original(wh.original, clock: try #require(try db.deletedAt("block", wh.second)),
                             text: try defaultText(db, wh.original), note: home.id,
                             noteTitle: "home", anchor: wh.second)
            let a = original(wa.original, clock: try #require(try db.deletedAt("block", wa.second)),
                             text: try defaultText(db, wa.original), note: away.id,
                             noteTitle: "away", anchor: wa.second)
            #expect(h.deletedAt < a.deletedAt)

            #expect(try stranded(db) == [a, h])
            #expect(try stranded(db, wingID: "") == [h])
            #expect(try stranded(db, wingID: far.id) == [a])
            try db.write { db in
                try db.execute(
                    sql: "UPDATE wing SET deleted_at = '2026-07-01T00:50:00.000Z' WHERE id = ?",
                    arguments: [far.id])
            }
            #expect(try stranded(db, wingID: "") == [a, h], "a dead wing's rows list in Home's Trash")
            #expect(try stranded(db, wingID: far.id) == [a])
        }
    }

    /// The family rule at its edges, on a hand-built lineage graph (rows
    /// written directly with foreign keys off — no operation makes these
    /// shapes, but the rule must answer them exactly as it always has): a
    /// descendant id with NO block row is walked through and never counts; a
    /// cycle through the original makes it its own live descendant; a cycle
    /// among dead descendants terminates; a tie on the clock is broken by the
    /// member's id (the anchor) and by the original's id (the order); an
    /// original with no live default take lists with no text.
    @Test func aDanglingCyclicOrTiedLineageAnswersExactlyByTheFamilyRule() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "hand-built")
            let t0 = "2026-07-01T00:10:00.000Z"
            let t1 = "2026-07-01T00:20:00.000Z"
            let t3 = "2026-07-01T00:40:00.000Z"
            try db.writeWithoutTransaction { db in
                try db.execute(sql: "PRAGMA foreign_keys = OFF")
                for (id, deletedAt, defaultVariant) in [
                    ("z-orig-1", nil, "v-z1"), ("z-dead-1", t1, nil),     // o1 ← ghost-1 ← d1
                    ("y-orig-2", nil, nil),                                // o2 ← ghost-2 (only)
                    ("x-orig-3", nil, nil), ("x-dead-3", t1, nil),         // o3 ⇄ d3
                    ("a-orig-4", nil, nil), ("a-dead-4a", t1, nil), ("a-dead-4b", t1, nil),  // o4 ← d4a ⇄ d4b
                    ("m-orig-5", nil, "v-m5"), ("m-dead-5", t3, nil),      // o5 ← d5; o5's take dead
                ] as [(String, String?, String?)] {
                    try db.execute(
                        sql: """
                            INSERT INTO block (id, default_variant_id, last_container_id,
                                               created_at, updated_at, deleted_at)
                            VALUES (?, ?, ?, ?, ?, ?)
                            """,
                        arguments: [id, defaultVariant, note.id, t0, t0, deletedAt])
                }
                for (id, block, text, deletedAt) in [
                    ("v-z1", "z-orig-1", "origin one", nil),
                    ("v-m5", "m-orig-5", "origin five", t3),
                ] as [(String, String, String, String?)] {
                    try db.execute(
                        sql: """
                            INSERT INTO variant (id, block_id, working_text, fan_position,
                                                 created_at, updated_at, deleted_at)
                            VALUES (?, ?, ?, 'a0', ?, ?, ?)
                            """,
                        arguments: [id, block, text, t0, t0, deletedAt])
                }
                for (n, source, target) in [
                    (1, "ghost-1", "z-orig-1"), (2, "z-dead-1", "ghost-1"),
                    (3, "ghost-2", "y-orig-2"),
                    (4, "x-dead-3", "x-orig-3"), (5, "x-orig-3", "x-dead-3"),
                    (6, "a-dead-4a", "a-orig-4"), (7, "a-dead-4b", "a-dead-4a"),
                    (8, "a-dead-4a", "a-dead-4b"),
                    (9, "m-dead-5", "m-orig-5"),
                ] {
                    try db.execute(
                        sql: """
                            INSERT INTO edge (id, source_block_id, target_block_id, type, origin_op, created_at)
                            VALUES (?, ?, ?, 'derived_from', 'divide', ?)
                            """,
                        arguments: ["edge-\(n)", source, target, t0])
                }
                try db.execute(sql: "PRAGMA foreign_keys = ON")
            }
            let five = original("m-orig-5", clock: t3, text: nil, note: note.id,
                                noteTitle: "hand-built", anchor: "m-dead-5")
            let one = original("z-orig-1", clock: t1, text: "origin one", note: note.id,
                               noteTitle: "hand-built", anchor: "z-dead-1")
            let four = original("a-orig-4", clock: t1, text: nil, note: note.id,
                                noteTitle: "hand-built", anchor: "a-dead-4b")
            #expect(try stranded(db) == [five, one, four],
                    "newest clock first; the t1 tie by the original's id, descending")
            #expect(try stranded(db, oldestFirst: true) == [four, one, five])
            #expect(try stranded(db, limit: 2) == [five, one])
            #expect(try stranded(db, oldestFirst: true, limit: 2) == [four, one])
            #expect(try fates(db, note.id) == [
                "z-orig-1": .counting(t1), "a-orig-4": .counting(t1), "m-orig-5": .counting(t3),
            ], "o2 has no real descendant (no clock to ride); o3 is its own live descendant")
        }
    }

    /// Nothing deleted, no lineage, an empty note, a missing note: nothing.
    @Test func nothingDeletedOrNoLineageStrandsNothing() throws {
        try withOperations { ops, db in
            #expect(try stranded(db) == [])
            let post = try ops.createPost(title: "plain")
            let lone = try ops.newBlock(in: post.id, text: "a block with no lineage")
            try ops.deleteBlock(lone.block.id)
            let empty = try ops.createPost(title: "empty")
            #expect(try stranded(db) == [])
            #expect(try fates(db, post.id) == [:])
            #expect(try fates(db, empty.id) == [:])
            #expect(try fates(db, "no-such-note") == [:])
        }
    }

    // MARK: - The cost: RED ON OLD

    /// **RED ON OLD.** The Trash arm after a Delete Block at the end of a
    /// seam history: its work must grow with the lineage it walks, never with
    /// that lineage SQUARED. Old: every original carried a pair for each of
    /// its descendants — tripling the rounds was ~nine times the work.
    @Test func theTrashArmGrowsWithTheSeamHistoryNeverItsSquare() throws {
        func work(rounds: Int) throws -> Int {
            try withOperations { ops, db in
                let (_, a, c) = try seamNote(ops, rounds: rounds)
                try ops.deleteBlock(a[rounds])
                #expect(try db.read {
                    try Queries.strandedOriginals($0, now: harnessNow, limit: 501)
                }.map(\.id) == [c[rounds]])
                return try instructions(db) {
                    _ = try Queries.strandedOriginals($0, now: harnessNow, limit: 501)
                }
            }
        }
        let short = try work(rounds: 20)
        let long = try work(rounds: 60)
        print("VX-670 strandedOriginals VM instructions: 20 rounds \(short), 60 rounds \(long)")
        #expect(Double(long) < Double(short) * 3.9,
                "seam rounds ×3: \(short) → \(long) VM instructions — linear is ≤ ×3, the pair set was ×9")
    }

    /// **RED ON OLD.** The tray's held fates read, same shape.
    @Test func theTraysFatesGrowWithTheSeamHistoryNeverItsSquare() throws {
        func work(rounds: Int) throws -> Int {
            try withOperations { ops, db in
                let (note, a, c) = try seamNote(ops, rounds: rounds)
                try ops.deleteBlock(a[rounds])
                #expect(try db.read {
                    try Queries.originFamilyClocks($0, postID: note, now: harnessNow)
                }.keys.sorted() == [c[rounds]])
                return try instructions(db) {
                    _ = try Queries.originFamilyClocks($0, postID: note, now: harnessNow)
                }
            }
        }
        let short = try work(rounds: 20)
        let long = try work(rounds: 60)
        print("VX-670 originFamilyClocks VM instructions: 20 rounds \(short), 60 rounds \(long)")
        #expect(Double(long) < Double(short) * 3.9,
                "seam rounds ×3: \(short) → \(long) VM instructions — linear is ≤ ×3, the pair set was ×9")
    }

    // MARK: - The cost: P1's other half (the library)

    /// A library of `blocksEach` blocks in each of 20 notes, half of them
    /// divided (lineage edges elsewhere), beside a seam note whose placed
    /// block was just deleted.
    private func libraryWorld(
        _ ops: Operations, blocksEach: Int
    ) throws -> (note: String, deleted: String, stranded: String) {
        for n in 0..<20 {
            let other = try ops.createPost(title: "library \(n)")
            for b in 0..<blocksEach {
                let minted = try ops.seedBlock(
                    in: other.id, text: "Library paragraph \(b) of note \(n). And a second sentence.")
                if b % 2 == 0 { _ = try ops.divide(minted.block.id, cut: 8) }
            }
        }
        let (note, a, c) = try seamNote(ops, rounds: 10)
        try ops.deleteBlock(a[10])
        return (note, a[10], c[10])
    }

    /// The tray's read must not grow with the LIBRARY: the same seam note in
    /// a library fifteen times thicker costs the same.
    @Test func theTraysFatesDoNotGrowWithTheLibrary() throws {
        func work(blocksEach: Int) throws -> Int {
            try withOperations { ops, db in
                let world = try libraryWorld(ops, blocksEach: blocksEach)
                #expect(try db.read {
                    try Queries.originFamilyClocks($0, postID: world.note, now: harnessNow)
                }.keys.sorted() == [world.stranded])
                return try instructions(db) {
                    _ = try Queries.originFamilyClocks($0, postID: world.note, now: harnessNow)
                }
            }
        }
        let thin = try work(blocksEach: 2)
        let thick = try work(blocksEach: 30)
        print("VX-670 originFamilyClocks VM instructions: library ×1 \(thin), ×15 \(thick)")
        #expect(Double(thick) < Double(thin) * 1.5,
                "library ×15: \(thin) → \(thick) VM instructions — the library must not drive the tray (P1)")
    }

    /// The tray's plan: seeded by this note's own blocks (by index), every
    /// walk seeks by edge and block id — never a scan of a store table.
    @Test func theTraysFatesNeverScanAStoreTable() throws {
        try withOperations { ops, db in
            let (note, a, _) = try seamNote(ops, rounds: 3)
            try ops.deleteBlock(a[3])
            let plan = try capturedPlan(db) {
                _ = try Queries.originFamilyClocks($0, postID: note, now: harnessNow)
            }
            let scans = storeTableScans(plan)
            #expect(scans.isEmpty, "store-table scans \(scans); plan was:\n\(plan)")
        }
    }

    /// The Trash arm's library cost: it may pay ONE window scan of `block` —
    /// the same scan the listing's own block arm already pays beside it
    /// (there is no `deleted_at` index) — and nothing more: the library's
    /// growth must cost the stranded arm no more than it costs the block arm.
    @Test func theTrashArmGrowsWithTheLibraryNoFasterThanTheListingsOwnBlockScan() throws {
        func work(blocksEach: Int) throws -> (stranded: Int, blockArm: Int) {
            try withOperations { ops, db in
                let world = try libraryWorld(ops, blocksEach: blocksEach)
                #expect(try db.read {
                    try Queries.strandedOriginals($0, now: harnessNow, limit: 501)
                }.map(\.id) == [world.stranded])
                return (
                    try instructions(db) {
                        _ = try Queries.strandedOriginals($0, now: harnessNow, limit: 501, wingID: "")
                    },
                    try instructions(db) {
                        _ = try Queries.trash($0, now: harnessNow, kinds: [.block], limit: 501, wingID: "")
                    })
            }
        }
        let thin = try work(blocksEach: 2)
        let thick = try work(blocksEach: 30)
        let strandedGrowth = thick.stranded - thin.stranded
        let blockArmGrowth = thick.blockArm - thin.blockArm
        print("VX-670 strandedOriginals VM instructions: library ×1 \(thin.stranded), ×15 \(thick.stranded) "
              + "(growth \(strandedGrowth)); the block arm \(thin.blockArm) → \(thick.blockArm) (growth \(blockArmGrowth))")
        #expect(Double(strandedGrowth) <= Double(blockArmGrowth) * 1.5,
                "library ×15 grew the stranded arm by \(strandedGrowth) VM instructions against the block arm's \(blockArmGrowth)")
    }

    /// The Trash arm's plan, in production's Home shape (`wingID: ""`): the
    /// window seed is the ONE scan of `block` (alias `t`), the wing table is
    /// the Home fence's tiny list — and every lineage walk seeks.
    @Test func theTrashArmScansOnlyItsWindowSeed() throws {
        try withOperations { ops, db in
            let (_, a, _) = try seamNote(ops, rounds: 3)
            try ops.deleteBlock(a[3])
            let plan = try capturedPlan(db) {
                _ = try Queries.strandedOriginals($0, now: harnessNow, limit: 501, wingID: "")
            }
            let scans = storeTableScans(plan, allowing: ["SCAN t", "SCAN w"])
            #expect(scans.isEmpty, "store-table scans \(scans); plan was:\n\(plan)")
            #expect(plan.split(separator: "\n").contains("SCAN t"),
                    "the window seed is the one scan of block; plan was:\n\(plan)")
        }
    }
}
