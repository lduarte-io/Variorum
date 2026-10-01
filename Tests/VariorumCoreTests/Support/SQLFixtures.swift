import Foundation
import GRDB
@testable import VariorumCore

/// Raw-SQL row factories for schema-level tests. Deliberately *not* the record
/// types (Step 5) and *not* operations (Phase 2): these tests probe what SQLite
/// itself enforces, so they speak SQL. IDs are caller-chosen strings so tests
/// read declaratively.
enum Fixture {
    static let now = "2026-07-04T00:00:00.000Z"

    static func container(_ db: Database, id: String, kind: String = "post") throws {
        try db.execute(
            sql: "INSERT INTO container (id, kind, created_at, updated_at) VALUES (?, ?, ?, ?)",
            arguments: [id, kind, now, now])
    }

    static func block(_ db: Database, id: String) throws {
        try db.execute(
            sql: "INSERT INTO block (id, created_at, updated_at) VALUES (?, ?, ?)",
            arguments: [id, now, now])
    }

    static func variant(_ db: Database, id: String, blockId: String, fanPosition: String = "V") throws {
        try db.execute(
            sql: "INSERT INTO variant (id, block_id, fan_position, created_at, updated_at) VALUES (?, ?, ?, ?, ?)",
            arguments: [id, blockId, fanPosition, now, now])
    }

    static func commitPoint(_ db: Database, id: String, variantId: String, text: String = "t") throws {
        try db.execute(
            sql: "INSERT INTO commit_point (id, variant_id, text, created_at) VALUES (?, ?, ?, ?)",
            arguments: [id, variantId, text, now])
    }

    static func edge(_ db: Database, id: String, source: String, target: String, type: String = "derived_from") throws {
        try db.execute(
            sql: "INSERT INTO edge (id, source_block_id, target_block_id, type, created_at) VALUES (?, ?, ?, ?, ?)",
            arguments: [id, source, target, type, now])
    }

    static func containerBlock(
        _ db: Database, id: String, containerId: String, blockId: String,
        position: String = "V", chosenVariantId: String? = nil
    ) throws {
        try db.execute(
            sql: """
                INSERT INTO container_block (id, container_id, block_id, position, chosen_variant_id, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?)
                """,
            arguments: [id, containerId, blockId, position, chosenVariantId, now, now])
    }

    static func reading(_ db: Database, id: String, name: String = "r", kind: String = "book") throws {
        try db.execute(
            sql: "INSERT INTO reading (id, name, kind, created_at, updated_at) VALUES (?, ?, ?, ?, ?)",
            arguments: [id, name, kind, now, now])
    }

    static func readingPost(_ db: Database, id: String, readingId: String, postId: String, position: String = "V") throws {
        try db.execute(
            sql: "INSERT INTO reading_post (id, reading_id, post_id, position, created_at) VALUES (?, ?, ?, ?, ?)",
            arguments: [id, readingId, postId, position, now])
    }

    static func tag(_ db: Database, id: String, name: String, path: String, parentId: String? = nil) throws {
        try db.execute(
            sql: "INSERT INTO tag (id, parent_id, name, path, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?)",
            arguments: [id, parentId, name, path, now, now])
    }

    static func postTag(_ db: Database, id: String, tagId: String, postId: String) throws {
        try db.execute(
            sql: "INSERT INTO post_tag (id, tag_id, post_id, created_at) VALUES (?, ?, ?, ?)",
            arguments: [id, tagId, postId, now])
    }

    static func blockTag(_ db: Database, id: String, tagId: String, blockId: String) throws {
        try db.execute(
            sql: "INSERT INTO block_tag (id, tag_id, block_id, created_at) VALUES (?, ?, ?, ?)",
            arguments: [id, tagId, blockId, now])
    }

    static func reference(_ db: Database, id: String, containerId: String, kind: String = "url", position: String = "V") throws {
        try db.execute(
            sql: "INSERT INTO reference (id, container_id, kind, position, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?)",
            arguments: [id, containerId, kind, position, now, now])
    }

    /// Tombstone any row by table + id column value.
    static func tombstone(_ db: Database, table: String, id: String, at deletedAt: String = "2026-07-04T12:00:00.000Z") throws {
        try db.execute(
            sql: "UPDATE \(table) SET deleted_at = ? WHERE id = ?",
            arguments: [deletedAt, id])
    }

    /// A placed block with one variant: container + block + variant + pointer.
    /// The everyday minimal world most constraint tests need.
    static func placedBlock(
        _ db: Database, container: String, block: String, variant: String, cb: String,
        chosen: Bool = false
    ) throws {
        try Fixture.container(db, id: container)
        try Fixture.block(db, id: block)
        try Fixture.variant(db, id: variant, blockId: block)
        try Fixture.containerBlock(
            db, id: cb, containerId: container, blockId: block,
            chosenVariantId: chosen ? variant : nil)
    }
}

/// A full-schema in-memory database with FK enforcement OFF — the only way a
/// test can materialize the sync-order states SyncSpec §5 requires the read
/// side to tolerate (child rows whose parents haven't arrived, e.g. a
/// placement before its block). Production stores always run with FKs ON;
/// how such states arise locally is the Phase 5 apply path's business — the
/// read layer's contract is just: render gaps, never crash.
func unenforcedDatabase() throws -> DatabaseQueue {
    var config = Configuration()
    config.foreignKeysEnabled = false
    let queue = try DatabaseQueue(configuration: config)
    try AppDatabase.migrator.migrate(queue)
    return queue
}

extension DatabaseError {
    var isConstraintViolation: Bool { resultCode == .SQLITE_CONSTRAINT }
}

/// Expects the write to fail with an SQLITE_CONSTRAINT-class error.
func expectConstraintViolation(_ body: () throws -> Void) -> Bool {
    do {
        try body()
        return false
    } catch let error as DatabaseError {
        return error.isConstraintViolation
    } catch {
        return false
    }
}
