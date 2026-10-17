import CryptoKit
import Foundation

// VX-378 U2 — THE ACCOUNT'S VAULT, MODELLED TO THE RULES (`notes/CastleRules.md`
// rules 7, 11, 12, 14, 15). The vault holds the account's master wrapped by the
// passphrase (with its KDF descriptor) and by the twelve words — ONLY those two
// (rule 14: "never by Apple"); a MODE flag, the account's one posture (rules
// 10–12); the CURRENT sync key — the row-sealing key, under the master; and
// EVERY EARLIER sync key the account has had, each sealed under the current
// master (rule 15: "the account keeps every sync key it has ever had … so a
// device joining years later reads everything"). A row is read with the key its
// own key-id label names (14b's AAD already carries it), so no row is ever
// re-encrypted.
//   - The sync key changes ONLY when the account enters Castle — ONE CAS write:
//     a new master, a new sync key, the earlier keys (the outgoing one among
//     them) re-sealed under the new master (rule 11, rule 15).
//   - Leaving Castle flips the MODE flag and changes no key (rule 12: "the
//     server's keys and the library's follow the same one-posture rule").
//   - The key doors re-wrap the master under a new passphrase or new words; the
//     keys stay (rule 6's twin, rule 7: "the key doors change the library's and
//     the account's locks together").
// (Deleted with VX-378 U2 — the rotation of VX-305: the vault's Apple-held copy
// and its key id, the previous corpus key and the rotation seq, the walk that
// re-encrypted rows below it, the completing write, and every wait on them.)
//
// This is the MODEL the acts' order, resume and guards are fixed against. The
// server's `key_vault` change — a SyncSpec §12 lockstep event — is VX-307's;
// nothing here is the wire format. (The dormant journal-bridge class key of the
// 14b format is not modelled: nothing reads it, and its fate in the new row is
// VX-307's to decide.) Wraps are RFC 3394 `AES.KeyWrap`, as everywhere else.

/// A key the vault keeps under the current master: its id (the label rows
/// carry) and its wrap.
public struct VaultKey: Codable, Equatable, Sendable {
    public var keyID: String
    public var wrappedByMaster: Data

    public init(keyID: String, wrappedByMaster: Data) {
        self.keyID = keyID
        self.wrappedByMaster = wrappedByMaster
    }
}

/// **The account's vault row** (rules 14, 15) — non-secret on its own: every
/// key in it is wrapped.
public struct AccountVault: Codable, Equatable, Sendable {
    public static let currentFormatVersion = 1

    public var formatVersion: Int
    /// The passphrase lock's descriptor — truth for every derivation.
    public var kdf: PassphraseKDF.Descriptor
    /// The master under the passphrase.
    public var masterByPassphrase: Data
    /// The master under the twelve words — the account's recovery wrap, copied
    /// byte for byte into every key file with a master lock (old design §3.5a).
    public var masterByWords: Data
    /// THE MODE FLAG — the account's one posture.
    public var mode: ProtectionMode
    /// The CURRENT sync key (rows written now are sealed under it).
    public var rowKey: VaultKey
    /// Every earlier sync key, by its id, each wrapped under the CURRENT master.
    public var earlierRowKeys: [String: Data]
    /// The key proof's hash (`KeyProof.hash(master:)`) — what the server checks
    /// every write against.
    public var keyProofHash: String
    /// The name of the device that last wrote it (decision 34's notices).
    public var updatedByDevice: String?

    public init(
        formatVersion: Int = AccountVault.currentFormatVersion, kdf: PassphraseKDF.Descriptor,
        masterByPassphrase: Data, masterByWords: Data, mode: ProtectionMode, rowKey: VaultKey,
        earlierRowKeys: [String: Data] = [:], keyProofHash: String, updatedByDevice: String? = nil
    ) {
        self.formatVersion = formatVersion
        self.kdf = kdf
        self.masterByPassphrase = masterByPassphrase
        self.masterByWords = masterByWords
        self.mode = mode
        self.rowKey = rowKey
        self.earlierRowKeys = earlierRowKeys
        self.keyProofHash = keyProofHash
        self.updatedByDevice = updatedByDevice
    }

    /// The master, by a typed secret: the passphrase under the vault's own
    /// descriptor, or the words.
    public func master(passphrase: PassphraseKey?, words: WordsKey?) -> SymmetricKey? {
        if let passphrase, passphrase.kdf == kdf, let bytes = Lock.unwrap(masterByPassphrase, under: passphrase.key) {
            return SymmetricKey(data: bytes)
        }
        if let words, let bytes = Lock.unwrap(masterByWords, under: words.key) { return SymmetricKey(data: bytes) }
        return nil
    }

    /// Does `master` hold this vault (its proof)?
    public func isMaster(_ master: SymmetricKey) -> Bool { KeyProof.hash(master: master) == keyProofHash }

    /// Every sync key, opened with the master: the current one and every
    /// earlier one (rule 15).
    public func keys(master: SymmetricKey) throws -> AccountKeys {
        guard isMaster(master), let current = Lock.unwrap(rowKey.wrappedByMaster, under: master) else {
            throw AccountVaultError.notThisVaultsMaster
        }
        var earlier: [String: Data] = [:]
        for (id, wrapped) in earlierRowKeys {
            guard let key = Lock.unwrap(wrapped, under: master) else { throw AccountVaultError.notThisVaultsMaster }
            earlier[id] = key
        }
        return AccountKeys(
            master: VaultModel.bytes(master), rowKeyID: rowKey.keyID, rowKey: current, earlierRowKeys: earlier)
    }
}

public enum AccountVaultError: Error, Equatable, Sendable {
    /// The master offered is not this vault's (its proof, or a wrap, refuses).
    case notThisVaultsMaster
    /// The sync key changes only when the account ENTERS Castle (rule 15).
    case alreadyInCastle
}

/// **The account's sync keys, as a device holds them** (custody — the
/// account's way, rule 15) — the master, the current sync key, and every
/// earlier sync key the account has had (rule 15). Secret: its description is
/// redacted, and it is never logged.
public struct AccountKeys: Codable, Equatable, Sendable, CustomStringConvertible {
    public var master: Data
    public var rowKeyID: String
    public var rowKey: Data
    public var earlierRowKeys: [String: Data]

    public init(master: Data, rowKeyID: String, rowKey: Data, earlierRowKeys: [String: Data] = [:]) {
        self.master = master
        self.rowKeyID = rowKeyID
        self.rowKey = rowKey
        self.earlierRowKeys = earlierRowKeys
    }

    public var masterKey: SymmetricKey { SymmetricKey(data: master) }

    /// THE ROW READER (rule 15): the key a row sealed under `keyID` opens with —
    /// the current sync key or an earlier one, picked by the row's own label.
    public func rowKey(for keyID: String) -> SymmetricKey? {
        if keyID == rowKeyID { return SymmetricKey(data: rowKey) }
        return earlierRowKeys[keyID].map { SymmetricKey(data: $0) }
    }

    public var description: String { "AccountKeys(\(rowKeyID.prefix(8)), \(earlierRowKeys.count) earlier, redacted)" }
}

/// The vault as one fetch read it: the row and its CAS revision.
public struct VaultSnapshot: Equatable, Sendable {
    public var accountID: String
    public var revision: Int
    public var vault: AccountVault
    public var updatedAt: Date?

    public init(accountID: String, revision: Int, vault: AccountVault, updatedAt: Date? = nil) {
        self.accountID = accountID
        self.revision = revision
        self.vault = vault
        self.updatedAt = updatedAt
    }

    /// `assess`'s non-secret reading.
    public var reading: VaultReading {
        VaultReading(
            accountID: accountID, mode: vault.mode, rowKeyID: vault.rowKey.keyID, kdf: vault.kdf,
            recoveryWrap: vault.masterByWords, updatedByDevice: vault.updatedByDevice, updatedAt: updatedAt)
    }

    public var mode: ProtectionMode { vault.mode }
    public var rowKeyID: String { vault.rowKey.keyID }
}

/// Typed refusals the vault (server) gives — the fakes throw these; phase 3
/// maps the client's errors onto them.
public enum VaultRefusal: Error, Equatable, Sendable {
    /// The CAS: another write landed since this device's read.
    case revisionConflict
    /// The proof is not the current master's.
    case keyProofRefused
    case vaultAbsent
    case vaultExists
    /// The network: nothing was read or written.
    case unreachable
    /// The session isn't signed into this account (row-level security):
    /// nothing was read or written.
    case notSignedIn
}

public enum VaultModel {
    /// **A brand-new vault** (sync setup, the first device — rule 7: the
    /// library's pair becomes the account's): a master and a sync key minted;
    /// the master under the passphrase and the words (rule 14); the mode the
    /// library's.
    public static func creating(
        passphrase: PassphraseKey, words: WordsKey, mode: ProtectionMode, device: String, ids: any IDsLeaf
    ) throws -> (vault: AccountVault, keys: AccountKeys) {
        let master = ids.mintSymmetricKey(), rowKey = ids.mintSymmetricKey()
        let rowKeyID = ids.mintID()
        let vault = AccountVault(
            kdf: passphrase.kdf, masterByPassphrase: try Lock.wrap(bytes(master), under: passphrase.key),
            masterByWords: try Lock.wrap(bytes(master), under: words.key), mode: mode,
            rowKey: VaultKey(keyID: rowKeyID, wrappedByMaster: try Lock.wrap(bytes(rowKey), under: master)),
            keyProofHash: KeyProof.hash(master: master), updatedByDevice: device)
        return (vault, AccountKeys(master: bytes(master), rowKeyID: rowKeyID, rowKey: bytes(rowKey)))
    }

    /// **Entering Castle — the ONE write** (rule 11, rule 15): a new master and
    /// a new sync key; the outgoing sync key and every earlier one re-sealed
    /// under the new master; the master under the passphrase typed at the press
    /// (its descriptor reused) and the words; the mode Castle. A device that
    /// has not followed holds only the outgoing master, which opens nothing
    /// here any more — writing made in Castle is sealed under a key no quiet
    /// road holds.
    public static func enteringCastle(
        _ vault: AccountVault, held: AccountKeys, passphrase: PassphraseKey, words: WordsKey, device: String,
        ids: any IDsLeaf
    ) throws -> (vault: AccountVault, keys: AccountKeys) {
        guard vault.mode == .standard else { throw AccountVaultError.alreadyInCastle }
        guard vault.isMaster(held.masterKey), held.rowKeyID == vault.rowKey.keyID else {
            throw AccountVaultError.notThisVaultsMaster
        }
        let master = ids.mintSymmetricKey(), rowKey = ids.mintSymmetricKey()
        let rowKeyID = ids.mintID()
        var earlier = held.earlierRowKeys
        earlier[held.rowKeyID] = held.rowKey
        var next = vault
        next.kdf = passphrase.kdf
        next.masterByPassphrase = try Lock.wrap(bytes(master), under: passphrase.key)
        next.masterByWords = try Lock.wrap(bytes(master), under: words.key)
        next.mode = .castle
        next.rowKey = VaultKey(keyID: rowKeyID, wrappedByMaster: try Lock.wrap(bytes(rowKey), under: master))
        next.earlierRowKeys = try earlier.mapValues { try Lock.wrap($0, under: master) }
        next.keyProofHash = KeyProof.hash(master: master)
        next.updatedByDevice = device
        return (next, AccountKeys(master: bytes(master), rowKeyID: rowKeyID, rowKey: bytes(rowKey), earlierRowKeys: earlier))
    }

    /// **Leaving Castle — the mode flag, flipped** (rule 12): no key changes.
    public static func leavingCastle(_ vault: AccountVault, device: String) -> AccountVault {
        var next = vault
        next.mode = .standard
        next.updatedByDevice = device
        return next
    }

    /// A new passphrase's lock on the master (the key doors — rule 6's twin).
    public static func rewrappingPassphrase(
        _ vault: AccountVault, master: SymmetricKey, passphrase: PassphraseKey, device: String
    ) throws -> AccountVault {
        guard vault.isMaster(master) else { throw AccountVaultError.notThisVaultsMaster }
        var next = vault
        next.kdf = passphrase.kdf
        next.masterByPassphrase = try Lock.wrap(bytes(master), under: passphrase.key)
        next.updatedByDevice = device
        return next
    }

    /// New words' lock on the master.
    public static func rewrappingWords(
        _ vault: AccountVault, master: SymmetricKey, words: WordsKey, device: String
    ) throws -> AccountVault {
        guard vault.isMaster(master) else { throw AccountVaultError.notThisVaultsMaster }
        var next = vault
        next.masterByWords = try Lock.wrap(bytes(master), under: words.key)
        next.updatedByDevice = device
        return next
    }

    /// The master, from the vault, by a typed secret.
    public static func master(of vault: AccountVault, passphrase: PassphraseKey?, words: WordsKey?) -> SymmetricKey? {
        vault.master(passphrase: passphrase, words: words)
    }

    static func bytes(_ key: SymmetricKey) -> Data { key.withUnsafeBytes { Data($0) } }
}
