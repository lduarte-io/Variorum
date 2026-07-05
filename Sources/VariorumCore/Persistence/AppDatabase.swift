import Foundation
import GRDB

/// The database stack: the only gateway to SQLite.
///
/// Wraps a GRDB connection — a `DatabasePool` on disk (WAL, reader pool) or an
/// in-memory `DatabaseQueue` for tests. Nothing outside this type ever holds a
/// raw connection: all access flows through `read`/`write`/`applyingRemote`,
/// which is the one choke point that keeps P2 (no main-thread DB I/O; reads
/// never block writes) enforceable.
public struct AppDatabase: Sendable {
    /// Private on purpose: operations/queries reach SQLite through the methods
    /// below, never through the connection itself.
    private let writer: any DatabaseWriter

    private init(_ writer: any DatabaseWriter) throws {
        self.writer = writer
        try AppDatabase.migrator.migrate(writer)
    }

    // MARK: - Factories

    /// The canonical on-disk store (WAL journal, reader pool).
    public static func onDisk(url: URL) throws -> AppDatabase {
        try AppDatabase(DatabasePool(path: url.path, configuration: configuration()))
    }

    /// A private in-memory store, for tests.
    public static func inMemory() throws -> AppDatabase {
        try AppDatabase(DatabaseQueue(configuration: configuration()))
    }

    private static func configuration() -> Configuration {
        var config = Configuration()
        // Explicit even though it is GRDB's default: FK enforcement is an
        // invariant backstop (AppSpec §6), never an accident of configuration.
        config.foreignKeysEnabled = true
        config.busyMode = .timeout(5)
        config.prepareDatabase { db in
            // The `_sync_applying` flag table (SyncSpec §3): outbox triggers
            // skip enqueueing while it holds a row. Triggers reference it, so
            // it must exist on every connection — created here, empty, at
            // connect time. `applyingRemote` populates it for the span of one
            // apply transaction; the Phase 5 sync engine is its only client.
            try db.execute(sql: "CREATE TEMP TABLE IF NOT EXISTS _sync_applying (applying INTEGER NOT NULL)")
        }
        return config
    }

    // MARK: - Access

    public func read<T>(_ value: (Database) throws -> T) throws -> T {
        try writer.read(value)
    }

    public func read<T: Sendable>(_ value: @Sendable @escaping (Database) throws -> T) async throws -> T {
        try await writer.read(value)
    }

    public func write<T>(_ updates: (Database) throws -> T) throws -> T {
        try writer.write(updates)
    }

    public func write<T: Sendable>(_ updates: @Sendable @escaping (Database) throws -> T) async throws -> T {
        try await writer.write(updates)
    }

    /// A write transaction with outbox echo suppression (SyncSpec §3): rows the
    /// sync engine applies from the server must not re-enqueue into
    /// `sync_outbox` — the originating device already shipped them. Cascade
    /// triggers stay active during apply. The flag lives only for this
    /// transaction; a rollback unwinds the flag row too (temp tables are
    /// transactional).
    public func applyingRemote<T>(_ updates: (Database) throws -> T) throws -> T {
        try writer.write { db in
            try db.execute(sql: "INSERT INTO _sync_applying (applying) VALUES (1)")
            do {
                let result = try updates(db)
                try db.execute(sql: "DELETE FROM _sync_applying")
                return result
            } catch {
                // The transaction is about to roll back, which also unwinds the
                // flag row; the explicit DELETE just guarantees the flag never
                // outlives the body on any path.
                try? db.execute(sql: "DELETE FROM _sync_applying")
                throw error
            }
        }
    }
}
