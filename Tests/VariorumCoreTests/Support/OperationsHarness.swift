import Dependencies
import Foundation
import GRDB
@testable import VariorumCore

/// Runs `body` against a fresh in-memory database with deterministic
/// dependencies: incrementing UUIDs, a clock that advances one second per
/// read (so `updated_at` movement is observable and successive operations
/// get distinct timestamps), and a seeded RNG for position jitter.
/// **The harness world's "now"** (13j): the recovery queries take a required
/// clock, because the 30-day Trash window is what "in the Trash" means. The
/// fixtures here are stamped from 2026-07-01 and tick forward by seconds, so
/// a listing asked as of this moment sees everything the test just deleted —
/// and a test that wants the OTHER side of the window says so by passing its
/// own date (`harnessNow.addingTimeInterval(31 * 86_400)`).
let harnessNow = Date(timeIntervalSince1970: 1_782_864_000 + 3_600)

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

// MARK: - Fixture seeding (13u1 UNIT 2)

extension Operations {
    /// **A FIXTURE MINT IS NOT A GESTURE.** `newBlock` joined AppSpec §9's
    /// structural-undo list at the author's ruling R-13u-3 (13u1 UNIT 2), so
    /// every mint now registers an entry — which is right for the doors she
    /// presses and wrong for the blocks a test seeds before the act it is
    /// actually about. A suite that counts `stack.depth` after building a
    /// three-block note is asserting something about the OPERATION under
    /// test, not about how its fixture came to exist.
    ///
    /// So the suites seed through here, with the same `registeringUndo:
    /// false` the type-time crystallizers use and for the same stated
    /// reason. Every depth assertion in those suites therefore reads exactly
    /// as it did before the ruling — the zero-test-edit standard applied to
    /// the numbers rather than to the lines.
    @discardableResult
    func seedBlock(
        in containerID: String, text: String, at insert: InsertPosition = .end
    ) throws -> NewBlockResult {
        try newBlock(in: containerID, text: text, at: insert, registeringUndo: false)
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
