//
//  World.swift
//  VariorumCoreTests — VX-305 U4: THE SCENARIO WORLD (design §4.1, the phase
//  plan §6): two Macs and a phone, two Apple accounts and two Variorum
//  accounts, the fakes with real semantics (`Fakes.swift`), an older build as
//  an actor (`OlderBuild.swift`), real key files and wraps with test-speed KDF
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

enum Build: String, Equatable {
    case new
    /// Today's build (pre-VX-305): it reads and mints only the old shared key.
    case older
}

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
    var byOlderBuild = false
    /// Whose secrets it was made under — an account, or the library's own.
    var holder: String
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
    /// Copies a retirement sheet listed before she confirmed it (promise 5's
    /// stated exception), by path.
    var listedBySheet: Set<String> = []
    /// Library keys two Macs share because of a hand-off made before this
    /// change (§3.1 rule 2's third exception).
    var handedOffBeforeChange: Set<String> = []
    /// Keys an older build's leave or follow put under the old shared key with
    /// no change of keys (promise 13's one exception).
    var olderBuildLeaveKeys: Set<String> = []
    /// Keys made in Castle — by the record's family tree at their birth.
    var castleBorn: Set<String> = []
    /// The time each library left Castle, per device (promise 13).
    var leftCastleAt: [String: Date] = [:]
    /// Every key the library had when it last left Castle, per device — what
    /// promise 13 keeps from the Apple account and the login password.
    var keptByLeave: [String: Set<String>] = [:]
    /// Corpus key ids current while their vault read Castle (§3.9: no
    /// Castle-era corpus key ever sits under anything Apple-reachable).
    var castleCorpusKeyIDs: Set<String> = []
    /// Apple key ids lost to an Apple-ID switch, an iCloud Keychain reset or a
    /// wiped keychain (promise 5's "its own Apple key and this Mac's are both
    /// gone").
    var lostAppleKeys: Set<String> = []
    /// Devices on an older build when the old shared key was retired (promise
    /// 5's exception).
    var olderWhenRetired: Set<String> = []
    /// Masters an older build's leave put under the old shared key (§8's
    /// residue — this build never adds to it).
    var olderExposedMasters: Set<Data> = []
    /// Devices whose STANDARD key file a login-password holder rewrote, with
    /// the key it was then under — rule 3: in Standard that person can rewrite
    /// anything, and no repair acts on a Standard record's word (§3.3), so
    /// promise 3's own-key wording waits for the next key change.
    var tamperedStandard: [String: String] = [:]
    /// Apple key ids whose deliberate delete never reached iCloud: made while
    /// the device's switch was off, or queued and lost with its keychain (a
    /// replaced, wiped or re-Apple-ID'd device) — §8's residue (PROVISIONAL
    /// P-U4-1: after a leave, nothing in Standard deletes them on sight).
    var deletesNotCarried: Set<String> = []
    /// Every copy retention pruned: who, under which Mac, for which library.
    var prunes: [(by: String, mac8: String, library: String, copy: CatalogCopy)] = []
    /// Every copy opened into a library: the record before and after.
    var opens: [(device: String, before: ProtectionRecord, after: ProtectionRecord?)] = []
}

final class SDevice {
    let name: String
    let isPhone: Bool
    var machine: MachineIdentity
    var build: Build = .new
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
    var sessionMemory: [String: DeviceKeyMaterial] = [:]
    var paused = false
    var writeCount = 0
    var crashAfterWrites: Int?
    var logLines: [String] = []
    var diagnostics: [ProtectionDiagnostic] = []
    // The app, while it runs.
    var executor: ProtectionExecutor?
    var library: UnlockedLibrary?
    var touchIDPress: TouchIDPress?
    var corner45Answer: ProtectionMode?
    /// Today's per-device settings (UserDefaults — §3.15 retires them there).
    var legacySettings = DeviceSettings(gateStyle: .touchID)
    /// Today's 13p-era stored at-open mode.
    var legacyAtOpenMode: LegacyAtOpenMode?
    /// Today's device identity for the slot's library (the sync custody item's).
    var olderDeviceID: String?
    /// What an adversary with the login password captured earlier — replayed
    /// one at a time, or both homes together (§4.1).
    var captures: [DeviceCapture] = []
    /// The last act's outcome (a Done's words).
    var lastOutcome: ActOutcome?
    /// Hand-off folders Send Library brought here, oldest first.
    var incoming: [String] = []
    /// New secrets she chose at an act that hasn't finished (a crash): which
    /// one the locks end up under is read back once nothing is in flight.
    var pending: [(holder: String, passphrase: String?, words: [String]?)] = []

    init(name: String, isPhone: Bool, machine: MachineIdentity) {
        self.name = name
        self.isPhone = isPhone
        self.machine = machine
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

    static func legacyKeyFile(_ fingerprint: String?) -> String {
        fingerprint.map { StoreKeyEnvelope.filename(forFingerprint: $0) } ?? StoreKeyEnvelope.legacyFilename
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
    case olderBuild
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
    /// Every promise violation, with the log line it surfaced at.
    var violations: [(Violation, Int)] = []
    /// Each action kind's outcomes (the generator's coverage).
    var stats: [String: [String: Int]] = [:]
    /// The account each device's library was last seen bound to.
    var lastBinding: [String: String?] = [:]

    /// Two Macs and a phone on Apple account 1 (the phone and Mac A share a
    /// login identity? never: each device its own hardware and login).
    init(seed: UInt64 = 1) {
        rng = SeededRandom(seed: seed)
        appleAccounts[Self.appleA] = AppleAccountFake(id: Self.appleA)
        appleAccounts[Self.appleB] = AppleAccountFake(id: Self.appleB)
        farFolders[Self.appleA] = FolderFS()
        farFolders[Self.appleB] = FolderFS()
        for (name, phone) in [("macA", false), ("macB", false), ("phone", true)] {
            let device = SDevice(
                name: name, isPhone: phone,
                machine: MachineIdentity(hardware: rng.uuid().uppercased(), login: rng.uuid().uppercased()))
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
                let own = holder(device, account: nil, libraryID: slot.libraryID)
                if truth.known[own]?.passphrase == nil && truth.known[own]?.words == nil {
                    let k = known(was)
                    setKnown(own, passphrase: k.passphrase, words: k.words)
                }
            }
            lastBinding[key] = .some(record.account)
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
                if isAccount, let vault = server.snapshot(choice.holder), let pk = passphraseKey(p, vault.format.kdf) {
                    opens = (try? vault.format.unwrapMaster(withPassphraseKey: pk.key)) != nil
                } else if let wrap = liveKeyFile(device)?.passphrase, let pk = passphraseKey(p, wrap.kdf) {
                    opens = Lock.unwrap(wrap.wrapped, under: pk.key) != nil
                }
                if opens { k.passphrase = p; adopted = true }
            }
            if let w = choice.words, w != k.words, let wk = wordsKey(w) {
                var opens = false
                if isAccount, let vault = server.snapshot(choice.holder) {
                    opens = (try? vault.format.unwrapMaster(withRecoveryKey: wk)) != nil
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
        } else {
            device.keychain.synced[name] = nil
            if let id { truth.deletesNotCarried.insert(id) }
        }
    }

    /// The device's keychain goes (replaced, wiped, signed into another Apple
    /// ID): its queued deletes never reach iCloud.
    func loseQueuedDeletes(_ device: SDevice) {
        // Apple keys that lived only here (made while off, or queued and never
        // uploaded) are gone with the keychain.
        let cloud = device.appleAccount.flatMap { appleAccounts[$0]?.cloud } ?? [:]
        for (name, replica) in device.keychain.synced where replica.item != nil && cloud[name]?.item == nil {
            if let id = replica.item?.value.appleKey?.id { truth.lostAppleKeys.insert(id) }
        }
        for (name, replica) in device.keychain.synced where replica.dirty && replica.item == nil {
            if case .own(let id)? = ProtectionNames.parseAppleKeyAccount(name.account, scope: Self.scope) {
                truth.deletesNotCarried.insert(id)
            } else if name == KName.oldShared(Self.scope), let id = appleAccounts[device.appleAccount ?? ""]?.cloud[name]?.item?.value.appleKey?.id {
                truth.deletesNotCarried.insert(id)
            }
        }
    }

    // MARK: - Leaves

    func leaves(_ device: SDevice) -> ExecutorLeaves {
        let leaf = DeviceLeaves(world: self, device: device)
        return ExecutorLeaves(
            custody: leaf, legacyItems: leaf, syncKeys: leaf, apple: leaf, vault: leaf, library: leaf, keyFiles: leaf,
            memory: leaf, plans: leaf, backups: leaf, clock: leaf, ids: leaf, biometry: leaf, diagnostics: leaf)
    }

    func newExecutor(_ device: SDevice, libraryID: String) -> ProtectionExecutor {
        ProtectionExecutor(
            leaves: leaves(device),
            configuration: ExecutorConfiguration(
                scope: Self.scope, libraryID: libraryID, machine: device.machine, deviceName: device.name, floor: PF.floor,
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

    func liveKeyFile(_ device: SDevice) -> KeyFile? {
        if case .format3(let file)? = device.container.files[SPath.liveKeyFile]?.keyFile { return file }
        return nil
    }

    func legacyBeside(_ device: SDevice) -> [(path: String, file: LegacyKeyFile)] {
        device.container.files.keys.sorted().compactMap { path in
            guard !path.contains("/"), case .legacy(let legacy)? = device.container.files[path]?.keyFile else { return nil }
            return (path, legacy)
        }
    }

    func readableAppleKeys(_ device: SDevice) -> [String: AppleKeyMaterial] {
        var keys: [String: AppleKeyMaterial] = [:]
        for (name, replica) in device.keychain.synced where name.service == ProtectionNames.appleKeyService {
            guard let item = replica.item, case .own(let id)? = ProtectionNames.parseAppleKeyAccount(name.account, scope: Self.scope),
                  let key = item.value.appleKey else { continue }
            keys[id] = key
        }
        return keys
    }

    func oldSharedKey(_ device: SDevice) -> AppleKeyMaterial? {
        device.keychain.synced[KName.oldShared(Self.scope)]?.item?.value.appleKey
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

    func slotHolder(_ device: SDevice) -> String? {
        guard let slot = device.slot else { return nil }
        return holder(device, account: slot.record?.account ?? (slot.record == nil ? slot.rowsOwner : nil), libraryID: slot.libraryID)
    }

    /// The secrets she would type for the library in the slot.
    func typedFor(_ device: SDevice) -> TypedSecrets {
        guard let holder = slotHolder(device) else { return .none }
        let known = known(holder)
        return TypedSecrets(passphrase: known.passphrase, words: known.words)
    }

    /// Every road this device has for the slot, walked as she would: the
    /// custody items enumerated (a Touch ID item through a press), today's
    /// items, the Apple wraps whose key reads here, the typed secrets on every
    /// key file the device holds, the vault road behind them — each candidate
    /// expanded through the history and the anchor. Returns the key that
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
        // Today's items.
        for name in device.keychain.names(service: LegacyItems.storeKeyService) {
            guard let item = device.keychain.item(name) else { continue }
            add(pressRead(device, item)?.libraryKey)
        }
        // Every key file this device holds beside the slot, and the catalog's.
        let catalog = catalog(device)
        let files = catalog.keyFiles.compactMap(\.document)
        let apple = readableAppleKeys(device), shared = oldSharedKey(device)
        var secrets: [ProtectionSecret] = []
        if let passphrase = typed.passphrase { secrets.append(.passphrase(passphrase)) }
        if let newPassphrase = typed.newPassphrase { secrets.append(.passphrase(newPassphrase)) }
        if let words = typed.words { secrets.append(.words(words)) }
        var masters: [SymmetricKey] = []
        if device.online, let account = device.session.accountID, let vault = server.snapshot(account) {
            if let passphrase = typed.passphrase, let key = passphraseKey(passphrase, vault.format.kdf),
               let master = try? vault.format.unwrapMaster(withPassphraseKey: key.key) {
                masters.append(master)
            }
            if let words = typed.words, let wk = try? WordsKey.derive(words),
               let master = try? vault.format.unwrapMaster(withRecoveryKey: wk.key) {
                masters.append(master)
            }
        }
        for document in files {
            switch document {
            case .format3(let file):
                if let wrap = file.apple, let key = apple[wrap.keyID] { add(try? file.open(apple: key)) }
                if let shared, file.sharedApple?.keyID == shared.id { add(try? file.open(sharedApple: shared)) }
                for secret in secrets { add(try? file.open(secret, floor: PF.floor)) }
                for master in masters { add(try? file.open(master: master)) }
            case .legacy(let legacy):
                if let shared { add(try? legacy.open(sharedApple: shared)) }
                if let passphrase = typed.passphrase { add(try? legacy.open(passphrase: passphrase, floor: PF.floor)) }
                if let words = typed.words { add(try? legacy.open(words: words)) }
                for master in masters { add(try? legacy.open(master: master)) }
            }
        }
        // Expansion: every file's history under a key in hand; every anchor by
        // the typed secrets or by its outgoing key.
        var index = 0
        while index < candidates.count {
            let key = candidates[index]
            index += 1
            for document in files {
                guard case .format3(let file) = document else { continue }
                if file.fingerprint == PF.fp(key) {
                    for older in (try? file.historyKeys(currentKey: key)) ?? [] { add(older.key) }
                }
                for anchor in [file.anchor].compactMap({ $0 }) + file.keptAnchors {
                    if let contents = try? anchor.open(outgoingKey: key) { for held in contents.keys { add(held.key) } }
                }
            }
        }
        for document in files {
            guard case .format3(let file) = document else { continue }
            for anchor in [file.anchor].compactMap({ $0 }) + file.keptAnchors {
                for secret in secrets {
                    if let contents = try? anchor.open(secret, floor: PF.floor) {
                        for held in contents.keys { add(held.key) }
                        for kept in contents.keptAnchors {
                            if let inner = try? kept.open(secret, floor: PF.floor) { for held in inner.keys { add(held.key) } }
                        }
                    }
                }
            }
        }
        guard let opener = candidates.first(where: { PF.fp($0) == slot.fingerprint }) else { return nil }
        return (opener, candidates.filter { $0 != opener })
    }

    // MARK: - Launch: the lobby, unlock, settle, the migration, the repairs

    /// The app opens on `device`: the lobby walks its roads, the executor
    /// unlocks with every key reached, settles any act in flight, migrates a
    /// library with no record, reads the vault fresh, and runs the repairs
    /// `assess` owes.
    @discardableResult
    func launch(_ device: SDevice, typed: TypedSecrets? = nil) async throws -> UnlockedLibrary {
        guard device.build == .new else { throw WorldRefusal.olderBuild }
        if device.isOpen, let library = device.library { return library }
        guard let slot = device.slot else { throw WorldRefusal.noLibrary }
        let typed = typed ?? typedFor(device)
        device.touchIDPress = nil
        guard let (key, also) = await walkLobby(device, typed: typed) else { throw WorldRefusal.cannotOpen }
        let executor = newExecutor(device, libraryID: slot.record?.libraryID ?? slot.libraryID)
        device.executor = executor
        var library = try executor.unlock(with: key, alsoInHand: also)
        device.library = library
        do {
            _ = try await executor.settle(&library, typed: typed)
        } catch let crash as SimulatedCrash {
            throw crash
        } catch {
            // The lobby opens the library all the same; the act stays owed
            // (promise 6 then says whether it may: only offline).
            stepLog.append("  \(device.name): the act in flight couldn't settle now (\(error))")
        }
        device.library = library
        if library.record == nil {
            let inputs = migrationInputs(device, library: library)
            if let account = inputs.account, device.session.accountID == account, device.online {
                _ = try? await executor.readVault(accountID: account)
            }
            _ = try await executor.migrate(&library, inputs: inputs, typed: typed)
            device.library = library
            noteBirths(device)
        }
        if let account = library.record?.account, device.session.accountID == account, device.online {
            _ = try? await executor.readVault(accountID: account)
            // The lobby's Always-ask duty (pre-13x §3.3, phase 2's): with no
            // sync-keys item, the account's keys come from the vault through
            // the secret typed at the unlock, held for the session.
            let leaf = DeviceLeaves(world: self, device: device)
            let held = [ProtectionNames.CustodyClass.touchid, .silent].contains { (try? leaf.readSyncKeys(accountID: account, itemClass: $0)) != nil }
            if !held, device.sessionMemory[account] == nil, let vault = server.snapshot(account) {
                var master: SymmetricKey?
                if let p = typed.passphrase, let pk = passphraseKey(p, vault.format.kdf) { master = try? vault.format.unwrapMaster(withPassphraseKey: pk.key) }
                if master == nil, let w = typed.words, let wk = wordsKey(w) { master = try? vault.format.unwrapMaster(withRecoveryKey: wk) }
                if let master { device.sessionMemory[account] = try? VaultModel.material(following: vault.format, master: master) }
            }
        }
        try await runRepairs(device)
        return device.library!
    }

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
    }

    // MARK: - assess's facts for a device

    func facts(_ device: SDevice) -> ProtectionFacts {
        let catalog = catalog(device)
        let leaf = DeviceLeaves(world: self, device: device)
        let custody = (try? leaf.custodyItems()) ?? []
        let legacy = (try? leaf.legacyItems()) ?? []
        let syncKeys = (try? leaf.syncKeyItems()) ?? []
        let apple = AppleKeyFacts(readable: Set(readableAppleKeys(device).keys), oldSharedID: oldSharedKey(device)?.id)
        var unlocked: UnlockedFacts?
        if let library = device.library {
            let reach = device.executor?.reach(key: library.key, keyFile: library.keyFile) ?? PF.reach([library.key])
            let recordSection = library.record?.verifiedSections(reach: reach).first { $0.deviceID == library.section.deviceID }
            var legacyInputs: LegacyModeInputs?
            if library.record == nil { legacyInputs = migrationInputs(device, library: library).legacyMode }
            unlocked = UnlockedFacts(
                record: library.record, legacyModeInputs: legacyInputs, familyTree: library.familyTree,
                thisMac: library.section, identity: library.resolution, memory: library.memory,
                currentFingerprint: library.fingerprint,
                liveKeyFileID: device.container.files[SPath.liveKeyFile] == nil ? nil
                    : Catalog.id(place: .container, folders: [], name: SPath.liveKeyFile),
                corner45Answer: device.corner45Answer, recordSection: recordSection)
        }
        let sessionAccount = device.session.accountID
        let vault = sessionAccount.flatMap { device.executor?.freshVaults[$0]?.reading }
        return ProtectionFacts(
            scope: Self.scope, storeFile: device.slot == nil ? .absent : .present,
            containerMarker: device.container.files[SPath.marker] != nil, unlocked: unlocked,
            slotFingerprintHint: liveKeyFile(device)?.fingerprint, custody: custody, legacyItems: legacy,
            syncKeys: syncKeys, appleKeys: apple, biometry: device.biometry.facts, touchIDPress: device.touchIDPress,
            session: device.session, vault: vault, catalog: catalog, now: clock)
    }

    func assessed(_ device: SDevice) -> Assessment { assess(facts(device), guards: guards) }

    // MARK: - The migration's inputs, gathered from today's facts (phase 2's leaves)

    func migrationInputs(_ device: SDevice, library: UnlockedLibrary) -> MigrationInputs {
        let libraryID = device.slot?.libraryID ?? library.record?.libraryID ?? ""
        let current = library.fingerprint
        let beside = legacyBeside(device)
        let currentFile = beside.first { $0.file.fingerprint == current }?.file
        let facts = currentFile.map { LegacyKeyFileFacts($0.envelope) }
        let bound = device.keychain.local[KName.legacyBound(Self.scope, libraryID)]?.value.libraryKey
        let custody: LegacyRawKeyCustody = bound.map { PF.fp($0) == current } == true ? .silent : .gatedOrNone
        let syncItem = device.keychain.local[KName.legacySync(Self.scope, libraryID, gated: false)]
            ?? device.keychain.local[KName.legacySync(Self.scope, libraryID, gated: true)]
        var carried: String?
        if case .legacySync(let id, _)? = syncItem?.value { carried = id }
        let account = currentFile?.envelope.master != nil ? device.slot?.rowsOwner : nil
        let enrolled = syncItem != nil || account != nil
        var vaultApple: Bool?
        if let account, device.session.accountID == account, device.online, let vault = server.snapshot(account) {
            vaultApple = vault.format.masterWrappedByAppleHeld != nil
        }
        let catalog = catalog(device)
        let fingerprints = catalog.keyFiles.filter { $0.library == libraryID }.flatMap(\.heldFingerprints)
        // The move's subjects: other libraries' newest copies attributed to
        // this Mac, Standard-shaped.
        var newest: [String: CatalogCopy] = [:]
        for copy in catalog.copies {
            guard let other = copy.library, other != libraryID, copy.mac.isMac(String((carried ?? "").prefix(8))) else { continue }
            if let held = newest[other], (held.stamp ?? .distantPast) >= (copy.stamp ?? .distantPast) { continue }
            newest[other] = copy
        }
        let subjects = newest.values.compactMap { copy -> String? in
            guard let file = catalog.servingKeyFiles(of: copy).first else { return nil }
            return AssessRules.standardShaped(file) ? file.id : nil
        }.sorted()
        return MigrationInputs(
            legacyMode: LegacyModeInputs(
                legacyMode: device.legacyAtOpenMode, vaultHasAppleHeldCopy: vaultApple, keyFile: facts,
                rawKeyCustody: custody, enrolled: enrolled),
            account: account, carriedDeviceID: carried ?? device.olderDeviceID, settings: device.legacySettings,
            catalogFingerprints: Array(Set(fingerprints)).sorted(), moveSubjects: subjects)
    }

    /// The family tree's births on `device`'s library, as ground truth.
    func noteBirths(_ device: SDevice) {
        guard let record = device.library?.record else { return }
        for entry in record.familyTree.entries where entry.kind == .castle && entry.madeBy != nil {
            truth.castleBorn.insert(entry.fingerprint)
        }
        if record.mode == .castle, record.modeConfirmed { truth.castleBorn.insert(record.currentFingerprint) }
    }
}

// MARK: - The leaves: one device's view of the world

final class DeviceLeaves: CustodyLeaf, LegacyItemsLeaf, SyncKeysLeaf, AppleKeysLeaf, VaultLeaf, LibraryFileLeaf,
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
        device.keychain.local[KName.custody(scope, fingerprint, itemClass)] = nil
        try wrote("custody- \(itemClass.rawValue) \(f8(fingerprint))")
    }

    // MARK: Today's items

    func legacyItems() throws -> [LegacyItemFact] {
        var facts: [LegacyItemFact] = []
        for name in device.keychain.names(service: LegacyItems.storeKeyService) {
            guard name.account.hasPrefix(scope), let item = device.keychain.item(name) else { continue }
            if item.touchID {
                facts.append(LegacyItemFact(kind: .gated(account: name.account), fingerprint: nil))
            } else {
                facts.append(LegacyItemFact(kind: .silent(account: name.account), fingerprint: item.value.libraryKey.map(PF.fp)))
            }
        }
        for name in device.keychain.names(service: LegacyItems.syncCustodyService) where name.account.hasPrefix(scope) {
            facts.append(LegacyItemFact(kind: .syncCustody(account: name.account), fingerprint: nil))
        }
        for name in device.keychain.names(service: LegacyItems.escrowService) {
            guard let key = device.keychain.item(name)?.value.libraryKey else { continue }
            facts.append(LegacyItemFact(kind: .escrow(libraryID: name.account), fingerprint: PF.fp(key)))
        }
        return facts
    }

    func legacyName(_ kind: LegacyItemFact.Kind) -> KName {
        switch kind {
        case .silent(let account), .gated(let account): return KName(service: LegacyItems.storeKeyService, account: account)
        case .escrow(let libraryID): return KName.escrow(libraryID)
        case .syncCustody(let account): return KName(service: LegacyItems.syncCustodyService, account: account)
        }
    }

    func readLegacyItem(_ kind: LegacyItemFact.Kind) throws -> StoreKey? {
        if case .syncCustody = kind { return nil }
        guard let item = device.keychain.item(legacyName(kind)) else { return nil }
        return world.pressRead(device, item)?.libraryKey
    }

    func deleteLegacyItem(_ kind: LegacyItemFact.Kind) throws {
        let name = legacyName(kind)
        if case .escrow = kind { world.deleteSynced(device, name) } else { device.keychain.local[name] = nil }
        try wrote("legacy- \(name.account)")
    }

    // MARK: Sync keys

    func syncKeyItems() throws -> [SyncKeysItemFact] {
        device.keychain.names(service: ProtectionNames.syncKeysService).compactMap {
            ProtectionNames.parseSyncKeysAccount($0.account, scope: scope).map {
                SyncKeysItemFact(accountID: $0.accountID, itemClass: $0.class)
            }
        }
    }

    func readSyncKeys(accountID: String, itemClass: ProtectionNames.CustodyClass) throws -> DeviceKeyMaterial? {
        guard let item = device.keychain.local[KName.syncKeys(scope, accountID, itemClass)] else { return nil }
        return world.pressRead(device, item)?.material
    }

    func writeSyncKeys(_ material: DeviceKeyMaterial, accountID: String, itemClass: ProtectionNames.CustodyClass) throws {
        device.keychain.local[KName.syncKeys(scope, accountID, itemClass)] = KItem(
            value: .syncKeys(material), touchID: itemClass == .touchid, enrollment: device.biometry.generation)
        try wrote("sync+ \(itemClass.rawValue)")
    }

    func deleteSyncKeys(accountID: String, itemClass: ProtectionNames.CustodyClass) throws {
        device.keychain.local[KName.syncKeys(scope, accountID, itemClass)] = nil
        try wrote("sync- \(itemClass.rawValue)")
    }

    func holdInSession(_ material: DeviceKeyMaterial?, accountID: String) { device.sessionMemory[accountID] = material }
    func sessionSyncKeys(accountID: String) -> DeviceKeyMaterial? { device.sessionMemory[accountID] }

    // MARK: Apple keys

    func readableAppleKeyIDs() throws -> Set<String> { Set(world.readableAppleKeys(device).keys) }
    func readAppleKey(id: String) throws -> AppleKeyMaterial? { world.readableAppleKeys(device)[id] }

    func addAppleKey(_ key: AppleKeyMaterial) throws {
        world.addSynced(device, KName.apple(scope, key.id), KItem(value: .apple(id: key.id, bytes: PF.bytes(key.key))))
        try wrote("apple+ \(key.id.prefix(8))")
    }

    func deleteAppleKey(id: String) throws {
        guard device.keychain.synced[KName.apple(scope, id)]?.item != nil else { return }
        world.deleteSynced(device, KName.apple(scope, id))
        try wrote("apple- \(id.prefix(8))")
    }

    func readOldSharedAppleKey() throws -> AppleKeyMaterial? { world.oldSharedKey(device) }

    func deleteOldSharedAppleKey(id: String) throws -> Bool {
        guard let shared = world.oldSharedKey(device), shared.id == id else { return false }
        world.deleteSynced(device, KName.oldShared(scope))
        try wrote("shared- \(id.prefix(8))")
        return true
    }

    // MARK: The vault

    func fetchVault(accountID: String) async throws -> VaultSnapshot? {
        guard device.online else { throw VaultRefusal.unreachable }
        return world.server.snapshot(accountID)
    }

    func createVault(_ format: KeyVaultFormat, accountID: String, device name: String) async throws -> VaultSnapshot {
        guard device.online else { throw VaultRefusal.unreachable }
        var named = format
        named.updatedByDevice = name
        let snapshot = try world.server.create(named, accountID: accountID)
        try wrote("vault create")
        return snapshot
    }

    func updateVault(
        _ format: KeyVaultFormat, accountID: String, expectedRevision: Int, proofMaster: SymmetricKey, device name: String
    ) async throws -> VaultSnapshot {
        guard device.online else { throw VaultRefusal.unreachable }
        var named = format
        named.updatedByDevice = name
        let snapshot = try world.server.update(named, accountID: accountID, expectedRevision: expectedRevision, proofMaster: proofMaster)
        try wrote("vault \(ServerFake.describe(snapshot.format))")
        return snapshot
    }

    func reencryptBelowRotationSeq(accountID: String, material: DeviceKeyMaterial) async throws -> Int {
        guard device.online else { throw VaultRefusal.unreachable }
        let count = try world.server.reencrypt(accountID: accountID, material: material)
        try wrote("reencrypt")
        return count
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

    func stagedFingerprint() throws -> String? { device.staged?.fingerprint }

    func writeStagedRecord(_ record: ProtectionRecord, with newKey: StoreKey) throws {
        guard device.staged?.fingerprint == PF.fp(newKey) else { throw ExecutorRefusal.keyDoesNotOpenLibrary }
        device.staged?.record = record
        device.staged?.libraryID = record.libraryID
        try wrote("staged-record \(f8(newKey))")
    }

    func swapStaged(setAside: Bool) throws {
        guard let staged = device.staged else { throw ExecutorRefusal.nothingToDo }
        if setAside, let outgoing = slot {
            // The library she had goes to her older libraries, WITH every key
            // file the slot holds for it (LibraryAsideCopies' shape).
            let folder = "\(CatalogNames.previousLibrariesFolderName)/\(CatalogNames.stampString(world.tick()))"
            device.container.files["\(folder)/\(SPath.slot)"] = .library(outgoing)
            for path in device.container.files.keys where !path.contains("/") {
                guard let document = device.container.files[path]?.keyFile, document.libraryID == outgoing.libraryID else { continue }
                device.container.files["\(folder)/\(path)"] = .keyFile(document)
            }
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

    func readLegacyRotationMarker(with key: StoreKey) throws -> LegacyRotationMarker? {
        guard try libraryOpens(with: key) else { throw ExecutorRefusal.keyDoesNotOpenLibrary }
        return slot?.legacyMarker
    }

    func clearLegacyRotationMarker(with key: StoreKey) throws {
        guard try libraryOpens(with: key) else { throw ExecutorRefusal.keyDoesNotOpenLibrary }
        slot?.legacyMarker = nil
        try wrote("marker-")
    }

    // MARK: Key files

    func readLiveKeyFile() throws -> KeyFileDocument? { device.container.files[SPath.liveKeyFile]?.keyFile }

    func writeLiveKeyFile(_ file: KeyFile) throws {
        device.container.files[SPath.liveKeyFile] = .keyFile(.format3(file))
        try wrote("keyfile \(f8(file.fingerprint))")
    }

    func readOwnKeyFile(libraryID: String, deviceID: String) throws -> KeyFile? {
        if case .format3(let file)? = device.container.files["\(SPath.ownFolder(libraryID, deviceID))/\(SPath.liveKeyFile)"]?.keyFile {
            return file
        }
        return nil
    }

    func writeOwnKeyFile(_ file: KeyFile, deviceID: String) throws {
        let folder = SPath.ownFolder(file.libraryID, deviceID)
        device.container.files["\(folder)/\(SPath.liveKeyFile)"] = .keyFile(.format3(file))
        if let far = world.farFolder(of: device), !far.paths(under: folder + "/").isEmpty {
            far.files["\(folder)/\(SPath.liveKeyFile)"] = .keyFile(.format3(file))
        }
        try wrote("own-keyfile \(file.libraryID.prefix(8))")
    }

    func legacyKeyFilesBesideLibrary() throws -> [(id: String, file: LegacyKeyFile)] {
        world.legacyBeside(device).map { (Catalog.id(place: .container, folders: [], name: $0.path), $0.file) }
    }

    func deleteLegacyKeyFile(id: String) throws {
        guard let (fs, path) = resolve(id) else { return }
        fs.files[path] = nil
        try wrote("legacy-keyfile- \(path)")
    }

    func readKeyFile(catalogID: String) throws -> KeyFileDocument? {
        guard let (fs, path) = resolve(catalogID) else { return nil }
        return fs.files[path]?.keyFile
    }

    // MARK: Memory, plans

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
        world.writePair(device, image: slot, keyFile: .format3(keyFile), deviceID: deviceID)
        try wrote("backup \(f8(key))")
    }

    func writeSendPair(with key: StoreKey, keyFile: KeyFile, to destination: String) throws {
        guard !device.paused else { throw ExecutorRefusal.nothingToDo }
        guard let slot, slot.fingerprint == PF.fp(key) else { throw ExecutorRefusal.keyDoesNotOpenLibrary }
        device.container.files["\(destination)/\(SPath.slot)"] = .library(slot)
        device.container.files["\(destination)/\(SPath.liveKeyFile)"] = .keyFile(.format3(keyFile))
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
    func biometry() -> BiometryFacts { device.biometry.facts }
    func biometryStateHash() -> Data? { device.biometry.stateHash }
    func log(_ line: String) { device.logLines.append(line) }
    func report(_ entry: ProtectionDiagnostic) { device.diagnostics.append(entry) }
}

extension SWorld {
    /// A backup pair on `device`: the snapshot and its frozen key file, in this
    /// Mac's `Backups/<library8>/<mac8>/` — in the container, and in its far
    /// folder when it has one. The world remembers each copy's birth.
    func writePair(_ device: SDevice, image: LibraryImage, keyFile: KeyFileDocument, deviceID: String, olderBuild: Bool = false) {
        let at = tick()
        let folder = olderBuild ? CatalogNames.backupsFolderName : SPath.ownFolder(image.libraryID, deviceID)
        let name = SPath.snapshot(at, image.fingerprint)
        var places: [(String, FolderFS)] = [("container", device.container)]
        if let far = farFolder(of: device) { places.append(("farFolder", far)) }
        for (place, fs) in places {
            fs.files["\(folder)/\(name)"] = .library(image)
            fs.files["\(folder)/\(SPath.pair(of: name))"] = .keyFile(keyFile)
            truth.copies["\(place):\(folder)/\(name)"] = CopyTruth(
                libraryID: image.libraryID, fingerprint: image.fingerprint, madeAt: at, madeOn: device.name,
                mode: image.record?.mode, byOlderBuild: olderBuild,
                holder: holder(device, account: image.record?.account ?? (image.record == nil ? image.rowsOwner : nil), libraryID: image.libraryID))
        }
    }
}
