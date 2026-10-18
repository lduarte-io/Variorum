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
// 13i-a: the stored rule is the v2 grammar (Domain/RuleGrammar). VX-249: what
// the note must wear is decided by the mint's planner (`GatheringMint
// .outcome`, through `Queries.gatheringCollectOutcome`), started from what
// the note already wears — ONE authority for the two doors, a ★ term
// satisfiable by starring. The legacy date/profile pre-checks keep R98's
// descriptive refusals; any shape the planner can't aim at refuses with the
// standing honest sentence (tagging alone can't satisfy it), and the end
// probe — the assembly's own predicate — stays the belt.
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
        /// VX-249: whether the act STARRED the note — the rule's ★ term,
        /// satisfied by the one star write (cap-exempt). False when the note
        /// was starred already or the rule asks for no star.
        public let starred: Bool
    }

    /// Makes the post satisfy the gathering's rule by applying what the rule
    /// needs — the mint's planner decides (VX-249): every missing top-level
    /// tag conjunct, an any-of (OR) group's first satisfiable option when
    /// none is met, and the STAR when the rule asks for one — deterministic,
    /// reported. One transaction: a refusal mid-way writes nothing.
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
            let term: RuleTerm
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
                    gatheringArchived: reading.archivedAt != nil, starred: false)
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
            default: [term]
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
            // VX-249 — THE ONE AUTHORITY: what the note must wear is the
            // mint's planner's answer (`GatheringMint.outcome`), started from
            // what this note already wears. So a ★ term is satisfiable here
            // too (her answer to the star asymmetry, QUESTIONS #217): the plan
            // stars the note. The planner's any-of pick (its first SATISFIABLE
            // option, keeping the rule's NOTs holding) and its NOT semantics
            // (VX-250 (3)) are R98's from here on.
            let plan: GatheringMint.Plan
            switch try Queries.gatheringCollectOutcome(
                db, reading: reading, term: term, post: post, starredNoteIDs: starred) {
            case .plan(let p):
                plan = p
            case .blocked(.deadTag(let path)):
                // The tag row must EXIST AND BE LIVE — the op applies tags,
                // it never mints taxonomy (a build-time call, batch 10). The
                // refusal names the tag when any row (even a tombstone)
                // still knows its path — the standing R98 copy.
                let name = path.map { "the tag #\($0)" } ?? "a tag"
                throw OperationError.smartFilterUnsatisfiable(
                    readingID: readingID,
                    reason: "its filter needs \(name), which doesn't exist "
                        + "right now — recreate it (Settings → Tags) first")
            case .blocked:
                throw OperationError.smartFilterUnsatisfiable(
                    readingID: readingID,
                    reason: "tagging alone can't satisfy its filter")
            }
            var applied: [String] = []
            let now = date.now
            for tagID in plan.tagIDs {
                let path = try liveTag(db, tagID).path
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
            // VX-249: the star the rule needs, through the ONE star write —
            // so intake hears it (starring a note is an applying act, 13i-b
            // U1). CAP-EXEMPT by her ruling (2026-10-13 — P-VX217-c's twin:
            // "starring an existing note to collect it ignores the 15-star
            // limit, like the mint"): the limit never blocks the collect.
            if plan.star {
                try writeStar(db, .post(postID), starred: true, enforcingCap: false)
            }
            // The probe must pass now — a rule this op can't satisfy by
            // tagging and starring refuses loudly, and the transaction
            // unwinds every write (never a half-tagged or stray-starred
            // post). The star context is read AGAIN: the plan may have just
            // written the star.
            var after = Queries.StarContext()
            guard try matchesRule(
                db, postID: postID, term: term, wingID: reading.wingId,
                starredNoteIDs: try after.ids(db, for: term))
            else {
                throw OperationError.smartFilterUnsatisfiable(
                    readingID: readingID,
                    reason: "tagging alone can't satisfy its filter")
            }
            return SmartCollectResult(
                appliedTagPaths: applied, alreadyMatched: false,
                gatheringArchived: reading.archivedAt != nil, starred: plan.star)
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
        try Queries.postMatchesRule(
            db, postID: postID, term: term, wingID: wingID, starredNoteIDs: starredNoteIDs)
    }
}
