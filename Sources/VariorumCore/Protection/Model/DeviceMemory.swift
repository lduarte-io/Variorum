import Foundation

// VX-305 U1 — WHAT THIS MAC REMEMBERS (design §3.2, §3.6): one non-secret
// Keychain item per library ID (device-only; service `io.lduarte.Variorum.
// memory`, account `<scope>-<libraryID>`), SEALED WHOLE (purpose `memory`)
// under the library key, so an edit is caught and a replayed item loses to a
// newer record. Before unlock it is a display hint only and decides nothing
// (§3.10).
//
// It holds: the library's location (scope), current fingerprint and epoch;
// the mode and account last confirmed; the device identity with its hardware
// marker (both inside the device section's second home below); the biometry
// state hash when its Touch ID item was made (a hint, never a verdict —
// §3.10); the vault facts today's key file caches; nudge dismissals; a mirror
// of the key file's wraps, history and anchor; the family tree's mirror; and
// THE SECOND HOME OF THIS MAC'S DEVICE SECTION (the same fields and version).

/// The vault facts today's key file caches (pre-13x §3.6; moved here by the
/// design): what the local passphrase copy was last reconciled against.
public struct VaultFacts: Codable, Equatable, Sendable {
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

/// The mode and account last CONFIRMED on this Mac (account nil = none).
public struct ConfirmedFacts: Codable, Equatable, Sendable {
    public var mode: ProtectionMode
    public var account: String?

    public init(mode: ProtectionMode, account: String?) {
        self.mode = mode
        self.account = account
    }
}

public struct DeviceMemory: Codable, Equatable, Sendable {
    public static let currentFormat = 1

    public var format: Int
    public var libraryID: String
    /// The store-variant scope the library lives under.
    public var scope: String
    public var currentFingerprint: String
    public var keyEpoch: Int
    public var lastConfirmed: ConfirmedFacts?
    /// `LAEnvironment`'s biometry state hash when this Mac's Touch ID item was
    /// made — chooses which line shows after a press fails, nothing else.
    public var biometryStateHash: Data?
    public var vaultFacts: VaultFacts?
    /// Nudge name → dismissed at.
    public var nudgeDismissals: [String: Date]
    /// The key file's mirror — its wraps, history and anchor (§3.2).
    public var keyFileMirror: KeyFile?
    /// The family tree's mirror — unioned with the record's at open.
    public var familyTree: FamilyTree
    /// The second home of this Mac's device section (§3.6).
    public var deviceSection: DeviceSection

    public init(
        format: Int = DeviceMemory.currentFormat, libraryID: String, scope: String,
        currentFingerprint: String, keyEpoch: Int, lastConfirmed: ConfirmedFacts? = nil,
        biometryStateHash: Data? = nil, vaultFacts: VaultFacts? = nil,
        nudgeDismissals: [String: Date] = [:], keyFileMirror: KeyFile? = nil,
        familyTree: FamilyTree, deviceSection: DeviceSection
    ) {
        self.format = format
        self.libraryID = libraryID
        self.scope = scope
        self.currentFingerprint = currentFingerprint
        self.keyEpoch = keyEpoch
        self.lastConfirmed = lastConfirmed
        self.biometryStateHash = biometryStateHash
        self.vaultFacts = vaultFacts
        self.nudgeDismissals = nudgeDismissals
        self.keyFileMirror = keyFileMirror
        self.familyTree = familyTree
        self.deviceSection = deviceSection
    }

    /// The device identity (kept in the device section — one field, two
    /// readings, never two values that could disagree).
    public var deviceID: String { deviceSection.deviceID }
    /// The hardware marker (likewise).
    public var hardwareMarker: String { deviceSection.hardwareMarker }

    /// The Keychain item's account.
    public var itemAccount: String { ProtectionNames.memoryAccount(scope: scope, libraryID: libraryID) }

    /// Sealed whole under the library key in hand.
    public func sealed(under key: StoreKey) throws -> Sealed<DeviceMemory> {
        try Sealed.sealing(self, purpose: .memory, libraryID: libraryID, key: key)
    }

    /// Open a memory item for `libraryID`: verified, else nil — a memory item
    /// that fails its seal loses to the record's device section (§3.6; the
    /// plan's U3 test). A memory item for another library is not this one's.
    public static func opening(
        _ sealed: Sealed<DeviceMemory>, libraryID: String, reach: (String) -> StoreKey?
    ) -> DeviceMemory? {
        guard let memory = try? sealed.open(purpose: .memory, libraryID: libraryID, reach: reach),
              memory.libraryID == libraryID
        else { return nil }
        return memory
    }
}
