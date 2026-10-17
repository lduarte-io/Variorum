//
//  RecordModelTests.swift
//  VariorumCoreTests — VX-305 U1 (the model): the protection record, this
//  Mac's section and its plain device ID (rule 23), what this Mac remembers
//  (rule 21's four things), and plans (design §3.2, §3.4, §3.6). (The family
//  tree, the two homes, the hardware marker and the takeover left with VX-378
//  U1.)
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-305 U1 — the values round-trip")
struct ProtectionValueRoundTripTests {
    @Test func everyValueRoundTrips() throws {
        let key = StoreKey.mint()
        let library = PF.id()
        let device = PF.id()
        var section = DeviceSection(
            deviceID: device, settings: DeviceSettings(gateStyle: .touchID, idleLockMinutes: 30, scheduledExport: true))
        section = section.recordingAppleKey(AppleKeyRecord(id: PF.id()))
        section = section.recordingAppleKey(
            AppleKeyRecord(id: PF.id(), retiredAt: PF.day(1)))
        section = section.beginningAct(.enterCastle, from: PF.fp(key), to: nil, fromKind: .standard, at: PF.day(2)).section
        let record = try ProtectionRecord.minting(
            libraryID: library, mode: .standard, account: PF.id(), currentFingerprint: PF.fp(key), at: PF.t0)
            .storing(section, sealedUnder: key)
        let memory = DeviceMemory(
            libraryID: library, currentFingerprint: PF.fp(key), deviceID: device,
            keyFileMirror: KeyFile(libraryID: library, key: key, epoch: 1), biometryStateHash: Data([9, 9]))
        let plan = ProtectionPlan(
            libraryID: library, deviceID: device, sequence: 1, act: .enterCastle,
            fromFingerprint: PF.fp(key), steps: [PlanStep(name: "custody", done: true), PlanStep(name: "swap")],
            createdAt: PF.day(2))

        func roundTrip<T: Codable & Equatable>(_ value: T) throws {
            let data = try ProtectionCoding.canonical(value)
            #expect(try ProtectionCoding.decoder().decode(T.self, from: data) == value)
        }
        try roundTrip(record)
        try roundTrip(section)
        try roundTrip(memory)
        try roundTrip(plan)
        try roundTrip(try memory.sealed(under: key))
        try roundTrip(try plan.sealed(under: key))
        #expect(record.verifiedSections(reach: PF.reach([key])) == [section])
        #expect(DeviceMemory.opening(try memory.sealed(under: key), libraryID: library, reach: PF.reach([key])) == memory)
    }
}

@Suite("VX-305 U1 — this Mac's section at open: the plain device ID it remembers (rule 23)")
struct DeviceFactsTests {
    private func section(_ id: String, version: Int, gate: GateStyle = .touchID) -> DeviceSection {
        DeviceSection(deviceID: id, version: version, settings: DeviceSettings(gateStyle: gate))
    }

    private func memory(_ deviceID: String) -> DeviceMemory {
        DeviceMemory(libraryID: PF.id(), currentFingerprint: "abababababababab", deviceID: deviceID)
    }

    /// The record's section for the remembered device ID — the newest of it;
    /// none in the record: a fresh section under that same ID; nothing
    /// remembered: a NEW plain random ID with a fresh section, no choice yet,
    /// adopting nothing (PROVISIONAL — the VX-378 heading in QUESTIONS).
    @Test func theRememberedDeviceIDNamesThisMacsSection() {
        let id = PF.id(), other = PF.id()
        let mine = section(id, version: 3), older = section(id, version: 2), theirs = section(other, version: 9)
        var minted = 0
        func mint() -> String { minted += 1; return "minted-\(minted)" }
        #expect(DeviceFacts.thisMacsSection(memory: memory(id), recordSections: [older, theirs, mine], mintDeviceID: mint)
            == mine)
        let fresh = DeviceFacts.thisMacsSection(memory: memory(id), recordSections: [theirs], mintDeviceID: mint)
        #expect(fresh.deviceID == id && fresh.settings == .noChoiceYet && fresh.appleKeys.isEmpty)
        #expect(minted == 0, "a remembered ID is never re-minted")
        let new = DeviceFacts.thisMacsSection(memory: nil, recordSections: [theirs, mine], mintDeviceID: mint)
        #expect(new.deviceID == "minted-1" && new.settings == .noChoiceYet && new.appleKeys.isEmpty,
                "with nothing remembered, no section of the record is guessed")
    }

    @Test func actsAreSequencedAndVersionsOnlyGrow() {
        let start = section(PF.id(), version: 1)
        let (one, first) = start.beginningAct(.enterCastle, from: "a", to: "b", at: PF.t0)
        #expect(first == 1)
        #expect(one.actInFlight?.sequence == 1)
        #expect(one.endingAct(sequence: 2) == one, "a stale end changes nothing")
        let ended = one.endingAct(sequence: 1)
        #expect(ended.actInFlight == nil)
        let (_, second) = ended.beginningAct(.leaveCastle, from: "b", to: "c", at: PF.day(1))
        #expect(second == 2, "a sequence is never reused")
        #expect(ended.version > one.version && one.version > start.version)
        // A retired id is never un-retired by a later record of it.
        let retired = start.retiringAppleKey(id: "k", at: PF.day(1))
            .recordingAppleKey(AppleKeyRecord(id: "k"))
        #expect(retired.retiredAppleKeyIDs == ["k"])
    }
}

@Suite("VX-305 U1 — the record's sealed sections, the memory's seal, plans named by the act")
struct SealedHomesAndPlansTests {
    @Test func storingReplacesThatDevicesSectionOnly() throws {
        let key = StoreKey.mint()
        let a = DeviceSection(deviceID: PF.id(), settings: .noChoiceYet)
        let b = DeviceSection(deviceID: PF.id(), settings: .noChoiceYet)
        var record = ProtectionRecord.minting(
            libraryID: PF.id(), mode: .castle, account: nil, currentFingerprint: PF.fp(key), at: PF.t0)
        record = try record.storing(a, sealedUnder: key).storing(b, sealedUnder: key)
        let alwaysAsk = DeviceSettings(gateStyle: .alwaysAsk)
        record = try record.storing(a.withSettings(alwaysAsk), sealedUnder: key)
        let sections = record.verifiedSections(reach: PF.reach([key]))
        #expect(sections.count == 2)
        #expect(sections.first { $0.deviceID == a.deviceID }?.settings == alwaysAsk)
    }

    /// A tampered memory item fails its seal and loses (nil); one for another
    /// library is not this one's.
    @Test func aTamperedMemoryItemIsNotThisMacsMemory() throws {
        let key = StoreKey.mint()
        let library = PF.id()
        let memory = DeviceMemory(libraryID: library, currentFingerprint: PF.fp(key), deviceID: PF.id())
        let sealed = try memory.sealed(under: key)
        var edited = memory
        edited.deviceID = PF.id()
        let forged = Sealed<DeviceMemory>(payload: try ProtectionCoding.canonical(edited), seal: sealed.seal)
        #expect(DeviceMemory.opening(forged, libraryID: library, reach: PF.reach([key])) == nil)
        #expect(DeviceMemory.opening(sealed, libraryID: PF.id(), reach: PF.reach([key])) == nil)
        #expect(DeviceMemory.opening(sealed, libraryID: library, reach: PF.reach([key])) == memory)
    }

    /// A plan resumes only when its seal verifies and this Mac's section names
    /// it; a planted plan, a replayed one, and another device's are ignored.
    @Test func aPlanResumesOnlyWhenTheSectionNamesIt() throws {
        let key = StoreKey.mint(), newer = StoreKey.mint()
        let library = PF.id()
        let base = DeviceSection(deviceID: PF.id(), settings: .noChoiceYet)
        let (firstAct, s1) = base.beginningAct(.enterCastle, from: PF.fp(key), to: nil, at: PF.t0)
        let plan1 = ProtectionPlan(
            libraryID: library, deviceID: base.deviceID, sequence: s1, act: .enterCastle,
            fromFingerprint: PF.fp(key), steps: [PlanStep(name: "one")], createdAt: PF.t0)
        let sealed1 = try plan1.sealed(under: key)
        #expect(ProtectionPlan.resumable(sealed1, libraryID: library, section: firstAct, reach: PF.reach([key]))
            == .success(plan1))
        // After a re-key, the plan sealed under the old key opens through the history.
        #expect(ProtectionPlan.resumable(sealed1, libraryID: library, section: firstAct, reach: PF.reach([newer, key]))
            == .success(plan1))
        // The act ended and a second began: plan 1 replayed is not named.
        let (secondAct, _) = firstAct.endingAct(sequence: s1).beginningAct(.enterCastle, from: PF.fp(key), to: nil, at: PF.day(1))
        #expect(ProtectionPlan.resumable(sealed1, libraryID: library, section: secondAct, reach: PF.reach([key]))
            == .failure(.notNamed))
        // No act in flight: nothing is named.
        #expect(ProtectionPlan.resumable(sealed1, libraryID: library, section: base, reach: PF.reach([key]))
            == .failure(.notNamed))
        // A planted plan (sealed under a key no road reaches).
        let planted = try plan1.sealed(under: StoreKey.mint())
        #expect(ProtectionPlan.resumable(planted, libraryID: library, section: firstAct, reach: PF.reach([key]))
            == .failure(.unsealed))
        // Another device's plan for the same sequence.
        var foreign = plan1
        foreign.deviceID = PF.id()
        #expect(ProtectionPlan.resumable(try foreign.sealed(under: key), libraryID: library, section: firstAct,
                                         reach: PF.reach([key])) == .failure(.notNamed))
        #expect(plan1.firstUnfinishedStep == 0)
    }
}
