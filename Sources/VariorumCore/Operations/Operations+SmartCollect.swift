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
        /// VX-241: whether the gathering was ARCHIVED when the act ran (read
        /// in its transaction). An archived gathering assembles EMPTY
        /// everywhere (13i-e), so the receipt must not say it shows the note
        /// now — the tags still apply (explicit adds stay open, R-13ie-4).
        public let gatheringArchived: Bool
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
            case .none:
                // 13i-c (R-13ic-4): no rule shows nothing and has no tag to
                // apply — a Trash restoree's state; give it a rule first.
                throw OperationError.smartFilterUnsatisfiable(
                    readingID: readingID,
                    reason: "it has no rule yet — give it one first")
            case .rule(let t): term = t
            }
            // 13i-b U4 (F-U3-3): the ★ term's context, so a starred note is
            // honestly "already matched" and a tag the door applies can
            // complete a `tag ∧ ★` rule.
            var stars = Queries.StarContext()
            let starred = try stars.ids(db, for: term)
            if try matchesRule(
                db, postID: postID, term: term, wingID: reading.wingId, starredNoteIDs: starred) {
                return SmartCollectResult(
                    appliedTagPaths: [], alreadyMatched: true,
                    gatheringArchived: reading.archivedAt != nil)
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
            guard try matchesRule(
                db, postID: postID, term: term, wingID: reading.wingId, starredNoteIDs: starred)
            else {
                throw OperationError.smartFilterUnsatisfiable(
                    readingID: readingID,
                    reason: "tagging alone can't satisfy its filter")
            }
            return SmartCollectResult(
                appliedTagPaths: applied, alreadyMatched: false,
                gatheringArchived: reading.archivedAt != nil)
        }
    }

    // MARK: - VX-217: a new note born inside a gathering

    /// What minting inside a gathering did — the report half, as R98's.
    public struct GatheringMintResult: Equatable, Sendable {
        public let post: Container
        /// Tag paths applied to the new note, in the rule's order.
        public let appliedTagPaths: [String]
        /// Whether the note was starred (R-VX214-4 — a star term is
        /// satisfiable at mint).
        public let starred: Bool
    }

    /// **NEW NOTE IN A GATHERING** (VX-217; option (A) as ruled, R-VX214-3/4
    /// — the run record `notes/plans/fixes/vx-214-settings-launch-polish.md`).
    /// R98 composed with `newPostInReading`'s refuse-before-mint: ONE
    /// transaction mints the note in the gathering's WING and makes it wear
    /// what the rule needs — the tags (each through the one application road,
    /// so every living book hears the act) and the star where the rule asks
    /// for it (the one star write, so star intake hears it too). Any rule a
    /// fresh note can't be made to match refuses BEFORE the mint with the
    /// reason the door's hover already says (`GatheringMint.Blocker.reason`),
    /// so a refusal leaves no stray note. No membership row (a gathering
    /// holds nothing — §1); no undo entry (`newPostInReading`'s class:
    /// deleting the note is the inverse).
    ///
    /// The star is written cap-exempt — the born-starred mints' precedent
    /// (P-13id-U2-1: "a mint must never fail on a star"); PROVISIONAL, in the
    /// batch record.
    @discardableResult
    public func newPostInGathering(_ readingID: String) throws -> GatheringMintResult {
        try database.write { db in
            let reading = try liveReading(db, readingID)
            guard reading.kind == .gathering else {
                throw OperationError.wrongReadingKind(id: readingID, expected: .gathering)
            }
            let plan: GatheringMint.Plan
            switch try Queries.gatheringMintOutcome(db, reading: reading) {
            case .blocked(let blocker):
                throw OperationError.smartFilterUnsatisfiable(
                    readingID: readingID, reason: blocker.reason)
            case .plan(let p):
                plan = p
            }
            let post = try insertPost(
                db, title: nil, profile: nil, entryDate: nil, wingId: reading.wingId)
            let now = date.now
            var paths: [String] = []
            for tagID in plan.tagIDs {
                let tag = try liveTag(db, tagID)
                try insertPostTag(db, tagID: tagID, postID: post.id, now: now)
                paths.append(tag.path)
            }
            if plan.star {
                try writeStar(db, .post(post.id), starred: true, enforcingCap: false)
            }
            // The belt: the assembly's own predicate decides "the gathering
            // shows it" — the planner only proposes. A plan that fails it
            // unwinds the whole mint (never a stray note).
            let term = RuleGrammar.decode(reading.querySpec)
            var stars = Queries.StarContext()
            let starred = try stars.ids(db, for: term)
            guard try matchesRule(
                db, postID: post.id, term: term, wingID: reading.wingId, starredNoteIDs: starred)
            else {
                throw OperationError.smartFilterUnsatisfiable(
                    readingID: readingID, reason: GatheringMint.unmatchedReason)
            }
            return GatheringMintResult(post: post, appliedTagPaths: paths, starred: plan.star)
        }
    }

    /// The assembly's own predicate (`ruleMatchSQL` — ONE implementation,
    /// the Stage B rule), probed for a single post. `starredNoteIDs` is the
    /// star term's context — REQUIRED since 13i-b U4 (F-U3-3), like
    /// `ruleMatchSQL`'s own: intake passes the live list (U1), the collect
    /// door its `StarContext` (U4).
    func matchesRule(
        _ db: Database, postID: String, term: RuleTerm?, wingID: String,
        starredNoteIDs: [String]
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
