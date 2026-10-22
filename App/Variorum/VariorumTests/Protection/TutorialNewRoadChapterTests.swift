//
//  TutorialNewRoadChapterTests.swift
//  VariorumTests
//
//  VX-309 U2 piece 7 — THE FIELD GUIDE'S PROTECTION CHAPTER ON THE NEW ROAD (VX-379's acceptance; QUESTIONS #235:
//  "written here"; the brief is §5d of notes/plans/vx-309-copies-and-words.md, the record its U2 RECORD). The guide's
//  "keeping it private" chapter is re-seeded against the rules AS BUILT — three lessons, the first LEADING with the
//  readme's four Start Here passages verbatim. VX-329 U1 — THE RELEASE SWITCH: the road is the only road, so EVERY store
//  (the dev store and the real store's variant alike — the dev-store fence dissolved) seeds this chapter; copy §7's
//  chapter and VX-209's older-copy warning left with today's road. The words themselves are pinned headless by
//  `U2WordsTests`; this suite pins the SEED: the book's shape against `plan`, every paragraph landed, the export
//  lesson's backup paragraphs, on both variants.
//
//  RED ON OLD (behavioural reverts, recorded in the VX-309 U2 RECORD): R-U2-7-gate / R-U2-7-seed (the dev-store pins);
//  the flip's own red is the real variant's arm — before VX-329 the fence kept today's chapter there.
//  Mac-only (the seeder is the Mac's): run on the stage — headless runs never reach it.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore

@testable import Variorum

/// A store with the field guide seeded through the restore road, for a session over the given store variant.
@MainActor
private func withGuide<T>(
    variant: AppDatabase.StoreVariant,
    _ body: @MainActor (AppDatabase, _ guideID: String) async throws -> T
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 309))
    } operation: { @MainActor in
        let session = AppSession(database: db, storeVariant: variant)
        // The seeded-book marks are injected (never a store's defaults).
        session.seededBookMarkIsSet = { _ in false }
        session.markSeededBook = { _ in }
        let guideID = try await TutorialSeeder.restore(session: session)
        return try await body(db, guideID)
    }
}

private struct SeededLesson: Equatable {
    let title: String
    let chapter: String?
    let text: String
}

/// Every lesson in book order: title, chapter, and its whole stored text.
private func lessons(_ db: AppDatabase, _ guideID: String) async throws -> [SeededLesson] {
    try await db.read { db in
        let rows = try Row.fetchAll(
            db,
            sql: """
                SELECT c.id AS id, c.title AS title, rs.name AS chapter FROM reading_post rp
                JOIN container c ON c.id = rp.post_id AND c.deleted_at IS NULL
                LEFT JOIN reading_section rs ON rs.id = rp.section_id AND rs.deleted_at IS NULL
                WHERE rp.reading_id = ? AND rp.deleted_at IS NULL
                ORDER BY rp.position, rp.id
                """,
            arguments: [guideID])
        return try rows.map { row in
            SeededLesson(title: row["title"], chapter: row["chapter"],
                         text: try Queries.renderedText(db, containerID: row["id"]))
        }
    }
}

@MainActor
@Suite("VX-309 U2 — the field guide's protection chapter (VX-329: every store's)", .serialized)
struct TutorialNewRoadChapterTests {
    private static let privacy = "keeping it private"

    /// The road's three lesson titles are the privacy chapter's; copy §7's titles are in no chapter.
    @Test func thePlansPrivacyChapterIsTheRoads() {
        let plan = TutorialSeeder.plan
        #expect(plan.first { $0.chapter == Self.privacy }?.lessons == [
            ProtectionWords.guideKeyLessonTitle, ProtectionWords.guidePosturesLessonTitle,
            ProtectionWords.guideCopiesLessonTitle,
        ])
        #expect(!plan.flatMap(\.lessons).contains(ProtectionCopy.privacyLessonOneTitle), "copy §7's chapter left")
        #expect(Set(plan.map(\.chapter)).count == plan.count, "each chapter once")
    }

    /// Every store's guide — the dev store's and the real store's variant alike — matches the plan exactly, and the
    /// chapter says every paragraph — lesson 1 LEADING with the readme's Start Here passages.
    @Test(arguments: [AppDatabase.StoreVariant.dev, .real])
    func everyStoresGuideSeedsTheRoadsChapter(_ variant: AppDatabase.StoreVariant) async throws {
        try await withGuide(variant: variant) { db, guideID in
            let seeded = try await lessons(db, guideID)
            let planned = TutorialSeeder.plan.flatMap { chapter, lessons in
                lessons.map { (title: $0, chapter: chapter) }
            }
            #expect(seeded.count == planned.count, "every lesson is in the book exactly once")
            for (row, plan) in zip(seeded, planned) {
                #expect(row.title == plan.title && row.chapter == plan.chapter, "\(plan.title) sits in \(plan.chapter)")
            }
            let byTitle = Dictionary(seeded.map { ($0.title, $0.text) }, uniquingKeysWith: { first, _ in first })
            let key = try #require(byTitle[ProtectionWords.guideKeyLessonTitle])
            #expect(key.hasPrefix(ReadmeSeeder.startHerePassages[0]), "lesson 1 LEADS with the Start Here passages")
            for passage in ReadmeSeeder.startHerePassages {
                #expect(key.contains(passage), "verbatim — one text, two homes: \(passage.prefix(40))")
            }
            #expect(key.contains(ProtectionWords.guideSyncSentence + " " + ProtectionCopy.privacyServerSeesShapeSentence))
            #expect(key.contains(ProtectionCopy.keystoneAccountPassword) && key.contains(ProtectionWords.guideOpenMeansReadable))
            let postures = try #require(byTitle[ProtectionWords.guidePosturesLessonTitle])
            for paragraph in ProtectionWords.guidePosturesLesson { #expect(postures.contains(paragraph)) }
            let copies = try #require(byTitle[ProtectionWords.guideCopiesLessonTitle])
            for paragraph in ProtectionWords.guideCopiesLesson { #expect(copies.contains(paragraph)) }

            let book = seeded.map(\.text).joined(separator: "\n")
            #expect(book.contains(ProtectionWords.guideBackupsHappen), "the export lesson: a backup is a pair")
            #expect(book.contains(ProtectionWords.guideSecondFolderLead + " Settings \u{25B8} "
                                  + "\(SettingsPane.dataSafety.title)"), "the second folder's lead, then the door")
            #expect(!book.contains("copies your whole library into a backups folder"), "today's backup words are gone")
            #expect(!seeded.contains { $0.title == ProtectionCopy.privacyLessonOneTitle })
        }
    }
}
