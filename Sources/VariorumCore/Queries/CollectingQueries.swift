import Foundation
import GRDB

// The Collecting settings' read support (13i-b U3 — the rule editor's
// auto-tag row; the sitting record §4: "Notes written here are tagged: …
// [also tag the N current members]").
extension Queries {
    /// **The N in "also tag the N current members now"** — how many of the
    /// book's live MEMBERS do not yet wear `tagID`. The SAME predicate
    /// `Operations.tagAllMembers` tags by (live member rows — never arrivals —
    /// whose note is a live post of the tag's wing, archived notes included,
    /// not already wearing it), so the number the offer says is the number
    /// the act will tag, by construction. A dead or missing tag answers 0 (it
    /// can tag nothing). Cost ∝ the book's own rows (P1).
    public static func membersMissingTag(
        _ db: Database, readingID: String, tagID: String
    ) throws -> Int {
        try Int.fetchOne(
            db,
            sql: """
                SELECT COUNT(*) FROM reading_post rp
                JOIN tag t ON t.id = ? AND t.deleted_at IS NULL
                JOIN container c ON c.id = rp.post_id AND c.deleted_at IS NULL
                 AND c.kind = 'post' AND c.wing_id = t.wing_id
                WHERE rp.reading_id = ? AND rp.deleted_at IS NULL AND rp.status = 'member'
                  AND NOT EXISTS (SELECT 1 FROM post_tag pt
                                  WHERE pt.post_id = rp.post_id AND pt.tag_id = t.id
                                    AND pt.deleted_at IS NULL)
                """,
            arguments: [tagID, readingID]) ?? 0
    }
}
