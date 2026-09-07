import Foundation
import GRDB
import Testing
@testable import VariorumCore

@Suite("Reading assembly query (Phase 4, Step 2)")
struct ReadingAssemblyQueryTests {
    // MARK: - Curated order, extent, membership

    @Test func curatedAssemblesInPositionOrder() throws {
        try withOperations { ops, db in
            let p1 = try ops.createPost(title: "one")
            let p2 = try ops.createPost(title: "two")
            let p3 = try ops.createPost(title: "three")
            let reading = try ops.createReading(name: "book", kind: .curated)
            try ops.addPostToReading(p1.id, to: reading.id)
            try ops.addPostToReading(p3.id, to: reading.id)
            try ops.addPostToReading(p2.id, to: reading.id, at: .after(p1.id))
            let entries = try db.read { try Queries.assembleReading($0, readingID: reading.id) }
            #expect(entries.map(\.postID) == [p1.id, p2.id, p3.id])
            #expect(entries.map(\.title) == ["one", "two", "three"])
        }
    }

    @Test func maxPostsCapsTheAssembly() throws {
        try withOperations { ops, db in
            let reading = try ops.createReading(name: "capped", kind: .curated, maxPosts: 2)
            let p1 = try ops.createPost()
            let p2 = try ops.createPost()
            try ops.addPostToReading(p1.id, to: reading.id)
            try ops.addPostToReading(p2.id, to: reading.id)
            // The op enforces the cap on the way in; the read enforces it on
            // the way out too (a sync race can overfill — render the extent).
            let p3 = try ops.createPost()
            try db.write { db in
                try db.execute(
                    sql: """
                        INSERT INTO reading_post (id, reading_id, post_id, position, created_at)
                        VALUES ('raced', ?, ?, 'zzz', '2026-07-04T00:00:00.000Z')
                        """,
                    arguments: [reading.id, p3.id])
            }
            let entries = try db.read { try Queries.assembleReading($0, readingID: reading.id) }
            #expect(entries.count == 2)
            #expect(entries.map(\.postID) == [p1.id, p2.id])
        }
    }

    @Test func readingsListsLiveRowsByName() throws {
        // Phase 10 (additive): the readings-management face's listing.
        try withOperations { ops, db in
            _ = try ops.createReading(name: "zeta", kind: .curated)
            _ = try ops.createReading(name: "alpha", kind: .smart)
            let dead = try ops.createReading(name: "dead", kind: .curated)
            try ops.deleteReading(dead.id)
            let readings = try db.read { try Queries.readings($0) }
            #expect(readings.map(\.name) == ["alpha", "zeta"])
        }
    }

    /// pre-13x ladder round 2, F3 (MINOR-N3): the seeded books' silent
    /// ensure reads a book's tombstone as the reader's decision — any
    /// tombstoned row of the exact name, whatever its age; a live book, a
    /// restored one and a name never seen answer false.
    @Test func readingTombstoneExistsReadsTheExactNameAcrossAnyAge() throws {
        try withOperations { ops, db in
            let live = try ops.createReading(name: "Encryption Explained", kind: .curated)
            #expect(try db.read { try Queries.readingTombstoneExists($0, name: "Encryption Explained") } == false)
            #expect(try db.read { try Queries.readingTombstoneExists($0, name: "never seen") } == false)
            try ops.deleteReading(live.id)
            #expect(try db.read { try Queries.readingTombstoneExists($0, name: "Encryption Explained") } == true)
            #expect(try db.read { try Queries.readingTombstoneExists($0, name: "encryption explained") } == false,
                    "the EXACT name — the seeder's own discovery rule")
            // A tombstone older than the Trash's window still answers (a purge
            // intent or the window's edge is not the reader's word being taken back).
            try db.write { db in
                try db.execute(sql: "UPDATE reading SET deleted_at = '2020-01-01T00:00:00.000Z' WHERE id = ?", arguments: [live.id])
            }
            #expect(try db.read { try Queries.readingTombstoneExists($0, name: "Encryption Explained") } == true)
            try ops.restoreReading(live.id)
            #expect(try db.read { try Queries.readingTombstoneExists($0, name: "Encryption Explained") } == false,
                    "a restored book took the deletion back")
        }
    }

    @Test func callerLimitWindowsTheAssemblyAndMaxPostsStillWins() throws {
        // Phase 10 (additive): a held observation windows its standing
        // fetch (the observeLibrary discipline — the book view's bound).
        try withOperations { ops, db in
            let reading = try ops.createReading(name: "windowed", kind: .curated)
            var ids: [String] = []
            for i in 0..<5 {
                let post = try ops.createPost(title: "p\(i)")
                try ops.addPostToReading(post.id, to: reading.id)
                ids.append(post.id)
            }
            let windowed = try db.read {
                try Queries.assembleReading($0, readingID: reading.id, limit: 3)
            }
            #expect(windowed.map(\.postID) == Array(ids.prefix(3)))
            // The window and the extent cap combine as min(maxPosts, limit).
            let capped = try ops.createReading(name: "capped", kind: .curated, maxPosts: 2)
            for id in ids.prefix(2) { try ops.addPostToReading(id, to: capped.id) }
            let wideWindow = try db.read {
                try Queries.assembleReading($0, readingID: capped.id, limit: 5)
            }
            #expect(wideWindow.count == 2)  // maxPosts wins
            let narrowWindow = try db.read {
                try Queries.assembleReading($0, readingID: capped.id, limit: 1)
            }
            #expect(narrowWindow.count == 1)  // the window wins
            // And nil limit preserves the Phase 4 behavior exactly.
            let whole = try db.read {
                try Queries.assembleReading($0, readingID: reading.id)
            }
            #expect(whole.count == 5)
        }
    }

    @Test func tombstonedPostsAndMembershipsAreExcluded() throws {
        try withOperations { ops, db in
            let reading = try ops.createReading(name: "r", kind: .curated)
            let p1 = try ops.createPost()
            let p2 = try ops.createPost()
            let p3 = try ops.createPost()
            for post in [p1, p2, p3] { try ops.addPostToReading(post.id, to: reading.id) }
            try ops.deleteContainer(p2.id)
            try ops.removePostFromReading(p3.id, from: reading.id)
            let entries = try db.read { try Queries.assembleReading($0, readingID: reading.id) }
            #expect(entries.map(\.postID) == [p1.id])
        }
    }

    @Test func archivedPostsAreOutOfView() throws {
        // Domain archive = kept, out of view (AppSpec §6) — PROVISIONAL
        // read-time interpretation, phase closeout.
        try withOperations { ops, db in
            let reading = try ops.createReading(name: "r", kind: .curated)
            let p1 = try ops.createPost()
            let p2 = try ops.createPost()
            try ops.addPostToReading(p1.id, to: reading.id)
            try ops.addPostToReading(p2.id, to: reading.id)
            try ops.archiveContainer(p1.id)
            let entries = try db.read { try Queries.assembleReading($0, readingID: reading.id) }
            #expect(entries.map(\.postID) == [p2.id])
        }
    }

    @Test func aPostMayLiveInManyReadings() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "shared")
            let r1 = try ops.createReading(name: "a", kind: .curated)
            let r2 = try ops.createReading(name: "b", kind: .curated)
            try ops.addPostToReading(post.id, to: r1.id)
            try ops.addPostToReading(post.id, to: r2.id)
            let inR1 = try db.read { try Queries.assembleReading($0, readingID: r1.id) }
            let inR2 = try db.read { try Queries.assembleReading($0, readingID: r2.id) }
            #expect(inR1.map(\.postID) == [post.id])
            #expect(inR2.map(\.postID) == [post.id])
        }
    }

    @Test func missingReadingOrMissingPostRowTolerated() throws {
        // Reading that never arrived: empty, no crash.
        try withOperations { _, db in
            let entries = try db.read { try Queries.assembleReading($0, readingID: "nowhere") }
            #expect(entries.isEmpty)
        }
        // Membership whose post hasn't arrived (child-before-parent sync
        // order, SyncSpec §5): the entry is a gap — excluded, no crash.
        let queue = try unenforcedDatabase()
        try queue.write { db in
            try Fixture.reading(db, id: "r")
            try Fixture.container(db, id: "p1")
            try Fixture.readingPost(db, id: "rp1", readingId: "r", postId: "p1", position: "A")
            try Fixture.readingPost(db, id: "rp2", readingId: "r", postId: "not-arrived", position: "B")
        }
        let entries = try queue.read { try Queries.assembleReading($0, readingID: "r") }
        #expect(entries.map(\.postID) == ["p1"])
    }

    // MARK: - Sort fields (AppSpec §10: the two stamps + entry_date/created_at)

    @Test func entryDateSortOrdersJournalsAndSortsUndatedLast() throws {
        try withOperations { ops, db in
            let reading = try ops.createReading(
                name: "journal", kind: .curated, sortField: .entryDate, sortDir: .asc)
            let later = try ops.createPost(entryDate: "2026-07-02")
            let earlier = try ops.createPost(entryDate: "2026-07-01")
            let undated = try ops.createPost()
            for post in [later, undated, earlier] { try ops.addPostToReading(post.id, to: reading.id) }
            let entries = try db.read { try Queries.assembleReading($0, readingID: reading.id) }
            #expect(entries.map(\.postID) == [earlier.id, later.id, undated.id])
        }
    }

    @Test func createdAtSortFollowsCreationOrder() throws {
        try withOperations { ops, db in
            let reading = try ops.createReading(
                name: "r", kind: .curated, sortField: .createdAt, sortDir: .desc)
            let first = try ops.createPost()
            let second = try ops.createPost()
            try ops.addPostToReading(first.id, to: reading.id)
            try ops.addPostToReading(second.id, to: reading.id)
            let entries = try db.read { try Queries.assembleReading($0, readingID: reading.id) }
            #expect(entries.map(\.postID) == [second.id, first.id])
        }
    }

    @Test func lastTouchedSortReordersOnAnyEdit() throws {
        try withOperations { ops, db in
            let reading = try ops.createReading(
                name: "r", kind: .curated, sortField: .lastTouched, sortDir: .desc)
            let a = try ops.createPost()
            let b = try ops.createPost()
            let blockA = try ops.newBlock(in: a.id, text: "aaaa")
            _ = try ops.newBlock(in: b.id, text: "bbbb")
            try ops.addPostToReading(a.id, to: reading.id)
            try ops.addPostToReading(b.id, to: reading.id)
            // Touch A after B: one keystroke is enough for the noisy stamp.
            try ops.autosave(blockA.variant.id, text: "aaaa!", charDelta: 1)
            let entries = try db.read { try Queries.assembleReading($0, readingID: reading.id) }
            #expect(entries.map(\.postID) == [a.id, b.id])
        }
    }

    @Test func lastMajorRevisionSortIgnoresTypoFixes() throws {
        try withOperations { ops, db in
            let reading = try ops.createReading(
                name: "r", kind: .curated, sortField: .lastMajorRevision, sortDir: .desc)
            let a = try ops.createPost()
            let b = try ops.createPost()
            let blockA = try ops.newBlock(in: a.id, text: String(repeating: "a", count: 400))
            let blockB = try ops.newBlock(in: b.id, text: String(repeating: "b", count: 400))
            try ops.addPostToReading(a.id, to: reading.id)
            try ops.addPostToReading(b.id, to: reading.id)
            // Meaningful stamp on B first (manual commit forces it), then on A.
            try ops.commit(blockB.variant.id)
            try ops.commit(blockA.variant.id)
            // A later typo fix on B must NOT reshuffle the meaningful sort.
            try ops.autosave(blockB.variant.id, text: String(repeating: "b", count: 399), charDelta: -1)
            let entries = try db.read { try Queries.assembleReading($0, readingID: reading.id) }
            #expect(entries.map(\.postID) == [a.id, b.id])
        }
    }

    // MARK: - Smart readings (v1 predicate vocabulary, PROVISIONAL)

    @Test func smartMatchesProfileAndDateRange() throws {
        try withOperations { ops, db in
            _ = try ops.createPost(title: "blog", profile: .blog, entryDate: "2026-06-15")
            let juneEntry = try ops.createPost(title: "june", profile: .journal, entryDate: "2026-06-15")
            _ = try ops.createPost(title: "july", profile: .journal, entryDate: "2026-07-02")
            let spec = try Queries.SmartQuerySpec(
                profile: "journal", entryDateFrom: "2026-06-01", entryDateTo: "2026-06-30"
            ).encodedJSON()
            let reading = try ops.createReading(name: "june journal", kind: .smart, querySpec: spec)
            let entries = try db.read { try Queries.assembleReading($0, readingID: reading.id) }
            #expect(entries.map(\.postID) == [juneEntry.id])
        }
    }

    @Test func smartTagPredicateUsesSubtreeSemantics() throws {
        try withOperations { ops, db in
            let life = try ops.createTag(name: "life")
            let goals = try ops.createTag(parent: life.id, name: "goals")
            let y2026 = try ops.createTag(parent: goals.id, name: "2026")
            let work = try ops.createTag(name: "work")

            let atRoot = try ops.createPost(title: "at goals")
            let deeper = try ops.createPost(title: "under goals")
            let elsewhere = try ops.createPost(title: "work post")
            let untagged = try ops.createPost(title: "untagged")
            try ops.applyTag(goals.id, toPost: atRoot.id)
            try ops.applyTag(y2026.id, toPost: deeper.id)
            try ops.applyTag(work.id, toPost: elsewhere.id)
            _ = untagged

            let spec = try Queries.SmartQuerySpec(tags: ["life/goals"]).encodedJSON()
            let reading = try ops.createReading(name: "goals", kind: .smart, querySpec: spec)
            let entries = try db.read { try Queries.assembleReading($0, readingID: reading.id) }
            #expect(Set(entries.map(\.postID)) == [atRoot.id, deeper.id])

            // ANY-of across listed paths.
            let anySpec = try Queries.SmartQuerySpec(tags: ["life/goals", "work"]).encodedJSON()
            try ops.setReadingQuerySpec(reading.id, querySpec: anySpec)
            let anyEntries = try db.read { try Queries.assembleReading($0, readingID: reading.id) }
            #expect(Set(anyEntries.map(\.postID)) == [atRoot.id, deeper.id, elsewhere.id])
        }
    }

    @Test func smartWithNoSpecMatchesAllPostsAndMalformedMatchesNone() throws {
        try withOperations { ops, db in
            let p1 = try ops.createPost()
            let p2 = try ops.createPost()
            _ = try ops.createPool()  // never a smart-reading member
            let unconstrained = try ops.createReading(name: "all", kind: .smart)
            let all = try db.read { try Queries.assembleReading($0, readingID: unconstrained.id) }
            #expect(all.map(\.postID) == [p1.id, p2.id])  // created_at fallback order

            let malformed = try ops.createReading(
                name: "broken", kind: .smart, querySpec: "{not json")
            let none = try db.read { try Queries.assembleReading($0, readingID: malformed.id) }
            #expect(none.isEmpty)
        }
    }

    @Test func smartRespectsSortAndExtent() throws {
        try withOperations { ops, db in
            let old = try ops.createPost(profile: .journal, entryDate: "2026-01-01")
            let mid = try ops.createPost(profile: .journal, entryDate: "2026-02-01")
            let new = try ops.createPost(profile: .journal, entryDate: "2026-03-01")
            _ = mid
            let spec = try Queries.SmartQuerySpec(profile: "journal").encodedJSON()
            let reading = try ops.createReading(
                name: "latest two", kind: .smart,
                sortField: .entryDate, sortDir: .desc, querySpec: spec, maxPosts: 2)
            let entries = try db.read { try Queries.assembleReading($0, readingID: reading.id) }
            #expect(entries.map(\.postID) == [new.id, mid.id])
            _ = old
        }
    }

    // MARK: - Grouping by a tag root (chapter sections)

    @Test func groupingSectionsPostsByImmediateChildOfRoot() throws {
        try withOperations { ops, db in
            let book = try ops.createTag(name: "book")
            let ch1 = try ops.createTag(parent: book.id, name: "ch1")
            let ch2 = try ops.createTag(parent: book.id, name: "ch2")
            let notes = try ops.createTag(parent: ch1.id, name: "notes")

            let inCh1 = try ops.createPost(title: "direct")
            let inCh1Deep = try ops.createPost(title: "via grandchild")
            let inCh2 = try ops.createPost(title: "ch2")
            let atRoot = try ops.createPost(title: "root only")
            let unsectioned = try ops.createPost(title: "outside")
            try ops.applyTag(ch1.id, toPost: inCh1.id)
            try ops.applyTag(notes.id, toPost: inCh1Deep.id)
            try ops.applyTag(ch2.id, toPost: inCh2.id)
            try ops.applyTag(book.id, toPost: atRoot.id)

            let reading = try ops.createReading(
                name: "the book", kind: .curated, groupingTagId: book.id)
            for post in [inCh1, inCh1Deep, inCh2, atRoot, unsectioned] {
                try ops.addPostToReading(post.id, to: reading.id)
            }
            let entries = try db.read { try Queries.assembleReading($0, readingID: reading.id) }
            let sections = Dictionary(uniqueKeysWithValues: entries.map { ($0.postID, $0.sectionPath) })
            #expect(sections[inCh1.id] == "book/ch1")
            #expect(sections[inCh1Deep.id] == "book/ch1")
            #expect(sections[inCh2.id] == "book/ch2")
            #expect(sections[atRoot.id] == .some(nil))       // tagged at the root: no child section
            #expect(sections[unsectioned.id] == .some(nil))  // untagged: ungrouped
        }
    }

    @Test func smartReadingGroupsToo() throws {
        // Grouping + smart predicate together: the section subquery's
        // parameter precedes every predicate parameter in the SQL — this
        // pins the argument ordering.
        try withOperations { ops, db in
            let book = try ops.createTag(name: "book")
            let ch1 = try ops.createTag(parent: book.id, name: "ch1")
            let inSection = try ops.createPost(profile: .journal, entryDate: "2026-06-10")
            let outside = try ops.createPost(profile: .journal, entryDate: "2026-06-11")
            _ = try ops.createPost(profile: .blog, entryDate: "2026-06-12")
            try ops.applyTag(ch1.id, toPost: inSection.id)
            let spec = try Queries.SmartQuerySpec(
                profile: "journal", entryDateFrom: "2026-06-01", entryDateTo: "2026-06-30"
            ).encodedJSON()
            let reading = try ops.createReading(
                name: "smart grouped", kind: .smart, sortField: .entryDate,
                groupingTagId: book.id, querySpec: spec)
            let entries = try db.read { try Queries.assembleReading($0, readingID: reading.id) }
            #expect(entries.map(\.postID) == [inSection.id, outside.id])
            #expect(entries.map(\.sectionPath) == ["book/ch1", nil])
        }
    }

    @Test func danglingGroupingTagMeansUngrouped() throws {
        // The AppSpec §7 read-time rule: grouping_tag_id may dangle at a
        // tombstoned tag under soft delete — treat as NULL/ungrouped.
        try withOperations { ops, db in
            let book = try ops.createTag(name: "book")
            let ch1 = try ops.createTag(parent: book.id, name: "ch1")
            let post = try ops.createPost()
            try ops.applyTag(ch1.id, toPost: post.id)
            let reading = try ops.createReading(
                name: "r", kind: .curated, groupingTagId: book.id)
            try ops.addPostToReading(post.id, to: reading.id)
            try ops.deleteTag(book.id)
            let entries = try db.read { try Queries.assembleReading($0, readingID: reading.id) }
            #expect(entries.count == 1)
            #expect(entries[0].sectionPath == nil)
        }
    }

    @Test func groupingIgnoresTombstonedApplicationsAndSections() throws {
        try withOperations { ops, db in
            let book = try ops.createTag(name: "book")
            let ch1 = try ops.createTag(parent: book.id, name: "ch1")
            let ch2 = try ops.createTag(parent: book.id, name: "ch2")
            let post = try ops.createPost()
            try ops.applyTag(ch1.id, toPost: post.id)
            try ops.applyTag(ch2.id, toPost: post.id)
            let reading = try ops.createReading(
                name: "r", kind: .curated, groupingTagId: book.id)
            try ops.addPostToReading(post.id, to: reading.id)

            // Two sections match: the lexically smallest path wins.
            let both = try db.read { try Queries.assembleReading($0, readingID: reading.id) }
            #expect(both[0].sectionPath == "book/ch1")

            // Removing the ch1 application leaves ch2.
            try ops.removeTag(ch1.id, fromPost: post.id)
            let one = try db.read { try Queries.assembleReading($0, readingID: reading.id) }
            #expect(one[0].sectionPath == "book/ch2")

            // Tombstoning the ch2 *tag* (cascades its applications): ungrouped.
            try ops.deleteTag(ch2.id)
            let none = try db.read { try Queries.assembleReading($0, readingID: reading.id) }
            #expect(none[0].sectionPath == nil)
        }
    }
}
