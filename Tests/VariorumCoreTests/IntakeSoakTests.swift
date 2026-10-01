import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// 13i-b U1 — THE INTAKE SOAK (the plan §5's U1 evidence; P-7 "find bugs
/// before she does"). Seeded-random sequences over every act that touches
/// intake — tag / untag, star / unstar, mint inside a book, hand-add,
/// remove, seat, dismiss, finish / un-finish, rule edits, tag-all-members,
/// delete / restore a book, archive / unarchive a note — with the store-wide
/// invariants asserted after EVERY step. Typed refusals (`OperationError`)
/// are no-ops (the guards ARE the product); anything else escaping an
/// operation — a constraint error above all — fails the soak.
///
/// The invariants:
/// 1. no duplicate live pair (`uq_reading_post_live`'s promise, asserted);
/// 2. an arrival is never counted, listed or assembled as a member — the
///    assembly, the shelf count, the membership chip and the Pool all agree
///    with the live MEMBER rows exactly;
/// 3. intake never evicts: a live member row stays a live member except
///    through the explicit doors (remove, delete-book); statuses only ever
///    move arrival → member; rows are never physically removed;
/// 4. a removed member is never re-added by anything but her own hand-add
///    (or the exact-stamp revival of a restored book);
/// 5. a finished book holds no live arrival; a gathering holds no rows;
///    capacity is never exceeded;
/// 6. I2 and I10 untouched.
@Suite("13i-b U1 — the intake soak (randomized, invariants every step)")
struct IntakeSoakTests {
    @Test(arguments: [1, 7, 42, 99, 2026, 20_261_001] as [UInt64])
    func randomIntakeSequencesPreserveTheInvariants(seed: UInt64) throws {
        try withOperations(seed: seed) { ops, db in
            var soak = try Soak(ops: ops, db: db, rng: SeededGenerator(seed: seed &* 0x9E37_79B9))
            for step in 0..<300 {
                try soak.step(step)
            }
            // The soak must actually have exercised the machinery.
            #expect(soak.seen.contains("seat"), "no intake seat happened (seed \(seed))")
            #expect(soak.seen.contains("arrival"), "no arrival happened (seed \(seed))")
        }
    }
}

private struct Soak {
    let ops: Operations
    let db: AppDatabase
    var rng: SeededGenerator
    var seen: Set<String> = []

    var tags: [String] = []
    var books: [String] = []
    var gathering: String = ""
    var notes: [String] = []
    var rules: [String?] = []

    init(ops: Operations, db: AppDatabase, rng: SeededGenerator) throws {
        self.ops = ops
        self.db = db
        self.rng = rng
        let a = try ops.createTag(name: "a")
        let b = try ops.createTag(name: "b")
        let c = try ops.createTag(parent: a.id, name: "c")
        tags = [a.id, b.id, c.id]
        func enc(_ t: RuleTerm) throws -> String { try RuleGrammar.encode(t)! }
        rules = [
            try enc(.tag(a.id)), try enc(.tag(b.id)), try enc(.tag(c.id)),
            try enc(.and([.tag(a.id), .star])), try enc(.or([.tag(a.id), .tag(b.id)])),
            try enc(.and([.tag(a.id), .not(.tag(b.id))])), nil, "{malformed",
        ]
        books = [
            try ops.createReading(name: "on a", kind: .book, querySpec: rules[0]).id,
            try ops.createReading(name: "on b, capped", kind: .book, querySpec: rules[1],
                                  maxPosts: 3).id,
            try ops.createReading(name: "a and starred", kind: .book, querySpec: rules[3]).id,
            try ops.createReading(name: "guarded", kind: .book, querySpec: rules[4],
                                  intakeSeating: .arrivals).id,
            try ops.createReading(name: "outflow", kind: .book, querySpec: rules[2],
                                  autoTagId: b.id).id,
            try ops.createReading(name: "plain", kind: .book).id,
        ]
        gathering = try ops.createReading(name: "g", kind: .gathering, querySpec: rules[0]).id
        for i in 0..<4 { notes.append(try ops.createPost(title: "seed \(i)").id) }
    }

    private mutating func pick<T>(_ xs: [T]) -> T { xs[Int.random(in: 0..<xs.count, using: &rng)] }

    private func liveRows() throws -> [ReadingPost] {
        try db.read {
            try ReadingPost.fetchAll(
                $0, sql: "SELECT * FROM reading_post WHERE deleted_at IS NULL ORDER BY id")
        }
    }

    private func liveArrivalIDs() throws -> [String] {
        try db.read {
            try String.fetchAll(
                $0, sql: """
                    SELECT id FROM reading_post WHERE deleted_at IS NULL AND status = 'arrival'
                    ORDER BY id
                    """)
        }
    }

    /// Pairs whose only history is a tombstoned MEMBER row and no live row.
    private func removedPairs() throws -> Set<String> {
        try db.read {
            Set(try String.fetchAll($0, sql: """
                SELECT reading_id || '|' || post_id FROM reading_post
                GROUP BY reading_id, post_id
                HAVING SUM(deleted_at IS NULL) = 0
                   AND SUM(deleted_at IS NOT NULL AND status = 'member') > 0
                """))
        }
    }

    mutating func step(_ index: Int) throws {
        let beforeLive = try liveRows()
        let beforeMembers = Set(beforeLive.filter { $0.status == .member }.map(\.id))
        let beforeRemoved = try removedPairs()
        let beforeTotal = try db.fetchInt("SELECT COUNT(*) FROM reading_post") ?? 0

        // What the step may legitimately end (invariant 3's explicit doors).
        var endedPair: String?
        var endedBook: String?
        var handAddedPair: String?
        var restoredBook: String?

        let roll = Int.random(in: 0..<100, using: &rng)
        let label: String
        do {
            switch roll {
            case 0..<8:
                label = "createPost"
                notes.append(try ops.createPost(title: "n\(index)").id)
            case 8..<30:
                label = "applyTag"
                _ = try ops.applyTag(pick(tags), toPost: pick(notes))
            case 30..<38:
                label = "removeTag"
                try ops.removeTag(pick(tags), fromPost: pick(notes))
            case 38..<48:
                label = "setStarred"
                let starred = Bool.random(using: &rng)
                try ops.setStarred(.post(pick(notes)), starred: starred)
            case 48..<53:
                label = "newPostInReading"
                notes.append(try ops.newPostInReading(pick(books), title: "minted \(index)").id)
            case 53..<59:
                label = "addPostToReading"
                let book = pick(books), note = pick(notes)
                handAddedPair = "\(book)|\(note)"
                try ops.addPostToReading(note, to: book)
            case 59..<64:
                label = "removePostFromReading"
                let book = pick(books), note = pick(notes)
                endedPair = "\(book)|\(note)"
                try ops.removePostFromReading(note, from: book)
            case 64..<70:
                label = "seatArrival"
                let arrivals = try liveArrivalIDs()
                guard !arrivals.isEmpty else { return }
                try ops.seatArrival(pick(arrivals))
            case 70..<75:
                label = "dismissArrival"
                let arrivals = try liveArrivalIDs()
                guard !arrivals.isEmpty else { return }
                try ops.dismissArrival(pick(arrivals))
            case 75..<80:
                label = "lockReading"
                try ops.lockReading(pick(books))
            case 80..<86:
                label = "unlockReading"
                try ops.unlockReading(pick(books))
            case 86..<90:
                label = "setReadingQuerySpec"
                try ops.setReadingQuerySpec(pick(books), querySpec: pick(rules))
            case 90..<92:
                label = "tagAllMembers"
                try ops.tagAllMembers(books[4])
            case 92..<94:
                label = "deleteReading"
                let book = pick(books)
                endedBook = book
                try ops.deleteReading(book)
            case 94..<96:
                label = "restoreReading"
                let book = pick(books)
                restoredBook = book
                try ops.restoreReading(book)
            case 96..<98:
                label = "archiveContainer"
                try ops.archiveContainer(pick(notes))
            default:
                label = "unarchiveContainer"
                try ops.unarchiveContainer(pick(notes))
            }
        } catch is OperationError {
            return  // a typed refusal is a no-op — the guard IS the product
        }

        let afterLive = try liveRows()
        let liveByID = Dictionary(uniqueKeysWithValues: afterLive.map { ($0.id, $0) })
        let afterTotal = try db.fetchInt("SELECT COUNT(*) FROM reading_post") ?? 0
        let context = "seed step \(index) (\(label))"

        // Telemetry: did intake actually do something on this step?
        let born = afterLive.filter { row in !beforeLive.contains { $0.id == row.id } }
        if born.contains(where: { $0.status == .member }) && label != "addPostToReading"
            && label != "newPostInReading" { seen.insert("seat") }
        if born.contains(where: { $0.status == .arrival }) { seen.insert("arrival") }

        // 1. No duplicate live pair.
        #expect(try db.fetchInt("""
            SELECT COUNT(*) FROM (SELECT 1 FROM reading_post WHERE deleted_at IS NULL
                                  GROUP BY reading_id, post_id HAVING COUNT(*) > 1)
            """) == 0, "duplicate live pair at \(context)")

        // 3. Intake never evicts; rows are never physically removed; status
        //    only ever moves arrival → member.
        #expect(afterTotal >= beforeTotal, "a row vanished at \(context)")
        for id in beforeMembers {
            let before = try #require(beforeLive.first { $0.id == id })
            let pair = "\(before.readingId)|\(before.postId)"
            if pair == endedPair || before.readingId == endedBook { continue }
            #expect(liveByID[id]?.status == .member,
                    "member row \(id) evicted or demoted at \(context)")
        }

        // 4. A removed member returns only by her hand-add or a restore's
        //    exact-stamp revival.
        let afterPairs = Set(afterLive.map { "\($0.readingId)|\($0.postId)" })
        for pair in beforeRemoved where afterPairs.contains(pair) {
            let book = String(pair.split(separator: "|")[0])
            #expect(pair == handAddedPair || book == restoredBook,
                    "a removed member \(pair) was re-added by intake at \(context)")
        }

        try assertMemberReadersAgree(context)
        try assertStructural(context)
    }

    /// 2 + 5: every member-reader agrees with the live MEMBER rows exactly.
    private func assertMemberReadersAgree(_ context: String) throws {
        try db.read { db in
            let shelf = try Queries.bookshelf(db)
            for reading in try Queries.readings(db) {
                let memberRows = try String.fetchAll(db, sql: """
                    SELECT post_id FROM reading_post
                    WHERE reading_id = ? AND deleted_at IS NULL AND status = 'member'
                    """, arguments: [reading.id])
                let arrivalRows = Set(try String.fetchAll(db, sql: """
                    SELECT post_id FROM reading_post
                    WHERE reading_id = ? AND deleted_at IS NULL AND status = 'arrival'
                    """, arguments: [reading.id]))
                let assembled = try Queries.assembleReading(db, readingID: reading.id)
                    .map(\.postID)
                if reading.kind == .gathering {
                    #expect(memberRows.isEmpty && arrivalRows.isEmpty,
                            "a gathering holds rows at \(context)")
                    continue
                }
                let visibleMembers = Set(try String.fetchAll(db, sql: """
                    SELECT rp.post_id FROM reading_post rp
                    JOIN container c ON c.id = rp.post_id AND c.deleted_at IS NULL
                     AND c.archived_at IS NULL
                    WHERE rp.reading_id = ? AND rp.deleted_at IS NULL AND rp.status = 'member'
                    """, arguments: [reading.id]))
                #expect(Set(assembled) == visibleMembers,
                        "assembly ≠ members of \(reading.name) at \(context)")
                #expect(Set(assembled).isDisjoint(with: arrivalRows),
                        "an arrival assembled as a member at \(context)")
                #expect(shelf.first { $0.reading.id == reading.id }?.postCount == memberRows.count,
                        "the shelf counted an arrival at \(context)")
                if reading.locked {
                    #expect(arrivalRows.isEmpty, "a finished book holds a bell at \(context)")
                }
                if let cap = reading.maxPosts {
                    #expect(memberRows.count <= cap, "capacity exceeded at \(context)")
                }
            }
            // The chip and the Pool, per note.
            let pool = Set(try Queries.poolPosts(db, limit: 10_000).map(\.postID))
            for note in notes {
                let memberBooks = Set(try String.fetchAll(db, sql: """
                    SELECT rp.reading_id FROM reading_post rp
                    JOIN reading r ON r.id = rp.reading_id AND r.deleted_at IS NULL
                    WHERE rp.post_id = ? AND rp.deleted_at IS NULL AND rp.status = 'member'
                    """, arguments: [note]))
                let chipBooks = Set(try Queries.readingsContaining(db, postID: note)
                    .filter { $0.kind == .book }.map(\.id))
                #expect(chipBooks == memberBooks, "the chip listed an arrival at \(context)")
                if !memberBooks.isEmpty {
                    #expect(!pool.contains(note), "a member listed in the Pool at \(context)")
                }
            }
        }
    }

    /// 6. I2 + I10 (the InvariantSweep predicates).
    private func assertStructural(_ context: String) throws {
        #expect(try db.fetchInt("""
            SELECT COUNT(*) FROM block b WHERE b.deleted_at IS NULL AND NOT EXISTS (
              SELECT 1 FROM variant v WHERE v.block_id = b.id AND v.deleted_at IS NULL
                AND v.status = 'active')
            """) == 0, "I10 at \(context)")
        #expect(try db.fetchInt("""
            SELECT COUNT(*) FROM (SELECT block_id FROM container_block
                                  WHERE deleted_at IS NULL GROUP BY block_id HAVING COUNT(*) > 1)
            """) == 0, "I2 at \(context)")
    }
}
