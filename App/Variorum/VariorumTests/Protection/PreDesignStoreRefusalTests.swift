//
//  PreDesignStoreRefusalTests.swift
//  VariorumTests — a store from BEFORE this design (CastleRules rule 26): an encrypted library with an older Variorum's
//  key file beside it (`variorum-keys-<fp16>.json` / `variorum-keys.json`) and no format-3 key file. With today's
//  readers deleted (VX-329 U1 — "nothing is kept read-only") no road opens it. These pins hold what the shape meets,
//  over PLANTED leaves (no keychain) — never a crash, never a guess, never a byte of the old store read:
//    · VX-329 U4 (the plan's §6d, her ruling + her words at the 2026-10-22 morning sitting): the LIVE SLOT meets HER
//      PRE-DESIGN FACE (`ProtectionLobbyFace.preDesignStore`) — on a clean Mac AND on a Mac whose keychain remembers a
//      library of this design (the §8 addendum's shape: her real store's byte copy met the LOBBY's typed roads there, a
//      wedge). No silent item is read and no key is tried against the store; nothing is minted; the store and its older
//      key file are only read by name. The other two arms stand: with no key-file name at all, rule 27's refusal
//      (unchanged); a library of this design with today's names beside it (a Debug build's pre-switch stub) opens.
//      (VX-329 U1's piece 5 pinned the live slot at rule 27's refusal; U4 replaced that face with hers.)
//    · a PICKED copy of that shape (File ▸ Open Library…) is named as a library with a key file and refused as "This file
//      couldn't be read as a library." — never the no-key-file sentence; one with no key file at all keeps the honest
//      keyless refusal (U1 piece 5, unchanged).
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-329 U1 piece 5 + U4 — a store from before this design meets her face, never the lobby's roads (planted)")
@MainActor
struct PreDesignStoreRefusalTests {
    /// An older Variorum's key file's top-level shape (the classifier and the road read its NAME only).
    private func olderKeyFileBytes(_ key: StoreKey) -> Data {
        let recovery = Data((0..<40).map { _ in UInt8.random(in: 0...255) }).base64EncodedString()
        return Data("""
            {"formatVersion":2,"storeID":"\(UUID().uuidString.lowercased())",\
            "keyFingerprint":"\(KeyFingerprint.of(key))","recovery":"\(recovery)"}
            """.utf8)
    }

    /// A pre-design library in `folder`: a keyed store with no protection record, the older key file beside it.
    private func plantPreDesignLibrary(at store: URL) throws -> (olderKeyFile: URL, olderBytes: Data) {
        let key = StoreKey.mint()
        try FileManager.default.createDirectory(at: store.deletingLastPathComponent(), withIntermediateDirectories: true)
        let database = try AppDatabase.onDisk(url: store, key: key)
        _ = database.asRebindable().binding.lock()
        let older = store.deletingLastPathComponent()
            .appendingPathComponent("variorum-keys-\(KeyFingerprint.of(key)).json", isDirectory: false)
        let bytes = olderKeyFileBytes(key)
        try bytes.write(to: older)
        return (older, bytes)
    }

    /// The slot's folder, by name (sorted) — what a route that reads nothing leaves exactly as it found it.
    private func listing(_ road: PlantedRoad) throws -> [String] {
        try FileManager.default.contentsOfDirectory(atPath: road.slot.places.container.path).sorted()
    }

    @Test func theLiveSlotShowsHerPreDesignFaceAndTouchesNothing() async throws {
        let road = PlantedRoad()
        let planted = try plantPreDesignLibrary(at: road.slot.places.slot)
        let storeBefore = try Data(contentsOf: road.slot.places.slot)
        let before = try listing(road)

        guard case .lobby(let lobby) = await ProtectionOpenRoad.route(road.context()) else {
            Issue.record("a store from before this design meets the lobby's surface, never a crash or a guess")
            return
        }
        let face = ProtectionLobbyFace.derive(lobby)
        #expect(face.preDesignStore, "her pre-design face (the plan's §6d): \(face)")
        #expect(try Data(contentsOf: planted.olderKeyFile) == planted.olderBytes, "the older key file is only read")
        #expect(try Data(contentsOf: road.slot.places.slot) == storeBefore, "the store is only read")
        let after = try listing(road)
        #expect(after == before, "nothing beside the store was made or moved: \(after)")
        #expect(!FileManager.default.fileExists(atPath: road.slot.places.liveKeyFile.path), "nothing minted on a guess")
        #expect(road.custody.writes.isEmpty && road.memory.writes.isEmpty, "no keychain item written")
    }

    /// THE §8 ADDENDUM'S SHAPE: the byte copy in a slot on a Mac whose keychain REMEMBERS a library of this design — its
    /// memory item with a key-file copy, a silent item, a Touch ID item, biometry ready. On the pre-U4 tree the copy met
    /// the lobby's typed roads (the remembered copy made "something might still open it" true, so rule 27 stood down and
    /// no door appeared). Now: her face; no silent item read (no key tried against the old store); and the automatic
    /// Touch ID ask stands down — no prompt for a key that cannot open it.
    @Test func aMacThatRemembersALibraryOfThisDesignShowsHerFaceNeverTheLobbysRoads() async throws {
        let road = PlantedRoad()
        road.biometry = .ready
        _ = try plantPreDesignLibrary(at: road.slot.places.slot)
        let remembered = StoreKey.mint()
        let libraryID = UUID().uuidString.lowercased()
        let mirror = try KeyFile.building(
            libraryID: libraryID, key: remembered, epoch: 1,
            locks: NewKeyLocks(words: try WordsKey.derive(try RecoveryPhrase.generate())))
        road.memory.items[libraryID] = try DeviceMemory(
            libraryID: libraryID, currentFingerprint: mirror.fingerprint, deviceID: UUID().uuidString.lowercased(),
            keyFileMirror: mirror).sealed(under: remembered)
        road.custody.items[CustodyItemFact(fingerprint: mirror.fingerprint, itemClass: .silent, libraryID: libraryID)] =
            remembered
        road.custody.items[CustodyItemFact(fingerprint: mirror.fingerprint, itemClass: .touchid, libraryID: libraryID)] =
            remembered

        guard case .lobby(let lobby) = await ProtectionOpenRoad.route(road.context()) else {
            Issue.record("the lobby's surface")
            return
        }
        #expect(road.custody.reads.isEmpty, "no keychain item read — no key tried against the old store: \(road.custody.reads)")
        let face = ProtectionLobbyFace.derive(lobby)
        #expect(face.preDesignStore, "her face, whatever this Mac remembers: \(face)")

        #expect(face.touchIDButton && face.autoAsk, "the road fields keep their derivation (the phone's, until VM-8)")
        let roads = PlantedRoads()
        let model = roads.model(lobby)
        await model.autoAskIfDue(appIsActive: true)
        #expect(roads.presses == 0, "no Touch ID prompt is raised over a store no key here opens")
    }

    /// The keyless arm, unchanged: a store with NO key-file name beside it keeps rule 27's refusal (never her face).
    @Test func aStoreWithNoKeyFileNameAtAllKeepsRule27() async throws {
        let road = PlantedRoad()
        let planted = try plantPreDesignLibrary(at: road.slot.places.slot)
        try FileManager.default.removeItem(at: planted.olderKeyFile)
        guard case .lobby(let lobby) = await ProtectionOpenRoad.route(road.context()) else {
            Issue.record("the lobby's surface")
            return
        }
        let face = ProtectionLobbyFace.derive(lobby)
        #expect(!face.preDesignStore, "no older name, no pre-design face")
        #expect(face.noKeyFileAnywhere == NoKeyFileAnywhere(accountRoad: false), "rule 27's refusal: \(face)")
        #expect(!face.passphraseField && face.wordsRoad == .none && !face.touchIDButton,
                "no typed or Touch ID road is offered that could not open it")
        #expect(ProtectionWords.noKeyFileAnywhere.hasPrefix("No key file opens this library."),
                "the sentence the face says (§7c (3)) — never a claim that no key file exists")
    }

    /// The format-3 arm, unchanged: a library of THIS design with today's names beside it (a Debug build's pre-switch
    /// stub envelope stood beside every new-road library until VX-329 U1) is no pre-design store — its own road opens it.
    @Test func aLibraryOfThisDesignWithTodaysNamesBesideItStillOpens() async throws {
        let road = PlantedRoad()
        let (created, _) = try await road.created()
        let stub = road.slot.places.container
            .appendingPathComponent("variorum-keys-\(KeyFingerprint.of(created.key)).json", isDirectory: false)
        try olderKeyFileBytes(created.key).write(to: stub)
        try Data("{}".utf8).write(to: road.slot.places.container.appendingPathComponent("variorum-keys.json"))
        guard case .opened(let session) = await ProtectionOpenRoad.route(road.context()) else {
            Issue.record("the format-3 slot keeps its road")
            return
        }
        #expect(session.key == created.key)
    }

    @Test func aPickedPreDesignCopyIsNamedNeverCalledKeyless() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("vx329-u1-predesign-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let withKeyFile = root.appendingPathComponent("from-the-old-build", isDirectory: true)
        _ = try plantPreDesignLibrary(at: withKeyFile.appendingPathComponent("variorum.sqlite"))
        #expect(PickedCopy.classify(withKeyFile) == .refused(ProtectionWords.pickedCopyUnreadable, detail: nil),
                "named as a library with a key file this build can't read")
        #expect(PickedCopy.classify(withKeyFile.appendingPathComponent("variorum.sqlite"))
            == .refused(ProtectionWords.pickedCopyUnreadable, detail: nil), "the store itself, picked")

        let bare = root.appendingPathComponent("no-key-file", isDirectory: true)
        let planted = try plantPreDesignLibrary(at: bare.appendingPathComponent("variorum.sqlite"))
        try FileManager.default.removeItem(at: planted.olderKeyFile)
        #expect(PickedCopy.classify(bare) == .refused(LibraryOpenCopy.bareStoreRefusal, detail: nil),
                "with no key file at all, the keyless refusal is the honest one")
    }
}
