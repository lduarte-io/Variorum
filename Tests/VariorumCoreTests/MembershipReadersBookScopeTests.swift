import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// 13i-c U2 — **THE THREE MEMBERSHIP READERS GAIN `kind='book'` TOGETHER**
/// (13i-b ladder F-R1-7, ruled as one in the 13i-c plan §3: "membership means
/// a BOOK's row; a sync-stray member row on a gathering is never a home").
///
/// A gathering holds nothing (the sitting record §1), so no local door mints a
/// row on one — but a two-device race can leave a stray live MEMBER row there
/// (the reverted-bind class; the 13i-b ladder traced it). Each reader below
/// used to count that stray as membership. Red on the pre-fix tree, each one:
/// - `membershipElsewhere` read the note as "membered elsewhere", so an OWNED
///   living book BELLED a free note instead of claiming it;
/// - the Pool's exclusion read the stray as a home, so the bookless note left
///   the Pool;
/// - `readingsContaining`'s membership leg listed the gathering as a book (and,
///   when its rule matched too, twice).
@Suite("13i-c U2 — the three membership readers count BOOKS only (F-R1-7)")
struct MembershipReadersBookScopeTests {
    private func rule(_ term: RuleTerm) throws -> String {
        try #require(try RuleGrammar.encode(term))
    }

    /// A stray live member row on a gathering — only a sync race can write
    /// one, so the fixture writes it raw.
    private func strayMemberRow(
        _ db: AppDatabase, gatheringID: String, postID: String
    ) throws {
        try db.write { db in
            try db.execute(
                sql: """
                    INSERT INTO reading_post (id, reading_id, post_id, position, status, created_at)
                    VALUES ('stray-row', ?, ?, 'a0', 'member', '2026-07-01T00:00:00.000Z')
                    """,
                arguments: [gatheringID, postID])
        }
    }

    @Test func anOwnedLivingBookClaimsANoteWhoseOnlyOtherRowIsAStrayOnAGathering() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let other = try ops.createTag(name: "other")
            let gathering = try ops.createReading(
                name: "g", kind: .gathering, querySpec: try rule(.tag(other.id)))
            let owned = try ops.createReading(
                name: "owned", kind: .book, querySpec: try rule(.tag(work.id)))
            try db.write {
                try $0.execute(sql: "UPDATE reading SET owned = 1 WHERE id = ?",
                               arguments: [owned.id])
            }
            let note = try ops.createPost(title: "free")
            try strayMemberRow(db, gatheringID: gathering.id, postID: note.id)

            _ = try ops.applyTag(work.id, toPost: note.id)

            let status = try db.fetchString(
                "SELECT status FROM reading_post WHERE reading_id = ? AND post_id = ?",
                [owned.id, note.id])
            // A gathering's stray is never "a second place it lives": the
            // owned book CLAIMS the free note (pre-fix: 'arrival', the bell).
            #expect(status == "member")
        }
    }

    @Test func aNoteWhoseOnlyRowIsAStrayOnAGatheringStaysInThePool() throws {
        try withOperations { ops, db in
            let other = try ops.createTag(name: "other")
            let gathering = try ops.createReading(
                name: "g", kind: .gathering, querySpec: try rule(.tag(other.id)))
            let note = try ops.createPost(title: "bookless")
            try strayMemberRow(db, gatheringID: gathering.id, postID: note.id)

            let pool = try db.read { try Queries.poolListing($0, window: 10) }
            // Pre-fix: the stray read as a home and the note left the Pool.
            #expect((pool.loose + pool.tucked).map(\.postID).contains(note.id))
        }
    }

    /// 13i-c ladder round 1: the Pool probe also checks the reading's
    /// LIVENESS, like its two sibling readers — a live member row under a
    /// TOMBSTONED book (a sync-stray/mid-batch tolerance state, SyncSpec §5;
    /// no local door writes one — `restoreContainer` and `revertDiverge`
    /// both guard the reading live) is not a home. Red on the pre-fix tree:
    /// the note vanished from the Pool while no book listed it.
    @Test func aNoteWhoseOnlyRowIsAStrayUnderADeadBookStaysInThePool() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "gone", kind: .book)
            let note = try ops.createPost(title: "orphaned")
            try ops.deleteReading(book.id)
            // The stray: a live member row arriving under the dead book —
            // only a sync race leaves it, so the fixture writes it raw.
            try db.write {
                try $0.execute(
                    sql: """
                        INSERT INTO reading_post (id, reading_id, post_id, position, status, created_at)
                        VALUES ('stray-dead-book', ?, ?, 'a0', 'member', '2026-07-01T00:00:00.000Z')
                        """,
                    arguments: [book.id, note.id])
            }

            let pool = try db.read { try Queries.poolListing($0, window: 10) }
            #expect((pool.loose + pool.tucked).map(\.postID).contains(note.id),
                    "a dead book's stray is not a home — the siblings' liveness rule, here too")
            let homes = try db.read { try Queries.readingsContaining($0, postID: note.id) }
            #expect(homes.isEmpty, "…and no listing claims the dead book holds it")
        }
    }

    @Test func theChipNeverListsAGatheringThroughAStrayMemberRow() throws {
        try withOperations { ops, db in
            let tagged = try ops.createTag(name: "tagged")
            let gathering = try ops.createReading(
                name: "g", kind: .gathering, querySpec: try rule(.tag(tagged.id)))
            let quiet = try ops.createReading(
                name: "quiet", kind: .gathering,
                querySpec: try rule(.tag(try ops.createTag(name: "unused").id)))
            let note = try ops.createPost(title: "n")
            _ = try ops.applyTag(tagged.id, toPost: note.id)
            try strayMemberRow(db, gatheringID: gathering.id, postID: note.id)
            try db.write {
                try $0.execute(
                    sql: """
                        INSERT INTO reading_post (id, reading_id, post_id, position, status, created_at)
                        VALUES ('stray-two', ?, ?, 'a0', 'member', '2026-07-01T00:00:00.000Z')
                        """,
                    arguments: [quiet.id, note.id])
            }

            let containing = try db.read {
                try Queries.readingsContaining($0, postID: note.id).map(\.id)
            }
            // The matching gathering lists ONCE (its rule), the non-matching
            // one not at all (pre-fix: [g, g, quiet]).
            #expect(containing == [gathering.id])
        }
    }
}
