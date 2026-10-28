//
//  VX653LineageProbeTests.swift
//  VariorumCoreTests
//
//  VX-653 / VX-654 (VX-678 run, Unit 2) — the MEASUREMENT PROBE, not a pin.
//  Gated: runs only with `VX653_PROBE=1` in the environment.
//
//  Scratch stage: VM-step growth of the two lineage reads over a note's
//  SEAM history (⏎ mid-paragraph = divide, ⌫ at the seam = merge).
//

import Dependencies
import Foundation
import GRDB
import SQLCipher
import Testing

@testable import VariorumCore

private let probeEnabled = ProcessInfo.processInfo.environment["VX653_PROBE"] == "1"

private final class Counter: @unchecked Sendable { var value = 0 }

/// Every VM instruction the connection executes while `body` runs.
private func instructions(_ db: Database, _ body: () throws -> Void) throws -> Int {
    let counter = Counter()
    let context = Unmanaged.passRetained(counter).toOpaque()
    defer { Unmanaged<Counter>.fromOpaque(context).release() }
    sqlite3_progress_handler(db.sqliteConnection, 1, { pointer in
        guard let pointer else { return 0 }
        Unmanaged<Counter>.fromOpaque(pointer).takeUnretainedValue().value += 1
        return 0
    }, context)
    defer { sqlite3_progress_handler(db.sqliteConnection, 0, nil, nil) }
    try body()
    return counter.value
}

/// The pre-VX-654 body, verbatim.
private func legacyStranded(_ db: Database, blockIDs: [String]) throws -> [String] {
    guard !blockIDs.isEmpty else { return [] }
    let placeholders = Queries.databaseQuestionMarks(count: blockIDs.count)
    return try String.fetchAll(
        db,
        sql: """
            WITH RECURSIVE anc(id) AS (
              SELECT e.target_block_id FROM edge e
              WHERE e.source_block_id IN (\(placeholders))
                AND e.type = 'derived_from'
              UNION
              SELECT e.target_block_id FROM edge e
              JOIN anc a ON e.source_block_id = a.id
              WHERE e.type = 'derived_from'
            ),
            fam(origin, id) AS (
              SELECT a.id, e.source_block_id FROM anc a
              JOIN edge e ON e.target_block_id = a.id AND e.type = 'derived_from'
              UNION
              SELECT f.origin, e.source_block_id FROM fam f
              JOIN edge e ON e.target_block_id = f.id AND e.type = 'derived_from'
            )
            SELECT f.origin FROM fam f
            JOIN block d ON d.id = f.id
            JOIN block o ON o.id = f.origin
            WHERE o.deleted_at IS NULL AND o.archived_at IS NULL
              AND NOT EXISTS (
                SELECT 1 FROM container_block placed
                WHERE placed.block_id = o.id AND placed.deleted_at IS NULL)
            GROUP BY f.origin
            HAVING SUM(CASE WHEN d.deleted_at IS NULL THEN 1 ELSE 0 END) = 0
            """,
        arguments: StatementArguments(blockIDs))
}

/// The candidate rewrite.
private func candidateStranded(_ db: Database, blockIDs: [String]) throws -> [String] {
    guard !blockIDs.isEmpty else { return [] }
    let placeholders = Queries.databaseQuestionMarks(count: blockIDs.count)
    return try String.fetchAll(
        db,
        sql: """
            WITH RECURSIVE anc(id) AS (
              SELECT e.target_block_id FROM edge e
              WHERE e.source_block_id IN (\(placeholders))
                AND e.type = 'derived_from'
              UNION
              SELECT e.target_block_id FROM edge e
              JOIN anc a ON e.source_block_id = a.id
              WHERE e.type = 'derived_from'
            ),
            cand(id) AS (
              SELECT o.id FROM anc a
              JOIN block o ON o.id = a.id
              WHERE o.deleted_at IS NULL AND o.archived_at IS NULL
                AND NOT EXISTS (
                  SELECT 1 FROM container_block placed
                  WHERE placed.block_id = o.id AND placed.deleted_at IS NULL)
            ),
            nb(id) AS (
              SELECT e.source_block_id FROM cand c
              JOIN edge e ON e.target_block_id = c.id AND e.type = 'derived_from'
              UNION
              SELECT e.source_block_id FROM nb n
              JOIN edge e ON e.target_block_id = n.id AND e.type = 'derived_from'
            ),
            scope(id) AS (SELECT id FROM nb UNION SELECT id FROM cand),
            up(id, live) AS (
              SELECT e.target_block_id, d.deleted_at IS NULL FROM nb n
              JOIN block d ON d.id = n.id
              JOIN edge e ON e.source_block_id = n.id AND e.type = 'derived_from'
              WHERE e.target_block_id IN (SELECT id FROM scope)
              UNION
              SELECT e.target_block_id, u.live FROM up u
              JOIN edge e ON e.source_block_id = u.id AND e.type = 'derived_from'
              WHERE e.target_block_id IN (SELECT id FROM scope)
            )
            SELECT u.id FROM up u
            WHERE u.id IN (SELECT id FROM cand)
            GROUP BY u.id
            HAVING MAX(u.live) = 0
            ORDER BY u.id
            """,
        arguments: StatementArguments(blockIDs))
}

@Suite("VX-653/654 — lineage read probe (scratch)", .enabled(if: probeEnabled), .serialized)
struct VX653LineageProbeScratchTests {
    @Test func vmStepGrowth() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note")
            var live: [String] = []
            for b in 0..<20 {
                live.append(try ops.seedBlock(in: note.id, text: "Paragraph \(b) has some words. And a second sentence here.").block.id)
            }
            var seam = live[10]
            var done = 0
            for target in [25, 50, 100, 200] {
                for _ in done..<target {
                    let d = try ops.divide(seam, cut: 24)
                    seam = try ops.merge(seam, d.block.id, joining: .deleteKeystroke).block.id
                }
                done = target
                try ops.deleteBlock(seam)
                let (counts, rows) = try db.read { d in
                    var old: [String] = [], new: [String] = []
                    let c = [
                        try instructions(d) { old = try legacyStranded(d, blockIDs: [seam]) },
                        try instructions(d) { new = try candidateStranded(d, blockIDs: [seam]) },
                    ]
                    return (c, (old, new))
                }
                _ = try ops.restoreBlock(seam)
                print("VX653 scratch R=\(target) stranded old=\(counts[0]) new=\(counts[1]) rowsOld=\(rows.0) rowsNew=\(rows.1) equal=\(rows.0 == rows.1)")
            }
        }
    }
}
