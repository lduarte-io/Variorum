import CryptoKit
import Foundation

/// The key class a wrapped per-class key serves (Phase 14b ruling R-8:
/// master + per-class keys — Variorum corpus · journal-bridge; Fragments'
/// side only ever handles the journal-bridge key at touchpoint #2).
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
                classKeys: wrapped
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
        classKeys: [WrappedClassKey]
    ) {
        self.formatVersion = formatVersion
        self.kdf = kdf
        self.masterWrappedByPassphrase = masterWrappedByPassphrase
        self.masterWrappedByRecovery = masterWrappedByRecovery
        self.classKeys = classKeys
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
}
