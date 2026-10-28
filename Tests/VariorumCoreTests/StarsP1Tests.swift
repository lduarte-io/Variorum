//
//  StarsP1Tests.swift
//  VariorumCoreTests
//
//  VX-643 (VX-648 batch 3) — the P1 CHECK the ticket owes with the cap's
//  retirement: "stars are one synced `setting` row (a JSON array of ids,
//  PLAIN, CAS); reading it is ∝ the stars, never the corpus (P1)."
//
//  Until VX-643 every star read's cost note said "bounded by the cap
//  (`Operations.starLimit`)". With the cap gone the bound is the stars she
//  keeps — her own deliberate list, the Open list's class — so these pins say
//  what the read DOES cost: SQLite's own work counter flat as the corpus grows
//  tenfold under a fixed star count, and the statements PK seeks (no scan of
//  the notes table). A GUARD, green on both sides of the retirement by design
//  (the read side never consulted the cap): the stars are written straight
//  into the setting row so the fixture is the same on either tree.
//
//  SHAPE pins (plans and VM steps), never timings — `TrayBadgeP1Tests`' and
//  `ReadLayerP1Tests`' discipline.
//

import Dependencies
import Foundation
import GRDB
import SQLCipher
import Testing

@testable import VariorumCore

/// Every SELECT `body` ran, as SQLite expanded it.
private func capturedSelects(
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
private func plan(_ db: AppDatabase, _ body: (Database) throws -> Void) throws -> String {
    let statements = try capturedSelects(db, body)
    return try db.read { database in
        try statements.flatMap { sql in
            try Row.fetchAll(database, sql: "EXPLAIN QUERY PLAN \(sql)")
                .map { ($0["detail"] as String?) ?? "" }
        }.joined(separator: "\n")
    }
}

/// `SQLITE_STMTSTATUS_VM_STEP` summed over every SELECT `body` ran.
private func vmSteps(_ db: AppDatabase, _ body: (Database) throws -> Void) throws -> Int {
    let statements = try capturedSelects(db, body)
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

@Suite("VX-643 — reading the stars costs the stars, never the corpus (P1)")
struct StarsP1Tests {
    /// A library of `notes` notes with the first `stars` of them starred —
    /// written into the one setting row directly, in star order.
    private func world(
        notes: Int, stars: Int, _ body: (AppDatabase) throws -> Void
    ) throws {
        try withOperations { ops, db in
            var ids: [String] = []
            for index in 0..<notes {
                ids.append(try ops.createPost(title: "n\(index)", profile: .generic).id)
            }
            let keys = ids.prefix(stars).map { StarTarget.post($0).key }
            let json = String(decoding: try JSONEncoder().encode(Array(keys)), as: UTF8.self)
            try db.write { database in
                try database.execute(
                    sql: "INSERT OR REPLACE INTO setting (key, value) VALUES ('starred', ?)",
                    arguments: [json])
            }
            #expect(try db.read { try Queries.starred($0) }.count == stars, "the fixture's stars read back")
            try body(db)
        }
    }

    /// The union read (`Queries.starred`) and the sidebar's wing-scoped read
    /// (`Queries.starred(_:wingID:)`) at thirty stars — twice the old cap —
    /// over a library ten times larger: the work is the same, and every lookup
    /// of a starred note is a seek BY ID.
    ///
    /// **RED ON OLD — the check's finding (the batch record's "VX-643 — THE P1
    /// CHECK"):** the list half's `WHERE id IN (…) AND kind = 'post'` let the
    /// planner take `idx_container_kind (kind=?)` — a walk of EVERY note in the
    /// library — over the primary key, so the read the Starred faces HOLD
    /// (re-run on the writer after every autosave, VX-647's amplifier) grew with
    /// the corpus: 941 → 6,881 VM steps at notes ×10, cap or no cap.
    @Test func theStarReadsAreFlatInTheCorpus() throws {
        func steps(notes: Int) throws -> (union: Int, wing: Int) {
            var result = (union: 0, wing: 0)
            try world(notes: notes, stars: 30) { db in
                result.union = try vmSteps(db) { _ = try Queries.starred($0) }
                result.wing = try vmSteps(db) { _ = try Queries.starred($0, wingID: "") }
                let shape = try plan(db) {
                    _ = try Queries.starred($0)
                    _ = try Queries.starred($0, wingID: "")
                }
                let containerLines = shape.split(separator: "\n").map(String.init)
                    .filter { $0.contains("container") }
                let byIDOnly = !containerLines.isEmpty && containerLines.allSatisfy { $0.contains("(id=?)") }
                #expect(byIDOnly,
                        "every starred note is sought by its id, never through the notes at large:\n\(shape)")
            }
            return result
        }
        let small = try steps(notes: 60)
        let large = try steps(notes: 600)
        print("VX-643 star-read VM steps (30 stars): union \(small.union) → \(large.union), wing \(small.wing) → \(large.wing) at notes ×10")
        #expect(Double(large.union) < Double(small.union) * 1.5,
                "union: \(small.union) → \(large.union) VM steps — the corpus must not drive it (P1)")
        #expect(Double(large.wing) < Double(small.wing) * 1.5,
                "wing: \(small.wing) → \(large.wing) VM steps — the corpus must not drive it (P1)")
    }

    /// …and the honest other half: the cost follows the STARS (her own list),
    /// so doubling them roughly doubles the work — bounded by what she keeps,
    /// as the Open list is.
    @Test func theStarReadsFollowTheStars() throws {
        func steps(stars: Int) throws -> Int {
            var result = 0
            try world(notes: 200, stars: stars) { db in
                result = try vmSteps(db) { _ = try Queries.starred($0, wingID: "") }
            }
            return result
        }
        let thirty = try steps(stars: 30)
        let sixty = try steps(stars: 60)
        print("VX-643 wing star-read VM steps: 30 stars \(thirty), 60 stars \(sixty)")
        #expect(sixty > thirty, "more stars, more work — the stars are the bound")
        #expect(Double(sixty) < Double(thirty) * 2.5, "linear in the stars: \(thirty) → \(sixty)")
    }
}
