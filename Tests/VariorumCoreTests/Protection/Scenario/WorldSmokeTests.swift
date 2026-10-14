//
//  WorldSmokeTests.swift
//  VariorumCoreTests — VX-305 U4: the world's own checks — that a store
//  today's build left migrates on the new build, that an act runs on it, and
//  that the fakes keep their measured semantics (Touch ID items die on an
//  enrollment change and survive a closed lid; iCloud Keychain's delay, the
//  off switch, the same-name rule, deletes with no recovery).
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-305 U4 — the world: today's stores migrate, and the fakes keep their measured semantics")
struct WorldSmokeTests {
    @Test func todaysStandardStoreMigratesThenEntersCastle() async throws {
        let world = SWorld(seed: 7)
        let lib = try world.today(on: world.macA, TodaySpec(mode: .standard))
        let opened = try await world.launch(world.macA)
        #expect(opened.record?.mode == .standard && opened.record?.modeConfirmed == true)
        #expect(world.liveKeyFile(world.macA)?.sharedApple != nil)
        let result = await world.apply(.useCastle("macA", .touchID, newWords: false))
        #expect(result == .done, "\(world.stepLog.suffix(8).joined(separator: "\n"))")
        let record = try #require(world.macA.slot?.record)
        #expect(record.mode == .castle && record.currentFingerprint != PF.fp(lib.key))
        #expect(world.oldSharedKey(world.macA) == nil)
        await world.apply(.settle)
        #expect(world.macA.library?.section.actInFlight == nil)
    }

    @Test func aTouchIDItemDiesOnAnEnrollmentChangeButNotOnAClosedLid() async throws {
        let world = SWorld(seed: 3)
        let d = world.macA
        let item = KItem(value: .key(world.mintKey()), touchID: true, enrollment: d.biometry.generation)
        #expect(world.pressRead(d, item) != nil)
        d.biometry.lidClosed = true
        #expect(world.pressRead(d, item) == nil)
        d.biometry.lidClosed = false
        #expect(world.pressRead(d, item) != nil)
        d.biometry.osEpoch += 1  // the hash moves, nothing changed
        #expect(world.pressRead(d, item) != nil)
        await world.apply(.addFinger("macA"))
        #expect(world.pressRead(d, item) == nil)
    }

    @Test func iCloudKeychainHasADelayAnOffSwitchTheSameNameRuleAndNoRecovery() throws {
        let world = SWorld(seed: 5)
        let a = world.macA, b = world.macB
        let name = KName.apple(SWorld.scope, "11111111-1111-4111-8111-111111111111")
        world.addSynced(a, name, KItem(value: .apple(id: "1", bytes: Data([1]))))
        #expect(b.keychain.item(name) == nil)  // the delay
        world.syncICloud(a)
        world.syncICloud(b)
        #expect(b.keychain.item(name) != nil)
        // The same name written on both: one survivor, the newer.
        world.addSynced(a, name, KItem(value: .apple(id: "1", bytes: Data([2]))))
        world.addSynced(b, name, KItem(value: .apple(id: "1", bytes: Data([3]))))
        world.propagateAll()
        #expect(a.keychain.item(name) == b.keychain.item(name))
        // Off: made here stays here; on again, it syncs.
        a.iCloudOn = false
        let other = KName.apple(SWorld.scope, "22222222-2222-4222-8222-222222222222")
        world.addSynced(a, other, KItem(value: .apple(id: "2", bytes: Data([4]))))
        world.propagateAll()
        #expect(b.keychain.item(other) == nil)
        a.iCloudOn = true
        world.propagateAll()
        #expect(b.keychain.item(other) != nil)
        // A delete while off reaches only this device; the cloud's copy comes back.
        a.iCloudOn = false
        world.deleteSynced(a, other)
        #expect(a.keychain.item(other) == nil)
        a.iCloudOn = true
        world.propagateAll()
        #expect(a.keychain.item(other) != nil)
        // A delete while on reaches everyone, with no recovery.
        world.deleteSynced(a, other)
        world.propagateAll()
        #expect(a.keychain.item(other) == nil && b.keychain.item(other) == nil)
    }
}
