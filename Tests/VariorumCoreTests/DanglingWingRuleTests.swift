//
//  DanglingWingRuleTests.swift
//  VariorumCoreTests
//
//  VX-892 (the VX-912 run, batch B2 — `notes/plans/fixes/vx-912-open-source-
//  gating.md`, "## B2 record") — THE ONE DANGLING-WING RULE the two readers
//  now share (`Queries.effectiveWingID` and its projection `effectiveWingSQL`),
//  and the P1 shape of `liveTagIDs`' new probe set (a loose index scan over
//  `uq_tag_path_live` — ∝ the wings, never the vocabulary). A product row: the
//  API is new, so the suite does not compile on the pre-fix tree; the readers'
//  red-on-old pins are `DanglingWingReadersTests`.
//

import Dependencies
import Foundation
import GRDB
import SQLCipher
import Testing
@testable import VariorumCore

private final class RuleInstructionCounter: @unchecked Sendable { var value = 0 }

/// Every SQLite VM instruction the connection executes while `body` runs.
private func instructions(_ db: AppDatabase, _ body: (Database) throws -> Void) throws -> Int {
    try db.read { database in
        let counter = RuleInstructionCounter()
        let context = Unmanaged.passRetained(counter).toOpaque()
        defer { Unmanaged<RuleInstructionCounter>.fromOpaque(context).release() }
        sqlite3_progress_handler(database.sqliteConnection, 1, { pointer in
            guard let pointer else { return 0 }
            Unmanaged<RuleInstructionCounter>.fromOpaque(pointer).takeUnretainedValue().value += 1
            return 0
        }, context)
        defer { sqlite3_progress_handler(database.sqliteConnection, 0, nil, nil) }
        try body(database)
        return counter.value
    }
}

/// The joined query plan of every SELECT/WITH `body` ran.
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

@Suite("VX-892 — the one dangling-wing rule")
struct DanglingWingRuleTests {
    /// The pure rule and its SQL projection agree over every class of stored
    /// pointer: Home, a live wing, a dead wing, an id no wing row carries.
    @Test func thePureRuleAndItsProjectionAgree() throws {
        try withOperations { ops, db in
            let live = try ops.createWing(name: "Live")
            let dead = try ops.createWing(name: "Dead")
            try db.write { try $0.execute(
                sql: "UPDATE wing SET deleted_at = '2026-06-30T00:00:00.000Z' WHERE id = ?", arguments: [dead.id]) }
            let absent = "0ABSENT0-0000-4000-8000-0000000000AB"
            let liveIDs = Set(try db.read { try Queries.wings($0).map(\.id) })
            #expect(liveIDs == [live.id])
            let expected = ["": "", live.id: live.id, dead.id: "", absent: ""]
            for (stored, reads) in expected {
                #expect(Queries.effectiveWingID(stored, liveWingIDs: liveIDs) == reads, "pure: \(stored)")
                let projected = try db.read { try String.fetchOne(
                    $0, sql: "SELECT \(Queries.effectiveWingSQL("v.stored")) FROM (SELECT ? AS stored) v",
                    arguments: [stored]) }
                #expect(projected == reads, "projection: \(stored)")
                #expect(Queries.effectiveWingID(stored, liveWingIDs: liveIDs)
                        == (try db.read { try Queries.wingIsLive($0, id: stored) } ? stored : ""),
                        "the listings' per-row form reads the same")
            }
        }
    }

    /// P1 — the probe set for Home and the every-wing form is a LOOSE INDEX
    /// SCAN: ×30 the vocabulary in every wing leaves the work flat (the wings
    /// alone drive it), and the plan SEARCHes `uq_tag_path_live`, never scans
    /// `tag`.
    @Test func theTagPathProbeGrowsWithTheWingsNeverTheVocabulary() throws {
        func work(tagsPerWing: Int) throws -> Int {
            try withOperations { ops, db in
                let wings: [String?] = [nil] + (try (0..<3).map { try ops.createWing(name: "w\($0)").id })
                for wing in wings {
                    _ = try ops.createTag(name: "quote", wingID: wing)
                    for n in 0..<tagsPerWing { _ = try ops.createTag(name: "t\(n)", wingID: wing) }
                }
                #expect(try db.read { try Queries.liveTagIDs($0, path: "quote", wingID: nil) }.count == 4)
                return try instructions(db) { database in
                    _ = try Queries.liveTagIDs(database, path: "quote", wingID: "")
                    _ = try Queries.liveTagIDs(database, path: "quote", wingID: nil)
                }
            }
        }
        let thin = try work(tagsPerWing: 10)
        let thick = try work(tagsPerWing: 300)
        print("VX-892 liveTagIDs VM instructions: vocabulary ×1 \(thin), ×30 \(thick)")
        #expect(Double(thick) < Double(thin) * 1.5,
                "vocabulary ×30: \(thin) → \(thick) VM instructions — the vocabulary must not drive the probe (P1)")

        try withOperations { ops, db in
            _ = try ops.createTag(name: "quote")
            let plan = try capturedPlan(db) { database in
                _ = try Queries.liveTagIDs(database, path: "quote", wingID: "")
                _ = try Queries.liveTagIDs(database, path: "quote", wingID: nil)
            }
            let scans = plan.split(separator: "\n").map(String.init).filter {
                $0 == "SCAN t" || $0.hasPrefix("SCAN t ") || $0 == "SCAN tag" || $0.hasPrefix("SCAN tag ")
            }
            #expect(scans.isEmpty, "tag scans \(scans); plan was:\n\(plan)")
            #expect(plan.contains("uq_tag_path_live"), "the seeks ride the live-path index; plan was:\n\(plan)")
        }
    }
}
