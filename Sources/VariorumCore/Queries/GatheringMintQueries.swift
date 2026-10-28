import Foundation
import GRDB

// VX-217 — the ONE read behind a gathering's "+ new note" door. The book
// view calls it to decide whether the door can act (and what its hover
// says); `Operations.newPostInGathering` calls it inside its own write
// transaction to decide what to write. One authority (the architect's rider
// 2): the planner is `GatheringMint.outcome`, fed here from the store.
//
// VX-249 — R98's collect-EXISTING door (`collectPostIntoSmartReading`) plans
// through the same planner (`gatheringCollectOutcome`), fed the note as it
// stands, so the mint and the collect can never disagree about what a rule
// needs a note to wear.
extension Queries {
    /// What minting a note inside this gathering would take, or why it can't.
    /// `reading` must be a live GATHERING (the caller's guard — a book's
    /// door is `newPostInReading`'s, never this).
    ///
    /// `starrable` (VX-549): `false` for a walk that may not star the note
    /// (`GatheringMint.outcome`'s own parameter; her doors keep the default).
    public static func gatheringMintOutcome(
        _ db: Database, reading: Reading, starrable: Bool = true
    ) throws -> GatheringMint.Outcome {
        let rule = RuleGrammar.read(reading.querySpec)
        var facts = RuleTagFacts()
        if case .rule(let term) = rule {
            facts = try RuleTagFacts(db, term: term, wingID: reading.wingId)
        }
        return GatheringMint.outcome(
            archived: reading.archivedAt != nil, finished: reading.locked, rule: rule,
            tagIsLive: facts.isLive, deadTagPath: facts.deadPath, tagCovers: facts.covers,
            starrable: starrable)
    }

    /// **The MCP door's write new into a gathering** (VX-596, RB-1 PROVISIONAL —
    /// `GatheringMint.starringOnlyWhereNeeded` over THIS store's facts): tags
    /// first, exactly as VX-549 built it, and the star only where the rule
    /// needs one — where it does, her door's own plan (`newPostInGathering`'s).
    /// Read inside the act's own transaction (`Operations.mintNoteEntry`).
    public static func gatheringWireMintOutcome(
        _ db: Database, reading: Reading
    ) throws -> GatheringMint.Outcome {
        try GatheringMint.starringOnlyWhereNeeded { starrable in
            try gatheringMintOutcome(db, reading: reading, starrable: starrable)
        }
    }

    /// **VX-249 — what collecting THIS existing note into the gathering
    /// would take** (R98's apply-and-report door), or why it can't: the
    /// mint's planner, started from what the note already wears — the rule's
    /// tag terms it already meets (`ruleSQL`'s own tag test, read for this
    /// note), its star (`starredNoteIDs`, the caller's `StarContext`), and
    /// its profile and entry date against any legacy term (three-valued, as
    /// SQL is).
    ///
    /// The gathering's own state is the CALLER's: R98 refuses a legacy
    /// finished gathering itself and deliberately collects into an ARCHIVED
    /// one (13i-e — explicit adds stay open; VX-241's honest receipt), so
    /// neither blocks here.
    static func gatheringCollectOutcome(
        _ db: Database, reading: Reading, term: RuleTerm, post: Container,
        starredNoteIDs: [String]
    ) throws -> GatheringMint.Outcome {
        let facts = try RuleTagFacts(db, term: term, wingID: reading.wingId)
        var wears: [String: Bool] = [:]
        for id in RuleGrammar.tagIDs(of: term) {
            wears[id] = try postMatchesRule(
                db, postID: post.id, term: .tag(id), wingID: reading.wingId, starredNoteIDs: [])
        }
        return GatheringMint.outcome(
            archived: false, finished: false, rule: .rule(term),
            tagIsLive: facts.isLive, deadTagPath: facts.deadPath, tagCovers: facts.covers,
            noteWears: { wears[$0] ?? false },
            noteStarred: starredNoteIDs.contains(post.id),
            noteMeetsLegacy: { legacy in
                switch legacy {
                case .legacyProfile(let profile): post.profile.map { $0.rawValue == profile }
                case .legacyEntryDateFrom(let day): post.entryDate.map { $0 >= day }
                case .legacyEntryDateTo(let day): post.entryDate.map { $0 <= day }
                default: nil
                }
            })
    }

    /// The assembly's own predicate (`ruleMatchSQL` — ONE implementation,
    /// the Stage B rule), probed for a single post: live, unarchived, a
    /// note, in the wing, matching the term. `Operations.matchesRule` is
    /// this; `gatheringCollectOutcome` reads a note's tag terms through it.
    static func postMatchesRule(
        _ db: Database, postID: String, term: RuleTerm?, wingID: String,
        starredNoteIDs: [String]
    ) throws -> Bool {
        let match = ruleMatchSQL(term, wingID: wingID, starredNoteIDs: starredNoteIDs)
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

    /// The store facts the planner needs about the tags a rule names, read
    /// in THE GATHERING'S WING (`tagIsLive` — the spawn prefill's read): a
    /// note is born in that wing (or collected into it), and a tag of another
    /// wing never satisfies this rule's terms for it.
    private struct RuleTagFacts {
        var live: [String: Bool] = [:]
        /// The refusal names a dead tag when any row (even a tombstone)
        /// still knows its path — R98's own rule.
        var dead: [String: String?] = [:]
        /// VX-250 (3): the LIVE tags' paths, so the planner can tell when a
        /// tag it plans sits inside a NOT term's subtree (`ruleSQL`'s
        /// subtree match — the planned tags are always tags this rule names).
        var livePaths: [String: String] = [:]

        init() {}

        init(_ db: Database, term: RuleTerm, wingID: String) throws {
            for id in RuleGrammar.tagIDs(of: term) {
                let isLive = try tagIsLive(db, id: id, wingID: wingID)
                live[id] = isLive
                let path = try String.fetchOne(
                    db, sql: "SELECT path FROM tag WHERE id = ?", arguments: [id])
                if isLive {
                    livePaths[id] = path
                } else {
                    dead[id] = path
                }
            }
        }

        func isLive(_ id: String) -> Bool { live[id] ?? false }

        func deadPath(_ id: String) -> String? { dead[id] ?? nil }

        func covers(_ ruleTag: String, _ wornTag: String) -> Bool {
            guard let root = livePaths[ruleTag], let worn = livePaths[wornTag] else {
                return false
            }
            return worn == root || worn.hasPrefix(root + "/")
        }
    }
}
