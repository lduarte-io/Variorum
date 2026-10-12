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
    /// How this value reaches its connection (Phase 13p Batch 2 — the
    /// re-lock design). `.direct` is every constructed store: the writer
    /// and key ride the value, exactly as before Batch 2. `.bound` is the
    /// app's AMBIENT view (`asRebindable()`): the connection lives in a
    /// `StoreBinding` the composition root can LOCK (close the pool, drop
    /// the key) and later re-point at a freshly opened store — which is
    /// what lets every ambient holder (`@Dependency(\.database)` in
    /// Operations, the sync engine, the janitor) survive a re-lock without
    /// a single line of their own changing: their next access resolves
    /// through the binding.
    enum Storage: Sendable {
        case direct(any DatabaseWriter, StoreKey?)
        case bound(StoreBinding)
    }

    /// Internal (not private) so `StoreBinding.adopt` — same module, its
    /// own file — can take a directly-opened store's parts.
    let storage: Storage

    private init(_ writer: any DatabaseWriter, key: StoreKey? = nil) throws {
        storage = .direct(writer, key)
        try AppDatabase.migrator.migrate(writer)
    }

    /// The bound view — no migration (the wrapped store already ran it).
    init(bound binding: StoreBinding) {
        storage = .bound(binding)
    }

    /// The connection, resolved per access. Throws `StoreLockedError`
    /// while a bound store is locked — an access racing a re-lock gets a
    /// typed refusal, never a crash and never a stale pool.
    private func currentWriter() throws -> any DatabaseWriter {
        switch storage {
        case .direct(let writer, _):
            return writer
        case .bound(let binding):
            guard let writer = binding.currentWriter() else { throw StoreLockedError() }
            return writer
        }
    }

    /// The store's SQLCipher key (Phase 13p, whole-store encryption —
    /// R13p-1/R13p-2), resolved per access like the writer; nil = an
    /// unkeyed store (in-memory tests, pre-migration plaintext) OR a
    /// locked binding — `artifactConfiguration()` disambiguates.
    private var key: StoreKey? {
        switch storage {
        case .direct(_, let key): return key
        case .bound(let binding): return binding.currentKey()
        }
    }

    /// Wrap this store for the composition root: the returned VIEW is
    /// what gets installed as the ambient dependency; the BINDING is the
    /// lock/adopt handle the root keeps. Wrapping a bound view returns it
    /// unchanged with its existing binding.
    public func asRebindable() -> (view: AppDatabase, binding: StoreBinding) {
        switch storage {
        case .direct(let writer, let key):
            let binding = StoreBinding(writer: writer, key: key)
            return (AppDatabase(bound: binding), binding)
        case .bound(let binding):
            return (self, binding)
        }
    }

    // MARK: - Factories

    /// The canonical on-disk store (WAL journal, reader pool). `key` is
    /// REQUIRED at the call site on purpose: every caller decides, visibly,
    /// whether this store is encrypted — a defaulted nil would be a silent
    /// plaintext door. Production stores are keyed (Phase 13p); nil exists
    /// for tests that exercise the plaintext-era shape (and the migration's
    /// own source fixtures).
    public static func onDisk(url: URL, key: StoreKey?) throws -> AppDatabase {
        try AppDatabase(
            DatabasePool(path: url.path, configuration: configuration(key: key)),
            key: key)
    }

    /// A private in-memory store, for tests.
    public static func inMemory() throws -> AppDatabase {
        try AppDatabase(DatabaseQueue(configuration: configuration()))
    }

    /// Internal (not private) so `StoreEncryptionMigration` keys its verify
    /// connection through the ONE keying implementation.
    static func configuration(key: StoreKey? = nil) -> Configuration {
        var config = Configuration()
        // Explicit even though it is GRDB's default: FK enforcement is an
        // invariant backstop (AppSpec §6), never an accident of configuration.
        config.foreignKeysEnabled = true
        config.busyMode = .timeout(5)
        if let key {
            config.prepareDatabase { db in
                // Phase 13p: the RAW-KEY pragma, on EVERY connection this
                // configuration opens — pool writers AND readers. As SQL,
                // deliberately, and NEVER GRDB's `usePassphrase(_:)`: that
                // method is the KDF road (sqlite3_key → 256,000
                // PBKDF2-HMAC-SHA512 iterations — measured 165 ms per open
                // vs ~1 ms for this pragma; spike memo Q2), and GRDB offers
                // no raw-key convenience. The x'…' hex literal hands the
                // pager the 256-bit key directly, bypassing derivation.
                //
                // P15 (pre-13u Act 9): catch-and-sanitize — GRDB's
                // DatabaseError.description appends the executed SQL, so a
                // failure HERE would carry the full key hex onto the
                // store-failure screen and into the backup log. (PRAGMA
                // key rarely errors — SQLCipher defers key validation to
                // the first page read — but the channel must not exist.)
                do {
                    try db.execute(sql: "PRAGMA key = \"x'\(key.hexEncoded)'\"")
                } catch {
                    throw RedactedKeyedStatementError(
                        description: key.redactedDescription(of: error))
                }
            }
        }
        return config
    }

    /// A GRDB configuration keyed exactly as this store is keyed — for
    /// opening THIS store's own artifacts (backup copies, integrity checks,
    /// restore verifications) WITHOUT running the migrator. The key never
    /// crosses the seam as bytes; it rides the configuration's
    /// connection-preparation closure. For an unkeyed store this is the
    /// plain configuration, so plaintext-era artifacts behave as they
    /// always did.
    ///
    /// A LOCKED bound store yields a configuration whose every connection
    /// REFUSES (`StoreLockedError` from `prepareDatabase`) — never the
    /// plain configuration, which would silently open a keyed artifact as
    /// "not a database" or, worse, create an unkeyed one.
    /// The fingerprint of the key this store is open under (pre-13x 1a —
    /// what snapshot filenames and the key file's name carry); nil for a
    /// plaintext-era store or a LOCKED bound one (a locked store has no key
    /// in hand, and a snapshot cannot be taken from it anyway).
    public var storeKeyFingerprint: String? {
        switch storage {
        case .direct(_, let key):
            return key.map(StoreKeyEnvelope.fingerprint(of:))
        case .bound(let binding):
            return binding.currentState()?.key.map(StoreKeyEnvelope.fingerprint(of:))
        }
    }

    public func artifactConfiguration() -> Configuration {
        switch storage {
        case .direct(_, let key):
            return Self.configuration(key: key)
        case .bound(let binding):
            // ONE state read (13p ladder R1-n1): the earlier
            // isLocked-then-`key` shape was two lock acquisitions, and a
            // lock landing between them read "unlocked" and then a nil key
            // — composing the PLAIN configuration for a keyed store, the
            // exact silently-plain door this method's own contract forbids.
            guard let state = binding.currentState() else {
                var config = Configuration()
                config.prepareDatabase { _ in throw StoreLockedError() }
                return config
            }
            return Self.configuration(key: state.key)
        }
    }

    // MARK: - Access

    public func read<T>(_ value: (Database) throws -> T) throws -> T {
        try currentWriter().read(value)
    }

    public func read<T: Sendable>(_ value: @Sendable @escaping (Database) throws -> T) async throws -> T {
        try await currentWriter().read(value)
    }

    public func write<T>(_ updates: (Database) throws -> T) throws -> T {
        try currentWriter().write(updates)
    }

    public func write<T: Sendable>(_ updates: @Sendable @escaping (Database) throws -> T) async throws -> T {
        try await currentWriter().write(updates)
    }

    /// pre-13x 3b: a write OUTSIDE a transaction — SQLite refuses `ATTACH`
    /// inside one, and the plaintext export attaches its destination
    /// (`StorePlaintextExport`). The caller owns its own atomicity.
    public func writeWithoutTransaction<T>(_ updates: (Database) throws -> T) throws -> T {
        try currentWriter().writeWithoutTransaction(updates)
    }

    // MARK: - Backup (Phase 8, A1)

    /// One consistent cold copy of the store at `url`, via SQLite's backup
    /// API — safe against an in-use WAL store (the copy is a single-point
    /// snapshot; writers proceed). The destination is a self-contained
    /// database file the recoverable-open path (`openStore(at:)`) can open
    /// directly. Blocking — callers keep it off the main thread (P2).
    ///
    /// Phase 13p: the destination is opened WITH THIS STORE'S OWN KEY — so
    /// a keyed store's backups are ciphertext under the same key, and a
    /// plaintext store's stay plain. This is the spike memo's one hard
    /// sequencing instruction made real: SQLCipher REFUSES `sqlite3_backup`
    /// on a key mismatch ("backup is not supported with encrypted
    /// databases"), so an unkeyed destination here would have broken 13l's
    /// entire backup machinery — scheduled backups, the second destination,
    /// the freshness face, the restore drill — at the first post-migration
    /// run. Pinned in `StoreEncryptionTests` (red-on-old: the shipped
    /// unkeyed path THROWS against a keyed store).
    public func backup(to url: URL) throws {
        let writer = try currentWriter()
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        let destination = try DatabaseQueue(
            path: url.path, configuration: artifactConfiguration())
        try writer.backup(to: destination)
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
        guard let writer = try? currentWriter() else {
            // A LOCKED bound store (Phase 13p Batch 2): the signature has
            // no throwing arm, so the refusal is delivered THROUGH the
            // sequence — an observation over a keyless in-memory stand-in
            // whose fetch throws `StoreLockedError` on first iteration.
            // Reachable only in the narrow race between a re-lock's state
            // flip and a surface's `.task` teardown; the consumer's
            // ordinary error/cancellation path ends the iteration.
            return ValueObservation
                .tracking { (_: Database) -> Value in throw StoreLockedError() }
                .removeDuplicates()
                .values(in: Self.lockedObservationStandIn)
        }
        return ValueObservation
            .tracking(fetch)
            .removeDuplicates()
            .values(in: writer)
    }

    /// **A live projection woken by NAMED regions only** (13n-c Stage B R2-1):
    /// `observe`'s twin for a fetch that must READ a table written at
    /// autosave rate but whose answer can only change when a narrower signal
    /// moves. `observe` tracks what the fetch reads, and `container` is
    /// stamped per edit by a full-record update (`registerTextChange`), so any
    /// fetch reading it re-runs at autosave rate. Here the fetch re-runs only
    /// when a transaction writes one of `regions` (GRDB's constant-region
    /// tracking — the fetch's own reads are NOT tracked), so the caller names
    /// exactly the tables whose writes can change the answer. The same
    /// bounded-fetch rule binds it (P1), and the same locked-store stand-in.
    public func observe<Value: Equatable & Sendable>(
        tracking regions: [any DatabaseRegionConvertible],
        _ fetch: @escaping @Sendable (Database) throws -> Value
    ) -> AsyncValueObservation<Value> {
        guard let writer = try? currentWriter() else {
            return ValueObservation
                .tracking { (_: Database) -> Value in throw StoreLockedError() }
                .removeDuplicates()
                .values(in: Self.lockedObservationStandIn)
        }
        return ValueObservation
            .tracking(regions: regions, fetch: fetch)
            .removeDuplicates()
            .values(in: writer)
    }

    /// A tiny keyless in-memory queue serving ONLY locked-state
    /// observations (nothing ever reads or writes it — the fetch closure
    /// throws before touching the connection).
    private static let lockedObservationStandIn: DatabaseQueue = {
        do {
            return try DatabaseQueue()
        } catch {
            fatalError("An in-memory DatabaseQueue could not be created: \(error)")
        }
    }()

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
        try currentWriter().write { db in
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

    /// The async twin: the sync engine's apply transactions run through this
    /// so a large pull never parks a cooperative-pool thread on a blocking
    /// write (Phase 5 review). Same flag discipline as the synchronous form.
    public func applyingRemote<T: Sendable>(
        _ updates: @escaping @Sendable (Database) throws -> T
    ) async throws -> T {
        try await currentWriter().write { db in
            try db.execute(sql: "INSERT INTO _sync_applying (applying) VALUES (1)")
            do {
                let result = try updates(db)
                try db.execute(sql: "DELETE FROM _sync_applying")
                return result
            } catch {
                try? db.execute(sql: "DELETE FROM _sync_applying")
                throw error
            }
        }
    }
}
