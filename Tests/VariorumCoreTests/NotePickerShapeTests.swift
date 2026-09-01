//
//  NotePickerShapeTests.swift
//  VariorumCoreTests
//
//  The pre-13u ladder's F7 — `Queries.notePickerNotes(query:)` was
//  corpus-shaped on a keystroke road: the snippet is a correlated subquery
//  in the SELECT list, and SQLite evaluates SELECT-list subqueries for every
//  row that passes WHERE BEFORE the sorter applies LIMIT, so every live note
//  paid a placement + variant seek per keystroke in the picker. The fix
//  selects the bounded id set in a CTE first and computes snippets for those
//  rows only.
//
//  The pin is a SHAPE fact, 17c's standard (`ReadLayerP1Tests`): not a
//  timing, but SQLite's own deterministic statement counters, read through
//  `sqlite3_stmt_status` on the very statement the query ran. A counter
//  cannot flip with machine load.
//

import Dependencies
import Foundation
import GRDB
import SQLCipher
import Testing

@testable import VariorumCore

/// `sqlite3_stmt_status` from the SQLite GRDB actually links (the SQLCipher
/// build its fork carries) — imported as that module, so the header and the
/// linked library agree. (A `dlsym(RTLD_DEFAULT)` probe resolved to the
/// SYSTEM libsqlite3 Foundation links, which read a foreign statement
/// struct as zeros — the interposition hazard, observed.)
private enum StatementStatus {
    static let vmStep = SQLITE_STMTSTATUS_VM_STEP
    static let sort = SQLITE_STMTSTATUS_SORT

    static func read(_ statement: Statement, _ counter: Int32) -> Int {
        Int(sqlite3_stmt_status(statement.sqliteStatement, counter, 0))
    }
}

/// The expanded SQL of every statement `body` ran (the `ReadLayerP1Tests`
/// capture, kept private here for the same reason it is private there).
private func captureStatements(
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
        return captured.value
    }
}

/// Re-runs one captured statement verbatim and reads its counters.
private func counters(
    _ db: AppDatabase, sql: String
) throws -> (vmSteps: Int, sorts: Int, rows: Int) {
    try db.read { database in
        let statement = try database.makeStatement(sql: sql)
        let rows = try Row.fetchAll(statement)
        return (StatementStatus.read(statement, StatementStatus.vmStep),
                StatementStatus.read(statement, StatementStatus.sort),
                rows.count)
    }
}

@Suite("The note picker's shape (the ladder's F7)")
struct NotePickerShapeTests {
    /// A corpus of `count` live notes, each with one block of body text.
    private func corpus(_ ops: Operations, count: Int) throws {
        for index in 0..<count {
            let post = try ops.createPost(title: "note \(index)")
            _ = try ops.newBlock(in: post.id, text: "body of note \(index), first words")
        }
    }

    private func pickerCounters(
        _ db: AppDatabase, limit: Int
    ) throws -> (vmSteps: Int, sorts: Int, rows: Int) {
        let statements = try captureStatements(db) { database in
            _ = try Queries.notePickerNotes(database, query: "", limit: limit)
        }
        #expect(statements.count == 1, "the picker is ONE statement")
        return try counters(db, sql: statements[0])
    }

    /// **RED ON OLD:** the SORT counter counts the snippet subquery's own
    /// `ORDER BY cb.position, cb.id LIMIT 1` once per evaluation. Old code
    /// evaluated it for every live note (sorts ∝ corpus); the CTE evaluates
    /// it for at most `limit` rows (sorts flat in corpus size).
    @Test func snippetWorkIsBoundedByTheLimitNotTheCorpus() throws {
        let small = try withOperations { ops, db -> (vmSteps: Int, sorts: Int, rows: Int) in
            try corpus(ops, count: 60)
            return try pickerCounters(db, limit: 30)
        }
        let large = try withOperations { ops, db -> (vmSteps: Int, sorts: Int, rows: Int) in
            try corpus(ops, count: 120)
            return try pickerCounters(db, limit: 30)
        }
        // Measured at the fix (SQLCipher 4.18.0 / the fork's SQLite), so the
        // next reader knows what "flat" and "corpus-shaped" looked like:
        //   NEW  60 notes: 31 sorts, 3,262 VM steps · 120 notes: 31 sorts, 4,582 VM steps
        //   OLD  60 notes: 61 sorts, 4,607 VM steps · 120 notes: 121 sorts, 9,047 VM steps
        // — the old statement sorted once per LIVE NOTE (1 + N) and stepped
        // ~74 ops per note; the CTE sorts 1 + limit and steps ~22 per note,
        // which is the title/day scan itself, the inherent cost of a
        // substring search.
        #expect(small.rows == 30 && large.rows == 30)
        #expect(large.sorts == small.sorts,
                "snippet evaluations must not grow with the corpus (60 notes: \(small.sorts) sorts, 120: \(large.sorts))")
        #expect(large.vmSteps > small.vmSteps,
                "positive activity: the larger corpus was actually scanned")
    }
}
