import CryptoKit
import Foundation

// VX-305 U3 — THE EXECUTOR (design §3.3: "the only code that writes custody
// items, sync keys, the key file, the record, what this Mac remembers, plans,
// Apple keys and the vault. It runs repairs and plan steps. Every write is
// verified, and every delete comes after its replacement has verified —
// except a retirement, which deletes with no replacement by design").
//
// THE PLAN RUNNER (§3.6, §3.9; VX-235's class): every act is a SEALED PLAN.
//   - Begin: this Mac's device section names the act in flight — its next
//     sequence number, the act, the keys it moves between — written into BOTH
//     homes (the record inside the library, and what this Mac remembers);
//     then the plan, sealed under the key in hand, naming that sequence.
//   - Steps run in order and each is idempotent; the plan is re-sealed with
//     the step marked done after it. A resume starts from the first
//     unfinished step.
//   - A plan resumes ONLY when this Mac's section names it (the planted and
//     the replayed plan): one the section doesn't name, or failing its seal,
//     is ignored and reported. A missing or unmatched plan never blocks:
//     before the commit point (the swap) the act ROLLS BACK — the old custody
//     item, the history or the anchor still open the library — and after it
//     the act's fixed remaining steps FINISH FROM THE RECORD. A synced
//     rotation resumes from the server's own state (the device follows its own
//     landed rotation as any follower would).
//   - End: the act in flight cleared in both homes, the plan deleted.
// So after a crash at any write and a relaunch, an act finishes or rolls
// back — never a third state (promise 6) — and the tests prove it write by
// write.

public struct ExecutorConfiguration: Sendable {
    /// The store-variant scope (`Variorum` / `Variorum-dev`).
    public var scope: String
    /// The library in the slot.
    public var libraryID: String
    /// This hardware and this macOS login — read by a leaf, hashed into the
    /// marker, never stored or logged.
    public var machine: MachineIdentity
    /// This device's name — the vault's `updated_by_device` (decision 34).
    public var deviceName: String
    /// The KDF floor every derivation checks first (tests: `.relaxedForTests`).
    public var floor: PassphraseKDF.Floor
    /// Who the session is signed in as.
    public var session: SessionFact

    public init(
        scope: String, libraryID: String, machine: MachineIdentity, deviceName: String,
        floor: PassphraseKDF.Floor = PassphraseKDF.floor, session: SessionFact = .signedOut
    ) {
        self.scope = scope
        self.libraryID = libraryID
        self.machine = machine
        self.deviceName = deviceName
        self.floor = floor
        self.session = session
    }
}

/// The library as the executor holds it after unlock — every home verified
/// with the key in hand (a home failing its seal arrives as nil and loses).
public struct UnlockedLibrary {
    /// The key the library opened under.
    public var key: StoreKey
    /// nil: a library from before this change — the migration's subject.
    public var record: ProtectionRecord?
    /// This Mac's section at open (the two homes reconciled).
    public var section: DeviceSection
    public var resolution: IdentityResolution
    public var memory: DeviceMemory?
    /// The live key file, when it is format 3.
    public var keyFile: KeyFile?
    /// The family tree at open (its two homes unioned).
    public var familyTree: FamilyTree
    /// The other keys the lobby's road reached on the way (the live key file's
    /// current key when the library opened through its history) — what the
    /// older-library-file repair re-encrypts under.
    public var keysInHand: [StoreKey] = []

    public var fingerprint: String { StoreKeyEnvelope.fingerprint(of: key) }

    public init(
        key: StoreKey, record: ProtectionRecord?, section: DeviceSection, resolution: IdentityResolution,
        memory: DeviceMemory?, keyFile: KeyFile?, familyTree: FamilyTree
    ) {
        self.key = key
        self.record = record
        self.section = section
        self.resolution = resolution
        self.memory = memory
        self.keyFile = keyFile
        self.familyTree = familyTree
    }
}

/// The secrets typed at a door — derived by the executor under the right
/// descriptor, held only for the act's span, NEVER stored.
public struct TypedSecrets: Sendable, CustomStringConvertible {
    /// The current passphrase, typed (verified against the live key file or
    /// the vault).
    public var passphrase: String?
    /// The twelve words, typed (verified) — or made new (`wordsAreNew`).
    public var words: [String]?
    public var wordsAreNew: Bool
    /// A NEW passphrase (set new — a fresh descriptor).
    public var newPassphrase: String?

    public init(passphrase: String? = nil, words: [String]? = nil, wordsAreNew: Bool = false, newPassphrase: String? = nil) {
        self.passphrase = passphrase
        self.words = words
        self.wordsAreNew = wordsAreNew
        self.newPassphrase = newPassphrase
    }

    public static let none = TypedSecrets()

    public var description: String { "TypedSecrets(redacted)" }
}

/// The derived secrets an act holds in hand.
public struct ActSecrets: Sendable {
    public var passphrase: PassphraseKey?
    public var words: WordsKey?

    public init(passphrase: PassphraseKey? = nil, words: WordsKey? = nil) {
        self.passphrase = passphrase
        self.words = words
    }

    public var isEmpty: Bool { passphrase == nil && words == nil }
}

/// Every refusal the executor names (the doors' sentences are phase 4's).
public enum ExecutorRefusal: Error, Equatable, Sendable {
    case keyDoesNotOpenLibrary
    /// A library with no record yet: the migration runs first.
    case migrationOwed
    /// An act is already in flight on this device — resume it first.
    case actInFlight(ProtectionAct)
    /// A resume needs the secrets typed again (a plan never holds one).
    case secretsRequired(ProtectionAct)
    case passphraseDoesNotOpen
    case wordsDoNotOpen
    /// A door asks for a secret that wasn't given.
    case secretMissing
    /// Use Standard types the words — never makes new ones (§3.9).
    case wordsMustBeTyped
    /// VX-113: the passphrase typed was changed elsewhere — the change named.
    case passphraseChangedElsewhere(device: String?, day: Date?)
    case wrongMode(ProtectionMode)
    case modeNotConfirmed
    case notSynced
    case noAccountSignedIn
    case otherAccountSignedIn
    /// Signed out: the one plain road (This Mac Only) stands in its place.
    case signedOutUseThisMacOnly
    /// Decision 35 / a synced act: the vault must be read fresh this session.
    case needsFreshVault
    /// The account's vault can't be reached this session — signed out, signed
    /// into another account, or offline: nothing was read or written. A synced
    /// act past its commit point WAITS for it, named (her ruling 2026-10-14/15:
    /// "Finish leaving Castle — sign in to finish"); before it, the act rolls
    /// back.
    case vaultOutOfReach(account: String)
    /// Decision 32: one rotation at a time.
    case rotationInProgress
    /// The account's keys moved elsewhere since the door — follow first.
    case accountMoved
    /// §3.5 point 4: a vault on the old shared key stops Use Castle.
    case vaultOnOldSharedKey(account: String)
    /// No Apple key readable where one is needed (never minted to make up).
    case appleKeyUnreadable
    /// A leave's completing write waits for the named key (§3.9).
    case waitingForNamedAppleKey
    case noLiveKeyFile
    case recordMissing
    case nothingToDo
    /// The act's subject is not this library.
    case wrongLibrary
    /// A repair the guards forbid: it would make a Touch ID item, or act
    /// destructively on a Standard record's word alone.
    case repairForbidden(String)
}

public final class ProtectionExecutor {
    public let leaves: ExecutorLeaves
    public var configuration: ExecutorConfiguration
    public let guards: ProtectionGuards
    /// The vault as read THIS SESSION, per account — decision 35's "fresh
    /// vault read". Only this executor's own fetches go here.
    public internal(set) var freshVaults: [String: VaultSnapshot] = [:]
    /// Every account whose vault this session has read (present or absent).
    var vaultsReadThisSession: Set<String> = []
    /// A copy act's in-hand facts, for its span only (never stored): the
    /// copy's own key, its record, a landing's new record and section.
    var copyOpenerInHand: StoreKey?
    var copyRecordInHand: ProtectionRecord?
    var landingInHand: (record: ProtectionRecord, section: DeviceSection)?

    public init(leaves: ExecutorLeaves, configuration: ExecutorConfiguration, guards: ProtectionGuards = .all) {
        self.leaves = leaves
        self.configuration = configuration
        self.guards = guards
    }

    var libraryID: String { configuration.libraryID }
    func now() -> Date { leaves.clock.now() }
    func log(_ line: String) { leaves.diagnostics.log(line) }
    static func fp8(_ fingerprint: String?) -> String { String((fingerprint ?? "none").prefix(8)) }
    static func fp(_ key: StoreKey) -> String { StoreKeyEnvelope.fingerprint(of: key) }

    // MARK: - The vault, read fresh

    /// Read the account's vault now — the one road to a "fresh vault read".
    /// Only the account this session is signed into: the vault is the
    /// account's (row-level security), so a device signed out, or signed into
    /// another account, never asks — a resume that met that wrote the vault
    /// while signed out (VX-305 U4, the soak's seed 2 — her ruling
    /// 2026-10-14/15).
    @discardableResult
    public func readVault(accountID: String) async throws -> VaultSnapshot? {
        guard configuration.session.accountID == accountID else {
            throw ExecutorRefusal.vaultOutOfReach(account: accountID)
        }
        let snapshot = try await leaves.vault.fetchVault(accountID: accountID)
        if let snapshot { freshVaults[accountID] = snapshot } else { freshVaults[accountID] = nil }
        vaultsReadThisSession.insert(accountID)
        return snapshot
    }

    /// Decision 35: a vault read this session for `account`, signed in as it.
    func freshVault(for account: String?) -> VaultSnapshot? {
        guard let account, configuration.session.accountID == account else { return nil }
        return freshVaults[account]
    }

    /// Whether this session has read `account`'s vault — present, or absent
    /// (sync setup's read finds none, and that is the account's word too).
    func readThisSession(_ account: String) -> Bool {
        configuration.session.accountID == account && vaultsReadThisSession.contains(account)
    }

    // MARK: - Unlock: every home verified with the key in hand

    /// The library as this Mac holds it, opened with `key` (a road's key).
    /// `alsoInHand`: every other key the lobby's road reached on the way (the
    /// live key file's current key when the library opened through its
    /// history — a library file swapped for an older one) — a home sealed under
    /// any of them still verifies, so a replayed library file alone loses to
    /// the newer memory (§3.6).
    public func unlock(with key: StoreKey, alsoInHand: [StoreKey] = []) throws -> UnlockedLibrary {
        guard try leaves.library.libraryOpens(with: key) else { throw ExecutorRefusal.keyDoesNotOpenLibrary }
        let liveFile = try liveFormat3()
        let reach = reach(key: key, keyFile: liveFile, extra: alsoInHand)
        let record = try leaves.library.readRecord(with: key)
        let slotLibrary = record?.libraryID ?? libraryID
        let memory = try leaves.memory.readMemory(libraryID: slotLibrary)
            .flatMap { DeviceMemory.opening($0, libraryID: slotLibrary, reach: reach) }
        guard let record else {
            // A library from before this change: the migration builds this
            // Mac's section from its own facts.
            let section = memory?.deviceSection ?? DeviceSection(
                deviceID: leaves.ids.mintID(), hardwareMarker: .unset, settings: .noChoiceYet)
            return UnlockedLibrary(
                key: key, record: nil, section: section, resolution: .newIdentity(predecessorID: nil),
                memory: memory, keyFile: liveFile, familyTree: memory?.familyTree ?? FamilyTree())
        }
        // The executor serves the slot's library (a landing changes it).
        configuration.libraryID = record.libraryID
        let sections = record.verifiedSections(reach: reach)
        // The key file a new identity's takeover reads (§3.5: "the Apple key
        // ids its live key file's wraps name"): the live one — or, when the
        // live place holds another key's file and a plan that verifies carried
        // this key's own (an act its predecessor began), that one, which the
        // settle then restores (VX-305 U4, the soak's seed 2).
        var ownFile = liveFile
        if liveFile?.fingerprint != StoreKeyEnvelope.fingerprint(of: key), let sealed = try leaves.plans.readPlan(),
           let plan = try? sealed.open(purpose: .plan, libraryID: record.libraryID, reach: reach),
           let outgoing = plan.parameters?.outgoingKeyFile, outgoing.fingerprint == StoreKeyEnvelope.fingerprint(of: key) {
            ownFile = outgoing
        }
        let (section, resolution) = DeviceFacts.thisMacsSection(
            memory: memory, recordSections: sections, marker: record.marker(for: configuration.machine),
            keyFileOwnAppleKeyIDs: [ownFile?.apple?.keyID].compactMap { $0 },
            keyFileSharedAppleKeyID: ownFile?.sharedApple?.keyID,
            mintDeviceID: { self.leaves.ids.mintID() }, guards: guards)
        var unlocked = UnlockedLibrary(
            key: key, record: record, section: section, resolution: resolution, memory: memory, keyFile: liveFile,
            familyTree: FamilyTree.atOpen(record: record.familyTree, memory: memory?.familyTree, guards: guards))
        unlocked.keysInHand = alsoInHand
        return unlocked
    }

    func liveFormat3() throws -> KeyFile? {
        if case .format3(let file)? = try leaves.keyFiles.readLiveKeyFile() { return file }
        return nil
    }

    /// The keys a seal may be verified with: the key in hand, an older one
    /// through the live key file's history, and a key a SILENT custody item
    /// holds (read without a prompt) — every one checked by fingerprint.
    func reach(key: StoreKey, keyFile: KeyFile?, extra: [StoreKey] = []) -> (String) -> StoreKey? {
        let custody = leaves.custody
        return { fingerprint in
            for candidate in [key] + extra where Self.fp(candidate) == fingerprint { return candidate }
            if let keyFile, keyFile.fingerprint == Self.fp(key),
               let older = try? keyFile.historyKey(fingerprint, currentKey: key) {
                return older
            }
            if let held = try? custody.readCustody(fingerprint: fingerprint, itemClass: .silent),
               Self.fp(held) == fingerprint {
                return held
            }
            return nil
        }
    }

    // MARK: - This Mac's facts, written into both homes

    /// What this Mac remembers, agreeing with the record — the key file's
    /// mirror follows the live file only when it is the current key's (mid-act
    /// the mirror keeps the outgoing file, which a roll back restores).
    func memoryValue(for library: UnlockedLibrary) -> DeviceMemory? {
        guard let record = library.record else { return nil }
        let old = library.memory
        var mirror = old?.keyFileMirror
        if let live = library.keyFile, live.fingerprint == record.currentFingerprint { mirror = live }
        return DeviceMemory(
            libraryID: record.libraryID, scope: configuration.scope, currentFingerprint: record.currentFingerprint,
            keyEpoch: record.keyEpoch,
            lastConfirmed: record.modeConfirmed ? ConfirmedFacts(mode: record.mode, account: record.account) : old?.lastConfirmed,
            biometryStateHash: old?.biometryStateHash, vaultFacts: old?.vaultFacts,
            nudgeDismissals: old?.nudgeDismissals ?? [:], keyFileMirror: mirror,
            familyTree: library.familyTree.union(record.familyTree), deviceSection: library.section)
    }

    /// The record's home (inside the library, under the key in hand), then
    /// what this Mac remembers — both carrying `section`.
    func writeFacts(_ library: inout UnlockedLibrary, section: DeviceSection) throws {
        guard var record = library.record else { throw ExecutorRefusal.recordMissing }
        record = try record.storing(section, sealedUnder: library.key)
        try leaves.library.writeRecord(record, with: library.key)
        library.record = record
        library.section = section
        try writeMemory(&library)
    }

    /// What this Mac remembers, sealed under the key in hand.
    func writeMemory(_ library: inout UnlockedLibrary, editing edit: ((inout DeviceMemory) -> Void)? = nil) throws {
        guard var memory = memoryValue(for: library) else { throw ExecutorRefusal.recordMissing }
        edit?(&memory)
        try leaves.memory.writeMemory(try memory.sealed(under: library.key), libraryID: memory.libraryID)
        library.memory = memory
    }

    /// The live key file — and the in-hand copy follows.
    func writeLiveKeyFile(_ file: KeyFile, _ library: inout UnlockedLibrary) throws {
        try leaves.keyFiles.writeLiveKeyFile(file)
        library.keyFile = file
    }
}
