import Foundation

// VX-305 U2 — WHAT `assess` READS (design §3.3): the things of §3.2 as this
// device found them, plus the session, the vault reading (fresh, for this
// account, this session — or none), the store file's presence and the
// container marker. Plain values, read by leaves (phase 2 wires them); `assess`
// takes them and calls nothing. Before unlock nothing here decides anything:
// the record and this Mac's facts are inside the encrypted library and the
// sealed memory, so `unlocked` is nil and the lobby offers roads only.

/// What sits at the slot (today's `StoreFilePresence`, plus the plaintext
/// export's shape where a picked file is concerned).
public enum StoreFileFact: String, Equatable, Sendable {
    case absent
    case present
    case plaintext
}

/// Who the session is signed in as (§3.8). The record names the account;
/// signing in or out never changes it.
public enum SessionFact: Equatable, Sendable {
    case signedOut
    case signedIn(accountID: String, email: String?)

    public var accountID: String? {
        if case .signedIn(let id, _) = self { return id }
        return nil
    }
}

/// The vault as read THIS session for the session's account — decision 35's
/// "fresh vault read". Non-secret fields only (rules 14, 15: the mode flag, the
/// current sync key's id, the recovery wrap's bytes).
public struct VaultReading: Equatable, Sendable {
    public var accountID: String
    /// THE MODE FLAG — the account's one posture.
    public var mode: ProtectionMode
    /// The current sync key's id — what a library compares with the one it
    /// follows (`ProtectionRecord.accountRowKeyID`).
    public var rowKeyID: String
    /// The passphrase lock's descriptor (VX-113: a passphrase changed elsewhere
    /// is named by it).
    public var kdf: PassphraseKDF.Descriptor?
    /// The recovery wrap (the master under the words), as read — what proves a
    /// key file's master words copy current (old design §3.5a).
    public var recoveryWrap: Data?
    /// Decision 34's device name and the row's day — the notices' *[device] on
    /// [day]*.
    public var updatedByDevice: String?
    public var updatedAt: Date?

    public init(
        accountID: String, mode: ProtectionMode, rowKeyID: String, kdf: PassphraseKDF.Descriptor? = nil,
        recoveryWrap: Data? = nil, updatedByDevice: String? = nil, updatedAt: Date? = nil
    ) {
        self.accountID = accountID
        self.mode = mode
        self.rowKeyID = rowKeyID
        self.kdf = kdf
        self.recoveryWrap = recoveryWrap
        self.updatedByDevice = updatedByDevice
        self.updatedAt = updatedAt
    }
}

/// The Apple keys this device can see in this scope's family (§3.5).
public struct AppleKeyFacts: Equatable, Sendable {
    /// Ids of the `<scope>-apple-key-<id>` items present and readable here.
    public var readable: Set<String>

    public init(readable: Set<String> = []) {
        self.readable = readable
    }
}

/// A sync-keys item present here (`<scope>-<accountID>-<class>`).
public struct SyncKeysItemFact: Hashable, Sendable {
    public var accountID: String
    public var itemClass: ProtectionNames.CustodyClass

    public init(accountID: String, itemClass: ProtectionNames.CustodyClass) {
        self.accountID = accountID
        self.itemClass = itemClass
    }
}

/// Why Touch ID is unusable FOR NOW — a momentary reading that never changes
/// anything (§3.10).
public enum TransientUnavailability: String, Equatable, Sendable, CaseIterable {
    /// `builtInSensorInaccessible` — clamshell mode.
    case lidClosed
    case keyboardDisconnected
    case keyboardNotPaired
    case lockout
}

/// This Mac's biometry (`LAEnvironment`, macOS 15+ — the Apple facts §5).
public struct BiometryFacts: Equatable, Sendable {
    /// Touch ID hardware exists (built in, or a paired keyboard's).
    public var hardware: Bool
    /// At least one finger enrolled.
    public var enrolled: Bool
    /// Unusable for now, and why.
    public var transient: TransientUnavailability?

    public init(hardware: Bool, enrolled: Bool, transient: TransientUnavailability? = nil) {
        self.hardware = hardware
        self.enrolled = enrolled
        self.transient = transient
    }

    public static let none = BiometryFacts(hardware: false, enrolled: false)
    public static let ready = BiometryFacts(hardware: true, enrolled: true)
}

/// What the last Touch ID press this open did (§3.10).
public enum TouchIDPress: Equatable, Sendable {
    /// It failed against an item that exists — a biometry change invalidated
    /// it, or the hash moved with nothing changed (a macOS update); the item
    /// is the final word, never the hash.
    case failedOnExistingItem
    /// Unusable for now: the press said why and changed nothing.
    case transient(TransientUnavailability)
    case cancelled
}

/// The facts that exist only after unlock — verified by the key in hand.
public struct UnlockedFacts: Sendable {
    /// The record, verified. (A library with no record is from before this
    /// design and is not handled — rule 26; it never unlocks.)
    public var record: ProtectionRecord
    /// This Mac's section at open (`DeviceFacts.thisMacsSection`).
    public var thisMac: DeviceSection
    /// What this Mac remembers, verified (nil: absent, or it failed its seal).
    public var memory: DeviceMemory?
    /// The key the library opened under.
    public var currentFingerprint: String
    /// The live key file's id in the catalog.
    public var liveKeyFileID: String?
    /// RULE 21: what the open said — the library in the live place is not the
    /// one this Mac last opened (`UnlockedLibrary.notice`).
    public var notice: LibraryNotice?

    public init(
        record: ProtectionRecord, thisMac: DeviceSection, memory: DeviceMemory? = nil,
        currentFingerprint: String, liveKeyFileID: String? = nil, notice: LibraryNotice? = nil
    ) {
        self.record = record
        self.thisMac = thisMac
        self.memory = memory
        self.currentFingerprint = currentFingerprint
        self.liveKeyFileID = liveKeyFileID
        self.notice = notice
    }
}

/// **Everything `assess` reads.**
public struct ProtectionFacts: Sendable {
    public var scope: String
    public var storeFile: StoreFileFact
    /// "A library lived here" — the container's marker (§3.2).
    public var containerMarker: Bool
    /// nil before unlock.
    public var unlocked: UnlockedFacts?
    /// Before unlock: the current fingerprint the slot's key file names (else
    /// what this Mac remembers) — a display hint, unverified (every road
    /// verifies itself).
    public var slotFingerprintHint: String?
    /// Before unlock: the mode this Mac last confirmed — a display hint that
    /// decides nothing.
    public var rememberedModeHint: ProtectionMode?
    /// The email this device last knew for the library's account (the
    /// other-account screen names the same email with a different account).
    public var libraryAccountEmail: String?
    /// The library IDs this scope's memory items name (enumerated by name).
    public var rememberedLibraryIDs: Set<String>
    /// This scope's custody items, enumerated.
    public var custody: [CustodyItemFact]
    public var syncKeys: [SyncKeysItemFact]
    public var appleKeys: AppleKeyFacts
    public var biometry: BiometryFacts
    public var touchIDPress: TouchIDPress?
    public var session: SessionFact
    /// The vault, read this session for the session's account — or none.
    public var vault: VaultReading?
    public var catalog: Catalog
    public var now: Date

    public init(
        scope: String, storeFile: StoreFileFact = .present, containerMarker: Bool = true,
        unlocked: UnlockedFacts? = nil, slotFingerprintHint: String? = nil, rememberedModeHint: ProtectionMode? = nil,
        libraryAccountEmail: String? = nil, rememberedLibraryIDs: Set<String> = [], custody: [CustodyItemFact] = [],
        syncKeys: [SyncKeysItemFact] = [], appleKeys: AppleKeyFacts = AppleKeyFacts(),
        biometry: BiometryFacts = .ready, touchIDPress: TouchIDPress? = nil, session: SessionFact = .signedOut,
        vault: VaultReading? = nil, catalog: Catalog = Catalog(), now: Date
    ) {
        self.scope = scope
        self.storeFile = storeFile
        self.containerMarker = containerMarker
        self.unlocked = unlocked
        self.slotFingerprintHint = slotFingerprintHint
        self.rememberedModeHint = rememberedModeHint
        self.libraryAccountEmail = libraryAccountEmail
        self.rememberedLibraryIDs = rememberedLibraryIDs
        self.custody = custody
        self.syncKeys = syncKeys
        self.appleKeys = appleKeys
        self.biometry = biometry
        self.touchIDPress = touchIDPress
        self.session = session
        self.vault = vault
        self.catalog = catalog
        self.now = now
    }

    /// The vault reading counts only for the account it is for, and only for
    /// the account the library names (decision 35: "a fresh vault read for
    /// its account").
    func freshVault(for account: String?) -> VaultReading? {
        guard let account, let vault, vault.accountID == account, session.accountID == account else { return nil }
        return vault
    }
}
