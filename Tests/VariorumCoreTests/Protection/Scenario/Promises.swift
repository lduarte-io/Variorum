//
//  Promises.swift
//  VariorumCoreTests — VX-305 U4: THE THIRTEEN PROMISES (design §4.1), checked
//  after every step — 2's retired-key clause, 3 and 7 once the world settles
//  (propagation done, followers followed).
//
//  The checks rest on one engine, `KeyReach`: from SEEDS (keys, Apple keys,
//  masters, secrets, the vault's wrapped copies a session can fetch) it closes
//  over every key file a device holds — every lock, every history, every
//  anchor and kept anchor — to the library keys reached. Two readers:
//    - THE ATTACKER (promises 2, 8, 13): a login-password holder on the device
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
    /// Masters the reach must not use (an older build's exposure, §8).
    var excludedMasters: Set<Data> = []
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
    func reach(_ seeds: Seeds, files: [KeyFileDocument]) -> [String: StoreKey] {
        var keys: [String: StoreKey] = [:]
        for key in seeds.keys { keys[PF.fp(key)] = key }
        var masters = seeds.masters.filter { !seeds.excludedMasters.contains($0) }
        let wordsKeys = seeds.words.compactMap { wordsKey($0) }
        func pass(_ wrap: StoreKeyEnvelope.PassphraseWrap?) -> [SymmetricKey] {
            guard let wrap else { return [] }
            return seeds.passphrases.compactMap { passphraseKey($0, wrap.kdf)?.key }
        }
        func addMaster(_ master: SymmetricKey) {
            let bytes = PF.bytes(master)
            if !seeds.excludedMasters.contains(bytes), !masters.contains(bytes) { masters.append(bytes) }
        }
        var anchorsDone: Set<Data> = []
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
            var anchors: [CastleAnchor] = []
            for document in files {
                switch document {
                case .format3(let file):
                    func open(_ blob: Data?, _ key: SymmetricKey) {
                        guard let blob, let opened = Lock.unwrapStoreKey(blob, under: key), PF.fp(opened) == file.fingerprint else { return }
                        add(opened)
                    }
                    if let wrap = file.apple, let apple = seeds.apple[wrap.keyID] { open(wrap.wrapped, apple) }
                    if let wrap = file.sharedApple, let apple = seeds.apple[wrap.keyID] { open(wrap.wrapped, apple) }
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
                    anchors += [file.anchor].compactMap { $0 } + file.keptAnchors
                case .legacy(let legacy):
                    let envelope = legacy.envelope
                    func open(_ blob: Data?, _ key: SymmetricKey) {
                        guard let blob, let opened = Lock.unwrapStoreKey(blob, under: key) else { return }
                        if let fingerprint = legacy.fingerprint, PF.fp(opened) != fingerprint { return }
                        add(opened)
                    }
                    if let blob = envelope.apple {
                        if let id = envelope.appleKeyID, let apple = seeds.apple[id] { open(blob, apple) }
                    }
                    for master in masters { open(envelope.master, SymmetricKey(data: master)) }
                    for key in pass(envelope.passphrase) { open(envelope.passphrase?.wrapped, key) }
                    for wk in wordsKeys { open(envelope.recovery, wk) }
                }
            }
            // The anchors: by their own locks, by a follower's outgoing key or
            // copied locks; their kept anchors in turn.
            var queue = anchors
            while !queue.isEmpty {
                let anchor = queue.removeFirst()
                guard !anchorsDone.contains(anchor.bundle) else { continue }
                var contents: AnchorContents?
                if let outgoing = keys[anchor.outgoingFingerprint] { contents = try? anchor.open(outgoingKey: outgoing) }
                if contents == nil, let wrap = anchor.locks.passphrase {
                    for p in seeds.passphrases {
                        if let pk = passphraseKey(p, wrap.kdf), let opened = try? anchor.open(.passphraseKey(pk), floor: PF.floor) {
                            contents = opened
                            break
                        }
                    }
                }
                if contents == nil, anchor.locks.words != nil {
                    for words in seeds.words { if let opened = try? anchor.open(.words(words), floor: PF.floor) { contents = opened; break } }
                }
                if contents == nil, anchor.locks.outgoingKey != nil, let copied = anchor.locks.copiedLocks {
                    var outgoing: StoreKey?
                    if let wrap = copied.passphrase {
                        for key in pass(wrap) { if let o = Lock.unwrapStoreKey(wrap.wrapped, under: key) { outgoing = o } }
                    }
                    if outgoing == nil, let blob = copied.words { for wk in wordsKeys { outgoing = outgoing ?? Lock.unwrapStoreKey(blob, under: wk) } }
                    if outgoing == nil, let blob = copied.master {
                        for master in masters { outgoing = outgoing ?? Lock.unwrapStoreKey(blob, under: SymmetricKey(data: master)) }
                        if outgoing == nil, let copy = copied.masterWordsCopy {
                            for wk in wordsKeys {
                                if let master = Lock.unwrap(copy, under: wk) {
                                    outgoing = outgoing ?? Lock.unwrapStoreKey(blob, under: SymmetricKey(data: master))
                                }
                            }
                        }
                    }
                    if let outgoing, PF.fp(outgoing) == anchor.outgoingFingerprint {
                        add(outgoing)
                        contents = try? anchor.open(outgoingKey: outgoing)
                    }
                }
                guard let contents else { continue }
                anchorsDone.insert(anchor.bundle)
                changed = true
                for held in contents.keys { add(held.key) }
                queue += contents.keptAnchors
            }
        }
        return keys
    }

    // MARK: - What a device holds

    /// Every key file on a device: its container, its far folder, its Time
    /// Machine snapshots.
    func keyFilesOn(_ device: SDevice, excluding exclude: (String, KeyFileDocument) -> Bool = { _, _ in false }) -> [KeyFileDocument] {
        var documents: [KeyFileDocument] = []
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
        let oldSharedStanding = section?.oldSharedKeyStillStanding ?? false
        for item in items where !item.touchID {
            switch item.value {
            case .key(let key): seeds.keys.append(key)
            case .syncKeys(let material), .legacySync(_, let material?): seeds.masters.append(material.masterKey)
            case .apple(let id, let bytes):
                // A deliberate delete that never reached iCloud (P-U4-1).
                if truth.deletesNotCarried.contains(id) { continue }
                // §3.1 rule 2's first exception: the old shared key, until
                // this device's section records it retired.
                if oldSharedStanding, id == section?.oldSharedKey?.id { continue }
                // A retirement holds everywhere once iCloud Keychain carries
                // it (the retired-key clause — once the world settles; and
                // while this Mac's switch is off, the stated exception).
                if retired.contains(id), !settled || !device.iCloudOn { continue }
                if let shared = section?.oldSharedKey, shared.retiredAt != nil, shared.id == id, !settled || !device.iCloudOn { continue }
                seeds.apple[id] = SymmetricKey(data: bytes)
            default: break
            }
        }
        if let account = device.library?.record?.account, device.session.accountID == account,
           let vault = server.snapshot(account) {
            seeds.vaults.append(vault.format)
        }
        seeds.excludedMasters = truth.olderExposedMasters
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
            case .syncKeys(let material), .legacySync(_, let material?): seeds.masters.append(material.masterKey)
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
        for device in devices where device.build == .new {
            violations += known(device)
            violations += castleMeansCastle(device, settled: settled)
            violations += castleStaysCastles(device, settled: settled)
            violations += crashSafe(device)
            if settled {
                violations += standardMeansStandard(device)
                violations += converges(device)
            }
        }
        violations += vaultInvariant()
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
        if memory.currentFingerprint != record.currentFingerprint || memory.keyEpoch != record.keyEpoch {
            return [Violation(promise: 1, device: device.name,
                              detail: "the memory names \(f8(memory.currentFingerprint))#\(memory.keyEpoch), the record \(f8(record.currentFingerprint))#\(record.keyEpoch)")]
        }
        // …and THE KEY FILE agrees (§3.3's "Always: the record, what this Mac
        // remembers and the key file agree" — VX-305 ladder round 1, the final
        // call §1(c)): with nothing in flight and no repair owed that would
        // bring the current key's own file back, the live place's format-3
        // file IS the record's current key's. Keyed on "no repair owed", so a
        // repair pending its run passes, and a state no repair can leave (the
        // round-1 wedge) fails. Stated residue: PROVISIONAL P-R1-1 — no
        // catalogued frozen copy of the current key's file to restore from
        // (the honest refusal stands).
        if liveKeyFile(device)?.fingerprint != record.currentFingerprint {
            let assessment = assessed(device)
            let owed = assessment.repairs.contains { repair in
                switch repair {
                case .restoreKeyFileFromCopy, .restoreKeyFileFromMirror, .rekeyOlderLibraryFile: return true
                default: return false
                }
            }
            let copyExists = catalog(device).keyFiles.contains { file in
                if case .format3(let keyFile)? = file.document {
                    return keyFile.fingerprint == record.currentFingerprint && keyFile.libraryID == record.libraryID
                }
                return false
            }
            if !owed, copyExists {
                return [Violation(promise: 1, device: device.name,
                                  detail: "the live key file is \(liveKeyFile(device).map { f8($0.fingerprint) } ?? "absent"), the record's key \(f8(record.currentFingerprint)) — and no repair brings its own file back")]
            }
        }
        return []
    }

    /// PROMISES 2 and 8 — Castle means Castle; the posture law.
    func castleMeansCastle(_ device: SDevice, settled: Bool) -> [Violation] {
        guard let library = device.library, library.section.actInFlight == nil, let record = device.slot?.record,
              record.mode == .castle, record.modeConfirmed else { return [] }
        var violations: [Violation] = []
        func fail(_ detail: String, _ promise: Int = 2) { violations.append(Violation(promise: promise, device: device.name, detail: detail)) }
        let tree = Set(library.familyTree.fingerprints).union([record.currentFingerprint])
        // A Time Machine rollback past a leave (her act): the later Standard
        // stretch's key — born after the restored current key — keeps its
        // silent item; it holds only what was Apple-reachable by design
        // (PROVISIONAL P-U4-8).
        // (A Standard key the restored record never knew is one born after it.)
        func laterStandard(_ fingerprint: String) -> Bool {
            guard let entry = library.familyTree.entry(fingerprint), entry.kind == .standard else { return false }
            return !record.familyTree.contains(fingerprint)
        }
        for name in device.keychain.local.keys where name.service == ProtectionNames.custodyService {
            if let item = device.keychain.local[name], !item.touchID, let key = item.value.libraryKey, tree.contains(PF.fp(key)),
               !laterStandard(PF.fp(key)) {
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
        if let live = liveKeyFile(device), live.fingerprint == record.currentFingerprint, live.apple != nil || live.sharedApple != nil {
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
        let exempt = truth.handedOffBeforeChange.union(truth.olderBuildLeaveKeys)
        if attacker[record.currentFingerprint] != nil, !exempt.contains(record.currentFingerprint) {
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
            if truth.rolledBackOver.contains(id) || laterStandard(image.fingerprint) { continue }
            // A key a login-password holder already held in Standard (rule 3)
            // and tampered with there: entering Castle protects what's written
            // after (promise 8), never undoes what they took before.
            if truth.tamperedStandard[device.name]?.contains(image.fingerprint) == true { continue }
            if attacker[image.fingerprint] != nil, !exempt.contains(image.fingerprint), !truth.listedBySheet.contains(id) {
                fail("a login-password holder opens the copy \(id) (\(f8(image.fingerprint)))")
            }
        }
        return violations
    }

    /// PROMISE 13 — what Castle wrote stays Castle's, in its copies: after a
    /// leave, nothing the Apple account or a login-password holder can reach
    /// opens a copy made before the leave, or any key made in Castle.
    func castleStaysCastles(_ device: SDevice, settled: Bool) -> [Violation] {
        guard let library = device.library, library.section.actInFlight == nil, let record = device.slot?.record,
              record.mode == .standard, let kept = truth.keptByLeave[device.name], !kept.isEmpty else { return [] }
        let attacker = reach(attackerSeeds(device, appleAccount: true, settled: settled), files: keyFilesOn(device))
        var exempt = truth.handedOffBeforeChange.union(truth.olderBuildLeaveKeys)
        // A key a login-password holder already held in Standard (rule 3) and
        // tampered with there: the later crossings protect what's written
        // after, never undo what they took before (promise 2 reads it the same
        // way — the closer's soak, seed 6 sequence 916).
        exempt.formUnion(truth.tamperedStandard[device.name] ?? [])
        // A Standard pair another Mac sent here is THAT Mac's own copy, under
        // its own key and its own Apple key (rule 3, its library's) — no copy
        // this device made, and no key made in Castle (promise 2 reads "made on
        // this Mac" the same way). Its key rides this library's family tree
        // only so the landing's own line reads as its own (the closer's soak,
        // seed 2 sequence 661). …and so does every key that pair's own key
        // file reaches by its own locks — its history (the sender's earlier
        // keys, taken within Standard): the landed tree carries those too, and
        // the pair (never written here, keeping its own locks — §3.7) opens
        // them through the sender's own Apple key. The sender's Standard copy
        // in its day, exactly what a restored Standard state reached
        // (`reachableInItsDay` — never an anchor's); still no copy this device
        // made and no key made in Castle (VX-305 ladder round 1, NEW-2). Read
        // by the pair's IDENTITY, recorded at the send — never by its folder:
        // this device's own Send Library the same day can overwrite the
        // folder (and the folder → sender map), while a Time Machine snapshot
        // still holds the sender's pair (NEW-2's second road).
        exempt.formUnion(truth.sentStandardPairReach[device.name] ?? [])
        // §3.1 rule 2's second exception: the Standard-synced days' keys, until
        // that account replaces its keys or enters Castle.
        // (On a device that hasn't yet followed the account past them, its
        // held sync keys still name that corpus key — rule 2: "after that
        // device follows".)
        var held = Set<String>()
        for item in device.keychain.local.values {
            switch item.value {
            case .syncKeys(let m), .legacySync(_, let m?): held.insert(m.corpusKeyID)
            default: break
            }
        }
        for m in device.sessionMemory.values { held.insert(m.corpusKeyID) }
        var exceptionHolds = false
        for (fingerprint, synced) in truth.standardSynced
        where server.snapshot(synced.account)?.corpusKeyID == synced.corpusKeyID || held.contains(synced.corpusKeyID) {
            exempt.insert(fingerprint)
            exceptionHolds = true
        }
        // While the exception holds, what the account's master reaches — a
        // Standard-days key file's master lock and the history behind it — is
        // the exception's; the attacker's other roads are judged alone.
        var seeds = attackerSeeds(device, appleAccount: true, settled: settled)
        if exceptionHolds { seeds.masters = []; seeds.vaults = [] }
        let withoutAccount = exceptionHolds ? reach(seeds, files: keyFilesOn(device)) : attacker
        var violations: [Violation] = []
        for fingerprint in kept.sorted() where attacker[fingerprint] != nil && withoutAccount[fingerprint] != nil && !exempt.contains(fingerprint) {
            violations.append(Violation(promise: 13, device: device.name, detail: "the Apple account or the login password reaches \(f8(fingerprint)), a key from before the leave"))
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
              record.mode == .standard, record.modeConfirmed else { return [] }
        if truth.tamperedStandard[device.name]?.contains(record.currentFingerprint) == true { return [] }
        // Decision 35: a synced library writes nothing Apple-reachable without
        // a fresh read of its account's vault — signed out, in another account
        // or offline, its own Apple key waits (Re-link's library arm too).
        if let account = record.account, device.session.accountID != account || !device.online { return [] }
        // A synced pair landed HELD writes nothing Apple-reachable until the
        // one Resume Sync press reads its account's vault (§3.7, the restore
        // hold) — as promise 7 already waits for it.
        if truth.heldLanding[device.name] == record.libraryID { return [] }
        guard let live = liveKeyFile(device), live.fingerprint == record.currentFingerprint, let wrap = live.apple else {
            return [Violation(promise: 3, device: device.name, detail: "no Apple wrap of the current key")]
        }
        let own = library.section.appleKeys.contains { $0.id == wrap.keyID && $0.isOwnLibraryKey && $0.retiredAt == nil }
        guard own, readableAppleKeys(device)[wrap.keyID] != nil else {
            return [Violation(promise: 3, device: device.name, detail: "the Apple wrap isn't under this Mac's own readable key")]
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
        // A synced pair landed held: no sync round until Resume Sync.
        if truth.heldLanding[device.name] == record.libraryID { return [] }
        var violations: [Violation] = []
        if let mode = vault.mode.settled, mode != record.mode {
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

    /// §3.9 — no Castle-era corpus key ever sits under anything Apple-
    /// reachable: an Apple wrap never beside a Castle-era previous corpus key,
    /// and never over a Castle-era master (an older build's leave excepted).
    func vaultInvariant() -> [Violation] {
        var violations: [Violation] = []
        for (id, account) in server.accounts.sorted(by: { $0.key < $1.key }) where account.format.masterWrappedByAppleHeld != nil {
            if let previous = account.format.previousCorpusKey, truth.castleCorpusKeyIDs.contains(previous.keyID),
               !truth.olderBuildLeaveKeys.contains(previous.keyID) {
                violations.append(Violation(promise: 2, device: "vault \(id.prefix(8))", detail: "an Apple wrap beside a Castle-era previous corpus key"))
            }
            if let corpus = account.format.classKey(for: .corpus)?.keyID, truth.castleCorpusKeyIDs.contains(corpus),
               !truth.olderBuildLeaveKeys.contains(corpus) {
                violations.append(Violation(promise: 2, device: "vault \(id.prefix(8))", detail: "an Apple wrap over a Castle-era master"))
            }
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
            if truth.listedBySheet.contains(id) { continue }
            if copy.byOlderBuild, truth.olderWhenRetired.contains(device.name) { continue }
            let reached = reachCache[device.name] ?? reach(herSeeds(device), files: keyFilesOn(device))
            reachCache[device.name] = reached
            if reached[image.fingerprint] != nil { continue }
            // A Standard copy made with no passphrase or words, once its own
            // Apple key and this Mac's are both gone (promise 5's exception):
            // every key file here holding its key is secretless, a key that
            // wrapped it was LOST (an Apple-ID switch, a reset, a wiped
            // keychain), and none that wraps it reads here now.
            let holders = keyFilesOn(device).filter { document in
                switch document {
                case .format3(let file): return file.fingerprint == image.fingerprint
                case .legacy(let legacy): return legacy.fingerprint == image.fingerprint
                }
            }
            let ids = holders.flatMap { document -> [String] in
                switch document {
                case .format3(let file): return [file.apple?.keyID, file.sharedApple?.keyID].compactMap { $0 }
                case .legacy(let legacy): return [legacy.envelope.apple == nil ? nil : legacy.envelope.appleKeyID].compactMap { $0 }
                }
            }
            let readable = Set(readableAppleKeys(device).keys).union([oldSharedKey(device)?.id].compactMap { $0 })
            // "Gone" includes a key her own Use Castle retired, once she
            // restored the container past it by Time Machine (the newer key
            // file whose history held this copy's key went with the restore —
            // PROVISIONAL P-U4-13).
            var retiredHere: Set<String> = []
            if truth.restoredPastCrossing.contains(device.name) {
                retiredHere = device.library?.section.retiredAppleKeyIDs ?? []
                for item in device.keychain.local.values {
                    if case .memory(let sealed) = item.value,
                       let memory = try? ProtectionCoding.decoder().decode(DeviceMemory.self, from: sealed.payload) {
                        retiredHere.formUnion(memory.deviceSection.retiredAppleKeyIDs)
                    }
                }
            }
            let lost = truth.lostAppleKeys
            let gone = { (id: String) in lost.contains(id) || retiredHere.contains(id) }
            if !holders.isEmpty, holders.allSatisfy(secretless), ids.contains(where: gone),
               !ids.contains(where: readable.contains) { continue }
            // §3.5a's residue (promise 5's last exception): a silently-joined
            // device's file — its library key under a master and no passphrase
            // or words lock, its Apple roads gone — whose master the account
            // has since replaced, no words copy her words open beside it: "only
            // the server brings its writing back, and its unsynced edits are
            // lost" (the closer's soak, seed 3 sequence 211 — the device had
            // migrated signed out, so no vault read ever gave it the copy).
            let masterOnly = holders.allSatisfy { document in
                switch document {
                case .format3(let file): return file.passphrase == nil && file.words == nil && file.master != nil
                case .legacy(let legacy):
                    return legacy.envelope.passphrase == nil && legacy.envelope.recovery == nil && legacy.envelope.master != nil
                }
            }
            if truth.silentlyJoined.contains(device.name), !holders.isEmpty, masterOnly, server.accounts[copy.holder] != nil,
               !ids.contains(where: readable.contains) { continue }
            violations.append(Violation(promise: 5, device: device.name, detail: "the copy \(id) (\(f8(image.fingerprint))) opens by no road"))
        }
        return violations
    }

    /// A key file with no passphrase, words or master lock whose Apple keys
    /// are all gone (an Apple-ID switch, an iCloud Keychain reset).
    func secretless(_ document: KeyFileDocument) -> Bool {
        switch document {
        case .format3(let file): return file.passphrase == nil && file.words == nil && file.master == nil
        case .legacy(let legacy):
            return legacy.envelope.passphrase == nil && legacy.envelope.recovery == nil && legacy.envelope.master == nil
        }
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
        var confirmed: Bool?
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
            libraryID: device.slot?.libraryID, mode: record?.mode, confirmed: record?.modeConfirmed, account: record?.account,
            fingerprint: record?.currentFingerprint, gate: section?.settings.gateStyle,
            scheduledExport: section?.settings.scheduledExport, silentItems: silent, touchIDItems: touch)
    }

    /// PROMISE 4 — no silent change: the mode and the account change only at
    /// a deliberate act or its follow; a copy never lowers the mode or brings
    /// its own key.
    func noSilentChange(_ action: Action, before: [String: Posture], crashedBefore: Set<String>) -> [Violation] {
        var violations: [Violation] = []
        for device in devices where device.build == .new {
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
        case .cloneMac(_, let d): return d == name
        case .useCastle(let d, _, _), .useStandard(let d), .follow(let d, _), .finishLeave(let d, _), .turnOnSync(let d),
             .move(let d), .thisMacOnly(let d, _), .stopSyncingHere(let d, _), .deleteAccountHere(let d), .resumeSync(let d),
             .answerCorner45(let d, _), .confirmMode(let d), .land(let d, _), .openOlderLibrary(let d), .replaceAllKeys(let d, _),
             // A copy that raises runs Use Castle at its confirm (§3.7); a
             // lowering or a copy's own key is the opens' check below.
             .restoreBackup(let d, _):
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
    /// 1): the same claims, the group drawn so it never takes the stated
    /// limit's shape (`ScenarioGenerator.rollsBackBothHomes`) — except a group
    /// that holds `.replayBothHomes` itself (a fixed scenario's).
    func sealed(_ device: SDevice, before was: Posture, tampers: [Tamper]) -> [Violation] {
        guard was.mode == .castle, was.confirmed == true else { return [] }
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

    /// PROMISE 12 — moving adds: the copies she could open before the move
    /// she can open after.
    func openableCopies(_ device: SDevice) -> Set<String> {
        let reached = reach(herSeeds(device), files: keyFilesOn(device))
        return Set(imagesOn(device).filter { reached[$0.image.fingerprint] != nil }.map(\.id))
    }

    /// PROMISE 9 — honest words: every road an *Opens with* line names opens
    /// the copy (walked with the real secret of the day it names).
    func honestWords(_ device: SDevice) -> [Violation] {
        guard device.isOpen, let library = device.library, library.section.actInFlight == nil, library.record != nil else { return [] }
        let assessment = assessed(device)
        let catalog = catalog(device)
        var violations: [Violation] = []
        let apple = readableAppleKeys(device)
        var custody: [String: StoreKey] = [:]
        for name in device.keychain.names(service: ProtectionNames.custodyService) {
            if let item = device.keychain.item(name), let key = item.value.libraryKey { custody[PF.fp(key)] = key }
        }
        for name in device.keychain.names(service: LegacyItems.storeKeyService) {
            if let item = device.keychain.item(name), !item.touchID, let key = item.value.libraryKey { custody[PF.fp(key)] = key }
        }
        // The master as the vault was READ this session (the line was computed
        // from that reading — the account moving on since is promise 7's).
        let vaultAccount = device.session.accountID ?? library.record?.account
        var masters: [SymmetricKey?] = [vaultAccount.flatMap { todayMaster($0) }]
        if let account = vaultAccount, let read = device.executor?.freshVaults[account] {
            for p in known(account).timeline.compactMap(\.passphrase) {
                if let pk = passphraseKey(p, read.format.kdf), let m = try? read.format.unwrapMaster(withPassphraseKey: pk.key) {
                    masters.append(m)
                    break
                }
            }
        }
        for copy in catalog.copies {
            guard let opens = assessment.opensWith[copy.id], let truthCopy = truth.copies[copy.id] else { continue }
            let holder = truthCopy.holder
            let slotK = slotHolder(device).map(known) ?? Known()
            // Every holder this device's library has had: its own (before or
            // after an account), the account's, the copy's.
            var k = known(holder)
            let own = known(self.holder(device, account: nil, libraryID: library.record?.libraryID ?? ""))
            // The copy's OWN library's secrets on this device — the slot may
            // hold another library now (a landing set this one aside), and an
            // anchor written at its leave is locked with its own secrets of
            // that day (the closer's soak, seed 4 sequence 410).
            let copyOwn = known(self.holder(device, account: nil, libraryID: truthCopy.libraryID))
            k.timeline += own.timeline + slotK.timeline + copyOwn.timeline
            // A frozen key file's own locks are what the Mac that froze it held
            // that library under — any holder of a copy of that library (two
            // copies of one key serve each other's lines).
            for other in Set(truth.copies.values.filter { $0.libraryID == truthCopy.libraryID }.map(\.holder)) where other != holder {
                k.timeline += known(other).timeline
            }
            // An Apple key this Mac lists as its own and can't read names the
            // former account that still opens it (§3.1 rule 2's last
            // exception) — a road elsewhere, by its own words, never here.
            for route in opens.routes where route.opener != .appleKeyNotReadableHere {
                var book = SecretBook(custody: custody, apple: apple, oldShared: oldSharedKey(device), vaultMaster: masters.first ?? nil)
                var candidates: [SecretBook] = []
                // `.current` is "the secret that opens the live key file's own
                // lock" (the route finder's definition) — on a device whose
                // local copy lags a change made elsewhere, that's the secret it
                // still holds, beside the account's newest (the vault road).
                // A synced pair landed held keeps its own secrets (made new at
                // the landing) until Resume Sync: the library's own holder too.
                let livePassphrases = Array(Set(slotK.timeline.compactMap(\.passphrase) + [slotK.passphrase, own.passphrase].compactMap { $0 }))
                // `.current` words also name a master words copy equal to the
                // vault's recovery wrap AS THIS SESSION READ IT — the account's
                // words of that read (a reading the account has since moved past).
                let sessionAccount = device.session.accountID.map(known) ?? Known()
                let liveWords = slotK.timeline.compactMap(\.words) + [slotK.words, own.words].compactMap { $0 }
                    + sessionAccount.timeline.compactMap(\.words)
                switch route.opener {
                case .passphrase(.current):
                    for p in livePassphrases { var b = book; b.passphrases[.current] = p; candidates.append(b) }
                case .words(.current):
                    for w in liveWords { var b = book; b.words[.current] = w; candidates.append(b) }
                // A day the library changed hands (a join, a landing): the
                // secrets of that day are the copy's holder's AND the slot's.
                // (…or an account's that day: an anchor written at a leave is
                // locked with the account's secrets as typed then.)
                case .passphrase(.of(let date)):
                    let accounts = server.accounts.keys.map { known($0).at(date).passphrase }
                    for p in ([known(holder).at(date).passphrase, slotK.at(date).passphrase, own.at(date).passphrase,
                               copyOwn.at(date).passphrase] + accounts).compactMap({ $0 }) {
                        var b = book; b.passphrases[.of(date)] = p; candidates.append(b)
                    }
                case .words(.of(let date)):
                    let accounts = server.accounts.keys.map { known($0).at(date).words }
                    for w in ([known(holder).at(date).words, slotK.at(date).words, own.at(date).words,
                               copyOwn.at(date).words] + accounts).compactMap({ $0 }) {
                        var b = book; b.words[.of(date)] = w; candidates.append(b)
                    }
                default: break
                }
                switch route.opener {
                case .passphrase(let day):
                    switch day {
                    case .current: book.passphrases[day] = slotK.passphrase
                    case .of(let date): book.passphrases[day] = known(holder).at(date).passphrase ?? slotK.at(date).passphrase
                    case .heldHere: for p in k.timeline.compactMap(\.passphrase) + slotK.timeline.compactMap(\.passphrase) { var b = book; b.passphrases[day] = p; candidates.append(b) }
                    }
                case .words(let day):
                    switch day {
                    case .current: book.words[day] = slotK.words
                    case .of(let date): book.words[day] = known(holder).at(date).words ?? slotK.at(date).words
                    case .heldHere: for w in k.timeline.compactMap(\.words) + slotK.timeline.compactMap(\.words) { var b = book; b.words[day] = w; candidates.append(b) }
                    }
                default: break
                }
                if candidates.isEmpty { candidates = [book] }
                candidates += candidates.flatMap { b in masters.dropFirst().map { var c = b; c.vaultMaster = $0; return c } }
                let opened = candidates.contains { (try? walk(route, in: catalog, book: $0)).map { PF.fp($0) == copy.fingerprint || copy.candidateFingerprints.contains(PF.fp($0)) } == true }
                if !opened {
                    violations.append(Violation(promise: 9, device: device.name, detail: "\(copy.id)'s line names \(route.opener), which doesn't open it"))
                }
            }
        }
        return violations
    }
}
