import Foundation

// VX-305 U1 — THIS MAC'S FACTS: one device section per device (design §3.2,
// §3.6), in the protection record (inside the encrypted library). Its plain
// random device ID (rule 23 — made at creation, remembered by this Mac); the
// act in flight; the settings that could weaken protection (the gate style,
// the idle lock, the scheduled Markdown export); the Apple key ids this Mac
// minted or followed for the library and its account, and whether each is
// retired; and a version that only grows. (The old shared key's state left
// with rule 26; the hardware marker, the second home in what this Mac
// remembers, the identity resolution and the takeover left with VX-378 U1 —
// rules 21, 23.)

/// An act between its first step and its last (§3.2): its sequence number,
/// the act, and the keys it moves between. A plan resumes only when this names
/// it (§3.6).
public struct ActInFlight: Codable, Equatable, Sendable {
    public var sequence: Int
    public var act: ProtectionAct
    public var fromFingerprint: String?
    public var toFingerprint: String?
    /// The library's mode when the act began — what finishing a follow from
    /// the record reads (the family tree's one act-time reading, carried here
    /// when the tree left with VX-378 U1).
    public var fromKind: ProtectionMode?
    public var startedAt: Date

    public init(
        sequence: Int, act: ProtectionAct, fromFingerprint: String? = nil,
        toFingerprint: String? = nil, fromKind: ProtectionMode? = nil, startedAt: Date
    ) {
        self.sequence = sequence
        self.act = act
        self.fromFingerprint = fromFingerprint
        self.toFingerprint = toFingerprint
        self.fromKind = fromKind
        self.startedAt = startedAt
    }
}

/// The settings that could weaken protection (§3.2) — per device, sealed in
/// this Mac's facts, never in UserDefaults (§3.15).
public struct DeviceSettings: Codable, Equatable, Sendable {
    /// nil = no choice yet (a landed library or a first follow into Castle
    /// decides at its own press — §3.10).
    public var gateStyle: GateStyle?
    /// Lock after time away, in minutes; nil = never. Offered 5 · 10 · 30 ·
    /// never; 10 by default (pre-13x decision 18, kept).
    public var idleLockMinutes: Int?
    /// The scheduled Markdown export (off by default; entering Castle turns it
    /// off with one notice — §3.9, §3.12).
    public var scheduledExport: Bool

    public static let defaultIdleLockMinutes = 10

    public init(gateStyle: GateStyle?, idleLockMinutes: Int? = defaultIdleLockMinutes, scheduledExport: Bool = false) {
        self.gateStyle = gateStyle
        self.idleLockMinutes = idleLockMinutes
        self.scheduledExport = scheduledExport
    }

    /// A device with no choice yet (§3.10).
    public static let noChoiceYet = DeviceSettings(gateStyle: nil)
}

/// Whose Apple key an id is (§3.5): this Mac's own for the library, or the
/// sync account's (which locks only the account's master in the vault).
public enum AppleKeyPurpose: String, Codable, Sendable {
    case library
    case account
}

/// How this Mac came to list it: minted here, or followed (read — the
/// account's key a follower picked up). (Adopted from a predecessor by a
/// replacement Mac left with the takeover — VX-378 U1, rule 23.)
public enum AppleKeyOrigin: String, Codable, Sendable {
    case minted
    case followed
}

public struct AppleKeyRecord: Codable, Equatable, Sendable {
    public var id: String
    public var purpose: AppleKeyPurpose
    /// The account an `.account` key belongs to.
    public var accountID: String?
    public var origin: AppleKeyOrigin
    /// When it was retired — deleted on sight from then on, by this id only
    /// (§3.5).
    public var retiredAt: Date?

    public init(
        id: String, purpose: AppleKeyPurpose, accountID: String? = nil,
        origin: AppleKeyOrigin, retiredAt: Date? = nil
    ) {
        self.id = id
        self.purpose = purpose
        self.accountID = accountID
        self.origin = origin
        self.retiredAt = retiredAt
    }

    /// "This Mac's own for the library": minted by it (§3.5 — "this Mac's own
    /// means minted and named by it").
    public var isOwnLibraryKey: Bool { purpose == .library && origin != .followed }
}

public struct DeviceSection: Codable, Equatable, Sendable {
    /// The plain random device ID (`<mac8>` is its first eight characters).
    public var deviceID: String
    /// Only grows: every change to the section bumps it (§3.6).
    public var version: Int
    public var actInFlight: ActInFlight?
    /// The last act sequence number handed out — so a sequence is never reused
    /// and a plan for an earlier act can never be named again.
    public var lastActSequence: Int
    public var settings: DeviceSettings
    public var appleKeys: [AppleKeyRecord]

    public init(
        deviceID: String, version: Int = 1,
        actInFlight: ActInFlight? = nil, lastActSequence: Int = 0,
        settings: DeviceSettings, appleKeys: [AppleKeyRecord] = []
    ) {
        self.deviceID = deviceID
        self.version = version
        self.actInFlight = actInFlight
        self.lastActSequence = lastActSequence
        self.settings = settings
        self.appleKeys = appleKeys
    }

    public var mac8: String { ProtectionNames.mac8(deviceID) }

    // MARK: - Reading

    /// Every id this Mac lists as its own for the library and not yet retired —
    /// what entering Castle retires (§3.5).
    public var ownLibraryAppleKeyIDsToRetire: [String] {
        appleKeys.filter { $0.isOwnLibraryKey && $0.retiredAt == nil }.map(\.id)
    }

    /// Every retired id — delete on sight, by id only (§3.5).
    public var retiredAppleKeyIDs: Set<String> {
        Set(appleKeys.filter { $0.retiredAt != nil }.map(\.id))
    }

    // MARK: - Changing (every change bumps the version)

    public func bumped() -> DeviceSection {
        var next = self
        next.version += 1
        return next
    }

    public func withSettings(_ settings: DeviceSettings) -> DeviceSection {
        var next = bumped()
        next.settings = settings
        return next
    }

    /// Record an Apple key id (idempotent by id: an existing record keeps its
    /// retirement — a retired id is never un-retired).
    public func recordingAppleKey(_ record: AppleKeyRecord) -> DeviceSection {
        var next = bumped()
        if let index = next.appleKeys.firstIndex(where: { $0.id == record.id }) {
            let retired = next.appleKeys[index].retiredAt
            next.appleKeys[index] = record
            next.appleKeys[index].retiredAt = [retired, record.retiredAt].compactMap { $0 }.min()
        } else {
            next.appleKeys.append(record)
        }
        return next
    }

    /// Retire an id (recording it first if this section never listed it — a
    /// follower records the account's key as retired, §3.5).
    public func retiringAppleKey(
        id: String, purpose: AppleKeyPurpose, accountID: String? = nil,
        origin: AppleKeyOrigin, at: Date
    ) -> DeviceSection {
        let existing = appleKeys.first { $0.id == id }
        var record = existing ?? AppleKeyRecord(id: id, purpose: purpose, accountID: accountID, origin: origin)
        record.retiredAt = existing?.retiredAt.map { min($0, at) } ?? at
        return recordingAppleKey(record)
    }

    /// The act begins: the next sequence number, named in flight (§3.6).
    public func beginningAct(
        _ act: ProtectionAct, from: String?, to: String?, fromKind: ProtectionMode? = nil, at: Date
    ) -> (section: DeviceSection, sequence: Int) {
        var next = bumped()
        next.lastActSequence += 1
        next.actInFlight = ActInFlight(
            sequence: next.lastActSequence, act: act, fromFingerprint: from, toFingerprint: to, fromKind: fromKind,
            startedAt: at)
        return (next, next.lastActSequence)
    }

    /// The act ends — only the one named (a stale end changes nothing).
    public func endingAct(sequence: Int) -> DeviceSection {
        guard actInFlight?.sequence == sequence else { return self }
        var next = bumped()
        next.actInFlight = nil
        return next
    }

}

// MARK: - This Mac's section at open (rule 23)

public enum DeviceFacts {
    /// **This Mac's section, at open** (rule 23: "a plain random device ID,
    /// made at creation"; rule 21: what this Mac remembers names it). The
    /// record's section for the device ID this Mac remembers — or, the record
    /// holding none for it, a fresh section under that same ID. With nothing
    /// remembered (no memory item, or one failing its seal) a NEW plain random
    /// device ID with a fresh section: no choice yet, adopting nothing — never
    /// a section guessed from the record. PROVISIONAL (QUESTIONS, the VX-378
    /// heading): U2's detect-and-refuse may make that open a refusal.
    public static func thisMacsSection(
        memory: DeviceMemory?, recordSections: [DeviceSection], mintDeviceID: () -> String
    ) -> DeviceSection {
        let id = memory?.deviceID ?? mintDeviceID()
        return recordSections.filter { $0.deviceID == id }.max { $0.version < $1.version }
            ?? DeviceSection(deviceID: id, settings: .noChoiceYet)
    }
}
