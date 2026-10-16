//
//  CrossingTests.swift
//  VariorumCoreTests — VX-305 U3: the crossings (design §3.4, §3.9) — Use
//  Castle and Use Standard, local and synced — as state transitions: the exact
//  writes in order, a crash after every write then a resume that finishes (or,
//  with the plan gone, rolls back before the swap and finishes from the record
//  after it), and every refusal named.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

/// The two end states of entering Castle.
enum UseCastleStates {
    static func finished(_ k0: StoreKey, ownApple: String?) -> WorldState {
        { fixture, library in
            guard let record = fixture.liveRecord, let live = fixture.world.liveFormat3 else { return false }
            let current = fixture.world.live!.fingerprint
            return record.mode == .castle && current != PF.fp(k0)
                && live.apple == nil && live.history.contains { $0.fingerprint == PF.fp(k0) }
                && !fixture.world.custody.keys.contains { $0.itemClass == .silent }
                && ownApple.map { fixture.world.icloud.keys[$0] == nil && library.section.retiredAppleKeyIDs.contains($0) } ?? true
        }
    }

    static func neverHappened(_ k0: StoreKey, ownApple: String?) -> WorldState {
        { fixture, library in
            guard let record = fixture.liveRecord else { return false }
            return record.mode == .standard && fixture.world.live!.fingerprint == PF.fp(k0)
                && fixture.world.liveFormat3?.fingerprint == PF.fp(k0)
                && fixture.world.custody.keys.map(\.fingerprint) == [PF.fp(k0)]
                && ownApple.map { fixture.world.icloud.keys[$0] != nil && !library.section.retiredAppleKeyIDs.contains($0) } ?? true
        }
    }
}

@Suite("VX-305 U3 — Use Castle: the exact writes, a crash after every write, the refusals")
struct UseCastleTests {
    @Test func useCastleLocalWritesExactlyThisInOrder() async throws {
        let fixture = try EX(.standard, scheduledExport: true)
        let k0 = fixture.key, own = fixture.ownApple!.id
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        let outcome = try await executor.useCastle(&library, typed: fixture.typed, gate: .touchID)
        let k1 = library.key
        #expect(outcome.notices == [.scheduledExportTurnedOff])
        #expect(fixture.world.writeLog(naming: [PF.fp(k0): "K0", PF.fp(k1): "K1"]) + [] == [
            "record K0", "memory K0", "plan",                       // the act named in both homes, then the plan
            "custody+ touchid K1", "plan",                          // the new key's item, at this press
            "keyfile K1", "plan",                                   // the new key file: the history takes K0
            "stage K1", "plan",                                     // re-encrypted into the staged file
            "staged-record K1", "plan",                             // the record written into it
            "swap K1", "plan",                                      // THE COMMIT
            "memory K1", "plan",                                    // what this Mac remembers
            "custody- silent K0", "plan",                           // the old item — after the swap
            "record K1", "memory K1", "plan",                       // the scheduled export off
            "backup K1", "plan",                                    // a fresh pair
            "apple- \(own.prefix(8))", "record K1", "memory K1", "plan",  // this Mac's own Apple key retired
            "record K1", "memory K1", "plan-",                      // the act ends
        ])
        #expect(fixture.world.copyEvents == ["pause", "resume"])
        expectSettled(fixture, library)
        #expect(UseCastleStates.finished(k0, ownApple: own)(fixture, library))
        // The history verifiably holds K0; the backup pair is under K1.
        #expect(try fixture.world.liveFormat3?.historyKey(PF.fp(k0), currentKey: k1) == k0)
        #expect(fixture.world.backups.map(\.fingerprint) == [PF.fp(k1)])
        #expect(library.section.settings.scheduledExport == false)
    }

    @Test func aCrashAfterEveryWriteFinishesOnResume_TouchID() async throws {
        var k0: StoreKey!, own: String!
        try await CrashHarness.everywhere(
            { let f = try EX(.standard, scheduledExport: true); k0 = f.key; own = f.ownApple!.id; return f },
            act: { fixture, executor, library in _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .touchID) },
            finished: { UseCastleStates.finished(k0, ownApple: own)($0, $1) },
            neverHappened: { UseCastleStates.neverHappened(k0, ownApple: own)($0, $1) })
    }

    @Test func aCrashAfterEveryWriteFinishesOnResume_AlwaysAsk() async throws {
        var k0: StoreKey!, own: String!
        try await CrashHarness.everywhere(
            { let f = try EX(.standard); k0 = f.key; own = f.ownApple!.id; return f },
            act: { fixture, executor, library in _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .alwaysAsk) },
            finished: { UseCastleStates.finished(k0, ownApple: own)($0, $1) },
            neverHappened: { UseCastleStates.neverHappened(k0, ownApple: own)($0, $1) })
    }

    @Test func withThePlanGoneItRollsBackBeforeTheSwapAndFinishesFromTheRecordAfter() async throws {
        var k0: StoreKey!, own: String!
        try await CrashHarness.everywhere(
            { let f = try EX(.standard); k0 = f.key; own = f.ownApple!.id; return f },
            act: { fixture, executor, library in _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .touchID) },
            finished: { UseCastleStates.finished(k0, ownApple: own)($0, $1) },
            neverHappened: { UseCastleStates.neverHappened(k0, ownApple: own)($0, $1) },
            dropPlan: true)
    }

    @Test func syncedUseCastleRotatesTheAccountThenTheLibrary() async throws {
        let fixture = try EX(.standard, synced: true)
        let k0 = fixture.key, own = fixture.ownApple!.id, accountKey = fixture.accountApple!.id
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .touchID)
        let k1 = library.key
        #expect(fixture.world.writeLog(naming: [PF.fp(k0): "K0", PF.fp(k1): "K1"]) == [
            "record K0", "memory K0", "plan",
            "plan", "vault rotating", "sync+ touchid", "sync- silent", "plan",     // the account's commit point
            "reencrypt", "plan",                                                 // the walk
            "vault castle", "sync+ touchid", "apple- \(accountKey.prefix(8))", "record K0", "memory K0", "plan",
            "custody+ touchid K1", "plan", "keyfile K1", "plan", "stage K1", "plan", "staged-record K1", "plan",
            "swap K1", "plan", "memory K1", "plan", "custody- silent K0", "plan",
            "plan", "backup K1", "plan", "apple- \(own.prefix(8))", "record K1", "memory K1", "plan",
            "record K1", "memory K1", "plan-",
        ])
        let vault = try #require(fixture.world.server.snapshot(fixture.account!))
        #expect(vault.mode == .castle && vault.format.previousCorpusKey == nil)
        // No Castle-era key under anything Apple-reachable; the sync keys the Castle way.
        #expect(fixture.world.syncItems.keys.map(\.itemClass) == [.touchid])
        #expect(library.section.retiredAppleKeyIDs == [own, accountKey])
        // The new key file carries the new master with its words copy (§3.5a).
        let live = try #require(fixture.world.liveFormat3)
        #expect(live.masterWordsCopy == vault.format.masterWrappedByRecovery)
        #expect(try live.open(wordsThroughMaster: fixture.words) == k1)
        expectSettled(fixture, library)
    }

    @Test func syncedUseCastleCrashAfterEveryWriteFinishes_AlwaysAsk() async throws {
        var k0: StoreKey!, own: String!
        try await CrashHarness.everywhere(
            { let f = try EX(.standard, synced: true); k0 = f.key; own = f.ownApple!.id; return f },
            act: { fixture, executor, library in _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .alwaysAsk) },
            finished: { fixture, library in
                UseCastleStates.finished(k0, ownApple: own)(fixture, library)
                    && fixture.world.server.snapshot(fixture.account!)!.mode == .castle
            },
            neverHappened: { UseCastleStates.neverHappened(k0, ownApple: own)($0, $1) })
    }

    @Test func theRefusalsAreNamed() async throws {
        // Already in Castle.
        let castle = try EX(.castle)
        let e1 = castle.executor()
        var l1 = try castle.unlocked(e1)
        await #expect(throws: ExecutorRefusal.wrongMode(.castle)) {
            _ = try await e1.useCastle(&l1, typed: castle.typed, gate: .touchID)
        }
        // A wrong passphrase.
        let standard = try EX(.standard)
        let e2 = standard.executor()
        var l2 = try standard.unlocked(e2)
        await #expect(throws: ExecutorRefusal.passphraseDoesNotOpen) {
            _ = try await e2.useCastle(&l2, typed: TypedSecrets(passphrase: "wrong", words: standard.words), gate: .touchID)
        }
        // Synced, signed out: the one plain road stands in its place.
        let synced = try EX(.standard, synced: true)
        let e3 = synced.executor(session: .signedOut)
        var l3 = try synced.unlocked(e3)
        await #expect(throws: ExecutorRefusal.signedOutUseThisMacOnly) {
            _ = try await e3.useCastle(&l3, typed: synced.typed, gate: .touchID)
        }
        // Decision 32: a rotation still finishing.
        let rotating = try EX(.standard, synced: true)
        var account = rotating.world.server.accounts[rotating.account!]!
        account.format = try account.format.carryingPreviousCorpusKey(
            SymmetricKey(size: .bits256), keyID: "old", masterKey: rotating.material!.masterSymmetricKey)
        rotating.world.server.accounts[rotating.account!] = account
        let e4 = rotating.executor()
        var l4 = try rotating.unlocked(e4)
        await #expect(throws: ExecutorRefusal.rotationInProgress) {
            _ = try await e4.useCastle(&l4, typed: rotating.typed, gate: .touchID)
        }
        // Nothing was written by any refused door.
        for fixture in [castle, standard, synced, rotating] { #expect(fixture.world.writes.isEmpty) }
        // An act already in flight.
        let busy = try EX(.standard)
        busy.world.crashAfterWrites = 4
        let e5 = busy.executor()
        var l5 = try busy.unlocked(e5)
        await #expect(throws: SimulatedCrash.self) { _ = try await e5.useCastle(&l5, typed: busy.typed, gate: .touchID) }
        busy.world.relaunch()
        let e6 = busy.executor()
        var l6 = try busy.unlocked(e6)
        await #expect(throws: ExecutorRefusal.actInFlight(.enterCastle)) {
            _ = try await e6.useCastle(&l6, typed: busy.typed, gate: .touchID)
        }
    }
}
