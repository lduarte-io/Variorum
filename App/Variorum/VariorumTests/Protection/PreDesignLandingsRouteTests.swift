//
//  PreDesignLandingsRouteTests.swift
//  VariorumTests — VX-329 U4 piece 3, THE RULING's (D): her pre-design face's OTHER door. Both Open Library… landings — T-5's
//  Make this my library into the empty slot and T-8's bring-in of a plaintext export — set a library from before this
//  design aside through the SAME whole act (its older key files, sidecars and store together, the same files they were —
//  never split), and the bootstrap's gates admit her face by its own fact. End to end through `AppBootstrap` on a temp slot
//  and a THROWAWAY keychain scope, on the REMEMBERING-MAC shape (this Mac's keychain still holds a library of this design:
//  its memory item with a key-file copy, its silent item — so rule 27's refusal never derives): on the pre-U4 tree the gate
//  admitted rule 27's face only, so both landings refused `.failed` here — RED ON OLD (this file names no U4 symbol, so the
//  revert run compiles). Mac only (the keychain).
//

import Darwin
import Foundation
import Testing

@testable import Variorum
import VariorumCore

/// A library from before this design planted in a slot, and the proof it left WHOLE.
@MainActor
enum PreDesignPlant {
    struct Planted {
        /// Every file of the library, by name, with its file identity (device + inode) as planted.
        var identities: [String: [Int]]
    }

    nonisolated static func identity(_ url: URL) -> [Int]? {
        var info = stat()
        guard lstat(url.path, &info) == 0 else { return nil }
        return [Int(info.st_dev), Int(info.st_ino)]
    }

    /// The slot's library REPLACED by one from before this design (this Mac's keychain left exactly as it was): the store
    /// and its sidecars and this design's key file gone; a keyed store with no protection record, and an older Variorum's
    /// two key-file names beside it.
    static func replaceSlot(_ places: ProtectionPlaces) throws -> Planted {
        ProtectionLibraryFiles.removeWithSidecars(places.slot)
        try? FileManager.default.removeItem(at: places.liveKeyFile)
        let key = StoreKey.mint()
        let database = try AppDatabase.onDisk(url: places.slot, key: key)
        _ = database.asRebindable().binding.lock()
        let fingerprintName = "variorum-keys-\(KeyFingerprint.of(key)).json"
        try Data(#"{"formatVersion":2,"keyFingerprint":"x"}"#.utf8).write(to: places.container.appendingPathComponent(fingerprintName))
        try Data(#"{"formatVersion":1}"#.utf8).write(to: places.container.appendingPathComponent("variorum-keys.json"))
        var identities: [String: [Int]] = [:]
        for name in [CatalogNames.libraryFilename, "variorum.sqlite-wal", "variorum.sqlite-shm", fingerprintName,
                     "variorum-keys.json"] {
            if let id = identity(places.container.appendingPathComponent(name)) { identities[name] = id }
        }
        return Planted(identities: identities)
    }

    /// The planted library in exactly one Previous Libraries folder, every file the SAME FILE it was in the slot (moved
    /// by its entry, never copied — never read), and no older name left beside the slot.
    static func expectSetAsideWhole(
        _ places: ProtectionPlaces, _ planted: Planted, sourceLocation: SourceLocation = #_sourceLocation
    ) throws {
        let asides = CopyDoorsPlant.asideFolders(places)
        #expect(asides.count == 1, "one aside: \(asides)", sourceLocation: sourceLocation)
        guard let aside = asides.first else { return }
        for (name, before) in planted.identities {
            #expect(identity(aside.appendingPathComponent(name)) == before,
                    "\(name) is in the aside, the same file it was", sourceLocation: sourceLocation)
        }
        let beside = try FileManager.default.contentsOfDirectory(atPath: places.container.path)
        #expect(!beside.contains { $0.hasPrefix("variorum-keys") }, "no older name left in the slot: \(beside)",
                sourceLocation: sourceLocation)
    }
}

@Suite("VX-329 U4 — (D): Open Library…'s landings from her face set the old library aside whole (throwaway scope)", .serialized)
@MainActor
struct PreDesignLandingsRouteTests {
    /// The remembering Mac: a library of this design created here (its memory item and silent item in this scope), its
    /// backup pair taken — then the slot's library replaced by one from before this design.
    static func rememberingMac(_ world: RoadWorld) async throws -> (words: [String], planted: PreDesignPlant.Planted) {
        let (created, words) = try await world.created()
        _ = try AppDatabase.onDisk(url: world.slotURL, key: created.key)
        #expect(ProtectionBackupHook.takePair(created) == .written)
        return (words, try PreDesignPlant.replaceSlot(world.slot.places))
    }

    @Test func makeThisMyLibraryFromHerFaceSetsTheOldLibraryAsideWholeAndLands() async throws {
        try await withRoadDependencies {
            let world = RoadWorld()
            defer { world.scope.purge() }
            let (words, planted) = try await Self.rememberingMac(world)
            let bootstrap = world.bootstrap()
            await bootstrap.awaitOpen()
            guard case .roadLobby = bootstrap.state else {
                Issue.record("a store from before this design meets the lobby's surface: \(bootstrap.state)")
                return
            }
            let roads = try #require(bootstrap.copyDoorsRoadsWithoutALibrary())
            let row = try #require(await roads.listing().all.first { $0.kind == .backup })
            // THE GATE'S FACT ARM — red on the pre-U4 tree (`.refused(.failed)`: rule 27's face was the only lobby admitted).
            #expect(await roads.makeMine?(row, TypedSecrets(words: words), .none) == .made)
            guard case .ready = bootstrap.state, let session = bootstrap.roadSession else {
                Issue.record("the copy lands as a new library, ready: \(bootstrap.state)")
                return
            }
            #expect(session.library.record?.mode == .standard)
            #expect(LibraryRestoreHold.isHeld(besideStore: world.slotURL), "held, as every adoption lands (its own hold)")
            try PreDesignPlant.expectSetAsideWhole(world.slot.places, planted)
        }
    }

    @Test func aPlaintextExportBroughtInFromHerFaceSetsTheOldLibraryAsideWhole() async throws {
        try await withRoadDependencies {
            let world = RoadWorld()
            defer { world.scope.purge() }
            let (_, planted) = try await Self.rememberingMac(world)
            let bootstrap = world.bootstrap()
            await bootstrap.awaitOpen()
            guard case .roadLobby = bootstrap.state else {
                Issue.record("the lobby's surface: \(bootstrap.state)")
                return
            }
            let export = try ExportPlant.export(into: world.slot.root.appendingPathComponent("Downloads/vx329-u4-export"))
            let roads = try #require(bootstrap.copyDoorsRoadsWithoutALibrary())
            let bring = try #require(roads.bringInPlaintextExport)
            // The same gate, the same fact — red on the pre-U4 tree.
            #expect(await bring(export) == .made)
            guard case .ready = bootstrap.state, bootstrap.roadSession != nil else {
                Issue.record("the new library opens ready: \(bootstrap.state)")
                return
            }
            #expect(!LibraryRestoreHold.isHeld(besideStore: world.slotURL), "never held — a fresh mint never synced")
            try PreDesignPlant.expectSetAsideWhole(world.slot.places, planted)
        }
    }
}
