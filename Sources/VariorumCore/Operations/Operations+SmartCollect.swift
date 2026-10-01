import Foundation
import GRDB

// R98 (taste checkpoint, Sitting 9 — batches 7 + 10): "i think that smart
// books should still let you add, and should just tell you that tags are
// going to be added" — refined at the batch-10 question round to APPLY AND
// REPORT ("the user already deliberately tried to add it"), with a filter
// that tagging can't satisfy refusing DESCRIPTIVELY, naming the filter.
// Adding to a gathering mints NO membership row (its assembly is derived,
// #25a) — the add IS the tagging. The 13i sitting's §14.6 recast keeps this
// exactly: "adding a note to a GATHERING applies the tag."
//
// 13i-a: the stored rule is the v2 grammar (Domain/RuleGrammar). The
// collection walk reads the tree's TOP-LEVEL conjuncts — the shapes every
// migrated and door-written rule has (AND of tag terms / one OR-of-tags /
// legacy terms). Anything deeper (NOT, nested trees — authorable only from
// 13i-b's grammar faces) falls through to the end probe, whose standing
// refusal already says the honest thing: tagging alone can't satisfy it.
extension Operations {
    /// What collecting did — the report half of apply-and-report.
    public struct SmartCollectResult: Equatable, Sendable {
        /// Tag paths newly applied to the post (empty when it already
        /// matched the filter).
        public let appliedTagPaths: [String]
        public let alreadyMatched: Bool
    }

    /// Makes the post satisfy the gathering's rule by applying the tags the
    /// rule needs: every missing top-level tag conjunct, plus the FIRST of
    /// an any-of (OR) group when none matches — deterministic, reported.
    /// One transaction: a refusal mid-way applies nothing.
    @discardableResult
    public func collectPostIntoSmartReading(
        _ postID: String, into readingID: String
    ) throws -> SmartCollectResult {
        try database.write { db in
            let post = try livePost(db, postID)
            let reading = try liveReading(db, readingID)
            guard reading.kind == .gathering else {
                throw OperationError.wrongReadingKind(id: readingID, expected: .gathering)
            }
            guard !reading.locked else {
                throw OperationError.lockedReading(id: readingID)
            }
            let term: RuleTerm?
            switch RuleGrammar.read(reading.querySpec) {
            case .malformed:
                throw OperationError.smartFilterUnsatisfiable(
                    readingID: readingID,
                    reason: "its filter is unreadable (malformed) — edit the filter first")
            case .none: term = nil
            case .rule(let t): term = t
            }
            if try matchesRule(db, postID: postID, term: term, wingID: reading.wingId) {
                return SmartCollectResult(appliedTagPaths: [], alreadyMatched: true)
            }
            // The filters tagging cannot satisfy refuse BEFORE any write,
            // naming themselves (her "before June" example).
            if post.archivedAt != nil {
                throw OperationError.smartFilterUnsatisfiable(
                    readingID: readingID,
                    reason: "this note is archived — books don't show archived notes; "
                        + "unarchive it first")
            }
            let conjuncts: [RuleTerm] = switch term {
            case .and(let terms): terms
            case .some(let single): [single]
            case nil: []
            }
            for conjunct in conjuncts {
                switch conjunct {
                case .legacyProfile(let profile) where post.profile?.rawValue != profile:
                    throw OperationError.smartFilterUnsatisfiable(
                        readingID: readingID,
                        reason: "it collects \(profile) notes — this note isn't one, "
                            + "and adding can't change that")
                case .legacyEntryDateFrom, .legacyEntryDateTo:
                    guard let day = post.entryDate else {
                        throw OperationError.smartFilterUnsatisfiable(
                            readingID: readingID,
                            reason: "it collects notes by their entry date — this note has "
                                + "no entry date; set one first (set date…)")
                    }
                    if case .legacyEntryDateFrom(let from) = conjunct, day < from {
                        throw OperationError.smartFilterUnsatisfiable(
                            readingID: readingID,
                            reason: "it collects notes dated \(from) or later — "
                                + "this one is dated \(day)")
                    }
                    if case .legacyEntryDateTo(let to) = conjunct, day > to {
                        throw OperationError.smartFilterUnsatisfiable(
                            readingID: readingID,
                            reason: "it collects notes dated \(to) or earlier — "
                                + "this one is dated \(day)")
                    }
                default:
                    break
                }
            }
            // The tag terms the rule needs: every top-level tag conjunct
            // without a live application, plus an OR group's FIRST tag when
            // none of its members matches (the v1 any-of rule, kept).
            var neededTagIDs: [String] = []
            for conjunct in conjuncts {
                switch conjunct {
                case .tag(let id):
                    if try !hasLiveTagApplication(db, postID: postID, underTagID: id) {
                        neededTagIDs.append(id)
                    }
                case .or(let options):
                    let tagOptions = options.compactMap {
                        if case .tag(let id) = $0 { return id } else { return nil as String? }
                    }
                    // A mixed OR (tags beside star/NOT terms) is not a
                    // taggable group — leave it to the end probe.
                    guard tagOptions.count == options.count, !tagOptions.isEmpty else { break }
                    let satisfied = try tagOptions.contains {
                        try hasLiveTagApplication(db, postID: postID, underTagID: $0)
                    }
                    if !satisfied, let first = tagOptions.first,
                       !neededTagIDs.contains(first) {
                        neededTagIDs.append(first)
                    }
                default:
                    break
                }
            }
            var applied: [String] = []
            let now = date.now
            for tagID in neededTagIDs {
                // The tag row must EXIST AND BE LIVE — the op applies tags,
                // it never mints taxonomy (a build-time call, batch 10). A
                // dead term ('' or a deleted tag) can never be satisfied.
                guard let path = try String.fetchOne(
                    db,
                    sql: "SELECT path FROM tag WHERE id = ? AND deleted_at IS NULL",
                    arguments: [tagID])
                else {
                    // Name the tag when any row (even a tombstone) still
                    // knows its path — the refusal names the filter, the
                    // standing R98 copy.
                    let known = try String.fetchOne(
                        db, sql: "SELECT path FROM tag WHERE id = ?", arguments: [tagID])
                    let name = known.map { "the tag #\($0)" } ?? "a tag"
                    throw OperationError.smartFilterUnsatisfiable(
                        readingID: readingID,
                        reason: "its filter needs \(name), which doesn't exist "
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
                    // The one application road (13i-b U1): adding a note to
                    // a gathering APPLIES the tag (§14.6's R98 recast), and
                    // an applying act is heard by every living book.
                    try insertPostTag(db, tagID: tagID, postID: postID, now: now)
                }
                applied.append(path)
            }
            // The probe must pass now — a rule this op can't satisfy by
            // tagging refuses loudly, and the transaction unwinds the
            // applications (never a half-tagged post).
            guard try matchesRule(db, postID: postID, term: term, wingID: reading.wingId) else {
                throw OperationError.smartFilterUnsatisfiable(
                    readingID: readingID,
                    reason: "tagging alone can't satisfy its filter")
            }
            return SmartCollectResult(appliedTagPaths: applied, alreadyMatched: false)
        }
    }

    /// The assembly's own predicate (`ruleMatchSQL` — ONE implementation,
    /// the Stage B rule), probed for a single post. `starredNoteIDs` is the
    /// star term's context (13i-b U1's intake passes the live list; the
    /// collect door's callers are U4's to wire).
    func matchesRule(
        _ db: Database, postID: String, term: RuleTerm?, wingID: String,
        starredNoteIDs: [String] = []
    ) throws -> Bool {
        let match = Queries.ruleMatchSQL(term, wingID: wingID, starredNoteIDs: starredNoteIDs)
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

    /// A live application of a live tag at-or-under the REFERENCED tag's
    /// subtree (the `ruleMatchSQL` tag test, single-post form — the root is
    /// reached by ID, §19's rule). Wing-scoped exactly as `ruleSQL` is
    /// (13i-b U1 — the two probes must never disagree about a term).
    private func hasLiveTagApplication(
        _ db: Database, postID: String, underTagID tagID: String
    ) throws -> Bool {
        try Bool.fetchOne(
            db,
            sql: """
                SELECT EXISTS (SELECT 1 FROM post_tag pt
                 JOIN tag applied ON applied.id = pt.tag_id AND applied.deleted_at IS NULL
                 JOIN tag root ON root.id = ? AND root.deleted_at IS NULL
                WHERE pt.post_id = ? AND pt.deleted_at IS NULL
                  AND applied.wing_id = root.wing_id
                  AND (applied.path = root.path
                       OR substr(applied.path, 1, length(root.path) + 1) = root.path || '/'))
                """,
            arguments: [tagID, postID]) ?? false
    }
}
