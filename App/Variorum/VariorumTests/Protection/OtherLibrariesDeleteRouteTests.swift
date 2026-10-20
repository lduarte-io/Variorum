//
//  OtherLibrariesDeleteRouteTests.swift
//  VariorumTests — VX-309 U1c piece 1 (VX-265) THROUGH `AppBootstrap` (a new-road bootstrap over the PLANTED road — no
//  keychain, a temp slot; Mac only: `AppBootstrap` is the app's). Rule 19's delete as the app composes it: with the library
//  open, Data Safety's roads offer the library that stepped aside (Make this my library, through the bootstrap) a delete,
//  the press deletes every copy this Mac made of it on the OPEN session and speaks the receipt on the status seam, the
//  library staying ready; with NO library open (the missing face) the roads delete another library's copies and never the
//  remembered one's. Red by construction on the pre-unit tree (no `deleteCopies` road).
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-309 U1c — rule 19's delete through AppBootstrap (planted, no keychain)", .serialized)
@MainActor
struct OtherLibrariesDeleteRouteTests {
    /// A library open through the bootstrap, then Make this my library on its own backup (A steps aside for B).
    private func aSteppedAside(_ road: PlantedRoad) async throws -> (bootstrap: AppBootstrap, aID: String) {
        let (bootstrap, words) = try await LockWorld.readyInStandard(road)
        let session = try #require(bootstrap.roadSession)
        let aID = try #require(session.library.record?.libraryID)
        #expect(ProtectionBackupHook.takePair(session) == .written)
        let roads = try #require(bootstrap.copyDoorsRoads())
        let row = try #require(await roads.listing().thisLibrary.first)
        let pair = TypedSecrets(words: words)
        #expect(await bootstrap.makeThisMyLibrary(row, copySecrets: pair, currentPair: pair) == .made)
        guard case .ready = bootstrap.state else { throw LockWorld.LockWorldError.notReady("\(bootstrap.state)") }
        return (bootstrap, aID)
    }

    @Test func withTheLibraryOpenTheDeleteRunsOnTheOpenSessionAndSpeaksItsReceipt() async throws {
        try await withRoadDependencies {
            let road = PlantedRoad()
            let (bootstrap, aID) = try await aSteppedAside(road)
            let open = try #require(bootstrap.roadSession)
            let standing = try #require(bootstrap.roadStanding)
            var spoken: [String] = []
            standing.speak = { spoken.append($0) }
            let roads = try #require(bootstrap.copyDoorsRoads())
            let choice = try #require(await roads.listing().deleteChoices[aID], "the library that stepped aside")
            let delete = try #require(roads.deleteCopies)
            #expect(await delete(aID) == .deleted(choice.count))
            #expect(spoken.contains(ProtectionWords.deleteCopiesReceipt(choice.count)), "\(spoken)")
            #expect(!(await roads.listing()).all.contains { $0.copy.library == aID })
            #expect(CopyDoorsPlant.asideFolders(road.slot.places).isEmpty, "A's Previous Library, whole")
            guard case .ready = bootstrap.state else {
                Issue.record("the library stays open — a delete never reopens: \(bootstrap.state)")
                return
            }
            #expect(bootstrap.roadSession === open && open.library.section.actInFlight == nil)
        }
    }

    @Test func withNoLibraryOpenTheRoadsDeleteAnotherLibraryAndNeverTheRememberedOne() async throws {
        try await withRoadDependencies {
            let road = PlantedRoad()
            let (bootstrap, aID) = try await aSteppedAside(road)
            let bID = try #require(bootstrap.roadSession?.library.record?.libraryID)
            // The missing face: B moved out of the slot (the walk's own move — never a delete).
            try Plant.moveLibraryAway(road, to: road.slot.root.appendingPathComponent("away", isDirectory: true))
            bootstrap.retry()
            await bootstrap.awaitOpen()
            guard case .libraryMissing = bootstrap.state else {
                Issue.record("the missing face: \(bootstrap.state)")
                return
            }
            #expect(bootstrap.copyDoorsRoads() == nil, "no library is open")
            let roads = try #require(bootstrap.copyDoorsRoadsWithoutALibrary())
            let listing = await roads.listing()
            #expect(listing.deleteChoices[bID] == nil, "the remembered library — never offered")
            let choice = try #require(listing.deleteChoices[aID])
            let delete = try #require(roads.deleteCopies)
            #expect(await delete(bID) == .refused(.copyGone))
            #expect(await delete(aID) == .deleted(choice.count))
            let after = await roads.listing()
            #expect(!after.all.contains { $0.copy.library == aID } && after.all.contains { $0.copy.library == bID })
        }
    }
}
