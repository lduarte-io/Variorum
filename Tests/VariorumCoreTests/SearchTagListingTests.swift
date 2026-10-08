//
//  SearchTagListingTests.swift
//  VariorumCoreTests
//
//  VX-84a (the 13o follow-up run, VX-83) — her report: *"classics are not
//  showing notes tagged classics, in fact searching a tag is not revealing the
//  notes tagged that at all."* The provisional call D-1: a `#tag` typed with
//  no words NARROWS THE LIBRARY like a day does — the catalog's own listing,
//  narrowed through the ONE composer's text-less road
//  (`SearchComposer.listingNarrowing`): the NOTES by post-level tags, the
//  BLOCKS (the Blocks scope) by block-level tags.
//
//  These are BUILD pins for a new road (the composer served no text-less
//  question, P-13o-U1-7): on the pre-fix tree they do not compile. The
//  BUG-CLASS red-on-old pin is the Mac state-transition pin
//  (`LibraryTagListingTests` — a tag alone listed no notes). The cells:
//  post-level · subtree · case · wing · tombstones · the archived facet and
//  the version fence · intersection · the sort and keyset · words close the
//  road · blocks by their own tags · the counts · and the SEAM's plan and
//  page-request measurement (the U-A record's §SEAM).
//

import Foundation
import GRDB
import SQLCipher
import Testing

@testable import VariorumCore

private func question(_ text: String, visibility: SearchVisibility = .living) -> SearchQuery {
    SearchQueryParser.parse(text, typeAhead: true, visibility: visibility, locale: Locale(identifier: "en_US"))
}

private func notes(
    _ db: AppDatabase, _ text: String, wing: String = "", visibility: SearchVisibility = .living,
    sort: Queries.LibrarySort = .title, direction: SortDirection = .asc,
    after cursor: Queries.CatalogCursor? = nil, limit: Int = 50
) throws -> Queries.CatalogNotesPage {
    try db.read { db in
        try Queries.catalogNotesPage(
            db, query: "", sort: sort, direction: direction, after: cursor, limit: limit,
            wingID: wing, narrowing: question(text, visibility: visibility))
    }
}

private func titles(_ page: Queries.CatalogNotesPage) -> [String] { page.hits.map(\.title) }

@Suite("VX-84a — the composer's text-less TAG road (a tag alone narrows the Library)")
struct SearchTagListingTests {
    /// Her shelf, the Mac pin's twin: #classics on two notes, its child
    /// #classics/doyle on a third (the SUBTREE), #other on a fourth, a fifth
    /// untagged; a twin #classics in a second WING on a sixth.
    private struct Shelf {
        let hound: Container, study: Container, sign: Container, other: Container, plain: Container
        let away: Container
        let classics: VariorumCore.Tag, doyle: VariorumCore.Tag, wing: Wing
    }

    private func shelf(_ ops: Operations) throws -> Shelf {
        let classics = try ops.createTag(name: "classics")
        let doyle = try ops.createTag(parent: classics.id, name: "doyle")
        let otherTag = try ops.createTag(name: "other")
        let wing = try ops.createWing(name: "Second")
        let twin = try ops.createTag(name: "classics", wingID: wing.id)
        func note(_ title: String, _ tag: VariorumCore.Tag?, wing: String = "") throws -> Container {
            let post = try ops.createPost(title: title, wingId: wing)
            _ = try ops.newBlock(in: post.id, text: "\(title) — its words")
            if let tag { _ = try ops.applyTag(tag.id, toPost: post.id) }
            return post
        }
        return Shelf(
            hound: try note("The Hound", classics), study: try note("A Study in Scarlet", classics),
            sign: try note("The Sign of Four", doyle), other: try note("Elsewhere", otherTag),
            plain: try note("Untagged", nil), away: try note("Away", twin, wing: wing.id),
            classics: classics, doyle: doyle, wing: wing)
    }

    // MARK: - Notes, post-level

    @Test func aTagAloneNamesItsNotesSubtreeIncludedInItsOwnWingOnly() throws {
        try withOperations { ops, db in
            _ = try shelf(ops)
            #expect(titles(try notes(db, "#classics")) == ["A Study in Scarlet", "The Hound", "The Sign of Four"],
                    "post-level, the subtree included, the sort's order")
            #expect(titles(try notes(db, "#CLASSICS")) == titles(try notes(db, "#classics")),
                    "a typed path matches case-insensitively (P-13o-U1-9)")
            #expect(titles(try notes(db, "#classics/doyle")) == ["The Sign of Four"], "a child names its own")
            #expect(titles(try notes(db, "#nothing")).isEmpty, "an unknown tag names nothing")
        }
        try withOperations { ops, db in
            let s = try shelf(ops)
            #expect(titles(try notes(db, "#classics", wing: s.wing.id)) == ["Away"],
                    "the twin path in the second wing — wings isolate totally")
        }
    }

    @Test func tombstonesNeverList() throws {
        try withOperations { ops, db in
            let s = try shelf(ops)
            try ops.removeTag(s.classics.id, fromPost: s.hound.id)
            try ops.deleteContainer(s.study.id)
            #expect(titles(try notes(db, "#classics")) == ["The Sign of Four"],
                    "a removed application and a deleted note leave the listing")
            try ops.deleteTag(s.doyle.id)
            #expect(titles(try notes(db, "#classics")).isEmpty, "a deleted tag names nothing")
        }
    }

    @Test func theArchivedFacetAndTheVersionFence() throws {
        try withOperations { ops, db in
            let s = try shelf(ops)
            try ops.archiveContainer(s.hound.id)
            _ = try ops.saveNoteVersion(s.study.id)   // a VERSION: a tagged, archived family copy
            #expect(titles(try notes(db, "#classics")) == ["A Study in Scarlet", "The Sign of Four"],
                    "living: the archived note waits behind the facet; the version is archived too")
            let faceted = try notes(db, "#classics", visibility: .includingArchived)
            #expect(titles(faceted) == ["A Study in Scarlet", "The Hound", "The Sign of Four"],
                    "the facet on: the archived note joins — the version NEVER does")
            #expect(faceted.hits.map(\.isArchived) == [false, true, false], "…and its row says so (R-13o-6)")
        }
    }

    /// A note wearing BOTH a tag and its child is in the subtree twice — it
    /// lists ONCE, counts once (found while measuring the seam: the driver
    /// yielded one row per application).
    @Test func aNoteTaggedTwiceInTheSubtreeListsOnce() throws {
        try withOperations { ops, db in
            let s = try shelf(ops)
            _ = try ops.applyTag(s.doyle.id, toPost: s.hound.id)
            #expect(titles(try notes(db, "#classics")) == ["A Study in Scarlet", "The Hound", "The Sign of Four"])
            #expect(titles(try notes(db, "#classics", sort: .lastTouched, direction: .desc)).count == 3,
                    "both edited-sort arms")
            let counts = try db.read { db in
                try Queries.searchCounts(db, query: question("#classics"), scope: SearchScope(wingID: ""))
            }
            #expect(counts?.living.notes == 3)
        }
    }

    @Test func severalTagsIntersect() throws {
        try withOperations { ops, db in
            let s = try shelf(ops)
            let favorite = try ops.createTag(name: "favorite")
            _ = try ops.applyTag(favorite.id, toPost: s.hound.id)
            _ = try ops.applyTag(favorite.id, toPost: s.other.id)
            #expect(titles(try notes(db, "#classics #favorite")) == ["The Hound"])
        }
    }

    @Test func theSortAndTheKeysetPageThroughATagsNotes() throws {
        try withOperations { ops, db in
            _ = try shelf(ops)
            let first = try notes(db, "#classics", limit: 2)
            #expect(titles(first) == ["A Study in Scarlet", "The Hound"])
            let next = try #require(first.next)
            let second = try notes(db, "#classics", after: next, limit: 2)
            #expect(titles(second) == ["The Sign of Four"] && second.next == nil, "every tagged note reachable")
            #expect(titles(try notes(db, "#classics", direction: .desc)) == ["The Sign of Four", "The Hound", "A Study in Scarlet"])
            // The default edited sort's TWO arms (touched / never-touched) both narrow.
            let edited = try notes(db, "#classics", sort: .lastTouched, direction: .desc)
            #expect(Set(titles(edited)) == ["A Study in Scarlet", "The Hound", "The Sign of Four"])
            #expect(edited.hits.map(\.lastTouchedAt) == edited.hits.map(\.lastTouchedAt).sorted(by: { ($0 ?? "") > ($1 ?? "") }))
        }
    }

    @Test func wordsCloseTheRoadAndNilIsTheShippedPage() throws {
        try withOperations { ops, db in
            _ = try shelf(ops)
            let env = try db.read { try Queries.searchEnvironment($0) }
            #expect(SearchComposer.listingNarrowing(question("#classics hound"), kind: .notes, wingID: "", environment: env) == nil,
                    "words are the answer sheet's road (unchanged)")
            #expect(SearchComposer.listingNarrowing(question(""), kind: .notes, wingID: "", environment: env) == nil)
            let unnarrowed = try db.read { db in
                try Queries.catalogNotesPage(db, query: "", sort: .title, direction: .asc, limit: 50, wingID: "")
            }
            #expect(unnarrowed.hits.count == 5, "no question: the whole wing, as shipped")
            #expect(try notes(db, "#classics hound").hits.isEmpty && (try notes(db, "hound").hits.isEmpty),
                    "a narrowing the road cannot serve fails CLOSED — never the whole Library")
            #expect(Queries.catalogNotesPageSQL(sort: .lastTouched, direction: .desc, hasCursor: true, wingScope: nil)
                    == Queries.catalogNotesPageSQL(sort: .lastTouched, direction: .desc, hasCursor: true,
                                                   wingScope: nil, narrowing: nil),
                    "the shipped statement, byte for byte, when nothing narrows")
        }
    }

    // MARK: - Blocks, block-level (the Blocks scope)

    @Test func blocksListByTheirOwnTagsScrapsInEveryWing() throws {
        try withOperations { ops, db in
            let s = try shelf(ops)
            let idea = try ops.createTag(name: "idea")
            let pool = try ops.createPool(title: "Heap")
            let scrap = try ops.newBlock(in: pool.id, text: "a loose idea\nwith a second line")
            _ = try ops.applyTag(idea.id, toBlock: scrap.block.id)
            let inNote = try ops.newBlock(in: s.hound.id, text: "the moor at night")
            _ = try ops.applyTag(idea.id, toBlock: inNote.block.id)
            try ops.setBlockName(inNote.block.id, name: "The moor")
            let gone = try ops.newBlock(in: s.study.id, text: "deleted later")
            _ = try ops.applyTag(idea.id, toBlock: gone.block.id)
            try ops.deleteBlock(gone.block.id)
            _ = try ops.applyTag(idea.id, toPost: s.sign.id)   // a NOTE-level application lists no block

            let blocks = try db.read { db in try Queries.catalogTaggedBlocks(db, narrowing: question("#idea"), wingID: "") }
            #expect(Set(blocks.map(\.id)) == [scrap.block.id, inNote.block.id])
            let named = try #require(blocks.first { $0.id == inNote.block.id })
            #expect(named.title == "The moor" && named.detail == "The Hound" && named.homeContainerID == s.hound.id
                    && !named.homeIsPool, "a named block wears its name, its home said")
            let loose = try #require(blocks.first { $0.id == scrap.block.id })
            #expect(loose.title == "a loose idea" && loose.homeIsPool, "a scrap's first line is its handle")

            let elsewhere = try db.read { db in
                try Queries.catalogTaggedBlocks(db, narrowing: question("#idea"), wingID: s.wing.id)
            }
            #expect(elsewhere.isEmpty, "the second wing's own #idea does not exist — a tag path is per wing")
            #expect(try db.read { db in
                try Queries.catalogTaggedBlocks(db, narrowing: question("#idea moor"), wingID: "")
            }.isEmpty, "words close the road")
        }
    }

    /// **Ladder R1 MINOR (U-A AGREED):** a block whose HOME is archived — the
    /// one archived shape this road can list, since an archived BLOCK's
    /// placement is released and never lists (P-13o-U1-8) — enters only under
    /// the archived facet AND carries the archived FACT, so the row can wear
    /// the mark (R-13o-6's letter, "rows say which they are"; P-VX83-3 read
    /// as the implementer meant it: every row the facet brings in says so).
    /// RED-ON-OLD: the shipped statement never selected the home's archive
    /// and the hit defaulted false — verified by revert at the fix.
    @Test func anArchivedHomesBlockEntersOnlyUnderTheFacetWearingItsFact() throws {
        try withOperations { ops, db in
            let idea = try ops.createTag(name: "idea")
            let kept = try ops.createPost(title: "Kept")
            let keptBlock = try ops.newBlock(in: kept.id, text: "a living thought")
            _ = try ops.applyTag(idea.id, toBlock: keptBlock.block.id)
            let shelved = try ops.createPost(title: "Shelved")
            let shelvedBlock = try ops.newBlock(in: shelved.id, text: "a put-away thought")
            _ = try ops.applyTag(idea.id, toBlock: shelvedBlock.block.id)
            try ops.archiveContainer(shelved.id)

            let living = try db.read { db in
                try Queries.catalogTaggedBlocks(db, narrowing: question("#idea"), wingID: "")
            }
            #expect(living.map(\.id) == [keptBlock.block.id],
                    "the archived home's block waits for the facet")
            let withFacet = try db.read { db in
                try Queries.catalogTaggedBlocks(
                    db, narrowing: question("#idea", visibility: .includingArchived), wingID: "")
            }
            #expect(Set(withFacet.map(\.id)) == [keptBlock.block.id, shelvedBlock.block.id])
            #expect(withFacet.first { $0.id == shelvedBlock.block.id }?.isArchived == true,
                    "the facet's row says which it is (R-13o-6)")
            #expect(withFacet.first { $0.id == keptBlock.block.id }?.isArchived == false,
                    "a living home's block stays unmarked")
        }
    }

    // MARK: - The counts (the band stays honest)

    @Test func theCountsAreTheListingsOwn() throws {
        try withOperations { ops, db in
            let s = try shelf(ops)
            try ops.archiveContainer(s.hound.id)
            let pool = try ops.createPool(title: "Heap")
            let scrap = try ops.newBlock(in: pool.id, text: "a classic line")
            _ = try ops.applyTag(s.classics.id, toBlock: scrap.block.id)
            let counts = try #require(try db.read { db in
                try Queries.searchCounts(db, query: question("#classics"), scope: SearchScope(wingID: ""))
            })
            #expect(counts.living.notes == 2 && counts.all.notes == 3, "living vs the facet on")
            #expect(counts.living.blocks == 1 && counts.all.blocks == 1)
            #expect(counts.living.passages == 0 && counts.living.scraps == 0, "nothing was searched as text")
            #expect(counts.archivedPlaces == 1, "the archived note is what the facet would add")
            let words = try #require(try db.read { db in
                try Queries.searchCounts(db, query: question("#classics hound"), scope: SearchScope(wingID: ""))
            })
            #expect(words.living.blocks == 0 && words.all.blocks == 0, "with words, the shipped counts — no blocks")
            #expect(try db.read { db in
                try Queries.searchCounts(db, query: question("#nothing"), scope: SearchScope(wingID: ""))
            } == nil, "an unknown tag counts nothing (no band numbers, as before)")
        }
    }
}

// MARK: - THE SEAM (VX-84a): the driven page vs the predicate in the sort walk

private func pageRequests(_ db: Database, reset: Bool) -> Int {
    var hit: Int32 = 0, miss: Int32 = 0, high: Int32 = 0
    sqlite3_db_status(db.sqliteConnection, SQLITE_DBSTATUS_CACHE_HIT, &hit, &high, reset ? 1 : 0)
    sqlite3_db_status(db.sqliteConnection, SQLITE_DBSTATUS_CACHE_MISS, &miss, &high, reset ? 1 : 0)
    return Int(hit) + Int(miss)
}

/// `notes` touched notes (one take each); the SAME 10 notes — the OLDEST
/// touched, so a newest-first walk meets them last — carry #classics in
/// every corpus: the tag's set is fixed while the corpus grows.
private func taggedCorpus(notes: Int) throws -> AppDatabase {
    let db = try AppDatabase.inMemory()
    try db.write { db in
        try db.execute(sql: "INSERT INTO _sync_applying VALUES (1)")
        try db.execute(sql: "PRAGMA defer_foreign_keys = ON")
        let now = "2026-10-06T00:00:00.000Z"
        try db.execute(sql: """
            INSERT INTO tag (id, name, path, created_at, updated_at) VALUES ('t-classics', 'classics', 'classics', ?, ?)
            """, arguments: [now, now])
        let note = try db.makeStatement(sql: """
            INSERT INTO container (id, kind, title, last_touched_at, created_at, updated_at)
            VALUES (?, 'post', ?, ?, ?, ?)
            """)
        let applied = try db.makeStatement(sql: """
            INSERT INTO post_tag (id, tag_id, post_id, created_at) VALUES (?, 't-classics', ?, ?)
            """)
        for n in 0..<notes {
            let id = String(format: "n%06d", n)
            let touched = String(format: "2026-10-06T%02d:%02d:%02d.000Z", (n / 3600) % 24, (n / 60) % 60, n % 60)
            try note.execute(arguments: [id, "note \(n)", touched, now, now])
            if n < 10 { try applied.execute(arguments: [id + "-pt", id, now]) }
        }
        try db.execute(sql: "DELETE FROM _sync_applying")
    }
    return db
}

@Suite("VX-84a — the seam: a tag's page is DRIVEN by its applications")
struct SearchTagListingSeamTests {
    /// (A) the predicate composed INTO the shipped sort walk (the composer's
    /// note-level tag fragment appended to each `INDEXED BY` arm) vs (B) the
    /// built shape, the page DRIVEN from the tag's applications. Page
    /// requests, two corpora of one shape, the second 5×, the tagged set
    /// fixed at 10 notes. Printed as `[VX-84a]` lines for the record; (B) is
    /// pinned flat, (A)'s growth is the measurement that rules it out.
    @Test func theDrivenPageIsFlatWhileTheSortWalkGrowsWithTheWing() throws {
        var driven: [Int] = []
        var walked: [Int] = []
        for size in [2_000, 10_000] {
            let db = try taggedCorpus(notes: size)
            try db.read { db in
                let q = question("#classics")
                _ = pageRequests(db, reset: true)
                let page = try Queries.catalogNotesPage(
                    db, query: "", sort: .lastTouched, direction: .desc, limit: 80, wingID: "", narrowing: q)
                driven.append(pageRequests(db, reset: false))
                #expect(page.hits.count == 10)

                // (A): the shipped arms + the composer's own note-level predicate.
                let env = try Queries.searchEnvironment(db)
                let fragment = SearchComposer.composeFilter(
                    try #require(q.filter), level: .note, wingID: "", environment: env)
                let shipped = Queries.catalogNotesPageSQL(
                    sort: .lastTouched, direction: .desc, hasCursor: false, wingScope: nil)
                let predicate = shipped.replacingOccurrences(
                    of: "FROM container INDEXED BY idx_container_touched",
                    with: "FROM container c INDEXED BY idx_container_touched")
                    .replacingOccurrences(
                        of: "\n  AND (? = ''",
                        with: "\n  AND \(fragment.sql)\n  AND (? = ''")
                #expect(predicate.components(separatedBy: fragment.sql).count == 3,
                        "the predicate composed into BOTH arms of the shipped walk")
                let arm: [DatabaseValue] = (fragment.arguments
                    + [.text(""), .text("%%"), .text("%%"), .integer(81)]).map(Queries.databaseValue)
                _ = pageRequests(db, reset: true)
                let rows = try Row.fetchAll(db, sql: predicate, arguments: StatementArguments(arm + arm + [81.databaseValue]))
                walked.append(pageRequests(db, reset: false))
                #expect(rows.count == 10, "the predicate shape finds the same ten")
            }
        }
        print("[VX-84a] driven page: \(driven[0]) → \(driven[1]) page requests (2k → 10k notes)")
        print("[VX-84a] predicate in the sort walk: \(walked[0]) → \(walked[1]) page requests")
        #expect(Double(driven[1]) <= Double(driven[0]) * 1.5,
                "the driven page is ∝ the tag's notes — flat while the wing grows 5×")
        #expect(Double(walked[1]) >= Double(walked[0]) * 2.5,
                "the measurement that rules the predicate out: ∝ the wing's notes")
    }

    @Test func theDrivenPlansStartFromTheTagNeverAWalk() throws {
        let db = try taggedCorpus(notes: 200)
        try db.write { db in   // a scrap tagged at block level, for the blocks road
            try db.execute(sql: "INSERT INTO _sync_applying VALUES (1)")
            try db.execute(sql: "PRAGMA defer_foreign_keys = ON")
            let now = "2026-10-06T00:00:00.000Z"
            try db.execute(sql: """
                INSERT INTO container (id, kind, created_at, updated_at) VALUES ('pool', 'pool', ?, ?);
                INSERT INTO block (id, default_variant_id, created_at, updated_at) VALUES ('blk', 'blk-v', ?, ?);
                INSERT INTO variant (id, block_id, working_text, fan_position, created_at, updated_at)
                  VALUES ('blk-v', 'blk', 'a classic scrap', 'a0', ?, ?);
                INSERT INTO container_block (id, container_id, block_id, position, chosen_variant_id, created_at, updated_at)
                  VALUES ('blk-p', 'pool', 'blk', 'a0', 'blk-v', ?, ?);
                INSERT INTO block_tag (id, tag_id, block_id, created_at) VALUES ('blk-t', 't-classics', 'blk', ?);
                DELETE FROM _sync_applying;
                """, arguments: [now, now, now, now, now, now, now, now, now])
        }
        try db.read { db in
            let env = try Queries.searchEnvironment(db)
            func plan(_ sql: String, _ arguments: [SearchComposer.Value]) throws -> [String] {
                try Row.fetchAll(db, sql: "EXPLAIN QUERY PLAN " + sql, arguments: Queries.arguments(arguments))
                    .map { $0["detail"] as String }
            }
            // The NOTES page, the default edited sort — BOTH arms (touched and
            // never-touched; the never-touched arm was where the seam found a
            // walk BY KIND and a scan of every application).
            let notes = try #require(SearchComposer.listingNarrowing(
                question("#classics"), kind: .notes, wingID: "", environment: env))
            let arm = notes.driverArguments + notes.conditionArguments
                + [.text(""), .text("%%"), .text("%%"), .integer(81)]
            let page = try plan(Queries.catalogNotesPageSQL(
                sort: .lastTouched, direction: .desc, hasCursor: false, wingScope: nil, narrowing: notes),
                arm + arm + [.integer(81)])
            print("[VX-84a] notes page plan:\n" + page.joined(separator: "\n"))
            #expect(page.filter { $0.hasPrefix("SEARCH pt USING INDEX idx_post_tag_tag") }.count >= 2,
                    "each arm reads the applications BY TAG ID: \(page)")
            #expect(!page.contains { $0.hasPrefix("SCAN pt") || $0.hasPrefix("SCAN c") || $0.contains("idx_container_kind") },
                    "never a scan of the applications, never a walk of the notes: \(page)")

            // The BLOCKS list.
            let blocks = try #require(SearchComposer.listingNarrowing(
                question("#classics"), kind: .blocks, wingID: "", environment: env))
            let list = try plan("""
                SELECT b.id FROM (\(blocks.driver)) t
                CROSS JOIN block b ON b.id = t.tagged_id
                JOIN container_block cb ON cb.block_id = b.id AND cb.deleted_at IS NULL
                JOIN container c ON c.id = cb.container_id
                WHERE \(blocks.conditions)
                """, blocks.driverArguments + blocks.conditionArguments)
            print("[VX-84a] blocks plan:\n" + list.joined(separator: "\n"))
            #expect(list.contains { $0.hasPrefix("SEARCH bt USING INDEX idx_block_tag_tag") }, "\(list)")
            #expect(!list.contains { $0.hasPrefix("SCAN bt") || $0.hasPrefix("SCAN b") || $0.hasPrefix("SCAN c") || $0.hasPrefix("SCAN cb") },
                    "\(list)")
            #expect(try Queries.catalogTaggedBlocks(db, narrowing: question("#classics"), wingID: "").map(\.id) == ["blk"])
        }
    }
}
