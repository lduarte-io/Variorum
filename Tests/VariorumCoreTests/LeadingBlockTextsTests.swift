//
//  LeadingBlockTextsTests.swift
//  VariorumCoreTests
//
//  13u2 UNIT A2 — the bounded read behind the book cards' preview prime
//  (`Queries.leadingBlockTexts`), pinned the way `ReadLayerP1Tests` pins the
//  read layer's P1 debt: as SHAPE facts — the query plan and the row cap —
//  never as timings, so a pin cannot pass or fail with machine load.
//
//  Why it exists: a collapsed Outline card used to derive its ~forty-word
//  preview from a WHOLE-note render (`Queries.renderPost`, cost ∝ the note's
//  text), once per realized row. RULING A-1's constraint 1 is that the
//  replacement is bounded per entry — cost ∝ entries × a small constant,
//  never ∝ the book's text. These tests say exactly that, plus the one thing
//  a bound is worthless without: that the bounded read RESOLVES each slot
//  identically to the unbounded one it replaces.
//
//  The measured numbers live in the plan's UNIT A2 RECORD.
//

import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

@Suite("The leading blocks read (13u2 UNIT A2 — the card preview's prime)")
struct LeadingBlockTextsTests {

    /// The query plan of the shipped statement, exactly as it ships (the SQL
    /// is a constant precisely so this reads the real thing).
    private func plan(_ db: AppDatabase, containerID: String, blocks: Int) throws -> String {
        try db.read { database in
            try Row.fetchAll(
                database,
                sql: "EXPLAIN QUERY PLAN \(Queries.leadingBlockTextsSQL)",
                arguments: [containerID, blocks])
                .map { ($0["detail"] as String?) ?? "" }
                .joined(separator: "\n")
        }
    }

    // MARK: - The bound (P1)

    /// **THE P1 PIN.** The read must SEEK the note's placements through
    /// `idx_cblock_order` and stop at the `LIMIT` — never scan
    /// `container_block`, and never sort the note's whole placement list to
    /// find its first four rows. (SQLite reports `USE TEMP B-TREE FOR LAST
    /// TERM OF ORDER BY` for the `cb.id` tiebreak: that is its partial
    /// sorter, which consumes the index's `position` order and buffers only
    /// runs of EQUAL positions — measured flat from a 10-block note to a
    /// 20,000-block one. A full `USE TEMP B-TREE FOR ORDER BY` would mean the
    /// planner had to read every row first, and that is the regression this
    /// pin catches.)
    @Test func theLeadingBlocksReadSeeksTheIndexAndNeverScansThePlacements() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "a long note")
            for i in 0..<40 { try ops.seedBlock(in: post.id, text: "block \(i)") }

            let plan = try plan(db, containerID: post.id, blocks: 4)
            #expect(plan.contains("SEARCH cb USING INDEX idx_cblock_order"),
                    "the note's placements must be SEEKED by the ordered index; plan was:\n\(plan)")
            #expect(!plan.contains("SCAN cb"),
                    "the placements table must never be scanned; plan was:\n\(plan)")
            #expect(!plan.contains("USE TEMP B-TREE FOR ORDER BY"),
                    "a full sort would mean reading every placement first; plan was:\n\(plan)")
        }
    }

    /// The cap is real: a forty-block note answers with four texts, and the
    /// four are the note's FIRST four in reading order.
    @Test func theReadReturnsAtMostTheBlocksAskedForAndTheyAreTheLeadingOnes() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            for i in 0..<40 { try ops.seedBlock(in: post.id, text: "block \(i)") }

            let leading = try db.read {
                try Queries.leadingBlockTexts($0, containerID: post.id, blocks: 4)
            }
            #expect(leading == ["block 0", "block 1", "block 2", "block 3"])

            let whole = try db.read { try Queries.renderPost($0, containerID: post.id) }
            #expect(whole.count == 40, "the premise: the note really is forty blocks long")
            #expect(leading == whole.prefix(4).compactMap(\.text),
                    "the bounded read is the unbounded one's prefix")
        }
    }

    /// One read, many notes — the book's prime. One statement per note, each
    /// bounded; the count is the book's entries, never its blocks.
    @Test func theManyNoteReadAnswersEveryNoteAndCostsOneBoundedStatementEach() throws {
        try withOperations { ops, db in
            var ids: [String] = []
            for n in 0..<5 {
                let post = try ops.createPost(title: "note \(n)")
                for i in 0..<30 { try ops.seedBlock(in: post.id, text: "note \(n) block \(i)") }
                ids.append(post.id)
            }

            let statements = LockIsolated<[String]>([])
            let texts = try db.read { database in
                database.trace(options: .statement) { event in
                    guard case .statement(let statement) = event else { return }
                    let sql = statement.sql
                    statements.withValue { $0.append(sql) }
                }
                return try Queries.leadingBlockTexts(database, containerIDs: ids, blocks: 4)
            }

            #expect(texts.count == 5)
            for (n, id) in ids.enumerated() {
                #expect(texts[id]?.first == "note \(n) block 0")
                #expect(texts[id]?.count == 4, "each note answers with its cap, not its length")
            }
            // Five notes, five bounded statements — 150 blocks between them.
            // (The trace also carries the read transaction's own BEGIN/COMMIT;
            // the claim is about the SELECTs.)
            let selects = statements.value.filter {
                $0.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("SELECT")
            }
            #expect(selects.count == 5,
                    "one bounded statement per note: \(selects.count) — \(statements.value)")
            #expect(selects.allSatisfy { $0.contains("LIMIT") },
                    "every statement carries the bound")
        }
    }

    // MARK: - The resolution (it must be `renderPost`'s, or the preview lies)

    /// The read-time fallback matrix (AppSpec §7), asked of the bounded read:
    /// the pointer's chosen take while it is live/active/on-the-block, else
    /// the block's default while it is live — and a gap contributes nothing.
    @Test func theBoundedReadResolvesEachSlotExactlyAsRenderPostDoes() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            // (1) plain: chosen == default
            try ops.seedBlock(in: post.id, text: "plain")
            // (2) a chosen take that is not the default
            let fanned = try ops.newBlock(in: post.id, text: "the default", registeringUndo: false)
            let take = try ops.branchVariant(fanned.block.id, from: fanned.variant.id)
            try ops.autosave(take.id, text: "the chosen take", charDelta: 4)
            try ops.chooseVariant(fanned.block.id, variantID: take.id)
            // (3) a chosen take ARCHIVED after the fact — the slot falls back
            //     to the block's default (archive hides a take from the fan,
            //     not from a slot with nothing else to show).
            let archivedSide = try ops.newBlock(
                in: post.id, text: "still the default", registeringUndo: false)
            let doomed = try ops.branchVariant(archivedSide.block.id, from: archivedSide.variant.id)
            try ops.autosave(doomed.id, text: "archived take", charDelta: 4)
            try ops.chooseVariant(archivedSide.block.id, variantID: doomed.id)
            try ops.archiveVariant(doomed.id)
            // (4) a tombstoned BLOCK under a live placement — a gap.
            // (The VX-439 ladder's R2-1 — RE-STAGED, red on old: a raw block
            // tombstone fires `cascade_block_tombstone`, which tombstones the
            // PLACEMENT too, so this leg as first written never held a gap.
            // The placement is revived after the block's tombstone — the
            // cross-batch sync state SyncSpec §5 designs for: the block's
            // tombstone landed, its placement's has not. The read decoded the
            // gap's NULL as `String` and THREW.)
            let gap = try ops.newBlock(in: post.id, text: "gone", registeringUndo: false)
            try db.write { database in
                try database.execute(
                    sql: "UPDATE block SET deleted_at = ? WHERE id = ?",
                    arguments: ["2026-09-15T00:00:00.000Z", gap.block.id])
                try database.execute(
                    sql: "UPDATE container_block SET deleted_at = NULL WHERE block_id = ?",
                    arguments: [gap.block.id])
            }
            // (5) a live block whose only take is tombstoned — a gap too
            //     (R2-1; the take's tombstone landed, its block's has not).
            let takeless = try ops.newBlock(in: post.id, text: "no take", registeringUndo: false)
            try db.write { database in
                try database.execute(
                    sql: "UPDATE variant SET deleted_at = ? WHERE id = ?",
                    arguments: ["2026-09-15T00:00:00.000Z", takeless.variant.id])
            }
            // (6) and a block after the gaps: the read goes on past them.
            try ops.seedBlock(in: post.id, text: "after the gaps")

            let livePlacements = try db.read { database in
                try Int.fetchOne(
                    database,
                    sql: "SELECT COUNT(*) FROM container_block WHERE container_id = ? AND deleted_at IS NULL",
                    arguments: [post.id]) ?? 0
            }
            #expect(livePlacements == 6, "the premise: both gaps hold a live placement — \(livePlacements)")
            let whole = try db.read { try Queries.renderPost($0, containerID: post.id) }
            let bounded = try db.read {
                try Queries.leadingBlockTexts($0, containerID: post.id, blocks: 10)
            }
            #expect(bounded == whole.compactMap(\.text),
                    "same resolution, gaps dropped the same way: \(bounded)")
            #expect(bounded == ["plain", "the chosen take", "still the default", "after the gaps"])
            // A gap still spends its slot of the bound (the read is LIMIT-stopped).
            let five = try db.read {
                try Queries.leadingBlockTexts($0, containerID: post.id, blocks: 5)
            }
            #expect(five == ["plain", "the chosen take", "still the default"], "the two gaps took slots 4 and 5")
        }
    }

    /// Degenerate asks answer honestly rather than throwing: zero blocks is
    /// nothing, an unknown note is nothing, and a note with no live
    /// placements is absent from the many-note answer.
    @Test func degenerateAsksAnswerEmpty() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            try ops.seedBlock(in: post.id, text: "one")
            let empty = try ops.createPost(title: "nothing in it")

            try db.read { database in
                #expect(try Queries.leadingBlockTexts(
                    database, containerID: post.id, blocks: 0).isEmpty)
                #expect(try Queries.leadingBlockTexts(
                    database, containerID: "no-such-note", blocks: 4).isEmpty)
                #expect(try Queries.leadingBlockTexts(
                    database, containerID: empty.id, blocks: 4).isEmpty)
                let many = try Queries.leadingBlockTexts(
                    database, containerIDs: [post.id, empty.id, post.id], blocks: 4)
                #expect(many[post.id] == ["one"])
                #expect(many[empty.id] == [], "a note with no live slots answers with no texts")
                #expect(many.count == 2, "a repeated id is read once")
            }
        }
    }
}
