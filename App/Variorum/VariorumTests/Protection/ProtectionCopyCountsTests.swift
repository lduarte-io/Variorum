//
//  ProtectionCopyCountsTests.swift
//  VariorumTests — VX-309 U1a piece 2 (VX-397): Settings ▸ Data Safety's counts on the NEW road read the catalogue per
//  library per Mac — this Mac's pairs of the open library, in the container and in the picked folder — over a PLANTED
//  road (no keychain — also headless in the implementer's harness). Today's flat files, another Mac's fresh copy in the
//  shared folder, another library's pair and a pair whose key file doesn't read are never this Mac's copies; a copy
//  stamped ahead of the clock is counted (a real file) but never the newest.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-309 U1a — Data Safety's new-road counts: this Mac's pairs of this library, per place (VX-397)")
@MainActor
struct ProtectionCopyCountsTests {
    @Test func theCountsAreThisMacsPairsOfThisLibraryPerPlaceAndNothingElse() async throws {
        let road = PlantedRoad(farFolder: true)
        let (session, _) = try await road.created()
        let libraryID = FarPlant.libraryID(session), deviceID = FarPlant.deviceID(session)
        let farRoot = FarPlant.farRoot(road)
        let now = Date()
        // THIS Mac's pairs of THIS library: two beside the library, one in the picked folder, one there stamped ahead.
        let older = now.addingTimeInterval(-3 * 86_400), newer = now.addingTimeInterval(-86_400)
        try FarPlant.pair(in: FarPlant.ownContainer(road, session), libraryID: libraryID, at: older)
        try FarPlant.pair(in: FarPlant.ownContainer(road, session), libraryID: libraryID, at: newer)
        try FarPlant.pair(in: FarPlant.ownFar(road, session), libraryID: libraryID, at: newer)
        try FarPlant.pair(in: FarPlant.ownFar(road, session), libraryID: libraryID, at: now.addingTimeInterval(3_600))
        // The wrong shapes, each fresh: another Mac's copy of this library in the shared folder; this Mac's copy of
        // another library; a snapshot whose key file is missing; today's flat files in both places.
        let otherMac = FarPlant.anotherMac(than: deviceID)
        try FarPlant.pair(in: FarPlant.folder(farRoot, libraryID: libraryID, deviceID: otherMac), libraryID: libraryID, at: now)
        try FarPlant.pair(in: FarPlant.folder(road.slot.container, libraryID: libraryID, deviceID: otherMac),
                          libraryID: libraryID, at: now)
        let another = UUID().uuidString.lowercased()
        try FarPlant.pair(in: FarPlant.folder(road.slot.container, libraryID: another, deviceID: deviceID),
                          libraryID: another, at: now)
        let orphan = try FarPlant.pair(in: FarPlant.ownContainer(road, session), libraryID: libraryID, at: now)
        try FileManager.default.removeItem(at: FileBackupsLeaf.pairURL(of: FarPlant.ownContainer(road, session)
            .appendingPathComponent(orphan)))
        for root in [road.slot.container, farRoot] {
            let flat = root.appendingPathComponent(CatalogNames.backupsFolderName, isDirectory: true)
            try FileManager.default.createDirectory(at: flat, withIntermediateDirectories: true)
            for day in [1.0, 2, 3] {
                let name = CatalogNames.backupPrefix + CatalogNames.stampString(now.addingTimeInterval(-day * 3_600)) + ".sqlite"
                try Data("today's flat file".utf8).write(to: flat.appendingPathComponent(name))
            }
        }

        let counts = ProtectionCopyCounts.read(session, now: now)
        // Whole seconds — the names are second-granular.
        func second(_ date: Date) -> Date { CatalogNames.stamp(CatalogNames.stampString(date))! }
        #expect(counts.container == OwnCopies.Summary(count: 2, newest: second(newer), oldest: second(older)),
                "beside the library: this Mac's two pairs of this library — \(counts.container)")
        #expect(counts.far == OwnCopies.Summary(count: 2, newest: second(newer), oldest: second(newer)),
                "the picked folder: this Mac's two pairs (one stamped ahead — counted, never the newest) — \(counts.far)")
    }

    @Test func aLibraryWithNoPairsAnywhereCountsNone() async throws {
        let road = PlantedRoad(farFolder: true)
        let (session, _) = try await road.created()
        #expect(ProtectionCopyCounts.read(session) == RoadCopyCounts(container: .none, far: .none))
    }

    /// The pair road's own pairs are what the counts read: one written pair lands one in each place.
    @Test func thePairRoadsPairsAreCountedInBothPlaces() async throws {
        let road = PlantedRoad(farFolder: true)
        let (session, _) = try await road.created()
        #expect(ProtectionBackupHook.takePair(session) == .written)
        let counts = ProtectionCopyCounts.read(session)
        #expect(counts.container.count == 1 && counts.far.count == 1, "\(counts)")
    }
}
