import CryptoKit
import Foundation
import GRDB

// pre-13x batch 2b — THE ROTATION'S SHARED DRIVER (the postures design §4
// steps 2–3, decisions 6 / 31 / 32; the BATCH 2 brief's "2b — REFINED AT
// 2a's SEAM" items (1a)–(1c)): what entering Castle, Replace All Keys
// (batch 3's door) and a FOLLOWER finishing a rotation (2c) all run.
// Productized from the 1b `RotationDrill` walk — the server semantics it
// proved (the seq rule, version-neutral `sync_reencrypt`, completion
// clearing the key and the seq together) are pinned in `KeyProofGateTests`;
// this file is the client's whole road over them, in `Sync/` because any
// device holding the new master must be able to run it.
//
// THE STEPS THIS FILE OWNS (the rest of §4 — the library re-key, custody,
// the snapshot, the insurance, the offer — is the app layer's runner):
//   BEGIN (§4 step 2): mint M′ and C′ (+ J′, the dormant class), rewrite the
//     vault in ONE `key_vault_update` authorized by the OLD proof — M′ under
//     P and under W (the secrets the ceremony obtained; the Apple-held copy
//     re-added ONLY where the caller keeps it — Standard's Replace All
//     Keys, never entering Castle), C′ under M′, the OLD C under M′ as the
//     previous corpus key, the proof hash replaced, the corpus key id
//     advanced (the fence), the rotation seq taken server-side and read
//     back off the receipt. The caller lands the returned material in
//     custody (M′ / C′ / the previous key + the seq) under the CURRENT shape.
//   THE WALK (§4 step 3): every row of this account BELOW the rotation seq
//     is pulled (device id nil — a walk is not a round), opened under the
//     previous key by the seq rule, re-sealed under C′ at the version it
//     was pulled at, and handed to `sync_reencrypt`; a row whose version
//     moved is skipped (it is already above the seq under C′); the walk
//     repeats until a pull finds NO row below the seq (the second pass
//     catches the A5 visibility window's stragglers). Progress is reported
//     as N of M for the ceremony's text.
//   COMPLETION: one `key_vault_update` under the CURRENT proof clearing the
//     previous key, its id AND the seq together; the caller drops the
//     previous key from custody.
// Any enrolled device can run THE WALK and COMPLETION: a follower reads M′
// from the vault by the passphrase (`materialFollowing`), C′ and the
// previous key under M′, and finishes what the acting device started.

/// The secrets a rotation wraps the NEW master under (design §4 step 2:
/// "M′ under P and under W"): the passphrase-derived key with the FRESH
/// descriptor it was derived under, and the recovery-derived key (nil
/// where the vault will carry no recovery wrap — the caller's ceremony
/// decides; see the batch record's question 1). Derived by the caller
/// OFF the main actor (Argon2id — tenths of a second).
public struct RotationSecrets: Sendable {
    public let passphraseKey: SymmetricKey
    public let kdf: PassphraseKDF.Descriptor
    public let recoveryKey: SymmetricKey?

    public init(passphraseKey: SymmetricKey, kdf: PassphraseKDF.Descriptor, recoveryKey: SymmetricKey?) {
        self.passphraseKey = passphraseKey
        self.kdf = kdf
        self.recoveryKey = recoveryKey
    }

    /// Derive from the typed words: a fresh v1 descriptor for the
    /// passphrase (a new salt — the wrap is fresh), the recovery key from
    /// the twelve words when given. The heavy hop; callers run it off-main.
    public static func derive(
        passphrase: String, recoveryWords: [String]?,
        kdf: PassphraseKDF.Descriptor = .v1(salt: PassphraseKDF.randomSalt())
    ) throws -> RotationSecrets {
        guard !passphrase.isEmpty else { throw VaultEnrollmentError.emptyPassphrase }
        let passphraseKey = try PassphraseKDF.deriveKey(passphrase: passphrase, descriptor: kdf)
        let recoveryKey = try recoveryWords.map { try RecoveryPhrase.recoveryWrapKey(words: $0) }
        return RotationSecrets(passphraseKey: passphraseKey, kdf: kdf, recoveryKey: recoveryKey)
    }
}

/// THE PER-STEP PERSISTED MARKER (§4's "a persisted marker (the
/// `AccountRekeyMarker` pattern) re-runs a crash at any step to completion
/// on the acting device"; the brief's item (1d)): written BEFORE the vault
/// write, advanced at each step, cleared only after the last — so a crash
/// or a thrown failure anywhere leaves it set across relaunches, every
/// engine round refuses while it is set (`SyncError.accountRekeyIncomplete`),
/// and the runner RESUMES AT THE FAILED STEP rather than starting over.
///
/// It lives in the LOCAL-ONLY `sync_state` keyspace under the key SyncSpec
/// §3 already documents (`rekey_in_progress`), per device by construction.
/// Its value carries NON-SECRET facts only — the step, whether the road
/// enters Castle, the old and new LIBRARY-key fingerprints (public: what the
/// key files are named by), the new corpus key id — never a key; a resume
/// finds every key it needs in custody or in the key file's wrapped copies.
public struct RotationMarker: Codable, Equatable, Sendable {
    /// The road's steps, in §4's order. The marker names the step that is
    /// IN PROGRESS (not yet complete); a resume re-runs from it.
    public enum Step: String, Codable, CaseIterable, Sendable {
        /// §4 step 2 — the vault write (set BEFORE it: a lost response is
        /// ambiguous, and the resume re-reads the vault to tell).
        case vaultWrite
        /// §4 step 3 — the walk (this device holds M′; any M′-holder can
        /// finish it).
        case reencrypt
        /// §4 step 4 — the library's export-and-swap under L′.
        case rekeyLibrary
        /// §4 step 5 — custody moved to the target shape (both items).
        case custody
        /// §4 step 6 — the fresh snapshot pair + the insurance off.
        case snapshot
        /// §4 step 7 — the offer (the last step; clearing follows it).
        case offer
    }

    public var step: Step
    public var entersCastle: Bool
    /// The library key the road STARTED under (the file the old key file
    /// names) and the one it ends under (the NEW key file's name) — set at
    /// `rekeyLibrary`, nil before.
    public var oldKeyFingerprint: String?
    public var newKeyFingerprint: String?
    /// The corpus key id the vault write advanced to (set at `vaultWrite`,
    /// before the write) — the resume compares it with the vault's to tell
    /// whether the write landed.
    public var newCorpusKeyID: String?
    /// The device word + day the notices name (display only — never
    /// ordering). ISO-8601.
    public var startedAt: String
    /// pre-13x 2d.4 (the orchestrator's ruling 3): this road is a FOLLOW —
    /// a resume from any step still retires the old key files at its end
    /// (the exposure's closure cannot depend on the process surviving).
    /// Optional so a marker written before the flag decodes (nil = not a
    /// follow — the ceremony's road, which keeps its old file by 2b).
    public var follow: Bool?

    public init(
        step: Step, entersCastle: Bool,
        oldKeyFingerprint: String? = nil, newKeyFingerprint: String? = nil,
        newCorpusKeyID: String? = nil, startedAt: String, follow: Bool? = nil
    ) {
        self.step = step
        self.entersCastle = entersCastle
        self.oldKeyFingerprint = oldKeyFingerprint
        self.newKeyFingerprint = newKeyFingerprint
        self.newCorpusKeyID = newCorpusKeyID
        self.startedAt = startedAt
        self.follow = follow
    }

    /// Whether this marker's road is a follow (the flag, defaulted).
    public var isFollow: Bool { follow == true }

    /// SyncSpec §3's documented local-only key (the 14c marker's, kept).
    public static let key = "rekey_in_progress"

    /// The marker, decoded; nil when none is set. A value this build cannot
    /// decode (a 14c-era wall-clock stamp) still counts as SET for the
    /// engine's refusal (`isSet`) and reads as a `.vaultWrite` marker here
    /// — the resume's most conservative reading.
    public static func read(_ db: Database) throws -> RotationMarker? {
        guard let value = try String.fetchOne(
            db, sql: "SELECT value FROM sync_state WHERE key = ?", arguments: [key])
        else { return nil }
        if let marker = try? JSONDecoder().decode(RotationMarker.self, from: Data(value.utf8)) {
            return marker
        }
        return RotationMarker(step: .vaultWrite, entersCastle: false, startedAt: value)
    }

    public static func write(_ marker: RotationMarker, _ db: Database) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let value = String(decoding: try encoder.encode(marker), as: UTF8.self)
        try db.execute(
            sql: "INSERT OR REPLACE INTO sync_state (key, value) VALUES (?, ?)",
            arguments: [key, value])
    }

    public static func clear(_ db: Database) throws {
        try db.execute(sql: "DELETE FROM sync_state WHERE key = ?", arguments: [key])
    }

    public static func isSet(_ db: Database) throws -> Bool {
        try String.fetchOne(
            db, sql: "SELECT value FROM sync_state WHERE key = ?", arguments: [key]) != nil
    }

    /// The marker advanced to `step` (the same facts).
    public func advanced(to step: Step) -> RotationMarker {
        var next = self
        next.step = step
        return next
    }
}

/// The driver's typed refusals (the door-side sentences are the copy
/// file's; these are the mechanisms).
public enum CorpusRotationError: Error, Equatable, Sendable {
    /// Decision 32 — the vault carries a previous corpus key: a rotation
    /// started (on `startedByDeviceHint`, if the caller knows) is still
    /// finishing; any device holding the new master can finish it; a
    /// second never starts.
    case rotationInProgress(previousKeyID: String)
    /// The vault's current corpus key id is not the one this device holds
    /// — the account's keys were replaced elsewhere (the stale-master
    /// front check, corner 30): follow first.
    case staleMaster(vaultKeyID: String, heldKeyID: String)
    /// The vault write landed no rotation seq — the payload carried no
    /// previous key (a programming error, never a user state).
    case noRotationSeq
    /// The walk was asked to run with no rotation in the material.
    case noRotationInMaterial
    /// The walk never reached an empty window within its pass budget — a
    /// row below the seq kept refusing (`skipped` on every pass); nothing is
    /// lost, the resume retries.
    case walkDidNotConverge(remaining: Int)
}

/// THE SHARED DRIVER.
public struct CorpusRotation: Sendable {
    /// N of M for the ceremony's text: rows re-encrypted so far, rows the
    /// first pass found below the seq (the whole pre-rotation corpus, once).
    public struct Progress: Equatable, Sendable {
        public var reencrypted: Int
        public var total: Int
        public init(reencrypted: Int, total: Int) {
            self.reencrypted = reencrypted
            self.total = total
        }
    }

    /// What the walk did.
    public struct WalkReport: Equatable, Sendable {
        public var replaced = 0
        public var skipped = 0
        public var passes = 0
        public init() {}
    }

    /// What BEGIN returns: the material to land in custody (M′, C′, J′, the
    /// previous key + the seq), the format as written (the seq read back),
    /// and the receipt.
    public struct Begun: Sendable {
        public let material: DeviceKeyMaterial
        public let format: KeyVaultFormat
        public let receipt: KeyVaultClient.UpdateReceipt
    }

    public let transport: any SyncTransport & SyncRotationTransport
    /// Rows per pull window / re-encrypt batch (transport granularity).
    public var batchSize: Int
    /// The bound on passes over the remainder (each pass ends at an empty
    /// window or re-encrypts what it found; the second pass exists for the
    /// A5 visibility window).
    public var maxPasses: Int
    /// N of M, after every batch.
    public var progress: (@Sendable (Progress) -> Void)?

    public init(
        transport: any SyncTransport & SyncRotationTransport,
        batchSize: Int = 200, maxPasses: Int = 8,
        progress: (@Sendable (Progress) -> Void)? = nil
    ) {
        self.transport = transport
        self.batchSize = batchSize
        self.maxPasses = maxPasses
        self.progress = progress
    }

    // MARK: - BEGIN (§4 step 2)

    /// The vault write that starts a rotation, authorized by the OLD proof.
    /// Refuses at the door (decision 32) while the vault carries a previous
    /// corpus key, and (corner 30) when the vault's current corpus key id is
    /// not the one `current` holds — the account moved elsewhere; follow
    /// first. `appleHeldCopy` non-nil keeps the Apple-held copy of M′ (the
    /// vault's `master_wrapped_by_apple_held` — Standard's Replace All Keys;
    /// decision 30's pinned PRESENCE); nil writes none (entering Castle —
    /// the pinned ABSENCE).
    public static func begin(
        client: KeyVaultClient,
        current: DeviceKeyMaterial,
        secrets: RotationSecrets,
        appleHeldCopy: (key: SymmetricKey, id: String)?
    ) async throws -> Begun {
        guard let fetched = try await client.fetchVault() else {
            throw KeyVaultClientError.vaultAbsent
        }
        if let previous = fetched.format.previousCorpusKey {
            throw CorpusRotationError.rotationInProgress(previousKeyID: previous.keyID)
        }
        let vaultKeyID = fetched.format.classKey(for: .corpus)?.keyID ?? ""
        guard vaultKeyID == current.corpusKeyID else {
            throw CorpusRotationError.staleMaster(vaultKeyID: vaultKeyID, heldKeyID: current.corpusKeyID)
        }
        // The OLD master's proof authorizes the ONE write that installs
        // the new hash (decision 12); the old proof is refused from then on.
        let oldProof = KeyProof.wireToken(master: current.masterSymmetricKey)

        let master = SymmetricKey(size: .bits256)
        let corpus = SymmetricKey(size: .bits256)
        let journal = SymmetricKey(size: .bits256)
        let corpusID = UUID().uuidString.lowercased()
        let journalID = UUID().uuidString.lowercased()
        var format = try KeyVaultFormat.create(
            masterKey: master,
            passphraseKey: secrets.passphraseKey,
            recoveryKey: secrets.recoveryKey,
            classKeys: [
                (keyClass: .corpus, keyID: corpusID, key: corpus),
                (keyClass: .journalBridge, keyID: journalID, key: journal),
            ],
            kdf: secrets.kdf)
        // The OLD corpus key under the NEW master, for the rotation's
        // duration (decision 6) — its id in its own column (decision 31).
        format = try format.carryingPreviousCorpusKey(
            current.corpusSymmetricKey, keyID: current.corpusKeyID, masterKey: master)
        if let appleHeldCopy {
            format = try format.settingAppleHeldCopy(
                masterKey: master, appleKey: appleHeldCopy.key, appleKeyID: appleHeldCopy.id)
        }
        let receipt = try await client.updateVault(
            format, expectedRevision: fetched.revision, keyProof: oldProof)
        guard let seq = receipt.rotationStartedSeq else {
            throw CorpusRotationError.noRotationSeq
        }
        format.rotationStartedSeq = seq
        let material = DeviceKeyMaterial(
            masterKey: master.data, corpusKey: corpus.data, corpusKeyID: corpusID,
            journalBridgeKey: journal.data, journalBridgeKeyID: journalID
        ).carryingPreviousCorpusKey(current.corpusKey, keyID: current.corpusKeyID, startedSeq: seq)
        return Begun(material: material, format: format, receipt: receipt)
    }

    // MARK: - THE FOLLOWER'S KEY READ (§7 step 3; 2c calls it)

    /// The material a device holding the vault's MASTER (unwrapped by the
    /// passphrase or the words, or held in custody) derives from the
    /// fetched format: the class keys under M, and — while the vault
    /// carries one — the previous corpus key + the rotation seq, so the
    /// follower opens pre-rotation rows and can finish the walk. Nothing is
    /// unwrapped on the server.
    public static func materialFollowing(
        _ vault: KeyVaultFormat, master: SymmetricKey
    ) throws -> DeviceKeyMaterial {
        guard let corpusEntry = vault.classKey(for: .corpus) else {
            throw KeyVaultError.unknownClassKey(.corpus)
        }
        guard let journalEntry = vault.classKey(for: .journalBridge) else {
            throw KeyVaultError.unknownClassKey(.journalBridge)
        }
        let corpus = try vault.unwrapClassKey(.corpus, masterKey: master)
        let journal = try vault.unwrapClassKey(.journalBridge, masterKey: master)
        var material = DeviceKeyMaterial(
            masterKey: master.data,
            corpusKey: corpus.data, corpusKeyID: corpusEntry.keyID,
            journalBridgeKey: journal.data, journalBridgeKeyID: journalEntry.keyID)
        if vault.previousCorpusKey != nil, let seq = vault.rotationStartedSeq {
            let previous = try vault.unwrapPreviousCorpusKey(masterKey: master)
            material = material.carryingPreviousCorpusKey(
                previous.key.data, keyID: previous.keyID, startedSeq: seq)
        }
        return material
    }

    // MARK: - THE WALK (§4 step 3)

    /// Re-encrypt every row of this account below the rotation seq under
    /// the current corpus key; ends when a pull finds none. Any device
    /// holding M′ (the material's `rotation` present) can run it; a crash
    /// mid-walk re-runs to completion — rows already replaced sit above the
    /// seq and are simply not found again.
    @discardableResult
    public func reencryptRemainder(material: DeviceKeyMaterial) async throws -> WalkReport {
        guard let rotation = material.rotation else {
            throw CorpusRotationError.noRotationInMaterial
        }
        let keys = material.syncKeys
        let crypto = SyncPayloadCrypto(keys: keys)
        var report = WalkReport()
        var total: Int?
        var reencrypted = 0
        while report.passes < maxPasses {
            report.passes += 1
            let below = try await pullBelow(seq: rotation.startedSeq, keys: keys)
            if total == nil {
                total = below.count
                progress?(Progress(reencrypted: 0, total: below.count))
            }
            guard !below.isEmpty else {
                progress?(Progress(reencrypted: reencrypted, total: max(total ?? 0, reencrypted)))
                return report
            }
            // M grows to what later passes find (the visibility window's
            // stragglers) — N never exceeds M on the ceremony's line.
            total = max(total ?? 0, reencrypted + below.count)
            var index = 0
            while index < below.count {
                let chunk = Array(below[index..<min(index + batchSize, below.count)])
                index += chunk.count
                // Opened under the PREVIOUS key by the seq rule; re-sealed
                // under the CURRENT key at the version it was pulled at.
                let resealed = try chunk.map { pulled in
                    try crypto.encryptForWire(try crypto.decryptFromWire(pulled).row)
                }
                let outcomes = try await transport.reencrypt(
                    resealed, activeKeyID: keys.corpusKeyID, keyProof: keys.keyProof)
                for outcome in outcomes {
                    switch outcome {
                    case .replaced:
                        report.replaced += 1
                        reencrypted += 1
                    case .skipped:
                        report.skipped += 1
                    }
                }
                progress?(Progress(
                    reencrypted: reencrypted, total: max(total ?? 0, reencrypted)))
            }
        }
        // The pass budget ran out with rows still below the seq.
        let remaining = try await pullBelow(seq: rotation.startedSeq, keys: keys).count
        throw CorpusRotationError.walkDidNotConverge(remaining: remaining)
    }

    /// The rows still below the rotation seq (the bounded remainder pull —
    /// device id nil: a walk is not a round and records no cursor).
    private func pullBelow(seq: Int64, keys: SyncEncryptionKeys) async throws -> [SyncPulledRow] {
        var cursor: Int64 = 0
        var below: [SyncPulledRow] = []
        while true {
            let window = try await transport.pull(
                since: cursor, limit: batchSize, activeKeyID: keys.corpusKeyID,
                keyProof: keys.keyProof, deviceID: nil)
            guard !window.isEmpty else { break }
            below.append(contentsOf: window.filter { $0.serverSeq < seq })
            // The feed is seq-ordered: past the rotation seq nothing more is
            // under the previous key.
            if window.last!.serverSeq >= seq { break }
            cursor = window.last!.serverSeq
        }
        return below
    }

    // MARK: - COMPLETION

    /// The clearing write under the CURRENT proof: the previous key, its
    /// id and the seq go together (pinned server-side by 1b). Returns the
    /// material with the previous key dropped — what the caller lands in
    /// custody. Refuses when the vault has moved to another corpus key
    /// (a second rotation elsewhere — impossible while ours stands, but
    /// stated). Idempotent: a vault already clear stays clear.
    public static func complete(
        client: KeyVaultClient, material: DeviceKeyMaterial
    ) async throws -> DeviceKeyMaterial {
        guard let fetched = try await client.fetchVault() else {
            throw KeyVaultClientError.vaultAbsent
        }
        let vaultKeyID = fetched.format.classKey(for: .corpus)?.keyID ?? ""
        guard vaultKeyID == material.corpusKeyID else {
            throw CorpusRotationError.staleMaster(vaultKeyID: vaultKeyID, heldKeyID: material.corpusKeyID)
        }
        if fetched.format.previousCorpusKey != nil {
            try await client.updateVault(
                fetched.format.clearingPreviousCorpusKey(),
                expectedRevision: fetched.revision,
                keyProof: KeyProof.wireToken(master: material.masterSymmetricKey))
        }
        return material.clearingPreviousCorpusKey()
    }
}
