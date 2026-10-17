import Foundation

// VX-305 U1 — THE PROTECTION RECORD, as a value (design §3.2). The library's
// own facts — library ID; the mode (the current key's kind); the account (none
// or one id); the key epoch; the current key's fingerprint; when it changed —
// and ONE SEALED DEVICE SECTION PER DEVICE, keyed by its plain random device
// ID (rule 23). (The family tree and the hardware marker's salt left with
// VX-378 U1 — rules 21, 23: the key file's history is the list of keys the
// library has had, rule 4.) Its SQLite table (`protection_record`, local-only, the plaintext
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
    /// The account's sync key this library has followed (rule 15) — its id,
    /// non-secret. The vault naming another current key means the account
    /// entered Castle while this device lagged: a follow is owed. Written by the
    /// acts that take the account's keys (sync setup, a join, a follow, Use
    /// Castle's write); cleared with the account.
    public var accountRowKeyID: String?
    public var keyEpoch: Int
    public var currentFingerprint: String
    public var changedAt: Date
    /// RULE 3 ("every library is asked for a passphrase"): whether a passphrase
    /// exists for the library — a passphrase lock on its key file, or, bound to
    /// an account, the account's (rule 7: one pair; the vault always carries
    /// one). A fact the executor keeps fresh at every record it writes; the
    /// reminders' faces are phase 3's.
    public var passphraseSet: Bool
    /// How many times the returning reminder was dismissed (rule 3's "then with
    /// a 'don't show again'"). A fact only: the schedule is the face's.
    public var reminderDismissals: Int
    /// One per device, each sealed (purpose `device-section`) under the key
    /// in hand when it was written.
    public var deviceSections: [Sealed<DeviceSection>]

    public init(
        format: Int = ProtectionRecord.currentFormat, libraryID: String, mode: ProtectionMode,
        account: String?, accountRowKeyID: String? = nil, keyEpoch: Int, currentFingerprint: String,
        changedAt: Date, passphraseSet: Bool = false, reminderDismissals: Int = 0,
        deviceSections: [Sealed<DeviceSection>] = []
    ) {
        self.format = format
        self.libraryID = libraryID
        self.mode = mode
        self.account = account
        self.accountRowKeyID = accountRowKeyID
        self.keyEpoch = keyEpoch
        self.currentFingerprint = currentFingerprint
        self.changedAt = changedAt
        self.passphraseSet = passphraseSet
        self.reminderDismissals = reminderDismissals
        self.deviceSections = deviceSections
    }

    /// A new record for a library whose current key is `currentKey`, born
    /// `mode` (the creation).
    public static func minting(
        libraryID: String, mode: ProtectionMode, account: String?, accountRowKeyID: String? = nil,
        currentFingerprint: String, keyEpoch: Int = 1, passphraseSet: Bool = false, at: Date
    ) -> ProtectionRecord {
        ProtectionRecord(
            libraryID: libraryID, mode: mode, account: account, accountRowKeyID: accountRowKeyID,
            keyEpoch: keyEpoch, currentFingerprint: currentFingerprint, changedAt: at, passphraseSet: passphraseSet)
    }

    /// Rule 3's fact as the library stands: a passphrase lock on `keyFile`,
    /// or the account's passphrase (rule 7 — bound, the device holds the
    /// account's pair, and the vault always carries a passphrase lock).
    public static func passphraseExists(keyFile: KeyFile?, account: String?) -> Bool {
        keyFile?.passphrase != nil || account != nil
    }

    /// This record with rule 3's fact brought to `keyFile`.
    public func stampingPassphraseFact(keyFile: KeyFile?) -> ProtectionRecord {
        var next = self
        next.passphraseSet = Self.passphraseExists(keyFile: keyFile, account: account)
        return next
    }

    /// **A re-key** (§3.4): the new key current, the epoch advanced; the mode
    /// is the new key's kind (a key changes only at a deliberate act — §3.12).
    public func recordingRekey(to newFingerprint: String, kind: ProtectionMode, at: Date) -> ProtectionRecord {
        var next = self
        next.currentFingerprint = newFingerprint
        next.keyEpoch += 1
        next.mode = kind
        next.changedAt = at
        return next
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
