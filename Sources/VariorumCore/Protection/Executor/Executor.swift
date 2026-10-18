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
//     item or the history still opens the library — and after it
//     the act's fixed remaining steps FINISH FROM THE RECORD. A synced act
//     resumes from the vault as it stands (a vault write it already made is
//     picked up — or, out of reach before the swap, it rolls back and the
//     device follows that write as any device would).
//   - End: the act in flight cleared in this Mac's section, the plan deleted.
// So after a crash at any write and a relaunch, an act finishes or rolls
// back — never a third state (promise 6) — and the tests prove it write by
// write.

public struct ExecutorConfiguration: Sendable {
    /// The store-variant scope (`Variorum` / `Variorum-dev`).
    public var scope: String
    /// The library in the slot.
    public var libraryID: String
    /// This device's name — the vault's `updated_by_device` (decision 34).
    public var deviceName: String
    /// The KDF floor every derivation checks first (tests: `.relaxedForTests`).
    public var floor: PassphraseKDF.Floor
    /// Who the session is signed in as.
    public var session: SessionFact

    public init(
        scope: String, libraryID: String, deviceName: String,
        floor: PassphraseKDF.Floor = PassphraseKDF.floor, session: SessionFact = .signedOut
    ) {
        self.scope = scope
        self.libraryID = libraryID
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
    /// The record (a library with no record never unlocks — rule 26).
    public var record: ProtectionRecord?
    /// This Mac's section at open (`DeviceFacts.thisMacsSection`).
    public var section: DeviceSection
    public var memory: DeviceMemory?
    /// The live key file, when it is format 3.
    public var keyFile: KeyFile?
    /// Adjudication 5 (after VX-378 U1): with nothing remembered, an act the
    /// plan on disk names resumes in the section the plan names; this Mac
    /// takes its fresh device ID only once that act has settled.
    public var sectionFromThePlan = false
    /// RULE 21 (her ruling at the U4 stop, 2026-10-17): what the open says
    /// ONCE when the library in the live place is not the one this Mac last
    /// opened — her words, `LibraryNotice.words`. The open went on; what this
    /// Mac remembers follows the library at the open's repairs.
    public var notice: LibraryNotice?

    public var fingerprint: String { StoreKeyEnvelope.fingerprint(of: key) }

    public init(
        key: StoreKey, record: ProtectionRecord?, section: DeviceSection, memory: DeviceMemory?, keyFile: KeyFile?
    ) {
        self.key = key
        self.record = record
        self.section = section
        self.memory = memory
        self.keyFile = keyFile
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
    case notSynced
    case noAccountSignedIn
    case otherAccountSignedIn
    /// Signed out: the one plain road (This Mac Only) stands in its place.
    case signedOutUseThisMacOnly
    /// Decision 35 / a synced act: the vault must be read fresh this session.
    case needsFreshVault
    /// The account's vault can't be reached this session — signed out, signed
    /// into another account, or offline: nothing was read or written; an act
    /// that needed it rolls back (VX-378 U2 — no act waits on a vault).
    case vaultOutOfReach(account: String)
    /// The account's keys moved elsewhere since the door — follow first.
    case accountMoved
    /// No Apple key readable where one is needed (never minted to make up).
    case appleKeyUnreadable
    case noLiveKeyFile
    case recordMissing
    /// Rule 17: nothing typed and no quiet road on this Mac opens the copy.
    case copyDoesNotOpen
    case nothingToDo
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
    /// any of them still verifies. (The older library file no longer loses to
    /// the memory by a repair — VX-378 U1, rule 21 — and no longer refuses:
    /// it opens with rule 21's notice — her ruling at the U4 stop.)
    public func unlock(with key: StoreKey, alsoInHand: [StoreKey] = []) throws -> UnlockedLibrary {
        guard try leaves.library.libraryOpens(with: key) else { throw ExecutorRefusal.keyDoesNotOpenLibrary }
        let liveFile = try liveFormat3()
        let reach = reach(key: key, keyFile: liveFile, extra: alsoInHand)
        // A library with no record is from before this design: rule 26 — not
        // migrated, not handled; it does not unlock.
        guard let record = try leaves.library.readRecord(with: key) else { throw ExecutorRefusal.recordMissing }
        let memory = try leaves.memory.readMemory(libraryID: record.libraryID)
            .flatMap { DeviceMemory.opening($0, libraryID: record.libraryID, reach: reach) }
        let sections = record.verifiedSections(reach: reach)
        // Adjudication 5: nothing remembered, and a plan on disk this library's
        // key seals naming a section of the record with that act in flight —
        // the act resumes there (rule 20), never stranded under a fresh ID.
        var fromPlan: DeviceSection?
        if memory == nil, let sealed = try leaves.plans.readPlan(),
           let plan = try? sealed.open(purpose: .plan, libraryID: record.libraryID, reach: reach),
           plan.libraryID == record.libraryID {
            fromPlan = sections.filter { plan.isNamed(by: $0) }.max { $0.version < $1.version }
        }
        let section = fromPlan ?? DeviceFacts.thisMacsSection(
            memory: memory, recordSections: sections, mintDeviceID: { self.leaves.ids.mintID() })
        // RULE 21 — the notice (her ruling at the U4 stop): the open goes on and
        // says so once; nothing is written here (the memory follows at the
        // open's repairs).
        let named = LibraryNotice.rememberedFingerprint(
            try leaves.memory.readMemory(libraryID: record.libraryID), libraryID: record.libraryID)
        let notice = LibraryNotice.check(
            libraryID: record.libraryID, libraryFingerprint: Self.fp(key), recordDate: record.changedAt,
            rememberedFingerprint: memory?.currentFingerprint ?? named,
            rememberedLibraryIDs: try leaves.memory.rememberedLibraryIDs(),
            liveKeyFile: liveFile, actInFlight: section.actInFlight)
        if let notice { log("unlock: the library in the live place is not the one this Mac last opened — \(notice.words)") }
        // The executor serves the slot's library (a landing changes it).
        configuration.libraryID = record.libraryID
        var library = UnlockedLibrary(key: key, record: record, section: section, memory: memory, keyFile: liveFile)
        library.sectionFromThePlan = fromPlan != nil
        library.notice = notice
        return library
    }

    /// Adjudication 5's other half: once the act the plan named has settled,
    /// this Mac — remembering nothing — takes a fresh plain device ID with a
    /// fresh section (P-VX378-U1-1 (a)).
    func takeFreshDeviceIDAfterTheSettle(_ library: inout UnlockedLibrary) throws {
        guard library.sectionFromThePlan, library.section.actInFlight == nil else { return }
        library.sectionFromThePlan = false
        try writeFacts(&library, section: DeviceSection(deviceID: leaves.ids.mintID(), settings: .noChoiceYet))
        log("settle: the act the plan named settled — this Mac takes a fresh device ID")
    }

    func liveFormat3() throws -> KeyFile? { try leaves.keyFiles.readLiveKeyFile() }

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

    // MARK: - This Mac's facts: the record's section, and what this Mac remembers

    /// What this Mac remembers, agreeing with the record — the key file's
    /// mirror follows the live file only when it is the current key's (mid-act
    /// the mirror keeps the outgoing file, which a roll back restores).
    func memoryValue(for library: UnlockedLibrary) -> DeviceMemory? {
        guard let record = library.record else { return nil }
        let old = library.memory
        var mirror = old?.keyFileMirror
        if let live = library.keyFile, live.fingerprint == record.currentFingerprint { mirror = live }
        return DeviceMemory(
            libraryID: record.libraryID, currentFingerprint: record.currentFingerprint, deviceID: library.section.deviceID,
            keyFileMirror: mirror)
    }

    /// This Mac's section into the record (inside the library, under the key
    /// in hand), then what this Mac remembers (its device ID, the current key,
    /// the mirror).
    func writeFacts(_ library: inout UnlockedLibrary, section: DeviceSection) throws {
        guard var record = library.record else { throw ExecutorRefusal.recordMissing }
        record = try record.stampingPassphraseFact(keyFile: library.keyFile).storing(section, sealedUnder: library.key)
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

    /// **Rule 3's dismissal, recorded** (the returning reminder's "don't show
    /// again" counts three): one record write, nothing else — the schedule
    /// and its words are phase 3's.
    public func recordPassphraseReminderDismissed(_ library: inout UnlockedLibrary) throws {
        guard var record = library.record else { throw ExecutorRefusal.recordMissing }
        record.reminderDismissals += 1
        record = record.stampingPassphraseFact(keyFile: library.keyFile)
        try leaves.library.writeRecord(record, with: library.key)
        library.record = record
    }

    /// The live key file — and the in-hand copy follows.
    func writeLiveKeyFile(_ file: KeyFile, _ library: inout UnlockedLibrary) throws {
        try leaves.keyFiles.writeLiveKeyFile(file)
        library.keyFile = file
    }
}
