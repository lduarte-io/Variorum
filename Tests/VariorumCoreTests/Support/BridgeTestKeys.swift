import CryptoKit
import Foundation
@testable import VariorumCore

/// Phase 14b (L11) — the bridge suites' fixed journal-class key world (the
/// `SyncTestKeys` pattern): ONE fixed key bound by the bridge harness, so
/// the ENTIRE existing bridge suite set runs over ciphertext by default —
/// the bridge's own crown. Fixed bytes so a test can seal a Fragments-side
/// E2EE write exactly as their client will, and open what the bridge
/// pushed.
enum BridgeTestKeys {
    static let journalKeyID = "test-journal-key-0000000000001"
    static let journalKey = SymmetricKey(data: Data((0..<32).map { UInt8($0 &+ 0x80) }))
    static let keys = BridgeEncryptionKeys(
        journalKey: journalKey, journalKeyID: journalKeyID)

    /// Seal a body as a post-E2EE Fragments client would (the touchpoint #2
    /// convention: AAD binds journal_entries:<date>:body:<keyID>).
    static func seal(_ body: String, day: String) throws -> String {
        try BridgeCrypto.seal(body, day: day, keys: keys)
    }

    /// Open a server-stored body; legacy plaintext returns verbatim (the
    /// landing's own rule, reused so assertions read naturally either way).
    static func opened(_ value: String?, day: String) throws -> String? {
        guard let value else { return nil }
        return try BridgeCrypto.openLanded(value, day: day, keys: keys)
    }
}

/// The harness default: working journal keys every round.
struct FixedBridgeKeyProvider: BridgeKeyProviding {
    var keys: BridgeEncryptionKeys = BridgeTestKeys.keys
    func currentKeys() throws -> BridgeEncryptionKeys { keys }
}

/// Models the paused / pre-enrollment bridge: every round must refuse
/// visibly (`BridgeEncryptionError.keysUnavailable`).
struct LockedBridgeKeyProvider: BridgeKeyProviding {
    func currentKeys() throws -> BridgeEncryptionKeys {
        throw BridgeEncryptionError.keysUnavailable
    }
}
