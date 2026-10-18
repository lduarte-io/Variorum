//
//  ProtectionRule27FaceTests.swift
//  VariorumTests — VX-306 U2 piece 4: RULE 27 from planted facts — before unlock (everything gone) the lobby's face, the account
//  sentence with a sign-in, and *Start a New Library* setting the unopenable library aside WHOLE; after a quiet-road
//  open, the standing banner (no doors, nothing rebuilt).
//  (`notes/plans/vx-306-castle-open-road.md` §2 U2 + its addendum; the contract `notes/CastleRules.md`.)
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-306 U2 — rule 27 (planted facts)")
@MainActor
struct ProtectionRule27FaceTests {
    static let day: (Date) -> String = { ProtectionWords.day($0) }

    // MARK: - Rule 27

    /// Before unlock: every key-file copy gone — the lobby's face (§7c (3)), the account sentence only with a sign-in,
    /// and *Start a New Library* setting the library no key file opens aside WHOLE before the creation.
    @Test func everythingGoneIsRule27sLobbyAndStartingNewSetsTheLibraryAsideWhole() async throws {
        let road = PlantedRoad()
        let (created, _) = try await road.created()
        try FileManager.default.removeItem(at: road.slot.places.liveKeyFile)
        road.memory.items = [:]
        road.custody.items = [:]
        road.apple.keys = [:]
        guard case .lobby(let lobby) = await ProtectionOpenRoad.route(road.context()) else {
            Issue.record("no road at all — the lobby")
            return
        }
        let face = ProtectionLobbyFace.derive(lobby)
        #expect(face.noKeyFileAnywhere == NoKeyFileAnywhere(accountRoad: false))
        #expect(!face.passphraseField && face.wordsRoad == .none)
        let signedIn = RoadContext(system: road.system(), session: .signedIn(accountID: "acct", email: nil), writes: true)
        #expect(ProtectionLobbyFace.derive(ProtectionOpenRoad.lobbyFacts(signedIn)).noKeyFileAnywhere?.accountRoad == true)

        let ctx = road.context()
        let model = ProtectionLobbyModel(
            standing: lobby, typedRoad: { _ in .refused("") }, touchIDRoad: { _ in .refused("") },
            refreshRoad: { lobby }, opened: { _ in }, recordMissing: {},
            startNew: {
                guard case .created = await ProtectionOpenRoad.create(
                    ctx, setAsideLiveKeyFile: true, setAsideUnopenableLibrary: true) else { return "not created" }
                return nil
            })
        #expect(model.offersStartNew)
        await model.startNewLibrary()
        #expect(model.message == nil)
        // The old library stepped aside whole into Previous Libraries — it still opens with its key there.
        let aside = try FileManager.default.contentsOfDirectory(atPath: road.slot.places.previousLibraries.path)
        let folder = road.slot.places.previousLibraries.appendingPathComponent(try #require(aside.first))
        #expect(ProtectionLibraryFiles.opens(folder.appendingPathComponent(CatalogNames.libraryFilename), key: created.key))
        // The new library is in the slot, under its own key.
        let live = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        #expect(live.fingerprint != created.library.fingerprint)
    }

    /// The doors are offered only with the creation wired, and only on rule 27's face.
    @Test func startNewIsOfferedOnlyOnRule27sFace() async throws {
        let road = PlantedRoad()
        _ = try await road.created()
        road.custody.items = [:]
        road.apple.keys = [:]
        guard case .lobby(let lobby) = await ProtectionOpenRoad.route(road.context()) else { Issue.record("the road did not open as planted"); return }
        let model = ProtectionLobbyModel(
            standing: lobby, typedRoad: { _ in .refused("") }, touchIDRoad: { _ in .refused("") },
            refreshRoad: { lobby }, opened: { _ in }, recordMissing: {}, startNew: { nil })
        #expect(!model.offersStartNew, "an ordinary lobby (the words open it) offers no fresh start")
    }

    /// After a quiet-road open with no key file anywhere: the standing banner (no doors), nothing rebuilt.
    @Test func aQuietOpenWithNoKeyFileAnywhereStandsUnderRule27sBanner() async throws {
        let road = PlantedRoad()
        _ = try await road.created()
        try FileManager.default.removeItem(at: road.slot.places.liveKeyFile)
        road.memory.items = [:]
        guard case .opened(let session) = await ProtectionOpenRoad.route(road.context()) else {
            Issue.record("the silent item still opens it")
            return
        }
        let faces = RoadStandingFaces.derive(session.report)
        #expect(faces.noKeyFileAnywhere == NoKeyFileAnywhere(accountRoad: false))
        #expect(!session.owesInterlude, "no card — a banner")
        #expect(try road.system().leaves.keyFiles.readLiveKeyFile() == nil, "nothing rebuilds a key file from the key")
    }
}
