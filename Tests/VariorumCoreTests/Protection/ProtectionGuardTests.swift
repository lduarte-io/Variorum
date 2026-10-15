//
//  ProtectionGuardTests.swift
//  VariorumCoreTests — VX-305 U1: the guards in the model's own functions are
//  LIVE — each one, switched off (DEBUG only, `ProtectionGuards`), lets its bug
//  through; switched on, it closes it. The red-on-old for new code at the unit
//  level; U4's mutation pins run the fixed scenarios the same way.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-305 U1 — ProtectionGuards: a Release build has no off-switch")
struct ProtectionGuardsTests {
    @Test func everyGuardIsOnByDefault() {
        let guards = ProtectionGuards.all
        #expect(guards.twoHomesOn)
        #expect(guards.hardwareMarkerOn)
        #expect(guards.familyTreeTwoHomesOn)
        #expect(guards.anchorCarriedByEveryRekeyOn)
        #expect(guards.anchorWrittenFirstOn)
    }
}

#if DEBUG
@Suite("VX-305 U1 — each model guard, switched off, lets its bug through (DEBUG mutation pins)")
struct ProtectionGuardMutationTests {
    /// THE TWO HOMES: a memory item replayed alone (older) would win and
    /// un-retire an id.
    @Test func twoHomes() {
        let id = PF.id(), retired = PF.id()
        let current = DeviceSection(deviceID: id, hardwareMarker: .stub("m"), version: 8, settings: DeviceSettings(gateStyle: .alwaysAsk))
            .retiringAppleKey(id: retired, purpose: .library, origin: .minted, at: PF.day(1))
        let replayed = DeviceSection(deviceID: id, hardwareMarker: .stub("m"), version: 2, settings: DeviceSettings(gateStyle: .touchID))
        let on = DeviceFacts.reconcile(record: current, memory: replayed)!
        #expect(on.settings.gateStyle == .alwaysAsk)
        #expect(on.retiredAppleKeyIDs == [retired])
        var off = ProtectionGuards()
        off.twoHomes = false
        let broken = DeviceFacts.reconcile(record: current, memory: replayed, guards: off)!
        #expect(broken.settings.gateStyle == .touchID, "red with the guard off: the replay won")
        #expect(broken.retiredAppleKeyIDs.isEmpty, "red with the guard off: delete on sight weakened")
    }

    /// THE HARDWARE MARKER: a second login would adopt the first login's
    /// section (VX-340), and a memory item on new hardware would keep its
    /// identity (two Macs on one device cursor).
    @Test func hardwareMarker() {
        let salt = HardwareMarker.mintSalt()
        let first = DeviceSection(deviceID: PF.id(), hardwareMarker: HardwareMarker.compute(PF.macA, salt: salt),
                                  settings: .noChoiceYet)
        let memory = DeviceMemory(
            libraryID: PF.id(), scope: "Variorum", currentFingerprint: "abababababababab", keyEpoch: 1,
            familyTree: FamilyTree(), deviceSection: first)
        let secondLogin = HardwareMarker.compute(PF.macASecondLogin, salt: salt)
        let newHardware = HardwareMarker.compute(PF.macB, salt: salt)
        #expect(DeviceFacts.resolveIdentity(memory: nil, sections: [first], marker: secondLogin)
            == .anotherLogin, "the split marker: this hardware's part, another login's part")
        #expect(DeviceFacts.resolveIdentity(memory: memory, sections: [first], marker: newHardware)
            == .newIdentity(predecessorID: first.deviceID))
        var off = ProtectionGuards()
        off.hardwareMarker = false
        #expect(DeviceFacts.resolveIdentity(memory: nil, sections: [first], marker: secondLogin, guards: off)
            == .foundByMarker(deviceID: first.deviceID), "red with the guard off: the second login adopted the first's")
        #expect(DeviceFacts.resolveIdentity(memory: memory, sections: [first], marker: newHardware, guards: off)
            == .continuing(deviceID: first.deviceID), "red with the guard off: two Macs share one identity")
    }

    /// THE FAMILY TREE's TWO HOMES: a rolled-back library file would make its
    /// own later copies look foreign.
    @Test func familyTreeTwoHomes() {
        let mac = PF.id()
        let early = FamilyTree().recordingBirth(fingerprint: "1111111111111111", kind: .castle, madeBy: mac, madeAt: PF.t0)
        let later = early.recordingBirth(fingerprint: "2222222222222222", kind: .castle, madeBy: mac, madeAt: PF.day(1))
        #expect(FamilyTree.atOpen(record: early, memory: later).contains("2222222222222222"))
        var off = ProtectionGuards()
        off.familyTreeTwoHomes = false
        #expect(!FamilyTree.atOpen(record: early, memory: later, guards: off).contains("2222222222222222"),
                "red with the guard off: the later copy reads as foreign")
    }

    /// THE ANCHOR CARRIED BY EVERY RE-KEY: a Replace All Keys in Standard
    /// would strand every copy from before the leave.
    @Test func anchorCarriedByEveryRekey() throws {
        let world = try KeyWorld()
        let c = StoreKey.mint(), s1 = StoreKey.mint(), s2 = StoreKey.mint()
        let anchor = try CastleAnchor.sealing(
            outgoingKeyFile: try world.castleFile(c), outgoingKey: c,
            locks: .pressingDevice(passphrase: world.p, words: world.w), madeAt: PF.day(1), madeBy: nil)
        let standard = try world.castleFile(c).writingAnchor(anchor).rekeyed(
            .leavingCastle, from: c, to: s1, locks: NewKeyLocks(words: world.w), at: PF.day(1)).keyFile
        #expect(try standard.rekeyed(.withinMode, from: s1, to: s2, locks: NewKeyLocks(), at: PF.day(2))
            .keyFile.anchor == anchor)
        var off = ProtectionGuards()
        off.anchorCarriedByEveryRekey = false
        let broken = try standard.rekeyed(.withinMode, from: s1, to: s2, locks: NewKeyLocks(), at: PF.day(2), guards: off)
        #expect(broken.keyFile.anchor == nil, "red with the guard off: the anchor was dropped")
        #expect(!broken.keyFile.heldFingerprints.contains(PF.fp(c)), "red with the guard off: the Castle-era key is unreachable")
    }

    /// THE ANCHOR WRITTEN FIRST: a leave would build its new key file with no
    /// anchor at all — every copy from before the leave stranded.
    @Test func anchorWrittenFirst() throws {
        let world = try KeyWorld()
        let c = StoreKey.mint(), s = StoreKey.mint()
        let castle = try world.castleFile(c)
        #expect(throws: KeyFileError.anchorNotWrittenFirst) {
            _ = try castle.rekeyed(.leavingCastle, from: c, to: s, locks: NewKeyLocks(words: world.w), at: PF.day(1))
        }
        var off = ProtectionGuards()
        off.anchorWrittenFirst = false
        let broken = try castle.rekeyed(.leavingCastle, from: c, to: s, locks: NewKeyLocks(words: world.w),
                                        at: PF.day(1), guards: off)
        #expect(broken.keyFile.anchor == nil && broken.keyFile.history.isEmpty,
                "red with the guard off: nothing from before the leave is reachable")
    }
}
#endif
