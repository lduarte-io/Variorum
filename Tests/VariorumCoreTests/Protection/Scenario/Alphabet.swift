//
//  Alphabet.swift
//  VariorumCoreTests — VX-305 U4: THE ACTION ALPHABET (design §4.1): every
//  user act, every device and Apple-account event, and the adversary's acts —
//  all with the login password — each ONE step (VX-378 U1 cut the older build,
//  rule 26, and the acts whose doors died with the design they served). A crash can ride any act (`crash(_:afterWrites:)`). The world applies
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
    /// The library file replayed alone — kept for the rule-21 pin only
    /// (`CutPinsRule21Tests`): out of the generator's pool (`generated`) until
    /// U4 rebuilds it against U2's refusal. (`replayKeyFile` and
    /// `deleteKeyFileAndMemory` left with the restores — VX-378 U1, rules 21,
    /// 27.)
    case replayLibraryFile
    /// Both homes of this Mac's facts rolled back together (the stated limit).
    case replayBothHomes
    case deleteMemoryItem
    case deleteTouchIDItem
    case deleteKeyFile

    /// The tampers the generator draws from.
    static let generated = allCases.filter { $0 != .replayLibraryFile }
}

indirect enum Action: Equatable {
    // The user's acts.
    case launch(String)
    case lock(String)
    /// Twelve words always (rule 2); a passphrase when `passphrase`.
    case createLibrary(String, passphrase: Bool)
    case useCastle(String, GateStyle, newWords: Bool)
    case useStandard(String)
    case replaceAllKeys(String, newWords: Bool)
    case signIn(String, account: String)
    case signOut(String)
    /// Turn on sync as the signed-in account — set up (no vault) or join.
    case turnOnSync(String)
    case move(String)
    case thisMacOnly(String, ProtectionMode?)
    case stopSyncingHere(String, forgotPassphrase: Bool)
    case deleteAccountHere(String)
    case follow(String, Typing)
    case changePassphrase(String)
    case resetPassphrase(String, ResetVia)
    case regenerateWords(String)
    /// The backup service: a pair under the current key, then retention.
    case backup(String)
    case sendLibrary(from: String, to: String)
    case plaintextExport(String)
    case offerDelete(String)
    case setGate(String, GateStyle)
    case answerRearm(String, yes: Bool)
    case setIdleLock(String, minutes: Int?)
    case setScheduledExport(String, Bool)
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
    // The adversary.
    case tamper(String, Tamper)
    /// Two or three tampers in ONE closed window (VX-305 ladder round 1, the
    /// final call §1(c)): the world's pre-launch settle runs ONCE before the
    /// group (the seed-9 lesson), the posture is captured before it, and the
    /// one relaunch and promise-10 check come after it — so tampers COMPOSE,
    /// which single `.tamper` steps (each bracketed by launches) never do.
    case tamperSequence(String, [Tamper])
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
        return result
    }

    /// Open the app on `device` if it isn't (a user act needs it open).
    func opened(_ device: SDevice) async throws -> (ProtectionExecutor, UnlockedLibrary) {
        if !device.isOpen { try await launch(device) }
        guard let executor = device.executor, let library = device.library else { throw WorldRefusal.notOpen }
        capture(device)
        return (executor, library)
    }

    /// Run an executor act on the open library, keeping the device's copy of
    /// the library current whatever happens.
    func act(_ device: SDevice, _ body: (ProtectionExecutor, inout UnlockedLibrary) async throws -> ActOutcome?) async throws {
        let (executor, start) = try await opened(device)
        // A resume the opening ran settles what its press chose; the state the
        // opening reached (a migration's record) is truth before the act.
        adoptPending(device)
        syncHolders()
        var library = start
        let before = library.record
        defer {
            if device.executor != nil { device.library = library }
        }
        let outcome = try await body(executor, &library)
        device.lastOutcome = outcome
        device.library = library
        afterAct(device, before: before)
        // The assessment refreshes after an act, and its repairs run then (a
        // mode just confirmed — corner 45's answer, the vault's — gets its
        // custody repairs at once, §3.13).
        try await runRepairs(device)
    }

    /// The truth an act leaves: the keys born in Castle; a leave of the
    /// account's secrets. (A leave of Castle's moment — promise 13's — left
    /// with VX-378 U1, rule 13.)
    func afterAct(_ device: SDevice, before: ProtectionRecord?) {
        noteBirths(device)
        guard let record = device.library?.record else { return }
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
        case .createLibrary(let name, let passphrase):
            let d = device(name)
            guard d.slot == nil else { throw WorldRefusal.noLibrary }
            let p = passphrase ? newPassphrase() : nil, w = newWords()
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
                let words = (makeNewWords || k.words == nil) ? self.newWords() : k.words!
                let passphrase = k.passphrase ?? self.newPassphrase()
                let typed = TypedSecrets(passphrase: passphrase, words: words, wordsAreNew: words != k.words)
                self.choose(d, holder: holder, passphrase: passphrase, words: words)
                let outcome = try await executor.useCastle(&library, typed: typed, gate: gate)
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
                if makeNewWords { self.choose(d, holder: holder, passphrase: nil, words: words) }
                let outcome = try await executor.replaceAllKeys(
                    &library, typed: TypedSecrets(passphrase: k.passphrase, words: words, wordsAreNew: makeNewWords))
                if makeNewWords { self.setKnown(holder, passphrase: k.passphrase, words: words) }
                return outcome
            }
        case .signIn(let name, let account):
            let d = device(name)
            d.session = .signedIn(accountID: account, email: nil)
            d.executor?.configuration.session = d.session
            if let executor = d.executor, d.online { _ = try? await executor.readVault(accountID: account) }
            await resumeAtVaultReach(d)
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
                    self.choose(d, holder: own, passphrase: p, words: w)
                    // The account's too: a set-up a crash interrupts finishes on
                    // its resume, and the vault then opens with these.
                    self.choose(d, holder: account, passphrase: p, words: w)
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
                    self.choose(d, holder: self.holder(d, account: nil, libraryID: library.record!.libraryID), passphrase: fresh, words: nil)
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
        case .follow(let name, let typing):
            let d = device(name)
            try await act(d) { executor, library in
                guard let account = library.record?.account else { throw ExecutorRefusal.notSynced }
                // She can press only an open door: the follow is offered when owed
                // (its notice comes from a fresh read of the vault).
                if d.session.accountID == account, d.online { _ = try? await executor.readVault(accountID: account) }
                guard let kind = self.owedFollow(d), self.assessed(d).door(.followNow).isOpen else {
                    throw ExecutorRefusal.nothingToDo
                }
                return try await executor.follow(&library, kind: kind, typed: self.typed(typing, account))
            }
        case .changePassphrase(let name):
            let d = device(name)
            try await act(d) { executor, library in
                let holder = self.slotHolder(d)!
                let k = self.known(holder)
                let fresh = self.newPassphrase()
                self.choose(d, holder: holder, passphrase: fresh, words: nil)
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
                self.choose(d, holder: holder, passphrase: fresh, words: nil)
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
                self.choose(d, holder: holder, passphrase: nil, words: fresh)
                let outcome = try await executor.regenerateWords(&library, passphrase: k.passphrase ?? "", newWords: fresh)
                self.setKnown(holder, passphrase: k.passphrase, words: fresh)
                return outcome
            }
        case .backup(let name):
            try await backupService(device(name))
        case .sendLibrary(let from, let to):
            let sender = device(from), receiver = device(to)
            let folder = "\(CatalogNames.handOffPrefix)\(CatalogNames.stampString(clock).prefix(10))"
            try await act(sender) { executor, library in try await executor.sendLibrary(&library, to: folder) }
            senderHolders[folder] = slotHolder(sender)
            senders[folder] = from
            for path in sender.container.paths(under: folder + "/") { receiver.container.files[path] = sender.container.files[path] }
            receiver.incoming.append(folder)
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
            loseQueuedDeletes(d)
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
                ProtectionNames.parseAppleKeyAccount($0.account, scope: Self.scope)
            })
            account.cloud.removeAll()
        case .wipeKeychain(let name):
            let d = device(name)
            loseQueuedDeletes(d)
            d.keychain = DeviceKeychain()
            lock(d)
            syncICloud(d)
        case .replaceMac(let name, let carriesMemory):
            let d = device(name)
            lock(d)
            d.machine = MachineIdentity(hardware: rng.uuid().uppercased(), login: d.machine.login)
            let memory = d.keychain.local.filter { $0.key.service == ProtectionNames.memoryService }
            loseQueuedDeletes(d)
            d.keychain = DeviceKeychain()
            if carriesMemory { d.keychain.local = memory }
            d.biometry = BiometryFake(generation: d.biometry.generation + 100)
            syncICloud(d)
        case .cloneMac(let from, let to):
            let source = device(from), clone = device(to)
            lock(clone)
            loseQueuedDeletes(clone)
            clone.container = FolderFS()
            clone.container.files = source.container.files
            clone.machine = MachineIdentity(hardware: rng.uuid().uppercased(), login: source.machine.login)
            clone.keychain = DeviceKeychain()
            clone.keychain.local = source.keychain.local.filter { $0.key.service == ProtectionNames.memoryService }
            clone.appleAccount = source.appleAccount
            clone.session = source.session
            clone.biometry = BiometryFake(generation: source.biometry.generation + 50)
            // The same libraries, so the same secrets: a local library's
            // holder is per device in the world's bookkeeping.
            for (holder, known) in truth.known where holder.hasSuffix("@\(from)") {
                truth.known[String(holder.dropLast(from.count)) + to] = known
            }
            syncICloud(clone)
        case .goOffline(let name): device(name).online = false
        case .goOnline(let name):
            let d = device(name)
            d.online = true
            await resumeAtVaultReach(d)
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
            let was = d.slot?.record?.currentFingerprint
            d.container.files = files
            d.container.files[SPath.plan] = plan
            // Her restore: the library file and its key file come back together
            // and the open believes them (the memory follows the restored
            // current key — P-U4-8's rollback, her act). Past a crossing, that
            // is the stated limit's shape (§3.6, P-U4-5 — her 2026-10-14/15
            // ruling: accepted and stated): the keys the restored state names
            // are its own again — Re-link's arm may re-wrap them — and Standard
            // copies made after its moment are the later stretch's (PROVISIONAL
            // P-U4-12: the acceptance read to cover a Time Machine restore).
            if let restored = d.slot?.record, restored.currentFingerprint != was {
                truth.restoredPastCrossing.insert(d.name)
                for (id, copy) in truth.copies where copy.madeOn == d.name && copy.mode == .standard && copy.madeAt > restored.changedAt {
                    truth.rolledBackOver.insert(id)
                }
            }
        case .deleteContainerAndOpenOldCopy(let name):
            try deleteContainerAndOpenOldCopy(device(name))
        case .shareBackupFolder(let name, let account):
            device(name).farFolderAccount = account
        case .crash(let inner, let n):
            guard let name = inner.device else { throw WorldRefusal.notOpen }
            let d = device(name)
            if !d.isOpen { try await launch(d) }
            d.crashAfterWrites = n
            defer { d.crashAfterWrites = nil }
            try await perform(inner)
        // MARK: The adversary
        case .tamper(let name, let tamper):
            try tamperWith(device(name), tamper)
        case .tamperSequence(let name, let tampers):
            // Each applies in turn, the app closed throughout; one that finds
            // nothing to act on (no capture to replay) is skipped and said —
            // the group is refused only when none applied.
            var applied = 0
            var lastRefusal: Error?
            for tamper in tampers {
                do {
                    try tamperWith(device(name), tamper)
                    applied += 1
                } catch {
                    stepLog.append("  (\(tamper) didn't apply: \(error))")
                    lastRefusal = error
                }
            }
            if applied == 0, let lastRefusal { throw lastRefusal }
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

    // MARK: - Copies

    /// The backup service (phase 2/5's): a pair under the current key, frozen
    /// with the live key file, then retention over THIS Mac's copies of THIS
    /// library (VX-302). Every prune is recorded for promise 11.
    func backupService(_ device: SDevice) async throws {
        let (_, library) = try await opened(device)
        guard !device.paused, let live = liveKeyFile(device), live.fingerprint == library.fingerprint, let slot = device.slot else {
            throw ExecutorRefusal.noLiveKeyFile
        }
        writePair(device, image: slot, keyFile: live, deviceID: library.section.deviceID)
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

    // MARK: - The adversary

    func tamperWith(_ device: SDevice, _ tamper: Tamper) throws {
        let leaf = DeviceLeaves(world: self, device: device)
        guard let slot = device.slot else { throw WorldRefusal.noLibrary }
        let memoryName = KName.memory(Self.scope, slot.libraryID)
        // A tamper on a Standard device is outside the protection claims (rule
        // 3: that person holds the key): its library's keys at that moment.
        if slot.record?.mode == .standard {
            let tree = Set((slot.record?.familyTree.fingerprints ?? []) + (device.library?.familyTree.fingerprints ?? []) + [slot.fingerprint])
            truth.tamperedStandard[device.name, default: []].formUnion(tree)
        }
        lock(device)
        switch tamper {
        case .plantAppleWrap:
            // A login-password holder reads every item's secret except a Touch
            // ID item's (the Apple facts §3.10): only a silent item gives the key.
            guard var file = liveKeyFile(device), let key = (device.keychain.names(service: ProtectionNames.custodyService)
                .compactMap { name in device.keychain.item(name).flatMap { $0.touchID ? nil : $0.value.libraryKey } }
                .first { PF.fp($0) == file.fingerprint }) else {
                throw WorldRefusal.cannotOpen
            }
            let planted = mintApple()
            addSynced(device, KName.apple(Self.scope, planted.id), KItem(value: .apple(id: planted.id, bytes: PF.bytes(planted.key))))
            file.apple = AppleWrap(keyID: planted.id, wrapped: try AES.KeyWrap.wrap(SymmetricKey(data: key.data), using: planted.key))
            device.container.files[SPath.liveKeyFile] = .keyFile(file)
        case .dropWordsLock:
            guard var file = liveKeyFile(device) else { throw WorldRefusal.noLibrary }
            file.words = nil
            device.container.files[SPath.liveKeyFile] = .keyFile(file)
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
            if let since = capture.slot?.library?.record?.changedAt {
                for (id, copy) in truth.copies where copy.madeOn == device.name && copy.mode == .standard && copy.madeAt > since {
                    truth.rolledBackOver.insert(id)
                }
                // Its Send Library pairs from the Standard stretch too.
                for (folder, sender) in senders where sender == device.name {
                    for path in device.container.paths(under: folder + "/") where path.hasSuffix(".sqlite") {
                        if device.container.files[path]?.library?.record?.mode == .standard { truth.rolledBackOver.insert("container:\(path)") }
                    }
                }
            }
        case .deleteMemoryItem:
            device.keychain.local[memoryName] = nil
        case .deleteTouchIDItem:
            for name in device.keychain.names(service: ProtectionNames.custodyService) where device.keychain.local[name]?.touchID == true {
                device.keychain.local[name] = nil
            }
        case .deleteKeyFile:
            device.container.files[SPath.liveKeyFile] = nil
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
        far.files["\(folder)/\(SPath.pair(of: name))"] = .keyFile(file)
    }

    /// The container deleted; an old copy (the newest in the far folder or a
    /// Time Machine snapshot) opened into the slot as it was.
    func deleteContainerAndOpenOldCopy(_ device: SDevice) throws {
        lock(device)
        var source: (image: LibraryImage, keyFile: KeyFile)?
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
        device.container.files[SPath.liveKeyFile] = .keyFile(source.keyFile)
    }

    // MARK: - The world settles

    /// Propagation done, followers followed (§4.1): iCloud Keychain carries
    /// everything; every device signed in opens and follows what it's owed
    /// (typing its passphrase); repeated until nothing moves.
    func settleWorld() async {
        for _ in 0..<4 {
            propagateAll()
            for device in devices where device.slot != nil {
                if !device.isOpen { _ = try? await launch(device) }
                guard device.isOpen else { continue }
                if let account = device.library?.record?.account, device.session.accountID == account, device.online {
                    _ = try? await device.executor?.readVault(accountID: account)
                }
                await resumeAtVaultReach(device)
                try? await runRepairs(device)
                let assessment = assessed(device)
                for act in assessment.acts {
                    if case .follow = act { _ = await apply(.follow(device.name, .passphrase)) }
                }
            }
        }
        propagateAll()
        for device in devices where device.isOpen { try? await runRepairs(device) }
    }
}
