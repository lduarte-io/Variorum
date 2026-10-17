//
//  Promises.swift
//  VariorumCoreTests — VX-378 U4: THE PROMISES, rewritten to `notes/CastleRules.md`
//  (VX-305's thirteen, cut at U1, rewritten here — each quotes its rule):
//
//    1 ONE POSTURE (rules 9, 11, 13) — while the library is in Castle, no quiet
//      road reaches its current key, any earlier key, or any copy of it.
//    2 STANDARD HANDS EVERYTHING OUT (rules 8, 12) — in Standard the current
//      key opens by this Mac's quiet roads, re-made at the open (settled).
//    3 THE ACCOUNT IS ONE POSTURE (rules 10, 14, 15) — while the account is in
//      Castle no quiet road holds the key its rows are written under; a device
//      holding that key has followed; the account keeps every sync key it has
//      had; every device ends in the account's posture (settled).
//    4 THE FLOOR (rules 4, 5, 6, 7, 12 — her ruling at the U4 stop,
//      2026-10-17) — every copy opens with the passphrase and words she had
//      when she made it; on a device that has caught up, her current ones
//      open the library; and every key change carries the earlier keys
//      forward, so her current ones open older copies of the same library
//      (never across a new library: Make this my library carries no keys).
//    5 EVERY COPY OPENS BY SOME ROAD (rules 1, 27, 19) — or the refusal names
//      what would have; copies leave only by her or this Mac's own retention.
//    6 CRASH SAFE (rule 20) — strict: nothing left half-done, and the open says
//      which.
//    7 FOUR THINGS; A DISAGREEMENT IS NOTICED AND SAID (rules 21, 23 — her
//      ruling at the U4 stop, 2026-10-17) — what this Mac remembers matches the
//      live place; when the library there isn't the one this Mac last opened,
//      the open goes on, says so once (her words) and the memory follows;
//      nothing changes posture, account or roads silently (promise 9).
//    8 DELETED ONLY AFTER REPLACEMENT (rule 22) — no delete leaves the library
//      in the live place with no road of hers.
//    9 NOTHING SILENT (the kept core of VX-305's promise 10; rule 17) — the
//      posture, the account and the roads change only at a deliberate act, or
//      at an open that said rule 21's notice; in Castle no tampered file or
//      item changes them silently; Look inside writes nothing; Make this my
//      library keeps the posture of now.
//
//  NO PROMISE is made about pre-leave copies after a leave: one posture at a
//  time (rules 12, 13 — her 2026-10-16 ruling; a reviewer proposing one is
//  pointed at CastleRules's considered-and-not-pursued list).
//
//  THE STATED LIMITS (each with its pointer, each read where it applies):
//    L1 rule 10 — a device that has not followed reads its own copy through its
//       own quiet road (it is still Standard; promise 1 is the followers').
//    L2 rule 25 — Apple's roads are Apple's: a key left in an Apple account she
//       has since left keeps its lock (FD-2), and a delete made while iCloud
//       Keychain's switch is off reaches iCloud only when it's on.
//    L3 rule 3 — a login-password holder's tamper in Standard: they hold the key
//       (until a key change mints one past them).
//    L4 THE ROLLBACK (P-U4-5, her ruling 2026-10-14/15 "accept and state it";
//       P-U4-12): the library file and its key file returned to an earlier
//       moment while what this Mac remembers is gone or returned with them (a
//       Time Machine restore, a hand restore over a wiped keychain, a complete
//       replay) put the Mac back in that moment, its secrets of that day with it;
//       copies made after it are the later stretch's.
//    L5 rules 17, 18 — a key carried in from another library's copy keeps that
//       library's own quiet roads (another Mac's own Apple key is never deleted
//       here — §3.5's delete-on-sight-by-recorded-id).
//    L6 rule 21 — A LIBRARY PUT IN THE LIVE PLACE FROM OUTSIDE (her ruling at the
//       U4 stop: "they have to just remember that at that point"; P-VX378-U4-2
//       CLOSED as outside the promise): a replayed or hand-copied library file,
//       or one an open said the notice for, is read in its own day — its posture
//       until it follows, the secrets it was made with — and beside a key file
//       that reaches it only through its history (the split pair, P-VX378-U4-6)
//       it has no Apple road and no follow until the pair is whole again.
//
//  The checks rest on one engine, `reach`: from SEEDS (keys, Apple keys,
//  masters, secrets, the vault's wrapped copies a session can fetch) it closes
//  over key files — every lock, every history — to the library keys reached.
//  Two readers: THE ATTACKER (promise 1 — a login-password holder on the device,
//  every keychain item but a Touch ID item's secret, every file, and the Apple
//  account's iCloud Keychain, minus L2's exceptions) and HER OWN ROADS (promises
//  5, 8 — her finger, her items, her secrets of every day, her Apple keys, the
//  vault through her secrets).
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
    var vaults: [AccountVault] = []
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
                // The vault opens by the passphrase and the words only — never
                // by Apple (rule 14).
                let before = masters.count
                for p in seeds.passphrases {
                    if let pk = passphraseKey(p, vault.kdf), let master = vault.master(passphrase: pk, words: nil) { addMaster(master) }
                }
                for wk in wordsKeys { if let master = vault.master(passphrase: nil, words: WordsKey(key: wk)) { addMaster(master) } }
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
            case .syncKeys(let material): seeds.masters.append(material.master)
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
            seeds.vaults.append(vault.vault)
        }
        return seeds
    }

    /// HER roads on `device`: everything she holds, every secret she has ever
    /// had for the libraries and accounts it touches, the vault through them.
    func herSeeds(_ device: SDevice, inHand: Bool = true) -> Seeds {
        var seeds = Seeds()
        for item in Array(device.keychain.local.values) + device.keychain.synced.values.compactMap(\.item) {
            guard let value = pressRead(device, item) else { continue }
            switch value {
            case .key(let key): seeds.keys.append(key)
            case .syncKeys(let material): seeds.masters.append(material.master)
            case .apple(let id, let bytes): seeds.apple[id] = SymmetricKey(data: bytes)
            default: break
            }
        }
        if inHand {
            for material in device.sessionMemory.values { seeds.masters.append(material.master) }
            if let library = device.library { seeds.keys.append(library.key) }
        }
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
            if let vault = server.snapshot(account) { seeds.vaults.append(vault.vault) }
        }
        return seeds
    }


    // MARK: - The checks

    /// Every promise that applies after a step. `settled`: the world has just
    /// settled (propagation done, followers followed) — the clauses that need
    /// it are checked too.
    func checkPromises(settled: Bool) -> [Violation] {
        noteAccountRowKeys()
        var violations: [Violation] = []
        for device in devices {
            violations += onePosture(device, settled: settled)
            if settled { violations += standardHandsEverythingOut(device) }
            violations += coreSentence(device)
            violations += crashSafe(device)
            violations += fourThings(device)
        }
        violations += accountOnePosture(settled: settled)
        violations += everyCopyOpens()
        violations += foundAtTheWrite()
        return violations
    }

    /// Whose secrets, the moment and its day's secrets — L4's (the rollback).
    func dayOfRollback(_ device: SDevice) -> (passphrase: String?, words: [String]?)? {
        guard let limit = truth.statedLimit[device.name] else { return nil }
        if device.slot?.fingerprint != limit.fingerprint, device.slot != nil,
           !(liveKeyFile(device)?.heldFingerprints.contains(limit.fingerprint) ?? false) {
            truth.statedLimit[device.name] = nil
            return nil
        }
        return known(limit.holder).at(limit.at)
    }

    /// PROMISE 1 — ONE POSTURE (rules 9, 11, 13): "Castle is one promise: no
    /// quiet road through Apple, ever, on any device of the account" (9);
    /// "Entering Castle … the Apple and on-device keychain items deleted … your
    /// Standard-era backups' quiet locks die with it" (11); "A Castle-era backup
    /// is protected while your library is in Castle" (13). While the library is
    /// in Castle no road that opens without a typed secret or a Touch ID press
    /// reaches its current key, any key its key file carries, or any copy of it.
    func onePosture(_ device: SDevice, settled: Bool) -> [Violation] {
        guard let library = device.library, library.section.actInFlight == nil, let record = device.slot?.record,
              record.mode == .castle else { return [] }
        // ONE POSTURE PER ACCOUNT (her 2026-10-16 ruling): once the account has
        // left Castle, "your text, the server's rows, the sync key and every
        // backup you have ever made are Standard from now on" (rule 12) — a
        // device that hasn't followed out yet holds no Castle promise the account
        // gave up (its quiet follow out is owed).
        if let account = record.account, server.snapshot(account)?.mode == .standard { return [] }
        // L6: a library put back in the live place from outside (an old Castle
        // copy over a later Standard stretch) is in its own day — a later leave
        // handed its keys out (rule 12), and putting the copy back doesn't take
        // them in again.
        if fromOutside(device) { return [] }
        var violations: [Violation] = []
        func fail(_ detail: String) { violations.append(Violation(promise: 1, device: device.name, detail: detail)) }
        // The key file beside the library — when it is this library's (a stray
        // of another library's, put there from outside, names keys this library
        // never had — census seed 25 sequence 367).
        let live = liveKeyFile(device).flatMap { $0.libraryID == record.libraryID ? $0 : nil }
        // The keys the library has had: the live key file's current key and
        // history (rule 4). A rollback past a leave (L4) leaves the later
        // Standard stretch's keys out of the restored file.
        let tree = Set(live?.heldFingerprints ?? []).union([record.currentFingerprint])
        let tampered = truth.tamperedStandard[device.name] ?? []  // L3
        for name in device.keychain.local.keys where name.service == ProtectionNames.custodyService {
            if let item = device.keychain.local[name], !item.touchID, let key = item.value.libraryKey, tree.contains(PF.fp(key)),
               !tampered.contains(PF.fp(key)) {
                fail("a silent custody item holds \(f8(key)) — rule 11's on-device road kept")
            }
        }
        if let live, live.fingerprint == record.currentFingerprint, live.apple != nil, !tampered.contains(live.fingerprint) {
            fail("an Apple wrap of the current key (rule 9)")
        }
        if settled {
            let readable = Set(readableAppleKeys(device).keys)
            for id in library.section.retiredAppleKeyIDs where readable.contains(id) && device.iCloudOn {
                fail("a retired Apple key (\(id.prefix(8))) still exists here (rule 11)")
            }
        }
        // THE ATTACKER. This library's own key files take every seed; another
        // library's key file (a copy made hers carried its keys in — L5) only
        // the Apple keys this Mac made itself, so another library's own roads
        // stay that library's.
        let seeds = attackerSeeds(device, appleAccount: true, settled: settled)
        var own = seeds
        let ownApple = Set(library.section.appleKeys.map(\.id)).union([live?.apple?.keyID].compactMap { $0 })
        own.apple = seeds.apple.filter { ownApple.contains($0.key) }
        let files = keyFilesOn(device) + mirrors(device)
        let mine = files.filter { $0.libraryID == record.libraryID }
        var reached = reach(seeds, files: mine)
        reached.merge(reach(own, files: files)) { a, _ in a }
        for fingerprint in tree.sorted() where reached[fingerprint] != nil && !tampered.contains(fingerprint) {
            fail("a quiet road reaches \(fingerprint == record.currentFingerprint ? "the current key" : "an earlier key") \(fingerprint.prefix(8))")
        }
        for (id, image) in imagesOn(device) where image.libraryID == record.libraryID && id != "container:\(SPath.slot)" {
            // "any copy … on any device that has followed": a pair another Mac
            // sent here (its own, under its own key) isn't one (L5).
            if let made = truth.copies[id], made.madeOn != device.name, record.account == nil || made.holder != record.account {
                continue
            }
            if senders.contains(where: { id.hasPrefix("container:\($0.key)/") && $0.value != device.name }) { continue }
            if truth.rolledBackOver.contains(id) || tampered.contains(image.fingerprint) { continue }
            if !tree.contains(image.fingerprint), truth.copies[id]?.mode == .standard { continue }  // L4: the later stretch's
            if reached[image.fingerprint] != nil { fail("a quiet road opens the copy \(id) (\(f8(image.fingerprint)))") }
        }
        return violations
    }

    /// PROMISE 2 (settled) — STANDARD HANDS EVERYTHING OUT (rules 8, 12): "the
    /// next open uses whatever quiet road still works and quietly makes a fresh
    /// Apple road" (8); leaving Castle comes "with a fresh Apple road and the
    /// on-device road back" (12). In Standard the current key opens on this Mac
    /// by its Apple road and its on-device item — re-made at the open (rule 8;
    /// the detected lost road no longer excuses it, U2 re-makes it).
    func standardHandsEverythingOut(_ device: SDevice) -> [Violation] {
        guard let library = device.library, library.section.actInFlight == nil, let record = device.slot?.record,
              record.mode == .standard else { return [] }
        if truth.tamperedStandard[device.name]?.contains(record.currentFingerprint) == true { return [] }  // L3
        if splitPair(device) { return [] }  // L6
        // Decision 35: a synced library makes nothing Apple-reachable without a
        // fresh read of a vault in Standard — signed out, elsewhere, offline or
        // lagging (L1, promise 3's), it waits.
        if let account = record.account {
            guard device.session.accountID == account, device.online, server.snapshot(account)?.mode == .standard else { return [] }
        }
        var violations: [Violation] = []
        func fail(_ detail: String) { violations.append(Violation(promise: 2, device: device.name, detail: detail)) }
        guard let live = liveKeyFile(device), live.fingerprint == record.currentFingerprint else {
            return [Violation(promise: 2, device: device.name, detail: "no key file of the current key in the live place")]
        }
        if let wrap = live.apple, let apple = readableAppleKeys(device)[wrap.keyID],
           (try? live.open(apple: apple)).map(PF.fp) == record.currentFingerprint {
        } else {
            fail("the Apple road doesn't open the current key here (rule 8 re-makes it at the open)")
        }
        let item = device.keychain.local[KName.custody(Self.scope, record.currentFingerprint, .silent)]
        if item?.value.libraryKey.map(PF.fp) != record.currentFingerprint {
            fail("no on-device item holds the current key (rule 8)")
        }
        return violations
    }

    /// Every sync key each account has had — read after every step (rule 15).
    func noteAccountRowKeys() {
        for (id, account) in server.accounts {
            truth.accountRowKeys[id, default: []].insert(account.vault.rowKey.keyID)
            truth.accountRowKeys[id, default: []].formUnion(account.vault.earlierRowKeys.keys)
        }
    }

    /// The sync keys a device holds for `account` — its items and its session.
    func heldSyncKeys(_ device: SDevice, _ account: String, quietOnly: Bool = false) -> [AccountKeys] {
        var held: [AccountKeys] = []
        for itemClass in [ProtectionNames.CustodyClass.silent, .touchid] {
            guard let item = device.keychain.local[KName.syncKeys(Self.scope, account, itemClass)] else { continue }
            if quietOnly, item.touchID { continue }
            if let material = item.value.material { held.append(material) }
        }
        if !quietOnly, let session = device.sessionMemory[account] { held.append(session) }
        return held
    }

    /// PROMISE 3 — THE ACCOUNT IS ONE POSTURE (rules 10, 14, 15): "Castle is
    /// account-wide" (10); "The account's shared keys are wrapped by the
    /// passphrase and the twelve words only — never by Apple" (14); "Each row on
    /// the server is sealed under the sync key that was current when it was
    /// written, and the account keeps every sync key it has ever had … while the
    /// account stays in Castle, writing made there is sealed under a key no quiet
    /// road holds, and a device that has not followed cannot sync until it does"
    /// (15).
    func accountOnePosture(settled: Bool) -> [Violation] {
        var violations: [Violation] = []
        for id in server.accounts.keys.sorted() {
            guard let snapshot = server.snapshot(id) else { continue }
            let vault = snapshot.vault
            let current = vault.rowKey.keyID
            func fail(_ device: String, _ detail: String) {
                violations.append(Violation(promise: 3, device: device, detail: "account \(id.prefix(8)): \(detail)"))
            }
            // The account keeps every sync key it has had, each under the
            // current master (her current secrets open the master).
            let had = truth.accountRowKeys[id] ?? []
            let kept = Set(vault.earlierRowKeys.keys).union([current])
            if !had.isSubset(of: kept) { fail("server", "\(had.subtracting(kept).count) sync key(s) it had are gone from the vault") }
            let k = known(id)
            var master: SymmetricKey?
            if let p = k.passphrase, let pk = passphraseKey(p, vault.kdf) { master = vault.master(passphrase: pk, words: nil) }
            if master == nil, let w = k.words, let wk = wordsKey(w) { master = vault.master(passphrase: nil, words: WordsKey(key: wk)) }
            if let master {
                if (try? vault.keys(master: master)) == nil { fail("server", "a sync key doesn't open under the current master") }
            } else {
                fail("server", "her current passphrase and words open no master")
            }
            for device in devices {
                guard let record = device.slot?.record, device.library?.section.actInFlight == nil,
                      device.container.files[SPath.plan] == nil else { continue }
                if vault.mode == .castle {
                    // No quiet road holds the key Castle rows are written under.
                    if heldSyncKeys(device, id, quietOnly: true).contains(where: { $0.rowKey(for: current) != nil }) {
                        fail(device.name, "a silent sync-keys item holds the key Castle rows are written under")
                    }
                    // A device holding that key has followed into Castle — or its
                    // live place holds a library put there from outside, in that
                    // copy's own posture until it follows (L6).
                    if record.account == id, record.mode != .castle, !fromOutside(device),
                       heldSyncKeys(device, id).contains(where: { $0.rowKey(for: current) != nil }) {
                        fail(device.name, "a device that hasn't followed into Castle holds the key Castle rows are written under")
                    }
                }
                // Settled: every device of the account, signed in and online,
                // ends in its posture and holds its current sync key.
                if settled, record.account == id, device.session.accountID == id, device.online, device.isOpen,
                   truth.tamperedStandard[device.name]?.contains(record.currentFingerprint) != true, !splitPair(device) {
                    if record.mode != vault.mode { fail(device.name, "the library is \(record.mode), the account \(vault.mode)") }
                    if !heldSyncKeys(device, id).contains(where: { $0.rowKeyID == current }) {
                        fail(device.name, "it doesn't hold the account's current sync key")
                    }
                }
            }
        }
        return violations
    }

    /// The live place as this Mac remembers it, read without the app: the
    /// memory item's library and key agree with the slot and the key file (an
    /// act in flight between exactly those two keys explains it), or nothing is
    /// remembered for it (L4's road).
    func livePlaceRemembered(_ device: SDevice) -> Bool {
        guard let slot = device.slot else { return false }
        let names = Set(device.keychain.names(service: ProtectionNames.memoryService)
            .compactMap { ProtectionNames.parseMemoryAccount($0.account, scope: Self.scope) })
        guard case .memory(let sealed)? = device.keychain.local[KName.memory(Self.scope, slot.libraryID)]?.value,
              let memory = try? ProtectionCoding.decoder().decode(DeviceMemory.self, from: sealed.payload) else {
            return names.isEmpty || names.contains(slot.libraryID)
        }
        let inFlight = device.library?.section.actInFlight
        let actKeys = Set([inFlight?.fromFingerprint, inFlight?.toFingerprint].compactMap { $0 })
        func agrees(_ fingerprint: String) -> Bool {
            fingerprint == memory.currentFingerprint || (actKeys.contains(fingerprint) && actKeys.contains(memory.currentFingerprint))
        }
        return agrees(slot.fingerprint) && (liveKeyFile(device).map { agrees($0.fingerprint) } ?? true)
    }

    /// PROMISE 4 — THE FLOOR, AND THE CARRY WITHIN THE SAME LIBRARY (rules 4,
    /// 5, 6, 7, 12 — her ruling at the U4 stop, 2026-10-17): "A backup always
    /// opens with the passphrase and words you had when you made it. Every key
    /// change also carries the earlier keys forward, so your current ones open
    /// older backups of the same library" (4); a backup "opens with the
    /// passphrase and words you had when you made it, with your current secrets
    /// through rule 4" (5); re-locking keeps it (6); one pair at a time (7); a
    /// device that lagged "types a secret once to catch up, today's or the one
    /// it had when it last synced" (12). Three clauses:
    ///   (a) THE FLOOR — every copy this Mac made opens, typed, through its own
    ///       key file, with the pair she had when she made it (`CopyTruth
    ///       .madeWith…`, found at the write — `recordMadeWith`).
    ///   (b) CAUGHT UP — on a device in step with its holder (a library of its
    ///       own; or synced, its record following the account's current sync
    ///       key and posture), her current passphrase or words — typed, or
    ///       through the account's vault they open (rule 7) — open the library.
    ///   (c) THE CARRY — where her current secrets open the library (or its
    ///       sealed copy, rule 1), they reach every copy of THIS library this
    ///       Mac made, through it and the copy's own key file. Never across a
    ///       new library (Make this my library carries no keys — her ruling).
    /// (b) and (c) are judged while the live place is the library this Mac
    /// remembers, with nothing in flight.
    func coreSentence(_ device: SDevice) -> [Violation] {
        var violations: [Violation] = []
        func fail(_ detail: String) { violations.append(Violation(promise: 4, device: device.name, detail: detail)) }
        // (a) THE FLOOR — every copy, whatever the live place holds.
        for (id, copy) in truth.copies.sorted(by: { $0.key < $1.key }) where copy.madeOn == device.name {
            guard copy.madeWithPassphrase != nil || copy.madeWithWords != nil,
                  let (fs, path) = DeviceLeaves(world: self, device: device).resolve(id), let image = fs.files[path]?.library,
                  image.fingerprint == copy.fingerprint else { continue }
            var seeds = Seeds()
            seeds.passphrases = [copy.madeWithPassphrase].compactMap { $0 }
            seeds.words = [copy.madeWithWords].compactMap { $0 }
            if reach(seeds, files: [ownKeyFile(fs, path)].compactMap { $0 })[image.fingerprint] == nil {
                fail("the copy \(id) (\(f8(image.fingerprint))) doesn't open with the secrets it was made with")
            }
        }
        guard let slot = device.slot, let record = slot.record, device.container.files[SPath.plan] == nil,
              device.library?.section.actInFlight == nil, livePlaceRemembered(device),
              let holder = slotHolder(device) else { return violations }
        // L3 (rule 3): a login-password holder rewrote this Standard key's file;
        // judged again once a key change mints one past them.
        if truth.tamperedStandard[device.name]?.contains(slot.fingerprint) == true { return violations }
        let k = known(holder)
        var seeds = Seeds()
        seeds.passphrases = [k.passphrase].compactMap { $0 }
        seeds.words = [k.words].compactMap { $0 }
        if let day = dayOfRollback(device) {  // L4
            seeds.passphrases += [day.passphrase].compactMap { $0 }
            seeds.words += [day.words].compactMap { $0 }
        }
        var vault: VaultSnapshot?
        if let account = record.account, let snapshot = server.snapshot(account) {
            vault = snapshot
            seeds.vaults.append(snapshot.vault)
        }
        var base = [liveKeyFile(device)].compactMap { $0 }
        if case .memory(let sealed)? = device.keychain.local[KName.memory(Self.scope, slot.libraryID)]?.value,
           let memory = try? ProtectionCoding.decoder().decode(DeviceMemory.self, from: sealed.payload),
           let mirror = memory.keyFileMirror { base.append(mirror) }
        // Rule 1's row (§3 of the corrector plan): the key file in the live place
        // and its sealed copy both gone, nothing rebuilds one from the key — "the
        // copy-less rebuild door is NOT built (rule 27 says the honest outcome)":
        // her secrets then open only what a remaining key file carries (its
        // copies keep the floor), and the open must SAY so.
        // A backup the app lists still holding the library's own key file:
        // rule 21's offer is owed instead (her ruling at the U4 stop).
        if !base.contains(where: { $0.fingerprint == slot.fingerprint }) {
            if device.isOpen {
                let assessment = assessed(device)
                if catalog(device).keyFiles.contains(where: { $0.role != .live && $0.fingerprint == slot.fingerprint }) {
                    if !assessment.acts.contains(.offerKeyFile) {
                        fail("a backup holds the library's own key file and the open doesn't offer it (rule 21)")
                    }
                } else if !assessment.faults.contains(where: { if case .noKeyFileAnywhere = $0 { return true } else { return false } }) {
                    fail("no key file of the current key is left and the open doesn't say so (rule 27)")
                }
            }
            return violations
        }
        let todayOpensIt = reach(seeds, files: base)[slot.fingerprint] != nil
        // (b) CAUGHT UP.
        let caughtUp: Bool = {
            guard record.account != nil else { return true }
            guard let vault else { return false }
            return record.accountRowKeyID == vault.rowKeyID && record.mode == vault.mode
        }()
        // L6: a library put in the live place from outside opens with the
        // secrets it was made with (the floor), not necessarily today's.
        // …and a backup's key file the offer put beside it carries the locks of
        // its day (the floor), until a key door re-locks it.
        let fromABackup = truth.keyFileFromBackup[device.name].map { $0 == liveKeyFile(device) } ?? false
        if caughtUp, !todayOpensIt, !fromOutside(device), !fromABackup {
            fail("her current passphrase and words don't open the library, and it has caught up (rules 4, 7, 12)")
        }
        // L4/L6: under a library (or key file) put back from outside, a copy the
        // key file there doesn't carry is the replaced stretch's — for good (the
        // carry is never promised across a replay), noted whatever today's open.
        // (Noted against the key file a later key change carries forward — the
        // live one, else the sealed copy; the carry itself isn't asked while
        // the replay stands.)
        if fromOutside(device) || dayOfRollback(device) != nil {
            let lineage = liveKeyFile(device).flatMap { $0.libraryID == record.libraryID ? $0 : nil } ?? base.last
            let carried = Set(lineage?.heldFingerprints ?? [])
            for (id, copy) in truth.copies where copy.madeOn == device.name && copy.libraryID == record.libraryID
                && !carried.contains(copy.fingerprint) {
                truth.rolledBackOver.insert(id)
            }
            return violations
        }
        // (c) THE CARRY — within the same library, wherever today's open it.
        guard todayOpensIt else { return violations }
        for (id, copy) in truth.copies.sorted(by: { $0.key < $1.key }) where copy.madeOn == device.name {
            if truth.rolledBackOver.contains(id) { continue }  // L4, L6
            guard let (fs, path) = DeviceLeaves(world: self, device: device).resolve(id), let image = fs.files[path]?.library,
                  image.libraryID == record.libraryID else {
                continue  // gone, or another library's copy (rule 19 — a new library has no previous keys)
            }
            if reach(seeds, files: base + [ownKeyFile(fs, path)].compactMap { $0 })[image.fingerprint] == nil {
                fail("her current passphrase and words don't open the copy \(id) (\(f8(image.fingerprint))) of the same library")
            }
        }
        return violations
    }

    /// A copy's own key file: its pair, else the key file set aside beside it.
    func ownKeyFile(_ fs: FolderFS, _ path: String) -> KeyFile? {
        fs.files[SPath.pair(of: path)]?.keyFile
            ?? fs.files[(path as NSString).deletingLastPathComponent + "/" + SPath.liveKeyFile]?.keyFile
    }

    /// PROMISE 5 — EVERY COPY OPENS BY SOME ROAD (rules 1, 27, 19): every copy
    /// Variorum wrote opens, on the device that made it, by the roads she has —
    /// her secrets of every day among them, nothing in the app's hands; the
    /// library in the live place too, or the lobby says honestly that no key
    /// file is left (27); a copy leaves only by her delete or this Mac's own
    /// retention of this library (19, VX-302).
    func everyCopyOpens() -> [Violation] {
        var violations: [Violation] = []
        var reachCache: [String: [String: StoreKey]] = [:]
        func reached(_ device: SDevice) -> [String: StoreKey] {
            if let held = reachCache[device.name] { return held }
            let found = reach(herSeeds(device, inHand: false), files: keyFilesOn(device) + mirrors(device))
            reachCache[device.name] = found
            return found
        }
        for (id, copy) in truth.copies.sorted(by: { $0.key < $1.key }) {
            let device = device(copy.madeOn)
            guard let (fs, path) = DeviceLeaves(world: self, device: device).resolve(id), let image = fs.files[path]?.library else {
                continue  // deleted (by her, by retention, by a wiped container)
            }
            if truth.tamperedStandard[device.name]?.contains(image.fingerprint) == true { continue }  // L3
            if reached(device)[image.fingerprint] == nil {
                violations.append(Violation(promise: 5, device: device.name, detail: "the copy \(id) (\(f8(image.fingerprint))) opens by no road"))
            }
        }
        for device in devices where !device.isOpen {
            guard let slot = device.slot, slot.record != nil, reached(device)[slot.fingerprint] == nil else { continue }
            // L3 (rule 3): a login-password holder rewrote this Standard key's
            // file (its only typed lock dropped) — they hold the key; what they
            // left is theirs (census seed 26 sequences 511, 521).
            if truth.tamperedStandard[device.name]?.contains(slot.fingerprint) == true { continue }
            // Before the open, with nothing remembered, the lobby can't tell which
            // library is in the live place: another library's key file there (the
            // other Mac's backups in a shared folder) might be its own — rule 27's
            // refusal can't be certain, so it isn't owed (census seed 25 seq 555).
            let remembered = device.keychain.names(service: ProtectionNames.memoryService)
            if remembered.isEmpty, catalog(device).keyFiles.contains(where: { $0.document.map { $0.libraryID != slot.libraryID } ?? false }) {
                continue
            }
            var closed = facts(device)
            closed.unlocked = nil
            if AssessRules.lobby(closed).noKeyFileAnywhere == nil {
                violations.append(Violation(promise: 5, device: device.name,
                                            detail: "the library in the live place opens by no road, and the lobby doesn't say so (rule 27)"))
            }
        }
        for prune in truth.prunes {
            if prune.copy.mac != .mac8(prune.mac8.lowercased()) || prune.copy.library != prune.library {
                violations.append(Violation(promise: 5, device: prune.by, detail: "retention pruned \(prune.copy.id), not this Mac's copy of this library"))
            }
        }
        truth.prunes.removeAll()
        return violations
    }

    /// PROMISE 6 — CRASH SAFE (rule 20): "a crash at any point leaves either
    /// the old state or the new one. The next open finishes the act or rolls it
    /// back from what is on disk, and says which." Strict: with the app open,
    /// nothing is half-done — no act in flight, no plan or staged file left,
    /// copies not paused. (The vault-reach qualifier left with VX-378 U2.)
    func crashSafe(_ device: SDevice) -> [Violation] {
        guard device.isOpen, let library = device.library else { return [] }
        var violations: [Violation] = []
        func fail(_ detail: String) { violations.append(Violation(promise: 6, device: device.name, detail: detail)) }
        if let inFlight = library.section.actInFlight { fail("an act is still in flight (\(inFlight.act))") }
        if library.section.actInFlight == nil, device.container.files[SPath.plan] != nil { fail("a plan is left on disk with nothing in flight") }
        if library.section.actInFlight == nil, device.staged != nil { fail("a staged file is left") }
        if device.paused { fail("copies are still paused") }
        return violations
    }

    /// PROMISE 7 — FOUR THINGS; A DISAGREEMENT IS NOTICED AND SAID (rules 21,
    /// 23 — her ruling at the U4 stop, 2026-10-17): "This Mac remembers four
    /// things about its library — its ID, its device ID, a fingerprint of its
    /// current key, and a copy of its key file: the key itself, still wrapped
    /// under your locks — and only the app's own doors change them" (21); a
    /// plain random device ID (23). With the library open and nothing in
    /// flight, a verified memory item names it, its current key and this Mac's
    /// device ID, carries the current key's file, and names no other library.
    /// The notice is judged at the launch (`noticeMismatches`): the open says
    /// exactly what the live place calls for — and nothing it then takes is
    /// silent (promise 9).
    func fourThings(_ device: SDevice) -> [Violation] {
        guard let library = device.library, library.section.actInFlight == nil, let record = device.slot?.record else { return [] }
        func fail(_ detail: String) -> [Violation] { [Violation(promise: 7, device: device.name, detail: detail)] }
        let reach = device.executor?.reach(key: library.key, keyFile: library.keyFile) ?? PF.reach([library.key])
        guard case .memory(let sealed)? = device.keychain.local[KName.memory(Self.scope, record.libraryID)]?.value,
              let memory = DeviceMemory.opening(sealed, libraryID: record.libraryID, reach: reach) else {
            return fail("no verified memory item for the open library")
        }
        if memory.currentFingerprint != record.currentFingerprint || memory.deviceID != library.section.deviceID {
            return fail("the memory names \(f8(memory.currentFingerprint)) on \(memory.deviceID.prefix(8)), the record \(f8(record.currentFingerprint)) on \(library.section.mac8)")
        }
        if let live = liveKeyFile(device), live.fingerprint == record.currentFingerprint, memory.keyFileMirror != live {
            return fail("the sealed copy isn't the current key's file")
        }
        let others = Set(device.keychain.names(service: ProtectionNames.memoryService)
            .compactMap { ProtectionNames.parseMemoryAccount($0.account, scope: Self.scope) })
            .subtracting([record.libraryID]).subtracting(truth.plantedMemories[device.name] ?? [])
        // L4: a rollback returns the Mac to an earlier moment; a library this
        // Mac came to remember after it (Make this my library's) is the later
        // stretch's, left as it was.
        if !others.isEmpty, truth.statedLimit[device.name] == nil {
            return fail("this Mac remembers \(others.count) other librar(ies) too")
        }
        return []
    }

    /// The findings the world made at the write or at the launch: promise 7's
    /// refusals, promise 8's strandings, promise 9's Look inside writes.
    func foundAtTheWrite() -> [Violation] {
        var violations: [Violation] = []
        violations += truth.noticeMismatches.map { Violation(promise: 7, device: $0.device, detail: $0.detail) }
        violations += truth.strandings.map { Violation(promise: 8, device: $0.device, detail: $0.detail) }
        violations += truth.lookInsideWrites.map { Violation(promise: 9, device: $0.device, detail: $0.detail) }
        violations += truth.doorRefusals.map { Violation(promise: 4, device: $0.device, detail: $0.detail) }
        violations += truth.madeWithNothing.map { Violation(promise: 4, device: $0.device, detail: $0.detail) }
        truth.doorRefusals.removeAll()
        truth.madeWithNothing.removeAll()
        truth.noticeMismatches.removeAll()
        truth.strandings.removeAll()
        truth.lookInsideWrites.removeAll()
        return violations
    }

    // MARK: - Promise 9, with a before and an after

    /// What a step may change on a device.
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

    /// PROMISE 9 — NOTHING SILENT: the mode and the account change only at a
    /// deliberate act or its follow; Make this my library keeps the posture of
    /// now ("You never leave Castle by opening something" — rule 17).
    func noSilentChange(_ action: Action, before: [String: Posture], crashedBefore: Set<String>) -> [Violation] {
        var violations: [Violation] = []
        for device in devices {
            guard let was = before[device.name] else { continue }
            // An open that said rule 21's notice said what it took (her ruling
            // at the U4 stop): the copy's posture and account are its own.
            if noticedThisStep.contains(device.name) { continue }
            let now = posture(device)
            if case .makeMine(let name, _, _) = innerAction(action), name == device.name, was.libraryID != now.libraryID,
               let from = truth.makeMinePressMode[name] ?? was.mode, let to = now.mode, from != to {
                violations.append(Violation(promise: 9, device: device.name, detail: "Make this my library moved the posture \(from) → \(to)"))
            }
            guard was.libraryID == now.libraryID, was.mode != nil, now.mode != nil else { continue }
            let changed = was.mode != now.mode || was.account != now.account
            guard changed else { continue }
            if deliberate(action, on: device.name) || crashedBefore.contains(device.name) { continue }
            if let back = truth.beforeRollback[device.name], back.mode == now.mode, back.account == now.account {
                truth.beforeRollback[device.name] = nil
                continue
            }
            violations.append(Violation(
                promise: 9, device: device.name,
                detail: "\(was.mode.map { "\($0)" } ?? "-")/\(was.account?.prefix(8) ?? "none") → \(now.mode.map { "\($0)" } ?? "-")/\(now.account?.prefix(8) ?? "none") at a step that isn't a deliberate act"))
        }
        return violations
    }

    func innerAction(_ action: Action) -> Action {
        if case .crash(let inner, _) = action { return innerAction(inner) }
        return action
    }

    func deliberate(_ action: Action, on name: String) -> Bool {
        switch action {
        case .crash(let inner, _): return deliberate(inner, on: name)
        case .settle: return true
        // Files replaced from outside the app (the tamper check below judges a
        // tamper in Castle; this one judges what the app does).
        case .timeMachineRollback(let d), .deleteContainerAndOpenOldCopy(let d), .tamper(let d, _), .tamperSequence(let d, _):
            return d == name
        case .useCastle(let d, _, _), .useStandard(let d), .follow(let d, _), .turnOnSync(let d),
             .move(let d), .thisMacOnly(let d), .stopSyncingHere(let d), .deleteAccountHere(let d), .replaceAllKeys(let d, _),
             .makeMine(let d, _, _):
            return d == name
        default:
            return false
        }
    }

    /// PROMISE 9's tamper clause (the kept core of VX-305's promise 10): in
    /// Castle, no planted, edited, replayed or deleted file or item — alone, or
    /// in a group in one closed window — changes the mode, the account, the
    /// custody, the gate style or the scheduled export SILENTLY in a weakening
    /// direction (Always ask recorded quietly when an item vanished weakens
    /// nothing). A relaunch that said rule 21's notice said what it took — the
    /// replayed copy's own posture and roads (her ruling at the U4 stop: "we
    /// also do not need to protect them from hand copying an old library over -
    /// they have to just remember that at that point"). Outside the promise
    /// (P-VX378-U4-2, CLOSED at the same sitting — her words: "someone with
    /// access to your computer can of course delete your library"): a group
    /// that replays both of this Mac's homes together, or the library file
    /// while what this Mac remembers is deleted, edited or replayed — L4.
    func sealed(_ device: SDevice, before was: Posture, tampers: [Tamper], opened: Bool = true, noticed: Bool = false) -> [Violation] {
        guard was.mode == .castle, !noticed else { return [] }
        let now = posture(device)
        // The relaunch found no road: the files on disk are the adversary's,
        // not a posture the app took — only what the app could have written is
        // judged here.
        let judgesThePosture = opened
        var violations: [Violation] = []
        let label = tampers.map { "\($0)" }.joined(separator: " + ")
        func fail(_ what: String) { violations.append(Violation(promise: 9, device: device.name, detail: "after \(label): \(what)")) }
        // L4 — both homes of this Mac's facts returned together (P-U4-5): the
        // complete replay, or the library file replayed while what this Mac
        // remembers can't speak (deleted, edited past its seal, or replayed) —
        // outside the promise (P-VX378-U4-2, CLOSED at her ruling).
        // L6: a library file replayed into the live place — said by rule 21's
        // notice (promise 7 judges it), or under the same key the memory names,
        // which rule 21's four things can't tell from the one this Mac last
        // opened (PROVISIONAL P-VX378-U4-7) — is the copy's own day.
        // A replayed memory item is the same class (census seed 27 sequence 980:
        // an earlier item names this Mac's earlier device ID, whose section —
        // its gate of that day — the open then reads; rule 21 keys on the
        // library, and a memory item older than it "moved on" — P-VX378-U4-5).
        let statedLimit = tampers.contains(.replayBothHomes) || tampers.contains(.replayLibraryFile)
            || tampers.contains(.replayMemory)
        if now.libraryID == was.libraryID, !statedLimit, judgesThePosture {
            if now.mode != .castle { fail("the mode is \(now.mode.map { "\($0)" } ?? "unknown")") }
            if now.account != was.account { fail("the account changed") }
        }
        if !statedLimit, !now.silentItems.subtracting(was.silentItems).isEmpty { fail("a silent custody item appeared") }
        if !now.touchIDItems.subtracting(was.touchIDItems).isEmpty { fail("a Touch ID item appeared") }
        if !statedLimit, judgesThePosture {
            if was.gate != .touchID, now.gate == .touchID { fail("the gate style became Touch ID") }
            if was.scheduledExport == false, now.scheduledExport == true { fail("the scheduled export turned on") }
        }
        return violations
    }
}
