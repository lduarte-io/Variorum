//
//  SearchTagAssociationTests.swift
//  VariorumCoreTests
//
//  13o U3, P2 — THE TAG-ASSOCIATION JOIN (the 13i sitting record §12 item 1,
//  her ruling: *"a book can have a tag association already so it does not
//  need its own tag — the tags that it gives its writing is enough"*): a
//  typed `#tag` surfaces the books and gatherings associated with it through
//  their intake rule (the tag FLOWS there) or their outflow (their writing
//  CARRIES it), ranked ahead of every name hit, each saying why. The pure
//  decision (`SearchTagAssociation`) cell for cell; the read
//  (`Queries.searchTagAssociations`) end to end; the band's counts.
//

import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

private func rule(_ term: RuleTerm) throws -> String? { try RuleGrammar.encode(term) }

private func parse(_ text: String, visibility: SearchVisibility = .living, filter: SearchFilter? = nil) -> SearchQuery {
    var query = SearchQueryParser.parse(text, typeAhead: true, visibility: visibility, locale: Locale(identifier: "en_US"))
    if let filter { query.filter = query.filter.map { .all([$0, filter]) } ?? filter }
    return query
}

private func associations(
    _ db: AppDatabase, _ text: String, wing: String = "", visibility: SearchVisibility = .living,
    filter: SearchFilter? = nil
) throws -> [SearchTagAssociation.Association] {
    try db.read { db in
        try Queries.searchTagAssociations(
            db, query: parse(text, visibility: visibility, filter: filter), scope: SearchScope(wingID: wing))
    }
}

@Suite("13o U3 — the tag-association join")
struct SearchTagAssociationTests {
    // MARK: - The pure decision

    @Test func theTypedTagsAreThePositiveTagPathLeavesInTypedOrder() {
        #expect(SearchTagAssociation.typedPaths(of: nil).isEmpty)
        #expect(SearchTagAssociation.typedPaths(of: .tagPath("dream")) == ["dream"])
        #expect(SearchTagAssociation.typedPaths(of: .all([.tagPath("dream"), .tagPath("life/goals"), .tagPath("Dream")]))
                == ["dream", "life/goals"], "in the order typed, once each, case-insensitively")
        #expect(SearchTagAssociation.typedPaths(of: .all([.not(.tagPath("dream")), .tagPath("work")])) == ["work"],
                "a negated tag names no association")
        #expect(SearchTagAssociation.typedPaths(of: .not(.not(.tagPath("dream")))) == ["dream"], "parity, not presence")
        #expect(SearchTagAssociation.typedPaths(of: .all([.tag(id: "t1"), .starred, .family(.notes)])).isEmpty,
                "a tag by id is programmatic, never typed")
    }

    @Test func theDecisionRanksFlowsBeforeOutflowsAndExactBeforeAncestor() throws {
        let paths = ["t-dream": "dream", "t-life": "life", "t-goals": "life/goals", "t-lucid": "dream/lucid",
                     "t-other": "other"]
        func candidate(_ id: String, _ name: String, rule term: RuleTerm? = nil, outflow: [String] = [],
                       archived: Bool = false) throws -> SearchTagAssociation.Candidate {
            .init(readingID: id, name: name, ruleSpec: try term.flatMap(rule), outflowTagIDs: outflow,
                  isArchived: archived)
        }
        let candidates = try [
            candidate("r1", "Zed exact", rule: .tag("t-dream")),
            candidate("r2", "An outflow", outflow: ["t-lucid"]),
            candidate("r3", "Ancestor", rule: .tag("t-life")),
            candidate("r4", "Excluder", rule: .and([.tag("t-other"), .not(.tag("t-dream"))])),
            candidate("r5", "Dead term", rule: .tag("t-gone")),
            candidate("r6", "Narrower rule", rule: .tag("t-lucid")),
            candidate("r7", "Broader outflow", outflow: ["t-life"]),
            candidate("r8", "Book 10", rule: .or([.tag("t-other"), .tag("t-dream")])),
            candidate("r9", "Book 9", rule: .tag("t-dream")),
        ]
        let dream = SearchTagAssociation.associate(candidates: candidates, typedPaths: ["dream"], tagPaths: paths)
        #expect(dream.map(\.readingID) == ["r9", "r8", "r1", "r2"],
                "the rules naming #dream (digit-aware by name), then the outflow carrying dream/lucid")
        #expect(dream.first?.reason == .flowsIn(path: "dream"))
        #expect(dream.last?.reason == .taggedHere(path: "dream/lucid"), "the outflow names its own tag")

        let goals = SearchTagAssociation.associate(candidates: candidates, typedPaths: ["life/goals"], tagPaths: paths)
        #expect(goals.map(\.readingID) == ["r3"], "life/goals FLOWS INTO a #life rule (intake hears the subtree)")
        #expect(goals.first?.reason == .flowsIn(path: "life/goals"))
        #expect(!goals.contains { $0.readingID == "r7" },
                "an outflow BROADER than the typed tag is not among its results (the query's own subtree rule)")

        let lucid = SearchTagAssociation.associate(candidates: candidates, typedPaths: ["dream/lucid"], tagPaths: paths)
        #expect(lucid.map(\.readingID) == ["r6", "r9", "r8", "r1", "r2"],
                "the exact rule first, then the ancestor rules (dream/lucid flows into #dream), then the outflow")
        #expect(!lucid.contains { $0.readingID == "r4" }, "NOT #dream is never where dream flows")
        #expect(SearchTagAssociation.associate(candidates: candidates, typedPaths: [], tagPaths: paths).isEmpty)
    }

    @Test func aNoRuleOrMalformedRuleAssociatesNothingByItsRule() {
        let paths = ["t": "dream"]
        let none = SearchTagAssociation.Candidate(
            readingID: "a", name: "a", ruleSpec: nil, outflowTagIDs: [], isArchived: false)
        let broken = SearchTagAssociation.Candidate(
            readingID: "b", name: "b", ruleSpec: "{not json", outflowTagIDs: [], isArchived: false)
        #expect(SearchTagAssociation.associate(candidates: [none, broken], typedPaths: ["dream"], tagPaths: paths).isEmpty)
    }

    // MARK: - The read, end to end

    @Test func aTypedTagSurfacesTheBooksAndGatheringsItIsAssociatedWith() throws {
        try withOperations { ops, db in
            let dream = try ops.createTag(name: "dream")
            let lucid = try ops.createTag(parent: dream.id, name: "lucid")
            let other = try ops.createTag(name: "other")
            let living = try ops.createReading(name: "Dream journal", kind: .book, querySpec: rule(.tag(dream.id)))
            let gathering = try ops.createReading(name: "All dreams", kind: .gathering, querySpec: rule(.tag(dream.id)))
            let outflow = try ops.createReading(name: "Lucid log", kind: .book, autoTagIDs: [lucid.id])
            let excluder = try ops.createReading(
                name: "Waking", kind: .book, querySpec: rule(.and([.tag(other.id), .not(.tag(dream.id))])))
            let plain = try ops.createReading(name: "Dreamless plain book", kind: .book)
            let archived = try ops.createReading(name: "Old dreams", kind: .book, querySpec: rule(.tag(dream.id)))
            try ops.archiveReading(archived.id)

            let found = try associations(db, "#dream")
            #expect(found.map(\.readingID) == [gathering.id, living.id, outflow.id],
                    "the flows by name, then the outflow; never the excluder, the plain book or the archived one")
            #expect(found.map(\.reason) == [.flowsIn(path: "dream"), .flowsIn(path: "dream"),
                                            .taggedHere(path: "dream/lucid")])
            #expect(!found.contains { [excluder.id, plain.id, archived.id].contains($0.readingID) })

            #expect(try associations(db, "#DREAM").map(\.readingID) == found.map(\.readingID),
                    "a typed path matches its tag case-insensitively")
            #expect(try associations(db, "words #dream").map(\.readingID) == found.map(\.readingID),
                    "words never narrow the association — the tag is its key")
            #expect(try associations(db, "dream").isEmpty, "a WORD is not a tag")
            #expect(try associations(db, "#nosuchtag").isEmpty)

            let withArchive = try associations(db, "#dream", visibility: .includingArchived)
            #expect(withArchive.contains { $0.readingID == archived.id && $0.isArchived },
                    "the archived facet adds the archived book, marked")
            #expect(try associations(db, "#dream", filter: .family(.notes)).isEmpty,
                    "a notes-only question surfaces no book")
            #expect(try associations(db, "#dream", filter: .family(.books)).count == 3)
        }
    }

    @Test func theAssociationNeverCrossesWings() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Quarantine")
            let home = try ops.createTag(name: "dream")
            let away = try ops.createTag(name: "dream", wingID: wing.id)
            let homeBook = try ops.createReading(name: "Home dreams", kind: .book, querySpec: rule(.tag(home.id)))
            let awayBook = try ops.createReading(
                name: "Away dreams", kind: .book, querySpec: rule(.tag(away.id)), wingId: wing.id)
            #expect(try associations(db, "#dream").map(\.readingID) == [homeBook.id])
            #expect(try associations(db, "#dream", wing: wing.id).map(\.readingID) == [awayBook.id])
        }
    }

    @Test func theBandCountsTheAssociatedBooksWithWordsAndWithout() throws {
        try withOperations { ops, db in
            let dream = try ops.createTag(name: "dream")
            _ = try ops.createReading(name: "Dream journal", kind: .book, querySpec: rule(.tag(dream.id)))
            let archived = try ops.createReading(name: "Old dreams", kind: .book, querySpec: rule(.tag(dream.id)))
            try ops.archiveReading(archived.id)
            let note = try ops.createPost(title: "Night")
            _ = try ops.newBlock(in: note.id, text: "a dream of the harbor")
            _ = try ops.applyTag(dream.id, toPost: note.id)

            let alone = try #require(try db.read { db in
                try Queries.searchCounts(db, query: parse("#dream"), scope: SearchScope(wingID: ""))
            }, "a typed tag ALONE now answers: its associated books")
            // JUSTIFIED EDIT (VX-84a, the 13o follow-up run): this cell read
            // `notes: 0` under P-13o-U2-6 ("a tag alone answers with its books
            // only"); her report superseded it ("searching a tag is not
            // revealing the notes tagged that at all" — D-1: a tag alone
            // narrows the Library), so the tagged note COUNTS beside its book.
            #expect(alone.living == .init(books: 1, notes: 1, passages: 0, scraps: 0))
            #expect(alone.all.books == 2 && alone.archivedPlaces == 1)

            let worded = try #require(try db.read { db in
                try Queries.searchCounts(db, query: parse("harbor #dream"), scope: SearchScope(wingID: ""))
            })
            #expect(worded.living == .init(books: 1, notes: 1, passages: 1, scraps: 0),
                    "the associated book counts beside the tagged note's passage")
            #expect(worded.all.books == 2 && worded.archivedPlaces == 1)

            #expect(try db.read { db in
                try Queries.searchCounts(db, query: parse("#nosuchtag"), scope: SearchScope(wingID: ""))
            } == nil, "no words, no worn day, no association — no numbers")
        }
    }

    @Test func theCandidatesStatementWalksOnlyTheWingsReadings() throws {
        let db = try AppDatabase.inMemory()
        let plan: String = try db.read { db in
            let environment = try Queries.searchEnvironment(db)
            let statement = try #require(SearchComposer.associationCandidates(
                parse("#dream"), scope: SearchScope(wingID: ""), environment: environment))
            return try Row.fetchAll(db, sql: "EXPLAIN QUERY PLAN " + statement.sql,
                                    arguments: Queries.arguments(statement.arguments))
                .map { $0["detail"] as String }.joined(separator: "\n")
        }
        for table in ["container", "variant", "block", "search_fts", "post_tag"] {
            #expect(!plan.contains(table), "the candidates read readings only:\n\(plan)")
        }
        #expect(try db.read { db in
            SearchComposer.associationCandidates(
                parse("#dream"), scope: SearchScope(wingID: "", within: .book(id: "x")),
                environment: try Queries.searchEnvironment(db))
        } == nil, "a book's own search has no association")
    }
}
