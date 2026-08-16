import CryptoKit
import Foundation

/// Phase 14b batch 3 (L11) — the bridge's journal-class E2EE capability
/// (R-8: the `journal_bridge` class key; touchpoint #2 designed the
/// Fragments end, EXECUTED at the 14d batch). HISTORY: the bridge's
/// rounds stayed STRUCTURALLY PAUSED from 14b until 14d — the engine's
/// default provider refuses every round (below), and the app wired no
/// real provider while the Fragments side couldn't read ciphertext.
/// **The pause ENDED at 14d (2026-08-16):** production wires the live
/// Keychain provider, both ends speak `e1:`, and the refusing default
/// now models only keyless states (unenrolled, CF-12-locked, tests).
///
/// **The AAD convention (batch-3's recorded design call — simple enough for
/// Fragments' client to reproduce):**
///
///     AAD = UTF-8("journal_entries:<date>:body:<key_id>")
///
/// where `<date>` is the row's `date` column (the `yyyy-MM-dd` day key —
/// the join key of the whole contract, so a ciphertext can never be moved
/// between days undetected) and `<key_id>` is the vault's
/// `journal_bridge_key_id`. This is `PayloadCipher`'s standard
/// `table:rowID:column:keyID` binding with the DAY standing in the rowID
/// slot — deliberate: the deterministic UUID derives FROM the day, both
/// sides always know the day, and one binding grammar serves the suite.
/// Encoding is the suite's `e1:` + base64(nonce ‖ ciphertext ‖ tag),
/// AES-256-GCM, per-value random 96-bit nonce.
public enum BridgeCrypto {
    /// The binding for one journal day's body.
    public static func binding(day: String, keyID: String) -> PayloadCipher.Binding {
        PayloadCipher.Binding(
            table: "journal_entries", rowID: day, column: "body", keyID: keyID)
    }

    /// Seal one rendered body for the wire. The empty string seals too —
    /// under E2EE the server cannot see emptiness, which is exactly why the
    /// empty-body-as-deletion detection moves client-side (touchpoint #2's
    /// standing relocation).
    public static func seal(
        _ body: String, day: String, keys: BridgeEncryptionKeys
    ) throws -> String {
        try PayloadCipher.seal(
            body, key: keys.journalKey, binding: binding(day: day, keyID: keys.journalKeyID))
    }

    /// Open one landed body. THE LEGACY RULE (recorded, deliberate): a body
    /// that is not ciphertext at all — no `e<n>:` version prefix — passes
    /// through as legacy plaintext: `journal_entries` is never wiped
    /// (unlike the R-2 mirror), so pre-E2EE rows and interim
    /// Fragments-side writes are historical data, not a fault; refusing
    /// them would jam the cursor on exactly the transition the one-batch
    /// handoff executes. EVERYTHING ELSE refuses (ladder R1-4): the
    /// pass-through rides ONLY `PayloadCipher.open`'s `.notEncrypted` arm,
    /// so a FUTURE-version ciphertext (`e2:…`) refuses as
    /// `unsupportedVersion` instead of landing verbatim as the day's text,
    /// and a tampered `e1:` body refuses as ever — nothing unauthenticated
    /// (and no ciphertext soup) ever lands.
    public static func openLanded(
        _ value: String, day: String, keys: BridgeEncryptionKeys
    ) throws -> String {
        do {
            return try PayloadCipher.open(
                value, key: keys.journalKey,
                binding: binding(day: day, keyID: keys.journalKeyID))
        } catch PayloadCipherError.notEncrypted {
            return value
        }
    }
}

/// The journal-bridge class key material one bridge round seals/opens with.
public struct BridgeEncryptionKeys: Sendable {
    public let journalKey: SymmetricKey
    /// The vault's `journal_bridge_key_id` — bound into every body's AAD.
    public let journalKeyID: String

    public init(journalKey: SymmetricKey, journalKeyID: String) {
        self.journalKey = journalKey
        self.journalKeyID = journalKeyID
    }
}

/// The bridge's key seam — the sync engine's `SyncKeyProviding` pattern
/// applied to the journal-bridge class (a SEPARATE protocol deliberately:
/// R-8's whole point is that the bridge only ever touches the
/// journal-bridge key, and Fragments' side at touchpoint #2 receives
/// exactly this class, never the corpus key).
public protocol BridgeKeyProviding: Sendable {
    /// Throw ANYTHING to signal absent/locked — the engine maps every
    /// throw to `BridgeEncryptionError.keysUnavailable` and refuses the
    /// round before any network contact.
    func currentKeys() throws -> BridgeEncryptionKeys
}

/// The default: no key provider wired ⇒ every bridge round refuses
/// visibly. This IS the phase's designed pause (rounds do not run until
/// the one-batch Fragments handoff wires the real provider), and it is
/// also the post-handoff pre-enrollment state — one honest refusal serves
/// both.
public struct UnenrolledBridgeKeyProvider: BridgeKeyProviding {
    public init() {}
    public func currentKeys() throws -> BridgeEncryptionKeys {
        throw BridgeEncryptionError.keysUnavailable
    }
}

/// Typed refusals in the sync engine's visible grammar (the status row
/// renders the description verbatim).
public enum BridgeEncryptionError: Error, Equatable, Sendable {
    /// The journal-bridge key is absent or locked on this device — the
    /// round refuses before any network contact; cursor and day hashes
    /// keep everything.
    case keysUnavailable
}

extension BridgeEncryptionError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .keysUnavailable:
            return "Bridge paused: the journal encryption key is not available on this "
                + "device (not enrolled, or locked). Nothing is lost while paused; "
                + "the cursor and every day's state are kept."
        }
    }
}
