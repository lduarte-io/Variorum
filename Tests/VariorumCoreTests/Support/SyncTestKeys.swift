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
    static let keys = SyncEncryptionKeys(corpusKey: corpusKey, corpusKeyID: corpusKeyID)
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
struct FixedSyncKeyProvider: SyncKeyProviding {
    var keys: SyncEncryptionKeys = SyncTestKeys.keys
    func currentKeys() throws -> SyncEncryptionKeys { keys }
}

/// Models the pre-enrollment / locked-Keychain device: every round must
/// refuse visibly (`SyncError.encryptionKeysUnavailable`).
struct LockedSyncKeyProvider: SyncKeyProviding {
    func currentKeys() throws -> SyncEncryptionKeys {
        throw SyncKeyProviderError.notEnrolled
    }
}
