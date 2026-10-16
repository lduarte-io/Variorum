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
        #expect(guards.prepareBeforeCommitOn && guards.exportOffAtCastleOn && guards.followerAnchorTypedLockOn)
        #expect(guards.oldSharedKeyDeletedByRecordedIDOn && guards.moveKeepsOldWrapOn)
        #expect(guards.retirementRerunsMovesOn && guards.freshPairAfterMoveOn)
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

    @Test func aFollowersAnchorMissesTheSecretTypedAtItsFollowWithTheGuardOff() async throws {
        for guarded in [true, false] {
            let mac = try EX(.castle, synced: true)
            let phone = try EX(.castle, synced: true, joining: mac)
            // The passphrase changed during Castle on the Mac, which then leaves.
            let me = mac.executor()
            var ml = try mac.unlocked(me)
            _ = try await me.changePassphrase(&ml, current: mac.passphrase, new: "changed on the Mac")
            _ = try await me.useStandard(&ml, typed: TypedSecrets(passphrase: "changed on the Mac", words: mac.words))
            let executor = phone.executor(guards: guarded ? .all : Self.off { $0.followerAnchorTypedLock = false })
            var library = try phone.unlocked(executor)
            _ = try await executor.follow(&library, kind: .intoStandard, typed: TypedSecrets(passphrase: "changed on the Mac"))
            let anchor = try #require(phone.world.liveFormat3?.anchor)
            #expect(anchor.opens(with: .passphrase("changed on the Mac"), floor: PF.floor) == guarded)
        }
    }

    @Test func aNewerOldNameItemIsDeletedWithTheGuardOff() async throws {
        for guarded in [true, false] {
            let fixture = try EX(.castle)
            let recorded = AppleKeyMaterial.mint(), newer = AppleKeyMaterial.mint()
            fixture.world.icloud.oldShared = newer
            let executor = fixture.executor(guards: guarded ? .all : Self.off { $0.oldSharedKeyDeletedByRecordedID = false })
            var library = try fixture.unlocked(executor)
            try executor.writeFacts(&library, section: { var s = library.section.bumped(); s.oldSharedKey = OldSharedKeyRecord(id: recorded.id); return s }())
            _ = try await executor.retireOldSharedKey(&library)
            #expect((fixture.world.icloud.oldShared != nil) == guarded)
        }
    }

    @Test func onlyTheLiveFilesOwnKeyIsRetiredAtCastleWithTheGuardOff() async throws {
        for guarded in [true, false] {
            let fixture = try EX(.standard)
            let lost = fixture.ownApple!.id
            fixture.world.icloud.keys[lost] = nil
            let executor = fixture.executor(guards: guarded ? .all : Self.off { $0.everyOwnKeyRetiredAtCastle = false })
            var library = try fixture.unlocked(executor)
            _ = try await executor.relinkLibraryArm(&library)
            _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .touchID)
            #expect(library.section.retiredAppleKeyIDs.contains(lost) == guarded)
        }
    }

    @Test func aFollowerClearsAPreviousKeyWhileTheLeavesIDStandsWithTheGuardOff() async throws {
        for guarded in [true, false] {
            let mac = try EX(.castle, synced: true)
            let phone = try EX(.castle, synced: true, joining: mac)
            let clean = try EX(.castle, synced: true)
            let ce = clean.executor()
            var cl = try clean.unlocked(ce)
            _ = try await ce.useStandard(&cl, typed: clean.typed)
            mac.world.crashAfterWrites = try #require(clean.world.writes.firstIndex { $0.description.hasPrefix("vault") }) + 1
            let me = mac.executor()
            var ml = try mac.unlocked(me)
            await #expect(throws: SimulatedCrash.self) { _ = try await me.useStandard(&ml, typed: mac.typed) }
            let named = try #require(phone.world.server.snapshot(phone.account!)?.format.appleKeyID)
            phone.world.icloud.keys[named] = nil
            let executor = phone.executor(guards: guarded ? .all : Self.off { $0.leaveIDGatesCompletion = false })
            var library = try phone.unlocked(executor)
            _ = try? await executor.follow(&library, kind: .intoStandard, typed: TypedSecrets(passphrase: phone.passphrase))
            let vault = try #require(phone.world.server.snapshot(phone.account!))
            #expect((vault.format.previousCorpusKey != nil) == guarded)
        }
    }

    @Test func theSyncKeysGoSilentInALeavesWindowWithTheGuardOff() async throws {
        for guarded in [true, false] {
            let guards = guarded ? ProtectionGuards.all : Self.off { $0.castleKindCustodyThroughLeave = false }
            let clean = try EX(.castle, synced: true)
            let ce = clean.executor(guards: guards)
            var cl = try clean.unlocked(ce)
            _ = try await ce.useStandard(&cl, typed: clean.typed)
            // Crash right after the keys were filed for the window (before the walk).
            let window = try #require(clean.world.writes.firstIndex(of: .reencrypt))
            let fixture = try EX(.castle, synced: true)
            fixture.world.crashAfterWrites = window
            let executor = fixture.executor(guards: guards)
            var library = try fixture.unlocked(executor)
            await #expect(throws: SimulatedCrash.self) { _ = try await executor.useStandard(&library, typed: fixture.typed) }
            #expect(fixture.world.syncItems.keys.contains { $0.itemClass == .silent } == !guarded)
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

    @Test func aStandardLeaveKeepsItsKeyWithTheGuardOff() async throws {
        for guarded in [true, false] {
            let fixture = try EX(.standard, synced: true)
            let k0 = fixture.key
            let executor = fixture.executor(guards: guarded ? .all : Self.off { $0.rekeyAtEveryCrossing = false })
            var library = try fixture.unlocked(executor)
            _ = try await executor.leaveAccount(.stopSyncingHere, &library, typed: fixture.typed)
            #expect((library.key != k0) == guarded)
        }
    }

    @Test func theLastStepRaceDeletesTheOldKeyAVaultStillNamesWithTheGuardOff() async throws {
        for guarded in [true, false] {
            let fixture = try EX(.castle, synced: true)
            let shared = AppleKeyMaterial.mint()
            fixture.world.icloud.oldShared = shared
            var account = fixture.world.server.accounts[fixture.account!]!
            account.format = try account.format.settingAppleHeldCopy(
                masterKey: fixture.material!.masterSymmetricKey, appleKey: shared.key, appleKeyID: shared.id)
            fixture.world.server.accounts[fixture.account!] = account
            let executor = fixture.executor(guards: guarded ? .all : Self.off { $0.doorTimeVaultCheck = false })
            var library = try fixture.unlocked(executor)
            _ = try await executor.retireOldSharedKey(&library)
            #expect((fixture.world.icloud.oldShared != nil) == guarded)
        }
    }

    @Test func useCastlesDoorOpensOnAVaultStillOnTheOldKeyWithTheGuardOff() async throws {
        for guarded in [true, false] {
            // A local library on this Mac, signed in to another account whose
            // vault an older build re-linked onto the old shared key.
            let other = try EX(.standard, synced: true)
            let shared = other.accountApple!
            other.world.icloud.oldShared = shared
            let fixture = try EX(.standard, world: ExecutorWorld(icloud: other.world.icloud, server: other.world.server))
            let executor = fixture.executor(
                guards: guarded ? .all : Self.off { $0.doorTimeVaultCheck = false }, session: other.session)
            var library = try fixture.unlocked(executor)
            if guarded {
                await #expect(throws: ExecutorRefusal.vaultOnOldSharedKey(account: other.account!)) {
                    _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .touchID)
                }
            } else {
                _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .touchID)
                #expect(fixture.liveRecord?.mode == .castle)
            }
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
