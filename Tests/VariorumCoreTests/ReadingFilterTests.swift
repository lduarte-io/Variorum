import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// 13i-b U4 — **the in-book filter, mechanics** (the sitting record §18.1, her
/// ORIGINAL sitting ask). A view-local tag/star filter over a reading's
/// assembly (a read — never membership) and "Save this filter as a gathering"
/// (rule = the reading's tag association ∧ the filter). Headless; the bar and
/// the door's face are 13i-d's. New surface: these pins are its specification.
@Suite("13i-b U4 — the in-book filter: the view-local read + saveFilterAsGathering")
struct ReadingFilterTests {
    private struct Book {
        let book: Reading
        let a: Container  // #x
        let b: Container  // #y
        let c: Container  // #x, starred
        let x: VariorumCore.Tag
        let y: VariorumCore.Tag
    }

    private func book(_ ops: Operations, maxPosts: Int? = nil) throws -> Book {
        let x = try ops.createTag(name: "x")
        let y = try ops.createTag(name: "y")
        let book = try ops.createReading(name: "the book", kind: .book, maxPosts: maxPosts)
        let a = try ops.createPost(title: "a")
        let b = try ops.createPost(title: "b")
        let c = try ops.createPost(title: "c")
        _ = try ops.applyTag(x.id, toPost: a.id)
        _ = try ops.applyTag(y.id, toPost: b.id)
        _ = try ops.applyTag(x.id, toPost: c.id)
        try ops.setStarred(.post(c.id), starred: true)
        for note in [a, b, c] where maxPosts == nil {
            try ops.addPostToReading(note.id, to: book.id)
        }
        return Book(book: book, a: a, b: b, c: c, x: x, y: y)
    }

    private func view(
        _ db: AppDatabase, _ id: String, _ filter: RuleTerm?, limit: Int? = nil
    ) throws -> [String] {
        try db.read {
            try Queries.assembleReading($0, readingID: id, limit: limit, filter: filter)
                .map(\.postID)
        }
    }

    // MARK: - The view-local read

    @Test func aFilterNarrowsTheBooksAssemblyInItsOwnOrderAndWritesNothing() throws {
        try withOperations { ops, db in
            let w = try book(ops)
            #expect(try view(db, w.book.id, nil) == [w.a.id, w.b.id, w.c.id])
            try db.clearOutbox()
            let before = try db.fetchInt("SELECT COUNT(*) FROM reading_post")
            #expect(try view(db, w.book.id, .tag(w.x.id)) == [w.a.id, w.c.id])
            #expect(try view(db, w.book.id, .star) == [w.c.id])
            #expect(try view(db, w.book.id, .and([.tag(w.x.id), .not(.star)])) == [w.a.id])
            #expect(try view(db, w.book.id, .or([.tag(w.y.id), .star])) == [w.b.id, w.c.id])
            // A read: membership untouched, nothing queued for sync.
            #expect(try db.fetchInt("SELECT COUNT(*) FROM reading_post") == before)
            #expect(try db.fetchInt("SELECT COUNT(*) FROM sync_outbox") == 0)
            // nil is byte-identical to the unfiltered read.
            let plain = try db.read { try Queries.assembleReading($0, readingID: w.book.id) }
            let nilFiltered = try db.read {
                try Queries.assembleReading($0, readingID: w.book.id, filter: nil)
            }
            #expect(plain == nilFiltered)
        }
    }

    @Test func chaptersSurviveTheFilter() throws {
        try withOperations { ops, db in
            let w = try book(ops)
            let one = try ops.createSection(in: w.book.id, name: "one")
            try ops.assignPostToSection(w.c.id, in: w.book.id, section: one.id)
            let entries = try db.read {
                try Queries.assembleReading($0, readingID: w.book.id, filter: .tag(w.x.id))
            }
            // Chapters lead, unfiled trail — the book's own grouped order.
            #expect(entries.map(\.postID) == [w.c.id, w.a.id])
            #expect(entries.map(\.sectionPath) == ["one", nil])
        }
    }

    @Test func aFilterNarrowsAGatheringsAssemblyToo() throws {
        try withOperations { ops, db in
            let w = try book(ops)
            let gathering = try ops.createReading(
                name: "x gathering", kind: .gathering,
                querySpec: try RuleGrammar.encode(.tag(w.x.id)))
            #expect(try view(db, gathering.id, nil) == [w.a.id, w.c.id])
            #expect(try view(db, gathering.id, .star) == [w.c.id])
        }
    }

    /// A capped book's filtered view is a subset of what she SEES — never a
    /// member past the cap — and the caller's window applies last.
    @Test func aCappedBooksFilterNeverReachesPastTheCap() throws {
        try withOperations { ops, db in
            let w = try book(ops, maxPosts: 2)
            for note in [w.a, w.b, w.c] {
                // Members past the cap: a lowered cap is legal (#25(d)).
                try db.write { db in
                    try db.execute(
                        sql: """
                            INSERT INTO reading_post (id, reading_id, post_id, position, created_at)
                            VALUES (?, ?, ?, ?, '2026-07-01T00:00:00.000Z')
                            """,
                        arguments: ["rp-\(note.title ?? "")", w.book.id, note.id,
                                    "a\(note.title ?? "")"])
                }
            }
            #expect(try view(db, w.book.id, nil) == [w.a.id, w.b.id])
            #expect(try view(db, w.book.id, .tag(w.x.id)) == [w.a.id], "c is past the cap")
            #expect(try view(db, w.book.id, .or([.tag(w.x.id), .tag(w.y.id)]), limit: 1)
                    == [w.a.id])
        }
    }

    // MARK: - Save this filter as a gathering

    private func rule(_ db: AppDatabase, _ id: String) throws -> RuleTerm? {
        RuleGrammar.decode(try db.read { try Reading.fetchOne($0, key: id)?.querySpec })
    }

    @Test func aLivingBooksRuleIsTheAssociation() throws {
        try withOperations { ops, db in
            let w = try book(ops)
            try ops.setReadingQuerySpec(w.book.id, querySpec: try RuleGrammar.encode(.tag(w.x.id)))
            let bookBefore = try db.snapshotRow("reading", w.book.id, excluding: [])
            let saved = try ops.saveFilterAsGathering(w.book.id, filter: .star, name: "x, starred")
            #expect(saved.association == .rule)
            #expect(try rule(db, saved.reading.id) == .and([.tag(w.x.id), .star]))
            #expect(saved.reading.kind == .gathering)
            #expect(saved.reading.name == "x, starred")
            #expect(saved.reading.wingId == w.book.wingId)
            #expect(saved.reading.shelfId == nil)
            #expect(saved.reading.starred == false)
            // The book is untouched — saving a filter never edits it.
            #expect(try db.snapshotRow("reading", w.book.id, excluding: []) == bookBefore)
            // What it gathers: x ∧ ★.
            #expect(try view(db, saved.reading.id, nil) == [w.c.id])
        }
    }

    @Test func theConjunctionIsFlat() throws {
        try withOperations { ops, db in
            let w = try book(ops)
            let z = try ops.createTag(name: "z")
            try ops.setReadingQuerySpec(
                w.book.id, querySpec: try RuleGrammar.encode(.and([.tag(w.x.id), .tag(w.y.id)])))
            let saved = try ops.saveFilterAsGathering(
                w.book.id, filter: .and([.star, .not(.tag(z.id))]), name: "flat")
            #expect(try rule(db, saved.reading.id)
                    == .and([.tag(w.x.id), .tag(w.y.id), .star, .not(.tag(z.id))]))
        }
    }

    @Test func aRulelessBooksAutoTagIsTheAssociationElseTheFilterAlone() throws {
        try withOperations { ops, db in
            let w = try book(ops)
            // No rule, no auto-tag: the filter alone (reported).
            let bare = try ops.saveFilterAsGathering(w.book.id, filter: .star, name: "bare")
            #expect(bare.association == .none)
            #expect(try rule(db, bare.reading.id) == .star)

            // An auto-tag: what notes written here wear.
            let outflow = try ops.createTag(name: "outflow")
            try ops.setReadingAutoTag(w.book.id, tagID: outflow.id)
            let tagged = try ops.saveFilterAsGathering(w.book.id, filter: .star, name: "tagged")
            #expect(tagged.association == .autoTag)
            #expect(try rule(db, tagged.reading.id) == .and([.tag(outflow.id), .star]))

            // A DEAD auto-tag is no association (the read-time fallback class).
            try ops.deleteTag(outflow.id)
            let dead = try ops.saveFilterAsGathering(w.book.id, filter: .star, name: "dead")
            #expect(dead.association == .none)
            #expect(try rule(db, dead.reading.id) == .star)
        }
    }

    @Test func aBooksMalformedRuleFallsThroughToItsAutoTag() throws {
        try withOperations { ops, db in
            let w = try book(ops)
            let outflow = try ops.createTag(name: "outflow")
            try ops.setReadingAutoTag(w.book.id, tagID: outflow.id)
            try db.write { db in
                try db.execute(
                    sql: "UPDATE reading SET query_spec = '{broken' WHERE id = ?",
                    arguments: [w.book.id])
            }
            let saved = try ops.saveFilterAsGathering(w.book.id, filter: .tag(w.x.id), name: "s")
            #expect(saved.association == .autoTag)
            #expect(try rule(db, saved.reading.id) == .and([.tag(outflow.id), .tag(w.x.id)]))
        }
    }

    @Test func aGatheringsRuleIsTheAssociationAndTheSavedOneShowsTheFilteredView() throws {
        try withOperations { ops, db in
            let w = try book(ops)
            let gathering = try ops.createReading(
                name: "x gathering", kind: .gathering,
                querySpec: try RuleGrammar.encode(.tag(w.x.id)))
            let saved = try ops.saveFilterAsGathering(gathering.id, filter: .star, name: "x ★")
            #expect(saved.association == .rule)
            // A gathering's filtered view and the saved gathering are the SAME
            // predicate — exactly what she was looking through.
            #expect(Set(try view(db, saved.reading.id, nil))
                    == Set(try view(db, gathering.id, .star)))

            // A rule-less gathering shows everything in its wing: ∧ is the
            // filter alone, exactly.
            let all = try ops.createReading(name: "everything", kind: .gathering)
            let fromAll = try ops.saveFilterAsGathering(all.id, filter: .tag(w.y.id), name: "y")
            #expect(fromAll.association == .rule)
            #expect(try rule(db, fromAll.reading.id) == .tag(w.y.id))
        }
    }

    @Test func itRefusesWhatItCannotRead() throws {
        try withOperations { ops, db in
            let broken = try ops.createReading(name: "broken", kind: .gathering, querySpec: "{nope")
            #expect(throws: OperationError.self) {
                try ops.saveFilterAsGathering(broken.id, filter: .star, name: "n")
            }
            #expect(throws: OperationError.readingNotFound(id: "gone")) {
                try ops.saveFilterAsGathering("gone", filter: .star, name: "n")
            }
            #expect(try db.fetchInt("SELECT COUNT(*) FROM reading") == 1, "nothing minted")
        }
    }

    // MARK: - The pure conjunction

    @Test func conjoinSpreadsTopLevelAndsAndKeepsTheFilterAloneWhenThereIsNoAssociation() {
        #expect(RuleGrammar.conjoin(nil, .star) == .star)
        #expect(RuleGrammar.conjoin(.tag("a"), .star) == .and([.tag("a"), .star]))
        #expect(RuleGrammar.conjoin(.and([.tag("a"), .tag("b")]), .and([.star]))
                == .and([.tag("a"), .tag("b"), .star]))
        // An OR stays one term (its grouping is its meaning).
        #expect(RuleGrammar.conjoin(.or([.tag("a"), .tag("b")]), .star)
                == .and([.or([.tag("a"), .tag("b")]), .star]))
        // An empty AND is "no constraint" — kept as a term, never spread to nothing.
        #expect(RuleGrammar.conjoin(.and([]), .star) == .and([.and([]), .star]))
    }
}
