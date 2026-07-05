import Dependencies
import Foundation
import GRDB

// References: external source material beside a post — a viewing aid, never
// a knowledge object. Rows sync; `file_bookmark` stays local (Phase 5
// excludes it from payloads).
extension Operations {
    @discardableResult
    public func addReference(
        to postID: String,
        kind: ReferenceKind,
        name: String? = nil,
        url: String? = nil,
        fileBookmark: Data? = nil,
        at insert: InsertPosition = .end
    ) throws -> Reference {
        try database.write { db in
            _ = try livePost(db, postID)
            let now = date.now
            let reference = Reference(
                id: newID(), containerId: postID, kind: kind, name: name,
                url: url, fileBookmark: fileBookmark,
                position: try referencePosition(db, containerID: postID, at: insert),
                createdAt: now, updatedAt: now)
            try reference.insert(db)
            return reference
        }
    }

    public func removeReference(_ id: String) throws {
        try database.write { db in
            var reference = try liveReference(db, id)
            let now = date.now
            reference.deletedAt = now
            reference.updatedAt = now
            try reference.update(db)
        }
    }

    /// Remembered page/scroll position (JSON) — pure view bookkeeping.
    public func updateReferenceViewState(_ id: String, viewState: String?) throws {
        try database.write { db in
            var reference = try liveReference(db, id)
            reference.viewState = viewState
            reference.updatedAt = date.now
            try reference.update(db)
        }
    }

    public func reorderReference(_ id: String, to insert: InsertPosition) throws {
        try database.write { db in
            var reference = try liveReference(db, id)
            reference.position = try referencePosition(
                db, containerID: reference.containerId, at: insert)
            reference.updatedAt = date.now
            try reference.update(db)
        }
    }

    // MARK: - Internals

    private func liveReference(_ db: Database, _ id: String) throws -> Reference {
        guard let reference = try Reference.fetchOne(db, key: id), reference.deletedAt == nil else {
            throw OperationError.referenceNotFound(id: id)
        }
        return reference
    }

    /// Insert-position resolution for the reference panel; anchors are
    /// reference IDs within the same post.
    private func referencePosition(
        _ db: Database, containerID: String, at insert: InsertPosition
    ) throws -> String {
        func positionOfReference(_ referenceID: String) throws -> String {
            guard let position = try String.fetchOne(
                db,
                sql: """
                    SELECT position FROM reference
                    WHERE container_id = ? AND id = ? AND deleted_at IS NULL
                    """,
                arguments: [containerID, referenceID])
            else { throw OperationError.referenceNotFound(id: referenceID) }
            return position
        }
        func edgePosition(_ aggregate: String) throws -> String? {
            try String.fetchOne(
                db,
                sql: """
                    SELECT \(aggregate)(position) FROM reference
                    WHERE container_id = ? AND deleted_at IS NULL
                    """,
                arguments: [containerID])
        }
        switch insert {
        case .start:
            return FractionalIndex.between(nil, try edgePosition("MIN"))
        case .end:
            return FractionalIndex.between(try edgePosition("MAX"), nil)
        case .after(let referenceID):
            let anchor = try positionOfReference(referenceID)
            let next = try String.fetchOne(
                db,
                sql: """
                    SELECT MIN(position) FROM reference
                    WHERE container_id = ? AND deleted_at IS NULL AND position > ?
                    """,
                arguments: [containerID, anchor])
            return FractionalIndex.between(anchor, next)
        case .before(let referenceID):
            let anchor = try positionOfReference(referenceID)
            let previous = try String.fetchOne(
                db,
                sql: """
                    SELECT MAX(position) FROM reference
                    WHERE container_id = ? AND deleted_at IS NULL AND position < ?
                    """,
                arguments: [containerID, anchor])
            return FractionalIndex.between(previous, anchor)
        }
    }
}
