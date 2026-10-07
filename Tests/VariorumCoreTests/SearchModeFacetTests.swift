//
//  SearchModeFacetTests.swift
//  VariorumCoreTests
//
//  13o U3, P3 — THE MODE FACETS (the 13i sitting record §12 item 2: *"mode
//  facets as search filters — gathering · living · owned · finished · sealed
//  (facts on the row, NEVER tags)"*): one AST leaf, `.bookState`, composed in
//  the one composer over the READING row a book or chapter hit names — so a
//  facet narrows the answer to books (a note carries no reading row; the
//  mirror of an armed day, PROVISIONAL P-13o-U3-3) — and over the
//  association's candidates at reading level.
//

import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

private func parse(_ text: String, visibility: SearchVisibility = .living, filter: SearchFilter? = nil) -> SearchQuery {
    var query = SearchQueryParser.parse(text, typeAhead: true, visibility: visibility, locale: Locale(identifier: "en_US"))
    if let filter { query.filter = query.filter.map { .all([$0, filter]) } ?? filter }
    return query
}

/// The books a question's book and chapter hits name (every page).
private func books(
    _ db: AppDatabase, _ text: String, _ state: SearchBookState?, visibility: SearchVisibility = .living
) throws -> Set<String> {
    try db.read { db in
        var ids: Set<String> = []
        var cursor: SearchComposer.Cursor?
        repeat {
            let page = try Queries.searchPassages(
                db, query: parse(text, visibility: visibility, filter: state.map { .bookState($0) }),
                scope: SearchScope(wingID: ""), after: cursor, limit: 100)
            ids.formUnion(page.passages.compactMap(\.readingID))
            cursor = page.next
        } while cursor != nil
        return ids
    }
}

private struct Shelf {
    let plain: Reading, gathering: Reading, living: Reading, owned: Reading
    let finished: Reading, sealed: Reading, archivedLiving: Reading
    let note: Container
}

/// One book per state, every name saying "harbor", and a note that does too.
private func shelf(_ ops: Operations) throws -> Shelf {
    let tag = try ops.createTag(name: "sea")
    let spec = try RuleGrammar.encode(.tag(tag.id))
    let plain = try ops.createReading(name: "Harbor plain", kind: .book)
    let gathering = try ops.createReading(name: "Harbor gathering", kind: .gathering, querySpec: spec)
    let living = try ops.createReading(name: "Harbor living", kind: .book, querySpec: spec)
    let owned = try ops.createReading(name: "Harbor owned", kind: .book)
    _ = try ops.setReadingOwned(owned.id, owned: true)
    let finished = try ops.createReading(name: "Harbor finished", kind: .book)
    try ops.lockReading(finished.id)
    let sealed = try ops.createReading(name: "Harbor sealed", kind: .book)
    _ = try ops.sealReading(sealed.id)
    let archivedLiving = try ops.createReading(name: "Harbor archived living", kind: .book, querySpec: spec)
    try ops.archiveReading(archivedLiving.id)
    let note = try ops.createPost(title: "Harbor note")
    return Shelf(plain: plain, gathering: gathering, living: living, owned: owned,
                 finished: finished, sealed: sealed, archivedLiving: archivedLiving, note: note)
}

@Suite("13o U3 — the mode facets")
struct SearchModeFacetTests {
    @Test func eachFacetNarrowsTheBooksToTheFactOnTheirRow() throws {
        try withOperations { ops, db in
            let s = try shelf(ops)
            #expect(try books(db, "harbor", nil)
                    == [s.plain.id, s.gathering.id, s.living.id, s.owned.id, s.finished.id, s.sealed.id],
                    "control: every living-corpus book (the archived one behind the facet)")
            #expect(try books(db, "harbor", .gathering) == [s.gathering.id])
            #expect(try books(db, "harbor", .living) == [s.living.id],
                    "a book whose intake is on — not the gathering, not the rule-less, not the archived")
            #expect(try books(db, "harbor", .owned) == [s.owned.id])
            #expect(try books(db, "harbor", .finished) == [s.finished.id, s.sealed.id],
                    "sealed is finished too (the census's own reading)")
            #expect(try books(db, "harbor", .sealed) == [s.sealed.id])
            #expect(try books(db, "harbor", .living, visibility: .includingArchived) == [s.living.id],
                    "an ARCHIVED book's intake is paused — never living, even under the archived facet")
            #expect(try books(db, "harbor", .finished, visibility: .includingArchived)
                    == [s.finished.id, s.sealed.id])
        }
    }

    @Test func aFacetNarrowsTheAnswerToBooksAndAChapterWearsItsBook() throws {
        try withOperations { ops, db in
            let s = try shelf(ops)
            let chapter = try ops.createSection(in: s.owned.id, name: "Harbor chapter")
            let page = try db.read { db in
                try Queries.searchPassages(
                    db, query: parse("harbor", filter: .bookState(.owned)), scope: SearchScope(wingID: ""))
            }
            #expect(page.passages.allSatisfy { $0.family == .books }, "no note, no scrap — books only")
            #expect(Set(page.passages.map(\.sourceID)) == [s.owned.id, chapter.id],
                    "the owned book's name and its chapter's")
            let counts = try #require(try db.read { db in
                try Queries.searchCounts(
                    db, query: parse("harbor", filter: .bookState(.owned)), scope: SearchScope(wingID: ""))
            })
            #expect(counts.living == .init(books: 1, notes: 0, passages: 0, scraps: 0))
            #expect(try db.read { db in
                try Queries.searchGroups(
                    db, query: parse("harbor", filter: .bookState(.owned)), scope: SearchScope(wingID: ""))
            }.groups.isEmpty, "the answer sheet's note groups empty under a facet")
        }
    }

    @Test func aFacetNarrowsTheTagAssociationToo() throws {
        try withOperations { ops, db in
            let dream = try ops.createTag(name: "dream")
            let spec = try RuleGrammar.encode(.tag(dream.id))
            let living = try ops.createReading(name: "Dream journal", kind: .book, querySpec: spec)
            let gathering = try ops.createReading(name: "All dreams", kind: .gathering, querySpec: spec)
            let finished = try ops.createReading(name: "Dream year", kind: .book, querySpec: spec)
            try ops.lockReading(finished.id)
            func associated(_ state: SearchBookState?) throws -> [String] {
                try db.read { db in
                    try Queries.searchTagAssociations(
                        db, query: parse("#dream", filter: state.map { .bookState($0) }),
                        scope: SearchScope(wingID: ""))
                }.map(\.readingID)
            }
            #expect(try associated(nil) == [gathering.id, living.id, finished.id])
            #expect(try associated(.living) == [living.id])
            #expect(try associated(.gathering) == [gathering.id])
            #expect(try associated(.finished) == [finished.id], "a finished book's rule still names where dream flowed")
            #expect(try associated(.sealed).isEmpty)
        }
    }

    @Test func theLivingFacetIsIntakesOwnPredicate() throws {
        // Every (kind × finished × archived × rule) cell against the census's
        // rule with intake's archived pause — the one SQL home cannot drift
        // from the Swift reading it states.
        try withOperations { ops, db in
            let tag = try ops.createTag(name: "sea")
            let spec = try RuleGrammar.encode(.tag(tag.id))
            var expected: Set<String> = []
            var n = 0
            for kind in [ReadingKind.book, .gathering] {
                for finished in [false, true] where !(kind == .gathering && finished) {
                    for archived in [false, true] {
                        for hasRule in [false, true] where !(kind == .gathering && !hasRule) {
                            n += 1
                            let reading = try ops.createReading(
                                name: "Harbor \(n)", kind: kind, querySpec: hasRule ? spec : nil)
                            if finished { try ops.lockReading(reading.id) }
                            if archived { try ops.archiveReading(reading.id) }
                            if kind == .book, !finished, !archived, hasRule { expected.insert(reading.id) }
                        }
                    }
                }
            }
            #expect(try books(db, "harbor", .living, visibility: .includingArchived) == expected)
            #expect(expected.count == 1)
        }
    }

    @Test func aFacetKeepsThePageDrivenByTheIndex() throws {
        let db = try AppDatabase.inMemory()
        let plan: String = try db.read { db in
            let environment = try Queries.searchEnvironment(db)
            let statement = try #require(try SearchComposer.passages(
                parse("harbor lights", filter: .bookState(.living)), scope: SearchScope(wingID: ""),
                after: nil, limit: 50, environment: environment))
            return try Row.fetchAll(db, sql: "EXPLAIN QUERY PLAN " + statement.sql,
                                    arguments: Queries.arguments(statement.arguments))
                .map { $0["detail"] as String }.joined(separator: "\n")
        }
        #expect(plan.contains("SCAN search_fts VIRTUAL TABLE INDEX"), "the FTS index drives:\n\(plan)")
        for alias in ["d", "pl", "c", "b", "r", "reading"] {
            #expect(!plan.split(separator: "\n").contains { $0 == "SCAN \(alias)" || $0.hasPrefix("SCAN \(alias) ") },
                    "SCAN \(alias) is a corpus walk:\n\(plan)")
        }
    }
}
