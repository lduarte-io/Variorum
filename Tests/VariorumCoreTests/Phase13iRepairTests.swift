import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

// 13i-a (the wings/shelves/books lockstep event) — the SyncSpec §7
// additions, each asserted on the standing trio: (a) the deterministic
// outcome, (b) both devices converge byte-identically, (c) every repair
// write reaches the outbox explicitly. The execution record is
// `notes/plans/phase-13i-a-schema-event.md` §5; R2's shape is PROVISIONAL
// (QUESTIONS #167).
@Suite("13i-a repairs (wings · per-wing tags · membership status · owned · Welcome)")
struct Phase13iRepairTests {

    // MARK: - R3: the tag identity is (wing, path)

    /// Identical paths in TWO wings are legal twins — the dedupe must NOT
    /// fire across wings (R-13ia-1: each wing's vocabulary is its own).
    @Test func samePathInTwoWingsSurvivesAsTwins() async throws {
        let (a, b, server) = try furniturePair()
        // A mints #video in Home; B mints #video in a second wing.
        try a.with { ops, _ in _ = try ops.createTag(parent: nil, name: "video") }
        let wingID = "BB000000-0000-4000-8000-00000000W1NG"
        try b.with { _, db in
            try db.write { database in
                try database.execute(
                    sql: """
                        INSERT INTO wing (id, owner_id, name, position, created_at, updated_at)
                        VALUES (?, ?, 'the Work', 'a1', ?, ?)
                        """,
                    arguments: [wingID, FakeSyncServer.defaultUserID,
                                "2026-09-30T00:00:00.000Z", "2026-09-30T00:00:00.000Z"])
                try database.execute(
                    sql: """
                        INSERT INTO tag (id, owner_id, name, path, wing_id, created_at, updated_at)
                        VALUES ('BB000000-0000-4000-8000-0000000000T1', ?, 'video', 'video', ?, ?, ?)
                        """,
                    arguments: [FakeSyncServer.defaultUserID, wingID,
                                "2026-09-30T00:00:00.000Z", "2026-09-30T00:00:00.000Z"])
            }
        }
        try await assertFurnitureConverged(a, b, server)
        for client in [a, b] {
            #expect(try client.db.fetchInt(
                "SELECT COUNT(*) FROM tag WHERE path = 'video' AND deleted_at IS NULL") == 2,
                "one #video per wing — twins, never a collision")
        }
    }

    /// The SAME wing's duplicate still dedupes exactly as before (the §7
    /// rule, now scoped): smaller id keeps, applications re-point.
    @Test func samePathInOneWingStillDedupes() async throws {
        let (a, b, server) = try furniturePair()
        try a.with { ops, _ in _ = try ops.createTag(parent: nil, name: "video") }
        try b.with { ops, _ in
            let tag = try ops.createTag(parent: nil, name: "video")
            let post = try ops.createPost(title: "clip ideas")
            _ = try ops.applyTag(tag.id, toPost: post.id)
        }
        try await assertFurnitureConverged(a, b, server)
        for client in [a, b] {
            #expect(try client.db.fetchInt(
                "SELECT COUNT(*) FROM tag WHERE path = 'video' AND deleted_at IS NULL") == 1)
            // The application survived onto the keeper (AA sorts below BB).
            #expect(try client.db.fetchInt(
                """
                SELECT COUNT(*) FROM post_tag pt
                JOIN tag t ON t.id = pt.tag_id AND t.deleted_at IS NULL
                WHERE pt.deleted_at IS NULL AND t.path = 'video'
                """) == 1)
        }
    }

    // MARK: - R1: the pair dedupe is status-aware (member outranks arrival)

    /// Two devices reacting to ONE tagging event: one SEATS the note
    /// (member), the other BELLS it (arrival, the at-capacity shape). The
    /// pair dedupes to one row and the kept row is a MEMBER whichever id
    /// sorts smaller — a seating outranks the bell (sitting record §4).
    @Test func aSeatAndABellForOnePairConvergeToTheSeat() async throws {
        let (a, b, server) = try furniturePair()
        // The shared substrate: A mints the note and the book, pushes;
        // B pulls so both sides hold the same pair targets.
        let (postID, readingID): (String, String) = try a.with { ops, _ in
            let post = try ops.createPost(title: "the note")
            let book = try ops.createReading(name: "the book", kind: .book)
            return (post.id, book.id)
        }
        try await a.push()
        _ = try await b.pull()
        // Each device inserts ITS OWN membership row for the pair —
        // A seats, B bells (fresh UUIDs; intake only ever inserts fresh
        // pairs). Raw SQL: the intake ops are 13i-b's.
        try a.with { _, db in
            try db.write { database in
                try database.execute(
                    sql: """
                        INSERT INTO reading_post (id, reading_id, post_id, position, status, created_at)
                        VALUES ('AA000000-0000-4000-8000-00000000SEAT', ?, ?, 'a1', 'member', ?)
                        """,
                    arguments: [readingID, postID, "2026-09-30T00:00:01.000Z"])
            }
        }
        try b.with { _, db in
            try db.write { database in
                try database.execute(
                    sql: """
                        INSERT INTO reading_post (id, reading_id, post_id, position, status, created_at)
                        VALUES ('BB000000-0000-4000-8000-00000000BELL', ?, ?, 'a2', 'arrival', ?)
                        """,
                    arguments: [readingID, postID, "2026-09-30T00:00:02.000Z"])
            }
        }
        try await assertFurnitureConverged(a, b, server)
        for client in [a, b] {
            #expect(try client.db.fetchInt(
                "SELECT COUNT(*) FROM reading_post WHERE post_id = ? AND deleted_at IS NULL",
                [postID]) == 1)
            #expect(try client.db.fetchString(
                "SELECT status FROM reading_post WHERE post_id = ? AND deleted_at IS NULL",
                [postID]) == "member",
                "the seating survives whichever id the dedupe keeps")
        }
    }

    /// The MIRRORED keep-shape: here the ARRIVAL's id sorts smaller (AA),
    /// the member's larger (BB) — the kept arrival must be PROMOTED, which
    /// is branch 1's adopt-member arm doing the work.
    @Test func theSeatKeepsWhenItsIDSortsSmallerToo() async throws {
        let (a, b, server) = try furniturePair()
        let (postID, readingID): (String, String) = try a.with { ops, _ in
            let post = try ops.createPost(title: "the note")
            let book = try ops.createReading(name: "the book", kind: .book)
            return (post.id, book.id)
        }
        try await a.push()
        _ = try await b.pull()
        try a.with { _, db in
            try db.write { database in
                try database.execute(
                    sql: """
                        INSERT INTO reading_post (id, reading_id, post_id, position, status, created_at)
                        VALUES ('AA000000-0000-4000-8000-00000000ARRV', ?, ?, 'a1', 'arrival', ?)
                        """,
                    arguments: [readingID, postID, "2026-09-30T00:00:01.000Z"])
            }
        }
        try b.with { _, db in
            try db.write { database in
                try database.execute(
                    sql: """
                        INSERT INTO reading_post (id, reading_id, post_id, position, status, created_at)
                        VALUES ('BB000000-0000-4000-8000-00000000MEMB', ?, ?, 'a2', 'member', ?)
                        """,
                    arguments: [readingID, postID, "2026-09-30T00:00:02.000Z"])
            }
        }
        try await assertFurnitureConverged(a, b, server)
        for client in [a, b] {
            #expect(try client.db.fetchString(
                "SELECT status FROM reading_post WHERE post_id = ? AND deleted_at IS NULL",
                [postID]) == "member")
        }
    }

    /// Ladder R1 B-1's pin (red-on-old): the ASYMMETRIC choreography — the
    /// promotion branch's device must PUSH the kept row's new status, or
    /// the mirror (and any device that never sees the live loser) holds
    /// 'arrival' forever. The §7 outbox rule asserted directly.
    @Test func thePromotedKeptRowReachesTheOutboxAndAsymmetricRoundsConverge() async throws {
        let (a, b, server) = try furniturePair()
        let (postID, readingID): (String, String) = try a.with { ops, _ in
            let post = try ops.createPost(title: "the note")
            let book = try ops.createReading(name: "the book", kind: .book)
            return (post.id, book.id)
        }
        try await a.push()
        _ = try await b.pull()
        // A mints the ARRIVAL (AA — the smaller id) and pushes FIRST;
        // B mints the MEMBER (BB) and only then meets A's row.
        try a.with { _, db in
            try db.write { database in
                try database.execute(
                    sql: """
                        INSERT INTO reading_post (id, reading_id, post_id, position, status, created_at)
                        VALUES ('AA000000-0000-4000-8000-00000000ARRV', ?, ?, 'a1', 'arrival', ?)
                        """,
                    arguments: [readingID, postID, "2026-09-30T00:00:01.000Z"])
            }
        }
        try await a.push()
        try b.with { _, db in
            try db.write { database in
                try database.execute(
                    sql: """
                        INSERT INTO reading_post (id, reading_id, post_id, position, status, created_at)
                        VALUES ('BB000000-0000-4000-8000-00000000MEMB', ?, ?, 'a2', 'member', ?)
                        """,
                    arguments: [readingID, postID, "2026-09-30T00:00:02.000Z"])
            }
        }
        try await b.push()
        _ = try await b.pull()  // the collision lands on B: AA kept, promoted
        #expect(try b.db.fetchString(
            """
            SELECT status FROM reading_post
            WHERE id = 'AA000000-0000-4000-8000-00000000ARRV'
            """) == "member")
        // THE §7 RULE, asserted directly: the promotion is a repair write
        // on the kept row and must be enqueued (B-1's exact hole).
        #expect(try b.db.fetchInt(
            """
            SELECT COUNT(*) FROM sync_outbox
            WHERE table_name = 'reading_post'
              AND row_id = 'AA000000-0000-4000-8000-00000000ARRV'
            """) == 1,
            "the kept row's promotion reaches the outbox — a forgotten enqueue is silent divergence")
        // And the asymmetric tail converges WITHOUT B ever re-meeting a
        // live loser on A's side.
        try await b.push()
        _ = try await a.pull()
        try await assertFurnitureConverged(a, b, server)
        for client in [a, b] {
            #expect(try client.db.fetchString(
                "SELECT status FROM reading_post WHERE post_id = ? AND deleted_at IS NULL",
                [postID]) == "member")
        }
    }

    /// DOCUMENTED, not repaired (the plan §5's last bullet): a SEAT and a
    /// DISMISSAL arriving as two different rows coexist — the live member
    /// stands and the born-tombstoned decided row is inert beside it. (On
    /// ONE row the ordinary tombstone-wins matrix decides instead.)
    @Test func aSeatBesideABornTombstonedDismissalIsDocumentedCoexistence() async throws {
        let (a, b, server) = try furniturePair()
        let (postID, readingID): (String, String) = try a.with { ops, _ in
            let post = try ops.createPost(title: "the note")
            let book = try ops.createReading(name: "the book", kind: .book)
            return (post.id, book.id)
        }
        try await a.push()
        _ = try await b.pull()
        try a.with { _, db in
            try db.write { database in
                try database.execute(
                    sql: """
                        INSERT INTO reading_post (id, reading_id, post_id, position, status, created_at)
                        VALUES ('AA000000-0000-4000-8000-00000000SEAT', ?, ?, 'a1', 'member', ?)
                        """,
                    arguments: [readingID, postID, "2026-09-30T00:00:01.000Z"])
            }
        }
        try b.with { _, db in
            try db.write { database in
                // The dismissal: created and deleted on one stamp (§4).
                try database.execute(
                    sql: """
                        INSERT INTO reading_post (id, reading_id, post_id, position, status,
                                                  created_at, deleted_at)
                        VALUES ('BB000000-0000-4000-8000-00000000DISM', ?, ?, 'a2', 'arrival',
                                ?, ?)
                        """,
                    arguments: [readingID, postID,
                                "2026-09-30T00:00:02.000Z", "2026-09-30T00:00:02.000Z"])
            }
        }
        try await assertFurnitureConverged(a, b, server)
        for client in [a, b] {
            #expect(try client.db.fetchInt(
                "SELECT COUNT(*) FROM reading_post WHERE post_id = ?", [postID]) == 2)
            #expect(try client.db.fetchInt(
                "SELECT COUNT(*) FROM reading_post WHERE post_id = ? AND deleted_at IS NULL",
                [postID]) == 1)
        }
    }

    // MARK: - R2: OWNED exclusivity (PROVISIONAL #167)

    /// A owns note N in book X (accepted FIRST); B plainly adds N to book
    /// Y offline. The later plain membership is TOMBSTONED everywhere —
    /// the ownership promise defended at the door.
    ///
    /// 13i-c U2 — the FIXTURE re-ordered, the subject untouched: B used to
    /// pull A's claim and THEN hand-add, a road the ownership consult now
    /// refuses at the door by design (`noteOwnedElsewhere` — the 13i-c plan
    /// §4 row 1). The race this pins is B adding WITHOUT having seen the
    /// claim, so B pulls the note before A claims it and never pulls again.
    @Test func aLaterPlainAddBesideAStandingOwnedClaimTombstones() async throws {
        let (a, b, server) = try furniturePair()
        let postID: String = try a.with { ops, _ in
            try ops.createPost(title: "the claimed note").id
        }
        try await a.push()
        _ = try await b.pull()
        let ownedID: String = try a.with { ops, db in
            let post = try #require(try db.read { try Container.fetchOne($0, key: postID) })
            let owned = try ops.createReading(name: "the Owned", kind: .book)
            try db.write { database in
                try database.execute(
                    sql: "UPDATE reading SET owned = 1 WHERE id = ?", arguments: [owned.id])
                try database.execute(
                    sql: """
                        INSERT INTO reading_post (id, reading_id, post_id, position, status, created_at)
                        VALUES ('AA000000-0000-4000-8000-0000000CLAIM', ?, ?, 'a1', 'member', ?)
                        """,
                    arguments: [owned.id, post.id, "2026-09-30T00:00:01.000Z"])
            }
            return owned.id
        }
        try await a.push()   // the claim is accepted FIRST; B never pulls it
        let plainID: String = try b.with { ops, _ in
            let plain = try ops.createReading(name: "the plain book", kind: .book)
            _ = try ops.addPostToReading(postID, to: plain.id)
            return plain.id
        }
        try await assertFurnitureConverged(a, b, server)
        for client in [a, b] {
            #expect(try client.db.fetchString(
                """
                SELECT reading_id FROM reading_post
                WHERE post_id = ? AND deleted_at IS NULL AND status = 'member'
                """, [postID]) == ownedID,
                "the standing claim is the ONE live membership")
            #expect(try client.db.fetchInt(
                """
                SELECT COUNT(*) FROM reading_post
                WHERE post_id = ? AND reading_id = ? AND deleted_at IS NOT NULL
                """, [postID, plainID]) == 1,
                "the later plain membership tombstoned — recoverable, never erased")
        }
    }

    /// The MIRROR: N was already plainly membered (accepted first); the
    /// owned claim arrives later. The claim DEMOTES to an ARRIVAL — the
    /// bell intake itself would have rung ("lives elsewhere: claim / copy
    /// in / leave", sitting record §6) — and the plain membership stands.
    @Test func aLaterOwnedClaimOverAMemberedNoteDemotesToAnArrival() async throws {
        let (a, b, server) = try furniturePair()
        let (postID, plainID): (String, String) = try a.with { ops, _ in
            let post = try ops.createPost(title: "the membered note")
            let plain = try ops.createReading(name: "the plain book", kind: .book)
            _ = try ops.addPostToReading(post.id, to: plain.id)
            return (post.id, plain.id)
        }
        try await a.push()
        _ = try await b.pull()
        let ownedID: String = try b.with { ops, db in
            let owned = try ops.createReading(name: "the Owned", kind: .book)
            try db.write { database in
                try database.execute(
                    sql: "UPDATE reading SET owned = 1 WHERE id = ?", arguments: [owned.id])
                try database.execute(
                    sql: """
                        INSERT INTO reading_post (id, reading_id, post_id, position, status, created_at)
                        VALUES ('BB000000-0000-4000-8000-0000000CLAIM', ?, ?, 'a1', 'member', ?)
                        """,
                    arguments: [owned.id, postID, "2026-09-30T00:00:02.000Z"])
            }
            return owned.id
        }
        try await assertFurnitureConverged(a, b, server)
        for client in [a, b] {
            #expect(try client.db.fetchString(
                """
                SELECT reading_id FROM reading_post
                WHERE post_id = ? AND deleted_at IS NULL AND status = 'member'
                """, [postID]) == plainID,
                "the earlier plain membership stands")
            #expect(try client.db.fetchString(
                """
                SELECT status FROM reading_post
                WHERE post_id = ? AND reading_id = ? AND deleted_at IS NULL
                """, [postID, ownedID]) == "arrival",
                "the later claim waits at Arrivals instead — nothing destroyed, nothing silent")
        }
    }

    // MARK: - R5: the Welcome-shelf keeper

    /// Two devices' seeders racing the Welcome shelf offline converge:
    /// smaller id keeps, the losers' books re-point, the loser tombstones.
    @Test func twoWelcomeShelvesConvergeToTheSmallerIDKeeper() async throws {
        let (a, b, server) = try furniturePair()
        func seedWelcome(_ client: SyncClient, shelfID: String, bookName: String) throws {
            try client.with { ops, db in
                let book = try ops.createReading(name: bookName, kind: .book)
                try db.write { database in
                    try database.execute(
                        sql: """
                            INSERT INTO shelf (id, owner_id, wing_id, name, role, position,
                                               created_at, updated_at)
                            VALUES (?, ?, '', 'Welcome', 'welcome', 'a1', ?, ?)
                            """,
                        arguments: [shelfID, FakeSyncServer.defaultUserID,
                                    "2026-09-30T00:00:00.000Z", "2026-09-30T00:00:00.000Z"])
                    try database.execute(
                        sql: "UPDATE reading SET shelf_id = ? WHERE id = ?",
                        arguments: [shelfID, book.id])
                }
            }
        }
        try seedWelcome(a, shelfID: "AA000000-0000-4000-8000-0000000SHELF", bookName: "field guide A")
        try seedWelcome(b, shelfID: "BB000000-0000-4000-8000-0000000SHELF", bookName: "field guide B")
        try await assertFurnitureConverged(a, b, server)
        for client in [a, b] {
            #expect(try client.db.fetchInt(
                "SELECT COUNT(*) FROM shelf WHERE role = 'welcome' AND deleted_at IS NULL") == 1)
            #expect(try client.db.fetchString(
                "SELECT id FROM shelf WHERE role = 'welcome' AND deleted_at IS NULL")
                == "AA000000-0000-4000-8000-0000000SHELF")
            #expect(try client.db.fetchInt(
                """
                SELECT COUNT(*) FROM reading
                WHERE shelf_id = 'AA000000-0000-4000-8000-0000000SHELF' AND deleted_at IS NULL
                """) == 2,
                "both devices' seeded books sit on the keeper")
        }
    }
}
