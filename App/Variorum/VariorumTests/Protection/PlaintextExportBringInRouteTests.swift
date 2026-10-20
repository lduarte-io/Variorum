//
//  PlaintextExportBringInRouteTests.swift
//  VariorumTests — VX-309 U1b piece 3: T-8 end to end through `AppBootstrap` (the one switch turned on by a test harness)
//  on a temp slot and a THROWAWAY keychain scope. From an open library: the preflight reads the export, the window comes
//  down (the pool closed), the act lands the export's content in a NEW library, and the open lands READY on it — never held,
//  the receipt naming what landed said once, the old library aside whole. From the missing face: the same, nothing open
//  before. Mac only (the keychain); the same road over planted leaves is `PlaintextExportBringInRoadTests`'. Red by
//  construction on the pre-unit tree (no bring-in road; the pick refused a plain-text copy).
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-309 U1b — T-8: a plaintext export brought in through AppBootstrap (throwaway scope, temp slot)", .serialized)
@MainActor
struct PlaintextExportBringInRouteTests {
    static func titles(_ url: URL, key: StoreKey, scratch: URL) throws -> [String?] {
        let reader = try ProtectionCopyPeek.open(url, key: key, inside: scratch)
        defer { reader.close() }
        return try reader.notes().map(\.title)
    }

    @Test func fromAnOpenLibraryTheExportLandsAsANewLibraryReadyNeverHeld() async throws {
        try await withRoadDependencies {
            let world = RoadWorld()
            defer { world.scope.purge() }
            let (created, _) = try await world.created()
            let oldID = try #require(created.library.record?.libraryID)
            let bootstrap = world.bootstrap()
            await bootstrap.awaitOpen()
            guard case .ready = bootstrap.state, bootstrap.roadSession != nil else {
                Issue.record("the library opens: \(bootstrap.state)")
                return
            }
            let export = try ExportPlant.export(into: world.slot.root.appendingPathComponent("Downloads/vx309-export"))
            let roads = try #require(bootstrap.copyDoorsRoads())
            let bring = try #require(roads.bringInPlaintextExport, "the door exists with a library open")
            #expect(await bring(export) == .made)
            guard case .ready = bootstrap.state, let session = bootstrap.roadSession else {
                Issue.record("the new library opens ready: \(bootstrap.state)")
                return
            }
            #expect(session.library.record?.libraryID != oldID && session.library.record?.mode == .standard)
            #expect(!LibraryRestoreHold.isHeld(besideStore: world.slotURL), "never held — a fresh mint never synced")
            #expect(CopyDoorsPlant.asideFolders(world.slot.places).count == 1, "the old library aside whole")
            #expect(try Self.titles(world.slotURL, key: session.key, scratch: world.slot.places.scratch)
                .contains("First"))
            let standing = try #require(bootstrap.roadStanding)
            var spoken: [String] = []
            standing.speak = { spoken.append($0) }
            // VX-309 U2 piece 9, FLIPPED DELIBERATELY (the as-drafted receipt re-drafted in §7c (9)'s shape): said once, and —
            // a library was open — where the previous one went.
            let receipt = spoken.filter { $0.hasPrefix("This is your library now, made from the plain-text copy") }
            #expect(receipt.count == 1 && receipt.first?.contains("The previous one is in Previous Libraries.") == true,
                    "\(spoken)")
        }
    }

    @Test func fromTheMissingFaceTheExportLandsAsANewLibrary() async throws {
        try await withRoadDependencies {
            let world = RoadWorld()
            defer { world.scope.purge() }
            _ = try await world.created()
            ProtectionLibraryFiles.removeWithSidecars(world.slotURL)
            let bootstrap = world.bootstrap()
            await bootstrap.awaitOpen()
            guard case .libraryMissing = bootstrap.state else {
                Issue.record("the missing face: \(bootstrap.state)")
                return
            }
            let export = try ExportPlant.export(into: world.slot.root.appendingPathComponent("Downloads/vx309-export"))
            let roads = try #require(bootstrap.copyDoorsRoadsWithoutALibrary())
            let bring = try #require(roads.bringInPlaintextExport)
            #expect(await bring(export) == .made)
            guard case .ready = bootstrap.state, let session = bootstrap.roadSession else {
                Issue.record("the new library opens ready: \(bootstrap.state)")
                return
            }
            #expect(try Self.titles(world.slotURL, key: session.key, scratch: world.slot.places.scratch)
                .contains("Loose"))
            // VX-309 U2 piece 9: no library was open, so the receipt names no previous one.
            let standing = try #require(bootstrap.roadStanding)
            var spoken: [String] = []
            standing.speak = { spoken.append($0) }
            let receipt = spoken.filter { $0.hasPrefix("This is your library now, made from the plain-text copy") }
            #expect(receipt.count == 1 && receipt.first?.contains("Previous Libraries") == false, "\(spoken)")
        }
    }
}
