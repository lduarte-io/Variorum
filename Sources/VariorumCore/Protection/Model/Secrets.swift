import CryptoKit
import Foundation

// VX-305 U1 — THE SECRETS AS KEYS: the passphrase (Argon2id under its
// descriptor — `PassphraseKDF`, reused) and the twelve words (BIP-39 →
// HKDF — `RecoveryPhrase`, reused). No new primitive exists here: every lock
// in the model is RFC 3394 `AES.KeyWrap` under one of these, exactly as
// `KeyVaultFormat` locks its own. Never stored, never
// encoded, never logged (none of these types is `Codable`; every description
// is redacted).

/// A passphrase-derived wrapping key with the descriptor it was derived under
/// (the descriptor is truth — §3.5 of the pre-13x design, kept).
public struct PassphraseKey: Sendable, CustomStringConvertible {
    public let key: SymmetricKey
    public let kdf: PassphraseKDF.Descriptor

    public init(key: SymmetricKey, kdf: PassphraseKDF.Descriptor) {
        self.key = key
        self.kdf = kdf
    }

    /// The heavy derivation (callers off-main). An empty passphrase refuses.
    public static func derive(
        _ passphrase: String, kdf: PassphraseKDF.Descriptor = .v1(salt: PassphraseKDF.randomSalt())
    ) throws -> PassphraseKey {
        guard !passphrase.isEmpty else { throw KeyFileError.emptyPassphrase }
        return PassphraseKey(key: try PassphraseKDF.deriveKey(passphrase: passphrase, descriptor: kdf), kdf: kdf)
    }

    public var description: String { "PassphraseKey(redacted)" }
}

/// The twelve words' wrapping key.
public struct WordsKey: Sendable, CustomStringConvertible {
    public let key: SymmetricKey

    public init(key: SymmetricKey) { self.key = key }

    public static func derive(_ words: [String]) throws -> WordsKey {
        WordsKey(key: try RecoveryPhrase.recoveryWrapKey(words: words))
    }

    public var description: String { "WordsKey(redacted)" }
}

/// An Apple key in hand: its id (what wraps and records name) and its bytes.
public struct AppleKeyMaterial: Sendable, CustomStringConvertible {
    public let id: String
    public let key: SymmetricKey

    public init(id: String, key: SymmetricKey) {
        self.id = id
        self.key = key
    }

    public static func mint() -> AppleKeyMaterial {
        AppleKeyMaterial(id: UUID().uuidString.lowercased(), key: SymmetricKey(size: .bits256))
    }

    public var description: String { "AppleKeyMaterial(\(id), redacted)" }
}

/// What a person typed (or what a lobby derived from it), offered to a lock.
public enum ProtectionSecret: Sendable, CustomStringConvertible {
    case passphrase(String)
    /// A passphrase already derived under one descriptor — it opens only a
    /// lock made under that same descriptor (no second derivation).
    case passphraseKey(PassphraseKey)
    case words([String])

    public var description: String {
        switch self {
        case .passphrase: return "ProtectionSecret.passphrase(redacted)"
        case .passphraseKey: return "ProtectionSecret.passphraseKey(redacted)"
        case .words: return "ProtectionSecret.words(redacted)"
        }
    }

    /// The wrapping key this secret yields for a PASSPHRASE lock made under
    /// `kdf` — nil for the words, or a derived key under another descriptor.
    /// The floor is checked BEFORE any derivation (a tampered descriptor can
    /// never make the KDF cheap — pre-13x 3b, kept).
    func passphraseKey(for kdf: PassphraseKDF.Descriptor, floor: PassphraseKDF.Floor) throws -> SymmetricKey? {
        switch self {
        case .passphrase(let typed):
            try kdf.validateFloor(floor)
            return try PassphraseKDF.deriveKey(passphrase: typed, descriptor: kdf)
        case .passphraseKey(let derived):
            try kdf.validateFloor(floor)
            return derived.kdf == kdf ? derived.key : nil
        case .words:
            return nil
        }
    }

    /// The wrapping key for a WORDS lock — nil for a passphrase.
    func wordsKey() throws -> SymmetricKey? {
        guard case .words(let words) = self else { return nil }
        return try RecoveryPhrase.recoveryWrapKey(words: words)
    }

    var isWords: Bool {
        if case .words = self { return true }
        return false
    }
}

// MARK: - The one lock primitive (RFC 3394, as everywhere else in the app)

enum Lock {
    static func wrap(_ data: Data, under key: SymmetricKey) throws -> Data {
        do {
            return try AES.KeyWrap.wrap(SymmetricKey(data: data), using: key)
        } catch {
            throw KeyFileError.wrapFailed
        }
    }

    /// nil = this key does not open the lock (RFC 3394 refuses a wrong key
    /// and a tampered blob alike — it never yields bytes).
    static func unwrap(_ blob: Data, under key: SymmetricKey) -> Data? {
        guard let unwrapped = try? AES.KeyWrap.unwrap(blob, using: key) else { return nil }
        return unwrapped.withUnsafeBytes { Data($0) }
    }

    static func unwrapStoreKey(_ blob: Data, under key: SymmetricKey) -> StoreKey? {
        unwrap(blob, under: key).flatMap { StoreKey(data: $0) }
    }
}
