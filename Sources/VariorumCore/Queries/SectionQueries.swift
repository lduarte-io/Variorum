import Foundation
import GRDB

// Reading sections / chapters, read side (Phase 13, Step A1). The book
// view's chapter traversal; Stage B builds the faces on these.
extension Queries {
    /// The book's live chapters, in order — `(position, id)`, the standing
    /// sort key.
    public static func readingSections(_ db: Database, readingID: String) throws -> [ReadingSection] {
        try ReadingSection
            .filter(Column("reading_id") == readingID && Column("deleted_at") == nil)
            .order(Column("position"), Column("id"))
            .fetchAll(db)
    }

    /// post → LIVE chapter, for one reading's memberships. The dangling
    /// rule embodied (AppSpec §7's fallback class): a membership whose
    /// `section_id` points at a tombstoned/missing section is ABSENT here —
    /// it reads as unsectioned, exactly like a NULL pointer; nothing
    /// repairs or rewrites the stored pointer.
    public static func sectionAssignments(
        _ db: Database, readingID: String
    ) throws -> [String: String] {
        let rows = try Row.fetchAll(
            db,
            sql: """
                SELECT rp.post_id AS post_id, s.id AS section_id
                FROM reading_post rp
                JOIN reading_section s
                  ON s.id = rp.section_id AND s.deleted_at IS NULL
                WHERE rp.reading_id = ? AND rp.deleted_at IS NULL
                """,
            arguments: [readingID])
        return Dictionary(uniqueKeysWithValues: rows.map {
            ($0["post_id"] as String, $0["section_id"] as String)
        })
    }
}
