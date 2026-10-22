import Foundation
@testable import VariorumCore

/// The in-process stand-in for the Supabase mirror (SyncSpec §2/§4) — and it
/// must stay exactly this dumb WITHIN a tenant: per-row compare-and-set, a
/// PER-OWNER monotonic `server_seq` (Phase 13y — 12_phase13y_tenant_seq.sql's
/// twin; the 14c I-1 disclosure's closure), **no uniqueness constraints, no
/// foreign keys, no domain logic**. The real mirror deliberately accepts
/// both sides of a race (two live placements for one block, dangling
/// references mid-batch) so clients can repair deterministically; any check
/// added here that Postgres won't have hides a client bug the real server
/// would let through.
///
/// PHASE 13Y — PER-TENANT SEQUENCING (12's semantics, mirrored EXACTLY):
///  - every mint draws from the CALLING account's own counter
///    (`nextTenantSeq` — `next_tenant_seq(for_tenant)`'s twin), at all three
///    of 12's mint sites: the accept stamp (push + reencrypt — the
///    trigger's road), `executePurge`'s granted ledger seq, and
///    `keyVaultUpdate`'s rotation-begin seq;
///  - THE FLOOR (12's F-S1 initialization, lazily): an account's FIRST
///    mint reads the GREATEST seq its partition already carries — data
///    rows, device cursors, ledger entries, a standing rotation seq — so
///    a fake seeded mid-history (the migration scenario) continues above
///    everything its cursors compare against, exactly as the deploy's
///    per-owner MAX floor does. An empty account starts at 1;
///  - `wipe()` / `truncateAccount` leave counters UNTOUCHED (the
///    sequence-survives-a-truncate doctrine, per owner: cursors stay
///    valid across a re-key); `purgeAccount` removes the account's
///    counter with it (12's account_purge letter — a re-created account
///    reads its own sequence from its start: the adopt road);
///  - `headSeq` is PER-ACCOUNT (`headSeq(for:)`; the property is the
///    default account's — the single-user suites' exact old meaning).
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
/// PRE-13X BATCH 1B — THE POSTURES EVENT (11_pre13x_postures.sql; the
/// design's §3.10, decisions 12 / 31 / 32). The fake now models the vault
/// ROW per account (the fence key id · the proof hash · the previous corpus
/// key · the rotation seq · the revision) and enforces EXACTLY what the SQL
/// enforces:
///  - **the key proof** (`gatedAccount`, the SQL's `sync_key_gate` twin):
///    after the fence, the presented `keyProof` is hashed and compared to
///    the vault's stored hash — mismatch, absent, or malformed refuses with
///    `SyncError.keyProofRefused` (the VARIORUM_KEY_PROOF_REQUIRED marker's
///    classification); the NULL-hash MIGRATION ARM lands the FIRST proof's
///    hash and accepts it, once. (The compare is a plain `==` here — the
///    fake is not the security boundary; the SQL's is constant-time and
///    pinned.) The gate order is the SQL's: fence → proof → entitlement;
///  - **`keyVaultUpdate`** (the `key_vault_update` RPC's twin): absent
///    refuses; the proof (the NULL-hash arm included); the revision CAS;
///    the ROTATION SEQ — the payload SETS a previous key where none stands
///    ⇒ the next sequence value (the same counter the rows take); the SAME
///    previous key ⇒ carry-through; a DIFFERENT one while one stands ⇒
///    `KeyVaultClientError.rotationInProgress` (decision 32); a payload
///    without one ⇒ both cleared. The actor's serialization stands in for
///    the SQL's row locks: a push either wholly precedes the vault write
///    (and its seqs sit BELOW the rotation seq) or wholly follows it (and
///    is refused by the new proof) — never interleaves (decision 31);
///  - **`reencrypt`** (the `sync_reencrypt` twin): per row, the payload is
///    replaced where the version matches — a FRESH seq, the version KEPT;
///    else `skipped` with the current version;
///  - **the gated truncate** (`account_data_truncate`'s twin): the right key
///    id WITHOUT the proof deletes nothing;
///  - **`purgeAccount` stays session-only** — deletion is mandated and loud.
///
/// The single-user suites keep their exact shape: `FakeSyncServer` itself
/// conforms to `SyncTransport` AS the default account (pre-provisioned
/// with the suite key world's corpus key id AND proof hash — the fake twin
/// of "setup wrote the vault before any round ran"); `connection(as:)`
/// hands out per-account transports for the multi-tenant suites.
actor FakeSyncServer: SyncTransport, SyncPurgeTransport, SyncRotationTransport {
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

    /// One account's `key_vault` row as the RPCs read it (pre-13x): the
    /// fence's comparand, the proof's hash, the rotation bookkeeping, the
    /// CAS token. The vault's FORMAT (the wrapped keys) lives on the
    /// `ScriptedVaultServer` — the PostgREST twin — which routes its
    /// `key_vault_update` through this row so ONE emulation exists.
    struct VaultRow: Equatable {
        /// nil = AUTO-ADOPT: the first round's presented key id becomes
        /// the vault's (the auto-adopt latitude, born for the deleted
        /// vault-bootstrap runner — `setVaultKeyAutoAdopt`).
        var corpusKeyID: String?
        /// nil = a hash-less row. The 11-era NULL-hash migration arm is
        /// RETIRED (13y UNIT B) — the challenge road refuses it; the one
        /// surviving latitude is the fake-only auto-adopt enroll below.
        var keyProofHash: String?
        /// 13y UNIT B — the VAULT-HELD MAC SECRET's twin (kp2, base64):
        /// what `vault.decrypted_secrets` serves the real verify. nil =
        /// NOT ENROLLED — every gated call refuses
        /// VARIORUM_KEY_PROOF_ENROLL until `key_proof_enroll` lands it.
        var keyProofMacSecret: String?
        /// The previous corpus key — its id and its bare wrap, two columns
        /// — while a rotation is finishing; nil otherwise, TOGETHER with the
        /// seq.
        var previousCorpusKeyID: String?
        var previousCorpusKey: String?
        var rotationStartedSeq: Int64?
        var revision: Int = 1
        /// pre-13x 2c (decision 34): the NAME of the device that last wrote
        /// the row — written by every `keyVaultUpdate` from its payload.
        var updatedByDevice: String?
    }

    /// One account's world: its partition (the composite-PK twin), its
    /// vault row (the fence's comparand + the proof's hash), its entitlement.
    private struct Account {
        /// table → rowID → current state. Rows are never removed BY SYNC —
        /// a tombstone is an ordinary accepted update (S2). Phase 13j's
        /// `executePurge` is the ONE remover, exactly as 10's RPC is on
        /// the real mirror, and every removal leaves a ledger entry.
        var tables: [String: [String: StoredRow]] = [:]
        var vault: VaultRow
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
    /// 13y: user id → the account's own counter (12's `sync_tenant_seq`
    /// twin). Absent = never minted; the first mint floors lazily.
    private var tenantSeqs: [String: Int64] = [:]

    /// 12's `next_tenant_seq(for_tenant)`: the per-owner upsert-increment.
    /// The actor's serialization stands in for the counter row's lock.
    private func nextTenantSeq(for userID: String) -> Int64 {
        let granted = (tenantSeqs[userID] ?? tenantFloorSeq(for: userID)) + 1
        tenantSeqs[userID] = granted
        return granted
    }

    /// 12's floor initialization (F-S1), lazily per account: the GREATEST
    /// seq the partition already carries — data rows, device cursors,
    /// ledger entries, a standing rotation seq — so minting always
    /// continues ABOVE everything the account's bookkeeping compares
    /// against (no cursor resets, the carry-over's letter).
    private func tenantFloorSeq(for userID: String) -> Int64 {
        guard let account = accounts[userID] else { return 0 }
        var floor: Int64 = 0
        for rows in account.tables.values {
            for stored in rows.values { floor = max(floor, stored.serverSeq) }
        }
        for cursor in account.deviceCursors.values { floor = max(floor, cursor.lastSeq) }
        for purgedSeq in account.purgedRows.values { floor = max(floor, purgedSeq) }
        if let rotationSeq = account.vault.rotationStartedSeq { floor = max(floor, rotationSeq) }
        return floor
    }

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
    /// 13y (12's `sync_visibility_horizon_ms()` twin — the R-13y-4 fork's
    /// Shape 1): the SERVED horizon, in milliseconds — what the rotation
    /// walk's production road fetches and derives its wait from. Defaults
    /// to the deployed constant (2000); SETTABLE (`setServedVisibility
    /// HorizonMillis`) so the derivation pin can observe wait = served +
    /// margin for an arbitrary value. Deliberately independent of
    /// `visibilityHorizon` above: the fake's ENFORCED window runs on the
    /// logical tick clock (tests advance it by hand), while the served
    /// value is a wire fact — the mirror's one-function coupling is the
    /// DDL pins' to prove, not this emulation's.
    private var servedVisibilityHorizonMillis: Int64 = 2000

    /// The mirror's deployed lockstep marker (SyncSpec §12). Defaults to
    /// the client's current version — a fake models an in-lockstep server
    /// unless a test deliberately deploys it behind/ahead.
    private var deployedLockstepVersion = SyncSchema.lockstepVersion

    init(visibilityHorizon: Int64 = 0) {
        self.visibilityHorizon = visibilityHorizon
        // The default account is pre-provisioned with the suite key
        // world's corpus key id + proof hash — the fake twin of "the vault
        // row exists before any round" (the real server refuses a
        // vault-less caller at the fence; here, an unprovisioned USER does
        // the same).
        // Provisioned ENROLLED (13y UNIT B): the secret present and the
        // hash at its post-enrollment value — the fake twin of "the
        // account's first round enrolled long ago", so the single-user
        // suites run the challenge protocol without each replaying the
        // enroll road (which has its own pins).
        accounts[Self.defaultUserID] = Account(
            vault: VaultRow(
                corpusKeyID: SyncTestKeys.corpusKeyID,
                keyProofHash: SyncTestKeys.macKeyHash,
                keyProofMacSecret: SyncTestKeys.macKeyWire))
    }

    func setDeployedLockstepVersion(_ version: Int) {
        deployedLockstepVersion = version
    }

    /// 13y: set the SERVED horizon (see `servedVisibilityHorizonMillis`).
    func setServedVisibilityHorizonMillis(_ millis: Int64) {
        servedVisibilityHorizonMillis = millis
    }

    /// 13y (`SyncRotationTransport`): the served A5 horizon — the fake
    /// twin of `sync_visibility_horizon_ms()`.
    func visibilityHorizonMillis() async throws -> Int64 {
        servedVisibilityHorizonMillis
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
    /// comparand), its proof hash (pre-13x — nil models the author's
    /// pre-postures row, the NULL-hash arm; every other provisioning names
    /// the hash its key world proves), and its entitlement. The
    /// real-world analogue is signup + vault setup + the entitlement grant.
    /// An account that already exists keeps its partition, cursors and
    /// ledger — only the vault row (revision 1) and the entitlement reset
    /// (the `ScriptedVaultServer`'s create lands here for a user whose
    /// partition may already carry rows).
    /// `keyProofMacSecret` (13y UNIT B): the Vault-held kp2 (base64) —
    /// non-nil provisions the account ENROLLED; nil (the default) leaves
    /// it un-enrolled, and its first gated call takes the enroll road
    /// (the production shape for every fresh account).
    func provisionAccount(
        _ userID: String, vaultCorpusKeyID: String, keyProofHash: String?, entitled: Bool = true,
        keyProofMacSecret: String? = nil
    ) {
        var account = accounts[userID] ?? Account(vault: VaultRow())
        account.vault = VaultRow(
            corpusKeyID: vaultCorpusKeyID, keyProofHash: keyProofHash,
            keyProofMacSecret: keyProofMacSecret)
        account.entitled = entitled
        accounts[userID] = account
    }

    /// The re-key act's server half, done by hand (the 14c-era hook —
    /// `AccountRekey`'s real road goes through the `ScriptedVaultServer`):
    /// the account's vault now names a new corpus key id AND the new
    /// master's proof hash (a vault rewrite installs both; CF-8 writes the
    /// NEW vault FIRST — from this moment every stale writer is fenced,
    /// and every stale proof refused).
    func setVaultRow(
        corpusKeyID: String, keyProofHash: String?,
        keyProofMacSecret: String? = nil,
        for userID: String = FakeSyncServer.defaultUserID
    ) {
        accounts[userID]?.vault.corpusKeyID = corpusKeyID
        accounts[userID]?.vault.keyProofHash = keyProofHash
        accounts[userID]?.vault.keyProofMacSecret = keyProofMacSecret
    }

    /// The tier's server half: revoke/grant hosted sync.
    func setEntitled(_ entitled: Bool, for userID: String = FakeSyncServer.defaultUserID) {
        accounts[userID]?.entitled = entitled
    }

    /// The auto-adopt latitude (recorded emulation choice, born for the
    /// vault-bootstrap runner — deleted at VX-329's ladder round 1): the
    /// account's vault key id ADOPTS the first round's presented id —
    /// models "the same act that just WROTE the vault now drains through
    /// it" (the runner's create-vault → reinit → drain sequence, where
    /// the fence's comparand is by construction the key the drain
    /// presents). The proof hash adopts the same way (the NULL-hash arm).
    /// Fence and proof tests always set explicit values instead — never
    /// this. (Since pre-13x 1b the linked `ScriptedVaultServer` provisions
    /// the account at vault CREATE, so no world here needs this; kept for
    /// any world that composes the fakes apart.)
    func setVaultKeyAutoAdopt(for userID: String = FakeSyncServer.defaultUserID) {
        accounts[userID]?.vault.corpusKeyID = nil
        accounts[userID]?.vault.keyProofHash = nil
        accounts[userID]?.vault.keyProofMacSecret = nil
    }

    /// Test inspection: the account's vault row as the RPCs see it.
    func vaultRow(for userID: String = FakeSyncServer.defaultUserID) -> VaultRow? {
        accounts[userID]?.vault
    }

    /// A per-account transport handle for the multi-tenant suites — the
    /// fake twin of "a device authenticated as this user". Nonisolated:
    /// it only captures the actor reference.
    nonisolated func connection(as userID: String) -> FakeSyncServerConnection {
        FakeSyncServerConnection(server: self, userID: userID)
    }

    // MARK: SyncTransport (the default account — the single-user suites'
    // implicit caller)

    func push(_ batch: [SyncRow], activeKeyID: String, keyProof: SyncKeyProof) throws -> [SyncPushOutcome] {
        try push(batch, activeKeyID: activeKeyID, keyProof: keyProof, as: Self.defaultUserID)
    }

    func pull(since: Int64, limit: Int, activeKeyID: String, keyProof: SyncKeyProof, deviceID: String?) throws -> [SyncPulledRow] {
        try pull(
            since: since, limit: limit, activeKeyID: activeKeyID, keyProof: keyProof,
            deviceID: deviceID, as: Self.defaultUserID)
    }

    func schemaVersion() -> Int {
        deployedLockstepVersion
    }

    // MARK: SyncChallengeTransport (default account — 13y UNIT B)

    func fetchChallenges(_ count: Int) -> [String] {
        fetchChallenges(count, as: Self.defaultUserID)
    }

    func enrollKeyProof(legacyProof: String, macKey: String, activeKeyID: String) throws {
        try enrollKeyProof(
            legacyProof: legacyProof, macKey: macKey, activeKeyID: activeKeyID,
            as: Self.defaultUserID)
    }

    // MARK: SyncPurgeTransport (default account)

    func syncHorizon(activeKeyID: String, keyProof: SyncKeyProof) throws -> Int64 {
        try syncHorizon(activeKeyID: activeKeyID, keyProof: keyProof, as: Self.defaultUserID)
    }

    func purgeLedger(since: Int64, activeKeyID: String, keyProof: SyncKeyProof) throws -> SyncPurgeLedgerPage {
        try purgeLedger(since: since, activeKeyID: activeKeyID, keyProof: keyProof, as: Self.defaultUserID)
    }

    func executePurge(_ rows: [SyncPurgeTarget], activeKeyID: String, keyProof: SyncKeyProof) throws -> Int64 {
        try executePurge(rows, activeKeyID: activeKeyID, keyProof: keyProof, as: Self.defaultUserID)
    }

    // MARK: SyncRotationTransport (default account)

    func reencrypt(_ rows: [SyncRow], activeKeyID: String, keyProof: SyncKeyProof) throws -> [SyncReencryptOutcome] {
        try reencrypt(rows, activeKeyID: activeKeyID, keyProof: keyProof, as: Self.defaultUserID)
    }

    // MARK: The tenant-scoped halves (the RPC bodies' fake twins)

    // MARK: 13y UNIT B — the challenge machinery (12's twins)

    /// Per-user unconsumed nonces (the `key_proof_challenge` twin), in
    /// mint order (eviction is oldest-first). Keyed by user, NOT by
    /// account: `sync_challenge` is session-gated only — no vault
    /// requirement (a not-yet-provisioned caller mints too).
    private var challengeStashes: [String: [(nonce: Data, issuedAt: Int64)]] = [:]
    /// The 5-minute TTL, in the fake's LOGICAL clock ticks — settable so
    /// the expiry pin can cross it; the huge default keeps every suite
    /// that advances the clock (the A5 arms) inside the window.
    private var challengeTTLTicks: Int64 = .max / 4

    func setChallengeTTLTicks(_ ticks: Int64) {
        challengeTTLTicks = ticks
    }

    /// Test inspection: the user's live (unconsumed) nonce count.
    func liveChallengeCount(for userID: String = FakeSyncServer.defaultUserID) -> Int {
        challengeStashes[userID]?.count ?? 0
    }

    /// `sync_challenge(n)`'s twin: clamp 1...32, GC the caller's expired
    /// rows, mint, evict beyond 64 oldest-first.
    func fetchChallenges(_ count: Int, as userID: String) -> [String] {
        let granted = min(max(count, 1), 32)
        var stash = challengeStashes[userID] ?? []
        stash.removeAll { $0.issuedAt < clock - challengeTTLTicks }
        var minted: [String] = []
        for _ in 0..<granted {
            var nonce = Data(count: 32)
            for i in 0..<32 { nonce[i] = UInt8.random(in: 0...255) }
            stash.append((nonce: nonce, issuedAt: clock))
            minted.append(nonce.base64EncodedString())
        }
        if stash.count > 64 {
            stash.removeFirst(stash.count - 64)
        }
        challengeStashes[userID] = stash
        return minted
    }

    /// `key_proof_enroll`'s twin: the fence, ONCE (an existing secret
    /// refuses — the racing loser proceeds), the OLD hash authorizing,
    /// the secret + the post-enroll hash landing together. ONE fake-only
    /// latitude, recorded: a NIL-hash row ADOPTS the first enrollment
    /// (the auto-adopt worlds' road — the real server refuses a hash-less
    /// enroll; fence and proof tests always set explicit values).
    func enrollKeyProof(
        legacyProof: String, macKey: String, activeKeyID: String, as userID: String
    ) throws {
        guard let account = accounts[userID],
              let fenceKey = account.vault.corpusKeyID else {
            throw SyncError.encryptionKeysReplaced
        }
        guard fenceKey == activeKeyID else {
            throw SyncError.encryptionKeysReplaced
        }
        guard account.vault.keyProofMacSecret == nil else {
            throw SyncError.keyProofAlreadyEnrolled
        }
        if let stored = account.vault.keyProofHash {
            guard let presented = KeyProof.hash(ofWireToken: legacyProof),
                  presented == stored else {
                throw SyncError.keyProofRefused
            }
        }
        guard let macRaw = Data(base64Encoded: macKey) else {
            throw SyncError.keyProofRefused
        }
        accounts[userID]?.vault.keyProofMacSecret = macKey
        accounts[userID]?.vault.keyProofHash = KeyProof.hash(ofToken: macRaw)
    }

    /// THE PROOF CHECK (12's `sync_key_proof_check` twin, the RULED
    /// order): vault present → the Vault-held secret (ABSENT refuses
    /// ENROLL, before any nonce is consumed) → the nonce → the TTL → the
    /// HMAC over `nonce ‖ ':' ‖ rpc` recomputed from the secret — and the
    /// nonce is CONSUMED ONLY WHEN THE WHOLE CHECK SUCCEEDS (R3-F1, the
    /// mirror's transactional truth: a refusing RAISE aborts the RPC's
    /// transaction and the consume's DELETE rolls back, so a nonce
    /// survives every refused attempt and is spent exactly once, by its
    /// one successful use). The actor's serialization makes
    /// check-then-remove-on-success equivalent to the SQL's atomic
    /// DELETE … RETURNING + rollback-on-raise.
    private func checkProof(_ keyProof: SyncKeyProof, rpc: String, for userID: String) throws {
        guard accounts[userID] != nil else {
            throw SyncError.encryptionKeysReplaced
        }
        guard let secret = accounts[userID]?.vault.keyProofMacSecret,
              let secretRaw = Data(base64Encoded: secret) else {
            throw SyncError.keyProofEnrollRequired
        }
        guard let nonce = Data(base64Encoded: keyProof.challenge) else {
            throw SyncError.keyProofChallengeStale
        }
        var stash = challengeStashes[userID] ?? []
        guard let index = stash.firstIndex(where: { $0.nonce == nonce }) else {
            throw SyncError.keyProofChallengeStale
        }
        guard stash[index].issuedAt >= clock - challengeTTLTicks else {
            // Rollback semantics: the expired nonce STAYS (the real row
            // survives the RAISE and lingers until the mint's GC) — it can
            // never succeed later, only refuse stale again.
            throw SyncError.keyProofChallengeStale
        }
        let expected = KeyProofMaterial(legacyWireToken: "", macKey: secretRaw)
            .proof(challenge: keyProof.challenge, rpc: rpc).proof
        guard expected == keyProof.proof else {
            // Rollback semantics: a refused proof (the splice, a wrong
            // key) leaves the nonce standing — the pair keeps exactly the
            // one spend on its own door it always had.
            throw SyncError.keyProofRefused
        }
        stash.remove(at: index)
        challengeStashes[userID] = stash
    }

    /// The round-level gates, in the SQL's order: account (auth) → fence →
    /// PROOF (challenge-verified, bound to the calling RPC's name) →
    /// entitlement. Any refusal aborts the WHOLE call before any row is
    /// touched, exactly as the RPC's RAISE does.
    private func gatedAccount(
        _ userID: String, activeKeyID: String, keyProof: SyncKeyProof, rpc: String
    ) throws -> Account {
        guard var account = accounts[userID] else {
            // The real server: an authenticated caller with NO key_vault
            // row hits the fence's missing-vault arm. An unprovisioned
            // fake account refuses the same way.
            throw SyncError.encryptionKeysReplaced
        }
        if account.vault.corpusKeyID == nil {
            // The auto-adopt latitude (`setVaultKeyAutoAdopt`): the vault
            // was just written by this very actor; its id is the one now
            // presented.
            account.vault.corpusKeyID = activeKeyID
            accounts[userID] = account
        }
        guard account.vault.corpusKeyID == activeKeyID else {
            throw SyncError.encryptionKeysReplaced
        }
        try checkProof(keyProof, rpc: rpc, for: userID)
        guard accounts[userID]!.entitled else {
            throw SyncError.syncNotEntitled
        }
        return accounts[userID]!
    }

    // MARK: 13y UNIT B — the abuse guard's twin (12's quota, memo §4)

    private struct WriteBudget {
        var lifetimeRows: Int64 = 0
        var windowStart: Int64
        var windowRows: Int64 = 0
    }
    private var writeBudgets: [String: WriteBudget] = [:]
    /// The ruled numbers as defaults; settable so the quota pins can
    /// cross them without minting half a million rows. The window runs
    /// on the LOGICAL clock (ticks-as-seconds — a day's worth by
    /// default, far past anything the A5 arms advance).
    private var quotaBatchCap = 2_000
    private var quotaLifetimePool: Int64 = 500_000
    private var quotaWindowLimit: Int64 = 50_000
    private var quotaWindowTicks: Int64 = 86_400

    func setWriteQuota(
        batchCap: Int = 2_000, lifetimePool: Int64 = 500_000,
        windowLimit: Int64 = 50_000, windowTicks: Int64 = 86_400
    ) {
        quotaBatchCap = batchCap
        quotaLifetimePool = lifetimePool
        quotaWindowLimit = windowLimit
        quotaWindowTicks = windowTicks
    }

    /// Test inspection: the account's budget facts.
    func writeBudgetFacts(
        for userID: String = FakeSyncServer.defaultUserID
    ) -> (lifetime: Int64, windowRows: Int64)? {
        writeBudgets[userID].map { ($0.lifetimeRows, $0.windowRows) }
    }

    /// The pre-loop check (12's letter): the cap, the pool, the tumbling
    /// window — the REFUSE-WHOLE boundary, no overshoot.
    private func checkWriteQuota(batchRows: Int, for userID: String) throws {
        if batchRows > quotaBatchCap {
            throw SyncError.writeQuotaExceeded(retryAfterSeconds: 0)
        }
        var budget = writeBudgets[userID] ?? WriteBudget(windowStart: clock)
        if budget.lifetimeRows >= quotaLifetimePool {
            if clock - budget.windowStart >= quotaWindowTicks {
                budget.windowStart = clock
                budget.windowRows = 0
            } else if budget.windowRows + Int64(batchRows) > quotaWindowLimit {
                throw SyncError.writeQuotaExceeded(
                    retryAfterSeconds: Int(budget.windowStart + quotaWindowTicks - clock))
            }
        }
        writeBudgets[userID] = budget
    }

    /// The post-loop increment: the ACTUAL accepted rows (CAS rejects
    /// burn nothing — 12's letter).
    private func recordAcceptedWrites(_ accepted: Int, for userID: String) {
        guard accepted > 0 else { return }
        var budget = writeBudgets[userID] ?? WriteBudget(windowStart: clock)
        budget.lifetimeRows += Int64(accepted)
        budget.windowRows += Int64(accepted)
        writeBudgets[userID] = budget
    }

    // MARK: 13y ladder R1 (F-R3) — the truncate door's re-auth, DERIVED FROM
    // THE RIDDEN SESSION (never a defaulted bool)

    /// The re-auth claim `account_data_truncate` reads comes from the
    /// SESSION the call rides (12 §7e reads `auth.jwt()->'amr'`). F-R3
    /// retired the old per-user default-fresh Bool (which modeled
    /// production's steady state — a stale standing session — NOWHERE): the
    /// truncate call now STATES which session it rode. A `.freshGrant` is
    /// the door's own flow (it adopts a just-minted grant — a fresh amr); a
    /// `.staleSession` is the standing session (or a stolen long-lived
    /// token), whose amr sits outside the window. `sync_purge_execute`
    /// carries no re-auth at all (F-R1), so it takes no claim.
    enum TruncateReauth: Sendable {
        /// A freshly-granted session — the truncate road's adopt-fresh-grant
        /// flow (`AccountLifecycleClient` rides a new grant's token).
        case freshGrant
        /// The standing session, whose amr is stale (or a stolen token).
        case staleSession
    }

    private func checkTruncateReauth(_ reauth: TruncateReauth) throws {
        guard case .freshGrant = reauth else {
            throw SyncError.reauthRequired
        }
    }

    // MARK: 13y UNIT B — the direct-call test helper

    /// Test support: ONE fresh proof for a DIRECT server call — mints a
    /// nonce as the user and binds it to `rpc` under `material`'s kp2.
    /// Pure minting: it never enrolls (the enroll-road pins drive that
    /// door explicitly).
    func mintProof(
        rpc: String, for userID: String = FakeSyncServer.defaultUserID,
        material: KeyProofMaterial = SyncTestKeys.proofMaterial
    ) -> SyncKeyProof {
        let nonce = fetchChallenges(1, as: userID)[0]
        return material.proof(challenge: nonce, rpc: rpc)
    }

    /// The client-carried owner guard (the RPC's RAISE, whole-batch): a row
    /// of an owner-carrying table that does not carry EXACTLY the caller's
    /// own owner_id refuses the call — another account's uid, a JSON null,
    /// and an absent column alike.
    private func requireOwnerStamps(_ batch: [SyncRow], as userID: String) throws {
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
    }

    /// Wire fidelity (the plan's fake-server-drift risk): real payloads
    /// cross jsonb, which normalizes scalar types (`.real(0.0)` →
    /// `.integer(0)`). Round-trip every stored row through JSON so engine
    /// flows see the same normalization the real mirror would produce.
    private func normalized(_ row: SyncRow) throws -> SyncRow {
        try JSONDecoder().decode(SyncRow.self, from: JSONEncoder().encode(row))
    }

    func push(
        _ batch: [SyncRow], activeKeyID: String, keyProof: SyncKeyProof, as userID: String
    ) throws -> [SyncPushOutcome] {
        _ = try gatedAccount(userID, activeKeyID: activeKeyID, keyProof: keyProof, rpc: "sync_push")
        // Validated for the WHOLE batch BEFORE any row applies: the RPC's
        // RAISE aborts the whole transaction, so a partial application
        // here would be emulation drift.
        try requireOwnerStamps(batch, as: userID)
        // 13y UNIT B (12's quota, memo §4): the ONLY quota'd door — the
        // cap, the pool, the tumbling window, refuse-whole; the increment
        // counts the ACTUAL accepted rows after the loop.
        try checkWriteQuota(batchRows: batch.count, for: userID)
        var acceptedRows = 0
        defer { recordAcceptedWrites(acceptedRows, for: userID) }
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
            // 13y: the accept stamp draws from the CALLER's own counter
            // (the trigger's `next_tenant_seq(new.owner_id)` — the
            // partition IS the stamp here).
            let granted = nextTenantSeq(for: userID)
            var accepted = incoming
            accepted.syncVersion = currentVersion + 1
            accounts[userID]!.tables[incoming.table, default: [:]][incoming.rowID] =
                StoredRow(row: try normalized(accepted), serverSeq: granted,
                          writtenAt: clock, committed: !heldTransaction)
            acceptedRows += 1
            return .accepted(newVersion: accepted.syncVersion, serverSeq: granted)
        }
    }

    func pull(
        since: Int64, limit: Int, activeKeyID: String, keyProof: SyncKeyProof, deviceID: String? = nil,
        as userID: String
    ) throws -> [SyncPulledRow] {
        let account = try gatedAccount(userID, activeKeyID: activeKeyID, keyProof: keyProof, rpc: "sync_pull")
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

    // MARK: pre-13x — the rotation's write (the `sync_reencrypt` twin)

    /// Per row: the payload replaced where the version matches — a FRESH
    /// seq (above the rotation seq), the version KEPT; a moved or absent
    /// row `skipped` with the server's current version. The push posture
    /// (the gate + the owner guard); own partition only.
    func reencrypt(
        _ rows: [SyncRow], activeKeyID: String, keyProof: SyncKeyProof, as userID: String
    ) throws -> [SyncReencryptOutcome] {
        // NO quota, deliberately (memo §4): a rotation rewrites the
        // whole corpus by design.
        _ = try gatedAccount(userID, activeKeyID: activeKeyID, keyProof: keyProof, rpc: "sync_reencrypt")
        try requireOwnerStamps(rows, as: userID)
        return try rows.map { incoming in
            guard let current = accounts[userID]?.tables[incoming.table]?[incoming.rowID] else {
                return .skipped(currentVersion: nil)
            }
            guard current.row.syncVersion == incoming.syncVersion else {
                return .skipped(currentVersion: current.row.syncVersion)
            }
            // The bytes swapped, the version KEPT (never bumped), a fresh
            // seq stamped — from the caller's own counter (13y).
            let granted = nextTenantSeq(for: userID)
            accounts[userID]!.tables[incoming.table, default: [:]][incoming.rowID] =
                StoredRow(row: try normalized(incoming), serverSeq: granted,
                          writtenAt: clock, committed: true)
            return .replaced(serverSeq: granted)
        }
    }

    // MARK: pre-13x — the ONE vault write road (the `key_vault_update` twin)

    /// What the RPC returns: the new revision and the rotation seq (nil
    /// unless this call began a rotation or carried one through).
    struct VaultUpdateReceipt: Equatable {
        let revision: Int
        let rotationStartedSeq: Int64?
    }

    /// The `key_vault_update` RPC's fake twin, in the SQL's order: absent
    /// → the proof (the NULL-hash arm included) → the rotation logic
    /// (decision 32's refusal) → the revision CAS → the write. The row's
    /// FORMAT columns live on the `ScriptedVaultServer`, which calls this
    /// FIRST and stores the payload only when it returns.
    func keyVaultUpdate(
        as userID: String, expectedRevision: Int, keyProof: SyncKeyProof,
        newCorpusKeyID: String, newKeyProofHash: String?,
        newKeyProofMac: String? = nil,
        previousCorpusKeyID: String?, previousCorpusKey: String?,
        updatedByDevice: String? = nil
    ) throws -> VaultUpdateReceipt {
        guard var account = accounts[userID] else {
            throw KeyVaultClientError.vaultAbsent
        }
        do {
            try checkProof(keyProof, rpc: "key_vault_update", for: userID)
        } catch SyncError.keyProofRefused {
            throw KeyVaultClientError.keyProofRefused
        } catch SyncError.keyProofEnrollRequired {
            throw KeyVaultClientError.keyProofEnrollRequired
        } catch SyncError.keyProofChallengeStale {
            throw KeyVaultClientError.keyProofChallengeStale
        }
        account = accounts[userID]!
        // The R1-2 revision CAS, pre-checked under the held lock (12's
        // 13y UNIT B letter: the successor rule must never mask a stale
        // fetch's honest refetch contract).
        guard account.vault.revision == expectedRevision else {
            throw KeyVaultClientError.vaultRevisionConflict
        }
        // 13y UNIT B (12's successor block, memo §3): a NEW hash lands
        // ONLY beside its sha256-matched key_proof_mac — the row's hash
        // and the Vault-held secret move TOGETHER or not at all.
        if let mac = newKeyProofMac {
            guard let macRaw = Data(base64Encoded: mac),
                  let hash = newKeyProofHash,
                  KeyProof.hash(ofToken: macRaw) == hash else {
                throw KeyVaultClientError.keyProofRefused
            }
        } else if let hash = newKeyProofHash, hash != account.vault.keyProofHash {
            throw KeyVaultClientError.keyProofRefused
        }
        // The id and the wrap travel together, never one without the other.
        guard (previousCorpusKeyID == nil) == (previousCorpusKey == nil) else {
            throw FakeSyncServerError.previousKeyHalfMissing
        }
        let nextSeq: Int64?
        if previousCorpusKey == nil {
            // pre-13x ladder round 1, F1 (BLOCKER-1) — THE COMPLETION GUARD,
            // the maintenance artifact's twin: clearing a standing previous
            // key is refused while any row of the caller's partition in a
            // table that CARRIES CIPHERTEXT still sits below the rotation
            // seq (a straggler the visibility window hid from the walk).
            // Every stored row counts, committed or held — the SQL's FOR
            // UPDATE waits for every in-flight old-proof push to commit
            // before the clearing write runs, so its count is over committed
            // rows that include them. Only rows that CARRY ciphertext count
            // (at least one encrypted column not null) — an all-plain
            // table's rows and an all-NULL row are under no key.
            if account.vault.previousCorpusKey != nil,
               let startedSeq = account.vault.rotationStartedSeq,
               rowsBelow(startedSeq, in: account) > 0 {
                throw KeyVaultClientError.rotationRowsRemain
            }
            nextSeq = nil
        } else if account.vault.previousCorpusKey == nil {
            // A rotation begins: the next value of the CALLER'S OWN
            // counter — the same one the account's rows take (13y M3;
            // 12's `next_tenant_seq(caller)`), inside this call.
            nextSeq = nextTenantSeq(for: userID)
        } else if account.vault.previousCorpusKey == previousCorpusKey
                    && account.vault.previousCorpusKeyID == previousCorpusKeyID {
            // The carry-through (decision 32's precision): the SAME
            // previous key — a re-wrap mid-rotation — keeps the seq.
            nextSeq = account.vault.rotationStartedSeq
        } else {
            throw KeyVaultClientError.rotationInProgress
        }
        guard account.vault.revision == expectedRevision else {
            throw KeyVaultClientError.vaultRevisionConflict
        }
        account.vault.corpusKeyID = newCorpusKeyID
        if let newKeyProofHash { account.vault.keyProofHash = newKeyProofHash }
        if let newKeyProofMac { account.vault.keyProofMacSecret = newKeyProofMac }
        account.vault.previousCorpusKeyID = previousCorpusKeyID
        account.vault.previousCorpusKey = previousCorpusKey
        account.vault.rotationStartedSeq = nextSeq
        // Decision 34: the writer's name, from the payload (nil when the
        // payload carries none — the SQL writes whatever it is handed).
        account.vault.updatedByDevice = updatedByDevice
        account.vault.revision = expectedRevision + 1
        accounts[userID] = account
        return VaultUpdateReceipt(revision: account.vault.revision, rotationStartedSeq: nextSeq)
    }

    /// The guard's count: rows that CARRY CIPHERTEXT (`SyncSchema
    /// .rowCarriesCiphertext` — at least one encrypted column not null; the
    /// SQL's per-table `is not null` predicate is pinned equal to the
    /// registry's columns) with a seq below the rotation seq, in one
    /// partition. A row with every encrypted column NULL never counts.
    private func rowsBelow(_ seq: Int64, in account: Account) -> Int {
        account.tables.values.reduce(0) { count, rows in
            count + rows.values.filter { $0.serverSeq < seq && SyncSchema.rowCarriesCiphertext($0.row) }.count
        }
    }

    /// Test inspection (F1): how many ciphertext-carrying rows of an
    /// account still sit below a seq — what the guard would count.
    func ciphertextRowsBelow(_ seq: Int64, for userID: String = FakeSyncServer.defaultUserID) -> Int {
        accounts[userID].map { rowsBelow(seq, in: $0) } ?? 0
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

    func syncHorizon(activeKeyID: String, keyProof: SyncKeyProof, as userID: String) throws -> Int64 {
        let account = try gatedAccount(userID, activeKeyID: activeKeyID, keyProof: keyProof, rpc: "sync_horizon")
        let live = account.deviceCursors.values
            .filter { $0.seenAt + horizonDropoutTicks > clock }
            .map(\.lastSeq)
        return live.min() ?? 0
    }

    func purgeLedger(
        since: Int64, activeKeyID: String, keyProof: SyncKeyProof, as userID: String
    ) throws -> SyncPurgeLedgerPage {
        let account = try gatedAccount(userID, activeKeyID: activeKeyID, keyProof: keyProof, rpc: "sync_purge_ledger")
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
        _ rows: [SyncPurgeTarget], activeKeyID: String, keyProof: SyncKeyProof, as userID: String
    ) throws -> Int64 {
        _ = try gatedAccount(userID, activeKeyID: activeKeyID, keyProof: keyProof, rpc: "sync_purge_execute")
        // 13y ladder R1 (F-R1): NO re-auth window on this door — the 13j
        // janitor calls it UNATTENDED, so a re-auth check would freeze the
        // autonomous purge pipeline. The gate (challenge-verified proof) is
        // its wall; the re-auth window stays on account_data_truncate only.
        // 13y M2: the granted ledger seq is the caller's own.
        let granted = nextTenantSeq(for: userID)
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

    /// The DEFAULT account's head — the single-user suites' exact old
    /// meaning (one tenant minted everything, so its head was the global
    /// one). Multi-tenant reads name the account.
    var headSeq: Int64 { headSeq(for: Self.defaultUserID) }

    /// 13y: one account's sequence head — what its next mint exceeds and
    /// what its devices' cursors rest at when fully caught up.
    func headSeq(for userID: String) -> Int64 {
        tenantSeqs[userID] ?? tenantFloorSeq(for: userID)
    }

    func currentRow(
        table: String, rowID: String, for userID: String = FakeSyncServer.defaultUserID
    ) -> SyncRow? {
        accounts[userID]?.tables[table]?[rowID]?.row
    }

    /// The row's current `server_seq` — its position in the changefeed
    /// (re-stamped on every accepted change). For pins about ARRIVAL
    /// ORDER, which is what the seq is.
    func currentSeq(
        table: String, rowID: String, for userID: String = FakeSyncServer.defaultUserID
    ) -> Int64? {
        accounts[userID]?.tables[table]?[rowID]?.serverSeq
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

    /// One account's stored rows WITH their seqs — the rotation pins read
    /// which key a row is under by its position (decision 31).
    func storedRowsWithSeqs(for userID: String = FakeSyncServer.defaultUserID) -> [SyncPulledRow] {
        (accounts[userID]?.tables.values.flatMap { $0.values } ?? [])
            .map { SyncPulledRow(row: $0.row, serverSeq: $0.serverSeq) }
            .sorted { $0.serverSeq < $1.serverSeq }
    }

    // MARK: Phase 14b — wipe-and-repush (ruling R-2)

    /// Truncates every stored data row — the fake twin of the gate's
    /// data-table truncate artifact. Provisioning (vault rows,
    /// entitlement) SURVIVES, exactly as the real truncate never touches
    /// `key_vault` or `entitlement`; the per-owner counters (13y) are
    /// deliberately NOT reset: the ordering authority stays monotonic
    /// per owner across the wipe (SyncSpec §9), exactly as 12's counter
    /// table survives the real truncate.
    func wipe() {
        for user in accounts.keys {
            accounts[user]!.tables = [:]
        }
    }

    /// The account-scoped truncate (CF-8's re-key road, 09's
    /// `account_data_truncate` RPC, pre-13x-gated): one tenant's data rows
    /// only — through the gate, so the right key id WITHOUT the proof
    /// deletes nothing. device_cursor and purged_row are untouched (10's
    /// letter) — and so is the account's counter (13y, 12's letter: the
    /// owner's sequence stays monotonic across a re-key, cursors valid).
    func truncateAccount(
        _ userID: String, activeKeyID: String, keyProof: SyncKeyProof,
        reauth: TruncateReauth
    ) throws {
        _ = try gatedAccount(userID, activeKeyID: activeKeyID, keyProof: keyProof, rpc: "account_data_truncate")
        // 13y ladder R1 (F-R3): the re-auth claim is a property of the
        // SESSION this call rides — the gate (fence/proof) outranks it.
        try checkTruncateReauth(reauth)
        accounts[userID]?.tables = [:]
        // 13y UNIT B (memo §4): the POOL RESET — the repush after a
        // re-key is a first load (the adopt road's letter).
        writeBudgets[userID] = nil
    }

    /// The deletion door's purge (batch 2's `account_purge` RPC, her
    /// Round-5 ruling): the whole account goes — data partition, vault
    /// row, entitlement (the real RPC also removes the auth user;
    /// here the account's disappearance models it). SESSION-ONLY: no
    /// proof, no fence — deletion is mandated and loud (decision 12). A
    /// lingering device's next round refuses at the fence's missing-vault
    /// arm — the same backstop that covers the real world's
    /// JWT-until-expiry window.
    func purgeAccount(_ userID: String) {
        accounts[userID] = nil
        // 13y (12's account_purge letter): the account's counter goes with
        // it — a re-created account reads its own sequence from its start
        // (the adopt road's premise). UNIT B: the nonces, the budget row
        // and the Vault-held secret go too (the secret rides the vault
        // row here — accounts[userID] carries it).
        tenantSeqs[userID] = nil
        challengeStashes[userID] = nil
        writeBudgets[userID] = nil
    }
}

/// A device's authenticated handle on the fake server: the same transport
/// protocol, bound to one account — the fake twin of the JWT the real
/// transport carries per call.
struct FakeSyncServerConnection: SyncTransport, SyncPurgeTransport, SyncRotationTransport {
    let server: FakeSyncServer
    let userID: String

    func push(_ batch: [SyncRow], activeKeyID: String, keyProof: SyncKeyProof) async throws -> [SyncPushOutcome] {
        try await server.push(batch, activeKeyID: activeKeyID, keyProof: keyProof, as: userID)
    }

    func pull(since: Int64, limit: Int, activeKeyID: String, keyProof: SyncKeyProof, deviceID: String?) async throws -> [SyncPulledRow] {
        try await server.pull(
            since: since, limit: limit, activeKeyID: activeKeyID, keyProof: keyProof,
            deviceID: deviceID, as: userID)
    }

    func schemaVersion() async throws -> Int {
        await server.schemaVersion()
    }

    func fetchChallenges(_ count: Int) async throws -> [String] {
        await server.fetchChallenges(count, as: userID)
    }

    func enrollKeyProof(legacyProof: String, macKey: String, activeKeyID: String) async throws {
        try await server.enrollKeyProof(
            legacyProof: legacyProof, macKey: macKey, activeKeyID: activeKeyID, as: userID)
    }

    func syncHorizon(activeKeyID: String, keyProof: SyncKeyProof) async throws -> Int64 {
        try await server.syncHorizon(activeKeyID: activeKeyID, keyProof: keyProof, as: userID)
    }

    func purgeLedger(since: Int64, activeKeyID: String, keyProof: SyncKeyProof) async throws -> SyncPurgeLedgerPage {
        try await server.purgeLedger(since: since, activeKeyID: activeKeyID, keyProof: keyProof, as: userID)
    }

    func executePurge(_ rows: [SyncPurgeTarget], activeKeyID: String, keyProof: SyncKeyProof) async throws -> Int64 {
        try await server.executePurge(rows, activeKeyID: activeKeyID, keyProof: keyProof, as: userID)
    }

    func reencrypt(_ rows: [SyncRow], activeKeyID: String, keyProof: SyncKeyProof) async throws -> [SyncReencryptOutcome] {
        try await server.reencrypt(rows, activeKeyID: activeKeyID, keyProof: keyProof, as: userID)
    }

    func visibilityHorizonMillis() async throws -> Int64 {
        try await server.visibilityHorizonMillis()
    }
}

enum FakeSyncServerError: Error, Equatable {
    /// The 09 push guard's RAISE: a client-carried owner table's row named
    /// an owner other than the caller.
    case ownerMismatch(table: String, rowID: String)
    /// The vault update's RAISE (11): a previous corpus key travels as its
    /// id AND its wrap — one without the other refuses.
    case previousKeyHalfMissing
}
