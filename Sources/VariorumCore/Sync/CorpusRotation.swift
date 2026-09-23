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
//     repeats until a pull finds NO row below the seq — and at the FIRST
//     empty window it WAITS PAST THE A5 VISIBILITY HORIZON and pulls once
//     more (the ladder's BLOCKER-1: a push that passed the old gate commits
//     below the seq but stays invisible to pulls for ≤ 2 s; a walk that
//     returned at its first empty window inside that window left the row
//     under a key completion then deleted everywhere — a permanently
//     wedged changefeed). Progress is reported as N of M for the
//     ceremony's text.
//   COMPLETION: one `key_vault_update` under the CURRENT proof clearing the
//     previous key, its id AND the seq together; the caller drops the
//     previous key from custody. The SERVER refuses the clearing write
//     (`VARIORUM_ROTATION_ROWS_REMAIN`) while any ciphertext-carrying row of
//     the account still sits below the seq — the client wait is the
//     insurance, the server guard the structure; the caller re-walks.
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

    /// 17l item 5 (RUN B batch B3; KnownIssues row 37 — her find at the
    /// pre-13x acceptance walk: *"I was asked to enter my passphrase
    /// again"*): derive for a ROTATION of `vault`, REUSING the vault's
    /// existing KDF descriptor when the typed passphrase is UNCHANGED —
    /// proven, never guessed from UI state: the key derived under the
    /// vault's own descriptor must open its passphrase-wrapped master
    /// copy. The same word under the same salt is the same derived key,
    /// so a sibling that opened its lobby by the passphrase still holds a
    /// key whose descriptor equals the vault's AFTER the rotation, and
    /// ledger 54's no-second-entry follow (the postures design §7 step 1
    /// "reused for the follow, never asked twice"; the runner's
    /// `follow(derivedPassphraseKey:kdf:)` descriptor-equality gate) now
    /// holds ACROSS Replace All Keys / entering Castle. The wrapped
    /// payload is the NEW master — cryptographically sound (the entry's
    /// letter: same secret, same salt, fresh content). A CHANGED word
    /// fails the unwrap and takes the fresh-salt road exactly as before
    /// (the pinned guard) — at the cost of one extra derivation, only on
    /// that rare deliberate act. `freshKDF` is that road's descriptor
    /// (tests inject a fast one, as with `derive(…kdf:)`).
    ///
    /// HER SCOPE LINE (2026-09-07, binding): the reuse applies to the
    /// PASSPHRASE wrap ONLY — the recovery key is derived fresh from the
    /// words given at THIS act, identically in both arms, and no part of
    /// the passphrase descriptor reaches that path (the independence pin).
    public static func derive(
        passphrase: String, recoveryWords: [String]?,
        forRotationOf vault: KeyVaultFormat,
        freshKDF: PassphraseKDF.Descriptor = .v1(salt: PassphraseKDF.randomSalt())
    ) throws -> RotationSecrets {
        guard !passphrase.isEmpty else { throw VaultEnrollmentError.emptyPassphrase }
        // The read-site discipline (`PassphraseKDF.Floor`): a descriptor
        // read from a vault is floor-checked before any derivation, so a
        // downgraded descriptor can never be perpetuated by the reuse.
        try vault.kdf.validateFloor()
        let underCurrent = try PassphraseKDF.deriveKey(passphrase: passphrase, descriptor: vault.kdf)
        guard (try? vault.unwrapMaster(withPassphraseKey: underCurrent)) != nil else {
            // The word is CHANGED (or was changed elsewhere): the fresh
            // random salt — the shipped behavior, byte-unchanged.
            return try derive(passphrase: passphrase, recoveryWords: recoveryWords, kdf: freshKDF)
        }
        let recoveryKey = try recoveryWords.map { try RecoveryPhrase.recoveryWrapKey(words: $0) }
        return RotationSecrets(passphraseKey: underCurrent, kdf: vault.kdf, recoveryKey: recoveryKey)
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
    /// The corpus key id the vault write advances to — stamped at
    /// `vaultWrite` BEFORE the write (F1, ledger 69: `CorpusRotation.prepare`
    /// mints it first) — so the resume tells EXACTLY whether the write that
    /// landed was this device's own (the vault's id equals it) or another
    /// device's rotation (it does not). Carried by every later step. nil
    /// on a marker written before F1 (the resume then falls back to the 5b
    /// device-name reading).
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
    /// lost, the resume retries. Also the runner's honest refusal when the
    /// server's completion guard refused three walks in a row (F1):
    /// `remaining` is what the last pull below the seq counted.
    case walkDidNotConverge(remaining: Int)
    /// pre-13x ladder round 1, F1 (BLOCKER-1): the server refused the
    /// clearing write `tries` times in a row (`rotationRowsRemain` — a
    /// ciphertext row of the account still below the seq that this
    /// device's pulls could not see, even after the wait past the
    /// horizon). Nothing is lost and nothing was cleared: the marker stays
    /// at `.reencrypt`, sync stays paused, the resume re-walks.
    case completionRefused(tries: Int)
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
    /// The bound on WORKING passes over the remainder — passes that found
    /// rows below the seq and re-encrypted them. The empty windows are not
    /// spent against it: neither the first (which waits past the A5
    /// visibility horizon and looks again) nor the one that ends the walk
    /// (pre-13x ladder round 2, F3 — NIT-N5: before F3 the wait's re-pull
    /// counted, so an empty window at exactly the last budgeted pass waited,
    /// continued and exited into `walkDidNotConverge(remaining: 0)`).
    public var maxPasses: Int
    /// N of M, after every batch.
    public var progress: (@Sendable (Progress) -> Void)?
    /// pre-13x ladder round 1, F1 (BLOCKER-1): THE WAIT PAST THE A5
    /// VISIBILITY HORIZON — run ONCE, at the walk's first empty window,
    /// before the pull that decides the walk is done. Production runs
    /// `Self.productionHorizonWait(transport:sleep:)` — it FETCHES the
    /// SERVED horizon (`visibilityHorizonMillis()` — the same server
    /// function that derives `sync_pull`'s filter, Phase 13y Shape 1) and
    /// sleeps `horizonWait(forServedMillis:)`'s derived duration; the
    /// pins inject the fake server's clock (`advanceClock`) — or nothing,
    /// to prove the server's guard alone. Injectable, never a hidden
    /// `Task.sleep` inside the loop, so the walk's timing is a fact a
    /// test can state.
    public var horizonWait: @Sendable () async throws -> Void

    /// Phase 13y (the R-13y-4 fork's ruling, Shape 1): the margin the
    /// production wait adds over the SERVED horizon — DERIVED, not
    /// invented: today's arithmetic is the retired hardcoded wait minus
    /// the mirror's constant (2500 − 2000 ms), kept as the slack that
    /// covered the horizon before the served read existed. A future
    /// horizon change moves the wait for free (served + this margin);
    /// only a deliberate re-derivation moves the margin.
    public static let horizonWaitMargin: Duration = .milliseconds(500)

    /// THE ONE DERIVATION (13y Shape 1, pinned): the production wait for
    /// a served horizon — served + margin. Nothing client-side hardcodes
    /// the old 2500 ms any more; this function is the only road from the
    /// server's answer to a wait.
    public static func horizonWait(forServedMillis served: Int64) -> Duration {
        .milliseconds(served) + horizonWaitMargin
    }

    /// THE PRODUCTION ROAD (13y Shape 1): fetch the served horizon from
    /// the transport, derive the wait, sleep it. `sleep` is the one
    /// injection point the duration pin observes; production passes the
    /// real `Task.sleep`. The init's nil `horizonWait` resolves to this.
    public static func productionHorizonWait(
        transport: any SyncRotationTransport,
        sleep: @escaping @Sendable (Duration) async throws -> Void = { try await Task.sleep(for: $0) }
    ) -> @Sendable () async throws -> Void {
        {
            let served = try await transport.visibilityHorizonMillis()
            try await sleep(horizonWait(forServedMillis: served))
        }
    }

    public init(
        transport: any SyncTransport & SyncRotationTransport,
        batchSize: Int = 200, maxPasses: Int = 8,
        progress: (@Sendable (Progress) -> Void)? = nil,
        horizonWait: (@Sendable () async throws -> Void)? = nil
    ) {
        self.transport = transport
        self.batchSize = batchSize
        self.maxPasses = maxPasses
        self.progress = progress
        // nil = the production road (13y): the served horizon + the
        // derived margin, through the real sleep.
        self.horizonWait = horizonWait ?? Self.productionHorizonWait(transport: transport)
    }

    // MARK: - BEGIN (§4 step 2) — the mint, then the write

    /// pre-13x ladder round 1, F1 (ledger 69): THE MINT, SPLIT FROM THE
    /// WRITE. What `begin` used to do inside one call is now two: `prepare`
    /// mints M′, C′ (+ J′) and their ids and builds the vault format — NO
    /// network, nothing written — so the caller can persist the NEW corpus
    /// key id in its marker BEFORE the write; `begin(client:current:
    /// prepared:)` then fetches, checks the door and writes. The resume of
    /// a `.vaultWrite` marker compares the vault's current corpus key id
    /// with the id the marker stamped: equal ⇒ this device's own write
    /// landed (custody did not); different ⇒ another device's rotation —
    /// exact, where the vault's `updated_by_device` could only guess (a
    /// follower's clearing write stamps ITS name over a landed write of
    /// ours — 5b's recorded corner). `Prepared` carries key material and
    /// is never persisted; a caller holds it for the span of one begin.
    public struct Prepared: Sendable {
        /// The new corpus key's id — what the marker stamps before the write.
        public let corpusKeyID: String
        let format: KeyVaultFormat
        let material: DeviceKeyMaterial
    }

    /// Mint the new keys and build the format `begin` will write. Pure of
    /// the network; `appleHeldCopy` non-nil keeps the Apple-held copy of M′
    /// (Standard's Replace All Keys — decision 30's pinned PRESENCE); nil
    /// writes none (entering Castle — the pinned ABSENCE).
    public static func prepare(
        current: DeviceKeyMaterial,
        secrets: RotationSecrets,
        appleHeldCopy: (key: SymmetricKey, id: String)?
    ) throws -> Prepared {
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
        let material = DeviceKeyMaterial(
            masterKey: master.data, corpusKey: corpus.data, corpusKeyID: corpusID,
            journalBridgeKey: journal.data, journalBridgeKeyID: journalID)
        return Prepared(corpusKeyID: corpusID, format: format, material: material)
    }

    /// The vault write that starts a rotation, authorized by the OLD proof,
    /// over keys `prepare` minted. Refuses at the door (decision 32) while
    /// the vault carries a previous corpus key, and (corner 30) when the
    /// vault's current corpus key id is not the one `current` holds — the
    /// account moved elsewhere; follow first. Returns the material to land
    /// in custody (M′ / C′ / J′ + the previous key and the seq read back
    /// off the receipt).
    public static func begin(
        client: KeyVaultClient,
        current: DeviceKeyMaterial,
        prepared: Prepared
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
        var format = prepared.format
        let receipt = try await client.updateVault(
            format, expectedRevision: fetched.revision, keyProof: oldProof)
        guard let seq = receipt.rotationStartedSeq else {
            throw CorpusRotationError.noRotationSeq
        }
        format.rotationStartedSeq = seq
        let material = prepared.material.carryingPreviousCorpusKey(
            current.corpusKey, keyID: current.corpusKeyID, startedSeq: seq)
        return Begun(material: material, format: format, receipt: receipt)
    }

    /// The one-call shape: `prepare` then `begin` — for callers with no
    /// marker to stamp between the two (the core pins, the attacker world).
    public static func begin(
        client: KeyVaultClient,
        current: DeviceKeyMaterial,
        secrets: RotationSecrets,
        appleHeldCopy: (key: SymmetricKey, id: String)?
    ) async throws -> Begun {
        try await begin(
            client: client, current: current,
            prepared: try prepare(current: current, secrets: secrets, appleHeldCopy: appleHeldCopy))
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
    /// the current corpus key; ends when a pull finds none — AFTER waiting
    /// past the A5 visibility horizon once (F1, BLOCKER-1: every row that
    /// can sit below the seq committed BEFORE the vault write, so one wait
    /// after the first empty window makes every straggler visible to the
    /// pull that follows; a row found then is re-encrypted and the next
    /// empty window ends the walk). Any device holding M′ (the material's
    /// `rotation` present) can run it; a crash mid-walk re-runs to
    /// completion — rows already replaced sit above the seq and are simply
    /// not found again.
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
        var waitedPastHorizon = false
        // F3 (NIT-N5): the budget counts WORKING passes — `report.passes`
        // still counts every pull (the report's honesty), but an empty
        // window costs nothing, so the wait's re-pull can never be the
        // pass that exhausts the budget.
        var workingPasses = 0
        while workingPasses < maxPasses {
            report.passes += 1
            let below = try await pullBelow(seq: rotation.startedSeq, keys: keys)
            if total == nil {
                total = below.count
                progress?(Progress(reencrypted: 0, total: below.count))
            }
            guard !below.isEmpty else {
                if !waitedPastHorizon {
                    // The first empty window: a row committed just before
                    // the vault write may still be inside the visibility
                    // window. Let it pass, then pull once more.
                    waitedPastHorizon = true
                    try await horizonWait()
                    continue
                }
                progress?(Progress(reencrypted: reencrypted, total: max(total ?? 0, reencrypted)))
                return report
            }
            workingPasses += 1
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
    /// stated). Idempotent: a vault already clear stays clear. The SERVER
    /// refuses the write with `KeyVaultClientError.rotationRowsRemain`
    /// while a ciphertext-carrying row of the account still sits below the
    /// seq (F1, BLOCKER-1) — the caller re-walks and calls again; nothing
    /// is cleared by a refused call.
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
