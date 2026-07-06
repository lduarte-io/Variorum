import Dependencies
import Foundation
import GRDB
@testable import VariorumCore

/// Runs `body` against a fresh in-memory database with deterministic
/// dependencies: incrementing UUIDs, a clock that advances one second per
/// read (so `updated_at` movement is observable and successive operations
/// get distinct timestamps), and a seeded RNG for position jitter.
func withOperations<T>(
    seed: UInt64 = 1,
    _ body: (Operations, AppDatabase) throws -> T
) throws -> T {
    let db = try AppDatabase.inMemory()
    // 2026-07-01T00:00:00Z, ticking forward one second per read.
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: seed))
    } operation: {
        try body(Operations(), db)
    }
}

/// The async twin of `withOperations`, for observation tests that await
/// emissions between operations. Same deterministic world.
func withOperationsAsync<T>(
    seed: UInt64 = 1,
    _ body: (Operations, AppDatabase) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: seed))
    } operation: {
        try await body(Operations(), db)
    }
}

// MARK: - Row-level assertions

extension AppDatabase {
    func fetchString(_ sql: String, _ arguments: [(any DatabaseValueConvertible)?] = []) throws -> String? {
        try read { db in
            try String.fetchOne(db, sql: sql, arguments: StatementArguments(arguments))
        }
    }

    func fetchInt(_ sql: String, _ arguments: [(any DatabaseValueConvertible)?] = []) throws -> Int? {
        try read { db in
            try Int.fetchOne(db, sql: sql, arguments: StatementArguments(arguments))
        }
    }

    func deletedAt(_ table: String, _ id: String) throws -> String? {
        try fetchString("SELECT deleted_at FROM \(table) WHERE id = ?", [id])
    }

    func outboxContains(_ table: String, _ id: String) throws -> Bool {
        try fetchInt(
            "SELECT COUNT(*) FROM sync_outbox WHERE table_name = ? AND row_id = ?",
            [table, id]) == 1
    }

    func clearOutbox() throws {
        try write { db in try db.execute(sql: "DELETE FROM sync_outbox") }
    }

    /// Full row snapshot for exact-inverse assertions, minus the columns
    /// undo is allowed to disturb (`updated_at` by default).
    func snapshotRow(
        _ table: String, _ id: String, excluding: Set<String> = ["updated_at"]
    ) throws -> [String: DatabaseValue]? {
        try read { db in
            guard let row = try Row.fetchOne(
                db, sql: "SELECT * FROM \(table) WHERE id = ?", arguments: [id])
            else { return nil }
            var snapshot: [String: DatabaseValue] = [:]
            for (column, value) in row where !excluding.contains(column) {
                snapshot[column] = value
            }
            return snapshot
        }
    }
}
