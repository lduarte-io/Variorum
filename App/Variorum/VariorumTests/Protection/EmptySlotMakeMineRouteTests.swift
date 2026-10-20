//
//  EmptySlotMakeMineRouteTests.swift
//  VariorumTests — VX-309 U1b piece 1: T-5 end to end through `AppBootstrap` (the one switch turned on by a test harness)
//  on a temp slot and a THROWAWAY keychain scope (the real custody and memory leaves; an in-memory Apple leaf). The missing
//  face (the library file gone, its key file and backup pair still here): the doors' roads with no library open now carry
//  Make this my library INTO THE EMPTY SLOT — the copy's own words typed — and the open lands READY on the new road with a
//  NEW library, held, a store id under its key, and the receipt said once; a wrong word refuses and the missing face stays.
//  Mac only (the keychain); the same road over planted leaves is `EmptySlotLandingRoadTests`'. Red by construction on the
//  pre-unit tree (`copyDoorsRoadsWithoutALibrary().makeMine` was nil).
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-309 U1b — T-5: Make this my library into the empty slot through AppBootstrap (throwaway scope, temp slot)", .serialized)
@MainActor
struct EmptySlotMakeMineRouteTests {
    /// The missing face's world: a library created on the new road, its pair taken by the backup hook's road, then its
    /// file (and sidecars) gone from the slot — its key file still in the live place.
    static func missingFace(_ world: RoadWorld) async throws -> (oldID: String, oldKey: StoreKey, words: [String]) {
        let (created, words) = try await world.created()
        // Migrate the store before the pair, as every real open does (the `.ready` arm runs the migrator before any
        // backup run can fire) — a pair of a never-migrated store exists only in a fixture, and the preflight's
        // schema read rightly refuses it (this suite's first Mac run caught exactly that).
        _ = try AppDatabase.onDisk(url: world.slotURL, key: created.key)
        #expect(ProtectionBackupHook.takePair(created) == .written)
        ProtectionLibraryFiles.removeWithSidecars(world.slotURL)
        return (try #require(created.library.record?.libraryID), created.key, words)
    }

    @Test func theMissingFaceLandsACopyAsANewLibraryAndOpensReadyHeld() async throws {
        try await withRoadDependencies {
            let world = RoadWorld()
            defer { world.scope.purge() }
            let (oldID, oldKey, words) = try await Self.missingFace(world)
            let bootstrap = world.bootstrap()
            await bootstrap.awaitOpen()
            guard case .libraryMissing = bootstrap.state else {
                Issue.record("the missing face: \(bootstrap.state)")
                return
            }
            #expect(bootstrap.copyDoorsRoads() == nil, "no library is open")
            let roads = try #require(bootstrap.copyDoorsRoadsWithoutALibrary())
            #expect(roads.landsInTheEmptySlot)
            let makeMine = try #require(roads.makeMine, "Make this my library is offered with no library open (T-5)")
            let listing = await roads.listing()
            let row = try #require(listing.all.first { $0.kind == .backup })
            let outcome = await makeMine(row, TypedSecrets(words: words), .none)
            #expect(outcome == .made)
            guard case .ready = bootstrap.state, let session = bootstrap.roadSession else {
                Issue.record("the open lands ready on the new road: \(bootstrap.state)")
                return
            }
            let newID = try #require(session.library.record?.libraryID)
            #expect(newID != oldID && session.key != oldKey && session.library.record?.mode == .standard)
            #expect(LibraryRestoreHold.isHeld(besideStore: world.slotURL), "held, as every adoption lands")
            guard case .known = StoreIdentity.resolve(besideStore: world.slotURL) else {
                Issue.record("a store id beside the new library")
                return
            }
            #expect(try StoreKeyEnvelope.loadCurrent(besideStore: world.slotURL)?.keyFingerprint == session.library.fingerprint)
            let aside = CopyDoorsPlant.asideFolders(world.slot.places)
            #expect(aside.count == 1, "the missing library's key file set aside, never written over")
            let standing = try #require(bootstrap.roadStanding)
            var spoken: [String] = []
            standing.speak = { spoken.append($0) }
            #expect(spoken.filter { $0 == ProtectionWords.makeMineEmptySlotReceipt }.count == 1, "\(spoken)")
        }
    }

    @Test func aWrongWordRefusesAndTheMissingFaceStays() async throws {
        try await withRoadDependencies {
            let world = RoadWorld()
            defer { world.scope.purge() }
            _ = try await Self.missingFace(world)
            let bootstrap = world.bootstrap()
            await bootstrap.awaitOpen()
            guard case .libraryMissing = bootstrap.state else {
                Issue.record("the missing face: \(bootstrap.state)")
                return
            }
            let roads = try #require(bootstrap.copyDoorsRoadsWithoutALibrary())
            let row = try #require(await roads.listing().all.first { $0.kind == .backup })
            let outcome = await roads.makeMine?(row, TypedSecrets(words: try RecoveryPhrase.generate()), .none)
            #expect(outcome == .refused(.copyDoesNotOpen))
            guard case .libraryMissing = bootstrap.state else {
                Issue.record("still the missing face: \(bootstrap.state)")
                return
            }
            #expect(!LibraryRestoreHold.isHeld(besideStore: world.slotURL))
            #expect(CopyDoorsPlant.asideFolders(world.slot.places).isEmpty)
        }
    }
}
