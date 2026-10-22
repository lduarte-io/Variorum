import CryptoKit
import Foundation

/// The unwrapped key material one enrolled device holds (Phase 14b —
/// rulings R-6/R-8). Custody is the CALLER's — 14b's app persisted this to the
/// device Keychain (that custody left with today's road at VX-329 U1) and the
/// `vault-bootstrap` runner (deleted at VX-329's ladder round 1) held it in
/// memory only; today's callers are the core's test worlds, which hold it in
/// memory. Codable so a Keychain item could be one JSON blob, exactly the
/// `AuthTokens` custody pattern.
public struct DeviceKeyMaterial: Codable, Equatable, Sendable {
    /// The master key — held so the recovery-phrase generation and
    /// passphrase changes work without re-entering the passphrase (Round
    /// 7's traced mechanism: "the Mac keeps master in its KEYCHAIN — so the
    /// morning phrase generation works regardless").
    public var masterKey: Data
    public var corpusKey: Data
    public var corpusKeyID: String
    public var journalBridgeKey: Data
    public var journalBridgeKeyID: String
    /// pre-13x 2b (decisions 6 / 31 — the 1b hand-forward): while a
    /// rotation is finishing, the PREVIOUS corpus key, its id, and the
    /// server's rotation seq ride custody beside the new keys — the seam
    /// opens a row below the seq under the previous key (`RotationInProgress`),
    /// and the driver re-encrypts what is left. All three nil outside a
    /// rotation (a custody blob written before 2b decodes with them nil).
    /// Dropped together by `clearingPreviousCorpusKey()` at completion.
    public var previousCorpusKey: Data?
    public var previousCorpusKeyID: String?
    public var rotationStartedSeq: Int64?

    public init(
        masterKey: Data, corpusKey: Data, corpusKeyID: String,
        journalBridgeKey: Data, journalBridgeKeyID: String,
        previousCorpusKey: Data? = nil, previousCorpusKeyID: String? = nil,
        rotationStartedSeq: Int64? = nil
    ) {
        self.masterKey = masterKey
        self.corpusKey = corpusKey
        self.corpusKeyID = corpusKeyID
        self.journalBridgeKey = journalBridgeKey
        self.journalBridgeKeyID = journalBridgeKeyID
        self.previousCorpusKey = previousCorpusKey
        self.previousCorpusKeyID = previousCorpusKeyID
        self.rotationStartedSeq = rotationStartedSeq
    }

    public var masterSymmetricKey: SymmetricKey { SymmetricKey(data: masterKey) }
    public var corpusSymmetricKey: SymmetricKey { SymmetricKey(data: corpusKey) }
    public var journalBridgeSymmetricKey: SymmetricKey { SymmetricKey(data: journalBridgeKey) }

    /// The rotation as the seam needs it — present only when ALL THREE
    /// fields are (both-or-neither, by construction).
    public var rotation: RotationInProgress? {
        guard let previousCorpusKey, let previousCorpusKeyID, let rotationStartedSeq else { return nil }
        return RotationInProgress(
            previousCorpusKey: SymmetricKey(data: previousCorpusKey),
            previousCorpusKeyID: previousCorpusKeyID, startedSeq: rotationStartedSeq)
    }

    /// The round's keys: the current corpus key, the proof MATERIAL from
    /// the master (kp1 + kp2 — 13y UNIT B), and the rotation while one is
    /// finishing.
    public var syncKeys: SyncEncryptionKeys {
        SyncEncryptionKeys(
            corpusKey: corpusSymmetricKey, corpusKeyID: corpusKeyID,
            keyProof: KeyProofMaterial(master: masterSymmetricKey),
            rotation: rotation)
    }

    /// Carry the previous corpus key for a rotation's duration.
    public func carryingPreviousCorpusKey(
        _ key: Data, keyID: String, startedSeq: Int64
    ) -> DeviceKeyMaterial {
        var carried = self
        carried.previousCorpusKey = key
        carried.previousCorpusKeyID = keyID
        carried.rotationStartedSeq = startedSeq
        return carried
    }

    /// Completion: the previous key, its id and the seq go TOGETHER.
    public func clearingPreviousCorpusKey() -> DeviceKeyMaterial {
        var cleared = self
        cleared.previousCorpusKey = nil
        cleared.previousCorpusKeyID = nil
        cleared.rotationStartedSeq = nil
        return cleared
    }
}

/// How a master-unwrapping act is authorized (Round 7's scope addition:
/// CHANGE PASSPHRASE is authorized by EITHER the current passphrase OR the
/// recovery phrase — the forgot-passphrase road).
public enum VaultAuthorization: Sendable {
    case passphrase(String)
    case recoveryPhrase([String])
}

/// The enrollment/setup/change flows' ONE brain (Phase 14b batch 3, ledger
/// L9): pure orchestration over `KeyVaultClient` + the `Crypto/` substrate.
/// It was shared verbatim by the Mac app, the phone (PL-6) and the
/// `vault-bootstrap` runner; the apps' flows left with today's road at VX-329
/// U1 and the runner at VX-329's ladder round 1, so it is KEPT as the core
/// test worlds' vault-setup brain (`AccountLifecycleTests`' world,
/// `ScriptedVaultServer`'s `VaultTestWorld`, `VaultEnrollmentTests`).
/// Custody is deliberately NOT here (the caller's).
///
/// The KDF call is the heavy step (~64 MiB transient, tenths of a second,
/// R-7): it runs in these nonisolated async functions — OFF the main actor
/// by construction — and only at setup/enrollment/change cadence (R-6).
/// Every derivation is measured and reported through `kdfMeasurement` so
/// the flows can log/display the number the gate reads off (L12).
public struct VaultEnrollment: Sendable {
    public let client: KeyVaultClient
    /// Called with each passphrase-KDF derivation's wall-clock seconds
    /// (L12 — the gate reads the on-device number off the flow's surface).
    public var kdfMeasurement: (@Sendable (TimeInterval) -> Void)?

    public init(
        client: KeyVaultClient,
        kdfMeasurement: (@Sendable (TimeInterval) -> Void)? = nil
    ) {
        self.client = client
        self.kdfMeasurement = kdfMeasurement
    }

    // MARK: - Setup (first device)

    /// Create the account's vault: mint master + the two v1 class keys
    /// (R-8), wrap master under the passphrase-KDF key, and insert the row.
    /// **Passphrase wrap ONLY** (Round 5): the recovery wrap is added later,
    /// in the author's presence, through `landRecoveryWrap` — the phrase's
    /// whole point is being seen once and written down.
    /// Refuses when a vault already exists (`KeyVaultClientError
    /// .vaultAlreadyExists` — never overwrite).
    public func setUp(passphrase: String) async throws -> DeviceKeyMaterial {
        guard !passphrase.isEmpty else { throw VaultEnrollmentError.emptyPassphrase }
        // Pre-check for a clean refusal (the create's 409 is the backstop
        // for the race — idempotence by refusal either way).
        if try await client.fetchVault() != nil {
            throw KeyVaultClientError.vaultAlreadyExists
        }
        let master = SymmetricKey(size: .bits256)
        let corpus = SymmetricKey(size: .bits256)
        let journal = SymmetricKey(size: .bits256)
        let corpusID = UUID().uuidString.lowercased()
        let journalID = UUID().uuidString.lowercased()
        let descriptor = PassphraseKDF.Descriptor.v1(salt: PassphraseKDF.randomSalt())
        let passphraseKey = try measuredDerive(passphrase: passphrase, descriptor: descriptor)
        let format = try KeyVaultFormat.create(
            masterKey: master,
            passphraseKey: passphraseKey,
            recoveryKey: nil,
            classKeys: [
                (keyClass: .corpus, keyID: corpusID, key: corpus),
                (keyClass: .journalBridge, keyID: journalID, key: journal),
            ],
            kdf: descriptor)
        try await client.createVault(format)
        return DeviceKeyMaterial(
            masterKey: master.data, corpusKey: corpus.data, corpusKeyID: corpusID,
            journalBridgeKey: journal.data, journalBridgeKeyID: journalID)
    }

    /// pre-13x 3a — SYNC SETUP's ONE road (the postures design decision 5,
    /// §5's Set-up-sync row, corner 26): the vault is BORN with its
    /// passphrase wrap, its recovery wrap (the twelve words in hand —
    /// generated + confirmed, or typed and verified against the library's
    /// key file) and, under a STANDARD library, the Apple-held copy of the
    /// master under the iCloud key — ONE row, the proof hash included. The
    /// 14b "passphrase wrap only, the wrap lands later" shape retires for
    /// this door (`landRecoveryWrap`'s add arm stays for the regenerate
    /// door and the store-side follow). `kdf` is the passphrase wrap's
    /// descriptor — the app passes the key file's current one so the
    /// vault's M-wrap and the file's L-wrap share one derivation (§3.6's
    /// derive-once at birth); a fresh v1 descriptor by default.
    public func setUp(
        passphrase: String, recoveryWords: [String],
        appleHeldCopy: (key: SymmetricKey, id: String)?,
        kdf: PassphraseKDF.Descriptor = .v1(salt: PassphraseKDF.randomSalt())
    ) async throws -> DeviceKeyMaterial {
        guard !passphrase.isEmpty else { throw VaultEnrollmentError.emptyPassphrase }
        let recoveryKey = try RecoveryPhrase.recoveryWrapKey(words: recoveryWords)
        if try await client.fetchVault() != nil {
            throw KeyVaultClientError.vaultAlreadyExists
        }
        let master = SymmetricKey(size: .bits256)
        let corpus = SymmetricKey(size: .bits256)
        let journal = SymmetricKey(size: .bits256)
        let corpusID = UUID().uuidString.lowercased()
        let journalID = UUID().uuidString.lowercased()
        let passphraseKey = try measuredDerive(passphrase: passphrase, descriptor: kdf)
        var format = try KeyVaultFormat.create(
            masterKey: master,
            passphraseKey: passphraseKey,
            recoveryKey: recoveryKey,
            classKeys: [
                (keyClass: .corpus, keyID: corpusID, key: corpus),
                (keyClass: .journalBridge, keyID: journalID, key: journal),
            ],
            kdf: kdf)
        if let appleHeldCopy {
            format = try format.settingAppleHeldCopy(
                masterKey: master, appleKey: appleHeldCopy.key, appleKeyID: appleHeldCopy.id)
        }
        try await client.createVault(format)
        return DeviceKeyMaterial(
            masterKey: master.data, corpusKey: corpus.data, corpusKeyID: corpusID,
            journalBridgeKey: journal.data, journalBridgeKeyID: journalID)
    }

    // MARK: - Enrollment (new device — R-4: passphrase entry is v1's road)

    /// Sign-in → type the passphrase → unwrap master → class keys. A wrong
    /// passphrase speaks (`wrongPassphrase`), never crashes; an absent
    /// vault speaks (`vaultAbsent` — no setup has run for this account).
    public func enroll(passphrase: String) async throws -> DeviceKeyMaterial {
        guard !passphrase.isEmpty else { throw VaultEnrollmentError.emptyPassphrase }
        let vault = try await fetchRequiredVault().format
        let passphraseKey = try measuredDerive(passphrase: passphrase, descriptor: vault.kdf)
        let master: SymmetricKey
        do {
            master = try vault.unwrapMaster(withPassphraseKey: passphraseKey)
        } catch KeyVaultError.unwrapFailed {
            // RFC 3394 makes wrong-key and tampered-wrap indistinguishable
            // by design; the overwhelmingly likely cause is the typo.
            throw VaultEnrollmentError.wrongPassphrase
        }
        return try material(from: vault, master: master)
    }

    /// The disaster road (R-5): the 12 written words alone unwrap master.
    /// Phrase validation errors (checksum, unknown word, wrong count) speak
    /// as themselves — the UX points at the typo. Refuses when the vault
    /// has no recovery wrap yet (the Round-5 overnight state).
    public func enroll(recoveryWords: [String]) async throws -> DeviceKeyMaterial {
        let recoveryKey = try RecoveryPhrase.recoveryWrapKey(words: recoveryWords)
        let vault = try await fetchRequiredVault().format
        let master: SymmetricKey
        do {
            master = try vault.unwrapMaster(withRecoveryKey: recoveryKey)
        } catch KeyVaultError.unwrapFailed {
            throw VaultEnrollmentError.wrongRecoveryPhrase
        }
        return try material(from: vault, master: master)
    }

    // MARK: - The recovery wrap ((RE)GENERATE — Rounds 5 + 7)

    /// Whether the account's vault carries a recovery wrap yet (drives the
    /// flows' offer: absent ⇒ GENERATE, present ⇒ the deliberate REPLACE).
    public func hasRecoveryWrap() async throws -> Bool {
        try await fetchRequiredVault().format.masterWrappedByRecovery != nil
    }

    /// Land the CONFIRMED 12 words as the vault's recovery wrap. The flow's
    /// order is ruled (Round 5 item 3): generate → she writes them down →
    /// confirm by re-entry → THEN the wrap lands — so this takes the words
    /// the author re-entered, never the freshly-generated set directly.
    ///
    /// First generation (wrap absent) rides `addingRecoveryWrap` — the
    /// strict add-only door, master verified against the vault's class keys.
    /// REPLACING an existing wrap is the deliberate ceremony Round 7 ruled
    /// ((RE)GENERATE is one surface): it requires `allowReplace: true`,
    /// which the UI passes only after its explicit confirm — without it the
    /// batch-1 refusal (`recoveryWrapAlreadyPresent`) stands.
    public func landRecoveryWrap(
        words: [String], material: DeviceKeyMaterial, allowReplace: Bool = false
    ) async throws {
        let recoveryKey = try RecoveryPhrase.recoveryWrapKey(words: words)
        let fetched = try await fetchRequiredVault()
        let vault = fetched.format
        let updated: KeyVaultFormat
        if vault.masterWrappedByRecovery == nil {
            updated = try vault.addingRecoveryWrap(
                masterKey: material.masterSymmetricKey, recoveryKey: recoveryKey)
        } else {
            guard allowReplace else { throw KeyVaultError.recoveryWrapAlreadyPresent }
            updated = try vault.replacingRecoveryWrap(
                masterKey: material.masterSymmetricKey, recoveryKey: recoveryKey)
        }
        // The update rides THIS fetch's revision token (R1-2): a vault
        // another device moved since the fetch refuses as
        // `vaultRevisionConflict` — never a silent phrase revert. And the
        // proof (pre-13x): the held master authorizes the write.
        try await client.updateVault(
            updated, expectedRevision: fetched.revision,
            keyProof: KeyProofMaterial(master: material.masterSymmetricKey))
    }

    // MARK: - Change passphrase (Round 7's scope addition)

    /// Re-wrap master under a NEW passphrase-derived key: authorize by the
    /// current passphrase OR the recovery phrase, mint a fresh salt +
    /// descriptor, wrap, update the vault row. The recovery words are
    /// UNTOUCHED by a passphrase change — independent wraps — and the
    /// class keys never change (R-7's soft door: a passphrase change is a
    /// one-key re-wrap, never a corpus re-encrypt).
    ///
    /// Returns the unwrapped material: the forgot-passphrase road (recovery
    /// authorization on an unenrolled device) both fixes the passphrase and
    /// enrolls in one act — the caller decides custody, as everywhere.
    @discardableResult
    public func changePassphrase(
        authorizedBy authorization: VaultAuthorization, newPassphrase: String
    ) async throws -> DeviceKeyMaterial {
        guard !newPassphrase.isEmpty else { throw VaultEnrollmentError.emptyPassphrase }
        let fetched = try await fetchRequiredVault()
        let vault = fetched.format
        let master: SymmetricKey
        switch authorization {
        case .passphrase(let current):
            guard !current.isEmpty else { throw VaultEnrollmentError.emptyPassphrase }
            let currentKey = try measuredDerive(passphrase: current, descriptor: vault.kdf)
            do {
                master = try vault.unwrapMaster(withPassphraseKey: currentKey)
            } catch KeyVaultError.unwrapFailed {
                throw VaultEnrollmentError.wrongPassphrase
            }
        case .recoveryPhrase(let words):
            let recoveryKey = try RecoveryPhrase.recoveryWrapKey(words: words)
            do {
                master = try vault.unwrapMaster(withRecoveryKey: recoveryKey)
            } catch KeyVaultError.unwrapFailed {
                throw VaultEnrollmentError.wrongRecoveryPhrase
            }
        }
        let descriptor = PassphraseKDF.Descriptor.v1(salt: PassphraseKDF.randomSalt())
        let newKey = try measuredDerive(passphrase: newPassphrase, descriptor: descriptor)
        var updated = vault
        updated.kdf = descriptor
        do {
            updated.masterWrappedByPassphrase = try AES.KeyWrap.wrap(master, using: newKey)
        } catch {
            throw KeyVaultError.wrapFailed
        }
        // CAS-guarded like every vault update (R1-2); the proof from the
        // master the authorization just unwrapped (pre-13x).
        try await client.updateVault(
            updated, expectedRevision: fetched.revision,
            keyProof: KeyProofMaterial(master: master))
        return try material(from: vault, master: master)
    }

    // MARK: - The reset door's vault half (Phase 13p Batch 2 — R13p-9)

    /// Re-wrap master under a NEW passphrase using the device's HELD
    /// material — NO old-passphrase authorization (the reset door's
    /// letter: the device that holds the keys, after biometric
    /// confirmation, is the authorization; a wrong/stale material refuses
    /// as `masterKeyMismatch` rather than enshrining garbage). Fresh salt
    /// + descriptor, CAS-guarded update like every vault write (R1-2).
    /// The recovery wrap and class keys are untouched.
    public func rewrapPassphrase(
        material: DeviceKeyMaterial, newPassphrase: String
    ) async throws {
        guard !newPassphrase.isEmpty else { throw VaultEnrollmentError.emptyPassphrase }
        let fetched = try await fetchRequiredVault()
        let descriptor = PassphraseKDF.Descriptor.v1(salt: PassphraseKDF.randomSalt())
        let newKey = try measuredDerive(passphrase: newPassphrase, descriptor: descriptor)
        let updated = try fetched.format.rewrappingPassphrase(
            masterKey: material.masterSymmetricKey,
            passphraseKey: newKey,
            kdf: descriptor)
        try await client.updateVault(
            updated, expectedRevision: fetched.revision,
            keyProof: KeyProofMaterial(master: material.masterSymmetricKey))
    }

    // MARK: - Helpers

    private func fetchRequiredVault() async throws -> KeyVaultClient.FetchedVault {
        guard let vault = try await client.fetchVault() else {
            throw KeyVaultClientError.vaultAbsent
        }
        return vault
    }

    private func material(
        from vault: KeyVaultFormat, master: SymmetricKey
    ) throws -> DeviceKeyMaterial {
        // Each guard names the class it is actually missing (ladder R1-6 —
        // a refusal that misnames its offender is worse than none).
        guard let corpusEntry = vault.classKey(for: .corpus) else {
            throw KeyVaultError.unknownClassKey(.corpus)
        }
        guard let journalEntry = vault.classKey(for: .journalBridge) else {
            throw KeyVaultError.unknownClassKey(.journalBridge)
        }
        let corpus = try vault.unwrapClassKey(.corpus, masterKey: master)
        let journal = try vault.unwrapClassKey(.journalBridge, masterKey: master)
        return DeviceKeyMaterial(
            masterKey: master.data,
            corpusKey: corpus.data, corpusKeyID: corpusEntry.keyID,
            journalBridgeKey: journal.data, journalBridgeKeyID: journalEntry.keyID)
    }

    /// The measured KDF hop. Runs synchronously in this nonisolated async
    /// context — off the main actor by construction; blocking one pool
    /// thread for tenths of a second at enrollment cadence (R-6) is the
    /// accepted cost stated in-sitting.
    private func measuredDerive(
        passphrase: String, descriptor: PassphraseKDF.Descriptor
    ) throws -> SymmetricKey {
        let start = ContinuousClock.now
        let key = try PassphraseKDF.deriveKey(passphrase: passphrase, descriptor: descriptor)
        let elapsed = ContinuousClock.now - start
        kdfMeasurement?(Double(elapsed.components.seconds)
            + Double(elapsed.components.attoseconds) / 1e18)
        return key
    }
}

/// Flow-level typed refusals (the substrate's own errors — checksum,
/// unknown word, vault-absent, newer-format — propagate as themselves).
public enum VaultEnrollmentError: Error, Equatable, Sendable {
    /// An empty passphrase is never legal (the headless tool's floor —
    /// Round 6 item 1; length POLICY beyond non-empty is the UI's wording,
    /// never enforced here).
    case emptyPassphrase
    /// The passphrase failed to unwrap master (wrong passphrase — or a
    /// tampered wrap, indistinguishable by RFC 3394 design).
    case wrongPassphrase
    /// A valid-checksum phrase that is not THIS vault's phrase (or the
    /// wrap is tampered — same indistinguishability).
    case wrongRecoveryPhrase
}

extension SymmetricKey {
    var data: Data {
        withUnsafeBytes { Data($0) }
    }
}
