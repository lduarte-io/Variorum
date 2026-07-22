import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 13b, Stage 4 Batch 4F — migration v1_12 `container.word_target`
/// (author ruling S4-28.1, ledger N36): the per-POST words-based extent
/// target, `reading.word_target`'s twin. Display/progress semantics only —
/// NEVER an add/type-time refusal. Its own SyncSpec §12 lockstep event
/// (marker 3 → 4; mirror DDL 07_phase13b_lockstep.sql).
@Suite("Per-post word target (13b Stage 4, 4F — v1_12)")
struct ContainerWordTargetTests {
    @Test func columnExistsNullableOnContainer() throws {
        let db = try AppDatabase.inMemory()
        try db.read { db in
            let column = try Row.fetchAll(db, sql: "PRAGMA table_info(container)")
                .first { $0["name"] == "word_target" }
            #expect(column != nil)
            #expect(column?["notnull"] == 0)
        }
    }

    @Test func theRecordRoundTripsTheColumn() throws {
        // The Container record carries the new column (a record that
        // silently dropped it would round-trip rows minus the target —
        // the serializer walk guards payloads; this guards the record).
        let db = try AppDatabase.inMemory()
        try db.write { db in
            let t0 = Date(timeIntervalSince1970: 1_782_864_000)
            let post = Container(
                id: "c1", kind: .post, title: "bounded", profile: .generic,
                wordTarget: 5_000, createdAt: t0, updatedAt: t0)
            try post.insert(db)
            let fetched = try Container.fetchOne(db, key: "c1")
            #expect(fetched?.wordTarget == 5_000)
            #expect(try Int.fetchOne(
                db, sql: "SELECT word_target FROM container WHERE id = 'c1'") == 5_000)
        }
    }

    // MARK: - setPostWordTarget (the setReadingWordTarget twin)

    @Test func setUpdateAndClearTheTarget() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "bounded", profile: .generic)
            #expect(try db.fetchInt(
                "SELECT word_target FROM container WHERE id = ?", [post.id]) == nil)

            try ops.setPostWordTarget(post.id, wordTarget: 5_000)
            #expect(try db.fetchInt(
                "SELECT word_target FROM container WHERE id = ?", [post.id]) == 5_000)

            // Extend at the boundary (the reading rule's shape).
            try ops.setPostWordTarget(post.id, wordTarget: 8_000)
            #expect(try db.fetchInt(
                "SELECT word_target FROM container WHERE id = ?", [post.id]) == 8_000)

            try ops.setPostWordTarget(post.id, wordTarget: nil)
            #expect(try db.fetchInt(
                "SELECT word_target FROM container WHERE id = ?", [post.id]) == nil)
        }
    }

    @Test func identityLevelClassNoTouchNoChurnAndNoOpWritesNothing() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "bounded", profile: .generic)
            _ = try ops.newBlock(in: post.id, text: "Some prose to churn against.", at: .end)
            let before = try db.read { db in
                try Row.fetchOne(
                    db,
                    sql: """
                        SELECT last_touched_at, churn_accumulator, updated_at
                        FROM container WHERE id = ?
                        """,
                    arguments: [post.id])!
            }

            try ops.setPostWordTarget(post.id, wordTarget: 5_000)
            let after = try db.read { db in
                try Row.fetchOne(
                    db,
                    sql: """
                        SELECT last_touched_at, churn_accumulator, updated_at
                        FROM container WHERE id = ?
                        """,
                    arguments: [post.id])!
            }
            // Identity-level (the setBlockName/extent-setters class): the
            // target is not writing — no touch stamp, no churn.
            #expect(after["last_touched_at"] as String? == before["last_touched_at"] as String?)
            #expect(after["churn_accumulator"] as Double == before["churn_accumulator"] as Double)
            #expect(after["updated_at"] as String != before["updated_at"] as String,
                    "a REAL set moves updated_at (it must sync)")

            // The no-op guard: same value again writes nothing.
            try db.clearOutbox()
            try ops.setPostWordTarget(post.id, wordTarget: 5_000)
            #expect(try !db.outboxContains("container", post.id),
                    "a no-op set writes no row and enqueues nothing")
        }
    }

    @Test func refusalsAreTypedAndExact() throws {
        try withOperations { ops, _ in
            let post = try ops.createPost(title: "bounded", profile: .generic)
            #expect(throws: OperationError.invalidExtent(value: 0)) {
                try ops.setPostWordTarget(post.id, wordTarget: 0)
            }
            #expect(throws: OperationError.invalidExtent(value: -100)) {
                try ops.setPostWordTarget(post.id, wordTarget: -100)
            }
            // A pool is not a post — targets are a post concept (recorded).
            let pool = try ops.createPool(title: "scraps")
            #expect(throws: OperationError.wrongContainerKind(id: pool.id, expected: .post)) {
                try ops.setPostWordTarget(pool.id, wordTarget: 100)
            }
            #expect(throws: OperationError.containerNotFound(id: "nope")) {
                try ops.setPostWordTarget("nope", wordTarget: 100)
            }
        }
    }

    @Test func aSealedPostRefusesTheTargetProvisional() throws {
        // PROVISIONAL (13b 4F — the seal posture judgment call): REFUSE
        // under seal, mirroring the reading extent setters' refuse-under-
        // locked rule (a sealed post is marked complete; its writing goal
        // is part of what "complete" froze). The N34 metadata-allowed
        // alternative is recorded in the batch record — flipping this is
        // one guard line + this pin's rewrite.
        try withOperations { ops, _ in
            let post = try ops.createPost(title: "bounded", profile: .generic)
            _ = try ops.newBlock(in: post.id, text: "Prose.", at: .end)
            try ops.lockPost(post.id)
            #expect(throws: OperationError.lockedPost(id: post.id)) {
                try ops.setPostWordTarget(post.id, wordTarget: 5_000)
            }
            try ops.unlockPost(post.id)
            try ops.setPostWordTarget(post.id, wordTarget: 5_000)
        }
    }

    @Test func theTargetIsNeverAnEntryTimeRefusal() throws {
        try withOperations { ops, db in
            // A tiny target, then far more words than it names — minting
            // and typing both succeed: the target is progress display,
            // never a gate (the ratified word_target semantics, mirrored).
            let post = try ops.createPost(title: "tiny", profile: .generic)
            try ops.setPostWordTarget(post.id, wordTarget: 3)
            let block = try ops.newBlock(
                in: post.id,
                text: "Far more than three words in this single block of prose.",
                at: .end)
            let more = "Far more than three words, and then an edit adds even more."
            try ops.autosave(block.variant.id, text: more, charDelta: 10)
            #expect(try db.fetchString(
                "SELECT working_text FROM variant WHERE id = ?", [block.variant.id]) == more)
        }
    }

    @Test func theHeaderResolvesTheTarget() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "bounded", profile: .generic)
            try ops.setPostWordTarget(post.id, wordTarget: 5_000)
            let header = try db.read { try Queries.containerHeader($0, containerID: post.id) }
            #expect(header?.wordTarget == 5_000,
                    "the bars' progress face reads the observed header")
        }
    }

    @Test func theSetReachesTheOutboxAndApplyModeSuppresses() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "bounded", profile: .generic)
            try db.clearOutbox()
            try ops.setPostWordTarget(post.id, wordTarget: 5_000)
            #expect(try db.outboxContains("container", post.id))
            try db.clearOutbox()
            try db.applyingRemote { db in
                try db.execute(
                    sql: "UPDATE container SET word_target = 9000 WHERE id = ?",
                    arguments: [post.id])
            }
            #expect(try !db.outboxContains("container", post.id))
        }
    }

    // MARK: - The wire (one convergence test — plain metadata CAS)

    @Test func thePerPostTargetCrossesTheWireAsPlainMetadata() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 90, seed: 2)
        let postID = try a.with { ops, _ -> String in
            let post = try ops.createPost(title: "bounded", profile: .generic)
            _ = try ops.newBlock(in: post.id, text: "Prose.", at: .end)
            try ops.setPostWordTarget(post.id, wordTarget: 5_000)
            return post.id
        }
        for _ in 0..<2 {
            for client in [a, b] {
                _ = try await client.pull()
                _ = try await client.push()
            }
        }
        #expect(try b.db.fetchInt(
            "SELECT word_target FROM container WHERE id = ?", [postID]) == 5_000)
        #expect(try a.syncedDump() == (try b.syncedDump()))
        #expect(try a.outboxCount() == 0)
        #expect(try b.outboxCount() == 0)
    }
}
