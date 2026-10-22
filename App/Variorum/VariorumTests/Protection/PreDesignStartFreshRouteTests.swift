//
//  PreDesignStartFreshRouteTests.swift
//  VariorumTests — VX-329 U4 piece 3: her pre-design face's *Start fresh…* (the plan's §6d; THE RULING (a)). Her confirm
//  promises "Your old library will be set aside whole in Previous Libraries — nothing is deleted." Pinned:
//    · over PLANTED leaves (no keychain): the road sets the old library aside WHOLE (every file the same file it was, in one
//      Previous Libraries folder; no older name left) and creates a new library exactly as an empty slot does — its next
//      open quiet; a slot that is no longer pre-design moves nothing; THE CREATION ROAD finishes an interrupted set-aside
//      (a remainder of the aside's own files beside an empty slot leaves before the creation);
//    · through `AppBootstrap` on a THROWAWAY keychain scope, on the remembering-Mac shape: the face's door is WIRED
//      (`offersStartFresh` — the fact AND the act), and pressing it (after her confirm, which the view asks) opens a new
//      library ready, never held, the old one aside whole.
//  The core mover's own arms (crash at every seam, the failed link, the stamp never overwritten) are core's
//  `PreDesignSetAsideTests`.
//

import Darwin
import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-329 U4 — Start fresh…: the old library aside whole, then the calm creation")
@MainActor
struct PreDesignStartFreshRouteTests {
    @Test func startFreshSetsTheOldLibraryAsideWholeAndCreatesANewLibrary() async throws {
        let road = PlantedRoad()
        let planted = try PreDesignPlant.replaceSlot(road.slot.places)
        guard case .created(let session, let words) = await ProtectionOpenRoad.startFreshOverAPreDesignStore(road.context())
        else {
            Issue.record("Start fresh creates a library once the old one is aside")
            return
        }
        #expect(words.words.count == 12 && session.isFresh, "a creation exactly as an empty slot's")
        try PreDesignPlant.expectSetAsideWhole(road.slot.places, planted)
        let live = try #require(try road.system().leaves.keyFiles.readLiveKeyFile(), "this design's key file beside it")
        #expect(live.libraryID == session.library.record?.libraryID)
        guard case .opened(let reopened) = await ProtectionOpenRoad.route(road.context()) else {
            Issue.record("the new library's next open is quiet")
            return
        }
        #expect(reopened.key == session.key)
    }

    @Test func aSlotThatIsNoLongerFromBeforeThisDesignMovesNothing() async throws {
        let road = PlantedRoad()
        let (created, _) = try await road.created()
        guard case .failed(let sentence) = await ProtectionOpenRoad.startFreshOverAPreDesignStore(road.context()) else {
            Issue.record("a stale face never sets a library of this design aside")
            return
        }
        #expect(sentence == ProtectionWords.couldNotCreate)
        #expect(CopyDoorsPlant.asideFolders(road.slot.places).isEmpty, "nothing moved")
        guard case .opened(let session) = await ProtectionOpenRoad.route(road.context()) else {
            Issue.record("the library still opens")
            return
        }
        #expect(session.key == created.key)
    }

    /// THE RULING: the resume runs on the creation road too. A set-aside interrupted past its commit, after the store left
    /// the slot (the remainder: the older key files, the same files as the aside's) — the launch reads an empty slot and
    /// creates; the remainder leaves first, so nothing of the old library stands beside the new one.
    @Test func theCreationRoadFinishesAnInterruptedSetAside() async throws {
        let road = PlantedRoad()
        let planted = try PreDesignPlant.replaceSlot(road.slot.places)
        let places = road.slot.places
        let aside = places.previousLibraries.appendingPathComponent(CatalogNames.stampString(Date()), isDirectory: true)
        try FileManager.default.createDirectory(at: aside, withIntermediateDirectories: true)
        for name in planted.identities.keys {
            #expect(link(places.container.appendingPathComponent(name).path, aside.appendingPathComponent(name).path) == 0)
        }
        for name in [CatalogNames.libraryFilename, "variorum.sqlite-wal", "variorum.sqlite-shm"] {
            unlink(places.container.appendingPathComponent(name).path)
        }
        guard case .created = await ProtectionOpenRoad.route(road.context()) else {
            Issue.record("an empty slot creates")
            return
        }
        try PreDesignPlant.expectSetAsideWhole(places, planted)
    }

    @Test func throughTheBootstrapTheDoorIsWiredAndStartFreshOpensANewLibrary() async throws {
        try await withRoadDependencies {
            let world = RoadWorld()
            defer { world.scope.purge() }
            let (created, _) = try await world.created()
            let oldID = try #require(created.library.record?.libraryID)
            let planted = try PreDesignPlant.replaceSlot(world.slot.places)
            let bootstrap = world.bootstrap()
            await bootstrap.awaitOpen()
            guard case .roadLobby(let lobby) = bootstrap.state else {
                Issue.record("the lobby's surface: \(bootstrap.state)")
                return
            }
            #expect(lobby.face.preDesignStore && lobby.offersStartFresh, "her face, its door wired (P-2)")
            await lobby.startFresh()
            await bootstrap.awaitOpen()
            guard case .ready = bootstrap.state, let session = bootstrap.roadSession else {
                Issue.record("a new library opens ready: \(bootstrap.state) — \(lobby.message ?? "")")
                return
            }
            #expect(session.library.record?.libraryID != oldID && session.library.record?.mode == .standard)
            #expect(!LibraryRestoreHold.isHeld(besideStore: world.slotURL), "a fresh start is never held")
            try PreDesignPlant.expectSetAsideWhole(world.slot.places, planted)
        }
    }
}
