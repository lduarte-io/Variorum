//
//  ExecutorCoreTests.swift
//  VariorumCoreTests — VX-305 U3: the executor's core — the unlock with every
//  home verified, the settle's plan rules (a failed seal: an unsealed or
//  unnamed plan is ignored and the act rolls back or finishes from the record;
//  a memory item failing its seal loses to the record's device section), and
//  the repairs with their preconditions verified before any delete.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

/// A Use Castle stopped right after its plan's first step (the act and the
/// plan both on disk, nothing swapped).
func midUseCastle(_ fixture: EX, stopAfter writes: Int = 5) async throws {
    fixture.world.crashAfterWrites = writes
    let executor = fixture.executor()
    var library = try fixture.unlocked(executor)
    do { _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .touchID) } catch is SimulatedCrash {}
    fixture.world.relaunch()
}

@Suite("VX-305 U3 — a failed seal: plans the record doesn't name, memory that loses")
struct SettleSealTests {
    @Test func aPlantedPlanIsIgnoredReportedAndTheActRollsBack() async throws {
        let fixture = try EX(.standard)
        try await midUseCastle(fixture)
        // A plan sealed under a key the library never had (a login-password
        // holder's plant), naming the very act in flight.
        let genuine = try #require(fixture.world.plan)
        let opened = try genuine.open(purpose: .plan, libraryID: fixture.libraryID, key: fixture.key)
        fixture.world.plan = try opened.sealed(under: StoreKey.mint())
        let (outcome, library, _) = try await fixture.relaunchAndSettle()
        #expect(outcome == .rolledBack(.enterCastle))
        #expect(fixture.world.diagnosticEntries.contains(.planIgnored(.unsealed)))
        #expect(fixture.world.diagnosticEntries.contains(.actRolledBack(.enterCastle)))
        #expect(fixture.liveRecord?.mode == .standard)
        expectSettled(fixture, library)
    }

    @Test func aReplayedPlanFromAnEarlierActIsNotNamedAndChangesNothing() async throws {
        let fixture = try EX(.standard)
        // An earlier act's GENUINE plan, sealed under the library's key.
        try await midUseCastle(fixture, stopAfter: 4)
        let old = try #require(fixture.world.plan)
        let (first, _, _) = try await fixture.relaunchAndSettle()
        if case .resumed = first {} else { Issue.record("expected the act to resume, got \(first)") }
        // Now in Castle; the replayed plan names sequence 1 — nothing names it.
        fixture.world.plan = old
        let (outcome, library, _) = try await fixture.relaunchAndSettle()
        #expect(outcome == .nothingInFlight)
        #expect(fixture.world.diagnosticEntries.last == .planIgnored(.noActInFlight))
        #expect(fixture.liveRecord?.mode == .castle)
        expectSettled(fixture, library)
    }

    @Test func aGenuinePlanOfAnotherActIsNotNamedTheActRollsBack() async throws {
        let fixture = try EX(.standard)
        try await midUseCastle(fixture)
        let genuine = try #require(fixture.world.plan)
        var replayed = try genuine.open(purpose: .plan, libraryID: fixture.libraryID, key: fixture.key)
        replayed.sequence += 7
        fixture.world.plan = try replayed.sealed(under: fixture.key)
        let (outcome, _, _) = try await fixture.relaunchAndSettle()
        #expect(outcome == .rolledBack(.enterCastle))
        #expect(fixture.world.diagnosticEntries.contains(.planIgnored(.notNamed)))
    }

    /// A memory item that fails its seal remembers nothing (rule 21): the open
    /// adopts no section of the record — it mints a new plain device ID with
    /// a fresh section (rule 23; PROVISIONAL — the VX-378 heading in
    /// QUESTIONS: U2's detect-and-refuse may make this open a refusal). The
    /// marker that found this Mac's own section left with VX-378 U1.
    @Test func aMemoryItemThatFailsItsSealRemembersNothing() async throws {
        let fixture = try EX(.standard)
        try await midUseCastle(fixture)
        let sealed = try #require(fixture.world.memories[fixture.libraryID])
        let original = try sealed.open(purpose: .memory, libraryID: fixture.libraryID, key: fixture.key).deviceID
        fixture.world.memories[fixture.libraryID] = Sealed(
            payload: sealed.payload, seal: Seal(keyFingerprint: sealed.seal.keyFingerprint, mac: Data(repeating: 0, count: 32)))
        let library = try fixture.executor().unlock(with: fixture.key)
        #expect(library.memory == nil)
        #expect(library.section.deviceID != original && library.section.actInFlight == nil)
        #expect(library.section.settings == .noChoiceYet && library.section.appleKeys.isEmpty)
    }

    @Test func aStrayPlanWithNoActInFlightIsDeletedAndReported() async throws {
        let fixture = try EX(.standard)
        let plan = ProtectionPlan(
            libraryID: fixture.libraryID, deviceID: fixture.deviceID, sequence: 1, act: .replaceAllKeys,
            steps: [PlanStep(name: "rotationWrite")], createdAt: PF.t0)
        fixture.world.plan = try plan.sealed(under: fixture.key)
        let (outcome, library, _) = try await fixture.relaunchAndSettle()
        #expect(outcome == .nothingInFlight)
        #expect(fixture.world.plan == nil)
        #expect(fixture.world.diagnosticEntries == [.planIgnored(.noActInFlight)])
        expectSettled(fixture, library)
    }

    @Test func aPlanNeverHoldsASecret() async throws {
        let fixture = try EX(.standard, synced: true)
        fixture.world.crashAfterWrites = 9
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        do { _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .touchID) } catch is SimulatedCrash {}
        let sealed = try #require(fixture.world.plan)
        let bytes = try ProtectionCoding.canonical(sealed)
        for (name, secret) in [
            ("passphrase", Data(fixture.passphrase.utf8)), ("words", Data(fixture.words.joined(separator: " ").utf8)),
            ("passphrase key", PF.bytes(fixture.p.key)), ("words key", PF.bytes(fixture.w.key)),
            ("library key", fixture.key.data), ("master", fixture.material!.master),
        ] {
            #expect(!SecretScan.carries(bytes, secret), "the plan carries the \(name)")
        }
    }
}

@Suite("VX-305 U3 — the repairs: preconditions verified before any delete; no Touch ID item; decision 35")
struct ExecutorRepairTests {
    /// A Castle library with a stray silent item for K0 (the history holds
    /// it) and one for an unknown key (no road but it).
    func castleWithStrays() async throws -> (EX, StoreKey, StoreKey) {
        let fixture = try EX(.standard)
        let k0 = fixture.key
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .touchID)
        fixture.key = library.key
        let stray = StoreKey.mint()
        fixture.world.custody[CustodyItemFact(fingerprint: PF.fp(k0), itemClass: .silent)] = k0
        fixture.world.custody[CustodyItemFact(fingerprint: PF.fp(stray), itemClass: .silent)] = stray
        fixture.world.writes = []
        return (fixture, k0, stray)
    }

    @Test func aSilentItemGoesOnlyWhenTheHistoryVerifiablyHoldsItsKey() async throws {
        let (fixture, k0, stray) = try await castleWithStrays()
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        let report = try executor.runRepairs([
            .deleteSilentItem(fingerprint: PF.fp(k0), precondition: .historyHolds(fingerprint: PF.fp(k0))),
            // The assessment's word alone is not enough: the history does NOT hold it.
            .deleteSilentItem(fingerprint: PF.fp(stray), precondition: .historyHolds(fingerprint: PF.fp(stray))),
        ], on: &library)
        #expect(report.done.count == 1)
        #expect(report.skipped == [.init(
            repair: .deleteSilentItem(fingerprint: PF.fp(stray), precondition: .historyHolds(fingerprint: PF.fp(stray))),
            reason: .preconditionDoesNotVerify)])
        #expect(!fixture.custody(.silent, k0) && fixture.custody(.silent, stray))
    }

    @Test func noRepairRunsWhileAnActIsInFlight() async throws {
        let fixture = try EX(.standard)
        try await midUseCastle(fixture)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        fixture.world.writes = []
        let report = try executor.runRepairs([.refreshMemory, .restoreKeyFileFromMirror], on: &library)
        #expect(report.done.isEmpty && report.skipped.allSatisfy { $0.reason == .actInFlight })
        #expect(fixture.world.writes.isEmpty)
    }

    @Test func noRepairEverMakesATouchIDItemAndNothingDestructiveRunsOnAStandardRecordsWord() async throws {
        let castle = try EX(.castle, gate: .alwaysAsk)
        let e1 = castle.executor()
        var l1 = try castle.unlocked(e1)
        let made = try e1.runRepairs([.makeTouchIDItem(fingerprint: PF.fp(castle.key))], on: &l1)
        #expect(made.skipped.map(\.reason) == [.forbidden])
        #expect(castle.world.custody.isEmpty)
        let standard = try EX(.standard)
        standard.world.custody[CustodyItemFact(fingerprint: PF.fp(standard.key), itemClass: .touchid)] = standard.key
        let e2 = standard.executor()
        var l2 = try standard.unlocked(e2)
        let deleted = try e2.runRepairs([.deleteTouchIDItem(fingerprint: PF.fp(standard.key))], on: &l2)
        #expect(deleted.skipped.map(\.reason) == [.forbidden])
        #expect(standard.custody(.touchid, standard.key))
    }

    @Test func aChoiceOfTouchIDWithNoItemRecordsAlwaysAskQuietly() async throws {
        let fixture = try EX(.castle, gate: .touchID)
        fixture.world.custody.removeAll()
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        try executor.runRepairs([.recordAlwaysAskQuietly], on: &library)
        #expect(library.section.settings.gateStyle == .alwaysAsk)
        #expect(fixture.world.custody.isEmpty)
        #expect(fixture.world.writeLog().allSatisfy { !$0.hasPrefix("custody+") })
    }

    @Test func deleteOnSightIsByRecordedIDOnly() async throws {
        let (fixture, _, _) = try await castleWithStrays()
        let anotherMacs = AppleKeyMaterial.mint()
        fixture.world.icloud.keys[anotherMacs.id] = anotherMacs
        let retired = try #require(fixture.ownApple)
        fixture.world.icloud.keys[retired.id] = retired  // came back when sync did
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        let report = try executor.runRepairs([
            .deleteRetiredAppleKey(id: retired.id), .deleteRetiredAppleKey(id: anotherMacs.id),
        ], on: &library)
        #expect(report.done == [.deleteRetiredAppleKey(id: retired.id)])
        #expect(fixture.world.icloud.keys[retired.id] == nil && fixture.world.icloud.keys[anotherMacs.id] != nil)
    }

    @Test func decision35_NothingAppleReachableWithoutAFreshVaultRead() async throws {
        let fixture = try EX(.standard, synced: true)
        // The live key file lost its Apple wrap; this Mac's own key is readable.
        let live = try #require(fixture.world.liveFormat3)
        fixture.world.liveKeyFile = (live.droppingApple())
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        let unread = try executor.runRepairs([.landAppleWrap(appleKeyID: fixture.ownApple!.id)], on: &library)
        #expect(unread.skipped.map(\.reason) == [.needsFreshVault])
        #expect(fixture.world.liveFormat3?.apple == nil)
        // Offline: no read is possible, so nothing lands.
        fixture.world.server.reachable = false
        await #expect(throws: VaultRefusal.unreachable) { try await executor.readVault(accountID: fixture.account!) }
        #expect(try executor.runRepairs([.landAppleWrap(appleKeyID: fixture.ownApple!.id)], on: &library).done.isEmpty)
        // Read fresh this session: it lands.
        fixture.world.server.reachable = true
        try await executor.readVault(accountID: fixture.account!)
        let read = try executor.runRepairs([.landAppleWrap(appleKeyID: fixture.ownApple!.id)], on: &library)
        #expect(read.done.count == 1 && fixture.world.liveFormat3?.apple?.keyID == fixture.ownApple!.id)
    }

    @Test func decision35_AnActWritesNothingAppleReachableOffline() async throws {
        // (The move off the old shared key's half left with rule 26.)
        // Use Standard on a synced Castle library offline: refused at its door.
        let castle = try EX(.castle, synced: true)
        castle.world.server.reachable = false
        let e2 = castle.executor()
        var l2 = try castle.unlocked(e2)
        await #expect(throws: VaultRefusal.unreachable) { _ = try await e2.useStandard(&l2, typed: castle.typed) }
        #expect(castle.world.writes.isEmpty)
    }

    /// An ABSENT live key file comes back from the sealed mirror (rule 1),
    /// never with its Apple wrap.
    @Test func theKeyFileComesBackFromTheSealedMirrorButNeverItsAppleWrap() async throws {
        let fixture = try EX(.standard)
        let live = try #require(fixture.world.liveFormat3)
        fixture.world.liveKeyFile = nil
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        try executor.runRepairs([.restoreKeyFileFromMirror], on: &library)
        let restored = try #require(fixture.world.liveFormat3)
        #expect(restored.words == live.words)
        #expect(restored.apple == nil)
    }

}
