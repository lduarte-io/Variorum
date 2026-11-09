//
//  StaleEnvelopeSweepRoadTests.swift
//  VariorumTests — VX-443 (the VX-849 run, batch 4; PROVISIONAL P-849-4): THE STORE-ID ENVELOPE beside the slot, swept at
//  the open — on the new road over PLANTED leaves (no keychain) and a temp slot with the REAL file leaves, so every fence
//  meets real folders. A Debug build's pre-switch open (`AppBootstrap.ensureStoreIdentity`, VX-306 U1b → VX-329) left
//  `variorum-keys-<fp16>.json` beside every new-road library (the open's key's fingerprint, the store id, no wraps); its
//  name is the pre-design detector's, so a library that then loses THIS design's key file shows her "older version" face
//  instead of the lobby that writes the key file back (rule 1). The open's repairs delete it BY NAME — never reading it —
//  when its fingerprint is one the live key file holds (rule 4: nothing openable is lost).
//
//  RED ON OLD (committed on the pre-fix tree — they name only pre-fix API): `theEnvelopeBesideAReopenedLibraryIsGone` (the
//  stub survives the open) and `aLostKeyFileAfterTheSweepOpensThroughTheMirrorNeverThePreDesignFace` (the route lands in
//  the lobby with her pre-design face). GREEN ON BOTH SIDES (the fences — the false-positive class): every other pin here.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-443 — the store-id envelope beside the slot, swept at the open (the new road, planted, real folders)")
@MainActor
struct StaleEnvelopeSweepRoadTests {
    /// The name `ensureStoreIdentity` wrote beside the slot.
    static func envelopeName(_ fingerprint: String) -> String { "variorum-keys-\(fingerprint).json" }

    /// The stub's own shape (`StoreIdentity.establish`: the format, the store id, the key's fingerprint — no wraps). The
    /// road never reads it; the bytes are only so the file is what it was.
    static func plant(_ url: URL, fingerprint: String) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data(#"{"formatVersion":2,"keyFingerprint":"\#(fingerprint)","storeID":"\#(UUID().uuidString.lowercased())"}"#.utf8)
            .write(to: url)
    }

    static func exists(_ url: URL) -> Bool { FileManager.default.fileExists(atPath: url.path) }

    /// THE PIN (red on the pre-fix tree): the stub of the library's own key beside the slot is gone after the next open —
    /// the library open, this design's key file byte-for-byte as it was.
    @Test func theEnvelopeBesideAReopenedLibraryIsGone() async throws {
        let road = PlantedRoad()
        let (created, _) = try await road.created()
        let stub = road.slot.url(Self.envelopeName(created.library.fingerprint))
        try Self.plant(stub, fingerprint: created.library.fingerprint)
        let keyFileBefore = try Data(contentsOf: road.slot.places.liveKeyFile)
        guard case .opened(let session) = await ProtectionOpenRoad.route(road.context()) else {
            Issue.record("the silent item opens it at once")
            return
        }
        #expect(session.key == created.key)
        #expect(!Self.exists(stub), "the store-id envelope beside the slot survived the open")
        #expect(try Data(contentsOf: road.slot.places.liveKeyFile) == keyFileBefore, "this design's key file untouched")
    }

    /// WHY IT MATTERS (red on the pre-fix tree): after the sweep, the live key file lost while the app is closed is rule
    /// 1's to heal — the silent item opens the library and the sealed mirror is written back. With the stub still beside
    /// the slot, the same loss read as a store from before this design: her pre-design face, no road tried.
    @Test func aLostKeyFileAfterTheSweepOpensThroughTheMirrorNeverThePreDesignFace() async throws {
        let road = PlantedRoad()
        let (created, _) = try await road.created()
        try Self.plant(road.slot.url(Self.envelopeName(created.library.fingerprint)), fingerprint: created.library.fingerprint)
        guard case .opened = await ProtectionOpenRoad.route(road.context()) else {
            Issue.record("the first reopen opens it")
            return
        }
        try FileManager.default.removeItem(at: road.slot.places.liveKeyFile)
        switch await ProtectionOpenRoad.route(road.context()) {
        case .opened(let session):
            #expect(session.key == created.key)
            #expect(session.report.repairsDone.contains(.restoreKeyFileFromMirror))
            #expect(Self.exists(road.slot.places.liveKeyFile), "rule 1: the key file is written back beside the library")
        case .lobby(let lobby):
            Issue.record("the lost key file met the lobby — pre-design face \(ProtectionLobbyFace.derive(lobby).preDesignStore)")
        default:
            Issue.record("the silent item opens it and the mirror is written back")
        }
    }

    // MARK: - The fences (green on both sides)

    /// THE LIVE SLOT ONLY: the same name in Previous Libraries, in this Mac's backup folder, in the picked far folder and in
    /// a folder outside the app's places (a picked copy's) stays — and beside the slot, an older name whose key this
    /// library never had, the fixed legacy name, an older set-aside and a near miss stay too.
    @Test func everyNameTheSweepDoesNotOwnStays() async throws {
        let road = PlantedRoad(farFolder: true)
        let (created, _) = try await road.created()
        let fingerprint = created.library.fingerprint
        let name = Self.envelopeName(fingerprint)
        let libraryID = try #require(created.library.record?.libraryID)
        let picked = FileManager.default.temporaryDirectory
            .appendingPathComponent("vx443-picked-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: picked) }
        let elsewhere = [
            road.slot.url("Previous Libraries/2026-01-02-030405/\(name)"),
            road.slot.url(ProtectionNames.backupsSubpath(libraryID: libraryID, deviceID: created.library.section.deviceID)
                + "/\(name)"),
            road.slot.far.appendingPathComponent(name),
            road.slot.far.appendingPathComponent("Variorum/Backups/\(name)"),
            picked.appendingPathComponent(name),
        ]
        let beside = [
            road.slot.url(Self.envelopeName(KeyFingerprint.of(StoreKey.mint()))),
            road.slot.url("variorum-keys.json"),
            road.slot.url("variorum-keys-\(fingerprint).stale-1791000000.json"),
            road.slot.url("variorum-keys-\(fingerprint.prefix(8)).json"),
            road.slot.url("variorum-keys-\(fingerprint).json.bak"),
        ]
        for url in elsewhere + beside { try Self.plant(url, fingerprint: fingerprint) }
        guard case .opened = await ProtectionOpenRoad.route(road.context()) else {
            Issue.record("the silent item opens it at once")
            return
        }
        for url in elsewhere + beside { #expect(Self.exists(url), "\(url.path) was touched") }
    }

    /// THE READ-ONLY ROAD (a hosted test run — `writes == false`) sweeps nothing: it repairs nothing at all.
    @Test func theReadOnlyRoadSweepsNothing() async throws {
        let road = PlantedRoad()
        let (created, _) = try await road.created()
        let stub = road.slot.url(Self.envelopeName(created.library.fingerprint))
        try Self.plant(stub, fingerprint: created.library.fingerprint)
        guard case .opened = await ProtectionOpenRoad.route(road.context(writes: false)) else {
            Issue.record("the read-only road opens the library")
            return
        }
        #expect(Self.exists(stub))
    }

    /// A STORE FROM BEFORE THIS DESIGN IS NEVER REACHED: with no key file of this design beside the store, the older name
    /// is the detector's — her face, no road tried, nothing swept (the detector byte-unchanged).
    @Test func withNoKeyFileOfThisDesignThePreDesignFaceStandsAndNothingIsSwept() async throws {
        let road = PlantedRoad()
        let (created, _) = try await road.created()
        let stub = road.slot.url(Self.envelopeName(created.library.fingerprint))
        try FileManager.default.removeItem(at: road.slot.places.liveKeyFile)
        try Self.plant(stub, fingerprint: created.library.fingerprint)
        guard case .lobby(let lobby) = await ProtectionOpenRoad.route(road.context()) else {
            Issue.record("the pre-design face")
            return
        }
        #expect(ProtectionLobbyFace.derive(lobby).preDesignStore)
        #expect(Self.exists(stub))
    }
}
