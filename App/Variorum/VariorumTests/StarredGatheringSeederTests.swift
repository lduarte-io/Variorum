//
//  StarredGatheringSeederTests.swift
//  VariorumTests
//
//  13i-b U4 — the starred-notes gathering's OCCASION (P-13ib-4): once per store
//  per device, behind the sync gate, silent. The core op's own rules are pinned
//  in `StarredNotesGatheringTests`; these pin what the app adds — the mark and
//  the gate — with injected marks, so no pin ever touches this machine's
//  defaults.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withSeederWorld<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 1661))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

private final class Mark {
    var value = false
    var load: () -> Bool { { [self] in value } }
    var save: (Bool) -> Void { { [self] in value = $0 } }
}

@MainActor
@Suite("13i-b U4 — the starred-notes gathering's occasion (P-13ib-4)")
struct StarredGatheringSeederTests {
    private func liveGatherings(_ db: AppDatabase) async throws -> [Reading] {
        try await db.read { try Queries.readings($0) }
    }

    @Test func anUnmarkedStoreIsSeededAndMarked() async throws {
        try await withSeederWorld { session, db in
            let mark = Mark()
            let outcome = await StarredGatheringSeeder.seedIfNeeded(
                session: session, loadMark: mark.load, saveMark: mark.save)
            guard case .ensured(.minted(let id)) = outcome else {
                Issue.record("expected a mint, got \(outcome)")
                return
            }
            #expect(mark.value)
            let rows = try await liveGatherings(db)
            #expect(rows.map(\.id) == [id])
            #expect(rows.first?.name == Operations.starredNotesGatheringName)
            #expect(rows.first?.shelfId == nil)
        }
    }

    @Test func aMarkedStoreIsNeverAskedAgainEvenAfterAPurge() async throws {
        try await withSeederWorld { session, db in
            let mark = Mark()
            mark.value = true
            // No row, no tombstone (the state a purged deletion leaves): the
            // MARK is the evidence, and it holds.
            let outcome = await StarredGatheringSeeder.seedIfNeeded(
                session: session, loadMark: mark.load, saveMark: mark.save)
            #expect(outcome == .alreadySeeded)
            let rows = try await liveGatherings(db)
            #expect(rows.isEmpty)
        }
    }

    @Test func herDeletionIsRecordedInTheMark() async throws {
        try await withSeederWorld { session, db in
            let gathering = try await session.runner.run { ops in
                try ops.createReading(
                    name: Operations.starredNotesGatheringName, kind: .gathering,
                    querySpec: try RuleGrammar.encode(.star))
            }
            try await session.runner.run { ops in try ops.deleteReading(gathering.id) }
            let mark = Mark()
            let outcome = await StarredGatheringSeeder.seedIfNeeded(
                session: session, loadMark: mark.load, saveMark: mark.save)
            #expect(outcome == .ensured(.deletedByTheReader))
            #expect(mark.value, "the decision is remembered past a purge")
            let rows = try await liveGatherings(db)
            #expect(rows.isEmpty)
        }
    }

    @Test func anAccountStoreWaitsForItsFirstCleanRoundAndIsNotMarked() async throws {
        try await withSeederWorld { session, db in
            let mark = Mark()
            let outcome = await StarredGatheringSeeder.seedIfNeeded(
                session: session,
                gate: SampleLibrarySeeder.SyncGate(
                    belongsToAnAccount: { true }, hasSyncedCleanly: { false }),
                firstRoundWait: .milliseconds(50), pollInterval: .milliseconds(10),
                loadMark: mark.load, saveMark: mark.save)
            #expect(outcome == .awaitingFirstSync)
            #expect(mark.value == false, "declining is free — the next launch asks again")
            let rows = try await liveGatherings(db)
            #expect(rows.isEmpty)
        }
    }

    @Test func anAccountStoreThatHasSyncedIsSeeded() async throws {
        try await withSeederWorld { session, db in
            let mark = Mark()
            let outcome = await StarredGatheringSeeder.seedIfNeeded(
                session: session,
                gate: SampleLibrarySeeder.SyncGate(
                    belongsToAnAccount: { true }, hasSyncedCleanly: { true }),
                loadMark: mark.load, saveMark: mark.save)
            guard case .ensured(.minted) = outcome else {
                Issue.record("expected a mint, got \(outcome)")
                return
            }
            #expect(mark.value)
            let rows = try await liveGatherings(db)
            #expect(rows.count == 1)
        }
    }

    @Test func theMarkIsScopedByStoreVariant() {
        #expect(StarredGatheringSeeder.seededDefaultsKey(for: .dev)
                != StarredGatheringSeeder.seededDefaultsKey(for: .real))
    }
}
