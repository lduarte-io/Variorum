//
//  LeaveCastleTests.swift
//  VariorumCoreTests — VX-305 U3: Use Standard — leaving Castle is a key
//  change (design §3.9): the anchor written first, the rotation's first write
//  naming the account's fresh key with no wrap (the account's commit point),
//  the completing write only by a device that reads the named key, the sync
//  keys the Castle way through the window, a fresh own Apple key, an empty
//  history — the exact writes, a crash after every write, the refusals.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

enum UseStandardStates {
    static func finished(_ k0: StoreKey) -> WorldState {
        { fixture, library in
            guard let record = fixture.liveRecord, let live = fixture.world.liveFormat3, let apple = live.apple,
                  let anchor = live.anchor else { return false }
            let current = fixture.world.live!.fingerprint
            let anchorOpens = (try? anchor.open(.passphrase(fixture.passphrase), floor: PF.floor).outgoing.key) == k0
                && (try? anchor.open(.words(fixture.words), floor: PF.floor).outgoing.key) == k0
            return record.mode == .standard && record.modeConfirmed && current != PF.fp(k0)
                && live.history.isEmpty && anchorOpens
                && fixture.world.icloud.keys[apple.keyID] != nil
                && library.section.appleKeys.contains { $0.id == apple.keyID && $0.isOwnLibraryKey && $0.retiredAt == nil }
                && fixture.world.custody.keys.map(\.itemClass) == [.silent]
        }
    }

    static func neverHappened(_ k0: StoreKey) -> WorldState {
        { fixture, library in
            guard let record = fixture.liveRecord else { return false }
            return record.mode == .castle && fixture.world.live!.fingerprint == PF.fp(k0)
                && fixture.world.liveFormat3?.fingerprint == PF.fp(k0) && fixture.world.liveFormat3?.apple == nil
                && !fixture.world.custody.keys.contains { $0.itemClass == .silent }
                && library.section.ownLibraryAppleKeyIDsToRetire.isEmpty
        }
    }
}

@Suite("VX-305 U3 — Use Standard: the anchor first, the exact writes, a crash after every write")
struct UseStandardTests {
    @Test func useStandardLocalWritesExactlyThisInOrder() async throws {
        let fixture = try EX(.castle)
        let k0 = fixture.key
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        let outcome = try await executor.useStandard(&library, typed: fixture.typed)
        let k1 = library.key
        let own = try #require(fixture.world.liveFormat3?.apple?.keyID)
        #expect(outcome.done == [.ruleFive])
        #expect(fixture.world.writeLog(naming: [PF.fp(k0): "K0", PF.fp(k1): "K1"]) == [
            "record K0", "memory K0", "plan",
            "keyfile K0", "plan",                                          // THE ANCHOR FIRST, into the outgoing file
            "custody+ silent K1", "plan",                                  // the new key's silent item
            "plan", "apple+ \(own.prefix(8))", "record K0", "memory K0", "plan",  // this Mac's own FRESH Apple key
            "keyfile K1", "plan",                                          // empty history, the anchor carried
            "stage K1", "plan", "staged-record K1", "plan", "swap K1", "plan",
            "memory K1", "plan",
            "custody- touchid K0", "plan",                                 // the Castle key's Touch ID item goes with it
            "backup K1", "plan",
            "record K1", "memory K1", "plan-",
        ])
        expectSettled(fixture, library)
        #expect(UseStandardStates.finished(k0)(fixture, library))
        // The anchor keeps the secrets of its day: Touch ID, the Apple key and
        // the new key reach nothing from before the leave.
        let live = try #require(fixture.world.liveFormat3)
        #expect(try live.historyKeys(currentKey: k1).isEmpty)
        #expect(live.anchor?.locks.outgoingKey == nil)
    }

    @Test func aCrashAfterEveryWriteFinishesOnResume() async throws {
        var k0: StoreKey!
        try await CrashHarness.everywhere(
            { let f = try EX(.castle); k0 = f.key; return f },
            act: { fixture, executor, library in _ = try await executor.useStandard(&library, typed: fixture.typed) },
            finished: { UseStandardStates.finished(k0)($0, $1) },
            neverHappened: { UseStandardStates.neverHappened(k0)($0, $1) })
    }

    @Test func aCrashAfterEveryWriteOnAlwaysAskFinishesOnResume() async throws {
        var k0: StoreKey!
        try await CrashHarness.everywhere(
            { let f = try EX(.castle, gate: .alwaysAsk); k0 = f.key; return f },
            act: { fixture, executor, library in _ = try await executor.useStandard(&library, typed: fixture.typed) },
            finished: { UseStandardStates.finished(k0)($0, $1) },
            neverHappened: { UseStandardStates.neverHappened(k0)($0, $1) })
    }

    @Test func withThePlanGoneItRollsBackBeforeTheSwapAndFinishesFromTheRecordAfter() async throws {
        var k0: StoreKey!
        try await CrashHarness.everywhere(
            { let f = try EX(.castle, gate: .alwaysAsk); k0 = f.key; return f },
            act: { fixture, executor, library in _ = try await executor.useStandard(&library, typed: fixture.typed) },
            finished: { UseStandardStates.finished(k0)($0, $1) },
            neverHappened: { UseStandardStates.neverHappened(k0)($0, $1) },
            dropPlan: true)
    }

    @Test func syncedUseStandardMarksTheLeaveThenCompletesIt() async throws {
        let fixture = try EX(.castle, synced: true)
        let k0 = fixture.key
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.useStandard(&library, typed: fixture.typed)
        let k1 = library.key
        let account = try #require(library.section.appleKeys.first { $0.purpose == .account }?.id)
        let own = try #require(fixture.world.liveFormat3?.apple?.keyID)
        #expect(fixture.world.writeLog(naming: [PF.fp(k0): "K0", PF.fp(k1): "K1"]) == [
            "record K0", "memory K0", "plan",
            "keyfile K0", "plan",                                              // the anchor first
            "plan", "apple+ \(account.prefix(8))", "record K0", "memory K0", "plan",  // the account's FRESH key
            "plan", "vault rotating apple-id-no-wrap", "sync+ touchid", "plan",      // the mark of a leave; Castle-kind keys
            "reencrypt", "plan",
            "vault apple-wrap", "sync+ silent", "sync- touchid", "plan",     // ONE write completes it; the keys go silent
            "custody+ silent K1", "plan",
            "plan", "apple+ \(own.prefix(8))", "record K0", "memory K0", "plan",
            "keyfile K1", "plan", "stage K1", "plan", "staged-record K1", "plan", "swap K1", "plan",
            "memory K1", "plan", "custody- touchid K0", "plan", "backup K1", "plan",
            "record K1", "memory K1", "plan-",
        ])
        let vault = try #require(fixture.world.server.snapshot(fixture.account!))
        #expect(vault.mode == .standard(appleKeyID: account) && vault.format.previousCorpusKey == nil)
        #expect(UseStandardStates.finished(k0)(fixture, library))
        expectSettled(fixture, library)
    }

    @Test func syncedUseStandardCrashAfterEveryWriteFinishes_AlwaysAsk() async throws {
        var k0: StoreKey!
        try await CrashHarness.everywhere(
            { let f = try EX(.castle, synced: true, gate: .alwaysAsk); k0 = f.key; return f },
            act: { fixture, executor, library in _ = try await executor.useStandard(&library, typed: fixture.typed) },
            finished: { fixture, library in
                UseStandardStates.finished(k0)(fixture, library)
                    && fixture.world.server.snapshot(fixture.account!)!.format.masterWrappedByAppleHeld != nil
            },
            neverHappened: { UseStandardStates.neverHappened(k0)($0, $1) })
    }

    @Test func pastTheVaultsFirstWriteWithThePlanGoneTheDeviceFinishesTheLeaveAsAnyFollower() async throws {
        // The account's commit point passed; the plan is lost: the library
        // half rolls back, the vault reads a leave in progress, and the
        // finish (a follow into Standard — this device reads the named key,
        // it minted it) completes it. Never a third state.
        let fixture = try EX(.castle, synced: true)
        let k0 = fixture.key
        let clean = try EX(.castle, synced: true)
        let ce = clean.executor()
        var cl = try clean.unlocked(ce)
        _ = try await ce.useStandard(&cl, typed: clean.typed)
        let vaultWrite = try #require(clean.world.writes.firstIndex { $0.description.hasPrefix("vault") })
        fixture.world.crashAfterWrites = vaultWrite + 1
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        await #expect(throws: SimulatedCrash.self) { _ = try await executor.useStandard(&library, typed: fixture.typed) }
        let (settled, rolledBack, _) = try await fixture.relaunchAndSettle(dropPlan: true)
        #expect(settled == .rolledBack(.leaveCastle))
        #expect(UseStandardStates.neverHappened(k0)(fixture, rolledBack))
        #expect(fixture.world.server.snapshot(fixture.account!)!.reading.mode == .leavingCastle(
            appleKeyID: fixture.world.server.snapshot(fixture.account!)!.format.appleKeyID!))
        let finisher = fixture.executor()
        var again = try finisher.unlock(with: fixture.key)
        let outcome = try await finisher.follow(&again, kind: .intoStandard, typed: TypedSecrets(passphrase: fixture.passphrase))
        #expect(!outcome.held)
        #expect(fixture.world.server.snapshot(fixture.account!)!.format.masterWrappedByAppleHeld != nil)
        #expect(fixture.liveRecord?.mode == .standard)
        expectSettled(fixture, again)
    }

    @Test func theRefusalsAreNamed() async throws {
        let standard = try EX(.standard)
        let e1 = standard.executor()
        var l1 = try standard.unlocked(e1)
        await #expect(throws: ExecutorRefusal.wrongMode(.standard)) { _ = try await e1.useStandard(&l1, typed: standard.typed) }
        let castle = try EX(.castle)
        let e2 = castle.executor()
        var l2 = try castle.unlocked(e2)
        await #expect(throws: ExecutorRefusal.wordsMustBeTyped) {
            _ = try await e2.useStandard(&l2, typed: TypedSecrets(passphrase: castle.passphrase, words: try PF.words(), wordsAreNew: true))
        }
        await #expect(throws: ExecutorRefusal.wordsDoNotOpen) {
            _ = try await e2.useStandard(&l2, typed: TypedSecrets(passphrase: castle.passphrase, words: try PF.words()))
        }
        let synced = try EX(.castle, synced: true)
        let e3 = synced.executor(session: .signedIn(accountID: PF.id(), email: nil))
        var l3 = try synced.unlocked(e3)
        await #expect(throws: ExecutorRefusal.otherAccountSignedIn) { _ = try await e3.useStandard(&l3, typed: synced.typed) }
        for fixture in [standard, castle, synced] { #expect(fixture.world.writes.isEmpty) }
    }
}
