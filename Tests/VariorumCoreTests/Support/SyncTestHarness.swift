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
    /// The integration pass (real Supabase) opts in: the server is stateful
    /// across runs, so the deterministic prefixed counter UUIDs below would
    /// CAS-collide with rows a previous run pushed. Random v4 IDs make every
    /// run's rows fresh; convergence assertions never depend on ID values.
    private let mintsRandomUUIDs: Bool
    /// One generator per device, created once: its state advances across
    /// calls (WithRandomNumberGenerator locks internally), so jitter never
    /// repeats within a device but stays deterministic per seed.
    private let randomNumberGenerator: WithRandomNumberGenerator
    /// The device's signed-in owner (Phase 9c). Phase 14c changed the
    /// default from nil (signed out — the pre-9c modeling convenience) to
    /// the fake server's default account: the born-multi-tenant mirror
    /// refuses unowned pushes on the owner-carrying tables, and
    /// post-14c a syncing device is ALWAYS signed in (the transport
    /// requires a session; adoption ran at 9c). Mutable so a scenario can
    /// model signed-out or a different account — the next `with`/engine
    /// call binds it.
    var ownerID: String? = FakeSyncServer.defaultUserID
    /// The device's E2EE key provider (Phase 14b): the suite default is the
    /// shared test key world, so EVERY scenario runs over ciphertext — the
    /// crown assertion. Mutable so a scenario can model a locked/unenrolled
    /// device (`LockedSyncKeyProvider`) mid-life; the next engine call
    /// binds it.
    var keyProvider: any SyncKeyProviding = FixedSyncKeyProvider()
    /// VX-314: the account-binding gate's injected facts — nil by default,
    /// exactly like production's today-road (the gate inert). Mutable so a
    /// scenario models a mismatched sign-in; the next engine call binds it.
    var accountBinding: SyncAccountBinding?
    /// pre-13x 1a: THIS DEVICE'S IDENTITY — the custody item's in
    /// production, the client's own here, riding whatever key world the
    /// client holds (`engine()` wraps it). Mutable so a scenario can model
    /// a RE-MINTED identity (a wiped Keychain — §14.37's returner).
    var deviceID: String = UUID().uuidString.lowercased()
    /// The sample-library dedupe's injected facts (pre-13u Act 0) — nil by
    /// default, exactly like production: the repair is inert unless a
    /// scenario wires facts in. Mutable so a scenario binds it; the next
    /// engine call carries it.
    var sampleLibraryFacts: SampleLibraryDedupeFacts?
    /// pre-13x 5a: the engine takes a LIST of facts (one per seeded book);
    /// the single above stays so every pre-5a scenario rides unmodified, and
    /// a scenario with a SECOND book appends here — `engine()` composes the
    /// two into the list exactly as `SyncSession.configure` hands both.
    var additionalSampleLibraryFacts: [SampleLibraryDedupeFacts] = []
    /// 17y B-DEDUPE: the seeded-furniture fold's facts — nil by default,
    /// exactly like production's unwired engine (inert).
    var furnitureFacts: SeededFurnitureDedupeFacts?

    /// `prefix` must be exactly two hex characters (e.g. "AA", "BB") — it
    /// leads every UUID the device mints, so two devices can never collide.
    ///
    /// `storeURL` (Phase 13l, Act 4 — the restore matrix): an ON-DISK store
    /// instead of the in-memory default. That is what makes a RESTORED
    /// device modelable without wall-clock tricks or hand-rolled snapshots:
    /// take a real `AppDatabase.backup(to:)` of a converged device, copy the
    /// file, and open a client on the copy. The restored client then carries
    /// the backup's rows, its cursor and its outbox — and, since pre-13x 1a,
    /// NOT an identity: a copy of the library is writing, never a device
    /// (the identity rides the sync-key custody item), so a restored client
    /// is a NEW device with a fresh `deviceID` (M7's flipped premise).
    ///
    /// Give a restored client its OWN `prefix`: the UUID counter restarts at
    /// zero, so reusing the source device's prefix would mint ids it already
    /// minted before the backup. Nothing in sync keys on the prefix.
    ///
    /// `custody` (Phase 13p, ladder R1-m6 — the keyed convergence pass):
    /// explicit per-client key custody for an on-disk store, so two
    /// simulated devices can each hold their OWN store key (R13p-4's
    /// per-store key) instead of sharing the ambient process-ephemeral
    /// test key. nil keeps the ambient default.
    init(
        name: String, prefix: String, transport: any SyncTransport,
        clockOffset: TimeInterval = 0, seed: UInt64 = 1, mintsRandomUUIDs: Bool = false,
        storeURL: URL? = nil, custody: StoreKeyCustody? = nil
    ) throws {
        precondition(prefix.count == 2 && prefix.allSatisfy(\.isHexDigit))
        self.db = try storeURL.map { try AppDatabase.openStore(at: $0, custody: custody) }
            ?? AppDatabase.inMemory()
        self.name = name
        self.devicePrefix = prefix
        self.mintsRandomUUIDs = mintsRandomUUIDs
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
        deps.uuid = mintsRandomUUIDs
            ? UUIDGenerator { UUID() }
            : UUIDGenerator { [devicePrefix, uuidCounter] in
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
        deps.ownerIdentity = OwnerIdentity { [owner = ownerID] in owner }
    }

    // MARK: Engine

    /// VX-494: the harness keeps ONE size for both directions (`pullWindowSize: batchSize`) so every scenario's
    /// window count — the soaks randomize it — is exactly what it was before the pull window got its own size;
    /// the production default is pinned by `ResumableCatchUpTests`.
    func engine(batchSize: Int = 200, maxPushIterations: Int = 5) -> SyncEngine {
        SyncEngine(
            transport: transport, batchSize: batchSize, pullWindowSize: batchSize,
            maxPushIterations: maxPushIterations,
            keyProvider: ClientIdentityKeyProvider(inner: keyProvider, deviceID: deviceID),
            sampleLibraryFacts: (sampleLibraryFacts.map { [$0] } ?? []) + additionalSampleLibraryFacts,
            furnitureFacts: furnitureFacts,
            accountBinding: accountBinding)
    }

    @discardableResult
    func push(batchSize: Int = 200, maxIterations: Int = 5) async throws -> SyncEngine.PushReport {
        try await withDependencies { deps in
            bind(&deps)
        } operation: {
            try await engine(batchSize: batchSize, maxPushIterations: maxIterations).push()
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

    /// pre-13x 2b: the engine's named primitive (§4 step 1).
    @discardableResult
    func pullToHead(batchSize: Int = 200, maxAttempts: Int = 6) async throws -> SyncEngine.PullReport {
        try await withDependencies { deps in
            bind(&deps)
        } operation: {
            try await engine(batchSize: batchSize).pullToHead(maxAttempts: maxAttempts)
        }
    }

    /// pre-13x 2b: the engine's outbox count (hoisted from the scheduler).
    func engineOutboxCount() async throws -> Int {
        try await withDependencies { deps in
            bind(&deps)
        } operation: {
            try await engine().outboxCount()
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
    /// cursors, seq bookkeeping) AND local-only columns
    /// (`reference.file_bookmark`) are deliberately absent: per-device
    /// machinery and per-machine data are not synced state.
    func syncedDump() throws -> String {
        try db.read { db in
            var lines: [String] = []
            for table in SyncSchema.tables {
                let rows = try Row.fetchAll(
                    db, sql: "SELECT * FROM \(table.name) ORDER BY \(table.primaryKey)")
                for row in rows {
                    let columns = row.compactMap { name, value in
                        table.excludedColumns.contains(name)
                            ? nil : "\(name)=\(String(describing: value))"
                    }.sorted()
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
        // 13y: heads are per-account — quiescence compares one FLEET's
        // cursors against ITS OWN account's head (the pair is always one
        // account's two devices).
        let head = await server.headSeq(for: a.ownerID ?? FakeSyncServer.defaultUserID)
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

/// Phase 13l, Act 4 — a scratch folder plus the two file moves a restore
/// actually is. Deliberately thin: the point of the restore matrix is that
/// "restored" means *these bytes, from that moment*, not a fixture that
/// approximates one.
struct RestoreScratch {
    let directory: URL

    init() throws {
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-restore-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    func url(_ name: String) -> URL { directory.appendingPathComponent(name) }

    func cleanUp() { try? FileManager.default.removeItem(at: directory) }

    /// One consistent snapshot through the SAME door the app's scheduler
    /// uses (`AppDatabase.backup(to:)` — SQLite's backup API, WAL-safe).
    func snapshot(_ client: SyncClient, as name: String) throws -> URL {
        let url = self.url(name)
        try client.db.backup(to: url)
        return url
    }

    /// THE RESTORE: put a snapshot's bytes somewhere and open a client on
    /// them. The source device stays alive on its own file — the tests then
    /// simply stop using it, which is what "this store was replaced" means.
    func restore(
        _ snapshot: URL, as name: String, prefix: String,
        transport: any SyncTransport, clockOffset: TimeInterval = 0, seed: UInt64 = 9
    ) throws -> SyncClient {
        let url = self.url("\(name).sqlite")
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
        try FileManager.default.copyItem(at: snapshot, to: url)
        return try SyncClient(
            name: name, prefix: prefix, transport: transport,
            clockOffset: clockOffset, seed: seed, storeURL: url)
    }
}

extension SyncClient {
    /// pre-13x 1a: a backup carries NO identity — this is what the STORE
    /// holds under the retired key (always nil now; pinned).
    func storedDeviceID() throws -> String? {
        try db.fetchString("SELECT value FROM sync_state WHERE key = 'device_id'")
    }

    func cursor() throws -> Int64 {
        Int64(try db.fetchString("SELECT value FROM sync_state WHERE key = 'last_server_seq'") ?? "0") ?? 0
    }
}
