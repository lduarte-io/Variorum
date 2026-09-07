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
//
// pre-13x batch 1a — FORMAT 2 (the postures design §3.5): the file gains
// the LIBRARY KEY wrapped under the account's MASTER key (`master` — what
// makes both local secret copies caches: any device holding the master can
// extend its own key file with no visit, and the twelve words open a
// Castle library online through the vault before the local W copy has
// ever landed here), the library key wrapped under the iCloud key
// (`apple` + `appleKeyID` — Standard's silent road; ABSENT in Castle), and
// what the local passphrase copy was last reconciled against (`vaultKDF`,
// `vaultCorpusKeyID`). Files are named by key FINGERPRINT
// (`variorum-keys-<fp16>.json`) beside the store and in every backup
// folder; the legacy `variorum-keys.json` reads as format 1 for the
// store's current key when no fingerprint file exists. A format-1 file
// reads as "no master copy, no iCloud copy, unknown descriptor" (every new
// field optional). `storeID` is the LIBRARY's identity — stable across
// re-keys — and names this device's per-store custody items (batch 1a's
// §3.3 / §1.13): every key file of one library carries the same id.

/// The wrapped-copies sidecar: versioned, Codable, atomic on disk.
public struct StoreKeyEnvelope: Codable, Equatable, Sendable {
    /// The current envelope format version (2 since pre-13x batch 1a). A
    /// newer envelope refuses every operation — never guess at a future
    /// format; an OLDER one (format 1) reads with the format-2 fields nil.
    public static let currentFormatVersion = 2
    /// The 13p-era format: passphrase + recovery wraps only.
    public static let formatVersion1 = 1

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
    /// FORMAT 2 — the library key wrapped under the account's MASTER key
    /// (RFC 3394). Written at enrollment / setup (batch 3); nil on a
    /// local-only library and on every format-1 file.
    public var master: Data?
    /// FORMAT 2 — the library key wrapped under the iCloud key (Standard's
    /// silent road, §3.8). ABSENT in Castle; nil on a format-1 file.
    public var apple: Data?
    /// FORMAT 2 — which iCloud key `apple` is under (the vault carries the
    /// same id; the client VERIFIES it, never adopts a key from the wire).
    public var appleKeyID: String?
    /// FORMAT 2 — the vault's passphrase-KDF descriptor the local passphrase
    /// copy was last reconciled against (§3.6: derive ONCE when it equals
    /// the vault's; a difference means a change happened elsewhere).
    public var vaultKDF: PassphraseKDF.Descriptor?
    /// FORMAT 2 — the vault's corpus key id last reconciled against (§3.6's
    /// owner distinction: a differing id after unlock is the follow or the
    /// adopt road).
    public var vaultCorpusKeyID: String?
    /// FORMAT 2 — pre-13x 4a (ledger 53): a NON-SECRET digest (SHA-256 hex,
    /// `RecoveryWrapDigest.hex`) of the vault's recovery wrap the local W
    /// copy was last reconciled against; a difference at ready means the
    /// twelve words were regenerated elsewhere (the words twin of
    /// `vaultKDF`). nil = unknown — a file written before 4a, or a vault
    /// with no recovery wrap yet — and owes no notice. Additive optional:
    /// a file without it decodes nil.
    public var vaultRecoveryWrapDigest: String?

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
        keyFingerprint: String? = nil,
        master: Data? = nil,
        apple: Data? = nil,
        appleKeyID: String? = nil,
        vaultKDF: PassphraseKDF.Descriptor? = nil,
        vaultCorpusKeyID: String? = nil,
        vaultRecoveryWrapDigest: String? = nil
    ) {
        self.formatVersion = formatVersion
        self.storeID = storeID
        self.passphrase = passphrase
        self.recovery = recovery
        self.keyFingerprint = keyFingerprint
        self.master = master
        self.apple = apple
        self.appleKeyID = appleKeyID
        self.vaultKDF = vaultKDF
        self.vaultCorpusKeyID = vaultCorpusKeyID
        self.vaultRecoveryWrapDigest = vaultRecoveryWrapDigest
    }

    /// The first 8 hex characters of the fingerprint — what a snapshot's
    /// filename carries (`variorum-backup-<stamp>-<fp8>.sqlite`, §6).
    public static func shortFingerprint(_ fingerprint: String) -> String {
        String(fingerprint.prefix(8))
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
        try requireCurrentFormat()  // first, exactly as before the split
        let wrap = try Self.makePassphraseWrap(key: key, passphrase: passphrase, kdf: kdf)
        try adoptPassphraseWrap(wrap, key: key)
    }

    /// The wrap COMPUTATION alone — the heavy Argon2id derivation with no
    /// envelope in hand (pre-13u Act 9, P10): callers derive off-main
    /// first, then read the envelope FRESH and `adoptPassphraseWrap`, so a
    /// wrap landed during the derivation is never clobbered by a
    /// pre-derivation snapshot.
    public static func makePassphraseWrap(
        key: StoreKey, passphrase: String,
        kdf: PassphraseKDF.Descriptor = .v1(salt: PassphraseKDF.randomSalt())
    ) throws -> PassphraseWrap {
        guard !passphrase.isEmpty else { throw StoreKeyEnvelopeError.emptyPassphrase }
        let wrapKey = try PassphraseKDF.deriveKey(passphrase: passphrase, descriptor: kdf)
        do {
            let wrapped = try AES.KeyWrap.wrap(
                SymmetricKey(data: key.data), using: wrapKey)
            return PassphraseWrap(kdf: kdf, wrapped: wrapped)
        } catch {
            throw StoreKeyEnvelopeError.wrapFailed
        }
    }

    /// pre-13x 4a (ledger 54): the wrap from a DERIVED key already in hand —
    /// the lobby derived the typed word under the vault's descriptor and
    /// the follow writes the new key file's P copy under that SAME key
    /// with that descriptor, so the word is never asked twice and the next
    /// open derives once. `kdf` MUST be the descriptor `passphraseKey` was
    /// derived under (the caller's contract — the descriptor is truth).
    public static func makePassphraseWrap(
        key: StoreKey, passphraseKey: SymmetricKey, kdf: PassphraseKDF.Descriptor
    ) throws -> PassphraseWrap {
        do {
            let wrapped = try AES.KeyWrap.wrap(SymmetricKey(data: key.data), using: passphraseKey)
            return PassphraseWrap(kdf: kdf, wrapped: wrapped)
        } catch {
            throw StoreKeyEnvelopeError.wrapFailed
        }
    }

    /// Land a precomputed passphrase wrap (P10's second half). Carries the
    /// same format guard as every mutating door — a newer-format envelope
    /// still refuses, exactly as `setPassphraseWrap` always has.
    public mutating func adoptPassphraseWrap(_ wrap: PassphraseWrap, key: StoreKey) throws {
        try requireCurrentFormat()
        passphrase = wrap
        keyFingerprint = Self.fingerprint(of: key)
        formatVersion = Self.currentFormatVersion  // a rewritten file is the current format
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
            formatVersion = Self.currentFormatVersion
        } catch {
            throw StoreKeyEnvelopeError.wrapFailed
        }
    }

    // MARK: - FORMAT 2: the master copy and the iCloud copy (pre-13x 1a)

    /// Wrap the library key under the account's MASTER key (§3.5 — "the
    /// master copy is what makes both local secret copies caches"). Lands
    /// at enrollment / sync setup (batch 3); an enrolled device that holds
    /// the master can add it with no visit. Replaces wholesale.
    public mutating func setMasterWrappedCopy(key: StoreKey, under master: SymmetricKey) throws {
        try requireCurrentFormat()
        do {
            self.master = try AES.KeyWrap.wrap(SymmetricKey(data: key.data), using: master)
        } catch {
            throw StoreKeyEnvelopeError.wrapFailed
        }
        keyFingerprint = Self.fingerprint(of: key)
        formatVersion = Self.currentFormatVersion
    }

    /// The master road: an enrolled device's master (or a master unwrapped
    /// from the vault by the passphrase / the words — the lobby's vault
    /// road, batch 4) opens the library key. RFC 3394 refuses a wrong key.
    public func unwrapKey(master: SymmetricKey) throws -> StoreKey {
        try requireCurrentFormat()
        guard let blob = self.master else { throw StoreKeyEnvelopeError.noMasterWrappedCopy }
        let unwrapped: SymmetricKey
        do {
            unwrapped = try AES.KeyWrap.unwrap(blob, using: master)
        } catch {
            throw StoreKeyEnvelopeError.wrongMasterKey
        }
        guard let key = StoreKey(data: unwrapped.withUnsafeBytes { Data($0) }) else {
            throw StoreKeyEnvelopeError.wrongMasterKey
        }
        return key
    }

    /// Wrap the library key under the iCloud key A (Standard's silent
    /// road, §3.8). `appleKeyID` names which A — the vault carries the
    /// same id and the client verifies it. Replaces wholesale; ABSENT in
    /// Castle (`removeAppleWrappedCopy` at the switch — batch 2).
    public mutating func setAppleWrappedCopy(
        key: StoreKey, under apple: SymmetricKey, appleKeyID: String
    ) throws {
        try requireCurrentFormat()
        do {
            self.apple = try AES.KeyWrap.wrap(SymmetricKey(data: key.data), using: apple)
        } catch {
            throw StoreKeyEnvelopeError.wrapFailed
        }
        self.appleKeyID = appleKeyID
        keyFingerprint = Self.fingerprint(of: key)
        formatVersion = Self.currentFormatVersion
    }

    /// The iCloud road. RFC 3394 refuses a wrong key.
    public func unwrapKey(apple: SymmetricKey) throws -> StoreKey {
        try requireCurrentFormat()
        guard let blob = self.apple else { throw StoreKeyEnvelopeError.noAppleWrappedCopy }
        let unwrapped: SymmetricKey
        do {
            unwrapped = try AES.KeyWrap.unwrap(blob, using: apple)
        } catch {
            throw StoreKeyEnvelopeError.wrongAppleKey
        }
        guard let key = StoreKey(data: unwrapped.withUnsafeBytes { Data($0) }) else {
            throw StoreKeyEnvelopeError.wrongAppleKey
        }
        return key
    }

    /// Entering Castle: the iCloud copy goes (the key itself stays in
    /// iCloud Keychain — §14.5); the other copies are untouched.
    public mutating func removeAppleWrappedCopy() throws {
        try requireCurrentFormat()
        apple = nil
        appleKeyID = nil
        formatVersion = Self.currentFormatVersion
    }

    /// Record what the local copies were last reconciled against (§3.6):
    /// the vault's descriptor and corpus key id — and, pre-13x 4a (ledger
    /// 53), the digest of its recovery wrap (`KeyVaultFormat
    /// .recoveryWrapDigest`; nil = the vault carries none, or the caller
    /// has no fetched vault in hand — REQUIRED so every landing site
    /// decides, the `legacyCleanup` precedent).
    public mutating func recordVaultReconciliation(
        kdf: PassphraseKDF.Descriptor?, corpusKeyID: String?, recoveryWrapDigest: String?
    ) throws {
        try requireCurrentFormat()
        vaultKDF = kdf
        vaultCorpusKeyID = corpusKeyID
        vaultRecoveryWrapDigest = recoveryWrapDigest
        formatVersion = Self.currentFormatVersion
    }

    /// pre-13x 4a: the digest ALONE — the words road's landing (the W copy
    /// re-landed under the vault's current words; the P copy's record is
    /// untouched, so a passphrase change elsewhere still speaks).
    public mutating func recordVaultRecoveryWrapDigest(_ digest: String?) throws {
        try requireCurrentFormat()
        vaultRecoveryWrapDigest = digest
        formatVersion = Self.currentFormatVersion
    }

    // MARK: - Unwrapping (the unlock roads)

    /// The passphrase road. RFC 3394 authenticates: a wrong passphrase
    /// cannot unwrap — it refuses (`wrongPassphrase`), never yields
    /// garbage key bytes. As heavy as the set (the KDF); off-main.
    /// pre-13x 3b: the wrap's descriptor is checked against the floor
    /// BEFORE the derivation (a tampered key file cannot make the KDF cheap).
    public func unwrapKey(passphrase typed: String, floor: PassphraseKDF.Floor = PassphraseKDF.floor) throws -> StoreKey {
        try requireCurrentFormat()
        guard let wrap = passphrase else { throw StoreKeyEnvelopeError.noPassphraseWrap }
        try wrap.kdf.validateFloor(floor)
        let wrapKey = try PassphraseKDF.deriveKey(passphrase: typed, descriptor: wrap.kdf)
        return try unwrapKey(passphraseKey: wrapKey, floor: floor)
    }

    /// The passphrase road with the DERIVED key already in hand (pre-13x
    /// 2c, decision 10's Always-ask exception): the lobby derives ONCE under
    /// the wrap's descriptor, opens the library, and keeps the derived key
    /// in session memory — never the typed word — so the vault read that
    /// fills an Always-ask device's sync keys needs no second Argon2id
    /// pass when the local copy was reconciled against the vault's
    /// descriptor (§3.6 — "derive once when the recorded descriptor equals
    /// the vault's"). Same refusal as the typed road.
    public func unwrapKey(passphraseKey wrapKey: SymmetricKey, floor: PassphraseKDF.Floor = PassphraseKDF.floor) throws -> StoreKey {
        try requireCurrentFormat()
        guard let wrap = passphrase else { throw StoreKeyEnvelopeError.noPassphraseWrap }
        try wrap.kdf.validateFloor(floor)
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

    /// The LEGACY sidecar's name (format 1's fixed name; read for the
    /// store's current key when no fingerprint-named file exists). Public
    /// so the copy that names it and the drills name the same file.
    public static let filename = "variorum-keys.json"
    public static var legacyFilename: String { filename }
    private static let fingerprintPrefix = "variorum-keys-"
    private static let fileExtension = "json"

    /// FORMAT 2's name: `variorum-keys-<fp16>.json` — one file per library
    /// key, beside the store and in every backup folder (§3.5, §6); a
    /// folder therefore holds one per key it has ever held, and no key's
    /// file is ever overwritten by another's.
    public static func filename(forFingerprint fingerprint: String) -> String {
        "\(fingerprintPrefix)\(fingerprint).\(fileExtension)"
    }

    /// The fingerprint a `variorum-keys-<fp>.json` name carries; nil for
    /// the legacy name and for anything else.
    public static func fingerprint(fromFilename name: String) -> String? {
        guard name.hasPrefix(fingerprintPrefix), name.hasSuffix(".\(fileExtension)") else { return nil }
        let middle = name.dropFirst(fingerprintPrefix.count).dropLast(fileExtension.count + 1)
        guard middle.count == 16, middle.allSatisfy(\.isHexDigit) else { return nil }
        return String(middle)
    }

    /// `<store folder>/variorum-keys-<fp>.json`.
    public static func url(besideStore storeURL: URL, fingerprint: String) -> URL {
        storeURL.deletingLastPathComponent()
            .appendingPathComponent(filename(forFingerprint: fingerprint), isDirectory: false)
    }

    /// `<store folder>/variorum-keys.json` — the legacy name.
    public static func legacyURL(besideStore storeURL: URL) -> URL {
        storeURL.deletingLastPathComponent()
            .appendingPathComponent(filename, isDirectory: false)
    }

    /// Where THIS envelope is written beside a store: its key's fingerprint
    /// name when it carries one, else the legacy name (a wraps-less,
    /// fingerprint-less envelope — the pre-1a escrow stub shape).
    public func preferredURL(besideStore storeURL: URL) -> URL {
        if let keyFingerprint {
            return Self.url(besideStore: storeURL, fingerprint: keyFingerprint)
        }
        return Self.legacyURL(besideStore: storeURL)
    }

    /// Every key file beside a store: the fingerprint-named ones (sorted
    /// by name) plus the legacy one when present.
    public static func keyFileURLs(besideStore storeURL: URL) -> [URL] {
        let folder = storeURL.deletingLastPathComponent()
        let entries = (try? FileManager.default.contentsOfDirectory(
            at: folder, includingPropertiesForKeys: [.contentModificationDateKey])) ?? []
        var files = entries
            .filter { fingerprint(fromFilename: $0.lastPathComponent) != nil }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
        let legacy = legacyURL(besideStore: storeURL)
        if FileManager.default.fileExists(atPath: legacy.path) { files.append(legacy) }
        return files
    }

    /// THE STORE'S CURRENT KEY FILE, found WITHOUT the key (the custody
    /// item is named by the file's `storeID`, so the file must be found
    /// first): the sole fingerprint-named file; several ⇒ the most recently
    /// modified (a state only a re-key produces — batch 2's lobby revisits
    /// the rule; recorded in the 1a record); none ⇒ the legacy file; nil
    /// when nothing is there.
    public static func locate(besideStore storeURL: URL) -> URL? {
        let files = keyFileURLs(besideStore: storeURL)
        let fingerprinted = files.filter { fingerprint(fromFilename: $0.lastPathComponent) != nil }
        if fingerprinted.count == 1 { return fingerprinted[0] }
        if fingerprinted.count > 1 {
            return fingerprinted.max { a, b in
                let da = (try? a.resourceValues(forKeys: [.contentModificationDateKey]))?
                    .contentModificationDate ?? .distantPast
                let db = (try? b.resourceValues(forKeys: [.contentModificationDateKey]))?
                    .contentModificationDate ?? .distantPast
                return da < db
            }
        }
        let legacy = legacyURL(besideStore: storeURL)
        return FileManager.default.fileExists(atPath: legacy.path) ? legacy : nil
    }

    /// The current key file's envelope (see `locate`); nil when none
    /// exists; throws `unreadable` on a present-but-undecodable file.
    public static func loadCurrent(besideStore storeURL: URL) throws -> StoreKeyEnvelope? {
        guard let url = locate(besideStore: storeURL) else { return nil }
        return try load(at: url)
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
    /// FORMAT 2 (pre-13x 1a): no master copy exists in this file (a
    /// local-only library, or a format-1 file).
    case noMasterWrappedCopy
    /// The given master does not unwrap the master copy (a different
    /// account's master, or a tampered blob).
    case wrongMasterKey
    /// No iCloud copy exists in this file (Castle, a local-only library
    /// before its first Standard launch, or a format-1 file).
    case noAppleWrappedCopy
    /// The given iCloud key does not unwrap the iCloud copy.
    case wrongAppleKey
    /// An empty passphrase is never legal (the 14b floor, kept).
    case emptyPassphrase
    /// CryptoKit's wrap refused (not expected in practice).
    case wrapFailed
    /// The envelope was written by a newer build — refuse, never guess.
    case newerFormat(Int)
    /// The sidecar exists but cannot be read (decode/IO failure carried).
    case unreadable(String)
}
