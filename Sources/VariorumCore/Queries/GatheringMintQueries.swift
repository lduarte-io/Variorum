import Foundation
import GRDB

// VX-217 — the ONE read behind a gathering's "+ new note" door. The book
// view calls it to decide whether the door can act (and what its hover
// says); `Operations.newPostInGathering` calls it inside its own write
// transaction to decide what to write. One authority (the architect's rider
// 2): the planner is `GatheringMint.outcome`, fed here from the store.
extension Queries {
    /// What minting a note inside this gathering would take, or why it can't.
    /// `reading` must be a live GATHERING (the caller's guard — a book's
    /// door is `newPostInReading`'s, never this).
    public static func gatheringMintOutcome(
        _ db: Database, reading: Reading
    ) throws -> GatheringMint.Outcome {
        let rule = RuleGrammar.read(reading.querySpec)
        // Tag liveness in THE GATHERING'S WING (`tagIsLive` — the spawn
        // prefill's read): the note is born in that wing, and a tag of
        // another wing never satisfies this rule's terms for it.
        var live: [String: Bool] = [:]
        var dead: [String: String?] = [:]
        // VX-250 (3): the LIVE tags' paths, so the planner can tell when a
        // tag it plans sits inside a NOT term's subtree (`ruleSQL`'s subtree
        // match — the planned tags are always tags this rule names).
        var livePaths: [String: String] = [:]
        if case .rule(let term) = rule {
            for id in RuleGrammar.tagIDs(of: term) {
                let isLive = try tagIsLive(db, id: id, wingID: reading.wingId)
                live[id] = isLive
                if isLive {
                    livePaths[id] = try String.fetchOne(
                        db, sql: "SELECT path FROM tag WHERE id = ?", arguments: [id])
                } else {
                    // The refusal names the tag when any row (even a
                    // tombstone) still knows its path — R98's own rule.
                    dead[id] = try String.fetchOne(
                        db, sql: "SELECT path FROM tag WHERE id = ?", arguments: [id])
                }
            }
        }
        return GatheringMint.outcome(
            archived: reading.archivedAt != nil, finished: reading.locked, rule: rule,
            tagIsLive: { live[$0] ?? false },
            deadTagPath: { dead[$0] ?? nil },
            tagCovers: { ruleTag, wornTag in
                guard let root = livePaths[ruleTag], let worn = livePaths[wornTag] else {
                    return false
                }
                return worn == root || worn.hasPrefix(root + "/")
            })
    }
}
