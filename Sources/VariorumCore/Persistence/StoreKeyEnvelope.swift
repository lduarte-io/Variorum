import CryptoKit
import Foundation

// Phase 13p, Batch 2 — the store key's WRAPPED copies (THE DESIGN's key
// architecture, items (a) and (b)): the same 256-bit store key Batch 1
// mints, wrapped by the SAME encryption passphrase and the SAME BIP-39
// recovery phrase as 14b's vault (R13p-4: one secret, ever — the KDF is
// `PassphraseKDF` and the phrase machinery is `RecoveryPhrase`, both
// REUSED, never re-implemented; no new crypto primitives exist here, only
// RFC 3394 `AES.KeyWrap` exactly as `KeyVaultFormat` uses it).
//
// WHERE THE WRAPS LIVE: a small JSON file BESIDE the store
// (`variorum-keys.json`), deliberately not in the store (the store is
// what's locked — a chicken-and-egg) and deliberately not the Keychain
// (a signed-out local-only user's recovery legs must travel WITH the
// library: 13x's move-your-library door, and a backup folder restored on
// a new machine, both carry this file, which is what makes "restore via
// passphrase / recovery phrase" true off this device). Every byte in it
// is non-secret: wrapped ciphertext, KDF parameters, salts, and a random
// store identity. Holding the file grants nothing without the passphrase
// or the twelve words.
//
// `storeID` names this store wherever a per-store identity is needed
// WITHOUT the key — concretely the iCloud escrow item's account
// (R13p-6): each device's store has its own key, and escrow items from
// several Macs share one iCloud Keychain, so the item must be named by
// the STORE, never by the bundle or the variant scope.
//
// ONE SECRET is enforced procedurally at the set-screen (the app layer
// verifies a typed passphrase against the account vault when one
// exists); this format cannot and does not try to enforce it — it just
// never mints a secret of its own.

/// The wrapped-copies sidecar: versioned, Codable, atomic on disk.
public struct StoreKeyEnvelope: Codable, Equatable, Sendable {
    /// The current (and only) envelope format version. A newer envelope
    /// refuses every operation — never guess at a future format.
    public static let currentFormatVersion = 1

    public var formatVersion: Int
    /// Random identity minted with the envelope (lowercased UUID). Names
    /// the escrow Keychain item; readable without any key on purpose.
    public var storeID: String
    /// The passphrase wrap — absent until a passphrase is set (knot 4:
    /// NO passphrase at first launch; the set-screen is summoned by the
    /// doors that need one).
    public var passphrase: PassphraseWrap?
    /// The recovery-phrase wrap (RFC 3394 blob under the BIP-39-derived
    /// key) — absent until the phrase is generated and shown.
    public var recovery: Data?
    /// A short public fingerprint of the wrapped KEY (first 8 bytes of
    /// SHA-256, hex) — set whenever a wrap lands. Lets custody flips and
    /// the locked lobby detect a FOREIGN envelope (a sidecar copied from
    /// another library) without holding any secret; reveals nothing about
    /// a random 256-bit key. nil on a wraps-less envelope.
    public var keyFingerprint: String?

    public struct PassphraseWrap: Codable, Equatable, Sendable {
        /// The versioned KDF parameters this wrap's key was derived with
        /// (the descriptor is truth — never re-derive from app defaults).
        public var kdf: PassphraseKDF.Descriptor
        /// The store key wrapped by the passphrase-KDF key (RFC 3394).
        public var wrapped: Data

        public init(kdf: PassphraseKDF.Descriptor, wrapped: Data) {
            self.kdf = kdf
            self.wrapped = wrapped
        }
    }

    public init(
        formatVersion: Int = StoreKeyEnvelope.currentFormatVersion,
        storeID: String = UUID().uuidString.lowercased(),
        passphrase: PassphraseWrap? = nil,
        recovery: Data? = nil,
        keyFingerprint: String? = nil
    ) {
        self.formatVersion = formatVersion
        self.storeID = storeID
        self.passphrase = passphrase
        self.recovery = recovery
        self.keyFingerprint = keyFingerprint
    }

    /// The public fingerprint of a key (see `keyFingerprint`).
    public static func fingerprint(of key: StoreKey) -> String {
        Data(SHA256.hash(data: key.data)).prefix(8)
            .map { String(format: "%02x", $0) }.joined()
    }

    /// Does this envelope's fingerprint match `key`? A wraps-less envelope
    /// (no fingerprint yet) matches — there is nothing to contradict.
    public func belongs(to key: StoreKey) -> Bool {
        guard let keyFingerprint else { return true }
        return keyFingerprint == Self.fingerprint(of: key)
    }

    // MARK: - Wrapping (the heavy KDF call rides here — callers off-main)

    /// Set (or REPLACE, wholesale) the passphrase wrap. A fresh salt and
    /// descriptor are minted per set — which is exactly what makes the
    /// R13p-9 reset door a re-wrap: after a replace, the OLD passphrase's
    /// derived key no longer unwraps anything, because the old wrap row
    /// is GONE, not shadowed (pinned in `StoreKeyEnvelopeTests`).
    ///
    /// The Argon2id derivation is deliberately slow (~64 MiB transient,
    /// tenths of a second at the v1 parameters) — callers run it off the
    /// main thread, at set/reset cadence only. `kdf` exists for tests
    /// (small parameters) and future parameter migration; production
    /// callers take the default.
    public mutating func setPassphraseWrap(
        key: StoreKey, passphrase: String,
        kdf: PassphraseKDF.Descriptor = .v1(salt: PassphraseKDF.randomSalt())
    ) throws {
        try requireCurrentFormat()
        guard !passphrase.isEmpty else { throw StoreKeyEnvelopeError.emptyPassphrase }
        let wrapKey = try PassphraseKDF.deriveKey(passphrase: passphrase, descriptor: kdf)
        do {
            let wrapped = try AES.KeyWrap.wrap(
                SymmetricKey(data: key.data), using: wrapKey)
            self.passphrase = PassphraseWrap(kdf: kdf, wrapped: wrapped)
            keyFingerprint = Self.fingerprint(of: key)
        } catch {
            throw StoreKeyEnvelopeError.wrapFailed
        }
    }

    /// Set (or replace) the recovery wrap from the twelve words. Phrase
    /// validation errors (checksum, unknown word, wrong count) propagate
    /// as themselves — the surface points at the typo.
    public mutating func setRecoveryWrap(key: StoreKey, words: [String]) throws {
        try requireCurrentFormat()
        let wrapKey = try RecoveryPhrase.recoveryWrapKey(words: words)
        do {
            recovery = try AES.KeyWrap.wrap(SymmetricKey(data: key.data), using: wrapKey)
            keyFingerprint = Self.fingerprint(of: key)
        } catch {
            throw StoreKeyEnvelopeError.wrapFailed
        }
    }

    // MARK: - Unwrapping (the unlock roads)

    /// The passphrase road. RFC 3394 authenticates: a wrong passphrase
    /// cannot unwrap — it refuses (`wrongPassphrase`), never yields
    /// garbage key bytes. As heavy as the set (the KDF); off-main.
    public func unwrapKey(passphrase typed: String) throws -> StoreKey {
        try requireCurrentFormat()
        guard let wrap = passphrase else { throw StoreKeyEnvelopeError.noPassphraseWrap }
        let wrapKey = try PassphraseKDF.deriveKey(passphrase: typed, descriptor: wrap.kdf)
        let unwrapped: SymmetricKey
        do {
            unwrapped = try AES.KeyWrap.unwrap(wrap.wrapped, using: wrapKey)
        } catch {
            // Wrong key and tampered wrap are indistinguishable by RFC 3394
            // design; the overwhelmingly likely cause is the typo.
            throw StoreKeyEnvelopeError.wrongPassphrase
        }
        guard let key = StoreKey(data: unwrapped.withUnsafeBytes { Data($0) }) else {
            throw StoreKeyEnvelopeError.wrongPassphrase
        }
        return key
    }

    /// The disaster road: the twelve written words alone.
    public func unwrapKey(recoveryWords words: [String]) throws -> StoreKey {
        try requireCurrentFormat()
        guard let blob = recovery else { throw StoreKeyEnvelopeError.noRecoveryWrap }
        let wrapKey = try RecoveryPhrase.recoveryWrapKey(words: words)
        let unwrapped: SymmetricKey
        do {
            unwrapped = try AES.KeyWrap.unwrap(blob, using: wrapKey)
        } catch {
            throw StoreKeyEnvelopeError.wrongRecoveryPhrase
        }
        guard let key = StoreKey(data: unwrapped.withUnsafeBytes { Data($0) }) else {
            throw StoreKeyEnvelopeError.wrongRecoveryPhrase
        }
        return key
    }

    private func requireCurrentFormat() throws {
        guard formatVersion <= Self.currentFormatVersion else {
            throw StoreKeyEnvelopeError.newerFormat(formatVersion)
        }
    }

    // MARK: - The file (atomic; beside the store)

    /// The sidecar's name, public so backups and drills name the same file.
    public static let filename = "variorum-keys.json"

    /// `<store folder>/variorum-keys.json` — beside the store so a moved
    /// or restored library folder carries its recovery legs.
    public static func url(besideStore storeURL: URL) -> URL {
        storeURL.deletingLastPathComponent()
            .appendingPathComponent(filename, isDirectory: false)
    }

    /// nil = no envelope exists there (fresh store, or pre-passphrase).
    /// A file that EXISTS but cannot be decoded throws `unreadable` —
    /// reading corruption as absence would let a surface claim "no
    /// passphrase is set" over a library that has one.
    public static func load(at url: URL) throws -> StoreKeyEnvelope? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(StoreKeyEnvelope.self, from: data)
        } catch {
            throw StoreKeyEnvelopeError.unreadable(String(describing: error))
        }
    }

    /// Atomic write (a crash mid-write leaves the old envelope, never a
    /// torn one — losing a freshly-set wrap is recoverable by setting it
    /// again; a torn file that shadows an existing wrap is not).
    public func write(at url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(self)
        try data.write(to: url, options: .atomic)
    }
}

/// Typed refusals — every arm speaks (the R94 doctrine reaches custody).
public enum StoreKeyEnvelopeError: Error, Equatable, Sendable {
    /// No passphrase wrap exists yet (the set-screen is the road).
    case noPassphraseWrap
    /// No recovery wrap exists yet.
    case noRecoveryWrap
    /// The typed passphrase did not unwrap the store key (or the wrap is
    /// tampered — indistinguishable by RFC 3394 design).
    case wrongPassphrase
    /// A valid-checksum phrase that is not THIS store's phrase.
    case wrongRecoveryPhrase
    /// An empty passphrase is never legal (the 14b floor, kept).
    case emptyPassphrase
    /// CryptoKit's wrap refused (not expected in practice).
    case wrapFailed
    /// The envelope was written by a newer build — refuse, never guess.
    case newerFormat(Int)
    /// The sidecar exists but cannot be read (decode/IO failure carried).
    case unreadable(String)
}
