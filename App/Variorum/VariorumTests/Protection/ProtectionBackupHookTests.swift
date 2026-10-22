//
//  ProtectionBackupHookTests.swift
//  VariorumTests — VX-306 U1b piece 5: STAGE 3 ON THE NEW ROAD (P-VX306-K4) — rule 5's PAIR (the library under its key
//  + its frozen key file) lands in this Mac's `Backups/<library8>/<mac8>/`, on a temp slot and a throwaway keychain
//  scope; never while copies are paused; never with another key's file; never attached for a read-only (hosted test
//  run) session. VX-329 U1 — THE RELEASE SWITCH: the pair road IS the backup writer (R-U1-5): `attach` hands
//  `StoreBackup` its `pairRoad`, and a run lands a pair when one is DUE (this Mac's newest pair older than the interval
//  — `OwnCopies.pairIsDue`) or forced, where today's hook rode a flat run that wrote (`handle(record:)`, deleted with the
//  flat legs). The claims are the same, through the writer the clock now calls.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

/// A count the main actor keeps (the m4 pin's ear).
@MainActor
final class HeardCount {
    var count = 0
}

@Suite("VX-306 U1b — the backup hook: the pair road is the backup run's writer (throwaway scope, temp slot)", .serialized)
@MainActor
struct ProtectionBackupHookTests {
    private func pairs(_ world: RoadWorld, _ session: ProtectionRoadSession) -> [String] {
        let libraryID = session.library.record?.libraryID ?? ""
        let folder = world.slot.places.backupFolder(libraryID: libraryID, deviceID: session.library.section.deviceID)
        return ((try? FileManager.default.contentsOfDirectory(atPath: folder.path)) ?? []).sorted()
    }

    @Test func aDueRunLandsAPairThatOpensWithTheLibrarysKey() async throws {
        let world = RoadWorld()
        defer { world.scope.purge() }
        let (session, _) = try await world.created()
        // A fresh library has no pair yet, so the clock's first run is due.
        let legs = ProtectionBackupHook.runPair(session, force: false, now: Date())
        #expect(legs.primary.outcome == .written)
        #expect(legs.secondary.outcome == .noDestination, "no picked folder — the far leg says so")
        let files = pairs(world, session)
        let snapshot = try #require(files.first { $0.hasSuffix(".sqlite") })
        let keys = try #require(files.first { $0.hasSuffix(".keys.json") })
        #expect(snapshot.hasPrefix("variorum-backup-"))
        #expect(keys == String(snapshot.dropLast(".sqlite".count)) + ".keys.json", "the pair: one stem")
        let folder = world.slot.places.backupFolder(
            libraryID: session.library.record?.libraryID ?? "", deviceID: session.library.section.deviceID)
        #expect(ProtectionLibraryFiles.opens(folder.appendingPathComponent(snapshot), key: session.key))
        let frozen = try KeyFile.decode(Data(contentsOf: folder.appendingPathComponent(keys)))
        #expect(frozen == (try world.system().leaves.keyFiles.readLiveKeyFile()), "the live key file, frozen beside it")
        // The catalogue reads it as this library's backup (the doors' road, U3).
        let catalog = world.system().lister.catalog()
        #expect(catalog.copies(ofLibrary: session.library.record?.libraryID ?? "").contains { $0.kind == .backup })
    }

    /// THE LADDER'S ROUND-1 m4 at the seam: a pair that LANDED says so — `CopyDoorsListModel.copiesChanged` once, on the
    /// main actor — and a standing Restore list re-reads; a run that wrote nothing says nothing. (Pre-fix: no word at
    /// all, so the list kept its old rows until the pane reopened — W-13.) VX-329 U1: driven through the writer `attach`
    /// hands the clock (`StoreBackup.pairRoad`).
    @Test func aLandedPairTellsTheRestoreListAndANothingDueRunSaysNothing() async throws {
        let world = RoadWorld()
        defer { world.scope.purge() }
        let (session, _) = try await world.created()
        let database = try AppDatabase.openStore(at: world.slotURL, custody: .inMemory(initial: session.key))
        let backup = StoreBackup(database: database, directory: world.slot.places.backups)
        ProtectionBackupHook.attach(to: backup, session: session)
        let road = try #require(backup.pairRoad)
        let heard = HeardCount()
        let observer = CopiesChangedObserver { heard.count += 1 }
        defer { withExtendedLifetime(observer) {} }
        #expect(road(false, Date()).primary.outcome == .written, "the first run is due")
        for _ in 0..<200 where heard.count < 1 { try await Task.sleep(for: .milliseconds(5)) }
        #expect(heard.count == 1, "the landed pair is said once")
        #expect(road(false, Date()).primary.outcome == .upToDate, "a fresh pair stands — nothing due")
        try await Task.sleep(for: .milliseconds(50))
        #expect(heard.count == 1, "a run that wrote nothing says nothing")
        // The real list, standing, re-reads to the pair the road writes next.
        let session2 = session
        var roads = PlantedCopyDoors().roads
        roads.listing = { await Task.detached { ProtectionCopyDoors.listing(session2) }.value }
        let list = CopyDoorsListModel(roads: roads)
        await list.refresh()
        #expect(list.listing.thisLibrary.count == 1)
        #expect(road(true, Date().addingTimeInterval(2)).primary.outcome == .written, "Back Up Now forces one")
        for _ in 0..<200 where list.listing.thisLibrary.count < 2 { try await Task.sleep(for: .milliseconds(5)) }
        #expect(list.listing.thisLibrary.count == 2, "the standing list shows the second pair")
        _ = database.asRebindable().binding.lock()
    }

    @Test func aRunThatFoundNothingDueWritesNoPair() async throws {
        let world = RoadWorld()
        defer { world.scope.purge() }
        let (session, _) = try await world.created()
        let now = Date()
        #expect(ProtectionBackupHook.runPair(session, force: false, now: now).primary.outcome == .written)
        let first = pairs(world, session)
        #expect(ProtectionBackupHook.runPair(session, force: false, now: now.addingTimeInterval(60)).primary.outcome
                == .upToDate)
        #expect(pairs(world, session) == first, "nothing due — no second pair")
    }

    @Test func pausedCopiesTakeNoPair() async throws {
        let world = RoadWorld()
        defer { world.scope.purge() }
        let (session, _) = try await world.created()
        session.system.backups.pauseCopies()
        #expect(ProtectionBackupHook.takePair(session) == .paused)
        #expect(pairs(world, session).isEmpty)
        session.system.backups.resumeCopies()
        #expect(ProtectionBackupHook.takePair(session) == .written)
    }

    @Test func aLiveKeyFileOfAnotherKeyTakesNoPair() async throws {
        let world = RoadWorld()
        defer { world.scope.purge() }
        let (session, _) = try await world.created()
        let stranger = try LobbyFixture.liveKeyFile(passphrase: false)
        try world.system().leaves.keyFiles.writeLiveKeyFile(stranger)
        #expect(ProtectionBackupHook.takePair(session) == .noKeyFileOfTheKey)
        #expect(pairs(world, session).isEmpty)
    }

    @Test func theHookIsAttachedOnlyForAWritingSession() async throws {
        let world = RoadWorld()
        defer { world.scope.purge() }
        let (session, _) = try await world.created()
        let database = try AppDatabase.openStore(at: world.slotURL, custody: .inMemory(initial: session.key))
        let directory = world.slot.root.appendingPathComponent("flat-backups", isDirectory: true)
        let backup = StoreBackup(database: database, directory: directory)
        ProtectionBackupHook.attach(to: backup, session: nil)
        #expect(backup.pairRoad == nil, "no library open on the road — nothing attached")
        let readOnly = ProtectionRoadSession(
            system: session.system, executor: session.executor, library: session.library, report: session.report,
            isFresh: false, writes: false)
        ProtectionBackupHook.attach(to: backup, session: readOnly)
        #expect(backup.pairRoad == nil, "a hosted test run — nothing attached")
        ProtectionBackupHook.attach(to: backup, session: session)
        #expect(backup.pairRoad != nil)
        // A later attach for no session drops the writer again (the lock's teardown, a library closed).
        ProtectionBackupHook.attach(to: backup, session: nil)
        #expect(backup.pairRoad == nil)
    }
}
