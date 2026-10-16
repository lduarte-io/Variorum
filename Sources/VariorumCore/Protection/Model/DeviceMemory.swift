import Foundation

// VX-305 U1 — WHAT THIS MAC REMEMBERS (design §3.2, §3.6): one non-secret
// Keychain item per library ID (device-only; service `io.lduarte.Variorum.
// memory`, account `<scope>-<libraryID>`), SEALED WHOLE (purpose `memory`)
// under the library key, so an edit is caught and a replayed item loses to a
// newer record. Before unlock it is a display hint only and decides nothing
// (§3.10).
//
// RULE 21 (`notes/CastleRules.md`): "This Mac remembers four things about its
// library — its ID, its current key, its device ID and the sealed copy of its
// key file — and only the app's own doors change them." Two hints ride beside
// them until U2 gives each its home: the biometry state hash (§3.10's which-
// line hint) and the vault facts (the follow's reading; U2 replaces the vault).
// (The mode and account last confirmed, the key epoch, the nudge dismissals,
// the family tree's mirror and the device section's second home left with
// VX-378 U1 — rules 21, 23.)

/// The vault facts today's key file caches (pre-13x §3.6; moved here by the
/// design): what the local passphrase copy was last reconciled against.
public struct VaultFacts: Codable, Equatable, Sendable {
    /// Recorded when this Mac's memory lost its vault facts and the library's
    /// master lock opens with none of the account's keys this device holds:
    /// the library follows no corpus key the account still names — a follow
    /// is owed (VX-305 U4, the held-keys repair).
    public static let unfollowedCorpusKeyID = "unfollowed"

    public var kdf: PassphraseKDF.Descriptor?
    public var corpusKeyID: String?
    /// `RecoveryWrapDigest.hex` of the vault's recovery wrap.
    public var recoveryWrapDigest: String?

    public init(kdf: PassphraseKDF.Descriptor? = nil, corpusKeyID: String? = nil, recoveryWrapDigest: String? = nil) {
        self.kdf = kdf
        self.corpusKeyID = corpusKeyID
        self.recoveryWrapDigest = recoveryWrapDigest
    }
}

public struct DeviceMemory: Codable, Equatable, Sendable {
    public static let currentFormat = 1

    public var format: Int
    public var libraryID: String
    public var currentFingerprint: String
    /// This Mac's plain random device ID for the library (rule 23) — it names
    /// this Mac's section of the record.
    public var deviceID: String
    /// The key file's mirror — its wraps and history (§3.2): THE on-device
    /// copy, written back only into an empty live place (rule 1).
    public var keyFileMirror: KeyFile?
    /// `LAEnvironment`'s biometry state hash when this Mac's Touch ID item was
    /// made — chooses which line shows after a press fails, nothing else.
    public var biometryStateHash: Data?
    public var vaultFacts: VaultFacts?

    public init(
        format: Int = DeviceMemory.currentFormat, libraryID: String, currentFingerprint: String, deviceID: String,
        keyFileMirror: KeyFile? = nil, biometryStateHash: Data? = nil, vaultFacts: VaultFacts? = nil
    ) {
        self.format = format
        self.libraryID = libraryID
        self.currentFingerprint = currentFingerprint
        self.deviceID = deviceID
        self.keyFileMirror = keyFileMirror
        self.biometryStateHash = biometryStateHash
        self.vaultFacts = vaultFacts
    }

    /// Sealed whole under the library key in hand.
    public func sealed(under key: StoreKey) throws -> Sealed<DeviceMemory> {
        try Sealed.sealing(self, purpose: .memory, libraryID: libraryID, key: key)
    }

    /// Open a memory item for `libraryID`: verified, else nil (a memory item
    /// that fails its seal remembers nothing). A memory item for another
    /// library is not this one's.
    public static func opening(
        _ sealed: Sealed<DeviceMemory>, libraryID: String, reach: (String) -> StoreKey?
    ) -> DeviceMemory? {
        guard let memory = try? sealed.open(purpose: .memory, libraryID: libraryID, reach: reach),
              memory.libraryID == libraryID
        else { return nil }
        return memory
    }
}
