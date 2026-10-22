import Foundation

/// One pulled row: the server-current payload (`row.syncVersion` = the
/// server's current version) plus the `server_seq` stamped when the server
/// last accepted a change to it. `server_seq` is the ONLY ordering authority
/// in the protocol (SyncSpec §9).
public struct SyncPulledRow: Equatable, Sendable, Codable {
    public let row: SyncRow
    public let serverSeq: Int64

    public init(row: SyncRow, serverSeq: Int64) {
        self.row = row
        self.serverSeq = serverSeq
    }
}

/// Per-row push verdict (SyncSpec §4). The server merges nothing: accept is
/// a compare-and-set (`base == current sync_version`), reject carries the
/// current server row so the client can merge deterministically and push
/// again. `rejected(current: nil)` is the degenerate mismatch where the
/// server has no row at all for a non-zero base.
///
/// `purged` (Phase 13j — the memo's §2 ledger): the pushed row's id is in
/// the account's content-free purged-ids ledger. The client DROPS the
/// outbox entry and its local copy instead of retrying — a stale peer can
/// never resurrect a purged row. This is what makes S2's one bent clause
/// safe: a tombstone may be physically removed only with a ledger entry
/// standing in its place.
public enum SyncPushOutcome: Equatable, Sendable {
    case accepted(newVersion: Int, serverSeq: Int64)
    case rejected(current: SyncPulledRow?)
    case purged
}

/// 13y UNIT B (the ruled memo §3) — ONE PER-REQUEST PROOF: the single-use
/// nonce (`challenge` on the wire) paired with the HMAC computed over it
/// under kp2, bound to the calling RPC's name (`key_proof` on the wire).
/// The pair travels as ONE value through the Swift seam so a call can
/// never carry one half without the other; `SupabaseTransport` splits it
/// into the two wire parameters, the fake verifies both. Minted by
/// `KeyProofMaterial.proof(challenge:rpc:)`; consumed by exactly one
/// request — a replay refuses server-side by construction.
public struct SyncKeyProof: Equatable, Sendable, Codable {
    /// The nonce, base64 — the wire `challenge` parameter.
    public let challenge: String
    /// The bound HMAC, base64 — the wire `key_proof` parameter.
    public let proof: String

    public init(challenge: String, proof: String) {
        self.challenge = challenge
        self.proof = proof
    }
}

/// 13y UNIT B — the challenge surface every gated call rides: the nonce
/// mint (`sync_challenge`) and the one enrollment road
/// (`key_proof_enroll`). `SyncTransport` INHERITS it (every round consumer
/// — the engine, the janitor, the rotation walk, the recency probe —
/// needs it, so unlike the single-consumer purge/rotation surfaces it is
/// not a separate opt-in); wrappers forward, fakes enforce — the standing
/// doctrine.
public protocol SyncChallengeTransport: Sendable {
    /// `sync_challenge(n)`: a batch of single-use base64 nonces
    /// (session-gated server-side; n is clamped to 32 there). The
    /// `SyncChallengeSigner` fetches once per round and consumes one per
    /// RPC call.
    func fetchChallenges(_ count: Int) async throws -> [String]

    /// `key_proof_enroll(kp1, kp2, active_key_id)`: the ONE enrollment
    /// road — the existing hash authorizes the successor, once per
    /// account. Throws `SyncError.keyProofAlreadyEnrolled` when a racing
    /// device won (callers treat it as success — kp2 is the same value,
    /// both derive from M; memo §7 edge 1).
    func enrollKeyProof(legacyProof: String, macKey: String, activeKeyID: String) async throws
}

/// The transport seam (SyncSpec §2): exactly two endpoints. The in-process
/// fake server (test support) and the Supabase RPC client are two
/// implementations of this one protocol — the engine never knows which it
/// is talking to.
public protocol SyncTransport: SyncChallengeTransport, Sendable {
    /// Pushes a batch; the result array is per-row, index-aligned with the
    /// batch. Each `SyncRow.syncVersion` is the CAS base (the row's last
    /// server-accepted version; 0 for never-accepted rows).
    ///
    /// `activeKeyID` (Phase 14c, THE DESIGN item 2 — the vault-key-id
    /// fence): the corpus key id this device's round seals with, compared
    /// server-side against the account's current `key_vault` row. A
    /// mismatch refuses the WHOLE round (`SyncError.encryptionKeysReplaced`
    /// — the CF-16 state), so a stale writer can never poison-push past a
    /// re-key. A REQUIRED parameter on the protocol, deliberately no
    /// default — wrappers forward, fakes enforce (the schemaVersion
    /// doctrine below): a wrapper that silently dropped the key id would
    /// bypass the fence in every test that composes it.
    ///
    /// `keyProof` (pre-13x, decision 12 — THE KEY PROOF; PER-REQUEST since
    /// 13y UNIT B, the ruled memo §3): the single-use nonce + the HMAC
    /// bound to THIS RPC's name, both in the request BODY (never a URL,
    /// never a header), verified server-side against the Vault-held kp2
    /// with the nonce consumed atomically. THE PROOF IS THE
    /// AUTHORIZATION — the key id is readable from the vault by any
    /// session; the proof is not. A session without it gets
    /// `SyncError.keyProofRefused` and nothing from the mirror. REQUIRED,
    /// no default — the `activeKeyID` doctrine exactly.
    func push(_ batch: [SyncRow], activeKeyID: String, keyProof: SyncKeyProof) async throws -> [SyncPushOutcome]

    /// Rows changed after `since`, ordered by `server_seq`, at most `limit`.
    /// State-based: each row appears once, in its current state, stamped
    /// with its latest seq — never an op log. `activeKeyID` as on `push`
    /// (both round halves are fenced).
    ///
    /// `deviceID` (Phase 13j — the memo's §5b: the cursor upsert rides the
    /// same round trip): non-nil on a round's FIRST window ONLY, where
    /// `since` is the device's COMMITTED cursor — the server records it
    /// monotonically into `device_cursor`, which is what makes the purge
    /// horizon computable at all. Mid-round windows pass nil (their
    /// `since` values are uncommitted fetch positions; recording one would
    /// over-report what the device has integrated if the apply never
    /// commits). A REQUIRED parameter, deliberately no default — wrappers
    /// forward, fakes record (the schemaVersion doctrine): a wrapper that
    /// silently dropped the device id would starve the horizon in every
    /// test that composes it.
    func pull(since: Int64, limit: Int, activeKeyID: String, keyProof: SyncKeyProof, deviceID: String?) async throws -> [SyncPulledRow]

    /// The mirror's deployed schema-version marker (SyncSpec §12's
    /// version-check mechanism — shipped with the Phase 11 lockstep event,
    /// the first post-sync migration to need it). The engine compares this
    /// against `SyncSchema.lockstepVersion` at the start of every round
    /// half and REFUSES on any mismatch (outbox intact, cursor unmoved).
    /// A pre-marker deployment (the 9c-era mirror, no `sync_meta` table)
    /// reports version 1. A hard protocol requirement, deliberately no
    /// default: wrappers forward, fakes declare — a transport that cannot
    /// answer must not sync.
    func schemaVersion() async throws -> Int
}

// MARK: - The purge surface (Phase 13j batch 6b — the memo's §4b/§5b)

/// One row a purge names — the (table, row) pair the janitor's family
/// expansion produced, or a purge intent's root.
public struct SyncPurgeTarget: Equatable, Hashable, Sendable, Codable {
    public let table: String
    public let rowID: String

    public init(table: String, rowID: String) {
        self.table = table
        self.rowID = rowID
    }
}

/// One purged-ids ledger entry: ids only, no words (the memo's §2 — the
/// content-free ledger that fences a returner).
public struct SyncPurgedRecord: Equatable, Sendable {
    public let table: String
    public let rowID: String
    public let purgedSeq: Int64

    public init(table: String, rowID: String, purgedSeq: Int64) {
        self.table = table
        self.rowID = rowID
        self.purgedSeq = purgedSeq
    }
}

/// A ledger page: the entries above the caller's scan point, plus the
/// coverage FLOOR — the seq below which ledger completeness is no longer
/// guaranteed (0 while ledger pruning is unbuilt; the future pruning rider
/// advances it, and a client whose scan point is below the floor takes the
/// SAY-SO-FIRST returner road, round 10).
public struct SyncPurgeLedgerPage: Equatable, Sendable {
    public let floor: Int64
    public let entries: [SyncPurgedRecord]

    public init(floor: Int64, entries: [SyncPurgedRecord]) {
        self.floor = floor
        self.entries = entries
    }
}

/// The purge transport surface (Phase 13j): the three server doors the
/// janitor needs beyond the round's push/pull. A SEPARATE protocol rather
/// than three new `SyncTransport` requirements, deliberately: the janitor
/// is the ONLY caller, so the dozens of test wrapper transports that feed
/// engines (gates, fault injectors, spies) never carry dead conformances —
/// while the real transport and the fake server conform to both, and the
/// session layer wires a janitor exactly when its transport can answer.
/// Within this protocol the standing doctrine holds: REQUIRED methods, no
/// defaults — wrappers forward, fakes enforce.
public protocol SyncPurgeTransport: Sendable {
    /// The account's lowest live-device cursor (the memo's §2 horizon rule:
    /// purge only what every device has already seen deleted). A device
    /// unseen for 60 days leaves the horizon (her round-8 ruling); an
    /// account with no recorded cursors answers 0 — and nothing is ≤ 0,
    /// which is the janitor's safe no-op.
    ///
    /// pre-13x: a READ, and the proof gates it too — a session without
    /// the keys gets nothing from the mirror, a seq included.
    func syncHorizon(activeKeyID: String, keyProof: SyncKeyProof) async throws -> Int64

    /// Ledger entries with `purged_seq > since`, plus the coverage floor.
    /// Proof-gated like the horizon (pre-13x).
    func purgeLedger(since: Int64, activeKeyID: String, keyProof: SyncKeyProof) async throws -> SyncPurgeLedgerPage

    /// Executes one family's purge server-side: deletes exactly the named
    /// rows inside the caller's own partition and records every one in the
    /// ledger, ONE transaction (the adjudication's note 1). Idempotent —
    /// a janitor resuming mid-family re-runs it safely. Returns the
    /// granted ledger seq (one per call: the purge is one event).
    func executePurge(_ rows: [SyncPurgeTarget], activeKeyID: String, keyProof: SyncKeyProof) async throws -> Int64
}

// MARK: - The rotation surface (pre-13x batch 1b — the design's §3.10,
// decision 6: version-neutral re-encryption)

/// One row's re-encryption verdict from `sync_reencrypt`, index-aligned
/// with the sent rows: `replaced` carries the FRESH `server_seq` the
/// trigger stamped (above the rotation seq — the seq rule then reads the
/// row under the current key; its `sync_version` is UNBUMPED, so no other
/// device's offline edit is ever rejected by a rotation and followers
/// apply nothing); `skipped` carries the server's current version (nil =
/// the row is gone) — the caller pulls and retries.
public enum SyncReencryptOutcome: Equatable, Sendable {
    case replaced(serverSeq: Int64)
    case skipped(currentVersion: Int?)
}

/// The rotation transport surface — a SEPARATE protocol (the 13j
/// `SyncPurgeTransport` precedent): the rotation driver (batch 2) is its
/// only caller, so the wrapper transports that feed engines never carry a
/// door they never exercise; the real transport and the fake server
/// conform. Same doctrine: REQUIRED methods, no defaults.
public protocol SyncRotationTransport: Sendable {
    /// Re-encrypt rows in place: each `SyncRow` carries its columns sealed
    /// under the CURRENT corpus key and, in `syncVersion`, the version the
    /// caller pulled it at (`expected_version` — the CAS). Own partition
    /// only; the gate (fence + proof) and the entitlement gate ride it
    /// exactly as a push's do.
    func reencrypt(_ rows: [SyncRow], activeKeyID: String, keyProof: SyncKeyProof) async throws -> [SyncReencryptOutcome]

    /// The server's A5 visibility horizon, in milliseconds — the value
    /// `sync_visibility_horizon_ms()` serves (Phase 13y, the R-13y-4 fork's
    /// Shape 1: the SAME function derives `sync_pull`'s filter, so the
    /// served value and the enforced value cannot drift). Nothing
    /// client-side hardcodes the horizon. Its one client consumer, the
    /// rotation walk's derived wait, left with today's road (VX-329 L1);
    /// the read stays as the served value's one client-visible authority.
    /// REQUIRED, no default — wrappers forward, fakes serve (the
    /// schemaVersion doctrine).
    func visibilityHorizonMillis() async throws -> Int64
}
