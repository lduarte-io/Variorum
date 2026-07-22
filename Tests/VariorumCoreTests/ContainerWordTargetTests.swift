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
}
