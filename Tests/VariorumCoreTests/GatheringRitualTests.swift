import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// 13i-b U1 — THE PHASE'S ACCEPTANCE SPINE, headless (the 13i-b plan §5: "the
/// R3 ritual as a headless walk … plus lesson-sentence truth checks (§25
/// lessons 3–4)"). The sitting record §25's rule binds every assertion here:
/// "every lesson is a sentence the field guide must be able to say
/// TRUTHFULLY of the shipped build — if the build makes any sentence false,
/// the build is wrong, not the sentence." Each lesson sentence stands as a
/// comment above the behaviour that makes it true. The tutorial chapter's
/// FACE is 13i-d's; this is the store underneath it.
///
/// The bind door's face is U3's; the op it will call already expresses
/// keep-collecting with no recast: `convertSmartReadingToCurated` flips the
/// SAME row to a book, materializes the assembly as members, and leaves the
/// rule on the row — and a book with a rule is a living book (U1's intake).
@Suite("13i-b U1 — the R3 ritual + lessons 3–4, headless")
struct GatheringRitualTests {
    private func assembled(_ db: AppDatabase, _ readingID: String) throws -> [String] {
        try db.read { try Queries.assembleReading($0, readingID: readingID).map(\.postID) }
    }

    // MARK: - R3 — the gathering's life (§25: "taught by DOING — the walk asserts each")

    @Test func ritualR3TheGatheringsLife() throws {
        try withOperations { ops, db in
            let tag = try ops.createTag(name: "video-ideas")
            let rule = try #require(try RuleGrammar.encode(.tag(tag.id)))

            // "tag two notes"
            let first = try ops.createPost(title: "the first idea")
            let second = try ops.createPost(title: "the second idea")
            _ = try ops.applyTag(tag.id, toPost: first.id)
            _ = try ops.applyTag(tag.id, toPost: second.id)

            // "make a gathering from the tag" — it shows both, holding nothing.
            let gathering = try ops.createReading(
                name: "video ideas", kind: .gathering, querySpec: rule)
            try ops.setShelfPinned(gathering.id, pinned: true)   // the one star (§7)
            #expect(try assembled(db, gathering.id) == [first.id, second.id])
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM reading_post WHERE reading_id = ?", [gathering.id]) == 0)

            // "untag one and watch it leave"
            try ops.removeTag(tag.id, fromPost: first.id)
            #expect(try assembled(db, gathering.id) == [second.id])

            // "bind the gathering into a book" — in place: the SAME row (§19.6:
            // name, star, everything survives the bind).
            let bound = try ops.convertSmartReadingToCurated(gathering.id)
            #expect(bound.reading.id == gathering.id)
            let row = try #require(try db.read { try Queries.reading($0, id: gathering.id) })
            #expect(row.kind == .book)
            #expect(row.name == "video ideas")
            #expect(row.starred)
            #expect(row.querySpec == rule)                        // the rule STAYS
            #expect(try assembled(db, gathering.id) == [second.id])

            // …and it keeps collecting (the lesson below) — a third note.
            let third = try ops.createPost(title: "the third idea")
            _ = try ops.applyTag(tag.id, toPost: third.id)
            #expect(try assembled(db, gathering.id) == [second.id, third.id])

            // "reorder it" — hand order is the book's now.
            try ops.reorderReadingPost(third.id, in: gathering.id, to: .start)
            #expect(try assembled(db, gathering.id) == [third.id, second.id])

            // "untag the other and watch it STAY" — membership rows are
            // truth; untagging is a non-event (§19, ratified §24).
            try ops.removeTag(tag.id, fromPost: second.id)
            #expect(try assembled(db, gathering.id) == [third.id, second.id])
        }
    }

    // MARK: - Lesson 3 — Gatherings

    @Test func lesson3EverySentenceIsTrue() throws {
        try withOperations { ops, db in
            let tag = try ops.createTag(name: "poems")
            let rule = try #require(try RuleGrammar.encode(.tag(tag.id)))
            let a = try ops.createPost(title: "a")
            let b = try ops.createPost(title: "b")
            _ = try ops.applyTag(tag.id, toPost: a.id)
            _ = try ops.applyTag(tag.id, toPost: b.id)

            // "A gathering is made from a tag."
            let gathering = try ops.createReading(name: "poems", kind: .gathering, querySpec: rule)
            #expect(try assembled(db, gathering.id) == [a.id, b.id])

            // "Remove the tag and the note leaves on its own."
            try ops.removeTag(tag.id, fromPost: a.id)
            #expect(try assembled(db, gathering.id) == [b.id])
            _ = try ops.applyTag(tag.id, toPost: a.id)

            // "You can't rearrange a gathering —" there is no membership to
            // move: the reorder door refuses, and the order stays derived.
            #expect(throws: OperationError.postNotInReading(postID: b.id, readingID: gathering.id)) {
                try ops.reorderReadingPost(b.id, in: gathering.id, to: .start)
            }
            #expect(try assembled(db, gathering.id) == [a.id, b.id])

            // "bind it into a book to take it in hand,"
            try ops.convertSmartReadingToCurated(gathering.id)
            try ops.reorderReadingPost(b.id, in: gathering.id, to: .start)
            #expect(try assembled(db, gathering.id) == [b.id, a.id])

            // "and it keeps collecting after you do."
            let c = try ops.createPost(title: "c")
            _ = try ops.applyTag(tag.id, toPost: c.id)
            #expect(try assembled(db, gathering.id) == [b.id, a.id, c.id])
        }
    }

    // MARK: - Lesson 4 — Arrivals

    @Test func lesson4EverySentenceIsTrue() throws {
        try withOperations { ops, db in
            let tag = try ops.createTag(name: "letters")
            let rule = try #require(try RuleGrammar.encode(.tag(tag.id)))
            let book = try ops.createReading(
                name: "letters", kind: .book, querySpec: rule, maxPosts: 2)
            func waiting() throws -> [ReadingPost] {
                try db.read {
                    try ReadingPost.fetchAll($0, sql: """
                        SELECT * FROM reading_post WHERE reading_id = ? AND deleted_at IS NULL
                          AND status = 'arrival' ORDER BY created_at, position, id
                        """, arguments: [book.id])
                }
            }

            // "A collecting book auto-adds freely;"
            let one = try ops.createPost(title: "one")
            _ = try ops.applyTag(tag.id, toPost: one.id)
            let two = try ops.createPost(title: "two")
            _ = try ops.applyTag(tag.id, toPost: two.id)
            #expect(try assembled(db, book.id) == [one.id, two.id])

            // "anything it can't seat on its own waits at Arrivals for you to
            // judge —" (here: the book is full; an owned-elsewhere note is the
            // other road, pinned in IntakeOperationsTests until 13i-c's doors)
            let three = try ops.createPost(title: "three")
            _ = try ops.applyTag(tag.id, toPost: three.id)
            let four = try ops.createPost(title: "four")
            _ = try ops.applyTag(tag.id, toPost: four.id)
            #expect(try assembled(db, book.id) == [one.id, two.id])
            #expect(try waiting().map(\.postId) == [three.id, four.id])

            // "— add it," (room made by hand, then the judgment)
            try ops.removePostFromReading(one.id, from: book.id)
            try ops.seatArrival(try #require(try waiting().first).id)
            #expect(try assembled(db, book.id) == [two.id, three.id])

            // "copy it in," — the OWNED arm's door is 13i-c's (no op exists
            // yet; nothing here makes the clause false).

            // "or dismiss it."
            let five = try ops.createPost(title: "five")
            _ = try ops.applyTag(tag.id, toPost: five.id)
            #expect(try waiting().map(\.postId) == [four.id, five.id])
            try ops.dismissArrival(try #require(try waiting().last).id)
            #expect(try waiting().map(\.postId) == [four.id])

            // "Finishing a book dismisses whatever is still waiting."
            try ops.lockReading(book.id)
            #expect(try waiting().isEmpty)
            #expect(try assembled(db, book.id) == [two.id, three.id])
        }
    }
}
