import CryptoKit
import Foundation

// VX-305 U1 — THE KEY FILE, FORMAT 3 (design §3.2, §3.4, §3.5, §3.5a). ONE file
// beside the library, `variorum-library-keys.json` (a name older builds never
// read), and — for another library this Mac holds copies of whose newest copy
// is in Standard — this Mac's own key file for it in `Backups/<library8>/
// <mac8>/` (the same format). Each backup pair carries a frozen copy, never
// rewritten. It holds:
//   - the current key's WRAPS: under the passphrase (with its KDF
//     descriptor), the twelve words, the account's master (when bound), and —
//     a Standard key only — this Mac's own Apple key for the library, naming
//     its id (the old shared key's wrap left with rule 26);
//   - THE HISTORY: every earlier key the library has had, each wrapped
//     directly under the current key, with fingerprint, epoch and retirement
//     date — carried forward by every key change, no exceptions (rule 4; the
//     Castle anchor left with VX-378 U1);
//   - the master's twelve-words copy, when the file has a master wrap (§3.5a).
// Every byte is non-secret: holding the file grants nothing without a secret.
// The crossings that build a new file from an old one are
// `KeyFileCrossings.swift`.

public enum KeyFileError: Error, Equatable, Sendable {
    /// No wrap of this road exists in the file.
    case noSuchWrap(KeyFileRoad)
    /// The secret or key offered does not open that wrap.
    case doesNotOpen(KeyFileRoad)
    /// A wrap opened to a key whose fingerprint is not the file's (a planted
    /// or confused file) — refused, never used.
    case wrapsAnotherKey(KeyFileRoad)
    /// The key offered for a write is not this file's current key.
    case keyIsNotThisFilesKey
    /// An Apple wrap names another Apple key than the one offered.
    case appleKeyMismatch(expected: String, offered: String)
    /// A history entry did not open under the current key, or opened to
    /// another key than it names.
    case historyEntryDoesNotOpen(String)
    /// A Castle key never has an Apple wrap (rule 9) — a re-key to a Castle
    /// key refuses an Apple lock.
    case appleWrapOnACastleKey
    /// A re-key to the key already current.
    case newKeyIsTheCurrentKey
    /// A new key file the twelve words would not open — neither a words lock
    /// nor the master with its twelve-words copy (rule 2: "there is no such
    /// thing as a library with no secret").
    case noWordsLock
    /// A file whose format is not 3 (rule 26: an older format is not read).
    case notFormat3(Int)
    /// A file written by a newer build — refused, never guessed.
    case newerFormat(Int)
    case wrapFailed
    /// Bytes that are not a key file (decode/IO failure carried). VX-329 U1: today's envelope's `unreadable` case,
    /// re-homed here with the envelope's deletion.
    case unreadable(String)
    /// An empty passphrase is never legal (the 14b floor, kept). VX-329 U1: re-homed from today's envelope.
    case emptyPassphrase
}

/// The roads into a key file's current key — the vocabulary refusals, the
/// route finder (U2) and the words speak.
public enum KeyFileRoad: String, Codable, Sendable, CaseIterable {
    case passphrase
    case words
    case master
    /// The master's twelve-words copy → the master → the master wrap.
    case masterThroughWords = "master_through_words"
    case apple
}

/// A passphrase wrap: the current key under the passphrase-derived key, with the KDF descriptor it was derived under
/// (the descriptor is truth — never re-derive from app defaults). VX-329 U1: relocated byte-for-byte from today's
/// envelope (`PassphraseWrap`, deleted with today's road) — the same two coding keys, `kdf` and
/// `wrapped`, so a format-3 key file's bytes are unchanged.
public struct PassphraseWrap: Codable, Equatable, Sendable {
    public var kdf: PassphraseKDF.Descriptor
    public var wrapped: Data

    public init(kdf: PassphraseKDF.Descriptor, wrapped: Data) {
        self.kdf = kdf
        self.wrapped = wrapped
    }
}

/// An Apple wrap: the current key under an Apple key, naming its id.
public struct AppleWrap: Codable, Equatable, Sendable {
    public var keyID: String
    public var wrapped: Data

    public init(keyID: String, wrapped: Data) {
        self.keyID = keyID
        self.wrapped = wrapped
    }
}

/// One older key the current key takes (§3.4): wrapped DIRECTLY under the
/// current key, with its fingerprint, epoch and retirement date.
public struct HistoryEntry: Codable, Equatable, Sendable {
    public var fingerprint: String
    public var epoch: Int
    public var retiredAt: Date
    public var wrapped: Data

    public init(fingerprint: String, epoch: Int, retiredAt: Date, wrapped: Data) {
        self.fingerprint = fingerprint
        self.epoch = epoch
        self.retiredAt = retiredAt
        self.wrapped = wrapped
    }
}

/// An older key, opened.
public struct OpenedKey: Sendable, Equatable {
    public var fingerprint: String
    public var epoch: Int
    public var retiredAt: Date?
    public var key: StoreKey

    public init(fingerprint: String, epoch: Int, retiredAt: Date?, key: StoreKey) {
        self.fingerprint = fingerprint
        self.epoch = epoch
        self.retiredAt = retiredAt
        self.key = key
    }
}

public struct KeyFile: Codable, Equatable, Sendable {
    public static let currentFormatVersion = 3

    public var formatVersion: Int
    public var libraryID: String
    /// The current key's fingerprint and epoch.
    public var fingerprint: String
    public var epoch: Int
    public var passphrase: PassphraseWrap?
    public var words: Data?
    public var master: Data?
    /// The master wrapped under the twelve words — the vault's recovery wrap,
    /// copied byte for byte (§3.5a). Present only beside a master wrap.
    public var masterWordsCopy: Data?
    /// This Mac's own Apple key for the library (a Standard key only).
    public var apple: AppleWrap?
    public var history: [HistoryEntry]

    public init(
        formatVersion: Int = KeyFile.currentFormatVersion, libraryID: String, fingerprint: String,
        epoch: Int, passphrase: PassphraseWrap? = nil, words: Data? = nil,
        master: Data? = nil, masterWordsCopy: Data? = nil, apple: AppleWrap? = nil,
        history: [HistoryEntry] = []
    ) {
        self.formatVersion = formatVersion
        self.libraryID = libraryID
        self.fingerprint = fingerprint
        self.epoch = epoch
        self.passphrase = passphrase
        self.words = words
        self.master = master
        self.masterWordsCopy = masterWordsCopy
        self.apple = apple
        self.history = history
    }

    /// A wraps-less file for `key` (the builders add the wraps).
    public init(libraryID: String, key: StoreKey, epoch: Int) {
        self.init(libraryID: libraryID, fingerprint: KeyFingerprint.of(key), epoch: epoch)
    }

    // MARK: - The current key's wraps (the key doors re-wrap these and nothing else)

    private func requireOwnKey(_ key: StoreKey) throws {
        guard KeyFingerprint.of(key) == fingerprint else { throw KeyFileError.keyIsNotThisFilesKey }
    }

    /// The passphrase wrap, set or replaced — the history is untouched (rule 6:
    /// re-locking the current key, never a new key).
    public func settingPassphrase(_ passphrase: PassphraseKey, for key: StoreKey) throws -> KeyFile {
        try requireOwnKey(key)
        var next = self
        next.passphrase = PassphraseWrap(
            kdf: passphrase.kdf, wrapped: try Lock.wrap(key.data, under: passphrase.key))
        return next
    }

    public func settingWords(_ words: WordsKey, for key: StoreKey) throws -> KeyFile {
        try requireOwnKey(key)
        var next = self
        next.words = try Lock.wrap(key.data, under: words.key)
        return next
    }

    /// The master wrap with the master's twelve-words copy beside it (§3.5a:
    /// every key file with a master wrap carries it, when the vault has one).
    public func settingMaster(_ master: SymmetricKey, wordsCopy: Data?, for key: StoreKey) throws -> KeyFile {
        try requireOwnKey(key)
        var next = self
        next.master = try Lock.wrap(key.data, under: master)
        next.masterWordsCopy = wordsCopy
        return next
    }

    /// §3.5a: refreshed from the vault while that master is current (after the
    /// words are regenerated, say) — only beside a master wrap.
    public func refreshingMasterWordsCopy(_ wordsCopy: Data?) -> KeyFile {
        guard master != nil else { return self }
        var next = self
        next.masterWordsCopy = wordsCopy
        return next
    }

    /// This Mac's own Apple key's wrap (a Standard key only — the caller's
    /// rule; `assess` treats an Apple wrap on a Castle key as a fault).
    public func settingApple(_ apple: AppleKeyMaterial, for key: StoreKey) throws -> KeyFile {
        try requireOwnKey(key)
        var next = self
        next.apple = AppleWrap(keyID: apple.id, wrapped: try Lock.wrap(key.data, under: apple.key))
        return next
    }

    public func droppingApple() -> KeyFile {
        var next = self
        next.apple = nil
        return next
    }

    /// The library's own words lock dropped — VX-529: a STALE one, after the account's twelve words were re-made on
    /// another device (rule 7's one pair: the old words stop opening the live library; they still open the backups made
    /// with them, rules 4–5). The words then open the file through the master's twelve-words copy alone — the caller's
    /// rule: never without that copy beside a master lock (`opensWithTheWords`; `relockedToTheAccountsPair` checks it).
    public func droppingWords() -> KeyFile {
        var next = self
        next.words = nil
        return next
    }

    // MARK: - Opening the current key (every road verifies itself)

    private func verified(_ key: StoreKey?, _ road: KeyFileRoad) throws -> StoreKey {
        guard let key else { throw KeyFileError.doesNotOpen(road) }
        guard KeyFingerprint.of(key) == fingerprint else { throw KeyFileError.wrapsAnotherKey(road) }
        return key
    }

    public func open(passphrase secret: ProtectionSecret, floor: PassphraseKDF.Floor = PassphraseKDF.floor) throws -> StoreKey {
        guard let wrap = passphrase else { throw KeyFileError.noSuchWrap(.passphrase) }
        guard let wrapping = try secret.passphraseKey(for: wrap.kdf, floor: floor) else {
            throw KeyFileError.doesNotOpen(.passphrase)
        }
        return try verified(Lock.unwrapStoreKey(wrap.wrapped, under: wrapping), .passphrase)
    }

    public func open(words: [String]) throws -> StoreKey {
        guard let blob = self.words else { throw KeyFileError.noSuchWrap(.words) }
        return try verified(Lock.unwrapStoreKey(blob, under: try RecoveryPhrase.recoveryWrapKey(words: words)), .words)
    }

    public func open(master: SymmetricKey) throws -> StoreKey {
        guard let blob = self.master else { throw KeyFileError.noSuchWrap(.master) }
        return try verified(Lock.unwrapStoreKey(blob, under: master), .master)
    }

    /// The master's twelve-words copy opened with the words (§3.5a).
    public func openMaster(words: [String]) throws -> SymmetricKey {
        guard let copy = masterWordsCopy else { throw KeyFileError.noSuchWrap(.masterThroughWords) }
        guard let bytes = Lock.unwrap(copy, under: try RecoveryPhrase.recoveryWrapKey(words: words)) else {
            throw KeyFileError.doesNotOpen(.masterThroughWords)
        }
        return SymmetricKey(data: bytes)
    }

    /// The words → the master → the library key (§3.5a: "so the words always
    /// open the file").
    public func open(wordsThroughMaster words: [String]) throws -> StoreKey {
        let master = try openMaster(words: words)
        do {
            return try open(master: master)
        } catch KeyFileError.doesNotOpen {
            throw KeyFileError.doesNotOpen(.masterThroughWords)
        }
    }

    /// Any secret, by every road it can take: the passphrase wrap; the words
    /// wrap, then the words through the master's copy.
    public func open(_ secret: ProtectionSecret, floor: PassphraseKDF.Floor = PassphraseKDF.floor) throws -> StoreKey {
        if case .words(let words) = secret {
            if self.words != nil, let key = try? open(words: words) { return key }
            if masterWordsCopy != nil, master != nil { return try open(wordsThroughMaster: words) }
            return try open(words: words)
        }
        return try open(passphrase: secret, floor: floor)
    }

    public func open(apple: AppleKeyMaterial) throws -> StoreKey {
        guard let wrap = self.apple else { throw KeyFileError.noSuchWrap(.apple) }
        guard wrap.keyID == apple.id else {
            throw KeyFileError.appleKeyMismatch(expected: wrap.keyID, offered: apple.id)
        }
        return try verified(Lock.unwrapStoreKey(wrap.wrapped, under: apple.key), .apple)
    }

    /// The twelve words open this file — by its words lock, or through the
    /// master's twelve-words copy beside a master lock (rule 2).
    public var opensWithTheWords: Bool { words != nil || (master != nil && masterWordsCopy != nil) }

    /// The roads this file carries (no secret needed to tell).
    public var roads: Set<KeyFileRoad> {
        var roads: Set<KeyFileRoad> = []
        if passphrase != nil { roads.insert(.passphrase) }
        if words != nil { roads.insert(.words) }
        if master != nil { roads.insert(.master) }
        if master != nil, masterWordsCopy != nil { roads.insert(.masterThroughWords) }
        if apple != nil { roads.insert(.apple) }
        return roads
    }

    // MARK: - The history (runs backwards only: the current key opens older keys)

    /// Every older key, opened with the current key — each verified against
    /// the fingerprint its entry names.
    public func historyKeys(currentKey: StoreKey) throws -> [OpenedKey] {
        try requireOwnKey(currentKey)
        return try history.map { entry in
            guard let key = Lock.unwrapStoreKey(entry.wrapped, under: SymmetricKey(data: currentKey.data)),
                  KeyFingerprint.of(key) == entry.fingerprint
            else { throw KeyFileError.historyEntryDoesNotOpen(entry.fingerprint) }
            return OpenedKey(fingerprint: entry.fingerprint, epoch: entry.epoch, retiredAt: entry.retiredAt, key: key)
        }
    }

    /// One older key by fingerprint, through the history (nil when the
    /// history doesn't hold it).
    public func historyKey(_ fingerprint: String, currentKey: StoreKey) throws -> StoreKey? {
        try historyKeys(currentKey: currentKey).first { $0.fingerprint == fingerprint }?.key
    }

    /// Every fingerprint this file can lead to, without any secret: its
    /// current key and its history — what the catalog and the route finder
    /// read (§3.7).
    public var heldFingerprints: [String] {
        var seen = Set<String>()
        return ([fingerprint] + history.map(\.fingerprint)).filter { seen.insert($0).inserted }
    }

    // MARK: - The file

    /// A key file from its bytes — format 3 only (rule 26: a file of an older
    /// format is not read, and says nothing); a newer format refuses, never
    /// guessed; bytes that are not a key file throw `unreadable`.
    public static func decode(_ data: Data) throws -> KeyFile {
        struct Probe: Decodable { var formatVersion: Int }
        guard let probe = try? JSONDecoder().decode(Probe.self, from: data) else {
            throw KeyFileError.unreadable("not a key file")
        }
        guard probe.formatVersion == currentFormatVersion else {
            throw probe.formatVersion > currentFormatVersion
                ? KeyFileError.newerFormat(probe.formatVersion) : KeyFileError.notFormat3(probe.formatVersion)
        }
        do {
            return try ProtectionCoding.decoder().decode(KeyFile.self, from: data)
        } catch {
            throw KeyFileError.unreadable(String(describing: error))
        }
    }

    public func encoded() throws -> Data {
        let encoder = ProtectionCoding.canonicalEncoder()
        encoder.outputFormatting.insert(.prettyPrinted)
        return try encoder.encode(self)
    }
}
