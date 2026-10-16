import CryptoKit
import Foundation

// VX-305 U1 — RE-KEYING (rule 4, `notes/CastleRules.md`: "every key change
// carries that list forward — no exceptions"). A new key's history takes the
// outgoing key and every key the outgoing file's history holds — entering
// Castle, leaving it, Replace All Keys, a follow, alike; each wrapped directly
// under the new key, so the current key (and so the current passphrase or
// words) opens every earlier key, and a key opens older keys, never newer
// ones. (The Castle anchor, the leave's empty history and the entry's anchor
// fold left with VX-378 U1 — rules 4, 12, 13.) These are pure values: the
// executor (U3) writes them, in prepare-then-commit order.

/// What the new key is locked under in its new file.
public struct NewKeyLocks: Sendable {
    public var passphrase: PassphraseKey?
    public var words: WordsKey?
    /// The account's master (when bound), with the vault's recovery wrap —
    /// the master's twelve-words copy — beside it (§3.5a).
    public var master: SymmetricKey?
    public var masterWordsCopy: Data?
    /// This Mac's own Apple key for the library — a Standard key only.
    public var apple: AppleKeyMaterial?

    public init(
        passphrase: PassphraseKey? = nil, words: WordsKey? = nil, master: SymmetricKey? = nil,
        masterWordsCopy: Data? = nil, apple: AppleKeyMaterial? = nil
    ) {
        self.passphrase = passphrase
        self.words = words
        self.master = master
        self.masterWordsCopy = masterWordsCopy
        self.apple = apple
    }
}

extension KeyFile {
    /// A NEW file for a key with no past — a library's creation, or a
    /// different library's landing (§3.7: "a fresh key with no history").
    public static func building(
        libraryID: String, key: StoreKey, epoch: Int, locks: NewKeyLocks
    ) throws -> KeyFile {
        try KeyFile(libraryID: libraryID, key: key, epoch: epoch).locking(key, with: locks)
    }

    /// **The re-key**: a new file for `newKey` (of `kind`), built from this
    /// one (whose current key is `currentKey`) — its history the outgoing key
    /// and every key this history holds (rule 4). A Castle key never takes an
    /// Apple lock (rule 9).
    public func rekeyed(
        from currentKey: StoreKey, to newKey: StoreKey, kind: ProtectionMode, locks: NewKeyLocks, at: Date
    ) throws -> KeyFile {
        guard StoreKeyEnvelope.fingerprint(of: currentKey) == fingerprint else {
            throw KeyFileError.keyIsNotThisFilesKey
        }
        guard newKey != currentKey else { throw KeyFileError.newKeyIsTheCurrentKey }
        guard kind == .standard || locks.apple == nil else { throw KeyFileError.appleWrapOnACastleKey }
        var next = KeyFile(libraryID: libraryID, key: newKey, epoch: epoch + 1)
        let outgoing = OpenedKey(fingerprint: fingerprint, epoch: epoch, retiredAt: at, key: currentKey)
        next.history = try Self.wrapping([outgoing] + historyKeys(currentKey: currentKey), under: newKey)
        return try next.locking(newKey, with: locks)
    }

    /// Lock this file's current key under `locks`.
    func locking(_ key: StoreKey, with locks: NewKeyLocks) throws -> KeyFile {
        var file = self
        if let passphrase = locks.passphrase { file = try file.settingPassphrase(passphrase, for: key) }
        if let words = locks.words { file = try file.settingWords(words, for: key) }
        if let master = locks.master {
            file = try file.settingMaster(master, wordsCopy: locks.masterWordsCopy, for: key)
        }
        if let apple = locks.apple { file = try file.settingApple(apple, for: key) }
        return file
    }

    /// Wrap the taken keys directly under the new key — one entry per
    /// fingerprint (the first wins), never the new key itself.
    private static func wrapping(_ keys: [OpenedKey], under newKey: StoreKey) throws -> [HistoryEntry] {
        let newFingerprint = StoreKeyEnvelope.fingerprint(of: newKey)
        var seen: Set<String> = [newFingerprint]
        var entries: [HistoryEntry] = []
        for key in keys where seen.insert(key.fingerprint).inserted {
            entries.append(HistoryEntry(
                fingerprint: key.fingerprint, epoch: key.epoch, retiredAt: key.retiredAt ?? .distantPast,
                wrapped: try Lock.wrap(key.key.data, under: SymmetricKey(data: newKey.data))))
        }
        return entries
    }
}
