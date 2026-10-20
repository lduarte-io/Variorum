//
//  TutorialNewRoadChapterTests.swift
//  VariorumTests
//
//  VX-309 U2 piece 7 — THE FIELD GUIDE'S PROTECTION CHAPTER ON THE NEW ROAD (VX-379's acceptance; QUESTIONS #235:
//  "written here"; the brief is §5d of notes/plans/vx-309-copies-and-words.md, the record its U2 RECORD). The guide's
//  "keeping it private" chapter is re-seeded against the rules AS BUILT — three lessons, the first LEADING with the
//  readme's four Start Here passages verbatim — and seeded ONLY where the store opens on the new road (the readme's own
//  gate, `ProtectionRoad.opensOnTheNewRoad(devStore:)`; VX-306 ladder r2 m2). Today's road, Release included, keeps
//  copy §7's chapter (VX-209's older-copy warning with it) until the switch (VX-329). The words themselves are pinned
//  headless by `U2WordsTests`; this suite pins the SEED: the book's shape against `plan(onTheNewRoad:)`, every paragraph
//  landed, the export lesson's backup paragraphs, and the gate both ways.
//
//  RED ON OLD (behavioural reverts, recorded in the U2 RECORD):
//    · R-U2-7-gate — `restore` seeds with `onTheNewRoad: false` whatever the variant: the dev-store pins go red;
//    · R-U2-7-seed — the seed ignores `onTheNewRoad` (today's chapter always): the dev-store pins go red;
//    · R-U2-7-fence — the gate drops the dev-store fence (`newRoadIsLive` alone): the real-store pin goes red.
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
@Suite("VX-309 U2 — the field guide's protection chapter on the new road", .serialized)
struct TutorialNewRoadChapterTests {
    private static let privacy = "keeping it private"

    /// The new road's three lesson titles stand in for copy §7's two; every other chapter is untouched.
    @Test func theNewRoadsPlanSwapsOnlyThePrivacyChapter() {
        let today = TutorialSeeder.plan(onTheNewRoad: false)
        let newRoad = TutorialSeeder.plan(onTheNewRoad: true)
        #expect(today.map(\.chapter) == TutorialSeeder.plan.map(\.chapter)
                && today.map(\.lessons) == TutorialSeeder.plan.map(\.lessons), "today's plan is the plan")
        #expect(newRoad.map(\.chapter) == today.map(\.chapter), "the same chapters, in the same order")
        for (new, old) in zip(newRoad, today) where new.chapter != Self.privacy {
            #expect(new.lessons == old.lessons, "\(new.chapter) is untouched")
        }
        #expect(newRoad.first { $0.chapter == Self.privacy }?.lessons == [
            ProtectionWords.guideKeyLessonTitle, ProtectionWords.guidePosturesLessonTitle,
            ProtectionWords.guideCopiesLessonTitle,
        ])
        #expect(today.first { $0.chapter == Self.privacy }?.lessons == [
            ProtectionCopy.privacyLessonOneTitle, ProtectionCopy.privacyLessonTwoTitle,
        ])
    }

    /// The dev store in this (Debug) build opens on the new road: the seeded book matches the new road's plan exactly, and
    /// the chapter says every paragraph — lesson 1 LEADING with the readme's Start Here passages.
    @Test func theDevStoresGuideSeedsTheNewRoadsChapter() async throws {
        try #require(ProtectionRoad.opensOnTheNewRoad(devStore: true), "a Debug test host: the dev store's road is new")
        try await withGuide(variant: .dev) { db, guideID in
            let seeded = try await lessons(db, guideID)
            let planned = TutorialSeeder.plan(onTheNewRoad: true).flatMap { chapter, lessons in
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
            #expect(!book.contains("copies your whole library into a backups folder"), "today's backup words retire here")
            #expect(!book.contains(ProtectionCopy.privacyOlderCopyParagraph), "VX-209's warning retires on this road")
            #expect(!seeded.contains { $0.title == ProtectionCopy.privacyLessonOneTitle
                                       || $0.title == ProtectionCopy.privacyLessonTwoTitle })
        }
    }

    /// A store of the REAL variant keeps today's road even in a Debug build (the dev-store fence): copy §7's chapter, the
    /// older-copy warning, today's backup words — and none of the new road's.
    @Test func theRealStoresGuideKeepsTodaysChapter() async throws {
        try #require(!ProtectionRoad.opensOnTheNewRoad(devStore: false))
        try await withGuide(variant: .real) { db, guideID in
            let seeded = try await lessons(db, guideID)
            #expect(seeded.map(\.title) == TutorialSeeder.plan.flatMap(\.lessons), "today's plan, exactly")
            let book = seeded.map(\.text).joined(separator: "\n")
            #expect(book.contains(ProtectionCopy.privacyOlderCopyParagraph))
            #expect(book.contains("copies your whole library into a backups folder"))
            for absent in [ProtectionWords.guideBackupsHappen, ProtectionWords.guideSecondFolderLead,
                           ProtectionWords.guideOpenMeansReadable, ReadmeSeeder.startHerePassages[0]]
                + ProtectionWords.guidePosturesLesson + ProtectionWords.guideCopiesLesson {
                #expect(!book.contains(absent), "the new road's words stay off today's road: \(absent.prefix(40))")
            }
        }
    }
}
