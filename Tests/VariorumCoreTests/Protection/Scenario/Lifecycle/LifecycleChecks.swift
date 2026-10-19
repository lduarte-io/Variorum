//
//  LifecycleChecks.swift
//  VariorumCoreTests — VX-378 U3: THE FIXTURE'S JUDGMENT. Every road chip and
//  every written fact of `Lifecycle.stages`, checked against the world the
//  walk left — the files, the keychains, the Apple accounts, the vault — by
//  trying each road for real (a secret against a key file, an Apple key against
//  its lock, an item's key against the file), never by asking the model's own
//  route sentence. Where a door exists (Look inside), the model's door must
//  agree with the road. A check returns its failures; none = the fact holds.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

/// What a road chip opens, or a copy, as the checks resolve it.
struct LTarget {
    var fingerprint: String
    /// The device whose disk and keychain hold it.
    var device: SDevice
    /// The library's live key file (for a copy: the device's live key file).
    var live: KeyFile?
    /// A copy's own key file (nil for the library).
    var own: KeyFile?
    var copy: LCopy?
    var isLibrary: Bool { copy == nil }
}

struct LifecycleChecks {
    let walk: LifecycleWalk
    var world: SWorld { walk.world }

    // MARK: - Targets

    func target(_ subject: LSubject) -> LTarget? {
        switch subject {
        case .library:
            guard let slot = walk.mac.slot else { return nil }
            return LTarget(fingerprint: slot.fingerprint, device: walk.mac, live: world.liveKeyFile(walk.mac), own: nil, copy: nil)
        default:
            guard let copy = walk.copies[subject] else { return nil }
            let device = world.device(copy.device)
            guard let image = device.container.files[copy.path]?.library else { return nil }
            return LTarget(
                fingerprint: image.fingerprint, device: device, live: world.liveKeyFile(device),
                own: device.container.files[copy.pairPath]?.keyFile, copy: copy)
        }
    }

    // MARK: - Roads, tried for real

    /// Every key a secret reaches on a key file: its current key, then its
    /// history (rule 4: the current key opens every earlier key).
    func keys(_ file: KeyFile?, _ secret: ProtectionSecret) -> [StoreKey] {
        guard let file, let current = try? file.open(secret, floor: PF.floor) else { return [] }
        return [current] + ((try? file.historyKeys(currentKey: current))?.map(\.key) ?? [])
    }

    /// The secrets a typed road types, each tried alone.
    func secrets(_ secret: LSecret, _ day: LDay, _ target: LTarget) -> [ProtectionSecret?] {
        let p = day == .itsDay ? target.copy?.dayPassphrase : walk.passphrase
        let w = day == .itsDay ? target.copy?.dayWords : walk.words
        let passphrase = p.map { ProtectionSecret.passphrase($0) }
        let words = w.map { ProtectionSecret.words($0) }
        switch secret {
        case .passphrase: return [passphrase]
        case .words: return [words]
        case .either: return [passphrase, words]
        }
    }

    func typedOpens(_ secret: ProtectionSecret?, _ day: LDay, _ target: LTarget) -> Bool {
        guard let secret else { return false }
        let files: [KeyFile?]
        switch day {
        case .today: files = target.isLibrary ? [target.live] : [target.live, target.own]
        case .throughTheHistory: files = [target.live]
        case .itsDay: files = [target.own]
        }
        let reached: [StoreKey] = files.flatMap { keys($0, secret) }
        if target.isLibrary, day != .itsDay {
            // The library opens by its live key file's CURRENT key.
            guard let file = target.live, let current = try? file.open(secret, floor: PF.floor) else { return false }
            return PF.fp(current) == target.fingerprint
        }
        return reached.contains { PF.fp($0) == target.fingerprint }
    }

    /// The Apple lock on the target's own key file (the live key file for the
    /// library), opened by an Apple key readable on `device`.
    func appleOpens(_ target: LTarget, on device: SDevice, keyID: String? = nil) -> Bool {
        let file = target.isLibrary ? target.live : target.own
        guard let file, let wrap = file.apple, keyID == nil || wrap.keyID == keyID,
              let apple = world.readableAppleKeys(device)[wrap.keyID],
              let key = try? file.open(apple: apple) else { return false }
        return PF.fp(key) == target.fingerprint
    }

    /// A keychain item on `device` holding the target's key directly.
    func itemOpens(_ target: LTarget, _ itemClass: ProtectionNames.CustodyClass) -> Bool {
        let name = KName.custody(SWorld.scope, target.fingerprint, itemClass)
        guard let item = target.device.keychain.local[name] else { return false }
        guard let value = world.pressRead(target.device, item), let key = value.libraryKey else { return false }
        return PF.fp(key) == target.fingerprint
    }

    /// Look inside a copy by the model's own door, writing nothing.
    func modelLookInside(_ target: LTarget, typed: TypedSecrets) -> (opened: Bool, wroteNothing: Bool) {
        guard let copy = target.copy else { return (false, true) }
        let catalog = world.catalog(target.device)
        guard let entry = catalog.copies.first(where: { $0.id == copy.id }) else { return (false, true) }
        let before = LSnapshot(target.device)
        let executor = world.newExecutor(target.device, libraryID: target.device.slot?.libraryID ?? "")
        let opened = (try? executor.lookInside(entry, in: catalog, typed: typed, quietRoads: .includingTouchID)) != nil
        return (opened, LSnapshot(target.device) == before)
    }

    // MARK: - A chip

    func expectedState(_ chip: LChip) -> LState {
        var state = chip.state
        if chip.condition == .touchIDChosen, walk.gate != .touchID { state = .gone }
        if chip.diff != nil { state = state == .opens ? .gone : .opens }
        return state
    }

    func check(_ chip: LChip, _ subject: LSubject, _ ctx: LStageContext) -> [String] {
        let here = "stage \(ctx.number) · \(subject.rawValue) · “\(chip.label)”"
        guard let target = target(subject) else { return ["\(here): the walk has no \(subject.rawValue)"] }
        let expected = expectedState(chip)
        var failures: [String] = []
        func say(_ opens: Bool, _ what: String = "") {
            if opens != (expected == .opens) {
                failures.append("\(here): the page says \(expected.rawValue), the world says \(opens ? "opens" : "gone")\(what)")
            }
        }
        switch chip.road {
        case .typed(let secret, let day):
            let tried = secrets(secret, day, target).map { typedOpens($0, day, target) }
            say(expected == .opens ? !tried.isEmpty && tried.allSatisfy { $0 } : tried.contains(true))
            // The model's door agrees: Look inside opens with each secret.
            if !target.isLibrary, expected == .opens {
                for value in secrets(secret, day, target) {
                    let typed: TypedSecrets
                    switch value {
                    case .passphrase(let p)?: typed = TypedSecrets(passphrase: p)
                    case .words(let w)?: typed = TypedSecrets(words: w)
                    default: continue
                    }
                    let look = modelLookInside(target, typed: typed)
                    if !look.opened { failures.append("\(here): Look inside refused a secret the road opens") }
                    if !look.wroteNothing { failures.append("\(here): Look inside wrote something") }
                }
            }
        case .apple(.itsOwnLock):
            if chip.everywhere {
                let opensOn = walk.hers.filter { appleOpens(target, on: $0) }.map(\.name)
                say(!opensOn.isEmpty, opensOn.isEmpty ? "" : " (on \(opensOn.joined(separator: ", ")))")
            } else {
                say(appleOpens(target, on: target.device))
            }
        case .apple(.beforeThisStage):
            guard let id = ctx.startAppleKeyID else {
                failures.append("\(here): no Apple key was named when the stage began")
                break
            }
            let readable = world.readableAppleKeys(target.device)[id] != nil
            let wrapped = [target.live, target.own].compactMap { $0 }.contains { $0.apple?.keyID == id }
            say(readable && wrapped && appleOpens(target, on: target.device, keyID: id))
        case .onDevice:
            say(itemOpens(target, .silent))
        case .touchID:
            say(itemOpens(target, .touchid))
        case .quietRoads:
            let quiet = appleOpens(target, on: target.device) || itemOpens(target, .silent) || itemOpens(target, .touchid)
            say(quiet)
            if !target.isLibrary {
                let look = modelLookInside(target, typed: .none)
                if look.opened != quiet { failures.append("\(here): Look inside with nothing typed \(look.opened ? "opened" : "refused") it") }
                if !look.wroteNothing { failures.append("\(here): Look inside wrote something") }
            }
        }
        return failures
    }

    // MARK: - A stage

    func verify(_ stage: LStage, _ ctx: LStageContext) -> [String] {
        var failures: [String] = []
        // The stage's posture: the live library's mode at the stage's end.
        let mode: ProtectionMode? = stage.posture == .standard ? .standard : stage.posture == .castle ? .castle : nil
        if let mode, walk.mac.slot?.record?.mode != mode {
            failures.append("stage \(ctx.number): the page's posture is \(mode.rawValue), the library is \(walk.mac.slot?.record?.mode.rawValue ?? "nothing")")
        }
        for row in stage.rows {
            switch row.content {
            case .text: break
            case .chips(let subject, let chips), .textStating(_, let subject, let chips):
                for chip in chips { failures += check(chip, subject, ctx) }
            }
        }
        for hidden in stage.hidden {
            for chip in hidden.chips { failures += check(chip, hidden.subject, ctx).map { "\($0) [hidden: \(hidden.source)]" } }
        }
        for entry in stage.facts {
            switch entry.status {
            case .asserted:
                failures += check(entry.fact, ctx).map { "stage \(ctx.number) · “\(entry.quote)”: \($0)" }
            case .diff(let id, let observed):
                failures += diff(id, entry, observed, ctx)
            case .diffWhen(let event, let id, let observed):
                if event == walk.event {
                    failures += diff(id, entry, observed, ctx)
                } else {
                    failures += check(entry.fact, ctx).map { "stage \(ctx.number) · “\(entry.quote)”: \($0)" }
                }
            case .onlyWhen(let event):
                if event == walk.event {
                    failures += check(entry.fact, ctx).map { "stage \(ctx.number) · “\(entry.quote)”: \($0)" }
                }
            case .assertedAt, .branch, .notAModelFact:
                continue
            }
        }
        return failures
    }

    /// A FACTS DIFF: the model's observed fact holds — and the page's still
    /// doesn't (a diff the model has since closed is stale, and says so).
    func diff(_ id: String, _ entry: LFactEntry, _ observed: LFact, _ ctx: LStageContext) -> [String] {
        var failures = check(observed, ctx).map { "stage \(ctx.number) · \(id) (observed): \($0)" }
        if check(entry.fact, ctx).isEmpty {
            failures.append("stage \(ctx.number) · \(id): the page's fact now holds — the FACTS DIFF no longer stands")
        }
        return failures
    }

    // MARK: - A fact

    func check(_ fact: LFact, _ ctx: LStageContext) -> [String] {
        var failures: [String] = []
        func expect(_ condition: Bool, _ message: @autoclosure () -> String) {
            if !condition { failures.append(message()) }
        }
        let mac = walk.mac
        let live = world.liveKeyFile(mac)
        let fingerprint = mac.slot?.fingerprint
        let library = mac.library
        func roads(_ file: KeyFile?) -> Set<LLock> {
            var locks = Set<LLock>()
            guard let file else { return locks }
            if file.passphrase != nil { locks.insert(.passphrase) }
            if file.words != nil { locks.insert(.words) }
            if file.apple != nil { locks.insert(.apple) }
            if file.master != nil { locks.insert(.master) }
            return locks
        }
        func items(for fp: String?) -> Set<LItem> {
            guard let fp else { return [] }
            var found = Set<LItem>()
            if mac.keychain.local[KName.custody(SWorld.scope, fp, .silent)] != nil { found.insert(.onDevice) }
            if mac.keychain.local[KName.custody(SWorld.scope, fp, .touchid)] != nil { found.insert(.touchID) }
            return found
        }
        func secretOpensLive(_ secret: ProtectionSecret?) -> Bool {
            guard let secret, let live, let key = try? live.open(secret, floor: PF.floor) else { return false }
            return PF.fp(key) == fingerprint
        }
        switch fact {
        case .newKey(let name, let kind):
            expect(fingerprint != nil && fingerprint != ctx.startFingerprint, "the key did not change")
            expect(fingerprint.map { !ctx.startKeysSeen.contains($0) } ?? false, "the key is not new")
            expect(mac.slot?.record?.mode == kind, "the library is \(mac.slot?.record?.mode.rawValue ?? "nothing"), not \(kind.rawValue)")
            if let fingerprint { walk.keys[name] = fingerprint }
        case .keyUnchanged:
            expect(fingerprint == ctx.startFingerprint, "the key changed")
        case .keyFileLocks(let has, let lacks):
            let locks = roads(live)
            for lock in has { expect(locks.contains(lock), "the key file has no \(lock.rawValue) lock") }
            for lock in lacks { expect(!locks.contains(lock), "the key file has a \(lock.rawValue) lock") }
        case .lockRelocked(let lock):
            expect(fingerprint == ctx.startFingerprint, "the key changed")
            switch lock {
            case .passphrase:
                expect(live?.passphrase != ctx.startKeyFile?.passphrase, "the passphrase lock is the same")
                expect(secretOpensLive(walk.passphrase.map { .passphrase($0) }), "the new passphrase doesn't open it")
                expect(!secretOpensLive(ctx.startPassphrase.map { .passphrase($0) }), "the old passphrase still opens it")
            case .words:
                expect(live?.words != ctx.startKeyFile?.words, "the words lock is the same")
                expect(secretOpensLive(.words(walk.words)), "the new words don't open it")
                expect(!secretOpensLive(ctx.startWords.map { .words($0) }), "the old words still open it")
            case .apple, .master:
                failures.append("no relock check for \(lock.rawValue)")
            }
        case .nothingElseChanges(let except):
            var before = ctx.startKeyFile, after = live
            for lock in except {
                switch lock {
                case .passphrase: before?.passphrase = nil; after?.passphrase = nil
                case .words: before?.words = nil; after?.words = nil
                case .apple: before?.apple = nil; after?.apple = nil
                case .master: before?.master = nil; after?.master = nil
                }
            }
            expect(before == after, "the key file changed beyond its \(except.map(\.rawValue)) lock(s)")
            let custodyNow = (try? DeviceLeaves(world: world, device: mac).custodyItems()) ?? []
            expect(Set(custodyNow.map { "\($0)" }) == Set(ctx.startCustody.map { "\($0)" }), "this Mac's items changed")
            expect(Set(world.readableAppleKeys(mac).keys) == ctx.startAppleReadable, "the Apple keys changed")
        case .historyCarries(let names):
            for name in names {
                guard let fp = walk.keys[name] else { failures.append("the walk never named \(name)"); continue }
                let held = live.flatMap { file in library.flatMap { try? file.historyKey(fp, currentKey: $0.key) } }
                expect(held != nil, "the history doesn't open \(name)")
            }
        case .custody(let has, let lacks):
            let found = items(for: fingerprint)
            for item in has { expect(found.contains(item), "no \(item.rawValue) item holds the current key") }
            for item in lacks { expect(!found.contains(item), "a \(item.rawValue) item holds the current key") }
        case .touchIDItemIfChosen:
            let found = items(for: fingerprint)
            if walk.gate == .touchID {
                expect(found == [.touchID], "Touch ID chosen, but the items are \(found.map(\.rawValue))")
            } else {
                expect(found.isEmpty, "Always ask, but a copy stays on the device: \(found.map(\.rawValue))")
            }
        case .noOnDeviceItemForAnyKeyItHasHad:
            let had = Set(live?.heldFingerprints ?? []).union([fingerprint].compactMap { $0 })
            let silent = mac.keychain.local.keys.filter { $0.service == ProtectionNames.custodyService }
                .compactMap { ProtectionNames.parseCustodyAccount($0.account, scope: SWorld.scope) }
                .filter { $0.class == .silent && had.contains($0.fingerprint) }
            expect(silent.isEmpty, "\(silent.count) on-device item(s) left for keys the library has had")
        case .appleKeysDeletedEverywhere:
            for device in walk.hers {
                let readable = Set(world.readableAppleKeys(device).keys).intersection(walk.appleKeysNamed)
                expect(readable.isEmpty, "\(device.name) still reads \(readable.count) of the library's Apple keys")
            }
        case .appleKeysDeleted:
            for (id, account) in world.appleAccounts {
                let left = Set(account.liveItems.compactMap { $0.value.value.appleKey?.id }).intersection(walk.appleKeysNamed)
                expect(left.isEmpty, "Apple account \(id) still holds \(left.count) of the library's Apple keys")
            }
            for device in world.devices {
                let left = Set(world.readableAppleKeys(device).keys).intersection(walk.appleKeysNamed)
                expect(left.isEmpty, "\(device.name) still holds \(left.count) of the library's Apple keys")
            }
        case .freshAppleRoad:
            let id = live?.apple?.keyID
            expect(id != nil, "the key file has no Apple lock")
            expect(id.map { !ctx.startAppleKeysSeen.contains($0) } ?? false, "the Apple lock names an earlier Apple key")
            if let target = target(.library) { expect(appleOpens(target, on: mac), "the Apple road doesn't open the library here") }
        case .sealedKeyFileCopy:
            expect(library?.memory?.keyFileMirror != nil && library?.memory?.keyFileMirror == live, "this Mac's keychain doesn't hold the live key file")
        case .newPlainRandomDeviceID:
            let id = library?.section.deviceID
            expect(id.map { UUID(uuidString: $0) != nil } ?? false, "the device ID isn't a plain random value")
            expect(id.map { !ctx.startDeviceIDsSeen.contains($0) } ?? false, "the device ID isn't new")
            expect(library?.memory?.deviceID == id, "this Mac remembers another device ID")
        case .wordsShownOnce, .wordsStoredNowhere:
            // VX-307 U2b: shown once = the LOOK's words (the stage's, `shownWords`); stored nowhere at the creation =
            // the creation's (handed back by the door, shown to no one).
            let handedBack: [String]?
            if case .wordsShownOnce = fact { handedBack = ctx.shownWords } else { handedBack = ctx.created?.words }
            guard let words = handedBack else { failures.append("the door handed back no words"); break }
            expect(words.count == 12, "the door handed back \(words.count) words")
            expect(secretOpensLive(.words(words)), "the words don't open the key file")
            let text = Data(words.joined(separator: " ").utf8)
            var stored: [Data] = mac.container.files.values.compactMap { $0.encodedKeyFile() }
            stored += mac.keychain.local.values.compactMap { item -> Data? in
                if case .memory(let sealed) = item.value { return sealed.payload }
                return nil
            }
            expect(!stored.contains { SecretScan.carries($0, text) }, "the words are stored")
        case .noBackups:
            let backups = world.catalog(mac).copies.filter { $0.kind == .backup }
            expect(backups.isEmpty, "\(backups.count) backup(s) exist")
        case .backupOfItsDay(let subject):
            guard let target = target(subject) else { failures.append("no \(subject.rawValue)"); break }
            expect(target.own == live, "its key file isn't the key file of its day")
            expect(target.fingerprint == fingerprint, "it isn't the library of its day")
        case .ownKeyFileWantsTheOldSecret(let subject, let secret):
            guard let target = target(subject), secret == .passphrase else { failures.append("no check"); break }
            expect(keys(target.own, .passphrase(ctx.startPassphrase ?? "")).contains { PF.fp($0) == target.fingerprint },
                   "its own key file doesn't open with the old passphrase")
            expect(!keys(target.own, .passphrase(walk.passphrase ?? "")).contains { PF.fp($0) == target.fingerprint },
                   "its own key file opens with the new passphrase")
        case .copyLocks(let subject, let has, let lacks, let noItem):
            guard let target = target(subject) else { failures.append("no \(subject.rawValue)"); break }
            let locks = roads(target.own)
            for lock in has { expect(locks.contains(lock), "its key file has no \(lock.rawValue) lock") }
            for lock in lacks { expect(!locks.contains(lock), "its key file has a \(lock.rawValue) lock") }
            if noItem { expect(!itemOpens(target, .silent), "an on-device item holds its key") }
        case .passphraseAsk(let ask):
            let asks = world.assessed(mac).acts.compactMap { act -> PassphraseAsk? in
                if case .askPassphrase(let ask) = act { return ask }
                return nil
            }
            expect(asks == (ask.map { [$0] } ?? []), "the passphrase asks owed are \(asks)")
        case .reminderTrigger(let trigger):
            switch trigger {
            case .noPassphraseYet:
                let owed = world.assessed(mac).acts.contains(.askPassphrase(.beforeFirstBackup))
                expect(owed && mac.slot?.record?.passphraseSet == false, "the reminder isn't owed while no passphrase exists")
            }
        case .nextOpenAsksNothing:
            expect(ctx.observed.contains(.openedUntyped), "the next open needed a secret")
            expect(!ctx.observed.contains(.lobbyAskedAtOnce), "the lobby asked at once")
        case .nextOpenAsksAtOnce:
            expect(ctx.observed.contains(.lobbyAskedAtOnce), "the lobby didn't ask at once")
            expect(ctx.observed.contains(.untypedOpenFailed), "something opened it with nothing typed")
            expect(ctx.observed.contains(.typedOpenSucceeded), "the secret typed didn't open it")
        case .quietRoadsRemade:
            expect(items(for: fingerprint).contains(.onDevice), "no on-device item was re-made")
            let id = live?.apple?.keyID
            expect(id.map { !ctx.startAppleKeysSeen.contains($0) } ?? false, "no fresh Apple road was made")
            if let target = target(.library) { expect(appleOpens(target, on: mac), "the Apple road doesn't open the library here") }
        case .scheduledExportOffWithOneNotice:
            expect(ctx.outcome?.notices.filter { $0 == .scheduledExportTurnedOff }.count == 1, "the notices were \(ctx.outcome?.notices ?? [])")
            expect(ctx.observed.contains(.exportOffAfterAct), "the scheduled export stayed on")
        case .scheduledExportReversible:
            expect(ctx.observed.contains(.exportBackOn), "she couldn't turn it back on")
        case .lookInside(let subject, let opensWith, let refuses, let quietRoad):
            guard let results = ctx.looks[subject.rawValue] else { failures.append("Look inside wasn't run"); break }
            expect(results.count == opensWith.count + refuses.count + 1, "Look inside ran \(results.count) times")
            for result in results {
                expect(result.wroteNothing, "Look inside (\(String(describing: result.typed))) wrote something")
            }
            if let quiet = results.first(where: { $0.typed == nil }) {
                expect(quiet.opened == quietRoad, "with nothing typed it \(quiet.opened ? "opened" : "refused")")
            }
            for (index, result) in results.dropFirst().enumerated() {
                let shouldOpen = index < opensWith.count
                expect(result.opened == shouldOpen, "\(String(describing: result.typed)) \(result.opened ? "opened" : "refused") it")
            }
        case .makeMine(let subject):
            guard let seen = ctx.makeMine[subject], let record = mac.slot?.record, let library, let copy = walk.copies[subject] else {
                failures.append("Make this my library wasn't run"); break
            }
            expect(record.libraryID != seen.oldLibraryID && record.libraryID != seen.copyLibraryID, "not a fresh identity")
            expect(!seen.keysSeenBefore.contains(library.fingerprint), "not a fresh key")
            expect(library.section.deviceID != seen.oldDeviceID, "not a fresh device ID")
            expect(record.mode == seen.oldMode, "the posture of now was \(seen.oldMode.rawValue); it's \(record.mode.rawValue)")
            expect(record.account == nil && live?.master == nil, "it carries an account")
            expect(live?.history.isEmpty == true, "it has a past")
            expect(secretOpensLive(walk.passphrase.map { .passphrase($0) }), "the current passphrase doesn't open it")
            expect(secretOpensLive(.words(walk.words)), "the current words don't open it")
            if let p = seen.copySecrets.passphrase, p != walk.passphrase {
                expect(!secretOpensLive(.passphrase(p)), "the copy's own passphrase opens it")
            }
            // The previous library aside, whole, with its own key file.
            let aside = mac.container.files.filter { $0.key.hasPrefix(CatalogNames.previousLibrariesFolderName + "/") }
            let asideLibrary = aside.first { $0.key.hasSuffix("/" + SPath.slot) && $0.value.library?.fingerprint == seen.oldFingerprint }
            expect(asideLibrary != nil, "the previous library isn't in Previous Libraries")
            if let asideLibrary {
                let folder = String(asideLibrary.key.dropLast(SPath.slot.count))
                expect(mac.container.files[folder + SPath.liveKeyFile]?.keyFile == seen.oldKeyFile, "its key file didn't step aside with it")
            }
            expect(mac.container.files[copy.path] == seen.copyFiles.0 && mac.container.files[copy.pairPath] == seen.copyFiles.1,
                   "the copy changed")
        case .theirsUntouched:
            guard let before = walk.theirsBefore else { failures.append("their state wasn't read"); break }
            let them = walk.theirs
            expect(them.container.files[SPath.slot] == before.slot, "their library changed")
            expect(them.container.files[SPath.liveKeyFile] == before.keyFile, "their key file changed")
            let vault = world.server.snapshot(LifecycleWalk.theirAccount)
            expect(vault?.vault == before.vault && vault?.revision == before.revision, "their account's vault changed")
        case .filesMoveWithYou:
            guard let before = ctx.moveBefore, let after = ctx.moveAfter else { failures.append("the move wasn't read"); break }
            expect(after.slot != nil && after.slot == before.slot, "the library didn't arrive as it was")
            expect(after.keyFile != nil && after.keyFile == before.keyFile, "its key file didn't arrive as it was")
        case .nothingTakenOver:
            guard let before = ctx.moveBefore, let library else { failures.append("the move wasn't read"); break }
            let old = Set(before.section.appleKeys.map(\.id))
            expect(Set(library.section.appleKeys.map(\.id)).isDisjoint(with: old), "the new section adopted the old one's Apple keys")
            let sections = library.record?.verifiedSections { $0 == PF.fp(library.key) ? library.key : nil } ?? []
            expect(sections.contains { $0.deviceID == before.deviceID && $0.appleKeys == before.section.appleKeys },
                   "the old device's section was changed")
        case .syncSetUpHandsThePairUp:
            guard let vault = world.server.snapshot(LifecycleWalk.myAccount)?.vault else { failures.append("no vault"); break }
            let p = walk.passphrase.flatMap { try? PassphraseKey.derive($0, kdf: vault.kdf) }
            expect(vault.master(passphrase: p, words: nil) != nil, "the account doesn't open with the library's passphrase")
            expect(vault.master(passphrase: nil, words: try? WordsKey.derive(walk.words)) != nil, "the account doesn't open with the library's words")
            expect(vault.mode == mac.slot?.record?.mode, "the account took another posture than the library's")
            expect(ctx.sync.setUpFingerprintBefore != nil && ctx.sync.setUpFingerprintAfter == ctx.sync.setUpFingerprintBefore,
                   "the key changed at sync set-up")
            expect(ctx.sync.setUpLocksAfter?.0 == ctx.sync.setUpLocksBefore?.0, "the passphrase lock was replaced")
            expect(ctx.sync.setUpLocksAfter?.1 == ctx.sync.setUpLocksBefore?.1, "the words lock was replaced")
        case .joinAdoptsTheAccountsPair:
            let other = walk.other
            guard let file = world.liveKeyFile(other), let fp = other.slot?.fingerprint else { failures.append("no joiner"); break }
            func opens(_ secret: ProtectionSecret?) -> Bool {
                guard let secret, let key = try? file.open(secret, floor: PF.floor) else { return false }
                return PF.fp(key) == fp
            }
            expect(opens(walk.passphrase.map { .passphrase($0) }), "the account's passphrase doesn't open the joiner's library")
            expect(opens(.words(walk.words)), "the account's words don't open the joiner's library")
            expect(!opens(ctx.sync.joinerOwnWords.map { .words($0) }), "the joiner's own words still open its library")
            expect(ctx.sync.joinerFingerprintBefore != nil && ctx.sync.joinerFingerprintAfterJoin == ctx.sync.joinerFingerprintBefore,
                   "the join changed the joiner's key")
        case .notices(let notices):
            for notice in notices {
                expect(ctx.noticeOutcome?.notices.contains(notice) == true, "no \(notice) notice")
            }
        case .oldWordsStillOpenOlderBackups:
            guard let results = ctx.looks[LSubject.joinersBackup.rawValue] else { failures.append("not looked inside"); break }
            expect(results.dropFirst().allSatisfy { $0.opened && $0.wroteNothing }, "the joiner's earlier backup didn't open with its old words and the account's secrets")
            if let target = target(.joinersBackup) {
                expect(typedOpens(target.copy?.dayWords.map { .words($0) }, .itsDay, target), "its old words don't open it")
                expect(typedOpens(walk.passphrase.map { .passphrase($0) }, .throughTheHistory, target), "the account's passphrase doesn't open it (same key)")
            }
        case .accountEntersCastleInOneWrite:
            guard let before = ctx.sync.vaultBeforeEntry, let after = ctx.sync.vaultAfterEntry else {
                failures.append("the entry wasn't read"); break
            }
            expect(after.mode == .castle, "the account is \(after.mode.rawValue)")
            expect(after.rowKey.keyID != before.rowKey.keyID, "the sync key didn't change")
            expect(after.earlierRowKeys.keys.contains(before.rowKey.keyID), "the old sync key isn't kept")
            let writes = ctx.sync.writesAfterEntry - ctx.sync.writesBeforeEntry
            expect(writes == 1, "the entry took \(writes) vault writes")
        case .laggingDeviceReadsOnlyWhatItHas:
            let seen = ctx.sync
            guard let after = seen.vaultAfterEntry else { failures.append("not read"); break }
            expect(seen.laggingOpenedUntyped, "the lagging device needed a secret to read its own library")
            expect(seen.laggingHeldKeys?.rowKey(for: after.rowKey.keyID) == nil, "the lagging device holds the new sync key")
            expect(seen.laggingOwed.contains(.follow(.intoCastle, typesOneSecret: true)), "no one-secret follow was owed: \(seen.laggingOwed)")
        case .followTypesOneSecret:
            let seen = ctx.sync
            guard let after = seen.vaultAfterEntry else { failures.append("not read"); break }
            expect(seen.followOutcome != nil, "the follow didn't run")
            expect(seen.followedHeldKeys?.rowKeyID == after.rowKey.keyID, "after the follow it holds another sync key")
        case .accountLeavesCastleOtherDevicesFollowQuietly:
            let seen = ctx.sync
            guard let before = seen.vaultBeforeLeave, let after = seen.vaultAfterCastleLeave else { failures.append("not read"); break }
            expect(after.mode == .standard, "the account didn't leave Castle")
            expect(after.rowKey == before.rowKey, "the leave changed the sync key")
            expect(after.earlierRowKeys == before.earlierRowKeys, "the leave changed the earlier sync keys")
            expect(seen.followOutOwed.contains(.follow(.intoStandard, typesOneSecret: false)), "no quiet follow out was owed: \(seen.followOutOwed)")
            expect(seen.followOutRequires == SecretRequirement.none, "the follow out asks \(String(describing: seen.followOutRequires))")
            expect(seen.followOutOutcome?.notices.contains(.followedOutOfCastle) == true, "no notice")
            expect(seen.otherModeAfterFollowOut == .standard, "the other device didn't follow out")
        case .leavingTheAccountChangesNoKey:
            let seen = ctx.sync
            expect(seen.leaverFingerprintAfterLeave == seen.leaverFingerprintBefore, "the leave changed the key")
            expect(seen.leaverKeyFileAfterLeave == seen.leaverKeyFileBefore, "the leave changed the key file's locks")
            expect(seen.leaverRecordAfterLeave?.account == nil, "the record still names the account")
            expect(seen.vaultAfterLeave != nil && seen.vaultAfterLeave?.revision == seen.vaultRevisionBeforeLeave, "the server's vault changed")
        case .signingBackInIsAJoinThatReadsEverything:
            let seen = ctx.sync
            guard let first = walk.firstRowKeyID else { failures.append("not read"); break }
            expect(seen.rejoinAccount == LifecycleWalk.myAccount, "signing back in didn't join")
            expect(seen.rejoinHeldKeys?.rowKey(for: first) != nil, "the device that joined later can't read the first sync key's rows")
            expect(seen.rejoinHeldKeys.map { $0.rowKey(for: $0.rowKeyID) != nil } ?? false, "it can't read the current one's")
        case .crashBeforeThePlanRollsBack:
            expect(ctx.crash.firstResult == .crashed, "the act didn't crash (\(String(describing: ctx.crash.firstResult)))")
            expect(ctx.crash.firstSettle == .rolledBack(.replaceAllKeys), "the open said \(String(describing: ctx.crash.firstSettle))")
            expect(ctx.crash.fingerprintAfterFirst == ctx.crash.fingerprintBefore, "the old state isn't back")
        case .crashAfterThePlanFinishes:
            expect(ctx.crash.secondResult == .crashed, "the act didn't crash (\(String(describing: ctx.crash.secondResult)))")
            if case .resumed(let outcome)? = ctx.crash.secondSettle {
                expect(outcome.act == .replaceAllKeys, "it finished \(outcome.act)")
            } else {
                failures.append("the open said \(String(describing: ctx.crash.secondSettle))")
            }
            expect(ctx.crash.fingerprintAfterSecond != ctx.crash.fingerprintBefore, "the new state isn't there")
            expect(ctx.crash.fingerprintBefore.map { ctx.crash.historyAfterSecond.contains($0) } ?? false, "the new key's history lost the old")
        case .noKeyDeletedBeforeItsReplacement:
            expect(ctx.crash.untypedAfterFirst, "after the roll back nothing quiet opens the library")
            expect(ctx.crash.untypedAfterSecond, "after the finish nothing quiet opens the library")
        case .fourThingsRemembered:
            guard let seen = ctx.remembered, let memory = seen.memory else { failures.append("nothing remembered"); break }
            let labels = Set(Mirror(reflecting: memory).children.compactMap(\.label))
            expect(labels == ["format", "libraryID", "currentFingerprint", "deviceID", "keyFileMirror"], "it remembers \(labels.sorted())")
            expect(memory.libraryID == seen.libraryID && memory.currentFingerprint == seen.fingerprint
                   && memory.deviceID == seen.deviceID && memory.keyFileMirror == seen.live, "what it remembers doesn't match the live place")
        case .noticesWhatItDoesntRemember(let stray):
            guard let result = ctx.strays[stray] else { failures.append("not tried"); break }
            expect(result.opened, "it didn't open: \(result.otherError ?? "")")
            expect(result.strayUntouched, "the open repaired the file it found (its library file, its key, or her locks)")
            switch stray {
            case .backupPairCopiedInByHand, .replayedOldLibraryFile:
                if case .olderCopy(let date)? = result.notice?.kind {
                    expect(date == result.strayDate, "the older copy's date isn't the copy's")
                } else {
                    failures.append("it said \(result.notice.map { "\($0.kind)" } ?? "nothing"), not the older copy")
                }
                expect(result.notice?.words == "This is an older copy of your library, from <date>", "the words aren't hers")
            case .swappedInFile:
                expect(result.notice?.kind == .differentLibrary, "it said \(result.notice.map { "\($0.kind)" } ?? "nothing"), not a different library")
                expect(result.notice?.words == "This is a different library than the one this Mac last had open", "the words aren't hers")
            }
            expect(result.memoryFollowed, "this Mac doesn't remember the library it opened (or still remembers another)")
            expect(result.secondOpenSilent, "it said so twice")
        case .offersTheKeyFileThatOpensIt:
            let seen = ctx.offerSeen
            expect(seen.tried && seen.opened, "the library with an old key file beside it didn't open")
            expect(seen.owed, "the offer wasn't owed")
            guard let offer = seen.offer else { failures.append("nothing was offered"); break }
            expect(offer.source == .thisMacsKeychain, "it offered \(offer.source), not this Mac's keychain copy")
            expect(offer.words == "The key file beside your library doesn't open it. This Mac's keychain holds a copy that does. Use it?",
                   "the words aren't hers")
            expect(offer.keyFile == seen.mirrorBefore, "it offered something other than the keychain copy")
            expect(seen.searchWroteNothing, "the search wrote something before her yes")
            expect(seen.liveAfterYes == seen.mirrorBefore, "her yes didn't put the keychain copy beside the library")
            expect(!seen.owedAfterYes, "the offer is still owed after her yes")
        case .lostKeyFileComesBack:
            expect(ctx.lostKeyFile.keyFileAfter != nil && ctx.lostKeyFile.keyFileAfter == ctx.lostKeyFile.keyFileBefore,
                   "the key file didn't come back as it was")
            expect(ctx.lostKeyFile.mirrorAfter == ctx.lostKeyFile.keyFileBefore, "it didn't come from the sealed copy")
            expect(!ctx.lostKeyFile.backupPairsHaveKeyFiles.isEmpty && ctx.lostKeyFile.backupPairsHaveKeyFiles.allSatisfy { $0 },
                   "not every backup carries its key file")
        case .syncedLibraryRecoversWithTheWords:
            let nothing = ctx.recovery.lobby?.noKeyFileAnywhere
            expect(nothing != nil, "the lobby didn't say nothing is left")
            expect(nothing?.accountRoad == true, "it didn't name the account road")
            expect(ctx.recovery.vaultOpensWithWords, "the twelve words don't open the account")
            expect(ctx.recovery.heldEveryKey, "the account doesn't give back every sync key it has had")
        case .notTypedHere:
            failures.append("a sentence this road doesn't type was asked to hold")
        case .all(let facts):
            for fact in facts { failures += check(fact, ctx) }
        case .useCastleNamesCopiesItCantDelete(let subject):
            guard let copy = walk.copies[subject] else { failures.append("no \(subject.rawValue)"); break }
            let named = ctx.useCastleDoor?.words.contains { words in
                if case .copiesUnderAKeyThisMacCantDelete(let ids) = words { return ids.contains(copy.id) }
                return false
            } ?? false
            expect(named, "Use Castle's door didn't name \(subject.rawValue) as under a key this Mac can't delete")
            let id = target(subject)?.own?.apple?.keyID
            expect(id.map { library?.section.retiredAppleKeyIDs.contains($0) == true } ?? false,
                   "its Apple lock's key isn't recorded retired (deleted on sight)")
        case .appleLockKeptInAnAccountSheLeft(let subject):
            guard let id = target(subject)?.own?.apple?.keyID else {
                failures.append("\(subject.rawValue)'s own key file has no Apple lock")
                break
            }
            let holding = world.appleAccounts.filter { _, account in
                account.liveItems.contains { $0.value.value.appleKey?.id == id }
            }.map(\.key)
            expect(!holding.isEmpty, "no Apple account still holds \(subject.rawValue)'s Apple key — it was deleted")
            let signedIn = Set(walk.hers.compactMap(\.appleAccount))
            expect(holding.allSatisfy { !signedIn.contains($0) },
                   "an Apple account holding \(subject.rawValue)'s Apple key is one a device of hers is signed into")
        case .noTouchIDItemForAnyKeyItHasHad:
            let had = Set(live?.heldFingerprints ?? []).union([fingerprint].compactMap { $0 })
            let touch = mac.keychain.local.keys.filter { $0.service == ProtectionNames.custodyService }
                .compactMap { ProtectionNames.parseCustodyAccount($0.account, scope: SWorld.scope) }
                .filter { $0.class == .touchid && had.contains($0.fingerprint) }
            expect(touch.isEmpty, "\(touch.count) Touch ID item(s) left for keys the library has had")
        }
        return failures
    }
}
