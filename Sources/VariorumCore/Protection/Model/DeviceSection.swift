import Foundation

// VX-305 U1 — THIS MAC'S FACTS: one device section per device (design §3.2,
// §3.6). Its device identity and hardware marker; the act in flight; the
// settings that could weaken protection (the gate style, the idle lock, the
// scheduled Markdown export); the Apple key ids this Mac minted or followed
// for the library and its account, and whether each is retired; the old
// shared key's state; and a version that only grows.
//
// It has TWO SEALED HOMES — its section of the protection record (inside the
// encrypted library) and what this Mac remembers — and `DeviceFacts` below is
// the one place they meet: at open the newer version wins and the retired
// Apple key ids are the union, so replaying either home alone changes nothing.

/// An act between its first step and its last (§3.2): its sequence number,
/// the act, and the keys it moves between. A plan resumes only when this names
/// it (§3.6).
public struct ActInFlight: Codable, Equatable, Sendable {
    public var sequence: Int
    public var act: ProtectionAct
    public var fromFingerprint: String?
    public var toFingerprint: String?
    public var startedAt: Date

    public init(
        sequence: Int, act: ProtectionAct, fromFingerprint: String? = nil,
        toFingerprint: String? = nil, startedAt: Date
    ) {
        self.sequence = sequence
        self.act = act
        self.fromFingerprint = fromFingerprint
        self.toFingerprint = toFingerprint
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
    /// A NEW DEVICE IDENTITY — a replacement Mac (§3.10, §3.13): no act and so
    /// no press, so Always ask; Touch ID comes on only from Settings.
    public static let newIdentity = DeviceSettings(gateStyle: .alwaysAsk)
}

/// Whose Apple key an id is (§3.5): this Mac's own for the library, or the
/// sync account's (which locks only the account's master in the vault).
public enum AppleKeyPurpose: String, Codable, Sendable {
    case library
    case account
}

/// How this Mac came to list it: minted here, followed (read — the account's
/// key a follower picked up), or adopted from a predecessor's section by a
/// replacement Mac (§3.5).
public enum AppleKeyOrigin: String, Codable, Sendable {
    case minted
    case followed
    case adopted
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

    /// "This Mac's own for the library": minted by it, or adopted from its
    /// predecessor (§3.5 — "this Mac's own means minted and named by it").
    public var isOwnLibraryKey: Bool { purpose == .library && origin != .followed }
}

/// The OLD SHARED Apple key's state on this device (§3.5 point 4–5): present
/// when this device's section lists it among the keys that ever wrapped this
/// library's keys; its recorded id (the `{id, key}` item's id, so a delete
/// fires only on that id); and its retirement, recorded on the retiring act's
/// own device section only.
public struct OldSharedKeyRecord: Codable, Equatable, Sendable {
    public var id: String
    public var retiredAt: Date?

    public init(id: String, retiredAt: Date? = nil) {
        self.id = id
        self.retiredAt = retiredAt
    }
}

public struct DeviceSection: Codable, Equatable, Sendable {
    /// The device identity (`<mac8>` is its first eight characters).
    public var deviceID: String
    /// `HardwareMarker.compute` — its two salted parts, never the identifiers
    /// themselves.
    public var hardwareMarker: HardwareMarker
    /// Only grows: every change to the section bumps it (§3.6).
    public var version: Int
    public var actInFlight: ActInFlight?
    /// The last act sequence number handed out — so a sequence is never reused
    /// and a plan for an earlier act can never be named again.
    public var lastActSequence: Int
    public var settings: DeviceSettings
    public var appleKeys: [AppleKeyRecord]
    public var oldSharedKey: OldSharedKeyRecord?

    public init(
        deviceID: String, hardwareMarker: HardwareMarker, version: Int = 1,
        actInFlight: ActInFlight? = nil, lastActSequence: Int = 0,
        settings: DeviceSettings, appleKeys: [AppleKeyRecord] = [],
        oldSharedKey: OldSharedKeyRecord? = nil
    ) {
        self.deviceID = deviceID
        self.hardwareMarker = hardwareMarker
        self.version = version
        self.actInFlight = actInFlight
        self.lastActSequence = lastActSequence
        self.settings = settings
        self.appleKeys = appleKeys
        self.oldSharedKey = oldSharedKey
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

    /// §3.5 point 4: the old shared key's door and §3.1's first exception show
    /// only while this device's section lists the key and not as retired.
    public var oldSharedKeyStillStanding: Bool {
        oldSharedKey != nil && oldSharedKey?.retiredAt == nil
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
        _ act: ProtectionAct, from: String?, to: String?, at: Date
    ) -> (section: DeviceSection, sequence: Int) {
        var next = bumped()
        next.lastActSequence += 1
        next.actInFlight = ActInFlight(
            sequence: next.lastActSequence, act: act, fromFingerprint: from, toFingerprint: to, startedAt: at)
        return (next, next.lastActSequence)
    }

    /// The act ends — only the one named (a stale end changes nothing).
    public func endingAct(sequence: Int) -> DeviceSection {
        guard actInFlight?.sequence == sequence else { return self }
        var next = bumped()
        next.actInFlight = nil
        return next
    }

    /// A copy's act in flight is cleared whenever it's opened (§3.6, §3.7).
    public func clearingActInFlight() -> DeviceSection {
        guard actInFlight != nil else { return self }
        var next = bumped()
        next.actInFlight = nil
        return next
    }
}

// MARK: - The two homes, the identity, the takeover

/// How a Mac found its own device identity at open (§3.6, §3.13).
public enum IdentityResolution: Equatable, Sendable {
    /// What this Mac remembers names an identity made on THIS hardware and
    /// login — it continues.
    case continuing(deviceID: String)
    /// No usable memory item: the record's section whose marker is this
    /// Mac's hardware and login — adopted, so its settings and retired ids
    /// stay its own (deleting the memory item changes nothing on its own).
    case foundByMarker(deviceID: String)
    /// A new identity is minted for NEW HARDWARE (or a library nothing here
    /// knows): what this Mac remembers turned up from other hardware (Quick
    /// Start, Migration Assistant, a restored backup) — then it names its
    /// PREDECESSOR, whose Apple keys the new identity takes over (§3.5); or no
    /// memory item came along and no section of the record is this
    /// hardware's — a replacement with no predecessor to name, taking over
    /// what §3.5 needs no predecessor for (P-U4-3 as her split simplified it).
    case newIdentity(predecessorID: String?)
    /// ANOTHER macOS LOGIN on this same hardware (VX-340; her ruling
    /// 2026-10-14/15 split the marker so it can be told apart): a section of
    /// the record, or the memory item, carries THIS hardware's part under a
    /// different login's part. It mints its own identity and ADOPTS NOTHING —
    /// no settings, no Apple key ids, no retired ids; it starts with no choice
    /// yet, like any brand-new identity with no predecessor (P-U1-7).
    case anotherLogin
}

public enum DeviceFacts {
    /// **The two homes at open** (§3.6): the newer version wins, and the
    /// retired Apple key ids — and the old shared key's retirement — are the
    /// union of both, so a library file replayed alone loses to the memory, a
    /// memory item replayed alone loses to the record, and neither can weaken
    /// delete on sight. A home that failed its seal is passed as nil and loses.
    /// Equal versions take the record's (inside the encrypted library). Guard
    /// off (DEBUG mutation pins only): the memory wins blindly.
    public static func reconcile(
        record: DeviceSection?, memory: DeviceSection?, guards: ProtectionGuards = .all
    ) -> DeviceSection? {
        guard guards.twoHomesOn else { return memory ?? record }
        guard let record else { return memory }
        guard let memory else { return record }
        let (winner, loser) = memory.version > record.version ? (memory, record) : (record, memory)
        var merged = winner
        for retired in loser.appleKeys where retired.retiredAt != nil {
            if let index = merged.appleKeys.firstIndex(where: { $0.id == retired.id }) {
                let mine = merged.appleKeys[index].retiredAt
                merged.appleKeys[index].retiredAt = [mine, retired.retiredAt].compactMap { $0 }.min()
            } else {
                merged.appleKeys.append(retired)
            }
        }
        if let lost = loser.oldSharedKey, let lostRetired = lost.retiredAt {
            if var shared = merged.oldSharedKey {
                // The same old-name item only: a different id is an item an
                // older build minted later — never this one's retirement.
                if shared.id == lost.id {
                    shared.retiredAt = [shared.retiredAt, lostRetired].compactMap { $0 }.min()
                    merged.oldSharedKey = shared
                }
            } else {
                merged.oldSharedKey = lost
            }
        }
        return merged
    }

    /// **Which identity is this Mac's** (§3.6, §3.13, VX-340). `memory` is
    /// what this Mac remembers, verified (nil when absent or failing its
    /// seal); `sections` are the record's verified sections; `marker` is
    /// `HardwareMarker.compute` for this hardware and login under the
    /// record's salt — its two parts (her ruling 2026-10-14/15).
    ///
    /// 1. The memory's identity, when its marker is this Mac's (both parts) →
    ///    continuing.
    /// 2. Else a record section whose marker is this Mac's (both parts) →
    ///    found by marker (PROVISIONAL P-U1-2 ordering: a foreign memory item
    ///    beside this Mac's own section yields to the section, which is the
    ///    marker's own evidence of who this Mac is). Several → the highest
    ///    version.
    /// 3. Else a memory item, or with none a record section, from THIS
    ///    hardware under another login → another login on this Mac: its own
    ///    identity, adopting nothing (VX-340).
    /// 4. Else, with a memory item from other hardware → a new identity
    ///    naming the memory's identity as its predecessor (a replacement).
    /// 5. Else, a record section on other hardware under THIS login's part →
    ///    a new identity naming that section's identity as its predecessor
    ///    (PROVISIONAL P-U4-14: the login part, carried with the user record,
    ///    names the previous Mac when no memory item came along).
    /// 6. Else → a new identity with no predecessor (new hardware with no
    ///    memory item, or a library nothing here knows).
    ///
    /// Guard off (DEBUG mutation pins only): the memory's identity is trusted
    /// wherever it turns up, and with no memory item the first section is
    /// adopted — the two bugs the marker exists to close.
    public static func resolveIdentity(
        memory: DeviceMemory?, sections: [DeviceSection], marker: HardwareMarker,
        guards: ProtectionGuards = .all
    ) -> IdentityResolution {
        guard guards.hardwareMarkerOn else {
            if let memory { return .continuing(deviceID: memory.deviceID) }
            if let first = sections.first { return .foundByMarker(deviceID: first.deviceID) }
            return .newIdentity(predecessorID: nil)
        }
        if let memory, memory.hardwareMarker == marker {
            return .continuing(deviceID: memory.deviceID)
        }
        let mine = sections.filter { $0.hardwareMarker == marker }
            .max { ($0.version, $1.deviceID) < ($1.version, $0.deviceID) }
        if let mine { return .foundByMarker(deviceID: mine.deviceID) }
        if let memory {
            return memory.hardwareMarker.sameHardware(as: marker)
                ? .anotherLogin : .newIdentity(predecessorID: memory.deviceID)
        }
        if sections.contains(where: { $0.hardwareMarker.sameHardware(as: marker) }) { return .anotherLogin }
        // No memory item came along (Migration Assistant never carries one):
        // a section on OTHER hardware under THIS login's part is this login's
        // previous Mac — the predecessor, named by her split marker's login
        // part (PROVISIONAL P-U4-14; the closer's soak, seed 11: a Mac
        // replaced mid-Use-Castle never learned its predecessor's own Apple
        // keys, and the pre-Castle copies stayed open through the Apple
        // account). Several → the highest version.
        if let predecessor = sections.filter({ $0.hardwareMarker.login == marker.login })
            .max(by: { ($0.version, $1.deviceID) < ($1.version, $0.deviceID) }) {
            return .newIdentity(predecessorID: predecessor.deviceID)
        }
        return .newIdentity(predecessorID: nil)
    }

    /// **A replacement Mac takes over its predecessor's keys** (§3.5): a new
    /// identity on new hardware adopts the Apple key ids its live key file's
    /// wraps name as its own, every other id its predecessor's section lists
    /// as its own for the library, and every id ANY section of the record
    /// lists as retired (a retired key is dead everywhere). It starts on
    /// Always ask (§3.10). The scheduled export and the idle lock start at
    /// their defaults (§3.10's "a device with no choice yet").
    public static func takingOver(
        predecessor: DeviceSection?, allSections: [DeviceSection], newDeviceID: String,
        marker: HardwareMarker, keyFileOwnAppleKeyIDs: [String], keyFileSharedAppleKeyID: String? = nil
    ) -> DeviceSection {
        var section = DeviceSection(
            deviceID: newDeviceID, hardwareMarker: marker, settings: .newIdentity)
        func adopt(_ record: AppleKeyRecord) {
            if let index = section.appleKeys.firstIndex(where: { $0.id == record.id }) {
                let mine = section.appleKeys[index].retiredAt
                section.appleKeys[index].retiredAt = [mine, record.retiredAt].compactMap { $0 }.min()
            } else {
                section.appleKeys.append(record)
            }
        }
        for id in keyFileOwnAppleKeyIDs {
            adopt(AppleKeyRecord(id: id, purpose: .library, origin: .adopted))
        }
        for record in predecessor?.appleKeys ?? [] where record.isOwnLibraryKey {
            adopt(AppleKeyRecord(id: record.id, purpose: .library, origin: .adopted, retiredAt: record.retiredAt))
        }
        for other in allSections + [predecessor].compactMap({ $0 }) {
            for record in other.appleKeys where record.retiredAt != nil {
                adopt(AppleKeyRecord(
                    id: record.id, purpose: record.purpose, accountID: record.accountID,
                    origin: .adopted, retiredAt: record.retiredAt))
            }
        }
        // The old shared key's state (§3.5 points 4–5): the predecessor's, as
        // it stood — this is the same Mac; with no predecessor to name, a
        // retirement any section of this library's record lists (by its id —
        // delete on sight fires only on that id, on the Apple account whose
        // device already deleted it). Otherwise a delete the replaced keychain
        // never carried left the old key alive here, opening this library's
        // pre-Castle copies, with neither the door nor §3.1's first exception
        // showing. PROVISIONAL P-U4-9 (VX-305 U4, found by the scenario world).
        if let shared = predecessor?.oldSharedKey {
            section.oldSharedKey = shared
        } else if predecessor == nil,
                  let retired = allSections.compactMap(\.oldSharedKey).filter({ $0.retiredAt != nil })
                    .min(by: { ($0.retiredAt ?? .distantFuture) < ($1.retiredAt ?? .distantFuture) }) {
            section.oldSharedKey = retired
        } else if predecessor == nil, case let standing = allSections.compactMap(\.oldSharedKey), !standing.isEmpty {
            // …and with no retirement listed, a STANDING record any section
            // lists: the key still wraps this library's pre-Castle copies, so
            // the replacement shows the door and §3.1's first exception too —
            // it fell away with no predecessor named, leaving those copies open
            // through the Apple account unsaid (VX-305 U4, the soak's seed 7;
            // P-U4-9 extended). The pick (VX-305 ladder round 1, NIT 5): the
            // record whose id the live key file's shared wrap names — the old
            // shared key that actually wraps THIS library's key; else the
            // smallest id, never the record's storage order. (The retirement
            // deletes by the recorded id first, so a record of another Apple
            // account's key would miss this Mac's; where none matches that
            // stays P-U4-1's known-leftover class, her P-U4-9 "any standing
            // record" wording.)
            section.oldSharedKey = standing.first { $0.id == keyFileSharedAppleKeyID }
                ?? standing.min { $0.id < $1.id }
        }
        return section
    }

    /// **This Mac's section, at open** — the resolution, the two homes, the
    /// takeover, composed. `mintDeviceID` is called only when a new identity
    /// is minted. Returns the section and how it was found.
    public static func thisMacsSection(
        memory: DeviceMemory?, recordSections: [DeviceSection], marker: HardwareMarker,
        keyFileOwnAppleKeyIDs: [String], keyFileSharedAppleKeyID: String? = nil, mintDeviceID: () -> String,
        guards: ProtectionGuards = .all
    ) -> (section: DeviceSection, resolution: IdentityResolution) {
        let resolution = resolveIdentity(
            memory: memory, sections: recordSections, marker: marker, guards: guards)
        func recordSection(_ id: String) -> DeviceSection? {
            recordSections.filter { $0.deviceID == id }.max { $0.version < $1.version }
        }
        func fresh() -> (DeviceSection, IdentityResolution) {
            (DeviceSection(deviceID: mintDeviceID(), hardwareMarker: marker, settings: .noChoiceYet),
             .newIdentity(predecessorID: nil))
        }
        switch resolution {
        case .continuing(let id):
            guard let section = reconcile(
                record: recordSection(id), memory: memory?.deviceSection, guards: guards)
            else { return fresh() }
            return (section, resolution)
        case .foundByMarker(let id):
            guard let section = recordSection(id) else { return fresh() }
            return (section, resolution)
        case .anotherLogin:
            // Another macOS login on this hardware (VX-340): its own identity,
            // adopting nothing — not the other login's settings, its own keys'
            // list or its retired ids; no choice yet (P-U1-7).
            return (DeviceSection(deviceID: mintDeviceID(), hardwareMarker: marker, settings: .noChoiceYet), .anotherLogin)
        case .newIdentity(let predecessorID):
            guard let predecessorID else {
                // NEW HARDWARE whose memory item didn't come along — Migration
                // Assistant reportedly doesn't carry Local Items (the Apple
                // facts §3.7) — opening a library the record already knows
                // (no section of it is this hardware's, so this is no second
                // login — that is `.anotherLogin`): a replacement with no
                // predecessor to name, but §3.5's other two takeovers need
                // none — the Apple key ids ITS LIVE KEY FILE's wraps name as
                // its own, and every id any section lists as retired ("a
                // retired key is dead everywhere"). It starts on Always ask
                // (§3.10: no act, no press). PROVISIONAL P-U4-3, as her
                // 2026-10-14/15 split of the marker simplified it: the
                // takeover is new hardware's alone.
                guard !recordSections.isEmpty else { return fresh() }
                return (takingOver(
                    predecessor: nil, allSections: recordSections, newDeviceID: mintDeviceID(), marker: marker,
                    keyFileOwnAppleKeyIDs: keyFileOwnAppleKeyIDs, keyFileSharedAppleKeyID: keyFileSharedAppleKeyID),
                        resolution)
            }
            let predecessor = reconcile(
                record: recordSection(predecessorID), memory: memory?.deviceSection, guards: guards)
            return (takingOver(
                predecessor: predecessor, allSections: recordSections, newDeviceID: mintDeviceID(),
                marker: marker, keyFileOwnAppleKeyIDs: keyFileOwnAppleKeyIDs, keyFileSharedAppleKeyID: keyFileSharedAppleKeyID),
                    resolution)
        }
    }
}
