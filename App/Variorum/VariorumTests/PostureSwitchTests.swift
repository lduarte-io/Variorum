//
//  PostureSwitchTests.swift
//  VariorumTests
//
//  pre-13x batch 2b — ENTERING AND LEAVING CASTLE, the Mac half of §12's
//  pins, over the REAL runner composed on scratch leaves: a scratch KEYED
//  store (real SQLCipher, real key files beside it, the real export-and-swap
//  through a scratch binding), an EMULATED MIRROR (the fake server's push /
//  pull / reencrypt semantics + the key-proof fence, over the same emulated
//  `key_vault` the flow tests use — the vault's rotation seq claimed from the
//  mirror's one sequence, as the RPC does), the real `CorpusRotation` driver,
//  real custody material, in-memory Keychain backings. The core suite
//  (`CorpusRotationTests`, `StoreEncryptionMigrationTests`) proves the walk's
//  bytes and the file's crash matrix; THIS suite proves the composition — §4's
//  seven steps in order, the three seams' resumes, the offer over pre-switch
//  pairs only, leaving Castle, and decision 32 at the door.
//

import CryptoKit
import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The emulated vault (the flow tests' scripted vault, with the mirror's seq)

/// The raw-JSON `key_vault` double the app suites keep, served through the
/// vault client's `load` seam; the ONE vault write road is the RPC
/// (`VaultRPCEmulation`). What this twin ADDS: a rotation that BEGINS claims
/// its seq from the mirror's sequence (the RPC's `nextval` of the rows'
/// sequence) so the walk's "below the seq" reads the rows it should.
final class EmulatedVault: @unchecked Sendable {
    private let lock = NSLock()
    private var row: Data?
    private let claimRotationSeq: @Sendable () async -> Int64
    /// pre-13x ladder round 1, F1 (BLOCKER-1): THE COMPLETION GUARD's twin
    /// — asked, on a clearing write over a standing previous key, whether
    /// any ciphertext-carrying row of the mirror still sits below the
    /// rotation seq; true ⇒ the RPC refuses `VARIORUM_ROTATION_ROWS_REMAIN`
    /// and writes nothing (the maintenance artifact's letter).
    private let rowsRemainBelow: @Sendable (Int64) async -> Bool
    /// pre-13x 4b (§7 steps 5 and 7): a ONE-SHOT hook run INSIDE the next
    /// `key_vault_update` request, BEFORE its CAS — so another device's
    /// whole act can land between this device's fetch and its write, and
    /// the CAS refusal is produced by construction, never by a race the
    /// scheduler may or may not lose. Consumed before it runs (its own
    /// vault writes pass through).
    private var beforeUpdate: (@Sendable () async throws -> Void)?
    private(set) var updateCount = 0

    init(
        claimRotationSeq: @escaping @Sendable () async -> Int64,
        rowsRemainBelow: @escaping @Sendable (Int64) async -> Bool = { _ in false }
    ) {
        self.claimRotationSeq = claimRotationSeq
        self.rowsRemainBelow = rowsRemainBelow
    }

    func setBeforeUpdate(_ hook: @escaping @Sendable () async throws -> Void) {
        lock.withLock { beforeUpdate = hook }
    }

    /// 13y UNIT B, fix round 4 — THE ONE ACCOUNT'S enrollment state,
    /// held where the real server holds it: this row (the hash) and its
    /// Vault-secret twin (the `_emu` key in the row). The mirror
    /// consults and enrolls THROUGH this object; the split mirror/vault
    /// secrets of rounds 1–3 are retired whole. (Round 3's propagation
    /// hook regressed the suite because the hook moved the row hash
    /// AFTER the mirror recorded its pre-move `enrolledUnderHash`, so
    /// the signer's retry gate cleared the secret it had just enrolled
    /// and the same call's second ENROLL refusal surfaced —
    /// `KeyProofChallenge.swift`'s `guard !enrolled`.)
    var enrolledSecret: Data? {
        lock.withLock {
            guard let stored = row,
                  let current = (try? JSONSerialization.jsonObject(with: stored)) as? [String: Any],
                  let wire = current[VaultRPCEmulation.secretKey] as? String
            else { return nil }
            return Data(base64Encoded: wire)
        }
    }

    /// The enroll road's row rewrite — the HTTP route's twin (the
    /// request-shaped doubles reach `VaultRPCEmulation`'s enroll path;
    /// the mirror calls this directly): once, under the OLD hash's
    /// authorization; the secret and the post-enroll hash land TOGETHER.
    func enrollRoad(kp1: String, kp2: String) throws {
        try lock.withLock {
            guard let stored = row,
                  var current = (try? JSONSerialization.jsonObject(with: stored)) as? [String: Any]
            else { throw SyncError.encryptionKeysReplaced }
            guard current[VaultRPCEmulation.secretKey] == nil else {
                throw SyncError.keyProofAlreadyEnrolled
            }
            guard let presented = KeyProof.hash(ofWireToken: kp1),
                  (current["key_proof_hash"] as? String) == presented,
                  let mac = Data(base64Encoded: kp2)
            else { throw SyncError.keyProofRefused }
            current[VaultRPCEmulation.secretKey] = kp2
            current["key_proof_hash"] = KeyProof.hash(ofToken: mac)
            row = (try? JSONSerialization.data(withJSONObject: current)) ?? row
        }
    }

    private func takeBeforeUpdate() -> (@Sendable () async throws -> Void)? {
        lock.withLock {
            let hook = beforeUpdate
            beforeUpdate = nil
            return hook
        }
    }

    var load: @Sendable (URLRequest) async throws -> (Data, URLResponse) {
        { [weak self] request in
            guard let self else { throw URLError(.cancelled) }
            return try await self.respond(to: request)
        }
    }

    private func respond(to request: URLRequest) async throws -> (Data, URLResponse) {
        func response(_ status: Int, _ body: Data = Data()) -> (Data, URLResponse) {
            (body, HTTPURLResponse(
                url: request.url!, statusCode: status,
                httpVersion: "HTTP/1.1", headerFields: nil)!)
        }
        // 13y UNIT B: the vault door's challenge + enroll roads. The other
        // doubles reach them through their unconditional first
        // `serveUpdate` call; this one guards the update path before
        // delegating, so the two roads are routed here explicitly.
        if request.url?.path.hasSuffix("/rest/v1/rpc/sync_challenge") == true
            || request.url?.path.hasSuffix("/rest/v1/rpc/key_proof_enroll") == true {
            var current: Data? = lock.withLock { row }
            guard let served = VaultRPCEmulation.serveUpdate(request, row: &current) else {
                return response(404)
            }
            lock.withLock { row = current }
            return response(served.status, served.body)
        }
        if request.url?.path.hasSuffix("/rest/v1/rpc/key_vault_update") == true {
            if let hook = takeBeforeUpdate() { try await hook() }
            lock.withLock { updateCount += 1 }
            // F1 (BLOCKER-1): the completion guard — a payload that CLEARS
            // the previous key while the row carries one is refused while
            // a ciphertext row still sits below the rotation seq. Read
            // before the RPC body runs (the SQL checks under the row lock,
            // before its update); nothing is written on a refusal.
            let clearing: Int64? = lock.withLock {
                guard let body = request.httpBody,
                      let call = (try? JSONSerialization.jsonObject(with: body)) as? [String: Any],
                      let payload = call["payload"] as? [String: Any],
                      payload["corpus_previous_key_id"] == nil,
                      let stored = row,
                      let current = (try? JSONSerialization.jsonObject(with: stored)) as? [String: Any],
                      current["corpus_previous_key_id"] is String,
                      let seq = current["rotation_started_seq"] as? NSNumber
                else { return nil }
                return seq.int64Value
            }
            if let seq = clearing, await rowsRemainBelow(seq) {
                return response(400, Data(
                    #"{"code":"P0001","message":"\#(SyncServerRefusalMarker.rotationRowsRemain): refused by the mirror"}"#.utf8))
            }
            let (served, previousBefore, stored): (VaultRPCEmulation.Served?, String?, Data?) = lock.withLock {
                let before = row.flatMap {
                    ((try? JSONSerialization.jsonObject(with: $0)) as? [String: Any])?["corpus_previous_key_id"] as? String
                }
                let served = VaultRPCEmulation.serveUpdate(request, row: &row)
                return (served, before, row)
            }
            guard let served else { return response(404) }
            guard served.status == 200, previousBefore == nil, let current = stored,
                  var json = (try? JSONSerialization.jsonObject(with: current)) as? [String: Any],
                  json["corpus_previous_key_id"] is String
            else { return response(served.status, served.body) }
            // A rotation BEGAN in this call: its seq is the rows' sequence's next.
            let seq = await claimRotationSeq()
            json["rotation_started_seq"] = NSNumber(value: seq)
            let rewritten = try JSONSerialization.data(withJSONObject: json)
            lock.withLock { row = rewritten }
            let receipt: [String: Any] = ["revision": json["revision"] as Any, "rotation_started_seq": NSNumber(value: seq)]
            return response(200, try JSONSerialization.data(withJSONObject: receipt))
        }
        return lock.withLock {
            guard request.url?.path.hasSuffix("/rest/v1/key_vault") == true else {
                return response(404)
            }
            switch request.httpMethod {
            case "GET":
                guard let row else { return response(200, Data("[]".utf8)) }
                return response(200, Data("[".utf8) + row + Data("]".utf8))
            case "POST":
                if let refusal = VaultRPCEmulation.insertRefusal(request.httpBody) {
                    return response(refusal.status, refusal.body)
                }
                guard row == nil else { return response(409, Data(#"{"code":"23505"}"#.utf8)) }
                row = request.httpBody
                return response(201)
            case "PATCH":
                return response(VaultRPCEmulation.patchRefused.status, VaultRPCEmulation.patchRefused.body)
            default:
                return response(405)
            }
        }
    }
}

// MARK: - The emulated mirror

/// The fake server's push / pull / reencrypt over one sequence, gated by the
/// vault-key-id fence and the key proof read from the EMULATED vault (the
/// RPC's order: fence, then proof). Records every `reencrypt` batch; one
/// scripted crash seam for the mid-walk resume.
actor EmulatedMirror: SyncTransport, SyncRotationTransport {
    struct Stored: Equatable {
        var row: SyncRow
        var seq: Int64
        /// F1: the logical-clock tick the row was written at — the A5
        /// visibility horizon is measured against it (the fake server's
        /// `writtenAt`; the mirror's `server_written_at`).
        var writtenAt: Int64 = 0
    }

    /// pre-13x 3a: the 09 push guard's twin — a pushed row of an
    /// owner-carrying table must carry EXACTLY this account's `owner_id`
    /// (the fake server's `requireOwnerStamps`); nil = unchecked (the 2b/2c
    /// worlds seed owner-less rows and never claim a partition).
    enum OwnerRefusal: Error, Equatable { case ownerMismatch(table: String, rowID: String) }
    let ownerID: String?
    /// F1 (BLOCKER-1): rows written within the last `visibilityHorizon`
    /// ticks are never served by a pull (the mirror's `interval '2
    /// seconds'`; the fake server's model). 0 = no window (every standing
    /// world); the straggler pins set 2 and let the clock advance where
    /// production sleeps.
    let visibilityHorizon: Int64
    private var clock: Int64 = 0
    init(ownerID: String? = nil, visibilityHorizon: Int64 = 0) {
        self.ownerID = ownerID
        self.visibilityHorizon = visibilityHorizon
    }

    func advanceClock(by ticks: Int64) { clock += ticks }

    private var rows: [String: Stored] = [:]
    private(set) var seq: Int64 = 0
    private var vault: KeyVaultClient?
    private(set) var reencryptBatches: [[SyncRow]] = []
    private var crashNextReencrypt = false
    private(set) var pushes = 0
    private(set) var pulls = 0
    /// pre-13x 2c (the drain bound): a LOCAL write landing DURING the round
    /// — fired from inside the pull, the mid-round moment — for this many
    /// pulls (`Int.max` = a writer that never stops).
    private var onPull: (@Sendable () async throws -> Void)?
    private var pullsToFire = 0

    func attach(vault: KeyVaultClient, enrollment: EmulatedVault? = nil) {
        self.vault = vault
        self.enrollment = enrollment
    }
    func setCrashNextReencrypt(_ crash: Bool) { crashNextReencrypt = crash }
    func setOnPull(times: Int, _ hook: @escaping @Sendable () async throws -> Void) {
        onPull = hook
        pullsToFire = times
    }
    func claimSeq() -> Int64 { seq += 1; return seq }
    func stored() -> [String: Stored] { rows }

    /// F1: what the completion guard counts — rows that CARRY ciphertext
    /// (`SyncSchema.rowCarriesCiphertext`: at least one encrypted column not
    /// null) below the rotation seq, visible or not.
    func ciphertextRowsBelow(_ rotationSeq: Int64) -> Int {
        rows.values.filter { $0.seq < rotationSeq && SyncSchema.rowCarriesCiphertext($0.row) }.count
    }

    // 13y UNIT B (fix round 4's structural shape) — the mirror's
    // challenge protocol twin: minted single-use nonces, and the ONE
    // account's Vault-held secret consulted from the SHARED enrollment
    // state (`EmulatedVault.enrolledSecret` — attached beside the
    // client). A rotation's successor rule replaces that shared secret
    // at the vault write, and this gate simply reads the new one — the
    // real check's own shape, no hash comparison, no re-adopt machinery.
    private var challengeNonces: Set<String> = []
    private var enrollment: EmulatedVault?

    func fetchChallenges(_ count: Int) async throws -> [String] {
        (0..<max(count, 1)).map { _ in
            let nonce = Data((0..<32).map { _ in UInt8.random(in: 0...255) }).base64EncodedString()
            challengeNonces.insert(nonce)
            return nonce
        }
    }

    func enrollKeyProof(legacyProof: String, macKey: String, activeKeyID: String) async throws {
        guard let vault, let fetched = try await vault.fetchVault() else {
            throw SyncError.encryptionKeysReplaced
        }
        guard fetched.format.classKey(for: .corpus)?.keyID == activeKeyID else {
            throw SyncError.encryptionKeysReplaced
        }
        guard let enrollment else { throw SyncError.keyProofRefused }
        // The ONE enroll road (ALREADY_ENROLLED propagates — the
        // signer swallows it as success, memo §7 edge 1).
        try enrollment.enrollRoad(kp1: legacyProof, kp2: macKey)
    }

    /// 13y UNIT B — the DIRECT-CALL test helper (the core fake's
    /// `mintProof` idiom): enroll `material` when no secret is enrolled,
    /// mint one nonce, bind the proof to `rpc`. Direct RPC calls in tests
    /// mint through this; engine calls ride the signer as in production.
    func mintProof(rpc: String, material: KeyProofMaterial, activeKeyID: String) async throws -> SyncKeyProof {
        if enrollment?.enrolledSecret == nil {
            do {
                try await enrollKeyProof(
                    legacyProof: material.legacyWireToken, macKey: material.macKeyWire,
                    activeKeyID: activeKeyID)
            } catch SyncError.keyProofAlreadyEnrolled {}
        }
        let nonce = try await fetchChallenges(1)[0]
        return material.proof(challenge: nonce, rpc: rpc)
    }

    private func gate(activeKeyID: String, keyProof: SyncKeyProof, rpc: String) async throws {
        guard let vault, let fetched = try await vault.fetchVault() else {
            throw SyncError.encryptionKeysReplaced
        }
        guard fetched.format.classKey(for: .corpus)?.keyID == activeKeyID else {
            throw SyncError.encryptionKeysReplaced
        }
        // The ONE account's Vault-held secret — the shared enrollment
        // state (a rotation's successor rule already replaced it at the
        // vault write; this read simply sees the new one).
        guard let secret = enrollment?.enrolledSecret else {
            throw SyncError.keyProofEnrollRequired
        }
        guard challengeNonces.remove(keyProof.challenge) != nil else {
            throw SyncError.keyProofChallengeStale
        }
        let expected = KeyProofMaterial(legacyWireToken: "", macKey: secret)
            .proof(challenge: keyProof.challenge, rpc: rpc).proof
        guard expected == keyProof.proof else { throw SyncError.keyProofRefused }
    }

    private func requireOwnerStamps(_ batch: [SyncRow]) throws {
        guard let ownerID else { return }
        for incoming in batch {
            guard let table = SyncSchema.table(named: incoming.table),
                  table.plainColumns.contains("owner_id") else { continue }
            guard case .text(let pushed)? = incoming.columns["owner_id"], pushed == ownerID else {
                throw OwnerRefusal.ownerMismatch(table: incoming.table, rowID: incoming.rowID)
            }
        }
    }

    func push(_ batch: [SyncRow], activeKeyID: String, keyProof: SyncKeyProof) async throws -> [SyncPushOutcome] {
        try await gate(activeKeyID: activeKeyID, keyProof: keyProof, rpc: "sync_push")
        try requireOwnerStamps(batch)
        pushes += 1
        return batch.map { incoming in
            let key = "\(incoming.table)/\(incoming.rowID)"
            let currentVersion = rows[key]?.row.syncVersion ?? 0
            guard incoming.syncVersion == currentVersion else {
                return .rejected(current: rows[key].map { SyncPulledRow(row: $0.row, serverSeq: $0.seq) })
            }
            seq += 1
            var accepted = incoming
            accepted.syncVersion = currentVersion + 1
            rows[key] = Stored(row: accepted, seq: seq, writtenAt: clock)
            return .accepted(newVersion: accepted.syncVersion, serverSeq: seq)
        }
    }

    func pull(since: Int64, limit: Int, activeKeyID: String, keyProof: SyncKeyProof, deviceID: String?) async throws -> [SyncPulledRow] {
        try await gate(activeKeyID: activeKeyID, keyProof: keyProof, rpc: "sync_pull")
        pulls += 1
        if pullsToFire > 0, let onPull {
            if pullsToFire != Int.max { pullsToFire -= 1 }
            try await onPull()
        }
        return Array(rows.values
            .filter { $0.seq > since && $0.writtenAt <= clock - visibilityHorizon }
            .sorted { $0.seq < $1.seq }
            .prefix(limit)
            .map { SyncPulledRow(row: $0.row, serverSeq: $0.seq) })
    }

    func schemaVersion() async throws -> Int { SyncSchema.lockstepVersion }

    /// 13y (`SyncRotationTransport`): the served A5 horizon — the deployed
    /// constant. The Mac worlds always inject a `horizonWait`, so the
    /// production road never fetches here; the conformance keeps this
    /// emulation honest to the wire.
    func visibilityHorizonMillis() async throws -> Int64 { 2000 }

    func reencrypt(_ incomingRows: [SyncRow], activeKeyID: String, keyProof: SyncKeyProof) async throws -> [SyncReencryptOutcome] {
        try await gate(activeKeyID: activeKeyID, keyProof: keyProof, rpc: "sync_reencrypt")
        try requireOwnerStamps(incomingRows)
        if crashNextReencrypt {
            crashNextReencrypt = false
            throw URLError(.networkConnectionLost)
        }
        reencryptBatches.append(incomingRows)
        return incomingRows.map { incoming in
            let key = "\(incoming.table)/\(incoming.rowID)"
            guard let current = rows[key] else { return .skipped(currentVersion: nil) }
            guard current.row.syncVersion == incoming.syncVersion else {
                return .skipped(currentVersion: current.row.syncVersion)
            }
            seq += 1
            rows[key] = Stored(row: incoming, seq: seq, writtenAt: clock)
            return .replaced(serverSeq: seq)
        }
    }
}

private struct FixedKeyProvider: SyncKeyProviding {
    let keys: SyncEncryptionKeys
    func currentKeys() throws -> SyncEncryptionKeys { keys }
    func deviceIdentity() throws -> String { "device-fixed-2b" }
}

/// pre-13x 4b.4: a lifecycle that counts purges — the un-followed device's
/// Delete-account arm (the 3b brain runs whether or not a follow is owed).
private actor PurgeCountingLifecycle: AccountLifecycleProviding {
    private(set) var purges = 0
    func truncateAccountData(activeKeyID: String, keyProof: KeyProofMaterial) async throws -> [String: Int] { [:] }
    func purgeAccount() async throws -> AccountPurgeReport {
        purges += 1
        return AccountPurgeReport(dataRows: 0, vaultRows: 1, entitlementRows: 1, authUserRemoved: true)
    }
    func fetchEntitlements() async throws -> [AccountEntitlement] { [] }
}

// MARK: - The suite

@MainActor
@Suite("pre-13x 2b — entering and leaving Castle: the runner over a scratch keyed store + an emulated mirror", .serialized)
struct PostureSwitchTests {
    enum RekeyFault { case beforeWork, afterWork }

    /// What the scripted leaves saw.
    @MainActor
    final class Calls {
        var custodyTargets: [StoreAtOpenMode] = []
        var refuseNextCustody = false
        var rekeyFault: RekeyFault?
        var rekeys = 0
        var pauses = 0
        var resumes = 0
        var reconciles = 0
        let snapshotsTaken = LockIsolated(0)
        let listedAfterSnapshot = LockIsolated<Bool?>(nil)
        let deletedPairs = LockIsolated<[URL]>([])
        let log = LockIsolated<[String]>([])
    }

    @MainActor
    final class World {
        let dir: URL
        let storeURL: URL
        let backups: URL
        let oldKey: StoreKey
        let apple: AppleKey
        let binding: StoreBinding
        let view: AppDatabase
        let keyStore: DeviceKeyStore
        let vaultEmu: EmulatedVault?
        let vaultClient: KeyVaultClient?
        let mirror: EmulatedMirror?
        let guardBacking: InMemoryStoreKeyGuardBacking
        let appleBacking: InMemoryAppleKeyBacking
        let gate: StoreLaunchGate
        let defaults: UserDefaults
        let suiteName: String
        let calls = Calls()
        let biometry: Bool
        var keyInHand: StoreKey?
        var posture: Posture
        var alwaysAsk = false
        var oldMaterial: DeviceKeyMaterial?
        var seededTitles: [String: String] = [:]
        var titlesBeforeSwitch: [String: SyncValue] = [:]
        var runner: PostureSwitchRunner!
        var words: [String] = []
        /// pre-13x 5b (ledger 67): this device's own name — what its vault
        /// client stamps and what its runner reads the vault's writer against.
        var deviceName = "test device"
        /// F1 (BLOCKER-1): the walk's wait past the A5 horizon, as this world
        /// injects it — time passes on the EMULATED mirror's clock (production
        /// sleeps 2.5 s). A pin replaces it (a frozen clock, a counting wait)
        /// and the leaves read it lazily, so no re-arm is needed.
        var horizonWait: @Sendable () async throws -> Void = {}
        /// F2 (MAJOR-2): the scripted fresh snapshot FAILS (an unwritable
        /// Backups folder, a WAL that would not drain) — the leaf answers
        /// `.failed` and writes nothing.
        var snapshotFails = false
        /// F3 (MINOR-N2): a hook run INSIDE the `pauseSync` leaf — the one
        /// moment a pin can schedule a second road on the shared runner
        /// while the first holds the pause (its `busy` already set).
        var onPause: (@MainActor () -> Void)?

        init(dir: URL, storeURL: URL, backups: URL, oldKey: StoreKey, apple: AppleKey,
             binding: StoreBinding, view: AppDatabase, keyStore: DeviceKeyStore,
             vaultEmu: EmulatedVault?, vaultClient: KeyVaultClient?, mirror: EmulatedMirror?,
             guardBacking: InMemoryStoreKeyGuardBacking, appleBacking: InMemoryAppleKeyBacking,
             gate: StoreLaunchGate, defaults: UserDefaults, suiteName: String, biometry: Bool, posture: Posture) {
            self.dir = dir; self.storeURL = storeURL; self.backups = backups
            self.oldKey = oldKey; self.apple = apple; self.binding = binding; self.view = view
            self.keyStore = keyStore; self.vaultEmu = vaultEmu; self.vaultClient = vaultClient
            self.mirror = mirror; self.guardBacking = guardBacking; self.appleBacking = appleBacking
            self.gate = gate; self.defaults = defaults; self.suiteName = suiteName
            self.biometry = biometry; self.posture = posture
            self.keyInHand = oldKey
        }

        func tearDown() {
            binding.lock()
            defaults.removePersistentDomain(forName: suiteName)
            try? FileManager.default.removeItem(at: dir)
        }

        var oldKeyFileURL: URL {
            StoreKeyEnvelope.url(besideStore: storeURL, fingerprint: StoreKeyEnvelope.fingerprint(of: oldKey))
        }

        func keyFile(_ fingerprint: String) throws -> StoreKeyEnvelope {
            try #require(try StoreKeyEnvelope.load(at: StoreKeyEnvelope.url(besideStore: storeURL, fingerprint: fingerprint)))
        }

        func marker() async throws -> RotationMarker? {
            try await view.read { try RotationMarker.read($0) }
        }

        func vault() async throws -> KeyVaultClient.FetchedVault {
            let client = try #require(vaultClient)
            return try #require(try await client.fetchVault())
        }

        /// A pre-existing snapshot pair under the OLD key (the app's own,
        /// made before the switch) — the offer's subject.
        @discardableResult
        func addPreSwitchPair() throws -> URL {
            let fp8 = StoreKeyEnvelope.shortFingerprint(StoreKeyEnvelope.fingerprint(of: oldKey))
            let url = backups.appendingPathComponent("variorum-backup-\(fp8)-0.sqlite")
            try Data("old snapshot bytes — never rewritten".utf8).write(to: url)
            try Data("old key file bytes".utf8).write(to: pairKeyFile(url))
            return url
        }

        nonisolated static func pairKeyFile(_ snapshot: URL) -> URL {
            snapshot.deletingPathExtension().appendingPathExtension("keys.json")
        }
        nonisolated func pairKeyFile(_ snapshot: URL) -> URL { Self.pairKeyFile(snapshot) }
    }

    nonisolated private func fastKDF() -> PassphraseKDF.Descriptor {
        PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
    }

    /// The world: a scratch keyed store with three pushed notes, its key
    /// file beside it, custody + the vault when `enrolled`, the runner over
    /// scripted leaves. `standard: false` is a CASTLE world (the key file
    /// under P + M, the key gated; no Apple copy anywhere).
    /// pre-13x 2c: `sharing` builds a SIBLING device — its own scratch store,
    /// key file, custody and Keychain backings, on the SAME mirror, the same
    /// vault and the same account (the old material saved into its custody,
    /// no second setup) — the §7 choreography's second device.
    private func makeWorld(
        enrolled: Bool = true, standard: Bool = true, biometry: Bool = true, sharing: World? = nil,
        // pre-13x 5b (ledger 67): a SIBLING with its OWN vault client under its
        // own name, so the vault's `updated_by_device` tells the two apart
        // (the shared client stamps every write "test device").
        deviceName: String = "test device",
        // F1 (BLOCKER-1): the emulated mirror's A5 visibility window, in
        // logical ticks (0 = none — every standing world).
        mirrorHorizon: Int64 = 0
    ) async throws -> World {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-2b-switch-\(UUID().uuidString)", isDirectory: true)
        let storeURL = dir.appendingPathComponent("library/variorum.sqlite")
        let backups = dir.appendingPathComponent("backups", isDirectory: true)
        try FileManager.default.createDirectory(at: backups, withIntermediateDirectories: true)
        let oldKey = StoreKey.mint()
        let opened = try AppDatabase.openStore(at: storeURL, custody: .inMemory(initial: oldKey))
        let (view, binding) = opened.asRebindable()
        let apple = AppleKey.mint()
        let appleBacking = InMemoryAppleKeyBacking(key: apple)
        let guardBacking = InMemoryStoreKeyGuardBacking(
            auto: standard ? oldKey : nil, gated: standard ? nil : oldKey,
            biometryAvailable: biometry, biometricSucceeds: true)
        let dials = ScriptedDialsBox(ProtectionDials())
        let gate = StoreLaunchGate(
            dials: { _, id in dials.dials(for: id) },
            saveDials: { new, _, id in dials.save(new, for: id) },
            legacyMode: { _, _ in nil },
            retireLegacyDials: { _, _ in },
            guardFor: { _ in StoreKeyGuard.inMemory(backing: guardBacking) },
            appleKeyFor: { _ in AppleKeyLeaves.inMemory(backing: appleBacking) },
            loadEnvelope: { try StoreKeyEnvelope.loadCurrent(besideStore: $0) },
            saveEnvelope: { try $0.write(at: $0.preferredURL(besideStore: $1)) },
            setAsideEnvelope: { _ in },
            stamp: { _, _ in nil },
            setStamp: { _, _, _ in })
        let suiteName = "io.lduarte.variorum.tests.2b.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        let keyStore = DeviceKeyStore.inMemory()

        var vaultEmu: EmulatedVault?
        var vaultClient: KeyVaultClient?
        var mirror: EmulatedMirror?
        var material: DeviceKeyMaterial?
        if let sharing {
            vaultEmu = sharing.vaultEmu; vaultClient = sharing.vaultClient; mirror = sharing.mirror
            if deviceName != "test device", let emu = sharing.vaultEmu {
                vaultClient = KeyVaultClient(
                    configuration: KeyVaultClient.Configuration(
                        projectURL: URL(string: "https://vault.2b.invalid")!, apiKey: "publishable-test-key", deviceName: deviceName),
                    sessionProvider: StaticSessionProvider(
                        session: UserSession(accessToken: "token-2b", userID: "user-2b")),
                    load: emu.load)
            }
            material = sharing.oldMaterial
            if let material { #expect(keyStore.save(material)) }
        } else if enrolled {
            let server = EmulatedMirror(visibilityHorizon: mirrorHorizon)
            // F1: the vault's completion guard reads the mirror — the one
            // emulation the SQL's FOR UPDATE + count make on Postgres.
            let emu = EmulatedVault(
                claimRotationSeq: { await server.claimSeq() },
                rowsRemainBelow: { seq in await server.ciphertextRowsBelow(seq) > 0 })
            let client = KeyVaultClient(
                configuration: KeyVaultClient.Configuration(
                    projectURL: URL(string: "https://vault.2b.invalid")!, apiKey: "publishable-test-key", deviceName: "test device"),
                sessionProvider: StaticSessionProvider(
                    session: UserSession(accessToken: "token-2b", userID: "user-2b")),
                load: emu.load)
            // 13y round 4: one account, one enrollment state — the
            // mirror consults the vault double's row (see
            // `EmulatedVault.enrolledSecret`).
            await server.attach(vault: client, enrollment: emu)
            let minted = try await VaultEnrollment(client: client).setUp(passphrase: "sesame")
            #expect(keyStore.save(minted))
            material = minted
            vaultEmu = emu; vaultClient = client; mirror = server
        }

        // The key file beside the store (format 2, its own fingerprint name).
        var envelope = StoreKeyEnvelope(storeID: "store-2b-\(UUID().uuidString.prefix(8))")
        try envelope.setPassphraseWrap(key: oldKey, passphrase: "sesame", kdf: fastKDF())
        if standard {
            try envelope.setAppleWrappedCopy(key: oldKey, under: apple.symmetricKey, appleKeyID: apple.id)
        }
        if let material {
            try envelope.setMasterWrappedCopy(key: oldKey, under: material.masterSymmetricKey)
        }
        try envelope.write(at: envelope.preferredURL(besideStore: storeURL))

        let world = World(
            dir: dir, storeURL: storeURL, backups: backups, oldKey: oldKey, apple: apple,
            binding: binding, view: view, keyStore: keyStore, vaultEmu: vaultEmu,
            vaultClient: vaultClient, mirror: mirror, guardBacking: guardBacking,
            appleBacking: appleBacking, gate: gate, defaults: defaults, suiteName: suiteName, biometry: biometry,
            posture: standard ? .standard : .castle)
        world.oldMaterial = material
        world.words = try RecoveryPhrase.generate()
        world.deviceName = deviceName
        // F1: where production sleeps past the horizon, this world lets
        // time pass on the mirror's clock.
        let mirrorForWait = mirror
        world.horizonWait = { await mirrorForWait?.advanceClock(by: max(mirrorHorizon, 1)) }

        // Three notes, pushed under the OLD corpus key.
        let stamp = "2026-09-05T00:00:00Z"
        for index in 0..<3 {
            let id = "note-\(index)-\(UUID().uuidString.prefix(6))"
            let title = "Castle note \(index) — \(UUID().uuidString.prefix(4))"
            world.seededTitles[id] = title
            try await view.write { db in
                try db.execute(
                    sql: "INSERT INTO container (id, kind, title, created_at, updated_at) VALUES (?, 'post', ?, ?, ?)",
                    arguments: [id, title, stamp, stamp])
            }
        }
        if enrolled, let mirror {
            let engine = SyncEngine(transport: mirror, keyProvider: DeviceKeySyncProvider(store: keyStore))
            try await withDependencies { $0.database = view } operation: {
                let report = try await engine.push()
                #expect(report.accepted >= 3, "the seed pushed")
            }
            for (key, stored) in await mirror.stored() where stored.row.table == "container" {
                world.titlesBeforeSwitch[key] = stored.row.columns["title"]
            }
        }
        world.runner = PostureSwitchRunner(leaves: leaves(for: world))
        return world
    }

    private func leaves(for world: World, faultAt: PostureSwitchRunner.FaultPoint? = nil, keyStore: DeviceKeyStore? = nil, vaultOverride: KeyVaultClient? = nil) -> PostureSwitchRunner.Leaves {
        let calls = world.calls
        let backups = world.backups
        let suiteName = world.suiteName
        let signedIn = world.vaultClient != nil
        let deviceName = world.deviceName
        return PostureSwitchRunner.Leaves(
            scope: "Variorum2b",
            storeURL: world.storeURL,
            database: world.view,
            gate: world.gate,
            keyStore: keyStore ?? world.keyStore,
            keyProvider: DeviceKeySyncProvider(store: keyStore ?? world.keyStore),
            vault: vaultOverride ?? world.vaultClient,
            transport: world.mirror,
            signedIn: { signedIn },
            appleKeys: AppleKeyLeaves.inMemory(backing: world.appleBacking),
            libraryKeyInHand: { world.keyInHand },
            posture: { world.posture },
            alwaysAsk: { world.alwaysAsk },
            biometryAvailable: { world.biometry },
            moveCustody: { target in
                if calls.refuseNextCustody {
                    calls.refuseNextCustody = false
                    return .refused("scripted custody refusal")
                }
                calls.custodyTargets.append(target)
                world.posture = target == .auto ? .standard : .castle
                return .changed
            },
            rekeyLibrary: { old, new, work in
                if calls.rekeyFault == .beforeWork {
                    calls.rekeyFault = nil
                    throw URLError(.cancelled)
                }
                calls.rekeys += 1
                world.binding.lock()
                var failure: (any Error)?
                do { try work() } catch { failure = error }
                let opened = StoreEncryptionMigration.opens(world.storeURL, key: new) ? new : old
                try world.binding.adopt(try AppDatabase.openStore(at: world.storeURL, custody: .inMemory(initial: opened)))
                world.keyInHand = opened
                if let failure { throw failure }
                if calls.rekeyFault == .afterWork {
                    calls.rekeyFault = nil
                    throw URLError(.cancelled)
                }
            },
            pauseSync: { calls.pauses += 1; world.onPause?() },
            resumeSync: { calls.resumes += 1 },
            takeSnapshot: {
                guard let key = world.keyInHand else { return .failed }
                if world.snapshotFails { return .failed }
                let fp8 = StoreKeyEnvelope.shortFingerprint(StoreKeyEnvelope.fingerprint(of: key))
                let n = calls.snapshotsTaken.withValue { $0 += 1; return $0 }
                let url = backups.appendingPathComponent("variorum-backup-\(fp8)-\(n).sqlite")
                try? FileManager.default.copyItem(at: world.storeURL, to: url)
                try? Data("fresh key file".utf8).write(to: World.pairKeyFile(url))
                return .written(url)
            },
            preSwitchSnapshots: { keep in
                calls.listedAfterSnapshot.setValue(calls.snapshotsTaken.value > 0)
                let entries = (try? FileManager.default.contentsOfDirectory(at: backups, includingPropertiesForKeys: nil)) ?? []
                return entries
                    .filter { $0.pathExtension == "sqlite" }
                    .filter { url in
                        let parts = url.deletingPathExtension().lastPathComponent.split(separator: "-")
                        return parts.count >= 3 && String(parts[2]) != keep
                    }
                    .sorted { $0.lastPathComponent < $1.lastPathComponent }
            },
            deleteSnapshotPairs: { urls in
                var removed = 0
                for url in urls {
                    try? FileManager.default.removeItem(at: World.pairKeyFile(url))
                    if (try? FileManager.default.removeItem(at: url)) != nil { removed += 1 }
                }
                calls.deletedPairs.withValue { $0.append(contentsOf: urls) }
                return removed
            },
            defaults: { UserDefaults(suiteName: suiteName)! },
            reconcile: { calls.reconciles += 1 },
            now: { Date(timeIntervalSince1970: 1_788_000_000) },
            log: { line in calls.log.withValue { $0.append(line) } },
            injectFault: { point in
                if point == faultAt { throw PostureSwitchError.injectedFault(point) }
            },
            deviceName: { deviceName },
            horizonWait: {
                let wait = await MainActor.run { world.horizonWait }
                try await wait()
            })
    }

    /// A world's runner re-composed with ONE scripted fault (2c.1b).
    private func arm(_ world: World, faultAt: PostureSwitchRunner.FaultPoint?) {
        world.runner = PostureSwitchRunner(leaves: leaves(for: world, faultAt: faultAt))
    }

    /// Seed `count` extra notes locally (unpushed) — the outbox's backlog.
    private func seedBacklog(_ world: World, count: Int, tag: String) async throws {
        try await world.view.write { db in
            for index in 0..<count {
                try db.execute(
                    sql: "INSERT INTO container (id, kind, title, created_at, updated_at) VALUES (?, 'post', ?, ?, ?)",
                    arguments: ["\(tag)-\(index)", "\(tag) \(index)", "2026-09-05T00:00:00Z", "2026-09-05T00:00:00Z"])
            }
        }
    }

    private func outboxCount(_ world: World) async throws -> Int {
        try await world.view.read { db in try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_outbox") ?? 0 }
    }

    /// The end state of a completed Standard → Castle switch (shared by the
    /// whole road and every resume).
    private func expectCastleEndState(_ world: World, _ outcome: PostureSwitchRunner.Outcome) async throws {
        #expect(outcome.entersCastle)
        // The library opens under the NEW key alone.
        let newFile = try world.keyFile(outcome.newKeyFingerprint)
        let newKey = try newFile.unwrapKey(passphrase: "sesame")
        #expect(StoreEncryptionMigration.opens(world.storeURL, key: newKey), "the library is under L′")
        #expect(!StoreEncryptionMigration.opens(world.storeURL, key: world.oldKey), "the old L opens nothing")
        #expect(world.keyInHand == newKey, "the reopen adopted L′")
        #expect(newFile.apple == nil && newFile.appleKeyID == nil, "no Apple copy enters Castle")
        #expect(newFile.recovery != nil, "L′ under the words in hand")
        #expect(try newFile.unwrapKey(recoveryWords: world.words) == newKey)
        // A Standard-era key file + A: its L opens no page of the re-keyed library.
        let oldFile = try #require(try StoreKeyEnvelope.load(at: world.oldKeyFileURL), "the old key file stays beside old snapshots")
        let standardEraKey = try oldFile.unwrapKey(apple: world.apple.symmetricKey)
        #expect(standardEraKey == world.oldKey)
        #expect(!StoreEncryptionMigration.opens(world.storeURL, key: standardEraKey),
                "§12: a Standard-era copy of the key file + the Apple-held key opens no page")
        // Custody: Touch ID (biometry) or the passphrase; both items through the one move.
        #expect(world.calls.custodyTargets.last == (world.biometry ? .biometric : .passphrase))
        #expect(world.posture == .castle)
        // The marker is gone; the snapshot came BEFORE the offer's listing.
        #expect(try await world.marker() == nil)
        #expect(world.calls.snapshotsTaken.value >= 1)
        #expect(world.calls.listedAfterSnapshot.value == true, "the fresh pair is taken before anything is offered")
        #expect(world.calls.resumes >= 1 && world.calls.reconciles >= 1)
        if let material = outcome.material, let vaultClient = world.vaultClient {
            let vault = try await world.vault()
            #expect(vault.format.previousCorpusKey == nil && vault.format.rotationStartedSeq == nil,
                    "the vault's previous key and seq cleared together")
            #expect(vault.format.masterWrappedByAppleHeld == nil && vault.format.appleKeyID == nil,
                    "no Apple-held copy under Castle")
            #expect(vault.format.classKey(for: .corpus)?.keyID == material.corpusKeyID)
            #expect(vault.format.keyProofHash == KeyProof.macHash(master: material.masterSymmetricKey),
                    "post-rotation the vault carries kp2\u{2032}'s hash (13y: the mac and the hash land together)")
            #expect(material.rotation == nil, "custody carries no previous key after completion")
            #expect(world.keyStore.load()?.corpusKeyID == material.corpusKeyID)
            #expect(try newFile.unwrapKey(master: material.masterSymmetricKey) == newKey, "L′ under M′")
            _ = vaultClient
        }
    }

    // MARK: - §4 whole

    @Test func enteringCastleRotatesEverythingAndTheStandardEraKeysOpenNothing() async throws {
        let world = try await makeWorld()
        defer { world.tearDown() }
        let mirror = try #require(world.mirror)
        let oldMaterial = try #require(world.oldMaterial)
        let oldPair = try world.addPreSwitchPair()
        let oldPairBytes = try Data(contentsOf: oldPair)
        MarkdownInsurance.setEnabled(true, in: world.defaults)
        let headBefore = await mirror.seq

        let outcome = try await world.runner.enterCastle(passphrase: "sesame", recoveryWords: world.words)
        try await expectCastleEndState(world, outcome)
        let material = try #require(outcome.material)

        // Every row on the server was re-encrypted — exactly once, all of
        // them below the rotation seq, every ciphertext changed.
        let batches = await mirror.reencryptBatches
        let reencryptedIDs = Set(batches.flatMap { $0 }.map(\.rowID))
        #expect(outcome.reencrypted == batches.flatMap { $0 }.count)
        #expect(reencryptedIDs.isSuperset(of: world.seededTitles.keys), "the three notes were re-encrypted")
        let stored = await mirror.stored()
        for (key, before) in world.titlesBeforeSwitch {
            #expect(stored[key]?.row.columns["title"] != before, "\(key)'s title ciphertext changed")
            #expect((stored[key]?.seq ?? 0) > headBefore, "re-encrypted rows sit above the rotation seq")
        }
        // The OLD keys are refused at the fence (a push with something to
        // push, a pull); the NEW ones read every note.
        let oldEngine = SyncEngine(transport: mirror, keyProvider: FixedKeyProvider(keys: oldMaterial.syncKeys))
        try await world.view.write { db in
            try db.execute(
                sql: "INSERT INTO container (id, kind, title, created_at, updated_at) VALUES (?, 'post', ?, ?, ?)",
                arguments: ["late-note", "typed after the switch", "2026-09-05T01:00:00Z", "2026-09-05T01:00:00Z"])
        }
        try await withDependencies { $0.database = world.view } operation: {
            await #expect(throws: SyncError.encryptionKeysReplaced, "old-C pull refused") { _ = try await oldEngine.pull() }
            await #expect(throws: SyncError.encryptionKeysReplaced, "old-C push refused") { _ = try await oldEngine.push() }
        }
        let lateRows = await mirror.stored().keys.filter { $0.hasSuffix("/late-note") }
        #expect(lateRows.isEmpty, "nothing under the old keys reached the mirror")
        let followerURL = world.dir.appendingPathComponent("follower/variorum.sqlite")
        let follower = try AppDatabase.openStore(at: followerURL, custody: .inMemory(initial: .mint()))
        let followerEngine = SyncEngine(transport: mirror, keyProvider: FixedKeyProvider(keys: material.syncKeys))
        try await withDependencies { $0.database = follower } operation: {
            let report = try await followerEngine.pull()
            #expect(report.applied >= 3)
        }
        let titles = try await follower.read { db in
            try Row.fetchAll(db, sql: "SELECT id, title FROM container")
                .reduce(into: [String: String]()) { acc, row in
                    let id: String = row["id"]
                    let title: String? = row["title"]
                    acc[id] = title
                }
        }
        for (id, title) in world.seededTitles {
            #expect(titles[id] == title, "a follower under the new keys reads \(id) back in the clear")
        }

        // The offer: the pre-switch pair listed, its bytes untouched, the
        // fresh pair not listed; the insurance OFF with the notice.
        #expect(outcome.preSwitchSnapshots == [oldPair])
        #expect(try Data(contentsOf: oldPair) == oldPairBytes, "no backup folder is ever rewritten")
        #expect(outcome.insuranceTurnedOff && !MarkdownInsurance.isEnabled(in: world.defaults))
        let fresh = try FileManager.default.contentsOfDirectory(at: world.backups, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "sqlite" && $0 != oldPair }
        #expect(fresh.count == 1, "one fresh pair under the new key")
        #expect(world.runner.deletePreSwitchSnapshots(outcome) == 1)
        #expect(!FileManager.default.fileExists(atPath: oldPair.path))
        #expect(!FileManager.default.fileExists(atPath: world.pairKeyFile(oldPair).path), "the pair goes together")
        #expect(FileManager.default.fileExists(atPath: fresh[0].path), "the fresh pair survives the offer")
        #expect(world.calls.pauses == 1)
    }

    /// pre-13x ladder round 1, F2 (MAJOR-2) — RED ON OLD: the runner
    /// discarded `takeSnapshot()`'s answer, listed the pre-switch pairs
    /// regardless, and the Done said "A fresh backup was made under it" —
    /// so an unwritable Backups folder offered the deletion of the only
    /// snapshots that existed, with the sentence's assurance. Now: a FAILED
    /// fresh snapshot lists nothing (no offer), the outcome says so, and the
    /// Done renders copy §2b's could-not-back-up line; the old pair's bytes
    /// are untouched and the offer's act removes nothing.
    @Test func aFailedFreshSnapshotMakesNoOfferAndTheDoneSaysSo() async throws {
        let world = try await makeWorld()
        defer { world.tearDown() }
        let oldPair = try world.addPreSwitchPair()
        let oldPairBytes = try Data(contentsOf: oldPair)
        world.snapshotFails = true

        let outcome = try await world.runner.enterCastle(passphrase: "sesame", recoveryWords: world.words)
        #expect(outcome.entersCastle && outcome.freshSnapshot == .failed)
        #expect(outcome.preSwitchSnapshots == [], "no fresh pair ⇒ no offer over the old ones")
        #expect(world.calls.snapshotsTaken.value == 0, "nothing was written")
        let oldPairBytesAfter = try Data(contentsOf: oldPair)
        #expect(FileManager.default.fileExists(atPath: oldPair.path) && oldPairBytesAfter == oldPairBytes,
                "the earlier backup is untouched")
        #expect(world.runner.deletePreSwitchSnapshots(outcome) == 0, "the offer's act has nothing to remove")
        #expect(FileManager.default.fileExists(atPath: oldPair.path))
        #expect(ProtectionCopy.castleDoneBody(outcome) == ProtectionCopy.enteredCastleWithoutFreshBackup,
                "the Done claims no backup")
        #expect(!ProtectionCopy.castleDoneBody(outcome).contains("A fresh backup was made"))
        // Everything else of the switch stands: the library under L′, the marker gone.
        #expect(!StoreEncryptionMigration.opens(world.storeURL, key: world.oldKey))
        #expect(try await world.marker() == nil)

        // The ordinary road, for contrast: a written pair lists the old one and speaks the ordinary Done.
        let written = try await makeWorld()
        defer { written.tearDown() }
        let writtenOldPair = try written.addPreSwitchPair()
        let writtenOutcome = try await written.runner.enterCastle(passphrase: "sesame", recoveryWords: written.words)
        if case .written = writtenOutcome.freshSnapshot {} else { Issue.record("the fresh pair was written") }
        #expect(writtenOutcome.preSwitchSnapshots == [writtenOldPair])
        #expect(ProtectionCopy.castleDoneBody(writtenOutcome) == ProtectionCopy.enteredCastleDone)
    }

    @Test func aLocalOnlyLibraryTakesStepsFourToSevenOnlyAndItsResumeNeedsThePassphrase() async throws {
        let world = try await makeWorld(enrolled: false, biometry: false)
        defer { world.tearDown() }
        world.calls.rekeyFault = .beforeWork
        await #expect(throws: URLError.self) {
            _ = try await world.runner.enterCastle(passphrase: "sesame", recoveryWords: world.words)
        }
        #expect(try await world.marker()?.step == .rekeyLibrary)
        #expect(StoreEncryptionMigration.opens(world.storeURL, key: world.oldKey), "before the swap the file is under L")
        // No master copy in a local-only key file: the resume asks for the passphrase.
        await #expect(throws: PostureSwitchError.passphraseRequired) {
            _ = try await world.runner.resume(passphrase: nil)
        }
        let outcome = try await world.runner.resume(passphrase: "sesame", recoveryWords: world.words)
        try await expectCastleEndState(world, outcome)
        #expect(outcome.material == nil && outcome.reencrypted == 0)
        #expect(world.calls.custodyTargets.last == .passphrase, "no biometry ⇒ Always ask")
        #expect(world.calls.pauses == 0, "no sync to pause")
    }

    // MARK: - The three seams

    @Test func aCrashAtEachOfTheThreeSeamsResumesToCompletion() async throws {
        // Seam A — mid re-encryption: the marker at `.reencrypt`, custody
        // carrying the previous key, the vault mid-rotation, the file under L.
        do {
            let world = try await makeWorld()
            defer { world.tearDown() }
            let mirror = try #require(world.mirror)
            await mirror.setCrashNextReencrypt(true)
            await #expect(throws: URLError.self) {
                _ = try await world.runner.enterCastle(passphrase: "sesame", recoveryWords: world.words)
            }
            #expect(try await world.marker()?.step == .reencrypt)
            #expect(world.keyStore.load()?.rotation != nil, "custody holds M′ + the previous key")
            #expect(try await world.vault().format.previousCorpusKey != nil)
            #expect(StoreEncryptionMigration.opens(world.storeURL, key: world.oldKey))
            // A second start refuses while the marker stands (decision 32 on this device).
            await #expect(throws: PostureSwitchError.switchInProgress(.reencrypt)) {
                _ = try await world.runner.enterCastle(passphrase: "sesame", recoveryWords: world.words)
            }
            let outcome = try await world.runner.resume(passphrase: "sesame", recoveryWords: world.words)
            try await expectCastleEndState(world, outcome)
            let batches = await mirror.reencryptBatches
            #expect(Set(batches.flatMap { $0 }.map(\.rowID)).isSuperset(of: world.seededTitles.keys),
                    "the walk finished after the crash")
        }
        // Seam B — after the export, before the swap: the new key file
        // written, the file still under L, the marker at `.rekeyLibrary`.
        do {
            let world = try await makeWorld()
            defer { world.tearDown() }
            world.calls.rekeyFault = .beforeWork
            await #expect(throws: URLError.self) {
                _ = try await world.runner.enterCastle(passphrase: "sesame", recoveryWords: world.words)
            }
            let marker = try #require(try await world.marker())
            #expect(marker.step == .rekeyLibrary)
            #expect(StoreEncryptionMigration.opens(world.storeURL, key: world.oldKey))
            let newFingerprint = try #require(marker.newKeyFingerprint)
            #expect(try world.keyFile(newFingerprint).master != nil, "the new key file came first")
            // The master copy under M′ opens L′ — no passphrase needed to resume.
            let outcome = try await world.runner.resume(passphrase: nil)
            try await expectCastleEndState(world, outcome)
        }
        // Seam B′ — after the swap, before the marker advanced: the file
        // already under L′; the resume must NOT swap again.
        do {
            let world = try await makeWorld()
            defer { world.tearDown() }
            world.calls.rekeyFault = .afterWork
            await #expect(throws: URLError.self) {
                _ = try await world.runner.enterCastle(passphrase: "sesame", recoveryWords: world.words)
            }
            #expect(try await world.marker()?.step == .rekeyLibrary)
            #expect(!StoreEncryptionMigration.opens(world.storeURL, key: world.oldKey), "the swap landed")
            let rekeysBefore = world.calls.rekeys
            let outcome = try await world.runner.resume(passphrase: nil)
            try await expectCastleEndState(world, outcome)
            #expect(world.calls.rekeys == rekeysBefore, "a file already under L′ is never exported again")
        }
        // Seam C — between the swap and custody: the custody move refused
        // once; the marker at `.custody`.
        do {
            let world = try await makeWorld()
            defer { world.tearDown() }
            world.calls.refuseNextCustody = true
            await #expect(throws: PostureSwitchError.custodyRefused("scripted custody refusal")) {
                _ = try await world.runner.enterCastle(passphrase: "sesame", recoveryWords: world.words)
            }
            #expect(try await world.marker()?.step == .custody)
            #expect(world.calls.custodyTargets.isEmpty)
            let outcome = try await world.runner.resume(passphrase: nil)
            try await expectCastleEndState(world, outcome)
            #expect(world.calls.custodyTargets == [.biometric])
        }
    }

    // MARK: - pre-13x ladder round 1, F1 — BLOCKER-1 at the runner

    /// F1 (BLOCKER-1) — THE RUNNER RE-WALKS ON THE SERVER's REFUSAL: a note
    /// pushed a second before the switch sits below the rotation seq but
    /// inside the mirror's visibility window; the ceremony's FIRST walk
    /// cannot see it (this pin's wait lets NO time pass the first time),
    /// so the clearing write is REFUSED (`VARIORUM_ROTATION_ROWS_REMAIN`)
    /// — and the runner walks again (the wait now lets time pass), finds
    /// the row, and completes: Castle's end state whole, every row above
    /// the seq, the refused write counted and nothing cleared by it. RED
    /// ON OLD (behavioural revert: the runner's re-walk removed — the
    /// refusal propagates): the ceremony THROWS the server's refusal with
    /// the marker at `.reencrypt`.
    @Test func aStragglerHiddenFromTheFirstWalkRefusesCompletionAndTheRunnerReWalksToCastle() async throws {
        let world = try await makeWorld(mirrorHorizon: 2)
        defer { world.tearDown() }
        let mirror = try #require(world.mirror)
        let emu = try #require(world.vaultEmu)
        await mirror.advanceClock(by: 2)  // the seed is visible
        // THE STRAGGLER: pushed under the old keys, written NOW — inside
        // the window for the ceremony's whole first walk.
        try await seedBacklog(world, count: 1, tag: "typed-a-second-before")
        let engine = SyncEngine(transport: mirror, keyProvider: DeviceKeySyncProvider(store: world.keyStore))
        try await withDependencies { $0.database = world.view } operation: { _ = try await engine.push() }
        let stragglerSeq = try #require(await mirror.stored()["container/typed-a-second-before-0"]?.seq)
        // The wait: NO time passes the first time (the first walk ends
        // blind), then time passes — production's sleep, made a fact.
        let waits = LockIsolated(0)
        world.horizonWait = {
            let n = waits.withValue { $0 += 1; return $0 }
            if n >= 2 { await mirror.advanceClock(by: 2) }
        }
        let updatesBefore = emu.updateCount
        // Every row on the mirror was pushed under the old keys — all of
        // them sit below the coming seq (the seeds, the store's seeded
        // settings, the straggler); the walk re-stamps each exactly once.
        let rowsBefore = await mirror.stored().count

        let outcome = try await world.runner.enterCastle(passphrase: "sesame", recoveryWords: world.words)
        try await expectCastleEndState(world, outcome)
        #expect(outcome.reencrypted == rowsBefore, "every row below the seq, the straggler included: \(outcome.reencrypted) of \(rowsBefore)")
        #expect(waits.value >= 2, "the first walk waited blind, the re-walk's wait let time pass")
        #expect(emu.updateCount == updatesBefore + 3, "begin · the REFUSED clearing write · the accepted one")
        #expect(try #require(await mirror.stored()["container/typed-a-second-before-0"]?.seq) > stragglerSeq,
                "the straggler was re-stamped above the seq")
        #expect(world.calls.log.value.contains { $0.contains("re-walking (try 2 of 3)") },
                "the runner said what it did")
        // Every row opens under the completed keys through the production
        // road — the engine's pull over the re-keyed custody, once the
        // re-stamped rows leave the window: the wedged changefeed cannot
        // happen.
        await mirror.advanceClock(by: 2)
        let after = SyncEngine(transport: mirror, keyProvider: DeviceKeySyncProvider(store: world.keyStore))
        let pulled = try await withDependencies { $0.database = world.view } operation: { try await after.pull() }
        #expect(!pulled.stalled && pulled.newCursor >= stragglerSeq, "the pull reached head past the re-stamped rows: \(pulled)")
    }

    /// F1 (BLOCKER-1) — THE BOUND, then the honest refusal: a wait that
    /// NEVER lets time pass (the straggler stays hidden) meets the
    /// server's refusal three times; the runner stops with
    /// `CorpusRotationError.completionRefused(tries: 3)` — the marker at
    /// `.reencrypt`, custody holding M′ + the previous key, the vault
    /// still carrying it (nothing cleared, nothing lost), the sentence
    /// worded — and the RESUME, once time passes, re-walks and finishes.
    @Test func threeRefusedCompletionsEndInTheHonestRefusalAndTheResumeFinishesOnceTimePasses() async throws {
        let world = try await makeWorld(mirrorHorizon: 2)
        defer { world.tearDown() }
        let mirror = try #require(world.mirror)
        let emu = try #require(world.vaultEmu)
        let oldMaterial = try #require(world.oldMaterial)
        await mirror.advanceClock(by: 2)
        try await seedBacklog(world, count: 1, tag: "typed-a-second-before")
        let engine = SyncEngine(transport: mirror, keyProvider: DeviceKeySyncProvider(store: world.keyStore))
        try await withDependencies { $0.database = world.view } operation: { _ = try await engine.push() }
        world.horizonWait = {}  // frozen: the straggler never becomes visible
        let updatesBefore = emu.updateCount

        await #expect(throws: CorpusRotationError.completionRefused(tries: PostureSwitchRunner.maxCompletionTries)) {
            _ = try await world.runner.enterCastle(passphrase: "sesame", recoveryWords: world.words)
        }
        #expect(emu.updateCount == updatesBefore + 1 + PostureSwitchRunner.maxCompletionTries,
                "begin, then three refused clearing writes")
        #expect(try await world.marker()?.step == .reencrypt, "the marker stays — the resume re-walks")
        let held = try #require(world.keyStore.load())
        #expect(held.rotation != nil && held.corpusKeyID != oldMaterial.corpusKeyID, "custody holds M′ and the previous key")
        let vault = try await world.vault()
        #expect(vault.format.previousCorpusKey?.keyID == oldMaterial.corpusKeyID && vault.format.rotationStartedSeq != nil,
                "the vault still carries the previous key + the seq — nothing was cleared")
        let rotationSeq = try #require(vault.format.rotationStartedSeq)
        #expect(await mirror.ciphertextRowsBelow(rotationSeq) == 1, "the straggler is still below the seq, under a key everyone still holds")
        #expect(StoreEncryptionMigration.opens(world.storeURL, key: world.oldKey), "the library was not re-keyed")
        #expect(world.calls.rekeys == 0 && world.calls.custodyTargets.isEmpty)
        #expect(PostureSwitchModel.message(for: CorpusRotationError.completionRefused(tries: 3))
                == ProtectionCopy.rotationRowsStillSettling, "the refusal speaks")
        // F2 (MAJOR-1, F1's hand-forward): the honest refusal is an EXIT —
        // the chain this ceremony paused is resumed (the rounds then refuse
        // on the marker, honestly, instead of never running at all).
        #expect(world.calls.resumes == world.calls.pauses && world.calls.pauses == 1,
                "the completionRefused exit resumes the sync it paused")
        // Rounds refuse while the marker stands (nothing pushes a stale row).
        await #expect(throws: SyncError.accountRekeyIncomplete) {
            try await withDependencies { $0.database = world.view } operation: { _ = try await engine.pull() }
        }

        // Time passes; the resume re-walks and finishes.
        world.horizonWait = { await mirror.advanceClock(by: 2) }
        let resumed = try await world.runner.resume(passphrase: "sesame", recoveryWords: world.words)
        try await expectCastleEndState(world, resumed)
        #expect(resumed.reencrypted == 1, "the resume re-encrypted exactly the straggler")
        #expect(await mirror.ciphertextRowsBelow(rotationSeq) == 0)
    }

    // MARK: - pre-13x ladder round 1, F2 (MINOR-5): the drain engine's dedupe facts

    /// THE COMPOSITION PIN, two halves: the drain's engine takes the LEAVES'
    /// facts (behavioural — before F2 it built `SyncEngine(transport:key
    /// Provider:)` bare, an inert empty list), and the PRODUCTION leaves
    /// carry every seeded book's facts — the same list `SyncSession.
    /// configure` hands the regular engine (a grep pin over the one
    /// composition line, the `TravellingDotsIndicator` precedent; the live
    /// leaves compose over a bootstrap this suite does not build).
    @Test func theDrainEngineTakesTheLeavesDedupeFactsAndTheLiveLeavesCarryEverySeededBooks() async throws {
        let world = try await makeWorld()
        defer { world.tearDown() }
        let mirror = try #require(world.mirror)
        var scripted = leaves(for: world)
        #expect(scripted.drainEngine(transport: mirror).sampleLibraryFacts.isEmpty, "the scripted world's leaves are inert")
        scripted.sampleLibraryFacts = SampleLibrarySeeder.allDedupeFacts()
        let engine = scripted.drainEngine(transport: mirror)
        // 18l-c U6 (re-armed): the facts are the DEDUPE-COVERED books, no
        // longer `Book.all` (the takemania book is seeded, not judged).
        #expect(engine.sampleLibraryFacts.map(\.bookName) == SampleLibrarySeeder.Book.dedupeCovered.map(\.name),
                "the drain engine carries exactly the leaves' facts, in order")
        #expect(engine.sampleLibraryFacts.count == 2, "Sherlock + Encryption Explained")

        // The production composition: `Leaves.live` hands `allDedupeFacts()`.
        let source = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("Shared/PostureSwitch.swift")
        let text = try String(contentsOf: source, encoding: .utf8)
        let live = try #require(text.range(of: "static func live("))
        let body = text[live.lowerBound...]
        #expect(body.contains("sampleLibraryFacts: SampleLibrarySeeder.allDedupeFacts()"),
                "the live leaves compose the seeded books' facts exactly as SyncSession.configure does")
        #expect(text.contains("let engine = leaves.drainEngine(transport: transport)"),
                "the drain builds its engine through the leaves, never bare")
    }

    // MARK: - Decision 32 at the door

    @Test func aRotationStillFinishingOnAnotherDeviceRefusesAtTheDoorAndChangesNothing() async throws {
        let world = try await makeWorld()
        defer { world.tearDown() }
        let client = try #require(world.vaultClient)
        let oldMaterial = try #require(world.oldMaterial)
        // "Another device" began a rotation and has not finished.
        let secrets = try RotationSecrets.derive(passphrase: "sesame", recoveryWords: nil, kdf: fastKDF())
        let begun = try await CorpusRotation.begin(client: client, current: oldMaterial, secrets: secrets, appleHeldCopy: nil)
        let vaultBefore = try await world.vault()
        #expect(vaultBefore.format.previousCorpusKey != nil)

        // THIS device, still on the old keys: the fence refuses the round
        // first (the CF-16 sentence — follow before anything else).
        await #expect(throws: SyncError.encryptionKeysReplaced) {
            _ = try await world.runner.enterCastle(passphrase: "sesame", recoveryWords: world.words)
        }
        // This device FOLLOWED (§14.39 — the mid-rotation material) and asks
        // for a switch of its own: decision 32 refuses at the door.
        let following = try CorpusRotation.materialFollowing(vaultBefore.format, master: begun.material.masterSymmetricKey)
        #expect(following.rotation != nil)
        #expect(world.keyStore.save(following))
        let facts = try await world.runner.checkDoor()
        #expect(facts.enrolled && facts.rotationInProgress, "the door check sees the rotation")
        #expect(facts.vaultUpdatedAt != nil, "the vault's day rides the sentence")
        await #expect(throws: CorpusRotationError.rotationInProgress(previousKeyID: oldMaterial.corpusKeyID)) {
            _ = try await world.runner.enterCastle(passphrase: "sesame", recoveryWords: world.words)
        }
        #expect(try await world.marker() == nil, "the marker never landed")
        #expect(StoreEncryptionMigration.opens(world.storeURL, key: world.oldKey), "nothing changed")
        #expect(try await world.vault().revision == vaultBefore.revision, "no vault write")
        #expect(world.calls.custodyTargets.isEmpty)

        // The ceremony: the door refuses with copy §4's sentence BEFORE any screen asks.
        // F2 (MINOR-4): the sentence names the vault's writer — here the
        // world's own client ("test device") began the rotation.
        let controller = makeController(for: world)
        let model = PostureSwitchModel(mode: .enter, runner: world.runner, controller: controller, vaultTie: nil)
        await model.start()
        #expect(facts.updatedByDevice == "test device")
        let expected = ProtectionCopy.rotationStillFinishing(
            device: "test device", day: EncryptionView.displayDate(facts.vaultUpdatedAt) ?? "an earlier day")
        #expect(model.phase == .failed(expected))
    }

    /// pre-13x ladder round 1, F2 (MINOR-4 — decision 34) — RED ON OLD: the
    /// still-finishing sentence always said "another device" (`DoorFacts`
    /// carried no `updatedByDevice`), though the column was ruled so the
    /// notice could NAME the device ("the real name is what lets a user
    /// spot an act they did not do"). A SIBLING under its own name begins
    /// a rotation; this device's door — and the mid-run refusal — name it.
    @Test func theStillFinishingRefusalNamesTheDeviceThatStartedTheRotation() async throws {
        let world = try await makeWorld()
        defer { world.tearDown() }
        let sibling = try await makeWorld(sharing: world, deviceName: "Lillian's iPhone")
        defer { sibling.tearDown() }
        let siblingClient = try #require(sibling.vaultClient)
        let oldMaterial = try #require(world.oldMaterial)
        let secrets = try RotationSecrets.derive(passphrase: "sesame", recoveryWords: nil, kdf: fastKDF())
        let begun = try await CorpusRotation.begin(client: siblingClient, current: oldMaterial, secrets: secrets, appleHeldCopy: nil)
        // This device followed (the mid-rotation material) and asks for a switch of its own.
        let vault = try await world.vault()
        #expect(vault.format.updatedByDevice == "Lillian's iPhone", "the vault names its writer")
        #expect(world.keyStore.save(try CorpusRotation.materialFollowing(vault.format, master: begun.material.masterSymmetricKey)))

        let facts = try await world.runner.checkDoor()
        #expect(facts.rotationInProgress && facts.updatedByDevice == "Lillian's iPhone", "the door's facts carry the name")
        let day = EncryptionView.displayDate(facts.vaultUpdatedAt) ?? "an earlier day"
        let named = ProtectionCopy.rotationStillFinishing(device: "Lillian's iPhone", day: day)
        #expect(named.hasPrefix("A key replacement started on Lillian's iPhone on "))

        // The door (copy §4's sentence, the device named) — both ceremonies.
        let controller = makeController(for: world)
        let enter = PostureSwitchModel(mode: .enter, runner: world.runner, controller: controller, vaultTie: nil)
        await enter.start()
        #expect(enter.phase == .failed(named), "\(enter.phase)")
        let replace = PostureSwitchModel(mode: .replaceKeys, runner: world.runner, controller: controller, vaultTie: nil)
        await replace.start()
        #expect(replace.phase == .failed(named))
        // The mid-run arm: the runner's own re-read refuses with the same named sentence.
        await #expect(throws: CorpusRotationError.rotationInProgress(previousKeyID: oldMaterial.corpusKeyID)) {
            _ = try await world.runner.enterCastle(passphrase: "sesame", recoveryWords: world.words)
        }
        #expect(try await world.marker() == nil)
    }

    /// pre-13x ladder round 1, F2 (MAJOR-1) — RED ON OLD: every refusal
    /// AFTER the pause left the chain stopped — `resumeSync` rode the
    /// success roads only, and the production leaf was a bare trigger (a
    /// no-op on a stopped session). Three refusal roads, each an exit:
    /// the fence at the drain (`encryptionKeysReplaced`), decision 32's
    /// door refusal (`rotationInProgress`) and the follow's wrong word
    /// (`wrongPassphrase`); the derived-key follow's descriptor refusal
    /// (`passphraseRequired`) rides too. After each, `resumes == pauses`.
    @Test func aRefusedCeremonyResumesTheSyncItPausedOnEveryExit() async throws {
        let world = try await makeWorld()
        defer { world.tearDown() }
        let client = try #require(world.vaultClient)
        let oldMaterial = try #require(world.oldMaterial)
        let secrets = try RotationSecrets.derive(passphrase: "sesame", recoveryWords: nil, kdf: fastKDF())
        let begun = try await CorpusRotation.begin(client: client, current: oldMaterial, secrets: secrets, appleHeldCopy: nil)
        let vaultBefore = try await world.vault()

        // Exit 1 — the fence refuses the drain (still on the old keys).
        await #expect(throws: SyncError.encryptionKeysReplaced) {
            _ = try await world.runner.enterCastle(passphrase: "sesame", recoveryWords: world.words)
        }
        #expect(world.calls.pauses == 1)
        #expect(world.calls.resumes == world.calls.pauses, "exit 1: the chain paused for the drain is resumed")

        // Exit 2 — decision 32 at the door (the vault carries a previous key).
        let following = try CorpusRotation.materialFollowing(vaultBefore.format, master: begun.material.masterSymmetricKey)
        #expect(world.keyStore.save(following))
        await #expect(throws: CorpusRotationError.rotationInProgress(previousKeyID: oldMaterial.corpusKeyID)) {
            _ = try await world.runner.enterCastle(passphrase: "sesame", recoveryWords: world.words)
        }
        #expect(world.calls.pauses == 2)
        #expect(world.calls.resumes == world.calls.pauses, "exit 2: the door refusal resumes")

        // Exit 3 — the follow's wrong word refuses at the vault (nothing written).
        await #expect(throws: VaultEnrollmentError.wrongPassphrase) {
            _ = try await world.runner.follow(passphrase: "not-the-word", recoveryWords: nil)
        }
        #expect(world.calls.pauses == 3)
        #expect(world.calls.resumes == world.calls.pauses, "exit 3: the follow's refusal resumes")

        // Exit 4 — the derived-key follow whose descriptor is not the vault's.
        await #expect(throws: PostureSwitchError.passphraseRequired) {
            _ = try await world.runner.follow(
                derivedPassphraseKey: SymmetricKey(size: .bits256), kdf: fastKDF())
        }
        #expect(world.calls.pauses == 4)
        #expect(world.calls.resumes == world.calls.pauses, "exit 4: the derived follow's refusal resumes")
        #expect(try await world.marker() == nil, "no road wrote a marker")
    }

    /// pre-13x ladder round 2, F3 (MINOR-N2) — RED ON OLD: the pause flag
    /// was INSTANCE-scoped while the balance is ROAD-scoped, so a second
    /// road refused `switchInProgress` mid-ceremony (the `busy` guard —
    /// exactly the case it exists for) saw the flag road 1 had set and
    /// RECONNECTED the chain out from under road 1's drain. Here road 1
    /// (entering Castle) pauses; at that very pause a second `follow` is
    /// scheduled on the shared runner; it runs at road 1's next suspension
    /// (the drain's first push), is refused at the guard, and must resume
    /// NOTHING — the one resume is road 1's own, at its end.
    @Test func aSecondRoadRefusedMidCeremonyNeverResumesTheFirstRoadsPause() async throws {
        let world = try await makeWorld()
        defer { world.tearDown() }
        let secondRoadError = LockIsolated<(any Error)?>(nil)
        let resumesWhenRefused = LockIsolated<Int?>(nil)
        let secondRoad = LockIsolated<Task<Void, Never>?>(nil)
        world.onPause = {
            secondRoad.setValue(Task { @MainActor in
                do {
                    _ = try await world.runner.follow(passphrase: "sesame", recoveryWords: nil)
                } catch {
                    let resumesNow = world.calls.resumes  // bound first: `setValue` takes a @Sendable autoclosure
                    secondRoadError.setValue(error)
                    resumesWhenRefused.setValue(resumesNow)
                }
            })
        }
        let outcome = try await world.runner.enterCastle(passphrase: "sesame", recoveryWords: world.words)
        #expect(outcome.entersCastle)
        await secondRoad.value?.value
        guard let refusal = secondRoadError.value, case PostureSwitchError.switchInProgress = refusal else {
            Issue.record("the second road is refused at the guard: \(String(describing: secondRoadError.value))")
            return
        }
        #expect(resumesWhenRefused.value == 0, "the refused second road resumed NOTHING — the pause is road 1's to balance")
        #expect(world.calls.pauses == 1 && world.calls.resumes == 1, "one pause, one resume — road 1's own, at its end")
    }

    // MARK: - Leaving Castle

    @Test func leavingCastleAddsTheAppleHeldCopiesAndMovesCustodySilentRotatingNothing() async throws {
        let world = try await makeWorld(standard: false)
        defer { world.tearDown() }
        let mirror = try #require(world.mirror)
        let material = try #require(world.oldMaterial)
        let corpusBefore = try await world.vault().format.classKey(for: .corpus)?.keyID
        let storedBefore = await mirror.stored()

        try await world.runner.leaveCastle()

        let vault = try await world.vault()
        #expect(vault.format.appleKeyID == world.apple.id)
        #expect(try vault.format.unwrapMaster(withAppleKey: world.apple.symmetricKey).withUnsafeBytes { Data($0) } == material.masterKey,
                "M under A in the vault")
        #expect(vault.format.classKey(for: .corpus)?.keyID == corpusBefore, "nothing rotated")
        #expect(vault.format.previousCorpusKey == nil)
        let keyFile = try #require(try StoreKeyEnvelope.loadCurrent(besideStore: world.storeURL))
        #expect(keyFile.appleKeyID == world.apple.id)
        #expect(try keyFile.unwrapKey(apple: world.apple.symmetricKey) == world.oldKey, "the key file's Apple copy of L")
        #expect(StoreEncryptionMigration.opens(world.storeURL, key: world.oldKey), "the library key is unchanged")
        #expect(world.calls.custodyTargets == [.auto], "custody gated → plain, both items, through the one move")
        #expect(world.posture == .standard)
        let batchesAfter = await mirror.reencryptBatches
        let storedAfter = await mirror.stored()
        #expect(batchesAfter.isEmpty && storedAfter == storedBefore, "the mirror untouched")
        #expect(try await world.marker() == nil, "no marker for a re-wrap")
    }

    @Test func leavingCastleRefusesUnderStandard() async throws {
        let world = try await makeWorld(enrolled: false)
        defer { world.tearDown() }
        await #expect(throws: PostureSwitchError.wrongPosture(.standard)) {
            try await world.runner.leaveCastle()
        }
    }

    // MARK: - The ceremony's brain (copy §2b in order)

    private func makeController(for world: World) -> ProtectionController {
        let syncLeaves = RecordingSyncLeaves(
            plain: SyncCustodyRecord(deviceID: "device-2b", material: world.oldMaterial))
        let controller = ProtectionController(configuration: .init(
            scope: "Variorum2b", storeURL: world.storeURL, gate: world.gate,
            isRealVariant: true,
            makeKDF: { self.fastKDF() },
            storeID: { (try? StoreKeyEnvelope.loadCurrent(besideStore: world.storeURL))?.storeID },
            syncCustodyLeaves: { _ in syncLeaves.leaves },
            syncCustodySession: SyncCustodySession()))
        controller.refreshEnvelopeFacts()
        return controller
    }

    /// **RUN A batch A2, row 13 (17l item 7 / QUESTIONS #90 (11), MINOR-N4
    /// (2)): a ceremony that fails AFTER *Generate New Ones* says the words
    /// she just wrote down are not in use.** F3 fixed MINOR-N4 (1) by moving
    /// MAJOR-3 (b)'s refusal to the door, so the words screens never run for
    /// a ceremony whose step 2 would refuse — but every other post-screen
    /// failure still lands with twelve fresh words on paper and nothing
    /// behind them, and the failure sentence alone never said so. The tail
    /// rides the instance `wording`, which is exactly the set of failures
    /// reachable after the screens.
    ///
    /// **RED ON OLD: the failure said only why the act failed.**
    @Test func aCeremonyFailingAfterGenerateNewOnesSaysTheFreshWordsNeverLanded() async throws {
        let world = try await makeWorld()
        defer { world.tearDown() }
        arm(world, faultAt: .beforeVaultWrite)
        let controller = makeController(for: world)
        // The account already carries words, so the ceremony offers the
        // choice that *Generate New Ones* is one half of.
        let tie = VaultTie(
            hasRecoveryWrap: true,
            verifyPassphrase: { _ in .match },
            verifyRecoveryWords: { _ in .match })
        let model = PostureSwitchModel(
            mode: .replaceKeys, runner: world.runner, controller: controller,
            vaultTie: tie, passphraseInHand: "sesame")

        await model.start()
        #expect(model.phase == .explain, "\(model.phase)")
        model.continueFromExplain()
        #expect(model.phase == .wordsExisting, "words exist ⇒ the choice: \(model.phase)")
        model.chooseGenerateNewWords()
        guard case .wordsShow(let fresh) = model.phase else {
            Issue.record("Generate New Ones shows twelve fresh words: \(model.phase)")
            return
        }
        model.acknowledgeWordsWritten()
        model.confirmWords(fresh.joined(separator: " "))
        // The act runs and the injected fault fails it.
        for _ in 0..<400 {
            if case .failed = model.phase { break }
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(5))
        }
        guard case .failed(let sentence) = model.phase else {
            Issue.record("the injected fault fails the act: \(model.phase)")
            return
        }
        #expect(sentence.hasSuffix(ProtectionCopy.freshWordsNeverLanded),
                "the words she just wrote down open nothing, and the sentence must say so: \(sentence)")
        #expect(sentence.count > ProtectionCopy.freshWordsNeverLanded.count,
                "the tail is a TAIL — the failure's own reason still leads")
        // (The world's vault is born by the wrap-free 14b-era `setUp(passphrase:)`
        // — see row 15's trace — so "the account's words still stand" is NOT a
        // claim this world can carry. What IS local and sound: the ceremony
        // reported no outcome, so nothing it would have minted took effect.)
        #expect(model.outcome == nil, "a failed ceremony landed nothing")

        // The guard: the SAME failure with her existing words typed carries
        // no tail — nothing new was written down.
        let typed = PostureSwitchModel(
            mode: .replaceKeys, runner: world.runner, controller: controller,
            vaultTie: tie, passphraseInHand: "sesame")
        await typed.start()
        typed.continueFromExplain()
        typed.chooseTypeWords()
        await typed.submitExistingWords(world.words.joined(separator: " "))
        for _ in 0..<400 {
            if case .failed = typed.phase { break }
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(5))
        }
        guard case .failed(let plain) = typed.phase else {
            Issue.record("the injected fault fails this act too: \(typed.phase)")
            return
        }
        #expect(!plain.contains(ProtectionCopy.freshWordsNeverLanded))
    }

    @Test func theCeremonyWalksTheCopysOrderRefusingAWrongPassphraseAgainstTheVaultAndAWrongReEntry() async throws {
        let world = try await makeWorld()
        defer { world.tearDown() }
        try world.addPreSwitchPair()
        let controller = makeController(for: world)
        #expect(controller.hasPassphraseWrap, "the world's key file carries a passphrase wrap — screen 2 is skipped")
        var vaultChecks: [String] = []
        let tie = VaultTie(
            hasRecoveryWrap: false,
            verifyPassphrase: { typed in
                vaultChecks.append(typed)
                return typed == "sesame" ? .match : .mismatch("not the account's")
            },
            verifyRecoveryWords: { _ in .couldNotCheck("unused") })
        let model = PostureSwitchModel(mode: .enter, runner: world.runner, controller: controller, vaultTie: tie)

        await model.start()
        #expect(model.phase == .explain)
        model.continueFromExplain()
        guard case .wordsShow(let words) = model.phase else {
            Issue.record("no words anywhere ⇒ fresh words are shown once: \(model.phase)")
            return
        }
        #expect(words.count == 12)
        model.acknowledgeWordsWritten()
        #expect(model.phase == .wordsConfirm(words))
        model.confirmWords(words.reversed().joined(separator: " "))
        #expect(model.lastError == ProtectionCopy.wordsMismatch, "a wrong re-entry is refused")
        #expect(model.phase == .wordsConfirm(words))
        model.confirmWords(words.joined(separator: " "))
        #expect(model.phase == .floor(needsPassphrase: true), "the passphrase was not just set ⇒ typed at the floor")

        await model.enterCastle(passphrase: "sesame", acknowledged: false)
        #expect(model.lastError == ProtectionCopy.floorCheckbox, "the floor must be read")
        await model.enterCastle(passphrase: "not-the-passphrase", acknowledged: true)
        #expect(model.lastError == ProtectionCopy.passphraseNotTheLibrarys, "checked against the VAULT's copy")
        #expect(vaultChecks == ["not-the-passphrase"])
        #expect(model.phase == .floor(needsPassphrase: true))
        #expect(try await world.marker() == nil, "nothing ran")

        await model.enterCastle(passphrase: "sesame", acknowledged: true)
        #expect(vaultChecks == ["not-the-passphrase", "sesame"])
        guard case .done(let insuranceOff, let hasOffer) = model.phase else {
            Issue.record("expected done, got \(model.phase)")
            return
        }
        #expect(!insuranceOff && hasOffer)
        #expect(!controller.switchInProgress)
        let outcome = try #require(model.outcome)
        world.words = words  // the ceremony's own words, not the world's
        try await expectCastleEndState(world, outcome)
        #expect(try world.keyFile(outcome.newKeyFingerprint).recovery != nil, "L′ under the confirmed words")
        model.continueFromDone()
        #expect(model.phase == .offer)
        model.keepOldBackups()
        #expect(model.phase == .closed)
        #expect(world.calls.deletedPairs.value.isEmpty, "Keep Them deletes nothing")
    }

    // MARK: - pre-13x 2c.1a: THE DRAIN BOUND (the 2b adjudication's item 2)

    /// Step 1 pushes until the outbox is EMPTY — at most three rounds — then
    /// refuses with the count. ONE engine push already drains a whole quiet
    /// outbox (every chunk of every row; the "1,000 rows per push" reading
    /// in 2b's question was wrong about the engine), and every reject the
    /// merge matrix answers clears or re-pushes within that same push — so
    /// what a round cannot finish is a LOCAL WRITE LANDING DURING IT (an
    /// autosave racing the round). One such keystroke is drained by the
    /// second round; a writer that never stops meets the bound: the third
    /// round ends with the honest refusal and the count, nothing begun.
    /// RED ON OLD (2b's single push then refuse): the one-keystroke world
    /// throws `outboxNotEmpty(pending: 1)` after its one push + pull.
    @Test func stepOneDrainsTheOutboxBoundedAtThreeRounds() async throws {
        let world = try await makeWorld()
        defer { world.tearDown() }
        let mirror = try #require(world.mirror)
        // A large quiet backlog beside it — proof that size alone never
        // needs a second round.
        try await seedBacklog(world, count: 1_250, tag: "backlog")
        // ONE keystroke lands mid-round (during the first pull).
        let view = world.view
        await mirror.setOnPull(times: 1) {
            try await view.write { db in
                try db.execute(
                    sql: "INSERT INTO container (id, kind, title, created_at, updated_at) VALUES (?, 'post', ?, ?, ?)",
                    arguments: ["typed-mid-round", "typed mid-round", "2026-09-05T00:00:00Z", "2026-09-05T00:00:00Z"])
            }
        }
        let pushesBefore = await mirror.pushes
        let outcome = try await world.runner.enterCastle(passphrase: "sesame", recoveryWords: world.words)
        #expect(outcome.entersCastle)
        #expect(try await outboxCount(world) == 0, "drained before the vault write — the second round landed the mid-round row")
        #expect(await mirror.pushes - pushesBefore >= 2, "a second push round ran")
        let stored = await mirror.stored()
        #expect(stored.keys.filter { $0.hasPrefix("container/backlog-") }.count == 1_250, "the whole backlog reached the mirror in one push")
        #expect(stored["container/typed-mid-round"] != nil, "the mid-round row reached the mirror before the vault write")

        // THE BOUND: a writer that never stops — three rounds, then the
        // refusal names what is left; nothing began.
        let stuck = try await makeWorld()
        defer { stuck.tearDown() }
        let stuckMirror = try #require(stuck.mirror)
        let stuckView = stuck.view
        await stuckMirror.setOnPull(times: Int.max) {
            try await stuckView.write { db in
                try db.execute(
                    sql: "INSERT INTO container (id, kind, title, created_at, updated_at) VALUES (?, 'post', ?, ?, ?)",
                    arguments: [UUID().uuidString, "still typing", "2026-09-05T00:00:00Z", "2026-09-05T00:00:00Z"])
            }
        }
        // (`pullToHead` reads two windows per round — the rows, then the
        // empty tail — so the writer lands two rows a round; the COUNT is
        // whatever is left, named honestly.)
        await #expect("three rounds, then the count") {
            _ = try await stuck.runner.enterCastle(passphrase: "sesame", recoveryWords: stuck.words)
        } throws: { error in
            if case SyncError.outboxNotEmpty(let pending) = error { return pending >= 1 }
            return false
        }
        #expect(try await stuck.marker() == nil, "nothing began")
        #expect(try await stuck.vault().format.previousCorpusKey == nil, "no vault write")
        #expect(StoreEncryptionMigration.opens(stuck.storeURL, key: stuck.oldKey), "nothing re-keyed")
    }

    // MARK: - pre-13x 2c.1b: THE TWO RESUME ARMS (the 2b adjudication's item 6)

    /// Through the fault leaf: (a) the vault write NEVER LANDED — the
    /// marker at `.vaultWrite`, the vault untouched — so the resume says
    /// `restartRequired`, clears the marker and re-keys nothing; (b) the
    /// write LANDED but custody did not — the resume asks for the
    /// passphrase, then picks M′ up from the vault (the follow's own arm),
    /// finishes the walk and completes the switch. RED ON OLD: (a) with the
    /// never-landed branch gone the resume "completes" a rotation that never
    /// began; (b) with the follow-by-passphrase branch gone the resume runs
    /// the walk on the OLD material and meets `staleMaster`.
    @Test func theResumeRestartsWhenTheVaultWriteNeverLandedAndFollowsByThePassphraseWhenCustodyDidNot() async throws {
        // (a) before the vault write
        do {
            let world = try await makeWorld()
            defer { world.tearDown() }
            arm(world, faultAt: .beforeVaultWrite)
            let revisionBefore = try await world.vault().revision
            await #expect(throws: PostureSwitchError.injectedFault(.beforeVaultWrite)) {
                _ = try await world.runner.enterCastle(passphrase: "sesame", recoveryWords: world.words)
            }
            #expect(try await world.marker()?.step == .vaultWrite)
            #expect(try await world.vault().revision == revisionBefore, "the write never landed")
            arm(world, faultAt: nil)
            await #expect(throws: PostureSwitchError.restartRequired) {
                _ = try await world.runner.resume(passphrase: nil)
            }
            #expect(try await world.marker() == nil, "the marker is cleared — the ceremony starts over")
            #expect(StoreEncryptionMigration.opens(world.storeURL, key: world.oldKey), "nothing was re-keyed")
            #expect(world.calls.rekeys == 0 && world.calls.custodyTargets.isEmpty)
            #expect(world.keyStore.load()?.corpusKeyID == world.oldMaterial?.corpusKeyID, "custody untouched")
        }
        // (b) after the vault write, before custody
        do {
            let world = try await makeWorld()
            defer { world.tearDown() }
            let oldMaterial = try #require(world.oldMaterial)
            arm(world, faultAt: .afterVaultWriteBeforeCustody)
            await #expect(throws: PostureSwitchError.injectedFault(.afterVaultWriteBeforeCustody)) {
                _ = try await world.runner.enterCastle(passphrase: "sesame", recoveryWords: world.words)
            }
            #expect(try await world.marker()?.step == .vaultWrite)
            let vault = try await world.vault()
            #expect(vault.format.previousCorpusKey != nil, "the write landed: a rotation is open on the server")
            #expect(vault.format.classKey(for: .corpus)?.keyID != oldMaterial.corpusKeyID)
            #expect(world.keyStore.load()?.corpusKeyID == oldMaterial.corpusKeyID, "custody still holds the OLD keys")
            arm(world, faultAt: nil)
            await #expect(throws: PostureSwitchError.passphraseRequired, "M′ is on the server only — the passphrase is asked") {
                _ = try await world.runner.resume(passphrase: nil)
            }
            let outcome = try await world.runner.resume(passphrase: "sesame", recoveryWords: world.words)
            try await expectCastleEndState(world, outcome)
            #expect(outcome.reencrypted >= 3, "the walk ran after the follow-by-passphrase picked M′ up")
        }
    }

    // MARK: - pre-13x 2c.1: THE FOLLOW (§7)

    /// The acting device is KILLED after the vault write with every row
    /// still under the previous key; a STANDARD sibling — opened as it did,
    /// its old-key round refused at the fence — follows by the passphrase
    /// ONCE: M′ from the vault, C′ + the previous key under M′, custody
    /// replaced, the walk FINISHED and the previous key cleared at head,
    /// its own library re-keyed (L′ under P and M′, no Apple copy, NO W
    /// copy — the words were not typed), custody behind Touch ID, the offer
    /// listed (it was Standard-shaped); then it pulls to an IDENTICAL store
    /// (every note in the clear) and its pending row pushes under C′ with
    /// CAS. A wrong word lands nothing. Then the killed acting device
    /// resumes by its passphrase and finds nothing left to re-encrypt.
    @Test func aStandardSiblingFollowsByThePassphraseFinishesTheRotationAndPullsToAnIdenticalStore() async throws {
        let acting = try await makeWorld()
        defer { acting.tearDown() }
        let sibling = try await makeWorld(sharing: acting)
        defer { sibling.tearDown() }
        let mirror = try #require(acting.mirror)
        let oldMaterial = try #require(acting.oldMaterial)
        try sibling.addPreSwitchPair()
        // The sibling's own three notes reach the mirror under the OLD key.
        let siblingEngine = SyncEngine(transport: mirror, keyProvider: DeviceKeySyncProvider(store: sibling.keyStore))
        try await withDependencies { $0.database = sibling.view } operation: {
            _ = try await siblingEngine.push()
            _ = try await siblingEngine.pull()
        }
        // The acting device dies after the vault write.
        arm(acting, faultAt: .afterVaultWriteBeforeCustody)
        await #expect(throws: PostureSwitchError.injectedFault(.afterVaultWriteBeforeCustody)) {
            _ = try await acting.runner.enterCastle(passphrase: "sesame", recoveryWords: acting.words)
        }
        let open = try await acting.vault()
        #expect(open.format.previousCorpusKey != nil && open.format.rotationStartedSeq != nil, "rows still under the previous key")

        // The un-followed sibling: a pending row, a refused round, nothing lost.
        try await seedBacklog(sibling, count: 1, tag: "typed-before-following")
        await #expect(throws: SyncError.encryptionKeysReplaced, "the fence refuses the old keys first") {
            try await withDependencies { $0.database = sibling.view } operation: { _ = try await siblingEngine.pull() }
        }
        #expect(try await outboxCount(sibling) >= 1, "the edit queues in the outbox")
        // M′ lands only after P or W: a wrong word writes nothing.
        await #expect(throws: VaultEnrollmentError.wrongPassphrase) {
            _ = try await sibling.runner.follow(passphrase: "not-the-passphrase", recoveryWords: nil)
        }
        #expect(try await sibling.marker() == nil)
        #expect(sibling.keyStore.load()?.corpusKeyID == oldMaterial.corpusKeyID, "custody unchanged")
        #expect(StoreEncryptionMigration.opens(sibling.storeURL, key: sibling.oldKey))

        // pre-13x 4b.3 (the 2c adjudication's item 4; decision 6 per DEVICE):
        // the FOLLOWER's own scheduled plaintext insurance is ON — it goes
        // OFF with the notice as it enters Castle.
        MarkdownInsurance.setEnabled(true, in: sibling.defaults)
        // THE FOLLOW, by the passphrase once.
        let outcome = try await sibling.runner.follow(passphrase: "sesame", recoveryWords: nil)
        #expect(outcome.entersCastle)
        #expect(outcome.insuranceTurnedOff && !MarkdownInsurance.isEnabled(in: sibling.defaults),
                "4b.3: the follower's OWN insurance turned OFF with the notice (decision 6 is per device)")
        let material = try #require(outcome.material)
        let vault = try await sibling.vault()
        #expect(vault.format.previousCorpusKey == nil && vault.format.rotationStartedSeq == nil,
                "the FOLLOWER finished the rotation and cleared the previous key + the seq at head")
        #expect(material.corpusKeyID == vault.format.classKey(for: .corpus)?.keyID && material.rotation == nil)
        #expect(sibling.keyStore.load()?.corpusKeyID == material.corpusKeyID, "custody REPLACED")
        #expect(outcome.reencrypted >= 6, "the follower re-encrypted the acting device's rows and its own")
        let newFile = try sibling.keyFile(outcome.newKeyFingerprint)
        let newKey = try newFile.unwrapKey(passphrase: "sesame")
        #expect(StoreEncryptionMigration.opens(sibling.storeURL, key: newKey), "the sibling's library is under L′")
        #expect(!StoreEncryptionMigration.opens(sibling.storeURL, key: sibling.oldKey))
        #expect(newFile.passphrase?.kdf == vault.format.kdf, "L′ under P with the VAULT's descriptor — the lobby derives once")
        #expect(try newFile.unwrapKey(master: material.masterSymmetricKey) == newKey, "L′ under M′")
        #expect(newFile.apple == nil && newFile.appleKeyID == nil, "no Apple copy enters Castle")
        #expect(newFile.recovery == nil, "the words were not typed — the W copy lands when they are")
        #expect(sibling.calls.custodyTargets.last == .biometric && sibling.posture == .castle)
        #expect(outcome.preSwitchSnapshots.count == 1, "the offer: it was Standard-shaped, so its old pairs open through the Apple account")
        #expect(sibling.calls.resumes >= 1, "sync resumed — the pull from the own cursor")
        #expect(try await sibling.marker() == nil)

        // The pull from the own cursor: every note in the clear, the
        // pending row pushed under C′, and the acting device reads it back.
        try await withDependencies { $0.database = sibling.view } operation: {
            _ = try await siblingEngine.pull()
            let report = try await siblingEngine.push()
            #expect(report.accepted >= 1, "the pending row pushes under C′ with CAS")
        }
        #expect(try await outboxCount(sibling) == 0)
        let titles = try await sibling.view.read { db in
            try Row.fetchAll(db, sql: "SELECT id, title FROM container").reduce(into: [String: String]()) { acc, row in
                let id: String = row["id"]; let title: String? = row["title"]; acc[id] = title
            }
        }
        for (id, title) in acting.seededTitles {
            #expect(titles[id] == title, "the follower reads the acting device's \(id) in the clear")
        }
        // The killed acting device resumes by its passphrase: nothing is
        // left below the seq — the follower finished it — and its own
        // re-key completes.
        arm(acting, faultAt: nil)
        let resumed = try await acting.runner.resume(passphrase: "sesame", recoveryWords: acting.words)
        try await expectCastleEndState(acting, resumed)
        #expect(resumed.reencrypted == 0, "the follower had already finished the walk")
        let actingEngine = SyncEngine(transport: mirror, keyProvider: DeviceKeySyncProvider(store: acting.keyStore))
        try await withDependencies { $0.database = acting.view } operation: { _ = try await actingEngine.pull() }
        let seen = try await acting.view.read { db in
            try String.fetchOne(db, sql: "SELECT title FROM container WHERE id = 'typed-before-following-0'")
        }
        #expect(seen == "typed-before-following 0", "the sibling's pending row reached the acting device in the clear")
    }

    /// pre-13x 2d (decision 35) — THE NO-ROTATION FOLLOW over the real
    /// runner: the account is Castle-shaped (the 2b world's vault carries no
    /// Apple-held copy — the 2c drill record's own finding) while this
    /// library is Standard-shaped (an `apple` copy in its key file, custody
    /// silent) and the keys are UNCHANGED. The passphrase, verified against
    /// the vault's copy (a wrong word writes nothing), takes the road: no
    /// new master, no marker at `.reencrypt`, no vault write, nothing
    /// re-encrypted — custody's keys stay; the library is RE-KEYED (a new
    /// L′), custody moves behind the gate, a NEW key file lands under the
    /// new fingerprint (L′ under P with the VAULT's descriptor + under M;
    /// NO `apple` copy; the vault's descriptor and corpus key id recorded),
    /// and the OLD key file leaves the live folder — A opens no page of the
    /// re-keyed library. RED ON OLD: the follow walked the rotation road
    /// against unchanged keys (a redundant custody replacement and a
    /// `.reencrypt` marker), and the old Standard-era key file stayed
    /// beside the Castle library.
    @Test func theMismatchFollowReKeysTheLibraryMovesCustodyBehindTheGateAndRemovesTheOldKeyFile() async throws {
        let world = try await makeWorld()
        defer { world.tearDown() }
        let material = try #require(world.oldMaterial)
        let mirror = try #require(world.mirror)
        let vaultBefore = try await world.vault()
        #expect(vaultBefore.format.masterWrappedByAppleHeld == nil, "the account is Castle-shaped")
        let oldFile = try #require(try StoreKeyEnvelope.loadCurrent(besideStore: world.storeURL))
        #expect(oldFile.apple != nil && world.guardBacking.auto == world.oldKey, "this library is Standard-shaped")
        let oldURL = world.oldKeyFileURL
        #expect(FileManager.default.fileExists(atPath: oldURL.path))

        // The runner over a COUNTING custody store: the no-rotation road
        // never re-saves custody (the rotation road saves twice).
        let saves = LockIsolated(0)
        let store = world.keyStore
        let counting = DeviceKeyStore(
            load: { store.load() },
            save: { saves.withValue { $0 += 1 }; return store.save($0) },
            clear: { store.clear() },
            deviceID: { store.deviceID() })
        let runner = PostureSwitchRunner(leaves: leaves(for: world, keyStore: counting))

        // A wrong word writes nothing.
        await #expect(throws: VaultEnrollmentError.wrongPassphrase) {
            _ = try await runner.follow(passphrase: "not-the-passphrase", recoveryWords: nil)
        }
        #expect(world.calls.rekeys == 0 && FileManager.default.fileExists(atPath: oldURL.path))
        #expect(try await world.marker() == nil)

        // The wrap-less legacy stub beside the library (her phone's 79 B file).
        let stubURL = StoreKeyEnvelope.legacyURL(besideStore: world.storeURL)
        try Data("{\n  \"formatVersion\" : 1,\n  \"storeID\" : \"\(oldFile.storeID)\"\n}".utf8).write(to: stubURL)

        let outcome = try await runner.follow(passphrase: "sesame", recoveryWords: nil)
        #expect(outcome.entersCastle && outcome.reencrypted == 0)
        #expect(saves.value == 0, "custody never re-saved — the new-master half was skipped")
        #expect(!FileManager.default.fileExists(atPath: stubURL.path), "the wrap-less legacy stub removed too (2d.4, ruling 5)")
        let held = try #require(world.keyStore.load())
        #expect(held.corpusKeyID == material.corpusKeyID && held.masterKey == material.masterKey,
                "custody's keys UNCHANGED — no rotation")
        #expect(try await world.vault().revision == vaultBefore.revision, "no vault write")
        #expect(await mirror.reencryptBatches.isEmpty, "nothing re-encrypted")
        #expect(world.calls.rekeys == 1, "the library RE-KEYED")
        #expect(world.calls.custodyTargets == [.biometric] && world.posture == .castle, "custody behind the gate")
        let newFile = try world.keyFile(outcome.newKeyFingerprint)
        let newKey = try newFile.unwrapKey(passphrase: "sesame")
        #expect(StoreEncryptionMigration.opens(world.storeURL, key: newKey), "the library is under L′")
        #expect(!StoreEncryptionMigration.opens(world.storeURL, key: world.oldKey))
        #expect(newFile.apple == nil && newFile.appleKeyID == nil, "NO Apple copy")
        #expect(newFile.passphrase?.kdf == vaultBefore.format.kdf, "L′ under P with the VAULT's descriptor")
        #expect(newFile.vaultKDF == vaultBefore.format.kdf && newFile.vaultCorpusKeyID == material.corpusKeyID,
                "the descriptor and the corpus key id recorded — no confirm owed")
        #expect(try newFile.unwrapKey(master: material.masterSymmetricKey) == newKey, "L′ under M")
        #expect(!FileManager.default.fileExists(atPath: oldURL.path), "the OLD key file REMOVED from the live folder")
        #expect(try StoreKeyEnvelope.loadCurrent(besideStore: world.storeURL)?.keyFingerprint == outcome.newKeyFingerprint,
                "locate finds exactly the new file")
        // A opens NO page of the re-keyed library: the old file's Apple copy
        // unwraps only the OLD key, which opens nothing now.
        let viaApple = try oldFile.unwrapKey(apple: world.apple.symmetricKey)
        #expect(viaApple == world.oldKey && !StoreEncryptionMigration.opens(world.storeURL, key: viaApple))
        #expect(try await world.marker() == nil && world.calls.resumes >= 1 && world.calls.reconciles >= 1)
    }

    /// pre-13x 3a — ENROLL (c) IS THE FOLLOW (the orchestrator's reading):
    /// a Standard-born library (its key file carries the iCloud copy) that
    /// has NEVER enrolled — no custody, no master copy — joins a CASTLE
    /// account through `runner.follow` with the typed passphrase: M from
    /// the vault lands in custody, the library is RE-KEYED (its old key had
    /// an iCloud copy), a NEW key file lands under the new fingerprint with
    /// the master copy, the vault's descriptor and NO Apple copy, custody
    /// goes behind the gate, the old key file leaves the live folder, the
    /// app's own pre-switch pairs are offered, the vault and the mirror are
    /// untouched. Green by construction on this tree (the runner's rotation
    /// road with no custody held is exactly this) — the composition pin the
    /// session's routing (`EnrollDirectionsTests`) relies on; recorded.
    @Test func aStandardBornLibraryWithNoCustodyJoinsCastleThroughTheFollow() async throws {
        let world = try await makeWorld()
        defer { world.tearDown() }
        let material = try #require(world.oldMaterial)
        let mirror = try #require(world.mirror)
        let vaultBefore = try await world.vault()
        #expect(vaultBefore.format.masterWrappedByAppleHeld == nil, "the account is Castle-shaped")
        // Never enrolled here: no custody, and a key file with P + the Apple copy only.
        world.keyStore.clear()
        var file = try #require(try StoreKeyEnvelope.loadCurrent(besideStore: world.storeURL))
        file.master = nil
        try file.write(at: file.preferredURL(besideStore: world.storeURL))
        let oldURL = world.oldKeyFileURL
        try world.addPreSwitchPair()
        #expect(world.keyStore.load() == nil)

        let outcome = try await world.runner.follow(passphrase: "sesame", recoveryWords: nil)
        #expect(outcome.entersCastle && outcome.reencrypted == 0)
        let held = try #require(world.keyStore.load())
        #expect(held.masterKey == material.masterKey && held.corpusKeyID == material.corpusKeyID, "M from the vault, in custody")
        #expect(world.calls.rekeys == 1 && world.calls.custodyTargets == [.biometric] && world.posture == .castle)
        let newFile = try world.keyFile(outcome.newKeyFingerprint)
        let newKey = try newFile.unwrapKey(passphrase: "sesame")
        #expect(StoreEncryptionMigration.opens(world.storeURL, key: newKey) && !StoreEncryptionMigration.opens(world.storeURL, key: world.oldKey))
        #expect(newFile.apple == nil && newFile.master != nil && newFile.vaultKDF == vaultBefore.format.kdf
                && newFile.vaultCorpusKeyID == material.corpusKeyID, "the joined library's key file")
        #expect(try newFile.unwrapKey(master: material.masterSymmetricKey) == newKey)
        #expect(!FileManager.default.fileExists(atPath: oldURL.path), "the Standard-era key file left the live folder")
        #expect(outcome.preSwitchSnapshots.count == 1, "its old pairs opened through the Apple account — offered")
        let batches = await mirror.reencryptBatches
        #expect(try await world.vault().revision == vaultBefore.revision && batches.isEmpty, "nothing rotated")
        #expect(try await world.marker() == nil)
    }

    /// pre-13x 2d.4 (the orchestrator's ruling 3): a FOLLOW killed after the
    /// re-key and before the old key files' removal — the marker at
    /// `.rekeyLibrary`, flagged as a follow — RESUMES and still retires
    /// them: the old fingerprint-named file AND the wrap-less legacy stub
    /// are gone at the end, custody behind the gate, the marker clear. The
    /// exposure's closure never depends on the process surviving. RED ON
    /// OLD: the removal ran after the road returned, and the marker's
    /// resume did not know it was a follow — the Standard-era key file
    /// stayed beside the Castle library after a crash.
    @Test func aFollowKilledAfterTheReKeyResumesAndStillRetiresTheOldKeyFiles() async throws {
        let world = try await makeWorld()
        defer { world.tearDown() }
        let oldFile = try #require(try StoreKeyEnvelope.loadCurrent(besideStore: world.storeURL))
        let oldURL = world.oldKeyFileURL
        let stubURL = StoreKeyEnvelope.legacyURL(besideStore: world.storeURL)
        try Data("{\n  \"formatVersion\" : 1,\n  \"storeID\" : \"\(oldFile.storeID)\"\n}".utf8).write(to: stubURL)

        world.calls.rekeyFault = .afterWork  // the swap landed; the process dies before custody
        await #expect(throws: URLError.self) {
            _ = try await world.runner.follow(passphrase: "sesame", recoveryWords: nil)
        }
        let marker = try #require(try await world.marker())
        #expect(marker.step == .rekeyLibrary && marker.isFollow, "the marker knows this road is a follow")
        #expect(FileManager.default.fileExists(atPath: oldURL.path) && FileManager.default.fileExists(atPath: stubURL.path),
                "killed before the removal: both old files still there")
        #expect(!StoreEncryptionMigration.opens(world.storeURL, key: world.oldKey), "…and the library already under L′")

        let outcome = try await world.runner.resume(passphrase: nil)
        #expect(outcome.entersCastle)
        #expect(world.calls.custodyTargets == [.biometric] && world.posture == .castle)
        #expect(try await world.marker() == nil)
        #expect(!FileManager.default.fileExists(atPath: oldURL.path), "the resumed follow retired the old key file")
        #expect(!FileManager.default.fileExists(atPath: stubURL.path), "…and the wrap-less stub")
        #expect(try StoreKeyEnvelope.loadCurrent(besideStore: world.storeURL)?.keyFingerprint == outcome.newKeyFingerprint)
        #expect(StoreKeyEnvelope.keyFileURLs(besideStore: world.storeURL).count == 1, "exactly one key file beside the library")
    }

    /// pre-13x 2d.4 (ruling 5's other half): a legacy-named format-1 key
    /// file WITH wraps is NOT a stub — it may serve legacy snapshots (§6) —
    /// and stays byte-identical through the follow while the old
    /// fingerprint-named file goes. RED ON OLD (batch C4): a removal keyed
    /// on the legacy NAME alone took it.
    @Test func aWrappedLegacyKeyFileStaysAtTheFollow() async throws {
        let world = try await makeWorld()
        defer { world.tearDown() }
        let oldFile = try #require(try StoreKeyEnvelope.loadCurrent(besideStore: world.storeURL))
        var wrapped = StoreKeyEnvelope(storeID: oldFile.storeID)
        try wrapped.setPassphraseWrap(key: world.oldKey, passphrase: "an older word", kdf: fastKDF())
        wrapped.formatVersion = StoreKeyEnvelope.formatVersion1
        let legacyURL = StoreKeyEnvelope.legacyURL(besideStore: world.storeURL)
        try wrapped.write(at: legacyURL)
        let bytesBefore = try Data(contentsOf: legacyURL)

        let outcome = try await world.runner.follow(passphrase: "sesame", recoveryWords: nil)
        #expect(outcome.entersCastle)
        #expect(!FileManager.default.fileExists(atPath: world.oldKeyFileURL.path), "the old fingerprint-named file goes")
        #expect(try Data(contentsOf: legacyURL) == bytesBefore, "a legacy file WITH wraps stays, byte-identical")
        #expect(try StoreKeyEnvelope.loadCurrent(besideStore: world.storeURL)?.keyFingerprint == outcome.newKeyFingerprint,
                "…and `locate` still prefers the fingerprinted file")
    }

    /// A follow by the TWELVE WORDS alone (no passphrase typed): M′ from
    /// the vault's W copy; the new key file carries L′ under W and M′ —
    /// and NO passphrase copy until the passphrase is next typed here.
    @Test func aFollowByTheTwelveWordsLandsTheWCopyAndNoPassphraseCopy() async throws {
        let acting = try await makeWorld()
        defer { acting.tearDown() }
        let sibling = try await makeWorld(sharing: acting)
        defer { sibling.tearDown() }
        _ = try await acting.runner.enterCastle(passphrase: "sesame", recoveryWords: acting.words)
        await #expect(throws: PostureSwitchError.secretRequired) {
            _ = try await sibling.runner.follow(passphrase: nil, recoveryWords: nil)
        }
        let outcome = try await sibling.runner.follow(passphrase: nil, recoveryWords: acting.words)
        let newFile = try sibling.keyFile(outcome.newKeyFingerprint)
        let newKey = try newFile.unwrapKey(recoveryWords: acting.words)
        #expect(StoreEncryptionMigration.opens(sibling.storeURL, key: newKey), "L′ under the typed words")
        #expect(newFile.passphrase == nil, "no passphrase copy — it lands when the passphrase is next typed here")
        #expect(try newFile.unwrapKey(master: try #require(outcome.material).masterSymmetricKey) == newKey)
        #expect(sibling.keyStore.load()?.corpusKeyID == (try await sibling.vault()).format.classKey(for: .corpus)?.keyID)
    }

    /// THE FOLLOW INTO STANDARD is silent: the account left Castle
    /// elsewhere (the vault gained an Apple-held copy under the SAME corpus
    /// key id); this Castle device adds its own iCloud copy to its key file
    /// (A from its own iCloud Keychain), moves custody gated → silent, and
    /// rotates nothing — no vault write, no marker, nothing typed.
    @Test func theFollowIntoStandardAddsTheAppleCopyAndMovesCustodySilentRotatingNothing() async throws {
        let world = try await makeWorld(standard: false)
        defer { world.tearDown() }
        let client = try #require(world.vaultClient)
        let material = try #require(world.oldMaterial)
        // "Another device" left Castle: the vault gains the Apple-held copy.
        let otherDevicesApple = AppleKey.mint()
        let fetched = try await world.vault()
        try await client.updateVault(
            try fetched.format.settingAppleHeldCopy(
                masterKey: material.masterSymmetricKey, appleKey: otherDevicesApple.symmetricKey,
                appleKeyID: otherDevicesApple.id),
            expectedRevision: fetched.revision, keyProof: KeyProofMaterial(master: material.masterSymmetricKey))
        let revisionAfterTheirWrite = try await world.vault().revision

        try await world.runner.followIntoStandard()

        let keyFile = try #require(try StoreKeyEnvelope.loadCurrent(besideStore: world.storeURL))
        #expect(keyFile.appleKeyID == world.apple.id, "THIS device's own A, from its own iCloud Keychain")
        #expect(try keyFile.unwrapKey(apple: world.apple.symmetricKey) == world.oldKey)
        #expect(world.calls.custodyTargets == [.auto] && world.posture == .standard)
        #expect(StoreEncryptionMigration.opens(world.storeURL, key: world.oldKey), "nothing rotated")
        #expect(try await world.vault().revision == revisionAfterTheirWrite, "no vault write of its own")
        #expect(try await world.marker() == nil)
    }

    /// A CASTLE follower of Replace All Keys (run elsewhere, still
    /// finishing): it finishes the walk, re-keys, keeps its Castle gate —
    /// and lists NO offer: its old pairs never opened through the Apple
    /// account, so the offer's sentence would be false.
    @Test func aCastleFollowerOfReplaceAllKeysFinishesTheWalkAndListsNoOffer() async throws {
        let world = try await makeWorld(standard: false)
        defer { world.tearDown() }
        let client = try #require(world.vaultClient)
        let oldMaterial = try #require(world.oldMaterial)
        try world.addPreSwitchPair()
        // "Another device" replaced the keys under Castle and stopped.
        let secrets = try RotationSecrets.derive(passphrase: "sesame", recoveryWords: world.words, kdf: fastKDF())
        _ = try await CorpusRotation.begin(client: client, current: oldMaterial, secrets: secrets, appleHeldCopy: nil)
        #expect(try await world.vault().format.previousCorpusKey != nil)

        let outcome = try await world.runner.follow(passphrase: "sesame", recoveryWords: nil)
        #expect(outcome.entersCastle, "the account is Castle — the gate stays")
        #expect(outcome.preSwitchSnapshots.isEmpty, "a Castle follower is offered nothing")
        #expect(outcome.reencrypted >= 3, "the follower finished the walk")
        let vault = try await world.vault()
        #expect(vault.format.previousCorpusKey == nil && vault.format.rotationStartedSeq == nil)
        #expect(world.calls.custodyTargets.last == .biometric)
        let newFile = try world.keyFile(outcome.newKeyFingerprint)
        #expect(newFile.apple == nil)
        #expect(StoreEncryptionMigration.opens(world.storeURL, key: try newFile.unwrapKey(passphrase: "sesame")))
    }

    // MARK: - pre-13x 3b: REPLACE ALL KEYS (copy §4; decisions 30 · 32 · 33; ledger 17 / 37 / 44)

    /// THE RUNNER'S GUARD (ledger 44 — decision 33 at the runner): a vault
    /// that carries a recovery wrap is never rewritten without the twelve
    /// words in hand — `run(entersCastle:…)` refuses `recoveryWords: nil`
    /// typed, before the marker and before the vault write. RED ON OLD: the
    /// runner minted a wrap-less vault (`beginOverAVaultWithARecoveryWrapLeavesNoStaleWrap`
    /// pinned that as "no stale wrap" — correct for the 14c road, WRONG for
    /// decision 33's doors) and the twelve words died silently.
    @Test func replaceAllKeysRefusesWithoutTheWordsWhenTheVaultCarriesAWrap() async throws {
        let world = try await makeWorld()
        defer { world.tearDown() }
        let client = try #require(world.vaultClient)
        let material = try #require(world.oldMaterial)
        try await VaultEnrollment(client: client).landRecoveryWrap(words: world.words, material: material)
        let before = try await world.vault()
        #expect(before.format.masterWrappedByRecovery != nil)

        await #expect(throws: PostureSwitchError.wordsRequired) {
            try await world.runner.replaceAllKeys(passphrase: "sesame", recoveryWords: nil)
        }
        let after = try await world.vault()
        #expect(after.revision == before.revision, "nothing was written")
        #expect(after.format.masterWrappedByRecovery == before.format.masterWrappedByRecovery,
                "the twelve words still open the account")
        #expect(after.format.classKey(for: .corpus)?.keyID == material.corpusKeyID, "no rotation began")
        #expect(try await world.marker() == nil)
        #expect(StoreEncryptionMigration.opens(world.storeURL, key: world.oldKey), "the library untouched")
        #expect(world.keyStore.load() == material)
        #expect(PostureSwitchModel.message(for: PostureSwitchError.wordsRequired).contains("twelve words"))

        // The same road WITH the words in hand runs (the 2b road, byte-unchanged).
        let outcome = try await world.runner.replaceAllKeys(passphrase: "sesame", recoveryWords: world.words)
        #expect(!outcome.entersCastle)
        let rotated = try await world.vault()
        #expect(rotated.format.masterWrappedByRecovery != nil, "M′ wrapped under the words in hand")
        #expect(try rotated.format.unwrapMaster(withRecoveryKey: RecoveryPhrase.recoveryWrapKey(words: world.words))
                == outcome.material?.masterSymmetricKey, "the SAME twelve words open M′")
    }

    /// pre-13x ladder round 1, F2 (MAJOR-3 b — decision 30's letter) — RED ON
    /// OLD: `appleHeldCopyForStandard` used `readOrMint()`, so a Standard
    /// Replace All Keys with A momentarily unreadable MINTED a second A and
    /// wrapped M′ under it. Now the copy is kept under the key READ here and
    /// only when it is the vault's; either miss refuses before the marker
    /// and before any write, and the chain it paused is resumed (MAJOR-1).
    @Test func replaceAllKeysUnderStandardRefusesWhenTheAppleKeyIsUnreadableOrAnotherAccountsAndNeverMints() async throws {
        let world = try await makeWorld()
        defer { world.tearDown() }
        let client = try #require(world.vaultClient)
        let material = try #require(world.oldMaterial)
        // The account's Apple-held copy under THIS device's A (sync setup's shape).
        let fetched = try await world.vault()
        try await client.updateVault(
            try fetched.format.settingAppleHeldCopy(
                masterKey: material.masterSymmetricKey, appleKey: world.apple.symmetricKey, appleKeyID: world.apple.id),
            expectedRevision: fetched.revision, keyProof: KeyProofMaterial(master: material.masterSymmetricKey))
        let before = try await world.vault()

        // (1) A unreadable here (propagation lag; iCloud Keychain off).
        world.appleBacking.key = nil
        await #expect(throws: PostureSwitchError.appleKeyUnreachable) {
            _ = try await world.runner.replaceAllKeys(passphrase: "sesame", recoveryWords: world.words)
        }
        #expect(world.appleBacking.key == nil, "NOTHING minted — decision 30: never re-mints the iCloud key")
        let afterOne = try await world.vault()
        #expect(afterOne.revision == before.revision && afterOne.format.appleKeyID == world.apple.id, "no vault write")
        #expect(try await world.marker() == nil && world.calls.rekeys == 0)
        #expect(world.keyStore.load() == material, "custody untouched")
        #expect(world.calls.resumes == world.calls.pauses, "the refusal resumes the chain it paused")

        // (2) A readable but ANOTHER Apple account's (not the vault's id).
        world.appleBacking.key = AppleKey.mint()
        await #expect(throws: PostureSwitchError.appleKeyUnreachable) {
            _ = try await world.runner.replaceAllKeys(passphrase: "sesame", recoveryWords: world.words)
        }
        let afterTwo = try await world.vault()
        #expect(afterTwo.revision == before.revision && afterTwo.format.appleKeyID == world.apple.id, "no vault write")
        #expect(try await world.marker() == nil)
        #expect(PostureSwitchModel.message(for: PostureSwitchError.appleKeyUnreachable)
                == ProtectionCopy.replaceKeysAppleKeyUnreachable, "the refusal speaks copy §4's line")

        // (3) The account's own A readable: the rotation runs and the copy
        // stays under the SAME A (decision 30's presence pin, re-run).
        world.appleBacking.key = world.apple
        let outcome = try await world.runner.replaceAllKeys(passphrase: "sesame", recoveryWords: world.words)
        let rotated = try await world.vault()
        #expect(rotated.format.appleKeyID == world.apple.id && rotated.format.masterWrappedByAppleHeld != nil)
        #expect(try rotated.format.unwrapMaster(withAppleKey: world.apple.symmetricKey) == outcome.material?.masterSymmetricKey)
    }

    /// pre-13x ladder round 2, F3 (MINOR-N4) — RED ON OLD: MAJOR-3 (b)'s
    /// refusal fired at STEP 2 of the run, after Screens 2–4 — with
    /// *Generate New Ones* the twelve words she had just written down opened
    /// NOTHING (never landed) and the `.failed` sentence said nothing of it.
    /// Now the DOOR reads A (decision 32's pattern — `DoorFacts
    /// .appleKeyReadable`) and refuses before any screen; the account's own
    /// A opens onto the explain screen; under Castle no Apple copy is owed
    /// and the fact is nil. The runner's step-2 check stays as the belt
    /// (the pin above).
    @Test func replaceAllKeysRefusesAnUnreachableAppleKeyAtTheDoorBeforeAnyScreen() async throws {
        let world = try await makeWorld()
        defer { world.tearDown() }
        let client = try #require(world.vaultClient)
        let material = try #require(world.oldMaterial)
        let fetched = try await world.vault()
        try await client.updateVault(
            try fetched.format.settingAppleHeldCopy(
                masterKey: material.masterSymmetricKey, appleKey: world.apple.symmetricKey, appleKeyID: world.apple.id),
            expectedRevision: fetched.revision, keyProof: KeyProofMaterial(master: material.masterSymmetricKey))
        let before = try await world.vault()
        let controller = makeController(for: world)

        // (1) A unreadable here (propagation lag; iCloud Keychain off): the
        // door refuses with copy §4's sentence — no screen, nothing run.
        world.appleBacking.key = nil
        let factsUnreadable = try await world.runner.checkDoor()
        #expect(factsUnreadable.appleKeyReadable == false)
        let unreachable = PostureSwitchModel(mode: .replaceKeys, runner: world.runner, controller: controller, vaultTie: nil)
        await unreachable.start()
        #expect(unreachable.phase == .failed(ProtectionCopy.replaceKeysAppleKeyUnreachable), "\(unreachable.phase)")
        #expect(world.appleBacking.key == nil, "nothing minted")
        let markerAfterOne = try await world.marker()
        let revisionAfterOne = try await world.vault().revision
        #expect(markerAfterOne == nil && revisionAfterOne == before.revision, "nothing ran")

        // (2) A readable but ANOTHER Apple account's: the same door refusal.
        world.appleBacking.key = AppleKey.mint()
        let factsOther = try await world.runner.checkDoor()
        #expect(factsOther.appleKeyReadable == false)
        let other = PostureSwitchModel(mode: .replaceKeys, runner: world.runner, controller: controller, vaultTie: nil)
        await other.start()
        #expect(other.phase == .failed(ProtectionCopy.replaceKeysAppleKeyUnreachable))

        // (3) The account's own A: the door opens onto the explain screen.
        world.appleBacking.key = world.apple
        let factsOwn = try await world.runner.checkDoor()
        #expect(factsOwn.appleKeyReadable == true)
        let open = PostureSwitchModel(mode: .replaceKeys, runner: world.runner, controller: controller, vaultTie: nil)
        await open.start()
        #expect(open.phase == .explain)

        // Under Castle the fact is nil — no Apple-held copy is owed there.
        let castle = try await makeWorld(standard: false)
        defer { castle.tearDown() }
        let castleFacts = try await castle.runner.checkDoor()
        #expect(castleFacts.appleKeyReadable == nil)
    }

    // MARK: - VX-99: a CASTLE Replace All Keys never writes an Apple copy into the new key file

    /// VX-99 (a) — THE CEREMONY ROAD. Her Pro, 2026-09-07: a Replace All Keys
    /// on a CASTLE account wrote the new key file WITH an `apple` copy, because
    /// the Mac still held its iCloud key from the Standard era. The mechanism
    /// (`PostureSwitch.writeNewKeyFile`): `replaceAllKeys` runs the road with
    /// `entersCastle: false`, and the key file's Apple copy was decided by
    /// `entersCastle ? nil : leaves.appleKeys.read()` — ANY readable A — while
    /// the VAULT's side of the same act is posture-gated
    /// (`appleHeldCopyForStandard`). The Castle row of §3.4: the library key
    /// wrapped under P, W and M only. A Castle world here: the vault carries no
    /// Apple-held copy, custody gated, the posture Castle — and the iCloud key
    /// READABLE (her Pro's state). RED ON OLD: the new key file carries
    /// `apple` + `appleKeyID` and opens through the iCloud key.
    @Test func aCastleReplaceAllKeysWritesNoAppleCopyIntoTheNewKeyFileWhileTheICloudKeyIsReadable() async throws {
        let world = try await makeWorld(standard: false)
        defer { world.tearDown() }
        #expect(world.posture == .castle)
        #expect(world.appleBacking.key == world.apple, "the iCloud key is READABLE on this Mac (the Standard era left it)")
        let before = try await world.vault()
        #expect(before.format.masterWrappedByAppleHeld == nil && before.format.appleKeyID == nil, "a Castle account")
        #expect(try StoreKeyEnvelope.load(at: world.oldKeyFileURL)?.apple == nil, "the Castle key file carries no Apple copy")

        let outcome = try await world.runner.replaceAllKeys(passphrase: "sesame", recoveryWords: world.words)

        #expect(!outcome.entersCastle)
        let material = try #require(outcome.material)
        let newFile = try world.keyFile(outcome.newKeyFingerprint)
        let newKey = try newFile.unwrapKey(passphrase: "sesame")
        #expect(StoreEncryptionMigration.opens(world.storeURL, key: newKey), "the library is under L′")
        #expect(newFile.apple == nil && newFile.appleKeyID == nil,
                "§3.4's Castle row: L′ under P, W and M′ only — no copy the iCloud key opens")
        #expect(throws: StoreKeyEnvelopeError.noAppleWrappedCopy, "the iCloud key opens nothing in the new key file") {
            _ = try newFile.unwrapKey(apple: world.apple.symmetricKey)
        }
        #expect(try newFile.unwrapKey(master: material.masterSymmetricKey) == newKey, "L′ under M′")
        #expect(try newFile.unwrapKey(recoveryWords: world.words) == newKey, "L′ under the words in hand")
        let after = try await world.vault()
        #expect(after.format.masterWrappedByAppleHeld == nil && after.format.appleKeyID == nil,
                "the vault still carries no Apple-held copy — the account stays Castle")
        #expect(after.format.classKey(for: .corpus)?.keyID == material.corpusKeyID, "the rotation landed")
        #expect(world.calls.custodyTargets.last == .biometric && world.posture == .castle, "custody stays behind the gate")
        #expect(world.appleBacking.key == world.apple, "the iCloud key untouched — never minted, never deleted")
        #expect(try await world.marker() == nil)
    }

    /// VX-99 (b) — THE RESUME ROAD. `resume` re-enters the same writer with the
    /// marker's `entersCastle` (false for Replace All Keys), so a CASTLE
    /// Replace All Keys that crashed before its key file was written wrote the
    /// Apple copy on its way back. Three seams: (1) mid re-encryption (the
    /// marker at `.reencrypt`); (2) after the vault write, before custody (the
    /// marker at `.vaultWrite` — M′ picked up by the passphrase); (3) the
    /// brief's literal `.rekeyLibrary` (the export refused — the new key file
    /// already written by the ceremony's own road, which the resume reads and
    /// never rewrites). The CONTROL, guarding the other side: a STANDARD
    /// Replace All Keys resumed from seam (1) still lands the Apple copy under
    /// the account's own iCloud key (§7 step 5 — "the key file also gets the
    /// iCloud copy again"). RED ON OLD: seams (1)–(3) end with `apple` set.
    @Test func aCastleReplaceAllKeysResumedAfterACrashWritesNoAppleCopyAndAStandardOneStillDoes() async throws {
        // (1) mid re-encryption.
        do {
            let world = try await makeWorld(standard: false)
            defer { world.tearDown() }
            let mirror = try #require(world.mirror)
            #expect(world.appleBacking.key == world.apple, "the iCloud key is readable")
            await mirror.setCrashNextReencrypt(true)
            await #expect(throws: URLError.self) {
                _ = try await world.runner.replaceAllKeys(passphrase: "sesame", recoveryWords: world.words)
            }
            let marker = try #require(try await world.marker())
            #expect(marker.step == .reencrypt && !marker.entersCastle, "a Replace All Keys marker, mid-walk")
            let outcome = try await world.runner.resume(passphrase: "sesame", recoveryWords: world.words)
            let newFile = try world.keyFile(outcome.newKeyFingerprint)
            #expect(StoreEncryptionMigration.opens(world.storeURL, key: try newFile.unwrapKey(passphrase: "sesame")))
            #expect(newFile.apple == nil && newFile.appleKeyID == nil, "seam 1: the resumed key file carries no Apple copy")
            #expect(try await world.vault().format.masterWrappedByAppleHeld == nil, "the account stays Castle")
            #expect(world.calls.custodyTargets.last == .biometric)
            #expect(try await world.marker() == nil)
        }
        // (2) after the vault write, before custody.
        do {
            let world = try await makeWorld(standard: false)
            defer { world.tearDown() }
            arm(world, faultAt: .afterVaultWriteBeforeCustody)
            await #expect(throws: PostureSwitchError.injectedFault(.afterVaultWriteBeforeCustody)) {
                _ = try await world.runner.replaceAllKeys(passphrase: "sesame", recoveryWords: world.words)
            }
            let marker = try #require(try await world.marker())
            #expect(marker.step == .vaultWrite && !marker.entersCastle)
            arm(world, faultAt: nil)
            let outcome = try await world.runner.resume(passphrase: "sesame", recoveryWords: world.words)
            let newFile = try world.keyFile(outcome.newKeyFingerprint)
            #expect(StoreEncryptionMigration.opens(world.storeURL, key: try newFile.unwrapKey(passphrase: "sesame")))
            #expect(newFile.apple == nil && newFile.appleKeyID == nil, "seam 2: the resumed key file carries no Apple copy")
            #expect(try await world.vault().format.masterWrappedByAppleHeld == nil, "the account stays Castle")
            #expect(try await world.marker() == nil)
        }
        // (3) at `.rekeyLibrary` — the export refused after the new key file landed.
        do {
            let world = try await makeWorld(standard: false)
            defer { world.tearDown() }
            world.calls.rekeyFault = .beforeWork
            await #expect(throws: URLError.self) {
                _ = try await world.runner.replaceAllKeys(passphrase: "sesame", recoveryWords: world.words)
            }
            let marker = try #require(try await world.marker())
            #expect(marker.step == .rekeyLibrary && !marker.entersCastle)
            let outcome = try await world.runner.resume(passphrase: nil)
            let newFile = try world.keyFile(outcome.newKeyFingerprint)
            #expect(StoreEncryptionMigration.opens(world.storeURL, key: try newFile.unwrapKey(passphrase: "sesame")))
            #expect(newFile.apple == nil && newFile.appleKeyID == nil, "seam 3: the key file the resume finished under carries no Apple copy")
            #expect(try await world.marker() == nil)
        }
        // THE CONTROL — a STANDARD Replace All Keys resumed from seam (1) still lands the Apple copy.
        do {
            let world = try await makeWorld()
            defer { world.tearDown() }
            let mirror = try #require(world.mirror)
            #expect(world.posture == .standard)
            await mirror.setCrashNextReencrypt(true)
            await #expect(throws: URLError.self) {
                _ = try await world.runner.replaceAllKeys(passphrase: "sesame", recoveryWords: world.words)
            }
            #expect(try await world.marker()?.step == .reencrypt)
            let outcome = try await world.runner.resume(passphrase: "sesame", recoveryWords: world.words)
            let newFile = try world.keyFile(outcome.newKeyFingerprint)
            let newKey = try newFile.unwrapKey(passphrase: "sesame")
            #expect(StoreEncryptionMigration.opens(world.storeURL, key: newKey))
            #expect(newFile.apple != nil && newFile.appleKeyID == world.apple.id,
                    "Standard's Replace All Keys: the Apple copy again, under the account's own iCloud key")
            #expect(try newFile.unwrapKey(apple: world.apple.symmetricKey) == newKey)
            #expect(try await world.vault().format.masterWrappedByAppleHeld != nil, "decision 30: the vault's copy under the same A")
            #expect(world.calls.custodyTargets.last == .auto && world.posture == .standard)
        }
    }

    /// VX-99 (d) — THE LOCAL-ONLY ROAD (steps 4–7 only). The Replace All Keys
    /// DOOR refuses a library that is not enrolled (`replaceKeysNotEnrolled`),
    /// but the RUNNER takes this road whenever its own enrolled reading fails at
    /// the run (no session, no custody, no vault composed) — the same
    /// `writeNewKeyFile`. A local-only CASTLE library (its key file under P
    /// only, custody gated, the posture its key file's — Castle) with the
    /// iCloud key readable: the new key file carries no Apple copy. The
    /// CONTROL: a local-only STANDARD library still lands it. RED ON OLD: the
    /// Castle file carries `apple`.
    @Test func aLocalOnlyCastleLibrarysReplaceAllKeysWritesNoAppleCopyAndAStandardOneStillDoes() async throws {
        do {
            let world = try await makeWorld(enrolled: false, standard: false)
            defer { world.tearDown() }
            #expect(world.vaultClient == nil && world.posture == .castle)
            #expect(world.appleBacking.key == world.apple, "the iCloud key is readable")
            let outcome = try await world.runner.replaceAllKeys(passphrase: "sesame", recoveryWords: world.words)
            #expect(outcome.material == nil && outcome.reencrypted == 0, "steps 4–7 only")
            let newFile = try world.keyFile(outcome.newKeyFingerprint)
            let newKey = try newFile.unwrapKey(passphrase: "sesame")
            #expect(StoreEncryptionMigration.opens(world.storeURL, key: newKey))
            #expect(newFile.apple == nil && newFile.appleKeyID == nil,
                    "a local-only Castle library's new key file: no copy the iCloud key opens")
            #expect(world.calls.custodyTargets.last == .biometric && world.posture == .castle)
        }
        do {
            let world = try await makeWorld(enrolled: false)
            defer { world.tearDown() }
            #expect(world.vaultClient == nil && world.posture == .standard)
            let outcome = try await world.runner.replaceAllKeys(passphrase: "sesame", recoveryWords: world.words)
            let newFile = try world.keyFile(outcome.newKeyFingerprint)
            let newKey = try newFile.unwrapKey(passphrase: "sesame")
            #expect(newFile.apple != nil && newFile.appleKeyID == world.apple.id, "the CONTROL: a Standard library keeps its Apple copy")
            #expect(try newFile.unwrapKey(apple: world.apple.symmetricKey) == newKey)
            #expect(world.calls.custodyTargets.last == .auto)
        }
    }

    /// VX-99 (e) — THE RESUME's ANOTHER-DEVICE ROAD BY THE VAULT's WORD (the
    /// orchestrator's ruling, 5ce7175b — the record's THE RESUME RULE). A's
    /// STANDARD Replace All Keys is killed BEFORE its own vault write; B enters
    /// Castle whole meanwhile; A resumes with its posture STILL reading Standard
    /// — the indeterminate reading's custody shape (silent), the ready's vault
    /// read never having landed. The resume's `.vaultWrite` arm holds the vault
    /// it just fetched, and that vault says CASTLE (no Apple-held copy): the
    /// road is the FOLLOW into B's switch (`byAnotherDevice`), so it follows
    /// the ACCOUNT exactly as `runFollow` does — no Apple copy in the new key
    /// file, custody to the gate, the Standard-era key file retired from the
    /// live folder, the offer listed (A was Standard-shaped). RED ON OLD
    /// (449f5618): the arm took `marker.entersCastle` (false) and the posture
    /// read (Standard) — the new key file carried `apple`, custody went
    /// `.auto`, the old Standard-era file stayed, and the outcome said "keys
    /// replaced" on a Castle account.
    @Test func aStandardReplaceAllKeysResumedIntoAnotherDevicesCastleFollowsTheVaultNotAStalePosture() async throws {
        let a = try await makeWorld()
        defer { a.tearDown() }
        let b = try await makeWorld(sharing: a, deviceName: "sibling device")  // built BEFORE any switch
        defer { b.tearDown() }
        let oldPair = try a.addPreSwitchPair()
        #expect(a.posture == .standard)
        #expect(try StoreKeyEnvelope.load(at: a.oldKeyFileURL)?.apple != nil, "A's library is Standard-shaped")
        arm(a, faultAt: .beforeVaultWrite)
        await #expect(throws: PostureSwitchError.injectedFault(.beforeVaultWrite)) {
            _ = try await a.runner.replaceAllKeys(passphrase: "sesame", recoveryWords: a.words)
        }
        let aMarker = try #require(try await a.marker())
        #expect(aMarker.step == .vaultWrite && !aMarker.entersCastle, "A's own Replace All Keys marker; its write never landed")

        // B's whole switch lands while A is down: the account is Castle now.
        let bDone = try await b.runner.enterCastle(passphrase: "sesame", recoveryWords: b.words)
        let bMaterial = try #require(bDone.material)
        #expect(try await a.vault().format.masterWrappedByAppleHeld == nil, "the vault carries no Apple-held copy")

        // A resumes — its posture read is STILL Standard (the stale shape).
        arm(a, faultAt: nil)
        #expect(a.posture == .standard, "the posture read A's resume starts from")
        let outcome = try await a.runner.resume(passphrase: "sesame")
        #expect(outcome.followedAnotherDevicesSwitch && outcome.otherDeviceName == "sibling device",
                "the road was the FOLLOW into B's switch: \(outcome)")
        #expect(outcome.entersCastle, "the road follows the ACCOUNT into Castle — the vault's word, never the stale read")
        let aFile = try a.keyFile(outcome.newKeyFingerprint)
        let aKey = try aFile.unwrapKey(passphrase: "sesame")
        #expect(StoreEncryptionMigration.opens(a.storeURL, key: aKey) && !StoreEncryptionMigration.opens(a.storeURL, key: a.oldKey))
        #expect(aFile.apple == nil && aFile.appleKeyID == nil,
                "a Castle account's key file carries no Apple copy, whatever the posture read said")
        #expect(try aFile.unwrapKey(master: bMaterial.masterSymmetricKey) == aKey, "L′ under B's M′")
        #expect(a.calls.custodyTargets.last == .biometric && a.posture == .castle, "custody to the gate")
        #expect(!FileManager.default.fileExists(atPath: a.oldKeyFileURL.path),
                "the old Standard-era key file retired from the live folder (the follow's 2d.4 rule)")
        #expect(outcome.preSwitchSnapshots == [oldPair], "A was Standard-shaped: the follow's offer is listed")
        #expect(a.appleBacking.key == a.apple, "the iCloud key untouched")
        #expect(try await a.marker() == nil)
    }

    /// THE CEREMONY (copy §4 whole, `PostureSwitchModel.Mode.replaceKeys`):
    /// the front check refuses a STALE recorded corpus id with the
    /// keys-don't-match sentence and runs nothing; then, on the current
    /// id: explain (the Standard addendum; the *Also choose a new
    /// passphrase* checkbox) → the existing words typed and checked against
    /// the VAULT → the passphrase typed and checked against the VAULT — a
    /// wrong word under a stale recorded descriptor is worded RETIRED (copy
    /// §5) — → the new passphrase (≥ 12, matched) → the rotation over the
    /// runner → the re-wrap on the NEW vault under the NEW proof, the key
    /// file's copy following under the vault's new descriptor → Done, no
    /// offer. Decision 30's PRESENCE: the vault's Apple-held copy of M′
    /// EXISTS after a Standard Replace All Keys (the addendum's fact).
    /// RED ON OLD: no `.replaceKeys` mode existed — the interim door took
    /// the passphrase alone; the front check and the retired wording are
    /// new mechanisms.
    @Test func theReplaceKeysCeremonyWalksCopyFoursOrderRefusesAStaleMasterAndLandsTheNewPassphraseUnderTheNewProof() async throws {
        let world = try await makeWorld()
        defer { world.tearDown() }
        let client = try #require(world.vaultClient)
        let material = try #require(world.oldMaterial)
        try await VaultEnrollment(client: client).landRecoveryWrap(words: world.words, material: material)
        let vaultBefore = try await world.vault()
        let controller = makeController(for: world)

        // The session + the landing (production's shape: `wireOneSecretHooks`
        // routes the session's landing to the controller's `landVaultMaterial`).
        let encryption = EncryptionSession(store: world.keyStore, client: client, signedIn: { true })
        encryption.onVaultMaterialLanded = { landing in
            // The scripted custody leaf never moved the guard backing: the
            // controller must hold L′ (the silent item's key after the
            // switch) for the landing to write the NEW key file.
            world.guardBacking.auto = world.keyInHand
            _ = await controller.landVaultMaterial(landing)
        }
        var vaultChecks: [String] = []
        let tie = VaultTie(
            hasRecoveryWrap: true,
            verifyPassphrase: { typed in
                vaultChecks.append(typed)
                do { _ = try await VaultEnrollment(client: client).enroll(passphrase: typed); return .match }
                catch VaultEnrollmentError.wrongPassphrase { return .mismatch("not the account's") }
                catch { return .couldNotCheck("\(error)") }
            },
            verifyRecoveryWords: { text in
                do { _ = try await VaultEnrollment(client: client).enroll(recoveryWords: EncryptionSession.words(from: text)); return .match }
                catch VaultEnrollmentError.wrongRecoveryPhrase { return .mismatch("not the account's words") }
                catch { return .couldNotCheck("\(error)") }
            },
            changePassphrase: { current, new in
                await encryption.changePassphrase(authorization: .passphrase(current), newPassphrase: new)
                if let refusal = encryption.lastError { throw KeyDoorRefusal(refusal) }
            })

        // THE FRONT CHECK: the key file records a STALE corpus id.
        var file = try #require(try StoreKeyEnvelope.loadCurrent(besideStore: world.storeURL))
        try file.recordVaultReconciliation(kdf: file.passphrase?.kdf, corpusKeyID: "corpus-of-an-older-vault", recoveryWrapDigest: nil)
        try file.write(at: file.preferredURL(besideStore: world.storeURL))
        controller.refreshEnvelopeFacts()
        let stale = PostureSwitchModel(mode: .replaceKeys, runner: world.runner, controller: controller, vaultTie: tie)
        await stale.start()
        #expect(stale.phase == .failed(PostureSwitchModel.message(for: CorpusRotationError.staleMaster(
            vaultKeyID: material.corpusKeyID, heldKeyID: "corpus-of-an-older-vault"))),
                "this account's keys don't match this library — nothing runs")
        let markerAfterStale = try await world.marker()
        let revisionAfterStale = try await world.vault().revision
        #expect(markerAfterStale == nil && revisionAfterStale == vaultBefore.revision)

        // The current id, recorded under a descriptor that is NOT the
        // vault's (the word was changed elsewhere — the retired class).
        try file.recordVaultReconciliation(kdf: fastKDF(), corpusKeyID: material.corpusKeyID, recoveryWrapDigest: nil)
        try file.write(at: file.preferredURL(besideStore: world.storeURL))
        controller.refreshEnvelopeFacts()
        let model = PostureSwitchModel(mode: .replaceKeys, runner: world.runner, controller: controller, vaultTie: tie)
        await model.start()
        #expect(model.phase == .explain)
        #expect(model.accountPostureIsStandard && !model.passphraseHandedIn)
        model.wantsNewPassphrase = true
        model.continueFromExplain()
        #expect(model.phase == .wordsExisting, "the vault carries a wrap ⇒ type mine or generate new")
        model.chooseTypeWords()
        #expect(model.phase == .wordsType)
        await model.submitExistingWords(world.words.reversed().joined(separator: " "))
        #expect(model.lastError != nil && model.phase == .wordsType, "wrong words refused against the vault")
        await model.submitExistingWords(world.words.joined(separator: " "))
        #expect(model.phase == .authorize, "the passphrase is typed at the authorization")

        await model.authorize(passphrase: "not-the-passphrase")
        #expect(model.lastError == ProtectionCopy.retiredPassphraseAtDoor,
                "a wrong word under a stale recorded descriptor is worded RETIRED (copy §5)")
        #expect(vaultChecks == ["not-the-passphrase"] && model.phase == .authorize)
        #expect(try await world.marker() == nil, "nothing ran")
        await model.authorize(passphrase: "sesame")
        #expect(model.phase == .newPassphrase, "the checkbox asks for the new passphrase before the act")
        await model.commitNewPassphrase("short", confirmation: "short")
        #expect(model.lastError == ProtectionCopy.passphraseTooShort && model.phase == .newPassphrase)
        await model.commitNewPassphrase("a-brand-new-passphrase-12", confirmation: "a-brand-new-passphrase-13")
        #expect(model.lastError == ProtectionCopy.passphraseMismatch && model.phase == .newPassphrase)
        await model.commitNewPassphrase("a-brand-new-passphrase-12", confirmation: "a-brand-new-passphrase-12")
        #expect(model.phase == .done(insuranceOff: false, hasOffer: false), "\(model.phase)")
        #expect(!controller.switchInProgress)
        let outcome = try #require(model.outcome)
        #expect(!outcome.entersCastle && outcome.preSwitchSnapshots.isEmpty, "no posture change, no offer")

        // The rotation: M′/C′, every row re-encrypted, the library under L′.
        let vault = try await world.vault()
        let newMaterial = try #require(outcome.material)
        #expect(vault.format.classKey(for: .corpus)?.keyID == newMaterial.corpusKeyID)
        #expect(vault.format.previousCorpusKey == nil && vault.format.rotationStartedSeq == nil)
        #expect(outcome.reencrypted >= 3)
        // DECISION 30 — THE PRESENCE PIN: the Apple-held copy of M′ EXISTS
        // under the SAME A (the addendum's honest sentence, tested).
        #expect(vault.format.masterWrappedByAppleHeld != nil && vault.format.appleKeyID == world.apple.id)
        #expect(try vault.format.unwrapMaster(withAppleKey: world.apple.symmetricKey) == newMaterial.masterSymmetricKey)
        #expect(world.calls.custodyTargets.last == .auto, "custody re-saved silent under Standard")
        #expect(world.posture == .standard)
        // THE NEW PASSPHRASE on the NEW vault under the NEW proof: opens M′; the old is refused.
        let opened = try await VaultEnrollment(client: client).enroll(passphrase: "a-brand-new-passphrase-12")
        #expect(opened.masterKey == newMaterial.masterKey)
        await #expect(throws: VaultEnrollmentError.wrongPassphrase) {
            _ = try await VaultEnrollment(client: client).enroll(passphrase: "sesame")
        }
        // THE KEY FILE followed under the VAULT's new descriptor (§3.6 — derive once).
        let after = try await world.vault()
        #expect(after.format.keyProofHash == KeyProof.macHash(master: newMaterial.masterSymmetricKey), "the proof is M′'s (kp2′'s hash — 13y)")
        let newFile = try world.keyFile(outcome.newKeyFingerprint)
        let newKey = try newFile.unwrapKey(passphrase: "a-brand-new-passphrase-12")
        #expect(StoreEncryptionMigration.opens(world.storeURL, key: newKey), "L′ under the NEW passphrase")
        #expect(throws: StoreKeyEnvelopeError.wrongPassphrase) { _ = try newFile.unwrapKey(passphrase: "sesame") }
        #expect(newFile.passphrase?.kdf == after.format.kdf && newFile.vaultKDF == after.format.kdf,
                "the local copy is under the vault's descriptor — the lobby derives once")
        #expect(newFile.vaultCorpusKeyID == newMaterial.corpusKeyID)
        #expect(newFile.apple != nil && newFile.appleKeyID == world.apple.id, "the Apple copy again under Standard")
        #expect(try newFile.unwrapKey(recoveryWords: world.words) == newKey, "L′ under the same twelve words")
        #expect(try after.format.unwrapMaster(withRecoveryKey: RecoveryPhrase.recoveryWrapKey(words: world.words))
                == newMaterial.masterSymmetricKey)
    }

    // MARK: - pre-13x 3b item 8: THE CROSS-DEVICE DRILLS (the 2b world + a sibling; the doors over production wiring)

    /// The production wiring over the 2b world's controller
    /// (`wireOneSecretHooks`): the session's landings reach the controller,
    /// so the key file follows exactly as it does in the app.
    private func wireSession(for world: World, controller: ProtectionController) throws -> EncryptionSession {
        let client = try #require(world.vaultClient)
        let encryption = EncryptionSession(store: world.keyStore, client: client, signedIn: { true })
        let auth = AuthSession(
            configuration: AuthConfiguration(projectURL: URL(string: "https://auth.2b-drills.invalid")!, apiKey: "k"),
            store: .inMemory(initial: AuthTokens(
                accessToken: "token-2b", refreshToken: "refresh", expiresAt: Date(timeIntervalSinceNow: 86_400),
                userID: "user-2b", email: "drills@test.invalid")),
            http: { _ in throw URLError(.notConnectedToInternet) })
        wireOneSecretHooks(protection: controller, encryption: encryption, keyVault: client, auth: auth)
        return encryption
    }

    private func vaultTie(_ client: KeyVaultClient, hasRecoveryWrap: Bool) -> VaultTie {
        VaultTie(
            hasRecoveryWrap: hasRecoveryWrap,
            verifyPassphrase: { typed in
                do { _ = try await VaultEnrollment(client: client).enroll(passphrase: typed); return .match }
                catch VaultEnrollmentError.wrongPassphrase { return .mismatch("not the account's") }
                catch { return .couldNotCheck("\(error)") }
            },
            verifyRecoveryWords: { text in
                do { _ = try await VaultEnrollment(client: client).enroll(recoveryWords: EncryptionSession.words(from: text)); return .match }
                catch VaultEnrollmentError.wrongRecoveryPhrase { return .mismatch("not the account's words") }
                catch { return .couldNotCheck("\(error)") }
            })
    }

    private func keyDoor(_ kind: KeyDoorModel.Kind, encryption: EncryptionSession, tie: VaultTie) throws -> KeyDoorModel {
        let facts = try #require(encryption.keyDoorFacts, "wired by wireOneSecretHooks")
        return KeyDoorModel(
            kind: kind, encryption: encryption, facts: facts,
            verifyVaultPassphrase: tie.verifyPassphrase, verifyVaultWords: tie.verifyRecoveryWords)
    }

    private func settle(_ door: KeyDoorModel) async throws {
        for _ in 0..<200 {
            switch door.phase {
            case .done, .failed, .closed: return
            default: try await Task.sleep(for: .milliseconds(50))
            }
        }
    }

    private func titles(in world: World) async throws -> [String: String] {
        try await world.view.read { db in
            try Row.fetchAll(db, sql: "SELECT id, title FROM container").reduce(into: [String: String]()) { acc, row in
                let id: String = row["id"]; let title: String? = row["title"]; acc[id] = title
            }
        }
    }

    /// CHANGE PASSPHRASE ACROSS TWO DEVICES (copy §4; §3.6): the acting
    /// device changes the word through the door; at the vault the NEW word
    /// opens the SAME master for the sibling and the OLD refuses; the keys
    /// never changed — the sibling's custody, library and rounds are
    /// untouched, no fence; the acting key file's copy followed under the
    /// vault's new descriptor. pre-13x 4a (drill (i)): the sibling's LOBBY —
    /// the old word offline, the new word online through the vault road
    /// (its local copy re-wrapped), the new word offline, the old refused.
    @Test func changingThePassphraseOnOneDeviceRetiresTheOldWordAtTheVaultForItsSibling() async throws {
        let acting = try await makeWorld()
        defer { acting.tearDown() }
        let sibling = try await makeWorld(sharing: acting)
        defer { sibling.tearDown() }
        let client = try #require(acting.vaultClient)
        let mirror = try #require(acting.mirror)
        let material = try #require(acting.oldMaterial)
        let controller = makeController(for: acting)
        let encryption = try wireSession(for: acting, controller: controller)
        await encryption.refresh()
        #expect(encryption.state == .enrolled(hasRecoveryWrap: false), "\(encryption.state)")
        let door = try keyDoor(.changePassphrase, encryption: encryption, tie: vaultTie(client, hasRecoveryWrap: false))
        await door.start()
        #expect(door.phase == .authorize && door.isEnrolledDoor, "\(door.phase) \(door.lastError ?? "")")
        let new = "a-new-word-for-both-12"
        await door.changePassphrase(current: "not-the-word", new: new, confirmation: new)
        #expect(door.lastError != nil && door.phase == .authorize, "a wrong current word refuses against the vault")
        let revisionBefore = try await acting.vault().revision
        await door.changePassphrase(current: "sesame", new: new, confirmation: new)
        try await settle(door)
        #expect(door.phase == .done, "\(door.phase) \(door.lastError ?? "")")
        let vault = try await acting.vault()
        #expect(vault.revision != revisionBefore)

        // THE SIBLING at the vault: the NEW word opens the SAME master; the OLD refuses.
        let opened = try await VaultEnrollment(client: client).enroll(passphrase: new)
        #expect(opened.masterKey == material.masterKey && opened.corpusKeyID == material.corpusKeyID, "a re-wrap, never a re-key")
        await #expect(throws: VaultEnrollmentError.wrongPassphrase) {
            _ = try await VaultEnrollment(client: client).enroll(passphrase: "sesame")
        }
        // The keys never changed: the sibling's custody, library and rounds untouched — no fence.
        #expect(sibling.keyStore.load()?.corpusKeyID == material.corpusKeyID)
        #expect(StoreEncryptionMigration.opens(sibling.storeURL, key: sibling.oldKey))
        let siblingEngine = SyncEngine(transport: mirror, keyProvider: DeviceKeySyncProvider(store: sibling.keyStore))
        try await withDependencies { $0.database = sibling.view } operation: {
            _ = try await siblingEngine.pull()
            _ = try await siblingEngine.push()
        }
        let seen = try await titles(in: sibling)
        for (id, title) in acting.seededTitles { #expect(seen[id] == title, "the sibling still reads \(id) in the clear") }
        // pre-13x 4a DRILL (i) — THE SIBLING'S LOBBY (3b's recorded gap, closed
        // by the vault road, §3.6): its key file still holds the P copy under
        // the OLD word — the old word opens it OFFLINE (the local copy); the
        // NEW word opens it ONLINE through the vault (the sibling's wrap
        // descriptor ≠ the vault's ⇒ two derivations) and re-wraps the local
        // copy under the vault's descriptor; the new word then opens it
        // OFFLINE (one derivation); the old word is refused everywhere.
        let siblingBefore = try #require(try StoreKeyEnvelope.load(at: sibling.oldKeyFileURL))
        #expect(try siblingBefore.unwrapKey(passphrase: "sesame") == sibling.oldKey)
        #expect(throws: StoreKeyEnvelopeError.wrongPassphrase) { _ = try siblingBefore.unwrapKey(passphrase: new) }
        let lobbySession = SyncCustodySession()
        let derivations = LockIsolated(0)
        let siblingStoreURL = sibling.storeURL
        let siblingGate = sibling.gate
        func open(_ word: String, online: Bool) async -> Result<StoreKey, StoreLobby.Refusal> {
            derivations.setValue(0)
            let road = StoreLobby.envelopeRoad(
                storeURL: siblingStoreURL, gate: siblingGate, session: lobbySession,
                vaultRoad: online ? LobbyVaultRoad(fetch: { try await client.fetchVault()?.format }) : nil,
                derive: { passphrase, descriptor in
                    derivations.withValue { $0 += 1 }
                    return try PassphraseKDF.deriveKey(passphrase: passphrase, descriptor: descriptor)
                })
            return await road(.passphrase(word)) { _ in }
        }
        guard case .success(let byOldOffline) = await open("sesame", online: false) else {
            Issue.record("the OLD word must open the sibling OFFLINE (the local copy)"); return
        }
        #expect(byOldOffline == sibling.oldKey && derivations.value == 1)
        guard case .success(let byNewOnline) = await open(new, online: true) else {
            Issue.record("the NEW word must open the sibling ONLINE (the vault road)"); return
        }
        #expect(byNewOnline == sibling.oldKey, "L through the vault's master and the key file's master-wrapped copy")
        #expect(derivations.value == 2, "the local descriptor, then the vault's — the descriptors differ")
        let siblingAfter = try #require(try StoreKeyEnvelope.load(at: sibling.oldKeyFileURL))
        #expect(siblingAfter.passphrase?.kdf == vault.format.kdf && siblingAfter.vaultKDF == vault.format.kdf,
                "the sibling's local copy re-wrapped under the vault's descriptor by the vault road")
        #expect(try siblingAfter.unwrapKey(passphrase: new) == sibling.oldKey)
        #expect(throws: StoreKeyEnvelopeError.wrongPassphrase) { _ = try siblingAfter.unwrapKey(passphrase: "sesame") }
        #expect(lobbySession.derivedWrappingKDF == vault.format.kdf, "the held key is the vault's derivation")
        guard case .success(let byNewOffline) = await open(new, online: false) else {
            Issue.record("the NEW word must open the sibling OFFLINE now (its local copy is new)"); return
        }
        #expect(byNewOffline == sibling.oldKey && derivations.value == 1, "one derivation — the local copy")
        guard case .failure(let refused) = await open("sesame", online: true) else {
            Issue.record("the OLD word must refuse now"); return
        }
        #expect(refused.message == ProtectionCopy.message(for: StoreKeyEnvelopeError.wrongPassphrase) && !refused.offline)
        // The acting key file followed: L under the NEW word with the VAULT's descriptor (no re-key — the same fingerprint).
        let actingFile = try #require(try StoreKeyEnvelope.load(at: acting.oldKeyFileURL))
        #expect(try actingFile.unwrapKey(passphrase: new) == acting.oldKey)
        #expect(throws: StoreKeyEnvelopeError.wrongPassphrase) { _ = try actingFile.unwrapKey(passphrase: "sesame") }
        #expect(actingFile.passphrase?.kdf == vault.format.kdf && actingFile.vaultKDF == vault.format.kdf,
                "the local copy under the vault's descriptor — the lobby derives once")
    }

    /// REGENERATE ACROSS TWO DEVICES (copy §4): the acting device replaces
    /// the vault's recovery wrap through the door; the NEW words enroll the
    /// sibling and the OLD refuse at the vault; the passphrase wrap is
    /// untouched (independent wraps); no re-key, so the sibling has nothing
    /// to follow; the acting key file's W copy followed the same words.
    @Test func regeneratingTheWordsOnOneDeviceRetiresTheOldWordsAtTheVaultForItsSibling() async throws {
        let acting = try await makeWorld()
        defer { acting.tearDown() }
        let sibling = try await makeWorld(sharing: acting)
        defer { sibling.tearDown() }
        let client = try #require(acting.vaultClient)
        let material = try #require(acting.oldMaterial)
        let oldWords = acting.words
        try await VaultEnrollment(client: client).landRecoveryWrap(words: oldWords, material: material)
        // pre-13x 4a: the sibling's key file reconciled under the vault as it
        // stood — the OLD wrap's digest recorded (the landing sites' record).
        let vaultBefore = try await acting.vault()
        var siblingFile = try #require(try StoreKeyEnvelope.load(at: sibling.oldKeyFileURL))
        try siblingFile.recordVaultReconciliation(
            kdf: vaultBefore.format.kdf, corpusKeyID: material.corpusKeyID, recoveryWrapDigest: vaultBefore.format.recoveryWrapDigest)
        try siblingFile.write(at: sibling.oldKeyFileURL)
        let controller = makeController(for: acting)
        let encryption = try wireSession(for: acting, controller: controller)
        await encryption.refresh()
        let door = try keyDoor(.regenerateWords, encryption: encryption, tie: vaultTie(client, hasRecoveryWrap: true))
        await door.start()
        #expect(door.phase == .authorize, "\(door.phase) \(door.lastError ?? "")")
        await door.authorizeRegenerate(current: "sesame")
        guard case .wordsShow(let fresh) = door.phase else {
            Issue.record("the fresh words are shown once: \(door.phase) \(door.lastError ?? "")")
            return
        }
        #expect(fresh.count == 12 && fresh != oldWords)
        door.acknowledgeWordsWritten()
        door.confirmWords(fresh.joined(separator: " "))
        try await settle(door)
        #expect(door.phase == .done, "\(door.phase) \(door.lastError ?? "")")

        // THE SIBLING at the vault.
        let opened = try await VaultEnrollment(client: client).enroll(recoveryWords: fresh)
        #expect(opened.masterKey == material.masterKey)
        await #expect(throws: VaultEnrollmentError.wrongRecoveryPhrase) {
            _ = try await VaultEnrollment(client: client).enroll(recoveryWords: oldWords)
        }
        let byWord = try await VaultEnrollment(client: client).enroll(passphrase: "sesame")
        #expect(byWord.masterKey == material.masterKey, "the passphrase wrap is untouched — independent wraps")
        #expect(sibling.keyStore.load()?.corpusKeyID == material.corpusKeyID, "no re-key — nothing to follow")
        #expect(try await sibling.vault().format.previousCorpusKey == nil)
        // The acting key file's W copy followed the same words (one secret).
        let actingFile = try #require(try StoreKeyEnvelope.load(at: acting.oldKeyFileURL))
        #expect(try actingFile.unwrapKey(recoveryWords: fresh) == acting.oldKey)
        #expect(throws: (any Error).self) { _ = try actingFile.unwrapKey(recoveryWords: oldWords) }
        // pre-13x 4a: the acting key file recorded the NEW wrap's digest through
        // the phrase-landed hook — it owes itself no notice.
        let vaultAfter = try await acting.vault()
        #expect(actingFile.vaultRecoveryWrapDigest == vaultAfter.format.recoveryWrapDigest
                && vaultAfter.format.recoveryWrapDigest != vaultBefore.format.recoveryWrapDigest)

        // pre-13x 4a DRILL (ii) — THE SIBLING'S NOTICE + DOOR (ledger 53): its
        // key file recorded the vault's OLD wrap digest; at ready the digest
        // differs ⇒ the words-regenerated notice (never a follow); *Enter It
        // Now…* refuses the OLD words and lands the NEW words' local copy
        // with the vault's digest; the notice clears; nothing re-keyed.
        let siblingController = makeController(for: sibling)
        siblingController.switchRunner = sibling.runner
        siblingController.foreignOwner = { _ in false }
        siblingController.readVaultPosture = { [client] in
            guard let fetched = try? await client.fetchVault() else { return nil }
            return VaultPostureReading(
                hasAppleHeldCopy: fetched.format.masterWrappedByAppleHeld != nil,
                appleKeyID: fetched.format.appleKeyID, passphraseKDF: fetched.format.kdf,
                hasPassphraseWrap: true, corpusKeyID: fetched.format.classKey(for: .corpus)?.keyID,
                updatedAt: fetched.updatedAt, updatedByDevice: fetched.format.updatedByDevice,
                signedInUserID: "user-2b", hasRecoveryWrap: fetched.format.masterWrappedByRecovery != nil,
                format: fetched.format, recoveryWrapDigest: fetched.format.recoveryWrapDigest)
        }
        await siblingController.reconcile()
        let regenerated = try #require(siblingController.changeNotice)
        #expect(regenerated.kind == .wordsRegeneratedElsewhere && !siblingController.followPending)
        #expect(siblingController.notice == .changedElsewhere(regenerated))
        siblingController.openChangeNotice()
        let siblingModel = try #require(siblingController.activeFollow)
        siblingModel.chooseWords()
        #expect(siblingModel.phase == .askWords)
        await siblingModel.enter(wordsText: oldWords.joined(separator: " "))
        #expect(siblingModel.lastError == "Those aren't your account's twelve words." && siblingModel.phase == .askWords)
        await siblingModel.enter(wordsText: fresh.joined(separator: " "))
        #expect(siblingModel.phase == .closed, "\(siblingModel.phase) \(siblingModel.lastError ?? "")")
        #expect(siblingController.changeNotice == nil)
        let siblingLanded = try #require(try StoreKeyEnvelope.load(at: sibling.oldKeyFileURL))
        let viaFresh = try siblingLanded.unwrapKey(recoveryWords: fresh)
        #expect(viaFresh == sibling.oldKey, "the NEW words' local copy landed")
        #expect(siblingLanded.vaultRecoveryWrapDigest == vaultAfter.format.recoveryWrapDigest)
        #expect(sibling.calls.rekeys == 0 && sibling.keyStore.load()?.corpusKeyID == material.corpusKeyID, "nothing re-keyed")
        await siblingController.reconcile()
        #expect(siblingController.changeNotice == nil)
    }

    /// REPLACE ALL KEYS THROUGH THE DOOR, THE SIBLING FOLLOWING, A STALE
    /// COPY REFUSED (copy §4; §4 steps 1–4; §12): the acting device walks the
    /// ceremony's door (no new passphrase); a copy of its key file + custody
    /// taken BEFORE the act opens no page of the re-keyed library and its
    /// sync keys are refused at the mirror; the sibling — that stale-custody
    /// device until it follows — is fenced with a pending row, follows by
    /// the passphrase under Standard (no gate; the Apple copy again), pulls
    /// to an identical store, and its pending row reaches the acting device.
    @Test func replaceAllKeysThroughTheDoorIsFollowedByTheSiblingAndAStaleCopyOpensNothing() async throws {
        let acting = try await makeWorld()
        defer { acting.tearDown() }
        let sibling = try await makeWorld(sharing: acting)
        defer { sibling.tearDown() }
        let client = try #require(acting.vaultClient)
        let mirror = try #require(acting.mirror)
        let oldMaterial = try #require(acting.oldMaterial)
        try await VaultEnrollment(client: client).landRecoveryWrap(words: acting.words, material: oldMaterial)
        let siblingEngine = SyncEngine(transport: mirror, keyProvider: DeviceKeySyncProvider(store: sibling.keyStore))
        try await withDependencies { $0.database = sibling.view } operation: {
            _ = try await siblingEngine.push()
            _ = try await siblingEngine.pull()
        }
        // THE STALE COPY: the acting key file + its custody, as a backup made before the act holds them.
        let staleFile = try #require(try StoreKeyEnvelope.load(at: acting.oldKeyFileURL))
        let staleCustody = DeviceKeyStore.inMemory()
        #expect(staleCustody.save(oldMaterial))

        // THE DOOR on the acting device.
        let controller = makeController(for: acting)
        let model = PostureSwitchModel(
            mode: .replaceKeys, runner: acting.runner, controller: controller,
            vaultTie: vaultTie(client, hasRecoveryWrap: true))
        await model.start()
        #expect(model.phase == .explain, "\(model.phase)")
        model.continueFromExplain()
        #expect(model.phase == .wordsExisting)
        model.chooseTypeWords()
        await model.submitExistingWords(acting.words.joined(separator: " "))
        #expect(model.phase == .authorize, "\(model.phase) \(model.lastError ?? "")")
        await model.authorize(passphrase: "sesame")
        #expect(model.phase == .done(insuranceOff: false, hasOffer: false), "\(model.phase) \(model.lastError ?? "")")
        let outcome = try #require(model.outcome)
        let newMaterial = try #require(outcome.material)
        #expect(!outcome.entersCastle && acting.posture == .standard && acting.calls.custodyTargets.last == .auto)
        let newFile = try acting.keyFile(outcome.newKeyFingerprint)
        let newKey = try newFile.unwrapKey(passphrase: "sesame")
        #expect(StoreEncryptionMigration.opens(acting.storeURL, key: newKey) && newFile.apple != nil)

        // THE STALE COPY: its L (through A) opens no page; its sync keys are refused at the mirror.
        let staleKey = try staleFile.unwrapKey(apple: acting.apple.symmetricKey)
        #expect(staleKey == acting.oldKey && !StoreEncryptionMigration.opens(acting.storeURL, key: staleKey),
                "§12: a copy of the key file from before the act + the Apple-held key opens nothing")
        let staleEngine = SyncEngine(transport: mirror, keyProvider: DeviceKeySyncProvider(store: staleCustody))
        await #expect(throws: SyncError.encryptionKeysReplaced, "the stale custody's keys are fenced") {
            try await withDependencies { $0.database = sibling.view } operation: { _ = try await staleEngine.pull() }
        }

        // THE SIBLING: fenced with a pending row; then the follow under Standard.
        try await seedBacklog(sibling, count: 1, tag: "typed-before-following")
        await #expect(throws: SyncError.encryptionKeysReplaced) {
            try await withDependencies { $0.database = sibling.view } operation: { _ = try await siblingEngine.pull() }
        }
        #expect(try await outboxCount(sibling) >= 1)
        let followed = try await sibling.runner.follow(passphrase: "sesame", recoveryWords: nil)
        #expect(!followed.entersCastle, "the account stays Standard")
        let material = try #require(followed.material)
        #expect(material.corpusKeyID == newMaterial.corpusKeyID && sibling.keyStore.load()?.corpusKeyID == newMaterial.corpusKeyID)
        let vault = try await sibling.vault()
        #expect(vault.format.previousCorpusKey == nil && vault.format.rotationStartedSeq == nil)
        #expect(sibling.calls.custodyTargets.last == .auto && sibling.posture == .standard, "no gate under Standard")
        let siblingFile = try sibling.keyFile(followed.newKeyFingerprint)
        let siblingKey = try siblingFile.unwrapKey(passphrase: "sesame")
        #expect(StoreEncryptionMigration.opens(sibling.storeURL, key: siblingKey))
        #expect(!StoreEncryptionMigration.opens(sibling.storeURL, key: sibling.oldKey))
        #expect(siblingFile.apple != nil && siblingFile.appleKeyID == sibling.apple.id, "the Apple copy again under Standard")
        #expect(try siblingFile.unwrapKey(master: material.masterSymmetricKey) == siblingKey)
        // The rounds: the pending row lands; both stores read every note in the clear.
        try await withDependencies { $0.database = sibling.view } operation: {
            _ = try await siblingEngine.pull()
            _ = try await siblingEngine.push()
        }
        #expect(try await outboxCount(sibling) == 0)
        let seen = try await titles(in: sibling)
        for (id, title) in acting.seededTitles { #expect(seen[id] == title, "the follower reads \(id) in the clear") }
        let actingEngine = SyncEngine(transport: mirror, keyProvider: DeviceKeySyncProvider(store: acting.keyStore))
        try await withDependencies { $0.database = acting.view } operation: { _ = try await actingEngine.pull() }
        let landed = try await acting.view.read { db in
            try String.fetchOne(db, sql: "SELECT title FROM container WHERE id = 'typed-before-following-0'")
        }
        #expect(landed == "typed-before-following 0", "the sibling's pending row reached the acting device in the clear")
    }

    // MARK: - pre-13x 2c.1: THE FOLLOW's face over the real runner

    /// §7 end to end on the sibling: the controller's reconcile reads the
    /// vault (the acting device entered Castle) and owes the follow with
    /// *[device] on [day]*; *Later* leaves the un-followed state (the
    /// persistent banner, every key door's sentence, no marker, custody
    /// unchanged); the reopened notice's typed passphrase walks
    /// `runner.follow` — M′ in custody, the library re-keyed, the offer for
    /// the pre-switch pair — and the controller's follow is no longer owed.
    /// RED-ON-OLD: no verdict, no model — the sibling's only road was the
    /// 14c bare re-enroll.
    @Test func theFollowModelWalksTheNoticeToTheActAndLaterLeavesTheUnfollowedState() async throws {
        let acting = try await makeWorld()
        defer { acting.tearDown() }
        let sibling = try await makeWorld(sharing: acting)
        defer { sibling.tearDown() }
        let oldMaterial = try #require(acting.oldMaterial)
        try sibling.addPreSwitchPair()
        _ = try await acting.runner.enterCastle(passphrase: "sesame", recoveryWords: acting.words)
        let vault = try await sibling.vault()
        let newKeyID = try #require(vault.format.classKey(for: .corpus)?.keyID)
        #expect(newKeyID != oldMaterial.corpusKeyID)

        let controller = makeController(for: sibling)
        controller.switchRunner = sibling.runner
        controller.foreignOwner = { _ in false }
        controller.readVaultPosture = { [client = sibling.vaultClient] in
            guard let fetched = try? await client?.fetchVault() else { return nil }
            return VaultPostureReading(
                hasAppleHeldCopy: fetched.format.masterWrappedByAppleHeld != nil,
                appleKeyID: fetched.format.appleKeyID, passphraseKDF: fetched.format.kdf,
                hasPassphraseWrap: true, corpusKeyID: fetched.format.classKey(for: .corpus)?.keyID,
                updatedAt: fetched.updatedAt, updatedByDevice: fetched.format.updatedByDevice,
                signedInUserID: "user-2b", hasRecoveryWrap: true, format: fetched.format)
        }
        await controller.reconcile()
        let owed = try #require(controller.followNotice)
        #expect(owed.kind == .movedToCastle)
        #expect(owed.device == "test device", "decision 34: the acting device's own name rides the notice")
        #expect(controller.notice == .follow(owed))

        // Later: the un-followed state.
        controller.openFollow()
        let first = try #require(controller.activeFollow)
        first.later()
        controller.closeFollow()
        #expect(controller.notice == .followWaiting(owed), "the persistent banner")
        #expect(controller.followPending, "every key door: pick up your new keys first")
        #expect(try await sibling.marker() == nil)
        #expect(sibling.keyStore.load()?.corpusKeyID == oldMaterial.corpusKeyID, "custody unchanged")

        // The banner's Enter…: the typed passphrase walks the follow.
        controller.openFollow()
        let model = try #require(controller.activeFollow)
        model.choosePassphrase()
        #expect(model.phase == .askPassphrase)
        await model.enter(passphrase: "not-the-passphrase")
        #expect(model.lastError == ProtectionCopy.passphraseNotTheLibrarys)
        #expect(model.phase == .askPassphrase, "a wrong word writes nothing and asks again")
        let insuranceWasOn = MarkdownInsurance.isEnabled(in: sibling.defaults)
        await model.enter(passphrase: "sesame")
        #expect(model.phase == .done(insuranceOff: insuranceWasOn, hasOffer: true),
                "Done reports the insurance flip only when the follower had it on")
        #expect(sibling.keyStore.load()?.corpusKeyID == newKeyID, "M′ in custody")
        #expect(sibling.calls.rekeys == 1, "the library re-keyed as it followed")
        #expect(try await sibling.marker() == nil)
        #expect(!controller.followPending, "the follow is no longer owed")
        #expect(controller.notice != .followWaiting(owed) && controller.notice != .follow(owed))
        model.continueFromDone()
        #expect(model.phase == .offer)
        model.keepOldBackups()
        #expect(model.phase == .closed)
    }

    // MARK: - pre-13x 4a: the change notice's door (ledger 33 · 53) + the follow from the held key (ledger 54)

    /// THE CHANGE NOTICE'S DOOR, over the real runner and the emulated vault
    /// (copy §5's first line; §7 steps 2–3): the acting device changes its
    /// passphrase; the sibling — material in hand, its key file recording the
    /// vault's OLD descriptor — learns at ready that the passphrase was
    /// changed elsewhere (never a follow: `followPending` false, sync keeps
    /// running); *Enter It Now…* — a wrong word refuses in the ACCOUNT's
    /// words; the NEW word lands the sibling's local copy under the vault's
    /// descriptor; the notice clears; nothing is re-keyed. The dismissal is
    /// per open (the lock road's reset brings it back).
    @Test func theSiblingLearnsThePassphraseChangeAtReadyAndEnterItNowLandsTheNewWord() async throws {
        let acting = try await makeWorld()
        defer { acting.tearDown() }
        let sibling = try await makeWorld(sharing: acting)
        defer { sibling.tearDown() }
        let client = try #require(acting.vaultClient)
        let material = try #require(acting.oldMaterial)
        let before = try await acting.vault()
        // The sibling's key file reconciled under the vault as it stood (the
        // landing's record — 3a/3b's sites), so a change elsewhere is visible.
        var siblingFile = try #require(try StoreKeyEnvelope.load(at: sibling.oldKeyFileURL))
        try siblingFile.recordVaultReconciliation(
            kdf: before.format.kdf, corpusKeyID: material.corpusKeyID, recoveryWrapDigest: before.format.recoveryWrapDigest)
        try siblingFile.write(at: sibling.oldKeyFileURL)
        // The acting device changes the word (the core act the door runs).
        let new = "a-new-word-for-both-12"
        _ = try await VaultEnrollment(client: client).changePassphrase(authorizedBy: .passphrase("sesame"), newPassphrase: new)
        let vault = try await acting.vault()
        #expect(vault.format.kdf != before.format.kdf)

        let controller = makeController(for: sibling)
        controller.switchRunner = sibling.runner
        controller.foreignOwner = { _ in false }
        controller.readVaultPosture = { [client] in
            guard let fetched = try? await client.fetchVault() else { return nil }
            return VaultPostureReading(
                hasAppleHeldCopy: fetched.format.masterWrappedByAppleHeld != nil,
                appleKeyID: fetched.format.appleKeyID, passphraseKDF: fetched.format.kdf,
                hasPassphraseWrap: true, corpusKeyID: fetched.format.classKey(for: .corpus)?.keyID,
                updatedAt: fetched.updatedAt, updatedByDevice: fetched.format.updatedByDevice,
                signedInUserID: "user-2b", hasRecoveryWrap: fetched.format.masterWrappedByRecovery != nil,
                format: fetched.format, recoveryWrapDigest: fetched.format.recoveryWrapDigest)
        }
        await controller.reconcile()
        let change = try #require(controller.changeNotice)
        #expect(change.kind == .passphraseChangedElsewhere)
        #expect(change.device == "test device", "decision 34: the acting device's own name")
        #expect(controller.notice == .changedElsewhere(change))
        #expect(!controller.followPending && controller.followNotice == nil, "a convenience change: sync keeps running")
        controller.dismissChangeNotice()
        #expect(controller.notice != .changedElsewhere(change))
        controller.resetPerOpenDeferrals()
        controller.refreshNotices()
        #expect(controller.notice == .changedElsewhere(change), "the dismissal is per open")

        // The door.
        controller.openChangeNotice()
        let model = try #require(controller.activeFollow)
        #expect(model.isChangeNoticeVariant && !model.canFollowFromHeldKey)
        model.choosePassphrase()
        #expect(model.phase == .askPassphrase)
        await model.enter(passphrase: "not the new word")
        #expect(model.lastError == EncryptionSession.message(for: VaultEnrollmentError.wrongPassphrase), "\(model.lastError ?? "nil")")
        #expect(model.phase == .askPassphrase && controller.changeNotice != nil, "a wrong word refuses in place")
        let rekeysBefore = sibling.calls.rekeys
        await model.enter(passphrase: new)
        #expect(model.phase == .closed, "\(model.phase) \(model.lastError ?? "")")
        #expect(controller.changeNotice == nil && controller.notice != .changedElsewhere(change))
        let landed = try #require(try StoreKeyEnvelope.load(at: sibling.oldKeyFileURL))
        #expect(landed.passphrase?.kdf == vault.format.kdf && landed.vaultKDF == vault.format.kdf,
                "the sibling's local copy under the vault's descriptor")
        #expect(try landed.unwrapKey(passphrase: new) == sibling.oldKey)
        #expect(throws: StoreKeyEnvelopeError.wrongPassphrase) { _ = try landed.unwrapKey(passphrase: "sesame") }
        #expect(sibling.calls.rekeys == rekeysBefore, "nothing re-keyed — a re-wrap")
        #expect(sibling.keyStore.load()?.corpusKeyID == material.corpusKeyID, "custody unchanged")
        await controller.reconcile()
        #expect(controller.changeNotice == nil, "the record agrees with the vault")
    }

    /// THE FOLLOW FROM THE WORD JUST TYPED (ledger 54; §7 step 1): the
    /// sibling opened its lobby by the passphrase, whose derived key sits in
    /// the session under the VAULT's descriptor; at ready the follow is owed
    /// (Castle entered elsewhere); *Enter Passphrase…* asks NOTHING — the
    /// follow runs from the held key: M′ at the vault, the library re-keyed,
    /// the new key file's P copy under that same derived key with the
    /// vault's descriptor (the typed word opens it; no W copy). A device
    /// that opened by Touch ID (no held key) is asked; a stale held key (a
    /// descriptor that is not the vault's) is asked; a held key under the
    /// vault's descriptor that does NOT open its master copy (the word was
    /// changed elsewhere too) falls to the field with nothing re-keyed.
    @Test func theFollowRunsFromTheWordJustTypedAtTheLobbyAndAsksWithoutAHeldKeyOrUnderAStaleOne() async throws {
        let acting = try await makeWorld()
        defer { acting.tearDown() }
        let sibling = try await makeWorld(sharing: acting)
        defer { sibling.tearDown() }
        // The second sibling is made BEFORE the switch (its seed push rides
        // the old keys; after the switch the fence would refuse it).
        let siblingTwo = try await makeWorld(sharing: acting)
        defer { siblingTwo.tearDown() }
        let client = try #require(acting.vaultClient)
        let oldMaterial = try #require(acting.oldMaterial)
        _ = try await acting.runner.enterCastle(passphrase: "sesame", recoveryWords: acting.words)
        let vault = try await sibling.vault()
        let newKeyID = try #require(vault.format.classKey(for: .corpus)?.keyID)
        let vaultReading = VaultPostureReading(
            hasAppleHeldCopy: vault.format.masterWrappedByAppleHeld != nil,
            appleKeyID: vault.format.appleKeyID, passphraseKDF: vault.format.kdf,
            hasPassphraseWrap: true, corpusKeyID: newKeyID,
            updatedAt: vault.updatedAt, updatedByDevice: vault.format.updatedByDevice,
            signedInUserID: "user-2b", hasRecoveryWrap: true, format: vault.format,
            recoveryWrapDigest: vault.format.recoveryWrapDigest)
        func controller(for world: World, session: SyncCustodySession) -> ProtectionController {
            let syncLeaves = RecordingSyncLeaves(
                plain: SyncCustodyRecord(deviceID: "device-2b", material: world.oldMaterial))
            let controller = ProtectionController(configuration: .init(
                scope: "Variorum2b", storeURL: world.storeURL, gate: world.gate,
                isRealVariant: true, makeKDF: { self.fastKDF() },
                storeID: { (try? StoreKeyEnvelope.loadCurrent(besideStore: world.storeURL))?.storeID },
                syncCustodyLeaves: { _ in syncLeaves.leaves },
                syncCustodySession: session))
            controller.refreshEnvelopeFacts()
            controller.switchRunner = world.runner
            controller.foreignOwner = { _ in false }
            controller.readVaultPosture = { [vaultReading] in vaultReading }
            return controller
        }

        // (1) The held key under the VAULT's descriptor: the follow runs with no field.
        let held = SyncCustodySession()
        held.holdDerivedWrappingKey(
            try PassphraseKDF.deriveKey(passphrase: "sesame", descriptor: vault.format.kdf), kdf: vault.format.kdf)
        let one = controller(for: sibling, session: held)
        await one.reconcile()
        let owed = try #require(one.followNotice)
        #expect(owed.kind == .movedToCastle && owed.vaultKDF == vault.format.kdf)
        one.openFollow()
        let model = try #require(one.activeFollow)
        #expect(model.canFollowFromHeldKey, "the word typed at the lobby is reused — never asked twice")
        // THE DOOR (copy §5's *Enter Passphrase…*): it asks nothing — the
        // follow runs from the held key.
        model.choosePassphrase()
        #expect(model.phase != .askPassphrase, "no field")
        for _ in 0..<600 {
            if case .done = model.phase { break }
            if case .failed = model.phase { break }
            if model.phase == .askPassphrase { break }
            try await Task.sleep(for: .milliseconds(50))
        }
        guard case .done = model.phase else { Issue.record("expected .done, got \(model.phase) \(model.lastError ?? "")"); return }
        #expect(sibling.keyStore.load()?.corpusKeyID == newKeyID, "M′ in custody")
        #expect(sibling.calls.rekeys == 1, "the library re-keyed as it followed")
        #expect(!one.followPending)
        let outcome = try #require(model.outcome)
        let newFile = try sibling.keyFile(outcome.newKeyFingerprint)
        #expect(newFile.passphrase?.kdf == vault.format.kdf, "the P copy under the held key's descriptor — the vault's")
        #expect(newFile.vaultKDF == vault.format.kdf && newFile.vaultCorpusKeyID == newKeyID)
        #expect(try newFile.unwrapKey(passphrase: "sesame") == sibling.keyInHand, "the typed word opens the new key file")
        #expect(newFile.recovery == nil, "the W copy lands when the words are next typed")
        #expect(newFile.apple == nil)

        // (2) A Touch ID / Face ID open held no derived key: the field asks.
        let two = controller(for: siblingTwo, session: SyncCustodySession())
        await two.reconcile()
        #expect(two.followNotice?.kind == .movedToCastle)
        two.openFollow()
        let modelTwo = try #require(two.activeFollow)
        #expect(!modelTwo.canFollowFromHeldKey)
        modelTwo.choosePassphrase()
        #expect(modelTwo.phase == .askPassphrase, "no held key — asked as before")
        #expect(siblingTwo.calls.rekeys == 0)

        // (3) A STALE held key (its descriptor is not the vault's): the field asks.
        let stale = SyncCustodySession()
        stale.holdDerivedWrappingKey(try PassphraseKDF.deriveKey(passphrase: "sesame", descriptor: fastKDF()), kdf: fastKDF())
        let three = controller(for: siblingTwo, session: stale)
        await three.reconcile()
        three.openFollow()
        let modelThree = try #require(three.activeFollow)
        #expect(!modelThree.canFollowFromHeldKey)
        modelThree.choosePassphrase()
        #expect(modelThree.phase == .askPassphrase)

        // (4) The vault's descriptor but the WRONG word (a key that opens the
        //     local copy of a word since changed): the vault refuses ⇒ the
        //     field asks; nothing re-keyed, custody unchanged.
        let wrong = SyncCustodySession()
        wrong.holdDerivedWrappingKey(
            try PassphraseKDF.deriveKey(passphrase: "not sesame", descriptor: vault.format.kdf), kdf: vault.format.kdf)
        let four = controller(for: siblingTwo, session: wrong)
        await four.reconcile()
        four.openFollow()
        let modelFour = try #require(four.activeFollow)
        #expect(modelFour.canFollowFromHeldKey, "the descriptor matches — the road is tried")
        await modelFour.followFromHeldKey()
        #expect(modelFour.phase == .askPassphrase, "the vault refused the held key — the field asks")
        #expect(siblingTwo.calls.rekeys == 0 && siblingTwo.keyStore.load()?.corpusKeyID == oldMaterial.corpusKeyID)
        #expect(try await siblingTwo.marker() == nil)
        _ = client
    }

    /// 17l ITEM 5 (RUN B batch B3; KnownIssues row 37 — her find at the
    /// pre-13x acceptance walk, 2026-09-07 08:19Z: her phone typed the
    /// word to unlock and was asked the SAME word again at the follow): a
    /// sibling that opened its lobby by the passphrase — the derived key
    /// held under the PRE-rotation vault descriptor — follows a Replace
    /// All Keys that KEPT the word with ZERO prompts, because the rotation
    /// re-wrapped under the EXISTING descriptor
    /// (`RotationSecrets.derive(forRotationOf:)` through the runner's
    /// ceremony), so the held key still equals the vault's and ledger 54's
    /// no-second-entry road runs end to end ACROSS the rotation. RED
    /// TODAY (pre-fix): the rotation minted a fresh salt, the descriptor
    /// differed, and the field asked — her double ask. The second act: a
    /// rotation that CHANGES the word — the held key is then honestly
    /// stale and the field asks (the reuse never leaks into the changed
    /// case, at the door).
    @Test func theSiblingThatOpenedByThePassphraseFollowsAReplaceAllKeysWithZeroPrompts() async throws {
        let acting = try await makeWorld()
        defer { acting.tearDown() }
        let sibling = try await makeWorld(sharing: acting)
        defer { sibling.tearDown() }
        let oldMaterial = try #require(sibling.oldMaterial)
        let before = try await sibling.vault()
        // The lobby's state: the key derived when the word was typed to
        // unlock — BEFORE the acting device's rotation.
        let heldKey = try PassphraseKDF.deriveKey(passphrase: "sesame", descriptor: before.format.kdf)

        // The acting device replaces all keys, KEEPING the word.
        _ = try await acting.runner.replaceAllKeys(passphrase: "sesame", recoveryWords: acting.words)
        let after = try await sibling.vault()
        let newKeyID = try #require(after.format.classKey(for: .corpus)?.keyID)
        #expect(newKeyID != oldMaterial.corpusKeyID, "a genuine rotation")
        #expect(after.format.kdf == before.format.kdf,
                "the unchanged word re-wrapped under the vault's EXISTING descriptor — 17l item 5's letter")

        let held = SyncCustodySession()
        held.holdDerivedWrappingKey(heldKey, kdf: before.format.kdf)
        let one = controller(for: sibling, material: oldMaterial, session: held)
        await one.reconcile()
        let owed = try #require(one.followNotice)
        #expect(owed.vaultKDF == before.format.kdf, "the notice carries the SAME descriptor the lobby derived under")
        one.openFollow()
        let model = try #require(one.activeFollow)
        #expect(model.canFollowFromHeldKey,
                "the word typed at the lobby follows a Replace All Keys — never asked twice, ACROSS the rotation")
        model.choosePassphrase()
        #expect(model.phase != .askPassphrase, "zero prompts — the door asks nothing")
        for _ in 0..<600 {
            if case .done = model.phase { break }
            if case .failed = model.phase { break }
            if model.phase == .askPassphrase { break }
            try await Task.sleep(for: .milliseconds(50))
        }
        guard case .done = model.phase else { Issue.record("expected .done, got \(model.phase) \(model.lastError ?? "")"); return }
        #expect(sibling.keyStore.load()?.corpusKeyID == newKeyID, "M′ in custody — the follow ran whole")
        #expect(sibling.calls.rekeys == 1, "the library re-keyed as it followed")
        #expect(!one.followPending)
        let outcome = try #require(model.outcome)
        let newFile = try sibling.keyFile(outcome.newKeyFingerprint)
        #expect(newFile.passphrase?.kdf == before.format.kdf, "the P copy under the held key's descriptor — reused")
        #expect(try newFile.unwrapKey(passphrase: "sesame") == sibling.keyInHand, "the typed word opens the new key file")

        // The CHANGED word: the reuse never leaks — the field honestly asks.
        _ = try await acting.runner.replaceAllKeys(passphrase: "a-genuinely-new-word", recoveryWords: acting.words)
        let final = try await sibling.vault()
        #expect(final.format.kdf != before.format.kdf, "a changed word minted a fresh salt")
        let stillHeld = SyncCustodySession()
        stillHeld.holdDerivedWrappingKey(heldKey, kdf: before.format.kdf)
        let two = controller(for: sibling, material: oldMaterial, session: stillHeld)
        await two.reconcile()
        #expect(two.followNotice != nil)
        two.openFollow()
        let modelTwo = try #require(two.activeFollow)
        #expect(!modelTwo.canFollowFromHeldKey, "the word changed — the held key is honestly stale")
        modelTwo.choosePassphrase()
        #expect(modelTwo.phase == .askPassphrase, "the field asks, as it must")
    }

    // MARK: - pre-13x 4b: helpers shared by the choreography, the un-followed device, the doors and the posture pins

    /// A sibling's controller composed the app's way: the plain custody
    /// record (nil material = no keys in hand — Always ask), the session
    /// (the lobby's hold), the runner, the exact-owner read answering
    /// "mine", the vault's reading over the SHARED client.
    private func controller(for world: World, material: DeviceKeyMaterial?, session: SyncCustodySession = SyncCustodySession()) -> ProtectionController {
        let syncLeaves = RecordingSyncLeaves(plain: SyncCustodyRecord(deviceID: "device-2b", material: material))
        let controller = ProtectionController(configuration: .init(
            scope: "Variorum2b", storeURL: world.storeURL, gate: world.gate,
            isRealVariant: true, makeKDF: { self.fastKDF() },
            storeID: { (try? StoreKeyEnvelope.loadCurrent(besideStore: world.storeURL))?.storeID },
            syncCustodyLeaves: { _ in syncLeaves.leaves },
            syncCustodySession: session))
        controller.refreshEnvelopeFacts()
        controller.switchRunner = world.runner
        controller.foreignOwner = { _ in false }
        wireVaultReading(controller, client: world.vaultClient)
        return controller
    }

    /// The vault's reading as `wireOneSecretHooks.readVaultPosture` fills it.
    private func wireVaultReading(_ controller: ProtectionController, client: KeyVaultClient?) {
        controller.readVaultPosture = { [client] in
            guard let client, let fetched = try? await client.fetchVault() else { return nil }
            return VaultPostureReading(
                hasAppleHeldCopy: fetched.format.masterWrappedByAppleHeld != nil,
                appleKeyID: fetched.format.appleKeyID, passphraseKDF: fetched.format.kdf,
                hasPassphraseWrap: true, corpusKeyID: fetched.format.classKey(for: .corpus)?.keyID,
                updatedAt: fetched.updatedAt, updatedByDevice: fetched.format.updatedByDevice,
                signedInUserID: "user-2b", hasRecoveryWrap: fetched.format.masterWrappedByRecovery != nil,
                format: fetched.format, recoveryWrapDigest: fetched.format.recoveryWrapDigest)
        }
    }

    /// A signed-in auth over an in-memory store whose network is down —
    /// the 3b doors' shape (sign-out clears locally whatever the logout answers).
    private func makeAuth() -> AuthSession {
        AuthSession(
            configuration: AuthConfiguration(projectURL: URL(string: "https://auth.2b-4b.invalid")!, apiKey: "k"),
            store: .inMemory(initial: AuthTokens(
                accessToken: "token-2b", refreshToken: "refresh", expiresAt: Date(timeIntervalSinceNow: 86_400),
                userID: "user-2b", email: "4b@test.invalid")),
            http: { _ in throw URLError(.notConnectedToInternet) })
    }

    /// The lobby's secret road over a world (4a's composition, drill (i)):
    /// `online` = the vault road over the shared client; the derivation
    /// count and the held key ride `session`.
    private func lobbyOpen(_ world: World, _ word: String, online: Bool, session: SyncCustodySession, derivations: LockIsolated<Int>) async -> Result<StoreKey, StoreLobby.Refusal> {
        derivations.setValue(0)
        let client = world.vaultClient
        let road = StoreLobby.envelopeRoad(
            storeURL: world.storeURL, gate: world.gate, session: session,
            vaultRoad: online ? LobbyVaultRoad(fetch: { try await client?.fetchVault()?.format }) : nil,
            derive: { passphrase, descriptor in
                derivations.withValue { $0 += 1 }
                return try PassphraseKDF.deriveKey(passphrase: passphrase, descriptor: descriptor)
            })
        return await road(.passphrase(word)) { _ in }
    }

    private func opened(_ result: Result<StoreKey, StoreLobby.Refusal>) -> StoreKey? {
        if case .success(let key) = result { return key }
        return nil
    }

    /// A sibling's key file reconciled against the vault as it stands —
    /// the landing sites' record (3a/3b), so a change elsewhere is visible.
    private func reconcileKeyFile(of world: World, to vault: KeyVaultClient.FetchedVault, corpusKeyID: String, passphraseUnderVaultKDF: String? = nil) throws {
        var file = try #require(try StoreKeyEnvelope.load(at: world.oldKeyFileURL))
        if let word = passphraseUnderVaultKDF {
            try file.setPassphraseWrap(key: world.oldKey, passphrase: word, kdf: vault.format.kdf)
        }
        try file.recordVaultReconciliation(kdf: vault.format.kdf, corpusKeyID: corpusKeyID, recoveryWrapDigest: vault.format.recoveryWrapDigest)
        try file.write(at: world.oldKeyFileURL)
    }

    // MARK: - pre-13x 4b.2: §7's PASSPHRASE-CHANGE CHOREOGRAPHY, steps 1–7 (both Castle)

    /// §7 STEPS 1–4 AND 6 over three Castle devices on one account. (1) The
    /// Mac re-wraps through the production door — the vault + its OWN key
    /// file; the phone is untouched and keeps syncing (a re-wrap rotates
    /// nothing — no fence, no proof refusal). (2) The phone's next open by
    /// Face ID: the post-unlock reconcile speaks the ONE-TIME notice (4a's
    /// kind) — nothing prompted, nothing deleted. (4) OFFLINE the OLD word
    /// opens the phone (its local copy). (3) ONLINE the OLD word still opens
    /// locally; the NEW word opens through the vault road and re-wraps the
    /// local copy — from then on only the new word. (6) The ALWAYS-ASK phone
    /// (decision 10's exception), opened with the OLD word: it reads and
    /// edits and does NOT sync until the new word is typed there — the
    /// banner names it; *Enter It Now…* with the new word picks the keys up
    /// and sync runs. Steps 5 and 7 are the two pins below.
    @Test func thePassphraseChangeChoreographyStepsOneToFourAndSix() async throws {
        let mac = try await makeWorld(standard: false)
        defer { mac.tearDown() }
        let phone = try await makeWorld(standard: false, sharing: mac)
        defer { phone.tearDown() }
        let alwaysAsk = try await makeWorld(standard: false, sharing: mac)
        defer { alwaysAsk.tearDown() }
        let client = try #require(mac.vaultClient)
        let mirror = try #require(mac.mirror)
        let material = try #require(mac.oldMaterial)
        let before = try await mac.vault()
        // Both phones' key files reconciled against the vault as it stood; the
        // Always-ask phone's P copy under the VAULT's descriptor (the reconciled
        // steady state — the lobby derives once, §3.6).
        try reconcileKeyFile(of: phone, to: before, corpusKeyID: material.corpusKeyID)
        try reconcileKeyFile(of: alwaysAsk, to: before, corpusKeyID: material.corpusKeyID, passphraseUnderVaultKDF: "sesame")
        let phoneBytesBefore = try Data(contentsOf: phone.oldKeyFileURL)
        let phoneEngine = SyncEngine(transport: mirror, keyProvider: DeviceKeySyncProvider(store: phone.keyStore))
        try await withDependencies { $0.database = phone.view } operation: {
            _ = try await phoneEngine.push(); _ = try await phoneEngine.pull()
        }

        // ————— (1) THE MAC RE-WRAPS — the vault + its own key file; the phone untouched, still syncing —————
        let macController = makeController(for: mac)
        macController.adoptResident(mac.oldKey)
        let macSession = try wireSession(for: mac, controller: macController)
        await macSession.refresh()
        #expect(macSession.state == .enrolled(hasRecoveryWrap: false), "\(macSession.state)")
        let door = try keyDoor(.changePassphrase, encryption: macSession, tie: vaultTie(client, hasRecoveryWrap: false))
        await door.start()
        #expect(door.phase == .authorize, "\(door.phase) \(door.lastError ?? "")")
        let new = "the-new-word-for-both-12"
        await door.changePassphrase(current: "sesame", new: new, confirmation: new)
        try await settle(door)
        #expect(door.phase == .done, "\(door.phase) \(door.lastError ?? "")")
        let vault = try await mac.vault()
        #expect(vault.revision == before.revision + 1 && vault.format.kdf != before.format.kdf, "ONE CAS write under the proof")
        #expect(vault.format.classKey(for: .corpus)?.keyID == material.corpusKeyID, "a re-wrap rotates NOTHING")
        let macFile = try #require(try StoreKeyEnvelope.load(at: mac.oldKeyFileURL))
        #expect(try macFile.unwrapKey(passphrase: new) == mac.oldKey && macFile.passphrase?.kdf == vault.format.kdf && macFile.vaultKDF == vault.format.kdf,
                "step 1: the Mac's OWN key file re-wrapped under the vault's new descriptor")
        #expect(try Data(contentsOf: phone.oldKeyFileURL) == phoneBytesBefore, "step 1: the phone's key file untouched")
        #expect(phone.keyStore.load() == material, "step 1: the phone's custody untouched")
        try await seedBacklog(phone, count: 1, tag: "phone-after-the-change")
        try await withDependencies { $0.database = phone.view } operation: {
            let pushed = try await phoneEngine.push()
            #expect(pushed.accepted >= 1, "step 1: the phone keeps syncing — no fence, no proof refusal")
            _ = try await phoneEngine.pull()
        }

        // ————— (2) THE PHONE's next open by Face ID: the one-time notice; nothing prompted, nothing deleted —————
        let phoneController = controller(for: phone, material: material)
        phoneController.adoptResident(phone.oldKey)
        await phoneController.reconcile()
        let notice = try #require(phoneController.changeNotice)
        #expect(notice.kind == .passphraseChangedElsewhere && notice.device == "test device", "step 2: 4a's kind — [device] on [day]")
        #expect(phoneController.notice == .changedElsewhere(notice) && !phoneController.followPending && phoneController.followNotice == nil,
                "step 2: a banner, never a follow — sync keeps running")
        #expect(phoneController.activeFollow == nil, "step 2: nothing prompted")
        #expect(try Data(contentsOf: phone.oldKeyFileURL) == phoneBytesBefore, "step 2: nothing deleted, nothing rewritten")
        #expect(StoreKeyEnvelope.keyFileURLs(besideStore: phone.storeURL).count == 1)

        // ————— (4) OFFLINE: the OLD word (the local copy) —————
        let lobbySession = SyncCustodySession()
        let derivations = LockIsolated(0)
        #expect(opened(await lobbyOpen(phone, "sesame", online: false, session: lobbySession, derivations: derivations)) == phone.oldKey,
                "step 4: offline, the old word opens the phone from its local copy")
        #expect(derivations.value == 1)
        #expect(opened(await lobbyOpen(phone, new, online: false, session: lobbySession, derivations: derivations)) == nil,
                "step 4: offline, the new word cannot open it yet — the local copy is under the old word")

        // ————— (3) ONLINE: the OLD word still opens (locally); the NEW word opens via the vault road and re-wraps; from then on only the new word —————
        #expect(opened(await lobbyOpen(phone, "sesame", online: true, session: lobbySession, derivations: derivations)) == phone.oldKey,
                "step 3: the old word opens until the new one has been used here")
        #expect(derivations.value == 1, "the local copy — the vault never awaited")
        #expect(opened(await lobbyOpen(phone, new, online: true, session: lobbySession, derivations: derivations)) == phone.oldKey,
                "step 3: the NEW word opens through the vault's master and the key file's master-wrapped copy")
        #expect(derivations.value == 2, "the local descriptor, then the vault's")
        let phoneAfter = try #require(try StoreKeyEnvelope.load(at: phone.oldKeyFileURL))
        #expect(phoneAfter.passphrase?.kdf == vault.format.kdf && phoneAfter.vaultKDF == vault.format.kdf,
                "step 3: the local copy re-wrapped under the vault's descriptor")
        #expect(opened(await lobbyOpen(phone, "sesame", online: true, session: lobbySession, derivations: derivations)) == nil,
                "step 3: from then on only the new word")
        #expect(opened(await lobbyOpen(phone, new, online: false, session: lobbySession, derivations: derivations)) == phone.oldKey && derivations.value == 1,
                "…and the new word is now LOCAL — one derivation, offline")
        phoneController.refreshEnvelopeFacts()
        await phoneController.reconcile()
        #expect(phoneController.changeNotice == nil, "the record agrees with the vault — the banner is gone")

        // ————— (6) THE ALWAYS-ASK PHONE: opened with the OLD word it reads and edits, and does NOT sync until the new word is typed there —————
        alwaysAsk.keyStore.clear()  // Always ask: no custody item — the sync keys live in the SESSION, filled from the typed word
        alwaysAsk.alwaysAsk = true
        let alwaysAskFile = try #require(try StoreKeyEnvelope.load(at: alwaysAsk.oldKeyFileURL))
        let oldWrapKDF = try #require(alwaysAskFile.passphrase?.kdf)
        #expect(oldWrapKDF == before.format.kdf && oldWrapKDF != vault.format.kdf, "its local copy is under the RETIRED word's descriptor")
        // The lobby by the OLD word: the local copy opens; the derived key held for the session under the OLD descriptor.
        let held = SyncCustodySession()
        #expect(opened(await lobbyOpen(alwaysAsk, "sesame", online: true, session: held, derivations: derivations)) == alwaysAsk.oldKey,
                "step 6: the old word opens the Always-ask phone")
        #expect(held.derivedWrappingKDF == oldWrapKDF)
        let askController = controller(for: alwaysAsk, material: nil, session: held)
        askController.adoptResident(alwaysAsk.oldKey)
        await askController.reconcile()
        let retired = try #require(askController.alwaysAskRetiredNotice)
        #expect(retired.kind == .alwaysAskRetiredWord && askController.notice == .alwaysAskRetiredWord(retired),
                "step 6: the banner — the old one still opens this device, but sync waits")
        #expect(held.record == nil && alwaysAsk.keyStore.load() == nil, "no sync keys in hand")
        // Reads and edits… (its OWN notes — it holds no keys, so nothing of
        // the Mac's has reached it since the change).
        let seen = try await titles(in: alwaysAsk)
        for (id, title) in alwaysAsk.seededTitles { #expect(seen[id] == title, "step 6: reads \(id)") }
        try await seedBacklog(alwaysAsk, count: 1, tag: "typed-on-always-ask")
        // …and does NOT sync.
        let askEngine = SyncEngine(transport: mirror, keyProvider: DeviceKeySyncProvider(store: alwaysAsk.keyStore))
        await #expect(throws: SyncError.encryptionKeysUnavailable, "step 6: no sync until the new word is typed here") {
            try await withDependencies { $0.database = alwaysAsk.view } operation: { _ = try await askEngine.push() }
        }
        // Enter It Now… with the NEW word: the vault's pickup — the keys held, the local copy re-wrapped, sync runs.
        askController.openFollow()
        let pickup = try #require(askController.activeFollow)
        #expect(pickup.isAlwaysAskVariant)
        pickup.choosePassphrase()
        await pickup.enter(passphrase: "sesame")
        #expect(pickup.lastError == ProtectionCopy.passphraseNotTheLibrarys && pickup.phase == .askPassphrase, "the OLD word is refused at the vault")
        await pickup.enter(passphrase: new)
        #expect(pickup.phase == .done(insuranceOff: false, hasOffer: false), "\(pickup.phase) \(pickup.lastError ?? "")")
        #expect(alwaysAsk.keyStore.load()?.corpusKeyID == material.corpusKeyID, "the keys picked up (held for the session)")
        #expect(askController.alwaysAskRetiredNotice == nil)
        let askAfter = try #require(try StoreKeyEnvelope.load(at: alwaysAsk.oldKeyFileURL))
        let askAfterKey = try askAfter.unwrapKey(passphrase: new)
        #expect(askAfter.passphrase?.kdf == vault.format.kdf && askAfterKey == alwaysAsk.oldKey, "the local copy re-wrapped under the new word")
        try await withDependencies { $0.database = alwaysAsk.view } operation: {
            let pushed = try await askEngine.push()
            #expect(pushed.accepted >= 1, "step 6: sync runs once the new word was typed here")
        }
        #expect(alwaysAsk.calls.rekeys == 0 && phone.calls.rekeys == 0 && mac.calls.rekeys == 0, "a re-wrap re-keys nothing anywhere")
    }

    /// §7 STEP 5 — BOTH DEVICES CHANGE THE PASSPHRASE AT ONCE (decision 9;
    /// corner 18): device 1's change lands INSIDE device 2's write (the
    /// emulated vault's one-shot hook — deterministic); the vault's CAS
    /// refuses device 2 with NOTHING overwritten (its door says so); device
    /// 2 RE-READS — its retry with the word it typed a moment ago is worded
    /// RETIRED (the door re-fetched the vault's descriptor on the refusal —
    /// 4b's one-line mechanism) — and retries by the road that needs no
    /// current word (Touch ID: the held material): it lands ON TOP — the
    /// last change wins; device 1 learns at its next open (the notice; the
    /// vault road at its lobby). RED-ON-OLD: without the re-read the retry
    /// is worded as a plain wrong word.
    @Test func bothDevicesChangeThePassphraseAtOnceTheCASRefusesTheSecondAndTheLastChangeWins() async throws {
        let one = try await makeWorld(standard: false)
        defer { one.tearDown() }
        let two = try await makeWorld(standard: false, sharing: one)
        defer { two.tearDown() }
        let client = try #require(one.vaultClient)
        let emu = try #require(one.vaultEmu)
        let material = try #require(one.oldMaterial)
        let before = try await one.vault()
        try reconcileKeyFile(of: one, to: before, corpusKeyID: material.corpusKeyID)
        try reconcileKeyFile(of: two, to: before, corpusKeyID: material.corpusKeyID)
        let twoBytesBefore = try Data(contentsOf: two.oldKeyFileURL)

        // Device 2's door, the vault fetched at its threshold.
        let twoController = controller(for: two, material: material)
        twoController.adoptResident(two.oldKey)
        await twoController.reconcile()
        #expect(twoController.posture == .castle)
        let twoSession = try wireSession(for: two, controller: twoController)
        await twoSession.refresh()
        let twoDoor = try keyDoor(.changePassphrase, encryption: twoSession, tie: vaultTie(client, hasRecoveryWrap: false))
        await twoDoor.start()
        #expect(twoDoor.phase == .authorize, "\(twoDoor.phase) \(twoDoor.lastError ?? "")")

        // DEVICE 1's change lands inside device 2's write — between its
        // fetch and its CAS (device 1's own key file follows, as its door lands it).
        let p1 = "device-one-new-word-12"
        let p2 = "device-two-new-word-12"
        let oneKeyFileURL = one.oldKeyFileURL
        let oneKey = one.oldKey
        emu.setBeforeUpdate {
            _ = try await VaultEnrollment(client: client).changePassphrase(authorizedBy: .passphrase("sesame"), newPassphrase: p1)
            let landed = try #require(try await client.fetchVault())
            var file = try #require(try StoreKeyEnvelope.load(at: oneKeyFileURL))
            try file.setPassphraseWrap(key: oneKey, passphrase: p1, kdf: landed.format.kdf)
            try file.recordVaultReconciliation(kdf: landed.format.kdf, corpusKeyID: material.corpusKeyID, recoveryWrapDigest: landed.format.recoveryWrapDigest)
            try file.write(at: oneKeyFileURL)
        }
        await twoDoor.changePassphrase(current: "sesame", new: p2, confirmation: p2)
        #expect(twoDoor.phase == .authorize, "the door stays on its field")
        #expect(twoDoor.lastError == EncryptionSession.message(for: KeyVaultClientError.vaultRevisionConflict),
                "step 5: the CAS refused device 2 — 'nothing was overwritten'")
        let afterOne = try await one.vault()
        #expect(afterOne.revision == before.revision + 1, "exactly device 1's write landed")
        #expect((try? await VaultEnrollment(client: client).enroll(passphrase: p1))?.masterKey == material.masterKey, "the vault is under device 1's word")
        await #expect(throws: VaultEnrollmentError.wrongPassphrase) { _ = try await VaultEnrollment(client: client).enroll(passphrase: p2) }
        await #expect(throws: VaultEnrollmentError.wrongPassphrase) { _ = try await VaultEnrollment(client: client).enroll(passphrase: "sesame") }
        #expect(try Data(contentsOf: two.oldKeyFileURL) == twoBytesBefore, "device 2's key file untouched — nothing was overwritten anywhere")

        // Device 2 RE-READS: the word it typed a moment ago is RETIRED now.
        await twoDoor.changePassphrase(current: "sesame", new: p2, confirmation: p2)
        #expect(twoDoor.lastError == ProtectionCopy.retiredPassphraseAtDoor,
                "step 5: after the re-read, the retry with the old word is worded RETIRED (copy §5)")
        #expect(twoDoor.phase == .authorize)
        // …and RETRIES by the road that needs no current word — Touch ID, the
        // held material: it lands ON TOP. The last change wins.
        twoDoor.forgot()
        #expect(twoDoor.phase == .forgotBiometric, "Castle + Touch ID: the presence confirm")
        await twoDoor.resetPassphraseWithBiometrics(new: p2, confirmation: p2)
        try await settle(twoDoor)
        #expect(twoDoor.phase == .done, "\(twoDoor.phase) \(twoDoor.lastError ?? "")")
        let afterTwo = try await one.vault()
        #expect(afterTwo.revision == before.revision + 2)
        #expect((try? await VaultEnrollment(client: client).enroll(passphrase: p2))?.masterKey == material.masterKey, "step 5: the LAST change wins — the vault is under device 2's word")
        await #expect(throws: VaultEnrollmentError.wrongPassphrase) { _ = try await VaultEnrollment(client: client).enroll(passphrase: p1) }
        #expect(afterTwo.format.classKey(for: .corpus)?.keyID == material.corpusKeyID, "a re-wrap, never a re-key")
        let twoFile = try #require(try StoreKeyEnvelope.load(at: two.oldKeyFileURL))
        #expect(try twoFile.unwrapKey(passphrase: p2) == two.oldKey && twoFile.passphrase?.kdf == afterTwo.format.kdf && twoFile.vaultKDF == afterTwo.format.kdf,
                "device 2's key file under its word with the vault's descriptor")

        // DEVICE 1 LEARNS at its next open: the notice, and the vault road at its lobby.
        let oneController = controller(for: one, material: material)
        oneController.adoptResident(one.oldKey)
        await oneController.reconcile()
        let learned = try #require(oneController.changeNotice)
        #expect(learned.kind == .passphraseChangedElsewhere && !oneController.followPending, "step 5: the other device learns — the notice")
        let session = SyncCustodySession()
        let derivations = LockIsolated(0)
        #expect(opened(await lobbyOpen(one, p1, online: false, session: session, derivations: derivations)) == one.oldKey, "its own word still opens it (the local copy)")
        #expect(opened(await lobbyOpen(one, p2, online: true, session: session, derivations: derivations)) == one.oldKey, "the winning word opens it online through the vault road")
        let oneAfter = try #require(try StoreKeyEnvelope.load(at: one.oldKeyFileURL))
        #expect(oneAfter.passphrase?.kdf == afterTwo.format.kdf, "…and re-wraps its copy")
    }

    /// §7 STEP 7 — TWO DEVICES SWITCHING POSTURE AT ONCE (corner 39; ledger
    /// 40): both Standard on a Standard account; device B's WHOLE `enterCastle`
    /// lands inside device A's vault write (the one-shot hook); A's CAS
    /// refuse RE-READS — the account already moved — and A's road becomes
    /// THE FOLLOW with the passphrase it typed for the ceremony: no second
    /// rotation, no vault write of A's own, the vault's corpus key id
    /// advanced exactly ONCE (B's), A's library re-keyed under B's M′, A's
    /// old key file retired (a follow), the ceremony's own words NOT landed
    /// (the vault's are B's). The refusal A meets is the PROOF's (B's
    /// rotation replaced the hash — the RPC checks the proof before the
    /// CAS); the CAS is what refuses when only a re-wrap intervened (the
    /// step-5 pin) — the runner re-reads on either. RED-ON-OLD: the refusal
    /// propagated, a `.vaultWrite` marker stood, A never entered Castle in
    /// the act.
    @Test func twoDevicesSwitchingPostureAtOnceTheSecondsCASRefuseBecomesTheFollow() async throws {
        let a = try await makeWorld()
        defer { a.tearDown() }
        let client = try #require(a.vaultClient)
        let emu = try #require(a.vaultEmu)
        let material = try #require(a.oldMaterial)
        // The account STANDARD-shaped (the 2b world's vault is born without the
        // Apple-held copy — the 2c drill's fix, the act leaving Castle performs).
        let born = try await a.vault()
        try await client.updateVault(
            try born.format.settingAppleHeldCopy(masterKey: material.masterSymmetricKey, appleKey: a.apple.symmetricKey, appleKeyID: a.apple.id),
            expectedRevision: born.revision, keyProof: KeyProofMaterial(master: material.masterSymmetricKey))
        let b = try await makeWorld(sharing: a)  // built BEFORE any switch (its seed rides the old keys)
        defer { b.tearDown() }
        let revisionBefore = try await a.vault().revision
        let updatesBefore = emu.updateCount

        // B's whole switch lands inside A's vault write.
        let bOutcome = LockIsolated<PostureSwitchRunner.Outcome?>(nil)
        emu.setBeforeUpdate {
            try await Task { @MainActor in
                let done = try await b.runner.enterCastle(passphrase: "sesame", recoveryWords: b.words)
                bOutcome.setValue(done)
            }.value
        }
        let aOutcome = try await a.runner.enterCastle(passphrase: "sesame", recoveryWords: a.words)
        let bDone = try #require(bOutcome.value)
        let bMaterial = try #require(bDone.material)

        // B ROTATED; A FOLLOWED — the vault moved for ONE rotation, and A never wrote it.
        let vault = try await a.vault()
        #expect(vault.format.classKey(for: .corpus)?.keyID == bMaterial.corpusKeyID, "the corpus key id is B's — advanced exactly once")
        #expect(vault.revision == revisionBefore + 2, "B's begin + B's completion; A wrote nothing")
        #expect(emu.updateCount == updatesBefore + 3, "B's begin, B's completion, and A's ONE refused attempt")
        #expect(vault.format.masterWrappedByAppleHeld == nil && vault.format.previousCorpusKey == nil, "Castle, the rotation complete")
        #expect(aOutcome.entersCastle && aOutcome.reencrypted == 0, "step 7: A's road was the FOLLOW — nothing re-encrypted, no rotation of its own")
        #expect(aOutcome.material?.corpusKeyID == bMaterial.corpusKeyID && a.keyStore.load()?.masterKey == bMaterial.masterKey, "A holds B's M′ / C′")
        #expect(try await a.marker() == nil, "no marker left standing")
        #expect(a.calls.rekeys == 1 && a.calls.custodyTargets.last == .biometric && a.posture == .castle, "A re-keyed its own library and gated custody")
        let aFile = try a.keyFile(aOutcome.newKeyFingerprint)
        let aKey = try aFile.unwrapKey(passphrase: "sesame")
        #expect(StoreEncryptionMigration.opens(a.storeURL, key: aKey) && !StoreEncryptionMigration.opens(a.storeURL, key: a.oldKey))
        #expect(aFile.passphrase?.kdf == vault.format.kdf && aFile.vaultCorpusKeyID == bMaterial.corpusKeyID && aFile.apple == nil, "A's new key file under the vault's descriptor, no Apple copy")
        #expect(try aFile.unwrapKey(master: bMaterial.masterSymmetricKey) == aKey, "L′ under B's M′")
        #expect(aFile.recovery == nil, "the ceremony's words are NOT landed — the vault's words are B's; the W copy lands when the account's words are next typed here")
        #expect(!FileManager.default.fileExists(atPath: a.oldKeyFileURL.path), "A's road was a follow — its Standard-era key file left the live folder")
        // pre-13x 5a (ledger 61 — PROVISIONAL): the LOSING ceremony's Done is
        // copy §2b's conflict-follow sentence naming the device the vault
        // records, never the ordinary Done; the winner's is the ordinary one.
        #expect(aOutcome.followedAnotherDevicesSwitch && aOutcome.otherDeviceName == "test device",
                "A's outcome says its road became the follow, naming the vault's device")
        #expect(ProtectionCopy.castleDoneBody(aOutcome) == ProtectionCopy.enteredCastleAfterAnotherDevice(device: "test device"))
        #expect(ProtectionCopy.castleDoneBody(aOutcome) != ProtectionCopy.enteredCastleDone, "not the ordinary Done — the words shown were not the account's")
        #expect(!bDone.followedAnotherDevicesSwitch && ProtectionCopy.castleDoneBody(bDone) == ProtectionCopy.enteredCastleDone)
        try await expectCastleEndState(b, bDone)
        // Both read each other's notes under the one corpus key.
        let aEngine = SyncEngine(transport: try #require(a.mirror), keyProvider: DeviceKeySyncProvider(store: a.keyStore))
        try await withDependencies { $0.database = a.view } operation: { _ = try await aEngine.pull() }
        let seenByA = try await titles(in: a)
        for (id, title) in b.seededTitles { #expect(seenByA[id] == title, "A reads B's \(id) in the clear") }
    }

    // MARK: - pre-13x 5b.0(c): THE RESUME ROAD'S FLAG (ledger 67)

    /// LEDGER 67 → 69 — the conflict-follow by the RESUME road: A's ceremony
    /// is KILLED before its vault write (the marker at `.vaultWrite`, the
    /// vault untouched); B — a sibling with its OWN vault client, so its
    /// writes stamp "sibling device" — enters Castle whole meanwhile; A
    /// relaunches and resumes by its passphrase (the resume door passes no
    /// words). The vault's corpus key id has MOVED, so the resume's arm
    /// picks M′ up from the vault — and because the vault's id is NOT the
    /// one A's marker stamped before its write (F1, ledger 69: the exact
    /// discriminator — `CorpusRotation.prepare` mints the id first), the
    /// road is THE FOLLOW: no second rotation, the ceremony's words NOT
    /// landed (the account's words are B's), and the outcome carries the
    /// flag + B's name (the vault's `updated_by_device` — now only the
    /// sentence's NAME) so the ceremony's Done speaks copy §2b's conflict
    /// sentence, never the ordinary Done. A ends in Castle under B's keys
    /// with its old key file retired. The CONTROLS: the standing pin (b)
    /// above (a resume after THIS device's own landed write, no follower)
    /// and `aCeremonyWhoseOwnWriteLandedResumesAsItselfAfterAFollowerFinished
    /// AndSpeaksTheOrdinaryDone` (5b's recorded corner, now exact). RED-ON-
    /// OLD (5b): the discriminator absent — A's resume landed the ceremony's
    /// words and told the user the ordinary Done; (F1) the id stamped ⇒ this
    /// pin holds under both readings (B's name ≠ A's AND B's id ≠ A's
    /// marker's) — the corner pin is what tells the two readings apart.
    @Test func aCeremonyKilledBeforeItsVaultWriteResumesIntoAnotherDevicesSwitchAsTheFollowAndSaysSo() async throws {
        let a = try await makeWorld()
        defer { a.tearDown() }
        let b = try await makeWorld(sharing: a, deviceName: "sibling device")  // built BEFORE any switch
        defer { b.tearDown() }
        let revisionBefore = try await a.vault().revision
        arm(a, faultAt: .beforeVaultWrite)
        await #expect(throws: PostureSwitchError.injectedFault(.beforeVaultWrite)) {
            _ = try await a.runner.enterCastle(passphrase: "sesame", recoveryWords: a.words)
        }
        let aMarker = try #require(try await a.marker())
        #expect(aMarker.step == .vaultWrite)
        #expect(aMarker.newCorpusKeyID != nil, "F1: the marker carries the id the ceremony minted BEFORE its write")
        #expect(try await a.vault().revision == revisionBefore, "A's write never landed")

        // B's whole switch lands while A is down.
        let bDone = try await b.runner.enterCastle(passphrase: "sesame", recoveryWords: b.words)
        try await expectCastleEndState(b, bDone)
        let bMaterial = try #require(bDone.material)
        #expect(bMaterial.corpusKeyID != aMarker.newCorpusKeyID, "the vault's id is B's, not the one A's marker stamped — the exact reading")
        #expect(try await a.vault().format.updatedByDevice == "sibling device", "the vault names B as its last writer (the sentence's name)")

        // A resumes by the passphrase alone — the resume door's shape.
        arm(a, faultAt: nil)
        let outcome = try await a.runner.resume(passphrase: "sesame")
        #expect(outcome.followedAnotherDevicesSwitch && outcome.otherDeviceName == "sibling device",
                "the resume's road was the FOLLOW into B's switch, naming the vault's writer: \(outcome)")
        #expect(ProtectionCopy.castleDoneBody(outcome) == ProtectionCopy.enteredCastleAfterAnotherDevice(device: "sibling device"))
        #expect(ProtectionCopy.castleDoneBody(outcome) != ProtectionCopy.enteredCastleDone,
                "not the ordinary Done — the words A's ceremony showed are not the account's")
        // A rotated nothing: the vault's key id is B's, advanced exactly once.
        let vault = try await a.vault()
        #expect(vault.format.classKey(for: .corpus)?.keyID == bMaterial.corpusKeyID)
        #expect(outcome.entersCastle && outcome.reencrypted == 0, "nothing left to re-encrypt — B finished its own rotation")
        #expect(outcome.material?.corpusKeyID == bMaterial.corpusKeyID && a.keyStore.load()?.masterKey == bMaterial.masterKey, "A holds B's M′ / C′")
        #expect(try await a.marker() == nil, "no marker left standing")
        #expect(a.calls.rekeys == 1 && a.calls.custodyTargets.last == .biometric && a.posture == .castle, "A re-keyed its own library and gated custody")
        let aFile = try a.keyFile(outcome.newKeyFingerprint)
        let aKey = try aFile.unwrapKey(passphrase: "sesame")
        #expect(StoreEncryptionMigration.opens(a.storeURL, key: aKey) && !StoreEncryptionMigration.opens(a.storeURL, key: a.oldKey))
        #expect(aFile.apple == nil && aFile.vaultCorpusKeyID == bMaterial.corpusKeyID, "A's new key file: no Apple copy, under the vault's key id")
        #expect(try aFile.unwrapKey(master: bMaterial.masterSymmetricKey) == aKey, "L′ under B's M′")
        #expect(aFile.recovery == nil, "the ceremony's words are NOT landed — the account's words are B's")
        #expect(!FileManager.default.fileExists(atPath: a.oldKeyFileURL.path), "the road was a follow — A's Standard-era key file left the live folder")
        // The winner's Done is the ordinary one.
        #expect(!bDone.followedAnotherDevicesSwitch && ProtectionCopy.castleDoneBody(bDone) == ProtectionCopy.enteredCastleDone)
    }

    /// LEDGER 69 — 5b's RECORDED CORNER, made exact (F1): A's ceremony's
    /// vault write LANDED (the marker at `.vaultWrite` stamped with the id
    /// it minted; custody never took M′ — the fault after the write); a
    /// FOLLOWER (B, its own vault client named "sibling device") finished
    /// the rotation by the passphrase — its clearing write stamps ITS name
    /// on the vault; then A resumes with its passphrase and its words. The
    /// vault's corpus key id IS the one A's marker stamped, so this is A's
    /// OWN switch: the ORDINARY Done, no flag, no other device named, and
    /// the ceremony's twelve words LANDED on A's new key file (they are the
    /// account's — B followed under them). RED-ON-OLD (behavioural revert:
    /// the 5b device-name reading — `updated_by_device` ≠ this device ⇒
    /// "another device rotated"): A was told the conflict-follow sentence
    /// over words that WERE the account's, and its words were not landed.
    @Test func aCeremonyWhoseOwnWriteLandedResumesAsItselfAfterAFollowerFinishedAndSpeaksTheOrdinaryDone() async throws {
        let a = try await makeWorld()
        defer { a.tearDown() }
        let b = try await makeWorld(sharing: a, deviceName: "sibling device")  // built BEFORE any switch
        defer { b.tearDown() }
        let oldMaterial = try #require(a.oldMaterial)
        arm(a, faultAt: .afterVaultWriteBeforeCustody)
        await #expect(throws: PostureSwitchError.injectedFault(.afterVaultWriteBeforeCustody)) {
            _ = try await a.runner.enterCastle(passphrase: "sesame", recoveryWords: a.words)
        }
        let aMarker = try #require(try await a.marker())
        #expect(aMarker.step == .vaultWrite)
        let landed = try await a.vault()
        let stamped = try #require(aMarker.newCorpusKeyID, "F1: the id minted before the write rides the marker")
        #expect(landed.format.classKey(for: .corpus)?.keyID == stamped, "A's write LANDED under the id its marker stamped")
        #expect(landed.format.previousCorpusKey != nil, "the rotation is open on the server")
        #expect(a.keyStore.load()?.corpusKeyID == oldMaterial.corpusKeyID, "custody never took M′")

        // THE FOLLOWER finishes the rotation while A is down — its clearing
        // write stamps "sibling device" on the vault.
        let followed = try await b.runner.follow(passphrase: "sesame", recoveryWords: nil)
        #expect(followed.entersCastle && followed.reencrypted >= 3)
        let afterFollow = try await a.vault()
        #expect(afterFollow.format.previousCorpusKey == nil && afterFollow.format.rotationStartedSeq == nil,
                "the follower cleared the previous key + the seq at head")
        #expect(afterFollow.format.updatedByDevice == "sibling device", "the vault's LAST writer is the follower — 5b's reading would call this another device's rotation")
        #expect(afterFollow.format.classKey(for: .corpus)?.keyID == stamped, "…but the corpus key id is still the one A minted")

        // A resumes with its passphrase and its words: ITS OWN switch.
        arm(a, faultAt: nil)
        let outcome = try await a.runner.resume(passphrase: "sesame", recoveryWords: a.words)
        #expect(!outcome.followedAnotherDevicesSwitch && outcome.otherDeviceName == nil,
                "the vault's id is the one this ceremony minted — no follow, no flag: \(outcome)")
        #expect(ProtectionCopy.castleDoneBody(outcome) == ProtectionCopy.enteredCastleDone, "the ORDINARY Done")
        #expect(ProtectionCopy.castleDoneBody(outcome) != ProtectionCopy.enteredCastleAfterAnotherDevice(device: "sibling device"))
        try await expectCastleEndState(a, outcome)
        #expect(outcome.reencrypted == 0, "the follower had finished the walk")
        #expect(outcome.material?.corpusKeyID == stamped && a.keyStore.load()?.corpusKeyID == stamped)
        let aFile = try a.keyFile(outcome.newKeyFingerprint)
        let aKey = try aFile.unwrapKey(passphrase: "sesame")
        #expect(aFile.recovery != nil, "the ceremony's words ARE the account's — landed on the new key file")
        #expect(try aFile.unwrapKey(recoveryWords: a.words) == aKey)
        #expect(FileManager.default.fileExists(atPath: a.oldKeyFileURL.path),
                "the ceremony's own road keeps its old key file beside old snapshots (2b's letter — not a follow)")
        #expect(a.calls.log.value.contains { $0.contains("this device's own vault write landed") }, "the runner said which story it read")
    }

    // MARK: - pre-13x 4b.4: THE UN-FOLLOWED DEVICE — the whole §12 list as ONE pin

    /// THE UN-FOLLOWED DEVICE (§7's "a device that has not followed yet";
    /// §12): after Castle was entered elsewhere, the sibling — opened by the
    /// passphrase, so the lobby holds the derived key — learns the follow
    /// and takes *Later*. Then: it opens and reads, and edits (the row
    /// queues); sync is refused with BOTH markers (the fence on the old
    /// custody; the proof on the current key id with the old master) and
    /// both present as the replaced-keys row; EVERY key door speaks *Pick up
    /// your new keys first — enter your passphrase.* — the pane's branch
    /// (`followPending`), the Encryption tab's branch (`.keysReplaced` + the
    /// follow's door) AND the models themselves (4b's guards); Sign out and
    /// Delete account work; the notice returns at every open; the
    /// passphrase typed to open is reused for the follow; a NEW rotation
    /// while *Later* stands re-asks at once; and, followed, every door opens
    /// again. RED-ON-OLD: the model guards absent — the change door opened
    /// its fields (as a local-only door) and the switches ran their checks.
    @Test func theUnfollowedDeviceOpensReadsAndWaitsWithEveryDoorSpeakingTheSentence() async throws {
        let acting = try await makeWorld()
        defer { acting.tearDown() }
        let sibling = try await makeWorld(sharing: acting)
        defer { sibling.tearDown() }
        let client = try #require(acting.vaultClient)
        let mirror = try #require(acting.mirror)
        let oldMaterial = try #require(acting.oldMaterial)
        try await VaultEnrollment(client: client).landRecoveryWrap(words: acting.words, material: oldMaterial)
        try reconcileKeyFile(of: sibling, to: try await acting.vault(), corpusKeyID: oldMaterial.corpusKeyID)
        let siblingEngine = SyncEngine(transport: mirror, keyProvider: DeviceKeySyncProvider(store: sibling.keyStore))
        try await withDependencies { $0.database = sibling.view } operation: { _ = try await siblingEngine.push(); _ = try await siblingEngine.pull() }
        _ = try await acting.runner.enterCastle(passphrase: "sesame", recoveryWords: acting.words)
        let vault = try await sibling.vault()
        let newKeyID = try #require(vault.format.classKey(for: .corpus)?.keyID)

        // The sibling opened BY THE PASSPHRASE: the lobby holds the derived key under the vault's descriptor.
        let held = SyncCustodySession()
        held.holdDerivedWrappingKey(try PassphraseKDF.deriveKey(passphrase: "sesame", descriptor: vault.format.kdf), kdf: vault.format.kdf)
        let controller = controller(for: sibling, material: oldMaterial, session: held)
        controller.adoptResident(nil)
        let encryption = try wireSession(for: sibling, controller: controller)
        encryption.followDoor = { controller.openFollow() }  // the roots' wiring (2c)
        await controller.reconcile()
        let owed = try #require(controller.followNotice)
        #expect(owed.kind == .movedToCastle && controller.followPending)
        controller.openFollow()
        try #require(controller.activeFollow).later()
        controller.closeFollow()
        #expect(controller.notice == .followWaiting(owed), "Later — the persistent banner")

        // (i) OPENS AND READS — and edits: the row queues.
        let seen = try await titles(in: sibling)
        for (id, title) in acting.seededTitles { #expect(seen[id] == title, "reads \(id)") }
        try await seedBacklog(sibling, count: 1, tag: "typed-while-waiting")
        #expect(try await outboxCount(sibling) >= 1, "edits queue in the outbox")

        // (ii) SYNC REFUSED — both markers, both the replaced-keys row.
        let fenced: (any Error)? = await {
            do { try await withDependencies { $0.database = sibling.view } operation: { _ = try await siblingEngine.pull() }; return nil }
            catch { return error }
        }()
        #expect(fenced as? SyncError == .encryptionKeysReplaced, "the fence's marker — the old custody")
        let staleProofEngine = SyncEngine(transport: mirror, keyProvider: FixedKeyProvider(keys: SyncEncryptionKeys(
            corpusKey: oldMaterial.corpusSymmetricKey, corpusKeyID: newKeyID,
            keyProof: KeyProofMaterial(master: oldMaterial.masterSymmetricKey))))
        let refused: (any Error)? = await {
            do { try await withDependencies { $0.database = sibling.view } operation: { _ = try await staleProofEngine.pull() }; return nil }
            catch { return error }
        }()
        #expect(refused as? SyncError == .keyProofRefused, "the proof's marker — the current id with the old master")
        for error in [fenced, refused] {
            let face = SyncRowFace.face(
                allowsSync: true, isConfigured: true, signedIn: true, isSyncing: false,
                lastError: String(describing: try #require(error)), lastErrorIsOffline: false)
            #expect(face.kind == .keysReplaced && face.doors == [SyncRowFace.Door(label: "Re-enroll…", act: .openAccount(.encryption))],
                    "both markers present as the replaced-keys row (2c's classifier)")
        }
        #expect(try await outboxCount(sibling) >= 1, "the queued edit is intact")

        // (iii) EVERY KEY DOOR speaks the sentence.
        #expect(controller.followPending, "the Protection pane's branch: the posture doors are replaced by the sentence")
        await encryption.refresh()
        #expect(encryption.state == .keysReplaced(hasRecoveryWrap: true) && encryption.followDoor != nil,
                "the Encryption tab's branch: the keys-replaced section — the sentence + the follow's door, no re-wrap doors")
        let tie = vaultTie(client, hasRecoveryWrap: true)
        let change = try keyDoor(.changePassphrase, encryption: encryption, tie: tie)
        await change.start()
        #expect(change.phase == .failed(ProtectionCopy.pickUpKeysFirst), "change passphrase: \(change.phase)")
        let regenerate = try keyDoor(.regenerateWords, encryption: encryption, tie: tie)
        await regenerate.start()
        #expect(regenerate.phase == .failed(ProtectionCopy.pickUpKeysFirst), "regenerate: \(regenerate.phase)")
        for mode in [PostureSwitchModel.Mode.replaceKeys, .enter, .leave] {
            let model = PostureSwitchModel(mode: mode, runner: sibling.runner, controller: controller, vaultTie: tie)
            await model.start()
            #expect(model.phase == .failed(ProtectionCopy.pickUpKeysFirst), "\(mode): \(model.phase)")
        }
        #expect(try await sibling.marker() == nil && sibling.calls.rekeys == 0 && sibling.keyStore.load()?.corpusKeyID == oldMaterial.corpusKeyID,
                "nothing acted, nothing moved")

        // (iv) SIGN OUT and DELETE ACCOUNT work (3b's doors — the account's own credential, never a key act).
        let auth = makeAuth()
        #expect(await auth.currentUserID == "user-2b")
        await auth.signOut(scope: .local)
        #expect(await auth.currentUserID == nil, "sign out works")
        let lifecycle = PurgeCountingLifecycle()
        _ = try await AccountDeletion(lifecycle: lifecycle).run()
        #expect(await lifecycle.purges == 1, "delete account works")

        // (v) THE NOTICE RETURNS AT EVERY OPEN (4a's per-open reset).
        controller.resetPerOpenDeferrals()
        controller.refreshNotices()
        #expect(controller.notice == .follow(owed), "a relock + unlock is an open — the modal notice again")

        // (vi) A PASSPHRASE TYPED TO OPEN IS REUSED FOR THE FOLLOW (4a's held key).
        controller.openFollow()
        let reuse = try #require(controller.activeFollow)
        #expect(reuse.canFollowFromHeldKey, "the word typed at the lobby would run the follow with no second entry")
        reuse.later()
        controller.closeFollow()
        #expect(controller.notice == .followWaiting(owed))

        // (vii) A NEW ROTATION WHILE LATER STANDS RE-ASKS AT ONCE (ledger 35).
        _ = try await acting.runner.replaceAllKeys(passphrase: "sesame", recoveryWords: acting.words)
        await controller.reconcile()
        let reasked = try #require(controller.followNotice)
        let newestKeyID = try await sibling.vault().format.classKey(for: .corpus)?.keyID
        #expect(reasked.corpusKeyID != owed.corpusKeyID && reasked.corpusKeyID == newestKeyID, "a NEW key id — the second rotation's")
        #expect(reasked.kind == .movedToCastle, "still Standard-shaped and the account Castle: the same honest kind, a new id")
        #expect(controller.notice == .follow(reasked), "Later's banner gives way — the modal notice at once")

        // Followed — 17l item 5 (RUN B B3) RE-BASED this tail (the
        // ruled-change class): the second rotation KEPT the word, so its
        // descriptor was REUSED and the held key still matches — the
        // follow runs from it with NO field (the shipped pre-fix arm
        // asserted the fresh-salt consequence here: a stale key and the
        // field asking). Every door opens again.
        controller.openFollow()
        let follow = try #require(controller.activeFollow)
        #expect(follow.canFollowFromHeldKey, "the held key still matches — the unchanged word's descriptor was reused")
        follow.choosePassphrase()
        #expect(follow.phase != .askPassphrase, "no field — never asked twice, across the second rotation too")
        for _ in 0..<600 {
            if case .done = follow.phase { break }
            if case .failed = follow.phase { break }
            try await Task.sleep(for: .milliseconds(50))
        }
        guard case .done = follow.phase else { Issue.record("expected .done, got \(follow.phase) \(follow.lastError ?? "")"); return }
        #expect(!controller.followPending && sibling.calls.rekeys == 1)
        await encryption.refresh()
        #expect(encryption.state == .enrolled(hasRecoveryWrap: true))
        let changeAgain = try keyDoor(.changePassphrase, encryption: encryption, tie: tie)
        await changeAgain.start()
        #expect(changeAgain.phase == .authorize, "followed: the door opens")
        let replaceAgain = PostureSwitchModel(mode: .replaceKeys, runner: sibling.runner, controller: controller, vaultTie: tie)
        await replaceAgain.start()
        #expect(replaceAgain.phase == .explain, "followed: Replace All Keys opens — \(replaceAgain.phase)")
        try await withDependencies { $0.database = sibling.view } operation: {
            let report = try await SyncEngine(transport: mirror, keyProvider: DeviceKeySyncProvider(store: sibling.keyStore)).push()
            #expect(report.accepted >= 1, "the queued edit pushes under C′")
        }
    }

    // MARK: - pre-13x 4b.5: KEY DOORS ONLINE

    /// EVERY KEY DOOR OF AN ENROLLED LIBRARY IS AN ONLINE ACT (decision 9;
    /// §12): over a vault client whose network is DOWN, change passphrase
    /// and regenerate refuse at their threshold with copy §4's offline
    /// sentence (the one shared door sentence — regenerate has no line of
    /// its own), Replace All Keys and both switches refuse at the door
    /// check with the runner's URLError sentence; nothing is written; the
    /// same doors OPEN once the network is back. A LOCAL-ONLY library
    /// changes its passphrase offline against its key file (3b's pin,
    /// re-asserted in this world). Two online changes at once: the step-5
    /// pin above.
    @Test func everyKeyDoorOfAnEnrolledLibraryRefusesOfflineWithTheSentenceAndOpensOnline() async throws {
        let world = try await makeWorld(standard: false)
        defer { world.tearDown() }
        let emu = try #require(world.vaultEmu)
        let offline = LockIsolated(false)
        let flaky = KeyVaultClient(
            configuration: KeyVaultClient.Configuration(
                projectURL: URL(string: "https://vault.2b.invalid")!, apiKey: "publishable-test-key", deviceName: "test device"),
            sessionProvider: StaticSessionProvider(session: UserSession(accessToken: "token-2b", userID: "user-2b")),
            load: { request in
                if offline.value { throw URLError(.notConnectedToInternet) }
                return try await emu.load(request)
            })
        let controller = makeController(for: world)
        controller.adoptResident(world.oldKey)
        wireVaultReading(controller, client: flaky)
        await controller.reconcile()
        let encryption = EncryptionSession(store: world.keyStore, client: flaky, signedIn: { true })
        wireOneSecretHooks(protection: controller, encryption: encryption, keyVault: flaky, auth: makeAuth())
        await encryption.refresh()
        #expect(encryption.state == .enrolled(hasRecoveryWrap: false), "\(encryption.state)")
        let runner = PostureSwitchRunner(leaves: leaves(for: world, vaultOverride: flaky))
        let tie = vaultTie(flaky, hasRecoveryWrap: false)
        let bytesBefore = try Data(contentsOf: world.oldKeyFileURL)
        let revisionBefore = try await world.vault().revision

        offline.setValue(true)
        let change = try keyDoor(.changePassphrase, encryption: encryption, tie: tie)
        await change.start()
        #expect(change.phase == .failed(ProtectionCopy.changePassphraseOffline), "change passphrase offline: \(change.phase)")
        let regenerate = try keyDoor(.regenerateWords, encryption: encryption, tie: tie)
        await regenerate.start()
        #expect(regenerate.phase == .failed(ProtectionCopy.changePassphraseOffline), "regenerate offline: \(regenerate.phase)")
        let offlineSentence = PostureSwitchModel.message(for: URLError(.notConnectedToInternet))
        for mode in [PostureSwitchModel.Mode.replaceKeys, .enter, .leave] {
            let model = PostureSwitchModel(mode: mode, runner: runner, controller: controller, vaultTie: tie)
            await model.start()
            #expect(model.phase == .failed(offlineSentence), "\(mode) offline: \(model.phase)")
        }
        #expect(try Data(contentsOf: world.oldKeyFileURL) == bytesBefore, "nothing written offline")
        #expect(try await world.marker() == nil && world.calls.rekeys == 0 && world.calls.custodyTargets.isEmpty)

        offline.setValue(false)
        #expect(try await world.vault().revision == revisionBefore, "the vault untouched")
        let changeOnline = try keyDoor(.changePassphrase, encryption: encryption, tie: tie)
        await changeOnline.start()
        #expect(changeOnline.phase == .authorize, "online: the fields")
        let regenerateOnline = try keyDoor(.regenerateWords, encryption: encryption, tie: tie)
        await regenerateOnline.start()
        #expect(regenerateOnline.phase == .authorize)
        let replace = PostureSwitchModel(mode: .replaceKeys, runner: runner, controller: controller, vaultTie: tie)
        await replace.start()
        #expect(replace.phase == .explain, "online: Replace All Keys opens — \(replace.phase)")
        let leave = PostureSwitchModel(mode: .leave, runner: runner, controller: controller, vaultTie: tie)
        await leave.start()
        #expect(leave.phase == .leaveConfirm, "online: Use Standard opens — \(leave.phase)")

        // A LOCAL-ONLY library changes its passphrase OFFLINE against its key file.
        let local = try await makeWorld(enrolled: false, standard: false)
        defer { local.tearDown() }
        let localController = makeController(for: local)
        localController.adoptResident(local.oldKey)
        let localEncryption = EncryptionSession(store: local.keyStore, client: nil, signedIn: { false })
        wireOneSecretHooks(protection: localController, encryption: localEncryption, keyVault: nil, auth: makeAuth())
        await localEncryption.refresh()
        let localDoor = KeyDoorModel(kind: .changePassphrase, encryption: localEncryption, facts: try #require(localEncryption.keyDoorFacts))
        await localDoor.start()
        #expect(localDoor.phase == .authorize && !localDoor.isEnrolledDoor, "a local-only door needs no network")
        await localDoor.changePassphrase(current: "not the word", new: "a-new-local-word-12", confirmation: "a-new-local-word-12")
        #expect(localDoor.lastError == ProtectionCopy.message(for: StoreKeyEnvelopeError.wrongPassphrase))
        await localDoor.changePassphrase(current: "sesame", new: "a-new-local-word-12", confirmation: "a-new-local-word-12")
        try await settle(localDoor)
        #expect(localDoor.phase == .done, "\(localDoor.phase) \(localDoor.lastError ?? "")")
        let localFile = try #require(try StoreKeyEnvelope.loadCurrent(besideStore: local.storeURL))
        #expect(try localFile.unwrapKey(passphrase: "a-new-local-word-12") == local.oldKey)
        #expect(throws: StoreKeyEnvelopeError.wrongPassphrase) { _ = try localFile.unwrapKey(passphrase: "sesame") }
    }

    // MARK: - pre-13x 4b.6: THE POSTURE PINS in the two-device world

    /// (a) A STANDARD device under a CASTLE account owes the posture-mismatch
    /// follow at ready and, followed, gates at its next open (custody behind
    /// Touch ID, the posture Castle, the effective gate biometric — 2d's
    /// road). (b) A CASTLE → STANDARD switch propagates SILENTLY: the acting
    /// device leaves Castle; a Castle sibling's reconcile runs the follow
    /// into Standard with nothing typed and no modal — its own Apple copy in
    /// its key file, custody silent, nothing rotated. (c) An account with NO
    /// vault makes nothing Castle (corner 26): two local-only libraries, one
    /// Castle and one Standard, each keep their own posture and nothing is
    /// written.
    @Test func thePosturePinsHoldInTheTwoDeviceWorld() async throws {
        // (a) Standard under Castle ⇒ the mismatch follow ⇒ gated at the next open.
        let acting = try await makeWorld()
        defer { acting.tearDown() }
        let material = try #require(acting.oldMaterial)
        #expect(try await acting.vault().format.masterWrappedByAppleHeld == nil, "the 2b world's account is Castle-shaped")
        let standard = try await makeWorld(sharing: acting)
        defer { standard.tearDown() }
        let sc = controller(for: standard, material: material)
        sc.adoptResident(nil)  // the silent road adopted nil: the custody SHAPE is in view
        await sc.reconcile()
        let owed = try #require(sc.followNotice)
        #expect(owed.kind == .castleStillOpensOldWay && sc.posture == .castle, "the account's posture is Castle; this library opened silently")
        sc.openFollow()
        let model = try #require(sc.activeFollow)
        model.choosePassphrase()
        await model.enter(passphrase: "sesame")
        guard case .done = model.phase else { Issue.record("expected .done, got \(model.phase) \(model.lastError ?? "")"); return }
        #expect(standard.calls.custodyTargets == [.biometric] && standard.posture == .castle && standard.calls.rekeys == 1)
        #expect(StoreAtOpenMode.effective(posture: standard.posture, dials: ProtectionDials()) == .biometric, "(a) gates at its next open")
        let standardAfter = try #require(try StoreKeyEnvelope.loadCurrent(besideStore: standard.storeURL))
        #expect(standardAfter.apple == nil, "no Apple copy beside a Castle library")
        #expect(!sc.followPending)

        // (b) Castle → Standard propagates silently.
        let castleActing = try await makeWorld(standard: false)
        defer { castleActing.tearDown() }
        let castleSibling = try await makeWorld(standard: false, sharing: castleActing)
        defer { castleSibling.tearDown() }
        let castleMaterial = try #require(castleActing.oldMaterial)
        try await castleActing.runner.leaveCastle()
        let revisionAfterLeaving = try await castleActing.vault().revision
        let cc = controller(for: castleSibling, material: castleMaterial)
        cc.adoptResident(castleSibling.oldKey)  // the gated shape
        cc.followIntoStandardAct = { try await castleSibling.runner.followIntoStandard() }
        await cc.reconcile()
        #expect(cc.followNotice == nil && !cc.followPending && cc.activeFollow == nil, "(b) nothing typed, no modal")
        let movedNotice = try #require(cc.movedToStandardNotice)
        #expect(cc.notice == .movedToStandard(movedNotice), "the one-time OK")
        let siblingFile = try #require(try StoreKeyEnvelope.loadCurrent(besideStore: castleSibling.storeURL))
        let viaOwnApple = try siblingFile.unwrapKey(apple: castleSibling.apple.symmetricKey)
        #expect(siblingFile.appleKeyID == castleSibling.apple.id && viaOwnApple == castleSibling.oldKey,
                "(b) its OWN Apple copy, from its own iCloud Keychain")
        #expect(castleSibling.calls.custodyTargets == [.auto] && castleSibling.posture == .standard && castleSibling.calls.rekeys == 0, "custody silent, nothing rotated")
        #expect(try await castleActing.vault().revision == revisionAfterLeaving, "no vault write of the sibling's own")
        #expect(StoreEncryptionMigration.opens(castleSibling.storeURL, key: castleSibling.oldKey), "the library key unchanged")

        // (c) No vault ⇒ nothing Castle.
        let castleLocal = try await makeWorld(enrolled: false, standard: false)
        defer { castleLocal.tearDown() }
        let standardLocal = try await makeWorld(enrolled: false)
        defer { standardLocal.tearDown() }
        let standardBytes = try Data(contentsOf: standardLocal.oldKeyFileURL)
        let sl = makeController(for: standardLocal)
        sl.adoptResident(nil)
        sl.readVaultPosture = { nil }
        await sl.reconcile()
        #expect(sl.posture == .standard && sl.followNotice == nil && sl.notice != .follow(owed), "(c) a Standard local-only library stays Standard beside a Castle one")
        #expect(try Data(contentsOf: standardLocal.oldKeyFileURL) == standardBytes, "nothing written")
        let cl = makeController(for: castleLocal)
        cl.adoptResident(castleLocal.oldKey)
        cl.readVaultPosture = { nil }
        await cl.reconcile()
        #expect(cl.posture == .castle && cl.followNotice == nil, "(c) the Castle local-only library keeps its own posture — its key file's")
        let standardFile = try #require(try StoreKeyEnvelope.loadCurrent(besideStore: standardLocal.storeURL))
        #expect(Posture.derive(legacyMode: nil, vaultHasAppleHeldCopy: nil, keyFile: standardFile, rawKeyCustody: .silent, enrolled: false) == .determined(.standard),
                "(c) with no vault each library's posture is its own key file's (corner 26)")
    }
}


// MARK: - 18o U5 (ledger row 15 — 17t item 1): #86(c)'s near-empty corner on the REBUILT road

extension PostureSwitchTests {
    /// 18o U5 — **#86(c)'s NEAR-EMPTY CORNER, ON THE ROAD THAT EXISTS NOW** (a
    /// documented-behaviour pin; the UNIT U5 RECORD's THE TRACE — ITEM 1).
    /// Her ruling answered the 14c re-key, which TRUNCATED the mirror and
    /// re-pushed LOCAL truth: a near-empty store re-keying over a full server
    /// would have flattened it, and T1's probe warned before that truncate.
    /// The rebuilt Replace All Keys pulls to head FIRST (§4 step 1) and
    /// re-encrypts the SERVER's own rows in place (step 3, `sync_reencrypt`),
    /// so the corner the probe still DETECTS loses nothing: every note the
    /// fuller server held is still live there under the NEW keys, and the
    /// near-empty copy ends holding all of them. GREEN ON TODAY'S TREE BY
    /// DESIGN — this is the evidence that 17t item 1 is hollow as a defect
    /// (the typed gate itself is hers: QUESTIONS #164); it reds the day a
    /// local-as-truth road returns to this door.
    @Test func aNearEmptyCopysReplaceAllKeysLosesNothingTheFullerServerHolds() async throws {
        let full = try await makeWorld()
        defer { full.tearDown() }
        let mirror = try #require(full.mirror)
        // The fuller server: twelve more notes from the full device, pushed.
        var serverTitles = full.seededTitles
        var fuller: [(id: String, title: String)] = []
        for index in 0..<12 {
            fuller.append((id: "fuller-\(index)-\(UUID().uuidString.prefix(6))",
                           title: "Fuller note \(index) — \(UUID().uuidString.prefix(4))"))
        }
        for note in fuller { serverTitles[note.id] = note.title }
        let rows = fuller
        try await full.view.write { db in
            for note in rows {
                try db.execute(
                    sql: "INSERT INTO container (id, kind, title, created_at, updated_at) VALUES (?, 'post', ?, ?, ?)",
                    arguments: [note.id, note.title, "2026-09-06T00:00:00Z", "2026-09-06T00:00:00Z"])
            }
        }
        let fullEngine = SyncEngine(transport: mirror, keyProvider: DeviceKeySyncProvider(store: full.keyStore))
        try await withDependencies { $0.database = full.view } operation: {
            let report = try await fullEngine.push()
            #expect(report.accepted >= 12, "the fuller server's notes pushed")
        }

        // The NEAR-EMPTY copy: a sibling on the same account holding only
        // its own three notes, never pulled — the corner, exactly.
        let nearEmpty = try await makeWorld(sharing: full)
        defer { nearEmpty.tearDown() }
        for (id, title) in nearEmpty.seededTitles { serverTitles[id] = title }
        let localBefore = try await nearEmpty.view.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM container WHERE kind = 'post'") ?? 0
        }
        #expect(localBefore == 3, "the near-empty copy holds three notes of eighteen")

        // (1) The T1 probe reads it exactly as #86(c)'s corner — the server
        // holds fifteen notes this copy has never seen.
        let report = try await withDependencies { $0.database = nearEmpty.view } operation: {
            try await RekeyRecencyProbe(
                transport: mirror, keyProvider: DeviceKeySyncProvider(store: nearEmpty.keyStore)).assess()
        }
        #expect(report.notesOnlyOnServer == 15, "the probe names the corner: \(report)")
        #expect(RekeyGuardRule.decide(report) == .warnFirst)

        // (2) Replace All Keys, FROM the near-empty copy.
        let outcome = try await nearEmpty.runner.replaceAllKeys(passphrase: "sesame", recoveryWords: nil)
        let material = try #require(outcome.material)
        #expect(!outcome.entersCastle)

        // (3) The server lost NOTHING: every note it held is still there,
        // live — and a fresh device under the NEW keys reads all eighteen
        // back in the clear (so each was re-encrypted, not replaced).
        let stored = await mirror.stored()
        for id in serverTitles.keys {
            let row = stored["container/\(id)"]?.row
            #expect(row != nil, "\(id) is still on the server")
            #expect(row?.columns["deleted_at"] == nil || row?.columns["deleted_at"] == .null,
                    "\(id) is still live on the server")
        }
        let followerURL = nearEmpty.dir.appendingPathComponent("u5-follower/variorum.sqlite")
        let follower = try AppDatabase.openStore(at: followerURL, custody: .inMemory(initial: .mint()))
        let followerEngine = SyncEngine(transport: mirror, keyProvider: FixedKeyProvider(keys: material.syncKeys))
        try await withDependencies { $0.database = follower } operation: {
            _ = try await followerEngine.pull()
        }
        let followerTitles = try await follower.read { db in
            try Row.fetchAll(db, sql: "SELECT id, title FROM container WHERE deleted_at IS NULL")
                .reduce(into: [String: String]()) { acc, row in
                    let id: String = row["id"]; let title: String? = row["title"]; acc[id] = title
                }
        }
        for (id, title) in serverTitles {
            #expect(followerTitles[id] == title, "a device under the new keys reads \(id) in the clear")
        }

        // (4) And the near-empty copy is no longer near-empty: step 1 pulled
        // the whole server into it before a single key turned.
        let localAfter = try await nearEmpty.view.read { db in
            try Row.fetchAll(db, sql: "SELECT id, title FROM container WHERE deleted_at IS NULL")
                .reduce(into: [String: String]()) { acc, row in
                    let id: String = row["id"]; let title: String? = row["title"]; acc[id] = title
                }
        }
        for (id, title) in serverTitles {
            #expect(localAfter[id] == title, "the near-empty copy now holds \(id)")
        }
    }
}

// MARK: - 18o U5 (ledger row 16 — 17t item 2): the one existing Copy All rides the hoisted rule

extension PostureSwitchTests {
    /// 18o U5 — GUARD (green on the scaffolding tree and the fixed tree —
    /// the hoist is behaviour-neutral): the Castle / Replace All Keys
    /// ceremony's words screen, the ONE place Copy All existed before this
    /// unit, composes the hoisted `WordsCopyDoor` (the same `Button`, the
    /// same 60 s clear, now `WordsClipboard`'s), wired to ITS model's
    /// `markWordsCopied()`, and the caption renders after a copy. The drive
    /// uses a private pasteboard (`ComposedWordsCopyDoors.click`).
    @Test func theCeremonysWordsScreenKeepsItsCopyAllThroughTheOneRule() async throws {
        let world = try await makeWorld()
        defer { world.tearDown() }
        let controller = makeController(for: world)
        let tie = VaultTie(
            hasRecoveryWrap: true,
            verifyPassphrase: { _ in .match },
            verifyRecoveryWords: { _ in .match })
        let model = PostureSwitchModel(
            mode: .replaceKeys, runner: world.runner, controller: controller,
            vaultTie: tie, passphraseInHand: "sesame")
        await model.start()
        model.continueFromExplain()
        model.chooseGenerateNewWords()
        guard case .wordsShow(let words) = model.phase else {
            Issue.record("Generate New Ones shows twelve fresh words: \(model.phase)"); return
        }
        let sheet = PostureSwitchSheet(model: model, onDone: {})
        await SurfaceComposition.host(sheet, size: NSSize(width: 520, height: 560))
        #expect(!SurfaceComposition.carries(ProtectionCopy.wordsCopied, in: SurfaceComposition.text(of: sheet.body)))
        let door = try #require(ComposedWordsCopyDoors.find(in: sheet.body).first,
                                "the ceremony's words screen composes the ONE Copy All door")
        #expect(door.words == words)
        await ComposedWordsCopyDoors.click(door, expecting: words)
        #expect(model.copiedWords, "the door reports to the ceremony's model")
        #expect(SurfaceComposition.carries(ProtectionCopy.wordsCopied, in: SurfaceComposition.text(of: sheet.body)))
    }
}
