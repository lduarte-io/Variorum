//
//  CopyDoorsListRefreshTests.swift
//  VariorumTests — VX-306 ladder round 1, m4 (the walk's W-13): THE NEW-ROAD RESTORE LIST RE-READS ITSELF when a backup
//  pair lands while it stands. Before the fix `CopyDoorsListModel.refresh()` ran only in the Data Safety pane's `.task`
//  (once per appearance), so a Back Up Now pressed in the same pane — or a scheduled run — wrote a pair the list never
//  showed until the pane was opened again. The seam is the one the backup hook already owns (`StoreBackup.onRun` →
//  `ProtectionBackupHook.handle` → the pair): the hook posts `CopyDoorsListModel.copiesChanged` once the pair has LANDED
//  (written), and every standing list re-reads. Planted roads (no keychain, no disk); the notification is named here by
//  its string so the file compiles on both sides of the fix — it ran RED on the pre-fix tree.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-306 ladder r1 m4 — the Restore list re-reads when a backup pair lands (planted)", .serialized)
@MainActor
struct CopyDoorsListRefreshTests {
    /// The notification the backup hook posts once a pair has landed (`CopyDoorsListModel.copiesChanged`).
    static let landed = Notification.Name("io.lduarte.Variorum.protection.copiesChanged")

    /// Two listings of one library: one backup, then two.
    static func listings() throws -> (one: CopyDoorsListing, two: CopyDoorsListing) {
        let library = PlantCatalog.id(), mac = PlantCatalog.id()
        let file = try PlantCatalog.keyFile(libraryID: library)
        let first = try PlantCatalog.backup(file, mac: mac, at: PlantCatalog.day(1))
        let second = try PlantCatalog.backup(file, mac: mac, at: PlantCatalog.day(2))
        return (CopyDoorsListing.make(Catalog.build(first), libraryID: library),
                CopyDoorsListing.make(Catalog.build(first + second), libraryID: library))
    }

    /// Waits (bounded) until `done` holds.
    static func settle(_ done: () -> Bool) async throws {
        for _ in 0..<200 where !done() { try await Task.sleep(for: .milliseconds(5)) }
    }

    @Test func aLandedBackupPairRefreshesTheStandingList() async throws {
        let (one, two) = try Self.listings()
        #expect(one != two && two.thisLibrary.count == 2)
        let planted = PlantedCopyDoors()
        planted.listing = one
        let list = CopyDoorsListModel(roads: planted.roads)
        await list.refresh()
        #expect(list.listing == one)
        // A Back Up Now in the same pane: the pair lands, the catalogue now lists two.
        planted.listing = two
        NotificationCenter.default.post(name: Self.landed, object: nil)
        try await Self.settle { list.listing == two }
        #expect(list.listing == two, "the list still reads the listing from before the pair landed")
    }

    /// Two re-reads in flight: the older one, landing LAST, never writes over the newer one.
    @Test func anOlderReadLandingLateNeverOverwritesANewerOne() async throws {
        let (one, two) = try Self.listings()
        var roads = PlantedCopyDoors().roads
        var calls = 0
        var release: CheckedContinuation<Void, Never>?
        roads.listing = {
            calls += 1
            if calls == 1 {
                await withCheckedContinuation { release = $0 }
                return one
            }
            return two
        }
        let list = CopyDoorsListModel(roads: roads)
        let older = Task { await list.refresh() }
        try await Self.settle { release != nil }
        await list.refresh()
        #expect(list.listing == two)
        release?.resume()
        await older.value
        #expect(list.listing == two, "an older read landed late and wrote over the newer listing")
    }
}
