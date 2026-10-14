//
//  Alphabet.swift
//  VariorumCoreTests — VX-305 U4: THE ACTION ALPHABET (design §4.1): every
//  user act, every device and Apple-account event, an older build on any
//  device, and the adversary's acts — all with the login password — each ONE
//  step. A crash can ride any act (`crash(_:afterWrites:)`). The world applies
//  a step, then the promises are checked (`Promises.swift`).
//

import CryptoKit
import Foundation

@testable import VariorumCore

/// What she types at a follow.
enum Typing: String, Equatable, CaseIterable {
    case passphrase
    case words
    /// The passphrase she had before a change elsewhere (VX-113).
    case oldPassphrase
}

/// How a different library's pair lands (§3.7): one secret unlocks it, the
/// other typed or made new — or none for a Standard pair through an Apple key
/// readable here.
enum LandTyping: String, Equatable, CaseIterable {
    case passphraseWordsTyped
    case passphraseWordsMadeNew
    case wordsPassphraseMadeNew
    case nothing
}

enum ResetVia: String, Equatable, CaseIterable {
    case touchID
    case words
    case plainConfirm
}

/// The adversary's single-item edits (all with the login password).
enum Tamper: String, Equatable, CaseIterable {
    /// A Castle key file planted with an Apple wrap of its key.
    case plantAppleWrap
    /// The live key file's words lock dropped.
    case dropWordsLock
    /// A plan sealed under a key the library never had.
    case plantPlan
    /// The memory item's sealed settings edited (gate, export) — its seal breaks.
    case editSealedSetting
    case replayPlan
    case replayMemory
    case replayKeyFile
    case replayLibraryFile
    /// Both homes of this Mac's facts rolled back together (the stated limit).
    case replayBothHomes
    case deleteMemoryItem
    case deleteTouchIDItem
    case deleteKeyFile
    /// The key file and the memory item both deleted.
    case deleteKeyFileAndMemory
}

enum OlderAct: String, Equatable, CaseIterable {
    case leaveCastle
    case follow
    case relink
    case backup
}

indirect enum Action: Equatable {
    // The user's acts.
    case launch(String)
    case lock(String)
    case createLibrary(String, secrets: Bool)
    case useCastle(String, GateStyle, newWords: Bool)
    case useStandard(String)
    case replaceAllKeys(String, newWords: Bool)
    case relinkAccount(String)
    case relinkLibraryArm(String)
    case retireOldSharedKey(String)
    case moveOffSharedKey(String)
    case signIn(String, account: String)
    case signOut(String)
    /// Turn on sync as the signed-in account — set up (no vault) or join.
    case turnOnSync(String)
    case move(String)
    case thisMacOnly(String, ProtectionMode?)
    case stopSyncingHere(String, forgotPassphrase: Bool)
    case deleteAccountHere(String)
    case resumeSync(String)
    case follow(String, Typing)
    case finishLeave(String, mint: Bool)
    case changePassphrase(String)
    case resetPassphrase(String, ResetVia)
    case regenerateWords(String)
    /// The backup service: a pair under the current key, then retention.
    case backup(String)
    /// Open the n-th newest copy of the library in the slot.
    case restoreBackup(String, newest: Int)
    case openOlderLibrary(String)
    case sendLibrary(from: String, to: String)
    case land(String, LandTyping)
    case plaintextExport(String)
    case offerDelete(String)
    case setGate(String, GateStyle)
    case answerRearm(String, yes: Bool)
    case setIdleLock(String, minutes: Int?)
    case setScheduledExport(String, Bool)
    case answerCorner45(String, ProtectionMode)
    case confirmMode(String)
    // The device and the Apple account.
    case addFinger(String)
    case removeFinger(String)
    case closeLid(String)
    case openLid(String)
    case unplugKeyboard(String)
    case plugKeyboard(String)
    case lockout(String)
    case clearLockout(String)
    case macOSUpdate(String)
    case iCloudOff(String)
    case iCloudOn(String)
    case syncICloud(String)
    case switchAppleID(String, to: String)
    case resetICloudKeychain(String)
    case wipeKeychain(String)
    case replaceMac(String, carriesMemory: Bool)
    case cloneMac(from: String, to: String)
    case goOffline(String)
    case goOnline(String)
    case timeMachineSnapshot(String)
    case timeMachineRollback(String)
    case deleteContainerAndOpenOldCopy(String)
    case shareBackupFolder(String, account: String)
    /// A crash after the n-th write of an act.
    case crash(Action, afterWrites: Int)
    case olderBuild(String, OlderAct, typing: Typing?)
    case updateToNewBuild(String)
    // The adversary.
    case tamper(String, Tamper)
    case plantPair(String)
    /// The world settles: iCloud propagates, every device opens, follows and
    /// heals what it's offered.
    case settle

    /// The device the action acts on.
    var device: String? {
        let mirror = Mirror(reflecting: self)
        guard let payload = mirror.children.first?.value else { return nil }
        if let name = payload as? String { return name }
        for child in Mirror(reflecting: payload).children { if let name = child.value as? String { return name } }
        if case .crash(let action, _) = self { return action.device }
        return nil
    }
}

enum StepResult: Equatable {
    case done
    case refused(String)
    case crashed
}

extension SWorld {
    // MARK: - Applying a step

    @discardableResult
    func apply(_ action: Action) async -> StepResult {
        advance()
        stepLog.append("▸ \(action)")
        let result: StepResult
        do {
            try await perform(action)
            result = .done
        } catch is SimulatedCrash {
            if let name = action.device { device(name).die() }
            result = .crashed
        } catch {
            result = .refused(String(describing: error))
        }
        if case .refused(let why) = result { stepLog.append("  refused: \(why)") }
        if case .crashed = result { stepLog.append("  crashed") }
        noteVaults()
        return result
    }

    /// Open the app on `device` if it isn't (a user act needs it open).
    func opened(_ device: SDevice) async throws -> (ProtectionExecutor, UnlockedLibrary) {
        guard device.build == .new else { throw WorldRefusal.olderBuild }
        if !device.isOpen { try await launch(device) }
        guard let executor = device.executor, let library = device.library else { throw WorldRefusal.notOpen }
        capture(device)
        return (executor, library)
    }

    /// Run an executor act on the open library, keeping the device's copy of
    /// the library current whatever happens.
    func act(_ device: SDevice, _ body: (ProtectionExecutor, inout UnlockedLibrary) async throws -> ActOutcome?) async throws {
        let (executor, start) = try await opened(device)
        var library = start
        let before = library.record
        defer {
            if device.executor != nil { device.library = library }
        }
        let outcome = try await body(executor, &library)
        device.lastOutcome = outcome
        device.library = library
        afterAct(device, before: before)
    }

    /// The truth an act leaves: the keys born in Castle, a leave's moment.
    func afterAct(_ device: SDevice, before: ProtectionRecord?) {
        noteBirths(device)
        guard let record = device.library?.record else { return }
        if before?.mode == .castle, record.mode == .standard {
            truth.leftCastleAt[device.name] = clock
            truth.keptByLeave[device.name, default: []].formUnion(before?.familyTree.fingerprints ?? [])
        }
        if before?.libraryID == record.libraryID, let account = before?.account, record.account == nil {
            // A leave: the library's own secrets start from the account's.
            let own = holder(device, account: nil, libraryID: record.libraryID)
            if truth.known[own] == nil || truth.known[own] != known(account) {
                let k = known(account)
                setKnown(own, passphrase: k.passphrase, words: k.words)
            }
        }
    }

    func capture(_ device: SDevice) {
        let slot = device.slot.flatMap { device.container.files[SPath.slot] == nil ? nil : SFile.library($0) }
        let memoryName = device.slot.map { KName.memory(Self.scope, $0.libraryID) }
        device.captures.append(DeviceCapture(
            slot: slot, liveKeyFile: device.container.files[SPath.liveKeyFile],
            memory: memoryName.flatMap { device.keychain.local[$0] }, memoryName: memoryName,
            plan: device.container.files[SPath.plan]))
        if device.captures.count > 8 { device.captures.removeFirst() }
    }

    /// The vaults' Castle-era corpus keys (§3.9), as ground truth.
    func noteVaults() {
        for (_, account) in server.accounts where account.format.masterWrappedByAppleHeld == nil && account.format.appleKeyID == nil {
            if let id = account.format.classKey(for: .corpus)?.keyID { truth.castleCorpusKeyIDs.insert(id) }
        }
    }

    // MARK: - The acts

    func perform(_ action: Action) async throws {
        switch action {
        case .launch(let name):
            let d = device(name)
            if d.isOpen { lock(d) }
            try await launch(d)
            capture(d)
        case .lock(let name):
            lock(device(name))
        case .createLibrary(let name, let secrets):
            let d = device(name)
            guard d.build == .new, d.slot == nil else { throw WorldRefusal.noLibrary }
            let p = secrets ? newPassphrase() : nil, w = secrets ? newWords() : nil
            let executor = newExecutor(d, libraryID: "")
            let library = try executor.createLibrary(passphrase: p, words: w)
            d.executor = executor
            d.library = library
            setKnown(holder(d, account: nil, libraryID: library.record!.libraryID), passphrase: p, words: w)
        case .useCastle(let name, let gate, let makeNewWords):
            let d = device(name)
            try await act(d) { executor, library in
                let holder = self.holder(d, account: library.record?.account, libraryID: library.record!.libraryID)
                var k = self.known(holder)
                let assessment = self.assessed(d)
                if let sheet = assessment.retirement {
                    for subject in sheet.routes.wouldStopOpening + sheet.routes.appleKeyAlone {
                        if case .copy(let id) = subject { self.truth.listedBySheet.insert(id) }
                    }
                    for other in self.devices where other.build == .older { self.truth.olderWhenRetired.insert(other.name) }
                }
                let words = (makeNewWords || k.words == nil) ? self.newWords() : k.words!
                let passphrase = k.passphrase ?? self.newPassphrase()
                let typed = TypedSecrets(passphrase: passphrase, words: words, wordsAreNew: words != k.words)
                let outcome = try await executor.useCastle(&library, typed: typed, gate: gate, moves: self.moveSubjects(d))
                k.passphrase = passphrase
                k.words = words
                if k != self.known(holder) { self.setKnown(holder, passphrase: passphrase, words: words) }
                return outcome
            }
        case .useStandard(let name):
            let d = device(name)
            try await act(d) { executor, library in try await executor.useStandard(&library, typed: self.typedFor(d)) }
        case .replaceAllKeys(let name, let makeNewWords):
            let d = device(name)
            try await act(d) { executor, library in
                let holder = self.slotHolder(d)!
                let k = self.known(holder)
                let words = makeNewWords ? self.newWords() : k.words
                let outcome = try await executor.replaceAllKeys(
                    &library, typed: TypedSecrets(passphrase: k.passphrase, words: words, wordsAreNew: makeNewWords))
                if makeNewWords { self.setKnown(holder, passphrase: k.passphrase, words: words) }
                return outcome
            }
        case .relinkAccount(let name):
            let d = device(name)
            try await act(d) { executor, library in
                try await executor.relinkAccount(&library, passphrase: self.known(self.slotHolder(d)!).passphrase ?? "")
            }
        case .relinkLibraryArm(let name):
            let d = device(name)
            try await act(d) { executor, library in
                let subjects = self.assessed(d).acts.compactMap { act -> [String]? in
                    if case .relinkLibraryArm(let ids) = act { return ids }
                    return nil
                }.flatMap { $0 }
                let catalog = self.catalog(d)
                let others = subjects.compactMap { catalog.keyFile(id: $0)?.library }.filter { $0 != library.record?.libraryID }
                return try await executor.relinkLibraryArm(&library, otherLibraries: others)
            }
        case .retireOldSharedKey(let name):
            let d = device(name)
            try await act(d) { executor, library in
                for other in self.devices where other.build == .older { self.truth.olderWhenRetired.insert(other.name) }
                if let sheet = self.assessed(d).retirement {
                    for subject in sheet.routes.wouldStopOpening + sheet.routes.appleKeyAlone {
                        if case .copy(let id) = subject { self.truth.listedBySheet.insert(id) }
                    }
                }
                return try await executor.retireOldSharedKey(&library, moves: self.moveSubjects(d))
            }
        case .moveOffSharedKey(let name):
            let d = device(name)
            try await act(d) { executor, library in try await executor.moveOffSharedKey(&library, subjects: self.moveSubjects(d)) }
        case .signIn(let name, let account):
            let d = device(name)
            d.session = .signedIn(accountID: account, email: nil)
            d.executor?.configuration.session = d.session
            if let executor = d.executor, d.online { _ = try? await executor.readVault(accountID: account) }
        case .signOut(let name):
            let d = device(name)
            d.session = .signedOut
            d.executor?.configuration.session = .signedOut
        case .turnOnSync(let name):
            let d = device(name)
            guard let account = d.session.accountID else { throw ExecutorRefusal.noAccountSignedIn }
            try await act(d) { executor, library in
                let own = self.holder(d, account: nil, libraryID: library.record!.libraryID)
                if self.server.snapshot(account) == nil {
                    var k = self.known(own)
                    let p = k.passphrase ?? self.newPassphrase(), w = k.words ?? self.newWords()
                    let typed = TypedSecrets(passphrase: p, words: w, wordsAreNew: k.words == nil)
                    let outcome = try await executor.setUpSync(&library, typed: typed)
                    k.passphrase = p
                    k.words = w
                    self.setKnown(account, passphrase: p, words: w)
                    if k != self.known(own) { self.setKnown(own, passphrase: p, words: w) }
                    return outcome
                }
                let k = self.known(account)
                return try await executor.enroll(&library, typed: TypedSecrets(passphrase: k.passphrase, words: k.words))
            }
        case .move(let name):
            let d = device(name)
            guard let account = d.session.accountID else { throw ExecutorRefusal.noAccountSignedIn }
            try await act(d) { executor, library in
                let k = self.known(account)
                return try await executor.move(&library, typed: TypedSecrets(passphrase: k.passphrase, words: k.words))
            }
        case .thisMacOnly(let name, let mode):
            let d = device(name)
            try await act(d) { executor, library in
                try await executor.leaveAccount(.thisMacOnly, &library, typed: self.typedFor(d), mode: mode)
            }
        case .stopSyncingHere(let name, let forgot):
            let d = device(name)
            try await act(d) { executor, library in
                var typed = self.typedFor(d)
                var fresh: String?
                if forgot, library.record?.mode == .standard {
                    fresh = self.newPassphrase()
                    typed = TypedSecrets(words: typed.words, newPassphrase: fresh)
                }
                let account = library.record?.account
                let outcome = try await executor.leaveAccount(.stopSyncingHere, &library, typed: typed)
                if let fresh, let account {
                    let own = self.holder(d, account: nil, libraryID: library.record!.libraryID)
                    self.setKnown(own, passphrase: fresh, words: self.known(account).words)
                }
                return outcome
            }
        case .deleteAccountHere(let name):
            let d = device(name)
            try await act(d) { executor, library in
                let account = library.record?.account
                let outcome = try await executor.leaveAccount(.deleteAccountHere, &library, typed: self.typedFor(d))
                if let account { self.server.delete(accountID: account) }
                return outcome
            }
        case .resumeSync(let name):
            let d = device(name)
            try await act(d) { executor, library in
                guard let account = library.record?.account else { throw ExecutorRefusal.notSynced }
                let own = self.known(self.holder(d, account: nil, libraryID: library.record!.libraryID))
                let acct = self.known(account)
                // The secret the vault opens, and the one made new at the landing.
                let typed = TypedSecrets(passphrase: own.passphrase ?? acct.passphrase, words: own.words ?? acct.words)
                return try await executor.resumeSyncAfterLanding(&library, typed: typed)
            }
        case .follow(let name, let typing):
            let d = device(name)
            try await act(d) { executor, library in
                guard let account = library.record?.account else { throw ExecutorRefusal.notSynced }
                let kind = self.owedFollow(d) ?? .keysReplaced
                return try await executor.follow(&library, kind: kind, typed: self.typed(typing, account))
            }
        case .finishLeave(let name, let mint):
            let d = device(name)
            try await act(d) { executor, library in
                guard let account = library.record?.account else { throw ExecutorRefusal.notSynced }
                let kind: FollowKind = library.record?.mode == .castle ? .intoStandard : .keysReplaced
                return try await executor.follow(
                    &library, kind: kind, typed: self.typed(.passphrase, account), mintingIfTheNamedKeyNeverArrives: mint)
            }
        case .changePassphrase(let name):
            let d = device(name)
            try await act(d) { executor, library in
                let holder = self.slotHolder(d)!
                let k = self.known(holder)
                let fresh = self.newPassphrase()
                let outcome = try await executor.changePassphrase(&library, current: k.passphrase ?? "", new: fresh)
                self.setKnown(holder, passphrase: fresh, words: k.words)
                return outcome
            }
        case .resetPassphrase(let name, let via):
            let d = device(name)
            try await act(d) { executor, library in
                let holder = self.slotHolder(d)!
                let k = self.known(holder)
                let fresh = self.newPassphrase()
                let authorization: ResetAuthorization
                switch via {
                case .touchID: authorization = .touchID
                case .words: authorization = .words(k.words ?? [])
                case .plainConfirm: authorization = .plainConfirm
                }
                let outcome = try await executor.resetPassphrase(&library, authorization: authorization, new: fresh)
                self.setKnown(holder, passphrase: fresh, words: k.words)
                return outcome
            }
        case .regenerateWords(let name):
            let d = device(name)
            try await act(d) { executor, library in
                let holder = self.slotHolder(d)!
                let k = self.known(holder)
                let fresh = self.newWords()
                let outcome = try await executor.regenerateWords(&library, passphrase: k.passphrase ?? "", newWords: fresh)
                self.setKnown(holder, passphrase: k.passphrase, words: fresh)
                return outcome
            }
        case .backup(let name):
            try await backupService(device(name))
        case .restoreBackup(let name, let n):
            try await restoreBackup(device(name), newest: n)
        case .openOlderLibrary(let name):
            try await openOlderLibrary(device(name))
        case .sendLibrary(let from, let to):
            let sender = device(from), receiver = device(to)
            let folder = "\(CatalogNames.handOffPrefix)\(CatalogNames.stampString(clock).prefix(10))"
            try await act(sender) { executor, library in try await executor.sendLibrary(&library, to: folder) }
            senderHolders[folder] = slotHolder(sender)
            for path in sender.container.paths(under: folder + "/") { receiver.container.files[path] = sender.container.files[path] }
            receiver.incoming.append(folder)
        case .land(let name, let typing):
            try await land(device(name), typing)
        case .plaintextExport(let name):
            let d = device(name)
            try await act(d) { executor, library in
                try await executor.plaintextExport(&library, typed: self.typedFor(d), to: "export-\(self.rng.int(0..<9999))")
            }
        case .offerDelete(let name):
            let d = device(name)
            try await act(d) { executor, library in
                let catalog = self.catalog(d)
                let others = catalog.copies.filter { $0.library != nil && $0.library != library.record?.libraryID }
                guard !others.isEmpty else { throw ExecutorRefusal.nothingToDo }
                return try await executor.offerDelete(&library, copies: others, catalog: catalog)
            }
        case .setGate(let name, let style):
            let d = device(name)
            try await act(d) { executor, library in
                var settings = library.section.settings
                settings.gateStyle = style
                return try await executor.changeSettings(&library, to: settings, passphrase: self.typedFor(d).passphrase)
            }
        case .answerRearm(let name, let yes):
            let d = device(name)
            try await act(d) { executor, library in try await executor.answerTouchIDRearm(&library, yes: yes) }
        case .setIdleLock(let name, let minutes):
            let d = device(name)
            try await act(d) { executor, library in
                var settings = library.section.settings
                settings.idleLockMinutes = minutes
                return try await executor.changeSettings(&library, to: settings)
            }
        case .setScheduledExport(let name, let on):
            let d = device(name)
            try await act(d) { executor, library in
                var settings = library.section.settings
                settings.scheduledExport = on
                return try await executor.changeSettings(&library, to: settings)
            }
        case .answerCorner45(let name, let mode):
            let d = device(name)
            d.corner45Answer = mode
            try await act(d) { executor, library in
                if mode == .castle { return try await executor.confirmMode(&library, as: .castle) }
                return try await executor.useStandard(&library, typed: self.typedFor(d))
            }
        case .confirmMode(let name):
            let d = device(name)
            try await act(d) { executor, library in
                guard let mode = library.record?.mode else { throw ExecutorRefusal.recordMissing }
                return try await executor.confirmMode(&library, as: mode)
            }

        // MARK: The device and the Apple account
        case .addFinger(let name):
            let d = device(name)
            d.biometry.fingers += 1
            d.biometry.generation += 1
        case .removeFinger(let name):
            let d = device(name)
            guard d.biometry.fingers > 0 else { throw WorldRefusal.notOpen }
            d.biometry.fingers -= 1
            d.biometry.generation += 1
        case .closeLid(let name): device(name).biometry.lidClosed = true
        case .openLid(let name): device(name).biometry.lidClosed = false
        case .unplugKeyboard(let name): device(name).biometry.keyboardDisconnected = true
        case .plugKeyboard(let name): device(name).biometry.keyboardDisconnected = false
        case .lockout(let name): device(name).biometry.lockout = true
        case .clearLockout(let name): device(name).biometry.lockout = false
        case .macOSUpdate(let name):
            let d = device(name)
            d.biometry.osEpoch += 1
            lock(d)
        case .iCloudOff(let name):
            device(name).iCloudOn = false
        case .iCloudOn(let name):
            let d = device(name)
            d.iCloudOn = true
            syncICloud(d)
        case .syncICloud(let name):
            syncICloud(device(name))
        case .switchAppleID(let name, let to):
            let d = device(name)
            truth.lostAppleKeys.formUnion(readableAppleKeys(d).keys)
            d.keychain.synced.removeAll()
            d.appleAccount = to
            syncICloud(d)
        case .resetICloudKeychain(let name):
            let d = device(name)
            guard let id = d.appleAccount, let account = appleAccounts[id] else { throw WorldRefusal.notOpen }
            for other in devices where other.appleAccount == id {
                truth.lostAppleKeys.formUnion(readableAppleKeys(other).keys)
                other.keychain.synced.removeAll()
            }
            truth.lostAppleKeys.formUnion(account.cloud.keys.compactMap {
                if case .own(let key)? = ProtectionNames.parseAppleKeyAccount($0.account, scope: Self.scope) { return key }
                return nil
            })
            account.cloud.removeAll()
        case .wipeKeychain(let name):
            let d = device(name)
            d.keychain = DeviceKeychain()
            lock(d)
            syncICloud(d)
        case .replaceMac(let name, let carriesMemory):
            let d = device(name)
            lock(d)
            d.machine = MachineIdentity(hardware: rng.uuid().uppercased(), login: d.machine.login)
            let memory = d.keychain.local.filter { $0.key.service == ProtectionNames.memoryService }
            d.keychain = DeviceKeychain()
            if carriesMemory { d.keychain.local = memory }
            d.biometry = BiometryFake(generation: d.biometry.generation + 100)
            syncICloud(d)
        case .cloneMac(let from, let to):
            let source = device(from), clone = device(to)
            lock(clone)
            clone.container = FolderFS()
            clone.container.files = source.container.files
            clone.machine = MachineIdentity(hardware: rng.uuid().uppercased(), login: source.machine.login)
            clone.keychain = DeviceKeychain()
            clone.keychain.local = source.keychain.local.filter { $0.key.service == ProtectionNames.memoryService }
            clone.appleAccount = source.appleAccount
            clone.session = source.session
            clone.build = source.build
            clone.biometry = BiometryFake(generation: source.biometry.generation + 50)
            syncICloud(clone)
        case .goOffline(let name): device(name).online = false
        case .goOnline(let name): device(name).online = true
        case .timeMachineSnapshot(let name):
            let d = device(name)
            var files = d.container.snapshot()
            files[SPath.plan] = nil
            d.timeMachine.append(files)
        case .timeMachineRollback(let name):
            let d = device(name)
            guard let files = d.timeMachine.last else { throw WorldRefusal.noLibrary }
            lock(d)
            let plan = d.container.files[SPath.plan]
            d.container.files = files
            d.container.files[SPath.plan] = plan
        case .deleteContainerAndOpenOldCopy(let name):
            try deleteContainerAndOpenOldCopy(device(name))
        case .shareBackupFolder(let name, let account):
            device(name).farFolderAccount = account
        case .crash(let inner, let n):
            guard let name = inner.device else { throw WorldRefusal.notOpen }
            let d = device(name)
            if !d.isOpen, d.build == .new { try await launch(d) }
            d.crashAfterWrites = n
            defer { d.crashAfterWrites = nil }
            try await perform(inner)
        case .olderBuild(let name, let act, let typing):
            let d = device(name)
            guard d.build == .older else { throw WorldRefusal.olderBuild }
            switch act {
            case .leaveCastle: try await olderLeaveCastle(d)
            case .follow:
                let account = d.slot?.rowsOwner ?? ""
                let k = known(account)
                let secret: ProtectionSecret? = typing == .words ? k.words.map { .words($0) } : k.passphrase.map { .passphrase($0) }
                try await olderFollow(d, typing: secret)
            case .relink: try olderRelink(d)
            case .backup: try olderBackup(d)
            }
        case .updateToNewBuild(let name):
            let d = device(name)
            lock(d)
            d.build = .new
        // MARK: The adversary
        case .tamper(let name, let tamper):
            try tamperWith(device(name), tamper)
        case .plantPair(let name):
            try plantPair(device(name))
        case .settle:
            await settleWorld()
        }
    }

    /// The secret she types for an account.
    func typed(_ typing: Typing, _ holder: String) -> TypedSecrets {
        let k = known(holder)
        switch typing {
        case .passphrase: return TypedSecrets(passphrase: k.passphrase)
        case .words: return TypedSecrets(words: k.words)
        case .oldPassphrase:
            let older = k.timeline.reversed().compactMap(\.passphrase).first { $0 != k.passphrase }
            return TypedSecrets(passphrase: older ?? k.passphrase)
        }
    }

    /// The follow `assess` owes this device, if any.
    func owedFollow(_ device: SDevice) -> FollowKind? {
        for act in assessed(device).acts {
            if case .follow(let kind, _, _) = act { return kind }
        }
        return nil
    }

    /// The move's subjects — the serving key files (catalog ids) of the other
    /// libraries `assess`'s MovePlan names.
    func moveSubjects(_ device: SDevice) -> [String] {
        let assessment = assessed(device)
        let catalog = catalog(device)
        return assessment.movePlan.otherLibraries.compactMap { library in
            catalog.copies(ofLibrary: library).max { ($0.stamp ?? .distantPast) < ($1.stamp ?? .distantPast) }
                .flatMap { catalog.servingKeyFiles(of: $0).first?.id }
        }
    }

    // MARK: - Copies

    /// The backup service (phase 2/5's): a pair under the current key, frozen
    /// with the live key file, then retention over THIS Mac's copies of THIS
    /// library (VX-302). Every prune is recorded for promise 11.
    func backupService(_ device: SDevice) async throws {
        let (_, library) = try await opened(device)
        guard !device.paused, let live = liveKeyFile(device), live.fingerprint == library.fingerprint, let slot = device.slot else {
            throw ExecutorRefusal.noLiveKeyFile
        }
        writePair(device, image: slot, keyFile: .format3(live), deviceID: library.section.deviceID)
        let outcome = Retention.plan(
            catalog: catalog(device), libraryID: slot.libraryID, thisMac: library.section.deviceID, guards: guards)
        let catalog = catalog(device)
        for id in outcome.prune {
            if let copy = catalog.copies.first(where: { $0.id == id }) {
                truth.prunes.append((by: device.name, mac8: library.section.mac8, library: slot.libraryID, copy: copy))
            }
            if let (fs, path) = DeviceLeaves(world: self, device: device).resolve(id) {
                fs.files[path] = nil
                fs.files[SPath.pair(of: path)] = nil
            }
            truth.copies[id] = nil
        }
    }

    /// The key a copy is under, by the roads this device has (her finger, her
    /// custody, the live history and anchor, the copy's own pair with the
    /// secrets of its day and today's).
    func openerFor(_ device: SDevice, fingerprint: String, pair: KeyFileDocument?, day: Date?) -> StoreKey? {
        var keys: [StoreKey] = []
        if let library = device.library {
            keys.append(library.key)
            if let live = library.keyFile, live.fingerprint == library.fingerprint {
                keys += ((try? live.historyKeys(currentKey: library.key)) ?? []).map(\.key)
            }
        }
        for name in device.keychain.names(service: ProtectionNames.custodyService) {
            if let item = device.keychain.item(name), let key = pressRead(device, item)?.libraryKey { keys.append(key) }
        }
        if let hit = keys.first(where: { PF.fp($0) == fingerprint }) { return hit }
        var secrets: [ProtectionSecret] = []
        if let holder = slotHolder(device) {
            let k = known(holder)
            let then = day.map { k.at($0) }
            for p in [k.passphrase, then?.passphrase].compactMap({ $0 }) { secrets.append(.passphrase(p)) }
            for w in [k.words, then?.words].compactMap({ $0 }) { secrets.append(.words(w)) }
        }
        if let live = liveKeyFile(device), let anchor = live.anchor {
            for secret in secrets {
                if let contents = try? anchor.open(secret, floor: PF.floor), let hit = contents.keys.first(where: { $0.fingerprint == fingerprint }) {
                    return hit.key
                }
            }
        }
        switch pair {
        case .format3(let file)?:
            for secret in secrets { if let key = try? file.open(secret, floor: PF.floor), PF.fp(key) == fingerprint { return key } }
            let apple = readableAppleKeys(device)
            if let wrap = file.apple, let key = apple[wrap.keyID], let opened = try? file.open(apple: key) { return opened }
        case .legacy(let legacy)?:
            for secret in secrets {
                switch secret {
                case .passphrase(let p): if let key = try? legacy.open(passphrase: p, floor: PF.floor) { return key }
                case .words(let w): if let key = try? legacy.open(words: w) { return key }
                default: break
                }
            }
            if let shared = oldSharedKey(device), let key = try? legacy.open(sharedApple: shared) { return key }
        case nil:
            break
        }
        return nil
    }

    /// Open the n-th newest copy of the slot's library (Data Safety's
    /// restore): the open rule's verdict, then the act.
    func restoreBackup(_ device: SDevice, newest n: Int) async throws {
        let (_, library) = try await opened(device)
        let catalog = catalog(device)
        let own = catalog.copies.filter { $0.library == library.record?.libraryID && $0.kind != .previousLibrary }
            .sorted { ($0.stamp ?? .distantPast) > ($1.stamp ?? .distantPast) }
        guard !own.isEmpty else { throw ExecutorRefusal.nothingToDo }
        let copy = own[min(n, own.count - 1)]
        try await openCopyByRule(device, copy: copy, catalog: catalog)
    }

    func openOlderLibrary(_ device: SDevice) async throws {
        _ = try await opened(device)
        let catalog = catalog(device)
        guard let copy = catalog.copies.filter({ $0.kind == .previousLibrary })
            .max(by: { ($0.stamp ?? .distantPast) < ($1.stamp ?? .distantPast) }) else { throw ExecutorRefusal.nothingToDo }
        try await openCopyByRule(device, copy: copy, catalog: catalog)
    }

    func openCopyByRule(_ device: SDevice, copy: CatalogCopy, catalog: Catalog) async throws {
        guard let library = device.library, let record = library.record,
              let (fs, path) = DeviceLeaves(world: self, device: device).resolve(copy.id),
              let image = fs.files[path]?.library else { throw ExecutorRefusal.nothingToDo }
        let pair = catalog.servingKeyFiles(of: copy).first?.document
        let target = OpenTarget(
            libraryID: record.libraryID, mode: record.mode, account: record.account, familyTree: library.familyTree,
            liveHistoryFingerprints: [library.fingerprint] + (library.keyFile?.history.map(\.fingerprint) ?? []))
        var facts: LegacyKeyFileFacts?
        if case .legacy(let legacy)? = pair { facts = LegacyKeyFileFacts(legacy.envelope) }
        if case .format3(let file)? = pair {
            facts = LegacyKeyFileFacts(hasAppleWrap: file.apple != nil || file.sharedApple != nil, hasPassphraseWrap: file.passphrase != nil)
        }
        let verdict = OpenRule.verdict(OpenFacts(
            libraryID: image.libraryID, keyFingerprint: image.fingerprint, recordMode: image.record?.mode, keyFileFacts: facts,
            rowsAccount: image.rowsOwner, synced: image.record?.account != nil, target: target), guards: guards)
        guard let opener = openerFor(device, fingerprint: image.fingerprint, pair: pair, day: copy.stamp) else {
            throw WorldRefusal.cannotOpen
        }
        switch verdict {
        case .ownLine:
            let before = record
            try await act(device) { executor, library in
                try await executor.openCopy(&library, copyID: copy.id, opener: opener, copyRecord: image.record)
            }
            truth.opens.append((device: device.name, before: before, after: device.library?.record))
        case .differentLibrary:
            guard let pair else { throw ExecutorRefusal.nothingToDo }
            try await landPair(device, LandingPair(copyID: copy.id, keyFile: pair, record: image.record), opener: opener,
                               typing: .passphraseWordsTyped, holderOfPair: holder(device, account: image.record?.account, libraryID: image.libraryID))
        case .raisesToCastle, .plaintextExport:
            throw ExecutorRefusal.nothingToDo
        }
    }

    /// Land the newest pair Send Library brought to `device`.
    func land(_ device: SDevice, _ typing: LandTyping) async throws {
        guard let folder = device.incoming.last,
              case .library(let image)? = device.container.files["\(folder)/\(SPath.slot)"],
              let document = device.container.files["\(folder)/\(SPath.liveKeyFile)"]?.keyFile
        else { throw ExecutorRefusal.nothingToDo }
        _ = try await opened(device)
        let senderHolder = senderHolders[folder] ?? holder(device, account: image.record?.account, libraryID: image.libraryID)
        let k = known(senderHolder)
        var opener: StoreKey?
        guard case .format3(let file) = document else { throw ExecutorRefusal.nothingToDo }
        switch typing {
        case .passphraseWordsTyped, .passphraseWordsMadeNew:
            opener = try? file.open(.passphrase(k.passphrase ?? ""), floor: PF.floor)
        case .wordsPassphraseMadeNew:
            opener = k.words.flatMap { try? file.open(.words($0), floor: PF.floor) }
        case .nothing:
            if let wrap = file.apple, let key = readableAppleKeys(device)[wrap.keyID] { opener = try? file.open(apple: key) }
        }
        guard let opener else { throw WorldRefusal.cannotOpen }
        try await landPair(device, LandingPair(copyID: "container:\(folder)/\(SPath.slot)", keyFile: document, record: image.record),
                           opener: opener, typing: typing, holderOfPair: senderHolder)
        device.incoming.removeAll { $0 == folder }
    }

    func landPair(_ device: SDevice, _ pair: LandingPair, opener: StoreKey, typing: LandTyping, holderOfPair: String) async throws {
        let k = known(holderOfPair)
        var typed: TypedSecrets
        var landed = (passphrase: k.passphrase, words: k.words)
        switch typing {
        case .passphraseWordsTyped: typed = TypedSecrets(passphrase: k.passphrase, words: k.words)
        case .passphraseWordsMadeNew:
            let w = newWords()
            typed = TypedSecrets(passphrase: k.passphrase, words: w, wordsAreNew: true)
            landed.words = w
        case .wordsPassphraseMadeNew:
            let p = newPassphrase()
            typed = TypedSecrets(words: k.words, newPassphrase: p)
            landed.passphrase = p
        case .nothing:
            typed = .none
            landed = (nil, nil)
        }
        let finalTyped = typed
        try await act(device) { executor, library in
            try await executor.land(&library, pair: pair, opener: opener, typed: finalTyped, gate: device.biometry.enrolled ? .touchID : .alwaysAsk)
        }
        guard let record = device.library?.record else { return }
        // The landed library's own secrets on this Mac (a synced pair's
        // account keeps its own until Resume Sync).
        setKnown(holder(device, account: nil, libraryID: record.libraryID), passphrase: landed.passphrase, words: landed.words)
    }

    // MARK: - The adversary

    func tamperWith(_ device: SDevice, _ tamper: Tamper) throws {
        let leaf = DeviceLeaves(world: self, device: device)
        guard let slot = device.slot else { throw WorldRefusal.noLibrary }
        let memoryName = KName.memory(Self.scope, slot.libraryID)
        lock(device)
        switch tamper {
        case .plantAppleWrap:
            guard var file = liveKeyFile(device), let key = (device.keychain.names(service: ProtectionNames.custodyService)
                .compactMap { device.keychain.item($0)?.value.libraryKey }.first { PF.fp($0) == file.fingerprint }) else {
                throw WorldRefusal.cannotOpen
            }
            let planted = mintApple()
            addSynced(device, KName.apple(Self.scope, planted.id), KItem(value: .apple(id: planted.id, bytes: PF.bytes(planted.key))))
            file.apple = AppleWrap(keyID: planted.id, wrapped: try AES.KeyWrap.wrap(SymmetricKey(data: key.data), using: planted.key))
            device.container.files[SPath.liveKeyFile] = .keyFile(.format3(file))
        case .dropWordsLock:
            guard var file = liveKeyFile(device) else { throw WorldRefusal.noLibrary }
            file.words = nil
            device.container.files[SPath.liveKeyFile] = .keyFile(.format3(file))
        case .plantPlan:
            let plan = ProtectionPlan(
                libraryID: slot.libraryID, deviceID: rng.uuid(), sequence: 1, act: .deviceSettings,
                steps: [PlanStep(name: "settings")], createdAt: clock,
                parameters: ActParameters(settings: DeviceSettings(gateStyle: .touchID, scheduledExport: true)))
            try leaf.writePlan(try plan.sealed(under: mintKey()))
        case .editSealedSetting:
            guard case .memory(let sealed)? = device.keychain.local[memoryName]?.value,
                  var memory = try? ProtectionCoding.decoder().decode(DeviceMemory.self, from: sealed.payload) else {
                throw WorldRefusal.noLibrary
            }
            memory.deviceSection.settings.scheduledExport = true
            memory.deviceSection.settings.gateStyle = .touchID
            memory.deviceSection.version += 100
            let payload = try ProtectionCoding.canonical(memory)
            device.keychain.local[memoryName]?.value = .memory(Sealed(payload: payload, seal: sealed.seal))
        case .replayPlan:
            guard let plan = device.captures.compactMap(\.plan).first else { throw WorldRefusal.noLibrary }
            device.container.files[SPath.plan] = plan
        case .replayMemory:
            guard let capture = device.captures.first(where: { $0.memory != nil }), let name = capture.memoryName else {
                throw WorldRefusal.noLibrary
            }
            device.keychain.local[name] = capture.memory
        case .replayKeyFile:
            guard let file = device.captures.compactMap(\.liveKeyFile).first else { throw WorldRefusal.noLibrary }
            device.container.files[SPath.liveKeyFile] = file
        case .replayLibraryFile:
            guard let file = device.captures.compactMap(\.slot).first else { throw WorldRefusal.noLibrary }
            device.container.files[SPath.slot] = file
        case .replayBothHomes:
            guard let capture = device.captures.first(where: { $0.slot != nil && $0.memory != nil }), let name = capture.memoryName else {
                throw WorldRefusal.noLibrary
            }
            device.container.files[SPath.slot] = capture.slot
            device.container.files[SPath.liveKeyFile] = capture.liveKeyFile
            device.container.files[SPath.plan] = capture.plan
            device.keychain.local[name] = capture.memory
        case .deleteMemoryItem:
            device.keychain.local[memoryName] = nil
        case .deleteTouchIDItem:
            for name in device.keychain.names(service: ProtectionNames.custodyService) where device.keychain.local[name]?.touchID == true {
                device.keychain.local[name] = nil
            }
        case .deleteKeyFile:
            device.container.files[SPath.liveKeyFile] = nil
        case .deleteKeyFileAndMemory:
            device.container.files[SPath.liveKeyFile] = nil
            device.keychain.local[memoryName] = nil
        }
    }

    /// A crafted pair planted in the iCloud Drive folder: a backup-named
    /// snapshot of THIS library's id under a key the library never had.
    func plantPair(_ device: SDevice) throws {
        guard let slot = device.slot, let far = farFolder(of: device) ?? farFolders[device.appleAccount ?? Self.appleA] else {
            throw WorldRefusal.noLibrary
        }
        let key = mintKey()
        let p = newPassphrase()
        setKnown("planted", passphrase: p, words: nil)
        let file = try KeyFile.building(
            libraryID: slot.libraryID, key: key, epoch: 1,
            locks: NewKeyLocks(passphrase: passphraseKey(p, fastKDF())))
        let name = SPath.snapshot(tick(), PF.fp(key))
        let folder = "\(CatalogNames.backupsFolderName)/\(ProtectionNames.library8(slot.libraryID))/ffffffff"
        far.files["\(folder)/\(name)"] = .library(LibraryImage(libraryID: slot.libraryID, fingerprint: PF.fp(key), record: nil, writing: 99))
        far.files["\(folder)/\(SPath.pair(of: name))"] = .keyFile(.format3(file))
    }

    /// The container deleted; an old copy (the newest in the far folder or a
    /// Time Machine snapshot) opened into the slot as it was.
    func deleteContainerAndOpenOldCopy(_ device: SDevice) throws {
        lock(device)
        var source: (image: LibraryImage, keyFile: KeyFileDocument)?
        if let far = farFolder(of: device) {
            for path in far.files.keys.sorted().reversed() where path.hasSuffix(".sqlite") {
                if let image = far.files[path]?.library, let document = far.files[SPath.pair(of: path)]?.keyFile {
                    source = (image, document)
                    break
                }
            }
        }
        if source == nil, let snapshot = device.timeMachine.first, let image = snapshot[SPath.slot]?.library,
           let document = snapshot[SPath.liveKeyFile]?.keyFile {
            source = (image, document)
        }
        guard let source else { throw WorldRefusal.noLibrary }
        device.container = FolderFS()
        device.container.files[SPath.slot] = .library(source.image)
        switch source.keyFile {
        case .format3: device.container.files[SPath.liveKeyFile] = .keyFile(source.keyFile)
        case .legacy(let legacy): device.container.files[SPath.legacyKeyFile(legacy.fingerprint)] = .keyFile(source.keyFile)
        }
    }

    // MARK: - The world settles

    /// Propagation done, followers followed (§4.1): iCloud Keychain carries
    /// everything; every new-build device signed in opens, follows what it's
    /// owed (typing its passphrase), finishes a leave it may finish, presses
    /// Re-link's library arm where it's offered; repeated until nothing moves.
    func settleWorld() async {
        for _ in 0..<4 {
            propagateAll()
            for device in devices where device.build == .new && device.slot != nil {
                if !device.isOpen { _ = try? await launch(device) }
                guard device.isOpen else { continue }
                if let account = device.library?.record?.account, device.session.accountID == account, device.online {
                    _ = try? await device.executor?.readVault(accountID: account)
                }
                try? await runRepairs(device)
                let assessment = assessed(device)
                for act in assessment.acts {
                    switch act {
                    case .follow:
                        _ = await apply(.follow(device.name, .passphrase))
                    case .relinkLibraryArm:
                        _ = await apply(.relinkLibraryArm(device.name))
                    default:
                        break
                    }
                }
                if assessment.door(.finishLeavingCastle).isOpen {
                    _ = await apply(.finishLeave(device.name, mint: false))
                }
            }
        }
        propagateAll()
        for device in devices where device.isOpen { try? await runRepairs(device) }
    }
}
