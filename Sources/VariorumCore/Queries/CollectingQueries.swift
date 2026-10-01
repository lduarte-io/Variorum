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

    /// **The offer's N over the OUTFLOW SET** (13i-c, PROVISIONAL P-13ic-11):
    /// live MEMBERS (archived included — they are counted on the shelf)
    /// missing at least ONE of the book's live, same-wing outflow tags —
    /// exactly the notes `tagAllMembers(nil)` will touch. A book with no
    /// outflow answers 0 (there is nothing to offer).
    public static func membersMissingAnyOutflowTag(
        _ db: Database, readingID: String
    ) throws -> Int {
        guard let reading = try Reading.fetchOne(db, key: readingID),
              reading.deletedAt == nil
        else { return 0 }
        let ids = reading.autoTagIDs
        guard !ids.isEmpty else { return 0 }
        let marks = Array(repeating: "?", count: ids.count).joined(separator: ",")
        return try Int.fetchOne(
            db,
            sql: """
                SELECT COUNT(*) FROM reading_post rp
                JOIN container c ON c.id = rp.post_id AND c.deleted_at IS NULL
                 AND c.kind = 'post' AND c.wing_id = ?
                WHERE rp.reading_id = ? AND rp.deleted_at IS NULL AND rp.status = 'member'
                  AND EXISTS (SELECT 1 FROM tag t
                              WHERE t.id IN (\(marks)) AND t.deleted_at IS NULL
                                AND t.wing_id = c.wing_id
                                AND NOT EXISTS (SELECT 1 FROM post_tag pt
                                                WHERE pt.post_id = rp.post_id AND pt.tag_id = t.id
                                                  AND pt.deleted_at IS NULL))
                """,
            arguments: StatementArguments([reading.wingId, readingID] + ids)) ?? 0
    }
}
