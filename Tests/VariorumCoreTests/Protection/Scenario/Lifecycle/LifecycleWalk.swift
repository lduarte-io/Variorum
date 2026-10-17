//
//  LifecycleWalk.swift
//  VariorumCoreTests — VX-378 U3: THE LIFECYCLE WALK. One person, one library,
//  the fourteen stages of `castle-lifecycle.html`, walked on the scenario world
//  (`SWorld`) through the executor's REAL acts — on this Mac (`macA`), with her
//  other Mac (`macB`) as stage 12's second device and stage 6's "other Macs",
//  and someone else's Mac (`theirMac`, its own Apple ID and account) for stage
//  10. The drivers here only ACT and OBSERVE; every judgment is the fixture's
//  (`LifecycleChecks.swift` reads `Lifecycle.stages` and nothing the model says
//  about itself).
//
//  Why the scenario world and not the executor harness (`ExecutorWorld`): the
//  page's stages 5, 6 and 11 need an Apple account whose items reach other Macs
//  (and whose deletions do), an Apple-ID change, an iCloud Keychain reset and a
//  new Mac with a fresh keychain — `SWorld` models all of them with the
//  measured Apple facts (`Fakes.swift`); `ExecutorWorld` none.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

/// A copy the walk tracks: where its snapshot and its own key file are, and
/// the secrets of its day.
struct LCopy {
    var device: String
    /// The catalog id (`container:<path>`).
    var id: String
    var path: String
    var pairPath: String
    var dayPassphrase: String?
    var dayWords: [String]?
}

/// A device's whole state — for "nothing is written".
struct LSnapshot: Equatable {
    var writeCount: Int
    var files: [String: SFile]
    var local: [KName: KItem]
    var synced: [KName: DeviceKeychain.Replica]
    var staged: LibraryImage?

    init(_ device: SDevice) {
        writeCount = device.writeCount
        files = device.container.files
        local = device.keychain.local
        synced = device.keychain.synced
        staged = device.staged
    }
}

/// What a driver saw at a moment a state check can't reconstruct afterwards.
enum LObs: Hashable {
    /// The next open opened the library with nothing typed.
    case openedUntyped
    /// Before that open, the lobby said it asks a secret at once.
    case lobbyAskedAtOnce
    /// An open with nothing typed found no road.
    case untypedOpenFailed
    /// The open after typing a secret succeeded.
    case typedOpenSucceeded
    /// The scheduled export was off right after Use Castle.
    case exportOffAfterAct
    /// She turned it back on and it stayed on.
    case exportBackOn
}

/// One Look inside, as the driver ran it.
struct LLookResult {
    var typed: LTyped?
    var opened: Bool
    var wroteNothing: Bool
}

/// One stray in the live place (stage 14), as the open met it.
struct LStrayResult {
    var refused: LibraryDisagreement?
    var otherError: String?
    var wroteNothing: Bool
}

/// Everything a stage's checks read that the world can't give back afterwards.
final class LStageContext {
    let number: Int
    // The live place when the stage began.
    var startFingerprint: String?
    var startKeyFile: KeyFile?
    var startCustody: [CustodyItemFact] = []
    var startAppleReadable: Set<String> = []
    var startAppleKeyID: String?
    var startPassphrase: String?
    var startWords: [String]?
    var startKeysSeen: Set<String> = []
    var startAppleKeysSeen: Set<String> = []
    var startDeviceIDsSeen: Set<String> = []
    // What the stage's acts handed back.
    var created: CreatedLibrary?
    var outcome: ActOutcome?
    var noticeOutcome: ActOutcome?
    var observed: Set<LObs> = []
    var looks: [String: [LLookResult]] = [:]
    var strays: [LStray: LStrayResult] = [:]
    // Compound facts' before/after (stages 9–14).
    var makeMine: [LSubject: MakeMineSeen] = [:]
    var moveBefore: (slot: SFile?, keyFile: SFile?, deviceID: String, section: DeviceSection)?
    var moveAfter: (slot: SFile?, keyFile: SFile?)?
    var sync = SyncSeen()
    var crash = CrashSeen()
    var lostKeyFile = LostKeyFileSeen()
    var recovery = RecoverySeen()
    /// Stage 14: what this Mac remembers, and the live place, before anything
    /// is put in it.
    var remembered: (memory: DeviceMemory?, libraryID: String?, fingerprint: String?, deviceID: String?, live: KeyFile?)?

    init(number: Int) { self.number = number }

    struct MakeMineSeen {
        var oldLibraryID: String
        var oldFingerprint: String
        var oldDeviceID: String
        var oldKeyFile: KeyFile?
        var oldMode: ProtectionMode
        var copyLibraryID: String?
        var copyFiles: (SFile?, SFile?)
        var keysSeenBefore: Set<String>
        var copySecrets: (passphrase: String?, words: [String]?)
    }

    struct TheirsSeen {
        var slot: SFile?
        var keyFile: SFile?
        var vault: AccountVault?
        var revision: Int?
    }

    struct SyncSeen {
        // 12a
        var setUpFingerprintBefore: String?
        var setUpLocksBefore: (StoreKeyEnvelope.PassphraseWrap?, Data?)?
        var setUpFingerprintAfter: String?
        var setUpLocksAfter: (StoreKeyEnvelope.PassphraseWrap?, Data?)?
        // 12b
        var joinerFingerprintBefore: String?
        var joinerOwnWords: [String]?
        var joinerFingerprintAfterJoin: String?
        // 12c
        var vaultBeforeEntry: AccountVault?
        var writesBeforeEntry = 0
        var writesAfterEntry = 0
        var vaultAfterEntry: AccountVault?
        var laggingOpenedUntyped = false
        var laggingHeldKeys: AccountKeys?
        var laggingOwed: [OwedAct] = []
        var followOutcome: ActOutcome?
        var followedHeldKeys: AccountKeys?
        var firstRowKeyID: String?
        // 12d
        var vaultBeforeLeave: AccountVault?
        var vaultAfterCastleLeave: AccountVault?
        var otherModeAfterFollowOut: ProtectionMode?
        var followOutOwed: [OwedAct] = []
        var followOutRequires: SecretRequirement?
        var followOutOutcome: ActOutcome?
        // 12e
        var leaverFingerprintBefore: String?
        var leaverKeyFileBefore: KeyFile?
        var leaverRecordAfterLeave: ProtectionRecord?
        var leaverKeyFileAfterLeave: KeyFile?
        var leaverFingerprintAfterLeave: String?
        var vaultRevisionBeforeLeave: Int?
        var vaultAfterLeave: VaultSnapshot?
        var rejoinHeldKeys: AccountKeys?
        var rejoinAccount: String?
    }

    struct CrashSeen {
        var fingerprintBefore: String?
        var firstResult: StepResult?
        var firstSettle: SettleOutcome?
        var fingerprintAfterFirst: String?
        var untypedAfterFirst = false
        var secondResult: StepResult?
        var secondSettle: SettleOutcome?
        var fingerprintAfterSecond: String?
        var historyAfterSecond: [String] = []
        var untypedAfterSecond = false
    }

    struct LostKeyFileSeen {
        var keyFileBefore: KeyFile?
        var keyFileAfter: KeyFile?
        var mirrorAfter: KeyFile?
        var backupPairsHaveKeyFiles: [Bool] = []
    }

    struct RecoverySeen {
        var lobby: LobbyRoads?
        var vaultOpensWithWords = false
        var heldEveryKey = false
    }
}

/// THE WALK.
final class LifecycleWalk {
    let world: SWorld
    let event: LStage5Event
    let gate: GateStyle
    static let myAccount = "her-account"
    static let theirAccount = "their-account"
    static let theirApple = "apple-account-3"

    var mac: SDevice { world.macA }
    var other: SDevice { world.macB }
    var theirs: SDevice { world.device("theirMac") }
    /// Her devices (stage 6's "your other Macs").
    var hers: [SDevice] { world.devices.filter { $0.name != "theirMac" } }

    // Her secrets, as she knows them.
    var passphrase: String?
    var words: [String] = []
    var theirPassphrase: String?
    var theirWords: [String] = []

    /// The keys the walk names (the fixture's `newKey(name:)`), by name.
    var keys: [String: String] = [:]
    /// Every library key fingerprint this walk has seen (fresh-key checks).
    var keysSeen: Set<String> = []
    /// Every Apple key id a key file of HER library ever named.
    var appleKeysNamed: Set<String> = []
    /// Every device ID this Mac's library has had.
    var deviceIDsSeen: Set<String> = []
    var copies: [LSubject: LCopy] = [:]
    /// Their side before her copy doors touched what they sent (stage 10;
    /// re-read at stage 12).
    var theirsBefore: LStageContext.TheirsSeen?

    init(event: LStage5Event, gate: GateStyle, seed: UInt64 = 378) {
        world = SWorld(seed: seed)
        self.event = event
        self.gate = gate
        world.appleAccounts[Self.theirApple] = AppleAccountFake(id: Self.theirApple)
        let them = SDevice(name: "theirMac", isPhone: false)
        them.appleAccount = Self.theirApple
        world.devices.append(them)
    }

    // MARK: - Reading her Mac

    var library: UnlockedLibrary? { mac.library }
    var liveKeyFile: KeyFile? { world.liveKeyFile(mac) }
    var slot: LibraryImage? { mac.slot }
    var today: TypedSecrets { TypedSecrets(passphrase: passphrase, words: words) }

    func holderOf(_ device: SDevice) -> String? { world.slotHolder(device) }

    /// Keep the world's truth (its lobby types from it) agreeing with hers.
    func rememberSecrets(on device: SDevice, passphrase: String?, words: [String]) {
        guard let holder = holderOf(device) else { return }
        world.setKnown(holder, passphrase: passphrase, words: words)
    }

    /// Note what the live place shows now: its key, the Apple key it names, its
    /// device ID.
    func noteLivePlace() {
        if let fp = slot?.fingerprint { keysSeen.insert(fp) }
        if let held = liveKeyFile?.heldFingerprints { keysSeen.formUnion(held) }
        if let id = liveKeyFile?.apple?.keyID { appleKeysNamed.insert(id) }
        if let id = library?.section.deviceID { deviceIDsSeen.insert(id) }
        for copy in copies.values where copy.device == mac.name {
            if let id = mac.container.files[copy.pairPath]?.keyFile?.apple?.keyID { appleKeysNamed.insert(id) }
        }
    }

    func begin(_ number: Int) -> LStageContext {
        let ctx = LStageContext(number: number)
        ctx.startFingerprint = slot?.fingerprint
        ctx.startKeyFile = liveKeyFile
        ctx.startCustody = (try? DeviceLeaves(world: world, device: mac).custodyItems()) ?? []
        ctx.startAppleReadable = Set(world.readableAppleKeys(mac).keys)
        ctx.startAppleKeyID = liveKeyFile?.apple?.keyID
        ctx.startPassphrase = passphrase
        ctx.startWords = words
        ctx.startKeysSeen = keysSeen
        ctx.startAppleKeysSeen = appleKeysNamed
        ctx.startDeviceIDsSeen = deviceIDsSeen
        world.stepLog.append("━━ stage \(number)")
        return ctx
    }

    /// Time passes: every device's iCloud Keychain syncs.
    func timePasses() { world.propagateAll() }

    /// Open `device` (if it isn't) by its roads, typing `typed`.
    @discardableResult
    func open(_ device: SDevice, typed: TypedSecrets) async throws -> UnlockedLibrary {
        try await world.launch(device, typed: typed)
    }

    /// A user act on an open device (the world opens it first with what she
    /// types if it isn't open).
    func act(
        _ device: SDevice, typed: TypedSecrets? = nil,
        _ body: @escaping (ProtectionExecutor, inout UnlockedLibrary) async throws -> ActOutcome?
    ) async throws -> ActOutcome? {
        if !device.isOpen { try await open(device, typed: typed ?? today) }
        device.lastOutcome = nil
        try await world.act(device, body)
        return device.lastOutcome
    }

    /// The newest copy the catalog lists on `device` that `before` didn't.
    func newCopy(on device: SDevice, before: Set<String>) -> CatalogCopy? {
        world.catalog(device).copies.filter { !before.contains($0.id) && $0.kind == .backup }.max { $0.id < $1.id }
    }

    func catalogIDs(_ device: SDevice) -> Set<String> { Set(world.catalog(device).copies.map(\.id)) }

    func track(_ copy: CatalogCopy, on device: SDevice, as subject: LSubject, dayPassphrase: String?, dayWords: [String]?) {
        let path = String(copy.id.dropFirst("container:".count))
        copies[subject] = LCopy(
            device: device.name, id: copy.id, path: path, pairPath: SPath.pair(of: path),
            dayPassphrase: dayPassphrase, dayWords: dayWords)
    }

    /// The account keys `device` holds (custody, either class, or the session).
    func heldSyncKeys(_ device: SDevice, account: String) -> AccountKeys? {
        let leaf = DeviceLeaves(world: world, device: device)
        for itemClass in [ProtectionNames.CustodyClass.touchid, .silent] {
            if let held = try? leaf.readSyncKeys(accountID: account, itemClass: itemClass) { return held }
        }
        return device.sessionMemory[account]
    }

    // MARK: - The stages

    /// One stage's acts — the road the fixture names for it.
    func run(_ stage: LStage, _ ctx: LStageContext) async throws {
        switch stage.number {
        case 1: try stage1(ctx)
        case 2: try await stage2(ctx)
        case 3: try await stage3(ctx)
        case 4: try await stage4(ctx)
        case 5: try await stage5(ctx)
        case 6: try await stage6(ctx)
        case 7: try await stage7(ctx)
        case 8: try await stage8(ctx)
        case 9: try await stage9(ctx, stage: stage)
        case 10: try await stage10(ctx, stage: stage)
        case 11: try await stage11(ctx)
        case 12: try await stage12(ctx)
        case 13: try await stage13(ctx)
        case 14: try await stage14(ctx, stage: stage)
        default: throw StartingStateRefused(description: "no stage \(stage.number)")
        }
    }

    func stage1(_ ctx: LStageContext) throws {
        let executor = world.newExecutor(mac, libraryID: "")
        let created = try executor.createLibrary(passphrase: nil)
        mac.executor = executor
        mac.library = created.library
        ctx.created = created
        passphrase = nil
        words = created.words
        rememberSecrets(on: mac, passphrase: nil, words: created.words)
    }

    func stage2(_ ctx: LStageContext) async throws {
        let fresh = world.newPassphrase()
        ctx.outcome = try await act(mac) { executor, library in
            try await executor.resetPassphrase(&library, authorization: .plainConfirm, new: fresh)
        }
        passphrase = fresh
        rememberSecrets(on: mac, passphrase: fresh, words: words)
    }

    func stage3(_ ctx: LStageContext) async throws {
        let before = catalogIDs(mac)
        let result = await world.apply(.backup(mac.name))
        guard result == .done, let copy = newCopy(on: mac, before: before) else {
            throw StartingStateRefused(description: "backup A → \(result)")
        }
        track(copy, on: mac, as: .backupA, dayPassphrase: passphrase, dayWords: words)
    }

    func stage4(_ ctx: LStageContext) async throws {
        let old = passphrase ?? "", fresh = world.newPassphrase()
        ctx.outcome = try await act(mac) { executor, library in
            try await executor.changePassphrase(&library, current: old, new: fresh)
        }
        passphrase = fresh
        rememberSecrets(on: mac, passphrase: fresh, words: words)
    }

    func stage5(_ ctx: LStageContext) async throws {
        switch event {
        case .appleIDChanged:
            // She changes her Apple ID: every device of hers moves to it.
            for device in hers { _ = await world.apply(.switchAppleID(device.name, to: SWorld.appleB)) }
        case .iCloudKeychainReset:
            _ = await world.apply(.resetICloudKeychain(mac.name))
        }
        // The next open, nothing typed.
        world.lock(mac)
        if world.assessed(mac).lobby.asksASecretAtOnce { ctx.observed.insert(.lobbyAskedAtOnce) }
        do {
            try await open(mac, typed: .none)
            ctx.observed.insert(.openedUntyped)
        } catch {
            ctx.observed.insert(.untypedOpenFailed)
            try await open(mac, typed: today)
        }
    }

    func stage6(_ ctx: LStageContext) async throws {
        // The scheduled export on, so its turn-off can be seen (the page's
        // "turned off, with one notice").
        _ = try await act(mac) { executor, library in
            var settings = library.section.settings
            settings.scheduledExport = true
            return try await executor.changeSettings(&library, to: settings)
        }
        let typed = today, gate = gate
        ctx.outcome = try await act(mac) { executor, library in
            try await executor.useCastle(&library, typed: typed, gate: gate)
        }
        if mac.library?.section.settings.scheduledExport == false { ctx.observed.insert(.exportOffAfterAct) }
        // She may reverse it.
        _ = try await act(mac) { executor, library in
            var settings = library.section.settings
            settings.scheduledExport = true
            return try await executor.changeSettings(&library, to: settings)
        }
        if mac.library?.section.settings.scheduledExport == true { ctx.observed.insert(.exportBackOn) }
    }

    func stage7(_ ctx: LStageContext) async throws {
        let current = passphrase ?? "", fresh = world.newWords()
        ctx.outcome = try await act(mac) { executor, library in
            try await executor.regenerateWords(&library, passphrase: current, newWords: fresh)
        }
        words = fresh
        rememberSecrets(on: mac, passphrase: passphrase, words: fresh)
        let before = catalogIDs(mac)
        let result = await world.apply(.backup(mac.name))
        guard result == .done, let copy = newCopy(on: mac, before: before) else {
            throw StartingStateRefused(description: "backup B → \(result)")
        }
        track(copy, on: mac, as: .backupB, dayPassphrase: passphrase, dayWords: words)
    }

    func stage8(_ ctx: LStageContext) async throws {
        let typed = today
        ctx.outcome = try await act(mac) { executor, library in try await executor.useStandard(&library, typed: typed) }
    }

    // MARK: Stages 9–10: the copy doors (the fixture names the secrets to type)

    func lookInside(_ ctx: LStageContext, on device: SDevice, _ subject: LSubject, copy: LCopy, opensWith: [LTyped], refuses: [LTyped]) async throws {
        if !device.isOpen { try await open(device, typed: today) }
        var results: [LLookResult] = []
        for typed in [Optional<LTyped>.none] + (opensWith + refuses).map(Optional.some) {
            let catalog = world.catalog(device)
            guard let entry = catalog.copies.first(where: { $0.id == copy.id }), let executor = device.executor else { continue }
            let before = LSnapshot(device)
            let opened = (try? executor.lookInside(entry, in: catalog, typed: secrets(typed, copy: copy))) != nil
            results.append(LLookResult(typed: typed, opened: opened, wroteNothing: LSnapshot(device) == before))
        }
        ctx.looks[subject.rawValue] = results
    }

    func secrets(_ typed: LTyped?, copy: LCopy?) -> TypedSecrets {
        guard let typed else { return .none }
        func pick(_ secret: LSecret, _ p: String?, _ w: [String]?) -> TypedSecrets {
            switch secret {
            case .passphrase: return TypedSecrets(passphrase: p)
            case .words: return TypedSecrets(words: w)
            case .either: return TypedSecrets(passphrase: p, words: w)
            }
        }
        switch typed {
        case .today(let s): return pick(s, passphrase, words)
        case .itsDay(let s): return pick(s, copy?.dayPassphrase, copy?.dayWords)
        case .theirs(let s): return pick(s, theirPassphrase, theirWords)
        }
    }

    func makeMine(_ ctx: LStageContext, _ subject: LSubject, copySecrets: TypedSecrets) async throws {
        guard let copy = copies[subject], let library = mac.library, let record = library.record else {
            throw StartingStateRefused(description: "no copy \(subject)")
        }
        ctx.makeMine[subject] = LStageContext.MakeMineSeen(
            oldLibraryID: record.libraryID, oldFingerprint: library.fingerprint, oldDeviceID: library.section.deviceID,
            oldKeyFile: liveKeyFile, oldMode: record.mode,
            copyLibraryID: mac.container.files[copy.pairPath]?.keyFile?.libraryID,
            copyFiles: (mac.container.files[copy.path], mac.container.files[copy.pairPath]),
            keysSeenBefore: keysSeen, copySecrets: (copySecrets.passphrase, copySecrets.words))
        let pair = today
        ctx.outcome = try await act(mac) { executor, library in
            let catalog = self.world.catalog(self.mac)
            guard let entry = catalog.copies.first(where: { $0.id == copy.id }) else { throw ExecutorRefusal.copyDoesNotOpen }
            return try await executor.makeThisMyLibrary(
                &library, copy: entry, in: catalog, copySecrets: copySecrets, currentPair: pair)
        }
        rememberSecrets(on: mac, passphrase: passphrase, words: words)
    }

    func stage9(_ ctx: LStageContext, stage: LStage) async throws {
        guard let copy = copies[.backupB] else { return }
        for entry in stage.facts {
            if case .lookInside(let subject, let opensWith, let refuses, _) = entry.fact {
                try await lookInside(ctx, on: mac, subject, copy: copy, opensWith: opensWith, refuses: refuses)
            }
        }
        try await makeMine(ctx, .backupB, copySecrets: TypedSecrets(passphrase: passphrase))
    }

    func stage10(_ ctx: LStageContext, stage: LStage) async throws {
        // Their library, on their Mac (another Apple ID), syncing to their own
        // account.
        let executor = world.newExecutor(theirs, libraryID: "")
        let p = world.newPassphrase()
        let created = try executor.createLibrary(passphrase: p)
        theirs.executor = executor
        theirs.library = created.library
        theirPassphrase = p
        theirWords = created.words
        rememberSecrets(on: theirs, passphrase: p, words: created.words)
        _ = await world.apply(.signIn(theirs.name, account: Self.theirAccount))
        let synced = await world.apply(.turnOnSync(theirs.name))
        guard synced == .done else { throw StartingStateRefused(description: "their sync → \(synced)") }
        // They AirDrop it to her (Send Library writes the pair to a folder).
        let sent = await world.apply(.sendLibrary(from: theirs.name, to: mac.name))
        guard sent == .done, let folder = mac.incoming.last,
              let image = mac.container.files["\(folder)/\(SPath.slot)"]?.library,
              let keyFile = mac.container.files["\(folder)/\(SPath.liveKeyFile)"]?.keyFile,
              let theirSection = theirs.library?.section
        else { throw StartingStateRefused(description: "send → \(sent)") }
        // She opens what arrived at the copy doors — presented as a catalogued
        // copy (the doors take a `CatalogCopy`; the picker that hands an
        // arbitrary folder to them is VX-309's): filed the way the catalog reads
        // another library's copy, under its own library and Mac.
        let base = "\(SPath.ownFolder(image.libraryID, theirSection.deviceID))/\(SPath.snapshot(world.tick(), image.fingerprint))"
        mac.container.files[base] = .library(image)
        mac.container.files[SPath.pair(of: base)] = .keyFile(keyFile)
        copies[.theirs] = LCopy(
            device: mac.name, id: "container:\(base)", path: base, pairPath: SPath.pair(of: base),
            dayPassphrase: p, dayWords: created.words)
        theirsBefore = LStageContext.TheirsSeen(
            slot: theirs.container.files[SPath.slot], keyFile: theirs.container.files[SPath.liveKeyFile],
            vault: world.server.snapshot(Self.theirAccount)?.vault, revision: world.server.snapshot(Self.theirAccount)?.revision)
        world.lock(theirs)
        guard let copy = copies[.theirs] else { return }
        for entry in stage.facts {
            if case .lookInside(let subject, let opensWith, let refuses, _) = entry.fact {
                try await lookInside(ctx, on: mac, subject, copy: copy, opensWith: opensWith, refuses: refuses)
            }
        }
        try await makeMine(ctx, .theirs, copySecrets: TypedSecrets(passphrase: p))
    }

    // MARK: Stage 11: a new Mac

    func stage11(_ ctx: LStageContext) async throws {
        timePasses()
        guard let section = mac.library?.section else { return }
        ctx.moveBefore = (mac.container.files[SPath.slot], mac.container.files[SPath.liveKeyFile], section.deviceID, section)
        // Migration Assistant: the files move; no keychain item arrives (her
        // iCloud Keychain isn't on there yet — "may or may not arrive").
        mac.iCloudOn = false
        _ = await world.apply(.replaceMac(mac.name, carriesMemory: false))
        ctx.moveAfter = (mac.container.files[SPath.slot], mac.container.files[SPath.liveKeyFile])
        if world.assessed(mac).lobby.asksASecretAtOnce { ctx.observed.insert(.lobbyAskedAtOnce) }
        do {
            try await open(mac, typed: .none)
            ctx.observed.insert(.openedUntyped)
        } catch {
            ctx.observed.insert(.untypedOpenFailed)
        }
        if !mac.isOpen {
            try await open(mac, typed: today)
            ctx.observed.insert(.typedOpenSucceeded)
        }
    }

    func stage11After() async { _ = await world.apply(.iCloudOn(mac.name)) }

    // MARK: Stage 12: sync

    func stage12(_ ctx: LStageContext) async throws {
        let account = Self.myAccount
        // 12a — this Mac turns sync on first.
        ctx.sync.setUpFingerprintBefore = slot?.fingerprint
        ctx.sync.setUpLocksBefore = (liveKeyFile?.passphrase, liveKeyFile?.words)
        _ = await world.apply(.signIn(mac.name, account: account))
        let setUp = await world.apply(.turnOnSync(mac.name))
        guard setUp == .done else { throw StartingStateRefused(description: "set up sync → \(setUp)") }
        ctx.sync.setUpFingerprintAfter = slot?.fingerprint
        ctx.sync.setUpLocksAfter = (liveKeyFile?.passphrase, liveKeyFile?.words)
        ctx.sync.firstRowKeyID = world.server.snapshot(account)?.rowKeyID
        firstRowKeyID = ctx.sync.firstRowKeyID
        // 12b — her other Mac makes its own library, backs it up, joins.
        let executor = world.newExecutor(other, libraryID: "")
        let created = try executor.createLibrary(passphrase: nil)
        other.executor = executor
        other.library = created.library
        rememberSecrets(on: other, passphrase: nil, words: created.words)
        ctx.sync.joinerOwnWords = created.words
        let before = catalogIDs(other)
        let backedUp = await world.apply(.backup(other.name))
        guard backedUp == .done, let copy = newCopy(on: other, before: before) else {
            throw StartingStateRefused(description: "the joiner's backup → \(backedUp)")
        }
        track(copy, on: other, as: .joinersBackup, dayPassphrase: nil, dayWords: created.words)
        ctx.sync.joinerFingerprintBefore = other.slot?.fingerprint
        _ = await world.apply(.signIn(other.name, account: account))
        let accountPassphrase = passphrase
        ctx.noticeOutcome = try await act(other) { executor, library in
            try await executor.enroll(&library, typed: TypedSecrets(passphrase: accountPassphrase))
        }
        ctx.sync.joinerFingerprintAfterJoin = other.slot?.fingerprint
        world.setKnown(account, passphrase: passphrase, words: words)
        if let joiners = copies[.joinersBackup] {
            try await lookInside(
                ctx, on: other, .joinersBackup, copy: joiners, opensWith: [.itsDay(.words), .today(.passphrase)], refuses: [])
        }
        // 12c — her other Mac enters Castle; this Mac lags, then follows.
        timePasses()
        ctx.sync.vaultBeforeEntry = world.server.snapshot(account)?.vault
        ctx.sync.writesBeforeEntry = world.server.writes.filter { $0.account == account }.count
        let both = today
        _ = try await act(other) { executor, library in try await executor.useCastle(&library, typed: both, gate: .touchID) }
        ctx.sync.writesAfterEntry = world.server.writes.filter { $0.account == account }.count
        ctx.sync.vaultAfterEntry = world.server.snapshot(account)?.vault
        world.lock(mac)
        do {
            try await open(mac, typed: .none)
            ctx.sync.laggingOpenedUntyped = true
        } catch {
            try await open(mac, typed: today)
        }
        ctx.sync.laggingHeldKeys = heldSyncKeys(mac, account: account)
        ctx.sync.laggingOwed = world.assessed(mac).acts
        let one = passphrase
        ctx.sync.followOutcome = try await act(mac) { executor, library in
            try await executor.follow(&library, kind: .intoCastle, typed: TypedSecrets(passphrase: one))
        }
        ctx.sync.followedHeldKeys = heldSyncKeys(mac, account: account)
        // 12d — this Mac leaves Castle; her other Mac follows out quietly.
        timePasses()
        ctx.sync.vaultBeforeLeave = world.server.snapshot(account)?.vault
        _ = try await act(mac) { executor, library in try await executor.useStandard(&library, typed: both) }
        ctx.sync.vaultAfterCastleLeave = world.server.snapshot(account)?.vault
        if !other.isOpen { try await open(other, typed: today) }
        _ = try await other.executor?.readVault(accountID: account)
        ctx.sync.followOutOwed = world.assessed(other).acts
        ctx.sync.followOutRequires = world.assessed(other).door(.followNow).spec?.requires
        ctx.sync.followOutOutcome = try await act(other) { executor, library in
            try await executor.follow(&library, kind: .intoStandard, typed: .none)
        }
        ctx.sync.otherModeAfterFollowOut = other.slot?.record?.mode
        // 12e — her other Mac leaves the account, then signs back in.
        ctx.sync.leaverFingerprintBefore = other.slot?.fingerprint
        ctx.sync.leaverKeyFileBefore = world.liveKeyFile(other)
        ctx.sync.vaultRevisionBeforeLeave = world.server.snapshot(account)?.revision
        _ = try await act(other) { executor, library in try await executor.leaveAccount(.stopSyncingHere, &library) }
        ctx.sync.leaverRecordAfterLeave = other.slot?.record
        ctx.sync.leaverKeyFileAfterLeave = world.liveKeyFile(other)
        ctx.sync.leaverFingerprintAfterLeave = other.slot?.fingerprint
        ctx.sync.vaultAfterLeave = world.server.snapshot(account)
        _ = await world.apply(.signOut(other.name))
        _ = await world.apply(.signIn(other.name, account: account))
        _ = try await act(other) { executor, library in
            try await executor.enroll(&library, typed: TypedSecrets(passphrase: accountPassphrase))
        }
        ctx.sync.rejoinAccount = other.slot?.record?.account
        ctx.sync.rejoinHeldKeys = heldSyncKeys(other, account: account)
        timePasses()
    }

    // MARK: Stage 13: crashes

    func stage13(_ ctx: LStageContext) async throws {
        let typed = today
        if !mac.isOpen { try await open(mac, typed: typed) }
        ctx.crash.fingerprintBefore = slot?.fingerprint
        ctx.crash.firstResult = await world.apply(.crash(.replaceAllKeys(mac.name, newWords: false), afterWrites: 1))
        try await open(mac, typed: typed)
        ctx.crash.firstSettle = mac.lastSettle
        ctx.crash.fingerprintAfterFirst = slot?.fingerprint
        world.lock(mac)
        ctx.crash.untypedAfterFirst = (try? await open(mac, typed: .none)) != nil
        if !mac.isOpen { try await open(mac, typed: typed) }
        ctx.crash.secondResult = await world.apply(.crash(.replaceAllKeys(mac.name, newWords: false), afterWrites: 5))
        try await open(mac, typed: typed)
        ctx.crash.secondSettle = mac.lastSettle
        ctx.crash.fingerprintAfterSecond = slot?.fingerprint
        ctx.crash.historyAfterSecond = liveKeyFile?.heldFingerprints ?? []
        world.lock(mac)
        ctx.crash.untypedAfterSecond = (try? await open(mac, typed: .none)) != nil
        if !mac.isOpen { try await open(mac, typed: typed) }
    }

    // MARK: Stage 14: something wrong on disk

    func stage14(_ ctx: LStageContext, stage: LStage) async throws {
        if !mac.isOpen { try await open(mac, typed: today) }
        guard let current = slot, let liveFile = liveKeyFile else { return }
        ctx.remembered = (mac.library?.memory, mac.library?.record?.libraryID, current.fingerprint, mac.library?.section.deviceID, liveFile)
        let liveSlotFile = mac.container.files[SPath.slot], liveKeyFileFile = mac.container.files[SPath.liveKeyFile]
        // An older backup pair of this library on this Mac.
        let catalog = world.catalog(mac)
        let older = catalog.copies.filter { $0.kind == .backup && $0.library == current.libraryID && $0.fingerprint != current.fingerprint }
            .max { $0.id < $1.id }
        for entry in stage.facts {
            guard case .refusesWhatItDoesntRemember(let stray) = entry.fact else { continue }
            world.lock(mac)
            var typed = today
            switch stray {
            case .backupPairCopiedInByHand:
                guard let older else { continue }
                let path = String(older.id.dropFirst("container:".count))
                mac.container.files[SPath.slot] = mac.container.files[path]
                mac.container.files[SPath.liveKeyFile] = mac.container.files[SPath.pair(of: path)]
            case .replayedOldLibraryFile:
                guard let older else { continue }
                let path = String(older.id.dropFirst("container:".count))
                mac.container.files[SPath.slot] = mac.container.files[path]
            case .swappedInFile:
                guard let copy = copies[.theirs] else { continue }
                mac.container.files[SPath.slot] = mac.container.files[copy.path]
                mac.container.files[SPath.liveKeyFile] = mac.container.files[copy.pairPath]
                typed = TypedSecrets(passphrase: theirPassphrase)
            }
            let before = LSnapshot(mac)
            var result = LStrayResult(refused: nil, otherError: nil, wroteNothing: false)
            do {
                try await open(mac, typed: typed)
                result.otherError = "it opened"
            } catch ExecutorRefusal.libraryDisagreesWithMemory(let disagreement) {
                result.refused = disagreement
            } catch {
                result.otherError = String(describing: error)
            }
            result.wroteNothing = LSnapshot(mac) == before
            ctx.strays[stray] = result
            // She puts her files back.
            world.lock(mac)
            mac.container.files[SPath.slot] = liveSlotFile
            mac.container.files[SPath.liveKeyFile] = liveKeyFileFile
        }
        try await open(mac, typed: today)
        // The live key file lost.
        ctx.lostKeyFile.keyFileBefore = liveFile
        world.lock(mac)
        mac.container.files[SPath.liveKeyFile] = nil
        try await open(mac, typed: .none)
        ctx.lostKeyFile.keyFileAfter = liveKeyFile
        ctx.lostKeyFile.mirrorAfter = mac.library?.memory?.keyFileMirror
        ctx.lostKeyFile.backupPairsHaveKeyFiles = world.catalog(mac).copies
            .filter { $0.kind == .backup && $0.library == current.libraryID }
            .map { copy in !world.catalog(mac).servingKeyFiles(of: copy).compactMap(\.document).isEmpty }
        // Every key-file copy gone — beside the library, in every backup, the
        // sealed copy in this Mac's keychain — and the keychain's items with it.
        world.lock(mac)
        for path in mac.container.files.keys where mac.container.files[path]?.keyFile != nil {
            mac.container.files[path] = nil
        }
        for name in mac.keychain.local.keys where name.service != ProtectionNames.syncKeysService {
            mac.keychain.local[name] = nil
        }
        ctx.recovery.lobby = world.assessed(mac).lobby
        if let vault = world.server.snapshot(Self.myAccount)?.vault, let wordsKey = try? WordsKey.derive(words),
           let master = vault.master(passphrase: nil, words: wordsKey) {
            ctx.recovery.vaultOpensWithWords = true
            if let held = try? vault.keys(master: master), let first = firstRowKeyID {
                ctx.recovery.heldEveryKey = held.rowKey(for: first) != nil && held.rowKey(for: held.rowKeyID) != nil
            }
        }
    }

    /// Stage 12's first sync key, kept for stage 14.
    var firstRowKeyID: String?
}
