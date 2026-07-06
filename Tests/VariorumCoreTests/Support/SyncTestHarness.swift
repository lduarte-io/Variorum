import Dependencies
import Foundation
import GRDB
@testable import VariorumCore

/// One simulated device: its own in-memory store, its own deterministic
/// dependency world (device-prefixed UUIDs so two devices never mint the
/// same ID, a device-offset clock so wall-time divergence is real — sync
/// must converge in spite of clocks, SyncSpec §9), and an engine over a
/// shared transport.
final class SyncClient {
    let db: AppDatabase
    let name: String
    private let transport: any SyncTransport
    private let uuidCounter = LockIsolated(0)
    private let tickCounter = LockIsolated(0)
    private let devicePrefix: String
    private let clockOffset: TimeInterval
    /// One generator per device, created once: its state advances across
    /// calls (WithRandomNumberGenerator locks internally), so jitter never
    /// repeats within a device but stays deterministic per seed.
    private let randomNumberGenerator: WithRandomNumberGenerator

    /// `prefix` must be exactly two hex characters (e.g. "AA", "BB") — it
    /// leads every UUID the device mints, so two devices can never collide.
    init(
        name: String, prefix: String, transport: any SyncTransport,
        clockOffset: TimeInterval = 0, seed: UInt64 = 1
    ) throws {
        precondition(prefix.count == 2 && prefix.allSatisfy(\.isHexDigit))
        self.db = try AppDatabase.inMemory()
        self.name = name
        self.devicePrefix = prefix
        self.transport = transport
        self.clockOffset = clockOffset
        self.randomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: seed))
    }

    /// Runs `body` with this device's dependency world bound.
    func with<T>(_ body: (Operations, AppDatabase) throws -> T) throws -> T {
        try withDependencies { deps in
            bind(&deps)
        } operation: {
            try body(Operations(), db)
        }
    }

    func withAsync<T>(_ body: (AppDatabase) async throws -> T) async throws -> T {
        try await withDependencies { deps in
            bind(&deps)
        } operation: {
            try await body(db)
        }
    }

    private func bind(_ deps: inout DependencyValues) {
        deps.database = db
        deps.uuid = UUIDGenerator { [devicePrefix, uuidCounter] in
            let count = uuidCounter.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return UUID(uuidString: String(
                format: "\(devicePrefix)000000-0000-4000-8000-%012d", count))!
        }
        // 2026-07-01T00:00:00Z + device offset, ticking one second per read.
        deps.date = DateGenerator { [clockOffset, tickCounter] in
            let seconds = tickCounter.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return Date(timeIntervalSince1970: 1_782_864_000 + clockOffset + Double(seconds))
        }
        deps.withRandomNumberGenerator = randomNumberGenerator
    }

    // MARK: Engine

    func engine(batchSize: Int = 200) -> SyncEngine {
        SyncEngine(transport: transport, batchSize: batchSize)
    }

    @discardableResult
    func push(batchSize: Int = 200) async throws -> SyncEngine.PushReport {
        try await withDependencies { deps in
            bind(&deps)
        } operation: {
            try await engine(batchSize: batchSize).push()
        }
    }

    @discardableResult
    func pull(batchSize: Int = 200) async throws -> SyncEngine.PullReport {
        try await withDependencies { deps in
            bind(&deps)
        } operation: {
            try await engine(batchSize: batchSize).pull()
        }
    }

    // MARK: State inspection

    func outboxCount() throws -> Int {
        try db.fetchInt("SELECT COUNT(*) FROM sync_outbox") ?? 0
    }

    func outboxContains(_ table: String, _ rowID: String) throws -> Bool {
        try db.outboxContains(table, rowID)
    }

    /// A canonical dump of every synced table — the byte-equality surface
    /// two converged devices are compared on. Local-only tables (outbox,
    /// cursors, seq bookkeeping) are deliberately absent: they are
    /// per-device machinery, not synced state.
    func syncedDump() throws -> String {
        try db.read { db in
            var lines: [String] = []
            for table in SyncSchema.tables {
                let rows = try Row.fetchAll(
                    db, sql: "SELECT * FROM \(table.name) ORDER BY \(table.primaryKey)")
                for row in rows {
                    let columns = row.map { "\($0)=\(String(describing: $1))" }.sorted()
                    lines.append("\(table.name)|\(columns.joined(separator: "|"))")
                }
            }
            return lines.joined(separator: "\n")
        }
    }
}

/// Pushes and pulls both devices until neither has dirty rows and both have
/// consumed the whole changefeed. Returns the number of rounds taken;
/// `Issue`s if the pair fails to quiesce (a divergence loop).
@discardableResult
func syncToQuiescence(
    _ a: SyncClient, _ b: SyncClient, server: FakeSyncServer,
    batchSize: Int = 200, maxRounds: Int = 12
) async throws -> Int {
    for round in 1...maxRounds {
        try await a.push(batchSize: batchSize)
        try await b.push(batchSize: batchSize)
        try await a.pull(batchSize: batchSize)
        try await b.pull(batchSize: batchSize)
        let head = await server.headSeq
        let quiet = try a.outboxCount() == 0 && b.outboxCount() == 0
            && a.db.fetchString("SELECT value FROM sync_state WHERE key = 'last_server_seq'") == String(head)
            && b.db.fetchString("SELECT value FROM sync_state WHERE key = 'last_server_seq'") == String(head)
        if quiet { return round }
    }
    throw SyncHarnessError.neverQuiesced(maxRounds: maxRounds)
}

enum SyncHarnessError: Error {
    case neverQuiesced(maxRounds: Int)
}
