import Foundation

// VX-305 U1 — THE PROTECTION RECORD, as a value (design §3.2). The library's
// own facts — library ID; the mode (the current key's kind); the account (none
// or one id); the key epoch; the current key's
// fingerprint; when it changed; the family tree; the salt every device's
// hardware marker is computed under — and ONE SEALED DEVICE SECTION PER
// DEVICE. Its SQLite table (`protection_record`, local-only, the plaintext
// export leaves it behind) is phase 2's; this is the value it will hold.
//
// A copy carries only the library's own facts (§3.6): a device section counts
// only on its own Mac.

public struct ProtectionRecord: Codable, Equatable, Sendable {
    public static let currentFormat = 1

    public var format: Int
    public var libraryID: String
    /// The current key's kind. (Always known: the record's "unconfirmed
    /// mode" — the migration's and corner 45's — left with rule 26.)
    public var mode: ProtectionMode
    /// The Variorum account the library is bound to — none, or one id
    /// (§3.8). Signing in or out never changes it.
    public var account: String?
    public var keyEpoch: Int
    public var currentFingerprint: String
    public var changedAt: Date
    public var familyTree: FamilyTree
    /// The random salt every device's hardware marker is computed under —
    /// never logged (§3.2).
    public var markerSalt: Data
    /// One per device, each sealed (purpose `device-section`) under the key
    /// in hand when it was written.
    public var deviceSections: [Sealed<DeviceSection>]

    public init(
        format: Int = ProtectionRecord.currentFormat, libraryID: String, mode: ProtectionMode,
        account: String?, keyEpoch: Int, currentFingerprint: String,
        changedAt: Date, familyTree: FamilyTree, markerSalt: Data,
        deviceSections: [Sealed<DeviceSection>] = []
    ) {
        self.format = format
        self.libraryID = libraryID
        self.mode = mode
        self.account = account
        self.keyEpoch = keyEpoch
        self.currentFingerprint = currentFingerprint
        self.changedAt = changedAt
        self.familyTree = familyTree
        self.markerSalt = markerSalt
        self.deviceSections = deviceSections
    }

    /// A new record for a library whose current key is `currentKey`, born
    /// `mode` on `madeBy` (the creation).
    public static func minting(
        libraryID: String, mode: ProtectionMode, account: String?,
        currentFingerprint: String, keyEpoch: Int = 1, madeBy: String?, at: Date,
        markerSalt: Data = HardwareMarker.mintSalt()
    ) -> ProtectionRecord {
        let tree = madeBy.map {
            FamilyTree().recordingBirth(fingerprint: currentFingerprint, kind: mode, madeBy: $0, madeAt: at)
        } ?? FamilyTree(entries: [FamilyTree.Entry(fingerprint: currentFingerprint, kind: mode)])
        return ProtectionRecord(
            libraryID: libraryID, mode: mode, account: account,
            keyEpoch: keyEpoch, currentFingerprint: currentFingerprint, changedAt: at,
            familyTree: tree, markerSalt: markerSalt)
    }

    /// **A re-key or a landing** (§3.4): the new key is recorded in the family
    /// tree with its kind for life and the Mac that made it, the old key
    /// retired, the epoch advanced; the mode is the new key's kind (a key
    /// changes only at a deliberate act — §3.12).
    public func recordingRekey(
        to newFingerprint: String, kind: ProtectionMode, by deviceID: String, at: Date
    ) -> ProtectionRecord {
        var next = self
        next.familyTree = familyTree
            .retiring(currentFingerprint, at: at)
            .recordingBirth(fingerprint: newFingerprint, kind: kind, madeBy: deviceID, madeAt: at)
        next.currentFingerprint = newFingerprint
        next.keyEpoch += 1
        next.mode = kind
        next.changedAt = at
        return next
    }

    /// The marker THIS hardware and login compute under the record's salt.
    public func marker(for machine: MachineIdentity) -> HardwareMarker {
        HardwareMarker.compute(machine, salt: markerSalt)
    }

    // MARK: - The device sections

    /// Every section that verifies with a key `reach` can find (the current
    /// key, or an older one through the history). A section that fails its
    /// seal is not this Mac's facts — it is left out.
    public func verifiedSections(reach: (String) -> StoreKey?) -> [DeviceSection] {
        deviceSections.compactMap {
            try? $0.open(purpose: .deviceSection, libraryID: libraryID, reach: reach)
        }
    }

    /// Store `section` (replacing that device's), sealed under `key`.
    public func storing(_ section: DeviceSection, sealedUnder key: StoreKey) throws -> ProtectionRecord {
        var next = self
        let sealed = try Sealed.sealing(section, purpose: .deviceSection, libraryID: libraryID, key: key)
        let others = deviceSections.filter { stored in
            guard let id = try? ProtectionCoding.decoder()
                .decode(DeviceSectionID.self, from: stored.payload).deviceID
            else { return true }
            return id != section.deviceID
        }
        next.deviceSections = others + [sealed]
        return next
    }

    /// The device id a sealed section names — read without verifying, for
    /// replacement only (a stored section is replaced by device id; whether it
    /// counts is `verifiedSections`' question).
    private struct DeviceSectionID: Decodable { var deviceID: String }
}
