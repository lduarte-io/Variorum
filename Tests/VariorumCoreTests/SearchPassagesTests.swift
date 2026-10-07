//
//  SearchPassagesTests.swift
//  VariorumCoreTests
//
//  13o U1, P7 — the one Domain composer (`SearchComposer`) and
//  `Queries.searchPassages`: ranking (kind weight + the rendered-take boost),
//  snippets, WING ISOLATION, the within-scopes, the archived facet and the
//  version fence, the filter half, keyset paging with a road to everything
//  (R-13o-9), the worn-day arm (R-13o-6), FTS5-syntax safety, and the
//  composed statements' plans.
//

import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

private var utc: Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    return calendar
}

private func search(
    _ db: AppDatabase, _ text: String, wing: String = "", within: SearchScope.Within = .library,
    visibility: SearchVisibility = .living, filter: SearchFilter? = nil,
    after: SearchComposer.Cursor? = nil, limit: Int = 50
) throws -> SearchPage {
    var query = SearchQueryParser.parse(text, typeAhead: true, visibility: visibility,
                                        locale: Locale(identifier: "en_US"), calendar: utc)
    if let filter {
        query.filter = query.filter.map { .all([$0, filter]) } ?? filter
    }
    return try db.read { db in
        try Queries.searchPassages(
            db, query: query, scope: SearchScope(wingID: wing, within: within),
            after: after, limit: limit, calendar: utc)
    }
}

private func ids(_ page: SearchPage) -> [String] { page.passages.map(\.id) }

@Suite("13o — the composer and searchPassages")
struct SearchPassagesTests {
    // MARK: - Ranking, snippets, kinds

    @Test func namesOutrankProseAndTheRenderedTakeOutranksItsSiblings() throws {
        try withOperations { ops, db in
            let named = try ops.createPost(title: "Harbor")
            let prose = try ops.createPost(title: "Elsewhere")
            let minted = try ops.newBlock(in: prose.id, text: "we walked along the harbor at night")
            let sibling = try ops.branchVariant(minted.block.id, from: minted.variant.id)

            let page = try search(db, "harbor ")
            #expect(page.passages.first?.id == "title:\(named.id)", "a title outranks prose (kind weight)")
            let takes = page.passages.filter { $0.kind == .take }
            #expect(takes.map(\.sourceID) == [minted.variant.id, sibling.id],
                    "both live takes are found, the RENDERED one first")
            #expect(takes.map(\.isRenderedTake) == [true, false])

            try ops.chooseVariant(minted.block.id, variantID: sibling.id)
            let after = try search(db, "harbor ").passages.filter { $0.kind == .take }
            #expect(after.map(\.sourceID) == [sibling.id, minted.variant.id], "the boost follows the choice")
            #expect(after.map(\.isRenderedTake) == [true, false])
            #expect(after.allSatisfy { $0.noteID == prose.id && $0.blockID == minted.block.id && $0.homeTitle == "Elsewhere" })
        }
    }

    @Test func snippetsFlagTheMatchedWords() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "Notes")
            _ = try ops.newBlock(in: post.id, text: "The Café on the corner was naïve and bright.")
            let hit = try #require(try search(db, "cafe naive ").passages.first)
            #expect(hit.snippet.filter(\.isMatch).map(\.text) == ["Café", "naïve"],
                    "the index's own folding decides the highlight (one sameness rule)")
            #expect(hit.snippet.map(\.text).joined() == "The Café on the corner was naïve and bright.")
        }
    }

    @Test func everyKindIsFoundWithItsHome() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "Zephyr Title")
            try ops.updateFloatingNotes(post.id, notes: "zephyr margin")
            let minted = try ops.newBlock(in: post.id, text: "zephyr prose")
            try ops.setBlockName(minted.block.id, name: "zephyr name")
            try ops.setTakeLabel(minted.variant.id, label: "zephyr label")
            let comment = try ops.addBlockComment(to: minted.block.id, text: "zephyr comment")
            let book = try ops.createReading(name: "Zephyr Book", kind: .book)
            let chapter = try ops.createSection(in: book.id, name: "Zephyr Chapter")
            let pool = try ops.createPool(title: "Scrap heap")
            let scrap = try ops.newBlock(in: pool.id, text: "zephyr scrap")

            let page = try search(db, "zephyr ")
            let byKind = Dictionary(grouping: page.passages, by: \.kind)
            #expect(byKind[.title]?.first?.noteID == post.id)
            #expect(byKind[.noteMeta]?.first?.noteID == post.id)
            #expect(byKind[.blockName]?.first?.blockID == minted.block.id)
            #expect(byKind[.takeLabel]?.first?.sourceID == minted.variant.id)
            #expect(byKind[.comment]?.first?.sourceID == comment.id)
            #expect(byKind[.book]?.first?.readingID == book.id)
            #expect(byKind[.chapter]?.first?.readingID == book.id)
            #expect(byKind[.chapter]?.first?.homeTitle == "Zephyr Book")
            #expect(byKind[.chapter]?.first?.sourceID == chapter.id)
            let takes = byKind[.take] ?? []
            #expect(Set(takes.map(\.sourceID)) == [minted.variant.id, scrap.variant.id])
            #expect(takes.first { $0.sourceID == scrap.variant.id }?.family == .scraps,
                    "a take whose home is a pool is a SCRAP — the query-time facet (F2)")
            #expect(takes.first { $0.sourceID == minted.variant.id }?.family == .notes)
            #expect(byKind[.book]?.first?.family == .books)
            #expect(page.passages.count == 9)
        }
    }

    // MARK: - Wing isolation (the 13i sitting record §12 — "nothing should cross wings")

    @Test func searchScopesByWingPeriod() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Quarantine")
            let home = try ops.createPost(title: "Home Lantern")
            let away = try ops.createPost(title: "Away Lantern", wingId: wing.id)
            let awayBlock = try ops.newBlock(in: away.id, text: "lantern prose away")
            let awayBook = try ops.createReading(name: "Lantern Book", kind: .book, wingId: wing.id)
            let pool = try ops.createPool(title: "Lantern scraps")

            let fromHome = Set(ids(try search(db, "lantern ")))
            #expect(fromHome.contains("title:\(home.id)"))
            #expect(!fromHome.contains("title:\(away.id)") && !fromHome.contains("take:\(awayBlock.variant.id)")
                    && !fromHome.contains("book:\(awayBook.id)"), "another wing's words never cross")
            #expect(fromHome.contains("title:\(pool.id)"),
                    "the scraps area is one shared room (P-13id-U5-4, kept — PROVISIONAL P-13o-U1-5)")

            let fromAway = Set(ids(try search(db, "lantern ", wing: wing.id)))
            #expect(fromAway == ["title:\(away.id)", "take:\(awayBlock.variant.id)", "book:\(awayBook.id)", "title:\(pool.id)"])

            // A DANGLING wing pointer reads Home (the `wingScope` rule).
            try db.write { db in
                try db.execute(sql: "UPDATE container SET wing_id = 'gone-wing' WHERE id = ?", arguments: [home.id])
            }
            #expect(Set(ids(try search(db, "lantern "))).contains("title:\(home.id)"))
        }
    }

    // MARK: - Within a note / a book

    @Test func withinANoteAndWithinABook() throws {
        try withOperations { ops, db in
            let a = try ops.createPost(title: "Alpha Comet")
            let aBlock = try ops.newBlock(in: a.id, text: "comet over the bay")
            let b = try ops.createPost(title: "Beta")
            let bBlock = try ops.newBlock(in: b.id, text: "comet over the hills")
            let c = try ops.createPost(title: "Gamma")
            _ = try ops.newBlock(in: c.id, text: "comet unseen")
            let book = try ops.createReading(name: "Sky Book", kind: .book)
            let chapter = try ops.createSection(in: book.id, name: "Comet Chapter")
            _ = try ops.addPostToReading(a.id, to: book.id)
            _ = try ops.addPostToReading(b.id, to: book.id)

            #expect(Set(ids(try search(db, "comet ", within: .note(id: a.id))))
                    == ["title:\(a.id)", "take:\(aBlock.variant.id)"])
            #expect(Set(ids(try search(db, "comet ", within: .book(id: book.id))))
                    == ["title:\(a.id)", "take:\(aBlock.variant.id)", "take:\(bBlock.variant.id)",
                        "chapter:\(chapter.id)"],
                    "the book's member notes and its own chapters — never a non-member")
        }
    }

    // MARK: - The archived facet + the version fence + unplaced blocks

    @Test func archivedIsBehindTheFacetAndVersionsNeverList() throws {
        try withOperations { ops, db in
            let live = try ops.createPost(title: "Live Orchid")
            let stored = try ops.createPost(title: "Stored Orchid")
            let storedBlock = try ops.newBlock(in: stored.id, text: "orchid in a box")
            try ops.archiveContainer(stored.id)
            let liveBlock = try ops.newBlock(in: live.id, text: "orchid on the sill")
            let shelved = try ops.branchVariant(liveBlock.block.id, from: liveBlock.variant.id)
            try ops.archiveVariant(shelved.id)
            let version = try ops.saveNoteVersion(live.id)

            let living = Set(ids(try search(db, "orchid ")))
            #expect(living == ["title:\(live.id)", "take:\(liveBlock.variant.id)"],
                    "default = the living corpus only")

            let all = try search(db, "orchid ", visibility: .includingArchived)
            let allIDs = Set(ids(all))
            #expect(allIDs.isSuperset(of: living))
            #expect(allIDs.contains("title:\(stored.id)") && allIDs.contains("take:\(storedBlock.variant.id)")
                    && allIDs.contains("take:\(shelved.id)"))
            #expect(!all.passages.contains { $0.noteID == version.post.id },
                    "a saved version never lists — not even under the facet")
            #expect(all.passages.filter(\.isArchived).count == 3)

            let only = try search(db, "orchid ", visibility: .archivedOnly)
            #expect(Set(ids(only)) == ["title:\(stored.id)", "take:\(storedBlock.variant.id)", "take:\(shelved.id)"])
        }
    }

    @Test func aBlockWithNoLivePlacementHasNoHomeAndNoHit() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "x")
            let minted = try ops.newBlock(in: post.id, text: "released lineage words")
            try db.write { db in
                try db.execute(sql: "UPDATE container_block SET deleted_at = 'x' WHERE block_id = ?",
                               arguments: [minted.block.id])
            }
            #expect(try search(db, "lineage ").passages.isEmpty,
                    "a released block's takes stay indexed but have no home to land in (PROVISIONAL P-13o-U1-8)")
        }
    }

    // MARK: - The filter half

    @Test func tagStarDayAndFamilyFilters() throws {
        try withOperations { ops, db in
            let life = try ops.createTag(name: "life")
            let goals = try ops.createTag(parent: life.id, name: "goals")
            let tagged = try ops.createPost(title: "Tagged Tulip")
            let taggedBlock = try ops.newBlock(in: tagged.id, text: "tulip words")
            _ = try ops.applyTag(goals.id, toPost: tagged.id)
            let plain = try ops.createPost(title: "Plain Tulip")
            let plainBlock = try ops.newBlock(in: plain.id, text: "tulip again")
            let blockTagged = try ops.newBlock(in: plain.id, text: "tulip block tagged")
            _ = try ops.applyTag(life.id, toBlock: blockTagged.block.id)

            #expect(Set(ids(try search(db, "#life tulip "))) == [
                "title:\(tagged.id)", "take:\(taggedBlock.variant.id)", "take:\(blockTagged.variant.id)",
            ], "subtree: #life matches life/goals on the note, and life on a block")
            #expect(Set(ids(try search(db, "#LIFE/goals tulip "))) == ["title:\(tagged.id)", "take:\(taggedBlock.variant.id)"],
                    "case folds; the subtree root is the typed path")
            #expect(try search(db, "#nosuch tulip ").passages.isEmpty)

            try ops.setStarred(.post(plain.id), starred: true)
            #expect(Set(ids(try search(db, "tulip ", filter: .starred))) == [
                "title:\(plain.id)", "take:\(plainBlock.variant.id)", "take:\(blockTagged.variant.id)",
            ])
            #expect(Set(ids(try search(db, "tulip ", filter: .not(.starred)))) == ["title:\(tagged.id)", "take:\(taggedBlock.variant.id)"])

            let range = try #require(SearchDayRange(field: .created, firstDay: "2026-07-01", lastDay: "2026-07-01", calendar: utc))
            #expect(try search(db, "tulip ", filter: .days(range)).passages.count == 5, "every note was created on the clock's day")
            let other = try #require(SearchDayRange(field: .edited, firstDay: "2026-08-01", lastDay: "2026-08-03", calendar: utc))
            #expect(try search(db, "tulip ", filter: .days(other)).passages.isEmpty)
            let edited = try #require(SearchDayRange(field: .edited, firstDay: "2026-06-30", lastDay: "2026-07-02", calendar: utc))
            #expect(try search(db, "tulip ", filter: .days(edited)).passages.count == 5)

            let pool = try ops.createPool(title: "Tulip scraps")
            let book = try ops.createReading(name: "Tulip Book", kind: .book)
            #expect(Set(ids(try search(db, "tulip ", filter: .family(.scraps)))) == ["title:\(pool.id)"])
            #expect(Set(ids(try search(db, "tulip ", filter: .family(.books)))) == ["book:\(book.id)"])
            #expect(try search(db, "tulip ", filter: .family(.notes)).passages.count == 5)
        }
    }

    // MARK: - Paging — a road to everything (R-13o-9)

    @Test func everyMatchIsReachableByPagingAndNoneTwice() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "Many")
            var expected: Set<String> = ["title:\(post.id)"]
            for i in 0..<120 {
                let minted = try ops.newBlock(in: post.id, text: "many words \(i) \(String(repeating: "filler ", count: i % 7))")
                expected.insert("take:\(minted.variant.id)")
            }
            var seen: [String] = []
            var cursor: SearchComposer.Cursor?
            var pages = 0
            repeat {
                let page = try search(db, "many ", after: cursor, limit: 50)
                seen += ids(page)
                cursor = page.next
                pages += 1
            } while cursor != nil && pages < 10
            #expect(pages == 3, "50 + 50 + 21")
            #expect(seen.count == 121 && Set(seen) == expected, "every match, exactly once")
        }
    }

    // MARK: - The worn day (R-13o-6)

    @Test func aNamelessNoteIsFoundByTheDayItWears() throws {
        try withOperations { ops, db in
            let dated = try ops.createPost(entryDate: "2026-09-14")
            let lastYear = try ops.createPost(entryDate: "2025-09-14")
            let titled = try ops.createPost(title: "Named", entryDate: "2026-09-14")
            let other = try ops.createPost(entryDate: "2026-09-15")
            // Undated + nameless: wears its CREATED day (the clock's 2026-07-01).
            let undated = try ops.createPost()

            #expect(Set(ids(try search(db, "september 14"))) == ["worn_day:\(dated.id)", "worn_day:\(lastYear.id)"],
                    "a year-less day finds every year's — only nameless notes wear a date")
            #expect(ids(try search(db, "sep 14 2026")) == ["worn_day:\(dated.id)"])
            #expect(ids(try search(db, "9/14/25")) == ["worn_day:\(lastYear.id)"])
            #expect(ids(try search(db, "2026-09-15")) == ["worn_day:\(other.id)"])
            #expect(ids(try search(db, "july 1")) == ["worn_day:\(undated.id)"], "the undated note's created day")
            let first = try #require(try search(db, "september 14").passages.first)
            #expect(first.homeTitle == "2026-09-14" && first.snippet.isEmpty && first.kind == .wornDay)
            #expect(!ids(try search(db, "september 14")).contains("worn_day:\(titled.id)"))

            // The worn arm obeys the scope and the facet like every hit.
            let wing = try ops.createWing(name: "W")
            #expect(try search(db, "september 14", wing: wing.id).passages.isEmpty)
            try ops.archiveContainer(dated.id)
            #expect(ids(try search(db, "sep 14 2026")).isEmpty)
            #expect(ids(try search(db, "sep 14 2026", visibility: .includingArchived)) == ["worn_day:\(dated.id)"])
            // The worn arm leads the FIRST page only.
            let page = try search(db, "september 14", visibility: .includingArchived,
                                  after: SearchComposer.Cursor(score: -1e9, docID: 0))
            #expect(page.passages.allSatisfy { $0.kind != .wornDay })
        }
    }

    // MARK: - Type-ahead, folding, syntax safety

    @Test func typeAheadFoldingAndFTSSyntaxSafety() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "Résumé of the Café")
            #expect(ids(try search(db, "resu")) == ["title:\(post.id)"], "the trailing word is a prefix")
            #expect(ids(try search(db, "CAFE ")) == ["title:\(post.id)"])
            #expect(try search(db, "resu ").passages.isEmpty, "a finished word is exact")
            // FTS5 syntax in her text is only ever words.
            for hostile in ["cafe\" OR \"x", "NEAR(cafe resume)", "cafe AND", "cafe*", "\"cafe", "-cafe", "cafe:", "^cafe", "{cafe}"] {
                _ = try search(db, hostile)
            }
            #expect(try search(db, "— # …").passages.isEmpty, "punctuation-only words match nothing and never throw")
        }
    }

    // MARK: - The composer, pure

    @Test func theComposerQuotesEveryLeafAndRefusesNegationAlone() throws {
        #expect(try SearchComposer.ftsMatch(.word("a\"b")) == "\"a\"\"b\"")
        #expect(try SearchComposer.ftsMatch(.prefix("trav")) == "\"trav\" *")
        #expect(try SearchComposer.ftsMatch(.all([.word("a"), .phrase("b c")])) == "(\"a\" AND \"b c\")")
        #expect(try SearchComposer.ftsMatch(.any([.word("a"), .word("b")])) == "(\"a\" OR \"b\")")
        #expect(try SearchComposer.ftsMatch(.all([.word("a"), .not(.word("b"))])) == "(\"a\" NOT \"b\")")
        #expect(try SearchComposer.ftsMatch(.all([.word("—"), .word("a")])) == "\"a\"", "separator-only words drop")
        #expect(try SearchComposer.ftsMatch(.word("#")) == nil)
        #expect(throws: SearchComposer.Refusal.negativeOnlyText) { try SearchComposer.ftsMatch(.not(.word("a"))) }
        #expect(throws: SearchComposer.Refusal.negativeOnlyText) {
            try SearchComposer.ftsMatch(.all([.not(.word("a")), .not(.word("b"))]))
        }
        #expect(SearchComposer.snippetSegments("a \u{2}b\u{3} c") == [
            SearchSnippetSegment(text: "a ", isMatch: false), SearchSnippetSegment(text: "b", isMatch: true),
            SearchSnippetSegment(text: " c", isMatch: false),
        ])
        #expect(SearchComposer.hasTokenCharacter("$5") && SearchComposer.hasTokenCharacter("🙂"))
        // The edited-in-a-window rule ships ONCE: the shipped unqualified
        // clause is the aliased function's nil form, byte for byte.
        #expect(Queries.editedOnClause == """
            (
                 (COALESCE(last_touched_at, created_at) >= ?
                  AND COALESCE(last_touched_at, created_at) < ?)
              OR id IN (
                   SELECT cb.container_id FROM commit_point cp
                   JOIN variant v ON v.id = cp.variant_id
                   JOIN container_block cb ON cb.block_id = v.block_id
                    AND cb.deleted_at IS NULL
                   WHERE cp.created_at >= ? AND cp.created_at < ?)
            )
            """)
        #expect(Queries.editedOnSQL(alias: "c").contains("COALESCE(c.last_touched_at, c.created_at)")
                && Queries.editedOnSQL(alias: "c").contains("OR c.id IN ("))
        #expect(!SearchComposer.hasTokenCharacter("—…!?"))
    }

    // MARK: - The plans (EXPLAIN pins against the drift class)

    @Test func thePageStatementIsDrivenByTheIndexAndSeeksEveryHome() throws {
        let db = try AppDatabase.inMemory()
        let plan: [String] = try db.read { db in
            let environment = try Queries.searchEnvironment(db)
            var query = SearchQueryParser.parse("harbor lights", locale: Locale(identifier: "en_US"), calendar: utc)
            query.filter = .all([.tagPath("life"), .starred, .family(.notes)])
            let statement = try #require(try SearchComposer.passages(
                query, scope: SearchScope(wingID: "", within: .book(id: "bk")),
                after: SearchComposer.Cursor(score: -1, docID: 1), limit: 50, environment: environment))
            return try Row.fetchAll(
                db, sql: "EXPLAIN QUERY PLAN " + statement.sql,
                arguments: Queries.arguments(statement.arguments)).map { $0["detail"] as String }
        }
        let text = plan.joined(separator: "\n")
        #expect(text.contains("SCAN search_fts VIRTUAL TABLE INDEX"), "the FTS index drives:\n\(text)")
        for seek in ["SEARCH d USING INTEGER PRIMARY KEY",                  // the doc by rowid
                     "SEARCH pl USING INDEX uq_cblock_ownership (block_id=?)", // the home via I2
                     "SEARCH c USING INDEX sqlite_autoindex_container_1 (id=?)",
                     "SEARCH b USING INDEX sqlite_autoindex_block_1 (id=?)",
                     "SEARCH r USING INDEX sqlite_autoindex_reading_1 (id=?)",
                     "SEARCH rp USING INDEX idx_reading_post_order (reading_id=?)", // the book's members
                     "SEARCH pt USING INDEX idx_post_tag_tag (tag_id=?)",          // a tag's own applications
                     "SEARCH bt USING INDEX idx_block_tag_tag (tag_id=?)"] {
            #expect(text.contains(seek), "\(seek) — missing:\n\(text)")
        }
        #expect(text.contains("SEARCH applied USING INDEX uq_tag_path_live (wing_id=? AND path>? AND path<?)"),
                "the subtree is an index RANGE on the root's path:\n\(text)")
        // (A typed `#path` resolves its ROOT by a case-folded walk of the tag
        // VOCABULARY — `SCAN root USING INDEX uq_tag_path_live` — bounded by
        // her tag tree, never by what she wrote; an id-term is a PK seek.)
        for alias in ["d", "pl", "c", "b", "r", "pt", "bt", "applied", "search_doc", "container", "variant"] {
            #expect(!plan.contains { $0 == "SCAN \(alias)" || $0.hasPrefix("SCAN \(alias) ") },
                    "SCAN \(alias) is a corpus walk:\n\(text)")
        }
        // The snippet stage is driven by the PAGE rows, one FTS lookup each.
        let last = plan.suffix(2).joined(separator: "\n")
        #expect(last.contains("SCAN page") && last.contains("search_fts VIRTUAL TABLE INDEX"),
                "snippets are cut for the page rows only:\n\(text)")
    }

    @Test func theWornDayArmsSeekTheirIndexes() throws {
        let db = try AppDatabase.inMemory()
        let plans: [String] = try db.read { db in
            let environment = try Queries.searchEnvironment(db)
            let query = SearchQueryParser.parse("sep 14", locale: Locale(identifier: "en_US"), calendar: utc)
            let statements = SearchComposer.wornDay(
                query, scope: SearchScope(wingID: ""),
                dayKeys: ["2025-09-14", "2026-09-14"],
                createdWindows: [("2025-09-14T00:00:00.000Z", "2025-09-15T00:00:00.000Z"),
                                 ("2026-09-14T00:00:00.000Z", "2026-09-15T00:00:00.000Z")],
                environment: environment)
            #expect(statements.count == 2)
            return try statements.map { statement in
                try Row.fetchAll(db, sql: "EXPLAIN QUERY PLAN " + statement.sql,
                                 arguments: Queries.arguments(statement.arguments))
                    .map { $0["detail"] as String }.joined(separator: " | ")
            }
        }
        #expect(plans[0].contains("idx_container_entry_date"), "dated notes by their day key:\n\(plans[0])")
        #expect(plans[1].contains("SEARCH c USING INDEX idx_container_undated_created (created_at>? AND created_at<?)"),
                "undated notes by their day's window:\n\(plans[1])")
        #expect(!plans.joined().contains("SCAN c") && !plans.joined().contains("idx_container_kind"),
                "no walk of every note:\n\(plans)")
    }
}
