import Dependencies
import Foundation
import GRDB

/// The transactional operations API (AppSpec §9) — the ONLY way anything
/// mutates the store. Each operation is a single `database.write` transaction:
/// it reads current rows, applies the whole semantic change, and never
/// duplicates what the schema's triggers own (tombstone cascades, outbox
/// capture). Semantic side-effects — timestamps, `last_container_id`,
/// default-variant reassignment, churn — live here, never in triggers.
///
/// IDs are random UUIDv4 via `@Dependency(\.uuid)`; time via
/// `@Dependency(\.date)`. Within one operation the clock is read once, so
/// every row an operation touches carries the same timestamp.
public struct Operations: Sendable {
    @Dependency(\.database) var database
    @Dependency(\.date) var date
    @Dependency(\.uuid) var uuid

    public init() {}

    // MARK: - Minting

    func newID() -> String { uuid().uuidString }

    // MARK: - Where an insertion lands

    /// Neighbor-relative insertion point for ordered pointer lists
    /// (`container_block`, `reading_post`). Neighbor IDs are the *pointed-at*
    /// entity (block in a container, post in a reading), not the pointer row.
    public enum InsertPosition: Equatable, Sendable {
        case start
        case end
        case after(String)
        case before(String)
    }
}

// MARK: - Shared fetch-or-throw helpers

extension Operations {
    func liveContainer(_ db: Database, _ id: String) throws -> Container {
        guard let container = try Container.fetchOne(db, key: id), container.deletedAt == nil else {
            throw OperationError.containerNotFound(id: id)
        }
        return container
    }

    func livePost(_ db: Database, _ id: String) throws -> Container {
        let container = try liveContainer(db, id)
        guard container.kind == .post else {
            throw OperationError.wrongContainerKind(id: id, expected: .post)
        }
        return container
    }

    func liveBlock(_ db: Database, _ id: String) throws -> Block {
        guard let block = try Block.fetchOne(db, key: id), block.deletedAt == nil else {
            throw OperationError.blockNotFound(id: id)
        }
        return block
    }

    func liveVariant(_ db: Database, _ id: String) throws -> Variant {
        guard let variant = try Variant.fetchOne(db, key: id), variant.deletedAt == nil else {
            throw OperationError.variantNotFound(id: id)
        }
        return variant
    }

    func liveReading(_ db: Database, _ id: String) throws -> Reading {
        guard let reading = try Reading.fetchOne(db, key: id), reading.deletedAt == nil else {
            throw OperationError.readingNotFound(id: id)
        }
        return reading
    }

    func liveTag(_ db: Database, _ id: String) throws -> Tag {
        guard let tag = try Tag.fetchOne(db, key: id), tag.deletedAt == nil else {
            throw OperationError.tagNotFound(id: id)
        }
        return tag
    }

    /// A block's live placement, if any (at most one — I2).
    func livePlacement(_ db: Database, blockID: String) throws -> ContainerBlock? {
        try ContainerBlock
            .filter(Column("block_id") == blockID && Column("deleted_at") == nil)
            .fetchOne(db)
    }

    /// The locked-post guard, centralized: autosave, commit, reorder, move,
    /// choose-variant, placement and deletion ops all refuse through this one
    /// helper so the rule cannot drift (a locked post freezes edits, commits,
    /// pointer order, and chosen variants — AppSpec §9).
    func ensureUnlocked(_ container: Container) throws {
        if container.locked {
            throw OperationError.lockedPost(id: container.id)
        }
    }

    /// The locked-post guard for ops addressed by block: applies when the
    /// block is currently placed in a locked container.
    func ensurePlacementUnlocked(_ db: Database, blockID: String) throws {
        if let placement = try livePlacement(db, blockID: blockID) {
            try ensureUnlocked(try liveContainer(db, placement.containerId))
        }
    }

    // MARK: - Settings

    func settingValue(_ db: Database, _ key: String) throws -> String? {
        try String.fetchOne(db, sql: "SELECT value FROM setting WHERE key = ?", arguments: [key])
    }

    func majorRevisionThreshold(_ db: Database) throws -> Double {
        try settingValue(db, "major_revision_threshold").flatMap(Double.init) ?? 0.8
    }

    // MARK: - Position resolution

    /// Mints a `container_block.position` at the requested spot in a
    /// container's live pointer list.
    func containerPosition(
        _ db: Database, containerID: String, at insert: InsertPosition
    ) throws -> String {
        func positionOfBlock(_ blockID: String) throws -> String {
            guard let position = try String.fetchOne(
                db,
                sql: """
                    SELECT position FROM container_block
                    WHERE container_id = ? AND block_id = ? AND deleted_at IS NULL
                    """,
                arguments: [containerID, blockID])
            else { throw OperationError.blockNotPlaced(id: blockID) }
            return position
        }
        func edgePosition(_ aggregate: String) throws -> String? {
            try String.fetchOne(
                db,
                sql: """
                    SELECT \(aggregate)(position) FROM container_block
                    WHERE container_id = ? AND deleted_at IS NULL
                    """,
                arguments: [containerID])
        }
        switch insert {
        case .start:
            return FractionalIndex.between(nil, try edgePosition("MIN"))
        case .end:
            return FractionalIndex.between(try edgePosition("MAX"), nil)
        case .after(let blockID):
            let anchor = try positionOfBlock(blockID)
            let next = try String.fetchOne(
                db,
                sql: """
                    SELECT MIN(position) FROM container_block
                    WHERE container_id = ? AND deleted_at IS NULL AND position > ?
                    """,
                arguments: [containerID, anchor])
            return FractionalIndex.between(anchor, next)
        case .before(let blockID):
            let anchor = try positionOfBlock(blockID)
            let previous = try String.fetchOne(
                db,
                sql: """
                    SELECT MAX(position) FROM container_block
                    WHERE container_id = ? AND deleted_at IS NULL AND position < ?
                    """,
                arguments: [containerID, anchor])
            return FractionalIndex.between(previous, anchor)
        }
    }

    /// Mints a `reading_post.position` at the requested spot in a reading's
    /// live membership list.
    func readingPosition(
        _ db: Database, readingID: String, at insert: InsertPosition
    ) throws -> String {
        func positionOfPost(_ postID: String) throws -> String {
            guard let position = try String.fetchOne(
                db,
                sql: """
                    SELECT position FROM reading_post
                    WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL
                    """,
                arguments: [readingID, postID])
            else { throw OperationError.postNotInReading(postID: postID, readingID: readingID) }
            return position
        }
        func edgePosition(_ aggregate: String) throws -> String? {
            try String.fetchOne(
                db,
                sql: """
                    SELECT \(aggregate)(position) FROM reading_post
                    WHERE reading_id = ? AND deleted_at IS NULL
                    """,
                arguments: [readingID])
        }
        switch insert {
        case .start:
            return FractionalIndex.between(nil, try edgePosition("MIN"))
        case .end:
            return FractionalIndex.between(try edgePosition("MAX"), nil)
        case .after(let postID):
            let anchor = try positionOfPost(postID)
            let next = try String.fetchOne(
                db,
                sql: """
                    SELECT MIN(position) FROM reading_post
                    WHERE reading_id = ? AND deleted_at IS NULL AND position > ?
                    """,
                arguments: [readingID, anchor])
            return FractionalIndex.between(anchor, next)
        case .before(let postID):
            let anchor = try positionOfPost(postID)
            let previous = try String.fetchOne(
                db,
                sql: """
                    SELECT MAX(position) FROM reading_post
                    WHERE reading_id = ? AND deleted_at IS NULL AND position < ?
                    """,
                arguments: [readingID, anchor])
            return FractionalIndex.between(previous, anchor)
        }
    }
}
