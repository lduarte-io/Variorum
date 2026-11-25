//
//  SearchChapterHitsTests.swift
//  VariorumCoreTests
//
//  VX-1074 (the VX-1082 run, batch S; `notes/plans/fixes/vx-1082-nov-24-fixes.md`)
//  — a chapter found by its own name is its OWN row in the Library answer's
//  Books section, not its book's. The app's section reads the chapters a page
//  names through ONE core read, `Queries.searchChapterHits`; these pin its
//  contract (a build pin for the new read — the bug row's red-on-old is the
//  app's `SearchChapterRowsTests`): the live chapters of live BOOKS, by id, in
//  the order asked, the name exactly as stored, the book's archived fact
//  carried; a deleted chapter, a dead book's chapter and a gathering's stray
//  row answer nothing (its book's own row stands for it — P-2: a gathering's
//  Outline has no chapter to land on). And the premise the build stands on:
//  the chapter's NAME is a hit whose `sourceID` names the chapter.
//

import Foundation
import GRDB
import Testing

@testable import VariorumCore

@Suite("VX-1074 — the chapters a search lists by their own row")
struct SearchChapterHitsTests {
    @Test func aChapterNameIsAHitThatNamesTheChapter() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "Video ideas", kind: .book)
            let chapter = try ops.createSection(in: book.id, name: "Oct 9 batch (V01\u{2013}V49)")
            let asked = SearchQueryParser.parse(
                "oct 9 batch", typeAhead: true, visibility: .living, locale: Locale(identifier: "en_US"))
            let passages = try db.read { db in
                try Queries.searchPassages(db, query: asked, scope: SearchScope(wingID: "")).passages
            }
            #expect(passages.map(\.kind) == [.chapter], "the one hit is the chapter's name: \(passages.map(\.kind))")
            #expect(passages.first?.sourceID == chapter.id && passages.first?.readingID == book.id)
        }
    }

    @Test func itAnswersLiveChaptersOfLiveBooksInTheOrderAsked() throws {
        try withOperations { ops, db in
            let video = try ops.createReading(name: "Video ideas", kind: .book)
            let first = try ops.createSection(in: video.id, name: "Oct 9 batch (V01\u{2013}V49)")
            let second = try ops.createSection(in: video.id, name: "Oct 16 batch")
            let shelved = try ops.createReading(name: "Kept", kind: .book)
            let archivedChapter = try ops.createSection(in: shelved.id, name: "Old batch")
            try ops.archiveReading(shelved.id)
            let hits = try db.read { db in
                try Queries.searchChapterHits(db, ids: [second.id, archivedChapter.id, first.id, "no-such-chapter"])
            }
            #expect(hits == [
                SearchChapterHit(sectionID: second.id, name: "Oct 16 batch", readingID: video.id,
                                 readingName: "Video ideas", isArchived: false),
                SearchChapterHit(sectionID: archivedChapter.id, name: "Old batch", readingID: shelved.id,
                                 readingName: "Kept", isArchived: true),
                SearchChapterHit(sectionID: first.id, name: "Oct 9 batch (V01\u{2013}V49)", readingID: video.id,
                                 readingName: "Video ideas", isArchived: false),
            ], "in the order asked, names exact, the archived book's fact carried")
            #expect(try db.read { try Queries.searchChapterHits($0, ids: []) }.isEmpty)
        }
    }

    @Test func aDeletedChapterADeadBookAndAGatheringsStrayRowAnswerNothing() throws {
        try withOperations { ops, db in
            let video = try ops.createReading(name: "Video ideas", kind: .book)
            let deleted = try ops.createSection(in: video.id, name: "Gone batch")
            try ops.deleteSection(deleted.id)
            let doomed = try ops.createReading(name: "Doomed", kind: .book)
            let orphan = try ops.createSection(in: doomed.id, name: "Orphan batch")
            _ = try ops.deleteReading(doomed.id)
            // A gathering refuses sections; a stray row can only arrive by
            // sync or an un-bind — written here by hand.
            let tag = try ops.createTag(name: "flora")
            let rule = try #require(try RuleGrammar.encode(.tag(tag.id)))
            let gathering = try ops.createReading(name: "Flora", kind: .gathering, querySpec: rule)
            try db.write { db in
                try db.execute(
                    sql: """
                        INSERT INTO reading_section (id, reading_id, name, position, created_at, updated_at)
                        VALUES ('stray-section', ?, 'Stray batch', 'a0', '2026-11-25T00:00:00.000Z', '2026-11-25T00:00:00.000Z')
                        """,
                    arguments: [gathering.id])
            }
            let hits = try db.read { db in
                try Queries.searchChapterHits(db, ids: [deleted.id, orphan.id, "stray-section"])
            }
            #expect(hits.isEmpty, "none of the three is a chapter the Books section can land on: \(hits)")
        }
    }
}
