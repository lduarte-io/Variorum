import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// 13i-b U4 — **the Pool tuck** (the sitting record §8; §25 lesson 10, whose
/// sentence is this suite's spine: "The Pool is every note with no book. Notes
/// that show in gatherings tuck behind the count in its masthead — one click
/// shows them."). The DEFINITION stays bookless; the read SPLITS it — loose
/// (shown by no gathering) vs tucked (shown by some live gathering) — with
/// exact per-class counts.
@Suite("13i-b U4 — the Pool tuck: the bookless split (lesson 10)")
struct PoolTuckTests {
    private func listing(_ db: AppDatabase, window: Int = 50) throws -> Queries.PoolListing {
        try db.read { try Queries.poolListing($0, window: window) }
    }

    /// Lesson 10, both sentences, against the store's own truth.
    @Test func thePoolIsEveryBooklessNoteAndTheGatheredOnesTuck() throws {
        try withOperations { ops, db in
            let tag = try ops.createTag(name: "ideas")
            let book = try ops.createReading(name: "a book", kind: .book)
            let loose = try ops.createPost(title: "loose")
            let tagged = try ops.createPost(title: "tagged")
            let starred = try ops.createPost(title: "starred")
            let membered = try ops.createPost(title: "membered")
            _ = try ops.applyTag(tag.id, toPost: tagged.id)
            try ops.setStarred(.post(starred.id), starred: true)
            try ops.addPostToReading(membered.id, to: book.id)
            _ = try ops.createReading(
                name: "ideas", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(tag.id)))
            _ = try ops.createReading(
                name: "starred notes", kind: .gathering, querySpec: try RuleGrammar.encode(.star))

            let pool = try listing(db)
            // "every note with no book": loose ∪ tucked is exactly the
            // bookless set — the member is in neither.
            let bookless = try db.read { db in
                try String.fetchAll(db, sql: """
                    SELECT id FROM container c
                    WHERE kind = 'post' AND deleted_at IS NULL AND archived_at IS NULL
                      AND NOT EXISTS (SELECT 1 FROM reading_post rp WHERE rp.post_id = c.id
                                       AND rp.deleted_at IS NULL AND rp.status = 'member')
                    """)
            }
            #expect(Set(pool.loose.map(\.postID) + pool.tucked.map(\.postID)) == Set(bookless))
            #expect(!bookless.contains(membered.id))
            // "the gathered ones tuck": exactly the notes a gathering shows.
            #expect(pool.loose.map(\.postID) == [loose.id])
            #expect(Set(pool.tucked.map(\.postID)) == Set([tagged.id, starred.id]))
            #expect(pool.looseCount == 1)
            #expect(pool.tuckedCount == 2)
            // The phone's listing and every older caller read the SAME split.
            let posts = try db.read { try Queries.poolPosts($0, limit: 50).map(\.postID) }
            #expect(posts == [loose.id])
        }
    }

    @Test func theCountsAreExactBeyondTheWindow() throws {
        try withOperations { ops, db in
            let tag = try ops.createTag(name: "t")
            _ = try ops.createReading(
                name: "t", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(tag.id)))
            for i in 0..<5 { _ = try ops.createPost(title: "loose \(i)") }
            for i in 0..<3 {
                let note = try ops.createPost(title: "tucked \(i)")
                _ = try ops.applyTag(tag.id, toPost: note.id)
            }
            let pool = try listing(db, window: 2)
            #expect(pool.loose.count == 2)
            #expect(pool.tucked.count == 2)
            #expect(pool.looseCount == 5)
            #expect(pool.tuckedCount == 3)
            // Newest touched first within each class.
            #expect(pool.loose.map(\.title) == ["loose 4", "loose 3"])
            #expect(pool.tucked.map(\.title) == ["tucked 2", "tucked 1"])
        }
    }

    @Test func untaggingOrUnstarringUntucksAtOnce() throws {
        try withOperations { ops, db in
            let tag = try ops.createTag(name: "t")
            _ = try ops.createReading(
                name: "t", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(tag.id)))
            _ = try ops.createReading(
                name: "s", kind: .gathering, querySpec: try RuleGrammar.encode(.star))
            let a = try ops.createPost(title: "a")
            let b = try ops.createPost(title: "b")
            _ = try ops.applyTag(tag.id, toPost: a.id)
            try ops.setStarred(.post(b.id), starred: true)
            #expect(try listing(db).tuckedCount == 2)
            try ops.removeTag(tag.id, fromPost: a.id)
            try ops.setStarred(.post(b.id), starred: false)
            let pool = try listing(db)
            #expect(pool.tuckedCount == 0)
            #expect(Set(pool.loose.map(\.postID)) == Set([a.id, b.id]))
        }
    }

    @Test func eachGatheringsLetterHolds() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "n")
            #expect(try listing(db).tuckedCount == 0, "no gathering — nothing tucks")
            // A MALFORMED rule shows nothing, so it tucks nothing.
            _ = try ops.createReading(name: "broken", kind: .gathering, querySpec: "{not json")
            #expect(try listing(db).tuckedCount == 0)
            // 13i-c (R-13ic-4, an HONEST FLIP of the 13i-b letter): a
            // gathering is MINTED with a rule, and a rule-less one — reachable
            // only as a Trash restoree — shows NOTHING, so it tucks nothing.
            #expect(throws: OperationError.self) {
                try ops.createReading(name: "everything", kind: .gathering)
            }
            let t = try ops.createTag(name: "t")
            let ruled = try ops.createReading(
                name: "ruled", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(t.id)))
            try db.write { db in
                try db.execute(
                    sql: "UPDATE reading SET query_spec = NULL WHERE id = ?", arguments: [ruled.id])
            }
            #expect(try listing(db).tuckedCount == 0, "no rule shows nothing — tucks nothing")
            // A real rule tucks its matches — within its OWN wing only
            // (nothing crosses wings).
            _ = try ops.applyTag(t.id, toPost: note.id)
            try db.write { db in
                try db.execute(
                    sql: "UPDATE reading SET query_spec = ? WHERE id = ?",
                    arguments: [try RuleGrammar.encode(.tag(t.id)), ruled.id])
            }
            let pool = try listing(db)
            #expect(pool.looseCount == 0)
            #expect(pool.tucked.map(\.postID) == [note.id])
            try db.write { db in
                try db.execute(
                    sql: "UPDATE reading SET wing_id = 'other-wing' WHERE id = ?",
                    arguments: [ruled.id])
            }
            #expect(try listing(db).tuckedCount == 0)
        }
    }

    @Test func anArrivalIsNotAHome() throws {
        try withOperations { ops, db in
            // A living book on #t that waits at Arrivals: tagging bells the
            // note — an ARRIVAL row, never membership — so the note is still
            // in the Pool (and shown by the gathering on #t, so tucked).
            let tag = try ops.createTag(name: "t")
            _ = try ops.createReading(
                name: "door", kind: .book, querySpec: try RuleGrammar.encode(.tag(tag.id)),
                intakeSeating: .arrivals)
            let note = try ops.createPost(title: "n")
            _ = try ops.applyTag(tag.id, toPost: note.id)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM reading_post WHERE post_id = ? AND status = 'arrival'",
                [note.id]) == 1)
            let pool = try listing(db)
            #expect(pool.loose.map(\.postID) == [note.id])
        }
    }

    /// **RED ON THE PRE-U4 READ (watched):** the old exclusion spelled each
    /// gathering as `NOT (<rule>)`, and a legacy term over a NULL column — a
    /// grandfathered `{"profile":"journal"}` rule against a note with no
    /// profile, which is every note `createPost`/`importPost` mints — made that
    /// `NOT (NULL)`, so the note vanished from the Pool though no gathering
    /// shows it. The split reads each rule's truth exactly as the assembly's
    /// WHERE does (NULL is not shown).
    @Test func aLegacyTermOverANullColumnNeverHidesANoteFromThePool() throws {
        try withOperations { ops, db in
            let journals = try ops.createReading(
                name: "old journal filter", kind: .gathering,
                querySpec: try RuleGrammar.encode(.legacyProfile("journal")))
            let plain = try ops.createPost(title: "a plain note")
            // The gathering does not show it…
            let shown = try db.read {
                try Queries.assembleReading($0, readingID: journals.id).map(\.postID)
            }
            #expect(!shown.contains(plain.id))
            // …so the Pool must.
            let pool = try db.read { try Queries.poolPosts($0, limit: 50).map(\.postID) }
            #expect(pool.contains(plain.id))
        }
    }

    /// P1 on the PLAN (the shipped statement, `poolListingSQL`): the notes by
    /// their kind index, the membership probe and the tag terms as index
    /// SEARCHes (no SCAN of `reading_post` or `post_tag`); nothing reads block
    /// or variant text.
    @Test func theSplitIsOneBoundedStatementThatNeverReadsText() throws {
        try withOperations { ops, db in
            let tag = try ops.createTag(name: "t")
            _ = try ops.createReading(
                name: "t", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(tag.id)))
            _ = try ops.createReading(
                name: "s", kind: .gathering, querySpec: try RuleGrammar.encode(.star))
            let a = try ops.createPost(title: "a")
            try ops.setStarred(.post(a.id), starred: true)
            let plan = try db.read { db -> [String] in
                let statement = try Queries.poolListingSQL(db)
                return try Row.fetchAll(
                    db, sql: "EXPLAIN QUERY PLAN \(statement.sql)",
                    arguments: StatementArguments(statement.arguments + [50]))
                    .map { ($0["detail"] as String?) ?? "" }
            }
            let joined = plan.joined(separator: "\n")
            #expect(joined.contains("idx_reading_post_post"), "\(joined)")
            // The tag term (the shipped rule predicate's own plan): the wing's
            // live tags by `uq_tag_path_live`, then a (tag, note) application
            // seek — ∝ the taxonomy, never the corpus.
            #expect(joined.contains("uq_post_tag_live"), "\(joined)")
            #expect(joined.contains("SEARCH c USING INDEX idx_container_kind"), "\(joined)")
            #expect(!joined.contains("SCAN rp"), "\(joined)")
            #expect(!joined.contains("SCAN pt"), "\(joined)")
            #expect(!joined.contains("block"), "\(joined)")
            #expect(!joined.contains("variant"), "\(joined)")
        }
    }
}
