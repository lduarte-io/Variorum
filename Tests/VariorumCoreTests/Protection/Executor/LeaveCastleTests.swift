//
//  LeaveCastleTests.swift
//  VariorumCoreTests — VX-305 U3: Use Standard — leaving Castle is a key
//  change (rule 12): the rotation's first write with the new master's Apple
//  wrap under the account's fresh key (the account's commit point), the
//  completing write by anyone, the sync keys silent (the account's mode), a
//  fresh own Apple key, the history carrying every Castle key (rule 4) — the
//  exact writes, a crash after every write, the refusals. (The anchor and the
//  stuck leave left with VX-378 U1.)
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

enum UseStandardStates {
    static func finished(_ k0: StoreKey) -> WorldState {
        { fixture, library in
            guard let record = fixture.liveRecord, let live = fixture.world.liveFormat3, let apple = live.apple
            else { return false }
            let current = fixture.world.live!.fingerprint
            // Rule 4: the current passphrase and words open the Castle key
            // through the history.
            let historyOpens = [ProtectionSecret.passphrase(fixture.passphrase), .words(fixture.words)].allSatisfy { secret in
                guard let key = try? live.open(secret, floor: PF.floor) else { return false }
                return (try? live.historyKey(PF.fp(k0), currentKey: key)) == k0
            }
            return record.mode == .standard && current != PF.fp(k0)
                && historyOpens
                && fixture.world.icloud.keys[apple.keyID] != nil
                && library.section.appleKeys.contains { $0.id == apple.keyID && $0.retiredAt == nil }
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

@Suite("VX-305 U3 — Use Standard: the history carried, the exact writes, a crash after every write")
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
            "custody+ silent K1", "plan",                                  // the new key's silent item
            "plan", "apple+ \(own.prefix(8))", "record K0", "memory K0", "plan",  // this Mac's own FRESH Apple key
            "keyfile K1", "plan",                                          // its history carrying K0 (rule 4)
            "stage K1", "plan", "staged-record K1", "plan", "swap K1", "plan",
            "memory K1", "plan",
            "custody- touchid K0", "plan",                                 // the Castle key's Touch ID item goes with it
            "backup K1", "plan",
            "record K1", "memory K1", "plan-",
        ])
        expectSettled(fixture, library)
        #expect(UseStandardStates.finished(k0)(fixture, library))
        // Rule 12: the new Standard key carries every Castle key.
        let live = try #require(fixture.world.liveFormat3)
        #expect(try live.historyKeys(currentKey: k1).map(\.key) == [k0])
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

    /// Rule 12 + rule 15: the account's part of the leave is the MODE flag,
    /// flipped in one write — no key changes on the server — and the sync keys
    /// go to a silent item (the account's mode is Standard).
    @Test func syncedUseStandardFlipsTheModeFlagAndChangesNoKey() async throws {
        let fixture = try EX(.castle, synced: true)
        let k0 = fixture.key
        let before = try #require(fixture.world.server.snapshot(fixture.account!))
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.useStandard(&library, typed: fixture.typed)
        let k1 = library.key
        let own = try #require(fixture.world.liveFormat3?.apple?.keyID)
        #expect(fixture.world.writeLog(naming: [PF.fp(k0): "K0", PF.fp(k1): "K1"]) == [
            "record K0", "memory K0", "plan",
            "vault standard", "sync+ silent", "sync- touchid", "plan",      // the flag, and the keys held the Standard way
            "custody+ silent K1", "plan",
            "plan", "apple+ \(own.prefix(8))", "record K0", "memory K0", "plan",
            "keyfile K1", "plan", "stage K1", "plan", "staged-record K1", "plan", "swap K1", "plan",
            "memory K1", "plan", "custody- touchid K0", "plan", "backup K1", "plan",
            "record K1", "memory K1", "plan-",
        ])
        let vault = try #require(fixture.world.server.snapshot(fixture.account!))
        #expect(vault.mode == .standard)
        #expect(vault.rowKeyID == before.rowKeyID && vault.vault.keyProofHash == before.vault.keyProofHash,
                "the leave changed a key on the server")
        #expect(vault.vault.earlierRowKeys == before.vault.earlierRowKeys)
        #expect(fixture.liveRecord?.accountRowKeyID == before.rowKeyID)
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
                    && fixture.world.server.snapshot(fixture.account!)!.mode == .standard
            },
            neverHappened: { UseStandardStates.neverHappened(k0)($0, $1) })
    }

    @Test func pastTheVaultWriteWithThePlanGoneTheDeviceFollowsOutQuietly() async throws {
        // The flag flipped; the plan is lost: the library half rolls back, the
        // vault reads Standard already (rule 12), and the follow out is quiet —
        // nothing typed, the device's keys still open the vault. Never a stuck
        // state.
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
        #expect(fixture.world.server.snapshot(fixture.account!)!.mode == .standard)
        let finisher = fixture.executor()
        var again = try finisher.unlock(with: fixture.key)
        let outcome = try await finisher.follow(&again, kind: .intoStandard, typed: .none)
        #expect(outcome.notices.contains(.followedOutOfCastle))
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
