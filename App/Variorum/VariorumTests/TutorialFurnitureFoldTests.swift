//
//  TutorialFurnitureFoldTests.swift
//  VariorumTests
//
//  17y B-DEDUPE, the ladder's BLOCKER-1 pin — **the REAL-SEED drift guard**
//  (the `theShippedSeedSatisfiesTheDedupesPristineContract` precedent): the
//  SHIPPED field guide, minted by the real `TutorialSeeder`, must classify
//  FOLDABLE under the furniture fold's real classifier — and two fresh
//  mints must carry EQUAL signatures, or her Monday fresh-install sign-in
//  keeps two guides forever. RED ON OLD: the shipped mint's word target,
//  its seed-authored comment and its sealed lesson each read ENGAGED, so
//  every real guide was unfoldable while the synthetic suite stayed green.
//  Any future seed-content change that trips a NEW engagement leg turns
//  this red at the next test run — the drift net the round-1 BLOCKER
//  demanded. (Round-2 caveat, recorded: the two mints here share UUID
//  sequences and clocks — id/timestamp EXCLUSION from the signature is
//  carried by the core two-client fold test's distinct prefixes and clock
//  offset, never by this guard alone.)
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore

@testable import Variorum

@MainActor
private func withSeedWorld<T: Sendable>(
    seed: UInt64, _ body: @MainActor (AppSession, AppDatabase) async throws -> T
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: seed))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        session.seededBookMarkIsSet = { _ in false }
        session.markSeededBook = { _ in }
        return try await body(session, db)
    }
}

private struct SeededVerdicts: Sendable {
    var guide: SeededFurnitureClassifier.Verdict
    var pool: SeededFurnitureClassifier.Verdict
    var twin: SeededFurnitureClassifier.Verdict?
}

@MainActor
@Suite("The shipped guide satisfies the pairwise fold (17y B-DEDUPE, BLOCKER-1's net)")
struct TutorialFurnitureFoldTests {

    private func mintAndJudge(seed: UInt64) async throws -> SeededVerdicts {
        try await withSeedWorld(seed: seed) { session, db in
            let guideID = try await TutorialSeeder.restore(session: session)
            return try await db.read { db in
                let guide = try SeededFurnitureClassifier.guideVerdict(
                    db, copyID: guideID, tagPath: TutorialSeeder.tagName,
                    hash: BridgeHash.body(_:))
                let poolID = try String.fetchOne(
                    db,
                    sql: "SELECT id FROM container WHERE kind = 'pool' AND title = ? AND deleted_at IS NULL",
                    arguments: [TutorialSeeder.scrapPoolTitle])
                let pool = try poolID.map {
                    try SeededFurnitureClassifier.noteVerdict(
                        db, postID: $0, within: nil,
                        seedTagPaths: [TutorialSeeder.tagName], hash: BridgeHash.body(_:))
                } ?? .straggling
                // The twin folds at container grain only when BOOKLESS; a
                // membered twin rides the book grain. Judge whichever
                // shape ships.
                let twinID = try String.fetchOne(
                    db,
                    sql: """
                        SELECT c.id FROM container c
                        WHERE c.title = ? AND c.deleted_at IS NULL
                          AND NOT EXISTS (SELECT 1 FROM reading_post rp
                                          WHERE rp.post_id = c.id AND rp.deleted_at IS NULL)
                        """,
                    arguments: [TutorialSeeder.twinTitle])
                let twin = try twinID.map {
                    try SeededFurnitureClassifier.noteVerdict(
                        db, postID: $0, within: nil,
                        seedTagPaths: [TutorialSeeder.tagName], hash: BridgeHash.body(_:))
                }
                return SeededVerdicts(guide: guide, pool: pool, twin: twin)
            }
        }
    }

    @Test func theRealGuidePoolAndTwinAreFoldableAndTwoMintsAgree() async throws {
        let first = try await mintAndJudge(seed: 1886)
        let second = try await mintAndJudge(seed: 1892)

        guard case .foldable(let guideSigA) = first.guide,
              case .foldable(let guideSigB) = second.guide
        else {
            Issue.record("""
                the SHIPPED guide must classify FOLDABLE on a fresh store — \
                an engaged/straggling verdict means her Monday sign-in keeps \
                two guides forever (got \(String(describing: first.guide)) / \
                \(String(describing: second.guide)))
                """)
            return
        }
        #expect(guideSigA == guideSigB, "two fresh mints are the SAME seed — they must fold")

        guard case .foldable(let poolSigA) = first.pool,
              case .foldable(let poolSigB) = second.pool
        else {
            Issue.record("the shipped scraps pool must classify FOLDABLE: \(String(describing: first.pool)) / \(String(describing: second.pool))")
            return
        }
        #expect(poolSigA == poolSigB)

        // The twin, in whichever grain it ships.
        switch (first.twin, second.twin) {
        case (nil, nil):
            break  // membered — it rides the guide's own fold above
        case (.some(.foldable(let a)), .some(.foldable(let b))):
            #expect(a == b)
        default:
            Issue.record("the twin's verdicts disagree or read engaged: \(String(describing: first.twin)) / \(String(describing: second.twin))")
        }
    }
}
