import CryptoKit
import Foundation

// VX-305 U1 — RE-KEYING (design §3.4; her rulings of 2026-10-13, §1: "a fresh
// key whenever the library crosses a line", "history flows into Castle, never
// out"). What the NEW key's history takes:
//   - ENTERING CASTLE — everything: the old key, its history, and the anchor
//     (with any earlier anchor kept inside it), opened with the secrets typed
//     at the door (both) or at the follow (one). An anchor those secrets can't
//     open is KEPT beside the history, unchanged — it never fails the entry,
//     keeps opening with the secrets of its day, and a later leave seals it
//     inside the new anchor.
//   - WITHIN A MODE (Replace All Keys, a follow that keeps the mode, leaving an
//     account): the old key and its history, with the anchor (and any kept
//     anchors) carried unchanged.
//   - LEAVING CASTLE — nothing: the new key starts with an empty history, and
//     everything from before the leave is in the anchor, WRITTEN FIRST into
//     the outgoing file (`writingAnchor`) and carried into the new one.
//   - A DIFFERENT LIBRARY LANDING — nothing (`building`): the sent pair keeps
//     its own locks.
// The history wraps each key it takes directly under the new key; the old key
// (in hand during any re-key) opens the old history. A key opens older keys,
// never newer ones. These are pure values: the executor (U3) writes them, in
// prepare-then-commit order.

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

public enum KeyFileCrossing: Sendable {
    case withinMode
    /// `openers`: the secrets typed at the door or the follow — tried on the
    /// anchor and on every kept anchor.
    case enteringCastle(openers: [ProtectionSecret])
    case leavingCastle
}

public struct RekeyOutcome: Sendable, Equatable {
    public var keyFile: KeyFile
    /// Anchors the entry into Castle could not open — kept beside the history,
    /// listed in Diagnostics; the door says which secrets, of which day, still
    /// open the copies they hold (§3.4, §3.9).
    public var unopenedAnchors: [CastleAnchor]
}

extension KeyFile {
    /// A NEW file for a key with no past — a library's creation, or a
    /// different library's landing (§3.7: "a fresh key with no history").
    public static func building(
        libraryID: String, key: StoreKey, epoch: Int, locks: NewKeyLocks
    ) throws -> KeyFile {
        try KeyFile(libraryID: libraryID, key: key, epoch: epoch).locking(key, with: locks)
    }

    /// The anchor FIRST (§3.4, §3.9): written into the outgoing (current) key
    /// file before any other step of a leave. It must be this key's anchor.
    public func writingAnchor(_ anchor: CastleAnchor) throws -> KeyFile {
        guard anchor.outgoingFingerprint == fingerprint, anchor.outgoingEpoch == epoch else {
            throw KeyFileError.anchorIsNotThisKeysAnchor
        }
        var next = self
        next.anchor = anchor
        return next
    }

    /// **The crossing**: a new file for `newKey`, built from this one (whose
    /// current key is `currentKey`).
    public func rekeyed(
        _ crossing: KeyFileCrossing, from currentKey: StoreKey, to newKey: StoreKey,
        locks: NewKeyLocks, at: Date, guards: ProtectionGuards = .all,
        floor: PassphraseKDF.Floor = PassphraseKDF.floor
    ) throws -> RekeyOutcome {
        guard StoreKeyEnvelope.fingerprint(of: currentKey) == fingerprint else {
            throw KeyFileError.keyIsNotThisFilesKey
        }
        guard newKey != currentKey else { throw KeyFileError.newKeyIsTheCurrentKey }
        var next = KeyFile(libraryID: libraryID, key: newKey, epoch: epoch + 1)
        let outgoing = OpenedKey(fingerprint: fingerprint, epoch: epoch, retiredAt: at, key: currentKey)
        var unopened: [CastleAnchor] = []
        switch crossing {
        case .withinMode:
            next.history = try Self.wrapping([outgoing] + historyKeys(currentKey: currentKey), under: newKey)
            if guards.anchorCarriedByEveryRekeyOn {
                next.anchor = anchor
                next.keptAnchors = keptAnchors
            }
        case .enteringCastle(let openers):
            guard locks.apple == nil else { throw KeyFileError.appleWrapOnACastleKey }
            var taken = [outgoing] + (try historyKeys(currentKey: currentKey))
            var queue = [anchor].compactMap { $0 } + keptAnchors
            while !queue.isEmpty {
                let candidate = queue.removeFirst()
                if let contents = openers.lazy.compactMap({ try? candidate.open($0, floor: floor) }).first {
                    taken += contents.keys.map {
                        var key = $0
                        key.retiredAt = key.retiredAt ?? candidate.madeAt
                        return key
                    }
                    queue += contents.keptAnchors
                } else {
                    unopened.append(candidate)
                }
            }
            next.history = try Self.wrapping(taken, under: newKey)
            next.keptAnchors = unopened
        case .leavingCastle:
            if guards.anchorWrittenFirstOn {
                guard let anchor, anchor.outgoingFingerprint == fingerprint else {
                    throw KeyFileError.anchorNotWrittenFirst
                }
            }
            next.anchor = anchor
        }
        return RekeyOutcome(keyFile: try next.locking(newKey, with: locks), unopenedAnchors: unopened)
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
