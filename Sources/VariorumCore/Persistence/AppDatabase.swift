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

    // MARK: - Observation

    /// A live projection (Phase 4): re-fetches when the observed database
    /// region changes and delivers *distinct* values as an async sequence.
    /// Fetches run on GRDB's reader queues and fresh values are dispatched
    /// on the cooperative thread pool — never the main thread (P2).
    ///
    /// Region tracking is table-grained for raw-SQL projections (TEXT
    /// primary keys can't rowid-narrow), so *any* write to a tracked table
    /// re-runs the fetch — in the worst case at autosave rate (`autosave`
    /// stamps the `container` row per edit). `removeDuplicates` bounds what
    /// consumers *see*, not the re-fetch work. Two consequences, owned here
    /// (Phase 4 review finding):
    /// - **A held observation's fetch must itself be viewport-shaped** —
    ///   one container, a bounded LIMIT, a keyset page. Observing an
    ///   unbounded projection is a P1 violation waiting for a keystroke;
    ///   the `Observations.swift` wrappers are bounded accordingly
    ///   (`observeLibrary` requires a limit).
    /// - UI layers hold observations for on-screen projections only (P3) —
    ///   Phase 7+ view models own start/stop with visibility.
    public func observe<Value: Equatable & Sendable>(
        _ fetch: @escaping @Sendable (Database) throws -> Value
    ) -> AsyncValueObservation<Value> {
        ValueObservation
            .tracking(fetch)
            .removeDuplicates()
            .values(in: writer)
    }

    /// A write transaction with outbox echo suppression (SyncSpec §3): rows the
    /// sync engine applies from the server must not re-enqueue into
    /// `sync_outbox` — the originating device already shipped them. Cascade
    /// triggers stay active during apply.
    ///
    /// `_sync_applying` is a permanent local-only table (schema v1), normally
    /// empty — NOT the temp table SyncSpec §3 originally sketched, because a
    /// main-schema trigger resolves unqualified names in its own schema and can
    /// never see a temp table. The flag row lives only inside this transaction;
    /// a rollback unwinds it too.
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
