//
//  LineageReadP1Tests.swift
//  VariorumCoreTests
//
//  VX-654 + VX-653 (the VX-678 run, Unit 2) — the two lineage reads behind
//  the tray and the Delete Block receipt, over a note's SEAM history (⏎
//  mid-paragraph divides, ⌫ at the seam merges; every round releases two
//  live-unplaced originals with lineage edges).
//
//  The trace of record (`notes/plans/fixes/vx-648-launch-week.md`, "VX-653 /
//  VX-654 MEASUREMENTS", ruling A-648-3): at 600 seam rounds
//  `Queries.originalsStrandedBy` took 13 s and `Queries.preservedOriginals`
//  5.8 s.
//
//  · VX-654 — `originalsStrandedBy` (awaited in the Delete Block receipt
//    chain, `StrandedOriginals.note`). Its recursive CTE carried an
//    `(origin, descendant)` PAIR for every ancestor of the deleted block and
//    every one of that ancestor's descendants — O(L²) in lineage depth. The
//    rewrite walks the ancestors once, the candidates' descendant
//    neighbourhood once, and ONE upward liveness walk from that
//    neighbourhood: O(L).
//  · VX-653 — `preservedOriginals` (held by the open tray panel). Its
//    `released_at` subquery sought the note's whole placement history per
//    original through `idx_cblock_order`. Traced on this run's HEAD: v1_34's
//    partial `idx_cblock_dead_block` (VX-647, landed AFTER the measurement)
//    already serves that subquery by block — the pins below are a GREEN
//    VERIFICATION of that (hollow at HEAD; red only with v1_34 withheld).
//
//  The rows pins are EXACT (ids and order) and were run against the old
//  `originalsStrandedBy` body before the rewrite, green on both sides — a
//  performance rewrite never moves an answer. The cost pins are SHAPE pins
//  (SQLite's own VM-instruction count and the query plan), never timings —
//  the P48 lesson `ReadLayerP1Tests` and `TrayBadgeP1Tests` follow.
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
/// (`sqlite3_progress_handler` at a period of one instruction) — the whole
/// read's work, recursive CTEs included.
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

private func stamp(_ date: Date) -> String { DateFormatter.variorumISO8601.string(from: date) }

// MARK: - Fixtures

/// A paragraph long enough for the seam cut at 24 to land inside it.
private let seamText = "Paragraph seam has words. And a second sentence follows here."

/// One SEAM ROUND on `block`: ⏎ mid-paragraph divides it, ⌫ at the seam
/// merges the halves back — both halves RELEASED (live, unplaced, lineage).
/// Returns the merged successor and the released second half.
private func seamRound(
    _ ops: Operations, _ block: String
) throws -> (merged: Operations.MergeResult, secondHalf: String) {
    let divided = try ops.divide(block, cut: 24)
    let merged = try ops.merge(block, divided.block.id, joining: .deleteKeystroke)
    return (merged, divided.block.id)
}

/// A note whose paragraph has been through `rounds` seam rounds. Returns the
/// note, the chain `a` (a[0] the seeded paragraph, a[k] the block round k's
/// merge minted — a[rounds] is the one still placed) and `c` (c[k] the
/// second half round k's divide minted and its merge released; c[0] unused).
private func seamNote(
    _ ops: Operations, rounds: Int
) throws -> (note: String, a: [String], c: [String]) {
    let note = try ops.createPost(title: "the seam note")
    try ops.seedBlock(in: note.id, text: "A paragraph above.")
    var a = [try ops.seedBlock(in: note.id, text: seamText).block.id]
    var c = [""]
    try ops.seedBlock(in: note.id, text: "A paragraph below.")
    for _ in 0..<rounds {
        let round = try seamRound(ops, a[a.count - 1])
        a.append(round.merged.block.id)
        c.append(round.secondHalf)
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

@Suite("VX-654 / VX-653 — the lineage reads cost the lineage, never its square")
struct LineageReadP1Tests {

    // MARK: - VX-654: originalsStrandedBy — the exact rows

    /// The seam chain her ⏎/⌫ makes. Deleting the placed block strands
    /// exactly the second half its last merge released (that half's ONLY
    /// descendant was the deleted block); every older original still has a
    /// live descendant among the released ones.
    @Test func aSeamHistoryStrandsExactlyTheOriginalsWhoseLastDescendantWent() throws {
        try withOperations { ops, db in
            let (_, a, c) = try seamNote(ops, rounds: 4)
            let placed = a[4]

            // Asked of a LIVE block: nothing is stranded while it lives.
            #expect(try db.read { try Queries.originalsStrandedBy($0, blockIDs: [placed]) } == [])

            try ops.deleteBlock(placed)
            #expect(try db.read { try Queries.originalsStrandedBy($0, blockIDs: [placed]) } == [c[4]],
                    "c4's only descendant was the deleted block; a3 still has c4 alive")

            try ops.deleteBlock(c[4])
            #expect(try db.read { try Queries.originalsStrandedBy($0, blockIDs: [c[4]]) } == [a[3]],
                    "now a3's whole family (c4, a4) is gone; c3 still has a3 alive")

            // The pick-delete road asks about several blocks at once: c4 is
            // itself dead now, so it is no longer an original that CAN be
            // stranded — the answer is a3 alone.
            #expect(try db.read {
                try Queries.originalsStrandedBy($0, blockIDs: [c[4], placed])
            } == [a[3]])
        }
    }

    /// The ceremony's preserved original, its successors moved apart across
    /// two notes, one of its edges tombstoned, and a `version_of` edge beside
    /// it: lineage is read PAST edge tombstones (the delete took its own
    /// edges down), a successor in another note still counts, and only
    /// `derived_from` is lineage.
    @Test func aDivideWOriginalIsStrandedOnlyWhenItsLastSuccessorGoesWhereverItLives() throws {
        try withOperations { ops, db in
            let here = try ops.createPost(title: "here")
            let there = try ops.createPost(title: "there")
            let w = try dividedW(ops, in: here.id)
            try ops.moveBlock(w.second, to: there.id)
            // A tombstoned derived_from edge from a LIVE successor: still
            // lineage — the second half keeps the original permanent.
            try db.write { db in
                try db.execute(
                    sql: """
                        UPDATE edge SET deleted_at = '2026-07-01T00:30:00.000Z'
                        WHERE source_block_id = ? AND target_block_id = ? AND type = 'derived_from'
                        """,
                    arguments: [w.second, w.original])
            }
            // A version_of edge from a live block is NOT a descendant.
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
            #expect(try db.read { try Queries.originalsStrandedBy($0, blockIDs: [w.first]) } == [],
                    "the second half still lives, in the other note, through a tombstoned edge")

            try ops.deleteBlock(w.second)
            #expect(try db.read { try Queries.originalsStrandedBy($0, blockIDs: [w.second]) }
                    == [w.original], "its last successor went — from the OTHER note")
            #expect(try db.read {
                try Queries.originalsStrandedBy($0, blockIDs: [w.first, w.second])
            } == [w.original])
        }
    }

    /// Only a LIVE, UNARCHIVED, UNPLACED ancestor can be stranded: an
    /// archived original keeps no clock, an independently deleted one is
    /// already in the Trash, and a placed source (extract, pool copy) is in
    /// a note.
    @Test func anArchivedADeadOrAPlacedAncestorIsNeverStranded() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "note")
            // Archived: merge x+y, archive x, delete the merge.
            let x = try ops.newBlock(in: post.id, text: "Ex.")
            let y = try ops.newBlock(in: post.id, text: "Why.")
            let xy = try ops.merge(x.block.id, y.block.id)
            try ops.archiveBlock(x.block.id)
            // Dead: merge p+q, delete p on its own, delete the merge.
            let p = try ops.newBlock(in: post.id, text: "Pea.")
            let q = try ops.newBlock(in: post.id, text: "Queue.")
            let pq = try ops.merge(p.block.id, q.block.id)
            try ops.deleteBlock(p.block.id)
            // Placed: an extract's source survives in place.
            let e = try ops.newBlock(in: post.id, text: "Kept part. Extracted part.")
            let extracted = try ops.extract(e.block.id, span: 11..<26)
            // Placed: a pool copy's source stays in the pool.
            let pool = try ops.createPool()
            let scrap = try ops.newBlock(in: pool.id, text: "A scrap.")
            let copy = try ops.poolDragCopy(scrap.block.id, to: post.id)

            let deleted = [xy.block.id, pq.block.id, extracted.block.id, copy.block.id]
            for id in deleted { try ops.deleteBlock(id) }

            #expect(try db.read { try Queries.originalsStrandedBy($0, blockIDs: [xy.block.id]) }
                    == [y.block.id], "x is archived — kept, no clock")
            #expect(try db.read { try Queries.originalsStrandedBy($0, blockIDs: [pq.block.id]) }
                    == [q.block.id], "p is already in the Trash on its own stamp")
            #expect(try db.read { try Queries.originalsStrandedBy($0, blockIDs: [extracted.block.id]) }
                    == [], "the extract's source is placed")
            #expect(try db.read { try Queries.originalsStrandedBy($0, blockIDs: [copy.block.id]) }
                    == [], "the pool scrap is placed")
            // Several at once, named in REVERSE of id order: the answer is
            // sorted by id, whatever order the caller named them.
            #expect(try db.read {
                try Queries.originalsStrandedBy($0, blockIDs: Array(deleted.reversed()))
            } == [y.block.id, q.block.id].sorted())
            #expect(Array(deleted.reversed()) != deleted.sorted(), "the fixture's order claim")
        }
    }

    /// No lineage, no input, a note with nothing in it, a missing id: no
    /// answer at all.
    @Test func noLineageNoInputAndAnEmptyNoteStrandNothing() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "plain")
            let lone = try ops.newBlock(in: post.id, text: "a block with no lineage")
            try ops.deleteBlock(lone.block.id)
            _ = try ops.createPost(title: "empty")
            #expect(try db.read { try Queries.originalsStrandedBy($0, blockIDs: [lone.block.id]) } == [])
            #expect(try db.read { try Queries.originalsStrandedBy($0, blockIDs: []) } == [])
            #expect(try db.read { try Queries.originalsStrandedBy($0, blockIDs: ["no-such-block"]) } == [])
        }
    }

    /// The family rule at its edges, on a hand-built lineage graph (rows
    /// written directly — no operation makes these shapes, but the rule must
    /// answer them exactly as it always has): a descendant id with NO block
    /// row is walked through and never counts (alive or at all), and a
    /// lineage CYCLE terminates and counts the original as its own live
    /// descendant.
    @Test func aDanglingOrCyclicLineageAnswersExactlyByTheFamilyRule() throws {
        try withOperations { ops, db in
            _ = ops
            let t = "2026-07-01T00:10:00.000Z"
            let dead = "2026-07-01T00:20:00.000Z"
            try db.writeWithoutTransaction { db in
                try db.execute(sql: "PRAGMA foreign_keys = OFF")
                for (id, deletedAt) in [
                    ("z-orig-1", nil), ("z-dead-1", dead),       // o1 ← ghost-1 ← d1
                    ("y-orig-2", nil),                           // o2 ← ghost-2 (only)
                    ("x-orig-3", nil), ("x-dead-3", dead),       // o3 ⇄ d3 (cycle through o3)
                    ("a-orig-4", nil), ("a-dead-4a", dead), ("a-dead-4b", dead),  // o4 ← d4a ⇄ d4b
                ] as [(String, String?)] {
                    try db.execute(
                        sql: "INSERT INTO block (id, created_at, updated_at, deleted_at) VALUES (?, ?, ?, ?)",
                        arguments: [id, t, t, deletedAt])
                }
                // (source derived_from target)
                for (n, source, target) in [
                    (1, "ghost-1", "z-orig-1"), (2, "z-dead-1", "ghost-1"),
                    (3, "ghost-2", "y-orig-2"),
                    (4, "x-dead-3", "x-orig-3"), (5, "x-orig-3", "x-dead-3"),
                    (6, "a-dead-4a", "a-orig-4"), (7, "a-dead-4b", "a-dead-4a"),
                    (8, "a-dead-4a", "a-dead-4b"),
                ] {
                    try db.execute(
                        sql: """
                            INSERT INTO edge (id, source_block_id, target_block_id, type, origin_op, created_at)
                            VALUES (?, ?, ?, 'derived_from', 'divide', ?)
                            """,
                        arguments: ["edge-\(n)", source, target, t])
                }
                try db.execute(sql: "PRAGMA foreign_keys = ON")
            }
            func stranded(_ ids: [String]) throws -> [String] {
                try db.read { try Queries.originalsStrandedBy($0, blockIDs: ids) }
            }
            #expect(try stranded(["z-dead-1"]) == ["z-orig-1"],
                    "walked through the missing row; the one real descendant is dead")
            #expect(try stranded(["ghost-2"]) == [],
                    "a family with no real descendant row has no clock to ride")
            #expect(try stranded(["x-dead-3"]) == [],
                    "a cycle through the original makes it its own live descendant")
            #expect(try stranded(["a-dead-4b"]) == ["a-orig-4"],
                    "a cycle among dead descendants terminates; all of them are dead")
            #expect(try stranded(["z-dead-1", "ghost-2", "x-dead-3", "a-dead-4b"])
                    == ["a-orig-4", "z-orig-1"], "sorted by id, whatever the caller's order")
        }
    }

    // MARK: - VX-654: the cost — RED ON OLD

    /// **RED ON OLD.** The receipt's read after a Delete Block at the end of
    /// a seam history: its work must grow with the lineage it walks, never
    /// with that lineage SQUARED. Old: every ancestor carried a pair for each
    /// of its descendants — tripling the rounds was ~nine times the work.
    @Test func theDeleteReceiptsReadGrowsWithTheSeamHistoryNeverItsSquare() throws {
        func work(rounds: Int) throws -> Int {
            try withOperations { ops, db in
                let (_, a, c) = try seamNote(ops, rounds: rounds)
                try ops.deleteBlock(a[rounds])
                #expect(try db.read {
                    try Queries.originalsStrandedBy($0, blockIDs: [a[rounds]])
                } == [c[rounds]])
                return try instructions(db) {
                    _ = try Queries.originalsStrandedBy($0, blockIDs: [a[rounds]])
                }
            }
        }
        let short = try work(rounds: 20)
        let long = try work(rounds: 60)
        print("VX-654 originalsStrandedBy VM instructions: 20 rounds \(short), 60 rounds \(long)")
        #expect(Double(long) < Double(short) * 3.9,
                "seam rounds ×3: \(short) → \(long) VM instructions — linear is ≤ ×3, the pair set was ×9")
    }

    // MARK: - VX-653: preservedOriginals — GREEN VERIFICATION (hollow at HEAD)

    /// The tray's preserved-originals listing, exact: a seam history, a
    /// ceremony original whose successors all died, an archived and a dead
    /// released block (both excluded), a successor moved to another note
    /// (the landing is THIS note's), and an empty note. Newest release
    /// first, ties by id; each release stamp is the act's own.
    @Test func thePreservedListingIsExactOverASeamHistory() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note")
            let elsewhere = try ops.createPost(title: "elsewhere")
            let empty = try ops.createPost(title: "empty")
            try ops.seedBlock(in: note.id, text: "A paragraph above.")
            let seed = try ops.seedBlock(in: note.id, text: seamText)
            var a = [seed.block.id]
            var c = [""]
            var released: [String] = [""]        // released[k]: round k's merge stamp
            var firstHalf: [String: String] = [:], secondHalf: [String: String] = [:]
            for k in 1...3 {
                let divided = try ops.divide(a[k - 1], cut: 24)
                let rendered = try db.read { try Queries.renderPost($0, containerID: note.id) }
                firstHalf[a[k - 1]] = rendered.first { $0.blockID == a[k - 1] }?.text
                secondHalf[divided.block.id] = rendered.first { $0.blockID == divided.block.id }?.text
                let merged = try ops.merge(a[k - 1], divided.block.id, joining: .deleteKeystroke)
                a.append(merged.block.id)
                c.append(divided.block.id)
                released.append(stamp(merged.block.createdAt))
            }
            // The ceremony original, its successors both deleted.
            let w = try dividedW(ops, in: note.id)
            let wReleased = try #require(try db.fetchString(
                "SELECT deleted_at FROM container_block WHERE block_id = ?", [w.original]))
            try ops.deleteBlock(w.first)
            try ops.deleteBlock(w.second)
            // Archived (x) and dead (p) released originals; their partners list.
            let x = try ops.newBlock(in: note.id, text: "Ex.")
            let y = try ops.newBlock(in: note.id, text: "Why.")
            let xy = try ops.merge(x.block.id, y.block.id)
            try ops.archiveBlock(x.block.id)
            let p = try ops.newBlock(in: note.id, text: "Pea.")
            let q = try ops.newBlock(in: note.id, text: "Queue.")
            let pq = try ops.merge(p.block.id, q.block.id)
            try ops.deleteBlock(p.block.id)
            // A ceremony whose second successor moves to another note.
            let g = try dividedW(ops, in: note.id, text: "Gamma one. Delta one.")
            let gReleased = try #require(try db.fetchString(
                "SELECT deleted_at FROM container_block WHERE block_id = ?", [g.original]))
            try ops.moveBlock(g.second, to: elsewhere.id)

            let expected: [Queries.PreservedOriginal] = [
                .init(blockID: g.original, text: "Gamma one. Delta one.",
                      releasedAt: gReleased, landAfterBlockID: g.first),
                .init(blockID: q.block.id, text: "Queue.",
                      releasedAt: stamp(pq.block.createdAt), landAfterBlockID: pq.block.id),
                .init(blockID: y.block.id, text: "Why.",
                      releasedAt: stamp(xy.block.createdAt), landAfterBlockID: xy.block.id),
                .init(blockID: w.original, text: "Alpha one. Beta one.",
                      releasedAt: wReleased, landAfterBlockID: nil),
                .init(blockID: a[2], text: firstHalf[a[2]], releasedAt: released[3], landAfterBlockID: a[3]),
                .init(blockID: c[3], text: secondHalf[c[3]], releasedAt: released[3], landAfterBlockID: a[3]),
                .init(blockID: a[1], text: firstHalf[a[1]], releasedAt: released[2], landAfterBlockID: nil),
                .init(blockID: c[2], text: secondHalf[c[2]], releasedAt: released[2], landAfterBlockID: nil),
                .init(blockID: a[0], text: firstHalf[a[0]], releasedAt: released[1], landAfterBlockID: nil),
                .init(blockID: c[1], text: secondHalf[c[1]], releasedAt: released[1], landAfterBlockID: nil),
            ]
            #expect(a[2] < c[3] && a[1] < c[2] && a[0] < c[1],
                    "the fixture's tie claim: each round's first half was minted before its second")
            #expect(expected.allSatisfy { $0.text != nil })
            #expect(released[1] < released[2] && released[2] < released[3]
                    && released[3] < wReleased && wReleased < stamp(xy.block.createdAt)
                    && stamp(xy.block.createdAt) < stamp(pq.block.createdAt)
                    && stamp(pq.block.createdAt) < gReleased,
                    "the fixture's clock claim: every release is later than the last")

            #expect(try db.read { try Queries.preservedOriginals($0, postID: note.id) } == expected)
            #expect(try db.read { try Queries.preservedOriginals($0, postID: note.id, limit: 3) }
                    == Array(expected.prefix(3)))
            #expect(try db.read { try Queries.preservedOriginals($0, postID: elsewhere.id) } == [],
                    "an original lists in the note it was released FROM")
            #expect(try db.read { try Queries.preservedOriginals($0, postID: empty.id) } == [])
        }
    }

    /// GREEN VERIFICATION (hollow at HEAD — red only with v1_34 withheld):
    /// the release stamp is sought BY BLOCK through v1_34's dead-placement
    /// index, never by scanning the note's whole placement history.
    @Test func theReleaseStampSeeksByBlockNeverTheNotesPlacementHistory() throws {
        try withOperations { ops, db in
            let (note, _, _) = try seamNote(ops, rounds: 2)
            let plan = try capturedPlan(db) {
                _ = try Queries.preservedOriginals($0, postID: note, limit: 501)
            }
            #expect(plan.contains("SEARCH rel USING INDEX idx_cblock_dead_block (block_id=?"),
                    "the release stamp must seek the block's own dead placements; plan was:\n\(plan)")
            #expect(!plan.contains("SEARCH rel USING INDEX idx_cblock_order"),
                    "never the note's placement history per original; plan was:\n\(plan)")
        }
    }

    /// GREEN VERIFICATION (hollow at HEAD — red only with v1_34 withheld):
    /// the open tray's listing grows with the released set, never with the
    /// released set times the note's placement history.
    @Test func thePreservedListingGrowsWithTheReleasedSetNeverItsSquare() throws {
        func work(rounds: Int) throws -> Int {
            try withOperations { ops, db in
                let (note, _, _) = try seamNote(ops, rounds: rounds)
                #expect(try db.read {
                    try Queries.preservedOriginals($0, postID: note, limit: 501)
                }.count == 2 * rounds)
                return try instructions(db) {
                    _ = try Queries.preservedOriginals($0, postID: note, limit: 501)
                }
            }
        }
        let short = try work(rounds: 20)
        let long = try work(rounds: 60)
        print("VX-653 preservedOriginals VM instructions: 20 rounds \(short), 60 rounds \(long)")
        #expect(Double(long) < Double(short) * 3.9,
                "seam rounds ×3: \(short) → \(long) VM instructions — linear is ≤ ×3")
    }
}
