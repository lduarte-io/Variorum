import CryptoKit
import Foundation

// VX-305 U1 — THE CASTLE ANCHOR (design §3.4; her rulings of 2026-10-13 and
// 2026-10-14, §1: "a fresh key at every crossing", "the anchor keeps the
// secrets of its day", and the follower's lock, confirmed 2026-10-14).
//
// At a leave, BEFORE anything else is written, the outgoing Castle key with
// its whole history — and any earlier anchor kept beside it — is sealed into
// ONE bundle under a fresh ANCHOR KEY, and the anchor key is locked only with
// what opened that device's library on the day it left, never with anything
// the Apple account or the login password reaches:
//   - on the device that presses Use Standard: under the passphrase and the
//     words typed there;
//   - on a device that follows out of Castle: under the secret typed at its
//     follow, AND under the outgoing Castle key itself, with that key's own
//     locks from the device's key file copied beside it (its passphrase or
//     words wrap, its master wrap and the master's words copy) — the master's
//     road left out when the vault's master is still the Castle-era one.
// Both are BIRTH-TIME locks. The anchor is never re-locked after it's written:
// no API here changes a lock, and every later re-key carries it byte for byte.
// It rides frozen into every later backup pair. It folds back in when the
// library enters Castle again (`KeyFileCrossings.swift`).
//
// THE BUNDLE is AES-256-GCM under the anchor key, its additional data binding
// the outgoing key's fingerprint (so the clear metadata can't be swapped onto
// another anchor's bundle); the LOCKS are RFC 3394, as every other lock. No
// value here ever holds a master under the passphrase (§3.5a: the vault's
// passphrase-wrapped master is deliberately never copied).

/// The outgoing key's own locks, copied from the follower's key file (§3.4).
public struct CopiedLocks: Codable, Equatable, Sendable {
    /// The outgoing key under the passphrase that device held it under.
    public var passphrase: StoreKeyEnvelope.PassphraseWrap?
    /// The outgoing key under the twelve words.
    public var words: Data?
    /// The outgoing key under the Castle-era master; nil when the master's
    /// road is left out.
    public var master: Data?
    /// That master under the twelve words (§3.5a) — beside `master` only.
    public var masterWordsCopy: Data?

    public init(
        passphrase: StoreKeyEnvelope.PassphraseWrap? = nil, words: Data? = nil,
        master: Data? = nil, masterWordsCopy: Data? = nil
    ) {
        self.passphrase = passphrase
        self.words = words
        self.master = master
        self.masterWordsCopy = masterWordsCopy
    }

    /// Copied from the device's (outgoing) key file. `includeMasterRoad`
    /// false when the vault's master was never changed since Castle (an
    /// older build left without changing it and put it under the old shared
    /// Apple key) — then the master's road is left out (§3.4).
    public static func copying(from keyFile: KeyFile, includeMasterRoad: Bool) -> CopiedLocks {
        CopiedLocks(
            passphrase: keyFile.passphrase, words: keyFile.words,
            master: includeMasterRoad ? keyFile.master : nil,
            masterWordsCopy: includeMasterRoad && keyFile.master != nil ? keyFile.masterWordsCopy : nil)
    }
}

/// The anchor key's locks.
public struct AnchorLocks: Codable, Equatable, Sendable {
    /// The anchor key under the passphrase (the pressing device's; or a
    /// follower's when the passphrase was the secret typed at its follow).
    public var passphrase: StoreKeyEnvelope.PassphraseWrap?
    /// The anchor key under the twelve words.
    public var words: Data?
    /// A follower's: the anchor key under the outgoing Castle key itself.
    public var outgoingKey: Data?
    /// A follower's: the outgoing key's own locks, copied beside.
    public var copiedLocks: CopiedLocks?

    public init(
        passphrase: StoreKeyEnvelope.PassphraseWrap? = nil, words: Data? = nil,
        outgoingKey: Data? = nil, copiedLocks: CopiedLocks? = nil
    ) {
        self.passphrase = passphrase
        self.words = words
        self.outgoingKey = outgoingKey
        self.copiedLocks = copiedLocks
    }
}

/// A secret typed at the act, as the lock it makes.
public enum TypedLock: Sendable {
    case passphrase(PassphraseKey)
    case words(WordsKey)
}

/// What the anchor is locked with at its birth (§3.4).
public enum AnchorLockInputs: Sendable {
    /// The device that presses Use Standard: the passphrase and the words
    /// typed there (both — decision 33's door; the words are never made new).
    case pressingDevice(passphrase: PassphraseKey, words: WordsKey)
    /// A device that follows out of Castle: the secret typed at its follow,
    /// plus the outgoing key with its own locks copied from `outgoingKeyFile`.
    case follower(typed: TypedLock, outgoingKeyFile: KeyFile, includeMasterRoad: Bool)
}

/// What the anchor's locks are — readable without any secret; what the
/// route finder's *Opens with* line speaks from (U2).
public struct AnchorRoads: Equatable, Sendable {
    public var passphrase: Bool
    public var words: Bool
    /// The outgoing key through its copied passphrase wrap.
    public var copiedPassphrase: Bool
    /// The outgoing key through its copied words wrap.
    public var copiedWords: Bool
    /// The words → the copied master → the outgoing key.
    public var copiedMasterThroughWords: Bool

    /// Does the passphrase of SOME day open it (directly or through the
    /// copied locks)? False on a words-only follower — whose copies' line
    /// then says the twelve words, not the passphrase (§3.4).
    public var opensWithAPassphrase: Bool { passphrase || copiedPassphrase }
    public var opensWithTheWords: Bool { words || copiedWords || copiedMasterThroughWords }
}

/// An opened anchor.
public struct AnchorContents: Sendable, Equatable {
    public var outgoing: OpenedKey
    public var history: [OpenedKey]
    public var keptAnchors: [CastleAnchor]

    /// The outgoing key and its history, newest first.
    public var keys: [OpenedKey] { [outgoing] + history }
}

public struct CastleAnchor: Codable, Equatable, Sendable {
    /// The day of the leave — "the passphrase or words you had on 12
    /// October" (§3.11).
    public var madeAt: Date
    /// The device that wrote it (a device identity).
    public var madeBy: String?
    public var outgoingFingerprint: String
    public var outgoingEpoch: Int
    /// Every key inside — the outgoing one, its history, and what the kept
    /// anchors hold — named in the clear (fingerprints are not secret), so the
    /// catalog knows what an anchor holds without opening it.
    public var heldFingerprints: [String]
    /// AES-256-GCM (combined) under the anchor key.
    public var bundle: Data
    public var locks: AnchorLocks

    /// FORMAT: the bundle's additional-data prefix.
    static let aadPrefix = "variorum.castle-anchor.v1:"

    public var roads: AnchorRoads {
        AnchorRoads(
            passphrase: locks.passphrase != nil,
            words: locks.words != nil,
            copiedPassphrase: locks.outgoingKey != nil && locks.copiedLocks?.passphrase != nil,
            copiedWords: locks.outgoingKey != nil && locks.copiedLocks?.words != nil,
            copiedMasterThroughWords: locks.outgoingKey != nil && locks.copiedLocks?.master != nil
                && locks.copiedLocks?.masterWordsCopy != nil)
    }

    // MARK: - Sealing (once, at its birth)

    /// Seal the outgoing key file's current key, its whole history, its kept
    /// anchors (and an anchor it still carries) into one anchor.
    public static func sealing(
        outgoingKeyFile: KeyFile, outgoingKey: StoreKey, locks: AnchorLockInputs,
        madeAt: Date, madeBy: String?
    ) throws -> CastleAnchor {
        try sealing(
            outgoingKeyFile: outgoingKeyFile, outgoingKey: outgoingKey, locks: locks,
            madeAt: madeAt, madeBy: madeBy, anchorKey: SymmetricKey(size: .bits256))
    }

    /// The same with the anchor key given — internal, for the secret scans
    /// (which must know the key to prove it never lands in a stored value).
    static func sealing(
        outgoingKeyFile: KeyFile, outgoingKey: StoreKey, locks: AnchorLockInputs,
        madeAt: Date, madeBy: String?, anchorKey: SymmetricKey
    ) throws -> CastleAnchor {
        guard StoreKeyEnvelope.fingerprint(of: outgoingKey) == outgoingKeyFile.fingerprint else {
            throw KeyFileError.keyIsNotThisFilesKey
        }
        let history = try outgoingKeyFile.historyKeys(currentKey: outgoingKey)
        let kept = outgoingKeyFile.keptAnchors + [outgoingKeyFile.anchor].compactMap { $0 }
        let bundle = SealedBundle(
            outgoing: BundledKey(
                fingerprint: outgoingKeyFile.fingerprint, epoch: outgoingKeyFile.epoch,
                retiredAt: madeAt, key: outgoingKey.data),
            history: history.map {
                BundledKey(fingerprint: $0.fingerprint, epoch: $0.epoch, retiredAt: $0.retiredAt, key: $0.key.data)
            },
            keptAnchors: kept)
        let sealed: Data
        do {
            let box = try AES.GCM.seal(
                try ProtectionCoding.canonical(bundle), using: anchorKey,
                authenticating: Data((aadPrefix + outgoingKeyFile.fingerprint).utf8))
            guard let combined = box.combined else { throw KeyFileError.wrapFailed }
            sealed = combined
        } catch let error as KeyFileError {
            throw error
        } catch {
            throw KeyFileError.wrapFailed
        }
        let anchorBytes = anchorKey.withUnsafeBytes { Data($0) }
        var anchorLocks = AnchorLocks()
        switch locks {
        case .pressingDevice(let passphrase, let words):
            anchorLocks.passphrase = StoreKeyEnvelope.PassphraseWrap(
                kdf: passphrase.kdf, wrapped: try Lock.wrap(anchorBytes, under: passphrase.key))
            anchorLocks.words = try Lock.wrap(anchorBytes, under: words.key)
        case .follower(let typed, let keyFile, let includeMasterRoad):
            guard keyFile.fingerprint == outgoingKeyFile.fingerprint else { throw KeyFileError.keyIsNotThisFilesKey }
            switch typed {
            case .passphrase(let passphrase):
                anchorLocks.passphrase = StoreKeyEnvelope.PassphraseWrap(
                    kdf: passphrase.kdf, wrapped: try Lock.wrap(anchorBytes, under: passphrase.key))
            case .words(let words):
                anchorLocks.words = try Lock.wrap(anchorBytes, under: words.key)
            }
            anchorLocks.outgoingKey = try Lock.wrap(anchorBytes, under: SymmetricKey(data: outgoingKey.data))
            anchorLocks.copiedLocks = CopiedLocks.copying(from: keyFile, includeMasterRoad: includeMasterRoad)
        }
        var held = [outgoingKeyFile.fingerprint] + history.map(\.fingerprint)
        for anchor in kept { held += anchor.heldFingerprints }
        var seen = Set<String>()
        return CastleAnchor(
            madeAt: madeAt, madeBy: madeBy, outgoingFingerprint: outgoingKeyFile.fingerprint,
            outgoingEpoch: outgoingKeyFile.epoch, heldFingerprints: held.filter { seen.insert($0).inserted },
            bundle: sealed, locks: anchorLocks)
    }

    // MARK: - Opening (with the secrets of its day)

    /// Open with a secret: its own lock first, then — on a follower's anchor —
    /// the outgoing key through the copied locks.
    public func open(_ secret: ProtectionSecret, floor: PassphraseKDF.Floor = PassphraseKDF.floor) throws -> AnchorContents {
        if let key = try anchorKey(secret, floor: floor) { return try openBundle(anchorKey: key) }
        throw KeyFileError.anchorDoesNotOpen
    }

    /// Open with the outgoing Castle key itself (a follower's anchor only —
    /// the route finder's road when that key is reached some other way).
    public func open(outgoingKey: StoreKey) throws -> AnchorContents {
        guard let lock = locks.outgoingKey,
              StoreKeyEnvelope.fingerprint(of: outgoingKey) == outgoingFingerprint,
              let bytes = Lock.unwrap(lock, under: SymmetricKey(data: outgoingKey.data))
        else { throw KeyFileError.anchorDoesNotOpen }
        return try openBundle(anchorKey: SymmetricKey(data: bytes))
    }

    /// Whether `secret` opens this anchor (by any of its roads).
    public func opens(with secret: ProtectionSecret, floor: PassphraseKDF.Floor = PassphraseKDF.floor) -> Bool {
        (try? open(secret, floor: floor)) != nil
    }

    private func anchorKey(_ secret: ProtectionSecret, floor: PassphraseKDF.Floor) throws -> SymmetricKey? {
        // The anchor's own locks.
        if let wrap = locks.passphrase, let wrapping = try secret.passphraseKey(for: wrap.kdf, floor: floor),
           let bytes = Lock.unwrap(wrap.wrapped, under: wrapping) {
            return SymmetricKey(data: bytes)
        }
        if let blob = locks.words, let wrapping = try secret.wordsKey(),
           let bytes = Lock.unwrap(blob, under: wrapping) {
            return SymmetricKey(data: bytes)
        }
        // A follower's: the outgoing key through its copied locks.
        guard let lock = locks.outgoingKey, let copied = locks.copiedLocks else { return nil }
        var outgoing: StoreKey?
        if let wrap = copied.passphrase, let wrapping = try secret.passphraseKey(for: wrap.kdf, floor: floor) {
            outgoing = Lock.unwrapStoreKey(wrap.wrapped, under: wrapping)
        }
        if outgoing == nil, let blob = copied.words, let wrapping = try secret.wordsKey() {
            outgoing = Lock.unwrapStoreKey(blob, under: wrapping)
        }
        if outgoing == nil, let masterWrap = copied.master, let copy = copied.masterWordsCopy,
           let wrapping = try secret.wordsKey(), let master = Lock.unwrap(copy, under: wrapping) {
            outgoing = Lock.unwrapStoreKey(masterWrap, under: SymmetricKey(data: master))
        }
        guard let outgoing, StoreKeyEnvelope.fingerprint(of: outgoing) == outgoingFingerprint,
              let bytes = Lock.unwrap(lock, under: SymmetricKey(data: outgoing.data))
        else { return nil }
        return SymmetricKey(data: bytes)
    }

    private func openBundle(anchorKey: SymmetricKey) throws -> AnchorContents {
        let plain: Data
        do {
            plain = try AES.GCM.open(
                try AES.GCM.SealedBox(combined: bundle), using: anchorKey,
                authenticating: Data((Self.aadPrefix + outgoingFingerprint).utf8))
        } catch {
            throw KeyFileError.anchorBundleUnreadable
        }
        guard let decoded = try? ProtectionCoding.decoder().decode(SealedBundle.self, from: plain) else {
            throw KeyFileError.anchorBundleUnreadable
        }
        func opened(_ bundled: BundledKey) throws -> OpenedKey {
            guard let key = StoreKey(data: bundled.key),
                  StoreKeyEnvelope.fingerprint(of: key) == bundled.fingerprint
            else { throw KeyFileError.anchorBundleUnreadable }
            return OpenedKey(fingerprint: bundled.fingerprint, epoch: bundled.epoch, retiredAt: bundled.retiredAt, key: key)
        }
        let outgoing = try opened(decoded.outgoing)
        guard outgoing.fingerprint == outgoingFingerprint else { throw KeyFileError.anchorBundleUnreadable }
        return AnchorContents(
            outgoing: outgoing, history: try decoded.history.map(opened), keptAnchors: decoded.keptAnchors)
    }

    /// The bundle, as sealed (never stored in the clear).
    struct SealedBundle: Codable {
        var outgoing: BundledKey
        var history: [BundledKey]
        var keptAnchors: [CastleAnchor]
    }

    struct BundledKey: Codable {
        var fingerprint: String
        var epoch: Int
        var retiredAt: Date?
        var key: Data
    }
}
