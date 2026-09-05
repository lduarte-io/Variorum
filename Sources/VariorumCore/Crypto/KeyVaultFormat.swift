import CryptoKit
import Foundation

/// The key class a wrapped per-class key serves (Phase 14b ruling R-8:
/// master + per-class keys — Variorum corpus · journal-bridge; Fragments'
/// side only ever handled the journal-bridge key at touchpoint #2). The
/// journal-bridge class is DORMANT since the bridge's 2026-09-04 retirement
/// — the format keeps it (a deployed wire shape); nothing reads it.
public enum VaultKeyClass: String, Codable, CaseIterable, Sendable {
    case corpus
    case journalBridge = "journal_bridge"
}

/// The versioned vault payload (Phase 14b rulings R-1/R-5/R-7/R-8, THE
/// DESIGN's "The vault" section): the master key wrapped TWICE — by the
/// passphrase-KDF key and by the recovery-phrase key — plus the per-class
/// keys wrapped by master, all via CryptoKit `AES.KeyWrap` (RFC 3394,
/// integrity built in: unwrapping with a wrong key or over flipped bytes
/// REFUSES — it never yields garbage key bytes).
///
/// **Wrap-addition (Round 5, her passphrase-file arrangement):** a vault
/// may be born with the passphrase wrap ALONE (`masterWrappedByRecovery`
/// absent) and gain the recovery wrap later, in her presence — the phrase's
/// whole point is being seen once and written down, so it is never
/// persisted overnight. `addingRecoveryWrap` is that door; it verifies the
/// caller's master against the vault's class keys first, so a WRONG master
/// can never be enshrined as the disaster road.
///
/// This type is the FORMAT + wrap/unwrap logic only. Custody (Keychain)
/// and transport (the `key_vault` PostgREST row) are batch 3's; the sync
/// engine never touches any of it.
public struct KeyVaultFormat: Codable, Equatable, Sendable {
    /// The current (and only) vault format version. A vault carrying a
    /// newer version refuses every operation — never guess at a future
    /// format.
    public static let currentFormatVersion = 1

    public var formatVersion: Int
    /// The versioned KDF parameters the passphrase wrap key was derived
    /// with (never re-derived from app defaults — the descriptor is truth).
    public var kdf: PassphraseKDF.Descriptor
    /// Master wrapped by the passphrase-KDF key (RFC 3394).
    public var masterWrappedByPassphrase: Data
    /// Master wrapped by the recovery-phrase key — absent until the
    /// recovery wrap is added (Round 5's wrap-addition).
    public var masterWrappedByRecovery: Data?
    /// The per-class keys, each wrapped by master.
    public var classKeys: [WrappedClassKey]

    // MARK: pre-13x — the six additive columns (design §3.10; the format
    // version STAYS 1: a row without them decodes as a pre-postures vault)

    /// Standard's ONE Apple-held copy (decision 3): master wrapped under
    /// the iCloud key A, with A's id beside it. nil under Castle — the
    /// posture is DERIVED from this field's presence (design §3.1) — and
    /// nil on every vault until batch 2 writes it.
    public var masterWrappedByAppleHeld: Data?
    public var appleKeyID: String?
    /// The key proof's hash (decision 12): `KeyProof.hash(master:)` — what
    /// the server compares every RPC's `key_proof` against. Landed at
    /// CREATE; nil only on a pre-postures row (the author's, until her
    /// first round's migration arm lands it).
    public var keyProofHash: String?
    /// The PREVIOUS corpus key for a rotation's duration (decision 6):
    /// its id (`corpus_previous_key_id` — what a follower binds the AAD of
    /// pre-rotation rows to) and its bare wrap under the NEW master
    /// (`corpus_previous_wrapped_by_master`) — two columns, the current
    /// key's own shape (the orchestrator's ruling on batch 1b's question
    /// 1). nil outside a rotation — TOGETHER with `rotationStartedSeq`
    /// (pinned).
    public var previousCorpusKey: PreviousCorpusKey?
    /// Which key a row is under is told by its `server_seq` (decision 31):
    /// SERVER-assigned when a rotation begins (`key_vault_update` takes
    /// `nextval` with the row locked); a row below it is under the previous
    /// corpus key, every other row under the current. nil outside a
    /// rotation. Never set client-side — the wire row carries it back.
    public var rotationStartedSeq: Int64?

    /// The previous corpus key as the vault carries it: its id and its
    /// wrap — TWO columns on the wire (`corpus_previous_key_id` +
    /// `corpus_previous_wrapped_by_master`), never one packed value; one
    /// without the other is malformed (`KeyVaultWireRow.format()` refuses).
    public struct PreviousCorpusKey: Codable, Equatable, Sendable {
        public var keyID: String
        public var wrappedByMaster: Data

        public init(keyID: String, wrappedByMaster: Data) {
            self.keyID = keyID
            self.wrappedByMaster = wrappedByMaster
        }
    }

    public struct WrappedClassKey: Codable, Equatable, Sendable {
        public var keyClass: VaultKeyClass
        /// Plaintext key identifier (a UUID string) — carried in every
        /// ciphertext's AAD (`PayloadCipher`) so a value cannot be silently
        /// re-attributed to a different key.
        public var keyID: String
        public var wrappedByMaster: Data

        public init(keyClass: VaultKeyClass, keyID: String, wrappedByMaster: Data) {
            self.keyClass = keyClass
            self.keyID = keyID
            self.wrappedByMaster = wrappedByMaster
        }
    }

    // MARK: - Create

    /// Build a vault: wrap `masterKey` under the passphrase-KDF key (and
    /// the recovery key when present — Round 5 allows creating without),
    /// and wrap each class key under master. Refuses an empty class-key
    /// set — a vault exists to carry them (R-8's v1 classes: corpus ·
    /// journal-bridge).
    public static func create(
        masterKey: SymmetricKey,
        passphraseKey: SymmetricKey,
        recoveryKey: SymmetricKey?,
        classKeys: [(keyClass: VaultKeyClass, keyID: String, key: SymmetricKey)],
        kdf: PassphraseKDF.Descriptor
    ) throws -> KeyVaultFormat {
        guard !classKeys.isEmpty else { throw KeyVaultError.noClassKeys }
        guard Set(classKeys.map(\.keyClass)).count == classKeys.count else {
            throw KeyVaultError.duplicateClassKey
        }
        do {
            let byPassphrase = try AES.KeyWrap.wrap(masterKey, using: passphraseKey)
            let byRecovery = try recoveryKey.map { try AES.KeyWrap.wrap(masterKey, using: $0) }
            let wrapped = try classKeys.map { entry in
                WrappedClassKey(
                    keyClass: entry.keyClass,
                    keyID: entry.keyID,
                    wrappedByMaster: try AES.KeyWrap.wrap(entry.key, using: masterKey)
                )
            }
            return KeyVaultFormat(
                formatVersion: currentFormatVersion,
                kdf: kdf,
                masterWrappedByPassphrase: byPassphrase,
                masterWrappedByRecovery: byRecovery,
                classKeys: wrapped,
                // pre-13x: a vault is CREATED with its proof hash — the
                // server's BEFORE INSERT trigger refuses one without.
                keyProofHash: KeyProof.hash(master: masterKey)
            )
        } catch let error as KeyVaultError {
            throw error
        } catch {
            throw KeyVaultError.wrapFailed
        }
    }

    public init(
        formatVersion: Int,
        kdf: PassphraseKDF.Descriptor,
        masterWrappedByPassphrase: Data,
        masterWrappedByRecovery: Data?,
        classKeys: [WrappedClassKey],
        masterWrappedByAppleHeld: Data? = nil,
        appleKeyID: String? = nil,
        keyProofHash: String? = nil,
        previousCorpusKey: PreviousCorpusKey? = nil,
        rotationStartedSeq: Int64? = nil
    ) {
        self.formatVersion = formatVersion
        self.kdf = kdf
        self.masterWrappedByPassphrase = masterWrappedByPassphrase
        self.masterWrappedByRecovery = masterWrappedByRecovery
        self.classKeys = classKeys
        self.masterWrappedByAppleHeld = masterWrappedByAppleHeld
        self.appleKeyID = appleKeyID
        self.keyProofHash = keyProofHash
        self.previousCorpusKey = previousCorpusKey
        self.rotationStartedSeq = rotationStartedSeq
    }

    // MARK: - pre-13x roads (batch 2 / 3 call them; batch 1b lands the format)

    /// Standard's Apple-held copy: master wrapped under the iCloud key A.
    /// Verifies `masterKey` against the class keys (the wrap-addition
    /// guard's discipline) — a mismatched master must never become the
    /// silent road's content.
    public func settingAppleHeldCopy(
        masterKey: SymmetricKey, appleKey: SymmetricKey, appleKeyID: String
    ) throws -> KeyVaultFormat {
        try requireCurrentFormat()
        try verifyMaster(masterKey)
        var updated = self
        do {
            updated.masterWrappedByAppleHeld = try AES.KeyWrap.wrap(masterKey, using: appleKey)
        } catch {
            throw KeyVaultError.wrapFailed
        }
        updated.appleKeyID = appleKeyID
        return updated
    }

    /// Castle: NO copy under the Apple-held key (pin the ABSENCE).
    public func removingAppleHeldCopy() -> KeyVaultFormat {
        var updated = self
        updated.masterWrappedByAppleHeld = nil
        updated.appleKeyID = nil
        return updated
    }

    /// Unwrap master by the Apple-held road (Standard's silent open).
    /// Refuses loudly when the vault carries no such copy (Castle).
    public func unwrapMaster(withAppleKey key: SymmetricKey) throws -> SymmetricKey {
        try requireCurrentFormat()
        guard let wrapped = masterWrappedByAppleHeld else {
            throw KeyVaultError.appleHeldCopyAbsent
        }
        return try Self.unwrap(wrapped, using: key)
    }

    /// A rotation's vault: the PREVIOUS corpus key (with its id) wrapped
    /// under `masterKey` (the NEW master) for the rotation's duration.
    /// Verifies the new master against the vault's class keys — the class
    /// keys must already be the NEW ones (the caller builds the rotated
    /// format first, then keeps the old key beside it).
    public func carryingPreviousCorpusKey(
        _ previous: SymmetricKey, keyID: String, masterKey: SymmetricKey
    ) throws -> KeyVaultFormat {
        try requireCurrentFormat()
        try verifyMaster(masterKey)
        var updated = self
        do {
            updated.previousCorpusKey = PreviousCorpusKey(
                keyID: keyID, wrappedByMaster: try AES.KeyWrap.wrap(previous, using: masterKey))
        } catch {
            throw KeyVaultError.wrapFailed
        }
        return updated
    }

    /// Completion: the previous key AND the seq go together (the server
    /// clears the seq when the payload clears the key; the client clears
    /// both so the value it holds never disagrees with what it sends).
    public func clearingPreviousCorpusKey() -> KeyVaultFormat {
        var updated = self
        updated.previousCorpusKey = nil
        updated.rotationStartedSeq = nil
        return updated
    }

    /// Unwrap the previous corpus key with the (new) master. Refuses when
    /// no rotation is in progress.
    public func unwrapPreviousCorpusKey(masterKey: SymmetricKey) throws -> (key: SymmetricKey, keyID: String) {
        try requireCurrentFormat()
        guard let previous = previousCorpusKey else {
            throw KeyVaultError.noRotationInProgress
        }
        return (try Self.unwrap(previous.wrappedByMaster, using: masterKey), previous.keyID)
    }

    private func verifyMaster(_ masterKey: SymmetricKey) throws {
        guard let probe = classKeys.first else { throw KeyVaultError.noClassKeys }
        guard (try? AES.KeyWrap.unwrap(probe.wrappedByMaster, using: masterKey)) != nil else {
            throw KeyVaultError.masterKeyMismatch
        }
    }

    // MARK: - Wrap-addition (Round 5)

    /// Add the recovery wrap to a vault born without one. Refuses when a
    /// recovery wrap already exists (replacing the disaster road is a
    /// deliberate future ceremony, not a silent overwrite), and VERIFIES
    /// `masterKey` by unwrapping the vault's first class key — a mismatched
    /// master must never become the phrase's target.
    public func addingRecoveryWrap(
        masterKey: SymmetricKey, recoveryKey: SymmetricKey
    ) throws -> KeyVaultFormat {
        try requireCurrentFormat()
        guard masterWrappedByRecovery == nil else {
            throw KeyVaultError.recoveryWrapAlreadyPresent
        }
        guard let probe = classKeys.first else { throw KeyVaultError.noClassKeys }
        guard (try? AES.KeyWrap.unwrap(probe.wrappedByMaster, using: masterKey)) != nil else {
            throw KeyVaultError.masterKeyMismatch
        }
        var updated = self
        do {
            updated.masterWrappedByRecovery = try AES.KeyWrap.wrap(masterKey, using: recoveryKey)
        } catch {
            throw KeyVaultError.wrapFailed
        }
        return updated
    }

    /// REPLACE an existing recovery wrap — the deliberate ceremony batch 1's
    /// `addingRecoveryWrap` refusal predicted, made real by the author's
    /// Round-7 ruling (batch 3): (RE)GENERATE RECOVERY PHRASE is ONE
    /// surface serving first-generation and regeneration, and replacement
    /// is a deliberate confirm in the UI. Additive to the batch-1 format
    /// logic (recorded reason: the Round-7 scope addition; `addingRecoveryWrap`
    /// keeps its strict add-only semantics and its pin). Verifies the
    /// caller's master exactly as the add door does; also serves the
    /// wrap-absent case (replacing nothing is adding), so the enrollment
    /// flow has one landing door behind its own allow-replace gate.
    public func replacingRecoveryWrap(
        masterKey: SymmetricKey, recoveryKey: SymmetricKey
    ) throws -> KeyVaultFormat {
        try requireCurrentFormat()
        guard let probe = classKeys.first else { throw KeyVaultError.noClassKeys }
        guard (try? AES.KeyWrap.unwrap(probe.wrappedByMaster, using: masterKey)) != nil else {
            throw KeyVaultError.masterKeyMismatch
        }
        var updated = self
        do {
            updated.masterWrappedByRecovery = try AES.KeyWrap.wrap(masterKey, using: recoveryKey)
        } catch {
            throw KeyVaultError.wrapFailed
        }
        return updated
    }

    /// REPLACE the passphrase wrap using a HELD master (Phase 13p Batch 2
    /// — the R13p-9 reset door's vault half: any enrolled device re-wraps
    /// under a new passphrase after biometric confirmation, NO old
    /// passphrase needed; the envelope's whole point). Verifies the
    /// caller's master exactly as the recovery doors do — a mismatched
    /// master must never become the wrap's content. The recovery wrap and
    /// the class keys are untouched (R-7's soft door: a passphrase change
    /// is a one-key re-wrap, never a corpus re-encrypt).
    public func rewrappingPassphrase(
        masterKey: SymmetricKey, passphraseKey: SymmetricKey,
        kdf: PassphraseKDF.Descriptor
    ) throws -> KeyVaultFormat {
        try requireCurrentFormat()
        guard let probe = classKeys.first else { throw KeyVaultError.noClassKeys }
        guard (try? AES.KeyWrap.unwrap(probe.wrappedByMaster, using: masterKey)) != nil else {
            throw KeyVaultError.masterKeyMismatch
        }
        var updated = self
        updated.kdf = kdf
        do {
            updated.masterWrappedByPassphrase = try AES.KeyWrap.wrap(
                masterKey, using: passphraseKey)
        } catch {
            throw KeyVaultError.wrapFailed
        }
        return updated
    }

    // MARK: - Unwrap

    /// Unwrap master with the passphrase-derived key. A wrong passphrase
    /// (wrong derived key) or tampered wrap refuses with `unwrapFailed` —
    /// RFC 3394's integrity check makes the two indistinguishable by
    /// design, and neither ever yields key bytes.
    public func unwrapMaster(withPassphraseKey key: SymmetricKey) throws -> SymmetricKey {
        try requireCurrentFormat()
        return try Self.unwrap(masterWrappedByPassphrase, using: key)
    }

    /// Unwrap master by the recovery road. Refuses loudly when the vault
    /// has no recovery wrap yet (the Round-5 overnight state).
    public func unwrapMaster(withRecoveryKey key: SymmetricKey) throws -> SymmetricKey {
        try requireCurrentFormat()
        guard let wrapped = masterWrappedByRecovery else {
            throw KeyVaultError.recoveryWrapAbsent
        }
        return try Self.unwrap(wrapped, using: key)
    }

    /// The stored entry for a class, if any.
    public func classKey(for keyClass: VaultKeyClass) -> WrappedClassKey? {
        classKeys.first { $0.keyClass == keyClass }
    }

    /// Unwrap one class key with the (already unwrapped) master.
    public func unwrapClassKey(
        _ keyClass: VaultKeyClass, masterKey: SymmetricKey
    ) throws -> SymmetricKey {
        try requireCurrentFormat()
        guard let entry = classKey(for: keyClass) else {
            throw KeyVaultError.unknownClassKey(keyClass)
        }
        return try Self.unwrap(entry.wrappedByMaster, using: masterKey)
    }

    // MARK: - Serialization

    /// Stable JSON encoding (sorted keys) — the payload as stored/shipped.
    public func encoded() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(self)
    }

    /// Decode a stored payload. Malformed bytes refuse with a typed error;
    /// a NEWER format version decodes structurally where possible but every
    /// operation on it refuses via `requireCurrentFormat` — and payloads a
    /// future format made undecodable refuse here.
    public init(decoding data: Data) throws {
        do {
            self = try JSONDecoder().decode(KeyVaultFormat.self, from: data)
        } catch {
            throw KeyVaultError.malformedPayload
        }
    }

    // MARK: - Helpers

    private func requireCurrentFormat() throws {
        guard formatVersion == Self.currentFormatVersion else {
            throw KeyVaultError.unsupportedFormatVersion(formatVersion)
        }
    }

    private static func unwrap(_ wrapped: Data, using key: SymmetricKey) throws -> SymmetricKey {
        do {
            return try AES.KeyWrap.unwrap(wrapped, using: key)
        } catch {
            throw KeyVaultError.unwrapFailed
        }
    }
}

/// Typed refusals — tamper, wrong keys, and format drift all speak; none
/// crash, none yield key material.
public enum KeyVaultError: Error, Equatable, Sendable {
    /// The vault's format version is not this build's (likely newer —
    /// refuse, never guess at a future format).
    case unsupportedFormatVersion(Int)
    /// The vault has no recovery wrap yet (Round 5's overnight state) —
    /// the recovery road cannot be taken until the wrap is added.
    case recoveryWrapAbsent
    /// The vault already carries a recovery wrap; replacing it is a
    /// deliberate ceremony, not this door.
    case recoveryWrapAlreadyPresent
    /// No entry for the requested class.
    case unknownClassKey(VaultKeyClass)
    /// A vault must carry at least one class key.
    case noClassKeys
    /// Two entries for one class at create.
    case duplicateClassKey
    /// The provided master failed verification against the vault's class
    /// keys (wrap-addition's guard).
    case masterKeyMismatch
    /// CryptoKit refused to wrap (not expected with valid keys).
    case wrapFailed
    /// Wrong key OR tampered wrapped bytes — indistinguishable by design
    /// (RFC 3394 integrity); nothing is ever unwrapped on this arm.
    case unwrapFailed
    /// The stored payload's bytes do not decode as a vault.
    case malformedPayload
    /// pre-13x: the vault carries no Apple-held copy (Castle — the
    /// silent road does not exist by design).
    case appleHeldCopyAbsent
    /// pre-13x: no previous corpus key is carried — no rotation is in
    /// progress.
    case noRotationInProgress
}
