//
//  Promises.swift
//  VariorumCoreTests — VX-305 U4: THE THIRTEEN PROMISES (design §4.1), checked
//  after every step — 2's retired-key clause, 3 and 7 once the world settles
//  (propagation done, followers followed).
//
//  The checks rest on one engine, `KeyReach`: from SEEDS (keys, Apple keys,
//  masters, secrets, the vault's wrapped copies a session can fetch) it closes
//  over every key file a device holds — every lock, every history — to the
//  library keys reached. (Promise 13's pre-leave reading and the anchor left
//  with VX-378 U1 — rules 12, 13.) Two readers:
//    - THE ATTACKER (promises 2, 8): a login-password holder on the device
//      (every keychain item but a Touch ID item's secret, every file, the
//      session's vault) and the Apple account (its iCloud Keychain) — with the
//      STATED EXCEPTIONS taken out of the seeds, exactly as §3.1 rule 2 names
//      them, so whatever is left must open nothing protected;
//    - HER OWN ROADS (promises 5, 12): her finger, her custody, her secrets of
//      every day, her Apple keys, the vault through her secrets.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

struct Violation: Equatable, CustomStringConvertible {
    var promise: Int
    var device: String
    var detail: String

    var description: String { "promise \(promise) on \(device): \(detail)" }
}

/// What a reach starts from.
struct Seeds {
    var keys: [StoreKey] = []
    var apple: [String: SymmetricKey] = [:]
    var masters: [Data] = []
    var passphrases: [String] = []
    var words: [[String]] = []
    var vaults: [KeyVaultFormat] = []
}

extension SWorld {
    func wordsKey(_ words: [String]) -> SymmetricKey? {
        let memo = words.joined(separator: " ")
        if let held = wordsDerived[memo] { return held.key }
        guard let key = try? WordsKey.derive(words) else { return nil }
        wordsDerived[memo] = key
        return key.key
    }

    // MARK: - The engine

    /// Every library key the seeds reach through `files` (fingerprint → key).
    func reach(_ seeds: Seeds, files: [KeyFile]) -> [String: StoreKey] {
        var keys: [String: StoreKey] = [:]
        for key in seeds.keys { keys[PF.fp(key)] = key }
        var masters = seeds.masters
        let wordsKeys = seeds.words.compactMap { wordsKey($0) }
        func pass(_ wrap: StoreKeyEnvelope.PassphraseWrap?) -> [SymmetricKey] {
            guard let wrap else { return [] }
            return seeds.passphrases.compactMap { passphraseKey($0, wrap.kdf)?.key }
        }
        func addMaster(_ master: SymmetricKey) {
            let bytes = PF.bytes(master)
            if !masters.contains(bytes) { masters.append(bytes) }
        }
        var changed = true
        while changed {
            changed = false
            func add(_ key: StoreKey?) {
                guard let key, keys[PF.fp(key)] == nil else { return }
                keys[PF.fp(key)] = key
                changed = true
            }
            for vault in seeds.vaults {
                let before = masters.count
                if let id = vault.appleKeyID, let apple = seeds.apple[id], vault.masterWrappedByAppleHeld != nil,
                   let master = try? vault.unwrapMaster(withAppleKey: apple) { addMaster(master) }
                for p in seeds.passphrases {
                    if let pk = passphraseKey(p, vault.kdf), let master = try? vault.unwrapMaster(withPassphraseKey: pk.key) { addMaster(master) }
                }
                for wk in wordsKeys { if let master = try? vault.unwrapMaster(withRecoveryKey: wk) { addMaster(master) } }
                if masters.count != before { changed = true }
            }
            for file in files {
                do {
                    func open(_ blob: Data?, _ key: SymmetricKey) {
                        guard let blob, let opened = Lock.unwrapStoreKey(blob, under: key), PF.fp(opened) == file.fingerprint else { return }
                        add(opened)
                    }
                    if let wrap = file.apple, let apple = seeds.apple[wrap.keyID] { open(wrap.wrapped, apple) }
                    for master in masters { open(file.master, SymmetricKey(data: master)) }
                    if let copy = file.masterWordsCopy {
                        for wk in wordsKeys {
                            if let master = Lock.unwrap(copy, under: wk) {
                                let before = masters.count
                                addMaster(SymmetricKey(data: master))
                                if masters.count != before { changed = true }
                            }
                        }
                    }
                    for key in pass(file.passphrase) { open(file.passphrase?.wrapped, key) }
                    for wk in wordsKeys { open(file.words, wk) }
                    if let current = keys[file.fingerprint] {
                        for entry in file.history {
                            if let older = Lock.unwrapStoreKey(entry.wrapped, under: SymmetricKey(data: current.data)),
                               PF.fp(older) == entry.fingerprint { add(older) }
                        }
                    }
                }
            }
        }
        return keys
    }

    // MARK: - What a device holds

    /// Every key file on a device: its container, its far folder, its Time
    /// Machine snapshots.
    func keyFilesOn(_ device: SDevice, excluding exclude: (String, KeyFile) -> Bool = { _, _ in false }) -> [KeyFile] {
        var documents: [KeyFile] = []
        var sources: [(String, FolderFS?)] = [("container", device.container)]
        if let far = farFolder(of: device) { sources.append(("farFolder", far)) }
        for (place, fs) in sources {
            guard let fs else { continue }
            for (path, file) in fs.files {
                guard let document = file.keyFile, !exclude("\(place):\(path)", document) else { continue }
                documents.append(document)
            }
        }
        for snapshot in device.timeMachine {
            for (path, file) in snapshot {
                if let document = file.keyFile, !exclude("tm:\(path)", document) { documents.append(document) }
            }
        }
        return documents
    }

    /// Every library image on a device (the slot, the copies), by path.
    func imagesOn(_ device: SDevice) -> [(id: String, image: LibraryImage)] {
        var images: [(String, LibraryImage)] = []
        for (path, file) in device.container.files { if let image = file.library { images.append(("container:\(path)", image)) } }
        if let far = farFolder(of: device) {
            for (path, file) in far.files { if let image = file.library { images.append(("farFolder:\(path)", image)) } }
        }
        return images.sorted { $0.0 < $1.0 }
    }

    /// An Apple account's iCloud Keychain as it will be once it carries what
    /// its devices have already done — every queued add and delete of a
    /// device whose switch is on applied (the newer version of a name wins).
    func eventualCloud(_ appleAccount: String) -> [KName: KItem] {
        eventualEntries(appleAccount).compactMapValues(\.item)
    }

    /// The cloud once every switched-on device has uploaded — tombstones kept.
    func eventualEntries(_ appleAccount: String) -> [KName: AppleAccountFake.Entry] {
        guard let account = appleAccounts[appleAccount] else { return [:] }
        var cloud = account.cloud
        for device in devices where device.appleAccount == appleAccount && device.iCloudOn {
            for (name, replica) in device.keychain.synced where replica.dirty && replica.version > (cloud[name]?.version ?? 0) {
                cloud[name] = AppleAccountFake.Entry(item: replica.item, version: replica.version)
            }
        }
        return cloud
    }

    /// THE ATTACKER on `device`: a login-password holder there (every item's
    /// secret but a Touch ID item's; every file; the bound account's vault
    /// through the session) and, with `appleAccount`, the Apple account's whole
    /// iCloud Keychain — minus the stated exceptions.
    func attackerSeeds(_ device: SDevice, appleAccount: Bool, settled: Bool) -> Seeds {
        var seeds = Seeds()
        let section = device.library?.section
        // A synced item another device deleted, its tombstone on its way here
        // (iCloud Keychain's delay): it holds here once carried — the
        // retired-key clause's timing (checked once the world settles).
        let tombstoned: Set<KName> = {
            guard !settled, let id = device.appleAccount, device.iCloudOn else { return [] }
            let entries = eventualEntries(id)
            return Set(device.keychain.synced.compactMap { name, replica in
                guard replica.item != nil, !replica.dirty, let entry = entries[name], entry.item == nil,
                      entry.version > replica.version else { return nil }
                return name
            })
        }()
        var items = Array(device.keychain.local.values)
            + device.keychain.synced.filter { !tombstoned.contains($0.key) && !truth.deletedWhileOff.contains($0.key) }.values.compactMap(\.item)
        if appleAccount, let id = device.appleAccount {
            // A delete made and queued on a device whose iCloud Keychain switch
            // is off holds everywhere once iCloud Keychain carries it (§3.1
            // rule 2's stated exception) — the escrow's and the retirements'.
            let queued = Set(devices.filter { $0.appleAccount == id && !$0.iCloudOn }
                .flatMap { $0.keychain.synced.filter { $0.value.dirty && $0.value.item == nil }.map(\.key) })
            items += eventualCloud(id).filter { !queued.contains($0.key) && !truth.deletedWhileOff.contains($0.key) }.values
        }
        let retired = section?.retiredAppleKeyIDs ?? []
        for item in items where !item.touchID {
            switch item.value {
            case .key(let key): seeds.keys.append(key)
            case .syncKeys(let material): seeds.masters.append(material.masterKey)
            case .apple(let id, let bytes):
                // A deliberate delete that never reached iCloud (P-U4-1).
                if truth.deletesNotCarried.contains(id) { continue }
                // A retirement holds everywhere once iCloud Keychain carries
                // it (the retired-key clause — once the world settles; and
                // while this Mac's switch is off, the stated exception).
                if retired.contains(id), !settled || !device.iCloudOn { continue }
                seeds.apple[id] = SymmetricKey(data: bytes)
            default: break
            }
        }
        if let account = device.library?.record?.account, device.session.accountID == account,
           let vault = server.snapshot(account) {
            seeds.vaults.append(vault.format)
        }
        return seeds
    }

    /// HER roads on `device`: everything she holds, every secret she has ever
    /// had for the libraries and accounts it touches, the vault through them.
    func herSeeds(_ device: SDevice) -> Seeds {
        var seeds = Seeds()
        for item in Array(device.keychain.local.values) + device.keychain.synced.values.compactMap(\.item) {
            guard let value = pressRead(device, item) else { continue }
            switch value {
            case .key(let key): seeds.keys.append(key)
            case .syncKeys(let material): seeds.masters.append(material.masterKey)
            case .apple(let id, let bytes): seeds.apple[id] = SymmetricKey(data: bytes)
            default: break
            }
        }
        for material in device.sessionMemory.values { seeds.masters.append(material.masterKey) }
        if let library = device.library { seeds.keys.append(library.key) }
        // Her Apple accounts' keychains are hers — the switch off on this
        // device only hides one until she turns it back on, and an Apple ID
        // this Mac left still holds what it carried ("open through that former
        // account", §3.1 rule 2's last exception): she can sign back into it
        // (the closer's soak, seed 7 sequence 191).
        for id in appleAccounts.keys.sorted() {
            for item in eventualCloud(id).values {
                if case .apple(let keyID, let bytes) = item.value, seeds.apple[keyID] == nil { seeds.apple[keyID] = SymmetricKey(data: bytes) }
            }
        }
        seeds.passphrases = truth.allPassphrases
        seeds.words = truth.allWords
        // Her accounts' vaults: signing in (and coming online) is hers to do,
        // so a device signed out, or offline, still has the vault road behind
        // her secrets — "only the server brings its writing back" (§3.5a) is a
        // road, not a stranding (the closer's soak, seed 3 sequence 211).
        for account in server.accounts.keys.sorted() {
            if let vault = server.snapshot(account) { seeds.vaults.append(vault.format) }
        }
        return seeds
    }

    // MARK: - The checks

    /// Every promise that applies after a step. `settled`: the world has just
    /// settled — 2's retired-key clause, 3 and 7 are checked too.
    func checkPromises(settled: Bool) -> [Violation] {
        var violations: [Violation] = []
        for device in devices {
            violations += known(device)
            violations += castleMeansCastle(device, settled: settled)
            violations += crashSafe(device)
            if settled {
                violations += standardMeansStandard(device)
                violations += converges(device)
            }
        }
        violations += nothingStranded()
        violations += ownCopiesOnly()
        return violations
    }

    /// PROMISE 1 — Known: one record per live library, and what this Mac
    /// remembers agrees with it.
    func known(_ device: SDevice) -> [Violation] {
        guard let library = device.library, library.section.actInFlight == nil else { return [] }
        guard let record = device.slot?.record else {
            return [Violation(promise: 1, device: device.name, detail: "an open library with no record")]
        }
        let reach = device.executor?.reach(key: library.key, keyFile: library.keyFile) ?? PF.reach([library.key])
        guard case .memory(let sealed)? = device.keychain.local[KName.memory(Self.scope, record.libraryID)]?.value,
              let memory = DeviceMemory.opening(sealed, libraryID: record.libraryID, reach: reach) else {
            return [Violation(promise: 1, device: device.name, detail: "no verified memory item for the open library")]
        }
        if memory.currentFingerprint != record.currentFingerprint || memory.deviceID != library.section.deviceID {
            return [Violation(promise: 1, device: device.name,
                              detail: "the memory names \(f8(memory.currentFingerprint)) on \(memory.deviceID.prefix(8)), the record \(f8(record.currentFingerprint)) on \(library.section.mac8)")]
        }
        // (Its key-file clause — "no repair owed would bring the current key's
        // own file back" — left with the restores, VX-378 U1, rule 21: U2's
        // refusal is the answer and U4 rewrites the promise.)
        return []
    }

    /// PROMISES 2 and 8 — Castle means Castle; the posture law.
    func castleMeansCastle(_ device: SDevice, settled: Bool) -> [Violation] {
        guard let library = device.library, library.section.actInFlight == nil, let record = device.slot?.record,
              record.mode == .castle else { return [] }
        var violations: [Violation] = []
        func fail(_ detail: String, _ promise: Int = 2) { violations.append(Violation(promise: promise, device: device.name, detail: detail)) }
        // The keys the library has had: the live key file's current key and
        // history (rule 4 — the family tree left with VX-378 U1). A Time
        // Machine rollback past a leave (her act) leaves the later Standard
        // stretch's key out of the restored file, so its silent item is not
        // counted (PROVISIONAL P-U4-8).
        let tree = Set(liveKeyFile(device)?.heldFingerprints ?? []).union([record.currentFingerprint])
        // A Standard copy under a key the restored file never knew is the
        // later stretch's, after a Time Machine rollback past a leave (P-U4-8).
        func laterStandard(_ id: String, _ fingerprint: String) -> Bool {
            !tree.contains(fingerprint) && truth.copies[id]?.mode == .standard
        }
        for name in device.keychain.local.keys where name.service == ProtectionNames.custodyService {
            if let item = device.keychain.local[name], !item.touchID, let key = item.value.libraryKey, tree.contains(PF.fp(key)) {
                fail("a silent custody item holds \(f8(key))")
            }
        }
        for name in device.keychain.local.keys where name.service == ProtectionNames.syncKeysService {
            if let item = device.keychain.local[name], !item.touchID, case .syncKeys(let m) = item.value,
               let vault = record.account.flatMap({ server.snapshot($0) }), m.corpusKeyID == vault.corpusKeyID,
               vault.mode.settled != .standard {
                fail("a silent sync-keys item holds the account's Castle-era keys")
            }
        }
        if let live = liveKeyFile(device), live.fingerprint == record.currentFingerprint, live.apple != nil {
            fail("an Apple wrap of the current key")
        }
        if settled {
            let readable = Set(readableAppleKeys(device).keys)
            for id in library.section.retiredAppleKeyIDs where readable.contains(id) && device.iCloudOn {
                fail("a retired Apple key (\(id.prefix(8))) still exists here")
            }
        }
        // Nothing a login-password holder can read opens the library or any
        // copy of it made here (the stated exceptions taken out of the seeds).
        let attacker = reach(attackerSeeds(device, appleAccount: false, settled: settled), files: keyFilesOn(device))
        if attacker[record.currentFingerprint] != nil {
            fail("a login-password holder reaches the current key \(f8(record.currentFingerprint))", 8)
        }
        for (id, image) in imagesOn(device) where image.libraryID == record.libraryID && id != "container:\(SPath.slot)" {
            // "any copy made on this Mac or on a device of its account that has
            // followed": a pair another Mac sent here (its own Standard copy,
            // under its own key) isn't one.
            if let made = truth.copies[id], made.madeOn != device.name, record.account == nil || made.holder != record.account {
                continue
            }
            if senders.contains(where: { id.hasPrefix("container:\($0.key)/") && $0.value != device.name }) { continue }
            if truth.rolledBackOver.contains(id) || laterStandard(id, image.fingerprint) { continue }
            // A key a login-password holder already held in Standard (rule 3)
            // and tampered with there: entering Castle protects what's written
            // after (promise 8), never undoes what they took before.
            if truth.tamperedStandard[device.name]?.contains(image.fingerprint) == true { continue }
            if attacker[image.fingerprint] != nil {
                fail("a login-password holder opens the copy \(id) (\(f8(image.fingerprint)))")
            }
        }
        return violations
    }

    /// PROMISE 6 — crash-safe: with nothing running, no act is half-done —
    /// the act finished or rolled back, the library open, no copy carrying a
    /// half-finished act. THE VAULT-REACH QUALIFIER (her ruling 2026-10-14/15,
    /// the soak's seed 2): a SYNCED act PAST ITS COMMIT POINT whose account's
    /// vault this device can't reach — signed out, signed into another
    /// account, or offline — stays in flight NAMED and WAITING: this Mac's
    /// section names it, its plan on disk is the one the section names, the
    /// library is open, and copies stay paused while the re-key is unswapped;
    /// it finishes at the next vault reach. That is no third state. Anything
    /// else in flight is (a crash before the commit point rolls back).
    func crashSafe(_ device: SDevice) -> [Violation] {
        guard device.isOpen, let library = device.library else { return [] }
        var violations: [Violation] = []
        func fail(_ detail: String) { violations.append(Violation(promise: 6, device: device.name, detail: detail)) }
        var waiting = false
        if let inFlight = library.section.actInFlight {
            if let why = notNamedAndWaiting(device, library, inFlight) {
                fail("an act is still in flight (\(inFlight.act)) — \(why)")
            } else {
                waiting = true
                if let to = inFlight.toFingerprint, library.fingerprint != to, !device.paused {
                    fail("copies run while \(inFlight.act) waits, its re-key unswapped")
                }
            }
        }
        if library.section.actInFlight == nil, device.container.files[SPath.plan] != nil {
            fail("a plan is left on disk with nothing in flight")
        }
        if library.section.actInFlight == nil, device.staged != nil {
            fail("a staged file is left")
        }
        if device.paused, !waiting { fail("copies are still paused") }
        return violations
    }

    /// Why an act in flight is NOT named and waiting (nil when it is): the
    /// plan on disk the one this Mac's section names; a synced act; its
    /// account's vault out of this device's reach now; past its commit point
    /// (`ProtectionPlan.pastCommitPoint` — the executor's own line).
    func notNamedAndWaiting(_ device: SDevice, _ library: UnlockedLibrary, _ inFlight: ActInFlight) -> String? {
        guard case .plan(let sealed)? = device.container.files[SPath.plan],
              let plan = try? ProtectionCoding.decoder().decode(ProtectionPlan.self, from: sealed.payload) else {
            return "no plan on disk"
        }
        guard plan.isNamed(by: library.section) else { return "the plan on disk isn't the one this Mac's section names" }
        guard plan.parameters?.synced == true, let account = plan.parameters?.accountID ?? library.record?.account else {
            return "not a synced act"
        }
        guard !device.online || device.session.accountID != account else { return "its account's vault is in reach" }
        guard plan.pastCommitPoint(libraryFingerprint: library.fingerprint) else {
            return "before its commit point (it rolls back)"
        }
        return nil
    }

    /// PROMISE 3 (settled) — Standard means Standard.
    func standardMeansStandard(_ device: SDevice) -> [Violation] {
        guard let library = device.library, library.section.actInFlight == nil, let record = device.slot?.record,
              record.mode == .standard else { return [] }
        if truth.tamperedStandard[device.name]?.contains(record.currentFingerprint) == true { return [] }
        // Decision 35: a synced library writes nothing Apple-reachable without
        // a fresh read of its account's vault — signed out, in another account
        // or offline, its own Apple key waits (Re-link's library arm too).
        if let account = record.account, device.session.accountID != account || !device.online { return [] }
        guard let live = liveKeyFile(device), live.fingerprint == record.currentFingerprint, let wrap = live.apple else {
            return [Violation(promise: 3, device: device.name, detail: "no Apple wrap of the current key")]
        }
        // The Apple road works here: its key is readable (rule 8). ("This Mac's
        // own" left with the takeover — VX-378 U1, rule 23: a Mac with a new
        // device ID owns no key it didn't mint, and the wrap's key reaches it
        // through iCloud Keychain.)
        guard readableAppleKeys(device)[wrap.keyID] != nil else {
            // A lost Apple road (its key gone with a replaced or reset
            // keychain) is detected — `Fault.appleRoadLost` — and rule 8's
            // quiet re-make is U2's (Re-link left with VX-378 U1, rule 8).
            let lost = assessed(device).faults.contains { if case .appleRoadLost = $0 { return true } else { return false } }
            if lost { return [] }
            return [Violation(promise: 3, device: device.name, detail: "the Apple wrap's key isn't readable here")]
        }
        return []
    }

    /// PROMISE 7 (settled) — every device of an account ends in its mode and keys.
    func converges(_ device: SDevice) -> [Violation] {
        guard let library = device.library, library.section.actInFlight == nil, let record = device.slot?.record,
              let account = record.account, device.session.accountID == account, device.online,
              let vault = server.snapshot(account) else { return [] }
        // A Standard device's files tampered with (outside the claims — rule
        // 3), until a deliberate act mints a key past them (P-U4-10).
        if truth.tamperedStandard[device.name]?.contains(record.currentFingerprint) == true { return [] }
        var violations: [Violation] = []
        let mode = vault.mode.settled
        if mode != record.mode {
            violations.append(Violation(promise: 7, device: device.name, detail: "the library is \(record.mode), the account \(mode)"))
        }
        let leaf = DeviceLeaves(world: self, device: device)
        let held = [ProtectionNames.CustodyClass.touchid, .silent].lazy.compactMap { try? leaf.readSyncKeys(accountID: account, itemClass: $0) }.first
            ?? device.sessionMemory[account]
        if let held, held.corpusKeyID != vault.corpusKeyID {
            violations.append(Violation(promise: 7, device: device.name, detail: "its sync keys are not the account's"))
        }
        return violations
    }

    /// PROMISE 5 — nothing stranded: every copy Variorum wrote opens, on the
    /// device that made it, by the roads she has (her secrets of every day
    /// among them) — except the stated ones.
    func nothingStranded() -> [Violation] {
        var violations: [Violation] = []
        var reachCache: [String: [String: StoreKey]] = [:]
        for (id, copy) in truth.copies.sorted(by: { $0.key < $1.key }) {
            let device = device(copy.madeOn)
            guard let (fs, path) = DeviceLeaves(world: self, device: device).resolve(id), let image = fs.files[path]?.library else {
                continue  // deleted (by her, by retention, by a wiped container)
            }
            let reached = reachCache[device.name] ?? reach(herSeeds(device), files: keyFilesOn(device))
            reachCache[device.name] = reached
            if reached[image.fingerprint] != nil { continue }
            // (The secretless copy's exception — a copy made with no
            // passphrase or words whose Apple keys were lost — left with rule
            // 2: no library is without its words.)
            violations.append(Violation(promise: 5, device: device.name, detail: "the copy \(id) (\(f8(image.fingerprint))) opens by no road"))
        }
        return violations
    }



    /// PROMISE 11 — own copies only: retention prunes only this Mac's copies
    /// of this library.
    func ownCopiesOnly() -> [Violation] {
        var violations: [Violation] = []
        for prune in truth.prunes {
            if prune.copy.mac != .mac8(prune.mac8.lowercased()) || prune.copy.library != prune.library {
                violations.append(Violation(promise: 11, device: prune.by, detail: "retention pruned \(prune.copy.id), not this Mac's copy of this library"))
            }
        }
        truth.prunes.removeAll()
        return violations
    }

    // MARK: - Promises with a before and an after

    /// What a step may change on a device (promise 4, 10).
    struct Posture: Equatable {
        var libraryID: String?
        var mode: ProtectionMode?
        var account: String?
        var fingerprint: String?
        var gate: GateStyle?
        var scheduledExport: Bool?
        var silentItems: Set<String>
        var touchIDItems: Set<String>
    }

    func posture(_ device: SDevice) -> Posture {
        let record = device.slot?.record
        let section = device.library?.section
        var silent: Set<String> = [], touch: Set<String> = []
        for name in device.keychain.local.keys where name.service == ProtectionNames.custodyService {
            guard let parsed = ProtectionNames.parseCustodyAccount(name.account, scope: Self.scope) else { continue }
            if parsed.class == .silent { silent.insert(parsed.fingerprint) } else { touch.insert(parsed.fingerprint) }
        }
        return Posture(
            libraryID: device.slot?.libraryID, mode: record?.mode, account: record?.account,
            fingerprint: record?.currentFingerprint, gate: section?.settings.gateStyle,
            scheduledExport: section?.settings.scheduledExport, silentItems: silent, touchIDItems: touch)
    }

    /// PROMISE 4 — no silent change: the mode and the account change only at
    /// a deliberate act or its follow; a copy never lowers the mode or brings
    /// its own key.
    func noSilentChange(_ action: Action, before: [String: Posture], crashedBefore: Set<String>) -> [Violation] {
        var violations: [Violation] = []
        for device in devices {
            guard let was = before[device.name] else { continue }
            let now = posture(device)
            guard was.libraryID == now.libraryID, was.mode != nil, now.mode != nil else { continue }
            let changed = was.mode != now.mode || was.account != now.account
            guard changed else { continue }
            if deliberate(action, on: device.name) || crashedBefore.contains(device.name) { continue }
            if let back = truth.beforeRollback[device.name], back.mode == now.mode, back.account == now.account {
                truth.beforeRollback[device.name] = nil
                continue
            }
            violations.append(Violation(
                promise: 4, device: device.name,
                detail: "\(was.mode.map { "\($0)" } ?? "-")/\(was.account?.prefix(8) ?? "none") → \(now.mode.map { "\($0)" } ?? "-")/\(now.account?.prefix(8) ?? "none") at a step that isn't a deliberate act"))
        }
        for open in truth.opens {
            guard let after = open.after else { continue }
            if open.before.mode == .castle, after.mode == .standard {
                violations.append(Violation(promise: 4, device: open.device, detail: "opening a copy lowered the mode"))
            }
            if after.currentFingerprint != open.before.currentFingerprint {
                violations.append(Violation(promise: 4, device: open.device, detail: "opening a copy brought its own key"))
            }
        }
        truth.opens.removeAll()
        return violations
    }

    func deliberate(_ action: Action, on name: String) -> Bool {
        switch action {
        case .crash(let inner, _): return deliberate(inner, on: name)
        case .settle: return true
        // Files replaced from outside the app (promise 10 judges a tamper in
        // Castle; promise 4 judges what the app does).
        case .timeMachineRollback(let d), .deleteContainerAndOpenOldCopy(let d), .tamper(let d, _), .tamperSequence(let d, _):
            return d == name
        case .useCastle(let d, _, _), .useStandard(let d), .follow(let d, _), .turnOnSync(let d),
             .move(let d), .thisMacOnly(let d), .stopSyncingHere(let d), .deleteAccountHere(let d), .replaceAllKeys(let d, _):
            return d == name
        default:
            return false
        }
    }

    /// PROMISE 10 — sealed: in Castle, no planted, edited, replayed or deleted
    /// file or item ALONE changes the mode, the account, the custody or the
    /// gate style — the weakening directions (Always ask recorded quietly
    /// when an item vanished never weakens anything). The stated limit (both
    /// homes together) may return this Mac's settings.
    func sealed(_ device: SDevice, before was: Posture, tamper: Tamper) -> [Violation] {
        sealed(device, before: was, tampers: [tamper])
    }

    /// …and over a GROUP of tampers in one closed window (VX-305 ladder round
    /// 1): the same claims — the stated limit's shape only in a group that
    /// holds `.replayBothHomes` itself (a fixed scenario's).
    func sealed(_ device: SDevice, before was: Posture, tampers: [Tamper]) -> [Violation] {
        guard was.mode == .castle else { return [] }
        let now = posture(device)
        var violations: [Violation] = []
        let label = tampers.map { "\($0)" }.joined(separator: " + ")
        func fail(_ what: String) { violations.append(Violation(promise: 10, device: device.name, detail: "after \(label): \(what)")) }
        let statedLimit = tampers.contains(.replayBothHomes)
        // The stated limit (§3.6): both homes rolled back together return this
        // Mac — the library file's record with it — to that earlier state.
        if now.libraryID == was.libraryID, !statedLimit {
            if now.mode != .castle { fail("the mode is \(now.mode.map { "\($0)" } ?? "unknown")") }
            if now.account != was.account { fail("the account changed") }
        }
        if !now.silentItems.subtracting(was.silentItems).isEmpty { fail("a silent custody item appeared") }
        if !now.touchIDItems.subtracting(was.touchIDItems).isEmpty { fail("a Touch ID item appeared") }
        if !statedLimit {
            if was.gate != .touchID, now.gate == .touchID { fail("the gate style became Touch ID") }
            if was.scheduledExport == false, now.scheduledExport == true { fail("the scheduled export turned on") }
        }
        return violations
    }

}
