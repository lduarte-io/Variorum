import CryptoKit
import Foundation
@testable import VariorumCore

/// Phase 14b — the suite-wide E2EE test key world. ONE fixed corpus key,
/// bound by every `SyncClient` (and every directly-constructed engine that
/// wants working keys), so the ENTIRE existing convergence / fault-injection
/// / repair suite set runs over ciphertext by default — the crown assertion:
/// the suites prove the seam by passing unchanged over sealed payloads.
///
/// Fixed bytes, not random: convergence assertions never depend on the key,
/// and a fixed key lets a test seal a crafted server row exactly as the
/// engine's seam would (the SyncPushTests/SyncPullTests competing-writer
/// recipes).
enum SyncTestKeys {
    static let corpusKeyID = "test-corpus-key-0000000000000001"
    static let corpusKey = SymmetricKey(data: Data((0..<32).map { UInt8($0 &+ 0x40) }))
    /// pre-13x: the suite's fixed MASTER key — the key proof derives from
    /// it (`KeyProof.wireToken`), and the fake server's default account is
    /// provisioned with its hash, so every scenario runs with the proof
    /// presented and checked (the crown's premise, extended).
    static let masterKey = SymmetricKey(data: Data((0..<32).map { UInt8($0 &+ 0x20) }))
    static let keyProof = KeyProof.wireToken(master: masterKey)
    static let keyProofHash = KeyProof.hash(master: masterKey)
    /// 13y UNIT B: the material (kp1 + kp2, both from the fixed master) —
    /// what every round's signer signs with, and what enrolled fake
    /// accounts hold as their Vault-held secret.
    static let proofMaterial = KeyProofMaterial(master: masterKey)
    static let macKeyWire = proofMaterial.macKeyWire
    /// The POST-ENROLLMENT hash — SHA-256(kp2), what the vault row
    /// carries once the account enrolled (the fake's default account is
    /// provisioned enrolled).
    static let macKeyHash = KeyProof.macHash(master: masterKey)
    static let keys = SyncEncryptionKeys(
        corpusKey: corpusKey, corpusKeyID: corpusKeyID, keyProof: proofMaterial)
    private static var crypto: SyncPayloadCrypto { SyncPayloadCrypto(keys: keys) }

    /// Seal one value exactly as the engine's seam would (AAD-bound to
    /// table/rowID/column/keyID) — for crafting a competing writer's server
    /// row.
    static func seal(
        _ plaintext: String, table: String, rowID: String, column: String
    ) throws -> String {
        try PayloadCipher.seal(
            plaintext, key: corpusKey,
            binding: .init(table: table, rowID: rowID, column: column, keyID: corpusKeyID))
    }

    /// Open one value a server dump carries — for asserting what a mirror
    /// row's ciphertext decrypts to.
    static func open(
        _ encoded: String, table: String, rowID: String, column: String
    ) throws -> String {
        try PayloadCipher.open(
            encoded, key: corpusKey,
            binding: .init(table: table, rowID: rowID, column: column, keyID: corpusKeyID))
    }

    /// The opened text of one column of a server-stored row, or nil when
    /// the row is missing or the column is not text.
    static func openedText(_ row: SyncRow?, column: String) throws -> String? {
        guard let row, case .text(let value) = row.columns[column] else { return nil }
        return try open(value, table: row.table, rowID: row.rowID, column: column)
    }

    /// A crafted wire/server row with its encrypted-classified text columns
    /// sealed exactly as the engine's seam seals them (NULLs pass; plain
    /// columns untouched).
    static func sealedForWire(_ row: SyncRow) throws -> SyncRow {
        try crypto.encryptForWire(row)
    }
}

/// The harness default: working keys every round (the crown's premise).
/// pre-13x 1a: the identity rides the provider — a fresh one per instance
/// (a directly-constructed engine is its own device); `SyncClient` wraps
/// whatever provider it holds with the CLIENT's identity, so swapping a
/// client's keys mid-life never changes which device it is.
struct FixedSyncKeyProvider: SyncKeyProviding {
    var keys: SyncEncryptionKeys = SyncTestKeys.keys
    var deviceID: String = UUID().uuidString.lowercased()
    func currentKeys() throws -> SyncEncryptionKeys { keys }
    func deviceIdentity() throws -> String { deviceID }
}

/// Models the pre-enrollment / locked-Keychain device: every round must
/// refuse visibly (`SyncError.encryptionKeysUnavailable`) — no custody, so
/// no identity either.
struct LockedSyncKeyProvider: SyncKeyProviding {
    func currentKeys() throws -> SyncEncryptionKeys {
        throw SyncKeyProviderError.notEnrolled
    }
    func deviceIdentity() throws -> String {
        throw SyncKeyProviderError.notEnrolled
    }
}

/// The client's identity over any key world (pre-13x 1a): keys from the
/// inner provider, the identity the client's own.
struct ClientIdentityKeyProvider: SyncKeyProviding {
    let inner: any SyncKeyProviding
    let deviceID: String
    func currentKeys() throws -> SyncEncryptionKeys { try inner.currentKeys() }
    func deviceIdentity() throws -> String {
        _ = try inner.currentKeys()  // a locked world has no identity either
        return deviceID
    }
}
