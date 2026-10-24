//
//  PairCatchUpTests.swift
//  VariorumCoreTests — VX-529 unit 1, scope 2: THE PAIR CATCH-UP at the
//  executor (`notes/plans/fixes/vx-529-pair-catchup.md`, design §2; the
//  architect's ruling, Shape A): the follow's third kind RE-LOCKS this library's
//  key to the account's pair and never re-keys it — the passphrase lock under
//  the account's current passphrase on the vault's descriptor, the master's
//  twelve-words copy the vault's, a stale own words lock dropped; nothing
//  written to the server; the sync keys held per posture; a crash at any write
//  leaves the old state or the new one (rule 20).
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

/// Two devices of one account; the first re-makes the account's passphrase and/or words through its own key doors.
func pairMovedElsewhere(
    _ mode: ProtectionMode, gate: GateStyle? = nil, passphrase: Bool = true, words: Bool = false
) async throws -> (mac: EX, air: EX, newPassphrase: String?, newWords: [String]?) {
    let mac = try EX(mode, synced: true, gate: gate)
    let air = try EX(mode, synced: true, gate: gate, joining: mac)
    let executor = mac.executor()
    var library = try mac.unlocked(executor)
    var newWords: [String]?
    if words {
        let fresh = try PF.words()
        _ = try await executor.regenerateWords(&library, passphrase: mac.passphrase, newWords: fresh)
        newWords = fresh
    }
    var newPassphrase: String?
    if passphrase {
        let fresh = "a passphrase made on the other Mac"
        _ = try await executor.changePassphrase(&library, current: mac.passphrase, new: fresh)
        newPassphrase = fresh
    }
    air.world.writes = []
    return (mac, air, newPassphrase, newWords)
}

/// The shapes a lagging device can be in: Standard, Castle with Touch ID, Castle Always ask.
let pairPostures: [(ProtectionMode, GateStyle?)] = [(.standard, nil), (.castle, .touchID), (.castle, .alwaysAsk)]

/// What a re-lock leaves: the library's key, epoch and record as they were; the key file carrying the account's pair
/// (`pairFollow` nil against the vault as it stands); the history, the master lock's bytes and the Apple wrap as they
/// were; nothing written to the server; what this Mac remembers mirroring the re-locked file; the act ended.
func expectCaughtUp(
    _ air: EX, _ library: UnlockedLibrary, before: (key: StoreKey, record: ProtectionRecord, file: KeyFile, revision: Int),
    sourceLocation: SourceLocation = #_sourceLocation
) throws {
    let account = try #require(air.account, sourceLocation: sourceLocation)
    let vault = try #require(air.world.server.snapshot(account), sourceLocation: sourceLocation)
    let live = try #require(air.world.liveFormat3, sourceLocation: sourceLocation)
    #expect(library.key == before.key && air.world.live?.fingerprint == PF.fp(before.key), "the library was re-keyed",
            sourceLocation: sourceLocation)
    let record = try #require(air.liveRecord, sourceLocation: sourceLocation)
    #expect(record.mode == before.record.mode && record.keyEpoch == before.record.keyEpoch
            && record.currentFingerprint == before.record.currentFingerprint && record.account == before.record.account
            && record.accountRowKeyID == before.record.accountRowKeyID, "the record's library facts moved",
            sourceLocation: sourceLocation)
    #expect(AssessRules.pairFollow(live, vault.reading) == nil, "the key file still owes the pair",
            sourceLocation: sourceLocation)
    #expect(live.fingerprint == before.file.fingerprint && live.epoch == before.file.epoch, sourceLocation: sourceLocation)
    #expect(live.history == before.file.history, "the history changed", sourceLocation: sourceLocation)
    #expect(live.master == before.file.master, "the master lock was re-made", sourceLocation: sourceLocation)
    #expect(live.apple == before.file.apple, "the Apple wrap changed", sourceLocation: sourceLocation)
    #expect(vault.revision == before.revision, "the catch-up wrote the vault", sourceLocation: sourceLocation)
    #expect(!air.world.writes.contains { if case .vaultUpdate = $0 { return true } else { return false } },
            sourceLocation: sourceLocation)
    #expect(!air.world.writes.contains { write in
        switch write {
        case .custody, .custodyDelete, .appleAdd, .appleDelete, .stage, .stagedRecord, .swap, .backup: return true
        default: return false
        }
    }, "a re-lock wrote a key's item, an Apple key, a staged file or a backup: \(air.world.writeLog())",
            sourceLocation: sourceLocation)
    #expect(library.memory?.keyFileMirror == live, "rule 1: the sealed copy didn't follow", sourceLocation: sourceLocation)
    expectSettled(air, library, sourceLocation: sourceLocation)
}

/// The account's sync keys held per posture after the act: Standard in its silent item; Castle in session memory (the
/// engine never reads the Touch ID item — VX-487 (a)).
func expectTheKeysHeld(_ air: EX, sourceLocation: SourceLocation = #_sourceLocation) throws {
    let account = try #require(air.account, sourceLocation: sourceLocation)
    let vault = try #require(air.world.server.snapshot(account), sourceLocation: sourceLocation)
    if air.mode == .standard {
        #expect(air.world.syncItems[SyncKeysItemFact(accountID: account, itemClass: .silent)]?.rowKeyID == vault.rowKeyID,
                sourceLocation: sourceLocation)
    } else {
        #expect(air.world.session[account]?.rowKeyID == vault.rowKeyID, "the session holds no sync keys",
                sourceLocation: sourceLocation)
        #expect(air.world.syncItems[SyncKeysItemFact(accountID: account, itemClass: .silent)] == nil,
                "a silent sync-keys item in Castle", sourceLocation: sourceLocation)
    }
}

func pairBefore(_ air: EX) throws -> (key: StoreKey, record: ProtectionRecord, file: KeyFile, revision: Int) {
    let account = try #require(air.account)
    let vault = try #require(air.world.server.snapshot(account))
    return (air.key, try #require(air.liveRecord), try #require(air.world.liveFormat3), vault.revision)
}

/// The vault as it stands for `air`'s account.
func pairVault(_ air: EX) throws -> VaultSnapshot {
    let account = try #require(air.account)
    return try #require(air.world.server.snapshot(account))
}

@Suite("VX-529 scope 2 — the pair catch-up: a re-lock, never a re-key, nothing to the server")
struct PairCatchUpTests {
    @Test(arguments: pairPostures)
    func thePassphraseHalfReLocksUnderTheAccountsCurrentPassphrase(_ mode: ProtectionMode, _ gate: GateStyle?) async throws {
        let (_, air, newPassphrase, _) = try await pairMovedElsewhere(mode, gate: gate)
        let before = try pairBefore(air)
        let executor = air.executor()
        var library = try air.unlocked(executor)
        let outcome = try await executor.follow(
            &library, kind: .pairChanged(passphrase: true, words: false), typed: TypedSecrets(passphrase: newPassphrase))
        #expect(outcome.act == .follow && outcome.fingerprint == PF.fp(before.key))
        try expectCaughtUp(air, library, before: before)
        let live = try #require(air.world.liveFormat3)
        #expect(try live.open(passphrase: .passphrase(try #require(newPassphrase)), floor: PF.floor) == air.key)
        #expect((try? live.open(passphrase: .passphrase(air.passphrase), floor: PF.floor)) == nil,
                "rule 7's one pair: the old passphrase still opens the live library")
        #expect(live.words == before.file.words, "the words did not move — their lock stays")
        try expectTheKeysHeld(air)
    }

    /// R-529-2: the words-only change is quiet — nothing typed; the master from what this device already holds.
    @Test(arguments: pairPostures)
    func theWordsHalfIsQuietAndDropsTheStaleOwnWordsLock(_ mode: ProtectionMode, _ gate: GateStyle?) async throws {
        let (_, air, _, newWords) = try await pairMovedElsewhere(mode, gate: gate, passphrase: false, words: true)
        let before = try pairBefore(air)
        let executor = air.executor()
        var library = try air.unlocked(executor)
        _ = try await executor.follow(&library, kind: .pairChanged(passphrase: false, words: true), typed: .none)
        try expectCaughtUp(air, library, before: before)
        let live = try #require(air.world.liveFormat3)
        #expect(live.words == nil, "E8: the stale own words lock stays")
        #expect(try live.open(.words(try #require(newWords)), floor: PF.floor) == air.key)
        #expect((try? live.open(.words(air.words), floor: PF.floor)) == nil, "E8: the old words open the live library")
        #expect(live.passphrase == before.file.passphrase, "the passphrase did not move — its lock stays")
        try expectTheKeysHeld(air)
    }

    /// E5: both halves — one typed passphrase; the words ride the vault's copy.
    @Test(arguments: pairPostures)
    func bothHalvesTakeOnePassphrase(_ mode: ProtectionMode, _ gate: GateStyle?) async throws {
        let (_, air, newPassphrase, newWords) = try await pairMovedElsewhere(mode, gate: gate, passphrase: true, words: true)
        let before = try pairBefore(air)
        let executor = air.executor()
        var library = try air.unlocked(executor)
        _ = try await executor.follow(
            &library, kind: .pairChanged(passphrase: true, words: true), typed: TypedSecrets(passphrase: newPassphrase))
        try expectCaughtUp(air, library, before: before)
        let live = try #require(air.world.liveFormat3)
        for secret in [ProtectionSecret.passphrase(try #require(newPassphrase)), .words(try #require(newWords))] {
            #expect(try live.open(secret, floor: PF.floor) == air.key)
        }
        for old in [ProtectionSecret.passphrase(air.passphrase), .words(air.words)] {
            #expect((try? live.open(old, floor: PF.floor)) == nil)
        }
    }

    /// E7: a backup made before the catch-up keeps its own key file and opens with the secrets of its day (rules 4–5).
    @Test func aBackupFromBeforeKeepsItsDaysSecrets() async throws {
        let (_, air, newPassphrase, _) = try await pairMovedElsewhere(.standard)
        let live = try #require(air.world.liveFormat3)
        air.world.backups.append(.init(fingerprint: PF.fp(air.key), keyFile: live, record: air.liveRecord, deviceID: "d"))
        let executor = air.executor()
        var library = try air.unlocked(executor)
        _ = try await executor.follow(
            &library, kind: .pairChanged(passphrase: true, words: false), typed: TypedSecrets(passphrase: newPassphrase))
        #expect(air.world.backups.count == 1 && air.world.backups[0].keyFile == live, "a backup was rewritten or added")
        #expect(try air.world.backups[0].keyFile.open(passphrase: .passphrase(air.passphrase), floor: PF.floor) == air.key)
    }

    /// The act owes nothing once it landed: a second press finds nothing to catch up.
    @Test func onceCaughtUpThereIsNothingToDo() async throws {
        let (_, air, newPassphrase, _) = try await pairMovedElsewhere(.castle, gate: .alwaysAsk)
        let executor = air.executor()
        var library = try air.unlocked(executor)
        _ = try await executor.follow(
            &library, kind: .pairChanged(passphrase: true, words: false), typed: TypedSecrets(passphrase: newPassphrase))
        air.world.writes = []
        await #expect(throws: ExecutorRefusal.nothingToDo) {
            _ = try await executor.follow(
                &library, kind: .pairChanged(passphrase: true, words: false), typed: TypedSecrets(passphrase: newPassphrase))
        }
        #expect(air.world.writes.isEmpty)
    }
}

@Suite("VX-529 scope 2 — the pair catch-up's entry checks: each refuses with nothing begun")
struct PairCatchUpEntryTests {
    static func refused(
        _ air: EX, _ refusal: ExecutorRefusal, halves: (Bool, Bool), typed: TypedSecrets,
        sourceLocation: SourceLocation = #_sourceLocation
    ) async throws {
        let executor = air.executor()
        var library = try air.unlocked(executor)
        let before = air.world.liveFormat3
        air.world.writes = []
        await #expect(throws: refusal, sourceLocation: sourceLocation) {
            _ = try await executor.follow(&library, kind: .pairChanged(passphrase: halves.0, words: halves.1), typed: typed)
        }
        #expect(air.world.writes.isEmpty, "the refused door wrote \(air.world.writeLog())", sourceLocation: sourceLocation)
        #expect(air.world.liveFormat3 == before && library.section.actInFlight == nil && air.world.plan == nil,
                sourceLocation: sourceLocation)
    }

    /// Nothing moved (or the follow already landed): nothing to catch up.
    @Test func nothingMovedIsNothingToDo() async throws {
        let mac = try EX(.standard, synced: true)
        let air = try EX(.standard, synced: true, joining: mac)
        try await Self.refused(air, .nothingToDo, halves: (true, false), typed: TypedSecrets(passphrase: air.passphrase))
    }

    /// The passphrase half types the account's current passphrase — nothing typed refuses; the old one names the change
    /// elsewhere (P1's split); one that opens neither is the plain refusal.
    @Test func thePassphraseHalfAsksTheAccountsCurrentPassphrase() async throws {
        let (mac, air, _, _) = try await pairMovedElsewhere(.castle, gate: .alwaysAsk)
        let vault = try pairVault(mac)
        try await Self.refused(air, .secretMissing, halves: (true, false), typed: .none)
        try await Self.refused(air, .secretMissing, halves: (true, false), typed: TypedSecrets(words: air.words))
        try await Self.refused(
            air, .passphraseChangedElsewhere(device: "Mac A", day: vault.updatedAt), halves: (true, false),
            typed: TypedSecrets(passphrase: air.passphrase))
        try await Self.refused(
            air, .passphraseDoesNotOpen, halves: (true, false), typed: TypedSecrets(passphrase: "not any passphrase of hers"))
    }

    /// E14 (S-1): a words-only catch-up with no master in hand — Castle Always ask, its session empty (unlocked by the
    /// OLD words) — refuses `secretMissing`; the account's passphrase typed there lands it.
    @Test func theWordsHalfWithNoMasterInHandAsksOneAccountSecret() async throws {
        let (_, air, _, _) = try await pairMovedElsewhere(.castle, gate: .alwaysAsk, passphrase: false, words: true)
        air.world.session = [:]
        try await Self.refused(air, .secretMissing, halves: (false, true), typed: .none)
        let executor = air.executor()
        var library = try air.unlocked(executor)
        _ = try await executor.follow(
            &library, kind: .pairChanged(passphrase: false, words: true), typed: TypedSecrets(passphrase: air.passphrase))
        let live = try #require(air.world.liveFormat3)
        #expect(AssessRules.pairFollow(live, try pairVault(air).reading) == nil)
        try expectTheKeysHeld(air)
    }

    /// E2 at the press: the account moved posture since the door — this follow no longer fits; the one now owed does.
    @Test func theAccountMovedPostureSinceTheDoor() async throws {
        let (mac, air, newPassphrase, _) = try await pairMovedElsewhere(.castle)
        let macExecutor = mac.executor()
        var macLibrary = try mac.unlocked(macExecutor)
        _ = try await macExecutor.useStandard(
            &macLibrary, typed: TypedSecrets(passphrase: try #require(newPassphrase), words: mac.words))
        try await Self.refused(air, .accountMoved, halves: (true, false), typed: TypedSecrets(passphrase: newPassphrase))
    }
}

@Suite("VX-529 scope 2 — the pair catch-up is crash safe: a crash after any write leaves the old state or the new (rule 20)")
struct PairCatchUpCrashTests {
    static func caughtUp(_ fixture: EX) -> Bool {
        guard let live = fixture.world.liveFormat3, let account = fixture.account,
              let vault = fixture.world.server.snapshot(account) else { return false }
        return AssessRules.pairFollow(live, vault.reading) == nil
    }

    @Test(arguments: pairPostures)
    func aCrashAfterEveryWriteFinishes(_ mode: ProtectionMode, _ gate: GateStyle?) async throws {
        var newPassphrase: String?
        var k0: StoreKey!
        try await CrashHarness.everywhere(
            {
                let made = try await pairMovedElsewhere(mode, gate: gate)
                newPassphrase = made.newPassphrase
                k0 = made.air.key
                return made.air
            },
            act: { _, executor, library in
                _ = try await executor.follow(
                    &library, kind: .pairChanged(passphrase: true, words: false), typed: TypedSecrets(passphrase: newPassphrase))
            },
            finished: { fixture, library in library.key == k0 && Self.caughtUp(fixture) },
            neverHappened: { fixture, library in library.key == k0 && !Self.caughtUp(fixture) },
            // The relaunch's lobby: the account's current passphrase, and the words (unchanged) for Always ask's road.
            typed: { fixture in TypedSecrets(passphrase: newPassphrase, words: fixture.words) })
    }

    @Test func withThePlanGoneItRollsBackOrFinishes() async throws {
        var newPassphrase: String?
        var k0: StoreKey!
        try await CrashHarness.everywhere(
            {
                let made = try await pairMovedElsewhere(.standard)
                newPassphrase = made.newPassphrase
                k0 = made.air.key
                return made.air
            },
            act: { _, executor, library in
                _ = try await executor.follow(
                    &library, kind: .pairChanged(passphrase: true, words: false), typed: TypedSecrets(passphrase: newPassphrase))
            },
            finished: { fixture, library in library.key == k0 && Self.caughtUp(fixture) },
            neverHappened: { fixture, library in library.key == k0 && !Self.caughtUp(fixture) },
            dropPlan: true, typed: { _ in TypedSecrets(passphrase: newPassphrase) })
    }
}
