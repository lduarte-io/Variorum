//
//  ProtectionBackupHookTests.swift
//  VariorumTests — VX-306 U1b piece 5: STAGE 3 ON THE NEW ROAD (P-VX306-K4) — the `StoreBackup.onRun` hook lands
//  rule 5's PAIR (the library under its key + its frozen key file) in this Mac's `Backups/<library8>/<mac8>/`, on a
//  temp slot and a throwaway keychain scope: only for a run that wrote a snapshot; never while copies are paused;
//  never with another key's file; never attached for a read-only (hosted test run) session.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-306 U1b — the backup hook: a pair per backup run that wrote (throwaway scope, temp slot)", .serialized)
@MainActor
struct ProtectionBackupHookTests {
    private func pairs(_ world: RoadWorld, _ session: ProtectionRoadSession) -> [String] {
        let libraryID = session.library.record?.libraryID ?? ""
        let folder = world.slot.places.backupFolder(libraryID: libraryID, deviceID: session.library.section.deviceID)
        return ((try? FileManager.default.contentsOfDirectory(atPath: folder.path)) ?? []).sorted()
    }

    @Test func aRunThatWroteASnapshotLandsAPairThatOpensWithTheLibrarysKey() async throws {
        let world = RoadWorld()
        defer { world.scope.purge() }
        let (session, _) = try await world.created()
        let record = BackupRunRecord(at: Date(), primary: .init(outcome: .written), secondary: .init(outcome: .noDestination))
        let outcome = await ProtectionBackupHook.handle(record, session: session)?.value
        #expect(outcome == .written)
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

    @Test func aRunThatFoundNothingDueWritesNoPair() async throws {
        let world = RoadWorld()
        defer { world.scope.purge() }
        let (session, _) = try await world.created()
        let record = BackupRunRecord(at: Date(), primary: .init(outcome: .upToDate), secondary: .init(outcome: .noDestination))
        #expect(ProtectionBackupHook.handle(record, session: session) == nil)
        #expect(pairs(world, session).isEmpty)
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
        #expect(backup.onRun == nil, "today's road — nothing attached")
        let readOnly = ProtectionRoadSession(
            system: session.system, executor: session.executor, library: session.library, report: session.report,
            isFresh: false, writes: false)
        ProtectionBackupHook.attach(to: backup, session: readOnly)
        #expect(backup.onRun == nil, "a hosted test run — nothing attached")
        ProtectionBackupHook.attach(to: backup, session: session)
        #expect(backup.onRun != nil)
    }
}
