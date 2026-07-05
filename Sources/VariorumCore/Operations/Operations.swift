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

    /// The session's structural-undo stack (AppSpec §9). When present,
    /// structural ops register their inverses here; inverses run internal
    /// revert operations that never re-register, so undoing cannot pollute
    /// the stack.
    public let undoStack: UndoStack?

    public init(undoStack: UndoStack? = nil) {
        self.undoStack = undoStack
    }

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

    /// One ordered pointer list, for the shared resolver below. Table and
    /// column names are compile-time constants, never user data.
    struct OrderedList {
        let table: String
        let scopeColumn: String
        /// The column an `InsertPosition` anchor names — the pointed-at
        /// entity (block, post), or the row's own id for references.
        let anchorColumn: String
        /// Typed refusal when an anchor has no live row in this scope.
        let missingAnchor: (String) -> OperationError
    }

    /// Mints a position at the requested spot in a live ordered list — the
    /// one implementation behind container placements, reading memberships,
    /// and the reference panel.
    func listPosition(
        _ db: Database, in list: OrderedList, scopeID: String, at insert: InsertPosition
    ) throws -> String {
        func anchorPosition(_ anchorID: String) throws -> String {
            guard let position = try String.fetchOne(
                db,
                sql: """
                    SELECT position FROM \(list.table)
                    WHERE \(list.scopeColumn) = ? AND \(list.anchorColumn) = ? AND deleted_at IS NULL
                    """,
                arguments: [scopeID, anchorID])
            else { throw list.missingAnchor(anchorID) }
            return position
        }
        func listEdge(_ aggregate: String) throws -> String? {
            try String.fetchOne(
                db,
                sql: """
                    SELECT \(aggregate)(position) FROM \(list.table)
                    WHERE \(list.scopeColumn) = ? AND deleted_at IS NULL
                    """,
                arguments: [scopeID])
        }
        func neighbor(_ aggregate: String, _ comparison: String, of anchor: String) throws -> String? {
            try String.fetchOne(
                db,
                sql: """
                    SELECT \(aggregate)(position) FROM \(list.table)
                    WHERE \(list.scopeColumn) = ? AND deleted_at IS NULL AND position \(comparison) ?
                    """,
                arguments: [scopeID, anchor])
        }
        switch insert {
        case .start:
            return FractionalIndex.between(nil, try listEdge("MIN"))
        case .end:
            return FractionalIndex.between(try listEdge("MAX"), nil)
        case .after(let anchorID):
            let anchor = try anchorPosition(anchorID)
            return FractionalIndex.between(anchor, try neighbor("MIN", ">", of: anchor))
        case .before(let anchorID):
            let anchor = try anchorPosition(anchorID)
            return FractionalIndex.between(try neighbor("MAX", "<", of: anchor), anchor)
        }
    }

    /// A `container_block.position` in a container's live pointer list.
    func containerPosition(
        _ db: Database, containerID: String, at insert: InsertPosition
    ) throws -> String {
        try listPosition(
            db,
            in: OrderedList(
                table: "container_block", scopeColumn: "container_id",
                anchorColumn: "block_id",
                missingAnchor: { OperationError.blockNotPlaced(id: $0) }),
            scopeID: containerID, at: insert)
    }

    /// A `reading_post.position` in a reading's live membership list.
    func readingPosition(
        _ db: Database, readingID: String, at insert: InsertPosition
    ) throws -> String {
        try listPosition(
            db,
            in: OrderedList(
                table: "reading_post", scopeColumn: "reading_id",
                anchorColumn: "post_id",
                missingAnchor: { OperationError.postNotInReading(postID: $0, readingID: readingID) }),
            scopeID: readingID, at: insert)
    }
}
