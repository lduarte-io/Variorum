import Foundation
import GRDB

// The reference panel's read side (Phase 11b, Step B3 — AppSpec §7
// `reference`): per-post source material in panel order. A viewing aid,
// never a knowledge object — the rows are pure metadata; the files stay
// the author's, addressed by LOCAL-ONLY security-scoped bookmarks (the
// sync serializer excludes `file_bookmark`; pinned from this panel's path).
extension Queries {
    /// A post's live references by `(position, id)` — the panel's listing.
    /// Cost ∝ the post's own references (P1).
    public static func references(_ db: Database, containerID: String) throws -> [Reference] {
        try Reference.fetchAll(
            db,
            sql: """
                SELECT * FROM reference
                WHERE container_id = ? AND deleted_at IS NULL
                ORDER BY position, id
                """,
            arguments: [containerID])
    }
}

extension AppDatabase {
    /// The panel's live projection (adds/removes/reorders/view-state).
    public func observeReferences(_ containerID: String) -> AsyncValueObservation<[Reference]> {
        observe { try Queries.references($0, containerID: containerID) }
    }
}
