//
//  ExecutorFixtures.swift
//  VariorumCoreTests — VX-305 U3: libraries in the executor's world, in each
//  shape the acts start from (Standard or Castle, local or synced, Touch ID or
//  Always ask), the relaunch-and-settle harness, and the checks every settled
//  world must pass.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

/// One library on one Mac, in the executor's world.
final class EX {
    static let scope = "Variorum-test"

    let world: ExecutorWorld
    let libraryID = PF.id()
    let deviceID = PF.id()
    let passphrase = "the day I left"
    let words: [String]
    let p: PassphraseKey
    let w: WordsKey
    var key: StoreKey
    var account: String?
    var mode: ProtectionMode
    var gate: GateStyle?
    var ownApple: AppleKeyMaterial?
    var accountApple: AppleKeyMaterial?
    var material: DeviceKeyMaterial?

    var typed: TypedSecrets { TypedSecrets(passphrase: passphrase, words: words) }

    /// A library in `mode`. Standard: P, W and this Mac's own Apple key (in
    /// iCloud Keychain), a silent item; synced, the account's vault with its
    /// Apple wrap under the account's key and a silent sync-keys item. Castle:
    /// P and W, a Touch ID item (or none under Always ask); synced, a Castle
    /// vault and the sync keys the Castle way.
    /// `joining`: another device of the same account — this device's own
    /// library, on the same server and iCloud Keychain, holding the account's
    /// keys (its section lists the account's Apple key as followed).
    init(_ mode: ProtectionMode, synced: Bool = false, gate: GateStyle? = nil, scheduledExport: Bool = false,
         world: ExecutorWorld? = nil, account: String? = nil, joining other: EX? = nil) throws {
        let world = world ?? other.map { ExecutorWorld(icloud: $0.world.icloud, server: $0.world.server) } ?? ExecutorWorld()
        self.world = world
        self.mode = mode
        self.gate = mode == .castle ? (gate ?? .touchID) : gate
        words = try other?.words ?? PF.words()
        if let other, let vault = other.account.flatMap({ world.server.snapshot($0) }) {
            p = try PassphraseKey.derive(other.passphrase, kdf: vault.format.kdf)
        } else {
            p = try PF.passphraseKey(passphrase)
        }
        w = try PF.wordsKey(words)
        key = StoreKey.mint()
        self.account = synced ? (account ?? PF.id()) : nil
        if mode == .standard {
            let own = AppleKeyMaterial.mint()
            ownApple = own
            world.icloud.keys[own.id] = own
        }
        var section = DeviceSection(
            deviceID: deviceID, hardwareMarker: "", settings: DeviceSettings(gateStyle: self.gate, scheduledExport: scheduledExport))
        if let own = ownApple { section = section.recordingAppleKey(AppleKeyRecord(id: own.id, purpose: .library, origin: .minted)) }
        var locks = NewKeyLocks(passphrase: p, words: w, apple: ownApple)
        if let other { self.account = other.account }
        if let account = self.account {
            let format: KeyVaultFormat, material: DeviceKeyMaterial
            if let other, let existing = world.server.snapshot(account) {
                format = existing.format
                material = try VaultModel.material(following: format, master: format.unwrapMaster(withPassphraseKey: p.key))
                accountApple = other.accountApple
                if let accountKey = other.accountApple {
                    section = section.recordingAppleKey(AppleKeyRecord(id: accountKey.id, purpose: .account, accountID: account, origin: .followed))
                }
            } else {
                let accountKey: AppleKeyMaterial? = mode == .standard ? AppleKeyMaterial.mint() : nil
                if let accountKey {
                    accountApple = accountKey
                    world.icloud.keys[accountKey.id] = accountKey
                    section = section.recordingAppleKey(AppleKeyRecord(id: accountKey.id, purpose: .account, accountID: account, origin: .minted))
                }
                (format, material) = try VaultModel.creating(passphrase: p, words: w, apple: accountKey, device: "Mac A", ids: world)
                world.server.accounts[account] = ExecutorVault.Account(revision: 1, format: format, rows: 0, updatedAt: nil)
            }
            self.material = material
            locks.master = material.masterSymmetricKey
            locks.masterWordsCopy = format.masterWrappedByRecovery
            switch (mode, self.gate) {
            case (.standard, _): world.syncItems[SyncKeysItemFact(accountID: account, itemClass: .silent)] = material
            case (.castle, .touchID): world.syncItems[SyncKeysItemFact(accountID: account, itemClass: .touchid)] = material
            case (.castle, _): world.session[account] = material
            }
        }
        var record = ProtectionRecord.minting(
            libraryID: libraryID, mode: mode, modeConfirmed: true, account: self.account,
            currentFingerprint: PF.fp(key), madeBy: deviceID, at: PF.t0)
        section.hardwareMarker = record.marker(for: PF.macA)
        record = try record.storing(section, sealedUnder: key)
        let file = try KeyFile.building(libraryID: libraryID, key: key, epoch: 1, locks: locks)
        world.live = ExecutorWorld.LibraryFile(fingerprint: PF.fp(key), record: record, generation: 1)
        world.liveKeyFile = .format3(file)
        switch (mode, self.gate) {
        case (.standard, _): world.custody[CustodyItemFact(fingerprint: PF.fp(key), itemClass: .silent)] = key
        case (.castle, .touchID): world.custody[CustodyItemFact(fingerprint: PF.fp(key), itemClass: .touchid)] = key
        case (.castle, _): break
        }
        let vault = self.account.flatMap { world.server.snapshot($0) }
        let memory = DeviceMemory(
            libraryID: libraryID, scope: Self.scope, currentFingerprint: PF.fp(key), keyEpoch: 1,
            lastConfirmed: ConfirmedFacts(mode: mode, account: self.account),
            vaultFacts: vault.map { VaultFacts(kdf: $0.format.kdf, corpusKeyID: $0.corpusKeyID, recoveryWrapDigest: $0.format.recoveryWrapDigest) },
            keyFileMirror: file, familyTree: record.familyTree, deviceSection: section)
        world.memories[libraryID] = try memory.sealed(under: key)
        world.writes = []
    }

    var session: SessionFact { account.map { .signedIn(accountID: $0, email: nil) } ?? .signedOut }

    func executor(guards: ProtectionGuards = .all, session: SessionFact? = nil, machine: MachineIdentity = PF.macA) -> ProtectionExecutor {
        ProtectionExecutor(
            leaves: world.leaves,
            configuration: ExecutorConfiguration(
                scope: Self.scope, libraryID: libraryID, machine: machine, deviceName: "Mac A", floor: PF.floor,
                session: session ?? self.session),
            guards: guards)
    }

    /// The library opened with the key in hand.
    func unlocked(_ executor: ProtectionExecutor) throws -> UnlockedLibrary { try executor.unlock(with: key) }

    // MARK: - The relaunch

    /// The lobby's roads, as a person would walk them: every custody item,
    /// then the live key file with what she types, its history, its anchor.
    func openByRoads(_ typed: TypedSecrets) -> StoreKey? {
        func opens(_ candidate: StoreKey) -> Bool { (try? world.libraryOpens(with: candidate)) == true }
        for item in (try? world.custodyItems()) ?? [] {
            if let held = try? world.readCustody(fingerprint: item.fingerprint, itemClass: item.itemClass), opens(held) {
                return held
            }
        }
        guard let live = world.liveFormat3 else { return nil }
        var secrets: [ProtectionSecret] = []
        if let passphrase = typed.passphrase { secrets.append(.passphrase(passphrase)) }
        if let words = typed.words { secrets.append(.words(words)) }
        for secret in secrets {
            if let current = try? live.open(secret, floor: PF.floor) {
                if opens(current) { return current }
                for older in (try? live.historyKeys(currentKey: current)) ?? [] where opens(older.key) { return older.key }
            }
            if let anchor = live.anchor, let contents = try? anchor.open(secret, floor: PF.floor) {
                for held in contents.keys where opens(held.key) { return held.key }
            }
        }
        return nil
    }

    /// Relaunch after a crash: the lobby opens by its roads, a fresh executor
    /// unlocks and settles.
    func relaunchAndSettle(
        _ typed: TypedSecrets? = nil, guards: ProtectionGuards = .all, dropPlan: Bool = false
    ) async throws -> (SettleOutcome, UnlockedLibrary, ProtectionExecutor) {
        world.relaunch()
        if dropPlan { world.plan = nil }
        let typed = typed ?? self.typed
        let opened = try #require(openByRoads(typed), "no road opens the library after the crash")
        key = opened
        let executor = executor(guards: guards)
        var library = try executor.unlock(with: opened)
        let outcome = try await executor.settle(&library, typed: typed)
        key = library.key
        return (outcome, library, executor)
    }

    // MARK: - Reading the world back

    var liveRecord: ProtectionRecord? { world.live?.record }

    func memoryValue(_ key: StoreKey? = nil) -> DeviceMemory? {
        guard let sealed = world.memories[libraryID] else { return nil }
        return try? sealed.open(purpose: .memory, libraryID: libraryID, key: key ?? self.key)
    }

    func custody(_ itemClass: ProtectionNames.CustodyClass, _ key: StoreKey) -> Bool {
        world.custody[CustodyItemFact(fingerprint: PF.fp(key), itemClass: itemClass)] != nil
    }
}

/// What every settled world shows: no act in flight, no plan, no staged file,
/// copies running; the record, the key file, what this Mac remembers and the
/// library's own key agree.
func expectSettled(_ fixture: EX, _ library: UnlockedLibrary, _ context: String = "", sourceLocation: SourceLocation = #_sourceLocation) {
    let world = fixture.world
    #expect(world.plan == nil, "\(context) a plan is left on disk", sourceLocation: sourceLocation)
    #expect(world.staged == nil, "\(context) a staged file is left", sourceLocation: sourceLocation)
    #expect(!world.paused, "\(context) copies are still paused", sourceLocation: sourceLocation)
    #expect(library.section.actInFlight == nil, "\(context) an act is still in flight", sourceLocation: sourceLocation)
    let fingerprint = world.live?.fingerprint
    #expect(fixture.liveRecord?.currentFingerprint == fingerprint, "\(context) the record names another key", sourceLocation: sourceLocation)
    #expect(world.liveFormat3?.fingerprint == fingerprint, "\(context) the key file is another key's", sourceLocation: sourceLocation)
    let memory = fixture.memoryValue(library.key)
    #expect(memory?.currentFingerprint == fingerprint, "\(context) what this Mac remembers names another key", sourceLocation: sourceLocation)
    #expect(memory?.deviceSection.actInFlight == nil, "\(context) the memory still names an act", sourceLocation: sourceLocation)
}
