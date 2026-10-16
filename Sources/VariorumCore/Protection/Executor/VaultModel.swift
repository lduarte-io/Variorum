import CryptoKit
import Foundation

// VX-305 U3 — THE VAULT, MODELLED (the phase plan §5: "the `Sync/` half is
// phase 3's — model it here"). The vault protocol is today's, unchanged
// (design §3.12): the master under the passphrase (with its descriptor), the
// words and — Standard — the account's Apple key, naming `apple_key_id`; the
// class keys under the master; the key proof; one rotation at a time, with
// the previous corpus key under the new master and the rotation seq. The
// vault reads Standard with an Apple wrap and Castle without one; a leave's
// rotation writes the wrap under the account's fresh Apple key at its FIRST
// write, like Standard's Replace All Keys (rule 12: no stuck leave — the
// id-with-no-wrap mark and the named-key completion left with VX-378 U1; U2
// replaces the rotation with the one-row write and the mode flag, rule 15).
// The payloads are built here from the real
// `KeyVaultFormat` (Crypto/, not Sync/), so the model is the true format; the
// transport, the walk and the server's guards are the `VaultLeaf`'s.

/// The vault as one fetch read it: the format, its CAS revision, and how many
/// of the account's rows still sit below the rotation seq (decision 31).
public struct VaultSnapshot: Equatable, Sendable {
    public var accountID: String
    public var revision: Int
    public var format: KeyVaultFormat
    public var rowsBelowRotationSeq: Int
    public var updatedAt: Date?

    public init(accountID: String, revision: Int, format: KeyVaultFormat, rowsBelowRotationSeq: Int = 0, updatedAt: Date? = nil) {
        self.accountID = accountID
        self.revision = revision
        self.format = format
        self.rowsBelowRotationSeq = rowsBelowRotationSeq
        self.updatedAt = updatedAt
    }

    /// U2's non-secret reading — what `assess` takes.
    public var reading: VaultReading {
        VaultReading(
            accountID: accountID, hasAppleWrap: format.masterWrappedByAppleHeld != nil,
            appleKeyID: format.appleKeyID, previousCorpusKeyID: format.previousCorpusKey?.keyID,
            corpusKeyID: format.classKey(for: .corpus)?.keyID, recoveryWrap: format.masterWrappedByRecovery,
            updatedByDevice: format.updatedByDevice, updatedAt: updatedAt)
    }

    public var mode: VaultMode { reading.mode }
    public var corpusKeyID: String? { format.classKey(for: .corpus)?.keyID }
}

/// Typed refusals the vault (server) gives — the fakes throw these; phase 3
/// maps today's `KeyVaultClientError` onto them.
public enum VaultRefusal: Error, Equatable, Sendable {
    /// The CAS: another write landed since this device's read.
    case revisionConflict
    /// The proof is not the current master's.
    case keyProofRefused
    /// Decision 32: a payload setting a previous corpus key while one stands.
    case rotationInProgress
    /// A completing write while rows remain below the seq.
    case rotationRowsRemain
    case vaultAbsent
    case vaultExists
    /// The network: nothing was read or written.
    case unreachable
    /// The session isn't signed into this account (row-level security):
    /// nothing was read or written.
    case notSignedIn
}

/// How a rotation's first write treats the Apple-held copy (§3.5, §3.9).
public enum RotationAppleCopy: Sendable {
    /// Use Castle, a Castle Replace All Keys: no Apple copy, no id.
    case none
    /// Standard's Replace All Keys (decision 30): M′ under the SAME account
    /// key; Use Standard (a leave): M′ under the account's FRESH key.
    case keptUnder(AppleKeyMaterial)
}

public enum VaultModel {
    /// A brand-new vault (sync setup, the first device): M, C, J minted; M
    /// under the passphrase and the words; Standard — M under the account's
    /// fresh Apple key.
    public static func creating(
        passphrase: PassphraseKey, words: WordsKey?, apple: AppleKeyMaterial?, device: String, ids: any IDsLeaf
    ) throws -> (format: KeyVaultFormat, material: DeviceKeyMaterial) {
        let master = ids.mintSymmetricKey(), corpus = ids.mintSymmetricKey(), journal = ids.mintSymmetricKey()
        let corpusID = ids.mintID(), journalID = ids.mintID()
        var format = try KeyVaultFormat.create(
            masterKey: master, passphraseKey: passphrase.key, recoveryKey: words?.key,
            classKeys: [(.corpus, corpusID, corpus), (.journalBridge, journalID, journal)], kdf: passphrase.kdf)
        if let apple {
            format = try format.settingAppleHeldCopy(masterKey: master, appleKey: apple.key, appleKeyID: apple.id)
        }
        format.updatedByDevice = device
        return (format, DeviceKeyMaterial(
            masterKey: bytes(master), corpusKey: bytes(corpus), corpusKeyID: corpusID,
            journalBridgeKey: bytes(journal), journalBridgeKeyID: journalID))
    }

    /// **A rotation's first write** (decision 6's shape, today's protocol):
    /// M′, C′, J′ minted; M′ under the passphrase (the door's descriptor) and
    /// the words; C′, J′ under M′; the OLD corpus key under M′ as the previous
    /// key; the proof hash replaced; the Apple copy per `apple`. Returns the
    /// payload and the material custody takes (M′, C′, J′ and the previous key).
    public static func rotationBegin(
        current: DeviceKeyMaterial, passphrase: PassphraseKey, words: WordsKey?, apple: RotationAppleCopy,
        device: String, ids: any IDsLeaf
    ) throws -> (format: KeyVaultFormat, material: DeviceKeyMaterial) {
        let master = ids.mintSymmetricKey(), corpus = ids.mintSymmetricKey(), journal = ids.mintSymmetricKey()
        let corpusID = ids.mintID(), journalID = ids.mintID()
        var format = try KeyVaultFormat.create(
            masterKey: master, passphraseKey: passphrase.key, recoveryKey: words?.key,
            classKeys: [(.corpus, corpusID, corpus), (.journalBridge, journalID, journal)], kdf: passphrase.kdf)
        format = try format.carryingPreviousCorpusKey(
            current.corpusSymmetricKey, keyID: current.corpusKeyID, masterKey: master)
        switch apple {
        case .none:
            break
        case .keptUnder(let key):
            format = try format.settingAppleHeldCopy(masterKey: master, appleKey: key.key, appleKeyID: key.id)
        }
        format.updatedByDevice = device
        let material = DeviceKeyMaterial(
            masterKey: bytes(master), corpusKey: bytes(corpus), corpusKeyID: corpusID,
            journalBridgeKey: bytes(journal), journalBridgeKeyID: journalID)
            .carryingPreviousCorpusKey(current.corpusKey, keyID: current.corpusKeyID, startedSeq: 1)
        return (format, material)
    }

    /// **The completing write**: the previous corpus key cleared (any device
    /// holding the new master may make it).
    public static func completing(_ format: KeyVaultFormat, device: String) -> KeyVaultFormat {
        var next = format.clearingPreviousCorpusKey()
        next.updatedByDevice = device
        return next
    }

    /// The material a holder of the vault's master derives from it — the class
    /// keys, and the previous corpus key while a rotation stands (today's
    /// follower read, restated outside `Sync/`).
    public static func material(following format: KeyVaultFormat, master: SymmetricKey) throws -> DeviceKeyMaterial {
        guard let corpus = format.classKey(for: .corpus), let journal = format.classKey(for: .journalBridge) else {
            throw KeyVaultError.unknownClassKey(.corpus)
        }
        var material = DeviceKeyMaterial(
            masterKey: bytes(master),
            corpusKey: bytes(try format.unwrapClassKey(.corpus, masterKey: master)), corpusKeyID: corpus.keyID,
            journalBridgeKey: bytes(try format.unwrapClassKey(.journalBridge, masterKey: master)),
            journalBridgeKeyID: journal.keyID)
        if format.previousCorpusKey != nil {
            let previous = try format.unwrapPreviousCorpusKey(masterKey: master)
            material = material.carryingPreviousCorpusKey(
                bytes(previous.key), keyID: previous.keyID, startedSeq: format.rotationStartedSeq ?? 1)
        }
        return material
    }

    /// The master, from the vault, by a typed secret: the passphrase under the
    /// vault's own descriptor, or the words through the recovery wrap.
    public static func master(
        of format: KeyVaultFormat, passphrase: PassphraseKey?, words: WordsKey?
    ) -> SymmetricKey? {
        if let passphrase, passphrase.kdf == format.kdf,
           let master = try? format.unwrapMaster(withPassphraseKey: passphrase.key) {
            return master
        }
        if let words, let master = try? format.unwrapMaster(withRecoveryKey: words.key) { return master }
        return nil
    }

    static func bytes(_ key: SymmetricKey) -> Data { key.withUnsafeBytes { Data($0) } }
}
