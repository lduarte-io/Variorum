//
//  CopyCountsAndRestoreListTests.swift
//  VariorumTests — VX-524 (rides VX-1013 — `notes/plans/fixes/vx-1013-open-far-folder-wait.md` MEMBERS): Settings ▸ Data
//  Safety's header said "5 copies" while its Restore list showed six rows, one backup listed twice (VX-510's walk, W-8).
//  Two readers over one catalogue: the counts (`ProtectionCopyCounts.read` → `OwnCopies.summary`, one per place — the
//  "Beside your library" row and the picked folder's row) and the Restore list (`ProtectionCopyDoors.listing` →
//  `CopyDoorsListing`, every catalogued copy of the open library, every place).
//
//  THE CONFIRM, pin first (the hallucination guard's speculative arm — the ticket's evidence is Suspected): W-8's scene
//  replayed on a planted road through the REAL pair road, lister and readers — the day's first pair lands beside the
//  library AND in the picked folder (the far leg: one a day there), a second Back Up Now the same day lands beside the
//  library only. The pin asserts what a counting or listing defect would break: every row of the open library's list is
//  ONE physical copy, counted by exactly one place's count, and the rows number the two counts' sum. The record carries
//  the run and what it showed.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-524 — Data Safety's counts and its Restore list read one catalogue", .serialized)
@MainActor
struct CopyCountsAndRestoreListTests {
    @Test func everyRestoreRowIsOneCopyCountedByExactlyOnePlace() async throws {
        let road = PlantedRoad(farFolder: true)
        let (session, _) = try await road.created()
        let libraryID = FarPlant.libraryID(session), deviceID = FarPlant.deviceID(session)
        let now = Date()
        // The day's first pair: beside the library and, the picked folder being due, its copy there (the far leg).
        let first = ProtectionBackupHook.takePairReporting(session, now: now)
        #expect(first.pair == .written)
        guard case .written? = first.far else {
            Issue.record("the day's first pair lands in the picked folder too — \(String(describing: first.far))")
            return
        }
        // A second Back Up Now the same day: beside the library only (one a day goes to the picked folder).
        let second = ProtectionBackupHook.takePairReporting(session, now: now)
        #expect(second.pair == .written)
        #expect(second.far == .notDue, "\(String(describing: second.far))")

        let counts = ProtectionCopyCounts.read(session, now: now.addingTimeInterval(60))
        let listing = ProtectionCopyDoors.listing(session)
        let rows = listing.thisLibrary

        // The two counts — the "Beside your library" row and the picked folder's row.
        #expect(counts.container.count == 2, "beside the library: \(counts.container)")
        #expect(counts.far.count == 1, "the picked folder: \(counts.far)")

        // THE AGREEMENT A DEFECT WOULD BREAK: no copy rowed twice, every row counted by exactly one place, the rows the
        // counts' sum.
        let ids = rows.map(\.id)
        #expect(Set(ids).count == ids.count, "no copy rowed twice: \(ids)")
        let catalog = session.system.lister.catalog()
        let counted = OwnCopies.of(catalog, libraryID: libraryID, thisMac: deviceID, in: .container)
            + OwnCopies.of(catalog, libraryID: libraryID, thisMac: deviceID, in: .farFolder)
        #expect(Set(ids) == Set(counted.map(\.id)), "every row counted, every counted copy rowed")
        #expect(rows.count == counts.container.count + counts.far.count,
                "rows \(rows.count) = beside the library \(counts.container.count) + the picked folder \(counts.far.count)")

        // W-8's shape, as it reads on the face: the first pair's stamp is TWO rows — the pair beside the library and its
        // copy in the picked folder, two physical copies — and a row carries its day and kind, never its place.
        let firstStem = try #require(first.snapshotName)
        let sameDay = rows.filter { $0.copy.name == firstStem }
        #expect(sameDay.count == 2, "the first pair rowed once per place: \(sameDay.map(\.id))")
        #expect(Set(sameDay.map(\.copy.place)) == [.container, .farFolder])
        #expect(Set(sameDay.map(\.asOf)).count == 1, "both rows read the same day and time")
        #expect(Set(sameDay.map { ProtectionWords.copyKind($0.kind) }) == ["Backup"], "and the same kind")
    }

    /// THE RULING'S PIN (R-1013-A3, PROVISIONAL P-1013-5 — option (a)): each Restore-list row's second line names where
    /// the copy sits, in Data Safety's own words. The same scene: the pair standing in both places is two rows with two
    /// different place lines; the pair beside the library only says so. RED BEFORE THE RULING: the line was the kind
    /// alone ("Backup"), so the two rows of one pair read identically.
    @Test func eachRestoreRowSaysWhereItsCopySits() async throws {
        let road = PlantedRoad(farFolder: true)
        let (session, _) = try await road.created()
        let now = Date()
        let first = ProtectionBackupHook.takePairReporting(session, now: now)
        guard case .written? = first.far else {
            Issue.record("the day's first pair lands in the picked folder too — \(String(describing: first.far))")
            return
        }
        let second = ProtectionBackupHook.takePairReporting(session, now: now)
        #expect(second.far == .notDue)
        let rows = ProtectionCopyDoors.listing(session).thisLibrary
        func line(_ row: CopyDoorRow) -> String { ProtectionWords.copyRowLine(kind: row.kind, place: row.copy.place) }

        let firstStem = try #require(first.snapshotName)
        let bothPlaces = rows.filter { $0.copy.name == firstStem }
        #expect(bothPlaces.count == 2)
        #expect(Set(bothPlaces.map(line)) == ["Backup · beside your library", "Backup · in your backup folder"],
                "the pair in both places, one line per place: \(bothPlaces.map(line))")

        let secondStem = try #require(second.snapshotName)
        let besideOnly = rows.filter { $0.copy.name == secondStem }
        #expect(besideOnly.map(line) == ["Backup · beside your library"],
                "the pair beside the library only: \(besideOnly.map(line))")
    }
}
