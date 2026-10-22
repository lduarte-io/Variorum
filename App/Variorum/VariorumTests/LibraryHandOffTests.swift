//
//  LibraryHandOffTests.swift
//  VariorumTests
//
//  Phase 13x U1 row 2 — the hand-off's pins: the round trip (produce → the open door reads it back as a pair → the
//  pair's own key file opens the copy and a row written before the send is inside), the no-key-file refusal, and the
//  same-day collision rule.
//
//  VX-329 U1 — THE RELEASE SWITCH: today's producer (a sealed snapshot beside TODAY's key file) was today's road and
//  was deleted with it; Send Library runs the protection road's own act (`ProtectionExecutor.sendLibrary` →
//  `variorum.sqlite` + this design's key file — PROVISIONAL P-VX329-U1-1), through the bootstrap
//  (`AppBootstrap.sendLibrary(into:)`), so these pins run it over the PLANTED road (no keychain) and read the folder back
//  with the road's own open door (`PickedCopy`). The dev-store drill (it read the dev key from today's custody) went
//  with today's custody.
//

import Foundation
import GRDB
import Testing

@testable import Variorum
import VariorumCore

@MainActor
@Suite("13x U1 — the hand-off folder pair (VX-329: the road's own act)", .serialized)
struct LibraryHandOffTests {
    private func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-13x-handoff-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    /// THE ROUND TRIP: a library open on the road with a marked row → the folder pair → the open door reads it back as
    /// this design's pair → the pair's key file opens with the library's words to the library's key → the copy opens
    /// under it and the marked row is inside; the live library still reads it (the source was only read).
    @Test func theHandOffFolderRoundTripsThroughTheOpenDoorAndItsOwnKeyFile() async throws {
        try await withRoadDependencies {
            let dir = try temporaryDirectory()
            defer { try? FileManager.default.removeItem(at: dir) }
            let (bootstrap, words) = try await LockWorld.readyInStandard(PlantedRoad())
            guard case .ready(let app) = bootstrap.state, let session = bootstrap.roadSession else {
                Issue.record("the library is open on the road: \(bootstrap.state)")
                return
            }
            try await app.database.write { db in
                try db.execute(
                    sql: """
                        INSERT INTO container (id, kind, title, created_at, updated_at)
                        VALUES ('13x-handoff-marker', 'post', 'the travelling row', '2027-01-01T00:00:00Z', '2027-01-01T00:00:00Z')
                        """)
            }
            let parent = dir.appendingPathComponent("Desktop", isDirectory: true)
            try FileManager.default.createDirectory(at: parent, withIntermediateDirectories: true)

            let folder = try await bootstrap.sendLibrary(into: parent).get()
            #expect(folder.deletingLastPathComponent().standardizedFileURL == parent.standardizedFileURL)
            #expect(folder.lastPathComponent.hasPrefix(LibraryHandOff.folderPrefix))
            let contents = try FileManager.default.contentsOfDirectory(atPath: folder.path).sorted()
            #expect(contents == [ProtectionNames.keyFilename, "variorum.sqlite"].sorted(),
                    "exactly the pair — no sidecars, nothing else")

            guard case .pair(let pair) = PickedCopy.classify(folder) else {
                Issue.record("the open door reads the folder as this design's pair: \(PickedCopy.classify(folder))")
                return
            }
            #expect(pair.document.libraryID == session.library.record?.libraryID)
            #expect(pair.document.fingerprint == KeyFingerprint.of(session.key), "the key file of the library's key")
            let opened = try pair.document.open(.words(words), floor: .relaxedForTests)
            #expect(opened == session.key, "the pair's own key file opens the copy — corner 33 made true")
            let reopened = try AppDatabase.openStore(at: pair.store, custody: .inMemory(initial: opened))
            defer { _ = reopened.asRebindable().binding.lock() }
            let title = try await reopened.read { db in
                try String.fetchOne(db, sql: "SELECT title FROM container WHERE id = '13x-handoff-marker'")
            }
            #expect(title == "the travelling row")
            let stillThere = try await app.database.read { db in
                try String.fetchOne(db, sql: "SELECT title FROM container WHERE id = '13x-handoff-marker'")
            }
            #expect(stillThere == "the travelling row", "the source was only read")
        }
    }

    /// REFUSAL: no live key file of the library's key ⇒ the door's no-key-file refusal and no folder at all (a pair
    /// without its key file opens nothing — the act never mints a dead hand-off).
    @Test func aLibraryWithoutItsKeyFileRefusesAndLeavesNothingBehind() async throws {
        try await withRoadDependencies {
            let dir = try temporaryDirectory()
            defer { try? FileManager.default.removeItem(at: dir) }
            let (bootstrap, _) = try await LockWorld.readyInStandard(PlantedRoad())
            let session = try #require(bootstrap.roadSession)
            var library = session.library
            library.keyFile = nil
            session.library = library
            let parent = dir.appendingPathComponent("Desktop", isDirectory: true)
            try FileManager.default.createDirectory(at: parent, withIntermediateDirectories: true)

            let result = await bootstrap.sendLibrary(into: parent)
            #expect(result == .failure(.noKeyFile))
            #expect(LibraryHandOffModel.refusal(for: .noKeyFile)
                == .refused(LibraryOpenCopy.handOffNoKeyFileRefusal, detail: nil))
            #expect(try FileManager.default.contentsOfDirectory(atPath: parent.path).isEmpty,
                    "nothing half-made is left behind")
        }
    }

    /// Same-day repeats step aside: " (2)", " (3)" (PROVISIONAL P-U1-4).
    @Test func sameDayHandOffsNeverOverwriteEachOther() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let first = LibraryHandOff.availableFolderURL(in: dir, now: now)
        #expect(first.lastPathComponent == LibraryHandOff.folderName(on: now))
        try FileManager.default.createDirectory(at: first, withIntermediateDirectories: true)
        let second = LibraryHandOff.availableFolderURL(in: dir, now: now)
        #expect(second.lastPathComponent == LibraryHandOff.folderName(on: now) + " (2)")
        try FileManager.default.createDirectory(at: second, withIntermediateDirectories: true)
        #expect(LibraryHandOff.availableFolderURL(in: dir, now: now).lastPathComponent
            == LibraryHandOff.folderName(on: now) + " (3)")
    }
}
