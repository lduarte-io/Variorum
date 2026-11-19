import Dependencies
import Foundation
import GRDB

/// The signed-in owner's identity seam (Phase 9c, Step 4 — S4 collected on:
/// `owner_id` has been nullable on the top-level entities since schema v1,
/// waiting for exactly this).
///
/// `current()` returns the authenticated user id (the VARIORUM project's
/// `auth.uid()` — the 9c plan's keying decision: project-local, stable no
/// matter how the identity was proven, never the Fragments uid), or `nil`
/// while signed out. Minting while signed out is legitimate — rows are born
/// unowned and the next `adoptOwnerID` backfill claims them (the same pass
/// that backfills the pre-9c corpus); after the mirror's RLS flip
/// (04_auth_rls.sql) an unowned row would be refused by the push guard, and
/// the sign-in flow runs the adoption pass before syncing for exactly that
/// reason.
///
/// Live default is signed-out; the app installs the real closure (reading
/// its auth session store) at bootstrap, alongside `AppDatabase.install` —
/// the closure is read per call, so sign-in/out never needs re-installation.
public struct OwnerIdentity: Sendable {
    public var current: @Sendable () -> String?

    public init(current: @escaping @Sendable () -> String?) {
        self.current = current
    }

    /// Signed out (the pre-sign-in default, and the test default: the
    /// pre-9c suites mint unowned rows exactly as the shipped app did).
    public static let signedOut = OwnerIdentity { nil }
}

extension OwnerIdentity: TestDependencyKey {
    public static let liveValue = OwnerIdentity.signedOut
    public static let testValue = OwnerIdentity.signedOut
}

extension DependencyValues {
    public var ownerIdentity: OwnerIdentity {
        get { self[OwnerIdentity.self] }
        set { self[OwnerIdentity.self] = newValue }
    }
}

extension OwnerIdentity {
    /// Wires the app's real identity closure as the live `\.ownerIdentity`
    /// dependency — the `AppDatabase.install` twin, called exactly once by
    /// root composition (AppBootstrap), before anything constructs
    /// `Operations`. The closure is read per call, so sign-in/out never
    /// needs re-installation.
    public static func install(_ identity: OwnerIdentity) {
        prepareDependencies { $0.ownerIdentity = identity }
    }
}

// MARK: - The backfill (Phase 9c, Step 4; brief interpretation 3)

extension Operations {
    /// Per-table adoption counts, for the choreography's dump-compare and
    /// the totality tests.
    public struct OwnerAdoptionReport: Equatable, Sendable {
        public var adoptedByTable: [String: Int]
        public var total: Int { adoptedByTable.values.reduce(0, +) }
    }

    /// Stamps the signed-in owner onto every row (live AND tombstoned —
    /// tombstones still sync) whose `owner_id` is NULL, across every synced
    /// table that carries the column (introspected, never hardcoded — a
    /// future owner-carrying table joins the backfill automatically, the
    /// same truth source as the mirror-DDL guard pins).
    ///
    /// Ordinary UPDATEs in one transaction: the outbox triggers enqueue
    /// every touched row (this is NOT an apply-mode write — the whole point
    /// is that the adoption PUSHES), so the mirror converges ahead of the
    /// RLS flip per the §12 choreography (backfill first, from the Mac; the
    /// phone pulls/converges; only then the 04 paste). Deliberately not
    /// touched: `updated_at` (adoption is not an edit — nothing may
    /// reshuffle, and CAS metadata rides `sync_version`), `sync_version`
    /// (the server's token, bumped only on accept), and rows already owned
    /// (by anyone — only NULL adopts). Idempotent: a second run adopts
    /// nothing.
    ///
    /// Refuses while signed out (`OperationError.noOwnerIdentity`) — an
    /// adoption without an identity has nothing to stamp.
    ///
    /// **VM-67 — it costs the rows to adopt, never the corpus, and writes
    /// nothing when nothing is unowned.** It runs at every launch with a
    /// session, every unlock and every sign-in, and on her phone almost every
    /// run has nothing to do. Two parts, inside ONE access to the writer:
    /// 1. **The probe** — per owner table, `EXISTS` through the table's
    ///    partial index of unowned rows (`idx_<table>_unowned`, v1_38): an
    ///    index seek, outside any transaction (a read in autocommit — no write
    ///    lock, no WAL frame). Nothing unowned anywhere ⇒ the all-zero report,
    ///    and no transaction was ever opened.
    /// 2. **The adoption** — otherwise, the same UPDATE set as ever, in ONE
    ///    IMMEDIATE transaction (GRDB's own `write` shape), each statement
    ///    driven by the same index.
    /// The access is the writer's own (`writeWithoutTransaction` — its FIFO
    /// queue), not a reader's: a write already queued when adoption is called
    /// lands first and its rows are seen, exactly as the one write
    /// transaction this replaced saw them. The predicate is unchanged
    /// (`owner_id IS NULL`), so the rows adopted, and the occasions that
    /// adopt them, are today's. Pinned in `OwnerAdoptionTests` (no write
    /// statement when nothing is unowned; every statement reads an owner
    /// table only through its unowned index; the state transitions per road).
    @discardableResult
    public func adoptOwnerID() throws -> OwnerAdoptionReport {
        guard let owner = currentOwnerID() else {
            throw OperationError.noOwnerIdentity
        }
        return try database.writeWithoutTransaction { db in
            var tables: [String] = []
            for table in SyncSchema.tables {
                let columns = try Row.fetchAll(
                    db, sql: "PRAGMA table_info(\(table.name))")
                    .map { $0["name"] as String }
                if columns.contains("owner_id") { tables.append(table.name) }
            }
            var adopted = Dictionary(uniqueKeysWithValues: tables.map { ($0, 0) })
            let anyUnowned = try tables.contains { table in
                try Bool.fetchOne(
                    db, sql: "SELECT EXISTS (SELECT 1 FROM \(table) WHERE owner_id IS NULL)") ?? false
            }
            guard anyUnowned else { return OwnerAdoptionReport(adoptedByTable: adopted) }
            try db.inTransaction {
                for table in tables {
                    try db.execute(
                        sql: "UPDATE \(table) SET owner_id = ? WHERE owner_id IS NULL",
                        arguments: [owner])
                    adopted[table] = db.changesCount
                }
                return .commit
            }
            return OwnerAdoptionReport(adoptedByTable: adopted)
        }
    }
}

// MARK: - The adopt road's re-stamp (pre-13x 3a — decision 17)

extension Operations {
    /// pre-13x 3a — THE ADOPT ROAD's re-stamp (the postures design decision
    /// 17, §5's setup/enroll rows, corner 29/31): a library that last synced
    /// under ANOTHER account (a deleted-then-recreated account; a library
    /// moved between accounts) is adopted by the signed-in one — EVERY
    /// owner-carrying synced row, live AND tombstoned, is re-stamped to
    /// `owner` in ONE transaction (introspected like `adoptOwnerID`, never a
    /// hand list). Ordinary UPDATEs — the outbox triggers enqueue every
    /// touched row (never apply mode); the caller then runs the engine's
    /// `resyncReinitialize` (versions → 0, `sync_row_seq` cleared, the
    /// cursor cleared, every row enqueued) so the WHOLE library uploads
    /// into the new account's partition — the 14c `(owner_id, id)` keys
    /// let the same ids under X and Y coexist. `adoptOwnerID` fills NULLs
    /// only and is deliberately not this. Rows already under `owner` are
    /// left alone (idempotent); `updated_at` and `sync_version` untouched
    /// (adoption is not an edit; the version is the server's token, reset
    /// by the re-initialization). Refuses while signed out.
    @discardableResult
    public func restampOwner(to owner: String) throws -> OwnerAdoptionReport {
        guard currentOwnerID() != nil else { throw OperationError.noOwnerIdentity }
        return try database.write { db in
            var restamped: [String: Int] = [:]
            for table in SyncSchema.tables {
                let columns = try Row.fetchAll(
                    db, sql: "PRAGMA table_info(\(table.name))")
                    .map { $0["name"] as String }
                guard columns.contains("owner_id") else { continue }
                try db.execute(
                    sql: "UPDATE \(table.name) SET owner_id = ? WHERE owner_id IS NULL OR owner_id != ?",
                    arguments: [owner, owner])
                restamped[table.name] = db.changesCount
            }
            return OwnerAdoptionReport(adoptedByTable: restamped)
        }
    }
}
