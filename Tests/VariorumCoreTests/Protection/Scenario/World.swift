//
//  World.swift
//  VariorumCoreTests — VX-305 U4: THE SCENARIO WORLD (design §4.1, the phase
//  plan §6): two Macs and a phone, two Apple accounts and two Variorum
//  accounts, the fakes with real semantics (`Fakes.swift`), real key files and
//  wraps with test-speed KDF
//  parameters (`.relaxedForTests` floors), and stand-in library files keyed by
//  their key's fingerprint and carrying their record.
//
//  Each `SDevice` implements every executor leaf over ITS keychain, ITS
//  container, its replica of its Apple account's iCloud Keychain, its far
//  (iCloud Drive) folder and the shared server — the leaves stay dumb, every
//  decision is the executor's. A crash can be injected after any write: the
//  write lands, the process dies (session memory and the copy pause go with
//  it; the disk and the keychain stay).
//
//  THE USER is modelled by the world's `Truth`: what she knows (her current
//  passphrase and words for each library or account, and their history), so
//  the lobby can type what she would, and the promises can name what each
//  copy's day was.
//

import CryptoKit
import Foundation

@testable import VariorumCore

/// What she knows about one library or account's secrets — current, and every
/// change with its time.
struct Known: Equatable {
    var passphrase: String?
    var words: [String]?
    var timeline: [(at: Date, passphrase: String?, words: [String]?)] = []

    static func == (a: Known, b: Known) -> Bool { a.passphrase == b.passphrase && a.words == b.words }

    func at(_ date: Date) -> (passphrase: String?, words: [String]?) {
        let entry = timeline.last { $0.at <= date }
        return entry.map { ($0.passphrase, $0.words) } ?? (passphrase, words)
    }
}

/// A copy Variorum (or today's build) wrote, as the world remembers its birth.
struct CopyTruth: Equatable {
    var libraryID: String
    var fingerprint: String
    var madeAt: Date
    var madeOn: String
    /// The library's mode when it was made (Castle-era copies are promise 13's).
    var mode: ProtectionMode?
    /// Whose secrets it was made under — an account, or the library's own.
    var holder: String
    /// THE FLOOR (rule 4, her ruling at the U4 stop, 2026-10-17: "A backup
    /// always opens with the passphrase and words you had when you made it"):
    /// the pair she had for this library when it was written — the one that
    /// opens its own key file then (on a device whose locks lagged its account,
    /// the pair of its last sync — rule 12's "the one it had when it last
    /// synced"). Promise 4 holds the copy to it for as long as it exists.
    var madeWithPassphrase: String? = nil
    var madeWithWords: [String]? = nil
}

/// The ground truth the promises read.
struct Truth {
    /// Her secrets, by holder: an account id, or a local library's id.
    var known: [String: Known] = [:]
    /// Every passphrase and every set of words ever in the world — the lock
    /// oracle tries them (each lock's secret is found, never assumed).
    var allPassphrases: [String] = []
    var allWords: [[String]] = []
    /// Every copy written, by its path ("<place>:<path>").
    var copies: [String: CopyTruth] = [:]
    /// Standard copies made after the moment both homes were rolled back to
    /// (the stated limit, P-U4-5): the restored Castle state doesn't reach back
    /// over them.
    var rolledBackOver: Set<String> = []
    /// Devices whose STANDARD key file a login-password holder rewrote, with
    /// the key it was then under — rule 3: in Standard that person can rewrite
    /// anything, and no repair acts on a Standard record's word (§3.3), so
    /// promise 3's own-key wording waits for the next key change.
    var tamperedStandard: [String: Set<String>] = [:]
    /// Apple key ids whose deliberate delete never reached iCloud: made while
    /// the device's switch was off, or queued and lost with its keychain (a
    /// replaced, wiped or re-Apple-ID'd device) — §8's residue (PROVISIONAL
    /// P-U4-1: after a leave, nothing in Standard deletes them on sight).
    var deletesNotCarried: Set<String> = []
    /// Synced items (any kind — the 13p escrow's raw key among them) deleted
    /// on a device whose switch was off: the stated exception (§3.1 rule 2)
    /// holds until iCloud Keychain carries a deletion.
    var deletedWhileOff: Set<KName> = []
    /// The mode and account a device had just before a rollback of its files
    /// (Time Machine, a replayed library file): the next open taking them back
    /// from what the Mac remembers is the rollback's consequence, not a silent
    /// change (P-U4-6).
    var beforeRollback: [String: (mode: ProtectionMode?, account: String?)] = [:]
    /// Every copy retention pruned: who, under which Mac, for which library.
    var prunes: [(by: String, mac8: String, library: String, copy: CatalogCopy)] = []
    // VX-378 U4 — the bookkeeping the rewritten promises read. (The open-copy
    // road's `opens` left with rule 17 — a copy is a copy.)
    /// PROMISE 7 (rule 21, her ruling at the U4 stop): an open whose notice
    /// isn't the one the live place calls for — none when the library isn't
    /// the one this Mac last opened, one when it is, or the wrong one (its
    /// kind, its date) — found at the launch.
    var noticeMismatches: [(device: String, detail: String)] = []
    /// PROMISE 8 (rule 22): a delete after which the library in the live place
    /// opened by none of her roads — found at the write.
    var strandings: [(device: String, detail: String)] = []
    /// PROMISE 9 (rule 17): Look inside wrote something.
    var lookInsideWrites: [(device: String, detail: String)] = []
    /// PROMISE 4 (rule 4): Look inside refused a copy her current secrets reach.
    var doorRefusals: [(device: String, detail: String)] = []
    /// PROMISE 4 (rule 4's floor): a copy written that opens with none of the
    /// secrets she had for its library — found at the write.
    var madeWithNothing: [(device: String, detail: String)] = []
    /// THE COMPLETE REPLAY — the stated limit carried from P-U4-5 (her ruling
    /// 2026-10-14/15, "accept and state it"): this Mac's homes replayed
    /// together return it to that earlier state, its secrets of that day with
    /// it — by device: whose secrets, the moment returned to, the key then.
    var statedLimit: [String: (holder: String, at: Date, fingerprint: String)] = [:]
    /// PROMISE 3 (rule 15): every sync key each account has ever had.
    var accountRowKeys: [String: Set<String>] = [:]
    /// PROMISE 7: memory items a login-password holder wrote back (a replay) —
    /// by device, the library IDs they name. Rule 21's "only the app's own
    /// doors change them" binds the app; an item planted beside the remembered
    /// library changes nothing (promise 9) and is not the app's second library.
    var plantedMemories: [String: Set<String>] = [:]
    /// PROMISE 4: when a device last CREATED a library (a fresh start, no past —
    /// what it made before belongs to a library it no longer carries).
    var freshStarts: [String: Date] = [:]
    /// Each device's last library holder: its pair carries into a library Make
    /// this my library made (rule 7: "Make-this-my-library keeps your current
    /// pair").
    var lastHolder: [String: String] = [:]
    /// L6 — A LIBRARY PUT IN THE LIVE PLACE FROM OUTSIDE (her ruling at the U4
    /// stop, 2026-10-17: "we also do not need to protect them from hand copying
    /// an old library over - they have to just remember that at that point";
    /// P-VX378-U4-2 CLOSED, "someone with access to your computer can of course
    /// delete your library"): by device, the key of a library file a replay put
    /// there, or one an open said rule 21's notice for. While the live place
    /// still holds it, the promises read the copy's own day — its posture until
    /// it follows, the secrets it was made with (the floor), and, beside a key
    /// file that reaches it only through its history, no quiet road the split
    /// pair can't carry (P-VX378-U4-6).
    var liveFromOutside: [String: String] = [:]
    /// PROMISE 9 (rule 17's "you never leave Castle by opening something"): the
    /// posture at Make this my library's press — after the open it pressed on
    /// settled anything in flight.
    var makeMinePressMode: [String: ProtectionMode] = [:]
}

final class SDevice {
    let name: String
    let isPhone: Bool
    /// The Apple ID it is signed into.
    var appleAccount: String?
    /// iCloud Keychain's switch — the app can't see it (corner 46).
    var iCloudOn = true
    var online = true
    /// The Variorum session.
    var session: SessionFact = .signedOut
    var keychain = DeviceKeychain()
    var biometry = BiometryFake()
    var container = FolderFS()
    /// The Apple account whose iCloud Drive folder this Mac backs up into.
    var farFolderAccount: String?
    var timeMachine: [[String: SFile]] = []
    /// The staged file of an act's export-and-swap (on disk — it survives a crash).
    var staged: LibraryImage?
    var sessionMemory: [String: AccountKeys] = [:]
    var paused = false
    var writeCount = 0
    var crashAfterWrites: Int?
    var logLines: [String] = []
    var diagnostics: [ProtectionDiagnostic] = []
    // The app, while it runs.
    var executor: ProtectionExecutor?
    var library: UnlockedLibrary?
    var touchIDPress: TouchIDPress?
    /// What an adversary with the login password captured earlier — replayed
    /// one at a time, or both homes together (§4.1).
    var captures: [DeviceCapture] = []
    /// The last act's outcome (a Done's words).
    var lastOutcome: ActOutcome?
    /// What the last open's settle (or a re-settle at a vault reach) did with
    /// an act in flight — `.waiting` is the act named and waiting.
    var lastSettle: SettleOutcome?
    /// Hand-off folders Send Library brought here, oldest first.
    var incoming: [String] = []
    /// New secrets she chose at an act that hasn't finished (a crash): which
    /// one the locks end up under is read back once nothing is in flight.
    var pending: [(holder: String, passphrase: String?, words: [String]?)] = []

    init(name: String, isPhone: Bool) {
        self.name = name
        self.isPhone = isPhone
    }

    var slot: LibraryImage? { container.files[SPath.slot]?.library }
    var isOpen: Bool { executor != nil && library != nil }

    /// The process dies: session memory and in-process state go; disk and
    /// keychain stay.
    func die() {
        executor = nil
        library = nil
        sessionMemory.removeAll()
        paused = false
        crashAfterWrites = nil
        touchIDPress = nil
    }
}

/// One earlier moment of a device, as a login-password holder could have
/// copied it: the library file, the live key file, the memory item, the plan.
struct DeviceCapture {
    /// When it was copied (the complete replay returns the Mac to this moment).
    var at: Date
    var slot: SFile?
    var liveKeyFile: SFile?
    var memory: KItem?
    var memoryName: KName?
    var plan: SFile?
}

/// The container's names (the real ones — the catalog parses them).
enum SPath {
    static let slot = CatalogNames.libraryFilename
    static let liveKeyFile = ProtectionNames.keyFilename
    static let plan = ProtectionNames.planFilename
    static let marker = "variorum-library-lived-here"

    static func ownFolder(_ libraryID: String, _ deviceID: String) -> String {
        ProtectionNames.backupsSubpath(libraryID: libraryID, deviceID: deviceID)
    }

    static func snapshot(_ stamp: Date, _ fingerprint: String) -> String {
        "variorum-backup-\(CatalogNames.stampString(stamp))-\(StoreKeyEnvelope.shortFingerprint(fingerprint)).sqlite"
    }

    static func pair(of snapshot: String) -> String { String(snapshot.dropLast(".sqlite".count)) + ".keys.json" }
}

enum WorldRefusal: Error, Equatable {
    case noLibrary
    case cannotOpen
    case notOpen
}

final class SWorld {
    static let scope = "Variorum-test"
    static let appleA = "apple-account-1"
    static let appleB = "apple-account-2"

    var rng: SeededRandom
    var clock = Date(timeIntervalSinceReferenceDate: 790_000_000)
    var devices: [SDevice] = []
    var appleAccounts: [String: AppleAccountFake] = [:]
    /// iCloud Drive folders, by Apple account.
    var farFolders: [String: FolderFS] = [:]
    let server = ServerFake()
    var truth = Truth()
    var syncVersion = 0
    var guards = ProtectionGuards.all
    var stepLog: [String] = []
    /// A memo of passphrase derivations (the lock oracle tries many).
    var derived: [String: PassphraseKey] = [:]
    /// A memo of words derivations (BIP-39's PBKDF2 is the slow part).
    var wordsDerived: [String: WordsKey] = [:]
    /// Whose secrets a sent pair was locked under, by hand-off folder.
    var senderHolders: [String: String] = [:]
    /// Send Library's folder → the Mac that sent it.
    var senders: [String: String] = [:]
    /// Devices whose last act crashed (their next launch finishes it).
    var crashed: Set<String> = []
    /// Devices whose open at this step said rule 21's notice: what that open
    /// went on to take — the copy's posture, its roads — was said, never silent
    /// (promise 9).
    var noticedThisStep: Set<String> = []
    /// Every promise violation, with the log line it surfaced at.
    var violations: [(Violation, Int)] = []
    /// Each action kind's outcomes (the generator's coverage).
    var stats: [String: [String: Int]] = [:]
    /// The account each device's library was last seen bound to.
    var lastBinding: [String: String?] = [:]

    /// Two Macs and a phone on Apple account 1. (The world models no hardware
    /// identity: the core reads none — rule 23.)
    init(seed: UInt64 = 1) {
        rng = SeededRandom(seed: seed)
        appleAccounts[Self.appleA] = AppleAccountFake(id: Self.appleA)
        appleAccounts[Self.appleB] = AppleAccountFake(id: Self.appleB)
        farFolders[Self.appleA] = FolderFS()
        farFolders[Self.appleB] = FolderFS()
        for (name, phone) in [("macA", false), ("macB", false), ("phone", true)] {
            let device = SDevice(name: name, isPhone: phone)
            device.appleAccount = Self.appleA
            devices.append(device)
        }
    }

    func device(_ name: String) -> SDevice { devices.first { $0.name == name }! }
    var macA: SDevice { device("macA") }
    var macB: SDevice { device("macB") }
    var phone: SDevice { device("phone") }

    func farFolder(of device: SDevice) -> FolderFS? {
        guard !device.isPhone, let account = device.farFolderAccount else { return nil }
        return farFolders[account]
    }

    func tick() -> Date {
        clock += 1
        return clock
    }

    func advance(hours: Double = 1) { clock += hours * 3600 }

    // MARK: - The user's secrets

    func known(_ holder: String) -> Known { truth.known[holder] ?? Known() }

    func setKnown(_ holder: String, passphrase: String?, words: [String]?, at: Date? = nil) {
        var known = truth.known[holder] ?? Known()
        known.passphrase = passphrase
        known.words = words
        known.timeline.append((at ?? clock, passphrase, words))
        truth.known[holder] = known
        if let passphrase, !truth.allPassphrases.contains(passphrase) { truth.allPassphrases.append(passphrase) }
        if let words, !truth.allWords.contains(words) { truth.allWords.append(words) }
    }

    func newPassphrase() -> String { "passphrase-\(rng.int(100_000..<999_999))" }

    /// A secret she chose, now known to her whatever the act's fate — the
    /// candidate set the lock oracle tries; it becomes CURRENT when a lock
    /// says so (`adoptPending`).
    func choose(_ device: SDevice, holder: String, passphrase: String?, words: [String]?) {
        if let passphrase, !truth.allPassphrases.contains(passphrase) { truth.allPassphrases.append(passphrase) }
        if let words, !truth.allWords.contains(words) { truth.allWords.append(words) }
        device.pending.append((holder, passphrase, words))
    }

    /// After every step: a library that left its account (by an act, or by a
    /// crashed act's resume) keeps the account's secrets as its own.
    func syncHolders() {
        for device in devices {
            guard let slot = device.slot, let record = slot.record else { continue }
            let key = "\(device.name)|\(slot.libraryID)"
            if case .some(.some(let was)) = lastBinding[key], record.account == nil {
                // The leave's re-key locks the new key under the account's
                // secrets of that moment: they are the library's own now (a
                // resumed leave included — afterAct's rule for any road).
                let own = holder(device, account: nil, libraryID: slot.libraryID)
                var k = known(was)
                // The secrets typed at the leave's press — the account's then,
                // which a change made elsewhere since may have moved past.
                if let wrap = liveKeyFile(device)?.passphrase {
                    let candidates = [k.passphrase].compactMap { $0 } + k.timeline.compactMap(\.passphrase).reversed()
                    if let opens = candidates.first(where: { p in
                        passphraseKey(p, wrap.kdf).map { Lock.unwrap(wrap.wrapped, under: $0.key) != nil } == true
                    }) { k.passphrase = opens }
                }
                if let lock = liveKeyFile(device)?.words {
                    let candidates = [k.words].compactMap { $0 } + k.timeline.compactMap(\.words).reversed()
                    if let opens = candidates.first(where: { w in wordsKey(w).map { Lock.unwrap(lock, under: $0) != nil } == true }) {
                        k.words = opens
                    }
                }
                if truth.known[own] == nil || truth.known[own] != k {
                    setKnown(own, passphrase: k.passphrase, words: k.words)
                }
            }
            lastBinding[key] = .some(record.account)
            let current = holder(device, account: record.account, libraryID: slot.libraryID)
            if truth.known[current] == nil, record.account == nil, let previous = truth.lastHolder[device.name] {
                let k = known(previous)
                setKnown(current, passphrase: k.passphrase, words: k.words)
            }
            truth.lastHolder[device.name] = current
        }
    }

    /// After a step: a pending secret whose lock now holds — the live key
    /// file's, or the account vault's — becomes current; with nothing in
    /// flight, what's left is dropped (the act rolled back).
    func adoptPending(_ device: SDevice) {
        guard !device.pending.isEmpty else { return }
        let inFlight = device.library?.section.actInFlight != nil || device.container.files[SPath.plan] != nil
        var remaining: [(holder: String, passphrase: String?, words: [String]?)] = []
        for choice in device.pending {
            var adopted = false
            var k = known(choice.holder)
            let isAccount = server.accounts[choice.holder] != nil
            if let p = choice.passphrase, p != k.passphrase {
                var opens = false
                if isAccount, let vault = server.snapshot(choice.holder), let pk = passphraseKey(p, vault.vault.kdf) {
                    opens = vault.vault.master(passphrase: pk, words: nil) != nil
                } else if let wrap = liveKeyFile(device)?.passphrase, let pk = passphraseKey(p, wrap.kdf) {
                    opens = Lock.unwrap(wrap.wrapped, under: pk.key) != nil
                }
                if opens { k.passphrase = p; adopted = true }
            }
            if let w = choice.words, w != k.words, let wk = wordsKey(w) {
                var opens = false
                if isAccount, let vault = server.snapshot(choice.holder) {
                    opens = vault.vault.master(passphrase: nil, words: WordsKey(key: wk)) != nil
                } else if let blob = liveKeyFile(device)?.words {
                    opens = Lock.unwrap(blob, under: wk) != nil
                }
                if opens { k.words = w; adopted = true }
            }
            if adopted { setKnown(choice.holder, passphrase: k.passphrase, words: k.words) }
            if !adopted, inFlight { remaining.append(choice) }
        }
        device.pending = remaining
    }

    func newWords() -> [String] {
        let entropy = rng.bytes(16)
        return (try? RecoveryPhrase.mnemonic(fromEntropy: entropy)) ?? (try! RecoveryPhrase.generate())
    }

    /// Memoized test-speed derivation.
    func passphraseKey(_ passphrase: String, _ kdf: PassphraseKDF.Descriptor) -> PassphraseKey? {
        let memo = "\(passphrase)|\(kdf.salt.base64EncodedString())|\(kdf.memoryKiB)|\(kdf.iterations)"
        if let held = derived[memo] { return held }
        guard (try? kdf.validateFloor(PF.floor)) != nil, let key = try? PassphraseKey.derive(passphrase, kdf: kdf) else { return nil }
        derived[memo] = key
        return key
    }

    func fastKDF() -> PassphraseKDF.Descriptor {
        PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13, memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: rng.bytes(16), outputBytes: 32)
    }

    func mintKey() -> StoreKey { StoreKey(data: rng.bytes(32))! }
    func mintApple() -> AppleKeyMaterial { AppleKeyMaterial(id: rng.uuid(), key: SymmetricKey(data: rng.bytes(32))) }

    // MARK: - iCloud Keychain

    func nextSyncVersion() -> Int {
        syncVersion += 1
        return syncVersion
    }

    /// One device syncs with its Apple account: its pending changes upload
    /// (the newer version of a name survives), then everything newer comes
    /// down (a tombstone deletes, with no recovery). Nothing while its switch
    /// is off or it's signed out of iCloud.
    func syncICloud(_ device: SDevice) {
        guard device.iCloudOn, let id = device.appleAccount, let account = appleAccounts[id] else { return }
        for (name, replica) in device.keychain.synced where replica.dirty {
            if replica.version > (account.cloud[name]?.version ?? 0) {
                account.cloud[name] = AppleAccountFake.Entry(item: replica.item, version: replica.version)
            }
            if replica.item == nil { device.keychain.synced[name] = nil } else { device.keychain.synced[name]?.dirty = false }
        }
        for (name, entry) in account.cloud where entry.version > (device.keychain.synced[name]?.version ?? 0) {
            device.keychain.synced[name] = entry.item.map { DeviceKeychain.Replica(item: $0, version: entry.version, dirty: false) }
        }
    }

    /// The world settles its iCloud Keychains: every device syncs, twice (so
    /// what one uploaded reaches the others).
    func propagateAll() {
        for _ in 0..<2 { for device in devices { syncICloud(device) } }
    }

    func addSynced(_ device: SDevice, _ name: KName, _ item: KItem) {
        var item = item
        item.synchronizable = true
        device.keychain.synced[name] = DeviceKeychain.Replica(item: item, version: nextSyncVersion(), dirty: true)
    }

    /// A delete of a synchronizable item: with the switch on it reaches every
    /// device at their next sync, with no recovery; with it off it reaches
    /// only this device, and the cloud's copy comes back when sync does.
    func deleteSynced(_ device: SDevice, _ name: KName) {
        guard let item = device.keychain.synced[name]?.item else { return }
        let id = item.value.appleKey?.id
        if device.iCloudOn, device.appleAccount != nil {
            device.keychain.synced[name] = DeviceKeychain.Replica(item: nil, version: nextSyncVersion(), dirty: true)
            if let id { truth.deletesNotCarried.remove(id) }
            truth.deletedWhileOff.remove(name)
        } else {
            device.keychain.synced[name] = nil
            if let id { truth.deletesNotCarried.insert(id) }
            truth.deletedWhileOff.insert(name)
        }
    }

    /// The device's keychain goes (replaced, wiped, signed into another Apple
    /// ID): its queued deletes never reach iCloud.
    func loseQueuedDeletes(_ device: SDevice) {
        for (name, replica) in device.keychain.synced where replica.dirty && replica.item == nil {
            // Any lost delete: the cloud's copy comes back here (P-U4-1's class).
            truth.deletedWhileOff.insert(name)
            if let id = ProtectionNames.parseAppleKeyAccount(name.account, scope: Self.scope) {
                truth.deletesNotCarried.insert(id)
            }
        }
    }

    // MARK: - Leaves

    func leaves(_ device: SDevice) -> ExecutorLeaves {
        let leaf = DeviceLeaves(world: self, device: device)
        return ExecutorLeaves(
            custody: leaf, syncKeys: leaf, apple: leaf, vault: leaf, library: leaf, keyFiles: leaf,
            memory: leaf, plans: leaf, backups: leaf, clock: leaf, ids: leaf, biometry: leaf, diagnostics: leaf)
    }

    func newExecutor(_ device: SDevice, libraryID: String) -> ProtectionExecutor {
        ProtectionExecutor(
            leaves: leaves(device),
            configuration: ExecutorConfiguration(
                scope: Self.scope, libraryID: libraryID, deviceName: device.name, floor: PF.floor,
                session: device.session),
            guards: guards)
    }

    // MARK: - Reading a device

    /// Every catalog entry this device can list (its container, its far folder).
    func catalog(_ device: SDevice) -> Catalog {
        var entries = device.container.catalogEntries(place: .container)
        if let far = farFolder(of: device) { entries += far.catalogEntries(place: .farFolder) }
        return Catalog.build(entries)
    }

    func liveKeyFile(_ device: SDevice) -> KeyFile? { device.container.files[SPath.liveKeyFile]?.keyFile }

    func readableAppleKeys(_ device: SDevice) -> [String: AppleKeyMaterial] {
        var keys: [String: AppleKeyMaterial] = [:]
        for (name, replica) in device.keychain.synced where name.service == ProtectionNames.appleKeyService {
            guard let item = replica.item, let id = ProtectionNames.parseAppleKeyAccount(name.account, scope: Self.scope),
                  let key = item.value.appleKey else { continue }
            keys[id] = key
        }
        return keys
    }

    /// A Touch ID read is a press: usable biometry and the enrollment the item
    /// was made under.
    func pressRead(_ device: SDevice, _ item: KItem) -> KValue? {
        guard item.touchID else { return item.value }
        guard device.biometry.usable, item.enrollment == device.biometry.generation else { return nil }
        return item.value
    }

    // MARK: - The lobby — before unlock, roads only (§3.3)

    /// Whose secrets a library's locks are under: its account's, else its
    /// own on this device (two Macs holding one library each keep their own).
    func holder(_ device: SDevice, account: String?, libraryID: String) -> String {
        account ?? "\(libraryID)@\(device.name)"
    }

    /// L6: the live place still holds the library put there from outside.
    func fromOutside(_ device: SDevice) -> Bool {
        guard let mark = truth.liveFromOutside[device.name] else { return false }
        if device.slot?.fingerprint == mark { return true }
        truth.liveFromOutside[device.name] = nil
        return false
    }

    /// L6's split pair: the library put in the live place from outside has no
    /// key file of its own beside it — the one there is another key's (reaching
    /// it through its history, or another library's), or none — and no home the
    /// offer reads held its own (P-VX378-U4-6).
    func splitPair(_ device: SDevice) -> Bool {
        guard fromOutside(device), let slot = device.slot else { return false }
        return liveKeyFile(device)?.fingerprint != slot.fingerprint
    }

    func slotHolder(_ device: SDevice) -> String? {
        guard let slot = device.slot else { return nil }
        return holder(device, account: slot.record?.account ?? (slot.record == nil ? slot.rowsOwner : nil), libraryID: slot.libraryID)
    }

    /// The secrets she would type for the library in the slot.
    func typedFor(_ device: SDevice) -> TypedSecrets {
        guard let holder = slotHolder(device) else { return .none }
        let known = known(holder)
        var typed = TypedSecrets(passphrase: known.passphrase, words: known.words)
        // An act in flight resumes with the secrets typed at its press (a plan
        // never holds one): she types again what she chose seconds before.
        if device.container.files[SPath.plan] != nil {
            if let chosen = device.pending.last {
                typed = TypedSecrets(passphrase: chosen.passphrase ?? typed.passphrase, words: chosen.words ?? typed.words)
            }
            // She types the passphrase the press took: the one that opens what
            // the plan's descriptor locks — the vault's, or her library's (a
            // change made elsewhere since the press is not yet hers here).
            let accountTimeline = device.session.accountID.map { self.known($0).timeline.compactMap(\.passphrase) } ?? []
            // (…and any she ever chose — a landing's pair's, made her own.)
            let candidates = [typed.passphrase].compactMap { $0 } + known.timeline.compactMap(\.passphrase).reversed()
                + accountTimeline.reversed() + truth.allPassphrases.reversed()
            let planKDF: PassphraseKDF.Descriptor? = {
                guard case .plan(let sealed)? = device.container.files[SPath.plan],
                      let plan = try? ProtectionCoding.decoder().decode(ProtectionPlan.self, from: sealed.payload) else { return nil }
                return plan.parameters?.passphraseKDF
            }()
            let vault = device.session.accountID.flatMap { server.snapshot($0) }
            // The locks under the plan's own descriptor this Mac holds — the
            // live key file's, or (her Time Machine restore took the live one
            // back past the press) the memory's mirror of it: the press's
            // passphrase is the one that opens them (the closer's soak, seed 5
            // sequence 626).
            let planLocks: [StoreKeyEnvelope.PassphraseWrap] = {
                guard let kdf = planKDF else { return [] }
                var files = [liveKeyFile(device)].compactMap { $0 }
                if let libraryID = device.slot?.libraryID,
                   case .memory(let sealed)? = device.keychain.local[KName.memory(Self.scope, libraryID)]?.value,
                   let memory = try? ProtectionCoding.decoder().decode(DeviceMemory.self, from: sealed.payload),
                   let mirror = memory.keyFileMirror {
                    files.append(mirror)
                }
                return files.compactMap(\.passphrase).filter { $0.kdf == kdf }
            }()
            if let kdf = planKDF, let vault, vault.vault.kdf == kdf,
               let opens = candidates.first(where: { p in
                   passphraseKey(p, kdf).map { vault.vault.master(passphrase: $0, words: nil) != nil } == true
               }) {
                typed = TypedSecrets(passphrase: opens, words: typed.words)
            } else if let kdf = planKDF, !planLocks.isEmpty,
                      let opens = candidates.first(where: { p in
                          passphraseKey(p, kdf).map { pk in planLocks.contains { Lock.unwrap($0.wrapped, under: pk.key) != nil } } == true
                      }) {
                typed = TypedSecrets(passphrase: opens, words: typed.words)
            } else if let wrap = liveKeyFile(device)?.passphrase,
                      let opens = candidates.first(where: { p in
                          passphraseKey(p, wrap.kdf).map { Lock.unwrap(wrap.wrapped, under: $0.key) != nil } == true
                      }) {
                typed = TypedSecrets(passphrase: opens, words: typed.words)
            }
        }
        return typed
    }

    /// Every road this device has for the slot, walked as she would: the
    /// custody items enumerated (a Touch ID item through a press), today's
    /// items, the Apple wraps whose key reads here, the typed secrets on every
    /// key file the device holds, the vault road behind them — each candidate
    /// expanded through the history. Returns the key that
    /// opens the slot, and every other key reached on the way.
    func walkLobby(_ device: SDevice, typed: TypedSecrets) async -> (key: StoreKey, also: [StoreKey])? {
        guard let slot = device.slot else { return nil }
        var candidates: [StoreKey] = []
        func add(_ key: StoreKey?) { if let key, !candidates.contains(key) { candidates.append(key) } }
        // Custody, the silent ones first.
        for name in device.keychain.names(service: ProtectionNames.custodyService) {
            guard let item = device.keychain.item(name), !item.touchID else { continue }
            add(item.value.libraryKey)
        }
        for name in device.keychain.names(service: ProtectionNames.custodyService) {
            guard let item = device.keychain.item(name), item.touchID else { continue }
            if let value = pressRead(device, item) {
                add(value.libraryKey)
            } else if let transient = device.biometry.transient {
                device.touchIDPress = .transient(transient)
            } else if device.biometry.enrolled {
                device.touchIDPress = .failedOnExistingItem
            }
        }
        // Every key file this device holds beside the slot, and the catalog's —
        // and this Mac's keychain copy (rule 1's third home: the sealed copy in
        // what this Mac remembers is a key file the lobby can open with her
        // secret — VX-378 U4 resumption, rule 21's offer).
        let catalog = catalog(device)
        let files = catalog.keyFiles.compactMap(\.document) + mirrors(device)
        let apple = readableAppleKeys(device)
        var secrets: [ProtectionSecret] = []
        if let passphrase = typed.passphrase { secrets.append(.passphrase(passphrase)) }
        if let newPassphrase = typed.newPassphrase { secrets.append(.passphrase(newPassphrase)) }
        if let words = typed.words { secrets.append(.words(words)) }
        var masters: [SymmetricKey] = []
        if device.online, let account = device.session.accountID, let vault = server.snapshot(account) {
            if let passphrase = typed.passphrase, let key = passphraseKey(passphrase, vault.vault.kdf),
               let master = vault.vault.master(passphrase: key, words: nil) {
                masters.append(master)
            }
            if let words = typed.words, let wk = try? WordsKey.derive(words),
               let master = vault.vault.master(passphrase: nil, words: wk) {
                masters.append(master)
            }
        }
        for file in files {
            if let wrap = file.apple, let key = apple[wrap.keyID] { add(try? file.open(apple: key)) }
            for secret in secrets { add(try? file.open(secret, floor: PF.floor)) }
            for master in masters { add(try? file.open(master: master)) }
        }
        // Expansion: every file's history under a key in hand.
        var index = 0
        while index < candidates.count {
            let key = candidates[index]
            index += 1
            for file in files {
                if file.fingerprint == PF.fp(key) {
                    for older in (try? file.historyKeys(currentKey: key)) ?? [] { add(older.key) }
                }
            }
        }
        guard let opener = candidates.first(where: { PF.fp($0) == slot.fingerprint }) else { return nil }
        return (opener, candidates.filter { $0 != opener })
    }

    // MARK: - Launch: the lobby, unlock, settle, the migration, the repairs

    /// The app opens on `device`: the lobby walks its roads, the executor
    /// unlocks with every key reached, settles any act in flight, reads the
    /// vault fresh, and runs the repairs `assess` owes.
    @discardableResult
    func launch(_ device: SDevice, typed: TypedSecrets? = nil) async throws -> UnlockedLibrary {
        if device.isOpen, let library = device.library { return library }
        guard let slot = device.slot else { throw WorldRefusal.noLibrary }
        let asked = typed
        var typed = typed ?? typedFor(device)
        device.touchIDPress = nil
        var lobby = await walkLobby(device, typed: typed)
        if lobby == nil, asked == nil, let holder = slotHolder(device) {
            // THE FLOOR (her ruling at the U4 stop, 2026-10-17 — rule 12: a
            // device that lagged "types a secret once to catch up, today's or
            // the one it had when it last synced"): today's opening nothing,
            // she types the pair she had before, newest first.
            for entry in known(holder).timeline.reversed()
            where entry.passphrase != typed.passphrase || entry.words != typed.words {
                let older = TypedSecrets(passphrase: entry.passphrase, words: entry.words)
                if let found = await walkLobby(device, typed: older) {
                    lobby = found
                    typed = older
                    stepLog.append("  \(device.name): today's secrets open nothing here — she types the pair of its last sync (rule 12)")
                    break
                }
            }
        }
        guard let (key, also) = lobby else { throw WorldRefusal.cannotOpen }
        let executor = newExecutor(device, libraryID: slot.record?.libraryID ?? slot.libraryID)
        device.executor = executor
        // PROMISE 7 (rule 21, her ruling at the U4 stop): the world's own reading
        // of whether the library in the live place is the one this Mac last
        // opened — the open must go on and say exactly that notice (its kind,
        // its date), writing nothing itself.
        let expected = expectedNotice(device, key: key, also: also, executor: executor)
        let writesBefore = device.writeCount
        var library = try executor.unlock(with: key, alsoInHand: also)
        if device.writeCount != writesBefore {
            truth.noticeMismatches.append((device.name, "the open itself wrote \(device.writeCount - writesBefore) time(s)"))
        }
        if library.notice?.kind != expected {
            truth.noticeMismatches.append((device.name,
                "the open said \(library.notice.map { "\($0.kind)" } ?? "nothing"); the live place calls for \(expected.map { "\($0)" } ?? "nothing")"))
        }
        if library.notice != nil {
            noticedThisStep.insert(device.name)
            truth.liveFromOutside[device.name] = slot.fingerprint
        }
        device.library = library
        device.lastSettle = nil
        do {
            device.lastSettle = try await executor.settle(&library, typed: typed)
        } catch let crash as SimulatedCrash {
            throw crash
        } catch {
            // The lobby opens the library all the same; the act stays owed
            // (promise 6 then says whether it may).
            stepLog.append("  \(device.name): the act in flight couldn't settle now (\(error))")
        }
        device.library = library
        if let account = library.record?.account, device.session.accountID == account, device.online {
            _ = try? await executor.readVault(accountID: account)
            // The lobby's Always-ask duty (pre-13x §3.3, phase 2's): with no
            // sync-keys item, the account's keys come from the vault through
            // the secret typed at the unlock, held for the session.
            let leaf = DeviceLeaves(world: self, device: device)
            let held = [ProtectionNames.CustodyClass.touchid, .silent].contains { (try? leaf.readSyncKeys(accountID: account, itemClass: $0)) != nil }
            // (VX-378 U4, found by discovery seed 21: only for a library that
            // already follows the vault's current key and posture — a device
            // that lagged owes its follow, which types its secret and holds the
            // keys; until then it holds no key for rows written since — rule 15.)
            if !held, device.sessionMemory[account] == nil, let vault = server.snapshot(account),
               library.record?.accountRowKeyID == vault.rowKeyID, library.record?.mode == vault.mode {
                var master: SymmetricKey?
                if let p = typed.passphrase, let pk = passphraseKey(p, vault.vault.kdf) { master = vault.vault.master(passphrase: pk, words: nil) }
                if master == nil, let w = typed.words, let wk = wordsKey(w) { master = vault.vault.master(passphrase: nil, words: WordsKey(key: wk)) }
                if let master { device.sessionMemory[account] = try? vault.vault.keys(master: master) }
            }
        }
        try await runRepairs(device)
        return device.library!
    }

    // (THE NEXT VAULT REACH — the world's re-settle of an act waiting for its
    // account's vault — left with VX-378 U4: no act waits on a vault since U2;
    // one that can't reach it before its swap rolls back, and the next open
    // settles anything left — promise 6, strict.)

    /// `assess`'s repairs, run by the executor.
    func runRepairs(_ device: SDevice) async throws {
        guard let executor = device.executor, var library = device.library else { return }
        for _ in 0..<3 {
            let assessment = assess(facts(device), guards: guards)
            guard !assessment.repairs.isEmpty else { break }
            let report = try executor.runRepairs(assessment.repairs, on: &library)
            device.library = library
            if report.done.isEmpty { break }
        }
    }

    /// The device locks (or quits): the app's in-memory state goes.
    func lock(_ device: SDevice) {
        device.executor = nil
        device.library = nil
        device.sessionMemory.removeAll()
        device.touchIDPress = nil
        // The copy pause is the process's too (the next open's settle pauses
        // again while an act waits) — a replaced Mac's new process never
        // inherited it (the closer's soak, seed 8 sequence 866).
        device.paused = false
    }

    // MARK: - assess's facts for a device

    func facts(_ device: SDevice) -> ProtectionFacts {
        let catalog = catalog(device)
        let leaf = DeviceLeaves(world: self, device: device)
        let custody = (try? leaf.custodyItems()) ?? []
        let syncKeys = (try? leaf.syncKeyItems()) ?? []
        let apple = AppleKeyFacts(readable: Set(readableAppleKeys(device).keys))
        var unlocked: UnlockedFacts?
        if let library = device.library, let record = library.record {
            unlocked = UnlockedFacts(
                record: record, thisMac: library.section, memory: library.memory,
                currentFingerprint: library.fingerprint,
                liveKeyFileID: device.container.files[SPath.liveKeyFile] == nil ? nil
                    : Catalog.id(place: .container, folders: [], name: SPath.liveKeyFile))
        }
        let sessionAccount = device.session.accountID
        let vault = sessionAccount.flatMap { device.executor?.freshVaults[$0]?.reading }
        return ProtectionFacts(
            scope: Self.scope, storeFile: device.slot == nil ? .absent : .present,
            containerMarker: device.container.files[SPath.marker] != nil, unlocked: unlocked,
            slotFingerprintHint: liveKeyFile(device)?.fingerprint,
            rememberedLibraryIDs: (try? leaf.rememberedLibraryIDs()) ?? [],
            rememberedKeyFileCopies: Set(mirrors(device).map(\.fingerprint)), custody: custody,
            syncKeys: syncKeys, appleKeys: apple, biometry: device.biometry.facts, touchIDPress: device.touchIDPress,
            session: device.session, vault: vault, catalog: catalog, now: clock)
    }

    func assessed(_ device: SDevice) -> Assessment { assess(facts(device), guards: guards) }

}

// MARK: - The leaves: one device's view of the world

final class DeviceLeaves: CustodyLeaf, SyncKeysLeaf, AppleKeysLeaf, VaultLeaf, LibraryFileLeaf,
    KeyFileStoreLeaf, MemoryStoreLeaf, PlanStoreLeaf, BackupsLeaf, ClockLeaf, IDsLeaf, BiometryLeaf, DiagnosticsLeaf
{
    unowned let world: SWorld
    unowned let device: SDevice
    var scope: String { SWorld.scope }

    init(world: SWorld, device: SDevice) {
        self.world = world
        self.device = device
    }

    func wrote(_ what: String) throws {
        device.writeCount += 1
        world.stepLog.append("  \(device.name) ✎ \(what)")
        if let crash = device.crashAfterWrites {
            if crash <= 1 {
                device.crashAfterWrites = nil
                throw SimulatedCrash()
            }
            device.crashAfterWrites = crash - 1
        }
    }

    // MARK: Custody

    func custodyItems() throws -> [CustodyItemFact] {
        device.keychain.names(service: ProtectionNames.custodyService).compactMap {
            ProtectionNames.parseCustodyAccount($0.account, scope: scope).map { CustodyItemFact(fingerprint: $0.fingerprint, itemClass: $0.class) }
        }
    }

    func readCustody(fingerprint: String, itemClass: ProtectionNames.CustodyClass) throws -> StoreKey? {
        guard let item = device.keychain.local[KName.custody(scope, fingerprint, itemClass)] else { return nil }
        return world.pressRead(device, item)?.libraryKey
    }

    func writeCustody(_ key: StoreKey, itemClass: ProtectionNames.CustodyClass) throws {
        device.keychain.local[KName.custody(scope, PF.fp(key), itemClass)] = KItem(
            value: .key(key), touchID: itemClass == .touchid, enrollment: device.biometry.generation)
        try wrote("custody+ \(itemClass.rawValue) \(f8(key))")
    }

    func deleteCustody(fingerprint: String, itemClass: ProtectionNames.CustodyClass) throws {
        try world.deleting(device, "custody- \(itemClass.rawValue) \(f8(fingerprint))") {
            device.keychain.local[KName.custody(scope, fingerprint, itemClass)] = nil
        }
        try wrote("custody- \(itemClass.rawValue) \(f8(fingerprint))")
    }

    // MARK: Sync keys

    func syncKeyItems() throws -> [SyncKeysItemFact] {
        device.keychain.names(service: ProtectionNames.syncKeysService).compactMap {
            ProtectionNames.parseSyncKeysAccount($0.account, scope: scope).map {
                SyncKeysItemFact(accountID: $0.accountID, itemClass: $0.class)
            }
        }
    }

    func readSyncKeys(accountID: String, itemClass: ProtectionNames.CustodyClass) throws -> AccountKeys? {
        guard let item = device.keychain.local[KName.syncKeys(scope, accountID, itemClass)] else { return nil }
        return world.pressRead(device, item)?.material
    }

    func writeSyncKeys(_ material: AccountKeys, accountID: String, itemClass: ProtectionNames.CustodyClass) throws {
        device.keychain.local[KName.syncKeys(scope, accountID, itemClass)] = KItem(
            value: .syncKeys(material), touchID: itemClass == .touchid, enrollment: device.biometry.generation)
        try wrote("sync+ \(itemClass.rawValue)")
    }

    func deleteSyncKeys(accountID: String, itemClass: ProtectionNames.CustodyClass) throws {
        try world.deleting(device, "sync- \(itemClass.rawValue)") {
            device.keychain.local[KName.syncKeys(scope, accountID, itemClass)] = nil
        }
        try wrote("sync- \(itemClass.rawValue)")
    }

    func holdInSession(_ material: AccountKeys?, accountID: String) { device.sessionMemory[accountID] = material }
    func sessionSyncKeys(accountID: String) -> AccountKeys? { device.sessionMemory[accountID] }

    // MARK: Apple keys

    func readableAppleKeyIDs() throws -> Set<String> { Set(world.readableAppleKeys(device).keys) }
    func readAppleKey(id: String) throws -> AppleKeyMaterial? { world.readableAppleKeys(device)[id] }

    func addAppleKey(_ key: AppleKeyMaterial) throws {
        world.addSynced(device, KName.apple(scope, key.id), KItem(value: .apple(id: key.id, bytes: PF.bytes(key.key))))
        try wrote("apple+ \(key.id.prefix(8))")
    }

    func deleteAppleKey(id: String) throws {
        guard device.keychain.synced[KName.apple(scope, id)]?.item != nil else {
            // A delete that can't reach the key — it lives in an Apple account
            // this device isn't signed into now (§3.1 rule 2's last exception,
            // until this Mac comes back to it): P-U4-1's class, its delete
            // never carried (the closer's soak, seed 6 sequence 485).
            world.truth.deletesNotCarried.insert(id)
            return
        }
        try world.deleting(device, "apple- \(id.prefix(8))") { world.deleteSynced(device, KName.apple(scope, id)) }
        try wrote("apple- \(id.prefix(8))")
    }

    // MARK: The vault

    /// The server answers only a session signed into the account (row-level
    /// security), and only online.
    func reach(_ accountID: String) throws {
        guard device.online else { throw VaultRefusal.unreachable }
        guard device.session.accountID == accountID else { throw VaultRefusal.notSignedIn }
    }

    func fetchVault(accountID: String) async throws -> VaultSnapshot? {
        try reach(accountID)
        return world.server.snapshot(accountID)
    }

    func createVault(_ vault: AccountVault, accountID: String, device name: String) async throws -> VaultSnapshot {
        try reach(accountID)
        var named = vault
        named.updatedByDevice = name
        let snapshot = try world.server.create(named, accountID: accountID)
        try wrote("vault create")
        return snapshot
    }

    func updateVault(
        _ vault: AccountVault, accountID: String, expectedRevision: Int, proofMaster: SymmetricKey, device name: String
    ) async throws -> VaultSnapshot {
        try reach(accountID)
        var named = vault
        named.updatedByDevice = name
        let snapshot = try world.server.update(named, accountID: accountID, expectedRevision: expectedRevision, proofMaster: proofMaster)
        try wrote("vault \(ServerFake.describe(snapshot.vault))")
        return snapshot
    }

    // MARK: The library file

    var slot: LibraryImage? {
        get { device.container.files[SPath.slot]?.library }
        set { device.container.files[SPath.slot] = newValue.map { .library($0) } }
    }

    func libraryOpens(with key: StoreKey) throws -> Bool { slot?.fingerprint == PF.fp(key) }

    func readRecord(with key: StoreKey) throws -> ProtectionRecord? {
        guard let slot, slot.fingerprint == PF.fp(key) else { throw ExecutorRefusal.keyDoesNotOpenLibrary }
        return slot.record
    }

    func writeRecord(_ record: ProtectionRecord, with key: StoreKey) throws {
        guard slot?.fingerprint == PF.fp(key) else { throw ExecutorRefusal.keyDoesNotOpenLibrary }
        slot?.record = record
        try wrote("record \(f8(key))")
    }

    func stageReencryption(from key: StoreKey, to newKey: StoreKey) throws {
        guard var image = slot, image.fingerprint == PF.fp(key) else { throw ExecutorRefusal.keyDoesNotOpenLibrary }
        image.fingerprint = PF.fp(newKey)
        device.staged = image
        try wrote("stage \(f8(newKey))")
    }

    /// A copy by its catalog id ("<place>:<path>"), or a hand-off folder's.
    func resolve(_ id: String) -> (fs: FolderFS, path: String)? {
        if id.hasPrefix("container:") { return (device.container, String(id.dropFirst("container:".count))) }
        if id.hasPrefix("farFolder:"), let far = world.farFolder(of: device) { return (far, String(id.dropFirst("farFolder:".count))) }
        return nil
    }

    func stageCopy(copyID: String, opener: StoreKey, to newKey: StoreKey) throws {
        guard let (fs, path) = resolve(copyID), var image = fs.files[path]?.library, image.fingerprint == PF.fp(opener) else {
            throw ExecutorRefusal.keyDoesNotOpenLibrary
        }
        image.fingerprint = PF.fp(newKey)
        device.staged = image
        try wrote("stage-copy \(f8(newKey))")
    }

    func copyOpens(copyID: String, with key: StoreKey) throws -> Bool {
        guard let (fs, path) = resolve(copyID) else { return false }
        return fs.files[path]?.library?.fingerprint == PF.fp(key)
    }

    func stagedFingerprint() throws -> String? { device.staged?.fingerprint }

    func writeStagedRecord(_ record: ProtectionRecord, with newKey: StoreKey) throws {
        guard device.staged?.fingerprint == PF.fp(newKey) else { throw ExecutorRefusal.keyDoesNotOpenLibrary }
        device.staged?.record = record
        device.staged?.libraryID = record.libraryID
        try wrote("staged-record \(f8(newKey))")
    }

    func swapStaged(setAside: Bool, asideKeyFile: KeyFile?) throws {
        guard let staged = device.staged else { throw ExecutorRefusal.nothingToDo }
        if setAside, let outgoing = slot {
            // The library she had goes to her older libraries, WITH its own key
            // file — the one the executor names (the live place may already
            // hold the incoming library's), else every one the slot holds for
            // it (LibraryAsideCopies' shape).
            let at = world.tick()
            let folder = "\(CatalogNames.previousLibrariesFolderName)/\(CatalogNames.stampString(at))"
            device.container.files["\(folder)/\(SPath.slot)"] = .library(outgoing)
            var aside = CopyTruth(
                libraryID: outgoing.libraryID, fingerprint: outgoing.fingerprint, madeAt: at, madeOn: device.name,
                mode: outgoing.record?.mode,
                holder: world.holder(device, account: outgoing.record?.account, libraryID: outgoing.libraryID))
            if let asideKeyFile {
                device.container.files["\(folder)/\(SPath.liveKeyFile)"] = .keyFile(asideKeyFile)
            } else {
                for path in device.container.files.keys where !path.contains("/") {
                    guard let document = device.container.files[path]?.keyFile, document.libraryID == outgoing.libraryID else { continue }
                    device.container.files["\(folder)/\(path)"] = .keyFile(document)
                }
            }
            world.recordMadeWith(&aside, id: "container:\(folder)/\(SPath.slot)", on: device,
                                 keyFile: device.container.files["\(folder)/\(SPath.liveKeyFile)"]?.keyFile)
            world.truth.copies["container:\(folder)/\(SPath.slot)"] = aside
        }
        slot = staged
        device.staged = nil
        try wrote("swap \(f8(staged.fingerprint))")
    }

    func discardStaged() throws {
        guard device.staged != nil else { return }
        device.staged = nil
        try wrote("discard-staged")
    }

    func createLibrary(with key: StoreKey, record: ProtectionRecord) throws {
        guard slot == nil else { throw ExecutorRefusal.nothingToDo }
        slot = LibraryImage(libraryID: record.libraryID, fingerprint: PF.fp(key), record: record, writing: 1)
        device.container.files[SPath.marker] = .marker
        try wrote("create \(f8(key))")
    }

    func exportPlaintext(with key: StoreKey, to destination: String) throws {
        guard let slot, slot.fingerprint == PF.fp(key) else { throw ExecutorRefusal.keyDoesNotOpenLibrary }
        device.container.files["Exports/\(destination)/variorum-plain.sqlite"] = .plaintext(libraryID: slot.libraryID, writing: slot.writing)
        try wrote("export")
    }

    // MARK: Key files

    func readLiveKeyFile() throws -> KeyFile? { device.container.files[SPath.liveKeyFile]?.keyFile }

    func writeLiveKeyFile(_ file: KeyFile) throws {
        // The live key file REPLACED is a delete of the one it overwrites.
        try world.deleting(device, "keyfile \(f8(file.fingerprint))") {
            device.container.files[SPath.liveKeyFile] = .keyFile(file)
        }
        try wrote("keyfile \(f8(file.fingerprint))")
    }


    // MARK: Memory, plans

    func rememberedLibraryIDs() throws -> Set<String> {
        Set(device.keychain.names(service: ProtectionNames.memoryService).compactMap {
            ProtectionNames.parseMemoryAccount($0.account, scope: scope)
        })
    }

    func deleteMemory(libraryID: String) throws {
        guard device.keychain.local[KName.memory(scope, libraryID)] != nil else { return }
        try world.deleting(device, "memory- \(libraryID.prefix(8))") { device.keychain.local[KName.memory(scope, libraryID)] = nil }
        try wrote("memory- \(libraryID.prefix(8))")
    }

    func readMemory(libraryID: String) throws -> Sealed<DeviceMemory>? {
        if case .memory(let sealed)? = device.keychain.local[KName.memory(scope, libraryID)]?.value { return sealed }
        return nil
    }

    func writeMemory(_ memory: Sealed<DeviceMemory>, libraryID: String) throws {
        device.keychain.local[KName.memory(scope, libraryID)] = KItem(value: .memory(memory))
        try wrote("memory \(f8(memory.sealedUnder))")
    }

    func readPlan() throws -> Sealed<ProtectionPlan>? {
        if case .plan(let sealed)? = device.container.files[SPath.plan] { return sealed }
        return nil
    }

    func writePlan(_ plan: Sealed<ProtectionPlan>) throws {
        device.container.files[SPath.plan] = .plan(plan)
        try wrote("plan")
    }

    func deletePlan() throws {
        guard device.container.files[SPath.plan] != nil else { return }
        device.container.files[SPath.plan] = nil
        try wrote("plan-")
    }

    // MARK: Backups

    func pauseCopies() { device.paused = true }
    func resumeCopies() { device.paused = false }

    func takeBackupPair(with key: StoreKey, keyFile: KeyFile, deviceID: String) throws {
        guard !device.paused else { throw ExecutorRefusal.nothingToDo }
        guard let slot, slot.fingerprint == PF.fp(key), keyFile.fingerprint == PF.fp(key) else {
            throw ExecutorRefusal.keyDoesNotOpenLibrary
        }
        world.writePair(device, image: slot, keyFile: keyFile, deviceID: deviceID)
        try wrote("backup \(f8(key))")
    }

    func writeSendPair(with key: StoreKey, keyFile: KeyFile, to destination: String) throws {
        guard !device.paused else { throw ExecutorRefusal.nothingToDo }
        guard let slot, slot.fingerprint == PF.fp(key) else { throw ExecutorRefusal.keyDoesNotOpenLibrary }
        device.container.files["\(destination)/\(SPath.slot)"] = .library(slot)
        device.container.files["\(destination)/\(SPath.liveKeyFile)"] = .keyFile(keyFile)
        try wrote("send \(f8(key))")
    }

    func deleteCopies(ids: [String]) throws {
        for id in ids {
            guard let (fs, path) = resolve(id) else { continue }
            fs.files[path] = nil
            fs.files[SPath.pair(of: path)] = nil
            world.truth.copies["\(id)"] = nil
        }
        try wrote("copies- \(ids.count)")
    }

    // MARK: Clock, IDs, biometry, diagnostics

    func now() -> Date { world.tick() }
    func mintID() -> String { world.rng.uuid() }
    func mintLibraryKey() -> StoreKey { world.mintKey() }
    func mintAppleKey() -> AppleKeyMaterial { world.mintApple() }
    func mintSymmetricKey() -> SymmetricKey { SymmetricKey(data: world.rng.bytes(32)) }
    func mintPassphraseKDF() -> PassphraseKDF.Descriptor { world.fastKDF() }
    func mintWords() -> [String] { world.newWords() }
    func biometry() -> BiometryFacts { device.biometry.facts }
    func log(_ line: String) { device.logLines.append(line) }
    func report(_ entry: ProtectionDiagnostic) { device.diagnostics.append(entry) }
}

extension SWorld {
    /// A backup pair on `device`: the snapshot and its frozen key file, in this
    /// Mac's `Backups/<library8>/<mac8>/` — in the container, and in its far
    /// folder when it has one. The world remembers each copy's birth.
    func writePair(_ device: SDevice, image: LibraryImage, keyFile: KeyFile, deviceID: String) {
        let at = tick()
        let folder = SPath.ownFolder(image.libraryID, deviceID)
        let name = SPath.snapshot(at, image.fingerprint)
        var places: [(String, FolderFS)] = [("container", device.container)]
        if let far = farFolder(of: device) { places.append(("farFolder", far)) }
        for (place, fs) in places {
            fs.files["\(folder)/\(name)"] = .library(image)
            fs.files["\(folder)/\(SPath.pair(of: name))"] = .keyFile(keyFile)
            let copyHolder = holder(device, account: image.record?.account ?? (image.record == nil ? image.rowsOwner : nil), libraryID: image.libraryID)
            var copy = CopyTruth(
                libraryID: image.libraryID, fingerprint: image.fingerprint, madeAt: at, madeOn: device.name,
                mode: image.record?.mode, holder: copyHolder)
            recordMadeWith(&copy, id: "\(place):\(folder)/\(name)", on: device, keyFile: keyFile)
            truth.copies["\(place):\(folder)/\(name)"] = copy
        }
    }

    /// THE FLOOR at the write (rule 4: "A backup always opens with the
    /// passphrase and words you had when you made it"): the pair she had for
    /// this library — a secret chosen at the act now running first, then her
    /// current pair for the copy's holder (or for this device's last holder —
    /// Make this my library keeps the pair, rule 7), then each pair she had
    /// before, newest first (a device whose locks lagged its account: the pair
    /// of its last sync, rule 12) — the first whose passphrase or words open
    /// the copy's own key file, typed. None: a copy written that her secrets
    /// for it never opened.
    func recordMadeWith(_ copy: inout CopyTruth, id: String, on device: SDevice, keyFile: KeyFile?) {
        guard let keyFile, keyFile.fingerprint == copy.fingerprint else { return }
        // L3 (rule 3): a login-password holder rewrote this Standard key's file
        // (a lock dropped, a lock planted) — the copy carries what they left.
        if truth.tamperedStandard[device.name]?.contains(copy.fingerprint) == true { return }
        var holders = [copy.holder]
        if let last = truth.lastHolder[device.name], !holders.contains(last) { holders.append(last) }
        if let account = device.session.accountID, !holders.contains(account) { holders.append(account) }
        var pairs: [(String?, [String]?)] = device.pending.reversed().map { ($0.passphrase, $0.words) }
        for holder in holders {
            let k = known(holder)
            pairs.append((k.passphrase, k.words))
            pairs += k.timeline.reversed().map { ($0.passphrase, $0.words) }
        }
        for (passphrase, words) in pairs {
            var seeds = Seeds()
            seeds.passphrases = [passphrase].compactMap { $0 }
            seeds.words = [words].compactMap { $0 }
            if reach(seeds, files: [keyFile])[copy.fingerprint] != nil {
                copy.madeWithPassphrase = passphrase
                copy.madeWithWords = words
                return
            }
        }
        truth.madeWithNothing.append((device.name, "the copy \(id) (\(copy.fingerprint.prefix(8))) opens with none of the secrets she had for it (rule 4)"))
    }
}

// MARK: - VX-378 U4: the oracles the rewritten promises read

extension SWorld {
    /// PROMISE 7's oracle (rule 21, her ruling at the U4 stop): the notice the
    /// live place calls for, read from the device itself — what the memory item
    /// for the slot's library NAMES (its payload, as the item states it) against
    /// the library file: another key → an older copy (dated by the library's
    /// record), unless this Mac's own act in flight moves between exactly those
    /// two keys, or the library moved on past what is remembered (its own key
    /// file's history carries the remembered key — PROVISIONAL P-VX378-U4-5);
    /// nothing remembered for this library while other libraries are → a
    /// different library. Absence is never a notice (rule 8's keychain reset).
    func expectedNotice(_ device: SDevice, key: StoreKey, also: [StoreKey], executor: ProtectionExecutor) -> LibraryNotice.Kind? {
        guard let slot = device.slot, let record = slot.record else { return nil }
        let live = liveKeyFile(device)
        let reach = executor.reach(key: key, keyFile: live, extra: also)
        let remembered = Set(device.keychain.names(service: ProtectionNames.memoryService)
            .compactMap { ProtectionNames.parseMemoryAccount($0.account, scope: Self.scope) })
        var memory: DeviceMemory?
        if case .memory(let sealed)? = device.keychain.local[KName.memory(Self.scope, record.libraryID)]?.value,
           let named = try? ProtectionCoding.decoder().decode(DeviceMemory.self, from: sealed.payload), named.libraryID == record.libraryID {
            memory = named
        }
        guard let memory else { return !remembered.isEmpty && !remembered.contains(record.libraryID) ? .differentLibrary : nil }
        if slot.fingerprint == memory.currentFingerprint { return nil }
        let inFlight = record.verifiedSections(reach: reach).first { $0.deviceID == memory.deviceID }?.actInFlight
        let actKeys = Set([inFlight?.fromFingerprint, inFlight?.toFingerprint].compactMap { $0 })
        if actKeys.contains(slot.fingerprint), actKeys.contains(memory.currentFingerprint) { return nil }
        if let live, live.fingerprint == slot.fingerprint, live.history.contains(where: { $0.fingerprint == memory.currentFingerprint }) {
            return nil
        }
        return .olderCopy(date: record.changedAt)
    }

    /// Every key-file copy this Mac's memory items carry (rule 1's sealed copy).
    func mirrors(_ device: SDevice) -> [KeyFile] {
        device.keychain.local.values.compactMap { item in
            guard case .memory(let sealed) = item.value,
                  let memory = try? ProtectionCoding.decoder().decode(DeviceMemory.self, from: sealed.payload) else { return nil }
            return memory.keyFileMirror
        }
    }

    /// Does the library in the live place open by her roads — with nothing in
    /// the app's hands (a crash now would drop the key in memory)?
    func opensByHerRoads(_ device: SDevice) -> Bool {
        guard let slot = device.slot else { return true }
        return reach(herSeeds(device, inHand: false), files: keyFilesOn(device) + mirrors(device))[slot.fingerprint] != nil
    }

    /// PROMISE 8 (rule 22): a delete (`body`) after which the library in the
    /// live place no longer opens by any road of hers — when it did just before
    /// — is a key deleted before its replacement verified.
    func deleting(_ device: SDevice, _ what: String, _ body: () -> Void) throws {
        let before = opensByHerRoads(device)
        body()
        if before, !opensByHerRoads(device) {
            truth.strandings.append((device.name, "after \(what) no road of hers opens the library in the live place"))
        }
    }
}
