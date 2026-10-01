import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// 13i-c U2 — **THE OWNERSHIP SOAK** (the 13i-c plan §7 U2 row; P-7 "find bugs
/// before she does"). Seeded-random sequences over every act the owned/sealed
/// family touches — own / stop owning, add (through the consult), copy in,
/// move in (and their answering arms), remove/release, the arrival seat,
/// tagging (intake's owned arms), finish / reopen, seal / unseal, delete book
/// only / with its notes, restore a book, delete / restore a note, duplicate
/// (shallow and deep), diverge — with the store-wide invariants asserted after
/// EVERY step. Typed refusals (`OperationError`) are no-ops (the guards ARE
/// the product); anything else escaping an operation fails the soak.
///
/// The invariants:
/// 1. **exclusivity** — no note is a live member of an OWNED book AND of any
///    other live book (§6: "there is no second place it lives");
/// 2. **the seal** — every live member of a live SEALED book is a sealed note
///    (its stamp the book's, or its own earlier one — "independent");
/// 3. no duplicate live pair (`uq_reading_post_live`'s promise, asserted);
/// 4. I10 — every live block keeps a live active take; I2 — one live
///    placement per block.
@Suite("13i-c U2 — the ownership soak (randomized, invariants every step)")
struct OwnershipSoakTests {
    @Test(arguments: [3, 11, 64, 777, 2026, 20_261_001] as [UInt64])
    func randomOwnershipSequencesPreserveTheInvariants(seed: UInt64) throws {
        try withOperations(seed: seed) { ops, db in
            var soak = try OwnershipSoak(
                ops: ops, db: db, rng: SeededGenerator(seed: seed &* 0x2545_F491))
            for step in 0..<250 {
                try soak.step(step)
            }
            // The soak must have exercised the machinery it claims to.
            for act in ["own", "copyIn", "moveIn", "seal", "unseal", "refusal:choice",
                        "restoreReading", "deleteWithNotes"] {
                #expect(soak.seen.contains(act), "never exercised \(act) (seed \(seed))")
            }
        }
    }
}

private struct OwnershipSoak {
    let ops: Operations
    let db: AppDatabase
    var rng: SeededGenerator
    var seen: Set<String> = []
    var tags: [String] = []
    var books: [String] = []
    var notes: [String] = []

    init(ops: Operations, db: AppDatabase, rng: SeededGenerator) throws {
        self.ops = ops
        self.db = db
        self.rng = rng
        let a = try ops.createTag(name: "a")
        let b = try ops.createTag(name: "b")
        tags = [a.id, b.id]
        func enc(_ t: RuleTerm) throws -> String { try RuleGrammar.encode(t)! }
        books = [
            try ops.createReading(name: "one", kind: .book).id,
            try ops.createReading(name: "two", kind: .book).id,
            try ops.createReading(name: "living a", kind: .book, querySpec: try enc(.tag(a.id))).id,
            try ops.createReading(name: "guarded b", kind: .book, querySpec: try enc(.tag(b.id)),
                                  intakeSeating: .arrivals).id,
            try ops.createReading(name: "capped", kind: .book, maxPosts: 3).id,
        ]
        for i in 0..<8 {
            let post = try ops.createPost(title: "note \(i)")
            try ops.seedBlock(in: post.id, text: "the text of note \(i)")
            notes.append(post.id)
        }
    }

    private mutating func pick<T>(_ items: [T]) -> T {
        items[Int(rng.next() % UInt64(items.count))]
    }

    /// Typed refusals are the product; anything else escapes and fails.
    var log: [String] = []

    private mutating func attempt(_ name: String, _ body: () throws -> Void) throws {
        do {
            try body()
            seen.insert(name)
            log.append(name)
        } catch let error as OperationError {
            switch error {
            case .noteMemberedElsewhere, .noteOwnedElsewhere: seen.insert("refusal:choice")
            default: break
            }
        }
    }

    private func liveArrivals(_ readingID: String) throws -> [String] {
        try db.read {
            try String.fetchAll(
                $0, sql: """
                    SELECT id FROM reading_post
                    WHERE reading_id = ? AND deleted_at IS NULL AND status = 'arrival'
                    ORDER BY id
                    """,
                arguments: [readingID])
        }
    }

    private func deletedBooks() throws -> [String] {
        try db.read {
            try String.fetchAll($0, sql: "SELECT id FROM reading WHERE deleted_at IS NOT NULL ORDER BY id")
        }
    }

    private func deletedNotes() throws -> [String] {
        try db.read {
            try String.fetchAll(
                $0, sql: """
                    SELECT id FROM container WHERE kind = 'post' AND deleted_at IS NOT NULL
                      AND NOT (archived_at IS NOT NULL AND archived_at = created_at)
                    ORDER BY id
                    """)
        }
    }

    private func liveNotes() throws -> [String] {
        try db.read {
            try String.fetchAll(
                $0, sql: """
                    SELECT id FROM container WHERE kind = 'post' AND deleted_at IS NULL
                      AND NOT (archived_at IS NOT NULL AND archived_at = created_at)
                    ORDER BY id
                    """)
        }
    }

    mutating func step(_ step: Int) throws {
        let ops = self.ops
        let books = self.books + (try db.read {
            try String.fetchAll($0, sql: """
                SELECT id FROM reading WHERE deleted_at IS NULL AND kind = 'book' ORDER BY id
                """)
        })
        let book = pick(Array(Set(books)).sorted())
        let live = try liveNotes()
        guard !live.isEmpty else {
            if let dead = try deletedNotes().first {
                try attempt("restoreNote") { try ops.restoreContainer(dead) }
            }
            return
        }
        let note = pick(live)
        switch rng.next() % 20 {
        case 0, 1: try attempt("own") { try ops.setReadingOwned(book, owned: true) }
        case 2: try attempt("unown") { try ops.setReadingOwned(book, owned: false) }
        case 3, 4, 5: try attempt("add") { try ops.addPostToReading(note, to: book) }
        case 6: try attempt("copyIn") { try ops.copyPostIntoReading(note, into: book) }
        case 7: try attempt("moveIn") { try ops.movePostIntoReading(note, into: book) }
        case 8: try attempt("remove") { try ops.removePostFromReading(note, from: book) }
        case 9:
            let tag = pick(tags)
            try attempt("tag") { try ops.applyTag(tag, toPost: note) }
        case 10:
            if let arrival = try liveArrivals(book).first {
                switch rng.next() % 4 {
                case 0: try attempt("seat") { try ops.seatArrival(arrival) }
                case 1: try attempt("copyIn") { try ops.copyPostIntoReading(answering: arrival) }
                case 2: try attempt("moveIn") { try ops.movePostIntoReading(answering: arrival) }
                default: try attempt("dismiss") { try ops.dismissArrival(arrival) }
                }
            }
        case 11:
            if rng.next() % 2 == 0 {
                try attempt("finish") { try ops.lockReading(book) }
            } else {
                try attempt("reopen") { try ops.unlockReading(book) }
            }
        case 12: try attempt("seal") { try ops.sealReading(book) }
        case 13: try attempt("unseal") { try ops.unsealReading(book) }
        case 14:
            if rng.next() % 2 == 0 {
                try attempt("deleteBook") { try ops.deleteReading(book) }
            } else {
                try attempt("deleteWithNotes") { try ops.deleteReadingWithNotes(book) }
            }
        case 15:
            if let dead = try deletedBooks().first {
                try attempt("restoreReading") { try ops.restoreReading(dead) }
            }
        case 16: try attempt("deleteNote") { try ops.deleteContainer(note) }
        case 17:
            if let dead = try deletedNotes().last {
                try attempt("restoreNote") { try ops.restoreContainer(dead) }
            }
        case 18:
            let deep = rng.next() % 2 == 0
            try attempt("duplicate") {
                _ = try ops.duplicateReading(book, name: "dup \(step)", deep: deep)
            }
        default: try attempt("diverge") { try ops.divergePostForReading(note, in: book) }
        }
        try assertInvariants(step: step)
    }

    private func assertInvariants(step: Int) throws {
        let exclusivity = try db.fetchInt(
            """
            SELECT COUNT(*) FROM (
              SELECT rp.post_id FROM reading_post rp
              JOIN reading r ON r.id = rp.reading_id AND r.deleted_at IS NULL AND r.kind = 'book'
              WHERE rp.deleted_at IS NULL AND rp.status = 'member'
              GROUP BY rp.post_id HAVING COUNT(*) > 1 AND SUM(r.owned) > 0)
            """)
        #expect(exclusivity == 0, "step \(step): a note lives in an owned book AND elsewhere")
        let unsealedInSealed = try db.fetchInt(
            """
            SELECT COUNT(*) FROM reading_post rp
            JOIN reading r ON r.id = rp.reading_id AND r.deleted_at IS NULL
             AND r.sealed_at IS NOT NULL
            JOIN container c ON c.id = rp.post_id AND c.deleted_at IS NULL
            WHERE rp.deleted_at IS NULL AND rp.status = 'member' AND c.locked = 0
            """)
        #expect(unsealedInSealed == 0, "step \(step): a sealed book holds an unsealed member \(log.suffix(6))")
        let duplicatePairs = try db.fetchInt(
            """
            SELECT COUNT(*) FROM (SELECT 1 FROM reading_post WHERE deleted_at IS NULL
                                  GROUP BY reading_id, post_id HAVING COUNT(*) > 1)
            """)
        #expect(duplicatePairs == 0, "step \(step): a duplicate live pair")
        let i10 = try db.fetchInt(
            """
            SELECT COUNT(*) FROM block b WHERE b.deleted_at IS NULL
              AND NOT EXISTS (SELECT 1 FROM variant v WHERE v.block_id = b.id
                                AND v.deleted_at IS NULL AND v.status = 'active')
            """)
        #expect(i10 == 0, "step \(step): I10 broken")
        let i2 = try db.fetchInt(
            """
            SELECT COUNT(*) FROM (SELECT 1 FROM container_block WHERE deleted_at IS NULL
                                  GROUP BY block_id HAVING COUNT(*) > 1)
            """)
        #expect(i2 == 0, "step \(step): I2 broken")
    }
}
