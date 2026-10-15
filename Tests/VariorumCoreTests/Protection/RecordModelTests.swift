//
//  RecordModelTests.swift
//  VariorumCoreTests — VX-305 U1 (the model): the protection record, the
//  family tree, this Mac's facts in two sealed homes, the hardware marker
//  (VX-340), what this Mac remembers, and plans (design §3.2, §3.4, §3.6,
//  §3.13).
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
            deviceID: device, hardwareMarker: HardwareMarker.compute(PF.macA, salt: HardwareMarker.mintSalt()),
            settings: DeviceSettings(gateStyle: .touchID, idleLockMinutes: 30, scheduledExport: true),
            oldSharedKey: OldSharedKeyRecord(id: PF.id()))
        section = section.recordingAppleKey(AppleKeyRecord(id: PF.id(), purpose: .library, origin: .minted))
        section = section.recordingAppleKey(
            AppleKeyRecord(id: PF.id(), purpose: .account, accountID: PF.id(), origin: .followed, retiredAt: PF.day(1)))
        section = section.beginningAct(.enterCastle, from: PF.fp(key), to: nil, at: PF.day(2)).section
        let record = try ProtectionRecord.minting(
            libraryID: library, mode: .standard, modeConfirmed: true, account: PF.id(),
            currentFingerprint: PF.fp(key), madeBy: device, at: PF.t0)
            .storing(section, sealedUnder: key)
        let memory = DeviceMemory(
            libraryID: library, scope: "Variorum-dev", currentFingerprint: PF.fp(key), keyEpoch: 1,
            lastConfirmed: ConfirmedFacts(mode: .standard, account: nil),
            biometryStateHash: Data([9, 9]), vaultFacts: VaultFacts(kdf: PF.fastKDF(), corpusKeyID: PF.id()),
            nudgeDismissals: ["exposed": PF.day(3)], keyFileMirror: KeyFile(libraryID: library, key: key, epoch: 1),
            familyTree: record.familyTree, deviceSection: section)
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
        try roundTrip(record.familyTree)
        try roundTrip(try memory.sealed(under: key))
        try roundTrip(try plan.sealed(under: key))
        #expect(record.verifiedSections(reach: PF.reach([key])) == [section])
        #expect(DeviceMemory.opening(try memory.sealed(under: key), libraryID: library, reach: PF.reach([key])) == memory)
    }
}

@Suite("VX-305 U1 — the family tree: every key, its kind for life, two homes unioned")
struct FamilyTreeTests {
    /// Every key a re-key or a landing mints is recorded with its kind and its
    /// Mac; the old key is retired, the epoch advances, the mode is the new
    /// key's kind.
    @Test func everyMintedKeyIsRecordedWithItsKindAndItsMac() {
        let macA = PF.id(), macB = PF.id()
        var record = ProtectionRecord.minting(
            libraryID: PF.id(), mode: .standard, modeConfirmed: true, account: nil,
            currentFingerprint: "aaaaaaaaaaaaaaaa", madeBy: macA, at: PF.t0)
        record = record.recordingRekey(to: "bbbbbbbbbbbbbbbb", kind: .castle, by: macA, at: PF.day(1))
        // A landing on another Mac is recorded the same way, by that Mac.
        record = record.recordingRekey(to: "cccccccccccccccc", kind: .castle, by: macB, at: PF.day(2))
        let tree = record.familyTree
        #expect(tree.fingerprints == ["aaaaaaaaaaaaaaaa", "bbbbbbbbbbbbbbbb", "cccccccccccccccc"])
        #expect(tree.entry("aaaaaaaaaaaaaaaa")?.kind == .standard)
        #expect(tree.entry("aaaaaaaaaaaaaaaa")?.retiredAt == PF.day(1))
        #expect(tree.entry("bbbbbbbbbbbbbbbb")?.madeBy == macA)
        #expect(tree.entry("bbbbbbbbbbbbbbbb")?.retiredAt == PF.day(2))
        #expect(tree.entry("cccccccccccccccc")?.madeBy == macB)
        #expect(tree.entry("cccccccccccccccc")?.kind == .castle)
        #expect(tree.entry("cccccccccccccccc")?.retiredAt == nil)
        #expect(record.keyEpoch == 3)
        #expect(record.mode == .castle)
        #expect(record.currentFingerprint == "cccccccccccccccc")
    }

    /// The two homes union at open: a library file rolled back past a re-key
    /// (Time Machine) still knows its later key through the memory's mirror —
    /// this library's later copies read as its own. A tree only grows.
    @Test func theTwoHomesUnion_aRolledBackLibraryStillKnowsItsLaterKeys() {
        let mac = PF.id()
        let early = ProtectionRecord.minting(
            libraryID: PF.id(), mode: .standard, modeConfirmed: true, account: nil,
            currentFingerprint: "1111111111111111", madeBy: mac, at: PF.t0)
        let later = early.recordingRekey(to: "2222222222222222", kind: .castle, by: mac, at: PF.day(1))
        // The library file is rolled back to `early`; the memory kept `later`'s tree.
        let atOpen = FamilyTree.atOpen(record: early.familyTree, memory: later.familyTree)
        #expect(atOpen.contains("2222222222222222"))
        #expect(atOpen.entry("1111111111111111")?.retiredAt == PF.day(1))
        // Union laws.
        let a = early.familyTree, b = later.familyTree
        let c = FamilyTree().seeding(["3333333333333333"])
        #expect(a.union(b) == b.union(a))
        #expect(a.union(b).union(c) == a.union(b.union(c)))
        #expect(b.union(b) == b)
    }

    /// The migration seeds fingerprints a key file names that the fold
    /// couldn't reach: they count as this library's own, of Castle's kind
    /// (the safe side), marked unreached.
    @Test func itCanBeSeededWithUnreachedFingerprints() {
        let tree = FamilyTree().seeding(["dddddddddddddddd"])
        #expect(tree.contains("dddddddddddddddd"))
        #expect(tree.entry("dddddddddddddddd")?.reached == false)
        #expect(tree.entry("dddddddddddddddd")?.kind == .castle)
        // A home that later reaches it merges in.
        let reached = tree.union(FamilyTree(entries: [FamilyTree.Entry(fingerprint: "dddddddddddddddd", kind: .castle)]))
        #expect(reached.entry("dddddddddddddddd")?.reached == true)
    }

    /// PROVISIONAL (the U1 record): two homes disagreeing on a kind take
    /// Castle; the earliest dates win; a decoded tree is normalized.
    @Test func mergingTakesTheSafeSide() throws {
        let one = FamilyTree(entries: [.init(fingerprint: "eeeeeeeeeeeeeeee", kind: .standard, madeAt: PF.day(2))])
        let two = FamilyTree(entries: [.init(fingerprint: "eeeeeeeeeeeeeeee", kind: .castle, madeAt: PF.day(1), retiredAt: PF.day(5))])
        let merged = one.union(two)
        #expect(merged.entry("eeeeeeeeeeeeeeee")?.kind == .castle)
        #expect(merged.entry("eeeeeeeeeeeeeeee")?.madeAt == PF.day(1))
        #expect(merged.entry("eeeeeeeeeeeeeeee")?.retiredAt == PF.day(5))
        let messy = Data(#"{"entries":[{"fingerprint":"ffffffffffffffff","kind":"standard","reached":true},{"fingerprint":"aaaaaaaaaaaaaaaa","kind":"castle","reached":true},{"fingerprint":"ffffffffffffffff","kind":"castle","reached":false}]}"#.utf8)
        let decoded = try ProtectionCoding.decoder().decode(FamilyTree.self, from: messy)
        #expect(decoded.fingerprints == ["aaaaaaaaaaaaaaaa", "ffffffffffffffff"])
        #expect(decoded.entry("ffffffffffffffff")?.kind == .castle)
    }
}

@Suite("VX-305 U1 — the hardware marker covers the hardware AND the login (VX-340), in two salted parts")
struct HardwareMarkerTests {
    /// Her 2026-10-14/15 ruling: a hardware part and a login part, each its
    /// own salted hash — a second login keeps the hardware part and changes
    /// the login part; other hardware changes the hardware part.
    @Test func itRecomputesOnTheSameHardwareAndLoginOnly() {
        let salt = HardwareMarker.mintSalt()
        let marker = HardwareMarker.compute(PF.macA, salt: salt)
        #expect(marker == HardwareMarker.compute(PF.macA, salt: salt))
        #expect(marker.hardware.count == 64 && marker.login.count == 64)
        let secondLogin = HardwareMarker.compute(PF.macASecondLogin, salt: salt)
        #expect(secondLogin != marker, "a second login is another device")
        #expect(secondLogin.sameHardware(as: marker) && secondLogin.login != marker.login, "…on the same hardware")
        let otherHardware = HardwareMarker.compute(PF.macB, salt: salt)
        #expect(otherHardware != marker && !otherHardware.sameHardware(as: marker), "other hardware is another device")
        let fresh = HardwareMarker.compute(PF.macA, salt: HardwareMarker.mintSalt())
        #expect(fresh.hardware != marker.hardware && fresh.login != marker.login, "each part names no Mac without its salt")
        // The two parts never collide: the same text in both fields hashes
        // differently per part (one domain each).
        let same = HardwareMarker.compute(MachineIdentity(hardware: PF.macA.login, login: PF.macA.login), salt: salt)
        #expect(same.hardware != same.login)
        #expect(same.login == marker.login, "the login part hashes the login alone")
        // Moving characters between the fields changes both parts.
        let shifted = MachineIdentity(hardware: PF.macA.hardware + "x", login: String(PF.macA.login.dropFirst()))
        let moved = HardwareMarker.compute(shifted, salt: salt)
        #expect(moved.hardware != marker.hardware && moved.login != marker.login)
    }

    @Test func theMarkerCarriesNeitherIdentifier() throws {
        let record = ProtectionRecord.minting(
            libraryID: PF.id(), mode: .castle, modeConfirmed: true, account: nil,
            currentFingerprint: "abababababababab", madeBy: PF.id(), at: PF.t0)
        let marker = record.marker(for: PF.macA)
        let encoded = try ProtectionCoding.canonical(marker)
        for identifier in [PF.macA.hardware, PF.macA.login] {
            for part in [marker.hardware, marker.login] {
                #expect(!part.contains(identifier.lowercased()))
                #expect(!SecretScan.carries(Data(part.utf8), text: identifier))
            }
            #expect(!SecretScan.carries(encoded, text: identifier))
            // Each part alone is salted: no unsalted hash of either identifier.
            let unsalted = Data(SHA256.hash(data: Data(identifier.utf8)))
            #expect(!SecretScan.carries(encoded, unsalted))
        }
        #expect(!"\(PF.macA)".contains(PF.macA.hardware), "the identity's description is redacted")
    }
}

@Suite("VX-305 U1 — this Mac's facts in two sealed homes")
struct DeviceFactsTests {
    private func section(_ id: String, marker: HardwareMarker, version: Int, gate: GateStyle = .touchID) -> DeviceSection {
        DeviceSection(deviceID: id, hardwareMarker: marker, version: version, settings: DeviceSettings(gateStyle: gate))
    }

    private func memory(for section: DeviceSection, library: String = PF.id()) -> DeviceMemory {
        DeviceMemory(
            libraryID: library, scope: "Variorum", currentFingerprint: "abababababababab", keyEpoch: 1,
            familyTree: FamilyTree(), deviceSection: section)
    }

    /// The newer version wins, and the retired ids are the union.
    @Test func theNewerWinsAndTheRetiredIdsAreTheUnion() {
        let id = PF.id()
        let retiredOnlyInRecord = PF.id(), retiredOnlyInMemory = PF.id()
        var record = section(id, marker: .stub("m"), version: 4, gate: .alwaysAsk)
            .retiringAppleKey(id: retiredOnlyInRecord, purpose: .library, origin: .minted, at: PF.day(1))
        var memory = section(id, marker: .stub("m"), version: 9, gate: .touchID)
            .retiringAppleKey(id: retiredOnlyInMemory, purpose: .library, origin: .minted, at: PF.day(2))
        record.version = 4
        memory.version = 9
        let merged = DeviceFacts.reconcile(record: record, memory: memory)!
        #expect(merged.version == 9)
        #expect(merged.settings.gateStyle == .touchID)
        #expect(merged.retiredAppleKeyIDs == [retiredOnlyInRecord, retiredOnlyInMemory])
        // And the other way: the record newer.
        record.version = 12
        let other = DeviceFacts.reconcile(record: record, memory: memory)!
        #expect(other.settings.gateStyle == .alwaysAsk)
        #expect(other.retiredAppleKeyIDs == [retiredOnlyInRecord, retiredOnlyInMemory])
    }

    /// A library file replayed alone (an older record section) and a memory
    /// item replayed alone (an older memory) each change nothing — and a
    /// replay can never un-retire an id.
    @Test func aReplayOfEitherHomeAloneChangesNothing() {
        let id = PF.id()
        let retired = PF.id()
        let current = section(id, marker: .stub("m"), version: 7, gate: .alwaysAsk)
            .retiringAppleKey(id: retired, purpose: .library, origin: .minted, at: PF.day(3))
        var stale = section(id, marker: .stub("m"), version: 3, gate: .touchID)
            .recordingAppleKey(AppleKeyRecord(id: retired, purpose: .library, origin: .minted))
        stale.version = 3
        // The library file replayed alone.
        let a = DeviceFacts.reconcile(record: stale, memory: current)!
        // The memory item replayed alone.
        let b = DeviceFacts.reconcile(record: current, memory: stale)!
        for merged in [a, b] {
            #expect(merged.settings.gateStyle == .alwaysAsk)
            #expect(merged.retiredAppleKeyIDs == [retired])
        }
    }

    /// The memory item deleted (or failing its seal): the record's section
    /// alone — and a Mac with no memory item finds its section by its
    /// hardware marker, so nothing changes.
    @Test func aMacWithNoMemoryItemFindsItsSectionByItsMarker() {
        let salt = HardwareMarker.mintSalt()
        let mine = section(PF.id(), marker: HardwareMarker.compute(PF.macA, salt: salt), version: 5, gate: .alwaysAsk)
        let other = section(PF.id(), marker: HardwareMarker.compute(PF.macB, salt: salt), version: 9)
        let found = DeviceFacts.thisMacsSection(
            memory: nil, recordSections: [other, mine], marker: HardwareMarker.compute(PF.macA, salt: salt),
            keyFileOwnAppleKeyIDs: [], mintDeviceID: { Issue.record("no mint"); return PF.id() })
        #expect(found.resolution == .foundByMarker(deviceID: mine.deviceID))
        #expect(found.section == mine)
        #expect(DeviceFacts.reconcile(record: mine, memory: nil) == mine)
    }

    /// VX-340: a second macOS login on the same Mac never finds the first
    /// login's section — it starts its own identity: its own device id and
    /// `<mac8>`, never the first login's settings, its own keys' list or its
    /// retired ids. Her 2026-10-14/15 ruling SPLIT THE MARKER so this can be
    /// told from new hardware: a section carrying THIS hardware's part under
    /// another login's part — or such a memory item — is another login, and it
    /// adopts nothing, starting with no choice yet (P-U1-7). (Re-pointed from
    /// P-U4-3 option (a), which took over the live key file's wrap id and every
    /// retired id here too.)
    @Test func aSecondMacOSLoginStartsItsOwnIdentity() {
        let salt = HardwareMarker.mintSalt()
        let firstOwn = PF.id(), retired = PF.id(), wrapped = PF.id()
        let firstLogin = section(PF.id(), marker: HardwareMarker.compute(PF.macA, salt: salt), version: 4)
            .recordingAppleKey(AppleKeyRecord(id: firstOwn, purpose: .library, origin: .minted))
            .retiringAppleKey(id: retired, purpose: .library, origin: .minted, at: PF.day(1))
        let minted = PF.id()
        let here = HardwareMarker.compute(PF.macASecondLogin, salt: salt)
        let found = DeviceFacts.thisMacsSection(
            memory: nil, recordSections: [firstLogin], marker: here,
            keyFileOwnAppleKeyIDs: [wrapped], mintDeviceID: { minted })
        #expect(found.resolution == .anotherLogin)
        #expect(found.section.deviceID == minted)
        #expect(found.section.hardwareMarker == here)
        #expect(found.section.mac8 != firstLogin.mac8)
        #expect(found.section.appleKeys.isEmpty, "another login adopts nothing — no own keys, no retired ids")
        #expect(found.section.settings == .noChoiceYet)
        // The first login's memory item turning up in the second login's
        // keychain (same hardware, another login) adopts nothing either.
        let viaMemory = DeviceFacts.thisMacsSection(
            memory: memory(for: firstLogin), recordSections: [firstLogin], marker: here,
            keyFileOwnAppleKeyIDs: [wrapped], mintDeviceID: { minted })
        #expect(viaMemory.resolution == .anotherLogin && viaMemory.section.appleKeys.isEmpty)
        // With no record sections at all (nothing knows the library yet), nothing is taken over.
        let bare = DeviceFacts.thisMacsSection(
            memory: nil, recordSections: [], marker: here, keyFileOwnAppleKeyIDs: [wrapped], mintDeviceID: { minted })
        #expect(bare.section.appleKeys.isEmpty && bare.section.settings == .noChoiceYet)
    }

    /// New hardware whose memory item stayed behind (Migration Assistant
    /// doesn't carry Local Items), opening a library the record knows — no
    /// section is this hardware's, and none carries this login's part, so it
    /// is a REPLACEMENT with no predecessor to name: it takes over what §3.5
    /// needs no predecessor for — the Apple key its live key file's wrap
    /// names, and every retired id any section lists — starting on Always ask
    /// (P-U4-3 as the split simplified it).
    @Test func newHardwareWithNoMemoryItemTakesOverWhatNeedsNoPredecessor() {
        let salt = HardwareMarker.mintSalt()
        let otherOwn = PF.id(), retired = PF.id(), wrapped = PF.id()
        let elsewhere = section(PF.id(), marker: HardwareMarker.compute(PF.macA, salt: salt), version: 4)
            .recordingAppleKey(AppleKeyRecord(id: otherOwn, purpose: .library, origin: .minted))
            .retiringAppleKey(id: retired, purpose: .library, origin: .minted, at: PF.day(1))
        let minted = PF.id()
        let newLogin = MachineIdentity(hardware: PF.macB.hardware, login: "55555555-EEEE-4EEE-8EEE-EEEEEEEEEEEE")
        let found = DeviceFacts.thisMacsSection(
            memory: nil, recordSections: [elsewhere], marker: HardwareMarker.compute(newLogin, salt: salt),
            keyFileOwnAppleKeyIDs: [wrapped], mintDeviceID: { minted })
        #expect(found.resolution == .newIdentity(predecessorID: nil))
        #expect(found.section.deviceID == minted)
        #expect(!found.section.appleKeys.contains { $0.id == otherOwn }, "no predecessor is named: never another section's own list")
        #expect(Set(found.section.appleKeys.map(\.id)) == [wrapped, retired])
        #expect(found.section.retiredAppleKeyIDs == [retired])
        #expect(found.section.settings == .newIdentity)
    }

    /// PROVISIONAL P-U4-14 (the closer's soak, seed 11): new hardware with
    /// no memory item, under THIS login's part (the user record carried over
    /// by Migration Assistant) — the section on other hardware under the same
    /// login part is its previous Mac: named the predecessor, its own keys
    /// taken over. (A second login on the same hardware still adopts nothing.)
    @Test func newHardwareUnderThisLoginNamesItsPredecessor() {
        let salt = HardwareMarker.mintSalt()
        let own = PF.id(), retired = PF.id()
        let previous = section(PF.id(), marker: HardwareMarker.compute(PF.macA, salt: salt), version: 4)
            .recordingAppleKey(AppleKeyRecord(id: own, purpose: .library, origin: .minted))
            .retiringAppleKey(id: retired, purpose: .library, origin: .minted, at: PF.day(1))
        let minted = PF.id()
        let found = DeviceFacts.thisMacsSection(
            memory: nil, recordSections: [previous], marker: HardwareMarker.compute(PF.macB, salt: salt),
            keyFileOwnAppleKeyIDs: [], mintDeviceID: { minted })
        #expect(found.resolution == .newIdentity(predecessorID: previous.deviceID))
        #expect(Set(found.section.ownLibraryAppleKeyIDsToRetire) == [own])
        #expect(found.section.retiredAppleKeyIDs == [retired])
        #expect(found.section.settings == .newIdentity)
    }

    /// A memory item that turns up on new hardware: a new identity, taking
    /// over its predecessor's own Apple keys, the key file's own wrap id, and
    /// every retired id any section lists — starting on Always ask.
    @Test func aMemoryItemOnNewHardwareMintsANewIdentityThatTakesOver() {
        let salt = HardwareMarker.mintSalt()
        let ownKept = PF.id(), ownRetired = PF.id(), followed = PF.id(), retiredElsewhere = PF.id(), wrapID = PF.id()
        let predecessor = section(PF.id(), marker: HardwareMarker.compute(PF.macA, salt: salt), version: 6)
            .recordingAppleKey(AppleKeyRecord(id: ownKept, purpose: .library, origin: .minted))
            .retiringAppleKey(id: ownRetired, purpose: .library, origin: .minted, at: PF.day(1))
            .recordingAppleKey(AppleKeyRecord(id: followed, purpose: .account, accountID: PF.id(), origin: .followed))
        let elsewhere = section(PF.id(), marker: .stub("someone-else"), version: 2)
            .retiringAppleKey(id: retiredElsewhere, purpose: .account, accountID: PF.id(), origin: .followed, at: PF.day(2))
        let minted = PF.id()
        let found = DeviceFacts.thisMacsSection(
            memory: memory(for: predecessor), recordSections: [predecessor, elsewhere],
            marker: HardwareMarker.compute(PF.macB, salt: salt),
            keyFileOwnAppleKeyIDs: [wrapID], mintDeviceID: { minted })
        #expect(found.resolution == .newIdentity(predecessorID: predecessor.deviceID))
        let taken = found.section
        #expect(taken.deviceID == minted)
        #expect(taken.hardwareMarker == HardwareMarker.compute(PF.macB, salt: salt))
        #expect(taken.settings.gateStyle == .alwaysAsk, "a new device identity starts on Always ask")
        #expect(Set(taken.ownLibraryAppleKeyIDsToRetire) == [ownKept, wrapID])
        #expect(taken.retiredAppleKeyIDs == [ownRetired, retiredElsewhere])
        #expect(!taken.appleKeys.contains { $0.id == followed }, "the account's followed key is not its own")
    }

    /// The memory continues on its own hardware and login; a memory item from
    /// elsewhere yields to this Mac's own marked section (PROVISIONAL order).
    @Test func theMemoryContinuesWhereItWasMade() {
        let salt = HardwareMarker.mintSalt()
        let here = HardwareMarker.compute(PF.macA, salt: salt)
        let mine = section(PF.id(), marker: here, version: 3)
        let continuing = DeviceFacts.resolveIdentity(memory: memory(for: mine), sections: [mine], marker: here)
        #expect(continuing == .continuing(deviceID: mine.deviceID))
        let foreign = section(PF.id(), marker: HardwareMarker.compute(PF.macB, salt: salt), version: 8)
        #expect(DeviceFacts.resolveIdentity(memory: memory(for: foreign), sections: [foreign, mine], marker: here)
            == .foundByMarker(deviceID: mine.deviceID))
    }

    @Test func actsAreSequencedAndVersionsOnlyGrow() {
        let start = section(PF.id(), marker: .stub("m"), version: 1)
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
        let retired = start.retiringAppleKey(id: "k", purpose: .library, origin: .minted, at: PF.day(1))
            .recordingAppleKey(AppleKeyRecord(id: "k", purpose: .library, origin: .minted))
        #expect(retired.retiredAppleKeyIDs == ["k"])
    }
}

@Suite("VX-305 U1 — the record's sealed sections, the memory's seal, plans named by the act")
struct SealedHomesAndPlansTests {
    @Test func aCopysActsInFlightAreClearedWhenItIsOpened() throws {
        let sent = StoreKey.mint(), landed = StoreKey.mint()
        let library = PF.id()
        let busy = DeviceSection(deviceID: PF.id(), hardwareMarker: .stub("m"), settings: .noChoiceYet)
            .beginningAct(.replaceAllKeys, from: "a", to: "b", at: PF.t0).section
        var record = try ProtectionRecord.minting(
            libraryID: library, mode: .castle, modeConfirmed: true, account: nil,
            currentFingerprint: PF.fp(sent), madeBy: busy.deviceID, at: PF.t0)
            .storing(busy, sealedUnder: sent)
        // A planted section no reachable key verifies.
        let planted = try Sealed.sealing(
            DeviceSection(deviceID: PF.id(), hardwareMarker: .stub("x"), settings: .noChoiceYet)
                .beginningAct(.enterCastle, from: nil, to: nil, at: PF.t0).section,
            purpose: .deviceSection, libraryID: library, key: StoreKey.mint())
        record.deviceSections.append(planted)
        let opened = try record.clearingActsInFlight(reach: PF.reach([sent]), resealUnder: landed)
        let sections = opened.verifiedSections(reach: PF.reach([landed]))
        #expect(sections.count == 1)
        #expect(sections.allSatisfy { $0.actInFlight == nil })
    }

    @Test func storingReplacesThatDevicesSectionOnly() throws {
        let key = StoreKey.mint()
        let a = DeviceSection(deviceID: PF.id(), hardwareMarker: .stub("a"), settings: .noChoiceYet)
        let b = DeviceSection(deviceID: PF.id(), hardwareMarker: .stub("b"), settings: .noChoiceYet)
        var record = ProtectionRecord.minting(
            libraryID: PF.id(), mode: .castle, modeConfirmed: true, account: nil,
            currentFingerprint: PF.fp(key), madeBy: a.deviceID, at: PF.t0)
        record = try record.storing(a, sealedUnder: key).storing(b, sealedUnder: key)
        record = try record.storing(a.withSettings(.newIdentity), sealedUnder: key)
        let sections = record.verifiedSections(reach: PF.reach([key]))
        #expect(sections.count == 2)
        #expect(sections.first { $0.deviceID == a.deviceID }?.settings == .newIdentity)
    }

    /// A tampered memory item fails its seal and loses (nil); one for another
    /// library is not this one's.
    @Test func aTamperedMemoryItemIsNotThisMacsMemory() throws {
        let key = StoreKey.mint()
        let library = PF.id()
        let memory = DeviceMemory(
            libraryID: library, scope: "Variorum", currentFingerprint: PF.fp(key), keyEpoch: 1,
            familyTree: FamilyTree(),
            deviceSection: DeviceSection(deviceID: PF.id(), hardwareMarker: .stub("m"), settings: DeviceSettings(gateStyle: .alwaysAsk)))
        let sealed = try memory.sealed(under: key)
        var edited = memory
        edited.deviceSection.settings.gateStyle = .touchID
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
        let base = DeviceSection(deviceID: PF.id(), hardwareMarker: .stub("m"), settings: .noChoiceYet)
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
