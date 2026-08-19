import Foundation
@testable import VariorumCore

/// The in-process stand-in for the Supabase mirror (SyncSpec §2/§4) — and it
/// must stay exactly this dumb WITHIN a tenant: per-row compare-and-set, one
/// global monotonic `server_seq`, **no uniqueness constraints, no foreign
/// keys, no domain logic**. The real mirror deliberately accepts both sides
/// of a race (two live placements for one block, dangling references
/// mid-batch) so clients can repair deterministically; any check added here
/// that Postgres won't have hides a client bug the real server would let
/// through.
///
/// PHASE 14C — MULTI-TENANT PARITY (batch 1; THE DESIGN items 1–2 and 5).
/// This fake EMULATES the 09 mirror's Postgres semantics — the REAL
/// Postgres truth (composite PKs, forced RLS, the definer-function guards)
/// is proven at the gate's integration pass + the live stranger-sees-zero
/// probes, exactly as the plan's preflight recorded (a Swift fake cannot
/// execute policies). What it emulates:
///  - **partitioned storage per account** — the fake twin of the composite
///    (owner_id, id) PK: every push/pull operates strictly inside the
///    calling user's partition, so another account's same-id row is
///    structurally unaddressable and CAS can never cross tenants;
///  - **owner stamp/subtract for the mirror-only-owner tables** — the
///    partition IS the stamp: payloads for the ten ownerless client
///    tables never carry `owner_id` in either direction, exactly what
///    the real RPC's stamp-on-insert + subtract-on-serve produces;
///  - **validate-equals-caller for the client-carried owner tables** — a
///    pushed row that does not carry EXACTLY the caller's own owner_id
///    refuses the whole call (the RPC's RAISE): another account's uid, a
///    JSON null, and an absent column alike, which is
///    `(item->'columns'->>'owner_id') is distinct from caller::text` read
///    byte for byte (SQL NULL is distinct from every uuid). **The batch-1
///    NULL latitude is RETIRED** (the dedicated isolation round's finding
///    I-2, 2026-08-05): it had been recorded for legacy signed-out fleets
///    that pushed NULL owners by design, but batch 1 itself moved
///    `SyncClient` to signed-in-by-default and rewrote the pre-9c
///    scenarios, so nothing needed the looseness — and a guard whose
///    central claim is only text-pinned is the postmortem's vacuous-pass
///    shape. `MultiTenantSyncTests` now exercises the foreign, NULL, and
///    absent arms directly;
///  - **the vault-key-id fence** — each account holds a vault corpus key
///    id; a round presenting a different id (or an unprovisioned account
///    — the real server's missing-vault-row case) refuses with
///    `SyncError.encryptionKeysReplaced`, the same typed error the real
///    transport classifies out of the VARIORUM_STALE_KEY_FENCE marker;
///  - **the entitlement gate** — an unentitled account's round refuses
///    with `SyncError.syncNotEntitled` (the VARIORUM_NO_ENTITLEMENT
///    marker's classification). Accounts are provisioned entitled by
///    default, emulating the deploy-path seed (her account) and the
///    probe-setup grant.
///
/// The single-user suites keep their exact shape: `FakeSyncServer` itself
/// conforms to `SyncTransport` AS the default account (pre-provisioned
/// with the suite key world's corpus key id — the fake twin of "setup
/// wrote the vault before any round ran"); `connection(as:)` hands out
/// per-account transports for the multi-tenant suites.
actor FakeSyncServer: SyncTransport, SyncPurgeTransport {
    private struct StoredRow {
        var row: SyncRow          // payload; row.syncVersion == current version
        var serverSeq: Int64      // stamped on every accepted change
        /// Logical-clock tick when the row was WRITTEN (seq assignment time).
        /// The A5 visibility horizon is measured against this — the fake twin
        /// of the mirror's `server_written_at` (03_visibility_horizon.sql).
        var writtenAt: Int64
        /// False while the writing transaction is still open (`holdPushes`):
        /// the row has a seq but is invisible to pulls — the visibility skew
        /// SyncSpec §5 documents (seq assigned at write time, row visible at
        /// commit time).
        var committed: Bool
    }

    /// One account's world: its partition (the composite-PK twin), its
    /// key_vault corpus key id (the fence's comparand), its entitlement.
    private struct Account {
        /// table → rowID → current state. Rows are never removed BY SYNC —
        /// a tombstone is an ordinary accepted update (S2). Phase 13j's
        /// `executePurge` is the ONE remover, exactly as 10's RPC is on
        /// the real mirror, and every removal leaves a ledger entry.
        var tables: [String: [String: StoredRow]] = [:]
        /// nil = AUTO-ADOPT: the first round's presented key id becomes
        /// the vault's (the bootstrap-runner latitude — `setVaultKeyAutoAdopt`).
        var vaultCorpusKeyID: String?
        var entitled: Bool = true
        /// Phase 13j: the per-device pull cursors (the `device_cursor`
        /// twin) — device id → (last committed seq, seen-at clock tick).
        var deviceCursors: [String: (lastSeq: Int64, seenAt: Int64)] = [:]
        /// Phase 13j: the content-free purged-ids ledger (`purged_row`).
        var purgedRows: [PurgedKey: Int64] = [:]
        /// Phase 13j: the ledger's coverage floor — 0 on the real mirror
        /// until ledger pruning exists; SETTABLE here so the returner road
        /// is provable today (`setLedgerFloor`).
        var ledgerFloor: Int64 = 0
    }

    struct PurgedKey: Hashable {
        let table: String
        let rowID: String
    }

    /// user id → account. The default account models the single-user era's
    /// one caller; multi-tenant suites provision more.
    private var accounts: [String: Account] = [:]
    private var seq: Int64 = 0

    /// The single-user suites' implicit caller (a uuid-shaped string so
    /// owner-stamped local rows read plausibly in dumps).
    static let defaultUserID = "00000000-aaaa-4bbb-8ccc-000000000001"

    // MARK: A5 machinery (in-flight transactions + visibility horizon)

    /// Logical server clock, in ticks; tests advance it explicitly.
    private var clock: Int64 = 0
    /// Rows written within the last `visibilityHorizon` ticks are never
    /// served — the changefeed fix (SyncSpec §5; the real RPC's
    /// `interval '2 seconds'` filter). **0 models the PRE-FIX server**, which
    /// is also exactly right for every synchronous suite: with no concurrent
    /// transactions there is no skew to hide from.
    private let visibilityHorizon: Int64
    /// While true, the NEXT push call's rows are stamped (seq + writtenAt)
    /// but stay invisible until `commitHeldPushes()` — one in-flight
    /// transaction later transactions commit around.
    private var holdingNextPush = false

    /// The mirror's deployed lockstep marker (SyncSpec §12). Defaults to
    /// the client's current version — a fake models an in-lockstep server
    /// unless a test deliberately deploys it behind/ahead.
    private var deployedLockstepVersion = SyncSchema.lockstepVersion

    init(visibilityHorizon: Int64 = 0) {
        self.visibilityHorizon = visibilityHorizon
        // The default account is pre-provisioned with the suite key
        // world's corpus key id — the fake twin of "the vault row exists
        // before any round" (the real server refuses a vault-less caller
        // at the fence; here, an unprovisioned USER does the same).
        accounts[Self.defaultUserID] = Account(vaultCorpusKeyID: SyncTestKeys.corpusKeyID)
    }

    func setDeployedLockstepVersion(_ version: Int) {
        deployedLockstepVersion = version
    }

    func advanceClock(by ticks: Int64) {
        clock += ticks
    }

    /// The next push call becomes one held-open transaction (subsequent
    /// pushes commit normally around it).
    func holdNextPush() {
        holdingNextPush = true
    }

    /// Commits the held transaction: its rows become visible AT THEIR
    /// ORIGINAL seqs (possibly below already-visible later seqs — the skew).
    func commitHeldPushes() {
        holdingNextPush = false
        for (user, account) in accounts {
            for (table, rows) in account.tables {
                for (rowID, stored) in rows where !stored.committed {
                    accounts[user]!.tables[table]![rowID]!.committed = true
                }
            }
        }
    }

    // MARK: Phase 14c — account provisioning (the multi-tenant surface)

    /// Provision an account: its key_vault corpus key id (the fence's
    /// comparand) and its entitlement. The real-world analogue is
    /// signup + vault setup + the entitlement grant.
    func provisionAccount(
        _ userID: String, vaultCorpusKeyID: String, entitled: Bool = true
    ) {
        accounts[userID] = Account(
            vaultCorpusKeyID: vaultCorpusKeyID, entitled: entitled)
    }

    /// The re-key act's server half: the account's vault now names a new
    /// corpus key id (CF-8 writes the NEW vault FIRST — from this moment
    /// every stale writer is fenced).
    func setVaultCorpusKeyID(_ keyID: String, for userID: String = FakeSyncServer.defaultUserID) {
        accounts[userID]?.vaultCorpusKeyID = keyID
    }

    /// The tier's server half: revoke/grant hosted sync.
    func setEntitled(_ entitled: Bool, for userID: String = FakeSyncServer.defaultUserID) {
        accounts[userID]?.entitled = entitled
    }

    /// The bootstrap-runner latitude (recorded emulation choice): the
    /// account's vault key id ADOPTS the first round's presented id —
    /// models "the same act that just WROTE the vault now drains through
    /// it" (the runner's create-vault → reinit → drain sequence, where
    /// the fence's comparand is by construction the key the drain
    /// presents; the runner's own tests mint real random key material,
    /// so no fixed id can be pre-provisioned). Fence tests always set an
    /// explicit id instead — never this.
    func setVaultKeyAutoAdopt(for userID: String = FakeSyncServer.defaultUserID) {
        accounts[userID]?.vaultCorpusKeyID = nil
    }

    /// A per-account transport handle for the multi-tenant suites — the
    /// fake twin of "a device authenticated as this user". Nonisolated:
    /// it only captures the actor reference.
    nonisolated func connection(as userID: String) -> FakeSyncServerConnection {
        FakeSyncServerConnection(server: self, userID: userID)
    }

    // MARK: SyncTransport (the default account — the single-user suites'
    // implicit caller)

    func push(_ batch: [SyncRow], activeKeyID: String) throws -> [SyncPushOutcome] {
        try push(batch, activeKeyID: activeKeyID, as: Self.defaultUserID)
    }

    func pull(since: Int64, limit: Int, activeKeyID: String, deviceID: String?) throws -> [SyncPulledRow] {
        try pull(
            since: since, limit: limit, activeKeyID: activeKeyID, deviceID: deviceID,
            as: Self.defaultUserID)
    }

    func schemaVersion() -> Int {
        deployedLockstepVersion
    }

    // MARK: SyncPurgeTransport (default account)

    func syncHorizon(activeKeyID: String) throws -> Int64 {
        try syncHorizon(activeKeyID: activeKeyID, as: Self.defaultUserID)
    }

    func purgeLedger(since: Int64, activeKeyID: String) throws -> SyncPurgeLedgerPage {
        try purgeLedger(since: since, activeKeyID: activeKeyID, as: Self.defaultUserID)
    }

    func executePurge(_ rows: [SyncPurgeTarget], activeKeyID: String) throws -> Int64 {
        try executePurge(rows, activeKeyID: activeKeyID, as: Self.defaultUserID)
    }

    // MARK: The tenant-scoped halves (the 09 RPC bodies' fake twins)

    /// The round-level gates, in the 09 order: account (auth) → fence →
    /// entitlement. Any refusal aborts the WHOLE call before any row is
    /// touched, exactly as the RPC's RAISE does.
    private func gatedAccount(_ userID: String, activeKeyID: String) throws -> Account {
        guard var account = accounts[userID] else {
            // The real server: an authenticated caller with NO key_vault
            // row hits the fence's missing-vault arm. An unprovisioned
            // fake account refuses the same way.
            throw SyncError.encryptionKeysReplaced
        }
        if account.vaultCorpusKeyID == nil {
            // The auto-adopt latitude (`setVaultKeyAutoAdopt`): the vault
            // was just written by this very actor; its id is the one now
            // presented.
            account.vaultCorpusKeyID = activeKeyID
            accounts[userID] = account
        }
        guard account.vaultCorpusKeyID == activeKeyID else {
            throw SyncError.encryptionKeysReplaced
        }
        guard account.entitled else {
            throw SyncError.syncNotEntitled
        }
        return account
    }

    func push(
        _ batch: [SyncRow], activeKeyID: String, as userID: String
    ) throws -> [SyncPushOutcome] {
        _ = try gatedAccount(userID, activeKeyID: activeKeyID)
        // Client-carried owner guard (the eight), validated for the WHOLE
        // batch BEFORE any row applies: the RPC's RAISE aborts the whole
        // transaction, so a partial application here would be emulation
        // drift. A row that does not carry EXACTLY the caller's own
        // owner_id refuses the call — another account's uid, a JSON null,
        // and an absent column alike, which is the real RPC's
        // `(item->'columns'->>'owner_id') is distinct from caller::text`
        // read byte for byte (SQL NULL is distinct from any uuid).
        for incoming in batch {
            guard let table = SyncSchema.table(named: incoming.table),
                  table.plainColumns.contains("owner_id")
            else { continue }
            guard case .text(let pushedOwner)? = incoming.columns["owner_id"],
                  pushedOwner == userID
            else {
                throw FakeSyncServerError.ownerMismatch(
                    table: incoming.table, rowID: incoming.rowID)
            }
        }
        let heldTransaction = holdingNextPush
        holdingNextPush = false
        return try batch.map { incoming in
            // Phase 13j — THE LEDGER FENCE (10's per-row check, before any
            // CAS work): a push naming a purged id answers 'purged'; the
            // client drops the outbox entry and its local copy.
            if accounts[userID]?.purgedRows[
                PurgedKey(table: incoming.table, rowID: incoming.rowID)] != nil {
                return .purged
            }
            let current = accounts[userID]?.tables[incoming.table]?[incoming.rowID]
            let currentVersion = current?.row.syncVersion ?? 0
            guard incoming.syncVersion == currentVersion else {
                return .rejected(current: current.map {
                    SyncPulledRow(row: $0.row, serverSeq: $0.serverSeq)
                })
            }
            seq += 1
            var accepted = incoming
            accepted.syncVersion = currentVersion + 1
            // Wire fidelity (the plan's fake-server-drift risk): real
            // payloads cross jsonb, which normalizes scalar types
            // (`.real(0.0)` → `.integer(0)`). Round-trip every accepted row
            // through JSON so engine flows see the same normalization the
            // real mirror would produce.
            let normalized = try JSONDecoder().decode(
                SyncRow.self, from: JSONEncoder().encode(accepted))
            accounts[userID]!.tables[incoming.table, default: [:]][incoming.rowID] =
                StoredRow(row: normalized, serverSeq: seq,
                          writtenAt: clock, committed: !heldTransaction)
            return .accepted(newVersion: accepted.syncVersion, serverSeq: seq)
        }
    }

    func pull(
        since: Int64, limit: Int, activeKeyID: String, deviceID: String? = nil,
        as userID: String
    ) throws -> [SyncPulledRow] {
        let account = try gatedAccount(userID, activeKeyID: activeKeyID)
        // Phase 13j — the device-cursor upsert (10's `for_device` arm):
        // monotonic on last_seq, seen-at stamped with the logical clock.
        if let deviceID {
            let existing = accounts[userID]?.deviceCursors[deviceID]?.lastSeq ?? 0
            accounts[userID]?.deviceCursors[deviceID] =
                (lastSeq: max(existing, since), seenAt: clock)
        }
        // Strictly the caller's partition — the composite identity's
        // subtract half comes free: the ten's stored payloads never
        // carried an owner, and the eight's carry the caller's own.
        return Array(
            account.tables.values
                .flatMap { $0.values }
                .filter {
                    $0.committed && $0.serverSeq > since
                        && $0.writtenAt <= clock - visibilityHorizon
                }
                .sorted { $0.serverSeq < $1.serverSeq }
                .prefix(limit)
                .map { SyncPulledRow(row: $0.row, serverSeq: $0.serverSeq) })
    }

    // MARK: The purge surface, tenant-scoped (10's three RPC bodies' twins)

    /// The 60-day drop-out window (her round-8 ruling), in the fake's
    /// LOGICAL CLOCK ticks — tests set it small and advance the clock to
    /// model a device falling out of the horizon. The default keeps every
    /// recorded cursor in-window (no test drops a device by accident).
    private var horizonDropoutTicks: Int64 = .max / 4

    func setHorizonDropoutTicks(_ ticks: Int64) {
        horizonDropoutTicks = ticks
    }

    /// The returner-road test hook: the real mirror's floor stays 0 until
    /// ledger pruning exists; the fake models a future-pruned state.
    func setLedgerFloor(_ floor: Int64, for userID: String = FakeSyncServer.defaultUserID) {
        accounts[userID]?.ledgerFloor = floor
    }

    func syncHorizon(activeKeyID: String, as userID: String) throws -> Int64 {
        let account = try gatedAccount(userID, activeKeyID: activeKeyID)
        let live = account.deviceCursors.values
            .filter { $0.seenAt + horizonDropoutTicks > clock }
            .map(\.lastSeq)
        return live.min() ?? 0
    }

    func purgeLedger(
        since: Int64, activeKeyID: String, as userID: String
    ) throws -> SyncPurgeLedgerPage {
        let account = try gatedAccount(userID, activeKeyID: activeKeyID)
        let entries = account.purgedRows
            .filter { $0.value > since }
            .map { SyncPurgedRecord(table: $0.key.table, rowID: $0.key.rowID, purgedSeq: $0.value) }
            .sorted {
                ($0.purgedSeq, $0.table, $0.rowID) < ($1.purgedSeq, $1.table, $1.rowID)
            }
        return SyncPurgeLedgerPage(floor: account.ledgerFloor, entries: entries)
    }

    /// The purge-execution door: deletes exactly the named rows inside the
    /// caller's partition and records every one in the ledger — idempotent
    /// (a missing row deletes nothing; an existing ledger entry keeps its
    /// original seq, the ON CONFLICT DO NOTHING twin). One granted seq per
    /// call: the purge is one event.
    func executePurge(
        _ rows: [SyncPurgeTarget], activeKeyID: String, as userID: String
    ) throws -> Int64 {
        _ = try gatedAccount(userID, activeKeyID: activeKeyID)
        seq += 1
        let granted = seq
        for target in rows {
            accounts[userID]?.tables[target.table]?[target.rowID] = nil
            let key = PurgedKey(table: target.table, rowID: target.rowID)
            if accounts[userID]?.purgedRows[key] == nil {
                accounts[userID]?.purgedRows[key] = granted
            }
        }
        return granted
    }

    // MARK: Test inspection (default account unless a user is named)

    /// Phase 13j inspection: the recorded device cursors and the ledger.
    func deviceCursor(
        _ deviceID: String, for userID: String = FakeSyncServer.defaultUserID
    ) -> Int64? {
        accounts[userID]?.deviceCursors[deviceID]?.lastSeq
    }

    func purgedLedgerCount(for userID: String = FakeSyncServer.defaultUserID) -> Int {
        accounts[userID]?.purgedRows.count ?? 0
    }

    func isPurged(
        table: String, rowID: String, for userID: String = FakeSyncServer.defaultUserID
    ) -> Bool {
        accounts[userID]?.purgedRows[PurgedKey(table: table, rowID: rowID)] != nil
    }

    var headSeq: Int64 { seq }

    func currentRow(
        table: String, rowID: String, for userID: String = FakeSyncServer.defaultUserID
    ) -> SyncRow? {
        accounts[userID]?.tables[table]?[rowID]?.row
    }

    func rowCount(
        table: String, for userID: String = FakeSyncServer.defaultUserID
    ) -> Int {
        accounts[userID]?.tables[table]?.count ?? 0
    }

    /// Every stored row across EVERY account — the total-mirror-dump
    /// surface the Phase 14b assertion walks ("a total mirror dump reads
    /// as structure, never words"), now spanning all tenants.
    var allStoredRows: [SyncRow] {
        accounts.values.flatMap { account in
            account.tables.values.flatMap { $0.values.map(\.row) }
        }
    }

    /// One account's stored rows — the per-tenant dump surface for the
    /// two-user suites' stranger-corpus assertions.
    func storedRows(for userID: String) -> [SyncRow] {
        accounts[userID]?.tables.values.flatMap { $0.values.map(\.row) } ?? []
    }

    // MARK: Phase 14b — wipe-and-repush (ruling R-2)

    /// Truncates every stored data row — the fake twin of the gate's
    /// data-table truncate artifact. Provisioning (vault key ids,
    /// entitlement) SURVIVES, exactly as the real truncate never touches
    /// `key_vault` or `entitlement`; the global `server_seq` sequence is
    /// deliberately NOT reset: the ordering authority stays monotonic
    /// across the wipe (SyncSpec §9), exactly as the real mirror's
    /// sequence object survives a TRUNCATE.
    func wipe() {
        for user in accounts.keys {
            accounts[user]!.tables = [:]
        }
    }

    /// The account-scoped truncate (CF-8's re-key road, batch 2's RPC):
    /// one tenant's data rows only.
    func truncateAccount(_ userID: String) {
        accounts[userID]?.tables = [:]
    }

    /// The deletion door's purge (batch 2's `account_purge` RPC, her
    /// Round-5 ruling): the whole account goes — data partition, vault
    /// key id, entitlement (the real RPC also removes the auth user;
    /// here the account's disappearance models it). A lingering device's
    /// next round refuses at the fence's missing-vault arm — the same
    /// backstop that covers the real world's JWT-until-expiry window.
    func purgeAccount(_ userID: String) {
        accounts[userID] = nil
    }
}

/// A device's authenticated handle on the fake server: the same transport
/// protocol, bound to one account — the fake twin of the JWT the real
/// transport carries per call.
struct FakeSyncServerConnection: SyncTransport, SyncPurgeTransport {
    let server: FakeSyncServer
    let userID: String

    func push(_ batch: [SyncRow], activeKeyID: String) async throws -> [SyncPushOutcome] {
        try await server.push(batch, activeKeyID: activeKeyID, as: userID)
    }

    func pull(since: Int64, limit: Int, activeKeyID: String, deviceID: String?) async throws -> [SyncPulledRow] {
        try await server.pull(
            since: since, limit: limit, activeKeyID: activeKeyID, deviceID: deviceID,
            as: userID)
    }

    func schemaVersion() async throws -> Int {
        await server.schemaVersion()
    }

    func syncHorizon(activeKeyID: String) async throws -> Int64 {
        try await server.syncHorizon(activeKeyID: activeKeyID, as: userID)
    }

    func purgeLedger(since: Int64, activeKeyID: String) async throws -> SyncPurgeLedgerPage {
        try await server.purgeLedger(since: since, activeKeyID: activeKeyID, as: userID)
    }

    func executePurge(_ rows: [SyncPurgeTarget], activeKeyID: String) async throws -> Int64 {
        try await server.executePurge(rows, activeKeyID: activeKeyID, as: userID)
    }
}

enum FakeSyncServerError: Error, Equatable {
    /// The 09 push guard's RAISE: a client-carried owner table's row named
    /// an owner other than the caller.
    case ownerMismatch(table: String, rowID: String)
}
