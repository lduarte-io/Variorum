//
//  JournalSegmentationClearingTests.swift
//  VariorumTests
//
//  VX-799 (the VX-805 run, Unit A) — the OCCASION of the journal entries'
//  one_block clearing pass (`JournalSegmentationClearing`), driven through
//  the production composition (`LaunchFurniture.seed`, the very function the
//  window task calls) and directly for each gate arm. The pass's own row
//  transition is pinned headlessly in the core
//  (`JournalSegmentationTests.theClearingPassTouchesExactlyLiveJournalOneBlockRows`).
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withClearingWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_950_400)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 799))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        // Never the test host's defaults (the test host IS the Debug app's domain).
        session.seededBookMarkIsSet = { _ in false }
        session.markSeededBook = { _ in }
        return try await body(session, db)
    }
}

/// A pre-VX-799 journal entry: the override the retired mint seed stamped.
@MainActor
private func legacyJournalEntry(_ session: AppSession, day: String) async throws -> String {
    try await session.runner.run { ops in
        let entry = try ops.createOrOpenJournalEntry(entryDate: day).container
        try ops.setSegmentationDefault(entry.id, segmentation: .oneBlock)
        return entry.id
    }
}

private func stored(_ db: AppDatabase, _ id: String) async throws -> String? {
    try await db.read { db in
        try String.fetchOne(
            db, sql: "SELECT segmentation_default FROM container WHERE id = ?", arguments: [id])
    }
}

@MainActor
private final class Mark {
    var settled = false
    var load: () -> Bool { { [self] in settled } }
    var save: (Bool) -> Void { { [self] in settled = $0 } }
}

/// One device's launch marks, defaults-free (the `LaunchFurnitureTests` shape).
@MainActor
private final class Device {
    var books: [String: Bool] = [:]
    var starred = false
    var welcome: String?
    let journal = Mark()

    var marks: LaunchFurniture.Marks {
        LaunchFurniture.Marks(
            book: { [self] book in
                (load: { self.books[book.name] ?? false },
                 save: { self.books[book.name] = $0 })
            },
            starred: (load: { [self] in starred }, save: { [self] in starred = $0 }),
            welcome: (load: { [self] in welcome }, save: { [self] in welcome = $0 }),
            journalSegmentation: (load: journal.load, save: journal.save))
    }
}

private func gate(account: Bool, clean: Bool) -> SampleLibrarySeeder.SyncGate {
    SampleLibrarySeeder.SyncGate(belongsToAnAccount: { account }, hasSyncedCleanly: { clean })
}

@MainActor
@Suite("VX-799 — the journal one_block clearing occasion")
struct JournalSegmentationClearingTests {
    /// THE PRODUCTION COMPOSITION: a launch clears an existing entry's stored
    /// override (silently — nothing spoken, nothing on ⌥⌘Z) and does NOT yet
    /// mark the store settled; the next launch finds nothing and settles it.
    /// RED ON OLD: nothing on the launch path cleared the override.
    @Test func aLaunchClearsTheOverrideAndTheNextSettles() async throws {
        try await withClearingWorld { session, db in
            let entry = try await legacyJournalEntry(session, day: "2026-07-01")
            let device = Device()
            let marks = device.marks
            let mark = device.journal

            _ = await LaunchFurniture.seed(
                session: session, storeVariant: .dev,
                gate: gate(account: false, clean: true), marks: marks)
            #expect(try await stored(db, entry) == nil, "the stored one_block is cleared")
            #expect(!mark.settled, "a pass that cleared rows does not settle")
            #expect(session.status.spoken == nil, "a store pass never speaks")
            #expect(session.undoStack.depth == 0, "nothing lands on her ⌥⌘Z")

            _ = await LaunchFurniture.seed(
                session: session, storeVariant: .dev,
                gate: gate(account: false, clean: true), marks: marks)
            #expect(mark.settled, "the next launch finds nothing and settles")
        }
    }

    /// Each arm of the occasion, directly: the account gate declines while the
    /// first clean round is pending (nothing written, nothing marked); a pass
    /// that clears reports its count unmarked; an empty pass settles; a
    /// settled store is never asked again — even when an override reappears
    /// (the named residual: a row synced in later from an older build).
    @Test func theOccasionsArms() async throws {
        try await withClearingWorld { session, db in
            let first = try await legacyJournalEntry(session, day: "2026-07-01")
            let second = try await legacyJournalEntry(session, day: "2026-07-02")
            let mark = Mark()

            let pending = await JournalSegmentationClearing.runIfNeeded(
                session: session, storeVariant: .dev,
                gate: gate(account: true, clean: false), firstRoundWait: .milliseconds(30),
                pollInterval: .milliseconds(10), loadMark: mark.load, saveMark: mark.save)
            #expect(pending == .awaitingFirstSync)
            #expect(try await stored(db, first) == "one_block", "nothing written ahead of the corpus")
            #expect(!mark.settled)

            let cleared = await JournalSegmentationClearing.runIfNeeded(
                session: session, storeVariant: .dev, gate: gate(account: true, clean: true),
                loadMark: mark.load, saveMark: mark.save)
            #expect(cleared == .cleared(2))
            #expect(try await stored(db, first) == nil)
            #expect(try await stored(db, second) == nil)
            #expect(!mark.settled)

            let settled = await JournalSegmentationClearing.runIfNeeded(
                session: session, storeVariant: .dev, gate: .unowned,
                loadMark: mark.load, saveMark: mark.save)
            #expect(settled == .settled)
            #expect(mark.settled)

            let reappeared = try await legacyJournalEntry(session, day: "2026-07-03")
            let again = await JournalSegmentationClearing.runIfNeeded(
                session: session, storeVariant: .dev, gate: .unowned,
                loadMark: mark.load, saveMark: mark.save)
            #expect(again == .alreadySettled)
            #expect(try await stored(db, reappeared) == "one_block", "a settled device never re-asks")
        }
    }

    /// The mark is per store variant, like every seeded mark.
    @Test func theMarkIsScopedByStoreVariant() {
        #expect(JournalSegmentationClearing.settledDefaultsKey(for: .real)
                != JournalSegmentationClearing.settledDefaultsKey(for: .dev))
    }
}
