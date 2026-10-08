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

    // MARK: - 13s-b U1b piece 5 — the birth furniture joins the fold

    private func mintAndJudgeBirthFurniture(
        seed: UInt64
    ) async throws -> (readme: SeededFurnitureClassifier.Verdict,
                       scrap: SeededFurnitureClassifier.Verdict) {
        try await withSeedWorld(seed: seed) { session, db in
            guard case .seeded = await ExampleSnippetSeeder.seedAtBirth(session: session) else {
                throw ChapterWorldError.seedRefused("example snippet")
            }
            guard case .seeded(let readmeID) = await ReadmeSeeder.seedAtBirth(session: session) else {
                throw ChapterWorldError.seedRefused("readme")
            }
            return try await db.read { db in
                let scrapID = try String.fetchOne(
                    db,
                    sql: "SELECT id FROM container WHERE kind = 'pool' AND title = ? AND deleted_at IS NULL",
                    arguments: [ExampleSnippetSeeder.groupTitle])
                let scrap = try scrapID.map {
                    try SeededFurnitureClassifier.noteVerdict(
                        db, postID: $0, within: nil, seedTagPaths: [], hash: BridgeHash.body(_:))
                } ?? .straggling
                let readme = try SeededFurnitureClassifier.noteVerdict(
                    db, postID: readmeID, within: nil, seedTagPaths: [], hash: BridgeHash.body(_:))
                return (readme, scrap)
            }
        }
    }

    /// **The REAL-SEED drift guard for the 13s-b birth furniture** (the
    /// BLOCKER-1 net's shape exactly): the shipped readme — five blocks,
    /// two of them fanned — and the example snippet group, each minted by
    /// their real seeders, classify FOLDABLE, and two fresh mints carry
    /// EQUAL signatures, or a fresh install's sign-in keeps two of each
    /// forever. RED ON OLD by construction (the old tree seeds neither);
    /// the per-fact behavioural revert at the stage window is the WIRING
    /// pin below (drop a fact and the engine never looks at the title).
    @Test func theRealReadmeAndExampleSnippetAreFoldableAndTwoMintsAgree() async throws {
        let first = try await mintAndJudgeBirthFurniture(seed: 1886)
        let second = try await mintAndJudgeBirthFurniture(seed: 1892)

        guard case .foldable(let readmeA) = first.readme,
              case .foldable(let readmeB) = second.readme
        else {
            Issue.record("the shipped readme must classify FOLDABLE: \(String(describing: first.readme)) / \(String(describing: second.readme))")
            return
        }
        #expect(readmeA == readmeB, "two fresh readme mints are the SAME seed — they must fold")

        guard case .foldable(let scrapA) = first.scrap,
              case .foldable(let scrapB) = second.scrap
        else {
            Issue.record("the shipped example group must classify FOLDABLE: \(String(describing: first.scrap)) / \(String(describing: second.scrap))")
            return
        }
        #expect(scrapA == scrapB)
    }

    /// **The WIRING pin (per changed fact — the stage window's behavioural
    /// revert target):** the Mac's ONE composed facts value carries every
    /// seeded object of the final set — the guide + its pool and twin, the
    /// readme, the example group — AND keeps the installed base's and the
    /// still-mintable objects' facts (the three gatherings with their
    /// shapes, the reserved quicknote): Quicknotes still mints at first
    /// capture, the classics gathering behind its door, and stores born
    /// before this build carry the rest, so their pairs must keep folding.
    @Test func theMacFactsCarryTheFinalSetAndKeepTheInstalledBases() {
        let facts = MacFurnitureFacts.compose()
        #expect(facts.guideBookName == TutorialSeeder.bookName)
        #expect(facts.guideTagPath == TutorialSeeder.tagName)
        let containers = facts.containers.map { ($0.title, $0.kind) }
        #expect(containers.contains { $0 == (TutorialSeeder.scrapPoolTitle, "pool") })
        #expect(containers.contains { $0 == (TutorialSeeder.twinTitle, "post") })
        #expect(containers.contains { $0 == (ReadmeSeeder.title, "post") },
                "the readme folds on sign-in (R-13s-5's release constraint)")
        #expect(containers.contains { $0 == (ExampleSnippetSeeder.groupTitle, "pool") },
                "the example snippet group folds on sign-in")
        #expect(containers.contains { $0 == (SampleLibraryWelcome.quicknoteTitle, "post") },
                "the installed base's seeded quicknote keeps folding")
        let gatherings = facts.gatherings.map(\.name)
        #expect(gatherings.contains(SampleLibraryWelcome.classicsGatheringName))
        #expect(gatherings.contains(Operations.starredNotesGatheringName))
        #expect(gatherings.contains(Operations.defaultQuicknoteBookName))
    }
}

private enum ChapterWorldError: Error { case seedRefused(String) }
