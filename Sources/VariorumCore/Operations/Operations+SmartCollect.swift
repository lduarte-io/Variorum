import Foundation
import GRDB

// R98 (taste checkpoint, Sitting 9 — batches 7 + 10): "i think that smart
// books should still let you add, and should just tell you that tags are
// going to be added" — refined at the batch-10 question round to APPLY AND
// REPORT ("the user already deliberately tried to add it"), with a filter
// that tagging can't satisfy refusing DESCRIPTIVELY, naming the filter.
// Adding to a smart book mints NO membership row (smart membership is
// derived, #25a) — the add IS the tagging.
extension Operations {
    /// What collecting did — the report half of apply-and-report.
    public struct SmartCollectResult: Equatable, Sendable {
        /// Tag paths newly applied to the post (empty when it already
        /// matched the filter).
        public let appliedTagPaths: [String]
        public let alreadyMatched: Bool
    }

    /// Makes the post satisfy the smart reading's filter by applying the
    /// tags the filter needs: every missing `tagsAll` path, plus the FIRST
    /// `tags` (any-of) path when none matches — deterministic, reported.
    /// One transaction: a refusal mid-way applies nothing.
    @discardableResult
    public func collectPostIntoSmartReading(
        _ postID: String, into readingID: String
    ) throws -> SmartCollectResult {
        try database.write { db in
            let post = try livePost(db, postID)
            let reading = try liveReading(db, readingID)
            guard reading.kind == .smart else {
                throw OperationError.wrongReadingKind(id: readingID, expected: .smart)
            }
            guard !reading.locked else {
                throw OperationError.lockedReading(id: readingID)
            }
            guard let spec = Queries.decodeSpec(reading.querySpec) else {
                throw OperationError.smartFilterUnsatisfiable(
                    readingID: readingID,
                    reason: "its filter is unreadable (malformed) — edit the filter first")
            }
            if try matchesSmartSpec(db, postID: postID, spec: spec) {
                return SmartCollectResult(appliedTagPaths: [], alreadyMatched: true)
            }
            // The filters tagging cannot satisfy refuse BEFORE any write,
            // naming themselves (her "before June" example).
            if post.archivedAt != nil {
                throw OperationError.smartFilterUnsatisfiable(
                    readingID: readingID,
                    reason: "this post is archived — books don't show archived posts; "
                        + "unarchive it first")
            }
            if let profile = spec.profile, post.profile?.rawValue != profile {
                throw OperationError.smartFilterUnsatisfiable(
                    readingID: readingID,
                    reason: "it collects \(profile) posts — this post isn't one, "
                        + "and adding can't change that")
            }
            if spec.entryDateFrom != nil || spec.entryDateTo != nil {
                guard let day = post.entryDate else {
                    throw OperationError.smartFilterUnsatisfiable(
                        readingID: readingID,
                        reason: "it collects posts by their entry date — this post has "
                            + "no entry date; set one first (set date…)")
                }
                if let from = spec.entryDateFrom, day < from {
                    throw OperationError.smartFilterUnsatisfiable(
                        readingID: readingID,
                        reason: "it collects posts dated \(from) or later — "
                            + "this one is dated \(day)")
                }
                if let to = spec.entryDateTo, day > to {
                    throw OperationError.smartFilterUnsatisfiable(
                        readingID: readingID,
                        reason: "it collects posts dated \(to) or earlier — "
                            + "this one is dated \(day)")
                }
            }
            // The tags the filter needs.
            var needed: [String] = []
            for path in spec.tagsAll ?? [] where try !hasLiveTagApplication(
                db, postID: postID, atOrUnder: path) {
                needed.append(path)
            }
            if let anyOf = spec.tags, !anyOf.isEmpty {
                let satisfied = try anyOf.contains {
                    try hasLiveTagApplication(db, postID: postID, atOrUnder: $0)
                }
                if !satisfied, let first = anyOf.first, !needed.contains(first) {
                    needed.append(first)
                }
            }
            var applied: [String] = []
            let now = date.now
            for path in needed {
                // The tag row must EXIST — the op applies tags, it never
                // mints taxonomy (a build-time call, recorded batch 10).
                guard let tagID = try String.fetchOne(
                    db,
                    sql: """
                        SELECT id FROM tag WHERE path = ? AND deleted_at IS NULL
                        ORDER BY id LIMIT 1
                        """,
                    arguments: [path])
                else {
                    throw OperationError.smartFilterUnsatisfiable(
                        readingID: readingID,
                        reason: "its filter needs the tag #\(path), which doesn't exist "
                            + "right now — recreate it (Settings → Tags) first")
                }
                let alreadyApplied = try Bool.fetchOne(
                    db,
                    sql: """
                        SELECT EXISTS (SELECT 1 FROM post_tag
                        WHERE tag_id = ? AND post_id = ? AND deleted_at IS NULL)
                        """,
                    arguments: [tagID, postID]) ?? false
                if !alreadyApplied {
                    try PostTag(id: newID(), tagId: tagID, postId: postID, createdAt: now)
                        .insert(db)
                }
                applied.append(path)
            }
            // The probe must pass now — a filter this op can't satisfy by
            // tagging refuses loudly, and the transaction unwinds the
            // applications (never a half-tagged post).
            guard try matchesSmartSpec(db, postID: postID, spec: spec) else {
                throw OperationError.smartFilterUnsatisfiable(
                    readingID: readingID,
                    reason: "tagging alone can't satisfy its filter")
            }
            return SmartCollectResult(appliedTagPaths: applied, alreadyMatched: false)
        }
    }

    /// The assembly's own predicate (`smartMatchSQL` — ONE implementation,
    /// the Stage B rule), probed for a single post.
    func matchesSmartSpec(
        _ db: Database, postID: String, spec: Queries.SmartQuerySpec
    ) throws -> Bool {
        let match = Queries.smartMatchSQL(spec)
        let conditions = [
            "c.id = ?", "c.deleted_at IS NULL", "c.archived_at IS NULL", "c.kind = 'post'",
        ] + match.conditions
        var arguments: [(any DatabaseValueConvertible)?] = [postID]
        arguments += match.arguments
        return try Bool.fetchOne(
            db,
            sql: "SELECT EXISTS (SELECT 1 FROM container c WHERE "
                + conditions.joined(separator: " AND ") + ")",
            arguments: StatementArguments(arguments)) ?? false
    }

    /// A live application of a live tag at-or-under the path (the
    /// `smartMatchSQL` tag test, single-post form).
    private func hasLiveTagApplication(
        _ db: Database, postID: String, atOrUnder path: String
    ) throws -> Bool {
        try Bool.fetchOne(
            db,
            sql: """
                SELECT EXISTS (SELECT 1 FROM post_tag pt
                 JOIN tag t ON t.id = pt.tag_id AND t.deleted_at IS NULL
                WHERE pt.post_id = ? AND pt.deleted_at IS NULL
                  AND (t.path = ?
                       OR substr(t.path, 1, length(?) + 1) = ? || '/'))
                """,
            arguments: [postID, path, path, path]) ?? false
    }
}
