//
//  ExecutorGuardTests.swift
//  VariorumCoreTests — VX-305 U3: the executor's guards (one
//  `ProtectionGuards` value, off-switches `#if DEBUG` only) — every guard on
//  by default in both configurations, and, in Debug, each switched off LETS
//  ITS BUG THROUGH beside the guarded run that doesn't (red-on-old for new
//  code: the phase plan §6's mutation pins, at the executor's level).
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-305 U3 — the executor's guards are on by default, in both configurations")
struct ExecutorGuardsOnTests {
    @Test func everyU3GuardIsOn() {
        let guards = ProtectionGuards.all
        #expect(guards.planNamedBySectionOn && guards.repairPreconditionsVerifiedOn && guards.repairNeverMakesTouchIDItemOn)
        #expect(guards.prepareBeforeCommitOn && guards.exportOffAtCastleOn)
    }
}

#if DEBUG
@Suite("VX-305 U3 — each executor guard, switched off, lets its bug through (DEBUG mutation pins)")
struct ExecutorGuardMutationTests {
    static func off(_ change: (inout ProtectionGuards) -> Void) -> ProtectionGuards {
        var guards = ProtectionGuards.all
        change(&guards)
        return guards
    }

    @Test func aPlanTheSectionDoesntNameResumesWithTheGuardOff() async throws {
        for guarded in [true, false] {
            let fixture = try EX(.castle)
            // A genuine plan of an earlier act, replayed: it would turn the
            // scheduled export on.
            let replay = ProtectionPlan(
                libraryID: fixture.libraryID, deviceID: fixture.deviceID, sequence: 1, act: .deviceSettings,
                steps: [PlanStep(name: "settings")], createdAt: PF.t0,
                parameters: ActParameters(settings: DeviceSettings(gateStyle: .touchID, scheduledExport: true)))
            fixture.world.plan = try replay.sealed(under: fixture.key)
            let guards = guarded ? ProtectionGuards.all : Self.off { $0.planNamedBySection = false }
            let (outcome, library, _) = try await fixture.relaunchAndSettle(guards: guards)
            if guarded {
                #expect(outcome == .nothingInFlight && !library.section.settings.scheduledExport)
            } else {
                #expect(library.section.settings.scheduledExport, "the replayed plan changed this Mac's settings")
            }
        }
    }

    @Test func aRepairDeletesTheOnlyRoadWithThePreconditionUnchecked() async throws {
        for guarded in [true, false] {
            let fixture = try EX(.standard)
            let executor = fixture.executor()
            var library = try fixture.unlocked(executor)
            _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .touchID)
            fixture.key = library.key
            let stray = StoreKey.mint()
            fixture.world.custody[CustodyItemFact(fingerprint: PF.fp(stray), itemClass: .silent)] = stray
            let repairer = fixture.executor(guards: guarded ? .all : Self.off { $0.repairPreconditionsVerified = false })
            var again = try repairer.unlock(with: fixture.key)
            try repairer.runRepairs([.deleteSilentItem(
                fingerprint: PF.fp(stray), precondition: .historyHolds(fingerprint: PF.fp(stray)))], on: &again)
            #expect(fixture.custody(.silent, stray) == guarded)
        }
    }

    @Test func aRepairMakesATouchIDItemWithTheGuardOff() throws {
        for guarded in [true, false] {
            let fixture = try EX(.castle, gate: .alwaysAsk)
            let executor = fixture.executor(guards: guarded ? .all : Self.off { $0.repairNeverMakesTouchIDItem = false })
            var library = try fixture.unlocked(executor)
            try executor.runRepairs([.makeTouchIDItem(fingerprint: PF.fp(fixture.key))], on: &library)
            #expect(fixture.custody(.touchid, fixture.key) == !guarded)
        }
    }

    @Test func swappingBeforeTheKeyFileStrandsTheLibraryWithTheGuardOff() async throws {
        let guards = Self.off { $0.prepareBeforeCommit = false }
        let clean = try EX(.standard)
        let ce = clean.executor(guards: guards)
        var cl = try clean.unlocked(ce)
        _ = try await ce.useCastle(&cl, typed: clean.typed, gate: .alwaysAsk)
        let swapAt = try #require(clean.world.writes.firstIndex { $0.description.hasPrefix("swap") }) + 1
        let fixture = try EX(.standard)
        fixture.world.crashAfterWrites = swapAt
        let executor = fixture.executor(guards: guards)
        var library = try fixture.unlocked(executor)
        await #expect(throws: SimulatedCrash.self) { _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .alwaysAsk) }
        fixture.world.relaunch()
        #expect(fixture.openByRoads(fixture.typed) == nil, "no road opens the swapped library — stranded")
    }

    @Test func theScheduledExportStaysOnWithTheGuardOff() async throws {
        for guarded in [true, false] {
            let fixture = try EX(.standard, scheduledExport: true)
            let executor = fixture.executor(guards: guarded ? .all : Self.off { $0.exportOffAtCastle = false })
            var library = try fixture.unlocked(executor)
            _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .touchID)
            #expect(library.section.settings.scheduledExport == !guarded)
        }
    }

    @Test func onlyTheLiveFilesOwnKeyIsRetiredAtCastleWithTheGuardOff() async throws {
        for guarded in [true, false] {
            let fixture = try EX(.standard)
            let lost = fixture.ownApple!.id
            fixture.world.icloud.keys[lost] = nil
            let executor = fixture.executor(guards: guarded ? .all : Self.off { $0.everyOwnKeyRetiredAtCastle = false })
            var library = try fixture.unlocked(executor)
            let minted = AppleKeyMaterial.mint()
            fixture.world.icloud.keys[minted.id] = minted
            library.section = library.section.recordingAppleKey(AppleKeyRecord(id: minted.id, purpose: .library, origin: .minted))
            _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .touchID)
            #expect(library.section.retiredAppleKeyIDs.contains(minted.id) == guarded)
        }
    }

    @Test func anAppleWrapLandsWithoutAFreshVaultReadWithTheGuardOff() throws {
        for guarded in [true, false] {
            let fixture = try EX(.standard, synced: true)
            fixture.world.liveKeyFile = (try #require(fixture.world.liveFormat3).droppingApple())
            let executor = fixture.executor(guards: guarded ? .all : Self.off { $0.freshVaultBeforeAppleWrite = false })
            var library = try fixture.unlocked(executor)
            try executor.runRepairs([.landAppleWrap(appleKeyID: fixture.ownApple!.id)], on: &library)
            #expect((fixture.world.liveFormat3?.apple == nil) == guarded)
        }
    }

    @Test func aTouchIDItemIsDeletedOnAStandardRecordsWordWithTheGuardOff() throws {
        for guarded in [true, false] {
            let fixture = try EX(.standard)
            fixture.world.custody[CustodyItemFact(fingerprint: PF.fp(fixture.key), itemClass: .touchid)] = fixture.key
            let executor = fixture.executor(guards: guarded ? .all : Self.off { $0.standardRecordNoDestructiveRepair = false })
            var library = try fixture.unlocked(executor)
            try executor.runRepairs([.deleteTouchIDItem(fingerprint: PF.fp(fixture.key))], on: &library)
            #expect(fixture.custody(.touchid, fixture.key) == guarded)
        }
    }

    @Test func anotherMacsAppleKeyIsDeletedOnSightWithTheGuardOff() async throws {
        for guarded in [true, false] {
            let fixture = try EX(.standard)
            let executor = fixture.executor(guards: guarded ? .all : Self.off { $0.deleteOnSightByIDOnly = false })
            var library = try fixture.unlocked(executor)
            _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .touchID)
            let anotherMacs = AppleKeyMaterial.mint()
            fixture.world.icloud.keys[anotherMacs.id] = anotherMacs
            try executor.runRepairs([.deleteRetiredAppleKey(id: anotherMacs.id)], on: &library)
            #expect((fixture.world.icloud.keys[anotherMacs.id] != nil) == guarded)
        }
    }
}
#endif
